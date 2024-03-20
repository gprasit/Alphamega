dotnet
{
    assembly(Nextech.RCB.eComm)
    {
        type(Nextech.RCB.eComm.RCB; eComRCB) { }
    }
    assembly(Nextech.VivaWallet.eComm)
    {
        type(Nextech.VivaWallet.eComm.VivaWallet; eComVivaWallet) { }
    }
    assembly(Newtonsoft.Json)
    {
        type(Newtonsoft.Json.JsonTextWriter; eComJsonTextWriter) { }
        type(Newtonsoft.Json.JsonTextReader; eComJsonTextReader) { }
        type(Newtonsoft.Json.Formatting; eComJsonFormatting) { }
        type(Newtonsoft.Json.JsonToken; eComJsonToken) { }
    }
    assembly(NAVWebRequest)
    {
        type(NAVWebRequest.NAVWebRequest; eComNAVWebRequest) { }
    }
    assembly(Nextech.Nav.WebService)
    {
        Version = '1.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'null';
        type(Nextech.Nav.HTTPWebService.HTTPWebRequest; NavHTTPWebRequest) { }
    }    
}