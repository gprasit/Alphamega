codeunit 60115 MA_GetDirectMarketingInfo_NT
{
#if __IS_SAAS__
    Access = Internal;
#endif
    trigger OnRun()
    begin
        RunRequest;
    end;

    var
        SessionKeyValues_g: Codeunit "LSC Session Key Values";
        ErrorText_g: Text;
        CardID_g: Text[100];
        ItemNo_g: Code[20];
        StoreNo_g: Code[10];
        POSFunctionalityProfileCode_g: Code[10];
        PublishedOfferTemp_g: Record "LSC Published Offer" temporary;
        PublishedOfferImagesTemp_g: Record "LSC Retail Image Link" temporary;
        PublishedOfferDetailLineTemp_g: Record "LSC Published Offer Detail Ln" temporary;
        PublishedOfferDetailLineImagesTemp_g: Record "LSC Retail Image Link" temporary;
        MemberCouponBufferTemp_g: Record "LSC Member Coupon Buffer" temporary;
        MemberNotificationTemp_g: Record "LSC Member Notification" temporary;
        MemberNotificationImagesTemp_g: Record "LSC Retail Image Link" temporary;
        PublishedOfferLineBufferTemp_g: Record "LSC Published Offer Line Buff" temporary;

    local procedure RunRequest()
    var
        Store: Record "LSC Store";
        lText001: Label 'Card No. not found.';
        lText002: Label 'Item No. not found.';
        Item: Record Item;
        MembershipCard: Record "LSC Membership Card";
        OfferUtils: Codeunit "MA_Offer Utils_NT";
        lText003: Label 'Store No. not found.';
    begin
        if CardID_g <> '' then
            if not MembershipCard.Get(CardID_g) then begin
                ErrorText_g := lText001;
                exit;
            end;

        if ItemNo_g <> '' then
            if not Item.Get(ItemNo_g) then begin
                ErrorText_g := lText002;
                exit;
            end;

        if StoreNo_g <> '' then
            if not Store.Get(StoreNo_g) then begin
                ErrorText_g := lText003;
                exit;
            end;

        OfferUtils.GetMemberDirMarkInfo(CardID_g, UpperCase(ItemNo_g), UpperCase(StoreNo_g), PublishedOfferTemp_g,
        PublishedOfferImagesTemp_g, PublishedOfferDetailLineTemp_g, PublishedOfferDetailLineImagesTemp_g,
        MemberCouponBufferTemp_g, MemberNotificationTemp_g, MemberNotificationImagesTemp_g, PublishedOfferLineBufferTemp_g);
    end;

    procedure SetRequest(CardID: Text[100]; ItemNo: Code[20]; StoreNo: Code[10])
    begin
        CardID_g := CardID;
        StoreNo_g := StoreNo;
        ItemNo_g := ItemNo;
    end;

    procedure SendRequest(CardID: Text[100]; ItemNo: Code[20]; StoreNo: Code[10]; var PublishedOfferTemp: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp: Record "LSC Retail Image Link" temporary; var MemberCouponBufferTemp: Record "LSC Member Coupon Buffer" temporary; var MemberNotificationTemp: Record "LSC Member Notification" temporary; var MemberNotificationImagesTemp: Record "LSC Retail Image Link" temporary; var PublishedOfferLineBufferTemp: Record "LSC Published Offer Line Buff" temporary; var ResponseCode: Code[30]; var ErrorText: Text)
    var
        WSServerBuffer: Record "LSC WS Server Buffer" temporary;
        LoadMemberDirMarkInfo: Codeunit LSCGetDirectMarketingInfo;
        RequestHandler: Codeunit "LSC Request Handler";
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
        GetDirectMarketingInfoXML: XmlPort LSCGetDirectMarketingInfoXML;
        RequestOk: Boolean;
        ReqDateTime: DateTime;
        LogFileID: Text;
        URIMissingTxt: Label 'Web Server URI is Missing for Request %1';
    begin
        RequestOk := false;
        ReqDateTime := CurrentDateTime;
        LogFileID := WebRequestFunctions.CreateLogFileID(ReqDateTime);
        RequestHandler.GetWebServerList(format(enum::"LSC Web Services"::GetDirectMarketingInfo), POSFunctionalityProfileCode_g, WSServerBuffer);
        WSServerBuffer.Reset;
        if WSServerBuffer.FindSet then
            repeat
                if WSServerBuffer."Local Request" then begin
                    Clear(GetDirectMarketingInfoXML);
                    GetDirectMarketingInfoXML.SetLoadMemberDirMarketInfo(PublishedOfferTemp, PublishedOfferImagesTemp, PublishedOfferDetailLineTemp,
                    PublishedOfferDetailLineImagesTemp, MemberCouponBufferTemp, MemberNotificationTemp, MemberNotificationImagesTemp, PublishedOfferLineBufferTemp);
                    GetDirectMarketingInfoXML.Export;
                    Commit;
                    SessionKeyValues_g.SetValue('#LOCALREQUEST', 'TRUE');
                    LoadMemberDirMarkInfo.GetDirectMarketingInfo(CardID, ItemNo, StoreNo, GetDirectMarketingInfoXML, ResponseCode, ErrorText);
                    SessionKeyValues_g.DeleteValue('#LOCALREQUEST');
                    WebRequestFunctions.ClearTable(PublishedOfferTemp);
                    WebRequestFunctions.ClearTable(PublishedOfferImagesTemp);
                    WebRequestFunctions.ClearTable(PublishedOfferDetailLineTemp);
                    WebRequestFunctions.ClearTable(PublishedOfferDetailLineImagesTemp);
                    WebRequestFunctions.ClearTable(MemberCouponBufferTemp);
                    WebRequestFunctions.ClearTable(MemberNotificationTemp);
                    WebRequestFunctions.ClearTable(MemberNotificationImagesTemp);
                    WebRequestFunctions.ClearTable(PublishedOfferLineBufferTemp);
                    GetDirectMarketingInfoXML.GetLoadMemberDirMarketInfo(PublishedOfferTemp, PublishedOfferImagesTemp, PublishedOfferDetailLineTemp,
                    PublishedOfferDetailLineImagesTemp, MemberCouponBufferTemp, MemberNotificationTemp, MemberNotificationImagesTemp, PublishedOfferLineBufferTemp);
                    RequestOk := true;
                    RequestHandler.AddToConnLog(WSServerBuffer."Profile ID", 'Local', 'Local', '');
                end else begin
                    RequestHandler.FindDestURI(format(enum::"LSC Web Services"::GetDirectMarketingInfo), WSServerBuffer);
                    WSServerBuffer."Extended Web Service URI" := WebRequestFunctions.ConvertToNewUrl(WSServerBuffer."Extended Web Service URI");
                    WSServerBuffer."Log File ID" := LogFileID;
                    PostGetDirectMarketingInfo(WSServerBuffer, CardID, ItemNo, StoreNo, PublishedOfferTemp, PublishedOfferImagesTemp, PublishedOfferDetailLineTemp,
                    PublishedOfferDetailLineImagesTemp, MemberCouponBufferTemp, MemberNotificationTemp, MemberNotificationImagesTemp, PublishedOfferLineBufferTemp, ResponseCode, ErrorText);
                    if ResponseCode <> '0098' then
                        RequestOk := true;
                    RequestHandler.AddToConnLog(WSServerBuffer."Profile ID", WSServerBuffer."Dist. Location", WSServerBuffer."Extended Web Service URI", ErrorText);
                end;
            until (WSServerBuffer.Next = 0) or RequestOk
        else begin
            ErrorText := StrSubstNo(URIMissingTxt, format(enum::"LSC Web Services"::GetDirectMarketingInfo));
            RequestHandler.AddToConnLog('', '', '', ErrorText);
        end;
    end;

    procedure GetResponse(var ErrorText: Text; var LoadMemberDirMarkInfoXML: XmlPort "MA_GetDirectMarketingInfo_NT")
    begin
        ErrorText := ErrorText_g;
        Clear(LoadMemberDirMarkInfoXML);
        LoadMemberDirMarkInfoXML.SetLoadMemberDirMarketInfo(PublishedOfferTemp_g, PublishedOfferImagesTemp_g, PublishedOfferDetailLineTemp_g,
        PublishedOfferDetailLineImagesTemp_g, MemberCouponBufferTemp_g, MemberNotificationTemp_g, MemberNotificationImagesTemp_g, PublishedOfferLineBufferTemp_g);
        LoadMemberDirMarkInfoXML.Export;
    end;

    local procedure PostGetDirectMarketingInfo(var WSServerBuffer: Record "LSC WS Server Buffer" temporary; CardID: Text[100]; ItemNo: Code[20]; StoreNo: Code[10]; var PublishedOfferTemp: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp: Record "LSC Retail Image Link" temporary; var MemberCouponBufferTemp: Record "LSC Member Coupon Buffer" temporary; var MemberNotificationTemp: Record "LSC Member Notification" temporary; var MemberNotificationImagesTemp: Record "LSC Retail Image Link" temporary; var PublishedOfferLineBufferTemp: Record "LSC Published Offer Line Buff" temporary; var ResponseCode: Code[30]; var ErrorText: Text)
    var
        ReqNodeBuffer: Record "LSC WS Node Buffer" temporary;
        ReqRecRefArray: array[32] of RecordRef;
        ResNodeBuffer: Record "LSC WS Node Buffer" temporary;
        ResRecRefArray: array[32] of RecordRef;
        WebRequestHandler: Codeunit "LSC Web Request Handler";
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
        ProcessErrorText: Text;
    begin
        //Request
        WebRequestHandler.AddNodeToBuffer('responseCode', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('errorText', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('cardID', CardID, ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('itemNo', ItemNo, ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('storeNo', StoreNo, ReqNodeBuffer);
        WebRequestHandler.AddReqTableNodeToBuffer('PublishedOffer', PublishedOfferTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddReqTableNodeToBuffer('PublishedOfferImages', PublishedOfferImagesTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddReqTableNodeToBuffer('PublishedOfferDetailLine', PublishedOfferDetailLineTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddReqTableNodeToBuffer('PublishedOfferDetailLineImages', PublishedOfferDetailLineImagesTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddReqTableNodeToBuffer('MemberCouponBuffer', MemberCouponBufferTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddReqTableNodeToBuffer('MemberNotification', MemberNotificationTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddReqTableNodeToBuffer('MemberNotificationImages', MemberNotificationImagesTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddReqTableNodeToBuffer('PublishedOfferLineBuffer', PublishedOfferLineBufferTemp, ReqNodeBuffer, ReqRecRefArray);
        //Process
        if not WebRequestHandler.SendWebRequest(format(enum::"LSC Web Services"::GetDirectMarketingInfo), WSServerBuffer, ReqNodeBuffer, ReqRecRefArray, ResNodeBuffer, ResRecRefArray, ProcessErrorText) then begin
            ResponseCode := '0098'; //Unidentified Client Error or Connection Error
            ErrorText := ProcessErrorText;
            exit;
        end;
        //Response
        ResponseCode := WebRequestHandler.GetNodeValueFromBuffer('responseCode', ResNodeBuffer);
        ErrorText := WebRequestHandler.GetNodeValueFromBuffer('errorText', ResNodeBuffer);
        WebRequestFunctions.ClearTable(PublishedOfferTemp);
        WebRequestHandler.GetTableNodeFromBuffer('PublishedOffer', ResNodeBuffer, ResRecRefArray, PublishedOfferTemp);
        WebRequestFunctions.ClearTable(PublishedOfferImagesTemp);
        WebRequestHandler.GetTableNodeFromBuffer('PublishedOfferImages', ResNodeBuffer, ResRecRefArray, PublishedOfferImagesTemp);
        WebRequestFunctions.ClearTable(PublishedOfferDetailLineTemp);
        WebRequestHandler.GetTableNodeFromBuffer('PublishedOfferDetailLine', ResNodeBuffer, ResRecRefArray, PublishedOfferDetailLineTemp);
        WebRequestFunctions.ClearTable(PublishedOfferDetailLineImagesTemp);
        WebRequestHandler.GetTableNodeFromBuffer('PublishedOfferDetailLineImages', ResNodeBuffer, ResRecRefArray, PublishedOfferDetailLineImagesTemp);
        WebRequestFunctions.ClearTable(MemberCouponBufferTemp);
        WebRequestHandler.GetTableNodeFromBuffer('MemberCouponBuffer', ResNodeBuffer, ResRecRefArray, MemberCouponBufferTemp);
        WebRequestFunctions.ClearTable(MemberNotificationTemp);
        WebRequestHandler.GetTableNodeFromBuffer('MemberNotification', ResNodeBuffer, ResRecRefArray, MemberNotificationTemp);
        WebRequestFunctions.ClearTable(MemberNotificationImagesTemp);
        WebRequestHandler.GetTableNodeFromBuffer('MemberNotificationImages', ResNodeBuffer, ResRecRefArray, MemberNotificationImagesTemp);
        WebRequestFunctions.ClearTable(PublishedOfferLineBufferTemp);
        WebRequestHandler.GetTableNodeFromBuffer('PublishedOfferLineBuffer', ResNodeBuffer, ResRecRefArray, PublishedOfferLineBufferTemp);
    end;

    procedure SetPosFunctionalityProfile(POSFunctionalityProfileCode: Code[10])
    begin
        POSFunctionalityProfileCode_g := POSFunctionalityProfileCode;
    end;
}

