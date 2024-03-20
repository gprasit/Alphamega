codeunit 60007 "Statement-Calc.-Post-Main_NT"
{
    trigger OnRun()
    var
        Statement: Record "LSC Statement";
        Statement2: Record "LSC Statement";
        Store: Record "LSC Store";
        WorkShiftRBO: Record "LSC Work Shift RBO";
        BatchPosting: Codeunit "LSC Batch Posting";
        ErrorMsgHandler: Codeunit "Error Message Handler";
        ErrorMsgMgmt: Codeunit "Error Message Management";
        RetailCalendarManagement: Codeunit "LSC Retail Calendar Management";
        //StatementCalculate: Codeunit "LSC Statement-Calculate";
        StatementCalculate: Codeunit "Statement-Calculate_NT";
        StatementPostItem: Codeunit "Statement-Post-Item Sales_NT";
        ErrorContextElement: Codeunit "Error Context Element";
        CheckStatementMsg: Label 'Check statement %1 transactions.';
        OkRun: Boolean;
        TreasuryGenFn: Codeunit "Treasury General Functions_NT";
        ErrorTxt: Text;
        ErrMsgTemp: Record "Error Message" temporary;
    begin
        //Store.SetRange("Auto. Calculate Statement", true);        
        if GlobalStoreNo <> '' then
            Store.SetFilter("No.", GlobalStoreNo);
        if Store.FindSet() then
            repeat
                if Store."Closing Method" = Store."Closing Method"::Shift then begin
                    WorkShiftRBO.SetCurrentKey(WorkShiftRBO."Store No.", Status);
                    WorkShiftRBO.SetRange(WorkShiftRBO."Store No.", Store."No.");
                    if Store."Advanced Shift Method" then
                        WorkShiftRBO.SetRange(WorkShiftRBO.Status, WorkShiftRBO.Status::Closed)
                    else
                        WorkShiftRBO.SetRange(WorkShiftRBO.Status, WorkShiftRBO.Status::Open, WorkShiftRBO.Status::Closed);
                    WorkShiftRBO.SetFilter(WorkShiftRBO."Statement No.", '=%1', '');
                    if WorkShiftRBO.FindSet() then
                        repeat
                            PrepareStatements(Store, false);
                        until WorkShiftRBO.Next() = 0;
                end else begin
                    if OpenAfterMidnight(Store."No.", RetailCalendarManagement.Yesterday(WorkDate)) then begin
                        PrepareStatements(Store, false);
                        PrepareStatements(Store, true);
                    end else
                        PrepareStatements(Store, false);
                end;
            until Store.Next() = 0;

        Commit;

        Clear(Statement);
        Statement.Reset();
        Store.Reset();
        //ErrorMsgMgmt.Activate(ErrorMsgHandler);
        //Store.SetRange("Auto. Calculate Statement", true);
        if GlobalStoreNo <> '' then
            Store.SetFilter("No.", GlobalStoreNo);
        if Store.FindSet() then
            repeat
                Statement.SetRange("Store No.", Store."No.");
                Statement.SetRange("Trans. Starting Date", CalculationDate);
                Statement.SetRange("Trans. Ending Date", CalculationDate);
                if Statement.FindSet() then
                    repeat
                        Clear(StatementPostItem);
                        Clear(BatchPosting);
                        Clear(StatementCalculate);
                        Statement2.Get(Statement."Store No.", Statement."No.");
                        Statement2."Skip Confirmation" := true;
                        //ErrorMsgMgmt.PushContext(ErrorContextElement, Statement2.RecordId, 0, CheckStatementMsg);
                        if BatchPosting.GetStatementStatus(Statement2) < 0 then
                            if StatementCalculate.Run(Statement2) then begin
                                if not StatementPostItem.Run(Statement2) then begin
                                    //ErrorMsgHandler.RegisterErrorMessages();                                    
                                    ErrorTxt := GetLastErrorText();
                                    TreasuryGenFn.ShowErrors(ErrorTxt, Statement2.RecordId, StrSubstNo(CheckStatementMsg, Statement2."No."));
                                end;
                            end else begin
                                ErrorTxt := GetLastErrorText();
                                TreasuryGenFn.ShowErrors(ErrorTxt, Statement2.RecordId, StrSubstNo(CheckStatementMsg, Statement2."No."));
                            end;
                        Commit();//Required to Log the Error Messages otherwise it was going out from the statment loop. Need to investigate.
                    until Statement.Next() = 0;
            until Store.Next() = 0;
    end;

    local procedure PrepareStatements(var Store_p: Record "LSC Store"; ForceToday_p: Boolean)
    var
        POSTerminalTemp: Record "LSC POS Terminal" temporary;
        StaffTemp: Record "LSC Staff" temporary;
        Statement: Record "LSC Statement";
        TransactionHeader: Record "LSC Transaction Header";
        IsCreate: Boolean;
        StmtPubFunc: Codeunit "Statement-Public Functions_NT";
    begin
        Statement.Init();
        Statement."Store No." := Store_p."No.";
        //if Statement.AssignShiftAndDates(Store_p, true) then begin //BC22
        if StmtPubFunc.AssignShiftAndDates(Statement,Store_p, true) then begin
            if ForceToday_p then
                ReAssignDates(Statement, WorkDate());

            if CalculationDate = 0D then
                CalculationDate := WorkDate() - 1;
            ReAssignDates(Statement, CalculationDate);

            TransactionHeader.SetAutoCalcFields("Statement No.");
            if Store_p."Closing Method" = Store_p."Closing Method"::"Date and Time" then begin
                TransactionHeader.SetCurrentKey("Store No.", Date);
                TransactionHeader.SetRange("Store No.", Statement."Store No.");
                TransactionHeader.SetRange(Date, Statement."Trans. Starting Date", Statement."Trans. Ending Date");
                TransactionHeader.SetFilter("Transaction Type", '<>%1&<>%2&<>%3&<>%4', TransactionHeader."Transaction Type"::PhysInv,
                    TransactionHeader."Transaction Type"::Logon, TransactionHeader."Transaction Type"::Logoff, TransactionHeader."Transaction Type"::"Open Drawer");
            end else
                if Store_p."Closing Method" = Store_p."Closing Method"::Shift then begin
                    TransactionHeader.SetCurrentKey("Store No.", "Shift Date", "Shift No.");
                    TransactionHeader.SetRange("Store No.", Statement."Store No.");
                    TransactionHeader.SetRange("Shift Date", Statement."Shift Date");
                    TransactionHeader.SetRange("Shift No.", Statement."Shift No.");
                    TransactionHeader.SetFilter("Transaction Type", '<>%1&<>%2&<>%3',
                        TransactionHeader."Transaction Type"::Logon, TransactionHeader."Transaction Type"::Logoff, TransactionHeader."Transaction Type"::"Open Drawer");
                end;
            TransactionHeader.SetRange("Entry Status", TransactionHeader."Entry Status"::" ");
            if (not Store_p."Group by Staff/POS") or (Store_p."Statement Method" = Store_p."Statement Method"::Total)
                or (Store_p."Closing Method" = Store_p."Closing Method"::Shift) then begin
                IsCreate := false;
                Statement."Staff/POS Term Filter Internal" := '';
                if TransactionHeader.FindSet() then
                    repeat
                        if TransactionHeader."Statement No." = '' then
                            IsCreate := true;
                    until (TransactionHeader.Next() = 0) or IsCreate;
                if IsCreate then
                    CreateStatements(Statement, Store_p, ForceToday_p);
            end else begin
                if Store_p."Statement Method" = Store_p."Statement Method"::"POS Terminal" then begin
                    TransactionHeader.SetFilter("POS Terminal No.", '<>%1', '');
                    POSTerminalTemp.Reset;
                    POSTerminalTemp.DeleteAll();
                    if TransactionHeader.FindSet() then
                        repeat
                            if TransactionHeader."Statement No." = '' then
                                if not POSTerminalTemp.Get(TransactionHeader."POS Terminal No.") then begin
                                    POSTerminalTemp."No." := TransactionHeader."POS Terminal No.";
                                    POSTerminalTemp.Insert();
                                end;
                        until TransactionHeader.Next() = 0;
                    if POSTerminalTemp.FindSet() then
                        repeat
                            Statement."Staff/POS Term Filter Internal" := POSTerminalTemp."No.";
                            CreateStatements(Statement, Store_p, ForceToday_p);
                        until POSTerminalTemp.Next() = 0;
                end else
                    if Store_p."Statement Method" = Store_p."Statement Method"::Staff then begin
                        TransactionHeader.SetFilter("Staff ID", '<>%1', '');
                        StaffTemp.Reset();
                        StaffTemp.DeleteAll();
                        if TransactionHeader.FindSet() then
                            repeat
                                if TransactionHeader."Statement No." = '' then
                                    if not StaffTemp.Get(TransactionHeader."Staff ID") then begin
                                        StaffTemp.Id := TransactionHeader."Staff ID";
                                        StaffTemp.Insert();
                                    end;
                            until TransactionHeader.Next() = 0;
                        if StaffTemp.FindSet() then
                            repeat
                                Statement."Staff/POS Term Filter Internal" := StaffTemp.Id;
                                CreateStatements(Statement, Store_p, ForceToday_p);
                            until StaffTemp.Next() = 0;
                    end;
            end;
        end;
    end;

    local procedure CreateStatements(var Statement_p: Record "LSC Statement"; var Store_p: Record "LSC Store"; ForceToday_p: Boolean)
    var
        StatementCheck: Record "LSC Statement";
    begin
        StatementCheck.SetRange("Store No.", Store_p."No.");
        if Store_p."Closing Method" = Store_p."Closing Method"::"Date and Time" then begin
            if (Statement_p."Trans. Starting Date" = 0D) or (Statement_p."Trans. Ending Date" = 0D) then
                exit;
            StatementCheck.SetRange("Trans. Starting Date", Statement_p."Trans. Starting Date");
            StatementCheck.SetRange("Trans. Ending Date", Statement_p."Trans. Ending Date");
            StatementCheck.SetRange("Trans. Starting Time", 0T);
            StatementCheck.SetRange("Trans. Ending Time", 0T);
        end else begin
            if (Statement_p."Shift Date" = 0D) or (Statement_p."Shift No." = '') then
                exit;
            StatementCheck.SetRange("Shift Date", Statement_p."Shift Date");
            StatementCheck.SetRange("Shift No.", Statement_p."Shift No.");
            if Store_p."Advanced Shift Method" then
                if Statement_p."Advanced Shift No." = '' then
                    exit
                else
                    StatementCheck.SetRange("Advanced Shift No.", Statement_p."Advanced Shift No.");
        end;
        StatementCheck.SetRange("Staff/POS Term Filter Internal", Statement_p."Staff/POS Term Filter Internal");
        if StatementCheck.IsEmpty() then begin
            Statement_p."No." := '';
            Statement_p.Validate("Store No.", Store_p."No.");
            if ForceToday_p then
                ReAssignDates(Statement_p, WorkDate());
            ReAssignDates(Statement_p, CalculationDate);
            Statement_p."Trans. After Midnight" := OpenAfterMidnight(Statement_p."Store No.", Statement_p."Trans. Ending Date");
            Statement_p.Insert(true);
        end;
    end;

    local procedure OpenAfterMidnight(StoreNo_p: Code[10]; Date_p: Date): Boolean;
    var
        RetailCalendar: Record "LSC Retail Calendar";
        RetailCalMgt: Codeunit "LSC Retail Calendar Management";
        OpenAfterMidnight: Boolean;
        OpenFrom: Time;
        OpenTo: Time;
    begin
        if RetailCalMgt.GetStoreOpenFromTo(StoreNo_p, RetailCalendar."Calendar Type"::"Opening Hours", Date_p, OpenFrom, OpenTo, OpenAfterMidnight) then
            exit(OpenAfterMidnight)
        else
            exit(false);
    end;

    local procedure ReAssignDates(var Statement_p: Record "LSC Statement"; Date_p: Date)
    begin
        Statement_p."Trans. Ending Date" := Date_p;
        Statement_p."Posting Date" := Statement_p."Trans. Ending Date";
        Statement_p."Trans. Starting Date" := Statement_p."Trans. Ending Date";
    end;

    procedure SetParams(StoreNo_p: Code[10]; CalcDate: Date)
    begin
        GlobalStoreNo := StoreNo_p;
        CalculationDate := CalcDate;
    end;

    var
        GlobalStoreNo: Code[10];
        CalculationDate: Date;
        CheckStatementCalcMsg: Label 'Check statement which is not calculated.';
}

