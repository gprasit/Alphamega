table 60014 "Store Hierarchy Tender Type_NT"
{
    Caption = 'Store Hierarchy Tender Type';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Store Hierarchy No."; Code[10])
        {
            Caption = 'Store Hierarchy No.';
            TableRelation = "LSC Retail Hierarchy".Code;
            trigger OnValidate()
            begin
            end;
        }
        field(5; "Store Hierarchy Name"; Text[100])
        {
            CalcFormula = Lookup("LSC Retail Hierarchy".Name WHERE(Code = FIELD("Store Hierarchy No.")));
            Caption = 'Store Hierarchy Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Control Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
            trigger OnValidate()
            begin
                CheckControlAccount();
            end;
        }
        field(15; "Control Account Name"; Text[100])
        {
            CalcFormula = Lookup("G/L Account".Name WHERE("No." = FIELD("Control Account No.")));
            Caption = 'G/L Account Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Tender Type"; Code[10])
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
        field(25; "Tender Type Name"; Text[30])
        {
            Caption = 'Tender Type Name';
            Editable = false;
        }
        field(30; "Tender Account No."; Code[20])
        {
            Caption = 'Tender Account No.';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(35; "Tender Account Name"; Text[100])
        {
            CalcFormula = Lookup("G/L Account".Name WHERE("No." = FIELD("Tender Account No.")));
            Caption = 'Tender G/L Account Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Diff. Bank Account"; Code[20])
        {
            Caption = 'Diff. Bank Account';
            TableRelation = "Bank Account" where(Blocked = const(false));
        }
        field(45; "Diff. Bank Name"; Text[100])
        {
            CalcFormula = Lookup("Bank Account".Name WHERE("No." = FIELD("Diff. Bank Account")));
            Caption = 'Diff. Bank Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Deposit Bank Account"; Code[20])
        {
            Caption = 'Deposit Bank Account';
            TableRelation = "Bank Account" where(Blocked = const(false));
        }
        field(55; "Deposit Bank Name"; Text[100])
        {
            CalcFormula = Lookup("Bank Account".Name WHERE("No." = FIELD("Deposit Bank Account")));
            Caption = 'Diff. Bank Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; "Store Hierarchy No.", "Control Account No.", "Tender Type")
        {
            Clustered = true;
        }
    }
    local procedure CheckControlAccount()
    var
        TreasuryControlAcc: Record "Treasury Control Account_NT";
    begin
        TestField("Store Hierarchy No.");
        TreasuryControlAcc.SetFilter("Store Hierarchy No.", "Store Hierarchy No.");
        if TreasuryControlAcc.FindFirst() then
            TestField("Control Account No.", TreasuryControlAcc."Control Account No.");

    end;
}
