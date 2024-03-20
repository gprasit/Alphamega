page 60102 "eCom_Web Service Test_NT"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'AlphaMega Web Service Test';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(InputParam; InParam)
                {
                    ApplicationArea = All;
                    Caption = 'Input';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestODATA)
            {
                ApplicationArea = All;
                Image = TestFile;
                trigger OnAction()
                var
                    ecomWebReq: Codeunit "eCom_Web Request Mgmt_NT";
                begin
                    ecomWebReq.SendODATARequest(InParam);
                end;
            }
            action(TestKiosk)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    xx: Text;
                    xx2: Text;
                    ostream: OutStream;
                    TxtBuilder: TextBuilder;
                    instr: instream;
                    tempblob: Codeunit "Temp Blob";
                    xmlmgt: Codeunit "XML DOM Management";
                    FileName: Text;
                    ss: Codeunit "eCom_Web Request Mgmt_NT";
                    CU: Codeunit "Kiosk Management_NT";
                    dd: TextBuilder;
                    MyFile: File;
                begin
                    // Clear(tempBlob);
                    // FileName := 'SalesOrder';
                    // tempBlob.CreateOutStream(oStream, TEXTENCODING::UTF8);
                    // tempblob.CreateInStream(Instr);
                    // UploadIntoStream('Window Title', 'C:\Nextech\eCommerce', '', FileName, Instr);
                    // while not instr.EOS do begin
                    //     instr.Read(xx);
                    //     TxtBuilder.Append(xx);
                    // end;
                    //ss.CreateSalesOrder(xx, xx2);
                    CU.Run();
                end;
            }
            action(TestString)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    MyInt: Integer;
                begin


                end;
            }

            action(TestSalesAdvice)
            {
                ApplicationArea = All;
                Caption = 'Test STICK & WIN';
                trigger OnAction()
                var
                    Transaction: Record "LSC Transaction Header";
                    TransContinuityEntry: Record "eCom_Trans. Contin. Entry_NT";
                    ContMgt: Codeunit "eCom_Continuity Mgt_NT";
                begin
                    Transaction.Get('9999', 'P9999', 23);
                    ContMgt.SalesAdvice(Transaction, TransContinuityEntry);
                end;
            }
            action(ConvertRetailImage)
            {
                ApplicationArea = All;
                Caption = 'Convert Image';

                trigger OnAction()
                var
                    RetailImage: Record "LSC Retail Image";
                    InStr: InStream;
                begin
                    RetailImage.SetAutoCalcFields("Image Blob");
                    //RetailImage.SetFilter(Code, '0108-3109 B2S 02');
                    if RetailImage.FindSet() then
                        repeat
                            Clear(InStr);
                            if RetailImage."Image Blob".HasValue then begin
                                RetailImage."Image Blob".CreateInStream(InStr);
                                RetailImage."Image Mediaset".ImportStream(InStr, Format(RetailImage.Code), 'image/bmp');
                                Clear(RetailImage."Image Blob");
                                RetailImage.Modify();
                            end;
                        until RetailImage.Next() = 0;
                    //message('%1', RetailImage."Image Mediaset".Count);
                end;
            }
            action(UpdatePUOffer)
            {
                ApplicationArea = All;
                Caption = 'Update Published Offers Image Link';

                trigger OnAction()
                var
                    RetailImageLink: Record "LSC Retail Image Link";
                    RetailImageLink2: Record "LSC Retail Image Link";
                    PubOffer: Record "LSC Published Offer";
                begin
                    //PubOffer.SetFilter("No.", 'PUB15192');
                    if PubOffer.FindSet() then
                        repeat
                            RetailImageLink.SetFilter(KeyValue, PubOffer."No.");
                            RetailImageLink.SetFilter(TableName, '%1', PubOffer.TableName);
                            RetailImageLink.DeleteAll(true);//FOR Existing Images. Build Linke from Replicated images

                            RetailImageLink.Reset();
                            RetailImageLink.SetFilter(KeyValue, PubOffer."No.");
                            if RetailImageLink.FindSet() then
                                repeat
                                    RetailImageLink2.Init();
                                    RetailImageLink2.TransferFields(RetailImageLink);
                                    RetailImageLink2."Record Id" := format(PubOffer.RecordId);
                                    RetailImageLink2.TableName := PubOffer.TableName;
                                    RetailImageLink2.Insert(true);
                                    RetailImageLink.Delete(true);
                                until RetailImageLink.Next() = 0;
                        until PubOffer.Next() = 0;

                end;
            }
            action(MemberAttr)
            {
                ApplicationArea = All;
                
                trigger OnAction()
                var
                AttributeMgt: Codeunit "LSC Member Attribute Mgmt";
                MemberAttributeListTemp: Record "LSC Member Attribute List" temporary;
                begin
                    AttributeMgt.GetAllAttributes('MCB0000001', MemberAttributeListTemp);
                    MemberAttributeListTemp.FindSet();
                    repeat
                    Message('%1',MemberAttributeListTemp);
                    until MemberAttributeListTemp.Next()=0;               
                end;
            }
        }

    }

    var
        InParam: Code[20];
}