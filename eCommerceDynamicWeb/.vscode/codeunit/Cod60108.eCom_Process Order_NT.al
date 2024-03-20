codeunit 60108 "eCom_Process Order_NT"
{
    TableNo = "Sales Header";

    trigger OnRun()
    begin
        SelectLatestVersion();
        UpdateSubItems(Rec);
        IF Rec."Document Type" = Rec."Document Type"::Order THEN BEGIN
            CLEAR(EcommerceOrderManagement);
            EcommerceOrderManagement.SetBatchProcess();
            IF EcommerceOrderManagement.CompletePayment(Rec) THEN BEGIN
                COMMIT;
                Get("Document Type", "No.");
                EcommerceOrderManagement.CreateTransaction(Rec);
            END;
        END;
        IF Rec."Document Type" = Rec."Document Type"::"Return Order" THEN BEGIN
            CLEAR(EcommerceOrderManagement);
            EcommerceOrderManagement.SetBatchProcess();
            EcommerceOrderManagement.RefundPayment(Rec);
            COMMIT;
            EcommerceOrderManagement.CreateTransaction(Rec);
        END;
    end;

    local procedure UpdateSubItems(SalesHeader: Record "Sales Header")
    var

        SalesLine: Record "Sales Line";
        PerDisc: Record "LSC Periodic Discount";
        PerDiscLine: Record "LSC Periodic Discount Line";
        RetailPriceUtils: Codeunit "LSC Retail Price Utils";
        StopLoop: Boolean;
        OfferNo: Code[20];
        UnitPrice: Decimal;
    begin
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("New Line", TRUE);
        IF SalesLine.FINDSET THEN
            REPEAT
                OfferNo := SalesLine."LSC Offer No.";
                UnitPrice := SalesLine."Unit Price";
                CLEAR(PerDiscLine);
                StopLoop := FALSE;//NT1.00 04.01.2023
                PerDiscLine.SETCURRENTKEY(Type, "No.");
                PerDiscLine.SETRANGE(Type, PerDiscLine.Type::Item);
                PerDiscLine.SETRANGE("No.", SalesLine."No.");
                //PerDiscLine.SETRANGE("Header Type",PerDiscLine."Header Type"::"Disc. Offer");
                IF PerDiscLine.FINDSET THEN
                    REPEAT
                        PerDisc.GET(PerDiscLine."Offer No.");
                        IF PerDisc.Status = PerDisc.Status::Enabled THEN
                            IF RetailPriceUtils.DiscValPerValid(PerDisc."Validation Period ID", TODAY, TIME) THEN BEGIN
                                UnitPrice := PerDiscLine."Offer Price Including VAT";
                                IF PerDiscLine."Discount Offer No." <> '' THEN
                                    OfferNo := PerDiscLine."Discount Offer No."
                                ELSE
                                    OfferNo := PerDiscLine."Offer No.";
                                StopLoop := TRUE;
                            END;
                        IF NOT StopLoop THEN
                            StopLoop := PerDiscLine.NEXT = 0;
                    UNTIL StopLoop;
                SalesLine."Updated Before Posting" := (SalesLine."Unit Price" <> UnitPrice) OR (SalesLine."LSC Offer No." <> OfferNo);
                IF SalesLine."Unit Price" <> UnitPrice THEN
                    SalesLine.VALIDATE("Unit Price", UnitPrice);
                IF SalesLine."LSC Offer No." <> OfferNo THEN
                    SalesLine."LSC Offer No." := OfferNo;
                IF SalesLine."Updated Before Posting" THEN
                    SalesLine.MODIFY;
            UNTIL SalesLine.NEXT = 0;
    end;

    var
        EcommerceOrderManagement: Codeunit "eCom_Order Management_NT";
}
