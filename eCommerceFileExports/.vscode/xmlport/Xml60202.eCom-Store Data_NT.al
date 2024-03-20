xmlport 60202 "eCom-Store Data_NT"
{
    Direction = Export;
    Encoding = UTF8;
    schema
    {
        textelement(StoreData)
        {
            XmlName = 'StoreData';
            textelement(File_Created_Date)
            {
                XmlName = 'File_Created_Date';
            }
            textelement(File_Created_Time)
            {
                XmlName = 'File_Created_Time';
            }
            textelement(Sending_System)
            {
                XmlName = 'Sending_System';
            }
            textelement(Receiving_System)
            {
                XmlName = 'Receiving_System';
            }

            textelement(Stores)
            {
                XmlName = 'Stores';
                tableelement(Store; "LSC Store")
                {
                    SourceTableView = SORTING("No.") WHERE("No." = FILTER(9998 | 9999));
                    XmlName = 'Store';
                    fieldelement(Store_ID; Store."No.")
                    {
                    }
                    fieldelement(Description; Store.Name)
                    {
                    }
                    fieldelement(Address; Store.Address)
                    {
                    }
                    fieldelement(City; Store.City)
                    {
                    }
                    fieldelement(Zip; Store."Post Code")
                    {
                    }
                    fieldelement(Telephone; Store."Phone No.")
                    {
                    }
                    trigger OnPreXmlItem()
                    var
                    begin
                        IF _FilterValue <> '' THEN
                            Store.SETFILTER("No.", _FilterValue);

                    end;
                }
            }

            trigger OnBeforePassVariable()
            var
                myInt: Integer;
            begin
                File_Created_Date := FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>');
                File_Created_Time := FORMAT(TIME);
                Sending_System := 'Dymanics NAV';
                Receiving_System := 'CUBLink';
            end;

        }

    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {

                }
            }
        }
    }
    procedure SetFilter(FilterValue: Text[250])
    begin
        _FilterValue := FilterValue;
    end;

    var
        _FilterValue: Text[250];
}