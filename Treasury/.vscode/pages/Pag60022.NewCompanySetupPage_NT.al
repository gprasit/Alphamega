page 60022 NewCompanySetupPage_NT
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'AlphaMega New Company Setup';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(InputParam; InParam)
                {
                    ApplicationArea = All;
                    Caption = 'Input';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(StoreDimension)
            {
                Caption = 'Create Store Dimension';
                Promoted = true;
                PromotedCategory = Process;
                Image = CopyDimensions;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NewCmpSetupMgmt.AddStoreDimension();
                end;
            }
            action(TranSalesProdPostingGrp)
            {
                Caption = 'Update Trans. Sales Inv/Prod. Posting Group';
                Promoted = true;
                PromotedCategory = Process;
                Image = GeneralPostingSetup;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NewCmpSetupMgmt.UpdateTransSalesInvGenProdPostingGrp();
                end;
            }
            action(UPDIUOM)
            {
                Caption = 'Update Item Unit Of Measure';
                Promoted = true;
                PromotedCategory = Process;
                Image = GeneralPostingSetup;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NewCmpSetupMgmt.UpdateItemUOM();
                end;
            }
            action(UPDTender)
            {
                Caption = 'Update Tender Counting Required';
                Promoted = true;
                PromotedCategory = Process;
                Image = GeneralPostingSetup;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NewCmpSetupMgmt.MarkTendersCountingRequired();
                end;
            }
            action(UPDTransSalesStatus)
            {
                Caption = 'Update Trans. Sales Status';
                Promoted = true;
                PromotedCategory = Process;
                Image = GeneralPostingSetup;
                ApplicationArea = All;

                trigger OnAction()
                var
                    TransSalesStatus: Record "LSC Trans. Sales Entry Status";
                begin
                    if TransSalesStatus.FindSet() then
                        repeat
                            if TransSalesStatus.Status = TransSalesStatus.Status::"Items Posted" then begin
                                TransSalesStatus.Status := 0;
                                TransSalesStatus.Modify();
                            end;
                        until TransSalesStatus.Next() = 0;
                end;
            }
            action(ClearErrorMsgs)
            {
                Caption = 'Clear Error Register';
                Promoted = true;
                PromotedCategory = Process;
                Image = GeneralPostingSetup;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ErrorMsg: Record "Error Message";
                    ErrorMsgReg: Record "Error Message Register";
                begin
                    ErrorMsg.DeleteAll();
                    ErrorMsgReg.DeleteAll();
                end;
            }

            action(TestString)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    TxtBuilder: TextBuilder;
                    MyText: Text;
                begin
                    MyText := 'Test My&String With &';
                    TxtBuilder.Append(MyText);
                    TxtBuilder.Replace('&', '&amp;');
                    MyText := TxtBuilder.ToText();
                    Message(MyText);
                end;
            }
        }

    }

    var
        NewCmpSetupMgmt: Codeunit NewCompanySetupMgmt_NT;
        InParam: Code[20];
}