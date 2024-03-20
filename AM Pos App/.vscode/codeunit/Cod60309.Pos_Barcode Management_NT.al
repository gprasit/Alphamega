codeunit 60309 "Pos_Barcode Management_NT"
{
    trigger OnRun()
    begin

    end;

    procedure GenerateBarcode(TextToConvertAsBarcode: Text) : Text
    var
        BarcodeWriter: DotNet ZXingBarcodeWriter_NT;
        BarcodeFormat: DotNet ZXingBarcodeFormat_NT;
        EncodingOption: DotNet ZXingCommonEncodingOptions_NT;
        Stream: DotNet MemoryStream;
        Bitmap: DotNet Bitmap;
        ImageFormat: DotNet ImageFormat;
        OStream: OutStream;
        BitMatrix: DotNet ZXingCommonBitMatrix_NT;
        ByteArray: DotNet Array;
        ImageString: DotNet String;
        Convert: DotNet Convert;

    begin
        EncodingOption := EncodingOption.EncodingOptions();
        EncodingOption.Height := 100;
        EncodingOption.Width := 100;

        BarcodeWriter := BarcodeWriter.BarcodeWriter();
        //BarcodeWriter.Format := BarcodeFormat.CODE_39;
        BarcodeWriter.Format := BarcodeFormat.CODE_39;
        BarcodeWriter.Options := EncodingOption;
        BitMatrix := BarcodeWriter.Encode(TextToConvertAsBarcode);
        Bitmap := BarcodeWriter.Write(BitMatrix);

        Stream := Stream.MemoryStream();
        Bitmap.Save(Stream, ImageFormat.Png);
        ByteArray := Stream.GetBuffer();
        ImageString := Convert.ToBase64String(ByteArray);
        exit(ImageString.ToString());
    end;

    var
        myInt: Integer;
}
