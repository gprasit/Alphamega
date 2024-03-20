page 60007 "Treasury Journal_NT"
{
    Caption = 'Treasury Journal';
    PageType = Worksheet;
    SourceTable = "Treasury Journal Line_NT";
    DelayedInsert = true;
    AutoSplitKey = true;
    DataCaptionFields = "Journal Batch Name";
    ApplicationArea = all;
    UsageCategory = Tasks;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = All;
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    exit(TreasuryMgmt.LookupName(Rec.GetRangeMax("Journal Template Name"), CurrentJnlBatchName, Text));
                end;

                trigger OnValidate()
                begin
                    TreasuryMgmt.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali();
                end;
            }

            repeater(General)
            {
                field("Treasury Statement No."; Rec."Treasury Statement No.")
                {
                    ToolTip = 'Specifies the value of the Treasury Statement No. field.';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Treasury Stmt. Line No."; Rec."Treasury Stmt. Line No.")
                {
                    ToolTip = 'Specifies the value of the Treasury Stmt. Line No. field.';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field.';
                    ApplicationArea = All;
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ToolTip = 'Specifies the value of the Tender Type field.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName, ReasonCodeDesc);
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        CurrPage.SaveRecord();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ToolTip = 'Specifies the value of the Reason Code field.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName, ReasonCodeDesc);
                        CurrPage.SaveRecord();
                    end;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = All;
                }
                field("Acc. Type"; Rec."Acc. Type")
                {
                    ToolTip = 'Specifies the value of the Account Type field.';
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the value of the Account No. field.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName, ReasonCodeDesc);
                        CurrPage.SaveRecord();
                    end;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.';
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the value of the Amount (LCY) field.';
                    ApplicationArea = All;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the value of the Source Code field.';
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                    ApplicationArea = All;
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                    ApplicationArea = All;
                    Visible = DimVisible2;
                }
                field(ShortcutDimCode3; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field(ShortcutDimCode4; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field(ShortcutDimCode5; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field(ShortcutDimCode6; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field(ShortcutDimCode7; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field(ShortcutDimCode8; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(Control60000)
            {
                Visible = false;
                ShowCaption = false;
                fixed(Control60001)
                {
                    ShowCaption = false;
                    group("Account Name")
                    {
                        Caption = 'Account Name';
                        field(AccName; AccName)
                        {
                            ApplicationArea = all;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the account.';
                        }
                    }
                }
            }
        }
        area(FactBoxes)
        {

            part(PDFViewer; "PDF Viewer Matrix_NT")
            {
                ApplicationArea = All;
                SubPageLink = "Journal Template Name" = field("Journal Template Name")
                            , "Journal Batch Name" = field("Journal Batch Name")
                            , "Line No." = field("Line No.");
            }

            part(JournalLineDetails; "Treasury Jnl. Dtls. FactBox_NT")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Journal Template Name" = field("Journal Template Name")
                            , "Journal Batch Name" = field("Journal Batch Name")
                            , "Line No." = field("Line No.");
            }
            part(Control1900919607; "Dimension Set Entries FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Dimension Set ID" = FIELD("Dimension Set ID");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(60005),
                              "No." = FIELD("Journal Batch Name"),
                              "Document Type" = const(Treasury),
                              "Line No." = field("Line No.");
            }
            systempart(TreasJnlLineLink; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(TreasJnlLineNotes; Notes)
            {
                ApplicationArea = Notes;
            }

        }
    }
    actions
    {
        area(Processing)
        {
            group(Action60000)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action(Release)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.Only those lines not in Treasury Statement will be effected.';

                    trigger OnAction()
                    var
                        TreasuryMgmt: Codeunit "Treasury Management_NT";
                    begin
                        TreasuryMgmt.ReleaseTreasuryJournal(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Reopen the document to change it. Treasury Statements needs to be recalculated in case reopened Journal lines are included in Treasury Statement.';

                    trigger OnAction()
                    var
                        TreasuryMgmt: Codeunit "Treasury Management_NT";
                    begin
                        TreasuryMgmt.ReopenTreasuryJournalDoc(Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("&Dimensions")
                {
                    ApplicationArea = All;
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions;
                        CurrPage.SaveRecord;
                    end;
                }
            }
            group("&Signatuire")
            {
                Caption = '&Signature';
                action("&Sign")
                {
                    ApplicationArea = All;
                    Caption = 'Sign Document';
                    Image = Signature;

                    trigger OnAction()
                    var
                        SignPad: Page "Signature Pad_NT";
                    begin
                        SignPad.SetLine(Rec);
                        SignPad.RunModal();
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
    end;

    trigger OnInit()
    var
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        // Get simple / classic mode for this page except when called from a webservices (SOAP or ODATA)
        if ClientTypeManagement.GetCurrentClientType() in [CLIENTTYPE::SOAP, CLIENTTYPE::OData, CLIENTTYPE::ODataV4]
        then
            IsSimplePage := false
        else
            IsSimplePage := GenJnlManagement.GetJournalSimplePageModePreference(PAGE::"Treasury Journal_NT");
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        SetDimensionVisibility();
        OpenedFromBatch := (Rec."Journal Batch Name" <> '') and (Rec."Journal Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            TreasuryMgmt.OpenTreasuryJnl(CurrentJnlBatchName, Rec);
            exit;
        end;

        TreasuryMgmt.TemplateSelection(Page::"Treasury Journal_NT", Rec, JnlSelected);
        if not JnlSelected then
            Error('');

        TreasuryMgmt.OpenTreasuryJnl(CurrentJnlBatchName, Rec);
    end;

    trigger OnAfterGetCurrRecord()
    var
    begin
        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName, ReasonCodeDesc);
        CurrPage.PDFViewer.Page.SetRecord(Rec);
    end;

    trigger OnAfterGetRecord()
    var
    begin
        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName, ReasonCodeDesc);
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;

        if not IsSimplePage then
            DimMgt.UseShortcutDims(
              DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);

        Clear(DimMgt);
    end;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        TreasuryMgmt.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        ShortcutDimCode: array[8] of Code[20];
        IsSimplePage: Boolean;
        AccName: Text[100];
        ReasonCodeDesc: Text[100];
        OpenedFromBatch: Boolean;
        TenderName: Text[30];
        CurrentJnlBatchName: Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;
        GenJnlManagement: Codeunit GenJnlManagement;
}