page 60024 "Posted Stmt. Z Report-Lines_NT"
{
    Caption = 'Z Report-Lines';
    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    SourceTable = "Posted Stmt. Z Report-Lines_NT";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff ID field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Z Amount"; Rec."Z-Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Counted Amount field.';
                }
                field("Trans. Amount"; Rec."Trans. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trans. Amount field.';
                    trigger OnDrillDown()
                    begin
                        PmtTransactionsTEMP.Reset;
                        PmtTransactionsTEMP.DeleteAll;

                        PmtTransactions.Reset;
                        // PmtTransactions.SetRange("Tender Type", "Tender Type");
                        // PmtTransactions.SetFilter("Currency Code", '%1', "Currency Code");
                        // PmtTransactions.SetFilter("Card No.", '%1', "Tender Type Card No.");

                        TransactionStatus.Reset;
                        TransactionStatus.SetCurrentKey("Statement No.");
                        TransactionStatus.SetRange("Statement No.", Rec."Statement No.");
                        if Rec."Staff ID" <> '' then
                            PmtTransactions.SetRange("Staff ID", Rec."Staff ID");
                        // else
                        //     if "POS Terminal No." <> '' then
                        //         TransactionStatus.SetRange("POS Terminal No.", "POS Terminal No.");
                        if TransactionStatus.FindSet() then
                            repeat
                                PmtTransactions.SetRange("Store No.", TransactionStatus."Store No.");
                                PmtTransactions.SetRange("POS Terminal No.", TransactionStatus."POS Terminal No.");
                                PmtTransactions.SetRange("Transaction No.", TransactionStatus."Transaction No.");
                                if PmtTransactions.FindSet() then
                                    repeat
                                        PmtTransactionsTEMP := PmtTransactions;
                                        PmtTransactionsTEMP.Insert;
                                    until PmtTransactions.Next = 0;
                            until TransactionStatus.Next = 0;
                        PAGE.RunModal(0, PmtTransactionsTEMP, PmtTransactionsTEMP."Amount in Currency");
                    end;
                }
                field("Z-Difference Amount"; Rec."Z-Difference Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Z-Difference Amount field.';
                }
                field("SMT-Counted Amount"; Rec."STMT-Counted Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Statement Counted Amount field.';
                }

                field("STMT-Difference Amount"; Rec."STMT-Difference Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Statement Difference Amount field.';
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value entered as comments or notes.';
                }
                field("Z-Amount in LCY"; Rec."Z-Amount in LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Counted Amount in LCY field.';
                }

                field("Trans. Amount in LCY"; Rec."Trans. Amount in LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trans. Amount in LCY field.';
                    trigger OnDrillDown()
                    begin
                        PmtTransactionsTEMP.Reset;
                        PmtTransactionsTEMP.DeleteAll;

                        PmtTransactions.Reset;
                        TransactionStatus.Reset;
                        TransactionStatus.SetCurrentKey("Statement No.");
                        TransactionStatus.SetRange("Statement No.", Rec."Statement No.");
                        if Rec."Staff ID" <> '' then
                            PmtTransactions.SetRange("Staff ID", Rec."Staff ID");
                        if TransactionStatus.FindSet() then
                            repeat
                                PmtTransactions.SetRange("Store No.", TransactionStatus."Store No.");
                                PmtTransactions.SetRange("POS Terminal No.", TransactionStatus."POS Terminal No.");
                                PmtTransactions.SetRange("Transaction No.", TransactionStatus."Transaction No.");
                                if PmtTransactions.FindSet() then
                                    repeat
                                        PmtTransactionsTEMP := PmtTransactions;
                                        PmtTransactionsTEMP.Insert;
                                    until PmtTransactions.Next = 0;
                            until TransactionStatus.Next = 0;
                        PAGE.RunModal(0, PmtTransactionsTEMP, PmtTransactionsTEMP."Amount Tendered");
                    end;
                }
                field("Z-Difference in LCY"; Rec."Z-Difference in LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Z-Difference in LCY field.';
                }

                field("STMT-Counted in LCY"; Rec."STMT-Counted in LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Statement Counted in LCY field.';
                }

                field("STMT-Difference in LCY"; Rec."STMT-Difference in LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference in LCY field.';
                }
            }
        }
    }
    var
        PmtTransactionsTEMP: Record "LSC Trans. Payment Entry" temporary;
        PmtTransactions: Record "LSC Trans. Payment Entry";
        TransactionStatus: Record "LSC Transaction Status";
}
