report 60101 "ESL_Export ESL_NT"
{
    Caption = 'Export ESL';
    ProcessingOnly = true;
    UseRequestPage = false;
    dataset
    {

    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    trigger OnInitReport()
    var
    begin
        CR := 13;
        LF := 10;
        FillTempRecs();//BC Upgrade
    end;

    trigger OnPreReport()
    var
        InsertCounter: Integer;
        //ESLStores: Record "ESL_ESL Stores_NT"; //BC Upgrade. Moved to Temp Record
        lItem: Record Item;
    begin
        LocalPath := 'C:\ncr\NAV2016\ESL\';
        ServerPath := '\\10.20.0.72\f$\ESLIMPORT\';

        // LocalPath := 'C:\ncr\BC\ESL\';//BC Upgrade Testing
        // ServerPath := 'C:\fdollar\ESLIMPORT\';//BC Upgrade Testing

        ToFile := 'Products2.txt';
        LocalFilename := LocalPath + ToFile;

        /*{IF Stores.FINDSET THEN
                    REPEAT
                        StorePriceGroup.RESET;
                        StorePriceGroup.SETRANGE(StorePriceGroup.Store, Stores."No.");
                        StorePriceGroup.SETCURRENTKEY(Store, Priority);
                        StorePriceGroup.SETASCENDING(StorePriceGroup.Priority, FALSE);
                        IF StorePriceGroup.FINDLAST THEN
                            PriceGroupCode := StorePriceGroup."Price Group Code"
                        ELSE
                            EXIT;

                    ///PUT ALL CODE HERE
                    //Change StoreNo variable
                    UNTIL Stores.NEXT = 0;}*/


        //IF GUIALLOWED THEN
        //FileName := FileMgt.ServerTempFileName('txt') //NOT FOR SCHEDULER
        //ELSE
        FileName := ServerPath + 'X' + ToFile; //ADD Path for scheduler
        NewFileName := ServerPath + ToFile;

        //BC Upgrade Start
        //Following Lines commented as overwirting FileName(Server)

        /*
        FileName := LocalPath + 'X' + ToFile; //ADD Path for scheduler
        NewFileName := LocalPath + ToFile;
        */

        //BC Upgrade End


        DotNetStringBuilber := DotNetStringBuilber.StringBuilder();

        DotNetStringBuilber.Append(
        '"' + 'DescriptionEN' + '"|"' +
          'DescriptionGR' + '"|"' +
          'ExpirationDate' + '"|"' +
          'PLU' + '"|"' +
          'ItemNo' + '"|"' +
          'SellPrice' + '"|"' +
          'OfferPrice' + '"|"' +
          'PromoText' + '"|"' +
          'UoM' + '"|"' +
          'PricePer' + '"|"' +
          'CountryOfOrigin' + '"|"' +
          'Store' + '"|"' +
          'Promo' + '"|"' +
          'Category' + '"|"' +
          'Barcode' + '"');

        //Fill Buffer  
        Item_Check.SETCURRENTKEY("Item Category Code");
        Item_Check.SETFILTER(Item_Check."Item Category Code", '01T1|01B5');
        //Item_Check.SETRANGE("No.",'108783','108790');        
        IF Item_Check.FINDSET THEN
            REPEAT
                IF NOT ESLBuffer.GET(Item_Check."No.") THEN BEGIN
                    ESLBuffer.INIT;
                    ESLBuffer."Item No" := Item_Check."No.";
                    ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                    ESLBuffer.INSERT;
                    FillTempItems(Item_Check);
                    InsertCounter += 1;
                END;
            UNTIL Item_Check.NEXT = 0;

        //BC Upgrade Start
        if ESLBuffer.FindSet() then
            repeat
                FillTempSalesPriceThisItem(ESLBuffer."Item No");
            until ESLBuffer.Next() = 0;
        //BC Upgrade End    

        // Don't output file if no records are found
        ESLBuffer.RESET;
        IF ESLBuffer.COUNT = 0 THEN
            CurrReport.QUIT;

        StoreNo := '';
        PriceGroupCode := '';
        StoreGroup := '';
        ESLStoresTemp.Reset();
        ESLStoresTemp.SetRange(Enabled, true);
        IF ESLStoresTemp.FindSet() THEN
            REPEAT
                StoreNo := ESLStoresTemp."Store No";
                PriceGroupCode := ESLStoresTemp."Price Group Code";
                StoreGroup := ESLStoresTemp."Store Group";

                IF ESLBuffer.FindSet() THEN
                    REPEAT
                        ExportItem(ESLBuffer."Item No", ESLBuffer."ESL Countries");
                    UNTIL ESLBuffer.Next() = 0;
            UNTIL ESLStoresTemp.Next() = 0;

        //Save to local path   
        oFileLocal.CREATE(LocalFilename, TEXTENCODING::UTF8);
        oFileLocal.CREATEOUTSTREAM(oStreamLocal);
        //Ch use StreamWriter for Greek
        streamWriterLocal := streamWriterLocal.StreamWriter(oStreamLocal, Encoding.Unicode);
        streamWriterLocal.Write(DotNetStringBuilber.ToString());
        streamWriterLocal.Close();
        oFileLocal.CLOSE;
        //..LocalFile

        //Server File..
        oFile.CREATE(FileName, TEXTENCODING::UTF8);
        oFile.CREATEOUTSTREAM(oStream);
        //Ch use StreamWriter for Greek
        streamWriter := streamWriter.StreamWriter(oStream, Encoding.Unicode);
        streamWriter.Write(DotNetStringBuilber.ToString());
        streamWriter.Close();
        oFile.CLOSE;

        IF EXISTS(NewFileName) THEN
            ERASE(NewFileName);

        RENAME(FileName, NewFileName);
        //..Server File


        //IF GUIALLOWED THEN
        //DOWNLOAD(FileName,'','','',ToFile) //NOT FOR SCHEDULER


    end;

    local procedure ExportItem(ItemNo_: Code[20]; ByCountry: Boolean)
    var
        ESLDescr: DotNet String;
        CurrPrice: Decimal;
        CompUom: Integer;
        ESLCountries_: Record "ESL_ESL Countries_NT";
        PricePer_Dec: Decimal;
    begin
        //Item.RESET;
        IF Item.GET(ItemNo_) THEN;
        IF Item."Item Category Code" IN ['01T1', '01B5'] THEN BEGIN
            //CLEAR Variables..
            DescriptionEN := '';
            DescriptionGR := '';
            ExpirationDate := '';
            ItemNo := '';
            SellPrice := 0;
            OfferPrice := 0;
            PromoText := '';
            PricePer := '';
            UoM := '';
            IF Item."Item Category Code" = '01T1' THEN
                Promo := ''
            ELSE
                Promo := '10';
            Category := '';
            CountryOfOrigin := '';
            ESLBarcode := '';
            DefaultBarcodeNo := '';
            //..

            DescriptionEN := Item.Description;
            DescriptionGR := Item."Greek Description";
            //ExpirationDate := 
            ItemNo := Item."No.";
            //SellPrice := RetailItemUtils.GetValidRetailPrice2(StoreGroup, Item."No.", TODAY, TIME, '', '', '', '', PriceGroupCode, '', '');
            SellPrice := GetSellPriceFromTempPriceList(Item."No.", StoreGroup, PriceListLineTmp);
            //IF (SellPrice = 0) AND (PriceGroupCode <> 'AL') THEN
            //SellPrice := RetailItemUtils.GetValidRetailPrice2(StoreGroup, Item."No.", TODAY, TIME, '', '', '', '', 'AL', '', '');

            GetOfferPriceAndPromoText(); //OfferPrice,PromoText,Promo

            //DefaultBarcodeNo := Item.DefaultBarcode; //BC Upgrade
            DefaultBarcodeNo := Item."No. 2"; //BC Upgrade
            ESLDescr := Item."ESL Description";
            IF (STRPOS(ESLDescr, '1/') = 1) OR (STRPOS(ESLDescr, '1 /') = 1) THEN BEGIN
                ESLDescr := ESLDescr.Replace('1/', '');
                ESLDescr := ESLDescr.Replace('1 /', '');
            END;
            ESLDescr := ESLDescr.Replace('/', '');

            //Uom..
            IF STRPOS(ItemNo, '90') = 1 THEN BEGIN
                IF STRPOS(DefaultBarcodeNo, '20') = 1 THEN
                    UoM := 'EACH'
                ELSE
                    IF STRPOS(DefaultBarcodeNo, '21') = 1 THEN
                        UoM := 'KG';
            END
            ELSE BEGIN
                UoM := 'EACH';
                //PricePer.. 
                CurrPrice := 0;
                IF (OfferPrice > 0) THEN
                    CurrPrice := OfferPrice
                ELSE
                    CurrPrice := SellPrice;

                CompUom := 0;
                PricePer_Dec := 0;
                IF (EVALUATE(CompUom, Item."Comparison UOM")) AND (CurrPrice > 0) THEN
                    IF (CompUom > 0) AND (Item."Actual Weight" > 0) THEN
                        IF CompUom <> 1 THEN
                            PricePer_Dec := (CurrPrice * CompUom / Item."Actual Weight");

                IF (PricePer_Dec > 0) AND (ESLDescr.ToString <> '') AND (CompUom <> 1) THEN
                    PricePer := FORMAT(PricePer_Dec, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>') + ' per ' + ESLDescr.ToString
                ELSE
                    IF (PricePer_Dec > 0) AND (ESLDescr.ToString <> '') AND (CompUom = 1) THEN
                        PricePer := FORMAT(CurrPrice, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>') + ' per ' + ESLDescr.ToString;
                //..PricePer
            END;
            IF UoM = '' THEN UoM := 'EACH';
            //..Uom

            IF ByCountry then begin
                ESLCountriesTemp.Reset();
                IF ESLCountriesTemp.FindSet() THEN BEGIN

                    //BC Upgrade. Code commented
                    // IF ESLCountries_.GET('CY') THEN //Only the first line
                    //     CountryOfOrigin := ESLCountries_."Greek Name";

                    Category := 'I';
                    ESLBarcode := ItemNo;
                    AppendToFile;

                    REPEAT
                        CountryOfOrigin := ESLCountriesTemp."Greek Name";
                        Category := 'I';
                        ESLBarcode := ItemNo + ESLCountriesTemp.Code + '1';
                        AppendToFile();
                        IF ESLCountriesTemp.Code = 'CY' THEN BEGIN
                            Category := 'II';
                            ESLBarcode := ItemNo + ESLCountriesTemp.Code + '2';
                            AppendToFile();
                        END

                    UNTIL ESLCountriesTemp.NEXT = 0;
                END;
            END ELSE BEGIN
                AppendToFile();
            END;
        END;
    end;

    local procedure AppendToFile()
    var
        OfferPriceTXT: Text;

    begin
        //INSERT USING GLOBALS
        IF OfferPrice = 0 THEN
            OfferPriceTXT := ''
        ELSE
            OfferPriceTXT := FORMAT(OfferPrice, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');

        IF Item."ESL Offer" THEN BEGIN
            IF Item."Item Category Code" = '01T1' THEN
                Promo := '2'
            ELSE
                Promo := '12';
        END;

        DotNetStringBuilber.Append(FORMAT(CR) + FORMAT(LF) +
        '"' + DescriptionEN + '"|"' +
        DescriptionGR + '"|"' +
        ExpirationDate + '"|"' +
        ESLBarcode + '"|"' +
        ItemNo + '"|"' +
        FORMAT(SellPrice, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>') + '"|"' +
        OfferPriceTXT + '"|"' +
        PromoText + '"|"' +
        UoM + '"|"' +
        PricePer + '"|"' +
        CountryOfOrigin + '"|"' +
        StoreNo + '"|"' +
        Promo + '"|"' +
        Category + '"|"' +
        DefaultBarcodeNo + '"');
    end;

    local procedure GetOfferPriceAndPromoText()
    var
        //BC Upgrade. Moved to Global as temporary
        // Offer: Record "LSC Offer";
        // OfferLine: Record "LSC Offer Line";
        PerioDisc_Counter: Integer;
    begin
        OfferLine.RESET;
        Offer.RESET;
        Offer.SETRANGE(Offer.Status, Offer.Status::Enabled);
        //CS 05/02/2019..
        Offer.SETRANGE(Offer."Customer Disc. Group", '');
        Offer.SETRANGE(Offer."Member Attribute", '');
        Offer.SETRANGE(Offer."Member Type", Offer."Member Type"::Scheme);
        Offer.SETRANGE(Offer."Coupon Code", '');
        //..CS 05/02/2019
        OfferLine.SETCURRENTKEY(Type, "No.");
        OfferLine.SETRANGE(Type, OfferLine.Type::Item);
        OfferLine.SETRANGE("No.", Item."No.");
        //OfferLine.SETRANGE("Unit of Measure", Barcode."Unit of Measure Code");

        IF Offer.FINDSET THEN
            REPEAT
                //IF RetailItemUtils.DiscValPerValid(Offer."Validation Period ID", TODAY, TIME) THEN BEGIN

                OfferLine.SETFILTER("Offer No.", Offer."No.");
                IF OfferLine.FINDLAST THEN BEGIN
                    OfferPrice := OfferLine."Offer Price Including VAT";
                    PromoText := OfferLine.Description;
                    IF Item."Item Category Code" = '01T1' THEN
                        Promo := '1'
                    ELSE
                        Promo := '11';
                END;

                OfferLine.SETRANGE("Offer No.");
            //END;
            UNTIL Offer.NEXT = 0;

        IF OfferPrice = 0 THEN BEGIN
            //GET Sales Offer Price if no promotion

            PeriodicDiscountLine.RESET;
            PeriodicDiscount.RESET;
            PeriodicDiscount.SETRANGE(PeriodicDiscount.Status, PeriodicDiscount.Status::Enabled);
            PeriodicDiscount.SETRANGE(PeriodicDiscount."Offer Type", PeriodicDiscount."Offer Type"::"Disc. Offer");
            //CS 05/02/2019..
            PeriodicDiscount.SETRANGE(PeriodicDiscount."Customer Disc. Group", '');
            PeriodicDiscount.SETRANGE(PeriodicDiscount."Member Attribute", '');
            PeriodicDiscount.SETRANGE(PeriodicDiscount."Member Type", PeriodicDiscount."Member Type"::Scheme);
            PeriodicDiscount.SETRANGE(PeriodicDiscount."Coupon Code", '');
            //..CS 05/02/2019

            //CS NT 15/02/2019 - Check for given Price Group, else use 'AL'
            PeriodicDiscount.SETRANGE(PeriodicDiscount."Price Group", PriceGroupCode);

            PeriodicDiscountLine.SETCURRENTKEY(Type, "No.");
            PeriodicDiscountLine.SETRANGE(Status, PeriodicDiscountLine.Status::Enabled);
            //PeriodicDiscountLine.SETRANGE("Unit of Measure", Barcode."Unit of Measure Code");

            //CS NT 15/02/2019 - Check for given Price Group, else use 'AL'
            PeriodicDiscountLine.SETRANGE(PeriodicDiscountLine."Price Group", PriceGroupCode);

            PerioDisc_Counter := 0;
            IF PeriodicDiscount.FINDSET THEN
                REPEAT
                    //BC Upgrade. Discount Validation checked at the time of loading Discounts to Temp tables
                    //IF RetailItemUtils.DiscValPerValid(PeriodicDiscount."Validation Period ID", TODAY, TIME) THEN BEGIN
                    GetPeriodicDiscountLine(PeriodicDiscount, PeriodicDiscountLine);
                    PerioDisc_Counter += 1;
                //END;
                UNTIL PeriodicDiscount.NEXT = 0;

            //Check for Price Group 'AL' if PriceGroupCode <> 'AL'
            IF (PerioDisc_Counter = 0) AND (PriceGroupCode <> 'AL') THEN BEGIN
                PeriodicDiscount.SETRANGE(PeriodicDiscount."Price Group", 'AL');
                PeriodicDiscountLine.SETRANGE(PeriodicDiscountLine."Price Group", 'AL');
                IF PeriodicDiscount.FINDSET THEN
                    REPEAT
                        //BC Upgrade. Discount Validation checked at the time of loading Discounts to Temp tables
                        //IF RetailItemUtils.DiscValPerValid(PeriodicDiscount."Validation Period ID", TODAY, TIME) THEN BEGIN
                        GetPeriodicDiscountLine(PeriodicDiscount, PeriodicDiscountLine);
                    //END;
                    UNTIL PeriodicDiscount.NEXT = 0;
            END;
        END;
    end;

    local procedure GetPeriodicDiscountLine(var PeriodicDiscount_: Record "LSC Periodic Discount" temporary; var PeriodicDiscountLine_: Record "LSC Periodic Discount Line" temporary)
    var
        hierarchy: Integer;
        ItemSpecialGroupLink: Record "LSC Item/Special Group Link";
    begin
        hierarchy := 0;
        /*{ Hierarchy
          5. Item
          4. Product group
          3. Item Categoty
          2. Special Groups
          1. All(Unused)
        }*/
        PeriodicDiscountLine_.SETFILTER("Offer No.", PeriodicDiscount_."No.");

        //item Level Hierarchy(5)
        PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::Item);
        PeriodicDiscountLine_.SETRANGE("No.", Item."No.");
        IF PeriodicDiscountLine_.FINDLAST THEN BEGIN
            IF PeriodicDiscountLine_."Offer Price Including VAT" > 0 THEN BEGIN
                OfferPrice := PeriodicDiscountLine_."Offer Price Including VAT";
                //PromoText := PeriodicDiscountLine_.Description; //BC Upgrade
                PromoText := PeriodicDiscountLine_."Discount Offer Description";//BC Upgrade
                IF Item."Item Category Code" = '01T1' THEN
                    Promo := '1'
                ELSE
                    Promo := '11';
            END
            ELSE BEGIN
                IF PeriodicDiscount_."ESL Offer Description" = '' THEN
                    PromoText := 'OFFER'
                ELSE
                    PromoText := PeriodicDiscount_."ESL Offer Description";
                IF Item."Item Category Code" = '01T1' THEN
                    Promo := '3'
                ELSE
                    Promo := '13';
            END;
            hierarchy := 5;
        END;

        //Product Group Level Hierarchy(4)
        IF hierarchy < 4 THEN BEGIN
            PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::"Product Group");
            //PeriodicDiscountLine_.SETRANGE("No.", Item."Product Group Code");//BC Upgrade
            PeriodicDiscountLine_.SETRANGE("No.", Item."LSC Retail Product Code");//BC Upgrade
            IF PeriodicDiscountLine_.FINDLAST THEN BEGIN
                //OfferPrice := SellPrice * (1 - PeriodicDiscountLine_."Deal Price/Disc. %");
                IF PeriodicDiscount_."ESL Offer Description" = '' THEN
                    PromoText := 'OFFER'
                ELSE
                    PromoText := PeriodicDiscount_."ESL Offer Description";
                IF Item."Item Category Code" = '01T1' THEN
                    Promo := '3'
                ELSE
                    Promo := '13';
                hierarchy := 4;
            END;
        END;

        //Item Category Level Hierarchy(3)
        IF hierarchy < 3 THEN BEGIN
            PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::"Item Category");
            PeriodicDiscountLine_.SETRANGE("No.", Item."Item Category Code");
            IF PeriodicDiscountLine_.FINDLAST THEN BEGIN
                //OfferPrice := SellPrice * (1 - PeriodicDiscountLine_."Deal Price/Disc. %");
                IF PeriodicDiscount_."ESL Offer Description" = '' THEN
                    PromoText := 'OFFER'
                ELSE
                    PromoText := PeriodicDiscount_."ESL Offer Description";
                IF Item."Item Category Code" = '01T1' THEN
                    Promo := '3'
                ELSE
                    Promo := '13';
                hierarchy := 3;
            END;
        END;

        //Special Groups Level Hierarchy(2)
        IF hierarchy < 2 THEN BEGIN
            PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::"Special Group");
            ItemSpecialGroupLink.RESET;
            ItemSpecialGroupLink.SETRANGE(ItemSpecialGroupLink."Item No.", Item."No.");
            IF ItemSpecialGroupLink.FINDSET THEN
                REPEAT
                    PeriodicDiscountLine_.SETRANGE("No.", ItemSpecialGroupLink."Special Group Code");
                    IF PeriodicDiscountLine_.FINDLAST THEN BEGIN
                        //OfferPrice := SellPrice * (1 - PeriodicDiscountLine_."Deal Price/Disc. %");
                        IF PeriodicDiscount_."ESL Offer Description" = '' THEN
                            PromoText := 'OFFER'
                        ELSE
                            PromoText := PeriodicDiscount_."ESL Offer Description";
                        IF Item."Item Category Code" = '01T1' THEN
                            Promo := '3'
                        ELSE
                            Promo := '13';
                        hierarchy := 2;
                    END;
                UNTIL ItemSpecialGroupLink.NEXT = 0;
        END;

        PeriodicDiscountLine_.SETRANGE("Offer No.");

    end;

    local procedure FillTempRecs()
    var
        lOffer: Record "LSC Offer";
        lOfferLine: Record "LSC Offer Line";
        lPeriodicDiscountLine: Record "LSC Periodic Discount Line";
        lPeriodicDiscount: Record "LSC Periodic Discount";
        ESLStores: Record "ESL_ESL Stores_NT";
    begin
        if ESLCountries.FindSet() then
            repeat
                ESLCountriesTemp.Init();
                ESLCountriesTemp.TransferFields(ESLCountries);
                ESLCountriesTemp.Insert();
            until ESLCountries.Next() = 0;

        lOffer.SETRANGE(Status, lOffer.Status::Enabled);
        lOffer.SETRANGE("Customer Disc. Group", '');
        lOffer.SETRANGE("Member Attribute", '');
        lOffer.SETRANGE("Member Type", lOffer."Member Type"::Scheme);
        lOffer.SETRANGE(lOffer."Coupon Code", '');
        if lOffer.FindSet() then
            repeat
                if RetailItemUtils.DiscValPerValid(lOffer."Validation Period ID", TODAY, TIME) then begin
                    Offer.Init();
                    Offer.TransferFields(lOffer);
                    Offer.Insert();

                    lOfferLine.SetCurrentKey("Offer No.", Type, "No.", "Variant Code", "Unit of Measure", "Currency Code");
                    lOfferLine.SetRange("Offer No.", lOffer."No.");
                    lOfferLine.SetRange(Type, lOfferLine.Type::Item);
                    if lOfferLine.FindSet() then
                        repeat
                            OfferLine.Init();
                            OfferLine.TransferFields(lOfferLine);
                            OfferLine.Insert();
                        until lOfferLine.Next() = 0;
                end;
            until lOffer.Next() = 0;

        lPeriodicDiscount.SetRange(Status, lPeriodicDiscount.Status::Enabled);
        lPeriodicDiscount.SetRange("Offer Type", lPeriodicDiscount."Offer Type"::"Disc. Offer");
        lPeriodicDiscount.SetRange("Customer Disc. Group", '');
        lPeriodicDiscount.SetRange("Member Attribute", '');
        lPeriodicDiscount.SetRange("Member Type", lPeriodicDiscount."Member Type"::Scheme);
        lPeriodicDiscount.SetRange("Coupon Code", '');
        if lPeriodicDiscount.FindSet() then
            repeat
                if RetailItemUtils.DiscValPerValid(lPeriodicDiscount."Validation Period ID", TODAY, TIME) then begin
                    PeriodicDiscount.Init();
                    PeriodicDiscount.TransferFields(lPeriodicDiscount);
                    PeriodicDiscount.Insert();

                    lPeriodicDiscountLine.SetRange("Offer No.", lPeriodicDiscount."No.");
                    if lPeriodicDiscountLine.FindSet() then
                        repeat
                            PeriodicDiscountLine.Init();
                            PeriodicDiscountLine.TransferFields(lPeriodicDiscountLine);
                            PeriodicDiscountLine.Insert();
                        until lPeriodicDiscountLine.Next() = 0;
                end;
            until lPeriodicDiscount.Next() = 0;

        ESLStores.SETRANGE(ESLStores.Enabled, TRUE);
        if ESLStores.FindSet() then
            repeat
                ESLStoresTemp.Init();
                ESLStoresTemp.TransferFields(ESLStores);
                ESLStoresTemp.Insert();
            until ESLStores.Next() = 0;

    end;

    local procedure FillTempItems(ItemToConsider: Record Item)
    var
        ProductExt: codeunit "LSC Product Ext.";
    begin
        Item.Init();
        Item.TransferFields(ItemToConsider);
        Item."No. 2" := ProductExt.DefaultBarcode(ItemToConsider);
        Item.Insert();
    end;

    local procedure FillTempSalesPriceThisItem(ItemNo: Code[20])
    var
        LineNo: Integer;
    begin
        PriceListLineTmp.Reset();
        if PriceListLineTmp.FindLast() then
            LineNo := PriceListLineTmp."Line No." + 1
        else
            LineNo := 10;

        PriceListLineTmp.Reset();

        ESLStoresTemp.RESET;
        IF ESLStoresTemp.FINDSET THEN
            REPEAT
                StoreNo := ESLStoresTemp."Store No";
                PriceGroupCode := ESLStoresTemp."Price Group Code";
                StoreGroup := ESLStoresTemp."Store Group";
                SellPrice := RetailItemUtils.GetValidRetailPrice2(StoreGroup, ItemNo, TODAY, TIME, '', '', '', '', PriceGroupCode, '', '');
                PriceListLineTmp.Init();
                PriceListLineTmp."Price List Code" := StoreGroup;
                PriceListLineTmp."Line No." := LineNo;
                LineNo += 1;
                PriceListLineTmp."Asset Type" := PriceListLineTmp."Asset Type"::Item;
                PriceListLineTmp."Asset No." := ItemNo;
                PriceListLineTmp."Source Type" := PriceListLineTmp."Source Type"::"Customer Price Group";
                PriceListLineTmp."Source No." := PriceGroupCode;
                PriceListLineTmp."Unit Price" := SellPrice;
                PriceListLineTmp.Insert();
            UNTIL ESLStoresTemp.NEXT = 0;
    end;

    local procedure GetSellPriceFromTempPriceList(ItemNo: Code[20]; StoreGroup: Code[20]; var PriceListLineTmp: Record "Price List Line" temporary): Decimal
    var
    begin
        PriceListLineTmp.Reset();
        PriceListLineTmp.SetFilter("Asset Type", '%1', PriceListLineTmp."Asset Type"::Item);
        PriceListLineTmp.SetFilter("Asset No.", ItemNo);
        PriceListLineTmp.SetFilter("Price List Code", StoreGroup);
        if PriceListLineTmp.FindFirst() then
            exit(PriceListLineTmp."Unit Price")
        else
            exit(0);
    end;

    var
        PriceListLineTmp: Record "Price List Line" temporary;
        Item: Record Item temporary;
        Store: Record "LSC Store";
        ToFile: Text[1024];
        FileName: Text[1024];
        NewFileName: Text[1024];
        LocalFilename: Text[1024];
        DescriptionEN: Text[50];
        DescriptionGR: Text[50];
        ExpirationDate: Text[10];
        ItemNo: Code[20];
        SellPrice: Decimal;
        OfferPrice: Decimal;
        PromoText: Text[50];
        PricePer: Text[50];
        UoM: Code[20];
        StoreNo: Code[20];
        Promo: Code[10];
        Category: Code[10];
        CountryOfOrigin: Text[50];
        ESLBarcode: Code[20];
        DotNetStringBuilber: DotNet StringBuilder;
        FileMgt: Codeunit "File Management";
        CR: Char;
        LF: Char;
        Encoding: DotNet Encoding;
        RetailItemUtils: Codeunit "LSC Retail Price Utils";
        BOUtils: Codeunit "LSC BO Utils";
        PeriodicDiscountLine: Record "LSC Periodic Discount Line" temporary;
        PeriodicDiscount: Record "LSC Periodic Discount" temporary;
        ESLCountries: Record "ESL_ESL Countries_NT";
        ESLCountriesTemp: Record "ESL_ESL Countries_NT" temporary;
        Barcodes: Record "LSC Barcodes";
        DefaultBarcodeNo: Code[20];
        //SalesPrice: Record "Sales Price";
        ServerPath: Text[1024];
        LocalPath: Text[1024];
        PriceGroupCode: Code[10];
        Stores: Record "LSC Store";
        StorePriceGroup: Record "LSC Store Price Group";
        StoreGroup: Code[10];
        ESLBuffer: Record "ESL_Export Buffer_NT" temporary;
        oFile: File;
        oStream: OutStream;
        streamWriter: DotNet StreamWriter;
        oFileLocal: File;
        oStreamLocal: OutStream;
        streamWriterLocal: DotNet StreamWriter;
        Item_Check: Record Item;
        ItemSpecialGroup_Check: Record "LSC Item/Special Group Link";
        Offer: Record "LSC Offer" temporary;
        OfferLine: Record "LSC Offer Line" temporary;
        ESLStoresTemp: Record "ESL_ESL Stores_NT" temporary;
}
