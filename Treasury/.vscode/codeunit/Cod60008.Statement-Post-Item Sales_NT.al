codeunit 60008 "Statement-Post-Item Sales_NT"
{
    TableNo = "LSC Statement";
    trigger OnRun()
    var
    begin
        PostItemSales(Rec);
    end;

    local procedure PostItemSales(StatementToPost: Record "LSC Statement")
    begin
        Clear(BatchPostingQueue);
        Clear(BatchPostingStatus);

        GetStatementBatchPostingStatus(StatementToPost);

        if BatchPostingStatus <> '' then
            Error(Text001);

        if not StatementPost.SafeManagementCheck(StatementToPost) then
            exit;
        Clear(StatementPost);

        StatementToPost.CalcFields("Serial/Lot No. Not Valid");
        if StatementToPost."Serial/Lot No. Not Valid" > 0 then
            if StatementPost.CheckSerialNo(StatementToPost."Store No.", StatementToPost."No.", ExplanationMsg) then
                if GuiAllowed then
                    Message(ExplanationMsg);
        if StatementToPost."Serial/Lot No. Not Valid" > 0 then
            Error(Text002, StatementToPost."Serial/Lot No. Not Valid");

        //if Confirm(Txt_ConfirmItemOnlyPosting, true) then begin
        Store.Get(StatementToPost."Store No.");
        if not Store."Use Batch Posting for Statem." then
            StatementPost.RunItemPosting(StatementToPost, false)
        else
            BatchPosting.ValidateAndPostStatement(StatementToPost, true);
        //end;
        Clear(StatementPost);
        Clear(BatchPosting);
    end;

    local procedure GetStatementBatchPostingStatus(Statement: Record "LSC Statement")
    begin
        BatchPostingQueue.Status := BatchPosting.GetStatementStatus(Statement);
        if (BatchPostingQueue.Status < 0) or
           (BatchPostingQueue.Status = BatchPostingQueue.Status::Finished)
        then
            BatchPostingStatus := ''
        else
            BatchPostingStatus := Format(BatchPostingQueue.Status);
    end;


    var

        BatchPostingQueue: Record "LSC Batch Posting Queue";
        Store: Record "LSC Store";
        StatementPost: Codeunit "LSC Statement-Post";
        BatchPostingStatus: Text[30];
        ExplanationMsg: Text;
        BatchPosting: Codeunit "LSC Batch Posting";
        CalculationDate: Date;
        Text001: Label 'Statement has already been posted to the Batch Posting Queue.';
        Text002: Label 'There are %1 unresolved serial numbers attached to this statement. They must be resolved before the statement can be posted.';
    //Txt_ConfirmItemOnlyPosting: Label 'Do you want to post only item sales part of this Statement?\\This will only update the Inventory and not the General Ledger.';
}

