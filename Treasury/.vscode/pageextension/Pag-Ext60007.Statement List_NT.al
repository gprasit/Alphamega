pageextension 60007 "Statement List_NT" extends "LSC Open Statement List"
{
    Editable = true;
    layout
    {
        addafter("Closing Method")
        {
            field(StaffName; FullName)
            {
                ApplicationArea = All;
                Caption = 'Staff Name';
                Editable = false;
            }
            field(Finish; Rec.Finish)
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        addafter("Posting Date")
        {
            field("Z-Amount"; Rec."Z-Amount")
            {
                ApplicationArea = All;
                BlankZero = true;
                trigger OnValidate()
                begin
                    OnAfterValidateZAmount();
                end;
            }
            field("Z-Difference"; DiffAmt[1])
            {
                ApplicationArea = All;
                Caption = 'Z-Difference';
                Editable = false;
            }
            field("Stmt-Difference"; DiffAmt[2])
            {
                ApplicationArea = All;
                Caption = 'Statement-Difference';
                Editable = false;
            }
        }
        modify("No.")
        {
            Editable = false;
        }
        modify("Store No.")
        {
            Editable = false;
        }
        modify("Calculated Date")
        {
            Editable = false;
        }
        modify("Calculated Time")
        {
            Editable = false;
        }
        modify("Closing Method")
        {
            Editable = false;
        }
        modify("Posting Date")
        {
            Editable = false;
        }
        modify("Trans. Ending Date")
        {
            Editable = false;
        }
        modify("Trans. Ending Time")
        {
            Editable = false;
        }
        modify(Accepted)
        {
            Editable = false;
        }
    }

    actions
    {
        addafter("T&ransactions")
        {
            action("&RefreshPage")
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Refresh;

                trigger OnAction()
                begin
                    UpdateCurrPage();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
    begin
        if not Rec.MarkedOnly then //MarkedOnly is from TreasuryStatements
            TreasRoleCenterMgmt.FilterStatements(Rec);
    end;

    trigger OnAfterGetRecord()
    var
        TreasuryGenFn: Codeunit "Treasury General Functions_NT";
    begin
        FullName := TreasuryGenFn.StaffName(Rec."Staff/POS Term Filter Internal");
        if Rec."Staff/POS Term Filter Internal" <> '' then
            FullName := Rec."Staff/POS Term Filter Internal" + ' ' + FullName;
        CalcDifference();
    end;

    local procedure OnAfterValidateZAmount()
    begin
        UpdateCurrPage();
    end;

    local procedure CalcDifference()
    var
        StatementLines: Record "LSC Statement Line";
        TransAmt: Decimal;
    begin
        StatementLines.SetFilter("Statement No.", Rec."No.");
        StatementLines.CalcSums("Trans. Amount");
        StatementLines.CalcSums("Difference in LCY");
        TransAmt := StatementLines."Trans. Amount";
        DiffAmt[1] := Rec."Z-Amount" - TransAmt;
        DiffAmt[2] := StatementLines."Difference in LCY";
    end;

    local procedure UpdateCurrPage()
    begin
        CurrPage.Update(true);
    end;

    var
        TreasRoleCenterMgmt: Codeunit "Treasury Role Center Mgt._NT";
        DiffAmt: array[2] of Decimal;
        FullName: Text;
}