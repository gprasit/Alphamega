pageextension 60306 "Pos_Transaction Register_NT" extends "LSC Transaction Register"
{
    layout
    {
        // Add changes to page layout here   

    }

    actions
    {
        // Add changes to page actions here
        addafter("&Print")
        {
            group("&Email")
            {
                Caption = '&Email';
                action("&Email Copy")
                {
                    ApplicationArea = All;
                    Caption = '&Email Copy';
                    Image = SendEmailPDF;
                    trigger OnAction()
                    var
                        PosGenFunc: codeunit "Pos_General Functions_NT";
                    begin
                        PosGenFunc.EMailTransSlip(Rec);
                    end;
                }
                separator(Email_Seperator_NT)
                {
                }
            }
        }
        addafter("&Print Copy")
        {
            action("Print &Invoice")
            {
                ApplicationArea = all;
                Caption = 'Print &Invoice';
                Image = Print;
                trigger OnAction()
                var
                    PosGenFunc: Codeunit "Pos_General Functions_NT";
                begin
                    PosGenFunc.PrintInvoiceFromTransRegister(Rec);
                end;
            }
        }
    }

    var
        myInt: Integer;
}
