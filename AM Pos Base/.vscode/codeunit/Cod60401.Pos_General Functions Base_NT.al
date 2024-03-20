codeunit 60401 "Pos_General Functions Base_NT"
{

    procedure Test_ODATA_Connection()
    var
        ODataRequests: Record "Pos_OData Requests_NT";
        ConvertToBase64: Codeunit "Base64 Convert";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;        
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JsonObj: JsonObject;
        JToken: JsonToken;
        Duration_dec: Decimal;
        ApplicationBuild: Text;
        ApplicationVersion: Text;
        AuthText: Text;
        JsonBody: Text;
        JsonResponseTxt: Text;
        LSRetailVersion: Text;
        NTAlphaMegaCopyright: Text;
        URI: Text;
        EndTime: Time;
        StartTime: Time;
        lText000: Label 'Do you want to test the web connection';
        lText001: Label 'The connection was tested successfully in %1 seconds.';
        lText002: Label 'Version: %1';
        lText003: Label 'Build: %1';
        lText004: Label 'LS Retail Version: %1';
        lText005: Label 'Copyright: %1';
        WebResponseTxt: Label 'The web service returned an error message:\Status code: %1\Description: %2\', Comment = '%1 = ResponseMessage.HttpStatusCode() %2 = ResponseMessage.ReasonPhrase()';
    begin
        if not (Confirm(lText000, true)) then
            exit;
        StartTime := Time;        
        RequestMessage.Method := Format('POST');
        ODataRequests.Get('TESTCONNECTION');
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
        RequestMessage.SetRequestUri(URI);        

        AuthText := StrSubstNo('%1:%2', ODataRequests."User Name", ODataRequests."Web Service Access Key");
        Client.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Basic %1', ConvertToBase64.ToBase64(AuthText)));

        JsonObj.WriteTo(JsonBody);

        Content.WriteFrom(jsonbody);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');        
        Headers.Add('Content-Type', 'application/json');
        RequestMessage.Content := Content;
        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            Error(WebResponseTxt, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());
        end else begin
            Clear(JsonResponseTxt);
            ResponseMessage.Content().ReadAs(JsonResponseTxt);

            if not JsonObj.ReadFrom(JsonResponseTxt) then
                Message('Invalid Response, expected a JSON object as root object');

            JsonObj.Get('value', JToken);

            JsonResponseTxt := JToken.AsValue().AsText();
            if not JsonObj.ReadFrom(JsonResponseTxt) then
                Message('Invalid Response, expected a JSON text as return value');

            JsonObj.Get('TestConnectionResult', JToken);
            if JToken.AsValue().AsText() <> 'OK' then
                Error(JToken.AsValue().AsText());

            JsonObj.Get('ApplicationVersion', JToken);
            ApplicationVersion := JToken.AsValue().AsText();

            JsonObj.Get('ApplicationBuild', JToken);
            ApplicationBuild := JToken.AsValue().AsText();

            JsonObj.Get('LSRetailVersion', JToken);
            LSRetailVersion := JToken.AsValue().AsText();

            JsonObj.Get('NTAlphaMegaCopyright', JToken);
            NTAlphaMegaCopyright := JToken.AsValue().AsText();

            EndTime := Time;
            Duration_dec := (EndTime - StartTime) / 1000;
            Message(StrSubstNo(lText001, Duration_dec)
                    + '\' + StrSubstNo(lText002, ApplicationVersion)
                    + '\' + StrSubstNo(lText003, ApplicationBuild)
                    + '\' + StrSubstNo(lText004, LSRetailVersion)
                    + '\' + StrSubstNo(lText005, NTAlphaMegaCopyright));
        end;
    end;

    procedure SerializeJsonObject(var RecRef: RecordRef) JObject: JsonObject;
    var
        FieldRef: FieldRef;
        TableFields: Record Field;
    begin
        TableFields.SetRange(TableNo, RecRef.Number);
        TableFields.SetRange(ObsoleteState, TableFields.ObsoleteState::No);
        TableFields.SetFilter("No.", '<>%1&<>%2&<>%3&<>%4&<>%5',
                    TableFields.FieldNo(SystemId),
                    TableFields.FieldNo(SystemCreatedAt),
                    TableFields.FieldNo(SystemCreatedBy),
                    TableFields.FieldNo(SystemModifiedAt),
                    TableFields.FieldNo(SystemModifiedBy));
        TableFields.SetFilter(Class, '<>%1', TableFields.Class::FlowFilter);
        if TableFields.FindSet() then begin
            repeat
                Clear(FieldRef);
                FieldRef := RecRef.Field(TableFields."No.");
                if FieldRef.Class = FieldRef.Class::FlowField then
                    FieldRef.CalcField();
                JObject.Add(FieldRef.Name, Format(FieldRef.Value));
            until TableFields.Next() = 0;
        end;

        exit(JObject);
    end;    
}