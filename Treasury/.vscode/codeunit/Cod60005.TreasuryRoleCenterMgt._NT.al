codeunit 60005 "Treasury Role Center Mgt._NT"
{
    Permissions = tabledata "Treasury Cue_NT" = RMI;
    procedure TreasuryStmtCount(Status: Option): Integer
    var
        PostedTreasStmt: Record "Posted Treasury Statement_NT";
        RetailUser: Record "LSC Retail User";
        TreasStatement: Record "Treasury Statement_NT";
    begin
        case Status of
            0:
                begin
                    if RetailUser.Get(UserId) then
                        if RetailUser."Store Hierarchy No." <> '' then
                            TreasStatement.SetRange("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
                    TreasStatement.SetRange(Status, Status);
                    Exit(TreasStatement.Count);
                end;
            1:
                begin
                    if RetailUser.Get(UserId) then
                        if RetailUser."Store Hierarchy No." <> '' then
                            PostedTreasStmt.SetRange("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
                    Exit(PostedTreasStmt.Count);
                end;
        end;
    end;

    procedure TreasuryStatementList(Status: Option): Integer
    var
        PostedTreasStmt: Record "Posted Treasury Statement_NT";
        RetailUser: Record "LSC Retail User";
        TreasStatement: Record "Treasury Statement_NT";
    begin
        case Status of
            0:
                begin
                    TreasStatement.FilterGroup(2);
                    if RetailUser.Get(UserId) then
                        if RetailUser."Store Hierarchy No." <> '' then
                            TreasStatement.SetRange("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
                    TreasStatement.SetRange(Status, Status);
                    TreasStatement.FilterGroup(0);
                    Page.RunModal(0, TreasStatement)
                end;
            1:
                begin
                    PostedTreasStmt.FilterGroup(2);
                    if RetailUser.Get(UserId) then
                        if RetailUser."Store Hierarchy No." <> '' then
                            PostedTreasStmt.SetRange("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
                    PostedTreasStmt.FilterGroup(0);
                    Page.RunModal(0, PostedTreasStmt)
                end;
        end;
    end;

    procedure FilterStatements(Var Statement: Record "LSC Statement")
    var
        RetailUser: Record "LSC Retail User";
        TempStores: Record "LSC Store" temporary;
        TreasuryMgt: Codeunit "Treasury Management_NT";
    begin
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then begin
                TreasuryMgt.AddStoresFromHierarchy(RetailUser."Store Hierarchy No.", TempStores);
                MarkStatements(Statement, TempStores);
            end;
    end;

    local procedure MarkStatements(var Statement: Record "LSC Statement"; Var TempStores: Record "LSC Store" temporary)
    var
        Statement2: Record "LSC Statement";
    begin
        TempStores.Reset();
        Statement.Reset();
        if TempStores.FindSet() then
            repeat
                Statement2.SetFilter("Store No.", TempStores."No.");
                if Statement2.FindSet() then
                    repeat
                        if not Statement2.Mark() then
                            Statement2.Mark(true);
                    until Statement2.Next() = 0;
            until TempStores.Next() = 0;
        Statement2.SetRange("Store No.");
        Statement2.MarkedOnly(true);
        Statement.Copy(Statement2);
        if Statement.FindFirst() then;
    end;

    procedure FilterPostedStatements(Var PostedStatement: Record "LSC Posted Statement")
    var
        RetailUser: Record "LSC Retail User";
        TempStores: Record "LSC Store" temporary;
        TreasuryMgt: Codeunit "Treasury Management_NT";
    begin
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then begin
                TreasuryMgt.AddStoresFromHierarchy(RetailUser."Store Hierarchy No.", TempStores);
                MarkPostedStatements(PostedStatement, TempStores);
            end;
    end;

    local procedure MarkPostedStatements(var PostedStatement: Record "LSC Posted Statement"; Var TempStores: Record "LSC Store" temporary)
    var
        PostedStatement2: Record "LSC Posted Statement";
    begin
        TempStores.Reset();
        PostedStatement.Reset();
        if TempStores.FindSet() then
            repeat
                PostedStatement2.SetFilter("Store No.", TempStores."No.");
                if PostedStatement2.FindSet() then
                    repeat
                        if not PostedStatement2.Mark() then
                            PostedStatement2.Mark(true);
                    until PostedStatement2.Next() = 0;
            until TempStores.Next() = 0;
        PostedStatement2.SetRange("Store No.");
        PostedStatement2.MarkedOnly(true);
        PostedStatement.Copy(PostedStatement2);
        if PostedStatement.FindFirst() then;
    end;

    procedure TreasuryJournalCount(EntryType: enum "Treas. Jnl. Entry Type_NT"; StoreHierarchyNo: code[10]): Integer
    var
        TreasJnl: Record "Treasury Journal Line_NT";
    begin
        if StoreHierarchyNo <> '' then
            TreasJnl.SetFilter("Store Hierarchy No.", StoreHierarchyNo);
        TreasJnl.SetFilter("Entry Type", '%1', EntryType);
        Exit(TreasJnl.Count);
    end;

    procedure TreasuryJournalDrilldown(EntryType: enum "Treas. Jnl. Entry Type_NT")
    var
        RetailUser: Record "LSC Retail User";
        TreasJnlBatch: Record "Treasury Journal Batch_NT";
    begin
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then
                TreasJnlBatch.SetFilter("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
        TreasJnlBatch.SetFilter("Jnl. Entry Type", '%1', EntryType);
        Page.RunModal(0, TreasJnlBatch);
    end;
}
