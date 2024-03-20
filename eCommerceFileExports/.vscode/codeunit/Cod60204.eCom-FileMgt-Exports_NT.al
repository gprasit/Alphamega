codeunit 60204 "eCom-Exports_NT"
{
    TableNo = "LSC Scheduler Job Header";
    trigger OnRun()
    var
        FileName: Text;
    begin
        IF Rec.Text = '' THEN
            EXIT;

        Char[1] := 13;
        Char[2] := 10;
        NewLine := FORMAT(Char[1]) + FORMAT(Char[2]);

        FileName := TEMPORARYPATH + 'tmp.txt';
        FileName := 'MyTestFile.txt';
        IF EXISTS(FileName) THEN
            ERASE(FileName);

        oFile.CREATE(FileName);
        oFile.CREATEOUTSTREAM(oStream);


        CASE Rec.Integer OF
            1:
                ExportItems;
            2:
                ExportInventory;
            3:
                ExportFoodyItems;
            4:
                ExportInventoryNew;
        end;

        oFile.Close();

        if Exists(Text) then
            Erase(Text);

        File.Rename(FileName, Text);
    end;

    procedure ExportItems()
    var
        OfferLine: Record "LSC Offer Line";
        PerDiscLine: Record "LSC Periodic Discount Line";
        PriceListLine: Record "Price List Line";
        Euro: Char;
        OfferNo: Code[20];
        CompPrice: Decimal;
        CompUOM: Decimal;
        _OriginalPrice: Decimal;
        CompPriceText: Text;
        PerDiscNo: Code[20];
        FinalPrice: Decimal;
        EveryDayLowPrice: Text;
        StockText: Text;
        CustomSticker: Text[30];
        CompOriginalPrice: Decimal;
        CompOriginalPriceText: Text;
    begin
        oStream.WRITETEXT('"PRODUCTID";"PRODUCTPRICE";"DISCOUNTPERC";"ORIGINALPRICE";"INOFFER";"STATUS";"COMPPRICE";"OFFERNO"' +
  ';"PERDISC";"EVERYDAYLOWPRICE";"COMPORIGINALPRICE";"STOCK";"CUSTOMSTICKER";"ONLY";"WEEKPICK";"PROMOTED";"PREMIUM"' + NewLine);
        WebItemSubstitution.SETCURRENTKEY("Item No.");
        Item.SETCURRENTKEY("Web Item");
        Item.SETRANGE("Web Item", TRUE);
        //Item.SETRANGE(Item."No.",'805407');
        //Item.SETRANGE("No.",'903084');
        //Item.SETRANGE("No.",'873534');
        //Item.SETFILTER("No.",'876027|852368');
        Euro := 8364;
        IF Item.FINDSET THEN
            REPEAT
                IF NOT WebItemSubstitution2.GET(Item."No.") THEN BEGIN
                    OriginalPrice := 0;
                    DiscPerc := '';
                    InOffer := FALSE;
                    OfferNo := '';
                    PerDiscNo := '';
                    IF InValidOffer(OfferLine) THEN BEGIN
                        //BC Upgrade Start
                        /*
                         RTU.GetItemPrice('AL', Item."No.", '', TODAY, '', SalesPrice, Item."Sales Unit of Measure");
                         Price := SalesPrice."Unit Price Including VAT";
                         */
                        //BC Upgrade end
                        RTU.GetItemPrice('AL', Item."No.", '', TODAY, '', PriceListLine, Item."Sales Unit of Measure");//BC Upgrade
                        Price := PriceListLine."LSC Unit Price Including VAT";//BC Upgrade

                        OriginalPrice := OfferLine."Standard Price Including VAT";
                        IF COPYSTR(OfferLine."Offer No.", 1, 2) = 'SP' THEN
                            DiscPerc := 'Super Price -' + FORMAT(OfferLine."Disc. %", 0, '<Integer>') + '%'
                        ELSE
                            DiscPerc := '-' + FORMAT(OfferLine."Disc. %", 0, '<Integer>') + '%';
                        InOffer := TRUE;
                        OfferNo := OfferLine."Offer No.";
                    END ELSE
                        IF InValidDiscOffer(PerDiscLine) THEN BEGIN
                            Price := PerDiscLine."Offer Price Including VAT";
                            OriginalPrice := PerDiscLine."Standard Price Including VAT";
                            DiscPerc := '-' + FORMAT(PerDiscLine."Deal Price/Disc. %", 0, '<Integer>') + '%';
                            InOffer := TRUE;
                            IF PerDiscLine."Discount Offer No." <> '' THEN
                                PerDiscNo := PerDiscLine."Discount Offer No."
                            ELSE
                                PerDiscNo := PerDiscLine."Offer No.";
                        END ELSE BEGIN
                            //BC Upgrade Start
                            /*
                            RTU.GetItemPrice('AL', Item."No.", '', TODAY, '', SalesPrice, Item."Sales Unit of Measure");
                            Price := SalesPrice."Unit Price Including VAT";
                            */
                            //BC Upgrade end
                            RTU.GetItemPrice('AL', Item."No.", '', TODAY, '', PriceListLine, Item."Sales Unit of Measure");//BC Upgrade
                            Price := PriceListLine."LSC Unit Price Including VAT";//BC Upgrade
                        END;
                    //FinalPrice := ROUND(Price,0.01);mk
                    IF (Item."Web Weight" > 0) THEN BEGIN
                        Price := Price * Item."Web Weight";
                        OriginalPrice := OriginalPrice * Item."Web Weight";
                    END;
                    FinalPrice := ROUND(Price, 0.01);//mk
                    CustomSticker := PointOfferSticker();

                    CompUOM := 0;
                    CompPrice := 0;
                    CompPriceText := '';
                    //ms added to reset
                    CompOriginalPrice := 0;
                    CompOriginalPriceText := '';
                    // ms end
                    IF Item."Comparison UOM" = '001' THEN
                        IF UPPERCASE(Item."ESL Description") = '1/PCS' THEN BEGIN
                            Item."Comparison UOM" := '1';
                            //Item."Actual Weight" := 1;
                        END ELSE
                            Item."Comparison UOM" := '1000';

                    IF EVALUATE(CompUOM, Item."Comparison UOM") THEN
                        IF Item."Actual Weight" <> 0 THEN BEGIN
                            IF Item."Web Weight Item" THEN
                                //CompPrice := FinalPrice * Item."Actual Weight" / CompUOM mk
                                CompPrice := FinalPrice / Item."Web Weight" //mk
                            ELSE
                                CompPrice := CompUOM * FinalPrice / Item."Actual Weight";
                        END;

                    IF (CompPrice <> 0) AND (CompPrice <> Price) THEN BEGIN
                        CompPrice := ROUND(CompPrice, 0.01);
                        CompPriceText := DELCHR(Item."ESL Description", '=', '\');
                        CompPriceText := DELCHR(CompPriceText, '=', '/');
                        CompPriceText := DELCHR(CompPriceText, '=', ' ');
                        CompPriceText := STRSUBSTNO('%1/%2', FORMAT(CompPrice, 0, '<Integer><Decimals,3>'), CompPriceText);
                    END;
                    EveryDayLowPrice := 'No';
                    IF Item."Every Day Low Price" THEN
                        EveryDayLowPrice := 'Yes';
                    IF (OriginalPrice <> 0) THEN BEGIN
                        IF EVALUATE(CompUOM, Item."Comparison UOM") THEN
                            IF Item."Actual Weight" <> 0 THEN BEGIN
                                IF Item."Web Weight Item" THEN
                                    //CompOriginalPrice := OriginalPrice * Item."Actual Weight" / CompUOM
                                    CompOriginalPrice := OriginalPrice / Item."Web Weight"
                                ELSE
                                    CompOriginalPrice := CompUOM * OriginalPrice / Item."Actual Weight";
                            END;
                        IF (CompOriginalPrice <> 0) AND (CompOriginalPrice <> OriginalPrice) THEN BEGIN
                            CompOriginalPrice := ROUND(CompOriginalPrice, 0.01);
                            CompOriginalPriceText := DELCHR(Item."ESL Description", '=', '\');
                            CompOriginalPriceText := DELCHR(CompOriginalPriceText, '=', '/');
                            CompOriginalPriceText := DELCHR(CompOriginalPriceText, '=', ' ');
                            CompOriginalPriceText := STRSUBSTNO('%1/%2', FORMAT(CompOriginalPrice, 0, '<Integer><Decimals,3>'), CompOriginalPriceText);
                        END;
                    END;

                    Price := ROUND(Price, 0.01);
                    OriginalPrice := ROUND(OriginalPrice, 0.01);
                    IF (Item."LSC Division Code" = '02') OR (Item."LSC Item Family Code" = '006') OR
                        (Item."LSC Retail Product Code" IN ['822', '824', '701', '702', '703', '704', '705', '706', '707', '708', '709', '710', '711', '712', '713', '714', '715',
                        'G39', 'G43', 'G44', 'G45', 'G46', 'G55', 'G56', 'G70', 'G73', 'G74', 'G75', 'G76', 'G77', 'G79', 'G80', 'G81', 'G82', 'G84', 'G86', 'G90', 'H52', 'H53',
                        'H70', 'J12', 'P21', 'P27', 'P45', 'P48', 'P49', 'P50', 'P51', 'P53']) THEN
                        StockText := 'STOCKGRP3'
                    ELSE
                        StockText := 'STOCKGRP2';
                    WebItemSubstitution.SETRANGE("Item No.", Item."No.");
                    IF WebItemSubstitution.FINDSET THEN
                        REPEAT
                            oStream.WRITETEXT('"' + WebItemSubstitution."Web Item No." + '";"' + FORMAT(Price, 0, '<Integer><Decimals,3>') + '";"' +
                              DiscPerc + '";"' + FORMAT(OriginalPrice, 0, '<Integer><Decimals,3>') + '";"' + FORMAT(InOffer) + '";"' + ' ' +
                              '";"' + CompPriceText + '";"' + OfferNo + '";"' + PerDiscNo + '";"' + EveryDayLowPrice + '";"' + CompOriginalPriceText + '";"' + StockText + '";"'
                              + CustomSticker + '"' + '";"' + BooleanValue(Item."Web Special Offer") + '";"' + BooleanValue(Item."Pick Of The Week") +
             '";"' + BooleanValue(Item."Promoted Product") + '";"' + BooleanValue(Item."Premium Package") + '"' + NewLine);
                        UNTIL WebItemSubstitution.NEXT = 0
                    ELSE
                        oStream.WRITETEXT('"' + Item."No." + '";"' + FORMAT(Price, 0, '<Integer><Decimals,3>') + '";"' +
                          DiscPerc + '";"' + FORMAT(OriginalPrice, 0, '<Integer><Decimals,3>') + '";"' + FORMAT(InOffer) + '";"' + FORMAT(Item."Web Item Status") +
                          '";"' + CompPriceText + '";"' + OfferNo + '";"' + PerDiscNo + '";"' + EveryDayLowPrice + '";"' + CompOriginalPriceText + '";"' + StockText + '";"'
                          + CustomSticker + '"' + '";"' + BooleanValue(Item."Web Special Offer") + '";"' + BooleanValue(Item."Pick Of The Week") +
            '";"' + BooleanValue(Item."Promoted Product") + '";"' + BooleanValue(Item."Premium Package") + '"' + NewLine);
                END;
            UNTIL Item.NEXT = 0;

    end;

    procedure ExportInventory()
    begin
        oStream.WRITETEXT('"ItemNo";"BarcodeNo";"Total"' + NewLine);
        Item.SETCURRENTKEY("Web Item");
        Item.SETRANGE("Web Item", TRUE);
        IF Item.FINDSET THEN
            REPEAT
                Item.CALCFIELDS(Inventory);
                /*BC Upgrade. DefaultBarcode Function removed by LS
                oStream.WRITETEXT('"' + Item."No." + '";"' + Item.DefaultBarcode + '";"' +
                  FORMAT(Item.Inventory, 0, '<Integer>') + '"' + NewLine);
                  */
                oStream.WRITETEXT('"' + Item."No." + '";"' + DefaultBarcode(Item."No.") + '";"' +
                FORMAT(Item.Inventory, 0, '<Integer>') + '"' + NewLine);
            UNTIL Item.NEXT = 0;
    end;

    procedure InValidOffer(VAR OfferLine: Record "LSC Offer Line"): Boolean
    var
        Offer: Record "LSC Offer";
    begin
        EXIT(FALSE);
        OfferLine.SETCURRENTKEY(Type, "No.");
        OfferLine.SETRANGE(Type, OfferLine.Type::Item);
        OfferLine.SETRANGE("No.", Item."No.");
        IF NOT OfferLine.FINDFIRST THEN
            EXIT(FALSE);
        REPEAT
            Offer.GET(OfferLine."Offer No.");
            IF Offer.Status = Offer.Status::Enabled THEN
                IF RTU.DiscValPerValid(Offer."Validation Period ID", TODAY, 0T) THEN
                    EXIT(TRUE);
        UNTIL OfferLine.NEXT = 0;
        EXIT(FALSE);
    end;

    procedure InValidDiscOffer(VAR PerDiscLine: Record "LSC Periodic Discount Line"): Boolean
    var
        PerDisc: Record "LSC Periodic Discount";
    begin
        PerDiscLine.SETCURRENTKEY(Type, "No.");
        PerDiscLine.SETRANGE(Type, PerDiscLine.Type::Item);
        PerDiscLine.SETRANGE("No.", Item."No.");
        IF NOT PerDiscLine.FINDFIRST THEN
            EXIT(FALSE);
        REPEAT
            PerDisc.GET(PerDiscLine."Offer No.");
            IF IsOfferValidForWeb(PerDisc) THEN
                IF (PerDisc.Status = PerDisc.Status::Enabled) AND (PerDisc.Type = PerDisc.Type::"Disc. Offer") THEN
                    IF RTU.DiscValPerValid(PerDisc."Validation Period ID", TODAY, 0T) THEN
                        EXIT(TRUE);
        UNTIL PerDiscLine.NEXT = 0;
        EXIT(FALSE);
    end;

    local procedure IsOfferValidForWeb(PerDisc: Record "LSC Periodic Discount"): Boolean
    var
        DistributionList: Record "LSC Distribution List";
    begin
        IF PerDisc."Customer Disc. Group" <> '' THEN
            EXIT(FALSE);
        IF PerDisc."Coupon Code" <> '' THEN
            EXIT(FALSE);
        IF PerDisc."Amount to Trigger" <> 0 THEN
            EXIT(FALSE);
        IF PerDisc."Member Value" <> '' THEN
            EXIT(FALSE);
        IF PerDisc."Member Attribute" <> '' THEN
            EXIT(FALSE);
        IF PerDisc."Price Group" <> 'AL' THEN
            EXIT(FALSE);

        DistributionList.SETRANGE("Table ID", DATABASE::"LSC Periodic Discount");
        DistributionList.SETRANGE(Value, PerDisc."No.");
        IF DistributionList.COUNT = 1 THEN BEGIN
            DistributionList.FINDFIRST;
            IF (DistributionList."Group Code" = 'STORES') AND (DistributionList."Subgroup Code" = '0011') THEN
                EXIT(FALSE);
        END;

        EXIT(TRUE);
    end;

    local procedure DefaultBarcode(ItemNo: Code[20]): Code[20]
    var
        Barcodes: Record "LSC Barcodes";
    begin
        //LS
        //DefaultBarcode

        Barcodes.SETCURRENTKEY("Item No.", "Barcode No.");
        Barcodes.SETRANGE("Item No.", ItemNo);
        Barcodes.SETRANGE("Show for Item", TRUE);
        IF Barcodes.FIND('-') THEN
            EXIT(Barcodes."Barcode No.")
        ELSE BEGIN
            Barcodes.SETRANGE("Show for Item", FALSE);
            IF Barcodes.FIND('-') THEN
                EXIT(Barcodes."Barcode No.");
        END;
        EXIT('');
    end;

    procedure ExportFoodyItems()
    var

        SalesPrice: Record "Sales Price";
        OfferLine: Record "LSC Offer Line";
        PerDiscLine: Record "LSC Periodic Discount Line";
        WebItemSubstitution: Record "eCom_Web Item Substitution_NT";
        WebItemSubstitution2: Record "eCom_Web Item Substitution_NT";
        CompPrice: Decimal;
        CompUOM: Decimal;
        CompPriceText: Text;
        Euro: Char;
        OfferNo: Code[20];
        _OriginalPrice: Decimal;
        PriceListLine: Record "Price List Line";
    begin
        oStream.WRITETEXT('"PRODUCTID";"PRODUCTPRICE";"DISCOUNTPERC";"ORIGINALPRICE";"INOFFER";"STATUS";"COMPPRICE";"OFFERNO"' + NewLine);
        Item.SETCURRENTKEY("Foody Item");
        Item.SETRANGE("Foody Item", TRUE);
        Euro := 8364;
        IF Item.FINDSET THEN
            REPEAT
                IF NOT WebItemSubstitution2.GET(Item."No.") THEN BEGIN
                    OriginalPrice := 0;
                    DiscPerc := '';
                    InOffer := FALSE;
                    OfferNo := '';
                    IF InValidOffer(OfferLine) THEN BEGIN
                        //BC Upgrade Start
                        /*

                        RTU.GetItemPrice('AL', Item."No.", '', TODAY, '', SalesPrice, Item."Sales Unit of Measure");
                        Price := SalesPrice."Unit Price Including VAT";   
                        */
                        //BC Upgrade End     
                        RTU.GetItemPrice('AL', Item."No.", '', TODAY, '', PriceListLine, Item."Sales Unit of Measure");//BC Upgrade
                        Price := PriceListLine."LSC Unit Price Including VAT";//BC Upgrade
                        OriginalPrice := OfferLine."Standard Price Including VAT";
                        IF COPYSTR(OfferLine."Offer No.", 1, 2) = 'SP' THEN
                            DiscPerc := 'Super Price -' + FORMAT(OfferLine."Disc. %", 0, '<Integer>') + '%'
                        ELSE
                            DiscPerc := '-' + FORMAT(OfferLine."Disc. %", 0, '<Integer>') + '%';
                        InOffer := TRUE;
                        OfferNo := OfferLine."Offer No.";
                    END ELSE
                        IF InValidDiscOffer(PerDiscLine) THEN BEGIN
                            Price := PerDiscLine."Offer Price Including VAT";
                            OriginalPrice := PerDiscLine."Standard Price Including VAT";
                            DiscPerc := '-' + FORMAT(PerDiscLine."Deal Price/Disc. %", 0, '<Integer>') + '%';
                            InOffer := TRUE;
                            IF PerDiscLine."Discount Offer No." <> '' THEN
                                OfferNo := PerDiscLine."Discount Offer No."
                            ELSE
                                OfferNo := PerDiscLine."Offer No.";
                        END ELSE BEGIN
                            //BC Upgrade Start
                            /*
                                RTU.GetItemPrice('AL', Item."No.", '', TODAY, '', SalesPrice, Item."Sales Unit of Measure");
                                Price := SalesPrice."Unit Price Including VAT";
                                */
                            RTU.GetItemPrice('AL', Item."No.", '', TODAY, '', PriceListLine, Item."Sales Unit of Measure");
                            Price := PriceListLine."LSC Unit Price Including VAT";
                            //BC Upgrade End

                        END;
                    _OriginalPrice := ROUND(Price, 0.01);
                    IF (Item."Web Weight" > 0) THEN BEGIN
                        Price := Price * Item."Web Weight";
                        OriginalPrice := OriginalPrice * Item."Web Weight";
                    END;

                    CompUOM := 0;
                    CompPrice := 0;
                    CompPriceText := '';
                    IF Item."Comparison UOM" = '001' THEN
                        IF UPPERCASE(Item."ESL Description") = '1/PCS' THEN BEGIN
                            Item."Comparison UOM" := '1';
                            Item."Actual Weight" := 1;
                        END ELSE
                            Item."Comparison UOM" := '1000';

                    IF EVALUATE(CompUOM, Item."Comparison UOM") THEN
                        IF Item."Actual Weight" <> 0 THEN BEGIN
                            IF Item."Web Weight Item" THEN
                                CompPrice := _OriginalPrice * Item."Actual Weight" / CompUOM
                            ELSE
                                CompPrice := CompUOM * _OriginalPrice / Item."Actual Weight";
                        END;

                    IF (CompPrice <> 0) AND (CompPrice <> Price) THEN BEGIN
                        CompPrice := ROUND(CompPrice, 0.01);
                        CompPriceText := DELCHR(Item."ESL Description", '=', '\');
                        CompPriceText := DELCHR(CompPriceText, '=', '/');
                        CompPriceText := DELCHR(CompPriceText, '=', ' ');
                        CompPriceText := STRSUBSTNO('%1/%2', FORMAT(CompPrice, 0, '<Integer><Decimals,3>'), CompPriceText);
                    END;

                    Price := ROUND(Price, 0.01);
                    OriginalPrice := ROUND(OriginalPrice, 0.01);
                    WebItemSubstitution.SETRANGE("Item No.", Item."No.");
                    IF WebItemSubstitution.FINDSET THEN
                        REPEAT
                            oStream.WRITETEXT('"' + WebItemSubstitution."Web Item No." + '";"' + FORMAT(Price, 0, '<Integer><Decimals,3>') + '";"' +
                              DiscPerc + '";"' + FORMAT(OriginalPrice, 0, '<Integer><Decimals,3>') + '";"' + FORMAT(InOffer) + '";"' + ' ' +
                              '";"' + CompPriceText + '";"' + OfferNo + '"' + NewLine);
                        UNTIL WebItemSubstitution.NEXT = 0
                    ELSE
                        oStream.WRITETEXT('"' + Item."No." + '";"' + FORMAT(Price, 0, '<Integer><Decimals,3>') + '";"' +
                          DiscPerc + '";"' + FORMAT(OriginalPrice, 0, '<Integer><Decimals,3>') + '";"' + FORMAT(InOffer) + '";"' + '' +// FORMAT(Item."Web Item Status") +
                          '";"' + CompPriceText + '";"' + OfferNo + '"' + NewLine);
                END;
            UNTIL Item.NEXT = 0;

    end;

    procedure ExportInventoryNew()
    var

        Store: Record "LSC Store";
        ImportWebItem: Codeunit "eCom-Import Web Item_NT";
        SkipInv: Boolean;
        Total: Decimal;
        WebItemSubstitution: Record "eCom_Web Item Substitution_NT";
        HasParent: Boolean;
        ParentItem: Record Item;
        TMPItem: Record Item temporary;
    begin
        oStream.WRITETEXT('"ProductId";"StockUnitId";"StockLocation";"StockQuantity";"StockUnitHeight";"StockUnitWidth";"StockUnitDepth";"StockUnitNeverOutOfStock"' + NewLine);
        Item.SETCURRENTKEY("Web Item");
        Item.SETRANGE("Web Item", TRUE);
        Store.SETFILTER("Web Store No.", '<>%1', '');
        IF NOT Store.FINDSET THEN
            EXIT;

        WebItemSubstitution.SETCURRENTKEY("Item No.");
        IF Item.FINDSET THEN
            REPEAT
                TMPItem := Item;
                IF TMPItem.INSERT THEN;
                WebItemSubstitution.SETRANGE("Item No.", Item."No.");
                IF WebItemSubstitution.FINDSET THEN
                    REPEAT
                        ParentItem.GET(WebItemSubstitution."Web Item No.");
                        TMPItem := ParentItem;
                        IF TMPItem.INSERT THEN;
                    UNTIL WebItemSubstitution.NEXT = 0;
            UNTIL Item.NEXT = 0;

        IF TMPItem.FINDFIRST THEN
            REPEAT
                Total := 0;
                Store.FINDFIRST;
                Item := TMPItem;
                REPEAT
                    HasParent := WebItemSubstitution.GET(Item."No.");
                    IF HasParent THEN
                        ParentItem.GET(WebItemSubstitution."Item No.")
                    ELSE
                        ParentItem := Item;
                    IF ImportWebItem.SkipInventoryCheck2(ParentItem) THEN BEGIN
                        SkipInv := TRUE;
                        ParentItem."Item Inventory" := 999;
                    END ELSE BEGIN
                        ParentItem.SETRANGE("Location Filter", Store."No.");
                        ParentItem.CALCFIELDS("Item Inventory");
                    END;
                    Total += ParentItem."Item Inventory";
                    oStream.WRITETEXT('"' + Item."No." + '";"VO87";"' + Store."Web Store No." + '";"' +
                      FORMAT(ParentItem."Item Inventory", 0, '<Integer>') + '";"0";"0";"0";"0"' + NewLine);
                UNTIL Store.NEXT = 0;
                IF SkipInv THEN
                    ParentItem."Item Inventory" := 999
                ELSE BEGIN
                    ParentItem.SETRANGE("Location Filter");
                    ParentItem.CALCFIELDS("Item Inventory");
                END;
                oStream.WRITETEXT('"' + Item."No." + '";"VO87";"1005";"' +
                    FORMAT(Total, 0, '<Integer>') + '";"0";"0";"0";"0"' + NewLine);
            UNTIL TMPItem.NEXT = 0;

    end;

    local procedure PointOfferSticker() CustomSticker: Text[30]
    var
        ItemSpecialGroup: Record "LSC Item/Special Group Link";
        MemberPointOfferLine: Record "LSC Member Point Offer Line";
        OfferNo: Code[20];
        Found: Boolean;
    begin
        Found := FALSE;
        MemberPointOfferLine.SETCURRENTKEY(Type, "No.");
        MemberPointOfferLine.SETRANGE(Type, MemberPointOfferLine.Type::Item);
        MemberPointOfferLine.SETRANGE("No.", Item."No.");
        IF MemberPointOfferLine.FINDFIRST THEN
            REPEAT
                Found := PointOfferIsValid(MemberPointOfferLine, CustomSticker);
                IF Found THEN
                    OfferNo := MemberPointOfferLine."Offer No.";
            UNTIL (MemberPointOfferLine.NEXT = 0) OR Found;

        IF NOT Found THEN BEGIN
            MemberPointOfferLine.SETRANGE(Type, MemberPointOfferLine.Type::"Product Group");
            MemberPointOfferLine.SETRANGE("No.", Item."LSC Retail Product Code");
            MemberPointOfferLine.SETRANGE("Prod. Group Category", Item."Item Category Code");
            IF MemberPointOfferLine.FINDFIRST THEN
                REPEAT
                    Found := PointOfferIsValid(MemberPointOfferLine, CustomSticker);
                    IF Found THEN
                        OfferNo := MemberPointOfferLine."Offer No.";
                UNTIL (MemberPointOfferLine.NEXT = 0) OR Found;
            MemberPointOfferLine.SETRANGE("Prod. Group Category");
        END;

        IF NOT Found THEN BEGIN
            MemberPointOfferLine.SETRANGE(Type, MemberPointOfferLine.Type::"Item Category");
            MemberPointOfferLine.SETRANGE("No.", Item."Item Category Code");
            IF MemberPointOfferLine.FINDFIRST THEN
                REPEAT
                    Found := PointOfferIsValid(MemberPointOfferLine, CustomSticker);
                    IF Found THEN
                        OfferNo := MemberPointOfferLine."Offer No.";
                UNTIL (MemberPointOfferLine.NEXT = 0) OR Found;
        END;

        IF NOT Found THEN BEGIN
            CLEAR(ItemSpecialGroup);
            ItemSpecialGroup.SETRANGE("Item No.", Item."No.");
            IF ItemSpecialGroup.FINDSET THEN BEGIN
                REPEAT
                    MemberPointOfferLine.SETRANGE(Type, MemberPointOfferLine.Type::"Special Group");
                    MemberPointOfferLine.SETRANGE("No.", ItemSpecialGroup."Special Group Code");
                    IF MemberPointOfferLine.FINDFIRST THEN
                        REPEAT
                            Found := PointOfferIsValid(MemberPointOfferLine, CustomSticker);
                            IF Found THEN
                                OfferNo := MemberPointOfferLine."Offer No.";
                        UNTIL (MemberPointOfferLine.NEXT = 0) OR Found;
                UNTIL (ItemSpecialGroup.NEXT = 0) OR Found;
            END;
        END;
        IF NOT Found THEN
            CustomSticker := '';
    end;

    local procedure PointOfferIsValid(MemberPointOfferLine: Record "LSC Member Point Offer Line"; VAR CustomSticker: Text[30]): Boolean
    var
        MemberPointOffer: Record "LSC Member Point Offer";
    begin
        MemberPointOffer.GET(MemberPointOfferLine."Offer No.");
        CustomSticker := MemberPointOffer."Custom Sticker";
        IF IsPointOfferValidForWeb(MemberPointOffer) THEN
            IF (MemberPointOffer.Status = MemberPointOffer.Status::Enabled) THEN
                EXIT(RTU.DiscValPerValid(MemberPointOffer."Validation Period ID", TODAY, 0T));
    end;

    local procedure IsPointOfferValidForWeb(MemberPointOffer: Record "LSC Member Point Offer"): Boolean
    var
        DistributionList: Record "LSC Distribution List";
    begin
        exit(true);
        IF MemberPointOffer."Customer Disc. Group" <> '' THEN
            EXIT(FALSE);
        IF MemberPointOffer."Amount To Trigger" <> 0 THEN
            EXIT(FALSE);
        IF MemberPointOffer."Member Value" <> '' THEN
            EXIT(FALSE);
        IF MemberPointOffer."Member Attribute" <> '' THEN
            EXIT(FALSE);
        IF MemberPointOffer."Price Group" <> 'AL' THEN
            EXIT(FALSE);

        DistributionList.SETRANGE("Table ID", DATABASE::"LSC Member Point Offer");
        DistributionList.SETRANGE(Value, MemberPointOffer."No.");
        IF DistributionList.COUNT = 1 THEN BEGIN
            DistributionList.FINDFIRST;
            IF (DistributionList."Group Code" = 'STORES') AND (DistributionList."Subgroup Code" = '0011') THEN
                EXIT(FALSE);
        END;

        EXIT(TRUE);

    end;

    local procedure BooleanValue(Bool: Boolean): Text[1]
    begin
        IF Bool THEN
            EXIT('1');
        EXIT('0');
    end;

    var
        Item: Record Item;
        WebItemSubstitution2: Record "eCom_Web Item Substitution_NT";
        WebItemSubstitution: Record "eCom_Web Item Substitution_NT";
        FileMgt: Codeunit "File Management";
        RTU: Codeunit "LSC Retail Price Utils";
        oFile: File;
        InStr: InStream;
        OStream: OutStream;
        InOffer: Boolean;
        ok: Boolean;
        Char: array[2] of Char;
        OriginalPrice: Decimal;
        Price: Decimal;
        DiscPerc: Text[30];
        NewLine: Text[30];

}
