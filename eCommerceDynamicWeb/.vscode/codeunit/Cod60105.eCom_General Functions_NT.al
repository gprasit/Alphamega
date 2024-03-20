codeunit 60105 "eCom_General Functions_NT"
{
    trigger OnRun()
    begin

    end;


    procedure ChangeSalesLineLoc(var SalesHeader: Record "Sales Header")
    var
        LineRec: Record "Sales Line";
        LocationRec: Record "LSC Store";
        LocationList: Page "LSC Store List";
    begin
        SalesHeader.TestField(Status, SalesHeader.Status::Open);
        LocationRec.RESET;
        CLEAR(LocationList);
        LocationList.LOOKUPMODE(TRUE);
        LocationList.SETRECORD(LocationRec);
        if LocationList.RUNMODAL = ACTION::LookupOK then begin
            LocationList.GETRECORD(LocationRec);
            //MESSAGE(LocationRec.Code);
            LocationRec.TESTFIELD("Location Code");
            SalesHeader.Validate("LSC Store No.", LocationRec."No.");
            SalesHeader.MODIFY(TRUE);
            CLEAR(LineRec);
            LineRec.RESET;
            LineRec.SETRANGE("Document Type", SalesHeader."Document Type");
            LineRec.SETRANGE("Document No.", SalesHeader."No.");
            LineRec.SETFILTER("No.", '<>%1', '');
            IF LineRec.FINDFIRST THEN
                REPEAT
                    LineRec.VALIDATE("Location Code", LocationRec."Location Code");
                    LineRec.MODIFY(TRUE);
                UNTIL LineRec.NEXT = 0;
            Message(Txt001);
        end else
            Message(Txt002);
    end;

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
        PrefixArray := PrefixArray.CreateInstance(GetDotNetType(String), 250);
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

    procedure CreateSalesReturnOrder(Var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesReturnOrder: Record "Sales Header";
        SalesReturnLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        ExactCostReversingMandatory: Boolean;
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;
        FromDocNo: Code[20];
        FromDocType: Enum "Sales Document Type From";
    begin
        if ReturnLinesExist(SalesHeader) then
            Error(Txt003, SalesReturnOrder."No.", SalesHeader."Document Type", SalesHeader."No.");

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '>0');
        if SalesLine.IsEmpty then
            Error(Txt004);

        SalesSetup.Get();
        ExactCostReversingMandatory := SalesSetup."Exact Cost Reversing Mandatory";
        IncludeHeader := true;
        RecalculateLines := false;
        FromDocNo := SalesHeader."No.";

        CopyDocMgt.SetProperties(
          IncludeHeader, RecalculateLines, false, false, false, ExactCostReversingMandatory, false);

        SalesReturnOrder.Init();
        SalesReturnOrder."Document Type" := SalesReturnOrder."Document Type"::"Return Order";
        SalesReturnOrder."External Document No." := SalesHeader."No.";
        SalesReturnOrder.Insert(true);

        case SalesHeader."Document Type" of

            SalesHeader."Document Type"::"Blanket Order":
                FromDocType := FromDocType::"Blanket Order";

            SalesHeader."Document Type"::"Credit Memo":
                FromDocType := FromDocType::"Credit Memo";

            SalesHeader."Document Type"::Invoice:
                FromDocType := FromDocType::Invoice;

            SalesHeader."Document Type"::Order:
                FromDocType := FromDocType::Order;

            SalesHeader."Document Type"::Quote:
                FromDocType := FromDocType::Quote;

            SalesHeader."Document Type"::"Return Order":
                FromDocType := FromDocType::"Return Order";
        end;

        CopyDocMgt.CopySalesDoc(FromDocType, FromDocNo, SalesReturnOrder);
        SalesReturnOrder."External Document No." := SalesHeader."No.";
        SalesReturnOrder.Modify(true);
        SalesReturnLine.SetFilter("Document Type", '%1', SalesReturnOrder."Document Type");
        SalesReturnLine.SetFilter("Document No.", SalesReturnOrder."No.");
        SalesReturnLine.SetFilter(Quantity, '>0');
        SalesReturnLine.ModifyAll("Return Qty. to Receive",0,true);
        Commit();
        Page.RunModal(Page::"Sales Return Order List", SalesReturnOrder);
    end;

    procedure ReturnLinesExist(Var SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesReturnLine: Record "Sales Line";
        LinesFound: Boolean;
    begin
        LinesFound := false;
        SalesLine.SetFilter("Document Type", '%1', SalesHeader."Document Type");
        SalesLine.SetFilter("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '>0');
        if SalesLine.FindSet() then
            repeat
                SalesReturnLine.Reset();
                case SalesLine."Document Type" of

                    SalesLine."Document Type"::"Blanket Order":
                        SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::"Blanket Order");
                    SalesLine."Document Type"::"Credit Memo":
                        SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::"Credit Memo");
                    SalesLine."Document Type"::Invoice:
                        SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::Invoice);
                    SalesLine."Document Type"::Order:
                        SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::Order);
                    SalesLine."Document Type"::Quote:
                        SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::Quote);
                    SalesLine."Document Type"::"Return Order":
                        SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::"Return Order");
                end;
                SalesReturnLine.SetFilter("From Document No.", SalesLine."Document No.");
                SalesReturnLine.SetFilter("From Line No.", '%1', SalesLine."Line No.");
                LinesFound := SalesReturnLine.FindFirst();
            until ((SalesLine.Next() = 0) or LinesFound);
        exit(LinesFound);
    end;

    procedure OpenSalesReturnOrder(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesReturnLine: Record "Sales Line";
        SalesReturnOrder: Record "Sales Header";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '>0');
        if SalesLine.FindFirst() then begin
            case SalesLine."Document Type" of
                SalesLine."Document Type"::"Blanket Order":
                    SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::"Blanket Order");
                SalesLine."Document Type"::"Credit Memo":
                    SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::"Credit Memo");
                SalesLine."Document Type"::Invoice:
                    SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::Invoice);
                SalesLine."Document Type"::Order:
                    SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::Order);
                SalesLine."Document Type"::Quote:
                    SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::Quote);
                SalesLine."Document Type"::"Return Order":
                    SalesReturnLine.SetFilter("From Document Type", '%1', SalesReturnLine."From Document Type"::"Return Order");
            end;
            SalesReturnLine.SetFilter("Document Type", '%1', SalesReturnLine."Document Type"::"Return Order");
            SalesReturnLine.SetFilter("From Document No.", SalesLine."Document No.");
            SalesReturnLine.SetFilter("From Line No.", '%1', SalesLine."Line No.");
            if SalesReturnLine.FindFirst() then begin
                SalesReturnOrder.SetRange("Document Type", SalesReturnLine."Document Type");
                SalesReturnOrder.SetRange("No.", SalesReturnLine."Document No.");
                Page.RunModal(Page::"Sales Return Order List", SalesReturnOrder);
            end else
                Message(Txt005);
        end else
            Message(Txt005);
    end;

    procedure GetJsonNoOfValue(VAR GenBuffer: Record "eCom_General Buffer_NT"; ParameterName: Text): Integer
    begin
        GenBuffer.SETRANGE("Text 1", ParameterName);
        EXIT(GenBuffer.COUNT);
    end;

    procedure GetJsonValueAtIndex(VAR GenBuffer: Record "eCom_General Buffer_NT"; Index: Integer; ParameterName: Text): Text
    begin
        GenBuffer.SETRANGE("Text 1", ParameterName);
        GenBuffer.FINDFIRST;
        IF Index > 0 THEN
            GenBuffer.NEXT(Index);
        EXIT(GenBuffer."Text 2");
    end;

    procedure XmlBufferFindNodeText(var TempResultXMLBuffer: Record "XML Buffer" temporary; NodeName: Text[250]; NodeType: Option): Text[250]
    begin
        TempResultXMLBuffer.Reset();
        TempResultXMLBuffer.SetRange(Type, NodeType);
        TempResultXMLBuffer.SetFilter(Name, NodeName);
        if TempResultXMLBuffer.FindFirst() then
            exit(TempResultXMLBuffer.Value);
        exit('');
    end;

    procedure KioskImportExportTemplate(var KioskSetup: Record "Kiosk Setup_NT"; Import: Boolean; FieldNo: Integer)
    var
        InS: instream;
        OutS: OutStream;
        FileName: Text;
    begin
        if Import then begin
            case FieldNo of
                KioskSetup.FieldNo("Welcome Email Template"):
                    begin
                        FileName := 'Email_Welcome';
                        KioskSetup.CalcFields("Welcome Email Template");
                        if KioskSetup."Welcome Email Template".HasValue then
                            if not Confirm(OverrideTemplateQst) then
                                Error('');
                        KioskSetup."Welcome Email Template".CreateInStream(InS, TextEncoding::UTF8);
                        if UploadIntoStream('Select Template', '', '', FileName, InS) then begin
                            KioskSetup."Welcome Email Template".CreateOutStream(OutS, TextEncoding::UTF8);
                            CopyStream(OutS, InS);
                            KioskSetup.Modify();
                        end;
                    end;
                KioskSetup.FieldNo("Update Email Template"):
                    begin
                        FileName := 'Email_Update';
                        KioskSetup.CalcFields("Update Email Template");
                        if KioskSetup."Update Email Template".HasValue then
                            if not Confirm(OverrideTemplateQst) then
                                Error('');
                        KioskSetup."Update Email Template".CreateInStream(InS, TextEncoding::UTF8);
                        if UploadIntoStream('Select Template', '', '', FileName, InS) then begin
                            KioskSetup."Update Email Template".CreateOutStream(OutS, TextEncoding::UTF8);
                            CopyStream(OutS, InS);
                            KioskSetup.Modify();
                        end;
                    end;
                KioskSetup.FieldNo("Change PIN Email Template"):
                    begin
                        FileName := 'Email_ChangePIN';
                        KioskSetup.CalcFields("Change PIN Email Template");
                        if KioskSetup."Change PIN Email Template".HasValue then
                            if not Confirm(OverrideTemplateQst) then
                                Error('');
                        KioskSetup."Change PIN Email Template".CreateInStream(InS, TextEncoding::UTF8);
                        if UploadIntoStream('Select Template', '', '', FileName, InS) then begin
                            KioskSetup."Change PIN Email Template".CreateOutStream(OutS, TextEncoding::UTF8);
                            CopyStream(OutS, InS);
                            KioskSetup.Modify();
                        end;
                    end;
                KioskSetup.FieldNo("Voucher Email Template"):
                    begin
                        FileName := 'Email_Voucher';
                        KioskSetup.CalcFields("Voucher Email Template");
                        if KioskSetup."Voucher Email Template".HasValue then
                            if not Confirm(OverrideTemplateQst) then
                                Error('');
                        KioskSetup."Voucher Email Template".CreateInStream(InS, TextEncoding::UTF8);
                        if UploadIntoStream('Select Template', '', '', FileName, InS) then begin
                            KioskSetup."Voucher Email Template".CreateOutStream(OutS, TextEncoding::UTF8);
                            CopyStream(OutS, InS);
                            KioskSetup.Modify();
                        end;
                    end;

                KioskSetup.FieldNo("Welcome SMS Template"):
                    begin
                        FileName := 'SMS_Welcome';
                        KioskSetup.CalcFields("Welcome SMS Template");
                        if KioskSetup."Welcome SMS Template".HasValue then
                            if not Confirm(OverrideTemplateQst) then
                                Error('');
                        KioskSetup."Welcome SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                        if UploadIntoStream('Select Template', '', '', FileName, InS) then begin
                            KioskSetup."Welcome SMS Template".CreateOutStream(OutS, TextEncoding::UTF8);
                            CopyStream(OutS, InS);
                            KioskSetup.Modify();
                        end;
                    end;
                KioskSetup.FieldNo("Update SMS Template"):
                    begin
                        FileName := 'SMS_Update';
                        KioskSetup.CalcFields("Update SMS Template");
                        if KioskSetup."Update SMS Template".HasValue then
                            if not Confirm(OverrideTemplateQst) then
                                Error('');
                        KioskSetup."Update SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                        if UploadIntoStream('Select Template', '', '', FileName, InS) then begin
                            KioskSetup."Update SMS Template".CreateOutStream(OutS, TextEncoding::UTF8);
                            CopyStream(OutS, InS);
                            KioskSetup.Modify();
                        end;
                    end;
                KioskSetup.FieldNo("Change PIN SMS Template"):
                    begin
                        FileName := 'SMS_ChangePIN';
                        KioskSetup.CalcFields("Change PIN SMS Template");
                        if KioskSetup."Change PIN SMS Template".HasValue then
                            if not Confirm(OverrideTemplateQst) then
                                Error('');
                        KioskSetup."Change PIN SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                        if UploadIntoStream('Select Template', '', '', FileName, InS) then begin
                            KioskSetup."Change PIN SMS Template".CreateOutStream(OutS, TextEncoding::UTF8);
                            CopyStream(OutS, InS);
                            KioskSetup.Modify();
                        end;
                    end;
                KioskSetup.FieldNo("Voucher SMS Template"):
                    begin
                        FileName := 'SMS_Voucher';
                        KioskSetup.CalcFields("Voucher SMS Template");
                        if KioskSetup."Voucher SMS Template".HasValue then
                            if not Confirm(OverrideTemplateQst) then
                                Error('');
                        KioskSetup."Voucher SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                        if UploadIntoStream('Select Template', '', '', FileName, InS) then begin
                            KioskSetup."Voucher SMS Template".CreateOutStream(OutS, TextEncoding::UTF8);
                            CopyStream(OutS, InS);
                            KioskSetup.Modify();
                        end;
                    end;
            end;
        end else begin
            case FieldNo of
                KioskSetup.FieldNo("Welcome Email Template"):
                    begin
                        FileName := 'Email_Welcome.htm';
                        KioskSetup.CalcFields("Welcome Email Template");
                        if KioskSetup."Welcome Email Template".HasValue then begin
                            KioskSetup."Welcome Email Template".CreateInStream(InS, TextEncoding::UTF8);
                            DownloadFromStream(InS, 'Save Template', '', '', FileName);
                        end;
                    end;
                KioskSetup.FieldNo("Update Email Template"):
                    begin
                        FileName := 'Email_Update.htm';
                        KioskSetup.CalcFields("Update Email Template");
                        if KioskSetup."Update Email Template".HasValue then begin
                            KioskSetup."Update Email Template".CreateInStream(InS, TextEncoding::UTF8);
                            DownloadFromStream(InS, 'Save Template', '', '', FileName);
                        end;
                    end;
                KioskSetup.FieldNo("Change PIN Email Template"):
                    begin
                        FileName := 'Email_ChangePIN.htm';
                        KioskSetup.CalcFields("Change PIN Email Template");
                        if KioskSetup."Change PIN Email Template".HasValue then begin
                            KioskSetup."Change PIN Email Template".CreateInStream(InS, TextEncoding::UTF8);
                            DownloadFromStream(InS, 'Save Template', '', '', FileName);
                        end;
                    end;
                KioskSetup.FieldNo("Voucher Email Template"):
                    begin
                        FileName := 'Email_Voucher.htm';
                        KioskSetup.CalcFields("Voucher Email Template");
                        if KioskSetup."Voucher Email Template".HasValue then begin
                            KioskSetup."Voucher Email Template".CreateInStream(InS, TextEncoding::UTF8);
                            DownloadFromStream(InS, 'Save Template', '', '', FileName);
                        end;
                    end;

                KioskSetup.FieldNo("Welcome SMS Template"):
                    begin
                        FileName := 'SMS_Welcome.txt';
                        KioskSetup.CalcFields("Welcome SMS Template");
                        if KioskSetup."Welcome SMS Template".HasValue then begin
                            KioskSetup."Welcome SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                            DownloadFromStream(InS, 'Save Template', '', '', FileName);
                        end;
                    end;
                KioskSetup.FieldNo("Update SMS Template"):
                    begin
                        FileName := 'SMS_Update.txt';
                        KioskSetup.CalcFields("Update SMS Template");
                        if KioskSetup."Update SMS Template".HasValue then begin
                            KioskSetup."Update SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                            DownloadFromStream(InS, 'Save Template', '', '', FileName);
                        end;
                    end;
                KioskSetup.FieldNo("Change PIN SMS Template"):
                    begin
                        FileName := 'SMS_ChangePIN.txt';
                        KioskSetup.CalcFields("Change PIN SMS Template");
                        if KioskSetup."Change PIN SMS Template".HasValue then begin
                            KioskSetup."Change PIN SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                            DownloadFromStream(InS, 'Save Template', '', '', FileName);
                        end;
                    end;
                KioskSetup.FieldNo("Voucher SMS Template"):
                    begin
                        FileName := 'SMS_Voucher.txt';
                        KioskSetup.CalcFields("Voucher SMS Template");
                        if KioskSetup."Voucher SMS Template".HasValue then begin
                            KioskSetup."Voucher SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                            DownloadFromStream(InS, 'Save Template', '', '', FileName);
                        end;
                    end;
            end;
        end;
    end;

    procedure SendEmail(Email: Text; Body: Text): Text
    var
        EmailMsg: Codeunit "Email Message";
        EmailSend: Codeunit Email;
        ResultOk: Boolean;
    begin
        EmailMsg.Create(Email, 'Receipt', '', true);
        EmailMsg.AppendToBody(Body);
        ResultOk := EmailSend.Send(EmailMsg, Enum::"Email Scenario"::Default);
        if not ResultOk then
            exit(GetLastErrorText())
        else
            exit('');
    end;

    procedure Integer2Binary(Int: Integer) BinaryVal: Text
    var
        Remainder: Decimal;
        Quotient: Integer;
    begin
        Quotient := Int;
        while Quotient > 0 do begin
            Remainder := Quotient MOD 2;
            Quotient := Quotient DIV 2;
            BinaryVal := Format(Remainder) + BinaryVal;
        end;
        BinaryVal := PadStr('', 5 - strlen(BinaryVal), '0') + BinaryVal;
    end;

    procedure ReplaceText(SearchText: Text; OldText: Text; NewText: Text): Text
    var
        TxtBuilder: TextBuilder;
    begin
        TxtBuilder.Append(SearchText);
        TxtBuilder.Replace(OldText, NewText);
        Exit(TxtBuilder.ToText());
    end;

    procedure IssueCouponLS(SelectedCouponHeader: Record "LSC Coupon Header"; var BarcodeNo: Code[22]): Text
    var
        BarcodeMaskCharacter: Record "LSC Barcode Mask Character";
        BarcodeMaskSegment: Record "LSC Barcode Mask Segment";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        CheckDigitExists: Boolean;
        NumberSeriesExist: Boolean;
        SequenceExists: Boolean;
        BarcodeWithoutSequence: Code[22];
        NoFromNumberSeries: Code[20];
        NumberSeriesCode: Code[10];
        FirstValidDate: Date;
        LastValidDate: Date;
        DiscountPercentageOrAmt: Decimal;
        Chk: Integer;
        Day: Integer;

        Month: Integer;
        NoFromNumberSeriesInt: Integer;
        NumberSeriesLength: Integer;
        SequenceLength: Integer;
        SequenceNo: Integer;
        Year: Integer;
        BarcodeChar: Text[30];
        BarcodeValueArray: array[10] of Text[30];
    begin
        PopulateArrays(SelectedCouponHeader, BarcodeValueArray);
        SequenceExists := false;
        NumberSeriesExist := false;
        CheckDigitExists := false;
        BarcodeWithoutSequence := '';
        BarcodeMaskRec.Reset;
        BarcodeMaskRec.SetRange(Type, BarcodeMaskRec.Type::Coupon);
        BarcodeMaskRec.SetRange(Mask, SelectedCouponHeader."Barcode Mask");
        BarcodeMaskRec.FindFirst;
        BarcodeMaskSegment.Reset;
        BarcodeMaskSegment.SetRange("Mask Entry No.", BarcodeMaskRec."Entry No.");
        for I := 1 to 8 do begin
            case I of
                1:
                    ElementType := SelectedCouponHeader."Barcode Element 1".AsInteger();
                2:
                    ElementType := SelectedCouponHeader."Barcode Element 2".AsInteger();
                3:
                    ElementType := SelectedCouponHeader."Barcode Element 3".AsInteger();
                4:
                    ElementType := SelectedCouponHeader."Barcode Element 4".AsInteger();
                5:
                    ElementType := SelectedCouponHeader."Barcode Element 5".AsInteger();
                6:
                    ElementType := SelectedCouponHeader."Barcode Element 6".AsInteger();
                7:
                    ElementType := SelectedCouponHeader."Barcode Element 7".AsInteger();
                8:
                    ElementType := SelectedCouponHeader."Barcode Element 8".AsInteger();
            end;
            case Enum::"LSC Barcode Element".FromInteger(ElementType) of
                CouponHeader."Barcode Element 1"::Prefix:
                    begin
                        BarcodeNo := BarcodeNo + BarcodeMaskRec.Prefix;
                        BarcodeWithoutSequence := BarcodeWithoutSequence + BarcodeMaskRec.Prefix;
                    end;
                CouponHeader."Barcode Element 1"::"Coupon Reference No.":
                    begin
                        BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Coupon Reference");
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        BarcodeMaskSegment.FindFirst;
                        BarcodeNo := BarcodeNo + CopyStr('0000000000000000000000', 1, BarcodeMaskSegment.Length - StrLen(SelectedCouponHeader."Coupon Reference No.")) +
                          SelectedCouponHeader."Coupon Reference No.";
                        BarcodeWithoutSequence := BarcodeWithoutSequence +
                          CopyStr('0000000000000000000000', 1, BarcodeMaskSegment.Length - StrLen(SelectedCouponHeader."Coupon Reference No.")) + SelectedCouponHeader."Coupon Reference No.";
                    end;
                SelectedCouponHeader."Barcode Element 1"::"Discount %",
                SelectedCouponHeader."Barcode Element 1"::"Discount Amount":
                    begin
                        Evaluate(DiscountPercentageOrAmt, BarcodeValueArray[I]);
                        if DiscountPercentageOrAmt <= 0 then begin
                            SelectedCouponHeader."Barcode Element 8" := Enum::"LSC Barcode Element".FromInteger(ElementType);
                            Exit(StrSubstNo(Text006, Format(SelectedCouponHeader."Barcode Element 8")));
                        end;
                        //CouponEntry.Value := DiscountPercentageOrAmt;
                        BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::Price);
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        BarcodeMaskSegment.FindFirst;
                        BarcodeNo := BarcodeNo + ReturnDiscount(DiscountPercentageOrAmt, BarcodeMaskSegment.Decimals, BarcodeMaskSegment.Length);
                        BarcodeWithoutSequence := BarcodeWithoutSequence +
                          ReturnDiscount(DiscountPercentageOrAmt, BarcodeMaskSegment.Decimals, BarcodeMaskSegment.Length);
                    end;
                SelectedCouponHeader."Barcode Element 1"::"First Valid Date (DDMMYY)":
                    begin
                        Evaluate(Day, CopyStr(BarcodeValueArray[I], 1, 2));
                        Evaluate(Month, CopyStr(BarcodeValueArray[I], 3, 2));
                        Evaluate(Year, CopyStr(BarcodeValueArray[I], 5, 2));
                        if Year > 60 then
                            Year := Year + 1900
                        else
                            Year := Year + 2000;
                        //CouponEntry."First Valid Date" := DMY2Date(Day, Month, Year);
                        FirstValidDate := DMY2Date(Day, Month, Year);
                        BarcodeNo := BarcodeNo + Format(FirstValidDate, 0, '<Day,2><Month,2><Year>');
                        BarcodeWithoutSequence := BarcodeWithoutSequence + Format(FirstValidDate, 0, '<Day,2><Month,2><Year>');
                    end;
                SelectedCouponHeader."Barcode Element 1"::"Last Valid Date (DDMMYY)":
                    begin
                        Evaluate(Day, CopyStr(BarcodeValueArray[I], 1, 2));
                        Evaluate(Month, CopyStr(BarcodeValueArray[I], 3, 2));
                        Evaluate(Year, CopyStr(BarcodeValueArray[I], 5, 2));
                        if Year > 60 then
                            Year := Year + 1900
                        else
                            Year := Year + 2000;
                        //CouponEntry."Last Valid Date" := DMY2Date(Day, Month, Year);
                        LastValidDate := DMY2Date(Day, Month, Year);
                        BarcodeNo := BarcodeNo + Format(LastValidDate, 0, '<Day,2><Month,2><Year>');
                        BarcodeWithoutSequence := BarcodeWithoutSequence + Format(LastValidDate, 0, '<Day,2><Month,2><Year>');
                    end;
                SelectedCouponHeader."Barcode Element 1"::"Sequence No.":
                    begin
                        Evaluate(SequenceNo, BarcodeValueArray[I]);
                        SequenceExists := true;
                        if not BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Serial No.") then
                            BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Any No.");
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        BarcodeMaskSegment.FindFirst;
                        SequenceLength := BarcodeMaskSegment.Length;
                        BarcodeNo := BarcodeNo + CopyStr('######################', 1, SequenceLength);
                        BarcodeWithoutSequence := BarcodeWithoutSequence + CopyStr('######################', 1, SequenceLength);
                    end;
                SelectedCouponHeader."Barcode Element 1"::"Number Series":
                    begin
                        if BarcodeValueArray[I] = '' then
                            exit(StrSubstNo(Text007, SelectedCouponHeader."Barcode Mask"));
                        NumberSeriesCode := BarcodeValueArray[I];
                        NumberSeriesExist := true;
                        BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Number Series");
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        if not BarcodeMaskSegment.FindFirst then
                            exit(StrSubstNo(Text008, SelectedCouponHeader."Barcode Mask"));
                        NumberSeriesLength := BarcodeMaskSegment.Length;
                        BarcodeNo := BarcodeNo + CopyStr('@@@@@@@@@@@@@@@@@@@@@@', 1, NumberSeriesLength);
                        BarcodeWithoutSequence := BarcodeWithoutSequence + CopyStr('@@@@@@@@@@@@@@@@@@@@@@', 1, NumberSeriesLength);
                    end;
                SelectedCouponHeader."Barcode Element 1"::"Check Digit":
                    begin
                        CheckDigitExists := true;
                        //Clear(EmptyItem);
                    end;
                SelectedCouponHeader."Barcode Element 1"::"Any Number":
                    begin
                        BarcodeNo := BarcodeNo + BarcodeValueArray[I];
                        BarcodeWithoutSequence := BarcodeWithoutSequence + BarcodeValueArray[I];
                    end;
            end;
        end;
        if SequenceExists then
            BarcodeNo := AddNumberToBarcode(BarcodeWithoutSequence, SequenceNo, SequenceLength, '#', 1);
        if NumberSeriesExist then begin
            NoFromNumberSeries := '';
            NoSeriesManagement.InitSeries(NumberSeriesCode, NumberSeriesCode, Today, NoFromNumberSeries, NumberSeriesCode);
            Evaluate(NoFromNumberSeriesInt, NoFromNumberSeries);
            BarcodeNo := AddNumberToBarcode(BarcodeWithoutSequence, NoFromNumberSeriesInt, NumberSeriesLength, '@', 2);
        end;
        if CheckDigitExists then begin
            if StrLen(BarcodeNo) mod 2 = 0 then
                Chk := 1 + StrCheckSum(BarcodeNo, CopyStr('1313131313131313131313', 1, StrLen(BarcodeNo)))
            else
                Chk := 1 + StrCheckSum(BarcodeNo, CopyStr('3131313131313131313131', 1, StrLen(BarcodeNo)));
            BarcodeChar := SelectStr(Chk, '0,1,2,3,4,5,6,7,8,9');
            BarcodeNo := BarcodeNo + BarcodeChar;
        end;
        //BarcodeNo := BarcodeWithoutSequence;
        exit('');//No Error
    end;

    local procedure PopulateArrays(SelectedCouponHeader: Record "LSC Coupon Header"; var BarcodeValueArray: array[10] of Text[30])
    var
        CouponManagement: Codeunit "LSC Coupon Management";
        Text002: Label 'The %1 must be filled out.';
        Text003: Label '*';
        Text004: Label 'Enter %';
        Text005: Label 'Enter Amt.';
        Text016: Label 'Barcode Mask is NOT correctly constructed.';
    begin
        //Clear(BarcodeElementArray);
        Clear(BarcodeValueArray);

        // ErrMsg := CouponManagement.CheckBarcodeMask(SelectedCouponHeader."Barcode Mask", SelectedCouponHeader."Coupon Reference No.",
        //   SelectedCouponHeader."Coupon Issuer",
        //   SelectedCouponHeader."First Valid Date Formula", SelectedCouponHeader."Last Valid Date Formula",
        //   SelectedCouponHeader."Barcode Element 1".AsInteger(), SelectedCouponHeader."Barcode Element 2".AsInteger(), SelectedCouponHeader."Barcode Element 3".AsInteger(),
        //   SelectedCouponHeader."Barcode Element 4".AsInteger(), SelectedCouponHeader."Barcode Element 5".AsInteger(), SelectedCouponHeader."Barcode Element 6".AsInteger(),
        //   SelectedCouponHeader."Barcode Element 7".AsInteger(), SelectedCouponHeader."Barcode Element 8".AsInteger());

        // if SelectedCouponHeader."Barcode Mask" = '' then
        //     ErrMsg := StrSubstNo(Text002, SelectedCouponHeader.FieldCaption("Barcode Mask"));
        // if ErrMsg <> '' then begin
        //     Message(Text016 + '\' + ErrMsg);
        //     exit;
        // end;

        // BarcodeElementArray[1] := Format(SelectedCouponHeader."Barcode Element 1");
        // BarcodeElementArray[2] := Format(SelectedCouponHeader."Barcode Element 2");
        // BarcodeElementArray[3] := Format(SelectedCouponHeader."Barcode Element 3");
        // BarcodeElementArray[4] := Format(SelectedCouponHeader."Barcode Element 4");
        // BarcodeElementArray[5] := Format(SelectedCouponHeader."Barcode Element 5");
        // BarcodeElementArray[6] := Format(SelectedCouponHeader."Barcode Element 6");
        // BarcodeElementArray[7] := Format(SelectedCouponHeader."Barcode Element 7");
        // BarcodeElementArray[8] := Format(SelectedCouponHeader."Barcode Element 8");

        for I := 1 to 8 do begin
            case I of
                1:
                    ElementType := SelectedCouponHeader."Barcode Element 1".AsInteger();
                2:
                    ElementType := SelectedCouponHeader."Barcode Element 2".AsInteger();
                3:
                    ElementType := SelectedCouponHeader."Barcode Element 3".AsInteger();
                4:
                    ElementType := SelectedCouponHeader."Barcode Element 4".AsInteger();
                5:
                    ElementType := SelectedCouponHeader."Barcode Element 5".AsInteger();
                6:
                    ElementType := SelectedCouponHeader."Barcode Element 6".AsInteger();
                7:
                    ElementType := SelectedCouponHeader."Barcode Element 7".AsInteger();
                8:
                    ElementType := SelectedCouponHeader."Barcode Element 8".AsInteger();
            end;
            case Enum::"LSC Barcode Element".FromInteger(ElementType) of
                CouponHeader."Barcode Element 1"::Prefix:
                    begin
                        BarcodeMaskRec.Reset;
                        BarcodeMaskRec.SetRange(Type, BarcodeMaskRec.Type::Coupon);
                        BarcodeMaskRec.SetRange(Mask, SelectedCouponHeader."Barcode Mask");
                        BarcodeMaskRec.FindFirst;
                        BarcodeValueArray[I] := BarcodeMaskRec.Prefix;
                    end;
                CouponHeader."Barcode Element 1"::"Coupon Reference No.":
                    BarcodeValueArray[I] := SelectedCouponHeader."Coupon Reference No.";
                CouponHeader."Barcode Element 1"::"Discount %":
                    begin
                        BarcodeValueArray[I] := Text004;
                        BarcodeValueArray[I] := Format(SelectedCouponHeader.Value, 0, '<Integer Thousand><Decimal,3>');
                    end;
                CouponHeader."Barcode Element 1"::"Discount Amount":
                    begin
                        BarcodeValueArray[I] := Text005;
                        BarcodeValueArray[I] := Format(SelectedCouponHeader.Value, 0, '<Integer Thousand><Decimal,3>');
                    end;
                CouponHeader."Barcode Element 1"::"First Valid Date (DDMMYY)":
                    BarcodeValueArray[I] := Format(CalcDate(SelectedCouponHeader."First Valid Date Formula", Today), 0, '<Day,2><Month,2><Year>');
                CouponHeader."Barcode Element 1"::"Last Valid Date (DDMMYY)":
                    BarcodeValueArray[I] := Format(CalcDate(SelectedCouponHeader."Last Valid Date Formula", Today), 0, '<Day,2><Month,2><Year>');
                CouponHeader."Barcode Element 1"::"Sequence No.":
                    BarcodeValueArray[I] := '1';
                CouponHeader."Barcode Element 1"::"Number Series":
                    begin
                        BarcodeMaskRec.Reset;
                        BarcodeMaskRec.SetRange(Type, BarcodeMaskRec.Type::Coupon);
                        BarcodeMaskRec.SetRange(Mask, SelectedCouponHeader."Barcode Mask");
                        BarcodeMaskRec.FindFirst;
                        BarcodeValueArray[I] := BarcodeMaskRec."Number Series";
                    end;
                CouponHeader."Barcode Element 1"::"Check Digit":
                    BarcodeValueArray[I] := Text003;
            end;
        end;
    end;


    local procedure ReturnDiscount(DiscountValue: Decimal; NoOfDecimals: Integer; LengthOfField: Integer) Disc: Text[30]
    var
        FractionValue: Decimal;
        RoundingPrec: Decimal;
        IntegerValue: Integer;
        Text007: Label 'The Discount Percentage or the Discount Amount (%1) has a length greater than can be used with this Barcode Mask.';
    begin
        if NoOfDecimals = 0 then
            Disc := Format(Round(DiscountValue, 1), 0, '<Integer>')
        else begin
            IntegerValue := Round(DiscountValue, 1, '<');
            FractionValue := DiscountValue - IntegerValue;
            RoundingPrec := 1 / Power(10, NoOfDecimals);
            Disc := Format(Round(FractionValue, RoundingPrec) + 0.0000000001, 0, '<Decimals>');
            if StrLen(Disc) < NoOfDecimals then
                Disc := Disc + CopyStr('000000000000000000000', 1, NoOfDecimals - StrLen(Disc));
            Disc := Format(IntegerValue, 0, '<Integer>') + CopyStr(Disc, 2, NoOfDecimals);
        end;
        if StrLen(Disc) < LengthOfField then
            Disc := CopyStr('0000000000000000000000', 1, LengthOfField - StrLen(Disc)) + Disc
        else
            if StrLen(Disc) > LengthOfField then
                Error(Text007, DiscountValue);
        exit(Disc);
    end;

    local procedure AddNumberToBarcode(BarcodeIn: Text[30]; NumberIn: Integer; NumberLen: Integer; MaskCh: Text[30]; SequenceNumberSeries: Integer) BarcodeOut: Text[30]
    var
        Ix: Integer;
        SeqPos: Integer;
        NumberText: Text[30];
        Text008: Label 'The length of the Sequence field in the Barcode is %1 characters long, but the Sequence No. (%2) is %3 characters long.';
        Text015: Label 'The length of the Number Series field in the Barcode is %1 characters long, but the number from the Number Series (%2) is %3 characters long.';
    begin
        NumberText := Format(NumberIn, 0, '<Integer>');
        if StrLen(NumberText) < NumberLen then
            NumberText := CopyStr('0000000000000000000000', 1, NumberLen - StrLen(NumberText)) + NumberText
        else
            if StrLen(NumberText) > NumberLen then
                if SequenceNumberSeries = 1 then
                    Error(Text008, NumberLen, NumberText, StrLen(NumberText))
                else
                    Error(Text015, NumberLen, NumberText, StrLen(NumberText));
        SeqPos := 0;
        for Ix := 1 to StrLen(BarcodeIn) do
            if CopyStr(BarcodeIn, Ix, 1) = MaskCh then begin
                SeqPos := SeqPos + 1;
                BarcodeOut := BarcodeOut + CopyStr(NumberText, SeqPos, 1);
            end else
                BarcodeOut := BarcodeOut + CopyStr(BarcodeIn, Ix, 1);
    end;

    procedure InsertPoints(CardNo: Code[20]): Boolean
    var
        LoyaltyPoints: Record "LSC Trans. Point Entry";
        MemberPointJnlLine: Record "LSC Member Point Jnl. Line";
        MembershipCard: Record "LSC Membership Card";
        MemProcOrderEntry: Record "LSC Member Process Order Entry";
        MobileAppSetup: Record "MA_Mobile App Setup_NT";
        PointJnlPostLine: Codeunit "LSC Point Jnl.-Post Line";
        NextTransNo: Integer;
    begin
        MobileAppSetup.GET;
        IF MobileAppSetup."Registration Bonus Points" <= 0 THEN
            EXIT;

        IF NOT MembershipCard.GET(CardNo) THEN
            CLEAR(MembershipCard);

        CLEAR(MemProcOrderEntry);
        //MemProcOrderEntry.SETRANGE("Document Source", MemProcOrderEntry."Document Source"::"Mobile App");//BC Upgrade
        MemProcOrderEntry.SETRANGE("Document Source", MemProcOrderEntry."Document Source"::POS);//BC Upgrade
        MemProcOrderEntry.SETRANGE("Store No.", MobileAppSetup."Store No.");
        MemProcOrderEntry.SETRANGE("POS Terminal No.", MobileAppSetup."POS Terminal No.");
        IF MemProcOrderEntry.FINDLAST THEN
            NextTransNo := MemProcOrderEntry."Transaction No.";

        NextTransNo += 1;

        CLEAR(MemProcOrderEntry);
        //MemProcOrderEntry."Document Source" := MemProcOrderEntry."Document Source"::"Mobile App";//BC Upgrade
        MemProcOrderEntry.SETRANGE("Document Source", MemProcOrderEntry."Document Source"::POS);//BC Upgrade
        MemProcOrderEntry."Store No." := MobileAppSetup."Store No.";
        MemProcOrderEntry."POS Terminal No." := MobileAppSetup."POS Terminal No.";
        MemProcOrderEntry."Transaction No." := NextTransNo;
        MemProcOrderEntry.Date := TODAY;
        MemProcOrderEntry.Time := TIME;
        MemProcOrderEntry."Card No." := CardNo;
        MemProcOrderEntry."Account No." := MembershipCard."Account No.";
        MemProcOrderEntry."Points in Transaction" := MobileAppSetup."Registration Bonus Points";
        EXIT(MemProcOrderEntry.INSERT);

        CLEAR(MemberPointJnlLine);
        MemberPointJnlLine.Type := MemberPointJnlLine.Type::"Pos. Adjustment";
        MemberPointJnlLine.VALIDATE("Card No.", CardNo);
        MemberPointJnlLine.Date := TODAY;
        MemberPointJnlLine.VALIDATE(Points, MobileAppSetup."Registration Bonus Points");
        MemberPointJnlLine."Store No." := MobileAppSetup."Store No.";
        MemberPointJnlLine."POS Terminal No." := MobileAppSetup."POS Terminal No.";
        //BC Upgrade Start
        /*
        PointJnlPostLine.RUN(MemberPointJnlLine);
        EXIT(PointJnlPostLine.EntryNo > 0);
        */
        exit(PointJnlPostLine.RUN(MemberPointJnlLine));
        //BC Upgrade End
    end;

    procedure InsertAttributes(CardNo: Code[20]): Boolean
    var
        MemberAttributeValueRec: Record "LSC Member Attribute Value";
        MemberAttributeValueUpdate: Record "MA_Member Attr Value Update_NT";
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
    begin
        IF NOT MembershipCard.GET(CardNo) THEN
            EXIT;
        IF NOT MemberContact.GET(MembershipCard."Account No.", MembershipCard."Contact No.") THEN
            EXIT;

        MemberAttributeValueUpdate.SETRANGE(Type, MemberAttributeValueUpdate.Type::"New Member");
        MemberAttributeValueUpdate.SETFILTER("Club Code", '<>%1', '');
        MemberAttributeValueUpdate.SETFILTER("Member Attribute", '<>%1', '');
        MemberAttributeValueUpdate.SETFILTER("Member Attribute Value", '<>%1', '');
        IF MemberAttributeValueUpdate.FINDSET THEN
            REPEAT
                IF NOT MemberAttributeValueRec.GET(MemberAttributeValueUpdate."Club Code", MemberContact."Account No.", MemberContact."Contact No.", MemberAttributeValueUpdate."Member Attribute") THEN BEGIN
                    CLEAR(MemberAttributeValueRec);
                    MemberAttributeValueRec."Club Code" := MemberAttributeValueUpdate."Club Code";
                    MemberAttributeValueRec."Account No." := MemberContact."Account No.";
                    MemberAttributeValueRec."Contact No." := MemberContact."Contact No.";
                    MemberAttributeValueRec."Attribute Code" := MemberAttributeValueUpdate."Member Attribute";
                    MemberAttributeValueRec.INSERT;
                END;
                MemberAttributeValueRec.VALIDATE("Attribute Value", MemberAttributeValueUpdate."Member Attribute Value");
                MemberAttributeValueRec.MODIFY(TRUE);
            UNTIL MemberAttributeValueUpdate.NEXT = 0;

    end;

    var
        Txt001: Label 'Location succesfully changed!';
        Txt002: Label 'You must click OK';
        Txt003: Label 'Sales Return Order %1 already created for %2 %3.';
        Txt004: Label 'Nothing to create.';
        Txt005: Label 'Return order not created.';
        Formatting: DotNet eComJsonFormatting;
        JsonTextReader: DotNet eComJsonTextReader;
        JsonTextWriter: DotNet eComJsonTextWriter;
        StringBuilder: DotNet StringBuilder;
        StringReader: DotNet StringReader;
        StringWriter: DotNet StringWriter;
        Text006: Label 'The %1 must be greater than 0.';
        Text007: Label 'The Number Series that is to be used with this Barcode Mask (%) must be filled out.';
        Text008: Label 'Barcode Mask %1 does not contain a segment for the Number Series.';

    var
        OverrideTemplateQst: Label 'The existing template will be replaced. Do you want to continue?';
        ElementType: Integer;
        I: Integer;
        BarcodeMaskRec: Record "LSC Barcode Mask";
        BarcodeMaskSegment: Record "LSC Barcode Mask Segment";
        CouponHeader: Record "LSC Coupon Header";
}
