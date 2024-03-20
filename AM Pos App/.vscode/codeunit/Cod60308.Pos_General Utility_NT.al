codeunit 60308 "Pos_General Utility_NT"
{
    SingleInstance = true;

    procedure SetLastItemLine(var NewRec: Record "LSC POS Trans. Line")
    var
    begin
        LastItemLine := NewRec;
    end;

    procedure GetLastItemLine(var CurrRec: Record "LSC POS Trans. Line")
    begin
        if not LastItemLine.Get(LastItemLine."Receipt No.", LastItemLine."Line No.") then
            Clear(LastItemLine);
        CurrRec := LastItemLine;
    end;


    procedure SetContinuityVoucher(var ContinuityVchCode_P: Text[30])
    begin
        ContinuityVoucherCode := ContinuityVchCode_P;
    end;

    procedure GetContinuityVoucher(var ContinuityVchCode_P: Text[30])
    begin
        ContinuityVchCode_P := ContinuityVoucherCode;
    end;

    procedure SetMailSubject(MailSubject_P: Text)
    begin
        MailSubject := MailSubject_P;
    end;

    procedure GetMailSubject(var MailSubject_P: Text)
    begin
        MailSubject_P := MailSubject;
    end;

    procedure SetFromLock(Fromlock: Boolean)
    begin
        FromLockCommand := Fromlock;
    end;

    procedure FromLock(): Boolean
    begin
        exit(FromLockCommand);
    end;

    procedure SetLockSetByStaffID(pStaffID: code[20])
    begin
        StaffID := pStaffID;
    end;

    procedure LockSetByStaffID(): Code[20]
    begin
        exit(StaffID);
    end;

    procedure InitializeTempTransTopUpEntry()
    var
    begin
        TransTopUpEntryTEMP.Reset();
        TransTopUpEntryTEMP.DeleteAll();
    end;

    procedure SetTopUpLineOnProcessTransaction(Var TransTopUpEntryTEMP2: Record "Pos_Trans. Topup Entry_NT" temporary)
    var
    begin
        TransTopUpEntryTEMP2.Reset();
        if TransTopUpEntryTEMP2.FindSet() then
            repeat
                TransTopUpEntryTEMP.Init();
                TransTopUpEntryTEMP.TransferFields(TransTopUpEntryTEMP2);
                TransTopUpEntryTEMP.Insert();
            until TransTopUpEntryTEMP2.Next() = 0;
    end;

    procedure GetTempTransTopUpEntry(Var TransTopUpEntryTEMP2: Record "Pos_Trans. Topup Entry_NT" temporary)
    var
    begin
        TransTopUpEntryTEMP2.Reset();
        TransTopUpEntryTEMP2.DeleteAll();

        TransTopUpEntryTEMP.Reset();
        if TransTopUpEntryTEMP.FindSet() then
            repeat
                TransTopUpEntryTEMP2.Init();
                TransTopUpEntryTEMP2.TransferFields(TransTopUpEntryTEMP);
                TransTopUpEntryTEMP2.Insert();
            until TransTopUpEntryTEMP.Next() = 0;
    end;

    procedure GetToalNumberOfItems(): Decimal
    begin
        exit(TotalNoOfItems);
    end;

    procedure SetToalNumberOfItems(pTotalNoOfItems: Decimal)
    begin
        TotalNoOfItems := pTotalNoOfItems;
    end;

    procedure SetGiftVoucher(FrmGiftVchIn: Boolean; GiftVchCodeIn: Text)
    begin
        FromGiftVoucher := FrmGiftVchIn;
        GiftVchCode := GiftVchCodeIn;
    end;

    procedure GetGiftVoucher(var FrmGiftVchIn: Boolean; var GiftVchCodeIn: Text)
    begin
        FrmGiftVchIn := FromGiftVoucher;
        GiftVchCodeIn := GiftVchCode;
    end;

    procedure SetSendTrans(SendTrans: Boolean)
    begin
        SendTransaction := SendTrans;
    end;

    procedure GetSendTrans(): Boolean
    begin
        exit(SendTransaction);
    end;

    procedure IsNumpadActive(): Boolean
    begin
        exit(NumPadActive);
    end;

    procedure SetNumpadActive(Value: boolean)
    begin
        NumPadActive := Value;
    end;

    procedure SetSuppressVoidMsg(Value: Boolean)

    begin
        SuppressVoidConfirmMsg := value;
    end;

    procedure GetSuppressVoidMsg(): Boolean
    begin
        exit(SuppressVoidConfirmMsg);
    end;

    procedure SetMsgPanelID(PanelID: Code[20])
    begin
        MsgPanelID := PanelID;
    end;

    procedure GetMsgPanelID(): Code[20]
    begin
        exit(MsgPanelID);
    end;

    procedure SetSchJobStepValue(StepsIn: Integer)
    begin
        SchJobSteps := StepsIn;
    end;

    procedure GetStepValue(): Integer
    begin
        Exit(SchJobSteps);
    end;

    procedure SetProcOrderEntryStepVal(StepsIn: Integer)
    begin
        ProcOrderEntrySteps := StepsIn;
    end;

    procedure GetProcOrderEntryStepVal(): Integer
    begin
        exit(ProcOrderEntrySteps);
    end;

    procedure UnBlockMemberAcc(AccNo: Code[20])
    var
        MemberAcc: Record "LSC Member Account";
    begin
        MemberAcc.Get(AccNo);
        if MemberAcc.Blocked then
            if not TempBlockedMembers.Get(AccNo) then begin
                Clear(TempBlockedMembers);
                TempBlockedMembers.Init();
                TempBlockedMembers := MemberAcc;
                TempBlockedMembers.Insert();
                MemberAcc.Blocked := false;
                MemberAcc.Modify();
            END;
    end;

    procedure BlockMemberAcc()
    var
        MemberAcc: Record "LSC Member Account";
    begin
        TempBlockedMembers.Reset();
        if TempBlockedMembers.FindSet() then
            repeat
                MemberAcc.Get(TempBlockedMembers."No.");
                MemberAcc.Blocked := TRUE;
                MemberAcc.Modify();
            until TempBlockedMembers.Next() = 0;
        TempBlockedMembers.Reset();
        TempBlockedMembers.DeleteAll();
    end;

    procedure SetStaffLogOnValues(StaffIn: Record "LSC Staff"; ManagerIn: Boolean)
    var
    begin
        TempStaff.Reset();
        TempStaff.DeleteAll();
        TempStaff.Init();
        TempStaff := StaffIn;
        TempStaff.Insert();
        Manager := ManagerIn;
    end;

    procedure GetStaffLogOnValues(var TempStaffIn: Record "LSC Staff" temporary; var ManagerIn: Boolean)
    var
    begin
        TempStaffIn := TempStaff;
        ManagerIn := Manager;
    end;

    procedure ClearStaffLogOnValues()
    var
    begin
        TempStaff.Reset();
        TempStaff.DeleteAll();
        Manager := false;
        OldStaffID := '';
    end;

    procedure SetOldStaffID(StaffID: code[20])
    var
    begin
        OldStaffID := StaffID;
    end;

    procedure GetOldStaffID(): Code[20]
    var
    begin
        exit(OldStaffID);
    end;

    procedure InitStepValues()
    begin
        ProcOrderEntrySteps := 0;
        SchJobSteps := 0;
    end;
procedure SetSkipEnteressedTriggeredFromGiftVoucher(SkipEnterPressedIn: Boolean)
var    
begin
    SkipEnterPressed := SkipEnterPressedIn;
end;
procedure GetSkipEnteressedTriggeredFromGiftVoucher(): Boolean
var    
begin
    exit(SkipEnterPressed);
end;

    var
        LastItemLine: Record "LSC POS Trans. Line";
        SkipEnterPressed: Boolean;
        TempBlockedMembers: Record "LSC Member Account" temporary;
        TransTopUpEntryTEMP: Record "Pos_Trans. Topup Entry_NT" temporary;
        FromGiftVoucher: Boolean;
        FromLockCommand: Boolean;
        NumPadActive: Boolean;
        SendTransaction: Boolean;
        SuppressVoidConfirmMsg: Boolean;
        StaffID: Code[20];
        TotalNoOfItems: Decimal;
        ContinuityVoucherCode: Text[30];
        GiftVchCode: Text;
        MailSubject: Text;
        MsgPanelID: Code[20];
        ProcOrderEntrySteps: Integer;
        SchJobSteps: Integer;
        TempStaff: Record "LSC Staff" temporary;
        Manager: Boolean;

        OldStaffID: code[20];
}
