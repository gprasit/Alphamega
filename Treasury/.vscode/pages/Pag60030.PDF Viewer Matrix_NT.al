page 60030 "PDF Viewer Matrix_NT"
{

    Caption = 'PDF Documents';
    PageType = CardPart;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    RefreshOnActivate = true;
    SourceTable = "Treasury Journal Line_NT";

    layout
    {
        area(content)
        {
            group(Group1)
            {
                ShowCaption = false;
                Visible = VisibleControl;
                usercontrol(PDFViewer; "PDF Viewer")
                {
                    ApplicationArea = All;
                    trigger ControlAddinReady()
                    begin
                        IsControlAddInReady := true;
                        SetRecord(Rec);
                    end;

                    trigger onView()
                    begin
                        RunFullView(Rec);
                    end;
                }
            }
        }
    }

    local procedure GetPDFAsTxt(DocAttachment: Record "Document Attachment"): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStreamVar: InStream;
        OutStreamVar: OutStream;
        PDFAsTxt: Text;
    begin
        if not DocAttachment."Document Reference ID".HasValue() then
            exit('');

        TempBlob.CreateInStream(InStreamVar);
        TempBlob.CreateOutStream(OutStreamVar);
        DocAttachment."Document Reference ID".ExportStream(OutStreamVar);
        PDFAsTxt := Base64Convert.ToBase64(InStreamVar);
        exit(PDFAsTxt);
    end;

    local procedure SetPDFDocument(PDFAsTxt: Text);
    var
        IsVisible: Boolean;
    begin
        IsVisible := PDFAsTxt <> '';
        VisibleControl := IsVisible;
        if not IsVisible or not IsControlAddInReady then
            exit;
        CurrPage.PDFViewer.SetVisible(IsVisible);
        CurrPage.PDFViewer.LoadPDF(PDFAsTxt, true);
        CurrPage.Update(false);
    end;

    procedure SetRecord(TreaJnlLine: Record "Treasury Journal Line_NT")
    var
        DocAttachment: Record "Document Attachment";
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStreamVar: InStream;
        OutStreamVar: OutStream;
        PDFAsTxt: Text;
    begin
        Clear(VisibleControl);
        SetFilterDocAttachment(TreaJnlLine, DocAttachment);
        if DocAttachment.IsEmpty() then
            exit;
        DocAttachment.FindFirst();
        SetPDFDocument(GetPDFAsTxt(DocAttachment));
    end;


    local procedure RunFullView(TreaJnlLine: Record "Treasury Journal Line_NT")
    var
        PDFViewerCard: Page "PDF Viewer_NT";
        DocAttachment: Record "Document Attachment";

    begin
        SetFilterDocAttachment(TreaJnlLine, DocAttachment);
        if DocAttachment.IsEmpty() then
            exit;
        DocAttachment.FindFirst();
        PDFViewerCard.SetRecord(DocAttachment);
        PDFViewerCard.SetTableView(DocAttachment);
        PDFViewerCard.Run();
    end;

    local procedure SetFilterDocAttachment(TreaJnlLine: Record "Treasury Journal Line_NT"; var DocAttachment: Record "Document Attachment")
    var
    begin
        DocAttachment.SetRange("Table ID", Database::"Treasury Journal Line_NT");
        DocAttachment.SetFilter("No.", TreaJnlLine."Journal Batch Name");
        DocAttachment.SetFilter("Document Type", '%1', DocAttachment."Document Type"::TREASURY);
        DocAttachment.SetFilter("Line No.", '%1', TreaJnlLine."Line No.");
    end;

    var
        [InDataSet]
        VisibleControl: Boolean;
        [InDataSet]
        IsControlAddInReady: Boolean;
}
