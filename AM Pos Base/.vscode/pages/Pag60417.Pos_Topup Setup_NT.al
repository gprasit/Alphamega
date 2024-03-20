page 60417 "Pos_Topup Setup_NT"
{
    Caption = 'Topup Setup';
    PageType = Card;
    SourceTable = "Pos_Topup Setup_NT";
    UsageCategory = Administration;
    ApplicationArea = all;

    layout
    {
        area(content)
        {            
                group(Topup)
                {
                    field("Topup Alta XL Initializer"; Rec."Topup Alta XL Initializer")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Topup Alta XL Initializer field.';
                    }
                    field("Topup Location Hash"; Rec."Topup Location Hash")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Topup Location Hash field.';
                    }
                    field("Topup User Name"; Rec."Topup User Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Topup User Name field.';
                    }
                    field("Topup Password"; Rec."Topup Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Topup Password field.';
                    }
                    field("Topup Temp Password"; Rec."Topup Temp Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Topup Temp Password field.';
                    }
                    field("Topup Name On Receipt"; Rec."Topup Name On Receipt")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Topup Name On Receipt field.';
                    }
                    field("Topup No. Of Retries"; Rec."Topup No. Of Retries")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Topup No. Of Retries field.';
                    }
                }
                group(SKash)
                {
                    field("sKash Location Hash"; Rec."sKash Location Hash")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the sKash Location Hash field.';
                    }
                    field("sKash Account Type"; Rec."sKash Account Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the sKash Account Type field.';
                    }
                    field("sKash Schema"; Rec."sKash Schema")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the sKash Schema field.';
                    }
                    field("sKash Password"; Rec."sKash Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the sKash Password field.';
                    }
                    field("sKash Retry Interval (ms)"; Rec."sKash Retry Interval (ms)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the sKash Retry Interval (ms) field.';
                    }
                    field("sKash Time Out (ms)"; Rec."sKash Time Out (ms)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the sKash Time Out (ms) field.';
                    }
                }
        }
    }
    actions
    {
        area(Processing)
        {
            
        }
    }    
}

