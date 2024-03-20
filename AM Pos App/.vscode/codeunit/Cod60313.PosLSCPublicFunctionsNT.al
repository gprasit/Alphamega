codeunit 60313 "Pos_LSC Public Functions_NT"
{
    trigger OnRun()
    begin
        
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
    var
        myInt: Integer;
}