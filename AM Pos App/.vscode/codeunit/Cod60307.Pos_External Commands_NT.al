codeunit 60307 "Pos_External Commands_NT"
{
    TableNo = "LSC POS Menu Line";
    trigger OnRun()
    begin
        if Rec."Registration Mode" then
            Register(Rec)
        else begin

            if PosTrans.Get(Rec."Current-RECEIPT") then
                POSTransFound := true
            else
                POSTransFound := false;
            CurrInput := Rec."Current-INPUT";

            case Rec.Command of
                'VOID_LL':
                    VoidLastLinePressed('VOID_LL');
                'VOID_LQ':
                    ReduceLineQtyPressed('VOID_LQ');
                'VOID_LS':
                    VoidLastScannedPressed('VOID_LS');
                'VOID_SI':
                    VoidItemPressed('VOID_SI');
                'PRINT_INV':
                    PrintTransInvoice();
                'PRINT_Z_NC':
                    PrintZReportNonCash();
                'SCREEN_DISP':
                    ScreenDisplay();
            end;
        end;
    end;

    local procedure Register(var MenuLine: Record "LSC POS Menu Line")
    var
        CommandFunc: Codeunit "LSC POS Command Registration";
        Module: Code[20];
        Text001: Label 'AM POS External Commands';
    begin
        Module := 'EXTCOMMANDS';
        CommandFunc.RegisterModule(Module, Text001, 60307);
        MenuLine."Registration Mode" := false;
    end;

    local procedure VoidLastLinePressed(FunctionCode: code[20])
    var
        LineRec: Record "LSC POS Trans. Line";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        PosTransCU: Codeunit "LSC POS Transaction";
        InfoTextDescription: Text;
        NT000: Label 'Only Last Line Can Be Voided.';
        NT009: Label 'Only Item Line Can Be Voided.';
    begin

        if SingleLineTransaction() then begin
            PosTransCU.ErrorBeep('Cannot void single line.');
            exit;
        end;

        LineRec.Reset();
        LineRec.SetRange("Receipt No.", PosTrans."Receipt No.");
        if LineRec.FindLast() then begin
            if LineRec."Entry Status" = LineRec."Entry Status"::Voided then begin
                PosTransCU.ErrorBeep(NT000);
                exit;
            end;
            if LineRec."Entry Type" <> LineRec."Entry Type"::Item then begin
                PosTransCU.ErrorBeep(NT009);
                exit;
            end;
        end;
        if not LineRec.FindLast() then begin
            PosTransCU.MessageBeep('');
            exit;
        end;
        //BC Upgrade Start
        LineRec."Void Command" := FunctionCode;
        LineRec.Modify();
        //BC Upgrade End
        POSLINES.SetCurrentLine(LineRec);
        PosTransCU.VoidLinePressed();
    end;

    local procedure ReduceLineQtyPressed(FunctionCode: code[20])
    var
        LineRec: Record "LSC POS Trans. Line";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        PosTransCU: Codeunit "LSC POS Transaction";
        PosView: Codeunit "LSC POS View";
    begin

        POSLINES.GetCurrentLine(LineRec);

        if LineRec."Price in Barcode" or LineRec."Scale Item" or (Round(LineRec.Quantity, 1) <> LineRec.Quantity) then begin
            //BC Upgrade Start
            LineRec."Void Command" := FunctionCode;
            LineRec.Modify();
            //BC Upgrade End
            PosTransCU.VoidLinePressed;
        end;

        if (LineRec.Quantity > 1) and (Round(LineRec.Quantity, 1) = LineRec.Quantity) then
            //PosTransCU.ChangeQtyPressed(Format(LineRec.Quantity - 1))//BC22
            PosView.ChangeQtyPressed(Format(LineRec.Quantity - 1))//BC22           
        else
            if LineRec.Quantity = 1 then begin
                LineRec."Void Command" := FunctionCode;//BC Upgrade
                LineRec.Modify();//BC Upgrade
                PosTransCU.VoidLinePressed;
            end;
    end;

    local procedure VoidLastScannedPressed(FunctionCode: code[20])
    var
        LastItemLine: Record "LSC POS Trans. Line";
        LineRec: Record "LSC POS Trans. Line";
        PosGenUtility: Codeunit "Pos_General Utility_NT";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        PosTransCU: Codeunit "LSC POS Transaction";
        InfoDescription: Text;
        NT006: Label 'Only Last Item Scanned Can Be Voided.';
        POSView: Codeunit "LSC POS View";
    begin
        if SingleLineTransaction then begin
            PosTransCU.ErrorBeep('Cannot void single line.');
            exit;
        end;
        PosGenUtility.GetLastItemLine(LastItemLine);
        if not LineRec.Get(LastItemLine."Receipt No.", LastItemLine."Line No.") then begin
            PosTransCU.ErrorBeep('Invalid Action.');
            exit;
        end;

        if LineRec."Entry Status" = LineRec."Entry Status"::Voided then begin
            PosTransCU.ErrorBeep(NT006);
            exit;
        end;
        //BC Upgrade Start
        /*
         if not POSSESSION.Permission(FunctionCode, InfoDescription) then begin
             PosTransCU.ErrorBeep(InfoDescription);
             exit;
         end;
        */
        LineRec."Void Command" := FunctionCode;
        LineRec.Modify();
        //BC Upgrade end

        POSLINES.SetCurrentLine(LineRec);

        Clear(LastItemLine);
        PosGenUtility.SetLastItemLine(LastItemLine);

        if LineRec."Price in Barcode" OR LineRec."Scale Item" then begin
            PosTransCU.VoidLinePressed;
        end;

        if (LineRec.Quantity > 0) AND (ROUND(LineRec.Quantity, 1) <> LineRec.Quantity) then
            PosTransCU.VoidLinePressed;

        if (LineRec.Quantity > 1) AND (ROUND(LineRec.Quantity, 1) = LineRec.Quantity) then
            //PosTransCU.ChangeQtyPressed(FORMAT(LineRec.Quantity - 1))//BC22
            POSView.ChangeQtyPressed(FORMAT(LineRec.Quantity - 1))//BC22            
        else
            if LineRec.Quantity = 1 then
                PosTransCU.VoidLinePressed;
    end;

    local procedure VoidItemPressed(FunctionCode: code[20])
    var
        Barcode: Record "LSC Barcodes";
        Item: Record Item;
        PosTransLine: Record "LSC POS Trans. Line";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        PosTransCU: Codeunit "LSC POS Transaction";
        ItemNo: Code[20];
        ItemNotOnFileErr: Label 'Item %1 is not on file!';
    begin
        if PosTransCU.GetFunctionMode() = FunctionCode then begin
            ItemNo := CopyStr(CurrInput, 1, 20);
            if not Item.Get(ItemNo) then
                if not Barcode.Get(ItemNo) then begin
                    PosTransCU.ErrorBeep('Item Not Found.');
                    exit;
                end else
                    ItemNo := Barcode."Item No.";
            PosTransCU.SetFunctionMode('ITEM');
        end else begin
            PosTransCU.SetFunctionMode(FunctionCode);
            exit;
        end;

        if ItemNo = '' then begin
            PosTransCU.MessageBeep('');
            exit;
        end;

        if not Item.Get(ItemNo) then begin
            PosTransCU.ErrorBeep(StrSubstNo(ItemNotOnFileErr, ItemNo));
            exit;
        end;

        PosTransLine.Reset();
        PosTransLine.SetRange("Receipt No.", PosTrans."Receipt No.");
        PosTransLine.SetRange("Entry Type", PosTransLine."Entry Type"::Item);
        PosTransLine.SetRange("Entry Status", PosTransLine."Entry Status"::" ");
        PosTransLine.SetRange(Number, ItemNo);
        if not PosTransLine.FindFirst() then begin
            PosTransCU.ErrorBeep(STRSUBSTNO(ItemNotOnFileErr, ItemNo));
            PosTransCU.SetFunctionMode(FunctionCode);//BC Upgrade
            exit;
        end;
        //BC Upgrade Start   
        PosTransLine."Void Command" := FunctionCode;
        PosTransLine.Modify();
        //BC Upgrade End
        POSLINES.SetCurrentLine(PosTransLine);
        ReduceLineQtyPressed(FunctionCode);
    end;

    local procedure SingleLineTransaction(): Boolean
    var
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        POSTransLine.Reset();
        POSTransLine.SetRange("Receipt No.", PosTrans."Receipt No.");
        POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
        exit(POSTransLine.Count = 1);
    end;

    procedure PrintTransInvoice()
    var
        Trans: Record "LSC Transaction Header";
        POSCtrl: Codeunit "LSC POS Control Interface";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
        lRecordRef: RecordRef;
        lRecordID: RecordID;
        LastErrorText: Text;
    begin
        if POSCtrl.GetActiveLookupRecordID(lRecordID) then begin
            lRecordRef.Get(lRecordID);
            lRecordRef.SetTable(Trans);
            if not PosGenFunc.PrintTransInvoice(Trans, LastErrorText) then
                PosTransCU.PosMessage(LastErrorText);
        end;
    end;

    procedure PrintZReportNonCash()
    var
        PrintUtil: Codeunit "Pos_Print Utility_NT";
    begin
        if not POSTransFound then
            PosTrans.Get(POSTransCU.GetReceiptNo());
        PrintUtil.PrintZReportNonCash(PosTrans, true, true);
    end;

    local procedure ScreenDisplay()
    var
        TenderType: Record "LSC Tender Type";
        POSTransCU: Codeunit "LSC POS Transaction";
        POSSession: Codeunit "LSC POS Session";
        StopTime: Time;
        DelayedUpdate: Integer;
        bWasOpen: Boolean;
        dd: Dialog;
        POSGUI: Codeunit "LSC POS GUI";
    begin
        //TenderType.Get(POSTransaction."Store No.", TenderTypeCode);
        //IF TenderType."EFT Provider" <> TenderType."EFT Provider"::JCC THEN
        //    EXIT;
        //POSTransCU.ScreenDisplay('Waiting for Card');

        POSGUI.ScreenDisplay('');
        dd.Open('TEST');

        StopTime := Time + 40000;  //Default 40 seconds
        while (StopTime > Time) do begin
            bWasOpen := true;
            if DelayedUpdate = 2 then begin
                POSGUI.ScreenDisplay('Waiting for Card');

            end;
            DelayedUpdate += 1;
            //Sleep(500);
        end;
        POSGUI.ScreenDisplay('');
        dd.Close();

        //Sleep(100);
    end;

    var
        PosTrans: Record "LSC POS Transaction";
        POSTransCU: Codeunit "LSC POS Transaction";
        POSSession: Codeunit "LSC POS Session";
        POSTransFound: Boolean;
        CurrInput: Text[100];
        Text001: Label 'Item lines are not allowed in this state!';
}