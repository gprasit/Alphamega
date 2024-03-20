page 60108 "ESL_ESL Stores_NT"
{
    Caption = 'ESL Stores';
    PageType = List;
    SourceTable = "ESL_ESL Stores_NT";
    UsageCategory = Lists;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Store No"; Rec."Store No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Price Group Code"; Rec."Price Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Group Code field.';
                }
                field("Store Group"; Rec."Store Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Group field.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field.';
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
