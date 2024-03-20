tableextension 60422 "Pos_LSC POS Trans. Line_NT" extends "LSC POS Trans. Line"
{
    fields
    {
        field(60001; "Point Value"; Decimal)
        {
            Caption = 'Point Value';
            DataClassification = CustomerContent;
        }
        field(60002; "sKash Entry No."; Integer)
        {
            Caption = 'sKash Entry No.';
            DataClassification = CustomerContent;
        }

        field(60003; "Continuity Voucher No."; Text[30])
        {
            Caption = 'Continuity Voucher No.';
            DataClassification = CustomerContent;
        }
        field(60004; "Void Command"; Code[20])
        {
            Caption = 'Void Command';
            DataClassification = CustomerContent;
        }
        field(60005; "Division Code"; Code[10])
        {
            Caption = 'Division Code';
            TableRelation = "LSC Division";
            DataClassification = CustomerContent;
        }
        field(60006; "Gift Receipt Qty. to Print"; Integer)
        {
            Caption = 'Gift Receipt Qty. to Print';
            DataClassification = CustomerContent;
        }
        field(60009; "No. Of Exchange Cards"; Integer)
        {
            Caption = 'No. Of Exchange Cards';
            DataClassification = CustomerContent;
        }


    }
}
