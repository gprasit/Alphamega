
pageextension 60404 "eVch_Pos Data Entry_NT" extends "LSC POS Data Entries"
{
    layout
    {
        // Add changes to page layout here
    }
    
    actions
    {
        // Add changes to page actions here
        addbefore("&Voucher Entries")
        {
            action("&Cancel Entry")
            {
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                var
                eVchMgt: Codeunit "eVch_eVoucher Management_NT";
                begin
                    eVchMgt.CancelDataEntry(Rec);
                end;
            }
        }
    }
    
    var
        myInt: Integer;
}