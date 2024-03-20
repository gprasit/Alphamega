page 60014 "Treasury Allocation Lines_NT"
{
    Caption = 'Allocation Lines';
    PageType = ListPart;
    SourceTable = "Treasury Allocation Line_NT";
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {

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
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Available To Deposit"; Rec."Available To Deposit")
                {
                    ApplicationArea = All;
                }
                field("Counted Amount"; Rec."Counted Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Counted Amount field.';
                    Editable = "Counted AmountEditable";
                }
                field("Counted Amount in LCY"; Rec."Counted Amount in LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Counted Amount in LCY field.';
                }

                field("Adj. Undeposited Amount"; Rec."Adj. Undeposited Amount")
                {
                    ApplicationArea = All;
                }
                field("Difference Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Account No.';
                    Editable = "Bank AccountEditabe";
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
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit() then
                            CurrPage.Update();
                    end;
                }
                field("Deposit Slip No."; Rec."Deposit Slip No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of Deposit Slip No.';
                }

                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Difference Line"; Rec."Difference Line")
                {
                    ApplicationArea = All;
                }
                field("Adj. Undeposited Amt. Line"; Rec."Adj. Undeposited Amt. Line")
                {
                    ApplicationArea = All;
                }

            }
        }

    }
    actions
    {
        area(Processing)
        {
            group("&Function")
            {
                Caption = '&Function';
                Image = "Action";
                action("&Insert New Line")
                {
                    ApplicationArea = All;
                    Caption = '&Insert New Line';
                    Image = Insert;

                    trigger OnAction()
                    begin
                        Rec.InsertLine();
                    end;
                }
                action("Insert &Diff. Line")
                {
                    ApplicationArea = All;
                    Caption = 'Insert &Difference Line';
                    Image = Insert;
                    trigger OnAction()
                    begin
                        Rec.InsertDiffLine();
                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;

                action("&Cash Declaration")
                {
                    ApplicationArea = All;
                    Caption = '&Cash Declaration';
                    Image = CashFlowSetup;

                    trigger OnAction()
                    var
                        TreasAllocLine: Record "Treasury Allocation Line_NT";
                    begin
                        //CurrPage.StatementLineForm.PAGE.GETRECORD(StatementLine2);
                        if TreasAllocLine.Get(Rec."Treasury Statement No.", Rec."Line No.") then begin
                            TreasAllocLine.SetRecFilter;
                            TreasAllocLine.LookupCountedAmt;
                        end;
                    end;
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to allocation lines and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if not Rec."Counting Required" then
            "Counted AmountEditable" := false
        else
            "Counted AmountEditable" := true;

        if not Rec."Taken to Bank" then
            "Bank AccountEditabe" := false
        else
            "Bank AccountEditabe" := true;
    end;

    trigger OnInit()
    begin
        "Counted AmountEditable" := true;
    end;

    var
        "Counted AmountEditable": Boolean;
        "Bank AccountEditabe": Boolean;
}
