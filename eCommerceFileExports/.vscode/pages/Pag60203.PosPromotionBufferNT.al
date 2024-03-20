page 60203 "Pos_Promotion Buffer_NT"
{
    ApplicationArea = All;
    Caption = 'Promotion Buffer';
    PageType = List;
    SourceTable = "Pos_Promotion Buffer_NT";
    UsageCategory = History;
    //Editable = false;
    // DeleteAllowed = false;
    // InsertAllowed = false;
    // ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Curent Action"; Rec."Curent Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Curent Action field.';
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                }
                field("Item Free"; Rec."Item Free")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Free field.';
                }
                field("Item Free Quantity"; Rec."Item Free Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Free Quantity field.';
                }
                field("Item Required"; Rec."Item Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Required field.';
                }
                field("Item Required Quantity_Txt"; Rec."Item Required Quantity_Txt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Required Quantity_Txt field.';
                }
                field("Item Required Quantity_Dec"; Rec."Item Required Quantity_Dec")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Required Quantity_Dec field.';
                }
                field("Promotion Event Category"; Rec."Promotion Event Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Event Category field.';
                }
                field("Promotion Event Description"; Rec."Promotion Event Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Event Description field.';
                }
                field("Promotion Event Number"; Rec."Promotion Event Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Event Number field.';
                }
                field("Promotion From Date"; Rec."Promotion From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion From Date field.';
                }
                field("Promotion To Date"; Rec."Promotion To Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion To Date field.';
                }
                field("Promotion Type"; Rec."Promotion Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Type field.';
                }
                field("Discount Percentage"; Rec."Discount Percentage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Percentage field.';
                }
                field("Discount Percentage_Dec"; Rec."Discount Percentage_Dec")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Percentage_Dec field.';
                }
                field("Promotion Group"; Rec."Promotion Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Group field.';
                }
                field("Promotion Identifier"; Rec."Promotion Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Identifier field.';
                }
                field("Promotion Limit"; Rec."Promotion Limit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Limit field.';
                }
                field("Promotion Price"; Rec."Promotion Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Price field.';
                }
                field("Promotion Receipt Line"; Rec."Promotion Receipt Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promotion Receipt Line field.';
                }
                field("Event Category Description"; Rec."Event Category Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Category Description field.';
                }
                field(Points; Rec.Points)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points field.';
                }
                field(Pillar; Rec.Pillar)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pillar field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UpdateMixAndMatch)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    PerDisc: Record "LSC Periodic Discount";
                begin
                    PerDisc.SetCurrentKey(Status, Type);
                    PerDisc.SetRange(Status, PerDisc.Status::Enabled);
                    PerDisc.SetRange(Type, PerDisc.Type::"Mix&Match");
                    PerDisc.SetRange("Created From Promotion File",true);
                    if PerDisc.FindSet() then
                        repeat
                            if PerDisc."Discount Offer No." = '' then begin
                                PerDisc."Discount Offer No." := PerDisc."No.";
                                PerDisc.Modify();
                            end;
                        until PerDisc.Next() = 0;
                end;
            }
        }

    }

}



