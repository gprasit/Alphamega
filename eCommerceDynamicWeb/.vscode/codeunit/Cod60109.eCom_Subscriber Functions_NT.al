codeunit 60109 "eCom_Subscriber Functions_NT"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnBeforeInsertToSalesLine', '', false, false)]
    local procedure OnBeforeInsertToSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; FromDocType: Option; RecalcLines: Boolean; var ToSalesHeader: Record "Sales Header"; DocLineNo: Integer; var NextLineNo: Integer; RecalculateAmount: Boolean);
    begin

        case FromSalesLine."Document Type" of

            FromSalesLine."Document Type"::"Blanket Order":
                ToSalesLine."From Document Type" := ToSalesLine."From Document Type"::"Blanket Order";

            FromSalesLine."Document Type"::"Credit Memo":
                ToSalesLine."From Document Type" := ToSalesLine."From Document Type"::"Credit Memo";

            FromSalesLine."Document Type"::Invoice:
                ToSalesLine."From Document Type" := ToSalesLine."From Document Type"::Invoice;

            FromSalesLine."Document Type"::Order:
                ToSalesLine."From Document Type" := ToSalesLine."From Document Type"::Order;

            FromSalesLine."Document Type"::Quote:
                ToSalesLine."From Document Type" := ToSalesLine."From Document Type"::Quote;

            FromSalesLine."Document Type"::"Return Order":
                ToSalesLine."From Document Type" := ToSalesLine."From Document Type"::"Return Order";
        end;
        ToSalesLine."From Document No." := FromSalesLine."Document No.";
        ToSalesLine."From Line No." := FromSalesLine."Line No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateReturnQtyToReceiveOnAfterCheck', '', false, false)]
    local procedure OnValidateReturnQtyToReceiveOnAfterCheck(var SalesLine: Record "Sales Line"; CurrentFieldNo: Integer);
    var
        _Item: Record Item;
    begin
        if not SalesLine."New Line" then
            if (CurrentFieldNo <> 0) AND
               (SalesLine.Type = SalesLine.Type::Item) and
               (SalesLine."Return Qty. to Receive" <> 0) then begin
                _Item.GET(SalesLine."No.");
                _Item.TESTFIELD("Web Return Not Allowed", false);
            end;
    end;

}
