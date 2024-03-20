codeunit 60107 "eCom_Continuity Mgt_NT"
{
    procedure SalesAdvice(TransactionHeader: Record "LSC Transaction Header"; VAR TransContinuityEntry: Record "eCom_Trans. Contin. Entry_NT"): Boolean
    var
        GenSetup: Record "eCom_General Setup_NT";
        DT: Date;
        TM: Time;
        eComWebReqMgt: Codeunit "eCom_Web Request Mgmt_NT";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        ItemInfo: Text;
        ReqOK: Boolean;
        DotNetString: DotNet String;
        JsonRequestBody: Text;
        JsonResponse: Text;
        JsonObj: JsonObject;
        GenBuffer: Record "eCom_General Buffer_NT" temporary;
        eComGenFn: Codeunit "eCom_General Functions_NT";
    begin
        IF TransactionHeader."Continuity Member No." = '' THEN
            EXIT;

        GenSetup.GET;
        GenSetup.TESTFIELD("Continuity URL");
        IF GenSetup."Continuity Time Out (ms)" = 0 THEN
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
        /* BC Upgrade
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
        //BC Upgrade Start
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
        //JsonObj.Add('transactionTime', TM);
        JsonObj.Add('transactionTime', Format(TM, 0, '<Hours24>:<Minutes,2>:<Seconds,2>'));
        JsonObj.Add('amount', ROUND(-TransactionHeader."Loyalty Gross Amount", 0.01));
        JsonObj.Add('campaignsToApply', '');//VoucherNos);
        //BC Upgrade end
        TransSalesEntry.SETRANGE("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SETRANGE("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SETRANGE("Transaction No.", TransactionHeader."Transaction No.");
        IF TransSalesEntry.FINDSET THEN
            REPEAT
                IF ItemInfo = '' THEN
                    ItemInfo := STRSUBSTNO(NT000, TransSalesEntry."Item No.", -TransSalesEntry.Quantity, (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount") / TransSalesEntry.Quantity)
                ELSE
                    ItemInfo := ItemInfo + ';' + STRSUBSTNO(NT000, TransSalesEntry."Item No.", -TransSalesEntry.Quantity,
                    (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount") / TransSalesEntry.Quantity);
            UNTIL TransSalesEntry.NEXT = 0;
        //JSonMgt.AddToJSon('itemsPurchased', ItemInfo); BC Upgrade
        JsonObj.Add('itemsPurchased', ItemInfo);
        //JSonMgt.EndJSon; BC Upgrade
        JsonObj.WriteTo(JsonRequestBody);//BC Upgrade
                                         //DotNetString := JSonMgt.GetJSon; BC Upgrade
                                         /* BC Upgrade
                                         ReqOK := JSonMgt.UploadJSon(GenSetup."Continuity URL" + 'salesAdvice', '', '',
                                           DotNetString, GenSetup."Continuity Time Out (ms)");
                                           */
        ReqOK := eComWebReqMgt.SendRequest2(GenSetup."Continuity URL" + 'salesAdvice', '', '', JsonRequestBody, GenSetup."Continuity Time Out (ms)", JsonResponse);//BC Upgrade
        TransContinuityEntry."Store No." := TransactionHeader."Store No.";
        TransContinuityEntry."POS Terminal No." := TransactionHeader."POS Terminal No.";
        TransContinuityEntry."Transaction No." := TransactionHeader."Transaction No.";
        TransContinuityEntry."Receipt No." := TransactionHeader."Receipt No.";
        TransContinuityEntry."Trans. Date" := TransactionHeader.Date;
        TransContinuityEntry."Trans. Time" := TransactionHeader.Time;
        TransContinuityEntry.Date := DT;
        TransContinuityEntry.Time := TM;
        TransContinuityEntry.Success := FALSE;
        IF ReqOK THEN BEGIN
            //IF NOT DotNetString.IsNullOrWhiteSpace(DotNetString) THEN BEGIN BC Upgrade            
            IF NOT DotNetString.IsNullOrWhiteSpace(JsonResponse) THEN BEGIN //BC Upgrade
                //JSonMgt.ReadJSon(DotNetString, GenBuffer); BC Upgrade
                DotNetString := JsonResponse;
                eComGenFn.ReadJSon(DotNetString, GenBuffer);//BC Upgrade
                TransContinuityEntry."Response Code" := eComGenFn.GetJsonValue(GenBuffer, 'returnMessageOutput_responseCode');
                TransContinuityEntry."Response Message Type" := eComGenFn.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessageType');
                TransContinuityEntry."Response Message" := eComGenFn.GetJsonValue(GenBuffer, 'returnMessageOutput_responseMessage');
                TransContinuityEntry."Merchant Name" := eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_merchantName');
                IF EVALUATE(TransContinuityEntry."Transaction Amount", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_transactionAmount')) THEN;
                IF EVALUATE(TransContinuityEntry."Merchant Discount Amount", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_merchantDiscountAmount')) THEN;
                IF EVALUATE(TransContinuityEntry."e-voucher Discount Amount", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_evoucherDiscountAmount')) THEN;
                IF EVALUATE(TransContinuityEntry."Total Discount Amount", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_totalDiscountAmount')) THEN;
                IF EVALUATE(TransContinuityEntry."Total Amount", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_totalAmount')) THEN;
                IF EVALUATE(TransContinuityEntry."Available Redemption Amount", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_availableRedemptionAmount')) THEN;
                IF EVALUATE(TransContinuityEntry."Redemption Amount", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_redemptionAmount')) THEN;
                IF EVALUATE(TransContinuityEntry."Max Redem Amt. For Shop Items", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_maxRedeemableAmountForShopItems')) THEN;
                IF EVALUATE(TransContinuityEntry."Grand Total Amount", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_grandTotalAmount')) THEN;
                IF EVALUATE(TransContinuityEntry."Previous Balance", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_previousBalance')) THEN;
                IF EVALUATE(TransContinuityEntry."Points Earned", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_pointsEarned')) THEN;
                IF EVALUATE(TransContinuityEntry."Points Redeemed", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_pointsRedeemed')) THEN;
                IF EVALUATE(TransContinuityEntry."New Balance", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_newBalance')) THEN;
                IF EVALUATE(TransContinuityEntry."Transaction Number", eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_transactionNumber')) THEN;
                TransContinuityEntry."Initialize Terminal" := eComGenFn.GetJsonValue(GenBuffer, 'transactionSet_initializeTerminal');
                TransContinuityEntry.Success := (TransContinuityEntry."Response Code" = '0') AND NOT (TransContinuityEntry."Response Message" IN ['E', 'e']);
            END;
        END ELSE BEGIN
            TransContinuityEntry."Response Code" := '-1';
            TransContinuityEntry."Response Message Type" := 'E';
            TransContinuityEntry."Response Message" := COPYSTR(GETLASTERRORTEXT, 1, 250);
            TransContinuityEntry.Success := FALSE;
        END;
        TransContinuityEntry."Line No." := 10000;
        IF NOT TransContinuityEntry.INSERT THEN
            REPEAT
                TransContinuityEntry."Line No." += 10000;
            UNTIL TransContinuityEntry.INSERT;
        EXIT(TransContinuityEntry.Success);
    end;

    var
        NT000: Label '%1;%2;%3';
}
