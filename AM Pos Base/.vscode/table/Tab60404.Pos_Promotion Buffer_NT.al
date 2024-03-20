table 60404 "Pos_Promotion Buffer_NT"
{
    Caption = 'Promotion Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(5; "Curent Action"; Code[1])
        {
            Caption = 'Curent Action';
        }
        field(10; "Store Code"; Code[4])
        {
            Caption = 'Store Code';
        }
        field(15; "Promotion Event Number"; Code[10])
        {
            Caption = 'Promotion Event Number';
        }
        field(20; "Promotion Event Description"; Text[35])
        {
            Caption = 'Promotion Event Description';
        }
        field(25; "Promotion Event Category"; Code[2])
        {
            Caption = 'Promotion Event Category';
        }
        field(30; "Event Category Description"; Text[30])
        {
            Caption = 'Event Category Description';
        }
        field(35; "Promotion From Date"; Date)
        {
            Caption = 'Promotion From Date';
        }
        field(40; "Promotion To Date"; Date)
        {
            Caption = 'Promotion To Date';
        }
        field(45; "Promotion Type"; Code[1])
        {
            Caption = 'Promotion Type';
        }
        field(50; "Promotion Identifier"; Code[20])
        {
            Caption = 'Promotion Identifier';
        }
        field(55; "Promotion Receipt Line"; Text[50])
        {
            Caption = 'Promotion Receipt Line';
        }
        field(60; "Item Required"; Code[20])
        {
            Caption = 'Item Required';
        }
        field(65; "Item Free"; Code[20])
        {
            Caption = 'Item Free';
        }
        field(70; "Item Required Quantity_Txt"; Code[2])
        {
            Caption = 'Item Required Quantity_Txt';
        }
        field(75; "Item Required Quantity_Dec"; Integer)
        {
            Caption = 'Item Required Quantity_Dec';
        }
        field(80; "Item Free Quantity"; Code[2])
        {
            Caption = 'Item Free Quantity';
        }
        field(85; "Discount Percentage"; Code[10])
        {
            Caption = 'Discount Percentage';
        }
        field(90; "Discount Percentage_Dec"; Decimal)
        {
            Caption = 'Discount Percentage_Dec';
        }
        field(95; Points; Code[2])
        {
            Caption = 'Points';
        }
        field(100; "Promotion Price"; Code[10])
        {
            Caption = 'Promotion Price';
        }
        field(105; "Promotion Group"; Code[2])
        {
            Caption = 'Promotion Group';
        }
        field(110; "Promotion Limit"; Code[2])
        {
            Caption = 'Promotion Limit';
        }
        field(115; Pillar; Code[10])
        {
            Caption = 'Pillar';
        }
        field(120; "Promotion Search Key"; Code[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Promotion Search Key")
        {
        }
        key(Key3; "Promotion Identifier", "Item Required", "Store Code", "Promotion From Date", "Promotion To Date")
        {
        }
    }
}
