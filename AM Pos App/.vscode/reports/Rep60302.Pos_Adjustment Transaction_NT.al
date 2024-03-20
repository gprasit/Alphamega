Report 60302 "Pos_Adjustment Transaction_NT"
{
   Caption ='Adjustment Transaction';
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Adjustment Transaction.rdlc';

    dataset
    {
        dataitem("LSC Transaction Header";"LSC Transaction Header")
        {
            RequestFilterFields = "Store No.","POS Terminal No.","Transaction No.","Receipt No.";
            column(ReportForNavId_1000000000; 1000000000)
            {
            }
            column(Logo;CompanyInfo.Picture)
            {
            }
            column(Address_1;Address[1])
            {
            }
            column(Address_2;Address[2])
            {
            }
            column(Address_3;Address[3])
            {
            }
            column(Address_4;Address[4])
            {
            }
            column(Address_5;Address[5])
            {
            }
            column(Address_6;Address[6])
            {
            }
            column(Address_7;Address[7])
            {
            }
            column(Address_8;Address[8])
            {
            }
            column(Address_9;Address[9])
            {
            }
            column(InvoiceType;InvoiceType)
            {
            }
            column(MemberCardNo_TransactionHeader;"LSC Transaction Header"."Member Card No.")
            {
            }
            column(NetAmount_TransactionHeader;"LSC Transaction Header"."Net Amount")
            {
            }
            column(GrossAmount_TransactionHeader;"LSC Transaction Header"."Gross Amount")
            {
            }
            column(CustomerNo_TransactionHeader;"LSC Transaction Header"."Customer No.")
            {
            }
            column(Date_TransactionHeader;"LSC Transaction Header".Date)
            {
            }
            column(Time_TransactionHeader;"LSC Transaction Header".Time)
            {
            }
            column(TransactionNo_TransactionHeader;"LSC Transaction Header"."Transaction No.")
            {
            }
            column(ReceiptNo_TransactionHeader;"LSC Transaction Header"."Receipt No.")
            {
            }
            column(StoreNo_TransactionHeader;"LSC Transaction Header"."Store No.")
            {
            }
            column(POSTerminalNo_TransactionHeader;"LSC Transaction Header"."POS Terminal No.")
            {
            }
            column(StaffID_TransactionHeader;"LSC Transaction Header"."Staff ID")
            {
            }
            column(InfoCodes_1;InfoCodes[1])
            {
            }
            column(InfoCodes_2;InfoCodes[2])
            {
            }
            column(InfoCodes_3;InfoCodes[3])
            {
            }
            column(InfoCodes_4;InfoCodes[4])
            {
            }
            column(InfoCodes_5;InfoCodes[5])
            {
            }
            column(InfoCodes_6;InfoCodes[6])
            {
            }
            dataitem("LSC Trans. Inventory Entry";"LSC Trans. Inventory Entry")
            {
                DataItemLink = "Store No."=field("Store No."),"POS Terminal No."=field("POS Terminal No."),"Transaction No."=field("Transaction No.");
                column(ReportForNavId_1000000001; 1000000001)
                {
                }
                column(ItemNo_TransInventoryEntry;"LSC Trans. Inventory Entry"."Item No.")
                {
                }
                column(Quantity_TransInventoryEntry;"LSC Trans. Inventory Entry".Quantity)
                {
                }
                column(BarcodeNo_TransInventoryEntry;"LSC Trans. Inventory Entry"."Barcode No.")
                {
                }
                column(ItemDescription;Item.Description)
                {
                }
                column(UnitPrice;Item."Unit Price")
                {
                }

                trigger OnAfterGetRecord()
                var
                    VATSetup: Record "VAT Posting Setup";
                    SalesPrice: Record "Sales Price";
                    RetailPriceUtils: Codeunit "LSC Retail Price Utils";
                begin
                    if not Item.Get("Item No.") then
                      Clear(Item);
                    RetailPriceUtils.GetItemPrice('AL',"Item No.",'',Date,'',SalesPrice,Item."Base Unit of Measure");
                    //if SalesPrice."Unit Price Including VAT" <> 0 then //BC.Upgrade
                    //Item."Unit Price" := SalesPrice."Unit Price Including VAT";//BC.Upgrade
                    if SalesPrice."LSC Unit Price Including VAT" <> 0 then
                      Item."Unit Price" := SalesPrice."LSC Unit Price Including VAT";
                end;
            }

            trigger OnAfterGetRecord()
            var
                FormatAddr: Codeunit "Format Address";
                Cust: Record Customer;
                TransInfoEntry: Record "LSC Trans. Infocode Entry";
                Infocode: Record "LSC Infocode";
                InformationSubcode: Record "LSC Information Subcode";
                i: Integer;
            begin
                if "LSC Transaction Header"."Transaction Type" <> "LSC Transaction Header"."transaction type"::NegAdj then
                  CurrReport.Skip;

                InvoiceType := 'A D J U S T M E N T';
                InvType := 1;

                i := 0;
                Clear(InfoCodes);

                TransInfoEntry.Reset;
                TransInfoEntry.SetRange("Store No.","Store No.");
                TransInfoEntry.SetRange("POS Terminal No.","POS Terminal No.");
                TransInfoEntry.SetRange("Transaction No.","Transaction No.");
                if TransInfoEntry.FindSet then
                  repeat
                    i += 1;
                    if Infocode.Get(TransInfoEntry.Infocode) then begin
                      if InformationSubcode.Get(TransInfoEntry.Infocode,TransInfoEntry.Subcode) then
                        InfoCodes[i] := StrSubstNo('%1 (%2)',Infocode.Description,InformationSubcode.Description)
                      else
                        InfoCodes[i] := StrSubstNo('%1 (%2)',Infocode.Description,TransInfoEntry.Information);
                    end else
                      InfoCodes[i] := StrSubstNo('%1 (%2)',TransInfoEntry.Infocode,TransInfoEntry.Information);
                  until (TransInfoEntry.Next = 0) or (i = 6);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);
        Address[1] := 'C.A. PAPAELLINAS EMPORIKI LTD (ALPHAMEGA)';
        Address[2] := '10 Diomidous Street, Dasoupolis, 2433, Strovolos, Nicosia';
        Address[3] := 'Web: http://www.alphamega.com.cy';
        Address[4] := 'Phone: (357) 22469505   Fax: (357) 22469535';
        Address[5] := 'VAT Registration No: 10027397Z';
    end;

    var
        Address: array [10] of Text;
        CompanyInfo: Record "Company Information";
        InvoiceType: Text;
        InvType: Integer;
        Item: Record Item;
        InfoCodes: array [6] of Text;
}

