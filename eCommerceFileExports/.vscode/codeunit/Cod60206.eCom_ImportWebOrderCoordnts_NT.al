codeunit 60206 eCom_ImportWebOrderCoordnts_NT
{
    TableNo = "LSC Scheduler Job Header";

    trigger OnRun()
    begin
        IF Text = '' THEN
            EXIT;
        ImportFile(Text);

    end;

    procedure ImportFile(FileName: Text)
    var
        SalesOrderHeader: Record "Sales Header";
        WebOrderCoordinates: Record "eCom_Web Order Coordinates_NT";
        iFile: File;
        iStream: InStream;
        TAB: Char;
        OrderId: Code[20];
        DashPosition: Integer;
        iLine: Text;
        DotNetArray: DotNet Array;
        DotNetString1: DotNet String;
        DotNetString2: DotNet String;
        encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
    begin
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;
        TAB := 9;
        DotNetString2 := FORMAT(TAB);
        iFile.CREATEINSTREAM(iStream);
        //20220221 WHILE NOT iStream.EOS DO BEGIN
        //20220221 iStream.READTEXT(iLine);
        StreamReader := StreamReader.StreamReader(iStream, encoding.GetEncoding('UTF-8'));//Greek iso-8859-7 //20220221
        WHILE NOT StreamReader.EndOfStream DO BEGIN//20220221
            iLine := StreamReader.ReadLine();//20220221
            DotNetString1 := iLine;
            IF NOT DotNetString1.IsNullOrWhiteSpace(DotNetString1) THEN BEGIN
                DotNetArray := DotNetString1.Split(DotNetString2.ToCharArray());
                CLEAR(WebOrderCoordinates);
                WebOrderCoordinates."Order ID" := DotNetArray.GetValue(1);
                WebOrderCoordinates.Name := DotNetArray.GetValue(5);
                WebOrderCoordinates.Address := DotNetArray.GetValue(6);
                WebOrderCoordinates."Postal Code" := DotNetArray.GetValue(7);
                WebOrderCoordinates.City := DotNetArray.GetValue(8);
                WebOrderCoordinates.Latitude := DotNetArray.GetValue(9);
                WebOrderCoordinates.Longitude := DotNetArray.GetValue(10);

                //CS NT 20220209 Get member contact from sales order..    
                IF (WebOrderCoordinates."Order ID" <> '') THEN BEGIN
                    OrderId := WebOrderCoordinates."Order ID";
                    DashPosition := STRPOS(OrderId, '-');
                    IF DashPosition > 0 THEN
                        OrderId := COPYSTR(OrderId, DashPosition + 1);
                    CLEAR(SalesOrderHeader);
                    SalesOrderHeader.SETRANGE("No.", OrderId);
                    IF SalesOrderHeader.FINDLAST THEN BEGIN
                        WebOrderCoordinates."Member Contact No." := SalesOrderHeader."Member Contact No.";
                    END;
                END;
                //..CS NT Get member contact from sales order

                IF NOT WebOrderCoordinates.INSERT THEN
                    WebOrderCoordinates.MODIFY;
            END;
        END;
        iFile.CLOSE();
        StreamReader.Close();//20220221
    end;
}
