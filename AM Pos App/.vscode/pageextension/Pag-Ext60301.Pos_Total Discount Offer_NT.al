pageextension 60301 "Pos_Total Discount Offer_NT" extends "LSC Total Discount Offer"
{

    layout
    {
        // Add changes to page layout here
        addafter("Use Trans. Line Time")
        {
            field("POS Popup Message"; Rec."POS Popup Message")
            {
                ApplicationArea = All;
            }
        }
        addafter("Use Offer Total Amount")
        {
            // field("Amount to Trigger"; Rec."Amount to Trigger")
            // {
            //     ApplicationArea = All;
            // }
            field("Amt. to Trigger Based on Lines"; Rec."Amt. to Trigger Based on Lines")
            {
                ApplicationArea = All;
            }
            field("Valid Only When Member Scanned"; Rec."Valid Only When Member Scanned")
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