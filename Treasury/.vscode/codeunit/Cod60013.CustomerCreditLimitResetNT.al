codeunit 60013 "Customer Credit Limit Reset_NT"
{
    TableNo = "LSC Scheduler Job Header";
    trigger OnRun()
    begin
        CraeteCustTransStatus(Rec.DateFormula);
    end;

    local procedure CraeteCustTransStatus(DateFormulaIn: DateFormula)
    var
        TransactionStatus: Record "LSC Transaction Status";
        BlankDateFormula: DateFormula;
    begin
        if DateFormulaIn = BlankDateFormula then
            exit;
        OpenTablesBuffers();
        if GuiAllowed then
            Window.Open(Text001 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@');

        Transaction.SetCurrentKey("Customer No.", Date, "Entry Status");
        Transaction.SetRange(Date, CalcDate(DateFormulaIn, Today), Today);
        Transaction.SetFilter("Transaction Type", '<>%1', Transaction."Transaction Type"::PhysInv);
        Transaction.SetFilter("Customer No.", '<>%1', '');
        NoOfRec := Transaction.Count;
        Counter := 0;
        if Transaction.FindSet then
            repeat
                Clear(TransactionStatus);
                if ProcessTrans(Transaction, TransactionStatus) then begin
                    Counter := Counter + 1;
                    if GuiAllowed then
                        Window.Update(1, Round(Counter / NoOfRec * 10000, 1));
                end;
            until Transaction.Next = 0;
        FlushTablesBuffers();
        if GuiAllowed then
            Window.Close;
    end;

    local procedure ProcessTrans(Transaction: Record "LSC Transaction Header"; var TransactionStatus: Record "LSC Transaction Status"): Boolean
    var

    begin
        //ProcessTrans        
        if Transaction."Transaction Type" in
           [Transaction."Transaction Type"::Logon, Transaction."Transaction Type"::Logoff, Transaction."Transaction Type"::"Open Drawer"]
        then
            exit(false);
        if Transaction."Entry Status" <> Transaction."Entry Status"::" " then
            exit(false);

        if Transaction."Posted Statement No." <> '' then
            exit(false);

        if not TransactionStatus.Get(Transaction."Store No.", Transaction."POS Terminal No.", Transaction."Transaction No.") then begin
            TransactionStatus.Init;
            TransactionStatus."Store No." := Transaction."Store No.";
            TransactionStatus."POS Terminal No." := Transaction."POS Terminal No.";
            TransactionStatus."Transaction No." := Transaction."Transaction No.";
            TransactionStatus."Customer No." := Transaction."Customer No.";
            TransactionStatus."Amount to Account" := Transaction."Amount to Account";
            TransactionStatus.Date := Transaction.Date;
            TransStatusToBuffer(TransactionStatus);
            exit(true);
        end else begin
            TransStatusToBuffer(TransactionStatus);
            //exit(TransactionStatus."Statement No." = '');
            exit(false);
        end;
    end;

    local procedure MarkTransaction(Transaction: Record "LSC Transaction Header")
    var
        CurrExchRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        Item: Record Item;
        lTenderTypeRec: Record "LSC Tender Type";
        POSTerminal_l: Record "LSC POS Terminal";
        TransactionHeader_l: Record "LSC Transaction Header";
        TransactionStatus: Record "LSC Transaction Status";
        TransDiscEntry: Record "LSC Trans. Discount Entry";
        TransIncomeExpenseEntry: Record "LSC Trans. Inc./Exp. Entry";
        TransPmtEntry: Record "LSC Trans. Payment Entry";
        TransSafeEntry: Record "LSC Trans. Safe Entry";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        TransSalesEntryStatus2: Record "LSC Trans. Sales Entry Status";
        TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status";
        TransTenderDeclarEntry: Record "LSC Trans. Tender Declar. Entr";
        ItemPosted: Boolean;
        NewTransSalesEntryStatus: Boolean;
        SerLotNoNotFound: Boolean;
        UpdateTransSalesEntry: Boolean;
        StoreCurrFactor: Decimal;
        ErrorText: Text[250];
    begin
        TransSalesEntry.Reset;
        TransPmtEntry.Reset;
        TransTenderDeclarEntry.Reset;

        TransSafeEntry.Reset;

        GetTransStatusFromBuffer(Transaction, TransactionStatus);
        TransactionStatus."Statement No." := '';
        TransactionStatus."Items Blocked" := 0;

        if Transaction."Wrong Shift" then
            TransactionStatus."Trans. on Wrong Shift" := 1
        else
            TransactionStatus."Trans. on Wrong Shift" := 0;

        TransactionStatus."Items/Barc. Not on File" := 0;
        TransactionStatus."Sales Amount" := 0;
        TransactionStatus."VAT Amount" := 0;
        TransactionStatus."Total Discount" := 0;
        TransactionStatus."Line Discount" := 0;
        TransactionStatus."Discount Total Amount" := 0;
        TransactionStatus.Income := 0;
        TransactionStatus.Expenses := 0;
        TransactionStatus."No of Trans. Sales Entries" := 0;
        TransactionStatus."Serial/Lot No. Not Valid" := 0;

        if Transaction."Customer No." <> '' then
            if Customer.Get(Transaction."Customer No.") then
                if Customer.Blocked <> Customer.Blocked::" " then
                    TransactionStatus."Blocked Customer" := true;

        if Transaction."Transaction Code" = Transaction."Transaction Code"::"Sale/Pmt. Difference" then
            TransactionStatus."Sale/Pmt. Difference" := true;

        TransSalesEntry.SetRange("Store No.", Transaction."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", Transaction."Transaction No.");

        TransPmtEntry.SetRange("Store No.", Transaction."Store No.");
        TransPmtEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransPmtEntry.SetRange("Transaction No.", Transaction."Transaction No.");

        TransIncomeExpenseEntry.SetRange("Store No.", Transaction."Store No.");
        TransIncomeExpenseEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransIncomeExpenseEntry.SetRange("Transaction No.", Transaction."Transaction No.");

        TransTenderDeclarEntry.SetRange("Store No.", Transaction."Store No.");
        TransTenderDeclarEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransTenderDeclarEntry.SetRange("Transaction No.", Transaction."Transaction No.");

        TransSafeEntry.SetRange("Store No.", Transaction."Store No.");
        TransSafeEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSafeEntry.SetRange("Transaction No.", Transaction."Transaction No.");

        TransDiscEntry.SetRange("Store No.", Transaction."Store No.");
        TransDiscEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransDiscEntry.SetRange("Transaction No.", Transaction."Transaction No.");

        if TransSalesEntry.FindSet then
            repeat
                TransactionStatus."No of Trans. Sales Entries" := TransactionStatus."No of Trans. Sales Entries" + 1;
                UpdateTransSalesEntry := false;
                if Item.Get(TransSalesEntry."Item No.") then begin
                    if Item.Blocked then begin
                        TransactionStatus."Items Blocked" := TransactionStatus."Items Blocked" + 1;
                        TransSalesEntry."Transaction Code" := TransSalesEntry."Transaction Code"::"Item Blocked";
                        UpdateTransSalesEntry := true;
                    end;
                end
                else begin
                    TransactionStatus."Items/Barc. Not on File" := TransactionStatus."Items/Barc. Not on File" + 1;
                    TransSalesEntry."Transaction Code" := TransSalesEntry."Transaction Code"::"Item/Barcode Not On File";
                    UpdateTransSalesEntry := true;
                end;

                ItemPosted := false;
                if TransSalesEntryStatus2.Get(TransSalesEntry."Store No.",
                      TransSalesEntry."POS Terminal No.",
                      TransSalesEntry."Transaction No.",
                      TransSalesEntry."Line No.")
                then
                    if TransSalesEntryStatus2.Status in [TransSalesEntryStatus2.Status::"Items Posted", TransSalesEntryStatus2.Status::Posted] then
                        ItemPosted := true;

                // if (TransSalesEntry."Serial No." <> '') and (not ItemPosted) then begin
                //     SerLotNoNotFound := TransSalesEntry."Serial/Lot No. Not Valid";
                //     TransSalesEntry."Serial/Lot No. Not Valid" := not TransSalesCheckSerialNo(TransSalesEntry, ErrorText);
                //     if TransSalesEntry."Serial/Lot No. Not Valid" <> SerLotNoNotFound then
                //         UpdateTransSalesEntry := true;
                // end;
                // if (TransSalesEntry."Lot No." <> '') and (not ItemPosted) then
                //     if not ((TransSalesEntry."Serial No." <> '') and (TransSalesEntry."Serial/Lot No. Not Valid")) then begin
                //         SerLotNoNotFound := TransSalesEntry."Serial/Lot No. Not Valid";
                //         TransSalesEntry."Serial/Lot No. Not Valid" := not TransSalesCheckLotNo(StatementNo, TransSalesEntry, ErrorText);
                //         if TransSalesEntry."Serial/Lot No. Not Valid" <> SerLotNoNotFound then
                //             UpdateTransSalesEntry := true;
                //     end;

                if TransSalesEntry."Serial/Lot No. Not Valid" then
                    TransactionStatus."Serial/Lot No. Not Valid" := TransactionStatus."Serial/Lot No. Not Valid" + 1;

                if UpdateTransSalesEntry then
                    TransSalesEntryToBuffer(TransSalesEntry);

                TransactionStatus."Sales Amount" := TransactionStatus."Sales Amount" + TransSalesEntry."Net Amount";
                TransactionStatus."VAT Amount" := TransactionStatus."VAT Amount" + TransSalesEntry."VAT Amount";
                TransactionStatus."Total Discount" := TransactionStatus."Total Discount" + TransSalesEntry."Total Discount";
                if TransSalesEntry."Line was Discounted" then
                    TransactionStatus."Line Discount" := TransactionStatus."Line Discount" + TransSalesEntry."Line Discount";
                if not TransSalesEntryStatus.Get(TransSalesEntry."Store No.",
                      TransSalesEntry."POS Terminal No.",
                      TransSalesEntry."Transaction No.",
                      TransSalesEntry."Line No.")
                then begin
                    NewTransSalesEntryStatus := true;
                    TransSalesEntryStatus.Init;
                    TransSalesEntryStatus."Store No." := TransSalesEntry."Store No.";
                    TransSalesEntryStatus."POS Terminal No." := TransSalesEntry."POS Terminal No.";
                    TransSalesEntryStatus."Transaction No." := TransSalesEntry."Transaction No.";
                    TransSalesEntryStatus."Line No." := TransSalesEntry."Line No.";
                end else
                    NewTransSalesEntryStatus := false;
                TransSalesEntryStatus."Statement No." := '';
                TransSalesEntryStatus."Item No." := TransSalesEntry."Item No.";
                TransSalesEntryStatus."Variant Code" := TransSalesEntry."Variant Code";
                TransSalesEntryStatus.Quantity := TransSalesEntry.Quantity;
                TransSalesEntryStatus.Date := TransSalesEntry.Date;
                TransSalesEntryStatus."Serial No." := TransSalesEntry."Serial No.";
                TransSalesEntryStatus."Lot No." := TransSalesEntry."Lot No.";                

                //OnMarkTransOnBeforeTransSalesEntryStatusToBuffer(TransSalesEntryStatus);
                TransSalesEntryStatusToBuffer(TransSalesEntryStatus);
            until TransSalesEntry.Next = 0;

        // if TransPmtEntry.FindSet then
        //     repeat
        //         if (Transaction."POS Terminal No." <> PosTerminalTemp."No.") or
        //            (Transaction."Staff ID" <> LastStaffID) or
        //            (LastCode = '')
        //         then begin
        //             PopulateStatementCode(Transaction."POS Terminal No.", Transaction."Staff ID", LastCode, WrkStaffID, WrkPOSTerminalNo);
        //             LastStaffID := Transaction."Staff ID";
        //         end;
        //         LastType := TransPmtEntry."Tender Type";
        //         LastCard := TransPmtEntry."Card No.";
        //         LastCard := '';
        //         LastCurr := TransPmtEntry."Currency Code";
        //         if Transaction."Trans. Currency" <> '' then
        //             StoreCurrFactor := CurrExchRate.ExchangeRate(Transaction.Date, Transaction."Trans. Currency")
        //         else
        //             StoreCurrFactor := 1;

        //         if Store."Safe Mgnt. in Use" and
        //            (Transaction."Transaction Type" in
        //            [Transaction."Transaction Type"::"Remove Tender",
        //            Transaction."Transaction Type"::"Float Entry",
        //            Transaction."Transaction Type"::"Change Tender",
        //            Transaction."Transaction Type"::"Tender Decl."])
        //         then begin
        //             TotAmount := 0;
        //             TotCurrAmount := 0;
        //         end
        //         else begin
        //             TotAmount := TransPmtEntry."Amount Tendered" / StoreCurrFactor;
        //             TotCurrAmount := TransPmtEntry."Amount in Currency";
        //         end;
        //         TotRemovedAmount := 0;
        //         TotAddedAmount := 0;
        //         TotChange := 0;
        //         case Transaction."Transaction Type" of
        //             Transaction."Transaction Type"::"Remove Tender":
        //                 TotRemovedAmount := TotRemovedAmount + TransPmtEntry."Amount in Currency";
        //             Transaction."Transaction Type"::"Float Entry":
        //                 TotAddedAmount := TotAddedAmount + TransPmtEntry."Amount in Currency";
        //             Transaction."Transaction Type"::"Change Tender":
        //                 TotChange := TotChange + TransPmtEntry."Amount in Currency";
        //             Transaction."Transaction Type"::"Tender Decl.":
        //                 TotRemovedAmount := TotRemovedAmount + TransPmtEntry."Amount in Currency";
        //         end;

        //         StatementLine2.SetFilter("Statement Code", '%1', LastCode);
        //         StatementLine2.SetFilter("Staff ID", '%1', WrkStaffID);
        //         StatementLine2.SetFilter("POS Terminal No.", '%1', WrkPOSTerminalNo);
        //         StatementLine2.SetFilter("Tender Type", '%1', LastType);
        //         StatementLine2.SetFilter("Tender Type Card No.", '%1', LastCard);
        //         StatementLine2.SetFilter("Currency Code", '%1', LastCurr);
        //         if StatementLine2.FindFirst then begin
        //             StatementLine2.Validate("Trans. Amount", StatementLine2."Trans. Amount" + TotCurrAmount);
        //             StatementLine2.Validate("Trans. Amount in LCY", StatementLine2."Trans. Amount in LCY" + TotAmount);
        //             if StatementLine2."Trans. Amount" <> 0 then
        //                 StatementLine2."Real Exchange Rate" := StatementLine2."Trans. Amount in LCY" / StatementLine2."Trans. Amount"
        //             else begin
        //                 if TotCurrAmount = 0 then
        //                     StatementLine2."Real Exchange Rate" := 1
        //                 else
        //                     if SafeStatementLine2."Real Exchange Rate" <> 0 then
        //                         SafeStatementLine2."Real Exchange Rate" := (SafeStatementLine2."Real Exchange Rate" + (TotAmount / TotCurrAmount)) / 2
        //                     else
        //                         SafeStatementLine2."Real Exchange Rate" := TotAmount / TotCurrAmount;
        //             end;
        //             if not StatementLine2."Counting Required" then begin
        //                 POSTerminal_l.Get(TransPmtEntry."POS Terminal No.");
        //                 lTenderTypeRec.Get(Transaction."Store No.", LastType);
        //                 StatementLine2."Counting Required" := lTenderTypeRec."Counting Required" and ((not Store."Safe Mgnt. in Use") or POSTerminal_l."Exclude from Cash Mgnt.");
        //             end;
        //             if StatementLine2."Counting Required" then
        //                 StatementLine2.Validate("Counted Amount", 0)
        //             else begin
        //                 lTenderTypeRec.Get(Transaction."Store No.", LastType);
        //                 if Store."Safe Mgnt. in Use" and
        //                    (lTenderTypeRec."Function" <> lTenderTypeRec."Function"::"Tender Remove/Float") and
        //                    (lTenderTypeRec."Counting Required")
        //                 then
        //                     StatementLine2.Validate("Counted Amount", StatementLine2."Counted Amount" - TotAddedAmount - TotRemovedAmount)
        //                 else
        //                     StatementLine2.Validate("Counted Amount", StatementLine2."Trans. Amount");
        //             end;
        //             StatementLine2."Added to Drawer" += TotAddedAmount;
        //             StatementLine2."Removed from Drawer" += TotRemovedAmount;
        //             StatementLine2."Change Tender" += TotChange;
        //             StatementLine2.Modify;
        //         end
        //         else begin
        //             InsertLine(Stmt, PosTerminalTemp."Statement Method");
        //             NextLine := NextLine + 10000;
        //         end;

        //   until TransPmtEntry.Next = 0;

        // if TransSafeEntry.FindSet then
        //     repeat
        //         if (Transaction."POS Terminal No." <> PosTerminalTemp."No.") or
        //            (Transaction."Staff ID" <> LastStaffID) or
        //            (LastCode = '')
        //         then begin
        //             PopulateStatementCode(Transaction."POS Terminal No.", Transaction."Staff ID", LastCode, WrkStaffID, WrkPOSTerminalNo);
        //             LastStaffID := Transaction."Staff ID";
        //         end;

        //         InsertBankLine(Stmt, TransSafeEntry, PosTerminalTemp."Statement Method");
        //         NextSafeLine := NextSafeLine + 10000;
        //     until TransSafeEntry.Next = 0;

        if TransIncomeExpenseEntry.FindSet then
            repeat
                case TransIncomeExpenseEntry."Account Type" of
                    TransIncomeExpenseEntry."Account Type"::Income:
                        begin
                            if TransIncomeExpenseEntry."To Account" and (Transaction."Amount to Account" <> 0) then
                                TransactionStatus."Amount to Account" += TransIncomeExpenseEntry."Net Amount"
                            else
                                TransactionStatus.Income := TransactionStatus.Income + TransIncomeExpenseEntry."Net Amount";
                            TransactionStatus."VAT Amount" := TransactionStatus."VAT Amount" + TransIncomeExpenseEntry."VAT Amount";
                        end;
                    TransIncomeExpenseEntry."Account Type"::Expense:
                        begin
                            TransactionStatus.Expenses := TransactionStatus.Expenses + TransIncomeExpenseEntry."Net Amount";
                            TransactionStatus."VAT Amount" := TransactionStatus."VAT Amount" + TransIncomeExpenseEntry."VAT Amount";
                        end;
                end;
            until TransIncomeExpenseEntry.Next = 0;

        TransIncomeExpenseEntry.SetRange("Account Type", TransIncomeExpenseEntry."Account Type"::Income);
        if not TransIncomeExpenseEntry.IsEmpty then begin
            TransactionHeader_l.Get(TransactionStatus."Store No.", TransactionStatus."POS Terminal No.", TransactionStatus."Transaction No.");
            if ((TransactionStatus.Income <> 0) and (TransactionStatus."Sales Amount" <> 0) and (TransactionHeader_l.Payment <= 0)) or
                ((TransactionStatus.Income <> 0) and (TransactionStatus."Sales Amount" = 0) and (TransactionHeader_l.Payment <= 0))
            then begin
                TransactionStatus."Amount to be Refunded" := TransactionStatus."Amount to be Refunded" + TransactionStatus.Income + TransactionStatus."Sales Amount" + TransactionStatus."VAT Amount" + TransactionHeader_l.Payment - TransactionHeader_l.Rounded;
                TransactionStatus."Customer Order ID" := TransactionHeader_l."Customer Order ID";
            end;
        end;
        TransIncomeExpenseEntry.SetRange("Account Type");
        //TmpDeclEntry.Reset;

        // if not Store."Safe Mgnt. in Use" then
        //     if TransTenderDeclarEntry.FindSet then
        //         repeat
        //             if StatementClosingMethod = StatementClosingMethod::Shift then begin
        //                 TmpDeclEntry.SetRange("Shift Date", TransTenderDeclarEntry."Shift Date");
        //                 TmpDeclEntry.SetRange("Shift No.", TransTenderDeclarEntry."Shift No.");
        //             end;

        //             if Store."Statement Method" = Store."Statement Method"::Staff then
        //                 TmpDeclEntry.SetRange("Staff ID", TransTenderDeclarEntry."Staff ID");
        //             if Store."Statement Method" = Store."Statement Method"::"POS Terminal" then
        //                 TmpDeclEntry.SetRange("POS Terminal No.", TransTenderDeclarEntry."POS Terminal No.");

        //             TmpDeclEntry.SetRange("Statement Code", TransTenderDeclarEntry."Statement Code");
        //             if TmpDeclEntry.FindFirst and (TmpDeclEntry."Transaction No." <> TransTenderDeclarEntry."Transaction No.") and
        //                (Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Last)
        //             then
        //                 TmpDeclEntry.DeleteAll;
        //             TmpDeclEntry.SetRange("Tender Type", TransTenderDeclarEntry."Tender Type");
        //             TmpDeclEntry.SetRange("Card No.", TransTenderDeclarEntry."Card No.");
        //             TmpDeclEntry.SetRange("Currency Code", TransTenderDeclarEntry."Currency Code");
        //             if TmpDeclEntry.FindFirst then begin
        //                 if Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Last then begin
        //                     TmpDeclEntry."Amount Tendered" := TransTenderDeclarEntry."Amount Tendered";
        //                     TmpDeclEntry."Amount in Currency" := TransTenderDeclarEntry."Amount in Currency";
        //                 end
        //                 else begin
        //                     TmpDeclEntry."Amount Tendered" := TmpDeclEntry."Amount Tendered" + TransTenderDeclarEntry."Amount Tendered";
        //                     TmpDeclEntry."Amount in Currency" := TmpDeclEntry."Amount in Currency" + TransTenderDeclarEntry."Amount in Currency";
        //                 end;
        //                 TmpDeclEntry.Modify;
        //             end
        //             else begin
        //                 TmpDeclEntry := TransTenderDeclarEntry;
        //                 TmpDeclEntry.Insert;
        //             end;
        //         until TransTenderDeclarEntry.Next = 0;

        if TransDiscEntry.FindFirst then begin
            TransDiscEntry.CalcSums("Discount Amount");
            TransactionStatus."Discount Total Amount" := TransDiscEntry."Discount Amount";
        end;

        TransStatusToBuffer(TransactionStatus);
        //OnAfterMarkTransaction(Transaction, CurrentStatementRecord);
    end;

    local procedure OpenTablesBuffers()
    var
        TransactionStatus: Record "LSC Transaction Status";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status";
        RecRef: RecordRef;
    begin
        RecRef.GETTABLE(TransactionStatus);
        IF BufferUtility.IsBufferOpen(RecRef, 1) THEN
            BufferUtility.CloseBuffer(RecRef, 1);
        BufferUtility.OpenBuffer(RecRef, 1);

        RecRef.GETTABLE(TransSalesEntryStatus);
        IF BufferUtility.IsBufferOpen(RecRef, 1) THEN
            BufferUtility.CloseBuffer(RecRef, 1);
        BufferUtility.OpenBuffer(RecRef, 1);

        RecRef.GETTABLE(TransSalesEntry);
        IF BufferUtility.IsBufferOpen(RecRef, 1) THEN
            BufferUtility.CloseBuffer(RecRef, 1);
        BufferUtility.OpenBuffer(RecRef, 1);
    end;

    local procedure TransStatusToBuffer(var TransactionStatus: Record "LSC Transaction Status")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TransactionStatus);
        BufferUtility.UpdateRec(RecRef, 1);
    end;

    local procedure GetTransStatusFromBuffer(VAR Transaction: Record "LSC Transaction Header"; VAR TransactionStatus: Record "LSC Transaction Status")
    var
        RecRef: RecordRef;
        lText001: Label 'Record not found %1';
    begin
        TransactionStatus."Store No." := Transaction."Store No.";
        TransactionStatus."POS Terminal No." := Transaction."POS Terminal No.";
        TransactionStatus."Transaction No." := Transaction."Transaction No.";
        RecRef.GetTable(TransactionStatus);
        if not BufferUtility.GetRec(RecRef, 1) then
            Error(lText001, TransactionStatus.RECORDID);
        RecRef.SetTable(TransactionStatus);
    end;

    local procedure TransSalesEntryToBuffer(var TransSalesEntry: Record "LSC Trans. Sales Entry")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TransSalesEntry);
        BufferUtility.UpdateRec(RecRef, 1);
    end;

    local procedure TransSalesEntryStatusToBuffer(var TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TransSalesEntryStatus);
        BufferUtility.UpdateRec(RecRef, 1);
    end;
