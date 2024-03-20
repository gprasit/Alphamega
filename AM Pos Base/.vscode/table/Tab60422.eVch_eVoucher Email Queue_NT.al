table 60422 "eVch_eVoucher Email Queue_NT"
{
    Caption = 'eVoucher Email Queue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry Type"; Code[10])
        {
            Caption = 'Entry Type';
            TableRelation = "LSC POS Data Entry Type".Code;
        }
        field(5; "Entry Code"; Code[20])
        {
            Caption = 'Entry Code';
        }
        field(10; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(15; "Created by Receipt No."; Code[20])
        {
            Caption = 'Created by Receipt No.';
        }
        field(20; "Date Created"; Date)
        {
            Caption = 'Date Created';
        }
        field(25; "Created in Store No."; Code[10])
        {
            Caption = 'Created in Store No.';
            TableRelation = "LSC Store";
        }
        field(30; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
        }
        field(35; "e-mail"; Text[80])
        {
            Caption = 'e-mail';
        }
        field(40; "Mail Sent"; Boolean)
        {
            Caption = 'Mail Sent';
        }
        field(45; "Date Sent"; Date)
        {
            Caption = 'Date Sent';
        }
        field(50; "Time Sent"; Time)
        {
            Caption = 'Time Sent';
        }
        field(55; "Last Message Text"; Text[250])
        {
            Caption = 'Last Message Text';
        }
        field(60; Redeemed; Boolean)
        {
            Caption = 'Redeemed';
            FieldClass = FlowField;
            CalcFormula = Lookup("LSC POS Data Entry".Applied WHERE("Entry Type" = FIELD("Entry Type"), "Entry Code" = FIELD("Entry Code"),"Applied by Receipt No."=FILTER(<>'CANCELLED')));
            Editable = false;
        }
        field(65; "Mail Resent"; Boolean)
        {
            Caption ='Mail Resent';            
        }
        field(70; "Resent e-mail"; Text[80])
        {
            Caption ='Resent e-mail';
        }
        field(75; "Date Resent"; Date)
        {
            Caption ='Date Resent';
        }
        field(80; "Resent By"; Code[20])
        {
            Caption ='Resent By';
        }
        field(85; Cancelled; Boolean)
        {
            Caption ='Cancelled';
            FieldClass = FlowField;
            CalcFormula= Lookup("LSC POS Data Entry".Applied WHERE ("Entry Type"=FIELD("Entry Type"),"Entry Code"=FIELD("Entry Code"),"Applied by Receipt No."=CONST('CANCELLED')));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry Type", "Entry Code")
        {
            Clustered = true;
        }
        key(Key2; "Date Sent")
        {
        }
    }
}
