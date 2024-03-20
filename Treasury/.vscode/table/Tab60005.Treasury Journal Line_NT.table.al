table 60005 "Treasury Journal Line_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Treasury Journal Line';

    fields
    {

        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Treasury Journal Template_NT".Name;
        }
        field(5; "Journal Batch Name"; Code[20])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Treasury Journal Batch_NT".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(10; "Treasury Statement No."; Code[20])
        {
            Caption = 'Treasury Statement No.';

            TableRelation = "Treasury Statement_NT"."Treasury Statement No.";
        }
        field(15; "Treasury Stmt. Line No."; Integer)
        {
            Caption = 'Treasury Stmt. Line No.';
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(25; "Entry Type"; Enum "Treas. Jnl. Entry Type_NT")
        {
            Caption = 'Entry Type';
            trigger OnValidate()
            begin
                TestStatusOpen();
                ValidateJnlBatchEntryType(CurrFieldNo);
            end;
        }
        field(30; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type Setup".Code where("Default Treasury Jrnl. Tender" = const(true));
            trigger OnValidate()
            begin
                TestStatusOpen();
                ValidateJnlBatchEntryType(CurrFieldNo);
            end;
        }
        field(35; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency.Code;

            trigger OnValidate()
            begin
                TestStatusOpen();
                if "Currency Code" <> '' then begin
                    GetCurrency;
                    if ("Currency Code" <> xRec."Currency Code") or
                       ("Posting Date" <> xRec."Posting Date") or
                       (CurrFieldNo = FieldNo("Currency Code")) or
                       ("Currency Factor" = 0)
                    then
                        "Currency Factor" :=
                          CurrExchRate.ExchangeRate("Posting Date", "Currency Code");
                end else
                    "Currency Factor" := 0;
                Validate("Currency Factor");
            end;
        }
        field(40; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';

            trigger OnValidate()
            begin
                TestStatusOpen();
                if ("Currency Code" = '') and ("Currency Factor" <> 0) then
                    FieldError("Currency Factor", StrSubstNo(Text002, FieldCaption("Currency Code")));
                Validate(Amount);
            end;
        }
        field(45; "Acc. Type"; Enum "Treasury Jnl. Acc. Type_NT")
        {
            Caption = 'Account Type';

            trigger OnValidate()
            begin
                TestStatusOpen();
                ValidateJnlBatchEntryType(CurrFieldNo);
                if "Acc. Type" <> xRec."Acc. Type" then
                    "Account No." := '';

                Validate("Account No.");
            end;
        }
        field(50; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Acc. Type" = CONST("G/L Account")) "G/L Account"."No." WHERE("Account Type" = CONST(Posting),
                                                                                               Blocked = CONST(false))
            ELSE
            IF ("Acc. Type" = CONST(Customer)) Customer."No."
            ELSE
            IF ("Acc. Type" = CONST(Vendor)) Vendor."No.";

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckGLAccount();
                CreateDim;
            end;
        }
        field(55; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            ClosingDates = true;
            trigger OnValidate()
            var
            begin
                TestStatusOpen();
                ValidateJnlBatchEntryType(CurrFieldNo);
            end;
        }
        field(60; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(65; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(70; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            begin
                TestStatusOpen();
                GetCurrency;
                if "Currency Code" = '' then
                    "Amount (LCY)" := Amount
                else
                    "Amount (LCY)" := Round(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        "Posting Date", "Currency Code",
                        Amount, "Currency Factor"));

                Amount := Round(Amount, Currency."Amount Rounding Precision");
            end;
        }
        field(75; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';

            trigger OnValidate()
            begin
                TestStatusOpen();
                if "Currency Code" = '' then begin
                    Amount := "Amount (LCY)";
                    Validate(Amount);
                end else begin
                    if CheckFixedCurrency then begin
                        GetCurrency;
                        Amount := Round(
                          CurrExchRate.ExchangeAmtLCYToFCY(
                            "Posting Date", "Currency Code",
                            "Amount (LCY)", "Currency Factor"),
                            Currency."Amount Rounding Precision");
                        Validate(Amount);
                    end else begin
                        TestField("Amount (LCY)");
                        TestField(Amount);
                        "Currency Factor" := Amount / "Amount (LCY)";
                    end;
                end;
            end;
        }
        field(80; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(85; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(90; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(95; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(100; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code" where("LSC Group" = field("Reason Code Group"));
            trigger OnValidate()
            var
                ReasonCode: Record "Reason Code";
            begin
                TestStatusOpen();
                if ReasonCode.Get("Reason Code") then
                    if ReasonCode."G/L Account No." <> '' then begin
                        "Acc. Type" := "Acc. Type"::"G/L Account";
                        Validate("Account No.", ReasonCode."G/L Account No.");
                    end else
                        Validate("Account No.", '');
            end;
        }
        field(105; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions;
            end;
        }
        field(110; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(115; "Reason Code Group"; Code[10])
        {
            Caption = 'Reason Code Group';
            TableRelation = "LSC Reason Code Groups"."No.";
        }
        field(120; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            TableRelation = "LSC Retail Hierarchy".Code;
        }
        field(125; Status; Enum "Treasury Jnl. Status_NT")
        {
            Caption = 'Status';
        }
        field(130; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(135; "G/L Register No."; Integer)
        {
            Caption = 'G/L Register No.';
            TableRelation = "G/L Register"."No.";
            Editable = false;
        }
        field(140; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        LockTable;
        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    trigger OnDelete()
    begin
        TestStatusOpen();
    end;

    trigger OnModify()
    var
        TreasuryJnlLine: Record "Treasury Journal Line_NT";
        TreasuryStmt: Record "Treasury Statement_NT";
    begin
        TreasuryJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        TreasuryJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        TreasuryJnlLine.SetFilter("Treasury Statement No.", '<>%1', '');
        if TreasuryJnlLine.FindFirst() then
            if TreasuryStmt."Treasury Statement No." <> TreasuryJnlLine."Treasury Statement No." then begin
                TreasuryStmt.Get(TreasuryJnlLine."Treasury Statement No.");
                TreasuryStmt.Recalculate := true;
                TreasuryStmt.Modify();
            end;
        "User ID" := UserId;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure EmptyLine(): Boolean
    begin
        exit(("Account No." = '') and ("Tender Type" = '') and (Amount = 0));
    end;

#if __IS_SAAS__
    internal
#endif
    procedure GetRetailSetup()
    begin
        if not RetailSetupAlreadyRetrieved then begin
            RetailSetup.Get;
            RetailSetupAlreadyRetrieved := true;
        end;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure SetUpNewLine(LastTreaStmtJnlLine: Record "Treasury Journal Line_NT")
    var
        TreasuryJnlBatch: Record "Treasury Journal Batch_NT";
        TreasuryJnlTemplate: Record "Treasury Journal Template_NT";
    begin
        TreasuryJnlTemplate.Get("Journal Template Name");
        TreasuryJnlBatch.Get("Journal Template Name", "Journal Batch Name");

        TreasuryJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        TreasuryJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if TreasuryJnlLine.Find('-') then begin
            "Posting Date" := LastTreaStmtJnlLine."Posting Date";
            //"Document No." := LastTreaStmtJnlLine."Document No.";
            Validate("Entry Type", LastTreaStmtJnlLine."Entry Type");
            Validate("Tender Type", LastTreaStmtJnlLine."Tender Type");
            "Currency Code" := LastTreaStmtJnlLine."Currency Code";
            "Posting Date" := LastTreaStmtJnlLine."Posting Date";
            "Document Date" := LastTreaStmtJnlLine."Document Date";
        end else begin
            "Posting Date" := WorkDate();
            "Document Date" := WorkDate();
            // if TreasuryJnlBatch."No. Series" <> '' then begin
            //     Clear(NoSeriesMgt);            
            //     "Document No." := NoSeriesMgt.GetNextNo(TreasuryJnlBatch."No. Series", "Posting Date", true);
            // end;
        end;
        if TreasuryJnlBatch."No. Series" <> '' then begin
            Clear(NoSeriesMgt);
            "Document No." := NoSeriesMgt.GetNextNo(TreasuryJnlBatch."No. Series", "Posting Date", true);
        end;
        "Source Code" := TreasuryJnlTemplate."Source Code";
        "Reason Code Group" := TreasuryJnlBatch."Reason Code Group";
        "Posting No. Series" := TreasuryJnlBatch."Posting No. Series";
        "Store Hierarchy No." := TreasuryJnlBatch."Store Hierarchy No.";
        "Entry Type" := TreasuryJnlBatch."Jnl. Entry Type";
        "User ID" := UserId;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure CreateDim()
    var
        AlphaMegaSetup: Record "AlphaMega Setup_NT";
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        CodeDictionary: Dictionary of [Integer, Code[20]];
        DimSource: List of [Dictionary of [Integer, Code[20]]];
        NewDimSetID: Integer;
    begin
        if "Acc. Type" = "Acc. Type"::"G/L Account" then
            CodeDictionary.Add(Database::"G/L Account", "Account No.")
        else
            if "Acc. Type" = "Acc. Type"::Customer then
                CodeDictionary.Add(Database::Customer, "Account No.")
            else
                if "Acc. Type" = "Acc. Type"::Vendor then
                    CodeDictionary.Add(Database::Vendor, "Account No.");

        DimSource.Add(CodeDictionary);

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';

        "Dimension Set ID" :=
            DimMgt.GetDefaultDimID(DimSource, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
        //Add Store Hierarchy Dimension
        if AlphaMegaSetup.Get() then begin
            AlphaMegaSetup.TestField("Store Hierarchy Dimension");
            TreasuryMgmt.AddDimensionToDimensionSet("Dimension Set ID", NewDimSetID, AlphaMegaSetup."Store Hierarchy Dimension", "Store Hierarchy No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            if "Dimension Set ID" <> NewDimSetID then
                "Dimension Set ID" := NewDimSetID;
        end;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

#if __IS_SAAS__
    internal
#endif
    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

#if __IS_SAAS__
    internal
#endif
    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    local procedure GetCurrency()
    begin
        if "Currency Code" = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision
        end else
            if "Currency Code" <> Currency.Code then begin
                Currency.Get("Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure CheckFixedCurrency(): Boolean
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        CurrExchRate.SetRange("Currency Code", "Currency Code");
        CurrExchRate.SetRange("Starting Date", 0D, "Posting Date");

        if not CurrExchRate.Find('+') then
            exit(false);

        if CurrExchRate."Relational Currency Code" = '' then
            exit(
              CurrExchRate."Fix Exchange Rate Amount" =
              CurrExchRate."Fix Exchange Rate Amount"::Both);

        if CurrExchRate."Fix Exchange Rate Amount" <>
          CurrExchRate."Fix Exchange Rate Amount"::Both
        then
            exit(false);

        CurrExchRate.SetRange("Currency Code", CurrExchRate."Relational Currency Code");
        if CurrExchRate.Find('+') then
            exit(
              CurrExchRate."Fix Exchange Rate Amount" =
              CurrExchRate."Fix Exchange Rate Amount"::Both);

        exit(false);
    end;

#if __IS_SAAS__
    internal
#endif
    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2 %3', "Journal Template Name", "Journal Batch Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure TestStatusOpen()
    begin
        TestField(Status, Status::Open);
        TestField("Treasury Statement No.", '');
        TestField("Treasury Stmt. Line No.", 0);
    end;

    local procedure CheckGLAccount()
    var
        ReasonCode: Record "Reason Code";
    begin
        if "Reason Code" <> '' then
            if ReasonCode.Get("Reason Code") then
                if ReasonCode."G/L Account No." <> '' then
                    if "Account No." <> ReasonCode."G/L Account No." then
                        Error(Text003, ReasonCode.FieldCaption("G/L Account No."), ReasonCode."G/L Account No.", "Reason Code");
    end;

    local procedure ValidateJnlBatchEntryType(CurrentFieldNo: Integer)
    var
        TreasuryJnlBatch: Record "Treasury Journal Batch_NT";
    begin
        TreasuryJnlBatch.Get("Journal Template Name", "Journal Batch Name");
        TreasuryJnlBatch.TestField("Jnl. Entry Type");
        if CurrentFieldNo = FieldNo("Entry Type") then
            TestField("Entry Type", TreasuryJnlBatch."Jnl. Entry Type");
    end;


    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        RetailSetup: Record "LSC Retail Setup";
        Store: Record "LSC Store";
        TreasuryJnlLine: Record "Treasury Journal Line_NT";
        Vendor: Record Vendor;
        DimMgt: Codeunit DimensionManagement;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        RetailSetupAlreadyRetrieved: Boolean;
        Text002: Label 'cannot be specified without %1';
        Text010: Label 'The Bag %1 is open with positive amount %2.';
        Text011: Label 'The Bag %1 is open with negative amount %2.';
        Text003: Label '%1 must be %2 as defined in reason codes %3.';


}



