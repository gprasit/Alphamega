pageextension 60312 "Retail Item Card_NT" extends "LSC Retail Item Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Qty not in Decimal")
        {
            field("Compress When Scanned"; Rec."Compress When Scanned")
            {
                ApplicationArea = All;
            }
        }
    }
    
    actions
    {
        // Add changes to page actions here
    }
    
    var
        myInt: Integer;
}