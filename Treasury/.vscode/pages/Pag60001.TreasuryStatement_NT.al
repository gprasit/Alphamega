page 60001 "Treasury Statement_NT"
{
    Caption = 'Treasury Statement';
    PageType = Card;
    SourceTable = "Treasury Statement_NT";
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Treasury Statement No."; Rec."Treasury Statement No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Store Hierarchy No."; Rec."Store Hierarchy No.")
                {
                    ToolTip = 'Specifies the value of the Store Hierarchy No. field.';
                    ApplicationArea = All;
                    Visible = HierarchyNoVisible;
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

                field(Recalculate; Rec.Recalculate)
                {
                    ToolTip = 'Specifies the value of the Recalculate field.';
                    ApplicationArea = All;
                    //Editable = false;
                    trigger OnValidate()
                    var
                    begin
                        Error(Text001);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Float Opening"; Rec."Float Opening")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

            }
            group("Signature Pad")
            {
                usercontrol("SGN SGNSignaturePad"; "SGN SGNSignaturePad")
                {
                    ApplicationArea = All;
                    Visible = true;
                    trigger Ready()
                    begin
                        CurrPage."SGN SGNSignaturePad".InitializeSignaturePad();
                    end;

                    trigger Sign(Signature: Text)
                    var
                        TreasGenFn: Codeunit "Treasury General Functions_NT";
                    begin
                        //TreasGenFn.SignDocument(Signature, Rec);
                        Rec.SignDocument(Signature);
                        CurrPage.Update(false);
                    end;
                }
                field("SGN Signature"; Rec."SGN Signature")
                {
                    Caption = 'Signature';
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            part(TreasuryStatementLinePage; "Treasury Statement Lines_NT")
            {
                ApplicationArea = All;
                SubPageLink = "Treasury Statement No." = FIELD("Treasury Statement No.");
            }
            part(TreasuryStmtNetSalesLinePage; "Treasury Stmt. NetSalesLine_NT")
            {
                ApplicationArea = All;
                SubPageLink = "Treasury Statement No." = FIELD("Treasury Statement No.");
            }
            part(TreasuryAllocationLinePage; "Treasury Allocation Lines_NT")
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
                action("C&alculate Treasury Statement")
                {
                    ApplicationArea = All;
                    Caption = 'C&alculate Treasury Statement';
                    Image = Calculate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    trigger OnAction()
                    begin
                        Clear(TreasuryMgmt);
                        TreasuryMgmt.CalculateTreasuryStatement(Rec);
                        CurrPage.Update();
                    end;
                }
                action("&Clear Statement")
                {
                    ApplicationArea = All;
                    Caption = '&Clear Statement';
                    Image = Restore;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Clear(TreasuryMgmt);
                        TreasuryMgmt.SetStatmentLinesFree(Rec);
                    end;
                }
                action("&Post Treasury Statement")
                {
                    ApplicationArea = All;
                    Caption = '&Post Treasury Statement';
                    Image = PostDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        Clear(TreasuryMgmt);
                        TreasuryMgmt.PostTreasuryStatment(Rec);
                        //TreasuryMgmt.MoveTreasuryStmtToPosted(Rec);
                    end;
                }
                action("Check &Statements")
                {
                    ApplicationArea = All;
                    Caption = 'Check &Statements';
                    Image = Check;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    begin
                        Clear(TreasuryMgmt);
                        TreasuryMgmt.ShowStatements(Rec);
                    end;
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin

        SetHierarchyNoFromUser;
    end;

    trigger OnOpenPage()
    begin

        HierarchyNoVisible := SetHierarchyNoVisible();
    end;

    local procedure SetHierarchyNoFromUser()
    begin
        if RetailUsers.Get(UserId) then
            if (RetailUsers."Store Hierarchy No." <> '') and (Rec."Treasury Statement No." = '') then
                Rec.Validate("Store Hierarchy No.", RetailUsers."Store Hierarchy No.");
    end;

    local procedure SetHierarchyNoVisible(): Boolean
    var
        RetailUser: Record "LSC Retail User";
        Store2: Record "LSC Store";
        Store_l: Record "LSC Store";
    begin
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." = '' then
                exit(true);
        exit(false);
    end;

    var
        RetailUsers: Record "LSC Retail User";
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        HierarchyNoVisible: Boolean;
        Text001: Label 'Not allowed to change this field. Used internally by the system.';
}


