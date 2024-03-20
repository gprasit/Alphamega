page 60404 "eCom_General Setup_NT"
{
    Caption = 'AlphaMega General Setup';
    PageType = Card;
    SourceTable = "eCom_General Setup_NT";
    ApplicationArea = all;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Cards File"; Rec."Cards File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cards File field.';
                }
                field("Contacts File"; Rec."Contacts File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contacts File field.';
                }
                field("Continuity Time Out (ms)"; Rec."Continuity Time Out (ms)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Continuity Time Out (ms) field.';
                }
                field("Continuity URL"; Rec."Continuity URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Continuity URL field.';
                }
                field("Interface Directory"; Rec."Interface Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Interface Directory field.';
                }
                field("JBA Item Parameters File"; Rec."JBA Item Parameters File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the JBA Item Parameters File field.';
                }
                field("JBA Items File"; Rec."JBA Items File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the JBA Items File field.';
                }
                field("Primary Key"; Rec."Primary Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key field.';
                }


                field("Viva Wallet API Key"; Rec."Viva Wallet API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Viva Wallet API Key field.';
                }
                field("Viva Wallet Capture Excess %"; Rec."Viva Wallet Capture Excess %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Viva Wallet Capture Excess % field.';
                }
                field("Viva Wallet Client Id"; Rec."Viva Wallet Client Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Viva Wallet Client Id field.';
                }
                field("Viva Wallet Client Secret"; Rec."Viva Wallet Client Secret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Viva Wallet Client Secret field.';
                }
                field("Viva Wallet Live Environment"; Rec."Viva Wallet Live Environment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Viva Wallet Live Environment field.';
                }
                field("Viva Wallet Merchant Id"; Rec."Viva Wallet Merchant Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Viva Wallet Merchant Id field.';
                }
                field("Viva Wallet Source Code"; Rec."Viva Wallet Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Viva Wallet Source Code field.';
                }
                field("eVoucher Nos."; Rec."eVoucher Nos.")
                {
                    ApplicationArea = All;
                }
                field("eVoucher Template"; Rec."eVoucher Template".HasValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Retail Zoom Starting Date"; Rec."Retail Zoom Starting Date")
                {
                    ApplicationArea = All;                    
                }
                field("Decrypt Loyalty APP QR"; Rec."Decrypt Loyalty APP QR")
                {
                    ApplicationArea = All;
                    ToolTip ='Place a check mark while using new Loyalty App. for Business Central.';
                }
                field("DataEntryUpdateReplCounter"; Rec."DataEntryUpdateReplCounter")
                {
                    ApplicationArea = All;
                    ToolTip ='Place a check mark when data entry replication counter needs to be updated.';
                }
                field("POS Message PanelID"; Rec."POS Message PanelID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the POS Message Panel ID.';
                }
                field("Journal Line Coupon Font"; Rec."Journal Line Coupon Font")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies font for coupon line in POS Journal.';
                }
                field("Journal Line Coupon Skin"; Rec."Journal Line Coupon Skin")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies skin for coupon line in POS Journal.';
                }          
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("&Import")
            {
                Caption = 'Import';
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                begin
                    Clear(eVoucherMgt);
                    eVoucherMgt.ImportTemplateToGeneralSetup(TRUE);
                end;
            }
            action("&Export")
            {
                Caption = 'Export';
                ApplicationArea = All;
                Image = Export;
                trigger OnAction()
                begin
                    Clear(eVoucherMgt);
                    eVoucherMgt.ImportTemplateToGeneralSetup(false);
                end;
            }
            action("&Delete")
            {
                Caption = 'Delete';
                ApplicationArea = All;
                Image = Delete;
                trigger OnAction()
                begin
                    Clear(eVoucherMgt);
                    eVoucherMgt.DeleteTemplateGeneralSetup;
                end;
            }
        }
    }
    var
        eVoucherMgt: Codeunit "eVch_eVoucher Management_NT";
}
