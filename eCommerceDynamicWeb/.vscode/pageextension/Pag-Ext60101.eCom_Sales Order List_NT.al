pageextension 60101 "eCom_Sales Order List_NT" extends "Sales Order List"
{
    PromotedActionCategories = 'New,Process,Report,Request Approval,Order,Release,Posting,Print/Send,Navigate,eCommerce';
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        //addafter(Display)
        addbefore("F&unctions")
        {
            group(eCommerceDynamicWeb)
            {
                Caption = 'e-Commerce';
                Image = LinkWeb;
                action(ProcFinOrd)
                {
                    Caption = 'Process Finished Orders';
                    Image = Process;
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Category10;
                    trigger OnAction()
                    var
                        SchedulerJobHeader: Record "LSC Scheduler Job Header";
                        eComProcessOrders: Codeunit "eCom_Process Orders_NT";
                        RetailUser: Record "LSC Retail User";
                    begin
                        IF RetailUser.GET(USERID) THEN
                            SchedulerJobHeader.Code := RetailUser."Store No.";
                        SchedulerJobHeader.Integer := 1;
                        eComProcessOrders.RUN(SchedulerJobHeader);
                    end;
                }
                action(ChangeLoc)
                {
                    Caption = 'Change Location';
                    ApplicationArea = All;
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = Category10;
                    trigger OnAction()
                    var
                        GeneralFn: Codeunit "eCom_General Functions_NT";
                    begin
                        GeneralFn.ChangeSalesLineLoc(Rec);
                    end;
                }
            }
        }
    }
    var
}
