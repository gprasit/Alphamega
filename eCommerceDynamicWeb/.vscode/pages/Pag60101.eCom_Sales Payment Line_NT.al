page 60101 "eCom_Sales Payment Line_NT"
{
    Caption = 'Sales Payment Line';
    PageType = List;
    SourceTable = "eCom_Sales Payment Line_NT";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Card Payment"; Rec."Card Payment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Payment field.';
                }
                field(Points; Rec.Points)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points field.';
                }
            }
        }
    }
}
