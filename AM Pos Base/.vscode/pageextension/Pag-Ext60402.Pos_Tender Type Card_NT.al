pageextension 60402 "Pos_Tender Type Card_NT" extends "LSC Tender Type Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("POS Count Entries")
        {
            field("Only Negative Transaction"; Rec."Only Negative Transaction")
            {
                ApplicationArea = All;
            }
        field("Exclude in Z Report_NC"; Rec."Exclude in Z Report_NC")
        {
            ApplicationArea = All;
           ToolTip ='Check mark this field for tender(s) to be excluded from Z-Report non cash';     
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
