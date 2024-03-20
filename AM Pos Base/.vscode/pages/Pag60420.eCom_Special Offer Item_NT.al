page 60420 "eCom_Special Offer Item_NT"
{
    ApplicationArea = All;
    Caption = 'eCommerce Special Offer Item';
    PageType = List;
    SourceTable = "eCom_Special Offer Item_NT";
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
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Description field.';
                }
                field("Offer Item No."; Rec."Offer Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Offer Item No. field.';
                }
                field("Offer Item Description"; Rec."Offer Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Offer Item Description field.';
                }
            }
        }
    }
}
