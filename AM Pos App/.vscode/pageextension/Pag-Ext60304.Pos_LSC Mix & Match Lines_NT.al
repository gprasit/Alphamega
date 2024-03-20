pageextension 60304 "Pos_LSC Mix & Match Lines_NT" extends "LSC Mix & Match Lines"
{
    layout
    {
        // Add changes to page layout here
        addafter("No. of Items Needed")
        {
            field("Offset for No. of Items"; Rec."Offset for No. of Items")
            {
                ApplicationArea = All;                
            }
            field("Actual No. of Items Needed"; Rec."No. of Items Needed" + Rec."Offset for No. of Items")
            {
                ApplicationArea = All;
                Editable =  false;
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
