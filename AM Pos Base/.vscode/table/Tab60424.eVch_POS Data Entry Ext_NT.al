table 60424 "eVch_POS Data Entry Ext_NT"
{
    Caption = 'POS Data Entry Ext.';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Entry Type"; Code[10])
        {
            Caption = 'Entry Type';
            TableRelation ="LSC POS Data Entry Type".Code;
        }
        field(2; "Entry Code"; Code[20])
        {
            Caption = 'Entry Code';
            DataClassification = ToBeClassified;
        }
        field(3; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = ToBeClassified;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(5; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Entry Type","Entry Code")
        {
            Clustered = true;
        }
    }
}
