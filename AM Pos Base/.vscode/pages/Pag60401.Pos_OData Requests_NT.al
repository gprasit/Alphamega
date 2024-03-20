page 60401 "Pos_OData Requests_NT"
{
    ApplicationArea = All;
    Caption = 'OData Requests';
    PageType = List;
    SourceTable = "Pos_OData Requests_NT";
    UsageCategory = Administration;
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Request Id"; Rec."Request Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Id field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("OData Base Url"; Rec."OData Base Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OData Base Url field.';
                }
                field("OData Services Port"; Rec."OData Services Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OData Services Port field.';
                }
                field("Server Instance Name"; Rec."Server Instance Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Server Instance Name field.';
                }
                field("OData Version Text"; Rec."OData Version Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OData Version Text field.';
                }
                field("Web Service Name"; Rec."Web Service Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Name field.';
                }
                field(Operation; Rec.Operation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Operation field.';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field.';
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                }
                field("Web Service Access Key"; Rec."Web Service Access Key")
                {
                    ApplicationArea = All;
                }
                field("Time Out"; Rec."Time Out")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Web service request time out defined in milliseconds.';
                }
                field("Definition Url"; Rec."Definition Url")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Definition Url field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Test OData Connection")
            {
                ApplicationArea = All;
                Caption = 'Test OData Connection';
                Image = TestFile;

                trigger OnAction()
                var
                    PosGenFuncBase: Codeunit "Pos_General Functions Base_NT";
                begin
                    PosGenFuncBase.Test_ODATA_Connection();
                end;
            }
        }
    }
}

