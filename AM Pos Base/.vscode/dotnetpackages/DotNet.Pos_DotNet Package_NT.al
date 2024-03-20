dotnet
{
    assembly(mscorlib)
    {
        type(System.Array; DotNetArray_NT) { }
        type(System.Type; DotNETType_NT) { }
    }
    
    assembly(zxing)
    {
        type(ZXing.BarcodeWriter;ZXingBarcodeWriter_NT){}
        type(ZXing.BarcodeFormat;ZXingBarcodeFormat_NT){}
        type(ZXing.Common.EncodingOptions;ZXingCommonEncodingOptions_NT){}
        type(ZXing.Common.BitMatrix;ZXingCommonBitMatrix_NT){}
    }
}