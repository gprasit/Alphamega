codeunit 60306 "Pos_Gen. Buffer Json Mgmt_NT"
{
    procedure ReadJSon(VAR String: DotNet String; VAR GenBuffer: Record "eCom_General Buffer_NT")
    var
        JsonToken: DotNet JsonToken_NT;
        InArray: array[250] of Boolean;
        Code: code[10];
        ColumnNo: Integer;
        PropertyName: Text;
        PrefixArray: DotNet Array;
        PrefixString: DotNet String;
    begin
        PrefixArray := PrefixArray.CreateInstance(GetDotNetType(String), 250);
        StringReader := StringReader.StringReader(String);
        JsonTextReader := JsonTextReader.JsonTextReader(StringReader);

        Code := '0000000000';

        while JsonTextReader.Read do
            case true of
                JsonTextReader.TokenType.CompareTo(JsonToken.StartObject) = 0:
                    ;
                JsonTextReader.TokenType.CompareTo(JsonToken.StartArray) = 0:
                    begin
                        InArray[JsonTextReader.Depth + 1] := TRUE;
                        ColumnNo := 0;
                    end;
                JsonTextReader.TokenType.CompareTo(JsonToken.StartConstructor) = 0:
                    ;
                JsonTextReader.TokenType.CompareTo(JsonToken.PropertyName) = 0:
                    begin
                        PrefixArray.SetValue(JsonTextReader.Value, JsonTextReader.Depth - 1);
                        if JsonTextReader.Depth > 1 then begin
                            PrefixString := PrefixString.Join('_', PrefixArray, 0, JsonTextReader.Depth - 1);
                            if PrefixString.Length > 0 then
                                PropertyName := PrefixString.ToString + '_' + FORMAT(JsonTextReader.Value, 0, 9)
                            else
                                PropertyName := FORMAT(JsonTextReader.Value, 0, 9);
                        end else
                            PropertyName := FORMAT(JsonTextReader.Value, 0, 9);
                    end;
                JsonTextReader.TokenType.CompareTo(JsonToken.String) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Integer) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Float) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Boolean) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Date) = 0,
                JsonTextReader.TokenType.CompareTo(JsonToken.Bytes) = 0:
                    begin
                        Code := INCSTR(Code);
                        //Data Exch. No.,Line No.,Column No.,Node ID
                        GenBuffer."Code 1" := Code;
                        GenBuffer."Integer 1" := JsonTextReader.Depth;
                        GenBuffer."Integer 2" := JsonTextReader.LineNumber;
                        GenBuffer."Integer 3" := ColumnNo;
                        GenBuffer."Text 1" := PropertyName;
                        GenBuffer."Text 2" := COPYSTR(FORMAT(JsonTextReader.Value, 0, 9), 1, 250);
                        //TempPostingExchField."Data Exch. Line Def Code" := JsonTextReader.TokenType.ToString;
                        GenBuffer.INSERT;
                    end;
                JsonTextReader.TokenType.CompareTo(JsonToken.EndConstructor) = 0:
                    ;
                JsonTextReader.TokenType.CompareTo(JsonToken.EndArray) = 0:
                    InArray[JsonTextReader.Depth + 1] := FALSE;
                JsonTextReader.TokenType.CompareTo(JsonToken.EndObject) = 0:
                    IF JsonTextReader.Depth > 0 THEN
                        IF InArray[JsonTextReader.Depth] THEN ColumnNo += 1;
            end;
    end;

    procedure GetJsonValue(VAR GenBuffer: Record "eCom_General Buffer_NT"; ParameterName: Text): Text
    begin
        GenBuffer.SetRange("Text 1", ParameterName);
        if GenBuffer.FindFirst() then
            exit(GenBuffer."Text 2");
    end;
var
        StringReader: DotNet StringReader;
        JsonTextReader: DotNet JsonTextReader_NT;
        JsonTextWriter: DotNet JsonTextWriter_NT;

}
