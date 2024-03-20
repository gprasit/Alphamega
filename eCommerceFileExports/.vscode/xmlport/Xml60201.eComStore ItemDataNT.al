xmlport 60201 "eCom-Store Item Data_NT"
{
    Encoding = UTF8;
    Direction = Export;
    schema
    {
        textelement(StoreItemData)
        {
            XmlName = 'StoreItemData';
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
            textelement(Type)
            {
                XmlName = 'Type';
            }
            textelement(StoreItems)
            {
                XmlName = 'StoreItems';
                tableelement("General Buffer"; "eCom_General Buffer_NT")
                {
                    XmlName = 'StoreItem';
                    fieldelement(Item_ID; "General Buffer"."Code 1")
                    {
                    }
                    fieldelement(Store_ID; "General Buffer"."Code 2")
                    {
                    }
                    textelement(Status)
                    {
                        XmlName = 'Status';
                    }
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
                Status := 'NEW';
                Type := 'PARTLY';
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
    procedure InsertRec(ItemNo: Code[20]; StoreNo: Code[10])
    begin
        "General Buffer"."Code 1" := ItemNo;
        "General Buffer"."Code 2" := StoreNo;
        "General Buffer".INSERT;
    end;
}