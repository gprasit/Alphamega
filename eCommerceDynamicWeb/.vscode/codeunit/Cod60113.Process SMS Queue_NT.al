codeunit 60113 "Process SMS Queue_NT"
{
    TableNo = "LSC Scheduler Job Header";
    trigger OnRun()
    var
    begin
        ProcessSMSQueue();
    end;

    procedure ProcessSMSQueue()
    var
        SMSQueue: Record "eCom_SMS Queue_NT";
        myInt: Integer;
        ResponseTxt: Text;
        SendOk: Boolean;
    begin
        SendOk := false;
        SMSQueue.SetRange(Sent, false);
        SMSQueue.SetRange(Success, false);
        if SMSQueue.FindSet() then
            repeat
                SendOk := SendSMS('357', SMSQueue."Phone No.", SMSQueue.Message, ResponseTxt);
                if SendOk then
                    MarkSMSQueueAsSent(SMSQueue."Entry No.");
            until SMSQueue.Next() = 0;
    end;


    procedure SendSMS(CountryCode: Code[10]; PhoneNo: code[20]; MsgBody: Text; Var Response: Text): Boolean
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        ResponseSuccess: Boolean;
        JsonResponseTxt: Text;
        RequestBody: Text;
        SMSLogUrl: Text;
        SMSMsgBody: Text;
        WebResponseTxt: Label 'The web service returned an error message:\Status code: %1\Description: %2\', Comment = '%1 = ResponseMessage.HttpStatusCode() %2 = ResponseMessage.ReasonPhrase()';
    begin
        RequestBody := 'http://api.microsms.net/sendapidirectalpha.asp?usr=kiosk@alphamega.com.cy&psw=poem05!&mobnu=' + CountryCode + PhoneNo + '&title=Alphamega&';
        SMSLogUrl := RequestBody;
        RequestBody := RequestBody + 'message=' + MsgBody;
        RequestMessage.Method := Format('POST');
        RequestMessage.SetRequestUri(RequestBody);

        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/text;charset=utf-8');

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseSuccess := false;
            Error(WebResponseTxt, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());
        end else begin
            ResponseSuccess := true;
            Clear(Response);
            ResponseMessage.Content().ReadAs(Response);
        end;
        LogMessage(Copystr(MsgBody, 1, 250), SMSLogUrl, PhoneNo, Response);
        exit(ResponseSuccess);
    end;


    local procedure LogMessage(Message: Text[250]; Url: Text; Numbers: Text; StatusMsg: Text[250]): Boolean
    var
        SMSLog: Record "LSC SMS Message log";
        LastEntryNo: Integer;
    begin
        //HHTPResponce := CONVERTSTR(XMLHTTP.responseText, '|', ',');
        IF SMSLog.FindLast() THEN
            LastEntryNo := SMSLog."Entry No." + 1
        ELSE
            LastEntryNo := 1;

        SMSLog.INIT;
        SMSLog."Entry No." := LastEntryNo;
        SMSLog."Date Time" := CURRENTDATETIME;
        SMSLog.Message := Message;
        SMSLog.Url := COPYSTR(Url, 1, 250); // NT
        SMSLog."Phone Numbers" := Numbers;
        //SMSLog."Status Code" := SELECTSTR(1, HHTPResponce);
        //SMSLog."Status Description" := SELECTSTR(2, HHTPResponce);
        SMSLog."Status Description" := StatusMsg;
        exit(SMSLog.Insert());

        //EXIT(SMSLog."Status Code" = '11');
    end;

    local procedure MarkSMSQueueAsSent(EntryNo: Integer)
    var
        SMSQueue: Record "eCom_SMS Queue_NT";
    begin
        SMSQueue.Get(EntryNo);
        SMSQueue.Sent := true;
        SMSQueue.Success := true;
        SMSQueue."Date Sent" := Today;
        SMSQueue."Time Sent" := Time;
        SMSQueue.Modify();
    end;
}
