dotnet
{   
    assembly(Newtonsoft.Json)
    {
        type(Newtonsoft.Json.JsonTextWriter; JsonTextWriter_NT) { }
        type(Newtonsoft.Json.JsonTextReader; JsonTextReader_NT) { }
        type(Newtonsoft.Json.Formatting; JsonFormatting_NT) { }
        type(Newtonsoft.Json.JsonToken; JsonToken_NT) { }
    }
    assembly(zxing)
    {
        type(ZXing.BarcodeWriter;ZXingBarcodeWriter_NT){}
        type(ZXing.BarcodeFormat;ZXingBarcodeFormat_NT){}
        type(ZXing.Common.EncodingOptions;ZXingCommonEncodingOptions_NT){}
        type(ZXing.Common.BitMatrix;ZXingCommonBitMatrix_NT){}
    }
    
    assembly(Nextech.Alta.Net)
    {        
        type(Nextech_Alta.GetReceipts;AltaReceipts_NT){}
        type(Nextech_Alta.AccountManagement;AltaAccountManagement_NT){}
        type(Nextech_Alta.Transaction;AltaTransaction_NT){}
   }   
}