local procedure FlushTablesBuffers()
    var
        TransactionStatusTmp: Record "LSC Transaction Status" temporary;
        TransactionStatus: Record "LSC Transaction Status";
        TransSalesEntryStatusTmp: Record "LSC Trans. Sales Entry Status" temporary;
        TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status";
        TransSalesEntryTmp: Record "LSC Trans. Sales Entry" temporary;
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TransactionStatusTmp);
        BufferUtility.SetTableFilter(1, RecRef, 1);
        if BufferUtility.FindFirstRec(1, RecRef, 1) then
            repeat
                RecRef.SetTable(TransactionStatusTmp);
                if TransactionStatus.Get(TransactionStatusTmp."Store No.", TransactionStatusTmp."POS Terminal No.", TransactionStatusTmp."Transaction No.") then begin
                    TransactionStatus.TransferFields(TransactionStatusTmp, false);                    
                    TransactionStatus.Modify(true);
                end else begin
                    TransactionStatus.Init;
                    TransactionStatus := TransactionStatusTmp;
                    TransactionStatus.Status := TransactionStatus.Status::Posted;
                    TransactionStatus.Insert(true);
                end;
            until BufferUtility.NextRec(1, 1, RecRef, 1) = 0;
        RecRef.GetTable(TransactionStatusTmp);
        BufferUtility.CloseBuffer(RecRef, 1);

        RecRef.GetTable(TransSalesEntryStatusTmp);
        BufferUtility.SetTableFilter(1, RecRef, 1);
        if BufferUtility.FindFirstRec(1, RecRef, 1) then
            repeat
                RecRef.SetTable(TransSalesEntryStatusTmp);
                if TransSalesEntryStatus.Get(TransSalesEntryStatusTmp."Store No.", TransSalesEntryStatusTmp."POS Terminal No.", TransSalesEntryStatusTmp."Transaction No.",
                TransSalesEntryStatusTmp."Line No.")
                then begin
                    TransSalesEntryStatus.TransferFields(TransSalesEntryStatusTmp, false);
                    TransSalesEntryStatus.Modify(true);
                end else begin
                    TransSalesEntryStatus.Init;
                    TransSalesEntryStatus := TransSalesEntryStatusTmp;
                    TransSalesEntryStatus.Status := TransSalesEntryStatus.Status::Posted;
                    TransSalesEntryStatus.Insert(true);
                end;
            until BufferUtility.NextRec(1, 1, RecRef, 1) = 0;
        RecRef.GetTable(TransSalesEntryStatusTmp);
        BufferUtility.CloseBuffer(RecRef, 1);

        RecRef.GetTable(TransSalesEntryTmp);
        BufferUtility.SetTableFilter(1, RecRef, 1);
        if BufferUtility.FindFirstRec(1, RecRef, 1) then
            repeat
                RecRef.SetTable(TransSalesEntryTmp);
                if TransSalesEntry.Get(TransSalesEntryTmp."Store No.", TransSalesEntryTmp."POS Terminal No.", TransSalesEntryTmp."Transaction No.",
                TransSalesEntryTmp."Line No.")
                then begin
                    TransSalesEntry.TransferFields(TransSalesEntryTmp, false);
                    TransSalesEntry.Modify(true);
                end else begin
                    TransSalesEntry.Init;
                    TransSalesEntry := TransSalesEntryTmp;
                    TransSalesEntry.Insert(true);
                end;
            until BufferUtility.NextRec(1, 1, RecRef, 1) = 0;
        RecRef.GetTable(TransSalesEntryTmp);
        BufferUtility.CloseBuffer(RecRef, 1);
    end;


    var
        Transaction: Record "LSC Transaction Header";
        BufferUtility: Codeunit "LSC Buffer Utility_NT";
        Window: Dialog;
        Counter: Integer;
        NoOfRec: Integer;
        Text001: Label 'Creating Transaction Status\\';
}