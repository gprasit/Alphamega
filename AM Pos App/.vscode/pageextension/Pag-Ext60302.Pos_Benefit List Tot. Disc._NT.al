pageextension 60302 "Pos_Benefit List Tot. Disc._NT" extends "LSC Benefit List Total Disc."
{

    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {
            field(PopUp; Rec.PopUp)
            {
                ApplicationArea = All;
                ToolTip = 'Place a check mark when you want the benefit as a Popup Message';
            }
        }
        addafter(Value)
        {
            field("Popup Message"; Rec."Popup Message")
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