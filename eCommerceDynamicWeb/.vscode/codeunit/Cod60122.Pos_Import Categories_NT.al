codeunit 60122 "Pos_Import Categories_NT"
{
    trigger OnRun()
    var
        ItemCategory: Record "Item Category";
        ProductGroup: Record "LSc Retail Product Group";
        ItemFamily: Record "LSC Item Family";
        Vendor: Record Vendor;
        Division: Record "LSC Division";
        Department: Record "eCom_Item Department_NT";
    begin
        FileName := 'C:\ncr\NAV2016\lsdesc.txt';
        IF NOT iFile.OPEN(FileName) THEN
            EXIT;
        iFile.CREATEINSTREAM(iStream);
        WHILE NOT iStream.EOS DO BEGIN
            iStream.READTEXT(iLine);
            Type := COPYSTR(iLine, 1, 4);
            Code := COPYSTR(iLine, 5, 10);
            Desc := COPYSTR(iLine, 15, 30);
            CASE Type OF
                'SDIV': // Division
                    IF NOT Division.GET(Code) THEN BEGIN
                        CLEAR(Division);
                        Division.Code := Code;
                        Division.Description := Desc;
                        Division.INSERT;
                    END ELSE BEGIN
                        Division.Description := Desc;
                        Division.MODIFY;
                    END;
                'DIVN':
                    IF NOT ItemCategory.GET(Code) THEN BEGIN
                        CLEAR(ItemCategory);
                        ItemCategory.Code := Code;
                        ItemCategory.Description := Desc;
                        ItemCategory.INSERT;
                    END ELSE BEGIN
                        ItemCategory.Description := Desc;
                        ItemCategory.MODIFY;
                    END;
                'PGR':
                    IF NOT ProductGroup.GET('', Code) THEN BEGIN
                        CLEAR(ProductGroup);
                        ProductGroup.Code := Code;
                        ProductGroup.Description := Desc;
                        ProductGroup.INSERT;
                    END ELSE BEGIN
                        ProductGroup.Description := Desc;
                        ProductGroup.MODIFY;
                    END;
                'PGMN':
                    IF NOT Vendor.GET(Code) THEN BEGIN
                        CLEAR(Vendor);
                        Vendor."No." := Code;
                        Vendor.Name := Desc;
                        Vendor.INSERT;
                    END ELSE BEGIN
                        Vendor.Name := Desc;
                        Vendor.MODIFY;
                    END;
                'PGMJ':
                    IF NOT ItemFamily.GET(Code) THEN BEGIN
                        CLEAR(ItemFamily);
                        ItemFamily.Code := Code;
                        ItemFamily.Description := Desc;
                        ItemFamily.INSERT;
                    END ELSE BEGIN
                        ItemFamily.Description := Desc;
                        ItemFamily.MODIFY;
                    END;
                'PCLS':
                    IF NOT Department.GET(Code) THEN BEGIN
                        CLEAR(Department);
                        Department.Code := Code;
                        Department.Description := Desc;
                        Department.INSERT;
                    END ELSE BEGIN
                        Department.Description := Desc;
                        Department.MODIFY;
                    END;
            END;
        END;
        iFile.CLOSE();
        AddFileName := FORMAT(TODAY);
        AddFileName := DELCHR(AddFileName, '=', '/');
        AddFileName := DELCHR(AddFileName, '=', '/') + DELCHR(FORMAT(TIME), '=', ':');
        AddFileName := DELCHR(AddFileName, '=', ' ');
        _File.Copy(FileName, 'C:\ncr\NAV2016\Processed\' + AddFileName + '_lsdesc.txt');
        ERASE(FileName);

    end;

    var
        i: Integer;
        _File: DotNet file;
        iFile: File;
        iStream: InStream;
        FileName: Text;
        iLine: Text;
        Type: Code[10];
        Code: Code[10];
        Desc: Text[30];
        AddFileName: Text;
}
