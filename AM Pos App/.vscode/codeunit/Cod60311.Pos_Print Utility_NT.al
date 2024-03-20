
codeunit 60311 "Pos_Print Utility_NT"
{
    trigger OnRun()
    begin

    end;

    procedure PrintTellAlphaMega(var PosPrintUtility: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        GenSetup: Record "eCom_General Setup_NT";
        BigInt: BigInteger;
        Code: Code[10];
        Date: Date;
        IntStore: Integer;
        DSTR1: Text[100];
        txt: Text;
        Value: array[10] of Text[80];
    begin
        if not Evaluate(IntStore, Transaction."Store No.") then
            exit;

        GenSetup.Get();
        if GenSetup."Retail Zoom Starting Date" = 0D then
            exit;

        Date := GenSetup."Retail Zoom Starting Date";

        BigInt := TODAY - Date - 1;
        //AM.SK 14/09/22 txt := COPYSTR(FORMAT(BigInt,0,'<Integer>'),2,3);
        txt := Format(BigInt, 0, '<Integer>');//AM.SK 14/09/22
        txt := txt + CopyStr(Transaction."Store No.", StrLen(Transaction."Store No.") - 1, 2);
        txt := txt + CopyStr(Transaction."POS Terminal No.", StrLen(Transaction."POS Terminal No.") - 1, 2);
        txt := txt + CopyStr(Transaction."Receipt No.", StrLen(Transaction."Receipt No.") - 3, 4);
        Evaluate(BigInt, txt);
        txt := Int2Hex(BigInt);
        //txt := Int2Hex(Int);
        //Code[1] := PADSTR(txt,4,'0');
        //Code[2] := COPYSTR(Transaction."Store No.",STRLEN(Transaction."Store No."),1);
        //EVALUATE(Int,COPYSTR(Transaction."POS Terminal No.",STRLEN(Transaction."POS Terminal No.") - 1,2));
        //txt := Int2Hex(Int);
        //Code[3] := PADSTR(txt,2,'0');
        //EVALUATE(Int,COPYSTR(Transaction."Receipt No.",STRLEN(Transaction."Receipt No.") - 4,5));
        //txt := Int2Hex(Int);
        //Code[4] := PADSTR(txt,5,'0');

        DSTR1 := '#L######################################';
        Value[1] := '****************************************';
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
        Value[1] := '* We value your opinion. Please tell   *';
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
        Value[1] := '* us about your shopping experience    *';
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
        Value[1] := '* by completing an online survey       *';
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
        Value[1] := '* you could win a 150 Euro voucher     *';
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
        Value[1] := '* each month! Visit:                   *';
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
        Value[1] := '* http://www.tellalphamega.com         *';
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
        Value[1] := StrSubstNo('* Entry code:%1                 *', txt);
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
        Value[1] := '****************************************';
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(Value, DSTR1), false, false, false, false));
    end;

    local procedure Int2Hex(IntValue: BigInteger) txtHex: Text
    var
        txtDigits: Text[16];
    begin
        txtDigits := '0123456789ABCDEF';
        txtHex := '';
        repeat
            txtHex := CopyStr(txtDigits, (IntValue mod 16) + 1, 1) + txtHex;
            IntValue := (IntValue - (IntValue mod 16)) / 16;
        until IntValue = 0;
    end;

    procedure PrintCustomerSlip(var PosPrintUtility: Codeunit "LSC POS Print Utility"; PaymEntry: Record "LSC Trans. Payment Entry"): Boolean
    var
        Contact: Record Contact;
        Customer: Record Customer;
        MemberCardTemp: Record "LSC Membership Card" temporary;
        MemberContact: Record "LSC Member Contact";
        Tendertype: Record "LSC Tender Type";
        Transaction: Record "LSC Transaction Header";
        POSFunctions: Codeunit "LSC POS Functions";
        ProcessCode: Code[30];
        i: Integer;
        DSTR1: Text[100];
        ErrorText: Text;
        FieldValue: array[10] of Text[100];
        NodeName: array[32] of Text[50];
        Payment: Text[30];
        Text003: Label 'RETURN';
        Text004: Label 'Amount';
        Text006: Label 'Paid into account no.';
        Text007: Label 'Charge my account no.';
    begin
        PosFuncProfile.Get(Globals.FunctionalityProfileID());
        if PaymEntry."Transaction No." = 0 then
            exit(true);
        if not Transaction.Get(PaymEntry."Store No.", PaymEntry."POS Terminal No.", PaymEntry."Transaction No.") then
            exit(true);
        if not Customer.Get(PaymEntry."Card or Account") then
            exit(true);
        if not Tendertype.Get(PaymEntry."Store No.", PaymEntry."Tender Type") then
            exit(true);
        if not (Tendertype."Function" = Tendertype."Function"::Customer) then
            exit(true);

        PosPrintUtility.WindowInitialize();
        if PosFuncProfile."Customer Slip Report ID" <> 0 then begin
            Transaction.SetRange("Store No.", Transaction."Store No.");
            Transaction.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            Transaction.SetRange("Transaction No.", Transaction."Transaction No.");
            REPORT.Run(PosFuncProfile."Customer Slip Report ID", false, true, Transaction);
            if PosFuncProfile."Customer Slip Report ID" = PosFuncProfile."Sales Slip Report ID" then begin
                Transaction.IncPrintedCounter(1);
                Commit;
            end;
        end else begin

            if not PosPrintUtility.OpenReceiptPrinter(2, 'CUSTOMER', '', Transaction."Transaction No.", Transaction."Receipt No.") then
                exit(false);

            PosPrintUtility.PrintLogo(2);

            PosPrintUtility.PrintHeader(Transaction, false, 2);

            DSTR1 := '#C##################';
            if Transaction."Sale Is Return Sale" then begin
                FieldValue[1] := Text003;
                NodeName[1] := 'Description';
                PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1, true), true, true, true, false));
                PosPrintUtility.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, true, true, true, false, 2);
                PosPrintUtility.PrintSeperator(2);
            end;
            PosPrintUtility.PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);
            // NT ..

            DSTR1 := '#C##################';

            PosPrintUtility.PrintSeperator(2);
            PosPrintUtility.PrintLine(2, '');
            IF Transaction."Sale Is Return Sale" XOR
               (Transaction."Transaction Type" = Transaction."Transaction Type"::Payment) THEN
                //Value[1] := 'Receipt' //BC Upgrade
                FieldValue[1] := 'Receipt' //BC Upgrade
            ELSE
                //Value[1] := 'Credit Invoice';//BC Upgrade
                FieldValue[1] := 'Credit Invoice';//BC Upgrade

            //PrintLine(2, FormatLine(FormatStr(Value, DSTR1), TRUE, TRUE, FALSE, FALSE)); //BC Upgrade
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), true, true, false, false));//BC Upgrade

            PosPrintUtility.PrintLine(2, '');
            PosPrintUtility.PrintSeperator(2);

            // .. NT
            if Transaction."Customer No." <> '' then begin
                if Customer.Get(Transaction."Customer No.") then begin
                    DSTR1 := '#T############# #T######################';
                    FieldValue[1] := Customer."No.";
                    NodeName[1] := 'Customer No.';
                    FieldValue[2] := CopyStr(Customer.Name, 1, MaxStrLen(FieldValue[2]));
                    NodeName[2] := 'Customer Name';
                    PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    PosPrintUtility.AddPrintLine(200, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
                    PosPrintUtility.PrintSeperator(2);
                    PosPrintUtility.PrintLine(2, '');
                    PosPrintUtility.PrintLine(2, '');
                end;
            end;
            // NT ..

            if Transaction."Member Card No." <> '' then
                //IF POSFunctions.LoadMemberInformation(Transaction."Member Card No.", ProcessError, ErrorText) THEN BEGIN //BC Upgrade
                if POSFunctions.GetMemberInfoForPos(Transaction."Member Card No.", ProcessCode, ErrorText) then begin //BC Upgrade
                    DSTR1 := '#C######################################';
                    //Value[1] := 'Social Family Card'; //BC Upgrade
                    FieldValue[1] := 'Social Family Card'; //BC Upgrade
                    PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false)); // BC Upgrade : Value -> FieldValue
                    POSFunctions.GetMemberShipCardInfo(MemberCardTemp);
                    //MemberCardTemp.CALCFIELDS("Cardholder Name"); BC Upgrade
                    if not MemberContact.Get(MemberCardTemp."Account No.", MemberCardTemp."Contact No.") then
                        MemberContact.Init();
                    DSTR1 := '#T############# #T######################';
                    FieldValue[1] := MemberCardTemp."Card No.";//BC Upgrade : Value -> FieldValue
                    NodeName[1] := 'Card No.';
                    //Value[2] := COPYSTR(MemberCardTemp."Cardholder Name", 1, MAXSTRLEN(Value[2]));//BC Upgrade
                    FieldValue[2] := CopyStr(MemberContact.Name, 1, MaxStrLen(FieldValue[2]));//BC Upgrade
                    NodeName[2] := 'Member Name';
                    PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));// BC Upgrade : Value -> FieldValue
                    PosPrintUtility.AddPrintLine(200, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);// BC Upgrade : Value -> FieldValue
                    PosPrintUtility.PrintSeperator(2);
                    PosPrintUtility.PrintLine(2, '');
                    PosPrintUtility.PrintLine(2, '');
                END;

            // .. NT

            if Transaction."Sell-to Contact No." <> '' then begin
                if Contact.Get(Transaction."Sell-to Contact No.") then begin
                    DSTR1 := '#T############# #T######################';
                    FieldValue[1] := Contact."No.";
                    NodeName[1] := 'Contact No.';
                    FieldValue[2] := CopyStr(Contact.Name, 1, MaxStrLen(FieldValue[2]));
                    NodeName[2] := 'Contact Name';
                    PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    PosPrintUtility.AddPrintLine(200, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
                    PosPrintUtility.PrintSeperator(2);
                    PosPrintUtility.PrintLine(2, '');
                    PosPrintUtility.PrintLine(2, '');
                end;
            end;

            DSTR1 := '#L##################### #R##############';

            if Transaction."Sale Is Return Sale" xor
               (Transaction."Transaction Type" = Transaction."Transaction Type"::Payment) then
                FieldValue[1] := Text006
            else
                FieldValue[1] := Text007;
            NodeName[1] := 'Account Text';
            FieldValue[2] := PaymEntry."Card or Account";
            NodeName[2] := 'Account No.';
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
            PosPrintUtility.AddPrintLine(200, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

            PosPrintUtility.PrintLine(2, '');

            DSTR1 := '#L#############             #N##########';
            FieldValue[1] := Text004;
            NodeName[1] := 'Total Text';
            if Transaction."Transaction Type" = Transaction."Transaction Type"::Payment then
                FieldValue[2] := POSFunctions.FormatAmount(-PaymEntry."Amount Tendered")
            else
                FieldValue[2] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
            NodeName[2] := 'Total Amount';
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
            PosPrintUtility.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
            PosPrintUtility.PrintSignature('');
            if not PosPrintUtility.ClosePrinter(2) then
                exit(false);
        end;
        exit(true);
    end;

    procedure PrintMemberInfoInSuspendSlip(var PosPrintUtility: Codeunit "LSC POS Print Utility"; PosTrans: Record "LSC POS Transaction")
    var
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
        DSTR1: Text[100];
        ErrorText: Text;
        FieldValue: array[10] of Text[100];
    begin
        if POSTrans."Member Card No." <> '' then
            if MembershipCard.Get(POSTrans."Member Card No.") then begin
                if not MemberContact.Get(MembershipCard."Account No.", MembershipCard."Contact No.") then //BC Upgrade
                    MemberContact.Init();//BC Upgrade
                //MembershipCard.CALCFIELDS("Cardholder Name"); // BC Upgrade
                DSTR1 := '#L########## #L#########################';
                FieldValue[1] := 'Customer Name:';
                // FieldValue[2] := MembershipCard." Cardholder Name "; // BC Upgrade
                FieldValue[2] := MemberContact.Name; // BC Upgrade
                PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                FieldValue[1] := 'Card No.:';
                FieldValue[2] := MembershipCard."Card No.";
                PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                PosPrintUtility.PrintSeperator(2);
                PosPrintUtility.PrintLine(2, '');
            end;
    end;

    procedure PrintSubHeader_AM(var PosPrintUtility: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header"; var StaffName: Text[30])
    var
        Staff: Record "LSC Staff";
        InvLineLen: Integer;
        LineLen: Integer;
        Tray: Integer;
        blankStr: Text[30];
        DSTR1: Text[100];
        FieldValue: array[10] of Text[100];
        NodeName: array[32] of Text[50];
        StaffName2: Text[30];
    begin
        Tray := 2;
        LineLen := 40;
        InvLineLen := 44;

        if Tray = 2 then
            blankStr := PosPrintUtility.StringPad(' ', LineLen - 38)
        else
            if Tray = 4 then
                blankStr := PosPrintUtility.StringPad(' ', InvLineLen - 38);
        DSTR1 := '#L##################### #L############################';
        StaffName := Transaction."Staff ID";
        StaffName2 := Transaction."Staff ID";
        if Staff.Get(Transaction."Staff ID") then
            StaffName2 := Staff."Name on Receipt";
        FieldValue[1] := 'Your cashier today was ';
        NodeName[1] := 'x';
        FieldValue[2] := StaffName2;
        NodeName[2] := 'x';
        PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
        PosPrintUtility.AddPrintLine(200, 2, NodeName, FieldValue, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);

        DSTR1 := '#L#### #L############' + blankStr + '#L#### #N########';

        FieldValue[1] := 'Store:';
        FieldValue[2] := Transaction."Store No.";
        FieldValue[3] := 'POS:';
        FieldValue[4] := Transaction."POS Terminal No.";
        PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));

        FieldValue[1] := Text002 + ':';
        NodeName[1] := 'x';
        FieldValue[2] := Format(Transaction."Transaction No.");
        NodeName[2] := 'Transaction No.';
        if Transaction."Transaction No." = 0 then begin
            FieldValue[1] := '';
            NodeName[1] := 'x';
            FieldValue[2] := '';
            NodeName[2] := 'x';
        end;
    end;

    procedure TransTotalNumberOfItems(var TotalNumberOfItems: Decimal; SalesEntry: Record "LSC Trans. Sales Entry"; CountItemOk: Boolean)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        PosGenUtils: Codeunit "Pos_General Utility_NT";
        TotNoOfItems: Decimal;
    begin
        if CountItemOk then begin
            TotalNumberOfItems := PosGenUtils.GetToalNumberOfItems();
            if ItemUnitOfMeasure.Get(SalesEntry."Item No.", SalesEntry."Unit of Measure") then begin
                if ItemUnitOfMeasure."LSC Count as 1 on Receipt" then
                    TotalNumberOfItems := TotalNumberOfItems + 1
                else
                    TotalNumberOfItems := TotalNumberOfItems + LineNoOfItems(Abs(SalesEntry.Quantity));

            end else
                TotalNumberOfItems := TotalNumberOfItems + LineNoOfItems(Abs(SalesEntry.Quantity));
            PosGenUtils.SetToalNumberOfItems(TotalNumberOfItems);
        end;
    end;

    local procedure LineNoOfItems(Qty: Decimal): Decimal
    begin
        if (Qty > 0) and (Round(Qty, 1) <> Qty) then
            exit(1);
        exit(Qty);
    end;

    procedure PrintTotalSavingsExtras(var PosPrintUtility: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; PrintTotalSavings: Boolean; TotalSavings: Decimal; Tray: Integer; var IsHandled: Boolean)
    var
        TransPointEntry: Record "LSC Trans. Point Entry";
        POSFunctions: Codeunit "LSC POS Functions";
        Points: Decimal;
        DSTR1: Text[100];
        FieldValue: array[10] of Text[100];
        NodeName: array[32] of Text[50];
    begin
        IsHandled := false;
        if PrintTotalSavings AND (TotalSavings <> 0) then begin

            DSTR1 := '#L###################################';
            FieldValue[1] := Text003;
            PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), true, true, false, false));
            FieldValue[1] := Text007;
            PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));

            DSTR1 := '#L####################### #R#########';
            FieldValue[1] := TextSavedToday;
            NodeName[1] := 'Total Text';
            FieldValue[2] := POSFunctions.FormatAmount(TotalSavings);
            NodeName[2] := 'Total Amount';
            PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
            PosPrintUtility.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            IsHandled := true;
        end;

        if Transaction."Member Card No." <> '' then begin
            Clear(Points);
            TransPointEntry.SetRange("Store No.", Transaction."Store No.");
            TransPointEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            TransPointEntry.SetRange("Transaction No.", Transaction."Transaction No.");
            if TransPointEntry.FindSet() then
                repeat
                    if TransPointEntry."Entry Type" = TransPointEntry."Entry Type"::Sale then
                        Points += TransPointEntry.Points
                    else
                        Points -= TransPointEntry.Points;
                until TransPointEntry.NEXT = 0;
            if Points <> 0 then begin
                PosPrintUtility.PrintLine(Tray, '');
                Clear(FieldValue);
                DSTR1 := '#L######################################';
                FieldValue[1] := STRSUBSTNO(Text006, Points);
                PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), FALSE, TRUE, FALSE, FALSE));
                PosPrintUtility.PrintSeperator(Tray);
                PosPrintUtility.PrintLine(Tray, '');
            end else
                PosPrintUtility.PrintSeperator(Tray);
        end else
            PosPrintUtility.PrintSeperator(Tray);
        PrintContinuity(PosPrintUtility, Tray, Transaction."Gross Amount" - Continuity2ExcludeAmt(Transaction), Transaction."Continuity Member No." <> '');
    end;

    local procedure PrintContinuity(var PosPrintUtility: Codeunit "LSC POS Print Utility"; Tray: Integer; Amt: Decimal; Digital: Boolean)
    var
        Continuity: Record Pos_Continuity_NT;
        Printed: Boolean;
        NoOfCoupons: Integer;
        DSTR1: Text[100];
        FieldValue: array[10] of Text[100];
    begin
        Printed := false;
        Continuity.SetCurrentKey("Starting Date", "Ending Date");
        Continuity.SetRange("Starting Date", 0D, Today);
        Continuity.SetFilter("Ending Date", '%1|>=%2', 0D, Today);
        DSTR1 := '#L###################################   ';
        Clear(FieldValue);
        if Continuity.FindSet() then
            repeat
                if Digital then
                    NoOfCoupons := -Amt DIV Continuity."One Digital Coupon Per Amount"
                else
                    NoOfCoupons := -Amt DIV Continuity."One Coupon Per Amount";
                if NoOfCoupons > 0 then begin
                    Printed := true;
                    if Digital then
                        FieldValue[1] := StrSubstNo('You are entitled %1 digital', NoOfCoupons)
                    else
                        FieldValue[1] := StrSubstNo('You are entitled %1', NoOfCoupons);
                    PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                    FieldValue[1] := StrSubstNo('%1 Coupons', Continuity.Description);
                    PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                end;
            until Continuity.Next() = 0;
        if Printed then
            PosPrintUtility.PrintSeperator(Tray);
    end;

    local procedure Continuity2ExcludeAmt(TransHeader: Record "LSC Transaction Header") Amt2Exclude: Decimal
    var
        Item: Record Item;
        TransSalesEntry: Record "LSC Trans. Sales Entry";
    begin
        Amt2Exclude := 0;
        TransSalesEntry.SetRange("Store No.", TransHeader."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", TransHeader."Transaction No.");
        if TransSalesEntry.FindSet() then
            repeat
                if Item.Get(TransSalesEntry."Item No.") then
                    IF Item."No Loyalty Points" THEN
                        Amt2Exclude += TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount";
            UNTIL TransSalesEntry.NEXT = 0;
    end;

    procedure PrintStoreTerminalinPrintXZ(var PosPrintUtility: Codeunit "LSC POS Print Utility")
    var
        Store: Record "LSC Store";
        Terminal: Record "LSC POS Terminal";
        DSTR1: Text[100];
        FieldValue: array[10] of Text[100];
        Globals: Codeunit "LSC POS Session";
    begin
        if Store.Get(Globals.StoreNo()) then begin
            DSTR1 := '#L########## #L###############';
            FieldValue[1] := 'Store Name' + ':';
            FieldValue[2] := Store.Name;
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end;
        if Terminal.Get(Globals.TerminalNo) then
            if Terminal."Statement Method" <> Terminal."Statement Method"::"POS Terminal" then begin
                DSTR1 := '#L########## #L###############';
                FieldValue[1] := 'Terminal' + ':';
                FieldValue[2] := Terminal."No.";
                PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
            end;
    end;

    procedure PrintStaffXZReport(var PosPrintUtility: Codeunit "LSC POS Print Utility"; Staff: Record "LSC Staff"; var FieldValue: array[10] of Text[100]; var DSTR1: Text[80])
    var
        DSTR2: Text[100];
        FieldValue2: array[10] of Text[100];
    begin
        DSTR2 := '#L########## #L###############';
        FieldValue2[1] := 'Staff ID' + ':';
        FieldValue2[2] := Globals.StaffID;
        PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue2, DSTR2), false, true, false, false));
        //Replace Standard FieldValue 
        DSTR1 := '#L######### #L############'; //### Added
        FieldValue[1] := 'Staff Name' + ':';
        FieldValue[2] := Staff."Name on Receipt";
    end;

    procedure PrintCashTotalXZReport(var PosPrintUtility: Codeunit "LSC POS Print Utility"; RunType: Option X,Z,Y; Scode: Code[20]; TerminalNo: Code[10]; StoreNo: Code[10])
    var
        PaymEntry: Record "LSC Trans. Payment Entry";
        TenderType2: Record "LSC Tender Type";
        TenderType: Record "LSC Tender Type";
        POSFunctions: Codeunit "LSC POS Functions";
        CashTotal: Decimal;
        DSTR1: Text[100];
        FieldValue: array[10] of Text[100];
    begin
        PaymEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
        PaymEntry.SetRange("Statement Code", SCode);
        PaymEntry.SetRange("Z-Report ID", '');
        PaymEntry.SetRange("POS Terminal No.", TerminalNo);
        PaymEntry.SetRange(Date, Today);
        if RunType = RunType::Y then
            PaymEntry.SetRange("Y-Report ID", '');

        TenderType.SetCurrentKey("Store No.");
        TenderType.SetRange("Store No.", StoreNo);
        TenderType.SetFilter(TenderType."Function", '<>%1', TenderType."Function"::"Tender Remove/Float");
        TenderType.SetRange("Foreign Currency", false);
        TenderType.SetFilter("Master Tender", '<>%1', ''); //Cash Change will have this defined
        if TenderType.FindSet() then
            repeat
                PaymEntry.SetRange("Tender Type", TenderType.Code);
                PaymEntry.CalcSums("Amount Tendered");
                CashTotal := CashTotal + PaymEntry."Amount Tendered";
                //Add Master Tender Example - Cash
                TenderType2.Reset();
                TenderType2.CopyFilters(TenderType);
                TenderType2.SetRange("Master Tender");
                //TenderType2.SetFilter(Code, TenderType.Code);
                TenderType2.SetFilter(Code, TenderType."Master Tender");
                if TenderType2.FindFirst() then begin
                    PaymEntry.SetRange("Tender Type", TenderType2.Code);
                    PaymEntry.CalcSums("Amount Tendered");
                    CashTotal := CashTotal + PaymEntry."Amount Tendered";
                end;
            until TenderType.Next() = 0;
        if CashTotal <> 0 then begin
            PosPrintUtility.PrintSeperator(2);
            DSTR1 := '#L##########            #R##############';
            FieldValue[1] := 'Cash Total' + ':';
            FieldValue[2] := POSFunctions.FormatAmount(CashTotal);
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
        end;
    end;

    procedure PrintsKashNoOfTransXZReport(var PosPrintUtility: Codeunit "LSC POS Print Utility"; RunType: Option X,Z,Y; Scode: Code[20]; TerminalNo: Code[10]; StoreNo: Code[10])
    var
        PaymEntry: Record "LSC Trans. Payment Entry";
        TenderType: Record "LSC Tender Type";
        POSFunctions: Codeunit "LSC POS Functions";
        sKashQty: Integer;
        DSTR1: Text[100];
        FieldValue: array[10] of Text[100];
    begin
        PaymEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
        PaymEntry.SetRange("Statement Code", SCode);
        PaymEntry.SetRange("Z-Report ID", '');
        PaymEntry.SetRange("POS Terminal No.", TerminalNo);
        PaymEntry.SetRange(Date, Today);
        if RunType = RunType::Y then
            PaymEntry.SetRange("Y-Report ID", '');

        TenderType.SetCurrentKey("Store No.");
        TenderType.SetRange("Store No.", StoreNo);
        TenderType.SetFilter(TenderType."Function", '<>%1', TenderType."Function"::"Tender Remove/Float");
        TenderType.SetRange("Foreign Currency", false);
        TenderType.SetRange("EFT Provider", TenderType."EFT Provider"::sKash);
        if TenderType.FindFirst() then begin
            PaymEntry.SetRange("Tender Type", TenderType.Code);
            sKashQty := PaymEntry.Count();
        end;
        
        if sKashQty <> 0 then begin
            PosPrintUtility.PrintSeperator(2);
            DSTR1 := '#L####################      #R##########';
            FieldValue[1] := TenderType.Description + ' no. of. Trans' + ':';
            FieldValue[2] := POSFunctions.FormatQty(sKashQty);
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
        end;
    end;

    procedure PrintTotalsExtraXZReport(var PosPrintUtility: Codeunit "LSC POS Print Utility"; var Transaction: record "LSC Transaction Header"; RunType: Option X,Z,Y; Scode: Code[20]; TerminalNo: Code[10]; StoreNo: Code[10])
    var
        PaymEntry: Record "LSC Trans. Payment Entry";
        POSTrans: Record "LSC POS Transaction";
        POSVoidedTransLine: Record "LSC POS Voided Trans. Line";
        TenderType: Record "LSC Tender Type";
        Transaction2: Record "LSC Transaction Header";
        NoOfCreditNotes: Integer;
        NoOfOvertender: Integer;
        NoOfVoidedItemLines: Integer;
        DSTR1: Text[100];
        FieldValue: array[10] of Text[100];
    begin
        if (RunType = RunType::Z) OR (RunType = RunType::Y) then begin
            Transaction2.SetCurrentKey("Statement Code", "Z-Report ID", "Transaction Type", "Entry Status", Date);
            Transaction2.SetFilter("Statement Code", '<>%1', SCode);
            Transaction2.SetRange("Z-Report ID", '');
            Transaction2.SetRange("Transaction Type", Transaction."Transaction Type"::Sales);
            Transaction2.SetRange(Date, TODAY);
            Transaction2.SetFilter("Entry Status", '%1|%2', Transaction."Entry Status"::" ", Transaction."Entry Status"::Posted);

            PaymEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date);
            PaymEntry.SetRange("Statement Code", SCode);
            PaymEntry.SetRange("Z-Report ID", '');
            PaymEntry.SetRange(Date, TODAY);

            if RunType = RunType::Y then
                PaymEntry.SetRange("Y-Report ID", '');


            TenderType.SetCurrentKey("Store No.");
            TenderType.SetRange("Store No.", StoreNo);
            TenderType.SetFilter(TenderType."Function", '<>%1', TenderType."Function"::"Tender Remove/Float");
            TenderType.SetRange("Foreign Currency", FALSE);
            if TenderType.FindSet() then
                repeat
                    if (TenderType."Function" <> TenderType."Function"::Card) then begin
                        if (TenderType.Code = '21') then
                            NoOfOvertender := PaymEntry.Count;
                        if (TenderType.Code = '27') then
                            NoOfCreditNotes := PaymEntry.Count;
                    end;
                until TenderType.Next() = 0;

            FieldValue[1] := 'No. Of Overtenders';
            FieldValue[2] := FORMAT(NoOfOvertender, 0, '<Integer>');
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
            FieldValue[1] := 'No. Of Credit Notes';
            FieldValue[2] := FORMAT(NoOfCreditNotes, 0, '<Integer>');
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

            NoOfVoidedItemLines := 0;
            if Transaction2.FindSet() THEN
                repeat
                    POSVoidedTransLine.SetRange("Receipt No.", Transaction2."Receipt No.");
                    NoOfVoidedItemLines += POSVoidedTransLine.Count;
                until Transaction2.NEXT = 0;
            FieldValue[1] := 'No. Of Error Correct';
            FieldValue[2] := Format(NoOfVoidedItemLines, 0, '<Integer>');
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

            POSTrans.SetCurrentKey("Entry Status");
            POSTrans.SetRange("Entry Status", POSTrans."Entry Status"::Suspended);
            POSTrans.SetRange("Trans. Date", TODAY);
            FieldValue[1] := 'No. Of Susp. Trans.';
            FieldValue[2] := Format(POSTrans.Count, 0, '<Integer>');
            PosPrintUtility.PrintLine(2, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end;
    end;

    procedure PrintLoyaltyHeader(var PosPrintUtility: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header")
    var
        Tray: Integer;
        DSTR1: Text[100];
        FieldValue: array[10] of Text[100];
        NodeName: array[32] of Text[50];
    begin
        Tray := 2;
        DSTR1 := '#L######################################';
        PosPrintUtility.PrintLine(Tray, '');
        FieldValue[1] := Text008;
        NodeName[1] := 'Member Info';
        PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
    end;

    procedure PrintLoyaltyStartingPoints(var PosPrintUtility: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        MemberText: Text[100];
        lText011: Label 'Membership Card %1.';
    begin
        if Transaction."Member Card No." <> '' then begin
            MemberText := StrSubstNo(lText011, Transaction."Member Card No.");
            PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(MemberText, false, false, false, false));
        end;
        if Transaction."Starting Point Balance" <> 0 then
            PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(StrSubstNo(Text009, Format(Transaction."Starting Point Balance", 0, '<Integer>')), false, false, false, false));
    end;

    procedure PrintTopupSlip(var PosPrintUtility: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header"; TransSalesEntry: Record "LSC Trans. Sales Entry"; Item: Record Item; CheckIfCopy: Boolean; PrintBuffer: Record "LSC POS Print Buffer" temporary; PrintBufferIndex: Integer; PageNo: Integer; LinesPrinted: Integer; var VoidedVoucher: Boolean): Boolean
    var
        Header: Record "LSC POS Print Setup Header";
        TabSpec: Record "LSC POS Table Spec Print Setup";
        TransTopupEntry: Record "Pos_Trans. Topup Entry_NT";
        DoIt: Boolean;

    begin
        Transaction.Get(TransSalesEntry."Store No.", TransSalesEntry."POS Terminal No.", TransSalesEntry."Transaction No.");
        if CheckIfCopy then
            if Transaction.GetPrintedCounter(1) > 0 then
                exit(true);

        TransTopupEntry.Reset();
        TransTopupEntry.SetRange("Store No.", TransSalesEntry."Store No.");
        TransTopupEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
        TransTopupEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
        TransTopupEntry.SetRange("Trans. Line No.", TransSalesEntry."Line No.");
        TransTopupEntry.SetRange("Transaction Status", TransTopupEntry."Transaction Status"::Completed);
        if not TransTopupEntry.FindFirst() then
            exit(true);

        TabSpec.SetRange(TabSpec."Table No.", DATABASE::Item);
        TabSpec.SetRange(TabSpec.Key, Item."No.");
        if TabSpec.Find('-') then
            repeat
                if Header.Get(TabSpec."Setup ID") then begin
                    DoIt := true;
                    if (TabSpec."When Required" = TabSpec."When Required"::Negative) and
                      (TransSalesEntry.Quantity > 0)
                    then
                        DoIt := false;
                    if (TabSpec."When Required" = TabSpec."When Required"::Positive) and
                      (TransSalesEntry.Quantity < 0)
                    then
                        DoIt := false;
                    if TabSpec."When Required" = TabSpec."When Required"::"Voucher Re-Issue" then
                        DoIt := false;

                    if DoIt then
                        if not PrintTopupSlip2(PosPrintUtility, Transaction, Header, TransTopupEntry, PrintBuffer, PrintBufferIndex, PageNo, LinesPrinted, VoidedVoucher) then
                            exit(false);
                end;
            until TabSpec.Next() = 0;
        exit(true);
    end;

    local procedure PrintTopupSlip2(var PosPrintUtility: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header"; Header: Record "LSC POS Print Setup Header"; TransTopupEntry: Record "Pos_Trans. Topup Entry_NT"; PrintBuffer: Record "LSC POS Print Buffer" temporary; PrintBufferIndex: Integer; PageNo: Integer; LinesPrinted: Integer; var VoidedVoucher: Boolean): Boolean
    var
        Line: Record "LSC POS Print Setup Line";
        TopupSetup: Record "Pos_Topup Setup_NT";
        i: Integer;
        Len: Integer;
        Pos: Integer;
        Tray: Integer;
        DSTR1: Text[50];
        DSTR: Text[50];
        FieldName: array[20] of Text[40];
        FieldValue: array[20] of Text[100];
        TmpStr: Text[100];
    begin

        if Header."Print Type" = Header."Print Type"::"Document print" then begin
            Tray := 4;
            if not PosPrintUtility.OpenReceiptPrinter(2, 'SALES', '', Transaction."Transaction No.", Transaction."Receipt No.") then
                exit(false);

            //BC22 Upgrade Start 

            //PosPrintUtility.InsertPage(Header."Document In Printer");
            PrintBuffer.Init;
            PrintBuffer."Buffer Index" := PrintBufferIndex;
            PrintBuffer."Station No." := 4;
            PrintBuffer."Page No." := PageNo;
            PrintBuffer."Printed Line No." := LinesPrinted;
            PrintBuffer.LineType := PrintBuffer.LineType::InsertPage;
            PrintBuffer.Text := Header."Document In Printer";
            PrintBuffer.Insert;
            PrintBufferIndex += 1;
            //BC 22 Upgrade End
            Len := PosPrintUtility.GetInvLineLen();
        end else
            if Header."Print Type" = Header."Print Type"::"Slip print" then begin
                Tray := 2;
                if not PosPrintUtility.OpenReceiptPrinter(2, 'SALES', '', Transaction."Transaction No.", Transaction."Receipt No.") then
                    exit(false);
                Len := PosPrintUtility.GetLineLen();
            end;

        PrintBuffer.Init();
        PrintBuffer."Buffer Index" := PrintBufferIndex;
        PrintBuffer."Station No." := Tray;
        PrintBuffer."Page No." := PageNo;
        PrintBuffer."Printed Line No." := LinesPrinted;
        PrintBuffer.LineType := PrintBuffer.LineType::Rotation;
        PrintBuffer.Width := Header.Rotation; //NOTE Use Width for Rotation value
        PrintBuffer.Insert();
        PrintBufferIndex += 1;

        if Header."Print Header" then begin
            PosPrintUtility.PrintHeader(Transaction, false, Tray);
            PosPrintUtility.PrintSubHeader(Transaction, Tray, Transaction.Date, Transaction.Time);
        end;

        if Header."Print COPY text on Copies" then
            if (Transaction.GetPrintedCounter(1) > 0) then
                PosPrintUtility.PrintCopyText(Tray);

        if Transaction."Entry Status" = Transaction."Entry Status"::Training then
            PosPrintUtility.PrintTrainingText(Tray);

        if VoidedVoucher then begin
            DSTR1 := '#C##################';
            FieldValue[1] := Text010;
            PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR1), true, false, true, false));
            VoidedVoucher := false;
        end;
        TopupSetup.Get();
        FieldName[1] := ';;date;;';
        FieldValue[1] := Format(TransTopupEntry."Processing Date");
        FieldName[2] := ';;pin;;';
        FieldValue[2] := TransTopupEntry.Pin;
        FieldName[3] := ';;serial;;';
        FieldValue[3] := TransTopupEntry."Serial No.";
        FieldName[4] := ';;merchant;;';
        FieldValue[4] := TopupSetup."Topup Name On Receipt";
        FieldName[5] := ';;cashier;;';
        FieldValue[5] := Transaction."Staff ID";

        Line.SetRange("Setup ID", Header."Setup ID");
        if Line.Find('-') then
            repeat
                case Line.Align of
                    Line.Align::Left:
                        if Line.Wide then
                            DSTR := '#L' + PosPrintUtility.StringPad('#', Round(Len / 2, 1, '<') - 2)
                        else
                            DSTR := '#L' + PosPrintUtility.StringPad('#', Len - 2);
                    Line.Align::Center:
                        if Line.Wide then
                            DSTR := '#C' + PosPrintUtility.StringPad('#', Round(Len / 2, 1, '<') - 2)
                        else
                            DSTR := '#C' + PosPrintUtility.StringPad('#', Len - 2);
                    Line.Align::Right:
                        if Line.Wide then
                            DSTR := '#R' + PosPrintUtility.StringPad('#', Round(Len / 2, 1, '<') - 2)
                        else
                            DSTR := '#R' + PosPrintUtility.StringPad('#', Len - 2);
                end;
                TmpStr := Line.Text;
                for i := 1 to 5 do begin
                    Pos := StrPos(TmpStr, FieldName[i]);
                    if Pos <> 0 then begin
                        if Pos = 1 then
                            TmpStr := FieldValue[i] + CopyStr(TmpStr, Pos + StrLen(FieldName[i]))
                        else
                            TmpStr := CopyStr(TmpStr, 1, Pos - 1) + FieldValue[i] + CopyStr(TmpStr, Pos + StrLen(FieldName[i]));
                    end;
                end;
                if Line.Align < Line.Align::Barcode then begin // NT
                    FieldValue[1] := TmpStr;
                    PosPrintUtility.PrintLine(Tray, PosPrintUtility.FormatLine(PosPrintUtility.FormatStr(FieldValue, DSTR), Line.Wide, Line.Bold, Line.High, Line.Italic));
                    FieldValue[1] := Format(TransTopupEntry."Processing Date");//BC Upgrade
                END;
            until Line.Next() = 0;

        if Header."Print Footer" then
            PosPrintUtility.PrintFooter(Transaction, Tray);

        PrintBuffer.Init();
        PrintBuffer."Buffer Index" := PrintBufferIndex;
        PrintBuffer."Station No." := Tray;
        PrintBuffer."Page No." := PageNo;
        PrintBuffer."Printed Line No." := LinesPrinted;
        PrintBuffer.LineType := PrintBuffer.LineType::Rotation;
        PrintBuffer.Width := Header.Rotation::" "; //NOTE Use Width for Rotation value
        PrintBuffer.Insert();
        PrintBufferIndex += 1;

        if not PosPrintUtility.ClosePrinter(Tray) then
            exit(false);
        exit(true);
    end;

    procedure PrintZReportNonCash(REC: Record "LSC POS Transaction"; DoChecks: Boolean; AskUser: Boolean)
    var
        NoOfUnpostedTrans: Integer;
        NoSuspPOSTransactionsVoided: Integer;
        ZReportConfirmQst: Label 'Are you sure you want to print a Z Report Non Cash?';
    begin
        Store.Get(Globals.StoreNo());
        StoreSetup := Store;
        if PosSetup."Profile ID" = '' then
            PosSetup.Get(Globals.HardwareProfileID);

        if PosTerminal."No." = '' then
            PosTerminal.Get(Globals.TerminalNo);

        if not PrinterActive then
            exit;

        if Globals.StaffID = '' then
            Globals.SetStaff(REC."Staff ID");

        POSPrintUtility.Init();
        //if not POSPrintUtility.IsZReportPrinterReady then begin
        if not POSPrintUtility.IsPrinterReady('TENDER', 'ZXREPORT') then begin
            PosTransCu.ErrorBeep(Posprintutility.GetLastError);
            exit;
        end;

        if DoChecks then begin
            if Globals.StaffID = '' then begin
                PosTransCU.PosMessage(ReportOnlyPrintableFromPosErr);
                exit;
            end;
            if not POSTransCU.TestNewTransaction then
                exit;
            //NoOfUnpostedTrans := PosFunc.POSSalesTransExistInStore(StoreSetup."No.");
            NoOfUnpostedTrans := POSSalesTransExistInStore(StoreSetup."No.");
            if NoOfUnpostedTrans > 0 then begin
                if not POSTransCU.PosConfirm(StrSubstNo(UnpostedTransContinueQst, NoOfUnpostedTrans), false) then
                    exit;
            end;
            //if TrainingActive then begin
            if POSView.GetTrainingMode then begin
                POSTransCU.ErrorBeep(ZReportNotInTrainingErr);
                exit;
            end;
        end;

        if not Globals.Permission("LSC POS Command"::PRINT_Z, InfoTextDescription) then begin
            POSTransCU.ErrorBeep(InfoTextDescription);
            exit;
        end;

        if AskUser then
            if not POSTransCU.PosConfirm(ZReportConfirmQst, false) then
                exit;

        if ZReportNonCashSuspendProcess(NoSuspPOSTransactionsVoided) then begin
            gNoSuspPOSTransactionsVoided := NoSuspPOSTransactionsVoided;
            if not PrintXZReportNonCash(1) then
                POSTransCU.PosMessage(POSPrintUtility.GetLastError);
        end;
    end;

    procedure PrintXZReportNonCash(RunType: Option X,Z,Y): Boolean
    var
        CompanyInformation: Record "Company Information";
        IncExpAccount: Record "LSC Income/Expense Account";
        IncExpEntry2: Record "LSC Trans. Inc./Exp. Entry";
        IncExpEntry: Record "LSC Trans. Inc./Exp. Entry";
        ItemCategory_l: Record "Item Category" temporary;
        PaymTemp: Record "LSC Trans. Payment Entry" temporary;
        PaymTrans2: Record "LSC Trans. Payment Entry";
        PaymTrans3: Record "LSC Trans. Payment Entry";
        POSTransactionSuspend: Record "LSC POS Transaction";
        POSTransactionSuspendMM: Record "LSC POS Transaction";
        POSTransactionSuspendTEMP: Record "LSC POS Transaction" temporary;
        POSTransLineSuspend: Record "LSC POS Trans. Line";
        POSVATCode_l: Record "LSC POS VAT Code" temporary;
        ProductGroup_l: Record "LSC Retail Product Group" temporary;
        Staff: Record "LSC Staff";
        StaffPayment_l: Record "LSC Staff";
        STAFFStoreLink: Record "LSC STAFF Store Link";
        SuspTrans: Record "LSC POS Transaction";
        SuspTransLine: Record "LSC POS Trans. Line";
        TendDeclEntry2: Record "LSC Trans. Tender Declar. Entr";
        Terminal: Record "LSC POS Terminal";
        TipsBufferTmp: Record "LSC Trans. Inc./Exp. Entry" temporary;
        TipsStaff_l: Record "LSC Staff";
        Transaction2: Record "LSC Transaction Header";
        Transaction: Record "LSC Transaction Header";
        TransPaymentStaff_l: Record "LSC Trans. Payment Entry";
        TransServerWorkTable: Record "LSC Trans. Server Work Table";
        YReportStats: Record "LSC POS Y-report statistics";
        ZReportStats: Record "LSC POS Z-report statistics";
        FormatAddress: Codeunit "Format Address";
        POSGUI: Codeunit "LSC POS GUI";
        POSTransaction: Codeunit "LSC POS Transaction";
        TSUtil: Codeunit "LSC POS Trans. Server Utility";
        PrintHeaderLines, LineFound, IsHandled, ReturnValue, CumulateIsHandled : Boolean;
        SCode: Code[20];
        YReportID: Code[10];
        ZReportID: Code[10];
        OldestDate: Date;
        FloatTotal, RemoveTotal, SuspPrepayment, YReportStatsSalesAmount, ZReportStatsSalesAmount, YReportStatsReturnsAmount, ZReportStatsReturnsAmount, ChargedAmount, RefundAmount, TotalSafeType,
