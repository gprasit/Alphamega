codeunit 60321 "Fix Periodic Discount Price_NT"
{
    trigger OnRun()
    begin

    end;

    LOCAL procedure UpdatePerDisc(ItemNo: Code[20])
    var
        PerDiscLine: Record "LSC Periodic Discount Line";
        PeriodicDiscount: Record "LSC Periodic Discount";
        SalesPrice: Record "Sales Price";
        ActionsMgt: Codeunit "LSC Actions Management";
        RetailPriceUtil: Codeunit "LSC Retail Price Utils";
        RecRef: RecordRef;
        PG: Code[10];
        OfferPrice: Decimal;
    begin
        PerDiscLine.RESET;
        PerDiscLine.SETCURRENTKEY(Type, "No.");
        PerDiscLine.SETRANGE(Type, PerDiscLine.Type::Item);
        PerDiscLine.SETRANGE("No.", ItemNo);
        PerDiscLine.SETFILTER("Deal Price/Disc. %", '>%1', 0);
        IF PerDiscLine.FINDSET THEN
            REPEAT
                IF PeriodicDiscount.GET(PerDiscLine."Offer No.") THEN
                    if PeriodicDiscount.Status = PeriodicDiscount.Status::Enabled then
                        IF PeriodicDiscount.Type = PeriodicDiscount.Type::"Disc. Offer" THEN BEGIN
                            IF PerDiscLine."Disc. Type" = PerDiscLine."Disc. Type"::"Deal Price" THEN
                                OfferPrice := PerDiscLine."Offer Price Including VAT"
                            ELSE
                                OfferPrice := PerDiscLine."Deal Price/Disc. %";
                            CLEAR(SalesPrice);
                            PG := PeriodicDiscount."Price Group";
                            IF PG = '' THEN
                                PG := 'AL';
                            RetailPriceUtil.GetItemPrice(PG, PerDiscLine."No.", PerDiscLine."Variant Code", TODAY,
                              PerDiscLine."Currency Code", SalesPrice, PerDiscLine."Unit of Measure");
                            PerDiscLine."Standard Price" := SalesPrice."Unit Price";
                            //PerDiscLine.CalcStdPriceWithVAT(); //BC22
                            CalcStdPriceWithVAT(PerDiscLine); //BC22
                            IF PerDiscLine."Disc. Type" = PerDiscLine."Disc. Type"::"Deal Price" THEN
                                PerDiscLine.VALIDATE("Offer Price Including VAT", OfferPrice)
                            ELSE
                                PerDiscLine.VALIDATE("Deal Price/Disc. %", OfferPrice);
                            PerDiscLine.MODIFY;
                            //BC Upgrade Start              
                            /*
                            PerDiscLine.CreateActions(1);
                            PeriodicDiscount.CreateActions(1);
                            */
                            // RecRef.GetTable(PeriodicDiscount);
                            // ActionsMgt.SetCalledByTableTrigger(false);
                            // ActionsMgt.CreateActionsByRecRef(RecRef, RecRef, 1);
                            // Clear(RecRef);
                            //Since Periodic Discount Line is modified system should create actions automatically
                            //BC Upgrade End
                        END;
            UNTIL PerDiscLine.NEXT = 0;

    end;
internal procedure CalcStdPriceWithVAT(var REC: Record "LSC Periodic Discount Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GetBaseTables(REC);

        FindVATPostingGroup(VATPostingSetup);
        REC."Standard Price Including VAT" := Round(REC."Standard Price" * (1 + VATPostingSetup."VAT %" / 100));
    end;

    internal procedure GetBaseTables(var REC: Record "LSC Periodic Discount Line")
    begin
        if PeriodicDiscount.Get(Rec."Offer No.") then;

        if not PriceGroup.Get(PeriodicDiscount."Price Group") then
            PriceGroup.Init;

        if not BackOfficeSetup.Get then
            exit;

        if not Store.Get(BackOfficeSetup."Local Store No.") then
            exit;

        if not POSFuncProfile.Get(Store."Functionality Profile") then
            exit;

        if REC.Type = REC.Type::Item then
            Item.Get(REC."No.")
        else
            item.Init();
    end;

    internal procedure FindVATPostingGroup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        if PeriodicDiscount."Price Group" = '' then begin
            if not VATPostingSetup.Get(Store."Store VAT Bus. Post. Gr.", Item."VAT Prod. Posting Group") then
                VATPostingSetup.Init;
        end else
            if not VATPostingSetup.Get(PriceGroup."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
                VATPostingSetup.Init;

        case VATPostingSetup."VAT Calculation Type" of
            VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                VATPostingSetup."VAT %" := 0;
            VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                begin
                    if LocalizationExt.IsNALocalizationEnabled then
                        VATPostingSetup."VAT %" := 0
                    else
                        Error(Text004 +
                          Text005, VATPostingSetup.FieldCaption("VAT Calculation Type"),
                          VATPostingSetup."VAT Calculation Type");
                end;                
        end;
    end;

    var        
        BackOfficeSetup: Record "LSC Retail Setup";
        GeneralBufferTemp: Record "eCom_General Buffer_NT" temporary;
        Item: Record Item; 
        PeriodicDiscount: Record "LSC Periodic Discount";
        POSFuncProfile: Record "LSC POS Func. Profile";
        PriceGroup: Record "Customer Price Group";
        Store: Record "LSC Store";
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        iFile: File;
        iStream: InStream;
        EveryDayLowPrice: Boolean;
        Bar: Code[13];
        Text004: Label 'Prices including VAT cannot be calculated when';
        Text005: Label '%1 is %2.';
        i: Integer;
}