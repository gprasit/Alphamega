page 60003 "Posted Treasury Statement_NT"
{
    Caption = 'Posted Treasury Statement';
    PageType = Card;
    SourceTable = "Posted Treasury Statement_NT";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Treasury Statement No."; Rec."Treasury Statement No.")
                {
                    ToolTip = 'Specifies the value of the Treasury Statment No. field.';
                    ApplicationArea = All;
                }
                field("Store Hierarchy No."; Rec."Store Hierarchy No.")
                {
                    ToolTip = 'Specifies the value of the Store Hierarchy No. field.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        if Rec."Store Hierarchy No." <> xRec."Store Hierarchy No." then
                            CurrPage.Update();
                    end;
                }
                field("Store Hierarchy Name"; Rec."Store Hierarchy Name")
                {
                    ToolTip = 'Specifies the value of the Store Hierarchy Name field.';
                    ApplicationArea = All;
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                    ApplicationArea = All;
                }
                field("Trans. Starting Date"; Rec."Trans. Starting Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Starting Date field.';
                    ApplicationArea = All;
                }
                field("Trans. Ending Date"; Rec."Trans. Ending Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Ending Date field.';
                    ApplicationArea = All;
                }
            }
            part(PostedTreasuryStmtLinePage; "Posted Treasury Stmt. Lines_NT")
            {
                ApplicationArea = All;
                SubPageLink = "Treasury Statement No." = FIELD("Treasury Statement No.");
            }
            part(PostedTreasuryStmtNetSalesLinePage; "Posted Treas. NetSalesLine_NT")
            {
                ApplicationArea = All;
                SubPageLink = "Treasury Statement No." = FIELD("Treasury Statement No.");
            }
            part(PostedTreasuryAllocationLinePage; "Posted Treas. Alloc. Lines_NT")
            {
                ApplicationArea = All;
                SubPageLink = "Treasury Statement No." = FIELD("Treasury Statement No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Check &Posted Statements")
                {
                    ApplicationArea = All;
                    Caption = 'Check &Posted Statements';
                    Image = Check;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    begin
                        Clear(TreasuryMgmt);
                        TreasuryMgmt.ShowPostedStatements(Rec);
                    end;
                }
            }
        }
    }
    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
}


