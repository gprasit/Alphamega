pageextension 60311 "Member Point Journal _NT" extends "LSC Member Point Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Post")
        {
            action(POSTOPENING)
            {
                Caption = 'POST OPENING BALANCE';
                ApplicationArea = All;

                trigger OnAction()
                var
                    PointJnlPost_NT: Codeunit "NT_Point Jnl.-Post";
                begin
                    PointJnlPost_NT.Run(Rec);
                end;
            }
        }
    }

    var
        myInt: Integer;
}
