table 60409 "Pos_Slip Email Entry_NT"
{
    Caption = 'Slip E-Mail Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[10])
        {
            Caption = 'Store No.';
        }
        field(5; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
        }
        field(10; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(15; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';            
        }
        field(20; Date; Date)
        {
            Caption = 'Date';
        }
        field(25; Time; Time)
        {
            Caption = 'Time';
        }
        field(30; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            Editable = false;
            trigger OnValidate()
            var
                SlipEmailRequests_l: Record "Pos_Slip Email Entry_NT";
            begin
                if not ClientSessionUtility.UpdateReplicationCountersForTable(RecordId, "Replication Counter") then
                    exit;
                SlipEmailRequests_l.SetCurrentKey("Replication Counter");
                if SlipEmailRequests_l.FindLast then
                    "Replication Counter" := SlipEmailRequests_l."Replication Counter" + 1
                else
                    "Replication Counter" := 1;
            end;
        }
        field(35; "Date Processed"; Date)
        {
            Caption = 'Date Processed';
        }
        field(40; "Time Processed"; Time)
        {
            Caption = 'Time Processed';
        }
        field(45; Message; Text[150])
        {
            Caption = 'Message';
            Editable = false;
        }
        field(50; "Customer/Member Email"; Text[250])
        {
            Caption = 'Customer/Member Email';
        }                
    }
    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.")
        {
            Clustered = true;
        }
        key(Key2; "Replication Counter")
        {
        }
        key(Key3; "Date Processed")
        {
        }
    }
    trigger OnInsert()
    begin
        Validate("Replication Counter");
    end;

    trigger OnModify()
    begin
        Validate("Replication Counter");
    end;

    var
        ClientSessionUtility: Codeunit "LSC Client Session Utility";
}
