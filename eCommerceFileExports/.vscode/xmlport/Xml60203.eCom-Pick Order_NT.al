xmlport 60203 "eCom-Pick Order_NT"
{
    Direction = Export;
    Encoding = UTF8;
    schema
    {
        textelement(PickOrderData)
        {
            XmlName = 'PickOrderData';
            textattribute(Attr1)
            {
                XmlName = 'xsi:noNamespaceSchemaLocation';
            }
            textattribute(Attr2)
            {
                XmlName = 'xmlns:xsi';
            }
            textelement(File_Created_Date)
            {
            }
            textelement(File_Created_Time)
            {
            }
            textelement(Sending_System)
            {
            }
            textelement(Receiving_System)
            {
            }
            textelement(Orders)
            {
                tableelement(Order; "Sales Header")
                {
                    XmlName = 'Order';
                    textelement(Status_ID)
                    {
                    }
                    fieldelement(Customer_ID; Order."Sell-to Customer No.")
                    {
                    }
                    textelement(Date_Created)
                    {
                        trigger OnBeforePassVariable()
                        var
                        begin
                            Date_Created := FORMAT(Order."Order Date", 0, '<Year4>-<Month,2>-<Day,2>');
                        end;
                    }
                    fieldelement(OrderNo; Order."No.")
                    {
                    }
                    textelement(Picklist_UUID)
                    {
                    }
                    textelement(Date_Updated)
                    {
                    }
                    textelement(Replacements_Products_Allowed)
                    {
                    }
                    textelement(Comment_From_Customer)
                    {
                    }
                    textelement(Comment_About_Customer)
                    {
                    }
                    textelement(Comment_About_Customer2)
                    {
                    }
                    textelement(Estimated_Time_Ready_For_Picking)
                    {
                    }
                    textelement(Delivery_Selected_DateTime)
                    {
                    }
                    textelement(Delivery_Selected_Slot_ID)
                    {
                    }
                    textelement(Delivery_Arrange_Position)
                    {
                    }
                    textelement(Delivery_Shipping_Method)
                    {
                    }
                    textelement(Total_Price)
                    {
                    }
                    textelement(domainName)
                    {
                    }
                    fieldelement(Store_ID; Order."LSC Store No.")
                    {
                    }
                    textelement(OrderType)
                    {
                    }
                    fieldelement(Delivery_Name; Order."Ship-to Name")
                    {
                    }
                    textelement(Delivery_Has_Address)
                    {
                    }
                    textelement(Delivery_First_Name)
                    {
                    }
                    textelement(Delivery_Last_Name)
                    {
                    }
                    textelement(Delivery_Street)
                    {
                    }
                    fieldelement(Delivery_Zip_Code; Order."Ship-to Post Code")
                    {
                    }

                    textelement(Delivery_City)
                    {
                    }
                    textelement(Delivery_Phone_Business)
                    {
                    }
                    textelement(Delivery_Mobile_Phone)
                    {
                    }
                    fieldelement(Pickup_Store_ID; Order."LSC Store No.")
                    {
                    }
                    textelement(Credit_Locked)
                    {
                    }
                    textelement(Reason_For_Cancellation)
                    {
                    }
                    textelement(Total_Customer_Orders)
                    {
                    }
                    textelement(Max_Height_Colli)
                    {
                    }
                    textelement(ExternalSeqNum)
                    {
                    }
                    textelement(ExternalRoute)
                    {
                    }
                    fieldelement(Longitude; Order."Web Order Delivery Longitude")
                    {
                    }
                    fieldelement(Latitude; Order."Web Order Delivery Latitude")
                    {
                    }
                    tableelement(Order_Row; "Sales Line")
                    {
                        SourceTableView = SORTING("Document Type", "Document No.", Type, "No.") WHERE(Type = CONST(Item), "Shipping Line" = CONST(false));
                        LinkTable = order;
                        LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        fieldelement(Row_ID; Order_Row."Line No.")
                        {
                        }
                        textelement(Item_ID)
                        {
                        }
                        fieldelement(Expected_Quantity; Order_Row.Quantity)
                        {
                        }
                        textelement(AllowSubstitute)
                        {
                            XmlName = 'Replacements_Products_Allowed';
                        }
                        textelement(Expected_Weight)
                        {
                        }
                        textelement(Picked_Quantity)
                        {
                        }
                        textelement(Warehouse_Location)
                        {
                        }
                        textelement(Single_Base_Price)
                        {
                        }
                        fieldelement(Single_Price; Order_Row."Unit Price")
                        {
                        }
                        fieldelement(Net_Price; Order_Row."VAT Base Amount")
                        {
                        }
                        fieldelement(Gross_Price; Order_Row.Amount)
                        {
                        }
                        textelement(Tax)
                        {
                        }
                        textelement(Sale_Stop)
                        {
                        }
                        textelement(Customer_Comment)
                        {
                        }
                        textelement(Replacements_Products_Type)
                        {
                        }
                        textelement(Ordered_Country_Of_Origin)
                        {
                        }
                        trigger OnAfterGetRecord()
                        var
                            Item: Record Item;
                        begin
                            Item.GET(Order_Row."No.");
                            //Item_ID := Item.DefaultBarcode;//BC Upgrade
                            Item_ID := DefaultBarcode(Order_Row."No.");//BC Upgrade
                            IF Item_ID = '' THEN
                                Item_ID := Order_Row."No.";
                            //Replacements_Products_Allowed2 := 'true';
                            //MS-BG
                            IF Order_Row."Allow Substitute" = TRUE THEN
                                AllowSubstitute := 'True'
                            ELSE
                                AllowSubstitute := 'False';
                            Expected_Weight := '';
                            IF (Item."Web Weight Item") AND (Item."Web Weight" <> 0) THEN
                                Expected_Weight := FORMAT(Item."Web Weight" * Order_Row.Quantity * 1000);
                            IF Order_Row.Quantity <> 0 THEN
                                Single_Base_Price := FORMAT(ROUND(Order_Row."VAT Base Amount" / Order_Row.Quantity, 0.01))
                            ELSE
                                Single_Base_Price := '0';

                        end;
                    }
                    trigger OnAfterGetRecord()
                    var
                        Address: Record eCom_Address_NT;
                        Date: Record Date;
                    begin
                        Date_Updated := FORMAT(Order."Order Date", 0, '<Year4>-<Month,2>-<Day,2>');
                        IF Order."Requested Delivery Date" = 0D THEN
                            Order."Requested Delivery Date" := CALCDATE('1W', Order."Order Date");
                        Estimated_Time_Ready_For_Picking := FORMAT(Order."Requested Delivery Date", 0, '<Year4>-<Month,2>-<Day,2>') + 'T' + COPYSTR(Order."Order Time Slot", 1, 2) + ':00:00';
                        Date.GET(Date."Period Type"::Date, Order."Requested Delivery Date");
                        Delivery_Selected_Slot_ID := Date."Period Name";
                        Delivery_Selected_DateTime := Order."Order Time Slot";

                        IF STRLEN(Order."Phone No.") = 8 THEN
                            Delivery_Phone_Business := '+357' + Order."Phone No."
                        ELSE
                            Delivery_Phone_Business := Order."Phone No.";
                        IF STRLEN(Order."Ship-To Telephone") = 8 THEN
                            Delivery_Mobile_Phone := '+357' + Order."Ship-To Telephone"
                        ELSE
                            Delivery_Mobile_Phone := Order."Ship-To Telephone";

                        Delivery_First_Name := COPYSTR(Order."Ship-to Name", 1, STRPOS(Order."Ship-to Name", ' '));
                        Delivery_Last_Name := COPYSTR(Order."Ship-to Name", STRPOS(Order."Ship-to Name", ' ') + 1);

                        Address.SETCURRENTKEY(Name);
                        Address.SETRANGE(Name, Order."Ship-to Address");
                        Address.SETRANGE("Postal Code", Order."Ship-to Post Code");
                        IF Address.FINDFIRST THEN BEGIN
                            Delivery_Street := STRSUBSTNO('%1 %2 Building:%3 Flat:%4', Address."Name GR", Order."Ship-to House No.", Order."Ship-to Building Name", Order."Ship-to Flat No.");
                            Delivery_City := STRSUBSTNO('%1 %2', Address."Municipality GR", Address."District GR");
                        END ELSE BEGIN
                            Delivery_Street := STRSUBSTNO('%1 %2 Building:%3 Flat:%4', Order."Ship-to Address", Order."Ship-to House No.", Order."Ship-to Building Name", Order."Ship-to Flat No.");
                            Delivery_City := STRSUBSTNO('%1 %2', Order."Ship-to Address 2", Order."Ship-to City");
                        END;
                    end;

                    trigger OnPreXmlItem()
                    var
                    begin
                        IF _FilterValue <> '' THEN
                            Order.SETFILTER("No.", _FilterValue);
                    end;
                }
            }

        }

    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {

                }
            }
        }
    }
    trigger OnPreXmlPort()
    var
    begin
        Attr1 := 'PICKORDER.xsd';
        Attr2 := 'http://www.w3.org/2001/XMLSchema-instance';
        File_Created_Date := FORMAT(TODAY, 0, '<Year4>-<Month,2>-<Day,2>');
        File_Created_Time := FORMAT(TIME);
        Sending_System := 'Dymanics NAV';
        Receiving_System := 'CUBLink';
        Replacements_Products_Allowed := 'true';
        Delivery_Has_Address := 'true';
        Status_ID := 'READY_TO_PICK';
    end;

    procedure SetFilter(FilterValue: Text[250])
    begin
        _FilterValue := FilterValue;
    end;

    local procedure DefaultBarcode(ItemNo: Code[20]): Code[20]
    var
        Barcodes: Record "LSC Barcodes";
    begin
        //LS
        //DefaultBarcode

        Barcodes.SETCURRENTKEY("Item No.", "Barcode No.");
        Barcodes.SETRANGE("Item No.", ItemNo);
        Barcodes.SETRANGE("Show for Item", TRUE);
        IF Barcodes.FIND('-') THEN
            EXIT(Barcodes."Barcode No.")
        ELSE BEGIN
            Barcodes.SETRANGE("Show for Item", FALSE);
            IF Barcodes.FIND('-') THEN
                EXIT(Barcodes."Barcode No.");
        END;
        EXIT('');
    end;

    var
        _FilterValue: Text[250];
}