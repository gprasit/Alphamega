codeunit 60203 "eCom-Data Exchange Mgmt_NT"
{
    TableNo = "LSC Scheduler Job Header";
    trigger OnRun()
    var
        Barcode: Record "LSC Barcodes";
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SpecialOfferItem: Record "eCom_Special Offer Item_NT";
        Store: Record "LSC Store";
        WebItemSubstitution: Record "eCom_Web Item Substitution_NT";
        PickOrder: XmlPort "eCom-Pick Order_NT";
        StoreData: XmlPort "eCom-Store Data_NT";
        StoreItemData: XmlPort "eCom-Store Item Data_NT";
        oFile: File;
        oStream: OutStream;
        NL: array[2] of char;
        myInt: Integer;
        FileName: Text;
        tmpFileName: Text;
    begin
        IF Text = '' THEN
            EXIT;

        NL[1] := 13;
        NL[2] := 10;
        NewLine := FORMAT(NL[1]) + FORMAT(NL[2]);

        CASE Integer OF
            1:
                BEGIN
                    tmpFileName := Text + '\TEMP\' + 'ITEM_DATA_' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + '_' + FORMAT(GetTime, 0, '<Hours24><Minutes,2><Seconds,2>' + '.XML');
                    FileName := Text + '\' + 'ITEM_DATA_' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + '_' + FORMAT(GetTime, 0, '<Hours24><Minutes,2><Seconds,2>' + '.XML');
                    oFile.CREATE(tmpFileName);
                    oFile.CREATEOUTSTREAM(oStream);
                    oStream.WRITETEXT('<?xml version="1.0" encoding="UTF-8" standalone="no"?>' + NewLine);

                    oStream.WRITETEXT('<ItemData>' + NewLine);
                    oStream.WRITETEXT('  <File_Created_Date>' + FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>') + '</File_Created_Date>' + NewLine);
                    oStream.WRITETEXT('  <File_Created_Time>' + FORMAT(Time) + '</File_Created_Time>' + NewLine);
                    oStream.WRITETEXT('  <Sending_System>Dymanics NAV</Sending_System>' + NewLine);
                    oStream.WRITETEXT('  <Receiving_System>CUBLink</Receiving_System>' + NewLine);
                    oStream.WRITETEXT('  <Type>PARTLY</Type>' + NewLine);
                    oStream.WRITETEXT('  <Items>' + NewLine);
                    Item.SETCURRENTKEY("Web Item");
                    Item.SETRANGE("Web Item", TRUE);
                    Item.FINDSET;
                    Barcode.SETCURRENTKEY("Item No.");
                    REPEAT
                        WriteItem(oStream, Item, Item."No.", Item."No.");
                        Barcode.SETRANGE("Item No.", Item."No.");
                        IF Barcode.FINDSET THEN
                            REPEAT
                                WriteItem(oStream, Item, Item."No.", Barcode."Barcode No.");
                            UNTIL Barcode.NEXT = 0;
                    UNTIL Item.NEXT = 0;

                    CLEAR(Item);
                    IF SpecialOfferItem.FINDFIRST THEN
                        REPEAT
                            Item.GET(SpecialOfferItem."Offer Item No.");
                            IF NOT Item."Web Item" THEN BEGIN
                                WriteItem(oStream, Item, Item."No.", Item."No.");
                                Barcode.SETRANGE("Item No.", Item."No.");
                                IF Barcode.FINDSET THEN
                                    REPEAT
                                        WriteItem(oStream, Item, Item."No.", Barcode."Barcode No.");
                                    UNTIL Barcode.NEXT = 0;
                            END;
                        UNTIL SpecialOfferItem.NEXT = 0;

                    CLEAR(Item);
                    IF WebItemSubstitution.FINDFIRST THEN
                        REPEAT
                            Item.GET(WebItemSubstitution."Web Item No.");
                            IF NOT Item."Web Item" THEN BEGIN
                                WriteItem(oStream, Item, Item."No.", Item."No.");
                                Barcode.SETRANGE("Item No.", Item."No.");
                                IF Barcode.FINDSET THEN
                                    REPEAT
                                        WriteItem(oStream, Item, Item."No.", Barcode."Barcode No.");
                                    UNTIL Barcode.NEXT = 0;
                            END;
                        UNTIL WebItemSubstitution.NEXT = 0;

                    oStream.WRITETEXT('  </Items>' + NewLine);
                    oStream.WRITETEXT('</ItemData>' + NewLine);
                    //ItemData.SetFilter("Text 2");
                    //ItemData.SETDESTINATION(oStream);
                    //ItemData.EXPORT;
                    oFile.CLOSE;
                    FILE.RENAME(tmpFileName, FileName);
                    //ERASE(tmpFileName);
                END;
            2:
                BEGIN
                    Store.SETFILTER("No.", '9998|9999');
                    Store.FINDFIRST;
                    REPEAT
                        Item.SETCURRENTKEY("Web Item");
                        Item.SETRANGE("Web Item", TRUE);
                        //IF "Text 2" <> '' THEN
                        //  Item.SETFILTER("No.","Text 2");
                        Barcode.SETCURRENTKEY("Item No.");
                        IF Item.FINDFIRST THEN
                            REPEAT
                                StoreItemData.InsertRec(Item."No.", Store."No.");
                                Barcode.SETRANGE("Item No.", Item."No.");
                                IF Barcode.FINDSET THEN
                                    REPEAT
                                        StoreItemData.InsertRec(Barcode."Barcode No.", Store."No.");
                                    UNTIL Barcode.NEXT = 0;
                            UNTIL Item.NEXT = 0;

                        CLEAR(Item);
                        IF SpecialOfferItem.FINDFIRST THEN
                            REPEAT
                                Item.GET(SpecialOfferItem."Offer Item No.");
                                IF NOT Item."Web Item" THEN BEGIN
                                    StoreItemData.InsertRec(Item."No.", Store."No.");
                                    Barcode.SETRANGE("Item No.", Item."No.");
                                    IF Barcode.FINDSET THEN
                                        REPEAT
                                            StoreItemData.InsertRec(Barcode."Barcode No.", Store."No.");
                                        UNTIL Barcode.NEXT = 0;
                                END;
                            UNTIL SpecialOfferItem.NEXT = 0;

                        CLEAR(Item);
                        IF WebItemSubstitution.FINDFIRST THEN
                            REPEAT
                                Item.GET(WebItemSubstitution."Web Item No.");
                                IF NOT Item."Web Item" THEN BEGIN
                                    StoreItemData.InsertRec(Item."No.", Store."No.");
                                    Barcode.SETRANGE("Item No.", Item."No.");
                                    IF Barcode.FINDSET THEN
                                        REPEAT
                                            StoreItemData.InsertRec(Barcode."Barcode No.", Store."No.");
                                        UNTIL Barcode.NEXT = 0;
                                END;
                            UNTIL WebItemSubstitution.NEXT = 0;
                    UNTIL Store.NEXT = 0;

                    tmpFileName := Text + '\TEMP\' + 'STORE_ITEMS_' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + '_' + FORMAT(GetTime, 0, '<Hours24><Minutes,2><Seconds,2>' + '.XML');
                    FileName := Text + '\' + 'STORE_ITEMS_' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + '_' + FORMAT(GetTime, 0, '<Hours24><Minutes,2><Seconds,2>' + '.XML');
                    oFile.CREATE(tmpFileName);
                    oFile.CREATEOUTSTREAM(oStream);
                    StoreItemData.SETDESTINATION(oStream);
                    StoreItemData.EXPORT;
                    oFile.CLOSE;
                    FILE.RENAME(tmpFileName, FileName);
                    //ERASE(tmpFileName);
                END;
            3:
                BEGIN
                    tmpFileName := Text + '\TEMP\' + 'STORES_' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + '_' + FORMAT(GetTime, 0, '<Hours24><Minutes,2><Seconds,2>' + '.XML');
                    FileName := Text + '\' + 'STORES_' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + '_' + FORMAT(GetTime, 0, '<Hours24><Minutes,2><Seconds,2>' + '.XML');
                    oFile.CREATE(tmpFileName);
                    oFile.CREATEOUTSTREAM(oStream);
                    //StoreData.SetFilter("Text 2");
                    StoreData.SETDESTINATION(oStream);
                    StoreData.EXPORT;
                    oFile.CLOSE;
                    FILE.RENAME(tmpFileName, FileName);
                    //ERASE(tmpFileName);
                END;
            else
                Error(lblErr001);

        end;
    end;

    procedure OpenFile(Path: Text)
    begin
        iFile.OPEN(Path);
        iFile.CREATEINSTREAM(iStream);
    end;

    procedure ImportJBAItems(VAR JBAItem: Record "eCom_JBA Item 2_NT")
    begin
        JBAItem.DELETEALL;
        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            CLEAR(JBAItem);
            JBAItem."Item Code" := COPYSTR(iLine, 3, 15);
            JBAItem."Barcode No." := COPYSTR(iLine, 18, 15);
            JBAItem.Description := COPYSTR(iLine, 51, 36);
            JBAItem."Item Vendor No." := COPYSTR(iLine, 90, 3);
            JBAItem."Section Code" := COPYSTR(iLine, 93, 2);
            JBAItem."POS Item Type" := COPYSTR(iLine, 95, 1);
            JBAItem."Brand Code" := COPYSTR(iLine, 96, 2);
            JBAItem.Department := COPYSTR(iLine, 98, 2);
            JBAItem."VAT Code" := COPYSTR(iLine, 48, 3);
            JBAItem."Category Code" := COPYSTR(iLine, 100, 3);
            JBAItem."Vendor Status" := COPYSTR(iLine, 109, 1);
            JBAItem."Vendor Location" := COPYSTR(iLine, 110, 1);
            JBAItem.INSERT;
        END;
    end;

    procedure ImportItemParameter(VAR ItemParameter: Record "eCom_Item Parameter_NT")
    begin
        ItemParameter.DELETEALL;
        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            CLEAR(ItemParameter);
            ItemParameter.Type := COPYSTR(iLine, 3, 4);
            ItemParameter."Search Key" := COPYSTR(iLine, 7, 10);
            ItemParameter.Description := COPYSTR(iLine, 17, 100);
            ItemParameter.INSERT;
        END;
    end;

    local procedure WriteItem(VAR oStream: OutStream; Item: Record Item; ItemNo: Code[20]; BarcodeNo: Code[20])
    var
        Division: Record "LSC Division";
        ItemCat: Record "Item Category";
        ProductGroup: Record "LSC Retail Product Group";
        String: TextBuilder;
    begin

        IF NOT Division.GET(Item."LSC Division Code") THEN
            CLEAR(Division);
        IF NOT ItemCat.GET(Item."Item Category Code") THEN
            CLEAR(ItemCat);
        /*BC Upgrade
    IF NOT ProductGroup.GET(Item."Item Category Code", Item."Product Group Code") THEN
        CLEAR(ProductGroup);
        */
        IF NOT ProductGroup.GET(Item."Item Category Code", Item."LSC Retail Product Code") THEN
            CLEAR(ProductGroup);
        oStream.WRITETEXT('    <Item>' + NewLine);
        oStream.WRITETEXT('      <Item_ID>' + BarcodeNo + '</Item_ID>' + NewLine);
        Clear(String);
        String.Append(Item.Description);
        String.Replace('&', '&amp;');
        Item.Description := String.ToText();
        oStream.WRITETEXT('      <Description>' + DELCHR(Item.Description, '<>', ' ') + '</Description>' + NewLine);
        oStream.WRITETEXT('      <Commodity_Group_ID>' + Item."Item Category Code" + '</Commodity_Group_ID>' + NewLine);
        //String := ItemCat.Description; BC Upgrade
        Clear(String);
        String.Append(ItemCat.Description);
        String.Replace('&', '&amp;');
        ItemCat.Description := String.ToText();
        oStream.WRITETEXT('      <Commodity_Group_Name>' + DELCHR(ItemCat.Description, '<>', ' ') + '</Commodity_Group_Name>' + NewLine);
        oStream.WRITETEXT('      <Head_Group_ID>' + Item."LSC Division Code" + '</Head_Group_ID>' + NewLine);

        Clear(String);
        String.Append(Division.Description);
        String.Replace('&', '&amp;');
        Division.Description := String.ToText();
        oStream.WRITETEXT('      <Head_Group_Name>' + DELCHR(Division.Description, '<>', ' ') + '</Head_Group_Name>' + NewLine);
        oStream.WRITETEXT('      <Sub_Group_ID>' + Item."LSC Retail Product Code" + '</Sub_Group_ID>' + NewLine);

        Clear(String);
        String.Append(ProductGroup.Description);
        String.Replace('&', '&amp;');
        ProductGroup.Description := String.ToText();
        oStream.WRITETEXT('      <Sub_Group_Name>' + DELCHR(ProductGroup.Description, '<>', ' ') + '</Sub_Group_Name>' + NewLine);
        oStream.WRITETEXT('      <Package_Size>1</Package_Size>' + NewLine);
        oStream.WRITETEXT('      <FE>' + ItemNo + '</FE>' + NewLine);
        oStream.WRITETEXT('      <Supplier></Supplier>' + NewLine);
        oStream.WRITETEXT('      <Country_Of_Origin></Country_Of_Origin>' + NewLine);
        //IF Item."Scale Item" THEN BEGIN
        IF Item."Web Weight Item" AND (Item."Web Weight" <> 0) THEN BEGIN
            oStream.WRITETEXT('      <Weight_Item>TRUE</Weight_Item>' + NewLine);
            oStream.WRITETEXT('      <Weight_Unit>KILO</Weight_Unit>' + NewLine);
        END ELSE BEGIN
            oStream.WRITETEXT('      <Weight_Item>FALSE</Weight_Item>' + NewLine);
            oStream.WRITETEXT('      <Weight_Unit></Weight_Unit>' + NewLine);
        END;
        oStream.WRITETEXT('      <Dimensions></Dimensions>' + NewLine);
        oStream.WRITETEXT('      <Weight>' + FORMAT(Item."Web Weight") + '</Weight>' + NewLine);
        oStream.WRITETEXT('      <AgeControl></AgeControl>' + NewLine);
        oStream.WRITETEXT('      <Brand_Name></Brand_Name>' + NewLine);
        oStream.WRITETEXT('      <Status>NEW</Status>' + NewLine);
        oStream.WRITETEXT('      <Image_Url>https://alphamega.com.cy/Admin/Public/GetImage.ashx?Width=100&amp;Height=100&amp;Image=/Files/Images/Ecom/Products/' + Item."No." + '.jpg&amp;Format=png&amp;Crop=0</Image_Url>' + NewLine);
        //oStream.WRITETEXT('      <Image_Url>http://alphamega.staging.dynamicweb-cms.com/Admin/Public/GetImage.ashx?Width=100&amp;Height=100&amp;Image=/Files/Images/Ecom/Products/' + Item."No." + '.jpg</Image_Url>' + NewLine);
        //oStream.WRITETEXT('      <Image_Url>http://alphamega.staging.dynamicweb-cms.com/Admin/Public/GetImage.ashx?Width=100&amp;Height=100&amp;Crop=5&amp;BackgroundColor=&DoNotUpscale=True&FillCanvas=True&Image=/Files/Images/Ecom/Products/' +
        //  Item."No." + '.jpg&AlternativeImage=/Images/missing_image.jpg</Image_Url>' + NewLine);
        //oStream.WRITETEXT('      <Stopped></Stopped>' + NewLine);
        oStream.WRITETEXT('    </Item>' + NewLine);
    end;

    LOCAL procedure GetTime(): Time
    begin
        EXIT(TIME);
    end;

    var
        NewLine: Text;
        iFile: File;
        iStream: InStream;
        iLine: Text;
        lblErr001: Label 'Invalid Parameter in Integer';
}
