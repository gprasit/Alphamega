table 60417 "Member Point EntryPOS Adj_NT"
{
    Caption = 'Member Point Entry Pos. Adj';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Source Type"; Enum "LSC Member Point Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(5; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "LSC Member Account"."No.";
            DataClassification = CustomerContent;
        }
        field(6; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = "LSC Member Contact"."Contact No." WHERE("Account No." = FIELD("Account No."));
            DataClassification = CustomerContent;
        }
        field(7; "Card No."; Text[100])
        {
            Caption = 'Card No.';
            TableRelation = "LSC Membership Card";
            DataClassification = CustomerContent;
        }
        field(8; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Sales,Redemption,Expire,Positive Adjmt.,Negative Adjmt,Transfer From,Transfer To';
            OptionMembers = Sales,Redemption,Expire,"Positive Adjmt.","Negative Adjmt","Transfer From","Transfer To";
            DataClassification = CustomerContent;
        }
        field(10; "Point Type"; Option)
        {
            Caption = 'Point Type';
            OptionCaption = 'Award Points,Other Points';
            OptionMembers = "Award Points","Other Points";
            DataClassification = CustomerContent;
        }
        field(11; Points; Decimal)
        {
            Caption = 'Points';
            DecimalPlaces = 0 : 1;
            DataClassification = CustomerContent;
        }
        field(12; "Point Value"; Decimal)
        {
            Caption = 'Point Value';
            DataClassification = CustomerContent;
        }
        field(13; "Posting Value"; Decimal)
        {
            Caption = 'Posting Value';
            DataClassification = CustomerContent;
        }
        field(14; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(15; "Remaining Points"; Decimal)
        {
            Caption = 'Remaining Points';
            DecimalPlaces = 0 : 1;
            DataClassification = CustomerContent;
        }
        field(16; "Closed by Entry"; Integer)
        {
            Caption = 'Closed by Entry';
            TableRelation = "LSC Member Point Entry"."Entry No.";
            DataClassification = CustomerContent;
        }
        field(17; "Closed by Points"; Decimal)
        {
            Caption = 'Closed by Points';
            DecimalPlaces = 0 : 1;
            DataClassification = CustomerContent;
        }
        field(20; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(30; "Member Club"; Code[10])
        {
            Caption = 'Member Club';
            TableRelation = "LSC Member Club".Code;
            DataClassification = CustomerContent;
        }
        field(31; "Member Scheme"; Code[10])
        {
            Caption = 'Member Scheme';
            TableRelation = "LSC Member Scheme".Code;
            DataClassification = CustomerContent;
        }
        field(35; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
            DataClassification = CustomerContent;
        }
        field(36; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "LSC POS Terminal"."No." WHERE("Store No." = FIELD("Store No."));
            DataClassification = CustomerContent;
        }
        field(37; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(40; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code".Code;
            DataClassification = CustomerContent;
        }
        field(50; "Posted to G/L"; Boolean)
        {
            Caption = 'Posted to G/L';
            DataClassification = CustomerContent;
        }
        field(60; "Date Processed"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(70; "Time Processed"; Time)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Date Processed", "Time Processed")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;
}

