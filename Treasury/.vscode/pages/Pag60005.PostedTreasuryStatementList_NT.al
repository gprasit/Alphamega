page 60005 "Posted Treasury Stmt. List_NT"
{
    ApplicationArea = All;
    Caption = 'Posted Treasury Statement List';
    CardPageId = "Posted Treasury Statement_NT";
    PageType = List;
    Editable = false;
    SourceTable = "Posted Treasury Statement_NT";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Treasury Statement No."; Rec."Treasury Statement No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = All;
                }
                field("Store Hierarchy No."; Rec."Store Hierarchy No.")
                {
                    ToolTip = 'Specifies the value of the Store Hierarchy No. field.';
                    ApplicationArea = All;
                }
                field("Store Hierarchy Name"; Rec."Store Hierarchy Name")
                {
                    ToolTip = 'Specifies the value of the Store Hierarchy Name field.';
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                    ApplicationArea = All;
                }
                field("Trans. Starting Date"; Rec."Trans. Starting Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Starting Date field.';
                    ApplicationArea = All;
                }
                field("Trans. Ending Date"; Rec."Trans. Ending Date")
                {
                    ToolTip = 'Specifies the value of the Trans. Ending Date field.';
                    ApplicationArea = All;
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Recalculate; Rec.Recalculate)
                {
                    ToolTip = 'Specifies the value of the Recalculate field.';
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnInit()
    var
        RetailUser: Record "LSC Retail User";
    begin
        Rec.FilterGroup(2);
        if RetailUser.Get(UserId) then
            if RetailUser."Store Hierarchy No." <> '' then
                Rec.SetRange("Store Hierarchy No.", RetailUser."Store Hierarchy No.");
        Rec.FilterGroup(0);
    end;
}
