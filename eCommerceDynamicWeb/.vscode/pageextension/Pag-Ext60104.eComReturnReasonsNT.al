pageextension 60104 "eCom_Return Reasons_NT" extends "Return Reasons"
{
    layout
    {
        addafter("Inventory Value Zero")
        {
            field("Transaction Type"; Rec."Transaction Type")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {

    }

    var
        myInt: Integer;
}
