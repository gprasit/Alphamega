codeunit 60201 "eCom-Import Web Item_NT"
{
    trigger OnRun()
    var

    begin
        ImportWebItem();
        ImportWebSpecialOfferItem();
        ImportWebItemInventory();
        ImportWebSpecialOfferItem();
        ImportFoodyItem();
    end;

    local procedure ImportWebItem()
    var
        CurrWebItem: Record "Aging Band Buffer";
        Item2: Record Item;
        Item: Record Item;
        iFile: File;
        iStream: InStream;
        ItemNo: Code[20];
        i: Integer;
        AddFileName: Text;
        ESLDesc: Text;
        FileName: Text;
        iLine: Text;
        DotNetString: TextBuilder;
    begin
        FileName := 'c:\ncr\Nav2016\LSECOMM.TXT';
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;
        iFile.CREATEINSTREAM(iStream);
        i := 0;

        Item.SetCurrentKey("Web Special Offer");
        Item.SETRANGE("Web Special Offer", TRUE);
        IF Item.FINDSET THEN
            REPEAT
                Item2 := Item;
                Item2."Web Special Offer" := FALSE;
                Item2.MODIFY;
            UNTIL Item.NEXT = 0;

        Item.SETRANGE("Web Special Offer");
        Item.SETCURRENTKEY("No.");
        Item.SETRANGE("Every Day Low Price", TRUE);
        IF Item.FINDSET THEN
            REPEAT
                Item2 := Item;
                Item2."Every Day Low Price" := FALSE;
                Item2.MODIFY;
            UNTIL Item.NEXT = 0;

        Item.SETRANGE("Every Day Low Price");
        Item.SETCURRENTKEY("Web Item");
        Item.SETRANGE("Web Item", TRUE);
        IF Item.FINDSET THEN
            REPEAT
                CurrWebItem."Currency Code" := Item."No.";
                CurrWebItem.INSERT;
            UNTIL Item.NEXT = 0;

        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            ItemNo := COPYSTR(iLine, 1, 15);
            IF Item.GET(ItemNo) THEN BEGIN
                Item."Web Item Status" := Item."Web Item Status"::" ";
                IF CurrWebItem.GET(Item."No.") THEN
                    CurrWebItem.DELETE
                ELSE
                    Item."Web Item Status" := Item."Web Item Status"::New;
                Item."Web Item" := COPYSTR(iLine, 104, 1) = '1';
                IF NOT Item."Web Item" THEN
                    Item."Web Item Status" := Item."Web Item Status"::Inactive;
                EVALUATE(Item."Web Weight", COPYSTR(iLine, 16, 5));
                Item."Web Weight" /= 1000;
                Item."Web Weight Item" := COPYSTR(iLine, 102, 1) = '1';
                Item."Every Day Low Price" := COPYSTR(iLine, 103, 1) = '1';
                Item."Heavy Item" := COPYSTR(iLine, 21, 1) = '1';

                ESLDesc := COPYSTR(iLine, 113, 8);
                ESLDesc := DELCHR(ESLDesc, '<>', ' ');
                ESLDesc := DELCHR(ESLDesc, '=', ' ');


                //mk..
                Item."Comparison UOM" := '001';

                EVALUATE(Item."Actual Weight", COPYSTR(iLine, 108, 5));
                //..mk

                Item."ESL Description" := ESLDesc;
                IF STRLEN(iLine) > 120 THEN
                    Item."Web Always On Stock" := COPYSTR(iLine, 121, 1) = '1';
                IF STRLEN(iLine) > 121 THEN
                    Item."Web Special Offer" := COPYSTR(iLine, 122, 1) = '1';
                Item.MODIFY;
            END;
        END;

        iFile.CLOSE;

        IF CurrWebItem.FINDFIRST THEN
            REPEAT
                Item.GET(CurrWebItem."Currency Code");
                Item."Web Item" := FALSE;
                Item."Web Item Status" := Item."Web Item Status"::Deleted;
                Item.MODIFY(TRUE);
            UNTIL CurrWebItem.NEXT = 0;

        AddFileName := FORMAT(TODAY);
        AddFileName := DELCHR(AddFileName, '=', '/');
        AddFileName := DELCHR(AddFileName, '=', '/') + DELCHR(FORMAT(TIME), '=', ':');
        AddFileName := DELCHR(AddFileName, '=', ' ');
        File.Copy(FileName, 'c:\ncr\NAV2016\Processed\' + AddFileName + '_LSECOMM.TXT');
        ERASE(FileName);

        // CheckInventory(); Commented in NAV server 67

    end;

    local procedure ImportWebSpecialOfferItem()
    var
        Item: Record Item;
        SItem: Record Item;
        SpecialOfferItem: Record "eCom_Special Offer Item_NT";
        FileMgt: Codeunit "File Management";
        iFile: File;
        iStream: InStream;
        i: Integer;
        AddFileName: Text;
        FileName: Text;
        iLine: Text;
    begin
        FileName := 'c:\ncr\Nav2016\lsecspe.txt';
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;
        iFile.CREATEINSTREAM(iStream);
        i := 0;

        SpecialOfferItem.RESET;
        SpecialOfferItem.DELETEALL;

        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            CLEAR(SpecialOfferItem);
            SpecialOfferItem."Item No." := COPYSTR(iLine, 1, 15);
            SpecialOfferItem."Item Description" := COPYSTR(iLine, 16, 36);
            SpecialOfferItem."Offer Item No." := COPYSTR(iLine, 52, 15);
            SpecialOfferItem."Offer Item Description" := COPYSTR(iLine, 67, 36);
            IF NOT SpecialOfferItem.INSERT THEN
                SpecialOfferItem.MODIFY;
            IF Item.GET(SpecialOfferItem."Item No.") THEN
                IF SItem.GET(SpecialOfferItem."Offer Item No.") THEN BEGIN
                    SItem."Web Weight Item" := Item."Web Weight Item";
                    SItem."Web Weight" := Item."Web Weight";
                    SItem.MODIFY;
                END;
        END;

        iFile.CLOSE;

        AddFileName := FORMAT(TODAY);
        AddFileName := DELCHR(AddFileName, '=', '/');
        AddFileName := DELCHR(AddFileName, '=', '/') + DELCHR(FORMAT(TIME), '=', ':');
        AddFileName := DELCHR(AddFileName, '=', ' ');

        //_File.Copy(FileName, 'c:\ncr\NAV2016\Processed\' + AddFileName + '_LSECSPE.TXT');BC Upgrade
        FileMgt.CopyServerFile(FileName, 'c:\ncr\NAV2016\Processed\' + AddFileName + '_LSECSPE.TXT', true);//BC Upgrade
        ERASE(FileName);
    end;

    local procedure ImportWebItemInventory()
    var
        Item: Record Item;
        WebItemInventory: Record "eCom_Item Inventory_NT";
        FileMgt: Codeunit "File Management";
        iFile: File;
        iStream: InStream;
        CheckQty: Decimal;
        i: Integer;
        AddFileName: Text;
        FileName: Text;
        iLine: Text;
    begin
        FileName := 'c:\ncr\Nav2016\LSESTK.TXT';
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;
        iFile.CREATEINSTREAM(iStream);
        CLEAR(WebItemInventory);
        WebItemInventory.DELETEALL;
        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            CLEAR(WebItemInventory);
            WebItemInventory."Location Code" := GetStoreNo(COPYSTR(iLine, 1, 2));
            IF WebItemInventory."Location Code" <> '' THEN BEGIN
                WebItemInventory."Item No." := COPYSTR(iLine, 3, 15);
                EVALUATE(WebItemInventory.Inventory, COPYSTR(iLine, 18, 9));
                WebItemInventory.Inventory /= 100;
                WebItemInventory.INSERT;
            END;
        END;

        iFile.Close();

        AddFileName := Format(Today);
        AddFileName := DelChr(AddFileName, '=', '/');
        AddFileName := DelChr(AddFileName, '=', '/') + DelChr(Format(Time), '=', ':');
        AddFileName := DelChr(AddFileName, '=', ' ');
        //_File.Copy(FileName, 'c:\ncr\NAV2016\Processed\' + AddFileName + '_LSESTK.TXT');//BC Upgrade
        FileMgt.CopyServerFile(FileName, 'c:\ncr\NAV2016\Processed\' + AddFileName + '_LSESTK.TXT', true);//BC Upgrade
        Erase(FileName);

    end;

    local procedure ImportFoodyItem()
    var
        CurrFoodyItem: Record "Aging Band Buffer" temporary;
        Item: Record Item;
        FileMgt: Codeunit "File Management";
        iFile: File;
        iStream: InStream;
        ItemNo: Code[20];
        i: Integer;
        AddFileName: Text;
        FileName: Text;
        iLine: Text;
    begin
        FileName := 'c:\ncr\Nav2016\lsfoody.TXT';
        if not iFile.Open(FileName) then
            exit;
        iFile.CreateInStream(iStream);
        i := 0;

        Item.SetCurrentKey("Foody Item");
        Item.SetRange("Foody Item", true);
        if Item.FindSet() then
            REPEAT
                CurrFoodyItem."Currency Code" := Item."No.";
                CurrFoodyItem.INSERT;
            UNTIL Item.NEXT = 0;

        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            ItemNo := COPYSTR(iLine, 1, 15);
            IF Item.GET(ItemNo) THEN BEGIN
                Item."Foody Item" := COPYSTR(iLine, 104, 1) = '1';
                Item.MODIFY(TRUE);
                IF Item."Foody Item" THEN
                    IF CurrFoodyItem.GET(Item."No.") THEN
                        CurrFoodyItem.DELETE;
            END;
        END;

        iFile.CLOSE;

        IF CurrFoodyItem.FINDFIRST THEN
            REPEAT
                Item.GET(CurrFoodyItem."Currency Code");
                Item."Foody Item" := FALSE;
                Item.MODIFY(TRUE);
            UNTIL CurrFoodyItem.NEXT = 0;

        AddFileName := FORMAT(TODAY);
        AddFileName := DELCHR(AddFileName, '=', '/');
        AddFileName := DELCHR(AddFileName, '=', '/') + DELCHR(FORMAT(TIME), '=', ':');
        AddFileName := DELCHR(AddFileName, '=', ' ');
        //_File.Copy(FileName, 'c:\ncr\NAV2016\Processed\' + AddFileName + '_lsfoody.TXT');
        FileMgt.CopyServerFile(FileName, 'c:\ncr\NAV2016\Processed\' + AddFileName + '_lsfoody.TXT', true);//BC Upgrade
        ERASE(FileName);

    end;

    local procedure GetStoreNo(StoreNo: Code[10]): Code[10]
    begin
        CASE StoreNo OF
            'EC':
                EXIT('0001');
            'DS':
                EXIT('0002');
            'LA':
                EXIT('0003');
            'LI':
                EXIT('0004');
            'PF':
                EXIT('0005');
            'DF':
                EXIT('0006');
            'LC':
                EXIT('0007');
            'SK':
                EXIT('0008');
            'KO':
                EXIT('0009');
            'KA':
                EXIT('0010');
            'LM':
                EXIT('0011');
            'LT':
                EXIT('0012');
            'KI':
                EXIT('0013');
            'LK':
                EXIT('0014');
            'PO':
                EXIT('0015');
            'AF':
                EXIT('0016');
        END;
    end;

    procedure SkipInventoryCheck2(Item: Record Item): Boolean
    begin
        if Item."Web Always On Stock" then
            exit(true);
        exit((((Item."LSC Item Family Code" IN ['001', '002', '003', '004', '005']) OR (Item."LSC Retail Product Code" = 'O54'))));
    end;
}