SuspendAmount, GrossAmount, TotalSales, VoidedTransactionsAmount : Decimal;
        PosLogAmount: array[6] of Decimal;
        PosLogQuantity: array[6] of Integer;
        RecCount, TransNotSent, NoSuspended, NoSuspPrepayment, TSErr, lSafeType, NoOfLines, NoTables, NoSplitTrans, DiscountQuantity, i, SuspendQuantity, RefundTransCount, ChargedTransCount, TotalAddrLine, AddrLineCount : Integer;
        CompanyAddr: array[8] of Text[100];
        DSTR1: Text[80];
        HeaderText: Text[50];
        lText001: Label 'No of Trans. not on Z-report';
        lText002: Label '    Date of oldest Trans.';
        lText003: Label 'Total Trans not on Z-report';
        lText004: Label 'Unsent WarrHotel entries';
        Text027: Label 'Total Net Sales';
        Text028: Label 'No. of Transactions';
        Text029: Label 'Items Sold';
        Text030: Label 'No. of Refunds';
        Text031: Label 'No. of Suspended';
        Text032: Label 'No. of Voided Transactions';
        Text034: Label 'No. of Training';
        Text035: Label 'Accumulated total Sales';
        Text035_NO: Label 'Grand total Sales';
        Text036: Label 'Accumulated total Returns';
        Text036_NO: Label 'Grand total Returns';
        Text037: Label 'No. of Open Drawer';
        Text038: Label 'Accumulated total Net';
        Text038_NO: Label 'Grand total Net';
        Text039: Label 'Total Sales - Refunds';
        Text080: Label 'VAT Registration No.';
        Text106: Label 'Z-REPORT NON CASH';
        Text107: Label 'X-REPORT NON CASH';
        Text108: Label 'Y-REPORT NON CASH';
        Text112: Label 'Tender declaration:';
        Text116: Label 'Z-Report ID:';
        Text117: Label 'Y-Report ID:';
        Text134: Label 'No. of Paying Customers';
        Text139: Label 'No. of logins';
        Text141: Label 'THIS Z IS FOR TERMINAL %1 ONLY!';
        Text153: Label 'Transaction Server Error';
        Text154: Label 'No. Susp. with Payment';
        Text155: Label 'Suspended Prepayment';
        Text161: Label '%1 Transactions are pending';
        Text230: Label 'System Voided';
        Text235: Label 'No. of Covers';
        Text236: Label 'No. of Split Trans.';
        Text237: Label 'Avg. Covers/Table';
        Text238: Label 'Avg. Paying Cust/Tbl';
        Text240: Label 'Amount';
        Text241: Label 'Price check';
        Text242: Label 'Copy receipts';
        Text243: Label 'Pro forma receipts';
        Text244: Label 'including ,excluding ';
        Text245: Label 'Voided lines';
        Text246: Label 'Open Drawer zero registration';
        Text247: Label 'No. of Delivery Receipts';
        Text248: Label 'Reduced Quantity';
        Text300: Label 'Foreign Currency:';
        Text301: Label 'Local and Foreign:';
        Text320: Label 'Float';
        Text321: Label 'Printed from ';
    begin
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnBeforePrintXZReport(RunType, Transaction, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1, IsHandled, ReturnValue, PrintBuffer.IsFiscalON, PrintBuffer.IsOnlyFiscal, gNoSuspPOSTransactionsVoided);

        PosFuncProfile.Get(Globals.FunctionalityProfileID());
        if IsHandled then
            exit(ReturnValue);

        if not Staff.Get(Globals.StaffID) then
            exit(true);
        if not Terminal.Get(Globals.TerminalNo) then
            exit(true);

        if not POSPrintUtility.OpenReceiptPrinter(2, 'TENDER', 'ZXREPORT', 0, '') then
            exit(false);

        // if PrintBuffer.IsFiscalON then begin
        //     PrintBuffer.FiscalPrintXZReport(RunType);
        //     if PrintBuffer.IsOnlyFiscal then
        //         exit(PrintBuffer.ClosePrinter(2));
        // end;

        if not Terminal."Terminal Statement" then
            Terminal."Statement Method" := Store."Statement Method";

        //Print Header info
        DSTR1 := '#L######## #L#########';
        FieldValue[1] := Text078 + ':';
        FieldValue[2] := Store."No.";
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnBeforePrintTerminalInfoXZReport(RunType, Transaction, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1, IsHandled, ReturnValue);
        //if not IsHandled then begin
        //if FisPOSCommand.IsNOLocalizationEnabled then begin
        if IsNOLocalizationEnabled then begin
            DSTR1 := '#L###################   #L##########';
            FieldValue[1] := Text321 + Text079 + ':';
            FieldValue[2] := Terminal."No.";
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end else
            if Terminal."Statement Method" = Terminal."Statement Method"::"POS Terminal" then begin
                DSTR1 := '#L####### #L########';
                FieldValue[1] := Text079 + ':';
                FieldValue[2] := Terminal."No.";
                POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
            end;
        //end;
        CompanyInformation.Get;
        if CompanyInformation."VAT Registration No." <> '' then begin
            DSTR1 := '#L#################   #L##############';
            FieldValue[1] := Text080 + ':';
            FieldValue[2] := CompanyInformation."VAT Registration No.";
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end;

        //if FisPOSCommand.IsNOLocalizationEnabled then begin
        if IsNOLocalizationEnabled then begin
            FormatAddress.Company(CompanyAddr, CompanyInformation);
            TotalAddrLine := CompressArray(CompanyAddr);
            DSTR1 := CopyStr('#L################################################', 1, POSPrintUtility.GetLineLen());
            for AddrLineCount := 1 to TotalAddrLine do begin
                FieldValue[1] := CopyStr(CompanyAddr[AddrLineCount], 1, 80);
                NodeName[1] := StrSubstNo('Company Address %1', i);
                //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
            end;
            POSPrintUtility.PrintSeperator(2);
        end;

        //SCode := POSFunctions.GetStatementCode;

        PosTerminal.Get(Globals.TerminalNo());
        SCode := GetStatementCode;


        Transaction.Date := Today;
        Transaction.Time := Time;
        POSPrintUtility.PrintLogo(2);
        POSPrintUtility.PrintHeader(Transaction, false, 2);

        DSTR1 := '#L#### #T###### #T#### ';
        FieldValue[1] := Text048 + ':';
        FieldValue[2] := Format(Today());
        FieldValue[3] := Format(Time(), 5);
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        DSTR1 := '#L###### #L############';
        FieldValue[1] := Text051 + ':';
        if Staff."Name on Receipt" <> '' then
            FieldValue[2] := Staff."Name on Receipt"
        else
            FieldValue[2] := Globals.StaffID;

        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        POSPrintUtility.PrintSeperator(2);

        //X or Z Report..
        DSTR1 := '#C##################';

        case RunType of
            RunType::Z:
                FieldValue[1] := Text106;
            RunType::X:
                FieldValue[1] := Text107;
            RunType::Y:
                FieldValue[1] := Text108;
        end;
        //PrintBuffer.PrintLineWide(2, FieldValue, DSTR1, true, true, true, false);

        PrintLineWide(POSPrintUtility, 2, FieldValue, DSTR1, true, true, true, false);
        if PosFuncProfile."TS Floating Cashier" and
           (Terminal."Statement Method" = Terminal."Statement Method"::Staff) and
           (Globals.GetValue("LSC POS Tag"::"TS_ERROR") <> '') then begin
            //PrintBuffer.PrintLineFeed(2);
            PrintLineFeed(POSPrintUtility, 2, 1);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(StrSubstNo(Text141, Terminal."No."), false, true, false, false));
        end;

        POSPrintUtility.PrintSeperator(2);

        // Report Body
        //  Line per Tender Type
        Clear(PaymEntry);
        PaymEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
        PaymEntry.SetRange("Statement Code", SCode);
        //PaymEntry.SetRange("Z-Report ID", '');
        PaymEntry.SetRange("POS Terminal No.", Terminal."No.");
        // if RunType = RunType::Y then
        //     PaymEntry.SetRange("Y-Report ID", '');
        //PrintUtilPublic.OnAfterPaymentEntrySetFiltersXZReport_NT(PaymEntry);//NT    
        PaymEntry.SetRange(Date, Today);//NT
        PaymTrans3.CopyFilters(PaymEntry);

        TenderType.SetCurrentKey("Store No.");
        TenderType.SetRange("Store No.", Globals.StoreNo);
        TenderType.SetFilter(TenderType."Function", '<>%1', TenderType."Function"::"Tender Remove/Float");
        TenderType.SetRange("Foreign Currency", false);
        Tendertype.SetRange("Exclude in Z Report_NC", false);
        LocalTotal := 0;
        //POSPrintUtility.PrintXZLines('');
        PrintXZLines('');
        //PrintUtilPublic.OnBeforeTotalLCYPrintXZReport_NT(RunType, Scode, Terminal."No.", Globals.StoreNo);//NT
        //  Totals for LCY
        if LocalTotal <> 0 then begin
            POSPrintUtility.PrintSeperator(2);
            DSTR1 := '#L########              #R##############';
            FieldValue[1] := Text005 + ':';
            FieldValue[2] := POSFunctions.FormatAmount(LocalTotal);
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end;

        IsHandled := false;
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnPrintXZReport_OnBeforePrintPaymentStaff(RunType, Transaction, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1, IsHandled, ReturnValue);
        if not IsHandled then
            if Terminal."Statement Method" <> Terminal."Statement Method"::Staff then begin
                LocalTotal := 0;
                if StaffPayment_l.FindSet then
                    repeat
                        STAFFStoreLink.SetRange("Staff ID", StaffPayment_l.ID);
                        STAFFStoreLink.SetRange("Store No.", Globals.StoreNo());
                        if (StaffPayment_l."Store No." = '') or (StaffPayment_l."Store No." = Globals.StoreNo()) or (not STAFFStoreLink.IsEmpty) then begin
                            TransPaymentStaff_l.SetCurrentKey("Staff ID", "Tender Decl. ID", "Tender Type", "Currency Code");
                            TransPaymentStaff_l.SetRange("Staff ID", StaffPayment_l.ID);
                            TransPaymentStaff_l.SetRange("Statement Code", SCode);
                            //TransPaymentStaff_l.SetRange("Z-Report ID", '');
                            TransPaymentStaff_l.SetRange(Date, Today);//NT
                            // if RunType = RunType::Y then
                            //     TransPaymentStaff_l.SetRange("Y-Report ID", '');
                            if not TransPaymentStaff_l.IsEmpty then begin
                                POSPrintUtility.PrintSeperator(2);
                                Clear(FieldValue);
                                DSTR1 := '#L######################################';
                                FieldValue[1] := Text051 + StaffPayment_l.ID;
                                //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
                                POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                                //POSPrintUtility.PrintXZLines(StaffPayment_l.ID);
                                PrintXZLines(StaffPayment_l.ID);
                            end;
                        end;
                    until StaffPayment_l.Next = 0;
                PaymEntry.SetRange("Staff ID");
            end;

        //  Totals for FCY
        //PrintBuffer.PrintLineFeed(2);
        PrintLineFeed(POSPrintUtility, 2, 1);
        TenderType.SetRange("Foreign Currency", true);

        TotalLCYInCurrency := 0;
        //POSPrintUtility.PrintXZLines('');
        PrintXZLines('');
        if TotalLCYInCurrency <> 0 then begin
            POSPrintUtility.PrintSeperator(2);
            DSTR1 := '#L##################### #R##############';
            FieldValue[1] := Text300;
            FieldValue[2] := POSFunctions.FormatAmount(TotalLCYInCurrency);
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
            //PrintBuffer.PrintLineFeed(2);
            PrintLineFeed(POSPrintUtility, 2, 1);
            POSPrintUtility.PrintSeperator(2);
            DSTR1 := '#L##################### #R##############';
            FieldValue[1] := Text301;
            FieldValue[2] := POSFunctions.FormatAmount(LocalTotal);
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
            POSPrintUtility.PrintSeperator(2);
        end;

        //  Floating and Removal Totals
        TenderType.SetRange("Foreign Currency");
        TenderType.SetRange(TenderType."Function", TenderType."Function"::"Tender Remove/Float");
        if TenderType.FindSet() then begin
            POSPrintUtility.PrintSeperator(2);
            repeat
                for lSafeType := 0 to 3 do begin
                    NoOfLines := 0;
                    TotalSafeType := 0;
                    PaymEntry.SetRange("Safe type", lSafeType);
                    PaymEntry.SetRange("Currency Code");
                    PaymEntry.SetRange("Card No.");
                    PaymEntry.SetRange("Tender Type", TenderType.Code);
                    if PaymEntry.FindSet() then
                        repeat
                            if NoOfLines = 0 then begin
                                if lSafeType = 0 then
                                    HeaderText := Text320
                                else
                                    HeaderText := Format(PaymEntry."Safe type");
                                DSTR1 := '#C######################################';
                                FieldValue[1] := HeaderText;
                                //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                                POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                            end;
                            NoOfLines := NoOfLines + 1;
                            Transaction.Get(PaymEntry."Store No.", PaymEntry."POS Terminal No.", PaymEntry."Transaction No.");
                            if PaymEntry."Amount Tendered" > 0 then begin
                                RemoveTotal := RemoveTotal + PaymEntry."Amount Tendered";
                                DSTR1 := '#L############## #L###### #R############';
                                FieldValue[1] := StrSubstNo('%1', Transaction."Transaction Type");
                                FieldValue[2] := Transaction."Staff ID";
                                FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                                //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                                POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                            end
                            else begin
                                FloatTotal := FloatTotal + PaymEntry."Amount Tendered";
                                DSTR1 := '#L############## #L###### #R############';
                                FieldValue[1] := StrSubstNo('%1', Transaction."Transaction Type");
                                FieldValue[2] := Transaction."Staff ID";
                                FieldValue[3] := POSFunctions.FormatAmount(-PaymEntry."Amount Tendered");
                                //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                                POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                            end;
                            if Store."Safe Mgnt. in Use" then
                                TotalSafeType := TotalSafeType + PaymEntry."Amount Tendered"
                            else
                                TotalSafeType := TotalSafeType - PaymEntry."Amount Tendered";
                            LineFound := true;
                        until PaymEntry.Next = 0;
                    if NoOfLines > 0 then begin
                        if NoOfLines > 1 then begin
                            //PrintBuffer.PrintLineFeed(2);
                            PrintLineFeed(POSPrintUtility, 2, 1);
                            DSTR1 := '#L############## #L###### #R############';
                            FieldValue[1] := Text005;
                            FieldValue[2] := '';
                            FieldValue[3] := POSFunctions.FormatAmount(TotalSafeType);
                            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                            POSPrintUtility.PrintSeperator(2);
                        end
                        else
                            POSPrintUtility.PrintSeperator(2);
                    end;
                end;
            until TenderType.Next = 0;
        end;
        PaymEntry.SetRange("Safe type");

        if FloatTotal <> 0 then begin
            DSTR1 := '#L##############    #R##################';
            FieldValue[1] := Text009 + ':';
            FieldValue[2] := POSFunctions.FormatAmount(-FloatTotal);
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
        end;

        if RemoveTotal <> 0 then begin
            DSTR1 := '#L##############    #R##################';
            FieldValue[1] := Text010 + ':';
            FieldValue[2] := POSFunctions.FormatAmount(RemoveTotal);
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
        end;

        if (LocalTotal <> 0) or (FloatTotal <> 0) or (RemoveTotal <> 0) then
            POSPrintUtility.PrintSeperator(2);

        //  Tender Declaration
        Transaction."Transaction No." := 0;
        TendDeclEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
        TendDeclEntry.SetRange("Statement Code", SCode);
        TendDeclEntry.SetRange(Date, Today);
        // TendDeclEntry.SetRange("Z-Report ID", '');
        // if RunType = RunType::Y then
        //     TendDeclEntry.SetRange("Y-Report ID", '')
        // else
        //     TendDeclEntry.SetRange("Y-Report ID");
        if Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Sum then begin
            BufferTendDeclEntry;
            if TendDeclEntry.Findfirst() then
                Transaction."Transaction No." := TendDeclEntry."Transaction No.";
        end else begin
            if TendDeclEntry.FindSet() then
                repeat
                    if TendDeclEntry."Transaction No." > Transaction."Transaction No." then
                        Transaction.Get(TendDeclEntry."Store No.", TendDeclEntry."POS Terminal No.", TendDeclEntry."Transaction No.")
                until TendDeclEntry.Next = 0;
        end;

        if Transaction."Transaction No." <> 0 then begin
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(Text112, false, true, false, false));
            Clear(TendDeclEntry);
            LocalTotal := 0;
            if Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Last then begin
                TendDeclEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.");
                TendDeclEntry.SetRange("Store No.", Transaction."Store No.");
                TendDeclEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                TendDeclEntry.SetRange("Transaction No.", Transaction."Transaction No.");
                BufferTendDeclEntry;
            end;
            TempTendDeclEntry.SetFilter("Currency Code", '=%1', '');
            PrintTenderDeclLines(POSPrintUtility);
            PrintCashDeclTotalLCYLine(POSPrintUtility, LocalTotal);
            //PrintBuffer.PrintLineFeed(2);
            PrintLineFeed(POSPrintUtility, 2, 1);
            TempTendDeclEntry.SetFilter("Currency Code", '<>%1', '');
            PrintTenderDeclLines(POSPrintUtility);
        end;

        POSPrintUtility.PrintSeperator(2);

        // Sales and Discount Totals
        Transaction.SetCurrentKey("Statement Code", "Z-Report ID", "Transaction Type", "Entry Status");
        Transaction.SetRange("Statement Code", SCode);
        //Transaction.SetRange("Z-Report ID", '');
        Transaction.SetRange("Transaction Type", Transaction."Transaction Type"::Sales);
        Transaction.SetFilter("Entry Status", '%1|%2', Transaction."Entry Status"::" ", Transaction."Entry Status"::Posted);
        Transaction.setrange("Sale Is Return Sale", true);
        Transaction.SetRange(Date, Today);//NT
        // if RunType = RunType::Y then
        //     Transaction.SetRange("Y-Report ID", '');
        //PrintUtilPublic.OnAfterTransactionSetFiltersXZReport_NT(Transaction);//NT
        Transaction.CalcSums("Gross Amount", Rounded);
        if Transaction."Entry Status" <> Transaction."Entry Status"::Training then begin
            case RunType of
                RunType::Z:
                    ZReportStatsReturnsAmount := Transaction."Gross Amount" + Transaction.Rounded;
                RunType::Y:
                    YReportStatsReturnsAmount := Transaction."Gross Amount" + Transaction.Rounded;
            end;
        end;

        Transaction.SetRange("Sale Is Return Sale", false);
        Transaction.CalcSums("Gross Amount", Rounded);
        if Transaction."Entry Status" <> Transaction."Entry Status"::Training then begin
            case RunType of
                RunType::Z:
                    ZReportStatsSalesAmount := -Transaction."Gross Amount" + Transaction.Rounded;
                RunType::Y:
                    YReportStatsSalesAmount := -Transaction."Gross Amount" + Transaction.Rounded;
            end;
        end;

        Transaction.SetRange("Sale Is Return Sale");
        Transaction.CalcSums("Gross Amount", "Discount Amount", "Total Discount", Rounded, "No. of Items", "No. of Covers", "Net Amount");

        ProductGroup_l.DeleteAll;
        CountDetails(SCode, PosLogQuantity, PosLogAmount, DiscountQuantity, ItemCategory_l, ProductGroup_l, POSVATCode_l, VoidedTransactionsAmount);

        DSTR1 := '#L######################### #R##########';
        FieldValue[1] := Text011;
        FieldValue[2] := POSFunctions.FormatAmount(-Transaction."Gross Amount" + Transaction."Discount Amount");
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));

        DSTR1 := '#L#################### #R## #R##########';
        FieldValue[1] := Text012;
        FieldValue[2] := Format(DiscountQuantity, 0, '<Integer>');
        FieldValue[3] := POSFunctions.FormatAmount(-Transaction."Discount Amount");
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
        DSTR1 := '#L######################### #R##########';

        FieldValue[2] := POSFunctions.FormatAmount(Transaction.Rounded);
        FieldValue[1] := Text093;
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));

        TotalSales := -Transaction."Gross Amount" + Transaction.Rounded;
        POSPrintUtility.PrintSeperator(2);
        FieldValue[1] := Text027;
        FieldValue[2] := POSFunctions.FormatAmount(TotalSales);
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));

        POSPrintUtility.PrintSeperator(2);
        //if (LocalizationExt.IsNALocalizationEnabled) then
        //    FieldValue[1] := Text005 + ' ' + SelectStr(1, Text244) + Text063_Tax
        //else
        FieldValue[1] := Text005 + ' ' + SelectStr(1, Text244) + Text063;
        FieldValue[2] := POSFunctions.FormatAmount(TotalSales);
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        if POSVATCode_l.FindSet then
            repeat
                FieldValue[1] := POSVATCode_l.Description;
                FieldValue[2] := POSFunctions.FormatAmount(POSVATCode_l."VAT %");
                //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
            until POSVATCode_l.Next = 0;

        //if (LocalizationExt.IsNALocalizationEnabled) then
        //FieldValue[1] := Text005 + SelectStr(2, Text244) + Text063_Tax
        //else
        FieldValue[1] := Text005 + SelectStr(2, Text244) + Text063;
        FieldValue[2] := POSFunctions.FormatAmount(-Transaction."Net Amount");
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));

        POSPrintUtility.PrintSeperator(2);
        //PrintBlankLine(2);
        POSPrintUtility.PrintBlankLine(2);

        IsHandled := true;//Nt
        //PrintUtilPublic.OnPrintXZReport_OnBeforePrintItemCategory(ItemCategory_l, IsHandled);
        if not IsHandled then
            if ItemCategory_l.FindSet then
                repeat
                    FieldValue[1] := ItemCategory_l.Code;
                    FieldValue[2] := POSFunctions.FormatAmount(-ItemCategory_l."LSC Difference (LCY)");
                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                    POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                until ItemCategory_l.Next = 0;
        IsHandled := false;//NT
        IncExpAccount.SetRange(IncExpAccount."Store No.", Globals.StoreNo);
        if IncExpAccount.FindSet() then begin
            //if LocalizationExt.IsNALocalizationEnabled then
            //    TipsBufferTmp.DeleteAll;
            IncExpEntry.SetCurrentKey("Statement Code", "Z-Report ID", "No.");
            IncExpEntry.SetRange("Statement Code", SCode);
            // IncExpEntry.SetRange("Z-Report ID", '');
            // if RunType = RunType::Y then
            //     IncExpEntry.SetRange("Z-Report ID", '');
            //PrintUtilPublic.OnAfterIncExpEntrySetFiltersXZReport_NT(IncExpEntry);//NT    
            IncExpEntry.SetRange(Date, Today);//NT
            if IncExpEntry.FindFirst() then begin
                POSPrintUtility.PrintSeperator(2);
                repeat
                    IncExpEntry.SetRange("No.", IncExpAccount."No.");
                    if IncExpEntry.Findfirst() then begin
                        FieldValue[1] := IncExpAccount.Description;
                        IncExpEntry.CalcSums(Amount);
                        FieldValue[2] := POSFunctions.FormatAmount(-IncExpEntry.Amount);
                        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                        if (IncExpAccount."Gratuity Type" = IncExpAccount."Gratuity Type"::Tips) and
                          (IncExpAccount."Account Type" = IncExpAccount."Account Type"::Expense)
                        then
                            BufferTipsInfo(TipsBufferTmp, IncExpEntry);
                    end;
                until IncExpAccount.Next = 0;
            end;
        end;

        POSPrintUtility.PrintSeperator(2);

        //Transaction counting
        DSTR1 := '#L#################### #R######## #R####';
        FieldValue[1] := '';
        FieldValue[2] := Text240;
        FieldValue[3] := Text160;
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        if PaymTrans3.FindSet() then
            repeat
                if not PaymTemp.Get(PaymTrans3."Store No.", PaymTrans3."POS Terminal No.", PaymTrans3."Transaction No.") then begin
                    Transaction2.Get(PaymTrans3."Store No.", PaymTrans3."POS Terminal No.", PaymTrans3."Transaction No.");
                    if Transaction2."Transaction Type" = Transaction2."Transaction Type"::Sales then
                        RecCount := RecCount + 1;
                    PaymTemp."Store No." := PaymTrans3."Store No.";
                    PaymTemp."POS Terminal No." := PaymTrans3."POS Terminal No.";
                    PaymTemp."Transaction No." := PaymTrans3."Transaction No.";
                    PaymTemp.Insert;
                end;
            until PaymTrans3.Next = 0;
        FieldValue[1] := Text134 + ':';
        FieldValue[2] := ' ';
        FieldValue[3] := Format(RecCount);
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        FieldValue[1] := Text028;
        FieldValue[3] := Format(Transaction.Count, 0, '<Integer>');
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        //PrintUtilPublic.OnAfterPrintNoOfTransactionsXZReport_NT(Transaction, RunType, Scode, Terminal."No.", Globals.StoreNo());//NT
        FieldValue[1] := Text029;
        FieldValue[3] := Format(Transaction."No. of Items", 0, '<Integer>');
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        Transaction.SetRange(Transaction."Sale Is Return Sale", true);

        //if FisPOSCommand.IsNOLocalizationEnabled then begin
        if IsNOLocalizationEnabled then begin
            Transaction.CalcSums("Gross Amount", "Reverted Gross Amount");
            RefundTransCount := Transaction.Count;
            RefundAmount := Transaction."Gross Amount" - Transaction."Reverted Gross Amount";
            Transaction.SetRange(Transaction."Sale Is Return Sale", false);
            Transaction.SetRange("Trans. Is Mixed Sale/Refund", true);
            Transaction.CalcSums("Reverted Gross Amount");
            RefundTransCount += Transaction.Count;
            RefundAmount += Transaction."Reverted Gross Amount";
        end else
            Transaction.CalcSums("Gross Amount");
        FieldValue[1] := Text030;

        //if FisPOSCommand.IsNOLocalizationEnabled then begin
        if IsNOLocalizationEnabled then begin
            FieldValue[2] := POSFunctions.FormatAmount(RefundAmount);
            FieldValue[3] := Format(RefundTransCount, 0, '<Integer>');
        end else begin
            RefundAmount := Transaction."Gross Amount";
            FieldValue[2] := POSFunctions.FormatAmount(RefundAmount);
            FieldValue[3] := Format(Transaction.Count, 0, '<Integer>');
        end;
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        Transaction.SetRange(Transaction."Sale Is Return Sale");
        //if FisPOSCommand.IsNOLocalizationEnabled then
        if IsNOLocalizationEnabled then
            Transaction.SetRange("Trans. Is Mixed Sale/Refund");

        //if FisPOSCommand.IsNOLocalizationEnabled then begin
        if IsNOLocalizationEnabled then begin
            Transaction.SetRange("To Account", true);
            Transaction.CalcSums("Gross Amount");
            ChargedTransCount := Transaction.Count;
            ChargedAmount := -Transaction."Gross Amount";
            FieldValue[1] := Text247;
            FieldValue[2] := POSFunctions.FormatAmount(ChargedAmount);
            FieldValue[3] := Format(ChargedTransCount, 0, '<Integer>');
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
            Transaction.SetRange("To Account");
        end;

        CountSuspended(SuspendQuantity, SuspendAmount);
        FieldValue[1] := Text031;
        FieldValue[2] := POSFunctions.FormatAmount(SuspendAmount);
        FieldValue[3] := Format(SuspendQuantity, 0, '<Integer>');
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        SuspTrans.SetRange("Store No.");
        FieldValue[2] := ' ';

        if RunType = RunType::Z then begin
            if Terminal."Print Suspend with Prepayment" then begin
                NoSuspPrepayment := 0;
                SuspPrepayment := 0;

                SuspTransLine.Reset;
                SuspTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
                SuspTransLine.SetRange("Entry Type", SuspTransLine."Entry Type"::IncomeExpense);
                if SuspTransLine.FindSet() then begin
                    repeat
                        if (SuspTransLine."POS Terminal No." = '0') then begin
                            NoSuspPrepayment := NoSuspPrepayment + 1;
                            SuspPrepayment := SuspPrepayment + SuspTransLine.Amount;
                        end;
                    until SuspTransLine.Next = 0;
                end;
                SuspPrepayment := Abs(SuspPrepayment);
                if (NoSuspPrepayment > 0) then begin
                    FieldValue[1] := '  ' + Text154;
                    FieldValue[3] := Format(NoSuspPrepayment, 0, '<Integer>');
                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
                    POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                end;
                if (SuspPrepayment > 0) then begin
                    FieldValue[1] := '  ' + Text155;
                    FieldValue[3] := POSFunctions.FormatAmount(SuspPrepayment);
                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
                    POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                end;
            end;
        end;

        if RunType = RunType::Y then begin
            if Terminal."Print Suspend with Prepayment" then begin
                NoSuspPrepayment := 0;
                SuspPrepayment := 0;

                SuspTransLine.Reset;
                SuspTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
                SuspTransLine.SetRange("Entry Type", SuspTransLine."Entry Type"::IncomeExpense);
                if SuspTransLine.FindSet() then begin
                    repeat
                        if (SuspTransLine."POS Terminal No." = '0') then begin
                            NoSuspPrepayment := NoSuspPrepayment + 1;
                            SuspPrepayment := SuspPrepayment + SuspTransLine.Amount;
                        end;
                    until SuspTransLine.Next = 0;
                end;
                SuspPrepayment := Abs(SuspPrepayment);
                if (NoSuspPrepayment > 0) then begin
                    FieldValue[1] := '  ' + Text154;
                    FieldValue[3] := Format(NoSuspPrepayment, 0, '<Integer>');
                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
                    POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                end;
                if (SuspPrepayment > 0) then begin
                    FieldValue[1] := '  ' + Text155;
                    FieldValue[3] := POSFunctions.FormatAmount(SuspPrepayment);
                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
                    POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                end;
            end;
        end;

        Transaction.SetRange("Entry Status", Transaction."Entry Status"::Voided);
        FieldValue[1] := Text032;
        FieldValue[2] := POSFunctions.FormatAmount(VoidedTransactionsAmount);
        FieldValue[3] := Format(Transaction.Count, 0, '<Integer>');
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        Clear(FieldValue[2]);

        if gNoSuspPOSTransactionsVoided <> 0 then begin
            FieldValue[1] := '  ' + Text230;
            FieldValue[3] := Format(gNoSuspPOSTransactionsVoided, 0, '<Integer>');
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end;

        Transaction.SetRange("Entry Status", Transaction."Entry Status"::Training);
        FieldValue[1] := Text034;
        FieldValue[3] := Format(Transaction.Count, 0, '<Integer>');
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        Transaction.SetRange("Entry Status");

        Transaction.SetFilter("Transaction Type", '%1|%2',
          Transaction."Transaction Type"::Sales, Transaction."Transaction Type"::"Open Drawer");
        Transaction.SetRange("Open Drawer", true);
        FieldValue[1] := Text037;
        FieldValue[3] := Format(Transaction.Count, 0, '<Integer>');
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        Transaction.SetRange("Open Drawer");

        Transaction.SetRange("Transaction Type", Transaction."Transaction Type"::Logon);
        FieldValue[1] := Text139;
        FieldValue[3] := Format(Transaction.Count, 0, '<Integer>');
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        Transaction.SetRange("Transaction Type");

        Transaction.SetRange("Sale Is Return Sale", false);

        if Transaction."No. of Covers" <> 0 then begin
            FieldValue[1] := Text235;
            FieldValue[3] := Format(Transaction."No. of Covers", 0, '<Integer>');
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

            Transaction.SetFilter("Split Number", '<>%1', 0);
            NoSplitTrans := Transaction.Count;
            FieldValue[1] := Text236;
            FieldValue[3] := Format(NoSplitTrans, 0, '<Integer>');
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
            Transaction.SetRange("Split Number");

            NoTables := RecCount - NoSplitTrans;

            FieldValue[1] := Text237;
            FieldValue[3] := FORMAT(ROUND(Transaction."No. of Covers" / NoTables, 0.1));
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

            FieldValue[1] := Text238;
            FieldValue[3] := FORMAT(ROUND(RecCount / NoTables, 0.1));
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end;

        Transaction.SetRange("Sale Is Return Sale");

        for i := 1 to 6 do begin
            case i of
                1:
                    FieldValue[1] := Text241;
                2:
                    FieldValue[1] := Text242;
                3:
                    FieldValue[1] := Text243;
                4:
                    FieldValue[1] := Text245;
                5:
                    FieldValue[1] := Text246;
                6:
                    FieldValue[1] := Text248;
            end;
            FieldValue[2] := POSFunctions.FormatAmount(PosLogAmount[i]);
            FieldValue[3] := Format(PosLogQuantity[i], 0, '<Integer>');
            if PosLogQuantity[i] <> 0 then
                //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
                POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

            if (i = 1) and (PosLogQuantity[1] <> 0) then begin
                ProductGroup_l.Reset;
                if ProductGroup_l.FindSet then
                    repeat
                        DSTR1 := '   #L############## #R###########';
                        FieldValue[1] := ProductGroup_l.Code;
                        FieldValue[2] := POSFunctions.FormatAmount(ProductGroup_l."Default Profit %");
                        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
                    until ProductGroup_l.Next = 0;
                DSTR1 := '#L#################### #R######## #R####';
            end;
        end;

        //if FisPOSCommand.IsNOLocalizationEnabled then begin
        if IsNOLocalizationEnabled then begin
            FieldValue[1] := Text039;
            FieldValue[2] := POSFunctions.FormatAmount(TotalSales - RefundAmount);
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end;

        DSTR1 := '#L######################### #R##########';
        TipsBufferTmp.Reset;
        if TipsBufferTmp.Count > 0 then
            PrintTipsInfo(TipsBufferTmp, 1);  //0 = Tips In, 1 = Tips out

        // if RunType = RunType::Z then begin
        //     if Terminal."Statement Method" = Terminal."Statement Method"::"POS Terminal" then begin
        //         if Terminal."Last Z-Report" <> '' then
        //             Terminal."Last Z-Report" := IncStr(Terminal."Last Z-Report")
        //         else
        //             Terminal."Last Z-Report" := 'T000000001';
        //         ZReportID := Terminal."Last Z-Report";
        //     end else begin
        //         if Staff."Last Z-Report" <> '' then
        //             Staff."Last Z-Report" := IncStr(Staff."Last Z-Report")
        //         else
        //             Staff."Last Z-Report" := 'S000000001';
        //         ZReportID := Staff."Last Z-Report";
        //     end;
        //     if (Globals.GetValue("LSC POS Tag"::"TS_ERROR") <> '') then
        //         ZReportID := 'X' + CopyStr(ZReportID, 2);
        //     POSPrintUtility.PrintSeperator(2);
        //     POSPrintUtility.PrintLine(2, Text116 + ZReportID);
        //     POSPrintUtility.PrintSeperator(2);
        // end;

        // if RunType = RunType::Y then begin
        //     if Terminal."Statement Method" = Terminal."Statement Method"::"POS Terminal" then begin
        //         if Terminal."Last Y-Report" <> '' then
        //             Terminal."Last Y-Report" := IncStr(Terminal."Last Y-Report")
        //         else
        //             Terminal."Last Y-Report" := 'T000000001';
        //         YReportID := Terminal."Last Y-Report";
        //     end else begin
        //         if Staff."Last Y-Report" <> '' then
        //             Staff."Last Y-Report" := IncStr(Staff."Last Y-Report")
        //         else
        //             Staff."Last Y-Report" := 'S000000001';
        //         YReportID := Staff."Last Y-Report";
        //     end;
        //     if (Globals.GetValue("LSC POS Tag"::"TS_ERROR") <> '') then
        //         YReportID := 'X' + CopyStr(YReportID, 2);
        //     POSPrintUtility.PrintSeperator(2);
        //     POSPrintUtility.PrintLine(2, Text117 + YReportID);
        //     POSPrintUtility.PrintSeperator(2);
        // end;


        if RunType = RunType::X then begin
            if PosFuncProfile."TS Send Transactions" then begin
                TransServerWorkTable.Reset;
                TransServerWorkTable.SetRange(Table, Database::"LSC Transaction Header");
                TransServerWorkTable.SetRange("Store No.", Globals.StoreNo);
                TransServerWorkTable.SetRange("POS Terminal No.", Globals.TerminalNo);
                TransNotSent := TransServerWorkTable.Count;
                if TransNotSent > 0 then begin
                    POSPrintUtility.PrintSeperator(2);
                    Clear(FieldValue);
                    DSTR1 := '#L######################################';
                    FieldValue[1] := Text153;
                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);                    
                    POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    FieldValue[1] := StrSubstNo(Text161, TransNotSent);
                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                    POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    POSPrintUtility.PrintSeperator(2);
                end;
            end;
        end;

        //PrintUtilPublic.OnBeforeCumulateSales(RunType, CumulateIsHandled);

        // if not CumulateIsHandled then begin
        //     if (RunType = RunType::Z) or (RunType = RunType::Y) then begin
        //         DSTR1 := '#L##################### #R##############';
        //         //if not FisPOSCommand.IsNOLocalizationEnabled then
        //         //    FieldValue[1] := Text035
        //         //else
        //         FieldValue[1] := Text035_NO;

        //         if RunType = RunType::Y then begin
        //             YReportStats.Reset;
        //             YReportStats.SetRange("Store No.", Globals.StoreNo);
        //             YReportStats.SetRange("POS Terminal No.", Globals.TerminalNo);
        //             if YReportStats.FindLast then begin
        //                 GrossAmount := (YReportStats."Cumulative Sales Amount" + YReportStatsSalesAmount) + (YReportStats."Cumulative Returns Amount" + YReportStatsReturnsAmount);
        //                 FieldValue[2] := POSFunctions.FormatAmount(GrossAmount);
        //                 //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        //                 POSPrintUtility.PrintLine(2,POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        //                 FieldValue[1] := Text036;
        //                 FieldValue[2] := POSFunctions.FormatAmount(YReportStats."Cumulative Returns Amount" + YReportStatsReturnsAmount);
        //                 //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        //                 POSPrintUtility.PrintLine(2,POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        //                 FieldValue[1] := Text038;
        //                 FieldValue[2] := POSFunctions.FormatAmount(YReportStats."Cumulative Sales Amount" + YReportStatsSalesAmount);
        //                 //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        //                 POSPrintUtility.PrintLine(2,POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        //             end else begin
        //                 FieldValue[2] := POSFunctions.FormatAmount(0);
        //                 //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        //                 POSPrintUtility.PrintLine(2,POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        //             end;
        //         end else begin
        //             ZReportStats.Reset;
        //             ZReportStats.SetRange("Store No.", Globals.StoreNo);
        //             ZReportStats.SetRange("POS Terminal No.", Globals.TerminalNo);
        //             if ZReportStats.FindLast then;

        //             GrossAmount := (ZReportStats."Cumulative Sales Amount" + ZReportStatsSalesAmount) + (ZReportStats."Cumulative Returns Amount" + ZReportStatsReturnsAmount);
        //             FieldValue[2] := POSFunctions.FormatAmount(GrossAmount);
        //             POSPrintUtility.PrintLine(2, FieldValue, DSTR1, false, true, false, false);

        //             if not FisPOSCommand.IsNOLocalizationEnabled then
        //                 FieldValue[1] := Text036
        //             else
        //                 FieldValue[1] := Text036_NO;
        //             FieldValue[2] := POSFunctions.FormatAmount(ZReportStats."Cumulative Returns Amount" + ZReportStatsReturnsAmount);
        //             POSPrintUtility.PrintLine(2, FieldValue, DSTR1, false, true, false, false);

        //             if not FisPOSCommand.IsNOLocalizationEnabled then
        //                 FieldValue[1] := Text038
        //             else
        //                 FieldValue[1] := Text038_NO;
        //             FieldValue[2] := POSFunctions.FormatAmount(ZReportStats."Cumulative Sales Amount" + ZReportStatsSalesAmount);
        //             POSPrintUtility.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        //         end;
        //     end;

        //     //Count not z-printed entries in the database
        //     Transaction2.SetCurrentKey("Statement Code", "Z-Report ID", "Transaction Type", "Entry Status");
        //     Transaction2.SetFilter("Statement Code", '<>%1', SCode);
        //     Transaction2.SetRange("Z-Report ID", '');
        //     Transaction2.SetRange("Transaction Type", Transaction."Transaction Type"::Sales);
        //     Transaction2.SetFilter("Entry Status", '%1|%2', Transaction."Entry Status"::" ", Transaction."Entry Status"::Posted);
        //     if RunType = RunType::Y then
        //         Transaction2.SetRange("Y-Report ID", '');
        //     PrintUtilPublic.OnAfterTransaction2FilterXZReport_NT(Transaction2);//NT
        //     if Transaction2.FindSet() then begin
        //         FieldValue[1] := lText001;
        //         FieldValue[2] := Format(Transaction2.Count, 0, '<Integer>');
        //         POSPrintUtility.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        //         OldestDate := Transaction2.Date;
        //         repeat
        //             if Transaction2.Date < OldestDate then
        //                 OldestDate := Transaction2.Date;
        //         until Transaction2.Next = 0;
        //         FieldValue[1] := lText002;
        //         FieldValue[2] := Format(OldestDate);
        //         POSPrintUtility.PrintLine(2, FieldValue, DSTR1, false, true, false, false);

        //         Transaction2.CalcSums("Gross Amount", "Discount Amount", "Total Discount", Rounded, "No. of Items");
        //         FieldValue[1] := lText003;
        //         FieldValue[2] := POSFunctions.FormatAmount(-Transaction2."Gross Amount" + Transaction2.Rounded);
        //         POSPrintUtility.PrintLine(2, FieldValue, DSTR1, false, true, false, false);
        //     end;
        //     Transaction2.Reset;
        //     POSPrintUtility.PrintSeperator(2);
        // end;

        if not POSPrintUtility.ClosePrinter(2) then
            exit(false);

        if Transaction."Entry Status" = Transaction."Entry Status"::Training then
            exit(true);

        // case RunType of
        //     RunType::Z:
        //         begin
        //             ZReportStats.Init;
        //             ZReportStats."Store No." := Globals.StoreNo;
        //             ZReportStats."POS Terminal No." := Globals.TerminalNo;
        //             ZReportStats.Date := Today;
        //             ZReportStats."Sales Amount" := ZReportStatsSalesAmount;
        //             ZReportStats."Return Amount" := ZReportStatsReturnsAmount;
        //             ZReportStats.Insert(true);
        //         end;
        //     RunType::Y:
        //         begin
        //             YReportStats.Init;
        //             YReportStats."Store No." := Globals.StoreNo;
        //             YReportStats."POS Terminal No." := Globals.TerminalNo;
        //             YReportStats.Date := Today;
        //             YReportStats."Sales Amount" := YReportStatsSalesAmount;
        //             YReportStats.Insert(true);
        //         end;
        // end;

        //Mark every entry included in the report with Z or Y report code.
        if (RunType = RunType::Z) or (RunType = RunType::Y) then begin
            // if Terminal."Statement Method" = Terminal."Statement Method"::"POS Terminal" then
            //     Terminal.Modify
            // else begin
            //     Staff.Modify;
            // end;

            // PaymEntry.SetRange("Currency Code");
            // PaymEntry.SetRange("Card No.");
            // PaymEntry.SetRange("Tender Type");
            // PaymEntry.SetRange("POS Terminal No.");
            // if PaymEntry.FindSet() then
            //     repeat
            //         PaymTrans2 := PaymEntry;
            //         if RunType = RunType::Y then
            //             PaymTrans2."Y-Report ID" := YReportID
            //         else
            //             PaymTrans2."Z-Report ID" := ZReportID;
            //         PaymTrans2.Modify(true);
            //     until PaymEntry.Next = 0;

            Clear(TendDeclEntry);
            TendDeclEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
            TendDeclEntry.SetRange("Statement Code", SCode);
            //TendDeclEntry.SetRange("Z-Report ID", '');
            TendDeclEntry.SetRange(Date, Today);//NT
            // if RunType = RunType::Y then
            //     TendDeclEntry.SetRange("Y-Report ID", '');
            //PrintUtilPublic.OnAfterTendDeclEntryFilterXZReport_NT(TendDeclEntry);//NT
            // if TendDeclEntry.FindSet() then
            //     repeat
            //         TendDeclEntry2 := TendDeclEntry;
            //         if RunType = RunType::Y then
            //             TendDeclEntry2."Y-Report ID" := YReportID
            //         else
            //             TendDeclEntry2."Z-Report ID" := ZReportID;
            //         TendDeclEntry2.Modify(true);
            //     until TendDeclEntry.Next = 0;

            Clear(IncExpEntry);
            IncExpEntry.SetCurrentKey("Statement Code", "Z-Report ID");
            IncExpEntry.SetRange("Statement Code", SCode);
            //IncExpEntry.SetRange("Z-Report ID", '');
            if RunType = RunType::Y then
                IncExpEntry.SetRange("Y-Report ID", '');
            //PrintUtilPublic.OnAfterIncExpEntryFilterXZReport_NT(IncExpEntry);//NT
            IncExpEntry.SetRange(Date, Today);//NT
            // if IncExpEntry.FindSet() then
            //     repeat
            //         IncExpEntry2 := IncExpEntry;
            //         IncExpEntry2."Z-Report ID" := ZReportID;
            //         IncExpEntry2.Modify(true);
            //     until IncExpEntry.Next = 0;

            // if Transaction.FindSet() then
            //     repeat
            //         Transaction2 := Transaction;
            //         if RunType = RunType::Y then
            //             Transaction2."Y-Report ID" := YReportID
            //         else
            //             Transaction2."Z-Report ID" := ZReportID;
            //         Transaction2.Modify(true);
            //     until Transaction.Next = 0;

            // if RunType = RunType::Y then begin
            //     YReportStats."Y-Report Id" := YReportID;
            //     YReportStats.Modify(true);
            //     Globals.SetValue("LSC POS Tag"::LAST_YID, YReportID);
            // end
            // else begin
            //     ZReportStats."Z-Report Id" := ZReportID;
            //     ZReportStats.Modify(true);
            //     Globals.SetValue("LSC POS Tag"::"LAST_ZID", ZReportID);
            // end;
        end;
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnAfterPrintXZReport(RunType, Transaction, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1);
        exit(true);
    end;

    procedure PrintXZLines(StaffID_p: Code[20])
    var
        Currency: Record Currency;
        TTCardSetup: Record "LSC Tender Type Card Setup";
        IsHandled: Boolean;
        DSTR1: Text[80];
    begin
        TTCardSetup.SetCurrentKey("Store No.", "Tender Type Code");
        TTCardSetup.SetRange("Store No.", Globals.StoreNo);
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        ///PrintUtilPublic.OnBeforePrintXZLines(StaffID_p, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1, IsHandled);
        if IsHandled then
            exit;

        if TenderType.FindSet() then
            repeat
                PaymEntry.SetRange("Tender Type", TenderType.Code);
                if StaffID_p <> '' then
                    PaymEntry.SetRange("Staff ID", StaffID_p)
                else
                    PaymEntry.SetRange("Staff ID");
                PaymEntry.SetRange("Card No.");
                FieldValue[1] := TenderType.Description;
                PaymEntry.CalcSums("Amount Tendered");
                LocalTotal := LocalTotal + PaymEntry."Amount Tendered";

                if TenderType."Foreign Currency" then begin
                    PaymEntry.SetRange("Currency Code");
                    PaymEntry.CalcSums("Amount Tendered");
                    if PaymEntry."Amount Tendered" <> 0 then begin
                        DSTR1 := '#L#### #R########### #R#################';
                        if Currency.FindSet() then
                            repeat
                                PaymEntry.SetRange("Currency Code", Currency.Code);
                                PaymEntry.CalcSums("Amount Tendered", "Amount in Currency");
                                if PaymEntry."Amount Tendered" <> 0 then begin
                                    FieldValue[1] := Currency.Code;
                                    FieldValue[2] := POSFunctions.FormatCurrency(PaymEntry."Amount in Currency", Currency.Code);
                                    FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);                                   
                                    POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                                end;
                                TotalLCYInCurrency := TotalLCYInCurrency + PaymEntry."Amount Tendered";
                            until Currency.Next = 0;
                    end;
                end else begin
                    if (TenderType."Function" = TenderType."Function"::Card) then begin
                        PaymEntry.SetRange("Card No.");
                        PaymEntry.CalcSums("Amount Tendered");
                        if PaymEntry."Amount Tendered" <> 0 then begin
                            DSTR1 := '#L################# #R##################';
                            FieldValue[2] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                            TTCardSetup.SetRange("Tender Type Code", TenderType.Code);
                            if TTCardSetup.FindSet() then
                                repeat
                                    DSTR1 := '   #L######### #R## #R###########';
                                    PaymEntry.SetRange("Card No.", TTCardSetup."Card No.");
                                    PaymEntry.CalcSums("Amount Tendered");
                                    if PaymEntry."Amount Tendered" <> 0 then begin
                                        FieldValue[1] := TTCardSetup.Description;
                                        FieldValue[2] := POSFunctions.FormatQty(PaymEntry.Count);
                                        FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                                        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                                        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                                    end
                                until TTCardSetup.Next = 0;
                        end;
                    end else begin
                        DSTR1 := '#L############ #R## #R##################';
                        PaymEntry.SetRange("Card No.");
                        PaymEntry.CalcSums("Amount Tendered");
                        if PaymEntry."Amount Tendered" <> 0 then begin
                            if TenderType."POS Count Entries" then
                                FieldValue[2] := POSFunctions.FormatQty(PaymEntry.Count())
                            else
                                FieldValue[2] := '';
                            FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
                        end;
                    end;
                end
            until TenderType.Next = 0;
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnAfterPrintXZLines(StaffID_p, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1);
    end;

    local procedure GetStatementCode(): Code[20]
    begin
        if not PosTerminal."Terminal Statement" then
            PosTerminal."Statement Method" := StoreSetup."Statement Method";
        case PosTerminal."Statement Method" of
            PosTerminal."Statement Method"::Staff:
                exit(Globals.StaffID);
            PosTerminal."Statement Method"::"POS Terminal":
                exit(PosTerminal."No.");
            PosTerminal."Statement Method"::Total:
                exit(Globals.StoreNo);
        end;
    end;

    procedure PrintLineWide(var PrintBuffer: Codeunit "LSC POS Print Utility"; Tray: Integer; FieldValue: array[10] of Text; DSTR: Text[100]; Wide: Boolean; Bold: Boolean; High: Boolean; Italic: Boolean)
    begin
        PrintBuffer.PrintLine(Tray, PrintBuffer.FormatLine(PrintBuffer.FormatStr(FieldValue, DSTR, true), Wide, Bold, High, Italic));
    end;

    procedure PrintLineFeed(var PrintBuffer: Codeunit "LSC POS Print Utility"; Tray: Integer; Lines: Integer)
    begin
        if Lines < 1 then
            Lines := 1;

        while Lines > 0 do begin
            Lines -= 1;
            PrintBuffer.PrintLine(Tray, '');
        end;
    end;

    procedure BufferTendDeclEntry()
    var
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        IsHandled: Boolean;
    begin
        TempTendDeclEntry.Reset;
        TempTendDeclEntry.DeleteAll;
        TempTransInfoCode.Reset;
        TempTransInfoCode.DeleteAll;

        TempTendDeclEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
        if TendDeclEntry.FindSet() then begin
            repeat
                IsHandled := false;
                //PrintUtilPublic.OnBeforeBufferTenderDeclEntry(TempTendDeclEntry, TendDeclEntry, IsHandled);
                if not IsHandled then begin
                    TempTendDeclEntry.SetRange("Statement Code", TendDeclEntry."Statement Code");
                    TempTendDeclEntry.SetRange("Z-Report ID", TendDeclEntry."Z-Report ID");
                    TempTendDeclEntry.SetRange("Tender Type", TendDeclEntry."Tender Type");
                    TempTendDeclEntry.SetRange("Currency Code", TendDeclEntry."Currency Code");
                    TempTendDeclEntry.SetRange("Card No.", TendDeclEntry."Card No.");
                    if TempTendDeclEntry.Find then begin
                        TempTendDeclEntry."Amount Tendered" += TendDeclEntry."Amount Tendered";
                        TempTendDeclEntry.Quantity += TendDeclEntry.Quantity;
                        TempTendDeclEntry."Amount in Currency" += TendDeclEntry."Amount in Currency";
                        TempTendDeclEntry.Modify;
                    end else begin
                        TempTendDeclEntry := TendDeclEntry;
                        TempTendDeclEntry.Insert;
                    end;
                end;
                TransInfoCode.SetRange("Store No.", TendDeclEntry."Store No.");
                TransInfoCode.SetRange("POS Terminal No.", TendDeclEntry."Store No.");
                TransInfoCode.SetRange("Transaction No.", TendDeclEntry."Transaction No.");
                TransInfoCode.SetRange("Transaction Type", TransInfoCode."Transaction Type"::"Payment Entry");
                TransInfoCode.SetRange("Line No.", TendDeclEntry."Line No.");
                if TransInfoCode.FindSet() then
                    repeat
                        TempTransInfoCode := TransInfoCode;
                        TempTransInfoCode."Replication Counter" := TempTendDeclEntry."Line No.";
                        TempTransInfoCode.Insert;
                    until TransInfoCode.Next = 0;

            until TendDeclEntry.Next = 0;
        end;
    end;

    procedure PrintTenderDeclLines(var PrintBuffer: Codeunit "LSC POS Print Utility")
    var
        Currency: Record Currency;
        TenderCard: Record "LSC Tender Type Card Setup";
        TenderType: Record "LSC Tender Type";
        TransDiffEntry: Record "LSC Trans. Difference Entry";
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        IsHandled: Boolean;
        DSTR1: Text[100];
        Payment: Text[30];
        DiffText: Label '   Difference';
    begin
        DSTR1 := '#L######## #R### #R######## #R##########';

        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnBeforePrintTenderDeclLines(TempTendDeclEntry, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1, IsHandled);
        if IsHandled then
            exit;

        if TempTendDeclEntry.FindSet() then
            repeat
                LocalTotal := LocalTotal + TempTendDeclEntry."Amount Tendered";
                Payment := TempTendDeclEntry."Tender Type";
                if TenderType.Get(TempTendDeclEntry."Store No.", TempTendDeclEntry."Tender Type") then
                    Payment := TenderType.Description
                else
                    Clear(TenderType);

                Clear(FieldValue);
                if TenderType."Foreign Currency" then begin
                    FieldValue[1] := TempTendDeclEntry."Currency Code";
                    NodeName[1] := 'Currency Code';
                    NodeName[2] := 'x';
                    NodeName[3] := 'x';
                    if TenderType."Multiply in Tender Operations" then begin
                        FieldValue[2] := POSFunctions.FormatQty(TempTendDeclEntry.Quantity);
                        NodeName[2] := 'Quantity';
                        FieldValue[3] := POSFunctions.FormatAmount(TempTendDeclEntry."Amount in Currency" / TempTendDeclEntry.Quantity);
                        NodeName[3] := 'Tender Unit Value';
                    end;
                    FieldValue[4] := POSFunctions.FormatCurrency(TempTendDeclEntry."Amount in Currency", FieldValue[1]);
                    NodeName[4] := 'Amount In Currency';
                end else begin
                    FieldValue[1] := Payment;
                    if (TenderType."Function" = TenderType."Function"::Card) then
                        if TenderCard.Get(TempTendDeclEntry."Store No.", TempTendDeclEntry."Tender Type", TempTendDeclEntry."Card No.") then
                            if TenderCard.Description <> '' then
                                FieldValue[1] := TenderCard.Description;
                    NodeName[1] := 'Tender Description';
                    NodeName[2] := 'x';
                    NodeName[3] := 'x';
                    if TenderType."Multiply in Tender Operations" then begin
                        FieldValue[2] := POSFunctions.FormatQty(TempTendDeclEntry.Quantity);
                        NodeName[2] := 'Quantity';
                        FieldValue[3] := POSFunctions.FormatAmount(TempTendDeclEntry."Amount Tendered" / TempTendDeclEntry.Quantity);
                        NodeName[3] := 'Tender Unit Value';
                    end;
                    FieldValue[4] := POSFunctions.FormatAmount(TempTendDeclEntry."Amount Tendered");
                    NodeName[4] := 'Amount In Tender';
                end;
                //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                PrintBuffer.PrintLine(2, PrintBuffer.FormatLine(PrintBuffer.FormatStr(FieldValue, DSTR1), false, false, false, false));
                PrintBuffer.AddPrintLine(700, 4, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
                TransDiffEntry.SetRange("Store No.", TempTendDeclEntry."Store No.");
                TransDiffEntry.SetRange("POS Terminal No.", TempTendDeclEntry."POS Terminal No.");
                TransDiffEntry.SetRange("Transaction No.", TempTendDeclEntry."Transaction No.");
                TransDiffEntry.SetRange("Tender Type", TempTendDeclEntry."Tender Type");
                TransDiffEntry.SetRange("Currency Code", TempTendDeclEntry."Currency Code");

                if TransDiffEntry.FindFirst then begin
                    FieldValue[1] := DiffText;
                    NodeName[1] := 'Tender Description';
                    NodeName[2] := 'x';
                    NodeName[3] := 'x';
                    FieldValue[4] := POSFunctions.FormatAmount(TransDiffEntry.Amount);
                    NodeName[4] := 'Amount In Tender';

                    //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
                    PrintBuffer.PrintLine(2, PrintBuffer.FormatLine(PrintBuffer.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    PrintBuffer.AddPrintLine(700, 4, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
                end;
                TempTransInfoCode.SetCurrentKey("Replication Counter");
                TempTransInfoCode.SetRange("Replication Counter", TempTendDeclEntry."Line No.");
                if TempTransInfoCode.FindSet then
                    repeat
                        TransInfoCode.Get(
                          TempTransInfoCode."Store No.", TempTransInfoCode."POS Terminal No.", TempTransInfoCode."Transaction No.",
                          TempTransInfoCode."Transaction Type", TempTransInfoCode."Line No.",
                          TempTransInfoCode.Infocode, TempTransInfoCode."Entry Line No.");
                        PrintBuffer.PrintTransInfoCode(TransInfoCode, 2, false);
                    until TempTransInfoCode.Next = 0;
            until TempTendDeclEntry.Next = 0;
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);

    end;

    local procedure PrintCashDeclTotalLCYLine(var PrintBuffer: Codeunit "LSC POS Print Utility"; TotalLCYAmount_p: Decimal)
    var
        IsHandled: Boolean;
        Tray: Integer;
        DSTR1: Text[100];
    begin
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnBeforePrintCashDeclTotalLCYLine(TotalLCYAmount_p, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1, IsHandled);
        if IsHandled then
            exit;

        DSTR1 := '#L######################### #R##########';
        Tray := 2;
        NodeName[1] := 'Total Text';
        NodeName[2] := 'Total Amount';
        Clear(FieldValue);
        FieldValue[1] := Text005 + ' ' + Globals.GetValue("LSC POS Tag"::"CURRSYM");
        FieldValue[2] := POSFunctions.FormatAmount(TotalLCYAmount_p);
        //PrintBuffer.PrintLine(Tray, FieldValue, DSTR1, false, false, false, false);
        PrintBuffer.PrintLine(2, PrintBuffer.FormatLine(PrintBuffer.FormatStr(FieldValue, DSTR1), false, false, false, false));
        PrintBuffer.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnAfterPrintCashDeclTotalLCYLine(TotalLCYAmount_p, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1);
    end;

    local procedure CountDetails(SCode: Code[20]; var PosLogQuantity: array[6] of Integer; var PosLogAmount: array[6] of Decimal; var TransDiscountQuantiy: Integer; var ItemCategory_Temp: Record "Item Category" temporary; var ProductGroup_Temp: Record "LSC Retail Product Group" temporary; var POSVATCode_Temp: Record "LSC POS VAT Code" temporary; var VoidedTransactionsAmount: Decimal)
    var
        Item_l: Record Item;
        PosCommandRec: Record "LSC POS Command";
        POSLog: Record "LSC POS Log";
        POSVATCode: Record "LSC POS VAT Code";
        POSVoidedTransaction: Record "LSC POS Voided Transaction";
        POSVoidedTransLine: Record "LSC POS Voided Trans. Line";
        Terminal: Record "LSC POS Terminal";
        Transaction_l: Record "LSC Transaction Header";
        TransDiscountEntry_l: Record "LSC Trans. Discount Entry";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        AddTransactionToItemCatTotal: Boolean;
        LastReceiptNo: Code[20];
        ItemPrice: Decimal;
        PosCommand: Enum "LSC POS Command";
    begin
        Clear(PosLogQuantity);
        Clear(PosLogAmount);
        ProductGroup_Temp.DeleteAll;
        Terminal.Get(Globals.TerminalNo);
        Transaction_l.SetCurrentKey("Statement Code", "Z-Report ID", "Transaction Type", "Entry Status");
        Transaction_l.SetRange("Statement Code", SCode);
        Transaction_l.SetRange(Date, Today);
        //Transaction_l.SetRange("Z-Report ID", '');
        Transaction_l.SetFilter("Entry Status", '%1|%2|%3', Transaction_l."Entry Status"::" ", Transaction_l."Entry Status"::Posted, Transaction_l."Entry Status"::Voided);
        if Terminal."Statement Method" = Terminal."Statement Method"::Staff then
            Transaction_l.SetFilter("Staff ID", Globals.StaffID);
        if Transaction_l.FindSet then
            repeat
                POSLog.SetRange("Entry Date", Transaction_l.Date);
                POSLog.SetRange("Store No.", Transaction_l."Store No.");
                POSLog.SetRange("Terminal No.", Transaction_l."POS Terminal No.");
                POSLog.SetRange("Receipt No.", Transaction_l."Receipt No.");
                if POSLog.FindSet then
                    repeat
                        //PosCommand := POSCommandRec.CommandToEnum(POSLog."POS Command");
                        PosCommand := CommandToEnum(POSLog."POS Command");
                        case PosCommand of
                            PosCommand::PRICECHK:
                                begin
                                    if Item_l.Get(POSLog."POS Parameter") then begin
                                        PosLogQuantity[1] += 1;
                                        if not ProductGroup_Temp.Get(Item_l."Item Category Code", Item_l."LSC Retail Product Code") then begin
                                            ProductGroup_Temp.Init;
                                            ProductGroup_Temp."Item Category Code" := Item_l."Item Category Code";
                                            ProductGroup_Temp.Code := Item_l."LSC Retail Product Code";
                                            ProductGroup_Temp.Insert;
                                        end;
                                        ItemPrice := GetPosSalesPrice(Transaction_l, Item_l."No.");
                                        ProductGroup_Temp."Default Profit %" += ItemPrice;
                                        ProductGroup_Temp.Modify;
                                        PosLogAmount[1] += ItemPrice;
                                    end;
                                end;
                            PosCommand::PRINT_C,
                            PosCommand::PRINT_LAST_C:
                                begin
                                    PosLogQuantity[2] += 1;
                                    PosLogAmount[2] += -Transaction_l."Gross Amount";
                                end;
                            PosCommand::PRINTBILL:
                                begin
                                    PosLogQuantity[3] += 1;
                                    PosLogAmount[3] += -Transaction_l."Gross Amount";
                                end;
                            PosCommand::VOID_L:
                                begin
                                    PosLogQuantity[4] += 1;
                                    POSVoidedTransLine.Reset;
                                    POSVoidedTransLine.SetRange("Receipt No.", Transaction_l."Receipt No.");
                                    if (not POSVoidedTransLine.IsEmpty) and (POSLog."Receipt No." <> LastReceiptNo) then begin
                                        POSVoidedTransLine.CalcSums(Amount);
                                        PosLogAmount[4] += POSVoidedTransLine.Amount;
                                    end;
                                end;
                            PosCommand::VOID:
                                if POSVoidedTransaction.Get(Transaction_l."Receipt No.") then begin
                                    POSVoidedTransaction.CalcFields("Gross Amount");
                                    POSVoidedTransLine.Reset;
                                    POSVoidedTransLine.SetRange("Receipt No.", Transaction_l."Receipt No.");
                                    if not POSVoidedTransLine.IsEmpty then begin
                                        PosLogQuantity[4] += POSVoidedTransLine.Count;
                                        PosLogAmount[4] += POSVoidedTransaction."Gross Amount";
                                        VoidedTransactionsAmount += POSVoidedTransaction."Gross Amount";
                                    end;
                                end;
                            PosCommand::OPEN_DR:
                                begin
                                    PosLogQuantity[5] += 1;
                                    PosLogAmount[5] += -Transaction_l."Gross Amount";
                                end;
                            PosCommand::QTYCH:
                                if POSLog."Receipt No." <> LastReceiptNo then begin
                                    TransSalesEntry.Reset;
                                    TransSalesEntry.SetRange("Receipt No.", Transaction_l."Receipt No.");
                                    if TransSalesEntry.FindSet() then
                                        repeat
                                            PosLogQuantity[6] += TransSalesEntry."Reduced Quantity";
                                            PosLogAmount[6] += TransSalesEntry."Reduced Quantity" * TransSalesEntry.Price;
                                        until TransSalesEntry.Next = 0;
                                end;
                        end;
                        LastReceiptNo := POSLog."Receipt No.";
                    until POSLog.Next = 0;

                TransDiscountEntry_l.SetRange("Store No.", Transaction_l."Store No.");
                TransDiscountEntry_l.SetRange("POS Terminal No.", Transaction_l."POS Terminal No.");
                TransDiscountEntry_l.SetRange("Transaction No.", Transaction_l."Transaction No.");
                if TransDiscountEntry_l.FindSet then
                    repeat
                        TransDiscountQuantiy += 1;
                    until TransDiscountEntry_l.Next = 0;

                TransSalesEntry.Reset;
                TransSalesEntry.SetRange("Store No.", Transaction_l."Store No.");
                TransSalesEntry.SetRange("POS Terminal No.", Transaction_l."POS Terminal No.");
                TransSalesEntry.SetRange("Transaction No.", Transaction_l."Transaction No.");
                if TransSalesEntry.FindSet then
                    repeat
                        if not POSVATCode_Temp.Get(TransSalesEntry."VAT Code") then begin
                            if not POSVATCode.Get(TransSalesEntry."VAT Code") then
                                clear(POSVATCode);
                            POSVATCode_Temp.Init;
                            POSVATCode_Temp."VAT Code" := TransSalesEntry."VAT Code";
                            POSVATCode_Temp.Description := POSVATCode.Description;
                            POSVATCode_Temp.Insert;
                        end;
                        POSVATCode_Temp."VAT %" += TransSalesEntry."VAT Amount";
                        POSVATCode_Temp.Modify;


                        //if not FisPOSCommand.IsNOLocalizationEnabled then
                        if not IsNOLocalizationEnabled then
                            AddTransactionToItemCatTotal := true
                        else
                            AddTransactionToItemCatTotal := Transaction_l."To Account" = false;

                        if AddTransactionToItemCatTotal then begin
                            if not ItemCategory_Temp.Get(TransSalesEntry."Item Category Code") then begin
                                ItemCategory_Temp.Init;
                                ItemCategory_Temp.Code := TransSalesEntry."Item Category Code";
                                ItemCategory_Temp.Insert;
                            end;
                            ItemCategory_Temp."LSC Difference (LCY)" += TransSalesEntry."Total Rounded Amt.";
                            ItemCategory_Temp.Modify;
                        end;
                    until TransSalesEntry.Next = 0;
            until Transaction_l.Next = 0;
    end;

    procedure CommandToEnum(CommandCode: Code[20]) CommandEnum: Enum "LSC POS Command"
    begin
        CommandExists(CommandCode, CommandEnum);
    end;

    local procedure CommandExists(CommandCode: Code[20]): Boolean
    var
        CommandEnum: Enum "LSC POS Command";
    begin
        exit(CommandExists(CommandCode, CommandEnum))
    end;

    local procedure CommandExists(CommandCode: Code[20]; var CommandEnum: Enum "LSC POS Command"): Boolean
    var
        Idx: Integer;
    begin
        CommandEnum := Enum::"LSC POS Command"::" ";
        if Format(CommandCode).Trim() = '' then
            exit; // ' ' -> '' (value 0)
        Idx := CommandEnum.Names.IndexOf(CommandCode);
        if Idx <= 0 then
            exit;
        CommandEnum := Enum::"LSC Pos Command".FromInteger(CommandEnum.Ordinals.Get(Idx));
        exit(true);
    end;

    local procedure GetPosSalesPrice(TransactionHeader_p: Record "LSC Transaction Header"; ItemNumber_p: Code[20]): Decimal
    var
        Item_l: Record Item;
        POSTransLine_l: Record "LSC POS Trans. Line";
        RetailSetup_l: Record "LSC Retail Setup";
        RetailPriceUtils: Codeunit "LSC Retail Price Utils";
    begin
        RetailSetup_l.Get;
        Item_l.Get(ItemNumber_p);
        exit(RetailPriceUtils.GetValidRetailPrice2Trans(
          TransactionHeader_p."Store No.", ItemNumber_p, TransactionHeader_p.Date, TransactionHeader_p.Time, Item_l."Sales Unit of Measure", '',
          RetailSetup_l."Def. VAT Bus. Post Gr. (Price)", TransactionHeader_p."Trans. Currency", RetailSetup_l."Default Price Group",
          TransactionHeader_p."Sales Type", TransactionHeader_p."Customer Disc. Group", POSTransLine_l));
    end;

    local procedure BufferTipsInfo(var TipsBufferTmp: Record "LSC Trans. Inc./Exp. Entry" temporary; var IncExpEntry: Record "LSC Trans. Inc./Exp. Entry")
    var
        TransHdr: Record "LSC Transaction Header";
        NextLineNo: Integer;
    begin
        if not (IncExpEntry.FindSet()) then
            exit;

        NextLineNo := 10000;
        if TipsBufferTmp.FindLast then
            NextLineNo := NextLineNo + TipsBufferTmp."Line No.";

        repeat
            TipsBufferTmp.SetRange("Staff ID", IncExpEntry."Staff ID");
            if not (TipsBufferTmp.FindFirst) then begin
                TipsBufferTmp.Init;
                TipsBufferTmp."Store No." := IncExpEntry."Store No.";
                TipsBufferTmp."POS Terminal No." := IncExpEntry."POS Terminal No.";
                TipsBufferTmp."Transaction No." := 0;
                TipsBufferTmp."Line No." := NextLineNo;
                NextLineNo := NextLineNo + 10000;
                TipsBufferTmp."Staff ID" := IncExpEntry."Staff ID";
                TipsBufferTmp.Insert;
            end;
            TipsBufferTmp.Amount := TipsBufferTmp.Amount + IncExpEntry.Amount;
            TipsBufferTmp.Modify;
        until IncExpEntry.Next = 0;
    end;

    local procedure CountSuspended(var SuspQuantity: Integer; var SuspAmount: Decimal)
    var
        SuspTrans: Record "LSC POS Transaction";
    begin
        SuspTrans.SetRange("Store No.", Store."No.");
        SuspTrans.SetRange("Entry Status", SuspTrans."Entry Status"::Suspended);
        SuspQuantity := SuspTrans.Count;
        if SuspTrans.FindSet then
            repeat
                SuspTrans.CalcFields("Gross Amount");
                SuspAmount += SuspTrans."Gross Amount";
            until SuspTrans.Next = 0;
    end;

    procedure ZReportNonCashSuspendProcess(var NoSuspPOSTransactionsVoided: Integer): Boolean
    var
        POSTransactionSuspend: Record "LSC POS Transaction";
        POSTransactionSuspendTEMP2: Record "LSC POS Transaction" temporary;
        POSTransactionSuspendTEMP: Record "LSC POS Transaction" temporary;
        POSTransLineSuspend: Record "LSC POS Trans. Line";
        POSTransLineSuspendTEMP: Record "LSC POS Trans. Line" temporary;
        GetPosTransSuspLinesUtils: Codeunit LSCGetPosTransSuspLinesUtils;
        GetPosTransSuspListUtils: Codeunit LSCGetPosTransSuspListUtils;
        PosGenFn: Codeunit "Pos_General Functions_NT";
        ProcessError: Boolean;
        ResponseCode: Code[30];
        NoSuspended: Integer;
        TSErr: Integer;
        ErrorText: Text;
        SuspTransExistMsg: Label 'Suspended Transaction exist\Process Stopped';
    begin
        NoSuspPOSTransactionsVoided := 0;
        if PosFuncProfile."Z-Report Suspend Trans.Process" <> PosFuncProfile."Z-Report Suspend Trans.Process"::None then begin

            POSTransactionSuspendTEMP.Reset;
            POSTransactionSuspendTEMP.DeleteAll;
            if PosFuncProfile."TS Susp./Retrieve" then begin
                GetPosTransSuspListUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
                GetPosTransSuspListUtils.SendRequest(StoreSetup."No.", ResponseCode, ErrorText, POSTransactionSuspendTEMP);
                //GetPosTransSuspListUtils.SetCommunicationError(ResponseCode, ErrorText);
                PosGenFn.SetCommunicationError(ResponseCode, ErrorText);
                if ErrorText <> '' then
                    exit(false);
            end else begin
                POSTransactionSuspend.Reset;
                POSTransactionSuspend.SetCurrentKey("Store No.", "POS Terminal No.", "Staff ID");
                POSTransactionSuspend.SetRange("Store No.", StoreSetup."No.");
                POSTransactionSuspend.SetRange("Entry Status", POSTransactionSuspend."Entry Status"::Suspended);
                POSTransactionSuspend.SetRange("Trans. Date", 0D, Today);
                if POSTransactionSuspend.FindSet then
                    repeat
                        POSTransactionSuspendTEMP := POSTransactionSuspend;
                        POSTransactionSuspendTEMP.Insert;
                    until POSTransactionSuspend.Next = 0;
            end;

            NoSuspended := 0;
            POSTransactionSuspendTEMP.Reset;
            if POSTransactionSuspendTEMP.FindSet then
                repeat
                    NoSuspended := NoSuspended + 1;
                until POSTransactionSuspendTEMP.Next = 0;

            case PosFuncProfile."Z-Report Suspend Trans.Process" of
                PosFuncProfile."Z-Report Suspend Trans.Process"::Block:
                    begin
                        if NoSuspended > 0 then begin
                            POSTransCU.PosMessage(SuspTransExistMsg);
                            exit(false);
                        end;
                    end;
                PosFuncProfile."Z-Report Suspend Trans.Process"::Delete,
                PosFuncProfile."Z-Report Suspend Trans.Process"::"Delete older than":
                    begin
                        if NoSuspended > 0 then begin
                            POSTransactionSuspendTEMP2.Reset;
                            POSTransactionSuspendTEMP2.DeleteAll;
                            POSTransactionSuspendTEMP.Reset;
                            if POSTransactionSuspendTEMP.FindSet then
                                repeat
                                    if PosFuncProfile."TS Susp./Retrieve" then begin
                                        POSTransLineSuspendTEMP.Reset;
                                        POSTransLineSuspendTEMP.DeleteAll;
                                        GetPosTransSuspLinesUtils.SetPosFunctionalityProfile(PosFuncProfile."Profile ID");
                                        GetPosTransSuspLinesUtils.SendRequest(ResponseCode, ErrorText, POSTransactionSuspendTEMP."Receipt No.",
                                            POSTransLineSuspendTEMP."Entry Type"::IncomeExpense.AsInteger(), POSTransLineSuspendTEMP);
                                        //GetPosTransSuspLinesUtils.SetCommunicationError(ResponseCode, ErrorText);
                                        PosGenFn.SetCommunicationError(ResponseCode, ErrorText);
                                        if ErrorText <> '' then
                                            exit(false);
                                        if POSTransLineSuspendTEMP.FindFirst then begin
                                            POSTransactionSuspendTEMP2 := POSTransactionSuspendTEMP;
                                            POSTransactionSuspendTEMP2.Insert;
                                        end;
                                    end else begin
                                        POSTransLineSuspend.Reset;
                                        POSTransLineSuspend.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
                                        POSTransLineSuspend.SetRange("Receipt No.", POSTransactionSuspendTEMP."Receipt No.");
                                        POSTransLineSuspend.SetRange("Entry Type", POSTransLineSuspend."Entry Type"::IncomeExpense);
                                        if POSTransLineSuspend.FindFirst then begin
                                            POSTransactionSuspendTEMP2 := POSTransactionSuspendTEMP;
                                            POSTransactionSuspendTEMP2.Insert;
                                        end;
                                    end;
                                until POSTransactionSuspendTEMP.Next = 0;
                            // POSTransactionSuspendTEMP2.Reset;
                            // if POSTransactionSuspendTEMP2.FindSet then
                            //     repeat
                            //         if POSTransactionSuspendTEMP.Get(POSTransactionSuspendTEMP2."Receipt No.") then
                            //             POSTransactionSuspendTEMP.Delete;
                            //     until POSTransactionSuspendTEMP2.Next = 0;
                            POSTransactionSuspendTEMP.Reset;
                            if POSTransactionSuspendTEMP.FindSet then
                                repeat
                                    //VoidSuspendedTrans(POSTransactionSuspendTEMP."Receipt No.");
                                    NoSuspPOSTransactionsVoided := NoSuspPOSTransactionsVoided + 1;
                                until POSTransactionSuspendTEMP.Next = 0;
                        end;
                    end;
            end;
        end;

        exit(true);
    end;

    local procedure PrintTipsInfo(var TipsBufferTmp: Record "LSC Trans. Inc./Exp. Entry" temporary; Which: Option "In",Out)
    var
        Staff: Record "LSC Staff";
        IsHandled: Boolean;
        DSTR1: Text[80];
        DetailText: Label '%1: %2';
        HeaderText: Label 'Tips %1';
        NotFoundText: Label 'Not found';
        TotalText: Label 'Tips %1 Total';
    begin
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnBeforePrintTipsInfo(TipsBufferTmp, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1, IsHandled);
        if IsHandled then
            exit;

        if not (TipsBufferTmp.FindSet()) then
            exit;

        //print header for the Tips Report.
        POSPrintUtility.PrintSeperator(2);
        DSTR1 := '#L######################################';
        FieldValue[1] := StrSubstNo(HeaderText, Format(Which));
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));

        POSPrintUtility.PrintSeperator(2);

        //Print details of Tips Out
        DSTR1 := ' #L##################### #R##########';

        repeat
            if not (Staff.Get(TipsBufferTmp."Staff ID")) then
                Staff."Name on Receipt" := NotFoundText;
            FieldValue[1] := StrSubstNo(DetailText, TipsBufferTmp."Staff ID", Staff."Name on Receipt");
            FieldValue[2] := POSFunctions.FormatAmount(-TipsBufferTmp.Amount);
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
            POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        until TipsBufferTmp.Next = 0;
        POSPrintUtility.PrintSeperator(2);

        //Print total line
        DSTR1 := '#L###################### #R##########';
        TipsBufferTmp.FindFirst;
        TipsBufferTmp.CalcSums(Amount);
        FieldValue[1] := StrSubstNo(TotalText, Format(Which));
        FieldValue[2] := POSFunctions.FormatAmount(-TipsBufferTmp.Amount);
        //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
        POSPrintUtility.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, true, false, false));
        //PrintBuffer.GetPrintBufferRec(gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef);
        //PrintUtilPublic.OnAfterPrintTipsInfo(TipsBufferTmp, gPrintBufferRef, gPrintBufferIndexRef, gLinesPrintedRef, DSTR1);
    end;

    procedure PrinterActive(): Boolean
    begin
        if not Globals.PrinterActive then begin
            POSTransCU.ErrorBeep(StrSubstNo(NoIsConfiguredInHwProfileMsg, "LSC Hardware Profile Devices"::Printer, PosSetup."Profile ID"));
            exit(false);
        end;
        exit(true);
    end;

    local procedure POSSalesTransExistInStore(StoreNo: Code[10]): Integer
    var
        POSTransaction: Record "LSC POS Transaction";
    begin
        POSTransaction.SetCurrentKey("Store No.", "Sales Type", "Transaction Type");
        POSTransaction.SetRange("Store No.", StoreNo);
        POSTransaction.SetRange("Transaction Type", POSTransaction."Transaction Type"::Sales);
        if not PosTerminal."Terminal Statement" then begin
            PosTerminal."Statement Method" := StoreSetup."Statement Method";
            if PosTerminal."Statement Method" = PosTerminal."Statement Method"::"POS Terminal" then
                POSTransaction.SetRange("Created on POS Terminal", Globals.TerminalNo);
            if PosTerminal."Statement Method" = PosTerminal."Statement Method"::Staff then
                POSTransaction.SetRange("Staff ID", Globals.StaffID);
        end else
            POSTransaction.SetRange("POS Terminal No.", Globals.TerminalNo);
        exit(POSTransaction.Count);
    end;

    procedure IsNOLocalizationEnabled() NOEnabled: Boolean
    var
        ClientSessionUtility: Codeunit "LSC Client Session Utility";
    begin
        if ClientSessionUtility.FindLocalizedVersion = 'NO' then
            exit(true)
        else
            exit(false);
    end;

    procedure PrintBarcodeOnSuspendedSlip(var POSPrintUtilityIn: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var POSTrans: Record "LSC POS Transaction"; var tmpPosItemTransLines: Record "LSC POS Trans. Line" temporary)
    var
        DSTR1: Text[100];
    begin
        DSTR1 := '#L################ #L#####################';
        //DSTR1 := '#L###################### #L#############';
        Clear(FieldValue);
        if tmpPosItemTransLines."Barcode No." <> '' then begin
            FieldValue[1] := Text075;
            FieldValue[2] := tmpPosItemTransLines."Barcode No." + ' ' + POSFunctions.FormatPrice(tmpPosItemTransLines.Price);
            //PrintBuffer.PrintLine(2, FieldValue, DSTR1, false, false, false, false);
            POSPrintUtilityIn.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
        end else begin
            FieldValue[1] := Text074;
            FieldValue[2] := tmpPosItemTransLines.Number + ' ' + POSFunctions.FormatPrice(tmpPosItemTransLines.Price);
            POSPrintUtilityIn.PrintLine(2, POSPrintUtility.FormatLine(POSPrintUtility.FormatStr(FieldValue, DSTR1), false, false, false, false));
        end;
    end;

    var
        PaymEntry: Record "LSC Trans. Payment Entry";
        PosFuncProfile: Record "LSC POS Func. Profile";
        PosSetup: Record "LSC POS Hardware Profile";
        PosTerminal: Record "LSC POS Terminal";
        Store: record "LSC store";
        StoreSetup: Record "LSC Store";
        TempTendDeclEntry: Record "LSC Trans. Tender Declar. Entr" temporary;
        TempTransInfoCode: Record "LSC Trans. Infocode Entry" temporary;
        TendDeclEntry: Record "LSC Trans. Tender Declar. Entr";
        Tendertype: Record "LSC Tender Type";
        Globals: Codeunit "LSC POS Session";
        POSFunctions: Codeunit "LSC POS Functions";
        POSPrintUtility: Codeunit "LSC POS Print Utility";
        POSTransCU: Codeunit "LSC POS Transaction";
        POSView: Codeunit "LSC POS View";
        LocalTotal: Decimal;
        TotalLCYInCurrency: Decimal;
        gNoSuspPOSTransactionsVoided: Integer;
        FieldValue: array[10] of Text[100];
        InfoTextDescription: Text;
        NodeName: array[32] of Text[50];
        NoIsConfiguredInHwProfileMsg: Label 'No %1 is configured in Hardware profile %2.';
        ReportOnlyPrintableFromPosErr: Label 'The report can only be printed from within the POS.';
        Text001: Label 'Staff';
        Text002: Label 'Trans';
        Text003: Label '    Congratulations!';
        Text005: Label 'Total ';
        Text006: Label 'Today %1 Points';
        Text007: label 'You''re taking SPECIAL DISCOUNTS home:';
        Text008: Label 'Social Family Card';
        Text009: Label 'Initial Point Balance: %1';
        Text010: label 'Voided';
        Text011: Label 'Gross Sales';
        Text012: Label 'Discount';
        Text048: Label 'Date';
        Text051: Label 'Staff';
        Text052: Label 'Trans';
        Text063: Label 'VAT';
        Text063_2: Label 'Net.Amt';
        Text063_Tax: Label 'TAX';
        Text074: Label 'Item No.: ';
        Text075: Label 'Barcode: ';
        Text078: Label 'Store no.';
        Text079: Label 'Terminal';
        Text093: Label 'Rounding';
        Text160: Label 'Qty.';
        TextSavedToday: Label 'SAVED TODAY';
        UnpostedTransContinueQst: Label 'There are %1 unposted sales transactions in the store. Do you still want to continue?';
        ZReportNotInTrainingErr: Label 'Z-Non Cash Reports are not allowed in Training mode';

}