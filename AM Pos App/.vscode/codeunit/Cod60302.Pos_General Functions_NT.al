codeunit 60302 "Pos_General Functions_NT"
{
    trigger OnRun()
    var
    begin
    end;

    procedure GetDiscOfferLineTotal(PeriodicDiscount: Record "LSC Periodic Discount"; CurrLine: Record "LSC POS Transaction"; TransAmt: Decimal) OfferLineAmt: Decimal
    var
        Item: Record Item;
        ItemSpecialGroup: Record "LSC Item/Special Group Link";
        PeriodicDiscountLine: Record "LSC Periodic Discount Line";
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        POSTransLine.Reset();
        POSTransLine.SetRange("Receipt No.", CurrLine."Receipt No.");
        POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
        OfferLineAmt := 0;
        PeriodicDiscountLine.Reset();
        PeriodicDiscountLine.SetRange("Offer No.", PeriodicDiscount."No.");
        PeriodicDiscountLine.SetRange(Type, PeriodicDiscountLine.Type::All);
        if PeriodicDiscountLine.FindFirst() then begin
            OfferLineAmt := TransAmt;
            exit;
        end;
        PeriodicDiscountLine.SetRange(Type);
        if PeriodicDiscountLine.Find('-') then
            repeat
                case PeriodicDiscountLine.Type of
                    PeriodicDiscountLine.Type::Item:
                        begin
                            POSTransLine.SetRange(Number, PeriodicDiscountLine."No.");
                            if POSTransLine.FindFirst() then
                                repeat
                                    OfferLineAmt += POSTransLine."Discount Amount" + POSTransLine.Amount;
                                until POSTransLine.Next() = 0;
                        end;
                    PeriodicDiscountLine.Type::"Product Group":
                        begin
                            //_POSTransLine.SETRANGE("Product Group Code", _PeriodicDiscountLine."No.");//BC Upgrade
                            POSTransLine.SetRange("Retail Product Code", PeriodicDiscountLine."No.");//BC Upgrade
                            IF POSTransLine.FindFirst() THEN
                                repeat
                                    OfferLineAmt += POSTransLine."Discount Amount" + POSTransLine.Amount;
                                until POSTransLine.Next() = 0;
                        end;
                    PeriodicDiscountLine.Type::"Item Category":
                        begin
                            POSTransLine.SetRange("Item Category Code", PeriodicDiscountLine."No.");
                            if POSTransLine.FindFirst() then
                                repeat
                                    OfferLineAmt += POSTransLine."Discount Amount" + POSTransLine.Amount;
                                until POSTransLine.Next() = 0;
                        end;
                    PeriodicDiscountLine.Type::"Special Group":
                        if POSTransLine.FindFirst() then
                            repeat
                                if ItemSpecialGroup.Get(POSTransLine.Number, PeriodicDiscountLine."No.") then
                                    OfferLineAmt += POSTransLine."Discount Amount" + POSTransLine.Amount;
                            until POSTransLine.Next() = 0;
                    else begin
                        OfferLineAmt := TransAmt;
                        exit;
                    end;
                end;
            until PeriodicDiscountLine.Next() = 0;
    end;

    procedure DiscOfferLineTotal(PeriodicDiscount: Record "LSC Periodic Discount"; POSTrans: Record "LSC POS Transaction"; TransAmt: Decimal) OfferLineAmt: Decimal
    var
        USEDPOSTransLineTemp: Record "LSC POS Trans. Line" temporary;
        _Item: Record Item;
        _ItemSpecialGroup: Record "LSC Item/Special Group Link";
        _PeriodicDiscountLine: Record "LSC Periodic Discount Line";
        _POSTransLine: Record "LSC POS Trans. Line";
        BenefitAmount: Decimal;
    begin
        IF NOT PeriodicDiscount."Amt. to Trigger Based on Lines" THEN
            EXIT(TransAmt);

        _POSTransLine.RESET;
        _POSTransLine.SETRANGE("Receipt No.", POSTrans."Receipt No.");
        _POSTransLine.SETRANGE("Entry Status", _POSTransLine."Entry Status"::" ");
        _POSTransLine.SETRANGE("Entry Type", _POSTransLine."Entry Type"::Item);
        OfferLineAmt := 0;
        _PeriodicDiscountLine.RESET;
        _PeriodicDiscountLine.SETRANGE("Offer No.", PeriodicDiscount."No.");
        _PeriodicDiscountLine.SETRANGE(Type, _PeriodicDiscountLine.Type::All);
        IF _PeriodicDiscountLine.FINDFIRST THEN BEGIN
            OfferLineAmt := TransAmt;
            EXIT;
        END;
        USEDPOSTransLineTemp.RESET;
        USEDPOSTransLineTemp.DELETEALL;
        _PeriodicDiscountLine.SETRANGE(Type);
        IF _PeriodicDiscountLine.FIND('-') THEN
            REPEAT
                CASE _PeriodicDiscountLine.Type OF
                    _PeriodicDiscountLine.Type::Item:
                        BEGIN
                            _POSTransLine.SETRANGE(Number, _PeriodicDiscountLine."No.");
                            IF _POSTransLine.FINDFIRST THEN
                                REPEAT
                                    IF NOT USEDPOSTransLineTemp.GET(_POSTransLine."Receipt No.", _POSTransLine."Line No.") THEN BEGIN
                                        OfferLineAmt += _POSTransLine."Discount Amount" + _POSTransLine.Amount;
                                        USEDPOSTransLineTemp := _POSTransLine;
                                        USEDPOSTransLineTemp.INSERT;
                                    END;
                                UNTIL _POSTransLine.NEXT = 0;
                        END;
                    _PeriodicDiscountLine.Type::"Product Group":
                        BEGIN
                            //_POSTransLine.SETRANGE("Product Group Code", _PeriodicDiscountLine."No.");//BC Upgrade
                            _POSTransLine.SETRANGE("Retail Product Code", _PeriodicDiscountLine."No.");//BC Upgrade
                            IF _POSTransLine.FINDFIRST THEN
                                REPEAT
                                    IF NOT USEDPOSTransLineTemp.GET(_POSTransLine."Receipt No.", _POSTransLine."Line No.") THEN BEGIN
                                        OfferLineAmt += _POSTransLine."Discount Amount" + _POSTransLine.Amount;
                                        USEDPOSTransLineTemp := _POSTransLine;
                                        USEDPOSTransLineTemp.INSERT;
                                    END;
                                UNTIL _POSTransLine.NEXT = 0;
                        END;
                    _PeriodicDiscountLine.Type::"Item Category":
                        BEGIN
                            _POSTransLine.SETRANGE("Item Category Code", _PeriodicDiscountLine."No.");
                            IF _POSTransLine.FINDFIRST THEN
                                REPEAT
                                    IF NOT USEDPOSTransLineTemp.GET(_POSTransLine."Receipt No.", _POSTransLine."Line No.") THEN BEGIN
                                        OfferLineAmt += _POSTransLine."Discount Amount" + _POSTransLine.Amount;
                                        USEDPOSTransLineTemp := _POSTransLine;
                                        USEDPOSTransLineTemp.INSERT;
                                    END;
                                UNTIL _POSTransLine.NEXT = 0;
                        END;
                    _PeriodicDiscountLine.Type::"Special Group":
                        IF _POSTransLine.FINDFIRST THEN
                            REPEAT
                                IF _ItemSpecialGroup.GET(_POSTransLine.Number, _PeriodicDiscountLine."No.") THEN
                                    IF NOT USEDPOSTransLineTemp.GET(_POSTransLine."Receipt No.", _POSTransLine."Line No.") THEN BEGIN
                                        OfferLineAmt += _POSTransLine."Discount Amount" + _POSTransLine.Amount;
                                        USEDPOSTransLineTemp := _POSTransLine;
                                        USEDPOSTransLineTemp.INSERT;
                                    END;
                            UNTIL _POSTransLine.NEXT = 0;
                    ELSE BEGIN
                        OfferLineAmt := TransAmt;
                        EXIT;
                    END;
                END;
            UNTIL _PeriodicDiscountLine.NEXT = 0;

        _POSTransLine.RESET;
        _POSTransLine.SETCURRENTKEY("Receipt No.", "Entry Type", "Entry Status");
        _POSTransLine.SETRANGE("Receipt No.", POSTrans."Receipt No.");
        _POSTransLine.SETRANGE("Entry Type", _POSTransLine."Entry Type"::Item);
        _POSTransLine.SETRANGE("Entry Status", _POSTransLine."Entry Status"::" ");
        _POSTransLine.SETRANGE("Benefit Item", TRUE);
        IF _POSTransLine.FINDSET THEN BEGIN
            BenefitAmount := 0;
            REPEAT
                BenefitAmount := BenefitAmount + _POSTransLine.Amount;
            UNTIL _POSTransLine.NEXT = 0;
            OfferLineAmt := OfferLineAmt - BenefitAmount;
        END;
    end;

    procedure CollectTransAddBenefits2(pReceiptNo: Code[20]; var pTransDiscBenefitEntry: Record "LSC Trans. Disc. Benefit Entry" temporary)
    var
        OffersTemp: Record "LSC Periodic Discount" temporary;
        PerDisc: Record "LSC Periodic Discount";
        PeriodicDiscBenefits: Record "LSC Periodic Discount Benefits";
        posTransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
        PosFunctions: Codeunit "LSC POS Functions";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        OfferNo: Code[20];
        LineNo: Integer;
        OfferCount: Integer;
        OfferType: Integer;
    begin
        LineNo := 0;
        posTransPerDisc.RESET;
        posTransPerDisc.SETRANGE("Receipt No.", pReceiptNo);
        posTransPerDisc.SETRANGE("Entry Status", posTransPerDisc."Entry Status"::" ");
        PosFunctions.PosTransDiscSetTableFilter(1, posTransPerDisc);
        if PosFunctions.PosTransDiscFindRec(1, '-', posTransPerDisc) then
            repeat
                OfferNo := '';
                case posTransPerDisc.DiscType OF
                    posTransPerDisc.DiscType::"Periodic Disc.":
                        begin
                            OfferType := posTransPerDisc."Periodic Disc. Type" + 1;
                            OfferNo := posTransPerDisc."Periodic Disc. Group";
                        end;
                    posTransPerDisc.DiscType::"Total Discount":
                        begin
                            OfferType := pTransDiscBenefitEntry."Offer Type"::"Total Discount";
                            OfferNo := posTransPerDisc."Offer No.";
                        end;
                end;
                if OfferNo <> '' then begin
                    if not OffersTemp.Get(OfferNo) then begin
                        if PerDisc.Get(OfferNo) then
                            //OfferCount := PosPriceUtil.PosTransOfferCount(pReceiptNo, posTransPerDisc.DiscType, OfferNo); BC22 Upgrade
                            PosTransOfferCount(pReceiptNo, posTransPerDisc.DiscType, OfferNo);//BC 22 Upgrade
                        PeriodicDiscBenefits.RESET;
                        PeriodicDiscBenefits.SetCurrentKey("Offer No.", "Step Amount", Type);
                        PeriodicDiscBenefits.SetRange(PeriodicDiscBenefits."Offer No.", OfferNo);
                        if posTransPerDisc.DiscType = posTransPerDisc.DiscType::"Total Discount" then
                            PeriodicDiscBenefits.SetRange("Step Amount", posTransPerDisc."Benefit Step Amount");
                        //PeriodicDiscBenefits.SETRANGE(Type, PeriodicDiscBenefits.Type::"Popup Message"); //BC Upgrade
                        PeriodicDiscBenefits.SetRange(PopUp, true); //BC Upgrade
                        if PeriodicDiscBenefits.FindSet() then
                            repeat
                                LineNo := LineNo + 1;
                                pTransDiscBenefitEntry.INIT;
                                pTransDiscBenefitEntry."Line No." := LineNo;
                                pTransDiscBenefitEntry."Offer Type" := OfferType;
                                pTransDiscBenefitEntry."Offer No." := OfferNo;
                                pTransDiscBenefitEntry."Offer Line No." := PeriodicDiscBenefits."Line No.";
                                pTransDiscBenefitEntry.Type := PeriodicDiscBenefits.Type;
                                pTransDiscBenefitEntry.PopUp := PeriodicDiscBenefits.PopUp;
                                pTransDiscBenefitEntry."No." := PeriodicDiscBenefits."No.";
                                pTransDiscBenefitEntry."Variant Code" := PeriodicDiscBenefits."Variant Code";
                                pTransDiscBenefitEntry.Description := PeriodicDiscBenefits.Description;
                                pTransDiscBenefitEntry."Value Type" := PeriodicDiscBenefits."Value Type";
                                pTransDiscBenefitEntry.Value := PeriodicDiscBenefits.Value;
                                pTransDiscBenefitEntry.Quantity := OfferCount;
                                pTransDiscBenefitEntry."Popup Message" := PeriodicDiscBenefits."Popup Message";
                                pTransDiscBenefitEntry.Insert();
                            until PeriodicDiscBenefits.Next() = 0;
                        OffersTemp.Init();
                        OffersTemp."No." := OfferNo;
                        OffersTemp.Insert();
                    end;
                end;
            until PosFunctions.PosTransDiscNextRec(1, 1, posTransPerDisc) = 0;
    end;

    procedure ProcessScannerData(pScanInput: Text): Text
    var
        GenSetup: Record "eCom_General Setup_NT";
        XMLDomMgt: Codeunit "LSC XML DOM Mgt.";
        lXmlQR: XmlDocument;
        RequireDecrypt: Boolean;
        DecryptedString: Text;
        EncryptedString: Text;
        lXMLQRCode: Text;
        Base64Err: Label 'Invalid Base64 Value';
        lNode: XmlNode;
    begin
        RequireDecrypt := false;
        if StrPos(pScanInput, '<mobiledevice>') > 0 then begin
            if GenSetup.Get() then
                if GenSetup."Decrypt Loyalty APP QR" then
                    RequireDecrypt := true;

            if not RequireDecrypt then
                RequireDecrypt := StrPos(pScanInput, '<contactid>') = 0;

            if not RequireDecrypt then
                exit(pScanInput);

            lXMLQRCode := pScanInput;

            lXmlQR := XmlDocument.Create();
            XMLDomMgt.LoadXMLDocumentFromText(lXMLQRCode, lXmlQR);
            if not lXmlQR.SelectSingleNode('mobiledevice', lNode) then
                exit;
            EncryptedString := XMLDomMgt.GetNodeInnerText(lNode);
            if EncryptedString <> '' then begin
                if not Decrypt(EncryptedString, DecryptedString) then
                    DecryptedString := Base64Err;
                if DecryptedString <> '' then
                    DecryptedString := '<mobiledevice>' + DecryptedString + '</mobiledevice>';
                exit(DecryptedString);
            end;
        end;
    end;

    [TryFunction]
    local procedure Decrypt(EncryptString: Text; var DecryptedString: Text)
    var
        ByteInputArray: DotNet DotNetArray_NT;
        ByteOutputArray: DotNet DotNetArray_NT;
        ByteType: DotNet DotNETType_NT;
        Convert: DotNet Convert;
        DotNetString: DotNet String;
        NETConvert: DotNet Convert;
        Rjm: DotNet "Cryptography.RijndaelManaged";
        UTF8Encoding: DotNet UTF8Encoding;
    begin
        if IsNull(Rjm) then
            Rjm := Rjm.Create();
        Rjm.KeySize := 128;
        Rjm.BlockSize := 128;
        Rjm."Key" := UTF8Encoding.UTF8.GetBytes('mDxRq9PZLGgXxTgS');
        Rjm.IV := UTF8Encoding.UTF8.GetBytes('StatefulWidget {');
        DotNetString := EncryptString;
        ByteInputArray := Convert.FromBase64String(DotNetString);
        ByteType := ByteType.GetType('System.Byte', FALSE);
        ByteInputArray := ByteInputArray.CreateInstance(ByteType, NETConvert.FromBase64String(DotNetString).Length);
        ByteInputArray := Convert.FromBase64String(DotNetString);
        ByteOutputArray := Rjm.CreateDecryptor().TransformFinalBlock(ByteInputArray, 0, ByteInputArray.Length);
        DecryptedString := UTF8Encoding.UTF8.GetString(ByteOutputArray);
    end;

    procedure LoadMemberInfoLocal(pCardNo: Text; VAR pErrorText: Text; var MembershipCardTemp: Record "LSC Membership Card" temporary; var MemberAccountTemp: Record "LSC Member Account" temporary; var MemberContactTemp: Record "LSC Member Contact" temporary; var MemberAttributeListTemp: Record "LSC Member Attribute List" temporary; var MemberClubTemp: Record "LSC Member Club" temporary; var MemberSchemeTemp: Record "LSC Member Scheme" temporary; var MemberMgtSetupTemp: Record "LSC Member Management Setup" temporary; var MemberPointSetupTemp: Record "LSC Member Point Setup" temporary; var MemberCouponBufferTemp: Record "LSC Member Coupon Buffer" temporary; var FBPWSBufferTemp: Record "LSC FBP WS Buffer" temporary): Boolean
    var
        MemberAccount: Record "LSC Member Account";
        MemberClub: Record "LSC Member Club";
        MemberContact: Record "LSC Member Contact";
        MemberMgtSetup: Record "LSC Member Management Setup";
        MemberPointSetup: Record "LSC Member Point Setup";
        MemberScheme: Record "LSC Member Scheme";
        MembershipCard: Record "LSC Membership Card";
        POSFuncProfile: Record "LSC POS Func. Profile";
        CouponManagement: Codeunit "LSC Coupon Management";
        FBPUtility: Codeunit "LSC FBP Utility";
        Globals: Codeunit "LSC POS Session";
        MemberAttributeMgt: Codeunit "LSC Member Attribute Mgmt";
        MemberCardMgt: Codeunit "LSC Member Card Management";
        PosFunc: Codeunit "LSC POS Functions";
        StoreNo_l: Code[10];
        StartingPoint: Decimal;
        CardNo: Text;
        lText101: Label '%1 %2 not found';
    begin
        //LoadMemberInfoLocal
        //Initialize; //BC Upgrade

        ClearMemberInfo(MembershipCardTemp
                    , MemberAccountTemp
                    , MemberContactTemp
                    , MemberAttributeListTemp
                    , MemberClubTemp
                    , MemberSchemeTemp
                    , MemberMgtSetupTemp
                    , MemberPointSetupTemp
                    , MemberCouponBufferTemp
                    , FBPWSBufferTemp
                    );//BC Upgrade

        //Get Membership Card
        if MemberCardMgt.GetMembershipCard(pCardNo, MembershipCard, pErrorText) then begin
            MembershipCardTemp.Init();
            MembershipCardTemp := MembershipCard;
            MembershipCardTemp.Insert();
        end else begin
            CardNo := FindMember(pCardNo);
            if CardNo <> '' then
                if MemberCardMgt.GetMembershipCard(CardNo, MembershipCard, pErrorText) then begin
                    MembershipCardTemp.Init();
                    MembershipCardTemp := MembershipCard;
                    MembershipCardTemp.Insert();
                end else begin
                    if pErrorText = '' then
                        pErrorText := StrSubstNo(lText101, MembershipCardTemp.TABLECAPTION, pCardNo);
                    exit(false);
                end;

            if CardNo = '' then //BC Upgrade. Card not found locally
                exit(false);
        end;

        //Get Member Account
        if MembershipCardTemp."Linked to Account" then begin
            MemberAccount.SetRange("No.", MembershipCardTemp."Account No.");
            IF MemberAccount.Find('-') then
                repeat
                    MemberAccountTemp.Init();
                    MemberAccountTemp := MemberAccount;
                    MemberAccountTemp.Insert();
                UNTIL MemberAccount.Next() = 0;
        end;

        //Get Member Contact
        if MembershipCardTemp."Linked to Account" then begin
            MemberContact.SetRange("Account No.", MembershipCardTemp."Account No.");
            MemberContact.SetRange("Contact No.", MembershipCardTemp."Contact No.");
            if MemberContact.Find('-') then
                repeat
                    MemberContactTemp.Init();
                    MemberContactTemp := MemberContact;
                    MemberContactTemp.Insert();
                until MemberContact.Next() = 0;
        end;

        //Get Member Attribute List
        //MemberAttributeMgt.GetAllAttributes(pCardNo,MemberAttributeListTemp,TRUE);       
        //BC Upgrade MemberAttributeMgt.GetAllAttributes(MembershipCardTemp."Card No.", MemberAttributeListTemp, TRUE); // NT

        //Get Member Club
        if MemberClub.Get(MembershipCardTemp."Club Code") then begin
            MemberClubTemp.Init();
            MemberClubTemp := MemberClub;
            MemberClubTemp.Insert();
        end;
        //Get Member Scheme
        if MemberScheme.Get(MembershipCardTemp."Scheme Code") then begin
            MemberSchemeTemp.Init();
            MemberSchemeTemp := MemberScheme;
            MemberSchemeTemp.Insert();
        end;

        //Get Member Management Setup
        if MemberMgtSetup.Get() then begin
            MemberMgtSetupTemp.Init();
            MemberMgtSetupTemp := MemberMgtSetup;
            MemberMgtSetupTemp.Insert();
        end;
        //Get Member Point Setup
        MemberPointSetup.Reset();
        MemberPointSetup.SetRange("Club Code", MembershipCardTemp."Club Code");
        if MemberPointSetup.FindSet() then
            repeat
                MemberPointSetupTemp.Init();
                MemberPointSetupTemp := MemberPointSetup;
                MemberPointSetupTemp.Insert();
            until MemberPointSetup.Next() = 0;

        //BC Upgrade Start

        //Starting Point & Attributes from WS ODATA Call
        if GetMemberInfoForPos(MembershipCardTemp."Card No.", StartingPoint, MemberAttributeListTemp) then begin
            if StartingPoint <> 0 then begin //Not Found or Invalid Card
                MemberAccountTemp.TotalRemainingPointsInt := StartingPoint;
                MemberAccountTemp.Modify();
            end;
        end else
            MemberAttributeMgt.GetAllAttributes(MembershipCardTemp."Card No.", MemberAttributeListTemp); //Check Local if WS call fails

        StoreNo_l := Globals.StoreNo();
        CouponManagement.GetMemberCouponList(MemberCouponBufferTemp, MemberAccount."No.", StoreNo_l, StoreNo_l <> '');
        FBPUtility.GetFBPStatus(FBPWSBufferTemp, MemberAccount."No.", StoreNo_l);

        MembershipCardTemp.FindFirst;
        if MemberClubTemp.FindFirst then;
        if MemberSchemeTemp.FindFirst then;
        if MemberAccountTemp.FindFirst then;
        if MemberContactTemp.FindFirst then;
        if MemberMgtSetupTemp.FindFirst then;

        //BC Upgrade End
        exit(true);
    end;

    local procedure FindMember(Value: Text): Text
    var
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
    begin
        MemberContact.Reset();
        MemberContact.SetCurrentKey("Phone No.");
        MemberContact.SetFilter("Phone No.", Value);
        if not MemberContact.FindFirst() then begin
            MemberContact.Reset();
            MemberContact.SetCurrentKey("Mobile Phone No.");
            MemberContact.SetFilter("Mobile Phone No.", Value);
            if not MemberContact.FindFirst() then begin
                MemberContact.Reset();
                MemberContact.SetCurrentKey("Search E-Mail");
                MemberContact.SetFilter("Search E-Mail", UpperCase(Value));
                if not MemberContact.FindFirst() then
                    if StrLen(Value) = 13 then
                        exit(CopyStr(Value, 6, 7));
            end;
        end;

        MembershipCard.SetCurrentKey("Account No.", "Contact No.", Status);
        MembershipCard.SetRange("Account No.", MemberContact."Account No.");
        MembershipCard.SetRange("Contact No.", MemberContact."Contact No.");
        MembershipCard.SetRange(Status, MembershipCard.Status::Active);
        if not MembershipCard.FindFirst() then
            exit('');
        exit(MembershipCard."Card No.");
    end;

    local procedure ClearMemberInfo(var MembershipCardTemp: Record "LSC Membership Card" temporary; var MemberAccountTemp: Record "LSC Member Account" temporary; var MemberContactTemp: Record "LSC Member Contact" temporary; var MemberAttributeListTemp: Record "LSC Member Attribute List" temporary; var MemberClubTemp: Record "LSC Member Club" temporary; var MemberSchemeTemp: Record "LSC Member Scheme" temporary; var MemberMgtSetupTemp: Record "LSC Member Management Setup" temporary; var MemberPointSetupTemp: Record "LSC Member Point Setup" temporary; var MemberCouponBufferTemp: Record "LSC Member Coupon Buffer" temporary; var FBPWSBufferTemp: Record "LSC FBP WS Buffer" temporary)
    begin
        //ClearMemberInfo
        Clear(MembershipCardTemp);
        MembershipCardTemp.Reset();
        MembershipCardTemp.DeleteAll();

        Clear(MemberAccountTemp);
        MemberAccountTemp.Reset();
        MemberAccountTemp.DELETEALL;

        Clear(MemberContactTemp);
        MemberContactTemp.Reset();
        MemberContactTemp.DeleteAll();

        MemberAttributeListTemp.Reset();
        MemberAttributeListTemp.DeleteAll();

        Clear(MemberClubTemp);
        MemberClubTemp.Reset();
        MemberClubTemp.DeleteAll();

        Clear(MemberSchemeTemp);
        MemberSchemeTemp.Reset();
        MemberSchemeTemp.DeleteAll();

        MemberMgtSetupTemp.Reset();
        MemberMgtSetupTemp.DeleteAll();

        MemberPointSetupTemp.Reset();
        MemberPointSetupTemp.DeleteAll();

        FBPWSBufferTemp.DeleteAll();
        MemberCouponBufferTemp.DeleteAll();
    end;

    procedure GetMemberStartingPoints(cardNo: Text[100]; var StartingPoint: Decimal) AuthenticationStatus: Boolean;
    var
        ODataRequests: Record "Pos_OData Requests_NT";
        ConvertToBase64: Codeunit "Base64 Convert";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JsonObj: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        Index: Integer;
        AuthText: Text;
        JsonBody: Text;
        JsonResponseTxt: Text;
        URI: Text;
        WebResponseTxt: Label 'The web service returned an error message:\Status code: %1\Description: %2\', Comment = '%1 = ResponseMessage.HttpStatusCode() %2 = ResponseMessage.ReasonPhrase()';
    begin
        RequestMessage.Method := Format('POST');
        if not ODataRequests.Get('GET_MEMBER_STARTING_POINTS') then
            exit(false);
        URI := ODataRequests."OData Base Url"
               + ':'
               + ODataRequests."OData Services Port"
               + '/'
               + ODataRequests."Server Instance Name"
               + '/'
               + ODataRequests."OData Version Text"
               + '/'
               + ODataRequests."Web Service Name"
               + '_'
               + ODataRequests.Operation
               + '?company=' + ODataRequests."Company Name";
        if not RequestMessage.SetRequestUri(URI) then
            exit(false);
        AuthText := StrSubstNo('%1:%2', ODataRequests."User Name", ODataRequests."Web Service Access Key");
        if not Client.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Basic %1', ConvertToBase64.ToBase64(AuthText))) then
            exit(false);
        if not JsonObj.Add('cardNo', cardNo) then
            exit(false);
        if not JsonObj.WriteTo(JsonBody) then
            exit(false);
        Content.WriteFrom(jsonbody);
        Content.GetHeaders(Headers);
        if not Headers.Remove('Content-Type') then
            exit(false);
        if not Headers.Add('Content-Type', 'application/json') then
            exit(false);
        RequestMessage.Content := Content;

        if ODataRequests."Time Out" <> 0 then
            Client.Timeout := ODataRequests."Time Out";

        if not Client.Send(RequestMessage, ResponseMessage) then
            exit(false);
        if not ResponseMessage.IsSuccessStatusCode() then begin
            AuthenticationStatus := false;
            Error(WebResponseTxt, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());
        end else begin
            AuthenticationStatus := true;
            Clear(JsonResponseTxt);
            if not ResponseMessage.Content().ReadAs(JsonResponseTxt) then
                exit(false);
            if not JsonObj.ReadFrom(JsonResponseTxt) then begin
                Message('Invalid Response, expected a JSON object as root object');
                exit(false);
            end;
            if not JsonObj.Get('value', JsonToken) then
                exit(false);
            StartingPoint := JsonToken.AsValue().AsDecimal();
        end;
        exit(AuthenticationStatus);
    end;

    procedure GetMemberInfoForPos(cardNo: Text[100]; var StartingPoint: Decimal; var MemberAttributeListTemp: Record "LSC Member Attribute List" temporary) AuthenticationStatus: Boolean;
    var
        ODataRequests: Record "Pos_OData Requests_NT";
        ConvertToBase64: Codeunit "Base64 Convert";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        Index: Integer;
        AuthText: Text;
        JsonBody: Text;
        JsonResponseTxt: Text;
        URI: Text;
        WebResponseTxt: Label 'The web service returned an error message:\Status code: %1\Description: %2\', Comment = '%1 = ResponseMessage.HttpStatusCode() %2 = ResponseMessage.ReasonPhrase()';
    begin
        RequestMessage.Method := Format('POST');
        if not ODataRequests.Get('GET_MEMBER_INFO_FOR_POS') then
            exit(false);
        URI := ODataRequests."OData Base Url"
               + ':'
               + ODataRequests."OData Services Port"
               + '/'
               + ODataRequests."Server Instance Name"
               + '/'
               + ODataRequests."OData Version Text"
               + '/'
               + ODataRequests."Web Service Name"
               + '_'
               + ODataRequests.Operation
               + '?company=' + ODataRequests."Company Name";
        if not RequestMessage.SetRequestUri(URI) then
            exit(false);
        AuthText := StrSubstNo('%1:%2', ODataRequests."User Name", ODataRequests."Web Service Access Key");
        if not Client.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Basic %1', ConvertToBase64.ToBase64(AuthText))) then
            exit(false);
        if not JsonObj.Add('cardNo', cardNo) then
            exit(false);
        if not JsonObj.WriteTo(JsonBody) then
            exit(false);
        Content.WriteFrom(jsonbody);
        Content.GetHeaders(Headers);
        if not Headers.Remove('Content-Type') then
            exit(false);
        if not Headers.Add('Content-Type', 'application/json') then
            exit(false);
        RequestMessage.Content := Content;

        if ODataRequests."Time Out" <> 0 then
            Client.Timeout := ODataRequests."Time Out";

        if not Client.Send(RequestMessage, ResponseMessage) then
            exit(false);
        if not ResponseMessage.IsSuccessStatusCode() then
            AuthenticationStatus := false
        //Error(WebResponseTxt, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());
        else begin
            AuthenticationStatus := true;
            Clear(JsonResponseTxt);
            if not ResponseMessage.Content().ReadAs(JsonResponseTxt) then
                exit(false);
            if not JsonObj.ReadFrom(JsonResponseTxt) then begin
                Message('Invalid Response, expected a JSON object as root object');
                exit(false);
            end;
            if not JsonObj.Get('value', JsonToken) then
                exit(false);
            JsonResponseTxt := JsonToken.AsValue().AsText();
            if JsonResponseTxt = '' then
                exit(false);
            LoadMemberInfoData(JsonResponseTxt, StartingPoint, MemberAttributeListTemp);
            //Message(JsonResponseTxt);
            //StartingPoint := JsonToken.AsValue().AsBigInteger();
        end;
        exit(AuthenticationStatus);
    end;

    local procedure LoadMemberInfoData(JsonTxt: Text; var StartingPoint: Decimal; var MemberAttributeListTemp: Record "LSC Member Attribute List" temporary): Boolean
    var
        JsonObj: JsonObject;
        JsonArray: JsonArray;
        JsonToken2: JsonToken;
        JsonToken: JsonToken;
    begin
        MemberAttributeListTemp.Reset();
        MemberAttributeListTemp.DeleteAll();
        if not JsonObj.ReadFrom(JsonTxt) then
            exit(false);

        if JsonObj.Get('StartingPoints', JsonToken) then
            StartingPoint := JsonToken.AsValue().AsDecimal();

        if JsonObj.Get('MemberAttributeList', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken2 in JsonArray do begin
                JsonObj := JsonToken2.AsObject();
                MemberAttributeListTemp.Init();
                if JsonObj.Get('Type', JsonToken) then begin
                    case JsonToken.AsValue().AsText() of
                        'Attribute':
                            MemberAttributeListTemp.Type := MemberAttributeListTemp.Type::Attribute;
                        'Discount Limitation':
                            MemberAttributeListTemp.Type := MemberAttributeListTemp.Type::"Discount Limitation";
                        'Action':
                            MemberAttributeListTemp.Type := MemberAttributeListTemp.Type::Action;
                    end;

                end;
                if JsonObj.Get('Code', JsonToken) then
                    MemberAttributeListTemp.Code := JsonToken.AsValue().AsCode();
                if JsonObj.Get('Description', JsonToken) then
                    MemberAttributeListTemp.Description := JsonToken.AsValue().AsText();
                if JsonObj.Get('Value', JsonToken) then
                    MemberAttributeListTemp.Value := JsonToken.AsValue().AsText();
                if JsonObj.Get('Action Type', JsonToken) then begin
                    case JsonToken.AsValue().AsText() of
                        'Message':
                            MemberAttributeListTemp."Action Type" := MemberAttributeListTemp."Action Type"::Message;
                        'Text On Receipt':
                            MemberAttributeListTemp."Action Type" := MemberAttributeListTemp."Action Type"::"Text On Receipt";
                    end;
                end;
                if JsonObj.Get('Limitation Type', JsonToken) then begin
                    case JsonToken.AsValue().AsText() of
                        'Discount Amount':
                            MemberAttributeListTemp."Limitation Type" := MemberAttributeListTemp."Limitation Type"::"Discount Amount";
                        'No. of Times Triggered':
                            MemberAttributeListTemp."Limitation Type" := MemberAttributeListTemp."Limitation Type"::"No. of Times Triggered";
                        'None':
                            MemberAttributeListTemp."Limitation Type" := MemberAttributeListTemp."Limitation Type"::None;
                    end;
                end;
                if JsonObj.Get('Attribute Type', JsonToken) then begin
                    case JsonToken.AsValue().AsText() of
                        'Boolean':
                            MemberAttributeListTemp."Attribute Type" := MemberAttributeListTemp."Attribute Type"::Boolean;
                        'Date':
                            MemberAttributeListTemp."Attribute Type" := MemberAttributeListTemp."Attribute Type"::Date;
                        'Decimal':
                            MemberAttributeListTemp."Attribute Type" := MemberAttributeListTemp."Attribute Type"::Decimal;
                        'Integer':
                            MemberAttributeListTemp."Attribute Type" := MemberAttributeListTemp."Attribute Type"::Integer;
                        'Text':
                            MemberAttributeListTemp."Attribute Type" := MemberAttributeListTemp."Attribute Type"::Text;
                    end;
                end;
                MemberAttributeListTemp.Insert();
            end;
        end;
    end;

    procedure GetMemberAccountPointBalance(REC: Record "LSC POS Transaction"): Text
    begin
        if REC."Member Card No." <> '' then
            exit(Format(REC."Starting Point Balance"))
        else
            exit('');
    end;

    // procedure UpdOffer(var MmHdr: Record "LSC Periodic Discount"; var MmLine: Record "LSC Periodic Discount Line"; ItemNo: Code[20]; Qty: Decimal; var TmpMixMatchNeededLine: Record "LSC Mix & Match Line Groups" temporary; var Lines: Integer; var UsedCurrLineQty: Decimal
    // ; var MmMembTmp: Codeunit "LSC POS Price Functions"; var MmTmp: Codeunit "LSC POS Price Functions";
    // var MmOfferList: Codeunit "LSC POS Price Functions"; var DiffList: array[250] of Integer; var LineList: array[250] of Integer;
    // var LastItemUpd: Code[20]; var DiffCount: Integer): Decimal
    // var
    //     ItmTmp: Code[20];
    //     Rest: Decimal;
    //     UseQty: Decimal;
    //     PrTmp: Decimal;
    //     QtyTmp: Decimal;
    //     OldQty: Decimal;
    //     N: Integer;
    //     LnTmp: Integer;
    //     I: Integer;
    //     LineCount: Integer;
    //     Done: Boolean;
    // //GLOBAL VARIABLES of the function added as input parameter so as to keep of same instance
    // //MmMembTmp: Codeunit "LSC POS Price Functions";
    // //MmTmp: Codeunit "LSC POS Price Functions";
    // //MmOfferList: Codeunit "LSC POS Price Functions";
    // //DiffList: array[250] of Integer;
    // //LineList: array[250] of Integer;
    // //LastItemUpd: Code[20];
    // //DiffCount: Integer;
    // begin
    //     Lines := 0;
    //     UsedCurrLineQty := 0;

    //     if not TmpMixMatchNeededLine.Get(MmLine."Offer No.", MmLine."Line Group") then
    //         exit(0);

    //     if TmpMixMatchNeededLine."Line Group Type" = TmpMixMatchNeededLine."Line Group Type"::Range then begin
    //         if (TmpMixMatchNeededLine."Value 1" = 0) and (TmpMixMatchNeededLine."Value 2" = 0) and (Qty > 0) then
    //             exit(0);
    //     end else
    //         if (TmpMixMatchNeededLine."Value 1" = 0) and (Qty > 0) then
    //             exit(0);

    //     LineCount := 0;
    //     MmTmp.ResetList;
    //     N := MmMembTmp.CountList;
    //     while N > 0 do begin
    //         MmMembTmp.GetIndexList(N, LnTmp, PrTmp, QtyTmp, ItmTmp);
    //         if ItmTmp = ItemNo then begin
    //             OldQty := OldQty + QtyTmp;
    //             MmTmp.AddToList(LnTmp, PrTmp, QtyTmp, ItmTmp);
    //             LineCount := LineCount + 1;
    //             LineList[LineCount] := N;
    //         end;
    //         N := N - 1;
    //     end;
    //     UseQty := Qty + OldQty;
    //     LastItemUpd := ItemNo;

    //     if UseQty < MmLine."No. of Items Needed" + mmLine."Offset for No. of Items" then //NT
    //         exit(0);

    //     if TmpMixMatchNeededLine.Get(MmLine."Offer No.", MmLine."Line Group") and (TmpMixMatchNeededLine."Value 1" <> -1) then begin
    //         Rest := UseQty;
    //         Done := false;
    //         if TmpMixMatchNeededLine."Line Group Type" = TmpMixMatchNeededLine."Line Group Type"::Range then begin
    //             if (TmpMixMatchNeededLine."Value 1" <= 0) and (TmpMixMatchNeededLine."Value 2" <= 0) then
    //                 Done := true;
    //         end else
    //             if TmpMixMatchNeededLine."Value 1" <= 0 then
    //                 Done := true;

    //         while (Rest > 0) and (not Done) do begin
    //             if DiffListOK(MmHdr, MmLine."Line No.", DiffCount, DiffList, LastItemUpd) and ((Rest - (MmLine."No. of Items Needed" + mmLine."Offset for No. of Items")) >= 0) then begin //NT
    //                 Rest := Rest - (MmLine."No. of Items Needed" + mmLine."Offset for No. of Items");//NT
    //                 if TmpMixMatchNeededLine."Line Group Type" = TmpMixMatchNeededLine."Line Group Type"::Range then begin
    //                     TmpMixMatchNeededLine."Value 3" := TmpMixMatchNeededLine."Value 3" - 1;
    //                     if TmpMixMatchNeededLine."Value 1" <= 0 then begin
    //                         if Rest <= 0 then
    //                             Done := true;
    //                         TmpMixMatchNeededLine."Value 2" := TmpMixMatchNeededLine."Value 2" - 1;
    //                         if TmpMixMatchNeededLine."Value 2" <= 0 then
    //                             Done := true;
    //                     end
    //                     else begin
    //                         TmpMixMatchNeededLine."Value 1" := TmpMixMatchNeededLine."Value 1" - 1;
    //                         TmpMixMatchNeededLine."Value 2" := TmpMixMatchNeededLine."Value 2" - 1;
    //                         if (TmpMixMatchNeededLine."Value 1" <= 0) and (TmpMixMatchNeededLine."Value 2" <= 0) then
    //                             Done := true;
    //                     end;
    //                 end
    //                 else begin
    //                     TmpMixMatchNeededLine."Value 1" := TmpMixMatchNeededLine."Value 1" - 1;
    //                     if TmpMixMatchNeededLine."Value 1" <= 0 then
    //                         Done := true;
    //                 end;
    //                 TmpMixMatchNeededLine.Modify;
    //                 Lines := Lines + 1;
    //             end else
    //                 Done := true;
    //         end;
    //     end else
    //         if not DiffListOK(MmHdr, MmLine."Line No.", DiffCount, DiffList, LastItemUpd) then
    //             exit(0)
    //         else
    //             exit(0);

    //     if Lines > 0 then begin
    //         N := MmTmp.CountList;
    //         for I := 1 to N do begin
    //             MmTmp.GetIndexList(I, LnTmp, PrTmp, QtyTmp, ItmTmp);
    //             MmOfferList.AddToList(LnTmp, PrTmp, QtyTmp, ItmTmp);
    //         end;
    //         for I := 1 to LineCount do
    //             MmMembTmp.DeleteIndexList(LineList[I]);
    //     end;

    //     if (Rest = 0) or (Rest = UseQty) then
    //         LastItemUpd := '';
    //     UseQty := UseQty - Rest;
    //     UsedCurrLineQty := UseQty - OldQty;
    //     exit(UseQty);
    // end;

    // procedure DiffListOK(var mmHdr: Record "LSC Periodic Discount"; lineNo: Integer; var DiffCount: Integer
    //  ; var DiffList: array[250] of Integer; var LastItemUpd: Code[20]): Boolean
    // var
    //     i: Integer;
    // begin
    //     if mmHdr."Same/Diff. M&M Lines" = mmHdr."Same/Diff. M&M Lines"::"Different M&M Lines" then begin
    //         for i := 1 to DiffCount do
    //             if DiffList[i] = lineNo then
    //                 exit(false);
    //         DiffCount := DiffCount + 1;
    //         DiffList[DiffCount] := lineNo;
    //         LastItemUpd := '';
    //     end;

    //     exit(true);
    // end;

    procedure IsWeightItem(POSTransLine_p: Record "LSC POS Trans. Line"): Boolean
    begin
        if POSTransLine_p."Scale Item" then
            exit(true);
        if POSTransLine_p."Quantity in Barcode" then
            //exit(true);//BC Changing Base Code As for Qty in Barcode it was taking Qty as 1 and not triggering Mix&Match
            exit(false);//BC Upgrade
        exit(false);
    end;
    //==========================TEST TO BE REMOVED==========
    procedure UpdOffer(var MmHdr: Record "LSC Periodic Discount"; var MmLine: Record "LSC Periodic Discount Line"; ItemNo: Code[20]; Qty: Decimal; var TmpMixMatchNeededLine: Record "LSC Mix & Match Line Groups" temporary; var Lines: Integer; var UsedCurrLineQty: Decimal): Decimal
    var
        Done: Boolean;
        ItmTmp: Code[20];
        OldQty: Decimal;
        PrTmp: Decimal;
        QtyTmp: Decimal;
        Rest: Decimal;
        UseQty: Decimal;
        I: Integer;
        LineCount: Integer;
        LnTmp: Integer;
        N: Integer;
    begin
        //GLOBAL VARIABLES of the function added as input parameter so as to keep of same instance
        //MmMembTmp: Codeunit "LSC POS Price Functions";
        //MmTmp: Codeunit "LSC POS Price Functions";
        //MmOfferList: Codeunit "LSC POS Price Functions";
        //DiffList: array[250] of Integer;
        //LineList: array[250] of Integer;
        //LastItemUpd: Code[20];
        //DiffCount: Integer;
        Lines := 0;
        UsedCurrLineQty := 0;

        if not TmpMixMatchNeededLine.Get(MmLine."Offer No.", MmLine."Line Group") then
            exit(0);

        if TmpMixMatchNeededLine."Line Group Type" = TmpMixMatchNeededLine."Line Group Type"::Range then begin
            if (TmpMixMatchNeededLine."Value 1" = 0) and (TmpMixMatchNeededLine."Value 2" = 0) and (Qty > 0) then
                exit(0);
        end else
            if (TmpMixMatchNeededLine."Value 1" = 0) and (Qty > 0) then
                exit(0);

        LineCount := 0;
        MmTmp.ResetList;
        N := MmMembTmp.CountList;
        while N > 0 do begin
            MmMembTmp.GetIndexList(N, LnTmp, PrTmp, QtyTmp, ItmTmp);
            if ItmTmp = ItemNo then begin
                OldQty := OldQty + QtyTmp;
                MmTmp.AddToList(LnTmp, PrTmp, QtyTmp, ItmTmp);
                LineCount := LineCount + 1;
                LineList[LineCount] := N;
            end;
            N := N - 1;
        end;
        UseQty := Qty + OldQty;
        LastItemUpd := ItemNo;

        if UseQty < MmLine."No. of Items Needed" + mmLine."Offset for No. of Items" then //NT
            exit(0);

        if TmpMixMatchNeededLine.Get(MmLine."Offer No.", MmLine."Line Group") and (TmpMixMatchNeededLine."Value 1" <> -1) then begin
            Rest := UseQty;
            Done := false;
            if TmpMixMatchNeededLine."Line Group Type" = TmpMixMatchNeededLine."Line Group Type"::Range then begin
                if (TmpMixMatchNeededLine."Value 1" <= 0) and (TmpMixMatchNeededLine."Value 2" <= 0) then
                    Done := true;
            end else
                if TmpMixMatchNeededLine."Value 1" <= 0 then
                    Done := true;

            while (Rest > 0) and (not Done) do begin
                if DiffListOK(MmHdr, MmLine."Line No.", DiffCount, DiffList, LastItemUpd) and ((Rest - (MmLine."No. of Items Needed" + mmLine."Offset for No. of Items")) >= 0) then begin //NT
                    Rest := Rest - (MmLine."No. of Items Needed" + mmLine."Offset for No. of Items");//NT
                    if TmpMixMatchNeededLine."Line Group Type" = TmpMixMatchNeededLine."Line Group Type"::Range then begin
                        TmpMixMatchNeededLine."Value 3" := TmpMixMatchNeededLine."Value 3" - 1;
                        if TmpMixMatchNeededLine."Value 1" <= 0 then begin
                            if Rest <= 0 then
                                Done := true;
                            TmpMixMatchNeededLine."Value 2" := TmpMixMatchNeededLine."Value 2" - 1;
                            if TmpMixMatchNeededLine."Value 2" <= 0 then
                                Done := true;
                        end
                        else begin
                            TmpMixMatchNeededLine."Value 1" := TmpMixMatchNeededLine."Value 1" - 1;
                            TmpMixMatchNeededLine."Value 2" := TmpMixMatchNeededLine."Value 2" - 1;
                            if (TmpMixMatchNeededLine."Value 1" <= 0) and (TmpMixMatchNeededLine."Value 2" <= 0) then
                                Done := true;
                        end;
                    end
                    else begin
                        TmpMixMatchNeededLine."Value 1" := TmpMixMatchNeededLine."Value 1" - 1;
                        if TmpMixMatchNeededLine."Value 1" <= 0 then
                            Done := true;
                    end;
                    TmpMixMatchNeededLine.Modify;
                    Lines := Lines + 1;
                end else
                    Done := true;
            end;
        end else
            if not DiffListOK(MmHdr, MmLine."Line No.", DiffCount, DiffList, LastItemUpd) then
                exit(0)
            else
                exit(0);

        if Lines > 0 then begin
            N := MmTmp.CountList;
            for I := 1 to N do begin
                MmTmp.GetIndexList(I, LnTmp, PrTmp, QtyTmp, ItmTmp);
                MmOfferList.AddToList(LnTmp, PrTmp, QtyTmp, ItmTmp);
            end;
            for I := 1 to LineCount do
                MmMembTmp.DeleteIndexList(LineList[I]);
        end;

        if (Rest = 0) or (Rest = UseQty) then
            LastItemUpd := '';
        UseQty := UseQty - Rest;
        UsedCurrLineQty := UseQty - OldQty;
        exit(UseQty);
    end;

    procedure DiffListOK(var mmHdr: Record "LSC Periodic Discount"; lineNo: Integer; var DiffCount: Integer
     ; var DiffList: array[250] of Integer; var LastItemUpd: Code[20]): Boolean
    var
        i: Integer;
    begin
        if mmHdr."Same/Diff. M&M Lines" = mmHdr."Same/Diff. M&M Lines"::"Different M&M Lines" then begin
            for i := 1 to DiffCount do
                if DiffList[i] = lineNo then
                    exit(false);
            DiffCount := DiffCount + 1;
            DiffList[DiffCount] := lineNo;
            LastItemUpd := '';
        end;

        exit(true);
    end;

    procedure EmailCopy(Var Trans: Record "LSC Transaction Header"; pEmail: Text[250]; var ErrorMsg: Text[150]): Boolean
    var
        PosTerminal: Record "LSC POS Terminal";
        Store: Record "LSC Store";
        TmpTrans: Record "LSC Transaction Header" temporary;
        Globals: Codeunit "LSC POS Session";
        POSCtrlInterface: codeunit "LSC POS Control Interface";
        PosGenUtility: Codeunit "Pos_General Utility_NT";
        PrintUtil: Codeunit "LSC POS Print Utility";
        RetVal: Boolean;
        Phase: Integer;
        "E-Receipt": Text;
        Text001: Label 'EMail Missing';
    begin
        RetVal := false;
        "E-Receipt" := 'E-Receipt ';
        if pEmail = '' then begin
            ErrorMsg := Text001;
            RetVal := false;
            exit(RetVal);
        end;

        Phase := 0;
        Globals.SetStore(Trans."Store No.");
        Globals.SetTerminal(Trans."POS Terminal No.");
        Store.Get(Trans."Store No.");
        Globals.SetHardwareProfile(Store."Hardware Profile");
        TmpTrans.Init();
        TmpTrans.TransferFields(Trans);
        TmpTrans.Insert();
        PrintUtil.Init();
        POSCtrlInterface.SetClientType(1);//UNIT TEST.. INITIATE TO SEND MAIL
        PrintUtil.SetWebPrinting(true, pEmail, "E-Receipt" + ' - ' + TmpTrans."Receipt No.");
        PosGenUtility.SetMailSubject("E-Receipt" + ' - ' + TmpTrans."Receipt No.");
        if PrintUtil.PrintSlips(TmpTrans, Phase) then
            RetVal := true;
        PrintUtil.SetWebPrinting(false, '', '');
        exit(RetVal);
    end;

    procedure SendEmail_Copy(var MailRecipients: Text; var PrintBuffer: Record "LSC POS Print Buffer"): Boolean
    var
        CompanyInformation: Record "Company Information";
        EmailAccount: Record "Email Account";
        EmailItem: Record "Email Item" temporary;
        POSTerminal: Record "LSC POS Terminal";
        EmailScenario: Codeunit "Email Scenario";
        Globals: Codeunit "LSC POS Session";
        MailManagement: Codeunit "Mail Management";
        POSFunctions: Codeunit "LSC POS Functions";
        PosGenUtility: Codeunit "Pos_General Utility_NT";
        PosReceipt: Report "POS_OPOS Emulation Report_NT";
        VarInStream: InStream;
        OutStr: OutStream;
        ReportNo: Integer;
        BodyBuffer: Text;
        EmailAddressesErrorText: Text;
        LastErrorText: Text;
        MailSubject: Text;
        CannotSendMailErr: Label 'You cannot send the email.\Verify that the email settings are correct.';
    begin

        if MailManagement.IsEnabled() then begin
            Clear(PosReceipt);
            PosGenUtility.GetMailSubject(MailSubject);
            PrintBuffer.Reset();
            PosReceipt.SetLine(PrintBuffer);
            ReportNo := Report::"POS_OPOS Emulation Report_NT";
            PosReceipt.UseRequestPage(false);

            EmailItem.Init();
            EmailItem.Body.CreateOutStream(OutStr);
            PosReceipt.SaveAs('', ReportFormat::Pdf, OutStr);
            BodyBuffer := '<pre style="font-family:Courier New">';
            PrintBuffer.SetRange(LineType, PrintBuffer.LineType::PrintLine);
            if PrintBuffer.FindSet() then
                repeat
                    if PrintBuffer.FontType > 0 then
                        BodyBuffer += GetWebTextLine(PrintBuffer.Text, PrintBuffer.FontType)
                    else
                        BodyBuffer += PrintBuffer.Text + '<br/>';
                until PrintBuffer.Next = 0;
            BodyBuffer := BodyBuffer + '</pre>';
            CompanyInformation.Get;
            POSTerminal.Get(Globals.TerminalNo);
            EmailItem."From Name" := CompanyInformation.Name;
            EmailScenario.GetEmailAccount("Email Scenario"::Default, EmailAccount);
            EmailItem."From Address" := EmailAccount."Email Address";
            EmailItem."Send to" := MailRecipients;
            EmailItem."Send BCC" := POSTerminal."BCC E-Mail Address";
            EmailItem.Subject := MailSubject;
            EmailItem.Body.CreateInStream(VarInStream);
            EmailItem.AddAttachment(VarInStream, MailSubject + '.pdf');
            EmailItem."Plaintext Formatted" := false;
            EmailItem."Message Type" := EmailItem."Message Type"::"From Email Body Template";
            EmailItem.SetBodyText(BodyBuffer);
            MailManagement.InitializeFrom(true, true);

            if not POSFunctions.ValidateEmailAddresses(EmailItem, EmailAddressesErrorText) then begin
                LastErrorText := EmailAddressesErrorText;
                exit(false);
            end;

            if not MailManagement.Send(EmailItem, "Email Scenario"::Notification) then begin
                LastErrorText := CannotSendMailErr;
                exit(false);
            end;
            exit(true);
        end;
    end;

    procedure GetWebTextLine(var pText: Text; pFontType: Integer): Text
    var
        ActiveFontType: Option Normal,Bold,Wide,High,WideAndHight,Italic;
    begin
        if pFontType = ActiveFontType::Bold then
            exit('<b>' + pText + '</b><br/>')
        else
            if pFontType = ActiveFontType::Italic then
                exit('<i>' + pText + '</i><br/>')
            else
                exit(pText + '<br/>'); //Finish Wide and High ?
    end;

    // procedure GetDataEntryType(Input: Text): Code[20]
    // var
    //     POSDataEntryType: Record "LSC POS Data Entry Type";
    //     Prefix: Code[10];
    //     i: Integer;
    //     DotNetArray: DotNet Array;
    //     DotNetString1: DotNet String;
    //     DotNetString2: DotNet String;
    // begin
    //     POSDataEntryType.SetFilter(Prefix, '<>%1', '');
    //     DotNetString2 := ';';
    //     if POSDataEntryType.FindSet() then begin
    //         repeat
    //             DotNetString1 := POSDataEntryType.Prefix;
    //             if not DotNetString1.IsNullOrWhiteSpace(DotNetString1) then begin
    //                 DotNetArray := DotNetString1.Split(DotNetString2.ToCharArray());
    //                 for i := 1 TO DotNetArray.Length do begin
    //                     Prefix := DotNetArray.GetValue(i - 1);
    //                     if CopyStr(Input, 1, StrLen(Prefix)) = Prefix then
    //                         exit(POSDataEntryType.Code);
    //                 end;
    //             end;
    //         until POSDataEntryType.Next() = 0;
    //     end;
    //     exit('');
    // end;

    procedure InputIsGiftVoucher(EntryType: Code[20]; VAR Amount: Decimal; VAR ErrorMSG: Text; var CurrInput: Text; STATE_PAYMENT: Code[10]): Boolean
    var
        BarcodeMask: Record "LSC Barcode Mask";//BC
        DataEntry2: Record "LSC POS Data Entry";//BC
        DataEntry2Modify: Record "LSC POS Data Entry";//BC
        DataEntry: Record "LSC POS Data Entry";
        LocalDataEntry: Record "LSC POS Data Entry";//BC
        PosDataEntryType: Record "LSC POS Data Entry Type";//BC
        PosFunc: Codeunit "LSC POS Functions";//BC
        PosInfoCodeUtils: Codeunit "LSC POS Infocode Utility";
        TSUtil: Codeunit "LSC POS Trans. Server Utility";
        LocalRecFound: Boolean;
        STATE: Code[10];
        ExpDate: Date;
        ErrorCode: Integer;
        Text001: Label 'Entry %1 %2 is either applied or no balance left';
    begin
        STATE := 'PAYMENT';
        if EntryType = '' then
            exit(false);

        //BC22 Start 
        //Allow all Vouchers to be scanned
        /*
        if StrLen(CurrInput) <> 13 then
            exit(false);
          */
        //BC22 End

        if STATE <> STATE_PAYMENT then
            exit(false);
        //BC Start
        PosDataEntryType.Get(EntryType);
        if PosDataEntryType."Barcode Mask Entry No" <> 0 then begin
            BarcodeMask.Get(PosDataEntryType."Barcode Mask Entry No");
            if BarcodeMask.Type = BarcodeMask.Type::"Data Entry" then
                CurrInput := PosFunc.GetBarcDataEntryCode(CopyStr(CurrInput, 1, 22), BarcodeMask);
        end;
        // LocalRecFound := LocalDataEntry.Get(EntryType, CurrInput);
        // DataEntry2Modify := LocalDataEntry;
        //BC end
        Clear(DataEntry);
        // if not TSUtil.GetDataEntry(EntryType, CurrInput, DataEntry, ErrorText) then
        //     exit(false);
        // if DataEntry.Applied then begin
        //     ErrorMSG := StrSubstNo('Entry %1 has already been applied', CurrInput);
        //     exit(false);
        // END;

        //LocalInstance of Data Entry
        // If localRecfound then
        //     if DataEntry2.Get(DataEntry."Entry Type", DataEntry."Entry Code") then
        //         DataEntry2Modify.Modify();

        // if PosDataEntryType."Create Voucher Entry" then
        //     Amount := DataEntry."Voucher Remaining Amount"
        // else
        //     Amount := DataEntry.Amount;
        // exit(Amount > 0);
        if LocalDataEntry.Get(EntryType, CurrInput) then
            if LocalDataEntry.Applied then begin
                ErrorMSG := StrSubstNo('Entry %1 has already been applied', CurrInput);
                exit(false);
            end;

        if not PosInfoCodeUtils.ViewDataEntryBalance(EntryType, CurrInput, ErrorCode, Amount, ExpDate, ErrorMSG) then begin

            exit(false);
        end;
        if Amount <= 0 then
            ErrorMSG := StrSubstNo(Text001, EntryType, CurrInput);
        exit(Amount > 0);
    end;

    procedure ProcessGiftVoucher(_POSDataEntryType: Record "LSC POS Data Entry Type"; EntryCode: Code[20]; Amount: Decimal; VAR _ErrorMessage: Text; STATE_PAYMENT: Code[10])
    var
        PosMenuLine: Record "LSC POS Menu Line";
        PosTransInfoCode: Record "LSC POS Trans. Infocode Entry";
        _POSTransLine: Record "LSC POS Trans. Line";
        PosFunc: Codeunit "LSC POS Functions";
        PosGenUtils: Codeunit "Pos_General Utility_NT";
        PosInfoUtil: Codeunit "LSC POS Infocode Utility";
        PosView: Codeunit "LSC POS View";
        FromGiftVoucher: Boolean;
        CurrReceiptNo: code[20];
        NewInput: Code[20];
        STATE: Code[10];
        AvailableAmount: Decimal;
        EntryCodeTxt: Text;
        GiftVchCode: Text;
    begin
        STATE := 'PAYMENT';
        PosGenUtils.GetGiftVoucher(FromGiftVoucher, GiftVchCode);
        // IF NOT (STRLEN(EntryCode) IN [9, 13]) THEN
        //     EXIT;
        IF STATE <> STATE_PAYMENT THEN
            EXIT;
        IF _POSDataEntryType."Tender Type" = '' THEN
            EXIT;

        //CHECK FOR REUSE IN SAME TRANSACTION
        CurrReceiptNo := Posview.GetReceiptNo();
        PosTransInfoCode.SETRANGE("Receipt No.", CurrReceiptNo);
        PosTransInfoCode.SETRANGE("Transaction Type", PosTransInfoCode."Transaction Type"::"Payment Entry");
        PosTransInfoCode.SETFILTER(Infocode, _POSDataEntryType.Code);
        PosTransInfoCode.SETFILTER(Status, '<>%1', PosTransInfoCode.Status::Voided);
        //NewInput := PosInfoUtil.ReturnDataEntryInput(EntryCode, _POSDataEntryType);//BC Upgrade
        NewInput := EntryCode;//BC Upgrade
        PosTransInfoCode.SETFILTER(Information, NewInput);
        IF PosTransInfoCode.FINDFIRST() THEN BEGIN
            _ErrorMessage := 'You cannot use this voucher for the same transaction twice.';
            EXIT;
        END;

        IF _POSDataEntryType."Exclude Item Category" <> '' THEN BEGIN
            CLEAR(_POSTransLine);
            _POSTransLine.SETRANGE("Receipt No.", CurrReceiptNo);
            _POSTransLine.SETRANGE("Entry Status", _POSTransLine."Entry Status"::" ");
            _POSTransLine.SETRANGE("Entry Type", _POSTransLine."Entry Type"::Item);
            //_POSTransLine.SETFILTER("Item Category Code",_POSDataEntryType."Exclude Item Category");
            IF _POSTransLine.FINDSET THEN
                REPEAT
                    IF STRPOS(_POSDataEntryType."Exclude Item Category", _POSTransLine."Item Category Code") = 0 THEN
                        AvailableAmount += _POSTransLine.Amount;
                UNTIL _POSTransLine.NEXT = 0;
            //IF _POSTransLine.FINDFIRST THEN BEGIN
            //  _ErrorMessage := STRSUBSTNO('%1 is not allowed for this voucher',_POSTransLine.Description);
            //  EXIT;
            //END;
        END ELSE
            AvailableAmount := Amount;

        IF AvailableAmount <= 0 THEN BEGIN
            _ErrorMessage := 'You cannot use this voucher for this transaction.';
            EXIT;
        END;

        IF AvailableAmount > Amount THEN
            AvailableAmount := Amount;

        //PosTransCU.TenderKeyPressedEx(_POSDataEntryType."Tender Type", PosFunc.FormatAmount(AvailableAmount)); BC22 Upgrade
        EntryCodeTxt := EntryCode;
        //BC22 Upgrade Start
        //IF PosTransCU.GetFunctionMode() = 'INFOCODE' THEN BEGIN
        //PosTransCU.SetCurrInput(EntryCodeTxt);
        Posview.SetCurrInput(EntryCodeTxt);
        //PosGenUtils.SetGiftVoucher(True, EntryCodeTxt);

        //PosTransCU.ValidateInput;
        PosMenuLine.Init();
        PosMenuLine."Current-RECEIPT" := CurrReceiptNo;
        PosMenuLine."Current-INPUT" := EntryCodeTxt;
        PosMenuLine.Command := 'TENDER_K_AM';
        PosMenuLine.Parameter := StrSubstNo('%1,%2', _POSDataEntryType."Tender Type", PosFunc.FormatAmount(AvailableAmount));
        Posview.RunCommand(PosMenuLine);
        IF PosView.GetFunctionMode() = 'INFOCODE' THEN BEGIN
            Posview.SetCurrInput(EntryCodeTxt);
            PosView.ValidateInput();
            Clear(EntryCodeTxt);
            //PosGenUtils.SetSkipEnteressedTriggeredFromGiftVoucher(true);
        end;
        //END;
        //BC22 Upgrade End
    end;

    procedure VoidDataEntry(REC: Record "LSC POS Transaction")
    var
        couponEntry: Record "LSC Coupon Entry";
        POSDataEntry2: Record "LSC POS Data Entry";
        POSDataEntry: Record "LSC POS Data Entry";
        VoucherEntry: Record "LSC Voucher Entries";
        TSUtil: Codeunit "LSC POS Trans. Server Utility";
        ErrMsg: Text;
    begin
        POSDataEntry.Reset();
        POSDataEntry.SetCurrentKey("Applied by Receipt No.", "Applied by Line No.");
        POSDataEntry.SetRange("Applied by Receipt No.", REC."Receipt No.");
        if POSDataEntry.FindSet() then
            repeat
                POSDataEntry2 := POSDataEntry;
                POSDataEntry2.Applied := false;
                POSDataEntry2."Applied Amount" := 0;
                POSDataEntry2."Applied by Receipt No." := '';
                POSDataEntry2."Applied by Line No." := 0;
                POSDataEntry2."Reserverd By POS No." := '';
                TSUtil.UpdateDataEntry(POSDataEntry2, ErrMsg);
                POSDataEntry2.Modify();
                VoucherEntry.Reset();
                VoucherEntry.SetCurrentKey("Voucher No.", "Entry Type", Voided);
                VoucherEntry.SetRange("Voucher No.", POSDataEntry."Entry Code");
                VoucherEntry.SetRange(Voided, FALSE);
                VoucherEntry.SetRange("Receipt Number", REC."Receipt No.");
                if VoucherEntry.FindSet(true, true) then
                    VoucherEntry.ModifyAll(Voided, true);
            //Sum("Voucher Entries".Amount WHERE (Voucher No.=FIELD(Entry Code),Voided=CONST(No)))
            until POSDataEntry.Next() = 0;
    end;

    procedure VoidLineDataEntry(POSTransLine: Record "LSC POS Trans. Line")
    var
        Infocode: Record "LSC Infocode";
        POSDataEntry: Record "LSC POS Data Entry";
        POSTransInfoEntry: Record "LSC POS Trans. Infocode Entry";
        TSUtil: Codeunit "LSC POS Trans. Server Utility";
        ErrMsg: Text;
    begin
        if POSTransLine."Entry Type" <> POSTransLine."Entry Type"::Payment then
            exit;
        Clear(POSTransInfoEntry);
        POSTransInfoEntry.SetRange("Receipt No.", POSTransLine."Receipt No.");
        POSTransInfoEntry.SetRange("Transaction Type", POSTransInfoEntry."Transaction Type"::"Payment Entry");
        POSTransInfoEntry.SetRange("Line No.", POSTransLine."Line No.");
        POSTransInfoEntry.SetRange(Status, POSTransInfoEntry.Status::Processed);
        if POSTransInfoEntry.FindFirst() then
            if Infocode.Get(POSTransInfoEntry.Infocode) then
                if Infocode."Data Entry Type" <> '' then
                    if TSUtil.GetDataEntry(Infocode."Data Entry Type", POSTransInfoEntry.Information, POSDataEntry, ErrMsg) then begin
                        //if POSDataEntry.GET(Infocode."Data Entry Type", POSTransInfoEntry.Information) then begin
                        POSDataEntry."Reserverd By POS No." := '';
                        ErrMsg := '';
                        TSUtil.UpdateDataEntry(POSDataEntry, ErrMsg);
                    end;
    end;

    procedure IsPurgeOverDue(): Boolean
    var
        PosFuncProfile: Record "LSC POS Func. Profile";
        PosTrans: Record "LSC POS Transaction";
        SaleType: Record "LSC Sales Type";
        Trans: Record "LSC Transaction Header";
        POSSESSION: Codeunit "LSC POS Session";
        RefDate: Date;
    begin
        SaleType.SetFilter("Days Open Trans. Exist", '>%1', 0);
        if SaleType.FindSet() then
            repeat
                PosTrans.SetCurrentKey("Store No.", "Sales Type", "Table No.", "Transaction Type", "Trans. Date");
                PosTrans.SetRange("Store No.", POSSESSION.StoreNo);
                PosTrans.SetRange("Sales Type", SaleType.Code);
                PosTrans.SetRange("Trans. Date", 0D, Today - SaleType."Days Open Trans. Exist" - SaleType."Trans. Delete Reminder");
                PosTrans.SetRange("Transaction Type", PosTrans."Transaction Type"::Sales);
                IF PosTrans.FindFirst() THEN
                    exit(true);
            until SaleType.Next() = 0;
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID());
        if PosFuncProfile."Days Transactions Exists" <> 0 then begin
            RefDate := Today;
            Trans.Reset();
            Trans.SetCurrentKey("Store No.", Date);
            Trans.SetRange("Store No.", POSSESSION.StoreNo);
            Trans.SetRange(Date, 0D, RefDate - PosFuncProfile."Days Transactions Exists" - PosFuncProfile."Trans. Delete Reminder");
            exit(Trans.FindFirst());
        end;
    end;

    procedure Purge()
    var
        CardEntries: Record "LSC POS Card Entry";
        LastTransRecord: Record "LSC Transaction Header" temporary;
        PosFuncProfile: Record "LSC POS Func. Profile";
        POSLog: Record "LSC POS Log";
        PosTrans: Record "LSC POS Transaction";
        SaleType: Record "LSC Sales Type";
        Trans: Record "LSC Transaction Header";
        TransCouponEntry: Record "LSC Trans. Coupon Entry";
        VoidedTrans: Record "LSC POS Voided Transaction";
        POSSESSION: Codeunit "LSC POS Session";
        RefDate: Date;
        CountTransAfterDateFilter: Integer;
        CountTransBeforeDateFilter: Integer;
    begin

        SaleType.SetFilter("Days Open Trans. Exist", '>%1', 0);
        if SaleType.FindSet then
            repeat
                PosTrans.SetCurrentKey("Store No.", "Sales Type", "Table No.", "Transaction Type", "Trans. Date");
                PosTrans.SetRange("Store No.", POSSESSION.StoreNo);
                PosTrans.SetRange("Sales Type", SaleType.Code);
                PosTrans.SetRange("Trans. Date", 0D, Today - SaleType."Days Open Trans. Exist");
                PosTrans.SetRange("Transaction Type", PosTrans."Transaction Type"::Sales);
                if PosTrans.FindSet then
                    repeat
                        PosTrans.CalcFields(Payment);
                        if PosTrans.Payment = 0 then
                            PosTrans.Delete(true);
                    until PosTrans.Next = 0;
            until SaleType.Next = 0;
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID());
        if PosFuncProfile."Days Transactions Exists" > 0 then begin
            RefDate := Today;
            Trans.Reset;
            Trans.SetCurrentKey("Store No.", Date);
            Trans.SetRange("Store No.", POSSESSION.StoreNo);
            CountTransBeforeDateFilter := Trans.Count;
            Trans.SetRange(Date, 0D, RefDate - PosFuncProfile."Days Transactions Exists");
            CountTransAfterDateFilter := Trans.Count;
            //Leave at least the last transaction in the table so it will replicate correctly in HO
            if not (CountTransBeforeDateFilter = CountTransAfterDateFilter) then
                Trans.DeleteAll(true)
            else
                if Trans.FindLast() then begin
                    LastTransRecord.Reset();
                    LastTransRecord.DeleteAll();
                    LastTransRecord := Trans;
                    Trans.DeleteAll(true);
                    Trans := LastTransRecord;
                    Trans.Insert(true);
                end;

            VoidedTrans.SetCurrentKey(Replicated, "Trans. Date");
            VoidedTrans.SetRange("Trans. Date", 0D, RefDate - PosFuncProfile."Days Transactions Exists");
            VoidedTrans.DeleteAll(true);

            CardEntries.SetCurrentKey(Replicated, Date);
            CardEntries.SetRange(Date, 0D, RefDate - PosFuncProfile."Days Transactions Exists");
            CardEntries.DeleteAll(true);

            POSLog.Reset;
            POSLog.SetRange("Entry Date", 0D, RefDate - PosFuncProfile."Days Transactions Exists");
            //SK 02/11/22 POSLog.SetRange("Store No.", StoreSetup."No."); //BC Upgrade
            //SK 02/11/22 POSLog.SetRange("Terminal No.", PosTerminal."No."); //BC Upgrade
            POSLog.DeleteAll(true);

            //BC Upgrade Start
            // EFTLog.Reset();
            // EFTLog.SetRange(Date, 0D, TODAY - PosFuncProfile."Days Transactions Exists");
            // EFTLog.DeleteAll();
            //EFTReceipt.RESET;//SK 02/11/22
            //EFTReceipt.SETRANGE(Date,0D,TODAY - PosFuncProfile."Days Transactions Exists");//SK 02/11/22
            //EFTReceipt.DeleteAll();

            /*
            // NT ..

            IF LastTrans."Transaction No." > 0 THEN BEGIN
                Trans.RESET;
                Trans.SETRANGE("Store No.", POSSESSION.StoreNo);
                IF NOT Trans.FINDFIRST THEN
                    LastTrans.INSERT;
            END;

            // .. NT
            */
            //CODEUNIT.RUN(CODEUNIT::"Mobile App Functions"); // NT //BC Upgrade Commented no function called onRun in POS NAV2016
            //COMMIT; //BC Upgrade Commented
            //BC Upgrade End
        end;
    end;

    procedure PrintInvoiceFromTransRegister(Trans: Record "LSC Transaction Header")
    Var
        TransHeader: Record "LSC Transaction Header";
    begin
        TransHeader.Reset();
        TransHeader.SetCurrentKey("Receipt No.", Date);
        TransHeader.SetRange("Receipt No.", Trans."Receipt No.");
        TransHeader.SetRange("Store No.", Trans."Store No.");
        TransHeader.SetRange("POS Terminal No.", Trans."POS Terminal No.");
        TransHeader.SetRange("Transaction No.", Trans."Transaction No.");
        Report.RunModal(Report::"Transaction Invoice_NT", true, true, TransHeader);
    end;

    procedure MultipleBarcodesPressed(ScannerData: Text)
    var
        PosTransCU: Codeunit "LSC POS Transaction";
        i: Integer;
        CurrInput: Text;
        DotNetArray: DotNet Array;
        DotNetString1: DotNet String;
        DotNetString2: DotNet String;
    begin

        DotNetString2 := 'F';
        DotNetString1 := ScannerData;
        DotNetArray := DotNetString1.Split(DotNetString2.ToCharArray());
        for i := 1 to DotNetArray.Length do
            if Format(DotNetArray.GetValue(i - 1)) <> '' then
                if not CheckBarcode(DotNetArray.GetValue(i - 1)) then begin
                    PosTransCU.PosMessage(StrSubstNo('Barcode %1 not found.', DotNetArray.GetValue(i - 1)));
                    exit;
                end;
        for i := 1 to DotNetArray.Length do
            if Format(DotNetArray.GetValue(i - 1)) <> '' then begin
                if CheckBarcode(DotNetArray.GetValue(i - 1)) then begin
                    CurrInput := DotNetArray.GetValue(i - 1);
                    PosTransCU.SetCurrInput(CurrInput);//BC Upgrade
                    PosTransCU.ItemNoPressed;
                end;
            end;
    end;

    procedure CheckBarcode(_BarcodeNo: Code[20]): Boolean
    var
        Barcode: Record "LSC Barcodes";
        BarcodeMask: Record "LSC Barcode Mask";
        BcUtil: Codeunit "LSC Barcode Management";
        BCFound: Boolean;
        BMFound: Boolean;
    begin
        BMFound := BcUtil.FindBarcodeMask(COPYSTR(_BarcodeNo, 1, 22), BarcodeMask);
        BCFound := Barcode.GET(COPYSTR(_BarcodeNo, 1, 20));

        if BCFound or (NOT BMFound) or (BMFound and (BarcodeMask.Type = BarcodeMask.Type::Item)) then
            exit(true);
        exit(false);
    end;

    procedure PrintTransInvoice(Transaction: Record "LSC Transaction Header"; var LastErrorText: Text): Boolean
    var
        GenPosFunc: Record "LSC POS Func. Profile";
        POSSESSION: Codeunit "LSC POS Session";
        NT000: label 'No Trans. Invoice Report ID Defined in POS Functionality Profile %1';
    begin

        Clear(LastErrorText);
        GenPosFunc.Get(POSSESSION.FunctionalityProfileID());
        if Transaction."Transaction No." = 0 then
            exit(true);
        //WindowInitialize();//BC Upgrade

        LastErrorText := StrSubstNo(NT000, GenPosFunc."Profile ID");

        if GenPosFunc."Trans. Sales Inv. Report ID" = 0 then
            exit(false);

        Transaction.SetRecFilter();
        Report.Run(GenPosFunc."Trans. Sales Inv. Report ID", false, true, Transaction);
        exit(true);
    end;

    procedure CouponResetReservation(POSTransLine: Record "LSC POS Trans. Line")
    var
        CouponEntry: Record "LSC Coupon Entry";
        CouponEntryTEMP: Record "LSC Coupon Entry" temporary;
        CouponHeader: Record "LSC Coupon Header";
        POSSession: Codeunit "LSC POS Session";
        SendSerialCouponUtils: Codeunit LSCSendSerialCouponUtils;
        ResponseCode: Code[30];
        ErrorText: Text;
    begin
        if CouponHeader.Get(POSTransLine."Coupon Code") then
            if CouponHeader."Coupon ID Method" = CouponHeader."Coupon ID Method"::"Serial No." then begin
                CouponEntry.Reset;
                CouponEntry.SetCurrentKey("Coupon Code", Barcode, Status);
                CouponEntry.SetRange("Coupon Code", CouponHeader.Code);
                CouponEntry.SetRange(Barcode, POSTransLine."Coupon Barcode No.");
                CouponEntry.SetRange("Reserved by POS Terminal No.", POSTransLine."POS Terminal No.");
                if CouponEntry.FindFirst then begin
                    CouponEntry."Reserved by POS Terminal No." := '';
                    CouponEntry."Date Reserved on POS" := 0D;
                    CouponEntry.Modify;
                    CouponEntryTEMP.Reset;
                    CouponEntryTEMP.DeleteAll;
                    CouponEntryTEMP := CouponEntry;
                    CouponEntryTEMP.Insert;
                    SendSerialCouponUtils.SetPosFunctionalityProfile(POSSession.FunctionalityProfileID);
                    SendSerialCouponUtils.SendRequest(false, CouponEntryTEMP, ResponseCode, ErrorText);
                end;
            end;
    end;

    procedure GetDataEntryType(Input: Text; var FoundPOSDataEntryType: Record "LSC POS Data Entry Type"): Boolean
    var
        POSDataEntryType: Record "LSC POS Data Entry Type";
        Prefix: Code[10];
        i: Integer;
        DotNetArray: DotNet Array;
        DotNetString1: DotNet String;
        DotNetString2: DotNet String;
    begin
        POSDataEntryType.SetFilter(Prefix, '<>%1', '');
        POSDataEntryType.SetFilter("Tender Type", '<>%1', '');
        DotNetString2 := ';';
        if POSDataEntryType.FindSet() then begin
            repeat
                DotNetString1 := POSDataEntryType.Prefix;
                if not DotNetString1.IsNullOrWhiteSpace(DotNetString1) then begin
                    DotNetArray := DotNetString1.Split(DotNetString2.ToCharArray());
                    for i := 1 to DotNetArray.Length do begin
                        Prefix := DotNetArray.GetValue(i - 1);
                        if CopyStr(Input, 1, STRLEN(Prefix)) = Prefix then begin
                            FoundPOSDataEntryType := POSDataEntryType;
                            exit(true);
                        end;
                    end;
                end;
            until POSDataEntryType.Next() = 0;
        END;
        exit(false);
    end;

    procedure PrintExtraPayment(var PosPrintUtil: Codeunit "LSC POS Print Utility"; var POSDataEntry: Record "LSC POS Data Entry"; TenderType: Record "LSC Tender Type"; PaymentLine: Record "LSC Trans. Payment Entry"; var Transaction: Record "LSC Transaction Header"): Boolean
    var
        Header: Record "LSC POS Print Setup Header";
        TabSpec: Record "LSC POS Table Spec Print Setup";
        IsHandled: Boolean;
        ReturnValue: Boolean;
        Skip: Boolean;
        InfoNumber: Text[30];
    begin

        InfoNumber := POSDataEntry."Entry Code";

        TabSpec.SetRange(TabSpec."Table No.", Database::"LSC Tender Type");
        TabSpec.SetRange(TabSpec.Key, TenderType."Primary Key");
        if TabSpec.FindSet() then
            repeat
                if Header.Get(TabSpec."Setup ID") then begin
                    Skip := false;
                    if PaymentLine."Amount Tendered" > 0 then begin
                        if (TabSpec."When Required" = TabSpec."When Required"::" ")
                          or (TabSpec."When Required" = TabSpec."When Required"::Negative)
                          or (TabSpec."When Required" = TabSpec."When Required"::"Voucher Re-Issue")
                        then
                            Skip := true;
                    end else
                        if (TabSpec."When Required" = TabSpec."When Required"::" ")
                          or (TabSpec."When Required" = TabSpec."When Required"::Positive)
                          or (TabSpec."When Required" = TabSpec."When Required"::"Voucher Re-Issue")
                        then
                            Skip := true;
                    if not Skip then begin
                        Header.Get(TabSpec."Setup ID");
                        if not PosPrintUtil.PrintExtra(Transaction, Header, PaymentLine."Amount Tendered", POSDataEntry."Voucher Remaining Amount (Int)", 0, TenderType.Code, TenderType.Description, InfoNumber, 2,
                           PaymentLine."Line No.", POSDataEntry."Entry Type", '', '', '', '')
                        then
                            exit(false);
                    end;
                end;
            until TabSpec.Next = 0;
        exit(true);
    end;

    procedure GetOfferDetails(FromOfferNo: Code[20]; ItemNo: Code[20]; VAR OfferNo: Code[20]; VAR OfferDesc: Text[30])
    var
        PerDiscLine: Record "LSC Periodic Discount Line";
    begin
        PerDiscLine.RESET;
        PerDiscLine.SETRANGE("Offer No.", FromOfferNo);
        PerDiscLine.SETRANGE(Type, PerDiscLine.Type::Item);
        PerDiscLine.SETRANGE("No.", ItemNo);
        if PerDiscLine.FINDFIRST then begin
            OfferNo := PerDiscLine."Discount Offer No.";
            OfferDesc := PerDiscLine."Discount Offer Description";
        end;
    end;

    procedure IsCouponValid2(var CouponHeader: Record "LSC Coupon Header"; var ErrorMsg: Text[250]): Boolean
    var
        CouponLine: Record "LSC Coupon Line";
        Item: Record Item;
        ItemSpecialGroup: Record "LSC Item/Special Group Link";
        POSTrans: Record "LSC POS Transaction";
        POSTransLine: Record "LSC POS Trans. Line";
        TMPPOSTransLine: Record "LSC POS Trans. Line" temporary;
        POSTransCU: Codeunit "LSC POS Transaction";
        Found: Boolean;
        UseTransAmt: Boolean;
        TMPCouponLineAmounts: Decimal;//BC Upgrade
        TransAmt: Decimal;
    begin
        if CouponHeader."Amount to Trigger" > 0 then begin
            if not POSTrans.Get(POSTransCU.GetReceiptNo) then
                exit(false);

            if CouponHeader."Amt. to Trigger Based on Lines" then begin
                CouponLine.Reset();
                CouponLine.SetRange("Coupon Code", CouponHeader.Code);
                CouponLine.SetRange("List Type", CouponLine."List Type"::Use);
                CouponLine.SetRange(Exclude, false);
                CouponLine.SetRange(Type, CouponLine.Type::All);
                POSTransLine.Reset();
                POSTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
                POSTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
                POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
                POSTransLine.SetRange("Entry Status", POSTransLine."Entry Status"::" ");
                TMPPOSTransLine.Reset();
                TMPPOSTransLine.DeleteAll();
                if POSTransLine.FindSet() then
                    repeat
                        TMPPOSTransLine := POSTransLine;
                        TMPPOSTransLine.Insert();
                    until POSTransLine.Next() = 0;
                if CouponLine.FindFirst() then
                    UseTransAmt := true
                else begin
                    //TMPCouponLineAmounts.RESET; //BC Upgrade
                    ///TMPCouponLineAmounts.DELETEALL; //BC Upgrade
                    TMPCouponLineAmounts := 0;//BC Upgrade
                    CouponLine.SetFilter(Type, '<>%1', CouponLine.Type::All);
                    if not CouponLine.FindSet() then
                        UseTransAmt := true
                    else
                        repeat
                            //BC Upgrade Start
                            // IF NOT TMPCouponLineAmounts.GET('', CouponLine."No.", CouponLine.Type) THEN BEGIN
                            //     CLEAR(TMPCouponLineAmounts);
                            //     TMPCouponLineAmounts."Coupon Code" := CouponLine."No.";
                            //     TMPCouponLineAmounts."Entry No." := CouponLine.Type;
                            //     TMPCouponLineAmounts.INSERT;
                            // END;
                            //BC Upgrade End
                            if TMPPOSTransLine.FindFirst() then
                                repeat
                                    Item.Get(TMPPOSTransLine.Number);
                                    case CouponLine.Type of
                                        CouponLine.Type::Item:
                                            if Item."No." = CouponLine."No." then begin
                                                //BC Upgrade Start
                                                // TMPCouponLineAmounts.Quantity += TMPPOSTransLine.Amount;
                                                // TMPCouponLineAmounts.MODIFY;
                                                TMPCouponLineAmounts += TMPPOSTransLine.Amount;
                                                //BC Upgrade end
                                                TMPPOSTransLine.DELETE;
                                            end;
                                        CouponLine.Type::"Item Category":
                                            if Item."Item Category Code" = CouponLine."No." then begin
                                                //BC Upgrade Start
                                                // TMPCouponLineAmounts.Quantity += TMPPOSTransLine.Amount;
                                                // TMPCouponLineAmounts.MODIFY;
                                                TMPCouponLineAmounts += TMPPOSTransLine.Amount;
                                                TMPPOSTransLine.DELETE;
                                                //BC Upgrade End;
                                            end;
                                        CouponLine.Type::"Product Group":
                                            //BC Upgrade Start
                                            //IF Item."Product Group Code" = CouponLine."No." THEN BEGIN
                                            if Item."LSC Retail Product Code" = CouponLine."No." then begin
                                                // TMPCouponLineAmounts.Quantity += TMPPOSTransLine.Amount;
                                                // TMPCouponLineAmounts.MODIFY;
                                                TMPCouponLineAmounts += TMPPOSTransLine.Amount;
                                                //BC Upgrade End
                                                TMPPOSTransLine.Delete();
                                            end;
                                        //BC Upgrade Start
                                        // CouponLine.Type::Division:
                                        //     IF Item."Division Code" = CouponLine."No." THEN BEGIN
                                        //         TMPCouponLineAmounts.Quantity += TMPPOSTransLine.Amount;
                                        //         TMPCouponLineAmounts.MODIFY;
                                        //         TMPPOSTransLine.DELETE;
                                        //     END;
                                        //BC Upgrade End
                                        CouponLine.Type::"Special Group":
                                            begin
                                                Found := FALSE;
                                                ItemSpecialGroup.SetRange("Item No.", Item."No.");
                                                if ItemSpecialGroup.FindSet() then
                                                    repeat
                                                        if ItemSpecialGroup."Special Group Code" = CouponLine."No." then begin
                                                            //BC Upgrade Start
                                                            // TMPCouponLineAmounts.Quantity += TMPPOSTransLine.Amount;
                                                            // TMPCouponLineAmounts.MODIFY;
                                                            TMPCouponLineAmounts += TMPPOSTransLine.Amount;
                                                            //BC Upgrade End
                                                            TMPPOSTransLine.Delete();
                                                            Found := true;
                                                        end;
                                                    until (ItemSpecialGroup.Next() = 0) OR Found;
                                            end;
                                    end;
                                until TMPPOSTransLine.Next() = 0;
                        until CouponLine.Next() = 0;
                end;
            end else
                UseTransAmt := true;

            if UseTransAmt then begin
                POSTrans.CalcFields("Gross Amount", POSTrans."Line Discount", POSTrans."Total Discount");
                TransAmt := POSTrans."Gross Amount" + POSTrans."Line Discount" + POSTrans."Total Discount";
            end else begin
                //TMPCouponLineAmounts.CALCSUMS(Quantity); BC Upgrade
                //TransAmt := TMPCouponLineAmounts.Quantity;BC Upgrade
                TransAmt := TMPCouponLineAmounts;//BC Upgrade
            end;
            if TransAmt < CouponHeader."Amount to Trigger" then begin
                ErrorMsg := StrSubstNo('Transaction must be greater than %1', CouponHeader."Amount to Trigger");
                exit(false);
            end else
                exit(true);
        end;

        if CouponHeader."Point Value" > 0 then begin
            if not POSTrans.Get(POSTransCU.GetReceiptNo) then
                exit(false);
            POSTrans.CalcFields("Point Value");
            exit(CouponHeader."Point Value" + POSTrans."Point Value" <= POSTrans."Starting Point Balance");
        end;

        EXIT(TRUE);
    end;

    procedure CreateCouponBarcode(CouponHeader: Record "LSC Coupon Header"; SequenceNumber: Integer; var ErrorText: Text[250]) BarcodeNo: Code[22]
    var
        BarcodeMask: Record "LSC Barcode Mask";
        BarcodeMaskCharacter: Record "LSC Barcode Mask Character";
        BarcodeMaskSegment: Record "LSC Barcode Mask Segment";
        CouponEntry: Record "LSC Coupon Entry";
        WrkCouponHeader: Record "LSC Coupon Header";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        WeReqMgt: Codeunit "Pos_Web Request Management_NT";
        ProcessError: Boolean;
        Char: Text[30];
        WrkCode: Code[22];
        WrkValueDate: Date;
        DiscountPercentageOrAmt: Decimal;
        Chk: Integer;
        ElementType: Integer;
        I: Integer;
        NumberSeriesLength: Integer;
        SequenceLength: Integer;
        WrkString: Text[250];
        Text023: Label 'The %1 in %2 %3 must be greater than 0. See field %4.';
        Text024: Label 'The %1 in %2 %3 must contain a DateFormula.';
        Text025: Label 'The %1 in %2 %3 must be filled out. See %4 in %5 %6.';
    begin
        if not CouponHeader."No. Series From Server" then
            exit('');
        ErrorText := '';
        if CouponHeader."Barcode Mask" = '' then begin
            BarcodeNo := CouponHeader.Code;
            ErrorText := StrSubstNo(Text021, CouponHeader.Code);
            exit('');
        end;

        BarcodeNo := '';
        BarcodeMask.Reset;
        BarcodeMask.SetRange(Mask, CouponHeader."Barcode Mask");
        if not BarcodeMask.FindFirst then begin
            BarcodeNo := CouponHeader.Code;
            ErrorText := StrSubstNo(Text022, CouponHeader."Barcode Mask", CouponHeader.Code);
            exit;
        end;
        BarcodeMaskSegment.Reset;
        BarcodeMaskSegment.SetRange("Mask Entry No.", BarcodeMask."Entry No.");
        for I := 1 to 8 do begin
            case I of
                1:
                    ElementType := CouponHeader."Barcode Element 1".AsInteger();
                2:
                    ElementType := CouponHeader."Barcode Element 2".AsInteger();
                3:
                    ElementType := CouponHeader."Barcode Element 3".AsInteger();
                4:
                    ElementType := CouponHeader."Barcode Element 4".AsInteger();
                5:
                    ElementType := CouponHeader."Barcode Element 5".AsInteger();
                6:
                    ElementType := CouponHeader."Barcode Element 6".AsInteger();
                7:
                    ElementType := CouponHeader."Barcode Element 7".AsInteger();
                8:
                    ElementType := CouponHeader."Barcode Element 8".AsInteger();
            end;
            case ElementType of
                WrkCouponHeader."Barcode Element 1"::Prefix.AsInteger():
                    BarcodeNo := BarcodeNo + BarcodeMask.Prefix;
                WrkCouponHeader."Barcode Element 1"::"Coupon Reference No.".AsInteger():
                    begin
                        BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Coupon Reference");
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        BarcodeMaskSegment.FindFirst;
                        BarcodeNo := BarcodeNo + CopyStr('0000000000000000000000', 1, BarcodeMaskSegment.Length - StrLen(CouponHeader."Coupon Reference No.")) + CouponHeader."Coupon Reference No.";
                    end;
                WrkCouponHeader."Barcode Element 1"::"Discount %".AsInteger(),
                WrkCouponHeader."Barcode Element 1"::"Discount Amount".AsInteger():
                    begin
                        DiscountPercentageOrAmt := CouponHeader.Value;
                        if DiscountPercentageOrAmt <= 0 then begin
                            BarcodeNo := CouponHeader.Code;
                            ErrorText := StrSubstNo(Text023, Format(CouponHeader."Barcode Element 1"), CouponHeader.TableCaption, CouponHeader.Code, CouponHeader.FieldCaption(Value));
                            exit;
                        end;
                        BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::Price);
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        BarcodeMaskSegment.FindFirst;
                        BarcodeNo := BarcodeNo + ReturnDiscount(DiscountPercentageOrAmt, BarcodeMaskSegment.Decimals, BarcodeMaskSegment.Length);
                    end;
                WrkCouponHeader."Barcode Element 1"::"First Valid Date (DDMMYY)".AsInteger():
                    begin
                        if Format(CouponHeader."First Valid Date Formula") = '' then begin
                            BarcodeNo := CouponHeader.Code;
                            ErrorText := StrSubstNo(Text024, CouponHeader.FieldCaption("First Valid Date Formula"), CouponHeader.TableCaption, CouponHeader.Code);
                            exit;
                        end;
                        WrkValueDate := CalcDate(CouponHeader."First Valid Date Formula", Today);
                        CouponEntry."First Valid Date" := WrkValueDate;
                        BarcodeNo := BarcodeNo + Format(CouponEntry."First Valid Date", 0, '<Day,2><Month,2><Year>');
                    end;
                WrkCouponHeader."Barcode Element 1"::"Last Valid Date (DDMMYY)".AsInteger():
                    begin
                        if Format(CouponHeader."Last Valid Date Formula") = '' then begin
                            BarcodeNo := CouponHeader.Code;
                            ErrorText := StrSubstNo(Text024, CouponHeader.FieldCaption("Last Valid Date Formula"), CouponHeader.TableCaption, CouponHeader.Code);
                            exit;
                        end;
                        WrkValueDate := CalcDate(CouponHeader."Last Valid Date Formula", Today);
                        CouponEntry."Last Valid Date" := WrkValueDate;
                        BarcodeNo := BarcodeNo + Format(CouponEntry."Last Valid Date", 0, '<Day,2><Month,2><Year>');
                    end;
                WrkCouponHeader."Barcode Element 1"::"Sequence No.".AsInteger():
                    begin
                        if not BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Serial No.") then
                            BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Any No.");
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        BarcodeMaskSegment.FindFirst;
                        SequenceLength := BarcodeMaskSegment.Length;
                        WrkString := '00000000000000000000' + Format(SequenceNumber);
                        WrkString := CopyStr(WrkString, StrLen(WrkString) - SequenceLength + 1, SequenceLength);
                        BarcodeNo := BarcodeNo + WrkString;
                        CouponEntry."Sequence No." := SequenceNumber;
                    end;
                WrkCouponHeader."Barcode Element 1"::"Any Number".AsInteger():
                    begin
                        BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Any No.");
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        BarcodeMaskSegment.FindFirst;
                        SequenceLength := BarcodeMaskSegment.Length;
                        WrkString := '00000000000000000000' + Format(SequenceNumber);
                        WrkString := CopyStr(WrkString, StrLen(WrkString) - SequenceLength + 1, SequenceLength);
                        BarcodeNo := BarcodeNo + WrkString;
                        CouponEntry."Sequence No." := SequenceNumber;
                    end;
                WrkCouponHeader."Barcode Element 1"::"Number Series".AsInteger():
                    begin
                        if BarcodeMask."Number Series" = '' then begin
                            BarcodeNo := CouponHeader.Code;
                            ErrorText := StrSubstNo(Text025, BarcodeMask.FieldCaption("Number Series"), BarcodeMask.TableCaption, BarcodeMask.Mask,
                              CouponHeader.FieldCaption("Barcode Mask"), CouponHeader.TableCaption, CouponHeader.Code);
                            exit;
                        end;
                        BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Number Series");
                        BarcodeMaskSegment.SetRange(Char, BarcodeMaskCharacter.Character);
                        BarcodeMaskSegment.FindFirst;
                        WrkCode := '';
                        if CouponHeader."No. Series From Server" then begin
                            IF not WeReqMgt.GetNextNoSeriesCodeFromServer(BarcodeMask."Number Series", WrkCode, ProcessError, ErrorText) then
                                NoSeriesManagement.InitSeries(BarcodeMask."Number Series", BarcodeMask."Number Series", Today, WrkCode, BarcodeMask."Number Series");
                        end else
                            NoSeriesManagement.InitSeries(BarcodeMask."Number Series", BarcodeMask."Number Series", Today, WrkCode, BarcodeMask."Number Series");
                        NumberSeriesLength := BarcodeMaskSegment.Length;
                        WrkString := '00000000000000000000' + WrkCode;
                        WrkString := CopyStr(WrkString, StrLen(WrkString) - NumberSeriesLength + 1, NumberSeriesLength);
                        BarcodeNo := BarcodeNo + WrkString;
                    end;
                CouponHeader."Barcode Element 1"::"Check Digit".AsInteger():
                    begin
                        if StrLen(BarcodeNo) mod 2 = 0 then
                            Chk := 1 + StrCheckSum(BarcodeNo, CopyStr('1313131313131313131313', 1, StrLen(BarcodeNo)))
                        else
                            Chk := 1 + StrCheckSum(BarcodeNo, CopyStr('3131313131313131313131', 1, StrLen(BarcodeNo)));
                        Char := SelectStr(Chk, '0,1,2,3,4,5,6,7,8,9');
                        BarcodeNo := BarcodeNo + Char;
                    end;
            end;
        end;
    end;

    local procedure ReturnDiscount(DiscountValue: Decimal; NoOfDecimals: Integer; LengthOfField: Integer) Disc: Text[30]
    var
        FractionValue: Decimal;
        RoundingPrec: Decimal;
        IntegerValue: Integer;
    begin
        if NoOfDecimals = 0 then
            Disc := Format(Round(DiscountValue, 1), 0, '<Integer>')
        else begin
            IntegerValue := Round(DiscountValue, 1, '<');
            FractionValue := DiscountValue - IntegerValue;
            RoundingPrec := 1 / Power(10, NoOfDecimals);
            Disc := Format(Round(FractionValue, RoundingPrec) + 0.0000000001, 0, '<Decimals>');
            if StrLen(Disc) < NoOfDecimals then
                Disc := Disc + CopyStr('000000000000000000000', 1, NoOfDecimals - StrLen(Disc));
            Disc := Format(IntegerValue, 0, '<Integer>') + CopyStr(Disc, 2, NoOfDecimals);
        end;
        if StrLen(Disc) < LengthOfField then
            Disc := CopyStr('0000000000000000000000', 1, LengthOfField - StrLen(Disc)) + Disc
        else
            if StrLen(Disc) > LengthOfField then
                Error(Text007, DiscountValue);
        exit(Disc);
    end;

    procedure InsertPosTopUpEntryToTempTransTopupEntry(Transaction: Record "LSC Transaction Header")
    var
        PosTopUpLine: Record "Pos_POS Topup Entry_NT";
        TransTopUpEntryTEMP: Record "Pos_Trans. Topup Entry_NT" temporary;
        PosGenUtil: Codeunit "Pos_General Utility_NT";
    begin
        PosTopUpLine.Reset();
        PosTopUpLine.SetRange("Receipt No.", Transaction."Receipt No.");
        if PosTopUpLine.FindFirst() then
            repeat
                TransTopUpEntryTEMP.TransferFields(PosTopUpLine);
                TransTopUpEntryTEMP."Transaction No." := Transaction."Transaction No.";
                TransTopUpEntryTEMP.Insert();
                PosTopUpLine.Delete();
            until not PosTopUpLine.FindFirst();
        PosGenUtil.SetTopUpLineOnProcessTransaction(TransTopUpEntryTEMP);
    end;

    procedure InsertTransTopUpEntry(var TransactionHeader: Record "LSC Transaction Header")
    var
        TransTopupEntryLoc: Record "Pos_Trans. Topup Entry_NT";
        TransTopUpEntryTEMP: Record "Pos_Trans. Topup Entry_NT" temporary;
        PosGenUtil: Codeunit "Pos_General Utility_NT";
    begin
        PosGenUtil.GetTempTransTopUpEntry(TransTopUpEntryTEMP);
        TransTopUpEntryTEMP.Reset();
        if TransTopUpEntryTEMP.FindSet() then
            repeat
                TransTopupEntryLoc := TransTopUpEntryTEMP;
                TransTopupEntryLoc."Transaction No." := TransactionHeader."Transaction No.";
                TransTopupEntryLoc.Insert(true);
            until TransTopUpEntryTEMP.Next() = 0;
    end;

    procedure PosTransOfferCount(pReceiptNo: Code[20]; pOfferType: Enum "LSC POS Trans. Per. Disc. Type"; pOfferNo: Code[20]): Integer
    var
        POSTransLine: Record "LSC POS Trans. Line";
        POSTransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
        TmpTrackingInstance: Record "Integer" temporary;
        PosFunctions: Codeunit "LSC POS Functions";
        DiscOfferCount: Integer;
    begin
        DiscOfferCount := 0;
        TmpTrackingInstance.Reset;
        TmpTrackingInstance.DeleteAll;

        POSTransPerDisc.Reset;
        POSTransPerDisc.SetRange("Receipt No.", pReceiptNo);
        POSTransPerDisc.SetRange("Entry Status", POSTransPerDisc."Entry Status"::" ");
        POSTransPerDisc.SetRange(DiscType, pOfferType);
        POSTransPerDisc.SetRange("Offer No.", pOfferNo);
        PosFunctions.PosTransDiscSetTableFilter(4, POSTransPerDisc);
        if PosFunctions.PosTransDiscFindRec(4, '-', POSTransPerDisc) then
            repeat
                if POSTransPerDisc."Tracking Instance ID" <> 0 then
                    if POSTransPerDisc."Periodic Disc. Type" = POSTransPerDisc."Periodic Disc. Type"::"Disc. Offer" then begin
                        if POSTransLine.Get(POSTransPerDisc."Receipt No.", POSTransPerDisc."Line No.") then
                            DiscOfferCount := DiscOfferCount + Round(POSTransLine.Quantity, 1.0, '>');
                    end
                    else
                        if POSTransPerDisc."Periodic Disc. Type" = POSTransPerDisc."Periodic Disc. Type"::"Mix&Match" then begin
                            if POSTransLine.Get(POSTransPerDisc."Receipt No.", POSTransPerDisc."Line No.") then
                                if POSTransLine."Entry Type" = POSTransLine."Entry Type"::PerDiscount then
                                    DiscOfferCount := DiscOfferCount + Round(POSTransLine.Quantity, 1.0, '>');
                        end else
                            if not TmpTrackingInstance.Get(POSTransPerDisc."Tracking Instance ID") then begin
                                TmpTrackingInstance.Init;
                                TmpTrackingInstance.Number := POSTransPerDisc."Tracking Instance ID";
                                if (POSTransPerDisc."Discount %" <> 0) or (POSTransPerDisc."Discount Amount" <> 0) then
                                    TmpTrackingInstance.Insert
                                else
                                    CheckPOSTransPerDiscIsCoupon(TmpTrackingInstance, POSTransPerDisc);
                            end;
            until PosFunctions.PosTransDiscNextRec(4, 1, POSTransPerDisc) = 0;
        exit(TmpTrackingInstance.Count + DiscOfferCount);
    end;

    local procedure CheckPOSTransPerDiscIsCoupon(var TmpTrackingInstance: Record "Integer" temporary; POSTransPerDisc: Record "LSC POS Trans. Per. Disc. Type")
    var
        PeriodicDiscBenefits: Record "LSC Periodic Discount Benefits";
    begin
        PeriodicDiscBenefits.SetRange("Offer No.", POSTransPerDisc."Offer No.");
        PeriodicDiscBenefits.SetRange(Type, PeriodicDiscBenefits.Type::Coupon);
        if PeriodicDiscBenefits.FindFirst() then
            TmpTrackingInstance.Insert
    end;

    procedure UpdateTransStaffID(var REC: Record "LSC POS Transaction")
    var
        POSSESSION: codeunit "LSC POS Session";
    begin
        if REC."New Transaction" AND (REC."Receipt No." <> '') then
            if REC."Staff ID" <> POSSESSION.StaffID then begin
                REC."Staff ID" := POSSESSION.StaffID;
                REC.Modify();
            end;
    end;

    procedure CalcTransTotal_LSCPOSOfferExtUtility(var pPosTrans: Record "LSC POS Transaction"): Decimal
    var
        PosTransLine: Record "LSC POS Trans. Line";
        Global: Codeunit "LSC POS Session";
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        BenefitAmount: Decimal;
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        if Global.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then begin
            pPosTrans.CalcFields("Net Amount", "Line Discount", "Net Income/Exp. Amount");
            TotalAmount := pPosTrans."Net Amount" + pPosTrans."Net Income/Exp. Amount";
        end else begin
            pPosTrans.CalcFields("Gross Amount", "Line Discount", "Income/Exp. Amount");
            TotalAmount := pPosTrans."Gross Amount" + pPosTrans."Income/Exp. Amount";
        end;

        PosTransLine.Reset;
        PosTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        PosTransLine.SetRange("Receipt No.", pPosTrans."Receipt No.");
        PosTransLine.SetRange("Entry Type", PosTransLine."Entry Type"::Item);
        PosTransLine.SetRange("Entry Status", PosTransLine."Entry Status"::" ");
        PosTransLine.SetRange("Benefit Item", true);
        if PosTransLine.FindSet then begin
            BenefitAmount := 0;
            repeat
                if Global.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                    BenefitAmount := BenefitAmount + PosTransLine."Net Amount"
                else
                    BenefitAmount := BenefitAmount + PosTransLine.Amount;
            until PosTransLine.Next = 0;
            TotalAmount := TotalAmount - BenefitAmount;
        end;
        exit(TotalAmount);
    end;

    procedure OnAfterPrintZ(var REC: Record "LSC POS Transaction")
    var
        PosFuncProfile: Record "LSC POS Func. Profile";
        PosMenuLine: Record "LSC POS Menu Line";
        TempStaff: Record "LSC Staff" temporary;
        POSCtrl: Codeunit "LSC POS Control Interface";
        PosGenUtils: Codeunit "Pos_General Utility_NT";
        POSGUI: Codeunit "LSC POS GUI";
        POSSESSION: Codeunit "LSC POS Session";
        PosView: Codeunit "LSC POS View";
    begin
        // NT ..
        OpenDrawer('');
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID());
        CASE PosFuncProfile."Auto Send Batch After Z Report" OF
            PosFuncProfile."Auto Send Batch After Z Report"::JCC:
                BEGIN
                    // EFTTransactionType := EFTTransactionType::"Send Batch";
                    // EFTTransaction('JCC');
                    PosMenuLine.Init();
                    PosMenuLine."Current-RECEIPT" := REC."Receipt No.";
                    PosMenuLine."Current-INPUT" := '';
                    PosMenuLine.Command := 'EFT_SEND_B';
                    PosMenuLine.Parameter := 'JCC';
                    Posview.RunCommand(PosMenuLine);
                END;
            PosFuncProfile."Auto Send Batch After Z Report"::RCB:
                BEGIN
                    // EFTTransactionType := EFTTransactionType::"Send Batch";
                    // EFTTransaction('RCB');
                    PosMenuLine.Init();
                    PosMenuLine."Current-RECEIPT" := REC."Receipt No.";
                    PosMenuLine."Current-INPUT" := '';
                    PosMenuLine.Command := 'EFT_SEND_B';
                    PosMenuLine.Parameter := 'RCB';
                    Posview.RunCommand(PosMenuLine);
                END;
            PosFuncProfile."Auto Send Batch After Z Report"::Both:
                BEGIN
                    // EFTTransactionType := EFTTransactionType::"Send Batch";
                    // EFTTransaction('JCC');
                    // EFTTransaction('RCB');
                    PosMenuLine.Init();
                    PosMenuLine."Current-RECEIPT" := REC."Receipt No.";
                    PosMenuLine."Current-INPUT" := '';
                    PosMenuLine.Command := 'EFT_SEND_B';
                    PosMenuLine.Parameter := 'JCC';
                    Posview.RunCommand(PosMenuLine);

                    PosMenuLine.Init();
                    PosMenuLine."Current-RECEIPT" := REC."Receipt No.";
                    PosMenuLine."Current-INPUT" := '';
                    PosMenuLine.Command := 'EFT_SEND_B';
                    PosMenuLine.Parameter := 'RCB';
                    Posview.RunCommand(PosMenuLine);
                END;
        END;

        //Globals.SetStaffID('');
        PosGenUtils.SetLockSetByStaffID('');
        PosGenUtils.SetFromLock(false);
        //TempStaff.Init();
        //PosView.SetStaffID(TempStaff, '', true);
        REC."Staff ID" := '';
        IF PosFuncProfile."Auto Logoff After Z Report" THEN
            IF POSCtrl.ActivePanel <> POSSESSION.OfflinePanelID THEN
                POSGUI.PostEvent('RUNCOMMAND', 'LOGOFF', '', '');
        // .. NT
    end;

    local procedure openDrawer(RoleID: Code[10])
    var
        PosMenuLine: Record "LSC POS Menu Line";
        PosView: Codeunit "LSC POS View";
    begin
        PosMenuLine.Init();
        PosMenuLine.Command := 'OPEN_DR';
        PosMenuLine.Parameter := RoleID;
        Posview.RunCommand(PosMenuLine);
    end;

    procedure OnBeforeValidateAmountInMarkUsedCoupons_NT(POSTransLineItem: Record "LSC POS Trans. Line"; CouponHeader: Record "LSC Coupon Header"; var SelectedItemsTEMP: Record "LSC Toplist Work Table" temporary; var NoOfCpnsThatCanBeUsed: Integer; RemainingTenderDiscountForCpn: Decimal)
    var
        POSTransaction: Record "LSC POS Transaction";
        MaxDiscAmount: Decimal;
        TotalItemsAmount: Decimal;
    begin
        SelectedItemsTEMP.Reset;
        SelectedItemsTEMP.SetCurrentKey(Amount);
        POSTransLineItem.Reset;
        POSTransLineItem.SetRange("Receipt No.", POSTransLineItem."Receipt No.");
        POSTransLineItem.SetRange("Entry Type", POSTransLineItem."Entry Type"::Item);
        POSTransLineItem.SetRange("Entry Status", POSTransLineItem."Entry Status"::" ");
        NoOfCpnsThatCanBeUsed := 0;
        if SelectedItemsTEMP.FindSet then
            repeat
                POSTransLineItem.SetRange(Number, SelectedItemsTEMP."No.");
                if POSTransLineItem.FindSet then
                    repeat
                        IF NOT CouponHeader."Amt. to Trigger Based on Lines" THEN
                            TotalItemsAmount += POSTransLineItem.Amount
                        ELSE
                            IF IsLineValid(CouponHeader, POSTransLineItem) THEN
                                TotalItemsAmount += POSTransLineItem.Amount;
                    until POSTransLineItem.Next = 0;
            until SelectedItemsTEMP.Next = 0;
        IF NOT CouponHeader."Amt. to Trigger Based on Lines" THEN
            NoOfCpnsThatCanBeUsed := TotalItemsAmount DIV RemainingTenderDiscountForCpn;
        IF CouponHeader."Amt. to Trigger Based on Lines" THEN
            NoOfCpnsThatCanBeUsed := TotalItemsAmount DIV RemainingTenderDiscountForCpn;
        POSTransaction.Get(POSTransLineItem."Receipt No.");
        POSTransaction.CALCFIELDS("Gross Amount", POSTransaction."Line Discount", POSTransaction."Total Discount", Payment);
        MaxDiscAmount := POSTransaction."Gross Amount" + POSTransaction."Line Discount" + POSTransaction."Total Discount" - POSTransaction.Payment;
        IF MaxDiscAmount < RemainingTenderDiscountForCpn THEN
            NoOfCpnsThatCanBeUsed := 0;
    end;

    procedure IsLineValid(CouponHeader: Record "LSC Coupon Header"; PosTransLine: Record "LSC POS Trans. Line"): Boolean
    var
        CouponLine: Record "LSC Coupon Line";
        ItemSpecialGroupLink: Record "LSC Item/Special Group Link";
    begin
        CouponLine.RESET;
        CouponLine.SETRANGE("Coupon Code", CouponHeader.Code);
        CouponLine.SETRANGE("List Type", CouponLine."List Type"::Use);
        CouponLine.SETRANGE(Exclude, FALSE);
        CouponLine.SETRANGE(Type, CouponLine.Type::All);
        IF CouponLine.FINDFIRST THEN
            EXIT(TRUE);
        CouponLine.SETRANGE(Type, CouponLine.Type::Item);
        CouponLine.SETRANGE("No.", PosTransLine.Number);
        IF CouponLine.FINDFIRST THEN
            EXIT(TRUE);
        //BC Upgrade Start
        /*
        CouponLine.SETRANGE(Type, CouponLine.Type::Division);
        CouponLine.SETRANGE("No.", PosTransLine."Division Code");
        IF CouponLine.FINDFIRST THEN
            EXIT(TRUE);
            */
        //BC Upgrade End
        CouponLine.SETRANGE(Type, CouponLine.Type::"Item Category");
        CouponLine.SETRANGE("No.", PosTransLine."Item Category Code");
        IF CouponLine.FINDFIRST THEN
            EXIT(TRUE);

        CouponLine.SETRANGE(Type, CouponLine.Type::"Product Group");
        CouponLine.SETRANGE("No.", PosTransLine."Retail Product Code");
        IF CouponLine.FINDFIRST THEN
            EXIT(TRUE);

        ItemSpecialGroupLink.SETRANGE("Item No.", PosTransLine.Number);
        IF ItemSpecialGroupLink.FINDSET THEN
            REPEAT
                CouponLine.SETRANGE("No.", ItemSpecialGroupLink."Special Group Code");
                IF CouponLine.FINDFIRST THEN
                    EXIT(TRUE);
            UNTIL ItemSpecialGroupLink.NEXT = 0;
        EXIT(FALSE);
    end;

    procedure EmailOrPrint(POSHardwareProfile: Record "LSC POS Hardware Profile"; POSTerminal: Record "LSC POS Terminal"; LastTransaction: Record "LSC Transaction Header"; var POSTransPostingStateTmp: Record "LSC POS Trans. Posting State" temporary): Boolean
    var
        Customer: Record Customer;
        MemberContact: Record "LSC Member Contact";
        EPOSControlInterface: Codeunit "LSC POS Control Interface";
        POSFunctions: Codeunit "LSC POS Functions";
        POSGUI: Codeunit "LSC POS GUI";
        POSPrintUtility: Codeunit "LSC POS Print Utility";
        CustEmailUsed, MemberEmailUsed : Boolean;
        Phase: Integer;
        SelectedOpt: Integer;
        lEmail: Text[250];
        SelectText: Text;
        SelectEmailText: Label 'Print,Send to: %1';
    begin
        CustEmailUsed := false;
        if Customer.Get(POSTransPostingStateTmp."Customer No.") then
            if Customer."E-Mail" <> '' then begin
                lEmail := Customer."E-Mail";
                CustEmailUsed := true;
            end;
        POSFunctions.GetCurrMemberContact(MemberContact);
        if MemberContact."E-Mail" <> '' then begin
            lEmail := MemberContact."E-Mail";
            CustEmailUsed := false;
            MemberEmailUsed := true;
        end;
        if lEmail <> '' then
            SelectText := StrSubstNo(SelectEmailText, lEmail)
        else
            SelectedOpt := 1;
        if SelectedOpt = 0 then
            while SelectedOpt = 0 do
                SelectedOpt := EPOSControlInterface.SelectOption(SelectText, SelectText, 0, false);

        if SelectedOpt = 0 then
            exit(false);
        if (SelectedOpt in [1]) then begin
            if (SelectedOpt = 1) or (POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::"Print and E-mail") then begin
                POSPrintUtility.Init();
                if (not POSPrintUtility.PrintSlips(LastTransaction, Phase)) and (POSPrintUtility.GetLastError <> '') then
                    POSGUI.PosMessage(POSPrintUtility.GetLastError);
            end;
        end;


        // if ((SelectedOpt = 1) and (lEmail = '')) or (SelectedOpt = 2) then begin
        //     POSTransPostingStateTmp."Email Type" := POSTransPostingStateTmp."Email Type"::Manual;
        //     if CustEmailUsed then begin
        //         POSTransPostingStateTmp."Email Type" := POSTransPostingStateTmp."Email Type"::Customer;
        //         POSTransPostingStateTmp."Customer/Member Email" := Customer."E-Mail";
        //     end;
        //     if MemberEmailUsed then begin
        //         POSTransPostingStateTmp."Email Type" := POSTransPostingStateTmp."Email Type"::Member;
        //         POSTransPostingStateTmp."Member Account No." := MemberContact."Account No.";
        //         POSTransPostingStateTmp."Member Contact No." := MemberContact."Contact No.";
        //         POSTransPostingStateTmp."Customer/Member Email" := MemberContact."E-Mail";
        //     end;
        //     POSTransPostingStateTmp."Email Address" := lEmail;
        //     POSTransPostingStateTmp.Modify();
        //     GetEmailInput(lEmail);

        //Handle Email Here as if email selected it will exit
        InsertSlipEmailEntry(LastTransaction, lEmail);
        exit(false);// Always exit false as standard code expects email input and marks as Error after Transaction posting 
        //end;
    end;

    procedure InsertSlipEmailEntry(LastTransaction: Record "LSC Transaction Header"; Email: Text[250])
    var
        SlipEmailEntry: Record "Pos_Slip Email Entry_NT";
    begin
        SlipEmailEntry.Init();
        SlipEmailEntry."Store No." := LastTransaction."Store No.";
        SlipEmailEntry."POS Terminal No." := LastTransaction."POS Terminal No.";
        SlipEmailEntry."Transaction No." := LastTransaction."Transaction No.";
        SlipEmailEntry."Receipt No." := LastTransaction."Receipt No.";
        SlipEmailEntry.Date := LastTransaction.Date;
        SlipEmailEntry.Time := LastTransaction.Time;
        SlipEmailEntry."Customer/Member Email" := Email;
        SlipEmailEntry.Insert(true);
    end;

    procedure GetFoodNonFoodAmtTxt(var POSTransaction: Record "LSC POS Transaction"; var FoodAmtTxt: Text; var NonFoodAmtTxt: Text)
    var
        PosTransCU: Codeunit "LSC POS Transaction";
    begin
        POSTransaction.CalcFields("Food Amount", "Non Food Amount");
        FoodAmtTxt := PosTransCU.FormatAmount(POSTransaction."Food Amount");
        NonFoodAmtTxt := PosTransCU.FormatAmount(POSTransaction."Non Food Amount");
    end;

    procedure VoidMemberCouponLines(POSTransLine: Record "LSC POS Trans. Line")
    var
        CouponHeader: Record "LSC Coupon Header";
        GlobalMenuLine: Record "LSC POS Menu Line";
        POSTransaction: Record "LSC POS Transaction";
        POSTransLine2: Record "LSC POS Trans. Line";
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        PosTransCU: Codeunit "LSC POS Transaction";

    begin
        if (POSTransLine."Text Type" = POSTransLine."Text Type"::"Member Text") then
            if POSTransaction.Get(POSTransLine."Receipt No.") then
                if POSTransaction."Member Card No." = '' then begin
                    POSTransLine2.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    POSTransLine2.SetRange("Entry Status", POSTransLine2."Entry Status"::" ");
                    POSTransLine2.SetFilter("Entry Type", '%1|%2', POSTransLine2."Entry Type"::Payment, POSTransLine2."Entry Type"::Coupon);
                    POSTransLine2.SetFilter("Coupon Code", '<>%1', '');
                    if POSTransLine2.FindSet() then
                        repeat
                            //if CouponHeader.Get(POSTransLine2."Coupon Code") then
                            //  if CouponHeader."Member Value" <> '' then begin
                            PosTransCU.GetGlobalMenuLine(GlobalMenuLine);
                            POSTransLine2."Void Command" := GlobalMenuLine.Command;
                            POSTransLine2.Modify();
                            PosGenUtil.SetSuppressVoidMsg(true);
                            POSLINES.SetCurrentLine(POSTransLine2);
                            PosTransCU.VoidLinePressed();
                        //end;
                        until POSTransLine2.next = 0;
                end;
        PosGenUtil.SetSuppressVoidMsg(false);
    end;

    procedure EMailTransSlip(var Trans: Record "LSC Transaction Header")
    var
        SlipEmailEntry: Record "Pos_Slip Email Entry_NT";
        TransHeader: Record "LSC Transaction Header";
        PosGenFunc: codeunit "Pos_General Functions_NT";
        myInt: Integer;
        pErrorMsg: Text[150];
        Text001: Label 'EMail Sent.';
    begin
        TransHeader.Reset;
        TransHeader.SetRange("Store No.", Trans."Store No.");
        TransHeader.SetRange("POS Terminal No.", Trans."POS Terminal No.");
        TransHeader.SetRange("Transaction No.", Trans."Transaction No.");
        TransHeader.FindFirst();
        SlipEmailEntry.Get(TransHeader."Store No.", TransHeader."POS Terminal No.", TransHeader."Transaction No.");
        PosGenFunc.EmailCopy(TransHeader, SlipEmailEntry."Customer/Member Email", pErrorMsg);
        if pErrorMsg <> '' then
            Message(pErrorMsg)
        else
            Message(Text001);
    end;

    procedure OnBeforePostTransactionCheckMemberCard(var POSTrans: Record "LSC POS Transaction"): Boolean
    var
        PosFuncProfile: Record "LSC POS Func. Profile";
        POSSESSION: Codeunit "LSC POS Session";
        POSTransCU: Codeunit "LSC POS Transaction";
    begin
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID());
        if PosFuncProfile."Loyalty Card on Cust. Trans." then
            if ((POSTrans."Entry Status" <> POSTrans."Entry Status"::Training)) and (POSTrans."Customer No." <> '') and
                (POSTrans."Transaction Type" = POSTrans."Transaction Type"::Sales) and
                (POSTrans."Entry Status" <> POSTrans."Entry Status"::Voided) and
                (POSTrans."Member Card No." = '') then begin
                POSTransCU.ErrorBeep('Please Enter Loyalty Card.');
                exit(true);
            end;
        exit(false);
    end;

    procedure IsValidCouponAttributes(var CouponHeader: Record "LSC Coupon Header"; var POSTransaction: Record "LSC POS Transaction"; var ErrorMsg: Text[250]): Boolean
    var
        MembershipCard: Record "LSC Membership Card";
        MemberCardManagement: Codeunit "LSC Member Card Management";
        MessageTxt: Text;

    begin
        IF (CouponHeader."Member Attribute" <> '') AND (CouponHeader."Member Attribute Value" <> '') THEN BEGIN
            IF POSTransaction."Member Card No." = '' THEN BEGIN
                ErrorMsg := STRSUBSTNO(Text023, CouponHeader.Code, CouponHeader.Description, CouponHeader."Member Attribute",
                CouponHeader."Member Attribute Value");
                EXIT(FALSE);
            END;
            CLEAR(MembershipCard);
            MemberCardManagement.GetMembershipCard(POSTransaction."Member Card No.", MembershipCard, MessageTxt);
            IF MembershipCard."Account No." = '' THEN BEGIN
                ErrorMsg := STRSUBSTNO(Text023, CouponHeader.Code, CouponHeader.Description, CouponHeader."Member Attribute",
                CouponHeader."Member Attribute Value");
                EXIT(FALSE);
            END;
            SetMemberInfo();
            IF NOT RetailPriceUtils.MemberAttrFilterPassed(CouponHeader."Member Attribute", CouponHeader."Member Attribute Value") THEN BEGIN
                ErrorMsg := STRSUBSTNO(Text023, CouponHeader.Code, CouponHeader.Description, CouponHeader."Member Attribute",
                CouponHeader."Member Attribute Value");
                EXIT(FALSE);
            END;
        END;
        exit(true);
    end;

    local procedure SetMemberInfo()
    var
        MemberAttributeListTemp: Record "LSC Member Attribute List" temporary;
        MembershipCardTemp: Record "LSC Membership Card" temporary;
        POSFunctions: Codeunit "LSC POS Functions";
    begin
        //SetMemberInfo
        POSFunctions.GetMemberShipCardInfo(MembershipCardTemp);
        //POSFunctions.GetMemberAccountInfo(MemberAccountTemp);
        POSFunctions.GetMemberAttributeList(MemberAttributeListTemp);
        RetailPriceUtils.SetMemberInfo(MembershipCardTemp, MemberAttributeListTemp);

    end;

    procedure CreateJournalLinesPriceCaption(var pRecRef: RecordRef; var pFieldNo: Integer; var pColumnNo: Integer; var tmpText: Text): Boolean
    var
        PosTransLine: Record "LSC POS Trans. Line";
        Globals: Codeunit "LSC POS Session";
        RecRef_l: RecordRef;
    begin
        case pFieldNo of
            PosTransLine.FieldNo(Price):
                begin
                    RecRef_l := pRecRef.Duplicate;
                    RecRef_l.SetTable(PosTransLine);
                    if PosTransLine."Deal Line" and not (PosTransLine."Entry Type" = PosTransLine."Entry Type"::FreeText) then
                        tmpText := ''
                    else
                        tmpText := Globals.FormatPrice(PosTransLine.Price);
                    exit(true);
                end;
        end;
    end;

    procedure NotUsedCouponsCheckInputNeeded(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        NotUsedCouponsTEMP: Record "LSC POS Trans. Line" temporary;
        POSTransLineCpn: Record "LSC POS Trans. Line";
    begin
        if POSTransaction."Entry Status" = POSTransaction."Entry Status"::Voided then
            exit(false);

        NotUsedCouponsTEMP.Reset;
        NotUsedCouponsTEMP.DeleteAll;
        POSTransLineCpn.Reset;
        POSTransLineCpn.SetRange("Receipt No.", POSTransaction."Receipt No.");
        if POSTransLineCpn.FindSet then
            repeat
                if (POSTransLineCpn."Entry Status" = POSTransLineCpn."Entry Status"::" ") and
                   (POSTransLineCpn."Coupon Function" = POSTransLineCpn."Coupon Function"::Use) and
                   (POSTransLineCpn."Coupon Code" <> '') and
                   (POSTransLineCpn."Entry Type" in [POSTransLineCpn."Entry Type"::Coupon, POSTransLineCpn."Entry Type"::Payment]) and
                   (not POSTransLineCpn."Valid in Transaction")
                then begin
                    NotUsedCouponsTEMP := POSTransLineCpn;
                    NotUsedCouponsTEMP.Insert;
                end;
            until POSTransLineCpn.Next = 0;
        if NotUsedCouponsTEMP.FindSet then begin
            // if POSFunctionalityProfile.Get(POSTransPostingStateTmp."POS Functionality Profile ID") then;
            // repeat
            //     CouponResetReservation(NotUsedCouponsTEMP, POSFunctionalityProfile);
            // until NotUsedCouponsTEMP.Next = 0;
            CouponsNotUsedLookup(NotUsedCouponsTEMP);
            exit(true);
        end;
        exit(false);
    end;

    local procedure CouponsNotUsedLookup(var pTmpPosTransLine: Record "LSC POS Trans. Line" temporary)
    var
        POSLookup: Record "LSC POS Lookup";
        POSGUI: Codeunit "LSC POS GUI";
        POSSESSION: Codeunit "LSC POS Session";
        RecRef: RecordRef;
        IsHandled: Boolean;
        FormID: Code[10];
        Text072: Label 'No Coupons to Display';
        Text073: Label 'Entered Coupons but not used';
    begin
        if pTmpPosTransLine.Count = 0 then
            exit;

        FormID := 'NOTUSEDCOU';
        POSLookup.Reset;
        if not POSSESSION.GetPosLookupRec(FormID, POSLookup) then
            exit;
        RecRef.GetTable(pTmpPosTransLine);
        POSLookup."Start Message" := Text073;
        POSLookup.Description := 'Unused Coupons';
        POSGUI.Lookup(POSLookup, '#NOTUSEDCOUPONS_NT', pTmpPosTransLine, POSSESSION.MgrKey, '', RecRef);
    end;

    procedure SetCouponJournalLineColor(var pRecRef: RecordRef; var JournalFont: Code[20]; var JournalSkin: Code[20])
    var
        GenSetup: Record "eCom_General Setup_NT";
        PosTransLine: Record "LSC POS Trans. Line";
        RecRef_l: RecordRef;
    begin
        if GenSetup.Get() then
            if (GenSetup."Journal Line Coupon Font" <> '') and (GenSetup."Journal Line Coupon Skin" <> '') then begin
                RecRef_l := pRecRef.Duplicate;
                RecRef_l.SetTable(PosTransLine);
                if PosTransLine."Entry Status" <> PosTransLine."Entry Status"::Voided then
                    if (PosTransLine."Entry Type" = PosTransLine."Entry Type"::Coupon) and (PosTransLine."Coupon Code" <> '') then begin
                        JournalFont := GenSetup."Journal Line Coupon Font";
                        JournalSkin := GenSetup."Journal Line Coupon Skin";
                    end;
            end;
    end;

    procedure MUltiplyIncExp(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var PaymentAmt: Decimal; var MultiplyWith: Decimal)
    var
        myInt: Integer;
    begin
        if MultiplyWith = 0 then
            exit;
        POSTransLine.Price := PaymentAmt;
        PaymentAmt := MultiplyWith * PaymentAmt;
        MultiplyWith := 1;
    end;

    procedure OnBeforeLookupCall_ProcessLookUpData(var LookupSetup: Record "LSC POS Lookup"; var PosTransLine: Record "LSC POS Trans. Line"; MgrKey: Boolean; CustomerNo: Code[20]; ExecuteCommand: Boolean; FormID: Code[20]; Filter: Code[29]; var LookupRecRef: RecordRef; var IsHandled: Boolean)
    var
        FuncProfile: Record "LSC POS Func. Profile";
        POSTransactionSuspendTEMP: Record "LSC POS Transaction" temporary;
        TempTransSales: Record "LSC Trans. Sales Entry" temporary;
        TransHeader: Record "LSC Transaction Header";
        TransSales: Record "LSC Trans. Sales Entry";
        EPosCtrl: Codeunit "LSC POS Control Interface";
        GetPosTransSuspListUtils: Codeunit LSCGetPosTransSuspListUtils;
        POSGUI: Codeunit "LSC POS GUI";
        POSSession: codeunit "LSC POS Session";
        FieldRef: FieldRef;
        TransRef: RecordRef;
        RecordIDLoc: RecordId;
        ResponseCode: Code[30];
        ErrorText: Text;
    begin
        CAse FormID of
            'SUSPEND':
                begin
                    FuncProfile.Get(POSSession.FunctionalityProfileID());
                    if FuncProfile."TS Susp./Retrieve" then begin
                        GetPosTransSuspListUtils.SetPosFunctionalityProfile(FuncProfile."Profile ID");
                        GetPosTransSuspListUtils.SendRequest(POSSession.StoreNo(), ResponseCode, ErrorText, POSTransactionSuspendTEMP);
                        //GetPosTransSuspListUtils.SetCommunicationError(ResponseCode, ErrorText);
                        SetCommunicationError(ResponseCode, ErrorText);
                        POSTransactionSuspendTEMP.Reset();
                        if ErrorText = '' then begin
                            LookupRecRef.Open(Database::"LSC POS Transaction", true);
                            LookupRecRef.GetTable(POSTransactionSuspendTEMP);
                        end;
                    end;
                end;
            'SALESENTRY':
                begin
                    if EPosCtrl.GetActiveLookupRecordID(RecordIDLoc) then begin
                        TransRef.Get(RecordIDLoc);
                        TransRef.SetTable(TransHeader);
                        TransSales.SetRange("Store No.", TransHeader."Store No.");
                        TransSales.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
                        TransSales.SetRange("Transaction No.", TransHeader."Transaction No.");
                        if TransSales.FindSet() then
                            repeat
                                TempTransSales.Init();
                                TempTransSales := TransSales;
                                TempTransSales.Insert();
                            until TransSales.Next() = 0;
                        LookupRecRef.Open(Database::"LSC Trans. Sales Entry", true);
                        LookupRecRef.GetTable(TempTransSales);
                    end;
                end;
        end;
    end;

    procedure SetCommunicationError(ResponseCode: Code[30]; ErrorText: Text)
    var
        POSSession: Codeunit "LSC POS Session";
    begin
        if ResponseCode in ['0098', '0099'] then
            POSSession.SetValue("LSC POS Tag"::"TS_ERROR", CopyStr(ErrorText, 1, 250))
        else
            POSSession.SetValue("LSC POS Tag"::"TS_ERROR", '');
    end;

    procedure UpdateNegAdjStateTxt2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        POSFuncProfile: Record "LSC POS Func. Profile";
        POSSESSION: Codeunit "LSC POS Session";
        POSView: Codeunit "LSC POS View";
        StateTxt2: text;
    begin
        StateTxt2 := POSView.GetPosStateTxt2();
        if StateTxt2 <> '' then
            exit;
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID);
        IF not PosFuncProfile."Watermark on Negative Adj." THEN
            exit;
        StateTxt2 := GetStateTxt2Tag(POSTransaction);
        POSSESSION.SetValue("LSC POS Tag"::"StateTxt2", StateTxt2);
        //TRANING TAG Needs to be set to display Water mark on POS Journal Grid
        POSSESSION.SetValue("LSC POS Tag"::TRAINING_STATUS, StateTxt2);
    end;

    local procedure GetStateTxt2Tag(var POSTransaction: Record "LSC POS Transaction"): Text
    var
        InfoSubcode: Record "LSC Information Subcode";
        POSTransInfoEntry: Record "LSc POS Trans. Infocode Entry";
        POSSESSION: Codeunit "LSC POS Session";
    begin
        if POSTransaction."Transaction Type" = POSTransaction."Transaction Type"::NegAdj then begin
            if POSTransInfoEntry.GET(POSTransaction."Receipt No.",
               POSTransInfoEntry."Transaction Type"::Header, 0, 'TRANSOUT', 0) then
                if POSTransInfoEntry."Type of Input" = POSTransInfoEntry."Type of Input"::SubCode then
                    if InfoSubcode.GET(POSTransInfoEntry.Infocode, POSTransInfoEntry.Subcode) then
                        exit('TRANSFER ' + UPPERCASE(InfoSubcode.Description));
            exit('TRANSFER');
        end else
            exit('');
    end;

    procedure FilterProcessOrderEntryAndSetStepValue(var ProcessOrderEntry: Record "LSC Member Process Order Entry")
    var
        SchJobHdr: Record "LSC Scheduler Job Header";
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        BlankDateFormula: DateFormula;
    begin
        SchJobHdr.SetRange("Object Type", SchJobHdr."Object Type"::Codeunit);
        SchJobHdr.SetRange("Object No.", Codeunit::"LSC Member Posting Utils");
        if SchJobHdr.FindFirst() then begin
            if SchJobHdr.DateFormula <> BlankDateFormula then
                ProcessOrderEntry.SetRange(Date, CalcDate(SchJobHdr.DateFormula, Today), Today);
            PosGenUtil.SetSchJobStepValue(SchJobHdr.Integer);
        end;
        UpdateAccNoForBlockedMemCards();
    end;

    procedure ProcessMemOrderEntry(var ProcessOrderEntry: Record "LSC Member Process Order Entry"; var IsHandled: Boolean)
    var
        PosGenUtil: Codeunit "Pos_General Utility_NT";
        ProcOrderEntryStepVal: Integer;
        SchJobStepVal: Integer;
    begin
        SchJobStepVal := PosGenUtil.GetStepValue();
        ProcOrderEntryStepVal := PosGenUtil.GetProcOrderEntryStepVal();
        if SchJobStepVal = 0 then begin
            IsHandled := true;
            exit;
        end;

        if ProcOrderEntryStepVal > SchJobStepVal then begin
            IsHandled := true;
            PosGenUtil.InitStepValues();
            PosGenUtil.BlockMemberAcc();
            exit;
        end;
        ProcOrderEntryStepVal += 1;
        PosGenUtil.UnBlockMemberAcc(ProcessOrderEntry."Account No.");
        if ProcessOrderEntry."Document Source" <> ProcessOrderEntry."Document Source"::POS then
            ProcessEntry(ProcessOrderEntry);
        PosGenUtil.SetProcOrderEntryStepVal(ProcOrderEntryStepVal);
    end;

    local procedure ProcessEntry(ProcessOrderEntry: Record "LSC Member Process Order Entry")
    var
        MemberPointJnlLine: Record "LSC Member Point Jnl. Line";
        ProcessOrderEntry2: Record "LSC Member Process Order Entry";
        PointJnlPostLine: Codeunit "LSC Point Jnl.-Post Line";
    begin
        Clear(MemberPointJnlLine);
        if ProcessOrderEntry."Points in Transaction" < 0 then
            MemberPointJnlLine.Type := MemberPointJnlLine.Type::Redemption
        else
            MemberPointJnlLine.Type := MemberPointJnlLine.Type::"Pos. Adjustment";
        if ProcessOrderEntry."Card No." <> '' then
            MemberPointJnlLine.Validate("Card No.", ProcessOrderEntry."Card No.")
        else
            MemberPointJnlLine.Validate("Account No.", ProcessOrderEntry."Account No.");
        MemberPointJnlLine.Date := Today;
        //IF AllowNegative THEN
        //   MemberPointJnlLine.SetAllowNegativeBalance;
        MemberPointJnlLine.Validate(Points, Abs(ProcessOrderEntry."Points in Transaction"));
        MemberPointJnlLine."Store No." := ProcessOrderEntry."Store No.";
        MemberPointJnlLine."POS Terminal No." := ProcessOrderEntry."POS Terminal No.";
        MemberPointJnlLine."Document No." := ProcessOrderEntry."Document No.";
        //IF AllowNegative THEN
        //    PointJnlPostLine.SetAllowNegativeBalance;
        PointJnlPostLine.Run(MemberPointJnlLine);
        ProcessOrderEntry2.Get(ProcessOrderEntry."Document Source", ProcessOrderEntry."Store No.", ProcessOrderEntry."POS Terminal No.", ProcessOrderEntry."Transaction No.");
        ProcessOrderEntry2."Date Processed" := Today;
        ProcessOrderEntry2."Time Processed" := Time;
        ProcessOrderEntry2.Modify();
    end;

    local procedure UpdateAccNoForBlockedMemCards()
    var
        MembershipCard: Record "LSC Membership Card";
        ProcessOrderEntryRec: Record "LSC Member Process Order Entry";
        TransHeader: Record "LSC Transaction Header";
    begin
        ProcessOrderEntryRec.SetCurrentKey("Date Processed");
        ProcessOrderEntryRec.SetRange("Date Processed", 0D);
        if ProcessOrderEntryRec.FindSet() then
            repeat
                if ProcessOrderEntryRec."Account No." = '' then
                    if TransHeader.Get(ProcessOrderEntryRec."Store No.", ProcessOrderEntryRec."POS Terminal No.", ProcessOrderEntryRec."Transaction No.") THEN
                        if MembershipCard.Get(TransHeader."Member Card No.") then begin
                            ProcessOrderEntryRec.Validate("Account No.", MembershipCard."Account No.");
                            ProcessOrderEntryRec.Modify();
                        end;
            until ProcessOrderEntryRec.Next() = 0;
    end;

    procedure EmployeeBarcodeScanned(CurrInput: Text): Boolean
    var
        BarcodeMask: Record "LSC Barcode Mask";
        GenPOSFunction: Record "LSC POS Func. Profile";
        BcUtil: Codeunit "LSC Barcode Management";
        POSFunctions: Codeunit "LSC POS Functions";
        POSGui: Codeunit "LSC POS GUI";
        POSSession: Codeunit "LSC POS Session";
    begin
        if BcUtil.FindBarcodeMask(CurrInput, BarcodeMask) then begin
            case BarcodeMask.Type of
                BarcodeMask.Type::Employee:
                    begin
                        GenPOSFunction.Get(POSSession.GetValue("LSC POS Tag"::"LSFUNCPROFILE"));
                        if GenPOSFunction."Staff Barcode Logon" then begin
                            CurrInput := POSFunctions.GetBarcStaff(CopyStr(CurrInput, 1, 22), BarcodeMask);
                            exit(CurrInput <> '');
                        end;
                    end;
            end;
        end;
        exit(false);
    end;

    procedure CompressLine(var Rec: Record "LSC POS Trans. Line")
    var
        POSTransLine: Record "LSC POS Trans. Line";
        POSTransInfocodeEntry: Record "LSC POS Trans. Infocode Entry";
        POSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";
        lBarcodes: Record "LSC Barcodes";
        OfferPosCalc: Record "LSC Offer Pos Calculation";
        PeriodicDiscount: Record "LSC Periodic Discount";
        KDSFunctions: Codeunit "LSC KDS Functions";
        //SendToKDS: Codeunit "LSC Send to KDS"; //LS Internal
        PosPrice: Codeunit "LSC POS Price Utility";
        PosFunc: Codeunit "LSC POS Functions";
        Header: Record "LSC POS Transaction";
        LastPeriodicDiscountCode: Code[20];
        Qty, QtyNotSent : Decimal;
        CompressOK, OnlyOnePeriodicDiscountEffecti, IsHandled : Boolean;
    begin
        // OnBeforeCompressLine(Rec, IsHandled);
        // if IsHandled then
        //     exit;

        OnlyOnePeriodicDiscountEffecti := false;
        if Header."Receipt No." <> Rec."Receipt No." then
            Header.Get(Rec."Receipt No.");

        if Rec."Discount Triggered" then begin
            LastPeriodicDiscountCode := '';
            OnlyOnePeriodicDiscountEffecti := true;
            POSTransPeriodicDisc.Reset;
            POSTransPeriodicDisc.SetRange("Receipt No.", Rec."Receipt No.");
            POSTransPeriodicDisc.SetRange("Line No.", Rec."Line No.");
            PosFunc.PosTransDiscSetTableFilter(1, POSTransPeriodicDisc);
            if PosFunc.PosTransDiscFindSetRec(1, POSTransPeriodicDisc) then
                repeat
                    if POSTransPeriodicDisc.DiscType = POSTransPeriodicDisc.DiscType::"Periodic Disc." then begin
                        if LastPeriodicDiscountCode = '' then
                            LastPeriodicDiscountCode := POSTransPeriodicDisc."Periodic Disc. Group";
                        if POSTransPeriodicDisc."Periodic Disc. Group" <> LastPeriodicDiscountCode then
                            OnlyOnePeriodicDiscountEffecti := false;
                    end else
                        OnlyOnePeriodicDiscountEffecti := false;
                until (PosFunc.PosTransDiscNextRec(1, 1, POSTransPeriodicDisc) = 0) or (not OnlyOnePeriodicDiscountEffecti);

            if LastPeriodicDiscountCode <> '' then
                PeriodicDiscount.Get(LastPeriodicDiscountCode);
        end;

        //if PosFuncProfile."Compress When Scanned" and
        if (Rec."Entry Type" = Rec."Entry Type"::Item) and
         not Rec."Price in Barcode" and
         not Rec."Scale Item" and
         (Rec."Serial No." = '') and
         (Rec."Journal Compression" = Rec."Journal Compression"::Allowed) and
         (Rec."Lot No." = '')
      then begin
            CompressOK := true;
            if Rec."Barcode No." <> '' then
                if lBarcodes.Get(Rec."Barcode No.") then
                    if lBarcodes."Discount %" <> 0 then
                        CompressOK := false;
            if CompressOK then begin
                InsertDefaultMenuType(true, Rec);
                POSTransLine.SetCurrentKey("Receipt No.", "Entry Type", Number, "Variant Code");
                POSTransLine.SetRange("Receipt No.", Rec."Receipt No.");
                POSTransLine.SetRange("Entry Type", Rec."Entry Type"::Item);
                POSTransLine.SetRange(Number, Rec.Number);
                POSTransLine.SetRange("Variant Code", Rec."Variant Code");
                POSTransLine.SetRange("Unit of Measure", Rec."Unit of Measure");
                POSTransLine.SetRange("Entry Status", Rec."Entry Status"::" ");
                POSTransLine.SetRange("Guest/Seat No.", Rec."Guest/Seat No.");
                POSTransLine.SetRange("Sales Staff", Rec."Sales Staff");
                POSTransLine.SetRange("Price Override", false);
                POSTransLine.SetRange("Price Change", false);
                POSTransLine.SetRange("Sales Type", Rec."Sales Type");
                POSTransLine.SetRange("Restaurant Menu Type", Rec."Restaurant Menu Type");
                POSTransLine.SetRange("Price Group Code", Rec."Price Group Code");
                POSTransLine.SetRange("Orig. of a Linked Item List", false);

                if Rec."Discount Triggered" and OnlyOnePeriodicDiscountEffecti then
                    POSTransLine.SetRange("Discount Triggered")
                else
                    POSTransLine.SetRange("Discount Triggered", false);

                if Rec."Linked No. not Orig." then
                    POSTransLine.SetRange("Parent Line", Rec."Parent Line")
                else
                    if Rec."Line No." <> Rec."Parent Line" then
                        POSTransLine.SetRange("Parent Line", Rec."Parent Line")
                    else
                        POSTransLine.SetRange("Parent Line");

                POSTransLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
                if POSTransLine.FindSet then
                    repeat
                        CompressOK := true;
                        POSTransInfocodeEntry.SetRange("Receipt No.", Rec."Receipt No.");
                        POSTransInfocodeEntry.SetRange("Transaction Type", POSTransInfocodeEntry."Transaction Type"::"Sales Entry");
                        POSTransInfocodeEntry.SetRange("Line No.", POSTransLine."Line No.");
                        if POSTransLine."Parent Compression" = POSTransLine."Parent Compression"::OK then
                            POSTransInfocodeEntry.SetFilter("Entry Trigger Function", '<>%1', POSTransInfocodeEntry."Entry Trigger Function"::Item);

                        if not POSTransInfocodeEntry.FindFirst then begin
                            if not Rec."Linked No. not Orig." then begin  //new item is main item
                                if POSTransLine."Line No." = POSTransLine."Parent Line" then begin
                                    POSTransLine.CalcFields("Lines where Line is Parent");
                                    if POSTransLine."Lines where Line is Parent" > 1 then
                                        if POSTransLine."Parent Compression" <> POSTransLine."Parent Compression"::OK then
                                            CompressOK := false;
                                end;
                            end;
                            if CompressOK then
                                //if PosPrice.IsPosTransLineBlockedByOffer(POSTransLine, Enum::"LSC Discount Blocking Type"::InfoCode) then
                                if IsPosTransLineBlockedByOffer(POSTransLine, Enum::"LSC Discount Blocking Type"::InfoCode) then
                                    CompressOK := false;

                            if CompressOK then
                                if KDSFunctions.TransLineSentToKitchen(Header, POSTransLine, QtyNotSent) then
                                    compressok := false;

                            if CompressOK then
                                if Rec."Discount Triggered" and OnlyOnePeriodicDiscountEffecti then
                                    CompressOK := CheckDiscountLimit(PeriodicDiscount, POSTransLine.Quantity, Rec);

                            // OnBeforeCompressOKCompressLine(Rec, POSTransLine, CompressOK);
                            if CompressOK then begin
                                Qty := Rec.Quantity;

                                OfferPosCalc.SetRange("Receipt No.", Rec."Receipt No.");
                                OfferPosCalc.SetRange("Trans. Line No.", Rec."Line No.");
                                OfferPosCalc.DeleteAll;

                                Rec.Delete(true);
                                //SendToKDS.DeleteKDSRouting(rec);
                                DeleteKDSRouting(rec);

                                PosFunc.ClearPosTransLineOffers(Rec);

                                POSTransPeriodicDisc.Reset;
                                POSTransPeriodicDisc.SetRange("Receipt No.", Rec."Receipt No.");
                                POSTransPeriodicDisc.SetRange("Line No.", Rec."Line No.");
                                PosFunc.PosTransDiscSetTableFilter(1, POSTransPeriodicDisc);
                                PosFunc.PosTransDiscDeleteAllRec(1);

                                POSTransLine.Validate(Quantity, POSTransLine.Quantity + Qty);

                                if POSTransLine."Discount Triggered" and OnlyOnePeriodicDiscountEffecti then
                                    POSTransLine.CalcPrices;

                                Rec := POSTransLine;
                                exit;
                            end;
                        end;
                    until POSTransLine.Next = 0;
            end;
        end;
    end;

    local procedure InsertDefaultMenuType(BeforeCompress: Boolean; var Rec: Record "LSC POS Trans. Line")
    var
        DefaultRestaurantMenuType: Record "LSC Default Rest Menu Type";
        HospType: Record "LSC Hospitality Type";
        Header: Record "LSC POS Transaction";
    begin
        if Header."Receipt No." <> Rec."Receipt No." then
            Header.Get(Rec."Receipt No.");

        if (Rec."Restaurant Menu Type" <> 0) and (not Rec."Deal Line") then
            exit;

        if Header."Hosp. Type Sequence" = 0 then
            exit;
        if not HospType.Get(Header."Store No.", Header."Hosp. Type Sequence", Header."Sales Type") then
            exit;
        if HospType."Menu Type Usage" = HospType."Menu Type Usage"::No then
            exit;
        if Rec."Deal Line" then
            //if DefaultRestaurantMenuType.MenuTypeDecidedbyDeal(HospType, Rec."Promotion No.", Rec."Store No.") then
            if MenuTypeDecidedbyDeal(HospType, Rec."Promotion No.", Rec."Store No.") then
                exit;
        //DefaultRestaurantMenuType.GetItemDefaultMenuType(Rec.Number, Rec."Retail Product Code", Rec."Restaurant Menu Type", Rec."Restaurant Menu Type Code", Rec."Store No.", BeforeCompress, Rec."Item Category Code");
        GetItemDefaultMenuType(Rec.Number, Rec."Retail Product Code", Rec."Restaurant Menu Type", Rec."Restaurant Menu Type Code", Rec."Store No.", BeforeCompress, Rec."Item Category Code");
    end;

    local procedure MenuTypeDecidedbyDeal(HospType: Record "LSC Hospitality Type"; PromotionNo: Code[20]; StoreNo: Code[10]): Boolean
    var
        DefaultRestaurantMenuType: Record "LSC Default Rest Menu Type";
    begin
        if (HospType."Menu Type Deal Usage" <> HospType."Menu Type Deal Usage"::No) then begin
            DefaultRestaurantMenuType.SetRange(Type, DefaultRestaurantMenuType.Type::Deal);
            DefaultRestaurantMenuType.SetRange("No.", PromotionNo);
            DefaultRestaurantMenuType.SetRange("Restaurant No.", StoreNo);
            if not DefaultRestaurantMenuType.IsEmpty then
                exit(true);
        end;
        exit(false);
    end;

    local procedure GetItemDefaultMenuType(ItemNo: Code[20]; ProductGroupCode: Code[20]; var MenuType: Integer; var CodeOnPOS: Code[10]; StoreNo: Code[10]; BeforeCompress: Boolean)
    begin
        GetItemDefaultMenuType(ItemNo, ProductGroupCode, MenuType, CodeOnPOS, StoreNo, BeforeCompress, '');
    end;

    local procedure GetItemDefaultMenuType(ItemNo: Code[20]; ProductGroupCode: Code[20]; var MenuType: Integer; var CodeOnPOS: Code[10]; StoreNo: Code[10]; BeforeCompress: Boolean; ItemCategoryCode: code[20])
    var
        DefaultRestaurantMenuType: Record "LSC Default Rest Menu Type";
        IsDefaultMenuType: Boolean;
    begin
        IsDefaultMenuType := false;
        MenuType := 0;
        CodeOnPOS := '';
        DefaultRestaurantMenuType.SetRange(Type, DefaultRestaurantMenuType.Type::Item);
        DefaultRestaurantMenuType.SetRange("No.", ItemNo);
        DefaultRestaurantMenuType.SetRange("Restaurant No.", StoreNo);
        if DefaultRestaurantMenuType.FindFirst then
            IsDefaultMenuType := true
        else begin
            DefaultRestaurantMenuType.SetRange(Type, DefaultRestaurantMenuType.Type::"Product Group");
            DefaultRestaurantMenuType.SetRange("No.", ProductGroupCode);
            DefaultRestaurantMenuType.SetRange("Restaurant No.", StoreNo);
            if DefaultRestaurantMenuType.FindFirst then
                IsDefaultMenuType := true
            else begin
                DefaultRestaurantMenuType.SetRange(Type, DefaultRestaurantMenuType.Type::"Item Category");
                DefaultRestaurantMenuType.SetRange("No.", ItemCategoryCode);
                DefaultRestaurantMenuType.SetRange("Restaurant No.", StoreNo);
                if DefaultRestaurantMenuType.FindFirst then
                    IsDefaultMenuType := true;
            end;
        end;
        if BeforeCompress then begin
            DefaultRestaurantMenuType.CalcFields("Compress Menu Type");
            if not DefaultRestaurantMenuType."Compress Menu Type" then
                IsDefaultMenuType := false;
        end;
        if IsDefaultMenuType then begin
            MenuType := DefaultRestaurantMenuType."Menu Type Order";
            DefaultRestaurantMenuType.CalcFields("Code on POS");
            CodeOnPOS := DefaultRestaurantMenuType."Code on POS";
        end;
    end;

    local procedure IsPosTransLineBlockedByOffer(var POSTransLine: Record "LSC POS Trans. Line"; DiscountBlockingType: enum "LSC Discount Blocking Type"): Boolean
    var
        POSTransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
        LineIsBlocked: Boolean;
        PosFunctions: Codeunit "LSC POS Functions";
    begin
        LineIsBlocked := false;

        if POSTransLine."Deal Line" then
            case DiscountBlockingType of
                DiscountBlockingType::ManualPrice:
                    LineIsBlocked := true;
                DiscountBlockingType::LineDiscOffer:
                    LineIsBlocked := true;
            end;

        if not LineIsBlocked then begin
            POSTransPerDisc.Reset;
            POSTransPerDisc.SetRange("Receipt No.", POSTransLine."Receipt No.");
            POSTransPerDisc.SetRange("Line No.", POSTransLine."Line No.");
            POSTransPerDisc.SetRange("Entry Status", POSTransPerDisc."Entry Status"::" ");
            PosFunctions.PosTransDiscSetTableFilter(4, POSTransPerDisc);
            if PosFunctions.PosTransDiscFindRec(4, '-', POSTransPerDisc) then
                repeat
                    case DiscountBlockingType of
                        DiscountBlockingType::ManualPrice:
                            LineIsBlocked := POSTransPerDisc."Block Manual Price Change";
                        DiscountBlockingType::LineDiscOffer:
                            LineIsBlocked := POSTransPerDisc."Block Line Discount Offer";
                        DiscountBlockingType::TotalDiscOffer:
                            LineIsBlocked := POSTransPerDisc."Block Total Discount Offer";
                        DiscountBlockingType::TenderTypeDisc:
                            LineIsBlocked := POSTransPerDisc."Block Tender Type Discount";
                        DiscountBlockingType::MemberPoints:
                            LineIsBlocked := POSTransPerDisc."Block Loyalty Points";
                        DiscountBlockingType::InfoCode:
                            LineIsBlocked := POSTransPerDisc."Block Infocode Discount";
                    end;
                until (PosFunctions.PosTransDiscNextRec(4, 1, POSTransPerDisc) = 0) or (LineIsBlocked);
        end;
    end;

    local procedure CheckDiscountLimit(PeriodicDiscount: Record "LSC Periodic Discount"; ExistingLineQTY: Decimal; Rec: Record "LSC POS Trans. Line"): Boolean
    var
        PeriodicDiscountLine: Record "LSC Periodic Discount Line";
        MixMatchLineGroups: Record "LSC Mix & Match Line Groups";
        MaxQty: Decimal;
    begin
        PeriodicDiscountLine.SetRange("Offer No.", PeriodicDiscount."No.");
        PeriodicDiscountLine.SetRange(Type, PeriodicDiscountLine.Type::Item);
        PeriodicDiscountLine.SetRange("No.", Rec.Number);
        PeriodicDiscountLine.SetRange("Variant Code", Rec."Variant Code");
        PeriodicDiscountLine.SetRange("Unit of Measure", Rec."Unit of Measure");
        PeriodicDiscountLine.SetFilter("Line Group", '<>%1', '');
        if not PeriodicDiscountLine.FindFirst() then
            exit(true);

        if not MixMatchLineGroups.Get(PeriodicDiscountLine."Offer No.", PeriodicDiscountLine."Line Group") then
            exit(true);

        if MixMatchLineGroups."Line Group Type" = MixMatchLineGroups."Line Group Type"::"No. of Lines" then
            MaxQty := MixMatchLineGroups."Value 1"
        else
            MaxQty := MixMatchLineGroups."Value 2";

        if MaxQty > ExistingLineQTY then
            Exit(true);

        exit(false)
    end;

    local procedure DeleteKDSRouting(PosTransLine: Record "LSC POS Trans. Line"): Boolean
    var
        PosTrLineDisplStatRouting: Record "LSC POS Tr. Line Dis. Stat. R.";
    begin
        if PosTransLine."Kitchen Routing" <> PosTransLine."Kitchen Routing"::Yes then
            exit(false);

        PosTrLineDisplStatRouting.Reset;
        PosTrLineDisplStatRouting.SetRange("Receipt No.", PosTransLine."Receipt No.");
        PosTrLineDisplStatRouting.SetRange("Pos Trans. Line No.", PosTransLine."Line No.");
        if not PosTrLineDisplStatRouting.IsEmpty then begin
            PosTrLineDisplStatRouting.DeleteAll;
            exit(true);
        end;
        exit(false);
    end;
    
    var
        MmMembTmp: Codeunit "LSC POS Price Functions";
        MmOfferList: Codeunit "LSC POS Price Functions";
        MmTmp: Codeunit "LSC POS Price Functions";
        RetailPriceUtils: Codeunit "LSC Retail Price Utils";
        LastItemUpd: Code[20];
        DiffCount: Integer;
        DiffList: array[250] of Integer;
        LineList: array[250] of Integer;
        Text007: Label 'According to the Barcode Mask, element no. %1 is %2, but the length of the segment is %3. It must be 6 characters long.';
        Text021: Label 'Barcode Mask missing in Coupon Header %1.';
        Text022: Label 'Coupon Barcode Mask %1 not found. See Coupon Header %2.';
        Text023: Label 'Coupon %1 %2 is only valid for members in %3 %4.';    
}
