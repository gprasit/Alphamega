// Report 60103 "eCom_Transaction Invoice_NT"
// {
//     DefaultLayout = RDLC;
//     Caption = 'Transaction Invoice';
//     RDLCLayout = './Layouts/Transaction Invoice.rdl';
//     ApplicationArea = all;
//     UsageCategory = ReportsAndAnalysis;
//     dataset
//     {
//         dataitem("LSC Transaction Header"; "LSC Transaction Header")
//         {
//             RequestFilterFields = "Store No.", "POS Terminal No.", "Transaction No.", "Receipt No.";
//             column(ReportForNavId_1000000000; 1000000000)
//             {
//             }
//             column(Logo; CompanyInfo.Picture)
//             {
//             }
//             column(Address_1; Address[1])
//             {
//             }
//             column(Address_2; Address[2])
//             {
//             }
//             column(Address_3; Address[3])
//             {
//             }
//             column(Address_4; Address[4])
//             {
//             }
//             column(Address_5; Address[5])
//             {
//             }
//             column(Address_6; Address[6])
//             {
//             }
//             column(Address_7; Address[7])
//             {
//             }
//             column(Address_8; Address[8])
//             {
//             }
//             column(Address_9; Address[9])
//             {
//             }
//             column(CustAddress_1; CustAddress[1])
//             {
//             }
//             column(CustAddress_2; CustAddress[2])
//             {
//             }
//             column(CustAddress_3; CustAddress[3])
//             {
//             }
//             column(CustAddress_4; CustAddress[4])
//             {
//             }
//             column(CustAddress_5; CustAddress[5])
//             {
//             }
//             column(CustAddress_6; CustAddress[6])
//             {
//             }
//             column(CustAddress_7; CustAddress[7])
//             {
//             }
//             column(CustAddress_8; CustAddress[8])
//             {
//             }
//             column(InvoiceType; InvoiceType)
//             {
//             }
//             column(MemberCardNo_TransactionHeader; MemberCardNo)
//             {
//             }
//             column(NetAmount_TransactionHeader; -"LSC Transaction Header"."Net Amount")
//             {
//             }
//             column(GrossAmount_TransactionHeader; -"LSC Transaction Header"."Gross Amount")
//             {
//             }
//             column(CustomerNo_TransactionHeader; "LSC Transaction Header"."Customer No.")
//             {
//             }
//             column(Date_TransactionHeader; "LSC Transaction Header".Date)
//             {
//             }
//             column(Time_TransactionHeader; "LSC Transaction Header".Time)
//             {
//             }
//             column(TransactionNo_TransactionHeader; "LSC Transaction Header"."Transaction No.")
//             {
//             }
//             column(ReceiptNo_TransactionHeader; "LSC Transaction Header"."Receipt No.")
//             {
//             }
//             column(StoreNo_TransactionHeader; "LSC Transaction Header"."Store No.")
//             {
//             }
//             column(POSTerminalNo_TransactionHeader; "LSC Transaction Header"."POS Terminal No.")
//             {
//             }
//             column(CustomerAddress; CustomerAddress)
//             {
//             }
//             column(OrderNo; "LSC Transaction Header"."eCom Order No.")
//             {
//             }
//             column(CustomerNumber; CustomerNumber)
//             {
//             }
//             dataitem(SalesLine_Qty_Difference; "Sales Line")
//             {
//                 DataItemLink = "Document No." = field("eCom Order No.");
//                 DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const(Order));
//                 column(ReportForNavId_17; 17)
//                 {
//                 }
//                 column(OriginalQuantity_SalesLineQtyDifference; SalesLine_Qty_Difference."Original Quantity")
//                 {
//                 }
//                 column(Description_SalesLineQtyDifference; SalesLine_Qty_Difference.Description)
//                 {
//                 }
//                 column(QtyDifference; QtyDifference)
//                 {
//                 }
//                 column(WebWeight_SalesLineQtyDifference; SalesLine_Qty_Difference."Web Weight")
//                 {
//                 }
//                 column(Quantity_SalesLineQtyDifference; SalesLine_Qty_Difference.Quantity)
//                 {
//                 }
//             }
//             dataitem(SalesLine_NotShipped; "Sales Line")
//             {
//                 DataItemLink = "Document No." = field("eCom Order No.");
//                 DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const(Order), "Qty. to Ship" = const(0));
//                 column(ReportForNavId_12; 12)
//                 {
//                 }
//                 column(Description_SalesLineNotShipped; SalesLine_NotShipped.Description)
//                 {
//                 }
//                 column(Quantity_SalesLineNotShipped; SalesLine_NotShipped.Quantity)
//                 {
//                 }
//                 column(No_SalesLineNotShipped; SalesLine_NotShipped."No.")
//                 {
//                 }
//             }
//             dataitem("LSC Trans. Sales Entry"; "LSC Trans. Sales Entry")
//             {
//                 DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
//                 column(ReportForNavId_1000000001; 1000000001)
//                 {
//                 }
//                 column(ItemNo_TransSalesEntry; "LSC Trans. Sales Entry"."Item No.")
//                 {
//                 }
//                 column(Quantity_TransSalesEntry; -"LSC Trans. Sales Entry".Quantity)
//                 {
//                 }
//                 column(BarcodeNo_TransSalesEntry; "LSC Trans. Sales Entry"."Barcode No.")
//                 {
//                 }
//                 column(VATCode_TransSalesEntry; "LSC Trans. Sales Entry"."VAT Code")
//                 {
//                     //                    DecimalPlaces = 2 : 2;
//                 }
//                 column(NetAmount_TransSalesEntry; -"LSC Trans. Sales Entry"."Net Amount")
//                 {
//                 }
//                 column(VATAmount_TransSalesEntry; -"LSC Trans. Sales Entry"."VAT Amount")
//                 {
//                 }
//                 column(ItemDescription; Item.Description)
//                 {
//                 }
//                 column(DiscountAmount_TransSalesEntry; "LSC Trans. Sales Entry"."Discount Amount")
//                 {
//                 }
//                 column(VATPercentage; VATAnal."Column 1 Amt.")
//                 {
//                 }
//                 column(SubItem; SubItem)
//                 {
//                 }
//                 column(SubItemNo; SubItemNo)
//                 {
//                 }
//                 column(SubQty; SubQty)
//                 {
//                 }
//                 column(SubDescription; SubDescripton)
//                 {
//                 }
//                 column(OutOfStock; OutOfStock)
//                 {
//                 }
//                 column(OutOfStockDescription; OutOfStockDescription)
//                 {
//                 }
//                 column(OutOfStockItemNo; OutOfStockItemNo)
//                 {
//                 }
//                 column(OriginalItemNo; OriginalItemNo)
//                 {
//                 }

