page 60026 "Jnl. Doc. Attachment Factbox"
{
    Caption = 'Documents Attached';
    PageType = CardPart;
    SourceTable = "Journal Document Attachment_NT";
    layout
    {
        area(content)
        {
            group(Control2)
            {
                ShowCaption = false;
                field(Documents; NumberOfRecords)
                {
                    ApplicationArea = All;
                    Caption = 'Documents';
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the number of attachments.';

                    trigger OnDrillDown()
                    var
                        Customer: Record Customer;
                        Vendor: Record Vendor;
                        Item: Record Item;
                        Employee: Record Employee;
                        FixedAsset: Record "Fixed Asset";
                        Resource: Record Resource;
                        SalesHeader: Record "Sales Header";
                        PurchaseHeader: Record "Purchase Header";
                        Job: Record Job;
                        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                        PurchInvHeader: Record "Purch. Inv. Header";
                        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
                        VATReportHeader: Record "VAT Report Header";
                        //DocumentAttachmentDetails: Page "Document Attachment Details";
                        DocumentAttachmentDetails: Page "Jrnl. Doc. Attach. Details_NT";
                        RecRef: RecordRef;
                        TreasJnlLine: Record "Treasury Journal Line_NT";
                    begin
                        case Rec."Table ID" of
                            0:
                                exit;
                            DATABASE::"Treasury Journal Line_NT":
                                begin
                                    RecRef.Open(DATABASE::"Treasury Journal Line_NT");
                                    if TreasJnlLine.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then
                                        RecRef.GetTable(TreasJnlLine);
                                end;
                        end;

                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
    end;

    trigger OnAfterGetCurrRecord()
    var
        currentFilterGroup: Integer;
    begin
        currentFilterGroup := Rec.FilterGroup;
        Rec.FilterGroup := 4;

        NumberOfRecords := 0;
        if Rec.GetFilters() <> '' then
            NumberOfRecords := Rec.Count;
        Rec.FilterGroup := currentFilterGroup;
    end;

    var
        NumberOfRecords: Integer;
}

