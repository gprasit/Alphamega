xmlport 60105 "Kiosk_Generic_XML_Response_NT"
{
    Caption = 'Generic XML Response';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    schema
    {
        textelement(RootXMLResponse)
        {
            textelement(ResultStatus)
            {
                trigger OnBeforePassVariable()
                begin
                    ResultStatus := ResultStatusVal;
                end;
            }
            textelement(ErrorMessage)
            {
                trigger OnBeforePassVariable()
                begin
                    ErrorMessage := ErrorMessageVal;
                end;
            }
            textelement(ErrorMessage2)
            {
                trigger OnBeforePassVariable()
                begin
                    ErrorMessage2 := ErrorMessage2Val;
                end;
            }

            textelement(CardNo)
            {
                trigger OnBeforePassVariable()
                begin
                    CardNo := CardNoVal;
                end;
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
    procedure SetResponseValues(ResponseName: Text; ResultNodeName: Text; ResultStatus: Text; ErrorMessage: Text; ErrorMessage2: Text; CardNo: Text)
    begin
        ResponseNameVal := ResponseName;
        ResultNodeNameVal := ResultNodeName;
        ResultStatusVal := ResultStatus;
        ErrorMessageVal := ErrorMessage;
        ErrorMessage2Val := ErrorMessage2;
        CardNoVal := CardNo;
    end;

    var
        ResponseNameVal: Text;
        ResultNodeNameVal: Text;
        ResultStatusVal: Text;
        ErrorMessageVal: Text;
        ErrorMessage2Val: Text;
        CardNoVal: Text;
}