//                 trigger OnAfterGetRecord()
//                 var
//                     SalesLine2: Record "Sales Line";
//                     SalesLine3: Record "Sales Line";
//                     SalesLine: Record "Sales Line";
//                     VATSetup: Record "VAT Posting Setup";
//                 begin
//                     if not Item.Get("Item No.") then
//                         Clear(Item);

//                     if "VAT Code" <> '' then begin
//                         if not VATAnal.Get("VAT Code") then begin
//                             VATSetup.Reset;
//                             VATSetup.SetRange("VAT Bus. Posting Group", "LSC Transaction Header"."VAT Bus.Posting Group");
//                             VATSetup.SetRange("LSC POS Terminal VAT Code", "VAT Code");
//                             if VATSetup.FindFirst then begin
//                                 Clear(VATAnal);
//                                 VATAnal."Currency Code" := "VAT Code";
//                                 VATAnal."Column 1 Amt." := VATSetup."VAT %";
//                                 VATAnal.Insert;
//                             end;
//                         end;
//                         VATAnal."Column 2 Amt." += -"LSC Trans. Sales Entry"."Net Amount";
//                         VATAnal."Column 3 Amt." += -"LSC Trans. Sales Entry"."VAT Amount";
//                         VATAnal.Modify;
//                     end;
//                     SubItem := false;
//                     SubItemNo := '';
//                     SubDescripton := '';
//                     OriginalItemNo := '';
//                     if not "LSC Transaction Header"."Sale Is Return Sale" then
//                         if SalesLine.Get(SalesLine."document type"::Order, "LSC Transaction Header"."eCom Order No.", "LSC Trans. Sales Entry"."Line No.") then begin
//                             SubItem := SalesLine."New Line";
//                             SubItemNo := SalesLine."No.";
//                             if SubItem then
//                                 if SalesLine2.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Reference Line No.") then
//                                     OriginalItemNo := SalesLine2."No.";
//                             SubDescripton := SalesLine2.Description;
//                             SubQty := SalesLine2.Quantity;
//                         end;

