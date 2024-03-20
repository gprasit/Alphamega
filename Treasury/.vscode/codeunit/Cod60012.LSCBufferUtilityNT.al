codeunit 60012 "LSC Buffer Utility_NT"
{

    var
        BufferRecRef: array[100] of RecordRef;
        BufferRecRefSet: array[100, 5] of RecordRef;
        BufferIndex: Record "LSC WS Node Buffer" temporary;
        Text001: Label 'All buffer indexes in use';
        Text002: Label 'Buffer already exists for table %1 and instance %2';
        Text003: Label 'No Buffer index available';
        Text004: Label 'Buffer index does not exists for table %1 and instance %2';

    procedure OpenBuffer(var RecRef_p: RecordRef; Instance_p: Integer)
    var
        i: Integer;
        IndexToUse: Integer;
    begin
        //OpenBuffer
        BufferIndex.Reset;
        if BufferIndex.Count > 100 then
            Error(Text001);

        BufferIndex.Reset;
        BufferIndex.SetRange(BufferIndex."Table No.", RecRef_p.Number);
        BufferIndex.SetRange(BufferIndex."Field No.", Instance_p);
        if BufferIndex.FindFirst then
            Error(Text002, RecRef_p.Number, Instance_p);

        i := 1;
        repeat
            if not BufferIndex.Get(i) then begin
                IndexToUse := i;
                i := 100;
            end;
            i := i + 1;
        until (i > 100);
        if IndexToUse <= 0 then
            Error(Text003);

        BufferIndex.Init;
        BufferIndex."Entry No." := IndexToUse;
        BufferIndex."Table No." := RecRef_p.Number;
        BufferIndex."Field No." := Instance_p;
        BufferIndex.Insert;

        BufferRecRef[IndexToUse].Open(RecRef_p.Number, true);
    end;

    internal procedure GetBufferIndex(TableNo_p: Integer; Instance_p: Integer): Integer
    begin
        //GetBufferIndex
        BufferIndex.Reset;
        BufferIndex.SetRange(BufferIndex."Table No.", TableNo_p);
        BufferIndex.SetRange(BufferIndex."Field No.", Instance_p);
        if not BufferIndex.FindFirst then
            Error(Text004, TableNo_p, Instance_p);

        exit(BufferIndex."Entry No.");
    end;

    procedure CloseBuffer(var RecRef_p: RecordRef; Instance_p: Integer)
    var
        Index: Integer;
    begin
        //CloseBuffer
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);
        BufferIndex.Get(Index);

        if BufferRecRef[Index].Number <> 0 then begin
            BufferRecRef[Index].Reset;
            BufferRecRef[Index].DeleteAll;
            BufferRecRef[Index].Close;
        end;

        BufferIndex.Delete;
    end;

    internal procedure GetRec(var RecRef_p: RecordRef; Instance_p: Integer): Boolean
    var
        Index: Integer;
    begin
        //GetRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        if BufferRecRef[Index].Get(RecRef_p.RecordId) then begin
            AssignRecRef(BufferRecRef[Index], RecRef_p);
            exit(true);
        end else begin
            Clear(RecRef_p);
            exit(false);
        end;
    end;

    procedure SetTableFilter(SetIndex_p: Integer; var RecRef_p: RecordRef; Instance_p: Integer)
    var
        Index: Integer;
    begin
        //SetTableFilter
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        BufferRecRefSet[Index] [SetIndex_p] := BufferRecRef[Index].Duplicate;
        BufferRecRefSet[Index] [SetIndex_p].SetView(RecRef_p.GetView);
    end;

    internal procedure FindRec(SetIndex_p: Integer; Which_p: Text[1024]; var RecRef_p: RecordRef; Instance_p: Integer): Boolean
    var
        Index: Integer;
    begin
        //FindRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        if Which_p = '=' then begin
            if BufferRecRefSet[Index] [SetIndex_p].Get(RecRef_p.RecordId) then begin
                AssignRecRef(BufferRecRefSet[Index] [SetIndex_p], RecRef_p);
                exit(true);
            end else begin
                Clear(RecRef_p);
                exit(false);
            end;
        end else begin
            if BufferRecRefSet[Index] [SetIndex_p].Find(Which_p) then begin
                AssignRecRef(BufferRecRefSet[Index] [SetIndex_p], RecRef_p);
                exit(true);
            end else begin
                Clear(RecRef_p);
                exit(false);
            end;
        end;
    end;

    procedure FindFirstRec(SetIndex_p: Integer; var RecRef_p: RecordRef; Instance_p: Integer): Boolean
    var
        Index: Integer;
    begin
        //FindFirstRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        if BufferRecRefSet[Index] [SetIndex_p].FindFirst then begin
            AssignRecRef(BufferRecRefSet[Index] [SetIndex_p], RecRef_p);
            exit(true);
        end else begin
            Clear(RecRef_p);
            exit(false);
        end;
    end;

    internal procedure FindLastRec(SetIndex_p: Integer; var RecRef_p: RecordRef; Instance_p: Integer): Boolean
    var
        Index: Integer;
    begin
        //FindLastRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        if BufferRecRefSet[Index] [SetIndex_p].FindLast then begin
            AssignRecRef(BufferRecRefSet[Index] [SetIndex_p], RecRef_p);
            exit(true);
        end else begin
            Clear(RecRef_p);
            exit(false);
        end;
    end;

    internal procedure FindSetRec(SetIndex_p: Integer; var RecRef_p: RecordRef; Instance_p: Integer): Boolean
    var
        Index: Integer;
    begin
        //FindSetRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        if BufferRecRefSet[Index] [SetIndex_p].FindSet then begin
            AssignRecRef(BufferRecRefSet[Index] [SetIndex_p], RecRef_p);
            exit(true);
        end else begin
            Clear(RecRef_p);
            exit(false);
        end;
    end;

    procedure NextRec(SetIndex_p: Integer; Steps_p: Integer; var RecRef_p: RecordRef; Instance_p: Integer): Integer
    var
        Steps: Integer;
        Index: Integer;
    begin
        //NextRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        Steps := BufferRecRefSet[Index] [SetIndex_p].Next(Steps_p);
        if Steps <> 0 then
            AssignRecRef(BufferRecRefSet[Index] [SetIndex_p], RecRef_p);
        exit(Steps);
    end;

    internal procedure IsEmptyRec(SetIndex_p: Integer; var RecRef_p: RecordRef; Instance_p: Integer): Boolean
    var
        Index: Integer;
    begin
        //IsEmptyRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        if BufferRecRefSet[Index] [SetIndex_p].IsEmpty then
            exit(true)
        else
            exit(false);
    end;

    internal procedure CountRec(SetIndex_p: Integer; var RecRef_p: RecordRef; Instance_p: Integer): Integer
    var
        Index: Integer;
    begin
        //CountRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        exit(BufferRecRefSet[Index] [SetIndex_p].Count);
    end;

    procedure UpdateRec(var RecRef_p: RecordRef; Instance_p: Integer)
    var
        RecField: FieldRef;
        RecKey: KeyRef;
        BufferRecField: FieldRef;
        BufferRecKey: KeyRef;
        i: Integer;
        RecFound: Boolean;
        Index: Integer;
    begin
        //UpdateRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        RecKey := RecRef_p.KeyIndex(1);
        BufferRecKey := BufferRecRef[Index].KeyIndex(1);
        for i := 1 to RecKey.FieldCount do begin
            RecField := RecKey.FieldIndex(i);
            BufferRecField := BufferRecKey.FieldIndex(i);
            BufferRecField.Value := RecField.Value;
        end;
        if BufferRecRef[Index].Find('=') then
            RecFound := true
        else
            RecFound := false;

        if not RecFound then begin
            BufferRecRef[Index].Init;
            for i := 1 to RecRef_p.FieldCount do begin
                RecField := RecRef_p.FieldIndex(i);
                BufferRecField := BufferRecRef[Index].FieldIndex(i);
                IF RecField.Type = RecField.Type::Blob then
                    RecField.CalcField();
                BufferRecField.Value := RecField.Value;
            end;
            BufferRecRef[Index].Insert;
        end else begin
            for i := 1 to RecRef_p.FieldCount do begin
                RecField := RecRef_p.FieldIndex(i);
                BufferRecField := BufferRecRef[Index].FieldIndex(i);
                IF RecField.Type = RecField.Type::Blob then
                    RecField.CalcField();
                BufferRecField.Value := RecField.Value;
            end;
            BufferRecRef[Index].Modify;
        end;
    end;

    internal procedure DeleteRec(var RecRef_p: RecordRef; Instance_p: Integer)
    var
        Index: Integer;
    begin
        //DeleteRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        BufferRecRef[Index].Get(RecRef_p.RecordId);
        BufferRecRef[Index].Delete;
    end;

    internal procedure DeleteAllRec(SetIndex_p: Integer; var RecRef_p: RecordRef; Instance_p: Integer)
    var
        Index: Integer;
    begin
        //DeleteAllRec
        Index := GetBufferIndex(RecRef_p.Number, Instance_p);

        BufferRecRefSet[Index] [SetIndex_p].DeleteAll;
    end;

    local procedure AssignRecRef(var pRecRefFrom: RecordRef; var pRecRefTo: RecordRef)
    var
        RecFieldFrom: FieldRef;
        RecFieldTo: FieldRef;
        i: Integer;
    begin
        //AssignRecRef
        for i := 1 to pRecRefFrom.FieldCount do begin
            RecFieldFrom := pRecRefFrom.FieldIndex(i);
            if RecFieldFrom.Active then begin
                RecFieldTo := pRecRefTo.Field(RecFieldFrom.Number);
                if Format(RecFieldFrom.Type) = 'BLOB' then
                    RecFieldFrom.CalcField;
                RecFieldTo.Value := RecFieldFrom.Value;
            end;
        end;
    end;

    procedure IsBufferOpen(var RecRef: RecordRef; Instance: Integer): Boolean
    begin
        BufferIndex.Reset;
        BufferIndex.SetRange(BufferIndex."Table No.", RecRef.Number);
        BufferIndex.SetRange(BufferIndex."Field No.", Instance);
        exit(not BufferIndex.IsEmpty);
    end;

    procedure GetTableList(var WebTableBuffer: Record "LSC Web Table Buffer" temporary)
    begin
        WebTableBuffer.RESET;
        WebTableBuffer.DELETEALL;

        BufferIndex.RESET;
        IF BufferIndex.FINDSET THEN
            REPEAT
                WebTableBuffer.INIT;
                WebTableBuffer."Entry No." := BufferIndex."Entry No.";
                WebTableBuffer."Table No." := BufferIndex."Table No.";
                WebTableBuffer."Record Index" := BufferIndex."Field No.";
                WebTableBuffer.INSERT;
            UNTIL BufferIndex.NEXT = 0;
    end;
}


