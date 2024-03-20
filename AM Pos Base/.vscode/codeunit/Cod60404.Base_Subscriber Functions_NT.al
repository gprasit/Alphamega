codeunit 60404 "Base_Subscriber Functions_NT"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Trans. Sales Entry", 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure OnAfterValidateItemNo(var Rec: Record "LSC Trans. Sales Entry"; var xRec: Record "LSC Trans. Sales Entry")
    var
        Item: Record Item;
    begin
        if not Item.Get(Rec."Item No.") then begin
            Rec."Item Department Code" := '';
            Rec."Item Vendor No." := '';
            Rec."Division Code" := '';
            Rec."Item Family Code" := '';
            exit;
        end;
        Rec."Item Department Code" := Item."Item Department Code";
        Rec."Item Vendor No." := Item."Vendor Item No.";
        Rec."Division Code" := Item."LSC Division Code";
        Rec."Item Family Code" := Item."LSC Item Family Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Published Offer", 'OnAfterValidateEvent', 'Discount No.', false, false)]
    local procedure OnAfterValidateDiscountNo(var Rec: Record "LSC Published Offer"; var xRec: Record "LSC Published Offer"; CurrFieldNo: Integer)
    var
        CouponHeader: Record "LSC Coupon Header";        
    begin
        case Rec."Discount Type" of
            Rec."Discount Type"::Coupon:
                begin
                    CouponHeader.Get(Rec."Discount No.");
                    case true of
                        CouponHeader."Member Attribute" <> '':
                            Rec."Offer Category" := Rec."Offer Category"::"Special Member";
                        CouponHeader."Member Value" <> '':
                            Rec."Offer Category" := Rec."Offer Category"::"Club and Scheme";
                        else
                            Rec."Offer Category" := Rec."Offer Category"::General;
                    end;
                    Rec."Member Attribute" := CouponHeader."Member Attribute";
                    Rec."Member Attribute Value" := CouponHeader."Member Attribute Value";
                end;
        end;
    end;

    var
        myInt: Integer;
}