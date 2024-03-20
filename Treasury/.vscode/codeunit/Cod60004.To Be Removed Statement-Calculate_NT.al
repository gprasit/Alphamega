codeunit 60004 "Statement-Calculate_NT"
{
    Permissions = TableData "LSC Tender Type" = r,
                  TableData "LSC Trans. Tender Declar. Entr" = rm,
                  TableData "LSC Transaction Header" = rm,
                  TableData "LSC Trans. Sales Entry" = rm,
                  TableData "LSC Trans. Payment Entry" = rm,
                  TableData "LSC Trans. Inc./Exp. Entry" = rm,
                  TableData "LSC Trans. Infocode Entry" = rm,
                  TableData "LSC Statement" = rmd,
                  TableData "LSC Statement Line" = rimd,
                  TableData "LSC Tender TP Card No. Series" = r;
    TableNo = "LSC Statement";

    trigger OnRun()
    var
        StartCalc: Label 'Start of statement calculation';
        EndCalc: Label 'Calculation finished without errors';
    begin
        LockTimeOut(false);

        OnBeforeRunCodeunit(Rec);
        CurrentStatementRecord := Rec;

        DeleteWarningComments(Rec."No.");
        InsertComment(Rec."No.", StartCalc, false);
        InitTmpTables;

        StatementLine2.Reset;
        StatementLine2.SetRange("Statement No.", Rec."No.");
        StatementLine2.SetRange("Store No.", Rec."Store No.");
        if StatementLine2.FindLast then
            NextLine := StatementLine2."Line No." + 10000
        else
            NextLine := 10000;

        SafeStatementLine2.Reset;
        SafeStatementLine2.SetRange("Statement No.", Rec."No.");
        SafeStatementLine2.SetRange("Store No.", Rec."Store No.");
        if SafeStatementLine2.FindLast then
            NextSafeLine := SafeStatementLine2."Line No." + 10000
        else
            NextSafeLine := 10000;

        StatementLine2.Reset;
        StatementLine2.SetCurrentKey("Statement No.", "Statement Code", "Staff ID",
          "POS Terminal No.", "Tender Type", "Tender Type Card No.", "Currency Code");
        StatementLine2.SetRange("Statement No.", Rec."No.");
        StatementLine2.SetRange("Store No.", Rec."Store No.");

        SafeStatementLine2.Reset;
        SafeStatementLine2.SetCurrentKey("Statement No.", "Statement Code", "Staff ID",
          "POS Terminal No.", "Tender Type", "Currency Code", "Bal. Account No.", "Bag No.");
        SafeStatementLine2.SetRange("Statement No.", Rec."No.");
        SafeStatementLine2.SetRange("Store No.", Rec."Store No.");

        Clear(TmpEndOfDayEntry);
        TmpEndOfDayEntry.DeleteAll;

        Clear(TmpEndOfDayComment);
        TmpEndOfDayComment.DeleteAll;

        Store.Get(Rec."Store No.");
        if not FuncProfile.Get(Store."Functionality Profile") then
            if not FuncProfile.Get('##DEFAULT') then
                Clear(FuncProfile);

        if Rec."Closing Method" = Rec."Closing Method"::Shift then
            CalcByShift(Rec)
        else
            CalcByDateTime(Rec);

        if GuiAllowed then
            if CommentLineCounter > 0 then
                Message(WarningCounter, CommentLineCounter);

        Clear(TmpEndOfDayEntry);
        TmpEndOfDayEntry.DeleteAll;

        InsertComment(Rec."No.", EndCalc, false);
        OnAfterRunCodeunit(Rec);
    end;

    var
        StatementLine: Record "LSC Statement Line";
        StatementLine2: Record "LSC Statement Line";
        Transaction: Record "LSC Transaction Header";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        TransPmtEntry: Record "LSC Trans. Payment Entry";
        TransIncomeExpenseEntry: Record "LSC Trans. Inc./Exp. Entry";
        TransTenderDeclarEntry: Record "LSC Trans. Tender Declar. Entr";
        TenderType: Record "LSC Tender Type";
        TenderTypeCardSetup: Record "LSC Tender Type Card Setup";
        POSTerminal: Record "LSC POS Terminal";
        PosTerminalTemp: Record "LSC POS Terminal" temporary;
        POSTerminalTemp2: Record "LSC POS Terminal" temporary;
        Store: Record "LSC Store";
        Item: Record Item;
        Customer: Record Customer;
        CashDeclaration: Record "LSC Cash Declaration";
        TmpDeclEntry: Record "LSC Trans. Tender Declar. Entr" temporary;
        TransSafeEntry: Record "LSC Trans. Safe Entry";
        SafeStatementLine: Record "LSC Safe Statement Line";
        SafeStatementLine2: Record "LSC Safe Statement Line";
        TmpEndOfDayEntry: Record "LSC POS Start Status" temporary;
        FuncProfile: Record "LSC POS Func. Profile";
        TmpEndOfDayComment: Record "LSC POS Start Status" temporary;
        CurrentStatementRecord: Record "LSC Statement";
        ItemTrack: Codeunit "LSC Retail Item Tracking";
        BufferUtility: Codeunit "LSC Buffer Utility_NT";
        ConfirmTxt: Text[250];
        TimeTxt: Text[100];
        StaffPOSFilter: Text[100];
        LastType: Code[10];
        LastCurr: Code[10];
        LastCode: Code[20];
        LastCard: Code[10];
        WrkStaffID: Code[20];
        WrkPOSTerminalNo: Code[10];
        LastStaffID: Code[20];
        TotAmount: Decimal;
        TotCurrAmount: Decimal;
        TotRemovedAmount: Decimal;
        TotAddedAmount: Decimal;
        TotChange: Decimal;
        NextLine: Integer;
        CommentLineCounter: Integer;
        NextSafeLine: Integer;
        LastCommentNo: Integer;
        ErrorLineCounter: Integer;
        NoOfRec: Integer;
        Counter: Integer;
        Skip: Boolean;
        Text000: Label 'and time between %1 and %2';
        Text001: Label 'Do you want to calculate the statement and mark all transactions\';
        Text002: Label 'with date on or before %1 %2 \with the statement number?';
        Text003: Label 'with date %1 %2 \with the statement number?';
        Text004: Label 'with date between %1 and %2 %3 \with the statement number?';
        Text005: Label 'Calculating Statement\\';
        Text006: Label 'Calculate statement and mark transactions ?';
        Text008: Label 'Processing Tender Declarations.\\';
        Text009: Label 'Unknown Tender Type';
        StartCheck: Label 'Start checking for Transactions on POS';
        EndCheck: Label 'Done checking for Transactions on POS';
        ConnectionError: Label 'Could not connect to %3 %1 - %2';
        MissingTrans: Label '%1 %2 missing from %3 %4. Last %2 on %4 is %5 - last local %2 is %6';
        CheckOK: Label '%1 %2 is OK - last %3 number is %4';
        TransWarning: Label 'The system found %1 possible error(s) when checking the %2. Do you want to continue?';
        WarningCounter: Label '%1 warnings or errors were generated while calculating the statement';
        AbortTxt: Label 'Aborting';
        RecordNotFoundErr: Label 'Record not found %1';
        EndOfDayMissing: Label 'Warning - End of Day Declaration is missing for Store %1, %2 %3';
        NewTransSkipCalc: Label 'Warning - New transactions without End of Day Declaration are not calculated for Store %1, %2 %3';

    local procedure CalcByDateTime(var Statement: Record "LSC Statement")
    var
        RetailCommentLine: Record "LSC Retail Comment Line";
        Window: Dialog;
        SavedErrLineCounter: Integer;
    begin
        OnBeforeCalcByDateTime(Statement);
        Statement.TestField("Trans. Ending Date");
        Statement.TestField("Trans. Starting Date");
        Statement.TestField("Store No.");

        Store.Get(Statement."Store No.");
        Statement.Method := Store."Statement Method";

        PosTerminalTemp.DeleteAll;
        POSTerminal.Reset;
        POSTerminal.SetCurrentKey("Store No.");
        POSTerminal.SetRange("Store No.", Statement."Store No.");
        if POSTerminal.FindSet then
            repeat
                PosTerminalTemp := POSTerminal;
                if not POSTerminal."Terminal Statement" then
                    PosTerminalTemp."Statement Method" := Store."Statement Method";
                PosTerminalTemp.Insert;
            until POSTerminal.Next = 0;

        if not Statement."Skip Confirmation" then begin
            if (Statement."Trans. Ending Time" <> 0T) or (Statement."Trans. Starting Time" <> 0T) then
                TimeTxt := StrSubstNo(Text000, Statement."Trans. Starting Time", Statement."Trans. Ending Time")
            else
                TimeTxt := '';
            if Statement."Trans. Starting Date" = 0D then
                ConfirmTxt := StrSubstNo(Text001 + Text002, Statement."Trans. Ending Date", TimeTxt)
            else
                if Statement."Trans. Starting Date" = Statement."Trans. Ending Date" then
                    ConfirmTxt := StrSubstNo(Text001 + Text003, Statement."Trans. Ending Date", TimeTxt)
                else
                    ConfirmTxt := StrSubstNo(Text001 + Text004, Statement."Trans. Starting Date", Statement."Trans. Ending Date", TimeTxt);

            if not Confirm(ConfirmTxt) then
                exit;
        end;

        Transaction.SetCurrentKey("Store No.", Date);
        Transaction.SetRange("Store No.", Statement."Store No.");
        Transaction.SetRange(Date, Statement."Trans. Starting Date", Statement."Trans. Ending Date");
        CheckTransactions(Transaction, Statement);
        Transaction.Reset;

        if FuncProfile."Check for Missing Transactions" then begin
            SavedErrLineCounter := ErrorLineCounter;
            CheckMissingTransFromPOS(Statement);
            Commit;  // needed to commit the RetailCommentLines
            if GuiAllowed then begin
                RetailCommentLine.FindLast;
                if ErrorLineCounter <> SavedErrLineCounter then begin
                    RetailCommentLine.SetRange("Table No.", Database::"LSC Statement");
                    RetailCommentLine.SetRange("No.", Statement."No.");
                    RetailCommentLine.SetFilter("Line No.", '>%1', LastCommentNo);
                    Page.Run(0, RetailCommentLine);
                    if not Confirm(StrSubstNo(TransWarning, ErrorLineCounter - SavedErrLineCounter, Statement.TableCaption), true) then
                        Error(AbortTxt);
                end;
            end;
        end;

        Statement."Calculated Date" := Today;
        Statement."Calculated Time" := Time;
        Transaction.SetCurrentKey("Store No.", Date);
        Transaction.SetRange("Store No.", Statement."Store No.");
        Transaction.SetRange(Date, Statement."Trans. Starting Date", Statement."Trans. Ending Date");
        Transaction.SetFilter("Transaction Type", '<>%1', Transaction."Transaction Type"::PhysInv);
        StaffPOSFilter := Statement."Staff/POS Term Filter Internal";
        if StaffPOSFilter <> '' then begin
            if Statement.Method = Statement.Method::Staff then
                Transaction.SetFilter("Staff ID", StaffPOSFilter);
            if Statement.Method = Statement.Method::"POS Terminal" then
                Transaction.SetFilter("POS Terminal No.", StaffPOSFilter);
        end;
        Transaction.SetAutoCalcFields("Posted Statement No.");

        OpenTablesBuffers();
        NoOfRec := Transaction.Count;
        Counter := 0;
        if GuiAllowed then
            Window.Open(Text005 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@');

        if Transaction.FindSet then
            repeat
                if ProcessTrans(Statement) then begin
                    Skip := false;
                    Counter := Counter + 1;
                    if GuiAllowed then
                        Window.Update(1, Round(Counter / NoOfRec * 10000, 1));
                    if Transaction.Date = Statement."Trans. Ending Date" then begin
                        if (Statement."Trans. Ending Time" <> 0T) and
                              (Statement."Trans. Ending Time" < Transaction.Time)
                        then
                            Skip := true;
                        if (Statement."Trans. Starting Time" <> 0T) and
                              (Statement."Trans. Starting Date" = 0D) and
                              (Statement."Trans. Starting Time" > Transaction.Time)
                        then
                            Skip := true;
                    end;
                    if (Transaction.Date = Statement."Trans. Starting Date") and
                       (Statement."Trans. Starting Time" <> 0T) and
                       (Statement."Trans. Starting Time" > Transaction.Time)
                    then
                        Skip := true;
                    if not Skip then
                        MarkTransaction(Statement."No.", Statement."Closing Method", Statement);
                end;
            until Transaction.Next = 0;
        if GuiAllowed then
            Window.Close;

        InsertTendDeclLines(Statement);
        FlushTablesBuffers();
        Statement.Modify;

        StatementCheckSerialNo(Statement);
        OnAfterCalcByDateTime(Statement);
    end;

    local procedure CalcByShift(Statement: Record "LSC Statement")
    var
        Window: Dialog;
    begin
        OnBeforeCalcByShift(Statement);
        Statement.TestField("Shift Date");
        Statement.TestField("Shift No.");
        Statement.TestField("Store No.");
        if not Statement."Skip Confirmation" then
            if not Confirm(Text006) then
                exit;

        PosTerminalTemp.DeleteAll;
        POSTerminal.Reset;
        POSTerminal.SetCurrentKey("Store No.");
        POSTerminal.SetRange("Store No.", Statement."Store No.");
        if POSTerminal.FindSet then
            repeat
                PosTerminalTemp := POSTerminal;
                PosTerminalTemp.Insert;
            until POSTerminal.Next = 0;

        Statement."Calculated Date" := Today;
        Statement."Calculated Time" := Time;

        Transaction.Reset;
        Transaction.SetCurrentKey("Store No.", "Shift Date", "Shift No.");
        Transaction.SetRange("Store No.", Statement."Store No.");
        Transaction.SetRange("Shift Date", Statement."Shift Date");
        Transaction.SetRange("Shift No.", Statement."Shift No.");
        CheckTransactions(Transaction, Statement);

        Transaction.Reset;
        Transaction.SetCurrentKey("Store No.", "Shift Date", "Shift No.");
        Transaction.SetRange("Store No.", Statement."Store No.");
        Transaction.SetRange("Shift Date", Statement."Shift Date");
        Transaction.SetRange("Shift No.", Statement."Shift No.");
        Transaction.SetAutoCalcFields("Posted Statement No.");

        OpenTablesBuffers();
        NoOfRec := Transaction.Count;
        Counter := 0;
        if GuiAllowed then
            Window.Open(Text005 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@');

        Store.Get(Statement."Store No.");

        if Transaction.FindSet then
            repeat
                Counter := Counter + 1;
                if GuiAllowed then
                    Window.Update(1, Round(Counter / NoOfRec * 10000, 1));
                if ProcessTrans(Statement) then
                    MarkTransaction(Statement."No.", Statement."Closing Method", Statement);
            until Transaction.Next = 0;
        if GuiAllowed then
            Window.Close;
        InsertTendDeclLines(Statement);
        FlushTablesBuffers();
        Statement.Modify;

        StatementCheckSerialNo(Statement);
        OnAfterCalcByShift(Statement);
    end;

    local procedure MarkTransaction(StatementNo: Code[20]; StatementClosingMethod: Option "Date and Time",Shift; Stmt: Record "LSC Statement")
    var
        TransactionStatus: Record "LSC Transaction Status";
        TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status";
        TransSalesEntryStatus2: Record "LSC Trans. Sales Entry Status";
        lTenderTypeRec: Record "LSC Tender Type";
        TransDiscEntry: Record "LSC Trans. Discount Entry";
        CurrExchRate: Record "Currency Exchange Rate";
        POSTerminal_l: Record "LSC POS Terminal";
        TransactionHeader_l: Record "LSC Transaction Header";
        ErrorText: Text[250];
        StoreCurrFactor: Decimal;
        UpdateTransSalesEntry: Boolean;
        NewTransSalesEntryStatus: Boolean;
        SerLotNoNotFound: Boolean;
        ItemPosted: Boolean;
    begin
        OnBeforeMarkTransaction(Transaction, CurrentStatementRecord);
        TransSalesEntry.Reset;
        TransPmtEntry.Reset;
        TransTenderDeclarEntry.Reset;

        TransSafeEntry.Reset;

        GetTransStatusFromBuffer(Transaction, TransactionStatus);
        TransactionStatus."Statement No." := StatementNo;
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

                if (TransSalesEntry."Serial No." <> '') and (not ItemPosted) then begin
                    SerLotNoNotFound := TransSalesEntry."Serial/Lot No. Not Valid";
                    TransSalesEntry."Serial/Lot No. Not Valid" := not TransSalesCheckSerialNo(TransSalesEntry, ErrorText);
                    if TransSalesEntry."Serial/Lot No. Not Valid" <> SerLotNoNotFound then
                        UpdateTransSalesEntry := true;
                end;
                if (TransSalesEntry."Lot No." <> '') and (not ItemPosted) then
                    if not ((TransSalesEntry."Serial No." <> '') and (TransSalesEntry."Serial/Lot No. Not Valid")) then begin
                        SerLotNoNotFound := TransSalesEntry."Serial/Lot No. Not Valid";
                        TransSalesEntry."Serial/Lot No. Not Valid" := not TransSalesCheckLotNo(StatementNo, TransSalesEntry, ErrorText);
                        if TransSalesEntry."Serial/Lot No. Not Valid" <> SerLotNoNotFound then
                            UpdateTransSalesEntry := true;
                    end;

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
                TransSalesEntryStatus."Statement No." := StatementNo;
                TransSalesEntryStatus."Item No." := TransSalesEntry."Item No.";
                TransSalesEntryStatus."Variant Code" := TransSalesEntry."Variant Code";
                TransSalesEntryStatus.Quantity := TransSalesEntry.Quantity;
                TransSalesEntryStatus.Date := TransSalesEntry.Date;
                TransSalesEntryStatus."Serial No." := TransSalesEntry."Serial No.";
                TransSalesEntryStatus."Lot No." := TransSalesEntry."Lot No.";

                OnMarkTransOnBeforeTransSalesEntryStatusToBuffer(TransSalesEntryStatus);
                TransSalesEntryStatusToBuffer(TransSalesEntryStatus);
            until TransSalesEntry.Next = 0;

        if TransPmtEntry.FindSet then
            repeat
                if (Transaction."POS Terminal No." <> PosTerminalTemp."No.") or
                   (Transaction."Staff ID" <> LastStaffID) or
                   (LastCode = '')
                then begin
                    PopulateStatementCode(Transaction."POS Terminal No.", Transaction."Staff ID", LastCode, WrkStaffID, WrkPOSTerminalNo);
                    LastStaffID := Transaction."Staff ID";
                end;
                LastType := TransPmtEntry."Tender Type";
                LastCard := TransPmtEntry."Card No.";
                LastCard := '';
                LastCurr := TransPmtEntry."Currency Code";
                if Transaction."Trans. Currency" <> '' then
                    StoreCurrFactor := CurrExchRate.ExchangeRate(Transaction.Date, Transaction."Trans. Currency")
                else
                    StoreCurrFactor := 1;

                if Store."Safe Mgnt. in Use" and
                   (Transaction."Transaction Type" in
                   [Transaction."Transaction Type"::"Remove Tender",
                   Transaction."Transaction Type"::"Float Entry",
                   Transaction."Transaction Type"::"Change Tender",
                   Transaction."Transaction Type"::"Tender Decl."])
                then begin
                    TotAmount := 0;
                    TotCurrAmount := 0;
                end
                else begin
                    TotAmount := TransPmtEntry."Amount Tendered" / StoreCurrFactor;
                    TotCurrAmount := TransPmtEntry."Amount in Currency";
                end;
                TotRemovedAmount := 0;
                TotAddedAmount := 0;
                TotChange := 0;
                case Transaction."Transaction Type" of
                    Transaction."Transaction Type"::"Remove Tender":
                        TotRemovedAmount := TotRemovedAmount + TransPmtEntry."Amount in Currency";
                    Transaction."Transaction Type"::"Float Entry":
                        TotAddedAmount := TotAddedAmount + TransPmtEntry."Amount in Currency";
                    Transaction."Transaction Type"::"Change Tender":
                        TotChange := TotChange + TransPmtEntry."Amount in Currency";
                    Transaction."Transaction Type"::"Tender Decl.":
                        TotRemovedAmount := TotRemovedAmount + TransPmtEntry."Amount in Currency";
                end;

                StatementLine2.SetFilter("Statement Code", '%1', LastCode);
                StatementLine2.SetFilter("Staff ID", '%1', WrkStaffID);
                StatementLine2.SetFilter("POS Terminal No.", '%1', WrkPOSTerminalNo);
                StatementLine2.SetFilter("Tender Type", '%1', LastType);
                StatementLine2.SetFilter("Tender Type Card No.", '%1', LastCard);
                StatementLine2.SetFilter("Currency Code", '%1', LastCurr);
                if StatementLine2.FindFirst then begin
                    StatementLine2.Validate("Trans. Amount", StatementLine2."Trans. Amount" + TotCurrAmount);
                    StatementLine2.Validate("Trans. Amount in LCY", StatementLine2."Trans. Amount in LCY" + TotAmount);
                    if StatementLine2."Trans. Amount" <> 0 then
                        StatementLine2."Real Exchange Rate" := StatementLine2."Trans. Amount in LCY" / StatementLine2."Trans. Amount"
                    else begin
                        if TotCurrAmount = 0 then
                            StatementLine2."Real Exchange Rate" := 1
                        else
                            if SafeStatementLine2."Real Exchange Rate" <> 0 then
                                SafeStatementLine2."Real Exchange Rate" := (SafeStatementLine2."Real Exchange Rate" + (TotAmount / TotCurrAmount)) / 2
                            else
                                SafeStatementLine2."Real Exchange Rate" := TotAmount / TotCurrAmount;
                    end;
                    if not StatementLine2."Counting Required" then begin
                        POSTerminal_l.Get(TransPmtEntry."POS Terminal No.");
                        lTenderTypeRec.Get(Transaction."Store No.", LastType);
                        StatementLine2."Counting Required" := lTenderTypeRec."Counting Required" and ((not Store."Safe Mgnt. in Use") or POSTerminal_l."Exclude from Cash Mgnt.");
                    end;
                    if StatementLine2."Counting Required" then
                        StatementLine2.Validate("Counted Amount", 0)
                    else begin
                        lTenderTypeRec.Get(Transaction."Store No.", LastType);
                        if Store."Safe Mgnt. in Use" and
                           (lTenderTypeRec."Function" <> lTenderTypeRec."Function"::"Tender Remove/Float") and
                           (lTenderTypeRec."Counting Required")
                        then
                            StatementLine2.Validate("Counted Amount", StatementLine2."Counted Amount" - TotAddedAmount - TotRemovedAmount)
                        else
                            StatementLine2.Validate("Counted Amount", StatementLine2."Trans. Amount");
                    end;
                    StatementLine2."Added to Drawer" += TotAddedAmount;
                    StatementLine2."Removed from Drawer" += TotRemovedAmount;
                    StatementLine2."Change Tender" += TotChange;
                    StatementLine2.Modify;
                end
                else begin
                    InsertLine(Stmt, PosTerminalTemp."Statement Method");
                    NextLine := NextLine + 10000;
                end;

            until TransPmtEntry.Next = 0;

        if TransSafeEntry.FindSet then
            repeat
                if (Transaction."POS Terminal No." <> PosTerminalTemp."No.") or
                   (Transaction."Staff ID" <> LastStaffID) or
                   (LastCode = '')
                then begin
                    PopulateStatementCode(Transaction."POS Terminal No.", Transaction."Staff ID", LastCode, WrkStaffID, WrkPOSTerminalNo);
                    LastStaffID := Transaction."Staff ID";
                end;

                InsertBankLine(Stmt, TransSafeEntry, PosTerminalTemp."Statement Method");
                NextSafeLine := NextSafeLine + 10000;
            until TransSafeEntry.Next = 0;

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
        TmpDeclEntry.Reset;

        if not Store."Safe Mgnt. in Use" then
            if TransTenderDeclarEntry.FindSet then
                repeat
                    if StatementClosingMethod = StatementClosingMethod::Shift then begin
                        TmpDeclEntry.SetRange("Shift Date", TransTenderDeclarEntry."Shift Date");
                        TmpDeclEntry.SetRange("Shift No.", TransTenderDeclarEntry."Shift No.");
                    end;

                    if Store."Statement Method" = Store."Statement Method"::Staff then
                        TmpDeclEntry.SetRange("Staff ID", TransTenderDeclarEntry."Staff ID");
                    if Store."Statement Method" = Store."Statement Method"::"POS Terminal" then
                        TmpDeclEntry.SetRange("POS Terminal No.", TransTenderDeclarEntry."POS Terminal No.");

                    TmpDeclEntry.SetRange("Statement Code", TransTenderDeclarEntry."Statement Code");
                    if TmpDeclEntry.FindFirst and (TmpDeclEntry."Transaction No." <> TransTenderDeclarEntry."Transaction No.") and
                       (Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Last)
                    then
                        TmpDeclEntry.DeleteAll;
                    TmpDeclEntry.SetRange("Tender Type", TransTenderDeclarEntry."Tender Type");
                    TmpDeclEntry.SetRange("Card No.", TransTenderDeclarEntry."Card No.");
                    TmpDeclEntry.SetRange("Currency Code", TransTenderDeclarEntry."Currency Code");
                    if TmpDeclEntry.FindFirst then begin
                        if Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Last then begin
                            TmpDeclEntry."Amount Tendered" := TransTenderDeclarEntry."Amount Tendered";
                            TmpDeclEntry."Amount in Currency" := TransTenderDeclarEntry."Amount in Currency";
                        end
                        else begin
                            TmpDeclEntry."Amount Tendered" := TmpDeclEntry."Amount Tendered" + TransTenderDeclarEntry."Amount Tendered";
                            TmpDeclEntry."Amount in Currency" := TmpDeclEntry."Amount in Currency" + TransTenderDeclarEntry."Amount in Currency";
                        end;
                        TmpDeclEntry.Modify;
                    end
                    else begin
                        TmpDeclEntry := TransTenderDeclarEntry;
                        TmpDeclEntry.Insert;
                    end;
                until TransTenderDeclarEntry.Next = 0;

        if TransDiscEntry.FindFirst then begin
            TransDiscEntry.CalcSums("Discount Amount");
            TransactionStatus."Discount Total Amount" := TransDiscEntry."Discount Amount";
        end;

        TransStatusToBuffer(TransactionStatus);
        OnAfterMarkTransaction(Transaction, CurrentStatementRecord);
    end;

    local procedure InsertTendDeclLines(Statement: Record "LSC Statement")
    var
        StatementLineLocal: Record "LSC Statement Line";
        Window: Dialog;
    begin
        if GuiAllowed then
            Window.Open(Text008 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

        TmpDeclEntry.Reset;
        StatementLineLocal.Reset;
        StatementLineLocal.SetRange("Statement No.", Statement."No.");
        Clear(PosTerminalTemp);

        TotAmount := 0;
        TotCurrAmount := 0;
        TotRemovedAmount := 0;
        TotAddedAmount := 0;
        TotChange := 0;
        Counter := 0;
        LastType := '';
        LastCurr := '';
        LastCode := '';
        LastCard := '';
        NextLine := NextLine + 10000;

        NoOfRec := TmpDeclEntry.Count;
        if TmpDeclEntry.FindSet then
            repeat
                Counter := Counter + 1;
                if GuiAllowed then
                    Window.Update(1, Round(Counter / NoOfRec * 10000, 1));
                if (TmpDeclEntry."POS Terminal No." <> PosTerminalTemp."No.") or
                   (TmpDeclEntry."Staff ID" <> LastStaffID)
                then begin
                    PopulateStatementCode(TmpDeclEntry."POS Terminal No.", TmpDeclEntry."Staff ID", LastCode, WrkStaffID, WrkPOSTerminalNo);
                    LastStaffID := TmpDeclEntry."Staff ID";
                end;
                LastType := TmpDeclEntry."Tender Type";
                LastCard := TmpDeclEntry."Card No.";
                LastCard := '';
                LastCurr := TmpDeclEntry."Currency Code";

                StatementLineLocal.SetFilter("POS Terminal No.", '%1', WrkPOSTerminalNo);
                StatementLineLocal.SetFilter("Staff ID", '%1', WrkStaffID);
                StatementLineLocal.SetFilter("Statement Code", '%1', LastCode);
                StatementLineLocal.SetRange("Tender Type", LastType);
                StatementLineLocal.SetFilter("Tender Type Card No.", '%1', LastCard);
                StatementLineLocal.SetFilter("Currency Code", '%1', LastCurr);
                TmpDeclEntry."Amount Tendered" := TmpDeclEntry."Amount Tendered" - TmpDeclEntry."Bank Amount Tendered" -
                  TmpDeclEntry."Safe Amount Tendered" - TmpDeclEntry."Fixed Float Amount Tendered";
                TmpDeclEntry."Amount in Currency" := TmpDeclEntry."Amount in Currency" - TmpDeclEntry."Bank Amount in Currency" -
                  TmpDeclEntry."Safe Amount in Currency" - TmpDeclEntry."Fixed Float Amount in Currency";
                if StatementLineLocal.FindFirst then begin
                    if TmpDeclEntry."Amount in Currency" <> 0 then
                        StatementLineLocal.Validate("Counted Amount", StatementLineLocal."Counted Amount" + TmpDeclEntry."Amount in Currency")
                    else
                        StatementLineLocal.Validate("Counted Amount", StatementLineLocal."Counted Amount" + TmpDeclEntry."Amount Tendered");
                    OnUpdateReferenceNumber(TmpDeclEntry, StatementLineLocal);
                    StatementLineLocal.Modify;
                end
                else begin
                    TotAmount := 0;
                    TotCurrAmount := 0;
                    Transaction."POS Terminal No." := TmpDeclEntry."POS Terminal No.";
                    Transaction."Staff ID" := TmpDeclEntry."Staff ID";
                    if PosTerminalTemp."Statement Method" <> Statement.Method then begin
                        InsertLine(Statement, PosTerminalTemp."Statement Method");
                        NextLine := NextLine + 10000;
                    end else begin
                        InsertLine(Statement, Statement.Method);
                        NextLine := NextLine + 10000;
                    end;
                    if TmpDeclEntry."Amount in Currency" <> 0 then
                        StatementLine.Validate("Counted Amount", TmpDeclEntry."Amount in Currency")
                    else
                        StatementLine.Validate("Counted Amount", TmpDeclEntry."Amount Tendered");
                    OnUpdateReferenceNumber(TmpDeclEntry, StatementLine);
                    StatementLine.Modify;
                end;
            until TmpDeclEntry.Next = 0;

        if GuiAllowed then
            Window.Close;
    end;

    local procedure InsertLine(Statement: Record "LSC Statement"; StatementMethodLoc: Option Staff,"POS Terminal",Total)
    var
        lTenderType: Record "LSC Tender Type";
        POSTerminal_l: Record "LSC POS Terminal";
        CountRequired: Boolean;
    begin
        CountRequired := true;
        case StatementMethodLoc of
            StatementMethodLoc::Staff:
                begin
                    StatementLine."Staff ID" := LastCode;
                    StatementLine."POS Terminal No." := '';
                end;
            StatementMethodLoc::"POS Terminal":
                begin
                    StatementLine."Staff ID" := '';
                    StatementLine."POS Terminal No." := LastCode;
                end;
            StatementMethodLoc::Total:
                begin
                    StatementLine."Staff ID" := '';
                    StatementLine."POS Terminal No." := '';
                end;
        end;
        StatementLine."Statement No." := Statement."No.";
        StatementLine."Line No." := NextLine;
        StatementLine."Statement Code" := LastCode;
        StatementLine."Tender Type" := LastType;
        StatementLine."Tender Type Card No." := LastCard;
        StatementLine."Currency Code" := LastCurr;
        StatementLine."Trans. Amount" := TotCurrAmount;
        StatementLine."Trans. Amount in LCY" := TotAmount;
        StatementLine."Counted Amount" := 0;
        StatementLine."Counted Amount in LCY" := 0;
        StatementLine."Store No." := Statement."Store No.";
        if TotCurrAmount <> 0 then
            StatementLine."Real Exchange Rate" := TotAmount / TotCurrAmount
        else
            StatementLine."Real Exchange Rate" := 1;
        if LastCard <> '' then begin
            if TenderTypeCardSetup.Get(
               StatementLine."Store No.", StatementLine."Tender Type", StatementLine."Tender Type Card No.")
            then begin
                StatementLine."Tender Type Name" := TenderTypeCardSetup.Description;
                CountRequired := TenderTypeCardSetup."Counting Required";
            end else
                StatementLine."Tender Type Name" := Text009;
        end else
            if TenderType.Get(StatementLine."Store No.", StatementLine."Tender Type") then begin
                StatementLine."Tender Type Name" := TenderType.Description;
                if StatementLine."POS Terminal No." <> '' then
                    POSTerminal_l.Get(StatementLine."POS Terminal No.")
                else
                    POSTerminal_l.Init;
                CountRequired := TenderType."Counting Required" and ((not Store."Safe Mgnt. in Use") or POSTerminal_l."Exclude from Cash Mgnt.");
            end else
                StatementLine."Tender Type Name" := Text009;

        StatementLine."Counting Required" := CountRequired;
        if StatementLine."Currency Code" <> '' then
            StatementLine."Tender Type Name" := StatementLine."Tender Type Name" + ' ' + StatementLine."Currency Code";

        StatementLine."Added to Drawer" := TotAddedAmount;
        StatementLine."Removed from Drawer" := TotRemovedAmount;
        StatementLine."Change Tender" := TotChange;
        if not CountRequired then begin
            lTenderType.Get(Store."No.", StatementLine."Tender Type");
            if Store."Safe Mgnt. in Use" and
               (lTenderType."Function" <> lTenderType."Function"::"Tender Remove/Float") and
               (lTenderType."Counting Required")
            then
                StatementLine.Validate("Counted Amount", -TotAddedAmount - TotRemovedAmount)
            else
                StatementLine.Validate("Counted Amount", StatementLine."Trans. Amount");
        end else
            StatementLine.Validate("Counted Amount", 0);
        OnBeforeInsertStatementLine(StatementLine, Store, POSTerminal);
        StatementLine.Insert(true);
    end;

#if __IS_SAAS__
    internal
#endif
    procedure SetTransactionsFree(Statement: Record "LSC Statement")
    var
        TransactionStatus: Record "LSC Transaction Status";
        TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status";
        RetailCommentLine: Record "LSC Retail Comment Line";
        WorkShiftRBO: Record "LSC Work Shift RBO";
    begin
        TransactionStatus.Reset;
        TransactionStatus.SetCurrentKey("Statement No.");
        TransactionStatus.SetRange("Statement No.", Statement."No.");
        TransactionStatus.ModifyAll("Statement No.", '', true);

        TransSalesEntryStatus.Reset;
        TransSalesEntryStatus.SetCurrentKey("Statement No.");
        TransSalesEntryStatus.SetRange("Statement No.", Statement."No.");
        TransSalesEntryStatus.ModifyAll("Statement No.", '', true);

        CashDeclaration.Reset;
        CashDeclaration.SetRange("Statement No.", Statement."No.");
        CashDeclaration.DeleteAll(true);

        StatementLine.Reset;
        StatementLine.SetRange("Statement No.", Statement."No.");
        StatementLine.DeleteAll;

        SafeStatementLine.Reset;
        SafeStatementLine.SetRange("Statement No.", Statement."No.");
        SafeStatementLine.DeleteAll;

        RetailCommentLine.SetRange("Table No.", Database::"LSC Statement");
        RetailCommentLine.SetRange("No.", Statement."No.");
        RetailCommentLine.DeleteAll;

        WorkShiftRBO.Reset;
        WorkShiftRBO.SetCurrentKey("Statement No.");
        WorkShiftRBO.SetRange("Statement No.", Statement."No.");
        WorkShiftRBO.ModifyAll("Statement No.", '', true);
    end;

    local procedure ProcessTrans(Statement: Record "LSC Statement"): Boolean
    var
        TransactionStatus: Record "LSC Transaction Status";
    begin
        //ProcessTrans
        OnBeforeProcessTransaction(Transaction, Statement);
        if Transaction."Transaction Type" in
           [Transaction."Transaction Type"::Logon, Transaction."Transaction Type"::Logoff, Transaction."Transaction Type"::"Open Drawer"]
        then
            exit(false);
        if Transaction."Entry Status" <> Transaction."Entry Status"::" " then
            exit(false);

        if Transaction."Posted Statement No." <> '' then
            exit(false);

        if not IsTransWithEndOfDay(Transaction, Statement) then
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
            exit(TransactionStatus."Statement No." = '');
        end;
        OnAfterProcessTransaction(Transaction, Statement);
    end;

    local procedure InitTmpTables()
    begin
        TmpDeclEntry.DeleteAll;
    end;

    local procedure PopulateStatementCode(POSTermNo: Code[10]; StaffID: Code[20]; var RetStatementCode: Code[20]; var RetStaffID: Code[20]; var RetPOSTerminalNo: Code[10])
    begin
        if PosTerminalTemp."No." <> POSTermNo then
            PosTerminalTemp.Get(POSTermNo);

        RetStatementCode := '';
        RetStaffID := '';
        RetPOSTerminalNo := '';

        if PosTerminalTemp."Statement Method" <> Store."Statement Method" then
            case PosTerminalTemp."Statement Method" of
                PosTerminalTemp."Statement Method"::Staff:
                    begin
                        RetStatementCode := StaffID;
                        RetStaffID := StaffID;
                    end;
                PosTerminalTemp."Statement Method"::"POS Terminal":
                    begin
                        RetStatementCode := POSTermNo;
                        RetPOSTerminalNo := POSTermNo;
                    end;
                PosTerminalTemp."Statement Method"::Total:
                    RetStatementCode := '';
            end
        else
            case Store."Statement Method" of
                Store."Statement Method"::Staff:
                    begin
                        RetStatementCode := StaffID;
                        RetStaffID := StaffID;
                    end;
                Store."Statement Method"::"POS Terminal":
                    begin
                        RetStatementCode := POSTermNo;
                        RetPOSTerminalNo := POSTermNo;
                    end;
                Store."Statement Method"::Total:
                    RetStatementCode := '';
            end;
    end;

    local procedure IsSerialNoInTransSalesEntry(pTransSalesEntry: Record "LSC Trans. Sales Entry"): Boolean
    var
        TransSalesEntry_Loc: Record "LSC Trans. Sales Entry";
        TransactionStatus: Record "LSC Transaction Status";
    begin
        TransSalesEntry_Loc.Reset;
        TransSalesEntry_Loc.SetCurrentKey("Item No.", "Variant Code");
        TransSalesEntry_Loc.SetRange("Item No.", pTransSalesEntry."Item No.");
        TransSalesEntry_Loc.SetRange("Variant Code", pTransSalesEntry."Variant Code");
        TransSalesEntry_Loc.SetRange("Serial No.", pTransSalesEntry."Serial No.");
        if pTransSalesEntry.Quantity >= 0 then
            TransSalesEntry_Loc.SetFilter(Quantity, '>=0')
        else
            TransSalesEntry_Loc.SetFilter(Quantity, '<0');
        if TransSalesEntry_Loc.FindSet then
            repeat
                if (TransSalesEntry_Loc."Store No." <> pTransSalesEntry."Store No.") or
                   (TransSalesEntry_Loc."POS Terminal No." <> pTransSalesEntry."POS Terminal No.") or
                   (TransSalesEntry_Loc."Transaction No." <> pTransSalesEntry."Transaction No.") or
                   (TransSalesEntry_Loc."Line No." <> pTransSalesEntry."Line No.")
                then
                    if TransactionStatus.Get(TransSalesEntry_Loc."Store No.",
                       TransSalesEntry_Loc."POS Terminal No.",
                       TransSalesEntry_Loc."Transaction No.")
                    then
                        if TransactionStatus.Status = TransactionStatus.Status::" " then
                            exit(true);
            until TransSalesEntry_Loc.Next = 0;
        exit(false);
    end;

    local procedure InsertBankLine(Statement: Record "LSC Statement"; TrSafeEntry: Record "LSC Trans. Safe Entry"; StatementMethodLoc: Option Staff,"POS Terminal",Total)
    var
        GLAcc: Record "G/L Account";
        BankAcc: Record "Bank Account";
        SafeLedgerEntry: Record "LSC Safe Ledger Entry";
    begin
        SafeStatementLine2.SetRange("Statement Code", LastCode);
        case StatementMethodLoc of
            StatementMethodLoc::Staff:
                begin
                    SafeStatementLine2.SetRange("Staff ID", LastCode);
                    SafeStatementLine2.SetRange("POS Terminal No.", '');
                end;
            StatementMethodLoc::"POS Terminal":
                begin
                    SafeStatementLine2.SetRange("Staff ID", '');
                    SafeStatementLine2.SetRange("POS Terminal No.", LastCode);
                end;
        end;
        Clear(SafeStatementLine);
        case StatementMethodLoc of
            StatementMethodLoc::Staff:
                begin
                    SafeStatementLine."Staff ID" := LastCode;
                    SafeStatementLine."POS Terminal No." := '';
                end;
            StatementMethodLoc::"POS Terminal":
                begin
                    SafeStatementLine."Staff ID" := '';
                    SafeStatementLine."POS Terminal No." := LastCode;
                end;
        end;
        SafeStatementLine."Statement No." := Statement."No.";
        SafeStatementLine."Line No." := NextSafeLine;
        SafeStatementLine."Statement Code" := LastCode;
        SafeStatementLine."Transaction Type" := TrSafeEntry."Transaction Type";
        SafeStatementLine."Tender Type" := TrSafeEntry."Tender Type";
        SafeStatementLine."Tender Type Card No." := TrSafeEntry."Card No.";
        SafeStatementLine."Currency Code" := TrSafeEntry."Currency Code";
        SafeStatementLine."Bal. Account Type" := TrSafeEntry."Bal. Account Type";
        SafeStatementLine."Bal. Account No." := TrSafeEntry."Bal. Account No.";
        if SafeStatementLine."Bal. Account Type" = SafeStatementLine."Bal. Account Type"::"G/L Account" then begin
            GLAcc.Get(SafeStatementLine."Bal. Account No.");
            SafeStatementLine."Bal. Account Name" := GLAcc.Name;
        end else
            if SafeStatementLine."Bal. Account Type" = SafeStatementLine."Bal. Account Type"::"Bank Account" then begin
                BankAcc.Get(SafeStatementLine."Bal. Account No.");
                SafeStatementLine."Bal. Account Name" := BankAcc.Name;
            end;

        SafeStatementLine."Bag No." := TrSafeEntry."Bank Bag No.";
        SafeStatementLine."Trans. Amount" := TrSafeEntry."Amount in Currency";
        SafeStatementLine."Trans. Amount in LCY" := TrSafeEntry."Amount Tendered";
        SafeStatementLine.Amount := 0;
        SafeStatementLine."Amount in LCY" := 0;
        SafeStatementLine."Store No." := Statement."Store No.";
        if TrSafeEntry."Amount in Currency" <> 0 then
            SafeStatementLine."Real Exchange Rate" := Round(TrSafeEntry."Amount Tendered" / TrSafeEntry."Amount in Currency", 0.000001)
        else
            SafeStatementLine."Real Exchange Rate" := 1;

        if TrSafeEntry.Description <> '' then
            SafeStatementLine.Description := TrSafeEntry.Description
        else
            if TenderType.Get(SafeStatementLine."Store No.", SafeStatementLine."Tender Type") then
                SafeStatementLine.Description := TenderType.Description
            else
                SafeStatementLine.Description := Text009;

        if (SafeStatementLine."Currency Code" <> '') and (StrPos(SafeStatementLine.Description, SafeStatementLine."Currency Code") = 0) then
            SafeStatementLine.Description :=
              CopyStr(StrSubstNo('%1 %2', SafeStatementLine.Description, SafeStatementLine."Currency Code"), 1, MaxStrLen(SafeStatementLine.Description));

        SafeStatementLine.Validate(Amount, SafeStatementLine."Trans. Amount");
        SafeStatementLine."Safe No." := TrSafeEntry."Safe No.";
        SafeLedgerEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.");
        SafeLedgerEntry.SetRange("Store No.", TrSafeEntry."Store No.");
        SafeLedgerEntry.SetRange("POS Terminal No.", TrSafeEntry."POS Terminal No.");
        SafeLedgerEntry.SetRange("Transaction No.", TrSafeEntry."Transaction No.");
        SafeLedgerEntry.SetRange("Line No.", TrSafeEntry."Line No.");
        if SafeLedgerEntry.FindFirst then
            SafeStatementLine."Safe Ledger Entry No." := SafeLedgerEntry."Entry No.";
        SafeStatementLine.Insert;
    end;

    local procedure CheckTransactions(var Transaction: Record "LSC Transaction Header"; var Statement: Record "LSC Statement")
    var
        TmpPOS: Record "LSC POS Terminal" temporary;
        TmpTrans: Record "LSC Transaction Header" temporary;
        POSTerminal_Loc: Record "LSC POS Terminal";
        FirstTransaction: Record "LSC Transaction Header";
        LastTransaction: Record "LSC Transaction Header";
        SalesEntry: Record "LSC Trans. Sales Entry";
        PaymentEntry: Record "LSC Trans. Payment Entry";
        TransactionHeaderCount: Record "LSC Transaction Header";
        ItemCount: Decimal;
        TransCount: Integer;
        PaymentEntryCount: Integer;
        TransactionIsOutsideTimeRange: Boolean;
        LastTransNotLogoff: Label 'Warning - The last %1 from %2 %3 is not a Logoff transaction';
        PrevTransMissing: Label 'Warning - %1 %2 from %3 %4, %5 %6 seems to be missing';
        SalesEntryMissing: Label 'Warning - Calculated item quantity %1 from %3 %4 does not match the registered quantity %2';
        EntryMissing: Label 'Warning - %1 %2 records were found from %3 %4, %5 were expected';
        TransTrainCount: Integer;
    begin
        // The purpose of this function is to check if all the transactions within the statement
        // are in sequence. This helps spot missing transactions that might have been lost due to
        // database corruption or similar incidents.

        // We start by buffering up the POS Terminals that are present in the statement. This would
        // not be necessary if we had a nice GROUPBY command

        Clear(CommentLineCounter);
        if Transaction.FindSet(false, false) then
            repeat
                if Transaction."Statement No." = '' then begin
                    //Exclude Transactions outside Statement."Trans. Starting Time" and Statement."Trans. Ending Time"
                    TransactionIsOutsideTimeRange := false;
                    if (Statement."Trans. Starting Time" > 0T) and
                       (Transaction.Date = Statement."Trans. Starting Date") and
                       (Transaction.Time < Statement."Trans. Starting Time")
                    then
                        TransactionIsOutsideTimeRange := true;
                    if not TransactionIsOutsideTimeRange then
                        if (Statement."Trans. Ending Time" > 0T) and
                           (Transaction.Date = Statement."Trans. Ending Date") and
                           (Transaction.Time > Statement."Trans. Ending Time")
                        then
                            TransactionIsOutsideTimeRange := true;
                    if not TransactionIsOutsideTimeRange then begin
                        OnBeforeCheckTransaction(Transaction, Statement);

                        if not TmpPOS.Get(Transaction."POS Terminal No.") then begin
                            TmpPOS.Init;
                            TmpPOS."No." := Transaction."POS Terminal No.";
                            TmpPOS.Insert;
                        end;

                        if not TmpTrans.Get('', Transaction."POS Terminal No.", 1) then begin
                            TmpTrans.Init;
                            TmpTrans."Store No." := '';
                            TmpTrans."POS Terminal No." := Transaction."POS Terminal No.";
                            TmpTrans."Transaction No." := 1;
                            TmpTrans.Insert;
                        end;

                        if Transaction."Entry Status" <> Transaction."Entry Status"::Training then begin
                            TmpPOS."Sum of Trans. No." += Transaction."Transaction No.";
                            TmpPOS."Count of Trans." += 1;
                            TmpPOS.Modify;

                            TmpTrans."No. of Item Lines" += Transaction."No. of Item Lines";
                            TmpTrans."No. of Payment Lines" += Transaction."No. of Payment Lines";
                            TmpTrans.Modify;
                        end;

                        if (Transaction."Transaction Type" = Transaction."Transaction Type"::"Tender Decl.") and
                           (Transaction."Entry Status" = Transaction."Entry Status"::" ")
                        then
                            FindLastTenderDecl(Transaction, Store, CurrentStatementRecord."No.");
                        OnAfterCheckTransaction(Transaction, Statement);
                    end;
                end;
            until Transaction.Next = 0;

        // At this stage we have gone through all the transactions within the statement and
        // have summed up the transaction numbers as well as the number of sales and payment
        // lines. We can therefore start the comparison

        if TmpPOS.FindSet(false, false) then
            repeat
                POSTerminal_Loc.Get(TmpPOS."No.");
                TmpTrans.Get('', POSTerminal_Loc."No.", 1);
                if Transaction.GetFilter(Date) <> '' then
                    POSTerminal_Loc.SetFilter("Date Filter", Transaction.GetFilter(Date));
                POSTerminal_Loc.CalcFields("First Trans. No.", "Last Trans. No.");

                LastTransaction.Get(POSTerminal_Loc."Store No.", POSTerminal_Loc."No.", POSTerminal_Loc."Last Trans. No.");
                if (LastTransaction."Transaction Type" <> LastTransaction."Transaction Type"::Logoff) and FuncProfile.RegisterLogonLogoff then
                    InsertComment(
                      Statement."No.", StrSubstNo(LastTransNotLogoff, TmpTrans.TableCaption,
                      POSTerminal_Loc.TableCaption, POSTerminal_Loc."No."), true);

                if POSTerminal_Loc."First Trans. No." <> 1 then
                    if not FirstTransaction.Get(POSTerminal_Loc."Store No.", POSTerminal_Loc."No.", POSTerminal_Loc."First Trans. No." - 1) then
                        InsertComment(
                          Statement."No.", StrSubstNo(PrevTransMissing, TmpTrans.TableCaption, POSTerminal_Loc."First Trans. No." - 1,
                          Store.TableCaption, POSTerminal_Loc."Store No.", POSTerminal_Loc.TableCaption, POSTerminal_Loc."No."), true);

                TransCount := POSTerminal_Loc."Last Trans. No." - POSTerminal_Loc."First Trans. No." + 1;
                TransactionHeaderCount.SetRange("Store No.", POSTerminal_Loc."Store No.");
                TransactionHeaderCount.SetRange("POS Terminal No.", POSTerminal_Loc."No.");
                TransactionHeaderCount.SetRange("Transaction No.", POSTerminal_Loc."First Trans. No.", POSTerminal_Loc."Last Trans. No.");
                TransactionHeaderCount.SetRange("Entry Status", TransactionHeaderCount."Entry Status"::Training);
                TransTrainCount := TransactionHeaderCount.Count;
                TransCount := TransCount - TransTrainCount;
                if TransCount <> TmpPOS."Count of Trans." then
                    InsertComment(
                      Statement."No.", StrSubstNo(EntryMissing, TmpPOS."Count of Trans.", TmpTrans.TableCaption,
                      TmpPOS.TableCaption, TmpPOS."No.", TransCount), true);

                ItemCount := 0;
                SalesEntry.Reset;
                SalesEntry.SetRange("Store No.", POSTerminal_Loc."Store No.");
                SalesEntry.SetRange("POS Terminal No.", POSTerminal_Loc."No.");
                SalesEntry.SetRange("Transaction No.", POSTerminal_Loc."First Trans. No.", POSTerminal_Loc."Last Trans. No.");

                ItemCount := SalesEntry.Count;

                if ItemCount <> TmpTrans."No. of Item Lines" then
                    InsertComment(
                      Statement."No.", StrSubstNo(SalesEntryMissing, ItemCount, TmpTrans."No. of Item Lines", TmpPOS.TableCaption,
                      TmpPOS."No."), true);

                PaymentEntry.Reset;
                PaymentEntry.SetRange("Store No.", POSTerminal_Loc."Store No.");
                PaymentEntry.SetRange("POS Terminal No.", POSTerminal_Loc."No.");
                PaymentEntry.SetRange("Transaction No.", POSTerminal_Loc."First Trans. No.", POSTerminal_Loc."Last Trans. No.");
                PaymentEntryCount := PaymentEntry.Count;
                if PaymentEntryCount <> TmpTrans."No. of Payment Lines" then
                    InsertComment(
                      Statement."No.", StrSubstNo(EntryMissing, PaymentEntryCount, PaymentEntry.TableCaption, TmpPOS.TableCaption,
                      TmpPOS."No.", TmpTrans."No. of Payment Lines"), true);

            until TmpPOS.Next = 0;
    end;

    local procedure InsertComment(StatementCode: Code[20]; Comment: Text[250]; IsError: Boolean)
    var
        RetailCommentLine: Record "LSC Retail Comment Line";
        LineNo: Integer;
    begin
        RetailCommentLine.Reset;
        RetailCommentLine.SetRange("Table No.", Database::"LSC Statement");
        RetailCommentLine.SetRange("No.", StatementCode);
        if RetailCommentLine.FindLast then
            LineNo := RetailCommentLine."Line No." + 1000
        else
            LineNo := 1000;

        RetailCommentLine.Reset;
        RetailCommentLine."Table No." := Database::"LSC Statement";
        RetailCommentLine."No." := StatementCode;
        RetailCommentLine."Line No." := LineNo;
        RetailCommentLine."Comment Date" := Today;
        RetailCommentLine."Comment Time" := Time;
        RetailCommentLine.Code := '';
        RetailCommentLine.Comment := Comment;
        RetailCommentLine."Error Comment" := IsError;
        RetailCommentLine.Insert(true);
        if IsError then
            ErrorLineCounter += 1
        else
            CommentLineCounter += 1;
    end;

    local procedure DeleteWarningComments(StatementCode: Code[20])
    var
        RetailCommentLine: Record "LSC Retail Comment Line";
    begin
        RetailCommentLine.Reset;
        RetailCommentLine.SetRange("Table No.", Database::"LSC Statement");
        RetailCommentLine.SetRange("No.", StatementCode);
        RetailCommentLine.SetRange("Error Comment", true);
        RetailCommentLine.DeleteAll(true);
    end;

#if __IS_SAAS__
    internal
#endif
    procedure FindLastTenderDecl(TransHeader: Record "LSC Transaction Header"; pStore: Record "LSC Store"; pStatementNo: Code[20])
    var
        EndOfDay: Record "LSC POS Start Status";
        TransactionStatus: Record "LSC Transaction Status";
        lTransTenderDecl: Record "LSC Trans. Tender Declar. Entr";
        lPOSTerminal: Record "LSC POS Terminal";
        lStatementMethod: Option Staff,"POS Terminal",Total;
        InsertEntry: Boolean;
    begin
        lTransTenderDecl.SetRange("Store No.", TransHeader."Store No.");
        lTransTenderDecl.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
        lTransTenderDecl.SetRange("Transaction No.", TransHeader."Transaction No.");
        if not lTransTenderDecl.FindFirst then
            exit;  //Exit if no entry is found

        if pStore."Safe Mgnt. in Use" then begin
            Clear(EndOfDay);
            EndOfDay."Store No." := TransHeader."Store No.";
            lStatementMethod := pStore."Statement Method";
            if lPOSTerminal.Get(TransHeader."POS Terminal No.") then
                if lPOSTerminal."Terminal Statement" and (lPOSTerminal."Statement Method" <> lStatementMethod) then
                    lStatementMethod := lPOSTerminal."Statement Method";
            case lStatementMethod of
                lStatementMethod::Staff:
                    begin
                        EndOfDay.Type := EndOfDay.Type::Staff;
                        EndOfDay.Id := TransHeader."Staff ID";
                    end;
                lStatementMethod::"POS Terminal":
                    begin
                        EndOfDay.Type := EndOfDay.Type::"POS Terminal";
                        EndOfDay.Id := TransHeader."POS Terminal No.";
                    end;
                else begin
                        EndOfDay.Type := 0;
                        EndOfDay.Id := '';
                    end;
            end;

            InsertEntry := true;

            if TransactionStatus.Get(TransHeader."Store No.", TransHeader."POS Terminal No.", TransHeader."Transaction No.") then
                if (TransactionStatus."Statement No." <> '') and (TransactionStatus."Statement No." <> pStatementNo) then
                    InsertEntry := false;

            if InsertEntry then
                if TmpEndOfDayEntry.Get(EndOfDay."Store No.", EndOfDay.Type, EndOfDay.ID) then begin
                    if TmpEndOfDayEntry."Trans. DateTime" < CreateDateTime(TransHeader."Original Date", TransHeader.Time) then begin
                        TmpEndOfDayEntry."Trans. No." := TransHeader."Transaction No.";
                        TmpEndOfDayEntry."Trans. DateTime" := CreateDateTime(TransHeader."Original Date", TransHeader.Time);
                        TmpEndOfDayEntry.Modify;
                    end;
                end else begin
                    TmpEndOfDayEntry."Store No." := EndOfDay."Store No.";
                    TmpEndOfDayEntry.Type := EndOfDay.Type;
                    TmpEndOfDayEntry.Id := EndOfDay.Id;
                    TmpEndOfDayEntry."Trans. No." := TransHeader."Transaction No.";
                    TmpEndOfDayEntry."Trans. DateTime" := CreateDateTime(TransHeader."Original Date", TransHeader.Time);
                    TmpEndOfDayEntry.Insert;
                end;
        end;
    end;

    local procedure IsTransWithEndOfDay(TransHeader: Record "LSC Transaction Header"; Statement: Record "LSC Statement"): Boolean
    var
        EndOfDay: Record "LSC POS Start Status";
        POSTerminal_l: Record "LSC POS Terminal";
        ReturnStat: Boolean;
        Handled: Boolean;
        lStatementMethod: Option Staff,"POS Terminal",Total;
        EndOfDayMissing: Label 'Warning - End of Day Declaration is missing for Store %1, %2 %3';
    begin
        OnBeforeIsTransWithEndOfDay(TransHeader, Statement, Store, ReturnStat, Handled);
        if Handled then
            exit(ReturnStat);

        POSTerminal_l.Get(TransHeader."POS Terminal No.");
        if Store."Safe Mgnt. in Use" and (not POSTerminal_l."Exclude from Cash Mgnt.") then begin
            Clear(EndOfDay);
            EndOfDay."Store No." := TransHeader."Store No.";
            lStatementMethod := Store."Statement Method";
            if POSTerminal_l."Terminal Statement" and (POSTerminal_l."Statement Method" <> lStatementMethod) then
                lStatementMethod := POSTerminal_l."Statement Method";
            case lStatementMethod of
                lStatementMethod::Staff:
                    begin
                        EndOfDay.Type := EndOfDay.Type::Staff;
                        EndOfDay.Id := TransHeader."Staff ID";
                    end;
                lStatementMethod::"POS Terminal":
                    begin
                        EndOfDay.Type := EndOfDay.Type::"POS Terminal";
                        EndOfDay.Id := TransHeader."POS Terminal No.";
                    end;
                else begin
                        EndOfDay.Type := 0;
                        EndOfDay.Id := '';
                    end;
            end;

            if TmpEndOfDayEntry.Get(EndOfDay."Store No.", EndOfDay.Type, EndOfDay.Id) then begin
                if CreateDateTime(TransHeader."Original Date", TransHeader.Time) > TmpEndOfDayEntry."Trans. DateTime" then begin
                    //New Transactions after the first tender declaration are not calculated
                    if not TmpEndOfDayComment.Get(EndOfDay."Store No.", EndOfDay.Type, EndOfDay.Id) then begin
                        TmpEndOfDayComment."Store No." := EndOfDay."Store No.";
                        TmpEndOfDayComment.Type := EndOfDay.Type;
                        TmpEndOfDayComment.Id := EndOfDay.Id;
                        TmpEndOfDayComment.Insert;
                        InsertComment(Statement."No.", StrSubstNo(NewTransSkipCalc, EndOfDay."Store No.", EndOfDay.Type, EndOfDay.Id), true);
                    end;
                    exit(false);
                end;
            end else
                if not TmpEndOfDayComment.Get(EndOfDay."Store No.", EndOfDay.Type, EndOfDay.Id) then begin
                    TmpEndOfDayComment."Store No." := EndOfDay."Store No.";
                    TmpEndOfDayComment.Type := EndOfDay.Type;
                    TmpEndOfDayComment.Id := EndOfDay.Id;
                    TmpEndOfDayComment.Insert;
                    InsertComment(Statement."No.", StrSubstNo(EndOfDayMissing, EndOfDay."Store No.", EndOfDay.Type, EndOfDay.Id), true);
                end;
        end;

        exit(true);
    end;

#if __IS_SAAS__
    internal
#endif
    procedure GetTenderDeclareEntries(var pTmpEndOfDayEntry: Record "LSC POS Start Status" temporary)
    begin
        pTmpEndOfDayEntry.Copy(TmpEndOfDayEntry, true);
    end;

    local procedure StatementCheckSerialNo(var pStatement: Record "LSC Statement")
    var
        TransactionStatus: Record "LSC Transaction Status";
        TransSalesEntry_Loc: Record "LSC Trans. Sales Entry";
        SerialLotQty: Decimal;
        LotNoInv: Decimal;
        ShouldBePositive: Boolean;
        TransOk: Boolean;
        UpdateTransStatus: Boolean;
        SaleIsReturnSale: Boolean;
    begin
        pStatement.CalcFields("Serial/Lot No. Not Valid");
        if pStatement."Serial/Lot No. Not Valid" > 0 then begin
            TransactionStatus.Reset;
            TransactionStatus.SetCurrentKey("Statement No.", "Blocked Customer", "Sale/Pmt. Difference");
            TransactionStatus.SetRange("Statement No.", pStatement."No.");
            TransactionStatus.SetFilter("Serial/Lot No. Not Valid", '>0');
            TransactionStatus.SetRange(Status, TransactionStatus.Status::" ");
            if TransactionStatus.FindSet then
                repeat
                    UpdateTransStatus := false;
                    TransSalesEntry_Loc.Reset;
                    TransSalesEntry_Loc.SetRange("Store No.", TransactionStatus."Store No.");
                    TransSalesEntry_Loc.SetRange("POS Terminal No.", TransactionStatus."POS Terminal No.");
                    TransSalesEntry_Loc.SetRange("Transaction No.", TransactionStatus."Transaction No.");
                    TransSalesEntry_Loc.SetRange("Serial/Lot No. Not Valid", true);
                    if TransSalesEntry_Loc.FindSet then
                        repeat
                            SaleIsReturnSale := TransSalesEntry_Loc.Quantity > 0;
                            if TransSalesEntry_Loc."Serial No." <> '' then begin
                                SerialLotQty := FindStatementSerialLotNoQty(pStatement."No.", TransSalesEntry_Loc);
                                if Abs(SerialLotQty) > 1 then
                                    TransOk := false
                                else begin
                                    ShouldBePositive := NextEntryShouldBePositive(TransSalesEntry_Loc);
                                    if ((SerialLotQty >= 0) and (ShouldBePositive)) or
                                       ((SerialLotQty <= 0) and (not ShouldBePositive))
                                    then
                                        TransOk := true
                                    else
                                        TransOk := false;
                                end;
                                if (not SaleIsReturnSale) and
                                   (TransSalesEntry_Loc."Expiration Date" <> 0D) and (TransSalesEntry_Loc."Expiration Date" < TransSalesEntry_Loc.Date)
                                then
                                    TransOk := false;
                                if TransOk then begin
                                    TransSalesEntry_Loc."Serial/Lot No. Not Valid" := false;
                                    TransSalesEntry_Loc.Modify(true);
                                    TransactionStatus."Serial/Lot No. Not Valid" := TransactionStatus."Serial/Lot No. Not Valid" - 1;
                                    UpdateTransStatus := true;
                                end;
                            end else begin
                                SerialLotQty := FindStatementSerialLotNoQty(pStatement."No.", TransSalesEntry_Loc);
                                LotNoInv := GetSerialLotNoInv(TransSalesEntry_Loc);
                                if (not SaleIsReturnSale) and (-SerialLotQty <= LotNoInv) then
                                    TransOk := true
                                else
                                    TransOk := false;
                                if (not SaleIsReturnSale) and
                                   (TransSalesEntry_Loc."Expiration Date" <> 0D) and (TransSalesEntry_Loc."Expiration Date" < TransSalesEntry_Loc.Date)
                                then
                                    TransOk := false;
                                if TransOk then begin
                                    TransSalesEntry_Loc."Serial/Lot No. Not Valid" := false;
                                    TransSalesEntry_Loc.Modify(true);
                                    TransactionStatus."Serial/Lot No. Not Valid" := TransactionStatus."Serial/Lot No. Not Valid" - 1;
                                    UpdateTransStatus := true;
                                end;
                            end;
                        until TransSalesEntry_Loc.Next = 0;
                    if UpdateTransStatus then
                        TransactionStatus.Modify(true);
                until TransactionStatus.Next = 0;
        end;
    end;

    local procedure FindStatementSerialLotNoQty(pStatementNo: Code[20]; var pTransSalesEntry: Record "LSC Trans. Sales Entry"): Decimal
    var
        TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status";
    begin
        TransSalesEntryStatus.Reset;
        TransSalesEntryStatus.SetCurrentKey("Serial No.", "Lot No.", "Store No.", "Item No.", "Variant Code", Status, "Statement No.");
        TransSalesEntryStatus.SetRange("Statement No.", pStatementNo);
        TransSalesEntryStatus.SetRange("Item No.", pTransSalesEntry."Item No.");
        TransSalesEntryStatus.SetRange("Variant Code", pTransSalesEntry."Variant Code");
        if pTransSalesEntry."Serial No." <> '' then
            TransSalesEntryStatus.SetRange("Serial No.", pTransSalesEntry."Serial No.");
        if pTransSalesEntry."Lot No." <> '' then
            TransSalesEntryStatus.SetRange("Lot No.", pTransSalesEntry."Lot No.");
        TransSalesEntryStatus.SetRange(Status, TransSalesEntryStatus.Status::" ");
        TransSalesEntryStatus.CalcSums(Quantity);
        exit(TransSalesEntryStatus.Quantity);
    end;

    local procedure NextEntryShouldBePositive(var pTransSalesEntry: Record "LSC Trans. Sales Entry"): Boolean
    var
        SerialNoInv: Decimal;
    begin
        SerialNoInv := GetSerialLotNoInv(pTransSalesEntry);
        if SerialNoInv > 0 then
            exit(false)
        else
            exit(true);
    end;

    local procedure GetSerialLotNoInv(var pTransSalesEntry: Record "LSC Trans. Sales Entry"): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        Store.Get(pTransSalesEntry."Store No.");

        ItemLedgerEntry.Reset;
        ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive,
          "Location Code", "Posting Date", "Expiration Date", "Lot No.", "Serial No.");
        ItemLedgerEntry.SetRange("Item No.", pTransSalesEntry."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", pTransSalesEntry."Variant Code");
        ItemLedgerEntry.SetRange("Location Code", Store."Location Code");
        if pTransSalesEntry."Serial No." <> '' then
            ItemLedgerEntry.SetRange("Serial No.", pTransSalesEntry."Serial No.");
        if pTransSalesEntry."Lot No." <> '' then
            ItemLedgerEntry.SetRange("Lot No.", pTransSalesEntry."Lot No.");
        ItemLedgerEntry.CalcSums(Quantity);
        exit(ItemLedgerEntry.Quantity);
    end;

#if __IS_SAAS__
    internal
#endif
    procedure GetSerialLotExpDate(var pTransSalesEntry: Record "LSC Trans. Sales Entry"): Date
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ExpDate: Date;
    begin
        ExpDate := 0D;

        Store.Get(pTransSalesEntry."Store No.");

        ItemLedgerEntry.Reset;
        ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive,
          "Location Code", "Posting Date", "Expiration Date", "Lot No.", "Serial No.");
        ItemLedgerEntry.SetRange("Item No.", pTransSalesEntry."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", pTransSalesEntry."Variant Code");
        ItemLedgerEntry.SetRange("Location Code", Store."Location Code");
        if pTransSalesEntry."Serial No." <> '' then
            ItemLedgerEntry.SetRange("Serial No.", pTransSalesEntry."Serial No.");
        if pTransSalesEntry."Lot No." <> '' then
            ItemLedgerEntry.SetRange("Lot No.", pTransSalesEntry."Lot No.");
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        if ItemLedgerEntry.FindFirst then
            ExpDate := ItemLedgerEntry."Expiration Date";

        exit(ExpDate);
    end;

#if __IS_SAAS__
    internal
#endif
    procedure TransSalesCheckSerialNo(var pTransSalesEntry: Record "LSC Trans. Sales Entry"; var pErrorText: Text[250]): Boolean
    var
        ExpDate: Date;
        SerialNoInv: Decimal;
        SerialNoValid: Boolean;
        SaleIsReturnSale: Boolean;
        lText001: Label 'Serial No. %1 already exists';
        lText002: Label 'Serial No. %1 does not exist';
        lText003: Label 'Serial No. %1 has expired or expiration date is invalid';
    begin
        SerialNoValid := true;
        pErrorText := ' ';
        SaleIsReturnSale := pTransSalesEntry.Quantity > 0;

        if ItemTrack.PublicIsItemSNTracking(pTransSalesEntry."Item No.") then begin
            SerialNoInv := GetSerialLotNoInv(pTransSalesEntry);
            if SaleIsReturnSale then begin
                if (SerialNoInv > 0) or (IsSerialNoInTransSalesEntry(pTransSalesEntry)) then begin
                    pErrorText := StrSubstNo(lText001, pTransSalesEntry."Serial No.");
                    SerialNoValid := false;
                end;
            end else
                if (SerialNoInv < 1) or IsSerialNoInTransSalesEntry(pTransSalesEntry) then begin
                    pErrorText := StrSubstNo(lText002, pTransSalesEntry."Serial No.");
                    SerialNoValid := false;
                end else begin
                    ExpDate := GetSerialLotExpDate(pTransSalesEntry);
                    if (ExpDate <> pTransSalesEntry."Expiration Date") or
                       ((pTransSalesEntry."Expiration Date" <> 0D) and (pTransSalesEntry."Expiration Date" < pTransSalesEntry.Date))
                    then begin
                        pErrorText := StrSubstNo(lText003, pTransSalesEntry."Serial No.");
                        SerialNoValid := false;
                    end;
                end;
        end;

        exit(SerialNoValid);
    end;

#if __IS_SAAS__
    internal
#endif
    procedure TransSalesCheckLotNo(var pStatementNo: Code[20]; var pTransSalesEntry: Record "LSC Trans. Sales Entry"; var pErrorText: Text[250]): Boolean
    var
        ExpDate: Date;
        LotNoInv: Decimal;
        LotOnTransSales: Decimal;
        LotNoValid: Boolean;
        SaleIsReturnSale: Boolean;
        lText001: Label 'Lot No. %1 does not exist or quantity %2 is not available';
        lText002: Label 'Lot No. %1 has expired or expiration date is invalid';
    begin
        LotNoValid := true;
        SaleIsReturnSale := pTransSalesEntry.Quantity > 0;

        if ItemTrack.PublicIsItemLotTracking(pTransSalesEntry."Item No.") then begin
            LotNoInv := GetSerialLotNoInv(pTransSalesEntry);
            LotOnTransSales := -FindStatementSerialLotNoQty(pStatementNo, pTransSalesEntry);
            if not SaleIsReturnSale then
                if LotNoInv < (LotOnTransSales - pTransSalesEntry.Quantity) then begin
                    pErrorText := StrSubstNo(lText001, pTransSalesEntry."Lot No.", -pTransSalesEntry.Quantity);
                    LotNoValid := false;
                end else begin
                    ExpDate := GetSerialLotExpDate(pTransSalesEntry);
                    if (ExpDate <> pTransSalesEntry."Expiration Date") or
                       ((pTransSalesEntry."Expiration Date" <> 0D) and (pTransSalesEntry."Expiration Date" < pTransSalesEntry.Date))
                    then begin
                        pErrorText := StrSubstNo(lText002, pTransSalesEntry."Lot No.");
                        LotNoValid := false;
                    end;
                end;
        end;

        exit(LotNoValid);
    end;

    local procedure CheckMissingTransFromPOS(Statement: Record "LSC Statement")
    var
        DistLocation: Record "LSC Distribution Location";
        POSTerminalLocal: Record "LSC POS Terminal";
        GetLastTransNoForPosUtils: Codeunit GetLastTransNoForPosUtils_NT;
        POSDialog: Dialog;
        ResponseCode: Code[30];
        ErrorMessage: Text;
        Diff: Integer;
        MaxTransNo: Integer;
        POSDialogTxt: Label 'Checking for %1 on %2  #3##########';
        cc: Codeunit "LSC POS Functions";
    begin
        // This function connects to the POS terminals in the statement and checks if there are transactions
        // on the POS that have not been replicated to the HO.
        Store.Get(Statement."Store No.");
        POSTerminalLocal.SetRange("Store No.", Store."No.");
        if not POSTerminalLocal.FindFirst then
            exit;

        GetLocalTrans;
        LastCommentNo := FindLastComment(Statement);
        InsertComment(Statement."No.", StartCheck, false);
        CommentLineCounter -= 1;

        if GuiAllowed then
            POSDialog.Open(StrSubstNo(POSDialogTxt, Transaction.TableCaption, POSTerminal.TableCaption));

        repeat
            if GuiAllowed then
                POSDialog.Update(3, POSTerminal."No.");
            if POSTerminalLocal."Functionality Profile" = '' then
                POSTerminalLocal."Functionality Profile" := Store."Functionality Profile";

            if DistLocation.Get(POSTerminalLocal."No.") then
                if DistLocation."Active for Replication" then begin
                    GetLastTransNoForPosUtils.SetPosFunctionalityProfile(POSTerminalLocal."Functionality Profile");
                    GetLastTransNoForPosUtils.SendRequest(POSTerminalLocal."No.", ResponseCode, ErrorMessage, MaxTransNo);
                    GetLastTransNoForPosUtils.SetCommunicationError(ResponseCode, ErrorMessage);
                    if ErrorMessage = '' then begin
                        POSTerminalTemp2.Get(POSTerminalLocal."No.");
                        if MaxTransNo <> POSTerminalTemp2."AutoLogoff After (Min.)" then begin
                            Diff := MaxTransNo - POSTerminalTemp2."AutoLogoff After (Min.)";
                            InsertComment(
                              Statement."No.",
                              StrSubstNo(
                              MissingTrans, Diff, Transaction.TableCaption,
                              POSTerminalLocal.TableCaption, POSTerminalLocal."No.",
                              MaxTransNo, POSTerminalTemp2."AutoLogoff After (Min.)"), true);
                        end else begin
                            InsertComment(
                              Statement."No.",
                              StrSubstNo(CheckOK, POSTerminalLocal.TableCaption, POSTerminalLocal."No.", Transaction.TableCaption, MaxTransNo), false);
                            CommentLineCounter -= 1;
                        end;
                    end else
                        InsertComment(Statement."No.", ResponseCode + ': ' + ErrorMessage, true);
                end;
        until POSTerminalLocal.Next = 0;

        if GuiAllowed then
            POSDialog.Close;

        InsertComment(Statement."No.", EndCheck, false);
        CommentLineCounter -= 1;
    end;

    local procedure FindLastComment(Statement: Record "LSC Statement"): Integer
    var
        RetailCommentLine: Record "LSC Retail Comment Line";
    begin
        // Find the last comment line before the check so we know which lines to display after the check

        RetailCommentLine.SetRange("Table No.", Database::"LSC Statement");
        RetailCommentLine.SetRange("No.", Statement."No.");
        if RetailCommentLine.FindLast then
            exit(RetailCommentLine."Line No.")
        else
            exit(0);
    end;

    local procedure GetLocalTrans()
    var
        TransactionLocal: Record "LSC Transaction Header";
    begin
        // Find the highest transaction numbers in the local database for each POS

        POSTerminalTemp2.Reset;
        POSTerminalTemp2.DeleteAll;

        POSTerminal.SetRange("Store No.", Store."No.");
        if POSTerminal.FindSet then
            repeat
                POSTerminalTemp2."No." := POSTerminal."No.";

                TransactionLocal.SetRange("Store No.", POSTerminal."Store No.");
                TransactionLocal.SetRange("POS Terminal No.", POSTerminal."No.");
                if TransactionLocal.FindLast then
                    POSTerminalTemp2."AutoLogoff After (Min.)" := TransactionLocal."Transaction No."
                else
                    POSTerminalTemp2."AutoLogoff After (Min.)" := 0;
                POSTerminalTemp2.Insert;
            until POSTerminal.Next = 0;
    end;

    local procedure OpenTablesBuffers()
    var
        TransactionStatus: Record "LSC Transaction Status";
        TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
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

    local procedure TransStatusToBuffer(var TransactionStatus: Record "LSC Transaction Status")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TransactionStatus);
        BufferUtility.UpdateRec(RecRef, 1);
    end;

    local procedure TransSalesEntryStatusToBuffer(var TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TransSalesEntryStatus);
        BufferUtility.UpdateRec(RecRef, 1);
    end;

    local procedure TransSalesEntryToBuffer(var TransSalesEntry: Record "LSC Trans. Sales Entry")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TransSalesEntry);
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCodeunit(var Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCodeunit(var Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcByDateTime(var Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcByDateTime(var Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcByShift(var Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcByShift(var Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMarkTransaction(var TransactionHeader: Record "LSC Transaction Header"; Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMarkTransaction(var TransactionHeader: Record "LSC Transaction Header"; Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessTransaction(var TransactionHeader: Record "LSC Transaction Header"; Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessTransaction(var TransactionHeader: Record "LSC Transaction Header"; Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckTransaction(var TransactionHeader: Record "LSC Transaction Header"; var Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckTransaction(var TransactionHeader: Record "LSC Transaction Header"; var Statement: Record "LSC Statement")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertStatementLine(var StatementLine: Record "LSC Statement Line"; Store: Record "LSC Store"; POSTerminal: Record "LSC POS Terminal")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsTransWithEndOfDay(var TransactionHeader: Record "LSC Transaction Header"; var Statement: Record "LSC Statement"; Store: Record "LSC Store"; var ReturnStat: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateReferenceNumber(TempLSCTransTenderDeclarEntr: Record "LSC Trans. Tender Declar. Entr" temporary; var LSCStatementLine: Record "LSC Statement Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMarkTransOnBeforeTransSalesEntryStatusToBuffer(var TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status")
    begin
    end;
}