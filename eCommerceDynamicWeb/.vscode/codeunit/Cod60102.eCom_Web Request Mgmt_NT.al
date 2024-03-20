codeunit 60102 "eCom_Web Request Mgmt_NT"
{
    trigger OnRun()
    begin

    end;

    procedure SendODATARequest(contactid: Code[20]) AuthenticationStatus: Boolean;
    var
        ConvertToBase64: Codeunit "Base64 Convert";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        AuthText: Text;
        JsonBody: Text;
        URI: Text;
        JsonResponseTxt: Text;
        WebResponseTxt: Label 'The web service returned an error message:\Status code: %1\Description: %2\', Comment = '%1 = ResponseMessage.HttpStatusCode() %2 = ResponseMessage.ReasonPhrase()';
        JsonObj: JsonObject;
        JsonArray: JsonArray;
        Index: Integer;
        JsonToken: JsonToken;
        xx: Codeunit "Temp Blob";
    begin
        RequestMessage.Method := Format('POST');
        URI := 'http://10.20.0.142:7058/BC200P/ODataV4/eCommerceDynamicWeb2_GetMemberPoints_CS?company=4cd49f53-c33f-ed11-a6c1-00505696fa04';

        RequestMessage.SetRequestUri(URI);
        AuthText := StrSubstNo('%1:%2', 'nextech', '9YEttJEoltcEbA/zRy04g07B5TPauZc11sDRMKDS2wo=');
        Client.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Basic %1', ConvertToBase64.ToBase64(AuthText)));
        JsonObj.Add('contactID', contactid);
        JsonObj.WriteTo(JsonBody);
        Content.WriteFrom(jsonbody);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        RequestMessage.Content := Content;

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode() then begin
            AuthenticationStatus := false;
            Error(WebResponseTxt, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());
        end else begin
            AuthenticationStatus := true;
            Clear(JsonResponseTxt);
            ResponseMessage.Content().ReadAs(JsonResponseTxt);
            //Message(JsonResponseTxt);
            // if not JsonArray.ReadFrom(JsonResponseTxt) then
            //     Error('Invalid Response, expected a JSON array as root object');
            // for Index := 0 to JsonArray.Count - 1 do begin
            //     JsonArray.Get(Index, JsonToken);
            //     JsonObj := JsonToken.AsObject();
            //     JsonObj.Get('value', JsonToken);
            //     Message('Return Value %1', JsonToken.AsValue().AsBigInteger());
            // end;            
            if not JsonObj.ReadFrom(JsonResponseTxt) then
                Error('Invalid Response, expected a JSON object as root object');

            JsonObj.Get('value', JsonToken);
            Message('Return Value %1', JsonToken.AsValue().AsDecimal());
        end;
        exit(AuthenticationStatus);
    end;

    [TryFunction]
    procedure SendRequest(WebServiceURL: Text; UserName: Text; Password: Text; RequestString: Text; TimeOut: Integer; Var Response: Text)
    var
        _HTTPWebRequest: DotNet NavHTTPWebRequest;
    begin
        Clear(_HTTPWebRequest);
        _HTTPWebRequest := _HTTPWebRequest.HTTPWebRequest();
        _HTTPWebRequest.CreateRequest(WebServiceURL, 'application/json;charset=utf-8', 'POST', UserName, Password, TimeOut);
        Response := _HTTPWebRequest.DoRequest(RequestString);
        Clear(_HTTPWebRequest);
    end;

    procedure SendRequest2(WebServiceURL: Text; UserName: Text; Password: Text; RequestString: Text; TimeOut: Integer; Var Response: Text): Boolean
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JsonResponseTxt: Text;
        WebResponseTxt: Label 'The web service returned an error message:\Status code: %1\Description: %2\', Comment = '%1 = ResponseMessage.HttpStatusCode() %2 = ResponseMessage.ReasonPhrase()';
        AuthenticationStatus: Boolean;
    begin
        RequestMessage.Method := Format('POST');
        RequestMessage.SetRequestUri(WebServiceURL);
        Content.WriteFrom(RequestString);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json;charset=utf-8');
        RequestMessage.Content := Content;
        Client.Send(RequestMessage, ResponseMessage);
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


    var
        myInt: Integer;
}
