pageextension 60003 "Open Statement_NT" extends "LSC Open Statement"
{
    layout
    {
        // Add changes to page layout here
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            var
                TreasuryMgmt: Codeunit "Treasury Management_NT";
            begin
                TreasuryMgmt.TreasStmtRecalculateOnStatementChange(Rec);
            end;
        }
        modify("Staff/POS Term Filter Internal")
        {
            Visible = false;
            trigger OnAfterValidate()
            var
                TreasuryMgmt: Codeunit "Treasury Management_NT";
            begin
                TreasuryMgmt.TreasStmtRecalculateOnStatementChange(Rec);
            end;
        }
        modify("Trans. Starting Date")
        {
            trigger OnAfterValidate()
            var
                TreasuryMgmt: Codeunit "Treasury Management_NT";
            begin
                TreasuryMgmt.TreasStmtRecalculateOnStatementChange(Rec);
            end;
        }
        modify("Trans. Ending Date")
        {
            trigger OnAfterValidate()
            var
                TreasuryMgmt: Codeunit "Treasury Management_NT";
            begin
                TreasuryMgmt.TreasStmtRecalculateOnStatementChange(Rec);
            end;
        }
        modify("Trans. Starting Time")
        {
            trigger OnAfterValidate()
            var
                TreasuryMgmt: Codeunit "Treasury Management_NT";
            begin
                TreasuryMgmt.TreasStmtRecalculateOnStatementChange(Rec);
            end;
        }
        modify("Trans. Ending Time")
        {
            trigger OnAfterValidate()
            var
                TreasuryMgmt: Codeunit "Treasury Management_NT";
            begin
                TreasuryMgmt.TreasStmtRecalculateOnStatementChange(Rec);
            end;
        }
        modify(StatementLineForm)
        {
            Visible = false;
        }
        addafter("Posting Date")
        {
            field(StaffPosFilter; StaffPosFilter)
            {
                Caption = 'Staff/POS Term Filter';
                ApplicationArea = All;
                trigger OnLookup(var Text: Text): Boolean
                var
                    TreasMgmt: Codeunit "Treasury Management_NT";
                begin
                    TreasMgmt."LookupStatementStaff/POS"(Rec, StaffPosFilter);
                    StaffPosFilterOnValidate();
                end;

                trigger OnValidate()
                var
                begin
                    StaffPosFilterOnValidate();
                end;
            }
            field(StaffName; FullName)
            {
                ApplicationArea = All;
                Caption = 'Staff Name';
                Editable = false;
            }
        }
        addafter(Warnings)
        {
            field("Total Counted Amount"; LineAmt[1])
            {
                ApplicationArea = All;
                Caption = 'Total Counted Amount';
                Editable = false;
            }
            field("Total Trans. Amount"; LineAmt[2])
            {
                ApplicationArea = All;
                Caption = 'Total Trans. Amount';
                Editable = false;
            }
            field("Total Difference Amount"; LineAmt[3])
            {
                ApplicationArea = All;
                Caption = 'Total Difference Amount';
                Editable = false;
            }
            field("Z-Amount"; Rec."Z-Amount")
            {
                ApplicationArea = All;
                BlankZero = true;
                Editable = false;
            }
            field(Finish; Rec.Finish)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that Counted amount is updated for this statement when checked';
            }
        }

        addbefore(SafeStatementLineForm)
        {
            part(StatementLineForm_NT; "LSC Statement Lines")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
                SubPageLink = "Statement No." = FIELD("No."),
                              "Statement Code" = FIELD("Staff/POS Terminal Filter"),
                              "Store No." = FIELD("Store No.");
                SubPageView = sorting("Statement No.", "Statement Code", "Staff ID", "POS Terminal No.", "Tender Type", "Tender Type Card No.", "Currency Code");
            }
        }
        addafter(StatementLineForm_NT)
        {
            part(StatementZReportLines; "Statement Z Report-Lines_NT")
            {
                ApplicationArea = All;
                SubPageLink = "Statement No." = FIELD("No."),
                              "Statement Code" = FIELD("Staff/POS Terminal Filter");
                SubPageView = sorting("Staff ID");
            }
        }
    }
    actions
    {
        addafter("Check &Transactions")
        {
            action("&UpdateCountedAmount")
            {
                Caption = '&Update Counted Amount';
                Promoted = true;
                Image = Process;
                ApplicationArea = all;
                trigger OnAction()
                var
                    TreasMgmt: Codeunit "Treasury Management_NT";
                begin
                    TreasMgmt.UpdateStatementCountedAmt(Rec);
                end;
            }
        }
        addafter("C&alculate Statement")
        {
            action("Calculate Statment AlphaMega")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    StatementCalculate: Codeunit "Statement-Calculate_NT";
                begin
                    StatementCalculate.Run(Rec);
                    Clear(StatementCalculate);
                end;
            }
        }
        addafter("Serial/Lot &No. Not Valid")
        {
            action("&StaffPOS")
            {
                Caption = 'Staff Pos Terminals';
                ToolTip = 'View staff wise POS Terminals where transactions included in this statement were entered.';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = ViewDetails;
                RunObject = page "Stmt._Staff POS Terminal_NT";
                RunPageLink = "Statement No." = field("No.");
            }
            action("&FinishEntry")
            {
                Caption = 'Finish';
                ToolTip = 'Mark statment when Counted amount is updated and unamrk if not updated.';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = ReleaseDoc;
                trigger OnAction()
                var
                    TreasuryGenFn: Codeunit "Treasury General Functions_NT";
                begin
                    TreasuryGenFn.MarkStatementAsFinnished(Rec);
                    CurrPage.Update(true);
                end;
            }
        }

    }
    local procedure StaffPosFilterOnValidate()
    var
        PosTerm: Record "LSC POS Terminal";
        Staff: Record "LSC Staff";
        TreasuryGenFn: Codeunit "Treasury General Functions_NT";
    begin
        if StaffPosFilter <> '' then
            if Rec.Method = Rec.Method::Staff then begin
                if not Staff.Get(StaffPosFilter) then
                    StaffPosFilter := '';
            end else
                if Rec.Method = Rec.Method::"POS Terminal" then
                    PosTerm.Get(StaffPosFilter);

        if StaffPosFilter <> '' then
            Rec.SetFilter("Staff/POS Terminal Filter", StaffPosFilter)
        else
            Rec.SetFilter("Staff/POS Terminal Filter", '*');
        FullName := TreasuryGenFn.StaffName(StaffPosFilter);
        StaffPOSTermFilterOnAfterValidate();
    end;

    local procedure StaffPOSTermFilterOnAfterValidate()
    begin
        CurrPage.Update(true);
    end;

    local procedure CalcCountedAmt()
    var
        StatementLines: Record "LSC Statement Line";
    begin
        Clear(LineAmt);
        StatementLines.SetFilter("Statement No.", Rec."No.");
        if StaffPosFilter <> '' then
            if Rec.Method = Rec.Method::Staff then
                StatementLines.SetFilter("Staff ID", StaffPosFilter)
            else
                if Rec.Method = Rec.Method::"POS Terminal" then
                    StatementLines.SetFilter("POS Terminal No.", StaffPosFilter);

        StatementLines.CalcSums("Counted Amount");
        StatementLines.CalcSums("Trans. Amount");
        StatementLines.CalcSums("Difference in LCY");

        LineAmt[1] := StatementLines."Counted Amount";
        LineAmt[2] := StatementLines."Trans. Amount";
        LineAmt[3] := StatementLines."Difference in LCY";
    end;

    trigger OnAfterGetRecord()
    var
        TreasuryGenFn: Codeunit "Treasury General Functions_NT";
    begin
        CalcCountedAmt();
        if StaffPosFilter = '' then
            FullName := TreasuryGenFn.StaffName(Rec."Staff/POS Term Filter Internal");
    end;

    var
        StaffPosFilter: Code[20];
        LineAmt: array[3] of Decimal;
        FullName: Text;
}
