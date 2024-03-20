tableextension 60007 Statement_NT extends "LSC Statement"
{
    fields
    {
        field(60000; "Z-Amount"; Decimal)
        {
            Caption = 'Z-Amount';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                TreasuryGenFn: Codeunit "Treasury General Functions_NT";
                TransAmt: Decimal;
            begin

                TransAmt := TreasuryGenFn.ValidateZAmount("No.");
                if TransAmt <> "Z-Amount" then
                    Message(Text001, FieldCaption("Z-Amount"), "Z-Amount", TransAmt);
            end;
        }
        field(60001; Finish; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Finish';
        }
    }
    var
        Text001: Label 'Entered %1 %2 does not match with transaction amount %3';
}
