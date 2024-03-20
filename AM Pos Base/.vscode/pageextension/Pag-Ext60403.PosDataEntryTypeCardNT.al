pageextension 60403 "Pos_Data Entry Type Card_NT" extends "LSC POS Data Entry Type Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Expiration Formula")
        {
            field(Prefix; Rec.Prefix)
            {
                ApplicationArea = All;                
            }
            field("Exclude Item Category"; Rec."Exclude Item Category")
            {
                ApplicationArea = All;
            }
            field("Tender Type"; Rec."Tender Type")
            {
                ApplicationArea = All; 
            }
            field("Amount Editable"; Rec."Amount Editable")
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