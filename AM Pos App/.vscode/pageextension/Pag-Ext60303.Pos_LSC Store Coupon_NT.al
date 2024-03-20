pageextension 60303 "Pos_LSC Store Coupon_NT" extends "LSC Store Coupon"
{
    layout
    {
        // Add changes to page layout here
        addafter(Handling)
        {
            field("Tender Type"; Rec."Tender Type")
            {
                ApplicationArea = All;
            }
        }
        addafter("Maximum Trans. Amount")
        {
            field("Check Member Quantity"; Rec."Check Member Quantity")
            {
                ApplicationArea = All;                
            }
            field("Member Attribute"; Rec."Member Attribute")
            {
                ApplicationArea = All;                
            }
            field("Member Attribute Value"; Rec."Member Attribute Value")
            {
                ApplicationArea = All;             
            }
            field("Point Value"; Rec."Point Value")
            {
                ApplicationArea = All;            
            }
            field("Amount to Trigger"; Rec."Amount to Trigger")
            {
                ApplicationArea = All;               
            }
            field("Amt. to Trigger Based on Lines"; Rec."Amt. to Trigger Based on Lines")
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
