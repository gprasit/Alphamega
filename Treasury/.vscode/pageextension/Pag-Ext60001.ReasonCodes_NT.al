pageextension 60001 ReasonCodes_NT extends "Reason Codes"
{
    layout
    {
        addafter("LSC Group")
        {
            field("G/L Account No."; Rec."G/L Account No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of the account that the entry will be posted from treasury journal on selection of the corresponding reason code.';
            }
            field("G/L Account Name"; Rec."G/L Account Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the name of the account.';
            }
        }

    }

    actions
    {
    }

    var

}
