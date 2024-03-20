pageextension 60308 "Pos_Transaction Card_NT" extends "LSC Transaction Card"
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
            action("Print &Invoice")
            {
                ApplicationArea = all;
                Caption = 'Print &Invoice';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;      
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

