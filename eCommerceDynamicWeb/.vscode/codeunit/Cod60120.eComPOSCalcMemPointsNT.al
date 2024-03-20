codeunit 60120 "eCom_POS Calc. Mem. Points_NT"
{
    //copy of "LSC POS Calc. Member Points"

    var
        MembershipCardTemp_g: Record "LSC Membership Card" temporary;
        MemberAttributeListTemp_g: Record "LSC Member Attribute List" temporary;
        rboPriceUtil: Codeunit "LSC Retail Price Utils";
        MemberPostingUtils: Codeunit "LSC Member Posting Utils";

    procedure UpdateMemberFromPOS(TransactionHeader: Record "LSC Transaction Header")
    var
        MemberAccountTemp_g: Record "LSC Member Account" temporary;
        MemberClubTemp_g: Record "LSC Member Club" temporary;
        MemberSchemeTemp_g: Record "LSC Member Scheme" temporary;
        MemberMgtSetupTemp_l: Record "LSC Member Management Setup" temporary;
        MemberPointSetupTemp_l: Record "LSC Member Point Setup" temporary;
        TransSalesLine: Record "LSC Trans. Sales Entry";
        OrigTransSalesLine: Record "LSC Trans. Sales Entry";
        TransPaymentLine: Record "LSC Trans. Payment Entry";
        TransDiscLine: Record "LSC Trans. Discount Entry";
        TransPointEntry: Record "LSC Trans. Point Entry";
        ProcessOrderEntry: Record "LSC Member Process Order Entry";
        StoreSetup: Record "LSC Store";
        PosFunctions: Codeunit "LSC POS Functions";
        POSCalcMemberPointsPublic: Codeunit "LSC POSCalcMemberPointsPublic";
        ActivePriceGroup_l: Code[10];
        ProcessCode: Code[30];
        AwardPoints: Decimal;
        OtherPoints: Decimal;
        CurrPoints: Decimal;
        DiscBenifitPoints: Decimal;
        AmountBase: Decimal;
        TenderAwardPoints_l: Decimal;
        TenderOtherPoints_l: Decimal;
        ErrorText: Text;
        PaymentWithPoints: Boolean;
    begin
        if TransactionHeader."Entry Status" <> TransactionHeader."Entry Status"::" " then
            exit;
        if TransactionHeader."Member Card No." = '' then
            exit;
        if not PosFunctions.GetMemberInfoForPos(TransactionHeader."Member Card No.", ProcessCode, ErrorText) then
            exit;
        PosFunctions.GetMemberShipCardInfo(MembershipCardTemp_g);
        PosFunctions.GetMemberAccountInfo(MemberAccountTemp_g);
        PosFunctions.GetMemberAttributeList(MemberAttributeListTemp_g);
        PosFunctions.GetMemberClubInfo(MemberClubTemp_g);
        PosFunctions.GetMemberSchemeInfo(MemberSchemeTemp_g);

        ActivePriceGroup_l := GetActivePriceGroup(MemberAccountTemp_g."Price Group", MemberSchemeTemp_g."Default Price Group", MemberClubTemp_g."Default Price Group");

        PosFunctions.GetMemberMgtSetupInfo(MemberMgtSetupTemp_l);
        PosFunctions.GetMemberPointSetupInfo(MemberPointSetupTemp_l);

        rboPriceUtil.SetMemberInfo(MembershipCardTemp_g, MemberAttributeListTemp_g);

        //insert information on payment with points.
        PaymentWithPoints := false;
        TransPaymentLine.SetRange("Store No.", TransactionHeader."Store No.");
        TransPaymentLine.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransPaymentLine.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        TransPaymentLine.SetRange("Tender Type", MemberClubTemp_g."Member Point Tender Type");
        if TransPaymentLine.FindSet then
            repeat
                TransPointEntry.Init;
                TransPointEntry."Store No." := TransactionHeader."Store No.";
                TransPointEntry."POS Terminal No." := TransactionHeader."POS Terminal No.";
                TransPointEntry."Transaction No." := TransactionHeader."Transaction No.";
                TransPointEntry."Receipt No." := TransactionHeader."Receipt No.";
                TransPointEntry."Entry Type" := TransPointEntry."Entry Type"::Payment;
                TransPointEntry."Point Type" := TransPointEntry."Point Type"::Award;
                TransPointEntry.Points := -TransPaymentLine."Amount in Currency";
                TransPointEntry.Date := TransPaymentLine.Date;
                TransPointEntry."Card No." := TransactionHeader."Member Card No.";
                TransPointEntry."Value Per Point" := MemberClubTemp_g."Point Value";
                TransPointEntry.Insert(true);
                PaymentWithPoints := true;
            until TransPaymentLine.Next = 0;

        //Now look at the transaction and calculate earned points and benefits.

        //Check if the total Transaction meets the minimum Transaction Amount limit for Point calculation.
        if Abs(TransTenderAmount(TransactionHeader)) < MemberClubTemp_g."Min. Trans.Amt for Point Calc." then begin
            if PaymentWithPoints then
                CreateProcessOrderEntry(TransactionHeader, MemberAccountTemp_g."No.", ProcessOrderEntry);
            exit;
        end;

        if not TransactionHeader."Sale Is Return Sale" then begin
            //Points as Discount Benefits
            DiscBenifitPoints := GetPointsDiscountBenefits(TransactionHeader);

            //Points as Discount
            PointsDiscount(TransactionHeader, MemberClubTemp_g."Point Value", TransPaymentLine.Date);

            //points pr. Item purchased
            PointsItemPurchased(TransactionHeader, MemberMgtSetupTemp_l, MemberPointSetupTemp_l, MemberClubTemp_g, MembershipCardTemp_g, ActivePriceGroup_l, AwardPoints, OtherPoints);
        end
        else begin
            //Sale is Return Sale
            TransSalesLine.SetRange("Store No.", TransactionHeader."Store No.");
            TransSalesLine.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
            TransSalesLine.SetRange("Transaction No.", TransactionHeader."Transaction No.");
            if TransSalesLine.FindSet then
                repeat
                    CurrPoints := 0;
                    if OrigTransSalesLine.Get(TransSalesLine."Orig Trans Store", TransSalesLine."Orig Trans Pos",
                      TransSalesLine."Orig Trans No.", TransSalesLine."Orig Trans Line No.")
                    then
                        if (OrigTransSalesLine."Member Points" <> 0) and (OrigTransSalesLine.Quantity <> 0) then
                            if MemberClubTemp_g."Point Rounding Precision" > 0 then
                                CurrPoints := MemberPostingUtils.RoundPoints(OrigTransSalesLine."Member Points" * TransSalesLine.Quantity / OrigTransSalesLine.Quantity, MemberClubTemp_g)
                            else
                                CurrPoints := OrigTransSalesLine."Member Points" * TransSalesLine.Quantity / OrigTransSalesLine.Quantity
                        else
                            CurrPoints := 0
                    else begin
                        //Refund
                        CurrPoints := 0;
                        if not TransSalesLine."Offer Blocked Points" then begin
                            StoreSetup.Get(TransSalesLine."Store No.");
                            if CalcPoints(StoreSetup."Currency Code", TransSalesLine.Date, TransSalesLine."Item Category Code", TransSalesLine."Retail Product Code", TransSalesLine."Item No.", MembershipCardTemp_g, ActivePriceGroup_l, MemberPointSetupTemp_l) then begin
                                if MemberMgtSetupTemp_l."Amount Type for Point Calc." = MemberMgtSetupTemp_l."Amount Type for Point Calc."::"Gross Amount" then
                                    AmountBase := TransSalesLine."Net Amount" + TransSalesLine."VAT Amount"
                                else
                                    AmountBase := TransSalesLine."Net Amount";
                                
                                if MemberPointSetupTemp_l."Base Calculation on" = MemberPointSetupTemp_l."Base Calculation on"::Amount then
                                    CurrPoints := -Round(AmountBase * MemberPointSetupTemp_l.Points / MemberPointSetupTemp_l."Unit Rate", 0.01)
                                else
                                    CurrPoints := -Round(TransSalesLine.Quantity * MemberPointSetupTemp_l.Points / MemberPointSetupTemp_l."Unit Rate", 0.01);
                            end;
                        end;
                    end;
                    if CurrPoints <> 0 then begin
                        if OrigTransSalesLine."Member Points Type" = OrigTransSalesLine."Member Points Type"::"Award Points" then begin
                            AwardPoints := AwardPoints + CurrPoints;
                            TransSalesLine."Member Points Type" := TransSalesLine."Member Points Type"::"Award Points";
                            TransSalesLine."Member Points" := CurrPoints;
                        end
                        else begin
                            OtherPoints := OtherPoints + CurrPoints;
                            TransSalesLine."Member Points Type" := TransSalesLine."Member Points Type"::"Other Points";
                            TransSalesLine."Member Points" := CurrPoints;
                        end;
                        //TransSalesLine.MODIFY;
                        TransSalesLine.Modify(true);
                    end;

                    TransDiscLine.Reset;
                    TransDiscLine.SetRange("Store No.", OrigTransSalesLine."Store No.");
                    TransDiscLine.SetRange("POS Terminal No.", OrigTransSalesLine."POS Terminal No.");
                    TransDiscLine.SetRange("Transaction No.", OrigTransSalesLine."Transaction No.");
                    TransDiscLine.SetRange("Line No.", OrigTransSalesLine."Line No.");
                    TransDiscLine.SetRange("Offer Type", TransDiscLine."Offer Type"::"Item Point");
                    if TransDiscLine.FindFirst then begin
                        if not TransPointEntry.Get(TransactionHeader."Store No.", TransactionHeader."POS Terminal No.",
                          TransactionHeader."Transaction No.", TransactionHeader."Receipt No.", TransPointEntry."Entry Type"::Payment,
                          TransPointEntry."Point Type"::Award)
                        then begin
                            TransPointEntry.Init;
                            TransPointEntry."Store No." := TransactionHeader."Store No.";
                            TransPointEntry."POS Terminal No." := TransactionHeader."POS Terminal No.";
                            TransPointEntry."Transaction No." := TransactionHeader."Transaction No.";
                            TransPointEntry."Receipt No." := TransactionHeader."Receipt No.";
                            TransPointEntry."Entry Type" := TransPointEntry."Entry Type"::Payment;
                            TransPointEntry."Point Type" := TransPointEntry."Point Type"::Award;
                            TransPointEntry.Date := TransPaymentLine.Date;
                            TransPointEntry."Card No." := TransactionHeader."Member Card No.";
                            TransPointEntry."Value Per Point" := MemberClubTemp_g."Point Value";
                            TransPointEntry.Insert(true);
                        end;
                        TransPointEntry.Points := TransPointEntry.Points - TransDiscLine.Points;
                        TransPointEntry.Modify(true);
                    end;
                until TransSalesLine.Next = 0;
        end;

        PointsTender(TransactionHeader, MembershipCardTemp_g, MemberClubTemp_g, MemberPointSetupTemp_l, ActivePriceGroup_l, AwardPoints, OtherPoints, TenderAwardPoints_l, TenderOtherPoints_l);

        if (AwardPoints <> 0) or (DiscBenifitPoints <> 0) then
            InsertTransPointEntry(TransactionHeader, MemberClubTemp_g, DiscBenifitPoints, MemberClubTemp_g."Disc. Benefit Point Type"::"Award Points", TransPointEntry."Point Type"::Award, AwardPoints, TenderAwardPoints_l);

        if (OtherPoints <> 0) or (DiscBenifitPoints <> 0) then
            InsertTransPointEntry(TransactionHeader, MemberClubTemp_g, DiscBenifitPoints, MemberClubTemp_g."Disc. Benefit Point Type"::"Other Points", TransPointEntry."Point Type"::Other, OtherPoints, TenderOtherPoints_l);

        CreateProcessOrderEntry(TransactionHeader, MemberAccountTemp_g."No.", ProcessOrderEntry);
    end;

    procedure CalcPoints(CurrencyCode_p: Code[10]; Date_p: Date; ItemCategory_p: Code[20]; ProductGroup_p: Code[20]; ItemNo_p: Code[20]; MemberCardTemp_p: Record "LSC Membership Card" temporary; ActivePriceGroup_p: Code[10]; var PointSetupTemp_p: Record "LSC Member Point Setup" temporary): Boolean
    var
        SpecialGroupLink: Record "LSC Item/Special Group Link";
        PointSetupMax: Record "LSC Member Point Setup";
        POSCalcMemberPointsPublic: Codeunit "LSC POSCalcMemberPointsPublic";
        CustFilterType: Integer;
    begin        
        PointSetupTemp_p.Reset;
        Clear(PointSetupTemp_p);
        PointSetupTemp_p.SetCurrentKey("Customer Filter Type", "Customer Filter Code");
        PointSetupTemp_p.SetFilter("Starting Date", '<=%1', Date_p);
        PointSetupTemp_p.SetFilter("Ending Date", '>=%1|%2', Date_p, 0D);
        PointSetupTemp_p.SetFilter("Currency Code", '%1|%2', CurrencyCode_p, '');

        for CustFilterType := PointSetupTemp_p."Customer Filter Type"::Account downto PointSetupTemp_p."Customer Filter Type"::All do begin
            case CustFilterType of
                2:
                    begin
                        PointSetupTemp_p.SetRange("Customer Filter Type", PointSetupTemp_p."Customer Filter Type"::Account);
                        PointSetupTemp_p.SetRange("Customer Filter Code", MemberCardTemp_p."Account No.");
                    end;
                1:
                    begin
                        PointSetupTemp_p.SetRange("Customer Filter Type", PointSetupTemp_p."Customer Filter Type"::"Price Group");
                        PointSetupTemp_p.SetRange("Customer Filter Code", ActivePriceGroup_p);
                    end;
                0:
                    begin
                        PointSetupTemp_p.SetRange("Customer Filter Type", PointSetupTemp_p."Customer Filter Type"::All);
                        PointSetupTemp_p.SetRange("Customer Filter Code");
                    end;
            end;

            if PointSetupTemp_p.FindLast then begin
                PointSetupTemp_p.SetRange("Filter Type", PointSetupTemp_p."Filter Type"::Item);
                PointSetupTemp_p.SetRange("Filter Code", ItemNo_p);
                if PointSetupTemp_p.FindSet then begin
                    PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Scheme);
                    PointSetupTemp_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Scheme Code", '');
                    if PointSetupTemp_p.FindLast then
                        exit(true);
                    PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Club);
                    PointSetupTemp_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Club Code", '');
                    if PointSetupTemp_p.FindLast then
                        exit(true);
                end;

                PointSetupTemp_p.SetRange("Scheme Filter Type");
                PointSetupTemp_p.SetRange("Club/Scheme");

                PointSetupTemp_p.SetRange("Filter Type", PointSetupTemp_p."Filter Type"::"Product Group");
                PointSetupTemp_p.SetRange("Filter Code", ProductGroup_p);
                if PointSetupTemp_p.FindSet then begin
                    PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Scheme);
                    PointSetupTemp_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Scheme Code", '');
                    if PointSetupTemp_p.FindLast then
                        exit(true);
                    PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Club);
                    PointSetupTemp_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Club Code", '');
                    if PointSetupTemp_p.FindLast then
                        exit(true);
                end;

                PointSetupTemp_p.SetRange("Scheme Filter Type");
                PointSetupTemp_p.SetRange("Club/Scheme");

                PointSetupTemp_p.SetRange("Filter Type", PointSetupTemp_p."Filter Type"::"Item Category");
                PointSetupTemp_p.SetRange("Filter Code", ItemCategory_p);
                if PointSetupTemp_p.FindSet then begin
                    PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Scheme);
                    PointSetupTemp_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Scheme Code", '');
                    if PointSetupTemp_p.FindLast then
                        exit(true);
                    PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Club);
                    PointSetupTemp_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Club Code", '');
                    if PointSetupTemp_p.FindLast then
                        exit(true);
                end;

                Clear(PointSetupMax);
                PointSetupTemp_p.SetRange("Filter Code");
                PointSetupTemp_p.SetRange("Club/Scheme");
                PointSetupTemp_p.SetRange("Scheme Filter Type");
                PointSetupTemp_p.SetRange("Filter Type", PointSetupTemp_p."Filter Type"::"Special Group");
                if PointSetupTemp_p.FindFirst() then begin
                    SpecialGroupLink.SetRange("Item No.", ItemNo_p);
                    if SpecialGroupLink.FindSet() then
                        repeat
                            PointSetupTemp_p.SetRange("Filter Code", SpecialGroupLink."Special Group Code");
                            PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Scheme);
                            PointSetupTemp_p.SetRange("Club/Scheme", MemberCardTemp_p."Scheme Code");
                            if PointSetupTemp_p.FindFirst() then begin
                                if PointSetupMax.Points < PointSetupTemp_p.Points then
                                    PointSetupMax := PointSetupTemp_p;
                            end;
                            PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Club);
                            PointSetupTemp_p.SetRange("Club/Scheme", MembershipCardTemp_g."Club Code");
                            if PointSetupTemp_p.FindFirst() then begin
                                if PointSetupMax.Points < PointSetupTemp_p.Points then
                                    PointSetupMax := PointSetupTemp_p;
                            end;
                        until SpecialGroupLink.Next = 0;

                    if PointSetupMax.Points <> 0 then begin
                        PointSetupTemp_p.Get(PointSetupMax."Scheme Filter Type", PointSetupMax."Club/Scheme", PointSetupMax."Filter Type",
                          PointSetupMax."Filter Code", PointSetupMax."Filter Sub Code", PointSetupMax."Customer Filter Type",
                          PointSetupMax."Customer Filter Code", PointSetupMax."Currency Code", PointSetupMax."Starting Date", PointSetupMax."Ending Date");
                        exit(true);
                    end;
                end;

                PointSetupTemp_p.SetRange("Scheme Filter Type");
                PointSetupTemp_p.SetRange("Club/Scheme");

                PointSetupTemp_p.SetRange("Filter Type", PointSetupTemp_p."Filter Type"::"All Items");
                PointSetupTemp_p.SetRange("Filter Code");
                if PointSetupTemp_p.FindSet then begin
                    PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Scheme);
                    PointSetupTemp_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Scheme Code", '');
                    if PointSetupTemp_p.FindLast then
                        exit(true);
                    PointSetupTemp_p.SetRange("Scheme Filter Type", PointSetupTemp_p."Scheme Filter Type"::Club);
                    PointSetupTemp_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Club Code", '');
                    if PointSetupTemp_p.FindLast then
                        exit(true);
                end;
                PointSetupTemp_p.SetRange("Filter Type");
            end;
        end;
        exit(false);
    end;

    procedure FindActiveOfferInStore(TransSalesEntry: Record "LSC Trans. Sales Entry"; var pPointOfferLine: Record "LSC Member Point Offer Line"; CardNo: Text[100]): Boolean
    var
        StoreSetup: Record "LSC Store";
        TransHeader: Record "LSC Transaction Header";
        PointOffer: Record "LSC Member Point Offer";
        PointOfferLines: Record "LSC Member Point Offer Line";
        TmpPointOffer: Record "LSC Member Point Offer" temporary;
        TmpPointOfferLine: Record "LSC Member Point Offer Line" temporary;
        Item: Record Item;
        ItemSpecialGroup: Record "LSC Item/Special Group Link";
        MembershipCardTemp: Record "LSC Membership Card";
        found: Boolean;
        FiltersOk: Boolean;
        OkPeriod: Boolean;
    begin
        TmpPointOffer.DeleteAll;
        TmpPointOfferLine.DeleteAll;

        StoreSetup.Get(TransSalesEntry."Store No.");
        Item.Get(TransSalesEntry."Item No.");
        TransHeader.Get(TransSalesEntry."Store No.", TransSalesEntry."POS Terminal No.", TransSalesEntry."Transaction No.");

        PointOffer.SetCurrentKey(Status);
        PointOffer.SetRange(Status, PointOffer.Status::Enabled);
        PointOffer.SetFilter("Currency Code", '%1|%2', StoreSetup."Currency Code", '');

        if TransSalesEntry."Unit of Measure" = '' then
            TransSalesEntry."Unit of Measure" := Item."Sales Unit of Measure";

        PointOfferLines.SetFilter("Unit of Measure", '%1|%2', TransSalesEntry."Unit of Measure", '');
        if TransSalesEntry."Variant Code" <> '' then
            PointOfferLines.SetFilter("Variant Code", '%1|%2', TransSalesEntry."Variant Code", '')
        else
            PointOfferLines.SetRange("Variant Code", '');

        if CardNo <> '' then
            if MembershipCardTemp.Get(CardNo) then begin
                MembershipCardTemp_g := MembershipCardTemp;
                rboPriceUtil.SetMemberInfo(MembershipCardTemp_g, MemberAttributeListTemp_g);
            end;

        if PointOffer.FindSet then
            repeat
                FiltersOk := false;
                if ((PointOffer."Customer Discount Group" = '') or (PointOffer."Customer Discount Group" = TransHeader."Customer Disc. Group"))
                  and rboPriceUtil.MemberFilterPassed(PointOffer."Member Type", PointOffer."Member Value")                  
                  and rboPriceUtil.MemberAttrFilterPassed(PointOffer."Member Attribute", PointOffer."Member Attribute Value")                  
                then begin
                    if PointOffer."Validation Period ID" = '' then
                        OkPeriod := true
                    else
                        OkPeriod := rboPriceUtil.DiscValPerValid(PointOffer."Validation Period ID", TransHeader.Date, TransHeader.Time);

                    if rboPriceUtil.PointOfferFiltersPassed(
                    
                         PointOffer, StoreSetup."No.", TransSalesEntry."Sales Type", TransSalesEntry."Price Group Code") and OkPeriod
                    then
                        FiltersOk := true
                    else
                        FiltersOk := false;
                end;

                if FiltersOk then begin
                    found := false;
                    PointOfferLines.SetRange("Offer No.", PointOffer."No.");
                    PointOfferLines.SetRange(Type, PointOfferLines.Type::Item);
                    PointOfferLines.SetRange("No.", Item."No.");
                    if PointOfferLines.FindLast then begin
                        found := true;
                        TmpPointOfferLine := PointOfferLines;
                    end;

                    if not found then begin
                        PointOfferLines.SetRange(Type, PointOfferLines.Type::"Product Group");
                        PointOfferLines.SetRange("No.", Item."LSC Retail Product Code");
                        PointOfferLines.SetRange("Prod. Group Category", Item."Item Category Code");
                        if PointOfferLines.FindFirst() then begin
                            found := true;
                            TmpPointOfferLine := PointOfferLines;
                        end;
                        PointOfferLines.SetRange("Prod. Group Category");
                    end;

                    if not found then begin
                        PointOfferLines.SetRange(Type, PointOfferLines.Type::"Item Category");
                        PointOfferLines.SetRange("No.", Item."Item Category Code");
                        if PointOfferLines.FindFirst() then begin
                            found := true;
                            TmpPointOfferLine := PointOfferLines;
                        end;
                    end;

                    if not found then begin
                        PointOfferLines.SetRange(Type, PointOfferLines.Type::"Item Category");
                        PointOfferLines.SetRange("No.", Item."Item Category Code");
                        if PointOfferLines.FindFirst() then begin
                            found := true;
                            TmpPointOfferLine := PointOfferLines;
                        end;
                    end;

                    if not found then begin
                        PointOfferLines.SetRange(Type, PointOfferLines.Type::All);
                        PointOfferLines.SetRange("No.");
                        if PointOfferLines.FindFirst() then begin
                            found := true;
                            TmpPointOfferLine := PointOfferLines;
                        end;
                    end;

                    if not found then begin
                        PointOfferLines.SetRange(Type, PointOfferLines.Type::"Special Group");
                        PointOfferLines.SetRange("No.");
                        PointOfferLines.SetRange(Exclude, true);
                        if PointOfferLines.FindSet then
                            repeat
                                if ItemSpecialGroup.Get(TransSalesEntry."Item No.", PointOfferLines."No.") then begin
                                    found := true;
                                    TmpPointOfferLine := PointOfferLines;
                                end;
                            until (PointOfferLines.Next = 0) or found;
                    end;

                    if not found then begin
                        PointOfferLines.SetRange(Type, PointOfferLines.Type::"Special Group");
                        PointOfferLines.SetRange("No.");
                        PointOfferLines.SetRange(Exclude, false);
                        if PointOfferLines.FindSet then
                            repeat
                                if ItemSpecialGroup.Get(TransSalesEntry."Item No.", PointOfferLines."No.") then begin
                                    found := true;
                                    TmpPointOfferLine := PointOfferLines;
                                end;
                            until (PointOfferLines.Next = 0) or found;
                    end;

                    if found and (not TmpPointOfferLine.Exclude) then begin
                        TmpPointOffer := PointOffer;
                        TmpPointOffer.Insert;
                        TmpPointOfferLine.Insert;
                    end
                end;
            until PointOffer.Next = 0;

        Clear(pPointOfferLine);
        TmpPointOffer.SetCurrentKey(Priority);
        if TmpPointOffer.FindFirst then begin
            TmpPointOfferLine.SetRange("Offer No.", TmpPointOffer."No.");
            TmpPointOfferLine.FindFirst;
            pPointOfferLine := TmpPointOfferLine;
            exit(true);
        end;

        exit(false);
    end;

    procedure TenderPoints(TransPaymentLine_p: Record "LSC Trans. Payment Entry"; MemberCardTemp_p: Record "LSC Membership Card" temporary; ActivePriceGroup_p: Code[10]; var MemberPointSetup_p: Record "LSC Member Point Setup"): Boolean
    var
        TenderTypeSetup_l: Record "LSC Tender Type Setup";
        CustFilterType_l: Integer;        
    begin
        //Loop through Trans. Payment Entry (P00220000...00044)
        //Treat each line seperately, sum up and use the most detailed - Find('+')
        MemberPointSetup_p.Reset;
        Clear(MemberPointSetup_p);
        MemberPointSetup_p.SetCurrentKey("Customer Filter Type", "Customer Filter Code");
        MemberPointSetup_p.SetFilter("Starting Date", '<=%1', TransPaymentLine_p.Date);
        MemberPointSetup_p.SetFilter("Ending Date", '>=%1|%2', TransPaymentLine_p.Date, 0D);
        MemberPointSetup_p.SetFilter("Currency Code", '%1|%2', TransPaymentLine_p."Currency Code", '');
        MemberPointSetup_p.SetRange("Filter Type", MemberPointSetup_p."Filter Type"::"Tender Type");
        MemberPointSetup_p.SetFilter("Club Code", MemberCardTemp_p."Club Code");
        MemberPointSetup_p.SetFilter("Filter Code", '%1|%2', TransPaymentLine_p."Tender Type", '');
        //if TenderTypeSetup_l.DefaultCardTender(TransPaymentLine_p."Tender Type") then //BC22
        if DefaultCardTender(TransPaymentLine_p."Tender Type") then //BC22
            MemberPointSetup_p.SetFilter("Filter Sub Code", '%1|%2', TransPaymentLine_p."Card No.", '');
        //if TenderTypeSetup_l.DefaultCurrencyTender(TransPaymentLine_p."Tender Type") then//BC22
        if DefaultCurrencyTender(TransPaymentLine_p."Tender Type") then //BC22
            MemberPointSetup_p.SetFilter("Filter Sub Code", '%1|%2', TransPaymentLine_p."Currency Code", '');

        for CustFilterType_l := MemberPointSetup_p."Customer Filter Type"::Account downto MemberPointSetup_p."Customer Filter Type"::All do begin
            case CustFilterType_l of
                2:
                    begin
                        MemberPointSetup_p.SetRange("Customer Filter Type", MemberPointSetup_p."Customer Filter Type"::Account);
                        MemberPointSetup_p.SetRange("Customer Filter Code", MemberCardTemp_p."Account No.");
                    end;
                1:
                    begin
                        MemberPointSetup_p.SetRange("Customer Filter Type", MemberPointSetup_p."Customer Filter Type"::"Price Group");
                        MemberPointSetup_p.SetRange("Customer Filter Code", ActivePriceGroup_p);
                    end;
                0:
                    begin
                        MemberPointSetup_p.SetRange("Customer Filter Type", MemberPointSetup_p."Customer Filter Type"::All);
                        MemberPointSetup_p.SetRange("Customer Filter Code");
                    end;
            end;

            if MemberPointSetup_p.FindLast then begin
                if MemberPointSetup_p."Scheme Filter Type" = MemberPointSetup_p."Scheme Filter Type"::Club then
                    exit(true)
                else begin
                    MemberPointSetup_p.SetRange("Scheme Filter Type", MemberPointSetup_p."Scheme Filter Type"::Scheme);
                    MemberPointSetup_p.SetFilter("Club/Scheme", '%1|%2', MemberCardTemp_p."Scheme Code", '');
                    if (MemberPointSetup_p."Filter Code" <> '') and (MemberPointSetup_p."Filter Code" = TransPaymentLine_p."Tender Type") then
                        MemberPointSetup_p.SetRange("Filter Code", TransPaymentLine_p."Tender Type");
                    if MemberPointSetup_p.FindFirst then
                        exit(true);
                end;
                MemberPointSetup_p.SetRange("Scheme Filter Type");
                MemberPointSetup_p.SetRange("Club/Scheme");
            end;
        end;

        exit(false);
    end;

    procedure CreateProcessOrderEntry(TransactionHeader_p: Record "LSC Transaction Header"; AccountNo_p: Code[20]; var ProcessOrderEntry_p: Record "LSC Member Process Order Entry")
    var
        TransSalesEntry_l: Record "LSC Trans. Sales Entry";
        TransDiscEntry_l: Record "LSC Trans. Discount Entry";
        TransPointEntry_l: Record "LSC Trans. Point Entry";
        POSCalcMemberPointsPublic: Codeunit "LSC POSCalcMemberPointsPublic";
        TransSalesEntries_l: Integer;
        TransDiscountEntries_l: Integer;
        PointsInTransaction_l: Decimal;
    begin
        TransSalesEntry_l.Reset;
        TransSalesEntry_l.SetRange("Store No.", TransactionHeader_p."Store No.");
        TransSalesEntry_l.SetRange("POS Terminal No.", TransactionHeader_p."POS Terminal No.");
        TransSalesEntry_l.SetRange("Transaction No.", TransactionHeader_p."Transaction No.");
        TransSalesEntries_l := TransSalesEntry_l.Count;

        TransDiscEntry_l.Reset;
        TransDiscEntry_l.SetRange("Store No.", TransactionHeader_p."Store No.");
        TransDiscEntry_l.SetRange("POS Terminal No.", TransactionHeader_p."POS Terminal No.");
        TransDiscEntry_l.SetRange("Transaction No.", TransactionHeader_p."Transaction No.");
        TransDiscountEntries_l := TransDiscEntry_l.Count;

        PointsInTransaction_l := 0;
        TransPointEntry_l.Reset;
        TransPointEntry_l.SetRange("Store No.", TransactionHeader_p."Store No.");
        TransPointEntry_l.SetRange("POS Terminal No.", TransactionHeader_p."POS Terminal No.");
        TransPointEntry_l.SetRange("Transaction No.", TransactionHeader_p."Transaction No.");
        if TransPointEntry_l.FindSet then
            repeat
                PointsInTransaction_l := PointsInTransaction_l + TransPointEntry_l.Points;
            until TransPointEntry_l.Next = 0;

        ProcessOrderEntry_p.Init;
        ProcessOrderEntry_p."Document Source" := ProcessOrderEntry_p."Document Source"::POS;
        ProcessOrderEntry_p."Document No." := TransactionHeader_p."Receipt No.";
        ProcessOrderEntry_p."Store No." := TransactionHeader_p."Store No.";
        ProcessOrderEntry_p."POS Terminal No." := TransactionHeader_p."POS Terminal No.";
        ProcessOrderEntry_p."Transaction No." := TransactionHeader_p."Transaction No.";
        ProcessOrderEntry_p.Date := TransactionHeader_p.Date;
        ProcessOrderEntry_p.Time := TransactionHeader_p.Time;
        ProcessOrderEntry_p."Points in Transaction" := PointsInTransaction_l;
        ProcessOrderEntry_p."Account No." := AccountNo_p;
        ProcessOrderEntry_p."Trans Sales Entries" := TransSalesEntries_l;
        ProcessOrderEntry_p."Trans Discount Entries" := TransDiscountEntries_l;        
        ProcessOrderEntry_p.Insert(true);
    end;

    procedure TransTenderAmount(var pTransHeader: Record "LSC Transaction Header"): Decimal
    var
        TenderType_l: Record "LSC Tender Type";
        TransPaymentEntry_l: Record "LSC Trans. Payment Entry";
        Payment_l: Decimal;
    begin
        //TransTenderAmount

        Payment_l := pTransHeader.Payment;

        TenderType_l.SetRange("Store No.", pTransHeader."Store No.");
        if TenderType_l.FindFirst then begin
            TransPaymentEntry_l.SetRange("Store No.", pTransHeader."Store No.");
            TransPaymentEntry_l.SetRange("POS Terminal No.", pTransHeader."POS Terminal No.");
            TransPaymentEntry_l.SetRange("Transaction No.", pTransHeader."Transaction No.");
            TransPaymentEntry_l.SetRange("Tender Type", TenderType_l.Code);
            if TransPaymentEntry_l.FindSet then
                repeat
                    Payment_l := Payment_l - TransPaymentEntry_l."Amount Tendered";
                until TransPaymentEntry_l.Next = 0;
        end;

        exit(Payment_l);
    end;

    local procedure GetActivePriceGroup(MemberAccountPriceGroup: Code[10]; MemberSchemeDefaultPriceGroup: Code[10]; MemberClubDefaultPriceGroup: Code[10]): Code[10]
    begin
        if MemberAccountPriceGroup <> '' then
            exit(MemberAccountPriceGroup)
        else
            if MemberSchemeDefaultPriceGroup <> '' then
                exit(MemberSchemeDefaultPriceGroup)
            else
                if MemberClubDefaultPriceGroup <> '' then
                    exit(MemberClubDefaultPriceGroup);
        exit('');
    end;

    local procedure GetPointsDiscountBenefits(TransactionHeader: Record "LSC Transaction Header"): Decimal;
    var
        TransDiscBenifitEntry: Record "LSC Trans. Disc. Benefit Entry";
        DiscBenifitPoints: Decimal;
    begin
        TransDiscBenifitEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransDiscBenifitEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransDiscBenifitEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        TransDiscBenifitEntry.SetRange(Type, TransDiscBenifitEntry.Type::"Member Points");
        if TransDiscBenifitEntry.FindSet then
            repeat
                if TransDiscBenifitEntry."Value Type" = TransDiscBenifitEntry."Value Type"::Points then
                    DiscBenifitPoints := DiscBenifitPoints + TransDiscBenifitEntry.Value;
            until TransDiscBenifitEntry.Next = 0;

        exit(DiscBenifitPoints);
    end;

    local procedure PointsDiscount(TransactionHeader: Record "LSC Transaction Header"; PointValue: Decimal; TransDate: Date);
    var
        TransDiscLine: Record "LSC Trans. Discount Entry";
        TransPointEntry: Record "LSC Trans. Point Entry";
    begin
        TransDiscLine.SetRange("Store No.", TransactionHeader."Store No.");
        TransDiscLine.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransDiscLine.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        TransDiscLine.SetRange("Offer Type", TransDiscLine."Offer Type"::"Item Point");
        if TransDiscLine.FindSet then
            repeat
                if not TransPointEntry.Get(TransactionHeader."Store No.", TransactionHeader."POS Terminal No.", TransactionHeader."Transaction No.",
                  TransactionHeader."Receipt No.", TransPointEntry."Entry Type"::Payment, TransPointEntry."Point Type"::Award)
                then begin
                    TransPointEntry.Init;
                    TransPointEntry."Store No." := TransactionHeader."Store No.";
                    TransPointEntry."POS Terminal No." := TransactionHeader."POS Terminal No.";
                    TransPointEntry."Transaction No." := TransactionHeader."Transaction No.";
                    TransPointEntry."Receipt No." := TransactionHeader."Receipt No.";
                    TransPointEntry."Entry Type" := TransPointEntry."Entry Type"::Payment;
                    TransPointEntry."Point Type" := TransPointEntry."Point Type"::Award;
                    TransPointEntry.Date := TransDate;
                    TransPointEntry."Card No." := TransactionHeader."Member Card No.";
                    TransPointEntry."Value Per Point" := PointValue;
                    TransPointEntry.Points := TransPointEntry.Points + TransDiscLine.Points;
                    TransPointEntry.Insert(true);
                end else begin
                    TransPointEntry.Points := TransPointEntry.Points + TransDiscLine.Points;
                    TransPointEntry.Modify(true);
                end;
            until TransDiscLine.Next = 0;
    end;

    local procedure PointsItemPurchased(TransactionHeader: Record "LSC Transaction Header"; MemberMgtSetup: Record "LSC Member Management Setup"; MemberPointSetup: Record "LSC Member Point Setup";
                                        MemberClub: Record "LSC Member Club"; MembershipCard: Record "LSC Membership Card"; ActivePriceGroup: Code[10]; var AwardPoints: Decimal;
                                        var OtherPoints: Decimal)
    var
        TransSalesLine: Record "LSC Trans. Sales Entry";
        TransDiscBenefitEntry: Record "LSC Trans. Disc. Benefit Entry";
        TransDiscEntry: Record "LSC Trans. Discount Entry";
        TransDiscLine: Record "LSC Trans. Discount Entry";
        MemberPointOfferLine: Record "LSC Member Point Offer Line";
        MemberPointOffer: Record "LSC Member Point Offer";
        StoreSetup: Record "LSC Store";
        POSCalcMemberPointsPublic: Codeunit "LSC POSCalcMemberPointsPublic";
        DiscBenifitPoints: Decimal;
        Qty: Decimal;
        AmountBase: Decimal;
        ItemPoints: Decimal;
        CurrPoints: Decimal;
    begin
        TransSalesLine.SetRange("Store No.", TransactionHeader."Store No.");
        TransSalesLine.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesLine.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        if TransSalesLine.FindSet then
            repeat
                Qty := -TransSalesLine.Quantity;
                CurrPoints := 0;
                ItemPoints := 0;
                if not TransSalesLine."Offer Blocked Points" then begin
                    if StoreSetup."No." <> TransSalesLine."Store No." then
                        StoreSetup.Get(TransSalesLine."Store No.");

                    if CalcPoints(StoreSetup."Currency Code", TransSalesLine.Date, TransSalesLine."Item Category Code", TransSalesLine."Retail Product Code", TransSalesLine."Item No.", MembershipCard, ActivePriceGroup, MemberPointSetup) then begin
                        if MemberMgtSetup."Amount Type for Point Calc." = MemberMgtSetup."Amount Type for Point Calc."::"Gross Amount" then
                            AmountBase := TransSalesLine."Net Amount" + TransSalesLine."VAT Amount"
                        else
                            AmountBase := TransSalesLine."Net Amount";
                                                    
                        if MemberPointSetup."Base Calculation on" = MemberPointSetup."Base Calculation on"::Amount then
                            ItemPoints := -Round(AmountBase * MemberPointSetup.Points / MemberPointSetup."Unit Rate", 0.01)
                        else
                            ItemPoints := -Round(TransSalesLine.Quantity * MemberPointSetup.Points / MemberPointSetup."Unit Rate", 0.01);
                    end;
                end;

                //Periodic Discount Offer with Factor Benefits
                TransDiscBenefitEntry.Reset;
                TransDiscBenefitEntry.SetRange("Store No.", TransSalesLine."Store No.");
                TransDiscBenefitEntry.SetRange("POS Terminal No.", TransSalesLine."POS Terminal No.");
                TransDiscBenefitEntry.SetRange("Transaction No.", TransSalesLine."Transaction No.");
                TransDiscBenefitEntry.SetRange("Offer No.", TransSalesLine."Periodic Disc. Group");
                TransDiscBenefitEntry.SetRange(Type, TransDiscBenefitEntry.Type::"Member Points");
                TransDiscBenefitEntry.SetRange("Value Type", TransDiscBenefitEntry."Value Type"::Factor);
                if TransDiscBenefitEntry.FindFirst then
                    if TransDiscBenefitEntry.Value > 0 then
                        CurrPoints := CurrPoints + ItemPoints * TransDiscBenefitEntry.Value;

                //Total Discount Offer with Factor benefits
                TransDiscEntry.Reset;
                TransDiscEntry.SetRange("Store No.", TransactionHeader."Store No.");
                TransDiscEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
                TransDiscEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
                TransDiscEntry.SetRange("Line No.", TransSalesLine."Line No.");
                TransDiscEntry.SetRange("Offer Type", TransDiscLine."Offer Type"::"Total Discount");
                if TransDiscEntry.FindSet then begin
                    repeat
                        TransDiscBenefitEntry.Reset;
                        TransDiscBenefitEntry.SetRange("Store No.", TransDiscEntry."Store No.");
                        TransDiscBenefitEntry.SetRange("POS Terminal No.", TransDiscEntry."POS Terminal No.");
                        TransDiscBenefitEntry.SetRange("Transaction No.", TransDiscEntry."Transaction No.");
                        TransDiscBenefitEntry.SetRange(Type, TransDiscBenefitEntry.Type::"Member Points");
                        TransDiscBenefitEntry.SetRange("Offer Type", TransDiscBenefitEntry."Offer Type"::"Total Discount");
                        TransDiscBenefitEntry.SetRange("Offer No.", TransDiscEntry."Offer No.");
                        TransDiscBenefitEntry.SetRange("Value Type", TransDiscBenefitEntry."Value Type"::Factor);
                        if TransDiscBenefitEntry.FindFirst then
                            CurrPoints := CurrPoints + ItemPoints * TransDiscBenefitEntry.Value;
                    until TransDiscEntry.Next = 0;
                end;

                if FindActiveOfferInStore(TransSalesLine, MemberPointOfferLine, '') then begin
                    if MemberPointOffer."No." <> MemberPointOfferLine."Offer No." then
                        MemberPointOffer.Get(MemberPointOfferLine."Offer No.");
                    TransDiscLine.Init;
                    TransDiscLine."Store No." := TransactionHeader."Store No.";
                    TransDiscLine."POS Terminal No." := TransactionHeader."POS Terminal No.";
                    TransDiscLine."Transaction No." := TransactionHeader."Transaction No.";
                    TransDiscLine."Line No." := TransSalesLine."Line No.";
                    TransDiscLine."Offer Type" := TransDiscLine."Offer Type"::"Member Point";
                    TransDiscLine."Offer No." := MemberPointOfferLine."Offer No.";
                    TransDiscLine."Receipt No." := TransSalesLine."Receipt No.";
                    TransDiscLine."Member Attribute" := MemberPointOffer."Member Attribute";
                    TransDiscLine."Member Attribute Value" := MemberPointOffer."Member Attribute Value";
                    TransDiscLine."Discount Amount" := 0;

                    case MemberPointOfferLine."Value Type" of
                        MemberPointOfferLine."Value Type"::Factor:
                            begin
                                if MemberClub."Point Rounding Precision" > 0 then
                                    TransDiscLine.Points := MemberPostingUtils.RoundPoints((ItemPoints * MemberPointOfferLine.Value), MemberClub)
                                else
                                    TransDiscLine.Points := ItemPoints * MemberPointOfferLine.Value;
                            end;
                        MemberPointOfferLine."Value Type"::"Additional per unit":
                            begin
                                CurrPoints := CurrPoints + ItemPoints;
                                TransDiscLine.Points := MemberPointOfferLine.Value * Qty;
                            end;
                        MemberPointOfferLine."Value Type"::"Replacement per unit":
                            if MemberPointOfferLine.Value * Qty > CurrPoints then begin
                                TransDiscLine.Points := MemberPointOfferLine.Value * Qty;
                                CurrPoints := 0;
                            end;
                    end;
                    CurrPoints := CurrPoints + TransDiscLine.Points;
                    TransDiscLine.Insert(true);
                end;

                if (CurrPoints = 0) and (ItemPoints <> 0) then
                    CurrPoints := ItemPoints;

                if CurrPoints <> 0 then begin
                    if MemberPointSetup."Points Type" = MemberPointSetup."Points Type"::"Award Points" then begin
                        AwardPoints := AwardPoints + CurrPoints;
                        TransSalesLine."Member Points Type" := TransSalesLine."Member Points Type"::"Award Points";
                        TransSalesLine."Member Points" := CurrPoints;
                    end
                    else begin
                        OtherPoints := OtherPoints + CurrPoints;
                        TransSalesLine."Member Points Type" := TransSalesLine."Member Points Type"::"Other Points";
                        TransSalesLine."Member Points" := CurrPoints;
                    end;
                    TransSalesLine.Modify(true);
                end;
            until TransSalesLine.Next = 0;
    end;

    local procedure PointsTender(TransactionHeader: Record "LSC Transaction Header"; MembershipCard: Record "LSC Membership Card"; MemberClub: Record "LSC Member Club";
                                MemberPointSetup: Record "LSC Member Point Setup"; ActivePriceGroup: Code[10]; var AwardPoints: Decimal; var OtherPoints: Decimal; var TenderAwardPoints: Decimal;
                                var TenderOtherPoints: Decimal);
    var
        TransPaymentLine: Record "LSC Trans. Payment Entry";
        TenderPoints: Decimal;
    begin
        TenderPoints := 0;
        TransPaymentLine.SetRange("Store No.", TransactionHeader."Store No.");
        TransPaymentLine.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransPaymentLine.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        if TransPaymentLine.FindSet then
            repeat
                if (TransPaymentLine."Amount in Currency" > 0) or TransPaymentLine."Change Line" then  //Refund not subtracted for point balance
                    if TenderPoints(TransPaymentLine, MembershipCard, ActivePriceGroup, MemberPointSetup) then
                        if MemberPointSetup."Unit Rate" <> 0 then begin
                            TenderPoints := TransPaymentLine."Amount in Currency" / MemberPointSetup."Unit Rate" * MemberPointSetup.Points;
                            if MemberPointSetup."Points Type" = MemberPointSetup."Points Type"::"Award Points" then
                                TenderAwardPoints := TenderAwardPoints + MemberPostingUtils.RoundPoints(TenderPoints, MemberClub)
                            else
                                TenderOtherPoints := TenderOtherPoints + MemberPostingUtils.RoundPoints(TenderPoints, MemberClub);
                        end;
            until TransPaymentLine.Next = 0;
        AwardPoints := AwardPoints + TenderAwardPoints;
        OtherPoints := OtherPoints + TenderOtherPoints;
    end;

    local procedure InsertTransPointEntry(TransactionHeader: Record "LSC Transaction Header"; MemberClub: Record "LSC Member Club"; DiscBenifitPoints: Decimal; BenefitPointType: Option;
                                          PointType: Option; Points: Decimal; TenderPoints: Decimal)
    var
        TransPointEntry: Record "LSC Trans. Point Entry";
    begin
        TransPointEntry.Init;
        TransPointEntry."Store No." := TransactionHeader."Store No.";
        TransPointEntry."POS Terminal No." := TransactionHeader."POS Terminal No.";
        TransPointEntry."Transaction No." := TransactionHeader."Transaction No.";
        TransPointEntry."Receipt No." := TransactionHeader."Receipt No.";
        TransPointEntry."Entry Type" := TransPointEntry."Entry Type"::Sale;
        TransPointEntry."Point Type" := PointType;
        if MemberClub."Disc. Benefit Point Type" = BenefitPointType then begin
            TransPointEntry."Disc. Benefit Points" := DiscBenifitPoints;
            TransPointEntry.Points := MemberPostingUtils.RoundPoints(Points + DiscBenifitPoints, MemberClub);
        end else
            TransPointEntry.Points := MemberPostingUtils.RoundPoints(Points, MemberClub);
        TransPointEntry."Tender Points" := TenderPoints;
        TransPointEntry.Date := TransactionHeader.Date;
        TransPointEntry."Value Per Point" := MemberClub."Point Value";
        TransPointEntry."Card No." := TransactionHeader."Member Card No.";
        if (TransPointEntry.Points <> 0) or (TransPointEntry."Disc. Benefit Points" <> 0) then
            TransPointEntry.Insert(true);
    end;

    procedure UpdateMemberFromSPGCustomerOrder(TransactionHeader: Record "LSC Transaction Header"): Boolean
    var
        MemberAccount: Record "LSC Member Account";
        MemberClub: Record "LSC Member Club";
        MemberScheme: Record "LSC Member Scheme";
        MemberMgtSetup: Record "LSC Member Management Setup";
        MemberPointSetup: Record "LSC Member Point Setup";
        TransPaymentLine: Record "LSC Trans. Payment Entry";
        TransPointEntry: Record "LSC Trans. Point Entry";
        ProcessOrderEntry: Record "LSC Member Process Order Entry";
        MembershipCard: Record "LSC Membership Card";
        MemberAttributeMgmt: Codeunit "LSC Member Attribute Mgmt";
        ActivePriceGroup: Code[10];
        AwardPoints: Decimal;
        OtherPoints: Decimal;
        DiscBenifitPoints: Decimal;
        TenderAwardPoints: Decimal;
        TenderOtherPoints: Decimal;
        PaymentWithPoints: Boolean;
    begin
        if TransactionHeader."Entry Status" <> TransactionHeader."Entry Status"::" " then
            exit(false);
        if TransactionHeader."Member Card No." = '' then
            exit(false);

        MembershipCard.Get(TransactionHeader."Member Card No.");
        MemberAccount.Get(MembershipCard."Account No.");
        MemberClub.Get(MemberAccount."Club Code");
        MemberScheme.Get(MemberAccount."Scheme Code");
        MemberAttributeMgmt.GetAllAttributes(TransactionHeader."Member Card No.", MemberAttributeListTemp_g);

        MemberMgtSetup.Get();
        MemberPointSetup.SetRange("Customer Filter Type", MemberPointSetup."Customer Filter Type"::Account);
        MemberPointSetup.SetRange("Customer Filter Code", TransactionHeader."Member Card No.");
        MemberPointSetup.SetRange("Club Code", MemberClub.Code);
        if not MemberPointSetup.IsEmpty() then
            MemberPointSetup.FindSet();

        ActivePriceGroup := GetActivePriceGroup(MemberAccount."Price Group", MemberScheme."Default Price Group", MemberClub."Default Price Group");

        rboPriceUtil.SetMemberInfo(MembershipCard, MemberAttributeListTemp_g);

        //Check if the total Transaction meets the minimum Transaction Amount limit for Point calculation.
        TransPaymentLine.SetRange("Store No.", TransactionHeader."Store No.");
        TransPaymentLine.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransPaymentLine.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        TransPaymentLine.SetRange("Tender Type", MemberClub."Member Point Tender Type");

        if Abs(TransTenderAmount(TransactionHeader)) < MemberClub."Min. Trans.Amt for Point Calc." then begin
            if not TransPaymentLine.IsEmpty() then
                CreateProcessOrderEntry(TransactionHeader, MemberAccount."No.", ProcessOrderEntry);
            exit(false);
        end;

        //Points as Discount Benefits
        DiscBenifitPoints := GetPointsDiscountBenefits(TransactionHeader);

        //Points as Discount
        if not TransPaymentLine.IsEmpty() then
            TransPaymentLine.FindFirst();
        PointsDiscount(TransactionHeader, MemberClub."Point Value", TransPaymentLine.Date);

        //points pr. Item purchased
        PointsItemPurchased(TransactionHeader, MemberMgtSetup, MemberPointSetup, MemberClub, MembershipCard, ActivePriceGroup, AwardPoints, OtherPoints);

        //Points fom Tender
        PointsTender(TransactionHeader, MembershipCard, MemberClub, MemberPointSetup, ActivePriceGroup, AwardPoints, OtherPoints, TenderAwardPoints, TenderOtherPoints);

        //Create Transaction Point Entry - Award
        if (AwardPoints <> 0) or (DiscBenifitPoints <> 0) then
            InsertTransPointEntry(TransactionHeader, MemberClub, DiscBenifitPoints, MemberClub."Disc. Benefit Point Type"::"Award Points", TransPointEntry."Point Type"::Award, AwardPoints, TenderAwardPoints);

        //Create Transaction Point Entry - Other
        if (OtherPoints <> 0) or (DiscBenifitPoints <> 0) then
            InsertTransPointEntry(TransactionHeader, MemberClub, DiscBenifitPoints, MemberClub."Disc. Benefit Point Type"::"Other Points", TransPointEntry."Point Type"::Other, OtherPoints, TenderOtherPoints);

        CreateProcessOrderEntry(TransactionHeader, MemberAccount."No.", ProcessOrderEntry);

        exit(true);
    end;

    procedure DefaultCurrencyTender(pCode: Code[10]): Boolean
    var
        lTenderTypeSetup: Record "LSC Tender Type Setup";
    begin
        if lTenderTypeSetup.Get(pCode) then
            exit(lTenderTypeSetup."Default Currency Tender");
        exit(false);
    end;

    procedure DefaultCardTender(pCode: Code[10]): Boolean
    var
        lTenderTypeSetup: Record "LSC Tender Type Setup";
    begin
        if lTenderTypeSetup.Get(pCode) then
            exit(lTenderTypeSetup."Default Card Tender");
        exit(false);
    end;
}