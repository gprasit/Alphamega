pageextension 60310 "Pos_Topup Setup_NT" extends "Pos_Topup Setup_NT"
{
    layout
    {
    }

    actions
    {
        addlast(processing)
        {
            group(Activate)
            {
                action(ActivateTopUpAccount)
                {
                    Caption ='Activate Account';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    Image = LinkAccount;
                    ToolTip ='Activate Topup Account';
                    trigger OnAction()
                    var
                        TopupMgt: Codeunit "Pos_Topup Management_NT";
                    begin
                        TopupMgt.ActivateAccount();
                    end;
                }
                action(ActivateTopUpLoc)
                {
                    Caption ='Activate Location';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    Image = Process;
                    ToolTip ='Activate Topup Location';
                    trigger OnAction()
                    var
                        TopupMgt: Codeunit "Pos_Topup Management_NT";
                    begin
                        TopupMgt.ActivateLocation();
                    end;
                }
            }
        }
    }

    var
        myInt: Integer;
}