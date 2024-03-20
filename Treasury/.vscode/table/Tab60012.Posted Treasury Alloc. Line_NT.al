table 60012 "Posted Treasury Alloc. Line_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Posted Treasury Allocation Line';

    fields
    {
        field(1; "Treasury Statement No."; Code[20])
        {
            Caption = 'Treasury Statement No.';

            TableRelation = "Treasury Statement_NT"."Treasury Statement No.";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(15; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type Setup".Code;
            trigger OnValidate()
            var
                TenderType: Record "LSC Tender Type Setup";
            begin
                if "Tender Type" <> '' then begin
                    TenderType.Get("Tender Type");
                    "Tender Type Name" := TenderType.Description;
                end else
                    "Tender Type Name" := '';
            end;
        }
        field(20; "Tender Type Name"; Text[30])
        {
            Caption = 'Tender Type Name';
            Editable = false;
        }

        field(25; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(30; "Counted Amount"; Decimal)
        {
            Caption = 'Counted Amount';
            DecimalPlaces = 2 : 2;
        }
        field(35; "Counted Amount in LCY"; Decimal)
        {
            Caption = 'Counted Amount in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(40; "Counting Required"; Boolean)
        {
            Caption = 'Counting Required';
            Editable = false;
        }
        field(45; "Taken to Bank"; Boolean)
        {
            Caption = 'Taken to Bank';
            Editable = false;
        }
        field(50; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            TableRelation = "LSC Retail Hierarchy".Code;
        }
        field(55; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account"."No.";
        }
        field(60; "Bank Account Name"; Text[100])
        {
            Caption = 'Bal. Account Name';
            Editable = false;
        }
        field(65; "Bag No."; Code[30])
        {
            Caption = 'Bag No.';
            Editable = false;
        }
        field(70; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions;
            end;
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
        field(90; "G/L Register No."; Integer)
        {
            Caption = 'G/L Register No.';
            TableRelation = "G/L Register"."No.";
            Editable = false;
        }
        field(95; "Available To Deposit"; Decimal)
        {
            Caption = 'Available To Deposit';
            DecimalPlaces = 2 : 2;
            Editable = false;
            BlankZero = true;
        }
        field(100; "Available To Deposit LCY"; Decimal)
        {
            Caption = 'Available To Deposit LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
            BlankZero = true;
        }
        field(105; "Calculated Amount"; Decimal)
        {
            Caption = 'Calculated Amount';
            DecimalPlaces = 2 : 2;
        }
        field(110; "Calculated in LCY"; Decimal)
        {
            Caption = 'Calculated Amount in LCY';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(115; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            DecimalPlaces = 2 : 2;
            BlankZero = true;
            Editable = false;
        }
        field(120; "Difference in LCY"; Decimal)
        {
            Caption = 'Difference in LCY';
            DecimalPlaces = 2 : 2;
            BlankZero = true;
            Editable = false;
        }
        field(125; "Adj. Undeposited Amount"; Decimal)
        {
            Caption = 'Adj. Undeposited Amount';
            DecimalPlaces = 2 : 2;
            BlankZero = true;
            Editable = false;
        }
        field(130; "Adj. Undeposited Amt. LCY"; Decimal)
        {
            Caption = 'Adj. Undeposited Amt. LCY';
            DecimalPlaces = 2 : 2;
            BlankZero = true;
            Editable = false;
        }
        field(135; "Real Exchange Rate"; Decimal)
        {
            Caption = 'Real Exchange Rate';
            DecimalPlaces = 0 : 15;
            Editable = false;
        }
        field(140; "Attached To Line No."; Integer)
        {
            Caption = 'Attached To Line No.';
        }
        field(145; "Difference Line"; Boolean)
        {
            Caption = 'Difference Line';
            Editable = false;
        }
        field(150; "Adj. Undeposited Amt. Line"; Boolean)
        {
            Caption = 'Adj. Undeposited Amt. Line';
            Editable = false;
        }
        field(155; "Deposit Slip No."; Code[30])
        {
            Caption = 'Deposit Slip No.';
        }
        field(160; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
        field(165; "Reference Entry No."; Integer)
        {
            caption = 'Reference Entry No.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Treasury Statement No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
    end;

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin
    end;

    trigger OnRename()
    begin
    end;

    procedure ShowDimensions()
    begin
        DimMgt.EditDimensionSet(
          "Dimension Set ID", StrSubstNo('%1 %2', "Treasury Statement No.", "Line No."),
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure LookupCountedAmt()
    var
        PostedCashDeclaration: Record "Posted Treasury Cash Decl._NT";
    begin
        PostedCashDeclaration.SetFilter("Treasury Statement No.", "Treasury Statement No.");
        PostedCashDeclaration.SetFilter("Treasury Allocation Line No.", '%1', "Line No.");
        PostedCashDeclaration.SetFilter("Tender Type", "Tender Type");
        if PostedCashDeclaration.Find('-') then
            PAGE.Run(0, PostedCashDeclaration)
        else
            Message(Text001);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        Text001: Label 'No Cash Declaration was found';
}