//                     OutOfStock := false;
//                     OutOfStockDescription := '';
//                     OutOfStockItemNo := '';
//                     if "LSC Trans. Sales Entry".Quantity = 0 then begin
//                         SalesLine3.SetRange("Document Type", SalesLine3."document type"::Order);
//                         SalesLine3.SetRange("Document No.", "LSC Transaction Header"."eCom Order No.");
//                         SalesLine3.SetRange("Reference Line No.", "LSC Trans. Sales Entry"."Line No.");
//                         OutOfStock := not SalesLine3.FindFirst;
//                         OutOfStockItemNo := SalesLine3."No.";
//                         OutOfStockDescription := SalesLine3.Description;
//                     end;

//                     if "LSC Trans. Sales Entry".Quantity = 0 then begin
//                         if SalesLine_Qty_Difference."Original Quantity" > SalesLine_Qty_Difference.Quantity then
//                             QtyDifference := 555;
//                     end;
//                 end;
//             }
//             dataitem("Sales Line"; "Sales Line")
//             {
//                 DataItemLink = "Document No." = field("eCom Order No.");
//                 DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const(Order));
//                 column(ReportForNavId_1; 1)
//                 {
//                 }
//                 column(SalesLineComment; SalesLineComment)
//                 {
//                 }
//                 column(SalesLineDescription; SalesLineDescription)
//                 {
//                 }

//                 trigger OnAfterGetRecord()
//                 var
//                     SalesCommentLine: Record "Sales Comment Line";
//                     SalesLine: Record "Sales Line";
//                 begin
//                     Clear(SalesLineDescription);
//                     Clear(SalesLineComment);
//                     if "Reference Line No." <> 0 then begin
//                         if SalesLine.Get("Document Type", "Document No.", "Reference Line No.") then begin
//                             SalesLineDescription := SalesLine.Description;
//                             SalesLineComment := 'Substitute';
//                         end;
//                     end else
//                         if SalesCommentLine.Get("Document Type", "Document No.", "Line No.", 10000) then begin
//                             SalesLineDescription := Description;
//                             SalesLineComment := SalesCommentLine.Comment;
//                         end;
//                     if SalesLineComment = '' then
//                         CurrReport.Skip;
//                 end;
//             }
//             dataitem("LSC Trans. Payment Entry"; "LSC Trans. Payment Entry")
//             {
//                 DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
//                 column(ReportForNavId_1000000002; 1000000002)
//                 {
//                 }
//                 column(TenderType_TransPaymentEntry; "LSC Trans. Payment Entry"."Tender Type")
//                 {
//                     //DecimalPlaces = 2 : 2;
//                 }
//                 column(AmountTendered_TransPaymentEntry; "LSC Trans. Payment Entry"."Amount Tendered")
//                 {
//                 }
//                 column(Cashier_TransPaymentEntry; "LSC Trans. Payment Entry"."Staff ID")
//                 {
//                 }
//                 column(TenderDescr; TenderDescr)
//                 {
//                 }

//                 trigger OnAfterGetRecord()
//                 begin
//                     if "Tender Type" <> '' then begin
//                         TenderType.Reset;
//                         TenderType.SetRange(TenderType.Code, "Tender Type");
//                         if TenderType.FindFirst then begin
//                             TenderDescr := TenderType.Description;
//                         end;
//                     end;
//                 end;
//             }
//             dataitem("Integer"; "Integer")
//             {
//                 DataItemTableView = sorting(Number);
//                 column(ReportForNavId_1000000041; 1000000041)
//                 {
//                 }
//                 column(VATCode; VATAnal."Currency Code")
//                 {
//                     //DecimalPlaces = 2 : 2;
//                 }
//                 column(VATPerc; VATAnal."Column 1 Amt.")
//                 {
//                     DecimalPlaces = 2 : 2;
//                 }
//                 column(VATBase; VATAnal."Column 2 Amt.")
//                 {
//                     DecimalPlaces = 2 : 2;
//                 }
//                 column(VATAmt; VATAnal."Column 3 Amt.")
//                 {
//                     DecimalPlaces = 2 : 2;
//                 }

