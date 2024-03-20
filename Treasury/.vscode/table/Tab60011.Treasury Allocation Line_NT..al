table 60011 "Treasury Allocation Line_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Treasury Allocation Line';
    Permissions = tabledata "Bank Account Ledger Entry" = rm;

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
                HierarchyDefs: Record "LSC Retail Hierar. Defaults";
                TempAllocationLine: Record "Treasury Allocation Line_NT" temporary;
                TenderType: Record "LSC Tender Type Setup";
                TenderTypeStore: Record "LSC Tender Type";
                StoreNo: Code[10];
            begin
                if "Tender Type" <> '' then begin
                    TenderType.Get("Tender Type");
                    "Tender Type Name" := TenderType.Description;
                end else
                    "Tender Type Name" := '';

                HierarchyDefs.SetRange("Table ID", Database::"LSC Store");
                HierarchyDefs.SetRange("Hierarchy Code", "Store Hierarchy No.");
                if HierarchyDefs.FindFirst() then
                    StoreNo := HierarchyDefs."No."
                else
                    Error(Text001, "Store Hierarchy No.");

                if TenderTypeStore.Get(StoreNo, "Tender Type") then begin
                    "Taken to Bank" := TenderTypeStore."Taken to Bank";
                    "Counting Required" := TenderTypeStore."Counting Required";
                end else
                    "Taken to Bank" := false;
                if "Tender Type" = '' then begin
                    TempAllocationLine := Rec;
                    Init();
                    "Store Hierarchy No." := TempAllocationLine."Store Hierarchy No.";
                    "Posting Date" := TempAllocationLine."Posting Date";
                end;
                CreateDim();
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
            trigger OnValidate()
            begin
                SetRealExchangeRate();
                Validate("Counted Amount");
            end;
        }
        field(30; "Counted Amount"; Decimal)
        {
            Caption = 'Counted Amount';
            DecimalPlaces = 2 : 2;
            trigger OnLookup()
            begin
                LookupCountedAmt;
            end;

            trigger OnValidate()
            var
                TreasCashDeclaration: Record "Treasury Cash Declaration_NT";
            begin
                TreasCashDeclaration.SetRange("Treasury Statement No.", "Treasury Statement No.");
                TreasCashDeclaration.SetRange("Treasury Allocation Line No.", "Line No.");
                TreasCashDeclaration.SetRange("Total Line", false);
                TreasCashDeclaration.CalcSums(Total);
                TreasCashDeclaration.SetRange("Total Line");
                if not "System-Created Entry" then
                    if "Taken to Bank" then
                        if "Counted Amount" > "Available To Deposit" then
                            Error(Text002, FieldCaption("Counted Amount"), FieldCaption("Available To Deposit"), "Available To Deposit");

                if not "System-Created Entry" then
                    if not "Taken to Bank" then
                        if "Counted Amount" > "Calculated Amount" then
                            Error(Text002, FieldCaption("Counted Amount"), FieldCaption("Calculated Amount"), "Calculated Amount");

                if "Counted Amount" <> 0 then begin
                    if ("Calculated Amount" = 0) and ("Real Exchange Rate" = 1) and ("Currency Code" <> '') then
                        SetRealExchangeRate();

                    if "Counted Amount" <> TreasCashDeclaration.Total then begin
                        if not TreasCashDeclaration.IsEmpty then
                            TreasCashDeclaration.DeleteAll;
                        "Counted Amount in LCY" := Round("Counted Amount" * "Real Exchange Rate", LCYRoundingPrecision);
                    end;
                end else begin
                    if not TreasCashDeclaration.IsEmpty then
                        TreasCashDeclaration.DeleteAll;
                    "Counted Amount in LCY" := 0;
                end;

                // "Difference Amount" := "Counted Amount" - "Calculated Amount";
                // "Difference in LCY" := "Counted Amount in LCY" - "Calculated in LCY";
                if not "Taken to Bank" then begin
                    "Remaining Amount" := "Counted Amount" - "Calculated Amount";
                    "Difference in LCY" := "Counted Amount in LCY" - "Calculated in LCY";
                end else begin
                    "Remaining Amount" := "Counted Amount" - "Available To Deposit";
                    "Difference in LCY" := "Counted Amount in LCY" - "Available To Deposit";
                end;
            end;
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
            trigger OnValidate()
            var
                BankAcc: Record "Bank Account";
            begin
                if xRec."Bank Account No." <> Rec."Bank Account No." then
                    if BankAcc.Get(Rec."Bank Account No.") then
                        "Bank Account Name" := BankAcc.Name
                    else
                        "Bank Account Name" := '';
            end;
        }
        field(60; "Bank Account Name"; Text[100])
        {
            Caption = 'Bal. Account Name';
            Editable = false;
        }
        field(65; "Bag No."; Code[30])
        {
            Caption = 'Bag No.';
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
    var
        BankAccLedg2: Record "Bank Account Ledger Entry";
        BankAccLedg: Record "Bank Account Ledger Entry";
        CashDeclaration: Record "Treasury Cash Declaration_NT";
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        DepositBankAcc: Code[20];
        DiffBankAcc: Code[20];
    begin
        CashDeclaration.SetRange("Treasury Statement No.", "Treasury Statement No.");
        CashDeclaration.SetRange("Tender Type", "Tender Type");
        CashDeclaration.SetRange("Currency Code", "Currency Code");
        CashDeclaration.SetRange("Treasury Allocation Line No.", "Line No.");
        CashDeclaration.DeleteAll();
        TreasuryMgmt.FindTenderDepositBankAcc("Store Hierarchy No.", "Tender Type", DepositBankAcc, DiffBankAcc);
        BankAccLedg.SetFilter("Bank Account No.", DiffBankAcc);
        BankAccLedg.SetFilter("Treasury Statement No.", "Treasury Statement No.");
        if BankAccLedg.FindSet() then
            repeat
                BankAccLedg2.Get(BankAccLedg."Entry No.");
                BankAccLedg2."Treasury Statement No." := '';
                BankAccLedg2."Treas. Alloc. Line No." := 0;
                BankAccLedg2."Store Hierarchy No." := '';
                BankAccLedg2.Modify();
            until BankAccLedg.Next() = 0;
    end;

    trigger OnInsert()
    var
        ControlAcc: Record "Treasury Control Account_NT";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NewNoSeriesCode: Code[20];
    begin
        if "Taken to Bank" then
            if "Bag No." = '' then begin
                ControlAcc.SetFilter("Store Hierarchy No.", "Store Hierarchy No.");
                if ControlAcc.FindFirst() then begin
                    ControlAcc.TestField(ControlAcc."Bank Bag Nos.");
                    NoSeriesMgt.InitSeries(ControlAcc."Bank Bag Nos.", '', "Posting Date", "Bag No.", NewNoSeriesCode);
                end;
            end;
    end;

    trigger OnModify()
    begin
    end;

    trigger OnRename()
    begin
    end;

    procedure InsertLine()
    var
        TreasuryStmt: Record "Treasury Statement_NT";
    begin
        TreasuryStmt.Get(Rec."Treasury Statement No.");

        AllocationLine.Init;
        AllocationLine."Treasury Statement No." := Rec."Treasury Statement No.";
        AllocationLine."Posting Date" := TreasuryStmt."Posting Date";
        AllocationLine."Counting Required" := true;
        AllocationLine.Validate("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
        AllocationLine2.Reset();
        AllocationLine2.SetRange("Treasury Statement No.", Rec."Treasury Statement No.");
        if AllocationLine2.Find('+') then
            AllocationLine."Line No." := AllocationLine2."Line No." + 1000
        else
            AllocationLine."Line No." := 1000;
        AllocationLine."System-Created Entry" := true;
        AllocationLine.Insert();
    end;

    procedure InsertDiffLine()
    var
        TreasuryStmt: Record "Treasury Statement_NT";
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        DiffAccNo: Code[20];
        GenJnlAccNo: Code[20];
        GenJnlAccType: Enum "Gen. Journal Account Type";
    begin
        TreasuryStmt.Get("Treasury Statement No.");
        if "Remaining Amount" = 0 then
            exit;
        TestField("Taken to Bank");
        AllocationLine.SetFilter("Treasury Statement No.", "Treasury Statement No.");
        AllocationLine.SetFilter("Attached To Line No.", '%1', "Line No.");
        AllocationLine.SetFilter("Difference Line", '%1', true);
        if AllocationLine.FindFirst() then
            Error(Text003, FieldCaption("Line No."), "Line No.");

        AllocationLine.Reset();
        AllocationLine.Init;
        AllocationLine."Treasury Statement No." := "Treasury Statement No.";
        if "Posting Date" <> 0D then
            AllocationLine."Posting Date" := "Posting Date"
        else
            AllocationLine."Posting Date" := TreasuryStmt."Posting Date";
        AllocationLine."Counting Required" := true;
        AllocationLine."Taken to Bank" := "Taken to Bank";
        AllocationLine.Validate("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
        AllocationLine.Validate("Tender Type", "Tender Type");
        AllocationLine2.Reset();
        AllocationLine2.SetRange("Treasury Statement No.", Rec."Treasury Statement No.");
        if AllocationLine2.Find('+') then
            AllocationLine."Line No." := AllocationLine2."Line No." + 1000
        else
            AllocationLine."Line No." := 1000;
        AllocationLine."Counted Amount" := -1 * "Remaining Amount";
        AllocationLine."Available To Deposit" := AllocationLine."Counted Amount";
        AllocationLine."Available To Deposit LCY" := AllocationLine."Counted Amount in LCY";
        AllocationLine.Validate("Counted Amount");
        AllocationLine."Attached To Line No." := "Line No.";
        AllocationLine."Difference Line" := true;
        TreasuryMgmt.FindTenderDepositBankAcc(AllocationLine."Store Hierarchy No.", AllocationLine."Tender Type", GenJnlAccNo, DiffAccNo);
        if DiffAccNo = '' then
            Error(Text004, TreasuryStmt."Store Hierarchy No.", AllocationLine."Tender Type Name");
        AllocationLine.Validate("Bank Account No.", DiffAccNo);
        AllocationLine.Insert();
    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2', "Treasury Statement No.", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;
#if __IS_SAAS__
    internal
#endif
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure CreateDim()
    var
        AlphaMegaSetup: Record "AlphaMega Setup_NT";
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        NewDimSetID: Integer;
    begin
        if AlphaMegaSetup.Get() then begin
            AlphaMegaSetup.TestField("Store Hierarchy Dimension");
            TreasuryMgmt.AddDimensionToDimensionSet("Dimension Set ID", NewDimSetID, AlphaMegaSetup."Store Hierarchy Dimension", "Store Hierarchy No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            if "Dimension Set ID" <> NewDimSetID then
                "Dimension Set ID" := NewDimSetID;
        end;
    end;

    local procedure SetRealExchangeRate()
    var        
        POSView: Codeunit "LSC POS View";
    begin
        //Statement.Get("Store No.", "Statement No.");
        if "Currency Code" <> '' then
            "Real Exchange Rate" := POSView.POSExchangeFCYToLCY("Posting Date", "Currency Code", 1)
        else
            "Real Exchange Rate" := 1;
    end;
#if __IS_SAAS__
    internal
#endif
    procedure LookupCountedAmt()
    var
        CashDeclaration: Record "Treasury Cash Declaration_NT";
        CashForm: Page "Treasury Cash Declaration_NT";
        Text003: Label 'Counting is not required for this Tender Type';
    begin
        if "Counting Required" then begin
            CashForm.SetLine(Rec);
            CashDeclaration.InsertData(Rec);
            CashDeclaration.SetRange("Treasury Statement No.", "Treasury Statement No.");
            CashDeclaration.SetRange("Tender Type", "Tender Type");
            CashDeclaration.SetRange("Currency Code", "Currency Code");
            CashDeclaration.SetRange("Treasury Allocation Line No.", "Line No.");
            Commit;

            CashForm.SetTableView(CashDeclaration);
            if CashForm.RunModal = Action::OK then begin
                CashDeclaration.Reset;
                CashDeclaration.SetRange("Treasury Statement No.", "Treasury Statement No.");
                CashDeclaration.SetRange("Tender Type", "Tender Type");
                CashDeclaration.SetRange("Currency Code", "Currency Code");
                CashDeclaration.SetRange("Treasury Allocation Line No.", "Line No.");
                CashDeclaration.SetRange("Total Line", false);
                CashDeclaration.CalcSums(Total);
                if CashDeclaration.Total <> 0 then begin
                    Validate("Counted Amount", CashDeclaration.Total);
                    "Counted Amount in LCY" := Round("Counted Amount" * "Real Exchange Rate", LCYRoundingPrecision);
                    "Remaining Amount" := "Counted Amount" - "Available To Deposit";
                    "Difference in LCY" := "Counted Amount in LCY" - "Available To Deposit LCY";
                    Modify;
                end;
            end;
        end else
            Message(Text003);
    end;
    //end;
    local procedure LCYRoundingPrecision(): Decimal
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get;
        if Currency.Get(GLSetup."LCY Code") then
            exit(Currency."Amount Rounding Precision")
        else
            exit(0.01);
    end;

    procedure AssistEdit(): Boolean
    var
        ControlAcc: Record "Treasury Control Account_NT";
        TreasAllocLine: Record "Treasury Allocation Line_NT";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NewNoSeriesCode: Code[20];
    begin
        TreasAllocLine.Copy(Rec);
        ControlAcc.SetFilter("Store Hierarchy No.", "Store Hierarchy No.");
        if ControlAcc.FindFirst() then begin
            ControlAcc.TestField("Bank Bag Nos.");
            if NoSeriesMgt.SelectSeries(ControlAcc."Bank Bag Nos.", '', NewNoSeriesCode) then begin
                NoSeriesMgt.SetSeries(TreasAllocLine."Bag No.");
                Rec := TreasAllocLine;
                exit(true);
            end;
        end;
    end;

    var
        AllocationLine2: Record "Treasury Allocation Line_NT";
        AllocationLine: Record "Treasury Allocation Line_NT";
        DimMgt: Codeunit DimensionManagement;
        Text001: Label 'No store defined for store hierarchy %1';
        Text002: Label '%1 can not be more than %2 %3';
        Text003: label 'Difference line already created for %1 %2';
        Text004: label 'Difference Bank Account not defined in Store Hierarchy No. %1 for Tender Type %2';
}
