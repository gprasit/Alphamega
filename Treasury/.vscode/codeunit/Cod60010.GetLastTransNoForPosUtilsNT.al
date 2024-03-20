codeunit 60010 GetLastTransNoForPosUtils_NT
{    
    trigger OnRun()
    begin
        RunRequest;
    end;

    var
        PosTerminal_g: Code[10];
        POSFunctionalityProfileCode_g: Code[10];
        ErrorText_g: Text;
        LastTransNo_g: Integer;
        PosTerminalInvalid: Label 'POS Terminal number missing or invalid.';

    local procedure RunRequest()
    var
        PosTerminal: Record "LSC POS Terminal";
        TransactionHeader: Record "LSC Transaction Header";
    begin
        if (PosTerminal_g = '') or not PosTerminal.get(PosTerminal_g) then begin
            ErrorText_g := PosTerminalInvalid;
            exit;
        end;

        LastTransNo_g := 0;
        TransactionHeader.SetCurrentKey("POS Terminal No.", "Transaction No.");
        TransactionHeader.SetRange("POS Terminal No.", PosTerminal_g);
        if TransactionHeader.FindLast() then
            LastTransNo_g := TransactionHeader."Transaction No.";
    end;

    procedure SetRequest(PosTerminal: Code[10])
    begin
        PosTerminal_g := PosTerminal;
    end;

    procedure SendRequest(PosTerminal: Code[10]; var ResponseCode: Code[30]; var ErrorText: Text; var LastTransNo: integer)
    var
        WSServerBuffer: Record "LSC WS Server Buffer" temporary;
        GetLastTransNoForPos: Codeunit LSCGetLastTransNoForPos;
        RequestHandler: Codeunit "LSC Request Handler";
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
        RequestID: Text;
        RequestOk: Boolean;
        ReqDateTime: DateTime;
        LogFileID: Text;
        URIMissingTxt: Label 'Web Server URI is Missing for Request %1';
    begin
        RequestID := 'LSCGetLastTransNoForPos';
        RequestOk := false;
        ReqDateTime := CurrentDateTime;
        LogFileID := WebRequestFunctions.CreateLogFileID(ReqDateTime);
        RequestHandler.GetWebServerList(RequestID, POSFunctionalityProfileCode_g, WSServerBuffer);
        WSServerBuffer.Reset;
        if WSServerBuffer.FindSet then
            repeat
                if WSServerBuffer."Local Request" then begin
                    GetLastTransNoForPos.GetLastTransNoForPos(ResponseCode, ErrorText, PosTerminal, LastTransNo);
                    RequestOk := true;
                    RequestHandler.AddToConnLog(WSServerBuffer."Profile ID", 'Local', 'Local', '');
                end else begin
                    RequestHandler.FindDestURI(RequestID, WSServerBuffer);
                    WSServerBuffer."Extended Web Service URI" := WebRequestFunctions.ConvertToNewUrl(WSServerBuffer."Extended Web Service URI");
                    WSServerBuffer."Log File ID" := LogFileID;
                    PostGetLastTransNoForPos(WSServerBuffer, PosTerminal, ResponseCode, ErrorText, LastTransNo);
                    if ResponseCode <> '0098' then
                        RequestOk := true;
                    RequestHandler.AddToConnLog(WSServerBuffer."Profile ID", WSServerBuffer."Dist. Location", WSServerBuffer."Extended Web Service URI", ErrorText);
                end;
            until (WSServerBuffer.Next = 0) or RequestOk
        else begin
            ErrorText := StrSubstNo(URIMissingTxt, RequestID);
            RequestHandler.AddToConnLog('', '', '', ErrorText);
        end;
    end;

    procedure GetResponse(var ErrorText: Text; var LastTransNo: Integer)
    begin
        ErrorText := ErrorText_g;
        LastTransNo := LastTransNo_g;
    end;

    local procedure PostGetLastTransNoForPos(var WSServerBuffer: Record "LSC WS Server Buffer"; PosTerminal: Code[10]; var ResponseCode: Code[30]; var ErrorText: Text; var LastTransNo: Integer)
    var
        ReqNodeBuffer: Record "LSC WS Node Buffer" temporary;
        ReqRecRefArray: array[32] of RecordRef;
        ResNodeBuffer: Record "LSC WS Node Buffer" temporary;
        ResRecRefArray: array[32] of RecordRef;
        WebRequestHandler: Codeunit "LSC Web Request Handler";
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
        RequestID: Text;
        ProcessErrorText: Text;
    begin
        RequestID := 'LSCGetLastTransNoForPos';
        //Request
        WebRequestHandler.AddNodeToBuffer('posTerminal', PosTerminal, ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('responseCode', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('errorText', '', ReqNodeBuffer);
        //Process
        if not WebRequestHandler.SendWebRequest(RequestID, WSServerBuffer, ReqNodeBuffer, ReqRecRefArray, ResNodeBuffer, ResRecRefArray, ProcessErrorText) then begin
            ResponseCode := '0098'; //Unidentified Client Error or Connection Error
            ErrorText := ProcessErrorText;
            exit;
        end;
        //Response
        ResponseCode := WebRequestHandler.GetNodeValueFromBuffer('responseCode', ResNodeBuffer);
        ErrorText := WebRequestHandler.GetNodeValueFromBuffer('errorText', ResNodeBuffer);
        if not Evaluate(LastTransNo, WebRequestHandler.GetNodeValueFromBuffer('lastTransNo', ResNodeBuffer)) then
            LastTransNo := 0;
    end;

    procedure SetPosFunctionalityProfile(POSFunctionalityProfileCode: Code[10])
    begin
        POSFunctionalityProfileCode_g := POSFunctionalityProfileCode;
    end;

    procedure SetCommunicationError(ResponseCode: Code[30]; ErrorText: Text)
    var
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
    begin
        WebRequestFunctions.SetCommunicationError(ResponseCode, ErrorText);
    end;
}


