codeunit 60318 "NT_Point Jnl.-Check Line"
{    
    TableNo = "LSC Member Point Jnl. Line";

    trigger OnRun()
    begin
        RunLineCheck(Rec);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        Text001: Label 'Journal Batch Name    #1##########\\';
        Text004: Label 'Checking lines        #2######  @4@@@@@@@@@@@@@';
        Text005: Label 'The Balance for Account %1 will be negative after posting.';
        Text006: Label 'The Account %1 is blocked.';
        Text007: Label 'The Transfer To Account No. is missing, the Account no. is %1.\\Please use Point Transfer Journals for transfers.';
        Text008: Label 'The Transfer To Account %1 is blocked.';
        Text009: Label 'The date is missing.';
        Text010: Label 'Transfer is only allowed between to accounts in same club.\Account %1 and Account %2 are not in same club.';
        Text012: Label 'is not within your range of allowed posting dates.';
        Text013: Label 'Test posting processed without errors.';
        AllowNegativeBalance: Boolean;

    procedure RunLineCheck(var PointJnlLine: Record "LSC Member Point Jnl. Line")
    var
        AccountRec: Record "LSC Member Account";
        ClubRec: Record "LSC Member Club";
        Points: Decimal;
    begin
        case PointJnlLine.Type of
            PointJnlLine.Type::Sales:
                Points := PointJnlLine.Points;
            PointJnlLine.Type::Redemption:
                Points := -PointJnlLine.Points;
            PointJnlLine.Type::"Pos. Adjustment":
                Points := PointJnlLine.Points;
            PointJnlLine.Type::"Neg. Adjustment":
                Points := -PointJnlLine.Points;
            PointJnlLine.Type::Transfer:
                Points := -PointJnlLine.Points;
        end;

        AccountRec.Get(PointJnlLine."Account No.");
        ClubRec.Get(AccountRec."Club Code");
        AccountRec.CalcFields(Balance);

        if not AllowNegativeBalance then
            if (AccountRec.Balance + Points) < 0 then
                Error(Text005, AccountRec."No.");

        if AccountRec.Blocked then
            Error(Text006, AccountRec."No.");

        if PointJnlLine.Type = PointJnlLine.Type::Transfer then begin
            if PointJnlLine."Transfer To Account No." = '' then
                Error(Text007, PointJnlLine."Account No.");

            AccountRec.Get(PointJnlLine."Transfer To Account No.");
            if AccountRec.Blocked then
                Error(Text008, AccountRec."No.");

            if AccountRec."Club Code" <> ClubRec.Code then
                Error(Text010, PointJnlLine."Account No.", PointJnlLine."Transfer To Account No.");
        end;

        if PointJnlLine.Date = 0D then
            Error(Text009);

        if DateNotAllowed(PointJnlLine.Date) then
            PointJnlLine.FieldError(Date, Text012);
    end;

    procedure RunJournalCheck(JournalLine: Record "LSC Member Point Jnl. Line"; RunFromPosting: Boolean)
    var
        AccountRec: Record "LSC Member Account";
        ClubRec: Record "LSC Member Club";
        JournalLine2: Record "LSC Member Point Jnl. Line";
        Window: Dialog;
        NoOfRec: Integer;
        CurrNo: Integer;
        PlusPoints: Decimal;
        NegPoints: Decimal;
    begin
        JournalLine.SetRange("Journal Template Name", JournalLine."Journal Template Name");
        JournalLine.SetRange("Journal Batch Name", JournalLine."Journal Batch Name");
        NoOfRec := JournalLine.Count;

        if not RunFromPosting and GuiAllowed then begin
            Window.Open(Text001 + Text004);
            Window.Update(1, JournalLine."Journal Batch Name");
            NoOfRec := JournalLine.Count;
        end;

        CurrNo := 0;
        if JournalLine.FindSet then
            repeat
                CurrNo := CurrNo + 1;
                if GuiAllowed and not RunFromPosting then begin
                    Window.Update(2, JournalLine."Line No.");
                    Window.Update(4, Round(CurrNo / NoOfRec * 10000, 1));
                end;

                JournalLine2.SetRange("Account No.", JournalLine."Account No.");
                JournalLine2.SetRange("Journal Template Name", JournalLine."Journal Template Name");
                JournalLine2.SetRange("Journal Batch Name", JournalLine."Journal Batch Name");
                NegPoints := 0;
                PlusPoints := 0;
                if JournalLine2.FindSet then
                    repeat
                        case JournalLine2.Type of
                            JournalLine2.Type::Sales:
                                PlusPoints := PlusPoints + JournalLine2.Points;
                            JournalLine2.Type::Redemption:
                                NegPoints := NegPoints + JournalLine2.Points;
                            JournalLine2.Type::"Pos. Adjustment":
                                PlusPoints := PlusPoints + JournalLine2.Points;
                            JournalLine2.Type::"Neg. Adjustment":
                                NegPoints := NegPoints + JournalLine2.Points;
                            JournalLine2.Type::Transfer:
                                NegPoints := NegPoints + JournalLine2.Points;
                        end;
                    until JournalLine2.Next = 0;

                AccountRec.Get(JournalLine."Account No.");
                ClubRec.Get(AccountRec."Club Code");
                AccountRec.CalcFields(Balance);
                //NT Start
                /*
                if AccountRec.Balance < (NegPoints - PlusPoints) then
                    Error(Text005, AccountRec."No.");
                */
                //NT End

                if AccountRec.Blocked then
                    Error(Text006, AccountRec."No.");

                if JournalLine.Type = JournalLine.Type::Transfer then begin
                    if JournalLine."Transfer To Account No." = '' then
                        Error(Text007, JournalLine."Account No.");
                    AccountRec.Get(JournalLine."Transfer To Account No.");
                    if AccountRec.Blocked then
                        Error(Text008, AccountRec."No.");
                    if AccountRec."Club Code" <> ClubRec.Code then
                        Error(Text010, JournalLine."Account No.", JournalLine."Transfer To Account No.");
                end;

                if JournalLine.Date = 0D then
                    Error(Text009);

                if DateNotAllowed(JournalLine.Date) then
                    JournalLine.FieldError(Date, Text012);
            until JournalLine.Next = 0;

        if not RunFromPosting and GuiAllowed then begin
            Window.Close;
            Message(Text013);
        end;
    end;

    procedure DateNotAllowed(PostingDate: Date): Boolean
    begin
        if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
            if UserId <> '' then
                if UserSetup.Get(UserId) then begin
                    AllowPostingFrom := UserSetup."Allow Posting From";
                    AllowPostingTo := UserSetup."Allow Posting To";
                end;
            if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                GLSetup.Get;
                AllowPostingFrom := GLSetup."Allow Posting From";
                AllowPostingTo := GLSetup."Allow Posting To";
            end;
            if AllowPostingTo = 0D then
                AllowPostingTo := 99991231D;
        end;
        exit((PostingDate < AllowPostingFrom) or (PostingDate > AllowPostingTo));
    end;

    procedure SetAllowNegativeBalance()
    begin
        AllowNegativeBalance := true;
    end;
}


