page 60033 "Signature Pad_NT"
{
    Caption = 'Signature Pad';
    PageType = Card;
    layout
    {
        area(content)
        {
            group(DisplayDoc)
            {
                Caption = 'Preview';
                usercontrol(PDFViewer; "PDF Viewer")
                {
                    ApplicationArea = All;

                    trigger ControlAddinReady()
                    begin
                        SetPDFDocument(TreaJnlLine);
                    end;
                }
            }
            group("Signature Pad")
            {
                usercontrol("Signature Pad_NT"; "SGN SGNSignaturePad")
                {
                    ApplicationArea = All;
                    Visible = true;
                    trigger Ready()
                    begin
                        CurrPage."Signature Pad_NT".InitializeSignaturePad();
                    end;

                    trigger Sign(Signature: Text)
                    var
                        TreasGenFn: Codeunit "Treasury General Functions_NT";
                    begin
                        //TreasGenFn.SignDocument(Signature, Rec);
                        // Rec.SignDocument(Signature);
                        // CurrPage.Update(false);
                    end;
                }
                // field("SGN Signature"; Rec."SGN Signature")
                // {
                //     Caption = 'Signature';
                //     ApplicationArea = All;
                //     Editable = false;
                // }
            }

        }
    }

    local procedure SetPDFDocument(TreaJnlLine: Record "Treasury Journal Line_NT")
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStreamVar: InStream;
        OutStreamVar: OutStream;
        PDFAsTxt: Text;
        DocAttachment: Record "Document Attachment";
    begin
        //CurrPage.PDFViewer.SetVisible(Rec."Document Reference ID".HasValue());
        SetFilterDocAttachment(TreaJnlLine, DocAttachment);
        if DocAttachment.IsEmpty() then
            Error('No attachment found.');
        DocAttachment.FindFirst();
        if not DocAttachment."Document Reference ID".HasValue() then
            exit;

        TempBlob.CreateInStream(InStreamVar);
        TempBlob.CreateOutStream(OutStreamVar);
        DocAttachment."Document Reference ID".ExportStream(OutStreamVar);

        PDFAsTxt := Base64Convert.ToBase64(InStreamVar);

        CurrPage.PDFViewer.LoadPDF(PDFAsTxt, false);
    end;

    local procedure SetFilterDocAttachment(TreaJnlLine: Record "Treasury Journal Line_NT"; var DocAttachment: Record "Document Attachment")
    var
    begin
        DocAttachment.SetRange("Table ID", Database::"Treasury Journal Line_NT");
        DocAttachment.SetFilter("No.", TreaJnlLine."Journal Batch Name");
        DocAttachment.SetFilter("Document Type", '%1', DocAttachment."Document Type"::TREASURY);
        DocAttachment.SetFilter("Line No.", '%1', TreaJnlLine."Line No.");
    end;

    procedure SetLine(TreaJnlLineIn: Record "Treasury Journal Line_NT")
    var

    begin
        TreaJnlLine := TreaJnlLineIn;
    end;

    var
        TreaJnlLine: Record "Treasury Journal Line_NT";
}
