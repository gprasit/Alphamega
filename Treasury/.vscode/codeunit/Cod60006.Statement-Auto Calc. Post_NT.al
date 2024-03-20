codeunit 60006 "Statement-Auto Calc. Post_NT"
{
    TableNo = "LSC Scheduler Job Header";
    trigger OnRun()
    var
        CalculationDate: Date;
        StmtCalcPostMain: Codeunit "Statement-Calc.-Post-Main_NT";
    begin
        AssignDate(CalculationDate, Rec.DateFormula);
        if Store.FindSet() then
            repeat
                StmtCalcPostMain.SetParams(Store."No.", CalculationDate);
                if StmtCalcPostMain.Run() then;
            until Store.Next() = 0;
    end;


    local procedure AssignDate(var CalculationDate: Date; SchedulerDTFormula: DateFormula)
    var
        BlankDTFormula: DateFormula;
        DefExpr: Text[10];
    begin
        DefExpr := '<-1D>';
        if SchedulerDTFormula <> BlankDTFormula then
            CalculationDate := CalcDate(SchedulerDTFormula, WorkDate())
        else
            CalculationDate := CalcDate(DefExpr, WorkDate());
    end;

    var
        Store: Record "LSC Store";
        StatementCalculate: Codeunit "Statement-Calc.-Post-Main_NT";

}

