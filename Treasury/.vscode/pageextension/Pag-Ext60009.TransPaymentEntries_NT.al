pageextension 60009 "Trans. Payment Entries_NT" extends "LSC Trans. Payment Entries"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("E&ntry")
        {
            group("&Print")
            {
                Caption = '&Print';
                action("&Print Copy")
                {
                    ApplicationArea = All;
                    Caption = '&Print Copy';
                    Image = Print;

                    trigger OnAction()
                    var
                        TransactionHeader: Record "LSC Transaction Header";
                    begin
                        TransactionHeader.Reset;
                        TransactionHeader.SetRange("Store No.", Rec."Store No.");
                        TransactionHeader.SetRange("POS Terminal No.", Rec."POS Terminal No.");
                        TransactionHeader.SetRange("Transaction No.", Rec."Transaction No.");

                        REPORT.RunModal(Report::"LSC Detailed Receipt", true, true, TransactionHeader);
                    end;
                }
            }
        }
    }

    var
        myInt: Integer;
}
