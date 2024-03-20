// pageextension 60201 "Retail Sales Order_NT" extends "Sales Order"
// {
//     layout
//     {
//         // Add changes to page layout here
//     }

//     actions
//     {
//         // Add changes to page actions here
//         addafter(Release)
//         {
//             action(TESTDISCOUNT)
//             {
//                 ApplicationArea = All;

//                 trigger OnAction()
//                 var
//                     salesheader: Record "Sales Header";
//                     total: Decimal;
//                     InvDiscAmt : Decimal;
//                     eComFileGenFn : Codeunit "eComFile_General Functions_NT";
//                 begin
//                     salesheader.SetFilter("Document Type",'%1',Rec."Document Type");
//                     salesheader.SetFilter("No.",Rec."No.");
//                     salesheader.FindFirst();   
//                     IF (SalesHeader."Invoice Discount %" <> 0) OR (SalesHeader."Inv. Discount Amount" <> 0) THEN
//                         IF SalesHeader."Web Order Status" IN [SalesHeader."Web Order Status"::Picked, SalesHeader."Web Order Status"::"Picked with Difference"] THEN BEGIN
//                             IF SalesHeader."Invoice Discount %" <> 0 THEN BEGIN
//                                 Total := eComFileGenFn.GetOrderTotalAmount(SalesHeader);
//                                 InvDiscAmt := ROUND((SalesHeader."Invoice Discount %" * Total / 100), 0.01);
//                             END;
//                             IF SalesHeader."Inv. Discount Amount" <> 0 THEN
//                                 InvDiscAmt += SalesHeader."Inv. Discount Amount";
//                             IF InvDiscAmt > 0 THEN
//                                 eComFileGenFn.CalcInvoiceDiscount(SalesHeader, InvDiscAmt);
//                         END;
//                 end;
//             }
//         }

//     }

//     var
//         myInt: Integer;
// }