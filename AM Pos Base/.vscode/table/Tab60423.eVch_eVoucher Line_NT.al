table 60423 "eVch_eVoucher Line_NT"
{
    Caption = 'eVoucher Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "e-Mail"; Text[80])
        {
            Caption = 'e-Mail';
        }
        field(4; Quantity; Integer)
        {
            Caption = 'Quantity';
            trigger OnValidate()
            begin
                Validate(Amount);
            end;
        }
        field(5; "Amount Code"; Code[10])
        {
            Caption = 'Amount Code';
            trigger OnValidate()
            var
                CreateDataEntryAmount: Record "eVch_Create Data Entry Amt_NT";
            begin
                IF CreateDataEntryAmount.GET("Amount Code") THEN
                    VALIDATE(Amount, CreateDataEntryAmount.Amount);
            end;
        }
        field(10; Amount; Decimal)
        {
            Caption = 'Amount';
            trigger OnValidate()
            begin
                "Line Amount" := Amount * Quantity;
            end;
        }
        field(15; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
        }
        field(20; "Member Card No."; Text[100])
        {
            Caption = 'Member Card No.';
            TableRelation = "LSC Membership Card";
            trigger OnValidate()
            var

                MembershipCard: Record "LSC Membership Card";
                MemberContact: Record "LSC Member Contact";
            begin
                IF MembershipCard.GET("Member Card No.") THEN
                    IF MemberContact.GET(MembershipCard."Account No.", MembershipCard."Contact No.") THEN
                        "Member Contact Name" := MemberContact.Name;
                IF "Member Card No." = '' THEN
                    "Member Contact Name" := '';

            end;
        }
        field(25; "Member Contact Name"; Text[100])
        {
            Caption = 'Member Contact Name';
        }
        field(30; "Entry Type"; Code[20])
        {
            Caption = 'Entry Type';
        }
        field(35; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = ,Posted,Canclelled;
            OptionCaption = ' ,Posted,Canclelled';
        }
    }
    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        eVoucherHeader: Record "eVch_eVoucher Header_NT";

    trigger OnInsert()
    var
        myInt: Integer;
    begin
        TestStatusOpen;
        GetHeader;
        if "Amount Code" = '' then begin
            "Amount Code" := eVoucherHeader."Amount Code";
            Validate(Amount, eVoucherHeader.Amount);
        end;
    end;

    local procedure GetHeader()
    begin
        if eVoucherHeader."No." <> "Document No." then
            eVoucherHeader.Get("Document No.");
    end;

    procedure TestStatusOpen()
    begin
        GetHeader;
        eVoucherHeader.TestStatusOpen();
    end;
}
