codeunit 60011 "Statement-Public Functions_NT"
{
    Permissions = TableData "LSC Scheduler Setup" = rm,
                  TableData "LSC Work Shift RBO" = rm;

    trigger OnRun()
    begin

    end;

    procedure AssignShiftAndDates(var Statement: Record "LSC Statement"; var pStore: Record "LSC Store"; IsCheckOnly: Boolean): Boolean
    var
        RetailCalendarManagement: Codeunit "LSC Retail Calendar Management";
        RetailCalendar: Record "LSC Retail Calendar";
        ErrorText: Text;
        OpenFrom: Time;
        OpenTo: Time;
        OpenAfterMidnight: Boolean;
        IsHandled: Boolean;
        ExitWithError: Boolean;
    begin
        Statement.Method := pStore."Statement Method";
        Statement."Closing Method" := pStore."Closing Method";
        if Statement."Closing Method" = Statement."Closing Method"::Shift then begin
            WorkShift.SetCurrentKey(WorkShift."Store No.", Status);
            WorkShift.SetRange(WorkShift."Store No.", pStore."No.");
            WorkShift.SetFilter(WorkShift."Statement No.", '=%1', '');
            if not IsHandled then
                WorkShift.SetRange(WorkShift.Status, WorkShift.Status::Open, WorkShift.Status::Closed);
            if not WorkShift.FindFirst() then
                if IsCheckOnly then
                    exit(false)
                else begin
                    if ErrorText <> '' then
                        Error(ErrorText);

                    if not IsHandled then
                        Error(Text011, WorkShift.TableCaption);
                end;
            Statement."Posting Date" := WorkShift."Shift Date";
            Statement."Shift Date" := WorkShift."Shift Date";
            Statement."Shift No." := WorkShift."Shift No.";
            if ExitWithError then
                exit(false);
            if not IsCheckOnly then begin
                WorkShift."Statement No." := Statement."No.";
                WorkShift.Modify;
            end;
        end else begin
            Statement."Trans. Ending Date" := WorkDate;
            //OnAssignShiftAndDates_OnAssignWorkDateToTransEndingDate(Rec);
            if RetailCalendarManagement.GetStoreOpenFromTo(
                pStore."No.", RetailCalendar."Calendar Type"::"Opening Hours",
                RetailCalendarManagement.Yesterday(WorkDate), OpenFrom, OpenTo, OpenAfterMidnight)
            then begin
                if OpenAfterMidnight then begin
                    Statement."Trans. After Midnight" := true;
                    Statement."Trans. Ending Date" := RetailCalendarManagement.Yesterday(WorkDate);
                end else
                    Statement."Trans. After Midnight" := false;
            end;
            Statement."Posting Date" := Statement."Trans. Ending Date";

            if pStore."One Statement per Day" then
                Statement."Trans. Starting Date" := Statement."Trans. Ending Date"
            else
                if Statement."Trans. Starting Date" > Statement."Trans. Ending Date" then
                    Statement."Trans. Starting Date" := 0D;
        end;
        Statement.Validate("VAT Reporting Date", Statement."Posting Date");
        exit(true);
    end;

    var
        WorkShift: Record "LSC Work Shift RBO";
        Text011: Label 'No open %1 found.';
}
