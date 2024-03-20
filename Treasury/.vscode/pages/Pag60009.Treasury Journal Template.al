page 60009 "Treasury Journal Template"
{
    ApplicationArea = All;
    Caption = 'Treasury Journal Templates';
    PageType = List;
    SourceTable = "Treasury Journal Template_NT";
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
                field("Page ID"; Rec."Page ID")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field("Page Name"; Rec."Page Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = all;
                }
                field("Posting Report ID"; Rec."Posting Report ID")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field("Posting Report Name"; Rec."Posting Report Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Te&mplate")
            {
                Caption = 'Te&mplate';
                action(Batches)
                {
                    ApplicationArea = All;
                    Caption = 'Batches';
                    Image = Documents;
                    Promoted = true;
                    PromotedIsBig = true;
                    RunObject = Page "Treasury Journal Batches";
                    RunPageLink = "Journal Template Name" = field(Name);
                }
            }
        }
    }
}
