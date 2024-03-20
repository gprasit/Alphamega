page 60408 "eVch_Posted eVoucher List_NT"
{
    ApplicationArea = All;
    Caption = 'Posted eVoucher List';
    PageType = List;
    SourceTable = "eVch_eVoucher Header_NT";
    SourceTableView = sorting(Status) where(Status=const(Posted));
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "eVch_Posted eVoucher Card_NT";
    

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice No. field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field.';
                }
            }
        }
    }
}
