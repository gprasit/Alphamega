page 60107 "ESL_ESL Countries_NT"
{
    ApplicationArea = All;
    Caption = 'ESL Countries';
    PageType = List;
    SourceTable = "ESL_ESL Countries_NT";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Greek Name"; Rec."Greek Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Greek Name field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ExpESL)
            {
                Caption = 'Export ESL';
                Promoted = true;
                PromotedCategory = Process;
                image = Export;
                ApplicationArea = All;
                RunObject = report "ESL_Export ESL_NT";
            }
            action(ExpESLChanges)
            {
                Caption = 'Export ESL Changes';
                Promoted = true;
                PromotedCategory = Process;
                image = Export;
                ApplicationArea = All;
                RunObject = report "ESL_Export ESL Changes_NT";
            }
        }
    }

}

