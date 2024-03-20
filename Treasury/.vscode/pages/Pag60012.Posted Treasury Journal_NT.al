page 60012 "Posted Treasury Journal_NT"
{
    ApplicationArea = All;
    Caption = 'Posted Treasury Journal';
    PageType = List;
    SourceTable = "Posted Treasury Jnl. Line_NT";
    UsageCategory = History;
    Editable = false;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Batch Name field.';
                }
                field("Treasury Statement No."; Rec."Treasury Statement No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Treasury Statement No. field.';
                }
                field("Treasury Stmt. Line No."; Rec."Treasury Stmt. Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Treasury Stmt. Line No. field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field.';
                }

                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Acc. Type"; Rec."Acc. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No. field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Factor field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount (LCY) field.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reason Code field.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Code field.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                }
                field("Store Hierarchy No."; Rec."Store Hierarchy No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Hierarchy No. field.';
                }
                field("G/L Register No."; Rec."G/L Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Register No. field.';
                }
            }
        }
        area(FactBoxes)
        {
            part(JournalLineDetails; "Pstd Treas. Jnl.DtlsFactBox_NT")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Treasury Statement No." = FIELD("Treasury Statement No."),
                              "Treasury Stmt. Line No." = FIELD("Treasury Stmt. Line No."),
                              "Entry Type" = field("Entry Type"),
                              "Line No." = FIELD("Line No.");
            }
            part(Control1900919607; "Dimension Set Entries FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Dimension Set ID" = FIELD("Dimension Set ID");
            }
            // systempart(TreasJnlLineLink; Links)
            // {
            //     ApplicationArea = RecordLinks;
            // }
            // systempart(TreasJnlLineNotes; Notes)
            // {
            //     ApplicationArea = Notes;
            // }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(60009),
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
    trigger OnInit()
    var
        RetailUser: Record "LSC Retail User";
    begin
        Rec.FilterGroup(2);
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then
                Rec.SetRange("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
        Rec.FilterGroup(0);
    end;

    trigger OnAfterGetCurrRecord()
    var
    begin
        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName);
    end;

    trigger OnAfterGetRecord()
    var
    begin
        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName);
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

    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;
        IsSimplePage: Boolean;
        AccName: Text[100];
        TenderName: Text[30];

}
