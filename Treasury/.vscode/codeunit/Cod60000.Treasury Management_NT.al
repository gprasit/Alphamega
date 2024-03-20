codeunit 60000 "Treasury Management_NT"
{
    Permissions = tabledata "Bank Account Ledger Entry" = rm, tabledata "LSC Statement Line" = rim,
    tabledata "Treasury Journal Batch_NT" = rim;
    trigger OnRun()
    begin

    end;

    procedure CalculateTreasuryStatement(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        TempFilteredStores: Record "LSC Store" temporary;
        TempStatement: Record "LSC Statement" temporary;
        TempSummedStmtLine: Record "LSC Statement Line" temporary;
        TempSummedTrsryStmtNetSalesLine: Record "Treasury Stmt. NetSalesLine_NT" temporary;
    begin
        TreasuryStmt.TestField("Store Hierarchy No.");
        TreasuryStmt.TestField("Trans. Starting Date");
        TreasuryStmt.TestField("Trans. Ending Date");
        AddStoresFromHierarchy(TreasuryStmt."Store Hierarchy No.", TempFilteredStores);
        FilterStatements(TreasuryStmt, TempStatement, TempFilteredStores);
        AddStatementLinesToNetSalesTempRec(TreasuryStmt."Treasury Statement No.", TempStatement, TempSummedTrsryStmtNetSalesLine);
        InsertTreasuryStmtNetSalesLines(TreasuryStmt, TempSummedTrsryStmtNetSalesLine);
        AddStatementLinesToTempRec(TreasuryStmt."Treasury Statement No.", TempStatement, TempSummedStmtLine);
        InsertTreasuryStmtLines(TreasuryStmt, TempSummedStmtLine);
        InsertTreasuryAllocationLines(TreasuryStmt, TempSummedStmtLine, TempFilteredStores);
        CalculateTreasuryStmtOpening(TreasuryStmt);
    end;

    procedure AddStoresFromHierarchy(StoreHierarchyCode: Code[10]; var TempStoresToFilter: Record "LSC Store" temporary)
    var
        HierarchyDefs: Record "LSC Retail Hierar. Defaults";
    begin
        TempStoresToFilter.Reset();
        TempStoresToFilter.DeleteAll();
        HierarchyDefs.SetRange("Table ID", Database::"LSC Store");
        HierarchyDefs.SetRange("Hierarchy Code", StoreHierarchyCode);
        if HierarchyDefs.FindSet() then
            repeat
                if not TempStoresToFilter.Get(HierarchyDefs."No.") then begin
                    TempStoresToFilter.Init();
                    TempStoresToFilter."No." := HierarchyDefs."No.";
                    TempStoresToFilter.Insert();
                end;
            until HierarchyDefs.Next() = 0;
    end;

    local procedure FilterStatements(var TreasuryStmt: Record "Treasury Statement_NT"; var TempStatement: Record "LSC Statement" temporary; var TempFilteredStores: Record "LSC Store" temporary)
    var
        Statement: Record "LSC Statement";
    begin
        TempStatement.Reset();
        TempStatement.DeleteAll();
        if TempFilteredStores.FindSet() then
            repeat
                Statement.SetRange("Store No.");
                Statement.SetRange("Trans. Starting Date");
                Statement.SetRange("Trans. Ending Date");
                Statement.SetRange("Store No.", TempFilteredStores."No.");
                Statement.SetFilter("Trans. Starting Date", '>=%1', TreasuryStmt."Trans. Starting Date");
                Statement.SetFilter("Trans. Ending Date", '<=%1', TreasuryStmt."Trans. Ending Date");
                if Statement.FindSet() then begin
                    repeat
                        TempStatement.Init();
                        TempStatement.TransferFields(Statement);
                        TempStatement.Insert();
                    until Statement.Next() = 0;
                end;
            until TempFilteredStores.Next() = 0;
    end;

    local procedure AddStatementLinesToTempRec(TreasuryStmtNo: Code[20]; Var TempFilteredStatments: Record "LSC Statement" temporary; var TempSummedStmtLine: Record "LSC Statement Line" temporary)
    var
        StatmentLine: Record "LSC Statement Line";
        LineNo: Integer;
    begin
        LineNo := 10000;
        if TempFilteredStatments.FindSet() then
            repeat
                StatmentLine.SetRange("Statement No.", TempFilteredStatments."No.");
                if StatmentLine.FindSet() then
                    repeat
                        if StatmentLine."Treasury Statement No." = '' then begin
                            TempSummedStmtLine.Reset();
                            TempSummedStmtLine.SetRange("Tender Type", StatmentLine."Tender Type");
                            if not TempSummedStmtLine.FindFirst() then begin
                                TempSummedStmtLine.Reset();
                                TempSummedStmtLine.Init();
                                TempSummedStmtLine.TransferFields(StatmentLine);
                                TempSummedStmtLine."Line No." := LineNo;
                                LineNo += 10;
                                TempSummedStmtLine.Insert();
                                StatmentLine.Validate("Treasury Statement No.", TreasuryStmtNo);
                                StatmentLine.Modify();
                            end else begin
                                TempSummedStmtLine."Counted Amount" += StatmentLine."Counted Amount";
                                TempSummedStmtLine."Trans. Amount" += StatmentLine."Trans. Amount";
                                TempSummedStmtLine."Difference Amount" += StatmentLine."Difference Amount";
                                TempSummedStmtLine."Counted Amount in LCY" += StatmentLine."Counted Amount in LCY";
                                TempSummedStmtLine."Trans. Amount in LCY" += StatmentLine."Trans. Amount in LCY";
                                TempSummedStmtLine."Difference in LCY" += StatmentLine."Difference in LCY";
                                TempSummedStmtLine.Modify();
                                StatmentLine.Validate("Treasury Statement No.", TreasuryStmtNo);
                                StatmentLine.Modify();
                            end;
                        end;
                    until StatmentLine.Next() = 0;
            until TempFilteredStatments.Next() = 0;
    end;

    local procedure InsertTreasuryStmtLines(var TreasuryStmt: Record "Treasury Statement_NT"; var TempSummedStmtLine: Record "LSC Statement Line" temporary)
    var
        TreasurySTMTLines: Record "Treasury Statement Line_NT";
        LineNo: Integer;
    begin
        TreasurySTMTLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if TreasurySTMTLines.FindLast() then
            LineNo := TreasurySTMTLines."Line No." + 10
        else
            LineNo := 10000;
        TempSummedStmtLine.Reset();
        if TempSummedStmtLine.FindSet() then
            repeat
                TreasurySTMTLines.Reset();
                TreasurySTMTLines.SetFilter("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
                TreasurySTMTLines.SetFilter("Tender Type", TempSummedStmtLine."Tender Type");
                if not TreasurySTMTLines.FindFirst() then begin
                    TreasurySTMTLines.Reset();
                    TreasurySTMTLines.Init();
                    TreasurySTMTLines.Validate("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
                    TreasurySTMTLines.Validate("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
                    TreasurySTMTLines.Validate("Tender Type", TempSummedStmtLine."Tender Type");
                    TreasurySTMTLines."Counted Amount" := TempSummedStmtLine."Counted Amount";
                    TreasurySTMTLines."Counted Amount in LCY" := TempSummedStmtLine."Counted Amount in LCY";
                    TreasurySTMTLines."Trans. Amount" := TempSummedStmtLine."Trans. Amount";
                    TreasurySTMTLines."Trans. Amount in LCY" := TempSummedStmtLine."Trans. Amount in LCY";
                    TreasurySTMTLines."Difference Amount" := TempSummedStmtLine."Difference Amount";
                    TreasurySTMTLines."Difference in LCY" := TempSummedStmtLine."Difference in LCY";
                    TreasurySTMTLines."Line No." := LineNo;
                    LineNo += 10;
                    TreasurySTMTLines.Insert(true);
                end else begin
                    TreasurySTMTLines."Counted Amount" += TempSummedStmtLine."Counted Amount";
                    TreasurySTMTLines."Counted Amount in LCY" += TempSummedStmtLine."Counted Amount in LCY";
                    TreasurySTMTLines."Trans. Amount" := TempSummedStmtLine."Trans. Amount";
                    TreasurySTMTLines."Trans. Amount in LCY" += TempSummedStmtLine."Trans. Amount in LCY";
                    TreasurySTMTLines."Difference Amount" += TempSummedStmtLine."Difference Amount";
                    TreasurySTMTLines."Difference in LCY" += TempSummedStmtLine."Difference in LCY";
                    TreasurySTMTLines.Modify();
                end;
            until TempSummedStmtLine.Next() = 0;
    end;

    procedure SetStatmentLinesFree(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        StatementLine: Record "LSC Statement Line";
        TreasAllocationLines: Record "Treasury Allocation Line_NT";
        TreasuryJnlLine2: Record "Treasury Journal Line_NT";
        TreasuryJnlLine: Record "Treasury Journal Line_NT";
        TreasuryStmtLine: Record "Treasury Statement Line_NT";
        TrsryStmtNetSalesLines: Record "Treasury Stmt. NetSalesLine_NT";
    begin
        TreasuryStmt.TestField(Status, TreasuryStmt.Status::" ");
        StatementLine.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        StatementLine.ModifyAll("Treasury Statement No.", '', false);

        TreasuryJnlLine.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if TreasuryJnlLine.FindSet() then
            repeat
                TreasuryJnlLine2.Get(TreasuryJnlLine."Journal Template Name", TreasuryJnlLine."Journal Batch Name", TreasuryJnlLine."Line No.");
                TreasuryJnlLine2."Treasury Statement No." := '';
                TreasuryJnlLine2."Treasury Stmt. Line No." := 0;
                TreasuryJnlLine2.Modify();
            until TreasuryJnlLine.Next() = 0;

        TrsryStmtNetSalesLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TrsryStmtNetSalesLines.DeleteAll();

        TreasuryStmtLine.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasuryStmtLine.DeleteAll(true);

        TreasAllocationLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasAllocationLines.DeleteAll(true);

        TreasuryStmt.Recalculate := false;
        TreasuryStmt.Modify();
    end;

    procedure UpdateTreasuryStmtRecalculate(var Statment: Record "LSC Statement")
    var
        TempTreasuryStmt: Record "Treasury Statement_NT" temporary;
    begin
        AddTreasuryStmtToTempRec(Statment, TempTreasuryStmt);
        MarkTreasuryStmtRecalculate(TempTreasuryStmt);
    end;

    local procedure AddTreasuryStmtToTempRec(var Statment: Record "LSC Statement"; var TempTreasuryStmt: Record "Treasury Statement_NT" temporary)
    var
        StatementLine: Record "LSC Statement Line";
    begin
        StatementLine.SetRange("Statement No.", Statment."No.");
        StatementLine.SetFilter("Treasury Statement No.", '<>%1', '');
        if StatementLine.FindSet() then
            repeat
                if not TempTreasuryStmt.Get(StatementLine."Treasury Statement No.") then begin
                    TempTreasuryStmt.Init();
                    TempTreasuryStmt."Treasury Statement No." := StatementLine."Treasury Statement No.";
                    TempTreasuryStmt.Recalculate := true;
                    TempTreasuryStmt.Insert();
                end;
            until StatementLine.Next() = 0;
    end;

    local procedure MarkTreasuryStmtRecalculate(var TempTreasuryStmt: Record "Treasury Statement_NT" temporary)
    var
        TreasuryStmt: Record "Treasury Statement_NT";
    begin
        if TempTreasuryStmt.FindSet() then
            repeat
                TreasuryStmt.Get(TempTreasuryStmt."Treasury Statement No.");
                //if TreasuryStmtLinesFound(TreasuryStmt) then
                //if TreasuryStmt.Status <> TreasuryStmt.Status::Posted then begin
                TreasuryStmt.Recalculate := TempTreasuryStmt.Recalculate;
                TreasuryStmt.Modify();
            //end;
            until TempTreasuryStmt.Next() = 0;
    end;

    local procedure TreasuryStmtLinesFound(TreasuryStmt: Record "Treasury Statement_NT"): Boolean
    var
        TreasuryStmtLines: Record "Treasury Statement Line_NT";
    begin
        TreasuryStmtLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasuryStmtLines.SetFilter("Tender Type", '<>%1', '');
        exit(not TreasuryStmtLines.IsEmpty);
    end;

    procedure TreasStmtRecalculateOnStatementChange(Statement: Record "LSC Statement")
    var
        PostedStatment: Record "LSC Posted Statement";
        TempTreasuryStmt: Record "Treasury Statement_NT" temporary;
    begin
        if PostedStatment.Get(Statement."No.") then
            exit;
        if PostedStatment.Get(Statement."Posting No.") then
            exit;
        AddTreasuryStmtToTempRec(Statement, TempTreasuryStmt);
        MarkTreasuryStmtRecalculate(TempTreasuryStmt);
    end;

    procedure UpdTreasuryStmtRecalculateOnStmtLineChange(StatmentLine: Record "LSC Statement Line")
    var
        PostedStatement: Record "LSC Posted Statement";
        Statement: Record "LSC Statement";
        TempTreasuryStmt: Record "Treasury Statement_NT" temporary;
    begin
        Statement.Get(StatmentLine."Store No.", StatmentLine."Statement No.");
        if PostedStatement.Get(Statement."No.") then
            exit;
        if PostedStatement.Get(Statement."Posting No.") then
            exit;
        AddTreasuryStmtToTempRec(Statement, TempTreasuryStmt);
        MarkTreasuryStmtRecalculate(TempTreasuryStmt);
    end;

    procedure PostTreasuryStatment(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        Statement: Record "LSC Statement";
        PostedCount: Integer;
    begin
        TreasuryStmt.TestField(Status, TreasuryStmt.Status::" ");
        if TreasuryStmt.Recalculate then
            Error(Text005, TreasuryStmt."Treasury Statement No.");
        if not Confirm(Text000, true) then
            exit;
        TreasuryStmt.TestField("Store Hierarchy No.");
        TreasuryStmt.TestField("Trans. Starting Date");
        TreasuryStmt.TestField("Trans. Ending Date");
        TreasuryStmt.TestField("Posting Date");
        CheckCountedAmt(TreasuryStmt);
        if not LinesExist(TreasuryStmt) then
            Error(NothingToPostErr);
        FilterStmtsForTreasuryStmt(TreasuryStmt, Statement);
        PostStatements(Statement, PostedCount);
        PostTreasuryJournal(TreasuryStmt);
        PostTreasuryAllocation(TreasuryStmt);
        ChangeTreasuryStmtStatus(TreasuryStmt, PostedCount);
        MoveTreasuryStmtToPosted(TreasuryStmt);
    end;

    local procedure FilterStmtsForTreasuryStmt(TreasuryStmt: Record "Treasury Statement_NT"; var Statement: Record "LSC Statement")
    var
        StatementLines: Record "LSC Statement Line";
    begin
        Statement.Reset();
        StatementLines.SetFilter("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if StatementLines.FindSet() then
            repeat
                Statement.SetFilter("No.", StatementLines."Statement No.");
                if Statement.FindFirst() then
                    if not Statement.Mark() then
                        Statement.Mark(true);
            until StatementLines.Next() = 0;
        Statement.SetRange("No.");
        Statement.MarkedOnly(true);
    end;

    local procedure PostStatements(Var Statement: Record "LSC Statement"; Var PostedCount: Integer)
    var
        StatementToPost: Record "LSC Statement";
        StatementNo: Code[20];
    begin
        if Statement.FindSet() then
            repeat
                Clear(BatchPostingStatus);
                clear(BatchPostingQueue);
                Clear(Store);
                if Statement.Recalculate then
                    Error(Text001, Statement."No.");
                if not StatementPost.SafeManagementCheck(Statement) then
                    Error(Text002, Statement."No.");
                Clear(StatementPost);

                Statement.CalcFields("Serial/Lot No. Not Valid");
                if Statement."Serial/Lot No. Not Valid" > 0 then
                    if StatementPost.CheckSerialNo(Statement."Store No.", Statement."No.", ExplanationMsg) then
                        Message(ExplanationMsg);
                if Statement."Serial/Lot No. Not Valid" > 0 then
                    Error(Text003, Statement."Serial/Lot No. Not Valid");
                GetStatementBatchPostingStatus(Statement);
                if BatchPostingStatus <> '' then
                    Error(Text004, Statement."No.");

                Store.Get(Statement."Store No.");
                if not Store."Use Batch Posting for Statem." then
                    StatementPost.Run(Statement)
                else
                    BatchPosting.ValidateAndPostStatement(Statement, false);

                PostedCount += 1;
                Clear(StatementPost);
                Clear(BatchPosting);
            until Statement.Next() = 0;
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

    local procedure ChangeTreasuryStmtStatus(Var TreasuryStmt: Record "Treasury Statement_NT"; var PostedCount: Integer)
    var
    begin
        if PostedCount > 0 then begin
            TreasuryStmt.Status := TreasuryStmt.Status::Posted;
            TreasuryStmt.Modify();
            Message(Text006, TreasuryStmt."Treasury Statement No.");
        end;
    end;

    procedure ShowStatements(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        Statement: Record "LSC Statement";
    begin
        TreasuryStmt.Recalculate := false;
        TreasuryStmt.Modify();
        FilterStmtsForTreasuryStmt(TreasuryStmt, Statement);
        Commit();
        If not Statement.IsEmpty then
            Statement.FindFirst();
        Page.RunModal(0, Statement);
    end;

    procedure AttachStoreDimension(var GenJnlLine: Record "Gen. Journal Line"; var Transaction: Record "LSC Transaction Header")
    var
        DimMgt: Codeunit DimensionManagement;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        CombinedDimID: Integer;
        DefStoreDimID: Integer;
        DimensionSetIDArr: array[10] of Integer;
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::"LSC Store", Transaction."Store No.", false);
        DefStoreDimID := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code", 0, 0);
        DimensionSetIDArr[1] := GenJnlLine."Dimension Set ID";
        DimensionSetIDArr[2] := DefStoreDimID;
        CombinedDimID := DimMgt.GetCombinedDimensionSetID(DimensionSetIDArr, GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");
        if CombinedDimID <> 0 then
            if GenJnlLine."Dimension Set ID" <> CombinedDimID then
                GenJnlLine."Dimension Set ID" := CombinedDimID;
    end;

    procedure AttachStoreDimension2(var ItemJournalLine: Record "Item Journal Line"; Statement: Record "LSC Statement")
    var
        DimMgt: Codeunit DimensionManagement;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        CombinedDimID: Integer;
        DefStoreDimID: Integer;
        DimensionSetIDArr: array[10] of Integer;
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::"LSC Store", Statement."Store No.", false);
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, ItemJournalLine."Location Code", false);
        DefStoreDimID := DimMgt.GetDefaultDimID(DefaultDimSource, '', ItemJournalLine."Shortcut Dimension 1 Code", ItemJournalLine."Shortcut Dimension 2 Code", 0, 0);
        DimensionSetIDArr[1] := ItemJournalLine."Dimension Set ID";
        DimensionSetIDArr[2] := DefStoreDimID;
        CombinedDimID := DimMgt.GetCombinedDimensionSetID(DimensionSetIDArr, ItemJournalLine."Shortcut Dimension 1 Code", ItemJournalLine."Shortcut Dimension 2 Code");
        if CombinedDimID <> 0 then
            if ItemJournalLine."Dimension Set ID" <> CombinedDimID then
                ItemJournalLine."Dimension Set ID" := CombinedDimID;
    end;

    procedure AddDimensionToDimensionSet(OldDimSetID: Integer; var NewDimSetID: Integer; DimCode: Code[20]; DimValCode: Code[20]; Var ShortCutDim1: Code[20]; Var ShortCutDim2: Code[20])
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        CombinedDimID: Integer;
        DimensionSetIDArr: array[10] of Integer;
    begin
        if (DimCode = '') or (DimValCode = '') then
            exit;
        DimMgt.GetDimensionSet(TempDimSetEntry, OldDimSetID);

        TempDimSetEntry.Reset();

        TempDimSetEntry.SetFilter("Dimension Code", DimCode);
        TempDimSetEntry.DeleteAll();

        TempDimSetEntry.Reset();
        TempDimSetEntry.Init();
        TempDimSetEntry.Validate("Dimension Code", DimCode);
        TempDimSetEntry.Validate("Dimension Value Code", DimValCode);
        TempDimSetEntry.Insert(true);
        NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
        DimensionSetIDArr[1] := OldDimSetID;
        DimensionSetIDArr[2] := NewDimSetID;
        CombinedDimID := DimMgt.GetCombinedDimensionSetID(DimensionSetIDArr, ShortCutDim1, ShortCutDim2);
        NewDimSetID := CombinedDimID;
    end;

    procedure ShowPostedStatements(var PostedTreasuryStmt: Record "Posted Treasury Statement_NT")
    var
        PostedStatement: Record "LSC Posted Statement";
    begin
        FilterPostedStatements(PostedTreasuryStmt, PostedStatement);
        Commit();
        If not PostedStatement.IsEmpty then
            PostedStatement.FindFirst();
        Page.RunModal(0, PostedStatement);
    end;

    local procedure FilterPostedStatements(PostedTreasuryStmt: Record "Posted Treasury Statement_NT"; var PostedStatement: Record "LSC Posted Statement")
    var
        PostedStmtLines: Record "LSC Posted Statement Line";
    begin
        PostedStatement.Reset();
        PostedStmtLines.SetFilter("Treasury Statement No.", PostedTreasuryStmt."Treasury Statement No.");
        if PostedStmtLines.FindSet() then
            repeat
                PostedStatement.SetFilter("No.", PostedStmtLines."Statement No.");
                if PostedStatement.FindFirst() then
                    if not PostedStatement.Mark() then
                        PostedStatement.Mark(true);
            until PostedStmtLines.Next() = 0;
        PostedStatement.SetRange("No.");
        PostedStatement.MarkedOnly(true);
    end;

    procedure MoveTreasuryStmtToPosted(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        PostedTreasCashDecl: Record "Posted Treasury Cash Decl._NT";
        PostedTreasJnl: Record "Posted Treasury Jnl. Line_NT";
        PstdTreasNetSalesLine: Record "Posted Treas. NetSalesLine_NT";
        PstdTreasuryAllocLines: Record "Posted Treasury Alloc. Line_NT";
        PstdTreasuryStmt: Record "Posted Treasury Statement_NT";
        PstdTreasuryStmtLines: Record "Posted Treasury Stmt. Line_NT";
        TreasCashDecl: Record "Treasury Cash Declaration_NT";
        TreasJnl: Record "Treasury Journal Line_NT";
        TreasNetSalesLine: Record "Treasury Stmt. NetSalesLine_NT";
        TreasuryAllocLines: Record "Treasury Allocation Line_NT";
        TreasuryStmt2: Record "Treasury Statement_NT";
        TreasuryStmtLines: Record "Treasury Statement Line_NT";
        RecordLinkManagement: Codeunit "Record Link Management";
        TreasAttachmentMgmt: Codeunit TreasuryAttchmentMgmt_NT;
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
        LineNo: Integer;
    begin
        TreasuryAllocLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if TreasuryAllocLines.FindSet() then
            repeat
                PstdTreasuryAllocLines.Init();
                PstdTreasuryAllocLines.TransferFields(TreasuryAllocLines);
                PstdTreasuryAllocLines.Insert();

                TreasCashDecl.Reset();
                TreasCashDecl.SetFilter("Treasury Statement No.", TreasuryAllocLines."Treasury Statement No.");
                TreasCashDecl.SetFilter("Treasury Allocation Line No.", '%1', TreasuryAllocLines."Line No.");
                TreasCashDecl.SetFilter("Tender Type", TreasuryAllocLines."Tender Type");
                if TreasCashDecl.FindSet() then
                    repeat
                        PostedTreasCashDecl.Init();
                        PostedTreasCashDecl.TransferFields(TreasCashDecl);
                        PostedTreasCashDecl.Insert();
                    until TreasCashDecl.Next() = 0;
            until TreasuryAllocLines.Next() = 0;

        TreasNetSalesLine.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if TreasNetSalesLine.FindSet then
            repeat
                PstdTreasNetSalesLine.Init;
                PstdTreasNetSalesLine.TransferFields(TreasNetSalesLine);
                PstdTreasNetSalesLine.Insert(true);
            until TreasNetSalesLine.Next = 0;

        TreasuryStmtLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if TreasuryStmtLines.FindSet then
            repeat
                PstdTreasuryStmtLines.Init;
                PstdTreasuryStmtLines.TransferFields(TreasuryStmtLines);
                PstdTreasuryStmtLines.Insert(true);
            until TreasuryStmtLines.Next = 0;

        if PostedTreasJnl.FindLast() then
            LineNo := PostedTreasJnl."Line No." + 10
        else
            LineNo := 10000;

        TreasJnl.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if TreasJnl.FindSet() then
            repeat
                PostedTreasJnl.Init();
                PostedTreasJnl.TransferFields(TreasJnl);
                PostedTreasJnl."Line No." := LineNo;
                LineNo += 10;
                PostedTreasJnl.Insert();
                if TreasJnl.HasLinks then begin
                    RecordLinkManagement.CopyLinks(TreasJnl, PostedTreasJnl);
                    TreasJnl.DeleteLinks();
                end;
                FromRecRef.GetTable(TreasJnl);
                ToRecRef.GetTable(PostedTreasJnl);
                TreasAttachmentMgmt.CopyAttachmentsForPostedJrnls(FromRecRef, ToRecRef);
            until TreasJnl.Next() = 0;

        PstdTreasuryStmt.Init();
        PstdTreasuryStmt.TransferFields(TreasuryStmt);
        PstdTreasuryStmt.Insert(true);

        TreasuryAllocLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasuryAllocLines.DeleteAll(true);

        TreasJnl.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasJnl.DeleteAll();

        TreasNetSalesLine.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasNetSalesLine.DeleteAll();

        TreasuryStmtLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasuryStmtLines.DeleteAll();

        TreasuryStmt2.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasuryStmt2.DeleteAll();
    end;

    local procedure AddStatementLinesToNetSalesTempRec(TreasuryStmtNo: Code[20]; Var TempFilteredStatments: Record "LSC Statement" temporary; var TempSummedTrsryStmtNetSalesLine: Record "Treasury Stmt. NetSalesLine_NT" temporary)
    var
        AlphaMegaSetup: Record "AlphaMega Setup_NT";
        AttrVal: Record "LSC Attribute Value";
        StatmentLine: Record "LSC Statement Line";
        TreasuryStmt: Record "Treasury Statement_NT";
        StmtToUpdstatistics: Record "LSC Statement" temporary;
        LineNo: Integer;
    begin
        LineNo := 10000;
        AlphaMegaSetup.Get();
        AlphaMegaSetup.TestField("Store Type Attribute");
        if TempFilteredStatments.FindSet() then
            repeat
                StatmentLine.SetRange("Statement No.", TempFilteredStatments."No.");
                if StatmentLine.FindSet() then
                    repeat
                        if StatmentLine."Treasury Statement No." = '' then begin
                            AttrVal.SetFilter("Link Type", '%1', AttrVal."Link Type"::Store);
                            AttrVal.SetFilter("Link Field 1", StatmentLine."Store No.");
                            AttrVal.SetFilter("Attribute Code", AlphaMegaSetup."Store Type Attribute");
                            AttrVal.FindFirst();
                            Attrval.TestField("Attribute Value");
                            TempSummedTrsryStmtNetSalesLine.Reset();
                            TempSummedTrsryStmtNetSalesLine.SetFilter("Store Attribute Code", AttrVal."Attribute Code");
                            TempSummedTrsryStmtNetSalesLine.SetFilter("Attribute Value", AttrVal."Attribute Value");

                            if not TempSummedTrsryStmtNetSalesLine.FindFirst() then begin
                                TreasuryStmt.Get(TreasuryStmtNo);
                                TempSummedTrsryStmtNetSalesLine.Reset();
                                TempSummedTrsryStmtNetSalesLine.Init();
                                TempSummedTrsryStmtNetSalesLine."Treasury Statement No." := TreasuryStmtNo;
                                TempSummedTrsryStmtNetSalesLine."Store Hierarchy No." := TreasuryStmt."Store Hierarchy No.";
                                TempSummedTrsryStmtNetSalesLine."Line No." := LineNo;
                                TempSummedTrsryStmtNetSalesLine.validate("Store Attribute Code", AttrVal."Attribute Code");
                                TempSummedTrsryStmtNetSalesLine."Attribute Value" := AttrVal."Attribute Value";
                                TempSummedTrsryStmtNetSalesLine."Counted Amount" := StatmentLine."Counted Amount";
                                TempSummedTrsryStmtNetSalesLine."Counted Amount in LCY" := StatmentLine."Counted Amount in LCY";
                                TempSummedTrsryStmtNetSalesLine.Validate("Currency Code", StatmentLine."Currency Code");
                                TempSummedTrsryStmtNetSalesLine."Trans. Amount" := StatmentLine."Trans. Amount";
                                TempSummedTrsryStmtNetSalesLine."Trans. Amount in LCY" := StatmentLine."Trans. Amount in LCY";
                                TempSummedTrsryStmtNetSalesLine."Difference Amount" := StatmentLine."Difference Amount";
                                TempSummedTrsryStmtNetSalesLine."Difference in LCY" := StatmentLine."Difference in LCY";
                                LineNo += 10;
                                if not StmtToUpdstatistics.Get(TempFilteredStatments."Store No.", TempFilteredStatments."No.") then begin
                                    StmtToUpdstatistics.Init();
                                    StmtToUpdstatistics."No." := TempFilteredStatments."No.";
                                    StmtToUpdstatistics."Store No." := TempFilteredStatments."Store No.";
                                    StmtToUpdstatistics.Insert();
                                    UpdateNetSalesLineStatistics(TempFilteredStatments."No.", TempFilteredStatments."Store No.", TempSummedTrsryStmtNetSalesLine);
                                end;
                                TempSummedTrsryStmtNetSalesLine.Insert();
                            end else begin
                                TempSummedTrsryStmtNetSalesLine."Counted Amount" += StatmentLine."Counted Amount";
                                TempSummedTrsryStmtNetSalesLine."Trans. Amount" += StatmentLine."Trans. Amount";
                                TempSummedTrsryStmtNetSalesLine."Difference Amount" += StatmentLine."Difference Amount";
                                TempSummedTrsryStmtNetSalesLine."Counted Amount in LCY" += StatmentLine."Counted Amount in LCY";
                                TempSummedTrsryStmtNetSalesLine."Trans. Amount in LCY" += StatmentLine."Trans. Amount in LCY";
                                TempSummedTrsryStmtNetSalesLine."Difference in LCY" += StatmentLine."Difference in LCY";
                                if not StmtToUpdstatistics.Get(TempFilteredStatments."Store No.", TempFilteredStatments."No.") then begin
                                    StmtToUpdstatistics.Init();
                                    StmtToUpdstatistics."No." := TempFilteredStatments."No.";
                                    StmtToUpdstatistics."Store No." := TempFilteredStatments."Store No.";
                                    StmtToUpdstatistics.Insert();
                                    UpdateNetSalesLineStatistics(TempFilteredStatments."No.", TempFilteredStatments."Store No.", TempSummedTrsryStmtNetSalesLine);
                                end;
                                TempSummedTrsryStmtNetSalesLine.Modify();
                            end;
                        end;
                    until StatmentLine.Next() = 0;
            until TempFilteredStatments.Next() = 0;
    end;

    local procedure InsertTreasuryStmtNetSalesLines(var TreasuryStmt: Record "Treasury Statement_NT"; var TempSummedNetSalesLine: Record "Treasury Stmt. NetSalesLine_NT" temporary)
    var
        TrsrySTMTNetSalesLines: Record "Treasury Stmt. NetSalesLine_NT";
        LinesFound: Boolean;
        LineNo: Integer;
    begin
        TrsrySTMTNetSalesLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if TrsrySTMTNetSalesLines.FindLast() then begin
            LineNo := TrsrySTMTNetSalesLines."Line No." + 10;
            LinesFound := true;
        end else
            LineNo := 10000;

        TempSummedNetSalesLine.Reset();

        if TempSummedNetSalesLine.FindSet() then
            repeat
                TrsrySTMTNetSalesLines.Reset();
                TrsrySTMTNetSalesLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
                TrsrySTMTNetSalesLines.SetFilter("Store Attribute Code", TempSummedNetSalesLine."Store Attribute Code");
                TrsrySTMTNetSalesLines.SetFilter("Attribute Value", TempSummedNetSalesLine."Attribute Value");

                if not TrsrySTMTNetSalesLines.FindFirst() then begin
                    TrsrySTMTNetSalesLines.Reset();
                    TrsrySTMTNetSalesLines.Init();
                    TrsrySTMTNetSalesLines.Validate("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
                    TrsrySTMTNetSalesLines.TransferFields(TempSummedNetSalesLine);
                    TrsrySTMTNetSalesLines."Line No." := LineNo;
                    TrsrySTMTNetSalesLines."Line Type" := TrsrySTMTNetSalesLines."Line Type"::Standard;
                    TrsrySTMTNetSalesLines.Insert(true);
                    LineNo += 10;
                end else begin
                    TrsrySTMTNetSalesLines."Counted Amount" += TempSummedNetSalesLine."Counted Amount";
                    TrsrySTMTNetSalesLines."Counted Amount in LCY" += TempSummedNetSalesLine."Counted Amount in LCY";
                    TrsrySTMTNetSalesLines."Trans. Amount" += TempSummedNetSalesLine."Trans. Amount";
                    TrsrySTMTNetSalesLines."Trans. Amount in LCY" += TempSummedNetSalesLine."Trans. Amount in LCY";
                    TrsrySTMTNetSalesLines."Difference Amount" += TempSummedNetSalesLine."Difference Amount";
                    TrsrySTMTNetSalesLines."Difference in LCY" += TempSummedNetSalesLine."Difference in LCY";
                    TrsrySTMTNetSalesLines.Modify();
                end;
            until TempSummedNetSalesLine.Next() = 0;
        // if (LineNo > 10000) and (not LinesFound) then begin
        //     TrsrySTMTNetSalesLines.Init();
        //     TrsrySTMTNetSalesLines.Validate("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        //     TrsrySTMTNetSalesLines."Line No." := LineNo;
        //     TrsrySTMTNetSalesLines."Line Type" := TrsrySTMTNetSalesLines."Line Type"::"Cash-Payments";
        //     TrsrySTMTNetSalesLines.Insert(true);
        //     LineNo += 10;

        //     TrsrySTMTNetSalesLines.Init();
        //     TrsrySTMTNetSalesLines.Validate("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        //     TrsrySTMTNetSalesLines."Line No." := LineNo;
        //     TrsrySTMTNetSalesLines."Line Type" := TrsrySTMTNetSalesLines."Line Type"::"Cash-Receipts";
        //     TrsrySTMTNetSalesLines.Insert(true);
        // end;
        CreateTreasuryCashPmtRcptLines(TreasuryStmt, LineNo);
    end;

    procedure ShowTreasuryJournal(Var TreasStmtNetSalesLine: Record "Treasury Stmt. NetSalesLine_NT")
    var
        TreasuryJnlLine2: Record "Treasury Journal Line_NT";
        TreasuryJnlLine: Record "Treasury Journal Line_NT";
        TotAmt: Decimal;
        TotAmtLCY: Decimal;
    begin
        if TreasStmtNetSalesLine."Line Type" IN [TreasStmtNetSalesLine."Line Type"::"Cash-Payments", TreasStmtNetSalesLine."Line Type"::"Cash-Receipts"] then begin
            TreasuryJnlLine.FilterGroup(2);
            TreasuryJnlLine.SetRange("Treasury Statement No.", TreasStmtNetSalesLine."Treasury Statement No.");
            TreasuryJnlLine.SetRange("Treasury Stmt. Line No.", TreasStmtNetSalesLine."Line No.");

            case TreasStmtNetSalesLine."Line Type" of
                TreasStmtNetSalesLine."Line Type"::"Cash-Payments":
                    TreasuryJnlLine.Setrange("Entry Type", TreasuryJnlLine."Entry Type"::"Cash-Payments");
                TreasStmtNetSalesLine."Line Type"::"Cash-Receipts":
                    TreasuryJnlLine.Setrange("Entry Type", TreasuryJnlLine."Entry Type"::"Cash-Receipts");
            end;
            TreasuryJnlLine.FilterGroup(0);
            // if Page.RunModal(page::"Treasury Journal_NT", TreaStmtCashJnlLine) = Action::LookupOK then begin
            //     TreaStmtCashJnlLine2.SetRange("Treasury Statement No.", TreaStmtCashJnlLine."Treasury Statement No.");
            //     TreaStmtCashJnlLine2.SetRange("Treasury Stmt. Line No.", TreaStmtCashJnlLine."Treasury Stmt. Line No.");
            //     TreaStmtCashJnlLine2.Setrange("Entry Type", TreaStmtCashJnlLine."Entry Type");
            //     if TreaStmtCashJnlLine2.FindSet() then
            //         repeat
            //             TotAmt += TreaStmtCashJnlLine2.Amount;
            //             TotAmtLCY += TreaStmtCashJnlLine2."Amount (LCY)";
            //         until TreaStmtCashJnlLine2.Next() = 0;
            //     if TotAmt <> TreasStmtNetSalesLine."Counted Amount" then begin
            //         TreasStmtNetSalesLine."Counted Amount" := TotAmt;
            //         TreasStmtNetSalesLine."Counted Amount in LCY" := TotAmtLCY;
            //         TreasStmtNetSalesLine.Modify();
            //     end;
            // end;
            Page.RunModal(page::"Treasury Journal_NT", TreasuryJnlLine);
        end else
            Message('Not allowed for this line type');
    end;

    procedure GetAccounts(var TreasuryJnlLine: Record "Treasury Journal Line_NT"; var AccName: Text[100]; Var TenderName: Text[30]; Var ReasonCodeDesc: Text[100])
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        Cust: Record Customer;
        [SecurityFiltering(SecurityFilter::Filtered)]
        GLAcc: Record "G/L Account";
        [SecurityFiltering(SecurityFilter::Filtered)]
        TenderTypeSetup: Record "LSC Tender Type Setup";
        [SecurityFiltering(SecurityFilter::Filtered)]
        Vend: Record Vendor;
        [SecurityFiltering(SecurityFilter::Filtered)]
        ReasonCode: Record "Reason Code";
    begin
        if (TreasuryJnlLine."Acc. Type" <> LastTreasuryJnlLine."Acc. Type") or
           (TreasuryJnlLine."Account No." <> LastTreasuryJnlLine."Account No.")
        then begin
            AccName := '';
            TenderName := '';
            ReasonCodeDesc := '';
            if TreasuryJnlLine."Account No." <> '' then
                case TreasuryJnlLine."Acc. Type" of
                    TreasuryJnlLine."Acc. Type"::"G/L Account":
                        if GLAcc.Get(TreasuryJnlLine."Account No.") then
                            AccName := GLAcc.Name;
                    TreasuryJnlLine."Acc. Type"::Customer:
                        if Cust.Get(TreasuryJnlLine."Account No.") then
                            AccName := Cust.Name;
                    TreasuryJnlLine."Acc. Type"::Vendor:
                        if Vend.Get(TreasuryJnlLine."Account No.") then
                            AccName := Vend.Name;
                end;
        end;
        if TreasuryJnlLine."Tender Type" <> '' then
            if TenderTypeSetup.Get(TreasuryJnlLine."Tender Type") then
                TenderName := TenderTypeSetup.Description;
        LastTreasuryJnlLine := TreasuryJnlLine;
        if ReasonCode.Get(TreasuryJnlLine."Reason Code") then
            ReasonCodeDesc := ReasonCode.Description;
    end;

    procedure GetAccounts(var PostedTreasJnlLine: Record "Posted Treasury Jnl. Line_NT"; var AccName: Text[100]; Var TenderName: Text[30])
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        Cust: Record Customer;
        [SecurityFiltering(SecurityFilter::Filtered)]
        GLAcc: Record "G/L Account";
        [SecurityFiltering(SecurityFilter::Filtered)]
        TenderTypeSetup: Record "LSC Tender Type Setup";
        [SecurityFiltering(SecurityFilter::Filtered)]
        Vend: Record Vendor;
    begin
        if (PostedTreasJnlLine."Acc. Type" <> LastPostedTreasJnlLine."Acc. Type") or
           (PostedTreasJnlLine."Account No." <> LastPostedTreasJnlLine."Account No.")
        then begin
            AccName := '';
            TenderName := '';
            if PostedTreasJnlLine."Account No." <> '' then
                case PostedTreasJnlLine."Acc. Type" of
                    PostedTreasJnlLine."Acc. Type"::"G/L Account":
                        if GLAcc.Get(PostedTreasJnlLine."Account No.") then
                            AccName := GLAcc.Name;
                    PostedTreasJnlLine."Acc. Type"::Customer:
                        if Cust.Get(PostedTreasJnlLine."Account No.") then
                            AccName := Cust.Name;
                    PostedTreasJnlLine."Acc. Type"::Vendor:
                        if Vend.Get(PostedTreasJnlLine."Account No.") then
                            AccName := Vend.Name;
                end;
        end;
        if PostedTreasJnlLine."Tender Type" <> '' then
            if TenderTypeSetup.Get(PostedTreasJnlLine."Tender Type") then
                TenderName := TenderTypeSetup.Description;
        LastPostedTreasJnlLine := PostedTreasJnlLine;
    end;

    procedure OpenTreasuryJnlBatch(var TreasuryJnlBatch: Record "Treasury Journal Batch_NT")
    var
        TreasuryJnlLine: Record "Treasury Journal Line_NT";
        TreasuryJnlTemplate: Record "Treasury Journal Template_NT";
        JnlSelected: Boolean;
        RetailUser: Record "LSC Retail User";
    begin
        if TreasuryJnlBatch.GetFilter("Journal Template Name") <> '' then
            exit;
        TreasuryJnlBatch.FilterGroup(2);

        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then
                TreasuryJnlBatch.SetFilter("Store Hierarchy No.", RetailUser."Store Hierarchy No.");

        if TreasuryJnlBatch.GetFilter("Journal Template Name") <> '' then begin
            TreasuryJnlBatch.FilterGroup(0);
            exit;
        end;
        TreasuryJnlBatch.FilterGroup(0);

        if not TreasuryJnlBatch.Find('-') then begin
            if not TreasuryJnlTemplate.Find('-') then
                TemplateSelection(0, TreasuryJnlLine, JnlSelected);
            if TreasuryJnlTemplate.Find('-') then
                CheckTemplateName(TreasuryJnlTemplate.Name, TreasuryJnlBatch.Name);
        end;
        TreasuryJnlBatch.Find('-');
        JnlSelected := true;
        if TreasuryJnlBatch.GetFilter("Journal Template Name") <> '' then
            TreasuryJnlTemplate.SetRange(Name, TreasuryJnlBatch.GetFilter("Journal Template Name"));
        case TreasuryJnlTemplate.Count of
            1:
                TreasuryJnlTemplate.Find('-');
            else
                JnlSelected := PAGE.RunModal(0, TreasuryJnlTemplate) = ACTION::LookupOK;
        end;
        if not JnlSelected then
            Error('');

        TreasuryJnlBatch.FilterGroup(2);
        TreasuryJnlBatch.SetRange("Journal Template Name", TreasuryJnlTemplate.Name);
        TreasuryJnlBatch.FilterGroup(0);
    end;

    procedure TemplateSelection(PageID: Integer; var TreasuryJnlLine: Record "Treasury Journal Line_NT"; var JnlSelected: Boolean)
    var
        TreasuryJnlTemplate: Record "Treasury Journal Template_NT";
    begin
        JnlSelected := true;
        TreasuryJnlTemplate.Reset;
        TreasuryJnlTemplate.SetRange("Page ID", PageID);

        case TreasuryJnlTemplate.Count of
            0:
                begin
                    TreasuryJnlTemplate.Init;
                    TreasuryJnlTemplate.Name := Text007;
                    TreasuryJnlTemplate.Description := Text008;
                    TreasuryJnlTemplate.Validate("Page ID");
                    TreasuryJnlTemplate.Insert;
                    Commit;
                end;
            1:
                TreasuryJnlTemplate.Find('-');
            else
                JnlSelected := PAGE.RunModal(0, TreasuryJnlTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            TreasuryJnlLine.FilterGroup(2);
            TreasuryJnlLine.SetRange("Journal Template Name", TreasuryJnlTemplate.Name);
            TreasuryJnlLine.FilterGroup(0);
            if OpenFromBatch then begin
                TreasuryJnlLine."Journal Template Name" := '';
                PAGE.Run(TreasuryJnlTemplate."Page ID", TreasuryJnlLine);
            end;
        end;
    end;

    procedure CheckTemplateName(CurrentJnlTemplateName: Code[20]; var CurrentJnlBatchName: Code[20])
    var
        TreasuryJnlBatch: Record "Treasury Journal Batch_NT";
        TreasuryJnlBatch2: Record "Treasury Journal Batch_NT";
        TreasuryJnlTemplate: Record "Treasury Journal Template_NT";
        RetailUser: Record "LSC Retail User";
        StoreHierarchyNo: Code[10];
        BatchName: code[20];
    begin
        TreasuryJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if RetailUser.Get(UserId) then
            StoreHierarchyNo := RetailUser."Store Hierarchy No.";
        if StoreHierarchyNo <> '' then
            TreasuryJnlBatch.SetFilter("Store Hierarchy No.", StoreHierarchyNo);

        if not TreasuryJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName) then begin
            if not TreasuryJnlBatch.Find('-') then begin
                TreasuryJnlTemplate.Get(CurrentJnlTemplateName);
                TreasuryJnlBatch.Init;
                TreasuryJnlBatch."Journal Template Name" := TreasuryJnlTemplate.Name;
                BatchName := Text007;
                TreasuryJnlBatch2.SetFilter("Journal Template Name", CurrentJnlTemplateName);
                TreasuryJnlBatch2.SetFilter(Name, '%1', STRSUBSTNO('%1*', Text007));
                if TreasuryJnlBatch2.FindLast() then
                    if TreasuryJnlBatch2.Name = Text007 then
                        BatchName := Text007 + '02'
                    else
                        BatchName := IncStr(TreasuryJnlBatch2.Name);
                TreasuryJnlBatch.Name := BatchName;
                TreasuryJnlBatch.Description := Text008;
                //TreasuryJnlBatch.ID := UserId;
                if StoreHierarchyNo <> '' then
                    TreasuryJnlBatch.Validate("Store Hierarchy No.", StoreHierarchyNo);
                TreasuryJnlBatch.Insert;
                Commit;
            end;
            CurrentJnlBatchName := TreasuryJnlBatch.Name;
        end;
    end;

    procedure TemplateSelectionFromBatch(var TreasuryJnlBatch: Record "Treasury Journal Batch_NT")
    var
        TreasuryJnlLine: Record "Treasury Journal Line_NT";
        TreasuryJnlTemplate: Record "Treasury Journal Template_NT";
        RetailUser: Record "LSC Retail User";
    begin
        OpenFromBatch := true;
        TreasuryJnlTemplate.Get(TreasuryJnlBatch."Journal Template Name");
        TreasuryJnlTemplate.TestField("Page ID");
        TreasuryJnlBatch.TestField(Name);
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then
                TreasuryJnlBatch.TestField("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
        TreasuryJnlLine.FilterGroup := 2;
        TreasuryJnlLine.SetRange("Journal Template Name", TreasuryJnlTemplate.Name);
        TreasuryJnlLine.FilterGroup := 0;

        TreasuryJnlLine."Journal Template Name" := '';
        TreasuryJnlLine."Journal Batch Name" := TreasuryJnlBatch.Name;
        PAGE.Run(TreasuryJnlTemplate."Page ID", TreasuryJnlLine);
    end;

    procedure LookupName(CurrentJnlTemplateName: Code[20]; CurrentJnlBatchName: Code[20]; var EntrdJnlBatchName: Text[20]): Boolean
    var
        TreasuryJnlBatch: Record "Treasury Journal Batch_NT";
        RetailUser: Record "LSC Retail User";
    begin
        TreasuryJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
        TreasuryJnlBatch.Name := CurrentJnlBatchName;
        TreasuryJnlBatch.FilterGroup(2);
        TreasuryJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then
                TreasuryJnlBatch.SetRange(TreasuryJnlBatch."Store Hierarchy No.", RetailUser."Store Hierarchy No.");
        TreasuryJnlBatch.FilterGroup(0);
        if PAGE.RunModal(0, TreasuryJnlBatch) <> ACTION::LookupOK then
            exit(false);

        EntrdJnlBatchName := TreasuryJnlBatch.Name;
        exit(true);
    end;

    procedure CheckName(CurrentJnlBatchName: Code[20]; var TreasuryJnlLine: Record "Treasury Journal Line_NT")
    var
        TreasuryJnlBatch: Record "Treasury Journal Batch_NT";
        RetailUser: Record "LSC Retail User";
    begin
        TreasuryJnlBatch.Get(TreasuryJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then
                TreasuryJnlBatch.TestField("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
    end;

    procedure SetName(CurrentJnlBatchName: Code[20]; var TreasuryJnlLine: Record "Treasury Journal Line_NT")
    begin
        TreasuryJnlLine.FilterGroup := 2;
        TreasuryJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        TreasuryJnlLine.FilterGroup := 0;
        //OnAfterSetName(GenJnlLine, CurrentJnlBatchName);
        if TreasuryJnlLine.Find('-') then;
    end;

    procedure OpenTreasuryJnl(var CurrentJnlBatchName: Code[20]; var TreasuryJnlLine: Record "Treasury Journal Line_NT")
    begin
        CheckTemplateName(TreasuryJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        TreasuryJnlLine.FilterGroup(2);
        TreasuryJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        TreasuryJnlLine.FilterGroup(0);
    end;

    local procedure CreateTreasuryCashPmtRcptLines(var TreasuryStmt: Record "Treasury Statement_NT"; var LastLineNo: Integer)
    var
        TempTreasNetSalesLine: Record "Treasury Stmt. NetSalesLine_NT" temporary;
        TempTreasuryJnlLine: Record "Treasury Journal Line_NT" temporary;
        TreasNetSalesLine: Record "Treasury Stmt. NetSalesLine_NT";
        TreasuryJnlLine: Record "Treasury Journal Line_NT";
        LineNo: Decimal;
    begin
        TempTreasRcptJnlLine.Reset();
        TempTreasRcptJnlLine.DeleteAll();
        LineNo := 10000;
        TreasuryJnlLine.SetRange("Posting Date", TreasuryStmt."Trans. Starting Date", TreasuryStmt."Trans. Ending Date");
        TreasuryJnlLine.SetFilter(Status, '%1', TreasuryJnlLine.Status::Released);
        TreasuryJnlLine.SetFilter("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
        if TreasuryJnlLine.FindSet() then
            repeat
                if TreasuryJnlLine."Treasury Statement No." = '' then begin
                    TempTreasNetSalesLine.Reset();
                    TempTreasNetSalesLine.SetRange("Tender Type", TreasuryJnlLine."Tender Type");
                    case TreasuryJnlLine."Entry Type" of
                        TreasuryJnlLine."Entry Type"::"Cash-Payments":
                            TempTreasNetSalesLine.SetRange("Line Type", TempTreasNetSalesLine."Line Type"::"Cash-Payments");
                        TreasuryJnlLine."Entry Type"::"Cash-Receipts":
                            TempTreasNetSalesLine.SetRange("Line Type", TempTreasNetSalesLine."Line Type"::"Cash-Receipts");
                    end;
                    if not TempTreasNetSalesLine.FindFirst() then begin
                        TempTreasNetSalesLine.Reset();
                        TempTreasNetSalesLine.Init();
                        TempTreasNetSalesLine."Treasury Statement No." := TreasuryStmt."Treasury Statement No.";
                        TempTreasNetSalesLine."Line No." := LineNo;

                        case TreasuryJnlLine."Entry Type" of
                            TreasuryJnlLine."Entry Type"::"Cash-Payments":
                                TempTreasNetSalesLine."Line Type" := TempTreasNetSalesLine."Line Type"::"Cash-Payments";
                            TreasuryJnlLine."Entry Type"::"Cash-Receipts":
                                TempTreasNetSalesLine."Line Type" := TempTreasNetSalesLine."Line Type"::"Cash-Receipts";
                        end;
                        TempTreasNetSalesLine."Tender Type" := TreasuryJnlLine."Tender Type";
                        TempTreasNetSalesLine."Counted Amount" := TreasuryJnlLine.Amount;
                        TempTreasNetSalesLine."Counted Amount in LCY" := TreasuryJnlLine."Amount (LCY)";
                        TempTreasNetSalesLine.Insert();

                        TempTreasuryJnlLine.Init();
                        TempTreasuryJnlLine.TransferFields(TreasuryJnlLine);
                        TempTreasuryJnlLine.Insert();
                        LineNo += 10;
                    end else begin
                        TempTreasNetSalesLine."Counted Amount" += TreasuryJnlLine.Amount;
                        TempTreasNetSalesLine."Counted Amount in LCY" += TreasuryJnlLine."Amount (LCY)";
                        TempTreasNetSalesLine.Modify();
                        TempTreasuryJnlLine.Init();
                        TempTreasuryJnlLine.TransferFields(TreasuryJnlLine);
                        TempTreasuryJnlLine.Insert();
                    end;
                    if TreasuryJnlLine."Entry Type" = TreasuryJnlLine."Entry Type"::"Cash-Receipts" then begin
                        TempTreasRcptJnlLine.Init();
                        TempTreasRcptJnlLine.TransferFields(TreasuryJnlLine);
                        TempTreasRcptJnlLine.Insert();
                    end;
                end;
            until TreasuryJnlLine.Next() = 0;

        TempTreasNetSalesLine.Reset();
        if TempTreasNetSalesLine.FindSet() then
            repeat
                TreasNetSalesLine.SetFilter("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
                TreasNetSalesLine.SetRange("Line Type", TempTreasNetSalesLine."Line Type");
                TreasNetSalesLine.SetFilter("Tender Type", TempTreasNetSalesLine."Tender Type");
                if not TreasNetSalesLine.FindFirst() then begin
                    TreasNetSalesLine.Reset();
                    TreasNetSalesLine.Init();
                    TreasNetSalesLine."Treasury Statement No." := TreasuryStmt."Treasury Statement No.";
                    TreasNetSalesLine."Store Hierarchy No." := TreasuryStmt."Store Hierarchy No.";
                    TreasNetSalesLine."Line No." := LastLineNo;
                    TreasNetSalesLine."Line Type" := TempTreasNetSalesLine."Line Type";
                    TreasNetSalesLine.Validate("Tender Type", TempTreasNetSalesLine."Tender Type");
                    TreasNetSalesLine."Counted Amount" := TempTreasNetSalesLine."Counted Amount";
                    TreasNetSalesLine."Counted Amount in LCY" := TempTreasNetSalesLine."Counted Amount in LCY";
                    TreasNetSalesLine.Insert();
                    LastLineNo += 10;
                end else begin
                    TreasNetSalesLine."Counted Amount" += TempTreasNetSalesLine."Counted Amount";
                    TreasNetSalesLine."Counted Amount in LCY" += TempTreasNetSalesLine."Counted Amount in LCY";
                    TreasNetSalesLine.Modify();
                end;
                //MARK Treasury Journal Lines with Stmt no & Line No
                TreasuryJnlLine.Reset();
                TempTreasuryJnlLine.Reset();
                TempTreasuryJnlLine.SetRange("Tender Type", TreasNetSalesLine."Tender Type");
                case TreasNetSalesLine."Line Type" of
                    TreasNetSalesLine."Line Type"::"Cash-Payments":
                        TempTreasuryJnlLine.SetRange("Entry Type", TempTreasuryJnlLine."Entry Type"::"Cash-Payments");
                    TreasNetSalesLine."Line Type"::"Cash-Receipts":
                        TempTreasuryJnlLine.SetRange("Entry Type", TempTreasuryJnlLine."Entry Type"::"Cash-Receipts");
                end;
                TempTreasuryJnlLine.FindSet();
                repeat
                    TreasuryJnlLine.Get(TempTreasuryJnlLine."Journal Template Name", TempTreasuryJnlLine."Journal Batch Name", TempTreasuryJnlLine."Line No.");
                    TreasuryJnlLine.Validate("Treasury Statement No.", TreasNetSalesLine."Treasury Statement No.");
                    TreasuryJnlLine.Validate("Treasury Stmt. Line No.", TreasNetSalesLine."Line No.");
                    TreasuryJnlLine.Modify();
                until TempTreasuryJnlLine.Next() = 0;
            until TempTreasNetSalesLine.Next() = 0;
    end;

    local procedure PostTreasuryJournal(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        NewGLReg: Record "G/L Register";
        TreasuryJnlLine2: Record "Treasury Journal Line_NT";
        TreasuryJnlLine: Record "Treasury Journal Line_NT";

    begin
        TreasuryJnlLine.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasuryJnlLine.SetFilter(Status, '%1', TreasuryJnlLine.Status::Released);
        TreasuryJnlLine.SetFilter("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
        if TreasuryJnlLine.FindSet() then
            repeat
                TreasuryJnlLine.TestField("Tender Type");
                TreasuryJnlLine.TestField("Account No.");
                //FindTenderAccount(TreasuryJnlLine."Store Hierarchy No.", TreasuryJnlLine."Tender Type", GenJnlAccType, GenJnlAccNo);

                InitPostGenJnl(TreasuryJnlLine, NewGLReg);

                //balncing line
                //InitPostGenJnl(TreasuryJnlLine, GenJnlAccType, GenJnlAccNo, Sign * (-1), NewGLReg);
                TreasuryJnlLine2.Get(TreasuryJnlLine."Journal Template Name", TreasuryJnlLine."Journal Batch Name", TreasuryJnlLine."Line No.");
                TreasuryJnlLine2.Status := TreasuryJnlLine2.Status::Posted;
                TreasuryJnlLine2."G/L Register No." := NewGLReg."No.";
                TreasuryJnlLine2.Modify();
            until TreasuryJnlLine.Next() = 0;
    end;

    procedure FindControlAccount(StoreHierarchyCode: Code[10]; TenderTypeCode: Code[10]; var AccType: Enum "Gen. Journal Account Type"; Var AccNo: Code[20])
    var
        ControlAcc: Record "Treasury Control Account_NT";
        HierarchyDefs: Record "LSC Retail Hierar. Defaults";
        TenderType: Record "LSC Tender Type";
        StoreNo: Code[10];
    begin
        // HierarchyDefs.SetRange("Table ID", Database::"LSC Store");
        // HierarchyDefs.SetRange("Hierarchy Code", StoreHierarchyCode);
        // if HierarchyDefs.FindFirst() then
        //     StoreNo := HierarchyDefs."No."
        // else
        //     Error(Text009);
        // TenderType.Get(StoreNo, TenderTypeCode);
        // TenderType.TestField("Account No.");
        // case TenderType."Account Type" of
        //     TenderType."Account Type"::"G/L Account":
        //         AccType := AccType::"G/L Account";
        //     TenderType."Account Type"::"Bank Account":
        //         AccType := AccType::"Bank Account";
        // end;

        //New Logic
        ControlAcc.SetFilter("Store Hierarchy No.", StoreHierarchyCode);
        if not ControlAcc.FindFirst() then
            Error(Text014, StoreHierarchyCode)
        else
            if ControlAcc."Control Account No." = '' then
                Error(Text014, StoreHierarchyCode);

        AccType := AccType::"G/L Account";
        AccNo := ControlAcc."Control Account No.";
    end;

    local procedure InitPostGenJnl(var TreasuryJnlLine: Record "Treasury Journal Line_NT"; Var NewGLReg: Record "G/L Register")
    var
        GenJnlLine: Record "Gen. Journal Line";
        DimMgt: Codeunit DimensionManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlAccNo: Code[20];
        Sign: Integer;
        GenJnlAccType: Enum "Gen. Journal Account Type";
    begin
        FindControlAccount(TreasuryJnlLine."Store Hierarchy No.", TreasuryJnlLine."Tender Type", GenJnlAccType, GenJnlAccNo);

        if TreasuryJnlLine."Entry Type" = TreasuryJnlLine."Entry Type"::"Cash-Receipts" then
            Sign := 1
        else
            Sign := -1;
        //Tender Line
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := TreasuryJnlLine."Posting Date";
        GenJnlLine."Document Date" := TreasuryJnlLine."Document Date";
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."External Document No." := TreasuryJnlLine."External Document No.";
        GenJnlLine."Account Type" := GenJnlAccType;
        GenJnlLine.VALIDATE("Account No.", GenJnlAccNo);
        if TreasuryJnlLine.Description <> '' then
            GenJnlLine.Description := TreasuryJnlLine.Description;
        GenJnlLine."Document No." := TreasuryJnlLine."Document No.";
        GenJnlLine.VALIDATE("Currency Code", TreasuryJnlLine."Currency Code");
        GenJnlLine.validate("Currency Factor", TreasuryJnlLine."Currency Factor");
        GenJnlLine.Validate(Amount, Sign * TreasuryJnlLine.Amount);
        GenJnlLine."Reason Code" := TreasuryJnlLine."Reason Code";
        GenJnlLine."Source Code" := TreasuryJnlLine."Source Code";
        GenJnlLine."Dimension Set ID" := TreasuryJnlLine."Dimension Set ID";
        DimMgt.UpdateGenJnlLineDim(GenJnlLine, GenJnlLine."Dimension Set ID");
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        //Balacing Acc Line
        Sign := Sign * -1;
        case TreasuryJnlLine."Acc. Type" of
            TreasuryJnlLine."Acc. Type"::Customer:
                GenJnlAccType := GenJnlAccType::Customer;
            TreasuryJnlLine."Acc. Type"::"G/L Account":
                GenJnlAccType := GenJnlAccType::"G/L Account";
            TreasuryJnlLine."Acc. Type"::Vendor:
                GenJnlAccType := GenJnlAccType::Vendor
        end;
        GenJnlAccNo := TreasuryJnlLine."Account No.";

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := TreasuryJnlLine."Posting Date";
        GenJnlLine."Document Date" := TreasuryJnlLine."Document Date";
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."External Document No." := TreasuryJnlLine."External Document No.";
        GenJnlLine."Account Type" := GenJnlAccType;
        GenJnlLine.VALIDATE("Account No.", GenJnlAccNo);
        if TreasuryJnlLine.Description <> '' then
            GenJnlLine.Description := TreasuryJnlLine.Description;
        GenJnlLine."Document No." := TreasuryJnlLine."Document No.";
        GenJnlLine.VALIDATE("Currency Code", TreasuryJnlLine."Currency Code");
        GenJnlLine.validate("Currency Factor", TreasuryJnlLine."Currency Factor");
        GenJnlLine.Validate(Amount, Sign * TreasuryJnlLine.Amount);
        GenJnlLine."Reason Code" := TreasuryJnlLine."Reason Code";
        GenJnlLine."Source Code" := TreasuryJnlLine."Source Code";
        GenJnlLine."Dimension Set ID" := TreasuryJnlLine."Dimension Set ID";
        DimMgt.UpdateGenJnlLineDim(GenJnlLine, GenJnlLine."Dimension Set ID");
        GenJnlPostLine.RunWithCheck(GenJnlLine);
        GenJnlPostLine.GetGLReg(NewGLReg);
    end;

    procedure ReleaseTreasuryJournal(var TreasuryJnl: Record "Treasury Journal Line_NT")
    begin
        CheckAndReleaseTreasuryJnlLine(TreasuryJnl);
    end;

    procedure ReopenTreasuryJournalDoc(var TreasuryJnl: Record "Treasury Journal Line_NT")
    var
        TreasuryJnlToUpd: Record "Treasury Journal Line_NT";
    begin
        TreasuryJnlToUpd.SetRange("Journal Template Name", TreasuryJnl."Journal Template Name");
        TreasuryJnlToUpd.SetRange("Journal Batch Name", TreasuryJnl."Journal Batch Name");
        TreasuryJnlToUpd.SetRange(Status, TreasuryJnlToUpd.Status::Released);
        TreasuryJnlToUpd.SetFilter("Treasury Statement No.", '');
        TreasuryJnlToUpd.ModifyAll(Status, TreasuryJnlToUpd.Status::Open);
    end;

    procedure ShowPostedTreasuryJournal(Var PostedTreasNetSalesLine: Record "Posted Treas. NetSalesLine_NT")
    var
        PostedTreasuryJnlLine2: Record "Posted Treasury Jnl. Line_NT";
        PostedTreasuryJnlLine: Record "Posted Treasury Jnl. Line_NT";
        TotAmt: Decimal;
        TotAmtLCY: Decimal;
    begin
        if PostedTreasNetSalesLine."Line Type" IN [PostedTreasNetSalesLine."Line Type"::"Cash-Payments", PostedTreasNetSalesLine."Line Type"::"Cash-Receipts"] then begin
            PostedTreasuryJnlLine.FilterGroup(2);
            PostedTreasuryJnlLine.SetRange("Treasury Statement No.", PostedTreasNetSalesLine."Treasury Statement No.");
            PostedTreasuryJnlLine.SetRange("Treasury Stmt. Line No.", PostedTreasNetSalesLine."Line No.");

            case PostedTreasNetSalesLine."Line Type" of
                PostedTreasNetSalesLine."Line Type"::"Cash-Payments":
                    PostedTreasuryJnlLine.Setrange("Entry Type", PostedTreasuryJnlLine."Entry Type"::"Cash-Payments");
                PostedTreasNetSalesLine."Line Type"::"Cash-Receipts":
                    PostedTreasuryJnlLine.Setrange("Entry Type", PostedTreasuryJnlLine."Entry Type"::"Cash-Receipts");
            end;
            PostedTreasuryJnlLine.FilterGroup(0);
            Page.RunModal(page::"Posted Treasury Journal_NT", PostedTreasuryJnlLine);
        end else
            Message('Not allowed for this line type');
    end;

    procedure CheckDimensions(TreasuryJnlLine: Record "Treasury Journal Line_NT")
    var
        Cust: Record Customer;
        Vend: Record Vendor;
        DimMgt: Codeunit DimensionManagement;
        GenJnlAccNo: Code[20];
        No: array[10] of Code[20];
        TableID: array[10] of Integer;
        GenJnlAccType: Enum "Gen. Journal Account Type";
    begin
        //FindControlAccount(TreasuryJnlLine."Store Hierarchy No.", TreasuryJnlLine."Tender Type", GenJnlAccType, GenJnlAccNo);
        FindTenderControlAccount(TreasuryJnlLine."Store Hierarchy No.", TreasuryJnlLine."Tender Type", GenJnlAccType, GenJnlAccNo);
        if not DimMgt.CheckDimIDComb(TreasuryJnlLine."Dimension Set ID") then
            ThrowGenJnlLineError(TreasuryJnlLine, Text010, DimMgt.GetDimCombErr);

        //Tender Account
        TableID[1] := Database::"G/L Account";
        No[1] := GenJnlAccNo;

        //Balance Account
        Clear(Cust);
        Clear(Vend);
        case TreasuryJnlLine."Acc. Type" of
            TreasuryJnlLine."Acc. Type"::"G/L Account":
                TableID[2] := Database::"G/L Account";
            TreasuryJnlLine."Acc. Type"::Customer:
                begin
                    TableID[2] := Database::Customer;
                    Cust.Get(TreasuryJnlLine."Account No.");
                end;
            TreasuryJnlLine."Acc. Type"::Vendor:
                begin
                    TableID[2] := Database::Vendor;
                    Vend.Get(TreasuryJnlLine."Account No.");
                end;
        end;
        No[2] := TreasuryJnlLine."Account No.";
        // TableID[3] := DATABASE::Job;
        // No[3] := "Job No.";
        TableID[4] := DATABASE::"Salesperson/Purchaser";
        if Cust."Salesperson Code" <> '' then
            No[4] := Cust."Salesperson Code";
        if Vend."Purchaser Code" <> '' then
            No[4] := Vend."Purchaser Code";

        TableID[5] := DATABASE::Campaign;
        //No[5] := "Campaign No.";
        No[5] := '';

        if not DimMgt.CheckDimValuePosting(TableID, No, TreasuryJnlLine."Dimension Set ID") then
            ThrowGenJnlLineError(TreasuryJnlLine, Text011, DimMgt.GetDimValuePostingErr);
    end;

    procedure CheckAndReleaseTreasuryJnlLine(Var TreasuryJnlLine: Record "Treasury Journal Line_NT")
    var
        AlphaMegaSetup: Record "AlphaMega Setup_NT";
        TreasuryJnlLine2: Record "Treasury Journal Line_NT";
        TreasuryJnlToUpd: Record "Treasury Journal Line_NT";

        UpdCnt: Integer;
    begin
        TreasuryJnlLine2.SetRange("Journal Template Name", TreasuryJnlLine."Journal Template Name");
        TreasuryJnlLine2.SetRange("Journal Batch Name", TreasuryJnlLine."Journal Batch Name");
        TreasuryJnlLine2.SetRange(Status, TreasuryJnlToUpd.Status::Open);
        if TreasuryJnlLine2.IsEmpty then begin
            Message(Text012);
            exit;
        end;
        if TreasuryJnlLine2.FindSet() then
            repeat
                TreasuryJnlLine2.TestField("Posting Date");
                TreasuryJnlLine2.TestField("Tender Type");
                //TreasuryJnlLine2.TestField("Acc. Type");
                TreasuryJnlLine2.TestField("Account No.");
                TreasuryJnlLine2.TestField(Amount);
                TreasuryJnlLine2.TestField("Reason Code");
                TreasuryJnlLine2.TestField("Store Hierarchy No.");
                if AlphaMegaSetup.Get() then
                    if AlphaMegaSetup."Ext. Doc. No. Mandatory" then
                        TreasuryJnlLine2.TestField("External Document No.");
                CheckDimensions(TreasuryJnlLine2);
                TreasuryJnlToUpd.Get(TreasuryJnlLine2."Journal Template Name", TreasuryJnlLine2."Journal Batch Name", TreasuryJnlLine2."Line No.");
                TreasuryJnlToUpd.Status := TreasuryJnlToUpd.Status::Released;
                TreasuryJnlToUpd."Treasury Statement No." := '';
                TreasuryJnlToUpd.Modify();
                UpdCnt += 1;
            until TreasuryJnlLine2.Next() = 0;
        Message(Text013, UpdCnt);
    end;

    procedure ThrowGenJnlLineError(TreasuryJnlLine: Record "Treasury Journal Line_NT"; ErrorTemplate: Text; ErrorText: Text)
    begin
        if TreasuryJnlLine."Line No." <> 0 then
            Error(StrSubstNo(
                        ErrorTemplate,
                        TreasuryJnlLine.TableCaption, TreasuryJnlLine."Journal Template Name", TreasuryJnlLine."Journal Batch Name", TreasuryJnlLine."Line No.",
                        ErrorText),
                    true,
                    TreasuryJnlLine);

        Error(ErrorText, true, TreasuryJnlLine);
    end;

    local procedure InsertTreasuryAllocationLines(var TreasuryStmt: Record "Treasury Statement_NT"; var TempSummedStmtLine: Record "LSC Statement Line" temporary; var TempStoresToFilter: Record "LSC Store" temporary)
    var
        TenderType: Record "LSC Tender Type";
        TreasAllocationLines: Record "Treasury Allocation Line_NT";
        DepositBankAcc: Code[20];
        DiffBankAcc: Code[20];
        LineNo: Integer;
    begin
        TreasAllocationLines.SetRange("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        if TreasAllocationLines.FindLast() then
            LineNo := TreasAllocationLines."Line No." + 10
        else
            LineNo := 10000;
        TempSummedStmtLine.Reset();
        if TempSummedStmtLine.FindSet() then
            repeat
                TreasAllocationLines.Reset();
                TreasAllocationLines.SetFilter("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
                TreasAllocationLines.SetFilter("Tender Type", TempSummedStmtLine."Tender Type");
                TreasAllocationLines.SetFilter("Adj. Undeposited Amt. Line", '%1', false);
                if not TreasAllocationLines.FindFirst() then begin
                    TreasAllocationLines.Reset();
                    TreasAllocationLines.Init();
                    TreasAllocationLines.Validate("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
                    TreasAllocationLines."Line No." := LineNo;
                    TreasAllocationLines.Validate("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
                    TreasAllocationLines.Validate("Tender Type", TempSummedStmtLine."Tender Type");
                    TreasAllocationLines."Counted Amount" := TempSummedStmtLine."Counted Amount";
                    TreasAllocationLines."Counted Amount in LCY" := TempSummedStmtLine."Counted Amount in LCY";
                    TreasAllocationLines."Calculated Amount" := TempSummedStmtLine."Counted Amount";
                    TreasAllocationLines."Calculated in LCY" := TempSummedStmtLine."Counted Amount in LCY";
                    if TempSummedStmtLine."Counted Amount" <> 0 then
                        TreasAllocationLines."Real Exchange Rate" := TempSummedStmtLine."Counted Amount in LCY" / TempSummedStmtLine."Counted Amount"
                    else
                        TreasAllocationLines."Real Exchange Rate" := 1;
                    TenderType.Get(TempSummedStmtLine."Store No.", TempSummedStmtLine."Tender Type");
                    TreasAllocationLines."Counting Required" := TenderType."Counting Required";
                    TreasAllocationLines."Taken to Bank" := TenderType."Taken to Bank";
                    if TreasAllocationLines."Taken to Bank" then
                        TreasAllocationLines."Posting Date" := WorkDate()
                    else
                        TreasAllocationLines."Posting Date" := TreasuryStmt."Posting Date";
                    LineNo += 10;
                    DepositBankAcc := '';
                    if TreasAllocationLines."Taken to Bank" then begin
                        UpdAllocLineAvailableAmtToDeposit(TreasAllocationLines);
                        FindTenderDepositBankAcc(TreasAllocationLines."Store Hierarchy No.", TreasAllocationLines."Tender Type", DepositBankAcc, DiffBankAcc);
                        if DepositBankAcc = '' then
                            Error(Text017, TreasAllocationLines."Store Hierarchy No.", TreasAllocationLines."Tender Type Name");
                        TreasAllocationLines.Validate("Bank Account No.", DepositBankAcc);
                    end;
                    InsertTreasAllocAdjUndepositedLine(TreasAllocationLines, LineNo);
                    TreasAllocationLines.Insert(true);
                end else begin
                    TreasAllocationLines."Counted Amount" += TempSummedStmtLine."Counted Amount";
                    TreasAllocationLines."Counted Amount in LCY" += TempSummedStmtLine."Counted Amount in LCY";
                    TreasAllocationLines."Calculated Amount" += TempSummedStmtLine."Counted Amount";
                    TreasAllocationLines."Calculated in LCY" += TempSummedStmtLine."Counted Amount in LCY";
                    TreasAllocationLines.Modify();
                end;
            until TempSummedStmtLine.Next() = 0;
        InsertTreasAllocCashRcptLines(TreasuryStmt, LineNo, TempStoresToFilter);
    end;

    local procedure PostTreasuryAllocation(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        NewGLReg: Record "G/L Register";
        TreasAllocLine: Record "Treasury Allocation Line_NT";


    begin
        TreasAllocLine.SetFilter("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasAllocLine.SetFilter("Counted Amount", '<>0');
        if TreasAllocLine.FindSet() then
            repeat
                TreasAllocLine.TestField("Tender Type");
                TreasAllocLine.TestField("Counted Amount");
                If TreasAllocLine."Taken to Bank" then
                    TreasAllocLine.TestField("Bank Account No.");

                InitPostTreasAllocaGenJnl(TreasuryStmt, TreasAllocLine, NewGLReg);
                TreasAllocLine.Validate("G/L Register No.", NewGLReg."No.");
                TreasAllocLine.Modify();
            until TreasAllocLine.Next() = 0;
    end;

    local procedure InitPostTreasAllocaGenJnl(TreasuryStmt: Record "Treasury Statement_NT"; var TreasAllocLine: Record "Treasury Allocation Line_NT"; Var NewGLReg: Record "G/L Register")
    var
        GenJnlLine: Record "Gen. Journal Line";
        BankAccLedg: Record "Bank Account Ledger Entry";
        DimMgt: Codeunit DimensionManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        BalGenJnlAccNo: Code[20];
        DepositBankAcc: Code[20];
        DiffBankAcc: Code[20];
        GenJnlAccNo: Code[20];
        Sign: Integer;
        BalGenJnlAccType: Enum "Gen. Journal Account Type";
        GenJnlAccType: Enum "Gen. Journal Account Type";
        PostingDate: Date;
        DocumentDate: Date;
    begin
        TreasAllocLine.SetAutoCalcFields();
        if not TreasAllocLine."Taken to Bank" then
            FindTenderControlAccount(TreasAllocLine."Store Hierarchy No.", TreasAllocLine."Tender Type", GenJnlAccType, GenJnlAccNo)
        else begin
            GenJnlAccType := GenJnlAccType::"Bank Account";
            GenJnlAccNo := TreasAllocLine."Bank Account No.";
        end;

        Sign := 1;
        PostingDate := 0D;
        DocumentDate := 0D;
        if TreasAllocLine."Posting Date" = 0D then
            PostingDate := TreasuryStmt."Posting Date"
        else
            PostingDate := TreasAllocLine."Posting Date";

        DocumentDate := PostingDate;

        if TreasAllocLine."Adj. Undeposited Amt. Line" = false then begin
            GenJnlLine.Init();
            //GenJnlLine."Posting Date" := TreasuryStmt."Posting Date";
            //GenJnlLine."Document Date" := TreasuryStmt."Posting Date";
            GenJnlLine."Posting Date" := PostingDate;
            GenJnlLine."Document Date" := DocumentDate;
            GenJnlLine."System-Created Entry" := true;
            if TreasAllocLine."Bag No." <> '' then
                GenJnlLine."External Document No." := TreasAllocLine."Bag No."
            else
                GenJnlLine."External Document No." := TreasAllocLine."Deposit Slip No.";
            GenJnlLine."Account Type" := GenJnlAccType;
            GenJnlLine.VALIDATE("Account No.", GenJnlAccNo);
            GenJnlLine."Document No." := TreasuryStmt."Treasury Statement No.";
            GenJnlLine.VALIDATE("Currency Code", TreasAllocLine."Currency Code");
            GenJnlLine.Validate(Amount, Sign * TreasAllocLine."Counted Amount");
            GenJnlLine."Dimension Set ID" := TreasAllocLine."Dimension Set ID";
            DimMgt.UpdateGenJnlLineDim(GenJnlLine, GenJnlLine."Dimension Set ID");
            GenJnlPostLine.RunWithCheck(GenJnlLine);

            //Balacing Acc Line
            Sign := Sign * -1;
            FindControlAccount(TreasAllocLine."Store Hierarchy No.", TreasAllocLine."Tender Type", BalGenJnlAccType, BalGenJnlAccNo);
            GenJnlLine.Init();
            //GenJnlLine."Posting Date" := TreasuryStmt."Posting Date";            
            //GenJnlLine."Document Date" := TreasuryStmt."Posting Date";
            GenJnlLine."Posting Date" := PostingDate;
            GenJnlLine."Document Date" := DocumentDate;

            GenJnlLine."System-Created Entry" := true;
            GenJnlLine."External Document No." := TreasAllocLine."Bag No.";
            GenJnlLine."Account Type" := BalGenJnlAccType;
            GenJnlLine.VALIDATE("Account No.", BalGenJnlAccNo);
            GenJnlLine."Document No." := TreasuryStmt."Treasury Statement No.";
            GenJnlLine.VALIDATE("Currency Code", TreasAllocLine."Currency Code");
            GenJnlLine.Validate(Amount, Sign * (TreasAllocLine."Counted Amount"));
            GenJnlLine."Dimension Set ID" := TreasAllocLine."Dimension Set ID";
            DimMgt.UpdateGenJnlLineDim(GenJnlLine, GenJnlLine."Dimension Set ID");
            GenJnlPostLine.RunWithCheck(GenJnlLine);
        end;
        if TreasAllocLine."Adj. Undeposited Amt. Line" then
            if TreasAllocLine."Taken to Bank" then
                if TreasAllocLine."Counted Amount" <> 0 then begin
                    Sign := 1;
                    FindTenderDepositBankAcc(TreasAllocLine."Store Hierarchy No.", TreasAllocLine."Tender Type", DepositBankAcc, DiffBankAcc);
                    if DiffBankAcc = '' then
                        Error(Text016, TreasuryStmt."Store Hierarchy No.", TreasAllocLine."Tender Type Name");
                    if DepositBankAcc = '' then
                        Error(Text017, TreasuryStmt."Store Hierarchy No.", TreasAllocLine."Tender Type Name");
                    GenJnlLine.Init();
                    // GenJnlLine."Posting Date" := TreasuryStmt."Posting Date";
                    // GenJnlLine."Document Date" := TreasuryStmt."Posting Date";
                    GenJnlLine."Posting Date" := PostingDate;
                    GenJnlLine."Document Date" := DocumentDate;
                    GenJnlLine."System-Created Entry" := true;
                    GenJnlLine."External Document No." := TreasAllocLine."Bag No.";
                    GenJnlLine."Account Type" := GenJnlAccType::"Bank Account";
                    GenJnlLine.VALIDATE("Account No.", DepositBankAcc);
                    GenJnlLine."Document No." := TreasuryStmt."Treasury Statement No.";
                    GenJnlLine.VALIDATE("Currency Code", TreasAllocLine."Currency Code");
                    GenJnlLine.Validate(Amount, Sign * TreasAllocLine."Counted Amount");
                    GenJnlLine."Dimension Set ID" := TreasAllocLine."Dimension Set ID";
                    DimMgt.UpdateGenJnlLineDim(GenJnlLine, GenJnlLine."Dimension Set ID");
                    GenJnlPostLine.RunWithCheck(GenJnlLine);

                    //Balacing Acc Line
                    Sign := Sign * -1;
                    FindControlAccount(TreasAllocLine."Store Hierarchy No.", TreasAllocLine."Tender Type", BalGenJnlAccType, BalGenJnlAccNo);
                    GenJnlLine.Init();
                    // GenJnlLine."Posting Date" := TreasuryStmt."Posting Date";
                    // GenJnlLine."Document Date" := TreasuryStmt."Posting Date";
                    GenJnlLine."Posting Date" := PostingDate;
                    GenJnlLine."Document Date" := DocumentDate;
                    GenJnlLine."System-Created Entry" := true;
                    GenJnlLine."External Document No." := TreasAllocLine."Bag No.";
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
                    GenJnlLine.VALIDATE("Account No.", DiffBankAcc);
                    GenJnlLine."Document No." := TreasuryStmt."Treasury Statement No.";
                    GenJnlLine.VALIDATE("Currency Code", TreasAllocLine."Currency Code");
                    GenJnlLine.Validate(Amount, Sign * (TreasAllocLine."Counted Amount"));
                    GenJnlLine."Dimension Set ID" := TreasAllocLine."Dimension Set ID";
                    DimMgt.UpdateGenJnlLineDim(GenJnlLine, GenJnlLine."Dimension Set ID");
                    GenJnlPostLine.RunWithCheck(GenJnlLine);
                end else begin
                    BankAccLedg.Get(TreasAllocLine."Reference Entry No.");
                    BankAccLedg."Treasury Statement No." := '';
                    BankAccLedg."Treas. Alloc. Line No." := 0;
                    BankAccLedg."Store Hierarchy No." := '';
                    BankAccLedg.Modify();
                end;

        GenJnlPostLine.GetGLReg(NewGLReg);
    end;

    procedure FindTenderControlAccount(StoreHierarchyCode: Code[10]; TenderTypeCode: Code[10]; var AccType: Enum "Gen. Journal Account Type"; Var AccNo: Code[20])
    var
        ControlAccTender: Record "Store Hierarchy Tender Type_NT";
    begin
        ControlAccTender.SetFilter("Store Hierarchy No.", StoreHierarchyCode);
        ControlAccTender.SetFilter("Tender Type", TenderTypeCode);
        if not ControlAccTender.FindFirst() then
            Error(Text015, TenderTypeCode, StoreHierarchyCode)
        else
            if ControlAccTender."Control Account No." = '' then
                Error(Text019, TenderTypeCode, StoreHierarchyCode);

        AccType := AccType::"G/L Account";
        AccNo := ControlAccTender."Tender Account No.";
    end;

    procedure FindTenderDepositBankAcc(StoreHierarchyCode: Code[10]; TenderTypeCode: Code[10]; Var DepositBankAccNo: Code[20]; Var DiffBankAccNo: Code[20])
    var
        ControlAccTender: Record "Store Hierarchy Tender Type_NT";
    begin
        ControlAccTender.SetFilter("Store Hierarchy No.", StoreHierarchyCode);
        ControlAccTender.SetFilter("Tender Type", TenderTypeCode);
        if not ControlAccTender.FindFirst() then
            Error(Text015, TenderTypeCode, StoreHierarchyCode)
        else
            if ControlAccTender."Control Account No." = '' then
                Error(Text019, TenderTypeCode, StoreHierarchyCode);
        DepositBankAccNo := ControlAccTender."Deposit Bank Account";
        DiffBankAccNo := ControlAccTender."Diff. Bank Account";
    end;

    procedure CalculateTreasuryStmtOpening(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        ControlAcc: Record "Treasury Control Account_NT";
        GLAcc: Record "G/L Account";
    begin
        ControlAcc.SetFilter("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
        ControlAcc.FindFirst();
        ControlAcc.TestField("Control Account No.");
        GLAcc.SetFilter("No.", ControlAcc."Control Account No.");
        GLAcc.SetRange("Date Filter", 0D, TreasuryStmt."Trans. Starting Date" - 1);
        GLAcc.FindFirst();
        GLAcc.CalcFields("Net Change");
        TreasuryStmt."Float Opening" := GLAcc."Net Change";
        TreasuryStmt.Modify();
    end;

    local procedure UpdAllocLineAvailableAmtToDeposit(Var TreasAllocLine: Record "Treasury Allocation Line_NT")
    var
        TreasNetSalesLine: Record "Treasury Stmt. NetSalesLine_NT";
        TreasStmtLine: Record "Treasury Statement Line_NT";
        TotAmt2: Decimal;
        TotAmt: Decimal;
        TotAmtLCY2: Decimal;
        TotAmtLCY: Decimal;
    begin
        TreasStmtLine.SetFilter("Treasury Statement No.", TreasAllocLine."Treasury Statement No.");
        TreasStmtLine.SetFilter("Tender Type", TreasAllocLine."Tender Type");
        if TreasStmtLine.FindSet() then
            repeat
                TotAmt += TreasStmtLine."Counted Amount";
                TotAmtLCY += TreasStmtLine."Counted Amount in LCY";
            until TreasStmtLine.Next() = 0;

        TreasNetSalesLine.SetFilter("Treasury Statement No.", TreasAllocLine."Treasury Statement No.");
        TreasNetSalesLine.SetFilter("Tender Type", TreasAllocLine."Tender Type");
        if TreasNetSalesLine.FindSet() then
            repeat
                Case TreasNetSalesLine."Line Type" of
                    TreasNetSalesLine."Line Type"::"Cash-Receipts":
                        begin
                            TotAmt += TreasNetSalesLine."Counted Amount";
                            TotAmtLCY += TreasNetSalesLine."Counted Amount in LCY";
                        end;
                    TreasNetSalesLine."Line Type"::"Cash-Payments":
                        begin
                            TotAmt2 += TreasNetSalesLine."Counted Amount";
                            TotAmtLCY2 += TreasNetSalesLine."Counted Amount in LCY";
                        end;
                end;
            until TreasNetSalesLine.Next() = 0;
        TreasAllocLine."Available To Deposit" := TotAmt - TotAmt2;
        TreasAllocLine."Available To Deposit LCY" := TotAmtLCY - TotAmtLCY2;
    end;

    procedure InsertTreasAllocAdjUndepositedLine(Var TreasAllocLine: Record "Treasury Allocation Line_NT"; Var LineNo: Integer)
    var
        BankAccLedg2: Record "Bank Account Ledger Entry";
        BankAccLedg: Record "Bank Account Ledger Entry";
        TreasAllocLine2: Record "Treasury Allocation Line_NT";
        DepositBankAcc: Code[20];
        DiffBankAcc: Code[20];
    begin

        FindTenderDepositBankAcc(TreasAllocLine."Store Hierarchy No.", TreasAllocLine."Tender Type", DepositBankAcc, DiffBankAcc);
        // if DiffBankAcc = '' then
        //     Error(Text016, TreasAllocLine."Store Hierarchy No.", TreasAllocLine."Tender Type Name");
        BankAccLedg.SetFilter("Bank Account No.", '%1', DiffBankAcc);
        //BankAccLedg.SetFilter("Store Hierarchy No.", TreasAllocLine."Store Hierarchy No.");
        BankAccLedg.SetFilter("Global Dimension 1 Code", TreasAllocLine."Store Hierarchy No.");
        BankAccLedg.SetFilter("Treasury Statement No.", '');
        BankAccLedg.SetFilter("Treas. Alloc. Line No.", '%1', 0);
        BankAccLedg.SetRange(Open, true);
        if BankAccLedg.FindSet() then
            repeat
                TreasAllocLine2.Init();
                TreasAllocLine2.Validate("Treasury Statement No.", TreasAllocLine."Treasury Statement No.");
                TreasAllocLine2.Validate("Store Hierarchy No.", TreasAllocLine."Store Hierarchy No.");
                TreasAllocLine2."Line No." := LineNo;
                LineNo += 10;
                TreasAllocLine2.Validate("Tender Type", TreasAllocLine."Tender Type");
                TreasAllocLine2.Validate("Currency Code", BankAccLedg."Currency Code");
                TreasAllocLine2.Validate("Bank Account No.", DepositBankAcc);
                TreasAllocLine2."Available To Deposit" := BankAccLedg.Amount;
                TreasAllocLine2."Available To Deposit LCY" := BankAccLedg."Amount (LCY)";
                TreasAllocLine2.Validate("Counted Amount", BankAccLedg.Amount);
                TreasAllocLine2."Adj. Undeposited Amount" := BankAccLedg.Amount;
                TreasAllocLine2."Adj. Undeposited Amt. LCY" := BankAccLedg."Amount (LCY)";
                TreasAllocLine2."Counting Required" := TreasAllocLine."Counting Required";
                TreasAllocLine2."Taken to Bank" := TreasAllocLine."Taken to Bank";
                TreasAllocLine2."Adj. Undeposited Amt. Line" := true;
                TreasAllocLine2."Bag No." := BankAccLedg."External Document No.";
                TreasAllocLine2."Reference Entry No." := BankAccLedg."Entry No.";
                TreasAllocLine2.Insert();
                BankAccLedg2.Get(BankAccLedg."Entry No.");
                BankAccLedg2."Treasury Statement No." := TreasAllocLine2."Treasury Statement No.";
                BankAccLedg2."Treas. Alloc. Line No." := TreasAllocLine2."Line No.";
                BankAccLedg2."Store Hierarchy No." := TreasAllocLine2."Store Hierarchy No.";
                BankAccLedg2.Modify();
            until BankAccLedg.Next() = 0;
    end;

    procedure UpdateStatementCountedAmt(var Statement: Record "LSC Statement")
    var
        StatementLine: Record "LSC Statement Line";
    begin
        StatementLine.SetRange("Statement No.", Statement."No.");
        if StatementLine.FindSet() then
            repeat
                StatementLine.Validate("Counted Amount", StatementLine."Trans. Amount");
                StatementLine.Modify(true);
            until StatementLine.Next() = 0;
    end;

    procedure DeleteZReportLines(LSCStatementLines: Record "LSC Statement Line")
    var
        StmtZLines: Record "Statement Z Report-Lines_NT";
    begin
        StmtZLines.SetFilter("Statement No.", LSCStatementLines."Statement No.");
        StmtZLines.DeleteAll(true);
    end;

    procedure "LookupStatementStaff/POS"(Statement: Record "LSC Statement"; Var "Staff/POSId": Code[20])
    var
        StatementLine: Record "LSC Statement Line";
        TempStaff: Record "LSC Staff" temporary;
        PosTerm: Record "LSC POS Terminal";
        Staff: Record "LSC Staff";
    begin
        case Statement.Method of
            Statement.Method::Staff:
                begin
                    StatementLine.SetFilter("Statement No.", Statement."No.");
                    if StatementLine.FindSet() then
                        repeat
                            if not TempStaff.Get(StatementLine."Staff ID") then
                                if Staff.Get(StatementLine."Staff ID") then begin
                                    TempStaff.Init();
                                    TempStaff.TransferFields(Staff);
                                    TempStaff.Insert();
                                end else begin
                                    TempStaff.Init();
                                    TempStaff.ID := StatementLine."Staff ID";
                                    TempStaff."First Name" := 'Unknown Staff';
                                    TempStaff."Last Name" := 'do not select';
                                    TempStaff.Insert();
                                end;
                        until StatementLine.Next() = 0;
                    if not TempStaff.IsEmpty then TempStaff.FindFirst();
                    if not TempStaff.IsEmpty then
                        if Page.RunModal(0, TempStaff) = Action::LookupOK then
                            "Staff/POSId" := TempStaff.ID;

                    if TempStaff.IsEmpty then
                        if Page.RunModal(0, Staff) = Action::LookupOK then
                            "Staff/POSId" := Staff.ID;

                end;
            Statement.Method::"POS Terminal":
                begin
                    PosTerm.SetFilter("Store No.", Statement."Store No.");
                    if Page.RunModal(0, PosTerm) = Action::LookupOK then
                        "Staff/POSId" := PosTerm."No.";
                end;
        end;
    end;

    procedure InsertStmtZReportLines(var Statement: Record "LSC Statement")
    var
        StmtZLines: Record "Statement Z Report-Lines_NT";
        LineNo: Integer;
        StatementLine: Record "LSC Statement Line";
    begin
        StmtZLines.SetFilter("Statement No.", StatementLine."Statement No.");
        if StmtZLines.FindLast() then
            LineNo := StmtZLines."Line No." + 10000
        else
            LineNo := 10000;
        StatementLine.SetFilter("Statement No.", Statement."No.");
        if StatementLine.FindSet() then
            repeat
                StmtZLines.Reset();
                StmtZLines.SetFilter("Statement No.", StatementLine."Statement No.");
                StmtZLines.SetFilter("Staff ID", StatementLine."Staff ID");
                if not StmtZLines.FindFirst() then begin
                    StmtZLines.Reset();
                    StmtZLines.Init();
                    StmtZLines.Validate("Statement No.", StatementLine."Statement No.");
                    StmtZLines."Line No." := LineNo;
                    LineNo += 10000;
                    StmtZLines.Validate("Staff ID", StatementLine."Staff ID");
                    StmtZLines."Trans. Amount" := StatementLine."Trans. Amount";
                    StmtZLines."Trans. Amount in LCY" := StatementLine."Trans. Amount in LCY";
                    StmtZLines."STMT-Counted Amount" := StatementLine."Counted Amount";
                    StmtZLines."STMT-Counted in LCY" := StatementLine."Counted Amount in LCY";
                    StmtZLines."STMT-Difference Amount" := StatementLine."Difference Amount";
                    StmtZLines."STMT-Difference in LCY" := StatementLine."Difference in LCY";
                    StmtZLines."Z-Difference Amount" := StatementLine."Difference Amount";
                    StmtZLines."Z-Difference in LCY" := StatementLine."Difference in LCY";
                    if StatementLine."Counted Amount" <> 0 then
                        StmtZLines."Real Exchange Rate" := StatementLine."Counted Amount in LCY" / StatementLine."Counted Amount"
                    else
                        StmtZLines."Real Exchange Rate" := 1;
                    StmtZLines."Statement Code" := StatementLine."Staff ID";
                    StmtZLines.Insert(true);
                end else begin
                    StmtZLines."Trans. Amount" += StatementLine."Trans. Amount";
                    StmtZLines."Trans. Amount in LCY" += StatementLine."Trans. Amount in LCY";
                    StmtZLines."STMT-Counted Amount" += StatementLine."Counted Amount";
                    StmtZLines."STMT-Counted in LCY" += StatementLine."Counted Amount in LCY";
                    StmtZLines."STMT-Difference Amount" += StatementLine."Difference Amount";
                    StmtZLines."STMT-Difference in LCY" += StatementLine."Difference in LCY";
                    StmtZLines."Z-Difference Amount" += StatementLine."Difference Amount";
                    StmtZLines."Z-Difference in LCY" += StatementLine."Difference in LCY";
                    StmtZLines.Modify(true);
                end;
            until StatementLine.Next() = 0;
    end;

    procedure TransferZLinesToPosted(StatementNo: Code[20])
    var
        StmtZLines: Record "Statement Z Report-Lines_NT";
        PostedStmtZLines: Record "Posted Stmt. Z Report-Lines_NT";
    begin
        StmtZLines.SetFilter("Statement No.", StatementNo);
        if StmtZLines.FindSet() then
            repeat
                PostedStmtZLines.Init();
                PostedStmtZLines.TransferFields(StmtZLines);
                PostedStmtZLines.Insert(true);
                StmtZLines.Delete(true);
            until StmtZLines.Next() = 0;
    end;

    procedure MergeTenderAfterStatementCalculate(var Statement: Record "LSC Statement")
    var
        StatementLine: Record "LSC Statement Line";
        StatementLine2: Record "LSC Statement Line";
        TenderType: Record "LSC Tender Type";
    begin
        if Statement.Method = Statement.Method::Total then
            exit;
        StatementLine.SetFilter("Statement No.", Statement."No.");
        if StatementLine.FindSet() then
            repeat
                if TenderType.Get(StatementLine."Store No.", StatementLine."Tender Type") then
                    if TenderType."Master Tender" <> '' then begin
                        StatementLine2.SetFilter("Statement No.", StatementLine."Statement No.");
                        StatementLine2.SetFilter("Tender Type", TenderType."Master Tender");
                        case Statement.Method of
                            Statement.Method::Staff:
                                StatementLine2.SetFilter("Staff ID", StatementLine."Staff ID");
                            Statement.Method::"POS Terminal":
                                StatementLine2.SetFilter("POS Terminal No.", StatementLine."POS Terminal No.");
                        end;
                        if StatementLine2.FindFirst() then begin
                            StatementLine2."Counted Amount" += StatementLine."Counted Amount";
                            StatementLine2."Counted Amount in LCY" += StatementLine."Counted Amount in LCY";
                            StatementLine2."Trans. Amount" += StatementLine."Trans. Amount";
                            StatementLine2."Trans. Amount in LCY" += StatementLine."Trans. Amount in LCY";
                            StatementLine2."Difference Amount" += StatementLine."Difference Amount";
                            StatementLine2."Difference in LCY" += StatementLine."Difference in LCY";
                            StatementLine2.Modify();

                            StatementLine."Counted Amount" := 0;
                            StatementLine."Counted Amount in LCY" := 0;
                            StatementLine."Trans. Amount" := 0;
                            StatementLine."Trans. Amount in LCY" := 0;
                            StatementLine."Difference Amount" := 0;
                            StatementLine."Difference in LCY" := 0;
                            StatementLine.Modify();
                        end;
                    end;
            until StatementLine.next = 0;
    end;

    procedure LinesExist(var TreasuryStmt: Record "Treasury Statement_NT"): Boolean
    var
        TreasLines: Record "Treasury Statement Line_NT";
        TreasNetSales: Record "Treasury Stmt. NetSalesLine_NT";
        LineCnt: Integer;
        LineCnt2: Integer;
    begin
        TreasLines.SetFilter("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        LineCnt := TreasLines.Count;
        TreasNetSales.SetFilter("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        LineCnt2 := TreasNetSales.Count;
        exit((LineCnt + LineCnt2) > 0)
    end;

    procedure UpdateZlineSTMTCountedAmount(Var StatementLine: Record "LSC Statement Line"; Var xStatementLine: Record "LSC Statement Line")
    var
        StmtZLines: Record "Statement Z Report-Lines_NT";
    begin
        StmtZLines.Reset();
        StmtZLines.SetFilter("Statement No.", StatementLine."Statement No.");
        StmtZLines.SetFilter("Staff ID", StatementLine."Staff ID");
        if StmtZLines.FindFirst() then begin
            StmtZLines.Validate("STMT-Counted Amount", StmtZLines."STMT-Counted Amount" - xStatementLine."Counted Amount" + StatementLine."Counted Amount");
            //StmtZLines.Validate("STMT-Counted in LCY", StmtZLines."STMT-Counted in LCY" - xStatementLine."Counted Amount in LCY" + StatementLine."Counted Amount in LCY");
            StmtZLines.Modify();
        end;
    end;

    procedure InsertTreasAllocCashRcptLines(var TreasuryStmt: Record "Treasury Statement_NT"; LineNo: Integer; var TempStoresToFilter: Record "LSC Store" temporary)
    var
        TreasAllocationLines: Record "Treasury Allocation Line_NT";
        //TreasuryJnlLine: Record "Treasury Journal Line_NT";
        TenderType: Record "LSC Tender Type";
        DepositBankAcc: Code[20];
        DiffBankAcc: Code[20];
    begin
        // TreasuryJnlLine.SetRange("Posting Date", TreasuryStmt."Trans. Starting Date", TreasuryStmt."Trans. Ending Date");
        // TreasuryJnlLine.SetFilter(Status, '%1', TreasuryJnlLine.Status::Released);
        // TreasuryJnlLine.SetFilter("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
        // TreasuryJnlLine.SetFilter("Entry Type", '%1', TreasuryJnlLine."Entry Type"::"Cash-Receipts");

        //if TreasuryJnlLine.FindSet() then
        TempTreasRcptJnlLine.Reset();
        if TempTreasRcptJnlLine.FindSet() then
            repeat
                TreasAllocationLines.Init();
                TreasAllocationLines.Validate("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
                TreasAllocationLines."Line No." := LineNo;
                LineNo += 10;
                TreasAllocationLines.Validate("Store Hierarchy No.", TreasuryStmt."Store Hierarchy No.");
                TreasAllocationLines.Validate("Tender Type", TempTreasRcptJnlLine."Tender Type");
                TreasAllocationLines."Calculated Amount" := TempTreasRcptJnlLine.Amount;
                TreasAllocationLines."Calculated in LCY" := TempTreasRcptJnlLine."Amount (LCY)";
                TreasAllocationLines."Available To Deposit" := TempTreasRcptJnlLine.Amount;
                TreasAllocationLines."Available To Deposit LCY" := TempTreasRcptJnlLine."Amount (LCY)";

                if TreasAllocationLines."Calculated Amount" <> 0 then
                    TreasAllocationLines."Real Exchange Rate" := TempTreasRcptJnlLine."Amount (LCY)" / TempTreasRcptJnlLine.Amount
                else
                    TreasAllocationLines."Real Exchange Rate" := 1;
                TempStoresToFilter.FindFirst();
                TenderType.Get(TempStoresToFilter."No.", TreasAllocationLines."Tender Type");
                TreasAllocationLines."Counting Required" := TenderType."Counting Required";
                TreasAllocationLines."Taken to Bank" := TenderType."Taken to Bank";
                if not TreasAllocationLines."Counting Required" then begin
                    TreasAllocationLines.Validate("Counted Amount", TempTreasRcptJnlLine.Amount);
                    TreasAllocationLines.Validate("Counted Amount in LCY", TempTreasRcptJnlLine."Amount (LCY)");
                end;

                if TreasAllocationLines."Taken to Bank" then
                    TreasAllocationLines."Posting Date" := WorkDate()
                else
                    TreasAllocationLines."Posting Date" := TreasuryStmt."Posting Date";
                LineNo += 10;

                DepositBankAcc := '';
                if TreasAllocationLines."Taken to Bank" then begin
                    FindTenderDepositBankAcc(TreasAllocationLines."Store Hierarchy No.", TreasAllocationLines."Tender Type", DepositBankAcc, DiffBankAcc);
                    if DepositBankAcc = '' then
                        Error(Text017, TreasAllocationLines."Store Hierarchy No.", TreasAllocationLines."Tender Type Name");
                    TreasAllocationLines.Validate("Bank Account No.", DepositBankAcc);
                end;
                TreasAllocationLines.Insert(true);
            //until TreasuryJnlLine.Next() = 0;
            until TempTreasRcptJnlLine.Next() = 0;
    end;

    local procedure CheckCountedAmt(var TreasuryStmt: Record "Treasury Statement_NT")
    var
        TreasAllocLine: Record "Treasury Allocation Line_NT";
    begin
        TreasAllocLine.SetFilter("Treasury Statement No.", TreasuryStmt."Treasury Statement No.");
        TreasAllocLine.SetFilter("Counted Amount", '<>0');
        if TreasAllocLine.FindSet() then
            repeat
                TreasAllocLine.TestField("Tender Type");
                If TreasAllocLine."Taken to Bank" then
                    TreasAllocLine.TestField("Bank Account No.");
                if not TreasAllocLine."System-Created Entry" then
                    if TreasAllocLine."Taken to Bank" then
                        if TreasAllocLine."Counted Amount" > TreasAllocLine."Available To Deposit" then
                            Error(Text018, TreasAllocLine.FieldCaption("Counted Amount"),
                                           TreasAllocLine.FieldCaption("Available To Deposit"),
                                           TreasAllocLine."Available To Deposit",
                                           TreasAllocLine.FieldCaption("Tender Type"),
                                           TreasAllocLine."Tender Type Name",
                                           TreasAllocLine.FieldCaption("Line No."),
                                           TreasAllocLine."Line No.");

                if not TreasAllocLine."System-Created Entry" then
                    if not TreasAllocLine."Taken to Bank" then
                        if TreasAllocLine."Counted Amount" > TreasAllocLine."Calculated Amount" then
                            Error(Text018, TreasAllocLine.FieldCaption("Counted Amount"),
                                           TreasAllocLine.FieldCaption("Available To Deposit"),
                                           TreasAllocLine."Available To Deposit",
                                           TreasAllocLine.FieldCaption("Tender Type"),
                                           TreasAllocLine."Tender Type Name",
                                           TreasAllocLine.FieldCaption("Line No."),
                                           TreasAllocLine."Line No.");
            until TreasAllocLine.Next() = 0;
    end;

    local procedure UpdateNetSalesLineStatistics(StatmentNo: Code[20]; StoreNo: Code[10]; var TempNetSalesLineToUpd: Record "Treasury Stmt. NetSalesLine_NT" temporary)
    var
        Statement: Record "LSC Statement";
    begin
        Statement.Get(StoreNo, StatmentNo);
        Statement.CalcFields("Sales Amount", "VAT Amount", "Total Discount");
        Statement.CalcFields("Line Discount", "Discount Total Amount", Income, Expenses);

        TempNetSalesLineToUpd."Sales Amount" += Statement."Sales Amount";
        TempNetSalesLineToUpd."VAT Amount" += Statement."VAT Amount";
        TempNetSalesLineToUpd."Total Discount" += Statement."Total Discount";
        TempNetSalesLineToUpd."Line Discount" += Statement."Line Discount";
        TempNetSalesLineToUpd."Discount Total Ammount" += Statement."Discount Total Amount";
        TempNetSalesLineToUpd.Income += Statement.Income;
        TempNetSalesLineToUpd.Expenses += Statement.Expenses;
    end;

    var
        BatchPostingQueue: Record "LSC Batch Posting Queue";
        TempTreasRcptJnlLine: Record "Treasury Journal Line_NT" temporary;
        LastTreasuryJnlLine: Record "Treasury Journal Line_NT";
        LastPostedTreasJnlLine: Record "Posted Treasury Jnl. Line_NT";
        Store: Record "LSC Store";
        BatchPosting: Codeunit "LSC Batch Posting";
        StatementPost: Codeunit "LSC Statement-Post";
        //StatementPost: Codeunit "Statement-Post_NT";
        OpenFromBatch: Boolean;
        BatchPostingStatus: Text[30];
        ExplanationMsg: Text;
        Text000: Label 'Do you want to post the Treasury Statement';
        Text001: Label 'Settings controlling how the Statement %1 is calculated have been changed. Please clear and recalculate the Statement before continuing.', Comment = '%1=Statement."No."';
        Text002: Label 'Safe Managment Check Failed for Statement %1', Comment = '%1=Statement."No."';
        Text003: Label 'There are %1 unresolved serial numbers attached to this statement. They must be resolved before the statement can be posted.';
        Text004: Label 'Statement %1 has already been posted to the Batch Posting Queue.', Comment = '%1=Statement."No."';
        Text005: Label 'Settings controlling how the Treasury Statement %1 is calculated have been changed. Please clear and recalculate the Treasury Statement before continuing.', Comment = '%1=Statement."No."';
        Text006: Label 'Treasury Statement %1 posted successfully.', Comment = '%1=TreasuryStmt."Treasury Statement No."';
        Text007: Label 'DEFAULT';
        Text008: Label 'Default Journal';
        Text009: Label 'No store defined for store hierarchy %1';
        Text010: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
        Text011: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
        Text012: Label 'Nothing to release.';
        Text013: Label '%1 Treasury journal line(s) updated.', Comment = '%1=UpdCnt';
        Text014: Label 'Control account not defined for store hierarchy %1';
        Text015: Label 'Tender Type %1 not defined for store hierarchy %2';
        Text016: label 'Difference Bank Account not defined in Store Hierarchy No. %1 for Tender Type %2';
        Text017: label 'Deposit Bank Account not defined in Store Hierarchy No. %1 for Tender Type %2';
        Text018: Label '%1 can not be more than %2 %3 \%4 : %5 \%6 : %7';
        Text019: Label 'Control account not defined for tender type %1 store hierarchy %2';
        NothingToPostErr: Label 'There is nothing to post.';

}
