tableextension 60425 "Pos_POS Func. Profile_NT" extends "LSC POS Func. Profile"
{
    fields
    {
        field(60401; "Auto Logoff After Z Report"; Boolean)
        {
            Caption = 'Auto Logoff After Z Report';
            DataClassification = CustomerContent;
        }
        field(60402; "Trans. Sales Inv. Report ID"; Integer)
        {
            Caption = 'Trans. Sales Inv. Report ID';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(60403; "Negative Adjustment Report ID"; Integer)
        {
            Caption = 'Negative Adjustment Report ID';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(60404; "Receipt Printing by Family"; Boolean)
        {
            Caption = 'Receipt Printing by Family';
            DataClassification = CustomerContent;
        }
        field(60405; "Auto Send Batch After Z Report"; Option)
        {
            Caption = 'Auto Send Batch After Z Report';
            DataClassification = CustomerContent;
            OptionMembers = None,JCC,RCB,Both;
        }
        field(60406; "Watermark on Negative Adj."; Boolean)
        {
            Caption = 'Watermark on Negative Adj.';
            DataClassification = CustomerContent;
        }
        field(60407; "Loyalty Card on Cust. Trans."; Boolean)
        {
            Caption = 'Loyalty Card on Cust. Trans.';
            DataClassification = CustomerContent;
        }
    }
}
