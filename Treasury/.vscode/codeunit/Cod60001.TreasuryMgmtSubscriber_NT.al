codeunit 60001 TreasuryMgmtSubscriber_NT
{
    //Moved to Page Extension
    // [EventSubscriber(ObjectType::Table, Database::"LSC Statement", 'OnAfterModifyEvent', '', false, False)]
    // local procedure LSCStatement_OnAfterModify(var xRec: Record "LSC Statement"; var Rec: Record "LSC Statement")
    // var
    //     TreasuryMgmt: Codeunit "Treasury Management_NT";
    // begin
    //     if not Rec.IsTemporary then
    //         if not xRec.Recalculate then
    //             if Rec.Recalculate then
    //                 TreasuryMgmt.UpdateTreasuryStmtRecalculate(Rec);
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"LSC Statement Line", 'OnAfterModifyEvent', '', false, False)]
    // local procedure LSCStatementLine_OnAfterModify(var Rec: Record "LSC Statement Line"; var xRec: Record "LSC Statement Line")
    // var
    //     TreasuryMgmt: Codeunit "Treasury Management_NT";
    // begin
    //     TreasuryMgmt.UpdTreasuryStmtRecalculateOnStmtLineChange(Rec);
    // end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Statement Line", 'OnAfterInsertEvent', '', false, False)]
    local procedure LSCStatementLine_OnAfterInsert(var Rec: Record "LSC Statement Line")
    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
    begin
        if not Rec.IsTemporary then
            TreasuryMgmt.UpdTreasuryStmtRecalculateOnStmtLineChange(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Statement Line", 'OnAfterDeleteEvent', '', false, False)]
    local procedure LSCStatementLine_OnAfterDelete(var Rec: Record "LSC Statement Line")
    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
    begin
        if not Rec.IsTemporary then begin
            TreasuryMgmt.UpdTreasuryStmtRecalculateOnStmtLineChange(Rec);
            TreasuryMgmt.DeleteZReportLines(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'OnBeforeGenJnlLineRunWithCheckInStatementPost', '', false, false)]
    local procedure OnBeforeGenJnlLineRunWithCheckInStatementPost(var GenJnlLine: Record "Gen. Journal Line"; var Transaction: Record "LSC Transaction Header")
    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
    begin
        TreasuryMgmt.AttachStoreDimension(GenJnlLine, Transaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'OnBeforePostCustomerStatementLine', '', false, false)]
    local procedure OnBeforePostCustomerStatementLine(Statement: Record "LSC Statement"; var StatementLine: Record "LSC Statement Line"; var GenJnlLine: Record "Gen. Journal Line"; var TotalSum: Decimal);
    var
        AlphaMegaSetup: Record "AlphaMega Setup_NT";
        TreasStmt: Record "Treasury Statement_NT";
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        NewDimSetID: Integer;
    begin
        if StatementLine."Treasury Statement No." <> '' then
            if TreasStmt.Get(StatementLine."Treasury Statement No.") then
                if AlphaMegaSetup.Get() then
                    if AlphaMegaSetup."Store Hierarchy Dimension" <> '' then begin
                        TreasuryMgmt.AddDimensionToDimensionSet(GenJnlLine."Dimension Set ID", NewDimSetID, AlphaMegaSetup."Store Hierarchy Dimension", TreasStmt."Store Hierarchy No.", GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");
                        if GenJnlLine."Dimension Set ID" <> NewDimSetID then
                            GenJnlLine."Dimension Set ID" := NewDimSetID;
                    end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'OnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnBeforeGenJnlPostLine(var GenJournalLine: Record "Gen. Journal Line"; var Statement: Record "LSC Statement"; var TransactionHeader: Record "LSC Transaction Header");
    var
        AlphaMegaSetup: Record "AlphaMega Setup_NT";
        TreasStmt: Record "Treasury Statement_NT";
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        NewDimSetID: Integer;
        StatementLine: Record "LSC Statement Line";
    begin
        // StatementLine.SetRange("Statement No.", Statement."No.");
        // StatementLine.SetFilter("Treasury Statement No.", '<>%1', '');
        // if StatementLine.FindFirst() then
        //     if StatementLine."Treasury Statement No." <> '' then
        //         if TreasStmt.Get(StatementLine."Treasury Statement No.") then
        //             if AlphaMegaSetup.Get() then
        //                 if AlphaMegaSetup."Store Hierarchy Dimension" <> '' then begin
        //                     TreasuryMgmt.AddDimensionToDimensionSet(GenJournalLine."Dimension Set ID", NewDimSetID, AlphaMegaSetup."Store Hierarchy Dimension", TreasStmt."Store Hierarchy No.", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
        //                     if GenJournalLine."Dimension Set ID" <> NewDimSetID then
        //                         GenJournalLine."Dimension Set ID" := NewDimSetID;
        //                 end;

        TreasuryMgmt.AttachStoreDimension(GenJournalLine, TransactionHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'OnBeforeItemJnlLinePostLine', '', false, false)]

    local procedure OnBeforeItemJnlLinePostLine(Statement: Record "LSC Statement"; var ItemJournalLine: Record "Item Journal Line"; var ItemPostingBuffer: Record "LSC Item Posting Buffer")
    var
        AlphaMegaSetup: Record "AlphaMega Setup_NT";
        TreasStmt: Record "Treasury Statement_NT";
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        NewDimSetID: Integer;
        StatementLine: Record "LSC Statement Line";
        CodeDictionary_l: Dictionary of [Integer, Code[20]];
    begin
        TreasuryMgmt.AttachStoreDimension2(ItemJournalLine, Statement);
        StatementLine.SetRange("Statement No.", Statement."No.");
        StatementLine.SetFilter("Treasury Statement No.", '<>%1', '');
        if StatementLine.FindFirst() then
            if StatementLine."Treasury Statement No." <> '' then
                if TreasStmt.Get(StatementLine."Treasury Statement No.") then
                    if AlphaMegaSetup.Get() then
                        if AlphaMegaSetup."Store Hierarchy Dimension" <> '' then begin
                            TreasuryMgmt.AddDimensionToDimensionSet(ItemJournalLine."Dimension Set ID", NewDimSetID, AlphaMegaSetup."Store Hierarchy Dimension", TreasStmt."Store Hierarchy No.", ItemJournalLine."Shortcut Dimension 1 Code", ItemJournalLine."Shortcut Dimension 2 Code");
                            if ItemJournalLine."Dimension Set ID" <> NewDimSetID then
                                ItemJournalLine."Dimension Set ID" := NewDimSetID;
                        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforePostLineByEntryType', '', false, false)]
    local procedure OnBeforePostLineByEntryType(var ItemJournalLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean; CalledFromInvtPutawayPick: Boolean)
    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
    begin
        //TreasuryMgmt.AttachStoreDimension2(ItemJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Calculate", 'OnAfterRunCodeunit', '', false, false)]
    local procedure OnAfterRunCodeunit(var Statement: Record "LSC Statement")
    var
        TreasMgmt: Codeunit "Treasury Management_NT";
    begin
        TreasMgmt.InsertStmtZReportLines(Statement);
        TreasMgmt.MergeTenderAfterStatementCalculate(Statement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'OnAfterStatementPost', '', false, false)]
    local procedure OnAfterStatementPost(var Statement: Record "LSC Statement");
    var
        TreasMgmt: Codeunit "Treasury Management_NT";
    begin
        TreasMgmt.TransferZLinesToPosted(Statement."No.");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure OnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        TreasJnlLine: Record "Treasury Journal Line_NT";
        PostedTreasJnlLine: Record "Posted Treasury Jnl. Line_NT";
    begin
        case DocumentAttachment."Table ID" of
            DATABASE::"Treasury Journal Line_NT":
                begin
                    RecRef.Open(DATABASE::"Treasury Journal Line_NT");
                    if TreasJnlLine.Get(DocumentAttachment."Document Type"::Treasury, DocumentAttachment."No.", DocumentAttachment."Line No.") then
                        RecRef.GetTable(TreasJnlLine);
                end;
            DATABASE::"Posted Treasury Jnl. Line_NT":
                begin
                    RecRef.Open(DATABASE::"Posted Treasury Jnl. Line_NT");
                    // if PostedTreasJnlLine.Get(DocumentAttachment."Line No.") then
                    //     RecRef.GetTable(PostedTreasJnlLine);
                    PostedTreasJnlLine.SetFilter("Journal Template Name", FORMAT(DocumentAttachment."Document Type"));
                    PostedTreasJnlLine.SetFilter("Journal Batch Name", DocumentAttachment."No.");
                    PostedTreasJnlLine.SetFilter("Line No.", '%1', DocumentAttachment."Line No.");
                    if PostedTreasJnlLine.FindFirst() then
                        RecRef.GetTable(PostedTreasJnlLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        case RecRef.Number of
            DATABASE::"Treasury Journal Line_NT", DATABASE::"Posted Treasury Jnl. Line_NT":
                begin
                    //1. Template Name
                    FieldRef := RecRef.Field(1);
                    DocumentAttachment."Document Type" := DocumentAttachment."Document Type"::Treasury;
                    //5. Batch Name
                    FieldRef := RecRef.Field(5);
                    DocumentAttachment."No." := FieldRef.Value;
                    //20. Line No
                    FieldRef := RecRef.Field(20);
                    DocumentAttachment."Line No." := FieldRef.Value;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var FlowFieldsEditable: Boolean)
    var
        FieldRef: FieldRef;
    begin
        case RecRef.Number of
            DATABASE::"Treasury Journal Line_NT", DATABASE::"Posted Treasury Jnl. Line_NT":
                begin
                    //1. Template Name
                    FieldRef := RecRef.Field(1);
                    DocumentAttachment.SetRange("Document Type", DocumentAttachment."Document Type"::Treasury);
                    //5. Batch Name
                    FieldRef := RecRef.Field(5);
                    DocumentAttachment.SetRange("No.", FieldRef.Value);
                    //20. Line No
                    FieldRef := RecRef.Field(20);
                    DocumentAttachment.SetRange("Line No.", FieldRef.Value);

                end;
        end;
    end;
    //TO BE REMOVED

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Statement-Calculate_NT", 'OnAfterRunCodeunit', '', false, false)]
    local procedure OnAfterRunCodeunit_NT(var Statement: Record "LSC Statement")
    var
        TreasMgmt: Codeunit "Treasury Management_NT";
    begin
        TreasMgmt.InsertStmtZReportLines(Statement);
        TreasMgmt.MergeTenderAfterStatementCalculate(Statement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Statement Line", 'OnAfterValidateEvent', 'Counted Amount', false, False)]
    local procedure OnAfterValidateCountedAmount(var Rec: Record "LSC Statement Line"; var xRec: Record "LSC Statement Line")
    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
    begin
        TreasuryMgmt.UpdateZlineSTMTCountedAmount(Rec, xRec)
    end;



}
