pageextension 60401 "MA_LSC Published Offer_NT" extends "LSC Published Offer"
{
    layout
    {
        // Add changes to page layout here
        addafter("Secondary Text")
        {
            field("Member Type"; Rec."Member Type")
            {
                ApplicationArea = all;
            }
            field("Member Value"; Rec."Member Value")
            {
                ApplicationArea = all;
            }
            field("Member Attribute"; Rec."Member Attribute")
            {
                ApplicationArea = all;
            }
            field("Member Attribute Value"; Rec."Member Attribute Value")
            {
                ApplicationArea = all;
            }
            field("Display Order"; Rec."Display Order")
            {
                ApplicationArea = all;
            }

        }
        // addafter(General)
        // {
        //     part("Published Offer Validity"; "MA_Published Offer Validity_NT")
        //     {
        //         SubPageLink = "Published Offer No." = field("No.");
        //         Caption = 'Published Offer Validity';
        //         ApplicationArea = all;
        //         UpdatePropagation = Both;
        //     }
        // }
        modify("Offer Category")
        {
            Editable = true;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}