codeunit 60304 "Pos_Continuity Management_NT"
{
    procedure POSSalesAdvice(POSTransaction: Record "LSC POS Transaction"; var POSContinuityEntry: Record "POS Continuity Entry_NT"; VoucherCode: Text): Boolean
    var
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        GenSetup: Record "eCom_General Setup_NT";
        POSTransLine: Record "LSC POS Trans. Line";
        PosGenBufJSonMgt: Codeunit "Pos_Gen. Buffer Json Mgmt_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
        PosWebReqMgt: Codeunit "Pos_Web Request Management_NT";
        JsonObj: JsonObject;
        ReqOK: Boolean;
        DT: Date;
        ItemInfo: Text;
        JsonRequestBody: Text;
        JsonResponse: Text;
        TM: Time;
        NT000: label '%1;%2;%3';
        NT001: label 'The %1 does not exist';
        DotNetString: DotNet String;
    begin

        if POSTransaction."Continuity Member No." = '' then
            exit(false);
        if VoucherCode = '' then
            exit(false);

        if not GenSetup.Get() then begin
            PosTransCU.ErrorBeep(StrSubstNo(NT001, GenSetup.TableCaption));
            exit(false);
        end;
        GenSetup.TestField("Continuity URL");
        if GenSetup."Continuity Time Out (ms)" = 0 then
            GenSetup."Continuity Time Out (ms)" := 5000;

        DT := TODAY;
        TM := TIME;
        //Bc Upgrade Start
        /*
        JSonMgt.StartJSon;
        JSonMgt.AddToJSon('institutionID', '2000');
        JSonMgt.AddToJSon('institutionPassword', '2000AMEKO');
        JSonMgt.AddToJSon('userProfile', 'ALPHAMEGA');
        JSonMgt.AddToJSon('responseLanguage', 'en');
        JSonMgt.AddToJSon('instrumentNo', POSTransaction."Continuity Member No.");
        JSonMgt.AddToJSon('instrumentType', 'M');
        JSonMgt.AddToJSon('transactionCategory', 'VCH');
        JSonMgt.AddToJSon('transactionType', 'VCH');
        //JSonMgt.AddToJSon('scheme', 0);
        JSonMgt.AddToJSon('transactionChannel', 'POS');
        //JSonMgt.AddToJSon('operatorId',POSTransaction."Staff ID");
        JSonMgt.AddToJSon('acquirerId', 'ALPHAMEGA');
        JSonMgt.AddToJSon('merchantId', POSTransaction."Store No.");
        JSonMgt.AddToJSon('terminalId', POSTransaction."POS Terminal No.");
        //JSonMgt.AddToJSon('transactionNo', '');
        //JSonMgt.AddToJSon('terminalBatchNumber', 0);
        JSonMgt.AddToJSon('terminalSequenceNumber', 1);
        JSonMgt.AddToJSon('transactionDate', FORMAT(DT, 0, '<Year4>-<Month,2>-<Day,2>'));
        JSonMgt.AddToJSon('transactionTime', TM);
        JSonMgt.AddToJSon('amount', 0);
        JSonMgt.AddToJSon('campaignsToApply', VoucherCode);
        */
        JsonObj.Add('institutionID', '2000');
        JsonObj.Add('institutionPassword', '2000AMEKO');
        JsonObj.Add('userProfile', 'ALPHAMEGA');
        JsonObj.Add('responseLanguage', 'en');
        JsonObj.Add('instrumentNo', POSTransaction."Continuity Member No.");
        JsonObj.Add('instrumentType', 'M');
        JsonObj.Add('transactionCategory', 'VCH');
        JsonObj.Add('transactionType', 'VCH');
        JsonObj.Add('transactionChannel', 'POS');
        JsonObj.Add('acquirerId', 'ALPHAMEGA');
        JsonObj.Add('merchantId', POSTransaction."Store No.");
        JsonObj.Add('terminalId', POSTransaction."POS Terminal No.");
        JsonObj.Add('terminalSequenceNumber', 1);
        JsonObj.Add('transactionDate', Format(DT, 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonObj.Add('transactionTime', TM);
        JsonObj.Add('amount', 0);
        JsonObj.Add('campaignsToApply', VoucherCode);
        //Bc Upgrade End
        POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
        POSTransLine.SetFilter(Quantity, '<>%1', 0);
        if POSTransLine.FindSet() then
            repeat
                if ItemInfo = '' then
                    ItemInfo := StrSubstNo(NT000, POSTransLine.Number, POSTransLine.Quantity, POSTransLine.Amount / POSTransLine.Quantity)
                else
                    ItemInfo := ItemInfo + ';' + StrSubstNo(NT000, POSTransLine.Number, POSTransLine.Quantity, POSTransLine.Amount / POSTransLine.Quantity);
            until POSTransLine.Next() = 0;
        //BC Upgrade Start
        /*
        JSonMgt.AddToJSon('itemsPurchased', ItemInfo);
        JSonMgt.EndJSon;
        DotNetString := JSonMgt.GetJSon;
        ReqOK := JSonMgt.UploadJSon(GenSetup."Continuity URL" + 'salesAdvice', '', '',
            DotNetString, GenSetup."Continuity Time Out (ms)");
            */
        JsonObj.Add('itemsPurchased', ItemInfo);
        JsonObj.WriteTo(JsonRequestBody);
        ReqOK := PosWebReqMgt.SendRequest2(GenSetup."Continuity URL" + 'salesAdvice', '', ''
        , JsonRequestBody, GenSetup."Continuity Time Out (ms)", JsonResponse);
        //BC Upgrade end
        POSContinuityEntry."Receipt No." := POSTransaction."Receipt No.";
        POSContinuityEntry."Trans. Date" := POSTransaction."Trans. Date";
        POSContinuityEntry."Trans. Time" := POSTransaction."Trans Time";
        POSContinuityEntry.Date := DT;
        POSContinuityEntry.Time := TM;
        POSContinuityEntry.Success := FALSE;
        POSContinuityEntry."Voucher Code" := VoucherCode;
        if ReqOK then begin
            if not DotNetString.IsNullOrWhiteSpace(JsonResponse) then begin
                DotNetString := JsonResponse;
                PosGenBufJSonMgt.ReadJSon(DotNetString, GenBuffer);
                POSContinuityEntry."Response Code" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseCode');
                POSContinuityEntry."Response Message Type" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessageType');
                POSContinuityEntry."Response Message" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessage');
                POSContinuityEntry."Merchant Name" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_merchantName');
                if Evaluate(POSContinuityEntry."Transaction Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_transactionAmount')) then;
                if Evaluate(POSContinuityEntry."Merchant Discount Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_merchantDiscountAmount')) then;
                if Evaluate(POSContinuityEntry."e-voucher Discount Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_evoucherDiscountAmount')) then;
                if Evaluate(POSContinuityEntry."Total Discount Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_totalDiscountAmount')) then;
                if Evaluate(POSContinuityEntry."Total Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_totalAmount')) then;
                if Evaluate(POSContinuityEntry."Available Redemption Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_availableRedemptionAmount')) then;
                if Evaluate(POSContinuityEntry."Redemption Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_redemptionAmount')) then;
                if Evaluate(POSContinuityEntry."Max Redem Amt. For Shop Items", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_maxRedeemableAmountForShopItems')) then;
                if Evaluate(POSContinuityEntry."Grand Total Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_grandTotalAmount')) then;
                if Evaluate(POSContinuityEntry."Previous Balance", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_previousBalance')) then;
                if Evaluate(POSContinuityEntry."Points Earned", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_pointsEarned')) then;
                if Evaluate(POSContinuityEntry."Points Redeemed", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_pointsRedeemed')) then;
                if Evaluate(POSContinuityEntry."New Balance", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_newBalance')) then;
                if Evaluate(POSContinuityEntry."Transaction Number", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_transactionNumber')) then;
                POSContinuityEntry."Initialize Terminal" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_initializeTerminal');
                POSContinuityEntry.Success := (POSContinuityEntry."Response Code" = '0') and not (POSContinuityEntry."Response Message" in ['E', 'e']);
            END;
        end else begin
            POSContinuityEntry."Response Code" := '-1';
            POSContinuityEntry."Response Message Type" := 'E';
            POSContinuityEntry."Response Message" := COPYSTR(JsonResponse, 1, 250);
            POSContinuityEntry.Success := FALSE;
        end;
        exit(POSContinuityEntry.Success);
    end;

    procedure POSSalesReversal(POSTransaction: Record "LSC POS Transaction"; var POSContinuityEntry: Record "POS Continuity Entry_NT"): Boolean
    var
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        GenSetup: Record "eCom_General Setup_NT";
        POSTransLine: Record "LSC POS Trans. Line";
        PosGenBufJSonMgt: Codeunit "Pos_Gen. Buffer Json Mgmt_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
        PosWebReqMgt: Codeunit "Pos_Web Request Management_NT";
        JsonObj: JsonObject;
        ReqOK: Boolean;
        DT: Date;
        ItemInfo: Text;
        JsonRequestBody: Text;
        JsonResponse: Text;
        TM: Time;
        NT000: label '%1;%2;%3';
        NT001: label 'The %1 does not exist';
        DotNetString: DotNet String;
    begin
        if POSTransaction."Continuity Member No." = '' then
            exit(false);

        if not GenSetup.Get() then begin
            PosTransCU.ErrorBeep(StrSubstNo(NT001, GenSetup.TableCaption));
            exit(false);
        end;
        GenSetup.TestField("Continuity URL");
        if GenSetup."Continuity Time Out (ms)" = 0 then
            GenSetup."Continuity Time Out (ms)" := 5000;
        //BC Upgrade Start
        /*
        JSonMgt.StartJSon;
        JSonMgt.AddToJSon('institutionID', '2000');
        JSonMgt.AddToJSon('institutionPassword', '2000AMEKO');
        JSonMgt.AddToJSon('userProfile', 'ALPHAMEGA');
        JSonMgt.AddToJSon('responseLanguage', 'en');
        JSonMgt.AddToJSon('instrumentNo', POSTransaction."Continuity Member No.");
        JSonMgt.AddToJSon('instrumentType', 'M');
        //JSonMgt.AddToJSon('scheme', 0);
        JSonMgt.AddToJSon('transactionChannel', 'POS');
        //JSonMgt.AddToJSon('operatorId',POSTransaction."Staff ID");
        JSonMgt.AddToJSon('acquirerId', 'ALPHAMEGA');
        JSonMgt.AddToJSon('merchantId', POSTransaction."Store No.");
        JSonMgt.AddToJSon('terminalId', POSTransaction."POS Terminal No.");
        //JSonMgt.AddToJSon('transactionNo', '');
        //JSonMgt.AddToJSon('terminalBatchNumber', 0);
        JSonMgt.AddToJSon('terminalSequenceNumber', 1);
        JSonMgt.AddToJSon('transactionDate', FORMAT(POSContinuityEntry.Date, 0, '<Year4>-<Month,2>-<Day,2>'));
        JSonMgt.AddToJSon('transactionTime', POSContinuityEntry.Time);
        JSonMgt.AddToJSon('amount', 0);
        */
        JsonObj.Add('institutionID', '2000');
        JsonObj.Add('institutionPassword', '2000AMEKO');
        JsonObj.Add('userProfile', 'ALPHAMEGA');
        JsonObj.Add('responseLanguage', 'en');
        JsonObj.Add('instrumentNo', POSTransaction."Continuity Member No.");
        JsonObj.Add('instrumentType', 'M');
        JsonObj.Add('transactionChannel', 'POS');
        JsonObj.Add('acquirerId', 'ALPHAMEGA');
        JsonObj.Add('merchantId', POSTransaction."Store No.");
        JsonObj.Add('terminalId', POSTransaction."POS Terminal No.");
        JsonObj.Add('terminalSequenceNumber', 1);
        JsonObj.Add('transactionDate', FORMAT(POSContinuityEntry.Date, 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonObj.Add('transactionTime', POSContinuityEntry.Time);
        JsonObj.Add('amount', 0);
        //BC Upgrade End
        POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
        POSTransLine.SetFilter(Quantity, '<>%1', 0);
        if POSTransLine.FindSet() then
            repeat
                if ItemInfo = '' then
                    ItemInfo := StrSubstNo(NT000, POSTransLine.Number, POSTransLine.Quantity, POSTransLine.Amount / POSTransLine.Quantity)
                else
                    ItemInfo := ItemInfo + ';' + StrSubstNo(NT000, POSTransLine.Number, POSTransLine.Quantity, POSTransLine.Amount / POSTransLine.Quantity);
            until POSTransLine.Next() = 0;
        //BC Upgrade Start
        /*
        JSonMgt.AddToJSon('itemsPurchased', ItemInfo);
        JSonMgt.EndJSon;
        DotNetString := JSonMgt.GetJSon;
        ReqOK := JSonMgt.UploadJSon(GenSetup."Continuity URL" + 'salesReversal', '', '',
            DotNetString, GenSetup."Continuity Time Out (ms)");
        */
        JsonObj.Add('itemsPurchased', ItemInfo);
        JsonObj.WriteTo(JsonRequestBody);
        ReqOK := PosWebReqMgt.SendRequest2(GenSetup."Continuity URL" + 'salesReversal', '', ''
        , JsonRequestBody, GenSetup."Continuity Time Out (ms)", JsonResponse);
        //BC Upgrade End
        if ReqOK then begin
            if not DotNetString.IsNullOrWhiteSpace(JsonResponse) then begin
                DotNetString := JsonResponse;
                PosGenBufJSonMgt.ReadJSon(DotNetString, GenBuffer);//BC Upgrade
                POSContinuityEntry."Reversal Response Code" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseCode');
                POSContinuityEntry."Reversal Response Message Type" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessageType');
                POSContinuityEntry."Reversal Response Message" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessage');
                POSContinuityEntry."Reversal Success" := (POSContinuityEntry."Response Code" = '0') AND NOT (POSContinuityEntry."Response Message" IN ['E', 'e']);
            end;
        end else begin
            POSContinuityEntry."Reversal Response Code" := '-1';
            POSContinuityEntry."Reversal Response Message Type" := 'E';
            //POSContinuityEntry."Reversal Response Message" := COPYSTR(GETLASTERRORTEXT, 1, 250);//BC Upgrade
            POSContinuityEntry."Reversal Response Message" := COPYSTR(JsonResponse, 1, 250);//BC Upgrade
            POSContinuityEntry."Reversal Success" := FALSE;
        end;
        exit(POSContinuityEntry."Reversal Success");
    end;

    procedure TermsAndConditions(POSTransaction: Record "LSC POS Transaction"; var POSContinuityEntry: Record "POS Continuity Entry_NT"): Boolean
    var
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        GenSetup: Record "eCom_General Setup_NT";
        PosGenBufJsonMgmt: Codeunit "Pos_Gen. Buffer Json Mgmt_NT";
        PosWebReqMgt: Codeunit "Pos_Web Request Management_NT";
        JsonObj: JsonObject;
        ReqOK: Boolean;
        JsonRequestBody: Text;
        JsonResponse: Text;
        NT001: label 'The %1 does not exist';
        DotNetString: DotNet String;
        NextContLineNo: Integer;
    begin
        clear(POSContinuityEntry);
        POSContinuityEntry.SetRange("Receipt No.", POSTransaction."Receipt No.");
        if POSContinuityEntry.FindLast() then
            NextContLineNo := POSContinuityEntry."Line No." + 10000
        else
            NextContLineNo := 10000;
        Clear(POSContinuityEntry);
        if POSTransaction."Continuity Member No." = '' then
            exit(false);

        if not GenSetup.Get() then begin
            PosTransCU.ErrorBeep(StrSubstNo(NT001, GenSetup.TableCaption));
            exit(false);
        end;
        GenSetup.TestField("Continuity URL");
        if GenSetup."Continuity Time Out (ms)" = 0 then
            GenSetup."Continuity Time Out (ms)" := 5000;
        //BC Upgrade Start
        /*
        JSonMgt.StartJSon;
        JSonMgt.AddToJSon('instrumentNumber', POSTransaction."Continuity Member No.");
        JSonMgt.AddToJSon('instrumentType', 'M');
        JSonMgt.AddToJSon('runoption', 'VERIFY');
        JSonMgt.AddToJSon('institutionID', '2000');
        JSonMgt.AddToJSon('institutionPassword', '2000AMEKO');
        JSonMgt.AddToJSon('userProfile', 'ALPHAMEGA');
        JSonMgt.AddToJSon('responseLanguage', 'en');
        JSonMgt.EndJSon;


        DotNetString := JSonMgt.GetJSon;
        ReqOK := JSonMgt.UploadJSon(GenSetup."Continuity URL" + 'maintainTermsAndConditions','','',
            DotNetString,GenSetup."Continuity Time Out (ms)");

        IF ReqOK THEN BEGIN
          IF NOT DotNetString.IsNullOrWhiteSpace(DotNetString) THEN BEGIN
            JSonMgt.ReadJSon(DotNetString,GenBuffer);
            POSContinuityEntry."T&C Response Code" := JSonMgt.GetJsonValue(GenBuffer,'returnMessageOutput_responseCode');
            POSContinuityEntry."T&C Response Message Type" := JSonMgt.GetJsonValue(GenBuffer,'returnMessageOutput_responseMessageType');
            POSContinuityEntry."T&C Response Message" := JSonMgt.GetJsonValue(GenBuffer,'returnMessageOutput_responseMessage');
            POSContinuityEntry."T&C Success" := (POSContinuityEntry."T&C Response Code" = '2470') AND NOT (POSContinuityEntry."T&C Response Message Type" IN ['E','e']);
            IF POSContinuityEntry."T&C Success" THEN BEGIN
              POSContinuityEntry."T&C Accepted" := JSonMgt.GetJsonValue(GenBuffer,'maintainTermsAndConditionOutputs_acceptedFlag') IN ['Y','y'];
              POSContinuityEntry."T&C Accepted Number" := JSonMgt.GetJsonValue(GenBuffer,'maintainTermsAndConditionOutputs_editionAcceptedNumber');
              POSContinuityEntry."T&C Accepted Name" := JSonMgt.GetJsonValue(GenBuffer,'maintainTermsAndConditionOutputs_editionAcceptedName');
            END;
          END;
        END ELSE BEGIN
          POSContinuityEntry."T&C Response Code" := '-1';
          POSContinuityEntry."T&C Response Message Type" := 'E';
          POSContinuityEntry."T&C Response Message" := COPYSTR(GETLASTERRORTEXT,1,250);
          POSContinuityEntry."T&C Success" := FALSE;
        END;
        */
        POSContinuityEntry."Receipt No." := POSTransaction."Receipt No.";
        POSContinuityEntry."Trans. Date" := POSTransaction."Trans. Date";
        POSContinuityEntry."Trans. Time" := POSTransaction."Trans Time";
        POSContinuityEntry.Date := Today;
        POSContinuityEntry.Time := Time;
        POSContinuityEntry.Success := FALSE;
        //BC Upgrade End
        JsonObj.Add('instrumentNumber', POSTransaction."Continuity Member No.");
        JsonObj.Add('instrumentType', 'M');
        JsonObj.Add('runoption', 'VERIFY');
        JsonObj.Add('institutionID', '2000');
        JsonObj.Add('institutionPassword', '2000AMEKO');
        JsonObj.Add('userProfile', 'ALPHAMEGA');
        JsonObj.Add('responseLanguage', 'en');
        JsonObj.WriteTo(JsonRequestBody);
        ReqOK := PosWebReqMgt.SendRequest2(GenSetup."Continuity URL" + 'maintainTermsAndConditions', '', '',
        JsonRequestBody, GenSetup."Continuity Time Out (ms)", JsonResponse);
        if ReqOK then begin
            if not DotNetString.IsNullOrWhiteSpace(JsonResponse) then begin
                DotNetString := JsonResponse;
                PosGenBufJsonMgmt.ReadJSon(DotNetString, GenBuffer);
                POSContinuityEntry."T&C Response Code" := PosGenBufJsonMgmt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseCode');
                POSContinuityEntry."T&C Response Message Type" := PosGenBufJsonMgmt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessageType');
                POSContinuityEntry."T&C Response Message" := PosGenBufJsonMgmt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessage');
                POSContinuityEntry."T&C Success" := (POSContinuityEntry."T&C Response Code" = '2470') and not (POSContinuityEntry."T&C Response Message Type" IN ['E', 'e']);
                if POSContinuityEntry."T&C Success" then begin
                    POSContinuityEntry."T&C Accepted" := PosGenBufJsonMgmt.GetJsonValue(GenBuffer, 'maintainTermsAndConditionOutputs_acceptedFlag') IN ['Y', 'y'];
                    POSContinuityEntry."T&C Accepted Number" := PosGenBufJsonMgmt.GetJsonValue(GenBuffer, 'maintainTermsAndConditionOutputs_editionAcceptedNumber');
                    POSContinuityEntry."T&C Accepted Name" := PosGenBufJsonMgmt.GetJsonValue(GenBuffer, 'maintainTermsAndConditionOutputs_editionAcceptedName');
                end;
            end;
        end else begin
            POSContinuityEntry."T&C Response Code" := '-1';
            POSContinuityEntry."T&C Response Message Type" := 'E';
            POSContinuityEntry."T&C Response Message" := CopyStr(JsonResponse, 1, 250);
            POSContinuityEntry."T&C Success" := false;
        end;
        POSContinuityEntry."Line No." := NextContLineNo;
        POSContinuityEntry.Insert();
        exit(POSContinuityEntry."T&C Accepted");
    end;

    procedure Sha256(InputSTR: Text): Text
    var
        CrypMgt: Codeunit "Cryptography Management";
        HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
    begin
        if InputSTR = '' then
            exit('');
        //BC Upgrade Start
        /*
        Encoding := Encoding.UTF8();
        HSHA256 := HSHA256.HMACSHA256(Encoding.GetBytes('3fd56daa3fb93fef3fe83fc886310c62'));
        Hash := HSHA256.ComputeHash(Encoding.GetBytes(InputSTR));
        HashStr := Convert.ToBase64String(Hash);
        EXIT(HashStr);
        */
        //BC Upgrade End
        exit(CrypMgt.GenerateHashAsBase64String(InputStr, '3fd56daa3fb93fef3fe83fc886310c62', HashAlgorithmType::HMACSHA256));//BC Upgrade
    end;

    procedure VoidContinuityCouponEntry(PosTrans: Record "LSC POS Transaction")
    var
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        POSTransLine.Reset();
        POSTransLine.SetRange("Receipt No.", PosTrans."Receipt No.");
        POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
        POSTransLine.SetFilter("Continuity Voucher No.", '<>%1', '');
        if POSTransLine.FindSet() then
            repeat
                VoidLineContinuityCouponEntry(PosTrans, POSTransLine);
            until POSTransLine.Next() = 0;
    end;

    procedure VoidLineContinuityCouponEntry(PosTrans: Record "LSC POS Transaction"; POSTransLine: Record "LSC POS Trans. Line")
    var
        POSContinuityEntry: Record "POS Continuity Entry_NT";
    begin
        if POSTransLine."Continuity Voucher No." = '' then
            exit;
        POSContinuityEntry.SetRange("Receipt No.", POSTransLine."Receipt No.");
        POSContinuityEntry.SetRange("Voucher Code", POSTransLine."Continuity Voucher No.");
        POSContinuityEntry.SetRange(Status, POSContinuityEntry.Status::" ");
        POSContinuityEntry.SetRange(Success, true);
        if POSContinuityEntry.FindFirst() then begin
            POSSalesReversal(PosTrans, POSContinuityEntry);
            if POSContinuityEntry."Reversal Success" then
                POSContinuityEntry.Status := POSContinuityEntry.Status::Voided;
            POSContinuityEntry.Modify();
        end;
    end;

    procedure SalesAdvice(TransactionHeader: Record "LSC Transaction Header"; var TransContinuityEntry: Record "Pos_Trans. Continuity Entry_NT"): Boolean
    var
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        GenSetup: Record "eCom_General Setup_NT";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        PosGenBufJSonMgt: Codeunit "Pos_Gen. Buffer Json Mgmt_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
        PosWebReqMgt: Codeunit "Pos_Web Request Management_NT";
        JsonObj: JsonObject;
        ReqOK: Boolean;
        DT: Date;
        ItemInfo: Text;
        JsonRequestBody: Text;
        JsonResponse: Text;
        TM: Time;
        NT000: label '%1;%2;%3';
        NT001: label 'The %1 does not exist';
        DotNetString: DotNet String;
    begin
        if TransactionHeader."Continuity Member No." = '' then
            exit;
        if not GenSetup.Get() then begin
            PosTransCU.ErrorBeep(StrSubstNo(NT001, GenSetup.TableCaption));
            exit(false);
        end;
        GenSetup.TestField("Continuity URL");
        if GenSetup."Continuity Time Out (ms)" = 0 then
            GenSetup."Continuity Time Out (ms)" := 5000;
        //VoucherNos := '';
        //POSContinuityEntry.SETRANGE("Receipt No.",TransactionHeader."Receipt No.");
        //POSContinuityEntry.SETRANGE(Success,TRUE);
        //IF POSContinuityEntry.FINDSET THEN
        //  REPEAT
        //    VoucherNos := VoucherNos + POSContinuityEntry."Voucher Code" + ';';
        //  UNTIL POSContinuityEntry.NEXT = 0;

        DT := TODAY;
        TM := TIME;
        //BC Upgrade Start
        /*
        JSonMgt.StartJSon;
        JSonMgt.AddToJSon('institutionID', '2000');
        JSonMgt.AddToJSon('institutionPassword', '2000AMEKO');
        JSonMgt.AddToJSon('userProfile', 'ALPHAMEGA');
        JSonMgt.AddToJSon('responseLanguage', 'en');
        JSonMgt.AddToJSon('instrumentNo', TransactionHeader."Continuity Member No.");
        JSonMgt.AddToJSon('instrumentType', 'M');
        //JSonMgt.AddToJSon('scheme', 0);
        JSonMgt.AddToJSon('transactionChannel', 'POS');
        //JSonMgt.AddToJSon('operatorId',TransactionHeader."Staff ID");
        JSonMgt.AddToJSon('acquirerId', 'ALPHAMEGA');
        JSonMgt.AddToJSon('merchantId', TransactionHeader."Store No.");
        JSonMgt.AddToJSon('terminalId', TransactionHeader."POS Terminal No.");
        //JSonMgt.AddToJSon('transactionNo', TransactionHeader."Transaction No.");
        //JSonMgt.AddToJSon('terminalBatchNumber', 0);
        JSonMgt.AddToJSon('terminalSequenceNumber', 1);
        JSonMgt.AddToJSon('transactionDate', FORMAT(DT, 0, '<Year4>-<Month,2>-<Day,2>'));
        JSonMgt.AddToJSon('transactionTime', TM);
        JSonMgt.AddToJSon('amount', ROUND(-TransactionHeader."Loyalty Gross Amount", 0.01));
        JSonMgt.AddToJSon('campaignsToApply', '');//VoucherNos);
        */

        JsonObj.Add('institutionID', '2000');
        JsonObj.Add('institutionPassword', '2000AMEKO');
        JsonObj.Add('userProfile', 'ALPHAMEGA');
        JsonObj.Add('responseLanguage', 'en');
        JsonObj.Add('instrumentNo', TransactionHeader."Continuity Member No.");
        JsonObj.Add('instrumentType', 'M');
        //JSonMgt.AddToJSon('scheme', 0);
        JsonObj.Add('transactionChannel', 'POS');
        //JSonMgt.AddToJSon('operatorId',TransactionHeader."Staff ID");
        JsonObj.Add('acquirerId', 'ALPHAMEGA');
        JsonObj.Add('merchantId', TransactionHeader."Store No.");
        JsonObj.Add('terminalId', TransactionHeader."POS Terminal No.");
        //JSonMgt.AddToJSon('transactionNo', TransactionHeader."Transaction No.");
        //JSonMgt.AddToJSon('terminalBatchNumber', 0);
        JsonObj.Add('terminalSequenceNumber', 1);
        JsonObj.Add('transactionDate', FORMAT(DT, 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonObj.Add('transactionTime', TM);
        JsonObj.Add('amount', Round(-TransactionHeader."Loyalty Gross Amount", 0.01));
        JsonObj.Add('campaignsToApply', '');//VoucherNos);

        TransSalesEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        if TransSalesEntry.FindSet() then
            repeat
                if ItemInfo = '' then
                    ItemInfo := StrSubstNo(NT000, TransSalesEntry."Item No.", -TransSalesEntry.Quantity, (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount") / TransSalesEntry.Quantity)
                else
                    ItemInfo := ItemInfo + ';' + StrSubstNo(NT000, TransSalesEntry."Item No.", -TransSalesEntry.Quantity,
                    (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount") / TransSalesEntry.Quantity);
            until TransSalesEntry.Next() = 0;
        JsonObj.Add('itemsPurchased', ItemInfo);

        JsonObj.WriteTo(JsonRequestBody);
        ReqOK := PosWebReqMgt.SendRequest2(GenSetup."Continuity URL" + 'salesAdvice', '', ''
        , JsonRequestBody, GenSetup."Continuity Time Out (ms)", JsonResponse);

        TransContinuityEntry."Store No." := TransactionHeader."Store No.";
        TransContinuityEntry."POS Terminal No." := TransactionHeader."POS Terminal No.";
        TransContinuityEntry."Transaction No." := TransactionHeader."Transaction No.";
        TransContinuityEntry."Receipt No." := TransactionHeader."Receipt No.";
        TransContinuityEntry."Trans. Date" := TransactionHeader.Date;
        TransContinuityEntry."Trans. Time" := TransactionHeader.Time;
        TransContinuityEntry.Date := DT;
        TransContinuityEntry.Time := TM;
        TransContinuityEntry.Success := false;
        if ReqOK then begin
            if not DotNetString.IsNullOrWhiteSpace(JsonResponse) then begin
                DotNetString := JsonResponse;
                PosGenBufJSonMgt.ReadJSon(DotNetString, GenBuffer);
                TransContinuityEntry."Response Code" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseCode');
                TransContinuityEntry."Response Message Type" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessageType');
                TransContinuityEntry."Response Message" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessage');
                TransContinuityEntry."Merchant Name" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_merchantName');
                if Evaluate(TransContinuityEntry."Transaction Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_transactionAmount')) then;
                if Evaluate(TransContinuityEntry."Merchant Discount Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_merchantDiscountAmount')) then;
                if Evaluate(TransContinuityEntry."e-voucher Discount Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_evoucherDiscountAmount')) then;
                if Evaluate(TransContinuityEntry."Total Discount Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_totalDiscountAmount')) then;
                if Evaluate(TransContinuityEntry."Total Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_totalAmount')) then;
                if Evaluate(TransContinuityEntry."Available Redemption Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_availableRedemptionAmount')) then;
                if Evaluate(TransContinuityEntry."Redemption Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_redemptionAmount')) then;
                if Evaluate(TransContinuityEntry."Max Redem Amt. For Shop Items", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_maxRedeemableAmountForShopItems')) then;
                if Evaluate(TransContinuityEntry."Grand Total Amount", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_grandTotalAmount')) then;
                if Evaluate(TransContinuityEntry."Previous Balance", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_previousBalance')) then;
                if Evaluate(TransContinuityEntry."Points Earned", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_pointsEarned')) then;
                if Evaluate(TransContinuityEntry."Points Redeemed", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_pointsRedeemed')) then;
                if Evaluate(TransContinuityEntry."New Balance", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_newBalance')) then;
                if Evaluate(TransContinuityEntry."Transaction Number", PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_transactionNumber')) then;
                TransContinuityEntry."Initialize Terminal" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'transactionSet_initializeTerminal');
                TransContinuityEntry.Success := (TransContinuityEntry."Response Code" = '0') and not (TransContinuityEntry."Response Message" in ['E', 'e']);
            end;
        end else begin
            TransContinuityEntry."Response Code" := '-1';
            TransContinuityEntry."Response Message Type" := 'E';
            TransContinuityEntry."Response Message" := COPYSTR(GETLASTERRORTEXT, 1, 250);
            TransContinuityEntry.Success := FALSE;
        end;
        TransContinuityEntry."Line No." := 10000;
        if not TransContinuityEntry.Insert() then
            repeat
                TransContinuityEntry."Line No." += 10000;
            until TransContinuityEntry.INSERT;
        exit(TransContinuityEntry.Success);
    end;

    procedure SalesReversal(TransactionHeader: Record "LSC Transaction Header"; FromTransContinuityEntry: Record "Pos_Trans. Continuity Entry_NT"): Boolean
    var
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        GenSetup: Record "eCom_General Setup_NT";
        TransContinuityEntry: Record "Pos_Trans. Continuity Entry_NT";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        PosGenBufJSonMgt: Codeunit "Pos_Gen. Buffer Json Mgmt_NT";
        PosTransCU: Codeunit "LSC POS Transaction";
        PosWebReqMgt: Codeunit "Pos_Web Request Management_NT";
        JsonObj: JsonObject;
        ReqOK: Boolean;
        DT: Date;
        ItemInfo: Text;
        JsonRequestBody: Text;
        JsonResponse: Text;
        TM: Time;
        NT000: label '%1;%2;%3';
        NT001: label 'The %1 does not exist';
        DotNetString: DotNet String;
    begin
        if TransactionHeader."Continuity Member No." = '' then
            exit;

        if not GenSetup.Get() then begin
            PosTransCU.ErrorBeep(StrSubstNo(NT001, GenSetup.TableCaption));
            exit(false);
        end;
        GenSetup.TestField("Continuity URL");
        if GenSetup."Continuity Time Out (ms)" = 0 then
            GenSetup."Continuity Time Out (ms)" := 5000;

        DT := FromTransContinuityEntry.Date;
        TM := FromTransContinuityEntry.Time;

        if DT = 0D then
            DT := TODAY;
        if TM = 0T then
            TM := TIME;

        JsonObj.Add('institutionID', '2000');
        JsonObj.Add('institutionPassword', '2000AMEKO');
        JsonObj.Add('userProfile', 'ALPHAMEGA');
        JsonObj.Add('responseLanguage', 'en');
        JsonObj.Add('instrumentNo', TransactionHeader."Continuity Member No.");
        JsonObj.Add('instrumentType', 'M');
        JsonObj.Add('transactionChannel', 'POS');
        JsonObj.Add('acquirerId', 'ALPHAMEGA');
        JsonObj.Add('merchantId', TransactionHeader."Store No.");
        JsonObj.Add('terminalId', TransactionHeader."POS Terminal No.");
        JsonObj.Add('terminalSequenceNumber', 1);
        JsonObj.Add('transactionDate', Format(DT, 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonObj.Add('transactionTime', TM);
        JsonObj.Add('amount', Round(-TransactionHeader."Loyalty Gross Amount", 0.01));

        TransSalesEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        if TransSalesEntry.FindSet() then
            repeat
                if ItemInfo = '' then
                    ItemInfo := StrSubstNo(NT000, TransSalesEntry."Item No.", -TransSalesEntry.Quantity, (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount") / TransSalesEntry.Quantity)
                else
                    ItemInfo := ItemInfo + ';' + StrSubstNo(NT000, TransSalesEntry."Item No.", -TransSalesEntry.Quantity,
                    (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount") / TransSalesEntry.Quantity);
            until TransSalesEntry.Next() = 0;
        JsonObj.Add('itemsPurchased', ItemInfo);

        JsonObj.WriteTo(JsonRequestBody);
        ReqOK := PosWebReqMgt.SendRequest2(GenSetup."Continuity URL" + 'salesReversal', '', ''
        , JsonRequestBody, GenSetup."Continuity Time Out (ms)", JsonResponse);


        TransContinuityEntry."Store No." := TransactionHeader."Store No.";
        TransContinuityEntry."POS Terminal No." := TransactionHeader."POS Terminal No.";
        TransContinuityEntry."Transaction No." := TransactionHeader."Transaction No.";
        TransContinuityEntry."Receipt No." := TransactionHeader."Receipt No.";
        TransContinuityEntry."Trans. Date" := TransactionHeader.Date;
        TransContinuityEntry."Trans. Time" := TransactionHeader.Time;
        TransContinuityEntry.Date := DT;
        TransContinuityEntry.Time := TM;
        TransContinuityEntry.Success := false;
        if ReqOK then begin
            if not DotNetString.IsNullOrWhiteSpace(JsonResponse) then begin
                DotNetString := JsonResponse;
                TransContinuityEntry."Response Code" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseCode');
                TransContinuityEntry."Response Message Type" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessageType');
                TransContinuityEntry."Response Message" := PosGenBufJSonMgt.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessage');
                TransContinuityEntry.Success := (TransContinuityEntry."Response Code" = '0') and not (TransContinuityEntry."Response Message" in ['E', 'e']);
            end;
        end else begin
            TransContinuityEntry."Response Code" := '-1';
            TransContinuityEntry."Response Message Type" := 'E';
            //TransContinuityEntry."Response Message" := CopyStr(GetLastErrorText(), 1, 250);//BC Upgrade
            TransContinuityEntry."Response Message" := CopyStr(JsonResponse, 1, 250);//BC Upgrade
            TransContinuityEntry.Success := false;
        end;

        TransContinuityEntry."Line No." := 10000;
        if not TransContinuityEntry.Insert() then
            repeat
                TransContinuityEntry."Line No." += 10000;
            until TransContinuityEntry.Insert();
        exit(TransContinuityEntry.Success);
    end;

    procedure CheckContinuityInProcessScannerInput(var pScanInput: Text; var PosTrans: Record "LSC POS Transaction"; var IsHandled: Boolean)
    var
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        PosGenBufJsonMgmt: Codeunit "Pos_Gen. Buffer Json Mgmt_NT";
        DotNetString: DotNet String;
    begin
        if (StrPos(pScanInput, '"continuityMember"') > 0) then begin
            DotNetString := pScanInput;
            PosGenBufJsonMgmt.ReadJSon(DotNetString, GenBuffer);
            pScanInput := PosGenBufJsonMgmt.GetJsonValue(GenBuffer, 'continuityMember_mobileNo');
            ContinuityMemberPressed(pScanInput, PosTrans);
            IsHandled := true;
        end else
            if (StrPos(pScanInput, '"continuityVoucher"') > 0) then begin
                ContinuityVoucherPressed(pScanInput, PosTrans);
                IsHandled := true;
            end;
    end;

    local procedure ContinuityMemberPressed(var pScanInput: Text; var REC: Record "LSC POS Transaction")
    var
        POSContinuityEntry: Record "POS Continuity Entry_NT";
    begin
        if pScanInput = '' then begin
            PosTransCU.ErrorBeep('Error Proccessing request');
            exit;
        end;

        //BC Upgrade Start
        /*
        
        REC."Continuity Member No." := pScanInput;
        REC.MODIFY;        
        pScanInput := '';
        if not ContinuityMgt.TermsAndConditions(REC, POSContinuityEntry) then
            PosTransCU.PosMessage('Customer has to accept terms and conditions.');
        PosTransCU.PosMessage(StrSubstNo('Continuity Member %1 added.', pScanInput));
        */
        REC."Continuity Member No." := pScanInput;
        if not TermsAndConditions(REC, POSContinuityEntry) then
            PosTransCU.PosMessage('Customer has to accept terms and conditions.')
        else begin
            PosTransCU.PosMessage(StrSubstNo('Continuity Member %1 added.', pScanInput));
            REC."Continuity Member No." := pScanInput;
            REC.Modify();
            pScanInput := '';
        end;
        //BC Upgrade End
    end;

    local procedure ContinuityVoucherPressed(var InputSTR: Text; var REC: Record "LSC POS Transaction")
    var
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        POSContinuityEntry: Record "POS Continuity Entry_NT";
        JSonMgt: Codeunit "Pos_Gen. Buffer Json Mgmt_NT";
        PosGenUtility: Codeunit "Pos_General Utility_NT";
        MobileNo: Code[10];
        i: Integer;
        NextContLineNo: Integer;
        Qty: Integer;
        PromoBarcode: Text[20];
        Signature: Text;
        txtQty: Text;
        VoucherCode: Text[30];
        InvalidBarcodeErr: Label 'Invalid Continuity Barcode';
        DotNetString: DotNet String;
        PosView: Codeunit "LSC POS View";
    begin
        DotNetString := InputSTR;
        JSonMgt.ReadJSon(DotNetString, GenBuffer);
        MobileNo := JSonMgt.GetJsonValue(GenBuffer, 'continuityVoucher_mobileNo');
        VoucherCode := JSonMgt.GetJsonValue(GenBuffer, 'continuityVoucher_voucherCode');
        Signature := JSonMgt.GetJsonValue(GenBuffer, 'continuityVoucher_signature');
        PromoBarcode := JSonMgt.GetJsonValue(GenBuffer, 'continuityVoucher_promotionalBarcode');
        txtQty := JSonMgt.GetJsonValue(GenBuffer, 'continuityVoucher_quantity');
        if not Evaluate(Qty, txtQty) then
            Qty := 1;
        if (Signature = '') or (MobileNo = '') or (PromoBarcode = '') or (VoucherCode = '') then begin
            PosTransCU.ErrorBeep('Invalid QR Code');
            exit;
        end;

        REC."Continuity Member No." := MobileNo;
        REC.Modify();
        Commit();
        ;

        if Signature <> Sha256(VoucherCode + PromoBarcode + txtQty) then begin
            PosTransCU.ErrorBeep('Signature Mismatch');
            exit;
        end;

        POSContinuityEntry.SETRANGE("Receipt No.", REC."Receipt No.");
        if POSContinuityEntry.FindLast() then
            NextContLineNo := POSContinuityEntry."Line No.";
        NextContLineNo += 10000;
        Clear(POSContinuityEntry);
        if not POSSalesAdvice(REC, POSContinuityEntry, VoucherCode) then
            POSSalesReversal(REC, POSContinuityEntry);

        POSContinuityEntry."Line No." := NextContLineNo;
        POSContinuityEntry.Insert();
        if not POSContinuityEntry.Success then begin
            PosTransCU.ErrorBeep(POSContinuityEntry."Response Message");
            exit;
        end;
        //BC Upgrade Start
        /*
        FOR i := 1 TO Qty DO BEGIN
            InputSTR := PromoBarcode;
            _VoucherCode := VoucherCode;
            ProcessBarcode;
            _VoucherCode := '';
        END;
        */
        for i := 1 to Qty do begin
            PosGenUtility.SetContinuityVoucher(VoucherCode);
            //PosTransCU.SetCurrInput(PromoBarcode);//BC22
            PosView.SetCurrInput(PromoBarcode);//BC22
            //if not PosTransCU.ProcessBarcode() then //BC22
            if not PosView.ProcessBarcode() then //BC22
                PosTransCU.ErrorBeep(InvalidBarcodeErr);
        end;
        VoucherCode := '';
        PosGenUtility.SetContinuityVoucher(VoucherCode);
        //BC Upgrade End        
    end;

    var
        PosTransCU: Codeunit "LSC POS Transaction";
}