//                 trigger OnAfterGetRecord()
//                 begin
//                     if Number = 1 then
//                         VATAnal.FindFirst
//                     else
//                         VATAnal.Next;
//                 end;

//                 trigger OnPreDataItem()
//                 begin
//                     SetRange(Number, 1, VATAnal.Count);
//                 end;
//             }

//             trigger OnAfterGetRecord()
//             var
//                 Cust: Record Customer;
//                 MemberContact: Record "LSC Member Contact";
//                 MembershipCard: Record "LSC Membership Card";
//                 SalesHeader: Record "Sales Header";
//                 FormatAddr: Codeunit "Format Address";
//                 i: Integer;
//             begin
//                 //IF ("Customer No." = '') AND ("Member Card No." = '') THEN
//                 //  CurrReport.SKIP;
//                 if "To Account" then begin
//                     InvoiceType := 'O N L I N E   O R D E R  I N V O I C E';
//                     InvType := 1;
//                 end else begin
//                     InvoiceType := 'O N L I N E   O R D E R  I N V O I C E';
//                     InvType := 2;
//                 end;
//                 MemberCardNo := '';
//                 Clear(CustAddress);
//                 //BC Upgrade Start
//                 // if ("Customer No." = '') then begin 

//                 //     Cust.Get("Customer No.");
//                 //     //FormatAddr.Customer(CustAddress,Cust);
//                 //     CustAddress[1] := Cust.Name;
//                 //     CustomerNumber := "Customer No.";
//                 //     with Cust do begin
//                 //         if Address <> '' then
//                 //             CustomerAddress := Address + ' ';
//                 //         if "Address 2" <> '' then
//                 //             CustomerAddress += "Address 2" + ' ';
//                 //         if City <> '' then
//                 //             CustomerAddress += City + ' ';
//                 //         if "Post Code" <> '' then
//                 //             CustomerAddress += "Post Code" + ' ';
//                 //         if County <> '' then
//                 //             CustomerAddress += County + ' ';
//                 //         if "Country/Region Code" <> '' then
//                 //             CustomerAddress += "Country/Region Code";
//                 //     end;
//                 // end else
//                 if "eCom Order No." <> '' then begin
//                     SalesHeader.Get(SalesHeader."Document Type"::Order, "eCom Order No.");
//                     CustAddress[1] := SalesHeader."Sell-to Customer Name";
//                     CustomerNumber := SalesHeader."Sell-to Customer No.";
//                     if SalesHeader."Sell-to Address" <> '' then
//                         CustomerAddress := SalesHeader."Sell-to Address" + ' ';
//                     if SalesHeader."Sell-to Address 2" <> '' then
//                         CustomerAddress += SalesHeader."Sell-to Address 2" + ' ';


//                     if SalesHeader."Sell-to City" <> '' then
//                         CustomerAddress += SalesHeader."Sell-to City" + ' ';
//                     if SalesHeader."Sell-to Post Code" <> '' then
//                         CustomerAddress += SalesHeader."Sell-to Post Code" + ' ';

//                     if SalesHeader."Sell-to Country/Region Code" <> '' then
//                         CustomerAddress += SalesHeader."Sell-to Country/Region Code";

//                 end else begin
//                     if ("Customer No." <> '') then begin

//                         Cust.Get("Customer No.");
//                         //FormatAddr.Customer(CustAddress,Cust);
//                         CustAddress[1] := Cust.Name;
//                         CustomerNumber := "Customer No.";

