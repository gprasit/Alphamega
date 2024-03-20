pageextension 60309 "Pos_LSC Member Point Offer_NT" extends "LSC Member Point Offer"
{
    layout
    {
        // Add changes to page layout here
        addafter(SalesTypeFilter)
        {
            field("Amount To Trigger"; Rec."Amount To Trigger")
            {
                ApplicationArea = All;
                BlankZero = true;
            }
            field("Amt. To Trigger Based On Lines"; Rec."Amt. To Trigger Based On Lines")
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
