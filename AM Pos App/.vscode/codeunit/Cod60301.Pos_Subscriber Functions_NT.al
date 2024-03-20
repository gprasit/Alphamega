codeunit 60301 "Pos_Subscriber Functions_NT"
{
    trigger OnRun()
    var

    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnAfterCheckingOfferIsValid', '', false, false)]
    local procedure OnAfterCheckingOfferIsValid(var PeriodicDiscount: Record "LSC Periodic Discount"; var SkipOffer: Boolean; var PosTrans: Record "LSC POS Transaction"; var TmpPeriodicDiscountLines: Record "LSC Periodic Discount Line")
    var
        PosGenFun: Codeunit "Pos_General Functions_NT";
        Totamount: Decimal;
    begin
        if (PeriodicDiscount."Amount to Trigger" <> 0) then
            if PeriodicDiscount."Amt. to Trigger Based on Lines" then begin
                PosTrans.CalcFields("Gross Amount", "Line Discount", "Income/Exp. Amount");
                TotAmount := PosTrans."Gross Amount" + PosTrans."Line Discount" + PosTrans."Income/Exp. Amount";
                TotAmount := PosGenFun.GetDiscOfferLineTotal(PeriodicDiscount, PosTrans, TotAmount);
                if TotAmount < PeriodicDiscount."Amount to Trigger" then
                    SkipOffer := true;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnBeforeCheckSkipCalcMixMatchNew', '', false, false)]
    local procedure OnBeforeCheckSkipCalcMixMatchNew(PeriodicDiscount: Record "LSC Periodic Discount"; POSTransaction: Record "LSC POS Transaction"; TmpPeriodicDiscount: Record "LSC Periodic Discount"; var MixMarchOk: Boolean)
    var
        PosGenFun: Codeunit "Pos_General Functions_NT";
        Totamount: Decimal;
    begin
        if (PeriodicDiscount."Amount to Trigger" <> 0) then
            if PeriodicDiscount."Amt. to Trigger Based on Lines" then begin
                POSTransaction.CalcFields("Gross Amount", "Line Discount", "Income/Exp. Amount");
                TotAmount := POSTransaction."Gross Amount" + POSTransaction."Line Discount" + POSTransaction."Income/Exp. Amount";
                TotAmount := PosGenFun.GetDiscOfferLineTotal(PeriodicDiscount, POSTransaction, TotAmount);
                if TotAmount < PeriodicDiscount."Amount to Trigger" then
                    MixMarchOk := false;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnBeforeRegisterMixMatchNew', '', false, false)]
    local procedure OnBeforeRegisterMixMatchNew(var PeriodicDiscount: Record "LSC Periodic Discount"; var PosTrans: Record "LSC POS Transaction"; OfferPosCalc: Record "LSC Offer Pos Calculation"; var MixMatchOk: Boolean)
    var
        PosGenFun: Codeunit "Pos_General Functions_NT";
        TotAmount: Decimal;
    begin
        if (PeriodicDiscount."Amount to Trigger" <> 0) then
            if PeriodicDiscount."Amt. to Trigger Based on Lines" then begin
                POSTrans.CalcFields("Gross Amount", "Line Discount", "Income/Exp. Amount");
                TotAmount := POSTrans."Gross Amount" + POSTrans."Line Discount" + POSTrans."Income/Exp. Amount";
                TotAmount := PosGenFun.GetDiscOfferLineTotal(PeriodicDiscount, POSTrans, TotAmount);
                if TotAmount < PeriodicDiscount."Amount to Trigger" then
                    MixMatchOk := false;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnFindPeriodicOffersDiscOfferType', '', false, false)]
    local procedure OnFindPeriodicOffersDiscOfferType(var PeriodicDiscountLines: Record "LSC Periodic Discount Line"; var TmpPerDiscount: Record "LSC Periodic Discount"; var CurrLine: Record "LSC POS Trans. Line"; var Found: Boolean; DateToUse: Date; TimeToUse: Time; var Exclude: Boolean)
    var
        PosTrans: Record "LSC POS Transaction";
        PosGenFun: Codeunit "Pos_General Functions_NT";
        TotAmount: Decimal;
    begin

        if (TmpPerDiscount."Amount to Trigger" <> 0) then
            if TmpPerDiscount."Amt. to Trigger Based on Lines" then begin
                PosTrans.Get(CurrLine."Receipt No.");
                POSTrans.CalcFields("Gross Amount", "Line Discount", "Income/Exp. Amount");
                TotAmount := POSTrans."Gross Amount" + POSTrans."Line Discount" + POSTrans."Income/Exp. Amount";
                TotAmount := PosGenFun.GetDiscOfferLineTotal(TmpPerDiscount, POSTrans, TotAmount);
                if TotAmount < TmpPerDiscount."Amount to Trigger" then begin
                    Found := true;
                    Exclude := true;
                end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Offer Ext. Utility", 'OnCalcTotalOfferOnAfterFindLastPeriodicDiscBenefits', '', false, false)]
    local procedure OnCalcTotalOfferOnAfterFindLastPeriodicDiscBenefits(var PeriodicDiscBenefits: Record "LSC Periodic Discount Benefits"; var pPosTrans: Record "LSC POS Transaction"; var pOffersTemp: Record "LSC Periodic Discount"; var IsHandled: Boolean; PeriodicDiscount: Record "LSC Periodic Discount"; pTotalAmount: Decimal)
    var
        PosGenFun: Codeunit "Pos_General Functions_NT";
        TotalAmount: Decimal;
    begin
        IF PeriodicDiscount."Amt. to Trigger Based on Lines" THEN
            TotalAmount := PosGenFun.DiscOfferLineTotal(PeriodicDiscount, pPosTrans, pTotalAmount)
        ELSE
            TotalAmount := pTotalAmount;
        PeriodicDiscBenefits.SetFilter("Step Amount", '<=%1', TotalAmount);
        if not PeriodicDiscBenefits.FindLast then
            IsHandled := true; //To SKIP the Benefit
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Offer Ext. Utility", 'OnBeforeCalcTransTotal', '', false, false)]
    local procedure OnBeforeCalcTransTotal(var POSTransaction: Record "LSC POS Transaction"; var TotalAmount: Decimal; var IsHandled: Boolean)
    var
        PosGenFn: Codeunit "Pos_General Functions_NT";
    begin
        TotalAmount := PosGenFn.CalcTransTotal_LSCPOSOfferExtUtility(POSTransaction);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTotalExecuted', '', false, false)]
    local procedure OnAfterTotalExecuted(var POSTransaction: Record "LSC POS Transaction")
    var
        PeriodicDisc: Record "LSC Periodic Discount";
        TransBenefitCollectBuffer2: Record "LSC Trans. Disc. Benefit Entry" temporary;
        PosGenFun: Codeunit "Pos_General Functions_NT";
        PosSession: Codeunit "LSC POS Session";
        PosTrans: Codeunit "LSC POS Transaction";
        POSGUI: Codeunit "LSC POS GUI";
    begin
        PosGenFun.CollectTransAddBenefits2(POSTransaction."Receipt No.", TransBenefitCollectBuffer2);
        if TransBenefitCollectBuffer2.FindSet() then
            repeat
                if TransBenefitCollectBuffer2."Popup Message" <> '' then begin
                    //PosTrans.PosMessage(TransBenefitCollectBuffer2."Popup Message")//BC Upgrade
                    // if PosSession.BannerOnMessage() then
                    //     PosTrans.PosMessageBanner(TransBenefitCollectBuffer2."Popup Message")
                    // else
                    //     PosTrans.PosMessage(TransBenefitCollectBuffer2."Popup Message");
                    POSGUI.PosMessage(TransBenefitCollectBuffer2."Popup Message");
                end else begin
                    if PeriodicDisc.GET(TransBenefitCollectBuffer2."Offer No.") THEN
                        if PeriodicDisc."POS Popup Message" <> '' then
                            //PosTrans.PosMessage(PeriodicDisc."POS Popup Message");//BC Upgrade
                            // PosTrans.PosMessage(TransBenefitCollectBuffer2."Popup Message")
                            //else
                            //  PosTrans.PosMessage(TransBenefitCollectBuffer2."Popup Message");
                            POSGUI.PosMessage(PeriodicDisc."POS Popup Message")
                end;
            until TransBenefitCollectBuffer2.NEXT = 0;

        PosGenFun.NotUsedCouponsCheckInputNeeded(POSTransaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnBeforeApplicableFilterChecksInFindPeriodicOffers', '', false, false)]
    local procedure OnBeforeApplicableFilterChecksInFindPeriodicOffers(POSTransaction: Record "LSC POS Transaction"; CurrLine: Record "LSC POS Trans. Line"; var PeriodicDiscountTemp: Record "LSC Periodic Discount"; var IsHandled: Boolean)
    begin
        if PeriodicDiscountTemp."Valid Only When Member Scanned" then
            if not POSTransaction."QR Code Used" then
                IsHandled := true;//SKIP Offer
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Offer Ext. Utility", 'OnBeforeCheckingAllPeriodicDiscountType', '', false, false)]
    local procedure OnBeforeCheckingAllPeriodicDiscountType(var PeriodicDiscountLines: Record "LSC Periodic Discount Line"; var Found: Boolean; var PosTransLineTemp: Record "LSC POS Trans. Line"; var PeriodicDiscount: Record "LSC Periodic Discount"; DateToUse: Date; TimeToUse: Time; var Exclude: Boolean)
    var
        POSTransaction: Record "LSC POS Transaction";
    begin
        POSTransaction.Get(PosTransLineTemp."Receipt No.");
        if PeriodicDiscount."Valid Only When Member Scanned" then
            if not POSTransaction."QR Code Used" then begin
                Found := true;//Skip Offer
                Exclude := true;//Skip Offer
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Coupon Management", 'OnIsCouponValidOnBeforeValidateCouponHeader', '', false, false)]
    local procedure OnIsCouponValidOnBeforeValidateCouponHeader(var CouponHeader: Record "LSC Coupon Header"; var POSTransaction: Record "LSC POS Transaction"; var ErrorMsg: Text[250]; var Result: Boolean; var IsHandled: Boolean)
    var
        GenFunc: Codeunit "Pos_General Functions_NT";
        POSTransCU: Codeunit "LSC POS Transaction";
    begin
        if CouponHeader."Point Value" > 0 then begin
            //IF NOT POSTransaction.GET(POSTransactionCodeunit.GetReceiptNo) THEN //BC Upgrade
            //EXIT(FALSE);//BC Upgrade
            POSTransaction.CalcFields("Point Value");
            if CouponHeader."Point Value" + POSTransaction."Point Value" > POSTransaction."Starting Point Balance" then begin
                ErrorMsg := 'Not enough points for this coupon.';
                IsHandled := true;
                Result := false;
            end;
        end;
        if not GenFunc.IsValidCouponAttributes(CouponHeader, POSTransaction, ErrorMsg) then begin
            IsHandled := true;
            Result := false;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeCheckMemberCard', '', false, false)]
    local procedure OnBeforeCheckMemberCard(var PosTransaction: Record "LSC POS Transaction"; var MemberAccountTemp: Record "LSC Member Account"; var MemberContactTemp: Record "LSC Member Contact"; var MembershipCardTemp: Record "LSC Membership Card"; var Handled: Boolean)
    var
        PosFunc: Codeunit "LSC POS Functions";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        StartingPoint: BigInteger;
    begin
        PosTransaction."QR Code Used" := PosFunc.QRCardNo = MembershipCardTemp."Card No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterUpdateMemberContext', '', false, false)]
    local procedure OnAfterUpdateMemberContext(var POSTransaction: Record "LSC POS Transaction"; POSFunction: Codeunit "LSC POS Functions")
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        POSSESSION: Codeunit "LSC POS Session";
    begin
        // POSSESSION.SetValue('MemberAccountPointBalance', PosGenFunc.GetMemberAccountPointBalance(POSTransaction));//BC Upgrade
        POSSESSION.SetValue('MembershipCard', POSTransaction."Member Card No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnBeforeProcessScannerInput', '', false, false)]
    local procedure OnBeforeProcessScannerInput(var Sender: Codeunit "LSC POS Transaction"; var pScanInput: Text; StoreSetup: Record "LSC Store")
    var
        MenuHead: Record "LSC POS Menu Header"; //SKASH
        MenuHeader: Record "LSC POS Menu Header";//SKASH
        MenuLine2: Record "LSC POS Menu Line";//SKASH
        POSDataEntryType: Record "LSC POS Data Entry Type";
        POS: Codeunit "LSC POS Session";
        PosGenFun: Codeunit "Pos_General Functions_NT";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        POSSESSION: Codeunit "LSC POS Session";//SKASH
        POSView: Codeunit "LSC POS View";
        STATE_PAYMENT: Code[10];
        Amount: Decimal;
        CurrInput: Text;
        DecryptedInput: Text;
        ErrorMSG: Text;
        FunctionSetup: Record "LSC POS Command";
        BcUtil: Codeunit "LSC Barcode Management";
        PosFunc: Codeunit "LSC POS Functions";
        BMFound: Boolean;
        DummyBool: Boolean;
        BarcodeMask: Record "LSC Barcode Mask";
        ItemNo: Code[20];
        PosMenuLine: Record "LSC POS Menu Line";
        DummyCode: code[10];

    begin
        STATE_PAYMENT := 'PAYMENT';
        CurrInput := pScanInput;
        //STArt=====================   

        //if PosEvent.Sender = POSSession.CurrInputID then begin
        //CurrInput := PosEvent.StrData;
        If pScanInput = '' then
            exit;
        //Length checking removed
        //if (POSView.GetPosState() = STATE_PAYMENT) and (StrLen(CurrInput) in [9, 13]) then begin
        if (POSView.GetPosState() = STATE_PAYMENT) then begin
            if PosGenFunc.GetDataEntryType(CurrInput, POSDataEntryType) then begin
                if PosGenFunc.InputIsGiftVoucher(POSDataEntryType.Code, Amount, ErrorMSG, CurrInput, STATE_PAYMENT) then begin
                    PosGenFunc.ProcessGiftVoucher(POSDataEntryType, CurrInput, Amount, ErrorMSG, STATE_PAYMENT);
                    if ErrorMSG <> '' then
                        POSView.ErrorBeep(ErrorMSG);
                    //else
                    ///  pScanInput := '';
                    //Always clear CurrInput else it creates incorrect data entry
                    pScanInput := '';
                end else begin
                    POSView.MessageBeep(ErrorMSG);
                    pScanInput := '';
                end;
            end else
                POSView.MessageBeep('');
        end;

        //SKASH START
        if POSSession.GetPosMenuRec(POSView.GetCurrMenu(0), MenuHead) then
            MenuHeader := MenuHead;
        if MenuHeader."Map Enter To" <> '' then
            if MenuHeader."Map Enter To" = 'SKASH' then begin
                MenuLine2.Command := MenuHeader."Map Enter To";
                MenuLine2.Parameter := MenuHeader."Map Parameter";
                POSView.InitCommand;
                //CurrInput := PosEvent.StrData;
                POSView.SetCurrInput(CurrInput);
                if MenuLine2.Command <> '' then begin
                    ClearLastError;
                    POSView.Run(MenuLine2);
                    Commit;
                    //clear(CurrInput);
                    clear(pScanInput);
                    //POSView.SetCurrInput(CurrInput);
                end;
            end;
        //SKASH END

        //end;

        //END============

        FunctionSetup.Get(POSView.GetFunctionMode());
        case FunctionSetup."Function Code" of
            'VOID_SI':
                begin
                    //CurrInput := posview.GetCurrInput();
                    CurrInput := pScanInput;
                    BMFound := BcUtil.FindBarcodeMask(CopyStr(CurrInput, 1, 22), BarcodeMask);
                    if BMFound then
                        if BarcodeMask.Type = BarcodeMask.Type::Item then begin
                            PosFunc.GetBarcItemInfo(COPYSTR(CurrInput, 1, 22), BarcodeMask, ItemNo, DummyBool, DummyBool, DummyCode);
                            PosFunc.GetBarcItemInfo(CopyStr(CurrInput, 1, 22), BarcodeMask, ItemNo, DummyBool, DummyBool, DummyCode);
                            if ItemNo <> '' then
                                CurrInput := ItemNo;
                        end;
                    PosMenuLine.Init();
                    PosMenuLine.Command := FunctionSetup."Function Code";
                    PosMenuLine."Current-RECEIPT" := POSView.GetReceiptNo();
                    PosMenuLine."Current-INPUT" := CurrInput;
                    Codeunit.Run(FunctionSetup."Run Codeunit", PosMenuLine);
                    //IsHandled := true;
                    pScanInput := '';
                end;
        end;

        DecryptedInput := (PosGenFun.ProcessScannerData(pScanInput));
        if DecryptedInput = '' then
            exit;
        pScanInput := DecryptedInput;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnProcessBarcode', '', false, false)]
    local procedure OnProcessBarcode(var POSTransaction: Record "LSC POS Transaction"; var BarcodeMask: Record "LSC Barcode Mask"; var CurrInput: Text; var Proceed: Boolean)
    var
        POSView: Codeunit "LSC POS View";
        STATE_PAYMENT: Code[10];
        InvalidDataEntryErr: Label 'Data Entry must be scanned after Total presssed.';
    begin
        STATE_PAYMENT := 'PAYMENT';
        //Data Entries Must be scanned at total for processing other wise creates incorrect Infocode entries
        if (POSView.GetPosState() <> STATE_PAYMENT) then
            if BarcodeMask.Type = BarcodeMask.Type::"Data Entry" then begin
                POSView.MessageBeep(InvalidDataEntryErr);
                Proceed := false;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeInsertPaymentEntryV2', '', false, false)]
    local procedure OnBeforeInsertPaymentEntryV2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLineTemp: Record "LSC POS Trans. Line"; var TransPaymentEntry: Record "LSC Trans. Payment Entry")
    begin
        //TransPaymentEntry."EFT Transaction System ID" := POSTransLineTemp."EFT Transaction System ID"; // NT
        TransPaymentEntry."Point Value" := POSTransLineTemp."Point Value"; // NT
        TransPaymentEntry."sKash Entry No." := POSTransLineTemp."sKash Entry No."; // NT
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransHeader', '', false, false)]
    local procedure OnAfterInsertTransHeader(var Transaction: Record "LSC Transaction Header"; var POSTrans: Record "LSC POS Transaction")
    begin
        POSTrans.CalcFields("Point Value");
        Transaction."Point Value" := POSTrans."Point Value";
        Transaction."Continuity Member No." := POSTrans."Continuity Member No.";
        Transaction."QR Code Used" := POSTrans."QR Code Used";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeMemberPointCalculation', '', false, false)]
    local procedure OnBeforeMemberPointCalculation(TransactionHeader: Record "LSC Transaction Header"; var IsHandled: Boolean)
    var
        CalcMemberPoints_NT: codeunit "Pos_Calc.Member Points_NT";
    begin
        CalcMemberPoints_NT.UpdateMemberFromPOS(TransactionHeader);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeProcessBarcode', '', false, false)]
    local procedure OnBeforeProcessBarcode(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var IsHandled: Boolean)
    var
        DrawerDevice: Record "LSC POS Drawer";
        PosSetup: Record "LSC POS Hardware Profile";
        OposUtil: Codeunit "LSC POS OPOS Utility";
        PosContinuityMgt: Codeunit "Pos_Continuity Management_NT";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        POSSESSION: Codeunit "LSC POS Session";
        PosTransCU: Codeunit "LSC POS Transaction";
        DeviceID: Code[20];
        RoleID: Code[10];
        SubRoleID: Code[20];
        TmpText: Text;
    begin
        PosContinuityMgt.CheckContinuityInProcessScannerInput(CurrInput, POSTransaction, IsHandled);
        if (StrLen(CurrInput) > 13) AND (CopyStr(CurrInput, 1, 1) = 'F') then
            if PosGenFunc.CheckBarcode(COPYSTR(CurrInput, 2, 13)) then begin
                PosGenFunc.MultipleBarcodesPressed(CurrInput);
                IsHandled := true;
            end;
        if PosSetup.Get(POSSESSION.HardwareProfileID()) then
            //if PosSetup."Drawer Alert if Open" then //BC22 Upgrade

            if (PosSetup.GetDevice("LSC Hardware Profile Devices"::Drawer, RoleID, SubRoleID, 0, DeviceID)) then begin
                DrawerDevice.Get(DeviceID);
                if OposUtil.IsAnyDrawerOpen(TmpText) then begin
                    PosTransCU.ErrorBeep('Drawer Is Open');
                    IsHandled := true;
                end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnVoidTransaction', '', false, false)]
    local procedure OnVoidTransaction(var POSTrans: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        PosFuncProfile: Record "LSC POS Func. Profile";
        ContinuityMgmt: Codeunit "Pos_Continuity Management_NT";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        POSSESSION: Codeunit "LSC POS Session";
        PosTransCU: Codeunit "LSC POS Transaction";
    begin
        ContinuityMgmt.VoidContinuityCouponEntry(POSTrans);
        PosGenFunc.VoidDataEntry(POSTrans);
        if (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Payment) and
          (POSTransLine."Entry Status" = POSTransLine."Entry Status"::" ") and
          (POSTransLine."Coupon Barcode No." <> '') and
          (POSTransLine."Coupon Code" <> '')
        then
            PosTransCU.CouponResetReservation(POSTransLine);
        if POSTrans."Retrieved from Receipt No." <> '' then
            if PosFuncProfile.Get(POSSESSION.FunctionalityProfileID()) then
                if PosFuncProfile."TS Void Transactions" or PosFuncProfile."DD Void Transactions" then
                    PosGenUtil.SetSendTrans(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnVoidLine', '', false, false)]
    local procedure OnVoidLine(var POSTransLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    var
        POSTransaction: Record "LSC POS Transaction";
        ContinuityMgmt: Codeunit "Pos_Continuity Management_NT";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        IsHandled := false;//Required for Voiding Coupons
        POSTransaction.Get(POSTransLine."Receipt No.");
        ContinuityMgmt.VoidLineContinuityCouponEntry(POSTransaction, POSTransLine);
        PosGenFunc.VoidLineDataEntry(POSTransLine);

        if (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Payment) and
          (POSTransLine."Entry Status" = POSTransLine."Entry Status"::" ") and
          (POSTransLine."Coupon Barcode No." <> '') and
          (POSTransLine."Coupon Code" <> '')
        then
            PosGenFunc.CouponResetReservation(POSTransLine);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeVoidLine', '', false, false)]
    // local procedure OnBeforeVoidLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var Handled: Boolean; var HandledErrorText: Text; var ReturnValue: Boolean)
    // var
    //     MemberVoidErrTxt: Label 'You can not void member line.\Void transaction or change Member.';
    // begin
    //     if (POSTransLine."Text Type" = POSTransLine."Text Type"::"Member Text") and (POSTransaction."Member Card No." <> '') then begin  //member void
    //         HandledErrorText := MemberVoidErrTxt;
    //         Handled := true;
    //         ReturnValue := false;
    //     end;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterVoidLine', '', false, false)]
    local procedure OnAfterVoidLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line");
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        PosGenFunc.VoidMemberCouponLines(POSTransLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeCreatePOSTransLineTmpCompressPaymentTrans', '', false, false)]
    local procedure OnBeforeCreatePOSTransLineTmpCompressPaymentTrans(POSTransaction: Record "LSC POS Transaction"; POSPaymentEntry: Record "LSC POS Trans. Line"; TenderTypes: Record "LSC Tender Type"; var POSTransLineTmp: Record "LSC POS Trans. Line"; CompressAll: Boolean; TransPositive: Boolean; var Compressed: Boolean; var IsHandled: Boolean)
    var
        LastInfoEntry: Record "LSC POS Trans. Infocode Entry";
        POSTransInfocodeEntry: Record "LSC POS Trans. Infocode Entry";
    begin
        IsHandled := POSPaymentEntry."Point Value" <> 0;
        if IsHandled then begin
            if (POSPaymentEntry.Amount > 0) and
                                   (TenderTypes."Compress Paym. Entries" or CompressAll) and
                                   (POSPaymentEntry."Entry Status" = 0)
                                then begin
                POSTransLineTmp.SetRange("Receipt No.", POSPaymentEntry."Receipt No.");
                POSTransLineTmp.SetRange("Entry Type", POSPaymentEntry."Entry Type");
                POSTransLineTmp.SetRange(Number, POSPaymentEntry.Number);
                POSTransLineTmp.SetRange("Entry Status", POSPaymentEntry."Entry Status");
                POSTransLineTmp.SetRange("Coupon EAN Org.", POSPaymentEntry."Coupon EAN Org.");
                POSTransLineTmp.SetRange("Card/Customer/Coup.Item No", POSPaymentEntry."Card/Customer/Coup.Item No");
                POSTransLineTmp.SetRange("Currency Code", POSPaymentEntry."Currency Code");
                if POSTransLineTmp.FindFirst then begin
                    POSTransInfocodeEntry.SetRange("Receipt No.", POSPaymentEntry."Receipt No.");
                    POSTransInfocodeEntry.SetRange("Transaction Type", POSTransInfocodeEntry."Transaction Type"::"Payment Entry");
                    POSTransInfocodeEntry.SetRange("Line No.", POSPaymentEntry."Line No.");
                    if POSTransInfocodeEntry.IsEmpty then
                        Clear(POSTransInfocodeEntry);
                    LastInfoEntry.SetRange("Receipt No.", POSTransLineTmp."Receipt No.");
                    LastInfoEntry.SetRange("Transaction Type", LastInfoEntry."Transaction Type"::"Sales Entry");
                    LastInfoEntry.SetRange("Line No.", POSTransLineTmp."Line No.");
                    if LastInfoEntry.IsEmpty then
                        Clear(LastInfoEntry);
                    if (POSTransaction."Sale Is Return Sale") and (TransPositive) then
                        POSTransInfocodeEntry."Receipt No." := POSPaymentEntry."Receipt No."; //No compress
                    if (LastInfoEntry."Receipt No." = '') and (POSTransInfocodeEntry."Receipt No." = '') then begin
                        POSTransLineTmp.Amount := POSTransLineTmp.Amount + POSPaymentEntry.Amount;
                        POSTransLineTmp.Quantity := POSTransLineTmp.Quantity + POSPaymentEntry.Quantity;
                        POSTransLineTmp."Amount In Currency" += POSPaymentEntry."Amount In Currency";
                        POSTransLineTmp."Point Value" += POSPaymentEntry."Point Value";//NT
                        POSTransLineTmp.Modify;
                        Compressed := true;
                    end;
                end;
            end;
            if not Compressed then begin
                POSTransLineTmp.Init;
                POSTransLineTmp := POSPaymentEntry;
                POSTransLineTmp.Insert;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterPostTransaction', '', false, false)]
    local procedure OnAfterPostTransaction(var TransactionHeader_p: Record "LSC Transaction Header");
    var
        TransContinuityEntry: Record "Pos_Trans. Continuity Entry_NT";
        ContinuityMgt: Codeunit "Pos_Continuity Management_NT";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        if TransactionHeader_p."Entry Status" = TransactionHeader_p."Entry Status"::" " then begin
            Clear(TransContinuityEntry);
            IF TransactionHeader_p."Sale Is Return Sale" then
                ContinuityMgt.SalesReversal(TransactionHeader_p, TransContinuityEntry)
            else
                if not ContinuityMgt.SalesAdvice(TransactionHeader_p, TransContinuityEntry) then
                    ContinuityMgt.SalesReversal(TransactionHeader_p, TransContinuityEntry);
        end;
        PosGenFunc.InsertTransTopUpEntry(TransactionHeader_p);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertItemLine', '', false, false)]
    local procedure OnAfterInsertItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        Item: Record Item;
        PosGenUtility: Codeunit "Pos_General Utility_NT";
        TopupMgt: Codeunit "Pos_Topup Management_NT";
    begin
        if POSTransLine."Entry Type" = POSTransLine."Entry Type"::Item then
            PosGenUtility.SetLastItemLine(POSTransLine);

        if (POSTransLine.Quantity > 0) AND (NOT POSTransaction."Sale Is Return Sale") then begin
            Item.Get(POSTransLine.Number);
            if Item."Topup Item" then
                TopupMgt.InsertTopUpLine(POSTransLine, POSTransaction);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnOkNewInput', '', false, false)]
    local procedure OnOkNewInput(FunctionSetup: Record "LSC POS Command"; var IsHandled: Boolean)
    var
        POSDataEntryType: Record "LSC POS Data Entry Type";
        PosMenuLine: Record "LSC POS Menu Line" temporary;
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
        POSView: Codeunit "LSC POS View";
        FC: Code[20];
        STATE_PAYMENT: Code[10];
        Amount: Decimal;
        CurrInput: Text;
        ErrorMSG: Text;
    begin
        STATE_PAYMENT := 'PAYMENT';
        fc := PosView.GetFunctionMode();
        case FunctionSetup."Function Code" of
            'VOID_SI':
                begin
                    // PosMenuLine.Init();
                    // PosMenuLine.Command := FunctionSetup."Function Code";
                    // PosMenuLine."Current-RECEIPT" := POSView.GetReceiptNo();
                    // PosMenuLine."Current-INPUT" := POSView.GetCurrInput();
                    // Codeunit.Run(FunctionSetup."Run Codeunit", PosMenuLine);
                    IsHandled := true;
                end;
        end;
        /*
        CurrInput := POSView.GetCurrInput();
        if (POSView.GetPosState() = STATE_PAYMENT) and (StrLen(CurrInput) in [9, 13]) then begin
            if PosGenFunc.GetDataEntryType(CurrInput, POSDataEntryType) then begin
                if PosGenFunc.InputIsGiftVoucher(POSDataEntryType.Code, Amount, ErrorMSG, CurrInput, STATE_PAYMENT) then begin
                    PosGenFunc.ProcessGiftVoucher(POSDataEntryType, CurrInput, Amount, ErrorMSG, STATE_PAYMENT);
                    if ErrorMSG <> '' then
                        POSView.ErrorBeep(ErrorMSG);
                end else
                    POSView.MessageBeep(ErrorMSG);
            end else
                POSView.MessageBeep('');
        end;
        */
    end;


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnProcessBarcode', '', false, false)]
    // local procedure OnProcessBarcode(var POSTransaction: Record "LSC POS Transaction"; var BarcodeMask: Record "LSC Barcode Mask"; var CurrInput: Text; var Proceed: Boolean)
    // var
    //     PosTransCU: Codeunit "LSC POS Transaction";
    //     PosFunc: Codeunit "LSC POS Functions";
    //     ItemNo: Code[20];
    //     DummyBool: Boolean;
    //     DummyCode: Code[10];
    //     PosMenuLine: Record "LSC POS Menu Line" temporary;
    //     FunctionCode: Code[20];
    //     FunctionSetup: Record "LSC POS Command";
    // begin
    //     FunctionCode := PosTransCU.GetFunctionMode();
    //     case PosTransCU.GetFunctionMode() of
    //         'VOID_SI':
    //             begin
    //                 FunctionSetup.Get(FunctionCode);
    //                 PosFunc.GetBarcItemInfo(COPYSTR(CurrInput, 1, 22), BarcodeMask, ItemNo, DummyBool, DummyBool, DummyCode);
    //                 CurrInput := ItemNo;
    //                 PosMenuLine.Init();
    //                 PosMenuLine.Command := FunctionSetup."Function Code";
    //                 PosMenuLine."Current-RECEIPT" := POSTransaction."Receipt No.";
    //                 PosMenuLine."Current-INPUT" := CurrInput;
    //                 Codeunit.Run(FunctionSetup."Run Codeunit", PosMenuLine);
    //                 Proceed := false;
    //             end;
    //     END;
    //     // ValidateInput;
    //     // EXIT(TRUE);
    // END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnBeforeValidateInputEx', '', false, false)]
    local procedure OnBeforeValidateInputEx(var Sender: Codeunit "LSC POS Transaction"; BarcodeMask: Record "LSC Barcode Mask"; FunctionSetup: Record "LSC POS Command"; OkNewInput: Boolean; var IsHandled: Boolean)
    var
        PosMenuLine: Record "LSC POS Menu Line" temporary;
        BcUtil: Codeunit "LSC Barcode Management";
        PosFunc: Codeunit "LSC POS Functions";
        POSView: Codeunit "LSC POS View";
        BMFound: Boolean;
        DummyBool: Boolean;
        DummyCode: Code[10];
        ItemNo: Code[20];
        CurrInput: Text;
    begin
        case FunctionSetup."Function Code" of
            'VOID_SI':
                begin
                    CurrInput := posview.GetCurrInput();
                    BMFound := BcUtil.FindBarcodeMask(CopyStr(CurrInput, 1, 22), BarcodeMask);
                    if BMFound then
                        if BarcodeMask.Type = BarcodeMask.Type::Item then begin
                            PosFunc.GetBarcItemInfo(COPYSTR(CurrInput, 1, 22), BarcodeMask, ItemNo, DummyBool, DummyBool, DummyCode);
                            PosFunc.GetBarcItemInfo(CopyStr(CurrInput, 1, 22), BarcodeMask, ItemNo, DummyBool, DummyBool, DummyCode);
                            if ItemNo <> '' then
                                CurrInput := ItemNo;
                        end;
                    PosMenuLine.Init();
                    PosMenuLine.Command := FunctionSetup."Function Code";
                    PosMenuLine."Current-RECEIPT" := POSView.GetReceiptNo();
                    PosMenuLine."Current-INPUT" := CurrInput;
                    Codeunit.Run(FunctionSetup."Run Codeunit", PosMenuLine);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransactionsProcessTransactionsV2', '', false, false)]
    local procedure OnAfterInsertTransactionsProcessTransactionsV2(var TransactionHeader: Record "LSC Transaction Header"; var TransSalesEntryTemp: Record "LSC Trans. Sales Entry"; PaymentEntryTemp: Record "LSC Trans. Payment Entry");
    var
        Item: Record Item;
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        LoyaltyGrossAmt: Decimal;
    begin
        TransSalesEntryTEMP.Reset;
        if not TransSalesEntryTEMP.IsEmpty then
            if TransSalesEntryTemp.FindSet() then
                repeat
                    if not Item.Get(TransSalesEntryTemp."Item No.") then
                        Clear(Item);
                    if not Item."No Loyalty Points" then
                        LoyaltyGrossAmt += (TransSalesEntryTemp."VAT Amount" + TransSalesEntryTemp."Net Amount");
                until TransSalesEntryTemp.Next() = 0;
        if LoyaltyGrossAmt <> 0 then
            TransactionHeader."Loyalty Gross Amount" := LoyaltyGrossAmt;

        PosGenFunc.InsertPosTopUpEntryToTempTransTopupEntry(TransactionHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnInsertCouponLineBeforeInsertLine', '', false, false)]
    local procedure OnInsertCouponLineBeforeInsertLine(var PosTransaction: Record "LSC POS Transaction"; var NewLine: Record "LSC POS Trans. Line"; CouponHeader: Record "LSC Coupon Header"; DiscountValue: Decimal; var IsHandled: Boolean)
    var
        PosGenUtility: Codeunit "Pos_General Utility_NT";
        VchCode: Text[30];
    begin
        // if PosTransaction."Continuity Voucher No. Temp" <> '' then
        //     NewLine."Continuity Voucher No." := PosTransaction."Continuity Voucher No. Temp";
        PosGenUtility.GetContinuityVoucher(VchCode);
        NewLine."Continuity Voucher No." := VchCode;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure OnAfterSubstituteReport(ReportId: Integer; RunMode: Option; RequestPageXml: Text; RecordRef: RecordRef; var NewReportId: Integer);
    begin
        if ReportId = Report::"LSC POS OPOS Emulation Report" then
            NewReportId := Report::"POS_OPOS Emulation Report_NT";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeSendeMail', '', false, false)]
    local procedure OnBeforeSendeMail(var Sender: Codeunit "LSC POS Print Utility"; var MailRecipients: Text; var PrintBuffer: Record "LSC POS Print Buffer"; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        ReturnValue := PosGenFunc.SendEmail_Copy(MailRecipients, PrintBuffer);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeEmailOrPrintV2', '', false, false)]
    local procedure OnBeforeEmailOrPrintV2(POSHardwareProfile: Record "LSC POS Hardware Profile"; POSTerminal: Record "LSC POS Terminal"; LastTransaction: Record "LSC Transaction Header"; var POSTransPostingStateTmp: Record "LSC POS Trans. Posting State" temporary; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        POSGenFn: Codeunit "Pos_General Functions_NT";
    begin
        ReturnValue := POSGenFn.EmailOrPrint(POSHardwareProfile, POSTerminal, LastTransaction, POSTransPostingStateTmp);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Requests Mgt", 'OnBeforePrintSlips', '', false, false)]
    local procedure OnBeforePrintSlips(var POSPendingRequests: Record "LSC POS Pending Requests"; var IsHandled: Boolean)
    begin
        if POSPendingRequests."Request ID" = 'SLIPEMAIL' then
            IsHandled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Functions", 'OnBeforeIsPurgeOverDue', '', false, false)]
    local procedure OnBeforeIsPurgeOverDue(PosTrans: Record "LSC POS Transaction"; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        if PosGenFunc.IsPurgeOverDue() then
            PosGenFunc.Purge();
        IsHandled := true;
        ReturnValue := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeItemLine', '', false, false)]
    local procedure OnBeforeItemLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        PosView: Codeunit "LSC POS View";
    begin
        if (StrLen(CurrInput) > 13) AND (CopyStr(CurrInput, 1, 1) = 'F') then
            if PosGenFunc.CheckBarcode(COPYSTR(CurrInput, 2, 13)) then begin
                PosGenFunc.MultipleBarcodesPressed(CurrInput);
                PosView.SetFunctionMode('ENTER');// BC22 To Exit ItemLine function
                CurrInput := '';// To Exit ItemLine function                
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterTenderKeyPressedEx', '', false, false)]
    local procedure OnAfterTenderKeyPressedEx(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var TenderAmountText: Text; var IsHandled: Boolean)
    var
        TenderType: Record "LSC Tender Type";
        PosTransCU: Codeunit "LSC POS Transaction";
        Balance: Decimal;
        RealBalance: Decimal;
    begin

        if TenderType.Get(POSTransaction."Store No.", TenderTypeCode) then
            if TenderType."Only Negative Transaction" then begin
                POSTransaction.CalcFields("Gross Amount", "Line Discount", Payment, "Net Amount", "Total Discount", "Income/Exp. Amount", Prepayment);
                Balance := POSTransaction."Gross Amount" + POSTransaction."Income/Exp. Amount" - POSTransaction.Payment;
                if POSTransaction."Sale Is Return Sale" then
                    RealBalance := -Balance
                else
                    RealBalance := Balance;

                if RealBalance > 0 then begin
                    PosTransCU.ErrorBeep(STRSUBSTNO('%1 is not valid now.', TenderType.Description));
                    IsHandled := true;
                end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterFinalizePosting', '', false, false)]
    local procedure OnAfterFinalizePosting(var LastTransaction: Record "LSC Transaction Header"; POSTransPostingStateTmp: Record "LSC POS Trans. Posting State")
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
        LastErrorText: Text;
        PrintConfirmMsg: Label 'Do you want to print an Invoice?';
    begin
        if POSTransPostingStateTmp.Print and (not POSTransPostingStateTmp."Training Active") and (LastTransaction."Customer No." <> '') and
            (LastTransaction."Transaction Type" = LastTransaction."Transaction Type"::Sales) and
            (LastTransaction."Entry Status" <> LastTransaction."Entry Status"::Voided) then
            if PosTransCU.PosConfirm(PrintConfirmMsg, true) then
                if not PosGenFunc.PrintTransInvoice(LastTransaction, LastErrorText) then
                    PosTransCU.PosMessage(LastErrorText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeRunCommand', '', false, false)]
    local procedure OnBeforeRunCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var POSMenuLine: Record "LSC POS Menu Line"; var isHandled: Boolean; TenderType: Record "LSC Tender Type"; var CusomterOrCardNo: Code[20])
    var
        POSMenuLine2: Record "LSC POS Menu Line";
        POSCtrl: Codeunit "LSC POS Control Interface";
        POSSession: Codeunit "LSC POS Session";
        PosTransCU: Codeunit "LSC POS Transaction";
        MultiplyValue: Decimal;
        InvalidValInQtyErr: Label 'Invalid value in quantity';
    begin
        case POSMenuLine.Command of
            'QTY':
                begin
                    if CurrInput = '' then begin
                        //BC22 Upgrade
                        POSMenuLine2 := POSMenuLine;
                        POSMenuLine2.Command := 'QTYCH';
                        POSMenuLine2.Parameter := '+';
                        POSMenuLine2."Current-LINE" := POSTransLine."Line No.";
                        //PosTransCU.ChangeQtyPressed('+'); 
                        if PosTransCU.RunCommand(POSMenuLine2) then
                            isHandled := true;
                    end else begin
                        // POSMenuLine2 := POSMenuLine;
                        // POSMenuLine2.Command := 'QTY';
                        // POSMenuLine2.Parameter := CurrInput;
                        // POSMenuLine2."Current-LINE" := POSTransLine."Line No.";
                        // //PosTransCU.ChangeQtyPressed('+'); 
                        // if PosTransCU.RunCommand(POSMenuLine2) then
                        //     isHandled := true;
                        if Evaluate(MultiplyValue, CurrInput) then begin
                            if MultiplyValue <> Round(MultiplyValue, 1) then begin
                                PosTransCU.ErrorBeep(InvalidValInQtyErr);
                                isHandled := true;
                                exit;
                            end;
                        end;
                        POSMenuLine.Parameter := CurrInput;
                    end;
                end;
            'MEMBERCARD':
                begin
                    if (POSCtrl.ActivePanel() = POSSession.OfflinePanelID()) OR (POSCtrl.ActivePanel() = POSSession.LoginPanelID()) then begin
                        CurrInput := '';
                        isHandled := true;
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeInsertDiscountEntry', '', false, false)]
    local procedure OnBeforeInsertDiscountEntry(var DiscountEntryTmp: Record "LSC Trans. Discount Entry" temporary; var SalesEntry: Record "LSC Trans. Sales Entry");
    var
        PosGenFn: Codeunit "Pos_General Functions_NT";
    begin
        if (SalesEntry."Periodic Disc. Type" = SalesEntry."Periodic Disc. Type"::"Disc. Offer") and
           (SalesEntry."Periodic Disc. Group" <> '') then
            PosGenFn.GetOfferDetails(SalesEntry."Periodic Disc. Group", SalesEntry."Item No.", SalesEntry."Discount Offer No.", SalesEntry."Discount Offer Description");
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Infocode Utility", 'OnBeforeTypeApplyToEntry', '', false, false)]
    // local procedure OnBeforeTypeApplyToEntry(Input: Text; MgrKeyActive: Boolean; Training: Boolean; var TSError: Boolean; var Line: Record "LSC POS Trans. Line"; var Trans: Record "LSC POS Transaction"; var InfoCodeRec: Record "LSC Infocode"; var ErrorTxt: Text; var IsHandled: Boolean; var ReturnValue: Boolean)
    // var
    //     DataEntryType: Record "LSC POS Data Entry Type";
    //     _DataEntry: Record "LSC POS Data Entry";
    //     _POSTransInfoEntry: Record "LSC POS Trans. Infocode Entry";
    //     NT000: Label 'Voucher already used.';
    // begin        
    //     DataEntryType.Get(InfoCodeRec."Data Entry Type");
    //     if DataEntryType."Data Entry Only Allowed" then
    //         if _DataEntry.GET(DataEntryType.Code, Input) then begin
    //             Clear(_POSTransInfoEntry);
    //             _POSTransInfoEntry.SetRange("Receipt No.", Line."Receipt No.");
    //             _POSTransInfoEntry.SetRange("Transaction Type", _POSTransInfoEntry."Transaction Type"::"Payment Entry");
    //             _POSTransInfoEntry.SetRange(Infocode, InfoCodeRec.Code);
    //             _POSTransInfoEntry.SetRange(Information, Input);
    //             _POSTransInfoEntry.SetRange(Status, _POSTransInfoEntry.Status::Processed);
    //             if _POSTransInfoEntry.FINDFIRST then begin
    //                 ErrorTxt := NT000;
    //                 IsHandled := true;
    //                 ReturnValue := false;
    //             end;
    //         end;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", 'OnPOSCommand', '', false, false)]
    local procedure OnPOSCommand(var ActivePanel: Record "LSC POS Panel"; var PosMenuLine: Record "LSC POS Menu Line")
    var
        TempStaff: Record "LSC Staff" temporary;
        PosGenUtils: Codeunit "Pos_General Utility_NT";
        PosView: Codeunit "LSC POS View";
    begin
        case PosMenuLine.Command of
            'LOGOFF':
                begin
                    if PosMenuLine.Parameter = 'LOCK' then begin
                        PosGenUtils.SetFromLock(true);
                        PosGenUtils.SetLockSetByStaffID(PosView.GetStaffID());
                    end else begin
                        PosGenUtils.SetLockSetByStaffID('');
                        PosGenUtils.SetFromLock(false);
                        TempStaff.Init();
                        PosView.SetStaffID(TempStaff, '', true);
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS OPOS Utility", 'OnBeforeOpenDrawerEx', '', false, false)]
    local procedure OnBeforeOpenDrawerEx(var retVal: Boolean; var IsHandled: Boolean)
    var
        PosGenUtils: Codeunit "Pos_General Utility_NT";
    begin
        if PosGenUtils.FromLock() then begin
            IsHandled := true;
            retVal := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterGetContext', '', false, false)]
    local procedure OnAfterGetContext(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        PosGenFun: Codeunit "Pos_General Functions_NT";
        PosGenUtils: Codeunit "Pos_General Utility_NT";
        POSSESSION: Codeunit "LSC POS Session";
        FoodAmtTxt: Text;
        NonFoodAmtTxt: Text;
    begin
        if PosGenUtils.FromLock() then
            POSSESSION.SetValue('TransStaffID', PosGenUtils.LockSetByStaffID());
        PosGenFun.GetFoodNonFoodAmtTxt(POSTransaction, FoodAmtTxt, NonFoodAmtTxt);
        POSSESSION.SetValue('FoodAmount', FoodAmtTxt);
        POSSESSION.SetValue('NonFoodAmount', NonFoodAmtTxt);
        PosGenFun.UpdateNegAdjStateTxt2(POSTransaction, POSTransLine, CurrInput);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC POS Trans. Line", 'OnAfterValidateEvent', 'Number', false, false)]
    local procedure OnAfterValidateNumber(var Rec: Record "LSC POS Trans. Line")
    var
        Item: Record Item;
    begin
        if Rec."Entry Type" = Rec."Entry Type"::Item then
            if Item.Get(Rec.Number) then
                Rec."Division Code" := Item."LSC Division Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", 'OnBeforeProcessEvent', '', false, false)]
    local procedure OnBeforeProcessEvent(var PosEvent: Codeunit "LSC POS Event"; var IsHandled: Boolean)
    var
        GenSetup: Record "eCom_General Setup_NT";
        POSDataEntryType: Record "LSC POS Data Entry Type";
        PosMenuLine: Record "LSC POS Menu Line" temporary;
        Staff: Record "LSC Staff";
        POSController: Codeunit "LSC POS Controller";
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        PosGenUtils: Codeunit "Pos_General Utility_NT";
        POSSession: Codeunit "LSC POS Session";
        PosTransCU: Codeunit "LSC POS Transaction";
        POSView: Codeunit "LSC POS View";
        FC: Code[20];
        STATE_PAYMENT: Code[10];
        Amount: Decimal;
        EventType: Enum "LSC POS Event Type";
        CurrInput: Text;
        ErrorMSG: Text;
        ReasonText: Text[80];
        Err001Lbl: Label 'Staff %1 is logged in.';
        PID: Text;
    begin
        STATE_PAYMENT := 'PAYMENT';
        EventType := PosEvent.EventType();
        PID := PosEvent.ActivePanel;
        case EventType of
            EventType::POSFORMLOAD:
                case PosEvent.IntData1 of
                    3:
                        begin
                            PosGenUtils.SetFromLock(false); //Set Lock False at POS LOAD
                            PosGenUtils.SetLockSetByStaffID('');//Set Lock False at POS LOAD
                            PosGenUtils.SetGiftVoucher(false, '');//Initialize Gift Voucher 
                            PosGenUtils.SetSuppressVoidMsg(false);
                            if GenSetup.Get() then
                                PosGenUtils.SetMsgPanelID(GenSetup."POS Message PanelID");
                        end;
                end;
            //All DATA ENTRIES TO BE PROCESSED
            EventType::ENTERPRESSED:
                begin
                    if PosEvent.Sender = POSSession.CurrInputID then begin
                        CurrInput := PosEvent.StrData;
                        If CurrInput = '' then
                            exit;
                        //Length checking removed
                        //if (POSView.GetPosState() = STATE_PAYMENT) and (StrLen(CurrInput) in [9, 13]) then begin
                        if (POSView.GetPosState() = STATE_PAYMENT) then begin
                            if PosGenFunc.GetDataEntryType(CurrInput, POSDataEntryType) then begin
                                if PosGenFunc.InputIsGiftVoucher(POSDataEntryType.Code, Amount, ErrorMSG, CurrInput, STATE_PAYMENT) then begin
                                    PosGenFunc.ProcessGiftVoucher(POSDataEntryType, CurrInput, Amount, ErrorMSG, STATE_PAYMENT);
                                    if ErrorMSG <> '' then
                                        POSView.ErrorBeep(ErrorMSG);
                                end else
                                    POSView.MessageBeep(ErrorMSG);
                            end else
                                POSView.MessageBeep('');
                        end;
                    end;
                end;
            EventType::DEVICEINPUT:
                begin
                    case PosEvent.IntData1 of
                        1: //SCANDATA
                            begin
                                if (PosEvent.ActivePanel = POSSession.OfflinePanelID) or
                                                        (PosEvent.ActivePanel = POSSession.LoginPanelID) then begin
                                    CurrInput := PosEvent.StrData;
                                    //ProcessBarcode();
                                    if PosGenFunc.EmployeeBarcodeScanned(CurrInput) then begin
                                        if not Staff.Get(CurrInput) then
                                            exit;
                                        if (PosEvent.ActivePanel = POSSession.OfflinePanelID) then
                                            IsHandled := true;//Do Nothing. Don't allow Barcode Logon at First Login. Only from Command MGRKEY
                                        if (staff.ID = PosGenUtils.LockSetByStaffID()) AND (PosGenUtils.LockSetByStaffID() <> '') then begin
                                            PosGenUtils.SetFromLock(false);//CLEAR LOCK IF SAME STAFF LOGGED IN
                                            PosGenUtils.SetLockSetByStaffID('');
                                        end;

                                        if (staff.ID <> PosGenUtils.LockSetByStaffID()) AND (PosGenUtils.LockSetByStaffID() <> '') then begin
                                            ReasonText := StrSubstNo(Err001Lbl, PosGenUtils.LockSetByStaffID());
                                            PosTransCU.PosMessage(ReasonText);
                                        end;
                                    end;
                                end;
                            end;
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInit', '', false, false)]
    local procedure OnAfterInit(var POSTransaction: Record "LSC POS Transaction")
    var
        PosTransCU: Codeunit "LSC POS Transaction";
        CurrPOSSate: Code[10];
    begin
        //NT Following is for Dual Display for First time when POS LOADS
        CurrPOSSate := PosTransCU.GetPosState();
        PosTransCU.SetPOSState(Format("LSC POS Transaction State"::TENDOP));
        PosTransCU.SetPOSState(CurrPOSSate);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterRecFound', '', false, false)]
    local procedure OnAfterRecFound(var Rec: Record "LSC POS Transaction")
    var
        PosGenFunc: codeunit "Pos_General Functions_NT";
        PosGenUtil: Codeunit "Pos_General Utility_NT";
    begin
        //if not PosGenUtil.FromLock() then
        //   PosGenFunc.UpdateTransStaffID(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC WS Request", 'OnBeforeWebRequestRun', '', false, false)]
    local procedure OnBeforeWebRequestRun(RequestID: Text[30]; var gxmlRequest: Text; var gxmlResponse: Text; var StopRun: Boolean)
    var
        PosWebReqMgt: Codeunit "Pos_Web Request Management_NT";
    begin
        case UpperCase(RequestID) of
            'GET_CUST_COUPON':
                begin
                    PosWebReqMgt.GetCustCoupon(gxmlRequest, gxmlResponse);
                    StopRun := true;
                end;
            'SEND_CUST_COUPON':
                begin
                    PosWebReqMgt.SendCustCoupon(gxmlRequest, gxmlResponse);
                    StopRun := true;
                end;
            'GET_NEXT_NOSERIES_CODE':
                begin
                    PosWebReqMgt.GetNextNoSeriesCode(gxmlRequest, gxmlResponse);
                    StopRun := true;
                end;
            'GET_MEMBER_FBP':
                begin
                    PosWebReqMgt.GetMemberFBP(gxmlRequest, gxmlResponse);
                    StopRun := true;
                end;
        end;
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Coupon Management", 'OnBeforeValidateCouponHeader', '', false, false)]
    // local procedure OnBeforeValidateCouponHeader(var CouponHeader: Record "LSC Coupon Header"; CouponEntry: Record "LSC Coupon Entry"; var IsHandled: Boolean; var ReturnValue: Boolean)
    // var
    //     PosGenFunc: Codeunit "Pos_General Functions_NT";
    //     ErrMsg: Text[250];
    // begin
    //     if not PosGenFunc.IsCouponValid2(CouponHeader, ErrMsg) then begin
    //         IsHandled := true;
    //         ReturnValue := false;
    //     end;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Coupon Management", 'OnIsCouponValidOnBeforeValidateCouponHeader', '', false, false)]
    local procedure "LSC Coupon Management_OnIsCouponValidOnBeforeValidateCouponHeader"(var CouponHeader: Record "LSC Coupon Header"; var POSTransaction: Record "LSC POS Transaction"; var ErrorMsg: Text[250]; var Result: Boolean; var IsHandled: Boolean)
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
        ErrMsg: Text[250];
    begin
        if not PosGenFunc.IsCouponValid2(CouponHeader, ErrMsg) then begin
            IsHandled := true;
            Result := false;
            ErrorMsg := ErrMsg;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintSalesInfo', '', false, false)]
    local procedure OnAfterPrintSalesInfo(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; Tray: Integer);
    var
        PosPrintUtils: Codeunit "Pos_Print Utility_NT";
    begin
        PosPrintUtils.PrintTellAlphaMega(Sender, Transaction, 2);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintCustomerSlipV2', '', false, false)]
    local procedure OnBeforePrintCustomerSlipV2(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; PaymEntry: Record "LSC Trans. Payment Entry"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        PosPrintUtility: Codeunit "Pos_Print Utility_NT";
    begin
        IsHandled := PosPrintUtility.PrintCustomerSlip(Sender, PaymEntry);
        ReturnValue := IsHandled;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterSetStaffName', '', false, false)]
    local procedure OnAfterSetStaffName(var Sender: Codeunit "LSC POS Print Utility"; Transaction: Record "LSC Transaction Header"; var StaffName: Text[30]; var DSTR1: Text[100])
    var
        PrintUtil: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtil.PrintSubHeader_AM(Sender, Transaction, StaffName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintSalesDiscountInfo', '', false, false)]
    local procedure OnBeforePrintSalesDiscountInfo(var RecipeBufferTEMP: Record "LSC Trans. Sales Entry" temporary; var RecipeBufferDetailTEMP: Record "LSC Trans. Discount Entry" temporary; var FieldValue: array[10] of Text[100]; var NodeName: array[32] of Text[50]; var DSTR2: Text[100])
    begin
        if RecipeBufferDetailTEMP."Discount Offer Description" <> '' then
            FieldValue[1] := RecipeBufferDetailTEMP."Discount Offer Description";//DiscountText = FieldValue[1]
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintTerminalInfoXZReport', '', false, false)]
    local procedure OnBeforePrintTerminalInfoXZReport(var Sender: Codeunit "LSC POS Print Utility"; RunType: Option; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var Handled: Boolean; var ReturnValue: Boolean)
    var
        PrintUtility: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtility.PrintStoreTerminalinPrintXZ(Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintTenderDeclLines', '', false, false)]
    local procedure OnBeforePrintTenderDeclLines(var Sender: Codeunit "LSC POS Print Utility"; var TransTenderDeclarEntry: Record "LSC Trans. Tender Declar. Entr"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean);
    begin
        TransTenderDeclarEntry.SetRange(Date, Today);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintLoyalty', '', false, false)]
    local procedure OnBeforePrintLoyalty(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean)
    var
        PrintUtils: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtils.PrintLoyaltyHeader(Sender, Transaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnBeforeValidateQuantity', '', false, false)]
    local procedure OnBeforeValidateQuantity(var NewQuantity: Decimal; var Line: Record "LSC POS Trans. Line"; var Proceed: Boolean)
    var
        TopupMgt: Codeunit "Pos_Topup Management_NT";
    begin
        TopupMgt.CheckTopUpQty(NewQuantity, Line, Proceed);
    end;

    //Following Top Up call moved to OnBeforeInsertPaymentLineForTopUp below
    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertPayment_TenderKeyExecutedEx', '', false, false)]
    local procedure OnBeforeInsertPayment_TenderKeyExecutedEx(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var TenderAmountText: Text)
    var
        TopupMgt: Codeunit "Pos_Topup Management_NT";
    begin
        TopupMgt.InitializTopupTenderKeyPressedEx(POSTransaction, TenderTypeCode);
    end;
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertPaymentLine', '', false, false)]
    local procedure OnBeforeInsertPaymentLineForTopUp(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: Decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean);
    var
        TopupMgt: Codeunit "Pos_Topup Management_NT";
    begin
        isHandled := TopupMgt.InitializTopupTenderKeyPressedEx(POSTransaction, TenderTypeCode);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTotalExecuted', '', false, false)]
    local procedure OnBeforeTotalExecuted(var POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    var
        TopupMgt: Codeunit "Pos_Topup Management_NT";
    begin
        TopupMgt.TopupSelectionMsgOnTotalPressed(POSTransaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeCompressSalesTrans2', '', false, false)]
    local procedure OnBeforeCompressSalesTrans2(POSSalesEntry: Record "LSC POS Trans. Line"; PosTransLineTmp: Record "LSC POS Trans. Line" temporary; var SkipCompression: Boolean)
    var
        Item: Record Item;
    begin
        if Item.Get(POSSalesEntry.Number) then
            if Item."Topup Item" then
                SkipCompression := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransaction', '', false, false)]
    local procedure OnAfterInsertTransaction(var Sender: Codeunit "LSC POS Post Utility"; var POSTrans: Record "LSC POS Transaction"; var Transaction: Record "LSC Transaction Header")
    var
        PosGenUtility: Codeunit "Pos_General Utility_NT";
    begin
        PosGenUtility.InitializeTempTransTopUpEntry();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Trans. Server Utility", 'OnBeforeSendUnsentTables', '', false, false)]
    local procedure OnBeforeSendUnsentTables();
    var
        DataEntry: Record "LSC POS Data Entry";
        InfoCode: Record "LSC Infocode";
        InfoEntry: Record "LSC Trans. Infocode Entry";
        RefTrans: Record "LSC Transaction Header";
        RetryAction: Record "lsc trans. server work table";
        Trans2: Record "LSC Transaction Header";
        Trans: Record "LSC Transaction Header";
        Globals: Codeunit "LSC POS Session";
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        DataEntryFound: Boolean;
    begin
        RetryAction.SetRange("Created by Store No.", Globals.StoreNo);
        RetryAction.SetRange("Created by POS Terminal No.", Globals.TerminalNo);
        RetryAction.SetRange(Table, Database::"LSC Transaction Header");
        if RetryAction.FindSet() then
            repeat
                DataEntryFound := false;
                if Trans.Get(RetryAction."Store No.", RetryAction."POS Terminal No.", RetryAction."Transaction No.") then begin
                    if Trans."Refund Receipt No." <> '' then begin
                        RefTrans.SetCurrentKey("Receipt No.");
                        RefTrans.SetFilter("Receipt No.", Trans."Refund Receipt No.");
                        if RefTrans.FindFirst() then begin
                            InfoEntry.SetRange("Store No.", RefTrans."Store No.");
                            InfoEntry.SetRange("POS Terminal No.", RefTrans."POS Terminal No.");
                            InfoEntry.SetRange("Transaction No.", RefTrans."Transaction No.");
                            InfoEntry.SetFilter(Infocode, '<>%1', 'TEXT');
                            if InfoEntry.FindSet then
                                repeat
                                    DataEntry.Reset();
                                    InfoCode.Get(InfoEntry.Infocode);
                                    if (InfoCode.Type = InfoCode.Type::"Create Data Entry") then begin
                                        DataEntry.SetRange("Entry Type", InfoCode."Data Entry Type");
                                        DataEntry.SetRange("Created by Receipt No.", RefTrans."Receipt No.");
                                        DataEntry.SetRange("Created in Store No.", RefTrans."Store No.");
                                        DataEntry.SetRange("Created by Line No.", InfoEntry."Line No.");
                                        if DataEntry.FindFirst() then begin
                                            DataEntryFound := true;
                                        end;
                                    end;
                                until (InfoEntry.Next() = 0) or DataEntryFound;
                        end;
                        if DataEntryFound then
                            PosGenUtil.SetSendTrans(true);
                    end;
                    DataEntryFound := false;
                    Trans2.Reset();
                    Trans2.SetFilter("Retrieved from Receipt No.", Trans."Receipt No.");
                    DataEntryFound := not Trans2.IsEmpty;
                    if DataEntryFound then
                        PosGenUtil.SetSendTrans(true);
                end;
            until RetryAction.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Trans. Server Utility", 'OnBeforePOSTransServerUtilSendTransaction', '', false, false)]
    local procedure OnBeforePOSTransServerUtilSendTransaction(var POSFuncProfile: Record "LSC POS Func. Profile");
    var
        PosGenUtil: Codeunit "Pos_General Utility_NT";
    begin
        if PosGenUtil.GetSendTrans() = true then
            POSFuncProfile."TS Send Transactions" := true;
        PosGenUtil.SetSendTrans(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterPrintZReport', '', false, false)]
    local procedure OnAfterPrintZReport(var POSTransaction: Record "LSC POS Transaction"; DoCheck: Boolean; AskUser: Boolean)
    var
        PosGenFn: Codeunit "Pos_General Functions_NT";
    begin
        PosGenFn.OnAfterPrintZ(POSTransaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeExitWhenResultNotOk', '', false, false)]
    local procedure OnBeforeExitWhenResultNotOk(var Payload: Text; var InputValue: Text; var ResultOK: Boolean; var KeyboardTriggerToProcess: Integer; var IsHandled: Boolean);
    var
        POSGenUtility: Codeunit "Pos_General Utility_NT";
    begin
        POSGenUtility.SetNumpadActive(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeKeyboardTriggerProcess', '', false, false)]
    local procedure OnBeforeKeyboardTriggerProcess(KeyboardTriggerToProcess: Integer; InputValue: Text)
    var
        POSGenUtility: Codeunit "Pos_General Utility_NT";
    begin
        POSGenUtility.SetNumpadActive(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnAfterKeyboardTriggerToProcess', '', false, false)]
    local procedure OnAfterKeyboardTriggerToProcess(InputValue: Text; KeyboardTriggerToProcess: Integer; var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        GlobalRec: Record "LSC POS Menu Line";
        POSLine: Record "LSC POS Trans. Line";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        InputQty: Integer;
    begin
        case KeyboardTriggerToProcess of
            5000://Gift car Exchange Qty
                begin
                    IsHandled := true;
                    POSLINES.GetCurrentLine(POSLine);
                    if POSLine."Marked for Gift Receipt" then
                        if Evaluate(InputQty, InputValue) then
                            if (InputQty > 0) and (InputQty < POSLine.Quantity) then begin
                                POSLine."No. Of Exchange Cards" := InputQty;
                                POSLine.Modify();
                            end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'SalesEntryOnBeforeInsertV2', '', false, false)]
    local procedure OnTransSalesEntryInsert_POSPostUtility(var pPOSTransLineTemp: Record "LSC POS Trans. Line" temporary; var pTransSalesEntry: Record "LSC Trans. Sales Entry")
    begin
        pTransSalesEntry."No. Of Exchange Cards" := pPOSTransLineTemp."No. Of Exchange Cards";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Refund Mgt.", 'OnAfterAssignRemainingQuantity', '', false, false)]
    local procedure OnAfterAssignRemainingQuantity(var POSTransLineBuffer: Record "LSC POS Trans. Line"; TransSalesEntry: Record "LSC Trans. Sales Entry");
    begin
        POSTransLineBuffer."Division Code" := TransSalesEntry."Division Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnBeforePostTransaction', '', false, false)]
    local procedure OnBeforePostTransaction(var Rec: Record "LSC POS Transaction"; var IsHandled: Boolean);
    var
        POSGenFun: Codeunit "Pos_General Functions_NT";
    begin
        IsHandled := POSGenFun.OnBeforePostTransactionCheckMemberCard(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforePosMessage', '', false, false)]
    local procedure OnBeforePosMessage(var POSTransaction: Record "LSC POS Transaction"; Message: Text; var IsHandled: Boolean; var ReturnValue: Boolean);
    var
        POSPOP: Codeunit "Pos_POP Up Functions_NT";
    begin
        if Message <> '' then
            if pospop.PopUpPosMessage(Message) then
                IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS DataSet Utility", 'OnBeforeCreateJournalLinesCaption', '', false, false)]
    local procedure OnBeforeCreateJournalLinesCaption(var pRecRef: RecordRef; var pFieldNo: Integer; var pColumnNo: Integer; var tmpText: Text; var EventSaysExit: Boolean);
    var
        GenFunc: Codeunit "Pos_General Functions_NT";
    begin
        if GenFunc.CreateJournalLinesPriceCaption(pRecRef, pFieldNo, pColumnNo, tmpText) then
            EventSaysExit := true;
    end;

    //  [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforePosConfirm', '', false, false)]
    //  local procedure OnBeforePosConfirm(var POSTransaction: Record "LSC POS Transaction"; Message: Text; var IsHandled: Boolean; var ReturnValue: Boolean);
    //  var
    //      POSPOP: Codeunit "Pos_POP Up Functions_NT";
    //  begin
    //      POSPOP.PosConfirmMessage(Message);
    //      IsHandled := true;
    //      ReturnValue :=  true;
    //  end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS DataSet Utility", 'OnBeforeSetJournalLineColorV2', '', false, false)]
    local procedure OnBeforeSetJournalLineColorV2(var pRecRef: RecordRef; var JournalFont: Code[20]; var JournalSkin: Code[20]);
    var
        GenFunc: Codeunit "Pos_General Functions_NT";
    begin
        GenFunc.SetCouponJournalLineColor(pRecRef, JournalFont, JournalSkin);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeIncExpLineV2_NT', '', false, false)]
    local procedure OnBeforeIncExpLineV2_NT(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var PaymentAmt: Decimal; var MultiplyWith: Decimal);
    var
        GenFunc: Codeunit "Pos_General Functions_NT";
    begin
        genfunc.MUltiplyIncExp(POSTransaction, POSTransLine, PaymentAmt, MultiplyWith);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeLookupCall', '', false, false)]
    local procedure OnBeforeLookupCall(var LookupSetup: Record "LSC POS Lookup"; var PosTransLine: Record "LSC POS Trans. Line"; MgrKey: Boolean; CustomerNo: Code[20]; ExecuteCommand: Boolean; FormID: Code[20]; Filter: Code[29]; var LookupRecRef: RecordRef; var IsHandled: Boolean);
    var
        PosGenFn: Codeunit "Pos_General Functions_NT";
    begin
        PosGenFn.OnBeforeLookupCall_ProcessLookUpData(LookupSetup, PosTransLine, MgrKey, CustomerNo, ExecuteCommand, FormID, Filter, LookupRecRef, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnPrintXZReport_OnBeforePrintItemCategory', '', false, false)]
    local procedure OnPrintXZReport_OnBeforePrintItemCategory(var Sender: Codeunit "LSC POS Print Utility"; var ItemCategoryTemp: Record "Item Category" temporary; var IsHandled: Boolean)

    begin
        IsHandled := true; //Stop printing Category
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeCumulateSales', '', false, false)]
    local procedure OnBeforeCumulateSales(RunType: Option; var Handled: Boolean);
    begin
        Handled := true; //Stop printing Accumulated Sales
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintItemTransLinesOnSuspendedSlipV2_NT', '', false, false)]
    local procedure OnBeforePrintItemTransLinesOnSuspendedSlipV2_NT(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean; var POSTrans: Record "LSC POS Transaction"; var tmpPosItemTransLines: Record "LSC POS Trans. Line" temporary; var FieldValue: array[10] of Text[100]);
    var
        PrintUtil: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtil.PrintBarcodeOnSuspendedSlip(Sender, Transaction, POSTrans, tmpPosItemTransLines);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Member Posting Utils", 'OnBeforeProcessOrderEntryFilterInLSCMemberPostingUtils_NT', '', false, false)]
    local procedure OnBeforeProcessOrderEntryFilterInLSCMemberPostingUtils_NT(var ProcessOrderEntry: Record "LSC Member Process Order Entry");
    var
        PosGenFn: Codeunit "Pos_General Functions_NT";
    begin
        PosGenFn.FilterProcessOrderEntryAndSetStepValue(ProcessOrderEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Member Posting Utils", 'OnBeforeUpdateMemberFromPOSInLSCMemberPostingUtils_NT', '', false, false)]
    local procedure OnBeforeUpdateMemberFromPOSInLSCMemberPostingUtils_NT(var ProcessOrderEntry: Record "LSC Member Process Order Entry"; NoOfTrans: Integer; var IsHandled: Boolean);
    var
        PosGenFn: Codeunit "Pos_General Functions_NT";
    begin
        PosGenFn.ProcessMemOrderEntry(ProcessOrderEntry, IsHandled);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Member Point Jnl. Line", 'OnBeforeValidateEvent', 'Points', false, false)]
    local procedure MyProcedure(var Rec: Record "LSC Member Point Jnl. Line")
    var
        RetailSetup: Record "LSC Retail Setup";
        RetailUser: Record "LSC Retail User";
    begin
        IF Rec.Type IN [Rec.Type::"Pos. Adjustment", Rec.Type::"Neg. Adjustment"] THEN BEGIN
            IF RetailUser.GET(USERID) THEN
                IF NOT RetailUser."Allow Unlimited Points" THEN BEGIN
                    RetailSetup.GET;
                    IF RetailSetup."Max Adjustment Points" <> 0 THEN
                        IF ABS(Rec.Points) > RetailSetup."Max Adjustment Points" THEN
                            ERROR('Max points allowed is %1', RetailSetup."Max Adjustment Points");
                END;
        END
        ELSE BEGIN
            IF RetailUser.Get(USERID) THEN
                IF NOT RetailUser."Allow Unlimited Points" THEN BEGIN
                    ERROR('You are allowed to use only Pos. Adjustment and Neg. Adjustment Type Option');
                END;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LSCSendVoucherEntry, 'OnBeforeSetRequestInSendVoucherEntry_NT', '', false, false)]
    local procedure OnBeforeSetRequestInSendVoucherEntry_NT(var UpdateReplicationCounter: Boolean; var SendVoucherEntryXML: XmlPort LSCSendVoucherEntryXML);
    var
        GeneralSetup: Record "eCom_General Setup_NT";
    begin
        if GeneralSetup.Get() then
            UpdateReplicationCounter := GeneralSetup.DataEntryUpdateReplCounter;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeStaffLogon', '', false, false)]
    local procedure OnBeforeStaffLogon(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Staff: Record "LSC Staff");
    var
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        POSSESSION: Codeunit "LSC POS Session";
        OldStaffID: Code[20];
    begin
        OldStaffID := POSSESSION.StaffID();
        PosGenUtil.SetOldStaffID(OldStaffID);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterStaffLogon', '', false, false)]
    local procedure OnAfterStaffLogon(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Staff: Record "LSC Staff");
    var
        StaffPerGroup: Record "LSC STAFF PER Group";
        TmpStaff: Record "LSC Staff";
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        POSSESSION: Codeunit "LSC POS Session";
        Manager: Boolean;
        OldStafID: code[20];
        PMsg: Text;
    begin
        if Staff."Permission Group" = '' then
            exit;
        if not StaffPerGroup.Get(Staff."Permission Group") then
            exit;

        Manager := StaffPerGroup."Manager Privileges" = StaffPerGroup."Manager Privileges"::Yes;

        if Manager then begin

            // if POSSESSION.ManagerID() = '' then
            //     if not POSSESSION.SetManagerID(TmpStaff, MessageTxt) then begin
            //         //MessageBeep(MessageTxt);
            //         exit;
            //     end;
            OldStafID := PosGenUtil.GetOldStaffID();

            if OldStafID <> '' then begin
                TmpStaff.Get(OldStafID);
                POSSESSION.SetStaffID(TmpStaff, '');
                POSSESSION.SetManagerID(Staff, PMsg);
            end;

            PosGenUtil.SetStaffLogOnValues(staff, Manager);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInit', '', false, false)]
    local procedure OnBeforeInit(var POSTransaction: Record "LSC POS Transaction")
    var
        StaffPerGroup: Record "LSC STAFF PER Group";
        TmpStaff: Record "LSC Staff" temporary;
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        POSSESSION: Codeunit "LSC POS Session";
        Manager: Boolean;
        MessageTxt: Text;
    begin
        PosGenUtil.GetStaffLogOnValues(TmpStaff, Manager);
        if Manager then begin
            if POSSESSION.ManagerID() = '' then
                if not POSSESSION.SetManagerID(TmpStaff, MessageTxt) then begin
                    //MessageBeep(MessageTxt);
                    exit;
                end;
            PosGenUtil.ClearStaffLogOnValues();
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC POS Trans. Line", 'OnBeforeCompressLine', '', false, false)]
    local procedure OnBeforeCompressLine(var Rec: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    var
        Item: Record Item;
        PosGenFn: Codeunit "Pos_General Functions_NT";
    begin
        if Item.Get(Rec.Number) then
            if Item."Compress When Scanned" then begin
                PosGenFn.CompressLine(Rec);
                IsHandled := true;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintNegAdjSlip', '', false, false)]
    local procedure OnAfterPrintNegAdjSlip(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]);
    var
        PosFuncProfile: Record "LSC POS Func. Profile";
        Transaction2: Record "LSC Transaction Header";
        POSSession: Codeunit "LSC POS Session";
    begin
        Transaction2.SetRange("Store No.", Transaction."Store No.");
        Transaction2.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        Transaction2.SetRange("Transaction No.", Transaction."Transaction No.");
        PosFuncProfile.Get(POSSession.FunctionalityProfileID);
        if PosFuncProfile."Negative Adjustment Report ID" <> 0 then
            Report.Run(PosFuncProfile."Negative Adjustment Report ID", FALSE, true, Transaction2);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnBeforeIsWeightItem', '', false, false)]
    local procedure OnBeforeIsWeightItem(var PosTransLine: Record "LSC POS Trans. Line"; var Result: Boolean; var IsHandled: Boolean);
    var
        PosGenFun: Codeunit "Pos_General Functions_NT";
    begin
        Result := PosGenFun.IsWeightItem(PosTransLine);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeCheckPointBalance', '', false, false)]
    local procedure OnBeforeCheckPointBalance(var Rec: Record "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line"; var CurrInput: Text; var IsHandled: Boolean);
    begin
        IsHandled := true;//Skip Member Point Not Enough Message 
    end;
    //NT Following Hook needs to be removed as LS Code modified to by pass Compiler Error 19.03.2024 as CalcSums on flowfield is compiler error now
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeSetCOPaymentAmtOnTenderKeyPressedEx', '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeSetCOPaymentAmtOnTenderKeyPressedEx"(var POSTransaction: Record "LSC POS Transaction"; var CustomerOrderHeader_Temp: Record "LSC Customer Order Header" temporary; var CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary; var PaymentAmount: Decimal; var PrepayCustomerOrder: Boolean; var COWasCreated: Boolean; var IsHandled: Boolean)
    var
    lPrevAppAmt: Decimal;
    begin
        CustomerOrderHeader_Temp.SetAutoCalcFields("Pre Approved Amount");
        if CustomerOrderHeader_Temp.FindSet() then
        repeat
            lPrevAppAmt += CustomerOrderHeader_Temp."Pre Approved Amount";
        until CustomerOrderHeader_Temp.Next()=0;
        CustomerOrderHeader_Temp."Pre Approved Amount" := lPrevAppAmt;
    end;


    //==============LS Custom App Hooks=======To be replaced with actual LS Hooks===========Start

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintExtraPaymentV2_NT', '', false, false)]
    local procedure OnBeforePrintExtraPayment(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var
                                                                                                                                                  POSDataEntry: Record "LSC POS Data Entry";
                                                                                                                                                  TenderType: Record "LSC Tender Type";
                                                                                                                                                  PaymentLine: Record "LSC Trans. Payment Entry";

    var
        IsHandled: Boolean;

    var
        ReturnValue: Boolean);
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        if POSDataEntry."Entry Code" <> '' then
            if Transaction.GetPrintedCounter(1) > 0 THEN begin
                IsHandled := true;
                ReturnValue := true;
                EXIT;
            end;
        if PosGenFunc.PrintExtraPayment(Sender, POSDataEntry, TenderType, PaymentLine, Transaction) then begin
            IsHandled := true;
            ReturnValue := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Member Mgt.", 'OnBeforeGetMemberInfoForPosV2_NT', '', false, false)]
    local procedure OnBeforeGetMemberInfoForPos(CardNo: Text; var MembershipCardTemp: Record "LSC Membership Card"; var MemberAccountTemp: Record "LSC Member Account"; var MemberContactTemp: Record "LSC Member Contact"; var MemberAttributeListTemp: Record "LSC Member Attribute List"; var MemberClubTemp: Record "LSC Member Club"; var MemberSchemeTemp: Record "LSC Member Scheme"; var MemberMgtSetupTemp: Record "LSC Member Management Setup"; var MemberPointSetupTemp: Record "LSC Member Point Setup"; var MemberCouponBufferTemp: Record "LSC Member Coupon Buffer"; var FBPWSBufferTemp: Record "LSC FBP WS Buffer"; var IsHandled: Boolean; var ResponseCode: Code[30]; var ErrorText: Text)
    var
        PosGenFun: Codeunit "Pos_General Functions_NT";
    begin
        IsHandled := PosGenFun.LoadMemberInfoLocal(CardNo
                                    , ErrorText
                                    , MembershipCardTemp
                                    , MemberAccountTemp
                                    , MemberContactTemp
                                    , MemberAttributeListTemp
                                    , MemberClubTemp
                                    , MemberSchemeTemp
                                    , MemberMgtSetupTemp
                                    , MemberPointSetupTemp
                                    , MemberCouponBufferTemp
                                    , FBPWSBufferTemp
                                    );
        if IsHandled then
            ResponseCode := '0000';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'ProcessCouponSetTenderTypeFilter_NT', '', false, false)]
    local procedure ProcessCouponSetTenderTypeFilter_NT(CouponHeader: Record "LSC Coupon Header"; var TenderTypeTable: Record "LSC Tender Type Setup")
    begin
        if CouponHeader."Tender Type" <> '' then
            TenderTypeTable.SetRange(Code, CouponHeader."Tender Type")
        else
            TenderTypeTable.SETRANGE(Code);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeModifyPaymentLine_NT', '', false, false)]
    local procedure OnBeforeModifyPaymentLine_NT(var NewLine: Record "LSC POS Trans. Line"; CouponHeader: Record "LSC Coupon Header")
    begin
        NewLine."Point Value" := CouponHeader."Point Value";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnBeforeInsertPaymentLineV2_NT', '', false, false)]
    local procedure OnBeforeInsertPaymentLine(var Rec: Record "LSC POS Transaction"; var PaymentAmount: Decimal; CouponBarcode: Code[22]; CouponHeader: Record "LSC Coupon Header"; var IsHandled: Boolean)
    var
        POSTransLine: Record "LSC POS Trans. Line";
        PosTransCU: Codeunit "LSC POS Transaction";
    begin
        if (CouponBarcode <> '') AND (CouponBarcode <> CouponHeader.Code) then begin
            Clear(POSTransLine);
            POSTransLine.SETRANGE("Receipt No.", Rec."Receipt No.");
            POSTransLine.SETRANGE("Entry Status", POSTransLine."Entry Status"::" ");
            POSTransLine.SETRANGE("Entry Type", POSTransLine."Entry Type"::Payment);
            //POSTransLine.SETRANGE("Barcode No.", CouponHeader.Code); BC Upgrade
            POSTransLine.SETRANGE("Coupon Barcode No.", CouponHeader.Code);//BC Upgrade
            POSTransLine.SETRANGE("Coupon Code", CouponHeader.Code);
            POSTransLine.SETRANGE("Coupon EAN Org.", CouponBarcode);
            if POSTransLine.FINDFIRST then begin
                PosTransCU.ErrorBeep(STRSUBSTNO('Coupon %1 already used.', CouponBarcode));
                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Trans. Server Utility", 'OnBeforeSendAtEndOfTransactionV2_NT', '', false, false)]
    local procedure OnBeforeCreateTSRetryEntryMemberProcessOrderEntry_NT(Trans: Record "LSC Transaction Header"; var IsHandled: Boolean)
    var
        MemberClub: Record "LSC Member Club";
        MembershipCard: Record "LSC Membership Card";
        TransPaymentLine: Record "LSC Trans. Payment Entry";
        RedemptionTrans: Boolean;
    begin
        if Trans."Member Card No." = '' then
            exit;
        RedemptionTrans := Trans."Point Value" <> 0;

        if not RedemptionTrans then
            if MembershipCard.Get(Trans."Member Card No.") then
                if MemberClub.Get(MembershipCard."Club Code") then begin
                    TransPaymentLine.SetRange("Store No.", Trans."Store No.");
                    TransPaymentLine.SetRange("POS Terminal No.", Trans."POS Terminal No.");
                    TransPaymentLine.SetRange("Transaction No.", Trans."Transaction No.");
                    TransPaymentLine.SetRange("Tender Type", MemberClub."Member Point Tender Type");
                    RedemptionTrans := not TransPaymentLine.IsEmpty;
                end;

        IsHandled := not RedemptionTrans; //Don't send member process order entry if not redemption 
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterLoadCoupon_NT', '', false, false)]
    local procedure OnAfterLoadCoupon_NT(Rec: Record "LSC POS Transaction"; var Line: Record "LSC POS Trans. Line"; var Ishandled: Boolean)
    var
        PosTrans: Record "LSC POS Transaction";
        PosFunc: Codeunit "LSC POS Functions";
        PosTransCU: Codeunit "LSC POS Transaction";
    begin
        if Line."Point Value" <> 0 then begin
            PosTrans.CalcFields("Point Value");
            PosTrans."Point Value" += Line."Point Value";
            if PosTrans."Point Value" > PosTrans."Starting Point Balance" then begin
                PosTransCU.ErrorBeep('Insufficient Points To Process this coupon.');
                IsHandled := true;
            end;
        end;
        /* BC Upgrade. Need to check the requirement of the code
        CouponTenderType2 := PosFunc.GetCouponTenderType;
        IF CouponTenderType2 <> '' THEN BEGIN
            IF NOT TenderType.GET(PosTrans."Store No.", CouponTenderType2) THEN BEGIN
                ErrorBeep(STRSUBSTNO(Text196, TenderType.TABLECAPTION, StoreSetup.TABLECAPTION));
                EXIT
            END;
            CouponTenderType := CouponTenderType;
        END;
        */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnBeforeUpdOfferInCalcMixMatch_NT', '', false, false)]
    local procedure OnBeforeUpdOfferInCalcMixMatch_NT(var MmHdr: Record "LSC Periodic Discount"; var MmLine: Record "LSC Periodic Discount Line"; ItemNo: Code[20]; Qty: Decimal; var TmpMixMatchNeededLine: Record "LSC Mix & Match Line Groups"; var Lines: Integer; var UsedCurrLineQty: Decimal; var UseQty: Decimal; var IsHandled: Boolean);
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        // UseQty := PosGenFunc.UpdOffer(MmHdr, MmLine, ItemNo, qty, TmpMixMatchNeededLine,
        // Lines, UsedCurrLineQty, MmMembTmp, MmTmp, MmOfferList, DiffList, LineList, LastItemUpd, DiffCount);
        // IsHandled := true;
        //===WITH NEW PARMETERS=====
        UseQty := PosGenFunc.UpdOffer(MmHdr, MmLine, ItemNo, Qty, TmpMixMatchNeededLine, Lines, UsedCurrLineQty);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnBeforeAddToListInCalcMixMatch_NT', '', false, false)]
    local procedure OnBeforeAddToListInCalcMixMatch_NT(var PosTransLine: Record "LSC POS Trans. Line"; var PeriodicDiscountLines2: Record "LSC Periodic Discount Line"; var MmMembList: Codeunit "LSC POS Price Functions"; BaseOffset: Decimal; var IsHandled: Boolean);
    begin
        MmMembList.AddToList(PosTransLine."Line No.", BaseOffset + PosTransLine.Price * (PeriodicDiscountLines2."No. of Items Needed" + PeriodicDiscountLines2."Offset for No. of Items"),
                                  PosTransLine.Quantity, Format(PeriodicDiscountLines2."Line No."));
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Price Utility", 'OnBeforeAddToListInCalcMixMatchNew_NT', '', false, false)]
    local procedure OnBeforeAddToListInCalcMixMatchNew_NT(var TmpPosTransLine: Record "LSC POS Trans. Line"; var PeriodicDiscountLines2: Record "LSC Periodic Discount Line"; var MmMembList: Codeunit "LSC POS Price Functions"; BaseOffset: Decimal; var IsHandled: Boolean)
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        if PosGenFunc.IsWeightItem(TmpPosTransLine) then
            MmMembList.AddToList(TmpPosTransLine."Line No.", BaseOffset + TmpPosTransLine.Price * (PeriodicDiscountLines2."No. of Items Needed" + PeriodicDiscountLines2."Offset for No. of Items"),
              1, Format(PeriodicDiscountLines2."Line No."))
        else
            MmMembList.AddToList(TmpPosTransLine."Line No.", BaseOffset + TmpPosTransLine.Price * (PeriodicDiscountLines2."No. of Items Needed" + PeriodicDiscountLines2."Offset for No. of Items"),
              TmpPosTransLine.Quantity, Format(PeriodicDiscountLines2."Line No."));
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Member Attribute Mgmt", 'OnAfterFilterDiscountTrEntryInGetRemainingDiscount_NT', '', false, false)]
    local procedure OnAfterFilterDiscountTrEntryInGetRemainingDiscount_NT(var DiscountTrEntry: Record "LSC Discount Tracking Entry"; DiscountLimitation: Record "LSC Discount Tracking Header"; CardRec: Record "LSC Membership Card");
    begin
        case DiscountLimitation."Limited by" of

            DiscountLimitation."Limited by"::Club:
                DiscountTrEntry.SetRange("Account No.", CardRec."Account No.");

            DiscountLimitation."Limited by"::Scheme:
                DiscountTrEntry.SetRange("Account No.", CardRec."Account No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", 'OnBeforeContainsQRCode_NT', '', false, false)]
    local procedure OnBeforeContainsQRCode_NT(var CurrInput: Text; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        PosTransaction: Codeunit "LSC POS Transaction";
        POSView: Codeunit "LSC POS View";
        PosGentUtil: Codeunit "Pos_General Utility_NT";
    begin
        if (StrPos(CurrInput, '"continuityMember"') > 0) or (StrPos(CurrInput, '"continuityVoucher"') > 0) then begin
            POSView.ProcessScannerInput(CurrInput);
            CurrInput := '';
            IsHandled := true;
            ReturnValue := true;
        end;
        // //SKIP if EnterPressed is triggered from GiftVoucher OnBeforeProcessEvent
        // if PosGentUtil.GetSkipEnteressedTriggeredFromGiftVoucher() = true then begin
        //     CurrInput := '';
        //     IsHandled := true;
        //     ReturnValue := true;
        //     PosGentUtil.SetSkipEnteressedTriggeredFromGiftVoucher(false);
        // end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeInsertTransDiscountEntry_NT', '', false, false)]
    local procedure OnBeforeInsertTransDiscountEntry_NT(var TransDiscountEntryTEMP: Record "LSC Trans. Discount Entry" temporary; var DiscountEntryTmp: Record "LSC Trans. Discount Entry" temporary; SalesEntry: Record "LSC Trans. Sales Entry");
    begin
        if TransDiscountEntryTEMP."Offer Type" = TransDiscountEntryTEMP."Offer Type"::"Disc. Offer" then begin
            TransDiscountEntryTEMP."Discount Offer No." := SalesEntry."Discount Offer No.";
            TransDiscountEntryTEMP."Discount Offer Description" := SalesEntry."Discount Offer Description";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Session", 'OnAfterPasswordValidityPassV2_NT', '', false, false)]
    local procedure OnAfterPasswordValidityPassV2(var Staff: Record "LSC Staff"; FunctionalityProfile: Record "LSC POS Func. Profile"; var ReasonText: Text[80]; var IsError: Boolean; pManager: Boolean)
    var
        PosGenUtil: codeunit "Pos_General Utility_NT";
        Err001Lbl: Label 'Staff %1 is logged in.';
    begin
        //if not pManager then //MGRKEY
        //if (Staff."Manager Privileges" <> Staff."Manager Privileges"::Yes) then
        if (staff.ID = PosGenUtil.LockSetByStaffID()) AND (PosGenUtil.LockSetByStaffID() <> '') then begin
            PosGenUtil.SetFromLock(false);//CLEAR LOCK IF SAME STAFF LOGGED IN
            PosGenUtil.SetLockSetByStaffID('');
        end;

        if (staff.ID <> PosGenUtil.LockSetByStaffID()) AND (PosGenUtil.LockSetByStaffID() <> '') then begin
            ReasonText := StrSubstNo(Err001Lbl, PosGenUtil.LockSetByStaffID());
            IsError := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Coupon Management", 'OnAfterCouponUsePosTransLineOnApplyCouponsToTransaction_NT', '', false, false)]
    local procedure OnAfterCouponUsePosTransLineOnApplyCouponsToTransaction_NT(CouponUsePOSTransLine: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    var
        CouponHeader: Record "LSC Coupon Header";
        PosGenFn: Codeunit "Pos_General Functions_NT";
        ErrorMsg: Text[250];
    begin
        IsHandled := false;
        if CouponHeader.Get(CouponUsePOSTransLine."Coupon Code") then
            if PosGenFn.IsCouponValid2(CouponHeader, ErrorMsg) then
                IsHandled := false
            else
                IsHandled := true //Skip this coupon
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Coupon Management", 'OnBeforeCreateCouponBarcode_NT', '', false, false)]
    local procedure OnBeforeCreateCouponBarcode_NT(CouponHeader: Record "LSC Coupon Header"; SequenceNumber: Integer; var ErrorText: Text[250]; var BarcodeNo: Code[22]; var IsHandled: Boolean)
    var
        PosGenFunc: Codeunit "Pos_General Functions_NT";
    begin
        if CouponHeader."No. Series From Server" then begin
            BarcodeNo := PosGenFunc.CreateCouponBarcode(CouponHeader, SequenceNumber, ErrorText);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintItemsInPrintSuspendSlip_NT', '', false, false)]
    local procedure OnBeforePrintItemsInPrintSuspendSlip_NT(var Sender: Codeunit "LSC POS Print Utility"; var PosTrans: Record "LSC POS Transaction")
    var
        PosPrintUtils: Codeunit "Pos_Print Utility_NT";
    begin
        PosPrintUtils.PrintMemberInfoInSuspendSlip(Sender, PosTrans);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterCountItemOkInSalesSlip_NT', '', false, false)]
    local procedure OnAfterCountItemOkInSalesSlip_NT(var Sender: Codeunit "LSC POS Print Utility"; var TotalNumberOfItems: Decimal; SalesEntry: Record "LSC Trans. Sales Entry"; CountItemOk: Boolean)
    var
        PrintUtils: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtils.TransTotalNumberOfItems(TotalNumberOfItems, SalesEntry, CountItemOk);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintSlips', '', false, false)]
    local procedure OnAfterPrintSlips(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var MsgTxt: Text[50]; PrintSlip: Boolean);
    var
        PosGenUtils: Codeunit "Pos_General Utility_NT";
    begin
        PosGenUtils.SetToalNumberOfItems(0);//For Clearing 
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintTotalSavingsInPrintSalesInfo_NT', '', false, false)]
    local procedure OnBeforePrintTotalSavingsInPrintSalesInfo_NT(var Sender: Codeunit "LSC POS Print Utility"; var TransactionHeader: Record "LSC Transaction Header"; PrintTotalSavings: Boolean; TotalSavings: Decimal; var Tray: Integer; var IsHandled: Boolean)
    var
        PrintUtility: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtility.PrintTotalSavingsExtras(Sender, TransactionHeader, PrintTotalSavings, TotalSavings, Tray, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintStaffXZReport_NT', '', false, false)]
    local procedure OnBeforePrintStaffXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; var TransactionHeader: Record "LSC Transaction Header"; Staff: Record "LSC Staff"; var FieldValue: array[10] of Text[100]; var DSTR1: Text[80])
    var
        PrintUtility: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtility.PrintStaffXZReport(Sender, Staff, FieldValue, DSTR1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPaymentEntrySetFiltersXZReport_NT', '', false, false)]
    local procedure OnAfterPaymentEntrySetFiltersXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; var PaymEntry: Record "LSC Trans. Payment Entry");
    begin
        PaymEntry.SetRange(Date, Today);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeTotalLCYPrintXZReport_NT', '', false, false)]
    local procedure OnBeforeTotalLCYPrintXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; RunType: Option; Scode: Code[20]; TerminalNo: Code[10]; StoreNo: Code[10])
    var
        PrintUtility: Codeunit "Pos_Print Utility_NT";
    begin

        PrintUtility.PrintsKashNoOfTransXZReport(Sender, RunType, Scode, TerminalNo, StoreNo);
        PrintUtility.PrintCashTotalXZReport(Sender, RunType, Scode, TerminalNo, StoreNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterTransactionSetFiltersXZReport_NT', '', false, false)]
    local procedure OnAfterTransactionSetFiltersXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header")
    begin
        Transaction.SetRange(Date, Today);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterIncExpEntrySetFiltersXZReport_NT', '', false, false)]
    local procedure OnAfterIncExpEntrySetFiltersXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; var IncExpEntry: Record "LSC Trans. Inc./Exp. Entry")
    begin
        IncExpEntry.SetRange(Date, Today);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintNoOfTransactionsXZReport_NT', '', false, false)]
    local procedure OnAfterPrintNoOfTransactionsXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; RunType: Option; Scode: Code[20]; TerminalNo: Code[10]; StoreNo: Code[10])
    var
        PrintUtility: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtility.PrintTotalsExtraXZReport(sender, Transaction, RunType, Scode, TerminalNo, StoreNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterTransaction2FilterXZReport_NT', '', false, false)]
    local procedure OnAfterTransaction2FilterXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header")
    begin
        Transaction.SetRange(Date, Today);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterTendDeclEntryFilterXZReport_NT', '', false, false)]
    local procedure OnAfterTendDeclEntryFilterXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; var TendDeclEntry: Record "LSC Trans. Tender Declar. Entr")
    begin
        TendDeclEntry.SetRange(Date, Today);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterIncExpEntryFilterXZReport_NT', '', false, false)]
    local procedure OnAfterIncExpEntryFilterXZReport_NT(var Sender: Codeunit "LSC POS Print Utility"; var IncExpEntry: Record "LSC Trans. Inc./Exp. Entry")
    begin
        IncExpEntry.SetRange(Date, Today);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintMemberAccountNumberV2_NT', '', false, false)]
    local procedure OnAfterPrintMemberAccountNumberV2_NT(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; MemberAccountNo: Code[20]; MemberCardNo: Text[100]; Tray: Integer)
    var
        PrintUtils: Codeunit "Pos_Print Utility_NT";
    begin
        PrintUtils.PrintLoyaltyStartingPoints(Sender, Transaction, Tray);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintExtraItemV2_NT', '', false, false)]
    local procedure OnBeforePrintExtraItemV2_NT(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; TransSalesEntry: Record "LSC Trans. Sales Entry"; Item: Record Item; var VoidedVoucher: Boolean; var PrintBuffer: Record "LSC POS Print Buffer" temporary; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        PosPrintUtils: Codeunit "Pos_Print Utility_NT";
        PageNo: Integer;
    begin
        PageNo := 2;//BC22 Upgrade
        if Item."Topup Item" then
            if PosPrintUtils.PrintTopupSlip(Sender, Transaction, TransSalesEntry, Item, true, PrintBuffer, PrintBufferIndex, PageNo, LinesPrinted, VoidedVoucher) then begin
                IsHandled := true;
                ReturnValue := true;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Trans. Server Utility", 'OnBeforeSendWholeTmpTransactionV2_NT', '', false, false)]
    local procedure OnBeforeSendWholeTmpTransactionV2_NT(var TransactionHeaderTemp_g: Record "LSC Transaction Header" temporary; var PosFuncProfile: Record "LSC POS Func. Profile"; var IsHandled: Boolean; var RetVal: Boolean);
    var
        PosFuncProfile2: Record "LSC POS Func. Profile";
        TransactionHeader: Record "LSC Transaction Header";
        Globals: Codeunit "LSC POS Session";
    begin
        if TransactionHeader.Get(TransactionHeaderTemp_g."Store No.", TransactionHeaderTemp_g."POS Terminal No.", TransactionHeaderTemp_g."Transaction No.") then
            if TransactionHeader."Refund Receipt No." <> '' then begin
                PosFuncProfile2.Get(Globals.FunctionalityProfileID);
                if (PosFuncProfile2."TS Void Transactions") and (not PosFuncProfile2."TS Send Transactions") then
                    PosFuncProfile."TS Send Transactions" := true;
            end else begin
                TransactionHeader.Reset();
                TransactionHeader.SetFilter("Retrieved from Receipt No.", TransactionHeaderTemp_g."Receipt No.");
                if not TransactionHeader.IsEmpty then
                    if PosFuncProfile2.Get(Globals.FunctionalityProfileID) then
                        if (PosFuncProfile2."TS Void Transactions") and (not PosFuncProfile2."TS Send Transactions") then
                            PosFuncProfile."TS Send Transactions" := true;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Trans. Server Utility", 'OnAfterSendWholeTmpTransactionV2_NT', '', false, false)]
    local procedure OnAfterSendWholeTmpTransactionV2_NT(var TransactionHeaderTemp_g: Record "LSC Transaction Header" temporary; var PosFuncProfile: Record "LSC POS Func. Profile");
    var
        PosFuncProfile2: Record "LSC POS Func. Profile";
        TransactionHeader: Record "LSC Transaction Header";
        Globals: Codeunit "LSC POS Session";
    begin
        if TransactionHeader.Get(TransactionHeaderTemp_g."Store No.", TransactionHeaderTemp_g."POS Terminal No.", TransactionHeaderTemp_g."Transaction No.") then
            if TransactionHeader."Refund Receipt No." <> '' then begin
                PosFuncProfile2.Get(Globals.FunctionalityProfileID);
                if (PosFuncProfile2."TS Void Transactions") and (not PosFuncProfile2."TS Send Transactions") then
                    PosFuncProfile."TS Send Transactions" := false;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Coupon Management", 'OnBeforeValidateAmountInMarkUsedCoupons_NT', '', false, false)]
    local procedure OnBeforeValidateAmountInMarkUsedCoupons_NT(POSTransLineItem: Record "LSC POS Trans. Line"; CouponHeader: Record "LSC Coupon Header"; var SelectedItemsTEMP: Record "LSC Toplist Work Table" temporary; var NoOfCpnsThatCanBeUsed: Integer; RemainingTenderDiscountForCpn: Decimal)
    var
        PosGenFn: Codeunit "Pos_General Functions_NT";
    begin
        PosGenFn.OnBeforeValidateAmountInMarkUsedCoupons_NT(POSTransLineItem, CouponHeader, SelectedItemsTEMP, NoOfCpnsThatCanBeUsed, RemainingTenderDiscountForCpn);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", 'OnBeforeRunCommandInEnterPressed_NT', '', false, false)]
    local procedure OnBeforeRunCommandInEnterPressed_NT(MenuHeader: Record "LSC POS Menu Header"; MenuLine2: Record "LSC POS Menu Line"; var IsHandled: Boolean);
    begin
        if MenuHeader."Map Enter To" = 'ITEMNO' then
            IsHandled := (MenuHeader."Map Parameter" = '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeOpenNumericKeyboardV2_NT', '', false, false)]
    local procedure OnBeforeOpenNumericKeyboardV2_NT(var Caption: Text; var KeybType: Integer; var DefaultValue: Text; var TriggerNo: Integer; var IsHandled: Boolean);
    var
        PosGenUtility: Codeunit "Pos_General Utility_NT";
    begin
        if not PosGenUtility.IsNumpadActive() then
            PosGenUtility.SetNumpadActive(true)
        else
            IsHandled := true; //NUmeric KeyBoard Already Open
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LSCSendDataEntryUtils, 'OnBeforeRunRequestV2_NT', '', false, false)]
    local procedure OnBeforeRunRequestV2_NT(var AddOnly_g: Boolean; var POSDataEntryTemp_g: Record "LSC POS Data Entry" temporary; var UpdateReplicationCounter_g: Boolean; var IsHandled: Boolean);
    var
        GeneralSetup: Record "eCom_General Setup_NT";
    begin
        if GeneralSetup.Get() then
            UpdateReplicationCounter_g := GeneralSetup.DataEntryUpdateReplCounter;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeConfirmVoidingPayment_NT', '', false, false)]
    local procedure OnBeforeConfirmVoidingPayment_NT(var LineRec: Record "LSC POS Trans. Line"; var IsHandled: Boolean)
    var
        PosGenUtil: Codeunit "Pos_General Utility_NT";
    begin
        IsHandled := PosGenUtil.GetSuppressVoidMsg();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Gift Receipt POS Commands", 'OnAfterGiftMark_NT', '', false, false)]
    local procedure OnAfterGiftMark_NT(var POSLine: Record "LSC POS Trans. Line"; AllLines: Boolean);
    var
        POSMarkedLine: Record "LSC POS Trans. Line";
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
        ChangeQtyMsg: Label 'Change gift card qty';
    begin
        if not AllLines then
            if POSMarkedLine.Get(POSLine."Receipt No.", POSLine."Line No.") then
                if POSMarkedLine."Marked for Gift Receipt" then
                    if POSLine.Quantity > 1 then
                        PosTransCU.OpenNumericKeyboard(ChangeQtyMsg, 0, '', 5000);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Gift Receipt POS Commands", 'OnBeforeInsertInCreateGiftBuffer_NT', '', false, false)]
    local procedure OnBeforeInsertInCreateGiftBuffer_NT(var ToQty: Decimal; var TransSalesEntry: Record "LSC Trans. Sales Entry"; var FuncProfile: Record "LSC POS Func. Profile");
    begin
        if TransSalesEntry."No. Of Exchange Cards" <> 0 then
            ToQty := TransSalesEntry."No. Of Exchange Cards";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeNotUsedCouponsCheckInputNeeded_NT', '', false, false)]
    local procedure OnBeforeNotUsedCouponsCheckInputNeeded_NT(var POSTransaction: Record "LSC POS Transaction"; var NotUsedCouponsTEMP: Record "LSC POS Trans. Line" temporary; var IsHandled: Boolean);
    begin
        IsHandled := true;
    end;


    //==============LS Custom App Hooks=======To be replaced with actual LS Hooks===========End
}