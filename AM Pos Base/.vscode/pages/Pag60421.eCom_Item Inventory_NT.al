page 60421 "eCom_Item Inventory_NT"
{
    ApplicationArea = All;
    Caption = 'eCommerce Item Inventory';
    PageType = List;
    SourceTable = "eCom_Item Inventory_NT";
    UsageCategory = Administration;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory field.';
                }
            }
        }
    }
}
