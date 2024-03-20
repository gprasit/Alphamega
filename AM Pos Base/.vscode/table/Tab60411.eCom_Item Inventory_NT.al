table 60411 "eCom_Item Inventory_NT"
{
    Caption = 'Item Inventory';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;

        }
        field(3; Inventory; Decimal)
        {
            Caption = 'Inventory';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
    }
    keys
    {
        key(PK; "Location Code","Item No.")
        {
            Clustered = true;
        }
    }
}
