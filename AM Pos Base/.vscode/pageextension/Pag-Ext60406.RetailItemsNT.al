pageextension 60406 "Retail Items_NT" extends "LSC Retail Item Card"
{
    layout
    {
        // Add changes to page layout here
        addafter(General)
        {
            group(eCommerce)
            {
                field("Web Always On Stock"; Rec."Web Always On Stock")
                {
                    ApplicationArea = All;
                }
                field("Web Item"; Rec."Web Item")
                {
                    ApplicationArea = All;
                }
                field("Web Weight"; Rec."Web Weight")
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