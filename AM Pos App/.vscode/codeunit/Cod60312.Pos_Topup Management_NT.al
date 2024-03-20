codeunit 60312 "Pos_Topup Management_NT"
{
    trigger OnRun()
    begin

    end;

    procedure InsertTopUpLine(PosTransLine: Record "LSC POS Trans. Line"; REC: Record "LSC POS Transaction")
    var
        PosTopupEntry: Record "Pos_POS Topup Entry_NT";
        NextEntryNo: Integer;
    begin
        NextEntryNo := 0;
        PosTopupEntry.Reset();
        PosTopupEntry.SetRange("Receipt No.", PosTransLine."Receipt No.");
        if PosTopupEntry.FindLast() then
            NextEntryNo := PosTopupEntry."Entry No.";
        NextEntryNo += 1;
        Clear(PosTopupEntry);
        PosTopupEntry."Receipt No." := PosTransLine."Receipt No.";
        PosTopupEntry."Entry No." := NextEntryNo;
        PosTopupEntry."Store No." := PosTransLine."Store No.";
        PosTopupEntry."POS Terminal No." := PosTransLine."POS Terminal No.";
        PosTopupEntry."Pos Trans. Line No." := PosTransLine."Line No.";
        PosTopupEntry."Item No." := PosTransLine.Number;
        PosTopupEntry."Topup ID" := PosTransLine.Number;
        PosTopupEntry."Topup Amount" := PosTransLine.Amount;
        PosTopupEntry."Request Date" := Today;
        PosTopupEntry."Request Time" := Time;
        if PosTransLine."Sales Staff" <> '' then
            PosTopupEntry."Request User ID" := PosTransLine."Sales Staff"
        else
            PosTopupEntry."Request User ID" := REC."Sales Staff";
        PosTopupEntry."Member Card No." := REC."Member Card No.";
        PosTopupEntry.Insert();
    end;

    procedure CheckTopUpQty(NewQuantity: Decimal; Line: Record "LSC POS Trans. Line"; Proceed: Boolean)
    var
        Item: Record Item;
    begin
        if Item.Get(Line.Number) then
            if Item."Topup Item" then
                if Abs(NewQuantity) <> 1 then
                    Proceed := false;
    end;

    procedure InitializTopupTenderKeyPressedEx(var PosTransaction: Record "LSC POS Transaction"; var TenderTypeCode: Code[10]) :Boolean
    var
        PosTopUpLine2: Record "Pos_POS Topup Entry_NT";
        PosTopUpLine: Record "Pos_POS Topup Entry_NT";
        PosTransLine2: Record "LSC POS Trans. Line";
        TmpPosTopUpLine: Record "Pos_POS Topup Entry_NT" temporary;
        TmpVoidedTopup: Record "Aging Band Buffer" temporary;
        PosTransCU: Codeunit "LSC POS Transaction";
        POSTransLinesCU: Codeunit "LSC POS Trans. Lines";
        Window: Dialog;
        MsgText: Text;
    begin
        PosTopUpLine.Reset();
        PosTopUpLine.SetCurrentKey("Receipt No.", "Transaction Status");
        PosTopUpLine.SetRange("Receipt No.", PosTransaction."Receipt No.");
        PosTopUpLine.SetRange("Transaction Status", PosTopUpLine."Transaction Status"::" ");
        if PosTopUpLine.FindSet() then begin
            Window.Open(Text0001);
            TmpPosTopUpLine.DeleteAll();
            repeat
                PosTopUpLine2 := PosTopUpLine;
                SendTransaction(PosTopUpLine2, PosTransaction);
                PosTopUpLine2.Modify();
                if PosTopUpLine2."Transaction Status" = PosTopUpLine2."Transaction Status"::Error then begin
                    TmpPosTopUpLine := PosTopUpLine2;
                    TmpPosTopUpLine.Insert();
                end;
            until PosTopUpLine.Next() = 0;
            Window.Close();
            if TmpPosTopUpLine.FindFirst() then begin
                TmpVoidedTopup.DeleteAll();
                repeat
                    if not TmpVoidedTopup.Get(TmpPosTopUpLine."Item No.") then begin
                        Clear(TmpVoidedTopup);
                        TmpVoidedTopup."Currency Code" := TmpPosTopUpLine."Item No.";
                        TmpVoidedTopup.Insert();
                    end;
                    TmpVoidedTopup."Column 1 Amt." += 1;
                    TmpVoidedTopup.Modify();
                    PosTransLine2.Get(TmpPosTopUpLine."Receipt No.", TmpPosTopUpLine."Pos Trans. Line No.");
                    POSTransLinesCU.SetCurrentLine(PosTransLine2);
                    PosTransCU.VoidLinePressed;
                until TmpPosTopUpLine.Next() = 0;
                if TmpVoidedTopup.Count = 1 then begin
                    if TmpVoidedTopup."Column 1 Amt." = 1 then
                        MsgText := StrSubstNo(Text0002, TmpVoidedTopup."Currency Code")
                    else
                        MsgText := StrSubstNo(Text0003, TmpVoidedTopup."Column 1 Amt.", TmpVoidedTopup."Currency Code")
                end else begin
                    MsgText := Text0004;
                    TmpVoidedTopup.FindFirst();
                    repeat
                        MsgText := MsgText + StrSubstNo('%1 - %2\', TmpVoidedTopup."Currency Code", TmpVoidedTopup."Column 1 Amt.");
                    until TmpVoidedTopup.Next() = 0;
                end;
                Message(MsgText);
                //exit;//BC Upgrade
                exit(true);//BC Upgrade. To stop Insertion of the payment Line  
            end;            
        end;
        exit(false);//BC Upgrade    
        /*
        IF TenderType."Mobile Payment" THEN BEGIN
            MobilePayment(REC, PaymentAmount);
            EXIT;
        END;
        */
    end;

    procedure ActivateAccount()
    var
        TopupSetup: Record "Pos_Topup Setup_NT";
        TimeStamp: DateTime;
        Error1: Text[1024];
        Error2: Text[1024];
        Password: Text[1024];
        AccountManagament: DotNet AltaAccountManagement_NT;
    begin
        TopupSetup.Get();
        TopupSetup.TestField("Topup Alta XL Initializer");
        TopupSetup.TestField("Topup User Name");
        TopupSetup.TestField("Topup Temp Password");

        Clear(AccountManagament);
        AccountManagament := AccountManagament.AccountManagement();
        AccountManagament.SetSecurityProtocol_3072();//BC Upgrade
        AccountManagament.Set_PrepayXL(TopupSetup."Topup Alta XL Initializer");
        TimeStamp := CurrentDateTime;
        if not AccountManagament.ActivateAccount(TopupSetup."Topup User Name", TopupSetup."Topup Temp Password", Password) THEN BEGIN
            AccountManagament.GetErrorMessage(Error1, Error2);
            Message(Error1);
            Message(Error2);
            Message('%1', TimeStamp);
        end else begin
            TopupSetup."Topup Password" := Password;
            TopupSetup.Modify();
            Commit();
        end;
    end;

    procedure ActivateLocation()
    var
        TopupSetup: Record "Pos_Topup Setup_NT";
        TimeStamp: DateTime;
        Error1: Text[1024];
        Error2: Text[1024];
        LocationHash: Text[1024];
        AccountManagament: DotNet AltaAccountManagement_NT;
    begin
        TopupSetup.Get();
        TopupSetup.TestField("Topup Alta XL Initializer");
        TopupSetup.TestField("Topup User Name");
        TopupSetup.TestField("Topup Password");
        CLEAR(AccountManagament);
        AccountManagament := AccountManagament.AccountManagement();
        AccountManagament.SetSecurityProtocol_3072();//BC Upgrade
        AccountManagament.Set_PrepayXL(TopupSetup."Topup Alta XL Initializer");
        TimeStamp := CurrentDateTime;
        if not AccountManagament.GenerateLocation(TopupSetup."Topup User Name", TopupSetup."Topup Password", LocationHash) THEN BEGIN
            AccountManagament.GetErrorMessage(Error1, Error2);
            Message(Error1);
            Message(Error2);
            Message('%1', TimeStamp);
        end else begin
            TopupSetup."Topup Location Hash" := LocationHash;
            TopupSetup.Modify();
            Commit();
        end;
    end;

    procedure SendTransaction(var PosTopUpLine: Record "Pos_POS Topup Entry_NT"; REC: Record "LSC POS Transaction"): Boolean
    var
        TopupSetup: Record "Pos_Topup Setup_NT";
        UserName: Text;
        Transaction: DotNet AltaTransaction_NT;
    begin
        TopupSetup.Get();
        TopupSetup.TestField("Topup Alta XL Initializer");
        TopupSetup.TestField("Topup User Name");
        TopupSetup.TestField("Topup Password");
        TopupSetup.TestField("Topup Location Hash");
        TopupSetup.TestField("Topup No. Of Retries");
        UserName := TopupSetup."Topup User Name" + '.' + PosTopUpLine."Store No." + '.' + PosTopUpLine."POS Terminal No." + '.' +
          PosTopUpLine."Processing User ID";
        PosTopUpLine."Processing Date" := Today;
        PosTopUpLine."Processing Time" := Time;

        CLEAR(Transaction);
        Transaction := Transaction.Transaction();
        Transaction.SetSecurityProtocol_3072();//BC Upgrade
        Transaction.SetAccountInfo(UserName, TopupSetup."Topup Password", TopupSetup."Topup Location Hash", TopupSetup."Topup No. Of Retries");
        Transaction.Set_PrepayXL(TopupSetup."Topup Alta XL Initializer");
        //IF NOT Transaction.SendTransaction(TopUpLine."Topup ID",TopUpLine."Member Card No.") THEN BEGIN //BC Upgrade as the Supplied DLL ia having 3 parameters for this function        
        if not Transaction.SendTransaction(PosTopUpLine."Topup ID", PosTopUpLine."Member Card No.", REC."Receipt No.") then begin //BC Upgrade. Added parameter "Receipt No."        
            Transaction.GetErrorMessage(PosTopUpLine."Error Message 1", PosTopUpLine."Error Message 2");
            PosTopUpLine."Transaction Status" := PosTopUpLine."Transaction Status"::Error;
            exit(false);
        end else begin
            PosTopUpLine."Transaction ID" := Transaction.GetTransID();
            PosTopUpLine."Serial No." := Transaction.GetSerialNo();
            PosTopUpLine.Pin := Transaction.GetPin();
            PosTopUpLine."Transaction Status" := PosTopUpLine."Transaction Status"::Completed;
            PosTopUpLine."Promotion Code 1" := Transaction.GetPromoCode1();
            PosTopUpLine."Promotion Code 2" := Transaction.GetPromoCode2();
            PosTopUpLine."Promotion Text" := Transaction.GetPromoText();
            exit(true);
        end;
    end;

    procedure TopupSelectionMsgOnTotalPressed(var PosTransaction: Record "LSC POS Transaction")
    var
        PosTopUpLine: Record "Pos_POS Topup Entry_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
    begin
        PosTopUpLine.Reset();
        PosTopUpLine.SetCurrentKey("Receipt No.", "Transaction Status");
        PosTopUpLine.SetRange("Receipt No.", PosTransaction."Receipt No.");
        PosTopUpLine.SetRange("Transaction Status", PosTopUpLine."Transaction Status"::" ");
        if PosTopUpLine.FindFirst() then
            repeat
                PosTransCU.PosMessage(StrSubstNo('Topup %1 was selected.', PosTopUpLine."Topup ID"));
            until PosTopUpLine.Next() = 0;
    end;

    var
        Text0001: Label 'Please Wait For Top-Up Authorization';
        Text0002: label '%1 was not authorized and voided.';
        Text0003: label '%1 %2 were not authorized and voided.';
        Text0004: label 'The following TopUps were not authorized and voided.\';

}