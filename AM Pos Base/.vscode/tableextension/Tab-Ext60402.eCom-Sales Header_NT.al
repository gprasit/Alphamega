tableextension 60402 "eCom-Sales Hedaer_NT" extends "Sales Header"
{
    fields
    {
        field(60000; "Member Contact No."; Code[20])
        {
            Caption = 'Member Contact No.';
            DataClassification = CustomerContent;
        }
        field(60001; "Order Time Slot"; Text[20])
        {
            Caption = 'Order Time Slot';
            DataClassification = CustomerContent;
        }
        field(60002; "Web Order Status"; Option)
        {
            Caption = 'Web Order Status';
            OptionMembers = " ",New,"Assigned for Picking",Picked,"Picked with Difference",Completed,Cancelled,Reversed,Delivered;
            DataClassification = CustomerContent;
        }
        field(60003; "Web Store No."; Code[10])
        {
            Caption = 'Web Store No.';
            DataClassification = CustomerContent;
        }
        field(60004; "Web Order Payment Status"; Option)
        {
            Caption = 'Web Order Payment Status';
            OptionMembers = " ",Pending,Failed,Completed,Cancelled,"Not Authorized",Refunded;
            DataClassification = CustomerContent;
        }
        field(60005; "Web Order Payment Order ID"; Code[10])
        {
            Caption = 'Web Order Payment Order ID';
            DataClassification = CustomerContent;
        }
        field(60006; "Web Order Payment Session ID"; Code[10])
        {
            Caption = 'Web Order Payment Session ID';
            DataClassification = CustomerContent;
        }
        field(60007; "Web Order Amount"; Decimal)
        {
            Caption = 'Web Order Amount';
            DataClassification = CustomerContent;
        }
        field(60008; "RCB Approval Code"; Code[10])
        {
            Caption = 'RCB Approval Code';
            DataClassification = CustomerContent;
        }
        field(60009; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(60010; "Receipt No."; Text[30])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(60011; Exported; Boolean)
        {
            Caption = 'Exported';
            DataClassification = CustomerContent;
        }
        field(60012; "Stick And Win Phone"; Text[30])
        {
            Caption = 'Stick And Win Phone';
            DataClassification = CustomerContent;
        }
        field(60013; "For Store No."; Code[10])
        {
            Caption = 'For Store No.';
            DataClassification = CustomerContent;
        }
        field(60014; "Web Order Delivery Longitude"; Text[30])
        {
            Caption = 'Web Order Delivery Longitude';
            DataClassification = CustomerContent;
        }
        field(60015; "Web Order Delivery Latitude"; Text[30])
        {
            Caption = 'Web Order Delivery Latitude';
            DataClassification = CustomerContent;
        }
        field(60016; "Sell-to Building Name"; Text[50])
        {
            Caption = 'Sell-to Building Name';
            DataClassification = CustomerContent;
        }
        field(60017; "Sell-to Flat No."; Text[10])
        {
            Caption = 'Sell-to Flat No.';
            DataClassification = CustomerContent;
        }
        field(60018; "Ship-to Building Name"; Text[50])
        {
            Caption = 'Ship-to Building Name';
            DataClassification = CustomerContent;
        }
        field(60019; "Ship-to Flat No."; Text[10])
        {
            Caption = 'Ship-to Flat No.';
            DataClassification = CustomerContent;
        }
        field(60020; "Web Order No."; Code[20])
        {
            Caption = 'Web Order No.';
            DataClassification = CustomerContent;
        }
        field(60021; "Actual Amount Charged"; Decimal)
        {
            Caption = 'Actual Amount Charged';
            DataClassification = CustomerContent;
        }
        field(60022; "Return Status"; Option)
        {
            Caption = 'Return Status';
            OptionMembers = " ","Ready for Approval",Approved,Completed;
            DataClassification = CustomerContent;
        }
        field(60023; "Original Store No."; Code[10])
        {
            Caption = 'Original Store No.';
            DataClassification = CustomerContent;
        }
        field(60024; "Coordinates Cheked"; Boolean)
        {
            Caption = 'Coordinates Cheked';
            DataClassification = CustomerContent;
        }
        field(60025; "Viva Capture Transaction Id"; Text[50])
        {
            Caption = 'Viva Capture Transaction Id';
            DataClassification = CustomerContent;
        }
        field(60026; "Web Order Transaction Id"; Text[50])
        {
            Caption = 'Web Order Transaction Id';
            DataClassification = CustomerContent;
        }
        field(60027; "Web Order Transaction Amount"; Decimal)
        {
            Caption = 'Web Order Transaction Amount';
            DataClassification = CustomerContent;
        }
        field(60028; "Web Order Payment Method"; Text[50])
        {
            Caption = 'Web Order Payment Method';
            DataClassification = CustomerContent;
        }
        field(60050; "Send For Approval Date"; Date)
        {
            Caption = 'Send For Approval Date';
            DataClassification = CustomerContent;
        }
        field(60051; "Approved Date"; Date)
        {
            Caption = 'Approved Date';
            DataClassification = CustomerContent;
        }
        field(60052; "Completed Date"; Date)
        {
            Caption = 'Completed Date';
            DataClassification = CustomerContent;
        }
        field(60053; "Refund Date"; Date)
        {
            Caption = 'Refund Date';
            DataClassification = CustomerContent;
        }
        field(60054; "Ship-to House No."; Text[30])
        {
            Caption = 'Ship-to House No.';
            DataClassification = CustomerContent;
            Description = 'Added as Field 10012729 Removed in BC';
        }
        field(60055; "Phone No."; Text[30])
        {
            DataClassification = CustomerContent;
            Description = 'Added as Field 10012755 Removed in BC';
        }
        field(60056; "Mobile Phone No."; Text[30])
        {
            Caption = 'Mobile Phone No.';
            DataClassification = CustomerContent;
            Description = 'Added as Field 10012757 Removed in BC';
        }
        field(60057; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            Description = 'Added as Field 10012758 Removed in BC';
        }
        field(60058; "Ship-To Telephone"; Text[30])
        {
            Caption = 'Ship-To Telephone';
            DataClassification = CustomerContent;
            Description = 'Added as Field 10012701 Removed in BC';
        }
        field(60059; "Order Shipping Method"; Text[30])
        {
            Caption ='Order Shipping Method';
            DataClassification = CustomerContent;
        }
        field(60070; Delivery; Boolean)
        {
            Caption ='Delivery';
            DataClassification = CustomerContent;
        }
        field(60071; "Web Order Completed Time"; Text[20])
        {
            Caption ='Web Order Completed Time';
            DataClassification = CustomerContent;
        }
        field(60072; "Invoice Discount %"; Decimal)
        {
            Caption ='Invoice Discount %';
            DataClassification = CustomerContent;
        }
        field(60073; "Inv. Discount Amount"; Decimal)
        {
            Caption ='Inv. Discount Amount';
            DataClassification = CustomerContent;
        }
    }
}
