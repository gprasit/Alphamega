codeunit 60403 "eVch_eVoucher Email Mgmt_NT"
{
    trigger OnRun()
    begin
        Code();
    end;

    local procedure Code()
    var
        TMPPOSDataEntry: Record "LSC POS Data Entry" temporary;
        SendResult: Text;
    begin
        eVchEmailQueue.SETCURRENTKEY("Date Sent");
        eVchEmailQueue.SETRANGE(eVchEmailQueue."Date Sent", 0D);
        IF eVchEmailQueue.FINDSET THEN BEGIN
            ReadTemplate;
            REPEAT
                IF SendEmail(eVchEmailQueue."Entry Code", eVchEmailQueue."Date Created", eVchEmailQueue.Amount, eVchEmailQueue."e-mail", eVchEmailQueue."Created by Receipt No.", SendResult) THEN BEGIN
                    eVchEmailQueue2.GET(eVchEmailQueue."Entry Type", eVchEmailQueue."Entry Code");
                    eVchEmailQueue2."Date Sent" := TODAY;
                    eVchEmailQueue2."Time Sent" := TIME;
                    eVchEmailQueue2."Mail Sent" := TRUE;
                    eVchEmailQueue2.MODIFY;
                END ELSE BEGIN
                    eVchEmailQueue2."Last Message Text" := COPYSTR(SendResult, 1, MAXSTRLEN(eVchEmailQueue2."Last Message Text"));
                    eVchEmailQueue2.MODIFY;
                END;
            UNTIL eVchEmailQueue.NEXT = 0;
        END;
    end;

    local procedure ReadTemplate()
    var
        eVchHdr: Record "eVch_eVoucher Header_NT";
        iStream: InStream;
        iLine: Text;
    begin
        eVoucherHeader.Get(eVchEmailQueue."Created by Receipt No.");
        if eVoucherHeader."Template File Name" <> '' then begin
            eVoucherHeader.CalcFields(Template);
            if eVoucherHeader.Template.HasValue then begin
                eVoucherHeader.Template.CreateInStream(iStream, TextEncoding::UTF8);
                while not iStream.EOS do begin
                    ArrayLength += 1;
                    iStream.READTEXT(iLine);
                    TextArray[ArrayLength] := iLine;
                end;
                exit;
            end;
        end;
        if GenSetup.Get() then;
        GenSetup.CalcFields("eVoucher Template");
        if GenSetup."eVoucher Template".HasValue then begin
            GenSetup."eVoucher Template".CreateInStream(iStream, TextEncoding::UTF8);
            while not iStream.EOS do begin
                ArrayLength += 1;
                iStream.ReadText(iLine);
                TextArray[ArrayLength] := iLine;
            end;
        end;
    end;

    procedure SendEmail(BarcodeNo: Code[20]; Date: Date; Amt: Decimal; eMail: Text; DocNo: Text; VAR SendResult: Text): Boolean
    var
        iStream2: InStream;
        i: Integer;
        iLine: Text;
        BarcodeFormat: DotNet ZXingBarcodeFormat_NT;
        BarcodeWriter: DotNet ZXingBarcodeWriter_NT;
        Bitmap: DotNet Bitmap;
        BitMatrix: DotNet ZXingCommonBitMatrix_NT;
        BodyText: DotNet String;
        ByteArray: DotNet Array;
        Convert: DotNet Convert;
        EncodingOption: DotNet ZXingCommonEncodingOptions_NT;
        ImageFormat: DotNet ImageFormat;
        ImageString: DotNet String;
        Stream: DotNet MemoryStream;
        String: DotNet String;
    begin
        Clear(BodyText);
        if (eMail = '') then
            exit;

        EncodingOption := EncodingOption.EncodingOptions();
        EncodingOption.Height := 100;
        EncodingOption.Width := 100;

        BarcodeWriter := BarcodeWriter.BarcodeWriter();
        BarcodeWriter.Format := BarcodeFormat.QR_CODE;
        BarcodeWriter.Options := EncodingOption;
        BitMatrix := BarcodeWriter.Encode(BarcodeNo);
        Bitmap := BarcodeWriter.Write(BitMatrix);
        Stream := Stream.MemoryStream();
        Bitmap.Save(Stream, ImageFormat.Png);
        ByteArray := Stream.GetBuffer();
        ImageString := Convert.ToBase64String(ByteArray);

        for i := 1 to ArrayLength do begin
            String := TextArray[i];
            if not String.IsNullOrWhiteSpace(String) then begin
                String := String.Replace('*|DATE:d/m/y|*', FORMAT(TODAY, 0, '<Day,2>/<Month,2>/<Year4>'));
                String := String.Replace('*|QR-CODE|*', STRSUBSTNO('<img src="data:image/png;base64,%1">', ImageString));
                String := String.Replace('*|AMOUNT|*', FORMAT(Amt));
                String := String.Replace('*|INVOICE|*', DocNo);
                String := String.Replace('*|UNIQUE-CODE|*', BarcodeNo);
                BodyText := BodyText + String;
            end;
        end;
        SendResult := SendEmail(eMail, BodyText);
        exit(SendResult = '');
    end;

    procedure SendEmail(Email: Text; Body: Text): Text
    var
        EmailMsg: Codeunit "Email Message";
        EmailSend: Codeunit Email;
        ResultOk: Boolean;
    begin
        EmailMsg.Create(Email, 'Voucher', '', true);
        EmailMsg.AppendToBody(Body);
        ResultOk := EmailSend.Send(EmailMsg, Enum::"Email Scenario"::Default);
        if not ResultOk then
            exit(GetLastErrorText())
        else
            exit('');
    end;

    procedure ResendEmail(var Rec: Record "eVch_eVoucher Email Queue_NT")
    var
        LSInput: Page "LSC Retail Input Dialog";
        EmailCC: Text;
        Dummy: Text;
        SendResult: Text;
        eVchHeader: Record "eVch_eVoucher Header_NT";
    begin
        eVchEmailQueue :=  Rec;
        if not TemplateRead then begin
            ReadTemplate();
            TemplateRead := TRUE;
        end;
        eVchHeader.Get(Rec."Created by Receipt No.");
        eVchHeader.TestField(Status, eVchHeader.Status::Posted);
        Rec.TestField("e-mail");
        Rec.TestField("Mail Sent");
        LSInput.SetValues('', '', 'Add CC:', '');
        LSInput.RunModal();
        LSInput.ReturnValues(EmailCC, Dummy);
        if EmailCC = '' then
            EmailCC := Rec."e-mail";

        if not SendEmail(Rec."Entry Code", Rec."Date Created", Rec.Amount, EmailCC, Rec."Created by Receipt No.", SendResult) then
            Message(SendResult)
        else begin
            Rec."Mail Resent" := true;
            Rec."Resent e-mail" := EmailCC;
            Rec."Date Resent" := Today;
            Rec."Resent By" := UserId;
            Rec.Modify();
            Message('Mail send successfully');
        end;

    end;

    var
        eVchEmailQueue2: Record "eVch_eVoucher Email Queue_NT";
        eVchEmailQueue: Record "eVch_eVoucher Email Queue_NT";
        eVoucherHeader: Record "eVch_eVoucher Header_NT";
        eVoucherLine: Record "eVch_eVoucher Line_NT";
        GenSetup: Record "eCom_General Setup_NT";
        ArrayLength: Integer;
        TextArray: array[1000] of Text;
        TemplateRead: Boolean;

}