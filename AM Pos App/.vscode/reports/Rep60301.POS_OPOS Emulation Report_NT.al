report 60301 "POS_OPOS Emulation Report_NT"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'Layouts/POS OPOS Emulation Report.rdlc';
    Caption = 'POS OPOS Emulation Report_NT';
    ShowPrintStatus = false;
    UseRequestPage = false;
    UseSystemPrinter = false;

    dataset
    {
        dataitem(Line; "Integer")
        {
            column(Number_Line; LineText[Line.Number])
            {
            }
            column(FontType; FontType[Line.Number])
            {
            }

            column(LineType; LineType[Line.Number])
            {
            }
            column(EncodedText; EncodedText)
            {
            }
            column(CmpInfoPicture; CmpInfo.Picture)
            {
            }
            column(ShowLogo; ShowLogo)
            {
            }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, NoOfLines);
            end;

            trigger OnAfterGetRecord()
            var
                PosBarcodeMgt: Codeunit "Pos_Barcode Management_NT";
            begin
                EncodedText := '';
                ShowLogo := 'False';
                if LineType[Line.Number] = 3 then
                    EncodedText := PosBarcodeMgt.GenerateBarcode(LineText[line.Number]);

                if LineType[Line.Number] = 4 then begin
                    if CmpInfo.Get() then
                        CmpInfo.CalcFields(Picture);
                    if CmpInfo.Picture.HasValue then
                        ShowLogo := 'True';
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        NoOfLines: Integer;
        LineText: array[10000] of Text[250];
        LineType: array[10000] of Integer;
        i: Integer;
        FontType: array[10000] of Integer;

    procedure SetLine(var sl: Record "LSC POS Print Buffer" temporary)
    var
    begin
        i := 0;
        if sl.FindSet() then
            repeat
                case sl.LineType of
                    sl.LineType::PrintLine, sl.LineType::PrintBarcode, sl.LineType::PrintLogo:
                        begin
                            i := i + 1;
                            LineText[i] := sl.Text;
                            LineType[i] := sl.LineType;
                            FontType[i] := sl.FontType;
                        end;
                end;
            until (sl.Next = 0);
        NoOfLines := i;
    end;

    var
        EncodedText: Text;
        ShowLogo: Text[10];
        CmpInfo: Record "Company Information";
}


