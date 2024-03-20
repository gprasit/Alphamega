page 60418 "Pos_Trans. Topup Entry_NT"
{
    ApplicationArea = All;
    Caption = 'Trans. Topup Entry';
    PageType = List;
    SourceTable = "Pos_Trans. Topup Entry_NT";
    UsageCategory = Lists;
    Editable = false;
    
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
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Trans. Line No."; Rec."Trans. Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trans. Line No. field.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                }
                field("Transaction ID"; Rec."Transaction ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction ID field.';
                }
                field("Transaction Status"; Rec."Transaction Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Status field.';
                }
                field("Topup ID"; Rec."Topup ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Topup ID field.';
                }
                field("Topup Amount"; Rec."Topup Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Topup Amount field.';
                }
                field(Pin; Rec.Pin)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pin field.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Date field.';
                }
                field("Request Time"; Rec."Request Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Time field.';
                }
                field("Processing Date"; Rec."Processing Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Date field.';
                }
                field("Processing Time"; Rec."Processing Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Time field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Member Card No."; Rec."Member Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Card No. field.';
                }
                field("Processing User ID"; Rec."Processing User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing User ID field.';
                }
                field("Promotion Code 1"; Rec."Promotion Code 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Code 1 field.';
                }
                field("Promotion Code 2"; Rec."Promotion Code 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Code 2 field.';
                }
                field("Promotion Text"; Rec."Promotion Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Text field.';
                }
                field("Error Message 1"; Rec."Error Message 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Message 1 field.';
                }
                field("Error Message 2"; Rec."Error Message 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Message 2 field.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. field.';
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance field.';
                }
                field("Request User ID"; Rec."Request User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request User ID field.';
                }
            }
        }
    }
}
