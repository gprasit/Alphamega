codeunit 60116 "MA_Offer Utils_NT"
{
#if __IS_SAAS__
    Access = Internal;
#endif
    trigger OnRun()
    begin
    end;

    procedure GetMemberDirMarkInfo(MemberCardNo_p: Text; ItemNo_p: Code[20]; StoreNo_p: Code[10]; var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary; var MemberCouponBuffer_p: Record "LSC Member Coupon Buffer" temporary; var MemberNotificationTemp_p: Record "LSC Member Notification" temporary; var MemberNotificationImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferLineBufferTemp_p: Record "LSC Published Offer Line Buff" temporary)
    begin
        GetPublishedOffers(MemberCardNo_p, ItemNo_p, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p, PublishedOfferLineBufferTemp_p);
        GetPersonalCoupons(MemberCardNo_p, ItemNo_p, StoreNo_p, MemberCouponBuffer_p);
        GetMemberNotifications(MemberCardNo_p, MemberNotificationTemp_p, MemberNotificationImagesTemp_p);
    end;

    procedure GetMemberNotifications(MemberCardNo_p: Text; var MemberNotificationTemp_p: Record "LSC Member Notification" temporary; var MemberNotificationImagesTemp_p: Record "LSC Retail Image Link" temporary)
    var
        MembershipCard: Record "LSC Membership Card";
        MemberContact: Record "LSC Member Contact";
    begin
        if MemberCardNo_p = '' then
            exit;
        if not MembershipCard.Get(MemberCardNo_p) then
            exit;
        if MemberContact.Get(MembershipCard."Account No.", MembershipCard."Contact No.") then begin
            GetNotificationsForMemberContact(MemberContact, MemberNotificationTemp_p);
            if MemberNotificationTemp_p.FindSet then
                repeat
                    AddRetailImagesToBuffer(MemberNotificationTemp_p.TableCaption, MemberNotificationTemp_p."No.", MemberNotificationImagesTemp_p);
                until MemberNotificationTemp_p.Next = 0;
        end;
    end;

    procedure GetPublishedOffersForMemberAccount(MemberAccount_p: Record "LSC Member Account"; var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferLineBufferTemp_p: Record "LSC Published Offer Line Buff" temporary)
    var
        MembershipCard: Record "LSC Membership Card";
    begin
        ClearPublishedOfferBuffers(PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        //Add non member offers to buffer.
        Clear(MembershipCard);
        AddPublishedOffersToBuffers(0, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        MembershipCard."Club Code" := MemberAccount_p."Club Code";
        MembershipCard."Scheme Code" := MemberAccount_p."Scheme Code";
        MembershipCard."Account No." := MemberAccount_p."No.";
        //Add Scheme offers to buffer
        AddPublishedOffersToBuffers(0, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        //Add Club offers to buffer
        AddPublishedOffersToBuffers(1, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
    end;

    procedure GetPublishedOffersForMemberContact(MemberContact_p: Record "LSC Member Contact"; var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferLineBufferTemp_p: Record "LSC Published Offer Line Buff" temporary)
    var
        MembershipCard: Record "LSC Membership Card";
    begin
        ClearPublishedOfferBuffers(PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        //Add non member offers to buffer
        Clear(MembershipCard);
        AddPublishedOffersToBuffers(0, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        MembershipCard."Club Code" := MemberContact_p."Club Code";
        MembershipCard."Scheme Code" := MemberContact_p."Scheme Code";
        MembershipCard."Account No." := MemberContact_p."Account No.";
        MembershipCard."Contact No." := MemberContact_p."Contact No.";
        //Add Scheme offers to buffer
        AddPublishedOffersToBuffers(0, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        //Add Club offers to buffer
        AddPublishedOffersToBuffers(1, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
    end;

    procedure GetNotificationsForMemberAccount(MemberAccount_p: Record "LSC Member Account"; var MemberNotificationTemp_p: Record "LSC Member Notification" temporary)
    begin
        MemberNotificationTemp_p.Reset;
        MemberNotificationTemp_p.DeleteAll;
        AddNotificationsToBuffer(MemberNotificationTemp_p.Type::Club, MemberAccount_p."Club Code", '', MemberNotificationTemp_p);
        AddNotificationsToBuffer(MemberNotificationTemp_p.Type::Scheme, MemberAccount_p."Scheme Code", '', MemberNotificationTemp_p);
        AddNotificationsToBuffer(MemberNotificationTemp_p.Type::Account, MemberAccount_p."No.", '', MemberNotificationTemp_p);
    end;

    procedure GetNotificationsForMemberContact(MemberContact_p: Record "LSC Member Contact"; var MemberNotificationTemp_p: Record "LSC Member Notification" temporary)
    begin
        MemberNotificationTemp_p.Reset;
        MemberNotificationTemp_p.DeleteAll;
        AddNotificationsToBuffer(MemberNotificationTemp_p.Type::Club, MemberContact_p."Club Code", '', MemberNotificationTemp_p);
        AddNotificationsToBuffer(MemberNotificationTemp_p.Type::Scheme, MemberContact_p."Scheme Code", '', MemberNotificationTemp_p);
        AddNotificationsToBuffer(MemberNotificationTemp_p.Type::Account, MemberContact_p."Account No.", '', MemberNotificationTemp_p);
        AddNotificationsToBuffer(MemberNotificationTemp_p.Type::Contact, MemberContact_p."Account No.", MemberContact_p."Contact No.", MemberNotificationTemp_p);
    end;

    local procedure AddNotificationsToBuffer(Type_p: Integer; Code_p: Code[20]; ContactNo_p: Code[20]; var MemberNotificationTemp_p: Record "LSC Member Notification" temporary)
    var
        MemberNotification: Record "LSC Member Notification";
        AttributeOk: Boolean;
    begin
        MemberNotification.SetRange(Type, Type_p);
        MemberNotification.SetRange(Code, Code_p);
        if Type_p = 2 then //Contact
            MemberNotification.SetRange("Contact No.", ContactNo_p);
        MemberNotification.SetFilter("Valid To Date", '>%1|%2', Today, 0D);
        MemberNotification.SetRange(Status, MemberNotification.Status::Enabled);
        if MemberNotification.FindSet then
            repeat
                AttributeOk := true;
                if MemberNotification."Member Attribute Value" <> '' then //Account or Contact with Attribute
                    AttributeOk := MemberWithAttribute(Code_p, ContactNo_p, MemberNotification."Member Attribute", MemberNotification."Member Attribute Value");
                if AttributeOk then begin
                    MemberNotificationTemp_p.Init;
                    MemberNotificationTemp_p := MemberNotification;
                    MemberNotificationTemp_p.Insert;
                end;
            until MemberNotification.Next = 0;
    end;

    local procedure MemberWithAttribute(AccountNo_p: Code[20]; ContactNo_p: Code[20]; AttributeCode_p: Code[10]; AttributeValue_p: Code[10]): Boolean
    var
        MemberAccount: Record "LSC Member Account";
        MemberAttributeValue: Record "LSC Member Attribute Value";
    begin
        if not MemberAccount.Get(AccountNo_p) then
            exit(false);

        MemberAttributeValue.SetRange("Club Code", MemberAccount."No.");
        MemberAttributeValue.SetRange("Account No.", AccountNo_p);
        if ContactNo_p <> '' then
            MemberAttributeValue.SetRange("Contact No.", ContactNo_p);
        MemberAttributeValue.SetRange("Attribute Code", AttributeCode_p);
        MemberAttributeValue.SetRange("Attribute Value", AttributeValue_p);
        exit(MemberAttributeValue.IsEmpty);
    end;

    procedure ItemsInPublishedOffer(PublishedOffer: Record "LSC Published Offer"; NoOfItemsToDisplay: Integer; var OfferItemBuffer: Record "LSC Offer Item Buffer" temporary)
    var
        PeriodicDiscount: Record "LSC Periodic Discount";
        Offer: Record "LSC Offer";
        CouponHeader: Record "LSC Coupon Header";
        TotalItems: Integer;
        i: Integer;
    begin
        OfferItemBuffer.DeleteAll;

        case PublishedOffer."Discount Type" of
            PublishedOffer."Discount Type"::Promotion,
          PublishedOffer."Discount Type"::Deal:
                if Offer.Get(PublishedOffer."Discount No.") then
                    ItemsInOffer(Offer, OfferItemBuffer);
            PublishedOffer."Discount Type"::Multibuy,
          PublishedOffer."Discount Type"::"Mix&Match",
          PublishedOffer."Discount Type"::"Disc. Offer",
          PublishedOffer."Discount Type"::"Total Discount",
          PublishedOffer."Discount Type"::"Tender Type",
          PublishedOffer."Discount Type"::"Item Point",
          PublishedOffer."Discount Type"::"Line Discount":
                if PeriodicDiscount.Get(PublishedOffer."Discount No.") then
                    ItemsInPeriodicDiscount(PeriodicDiscount, OfferItemBuffer);
            PublishedOffer."Discount Type"::Coupon:
                if CouponHeader.Get(PublishedOffer."Discount No.") then
                    ItemsInCouponDiscount(CouponHeader, OfferItemBuffer);
        end;

        TotalItems := OfferItemBuffer.Count;
        OfferItemBuffer.ModifyAll("Total No. Of Entries", TotalItems);
        if (TotalItems > NoOfItemsToDisplay) and (NoOfItemsToDisplay > 0) then begin
            OfferItemBuffer.FindSet;
            i := TotalItems - NoOfItemsToDisplay;
            repeat
                OfferItemBuffer.FindLast;
                OfferItemBuffer.Delete;
                i := i - 1;
            until i = 0;
        end;
    end;

    local procedure AddPublishedOfferToBuffer(var PublishedOffers_p: Query "MA_Published Offers_NT"; var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary)
    var
        PublishedOfferDetailLine: Record "LSC Published Offer Detail Ln";
        CouponHeader: Record "LSC Coupon Header";
    begin
        PublishedOfferTemp_p.Init;
        PublishedOfferTemp_p."No." := PublishedOffers_p.No;
        PublishedOfferTemp_p."Discount Type" := PublishedOffers_p.Discount_Type;
        PublishedOfferTemp_p."Discount No." := PublishedOffers_p.Discount_No;
        PublishedOfferTemp_p.Description := PublishedOffers_p.Description;
        PublishedOfferTemp_p."Offer Category" := PublishedOffers_p.Offer_Category;
        PublishedOfferTemp_p."Primary Text" := PublishedOffers_p.Primary_Text;
        PublishedOfferTemp_p."Secondary Text" := PublishedOffers_p.Secondary_Text;
        PublishedOfferTemp_p."Ending Date" := PublishedOffers_p.Ending_Date;
        PublishedOfferTemp_p."Display Order" := PublishedOffers_p.Display_Order;

        if PublishedOffers_p.Discount_Type = PublishedOffers_p.Discount_Type::Coupon then
            if CouponHeader.Get(PublishedOffers_p.Discount_No) then
                PublishedOfferTemp_p."Point Value" := CouponHeader."Point Value";

        PublishedOfferTemp_p.Insert;
        AddRetailImagesToBuffer(PublishedOfferTemp_p.TableName, PublishedOfferTemp_p."No.", PublishedOfferImagesTemp_p);
        PublishedOfferDetailLine.SetRange("Offer No.", PublishedOfferTemp_p."No.");
        if PublishedOfferDetailLine.FindSet then
            repeat
                PublishedOfferDetailLineTemp_p.Init;
                PublishedOfferDetailLineTemp_p."Offer No." := PublishedOfferDetailLine."Offer No.";
                PublishedOfferDetailLineTemp_p."Line No." := PublishedOfferDetailLine."Line No.";
                PublishedOfferDetailLineTemp_p.Description := PublishedOfferDetailLine.Description;
                PublishedOfferDetailLineTemp_p.Insert;
                AddRetailImagesToBuffer(PublishedOfferDetailLineTemp_p.TableName, PublishedOfferDetailLineTemp_p."Offer No." + ',' + Format(PublishedOfferDetailLineTemp_p."Line No."), PublishedOfferDetailLineImagesTemp_p);
            until PublishedOfferDetailLine.Next = 0;
    end;

    local procedure AddPublishedOffersToBuffers(MemberType_p: Integer; MembershipCard_p: Record "LSC Membership Card"; var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary)
    var
        MemberAttributeManagement: Codeunit "LSC Member Attribute Mgmt";
        //PublishedOffers: Query "LSC Published Offers";//BC Upgrade
        PublishedOffers: Query "MA_Published Offers_NT";//BC Upgrade
        MemberValue: Code[10];
        AddOffer: Boolean;
    begin
        Clear(PublishedOffers);
        PublishedOffers.SetFilter(Valid_To_Date, '>=%1|%2', Today, 0D);
        PublishedOffers.SetRange(Status, PublishedOffers.Status::Enabled);

        if MemberType_p = 0 then
            MemberValue := MembershipCard_p."Scheme Code"
        else
            MemberValue := MembershipCard_p."Club Code";
        
        if MemberValue <> '' then
            PublishedOffers.SetRange(Member_Type, MemberType_p);

        PublishedOffers.SetRange(Member_Value, MemberValue);
        if PublishedOffers.Open then
            while PublishedOffers.Read do begin
                AddOffer := true;
                if (PublishedOffers.Member_Attribute <> '') and (MembershipCard_p."Account No." <> '') then begin
                    MemberAttributeManagement.SetMemberCardValues(MembershipCard_p."Account No.", MembershipCard_p."Contact No.");
                    if PublishedOffers.Member_Attribute_Value2 <> DelChr(MemberAttributeManagement.AttributeValue(PublishedOffers.Member_Attribute, ''), '<>', ' ') then
                        AddOffer := false;
                end;
                //BC Upgrade Start
                //When offer passed above checks then check for CLUB/Scheme validity
                //Not required 24.10.23 as single offer and coupon will be defined without MemberType & Member Value 
                // if AddOffer then
                //     AddOffer := CheckPublishedOfferValidity(PublishedOffers.No, MemberType_p, MemberValue);
                //BC Upgrade End

                if AddOffer then
                    AddPublishedOfferToBuffer(PublishedOffers, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
            end;
        PublishedOffers.Close;
    end;

    local procedure AddRemoveBuffer(var Item: Record Item; OriginTableNo: Integer; OriginNo: Code[20]; Remove: Boolean; var OfferItemBuffer: Record "LSC Offer Item Buffer" temporary)
    begin
        if not Item.FindSet then
            exit;

        repeat
            if Remove then begin
                if OfferItemBuffer.Get(Item."No.") then
                    OfferItemBuffer.Delete;
            end else
                if ItemAvailable(Item) then begin
                    OfferItemBuffer."Item No." := Item."No.";
                    OfferItemBuffer."Item Description" := Item.Description;
                    OfferItemBuffer."Original Table ID" := OriginTableNo;
                    OfferItemBuffer."Original Entry No." := OriginNo;
                    OfferItemBuffer."Image ID" := GetItemImageID(Item);
                    OfferItemBuffer.ItemCategory := Item."Item Category Code";
                    OfferItemBuffer.ProductGroup := Item."LSC Retail Product Code";
                    if not OfferItemBuffer.Insert then;
                end;
        until Item.Next = 0;
    end;

    local procedure AddRetailImagesToBuffer(TableName_p: Text; KeyValue_p: Text; var ImageBufferTemp_p: Record "LSC Retail Image Link" temporary)
    var
        RetailImageLink: Record "LSC Retail Image Link";
    begin
        RetailImageLink.SetCurrentKey(TableName, KeyValue, "Display Order");
        RetailImageLink.SetRange(TableName, TableName_p);
        RetailImageLink.SetRange(KeyValue, KeyValue_p);
        if RetailImageLink.FindSet then
            repeat
                ImageBufferTemp_p.Init;
                ImageBufferTemp_p := RetailImageLink;
                ImageBufferTemp_p.Insert;
            until RetailImageLink.Next = 0;
    end;

    local procedure AddPublishedOfferLinesToBuffer(var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferLineBufferTemp_p: Record "LSC Published Offer Line Buff" temporary)
    var
        OfferLine: Record "LSC Offer Line";
        PeriodicDiscountLine: Record "LSC Periodic Discount Line";
        CouponLine: Record "LSC Coupon Line";
    begin
        if PublishedOfferTemp_p.FindSet then
            repeat
                case PublishedOfferTemp_p."Discount Type" of
                    PublishedOfferTemp_p."Discount Type"::Promotion,
                    PublishedOfferTemp_p."Discount Type"::Deal:
                        begin
                            OfferLine.SetRange("Offer No.", PublishedOfferTemp_p."Discount No.");
                            if OfferLine.FindSet then
                                repeat
                                    PublishedOfferLineBufferTemp_p.Init;
                                    PublishedOfferLineBufferTemp_p."Published Offer No." := PublishedOfferTemp_p."No.";
                                    PublishedOfferLineBufferTemp_p."Discount Type" := PublishedOfferTemp_p."Discount Type";
                                    PublishedOfferLineBufferTemp_p."Discount No." := PublishedOfferTemp_p."Discount No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line No." := OfferLine."Line No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line Type" := OfferLine.Type.AsInteger();
                                    PublishedOfferLineBufferTemp_p."Discount Line Id" := OfferLine."No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line Description" := OfferLine.Description;
                                    PublishedOfferLineBufferTemp_p."Variant Code" := OfferLine."Variant Code";
                                    PublishedOfferLineBufferTemp_p."Variant Type" := OfferLine."Variant Type";
                                    PublishedOfferLineBufferTemp_p.Exclude := OfferLine.Exclude;
                                    PublishedOfferLineBufferTemp_p."Unit of Measure" := OfferLine."Unit of Measure";
                                    PublishedOfferLineBufferTemp_p."Table No." := Database::"LSC Offer Line";
                                    PublishedOfferLineBufferTemp_p.Insert;
                                until OfferLine.Next = 0;
                        end;
                    PublishedOfferTemp_p."Discount Type"::Multibuy,
                    PublishedOfferTemp_p."Discount Type"::"Mix&Match",
                    PublishedOfferTemp_p."Discount Type"::"Disc. Offer",
                    PublishedOfferTemp_p."Discount Type"::"Total Discount",
                    PublishedOfferTemp_p."Discount Type"::"Tender Type",
                    PublishedOfferTemp_p."Discount Type"::"Item Point",
                    PublishedOfferTemp_p."Discount Type"::"Line Discount":
                        begin
                            PeriodicDiscountLine.SetRange("Offer No.", PublishedOfferTemp_p."Discount No.");
                            if PeriodicDiscountLine.FindSet then
                                repeat
                                    PublishedOfferLineBufferTemp_p.Init;
                                    PublishedOfferLineBufferTemp_p."Published Offer No." := PublishedOfferTemp_p."No.";
                                    PublishedOfferLineBufferTemp_p."Discount Type" := PublishedOfferTemp_p."Discount Type";
                                    PublishedOfferLineBufferTemp_p."Discount No." := PublishedOfferTemp_p."Discount No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line No." := PeriodicDiscountLine."Line No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line Type" := PeriodicDiscountLine.Type.AsInteger();
                                    PublishedOfferLineBufferTemp_p."Discount Line Id" := PeriodicDiscountLine."No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line Description" := PeriodicDiscountLine.Description;
                                    PublishedOfferLineBufferTemp_p."Variant Code" := PeriodicDiscountLine."Variant Code";
                                    PublishedOfferLineBufferTemp_p."Variant Type" := PeriodicDiscountLine."Variant Type";
                                    PublishedOfferLineBufferTemp_p.Exclude := PeriodicDiscountLine.Exclude;
                                    PublishedOfferLineBufferTemp_p."Unit of Measure" := PeriodicDiscountLine."Unit of Measure";
                                    PublishedOfferLineBufferTemp_p."Table No." := Database::"LSC Periodic Discount Line";
                                    PublishedOfferLineBufferTemp_p.Insert;
                                until PeriodicDiscountLine.Next = 0;
                        end;
                    PublishedOfferTemp_p."Discount Type"::Coupon:
                        begin
                            CouponLine.SetRange("Coupon Code", PublishedOfferTemp_p."Discount No.");
                            if CouponLine.FindSet then
                                repeat
                                    PublishedOfferLineBufferTemp_p.Init;
                                    PublishedOfferLineBufferTemp_p."Published Offer No." := PublishedOfferTemp_p."No.";
                                    PublishedOfferLineBufferTemp_p."Discount Type" := PublishedOfferTemp_p."Discount Type";
                                    PublishedOfferLineBufferTemp_p."Discount No." := PublishedOfferTemp_p."Discount No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line No." := CouponLine."Line No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line Type" := CouponLine.Type.AsInteger();
                                    PublishedOfferLineBufferTemp_p."Discount Line Id" := CouponLine."No.";
                                    PublishedOfferLineBufferTemp_p."Discount Line Description" := CouponLine.Description;
                                    PublishedOfferLineBufferTemp_p."Variant Code" := CouponLine."Variant or Dim 1 Code";
                                    PublishedOfferLineBufferTemp_p."Variant Type" := CouponLine."Variant Type";
                                    PublishedOfferLineBufferTemp_p.Exclude := CouponLine.Exclude;
                                    PublishedOfferLineBufferTemp_p."Unit of Measure" := CouponLine."Unit of Measure";
                                    PublishedOfferLineBufferTemp_p."Table No." := Database::"LSC Coupon Line";
                                    PublishedOfferLineBufferTemp_p.Insert;
                                until CouponLine.Next = 0;
                        end;
                end;
            until PublishedOfferTemp_p.Next = 0;
    end;

    local procedure ClearPublishedOfferBuffers(var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary)
    begin
        PublishedOfferTemp_p.Reset;
        PublishedOfferTemp_p.DeleteAll;
        PublishedOfferImagesTemp_p.Reset;
        PublishedOfferImagesTemp_p.DeleteAll;
        PublishedOfferDetailLineTemp_p.Reset;
        PublishedOfferDetailLineTemp_p.DeleteAll;
        PublishedOfferDetailLineImagesTemp_p.Reset;
        PublishedOfferDetailLineImagesTemp_p.DeleteAll;
    end;

    local procedure GetItemImageID(Item: Record Item): Code[20]
    var
        RetailImageLink: Record "LSC Retail Image Link";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        RecRef.FilterGroup(2);
        RetailImageLink.SetRange("Record Id", Format(RecRef.RecordId));
        RecRef.FilterGroup(0);
        if RetailImageLink.FindFirst then
            exit(RetailImageLink."Image Id")
        else
            exit('');
    end;

    local procedure GetPersonalCoupons(MemberCardNo_p: Text; ItemNo_p: Code[20]; StoreNo_p: Code[10]; var MemberCouponBuffer_p: Record "LSC Member Coupon Buffer" temporary)
    var
        MembershipCard: Record "LSC Membership Card";
        CouponManagement: Codeunit "LSC Coupon Management";
    begin
        if MemberCardNo_p = '' then
            exit;
        if not MembershipCard.Get(MemberCardNo_p) then
            exit;
        CouponManagement.GetMemberCouponList(MemberCouponBuffer_p, MembershipCard."Account No.", StoreNo_p, StoreNo_p <> '');
        if ItemNo_p <> '' then
            RemoveMemberCouponsNotWithItem(ItemNo_p, MemberCouponBuffer_p);
    end;

    local procedure GetPublishedOffers(MemberCardNo_p: Text; ItemNo_p: Code[20]; var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferLineBufferTemp_p: Record "LSC Published Offer Line Buff" temporary)
    var
        MembershipCard: Record "LSC Membership Card";
    begin
        ClearPublishedOfferBuffers(PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        //Add non member offers to buffer
        Clear(MembershipCard);
        AddPublishedOffersToBuffers(0, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        if MemberCardNo_p <> '' then
            if MembershipCard.Get(MemberCardNo_p) then begin
                //Add Scheme offers to buffer
                AddPublishedOffersToBuffers(0, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
                //Add Club offers to buffer
                AddPublishedOffersToBuffers(1, MembershipCard, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
            end;
        if ItemNo_p <> '' then
            RemovePublishedOffersNotWithItem(ItemNo_p, PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
        AddPublishedOfferLinesToBuffer(PublishedOfferTemp_p, PublishedOfferLineBufferTemp_p);
    end;

    local procedure ItemAvailable(Item: Record Item): Boolean
    var
        ItemStatusLink: Record "LSC Item Status Link";
    begin
        ItemStatusLink.SetRange("Item No.", Item."No.");
        if ItemStatusLink.FindFirst then
            Item.Blocked := ItemStatusLink."Block Sale in Sales Order" or ItemStatusLink."Block Sale on POS";

        exit(not Item.Blocked);
    end;

    local procedure ItemsFromSpecialGroup(SpecGrpCode: Code[20]; RemoveItem: Boolean; OriginTableNo: Integer; OriginNo: Code[20]; var OfferItemBuffer: Record "LSC Offer Item Buffer" temporary)
    var
        Item: Record Item;
        ItemSpecialGroupLink: Record "LSC Item/Special Group Link";
    begin
        ItemSpecialGroupLink.Reset;
        ItemSpecialGroupLink.SetRange("Special Group Code", SpecGrpCode);
        if ItemSpecialGroupLink.FindFirst then
            repeat
                if Item.Get(ItemSpecialGroupLink."Item No.") then
                    AddRemoveBuffer(Item, OriginTableNo, OriginNo, RemoveItem, OfferItemBuffer);
            until ItemSpecialGroupLink.Next = 0;
    end;

    local procedure ItemsInCouponDiscount(CouponHeader: Record "LSC Coupon Header"; var OfferItemBuffer: Record "LSC Offer Item Buffer" temporary)
    var
        CouponLine: Record "LSC Coupon Line";
        CouponLine2: Record "LSC Coupon Line";
        Item: Record Item;
        TableNo: Integer;
        AllItemsIncluded: Boolean;
        RemoveItem: Boolean;
    begin
        CouponLine.SetRange("Coupon Code", CouponHeader.Code);
        if not CouponLine.FindFirst then
            exit;

        CouponLine2.SetCurrentKey("Coupon Code", "List Type", Type);
        CouponLine2.SetRange("Coupon Code", CouponHeader.Code);
        CouponLine2.SetRange(Type, CouponLine2.Type::All);
        AllItemsIncluded := not CouponLine2.IsEmpty;
        TableNo := Database::"LSC Coupon Header";

        if CouponLine.FindSet then
            for RemoveItem := false to true do begin
                CouponLine.SetRange(Exclude, RemoveItem);
                if CouponLine.FindFirst then
                    repeat
                        case CouponLine.Type of
                            CouponLine.Type::All:
                                begin
                                    Item.Reset;
                                    if Item.FindSet then
                                        repeat
                                            AddRemoveBuffer(Item, TableNo, CouponHeader.Code, RemoveItem, OfferItemBuffer);
                                        until Item.Next = 0;
                                end;

                            CouponLine.Type::Item:
                                if not AllItemsIncluded or RemoveItem then begin
                                    SetItemTableFilter(Item, 0, CouponLine."No.");
                                    AddRemoveBuffer(Item, TableNo, CouponHeader.Code, RemoveItem, OfferItemBuffer);
                                end;

                            CouponLine.Type::"Item Category":
                                if not AllItemsIncluded or RemoveItem then begin
                                    SetItemTableFilter(Item, 1, CouponLine."No.");
                                    AddRemoveBuffer(Item, TableNo, CouponHeader.Code, RemoveItem, OfferItemBuffer);
                                end;

                            CouponLine.Type::"Product Group":
                                if not AllItemsIncluded or RemoveItem then begin
                                    SetItemTableFilter(Item, 2, CouponLine."No.");
                                    AddRemoveBuffer(Item, TableNo, CouponHeader.Code, RemoveItem, OfferItemBuffer);
                                end;

                            CouponLine.Type::"Special Group":
                                if not AllItemsIncluded or RemoveItem then
                                    ItemsFromSpecialGroup(CouponLine."No.", RemoveItem, TableNo, CouponHeader.Code, OfferItemBuffer);
                        end;
                    until CouponLine.Next = 0;
            end;
    end;

    local procedure ItemsInOffer(Offer: Record "LSC Offer"; var OfferItemBuffer: Record "LSC Offer Item Buffer" temporary)
    var
        OfferLine: Record "LSC Offer Line";
        OfferLine2: Record "LSC Offer Line";
        Item: Record Item;
        TableNo: Integer;
        AllItemsIncluded: Boolean;
        RemoveItem: Boolean;
    begin
        OfferLine.SetRange("Offer No.", Offer."No.");
        if not OfferLine.FindFirst then
            exit;

        TableNo := Database::"LSC Offer";

        OfferLine2.SetCurrentKey("Offer No.", Type, "No.", "Variant Code", "Unit of Measure", "Currency Code");
        OfferLine2.SetRange("Offer No.", Offer."No.");
        OfferLine2.SetRange(Type, OfferLine2.Type::All);
        AllItemsIncluded := not OfferLine2.IsEmpty;

        if OfferLine.FindSet then
            for RemoveItem := false to true do begin
                OfferLine.SetRange(Exclude, RemoveItem);
                if OfferLine.FindFirst then
                    repeat
                        case OfferLine.Type of
                            OfferLine.Type::All:
                                begin
                                    Item.Reset;
                                    if Item.FindSet then
                                        repeat
                                            AddRemoveBuffer(Item, TableNo, Offer."No.", RemoveItem, OfferItemBuffer);
                                        until Item.Next = 0;
                                end;

                            OfferLine.Type::Item:
                                if not AllItemsIncluded or RemoveItem then begin
                                    SetItemTableFilter(Item, 0, OfferLine."No.");
                                    AddRemoveBuffer(Item, TableNo, Offer."No.", RemoveItem, OfferItemBuffer);
                                end;

                            OfferLine.Type::"Item Category":
                                if not AllItemsIncluded or RemoveItem then begin
                                    SetItemTableFilter(Item, 1, OfferLine."No.");
                                    AddRemoveBuffer(Item, TableNo, Offer."No.", RemoveItem, OfferItemBuffer);
                                end;

                            OfferLine.Type::"Product Group":
                                if not AllItemsIncluded or RemoveItem then
                                    SetItemTableFilter(Item, 2, OfferLine."No.");

                            OfferLine.Type::"Special Group":
                                if not AllItemsIncluded or RemoveItem then
                                    ItemsFromSpecialGroup(OfferLine."No.", RemoveItem, TableNo, Offer."No.", OfferItemBuffer);
                        end;
                    until OfferLine.Next = 0;
            end;
    end;

    local procedure ItemsInPeriodicDiscount(PeriodicDiscount: Record "LSC Periodic Discount"; var OfferItemBuffer: Record "LSC Offer Item Buffer" temporary)
    var
        PeriodicDiscountLine: Record "LSC Periodic Discount Line";
        PeriodicDiscountLine2: Record "LSC Periodic Discount Line";
        Item: Record Item;
        TableNo: Integer;
        AllItemsIncluded: Boolean;
        RemoveItem: Boolean;
    begin
        PeriodicDiscountLine.SetRange("Offer No.", PeriodicDiscount."No.");
        if not PeriodicDiscountLine.FindSet then
            exit;

        PeriodicDiscountLine2.SetCurrentKey("Offer No.", Type, "No.", "Variant Code", "Unit of Measure", "Prod. Group Category");
        PeriodicDiscountLine2.SetRange("Offer No.", PeriodicDiscount."No.");
        PeriodicDiscountLine2.SetRange(Type, PeriodicDiscountLine2.Type::All);
        AllItemsIncluded := not PeriodicDiscountLine2.IsEmpty;
        TableNo := Database::"LSC Periodic Discount";

        if PeriodicDiscountLine.FindSet then
            for RemoveItem := false to true do begin
                PeriodicDiscountLine.SetRange(Exclude, RemoveItem);
                if PeriodicDiscountLine.FindFirst then
                    repeat
                        case PeriodicDiscountLine.Type of
                            PeriodicDiscountLine.Type::All:
                                begin
                                    Item.Reset;
                                    if Item.FindSet then
                                        repeat
                                            AddRemoveBuffer(Item, TableNo, PeriodicDiscount."No.", RemoveItem, OfferItemBuffer);
                                        until Item.Next = 0;
                                end;
                            PeriodicDiscountLine.Type::Item:
                                if not AllItemsIncluded or RemoveItem then begin
                                    SetItemTableFilter(Item, 0, PeriodicDiscountLine."No.");
                                    AddRemoveBuffer(Item, TableNo, PeriodicDiscount."No.", RemoveItem, OfferItemBuffer);
                                end;
                            PeriodicDiscountLine.Type::"Item Category":
                                if not AllItemsIncluded or RemoveItem then begin
                                    SetItemTableFilter(Item, 1, PeriodicDiscountLine."No.");
                                    AddRemoveBuffer(Item, TableNo, PeriodicDiscount."No.", RemoveItem, OfferItemBuffer);
                                end;
                            PeriodicDiscountLine.Type::"Product Group":
                                if not AllItemsIncluded or RemoveItem then begin
                                    SetItemTableFilter(Item, 2, PeriodicDiscountLine."No.");
                                    AddRemoveBuffer(Item, TableNo, PeriodicDiscount."No.", RemoveItem, OfferItemBuffer);
                                end;
                            PeriodicDiscountLine.Type::"Special Group":
                                if not AllItemsIncluded or RemoveItem then
                                    ItemsFromSpecialGroup(PeriodicDiscountLine."No.", RemoveItem, TableNo, PeriodicDiscount."No.", OfferItemBuffer);
                        end;
                    until PeriodicDiscountLine.Next = 0;
            end;
    end;

    local procedure RemovePublishedOfferFromBuffer(var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary)
    begin
        PublishedOfferDetailLineImagesTemp_p.SetRange(TableName, PublishedOfferDetailLineImagesTemp_p.TableCaption);
        PublishedOfferDetailLineImagesTemp_p.SetFilter(KeyValue, '%1*', PublishedOfferTemp_p."No.");
        PublishedOfferDetailLineImagesTemp_p.DeleteAll;
        PublishedOfferDetailLineImagesTemp_p.Reset;
        PublishedOfferDetailLineTemp_p.SetRange("Offer No.", PublishedOfferTemp_p."No.");
        PublishedOfferDetailLineTemp_p.DeleteAll;
        PublishedOfferDetailLineTemp_p.Reset;
        PublishedOfferImagesTemp_p.SetRange(TableName, PublishedOfferTemp_p.TableCaption);
        PublishedOfferImagesTemp_p.SetRange(KeyValue, PublishedOfferTemp_p."No.");
        PublishedOfferImagesTemp_p.DeleteAll;
        PublishedOfferImagesTemp_p.Reset;
        PublishedOfferTemp_p.Delete;
    end;

    local procedure RemovePublishedOffersNotWithItem(ItemNo_p: Code[20]; var PublishedOfferTemp_p: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp_p: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp_p: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp_p: Record "LSC Retail Image Link" temporary)
    var
        OfferItemBufferTemp: Record "LSC Offer Item Buffer" temporary;
    begin
        if PublishedOfferTemp_p.FindSet then
            repeat
                ItemsInPublishedOffer(PublishedOfferTemp_p, 0, OfferItemBufferTemp);
                if not OfferItemBufferTemp.Get(ItemNo_p) then
                    RemovePublishedOfferFromBuffer(PublishedOfferTemp_p, PublishedOfferImagesTemp_p, PublishedOfferDetailLineTemp_p, PublishedOfferDetailLineImagesTemp_p);
            until PublishedOfferTemp_p.Next = 0;
    end;

    local procedure RemoveMemberCouponsNotWithItem(ItemNo_p: Code[20]; var MemberCouponBuffer_p: Record "LSC Member Coupon Buffer" temporary)
    var
        CouponHeader: Record "LSC Coupon Header";
        OfferItemBufferTemp: Record "LSC Offer Item Buffer" temporary;
    begin
        if MemberCouponBuffer_p.FindSet then
            repeat
                CouponHeader.Get(MemberCouponBuffer_p."Coupon Code");
                OfferItemBufferTemp.DeleteAll;
                ItemsInCouponDiscount(CouponHeader, OfferItemBufferTemp);
                if not OfferItemBufferTemp.Get(ItemNo_p) then
                    MemberCouponBuffer_p.Delete;
            until MemberCouponBuffer_p.Next = 0;
    end;

    local procedure SetItemTableFilter(var Item: Record Item; FilterType: Option ItemNo,ItemCategory,ProductGroup; FilterValue: Code[20])
    begin
        Item.Reset;
        case FilterType of
            FilterType::ItemNo:
                begin
                    Item.Get(FilterValue);
                    Item.SetRecFilter;
                end;
            FilterType::ItemCategory:
                begin
                    Item.SetCurrentKey("Item Category Code");
                    Item.SetRange("Item Category Code", FilterValue);
                end;
            FilterType::ProductGroup:
                begin
                    Item.SetCurrentKey("LSC Retail Product Code");
                    Item.SetRange("LSC Retail Product Code", FilterValue);
                end;
        end;
    end;

    // local procedure CheckPublishedOfferValidity(PubOfferNo: code[20]; MemberType: Integer; MemberValue: code[10]): Boolean
    // var
    //     PubOfferValidity: Record "MA_Published Offer Validity_NT";
    // begin
    //     PubOfferValidity.SetFilter("Published Offer No.", PubOfferNo);

    //     if MemberValue <> '' then
    //         PubOfferValidity.SetRange("Member Type", MemberType);

    //     PubOfferValidity.SetRange("Member Value", MemberValue);

    //     exit(PubOfferValidity.FindFirst());
    // end;
}

