table 60020 "Journal Document Attachment_NT"
{
    Caption = 'Document Attachment';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            Editable = false;
        }
        field(5; "Journal Batch Name"; Code[20])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Treasury Journal Batch_NT".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(15; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }

        field(20; "Attached Date"; DateTime)
        {
            Caption = 'Attached Date';
        }
        field(25; "File Name"; Text[250])
        {
            Caption = 'Attachment';
            NotBlank = true;

            trigger OnValidate()
            var
                JnlDocAttachmentMgmt: Codeunit TreasuryAttchmentMgmt_NT;
            begin
                if "File Name" = '' then
                    Error(EmptyFileNameErr);

                if JnlDocAttachmentMgmt.IsDuplicateFile(
                    "Table ID", "Journal Template Name", "Journal Batch Name", "Line No.", "File Name", "File Extension")
                then
                    Error(DuplicateErr);
            end;
        }
        field(30; "File Type"; Enum "Document Attachment File Type")
        {
            Caption = 'File Type';
        }
        field(35; "File Extension"; Text[30])
        {
            Caption = 'File Extension';

            trigger OnValidate()
            begin
                case LowerCase("File Extension") of
                    'jpg', 'jpeg', 'bmp', 'png', 'tiff', 'tif', 'gif':
                        "File Type" := "File Type"::Image;
                    'pdf':
                        "File Type" := "File Type"::PDF;
                    'docx', 'doc':
                        "File Type" := "File Type"::Word;
                    'xlsx', 'xls':
                        "File Type" := "File Type"::Excel;
                    'pptx', 'ppt':
                        "File Type" := "File Type"::PowerPoint;
                    'msg':
                        "File Type" := "File Type"::Email;
                    'xml':
                        "File Type" := "File Type"::XML;
                    else
                        "File Type" := "File Type"::Other;
                end;
            end;
        }
        field(40; "Document Reference ID"; Media)
        {
            Caption = 'Document Reference ID';
        }
        field(45; "Attached By"; Guid)
        {
            Caption = 'Attached By';
            Editable = false;
            TableRelation = User."User Security ID" WHERE("License Type" = CONST("Full User"));
        }
        field(50; User; Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE("User Security ID" = FIELD("Attached By"),
                                                         "License Type" = CONST("Full User")));
            Caption = 'User';
            Editable = false;
            FieldClass = FlowField;
        }


    }

    keys
    {
        key(Key1; "Table ID", "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }

    // fieldgroups
    // {
    //     fieldgroup(Brick; "Table ID", "File Name", "File Extension", "File Type")
    //     {
    //     }
    // }

    trigger OnInsert()
    begin
        if IncomingFileName <> '' then begin
            Validate("File Extension", FileManagement.GetExtension(IncomingFileName));
            Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen("File Name")));
        end;

        if not "Document Reference ID".HasValue then
            Error(NoDocumentAttachedErr);

        Validate("Attached Date", CurrentDateTime);
        if IsNullGuid("Attached By") then
            "Attached By" := UserSecurityId;
    end;

    var
        NoDocumentAttachedErr: Label 'Please attach a document first.';
        EmptyFileNameErr: Label 'Please choose a file to attach.';
        NoContentErr: Label 'The selected file has no content. Please choose another file.';
        FileManagement: Codeunit "File Management";
        IncomingFileName: Text;
        DuplicateErr: Label 'This file is already attached to the document. Please choose another file.';

    //[Scope('OnPrem')]
    procedure Export(ShowFileDialog: Boolean): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DocumentStream: OutStream;
        FullFileName: Text;
    begin
        //if ID = 0 then
        if "Table ID" = 0 then
            exit;
        // Ensure document has value in DB
        if not "Document Reference ID".HasValue then
            exit;

        OnBeforeExportAttachment(Rec);
        FullFileName := "File Name" + '.' + "File Extension";
        TempBlob.CreateOutStream(DocumentStream);
        "Document Reference ID".ExportStream(DocumentStream);
        exit(FileManagement.BLOBExport(TempBlob, FullFileName, ShowFileDialog));
    end;

    // procedure HasPostedDocumentAttachment("Record": Variant): Boolean
    // var
    //     RecRef: RecordRef;
    //     FieldRef: FieldRef;
    //     RecNo: Code[20];
    // begin
    //     RecRef.GetTable(Record);
    //     SetRange("Table ID", RecRef.Number);
    //     case RecRef.Number of
    //         DATABASE::"Sales Invoice Header",
    //         DATABASE::"Sales Cr.Memo Header",
    //         DATABASE::"Purch. Inv. Header",
    //         DATABASE::"Purch. Cr. Memo Hdr.":
    //             begin
    //                 FieldRef := RecRef.Field(3);
    //                 RecNo := FieldRef.Value;
    //                 SetRange("No.", RecNo);
    //                 exit(not IsEmpty);
    //             end;
    //     end;

    //     exit(false);
    // end;

    //[Scope('OnPrem')]
    procedure SaveAttachment(RecRef: RecordRef; FileName: Text; TempBlob: Codeunit "Temp Blob")
    var
        DocStream: InStream;
    begin
        OnBeforeSaveAttachment(Rec, RecRef, FileName, TempBlob);

        if FileName = '' then
            Error(EmptyFileNameErr);
        // Validate file/media is not empty
        if not TempBlob.HasValue then
            Error(NoContentErr);

        TempBlob.CreateInStream(DocStream);
        InsertAttachment(DocStream, RecRef, FileName);
    end;

    procedure SaveAttachmentFromStream(DocStream: InStream; RecRef: RecordRef; FileName: Text)
    begin
        OnBeforeSaveAttachmentFromStream(Rec, RecRef, FileName, DocStream);

        if FileName = '' then
            Error(EmptyFileNameErr);

        InsertAttachment(DocStream, RecRef, FileName);
    end;

    local procedure InsertAttachment(DocStream: InStream; RecRef: RecordRef; FileName: Text)
    begin
        IncomingFileName := FileName;

        Validate("File Extension", FileManagement.GetExtension(IncomingFileName));
        Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen("File Name")));

        // IMPORTSTREAM(stream,description, mime-type,filename)
        // description and mime-type are set empty and will be automatically set by platform code from the stream
        "Document Reference ID".ImportStream(DocStream, '');
        if not "Document Reference ID".HasValue then
            Error(NoDocumentAttachedErr);

        InitFieldsFromRecRef(RecRef);

        OnBeforeInsertAttachment(Rec, RecRef);
        Insert(true);
    end;

    procedure InitFieldsFromRecRef(RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        LineNo: Integer;
    begin
        Validate("Table ID", RecRef.Number);

        case RecRef.Number of
            DATABASE::"Treasury Journal Line_NT":
                begin
                    FieldRef := RecRef.Field(1);
                    "Journal Template Name" := FieldRef.Value;
                    FieldRef := RecRef.Field(5);
                    "Journal Batch Name" := FieldRef.Value;
                    FieldRef := RecRef.Field(20);
                    "Line No." := FieldRef.Value;
                end;
        end;
    end;

    procedure FindUniqueFileName(FileName: Text; FileExtension: Text): Text[250]
    var
        DocumentAttachmentMgmt: Codeunit TreasuryAttchmentMgmt_NT;
        FileIndex: Integer;
        SourceFileName: Text[250];
    begin
        SourceFileName := CopyStr(FileName, 1, MaxStrLen(SourceFileName));
        while DocumentAttachmentMgmt.IsDuplicateFile("Table ID", "Journal Template Name", "Journal Batch Name", "Line No.", FileName, FileExtension) do begin
            FileIndex += 1;
            FileName := GetNextFileName(SourceFileName, FileIndex);
        end;
        exit(CopyStr(StrSubstNo('%1.%2', FileName, FileExtension), 1, MaxStrLen(SourceFileName)));
    end;

    // procedure VATReturnSubmissionAttachmentsExist(VATReportHeader: Record "VAT Report Header"): Boolean
    // var
    //     DocType: Enum "Attachment Document Type";
    // begin
    //     exit(VATReturnAttachmentsExist(VATReportHeader, DocType::"VAT Return Submission"));
    // end;

    // procedure VATReturnResponseAttachmentsExist(VATReportHeader: Record "VAT Report Header"): Boolean
    // var
    //     DocType: Enum "Attachment Document Type";
    // begin
    //     exit(VATReturnAttachmentsExist(VATReportHeader, DocType::"VAT Return Response"));
    // end;

    // local procedure VATReturnAttachmentsExist(VATReportHeader: Record "VAT Report Header"; DocType: Enum "Attachment Document Type"): Boolean
    // begin
    //     SetRange("Table ID", Database::"VAT Report Header");
    //     SetRange("No.", VATReportHeader."No.");
    //     SetRange("Document Type", DocType);
    //     exit(not IsEmpty());
    // end;

    // procedure DownloadZipFileWithVATReturnSubmissionAttachments(VATRepConfigCode: Enum "VAT Report Configuration"; VATReportNo: Code[20]): Boolean
    // begin
    //     exit(DownloadZipFileWithVATReturnAttachments(VATRepConfigCode, VATReportNo, "Document Type"::"VAT Return Submission"));
    // end;

    // procedure DownloadZipFileWithVATReturnResponseAttachments(VATRepConfigCode: Enum "VAT Report Configuration"; VATReportNo: Code[20]): Boolean
    // begin
    //     exit(DownloadZipFileWithVATReturnAttachments(VATRepConfigCode, VATReportNo, "Document Type"::"VAT Return Response"));
    // end;

    // local procedure DownloadZipFileWithVATReturnAttachments(VATRepConfigCode: Enum "VAT Report Configuration"; VATReportNo: Code[20]; DocType: Enum "Attachment Document Type"): Boolean
    // var
    //     VATReportHeader: Record "VAT Report Header";
    //     DataCompression: Codeunit "Data Compression";
    //     TempBlob: Codeunit "Temp Blob";
    //     ZipTempBlob: Codeunit "Temp Blob";
    //     ServerFileInStream: InStream;
    //     ZipInStream: InStream;
    //     DocumentStream: OutStream;
    //     ZipOutStream: OutStream;
    //     ToFile: Text;
    // begin
    //     if not VATReportHeader.Get(VATRepConfigCode, VATReportNo) then
    //         exit(false);

    //     SetRange("Table ID", Database::"VAT Report Header");
    //     SetRange("No.", VATReportHeader."No.");
    //     SetRange("Document Type", DocType);
    //     if not FindSet() then
    //         exit(false);

    //     ToFile := VATReportHeader."No.";
    //     case "Document Type" of
    //         "Document Type"::"VAT Return Submission":
    //             ToFile += '_Submission.zip';
    //         "Document Type"::"VAT Return Response":
    //             ToFile += 'Response.zip';
    //     end;

    //     DataCompression.CreateZipArchive();
    //     repeat
    //         if "Document Reference ID".HasValue() then begin
    //             clear(TempBlob);
    //             TempBlob.CreateOutStream(DocumentStream);
    //             "Document Reference ID".ExportStream(DocumentStream);
    //             TempBlob.CreateInStream(ServerFileInStream);
    //             DataCompression.AddEntry(ServerFileInStream, "File Name" + '.' + "File Extension");
    //         end;
    //     until Next() = 0;
    //     ZipTempBlob.CreateOutStream(ZipOutStream);
    //     DataCompression.SaveZipArchive(ZipOutStream);
    //     DataCompression.CloseZipArchive();
    //     ZipTempBlob.CreateInStream(ZipInStream);
    //     DownloadFromStream(ZipInStream, '', '', '', ToFile);
    //     exit(true);
    // end;

    local procedure GetNextFileName(FileName: Text[250]; FileIndex: Integer): Text[250]
    begin
        exit(StrSubstNo('%1 (%2)', FileName, FileIndex));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportAttachment(var DocumentAttachment: Record "Journal Document Attachment_NT")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAttachment(var DocumentAttachment: Record "Journal Document Attachment_NT"; var RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSaveAttachment(var DocumentAttachment: Record "Journal Document Attachment_NT"; var RecRef: RecordRef; FileName: Text; var TempBlob: Codeunit "Temp Blob")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSaveAttachmentFromStream(var DocumentAttachment: Record "Journal Document Attachment_NT"; var RecRef: RecordRef; FileName: Text; var DocStream: InStream)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Journal Document Attachment_NT"; var RecRef: RecordRef)
    begin
    end;
}

