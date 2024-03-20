xmlport 60102 Kiosk_GetPostCodes_NT
{
    Caption = 'Post Codes';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    schema
    {
        textelement(GetPostCodeResponse)
        {
            textelement(GetPostCodesResult)
            {
                tableelement(TempPostalCodes; eCom_PostOfficeAddress_NT)
                {
                    SourceTableView = sorting("Postal Code");
                    XmlName = 'PostalCodes';
                    UseTemporary = true;
                    MinOccurs = Zero;
                    fieldelement(PostalCode; TempPostalCodes."Postal Code")
                    {
                    }
                }
            }
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
            }
        }
    }
    procedure SetUniquePostalCodes()
    var
        PostCodes: Record eCom_PostOfficeAddress_NT;
    begin
        if PostCodes.FindSet() then
            repeat
                TempPostalCodes.SetRange("Postal Code", PostCodes."Postal Code");
                if not TempPostalCodes.FindFirst() then begin
                    TempPostalCodes.Reset();
                    TempPostalCodes.Init();
                    TempPostalCodes.TransferFields(PostCodes);
                    TempPostalCodes.Insert();
                end;
            until PostCodes.Next() = 0;
        TempPostalCodes.Reset();
    end;

}
