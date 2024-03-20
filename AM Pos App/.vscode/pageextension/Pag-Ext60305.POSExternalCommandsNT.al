pageextension 60305 "POS_External Commands_NT" extends "LSC POS External Commands"
{
    layout
    {
        // Add changes to page layout here
        addafter("Run Codeunit")
        {
            field(Prompt; Rec.Prompt)
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