codeunit 60104 "eCom_Process Orders_NT"
{
    TableNo = "LSC Scheduler Job Header";

    trigger OnRun()
    begin
        case Rec.Integer of
            1:
                ProcessOrders(Rec.Code);
            2:
                ProcessReturnOrders(Rec.Code);
        end;
    end;

    LOCAL procedure ProcessOrders(StoreNo: Code[10])
    var
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
    begin
        SalesHeader.SETCURRENTKEY("Document Type", "Web Order Status", "Web Order Payment Status");
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        IF StoreNo <> '' THEN
            SalesHeader.SETRANGE("LSC Store No.", StoreNo);
        SalesHeader.SETFILTER("Web Order Status", '%1|%2|%3', SalesHeader."Web Order Status"::Picked, SalesHeader."Web Order Status"::"Picked with Difference", SalesHeader."Web Order Status"::Delivered);
        SalesHeader.SETRANGE("Web Order Payment Status", SalesHeader."Web Order Payment Status"::Pending);

        IF SalesHeader.FINDSET THEN
            REPEAT
                SalesHeader2 := SalesHeader;
                COMMIT;
                IF CODEUNIT.RUN(CODEUNIT::"eCom_Process Order_NT", SalesHeader2) THEN BEGIN
                    IF SalesHeader."Web Order Status" = SalesHeader."Web Order Status"::Delivered THEN BEGIN
                        SalesHeader2.GET(SalesHeader."Document Type", SalesHeader."No.");
                        SalesHeader2."Web Order Status" := SalesHeader2."Web Order Status"::Delivered;
                        SalesHeader2.MODIFY;
                    END;
                END;
            UNTIL SalesHeader.NEXT = 0;
    end;

    local procedure ProcessReturnOrders(StoreNo: Code[10])
    var
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
    begin
        SalesHeader.SETCURRENTKEY("Document Type", "Web Order Status", "Web Order Payment Status");
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::"Return Order");
        IF StoreNo <> '' THEN
            SalesHeader.SETRANGE("LSC Store No.", StoreNo);
        SalesHeader.SETFILTER("Web Order Status", '%1|%2|%3', SalesHeader."Web Order Status"::Picked, SalesHeader."Web Order Status"::"Picked with Difference", SalesHeader."Web Order Status"::Delivered);
        SalesHeader.SETRANGE("Web Order Payment Status", SalesHeader."Web Order Payment Status"::Pending);

        IF SalesHeader.FINDSET THEN
            REPEAT
                SalesHeader2 := SalesHeader;
                COMMIT;
                IF CODEUNIT.RUN(CODEUNIT::"eCom_Process Order_NT", SalesHeader2) THEN BEGIN
                    IF SalesHeader."Web Order Status" = SalesHeader."Web Order Status"::Delivered THEN BEGIN
                        SalesHeader2.GET(SalesHeader."Document Type", SalesHeader."No.");
                        SalesHeader2."Web Order Status" := SalesHeader2."Web Order Status"::Delivered;
                        SalesHeader2.MODIFY;
                    END;
                END;
            UNTIL SalesHeader.NEXT = 0;

    end;
}
