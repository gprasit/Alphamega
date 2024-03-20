page 60302 "Pos_Slip Email Entry_NT"
{
    ApplicationArea = All;
    Caption = 'Slip Email Entry';
    PageType = List;
    SourceTable = "Pos_Slip Email Entry_NT";
    UsageCategory = History;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed =false;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("Time"; Rec."Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time field.';
                }
                field("Customer/Member Email"; Rec."Customer/Member Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer/Member Email field.';
                }
                field("Date Processed"; Rec."Date Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Processed field.';
                }
                field("Time Processed"; Rec."Time Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Processed field.';
                }
                field("Replication Counter"; Rec."Replication Counter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Replication Counter field.';
                }
            }
        }
    }
}
