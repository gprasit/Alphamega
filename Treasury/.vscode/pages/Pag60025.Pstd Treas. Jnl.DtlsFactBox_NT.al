page 60025 "Pstd Treas. Jnl.DtlsFactBox_NT"
{
    PageType = CardPart;
    Caption = 'Line Details';
    Editable = false;
    LinksAllowed = false;
    SourceTable = "Posted Treasury Jnl. Line_NT";

    layout
    {
        area(Content)
        {
            group(statement)
            {
                Caption = 'Statement';
                field(TreasStmtNo; Rec."Treasury Statement No.")
                {
                    ApplicationArea = all;
                    Caption = 'No.';
                    Editable = false;
                    ToolTip = 'Specifies the Treasury Statment No.';
                }
                field(TreasStmtLineNo; Rec."Treasury Stmt. Line No.")
                {
                    ApplicationArea = all;
                    Caption = 'Statement Line No.';
                    Editable = false;
                    ToolTip = 'Specifies the Treasury Statment Line No.';
                }
            }
            group(Tender)
            {
                Caption = 'Tender';
                field(TenderTypeName; TenderName)
                {
                    ApplicationArea = all;
                    Caption = 'Tender Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the tender that has been entered on the journal line.';
                }
            }
            group(Account)
            {
                Caption = 'Account';
                field(AccountName; AccName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account Name';
                    Editable = false;
                    ToolTip = 'Specifies the account name that the entry on the journal line will be posted to.';

                    trigger OnDrillDown()
                    begin
                        Codeunit.Run(Codeunit::"Gen. Jnl.-Show Card", Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName);
    end;

    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        AccName: Text[100];
        TenderName: Text[30];
}