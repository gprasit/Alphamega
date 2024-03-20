codeunit 60002 NewCompanySetupMgmt_NT
{
    trigger OnRun()
    begin

    end;

    procedure CreatePreLoadSubJobLines(Var SchJobHdr: Record "LSC Scheduler Job Header")
    var
        SchJobLine: Record "LSC Scheduler Job Line";
        SchSubJob: Record "LSC Scheduler Subjob";
        InsertCnt: Integer;
    begin
        SchSubJob.SetFilter(ID, '%1', 'PRE*');
        if SchSubJob.FindSet() then
            repeat
                SchJobLine.Init();
                SchJobLine.Validate("Scheduler Job ID", SchJobHdr."Job ID");
                SchJobLine.Validate("Subjob ID", SchSubJob.ID);
                SchJobLine.Validate(Enabled, false);
                SchJobLine.Insert(true);
                InsertCnt += 1;
            until SchSubJob.Next() = 0;
        Message('%1 Subjob Line(s) Updated', InsertCnt);
    end;

    procedure AddStoreDimension()
    var
        DimVal: Record "Dimension Value";
        Store: Record "LSC Store";
    begin
        Store.FindSet();
        repeat
            DimVal.Init();
            DimVal.Validate("Dimension Code", 'STORE');
            DimVal.Validate(Code, Store."No.");
            DimVal.Name := Copystr(Store.Name, 1, 50);
            DimVal."Dimension Value Type" := DimVal."Dimension Value Type"::Standard;
            DimVal.Insert(true);

        until Store.next = 0;
    end;

    procedure UpdateTenderType(Var ControlAcc: Record "Treasury Control Account_NT")
    var
        HierarchyDefs: Record "LSC Retail Hierar. Defaults";
        TenderType: Record "LSC Tender Type";
    begin
        HierarchyDefs.SetRange("Table ID", Database::"LSC Store");
        HierarchyDefs.SetRange("Hierarchy Code", ControlAcc."Store Hierarchy No.");
        if HierarchyDefs.FindSet() then
            repeat
                TenderType.SetFilter("Store No.", HierarchyDefs."No.");
                TenderType.FindSet();
                repeat
                    TenderType.Validate("Account No.", ControlAcc."Control Account No.");
                    TenderType.Validate("Difference G/L Acc.", '4913');
                    // //TenderType.Validate("Difference G/L Acc.", '');
                    TenderType.Validate("Taken to Bank", false);
                    TenderType.Validate("Counting Required", true);
                    TenderType.Modify(true);
                until TenderType.Next() = 0;
            until HierarchyDefs.Next() = 0;

    end;

    procedure UpdateTransSalesInvGenProdPostingGrp()
    var
        Item: Record Item;
        Store: Record "LSC Store";
        TransSales: Record "LSC Trans. Sales Entry";
        Cnt: Integer;
    begin

        If TransSales.FindSet() then
            repeat
                cnt := 0;
                if TransSales."Gen. Bus. Posting Group" = '' then begin
                    Store.Get(TransSales."Store No.");
                    if Store."Store Gen. Bus. Post. Gr." <> '' then
                        TransSales.Validate("Gen. Bus. Posting Group", Store."Store Gen. Bus. Post. Gr.")
                    else
                        TransSales.Validate("Gen. Bus. Posting Group", 'NATIONAL');
                    Cnt += 1;
                end;
                if TransSales."Gen. Prod. Posting Group" = '' then begin
                    TransSales.Validate("Gen. Prod. Posting Group", 'RETAIL');
                    Cnt += 1;
                end;
                if cnt > 0 then
                    TransSales.Modify();
            until TransSales.Next() = 0;
        if Item.FindSet() then
            repeat
                if Item."Inventory Posting Group" = '' then begin
                    Item.Validate("Inventory Posting Group", 'RETAIL');
                    Item.Modify();
                end;
            until item.Next() = 0;
        Message('Job Done.');
    end;

    procedure UpdateItemUOM()
    var
        Item: Record Item;
        IUOM: Record "Item Unit of Measure";
        UOM: Record "Unit of Measure";
        NoOfRecsInserted: Integer;
    begin
        Item.SetFilter("No.", 'BR*');
        if Item.FindSet() then
            repeat
                if not UOM.Get(Item."Base Unit of Measure") then begin
                    UOM.Init();
                    UOM.Validate(Code, item."Base Unit of Measure");
                    UOM.Validate(Description, Item."Base Unit of Measure");
                    UOM.Insert();
                    NoOfRecsInserted += 1;
                end;
                If not IUOM.Get(Item."No.", Item."Base Unit of Measure") then begin
                    IUOM.Init();
                    IUOM.Validate("Item No.", item."No.");
                    IUOM.Validate(Code, Item."Base Unit of Measure");
                    IUOM.Validate("Qty. per Unit of Measure", 1);
                    IUOM.Insert();
                    NoOfRecsInserted += 1;
                end;
            until Item.Next() = 0;

        // Item.SetFilter("No.", 'B*');
        // if Item.FindSet() then
        //     repeat
        //         if not UOM.Get(Item."Base Unit of Measure") then begin
        //             UOM.Init();
        //             UOM.Validate(Code, item."Base Unit of Measure");
        //             UOM.Validate(Description, Item."Base Unit of Measure");
        //             UOM.Insert();
        //             NoOfRecsInserted += 1;
        //         end;
        //         If not IUOM.Get(Item."No.", Item."Base Unit of Measure") then begin
        //             IUOM.Init();
        //             IUOM.Validate("Item No.", item."No.");
        //             IUOM.Validate(Code, Item."Base Unit of Measure");
        //             IUOM.Validate("Qty. per Unit of Measure", 1);
        //             IUOM.Insert();
        //             NoOfRecsInserted += 1;
        //         end;
        //     until Item.Next() = 0;
        Message('%1 Record(s) inserted.', NoOfRecsInserted);
    end;

    procedure MarkTendersCountingRequired()
    var
        TenderType: Record "LSC Tender Type";
    begin
        if TenderType.FindSet() then
            repeat
                TenderType.Validate("Counting Required", true);
                TenderType.Modify();
            until TenderType.Next() = 0;
    end;

    var
        LSC: Record "LSC Trans. Sales Entry";
        myInt: Integer;
}