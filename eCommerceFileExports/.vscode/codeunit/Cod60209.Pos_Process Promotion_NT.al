codeunit 60209 "Pos_Process Promotion_NT"
{
    TableNo = "LSC Scheduler Job Header";

    trigger OnRun()
    begin
        IF GuiAllowed THEN
            Window.Open('Current Action #1###############\Promotion #2###############');

        DisableExpiredDiscount();
        DeletePromoBuffer();
        if ImportPromotionFile(Rec.Text) then begin
            ProcessPromotion();
            SaveFile(Rec.Text);
        end;
        if GuiAllowed then
            Window.Close();
    end;

    procedure ImportPromotionFile(FileName: Text[250]): Boolean
    var
        Item: Record Item;
        _File: DotNet File;
        EndDate: Date;
        StartDate: Date;
        EntryNo: Integer;
        i: Integer;
        AddFileName: Text;
    begin
        PromoBuffer.LockTable();
        if PromoBuffer.FindLast() then
            EntryNo := PromoBuffer."Entry No." + 1
        else
            EntryNo := 1;

        if not iFile.Open(FileName) then
            exit(false);
        iFile.CreateInStream(iStream);
        i := 0;
        while not iStream.EOS do begin
            iStream.ReadText(iLine);
            ImportPromotionLines(EntryNo);
            EntryNo += 1;
        end;
        iFile.Close();
        exit(EntryNo > 1);
    end;

    local procedure ImportPromotionLines(EntryNo: Integer)
    var
        PromoBuffer: Record "Pos_Promotion Buffer_NT";
    begin
        PromoBuffer.Init();
        PromoBuffer."Entry No." := EntryNo;
        PromoBuffer."Curent Action" := COPYSTR(iLine, 1, 1);
        PromoBuffer."Store Code" := GetStoreNo(COPYSTR(iLine, 2, 2));

        PromoBuffer."Promotion Event Number" := COPYSTR(iLine, 4, 8);
        PromoBuffer."Promotion Event Description" := COPYSTR(iLine, 12, 35);
        PromoBuffer."Promotion Event Category" := COPYSTR(iLine, 47, 2);
        PromoBuffer."Event Category Description" := COPYSTR(iLine, 49, 30);

        PromoBuffer."Promotion From Date" := GetDate(COPYSTR(iLine, 79, 8));
        PromoBuffer."Promotion To Date" := GetDate(COPYSTR(iLine, 87, 8));
        PromoBuffer."Promotion Type" := COPYSTR(iLine, 105, 1);

        PromoBuffer."Promotion Identifier" := COPYSTR(iLine, 95, 11) + '_' + COPYSTR(iLine, 193, 2);

        PromoBuffer."Promotion Receipt Line" := COPYSTR(iLine, 106, 40);
        PromoBuffer."Item Required" := COPYSTR(iLine, 146, 15);

        PromoBuffer."Item Free" := COPYSTR(iLine, 161, 15);
        PromoBuffer."Item Required Quantity_Txt" := COPYSTR(iLine, 176, 2);

        IF NOT EVALUATE(PromoBuffer."Item Required Quantity_Dec", PromoBuffer."Item Required Quantity_Txt") THEN
            PromoBuffer."Item Required Quantity_Dec" := 0;

        IF (PromoBuffer."Item Free" = PromoBuffer."Item Required") AND (PromoBuffer."Item Required Quantity_Dec" > 0) THEN
            PromoBuffer."Item Required Quantity_Dec" += 1;

        PromoBuffer."Item Free Quantity" := COPYSTR(iLine, 178, 2);

        PromoBuffer."Discount Percentage" := COPYSTR(iLine, 180, 5);

        IF EVALUATE(PromoBuffer."Discount Percentage_Dec", PromoBuffer."Discount Percentage") THEN
            PromoBuffer."Discount Percentage_Dec" /= 100;

        PromoBuffer.Points := COPYSTR(iLine, 185, 2);
        PromoBuffer."Promotion Price" := COPYSTR(iLine, 187, 6);
        PromoBuffer."Promotion Group" := COPYSTR(iLine, 193, 2);
        PromoBuffer."Promotion Limit" := COPYSTR(iLine, 195, 2);

        PromoBuffer.Pillar := '';

        if StrLen(iLine) > 197 then
            PromoBuffer.Pillar := CopyStr(iLine, 197, 2);
        if GuiAllowed then begin
            Window.Update(1, 'Importing...');
            Window.Update(2, PromoBuffer."Promotion Identifier");
        end;
        PromoBuffer.Insert();
    end;

    local procedure GetStoreNo(StoreNo: Code[10]): Code[10]
    begin
        CASE StoreNo OF
            'EC':
                EXIT('0001');
            'DS':
                EXIT('0002');
            'LA':
                EXIT('0003');
            'LI':
                EXIT('0004');
            'PF':
                EXIT('0005');
            'DF':
                EXIT('0006');
            'LC':
                EXIT('0007');
            'SK':
                EXIT('0008');
            'KO':
                EXIT('0009');
            'KA':
                EXIT('0010');
            'LM':
                EXIT('0011');
            'LT':
                EXIT('0012');
            'KI':
                EXIT('0013');
            'LK':
                EXIT('0014');
            'PO':
                EXIT('0015');
            'AF':
                EXIT('0016');
            'LO':
                EXIT('9999');
            'MM':
                EXIT('0017');
            'AM':
                EXIT('0018');
            'TR':
                EXIT('0019');
        END;
    end;

    local procedure GetDate(_Date: Code[8]): Date
    var
        i: array[3] of Integer;
    begin
        IF (_Date = '') OR (_Date = '99999999') THEN
            EXIT(0D);
        EVALUATE(I[3], COPYSTR(_Date, 1, 4));
        EVALUATE(I[2], COPYSTR(_Date, 5, 2));
        EVALUATE(I[1], COPYSTR(_Date, 7, 2));
        EXIT(DMY2DATE(I[1], I[2], I[3]));
    end;

    local procedure ProcessPromotion()
    var
    begin
        //DeleteDisc;
        //exit;        
        InitGlobals();
        LoadPeriodicDiscount();
        LoadValidationPeriod();
        GroupPromotionData();
        CreateGroupedPromoBufferSearchKey();
        ProcessGroupedData();
        DeleteNonExistentDiscounts();
        SetDiscStatusEnabled();
    end;

    local procedure DeleteDisc()
    var
        DistGrp: Record "LSC Distribution List";
        PerDisc2: Record "LSC Periodic Discount";
        PerDisc: Record "LSC Periodic Discount";
    begin
        //PerDisc.SetRange("Currency Code", 'BC220');
        PerDisc.SetRange(Type, PerDisc.Type::"Mix&Match");
        PerDisc.FindSet();
        repeat
            PerDisc.Status := PerDisc.Status::Disabled;
            PerDisc.Modify();
            PerDisc2.Get(PerDisc."No.");
            PerDisc2.Delete(true);
            DistGrp.SetRange("Table ID", Database::"LSC Periodic Discount");
            DistGrp.SetRange(Value, PerDisc."No.");
            DistGrp.DeleteAll();
            Commit();
        until PerDisc.Next() = 0;
    end;

    local procedure GroupPromotionData()
    var
        PromoBuffer: Record "Pos_Promotion Buffer_NT";
        VP: code[10];
        EntryNo2: Integer;
        EntryNo: Integer;
    begin
        EntryNo := 1;
        EntryNo2 := 1;
        //PromoBuffer.SetRange("Promotion Identifier", 'P2484250921_11');//TO BE REMOVED
        //PromoBuffer.SetFilter("Promotion Type", '2|9');//TO BE REMOVED
        if PromoBuffer.FindSet() then
            repeat
                TempGroupedPromoBuffer_DataSet1.Reset();
                TempGroupedPromoBuffer_DataSet1.SetCurrentKey("Promotion Identifier", "Item Required", "Store Code", "Promotion From Date", "Promotion To Date");
                TempGroupedPromoBuffer_DataSet1.SetFilter("Promotion Identifier", PromoBuffer."Promotion Identifier");
                TempGroupedPromoBuffer_DataSet1.SetFilter("Store Code", PromoBuffer."Store Code");
                TempGroupedPromoBuffer_DataSet1.SetFilter("Promotion From Date", '%1', PromoBuffer."Promotion From Date");
                TempGroupedPromoBuffer_DataSet1.SetFilter("Promotion To Date", '%1', PromoBuffer."Promotion To Date");

                if not TempGroupedPromoBuffer_DataSet1.FindFirst() then begin
                    if GuiAllowed then begin
                        Window.Update(1, 'Grouping Data...');
                        Window.Update(2, TempGroupedPromoBuffer_DataSet1."Promotion Identifier");
                    end;
                    TempGroupedPromoBuffer_DataSet1.Reset();
                    TempGroupedPromoBuffer_DataSet1.Init();
                    TempGroupedPromoBuffer_DataSet1 := PromoBuffer;
                    TempGroupedPromoBuffer_DataSet1."Entry No." := EntryNo;
                    EntryNo += 1;
                    TempGroupedPromoBuffer2_DataSet1.Init();
                    TempGroupedPromoBuffer2_DataSet1 := TempGroupedPromoBuffer_DataSet1;
                    TempGroupedPromoBuffer2_DataSet1.Insert();
                    TempGroupedPromoBuffer_DataSet1.Insert();
                    VP := GetValidationPeriod(TempGroupedPromoBuffer_DataSet1."Promotion From Date", TempGroupedPromoBuffer_DataSet1."Promotion To Date");
                    if not TempPromoBufferDistList_DataSet2.Get(Database::"Pos_Promotion Buffer_NT", TempGroupedPromoBuffer_DataSet1."Promotion Identifier", VP, TempGroupedPromoBuffer_DataSet1."Store Code") then begin
                        TempPromoBufferDistList_DataSet2.Init();
                        TempPromoBufferDistList_DataSet2."Table ID" := Database::"Pos_Promotion Buffer_NT";
                        TempPromoBufferDistList_DataSet2.Value := TempGroupedPromoBuffer_DataSet1."Promotion Identifier";
                        TempPromoBufferDistList_DataSet2."Store Group" := TempGroupedPromoBuffer_DataSet1."Store Code";
                        TempPromoBufferDistList_DataSet2."Group Code" := VP;
                        TempPromoBufferDistList_DataSet2."Subgroup Code" := TempGroupedPromoBuffer_DataSet1."Store Code";
                        TempPromoBufferDistList_DataSet2.Insert();
                    end;
                end;
                //Generate Data Set4 grouped by promo ID	VID	ItemNo	Promotion Type 
                TempPromoBufferItems_DataSet4.Reset();
                TempPromoBufferItems_DataSet4.SetCurrentKey("Promotion Identifier", "Item Required", "Store Code", "Promotion From Date", "Promotion To Date");
                TempPromoBufferItems_DataSet4.SetFilter("Promotion Identifier", PromoBuffer."Promotion Identifier");
                TempPromoBufferItems_DataSet4.SetFilter("Promotion From Date", '%1', PromoBuffer."Promotion From Date");
                TempPromoBufferItems_DataSet4.SetFilter("Promotion To Date", '%1', PromoBuffer."Promotion To Date");
                TempPromoBufferItems_DataSet4.SetFilter("Item Required", PromoBuffer."Item Required");
                TempPromoBufferItems_DataSet4.SetFilter("Promotion Type", PromoBuffer."Promotion Type");
                if not TempPromoBufferItems_DataSet4.findfirst then begin
                    if GuiAllowed then begin
                        Window.Update(1, 'Grouping Item Data...');
                        Window.Update(2, TempGroupedPromoBuffer_DataSet1."Promotion Identifier");
                    end;
                    TempPromoBufferItems_DataSet4.Reset();
                    TempPromoBufferItems_DataSet4.Init();
                    TempPromoBufferItems_DataSet4 := PromoBuffer;
                    TempPromoBufferItems_DataSet4."Entry No." := EntryNo2;
                    EntryNo2 += 1;
                    TempPromoBufferItems_DataSet4.Insert();
                end;

            until PromoBuffer.Next() = 0;
    end;

    local procedure LoadPeriodicDiscount()
    var
        PeriodicDiscLineQ: Record "LSC Periodic Discount Line";
        PeriodicDiscQ: Record "LSC Periodic Discount";
    begin
        PeriodicDiscQ.SetRange(Status, PeriodicDiscQ.Status::Enabled);
        PeriodicDiscQ.SetRange("Created From Promotion File", true);
        //PeriodicDiscQ.SetRange("No.", 'PD164467');//TO BE REMOVED
        //PeriodicDiscQ.SetRange(Type, PeriodicDiscQ.Type::"Disc. Offer");//TO BE REMOVED
        // PeriodicDiscQ.SetFilter(Starting_Date, '%1|<=%2', 0D, Today);
        // PeriodicDiscQ.SetFilter(Ending_Date, '%1|>=%2', 0D, Today);

        //PeriodicDiscQ.Open;
        //while PeriodicDiscQ.Read() do begin
        if PeriodicDiscQ.FindSet() then
            repeat
                TmpPeriodicDiscount.Init;
                // TmpPeriodicDiscount."No." := PeriodicDiscQ.No;
                // TmpPeriodicDiscount.Type := PeriodicDiscQ.Type;
                // TmpPeriodicDiscount."Validation Period ID" := PeriodicDiscQ.Validation_Period_ID;
                // TmpPeriodicDiscount."Created From Promotion File" := PeriodicDiscQ.Created_From_Promotion_File;
                TmpPeriodicDiscount := PeriodicDiscQ;
                LoadDistributionList(Database::"LSC Periodic Discount", TmpPeriodicDiscount."No.");
                if TmpPeriodicDiscount.Type <> TmpPeriodicDiscount.Type::"Mix&Match" then //For Mix&Match Key is Updated in Data Base
                    TmpPeriodicDiscount."Promotion Search Key" := GeneratePerDiscSearchKey(TmpPeriodicDiscount."No.", Database::"LSC Periodic Discount", TmpPeriodicDiscount."Validation Period ID");
                TmpPeriodicDiscount.Insert;
                if TmpPeriodicDiscount.Type = TmpPeriodicDiscount.Type::"Mix&Match" then begin
                    TempMixMatchCreated.Init();
                    TempMixMatchCreated."Currency Code" := PeriodicDiscQ."Discount Offer No.";
                    TempMixMatchCreated."Code 1" := PeriodicDiscQ."No.";
                    TempMixMatchCreated.Insert();
                end;
                if GuiAllowed then begin
                    Window.Update(1, 'Loading Discount Header...');
                    Window.Update(2, TmpPeriodicDiscount."No.");
                end;
                PeriodicDiscLineQ.SetRange(PeriodicDiscLineQ."Offer No.", PeriodicDiscQ."No.");
                //PeriodicDiscLineQ.Open();
                //while PeriodicDiscLineQ.Read do begin
                if PeriodicDiscLineQ.FindSet() then
                    repeat
                        TmpPeriodicDiscountLine.Init();
                        // TmpPeriodicDiscountLine."Header Type" := TmpPeriodicDiscount.Type;
                        // TmpPeriodicDiscountLine."Offer No." := PeriodicDiscLineQ.Offer_No;
                        // TmpPeriodicDiscountLine."Line No." := PeriodicDiscLineQ.Line_No;
                        // TmpPeriodicDiscountLine.Type := PeriodicDiscLineQ.Type;
                        // TmpPeriodicDiscountLine."No." := PeriodicDiscLineQ.No;
                        // TmpPeriodicDiscountLine."Disc. Type" := PeriodicDiscLineQ.Disc_Type;
                        // TmpPeriodicDiscountLine."Deal Price/Disc. %" := PeriodicDiscLineQ.Deal_Price_Dis_Pct;
                        // TmpPeriodicDiscountLine."Discount Amount" := PeriodicDiscLineQ.Discount_Amount;
                        // TmpPeriodicDiscountLine."Offer Price" := PeriodicDiscLineQ.Offer_Price;
                        // TmpPeriodicDiscountLine."Offer Price Including VAT" := PeriodicDiscLineQ.Offer_Price_Including_VAT;
                        // TmpPeriodicDiscountLine."Discount Amount Including VAT" := PeriodicDiscLineQ.Discount_Amount_Including_VAT;
                        // TmpPeriodicDiscountLine."Price Group" := PeriodicDiscLineQ.Price_Group;
                        // TmpPeriodicDiscountLine."Discount Offer No." := PeriodicDiscLineQ.Discount_Offer_No;
                        TmpPeriodicDiscountLine := PeriodicDiscLineQ;
                        TmpPeriodicDiscountLine.Insert();
                        if GuiAllowed then begin
                            Window.Update(1, 'Loading Discount Line...');
                            Window.Update(2, TmpPeriodicDiscountLine."Offer No.");
                        end;
                    until PeriodicDiscLineQ.Next() = 0;
            until PeriodicDiscQ.Next() = 0;
        //end;
        //PeriodicDiscLineQ.Close();
        //end;
        //PeriodicDiscQ.Close();
    end;

    local procedure LoadDistributionList(TableID: Integer; ValueIn: Text[100])
    var
        DistributionList: Record "LSC Distribution List";
    begin
        DistributionList.Reset();
        DistributionList.SetFilter("Table ID", '%1', TableID);
        DistributionList.SetFilter(Value, ValueIn);
        if DistributionList.FindSet() then
            repeat
                if GuiAllowed then begin
                    Window.Update(1, 'Loading Distribution...');
                    Window.Update(2, ValueIn);
                end;
                TempDistributionList.Init();
                TempDistributionList := DistributionList;
                TempDistributionList.Insert();
            until DistributionList.Next() = 0;
    end;

    procedure LoadValidationPeriod()
    var
        ValidationPeriod: Record "LSC Validation Period";
    begin
        if ValidationPeriod.FindSet() then
            repeat
                if GuiAllowed then begin
                    Window.Update(1, 'Loading Validation Period...');
                    Window.Update(2, ValidationPeriod.ID);
                end;
                TempValidationPeriod.Init();
                TempValidationPeriod := ValidationPeriod;
                TempValidationPeriod.Insert();
            until ValidationPeriod.Next() = 0;
    end;

    local procedure GeneratePerDiscSearchKey(ValueIn: code[20]; TableNo: Integer; VP: Code[10]): Code[250]
    Var
        KeyVal: Code[250];
        StoreNoInteger: Integer;
    begin
        if GuiAllowed then begin
            Window.Update(1, 'Generating PeriodicDiscount Key...');
            Window.Update(2, ValueIn);
        end;
        TempDistributionList.Reset();
        TempDistributionList.SetFilter("Table ID", '%1', TableNo);
        TempDistributionList.SetFilter(Value, ValueIn);
        if TempDistributionList.FindSet() then
            repeat
                Evaluate(StoreNoInteger, TempDistributionList."Store Group");
                KeyVal := KeyVal + Format(StoreNoInteger);
            until TempDistributionList.Next() = 0;
        KeyVal := KeyVal + VP;
        exit(KeyVal);
    end;

    local procedure CreateGroupedPromoBufferSearchKey()
    var
        KeyVal: Code[250];
        VP: Code[10];
        EntryNo: Integer;
    begin
        TempGroupedPromoBuffer2_DataSet1.Reset();
        EntryNo := 1;
        if TempGroupedPromoBuffer2_DataSet1.FindSet() then
            repeat
                if GuiAllowed then begin
                    Window.Update(1, 'Generating Promotion Key...');
                    Window.Update(2, TempGroupedPromoBuffer2_DataSet1."Entry No.");
                end;
                TempPromoBufferKey_DataSet3.Reset();
                TempPromoBufferKey_DataSet3.SetCurrentKey("Promotion Identifier", "Item Required", "Store Code", "Promotion From Date", "Promotion To Date");
                TempPromoBufferKey_DataSet3.SetFilter("Promotion Identifier", TempGroupedPromoBuffer2_DataSet1."Promotion Identifier");
                TempPromoBufferKey_DataSet3.SetRange("Promotion From Date", TempGroupedPromoBuffer2_DataSet1."Promotion From Date");
                TempPromoBufferKey_DataSet3.SetRange("Promotion To Date", TempGroupedPromoBuffer2_DataSet1."Promotion To Date");
                if not TempPromoBufferKey_DataSet3.FindFirst() then begin
                    VP := GetValidationPeriod(TempGroupedPromoBuffer2_DataSet1."Promotion From Date", TempGroupedPromoBuffer2_DataSet1."Promotion To Date");
                    KeyVal := GeneratePromoBufferSearchKey(TempGroupedPromoBuffer2_DataSet1."Promotion Identifier", VP);
                    TempPromoBufferKey_DataSet3.Reset();
                    TempPromoBufferKey_DataSet3.Init();
                    TempPromoBufferKey_DataSet3."Entry No." := EntryNo;
                    EntryNo += 1;
                    TempPromoBufferKey_DataSet3."Promotion Identifier" := TempGroupedPromoBuffer2_DataSet1."Promotion Identifier";
                    TempPromoBufferKey_DataSet3."Promotion From Date" := TempGroupedPromoBuffer2_DataSet1."Promotion From Date";
                    TempPromoBufferKey_DataSet3."Promotion To Date" := TempGroupedPromoBuffer2_DataSet1."Promotion To Date";
                    TempPromoBufferKey_DataSet3."Promotion Search Key" := KeyVal;
                    TempPromoBufferKey_DataSet3.Insert();
                end;
            until (TempGroupedPromoBuffer2_DataSet1.Next() = 0);
    end;

    local procedure GeneratePromoBufferSearchKey(PromoNo: Code[20]; VP: Code[10]): Code[250]
    Var
        KeyVal: Code[250];
        StoreNoInteger: Integer;
    begin
        TempPromoBufferDistList_DataSet2.Reset();
        TempPromoBufferDistList_DataSet2.SetRange("Table ID", Database::"Pos_Promotion Buffer_NT");
        TempPromoBufferDistList_DataSet2.SetFilter(Value, PromoNo);
        TempPromoBufferDistList_DataSet2.SetFilter("Group Code", VP);
        TempPromoBufferDistList_DataSet2.FindSet();
        repeat
            Evaluate(StoreNoInteger, TempPromoBufferDistList_DataSet2."Store Group");
            KeyVal := KeyVal + Format(StoreNoInteger);
        until TempPromoBufferDistList_DataSet2.Next() = 0;
        KeyVal := KeyVal + VP;
        exit(KeyVal);
    end;

    local procedure GetPromoBufferSearchKey(PromoNo: Code[20]; FromDT: Date; ToDT: Date): Code[250]
    var
    begin
        TempPromoBufferKey_DataSet3.Reset();
        TempPromoBufferKey_DataSet3.SetCurrentKey("Promotion Identifier", "Item Required", "Store Code", "Promotion From Date", "Promotion To Date");
        TempPromoBufferKey_DataSet3.SetFilter("Promotion Identifier", PromoNo);
        TempPromoBufferKey_DataSet3.SetRange("Promotion From Date", FromDT);
        TempPromoBufferKey_DataSet3.SetRange("Promotion To Date", ToDT);
        TempPromoBufferKey_DataSet3.FindFirst();
        exit(TempPromoBufferKey_DataSet3."Promotion Search Key");
    end;

    local procedure InitGlobals()
    begin
        TmpPeriodicDiscountLine.Reset();
        TmpPeriodicDiscountLine.DeleteAll();
        TmpPeriodicDiscount.Reset();
        TmpPeriodicDiscount.DeleteAll();
        TmpPeriodicDiscountLine.Reset();
        TmpPeriodicDiscountLine.DeleteAll();
        TempDistributionList.Reset();
        TempDistributionList.DeleteAll();
        TempValidationPeriod.Reset();
        TempValidationPeriod.DeleteAll();
        TempCreatedUpdPeriodicDisc.Reset();
        TempCreatedUpdPeriodicDisc.DeleteAll();
        TempGroupedPromoBuffer_DataSet1.Reset();
        TempGroupedPromoBuffer_DataSet1.DeleteAll();
        TempGroupedPromoBuffer2_DataSet1.Reset();
        TempGroupedPromoBuffer2_DataSet1.DeleteAll();
        TempPromotionsToUpdate2.Reset();
        TempPromotionsToUpdate2.DeleteAll();
        TempMixMatchCreated.Reset();
        TempMixMatchCreated.DeleteAll();
        if not RetailSetup.Get() then
            RetailSetup.Init();
    end;

    local procedure ProcessGroupedData()
    var
        PromoKey: code[250];
        ValueToMatch: Decimal;
    begin
        TempPromoBufferItems_DataSet4.Reset();
        //TempPromoBufferItems_DataSet4.SetFilter("Promotion Type", '2|9'); //TO BE REMOVED
        if TempPromoBufferItems_DataSet4.FindSet() then
            repeat
                PromoKey := GetPromoBufferSearchKey(TempPromoBufferItems_DataSet4."Promotion Identifier", TempPromoBufferItems_DataSet4."Promotion From Date", TempPromoBufferItems_DataSet4."Promotion To Date");
                TempPromoBufferItems_DataSet4."Promotion Search Key" := PromoKey;
                TempPromoBufferItems_DataSet4.Modify();// Update key require to match While Checking for Deletion
                ValueToMatch := 0;
                if GuiAllowed then begin
                    Window.Update(1, 'Processing Data..Filtering Line...');
                    Window.Update(2, TempPromoBufferItems_DataSet4."Promotion Identifier");
                end;
                FilterPerDiscLineValidationPeriod
                    (TempPromoBufferItems_DataSet4."Item Required"
                    , TempPromoBufferItems_DataSet4."Promotion From Date"
                    , TempPromoBufferItems_DataSet4."Promotion To Date"
                    , TempPromoBufferItems_DataSet4."Promotion Identifier"
                    , PromoKey);
                TmpPeriodicDiscountLine.MarkedOnly(true);
                if TmpPeriodicDiscountLine.Count <> 0 then begin
                    if GuiAllowed then begin
                        Window.Update(1, 'Processing Data..Matching Price...');
                        Window.Update(2, TempPromoBufferItems_DataSet4."Promotion Identifier");
                    end;
                    TmpPeriodicDiscount.Get(TmpPeriodicDiscountLine."Offer No.");
                    case TempPromoBufferItems_DataSet4."Promotion Type" of
                        '2':
                            if MatchPriceOrPercentageInMarkedLines(TempPromoBufferItems_DataSet4."Promotion Type", TempPromoBufferItems_DataSet4."Discount Percentage_Dec") then begin
                                NothingToDo += 1;
                            end else begin
                                UpdatePeriodicDisc(TempPromoBufferItems_DataSet4, TmpPeriodicDiscount."Promotion Search Key");
                                ToModifyDisc += 1;
                            end;
                        '9':
                            begin
                                Evaluate(ValueToMatch, TempPromoBufferItems_DataSet4."Promotion Price");
                                ValueToMatch := ValueToMatch / 100;

                                if MatchPriceOrPercentageInMarkedLines(TempPromoBufferItems_DataSet4."Promotion Type", ValueToMatch) then begin
                                    NothingToDo += 1;
                                end else begin
                                    UpdatePeriodicDisc(TempPromoBufferItems_DataSet4, TmpPeriodicDiscount."Promotion Search Key");
                                    ToModifyPrice += 1;
                                end;
                            end;
                        '1', '6':
                            begin
                                CheckAndUpdateMixMatch(TempPromoBufferItems_DataSet4, TmpPeriodicDiscount, TmpPeriodicDiscountLine);
                            end;
                    end;
                end else begin
                    CreatePeriodicDisc(TempPromoBufferItems_DataSet4, GetPromoBufferSearchKey(TempPromoBufferItems_DataSet4."Promotion Identifier", TempPromoBufferItems_DataSet4."Promotion From Date", TempPromoBufferItems_DataSet4."Promotion To Date"));
                    LinesToInsert += 1;
                end;
            until TempPromoBufferItems_DataSet4.Next() = 0;
        if GuiAllowed then
            Message(StrSubstNo(ProcMsg, NothingToDo, ToModifyPrice, ToModifyDisc, LinesDeleted, HeadersDeleted, LinesToInsert));
    end;

    local procedure FilterPerDiscLineValidationPeriod(ItemNo: Code[20]; StartDt: date; EndDT: Date; PromoIdentifier: Code[20]; PromoKeyIn: code[250])

    begin
        TmpPeriodicDiscountLine.Reset();
        TmpPeriodicDiscountLine.ClearMarks();
        TmpPeriodicDiscountLine.SetCurrentKey(Type, "No.");
        TmpPeriodicDiscountLine.SetCurrentKey("Discount Offer No.");

        TmpPeriodicDiscountLine.SetRange(Type, TmpPeriodicDiscountLine.Type::Item);
        TmpPeriodicDiscountLine.SetRange("No.", ItemNo);
        TmpPeriodicDiscountLine.SetRange("Discount Offer No.", PromoIdentifier);
        if TmpPeriodicDiscountLine.IsEmpty then
            exit;

        TmpPeriodicDiscountLine.FindSet();
        repeat
            if TmpPeriodicDiscount."No." <> TmpPeriodicDiscountLine."Offer No." then
                TmpPeriodicDiscount.Get(TmpPeriodicDiscountLine."Offer No.");

            // if TempValidationPeriod.ID <> TmpPeriodicDiscount."Validation Period ID" then
            //     TempValidationPeriod.Get(TmpPeriodicDiscount."Validation Period ID");

            // if (TempValidationPeriod."Starting Date" = StartDt) and (TempValidationPeriod."Ending Date" = EndDT) then
            //     if CheckStoreGroup(TmpPeriodicDiscount."No.", PromoIdentifier, TmpPeriodicDiscount."Validation Period ID") then            
            //         TmpPeriodicDiscountLine.Mark(true);
            if PromoKeyIn = TmpPeriodicDiscount."Promotion Search Key" then // SEAR KEY Promotion Identifier and Validation Period
                TmpPeriodicDiscountLine.Mark(true);
        until TmpPeriodicDiscountLine.Next() = 0;
    end;

    local procedure CheckStoreGroup(DiscNo: Code[20]; PromoIdentifier: Code[20]; VP: code[10]): Boolean
    var
    begin
        TempDistributionList.Reset();
        TempDistributionList.SetRange("Table ID", Database::"LSC Periodic Discount");
        TempDistributionList.SetFilter(Value, DiscNo);
        if not TempDistributionList.FindFirst() then
            exit(false);

        TempPromoBufferDistList_DataSet2.Reset();
        TempPromoBufferDistList_DataSet2.SetRange(Value, PromoIdentifier);
        TempPromoBufferDistList_DataSet2.SetRange("Group Code", VP);
        if not TempPromoBufferDistList_DataSet2.FindFirst() then
            exit(false);

        if TempDistributionList.Count <> TempPromoBufferDistList_DataSet2.Count then
            exit(false);
        TempDistributionList.FindSet();
        repeat
            TempPromoBufferDistList_DataSet2.SetFilter("Store Group", TempDistributionList."Store Group");
            if not TempPromoBufferDistList_DataSet2.FindFirst() then
                exit(false);
        until TempDistributionList.Next() = 0;
        exit(true);
    end;

    local procedure MatchPriceOrPercentageInMarkedLines(PromoType: Code[1]; ValueToMatch: Decimal): Boolean
    var
        Matched: Boolean;
    begin
        Matched := false;
        case PromoType of
            '2':
                begin
                    if TmpPeriodicDiscountLine.FindSet() then
                        repeat
                            if TmpPeriodicDiscountLine."Deal Price/Disc. %" = ValueToMatch then
                                Matched := true;
                        until TmpPeriodicDiscountLine.Next() = 0;
                    exit(Matched);
                end;
            '9':
                begin
                    if TmpPeriodicDiscountLine.FindSet() then
                        repeat
                            if TmpPeriodicDiscountLine."Offer Price Including VAT" = ValueToMatch then
                                Matched := true;
                        until TmpPeriodicDiscountLine.Next() = 0;
                    exit(Matched);
                end;
            '6':
                begin

                end;
        end;
    end;

    procedure GetValidationPeriod(StartDate: Date; EndDate: Date): Code[10]
    var
        NewValidationPeriod: Record "LSC Validation Period";
        ValidationPeriod: Record "LSC Validation Period";
    begin
        if GuiAllowed then begin
            Window.Update(1, 'Generating Validation Period...');
            //Window.Update(2, StrSubstNo('Period..%1..%2', StartDate, EndDate));
        end;
        TempValidationPeriod.Reset();
        TempValidationPeriod.SetRange("Starting Date", StartDate);
        TempValidationPeriod.SetRange("Ending Date", EndDate);
        if TempValidationPeriod.FindFirst() then
            exit(TempValidationPeriod.ID);
        Clear(TempValidationPeriod);
        Clear(NewValidationPeriod);
        TempValidationPeriod.SetFilter(ID, '0?????????');
        if TempValidationPeriod.FindLast() then
            NewValidationPeriod.ID := IncStr(TempValidationPeriod.ID)
        else
            NewValidationPeriod.ID := IncStr('0000000001');
        NewValidationPeriod."Starting Date" := StartDate;
        NewValidationPeriod."Ending Date" := EndDate;
        NewValidationPeriod.Description := 'BC220';//TO BE REMOVED
        NewValidationPeriod.Insert(true);
        TempValidationPeriod.Reset();
        TempValidationPeriod.Init();
        TempValidationPeriod := NewValidationPeriod;
        TempValidationPeriod.Insert();
        exit(NewValidationPeriod.ID);
    end;

    local procedure CreatePeriodicDisc(var PromoBufferIn: Record "Pos_Promotion Buffer_NT" temporary; SearchKey: Code[50])
    var
        PeriodicDisc: Record "LSC Periodic Discount";
    begin
        GetPeriodicDiscHeader(PeriodicDisc, PromoBufferIn, SearchKey);
        CreatePeriodicDiscLines(PeriodicDisc, PromoBufferIn);
    end;

    local procedure UpdatePeriodicDisc(var PromoBufferIn: Record "Pos_Promotion Buffer_NT" temporary; SearchKey: Code[50])
    var
        PeriodicDisc: Record "LSC Periodic Discount";
    begin
        GetPeriodicDiscHeader(PeriodicDisc, PromoBufferIn, SearchKey);
        UpdatePerDiscLines(PeriodicDisc, PromoBufferIn);
    end;

    local procedure GetPeriodicDiscHeader(var PeriodicDisc: Record "LSC Periodic Discount"; var PromoBufferIn: Record "Pos_Promotion Buffer_NT" temporary; SearchKey: Code[50])
    var
        DistributionList: Record "LSC Distribution List";
        PromoFound: Boolean;
    begin
        Clear(PeriodicDisc);
        TmpPeriodicDiscount.Reset();
        TmpPeriodicDiscount.SetCurrentKey("Promotion Search Key");
        TmpPeriodicDiscount.SetRange(TmpPeriodicDiscount."Promotion Search Key", SearchKey);//KEY
        case PromoBufferIn."Promotion Type" of
            '2', '9':
                begin
                    TmpPeriodicDiscount.SetRange(Type, TmpPeriodicDiscount.Type::"Disc. Offer");
                    PromoFound := TmpPeriodicDiscount.FindFirst();
                end;
            '1', '6':
                begin
                    TmpPeriodicDiscount.SetRange(TmpPeriodicDiscount."Promotion Search Key");//Remove for Mix&Match
                    PromoFound := TempMixMatchCreated.Get(PromoBufferIn."Promotion Identifier");                    
                    if PromoFound then begin
                        TmpPeriodicDiscount.SetRange(Type, TmpPeriodicDiscount.Type::"Mix&Match");
                        TmpPeriodicDiscount.SetRange("No.", TempMixMatchCreated."Code 1");
                        PromoFound := TmpPeriodicDiscount.FindFirst();
                    end;
                end;
        end;

        if PromoFound then begin
            PeriodicDisc.Get(TmpPeriodicDiscount."No.");
            if GuiAllowed then begin
                Window.Update(1, 'Update Periodic Discount...');
                Window.Update(2, PeriodicDisc."No.");
            end;
            PeriodicDisc.Status := PeriodicDisc.Status::Disabled;
            //PeriodicDisc."Currency Code" := 'BC220';//TO BE REMOVED           
            PeriodicDisc.Modify();
            TempCreatedUpdPeriodicDisc.Init();
            TempCreatedUpdPeriodicDisc := PeriodicDisc;
            if TempCreatedUpdPeriodicDisc.Insert() then;
        end else begin
            Clear(PeriodicDisc);
            PeriodicDisc."Discount Type" := PeriodicDisc."Discount Type"::"Line spec.";
            case PromoBufferIn."Promotion Type" of
                '2', '9':
                    begin
                        PeriodicDisc.Type := PeriodicDisc.Type::"Disc. Offer";
                        PeriodicDisc."Offer Type" := PeriodicDisc."Offer Type"::"Disc. Offer";
                    end;
                '1', '6':
                    begin
                        PeriodicDisc.Type := PeriodicDisc.Type::"Mix&Match";
                        PeriodicDisc."Offer Type" := PeriodicDisc."Offer Type"::"Mix&Match";
                        PeriodicDisc."Discount Offer No." := PromoBufferIn."Promotion Identifier";
                        if PromoBufferIn."Promotion Type" = '1' then begin
                            PeriodicDisc."Discount Type" := PeriodicDisc."Discount Type"::"Discount Amount";
                        end else begin
                            PeriodicDisc."Discount Type" := PeriodicDisc."Discount Type"::"Deal Price";
                            Evaluate(PeriodicDisc."Deal Price Value", PromoBufferIn."Promotion Price");
                            PeriodicDisc.Validate("Deal Price Value", PeriodicDisc."Deal Price Value" / 100);
                        end;
                    end;
            end;
            PeriodicDisc.Insert(true);
            if PeriodicDisc.Type = PeriodicDisc.Type::"Mix&Match" then begin
                TempMixMatchCreated.Init();
                TempMixMatchCreated."Currency Code" := PromoBufferIn."Promotion Identifier";
                TempMixMatchCreated."Code 1" := PeriodicDisc."No.";
                TempMixMatchCreated.Insert();
            end;
            PeriodicDisc."Validation Period ID" := GetValidationPeriod(PromoBufferIn."Promotion From Date", PromoBufferIn."Promotion To Date");

            PeriodicDisc.Description := 'Discount Offer';
            if PeriodicDisc."Offer Type" = PeriodicDisc."Offer Type"::"Mix&Match" then
                PeriodicDisc.Description := COPYSTR(PromoBufferIn."Promotion Receipt Line", 1, 30);

            PeriodicDisc.Validate("Price Group", 'AL');
            PeriodicDisc."Created From Promotion File" := true;
            PeriodicDisc."Promotion Search Key" := SearchKey;//KEY
            //PeriodicDisc."Currency Code" := 'BC220';//TO BE REMOVED
            PeriodicDisc.Modify(true);
            DistributionList.SetRange("Table ID", Database::"LSC Periodic Discount");
            DistributionList.SetRange(Value, PeriodicDisc."No.");
            DistributionList.DeleteAll();

            Clear(DistributionList);
            //Ditribution
            TempPromoBufferDistList_DataSet2.Reset();
            TempPromoBufferDistList_DataSet2.SetRange("Table ID", Database::"Pos_Promotion Buffer_NT");
            TempPromoBufferDistList_DataSet2.SetFilter(Value, PromoBufferIn."Promotion Identifier");
            TempPromoBufferDistList_DataSet2.SetFilter("Group Code", PeriodicDisc."Validation Period ID");
            TempPromoBufferDistList_DataSet2.FindSet();
            repeat
                DistributionList.Init();
                DistributionList."Table ID" := Database::"LSC Periodic Discount";
                DistributionList.Value := PeriodicDisc."No.";
                DistributionList.Validate("Store Group", TempPromoBufferDistList_DataSet2."Store Group");
                DistributionList.Insert();

                TempDistributionList.Reset();
                TempDistributionList.Init();
                TempDistributionList := DistributionList;
                TempDistributionList.Insert();
            until TempPromoBufferDistList_DataSet2.Next() = 0;


            TmpPeriodicDiscount.Reset();
            TmpPeriodicDiscount.Init();
            TmpPeriodicDiscount := PeriodicDisc;
            TmpPeriodicDiscount.Insert();

            TempCreatedUpdPeriodicDisc.Init();
            TempCreatedUpdPeriodicDisc := PeriodicDisc;
            if TempCreatedUpdPeriodicDisc.Insert() then;
            if GuiAllowed then begin
                Window.Update(1, 'Create Periodic Discount...');
                Window.Update(2, PeriodicDisc."No.");
            end;
        end;
    end;


    local procedure CreatePeriodicDiscLines(var PeriodicDisc: Record "LSC Periodic Discount"; var PromoBufferIn: Record "Pos_Promotion Buffer_NT" temporary)
    var
        MixMatchLineGroup: Record "LSC Mix & Match Line Groups";
        PerDiscLine2: Record "LSC Periodic Discount Line";
        PerDiscLine: Record "LSC Periodic Discount Line";
        DiscAmt: Decimal;
        FreeQty: Decimal;
        NextLineNo: Integer;
    begin
        if GuiAllowed then begin
            Window.Update(1, 'Create Periodic Disc Lines...');
            Window.Update(2, PeriodicDisc."No.");
        end;

        TmpPeriodicDiscountLine.Reset();
        TmpPeriodicDiscountLine.ClearMarks();
        TmpPeriodicDiscountLine.SetRange("Offer No.", PeriodicDisc."No.");
        if TmpPeriodicDiscountLine.FindLast() then
            NextLineNo := TmpPeriodicDiscountLine."Line No." + 10000
        else
            NextLineNo := 10000;

        PerDiscLine.Init();
        PerDiscLine.Validate("Offer No.", PeriodicDisc."No.");
        PerDiscLine."Discount Offer No." := PromoBufferIn."Promotion Identifier";
        PerDiscLine.Type := PerDiscLine.Type::Item;
        if PeriodicDisc.Type = PeriodicDisc.Type::"Mix&Match" then
            PerDiscLine."Price Group" := PeriodicDisc."Price Group";
        PerDiscLine.Validate("No.", PromoBufferIn."Item Required");
        PerDiscLine."Discount Offer Description" := COPYSTR(PromoBufferIn."Promotion Receipt Line", 1, 30);
        PerDiscLine."Category Code" := PromoBufferIn."Promotion Event Category";
        PerDiscLine."Category Description" := PromoBufferIn."Event Category Description";
        PerDiscLine."Line No." := NextLineNo;
        case PromoBufferIn."Promotion Type" of
            '2', '9':
                begin
                    if PromoBufferIn."Promotion Type" = '9' then begin
                        PerDiscLine."Disc. Type" := PerDiscLine."Disc. Type"::"Deal Price";
                        Evaluate(PerDiscLine."Offer Price Including VAT", PromoBufferIn."Promotion Price");
                        PerDiscLine.Validate("Offer Price Including VAT", PerDiscLine."Offer Price Including VAT" / 100);
                    end else begin
                        PerDiscLine."Disc. Type" := PerDiscLine."Disc. Type"::"Disc. %";
                        PerDiscLine.Validate("Deal Price/Disc. %", PromoBufferIn."Discount Percentage_Dec");
                    END;
                    //PerDiscLine."Currency Code" := 'BC220';//TO BE REMOVED
                    //If Same item Exists with Different Promotion Identifier
                    if not DiscLineExists(PerDiscLine) then begin
                        PerDiscLine.Insert(true);

                        TmpPeriodicDiscountLine.Reset();
                        TmpPeriodicDiscountLine.Init();
                        TmpPeriodicDiscountLine := PerDiscLine;
                        if not TmpPeriodicDiscountLine.Insert() then
                            TmpPeriodicDiscountLine.Modify();
                    end;
                    //else begin
                    if PromoBufferIn."Promotion Type" = '9' then begin
                        PerDiscLine."Disc. Type" := PerDiscLine."Disc. Type"::"Deal Price";
                        Evaluate(PerDiscLine."Offer Price Including VAT", PromoBufferIn."Promotion Price");
                        PerDiscLine.Validate("Offer Price Including VAT", PerDiscLine."Offer Price Including VAT" / 100);
                    end else begin
                        PerDiscLine."Disc. Type" := PerDiscLine."Disc. Type"::"Disc. %";
                        PerDiscLine.Validate("Deal Price/Disc. %", PromoBufferIn."Discount Percentage_Dec");
                    END;
                    if (RetailSetup."Max Discount %" > 0) and (PerDiscLine."Standard Price Including VAT" > 0) then
                        PerDiscLine."Over Limit Discount" := PerDiscLine."Offer Price Including VAT" / PerDiscLine."Standard Price Including VAT" > RetailSetup."Max Discount %";
                    //PerDiscLine."Currency Code" := 'BC220U';//TO BE REMOVED
                    PerDiscLine."Discount Offer No." := PromoBufferIn."Promotion Identifier";//Since Disc Offer No restates in function DiscLineExists 
                    PerDiscLine.Modify(true);

                    TmpPeriodicDiscountLine.Reset();
                    TmpPeriodicDiscountLine.ClearMarks();
                    TmpPeriodicDiscountLine := PerDiscLine;
                    TmpPeriodicDiscountLine.Modify();
                    //end;
                end;
            '1', '6':
                begin
                    Evaluate(FreeQty, PromoBufferIn."Item Free Quantity");
                    if not MixMatchLineGroup.Get(PeriodicDisc."No.", 'A') then begin
                        CLEAR(MixMatchLineGroup);
                        MixMatchLineGroup."Group No." := PeriodicDisc."No.";
                        MixMatchLineGroup."Line Group Code" := 'A';
                        MixMatchLineGroup."Value 1" := PromoBufferIn."Item Required Quantity_Dec";
                        MixMatchLineGroup.Insert();
                    end;
                    IF PromoBufferIn."Promotion Type" = '1' THEN BEGIN
                        if PromoBufferIn."Item Required" <> PromoBufferIn."Item Free" then BEGIN
                            NextLineNo += 10000;
                            PerDiscLine2 := PerDiscLine;
                            //PerDiscLine2."Line No." := NextLineNo;
                            PerDiscLine2.Validate("No.", PromoBufferIn."Item Free");
                            PerDiscLine2.Validate("Line Group", 'A');
                            PerDiscLine2."Category Code" := PromoBufferIn."Promotion Event Category";
                            PerDiscLine2."Category Description" := PromoBufferIn."Event Category Description";
                            PerDiscLine2."Line No." := NextLineNo;
                            if not DiscLineExists(PerDiscLine2) then begin
                                PerDiscLine2.Insert(true);
                                TmpPeriodicDiscountLine.Reset();
                                TmpPeriodicDiscountLine.Init();
                                TmpPeriodicDiscountLine := PerDiscLine2;
                                if not TmpPeriodicDiscountLine.Insert() then
                                    TmpPeriodicDiscountLine.Modify();
                            end;
                            DiscAmt := PerDiscLine2."Standard Price Including VAT" * FreeQty;
                        END;
                        if PromoBufferIn."Item Required" = PromoBufferIn."Item Free" then
                            DiscAmt := PerDiscLine."Standard Price Including VAT" * FreeQty;
                        PerDiscLine.Validate("Line Group", 'A');
                        IF DiscAmt > 0 THEN
                            if not TempPromotionsToUpdate2.Get(PromoBufferIn."Promotion Identifier") then begin                                 //PeriodicDisc.GET(PromotionIdentifier);
                                PeriodicDisc."Discount Type" := PeriodicDisc."Discount Type"::"Discount Amount";
                                PeriodicDisc."Discount Amount Value" := DiscAmt;
                                PeriodicDisc."Discount % Value" := 0;
                                PeriodicDisc.Modify();

                                TmpPeriodicDiscount.Reset();
                                TmpPeriodicDiscount.Get(PeriodicDisc."No.");
                                TmpPeriodicDiscount := PeriodicDisc;
                                TmpPeriodicDiscount.Modify();

                                TempPromotionsToUpdate2.Init();
                                TempPromotionsToUpdate2."Currency Code" := PromoBufferIn."Promotion Identifier";
                                TempPromotionsToUpdate2.Insert();
                            end;
                    end else
                        PerDiscLine.Validate("Line Group", 'A');
                    if (RetailSetup."Max Discount %" > 0) and (PerDiscLine."Standard Price Including VAT" > 0) then
                        PerDiscLine."Over Limit Discount" := PerDiscLine."Offer Price Including VAT" / PerDiscLine."Standard Price Including VAT" > RetailSetup."Max Discount %";

                    if not DiscLineExists(PerDiscLine) then begin
                        PerDiscLine.Insert(true);
                        TmpPeriodicDiscountLine.Reset();
                        TmpPeriodicDiscountLine.Init();
                        TmpPeriodicDiscountLine := PerDiscLine;
                        if not TmpPeriodicDiscountLine.Insert() then
                            TmpPeriodicDiscountLine.Modify();
                    end;
                end;
        end;
    end;

    local procedure UpdatePerDiscLines(var PeriodicDisc: Record "LSC Periodic Discount"; var PromoBufferIn: Record "Pos_Promotion Buffer_NT" temporary)
    var
        PerDiscLine: Record "LSC Periodic Discount Line";
    begin
        if GuiAllowed then begin
            Window.Update(1, 'Updating Periodic Disc Lines...');
            Window.Update(2, PeriodicDisc."No.");
        end;
        TmpPeriodicDiscountLine.Reset();
        TmpPeriodicDiscountLine.SetRange("Offer No.", PeriodicDisc."No.");
        TmpPeriodicDiscountLine.SetRange(Type, TmpPeriodicDiscountLine.Type::Item);
        TmpPeriodicDiscountLine.SetFilter("No.", PromoBufferIn."Item Required");
        TmpPeriodicDiscountLine.FindLast();

        if PromoBufferIn."Promotion Type" = '9' then begin
            Evaluate(TmpPeriodicDiscountLine."Offer Price Including VAT", PromoBufferIn."Promotion Price");
            //TmpPeriodicDiscountLine."Offer Price Including VAT" := TmpPeriodicDiscountLine."Offer Price Including VAT" / 100;
            TmpPeriodicDiscountLine.Validate("Offer Price Including VAT", TmpPeriodicDiscountLine."Offer Price Including VAT" / 100);
        end else begin
            TmpPeriodicDiscountLine."Disc. Type" := TmpPeriodicDiscountLine."Disc. Type"::"Disc. %";
            TmpPeriodicDiscountLine.Validate("Deal Price/Disc. %", PromoBufferIn."Discount Percentage_Dec");
        end;
        TmpPeriodicDiscountLine.Modify();
        Clear(PerDiscLine);
        PerDiscLine := TmpPeriodicDiscountLine;
        //PerDiscLine."Currency Code" := 'BC220U';//TO BE REMOVED        
        PerDiscLine.Modify(true);
    end;

    local procedure SetDiscStatusEnabled()
    var
        PerDisc: Record "LSC Periodic Discount";
    begin
        TempCreatedUpdPeriodicDisc.Reset();
        if TempCreatedUpdPeriodicDisc.FindSet() then
            repeat
                PerDisc.Get(TempCreatedUpdPeriodicDisc."No.");
                PerDisc.Status := PerDisc.Status::Enabled;
                PerDisc.Modify();
            until TempCreatedUpdPeriodicDisc.Next() = 0;
    end;

    procedure DiscLineExists(var PerDiscLine: Record "LSC Periodic Discount Line"): Boolean
    begin
        TmpPeriodicDiscountLine.Reset;
        TmpPeriodicDiscountLine.SetRange("Offer No.", PerDiscLine."Offer No.");
        TmpPeriodicDiscountLine.SetRange("No.", PerDiscLine."No.");
        TmpPeriodicDiscountLine.SetRange(Type, PerDiscLine.Type);
        TmpPeriodicDiscountLine.SetRange("Unit of Measure", PerDiscLine."Unit of Measure");
        TmpPeriodicDiscountLine.SetRange("Variant Code", PerDiscLine."Variant Code");
        if TmpPeriodicDiscountLine.FindFirst then
            repeat
                if TmpPeriodicDiscountLine."Line No." <> PerDiscLine."Line No." then begin
                    PerDiscLine := TmpPeriodicDiscountLine;
                    exit(true);
                end;
            until TmpPeriodicDiscountLine.Next = 0;
        exit(false);
    end;

    procedure DeleteNonExistentDiscounts()
    var
        DistList: Record "LSC Distribution List";
        lMMLineGroup: Record "LSC Mix & Match Line Groups";
        lPerDiscBenefits: Record "LSC Periodic Discount Benefits";
        PerDiscLineRec: Record "LSC Periodic Discount Line";
        PerDiscRec: Record "LSC Periodic Discount";
    begin
        //DELETE Lines
        TmpPeriodicDiscount.Reset();
        TmpPeriodicDiscountLine.Reset();
        TmpPeriodicDiscountLine.ClearMarks();
        if TmpPeriodicDiscountLine.FindSet() then
            repeat
                if GuiAllowed then begin
                    Window.Update(1, 'Checking Periodic Disc.Lines For deletion...');
                    Window.Update(2, TmpPeriodicDiscountLine."Offer No.");
                end;
                if TmpPeriodicDiscount."No." <> TmpPeriodicDiscountLine."Offer No." then
                    TmpPeriodicDiscount.Get(TmpPeriodicDiscountLine."Offer No.");
                if TmpPeriodicDiscount.Type <> TmpPeriodicDiscount.Type::"Mix&Match" then begin //MIX&Match Always deleted and created
                    TempPromoBufferItems_DataSet4.Reset();
                    TempPromoBufferItems_DataSet4.SetCurrentKey("Promotion Search Key");
                    TempPromoBufferItems_DataSet4.SetRange("Promotion Search Key", TmpPeriodicDiscount."Promotion Search Key");
                    TempPromoBufferItems_DataSet4.SetRange("Promotion Identifier", TmpPeriodicDiscountLine."Discount Offer No.");
                    TempPromoBufferItems_DataSet4.SetRange("Item Required", TmpPeriodicDiscountLine."No.");

                    if TempPromoBufferItems_DataSet4.IsEmpty then begin
                        PerDiscLineRec.Get(TmpPeriodicDiscountLine."Offer No.", TmpPeriodicDiscountLine."Line No.");
                        if GuiAllowed then begin
                            Window.Update(1, 'Deleting Periodic Disc. Line...');
                            Window.Update(2, StrSubstNo('%1 %2', TmpPeriodicDiscountLine."Offer No.", TmpPeriodicDiscountLine."Line No."));
                        end;
                        LinesDeleted += 1;
                        PerDiscLineRec.Delete();
                        TmpPeriodicDiscountLine.Delete();
                    end;
                end;
            until TmpPeriodicDiscountLine.Next() = 0;

        //Header Deletion
        TmpPeriodicDiscount.Reset();
        if TmpPeriodicDiscount.FindSet() then
            repeat
                TmpPeriodicDiscountLine.Reset();
                TmpPeriodicDiscountLine.SetRange("Offer No.", TmpPeriodicDiscount."No.");
                if TmpPeriodicDiscountLine.IsEmpty then begin
                    PerDiscRec.Get(TmpPeriodicDiscount."No.");
                    if PerDiscRec.Status = PerDiscRec.Status::Enabled then begin
                        PerDiscRec.Status := PerDiscRec.Status::Disabled;
                        PerDiscRec.Modify();
                    end;
                    lPerDiscBenefits.Reset;
                    lPerDiscBenefits.SetRange("Offer No.", TmpPeriodicDiscount."No.");
                    if lPerDiscBenefits.FindSet then begin
                        repeat
                            lPerDiscBenefits.Delete();
                        until lPerDiscBenefits.Next = 0;
                    end;

                    if TmpPeriodicDiscount.Type = TmpPeriodicDiscount.Type::"Mix&Match" then begin
                        lMMLineGroup.Reset;
                        lMMLineGroup.SetRange("Group No.", TmpPeriodicDiscount."No.");
                        if lMMLineGroup.FindSet then
                            repeat
                                lMMLineGroup.Delete();
                            until lMMLineGroup.Next = 0;
                    end;
                    if GuiAllowed then begin
                        Window.Update(1, 'Deleting Periodic Disc. Header...');
                        Window.Update(2, PerDiscRec."No.");
                    end;
                    DistList.SetRange("Table ID", Database::"LSC Periodic Discount");
                    DistList.SetRange(Value, PerDiscRec."No.");
                    DistList.DeleteAll();

                    // PerDiscRec2.SetCurrentKey(Priority);
                    // PerDiscRec2.SetFilter(Priority, '>%1', PerDiscRec.Priority);
                    // if PerDiscRec2.FindSet then
                    //     repeat
                    //         PerDiscRec2.Priority -= 10;
                    //         //PerDiscRec2.AllowModify;
                    //         PerDiscRec2.Modify();
                    //     until PerDiscRec2.Next = 0;
                    HeadersDeleted += 1;

                    //if TempCreatedUpdPeriodicDisc.Get(TmpPeriodicDiscount."No.") then
                    //  TmpPeriodicDiscount.Delete();

                    PerDiscRec.Delete();
                    TmpPeriodicDiscount.Delete();

                end;
            until TmpPeriodicDiscount.Next() = 0;
    end;

    local procedure CheckAndUpdateMixMatch(var PromoBufferItemsIn: Record "Pos_Promotion Buffer_NT" temporary; var TmpPeriodicDisIn: Record "LSC Periodic Discount" temporary; var TmpPerDiscLineIn: Record "LSC Periodic Discount Line" temporary)
    var
        MixMatchLineGroup: Record "LSC Mix & Match Line Groups";
        PerDisc: Record "LSC Periodic Discount";
        PromoLineChanged: Boolean;
        DiscAmt: Decimal;
        FreeQty: Decimal;
        ValueToMatch: Decimal;
    begin
        case PromoBufferItemsIn."Promotion Type" of
            '6':
                begin
                    PromoLineChanged := false;
                    Evaluate(ValueToMatch, PromoBufferItemsIn."Promotion Price");
                    ValueToMatch := ValueToMatch / 100;

                    if TmpPeriodicDisIn."Deal Price Value" <> ValueToMatch then begin
                        PerDisc.Get(TmpPeriodicDisIn."No.");
                        PerDisc.Status := PerDisc.Status::Disabled;
                        PerDisc.Description := CopyStr(PromoBufferItemsIn."Promotion Receipt Line", 1, 30);
                        PerDisc."Deal Price Value" := ValueToMatch;
                        PerDisc.Modify();
                        //Recreate Lines as Price might change
                        DeleteMixMatchLines(TmpPeriodicDisIn, TmpPerDiscLineIn);
                        CreatePeriodicDiscLines(PerDisc, PromoBufferItemsIn);
                        TempCreatedUpdPeriodicDisc.Init();
                        TempCreatedUpdPeriodicDisc := PerDisc;
                        if TempCreatedUpdPeriodicDisc.Insert() then;
                        ToModifyPrice += 1;
                        exit;
                    end;
                end;
            '1':
                begin
                    DiscAmt := 0;
                    PromoLineChanged := false;
                    Evaluate(FreeQty, PromoBufferItemsIn."Item Free Quantity");
                    //PerDisc.Get(TmpPeriodicDisIn."No.");
                    DiscAmt := TmpPerDiscLineIn."Standard Price Including VAT" * FreeQty;
                    PromoLineChanged := TmpPeriodicDisIn."Discount Amount Value" <> DiscAmt;

                    if PromoBufferItemsIn."Item Required" <> PromoBufferItemsIn."Item Free" then
                        if not PromoLineChanged then begin
                            TmpPerDiscLineIn.SetRange("No.", PromoBufferItemsIn."Item Free");
                            PromoLineChanged := not TmpPerDiscLineIn.FindFirst();
                            if not PromoLineChanged then begin
                                DiscAmt := TmpPerDiscLineIn."Standard Price Including VAT" * FreeQty;
                                PromoLineChanged := PerDisc."Discount Amount Value" <> DiscAmt;
                            end;
                        end;
                    if not PromoLineChanged then begin
                        PromoLineChanged := PromoBufferItemsIn."Item Free" <> PromoBufferItemsIn."Item Required";
                    end;
                end;
        end;
        MixMatchLineGroup.Get(TmpPeriodicDisIn."No.", 'A');
        if not PromoLineChanged then
            PromoLineChanged := MixMatchLineGroup."Value 1" <> PromoBufferItemsIn."Item Required Quantity_Dec";

        if PromoLineChanged then begin
            PerDisc.Get(TmpPeriodicDisIn."No.");
            PerDisc.Status := PerDisc.Status::Disabled;
            PerDisc.Modify();
            DeleteMixMatchLines(TmpPeriodicDisIn, TmpPerDiscLineIn);
            CreatePeriodicDiscLines(PerDisc, PromoBufferItemsIn);
            TempCreatedUpdPeriodicDisc.Init();
            TempCreatedUpdPeriodicDisc := PerDisc;
            if TempCreatedUpdPeriodicDisc.Insert() then;
        end;
        if not PromoLineChanged then
            NothingToDo += 1
        else
            ToModifyDisc += 1;
    end;

    local procedure DeleteMixMatchLines(var TmpPeriodicDisIn: Record "LSC Periodic Discount" temporary; var TmpPerDiscLineIn: Record "LSC Periodic Discount Line" temporary)
    var
        MixMatchLineGroup: Record "LSC Mix & Match Line Groups";
        PerDiscLine: Record "LSC Periodic Discount Line";
    begin
        MixMatchLineGroup.Get(TmpPeriodicDisIn."No.", 'A');
        MixMatchLineGroup.Delete();

        PerDiscLine.SetRange("Offer No.", TmpPeriodicDisIn."No.");
        PerDiscLine.DeleteAll();

        TmpPeriodicDiscountLine.Reset();
        TmpPeriodicDiscountLine.ClearMarks();
        TmpPeriodicDiscountLine.SetRange("Offer No.", TmpPeriodicDisIn."No.");
        TmpPeriodicDiscountLine.DeleteAll();
    end;

    local procedure DisableExpiredDiscount()
    var
        SchedulerHdr: Record "LSC Scheduler Job Header";
    begin
        if not SchedulerHdr.Get('DSBL_PROMO') then begin
            SchedulerHdr.Init();
            SchedulerHdr."Job ID" := 'DSBL_PROMO';
            SchedulerHdr.Insert();
        end;
        if GuiAllowed then
            Window.Update(1, 'Disabling Expired Promo...');

        Codeunit.Run(Codeunit::"LSC DSBL Expired Periodic Disc", SchedulerHdr);
    end;

    local procedure SaveFile(FileName: Text[250])
    var
        _File: DotNet File;
        AddFileName: Text;
    begin
        AddFileName := Format(Today);
        AddFileName := DelChr(AddFileName, '=', '/');
        AddFileName := DelChr(AddFileName, '=', '/') + DelChr(Format(Time), '=', ':');
        AddFileName := DelChr(AddFileName, '=', ' ');
        _File.Copy(FileName, 'C:\ncr\NAV2016\Processed\' + AddFileName + '_lspromoall.TXT');
        Erase(FileName);
    end;

    local procedure DeletePromoBuffer()
    var

    begin
        if GuiAllowed then
            Window.Update(1, 'Deleteing Promo Buffer...');

        PromoBuffer.Reset();
        PromoBuffer.DeleteAll();
    end;

    var
        PromoBuffer: Record "Pos_Promotion Buffer_NT";
        RetailSetup: Record "LSC Retail Setup";
        TempCreatedUpdPeriodicDisc: Record "LSC Periodic Discount" temporary;
        TempDistributionList: Record "LSC Distribution List" temporary;
        TempGroupedPromoBuffer2_DataSet1: Record "Pos_Promotion Buffer_NT" temporary;
        TempGroupedPromoBuffer_DataSet1: Record "Pos_Promotion Buffer_NT" temporary;
        TempMixMatchCreated: Record "Aging Band Buffer" temporary;
        TempPromoBufferDistList_DataSet2: Record "LSC Distribution List" temporary;
        TempPromoBufferItems_DataSet4: Record "Pos_Promotion Buffer_NT" temporary;
        TempPromoBufferKey_DataSet3: Record "Pos_Promotion Buffer_NT" temporary;
        TempPromotionsToUpdate2: Record "Aging Band Buffer" temporary;
        TempValidationPeriod: Record "LSC Validation Period" temporary;
        TmpPeriodicDiscount: Record "LSC Periodic Discount" temporary;
        TmpPeriodicDiscountLine: Record "LSC Periodic Discount Line" temporary;
        Window: Dialog;
        iFile: File;
        iStream: InStream;
        GlobalEntryNo: Integer;
        HeadersDeleted: Integer;
        LinesDeleted: Integer;
        LinesToInsert: Integer;
        NothingToDo: Integer;
        ToModifyDisc: Integer;
        ToModifyPrice: Integer;
        iLine: Text[1024];
        ProcMsg: Label 'Lines for which promo exists %1\Lines to modify price %2\Lines to modify Discount %3\Lines Deleted %4\Headers Deleted %5\Lines to Create Promo %6';

}
