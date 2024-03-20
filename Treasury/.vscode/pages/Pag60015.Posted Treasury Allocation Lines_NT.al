page 60015 "Posted Treas. Alloc. Lines_NT"
{
    Caption = 'Allocation Lines';
    PageType = ListPart;
    SourceTable = "Posted Treasury Alloc. Line_NT";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }

                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type field.';
                }
                field("Tender Type Name"; Rec."Tender Type Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type Name field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Counted Amount"; Rec."Counted Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Counted Amount field.';
                }
                field("Counted Amount in LCY"; Rec."Counted Amount in LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Counted Amount in LCY field.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Account No.';
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Account Name.';
                }
                field("Bag No."; Rec."Bag No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bag No.';
                }
                field("G/L Register No."; Rec."G/L Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of G/L Register No.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View dimensions, such as area, project, or department, that was assigned to allocation lines and analyze transaction history.';
                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Cash Declaration")
                {
                    ApplicationArea = All;
                    Caption = 'Cash Declaration';
                    Image = CashFlowSetup;

                    trigger OnAction()
                    begin
                        Rec.LookupCountedAmt();
                    end;
                }
            }
        }
    }
}
