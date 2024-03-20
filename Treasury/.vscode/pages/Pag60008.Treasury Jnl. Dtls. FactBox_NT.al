page 60008 "Treasury Jnl. Dtls. FactBox_NT"
{
    PageType = CardPart;
    Caption = 'Treasury Journal Line Details';
    Editable = false;
    LinksAllowed = false;
    SourceTable = "Treasury Journal Line_NT";

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
                    var
                        GenJnlLine: Record "Gen. Journal Line";
                    begin
                        GenJnlLine.Init();
                        case Rec."Acc. Type" of
                            Rec."Acc. Type"::"G/L Account":
                                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                            Rec."Acc. Type"::Customer:
                                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                            Rec."Acc. Type"::Vendor:
                                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;

                        end;
                        GenJnlLine.Validate("Account No.", Rec."Account No.");
                        Codeunit.Run(Codeunit::"Gen. Jnl.-Show Card", GenJnlLine);
                    end;
                }
            }
            group(ReasonCode)
            {
                Caption = 'Reason Code';
                field(ReasonCodeDescription; ReasonCodeDesc)
                {
                    ApplicationArea = all;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies description of the reason code that has been entered on the journal line.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        TreasuryMgmt.GetAccounts(Rec, AccName, TenderName, ReasonCodeDesc);
    end;

    var
        TreasuryMgmt: Codeunit "Treasury Management_NT";
        AccName: Text[100];
        TenderName: Text[30];
        ReasonCodeDesc: Text[100];
}