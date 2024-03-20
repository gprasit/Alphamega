page 60028 "Treasury Jnl. Batches Setup"
{
    ApplicationArea = All;
    Caption = 'Treasury Journal Batches';
    DataCaptionExpression = DataCaption;
    PageType = List;
    SourceTable = "Treasury Journal Batch_NT";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Store Hierarchy No."; Rec."Store Hierarchy No.")
                {
                    ApplicationArea = all;
                }
                field("Reason Code Group"; Rec."Reason Code Group")
                {
                    ApplicationArea = all;
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                }
                field("Posting No. Series"; Rec."Posting No. Series")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Recurring; Rec.Recurring)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Jnl. Entry Type"; Rec."Jnl. Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value for Entry Type of the treasury journal.';
                }
                // field(ID; rec.ID)
                // {
                //     ApplicationArea = All;
                // }
                // field("User Name"; Rec."User Name")
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit &Journal")
            {
                ApplicationArea = All;
                Caption = 'Edit &Journal';
                Image = OpenJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';
                Visible = false;

                trigger OnAction()
                begin
                    //TreasuryMgmt.TemplateSelectionFromBatch(Rec);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        Rec.SetRange("Journal Template Name");
    end;

    trigger OnOpenPage()
    begin
        //TreasuryMgmt.OpenTreasuryJnlBatch(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetupNewLine(Rec);
    end;

    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";

    local procedure DataCaption(): Text[250]
    var
        TreasuryJnlTemplate: Record "Treasury Journal Template_NT";
    begin
        if not CurrPage.LookupMode then
            if (Rec.GetFilter("Journal Template Name") <> '') and (Rec.GetFilter("Journal Template Name") <> '''''') then
                if Rec.GetRangeMin("Journal Template Name") = Rec.GetRangeMax("Journal Template Name") then
                    if TreasuryJnlTemplate.Get(Rec.GetRangeMin("Journal Template Name")) then
                        exit(TreasuryJnlTemplate.Name + ' ' + TreasuryJnlTemplate.Description);
    end;
}

