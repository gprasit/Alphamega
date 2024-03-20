codeunit 60207 "eComFile_General Functions_NT"
{
    procedure ReadJSon(VAR String: DotNet String; VAR GenBuffer: Record "eCom_General Buffer_NT")
    var
        JsonToken: DotNet eComJsonToken;
        InArray: array[250] of Boolean;
        Code: code[10];
        ColumnNo: Integer;
        PropertyName: Text;
        PrefixArray: DotNet Array;
        PrefixString: DotNet String;
    begin
        PrefixArray := PrefixArray.CreateInstance(GETDOTNETTYPE(String), 250);
        StringReader := StringReader.StringReader(String);
        JsonTextReader := JsonTextReader.JsonTextReader(StringReader);

        Code := '0000000000';

        WHILE JsonTextReader.Read DO
            CASE TRUE OF
                JsonTextReader.TokenType.CompareTo(JsonToken.StartObject) = 0:
                    ;
                JsonTextReader.TokenType.CompareTo(JsonToken.StartArray) = 0:
                    BEGIN
                        InArray[JsonTextReader.Depth + 1] := TRUE;
                        ColumnNo := 0;
                    END;
                JsonTextReader.TokenType.CompareTo(JsonToken.StartConstructor) = 0:
                    ;
                JsonTextReader.TokenType.CompareTo(JsonToken.PropertyName) = 0:
                    BEGIN
                        PrefixArray.SetValue(JsonTextReader.Value, JsonTextReader.Depth - 1);
                        IF JsonTextReader.Depth > 1 THEN BEGIN
                            PrefixString := PrefixString.Join('_', PrefixArray, 0, JsonTextReader.Depth - 1);
                            IF PrefixString.Length > 0 THEN
                                PropertyName := PrefixString.ToString + '_' + FORMAT(JsonTextReader.Value, 0, 9)
                            ELSE
                                PropertyName := FORMAT(JsonTextReader.Value, 0, 9);
                        END ELSE
                            PropertyName := FORMAT(JsonTextReader.Value, 0, 9);
                    END;
                JsonTextReader.TokenType.CompareTo(JsonToken.String) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Integer) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Float) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Boolean) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Date) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Bytes) = 0:
                    BEGIN
                        Code := INCSTR(Code);
                        //Data Exch. No.,Line No.,Column No.,Node ID
                        GenBuffer."Code 1" := Code;
                        GenBuffer."Integer 1" := JsonTextReader.Depth;
                        GenBuffer."Integer 2" := JsonTextReader.LineNumber;
                        GenBuffer."Integer 3" := ColumnNo;
                        GenBuffer."Text 1" := PropertyName;
                        GenBuffer."Text 2" := COPYSTR(FORMAT(JsonTextReader.Value, 0, 9), 1, 250);
                        //TempPostingExchField."Data Exch. Line Def Code" := JsonTextReader.TokenType.ToString;
                        GenBuffer.INSERT;
                    END;
                JsonTextReader.TokenType.CompareTo(JsonToken.EndConstructor) = 0:
                    ;
                JsonTextReader.TokenType.CompareTo(JsonToken.EndArray) = 0:
                    InArray[JsonTextReader.Depth + 1] := FALSE;
                JsonTextReader.TokenType.CompareTo(JsonToken.EndObject) = 0:
                    IF JsonTextReader.Depth > 0 THEN
                        IF InArray[JsonTextReader.Depth] THEN ColumnNo += 1;
            END;
    end;

    procedure GetJsonValue(VAR GenBuffer: Record "eCom_General Buffer_NT"; ParameterName: Text): Text
    begin
        GenBuffer.SETRANGE("Text 1", ParameterName);
        IF GenBuffer.FINDFIRST THEN
            EXIT(GenBuffer."Text 2");
    end;

    procedure GetJsonValueAtIndex(VAR GenBuffer: Record "eCom_General Buffer_NT"; Index: Integer; ParameterName: Text): Text
    begin
        GenBuffer.SETRANGE("Text 1", ParameterName);
        GenBuffer.FINDFIRST;
        IF Index > 0 THEN
            GenBuffer.NEXT(Index);
        EXIT(GenBuffer."Text 2");
    end;

    procedure GetJsonNoOfValue(VAR GenBuffer: Record "eCom_General Buffer_NT"; ParameterName: Text): Integer
    begin
        GenBuffer.SETRANGE("Text 1", ParameterName);
        EXIT(GenBuffer.COUNT);
    end;

    procedure GetOrderTotalAmount(_SalesHeader: Record "Sales Header") OrderAmt: Decimal
    var
        SalesLine: Record "Sales Line";
        UnitPrice: Decimal;
    begin

        OrderAmt := 0;
        CLEAR(SalesLine);
        SalesLine.SETRANGE("Document Type", _SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", _SalesHeader."No.");
        IF SalesLine.FINDSET THEN
            REPEAT
                IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::"Return Order" THEN BEGIN
                    IF SalesLine."Unit Price Difference" <> 0 THEN
                        UnitPrice := SalesLine."Unit Price" - SalesLine."Unit Price Difference"
                    ELSE
                        UnitPrice := SalesLine."Unit Price";
                END ELSE
                    IF SalesLine."Actual Unit Price" <> 0 THEN
                        UnitPrice := SalesLine."Unit Price" - SalesLine."Actual Unit Price"
                    ELSE
                        UnitPrice := SalesLine."Unit Price";
                IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::Order THEN
                    OrderAmt += ROUND(SalesLine."Qty. to Ship" * UnitPrice, 0.01) - SalesLine."Line Discount Amount";
                IF _SalesHeader."Document Type" = _SalesHeader."Document Type"::"Return Order" THEN BEGIN
                    IF SalesLine."Return Qty. to Receive" > 0 THEN
                        OrderAmt += ROUND(SalesLine."Return Qty. to Receive" * UnitPrice, 0.01) - SalesLine."Line Discount Amount" + SalesLine."Return Amount to Refund"
                    ELSE
                        IF SalesLine."Unit Price Difference" > 0 THEN
                            OrderAmt += SalesLine.Quantity * (SalesLine."Unit Price" - SalesLine."Unit Price Difference");
                END;
            UNTIL SalesLine.NEXT = 0;

        OrderAmt -= _SalesHeader."Invoice Discount Value";
    end;

    procedure CalcInvoiceDiscount(var SalesHeader: Record "Sales Header"; InvDiscAmt: Decimal)
    var
        myInt: Integer;
    begin
        ValidateInvoiceDiscountAmount(SalesHeader, InvDiscAmt);
    end;

    local procedure ValidateInvoiceDiscountAmount(var SalesHeader: Record "Sales Header"; InvoiceDiscountAmount: Decimal)
    var
        SuppressTotals: Boolean;
        //ConfirmManagement: Codeunit "Confirm Management";
        DocumentTotals: Codeunit "Document Totals";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin

        SuppressTotals := CurrentClientType() = ClientType::ODataV4;
        if SuppressTotals then
            exit;
        DocumentTotals.SalesDocTotalsNotUpToDate();
        //SalesHeader.Get("Document Type", "Document No.");
        //if SalesHeader.InvoicedLineExists() then begin
            // if not ConfirmManagement.GetResponseOrDefault(UpdateInvDiscountQst, true) then
            //     exit;

            SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
            DocumentTotals.SalesDocTotalsNotUpToDate();
            UpdateSalesLine(SalesHeader);
            //CurrPage.Update(false);
        //end;
    end;

    local procedure UpdateSalesLine(var SalesHeader: Record "Sales Header")
    var
    SalesLine: Record "Sales Line";
    begin

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        IF SalesLine.FINDSET THEN
            REPEAT
                IF (SalesLine.Quantity <> 0) AND (SalesLine."Unit Price" <> 0) THEN BEGIN
                    SalesLine."Inv. Discount %" := ROUND(
                        SalesLine."Inv. Discount Amount" / ROUND(SalesLine.Quantity * SalesLine."Unit Price", 0.01) * 100, 0.00001);
                    SalesLine.MODIFY;
                END;
            UNTIL SalesLine.NEXT = 0;
    end;

    var
        JsonTextReader: DotNet eComJsonTextReader;
        StringReader: DotNet StringReader;
}
