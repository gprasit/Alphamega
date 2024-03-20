page 60109 "MA_App Advertisement_NT"
{
    ApplicationArea = All;
    Caption = 'App Advertisement';
    PageType = List;
    SourceTable = "MA_App Advertisement_NT";
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
                field("Description EN"; Rec."Description EN")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description EN field.';
                }
                field("Description GR"; Rec."Description GR")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description GR field.';
                }
                field("Display Order"; Rec."Display Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Order field.';
                }
                field("Image Code EN"; Rec."Image Code EN")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image Code EN field.';
                }
                field("Image Code GR"; Rec."Image Code GR")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image Code GR field.';
                }
                field("Link EN"; Rec."Link EN")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Link EN field.';
                }
                field("Link GR"; Rec."Link GR")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Link GR field.';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expiration Date field.';
                }
            }
        }

        area(factboxes)
        {
            part(PictureEN; "LSC Rtl Image Preview Factbox")
            {
                ApplicationArea = All;
                Caption = 'Picture EN';
                SubPageLink = Code = FIELD("Image Code EN");
            }
            part(PictureGR; "LSC Rtl Image Preview Factbox")
            {
                ApplicationArea = All;
                Caption = 'Picture GR';
                SubPageLink = Code = FIELD("Image Code GR");
            }
        }
    }
}


