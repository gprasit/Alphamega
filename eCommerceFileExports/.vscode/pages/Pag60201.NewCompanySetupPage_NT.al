page 60201 NewCompanySetupPage2_NT
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'AlphaMega New Company Setup 2 Test Page';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(InputParam; InParam)
                {
                    ApplicationArea = All;
                    Caption = 'Input';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            group(XML_Port)
            {
                Caption = 'XML Ports';
                action(XMLPort1)
                {
                    ApplicationArea = All;
                    Caption = 'XML Port Store Item Data';
                    trigger OnAction()
                    var
                        MyXmlPort: XmlPort "eCom-Store Item Data_NT";
                    begin
                        MyXmlPort.Run();
                    end;
                }
                action(XMLPort2)
                {
                    ApplicationArea = All;
                    Caption = 'XML Port Store Data';
                    trigger OnAction()
                    var
                        MyXmlPort: XmlPort "eCom-Store Data_NT";
                    begin
                        MyXmlPort.Run();
                    end;
                }
                action(XMLPort3)
                {
                    ApplicationArea = All;
                    Caption = 'XML Port Pick Order';
                    trigger OnAction()
                    var
                        MyXmlPort: XmlPort "eCom-Pick Order_NT";
                    begin
                        MyXmlPort.Run();
                    end;
                }
                action(StringTest)
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Operation: Text;
                    begin
                        Operation := 'MYFOOT';
                        message(StrSubstNo('<Operation>%1</Operation>', Operation));
                    end;
                }
            }
        }

    }

    var
        InParam: Code[20];
}