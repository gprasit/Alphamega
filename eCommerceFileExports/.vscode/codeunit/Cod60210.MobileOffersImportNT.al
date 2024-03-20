codeunit 60210 "Mobile Offers Import_NT"
{
    TableNo = "LSC Scheduler Job Header";

    trigger OnRun()
    begin
        if Text = '' then
            exit;
        ImportMobileOfferFile(Text);
    end;

    procedure ImportMobileOfferFile(FileName: Text)
    var
        ItemRec: Record Item;
        MemberScheme: Record "LSC Member Scheme";
        iFile: File;
        iStream: InStream;
        TAB: Char;
        CreatedCouponCode: code[10];
        ItemCodeInFile: Code[20];
        CouponRefInFile: Code[10];
        OfferNoInFile: Code[20];
        VPID: Code[10];
        OfferEndDateInFile: Date;
        OfferStartDateInFile: Date;
        OfferPriceInFile: Decimal;
        CurrentLine: Text;
        DescInFile: Text[100];
        DotNetArray: DotNet Array;
        DotNetString1: DotNet String;
        DotNetString2: DotNet String;
        lencoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
    begin
        if not iFile.Open(FileName) then
            exit;
        TAB := 9;
        DotNetString2 := Format(TAB);
        iFile.CreateInStream(iStream);
        if GuiAllowed then
            Window.Open('Current Action #1###############\Promotion #2###############');
        LoadValidationPeriod();
        StreamReader := StreamReader.StreamReader(iStream, lencoding.GetEncoding('UTF-8'));//Greek iso-8859-7 //20220221        
        while not StreamReader.EndOfStream do begin
            CurrentLine := StreamReader.ReadLine();
            DotNetString1 := CurrentLine;
            Clear(ItemCodeInFile);
            Clear(DescInFile);
            Clear(VPID);
            Clear(CouponRefInFile);
            OfferPriceInFile := 0;
            if not DotNetString1.IsNullOrWhiteSpace(DotNetString1) then begin
                DotNetArray := DotNetString1.Split(DotNetString2.ToCharArray());
                ItemCodeInFile := DotNetArray.GetValue(1);
                DescInFile := CopyStr(DotNetArray.GetValue(2), 1, 100);
                OfferPriceInFile := DotNetArray.GetValue(3);
                OfferNoInFile := DotNetArray.GetValue(4);
                Evaluate(OfferStartDateInFile, DotNetArray.GetValue(5));
                Evaluate(OfferEndDateInFile, DotNetArray.GetValue(6));
                CouponRefInFile := DotNetArray.GetValue(7);
                MemberScheme.FindSet();
                repeat
                    VPID := GetValidationPeriod(OfferStartDateInFile, OfferEndDateInFile);
                    CreateStoreCoupons(MemberScheme, CouponRefInFile, VPID, CreatedCouponCode, DescInFile);
                    CreateDiscountOffer(MemberScheme, ItemCodeInFile, OfferNoInFile, OfferPriceInFile, VPID, CreatedCouponCode, DescInFile);
                    CreatePublishedOffer(MemberScheme, VPID, CreatedCouponCode, DescInFile);
                    EnableCreatedData();
                until MemberScheme.Next() = 0;
            end;
        end;
        iFile.Close();
        StreamReader.Close();
    end;

    local procedure CreateStoreCoupons(MemberScheme: Record "LSC Member Scheme"; CouponRefInFile: Code[10]; VPID: Code[10]; var CreatedCouponCode: code[10]; DescInFile: Text[100])
    var
        RetailSetup: Record "LSC Retail Setup";
        StoreCoupon: Record "LSC Coupon Header";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        BarcodeMask: Code[22];
        CouponIssuer: Code[13];
        CouponRefSeriesCode: Code[20];
    begin
        StoreCouponTemp.Reset();
        StoreCouponTemp.DeleteAll();

        CouponRefSeriesCode := 'COUPON-REFERENCE';
        BarcodeMask := '22RRRRRRRRRRM';
        CouponIssuer := '11';

        if not RetailSetup.Get() then
            Clear(RetailSetup);
        RetailSetup.TestField("Default Price Group");
        StoreCoupon.Init();
        StoreCoupon.Insert(true);        

        StoreCoupon.Validate(Type, StoreCoupon.Type::"Store Coupon");
        StoreCoupon.VALIDATE("No. of Items to Trigger",0);        
        StoreCoupon.Validate("Coupon Issuer", CouponIssuer);
        StoreCoupon.Validate("Price Group", RetailSetup."Default Price Group");
        StoreCoupon.Validate("Calculation Type", StoreCoupon."Calculation Type"::"Triggers Offer");
        StoreCoupon.Validate("Discount Type", StoreCoupon."Discount Type"::"Discount Amount");
        //NoSeriesMgt.InitSeries(CouponRefSeriesCode, CouponRefSeriesCode, 0D, StoreCoupon."Coupon Reference No.", CouponRefSeriesCode);
        StoreCoupon.Validate("Coupon Reference No.", CouponRefInFile);
        StoreCoupon.Validate("Member Type", StoreCoupon."Member Type"::Scheme);
        StoreCoupon.Validate("Member Value", MemberScheme.Code);
        StoreCoupon.Validate("Validation Period ID", VPID);
        StoreCoupon.Validate("Barcode Mask", BarcodeMask);
        StoreCoupon.Description := CopyStr(DescInFile, 1, StrLen(StoreCoupon.Description));
        StoreCoupon.Modify(true);
        CreatedCouponCode := StoreCoupon.Code;

        StoreCouponTemp.Init();
        StoreCouponTemp := StoreCoupon;
        StoreCouponTemp.Insert();
    end;

    local procedure CreateDiscountOffer(MemberScheme: Record "LSC Member Scheme"; ItemCode: Code[20]; OfferNo: Code[20]; OfferPrice: Decimal; VPID: Code[10]; CreatedCouponCode: code[10]; DescInFile: Text[100])
    var
        Item: Record Item;
        PerDiscLine: Record "LSC Periodic Discount Line";
        PeriodicDisc: Record "LSC Periodic Discount";
        DistributionList: Record "LSC Distribution List";
        LineNo: Integer;
    begin
        PeriodicDiscTemp.Reset();
        PeriodicDiscTemp.DeleteAll();
        Item.Get(ItemCode);
        PeriodicDisc.Init();
        PeriodicDisc.Validate(Type, PeriodicDisc.Type::"Disc. Offer");
        PeriodicDisc.Validate("Offer Type", PeriodicDisc."Offer Type"::"Disc. Offer");
        PeriodicDisc."Discount Type" := PeriodicDisc."Discount Type"::"Deal Price";
        PeriodicDisc."No." := OfferNo;
        PeriodicDisc.Insert(true);

        PeriodicDisc.Description := CopyStr(DescInFile, 1, StrLen(PeriodicDisc.Description));
        PeriodicDisc.Validate("Discount Type", PeriodicDisc."Discount Type"::"Deal Price");
        PeriodicDisc.Validate("Member Type", PeriodicDisc."Member Type"::Club);
        PeriodicDisc.Validate("Member Value", MemberScheme."Club Code");
        PeriodicDisc.Validate("Coupon Code", CreatedCouponCode);
        PeriodicDisc.Validate("Coupon Qty Needed", 1);
        PeriodicDisc.Validate("Block Infocode Discount", true);
        PeriodicDisc.Validate("Validation Period ID", VPID);
        PeriodicDisc.Modify(true);

        PeriodicDiscTemp.Init();
        PeriodicDiscTemp := PeriodicDisc;
        PeriodicDiscTemp.Insert();

        PerDiscLine.SetRange("Offer No.", PeriodicDisc."No.");
        if PerDiscLine.FindLast() then
            LineNo := PerDiscLine."Line No." + 10000
        else
            LineNo := 10000;
        Clear(PerDiscLine);
        PerDiscLine.Init();
        PerDiscLine.Validate("Offer No.", PeriodicDisc."No.");
        PerDiscLine."Line No." := LineNo;
        PerDiscLine.Insert(true);
        PerDiscLine.Validate(Type, PerDiscLine.Type::Item);
        PerDiscLine.Validate("No.", ItemCode);
        PerDiscLine.Validate("Disc. Type", PerDiscLine."Disc. Type"::"Deal Price");
        PerDiscLine.Validate("Offer Price Including VAT", OfferPrice);
        PerDiscLine.Modify(true);

        DistributionList.INIT;
        DistributionList."Table ID" := DATABASE::"LSC Periodic Discount";
        DistributionList.Value := OfferNo;
        DistributionList.VALIDATE("Group Code", 'ALL');
        DistributionList.VALIDATE("Subgroup Code", 'ALL');
        DistributionList.VALIDATE("Store Group", 'ALL');
        DistributionList.INSERT(TRUE);

    end;

    local procedure CreatePublishedOffer(MemberScheme: Record "LSC Member Scheme"; VPID: Code[10]; CreatedCouponCode: code[10]; DescInFile: Text[100])
    var
        PubOffer: Record "LSC Published Offer";
    begin
        PubOfferTemp.Reset();
        PubOfferTemp.DeleteAll();
        PubOffer.Init();
        PubOffer.Description := CopyStr(DescInFile, 1, StrLen(PubOffer.Description));
        PubOffer.Insert(true);
        PubOffer.Validate("Validation Period ID", VPID);
        PubOffer.Validate("Discount Type", PubOffer."Discount Type"::Coupon);
        PubOffer.Validate("Discount No.", CreatedCouponCode);
        PubOffer.Validate("Offer Category", PubOffer."Offer Category"::"Points and Coupons");
        PubOffer."Primary Text" := PubOffer.Description;
        PubOffer.Validate("Member Type", PubOffer."Member Type"::Scheme);
        PubOffer.Validate("Member Value", MemberScheme.Code);
        PubOffer.Modify(true);

        PubOfferTemp.Init();
        PubOfferTemp := PubOffer;
        PubOfferTemp.Insert();
    end;

    local procedure EnableCreatedData()
    var
        StoreCpns: Record "LSC Coupon Header";
        PeriodicDisc: Record "LSC Periodic Discount";
        PublishedOffer: Record "LSC Published Offer";
    begin
        if StoreCouponTemp.FindSet() then
            repeat
                StoreCpns.Get(StoreCouponTemp.Code);
                StoreCpns.Validate(Status, StoreCpns.Status::Enabled);
                StoreCpns.Modify(true);
            until StoreCouponTemp.Next() = 0;

        if PeriodicDiscTemp.FindSet() then
            repeat
                PeriodicDisc.Get(PeriodicDiscTemp."No.");
                PeriodicDisc.Validate(Status, PeriodicDisc.Status::Enabled);
                PeriodicDisc.Modify(true);
            until PeriodicDiscTemp.Next() = 0;

        if PubOfferTemp.FindSet() then
            repeat
                PublishedOffer.Get(PubOfferTemp."No.");
                PublishedOffer.Validate(Status, PeriodicDisc.Status::Enabled);
                PublishedOffer.Modify(true);
            until PubOfferTemp.Next() = 0;
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
        //NewValidationPeriod.Description := '';//TO BE REMOVED
        NewValidationPeriod.Insert(true);
        TempValidationPeriod.Reset();
        TempValidationPeriod.Init();
        TempValidationPeriod := NewValidationPeriod;
        TempValidationPeriod.Insert();
        exit(NewValidationPeriod.ID);
    end;

    var
        PeriodicDiscTemp: Record "LSC Periodic Discount" temporary;
        PubOfferTemp: Record "LSC Published Offer" temporary;
        StoreCouponTemp: Record "LSC Coupon Header" temporary;
        TempValidationPeriod: Record "LSC Validation Period" temporary;
        Window: Dialog;

}

