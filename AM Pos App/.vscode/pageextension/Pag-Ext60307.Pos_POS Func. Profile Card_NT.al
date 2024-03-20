
pageextension 60307 "Pos_POS Func. Profile Card_NT" extends "LSC POS Func. Profile Card"
{
    layout
    {        
        addafter("Neg. Adj. Slip Report ID")
        {
            field("Trans. Sales Inv. Report ID"; Rec."Trans. Sales Inv. Report ID")
            {
                ApplicationArea = All;                
            }
            field("Negative Adjustment Report ID"; Rec."Negative Adjustment Report ID")
            {
                ApplicationArea = All;                
            }
        }
        addafter("Update Search Index")
        {
            field("Auto Send Batch After Z Report"; Rec."Auto Send Batch After Z Report")
            {
                ApplicationArea = All;                
            }
            field("Loyalty Card on Cust. Trans."; Rec."Loyalty Card on Cust. Trans.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether Member card is required when there is a customer in transaction.';
            }

            field("Watermark on Negative Adj."; Rec."Watermark on Negative Adj.")
            {
                ApplicationArea = All;
                ToolTip = 'Displays water mark for Negative Adj. at POS when check marked.';
            }
        }
    }
    
    actions
    {        
    }    
    var
        
}