//                         if Cust.Address <> '' then
//                             CustomerAddress := Cust.Address + ' ';
//                         if Cust."Address 2" <> '' then
//                             CustomerAddress += Cust."Address 2" + ' ';
//                         if Cust.City <> '' then
//                             CustomerAddress += Cust.City + ' ';
//                         if Cust."Post Code" <> '' then
//                             CustomerAddress += Cust."Post Code" + ' ';
//                         if Cust."Country/Region Code" <> '' then
//                             CustomerAddress += Cust."Country/Region Code";
//                     end;
//                     //BC Upgrade End
//                     if ("Customer No." = '') then //BC Upgrade
//                         if "Member Card No." <> '' then begin
//                             MembershipCard.Get("Member Card No.");
//                             MemberContact.Get(MembershipCard."Account No.", MembershipCard."Contact No.");
//                             //FormatAddr.MemberContact(CustAddress,MemberContact);
//                             CustAddress[1] := MemberContact.Name;
//                             CustomerNumber := MembershipCard."Account No.";
//                             with MemberContact do begin
//                                 if Address <> '' then
//                                     CustomerAddress := Address + ' ';
//                                 if "Address 2" <> '' then
//                                     CustomerAddress += "Address 2" + ' ';
//                                 if City <> '' then
//                                     CustomerAddress += City + ' ';
//                                 if "Post Code" <> '' then
//                                     CustomerAddress += "Post Code" + ' ';
//                                 if County <> '' then
//                                     CustomerAddress += County + ' ';
//                                 //BC Upgrade Start
//                                 // if Country <> '' then
//                                 //     CustomerAddress += Country;
//                                 if MemberContact."Country/Region Code" <> '' then
//                                     CustomerAddress += MemberContact."Country/Region Code";
//                                 //BC Upgrade End
//                             end
//                         end;
//                 end;
//                 if "Member Card No." <> '' then begin
//                     MemberCardNo := CopyStr("Member Card No.", StrLen("Member Card No.") - 2);
//                     if StrLen(MemberCardNo) < StrLen("Member Card No.") then
//                         repeat
//                             MemberCardNo := '*' + MemberCardNo;
//                         until StrLen(MemberCardNo) = StrLen("Member Card No.");
//                 end;
//                 POSTerminal.Get("POS Terminal No.");
//                 Barcode := '*T' + Format(POSTerminal."Receipt Barcode ID", 4, '<Integer,4><Filler Character,0>') +
//                         Format("Transaction No.", 9, '<Integer,9><Filler Character,0>') + '*';
//             end;
//         }
//     }

//     requestpage
//     {

//         layout
//         {
//         }

//         actions
//         {
//         }
//     }

//     labels
//     {
//     }

//     trigger OnPreReport()
//     begin
//         CompanyInfo.Get;
//         CompanyInfo.CalcFields(Picture);
//         Address[1] := 'C.A. PAPAELLINAS EMPORIKI LTD (ALPHAMEGA)';
//         //Address[2] := '10 Diomidous Street, Dasoupolis, 2433, Strovolos, Nicosia';
//         Address[2] := '10 Diomidous Street, 2024, Strovolos, Nicosia';
//         Address[3] := 'Web: http://www.alphamega.com.cy';
//         Address[4] := 'Phone: 80080022';
//         //Address[5] := 'VAT Registration No: 10027397Z';
//         Address[5] := 'Email: wedeliver@alphamega.com.cy';
//     end;

//     var
//         CompanyInfo: Record "Company Information";
//         Item: Record Item;
//         POSTerminal: Record "LSC POS Terminal";
//         TenderType: Record "LSC Tender Type";
//         VATAnal: Record "Aging Band Buffer" temporary;
//         OutOfStock: Boolean;
//         SubItem: Boolean;
//         CustomerNumber: Code[20];
//         MemberCardNo: Code[20];
//         OriginalItemNo: Code[20];
//         OutOfStockItemNo: Code[20];
//         SubItemNo: Code[20];
//         InvType: Integer;
//         QtyDifference: Integer;
//         SubQty: Integer;
//         Address: array[10] of Text;
//         Barcode: Text;
//         CustAddress: array[8] of Text[50];
//         CustomerAddress: Text[200];
//         InvoiceType: Text;
//         OutOfStockDescription: Text[200];
//         SalesLineComment: Text;
//         SalesLineDescription: Text;
//         SubDescripton: Text[200];
//         TenderDescr: Text[30];
// }