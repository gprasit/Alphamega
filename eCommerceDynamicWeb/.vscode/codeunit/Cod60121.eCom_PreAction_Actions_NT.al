codeunit 60121 "eCom_PreAction -> Actions_NT"
{
   Description ='Copy of LSC PreAction -> Actions since marked as internal';
    trigger OnRun()
    begin
        if not PreSetup.Get then
            PreSetup.Insert;

        OpenLog;
        if GuiAllowed then
            Window.Open('@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ \' +
                        '#1#############################\' +
                        Text000 +
                        Text001);

        Counter := 0;
        Setup.Get;
        Log(Text002);
        if GuiAllowed then
            Window.Update(1, Text003);
        CreateActions;
        Log(Text004);
        if GuiAllowed then
            Window.Close;
    end;

    var
        Text000: Label 'PreAction: #3##################\';
        Text001: Label 'LinkUp:    #4##################';
        Text002: Label 'Starting Preaction->Action';
        Text003: Label 'Creating Actions from Preactions';
        Text004: Label 'Finish Preaction->Action';
        Text008: Label 'Linkfilters for table %1 are missing';
        PreActionLog: Record "LSC Preaction Log";
        PreSetup: Record "LSC Preaction Setup";
        Setup: Record "LSC Retail Setup";
        "Actions": Record "LSC Actions";
        ActionCounters: Record "LSC Action Counters";
        PreAction: Record "LSC Preaction";
        SystemPreaction: Record "LSC System Preaction";
        tmpTableDistribution: Record "LSC Table Distribution Setup" temporary;
        PreloadAction: array[100] of Record "LSC Preload Action" temporary;
        PreloadAction2: Record "LSC Preload Action";
        PreloadActionTmp: Record "LSC Preload Action" temporary;
        DistIncludeList: Record "LSC Distrib. Incl./Excl. List";
        LocGroupFilter: Record "LSC Location Table" temporary;
        BOUtil: Codeunit "LSC BO Utils";
        Window: Dialog;
        PreloadWindow: Dialog;
        NextAction: Integer;
        NextEntryNo: Integer;
        TableName: Text[30];
        ErrorVal: Integer;
        ModuleVal: Integer;
        ErrorText: Text[250];
        NumErrors: Integer;
        Counter: Integer;
        On: Boolean;
        ActionSelected: Integer;
        ActionCommited: Integer;
        RecRef: array[100] of RecordRef;
        FieldReff: array[100] of FieldRef;
        KeyReff: array[100] of KeyRef;
        glIndex: Integer;
        Text009: Label 'Cannot open table %1';
        Text010: Label 'Cannot set filter on table %1, field %2';
        Text011: Label 'Master record not found. Master Table %1. Table %2 - Key %3';
        OldPreaction: Record "LSC Preaction";
        OldInKey: Text[250];
        OldTableNo: Integer;
        Preload: Boolean;
        PreloadRecRef: RecordRef;
        PreloadKeyRef: array[1] of KeyRef;
        PreloadFieldRef: FieldRef;
        NextPreloadAction: Integer;
        GroupFilter: Text[250];
        NumLocations: Integer;
        Text012: Label 'Cannot set field value on table %1, field %2';

    procedure CreateActions()
    var
        TableDistribution: Record "LSC Table Distribution Setup";
        TableLink: Record "LSC Table Links";
        RecTableNo: Integer;
        RecKey: Text[250];
        ActSelectedOld: Integer;
        ActCommitedOld: Integer;
    begin
        if not ActionCounters.Get then
            ActionCounters.Insert;

        NumErrors := 0;
        ActSelectedOld := ActionCounters."Action Selected";
        ActCommitedOld := ActionCounters."Action Commited";

        if PreAction.FindLast then begin
            ActionSelected := ActionCounters."Action Selected" + 1;
            ActionCounters."Action Selected" := PreAction."Entry No.";
            ActionCounters.Modify;
            Commit;
        end
        else
            exit;

        if SystemPreaction.FindLast then
            NextEntryNo := SystemPreaction."Entry No." + 1
        else
            NextEntryNo := 1;

        Actions.LockTable;
        if Actions.FindLast then
            NextAction := Actions."Entry No." + 1
        else
            NextAction := 1;

        TableLink.Reset;
        TableLink.SetCurrentKey("Master Table ID");

        PreAction.SetRange("Entry No.", ActionCounters."Action Commited" + 1, ActionCounters."Action Selected");
        PreAction.SetRange(PreAction."Link Down", true);
        if PreAction.FindSet() then
            repeat
                if PreAction."Table No." = Database::"LSC Distribution List" then begin
                    Evaluate(RecTableNo, BOUtil.SeparateActKey(1, PreAction.Key));
                    RecKey := BOUtil.SeparateActKey(2, PreAction.Key);
                end else begin
                    RecTableNo := PreAction."Table No.";
                    RecKey := PreAction.Key;
                end;

                TableLink.SetRange("Master Table ID", RecTableNo);
                if TableLink.FindFirst() then
                    FindDistrDown(1, RecTableNo, '', RecKey, PreAction.Action);
                if GuiAllowed then begin
                    Window.Update(3, PreAction."Entry No.");
                    Window.Update(4, PreAction."Link Down");
                end;
            until PreAction.Next = 0;

        Commit;
        SelectLatestVersion;

        PreAction.Reset;

        TableLink.Reset;
        TableLink.SetCurrentKey("Table ID");

        PreAction.SetRange("Entry No.", ActionCounters."Action Commited" + 1, ActionCounters."Action Selected");
        if PreAction.FindSet() then
            repeat
                if PreAction.Action <> PreAction.Action::Delete then begin
                    TableDistribution.SetRange("Table ID", PreAction."Table No.");
                    if not TableDistribution.FindFirst() then
                        InsertActions(PreAction."Table No.", PreAction.Key)
                    else
                        FindDistr(1, PreAction."Table No.", '', PreAction.Key);
                end else
                    DeleteActions(PreAction."Table No.", PreAction.Key);

                if GuiAllowed then begin
                    Window.Update(3, PreAction."Entry No.");
                    Window.Update(4, PreAction."Link Down");
                end;
            until PreAction.Next = 0;

        if NumErrors = 0 then begin
            ActionCounters."Action Commited" := ActionCounters."Action Selected";
            ActionCounters.Modify;
        end else begin
            ActionCounters."Action Selected" := ActSelectedOld;
            ActionCounters."Action Commited" := ActCommitedOld;
        end;

        SystemPreaction.Reset;
        SystemPreaction.DeleteAll;

        Commit;

        if NumErrors = 0 then
            ActionCommited := ActionCounters."Action Selected";
    end;

    procedure InsertActions(TableNo: Integer; InKey: Text[250])
    var
        TableDistribution: Record "LSC Table Distribution Setup";
        DistributionList: Record "LSC Distribution List";
        RecKey: Text[250];
        Group: Code[10];
        SubGroup: Code[10];
        SchedulerSetup: Record "LSC Scheduler Setup";
        SeparateChr: Text[1];
    begin
        // InsertActions(TableNo : Integer;InKey : Text[100])
        //
        // This function can be entered by 2 ways.
        // 1 - If the table is distributed "By Master Only". Then we have traversed the links to find the
        //     appropritate distribution for the table.
        // 2 - If the table is using distribution other than

        SchedulerSetup.Get;
        SeparateChr := SchedulerSetup."Loc. Group Filter Delimiter";
        if SeparateChr = '' then
            SeparateChr[1] := 177;

        SystemPreaction.Reset;
        SystemPreaction.SetCurrentKey("Org. Entry No.");

        if TableNo = Database::"LSC Distribution List" then begin
            RecKey := BOUtil.SeparateActKey(2, InKey);
            Actions.Init;
            Actions."Entry No." := NextAction;
            NextAction := NextAction + 1;

            Actions."Location Group Filter" := BOUtil.SeparateActKey(3, InKey) + SeparateChr + BOUtil.SeparateActKey(4, InKey);

            Actions.Action := Actions.Action::"Update-Add";
            Evaluate(Actions."Table No.", BOUtil.SeparateActKey(1, InKey));
            Actions.Key := BOUtil.ConvertTableKeyToActKey(RecKey);
            Actions."Additional Values" := PreAction."Additional Values";
            Actions.Date := Today;
            Actions.Time := Time;
            Actions."User ID" := PreAction."User ID";
            Actions.BatchID := PreAction.BatchID;
            Actions.Insert;

            SystemPreaction.SetRange("Org. Entry No.", PreAction."Entry No.");
            if SystemPreaction.FindSet() then
                repeat
                    Actions."Entry No." := NextAction;
                    NextAction := NextAction + 1;
                    Actions."Table No." := SystemPreaction.Table;
                    Actions.Key := SystemPreaction.Key;
                    Actions."Additional Values" := SystemPreaction."Additional Values";
                    Actions.Insert;
                until SystemPreaction.Next = 0;

            exit;
        end;


        TableDistribution.SetRange("Table ID", TableNo);
        if not TableDistribution.FindFirst() then begin
            if NoFilterExists(Group, SubGroup) then begin
                // This table has no distribution lines, and is therefore distributed to all locations
                Actions.Init;
                Actions."Entry No." := NextAction;
                NextAction += 1;

                Actions."Location Group Filter" := Group + SeparateChr + SubGroup;

                Actions.Action := Actions.Action::"Update-Add";
                Actions."Table No." := PreAction."Table No.";
                Actions.Key := PreAction.Key;
                Actions."Additional Values" := PreAction."Additional Values";
                Actions.Date := Today;
                Actions.Time := Time;
                Actions."User ID" := PreAction."User ID";
                Actions.BatchID := PreAction.BatchID;
                Actions.Insert;

                SystemPreaction.SetRange("Org. Entry No.", PreAction."Entry No.");
                if SystemPreaction.FindSet() then
                    repeat
                        Actions."Entry No." := NextAction;
                        NextAction += 1;
                        Actions."Table No." := SystemPreaction.Table;
                        Actions.Key := SystemPreaction.Key;
                        Actions."Additional Values" := SystemPreaction."Additional Values";
                        Actions.Insert;
                    until SystemPreaction.Next = 0;
                exit;
            end;
        end else begin
            case TableDistribution."Distribution Type" of
                TableDistribution."Distribution Type"::All:
                    begin
                        if NoFilterExists(Group, SubGroup) then begin
                            Actions.Init;
                            Actions."Entry No." := NextAction;
                            NextAction += 1;

                            Actions."Location Group Filter" := Group + SeparateChr + SubGroup;

                            if PreAction.Action <> PreAction.Action::Delete then
                                Actions.Action := Actions.Action::"Update-Add"
                            else
                                Actions.Action := Actions.Action::Delete;
                            Actions."Table No." := PreAction."Table No.";
                            Actions.Key := PreAction.Key;
                            Actions."Additional Values" := PreAction."Additional Values";
                            Actions.Date := Today;
                            Actions.Time := Time;
                            Actions."User ID" := PreAction."User ID";
                            Actions.BatchID := PreAction.BatchID;
                            Actions.Insert;

                            SystemPreaction.SetRange("Org. Entry No.", PreAction."Entry No.");
                            if SystemPreaction.FindSet() then
                                repeat
                                    Actions."Entry No." := NextAction;
                                    NextAction := NextAction + 1;
                                    Actions."Table No." := SystemPreaction.Table;
                                    Actions.Key := SystemPreaction.Key;
                                    Actions."Additional Values" := SystemPreaction."Additional Values";
                                    Actions.Insert;
                                until SystemPreaction.Next = 0;
                        end;
                        exit;
                    end;
                TableDistribution."Distribution Type"::"No Distribution",
                TableDistribution."Distribution Type"::"By Master Only":
                    begin
                        // this should be logged since a top-level table should never
                        // have these types of distribution.
                        exit;
                    end;
            end;
        end;

        DistributionList.SetRange("Table ID", TableNo);

        DistributionList.SetRange(Value, ConvertStr(InKey, ';', SeparateChr));

        if DistributionList.FindSet() then
            repeat
                Clear(Actions);
                Actions."Entry No." := NextAction;
                NextAction += 1;

                Actions."Location Group Filter" := DistributionList."Group Code" + SeparateChr + DistributionList."Subgroup Code";

                if PreAction.Action <> PreAction.Action::Delete then
                    Actions.Action := Actions.Action::"Update-Add"
                else
                    Actions.Action := Actions.Action::Delete;
                Actions."Table No." := PreAction."Table No.";
                Actions.Key := PreAction.Key;
                Actions."Additional Values" := PreAction."Additional Values";
                Actions.Date := Today;
                Actions.Time := Time;
                Actions."User ID" := PreAction."User ID";
                Actions.BatchID := PreAction.BatchID;
                Actions.Insert;

                SystemPreaction.SetRange("Org. Entry No.", PreAction."Entry No.");
                if SystemPreaction.FindSet() then
                    repeat
                        Actions."Entry No." := NextAction;
                        NextAction := NextAction + 1;
                        Actions."Table No." := SystemPreaction.Table;
                        Actions.Key := SystemPreaction.Key;
                        Actions."Additional Values" := SystemPreaction."Additional Values";
                        Actions.Insert;
                    until SystemPreaction.Next = 0;
            until DistributionList.Next = 0;
    end;

    procedure DeleteActions(TableNo: Integer; InKey: Text[250])
    var
        Group: Code[10];
        SubGroup: Code[10];
        RecKey: Text[250];
        SchedulerSetup: Record "LSC Scheduler Setup";
        SeparateChr: Text[1];
    begin
        SchedulerSetup.Get;
        SeparateChr := SchedulerSetup."Loc. Group Filter Delimiter";
        if SeparateChr = '' then
            SeparateChr[1] := 177;

        if TableNo = Database::"LSC Distribution List" then begin
            RecKey := BOUtil.SeparateActKey(2, InKey);
            Actions.Init;
            Actions."Entry No." := NextAction;
            NextAction := NextAction + 1;

            Actions."Location Group Filter" := BOUtil.SeparateActKey(3, InKey) + SeparateChr + BOUtil.SeparateActKey(4, InKey);

            Actions.Action := Actions.Action::Delete;
            Evaluate(Actions."Table No.", BOUtil.SeparateActKey(1, InKey));
            Actions.Key := BOUtil.ConvertTableKeyToActKey(RecKey);
            Actions."Additional Values" := PreAction."Additional Values";
            Actions.Date := Today;
            Actions.Time := Time;
            Actions."User ID" := PreAction."User ID";
            Actions.BatchID := PreAction.BatchID;
            Actions.Insert;

            SystemPreaction.Reset;
            SystemPreaction.SetCurrentKey("Org. Entry No.");
            SystemPreaction.SetRange("Org. Entry No.", PreAction."Entry No.");
            if SystemPreaction.FindSet() then
                repeat
                    Actions."Entry No." := NextAction;
                    NextAction := NextAction + 1;
                    Actions."Table No." := SystemPreaction.Table;
                    Actions.Key := SystemPreaction.Key;
                    Actions."Additional Values" := SystemPreaction."Additional Values";
                    Actions.Insert;
                until SystemPreaction.Next = 0;

            exit;
        end;

        if NoFilterExists(Group, SubGroup) then begin
            // This table has no distribution lines, and is therefore distributed to all locations
            Actions.Init;
            Actions."Entry No." := NextAction;
            NextAction := NextAction + 1;

            Actions."Location Group Filter" := Group + SeparateChr + SubGroup;

            Actions.Action := Actions.Action::Delete;
            Actions."Table No." := PreAction."Table No.";
            Actions.Key := PreAction.Key;
            Actions."Additional Values" := PreAction."Additional Values";
            Actions.Date := Today;
            Actions.Time := Time;
            Actions."User ID" := PreAction."User ID";
            Actions.BatchID := PreAction.BatchID;
            Actions.Insert;
        end;
    end;

    procedure FindDistr(Index: Integer; TableNo: Integer; InFields: Text[250]; InKey: Text[250])
    var
        TableDistribution: Record "LSC Table Distribution Setup";
        TableLinks: Record "LSC Table Links";
        Infilters: array[30] of Text[250];
        Keyfields: array[30] of Integer;
        LinkedTo: Integer;
        Pos: Integer;
        i: Integer;
        iKeyNo: Integer;
        KeyText: Text[1024];
    begin
        // FindDistr(Index : Integer;TableNo : Integer;InFields : Text[250];InKey : Text[250])
        //
        // Index    : indicates how often the function has been called
        // TableNo  : Table number
        // InFields : Contains the fields in the primary key?
        // InKey    : Contains the values of the primary key

        glIndex := Index;

        if not Preload then
            if Counter = 100 then begin
                Counter := 0;
                if On then begin
                    if GuiAllowed then
                        Window.Update(2, 1);
                    On := false;
                end else begin
                    if GuiAllowed then
                        Window.Update(2, 10000);
                    On := true;
                end;
            end;

        Counter := Counter + 1;

        RecRef[Index].Open(TableNo);

        if RecRef[Index].Number = 0 then begin
            ErrorVal := 0;
            ModuleVal := 0;
            Log(StrSubstNo(Text009, TableNo));
            NumErrors := NumErrors + 1;
            exit;
        end;

        // Select the primary key.
        KeyReff[Index] := RecRef[Index].KeyIndex(1);

        // Split up they list of primary key fields or filter fields
        if InFields <> '' then begin
            Pos := StrPos(InFields, ',');
            i := 0;
            while Pos <> 0 do begin
                i := i + 1;
                Evaluate(Keyfields[i], CopyStr(InFields, 1, Pos - 1));
                InFields := CopyStr(InFields, Pos + 1);
                Pos := StrPos(InFields, ',');
            end;
            i := i + 1;
            Evaluate(Keyfields[i], InFields);
            // Select optimal key
            if tmpTableDistribution.Get(TableNo, 0) then
                iKeyNo := tmpTableDistribution."Preaction Key"
            else begin
                iKeyNo := SelectGoodKey(Keyfields, i);
                tmpTableDistribution."Table ID" := TableNo;
                tmpTableDistribution."Preaction Key" := iKeyNo;
                tmpTableDistribution.Insert;
            end;

            if iKeyNo <> 1 then begin
                KeyText := '';
                KeyReff[Index] := RecRef[Index].KeyIndex(iKeyNo);
                for i := 1 to KeyReff[Index].FieldCount do begin
                    FieldReff[Index] := KeyReff[Index].FieldIndex(i);
                    KeyText := KeyText + ',' + FieldReff[Index].Caption;
                end;
                KeyText := CopyStr(KeyText, 2);
                KeyText := 'SORTING(' + KeyText + ')';
                RecRef[Index].SetView(KeyText);
            end;
        end else begin
            for i := 1 to KeyReff[Index].FieldCount do begin
                FieldReff[Index] := KeyReff[Index].FieldIndex(i);
                Keyfields[i] := FieldReff[Index].Number;
            end;
        end;

        // Split up the string containing the values of the filter for the rec.
        i := 0;
        Pos := StrPos(InKey, ';');
        while Pos <> 0 do begin
            i := i + 1;
            Infilters[i] := CopyStr(InKey, 1, Pos - 1);
            InKey := CopyStr(InKey, Pos + 1);
            Pos := StrPos(InKey, ';');
        end;
        i := i + 1;
        Infilters[i] := InKey;

        i := 1;
        while Keyfields[i] <> 0 do begin
            FieldReff[Index] := RecRef[Index].Field(Keyfields[i]);
            if not FieldFilter(Infilters[i]) then begin
                ErrorVal := 1;
                ModuleVal := 0;
                Log(StrSubstNo(Text010, TableNo, FieldReff[Index].Number));
                NumErrors := NumErrors + 1;
                RecRef[Index].Close;
                Clear(FieldReff[Index]);
                Clear(KeyReff[Index]);
                exit;
            end;
            i := i + 1;
        end;

        if RecRef[Index].FindSet() then begin
            repeat
                LinkedTo := FindLinkedTable(TableNo);
                if LinkedTo = 0 then begin
                    // There is no master table to be found, so we insert the action.
                    InKey := '';
                    InFields := '';
                    KeyReff[Index] := RecRef[Index].KeyIndex(1);
                    for i := 1 to KeyReff[Index].FieldCount do begin
                        FieldReff[Index] := KeyReff[Index].FieldIndex(i);
                        InKey := InKey + ';' + FormatFieldReferenceValue(TableNo, FieldReff[Index]);
                    end;
                    InKey := CopyStr(InKey, 2);

                    // The following if-statement was included in order to cut down the number of identical actions
                    // which happened if the record had many intermediate master records. Think item, price, price group
                    // where the item has many prices in the same price group. We therefore check if we are creating
                    // an action for the same master record again. If so, we dont don anything. Same if this is a
                    // preload action, since we handle them differently.

                    if Preload then
                        InsertPreloadAction(TableNo, InKey)
                    else begin
                        if (InKey <> OldInKey) or
                           (OldTableNo <> TableNo) or
                           (PreAction."Table No." <> OldPreaction."Table No.") or
                           (PreAction.Key <> OldPreaction.Key) or
                           (PreAction.Action <> OldPreaction.Action)
                         then begin
                            InsertActions(TableNo, InKey);
                            OldPreaction := PreAction;
                            OldTableNo := TableNo;
                            OldInKey := InKey;
                        end;
                    end;
                end
                else begin
                    // We have found a master table. Now we find out how the master table is distributed.
                    TableDistribution.SetRange("Table ID", TableNo);
                    TableDistribution.SetRange("Master Table ID", LinkedTo);
                    if TableDistribution.FindFirst() then begin
                        InKey := '';
                        InFields := '';
                        TableLinks.SetRange("Table ID", TableDistribution."Table ID");
                        TableLinks.SetRange("Master Table ID", TableDistribution."Master Table ID");
                        if TableLinks.FindSet() then
                            repeat
                                InFields := InFields + ',' + DelChr(Format(TableLinks."Main Field No."), '=', ',.');
                                case TableLinks.Type of
                                    TableLinks.Type::Constant:
                                        InKey := InKey + ';' + TableLinks.Value;
                                    TableLinks.Type::Filter:
                                        begin
                                            case TableLinks."Replace % with" of
                                                TableLinks."Replace % with"::" ":
                                                    InKey := InKey + ';' + TableLinks.Value;
                                                TableLinks."Replace % with"::"1=TODAY":
                                                    InKey := InKey + ';' + StrSubstNo(TableLinks.Value, Today);
                                                TableLinks."Replace % with"::"1=TODAY 2=0D":
                                                    InKey := InKey + ';' + StrSubstNo(TableLinks.Value, Today, '''''');
                                                TableLinks."Replace % with"::"1=0D":
                                                    InKey := InKey + ';' + StrSubstNo(TableLinks.Value, '''''');
                                            end;
                                        end;
                                    TableLinks.Type::Field:
                                        begin
                                            FieldReff[Index] := RecRef[Index].Field(TableLinks."Field No.");
                                            InKey := InKey + ';' + FormatFieldReferenceValue(RecRef[Index].NUMBER, FieldReff[Index]);
                                        end;
                                end;
                            until TableLinks.Next = 0;

                        // Trim the leading commas from the strings
                        InFields := CopyStr(InFields, 2);
                        InKey := CopyStr(InKey, 2);

                        // This is the recursive call. We now call the function again to find the distribution
                        // for the next master table.

                        if (InFields = '') and (InKey = '') then begin
                            ErrorVal := 1;
                            ModuleVal := 0;
                            Log(StrSubstNo(Text008, TableNo));
                        end else
                            FindDistr(Index + 1, TableLinks."Master Table ID", InFields, InKey);
                        glIndex := Index;
                    end;
                end;
            until RecRef[Index].Next = 0;
        end else begin
            ErrorVal := 1;
            ModuleVal := 0;
            Log(StrSubstNo(Text011, TableNo, PreAction."Table No.", PreAction.Key));
        end;

        RecRef[Index].Close;
        Clear(FieldReff[Index]);
        Clear(KeyReff[Index]);
    end;

    procedure FindLinkedTable(TableNo: Integer): Integer
    var
        TableLink: Record "LSC Table Links";
        LinkCondition: Record "LSC Link Conditions";
        ExitNow: Boolean;
        LinkedTabNo: Integer;
    begin
        // FindLinkedTable(TableNo : Integer) : Integer
        //
        // TableNo : Table number.
        //
        // Returns : the table no. of the master table, if it does exits.

        TableLink.SetRange("Table ID", TableNo);
        if not TableLink.FindFirst() then
            exit(0);
        if TableLink.Count = 1 then
            exit(TableLink."Master Table ID");

        ExitNow := false;
        LinkedTabNo := 0;
        repeat
            LinkCondition.SetRange("Table ID", TableLink."Table ID");
            LinkCondition.SetRange("Master Table ID", TableLink."Master Table ID");
            if LinkCondition.FindSet() then
                repeat
                    if not SameValue(TableNo, LinkCondition."Field No.", LinkCondition.Value, LinkCondition.Type) then
                        ExitNow := true;
                until (LinkCondition.Next = 0) or ExitNow;
            if ExitNow then
                ExitNow := false
            else begin
                ExitNow := true;
                LinkedTabNo := TableLink."Master Table ID";
            end;
        until (TableLink.Next = 0) or ExitNow;
        exit(LinkedTabNo);
    end;

    procedure SameValue(TabNo: Integer; FieldNo: Integer; Value: Text[250]; Type: Integer): Boolean
    var
        "Field": Record "Field";
        InDate: Date;
        Date2: Date;
        InDec: Decimal;
        Dec2: Decimal;
        InInt: Integer;
        Int2: Integer;
        InTime: Time;
        Time2: Time;
        BoolTxt: Text[10];
        RecFieldValue: Variant;
    begin
        if not Field.Get(TabNo, FieldNo) then
            exit(false);

        FieldReff[glIndex] := RecRef[glIndex].Field(FieldNo);
        RecFieldValue := FieldReff[glIndex].Value;

        case Field.Type of
            Field.Type::Text:
                if Format(RecFieldValue) <> Value then
                    exit(false)
                else
                    exit(true);
            Field.Type::Code:
                if Format(RecFieldValue) <> Value then
                    exit(false)
                else
                    exit(true);

            Field.Type::Date:
                begin
                    if not Evaluate(InDate, Value) then
                        exit(false);
                    Date2 := RecFieldValue;
                    if InDate = Date2 then
                        exit(true)
                    else
                        exit(false);
                end;
            Field.Type::Time:
                begin
                    if not Evaluate(InTime, Value) then
                        exit(false);
                    Time2 := RecFieldValue;
                    if InTime = Time2 then
                        exit(true)
                    else
                        exit(false);
                end;
            Field.Type::Integer:
                begin
                    if not Evaluate(InInt, Value) then
                        exit(false);
                    Int2 := RecFieldValue;
                    if InInt = Int2 then
                        exit(true)
                    else
                        exit(false);
                end;
            Field.Type::Decimal:
                begin
                    if not Evaluate(InDec, Value) then
                        exit(false);
                    Dec2 := RecFieldValue;
                    if InDec = Dec2 then
                        exit(true)
                    else
                        exit(false);
                end;
            Field.Type::Option:
                begin
                    if not Evaluate(InInt, Value) then
                        exit(false);
                    Int2 := RecFieldValue;
                    if InInt = Int2 then
                        exit(true)
                    else
                        exit(false);
                end;
            Field.Type::Boolean:
                begin
                    BoolTxt := Format(false);
                    if BoolTxt = Value then
                        Value := '0'
                    else begin
                        BoolTxt := Format(true);
                        if BoolTxt = Value then
                            Value := '1';
                    end;
                    if not Evaluate(InInt, Value) then
                        exit(false);
                    Int2 := RecFieldValue;
                    if InInt = Int2 then
                        exit(true)
                    else
                        exit(false);
                end;
        end;
    end;

    procedure FindDistrDown(Index: Integer; TableNo: Integer; InFields: Text[250]; InKey: Text[250]; ActionType: Integer)
    var
        Link: Record "LSC Table Links";
        LinkCond: Record "LSC Table Links";
        Filters: Record "LSC Table Links";
        Infilters: array[30] of Text[250];
        Keyfields: array[30] of Integer;
        Pos: Integer;
        i: Integer;
        iKeyNo: Integer;
        FiltersOk: Boolean;
        KeyText: Text[1024];
        FindRecOk: Boolean;
    begin
        glIndex := Index;

        if Counter = 100 then begin
            Counter := 0;
            if On then begin
                if GuiAllowed then
                    Window.Update(2, 1);
                On := false;
            end
            else begin
                if GuiAllowed then
                    Window.Update(2, 10000);
                On := true;
            end;
        end;

        Counter := Counter + 1;

        RecRef[Index].Open(TableNo);
        if RecRef[Index].Number = 0 then begin
            ErrorVal := 0;
            ModuleVal := 0;
            Log(StrSubstNo(Text009, TableNo));
            NumErrors := NumErrors + 1;
            RecRef[Index].CLOSE;
            CLEAR(FieldReff[Index]);
            CLEAR(KeyReff[Index]);
            exit;
        end;

        // Select the primary key.
        KeyReff[Index] := RecRef[Index].KeyIndex(1);

        if InFields <> '' then begin
            Pos := StrPos(InFields, ',');
            i := 0;
            while Pos <> 0 do begin
                i := i + 1;
                Evaluate(Keyfields[i], CopyStr(InFields, 1, Pos - 1));
                InFields := CopyStr(InFields, Pos + 1);
                Pos := StrPos(InFields, ',');
            end;
            i := i + 1;
            Evaluate(Keyfields[i], InFields);
            // Select optimal key
            if tmpTableDistribution.Get(TableNo, 0) then
                iKeyNo := tmpTableDistribution."Preaction Key"
            else begin
                iKeyNo := SelectGoodKey(Keyfields, i);
                tmpTableDistribution."Table ID" := TableNo;
                tmpTableDistribution."Preaction Key" := iKeyNo;
                tmpTableDistribution.Insert;
            end;

            if iKeyNo <> 1 then begin
                KeyText := '';
                KeyReff[Index] := RecRef[Index].KeyIndex(iKeyNo);
                for i := 1 to KeyReff[Index].FieldCount do begin
                    FieldReff[Index] := KeyReff[Index].FieldIndex(i);
                    KeyText := KeyText + ',' + FieldReff[Index].Caption;
                end;
                KeyText := CopyStr(KeyText, 2);
                KeyText := 'SORTING(' + KeyText + ')';
                RecRef[Index].SetView(KeyText);
            end;
        end else begin
            for i := 1 to KeyReff[Index].FieldCount do begin
                FieldReff[Index] := KeyReff[Index].FieldIndex(i);
                Keyfields[i] := FieldReff[Index].Number;
            end;
        end;

        i := 0;
        Pos := StrPos(InKey, ';');
        while Pos <> 0 do begin
            i := i + 1;
            Infilters[i] := CopyStr(InKey, 1, Pos - 1);
            InKey := CopyStr(InKey, Pos + 1);
            Pos := StrPos(InKey, ';');
        end;
        i := i + 1;
        Infilters[i] := InKey;

        i := 1;
        while Keyfields[i] <> 0 do begin
            FieldReff[Index] := RecRef[Index].Field(Keyfields[i]);
            if not FieldFilter(Infilters[i]) then begin
                ErrorVal := 1;
                ModuleVal := 0;
                Log(StrSubstNo(Text010, TableNo, FieldReff[Index].Number));
                NumErrors := NumErrors + 1;
                RecRef[Index].CLOSE;
                CLEAR(FieldReff[Index]);
                CLEAR(KeyReff[Index]);
                exit;
            end;
            i := i + 1;
        end;


        // Now we need to address the situation where we have deleted the record but still want
        // to create delete actions for the records below it in the distribution tree.
        // If we don't find the record we simply fill in the PK value and pretend the record
        // already exists. We then carry on to find the linked records are before. Note that this
        // only works if the links specified in the table distribution setup are set on PK values,
        // other links will not work since we cannot recreate them based on the data in the preaction table.

        if RecRef[Index].FindFirst() then
            FindRecOk := true
        else
            FindRecOk := false;
        if (not FindRecOk) and (ActionType = 2) then begin
            i := 1;
            while Keyfields[i] <> 0 do begin
                FieldReff[Index] := RecRef[Index].Field(Keyfields[i]);
                if not FieldValue(Infilters[i]) then begin
                    ErrorVal := 1;
                    ModuleVal := 0;
                    Log(StrSubstNo(Text012, TableNo, FieldReff[Index].Number));
                    NumErrors := NumErrors + 1;
                    RecRef[Index].CLOSE;
                    CLEAR(FieldReff[Index]);
                    CLEAR(KeyReff[Index]);
                    exit;
                end;
                i := i + 1;
            end;
            FindRecOk := true;
        end;
        if FindRecOk then
            repeat
                if Index <> 1 then begin
                    InKey := '';
                    InFields := '';
                    KeyReff[Index] := RecRef[Index].KeyIndex(1);
                    for i := 1 to KeyReff[Index].FieldCount do begin
                        FieldReff[Index] := KeyReff[Index].FieldIndex(i);
                        InKey := InKey + ';' + Format(FormatFieldReferenceValue(RecRef[Index].Number, FieldReff[Index]));
                    end;
                    InKey := CopyStr(InKey, 2);

                    SystemPreaction."Entry No." := NextEntryNo;
                    SystemPreaction.Table := TableNo;
                    SystemPreaction.Key := InKey;
                    SystemPreaction."Additional Values" := PreAction."Additional Values";
                    SystemPreaction."Action type" := PreAction.Action;
                    SystemPreaction.Date := Today;
                    SystemPreaction.Time := Time;
                    SystemPreaction."Link Down" := false;
                    SystemPreaction.UserID := PreAction."User ID";
                    SystemPreaction."Org. Entry No." := PreAction."Entry No.";
                    SystemPreaction.Insert;
                    NextEntryNo := NextEntryNo + 1;
                end;
                Link.SetCurrentKey("Master Table ID");
                Link.SetRange("Master Table ID", TableNo);
                if Link.FindSet() then
                    repeat
                        InKey := '';
                        InFields := '';
                        LinkCond.SetRange("Table ID", Link."Table ID");
                        LinkCond.SetRange("Master Table ID", Link."Master Table ID");
                        if LinkCond.FindSet() then
                            repeat
                                InFields := InFields + ',' + IntegerToStr(LinkCond."Field No.");
                                InKey := InKey + ';' + LinkCond.Value;
                            until LinkCond.Next = 0;

                        FiltersOk := true;
                        Filters.SetRange("Table ID", Link."Table ID");
                        Filters.SetRange("Master Table ID", Link."Master Table ID");
                        Filters.SetFilter(Type, '<>%1', Filters.Type::Field);
                        if Filters.FindSet() then
                            repeat
                                if not IsFilterOk(Filters) then
                                    FiltersOk := false;
                            until (Filters.Next = 0) or (not FiltersOk);

                        if FiltersOk then begin
                            clear(InKey);
                            clear(InFields);
                            Filters.SetRange("Table ID", Link."Table ID");
                            Filters.SetRange("Master Table ID", Link."Master Table ID");
                            Filters.SetRange(Type, Filters.Type::Field);
                            if Filters.FindSet() then
                                repeat
                                    InFields := InFields + ',' + IntegerToStr(Filters."Field No.");
                                    FieldReff[Index] := RecRef[Index].Field(Filters."Main Field No.");
                                    InKey := InKey + ';' + FormatFieldReferenceValue(RecRef[Index].Number, FieldReff[Index]);
                                until Filters.Next = 0;
                            InFields := CopyStr(InFields, 2);
                            InKey := CopyStr(InKey, 2);

                            if (InFields = '') and (InKey = '') then begin
                                ErrorVal := 1;
                                ModuleVal := 0;
                                Log(StrSubstNo(Text008, TableNo) + ' FindDistrDown');
                                NumErrors := NumErrors + 1;
                            end else
                                FindDistrDown(Index + 1, Link."Table ID", InFields, InKey, ActionType);
                            glIndex := Index
                        end;
                    until Link.Next = 0;
            until RecRef[Index].Next = 0;
        RecRef[Index].Close;
        Clear(FieldReff[Index]);
        Clear(KeyReff[Index]);
    end;

    procedure IsFilterOk(FilterRec: Record "LSC Table Links"): Boolean
    var
        "Fields": Record "Field";
        Value: Text[250];
        Int: Integer;
    begin
        if FilterRec."Main Field No." = 0 then
            exit(true);
        if not Fields.Get(FilterRec."Master Table ID", FilterRec."Main Field No.") then
            exit(true);

        FieldReff[glIndex] := RecRef[glIndex].Field(FilterRec."Main Field No.");
        Value := Format(FieldReff[glIndex].Value);

        PreSetup.Reset;
        case Fields.Type of
            Fields.Type::Text:
                begin
                    PreSetup.Text := Value;
                    PreSetup.Modify;
                    if FilterRec.Type = FilterRec.Type::Constant then
                        PreSetup.SetFilter(Text, '%1', FilterRec.Value)
                    else
                        PreSetup.SetFilter(Text, FilterRec.Value);
                    if PreSetup.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            Fields.Type::Code:
                begin
                    PreSetup.Code := UpperCase(Value);
                    PreSetup.Modify;
                    if FilterRec.Type = FilterRec.Type::Constant then
                        PreSetup.SetFilter(Code, '%1', FilterRec.Value)
                    else
                        PreSetup.SetFilter(Code, FilterRec.Value);
                    if PreSetup.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            Fields.Type::Integer:
                begin
                    if not Evaluate(PreSetup.Integer, Value) then
                        exit(true);
                    PreSetup.Modify;
                    if FilterRec.Type = FilterRec.Type::Constant then
                        PreSetup.SetFilter(Integer, '%1', StrToDecimal(FilterRec.Value))
                    else
                        PreSetup.SetFilter(Integer, FilterRec.Value);
                    if PreSetup.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            Fields.Type::Decimal:
                begin
                    if not Evaluate(PreSetup.Decimal, Value) then
                        exit(true);
                    PreSetup.Modify;
                    if FilterRec.Type = FilterRec.Type::Constant then
                        PreSetup.SetFilter(Decimal, '%1', StrToDecimal(FilterRec.Value))
                    else
                        PreSetup.SetFilter(Decimal, FilterRec.Value);
                    if PreSetup.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            Fields.Type::Date:
                begin
                    if not Evaluate(PreSetup.Date, Value) then
                        exit(true);
                    PreSetup.Modify;
                    if FilterRec.Type = FilterRec.Type::Constant then
                        PreSetup.SetFilter(Date, '%1', StrToDate(FilterRec.Value))
                    else begin
                        case FilterRec."Replace % with" of
                            FilterRec."Replace % with"::" ":
                                PreSetup.SetFilter(Integer, FilterRec.Value);
                            FilterRec."Replace % with"::"1=TODAY":
                                PreSetup.SetFilter(Date, FilterRec.Value, Today);
                            FilterRec."Replace % with"::"1=TODAY 2=0D":
                                PreSetup.SetFilter(Date, FilterRec.Value, Today, 0D);
                            FilterRec."Replace % with"::"1=0D":
                                PreSetup.SetFilter(Date, FilterRec.Value, 0D);
                        end;
                    end;
                    if PreSetup.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            Fields.Type::Time:
                begin
                    if not Evaluate(PreSetup.Time, Value) then
                        exit(true);
                    PreSetup.Modify;
                    if FilterRec.Type = FilterRec.Type::Constant then
                        PreSetup.SetFilter(Time, '%1', StrToTime(FilterRec.Value))
                    else
                        PreSetup.SetFilter(Time, FilterRec.Value);
                    if PreSetup.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            Fields.Type::Boolean:
                begin
                    if not Evaluate(PreSetup.Boolean, Value) then
                        exit(true);
                    PreSetup.Modify;
                    if FilterRec.Type = FilterRec.Type::Constant then
                        PreSetup.SetFilter(Boolean, FilterRec.Value);
                    if PreSetup.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            Fields.Type::Option:
                begin
                    Int := FieldReff[glIndex].Value;
                    PreSetup.Option := Int;
                    PreSetup.Modify;
                    if FilterRec.Type = FilterRec.Type::Constant then begin
                        Evaluate(Int, FilterRec.Value);
                        PreSetup.SetFilter(Option, '%1', Int);
                    end
                    else
                        PreSetup.SetFilter(Option, FilterRec.Value);
                    if PreSetup.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
        end;
        exit(false);
    end;

    procedure IntegerToStr("Integer": Integer): Text[50]
    begin
        exit(DelChr(Format(Integer), '=', ',.'));
    end;

    procedure StrToDecimal(Value: Text[100]): Decimal
    var
        Dec: Decimal;
    begin
        if not Evaluate(Dec, Value) then
            exit(0)
        else
            exit(Dec);
    end;

    procedure StrToDate(Value: Text[30]): Date
    var
        Date: Date;
    begin
        if not Evaluate(Date, Value) then
            exit(0D)
        else
            exit(Date);
    end;

    procedure StrToTime(Value: Text[100]): Time
    var
        xTime: Time;
    begin
        if not Evaluate(xTime, Value) then
            exit(0T)
        else
            exit(xTime);
    end;

    procedure GetError(): Integer
    begin
        exit(ErrorVal);
    end;

    procedure GetModule(): Integer
    begin
        exit(ModuleVal);
    end;

    procedure GetErrorText(): Text[250]
    begin
        exit(ErrorText);
    end;

    procedure ErrorHandling(Message: Text[250])
    begin
        ErrorText := Message;
    end;

    procedure OpenLog()
    begin
        if PreActionLog.FindLast then;
    end;

    procedure Log(Txt: Text[250])
    var
        Value: Text[250];
        i: Integer;
    begin
        PreActionLog.EntryNo := PreActionLog.EntryNo + 1;
        PreActionLog.Date := Today;
        PreActionLog.Time := Time;
        PreActionLog."Log text" := Txt;
        PreActionLog.Module := ModuleVal;
        PreActionLog."ErrorNo." := ErrorVal;
        if (ErrorVal <> 0) and (glIndex <> 0) then begin
            PreActionLog.Table := RecRef[glIndex].Number;
            KeyReff[glIndex] := RecRef[glIndex].KeyIndex(1);
            for i := 1 to KeyReff[glIndex].FieldCount do begin
                FieldReff[glIndex] := KeyReff[glIndex].FieldIndex(i);
                Value := Value + ';' + FormatFieldReferenceValue(RecRef[glIndex].NUMBER, FieldReff[glIndex]);
            end;
            PreActionLog.Value := CopyStr(Value, 2);
        end else
            PreActionLog.Table := 0;
        PreActionLog.Insert;
        ErrorVal := 0;
    end;

    procedure NoFilterExists(var LocGrType: Code[10]; var LocGr: Code[10]): Boolean
    var
        RetailLocGr: Record "LSC Distribution Subgroup";
    begin
        RetailLocGr.Reset;
        RetailLocGr.SetRange("No Filter", true);
        if not RetailLocGr.FindFirst() then
            exit(false);
        LocGrType := RetailLocGr."Group Code";
        LocGr := RetailLocGr."Subgroup Code";
        exit(true);
    end;

    procedure FieldFilter(TxtFilter: Text[250]): Boolean
    var
        "Field": Record "Field";
        intFilter: Integer;
        decFilter: Decimal;
        dateFilter: Date;
        timeFilter: Time;
        boolFilter: Boolean;
        StrPosOfOptionString: Integer;
        OptionNumber: Integer;
        Ix: Integer;
    begin
        Field.Get(RecRef[glIndex].Number, FieldReff[glIndex].Number);

        case Field.Type of
            Field.Type::Text:
                FieldReff[glIndex].SetRange(TxtFilter);
            Field.Type::Code:
                FieldReff[glIndex].SetRange(TxtFilter);
            Field.Type::Integer:
                begin
                    if not Evaluate(intFilter, TxtFilter) then
                        exit(false);
                    FieldReff[glIndex].SetRange(intFilter);
                end;
            Field.Type::Decimal:
                begin
                    if not Evaluate(decFilter, TxtFilter) then
                        exit(false);
                    FieldReff[glIndex].SetRange(decFilter);
                end;
            Field.Type::Date:
                begin
                    dateFilter := BOUtil.STDStringToDate(TxtFilter);
                    FieldReff[glIndex].SetRange(dateFilter);
                end;
            Field.Type::Time:
                begin
                    timeFilter := BOUtil.STDStringToTime(TxtFilter);
                    FieldReff[glIndex].SetRange(timeFilter);
                end;
            Field.Type::Option:
                begin
                    if not Evaluate(intFilter, TxtFilter) then begin
                        StrPosOfOptionString := StrPos(Field.OptionString, TxtFilter);
                        if StrPosOfOptionString = 0 then
                            exit(false);
                        OptionNumber := 0;
                        for Ix := 1 to StrPosOfOptionString do
                            if CopyStr(Field.OptionString, Ix, 1) = ',' then
                                OptionNumber := OptionNumber + 1;
                        FieldReff[glIndex].SetRange(OptionNumber);
                    end
                    else
                        FieldReff[glIndex].SetRange(intFilter);
                end;
            Field.Type::Boolean:
                begin
                    if not Evaluate(boolFilter, TxtFilter) then
                        exit(false);
                    FieldReff[glIndex].SetRange(boolFilter);
                end;
        end;

        exit(true);
    end;

    procedure SelectGoodKey(Keyfields: array[30] of Integer; FieldCount: Integer): Integer
    var
        locKeyRef: KeyRef;
        locFieldRef: FieldRef;
        nMaxVote: Integer;
        nCurrVote: Integer;
        GoodKey: Integer;
        keyIndex: Integer;
        i: Integer;
        j: Integer;
        iKeyCount: Integer;
        Found: Boolean;
    begin
        nMaxVote := 0;
        GoodKey := 1;

        iKeyCount := RecRef[glIndex].KeyCount;
        if iKeyCount = 1 then
            exit(1);

        for i := 1 to iKeyCount do begin
            locKeyRef := RecRef[glIndex].KeyIndex(i);
            nCurrVote := 0;
            for j := 1 to FieldCount do begin
                Found := false;
                keyIndex := 1;
                while ((keyIndex <= locKeyRef.FieldCount) and (not Found)) do begin
                    locFieldRef := locKeyRef.FieldIndex(keyIndex);
                    if locFieldRef.Number = Keyfields[j] then begin
                        nCurrVote += 1;
                        Found := true;
                    end else
                        keyIndex += 1;
                    if nCurrVote = FieldCount then begin
                        exit(i);
                    end;
                end;
            end;
            if nCurrVote > nMaxVote then begin
                nMaxVote := nCurrVote;
                GoodKey := i;
            end;
        end;

        exit(GoodKey);
    end;

    procedure FieldValue(TxtFilter: Text[250]): Boolean
    var
        "Field": Record "Field";
        intFilter: Integer;
        decFilter: Decimal;
        dateFilter: Date;
        timeFilter: Time;
        boolFilter: Boolean;
    begin
        Field.Get(RecRef[glIndex].Number, FieldReff[glIndex].Number);

        case Field.Type of
            Field.Type::Text:
                FieldReff[glIndex].Value := TxtFilter;
            Field.Type::Code:
                FieldReff[glIndex].Value := TxtFilter;
            Field.Type::Integer:
                begin
                    if not Evaluate(intFilter, TxtFilter) then
                        exit(false);
                    FieldReff[glIndex].Value := intFilter;
                end;
            Field.Type::Decimal:
                begin
                    if not Evaluate(decFilter, TxtFilter) then
                        exit(false);
                    FieldReff[glIndex].Value := decFilter;
                end;
            Field.Type::Date:
                begin
                    dateFilter := BOUtil.STDStringToDate(TxtFilter);
                    FieldReff[glIndex].Value := dateFilter;
                end;
            Field.Type::Time:
                begin
                    timeFilter := BOUtil.STDStringToTime(TxtFilter);
                    FieldReff[glIndex].Value := timeFilter;
                end;
            Field.Type::Option:
                begin
                    if not Evaluate(intFilter, TxtFilter) then
                        exit(false);
                    FieldReff[glIndex].Value := intFilter;
                end;
            Field.Type::Boolean:
                begin
                    if not Evaluate(boolFilter, TxtFilter) then
                        exit(false);
                    FieldReff[glIndex].Value := boolFilter;
                end;
        end;

        exit(true);
    end;

    procedure PreloadTable(TableNo: Integer)
    var
        txtPrimaryKey: Text[250];
        i: Integer;
        tmpDec: Decimal;
        tmpTime: Time;
        tmpDate: Date;
        tmpDateTime: DateTime;
        tmpBool: Boolean;
        addValue: Text[250];
        RecCounter: Integer;
        tmpText: Text;
        Ix: Integer;
        "Field": Record "Field";
        StrPosOfOptionString: Integer;
        OptionNumber: Integer;
    begin
        // This function is called in order to create preload actions for a table.
        // The function loops through the table, finds the primary key for the records and then calls
        // FindDist() in order to find the distribution list entries for current primary key.

        // If table number is >= 2000100000 we exit since this is an internal system table
        if TableNo >= 2000100000 then
            exit;

        RecCounter := 0;
        OpenLog;

        // Only create preload actions, the Preload flag controls if we create an Action or
        // a Preload Action. Used in function FindDist()

        Preload := true;
        if PreloadActionTmp.Insert then;

        PreloadRecRef.Open(TableNo);
        if PreloadRecRef.FindSet() then
            repeat

                RecCounter += 1;
                if (RecCounter mod 10) = 0 then
                    PreloadWindow.Update(4, RecCounter);

                // Select the primary key.
                PreloadKeyRef[1] := PreloadRecRef.KeyIndex(1);

                // next we loop through the primary key fields of the record in order to
                // create the text version of the key

                txtPrimaryKey := '';
                for i := 1 to PreloadKeyRef[1].FieldCount do begin
                    PreloadFieldRef := PreloadKeyRef[1].FieldIndex(i);
                    case Format(PreloadFieldRef.Type) of
                        'Decimal':
                            begin
                                Evaluate(tmpDec, Format(PreloadFieldRef.Value));
                                addValue := BOUtil.DecToStr(tmpDec);
                            end;
                        'Time':
                            begin
                                Evaluate(tmpTime, Format(PreloadFieldRef.Value));
                                addValue := BOUtil.STDTimeToString(tmpTime);
                            end;
                        'Date':
                            begin
                                Evaluate(tmpDate, Format(PreloadFieldRef.Value));
                                addValue := BOUtil.STDDateToString(tmpDate);
                            end;
                        'Boolean':
                            begin
                                Evaluate(tmpBool, Format(PreloadFieldRef.Value));
                                addValue := BOUtil.BoolToStr(tmpBool);
                            end;
                        'DateTime':
                            begin
                                Evaluate(tmpDateTime, Format(PreloadFieldRef.Value));
                                addValue := BOUtil.STDDateTimeToString(tmpDateTime);
                            end;
                        'Option':
                            begin
                                addValue := Format(PreloadFieldRef.Value);
                                tmpText := Format(PreloadFieldRef.Value);
                                if Field.Get(TableNo, PreloadFieldRef.Number) then begin
                                    StrPosOfOptionString := StrPos(Field.OptionString, tmpText);
                                    if StrPosOfOptionString > 0 then begin
                                        OptionNumber := 0;
                                        for Ix := 1 to StrPosOfOptionString do
                                            if CopyStr(Field.OptionString, Ix, 1) = ',' then
                                                OptionNumber := OptionNumber + 1;
                                    end;
                                    addValue := Format(OptionNumber);
                                end;
                            end;
                        else
                            addValue := Format(PreloadFieldRef.Value);
                    end;
                    txtPrimaryKey += ';' + addValue;
                end;
                txtPrimaryKey := CopyStr(txtPrimaryKey, 2);

                PreloadActionTmp."Table No." := TableNo;
                PreloadActionTmp.Key := txtPrimaryKey;
                PreloadActionTmp."User ID" := UserId;
                PreloadActionTmp.Modify;

                // Now that we have the primary key we call the FindDist() in order to find the
                // distribution list lines for the record.

                FindDistr(1, TableNo, '', txtPrimaryKey);

            until PreloadRecRef.Next = 0;
        PreloadRecRef.Close;
    end;

    procedure InsertPreloadAction(TableNo: Integer; InKey: Text[250])
    var
        TableDistribution: Record "LSC Table Distribution Setup";
        DistributionList: Record "LSC Distribution List";
        TempKey: Record "LSC Group Filter" temporary;
        Group: Code[10];
        SubGroup: Code[10];
        i: Integer;
        SchedulerSetup: Record "LSC Scheduler Setup";
        SeparateChr: Text[1];
    begin
        // This function is called from within FindDist(). If we get here it means that the
        // Preload flag is set and we have found a distribution list entry for the current
        // primary key. We now proceed to create a preload action.

        SchedulerSetup.Get;
        SeparateChr := SchedulerSetup."Loc. Group Filter Delimiter";
        if SeparateChr = '' then
            SeparateChr[1] := 177;

        TableDistribution.SetRange("Table ID", TableNo);
        if not TableDistribution.FindFirst() then begin
            if NoFilterExists(Group, SubGroup) then begin
                // This table has no distribution lines, and is therefore distributed to all locations
                PreloadAction[1].Init;
                PreloadAction[1]."Entry No." := NextPreloadAction;
                NextAction += 1;

                PreloadAction[1]."Location Group Filter" := Group + SeparateChr + SubGroup;

                PreloadAction[1].Action := PreloadAction[1].Action::"Update-Add";
                PreloadAction[1]."Table No." := PreloadActionTmp."Table No.";
                PreloadAction[1].Key := PreloadActionTmp.Key;
                PreloadAction[1].Date := Today;
                PreloadAction[1].Time := Time;
                PreloadAction[1]."User ID" := PreloadActionTmp."User ID";
                PreloadAction[1].BatchID := PreloadActionTmp.BatchID;
                PreloadAction[1].Insert;
                exit;
            end;
        end else begin
            case TableDistribution."Distribution Type" of
                TableDistribution."Distribution Type"::All:
                    begin
                        if NoFilterExists(Group, SubGroup) then begin
                            PreloadAction[1].Init;
                            PreloadAction[1]."Entry No." := NextPreloadAction;
                            NextPreloadAction += 1;

                            PreloadAction[1]."Location Group Filter" := Group + SeparateChr + SubGroup;

                            PreloadAction[1].Action := PreloadAction[1].Action::"Update-Add";
                            PreloadAction[1]."Table No." := PreloadActionTmp."Table No.";
                            PreloadAction[1].Key := PreloadActionTmp.Key;
                            PreloadAction[1].Date := Today;
                            PreloadAction[1].Time := Time;
                            PreloadAction[1]."User ID" := PreloadActionTmp."User ID";
                            PreloadAction[1].BatchID := PreloadActionTmp.BatchID;
                            PreloadAction[1].Insert;
                        end;
                        exit;
                    end;
                TableDistribution."Distribution Type"::"No Distribution",
                TableDistribution."Distribution Type"::"By Master Only":
                    begin
                        // this should be logged since a top-level table should never
                        // have these types of distribution.
                        exit;
                    end;
            end;
        end;

        DistributionList.SetRange("Table ID", TableNo);

        DistributionList.SetRange(Value, ConvertStr(InKey, ';', SeparateChr));

        if DistributionList.FindSet() then
            repeat
                // Now we check if the dist. list entry is valid by creating a dummy record and
                // applying our GroupFilter to it.
                if LocGroupFilter.FindSet() then
                    repeat
                        Clear(TempKey);
                        TempKey.Reset;

                        TempKey.Filter := DistributionList."Group Code" + SeparateChr + DistributionList."Subgroup Code";

                        TempKey.Insert;
                        TempKey.SetFilter(Filter, LocGroupFilter."Table Name");    // Table name contains the group filter!
                        if TempKey.FindFirst() then begin
                            i := LocGroupFilter."Table No.";

                            // Since we found a record, the key is in the a member of our GroupFilter
                            // and therefore valid in our store.

                            Clear(PreloadAction[i]);
                            PreloadAction[i]."Entry No." := NextPreloadAction;
                            NextPreloadAction += 1;

                            PreloadAction[i]."Location Group Filter" := DistributionList."Group Code" + SeparateChr +
                              DistributionList."Subgroup Code";


                            PreloadAction[i].Action := PreloadAction[i].Action::"Update-Add";
                            PreloadAction[i]."Table No." := PreloadActionTmp."Table No.";
                            PreloadAction[i].Key := PreloadActionTmp.Key;
                            PreloadAction[i].Date := Today;
                            PreloadAction[i].Time := Time;
                            PreloadAction[i]."User ID" := UserId;
                            PreloadAction[i].BatchID := LocGroupFilter."Exchange Location";
                            PreloadAction[i].Insert;
                        end;
                        TempKey.Delete;
                    until LocGroupFilter.Next = 0;
            until DistributionList.Next = 0;
    end;

    procedure SetLocation(JobID: Code[20])
    var
        DistGroupMember: Record "LSC Distribution Group Member";
        SchedulerSetup: Record "LSC Scheduler Setup";
        SeparateChr: Text[1];
    begin
        // This function is called before the preloading is started in order to figure
        // out which distribution combinations are valid for the current location. We
        // build a group filter which we then apply to the distribution list lines in
        // order to find out which dist. list lines are valid

        SchedulerSetup.Get;
        SeparateChr := SchedulerSetup."Loc. Group Filter Delimiter";
        if SeparateChr = '' then
            SeparateChr[1] := 177;

        DistIncludeList.SetRange("Location List Type", DistIncludeList."Location List Type"::"To");
        DistIncludeList.SetRange("Scheduler Job ID", JobID);
        if DistIncludeList.FindSet() then
            repeat
                NumLocations += 1;
                Clear(GroupFilter);
                DistGroupMember.SetCurrentKey("Distrib. Loc. Code");
                DistGroupMember.SetRange("Distrib. Loc. Code", DistIncludeList."Location Code");
                if DistGroupMember.FindSet() then
                    repeat
                        GroupFilter := GroupFilter + '|' + DistGroupMember."Group Code" + SeparateChr + DistGroupMember."Subgroup Code";
                    until DistGroupMember.Next = 0;
                GroupFilter := CopyStr(GroupFilter, 2, StrLen(GroupFilter));
                LocGroupFilter."Exchange Location" := DistIncludeList."Location Code";
                LocGroupFilter."Table No." := NumLocations + 1;        // We use no. 1 for all locations
                LocGroupFilter."Table Name" := GroupFilter;
                LocGroupFilter.Insert;
            until DistIncludeList.Next = 0;
    end;

    procedure CheckTables(SchJob: Record "LSC Scheduler Job Header")
    var
        SchJobLine: Record "LSC Scheduler Job Line";
        SchSubJob: Record "LSC Scheduler Subjob";
        TableDist: Record "LSC Table Distribution Setup";
        DistList: Record "LSC Distrib. Incl./Excl. List";
        SingleLoc: Label 'Job Type should be Single Location or Include List for preloading jobs';
        NoLocDefined: Label 'No To-Location is defined in the Scheduler Job';
        TypePreloadAction: Label 'Subjob %1 should use the %2 table (99001468)';
        NoTableDist: Label 'There is no %1 entry for table %2. You need to create and entry if you want to replicate By Actions. Otherwise, change the replication type to Normal.';
        PreloadActionRec: Record "LSC Preload Action";
        TableCounter: Integer;
        DoneMsg: Label 'Done - a total of %1 tables were preloaded';
        i: Integer;
        PreloadActionCounter: Integer;
        PreloadActionsExist: Label 'There are %1 records in the %2 table. You should delete them before you continue.';
        ExitPrompt: Label 'Do you want to stop the preloading?';
        ErrorPrompt: Label 'Exiting';
    begin
        // This function loops through the Scheduler Job Lines and checks if the subjobs are set up
        // to use the Preaload Actions table as well as checking which tables we need to create preaload
        // actions for. If a table has a master table that is distributed as all we don't need to create
        // preload actions and the job should be changed to normal instead.
        //

        PreloadActionCounter := PreloadActionRec.Count;
        if PreloadActionCounter <> 0 then begin
            if Confirm(
              StrSubstNo(PreloadActionsExist + '\\' +
                         ExitPrompt, PreloadActionCounter, PreloadActionRec.TableCaption, true))
            then
                Error(ErrorPrompt)
        end;

        if not ((SchJob."Distribution Restrictions" = SchJob."Distribution Restrictions"::"Single Location") or
                (SchJob."Distribution Restrictions" = SchJob."Distribution Restrictions"::"Include List"))
        then
            Error(SingleLoc);

        DistList.SetRange("Scheduler Job ID", SchJob."Job ID");
        if DistList.FindFirst() then
            SetLocation(SchJob."Job ID")
        else
            Error(NoLocDefined);

        PreloadWindow.Open(
          'Preloading job     #1#######################\' +
          'Checking subjob    #2#######################\' +
          'Preloading table   #3#######################\' +
          'Processing Record  #4#######################');

        PreloadWindow.Update(1, SchJob."Job ID");

        SchJobLine.SetRange("Scheduler Job ID", SchJob."Job ID");
        SchJobLine.SetRange(Enabled, true);
        if SchJobLine.FindSet() then
            repeat
                SchSubJob.Get(SchJobLine."Subjob ID");

                PreloadWindow.Update(2, SchSubJob.ID);

                if SchSubJob."Replication Method" = SchSubJob."Replication Method"::"By Actions" then begin
                    if SchSubJob."Action Table ID" = Database::"LSC Preload Action" then begin
                        TableDist.SetRange("Table ID", SchSubJob."From-Table ID");
                        if not TableDist.FindFirst() then
                            Error(StrSubstNo(NoTableDist, TableDist.TableCaption, SchSubJob."From-Table ID"));
                    end else
                        Error(StrSubstNo(TypePreloadAction, SchSubJob.ID, PreloadAction[1].TableCaption));
                end;
            until SchJobLine.Next = 0;

        if SchJobLine.FindSet() then
            repeat
                SchSubJob.Get(SchJobLine."Subjob ID");

                PreloadWindow.Update(3, SchSubJob.ID);

                if SchSubJob."Replication Method" = SchSubJob."Replication Method"::"By Actions" then
                    if SchSubJob."Action Table ID" = Database::"LSC Preload Action" then begin
                        TableCounter += 1;
                        PreloadTable(SchSubJob."From-Table ID");
                    end;
            until SchJobLine.Next = 0;

        PreloadAction2.LockTable;
        if PreloadAction2.FindLast then
            NextPreloadAction := PreloadAction2."Entry No." + 1
        else
            NextPreloadAction := 1;

        i := 1;
        if PreloadAction[i].FindSet() then
            repeat
                PreloadAction2.TransferFields(PreloadAction[i]);
                PreloadAction2."Entry No." := NextPreloadAction;
                PreloadAction2.Insert;
                NextPreloadAction += 1;
            until PreloadAction[i].Next = 0;

        for i := 1 to (NumLocations + 1) do
            PreloadAction[i].DeleteAll;

        PreloadWindow.Close;

        Message(StrSubstNo(DoneMsg, TableCounter));
    end;

    local procedure FormatFieldReferenceValue(TableNumber: Integer; VAR FieldReference: FieldRef) FieldReferenceValueFormatted: Text;
    VAR
        FieldRec: Record Field;
        tmpBool: Boolean;
        tmpDateTime: DateTime;
        tmpDate: Date;
        tmpTime: Time;
        tmpText: Text;
        tmpDec: Decimal;
        Ix: Integer;
        OptionNumber: Integer;
        StrPosOfOptionString: Integer;
        tmpInt: Integer;
    begin
        case Format(FieldReference.Type) of
            'Decimal':
                begin
                    Evaluate(tmpDec, Format(FieldReference.Value));
                    FieldReferenceValueFormatted := BOUtil.DecToStr(tmpDec);
                end;
            'Time':
                begin
                    Evaluate(tmpTime, Format(FieldReference.Value));
                    FieldReferenceValueFormatted := BOUtil.STDTimeToString(tmpTime);
                end;
            'Date':
                begin
                    Evaluate(tmpDate, Format(FieldReference.Value));
                    FieldReferenceValueFormatted := BOUtil.STDDateToString(tmpDate);
                end;
            'Boolean':
                begin
                    Evaluate(tmpBool, Format(FieldReference.Value));
                    FieldReferenceValueFormatted := BOUtil.BoolToStr(tmpBool);
                end;
            'DateTime':
                begin
                    Evaluate(tmpDateTime, Format(FieldReference.Value));
                    FieldReferenceValueFormatted := BOUtil.STDDateTimeToString(tmpDateTime);
                end;
            'Option':
                begin
                    FieldReferenceValueFormatted := Format(FieldReference.Value);
                    tmpText := Format(FieldReference.Value);
                    if FieldRec.Get(TableNumber, FieldReference.Number) then begin
                        StrPosOfOptionString := StrPos(FieldRec.OptionString, tmpText);
                        if StrPosOfOptionString > 0 then begin
                            OptionNumber := 0;
                            for Ix := 1 to StrPosOfOptionString do
                                if COPYSTR(FieldRec.OptionString, Ix, 1) = ',' then
                                    OptionNumber := OptionNumber + 1;
                        end;
                        FieldReferenceValueFormatted := Format(OptionNumber);
                    end;
                end;
            else
                FieldReferenceValueFormatted := Format(FieldReference.Value);
        end;
    end;
}

