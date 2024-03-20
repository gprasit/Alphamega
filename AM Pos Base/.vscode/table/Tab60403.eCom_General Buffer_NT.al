table 60403 "eCom_General Buffer_NT"
{
    Caption = 'General Buffer';
    DataClassification = CustomerContent;
    fields
    {
        field(60001; "Code 1"; Code[20])
        {
            Caption = 'Code 1';
        }
        field(60002; "Code 2"; Code[20])
        {
            Caption = 'Code 2';
        }
        field(60003; "Code 3"; Code[20])
        {
            Caption = 'Code 3';
        }
        field(60004; "Code 4"; Code[20])
        {
            Caption = 'Code 4';
        }
        field(60005; "Code 5"; Code[20])
        {
            Caption = 'Code 5';
        }
        field(60006; "Code 6"; Code[20])
        {
            Caption = 'Code 6';
        }
        field(60007; "Code 7"; Code[20])
        {
            Caption = 'Code 7';
        }
        field(60008; "Code 8"; Code[20])
        {
            Caption = 'Code 8';
        }
        field(60009; "Code 9"; Code[20])
        {
            Caption = 'Code 9';
        }
        field(60010; "Code 10"; Code[20])
        {
            Caption = 'Code 10';
        }
        field(60011; "Decimal 1"; Decimal)
        {
            Caption = 'Decimal 1';
        }
        field(60012; "Decimal 2"; Decimal)
        {
            Caption = 'Decimal 2';
        }
        field(60013; "Decimal 3"; Decimal)
        {
            Caption = 'Decimal 3';
        }
        field(60014; "Decimal 4"; Decimal)
        {
            Caption = 'Decimal 4';
        }
        field(60015; "Decimal 5"; Decimal)
        {
            Caption = 'Decimal 5';
        }
        field(60016; "Date 1"; Date)
        {
            Caption = 'Date 1';
        }
        field(60017; "Date 2"; Date)
        {
            Caption = 'Date 2';
        }
        field(60018; "Date 3"; Date)
        {
            Caption = 'Date 3';
        }
        field(60019; "Date 4"; Date)
        {
            Caption = 'Date 4';
        }
        field(60020; "Date 5"; Date)
        {
            Caption = 'Date 5';
        }

        field(60021; "Integer 1"; Integer)
        {
            Caption = 'Integer 1';
        }
        field(60022; "Integer 2"; Integer)
        {
            Caption = 'Integer 2';
        }
        field(60023; "Integer 3"; Integer)
        {
            Caption = 'Integer 3';
        }
        field(60024; "Integer 4"; Integer)
        {
            Caption = 'Integer 4';
        }
        field(60025; "Integer 5"; Integer)
        {
            Caption = 'Integer 5';
        }
        field(60026; "Text 1"; Text[250])
        {
            Caption = 'Text 1';
        }
        field(60027; "Text 2"; Text[250])
        {
            Caption = 'Text 2';
        }
        field(60028; "Text 3"; Text[250])
        {
            Caption = 'Text 3';
        }
        field(60029; "Boolean 1"; Boolean)
        {
            Caption = 'Boolean 1';
        }
        field(60030; "Boolean 2"; Boolean)
        {
            Caption = 'Boolean 2';
        }
        field(60031; "Boolean 3"; Boolean)
        {
            Caption = 'Boolean 3';
        }
    }
    keys
    {
        key(PK; "Code 1", "Code 2", "Code 3", "Code 4", "Code 5")
        {
            Clustered = true;
        }
    }
}
