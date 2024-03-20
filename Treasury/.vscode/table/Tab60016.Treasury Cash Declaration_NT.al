table 60016 "Treasury Cash Declaration_NT"
{
    Caption = 'Treasury Cash Declaration';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Treasury Statement No."; Code[20])
        {
            Caption = 'Statement No.';
            TableRelation = "Treasury Statement_NT";
        }
        field(2; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Coin,Note,Roll,Total';
            OptionMembers = Coin,Note,Roll,Total;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(6; "Treasury Allocation Line No."; Integer)
        {
            Caption = 'Treasury Allocation Line No.';
        }
        field(10; "Qty."; Integer)
        {
            Caption = 'Qty.';

            trigger OnValidate()
            begin
                Total := Amount * "Qty.";
                Modify;
                CashDeclaration.SetRange("Treasury Statement No.", "Treasury Statement No.");
                CashDeclaration.SetRange("Tender Type", "Tender Type");
                CashDeclaration.SetRange("Currency Code", "Currency Code");
                CashDeclaration.SetRange("Treasury Allocation Line No.", "Treasury Allocation Line No.");
                CashDeclaration.SetFilter(Type, '<>%1', CashDeclaration.Type::Total);
                CashDeclaration.CalcSums(Total);
                GrandTotal := CashDeclaration.Total;

                CashDeclaration2.Get("Treasury Statement No.", "Tender Type", "Currency Code", CashDeclaration.Type::Total, 0, "Treasury Allocation Line No.", true);
                CashDeclaration2.Total := CashDeclaration.Total;
                CashDeclaration2.Modify;
            end;
        }
        field(15; Total; Decimal)
        {
            Caption = 'Total';
        }
        field(16; "Total Line"; Boolean)
        {
            Caption = 'Total Line';
        }
        field(17; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type".Code;
        }
        field(18; Description; Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Treasury Statement No.", "Tender Type", "Currency Code", Type, Amount, "Treasury Allocation Line No.", "Total Line")
        {
            Clustered = true;
            SumIndexFields = Total;
        }
    }

    fieldgroups
    {
    }

    var
        CashDeclaration: Record "Treasury Cash Declaration_NT";
        CashDeclaration2: Record "Treasury Cash Declaration_NT";
        GrandTotal: Decimal;

#if __IS_SAAS__
    internal
#endif
    procedure InsertData(TreasAllocLine: Record "Treasury Allocation Line_NT")
    var
        Currency: Record Currency;
        CashDeclarationSetup: Record "LSC Cash Declaration Setup";
        Store: Record "LSC Store";
        Statement: Record "LSC Statement";
        TransStatus: Record "LSC Transaction Status";
        Transaction: Record "LSC Transaction Header";
        TransCashDeclaration: Record "LSC Trans. Cash Declaration";
        CashDeclTmp: array[2] of Record "LSC POS Cash Decl. Line" temporary;
        TCD_Tmp: Record "LSC Trans. Cash Declaration" temporary;
        TotalAmount: Decimal;
        HierarchyDefs: Record "LSC Retail Hierar. Defaults";
        StoreNo: Code[10];
    begin
        TotalAmount := 0;
        Clear(CashDeclTmp);
        CashDeclTmp[1].DeleteAll;

        HierarchyDefs.SetRange("Table ID", Database::"LSC Store");
        HierarchyDefs.SetRange("Hierarchy Code", TreasAllocLine."Store Hierarchy No.");
        if HierarchyDefs.FindFirst() then
            StoreNo := HierarchyDefs."No."
        else
            Error(Text001);

        //Statement.Get(TreasAllocLine."Store No.", TreasAllocLine."Statement No.");
        Store.Get(StoreNo);

        Clear(TransCashDeclaration);
        Clear(TCD_Tmp);
        TCD_Tmp.DeleteAll;

        // TransCashDeclaration.Reset;
        // if TreasAllocLine."Staff ID" <> '' then begin
        //     TransCashDeclaration.SetCurrentKey("Staff ID", "Decl. Type");
        //     TransCashDeclaration.SetRange("Staff ID", TreasAllocLine."Staff ID");
        // end
        // else begin
        //     TransCashDeclaration.SetCurrentKey("Decl. Type");
        // end;

        // TransCashDeclaration.SetRange("Decl. Type", TransCashDeclaration."Decl. Type"::"Counted Amount");
        // TransCashDeclaration.SetRange("Store No.", Statement."Store No.");
        // if TransCashDeclaration.FindFirst then begin
        //     TransStatus.Reset;
        //     TransStatus.SetCurrentKey("Statement No.", Status);
        //     TransStatus.SetRange("Statement No.", TreasAllocLine."Statement No.");
        //     TransStatus.SetRange("Store No.", Statement."Store No.");
        //     if (TreasAllocLine."POS Terminal No." <> '') then
        //         TransStatus.SetRange("POS Terminal No.", TreasAllocLine."POS Terminal No.");

        //     if TransStatus.FindFirst then begin
        //         repeat
        //             if Transaction.Get(TransStatus."Store No.", TransStatus."POS Terminal No.", TransStatus."Transaction No.") then begin
        //                 if (Transaction."Transaction Type" = Transaction."Transaction Type"::"Tender Decl.") then begin
        //                     TransCashDeclaration.SetRange("POS Terminal No.", TransStatus."POS Terminal No.");
        //                     TransCashDeclaration.SetRange("Transaction No.", TransStatus."Transaction No.");
        //                     if TransCashDeclaration.FindFirst then begin
        //                         TCD_Tmp."Store No." := TransCashDeclaration."Store No.";
        //                         TCD_Tmp."POS Terminal No." := TransCashDeclaration."POS Terminal No.";
        //                         TCD_Tmp."Transaction No." := TransCashDeclaration."Transaction No.";
        //                         if TCD_Tmp.Insert then;
        //                     end;
        //                 end;
        //             end;
        //         until TransStatus.Next = 0;
        //     end;
        // end;

        // Clear(TransCashDeclaration);
        // Clear(TCD_Tmp);

        // if Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Last then begin
        //     if TCD_Tmp.FindLast then begin
        //         TransCashDeclaration.SetRange("Store No.", TCD_Tmp."Store No.");
        //         TransCashDeclaration.SetRange("POS Terminal No.", TCD_Tmp."POS Terminal No.");
        //         TransCashDeclaration.SetRange("Transaction No.", TCD_Tmp."Transaction No.");
        //         TransCashDeclaration.SetRange("Tender Type", TreasAllocLine."Tender Type");
        //         TransCashDeclaration.SetRange("Currency Code", TreasAllocLine."Currency Code");
        //         if TransCashDeclaration.FindFirst then begin
        //             repeat
        //                 CashDeclTmp[1].Init;
        //                 CashDeclTmp[1]."Tender Type" := TransCashDeclaration."Tender Type";
        //                 CashDeclTmp[1]."Currency Code" := TransCashDeclaration."Currency Code";
        //                 CashDeclTmp[1].Type := TransCashDeclaration.Type;
        //                 CashDeclTmp[1].Amount := TransCashDeclaration.Amount;
        //                 CashDeclTmp[1]."Qty." := TransCashDeclaration."Qty.";
        //                 CashDeclTmp[1].Total := TransCashDeclaration.Total;
        //                 CashDeclTmp[1].Insert;
        //             until TransCashDeclaration.Next = 0;
        //         end;
        //     end;
        // end;

        // if Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Sum then begin
        //     if TCD_Tmp.FindFirst then begin
        //         repeat
        //             TransCashDeclaration.SetRange("Store No.", TCD_Tmp."Store No.");
        //             TransCashDeclaration.SetRange("POS Terminal No.", TCD_Tmp."POS Terminal No.");
        //             TransCashDeclaration.SetRange("Transaction No.", TCD_Tmp."Transaction No.");
        //             TransCashDeclaration.SetRange("Tender Type", TreasAllocLine."Tender Type");
        //             TransCashDeclaration.SetRange("Currency Code", TreasAllocLine."Currency Code");
        //             if TransCashDeclaration.FindFirst then begin
        //                 repeat
        //                     CashDeclTmp[1].Init;
        //                     CashDeclTmp[1]."Tender Type" := TransCashDeclaration."Tender Type";
        //                     CashDeclTmp[1]."Currency Code" := TransCashDeclaration."Currency Code";
        //                     CashDeclTmp[1].Type := TransCashDeclaration.Type;
        //                     CashDeclTmp[1].Amount := TransCashDeclaration.Amount;
        //                     CashDeclTmp[1]."Qty." := TransCashDeclaration."Qty.";
        //                     CashDeclTmp[1].Total := TransCashDeclaration.Total;
        //                     CashDeclTmp[2] := CashDeclTmp[1];
        //                     if CashDeclTmp[2].Find then begin
        //                         CashDeclTmp[2]."Qty." := CashDeclTmp[2]."Qty." + CashDeclTmp[1]."Qty.";
        //                         CashDeclTmp[2].Total := CashDeclTmp[2].Total + CashDeclTmp[1].Total;
        //                         CashDeclTmp[2].Modify;
        //                     end else
        //                         CashDeclTmp[1].Insert;
        //                 until TransCashDeclaration.Next = 0;
        //             end;
        //         until TCD_Tmp.Next = 0;
        //     end;
        // end;

        // if TreasAllocLine."Currency Code" <> '' then
        //     Currency.Get(TreasAllocLine."Currency Code");

        CashDeclarationSetup.SetRange("Store No.", Store."No.");
        CashDeclarationSetup.SetRange("Currency Code", TreasAllocLine."Currency Code");
        if CashDeclarationSetup.Find('-') then
            repeat
                CashDeclaration.Init;
                CashDeclaration."Treasury Statement No." := TreasAllocLine."Treasury Statement No.";
                CashDeclaration."Tender Type" := TreasAllocLine."Tender Type";
                CashDeclaration."Currency Code" := TreasAllocLine."Currency Code";
                CashDeclaration.Type := CashDeclarationSetup.Type;
                CashDeclaration."Treasury Allocation Line No." := TreasAllocLine."Line No.";
                CashDeclaration.Amount := CashDeclarationSetup.Amount;

                CashDeclTmp[2].Init;
                CashDeclTmp[2]."Tender Type" := CashDeclaration."Tender Type";
                CashDeclTmp[2]."Currency Code" := CashDeclaration."Currency Code";
                CashDeclTmp[2].Type := CashDeclaration.Type;
                CashDeclTmp[2].Amount := CashDeclaration.Amount;
                if CashDeclTmp[2].Find then begin
                    CashDeclaration."Qty." := CashDeclTmp[2]."Qty.";
                    CashDeclaration.Total := CashDeclTmp[2].Total;
                    TotalAmount := TotalAmount + CashDeclaration.Total;
                end;

                CashDeclaration.Description := CashDeclarationSetup.Description;

                if CashDeclaration.Insert then;
            until CashDeclarationSetup.Next = 0;

        CashDeclaration.Init;
        CashDeclaration."Treasury Statement No." := TreasAllocLine."Treasury Statement No.";
        CashDeclaration."Tender Type" := TreasAllocLine."Tender Type";
        CashDeclaration."Currency Code" := TreasAllocLine."Currency Code";
        CashDeclaration.Type := CashDeclaration.Type::Total;
        CashDeclaration."Treasury Allocation Line No." := TreasAllocLine."Line No.";
        CashDeclaration.Amount := 0;
        CashDeclaration."Total Line" := true;

        if TotalAmount <> 0 then
            CashDeclaration.Total := TotalAmount;

        if CashDeclaration.Insert then;
    end;

    var
        Text001: Label 'No store defined for store hierarchy %1';
}

