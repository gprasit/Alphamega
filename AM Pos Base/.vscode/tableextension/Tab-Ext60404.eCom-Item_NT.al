tableextension 60404 "eCom-Item_NT" extends Item
{
    fields
    {
        field(60001; "Bean Bar Item"; Boolean)
        {
            Caption = 'Bean Bar Item';
            DataClassification = CustomerContent;
        }
        field(60002; "Compress On Sales Export"; Boolean)
        {
            Caption = 'Compress On Sales Export';
            DataClassification = CustomerContent;
        }
        field(60004; "Max. Qty. Per Transaction"; Decimal)
        {
            Caption = 'Max. Qty. Per Transaction';
            DataClassification = CustomerContent;
        }
        field(60005; "Item Department Code"; code[20])
        {
            Caption = 'Item Department Code';
            DataClassification = CustomerContent;
            TableRelation = "eCom_Item Department_NT";
        }
        field(60006; "Topup Item"; Boolean)
        {
            Caption = 'Topup Item';
            DataClassification = CustomerContent;
        }
        field(60007; "Item Brand Code"; Code[10])
        {
            Caption = 'Item Brand Code';
            DataClassification = CustomerContent;
        }
        field(60010; "Mobile App. Category"; Code[10])
        {
            Caption = 'Mobile App. Category';
            DataClassification = CustomerContent;
        }
        field(60011; "Mobile App. Product Group"; Code[10])
        {
            Caption = 'Mobile App. Product Group';
            DataClassification = CustomerContent;
        }
        field(60012; "Mobile App. Description"; Text[50])
        {
            Caption = 'Mobile App. Description';
            DataClassification = CustomerContent;
        }
        field(60013; "Mobile App. Offer Desc."; Text[50])
        {
            Caption = 'Mobile App. Offer Desc.';
            DataClassification = CustomerContent;
        }
        field(60015; "Store Groups"; Code[60])
        {
            Caption = 'Store Groups';
            DataClassification = CustomerContent;
        }
        field(60030; "Greek Description"; Text[50])
        {
            Caption = 'Greek Description';
            DataClassification = CustomerContent;
        }
        field(60031; "Comparison UOM"; Code[10])
        {
            Caption = 'Comparison UOM';
            DataClassification = CustomerContent;
        }
        field(60032; "Actual Weight"; Decimal)
        {
            Caption = 'Actual Weight';
            DataClassification = CustomerContent;
        }
        field(60033; "ESL Description"; Text[10])
        {
            Caption = 'ESL Description';
            DataClassification = CustomerContent;
        }

        field(60034; "ESL Offer"; Boolean)
        {
            Caption = 'ESL Offer';
            DataClassification = CustomerContent;
        }
        field(60035; "ESL ENG Description"; Text[30])
        {
            Caption = 'ESL ENG Description';
            DataClassification = CustomerContent;
        }
        field(60055; "Web Item"; Boolean)
        {
            Caption = 'Web Item';
            DataClassification = CustomerContent;
        }
        field(60056; "Web Weight"; Decimal)
        {
            Caption = 'Web Weight';
            DataClassification = CustomerContent;
        }
        field(60057; "Heavy Item"; Boolean)
        {
            Caption = 'Heavy Item';
            DataClassification = CustomerContent;
        }
        field(60058; "Web Weight Item"; Boolean)
        {
            Caption = 'Web Weight Item';
            DataClassification = CustomerContent;
        }
        field(60059; "Web Item Status"; Enum "eCom-Web Item Status_NT")
        {
            Caption = 'Web Item Status';
            DataClassification = CustomerContent;
        }
        field(60060; "Web Return Not Allowed"; Boolean)
        {
            Caption = 'Web Return Not Allowed';
            DataClassification = CustomerContent;
            Description = 'Considered from server 67 as Item Inventory OLD -> Marked as DELETE in 10.20.0.60';
        }
        field(60061; "Item Inventory"; Decimal)
        {
            Caption = 'Item Inventory';

            FieldClass = FlowField;
            CalcFormula = Sum("eCom_Item Inventory_NT".Inventory WHERE("Item No." = FIELD("No."), "Location Code" = FIELD("Location Filter")));
        }
        field(60062; "Every Day Low Price"; Boolean)
        {
            Caption = 'Every Day Low Price';
            DataClassification = CustomerContent;
        }

        field(60063; "Foody Item"; Boolean)
        {
            Caption = 'Foody Item';
            DataClassification = CustomerContent;
        }
        field(60064; "Web Always On Stock"; Boolean)
        {
            Caption = 'Web Always On Stock';
            DataClassification = CustomerContent;
        }
        field(60100; "No Loyalty Points"; Boolean)
        {
            Caption = 'No Loyalty Points';
            DataClassification = CustomerContent;
        }
        field(600065; "Web Special Offer"; Boolean)
        {
            Caption ='Web Special Offer';
            DataClassification = CustomerContent;
        }
        field(600066; "Pick Of The Week"; Boolean)
        {
            Caption = 'Pick Of The Week';
            DataClassification = CustomerContent;
        }
        field(600067; "Promoted Product"; Boolean)
        {
            Caption ='Promoted Product';
            DataClassification = CustomerContent;
        }
        field(600068; "Premium Package"; Boolean)
        {
            Caption = 'Premium Package';
            DataClassification = CustomerContent;
        }
        field(600069; "Compress When Scanned"; Boolean)
        {
            Caption = 'Compress When Scanned';
            DataClassification = CustomerContent;
        }
    

    }
    keys
    {
        key(Key1; "Web Item")
        {
        }
        key(KEY_NT2; "Foody Item")
        {
        }
        key(KEY_NT3; "Web Special Offer")
        {
        }
        key(KEY_NT4; "Pick Of The Week")
        {
        }
    }
}

