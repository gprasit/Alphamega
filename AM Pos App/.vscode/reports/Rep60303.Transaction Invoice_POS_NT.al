report 60303 "POS_Transaction Invoice_NT"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/POS_Transaction Invoice_NT.rdlc';

    dataset
    {
        dataitem("LSC Transaction Header"; "LSC Transaction Header")
        {
            RequestFilterFields = "Store No.", "POS Terminal No.", "Transaction No.", "Receipt No.";
            column(ReportForNavId_1000000000; 1000000000)
            {
            }
            column(Logo; CompanyInfo.Picture)
            {
            }
            column(Address_1; Address[1])
            {
            }
            column(Address_2; Address[2])
            {
            }
            column(Address_3; Address[3])
            {
            }
            column(Address_4; Address[4])
            {
            }
            column(Address_5; Address[5])
            {
            }
            column(Address_6; Address[6])
            {
            }
            column(Address_7; Address[7])
            {
            }
            column(Address_8; Address[8])
            {
            }
            column(Address_9; Address[9])
            {
            }
            column(CustAddress_1; CustAddress[1])
            {
            }
            column(CustAddress_2; CustAddress[2])
            {
            }
            column(CustAddress_3; CustAddress[3])
            {
            }
            column(CustAddress_4; CustAddress[4])
            {
            }
            column(CustAddress_5; CustAddress[5])
            {
            }
            column(CustAddress_6; CustAddress[6])
            {
            }
            column(CustAddress_7; CustAddress[7])
            {
            }
            column(CustAddress_8; CustAddress[8])
            {
            }
            column(InvoiceType; InvoiceType)
            {
            }
            column(MemberCardNo_TransactionHeader; MemberCardNo)
            {
            }
            column(NetAmount_TransactionHeader; -"LSC Transaction Header"."Net Amount")
            {
            }
            column(GrossAmount_TransactionHeader; -"LSC Transaction Header"."Gross Amount")
            {
            }
            column(CustomerNo_TransactionHeader; "LSC Transaction Header"."Customer No.")
            {
            }
            column(Date_TransactionHeader; "LSC Transaction Header".Date)
            {
            }
            column(Time_TransactionHeader; "LSC Transaction Header".Time)
            {
            }
            column(TransactionNo_TransactionHeader; "LSC Transaction Header"."Transaction No.")
            {
            }
            column(ReceiptNo_TransactionHeader; "LSC Transaction Header"."Receipt No.")
            {
            }
            column(StoreNo_TransactionHeader; "LSC Transaction Header"."Store No.")
            {
            }
            column(POSTerminalNo_TransactionHeader; "LSC Transaction Header"."POS Terminal No.")
            {
            }
            column(CustomerAddress; CustomerAddress)
            {
            }
            column(CustomerNumber; CustomerNumber)
            {
            }
            column(Barcode; Barcode)
            {
            }
            column(BarcodeTxt; BarcodeTxt)
            {
            }
            dataitem("LSC Trans. Sales Entry"; "LSC Trans. Sales Entry")
            {
                DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                column(ReportForNavId_1000000001; 1000000001)
                {
                }
                column(ItemNo_TransSalesEntry; "LSC Trans. Sales Entry"."Item No.")
                {
                }
                column(Quantity_TransSalesEntry; -"LSC Trans. Sales Entry".Quantity)
                {
                }
                column(BarcodeNo_TransSalesEntry; "LSC Trans. Sales Entry"."Barcode No.")
                {
                }
                column(VATCode_TransSalesEntry; "LSC Trans. Sales Entry"."VAT Code")
                {

                }
                column(NetAmount_TransSalesEntry; -"LSC Trans. Sales Entry"."Net Amount")
                {
                }
                column(VATAmount_TransSalesEntry; -"LSC Trans. Sales Entry"."VAT Amount")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(ItemDescription; Item.Description)
                {
                }
                column(DiscountAmount_TransSalesEntry; "LSC Trans. Sales Entry"."Discount Amount")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(VATPercentage; VATAnal."Column 1 Amt.")
                {
                }

                trigger OnAfterGetRecord()
                var
                    VATSetup: Record "VAT Posting Setup";
                begin
                    if not Item.Get("Item No.") then
                        Clear(Item);

                    if "VAT Code" <> '' then begin
                        if not VATAnal.Get("VAT Code") then begin
                            VATSetup.Reset;
                            VATSetup.SetRange("VAT Bus. Posting Group", "LSC Transaction Header"."VAT Bus.Posting Group");
                            VATSetup.SetRange("LSC POS Terminal VAT Code", "VAT Code");
                            if VATSetup.FindFirst then begin
                                Clear(VATAnal);
                                VATAnal."Currency Code" := "VAT Code";
                                VATAnal."Column 1 Amt." := VATSetup."VAT %";
                                VATAnal.Insert;
                            end;
                        end;
                        VATAnal."Column 2 Amt." += -"LSC Trans. Sales Entry"."Net Amount";
                        VATAnal."Column 3 Amt." += -"LSC Trans. Sales Entry"."VAT Amount";
                        VATAnal.Modify;
                    end;
                end;
            }
            dataitem("LSC Trans. Payment Entry"; "LSC Trans. Payment Entry")
            {
                DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                column(ReportForNavId_1000000002; 1000000002)
                {
                }
                column(TenderType_TransPaymentEntry; "LSC Trans. Payment Entry"."Tender Type")
                {

                }
                column(AmountTendered_TransPaymentEntry; "LSC Trans. Payment Entry"."Amount Tendered")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(Cashier_TransPaymentEntry; "LSC Trans. Payment Entry"."Staff ID")
                {
                }
                column(TenderDescr; TenderDescr)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if "Tender Type" <> '' then begin
                        TenderType.Reset;
                        TenderType.SetRange(TenderType.Code, "Tender Type");
                        if TenderType.FindFirst then begin
                            TenderDescr := TenderType.Description;
                        end;
                    end;
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(ReportForNavId_1000000041; 1000000041)
                {
                }
                column(VATCode; VATAnal."Currency Code")
                {

                }
                column(VATPerc; VATAnal."Column 1 Amt.")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(VATBase; VATAnal."Column 2 Amt.")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(VATAmt; VATAnal."Column 3 Amt.")
                {
                    DecimalPlaces = 2 : 2;
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        VATAnal.FindFirst
                    else
                        VATAnal.Next;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, VATAnal.Count);
                end;
            }

            trigger OnAfterGetRecord()
            var
                FormatAddr: Codeunit "Format Address";
                Cust: Record Customer;
                MembershipCard: Record "LSC Membership Card";
                MemberContact: Record "LSC Member Contact";
                i: Integer;
            begin
                //IF ("Customer No." = '') AND ("Member Card No." = '') THEN
                //  CurrReport.SKIP;
                if "To Account" then begin
                    InvoiceType := 'C R E D I T   I N V O I C E';
                    InvType := 1;
                end else begin
                    InvoiceType := 'C A S H   I N V O I C E';
                    InvType := 2;
                end;
                MemberCardNo := '';
                Clear(CustAddress);
                if ("Customer No." <> '') then begin
                    Cust.Get("Customer No.");
                    //FormatAddr.Customer(CustAddress,Cust);
                    CustAddress[1] := Cust.Name;
                    CustomerNumber := "Customer No.";
                    with Cust do begin
                        if Address <> '' then
                            CustomerAddress := Address + ' ';
                        if "Address 2" <> '' then
                            CustomerAddress += "Address 2" + ' ';
                        if City <> '' then
                            CustomerAddress += City + ' ';
                        if "Post Code" <> '' then
                            CustomerAddress += "Post Code" + ' ';
                        if County <> '' then
                            CustomerAddress += County + ' ';
                        if "Country/Region Code" <> '' then
                            CustomerAddress += "Country/Region Code";
                    end;
                end else
                    if "Member Card No." <> '' then begin
                        MembershipCard.Get("Member Card No.");
                        MemberContact.Get(MembershipCard."Account No.", MembershipCard."Contact No.");
                        //FormatAddr.MemberContact(CustAddress,MemberContact);
                        CustAddress[1] := MemberContact.Name;
                        CustomerNumber := MembershipCard."Account No.";
                        with MemberContact do begin
                            if Address <> '' then
                                CustomerAddress := Address + ' ';
                            if "Address 2" <> '' then
                                CustomerAddress += "Address 2" + ' ';
                            if City <> '' then
                                CustomerAddress += City + ' ';
                            if "Post Code" <> '' then
                                CustomerAddress += "Post Code" + ' ';
                            if County <> '' then
                                CustomerAddress += County + ' ';
                            if "Country/Region Code" <> '' then
                                CustomerAddress += "Country/Region Code";
                        end
                    end;
                if "Member Card No." <> '' then begin
                    MemberCardNo := CopyStr("Member Card No.", StrLen("Member Card No.") - 2);
                    if StrLen(MemberCardNo) < StrLen("Member Card No.") then
                        repeat
                            MemberCardNo := '*' + MemberCardNo;
                        until StrLen(MemberCardNo) = StrLen("Member Card No.");
                end;
                POSTerminal.Get("POS Terminal No.");
                BarcodeTxt := '*T' + Format(POSTerminal."Receipt Barcode ID", 4, '<Integer,4><Filler Character,0>') +
                        Format("Transaction No.", 9, '<Integer,9><Filler Character,0>') + '*';
                Barcode := 'T' + Format(POSTerminal."Receipt Barcode ID", 4, '<Integer,4><Filler Character,0>') +
                        Format("Transaction No.", 9, '<Integer,9><Filler Character,0>');
                Barcode := PosBarcodeMgt.GenerateBarcode(Barcode);
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
        //Address[2] := '10 Diomidous Street, Dasoupolis, 2433, Strovolos, Nicosia';
        Address[2] := '10 Diomidous Street, 2024, Strovolos, Nicosia';
        Address[3] := 'Web: http://www.alphamega.com.cy';
        Address[4] := 'Phone: (357) 22469505   Fax: (357) 22469535';
        //Address[5] := 'VAT Registration No: 10027397Z';
        Address[5] := 'VAT Registration No: CY10027397Z';
    end;

    var
        PosBarcodeMgt: Codeunit "Pos_Barcode Management_NT";
        Address: array[10] of Text;
        CompanyInfo: Record "Company Information";
        CustAddress: array[8] of Text[50];
        InvoiceType: Text;
        InvType: Integer;
        Item: Record Item;
        VATAnal: Record "Aging Band Buffer" temporary;
        MemberCardNo: Code[20];
        CustomerAddress: Text[200];
        TenderDescr: Text[30];
        TenderType: Record "LSC Tender Type";
        CustomerNumber: Code[20];
        Barcode: Text;
        BarcodeTxt: Text;
        POSTerminal: Record "LSC POS Terminal";
}

