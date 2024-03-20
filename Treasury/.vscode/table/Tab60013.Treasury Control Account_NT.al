table 60013 "Treasury Control Account_NT"
{
    Caption = 'Treasury Control Account';
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
            Caption = 'Control Account No.';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
            trigger OnValidate()
            begin
                CheckControlAccount();
            end;
        }
        field(15; "Control Account Name"; Text[100])
        {
            CalcFormula = Lookup("G/L Account".Name WHERE("No." = FIELD("Control Account No.")));
            Caption = 'Control Account Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Fixed Float"; Decimal)
        {
            Caption = 'Fixed Float';
            BlankZero = true;
        }
        field(30; "Bank Bag Nos."; Code[10])
        {
            Caption = 'Bank Bag Nos.';
            TableRelation = "No. Series";
        }
        field(35; "Float Tender"; Code[20])
        {
            Caption = 'Float Tender';
            TableRelation = "LSC Tender Type Setup" where("Default Function" = const("Tender Remove/Float"));
            trigger OnValidate()
            var
                StoreHierarchyTenderType: Record "Store Hierarchy Tender Type_NT";
            begin
                if StoreHierarchyTenderType.Get("Store Hierarchy No.", "Control Account No.", "Float Tender") then
                    Validate("Float G/L Account", StoreHierarchyTenderType."Tender Account No.");
            end;
        }
        field(40; "Float G/L Account"; Code[20])
        {
            Caption = 'Float G/L Account';
            TableRelation = "G/L Account" where(Blocked = const(false), "Account Type" = const(Posting));
        }
    }
    keys
    {
        key(PK; "Store Hierarchy No.")
        {
            Clustered = true;
        }
    }
    local procedure CheckControlAccount()
    var
        StoreHierTenderType: Record "Store Hierarchy Tender Type_NT";
    begin
        TestField("Store Hierarchy No.");
        StoreHierTenderType.SetFilter("Store Hierarchy No.", "Store Hierarchy No.");
        if StoreHierTenderType.FindFirst() then
            TestField("Control Account No.", StoreHierTenderType."Control Account No.");
    end;
}