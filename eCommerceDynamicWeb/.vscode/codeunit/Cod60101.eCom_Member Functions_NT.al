codeunit 60101 "eCom_Member Functions_NT"
{
    procedure GetGiftcardAmount(_MemberContactNo: Code[20]; _GiftcardNo: Code[30]; VAR _ResponseMessage: Text): Decimal
    var
        PosDataEntry: Record "LSC POS Data Entry";
        GiftcardAmount: Integer;
    begin
        GiftcardAmount := 0;
        CLEAR(PosDataEntry);
        PosDataEntry.SETCURRENTKEY("Entry Type", "Entry Code");
        PosDataEntry.SETRANGE("Entry Type", 'GIFT CARD');
        PosDataEntry.SETRANGE("Entry Code", _GiftcardNo);
        PosDataEntry.SETRANGE(Applied, FALSE);
        PosDataEntry.SETFILTER("Expiring Date", '>=%1|%2', TODAY, 0D);
        if PosDataEntry.FindLast() then
            GiftcardAmount := PosDataEntry.Amount - PosDataEntry."Applied Amount"
        else
            _ResponseMessage := Text003;

        exit(GiftcardAmount);
    end;

    procedure GetItemStock(ItemNo: Code[20]) Stock: Decimal
    var
        Item: Record Item;
    begin
        Stock := 0;
        CLEAR(Item);
        IF (Item.GET(ItemNo)) THEN BEGIN
            Item.CalcFields(Inventory);
            Stock := Item.Inventory;
        end;
    end;

    procedure EditProfileUpdateContact_CS(ContactNo: Code[20]; FirstName: Text; LastName: Text; PhoneNo: Text; MobilePhone: Text; DateOfBirth: Text; Gender: Text; Email: Text; IAmAdult: Boolean; PreferredName: Text; CommunicationLanguage: Text[10]; UserIPAddress: Text): Text
    var
        MemberAccount: Record "LSC Member Account";
        MemberContact: Record "LSC Member Contact";
        MailMgt: Codeunit "Mail Management";
        MemberCardMgt: Codeunit "LSC Member Card Management";
        Name: Text;
        OldEmail: Text[80];
        OldMobilePhone: Text[30];
    begin

        IF (ContactNo = '') THEN
            exit(Text004);

        Name := FirstName + ' ' + LastName;

        IF (MobilePhone <> '') AND (STRLEN(MobilePhone) = 8) THEN BEGIN
            //Check first in Phone No. for the Mobile Phone
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Phone No.");
            //MemberContact.SETFILTER("Phone No.",'=%1','*@' + MobilePhone + '*');
            MemberContact.SETFILTER("Phone No.", '=%1', MobilePhone);
            IF ContactNo <> '' THEN
                MemberContact.SETFILTER("Contact No.", '<>%1', ContactNo);
            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(Text009, MemberContact.FIELDCAPTION("Mobile Phone No."), MobilePhone));
            //And then check in Mobile Phone No. for the Mobile Phone
            CLEAR(MemberContact);
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            //MemberContact.SETFILTER("Mobile Phone No.",'=%1','*@' + MobilePhone + '*');
            MemberContact.SETFILTER("Mobile Phone No.", '=%1', MobilePhone);
            IF ContactNo <> '' THEN
                MemberContact.SETFILTER("Contact No.", '<>%1', ContactNo);
            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(Text009, MemberContact.FIELDCAPTION("Mobile Phone No."), MobilePhone));
        END
        ELSE
            EXIT(Text005);

        IF (Email <> '') THEN BEGIN
            //IF NOT MemberCardMgt.EmailValid(Email) THEN // Does Not Exist in BC changed to mail management codeunit
            if not MailMgt.CheckValidEmailAddress(Email) then
                EXIT(Text006);//CS NT

            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("E-Mail");//CS NT use "E-Mail" instead of "Search E-Mail"
            MemberContact.SETFILTER("E-Mail", '=%1', Email);
            IF ContactNo <> '' THEN
                MemberContact.SETFILTER("Contact No.", '<>%1', ContactNo);

            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(Text009, MemberContact.FIELDCAPTION("E-Mail"), Email));
        END
        ELSE
            EXIT(Text008);

        Clear(MemberContact);
        MemberContact.SETRANGE("Contact No.", ContactNo);
        MemberContact.FINDFIRST;
        MemberContact.SETRANGE("Main Contact", TRUE); // CS NT Is this needed?

        OldMobilePhone := MemberContact."Mobile Phone No.";
        OldEmail := MemberContact."E-Mail";

        MemberContact.Name := Name;
        MemberContact."First Name" := FirstName;
        MemberContact.Surname := LastName;
        MemberContact."E-Mail" := Email;
        MemberContact."Search E-Mail" := Email;
        MemberContact."Phone No." := PhoneNo;
        MemberContact."Mobile Phone No." := MobilePhone;
    end;

    procedure UpdateContactAddress(ContactNo: Code[20]; Address: Text; HouseNo: Text; FlatHouseName: Text[50]; PostCode: Text; RegionCode: Text; City: Text; ManualAddress: Boolean): Text
    var
        KioskSetup: Record "Kiosk Setup_NT";
        MemberContact: Record "LSC Member Contact";
    begin
        IF (ContactNo = '') THEN
            exit(Text010);

        if not KioskSetup.Get() then Clear(KioskSetup);//BC Upgrdade    

        CLEAR(MemberContact);
        MemberContact.SETRANGE("Contact No.", ContactNo);
        MemberContact.FINDFIRST;
        // {
        // MemberContact."Manual Address" := ManualAddress;
        //         IF (ManualAddress = FALSE) THEN
        //             MemberContact."Address Wizard" := TRUE;//CS NT The user used the address wizard => Valid address
        //         MemberContact."House No." := HouseNo;
        // }
        MemberContact.Address := Address;
        IF STRLEN(RegionCode) > MAXSTRLEN(MemberContact.County) THEN
            RegionCode := COPYSTR(RegionCode, 1, MAXSTRLEN(MemberContact.County));
        MemberContact.County := RegionCode;//Area/Village
        MemberContact.City := City;
        MemberContact."Post Code" := PostCode;
        //MemberContact.Country := 'CY';//Changed in BC
        MemberContact."Country/Region Code" := KioskSetup."Default Country/Region Code";//BC Upgrade
        MemberContact.MODIFY(TRUE);
        EXIT('');
    end;

    procedure CreateUpdateContact_CS(VAR ContactNo: Code[20]; FirstName: Text; LastName: Text; PhoneNo: Text; MobilePhone: Text; Address: Text; Address2: Text; PostCode: Text; RegionCode: Code[150]; City: Text; DateOfBirth: Text; Gender: Text; Email: Text; GDPRLevel: Integer; VAR CardID: Text; BuildingName: Text[50]; FlatNumber: Text[10]; PhoneCode: Text[20]): Text
    var
        KioskSetup: Record "Kiosk Setup_NT";
        MemberAccount: Record "LSC Member Account";
        MemberClub: Record "LSC Member Club";
        MemberContact: Record "LSC Member Contact";
        MemberShipCard: Record "LSC Membership Card";
        MailMgt: Codeunit "Mail Management";
        Mobileutils: Codeunit "LSC Mobile utils";
        Response_Code: Code[30];
        Day: Integer;
        Month: Integer;
        Year: Integer;
        CardNo: Text;
        Name: Text;
        Response_Text: Text;
    begin
        //Created by CS NT at 09-09-2019 for Alphamega Car Competition
        //Registration => ContactNo=''
        //IsExistingCustomer => Customer has a Loyalty Card and creates an eCommerce account (Cannot change MobilePhone or Email at this stage)
        //CS NT 04-11-2019 Reverse Mobile Phone No. with Phone No.

        //BC Upgrade Start
        if (not KioskSetup.Get() and (KioskSetup."Club Code" = '')) then
            exit(StrSubstNo(Text013, KioskSetup.FieldCaption("Club Code"), KioskSetup.TableCaption));

        if KioskSetup."Default Country/Region Code" = '' then
            exit(StrSubstNo(Text013, KioskSetup.FieldCaption("Default Country/Region Code"), KioskSetup.TableCaption));
        //BC Upgrade End

        Name := FirstName + ' ' + LastName;

        IF ((MobilePhone <> '') AND (PhoneCode <> '357')) OR ((STRLEN(MobilePhone) = 8) AND (PhoneCode = '357')) THEN BEGIN
            //Check first in Phone No. for the Mobile Phone
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Phone No.");
            //MemberContact.SETFILTER("Phone No.",'=%1','*@' + MobilePhone + '*');
            MemberContact.SETFILTER("Phone No.", '=%1', MobilePhone);
            IF ContactNo <> '' THEN
                MemberContact.SETFILTER("Contact No.", '<>%1', ContactNo);
            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(Text009, MemberContact.FIELDCAPTION("Mobile Phone No."), MobilePhone));
            //And then check in Mobile Phone No. for the Mobile Phone
            CLEAR(MemberContact);
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            //MemberContact.SETFILTER("Mobile Phone No.",'=%1','*@' + MobilePhone + '*');
            MemberContact.SETFILTER("Mobile Phone No.", '=%1', MobilePhone);
            IF ContactNo <> '' THEN
                MemberContact.SETFILTER("Contact No.", '<>%1', ContactNo);
            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(Text009, MemberContact.FIELDCAPTION("Mobile Phone No."), MobilePhone));
        END
        ELSE
            EXIT('Invalid Mobile Phone Number provided.');

        IF (Email <> '') THEN BEGIN
            //IF NOT MemberCardMgt.EmailValid(Email) THEN
            if not MailMgt.CheckValidEmailAddress(Email) then
                EXIT('Please provide a valid E-mail address.');//CS NT

            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Search E-Mail");
            MemberContact.SETFILTER("Search E-Mail", '=%1', Email);
            IF ContactNo <> '' THEN
                MemberContact.SETFILTER("Contact No.", '<>%1', ContactNo);

            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(Text009, MemberContact.FIELDCAPTION("E-Mail"), Email));
        END
        ELSE
            EXIT('Please provide an E-mail address to proceed.');

        IF (ContactNo <> '') THEN BEGIN
            CLEAR(MemberContact);
            MemberContact.SETRANGE("Contact No.", ContactNo);
            MemberContact.FINDFIRST;
            MemberContact.SETRANGE("Main Contact", TRUE); // CS NT Is this needed?
        END ELSE BEGIN
            //MemberClub.GET('AM'); BC Upgrade
            MemberClub.GET(KioskSetup."Club Code");//BC Upgrade
            CLEAR(MemberAccount);
            MemberAccount."No. Series" := MemberClub."Account No. Series";
            //MemberAccount."Club Code" := 'AM'; BC Upgrade
            MemberAccount."Club Code" := MemberClub.Code;//BC Upgrade
            MemberAccount.INSERT(TRUE);
            //   {
            //   CLEAR(MemberAccount);
            //             MemberAccount.INSERT(TRUE);
            //             MemberAccount."Club Code" := 'AM';
            //             MemberAccount."Scheme Code" := 'SOCIAL';
            //             MemberAccount.MODIFY(TRUE);
            //   }
            CLEAR(MemberContact);
            MemberContact."No. Series" := MemberClub."Contact No. Series";
            MemberContact."Account No." := MemberAccount."No.";
            //MemberContact."Club Code" := 'AM'; //BC Upgrade
            MemberContact."Club Code" := MemberAccount."Club Code"; //BC Upgrade
            //MemberContact."Created In Store No." := '9999';//BC Upgrade
            MemberContact."Created In Store No." := KioskSetup."Default Web Store No.";//BC Upgrade
            MemberContact.INSERT(TRUE);
            MemberContact.Name := Name;
            //Mobileutils.MobileCreateMembershipCard(MemberContact, CardNo, Response_Code, Response_Text);//Changed In BC
            Mobileutils.MobileCreateMembershipCard(MemberContact, CardNo, Response_Text);//Changeed In BC
        END;

        MemberContact."e-Commerce Customer" := TRUE;
        MemberContact.Name := Name;
        MemberContact."First Name" := FirstName;
        MemberContact.Surname := LastName;

        MemberContact.Address := Address;
        MemberContact."Address 2" := Address2;//HouseNumber
        MemberContact.City := City;
        MemberContact."Region Code" := RegionCode;
        MemberContact."Post Code" := PostCode;
        MemberContact."Flat No." := FlatNumber;
        MemberContact."Building Name" := BuildingName;
        MemberContact.PhoneCode := PhoneCode;
        MemberContact."E-Mail" := Email;

        MemberContact."GDPR Level" := GDPRLevel;
        MemberContact."GDPR Time Updated" := TIME;
        MemberContact."GDPR Date Updated" := TODAY;
        MemberContact."GDPR Updated By" := USERID;
        //..CS NT

        //CS NT.. Add member extras
        IF DateOfBirth <> '' THEN
            IF EVALUATE(Day, COPYSTR(DateOfBirth, 1, 2)) THEN
                IF EVALUATE(Month, COPYSTR(DateOfBirth, 4, 2)) THEN
                    IF EVALUATE(Year, COPYSTR(DateOfBirth, 7, 4)) THEN
                        MemberContact."Date of Birth" := DMY2DATE(Day, Month, Year);

        CASE Gender OF
            'MALE':
                MemberContact.Gender := MemberContact.Gender::Male;
            '1':
                MemberContact.Gender := MemberContact.Gender::Male;
            'FEMALE':
                MemberContact.Gender := MemberContact.Gender::Female;
            '2':
                MemberContact.Gender := MemberContact.Gender::Female;
        END;
        CASE Gender OF  //MALE;FEMALE
            '1':
                MemberContact."Gender 2" := 'MALE';
            '2':
                MemberContact."Gender 2" := 'FEMALE';
        END;

        //MemberContact.Country := 'CY';//Changed In BC
        MemberContact."Country/Region Code" := KioskSetup."Default Country/Region Code";
        //..CS NT

        //CS NT Reverse Mobile Phone No. with Phone No.
        MemberContact."Phone No." := MobilePhone;
        MemberContact."Mobile Phone No." := PhoneNo;
        MemberContact."Scheme Code" := MemberAccount."Scheme Code";
        MemberContact.MODIFY(TRUE);
        ContactNo := MemberContact."Contact No.";

        CLEAR(MemberShipCard);
        MemberShipCard.SETCURRENTKEY("Account No.", "Contact No.", Status);
        MemberShipCard.SETRANGE(MemberShipCard."Account No.", MemberContact."Account No.");
        MemberShipCard.SETRANGE(MemberShipCard."Contact No.", MemberContact."Contact No.");
        IF MemberShipCard.FINDLAST THEN
            CardID := MemberShipCard."Card No.";

        //Send Message if new Customer??
        IF ContactNo = '' THEN begin
            //IF SMSFunctions.SendSMS2(MobilePhone, 'Welcome to Alphamega. CS TODO') THEN;
        end;

        exit('');

    end;

    procedure AddCoupon(TransactionId: Code[20]; BarcodeNo: Text; VAR Amount: Decimal): Boolean
    var
        POSTransLine: Record "LSC POS Trans. Line";
        POSTransLines: Codeunit "LSC POS Trans. Lines";
    begin
        IF BarcodeNo = '' THEN
            EXIT;

        POSView.SetCurrInput(BarcodeNo);
        
        IF NOT POSView.ProcessBarcode() THEN
            EXIT(FALSE);        
        POSTransLines.GetCurrentLine(POSTransLine);
        POSView.TotalPressed();
        POSTransLine.GET(POSTransLine."Receipt No.", POSTransLine."Line No.");

        IF (POSTransLine."Entry Status" = POSTransLine."Entry Status"::" ") AND
            (POSTransLine."Coupon Function" = POSTransLine."Coupon Function"::Use) AND
            (POSTransLine."Coupon Code" <> '') AND
            (POSTransLine."Entry Type" IN [POSTransLine."Entry Type"::Coupon,
              POSTransLine."Entry Type"::Payment]) AND
            (NOT POSTransLine."Valid in Transaction") THEN BEGIN
            POSTransactionFunctions.ClearInput;
            POSTransactionFunctions.VoidLinePressed();
            //ErrorMsg := 'Coupon cannot be used at this point.';
            EXIT;
        END;
        IF POSTransLine."Coupon EAN Org." = BarcodeNo THEN
            EXIT(TRUE);
    end;

    procedure SendSMS_CS(MobilePhone: Text[10]; Text: Text): Text
    var
    begin
        //CS NT THIS NOT LONGER WORKS, use the one in the website add in or in the website service
        //Send SMS with SMSQueue
        //IF SMSFunctions.SendSMS2(MobilePhone, Text) THEN
        IF SendSMS2(MobilePhone, Text) THEN
            EXIT('')
        ELSE
            EXIT('An error occured. Please try again.');
    end;

    procedure SendEmail_CS(EmailAddress: Text[10]; EmailText: Text): Text
    begin
        EXIT('Under Construction');
    end;

    local procedure SendSMS2(SMSnumber: Text[1024]; SmsMessage: Text[1024]): Boolean
    var
        SMSQueue: Record "eCom_SMS Queue_NT";
        EntryNo: Integer;
    begin
        IF (SMSnumber <> '') AND (SmsMessage <> '') THEN BEGIN
            SELECTLATESTVERSION;
            SMSQueue.LockTable();
            IF SMSQueue.FindLast() then
                EntryNo := SMSQueue."Entry No." + 1
            else
                EntryNo := 1;

            SMSQueue.Init();
            SMSQueue."Entry No." += 1;
            SMSQueue.Message := SmsMessage;
            SMSQueue."Phone No." := SMSnumber;
            SMSQueue.Insert();
            exit(true);

        END;
        exit(false);
    end;

    procedure GetContactDetails_CS(accountNo_: Code[20]; contactNo_: Code[20]; VAR FirstName: Text; VAR LastName: Text; VAR Address: Text; VAR Address2: Text; VAR City: Text; VAR RegionCode: Text; VAR PostCode: Text; VAR Country: Text; VAR PhoneNo: Text; VAR MobilePhone: Text; VAR Gender: Integer; VAR Email: Text; VAR DateOfBirth: Text; VAR GDPRLevel: Integer; VAR CardID: Text; VAR LoyaltyPoints: BigInteger; VAR BuildingName: Text[50]; VAR FlatNumber: Text[10]; VAR PhoneCode: Text[20]; var MemberClub: Text[20]; var DiscountTrackingValue: Decimal): Text
    var
        DiscLimitationSetup: Record "LSC Discount Limitation Setup";
        MemberContactRec: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
        DiscountLimitationID: code[10];
        MaxValue: Decimal;
        GenderTemp: Text;
    begin
        IF (contactNo_ <> '') THEN BEGIN
            CLEAR(MemberContactRec);
            //CS NT TEst without this IF(accountNo_ <> '') THEN
            //CS NT TEst without this MemberContactRec.SETRANGE(MemberContactRec."Account No.", accountNo_);
            MemberContactRec.SETRANGE(MemberContactRec."Contact No.", contactNo_);
            IF (MemberContactRec.COUNT <> 1) THEN
                EXIT('An error occured while fetching your account. Please attend to the customer service for further assistance.');

            IF MemberContactRec.FINDFIRST THEN BEGIN
                // Fill ref(VAR) data
                FirstName := MemberContactRec."First Name";
                LastName := MemberContactRec.Surname;

                Address := MemberContactRec.Address;
                Address2 := MemberContactRec."Address 2";
                City := MemberContactRec.City;
                RegionCode := MemberContactRec."Region Code";
                BuildingName := MemberContactRec."Building Name";
                FlatNumber := MemberContactRec."Flat No.";
                PhoneCode := MemberContactRec.PhoneCode;
                IF (PhoneCode = '') THEN
                    PhoneCode := '357';
                PostCode := MemberContactRec."Post Code";

                Country := 'Cyprus';//MemberContactRec.Country;

                //CS NT Check PhoneNo. first because thats where the MobilePhoneNo. is saved
                //OLD IF(STRPOS(MemberContactRec."Phone No." ,'9') = 1) THEN
                IF (MemberContactRec."Phone No." <> '') THEN BEGIN
                    MobilePhone := MemberContactRec."Phone No.";
                    PhoneNo := MemberContactRec."Mobile Phone No.";
                END
                //OLD ELSE IF(STRPOS(MemberContactRec."Mobile Phone No." ,'9') = 1) THEN
                ELSE
                    IF (MemberContactRec."Mobile Phone No." <> '') THEN BEGIN
                        MobilePhone := MemberContactRec."Mobile Phone No.";
                        PhoneNo := MemberContactRec."Phone No.";
                    END;

                GenderTemp := MemberContactRec."Gender 2"; //MALE;FEMALE
                IF (GenderTemp = 'MALE') THEN
                    Gender := 1
                ELSE
                    IF (GenderTemp = 'FEMALE') THEN
                        Gender := 2
                    ELSE
                        Gender := 0;//Optional
                Email := MemberContactRec."E-Mail";
                DateOfBirth := FORMAT(MemberContactRec."Date of Birth", 0, '<Year4>-<Month,2>-<Day,2>');
                //FORMAT(MemberContactRec."Date of Birth",0,'<Day,2>/<Month,2>/<Year4>');
                GDPRLevel := MemberContactRec."GDPR Level";

                //CS NT The third level of the gdpr level is not used so remove it
                IF (GDPRLevel > 7) THEN
                    GDPRLevel := GDPRLevel - 8;

                LoyaltyPoints := GetMemberPoints_CS(MemberContactRec."Contact No.");
                //BC Upgrade Start
                //DiscountTrackingValue := GetRemainingDiscount(MemberContactRec."Contact No.", 'DT00003');
            
                MemberClub := MemberContactRec."Club Code";
                CLEAR(MembershipCard);
                MembershipCard.SETRANGE(MembershipCard."Account No.", MemberContactRec."Account No.");
                IF MembershipCard.FINDFIRST THEN
                    CardID := MembershipCard."Card No.";
                
                MaxValue := 0;
                DiscountTrackingValue := 0;
                if CardID <> '' then begin
                    DiscountLimitationID := 'DT00003';
                    CLEAR(DiscLimitationSetup);
                    DiscLimitationSetup.SETRANGE("Discount Tracking No.", DiscountLimitationID);
                    DiscLimitationSetup.SETRANGE(Type, DiscLimitationSetup.Type::Club);
                    DiscLimitationSetup.SETRANGE("Limitation Type", DiscLimitationSetup."Limitation Type"::"Discount Amount");
                    DiscLimitationSetup.SETRANGE(Code, MemberContactRec."Club Code");
                    if not DiscLimitationSetup.FindFirst() then begin
                        DiscountTrackingValue := 0;
                        exit('');
                    end;
                    MaxValue := DiscLimitationSetup."Limitation Value";
                    DiscountTrackingValue := GetRemainingDiscount(CardID,DiscountLimitationID,MaxValue);
                end;
                //BC Upgrade End    
                EXIT('');
            END
            ELSE
                EXIT(Text011);
        END
        ELSE
            EXIT(Text012);
    end;

    procedure MemberSearch_CS(Type: Option Phone,Email; Value: Text[100]; var MemberContactNo: Code[20]; var MemberAccountNo: Code[20]; var ErrorMessage: Text)
    var
        MemberContact: Record "LSC Member Contact";
    begin
        //CS NT Return MemberContactNo and MemberAccountNo
        MemberContact.RESET;
        CASE Type OF
            Type::Email:
                BEGIN
                    MemberContact.SETCURRENTKEY("Search E-Mail");
                    MemberContact.SETFILTER("Search E-Mail", UPPERCASE(Value));
                    IF NOT MemberContact.FINDFIRST THEN BEGIN
                        MemberContact.RESET;
                        MemberContact.SETFILTER("E-Mail", Value);
                    END;
                END;
            Type::Phone:
                BEGIN
                    MemberContact.SETCURRENTKEY("Phone No.");
                    MemberContact.SETFILTER("Phone No.", Value);
                    IF NOT MemberContact.FINDFIRST THEN BEGIN
                        MemberContact.RESET;
                        MemberContact.SETCURRENTKEY("Mobile Phone No.");
                        MemberContact.SETFILTER("Mobile Phone No.", Value);
                    END;
                END;
        END;
        IF (MemberContact.COUNT > 1) THEN
            ErrorMessage := Text001
        ELSE
            IF MemberContact.FINDFIRST THEN BEGIN
                MemberContactNo := MemberContact."Contact No.";
                MemberAccountNo := MemberContact."Account No.";
            END
            ELSE
                ErrorMessage := Text002;
    end;

    procedure GetMemberPoints_CS(ContactID: Code[20]): BigInteger
    var
        MemberAccountRec: Record "LSC Member Account";
        MemberContactRec: Record "LSC Member Contact";
        TotalPoints: Decimal;
    begin
        SelectLatestVersion();
        CLEAR(MemberAccountRec);
        MemberAccountRec.SETRANGE("Main Contact", ContactID);
        IF MemberAccountRec.FindFirst() THEN BEGIN
            TotalPoints := MemberAccountRec.TotalRemainingPoints();
        END
        ELSE
            TotalPoints := 0;

        //CS NT 20210312 Hotfix for negative balance
        IF (TotalPoints <= 0) THEN
            TotalPoints := 1;

        EXIT(ROUND(TotalPoints, 1, '<'));//Round down to BigInteger
    end;

    procedure MobileAndEmailAreUnique(MobilePhone: Text[100]; EmailAddress: Text[100]): Integer
    var
        MemberContact: Record "LSC Member Contact";

    begin
        //CS NT Copied and modified from MemberContactSearch2 at codeunit Mobile App Functions
        //Check if Mobile Phone and Email are Unique
        // 0 Not Unique Details. Multiple Accounts found
        // 1 Unique details

        IF (MobilePhone <> '') THEN BEGIN
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Phone No.");
            MemberContact.SETFILTER("Phone No.", MobilePhone);
            IF MemberContact.COUNT > 1 THEN
                EXIT(0);

            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            MemberContact.SETFILTER("Mobile Phone No.", MobilePhone);
            IF MemberContact.COUNT > 1 THEN
                EXIT(0);
        END;
        IF (EmailAddress <> '') THEN BEGIN
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Search E-Mail");
            MemberContact.SETFILTER("Search E-Mail", UPPERCASE(EmailAddress));
            IF MemberContact.COUNT > 1 THEN
                EXIT(0);
        END;

        EXIT(1);
    end;

    procedure CheckGiftcardsAndVouchers(TypeOfCheck: Integer; GiftcardOrVoucher: Text; VAR Found: Text[1]; VAR Amount: Decimal; VAR AppliedAmount: Decimal; VAR RemainingAmount: Decimal; VAR DateCreated: Text[10]; VAR ExpiringDate: Text[10]; VAR Expired: Text[1]; VAR AlreadyApplied: Text[1]): Text
    var
        PosDataEntry: Record "LSC POS Data Entry";
    begin
        CLEAR(PosDataEntry);
        //FLAGS Found = 1 or 0, Expired = 1 or 0)
        Found := '0';
        Expired := '0';
        AlreadyApplied := '0';


        IF (TypeOfCheck = 1) THEN //Giftcard
            PosDataEntry.SETRANGE("Entry Type", 'OLDGF')
        ELSE
            IF (TypeOfCheck = 2) THEN //CreditNote
                PosDataEntry.SETRANGE("Entry Type", 'VOUCHER')
            ELSE
                IF (TypeOfCheck = 3) THEN //Voucher
                    PosDataEntry.SETRANGE("Entry Type", 'VOUCHER');

        //PosDataEntry.SETFILTER("Entry Type",'=%1|=%2','CRED_NOTE','GIFT VOUCH');
        PosDataEntry.SETRANGE("Entry Code", GiftcardOrVoucher);

        IF PosDataEntry.FINDFIRST THEN BEGIN
            Found := '1';
            Amount := PosDataEntry.Amount;
            AppliedAmount := PosDataEntry."Applied Amount";
            PosDataEntry.CALCFIELDS("Voucher Remaining Amount");
            RemainingAmount := PosDataEntry.Amount;////PosDataEntry."Voucher Remaining Amount";
            DateCreated := FORMAT(PosDataEntry."Date Created", 0, '<Year4>-<Month,2>-<Day,2>');
            IF (PosDataEntry.Applied) THEN
                AlreadyApplied := '1';
            IF (PosDataEntry."Expiring Date" < TODAY) THEN
                Expired := '1';
            ExpiringDate := FORMAT(PosDataEntry."Expiring Date", 0, '<Day,2>/<Month,2>/<Year4>');//'<Year4>-<Month,2>-<Day,2>');
        END
        ELSE
            Found := '0';

        IF (RemainingAmount = 0) THEN
            Found := '0';//CS NT use this??

        EXIT('');
    end;

    procedure GetPostCodeAddresses(PostCode: Code[10]) xmlResponse: Text
    var
        PostOfficeAddress: Record "eCom_PostOfficeAddress_NT";
        DotNetStringBuilber: TextBuilder;
    begin
        IF PostCode = '' THEN BEGIN
            //DotNetStringBuilber := DotNetStringBuilber.StringBuilder();
            DotNetStringBuilber.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');
            //DotNetStringBuilber.Append(Env.NewLine());
            DotNetStringBuilber.AppendLine();
            DotNetStringBuilber.AppendLine('<Addresses></Addresses>');
            //xmlResponse := DotNetStringBuilber.ToString();
            xmlResponse := DotNetStringBuilber.ToText();
            EXIT;
        END;

        PostOfficeAddress.SETCURRENTKEY("Postal Code", "Street Name");
        PostOfficeAddress.SETRANGE("Postal Code", PostCode);

        //DotNetStringBuilber := DotNetStringBuilber.StringBuilder();
        DotNetStringBuilber.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');
        //DotNetStringBuilber.Append(Env.NewLine());
        DotNetStringBuilber.AppendLine();
        DotNetStringBuilber.AppendLine('<Addresses>');
        //DotNetStringBuilber.Append(Env.NewLine());
        DotNetStringBuilber.AppendLine();

        //CS NT Special Case for AYIA NAPA MARINA 5330
        IF (PostCode = '5330') THEN BEGIN
            PostOfficeAddress.SETFILTER("Street Name", '<>%1', 'AYIA NAPA MARINA');
            DotNetStringBuilber.AppendLine('<Address>');
            //DotNetStringBuilber.Append(Env.NewLine());
            DotNetStringBuilber.AppendLine();
            DotNetStringBuilber.AppendLine(STRSUBSTNO('<PostalCode>%1</PostalCode>', '5330'));
            //DotNetStringBuilber.Append(Env.NewLine());
            DotNetStringBuilber.AppendLine();
            DotNetStringBuilber.AppendLine(STRSUBSTNO('<City>%1</City>', 'AMMOCHOSTOS'));
            // DotNetStringBuilber.Append(Env.NewLine());
            DotNetStringBuilber.AppendLine();
            DotNetStringBuilber.AppendLine(STRSUBSTNO('<Area>%1</Area>', 'Agia Napa'));
            // DotNetStringBuilber.Append(Env.NewLine());
            DotNetStringBuilber.AppendLine();
            DotNetStringBuilber.AppendLine(STRSUBSTNO('<StreetName>%1</StreetName>', 'AYIA NAPA MARINA'));
            // DotNetStringBuilber.Append(Env.NewLine());
            DotNetStringBuilber.AppendLine();
            DotNetStringBuilber.AppendLine(STRSUBSTNO('<StreetNumbers>%1</StreetNumbers>', ''));
            // DotNetStringBuilber.Append(Env.NewLine());
            DotNetStringBuilber.AppendLine();
            DotNetStringBuilber.AppendLine('</Address>');
            // DotNetStringBuilber.Append(Env.NewLine());
            DotNetStringBuilber.AppendLine();
        END;

        PostOfficeAddress.SETASCENDING("Street Name", TRUE);  //CS NT
        IF PostOfficeAddress.FINDSET THEN
            REPEAT
                DotNetStringBuilber.AppendLine('<Address>');
                // DotNetStringBuilber.Append(Env.NewLine());
                DotNetStringBuilber.AppendLine();
                DotNetStringBuilber.AppendLine(STRSUBSTNO('<PostalCode>%1</PostalCode>', PostOfficeAddress."Postal Code"));
                // DotNetStringBuilber.Append(Env.NewLine());
                DotNetStringBuilber.AppendLine();
                DotNetStringBuilber.AppendLine(STRSUBSTNO('<City>%1</City>', PostOfficeAddress.City));
                // DotNetStringBuilber.Append(Env.NewLine());
                DotNetStringBuilber.AppendLine();
                DotNetStringBuilber.AppendLine(STRSUBSTNO('<Area>%1</Area>', PostOfficeAddress.Area));
                // DotNetStringBuilber.Append(Env.NewLine());
                DotNetStringBuilber.AppendLine();
                DotNetStringBuilber.AppendLine(STRSUBSTNO('<StreetName>%1</StreetName>', PostOfficeAddress."Street Name"));
                // DotNetStringBuilber.Append(Env.NewLine());
                DotNetStringBuilber.AppendLine();
                DotNetStringBuilber.AppendLine(STRSUBSTNO('<StreetNumbers>%1</StreetNumbers>', PostOfficeAddress."Special Numbers"));
                // DotNetStringBuilber.Append(Env.NewLine());
                DotNetStringBuilber.AppendLine();
                DotNetStringBuilber.AppendLine('</Address>');
                // DotNetStringBuilber.Append(Env.NewLine());
                DotNetStringBuilber.AppendLine();
            UNTIL PostOfficeAddress.NEXT = 0;
        DotNetStringBuilber.AppendLine('</Addresses>');
        //xmlResponse := DotNetStringBuilber.ToString();
        xmlResponse := DotNetStringBuilber.ToText();
    end;

    procedure GetAddressFromPostCode(PostCode: Code[10]) xmlResponse: Text
    begin
        xmlResponse := GetPostCodeAddresses(PostCode);
    end;

    procedure CheckPaymentsAndVouchers(xmlRequest: Text; VAR xmlResponse: Text): Boolean
    var
        GeneralBuffer: Record "eCom_General Buffer_NT";
        XMLDOMManagement: Codeunit "LSC XML DOM Mgt.";
        XMLelement: XmlElement;
        XMLDoc: XmlDocument;
        CardNo: Code[20];
        Code: Code[10];
        ContactNo: Code[20];
        Amount: Decimal;
        AppliedAmount: Decimal;
        RemainingAmount: Decimal;
        GiftcardOrCreditNote: Integer;
        AlreadyApplied: Text[1];
        DateCreated: Text[10];
        Expired: Text[1];
        ExpiringDate: Text[10];
        Found: Text[1];
        DotNetStringBuilber: TextBuilder;
        XMLNodeList: XmlNodeList;
        XMLRootNode: XmlNode;
        XMLWorkNode: XmlNode;
    begin
        //CheckPaymentsAndVouchers
        Code := '0000';
        CLEAR(GeneralBuffer);
        GeneralBuffer.DELETEALL;
        //XMLDOMManagement.LoadXMLDocumentFromText(xmlRequest, XMLRootNode);
        if XmlDocument.ReadFrom(xmlRequest, XmlDoc) then begin
            XmlDoc.GetRoot(XMLelement);
            XMLRootNode := XMLelement.AsXmlNode();
        end;

        CardNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'CardNo');
        ContactNo := XMLDOMManagement.FindNodeText(XMLRootNode, 'ContactNo');
        // CardNo := FindNodeText(XMLRootNode, 'CardNo');
        // ContactNo := FindNodeText(XMLRootNode, 'ContactNo');

        //CS NT Process-Check Payments (Points, Credit Note, Giftcard)
        XMLDOMManagement.FindNodes(XMLRootNode, 'Payments/Payment', XMLNodeList);
        //----BC Upgrdae Commented-----Start
        // Enumerator := XMLNodeList.GetEnumerator;

        // WHILE Enumerator.MoveNext DO BEGIN
        //     XMLNode := Enumerator.Current;
        //     CLEAR(GeneralBuffer);
        //     Code := INCSTR(Code);
        //     GeneralBuffer."Code 1" := Code;
        //     //GeneralBuffer."Text 1" := XMLDOMManagement.FindNodeText(XMLNode,'ContactNo'); Use the value outside <Payment>
        //     GeneralBuffer."Text 2" := XMLDOMManagement.FindNodeText(XMLNode, 'Type');
        //     GeneralBuffer."Text 3" := XMLDOMManagement.FindNodeText(XMLNode, 'Code');
        //     GeneralBuffer.INSERT;
        // END;
        //----BC Upgrdae Commented-----End

        foreach xmlworknode in xmlnodelist do begin
            CLEAR(GeneralBuffer);
            Code := INCSTR(Code);
            GeneralBuffer."Code 1" := Code;
            case XMLWorkNode.AsXmlElement().Name of
                'Type':
                    GeneralBuffer."Text 2" := XMLDOMManagement.FindNodeText(XMLWorkNode, 'Type');
                'Code':
                    GeneralBuffer."Text 3" := XMLDOMManagement.FindNodeText(XMLWorkNode, 'Code');
            end;
            GeneralBuffer.INSERT;
        end;

        //DotNetStringBuilber := DotNetStringBuilber.StringBuilder();
        DotNetStringBuilber.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');

        //Payments
        DotNetStringBuilber.AppendLine('<Payments>');
        IF GeneralBuffer.FINDSET THEN
            REPEAT
                Found := '0';
                RemainingAmount := 0;
                Expired := '0';
                AlreadyApplied := '0';

                IF ((GeneralBuffer."Text 2" = 'Points') AND (ContactNo <> '')) THEN BEGIN
                    //This will be handled online for now
                    //GetMemberPoints_CS(ContactNo); //CS NT Do not use for nowreadyApplied <> '1')) THEN
                    DotNetStringBuilber.AppendLine('<Payment>');
                    DotNetStringBuilber.AppendLine(STRSUBSTNO('<Type>%1</Type>', GeneralBuffer."Text 2"));
                    DotNetStringBuilber.AppendLine(STRSUBSTNO('<Code>%1</Code>', GeneralBuffer."Text 3"));
                    DotNetStringBuilber.AppendLine('<Amount>0</Amount>');
                    DotNetStringBuilber.AppendLine('</Payment>');
                END
                ELSE
                    IF ((GeneralBuffer."Text 2" = 'Giftcard') OR (GeneralBuffer."Text 2" = 'Credit Note') OR (GeneralBuffer."Text 2" = 'Voucher')) THEN BEGIN
                        IF (GeneralBuffer."Text 2" = 'Giftcard') THEN
                            GiftcardOrCreditNote := 1
                        ELSE
                            IF (GeneralBuffer."Text 2" = 'Credit Note') THEN
                                GiftcardOrCreditNote := 2
                            ELSE
                                IF (GeneralBuffer."Text 2" = 'Voucher') THEN
                                    GiftcardOrCreditNote := 3;

                        CheckGiftcardsAndVouchers(GiftcardOrCreditNote, GeneralBuffer."Text 3", Found, Amount, AppliedAmount, RemainingAmount, DateCreated, ExpiringDate, Expired, AlreadyApplied);
                        IF ((Found = '1') AND (Expired <> '1') AND (AlreadyApplied <> '1')) THEN BEGIN
                            DotNetStringBuilber.AppendLine('<Payment>');
                            DotNetStringBuilber.AppendLine(STRSUBSTNO('<Type>%1</Type>', GeneralBuffer."Text 2"));
                            DotNetStringBuilber.AppendLine(STRSUBSTNO('<Code>%1</Code>', GeneralBuffer."Text 3"));
                            DotNetStringBuilber.AppendLine(STRSUBSTNO('<Amount>%1</Amount>', RemainingAmount));
                            DotNetStringBuilber.AppendLine('</Payment>');
                        END;
                    END;
            UNTIL GeneralBuffer.NEXT = 0;
        DotNetStringBuilber.AppendLine('</Payments>');

        //xmlResponse := DotNetStringBuilber.ToString(); Commented for BC Upgrade
        xmlResponse := DotNetStringBuilber.ToText();
        EXIT(TRUE);
    end;

    procedure CreateANewVerificationCode(_PhoneCode: Text[20]; _MobilePhone: Text[30]; _Email: Text[80]; _VerificationCode: Text): Text[255]
    var
        MemberContact: Record "LSC Member Contact";
        WebsiteVerificationCodes: Record "eCom_Web.VerificationCodes_NT";
        MailMgt: Codeunit "Mail Management";
        MemberCardMgt: Codeunit "LSC Member Card Management";
        _CustomerInformation: Text;
    begin
        //CS NT Check if the _CustomerInformation is used by another contact.. This is used at Edit Profile
        IF (_MobilePhone <> '') OR ((_PhoneCode = '357') AND (STRLEN(_MobilePhone) = 8)) THEN BEGIN
            _CustomerInformation := _MobilePhone;
            //Check first in Phone No. for the Mobile Phone
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Phone No.");
            MemberContact.SETFILTER("Phone No.", '=%1', _MobilePhone);
            IF MemberContact.FINDFIRST THEN
                EXIT('Used');
            //And then check in Mobile Phone No. for the Mobile Phone
            CLEAR(MemberContact);
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            MemberContact.SETFILTER("Mobile Phone No.", '=%1', _MobilePhone);
            IF MemberContact.FINDFIRST THEN
                EXIT('Used');
        END
        ELSE
            IF (_Email <> '') THEN BEGIN
                _CustomerInformation := _Email;
                /* BC Upgrdae Code Change
                IF NOT MemberCardMgt.EmailValid(_Email) THEN                
                    EXIT('Invalid Email');//CS NT
                */
                if not MailMgt.CheckValidEmailAddress(_Email) then
                    EXIT(Text006);//CS NT

                MemberContact.RESET;
                MemberContact.SETCURRENTKEY("Search E-Mail");
                MemberContact.SETFILTER("Search E-Mail", '=%1', _Email);
                IF MemberContact.FINDFIRST THEN
                    EXIT('Used');

                CLEAR(MemberContact);
                MemberContact.RESET;
                MemberContact.SETFILTER("E-Mail", '=%1', _Email);
                IF MemberContact.FINDFIRST THEN
                    EXIT('Used');
            END
            ELSE
                EXIT('Invalid input');
        //..CS NT Check if the _CustomerInformation is used by another contact

        //Delete old records with the same customer information
        CLEAR(WebsiteVerificationCodes);
        WebsiteVerificationCodes.RESET;
        WebsiteVerificationCodes.SETRANGE("Customer Information", _CustomerInformation);
        IF WebsiteVerificationCodes.FINDSET THEN
            REPEAT
                WebsiteVerificationCodes.DELETE;
            UNTIL WebsiteVerificationCodes.NEXT = 0;

        //Delete old records(over 2 days old) for performance and memory
        CLEAR(WebsiteVerificationCodes);
        WebsiteVerificationCodes.RESET;
        WebsiteVerificationCodes.SETFILTER("Date Created", '<=%1', CALCDATE('<-2D>', TODAY));
        IF WebsiteVerificationCodes.FINDSET THEN
            REPEAT
                WebsiteVerificationCodes.DELETE;
            UNTIL WebsiteVerificationCodes.NEXT = 0;


        //Add the new record and if successful return '1'
        CLEAR(WebsiteVerificationCodes);
        WebsiteVerificationCodes.RESET;
        WebsiteVerificationCodes."Customer Information" := _CustomerInformation;
        WebsiteVerificationCodes."Verification Code" := _VerificationCode;
        WebsiteVerificationCodes."Date Created" := TODAY;
        WebsiteVerificationCodes."Time Created" := Time;
        IF WebsiteVerificationCodes.INSERT THEN
            EXIT('1')
        ELSE
            EXIT('0');
    end;

    procedure VerifyUserCode(_CustomerInformation: Text; _VerificationCode: Text) CodeVerified: Text[1]
    var
        WebsiteVerificationCodes: Record "eCom_Web.VerificationCodes_NT";
    begin
        CLEAR(WebsiteVerificationCodes);
        CodeVerified := '0';
        WebsiteVerificationCodes.SETRANGE("Customer Information", _CustomerInformation);
        WebsiteVerificationCodes.SETRANGE("Verification Code", _VerificationCode);
        IF WebsiteVerificationCodes.FINDFIRST THEN
            CodeVerified := '1';
    end;

    procedure GetCustBalance(custid: code[20]): Decimal
    var
        Cust: Record Customer;
    begin
        if Cust.get(custid) then begin
            cust.CalcFields("Net Change");
            exit(cust."Net Change");
        end;
        exit(0);
    end;


    procedure GetAddressesViaPostCode(postCode: Code[10]) JsonResponse: Text
    var
        PostOfficeAddress: Record "eCom_PostOfficeAddress_NT";
        JsonObj2: JsonObject;
        JsonObj3: JsonObject;
        JsonObj: JsonObject;
        JArray: JsonArray;
    begin
        PostOfficeAddress.SetCurrentKey("Postal Code", "Street Name");
        PostOfficeAddress.SetFilter("Postal Code", PostCode);
        IF (PostCode = '5330') THEN BEGIN
            PostOfficeAddress.SETFILTER("Street Name", '<>%1', 'AYIA NAPA MARINA');
            JsonObj3.Add('PostalCode', '5330');
            JsonObj3.Add('City', 'AMMOCHOSTOS');
            JsonObj3.Add('Area', 'Agia Napa');
            JsonObj3.Add('StreetName', 'AYIA NAPA MARINA');
            JsonObj3.Add('StreetNumbers', '');
            JArray.Add(JsonObj3);
        END;

        PostOfficeAddress.SetAscending("Street Name", true);
        IF PostOfficeAddress.FindSet() THEN
            REPEAT
                Clear(JsonObj3);
                JsonObj3.Add('PostalCode', PostOfficeAddress."Postal Code");
                JsonObj3.Add('City', PostOfficeAddress.City);
                JsonObj3.Add('Area', PostOfficeAddress."Area");
                JsonObj3.Add('StreetName', PostOfficeAddress."Street Name");
                JsonObj3.Add('StreetNumbers', PostOfficeAddress."Special Numbers");
                JArray.Add(JsonObj3);
            UNTIL PostOfficeAddress.Next() = 0;
        JsonObj2.Add('Address', JArray);
        JsonObj.Add('addressManagementAddressList', JsonObj2);
        JsonObj.WriteTo(JsonResponse);
    end;

    local procedure GetRemainingDiscount(CardNo: Text; DiscountLimitationID: Code[10]; MaxValue: Decimal): Decimal
    var
        CardRec: Record "LSC Membership Card";
        DiscountLimitation: Record "LSC Discount Tracking Header";
        DiscountTrEntry: Record "LSC Discount Tracking Entry";
        EndingDate: Date;
        StartingDate: Date;
        PositiveDiscTrEntries: Integer;
        lText001: Label '%1 is missing in %2 %3 - Unable to calculate Remaining Discount';
    begin
        if CardNo = '' then
            exit(0)
        else
            CardRec.Get(CardNo);
        DiscountLimitation.Get(DiscountLimitationID);
        if DiscountLimitation."Limitation Type" = DiscountLimitation."Limitation Type"::None then
            exit(999999999999.0);

        if DiscountLimitation.Recurring then begin
            if DiscountLimitation."Starting Date" = 0D then begin
                Message(lText001, DiscountLimitation.FieldCaption("Starting Date"), DiscountLimitation.TableCaption, DiscountLimitationID);
                exit(0);
            end;
            StartingDate := FindCurrentStartingDate(DiscountLimitation."Starting Date", DiscountLimitation."Periodic Calculations");
        end else
            StartingDate := DiscountLimitation."Starting Date";

        EndingDate := CalcDate('<-1D>', CalcDate(DiscountLimitation."Periodic Calculations", StartingDate));
        DiscountTrEntry.SetRange("Tracking No.", DiscountLimitation."No.");
        DiscountTrEntry.SetRange(Date, StartingDate, EndingDate);
        if (Today >= StartingDate) and (Today <= EndingDate) then begin
            case DiscountLimitation."Limited by" of
                DiscountLimitation."Limited by"::Club:
                    begin
                        DiscountTrEntry.SetCurrentKey("Club Code", "Scheme Code", Date, "Tracking No.");
                        DiscountTrEntry.SetRange("Club Code", CardRec."Club Code");
                    end;
                DiscountLimitation."Limited by"::Scheme:
                    begin
                        DiscountTrEntry.SetCurrentKey("Club Code", "Scheme Code", Date, "Tracking No.");
                        DiscountTrEntry.SetRange("Club Code", CardRec."Club Code");
                        DiscountTrEntry.SetRange("Scheme Code", CardRec."Scheme Code");
                    end;
                DiscountLimitation."Limited by"::Account:
                    begin
                        DiscountTrEntry.SetCurrentKey("Tracking No.", "Account No.", "Contact No.", Date);
                        DiscountTrEntry.SetRange("Account No.", CardRec."Account No.");
                    end;
                DiscountLimitation."Limited by"::Contact:
                    begin
                        DiscountTrEntry.SetCurrentKey("Tracking No.", "Account No.", "Contact No.", Date);
                        DiscountTrEntry.SetRange("Account No.", CardRec."Account No.");
                        DiscountTrEntry.SetRange("Contact No.", CardRec."Contact No.");
                    end;
                else
                    exit(999999999999.0);
            end;

            case DiscountLimitation."Limitation Type" of
                DiscountLimitation."Limitation Type"::None:
                    exit(999999999999.0);
                DiscountLimitation."Limitation Type"::"Discount Amount":
                    begin
                        DiscountTrEntry.CalcSums("Discount Amount");
                        exit(MaxValue - DiscountTrEntry."Discount Amount");
                    end;
                DiscountLimitation."Limitation Type"::"No. of Times Triggered":
                    begin
                        DiscountTrEntry.SetFilter("Return Sale", '%1', false);
                        PositiveDiscTrEntries := DiscountTrEntry.Count;
                        DiscountTrEntry.SetFilter("Return Sale", '%1', true);
                        exit(MaxValue - (PositiveDiscTrEntries - DiscountTrEntry.Count));
                    end;
            end;
        end else
            exit(0);
    end;

    local procedure FindCurrentStartingDate(StartingDate: Date; PeriodCalc: DateFormula): Date
    var
        EndingDate: Date;
    begin
        EndingDate := StartingDate;
        repeat
            StartingDate := EndingDate;
            EndingDate := CalcDate(PeriodCalc, StartingDate);
        until (EndingDate > Today);
        exit(StartingDate);
    end;

    var
        POSTransactionFunctions: Codeunit "LSC POS Transaction";
        POSView : Codeunit "LSC POS View";
        Text001: Label 'Multiple accounts found. Please attend to the Customer Service for further assistance.';
        Text002: Label 'Account not found. Please create a new account.';
        Text003: Label 'Gift Card not found or already redeemed.';
        Text004: Label 'Contact No not provided.';
        Text005: Label 'Invalid Mobile Phone Number provided.';
        Text006: Label 'Please provide a valid E-mail address.';
        Text008: Label 'Please provide an E-mail address to proceed.';
        Text009: Label '%1 %2 is used by another Contact.';
        Text010: Label 'External ID not provided';
        Text011: Label 'Account Not Found.';
        Text012: Label 'Invalid request.';
        Text013: Label '%1 is missing from %2 for new registration';

}
