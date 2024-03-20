codeunit 60003 TreasuryAttchmentMgmt_NT
{


    procedure IsDuplicateFile(TableID: Integer; TemplateName: Code[20]; BatchName: Code[20]; RecLineNo: Integer; FileName: Text; FileExtension: Text): Boolean
    var
        JnlDocAttachment: Record "Journal Document Attachment_NT";
    begin
        JnlDocAttachment.SetRange("Table ID", TableID);
        JnlDocAttachment.SetRange("Journal Template Name", TemplateName);
        JnlDocAttachment.SetRange("Journal Batch Name", BatchName);
        JnlDocAttachment.SetRange("Line No.", RecLineNo);
        JnlDocAttachment.SetRange("File Name", FileName);
        JnlDocAttachment.SetRange("File Extension", FileExtension);
        if not JnlDocAttachment.IsEmpty() then
            exit(true);

        exit(false);
    end;

    local procedure DocAttachForPostedSalesDocs()
    var
        xx: Codeunit "Document Attachment Mgmt";
        myInt: Integer;
    begin

    end;

    procedure CopyAttachmentsForPostedJrnls(var FromRecRef: RecordRef; var ToRecRef: RecordRef)
    var
        FromDocumentAttachment: Record "Document Attachment";
        ToDocumentAttachment: Record "Document Attachment";
        FromFieldRef: FieldRef;
        ToFieldRef: FieldRef;
        FromNo: Code[20];
        FromLineNo: Integer;
        ToLineNo: Integer;
    begin
        case FromRecRef.Number of
            DATABASE::"Treasury Journal Line_NT":
                begin
                    FromDocumentAttachment.SetRange("Table ID", FromRecRef.Number);
                    FromDocumentAttachment.SetRange("Document Type", FromDocumentAttachment."Document Type"::Treasury);
                    //field 5 - No. = Journal Batch Name
                    FromFieldRef := FromRecRef.Field(5);
                    FromNo := FromFieldRef.Value();
                    FromDocumentAttachment.SetRange("No.", FromNo);
                    //field 20 - Line No. = Line No.
                    FromFieldRef := FromRecRef.Field(20);
                    FromLineNo := FromFieldRef.Value();
                    FromDocumentAttachment.SetRange("Line No.", FromLineNo);
                    if FromDocumentAttachment.FindSet() then begin
                        repeat
                            Clear(ToDocumentAttachment);
                            ToDocumentAttachment.Init();
                            ToDocumentAttachment.TransferFields(FromDocumentAttachment);
                            ToDocumentAttachment.Validate("Table ID", ToRecRef.Number);

                            ToFieldRef := ToRecRef.Field(20);
                            ToLineNo := ToFieldRef.Value();
                            ToDocumentAttachment."Line No." := ToLineNo;
                            ToDocumentAttachment.Insert(true);
                            FromDocumentAttachment.Delete();
                        until FromDocumentAttachment.Next() = 0;
                    end;
                end;
        end;
    end;
}