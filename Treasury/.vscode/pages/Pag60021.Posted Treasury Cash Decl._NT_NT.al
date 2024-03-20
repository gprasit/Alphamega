page 60021 "Posted Treasury Cash Decl._NT"
{
    Caption = 'Posted Treasury Cash Declaration';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Posted Treasury Cash Decl._NT";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Qty."; Rec."Qty.")
                {
                    ApplicationArea = All;
                    Editable = "Qty.Editable";

                    trigger OnValidate()
                    begin
                        QtyOnAfterValidate;
                    end;
                }
                field(Total; Rec.Total)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        TypeOnFormat;
        TotalOnFormat;
    end;

    trigger OnInit()
    begin
        "Qty.Editable" := true;
    end;

    var
        TreasAllocLine: Record "Treasury Allocation Line_NT";
        [InDataSet]
        "Qty.Editable": Boolean;
        [InDataSet]
        TypeEmphasize: Boolean;
        [InDataSet]
        TotalEmphasize: Boolean;

#if __IS_SAAS__
    internal
#endif
    procedure SetLine(Rec: Record "Treasury Allocation Line_NT")
    begin
        TreasAllocLine := Rec;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure FormatTotal()
    begin
    end;

    local procedure QtyOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure QtyOnDeactivate()
    begin
        if Rec."Total Line" then
            "Qty.Editable" := false
        else
            "Qty.Editable" := true;
    end;

    local procedure QtyOnActivate()
    begin
        if Rec."Total Line" then
            "Qty.Editable" := false
        else
            "Qty.Editable" := true;
    end;

    local procedure TypeOnFormat()
    begin
        if Rec."Total Line" then
            TypeEmphasize := true;
    end;

    local procedure TotalOnFormat()
    begin
        if Rec."Total Line" then
            TotalEmphasize := true;
    end;
}

