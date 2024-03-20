pageextension 60102 "eCom_Sales Order_NT" extends "Sales Order"
{
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Order,Request Approval,History,Print/Send,Navigate,eCommerce';
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            group(eCommerce)
            {
                Caption = 'eCommerce';
                field("Member Contact No."; Rec."Member Contact No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("LSC Member Card No."; Rec."LSC Member Card No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Web Order Status"; Rec."Web Order Status")
                {
                    ApplicationArea = All;
                }
                field("Web Order Payment Status"; Rec."Web Order Payment Status")
                {
                    ApplicationArea = All;
                }
                field("Inv. Discount Amount";Rec."Inv. Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;                    
                }
                field("Web Order Amount"; Rec."Web Order Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Card Payment Amount"; eComOrdMgt.GetOrderAmount(Rec))
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Other Payment Amount"; eComOrdMgt.GetOrderOtherAmount(Rec))
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Web Order Transaction Id"; Rec."Web Order Transaction Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Web Order Transaction Amount"; Rec."Web Order Transaction Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                }
                field("Web Store No."; Rec."Web Store No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Web Order Payment Method"; Rec."Web Order Payment Method")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Exported; Rec.Exported)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Order Confirmation")
        {
            group(eCommerceDynamicWeb)
            {
                Caption = 'e-Commerce';
                Image = LinkWeb;
                action(ChangeLoc)
                {
                    Caption = 'Change Location';
                    ApplicationArea = All;
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = Category13;
                    trigger OnAction()
                    var
                        GeneralFn: Codeunit "eCom_General Functions_NT";
                    begin
                        GeneralFn.ChangeSalesLineLoc(Rec);
                    end;
                }
                action(CompleteWebOrdVIVA)
                {
                    ApplicationArea = All;
                    Caption = 'Complete Web Order Viva Wallet';
                    Image = Payment;
                    Promoted = true;
                    PromotedCategory = Category13;
                    trigger OnAction()
                    begin
                        Clear(eComOrdMgt);
                        eComOrdMgt.CompletePaymentVivaWallet(Rec);
                    end;
                }
                action(RefundWebOrdVIVA)
                {
                    ApplicationArea = All;
                    Caption = 'Refund Web Order Viva Wallet';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category13;
                    trigger OnAction()
                    begin
                        Clear(eComOrdMgt);
                        eComOrdMgt.RefundPaymentVivaWallet(Rec);
                    end;
                }
                action(CancelWebOrdVIVA)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Web Order Viva Wallet';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category13;
                    trigger OnAction()
                    begin
                        Clear(eComOrdMgt);
                        eComOrdMgt.CancelOrderVivaWallet(Rec);
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
                        CLEAR(eComOrdMgt);
                        IF CONFIRM('Create transaction?') THEN
                            eComOrdMgt.CreateTransaction(Rec);
                    end;
                }
                action(ReverseTrans)
                {
                    Caption = 'Reverse Transaction';
                    ApplicationArea = All;
                    Image = Transactions;
                    Promoted = true;
                    PromotedCategory = Category13;
                    trigger OnAction()
                    begin
                        CLEAR(eComOrdMgt);
                        IF CONFIRM('Reverse transaction?') THEN
                            eComOrdMgt.ReverseTransaction(Rec);
                    end;
                }
                action(SalesPmtLines)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Payment Line';
                    Image = EditLines;
                    Promoted = true;
                    PromotedCategory = Category13;
                    RunObject = page "eCom_Sales Payment Line_NT";
                    RunPageView = sorting("Document Type", "Document No.", "Line No.");
                    RunPageLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                }
                group("&ReturnOrder")
                {
                    Caption = 'Sales Return Order';
                    Image = Return;
                    action(CreateReturnOrder)
                    {
                        ApplicationArea = All;
                        Caption = 'Create Sales Return Order';
                        Image = ReturnOrder;
                        Promoted = true;
                        PromotedCategory = Category13;
                        ToolTip = 'Create Sales return order for returning/canceling the sales order.';

                        trigger OnAction()
                        var
                            eComGenFn: codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.CreateSalesReturnOrder(Rec);
                        end;
                    }
                    action(ViewReturnOrder)
                    {
                        ApplicationArea = All;
                        Caption = 'View Sales Return Order';
                        Image = ViewOrder;
                        Promoted = true;
                        PromotedCategory = Category13;
                        ToolTip = 'View Sales return order created for returning/canceling the sales order.';

                        trigger OnAction()
                        var
                            eComGenFn: codeunit "eCom_General Functions_NT";
                        begin
                            eComGenFn.OpenSalesReturnOrder(Rec);
                        end;
                    }
                }
            }
        }
    }

    var
        eComOrdMgt: codeunit "eCom_Order Management_NT";

}