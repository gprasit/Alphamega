codeunit 60402 "eVch_eVoucher Management_NT"
{
    TableNo = "eVch_eVoucher Header_NT";
    trigger OnRun()
    begin
        eVoucherHeader := Rec;
        Code;
        Rec := eVoucherHeader;

    end;

    local procedure Code()
    begin
        eVoucherHeader.TESTFIELD(Status, eVoucherHeader.Status::Released);
        IF eVoucherHeader."Creation Nos." = eVoucherHeader."Creation Nos."::"Number Series" THEN
            eVoucherHeader.TESTFIELD("Creation No. Series");

        IF eVoucherHeader."Creation Nos." = eVoucherHeader."Creation Nos."::Random THEN
            RANDOMIZE;

        eVoucherLine.SETRANGE("Document No.", eVoucherHeader."No.");
        eVoucherLine.FINDFIRST;
        REPEAT
            eVoucherLine.TESTFIELD(Quantity);
            eVoucherLine.TESTFIELD("Amount Code");
            eVoucherLine.TESTFIELD(Amount);
            CreateEntries();
            eVoucherLine.Status := eVoucherLine.Status::Posted;
            eVoucherLine.MODIFY;
        UNTIL eVoucherLine.NEXT = 0;
        eVoucherHeader.Status := eVoucherHeader.Status::Posted;
        eVoucherHeader.MODIFY;
        COMMIT;

    end;

    local procedure CreateEntries()
    var
        DataEntry: Record "LSC POS Data Entry";
        DataEntryExt: Record "eVch_POS Data Entry Ext_NT";
        DataEntryType: Record "LSC POS Data Entry Type";
        VoucherEntries: Record "LSC Voucher Entries";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DataEntryCode: Code[20];
        i: Integer;
        VchLineNo: Integer;
    begin
        DataEntryType.Get(eVoucherHeader."Data Entry Type");//06.04.2023
        VchLineNo := 10000;//06.04.2023
        for i := 1 to eVoucherLine.Quantity do begin
            if eVoucherHeader."Creation Nos." = eVoucherHeader."Creation Nos."::Random then
                repeat
                    DataEntryCode := FORMAT(RANDOM(999999), 0, '<Integer>');
                    if StrLen(DataEntryCode) < 6 then
                        repeat
                            DataEntryCode := '0' + DataEntryCode;
                        until StrLen(DataEntryCode) = 6;
                    DataEntryCode := eVoucherHeader.Prefix + DataEntryCode;
                until not DataEntry.Get(eVoucherHeader."Data Entry Type", DataEntryCode)
            else
                DataEntryCode := eVoucherHeader.Prefix + NoSeriesManagement.GetNextNo3(eVoucherHeader."Creation No. Series", TODAY, true, true);
            Clear(DataEntry);
            DataEntry."Entry Type" := eVoucherHeader."Data Entry Type";
            DataEntry."Entry Code" := DataEntryCode;
            DataEntry."Created by Receipt No." := eVoucherHeader."No.";
            DataEntry."Created in Store No." := 'HO';
            DataEntry.Amount := eVoucherLine.Amount;
            DataEntry."Date Created" := Today;
            DataEntry."e-mail" := eVoucherLine."e-Mail";
            DataEntry."Invoice No." := eVoucherHeader."Invoice No.";
            DataEntry.Beneficiary := USERID;
            DataEntry.Insert();
            CLEAR(DataEntryExt);
            DataEntryExt."Entry Type" := DataEntry."Entry Type";
            DataEntryExt."Entry Code" := DataEntry."Entry Code";
            DataEntryExt."Created By" := USERID;
            DataEntryExt."Document No." := eVoucherHeader."No.";
            DataEntryExt."Document Line No." := eVoucherLine."Line No.";
            DataEntryExt.INSERT;
            //SendEmail(DataEntry."Entry Code",DataEntry."Date Created",DataEntry.Amount,eVoucherLine."e-Mail"); //NT20.02.2023
            // 06.04.2023 -  
            if DataEntryType."Create Voucher Entry" then begin
                VoucherEntries.Init();
                VoucherEntries."Voucher Type" := DataEntry."Entry Type";
                VoucherEntries."Voucher No." := DataEntryCode;
                VoucherEntries."Store No." := DataEntry."Created in Store No.";
                VoucherEntries."Line No." := VchLineNo;
                VchLineNo := VchLineNo + 10;
                VoucherEntries."Receipt Number" := DataEntry."Created by Receipt No.";
                VoucherEntries.Unposted := TRUE;
                VoucherEntries."Entry Type" := VoucherEntries."Entry Type"::Issued;
                VoucherEntries.Date := Today;
                VoucherEntries.Time := Time;
                VoucherEntries.Amount := DataEntry.Amount;
                VoucherEntries.Voided := false;
                VoucherEntries."Remaining Amount Now" := DataEntry.Amount;
                VoucherEntries.Insert();
            END;
            // 06.04.2023 +
            SendToEmailQueue(DataEntry);//NT20.02.2023
        END;
    end;

    local procedure SendToEmailQueue(DataEntry: Record "LSC POS Data Entry")
    var
        eVchEmailQueue: Record "eVch_eVoucher Email Queue_NT";
    begin
        eVchEmailQueue.Init();
        eVchEmailQueue."Entry Type" := DataEntry."Entry Type";
        eVchEmailQueue."Entry Code" := DataEntry."Entry Code";
        eVchEmailQueue.Amount := DataEntry.Amount;
        eVchEmailQueue."Created by Receipt No." := DataEntry."Created by Receipt No.";
        eVchEmailQueue."Date Created" := DataEntry."Date Created";
        eVchEmailQueue."Created in Store No." := DataEntry."Created in Store No.";
        eVchEmailQueue."Invoice No." := DataEntry."Invoice No.";
        eVchEmailQueue."e-mail" := DataEntry."e-mail";
        eVchEmailQueue.Insert();
    end;

    procedure ImportTemplateToGeneralSetup(Import: Boolean)
    var
        GenSetup: Record "eCom_General Setup_NT";
        iStream: InStream;
        oStream: OutStream;
        iLine: Text;
        TempFileName: Text[250];
        Env: DotNet Environment;
    begin
        if not GenSetup.Get() then exit;

        if Import then begin
            Clear(GenSetup."eVoucher Template");
            UploadIntoStream('Import File', '', 'html files (*.html)|*.html|All files (*.*)|*.*', TempFileName, iStream);
            if TempFileName <> '' then begin
                Clear(GenSetup."eVoucher Template");
                GenSetup."eVoucher Template".CreateOutStream(oStream);
                while not iStream.EOS do begin
                    iStream.ReadText(iLine);
                    oStream.WriteText(iLine + Env.NewLine);
                end;
                GenSetup.Modify();
            end;
        end else begin
            TempFileName := 'Template.htm';
            GenSetup.CalcFields(GenSetup."eVoucher Template");
            if GenSetup."eVoucher Template".HasValue then begin
                GenSetup."eVoucher Template".CreateInStream(iStream);
                DownloadFromStream(iStream, 'Save Template', '', '', TempFileName);
            end;
        end;
    end;

    procedure DeleteTemplateGeneralSetup()
    var
        GenSetup: Record "eCom_General Setup_NT";
    begin
        if not GenSetup.Get() then exit;
        GenSetup.CalcFields(GenSetup."eVoucher Template");
        if GenSetup."eVoucher Template".HasValue then begin
            Clear(GenSetup."eVoucher Template");
            GenSetup.Modify();
        end;
    end;

    procedure OnBeforeReleaseeVoucher(eVchHdr: Record "eVch_eVoucher Header_NT")
    var
        eVchLine: Record "eVch_eVoucher Line_NT";
        MailManagement: Codeunit "Mail Management";
    begin
        eVchLine.SetRange("Document No.", eVchHdr."No.");
        if eVchLine.IsEmpty then
            Error(Text001);
        if eVchLine.FINDSET then
            repeat
                eVchLine.TestField("e-Mail");
                MailManagement.CheckValidEmailAddresses(eVchLine."e-Mail");
            until eVchLine.Next() = 0;
    end;

    procedure eVoucherOnRelease(var eVoucher: Record "eVch_eVoucher Header_NT")
    var
    begin
        eVoucher.CalcFields("Line Total Amount");
        eVoucher.TestField("Total Amount", eVoucher."Line Total Amount");
        eVoucher.TestField("Invoice No.");
        OnBeforeReleaseeVoucher(eVoucher);
        eVoucherHeader := eVoucher;
        eVoucherHeader.TestField(Status, eVoucherHeader.Status::Open);
        eVoucherHeader.Status := eVoucherHeader.Status::Released;
        eVoucherHeader.Modify();
    end;

    procedure eVoucherOnReopen(var eVoucher: Record "eVch_eVoucher Header_NT")
    var
    begin
        eVoucherHeader := eVoucher;
        eVoucherHeader.TestField(Status, eVoucherHeader.Status::Released);
        eVoucherHeader.Status := eVoucherHeader.Status::Open;
        eVoucherHeader.Modify();
    end;

    procedure CancelEntries(DocNo: Code[20]; DocLineNo: Integer)
    var
        DataEntry: Record "LSC POS Data Entry";
        DataEntryExt: Record "eVch_POS Data Entry Ext_NT";
        Counter: Integer;
        VoucherEntries: Record "LSC Voucher Entries";
    begin
        eVoucherHeader.GET(DocNo);
        DataEntryExt.SETCURRENTKEY("Document No.", "Document Line No.");
        DataEntryExt.SETRANGE("Document No.", DocNo);
        IF DocLineNo <> 0 THEN
            DataEntryExt.SETRANGE("Document Line No.", DocLineNo)
        ELSE
            eVoucherHeader.TESTFIELD(Status, eVoucherHeader.Status::Posted);
        IF DataEntryExt.FINDSET THEN
            REPEAT
                eVoucherLine.GET(DataEntryExt."Document No.", DataEntryExt."Document Line No.");
                IF eVoucherLine.Status = eVoucherLine.Status::Posted THEN
                    IF DataEntry.GET(DataEntryExt."Entry Type", DataEntryExt."Entry Code") THEN BEGIN
                        DataEntry.Applied := TRUE;
                        DataEntry."Applied by Receipt No." := 'CANCELLED';
                        DataEntry."Date Applied" := Today;
                        DataEntry.Modify();
                        VoucherEntries.Reset();
                        VoucherEntries.SetFilter("Voucher No.", DataEntry."Entry Code");
                        if not VoucherEntries.IsEmpty then
                            VoucherEntries.ModifyAll(Voided, true);
                        Counter += 1;
                        eVoucherLine.Status := eVoucherLine.Status::Canclelled;
                        eVoucherLine.MODIFY;
                    END;
            until DataEntryExt.Next() = 0;
        IF DocLineNo = 0 THEN BEGIN
            eVoucherHeader.Status := eVoucherHeader.Status::Cancelled;
            eVoucherHeader.MODIFY;
        END;
        MESSAGE('%1 entries cancelled.', Counter);
    end;

    procedure CancelDataEntry(DataEntry: Record "LSC POS Data Entry")
    var
        PosDataEntry: Record "LSC POS Data Entry";
        VoucherEntries: Record "LSC Voucher Entries";
    begin
        if not Confirm('Cancel Entry?') then
            exit;
        POSDataEntry.Get(DataEntry."Entry Type", DataEntry."Entry Code");
        POSDataEntry.Applied := TRUE;
        POSDataEntry."Applied by Receipt No." := 'CANCELLED';
        POSDataEntry."Date Applied" := Today;
        POSDataEntry.Modify();
        VoucherEntries.SetFilter("Voucher No.", POSDataEntry."Entry Code");
        if not VoucherEntries.IsEmpty then
            VoucherEntries.ModifyAll(Voided, true);
    end;

    var
        eVoucherHeader: Record "eVch_eVoucher Header_NT";
        eVoucherLine: Record "eVch_eVoucher Line_NT";
        ArrayLength: Integer;
        TextArray: array[1000] of Text;
        Text001: Label 'Nothing to release.';

}