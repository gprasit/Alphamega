xmlport 60108 MA_GetDirectMarketingInfo_NT
{
    Caption = 'GetDirectMarketingInfoXML';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(RootGetDirectMarketingInfo)
        {
            tableelement(publishedoffer; "LSC Published Offer")
            {
                MinOccurs = Zero;
                XmlName = 'PublishedOffer';
                UseTemporary = true;
                SourceTableView = sorting("Display Order");
                fieldelement(No; PublishedOffer."No.")
                {
                }
                fieldelement(DiscountType; PublishedOffer."Discount Type")
                {
                }
                fieldelement(DiscountNo; PublishedOffer."Discount No.")
                {
                }
                fieldelement(Description; PublishedOffer.Description)
                {
                }
                fieldelement(OfferCategory; PublishedOffer."Offer Category")
                {
                }
                fieldelement(PrimaryText; PublishedOffer."Primary Text")
                {
                }
                fieldelement(SecondaryText; PublishedOffer."Secondary Text")
                {
                }
                fieldelement(EndingDate; PublishedOffer."Ending Date")
                {
                    MinOccurs = Zero;
                }
                textelement(PointValue)
                {
                    MinOccurs = Zero;
                    trigger OnBeforePassVariable()
                    var
                    begin
                        PointValue := Format(publishedoffer."Point Value", 0, 9);
                    end;
                }
                fieldelement(DisplayOrder; PublishedOffer."Display Order")
                {
                    MinOccurs = Zero;
                }
            }
            tableelement(publishedofferimages; "LSC Retail Image Link")
            {
                MinOccurs = Zero;
                XmlName = 'PublishedOfferImages';
                UseTemporary = true;
                fieldelement(KeyValue; PublishedOfferImages.KeyValue)
                {
                }
                fieldelement(DisplayOrder; PublishedOfferImages."Display Order")
                {
                }
                fieldelement(ImageId; PublishedOfferImages."Image Id")
                {
                }
            }
            tableelement(publishedofferdetailline; "LSC Published Offer Detail Ln")
            {
                MinOccurs = Zero;
                XmlName = 'PublishedOfferDetailLine';
                UseTemporary = true;
                fieldelement(OfferNo; PublishedOfferDetailLine."Offer No.")
                {
                }
                fieldelement(LineNo; PublishedOfferDetailLine."Line No.")
                {
                }
                fieldelement(Description; PublishedOfferDetailLine.Description)
                {
                }
            }
            tableelement(publishedofferdetaillineimages; "LSC Retail Image Link")
            {
                MinOccurs = Zero;
                XmlName = 'PublishedOfferDetailLineImages';
                UseTemporary = true;
                fieldelement(KeyValue; PublishedOfferDetailLineImages.KeyValue)
                {
                }
                fieldelement(DisplayOrder; PublishedOfferDetailLineImages."Display Order")
                {
                }
                fieldelement(ImageId; PublishedOfferDetailLineImages."Image Id")
                {
                }
            }
            tableelement(membercouponbuffer; "LSC Member Coupon Buffer")
            {
                MinOccurs = Zero;
                XmlName = 'MemberCouponBuffer';
                UseTemporary = true;
                fieldelement(CouponCode; MemberCouponBuffer."Coupon Code")
                {
                }
                fieldelement(Description; MemberCouponBuffer.Description)
                {
                }
                fieldelement(Barcode; MemberCouponBuffer.Barcode)
                {
                }
            }
            tableelement(membernotification; "LSC Member Notification")
            {
                MinOccurs = Zero;
                XmlName = 'MemberNotification';
                UseTemporary = true;
                fieldelement(No; MemberNotification."No.")
                {
                }
                fieldelement(ContactNo; MemberNotification."Contact No.")
                {
                }
                fieldelement(PrimaryText; MemberNotification."Primary Text")
                {
                }
                fieldelement(SecondaryText; MemberNotification."Secondary Text")
                {
                }
                fieldelement(WhenDisplay; MemberNotification."When Display")
                {
                }
                fieldelement(ValidFromDate; MemberNotification."Valid From Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ValidToDate; MemberNotification."Valid To Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(MemberAttribute; MemberNotification."Member Attribute")
                {
                }
                fieldelement(MemberAttributeValue; MemberNotification."Member Attribute Value")
                {
                }
                fieldelement(WebLink; MemberNotification."Web Link")
                {
                }
                fieldelement("E-MailDisclaimer"; MemberNotification."E-Mail Disclaimer")
                {
                }
                fieldelement("PersonalizedE-Mail"; MemberNotification."Personalized E-Mail")
                {
                }
                fieldelement(SendHTML; MemberNotification."Send HTML")
                {
                }
            }
            tableelement(membernotificationimages; "LSC Retail Image Link")
            {
                MinOccurs = Zero;
                XmlName = 'MemberNotificationImages';
                UseTemporary = true;
                fieldelement(KeyValue; MemberNotificationImages.KeyValue)
                {
                }
                fieldelement(DisplayOrder; MemberNotificationImages."Display Order")
                {
                }
                fieldelement(ImageId; MemberNotificationImages."Image Id")
                {
                }
            }
            tableelement(publishedofferlinebuffer; "LSC Published Offer Line Buff")
            {
                MinOccurs = Zero;
                XmlName = 'PublishedOfferLine';
                UseTemporary = true;
                fieldelement(PublishedOfferNo; PublishedOfferLineBuffer."Published Offer No.")
                {
                }
                fieldelement(DiscountType; PublishedOfferLineBuffer."Discount Type")
                {
                }
                fieldelement(DiscountNo; PublishedOfferLineBuffer."Discount No.")
                {
                }
                fieldelement(DiscountLineNo; PublishedOfferLineBuffer."Discount Line No.")
                {
                }
                fieldelement(DiscountLineType; PublishedOfferLineBuffer."Discount Line Type")
                {
                }
                fieldelement(DiscountLineId; PublishedOfferLineBuffer."Discount Line Id")
                {
                }
                fieldelement(DiscountLineDescription; PublishedOfferLineBuffer."Discount Line Description")
                {
                }
                fieldelement(VariantType; PublishedOfferLineBuffer."Variant Type")
                {
                }
                fieldelement(VariantCode; PublishedOfferLineBuffer."Variant Code")
                {
                }
                fieldelement(Exclude; PublishedOfferLineBuffer.Exclude)
                {
                }
                fieldelement(UnitOfMeasure; PublishedOfferLineBuffer."Unit of Measure")
                {
                }
                fieldelement(TableNo; PublishedOfferLineBuffer."Table No.")
                {
                }
            }
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

#if __IS_SAAS__
    internal
#endif
    procedure SetLoadMemberDirMarketInfo(var PublishedOfferTemp: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp: Record "LSC Retail Image Link" temporary; var MemberCouponBufferTemp: Record "LSC Member Coupon Buffer" temporary; var MemberNotificationTemp: Record "LSC Member Notification" temporary; var MemberNotificationImagesTemp: Record "LSC Retail Image Link" temporary; var PublishedOfferLineBufferTemp: Record "LSC Published Offer Line Buff" temporary)
    begin
        if PublishedOfferTemp.FindSet then
            repeat
                PublishedOffer.Init;
                PublishedOffer := PublishedOfferTemp;
                PublishedOffer.Insert;
            until PublishedOfferTemp.Next = 0;

        if PublishedOfferImagesTemp.FindSet then
            repeat
                PublishedOfferImages.Init;
                PublishedOfferImages := PublishedOfferImagesTemp;
                PublishedOfferImages.Insert;
            until PublishedOfferImagesTemp.Next = 0;

        if PublishedOfferDetailLineTemp.FindSet then
            repeat
                PublishedOfferDetailLine.Init;
                PublishedOfferDetailLine := PublishedOfferDetailLineTemp;
                PublishedOfferDetailLine.Insert;
            until PublishedOfferDetailLineTemp.Next = 0;

        if PublishedOfferDetailLineImagesTemp.FindSet then
            repeat
                PublishedOfferDetailLineImages.Init;
                PublishedOfferDetailLineImages := PublishedOfferDetailLineImagesTemp;
                PublishedOfferDetailLineImages.Insert;
            until PublishedOfferDetailLineImagesTemp.Next = 0;

        if MemberCouponBufferTemp.FindSet then
            repeat
                MemberCouponBuffer.Init;
                MemberCouponBuffer := MemberCouponBufferTemp;
                MemberCouponBuffer.Insert;
            until MemberCouponBufferTemp.Next = 0;

        if MemberNotificationTemp.FindSet then
            repeat
                MemberNotification.Init;
                MemberNotification := MemberNotificationTemp;
                MemberNotification.Insert;
            until MemberNotificationTemp.Next = 0;

        if MemberNotificationImagesTemp.FindSet then
            repeat
                MemberNotificationImages.Init;
                MemberNotificationImages := MemberNotificationImagesTemp;
                MemberNotificationImages.Insert;
            until MemberNotificationImagesTemp.Next = 0;

        if PublishedOfferLineBufferTemp.FindSet then
            repeat
                PublishedOfferLineBuffer.Init;
                PublishedOfferLineBuffer := PublishedOfferLineBufferTemp;
                PublishedOfferLineBuffer.Insert;
            until PublishedOfferLineBufferTemp.Next = 0;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure GetLoadMemberDirMarketInfo(var PublishedOfferTemp: Record "LSC Published Offer" temporary; var PublishedOfferImagesTemp: Record "LSC Retail Image Link" temporary; var PublishedOfferDetailLineTemp: Record "LSC Published Offer Detail Ln" temporary; var PublishedOfferDetailLineImagesTemp: Record "LSC Retail Image Link" temporary; var MemberCouponBufferTemp: Record "LSC Member Coupon Buffer" temporary; var MemberNotificationTemp: Record "LSC Member Notification" temporary; var MemberNotificationImagesTemp: Record "LSC Retail Image Link" temporary; var PublishedOfferLineBufferTemp: Record "LSC Published Offer Line Buff" temporary)
    begin
        if PublishedOffer.FindSet then
            repeat
                PublishedOfferTemp.Init;
                PublishedOfferTemp := PublishedOffer;
                PublishedOfferTemp.Insert;
            until PublishedOffer.Next = 0;

        if PublishedOfferImages.FindSet then
            repeat
                PublishedOfferImagesTemp.Init;
                PublishedOfferImagesTemp := PublishedOfferImages;
                PublishedOfferImagesTemp.Insert;
            until PublishedOfferImages.Next = 0;

        if PublishedOfferDetailLine.FindSet then
            repeat
                PublishedOfferDetailLineTemp.Init;
                PublishedOfferDetailLineTemp := PublishedOfferDetailLine;
                PublishedOfferDetailLineTemp.Insert;
            until PublishedOfferDetailLine.Next = 0;

        if PublishedOfferDetailLineImages.FindSet then
            repeat
                PublishedOfferDetailLineImagesTemp.Init;
                PublishedOfferDetailLineImagesTemp := PublishedOfferDetailLineImages;
                PublishedOfferDetailLineImagesTemp.Insert;
            until PublishedOfferDetailLineImages.Next = 0;

        if MemberCouponBuffer.FindSet then
            repeat
                MemberCouponBufferTemp.Init;
                MemberCouponBufferTemp := MemberCouponBuffer;
                MemberCouponBufferTemp.Insert;
            until MemberCouponBuffer.Next = 0;

        if MemberNotification.FindSet then
            repeat
                MemberNotificationTemp.Init;
                MemberNotificationTemp := MemberNotification;
                MemberNotificationTemp.Insert;
            until MemberNotification.Next = 0;

        if MemberNotificationImages.FindSet then
            repeat
                MemberNotificationImagesTemp.Init;
                MemberNotificationImagesTemp := MemberNotificationImages;
                MemberNotificationImagesTemp.Insert;
            until MemberNotificationImages.Next = 0;

        if PublishedOfferLineBuffer.FindSet then
            repeat
                PublishedOfferLineBufferTemp.Init;
                PublishedOfferLineBufferTemp := PublishedOfferLineBuffer;
                PublishedOfferLineBufferTemp.Insert;
            until PublishedOfferLineBuffer.Next = 0;
    end;
}

