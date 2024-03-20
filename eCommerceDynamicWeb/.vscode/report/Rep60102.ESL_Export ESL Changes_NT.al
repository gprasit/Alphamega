report 60102 "ESL_Export ESL Changes_NT"
{
    Caption = 'Export ESL Changes';
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
        myInt: Integer;
    begin
        CR := 13;
        LF := 10;

    end;

    trigger OnPreReport()
    var
        DistList: Record "LSC Distribution List";
        ESLStores: Record "ESL_ESL Stores_NT";
        PeriodicDiscountLine_Check: Record "LSC Periodic Discount Line";
        PeriodicDiscount_Check: Record "LSC Periodic Discount";
        InsertCounter: Integer;
    begin
        // LocalPath := '\\10.20.0.60\c$\ncr\NAV2016\ESL\';
        // ServerPath := '\\10.20.0.72\f$\ESLIMPORT\';
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();//BC Upgrade
        LocalPath := 'C:\ncr\NAV2016\ESL\'; //BC Upgrade Testing
        ServerPath := 'C:\fdollar\ESLIMPORT\';//BC Upgrade Testing


        ToFile := 'Products2.txt';
        LocalFilename := LocalPath + ToFile;

        /*{IF Stores.FINDSET THEN
          REPEAT
            StorePriceGroup.RESET;
            StorePriceGroup.SETRANGE(StorePriceGroup.Store, Stores."No.");
            StorePriceGroup.SETCURRENTKEY(Store,Priority);
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

        StoreNo := '';
        PriceGroupCode := '';
        StoreGroup := '';
        ESLStores.RESET;
        ESLStores.SETRANGE(ESLStores.Enabled, TRUE);
        IF ESLStores.FINDSET THEN
            REPEAT
                StoreNo := ESLStores."Store No";
                PriceGroupCode := ESLStores."Price Group Code";
                StoreGroup := ESLStores."Store Group";

                //Check for offers last 5 days
                PeriodicDiscount_Check.SETRANGE(PeriodicDiscount_Check.Status, PeriodicDiscount_Check.Status::Enabled);
                PeriodicDiscount_Check.SETFILTER(PeriodicDiscount_Check."Starting Date", '%1..%2', CALCDATE('<-13D>', TODAY), TODAY);
                PeriodicDiscount_Check.SETFILTER(PeriodicDiscount_Check."Ending Date", '>=%1', TODAY);
                PeriodicDiscount_Check.SETFILTER(PeriodicDiscount_Check."Price Group", '%1|%2', PriceGroupCode, 'AL');
                IF PeriodicDiscount_Check.FINDSET THEN
                    REPEAT
                        DistList.RESET;
                        DistList.SETRANGE(DistList."Table ID", 99001453);
                        DistList.SETRANGE(DistList."Store Group", StoreGroup);
                        DistList.SETRANGE(DistList.Value, PeriodicDiscount_Check."No.");
                        IF DistList.FINDFIRST THEN BEGIN
                            //CHECK ITEMS
                            PeriodicDiscountLine_Check.RESET;
                            PeriodicDiscountLine_Check.SETRANGE(PeriodicDiscountLine_Check."Offer No.", PeriodicDiscount_Check."No.");
                            PeriodicDiscountLine_Check.SETFILTER(PeriodicDiscountLine_Check."Price Group", '%1|%2', PriceGroupCode, 'AL');//CS NT
                            PeriodicDiscountLine_Check.SETRANGE(PeriodicDiscountLine_Check.Type, PeriodicDiscountLine_Check.Type::Item);
                            IF PeriodicDiscountLine_Check.FINDSET THEN
                                REPEAT
                                    IF Item_Check.GET(PeriodicDiscountLine_Check."No.") THEN;
                                    IF Item_Check."Item Category Code" IN ['01T1', '01B5'] THEN
                                        IF NOT ESLBuffer.GET(PeriodicDiscountLine_Check."No.") THEN BEGIN
                                            ESLBuffer.INIT;
                                            ESLBuffer."Item No" := PeriodicDiscountLine_Check."No.";
                                            ESLBuffer."Offer No" := PeriodicDiscountLine_Check."Offer No.";
                                            ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                            ESLBuffer.INSERT;
                                            InsertCounter += 1;
                                        END;
                                UNTIL PeriodicDiscountLine_Check.NEXT = 0;
                            /*{
                          //CHECK Product Groups
                          PeriodicDiscountLine_Check.RESET;
                          PeriodicDiscountLine_Check.SETRANGE(PeriodicDiscountLine_Check."Offer No.",PeriodicDiscount_Check."No.");
                          PeriodicDiscountLine_Check.SETRANGE(PeriodicDiscountLine_Check.Type, PeriodicDiscountLine_Check.Type::"Product Group");
                          PeriodicDiscountLine_Check.SETFILTER("Price Group", '%1|%2', PriceGroupCode, 'AL'); //CS NT
                          IF PeriodicDiscountLine_Check.FINDSET THEN
                            REPEAT
                              Item_Check.RESET;
                              Item_Check.SETRANGE(Item_Check."Product Group Code",PeriodicDiscountLine_Check."No.");
                              Item_Check.SETFILTER(Item_Check."Item Category Code", '01T1|01B5'); //CS NT
                              IF Item_Check.FINDSET THEN
                              REPEAT
                                IF NOT ESLBuffer.GET(Item_Check."No.") THEN
                                BEGIN
                                  ESLBuffer.INIT;
                                  ESLBuffer."Item No" := Item_Check."No.";
                                  ESLBuffer."Offer No" := PeriodicDiscountLine_Check."Offer No.";
                                  ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                  ESLBuffer.INSERT;
                                  InsertCounter += 1;
                                END;
                              UNTIL Item_Check.NEXT = 0;
                            UNTIL PeriodicDiscountLine_Check.NEXT =0;

                          //CHECK Item Category
                          PeriodicDiscountLine_Check.RESET;
                          PeriodicDiscountLine_Check.SETFILTER(PeriodicDiscountLine_Check."No.", '01T1|01B5'); //CS NT
                          PeriodicDiscountLine_Check.SETRANGE(PeriodicDiscountLine_Check."Offer No.",PeriodicDiscount_Check."No.");
                          PeriodicDiscountLine_Check.SETRANGE(PeriodicDiscountLine_Check.Type, PeriodicDiscountLine_Check.Type::"Item Category");
                          PeriodicDiscountLine_Check.SETFILTER("Price Group", '%1|%2', PriceGroupCode, 'AL'); //CS NT
                          IF PeriodicDiscountLine_Check.FINDSET THEN
                            REPEAT
                              Item_Check.RESET;
                              //Search only for '01T1' to make it a little faster
                              Item_Check.SETRANGE(Item_Check."Item Category Code",PeriodicDiscountLine_Check."No.");
                              IF Item_Check.FINDSET THEN
                              REPEAT
                                IF NOT ESLBuffer.GET(Item_Check."No.") THEN
                                BEGIN
                                  ESLBuffer.INIT;
                                  ESLBuffer."Item No" := Item_Check."No.";
                                  ESLBuffer."Offer No" := PeriodicDiscountLine_Check."Offer No.";
                                  ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                  ESLBuffer.INSERT;
                                  InsertCounter += 1;
                                END;
                              UNTIL Item_Check.NEXT = 0;
                            UNTIL PeriodicDiscountLine_Check.NEXT =0;


                          //CHECK SPECIAL Groups
                          PeriodicDiscountLine_Check.RESET;
                          PeriodicDiscountLine_Check.SETRANGE(PeriodicDiscountLine_Check."Offer No.",PeriodicDiscount_Check."No.");
                          PeriodicDiscountLine_Check.SETRANGE(PeriodicDiscountLine_Check.Type, PeriodicDiscountLine_Check.Type::"Special Group");
                          PeriodicDiscountLine_Check.SETFILTER("Price Group", '%1|%2', PriceGroupCode, 'AL'); //CS NT
                          IF PeriodicDiscountLine_Check.FINDSET THEN
                            REPEAT
                              ItemSpecialGroup_Check.RESET;
                              ItemSpecialGroup_Check.SETRANGE(ItemSpecialGroup_Check."Special Group Code",PeriodicDiscountLine_Check."No.");
                              IF ItemSpecialGroup_Check.FINDSET THEN
                              REPEAT
                                IF Item_Check.GET(ItemSpecialGroup_Check."Item No.") THEN
                                  IF Item_Check."Item Category Code" IN ['01T1','01B5'] THEN
                                    IF NOT ESLBuffer.GET(Item_Check."No.") THEN
                                    BEGIN
                                      ESLBuffer.INIT;
                                      ESLBuffer."Item No" := Item_Check."No.";
                                      ESLBuffer."Offer No" := PeriodicDiscountLine_Check."Offer No.";
                                      ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                      ESLBuffer.INSERT;
                                      InsertCounter += 1;
                                    END;
                              UNTIL ItemSpecialGroup_Check.NEXT = 0;
                            UNTIL PeriodicDiscountLine_Check.NEXT = 0;
                            }*/
                        END;
                    UNTIL PeriodicDiscount_Check.NEXT = 0;

                // Check for price changes
                //BC Upgrade Start
                /*
                SalesPrice.RESET;
                SalesPrice.SETFILTER(SalesPrice."Starting Date", '%1..%2', CALCDATE('<0D>', TODAY), TODAY);
                SalesPrice.SETFILTER(SalesPrice."Ending Date", '>=%1|%2', TODAY, 0D);
                SalesPrice.SETFILTER(SalesPrice."Sales Code", '%1|%2', PriceGroupCode, 'AL');//CS NT
                IF SalesPrice.FINDSET THEN
                    REPEAT
                        IF Item_Check.GET(SalesPrice."Item No.") THEN
                            IF Item_Check."Item Category Code" IN ['01T1', '01B5'] THEN
                                IF NOT ESLBuffer.GET(SalesPrice."Item No.") THEN BEGIN
                                    ESLBuffer.INIT;
                                    ESLBuffer."Item No" := SalesPrice."Item No.";
                                    ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                    ESLBuffer.INSERT;
                                    InsertCounter += 1;
                                END;
                    UNTIL SalesPrice.NEXT = 0;                

                //CS NT 06092019 Check if any ending date in last 3 days
                SalesPrice.RESET;
                SalesPrice.SETFILTER(SalesPrice."Ending Date", '%1..%2', CALCDATE('<-3D>', TODAY), TODAY);
                SalesPrice.SETFILTER(SalesPrice."Sales Code", '%1|%2', PriceGroupCode, 'AL');
                IF SalesPrice.FINDSET THEN
                    REPEAT
                        IF Item_Check.GET(SalesPrice."Item No.") THEN
                            IF Item_Check."Item Category Code" IN ['01T1', '01B5'] THEN
                                IF NOT ESLBuffer.GET(SalesPrice."Item No.") THEN BEGIN
                                    ESLBuffer.INIT;
                                    ESLBuffer."Item No" := SalesPrice."Item No.";
                                    ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                    ESLBuffer.INSERT;
                                    InsertCounter += 1;
                                END;
                    UNTIL SalesPrice.NEXT = 0;
                   */
                if not ExtendedPriceEnabled then begin
                    SalesPrice.RESET;
                    SalesPrice.SETFILTER(SalesPrice."Starting Date", '%1..%2', CALCDATE('<0D>', TODAY), TODAY);
                    SalesPrice.SETFILTER(SalesPrice."Ending Date", '>=%1|%2', TODAY, 0D);
                    SalesPrice.SETFILTER(SalesPrice."Sales Code", '%1|%2', PriceGroupCode, 'AL');//CS NT
                    IF SalesPrice.FINDSET THEN
                        REPEAT
                            IF Item_Check.GET(SalesPrice."Item No.") THEN
                                IF Item_Check."Item Category Code" IN ['01T1', '01B5'] THEN
                                    IF NOT ESLBuffer.GET(SalesPrice."Item No.") THEN BEGIN
                                        ESLBuffer.INIT;
                                        ESLBuffer."Item No" := SalesPrice."Item No.";
                                        ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                        ESLBuffer.INSERT;
                                        InsertCounter += 1;
                                    END;
                        UNTIL SalesPrice.NEXT = 0;

                    //CS NT 06092019 Check if any ending date in last 3 days
                    SalesPrice.RESET;
                    SalesPrice.SETFILTER(SalesPrice."Ending Date", '%1..%2', CALCDATE('<-3D>', TODAY), TODAY);
                    SalesPrice.SETFILTER(SalesPrice."Sales Code", '%1|%2', PriceGroupCode, 'AL');
                    IF SalesPrice.FINDSET THEN
                        REPEAT
                            IF Item_Check.GET(SalesPrice."Item No.") THEN
                                IF Item_Check."Item Category Code" IN ['01T1', '01B5'] THEN
                                    IF NOT ESLBuffer.GET(SalesPrice."Item No.") THEN BEGIN
                                        ESLBuffer.INIT;
                                        ESLBuffer."Item No" := SalesPrice."Item No.";
                                        ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                        ESLBuffer.INSERT;
                                        InsertCounter += 1;
                                    END;
                        UNTIL SalesPrice.NEXT = 0;
                end else begin
                    PriceListLine.Reset();
                    PriceListLine.SetCurrentKey("Asset Type", "Asset No.", "Source Type", "Source No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                    PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);

                    PriceListLine.SetFilter("Starting Date", '%1..%2', CALCDATE('<0D>', TODAY), TODAY);
                    PriceListLine.SetFilter("Ending Date", '>=%1|%2', TODAY, 0D);
                    PriceListLine.SetFilter("Source Type", '%1', PriceListLine."Source Type"::"Customer Price Group");
                    PriceListLine.SetFilter("Source No.", '%1|%2', PriceGroupCode, 'AL');//CS NT
                    IF PriceListLine.FindSet() THEN
                        REPEAT
                            IF Item_Check.GET(PriceListLine."Product No.") THEN
                                IF Item_Check."Item Category Code" IN ['01T1', '01B5'] THEN
                                    IF NOT ESLBuffer.GET(PriceListLine."Product No.") THEN BEGIN
                                        ESLBuffer.Init();
                                        ESLBuffer."Item No" := PriceListLine."Product No.";
                                        ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                        ESLBuffer.Insert();
                                        InsertCounter += 1;
                                    END;
                        UNTIL PriceListLine.NEXT = 0;

                    //CS NT 06092019 Check if any ending date in last 3 days
                    PriceListLine.Reset();
                    PriceListLine.SetCurrentKey("Asset Type", "Asset No.", "Source Type", "Source No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                    PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);

                    PriceListLine.SETFILTER("Ending Date", '%1..%2', CALCDATE('<-3D>', TODAY), TODAY);
                    PriceListLine.SetFilter("Source Type", '%1', PriceListLine."Source Type"::"Customer Price Group");
                    PriceListLine.SetFilter("Source No.", '%1|%2', PriceGroupCode, 'AL');//CS NT

                    IF PriceListLine.FindSet() THEN
                        REPEAT
                            IF Item_Check.Get(PriceListLine."Product No.") THEN
                                IF Item_Check."Item Category Code" IN ['01T1', '01B5'] THEN
                                    IF not ESLBuffer.Get(PriceListLine."Product No.") THEN BEGIN
                                        ESLBuffer.INIT;
                                        ESLBuffer."Item No" := PriceListLine."Product No.";
                                        ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                                        ESLBuffer.INSERT;
                                        InsertCounter += 1;
                                    END;
                        UNTIL PriceListLine.Next() = 0;
                end;
                //BC Upgrade End

                //CS NT Check if any changes on Item..
                Item_Check.RESET;
                Item_Check.SETRANGE(Item_Check."Last Date Modified", TODAY);
                IF Item_Check.FINDSET THEN
                    REPEAT
                        IF NOT ESLBuffer.GET(Item_Check."No.") THEN BEGIN
                            ESLBuffer.INIT;
                            ESLBuffer."Item No" := Item_Check."No.";
                            ESLBuffer."ESL Countries" := Item_Check."Item Category Code" = '01T1';
                            ESLBuffer.INSERT;
                            InsertCounter += 1;
                        END;
                    UNTIL Item_Check.NEXT = 0;
                //..CS NT Check if any changes on Item

                IF ESLBuffer.FINDSET THEN
                    REPEAT
                        ExportItem(ESLBuffer."Item No", ESLBuffer."ESL Countries");
                    UNTIL ESLBuffer.NEXT = 0;

                // Don't output file if no records are found
                ESLBuffer.RESET;
                IF ESLBuffer.COUNT = 0 THEN
                    CurrReport.QUIT;

            UNTIL ESLStores.NEXT = 0;

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
        ESLCountries_: Record "ESL_ESL Countries_NT";
        ProductExt: codeunit "LSC Product Ext.";
        CurrPrice: Decimal;
        PricePer_Dec: Decimal;
        CompUom: Integer;
        ESLDescr: DotNet String;
    begin
        Item.RESET;
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
            SellPrice := RetailItemUtils.GetValidRetailPrice2(StoreGroup, Item."No.", TODAY, TIME, '', '', '', '', PriceGroupCode, '', '');
            //IF (SellPrice = 0) AND (PriceGroupCode <> 'AL') THEN
            //SellPrice := RetailItemUtils.GetValidRetailPrice2(StoreGroup,Item."No.",TODAY,TIME,'','','','','AL','','');

            GetOfferPriceAndPromoText(); //OfferPrice,PromoText,Promo

            //DefaultBarcodeNo := Item.DefaultBarcode; //BC Upgrade
            DefaultBarcodeNo := ProductExt.DefaultBarcode(Item); //BC Upgrade
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

            IF ByCountry THEN BEGIN
                ESLCountries.RESET;
                IF ESLCountries.FINDSET THEN BEGIN

                    IF ESLCountries_.GET('CY') THEN //Only the first line
                        CountryOfOrigin := ESLCountries_."Greek Name";

                    Category := 'I';
                    ESLBarcode := ItemNo;
                    AppendToFile;

                    REPEAT
                        CountryOfOrigin := ESLCountries."Greek Name";
                        Category := 'I';
                        ESLBarcode := ItemNo + ESLCountries.Code + '1';
                        AppendToFile();
                        IF ESLCountries.Code = 'CY' THEN BEGIN
                            Category := 'II';
                            ESLBarcode := ItemNo + ESLCountries.Code + '2';
                            AppendToFile();
                        END

                    UNTIL ESLCountries.NEXT = 0;
                END;
            END ELSE BEGIN
                ESLBarcode := ItemNo;
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
        Offer: Record "LSC Offer";
        OfferLine: Record "LSC Offer Line";
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
                IF RetailItemUtils.DiscValPerValid(Offer."Validation Period ID", TODAY, TIME) THEN BEGIN

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
                END;
            UNTIL Offer.NEXT = 0;

        IF OfferPrice = 0 THEN BEGIN
            //GET Sales Offer Price if no promotion

            PeriodicDiscountLine.RESET;
            PeriodicDiscount.RESET;
            PeriodicDiscount.SETRANGE(PeriodicDiscount.Status, PeriodicDiscount.Status::Enabled);
            //PeriodicDiscount.SETRANGE(PeriodicDiscount."Offer Type", PeriodicDiscount."Offer Type"::"Disc. Offer");
            PeriodicDiscount.SETRANGE(PeriodicDiscount."Offer Type", PeriodicDiscount."Offer Type"::"Mix&Match", PeriodicDiscount."Offer Type"::"Disc. Offer");
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
                    IF RetailItemUtils.DiscValPerValid(PeriodicDiscount."Validation Period ID", TODAY, TIME) THEN BEGIN
                        IF PeriodicDiscount."Offer Type" = PeriodicDiscount."Offer Type"::"Disc. Offer" THEN
                            GetPeriodicDiscountLine(PeriodicDiscount, PeriodicDiscountLine)
                        ELSE
                            GetMixMatchLine(PeriodicDiscount, PeriodicDiscountLine);
                        PerioDisc_Counter += 1;
                    END;
                UNTIL PeriodicDiscount.NEXT = 0;

            //Check for Price Group 'AL' if PriceGroupCode <> 'AL'
            IF (PerioDisc_Counter = 0) AND (PriceGroupCode <> 'AL') THEN BEGIN
                PeriodicDiscount.SETRANGE(PeriodicDiscount."Price Group", 'AL');
                PeriodicDiscountLine.SETRANGE(PeriodicDiscountLine."Price Group", 'AL');
                IF PeriodicDiscount.FINDSET THEN
                    REPEAT
                        IF RetailItemUtils.DiscValPerValid(PeriodicDiscount."Validation Period ID", TODAY, TIME) THEN BEGIN
                            IF PeriodicDiscount."Offer Type" = PeriodicDiscount."Offer Type"::"Disc. Offer" THEN
                                GetPeriodicDiscountLine(PeriodicDiscount, PeriodicDiscountLine)
                            ELSE
                                GetMixMatchLine(PeriodicDiscount, PeriodicDiscountLine);
                        END;
                    UNTIL PeriodicDiscount.NEXT = 0;
            END;
        END;
    end;

    local procedure GetPeriodicDiscountLine(PeriodicDiscount_: Record "LSC Periodic Discount"; PeriodicDiscountLine_: Record "LSC Periodic Discount Line")
    var
        ItemSpecialGroupLink: Record "LSC Item/Special Group Link";
        hierarchy: Integer;
    begin
        hierarchy := 0;
        /*{ Hierarchy
          5. Item
          4. Product group
          3. Item Categoty
          2. Special Groups
          1. All (Unused)
        }*/
        PeriodicDiscountLine_.SETFILTER("Offer No.", PeriodicDiscount_."No.");

        //item Level Hierarchy(5)
        PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::Item);
        PeriodicDiscountLine_.SETRANGE("No.", Item."No.");
        IF PeriodicDiscountLine_.FINDLAST THEN BEGIN
            IF PeriodicDiscountLine_."Offer Price Including VAT" > 0 THEN BEGIN
                OfferPrice := PeriodicDiscountLine_."Offer Price Including VAT";
                //PromoText := PeriodicDiscountLine_.Description; //mk
                PromoText := PeriodicDiscountLine_."Discount Offer Description";//mk
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

        hierarchy := 15;

        //Product Group Level Hierarchy(4)
        IF hierarchy < 4 THEN BEGIN
            PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::"Product Group");
            //PeriodicDiscountLine_.SETRANGE("No.", Item."Product Group Code"); //BC Upgrade
            PeriodicDiscountLine_.SETRANGE("No.", Item."LSC Retail Product Code"); //BC Upgrade
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

    LOCAL procedure GetMixMatchLine(PeriodicDiscount_: Record "LSC Periodic Discount"; PeriodicDiscountLine_: Record "LSC Periodic Discount Line")
    var
        ItemSpecialGroupLink: Record "LSC Item/Special Group Link";
        hierarchy: Integer;
    begin
        IF Item."Item Category Code" <> '01B5' THEN
            EXIT;
        hierarchy := 0;
        /*{ Hierarchy
          5. Item
          4. Product group
          3. Item Categoty
          2. Special Groups
          1. All (Unused)
        }*/
        PeriodicDiscountLine_.SETFILTER("Offer No.", PeriodicDiscount_."No.");

        //item Level Hierarchy(5)
        PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::Item);
        PeriodicDiscountLine_.SETRANGE("No.", Item."No.");
        IF PeriodicDiscountLine_.FINDLAST THEN BEGIN
            IF PeriodicDiscount_."ESL Offer Description" = '' THEN
                PromoText := PeriodicDiscountLine_.Description
            ELSE
                PromoText := PeriodicDiscount_."ESL Offer Description";
            Promo := '15';
            hierarchy := 5;
        END;

        hierarchy := 15;

        //Product Group Level Hierarchy(4)
        IF hierarchy < 4 THEN BEGIN
            PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::"Product Group");
            //PeriodicDiscountLine_.SETRANGE("No.", Item."Product Group Code");//BC Upgrade
            PeriodicDiscountLine_.SETRANGE("No.", Item."LSC Retail Product Code");//BC Upgrade
            IF PeriodicDiscountLine_.FINDLAST THEN BEGIN
                //OfferPrice := SellPrice * (1 - PeriodicDiscountLine_."Deal Price/Disc. %");
                IF PeriodicDiscount_."ESL Offer Description" = '' THEN
                    PromoText := PeriodicDiscount_.Description
                ELSE
                    PromoText := PeriodicDiscount_."ESL Offer Description";
                Promo := '15';
                hierarchy := 4;
            END;
        END;

        //Item Category Level Hierarchy(3)
        IF hierarchy < 3 THEN BEGIN
            PeriodicDiscountLine_.SETRANGE(Type, PeriodicDiscountLine_.Type::"Item Category");
            PeriodicDiscountLine_.SETRANGE("No.", Item."Item Category Code");
            IF PeriodicDiscountLine_.FINDLAST THEN BEGIN
                IF PeriodicDiscount_."ESL Offer Description" = '' THEN
                    PromoText := PeriodicDiscount_.Description
                ELSE
                    PromoText := PeriodicDiscount_."ESL Offer Description";
                Promo := '15';
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
                        IF PeriodicDiscount_."ESL Offer Description" = '' THEN
                            PromoText := PeriodicDiscount_.Description
                        ELSE
                            PromoText := PeriodicDiscount_."ESL Offer Description";
                        Promo := '15';
                        hierarchy := 2;
                    END;
                UNTIL ItemSpecialGroupLink.NEXT = 0;
        END;

        PeriodicDiscountLine_.SETRANGE("Offer No.");
    end;

    var
        Barcodes: Record "LSC Barcodes";
        ESLBuffer: Record "ESL_Export Buffer_NT" temporary;
        ESLCountries: Record "ESL_ESL Countries_NT";
        Item: Record Item;
        ItemSpecialGroup_Check: Record "LSC Item/Special Group Link";
        Item_Check: Record Item;
        PeriodicDiscount: Record "LSC Periodic Discount";
        PeriodicDiscountLine: Record "LSC Periodic Discount Line";
        PriceListLine: Record "Price List Line";
        SalesPrice: Record "Sales Price";
        Store: Record "LSC Store";
        StorePriceGroup: Record "LSC Store Price Group";
        Stores: Record "LSC Store";
        BOUtils: Codeunit "LSC BO Utils";
        FileMgt: Codeunit "File Management";
        RetailItemUtils: Codeunit "LSC Retail Price Utils";
        oFile: File;
        oFileLocal: File;
        oStream: OutStream;
        oStreamLocal: OutStream;
        CR: Char;
        LF: Char;
        Category: Code[10];
        DefaultBarcodeNo: Code[20];
        ESLBarcode: Code[20];
        ItemNo: Code[20];
        PriceGroupCode: Code[10];
        Promo: Code[10];
        StoreGroup: Code[10];
        StoreNo: Code[20];
        UoM: Code[20];
        OfferPrice: Decimal;
        SellPrice: Decimal;
        CountryOfOrigin: Text[50];
        DescriptionEN: Text[50];
        DescriptionGR: Text[50];
        ExpirationDate: Text[10];
        FileName: Text[1024];
        LocalFilename: Text[1024];
        LocalPath: Text[1024];
        NewFileName: Text[1024];
        PricePer: Text[50];
        PromoText: Text[50];
        ServerPath: Text[1024];
        ToFile: Text[1024];
        DotNetStringBuilber: DotNet StringBuilder;
        Encoding: DotNet Encoding;
        streamWriter: DotNet StreamWriter;
        streamWriterLocal: DotNet StreamWriter;
        ExtendedPriceEnabled: Boolean;
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
}
