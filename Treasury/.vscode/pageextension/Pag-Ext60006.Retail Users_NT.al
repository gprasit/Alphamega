pageextension 60006 "Retail Users_NT" extends "LSC Retail Users"
{
    layout
    {
        addafter("Location Code")
        {
            field("Store Hierarchy No."; Rec."Store Hierarchy No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the store hierarchy no. for the corresponding retail user.';
            }

        }
    }

    actions
    {

    }

    var
        myInt: Integer;
}
