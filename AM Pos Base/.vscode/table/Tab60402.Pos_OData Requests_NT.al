table 60402 "Pos_OData Requests_NT"
{
    Caption = 'Pos OData Requests';
    DataCaptionFields = "Request Id";
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Request Id"; Text[30])
        {
            Caption = 'Request Id';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(20; "OData Base Url"; Text[50])
        {
            Caption = 'OData Base Url';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                ConstructDefinitionUrl();
            end;
        }
        field(25; "OData Services Port"; Text[10])
        {
            Caption = 'OData Services Port';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                ConstructDefinitionUrl();
            end;
        }
        field(30; "Server Instance Name"; Text[30])
        {
            Caption = 'Server Instance Name';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                ConstructDefinitionUrl();
            end;
        }
        field(35; "OData Version Text"; Text[20])
        {
            Caption = 'OData Version Text';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                ConstructDefinitionUrl();
            end;
        }
        field(40; "Web Service Name"; Text[30])
        {
            Caption = 'Web Service Name';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                ConstructDefinitionUrl();
            end;
        }
        field(45; Operation; Text[30])
        {
            Caption = 'Operation';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                ConstructDefinitionUrl();
            end;
        }

        field(50; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                ConstructDefinitionUrl();
            end;
        }
        field(55; "User Name"; Text[50])
        {
            Caption = 'User Name';
            DataClassification = CustomerContent;
        }
        field(60; "Web Service Access Key"; Text[80])
        {
            Caption = 'Web Service Access Key';
            DataClassification = CustomerContent;
        }

        field(65; "Time Out"; Integer)
        {
            Caption = 'Time Out';
            DataClassification = CustomerContent;
        }

        field(70; "Definition Url"; Text[250])
        {
            Caption = 'Definition Url';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Request Id")
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

    local procedure ConstructDefinitionUrl()
    var
    begin
        "Definition Url" := "OData Base Url" + ':' + "OData Services Port" + '/' + "Server Instance Name" + '/' + "OData Version Text" + '/' + "Web Service Name" + '_' + Operation + '?company=' + "Company Name";
    end;

    var
}


