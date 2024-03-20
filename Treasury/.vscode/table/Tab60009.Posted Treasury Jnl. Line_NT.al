table 60009 "Posted Treasury Jnl. Line_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Posted Treasury Journal Line';

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
        }
        field(30; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type Setup".Code;
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(35; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency.Code;

            trigger OnValidate()
            begin
            end;
        }
        field(40; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';

            trigger OnValidate()
            begin
            end;
        }
        field(45; "Acc. Type"; Enum "Treasury Jnl. Acc. Type_NT")
        {
            Caption = 'Account Type';
        }
        field(50; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Acc. Type" = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF ("Acc. Type" = CONST(Customer)) Customer."No."
            ELSE
            IF ("Acc. Type" = CONST(Vendor)) Vendor."No.";
        }
        field(55; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            ClosingDates = true;
            trigger OnValidate()
            var
            begin
                TestStatusOpen();
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
        }
        field(75; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(80; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

        }
        field(85; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

        }

        field(90; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(95; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(100; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
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
        }
        field(140; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnModify()
    var
    begin
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
            "Dimension Set ID", StrSubstNo('%1 %2 %3', "Treasury Statement No.", "Treasury Stmt. Line No.", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure TestStatusOpen()
    begin
        TestField(Status, Status::Open);
        TestField("Treasury Statement No.", '');
        TestField("Treasury Stmt. Line No.", 0);
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


}



