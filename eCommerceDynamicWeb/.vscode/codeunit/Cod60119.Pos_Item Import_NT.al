codeunit 60119 "Pos_Item Import_NT"
{
    trigger OnRun()
    var
    begin
        ImportItems();
    end;

    local procedure ImportItems()
    var
        Barcode2: Record "LSC Barcodes";
        Barcode: Record "LSC Barcodes";
        Division: Record "LSC Division";
        Item2: Record Item;
        Item: Record Item;
        ItemBrands: Record "Pos_Item Brand_NT";
        ItemCategory: Record "Item Category";
        ItemDeps: Record "eCom_Item Department_NT";
        ItemFamily: Record "LSC Item Family";
        ItemStatusLink: Record "LSC Item Status Link";
        IUOM: Record "Item Unit of Measure";
        PerDiscLine: Record "LSC Periodic Discount Line";
        POSVATCode: Record "LSC POS VAT Code";
        ProductGroup: Record "LSC Retail Product Group";
        SalesPrice: Record "Sales Price";
        SalesPriceOlder: Record "Sales Price";
        SalesPriceUpdate: Record "Sales Price";
        UnitofMeasure: Record "Unit of Measure";
        VATSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VendorSupplier: Record "Pos_Vendor Supplier_NT";
        //PreActionActions: Codeunit "LSC PreAction -> Actions"; //BC22
        PreActionActions: Codeunit "eCom_PreAction -> Actions_NT"; //BC22        
        Window: Dialog;
        _File: DotNet File;
        i: Integer;
        AddFileName: Text;
        FileName: Text;
        PriceUtils: Codeunit "LSC Retail Price Utils";
        CurrPrice: Decimal;
        RetailSetup: Record "LSC Retail Setup";
    begin
        if not RetailSetup.Get() then
            RetailSetup.Init();
        FileName := 'c:\ncr\NAV2016\lsitem.txt';
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;
        iFile.CREATEINSTREAM(iStream);

        //streamReader := streamReader.StreamReader(iStream, encoding.GetEncoding('iso-8859-7')); //CS +

        VATSetup.SetCurrentKey("LSC POS Terminal VAT Code");
        i := 0;
        Window.OPEN('Item #1###############');
        while not iStream.EOS do begin //CS -
                                       //WHILE NOT streamReader.EndOfStream  DO BEGIN //CS +
            iStream.ReadText(iLine); //CS -
                                     //iLine := StreamReader.ReadLine(); //CS +
            IF (iLine <> '') AND (STRLEN(iLine) > 2) THEN BEGIN
                i += 1;
                ProcessLine();
                Window.UPDATE(1, ItemNo);
                IF UOM <> '' THEN
                    IF NOT UnitofMeasure.GET(UOM) THEN BEGIN
                        UnitofMeasure.Code := UOM;
                        UnitofMeasure.INSERT;
                    END;

                IF NOT Item.GET(ItemNo) THEN BEGIN
                    CLEAR(Item);
                    Item."No." := ItemNo;
                    Item.INSERT(TRUE);
                    Item."Costing Method" := Item."Costing Method"::Average;
                END;

                IF Barcode2.GET(Bar) THEN
                    IF Item2.GET(Barcode2."Item No.") THEN
                        IF Item2."Compress On Sales Export" THEN
                            Barcode2.DELETE(TRUE);

                Item.Description := Desc;
                Item."Description 2" := POSDesc;

                //Item."Greek Description" := GreekDesc;
                Item."Comparison UOM" := CompUOM;
                Item."Actual Weight" := WeightPerUnit;
                Item."ESL Description" := ESLDesc;
                Item."ESL ENG Description" := ESLENGDesc;
                Item."Every Day Low Price" := EveryDayLowPrice;

                IF NOT IUOM.GET(ItemNo, UOM) THEN BEGIN
                    CLEAR(IUOM);
                    IUOM."Item No." := ItemNo;
                    IUOM.Code := UOM;
                    IUOM."Qty. per Unit of Measure" := 1;
                    IUOM.INSERT(TRUE);
                END;

                IF IUOM.GET(ItemNo, UOM) THEN BEGIN
                    CLEAR(IUOM);
                    IUOM."Item No." := ItemNo;
                    IUOM.Code := UOM;
                    IUOM."Qty. per Unit of Measure" := 1;
                    IF NOT IUOM.INSERT(TRUE) THEN IUOM.MODIFY(TRUE);
                END;

                IF Item."Base Unit of Measure" <> UOM THEN
                    Item.VALIDATE("Base Unit of Measure", UOM);

                IF ItemCatCode <> '' THEN BEGIN
                    IF NOT ItemCategory.GET(ItemCatCode) THEN BEGIN
                        CLEAR(ItemCategory);
                        ItemCategory.Code := ItemCatCode;
                        ItemCategory.Description := ItemCatDesc;
                        ItemCategory."LSC Division Code" := DivCode;
                        ItemCategory.INSERT;
                    END;

                    IF PGCode <> '' THEN
                        IF NOT ProductGroup.GET(ItemCatCode, PGCode) THEN BEGIN
                            CLEAR(ProductGroup);
                            ProductGroup."Item Category Code" := ItemCatCode;
                            ProductGroup.Code := PGCode;
                            ProductGroup.Description := PGDesc;
                            ProductGroup."Division Code" := DivCode;
                            ProductGroup.INSERT;
                        END;
                END;

                IF DivCode <> '' THEN
                    IF NOT Division.GET(DivCode) THEN BEGIN
                        CLEAR(Division);
                        Division.Code := DivCode;
                        Division.Description := DivDesc;
                        Division.INSERT;
                    END;

                Item.VALIDATE("LSC Division Code", DivCode);
                Item.VALIDATE("Item Category Code", ItemCatCode);
                Item."LSC Retail Product Code" := PGCode;

                Item."Item Department Code" := ItemDep;

                IF ItemDep <> '' THEN
                    IF NOT ItemDeps.GET(ItemDep) THEN BEGIN
                        CLEAR(ItemDeps);
                        ItemDeps.Code := ItemDep;
                        ItemDeps.Description := ItemDepDesc;
                    END;

                Item."Item Brand Code" := ItemBrand;

                IF ItemBrand <> '' THEN
                    IF NOT ItemBrands.GET(ItemBrand) THEN BEGIN
                        CLEAR(ItemBrands);
                        ItemBrands.Code := ItemBrand;
                        ItemBrands.Description := ItemBrandDesc;
                    END;

                Item.Validate("Inventory Posting Group", 'RETAIL');
                Item.Validate("Gen. Prod. Posting Group", 'RETAIL');

                IF ItemFam <> '' THEN
                    IF NOT ItemFamily.GET(ItemFam) THEN BEGIN
                        CLEAR(ItemFamily);
                        ItemFamily.Code := ItemFam;
                        ItemFamily.Description := ItemFamDesc;
                        ItemFamily.INSERT;
                    END;

                Item."LSC Item Family Code" := ItemFam;

                CASE VATCode OF
                    'N', 'X':
                        VATCode := 'A';
                    'W':
                        VATCode := 'B';
                    'S':
                        VATCode := 'C';
                    'H':
                        VATCode := 'D';
                    'Z':
                        VATCode := 'A';
                END;

                POSVATCode.Get(VATCode);
                VATSetup.SetRange("LSC POS Terminal VAT Code", VATCode);
                VATSetup.SetRange("VAT %", POSVATCode."VAT %");
                VATSetup.SetFilter("VAT Bus. Posting Group", '=%1', '');
                VATSetup.FindFirst();
                Item.Validate("VAT Prod. Posting Group", VATSetup."VAT Prod. Posting Group");
                if Bar <> '' then
                    case ItemStatus of
                        'A':
                            if not Barcode.Get(Bar) then begin
                                Barcode."Barcode No." := Bar;
                                Barcode."Item No." := ItemNo;
                                Barcode.Description := POSDesc;
                                Barcode.INSERT(TRUE);
                            end else
                                if Barcode.Description <> POSDesc then begin
                                    Barcode.Description := POSDesc;
                                    Barcode.MODIFY(TRUE);
                                end;
                        'D':
                            IF Barcode.GET(Bar) THEN
                                Barcode.DELETE(TRUE);
                    END;
                IF VendorNo <> '' THEN BEGIN
                    IF NOT Vendor.GET(VendorNo) THEN BEGIN
                        CLEAR(Vendor);
                        Vendor."No." := VendorNo;
                        Vendor.INSERT(TRUE);
                    END;
                    Vendor.Validate(Name, VendName);
                    IF VendPostGr = '1' THEN BEGIN
                        Vendor.VALIDATE("Gen. Bus. Posting Group", 'NATIONAL');
                        Vendor."Vendor Posting Group" := 'DOMESTIC';
                    END ELSE BEGIN
                        Vendor.VALIDATE("Gen. Bus. Posting Group", 'FOREIGN');
                        Vendor."Vendor Posting Group" := 'FOREIGN';
                    END;
                    IF CustNo <> '' THEN BEGIN
                        CLEAR(VendorSupplier);
                        VendorSupplier."Vendor No." := VendorNo;
                        VendorSupplier."Supplier No." := CustNo;
                        IF VendorSupplier.INSERT THEN;
                    END;
                    Vendor.MODIFY;
                    Item."Vendor No." := VendorNo;
                END;

                IF ItemStatus = 'D' THEN BEGIN
                    CLEAR(ItemStatusLink);
                    ItemStatusLink."Item No." := ItemNo;
                    ItemStatusLink."Location Code" := StoreCode;
                    ItemStatusLink.VALIDATE("Status Code", 'BLSALE');
                    IF NOT ItemStatusLink.INSERT(TRUE) THEN
                        ItemStatusLink.MODIFY(TRUE);
                END;
                IF ItemStatus = 'A' THEN BEGIN
                    CLEAR(ItemStatusLink);
                    ItemStatusLink.SETRANGE("Item No.", ItemNo);
                    ItemStatusLink.SETRANGE("Location Code", StoreCode);
                    ItemStatusLink.SETRANGE("Status Code", 'BLSALE');
                    ItemStatusLink.DELETEALL(TRUE);
                END;
                IF NOT (StoreCode IN ['AL', 'ALL']) THEN
                    IF STRPOS(Item."Store Groups", StoreCode) = 0 THEN BEGIN
                        IF Item."Store Groups" = '' THEN
                            Item."Store Groups" := StoreCode
                        ELSE
                            Item."Store Groups" := Item."Store Groups" + '_' + StoreCode;
                    END;

                Item.Modify(true);
                Clear(SalesPrice);
                CurrPrice := PriceUtils.GetValidRetailPrice2(RetailSetup."Local Store No.", Item."No.", TODAY, TIME, UOM, '', RetailSetup."Def. VAT Bus. Post Gr. (Price)", '', StoreCode, '', '');

                if Evaluate(SalesPrice."LSC Unit Price Including VAT", CPrice) then;
                if CurrPrice <> (SalesPrice."LSC Unit Price Including VAT" / 100) then begin
                    //IF SalesPrice."Unit Price Including VAT" > 0 THEN BEGIN
                    SalesPrice."LSC Unit Price Including VAT" /= 100;
                    SalesPrice."Item No." := ItemNo;
                    SalesPrice."Sales Type" := SalesPrice."Sales Type"::"Customer Price Group";
                    SalesPrice.VALIDATE("Sales Code", StoreCode);
                    SalesPrice."Starting Date" := GetDate(CSDate);
                    SalesPrice."Ending Date" := GetDate(CEDate);
                    //AM.SK 200223
                    IF SalesPrice."Ending Date" <> 0D THEN
                        IF SalesPrice."Ending Date" < SalesPrice."Starting Date" THEN
                            SalesPrice."Ending Date" := SalesPrice."Starting Date";
                    //<<
                    SalesPrice.VALIDATE("LSC Unit Price Including VAT");
                    IF NOT SalesPrice.INSERT(TRUE) THEN
                        SalesPrice.MODIFY(TRUE);
                end;
                //AM.SK 200223 >>
                /*{
                IF StoreCode <> '' THEN
                IF StoreCode <> 'AL' THEN BEGIN
                //IF SalesPrice."Ending Date" = 0D THEN BEGIN
                  CLEAR(SalesPriceOlder);
                  SalesPriceOlder.RESET;
                  SalesPriceOlder.SETRANGE("Item No.",ItemNo);
                  SalesPriceOlder.SETRANGE("Sales Type",SalesPriceOlder."Sales Type"::"Customer Price Group");
                  SalesPriceOlder.SETRANGE("Sales Code",StoreCode);
                  SalesPriceOlder.SETFILTER("Starting Date",'<%1',SalesPrice."Starting Date");
                  SalesPriceOlder.SETFILTER("Ending Date",'=%1',0D);
                  IF SalesPriceOlder.FINDFIRST THEN REPEAT
                    CLEAR(SalesPriceUpdate);
                    SalesPriceUpdate.RESET;
                    SalesPriceUpdate.SETRANGE("Item No.",ItemNo);
                    SalesPriceUpdate.SETRANGE("Sales Type",SalesPriceUpdate."Sales Type"::"Customer Price Group");
                    SalesPriceUpdate.SETRANGE("Sales Code",StoreCode);
                    SalesPriceUpdate.SETRANGE("Starting Date",SalesPriceOlder."Starting Date");
                    IF SalesPriceUpdate.FINDFIRST THEN BEGIN
                      SalesPriceUpdate.VALIDATE("Ending Date",SalesPrice."Starting Date");
                      SalesPriceUpdate.MODIFY(TRUE);
                    END;
                  UNTIL SalesPriceOlder.NEXT = 0;
                END;
                }*/
                //<<
                UpdatePerDisc(ItemNo);
                UpdateRecipe(Item, SalesPrice);
                //END;
                /*{
                PerDiscLine.RESET;
                PerDiscLine.SETCURRENTKEY(Type,"No.");
                PerDiscLine.SETRANGE(Type,PerDiscLine.Type::Item);
                PerDiscLine.SETRANGE("No.",Item."No.");
                IF PerDiscLine.FINDSET THEN
                  REPEAT
                    PerDiscLine.VALIDATE("No.");
                    PerDiscLine.MODIFY;
                    PerDiscLine.CreateActions(1);
                  UNTIL PerDiscLine.NEXT = 0;
                }*/
            END;
        END;
        iFile.CLOSE;
        //StreamReader.Close(); //CS +

        /*{IF ImportLog.FINDLAST THEN;
        ImportLog."Receipt No." += 1;
        ImportLog."Store No." := TODAY;
        ImportLog."POS Terminal No." := TIME;
        ImportLog.Amount := FileName;
        ImportLog."Transaction ID" := i;
        ImportLog.INSERT;}*/

        AddFileName := Format(Today);
        AddFileName := DelChr(AddFileName, '=', '/');
        AddFileName := DelChr(AddFileName, '=', '/') + DelChr(Format(Time), '=', ':');
        AddFileName := DelChr(AddFileName, '=', ' ');
        _File.Copy('c:\ncr\NAV2016\lsitem.txt', 'c:\ncr\NAV2016\Processed\' + AddFileName + '_lsitem.txt');
        Erase(FileName);
        //ERASE('z:\NAV2016\lsitem.txt');
        Window.Close();
        Commit();
        //ImportGreekDesc; BC Upgrade. Not required as function has all code commented in NAV

        PreActionActions.Run();
        Commit();
        Report.RunModal(Report::"ESL_Export ESL Changes_NT", false, false);
        Commit();
        if GeneralBufferTemp.FindSet() then
            SendEmail;
    end;

    local procedure GetDate(_Date: Code[8]): Date
    var
        I: array[3] of Integer;
    begin
        if (_Date = '') OR (_Date = '99999999') then
            exit(0D);
        Evaluate(I[3], CopyStr(_Date, 1, 4));
        Evaluate(I[2], CopyStr(_Date, 5, 2));
        Evaluate(I[1], CopyStr(_Date, 7, 2));
        exit(DMY2Date(I[1], I[2], I[3]));
    end;

    local procedure ProcessLine()
    begin
        ItemDep := '';
        ItemDepDesc := '';
        ItemBrand := '';
        ItemBrandDesc := '';
        GreekDesc := '';
        CompUOM := '';
        WeightPerUnit := 0;
        ESLDesc := '';
        ESLENGDesc := '';

        StoreCode := COPYSTR(iLine, 1, 2);
        ItemNo := COPYSTR(iLine, 3, 15);
        Bar := COPYSTR(iLine, 18, 13);
        Desc := COPYSTR(iLine, 31, 36);
        POSDesc := COPYSTR(iLine, 67, 20);
        VATCode := COPYSTR(iLine, 87, 1);
        UOM := COPYSTR(iLine, 88, 2);
        DivCode := COPYSTR(iLine, 90, 2);
        DivDesc := COPYSTR(iLine, 92, 30);
        ItemCatCode := COPYSTR(iLine, 122, 2);

        ItemCatCode := DivCode + ItemCatCode;

        ItemCatDesc := COPYSTR(iLine, 124, 30);
        PGCode := COPYSTR(iLine, 154, 3);
        PGDesc := COPYSTR(iLine, 157, 30);
        ItemFam := COPYSTR(iLine, 187, 3);
        ItemFamDesc := COPYSTR(iLine, 190, 30);
        VendorNo := COPYSTR(iLine, 220, 3);
        VendName := COPYSTR(iLine, 223, 30);
        VendPostGr := COPYSTR(iLine, 253, 1);
        CPrice := COPYSTR(iLine, 254, 8);
        CSDate := COPYSTR(iLine, 262, 8);
        CEDate := COPYSTR(iLine, 270, 8);
        ItemStatus := COPYSTR(iLine, 278, 1);

        CLEAR(ItemDep);
        CLEAR(ItemDepDesc);
        IF STRLEN(iLine) > 278 THEN BEGIN
            ItemDep := COPYSTR(iLine, 279, 2);
            ItemDepDesc := COPYSTR(iLine, 281, 30);
        END;
        IF STRLEN(iLine) < 311 THEN
            EXIT;

        ItemBrand := COPYSTR(iLine, 311, 3);
        ItemBrandDesc := COPYSTR(iLine, 314, 30);

        IF STRLEN(iLine) < 400 THEN
            EXIT;

        GreekDesc := COPYSTR(iLine, 352, 40);
        CompUOM := COPYSTR(iLine, 392, 3);
        IF NOT EVALUATE(WeightPerUnit, COPYSTR(iLine, 395, 5)) THEN
            WeightPerUnit := 0;

        ESLDesc := COPYSTR(iLine, 400, 8); //Ch
        ESLDesc := DELCHR(ESLDesc, '<>', ' ');//Trim Trailing and Leading
        ESLDesc := DELCHR(ESLDesc, '=', ' ');//Trim all spaces inside

        IF STRLEN(iLine) < 409 THEN
            EXIT;

        ESLENGDesc := COPYSTR(iLine, 408, 30);

        IF STRLEN(iLine) < 448 THEN
            EXIT;

        EveryDayLowPrice := COPYSTR(iLine, 448, 1) = '1';
    end;

    LOCAL procedure UpdatePerDisc(ItemNo: Code[20])
    var
        PerDiscLine: Record "LSC Periodic Discount Line";
        PeriodicDiscount: Record "LSC Periodic Discount";
        SalesPrice: Record "Sales Price";
        ActionsMgt: Codeunit "LSC Actions Management";
        RetailPriceUtil: Codeunit "LSC Retail Price Utils";
        RecRef: RecordRef;
        PG: Code[10];
        OfferPrice: Decimal;
    begin
        PerDiscLine.RESET;
        PerDiscLine.SETCURRENTKEY(Type, "No.");
        PerDiscLine.SETRANGE(Type, PerDiscLine.Type::Item);
        PerDiscLine.SETRANGE("No.", ItemNo);
        PerDiscLine.SETFILTER("Deal Price/Disc. %", '>%1', 0);
        IF PerDiscLine.FINDSET THEN
            REPEAT
                IF PeriodicDiscount.GET(PerDiscLine."Offer No.") THEN
                    if PeriodicDiscount.Status = PeriodicDiscount.Status::Enabled then
                        IF PeriodicDiscount.Type = PeriodicDiscount.Type::"Disc. Offer" THEN BEGIN
                            IF PerDiscLine."Disc. Type" = PerDiscLine."Disc. Type"::"Deal Price" THEN
                                OfferPrice := PerDiscLine."Offer Price Including VAT"
                            ELSE
                                OfferPrice := PerDiscLine."Deal Price/Disc. %";
                            CLEAR(SalesPrice);
                            PG := PeriodicDiscount."Price Group";
                            IF PG = '' THEN
                                PG := 'AL';
                            RetailPriceUtil.GetItemPrice(PG, PerDiscLine."No.", PerDiscLine."Variant Code", TODAY,
                              PerDiscLine."Currency Code", SalesPrice, PerDiscLine."Unit of Measure");
                            PerDiscLine."Standard Price" := SalesPrice."Unit Price";
                            //PerDiscLine.CalcStdPriceWithVAT(); //BC22
                            CalcStdPriceWithVAT(PerDiscLine); //BC22
                            IF PerDiscLine."Disc. Type" = PerDiscLine."Disc. Type"::"Deal Price" THEN
                                PerDiscLine.VALIDATE("Offer Price Including VAT", OfferPrice)
                            ELSE
                                PerDiscLine.VALIDATE("Deal Price/Disc. %", OfferPrice);
                            PerDiscLine.MODIFY;
                            //BC Upgrade Start              
                            /*
                            PerDiscLine.CreateActions(1);
                            PeriodicDiscount.CreateActions(1);
                            */
                            RecRef.GetTable(PeriodicDiscount);
                            ActionsMgt.SetCalledByTableTrigger(false);
                            ActionsMgt.CreateActionsByRecRef(RecRef, RecRef, 1);
                            Clear(RecRef);
                            //Since Periodic Discount Line is modified system should create actions automatically
                            //BC Upgrade End
                        END;
            UNTIL PerDiscLine.NEXT = 0;

    end;

    LOCAL procedure UpdateRecipe(Item: Record Item; SalesPrice: Record "Sales Price")
    var
        BOMComponent2: Record "BOM Component";
        BOMComponent: Record "BOM Component";
        NewSalesPrice: Record "Sales Price";
        Prices: array[4] of Decimal;
    begin
        IF StoreCode <> 'AL' THEN
            EXIT;
        Item.CALCFIELDS("LSC Included in Other Recipes");
        IF NOT Item."LSC Included in Other Recipes" THEN
            EXIT;
        BOMComponent.SETCURRENTKEY(Type, "No.");
        BOMComponent.SETRANGE(Type, BOMComponent.Type::Item);
        BOMComponent.SETRANGE("No.", Item."No.");
        BOMComponent.FINDSET;
        REPEAT
            IF BOMComponent."Unit Price" <> SalesPrice."LSC Unit Price Including VAT" THEN BEGIN
                BOMComponent2.SETRANGE("Parent Item No.", BOMComponent."Parent Item No.");
                BOMComponent2.CALCSUMS("Line Amount");
                Prices[1] := BOMComponent2."Line Amount";
                Prices[3] := BOMComponent."Unit Price";
                Prices[4] := SalesPrice."LSC Unit Price Including VAT";
                BOMComponent."Unit Price" := SalesPrice."LSC Unit Price Including VAT";
                BOMComponent."Line Amount" := SalesPrice."LSC Unit Price Including VAT" * BOMComponent."Quantity per";
                BOMComponent.MODIFY;
                BOMComponent2.SETRANGE("Parent Item No.", BOMComponent."Parent Item No.");
                BOMComponent2.CALCSUMS("Line Amount");
                Prices[2] := BOMComponent2."Line Amount";
                CLEAR(NewSalesPrice);
                NewSalesPrice."Item No." := BOMComponent."Parent Item No.";
                NewSalesPrice."Sales Type" := SalesPrice."Sales Type"::"Customer Price Group";
                NewSalesPrice.VALIDATE("Sales Code", SalesPrice."Sales Code");
                NewSalesPrice."Starting Date" := SalesPrice."Starting Date";
                NewSalesPrice."Ending Date" := SalesPrice."Ending Date";
                NewSalesPrice.VALIDATE("LSC Unit Price Including VAT", BOMComponent2."Line Amount");
                IF NOT NewSalesPrice.INSERT(TRUE) THEN
                    NewSalesPrice.MODIFY(TRUE);
                UpdatePriceChange(BOMComponent, Prices);
            END;
        UNTIL BOMComponent.NEXT = 0;
    end;

    local procedure UpdatePriceChange(BOMComponent: Record "BOM Component"; Prices: array[4] of Decimal)
    begin
        if not GeneralBufferTemp.Get(BOMComponent."Parent Item No.", BOMComponent."LSC Item No.") then begin
            GeneralBufferTemp."Code 1" := BOMComponent."Parent Item No.";
            GeneralBufferTemp."Code 2" := BOMComponent."LSC Item No.";
            GeneralBufferTemp."Decimal 1" := Prices[1];
            GeneralBufferTemp."Decimal 2" := Prices[2];
            GeneralBufferTemp."Decimal 3" := Prices[3];
            GeneralBufferTemp."Decimal 4" := Prices[4];
            GeneralBufferTemp.INSERT;
        end;
    end;

    local procedure SendEmail()
    var
        RetailSetup: Record "LSC Retail Setup";
        EmailMsg: Codeunit "Email Message";
        EmailSend: Codeunit Email;
        ResultOk: Boolean;
        Env: DotNet Environment;
    begin
        RetailSetup.Get();
        if RetailSetup."Price Change Email" = '' then
            exit;
        EmailMsg.Create(RetailSetup."Price Change Email", 'Price Changes', '', false);
        repeat
            EmailMsg.AppendToBody(StrSubstNo('Item %1 part of recipe %2 had a price change form %3 to %4', GeneralBufferTemp."Code 2", GeneralBufferTemp."Code 1", GeneralBufferTemp."Decimal 3", GeneralBufferTemp."Decimal 4"));
            EmailMsg.AppendToBody(Env.NewLine);
        until GeneralBufferTemp.Next() = 0;
        ResultOk := EmailSend.Send(EmailMsg, Enum::"Email Scenario"::Default);
    end;

    local procedure SetFileName(Name: Text)
    begin
        FileName := Name;
    end;

    internal procedure CalcStdPriceWithVAT(var REC: Record "LSC Periodic Discount Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GetBaseTables(REC);

        FindVATPostingGroup(VATPostingSetup);
        REC."Standard Price Including VAT" := Round(REC."Standard Price" * (1 + VATPostingSetup."VAT %" / 100));
    end;

    internal procedure GetBaseTables(var REC: Record "LSC Periodic Discount Line")
    begin
        if REC.Type = REC.Type::Item then
            Item.Get(REC."No.")
        else
            item.Init();

        if PeriodicDiscount.Get(Rec."Offer No.") then;

        if not PriceGroup.Get(PeriodicDiscount."Price Group") then
            PriceGroup.Init;

        if not BackOfficeSetup.Get then
            exit;

        if not Store.Get(BackOfficeSetup."Local Store No.") then
            exit;

        if not POSFuncProfile.Get(Store."Functionality Profile") then
            exit;        
    end;

    internal procedure FindVATPostingGroup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        if PeriodicDiscount."Price Group" = '' then begin
            if not VATPostingSetup.Get(Store."Store VAT Bus. Post. Gr.", Item."VAT Prod. Posting Group") then
                VATPostingSetup.Init;
        end else
            if not VATPostingSetup.Get(PriceGroup."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
                VATPostingSetup.Init;

        case VATPostingSetup."VAT Calculation Type" of
            VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                VATPostingSetup."VAT %" := 0;
            VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                begin
                    if LocalizationExt.IsNALocalizationEnabled then
                        VATPostingSetup."VAT %" := 0
                    else
                        Error(Text004 +
                          Text005, VATPostingSetup.FieldCaption("VAT Calculation Type"),
                          VATPostingSetup."VAT Calculation Type");
                end;
        end;
    end;

    var
        BackOfficeSetup: Record "LSC Retail Setup";
        GeneralBufferTemp: Record "eCom_General Buffer_NT" temporary;
        Item: Record Item;
        PeriodicDiscount: Record "LSC Periodic Discount";
        POSFuncProfile: Record "LSC POS Func. Profile";
        PriceGroup: Record "Customer Price Group";
        Store: Record "LSC Store";
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        iFile: File;
        iStream: InStream;
        EveryDayLowPrice: Boolean;
        Bar: Code[13];
        CEDate: Code[8];
        CPrice: Code[8];
        CSDate: Code[8];
        CustNo: Code[10];
        DivCode: Code[2];
        ItemBrand: Code[10];
        ItemCatCode: Code[4];
        ItemDep: Code[10];
        ItemFam: Code[3];
        ItemNo: Code[15];
        ItemStatus: Code[1];
        PGCode: Code[3];
        StoreCode: Code[3]; // BC Upgrade.Changed length from 2 to 3.
        UOM: Code[2];
        VATCode: Code[1];
        VendorNo: Code[3];
        VendPostGr: Code[1];
        WeightPerUnit: Decimal;
        CompUOM: Text[3];
        Desc: Text[36];
        DivDesc: Text[30];
        ESLDesc: Text[8];
        ESLENGDesc: Text[30];
        FileName: Text;
        GreekDesc: Text[40];
        iLine: Text[1024];
        ItemBrandDesc: Text;
        ItemCatDesc: Text[30];
        ItemDepDesc: Text;
        ItemFamDesc: Text[30];
        PGDesc: Text[30];
        POSDesc: Text[20];
        VendName: Text[30];
        Text004: Label 'Prices including VAT cannot be calculated when';
        Text005: Label '%1 is %2.';
        encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
}
