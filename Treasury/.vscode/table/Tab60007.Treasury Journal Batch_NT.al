table 60007 "Treasury Journal Batch_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Treasury Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageID = "Treasury Journal Batches";

    fields
    {
        field(1; "Journal Template Name"; Code[20])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "Treasury Journal Template_NT".Name;
        }
        field(5; Name; Code[20])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(15; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            TableRelation = "LSC Retail Hierarchy".Code;
        }
        field(20; "Reason Code Group"; Code[10])
        {
            Caption = 'Reason Code Group';
            TableRelation = "LSC Reason Code Groups"."No.";
        }
        field(30; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series".Code;

            trigger OnValidate()
            begin
                if "No. Series" <> '' then begin
                    TreasuryJnlTemplate.Get("Journal Template Name");
                    if TreasuryJnlTemplate.Recurring then
                        Error(
                          Text000,
                          FieldCaption("Posting No. Series"));
                    if "No. Series" = "Posting No. Series" then
                        Validate("Posting No. Series", '');
                end;
            end;
        }
        field(35; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(Text001, "Posting No. Series"));
                TreasuryJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                TreasuryJnlLine.SetRange("Journal Batch Name", Name);
                TreasuryJnlLine.ModifyAll("Posting No. Series", "Posting No. Series");
                Modify;
            end;
        }
        field(40; Recurring; Boolean)
        {
            CalcFormula = Lookup("Job Journal Template".Recurring WHERE(Name = FIELD("Journal Template Name")));
            Caption = 'Recurring';
            Editable = false;
            FieldClass = FlowField;
        }
        field(45; "Jnl. Entry Type"; Enum "Treas. Jnl. Entry Type_NT")
        {
            Caption = 'Journal Entry Type';
        }
        // field(50; ID; Code[50])
        // {
        //     Caption = 'ID';
        //     DataClassification = EndUserIdentifiableInformation;
        //     NotBlank = true;
        //     trigger OnLookup()
        //     var
        //         ApplicationMgtExt: Codeunit "LSC ApplicationMgt Ext.";
        //         BackOfficeExt: Codeunit "LSC BackOffice Ext.";
        //     begin
        //         BackOfficeExt.LookupUserID(ID);
        //         ApplicationMgtExt.LookupUserFullName(ID, "User Name");
        //     end;
        // }
        // field(55; "User Name"; Text[40])
        // {
        //     Caption = 'User Name';
        //     Editable = false;
        // }
    }

    keys
    {
        key(Key1; "Journal Template Name", Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TreasuryJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        TreasuryJnlLine.SetRange("Journal Batch Name", Name);
        TreasuryJnlLine.DeleteAll;
    end;

    trigger OnInsert()
    begin
        LockTable;
        TreasuryJnlTemplate.Get("Journal Template Name");
    end;

    trigger OnRename()
    begin
        TreasuryJnlLine.SetRange("Journal Template Name", xRec."Journal Template Name");
        TreasuryJnlLine.SetRange("Journal Batch Name", xRec.Name);
        while TreasuryJnlLine.Find('-') do
            TreasuryJnlLine.Rename("Journal Template Name", Name, TreasuryJnlLine."Line No.");
    end;

    procedure SetupNewLine(Var TreasJnlBatch: Record "Treasury Journal Batch_NT")
    var
        //ApplicationMgtExt: Codeunit "LSC ApplicationMgt Ext.";
        RetailUser: Record "LSC Retail User";
    begin
        //TreasJnlBatch.ID := UserId;
        //ApplicationMgtExt.LookupUserFullName(TreasJnlBatch.ID, TreasJnlBatch."User Name");
        if RetailUser.Get(UserId) then
            "Store Hierarchy No." := RetailUser."Store Hierarchy No.";
    end;

    var
        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';
        TreasuryJnlTemplate: Record "Treasury Journal Template_NT";
        TreasuryJnlLine: Record "Treasury Journal Line_NT";
}