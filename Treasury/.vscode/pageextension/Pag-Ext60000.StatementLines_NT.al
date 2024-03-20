pageextension 60000 "Statement Lines_NT" extends "LSC Statement Lines"
{
    layout
    {
        // Add changes to page layout here
        modify("Counted Amount")
        {
            trigger OnAfterValidate()
            var
                TreasuryMgmt: Codeunit "Treasury Management_NT";
            begin
                TreasuryMgmt.UpdTreasuryStmtRecalculateOnStmtLineChange(Rec);
                OnFieldValidate();
            end;
        }
        modify("Tender Type")
        {
            Editable = ControlEditable;
            trigger OnAfterValidate()
            var
                TreasuryMgmt: Codeunit "Treasury Management_NT";
            begin
                TreasuryMgmt.UpdTreasuryStmtRecalculateOnStmtLineChange(Rec);
            end;
        }
        modify("Trans. Amount")
        {
            trigger OnDrillDown()
            var
                PmtTransactionsTEMP: Record "LSC Trans. Payment Entry" temporary;
                PmtTransactions: Record "LSC Trans. Payment Entry";
                TransactionStatus: Record "LSC Transaction Status";
            begin
                PmtTransactionsTEMP.Reset;
                PmtTransactionsTEMP.DeleteAll;

                PmtTransactions.Reset;
                PmtTransactions.SetRange("Tender Type", Rec."Tender Type");
                PmtTransactions.SetFilter("Currency Code", '%1', Rec."Currency Code");
                if Rec."Tender Type Card No." <> '' then //Condition Added NT
                    PmtTransactions.SetFilter("Card No.", '%1', Rec."Tender Type Card No.");
                TransactionStatus.Reset;
                TransactionStatus.SetCurrentKey("Statement No.");
                TransactionStatus.SetRange("Statement No.", Rec."Statement No.");
                if Rec."Staff ID" <> '' then
                    PmtTransactions.SetRange("Staff ID", Rec."Staff ID")
                else
                    if Rec."POS Terminal No." <> '' then
                        TransactionStatus.SetRange("POS Terminal No.", Rec."POS Terminal No.");
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
                if not PmtTransactionsTEMP.IsEmpty then
                    PmtTransactionsTEMP.FindFirst();
                Page.RunModal(0, PmtTransactionsTEMP, PmtTransactionsTEMP."Amount in Currency");
            end;
        }
        modify("Trans. Amount in LCY")
        {
            trigger OnDrillDown()
            var
                PmtTransactionsTEMP: Record "LSC Trans. Payment Entry" temporary;
                PmtTransactions: Record "LSC Trans. Payment Entry";
                TransactionStatus: Record "LSC Transaction Status";
            begin
                PmtTransactionsTEMP.Reset;
                PmtTransactionsTEMP.DeleteAll;

                PmtTransactions.Reset;
                PmtTransactions.SetRange("Tender Type", Rec."Tender Type");
                PmtTransactions.SetFilter("Currency Code", '%1', Rec."Currency Code");
                if Rec."Tender Type Card No." <> '' then //Condition Added NT09092022
                    PmtTransactions.SetFilter("Card No.", '%1', Rec."Tender Type Card No.");
                TransactionStatus.Reset;
                TransactionStatus.SetCurrentKey("Statement No.");
                TransactionStatus.SetRange("Statement No.", Rec."Statement No.");
                if Rec."Staff ID" <> '' then
                    PmtTransactions.SetRange("Staff ID", Rec."Staff ID")
                else
                    if Rec."POS Terminal No." <> '' then
                        TransactionStatus.SetRange("POS Terminal No.", Rec."POS Terminal No.");
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
                if not PmtTransactionsTEMP.IsEmpty then
                    PmtTransactionsTEMP.FindFirst();
                Page.RunModal(0, PmtTransactionsTEMP, PmtTransactionsTEMP."Amount Tendered");
            end;
        }
        modify("Staff ID")
        {
            Editable = ControlEditable;
        }
        modify("POS Terminal No.")
        {
            Editable = ControlEditable;
        }
        modify("Currency Code")
        {
            Editable = ControlEditable;
        }
        modify("Tender Type Card No.")
        {
            Editable = ControlEditable;
        }
    }
    actions
    {
    }
    local procedure OnFieldValidate()
    var

    begin
        CurrPage.Update();
    end;

    trigger OnAfterGetRecord()
    var
    begin
        ControlEditable := Rec."Trans. Amount" = 0;
    end;

    var
        ControlEditable: Boolean;
}
