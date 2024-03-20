
pageextension 60005 "Tender Type Setup_NT" extends "LSC Tender Type Setup List"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Default Treasury Jrnl. Tender"; Rec."Default Treasury Jrnl. Tender")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this tender will be included in the drop down list of tender in the treasury journal. To have the tender included in the list, place a check mark in the check box.';
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
