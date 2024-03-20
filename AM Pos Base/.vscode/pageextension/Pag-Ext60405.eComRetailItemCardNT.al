pageextension 60405 "eCom_Retail Item Card_NT" extends "LSC Store Card"
{
    layout
    {
        // Add changes to page layout here
        addafter(Omni)
        {
            group(AMeCommerce)
            {
                Caption = 'AM Commerce';
                field(sss;Rec."Web Store No.")
                {
                    ApplicationArea = All;
                }
                
                
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
