xmlport 60107 "Create Voucher_XMLResponse_NT"
{
    Caption = 'Create Voucher Response';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    schema
    {
        //textelement(CreateVoucherResponse2)
        //{
        textelement(RootCreateVoucher)
        {
            textelement(Success)
            {
                trigger OnBeforePassVariable()
                begin
                    Success := SuccessVal;
                end;
            }
            textelement(VoucherNo)
            {
                trigger OnBeforePassVariable()
                begin
                    VoucherNo := VoucherNoVal;
                end;
            }
            textelement(VoucherStatus)
            {
                trigger OnBeforePassVariable()
                begin
                    VoucherStatus := VoucherStatusVal;
                end;
            }

            textelement(Error)
            {
                trigger OnBeforePassVariable()
                begin
                    Error := ErrorVal;
                end;
            }
            textelement(Error2)
            {
            }
            textelement(Owner)
            {
            }
            textelement(RedemptionDate)
            {
            }
            textelement(RedemedByCompany)
            {
            }
            textelement(ItemDescription)
            {
            }
            textelement(RedemedByStore)
            {
            }
        }
        //}
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    procedure SetResponseValues(Success: Text; VoucherNo: Text; VoucherStatus: Text; ErrorMsg: Text)
    begin
        SuccessVal := Success;
        VoucherNoVal := VoucherNo;
        VoucherStatusVal := VoucherStatus;
        ErrorVal := ErrorMsg;
    end;

    var
        SuccessVal: Text;
        VoucherNoVal: Text;
        VoucherStatusVal: Text;
        ErrorMessage2Val: Text;
        ErrorVal: Text;
}
