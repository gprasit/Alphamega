tableextension 60435 "Pos_Member Point Jnl. Line_NT" extends "LSC Member Point Jnl. Line"
{
    fields
    {
        field(60401; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                TransHeader: Record "LSC Transaction Header";
            begin
                if "Receipt No." <> '' then begin
                    TransHeader.SetCurrentKey("Receipt No.");
                    TransHeader.SetRange("Receipt No.", "Receipt No.");
                    if not TransHeader.FindFirst() then begin
                        "Receipt No." := '';
                        Message('Receipt not found.');
                    end;
                end;
            end;
        }

        field(60410; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                MemberContact: Record "LSC Member Contact";
            begin
                MemberContact.SetCurrentKey("Phone No.");
                MemberContact.SetFilter("Phone No.", "Phone No.");
                if MemberContact.FindFirst() then begin
                    "Contact No" := MemberContact."Contact No.";
                    Validate("Account No.", MemberContact."Account No.");
                end else begin
                    MemberContact.Reset();
                    MemberContact.SetCurrentKey("Mobile Phone No.");
                    MemberContact.SetFilter("Mobile Phone No.", "Phone No.");
                    if MemberContact.FindFirst() then begin
                        "Contact No" := MemberContact."Contact No.";
                        Validate("Account No.", MemberContact."Account No.");
                    end;
                end;
            end;
        }
        field(60415; "Main Contact Name"; Text[100])
        {
            Caption = 'Main Contact Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup("LSC Member Contact".Name where("Account No." = field("Account No."), "Main Contact" = const(true)));
        }
        field(60420; "To Main Contact Name"; Text[100])
        {
            Caption = 'To Main Contact Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup("LSC Member Contact".Name where("Account No." = field("Transfer To Account No."), "Main Contact" = const(true)));
        }
        field(60425; "To Phone No."; Text[30])
        {
            Caption = 'To Phone No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                MemberContact: Record "LSC Member Contact";
            begin
                if "To Phone No." = '' then
                    exit;
                MemberContact.SetCurrentKey("Phone No.");
                MemberContact.SetFilter("Phone No.", "To Phone No.");
                if MemberContact.FindFirst() then
                    Validate("Transfer To Account No.", MemberContact."Account No.")
                else begin
                    MemberContact.Reset();
                    MemberContact.SetCurrentKey("Mobile Phone No.");
                    MemberContact.SetFilter("Mobile Phone No.", "To Phone No.");
                    if MemberContact.FindFirst() then
                        Validate("Transfer To Account No.", MemberContact."Account No.");
                end;
            end;
        }
    }    
}
