table 60010 "AlphaMega Setup_NT"
{
    Caption = 'AlphaMega Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Key"; Code[10])
        {
            Caption = 'Key';
        }
        field(10; "Treasury Statement Nos."; Code[10])
        {
            Caption = 'Treasury Statement Nos.';
            TableRelation = "No. Series";
        }
        field(15; "Store Type Attribute"; Code[20])
        {
            Caption = 'Store Type Attribute';
            TableRelation = "LSC Attribute";
        }
        field(20; "Store Hierarchy Dimension"; Code[20])
        {
            Caption = 'Store Hierarchy Dimension';
            TableRelation = Dimension.Code where(Blocked = const(false));
        }
        field(25; "Ext. Doc. No. Mandatory"; Boolean)
        {
            Caption = 'Ext. Doc. No. Mandatory';
        }
    }
    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }

}
