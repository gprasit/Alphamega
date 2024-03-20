pageextension 60103 "eCom_Sales Return Order_NT" extends "Sales Return Order"
{
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Invoice,Request Approval,Print/Send,Return Order,Navigate,eCommerce';
    layout
    {
        // Add changes to page layout here
        addbefore("Posting Date")
        {
            field("Web Order Payment Session ID"; Rec."Web Order Payment Session ID")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("Web Order Amount"; Rec."Web Order Amount")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("Web Order Refund Amount"; eComOrderMgt.GetOrderAmount(Rec))
            {
                ApplicationArea = all;
                Editable = false;
                Style = Attention;
                StyleExpr = true;
            }
            field("Web Order Other Payment Amount"; eComOrderMgt.GetOrderOtherAmount(Rec))
            {
                ApplicationArea = all;
                Caption = 'Other Payment Amount';
                Editable = false;
            }
            field("Web Store No."; Rec."Web Store No.")
            {
                ApplicationArea = All;

            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("Request Approval")
        {
            group(eCommerceDynamicWeb)
            {
                Caption = 'e-Commerce';
                Image = LinkWeb;
                action(RefundWebOrdVIVA)
                {
                    ApplicationArea = All;
                    Caption = 'Refund Web Order Viva Wallet';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category13;
                    trigger OnAction()
                    begin
                        Clear(eComOrderMgt);
                        eComOrderMgt.RefundPaymentVivaWallet(Rec);
                    end;
                }
                action(CreateTrans)
                {
                    Caption = 'Create Transaction';
                    ApplicationArea = All;
                    Image = Transactions;
                    Promoted = true;
                    PromotedCategory = Category13;
                    trigger OnAction()
                    begin
                        CLEAR(eComOrderMgt);
                        IF (Rec."Web Order Payment Status" = Rec."Web Order Payment Status"::Refunded) then begin
                            IF CONFIRM('Create transaction?') THEN BEGIN
                                eComOrderMgt.CreateTransaction(Rec);
                                CurrPage.Update();
                            END;
                        END
                        ELSE
                            Message('Web Order Payment Status must be Refunded. Please refund transaction and retry.');
                    end;
                }
                action(RetAllLines)
                {
                    Caption = 'Return All Lines';
                    ApplicationArea = All;
                    Image = CancelAllLines;
                    Promoted = true;
                    PromotedCategory = Category13;
                    trigger OnAction()
                    begin
                        clear(eComOrderMgt);
                        eComOrderMgt.ReturnAllLines(Rec);
                    end;
                }

            }
        }
    }
    var
        eComOrderMgt: Codeunit "eCom_Order Management_NT";
}