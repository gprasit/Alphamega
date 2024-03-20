pageextension 60105 "eCom_Sales Order SubForm_NT" extends "Sales Order Subform"
{
    layout
    {
        // Add changes to page layout here

        addafter("Line Amount")
        {
            field("LSC Offer No."; Rec."LSC Offer No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("LSC Promotion No."; Rec."LSC Promotion No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Allow Substitute"; Rec."Allow Substitute")
            {
                ApplicationArea = All;
                Editable = false;
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
