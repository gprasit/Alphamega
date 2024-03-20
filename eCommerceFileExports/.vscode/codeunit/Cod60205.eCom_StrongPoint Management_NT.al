codeunit 60205 "eCom_StrongPoint Management_NT"
{
    trigger OnRun()
    begin
        IF _JSonText <> '' THEN
            PickOrderResult(_JSonText);
    end;

    procedure PickOrderResult(JSonText: Text): Text
    var
        Barcode: Record "LSC Barcodes";
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        Item: Record Item;
        Lines: Record "eCom_General Buffer_NT" temporary;
        NewSalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        SalesLine2: Record "Sales Line";
        SalesLine: Record "Sales Line";
        eComFileGenFn: Codeunit "eComFile_General Functions_NT";
        BarcodeNo: Code[20];
        DocumentNo: Code[20];
        OrderStatus: Code[20];
        Dec: Decimal;
        i: Integer;
        LineNo: Integer;
        NoOfLines: Integer;
        RefLineNo: Integer;
        Comment: Text;
        JSonString: DotNet String;
        SpecialOfferItem: Record "eCom_Special Offer Item_NT";
        RetailPriceUtils: Codeunit "LSC Retail Price Utils";
        PriceListLine: Record "Price List Line";
        PerDiscLine: Record "LSC Periodic Discount Line";
        PerDisc: Record "LSC Periodic Discount";
        StopLoop: Boolean;
        OfferNo: Code[20];
        UnitPrice: Decimal;
        Total: Decimal;
        InvDiscAmt: Decimal;
    begin
        GenBuffer.RESET;
        GenBuffer.DELETEALL;
        JSonString := JSonText;
        //JSonMgt.ReadJSon(JSonString, GenBuffer); BC Upgrade
        eComFileGenFn.ReadJSon(JSonString, GenBuffer); //BC Upgrade;

        // HEADER
        //DocumentNo := JSonMgt.GetJsonValue(GenBuffer, 'DocumentNo'); BC Upgrade
        DocumentNo := eComFileGenFn.GetJsonValue(GenBuffer, 'DocumentNo');//BC Upgrade
        //DeliveryArrangePosition
        //OrderStatus := JSonMgt.GetJsonValue(GenBuffer, 'OrderStatus'); BC Upgrade
        OrderStatus := eComFileGenFn.GetJsonValue(GenBuffer, 'OrderStatus');//BC Upgrade
        //FreightCarrierCountTotal
        //FinishedPicking
        //PickedBy
        //DeliveryArrangePositionSuffix
        //ExternalSeqNum
        //ExternalRoute

        IF NOT SalesHeader.GET(SalesHeader."Document Type"::Order, DocumentNo) THEN
            EXIT('Document not found.');

        //NoOfLines := JSonMgt.GetJsonNoOfValue(GenBuffer, 'PickingOrderProduct__CommentFromPicker'); BC Upgrade
        NoOfLines := eComFileGenFn.GetJsonNoOfValue(GenBuffer, 'PickingOrderProduct__CommentFromPicker');//BC Upgrade

        Lines.RESET;
        Lines.DELETEALL;
        FOR i := 0 TO NoOfLines - 1 DO BEGIN
            //BarcodeNo := JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__SKU'); BC Upgrade
            BarcodeNo := eComFileGenFn.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__SKU');//BC Upgrade
            IF NOT Barcode.GET(BarcodeNo) THEN BEGIN
                IF NOT Item.GET(BarcodeNo) THEN
                    EXIT(STRSUBSTNO('Barcode %1 not found', BarcodeNo));
            END ELSE
                Item.GET(Barcode."Item No.");
            //Comment := JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__CommentFromPicker');BC Upgrade
            Comment := eComFileGenFn.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__CommentFromPicker');//BC Upgrade
            //EVALUATE(LineNo, JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__Position'));
            EVALUATE(LineNo, eComFileGenFn.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__Position'));//BC Upgrade

            //EVALUATE(RefLineNo, JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__ReplacementProductForRow')); BC Upgrade
            EVALUATE(RefLineNo, eComFileGenFn.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__ReplacementProductForRow'));//BC Upgrade
            //IF UPPERCASE(JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__WeightSpecified')) = 'TRUE' THEN BEGIN BC Upgrade
            IF UPPERCASE(eComFileGenFn.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__WeightSpecified')) = 'TRUE' THEN BEGIN //BC Upgrade
                //EVALUATE(Dec, JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__Weight')); BC Upgrade
                EVALUATE(Dec, eComFileGenFn.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__Weight')); //BC Upgrade
                Dec /= 1000;
            END ELSE
                //EVALUATE(Dec, JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__Quantity')); BC Upgrade
                EVALUATE(Dec, eComFileGenFn.GetJsonValueAtIndex(GenBuffer, i, 'PickingOrderProduct__Quantity')); //BC Upgrade
            IF NOT Lines.GET(Item."No.") THEN BEGIN
                CLEAR(Lines);
                Lines."Code 1" := Item."No.";
                Lines."Code 6" := BarcodeNo;
                IF Comment <> '' THEN
                    Lines."Text 1" := COPYSTR(Comment, 1, 250);
                Lines."Integer 1" := LineNo;
                Lines."Integer 2" := RefLineNo;
                Lines."Decimal 2" := Item."Web Weight";
                Lines.INSERT;
            END ELSE BEGIN
                Lines."Code 7" := BarcodeNo;
                IF Comment <> '' THEN
                    Lines."Text 2" := COPYSTR(Comment, 1, 250);
                Lines."Integer 3" := LineNo;
                Lines."Integer 4" := RefLineNo;
            END;
            Lines."Decimal 1" += Dec;
            Lines.MODIFY;
        END;

        // LINES
        CLEAR(SalesLine);
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");

        IF Lines.FINDFIRST THEN
            REPEAT
                IF Lines."Integer 1" <> 0 THEN
                    SalesLine.GET(SalesHeader."Document Type", SalesHeader."No.", Lines."Integer 1")
                /*
  //CS NT NEW..20210504
 { IF BarcodesTable.GET(Lines."Code 6") THEN BEGIN
                SalesLine.SETRANGE(Type, SalesLine.Type::Item);
                SalesLine.SETRANGE("No.", BarcodesTable."Item No.");
                SalesLine.FINDFIRST;
            END
            ELSE
                IF ItemsTable.GET(Lines."Code 6") THEN BEGIN
                    SalesLine.SETRANGE(Type, SalesLine.Type::Item);
                    SalesLine.SETRANGE("No.", ItemsTable."No.");
                    SalesLine.FINDFIRST;
                END      }
  //..CS NT NEW
*/
                ELSE BEGIN
                    SalesLine.SETRANGE(Type, SalesLine.Type::Item);
                    SalesLine.SETRANGE("No.", Lines."Code 1");
                    IF NOT SalesLine.FINDFIRST THEN BEGIN
                        CLEAR(SalesLine2);
                        SalesLine2.SETRANGE("Document Type", SalesHeader."Document Type");
                        SalesLine2.SETRANGE("Document No.", SalesHeader."No.");
                        IF SalesLine2.FINDLAST THEN;
                        CLEAR(NewSalesLine);
                        NewSalesLine.SetHideValidationDialog(TRUE);
                        NewSalesLine."Document Type" := SalesHeader."Document Type";
                        NewSalesLine."Document No." := SalesHeader."No.";
                        NewSalesLine."Line No." := SalesLine2."Line No." + 10000;
                        NewSalesLine.Type := NewSalesLine.Type::Item;
                        NewSalesLine.VALIDATE("No.", Lines."Code 1");
                        NewSalesLine."Barcode No." := Lines."Code 6";
                        NewSalesLine."New Line" := TRUE;
                        IF Lines."Integer 2" <> 0 THEN BEGIN
                            NewSalesLine."Reference Line No." := Lines."Integer 2";
                            IF SpecialOfferItem.GET(NewSalesLine."No.") THEN
                                NewSalesLine."Web Order Sub. For Item No." := SpecialOfferItem."Item No.";
                        END;
                        //BC Upgrade Start
                        /* 
                        CLEAR(SalesPrice);
                        SalesPrice.SETRANGE("Item No.", NewSalesLine."No.");
                        SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
                        SalesPrice.SETRANGE("Sales Code", 'AL');
                        IF SalesPrice.FINDLAST THEN
                            NewSalesLine."Unit Price" := SalesPrice."Unit Price Including VAT";
                        */
                        RetailPriceUtils.GetItemPrice('AL', Item."No.", '', TODAY, '', PriceListLine, Item."Sales Unit of Measure");//BC Upgrade
                        NewSalesLine."Unit Price" := PriceListLine."LSC Unit Price Including VAT";
                        //BC Upgrade End
                        NewSalesLine.VALIDATE("Unit Price");

                        CLEAR(PerDiscLine);
                        StopLoop := false;//BC Upgrade
                        PerDiscLine.SETCURRENTKEY(Type, "No.");
                        PerDiscLine.SETRANGE(Type, PerDiscLine.Type::Item);
                        PerDiscLine.SETRANGE("No.", NewSalesLine."No.");
                        //PerDiscLine.SETRANGE("Header Type",PerDiscLine."Header Type"::"Disc. Offer");
                        IF PerDiscLine.FINDSET THEN
                            REPEAT
                                PerDisc.GET(PerDiscLine."Offer No.");
                                IF PerDisc.Status = PerDisc.Status::Enabled THEN
                                    IF RetailPriceUtils.DiscValPerValid(PerDisc."Validation Period ID", TODAY, TIME) THEN BEGIN
                                        NewSalesLine.VALIDATE("Unit Price", PerDiscLine."Offer Price Including VAT");
                                        IF PerDiscLine."Discount Offer No." <> '' THEN
                                            NewSalesLine."LSC Offer No." := PerDiscLine."Discount Offer No."
                                        ELSE
                                            NewSalesLine."LSC Offer No." := PerDiscLine."Offer No.";
                                        StopLoop := TRUE;
                                    END;
                                IF NOT StopLoop THEN
                                    StopLoop := PerDiscLine.NEXT = 0;
                            UNTIL StopLoop;
                        NewSalesLine."Base Unit Price" := NewSalesLine."Unit Price";
                        NewSalesLine.INSERT(TRUE);
                        SalesLine := NewSalesLine;
                    END;
                END;
                SalesLine.SetHideValidationDialog(TRUE);
                OfferNo := SalesLine."LSC Offer No.";
                UnitPrice := SalesLine."Base Unit Price";
                SalesLine.VALIDATE(Quantity, Lines."Decimal 1");
                IF NOT SalesLine."New Line" THEN
                    IF (SalesLine.Quantity <> 0) AND (Lines."Decimal 2" <> 0) THEN
                        UnitPrice := ROUND((SalesLine.Quantity * UnitPrice) / (SalesLine.Quantity * Lines."Decimal 2"), 0.01);
                SalesLine.VALIDATE("Unit Price", UnitPrice);
                SalesLine."Barcode No." := Lines."Code 6";
                SalesLine."LSC Offer No." := OfferNo;
                SalesLine.MODIFY(TRUE);
                IF Lines."Text 1" <> '' THEN
                    AddComment(SalesHeader."Document Type", SalesHeader."No.", SalesLine."Line No.", Lines."Text 1");
                IF Lines."Text 2" <> '' THEN
                    AddComment(SalesHeader."Document Type", SalesHeader."No.", SalesLine."Line No.", Lines."Text 2");
                IF Lines."Text 3" <> '' THEN
                    AddComment(SalesHeader."Document Type", SalesHeader."No.", SalesLine."Line No.", Lines."Text 3");
            UNTIL Lines.NEXT = 0;

        CLEAR(SalesLine2);
        SalesLine2.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine2.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine2.SETRANGE(Type, SalesLine2.Type::Item);
        SalesLine2.SETRANGE("No.", '858763');
        IF NOT SalesLine2.FINDFIRST THEN BEGIN
            SalesLine2.SETRANGE(Type);
            SalesLine2.SETRANGE("No.");
            IF SalesLine2.FINDLAST THEN;
            Dec := 1;
            CLEAR(NewSalesLine);
            NewSalesLine."Document Type" := SalesHeader."Document Type";
            NewSalesLine."Document No." := SalesHeader."No.";
            NewSalesLine."Line No." := SalesLine2."Line No." + 10000;
            NewSalesLine.Type := NewSalesLine.Type::Item;
            NewSalesLine.VALIDATE("No.", '858763');
            NewSalesLine.VALIDATE(Quantity, 1);
            NewSalesLine."New Line" := TRUE;        
            NewSalesLine."Web Order Unit Price" := NewSalesLine."Unit Price";//BC Upgrade
            NewSalesLine.INSERT(TRUE);

        END;
        /*{
        NoOfLines := JSonMgt.GetJsonNoOfValue(GenBuffer, 'FreightCarriers__Name');
                FOR i := 0 TO NoOfLines - 1 DO BEGIN
                    IF JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'FreightCarriers__Name') = 'Chargeable Bag' THEN BEGIN
                        CLEAR(SalesLine2);
                        SalesLine2.SETRANGE("Document Type", SalesHeader."Document Type");
                        SalesLine2.SETRANGE("Document No.", SalesHeader."No.");
                        IF SalesLine2.FINDLAST THEN;
                        EVALUATE(Dec, JSonMgt.GetJsonValueAtIndex(GenBuffer, i, 'FreightCarriers__Count'));
                        CLEAR(NewSalesLine);
                        NewSalesLine."Document Type" := SalesHeader."Document Type";
                        NewSalesLine."Document No." := SalesHeader."No.";
                        NewSalesLine."Line No." := SalesLine2."Line No." + 10000;
                        NewSalesLine.Type := NewSalesLine.Type::Item;
                        NewSalesLine.VALIDATE("No.", '834477');
                        NewSalesLine.VALIDATE(Quantity, Dec);
                        NewSalesLine."New Line" := TRUE;
                        NewSalesLine.INSERT(TRUE);
                    END;
                END;
        }*/

        CASE UPPERCASE(OrderStatus) OF
            'PICKED':
                SalesHeader."Web Order Status" := SalesHeader."Web Order Status"::Picked;
            'DELIVERED':
                SalesHeader."Web Order Status" := SalesHeader."Web Order Status"::Delivered;
            'CANCELLED':
                SalesHeader."Web Order Status" := SalesHeader."Web Order Status"::Cancelled;
            'PARTLYPICKED':
                SalesHeader."Web Order Status" := SalesHeader."Web Order Status"::"Picked with Difference";
        END;

        SalesHeader.MODIFY;
        IF (SalesHeader."Invoice Discount %" <> 0) OR (SalesHeader."Inv. Discount Amount" <> 0) THEN
            IF SalesHeader."Web Order Status" IN [SalesHeader."Web Order Status"::Picked, SalesHeader."Web Order Status"::"Picked with Difference"] THEN BEGIN
                IF SalesHeader."Invoice Discount %" <> 0 THEN BEGIN
                    Total := eComFileGenFn.GetOrderTotalAmount(SalesHeader);
                    InvDiscAmt := ROUND((SalesHeader."Invoice Discount %" * Total / 100), 0.01);
                END;
                IF SalesHeader."Inv. Discount Amount" <> 0 THEN
                    InvDiscAmt += SalesHeader."Inv. Discount Amount";
                IF InvDiscAmt > 0 THEN
                    eComFileGenFn.CalcInvoiceDiscount(SalesHeader, InvDiscAmt);
            END;

        //BC Upgrade Start
        /*
        AddComment(SalesHeader."Document Type", SalesHeader."No.", 0, STRSUBSTNO('Finised Picking: %1', JSonMgt.GetJsonValue(GenBuffer, 'FinishedPicking')));
        AddComment(SalesHeader."Document Type", SalesHeader."No.", 0, STRSUBSTNO('Picked By: %1', JSonMgt.GetJsonValue(GenBuffer, 'PickedBy')));
        */
        AddComment(SalesHeader."Document Type", SalesHeader."No.", 0, STRSUBSTNO('Finised Picking: %1', eComFileGenFn.GetJsonValue(GenBuffer, 'FinishedPicking')));
        AddComment(SalesHeader."Document Type", SalesHeader."No.", 0, STRSUBSTNO('Picked By: %1', eComFileGenFn.GetJsonValue(GenBuffer, 'PickedBy')));
        //BC Upgrade End

        //PickingOrderProduct__CommentFromPicker
        //PickingOrderProduct__OriginalWeightSpecified
        //PickingOrderProduct__OriginalWeight
        //PickingOrderProduct__WeightSpecified
        //PickingOrderProduct__Weight
        //PickingOrderProduct__OriginalQuantity
        //PickingOrderProduct__Quantity
        //PickingOrderProduct__ReplacementProductForRow
        //PickingOrderProduct__NewProductAdded
        //PickingOrderProduct__ScannedEAN
        //PickingOrderProduct__Position
        //PickingOrderProduct__SKU

        //
        //FOR i := 0 TO NoOfLines -1 DO
        //  MESSAGE(JSonMgt.GetJsonValueAtIndex(GenBuffer,i,'PickingOrderProduct__SKU'));
        EXIT('OK ' + SalesHeader."No.");
    end;

    local procedure AddComment(DocType: Enum "Sales Document Type"; DocNo: Code[20]; LineNo: Integer; Comment: Text)
    var
        SalesLineComment: Record "Sales Comment Line";
        NextLineNo: Integer;
    begin
        IF Comment = '' THEN
            EXIT;
        CLEAR(SalesLineComment);
        SalesLineComment.SETRANGE("Document Type", DocType);
        SalesLineComment.SETRANGE("No.", DocNo);
        SalesLineComment.SETRANGE("Document Line No.", LineNo);
        IF SalesLineComment.FINDLAST THEN
            NextLineNo := SalesLineComment."Line No.";
        NextLineNo += 10000;
        CLEAR(SalesLineComment);
        SalesLineComment."Document Type" := DocType;
        SalesLineComment."No." := DocNo;
        SalesLineComment."Document Line No." := LineNo;
        SalesLineComment."Line No." := NextLineNo;
        SalesLineComment.Comment := COPYSTR(Comment, 1, MAXSTRLEN(SalesLineComment.Comment));
        SalesLineComment.Date := TODAY;
        SalesLineComment.INSERT;
    end;

    procedure SetInput(InText: Text)
    begin
        _JSonText := InText;
    end;

    var
        _JSonText: Text;
}
