codeunit 60305 "Pos_Web Request Management_NT"
{

    procedure SendRequest2(WebServiceURL: Text; UserName: Text; Password: Text; RequestString: Text; TimeOut: Integer; Var Response: Text): Boolean
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        AuthenticationStatus: Boolean;
        JsonResponseTxt: Text;
        WebResponseTxt: Label 'The web service returned an error message:\Status code: %1\Description: %2\', Comment = '%1 = ResponseMessage.HttpStatusCode() %2 = ResponseMessage.ReasonPhrase()';
    begin
        ClearLastError();
        RequestMessage.Method := Format('POST');
        Client.Timeout := TimeOut;
        RequestMessage.SetRequestUri(WebServiceURL);
        Content.WriteFrom(RequestString);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json;charset=utf-8');
        RequestMessage.Content := Content;
        if not Client.Send(RequestMessage, ResponseMessage) then begin
            AuthenticationStatus := false;
            Response := GetLastErrorText();
            exit(AuthenticationStatus);
        end;
        if not ResponseMessage.IsSuccessStatusCode() then begin
            AuthenticationStatus := false;
            Response := StrSubstNo(WebResponseTxt, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());
        end else begin
            AuthenticationStatus := true;
            Clear(Response);
            ResponseMessage.Content().ReadAs(Response);
        end;
        exit(AuthenticationStatus);
    end;

    procedure GetCustCoupon(VAR pxmlRequest: Text; VAR pxmlResponse: Text)
    var
        CustCouponEntry: Record "Pos_Customer Coupon Entry_NT";
        CustCouponEntryTemp: Record "Pos_Customer Coupon Entry_NT" temporary;
        FlowFieldBuffer: Record "LSC FlowField Buffer" temporary;
        ReqNodeList: Record "LSC WS Node Buffer" temporary;
        TableNodeList: Record "LSC WS Node Buffer" temporary;
        WSFunc: Codeunit "LSC WS Functions";
        ReqXml: XmlDocument;
        ResXml: XmlDocument;
        RecRef: RecordRef;
        RecRefTemp: array[32] of RecordRef;
        gLocalProcess: Boolean;
        ContactNo: Code[20];
        CouponCode: Code[20];
        Response_Code: Code[30];
        ParentNodeIndex: Integer;
        ErrorText: Text[250];
        NodeName: Text[50];
        ParentNodeList: array[5] of Text[50];
        RequestID: Text[30];
        RequestNodeList: array[3] of Text[50];
        ResponseNodeList: array[5] of Text[50];
        Response_Text: Text[1024];
        BodyNode: XmlNode;
        LineNode: XmlNode;
        Node: XmlNode;
        NodeList: XmlNodeList;
    begin
        //GetCustCoupon
        RequestID := 'GET_CUST_COUPON';
        WSFunc.LoadRequest(pxmlRequest, ReqXml, RequestID, RequestNodeList, ResponseNodeList, ParentNodeIndex, ParentNodeList, BodyNode, Response_Code, Response_Text);

        //Get List of request nodes
        if Response_Code = '0000' then
            WSFunc.AddChildNodeListText(RequestID, 0, ParentNodeIndex, ParentNodeList, 'Coupon_Code', '',
              ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then
            WSFunc.AddChildNodeListText(RequestID, 0, ParentNodeIndex, ParentNodeList, 'Contact_No', '',
              ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then
            WSFunc.GetChildNodeList(0, BodyNode, ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then begin
            ReqNodeList.Reset();
            if ReqNodeList.Find('-') then
                repeat
                    case ReqNodeList.Source of
                        'Coupon_Code':
                            begin
                                CouponCode := ReqNodeList."Text Value";
                            end;
                        'Contact_No':
                            begin
                                ContactNo := ReqNodeList."Text Value";
                            end;
                    end;
                until (ReqNodeList.Next() = 0) or (Response_Code <> '0000');
        end;

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //Process Request
        WSFunc.InitParentResNodeList(ResponseNodeList, ParentNodeIndex, ParentNodeList);

        //Get Customer Coupon Entry
        WSFunc.AddChildNodeTableList(RequestID, 1, ParentNodeIndex, ParentNodeList, 'Customer Coupon Entry', TableNodeList,
          Response_Code, Response_Text);
        if Response_Code = '0000' then begin
            if TableNodeList.FindLast() then
                CustCouponEntry.Reset();
            CustCouponEntry.SetRange("Coupon Code", CouponCode);
            CustCouponEntry.SetRange("Contact No.", ContactNo);
            if CustCouponEntry.FindSet() then
                repeat
                    CustCouponEntryTemp.Init();
                    CustCouponEntryTemp := CustCouponEntry;
                    CustCouponEntryTemp.Insert();
                until CustCouponEntry.Next() = 0;
            RecRef.GetTable(CustCouponEntryTemp);
            RecRefTemp[TableNodeList."Entry No."].Open(TableNodeList."Table No.", true);
            WSFunc.CopyTableToTempTable(RecRef, RecRefTemp[TableNodeList."Entry No."], FlowFieldBuffer);
        end;

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //Process Response Doc
        WSFunc.CreateResponse(ResXml, RequestID, ResponseNodeList, BodyNode);

        //Set Customer Coupon Entry
        TableNodeList.Reset();
        if TableNodeList.Find('-') then
            repeat
                WSFunc.SetTableChildNodes(RequestID, 1, BodyNode, ParentNodeIndex, ParentNodeList, TableNodeList.Source,
                  RecRefTemp[TableNodeList."Entry No."], FlowFieldBuffer, Response_Code, Response_Text);
            until (TableNodeList.Next() = 0) or (Response_Code <> '0000');

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //pxmlResponse := ResXml.OuterXml; BC Upgrade
        ResXml.WriteTo(pxmlResponse);//BC Upgrade
    end;

    procedure SendCustCoupon(VAR pxmlRequest: Text; VAR pxmlResponse: Text)
    var
        CustCouponEntry: Record "Pos_Customer Coupon Entry_NT";
        CustCouponEntryTemp: Record "Pos_Customer Coupon Entry_NT" temporary;
        FlowFieldBuffer: Record "LSC FlowField Buffer" temporary;
        ReqNodeList: Record "LSC WS Node Buffer" temporary;
        UpdateFieldList: Record Field temporary;
        WSFunc: Codeunit "LSC WS Functions";
        ReqXml: XmlDocument;
        ResXml: XmlDocument;
        RecRef: RecordRef;
        RecRefTemp: RecordRef;
        AddOnly: Boolean;
        gLocalProcess: Boolean;
        ContactNo: Code[20];
        CouponCode: Code[20];
        Response_Code: Code[30];
        ParentNodeIndex: Integer;
        ReplCounter: Integer;
        ErrorText: Text[250];
        NodeName: Text[50];
        ParentNodeList: array[5] of Text[50];
        RequestID: Text[30];
        RequestNodeList: array[3] of Text[50];
        ResponseNodeList: array[5] of Text[50];
        Response_Text: Text[1024];
        UpdateAction: Text[30];
        BodyNode: XmlNode;
        LineNode: XmlNode;
        Node: XmlNode;
        NodeList: XmlNodeList;
    begin
        //SendCustCoupon
        RequestID := 'SEND_CUST_COUPON';
        WSFunc.LoadRequest(pxmlRequest, ReqXml, RequestID, RequestNodeList, ResponseNodeList, ParentNodeIndex, ParentNodeList, BodyNode, Response_Code, Response_Text);

        //Get List of request nodes
        if Response_Code = '0000' then
            WSFunc.AddChildNodeListText(RequestID, 0, ParentNodeIndex, ParentNodeList, 'Update_Action', '',
              ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then
            WSFunc.GetChildNodeList(0, BodyNode, ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then begin
            ReqNodeList.Reset();
            if ReqNodeList.Find('-') then
                repeat
                    case ReqNodeList.Source of
                        'Update_Action':
                            begin
                                UpdateAction := ReqNodeList."Text Value";
                                if not ((UpdateAction = 'Add') or (UpdateAction = 'Update-Add')) then begin
                                    Response_Code := '0030';
                                    Response_Text := STRSUBSTNO(Text001, ReqNodeList."Text Value", ReqNodeList."Node Name");
                                end;
                            end;
                    end;
                until (ReqNodeList.Next() = 0) OR (Response_Code <> '0000');
        end;

        //Get Cust Coupon Entry
        if Response_Code = '0000' then begin
            RecRefTemp.GetTable(CustCouponEntryTemp);
            WSFunc.GetTableChildNodes(RequestID, 0, BodyNode, ParentNodeIndex, ParentNodeList, 'Customer Coupon Entry', RecRefTemp,
              FlowFieldBuffer, 1, UpdateFieldList, Response_Code, Response_Text);
        end;

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //Process Request
        if UpdateAction = 'Add' then
            AddOnly := TRUE
        else
            AddOnly := FALSE;

        //Cust Coupon Entry
        if Response_Code = '0000' then begin
            UpdateFieldList.SetRange(TableNo, 1);
            RecRefTemp.GetTable(CustCouponEntryTemp);
            RecRef.GetTable(CustCouponEntry);
            WSFunc.UpdateTableByTempTable(AddOnly, RecRefTemp, RecRef, ReplCounter, UpdateFieldList);
        end;

        //Process Response Doc
        WSFunc.InitParentResNodeList(ResponseNodeList, ParentNodeIndex, ParentNodeList);
        WSFunc.CreateResponse(ResXml, RequestID, ResponseNodeList, BodyNode);

        //pxmlResponse := ResXml.OuterXml; BC Upgrade
        ResXml.WriteTo(pxmlResponse); //BC Upgrade
    end;

    procedure GetNextNoSeriesCode(VAR pxmlRequest: Text; VAR pxmlResponse: Text)
    var
        ReqNodeList: Record "LSC WS Node Buffer" temporary;
        ResNodeList: Record "LSC WS Node Buffer" temporary;
        TableNodeList: Record "LSC WS Node Buffer" temporary;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        WSC: Codeunit "LSC Web Services Client";
        WSFunc: Codeunit "LSC WS Functions";
        ReqXml: XmlDocument;
        ResXml: XmlDocument;
        RecRef: RecordRef;
        RecRefTemp: array[32] of RecordRef;
        gLocalProcess: Boolean;
        NewCode: Code[20];
        NoSeries: Code[10];
        Response_Code: Code[30];
        ParentNodeIndex: Integer;
        ParentNodeList: array[5] of Text[50];
        RequestID: Text[30];
        RequestNodeList: array[3] of Text[50];
        ResponseNodeList: array[5] of Text[50];
        Response_Text: Text[1024];
        BodyNode: XmlNode;
        LineNode: XmlNode;
        Node: XmlNode;
        NodeList: XmlNodeList;
    begin
        //GetNextNoSeriesCode
        RequestID := 'GET_NEXT_NOSERIES_CODE';
        WSFunc.LoadRequest(pxmlRequest, ReqXml, RequestID, RequestNodeList, ResponseNodeList, ParentNodeIndex, ParentNodeList, BodyNode, Response_Code, Response_Text);

        //Get List of request nodes
        if Response_Code = '0000' then
            WSFunc.AddChildNodeListText(RequestID, 0, ParentNodeIndex, ParentNodeList, 'No_Series_Code', '',
              ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then
            WSFunc.GetChildNodeList(0, BodyNode, ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then begin
            ReqNodeList.Reset();
            if ReqNodeList.Find('-') then
                repeat
                    if ReqNodeList.Source = 'No_Series_Code' then
                        NoSeries := ReqNodeList."Text Value";
                until (ReqNodeList.NEXT = 0) or (Response_Code <> '0000');
        end;

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //Process Request
        WSFunc.InitParentResNodeList(ResponseNodeList, ParentNodeIndex, ParentNodeList);

        NoSeriesManagement.InitSeries(NoSeries, NoSeries, TODAY, NewCode, NoSeries);

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //Process Response Doc
        WSFunc.CreateResponse(ResXml, RequestID, ResponseNodeList, BodyNode);

        if Response_Code = '0000' then
            WSFunc.AddChildNodeListText(RequestID, 1, ParentNodeIndex, ParentNodeList, 'New_Code', NewCode,
              ResNodeList, Response_Code, Response_Text);

        if Response_Code = '0000' then
            WSFunc.AppendChildNodeList(BodyNode, ResNodeList);

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //pxmlResponse := ResXml.OuterXml; BC Upgrade
        ResXml.WriteTo(pxmlResponse); //BC Upgrade
    end;

    procedure GetMemberFBP(VAR pxmlRequest: Text; VAR pxmlResponse: Text)
    var
        FBPWSBufferTEMP: Record "LSC FBP WS Buffer" temporary;
        FlowFieldBuffer: Record "LSC FlowField Buffer" temporary;
        MemberAccount: Record "LSC Member Account";
        MemberAccountTemp: Record "LSC Member Account" temporary;
        MemberAttributeListTemp: Record "LSC Member Attribute List" temporary;
        MemberClub: Record "LSC Member Club";
        MemberClub_l: Record "LSC Member Club";
        MemberContact: Record "LSC Member Contact";
        MemberCouponBufferTEMP: Record "LSC Member Coupon Buffer" temporary;
        MemberMgtSetup: Record "LSC Member Management Setup";
        MemberPointSetup: Record "LSC Member Point Setup";
        MemberSalesEntry_l: Record "LSC Member Sales Entry";
        MemberScheme: Record "LSC Member Scheme";
        MembershipCard: Record "LSC Membership Card";
        MembershipCardTemp: Record "LSC Membership Card";
        ReqNodeList: Record "LSC WS Node Buffer" temporary;
        ResNodeList: Record "LSC WS Node Buffer" temporary;
        TableNodeList: Record "LSC WS Node Buffer" temporary;
        CouponManagement: Codeunit "LSC Coupon Management";
        FBPUtility: Codeunit "LSC FBP Utility";
        MemberCardMgt: Codeunit "LSC Member Card Management";
        WSFunc: Codeunit "LSC WS Functions";
        ReqXml: XmlDocument;
        ResXml: XmlDocument;
        RecRef: RecordRef;
        RecRefTemp: array[32] of RecordRef;
        gLocalProcess: Boolean;
        Response_Code: Code[30];
        StoreNo: Code[10];
        ParentNodeIndex: Integer;
        CardNo: Text;
        ErrorText: Text[250];
        ParentNodeList: array[5] of Text[50];
        RequestID: Text[30];
        RequestNodeList: array[3] of Text[50];
        ResponseNodeList: array[5] of Text[50];
        Response_Text: Text[1024];
        BodyNode: XmlNode;
    begin
        RequestID := 'GET_MEMBER_FBP';
        WSFunc.LoadRequest(pxmlRequest, ReqXml, RequestID, RequestNodeList, ResponseNodeList, ParentNodeIndex, ParentNodeList, BodyNode, Response_Code, Response_Text);

        //Get List of request nodes
        if Response_Code = '0000' then
            WSFunc.AddChildNodeListText(RequestID, 0, ParentNodeIndex, ParentNodeList, 'Card_No', '',
              ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then
            WSFunc.AddChildNodeListText(RequestID, 0, ParentNodeIndex, ParentNodeList, 'Store_No', '',
              ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then
            WSFunc.GetChildNodeList(0, BodyNode, ReqNodeList, Response_Code, Response_Text);
        if Response_Code = '0000' then begin
            ReqNodeList.Reset();
            if ReqNodeList.Find('-') then
                repeat
                    case ReqNodeList.Source of
                        'Card_No':
                            CardNo := ReqNodeList."Text Value";
                        'Store_No':
                            StoreNo := ReqNodeList."Text Value";
                    end;
                until (ReqNodeList.Next() = 0) or (Response_Code <> '0000');
        end;

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //Process Request
        WSFunc.InitParentResNodeList(ResponseNodeList, ParentNodeIndex, ParentNodeList);

        if not MemberCardMgt.GetMembershipCard(CardNo, MembershipCard, ErrorText) then begin
            Response_Code := '1001';
            if ErrorText <> '' then
                Response_Text := ErrorText
            else
                Response_Text := STRSUBSTNO(Text101, MembershipCardTemp.TABLECAPTION, CardNo);
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //Get Member Coupon Buffer
        if Response_Code = '0000' then
            WSFunc.AddChildNodeTableList(RequestID, 1, ParentNodeIndex, ParentNodeList, 'Member Coupon Buffer', TableNodeList,
              Response_Code, Response_Text);
        if Response_Code = '0000' then begin
            if TableNodeList.FindLast() then;
            RecRefTemp[TableNodeList."Entry No."].Open(TableNodeList."Table No.", true);
            ////  CouponManagement.GetMemberCouponList(MemberCouponBufferTEMP,MemberAccount."No.",StoreNo); //LS-3001
            CouponManagement.GetMemberCouponList(MemberCouponBufferTEMP, MembershipCard."Account No.", StoreNo, StoreNo <> ''); //LS-3001
            RecRef.GetTable(MemberCouponBufferTEMP);
            WSFunc.CopyTableToTempTable(RecRef, RecRefTemp[TableNodeList."Entry No."], FlowFieldBuffer);
        end;

        //Get FBP WS Buffer
        if Response_Code = '0000' then
            WSFunc.AddChildNodeTableList(RequestID, 1, ParentNodeIndex, ParentNodeList, 'FBP WS Buffer', TableNodeList,
              Response_Code, Response_Text);
        if Response_Code = '0000' then begin
            if TableNodeList.FindLast() then;
            RecRefTemp[TableNodeList."Entry No."].OPEN(TableNodeList."Table No.", true);
            FBPUtility.GetFBPStatus(FBPWSBufferTEMP, MembershipCard."Account No.", StoreNo);
            RecRef.GetTable(FBPWSBufferTEMP);
            WSFunc.CopyTableToTempTable(RecRef, RecRefTemp[TableNodeList."Entry No."], FlowFieldBuffer);
        end;

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;

        //Process Response Doc
        WSFunc.CreateResponse(ResXml, RequestID, ResponseNodeList, BodyNode);

        //Set Tables
        TableNodeList.Reset();
        if TableNodeList.Find('-') then
            repeat
                WSFunc.SetTableChildNodes(RequestID, 1, BodyNode, ParentNodeIndex, ParentNodeList, TableNodeList.Source,
                  RecRefTemp[TableNodeList."Entry No."], FlowFieldBuffer, Response_Code, Response_Text);
            until (TableNodeList.Next() = 0) or (Response_Code <> '0000');

        if Response_Code <> '0000' then begin
            WSFunc.ErrorResponse(RequestID, ResponseNodeList, Response_Code, Response_Text, gLocalProcess, pxmlResponse);
            exit;
        end;
        //pxmlResponse := ResXml.OuterXml; BC Upgrade
        ResXml.WriteTo(pxmlResponse); //BC Upgrade
    end;

    procedure GetNextNoSeriesCodeFromServer(NoSeriesCode: Code[10]; VAR NewCode: Code[20]; VAR pProcessError: Boolean; VAR pErrorText: Text): Boolean
    var
        PosFuncProfile: Record "LSC POS Func. Profile";
        TempReqNodeList: Record "LSC WS Node Buffer" temporary;
        TempResNodeList: Record "LSC WS Node Buffer" temporary;
        TempTableNodeList: Record "LSC WS Node Buffer" temporary;
        POSSESSION: Codeunit "LSC POS Session";
        WebServicesClient: Codeunit "LSC Web Services Client";
        ReqXml: XmlDocument;
        ResXml: XmlDocument;
        Response_Code: Code[30];
        ParentNodeIndex: Integer;
        ParentNodeList: array[5] of Text[50];
        RequestID: Text;
        RequestNodeList: array[3] of Text[50];
        ResponseNodeList: array[5] of Text[50];
        xmlRequest: Text;
        xmlResponse: Text;
        BodyNode: XmlNode;
    begin
        RequestID := 'GET_NEXT_NOSERIES_CODE';
        if (NoSeriesCode = '') then
            exit(false);
        PosFuncProfile.Get(POSSESSION.FunctionalityProfileID());
        WebServicesClient.SetPosFuncProfile(PosFuncProfile);
        // if not WebServicesClient.GetNextNoSeriesCode(NoSeries, NewCode, pProcessError, pErrorText) THEN
        //     EXIT(FALSE);
        //EXIT(NewCode <> '');
        WebServicesClient.GetWebServiceSetup;
        RequestID := 'GET_NEXT_NOSERIES_CODE';
        Response_Code := '0000';
        NewCode := '';
        //BC 22 Upgrade Start
        //if not WebServicesClient.InitRequest(ReqXml, RequestID, RequestNodeList, ResponseNodeList, ParentNodeIndex, ParentNodeList, BodyNode, pProcessError, pErrorText) then
        if not InitRequest(ReqXml, RequestID, RequestNodeList, ResponseNodeList, ParentNodeIndex, ParentNodeList, BodyNode, pProcessError, pErrorText) then
            exit(false);
        //BC 22 Upgrade End
        if not WSFunc.AddChildNodeListText(RequestID, 0, ParentNodeIndex, ParentNodeList, 'No_Series_Code', NoSeriesCode, TempReqNodeList, Response_Code, pErrorText) then begin
            pProcessError := true;
            exit(false);
        END;

        WSFunc.AppendChildNodeList(BodyNode, TempReqNodeList);

        //xmlRequest := ReqXml.OuterXml; BC Upgrade
        ReqXml.WriteTo(xmlRequest);//BC Upgrade
        WebServicesClient.SendRequest(RequestID, xmlRequest, xmlResponse);
        if not WSFunc.LoadResponse(xmlResponse, ResXml, RequestID, ResponseNodeList, ParentNodeIndex, ParentNodeList, BodyNode, pProcessError, pErrorText) then
            exit(false);

        //Get Series Code
        if not WSFunc.AddChildNodeListText(RequestID, 1, ParentNodeIndex, ParentNodeList, 'New_Code', '', TempResNodeList, Response_Code, pErrorText) then begin
            pProcessError := true;
            exit(false);
        end;

        if not WSFunc.GetChildNodeList(1, BodyNode, TempResNodeList, Response_Code, pErrorText) then begin
            pProcessError := true;
            exit(false);
        end;
        TempResNodeList.Reset();
        if TempResNodeList.Find('-') then
            repeat
                if TempResNodeList.Source = 'New_Code' then
                    NewCode := TempResNodeList."Text Value";
            until TempResNodeList.Next() = 0;

        pProcessError := false;
        exit(true);
    end;

    internal procedure InitRequest(var pReqXml: XmlDocument; pRequestID: Code[30]; var pRequestNodeList: array[3] of Text[50]; var pResponseNodeList: array[5] of Text[50]; var pParentNodeIndex: Integer; var pParentNodeList: array[5] of Text[50]; var pNode: XmlNode; var pProcessError: Boolean; var pErrorText: Text[1024]): Boolean
    begin
        //InitRequest

        if not RequestSetupOk(pRequestID, pErrorText) then begin
            pProcessError := true;
            exit(false);
        end;

        WSFunc.GetHeaderReqNodes(pRequestID, pRequestNodeList);
        WSFunc.GetHeaderResNodes(pRequestID, pResponseNodeList);

        WSFunc.CreateRequest(pReqXml, pRequestID, pRequestNodeList, pParentNodeIndex, pParentNodeList, pNode);

        exit(true);
    end;

    local procedure RequestSetupOk(pRequestID: Text[30]; var pErrorText: Text[1024]): Boolean
    var
        WebServiceSetup: Record "LSC Web Service Setup";
        lText001: Label 'Web service module is not active';
        lText002: Label 'Web request %1 not found';
        lText003: Label 'Web request %1 is not active';
        WSRequest: Record "LSC WS Request";
    begin
        //RequestSetupOk

        if not WebServiceSetup."Web Service is Active" then begin
            pErrorText := lText001;
            exit(false);
        end;

        if not WSRequest.Get(pRequestID) then begin
            pErrorText := StrSubstNo(lText002, pRequestID);
            exit(false);
        end;

        if not WSRequest."Web Request is Active" then begin
            pErrorText := StrSubstNo(lText003, pRequestID);
            exit(false);
        end;

        if not WSFunc.XMLHeaderSetupOk(pRequestID, pErrorText) then
            exit(false);

        exit(true);
    end;

    var
        WSFunc: Codeunit "LSC WS Functions";
        Text001: label 'Invalid value %1 in Request Node %2';
        Text101: Label '%1 %2 not found';

}
