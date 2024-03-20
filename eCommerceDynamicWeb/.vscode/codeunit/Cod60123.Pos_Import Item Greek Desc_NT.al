codeunit 60123 "Pos_Import Item Greek Desc_NT"

{
    trigger OnRun()
    var
        i: Integer;
    begin
        /*
        {move descriptions to temp table
    Item.SETFILTER(GreekDesc, '<>%1','');
    IF Item.FINDSET THEN
      REPEAT
        testTable.INIT;
        testTable.ItemNo := Item."No.";
        testTable.GreekDescription := item."Greek Description";
        testTable.INSERT;
      UNTIL Item.NEXT = 0;

    EXIT;
    }
    */
        FileName := 'C:\ncr\NAV2016\lsitgr.txt';
        IF NOT EXISTS(FileName) THEN
            EXIT;
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;
        iFile.CREATEINSTREAM(iStream);

        StreamReader := StreamReader.StreamReader(iStream, encoding.GetEncoding('iso-8859-7')); //CS 

        i := 0;
        Window.OPEN('Item #1###############');

        WHILE NOT StreamReader.EndOfStream DO BEGIN
            iLine := StreamReader.ReadLine();
            IF (iLine <> '') AND (STRLEN(iLine) > 2) THEN BEGIN
                i += 1;
                ProcessLine();
                Window.UPDATE(1, ItemNo);
                IF Item.GET(ItemNo) THEN BEGIN
                    Item."Greek Description" := GreekDesc;
                    Item.MODIFY;
                END;
            END;
        END;
        iFile.CLOSE;
        StreamReader.Close();

        AddFileName := FORMAT(TODAY);
        AddFileName := DELCHR(AddFileName, '=', '/');
        AddFileName := DELCHR(AddFileName, '=', '/') + DELCHR(FORMAT(TIME), '=', ':');
        AddFileName := DELCHR(AddFileName, '=', ' ');
        _File.Copy(FileName, 'C:\ncr\NAV2016\Processed\' + AddFileName + '_lsitgr.txt');
        ERASE(FileName);
        Window.CLOSE;

    end;

    local procedure ProcessLine()
    begin
        ItemNo := '';
        GreekDesc := '';
        ItemNo := COPYSTR(iLine, 1, 15);
        //IF (STRLEN(iLine) >= 65) THEN
        // GreekDesc := COPYSTR(iLine,16,65)
        //ELSE IF (STRLEN(iLine) >= 40) THEN
        GreekDesc := COPYSTR(iLine, 16, 40)
        //ELSE IF (STRLEN(iLine) >= 16) THEN
        //GreekDesc := COPYSTR(iLine,16,STRLEN(iLine));
    end;

    var
        Item: Record Item;
        Window: Dialog;
        iFile: File;
        _File: DotNet file;
        iStream: InStream;
        Bar: Code[13];
        DivCode: Code[2];
        ItemCatCode: Code[4];
        ItemNo: Code[15];
        StoreCode: Code[2];
        UOM: Code[2];
        VATCode: Code[1];
        AddFileName: Text;
        Desc: Text[36];
        DivDesc: Text[30];
        FileName: Text;
        GreekDesc: Text[40];
        iLine: Text[1024];
        ItemCatDesc: Text[30];
        POSDesc: Text[20];
        encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;

}