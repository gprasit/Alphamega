codeunit 60106 "eCom_Order Management_NT"
{
    trigger OnRun()
    var
    begin

    end;

    procedure CompletePaymentVivaWallet(_SalesHeader: Record "Sales Header"): Boolean
    var
        GeneralSetup: Record "eCom_General Setup_NT";
        OK: Boolean;
        CaptureExcessLimit: Decimal;
        OrderAmount: Decimal;
        ResponseMessage: Text;
        txtOrderAmount: Text[30];
    begin
        //CS NT 20220418
        IF (_SalesHeader."Web Order Status" < _SalesHeader."Web Order Status"::Picked) OR
          (_SalesHeader."Web Order Status" = _SalesHeader."Web Order Status"::Cancelled) THEN
            _SalesHeader.FIELDERROR("Web Order Status");

        IF NOT (_SalesHeader."Web Order Payment Status" IN
          [_SalesHeader."Web Order Payment Status"::Pending, _SalesHeader."Web Order Payment Status"::Failed]) THEN
            _SalesHeader.FIELDERROR("Web Order Payment Status");

        IF (_SalesHeader."Web Order Transaction Id" = '') THEN BEGIN
            ErrorMessage2('Web Order Transaction Id" is empty');
            EXIT;
        END;
        OrderAmount := GetOrderAmount(_SalesHeader);
        IF OrderAmount <= 0 THEN
            OrderAmount := AdjustOrderAmount(_SalesHeader);

        GeneralSetup.GET;
        IF (GeneralSetup."Viva Wallet Capture Excess %" > 0) THEN BEGIN
            CaptureExcessLimit := _SalesHeader."Web Order Amount" + (_SalesHeader."Web Order Amount" * GeneralSetup."Viva Wallet Capture Excess %" / 100);
        END;

        IF (OrderAmount > CaptureExcessLimit) THEN BEGIN
            ErrorMessage2('Amount over the excess capture limit.Limit: ' + FORMAT(CaptureExcessLimit) + ' Amount: ' + FORMAT(_SalesHeader."Web Order Amount") + ' Percentage: ' + FORMAT(GeneralSetup."Viva Wallet Capture Excess %"));
            EXIT;
        END;
        //Message2('Capture ' + _SalesHeader."No." + ' with transaction Id ' + _SalesHeader."Web Order Transaction Id" + ' ' +FORMAT(OrderAmount));
        SendRequestVivaWallet(_SalesHeader."Web Order Transaction Id", OrderAmount, 'Capture', 'Capture for Alphamega order ' + _SalesHeader."No.", ResponseMessage);
        IF (STRPOS(ResponseMessage, 'TransactionId:') > 0) THEN BEGIN
            OK := TRUE;
            //Save new transactionId
            Message2('New TransactionId:' + DELSTR(ResponseMessage, 1, 14));
            _SalesHeader."Viva Capture Transaction Id" := DELSTR(ResponseMessage, 1, 14);//Delete 'TransactionId:' and leave the id only
            _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Completed;
            _SalesHeader."Actual Amount Charged" := ROUND(OrderAmount, 0.01);
            _SalesHeader.MODIFY;
            InsertComment(_SalesHeader, STRSUBSTNO('Payment Status: %1', 'Success'));
            ResponseMessage := 'Success';
        END
        ELSE BEGIN
            OK := FALSE;
            _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Failed;
            _SalesHeader.MODIFY;
            InsertComment(_SalesHeader, STRSUBSTNO('Payment Status: %1', ResponseMessage));
        END;

        IF ResponseMessage = 'Success' THEN
            Message2('VivaWallet Capture completed successfully')
        ELSE
            Message2(ResponseMessage);

        EXIT(OK);


    end;

    procedure GetOrderAmount(_SalesHeader: Record "Sales Header") OrderAmt: Decimal
    var
        SalesLine: Record "Sales Line";
        SalesPaymentLine: Record "eCom_Sales Payment Line_NT";
        UnitPrice: Decimal;

    begin
        OrderAmt := 0;
        CLEAR(SalesLine);
        SalesLine.SETRANGE("Document Type", _SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", _SalesHeader."No.");
        IF SalesLine.FINDSET THEN
            REPEAT
                IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::"Return Order" THEN BEGIN
                    IF SalesLine."Unit Price Difference" <> 0 THEN
                        UnitPrice := SalesLine."Unit Price" - SalesLine."Unit Price Difference"
                    ELSE
                        UnitPrice := SalesLine."Unit Price";
                END ELSE
                    IF SalesLine."Actual Unit Price" <> 0 THEN
                        UnitPrice := SalesLine."Unit Price" - SalesLine."Actual Unit Price"
                    ELSE
                        UnitPrice := SalesLine."Unit Price";
                IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::Order THEN
                    OrderAmt += ROUND(SalesLine."Qty. to Ship" * UnitPrice, 0.01) - SalesLine."Line Discount Amount";
                IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::"Return Order" THEN BEGIN
                    IF SalesLine."Return Qty. to Receive" > 0 THEN
                        OrderAmt += ROUND(SalesLine."Return Qty. to Receive" * UnitPrice, 0.01) - SalesLine."Line Discount Amount" + SalesLine."Return Amount to Refund"
                    ELSE
                        IF SalesLine."Unit Price Difference" > 0 THEN
                            OrderAmt += SalesLine.Quantity * (SalesLine."Unit Price" - SalesLine."Unit Price Difference");
                END;
            UNTIL SalesLine.NEXT = 0;
        IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::Order THEN BEGIN
            CLEAR(SalesPaymentLine);
            SalesPaymentLine.SETRANGE("Document Type", _SalesHeader."Document Type");
            SalesPaymentLine.SETRANGE("Document No.", _SalesHeader."No.");
            IF SalesPaymentLine.FINDSET THEN
                REPEAT
                    IF NOT SalesPaymentLine."Card Payment" THEN
                        OrderAmt -= SalesPaymentLine.Amount;
                UNTIL SalesPaymentLine.NEXT = 0;
        END;
        OrderAmt -= _SalesHeader."Invoice Discount Value";
    end;

    procedure AdjustOrderAmount(_SalesHeader: Record "Sales Header") OrderAmt: Decimal
    var
        NewSalesPaymentLine: Record "eCom_Sales Payment Line_NT";
        SalesLine: Record "Sales Line";
        SalesPaymentLine: Record "eCom_Sales Payment Line_NT";
        ActualPoints: Decimal;
        ActualPointsAmount: Decimal;
        ChargeAmount: Decimal;
        Points: Decimal;
        PointsAmount: Decimal;
    begin
        OrderAmt := 0;
        PointsAmount := 0;
        Points := 0;
        ChargeAmount := 0;

        CLEAR(SalesPaymentLine);
        SalesPaymentLine.SETRANGE("Document Type", _SalesHeader."Document Type");
        SalesPaymentLine.SETRANGE("Document No.", _SalesHeader."No.");
        IF SalesPaymentLine.FINDSET THEN
            REPEAT
                IF SalesPaymentLine."Card Payment" THEN
                    ChargeAmount += SalesPaymentLine.Amount
                ELSE
                    IF SalesPaymentLine.Points > 0 THEN BEGIN
                        PointsAmount += SalesPaymentLine.Amount;
                        Points += SalesPaymentLine.Points;
                    END;
            UNTIL SalesLine.NEXT = 0;
        IF PointsAmount >= ChargeAmount THEN BEGIN
            ActualPointsAmount := PointsAmount - ChargeAmount;
            ActualPoints := Points * (ActualPointsAmount / PointsAmount);

            SalesPaymentLine.SETFILTER(Points, '<>%1', 0);
            IF SalesPaymentLine.FINDSET THEN
                REPEAT
                    NewSalesPaymentLine := SalesPaymentLine;
                    SalesPaymentLine.Points := -SalesPaymentLine.Points;
                    SalesPaymentLine.Amount := -SalesPaymentLine.Amount;
                    SalesPaymentLine.MODIFY;
                UNTIL SalesLine.NEXT = 0;
            SalesPaymentLine.SETRANGE(Points);
            SalesPaymentLine.FINDLAST;
            NewSalesPaymentLine."Line No." := SalesPaymentLine."Line No." + 10000;
            NewSalesPaymentLine.Points := ROUND(ActualPoints, 1);
            NewSalesPaymentLine.Amount := ROUND(ActualPointsAmount, 0.01);
            NewSalesPaymentLine.INSERT;
            OrderAmt := ChargeAmount;
        END ELSE
            ERROR('Cannot complete payment');
    end;

    procedure GetOrderOtherAmount(_SalesHeader: Record "Sales Header") OrderAmt: Decimal
    var
        SalesLine: Record "Sales Line";
        SalesPaymentLine: Record "eCom_Sales Payment Line_NT";

    begin
        OrderAmt := 0;
        CLEAR(SalesPaymentLine);
        SalesPaymentLine.SETRANGE("Document Type", _SalesHeader."Document Type");
        SalesPaymentLine.SETRANGE("Document No.", _SalesHeader."No.");
        IF SalesPaymentLine.FINDSET THEN
            REPEAT
                IF NOT SalesPaymentLine."Card Payment" THEN
                    OrderAmt += SalesPaymentLine.Amount;
            UNTIL SalesPaymentLine.NEXT = 0;

    end;

    procedure CreateTransaction(SalesHeader: Record "Sales Header")
    var
        Item: Record Item;
        MemberAttrListTemp: Record "LSC Member Attribute List" temporary;
        MemberPointOfferLine: Record "LSC Member Point Offer Line";
        MemberProcessOrderEntry: Record "LSC Member Process Order Entry";
        MembershipCard: Record "LSC Membership Card";
        MembershipCardTemp: Record "LSC Membership Card" temporary;
        ReturnReason: Record "Return Reason";
        SalesLine: Record "Sales Line";
        SalesPaymentLine: record "eCom_Sales Payment Line_NT";
        Store: Record "LSC Store";
        TransContinuityEntry: Record "eCom_Trans. Contin. Entry_NT";
        TransDiscEntry: record "LSC Trans. Discount Entry";
        TransHeader: Record "LSC Transaction Header";
        TransPayEntry: Record "LSC Trans. Payment Entry";
        TransPointEntry: Record "LSC Trans. Point Entry";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        WebItemSubstitution: Record "eCom_Web Item Substitution_NT";
        WebOrderSalesLine2: record "eCom_Web Order Sales Line_NT";
        WebOrderSalesLine: record "eCom_Web Order Sales Line_NT";
        ContinuityMgt: Codeunit "eCom_Continuity Mgt_NT";
        MemberAttrMgmt: Codeunit "LSC Member Attribute Mgmt";
        //POSCalcMemberPoints: Codeunit "LSC POS Calc. Member Points";
        POSCalcMemberPoints: Codeunit "eCom_POS Calc. Mem. Points_NT";
        POSFunctions: Codeunit "LSC POS Functions";
        rboPriceUtil: Codeunit "LSC Retail Price Utils";
        NegAdjNeeded: Boolean;
        NewEntry: Boolean;
        ExtraPoints: Decimal;
        LineAmount: Decimal;
        Points: Decimal;
        NextTransNo: Integer;
    begin
        IF NOT BatchProcess THEN BEGIN
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN BEGIN
                SalesHeader.TESTFIELD("Web Order Status", SalesHeader."Web Order Status"::Picked);
                SalesHeader.TESTFIELD("Web Order Payment Status", SalesHeader."Web Order Payment Status"::Completed);
            END;
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN
                SalesHeader.TESTFIELD("Web Order Payment Status", SalesHeader."Web Order Payment Status"::Refunded);
        END ELSE BEGIN
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
                SalesHeader.TESTFIELD("Web Order Payment Status", SalesHeader."Web Order Payment Status"::Completed);
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN
                SalesHeader.TESTFIELD("Web Order Payment Status", SalesHeader."Web Order Payment Status"::Refunded);
        END;

        SalesHeader.TESTFIELD("Web Store No.");

        CLEAR(TransHeader);
        TransHeader.SETRANGE("Store No.", SalesHeader."Web Store No.");
        TransHeader.SETRANGE("POS Terminal No.", 'P9999');
        //TransHeader.SETRANGE("Order No.", SalesHeader."No."); BC Upgrade
        TransHeader.SetRange("eCom Order No.", SalesHeader."No.");//BC Upgrade
        TransHeader.SETRANGE("Sale Is Return Sale", FALSE);
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
            IF TransHeader.FINDFIRST THEN
                ERROR('Transaction already created.');

        IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN BEGIN
            //TransHeader.SETRANGE("Order No.", SalesHeader."External Document No."); BC Upgrade
            TransHeader.SetRange("eCom Order No.", SalesHeader."External Document No.");//BC Upgrade
            IF NOT TransHeader.FINDFIRST THEN
                ERROR('Sales Transaction not created.');
            TransHeader.SETRANGE("Sale Is Return Sale", TRUE);
            //TransHeader.SETRANGE("Order No.", SalesHeader."No."); BC Upgrade
            TransHeader.SetRange("eCom Order No.", SalesHeader."No.");//BC Upgrade
            IF TransHeader.FINDFIRST THEN
                ERROR('Return Transaction already created.');
        END;
        Store.GET(SalesHeader."Web Store No.");

        CLEAR(TransHeader);
        TransHeader.SETRANGE("Store No.", SalesHeader."Web Store No.");
        TransHeader.SETRANGE("POS Terminal No.", 'P9999');
        IF TransHeader.FINDLAST THEN
            NextTransNo := TransHeader."Transaction No.";

        NextTransNo += 1;

        //CLEAR(MSRCard);
        //IF SalesHeader."Your Reference" <> '' THEN
        //  IF MSRCard.GET(SalesHeader."Your Reference") THEN;

        CLEAR(TransHeader);
        TransHeader."Store No." := SalesHeader."Web Store No.";
        TransHeader."POS Terminal No." := 'P9999';
        TransHeader."Transaction No." := NextTransNo;
        TransHeader."Transaction Type" := TransHeader."Transaction Type"::Sales;
        TransHeader."Receipt No." := POSFunctions.ZeroPad(TransHeader."POS Terminal No.", 10) +
          POSFunctions.ZeroPad(FORMAT(NextTransNo, 0, '<Integer>'), 9);
        TransHeader."Sale Is Return Sale" := SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order";
        TransHeader."VAT Bus.Posting Group" := SalesHeader."VAT Bus. Posting Group";
        TransHeader.Date := TODAY;
        TransHeader."Original Date" := SalesHeader."Posting Date";
        TransHeader.Time := TIME;
        TransHeader."Customer No." := SalesHeader."Sell-to Customer No.";
        //TransHeader."Order No." := SalesHeader."No."; BC Upgrade
        TransHeader."eCom Order No." := SalesHeader."No.";//BC Upgrade
        TransHeader."Continuity Member No." := SalesHeader."Stick And Win Phone";
        TransHeader."Member Card No." := SalesHeader."LSC Member Card No.";
        TransHeader."Total Discount" := SalesHeader."Invoice Discount Value";
        TransHeader."Apply to Doc. No." := COPYSTR(SalesHeader."Order Shipping Method", 1, 20);
        /* BC Upgrade lines commented as can not add functions in standard codeunits
        CLEAR(rboPriceUtil);
        IF SalesHeader."Member Card No." <> '' THEN BEGIN
            MembershipCard.GET(SalesHeader."Member Card No.");
            rboPriceUtil.SetMemberInfo2(MembershipCard);
        END ELSE
            CLEAR(MembershipCard);
        */
        //BC Upgrade Start
        CLEAR(rboPriceUtil);
        MembershipCardTemp.DeleteAll();
        IF SalesHeader."LSC Member Card No." <> '' THEN BEGIN
            MembershipCard.GET(SalesHeader."LSC Member Card No.");
            MembershipCardTemp.Init();
            MembershipCardTemp := MembershipCard;
            MembershipCardTemp.Insert();
            MemberAttrMgmt.GetAllAttributes(MembershipCard."Card No.", MemberAttrListTemp);
            rboPriceUtil.SetMemberInfo(MembershipCardTemp, MemberAttrListTemp);
        END ELSE
            CLEAR(MembershipCard);
        //BC Upgrade End
        CLEAR(SalesLine);
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
            SalesLine.SETFILTER("Qty. to Ship", '<>%1', 0);
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN BEGIN
            SalesLine.SETFILTER("Return Qty. to Receive", '<>%1', 0);
            SalesLine.SETFILTER("Actual Unit Price", '=%1', 0);
        END;
        NegAdjNeeded := FALSE;
        SalesLine.FINDSET;
        ExtraPoints := 0;
        REPEAT
            IF WebItemSubstitution.GET(SalesLine."No.") THEN
                Item.GET(WebItemSubstitution."Item No.")
            ELSE
                Item.GET(SalesLine."No.");
            CLEAR(TransSalesEntry);
            TransSalesEntry."Store No." := TransHeader."Store No.";
            TransSalesEntry."POS Terminal No." := TransHeader."POS Terminal No.";
            TransSalesEntry."Transaction No." := TransHeader."Transaction No.";
            TransSalesEntry."Line No." := SalesLine."Line No.";
            TransSalesEntry."Receipt No." := TransHeader."Receipt No.";
            //TransSalesEntry."Barcode No." := SalesLine."Barcode No.";
            TransSalesEntry."Item No." := Item."No.";
            TransSalesEntry."Item Category Code" := Item."Item Category Code";
            //TransSalesEntry."Product Group Code" := Item."Product Group Code"; BC Upgrade
            TransSalesEntry."Retail Product Code" := Item."LSC Retail Product Code";//BC Upgrade
            TransSalesEntry."ASR Department Code" := SalesHeader."Original Store No.";
            IF SalesLine."Web Order Original Price" <> 0 THEN
                TransSalesEntry.Price := SalesLine."Web Order Original Price"
            ELSE
                TransSalesEntry.Price := SalesLine."Web Order Unit Price";
                            
            TransSalesEntry."Net Price" := TransSalesEntry.Price / (1 + (SalesLine."VAT %" / 100));
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN BEGIN
                TransSalesEntry.Quantity := -SalesLine."Qty. to Ship (Base)";
                TransSalesEntry."Cost Amount" := -SalesLine."Unit Cost (LCY)";
                LineAmount := ROUND(SalesLine."Qty. to Ship" * SalesLine."Unit Price", 0.01) - SalesLine."Line Discount Amount" - SalesLine."Inv. Discount Amount";
                TransSalesEntry."Net Amount" := -(LineAmount / (1 + (SalesLine."VAT %" / 100)));
                TransSalesEntry."VAT Amount" := -LineAmount - TransSalesEntry."Net Amount";
                TransSalesEntry."UOM Quantity" := -SalesLine."Qty. to Ship";
                TransSalesEntry."Refund Qty." := SalesLine."Qty. to Ship";
            END;
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN BEGIN

                IF NOT NegAdjNeeded THEN BEGIN
                    SalesLine.TESTFIELD("Return Reason Code");
                    ReturnReason.GET(SalesLine."Return Reason Code");
                    NegAdjNeeded := ReturnReason."Transaction Type" = ReturnReason."Transaction Type"::"Return & Adjust";
                END;

                TransSalesEntry.Quantity := SalesLine."Return Qty. to Receive (Base)";
                TransSalesEntry."Cost Amount" := SalesLine."Unit Cost (LCY)";
                LineAmount := ROUND(SalesLine."Return Qty. to Receive" * SalesLine."Unit Price", 0.01) - SalesLine."Line Discount Amount" - SalesLine."Inv. Discount Amount";
                TransSalesEntry."Net Amount" := (LineAmount / (1 + (SalesLine."VAT %" / 100)));
                TransSalesEntry."VAT Amount" := LineAmount - TransSalesEntry."Net Amount";
                TransSalesEntry."UOM Quantity" := SalesLine."Return Qty. to Receive";
                TransSalesEntry."Refund Qty." := 0;
            END;
            TransSalesEntry."Total Discount" := SalesLine."Inv. Discount Amount";
            TransSalesEntry."VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
            TransSalesEntry."VAT Code" := GetVatCode(SalesLine."VAT %");
            TransSalesEntry.Date := TransHeader.Date;
            TransSalesEntry.Time := TransHeader.Time;

            //IF SalesLine."LSC Offer No." <> '' THEN BEGIN //BC Upgrade
            if (SalesLine."LSC Offer No." <> '') or (SalesLine."Inv. Discount Amount" <> 0) then begin //BC Upgrade
                IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN
                    TransSalesEntry."Discount Amount" := -ABS(TransSalesEntry.Price * TransSalesEntry.Quantity) + (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount")
                ELSE
                    TransSalesEntry."Discount Amount" := ABS(TransSalesEntry.Price * TransSalesEntry.Quantity) + (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount");
                TransSalesEntry."Disc. Amount From Std. Price" := (TransSalesEntry."Net Price" * TransSalesEntry.Quantity) - TransSalesEntry."Net Amount";
                TransSalesEntry."Periodic Discount" := TransSalesEntry."Discount Amount";
                TransSalesEntry."Periodic Disc. Type" := TransSalesEntry."Periodic Disc. Type"::"Disc. Offer";
                TransSalesEntry."Periodic Disc. Group" := SalesLine."LSC Offer No.";
            END;
            TransSalesEntry."Total Rounded Amt." := TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount";
            TransSalesEntry."Promotion No." := '';
            TransSalesEntry."Standard Net Price" := TransSalesEntry."Net Price";
            TransSalesEntry."Customer No." := SalesHeader."Sell-to Customer No.";
            TransSalesEntry."Line was Discounted" := TransSalesEntry."Disc. Amount From Std. Price" <> 0;
            TransSalesEntry."Variant Code" := SalesLine."Variant Code";
            TransSalesEntry."Line Discount" := 0;
            TransSalesEntry."Unit of Measure" := SalesLine."Unit of Measure Code";
            TransSalesEntry."UOM Price" := SalesLine."Unit Price";
            TransSalesEntry."Item Family Code" := Item."LSC Item Family Code";
            TransSalesEntry."Item Brand Code" := Item."Item Brand Code";

            TransSalesEntry."Item Posting Group" := Item."Inventory Posting Group";
            TransSalesEntry."Discount Offer No." := SalesLine."LSC Offer No.";
            TransSalesEntry.INSERT;

            IF SalesHeader."LSC Member Card No." <> '' THEN
                IF FindActiveOfferInStore(rboPriceUtil, TransHeader, TransSalesEntry, MembershipCard, Store, Item, MemberPointOfferLine) THEN
                    ExtraPoints += ROUND(MemberPointOfferLine.Value * ABS((TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount")), 1, '<');

            IF SalesLine."LSC Offer No." <> '' THEN BEGIN
                CLEAR(TransDiscEntry);
                TransDiscEntry."Transaction No." := TransSalesEntry."Transaction No.";
                TransDiscEntry."Line No." := TransSalesEntry."Line No.";
                TransDiscEntry."Receipt No." := TransSalesEntry."Receipt No.";
                TransDiscEntry."Store No." := TransSalesEntry."Store No.";
                TransDiscEntry."POS Terminal No." := TransSalesEntry."POS Terminal No.";
                TransDiscEntry."Offer Type" := TransDiscEntry."Offer Type"::"Disc. Offer";
                TransDiscEntry."Offer No." := SalesLine."LSC Offer No.";
                TransDiscEntry."Discount Amount" := TransSalesEntry."Discount Amount";
                TransDiscEntry."Sequence Code" := TransDiscEntry."Sequence Code"::A;
                TransDiscEntry."Sequence Function" := TransDiscEntry."Sequence Function"::Highest;
                TransDiscEntry.INSERT;
            END;

            TransHeader."Net Amount" += TransSalesEntry."Net Amount";
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN BEGIN
                IF NOT Item."No Loyalty Points" THEN
                    TransHeader."Loyalty Gross Amount" += -LineAmount;
                TransHeader."Gross Amount" += -LineAmount;
                TransHeader."Discount Amount" += SalesLine."Line Discount Amount";
                TransHeader."No. of Items" += SalesLine."Qty. to Ship (Base)";
                TransHeader."Cost Amount" += TransSalesEntry."Cost Amount";
                TransHeader."Discount Amount" += TransSalesEntry."Discount Amount";
                CLEAR(WebOrderSalesLine);
                WebOrderSalesLine."Document Type" := SalesLine."Document Type";
                WebOrderSalesLine."Document No." := SalesLine."Document No.";
                WebOrderSalesLine."Line No." := SalesLine."Line No.";
                WebOrderSalesLine."Entry No." := 1;
                WebOrderSalesLine."Invoiced Quantity" := SalesLine."Qty. to Ship (Base)";
                WebOrderSalesLine."Refund Quantity" := 0;
                WebOrderSalesLine."Remaining Quantity" := SalesLine."Qty. to Ship (Base)";
                WebOrderSalesLine.INSERT;

            END;
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN BEGIN
                TransHeader."Gross Amount" += LineAmount;
                TransHeader."Discount Amount" += SalesLine."Line Discount Amount";
                TransHeader."No. of Items" -= SalesLine."Return Qty. to Receive (Base)";
                TransHeader."Cost Amount" += TransSalesEntry."Cost Amount";
                TransHeader."Discount Amount" += TransSalesEntry."Discount Amount";
                CLEAR(WebOrderSalesLine);
                WebOrderSalesLine.SETRANGE("Document Type", SalesLine."From Document Type");
                WebOrderSalesLine.SETRANGE("Document No.", SalesLine."From Document No.");
                WebOrderSalesLine.SETRANGE("Line No.", SalesLine."From Line No.");
                IF WebOrderSalesLine.FINDLAST THEN BEGIN
                    WebOrderSalesLine.CALCFIELDS("Refunded Quantity");
                    WebOrderSalesLine2 := WebOrderSalesLine;
                    NewEntry := WebOrderSalesLine2."Refund Document No." <> '';
                    IF NewEntry THEN
                        WebOrderSalesLine2."Entry No." += 1;
                    WebOrderSalesLine2."Refund Document Type" := SalesLine."Document Type";
                    WebOrderSalesLine2."Refund Document No." := SalesLine."Document No.";
                    WebOrderSalesLine2."Refund Line No." := SalesLine."Line No.";
                    WebOrderSalesLine2."Refund Quantity" += SalesLine."Return Qty. to Receive (Base)";
                    WebOrderSalesLine2."Remaining Quantity" := WebOrderSalesLine2."Invoiced Quantity" - WebOrderSalesLine."Refunded Quantity" - WebOrderSalesLine2."Refund Quantity";
                    IF WebOrderSalesLine2."Remaining Quantity" < 0 THEN
                        ERROR('You cannot return more than %1 for item %2', WebOrderSalesLine2."Invoiced Quantity" - WebOrderSalesLine."Refunded Quantity", SalesLine."No.");
                    IF NewEntry THEN
                        WebOrderSalesLine2.INSERT
                    ELSE
                        WebOrderSalesLine2.MODIFY;
                END;
            END;

        UNTIL SalesLine.NEXT = 0;

        Points := 0;

        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN BEGIN
            CLEAR(SalesPaymentLine);
            SalesPaymentLine.SETRANGE("Document Type", SalesHeader."Document Type");
            SalesPaymentLine.SETRANGE("Document No.", SalesHeader."No.");
            IF SalesPaymentLine.FINDSET THEN BEGIN
                REPEAT
                    CLEAR(TransPayEntry);
                    TransPayEntry."Store No." := TransHeader."Store No.";
                    TransPayEntry."POS Terminal No." := TransHeader."POS Terminal No.";
                    TransPayEntry."Transaction No." := TransHeader."Transaction No.";
                    TransPayEntry."Line No." := SalesPaymentLine."Line No.";
                    TransPayEntry."Receipt No." := TransHeader."Receipt No.";
                    TransPayEntry."Tender Type" := SalesPaymentLine."Tender Type";
                    TransPayEntry.Quantity := 1;
                    IF SalesPaymentLine."Card Payment" THEN BEGIN
                        TransPayEntry."Amount Tendered" := GetOrderAmount(SalesHeader);
                        TransPayEntry."Amount in Currency" := TransPayEntry."Amount Tendered";
                        Points += TransPayEntry."Amount Tendered";
                        TransHeader.Payment -= TransPayEntry."Amount Tendered";
                    END ELSE BEGIN
                        TransPayEntry."Amount Tendered" := SalesPaymentLine.Amount;
                        TransPayEntry."Amount in Currency" := SalesPaymentLine.Amount;
                        Points += SalesPaymentLine.Amount;
                        TransHeader.Payment -= SalesPaymentLine.Amount;
                    END;
                    TransPayEntry.Date := TransHeader.Date;
                    TransPayEntry.Time := TransHeader.Time;
                    TransPayEntry.INSERT;
                UNTIL SalesPaymentLine.NEXT = 0
            END ELSE BEGIN
                CLEAR(TransPayEntry);
                TransPayEntry."Store No." := TransHeader."Store No.";
                TransPayEntry."POS Terminal No." := TransHeader."POS Terminal No.";
                TransPayEntry."Transaction No." := TransHeader."Transaction No.";
                TransPayEntry."Line No." := 10000;
                TransPayEntry."Receipt No." := TransHeader."Receipt No.";
                TransPayEntry."Tender Type" := '90';
                TransPayEntry.Quantity := 1;
                TransPayEntry."Amount Tendered" := -TransHeader."Gross Amount";
                TransPayEntry."Amount in Currency" := -TransHeader."Gross Amount";
                TransPayEntry.Date := TransHeader.Date;
                TransPayEntry.Time := TransHeader.Time;
                TransPayEntry.INSERT;
                TransHeader.Payment := -TransHeader."Gross Amount";
                Points := -TransHeader."Gross Amount";
            END;
        END;

        IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN BEGIN
            CLEAR(TransPayEntry);
            TransPayEntry."Store No." := TransHeader."Store No.";
            TransPayEntry."POS Terminal No." := TransHeader."POS Terminal No.";
            TransPayEntry."Transaction No." := TransHeader."Transaction No.";
            TransPayEntry."Line No." := 10000;
            TransPayEntry."Receipt No." := TransHeader."Receipt No.";
            TransPayEntry."Tender Type" := '90';
            TransPayEntry.Quantity := 1;
            TransPayEntry."Amount Tendered" := -TransHeader."Gross Amount";
            TransPayEntry."Amount in Currency" := -TransHeader."Gross Amount";
            TransPayEntry.Date := TransHeader.Date;
            TransPayEntry.Time := TransHeader.Time;
            TransPayEntry.INSERT;
            TransHeader.Payment := -TransHeader."Gross Amount";
            IF SalesHeader."LSC Member Card No." <> '' THEN BEGIN
                TransPointEntry.INIT;
                TransPointEntry."Store No." := TransHeader."Store No.";
                TransPointEntry."POS Terminal No." := TransHeader."POS Terminal No.";
                TransPointEntry."Transaction No." := TransHeader."Transaction No.";
                TransPointEntry."Receipt No." := TransHeader."Receipt No.";
                TransPointEntry."Entry Type" := TransPointEntry."Entry Type"::Sale;
                TransPointEntry."Point Type" := TransPointEntry."Point Type"::Award;
                TransPointEntry.Points := ROUND(-TransHeader."Gross Amount", 1, '<');
                TransPointEntry."Tender Points" := TransPointEntry.Points;
                TransPointEntry.Date := TransHeader.Date;
                TransPointEntry."Card No." := TransHeader."Member Card No.";
                TransPointEntry."Value Per Point" := 0;
                TransPointEntry.INSERT(TRUE);
                POSCalcMemberPoints.CreateProcessOrderEntry(TransHeader, MembershipCard."Account No.", MemberProcessOrderEntry);
            END;
        END;

        //TransHeader."Member Card No." := MSRCard."Card No.";
        TransHeader.INSERT(TRUE);

        SalesHeader."Receipt No." := TransHeader."Receipt No.";
        SalesHeader."LSC Store No." := TransHeader."Store No.";
        SalesHeader."LSC POS ID" := TransHeader."POS Terminal No.";
        SalesHeader."Transaction No." := TransHeader."Transaction No.";
        SalesHeader."Completed Date" := TODAY;
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN BEGIN
            SalesHeader."Web Order Status" := SalesHeader."Web Order Status"::Completed;
            IF SalesHeader."LSC Member Card No." <> '' THEN BEGIN
                TransPointEntry.INIT;
                TransPointEntry."Store No." := TransHeader."Store No.";
                TransPointEntry."POS Terminal No." := TransHeader."POS Terminal No.";
                TransPointEntry."Transaction No." := TransHeader."Transaction No.";
                TransPointEntry."Receipt No." := TransHeader."Receipt No.";
                TransPointEntry."Entry Type" := TransPointEntry."Entry Type"::Sale;
                TransPointEntry."Point Type" := TransPointEntry."Point Type"::Award;
                TransPointEntry.Points := ROUND(Points, 1, '<');
                TransPointEntry."Tender Points" := TransPointEntry.Points;
                TransPointEntry.Date := TransHeader.Date;
                TransPointEntry."Card No." := TransHeader."Member Card No.";
                TransPointEntry."Value Per Point" := 0;
                TransPointEntry.INSERT(TRUE);
                IF ExtraPoints > 0 THEN BEGIN
                    TransPointEntry.INIT;
                    TransPointEntry."Store No." := TransHeader."Store No.";
                    TransPointEntry."POS Terminal No." := TransHeader."POS Terminal No.";
                    TransPointEntry."Transaction No." := TransHeader."Transaction No.";
                    TransPointEntry."Receipt No." := TransHeader."Receipt No.";
                    TransPointEntry."Entry Type" := TransPointEntry."Entry Type"::Sale;
                    TransPointEntry."Point Type" := TransPointEntry."Point Type"::Other;
                    TransPointEntry.Points := ROUND(ExtraPoints, 1, '<');
                    TransPointEntry."Tender Points" := ExtraPoints;
                    TransPointEntry.Date := TransHeader.Date;
                    TransPointEntry."Card No." := TransHeader."Member Card No.";
                    TransPointEntry."Value Per Point" := 0;
                    TransPointEntry.INSERT(TRUE);
                END;
                POSCalcMemberPoints.CreateProcessOrderEntry(TransHeader, MembershipCard."Account No.", MemberProcessOrderEntry);
            END;
        END;

        IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" THEN BEGIN
            SalesHeader."Web Order Status" := SalesHeader."Web Order Status"::Reversed;
            SalesHeader."Return Status" := SalesHeader."Return Status"::Completed;
        END;

        SalesHeader.MODIFY;

        IF NegAdjNeeded THEN
            CreateNegAdjTransaction(SalesHeader, NextTransNo);

        COMMIT;
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN BEGIN
            ContinuityMgt.SalesAdvice(TransHeader, TransContinuityEntry);
            SendReceiptByMail2(TransHeader, SalesHeader."E-Mail", SalesHeader."Ship-to Name");
        end;
    end;
    procedure SendReceiptByMail2(TransHeader: Record "LSC Transaction Header"; Email: Text; CustName: Text): Text
    var
        CompanyInformation: Record "Company Information";
        EmailAccount: Record "Email Account";
        EmailItem: Record "Email Item" temporary;
        EmailScenario: Codeunit "Email Scenario";
        MailManagement: Codeunit "Mail Management";
        POSFunctions: Codeunit "LSC POS Functions";
        TransInvoice: Report "Transaction Invoice_NT";
        VarInStream: InStream;
        OutStr: OutStream;
        BodyBuffer: Text;
        EmailAddressesErrorText: Text;
        LastErrorText: Text;
        MailSubject: Text;
        CannotSendMailErr: Label 'You cannot send the email.\Verify that the email settings are correct.';
    begin

        if MailManagement.IsEnabled() then begin
            Clear(TransInvoice);
            EmailItem.Init();
            EmailItem.Body.CreateOutStream(OutStr);
            TransHeader.SETRECFILTER;
            TransInvoice.SetTableView(TransHeader);

            TransInvoice.SaveAs('', ReportFormat::Pdf, OutStr);
            BodyBuffer := (STRSUBSTNO('<html><body><p>Dear %1,</p>' +
               '<p>Thank you for choosing Alphamega. The attached document is your final receipt following order preparation. You have been charged with this total amount.</p>' +
               '<p>This receipt includes the products you have ordered, as well as any substitutions that have been made. If you would like to reject one of our substitutions, ' +
               'you can return it to the driver upon delivery of your order.</p><p>Alternatively, you can return products, including any unwanted substitutions, to any of our stores ' +
               'by presenting this receipt. Please read through our <a href="https://www.alphamega.com.cy/en/cart/returns-policy" target="_blank" rel="noopener">' +
               '<strong><u>Returns policy</u></strong></a> before returning products to our stores, since Terms &amp; Conditions apply.</p><p>This is a no-reply email and ' +
               'cannot accept any replies. For any questions you may have, visit our <a href="https://www.alphamega.com.cy/en/help/faq" target="_blank" rel="noopener">' +
               '<strong><u>Frequently asked questions</u></strong></a> section. If you cannot find an answer to your question, contact us at any of the communication channels listed below. ' +
               '&nbsp;</p><p>Best regards, <p>Alphamega</p></p></body></html>', CustName));

            CompanyInformation.Get;
            EmailItem."From Name" := CompanyInformation.Name;
            EmailScenario.GetEmailAccount("Email Scenario"::Default, EmailAccount);
            EmailItem."From Address" := EmailAccount."Email Address";
            EmailItem."Send to" := Email;
            MailSubject := 'Receipts';
            EmailItem.Subject := MailSubject;
            EmailItem.Body.CreateInStream(VarInStream);
            EmailItem.AddAttachment(VarInStream, MailSubject + '.pdf');
            EmailItem."Plaintext Formatted" := false;
            EmailItem."Message Type" := EmailItem."Message Type"::"From Email Body Template";
            EmailItem.SetBodyText(BodyBuffer);
            MailManagement.InitializeFrom(true, true);

            if not POSFunctions.ValidateEmailAddresses(EmailItem, EmailAddressesErrorText) then begin
                LastErrorText := EmailAddressesErrorText;
                exit(LastErrorText);
            end;
            if not MailManagement.Send(EmailItem, "Email Scenario"::Notification) then begin
                LastErrorText := CannotSendMailErr;
                exit(LastErrorText);
            end;
        end;
    end;

    procedure CreateNegAdjTransaction(SalesHeader: Record "Sales Header"; NextTransNo: Integer)
    var
        Item: Record Item;
        ReturnReason: Record "Return Reason";
        SalesLine: Record "Sales Line";
        TransHeader: Record "LSC Transaction Header";
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        TransInventoryEntry: Record "LSC Trans. Inventory Entry";
        WebItemSubstitution: Record "eCom_Web Item Substitution_NT";
        POSFunctions: Codeunit "LSC POS Functions";
    begin
        NextTransNo += 1;

        CLEAR(TransHeader);
        TransHeader."Store No." := SalesHeader."Web Store No.";
        TransHeader."POS Terminal No." := 'P9999';
        TransHeader."Transaction No." := NextTransNo;
        TransHeader."Transaction Type" := TransHeader."Transaction Type"::NegAdj;
        TransHeader."Receipt No." := POSFunctions.ZeroPad(TransHeader."POS Terminal No.", 10) +
          POSFunctions.ZeroPad(FORMAT(NextTransNo, 0, '<Integer>'), 9);
        TransHeader."VAT Bus.Posting Group" := SalesHeader."VAT Bus. Posting Group";
        TransHeader.Date := TODAY;
        TransHeader."Original Date" := SalesHeader."Posting Date";
        TransHeader.Time := TIME;
        //TransHeader."Order No." := SalesHeader."No.";//BC Upgrade
        TransHeader."eCom Order No." := SalesHeader."No.";//BC Upgrade
        TransHeader.INSERT;

        CLEAR(TransInfoEntry);
        TransInfoEntry."Store No." := TransHeader."Store No.";
        TransInfoEntry."POS Terminal No." := TransHeader."POS Terminal No.";
        TransInfoEntry."Transaction No." := TransHeader."Transaction No.";
        TransInfoEntry."Line No." := 0;
        TransInfoEntry."Transaction Type" := TransInfoEntry."Transaction Type"::Header;
        TransInfoEntry."Type of Input" := TransInfoEntry."Type of Input"::SubCode;

        //TransInfoEntry.Information := 
        //TransInfoEntry.Infocode := 
        //TransInfoEntry.Subcode := 

        TransInfoEntry.Date := TransHeader.Date;
        TransInfoEntry.Time := TransHeader.Time;
        TransInfoEntry.INSERT;

        CLEAR(SalesLine);
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        SalesLine.SETFILTER("Return Qty. to Receive", '<>%1', 0);
        SalesLine.SETFILTER("Actual Unit Price", '=%1', 0);
        SalesLine.FINDSET;
        REPEAT
            SalesLine.TESTFIELD("Return Reason Code");
            ReturnReason.GET(SalesLine."Return Reason Code");
            IF ReturnReason."Transaction Type" = ReturnReason."Transaction Type"::"Return & Adjust" THEN BEGIN
                IF WebItemSubstitution.GET(SalesLine."No.") THEN
                    Item.GET(WebItemSubstitution."Item No.")
                ELSE
                    Item.GET(SalesLine."No.");
                CLEAR(TransInventoryEntry);
                TransInventoryEntry."Store No." := TransHeader."Store No.";
                TransInventoryEntry."POS Terminal No." := TransHeader."POS Terminal No.";
                TransInventoryEntry."Transaction No." := TransHeader."Transaction No.";
                TransInventoryEntry."Line No." := SalesLine."Line No.";
                TransInventoryEntry."Receipt No." := TransHeader."Receipt No.";
                TransInventoryEntry."Item No." := Item."No.";
                TransInventoryEntry.Quantity := SalesLine."Return Qty. to Receive (Base)";
                TransInventoryEntry.Date := TransHeader.Date;
                TransInventoryEntry.Time := TransHeader.Time;
                TransInventoryEntry.INSERT;
            END;
        UNTIL SalesLine.NEXT = 0;
    end;

    procedure ReverseTransaction(SalesHeader: Record "Sales Header")
    var
        Store: Record "LSC Store";
        TransactionHeader: Record "LSC Transaction Header";
        TransDiscountEntry2: Record "LSC Trans. Discount Entry";
        TransDiscountEntry: Record "LSC Trans. Discount Entry";
        TransHeader2: Record "LSC Transaction Header";
        TransHeader: Record "LSC Transaction Header";
        TransInfocodeEntry2: Record "LSC Trans. Infocode Entry";
        TransInfocodeEntry: Record "LSC Trans. Infocode Entry";
        TransMixMatchEntry2: Record "LSC Trans. Mix & Match Entry";
        TransMixMatchEntry: Record "LSC Trans. Mix & Match Entry";
        TransPmtEntry2: Record "LSC Trans. Payment Entry";
        TransPmtEntry: Record "LSC Trans. Payment Entry";
        TransSalesEntry2: Record "LSC Trans. Sales Entry";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        POSFunctions: Codeunit "LSC POS Functions";
        NextTransNo: integer;
    begin
        CLEAR(TransactionHeader);
        TransactionHeader.SETRANGE("Store No.", SalesHeader."Web Store No.");
        TransactionHeader.SETRANGE("POS Terminal No.", 'P9999');
        //TransactionHeader.SETRANGE("Order No.", SalesHeader."No.");//BC Upgrade
        TransactionHeader.SETRANGE("eCom Order No.", SalesHeader."No.");//BC Upgrade
        IF NOT TransactionHeader.FINDFIRST THEN
            ERROR('Transaction not found.');

        //TransactionHeader.TESTFIELD("Order No.");BC Upgrade
        TransactionHeader.TESTFIELD("eCom Order No.");//BC Upgrade
        TransactionHeader.TESTFIELD("Sale Is Return Sale", FALSE);

        Store.GET(SalesHeader."Web Store No.");

        CLEAR(TransHeader);
        TransHeader.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransHeader.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransHeader.FINDLAST;
        NextTransNo := TransHeader."Transaction No." + 1;

        TransHeader2 := TransactionHeader;
        TransHeader2."Receipt No." := POSFunctions.ZeroPad(TransHeader2."POS Terminal No.", 10) +
          POSFunctions.ZeroPad(FORMAT(NextTransNo, 0, '<Integer>'), 9);
        TransHeader2.Date := TODAY; // NIKOLAS
        TransHeader2."Transaction No." := NextTransNo;
        TransHeader2."Gross Amount" := -TransactionHeader."Gross Amount";
        TransHeader2."Net Amount" := -TransactionHeader."Net Amount";
        TransHeader2.Payment := -TransactionHeader.Payment;
        TransHeader2."Discount Amount" := -TransactionHeader."Discount Amount";
        TransHeader2."Cost Amount" := -TransactionHeader."Cost Amount";
        TransHeader2."Sale Is Return Sale" := TRUE;
        TransHeader2.INSERT(TRUE);
        TransactionHeader."Refund Receipt No." := TransHeader2."Receipt No.";
        TransactionHeader.MODIFY(TRUE);
        CLEAR(TransSalesEntry);
        TransSalesEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF TransSalesEntry.FINDSET THEN
            REPEAT
                CLEAR(TransSalesEntry2);
                TransSalesEntry2 := TransSalesEntry;
                TransSalesEntry2."Receipt No." := TransHeader2."Receipt No.";
                TransSalesEntry2."Transaction No." := TransHeader2."Transaction No.";
                TransSalesEntry2.Quantity := -TransSalesEntry.Quantity;
                TransSalesEntry2."Net Amount" := -TransSalesEntry."Net Amount";
                TransSalesEntry2."VAT Amount" := -TransSalesEntry."VAT Amount";
                TransSalesEntry2."Discount Amount" := -TransSalesEntry."Discount Amount";
                TransSalesEntry2."Cost Amount" := -TransSalesEntry."Cost Amount";
                TransSalesEntry2."Periodic Discount" := -TransSalesEntry."Periodic Discount";
                TransSalesEntry2."Total Rounded Amt." := -TransSalesEntry."Total Rounded Amt.";
                TransSalesEntry2."Refund Qty." := 0;
                TransSalesEntry2.INSERT;
            UNTIL TransSalesEntry.NEXT = 0;

        CLEAR(TransPmtEntry);
        TransPmtEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransPmtEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransPmtEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF TransPmtEntry.FINDSET THEN
            REPEAT
                CLEAR(TransPmtEntry2);
                TransPmtEntry2 := TransPmtEntry;
                TransPmtEntry2."Receipt No." := TransHeader2."Receipt No.";
                TransPmtEntry2."Transaction No." := TransHeader2."Transaction No.";
                TransPmtEntry2."Amount Tendered" := -TransPmtEntry."Amount Tendered";
                TransPmtEntry2."Amount in Currency" := -TransPmtEntry."Amount in Currency";
                TransPmtEntry2.INSERT;
            UNTIL TransPmtEntry.NEXT = 0;

        CLEAR(TransDiscountEntry);
        TransDiscountEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransDiscountEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransDiscountEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF TransDiscountEntry.FINDSET THEN
            REPEAT
                CLEAR(TransDiscountEntry2);
                TransDiscountEntry2 := TransDiscountEntry;
                TransDiscountEntry2."Receipt No." := TransHeader2."Receipt No.";
                TransDiscountEntry2."Transaction No." := TransHeader2."Transaction No.";
                TransDiscountEntry2."Discount Amount" := -TransDiscountEntry."Discount Amount";
                TransDiscountEntry2.INSERT;
            UNTIL TransDiscountEntry.NEXT = 0;

        CLEAR(TransMixMatchEntry);
        TransMixMatchEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransMixMatchEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransMixMatchEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF TransMixMatchEntry.FINDSET THEN
            REPEAT
                CLEAR(TransMixMatchEntry2);
                TransMixMatchEntry2 := TransMixMatchEntry;
                TransMixMatchEntry2."Transaction No." := TransHeader2."Transaction No.";
                TransMixMatchEntry2."Discount Amount" := -TransMixMatchEntry."Discount Amount";
                TransMixMatchEntry2.Quantity := -TransMixMatchEntry.Quantity;
                TransMixMatchEntry2.INSERT;
            UNTIL TransMixMatchEntry.NEXT = 0;

        CLEAR(TransInfocodeEntry);
        TransInfocodeEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransInfocodeEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransInfocodeEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF TransInfocodeEntry.FINDSET THEN
            REPEAT
                CLEAR(TransInfocodeEntry2);
                TransInfocodeEntry2 := TransInfocodeEntry;
                TransInfocodeEntry2."Transaction No." := TransHeader2."Transaction No.";
                TransInfocodeEntry2."Discount Amount" := -TransInfocodeEntry."Discount Amount";
                TransInfocodeEntry2.Quantity := -TransInfocodeEntry.Quantity;
                TransInfocodeEntry2.INSERT;
            UNTIL TransInfocodeEntry.NEXT = 0;

        SalesHeader."Web Order Status" := SalesHeader."Web Order Status"::Reversed;
        SalesHeader.MODIFY;

    end;

    procedure GetRespCenter(LocCode: Code[10]): Code[20]
    var
        RespCenter: Record "Responsibility Center";
    begin
        RespCenter.SETRANGE("Location Code", LocCode);
        IF RespCenter.FINDFIRST THEN
            EXIT(RespCenter.Code);
    end;

    procedure TrimString(Input: Text[1024]): Text[1024]
    begin
        IF (Input = 'NULL') THEN
            EXIT('');
        IF STRLEN(Input) < 3 THEN
            EXIT('');
        EXIT(COPYSTR(Input, 2, STRLEN(Input) - 2));
    end;

    procedure CancelOrder(_SalesHeader: Record "Sales Header")
    begin
        IF (_SalesHeader."Web Order Status" > _SalesHeader."Web Order Status"::"Assigned for Picking") OR
          (_SalesHeader."Web Order Status" = _SalesHeader."Web Order Status"::" ") THEN
            _SalesHeader.FIELDERROR("Web Order Status");
        IF NOT (_SalesHeader."Web Order Payment Status" IN
          [_SalesHeader."Web Order Payment Status"::Pending, _SalesHeader."Web Order Payment Status"::Failed]) THEN
            _SalesHeader.FIELDERROR("Web Order Payment Status");

        IF CancelPayment(_SalesHeader) THEN BEGIN
            _SalesHeader.GET(_SalesHeader."Document Type", _SalesHeader."No.");
            _SalesHeader."Web Order Status" := _SalesHeader."Web Order Status"::Cancelled;
            _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Cancelled;
            _SalesHeader.MODIFY;
        END;
    end;

    procedure CompletePayment(_SalesHeader: Record "Sales Header"): Boolean
    var
        OK: Boolean;
        OrderAmount: Decimal;
        ErrorMessage: Text;
        PaymentMethod: Text[50];
        ResponseCode: Text;
        StatusMessage: Text;
        txtOrderAmount: Text[30];
        VivaResponseMessage: Text;

    begin
        IF NOT BatchProcess THEN
            IF (_SalesHeader."Web Order Status" < _SalesHeader."Web Order Status"::Picked) OR
              (_SalesHeader."Web Order Status" = _SalesHeader."Web Order Status"::Cancelled) THEN
                _SalesHeader.FIELDERROR("Web Order Status");

        IF NOT (_SalesHeader."Web Order Payment Status" IN
          [_SalesHeader."Web Order Payment Status"::Pending, _SalesHeader."Web Order Payment Status"::Failed]) THEN
            _SalesHeader.FIELDERROR("Web Order Payment Status");


        OrderAmount := GetOrderAmount(_SalesHeader);
        IF OrderAmount <= 0 THEN
            OrderAmount := AdjustOrderAmount(_SalesHeader);

        txtOrderAmount := FORMAT(ROUND(OrderAmount, 0.01) * 100, 0, '<Integer>');

        //CS NT 20220706 check if RCB or Viva. "Web Order Payment Method" was create later so check both of the following cases
        IF (_SalesHeader."Web Order Payment Session ID" <> '') THEN
            PaymentMethod := 'RCB'
        ELSE
            IF ((STRPOS(_SalesHeader."Web Order Payment Method", 'Viva') > 0) OR (_SalesHeader."Web Order Transaction Id" <> '')) THEN
                PaymentMethod := 'Viva';

        IF (PaymentMethod = 'RCB') THEN BEGIN
            _SalesHeader.TESTFIELD("Web Order Payment Order ID");
            _SalesHeader.TESTFIELD("Web Order Payment Session ID");
            SendRequest(_SalesHeader."Web Order Payment Order ID", _SalesHeader."Web Order Payment Session ID", txtOrderAmount, 'Completion',
                        StatusMessage, ResponseCode, ErrorMessage);
            OK := StatusMessage = '00';
            IF OK THEN BEGIN
                _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Completed;
                _SalesHeader."Actual Amount Charged" := ROUND(OrderAmount, 0.01);
            END ELSE
                _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Failed;
            _SalesHeader.MODIFY;
            InsertComment(_SalesHeader, STRSUBSTNO('Payment Status: %1', StatusMessage));
        END
        ELSE
            IF (PaymentMethod = 'Viva') THEN BEGIN
                SendRequestVivaWallet(_SalesHeader."Web Order Transaction Id", OrderAmount, 'Capture', 'Capture for Alphamega order ' + _SalesHeader."No.", VivaResponseMessage);
                IF (STRPOS(VivaResponseMessage, 'TransactionId:') > 0) THEN BEGIN
                    OK := TRUE;
                    //Save new transactionId      
                    _SalesHeader."Viva Capture Transaction Id" := DELSTR(VivaResponseMessage, 1, 14);//Delete 'TransactionId:' and leave the id only
                    _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Completed;
                    _SalesHeader."Actual Amount Charged" := ROUND(OrderAmount, 0.01);
                    _SalesHeader.MODIFY;
                    InsertComment(_SalesHeader, STRSUBSTNO('Payment Status: %1', 'Success'));
                END
                ELSE BEGIN
                    OK := FALSE;
                    _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Failed;
                    _SalesHeader.MODIFY;
                    InsertComment(_SalesHeader, STRSUBSTNO('Payment Status: %1', VivaResponseMessage));
                END;
            END;

        IF OK THEN
            Message2('Payment completed successfully')
        ELSE
            Message2('Error processing payment.');
        IF NOT OK AND (ErrorMessage <> '') THEN
            Message2(ErrorMessage);
        EXIT(OK);

    end;

    local procedure SendRequestVivaWallet(TransactionId: Text; OrderAmount: Decimal; Operation: Text; DescriptionForCustomer: Text; VAR ResponseMessage: Text)
    var
        GeneralSetup: Record "eCom_General Setup_NT";
        IsLiveEnvironment: Boolean;
        MerchantID: Text[50];
        Password: Text[50];
        SourceCode: Text[10];
    begin
        GeneralSetup.GET;
        IsLiveEnvironment := GeneralSetup."Viva Wallet Live Environment";
        MerchantID := GeneralSetup."Viva Wallet Merchant Id";//TEST NT: 43917d9c-7bb1-46a9-85c7-49945ec12ce8
        Password := GeneralSetup."Viva Wallet API Key";//TEST NT: 3.U)LX
        SourceCode := GeneralSetup."Viva Wallet Source Code";//'6912';
        IF (Operation = 'Capture') THEN BEGIN
            _VivaWallet.SetSecurityProtocol_3072();
            ResponseMessage := _VivaWallet.VivaCapturePreAuth(MerchantID, Password, TransactionId, OrderAmount, DescriptionForCustomer, SourceCode, IsLiveEnvironment);
        END
        ELSE
            IF (Operation = 'CancelPreAuth') THEN BEGIN
                _VivaWallet.SetSecurityProtocol_3072();
                ResponseMessage := _VivaWallet.VivaCancelPreAuth(MerchantID, Password, TransactionId, OrderAmount, DescriptionForCustomer, SourceCode, IsLiveEnvironment);
            END
            ELSE
                IF (Operation = 'Refund') THEN BEGIN
                    _VivaWallet.SetSecurityProtocol_3072();
                    ResponseMessage := _VivaWallet.VivaRefund(MerchantID, Password, TransactionId, OrderAmount, DescriptionForCustomer, SourceCode, IsLiveEnvironment);
                END;
    end;

    procedure CancelPaymentVivaWallet(_SalesHeader: Record "Sales Header"): Boolean
    var
        OK: Boolean;
        OrderAmount: Decimal;
        ResponseMessage: Text;
    begin
        IF _SalesHeader."Web Order Status" <> _SalesHeader."Web Order Status"::Cancelled THEN
            _SalesHeader.FIELDERROR("Web Order Status");
        IF NOT (_SalesHeader."Web Order Payment Status" IN
          [_SalesHeader."Web Order Payment Status"::Pending, _SalesHeader."Web Order Payment Status"::Failed]) THEN
            _SalesHeader.FIELDERROR("Web Order Payment Status");

        IF (_SalesHeader."Web Order Transaction Id" = '') THEN BEGIN
            ErrorMessage2('"Web Order Transaction Id" is empty');
            EXIT;
        END;

        IF (_SalesHeader."Web Order Transaction Amount" > 0) THEN
            OrderAmount := _SalesHeader."Web Order Transaction Amount" //CS NT Get amount that 
        ELSE BEGIN
            OrderAmount := GetOrderAmount(_SalesHeader);
            IF OrderAmount <= 0 THEN
                OrderAmount := AdjustOrderAmount(_SalesHeader);
        END;

        //Message2('Cancel ' + _SalesHeader."No." + ' with transaction Id ' + _SalesHeader."Web Order Transaction Id" + ' ' +FORMAT(OrderAmount));
        SendRequestVivaWallet(_SalesHeader."Web Order Transaction Id", OrderAmount, 'CancelPreAuth', 'Cancel Alphamega order ' + _SalesHeader."No.", ResponseMessage);//Before Capture

        IF (STRPOS(ResponseMessage, 'Successful') > 0) THEN BEGIN
            OK := TRUE;
            _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Cancelled;
            _SalesHeader.MODIFY;
            InsertComment(_SalesHeader, STRSUBSTNO('Cancel Payment Status: %1', ResponseMessage));
        END
        ELSE BEGIN
            OK := FALSE;
            InsertComment(_SalesHeader, STRSUBSTNO('Refund Payment Status: %1', ResponseMessage));
        END;

        Message2(ResponseMessage);

        EXIT(OK);

    end;

    procedure RefundPaymentVivaWallet(_SalesHeader: Record "Sales Header"): Boolean
    var
        OK: Boolean;
        Amt: Decimal;
        ResponseMessage: Text;
    begin
        _SalesHeader.TestField(Status, _SalesHeader.Status::Released);
        IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::Order THEN
            _SalesHeader.TESTFIELD("Web Order Status", _SalesHeader."Web Order Status"::Reversed);
        IF NOT (_SalesHeader."Web Order Payment Status" IN
          [_SalesHeader."Web Order Payment Status"::Pending, _SalesHeader."Web Order Payment Status"::Completed]) THEN
            _SalesHeader.FIELDERROR("Web Order Payment Status");

        IF (_SalesHeader."Viva Capture Transaction Id" = '') THEN BEGIN
            ErrorMessage2('"Viva Capture Transaction Id" is empty');
            EXIT;
        END;

        Amt := GetOrderAmount(_SalesHeader);

        IF NOT Confirm2(STRSUBSTNO('The Amount of %1 will be refunded. Continue?', Amt)) THEN
            EXIT;
        //OrderAmount := FORMAT(Amt);
        SendRequestVivaWallet(_SalesHeader."Viva Capture Transaction Id", Amt, 'Refund', FORMAT(Amt) + ' refund for Alphamega order ' + _SalesHeader."No.", ResponseMessage);//After capture

        IF (STRPOS(ResponseMessage, 'Successful') > 0) THEN BEGIN
            OK := TRUE;
            _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Refunded;
            _SalesHeader.MODIFY;
            InsertComment(_SalesHeader, STRSUBSTNO('Refund Payment Status: %1', ResponseMessage));
        END
        ELSE BEGIN
            OK := FALSE;
            InsertComment(_SalesHeader, STRSUBSTNO('Refund Payment Status: %1', ResponseMessage));
        END;

        Message2(ResponseMessage);

        EXIT(OK);

    end;

    procedure CancelOrderVivaWallet(_SalesHeader: Record "Sales Header")
    begin
        //CS NT TEST
        //MESSAGE(SendCancellationEmail('christos@nextech.com.cy',_SalesHeader."Sell-to Customer Name",_SalesHeader."No."));
        //EXIT;
        //..CS NT TEST        

        IF (_SalesHeader."Web Order Status" <> _SalesHeader."Web Order Status"::Cancelled) OR
          (_SalesHeader."Web Order Status" = _SalesHeader."Web Order Status"::" ") THEN
            _SalesHeader.TESTFIELD("Web Order Status", _SalesHeader."Web Order Status"::Cancelled);
        IF NOT (_SalesHeader."Web Order Payment Status" IN
          [_SalesHeader."Web Order Payment Status"::Pending, _SalesHeader."Web Order Payment Status"::Failed]) THEN
            _SalesHeader.FIELDERROR("Web Order Payment Status");

        IF CancelPaymentVivaWallet(_SalesHeader) THEN BEGIN
            _SalesHeader.GET(_SalesHeader."Document Type", _SalesHeader."No.");
            _SalesHeader."Web Order Status" := _SalesHeader."Web Order Status"::Cancelled;
            _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Cancelled;
            _SalesHeader.MODIFY;
            SendCancellationEmail(_SalesHeader."E-Mail", _SalesHeader."Sell-to Customer Name", _SalesHeader."No.");
        END;
    end;

    procedure SendCancellationEmail(Email: Text; CustName: Text; OrderId: Text[20]): Text
    var
        EmailMsg: Codeunit "Email Message";
        EmailSend: Codeunit Email;
        ResultOk: Boolean;
    begin
        /*
        CLEAR(SMTPMail);
        SMTPMail.CreateMessage('Alphamega Hypermarkets', 'noreply@alphamega.com.cy', Email, 'Your Order has been cancelled', '', TRUE);

        SMTPMail.AppendBody(STRSUBSTNO('<html><body><p>Dear %1,</p>' +
            '<p></p>' +
            '<p>The order <strong>%2</strong> has been cancelled. You will be refunded within 3-5 business days or based on your bank&apos;s policy. </p>' +
            '<p></p>' +
            '<p>If this cancellation was accidental, please immediately contact us on <a href = "mailto: wedeliver@alphamega.com.cy">wedeliver@alphamega.com.cy</a>.</p>' +
            '<p></p>' +
            '<p>This is a no-reply email and cannot accept any replies.</p>' +
            '<p></p>' +
            '<p>Best regards,</br>Alphamega Hypermarkets</p>' +
            '</body></html>', CustName, OrderId));


        IF SMTPMail.TrySend() THEN
            EXIT('Cancellation email sent.');
        EXIT(SMTPMail.GetLastSendMailErrorText());
*/

        EmailMsg.Create(Email, 'Your Order has been cancelled', '', TRUE);
        EmailMsg.AppendToBody(STRSUBSTNO('<html><body><p>Dear %1,</p>' +
            '<p></p>' +
            '<p>The order <strong>%2</strong> has been cancelled. You will be refunded within 3-5 business days or based on your bank&apos;s policy. </p>' +
            '<p></p>' +
            '<p>If this cancellation was accidental, please immediately contact us on <a href = "mailto: wedeliver@alphamega.com.cy">wedeliver@alphamega.com.cy</a>.</p>' +
            '<p></p>' +
            '<p>This is a no-reply email and cannot accept any replies.</p>' +
            '<p></p>' +
            '<p>Best regards,</br>Alphamega Hypermarkets</p>' +
            '</body></html>', CustName, OrderId));
        ResultOk := EmailSend.Send(EmailMsg);
        if not ResultOk then
            exit(GetLastErrorText());
    end;

    procedure CancelPayment(_SalesHeader: Record "Sales Header"): Boolean
    var
        OK: Boolean;
        ErrorMessage: Text;
        ResponseCode: Text;
        StatusMessage: Text;
    begin
        IF _SalesHeader."Web Order Status" > _SalesHeader."Web Order Status"::"Assigned for Picking" THEN
            _SalesHeader.FIELDERROR("Web Order Status");
        IF NOT (_SalesHeader."Web Order Payment Status" IN
          [_SalesHeader."Web Order Payment Status"::Pending, _SalesHeader."Web Order Payment Status"::Failed]) THEN
            _SalesHeader.FIELDERROR("Web Order Payment Status");

        _SalesHeader.TESTFIELD("Web Order Payment Order ID");
        _SalesHeader.TESTFIELD("Web Order Payment Session ID");

        SendRequest(_SalesHeader."Web Order Payment Order ID", _SalesHeader."Web Order Payment Session ID", '', 'Reverse',
                      StatusMessage, ResponseCode, ErrorMessage);

        OK := StatusMessage = '00';
        IF OK THEN BEGIN
            _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Cancelled;
            _SalesHeader.MODIFY;
        END;
        InsertComment(_SalesHeader, STRSUBSTNO('Cancel Payment Status: %1', StatusMessage));
        IF OK THEN
            Message2('Payment cancelled successfully')
        ELSE
            Message2('Error processing request.');
        IF NOT OK AND (ErrorMessage <> '') THEN
            Message2(ErrorMessage);
        EXIT(OK);
    end;

    procedure RefundPayment(_SalesHeader: Record "Sales Header"): Boolean
    var
        OK: Boolean;
        Amt: Decimal;
        ErrorMessage: Text;
        OrderAmount: Text[30];
        ResponseCode: Text;
        StatusMessage: Text;
    begin
        IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::Order THEN
            _SalesHeader.TESTFIELD("Web Order Status", _SalesHeader."Web Order Status"::Reversed);
        IF NOT (_SalesHeader."Web Order Payment Status" IN
          [_SalesHeader."Web Order Payment Status"::Pending, _SalesHeader."Web Order Payment Status"::Completed]) THEN
            _SalesHeader.FIELDERROR("Web Order Payment Status");
        _SalesHeader.TESTFIELD("Web Order Payment Order ID");
        _SalesHeader.TESTFIELD("Web Order Payment Session ID");
        //_SalesHeader.TESTFIELD("Actual Amount Charged");
        //IF _SalesHeader."Actual Amount Charged" = 0 THEN
        Amt := GetOrderAmount(_SalesHeader);
        //ELSE
        //  Amt := _SalesHeader."Actual Amount Charged";
        IF NOT Confirm2(STRSUBSTNO('The Amount of %1 will be refunded. Continue?', Amt)) THEN
            EXIT;
        OrderAmount := FORMAT(Amt * 100, 0, '<Integer>');
        SendRequest(_SalesHeader."Web Order Payment Order ID", _SalesHeader."Web Order Payment Session ID", OrderAmount, 'Refund',
                      StatusMessage, ResponseCode, ErrorMessage);

        OK := StatusMessage = '00';
        IF OK THEN BEGIN
            _SalesHeader."Refund Date" := TODAY;
            _SalesHeader."Web Order Payment Status" := _SalesHeader."Web Order Payment Status"::Refunded;
            _SalesHeader.MODIFY;
        END;
        InsertComment(_SalesHeader, STRSUBSTNO('Refund Payment Status: %1', StatusMessage));
        IF OK THEN
            Message2('Payment refunded successfully')
        ELSE
            Message2('Error processing request.');
        IF NOT OK AND (ErrorMessage <> '') THEN
            Message2(ErrorMessage);
        EXIT(OK);

    end;

    LOCAL procedure SendRequest(OrderID: Text; SessionID: Text; OrderAmount: Text; Operation: Text; VAR StatusMessage: Text; VAR ResponseCode: Text; VAR ErrorMessage: Text)
    var
        TimeOut: Integer;
        ContentType: Text;
        CurrencyCode: Text;
        LanguageCode: Text;
        MerchantID: Text;
        URL: Text;
        String: TextBuilder;
    begin

        //URL := 'https://mpi.rcbcy.com:9774/Exec';
        URL := 'https://mpids2.rcbcy.com:9774/ExecPasswordAuth';
        MerchantID := 'E0228196';
        TimeOut := 0;
        ContentType := 'text/plain';
        LanguageCode := 'EN';
        IF OrderAmount <> '' THEN
            CurrencyCode := '978'
        ELSE
            CurrencyCode := '';

        _RCB := _RCB.RCB();
        _RCB.SetRestRequest(URL, TimeOut, ContentType, 'E0228196', '33kRHk77F');
        _RCB.AddtoRequest('<?xml version="1.0" encoding="UTF-8"?>');
        _RCB.AddtoRequest('<TKKPG>');
        _RCB.AddtoRequest('<Request>');
        //_RCB.AddtoRequest(String.Format('<Operation>{0}</Operation>', Operation));
        _RCB.AddtoRequest(StrSubstNo('<Operation>%1</Operation>', Operation));

        // _RCB.AddtoRequest(String.Format('<Language>{0}</Language>', LanguageCode));
        _RCB.AddtoRequest(StrSubstNo('<Language>%1</Language>', LanguageCode));

        _RCB.AddtoRequest('<Order>');
        //_RCB.AddtoRequest(String.Format('<Merchant>{0}</Merchant>', MerchantID));
        _RCB.AddtoRequest(StrSubstNo('<Merchant>%1</Merchant>', MerchantID));
        //_RCB.AddtoRequest(String.Format('<OrderID>{0}</OrderID>', OrderID));
        _RCB.AddtoRequest(StrSubstNo('<OrderID>%1</OrderID>', OrderID));
        _RCB.AddtoRequest('</Order>');
        //_RCB.AddtoRequest(String.Format('<SessionID>{0}</SessionID>', SessionID));
        _RCB.AddtoRequest(StrSubstNo('<SessionID>%1</SessionID>', SessionID));
        IF (OrderAmount <> '') AND (CurrencyCode <> '') THEN BEGIN
            IF (Operation = 'Refund') THEN
                _RCB.AddtoRequest('<Refund>');
            //_RCB.AddtoRequest(String.Format('<Amount>{0}</Amount>', OrderAmount));
            _RCB.AddtoRequest(StrSubstNo('<Amount>%1</Amount>', OrderAmount));
            //_RCB.AddtoRequest(String.Format('<Currency>{0}</Currency>', CurrencyCode));
            _RCB.AddtoRequest(StrSubstNo('<Currency>%1</Currency>', CurrencyCode));
            IF (Operation = 'Refund') THEN
                _RCB.AddtoRequest('</Refund>');
        END;
        _RCB.AddtoRequest('<EncryptedPayload></EncryptedPayload></Request></TKKPG>');
        _RCB.DoRequest();
        _RCB.ParseResponse();
        StatusMessage := _RCB.StatusMessage();
        ResponseCode := _RCB.ResponseCode();
        ErrorMessage := _RCB.ErrorMessage();

    end;

    local procedure InsertComment(_SalesHeader: Record "Sales Header"; Comment: Text[1024])
    var
        SalesCommentLine: Record "Sales Comment Line";
        NextLineNo: Integer;
    begin
        CLEAR(SalesCommentLine);
        SalesCommentLine.SETRANGE("Document Type", _SalesHeader."Document Type");
        SalesCommentLine.SETRANGE("No.", _SalesHeader."No.");
        SalesCommentLine.SETRANGE("Document Line No.", 0);
        IF SalesCommentLine.FINDLAST THEN
            NextLineNo := SalesCommentLine."Line No.";

        NextLineNo += 10000;
        CLEAR(SalesCommentLine);
        SalesCommentLine."Document Type" := _SalesHeader."Document Type";
        SalesCommentLine."No." := _SalesHeader."No.";
        SalesCommentLine."Document Line No." := 0;
        SalesCommentLine."Line No." := NextLineNo;
        SalesCommentLine.Date := TODAY;
        SalesCommentLine.Comment := COPYSTR(Comment, 1, MAXSTRLEN(SalesCommentLine.Comment));
        SalesCommentLine.INSERT;

    end;

    LOCAL procedure ErrorMessage2(ErrorText: Text)
    begin
        IF GuiAllowed2 THEN
            ERROR(ErrorText);
    end;

    LOCAL procedure Message2(MessageText: Text)
    begin
        IF GuiAllowed2 THEN
            MESSAGE(MessageText);
    end;

    LOCAL procedure Confirm2(ConfirmText: Text): Boolean
    begin
        IF NOT GuiAllowed2 THEN
            EXIT(TRUE);
        EXIT(CONFIRM(ConfirmText));
    end;

    LOCAL procedure GuiAllowed2(): Boolean
    begin
        IF NOT GUIALLOWED THEN
            EXIT(FALSE);
        EXIT(NOT BatchProcess);
    end;

    procedure SetBatchProcess()
    begin
        BatchProcess := TRUE;
    end;

    procedure GetVatCode(VAT: Decimal): Code[10]
    var
        POSVAT: Record "LSC POS VAT Code";
    begin
        POSVAT.SETRANGE("VAT %", VAT);
        POSVAT.FINDFIRST;
        EXIT(POSVAT."VAT Code");
    end;


    procedure FindActiveOfferInStore(VAR rboPriceUtil: Codeunit "LSC Retail Price Utils"; TransHeader: Record "LSC Transaction Header"; TransSalesEntry: Record "LSC Trans. Sales Entry"; MembershipCard: Record "LSC Membership Card"; StoreSetup: Record "LSC Store"; Item: Record Item; VAR pPointOfferLine: Record "LSC Member Point Offer Line"): Boolean
    var
        ItemSpecialGroup: Record "LSC Item/Special Group Link";
        PointOffer: Record "LSC Member Point Offer";
        PointOfferLines: Record "LSC Member Point Offer Line";
        TmpPointOffer: Record "LSC Member Point Offer" temporary;
        TmpPointOfferLine: Record "LSC Member Point Offer Line" temporary;
        FiltersOk: Boolean;
        found: Boolean;
        OkPeriod: Boolean;
    begin
        TmpPointOffer.DELETEALL;
        TmpPointOfferLine.DELETEALL;

        //StoreSetup.GET(TransSalesEntry."Store No.");
        //Item.GET(TransSalesEntry."Item No.");
        //TransHeader.GET(TransSalesEntry."Store No.",TransSalesEntry."POS Terminal No.",TransSalesEntry."Transaction No.");

        PointOffer.SETCURRENTKEY(Status);
        PointOffer.SETRANGE(Status, PointOffer.Status::Enabled);
        PointOffer.SETFILTER("Currency Code", '%1|%2', StoreSetup."Currency Code", '');

        IF TransSalesEntry."Unit of Measure" = '' THEN
            TransSalesEntry."Unit of Measure" := Item."Sales Unit of Measure";

        PointOfferLines.SETFILTER("Unit of Measure", '%1|%2', TransSalesEntry."Unit of Measure", '');
        IF TransSalesEntry."Variant Code" <> '' THEN
            PointOfferLines.SETFILTER("Variant Code", '%1|%2', TransSalesEntry."Variant Code", '')
        ELSE
            PointOfferLines.SETRANGE("Variant Code", '');

        IF PointOffer.FINDSET THEN
            REPEAT
                FiltersOk := FALSE;
                //IF ((PointOffer."Customer Disc. Group" = '') OR (PointOffer."Customer Disc. Group" = TransHeader."Customer Disc. Group")) BC Upgrade
                IF ((PointOffer."Customer Discount Group" = '') OR (PointOffer."Customer Discount Group" = TransHeader."Customer Disc. Group"))//BC Upgrade
                  AND rboPriceUtil.MemberFilterPassed(PointOffer."Member Type", PointOffer."Member Value")                  
                  AND rboPriceUtil.MemberAttrFilterPassed(PointOffer."Member Attribute", PointOffer."Member Attribute Value")
                THEN BEGIN
                    IF PointOffer."Validation Period ID" = '' THEN
                        OkPeriod := TRUE
                    ELSE
                        OkPeriod := rboPriceUtil.DiscValPerValid(PointOffer."Validation Period ID", TransHeader.Date, TransHeader.Time);

                    IF rboPriceUtil.PointOfferFiltersPassed(
                         PointOffer, StoreSetup."No.", TransSalesEntry."Sales Type", TransSalesEntry."Price Group Code") AND OkPeriod THEN
                        FiltersOk := TRUE
                    ELSE
                        FiltersOk := FALSE;
                END;

                IF FiltersOk THEN BEGIN
                    found := FALSE;
                    PointOfferLines.SETRANGE("Offer No.", PointOffer."No.");
                    PointOfferLines.SETRANGE(Type, PointOfferLines.Type::Item);
                    PointOfferLines.SETRANGE("No.", Item."No.");
                    IF PointOfferLines.FINDLAST THEN BEGIN
                        found := TRUE;
                        TmpPointOfferLine := PointOfferLines;
                    END;

                    IF NOT found THEN BEGIN
                        PointOfferLines.SETRANGE(Type, PointOfferLines.Type::"Product Group");
                        //PointOfferLines.SETRANGE("No.", Item."Product Group Code"); BC Upgrade
                        PointOfferLines.SETRANGE("No.", Item."LSC Retail Product Code");//BC Upgrade
                        PointOfferLines.SETRANGE("Prod. Group Category", Item."Item Category Code");
                        IF PointOfferLines.FIND('-') THEN BEGIN
                            found := TRUE;
                            TmpPointOfferLine := PointOfferLines;
                        END;
                        PointOfferLines.SETRANGE("Prod. Group Category");
                    END;

                    IF NOT found THEN BEGIN
                        PointOfferLines.SETRANGE(Type, PointOfferLines.Type::"Item Category");
                        PointOfferLines.SETRANGE("No.", Item."Item Category Code");
                        IF PointOfferLines.FIND('-') THEN BEGIN
                            found := TRUE;
                            TmpPointOfferLine := PointOfferLines;
                        END;
                    END;

                    IF NOT found THEN BEGIN
                        PointOfferLines.SETRANGE(Type, PointOfferLines.Type::"Item Category");
                        PointOfferLines.SETRANGE("No.", Item."Item Category Code");
                        IF PointOfferLines.FIND('-') THEN BEGIN
                            found := TRUE;
                            TmpPointOfferLine := PointOfferLines;
                        END;
                    END;

                    IF NOT found THEN BEGIN
                        PointOfferLines.SETRANGE(Type, PointOfferLines.Type::All);
                        PointOfferLines.SETRANGE("No.");
                        IF PointOfferLines.FIND('-') THEN BEGIN
                            found := TRUE;
                            TmpPointOfferLine := PointOfferLines;
                        END;
                    END;

                    IF NOT found THEN BEGIN
                        PointOfferLines.SETRANGE(Type, PointOfferLines.Type::"Special Group");
                        PointOfferLines.SETRANGE("No.");
                        PointOfferLines.SETRANGE(Exclude, TRUE);
                        IF PointOfferLines.FINDSET THEN
                            REPEAT
                                IF ItemSpecialGroup.GET(TransSalesEntry."Item No.", PointOfferLines."No.") THEN BEGIN
                                    found := TRUE;
                                    TmpPointOfferLine := PointOfferLines;
                                END;
                            UNTIL (PointOfferLines.NEXT = 0) OR found;
                    END;

                    IF NOT found THEN BEGIN
                        PointOfferLines.SETRANGE(Type, PointOfferLines.Type::"Special Group");
                        PointOfferLines.SETRANGE("No.");
                        PointOfferLines.SETRANGE(Exclude, FALSE);
                        IF PointOfferLines.FINDSET THEN
                            REPEAT
                                IF ItemSpecialGroup.GET(TransSalesEntry."Item No.", PointOfferLines."No.") THEN BEGIN
                                    found := TRUE;
                                    TmpPointOfferLine := PointOfferLines;
                                END;
                            UNTIL (PointOfferLines.NEXT = 0) OR found;
                    END;

                    IF found AND (NOT TmpPointOfferLine.Exclude) THEN BEGIN
                        TmpPointOffer := PointOffer;
                        TmpPointOffer.INSERT;
                        TmpPointOfferLine.INSERT;
                    END
                END;
            UNTIL PointOffer.NEXT = 0;

        CLEAR(pPointOfferLine);
        TmpPointOffer.SETCURRENTKEY(Priority);
        IF TmpPointOffer.FINDFIRST THEN BEGIN
            TmpPointOfferLine.SETRANGE("Offer No.", TmpPointOffer."No.");
            TmpPointOfferLine.FINDFIRST;
            pPointOfferLine := PointOfferLines;
            EXIT(TRUE);
        END;

        EXIT(FALSE);
    end;

    procedure ReturnAllLines(SalesHeader: Record "Sales Header")
    var
        LineRec: Record "Sales Line";
        ReturnReasonRec: Record "Return Reason";
        ReturnReasonList: Page "Return Reasons";
    begin
        SalesHeader.TESTFIELD(Status, SalesHeader.Status::Open);
        ReturnReasonRec.RESET;
        CLEAR(ReturnReasonList);
        ReturnReasonList.LOOKUPMODE(TRUE);
        ReturnReasonList.SETRECORD(ReturnReasonRec);
        IF ReturnReasonList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            ReturnReasonList.GETRECORD(ReturnReasonRec);
            //MESSAGE(ReturnReasonRec.Code);
            //ReturnReasonRec.TESTFIELD("Location Code");
            //VALIDATE("Store No.",LocationRec."No.");
            //MODIFY(TRUE);
            CLEAR(LineRec);
            LineRec.RESET;
            LineRec.SETRANGE("Document Type", SalesHeader."Document Type");
            LineRec.SETRANGE("Document No.", SalesHeader."No.");
            LineRec.SETFILTER("No.", '<>%1', '');
            IF LineRec.FINDFIRST THEN
                REPEAT
                    IF LineRec.Quantity <> 0 THEN BEGIN
                        LineRec.VALIDATE(LineRec."Return Reason Code", ReturnReasonRec.Code);
                        LineRec.VALIDATE(LineRec."Return Qty. to Receive", LineRec.Quantity);
                        LineRec.MODIFY(TRUE);
                    END;
                UNTIL LineRec.NEXT = 0;
            MESSAGE('Lines Updated!');
        END
        ELSE
            MESSAGE('You must click OK');

    end;

    var
        BatchProcess: Boolean;
        _RCB: DotNet eComRCB;
        _VivaWallet: DotNet eComVivaWallet;
}