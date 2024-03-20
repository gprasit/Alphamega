codeunit 60103 "eCom_Sales Order Management_NT"
{
    trigger OnRun()
    var
    begin

    end;

    procedure CreateSalesOrder(xmlRequest: Text; VAR xmlResponse: Text): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        XMLDOMManagement: Codeunit "LSC XML DOM Mgt.";
        XMLRootNode: XmlNode;
        XmlDoc: XmlDocument;
        XMLelement: XmlElement;
        OrderID: Text;
        CardNo: Code[20];
        FirstName: Text[50];
        MiddleName: Text[50];
        LastName: Text[50];
        FullName: Text[150];
        Address: Text[250];
        Address2: Text[250];
        City: Text[30];
        County: Text[30];
        PostCode: Code[20];
        PhoneNo: Text[30];
        Email: Text[50];
        CountryRegionCode: Code[20];
        HouseApartmentNo: Text[30];
        MobilePhoneNo: Text[30];
        DaytimePhoneNo: Text[30];
        CustomerNo: Code[20];
        PrimaryContact: Text[50];
        ShiptoFirstName: Text[50];
        ShiptoLastName: Text[50];
        ShiptoFullName: Text[100];
        ShiptoAddress1: Text[250];
        ShiptoAddress2: Text[250];
        ShiptoCity: Text[30];
        ShiptoCounty: Text[30];
        ShiptoPostCode: Code[20];
        ShiptoPhoneNo: Text[30];
        ShiptoCountryRegionCode: Code[20];
        ShiptoHouseApartmentNo: Text[30];
        ContactViaMail: Boolean;
        ContactViaPhone: Boolean;
        ContactViaEmail: Boolean;
        GeneralComments: Text[230];
        DeliveryInstructions: Text[230];
        //         SourceType  Option
        // Status	Option		
        CollectStoreNo: Code[10];
        ShippingZonesCode: Code[10];
        ShippingZonesDescription: Text[30];
        OrderNo: Code[20];
        ExternalDocumentNo: Code[35];
        ReservedByPOSNo: Code[10];
        SelltoContactNo: Code[20];
        StoreNo: Code[10];
        LocationCode: Code[10];
        PostCodeLocation: Record "eCom_Post Code Location_NT";
        ShippingFee: Decimal;
        OrderTimeSlot: Text[20];
        OrderDeliveryDate: Date;
        OrderDeliveryDate_Text: Text[250];
        RCBOrderID: Text;
        RCBSessionID: Text;
        TransactionNumber: Text[50];
        TransactionAmount: Decimal;
        OrderPaymentMethod: Text[50];
        StickAndWinPhone: Text[50];
        DeliveryLatitude: Text;
        DeliveryLongitude: Text;
        ShiptoFlatNumber: Text;
        ShiptoBuildingName: Text;
        FlatNumber: Text;
        BuildingName: Text;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        OrderDeliveryDate_Text_ToSplit: Text[20];
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
        XMLNode2: XmlNode;
        Items: Record "eCom_General Buffer_NT" temporary;
        ItemPrice: Record "eCom_General Buffer_NT" temporary;
        Payments: Record "eCom_General Buffer_NT" temporary;
        Code: Code[10];
        DiscountHeader: Record "eCom_General Buffer_NT" temporary;
        XMLNodeList2: XmlNodeList;
        DiscountLine: Record "eCom_General Buffer_NT" temporary;
        CoordinatesCheked: Boolean;
        WebOrderCoordinates: Record "eCom_Web Order Coordinates_NT";
        NextLineNo: Integer;
        SpecialOfferItem: Record "eCom_Special Offer Item_NT";
        SalesCommentLine: Record "Sales Comment Line";
        SalesPaymentLine: Record "eCom_Sales Payment Line_NT";
        WebOrderPointRedemption: Record "eCom_WebOrd.PointRedemption_NT";
        NextEntryNo: Integer;
        TxtBuilder: TextBuilder;
        CompletedTime: Text[20];
        OrderShippingMethod: Text[50];
        WebOrderAmount: Decimal;
    begin
        Code := '0000';
        if XmlDocument.ReadFrom(xmlRequest, XmlDoc) then begin
            XmlDoc.GetRoot(XMLelement);
            XMLRootNode := XMLelement.AsXmlNode();
        end;
        if XMLRootNode.IsXmlElement then
            if not XMLRootNode.AsXmlElement().IsEmpty then begin
                OrderID := XMLDOMManagement.FindNodeText(XMLRootNode, 'OrderID');
                CardNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'CardNo');
                FirstName := XMLDOMManagement.FindNodeText(XMLRootNode, 'FirstName');
                MiddleName := XMLDOMManagement.FindNodeText(XMLRootNode, 'MiddleName');
                LastName := XMLDOMManagement.FindNodeText(XMLRootNode, 'LastName');
                FullName := XMLDOMManagement.FindNodeText(XMLRootNode, 'FullName');
                Address := XMLDOMManagement.FindNodeText(XMLRootNode, 'Address');
                Address2 := XMLDOMManagement.FindNodeText(XMLRootNode, 'Address2');
                City := XMLDOMManagement.FindNodeText(XMLRootNode, 'City');
                County := XMLDOMManagement.FindNodeText(XMLRootNode, 'County');
                PostCode := XMLDOMManagement.FindNodeText(XMLRootNode, 'PostCode');
                PhoneNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'PhoneNo');
                Email := XMLDOMManagement.FindNodeText(XMLRootNode, 'Email');
                CountryRegionCode := XMLDOMManagement.FindNodeText(XMLRootNode, 'CountryRegionCode');
                HouseApartmentNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'HouseApartmentNo');
                MobilePhoneNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'MobilePhoneNo');
                DaytimePhoneNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'DaytimePhoneNo');
                CustomerNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'CustomerNo');
                PrimaryContact := XMLDOMManagement.FindNodeText(XMLRootNode, 'PrimaryContact');
                ShiptoFirstName := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoFirstName');
                ShiptoLastName := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoLastName');
                ShiptoFullName := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoFullName');
                ShiptoAddress1 := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoAddress1');
                ShiptoAddress2 := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoAddress2');
                ShiptoCity := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoCity');
                ShiptoCounty := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoCounty');
                ShiptoPostCode := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoPostCode');
                ShiptoPhoneNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoPhoneNo');
                ShiptoCountryRegionCode := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoCountryRegionCode');
                ShiptoHouseApartmentNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoHouseApartmentNo');
                //EVALUATE(ContactViaMail,XMLDOMManagement.FindNodeText(XMLRootNode,'ContactViaMail'));
                //EVALUATE(ContactViaPhone,XMLDOMManagement.FindNodeText(XMLRootNode,'ContactViaPhone'));
                //EVALUATE(ContactViaEmail,XMLDOMManagement.FindNodeText(XMLRootNode,'ContactViaEmail'));
                GeneralComments := XMLDOMManagement.FindNodeText(XMLRootNode, 'GeneralComments');
                DeliveryInstructions := XMLDOMManagement.FindNodeText(XMLRootNode, 'DeliveryInstructions');
                CollectStoreNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'CollectStoreNo');
                //EVALUATE(GiftReceipt,XMLDOMManagement.FindNodeText(XMLRootNode,'GiftReceipt'));
                //EVALUATE(GiftCard,XMLDOMManagement.FindNodeText(XMLRootNode,'GiftCard'));
                ShippingZonesCode := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShippingZonesCode');
                ShippingZonesDescription := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShippingZonesDescription');
                OrderNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'OrderNo');
                ExternalDocumentNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'ExternalDocumentNo');
                ReservedByPOSNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'ReservedByPOSNo');
                //WebTransactionGUID := XMLDOMManagement.FindNodeText(XMLRootNode,'WebTransactionGUID');
                SelltoContactNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'SelltoContactNo');
                StoreNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'StoreNo');
                LocationCode := XMLDOMManagement.FindNodeText(XMLRootNode, 'LocationCode');
                LocationCode := '9999';//CS NT
                CompletedTime := XMLDOMManagement.FindNodeText(XMLRootNode, 'CompletedTime');

                IF PostCodeLocation.GET(ShiptoPostCode) THEN BEGIN
                    LocationCode := PostCodeLocation."Location Code";
                    StoreNo := LocationCode;
                END;
                IF EVALUATE(ShippingFee, XMLDOMManagement.FindNodeText(XMLRootNode, 'ShippingFee')) THEN;
                IF ShippingFee >= 0.3 THEN
                    ShippingFee := ShippingFee - 0.3;//20220225 5cent per bag

                OrderTimeSlot := XMLDOMManagement.FindNodeText(XMLRootNode, 'OrderTimeSlot');
                OrderDeliveryDate_Text := XMLDOMManagement.FindNodeText(XMLRootNode, 'OrderDeliveryDate');
                RCBOrderID := XMLDOMManagement.FindNodeText(XMLRootNode, 'RCBOrderID');
                RCBSessionID := XMLDOMManagement.FindNodeText(XMLRootNode, 'RCBSessionID');
                TransactionNumber := XMLDOMManagement.FindNodeText(XMLRootNode, 'TransactionNumber');//CS NT 20220601
                IF EVALUATE(TransactionAmount, XMLDOMManagement.FindNodeText(XMLRootNode, 'TransactionAmount')) THEN;//CS NT 20220601
                OrderPaymentMethod := XMLDOMManagement.FindNodeText(XMLRootNode, 'OrderPaymentMethod');//CS NT 20220705
                OrderShippingMethod := XMLDOMManagement.FindNodeText(XMLRootNode, 'OrderShippingMethod');//CS NT 20230322
                StickAndWinPhone := XMLDOMManagement.FindNodeText(XMLRootNode, 'StickAndWinPhone');
                DeliveryLongitude := FormatCoordinates(XMLDOMManagement.FindNodeText(XMLRootNode, 'DeliveryLongitude'));
                DeliveryLatitude := FormatCoordinates(XMLDOMManagement.FindNodeText(XMLRootNode, 'DeliveryLatitude'));
                ShiptoBuildingName := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoBuildingName');
                ShiptoFlatNumber := XMLDOMManagement.FindNodeText(XMLRootNode, 'ShiptoFlatNumber');
                BuildingName := XMLDOMManagement.FindNodeText(XMLRootNode, 'BuildingName');
                FlatNumber := XMLDOMManagement.FindNodeText(XMLRootNode, 'FlatNumber');
                //CS NT Check Names
                IF ((FirstName <> '') AND (LastName <> '')) THEN BEGIN
                    IF (MiddleName <> '') THEN
                        FullName := FirstName + ' ' + MiddleName + ' ' + LastName
                    ELSE
                        FullName := FirstName + ' ' + LastName;
                END;

                IF ((ShiptoFirstName <> '') AND (ShiptoLastName <> '')) THEN
                    ShiptoFullName := ShiptoFirstName + ' ' + ShiptoLastName;
                IF OrderDeliveryDate_Text <> '' THEN BEGIN
                    /*
      {CS NT OLD 20220829
      IF EVALUATE(Day, COPYSTR(OrderDeliveryDate_Text, 1, 2)) THEN
                            IF EVALUATE(Month, COPYSTR(OrderDeliveryDate_Text, 4, 2)) THEN
                                IF EVALUATE(Year, COPYSTR(OrderDeliveryDate_Text, 7, 4)) THEN
                                    OrderDeliveryDate := DMY2DATE(Day, Month, Year);
       }
    */
                    //CS NT 20220829
                    //Date format 31-08-2022 00:00:00
                    IF EVALUATE(Day, COPYSTR(OrderDeliveryDate_Text, 1, 2)) AND EVALUATE(Month, COPYSTR(OrderDeliveryDate_Text, 4, 2)) AND EVALUATE(Year, COPYSTR(OrderDeliveryDate_Text, 7, 4)) THEN
                        OrderDeliveryDate := DMY2DATE(Day, Month, Year)
                    ELSE BEGIN
                        //Date format sometimes 29/8/2022
                        OrderDeliveryDate_Text_ToSplit := OrderDeliveryDate_Text;
                        DayText := SplitString(OrderDeliveryDate_Text_ToSplit, '/');
                        MonthText := SplitString(OrderDeliveryDate_Text_ToSplit, '/');
                        YearText := SplitString(OrderDeliveryDate_Text_ToSplit, '/');
                        IF EVALUATE(Day, DayText) AND EVALUATE(Month, MonthText) AND EVALUATE(Year, YearText) THEN
                            OrderDeliveryDate := DMY2DATE(Day, Month, Year)
                        ELSE BEGIN
                            xmlResponse := 'Order Delivery Date cannot be parsed';
                            EXIT(FALSE);
                        END;
                    END;
                END
                ELSE BEGIN
                    xmlResponse := 'Order Delivery Date is empty';
                    EXIT(FALSE);
                END;
                IF (OrderID = '') THEN BEGIN
                    xmlResponse := 'OrderID is empty';
                    EXIT(FALSE);
                END;

                CLEAR(SalesHeader);
                IF SalesHeader.GET(SalesHeader."Document Type"::Order, OrderID) THEN BEGIN
                    xmlResponse := 'SalesOrdeNo:' + SalesHeader."No.";
                    EXIT(FALSE);
                END;
                XMLDOMManagement.FindNodes(XMLRootNode, 'ProductLines/Product', XMLNodeList);
                foreach XMLNode in xmlnodelist do begin
                    //XMLNode := Enumerator.Current;
                    CLEAR(Items);
                    Code := INCSTR(Code);
                    Items."Code 1" := Code;
                    Items."Code 6" := XMLDOMManagement.FindNodeText(XMLNode, 'No');
                    Items."Code 7" := XMLDOMManagement.FindNodeText(XMLNode, 'Barcode');
                    Items."Code 8" := XMLDOMManagement.FindNodeText(XMLNode, 'UOM');
                    Items."Code 10" := XMLDOMManagement.FindNodeText(XMLNode, 'DiscountCode');
                    Items."Text 1" := XMLDOMManagement.FindNodeText(XMLNode, 'OfferNo');
                    Items."Text 2" := XMLDOMManagement.FindNodeText(XMLNode, 'VariantCode');
                    IF EVALUATE(Items."Boolean 3", XMLDOMManagement.FindNodeText(XMLNode, 'AllowSubstitute')) THEN;
                    IF EVALUATE(Items."Decimal 1", XMLDOMManagement.FindNodeText(XMLNode, 'Qty')) THEN;
                    IF EVALUATE(Items."Decimal 2", XMLDOMManagement.FindNodeText(XMLNode, 'UnitPrice')) THEN;
                    IF EVALUATE(Items."Decimal 3", XMLDOMManagement.FindNodeText(XMLNode, 'DiscountAmount')) THEN;
                    IF EVALUATE(Items."Decimal 4", XMLDOMManagement.FindNodeText(XMLNode, 'OriginalPrice')) THEN;
                    Items.INSERT;
                    IF NOT ItemPrice.GET(Items."Code 6") THEN BEGIN
                        ItemPrice."Code 1" := Items."Code 6";
                        ItemPrice."Decimal 1" := Items."Decimal 2";
                        ItemPrice.INSERT;
                    END;
                end;
                IF NOT Items.FINDSET THEN
                    EXIT(FALSE);
                Code := '0000';
                Clear(XMLNode);
                Clear(XMLNodeList);
                XMLDOMManagement.FindNodes(XMLRootNode, 'PaymentLines/Payment', XMLNodeList);
                //Enumerator := XMLNodeList.GetEnumerator;
                foreach XMLNode in xmlnodelist do begin
                    //XMLNode := Enumerator.Current;
                    Code := INCSTR(Code);
                    Payments."Code 1" := Code;
                    Payments."Code 6" := XMLDOMManagement.FindNodeText(XMLNode, 'Type');
                    Payments."Boolean 1" := Payments."Code 6" = UPPERCASE('EmployeeDiscount');
                    Payments."Boolean 2" := Payments."Code 6" = UPPERCASE('ShippingDiscount');
                    IF EVALUATE(Payments."Decimal 1", XMLDOMManagement.FindNodeText(XMLNode, 'Amount')) THEN;
                    IF Payments."Code 6" = 'POINTS' THEN
                        IF EVALUATE(Payments."Decimal 2", XMLDOMManagement.FindNodeText(XMLNode, 'NumberOfPoints')) THEN;
                    Payments.INSERT;
                end;

                Code := '0000';
                Clear(XMLNode);
                Clear(XMLNodeList);
                XMLDOMManagement.FindNodes(XMLRootNode, 'DiscountsUsedLines/DiscountUsed', XMLNodeList);
                foreach XMLNode in xmlnodelist do begin
                    Code := INCSTR(Code);
                    CLEAR(DiscountHeader);
                    DiscountHeader."Code 1" := Code;
                    EVALUATE(DiscountHeader."Integer 1", Code);
                    DiscountHeader."Code 2" := XMLDOMManagement.FindNodeText(XMLNode, 'DiscountNo');
                    IF EVALUATE(DiscountHeader."Decimal 1", XMLDOMManagement.FindNodeText(XMLNode, 'DiscountAmount')) THEN
                        DiscountHeader."Decimal 1" /= 1000;
                    XMLDOMManagement.FindNodes(XMLNode, 'DiscountItems/DiscountItem', XMLNodeList2);
                    foreach XMLNode2 in xmlnodelist2 do begin
                        CLEAR(DiscountLine);
                        DiscountLine."Code 1" := DiscountHeader."Code 1";
                        DiscountLine."Integer 1" := DiscountHeader."Integer 1";
                        DiscountLine."Code 2" := DiscountHeader."Code 2";
                        DiscountLine."Code 3" := XMLDOMManagement.FindNodeText(XMLNode2, 'DiscountItemNo');
                        IF EVALUATE(DiscountLine."Decimal 2", XMLDOMManagement.FindNodeText(XMLNode2, 'DiscountItemQty')) THEN;
                        IF DiscountLine."Decimal 2" = 0 THEN
                            DiscountLine."Decimal 2" := 1;
                        ItemPrice.GET(DiscountLine."Code 3");
                        DiscountLine."Decimal 3" := ItemPrice."Decimal 1";
                        DiscountLine.INSERT;
                        DiscountHeader."Decimal 3" += DiscountLine."Decimal 2" * DiscountLine."Decimal 3";
                    end;
                    DiscountHeader."Decimal 4" := (DiscountHeader."Decimal 1" / DiscountHeader."Decimal 3") * 100;
                    DiscountHeader.Insert();
                end;
                //CS NT 20220209 Check if coordinates are Cheked..
                CoordinatesCheked := FALSE;
                CLEAR(WebOrderCoordinates);
                WebOrderCoordinates.SETRANGE(WebOrderCoordinates."Member Contact No.", CustomerNo);
                WebOrderCoordinates.SETRANGE(WebOrderCoordinates."Postal Code", ShiptoPostCode);
                WebOrderCoordinates.SETRANGE(WebOrderCoordinates.Latitude, DeliveryLatitude);
                WebOrderCoordinates.SETRANGE(WebOrderCoordinates.Longitude, DeliveryLongitude);
                IF WebOrderCoordinates.FINDSET THEN
                    REPEAT
                        IF (STRPOS(WebOrderCoordinates.Address, ShiptoAddress1) > 0) THEN
                            CoordinatesCheked := TRUE;
                    UNTIL WebOrderCoordinates.NEXT = 0;
                //..CS NT 20220209 Check if coordinates are Cheked
                CLEAR(SalesHeader);
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                SalesHeader."No." := OrderID;
                SalesHeader.Exported := TRUE;
                SalesHeader.INSERT(TRUE);
                SalesHeader.VALIDATE("Sell-to Customer No.", 'WEBCUST');
                //SalesHeader.VALIDATE("Store No.", StoreNo);//BC Upgrade
                SalesHeader.VALIDATE("LSC Store No.", StoreNo);
                SalesHeader."Original Store No." := StoreNo;
                SalesHeader.VALIDATE("Location Code", LocationCode);
                SalesHeader."External Document No." := OrderID;
                SalesHeader."Prices Including VAT" := TRUE;
                SalesHeader."Sell-to Address" := Address;
                SalesHeader."Sell-to Address 2" := Address2;
                SalesHeader."Sell-to City" := City;
                SalesHeader."Sell-to Country/Region Code" := CountryRegionCode;
                SalesHeader."Sell-to Customer Name" := FirstName + ' ' + LastName;
                SalesHeader."Sell-to Post Code" := PostCode;
                SalesHeader."For Store No." := CollectStoreNo;
                SalesHeader."Ship-to Address" := ShiptoAddress1;
                SalesHeader."Ship-to Address 2" := ShiptoAddress2;
                SalesHeader."Ship-to City" := ShiptoCity;
                SalesHeader."Ship-to Country/Region Code" := ShiptoCountryRegionCode;
                SalesHeader."Ship-to Name" := ShiptoFullName;//CS NT ShiptoFirstName + ' ' + ShiptoLastName;
                SalesHeader."Ship-to Post Code" := ShiptoPostCode;
                SalesHeader."Ship-to House No." := ShiptoHouseApartmentNo;
                SalesHeader."Ship-to Building Name" := ShiptoBuildingName;
                SalesHeader."Ship-to Flat No." := ShiptoFlatNumber;
                SalesHeader."Sell-to Building Name" := BuildingName;
                SalesHeader."Sell-to Flat No." := FlatNumber;
                SalesHeader."Web Order Delivery Longitude" := DeliveryLongitude;
                SalesHeader."Web Order Delivery Latitude" := DeliveryLatitude;
                SalesHeader."Phone No." := PhoneNo;
                SalesHeader."Mobile Phone No." := MobilePhoneNo;
                SalesHeader."E-Mail" := Email;
                SalesHeader."Web Order Status" := SalesHeader."Web Order Status"::New;
                SalesHeader."Web Order Transaction Id" := TransactionNumber;//CS NT 20220601
                SalesHeader."Web Order Transaction Amount" := TransactionAmount;//CS NT 20220601
                SalesHeader."Web Order Payment Order ID" := RCBOrderID;
                SalesHeader."Web Order Payment Session ID" := RCBSessionID;
                SalesHeader."Stick And Win Phone" := StickAndWinPhone;
                SalesHeader."Ship-To Telephone" := ShiptoPhoneNo;
                //CS NT.. //On live create two fields: "Member Contact No." , "Order Time Slot"
                SalesHeader."Requested Delivery Date" := OrderDeliveryDate;
                SalesHeader."Order Time Slot" := OrderTimeSlot;
                SalesHeader."Member Contact No." := CustomerNo;
                //SalesHeader."Member Card No." := CardNo;//BC Upgrade
                SalesHeader."LSC Member Card No." := CardNo;
                SalesHeader."Coordinates Cheked" := CoordinatesCheked;//20220209
                SalesHeader."Web Order Completed Time" := CompletedTime;
                //..CS NT
                SalesHeader."Order Shipping Method" := OrderShippingMethod;
                SalesHeader.Delivery := SalesHeader."Order Shipping Method" = 'Delivery';
                SalesHeader."Web Order Payment Method" := OrderPaymentMethod;
                SalesHeader."Web Store No." := '9999';
                SalesHeader."Web Order Payment Status" := SalesHeader."Web Order Payment Status"::Pending;
                CLEAR(NextLineNo);
                SalesHeader."Web Order No." := OrderID;
                SalesHeader.MODIFY;
                REPEAT
                    NextLineNo += 10000;
                    CLEAR(SalesLine);
                    SalesLine."Document Type" := SalesHeader."Document Type";
                    SalesLine."Document No." := SalesHeader."No.";
                    SalesLine."Line No." := NextLineNo;
                    SalesLine.Type := SalesLine.Type::Item;
                    //CLEAR(WebItemSubstitution);
                    //IF WebItemSubstitution.GET(Items."Code 6") THEN BEGIN
                    //  SalesLine.VALIDATE("No.",WebItemSubstitution."Item No.");
                    //  SalesLine.Description := WebItemSubstitution.Description;
                    //END ELSE
                    SalesLine.VALIDATE("No.", Items."Code 6");
                    SalesLine.VALIDATE("Unit of Measure Code", Items."Code 8");
                    SalesLine.VALIDATE(Quantity, Items."Decimal 1");
                    SalesLine.VALIDATE("Unit Price", Items."Decimal 2");
                    SalesLine.VALIDATE("Line Discount Amount", Items."Decimal 3");
                    SalesLine."Allow Substitute" := Items."Boolean 3";
                    SalesLine."Web Variant" := Items."Text 2";
                    CLEAR(SpecialOfferItem);
                    IF NOT SalesLine."Allow Substitute" THEN
                        SalesLine."Allow Substitute" := SpecialOfferItem.GET(SalesLine."No.");
                    IF NOT SalesLine."Allow Substitute" THEN BEGIN
                        SpecialOfferItem.SETRANGE("Item No.", SalesLine."No.");
                        SalesLine."Allow Substitute" := SpecialOfferItem.FINDFIRST;
                    END;
                    SalesHeader."Web Order Amount" += SalesLine."Line Amount";
                    //IF WebItemSubstitution.Description <> '' THEN
                    //  SalesLine.Description := WebItemSubstitution.Description;
                    SalesLine."Original Quantity" := Items."Decimal 1";
                    SalesLine."Web Order Line" := TRUE;
                    SalesLine."Web Order Unit Price" := Items."Decimal 2";
                    SalesLine."Web Order Original Price" := Items."Decimal 4";
                    SalesLine."Base Unit Price" := Items."Decimal 2";
                    //SalesLine."Offer No." := Items."Text 1";//BC Upgrade
                    SalesLine."LSC Offer No." := Items."Text 1";
                    DiscountLine.SETRANGE("Code 3", SalesLine."No.");
                    IF DiscountLine.FINDFIRST THEN BEGIN
                        DiscountHeader.GET(DiscountLine."Code 1", DiscountLine."Code 2");
                        SalesLine.VALIDATE("Line Discount %", ROUND((DiscountHeader."Decimal 4" * (DiscountLine."Decimal 2" / SalesLine.Quantity)), 0.01) + SalesLine."Line Discount %");
                        //SalesLine."Offer No." := DiscountHeader."Code 2";//BC Upgrade
                        SalesLine."LSC Offer No." := DiscountHeader."Code 2"
                    END;
                    SalesLine.INSERT(TRUE);
                    IF Items."Code 10" <> '' THEN BEGIN
                        CLEAR(SalesCommentLine);
                        SalesCommentLine."Document Type" := SalesLine."Document Type";
                        SalesCommentLine."No." := SalesLine."Document No.";
                        SalesCommentLine."Document Line No." := SalesLine."Line No.";
                        SalesCommentLine.Comment := Items."Code 10";
                        SalesCommentLine."Line No." := 10000;
                        SalesCommentLine.INSERT;
                    END;
                UNTIL Items.NEXT = 0;

                WebOrderAmount := SalesHeader."Web Order Amount";

                NextLineNo += 10000;
                CLEAR(SalesLine);
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := NextLineNo;
                SalesLine.Type := SalesLine.Type::Item;
                SalesLine.VALIDATE("No.", '857440');
                SalesLine.VALIDATE(Quantity, 1);
                SalesLine.VALIDATE("Unit Price", ShippingFee);
                SalesLine."Shipping Line" := TRUE;
                SalesLine.INSERT(TRUE);
                SalesHeader."Web Order Amount" += SalesLine."Line Amount";
                SalesHeader.MODIFY;
                CLEAR(NextLineNo);
                Payments.SETRANGE("Boolean 1", FALSE);
                Payments.SETRANGE("Boolean 2", FALSE);
                IF Payments.FINDFIRST THEN
                    REPEAT
                        NextLineNo += 10000;
                        CLEAR(SalesPaymentLine);
                        SalesPaymentLine."Document Type" := SalesHeader."Document Type";
                        SalesPaymentLine."Document No." := SalesHeader."No.";
                        SalesPaymentLine."Line No." := NextLineNo;
                        CASE Payments."Code 6" OF
                            'CREDIT CARD':
                                BEGIN
                                    SalesPaymentLine."Tender Type" := '3';
                                    SalesPaymentLine."Card Payment" := TRUE;
                                END;
                            'POINTS':
                                BEGIN
                                    SalesPaymentLine."Tender Type" := '11';
                                    SalesPaymentLine.Points := Payments."Decimal 2";
                                    IF WebOrderPointRedemption.FindLast() THEN
                                        NextEntryNo := WebOrderPointRedemption."Entry No.";
                                    NextEntryNo += 1;
                                    CLEAR(WebOrderPointRedemption);
                                    WebOrderPointRedemption."Entry No." := NextEntryNo;
                                    WebOrderPointRedemption."Document Type" := SalesHeader."Document Type".AsInteger();
                                    WebOrderPointRedemption."Document No." := SalesHeader."No.";
                                    WebOrderPointRedemption.Amount := Payments."Decimal 1";
                                    WebOrderPointRedemption.Points := Payments."Decimal 2";
                                    WebOrderPointRedemption."Member Contact No." := SalesHeader."Member Contact No.";
                                    WebOrderPointRedemption.Date := TODAY;
                                    WebOrderPointRedemption."Store No." := '9999';
                                    WebOrderPointRedemption."POS Terminal No." := 'P9999';
                                    WebOrderPointRedemption.INSERT;
                                END;
                            'GIFT CARD':
                                SalesPaymentLine."Tender Type" := '8';
                            'VOUCHER', 'CREDIT NOTE':
                                SalesPaymentLine."Tender Type" := '7';
                            'DWVOUCHER':
                                SalesPaymentLine."Tender Type" := '36';
                        END;
                        SalesPaymentLine.Amount := Payments."Decimal 1";
                        SalesPaymentLine.INSERT;
                    UNTIL Payments.NEXT = 0;
                /*{
                CLEAR(PRCountingHeader);
                PRCountingHeader."Counting Type" := PRCountingHeader."Counting Type"::Picking;
                PRCountingHeader.INSERT(TRUE);
                PRCountingHeader.Picking := PRCountingHeader.Picking::"Sales Order";
                PRCountingHeader.VALIDATE(Store,SalesHeader."Store No.");
                PRCountingHeader.VALIDATE(Location,SalesHeader."Location Code");
                PRCountingHeader.VALIDATE("Reference No.",SalesHeader."No.");
                PRCountingHeader.MODIFY(TRUE);
                PRConfirm.InitCodeunit(TRUE);
                PRConfirm.RUN(PRCountingHeader);
                }*/

                SalesHeader.GET(SalesHeader."Document Type", SalesHeader."No.");
                SalesHeader.Exported := FALSE;

                Payments.SETRANGE("Boolean 2");
                Payments.SETRANGE("Boolean 1", TRUE);
                IF Payments.FINDFIRST THEN
                    SalesHeader."Invoice Discount %" := 10;//ROUND((Payments."Decimal 1" / WebOrderAmount) * 100,0.00001);

                Payments.SETRANGE("Boolean 1");
                Payments.SETRANGE("Boolean 2", TRUE);
                IF Payments.FINDFIRST THEN
                    SalesHeader."Inv. Discount Amount" += Payments."Decimal 1";

                SalesHeader.MODIFY;

                //DotNetStringBuilber := DotNetStringBuilber.StringBuilder(); BC Upgrade
                TxtBuilder.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');
                TxtBuilder.Appendline('<WebTransaction>');
                TxtBuilder.Appendline(STRSUBSTNO('<ReceiptNo>%1</ReceiptNo>', SalesHeader."No."));
                TxtBuilder.Appendline('</WebTransaction>');

                //xmlResponse := DotNetStringBuilber.ToString();BC Upgrade
                xmlResponse := TxtBuilder.ToText();
                exit(TRUE);
            end;
    end;

    local procedure FormatCoordinates(Value: Text): Text
    var
        Val: Text;
    begin
        IF StrPos(Value, '.') = 0 THEN
            exit(Value);
        Val := CopyStr(Value, StrPos(Value, '.') + 1);
        IF StrLen(Val) > 8 THEN
            Val := CopyStr(Val, 1, 8);
        EXIT(CopyStr(Value, 1, StrPos(Value, '.')) + Val);
    end;

    local procedure SplitString(VAR Text: Text; Separator: Text[1]) ResultString: Text
    var
        Pos: Integer;
    begin
        Pos := StrPos(Text, Separator);
        if Pos > 0 then begin
            ResultString := CopyStr(Text, 1, Pos - 1);
            IF Pos + 1 <= StrLen(Text) then
                Text := CopyStr(Text, Pos + 1)
            ELSE
                Text := '';
        end else begin
            ResultString := Text;
            Text := '';
        end;
    end;

    procedure GetWebsiteMembersAndTheirGDPRLevel(): Text
    var
        DotNetStringBuilder: TextBuilder;
        MemberContact: Record "LSC Member Contact";
    begin
        //DotNetStringBuilder := DotNetStringBuilder.StringBuilder();
        DotNetStringBuilder.Appendline('<?xml version="1.0" encoding="UTF-8" standalone="no"?>');
        DotNetStringBuilder.AppendLine('<WebsiteMembersAndGDPRLevels>');

        CLEAR(MemberContact);
        MemberContact.SETFILTER("Contact No.", '<>%1', '');
        MemberContact.SETFILTER("E-Mail", '<>%1', '');
        MemberContact.SETFILTER("GDPR Level", '>%1', 0);

        IF MemberContact.FINDSET THEN
            REPEAT
                DotNetStringBuilder.Appendline('<MemberAndGDPRLevel>');
                DotNetStringBuilder.Appendline(STRSUBSTNO('<ContactNo>%1</ContactNo>', MemberContact."Contact No."));
                DotNetStringBuilder.Appendline(STRSUBSTNO('<GDPRLevel>%1</GDPRLevel>', MemberContact."GDPR Level"));
                DotNetStringBuilder.Appendline('</MemberAndGDPRLevel>');
            UNTIL MemberContact.NEXT = 0;

        DotNetStringBuilder.AppendLine('</WebsiteMembersAndGDPRLevels>');
        //EXIT(DotNetStringBuilder.ToString()); BC Upgrade
        EXIT(DotNetStringBuilder.ToText());
    end;

    procedure GetWebOrderCoordinates(): Text
    var
        DotNetStringBuilder: TextBuilder;
        WebOrderCoordinates: Record "eCom_Web Order Coordinates_NT";
        address: Text[250];
        CustomerName: Text[250];
        CustomerCity: Text[250];
    begin

        //DotNetStringBuilder := DotNetStringBuilder.StringBuilder();
        DotNetStringBuilder.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="no"?>');
        DotNetStringBuilder.AppendLine('<WebOrderCoordinates>');

        CLEAR(WebOrderCoordinates);
        WebOrderCoordinates.SETRANGE(WebOrderCoordinates.Processed, FALSE);

        IF WebOrderCoordinates.FINDSET THEN
            REPEAT
                IF ((STRPOS(WebOrderCoordinates.Address, '??') <= 0) OR (STRPOS(WebOrderCoordinates.Name, '??') <= 0)) THEN BEGIN
                    address := ReplaceString(WebOrderCoordinates.Address, '&', 'Ampersand');
                    address := ReplaceString(address, 'Ampersand', '&#38;');//&amp;
                    CustomerName := ReplaceString(WebOrderCoordinates.Name, '&', 'Ampersand');
                    CustomerName := ReplaceString(CustomerName, 'Ampersand', '&#38;');//&amp;
                    CustomerCity := ReplaceString(WebOrderCoordinates.City, '&', 'Ampersand');
                    CustomerCity := ReplaceString(CustomerCity, 'Ampersand', '&#38;');//&amp;

                    DotNetStringBuilder.AppendLine('<Order>');
                    DotNetStringBuilder.AppendLine(STRSUBSTNO('<OrderId>%1</OrderId>', WebOrderCoordinates."Order ID"));
                    DotNetStringBuilder.AppendLine(STRSUBSTNO('<Name>%1</Name>', CustomerName));
                    DotNetStringBuilder.AppendLine(STRSUBSTNO('<Address>%1</Address>', address));
                    DotNetStringBuilder.AppendLine(STRSUBSTNO('<PostalCode>%1</PostalCode>', WebOrderCoordinates."Postal Code"));
                    DotNetStringBuilder.AppendLine(STRSUBSTNO('<City>%1</City>', CustomerCity));
                    DotNetStringBuilder.AppendLine(STRSUBSTNO('<Latitude>%1</Latitude>', WebOrderCoordinates.Latitude));
                    DotNetStringBuilder.AppendLine(STRSUBSTNO('<Longitude>%1</Longitude>', WebOrderCoordinates.Longitude));
                    DotNetStringBuilder.AppendLine('</Order>');
                END;
            UNTIL WebOrderCoordinates.NEXT = 0;

        DotNetStringBuilder.AppendLine('</WebOrderCoordinates>');
        //EXIT(DotNetStringBuilder.ToString()); BC Upgrdae
        EXIT(DotNetStringBuilder.ToText());
    end;

    local procedure ReplaceString(String: Text[250]; FindWhat: Text[250]; ReplaceWith: Text[250]) NewString: Text[250]
    begin
        WHILE STRPOS(String, FindWhat) > 0 DO
            String := DELSTR(String, STRPOS(String, FindWhat)) + ReplaceWith + COPYSTR(String, STRPOS(String, FindWhat) + STRLEN(FindWhat));
        NewString := String;
    end;

    procedure MarkWebOrderCoordinatesAsProcessed(xmlRequest: Text; VAR xmlResponse: Text): Boolean
    var
        XMLDOMManagement: Codeunit "LSC XML DOM Mgt.";
        XMLRootNode: XmlNode;
        XMLNodeList: XmlNodeList;
        XmlDoc: XmlDocument;
        iStream: InStream;
        XMLelement: XmlElement;
        XMLNode: XmlNode;
        OrderId: Text[50];
        WebOrderCoordinates: Record "eCom_Web Order Coordinates_NT";
    begin

        //XMLDOMManagement.LoadXMLDocumentFromText(xmlRequest, XMLRootNode);
        if XmlDocument.ReadFrom(xmlRequest, XmlDoc) then begin
            XmlDoc.GetRoot(XMLelement);
            XMLRootNode := XMLelement.AsXmlNode();
        end;
        if XMLRootNode.IsXmlElement then
            if not XMLRootNode.AsXmlElement().IsEmpty then begin

                XMLDOMManagement.FindNodes(XMLRootNode, 'Order', XMLNodeList);
                // Enumerator := XMLNodeList.GetEnumerator;
                // WHILE Enumerator.MoveNext DO BEGIN
                //     XMLNode := Enumerator.Current;
                //     OrderId := XMLDOMManagement.FindNodeText(XMLNode, 'OrderId');
                //     CLEAR(WebOrderCoordinates);
                //     IF WebOrderCoordinates.GET(OrderId) THEN BEGIN
                //         WebOrderCoordinates.Processed := TRUE;
                //         WebOrderCoordinates.MODIFY;
                //     END;
                // END;
                foreach XMLNode in xmlnodelist do begin
                    OrderId := XMLDOMManagement.FindNodeText(XMLNode, 'OrderId');
                    CLEAR(WebOrderCoordinates);
                    IF WebOrderCoordinates.GET(OrderId) THEN BEGIN
                        WebOrderCoordinates.Processed := TRUE;
                        WebOrderCoordinates.MODIFY;
                    END;
                end;
            end;
    end;

    procedure GetActiveWebItems(): Text
    var
        TxtBuilder: TextBuilder;
        WebItemSubstitution: Record "eCom_Web Item Substitution_NT";
        Item: Record Item;
    begin
        //DotNetStringBuilder := DotNetStringBuilder.StringBuilder();
        TxtBuilder.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="no"?>');
        TxtBuilder.AppendLine('<ActiveItems>');

        WebItemSubstitution.SETCURRENTKEY("Item No.");
        Item.SETCURRENTKEY("Web Item");
        Item.SETRANGE("Web Item", TRUE);
        IF Item.FINDSET THEN
            REPEAT
                TxtBuilder.AppendLine(STRSUBSTNO('<Item>%1</Item>', Item."No."));
                WebItemSubstitution.SETRANGE("Item No.", Item."No.");
                IF WebItemSubstitution.FINDSET THEN
                    REPEAT
                        TxtBuilder.AppendLine(STRSUBSTNO('<Item>%1</Item>', WebItemSubstitution."Web Item No."));
                    UNTIL WebItemSubstitution.NEXT = 0;
            UNTIL Item.NEXT = 0;
        TxtBuilder.AppendLine('</ActiveItems>');
        //EXIT(DotNetStringBuilder.ToString());//BC Upgrade
        exit(TxtBuilder.ToText());
    end;

    procedure GetMixAndMaxDiscounts(): Text
    var
        PeriodicDiscountLine: Record "LSC Periodic Discount Line";
        Item: Record Item;
        PeriodicDiscount: Record "LSC Periodic Discount";
        TxtBuilder: TextBuilder;
        InvalidItemExists: Boolean;
        tempStartingDate: Text;
        tempEndingDate: Text;
        SystWEB: Codeunit "Type Helper";
        ValidationPeriod: Record "LSC Validation Period";
        DealPriceValue: Decimal;
        MaxTimesToApply: Integer;
        DealPercentageValue: Decimal;
        DiscountAmountValue: Decimal;
        IsLineSpecific: Text[1];
        DiscountProducts: Text;
        LineGroups: Text;
        LineGroupValue: Text;
        LineGroupDescription: Text;
        LineGroupDescriptionGreek: Text;
        DiscountTypes: Text;
        DealPrice_DiscountPercentages: Text;
        tempBuffer: Record "eCom_General Buffer_NT";
        LineGroupDescriptionTemp: Text;
        LineGroupDescriptionGreekTemp: Text;
        MixAndMatchLineGroups: Record "LSC Mix & Match Line Groups";
        tempDiscType: Text[1];
        tempDealPrice_DiscountPercentage: Decimal;
        DiscountExtenderSettings: Text;
    begin
        //DotNetStringBuilder := DotNetStringBuilder.StringBuilder();
        TxtBuilder.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="no"?>');
        TxtBuilder.AppendLine('<MixAndMatchDiscounts>');

        CLEAR(PeriodicDiscount);
        PeriodicDiscount.SETRANGE(Status, PeriodicDiscount.Status::Enabled);
        PeriodicDiscount.SETRANGE(Type, PeriodicDiscount.Type::"Mix&Match");
        PeriodicDiscount.SETFILTER(PeriodicDiscount."Coupon Code", '=%1', '');//CS NT 20210928
        PeriodicDiscount.SETFILTER(PeriodicDiscount."Discount Type", '<>%1', PeriodicDiscount."Discount Type"::"Least Expensive");//Do not use least expensive type

        IF PeriodicDiscount.FINDSET THEN
            REPEAT
                PeriodicDiscount.CALCFIELDS("Ending Date");
                IF ((PeriodicDiscount."Ending Date" <> 0D) AND (PeriodicDiscount."Ending Date" >= TODAY)) THEN BEGIN
                    InvalidItemExists := FALSE;
                    CLEAR(PeriodicDiscountLine);
                    //PeriodicDiscountLine.SETRANGE(PeriodicDiscountLine."Offer No.", PeriodicDiscount."No.");
                    PeriodicDiscountLine.SETFILTER(PeriodicDiscountLine."Offer No.", '@' + PeriodicDiscount."No.");//CS NT SOS. Use @ because some contain '_'
                    PeriodicDiscountLine.SETRANGE(PeriodicDiscountLine.Type, PeriodicDiscountLine.Type::Item); //Only Items
                    IF (PeriodicDiscountLine.FINDSET) THEN
                        REPEAT
                            CLEAR(Item);
                            IF InvalidItemExists = FALSE THEN BEGIN
                                IF Item.GET(PeriodicDiscountLine."No.") THEN BEGIN
                                    IF (Item."Web Item" = FALSE) THEN
                                        InvalidItemExists := TRUE;
                                END
                                ELSE
                                    InvalidItemExists := TRUE;
                            END;
                        UNTIL PeriodicDiscountLine.NEXT = 0;

                    IF ((InvalidItemExists = FALSE) AND (PeriodicDiscountLine.FINDSET)) THEN BEGIN
                        TxtBuilder.AppendLine('<Discount>');
                        //Main information
                        TxtBuilder.AppendLine(STRSUBSTNO('<No>%1</No>', PeriodicDiscount."No."));
                        TxtBuilder.AppendLine(STRSUBSTNO('<Name>%1</Name>', SystWEB.HtmlEncode(PeriodicDiscount.Description)));
                        TxtBuilder.AppendLine(STRSUBSTNO('<GreekName>%1</GreekName>', SystWEB.HtmlEncode(PeriodicDiscount.GreekDescription)));
                        tempStartingDate := '';
                        tempEndingDate := '';
                        CLEAR(ValidationPeriod);
                        IF (ValidationPeriod.GET(PeriodicDiscount."Validation Period ID")) THEN BEGIN
                            tempStartingDate := FORMAT(ValidationPeriod."Starting Date", 10, '<Year4>/<Month,2>/<Day,2>');
                            tempEndingDate := FORMAT(ValidationPeriod."Ending Date", 10, '<Year4>/<Month,2>/<Day,2>');
                        END;

                        TxtBuilder.AppendLine(STRSUBSTNO('<StartingDate>%1</StartingDate>', tempStartingDate));
                        TxtBuilder.AppendLine(STRSUBSTNO('<EndingDate>%1</EndingDate>', tempEndingDate));
                        TxtBuilder.AppendLine(STRSUBSTNO('<MinimumAmount>%1</MinimumAmount>', PeriodicDiscount."Amount to Trigger"));
                        MaxTimesToApply := PeriodicDiscount."No. of Times Applicable";
                        IF (MaxTimesToApply = 0) THEN MaxTimesToApply := 1000;//Just a high number

                        //Discount Type
                        DealPriceValue := 0;
                        IF ((PeriodicDiscount."Discount Type" = PeriodicDiscount."Discount Type"::"Deal Price") AND (PeriodicDiscount."Deal Price Value" > 0)) THEN
                            DealPriceValue := PeriodicDiscount."Deal Price Value";
                        DealPercentageValue := 0;
                        IF ((PeriodicDiscount."Discount Type" = PeriodicDiscount."Discount Type"::"Discount %") AND (PeriodicDiscount."Discount % Value" > 0)) THEN
                            DealPercentageValue := PeriodicDiscount."Discount % Value";
                        DiscountAmountValue := 0;
                        IF ((PeriodicDiscount."Discount Type" = PeriodicDiscount."Discount Type"::"Discount Amount") AND (PeriodicDiscount."Discount Amount Value" > 0)) THEN
                            DiscountAmountValue := PeriodicDiscount."Discount Amount Value";
                        IsLineSpecific := '0';
                        IF (PeriodicDiscount."Discount Type" = PeriodicDiscount."Discount Type"::"Line spec.") THEN
                            IsLineSpecific := '1';

                        DiscountProducts := '[some]';
                        LineGroups := '';
                        LineGroupValue := '';
                        LineGroupDescription := '';
                        LineGroupDescriptionGreek := '';
                        DiscountTypes := '';
                        DealPrice_DiscountPercentages := '';
                        tempBuffer.DELETEALL;
                        CLEAR(tempBuffer);
                        //Loop periodic discount lines
                        IF (PeriodicDiscountLine.FINDSET) THEN
                            REPEAT
                                LineGroupDescriptionTemp := '';
                                LineGroupDescriptionGreekTemp := '';
                                DiscountProducts += '[p:' + PeriodicDiscountLine."No." + ',]';
                                LineGroups += PeriodicDiscountLine."Line Group" + ';';
                                CLEAR(MixAndMatchLineGroups);
                                IF MixAndMatchLineGroups.GET(PeriodicDiscountLine."Offer No.", PeriodicDiscountLine."Line Group") THEN BEGIN
                                    LineGroupValue += FORMAT(MixAndMatchLineGroups."Value 1") + ';';
                                    IF (MixAndMatchLineGroups.Description = '') THEN
                                        LineGroupDescriptionTemp := PeriodicDiscount.Description
                                    ELSE
                                        LineGroupDescriptionTemp := MixAndMatchLineGroups.Description;
                                    IF (MixAndMatchLineGroups.GreekDescription = '') THEN BEGIN
                                        IF (PeriodicDiscount.GreekDescription <> '') THEN
                                            LineGroupDescriptionGreekTemp := PeriodicDiscount.GreekDescription
                                        ELSE
                                            LineGroupDescriptionGreekTemp := PeriodicDiscount.Description;
                                    END
                                    ELSE
                                        LineGroupDescriptionGreekTemp := MixAndMatchLineGroups.GreekDescription;
                                END
                                ELSE BEGIN
                                    LineGroupValue += '0;';
                                    LineGroupDescriptionTemp := PeriodicDiscount.Description;
                                    IF (PeriodicDiscount.GreekDescription <> '') THEN
                                        LineGroupDescriptionGreekTemp := PeriodicDiscount.GreekDescription
                                    ELSE
                                        LineGroupDescriptionGreekTemp := PeriodicDiscount.Description;
                                END;

                                IF (IsLineSpecific = '1') THEN BEGIN //! Deal Price,Disc. % -> 0,1
                                    tempDiscType := '0';
                                    IF (PeriodicDiscountLine."Disc. Type" = PeriodicDiscountLine."Disc. Type"::"Disc. %") THEN
                                        tempDiscType := '1';
                                    tempDealPrice_DiscountPercentage := PeriodicDiscountLine."Deal Price/Disc. %";
                                    DiscountTypes += tempDiscType + ';';
                                    DealPrice_DiscountPercentages += FORMAT(tempDealPrice_DiscountPercentage) + ';';
                                END
                                ELSE BEGIN
                                    DiscountTypes += '0;';
                                    DealPrice_DiscountPercentages += '0;';
                                END;

                                //Handle group descriptions
                                tempBuffer.RESET;
                                tempBuffer.SETRANGE(tempBuffer."Code 1", PeriodicDiscountLine."Line Group");
                                IF NOT (tempBuffer.FINDFIRST) THEN BEGIN
                                    tempBuffer."Code 1" := PeriodicDiscountLine."Line Group";
                                    tempBuffer."Text 1" := LineGroupDescriptionTemp;
                                    tempBuffer."Text 2" := LineGroupDescriptionGreekTemp;
                                    tempBuffer.INSERT;
                                END;

                            UNTIL PeriodicDiscountLine.NEXT = 0;

                        tempBuffer.RESET;
                        IF (tempBuffer.FINDSET) THEN
                            REPEAT
                                LineGroupDescription += tempBuffer."Text 1" + ';';
                                LineGroupDescriptionGreek += tempBuffer."Text 2" + ';';
                            UNTIL tempBuffer.NEXT = 0;
                        CLEAR(tempBuffer);

                        DiscountExtenderSettings := '<?xml version="1.0" encoding="utf-8"?>';
                        DiscountExtenderSettings += '<Parameters addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups">';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Max times to apply discount" value="' + FORMAT(MaxTimesToApply) + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Deal Price Value" value="' + FORMAT(DealPriceValue) + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Deal Percentage Value" value="' + FORMAT(DealPercentageValue) + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Discount Amount Value" value="' + FORMAT(DiscountAmountValue) + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Is Line Specific" value="' + IsLineSpecific + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="DiscountProducts" value="' + DiscountProducts + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Line Group" value="' + LineGroups + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Line Group Value" value="' + LineGroupValue + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Line Group Description" value="' + LineGroupDescription + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Line Group Description Greek" value="' + LineGroupDescriptionGreek + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Disc. Type" value="' + DiscountTypes + '" />';
                        DiscountExtenderSettings += '<Parameter addin="NextechDWAddIn.NotificationSubscribers.DiscountExtenderWithLineGroups" name="Deal Price / Disc %" value="' + DealPrice_DiscountPercentages + '" />';
                        DiscountExtenderSettings += '</Parameters>';

                        TxtBuilder.AppendLine(STRSUBSTNO('<DiscountExtenderSettings>%1</DiscountExtenderSettings>', SystWEB.HtmlEncode(DiscountExtenderSettings)));
                        TxtBuilder.AppendLine('</Discount>');
                    END;
                END;
            UNTIL PeriodicDiscount.NEXT = 0;

        TxtBuilder.AppendLine('</MixAndMatchDiscounts>');
        //EXIT(DotNetStringBuilder.ToString());//BC Upgrade
        exit(TxtBuilder.ToText());//BC Upgrade
    end;

    procedure GetCancelledOrders(): Text
    var
        dateFrom: Date;
        dateTo: Date;
        SalesHeader: Record "Sales Header";
        TxtBuilder: TextBuilder;
    begin
        dateTo := TODAY;
        dateFrom := CALCDATE('-7D', dateTo);
        //DotNetStringBuilder := DotNetStringBuilder.StringBuilder(); BC Upgrdae
        TxtBuilder.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="no"?>');
        TxtBuilder.AppendLine('<WebCancelledOrders>');
        CLEAR(SalesHeader);
        SalesHeader.SetFilter("Posting Date", '%1..%2', dateFrom, dateTo);
        SalesHeader.SetRange("Web Order Status", SalesHeader."Web Order Status"::Cancelled);
        if SalesHeader.FindSet() then
            repeat
                TxtBuilder.AppendLine(STRSUBSTNO('<OrderId>%1</OrderId>', SalesHeader."External Document No."));
            until SalesHeader.NEXT = 0;
        TxtBuilder.AppendLine('</WebCancelledOrders>');
        //EXIT(DotNetStringBuilder.ToString()); BC Upgrade
        exit(TxtBuilder.ToText());
    end;

    var
        DayText: Text[5];
        MonthText: Text[5];
        YearText: Text[5];
}
