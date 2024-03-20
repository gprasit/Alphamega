codeunit 60114 "MA_Mobile App Management_NT"
{
    trigger OnRun()
    begin
        // MobileAppSetup.GET;
        // IF NOT MobileAppSetup."Member Notification Enabled" THEN
        //     EXIT;
        // CouponHeader.SETCURRENTKEY("Member Not. Primary Text");
        // CouponHeader.SETFILTER("Member Not. Primary Text", '<>%1', '');
        // TransCouponEntry.SETCURRENTKEY("Coupon Code", Date, "Coupon Function", "Member Notification Processed", "Member Account No.");
        // IF CouponHeader.FINDSET THEN
        //     REPEAT
        //         TransCouponEntry.SETRANGE("Coupon Code", CouponHeader.Code);
        //         TransCouponEntry.SETRANGE(Date, TODAY);
        //         TransCouponEntry.SETRANGE("Coupon Function", TransCouponEntry."Coupon Function"::Use);
        //         TransCouponEntry.SETRANGE("Member Notification Processed", FALSE);
        //         TransCouponEntry.SETFILTER("Member Account No.", '<>%1', '');
        //         IF TransCouponEntry.FINDSET THEN
        //             REPEAT
        //                 CLEAR(MemberNotification);
        //                 MemberNotification.INSERT(TRUE);
        //                 MemberNotification.Type := MemberNotification.Type::Account;
        //                 MemberNotification.Code := TransCouponEntry."Member Account No.";
        //                 MemberNotification."Primary Text" := CouponHeader."Member Not. Primary Text";
        //                 MemberNotification."Secondary Text" := CouponHeader."Member Not. Secondary Text";
        //                 MemberNotification."When Display" := CouponHeader."Member Notification Display";
        //                 MemberNotification."Valid From Date" := TODAY;
        //                 IF FORMAT(CouponHeader."Member Notification Date Calc.") <> '' THEN
        //                     MemberNotification."Valid To Date" := CALCDATE(CouponHeader."Member Notification Date Calc.", TODAY);
        //                 MemberNotification.MODIFY;
        //                 IF CouponHeader."Member Notification Image ID" <> '' THEN
        //                     MemberNotificationImageLink(MemberNotification, CouponHeader);
        //                 TransCouponEntry2 := TransCouponEntry;
        //                 TransCouponEntry2."Member Notification Processed" := TRUE;
        //                 TransCouponEntry2.MODIFY;
        //             UNTIL TransCouponEntry.NEXT = 0;
        //     UNTIL CouponHeader.NEXT = 0;
    end;

    // local procedure MemberNotificationImageLink(MemberNotification: Record "LSC Member Notification"; CouponHeader: Record "LSC Coupon Header")
    // var
    //     RetailImageLink: Record "LSC Retail Image Link";
    // begin
    //     IF CouponHeader."Member Notification Image ID" = '' THEN
    //         EXIT;
    //     IF NOT RetailImageLink.GET(MemberNotification.TABLENAME + ': ' + MemberNotification."No.", CouponHeader."Member Notification Image ID") THEN BEGIN
    //         RetailImageLink.INIT;
    //         RetailImageLink."Record Id" := MemberNotification.TABLENAME + ': ' + MemberNotification."No.";
    //         RetailImageLink."Image Id" := CouponHeader."Member Notification Image ID";
    //         RetailImageLink.TableName := MemberNotification.TABLENAME;
    //         RetailImageLink.KeyValue := MemberNotification."No.";
    //         RetailImageLink.INSERT(TRUE);
    //     END;
    // end;

    procedure IssueCoupon(CouponCode: Code[20]; CardNo: Code[20]): Boolean
    begin
        exit(ProcessCoupon(CouponCode, CardNo, 0));
    end;

    procedure CancelCoupon(CouponCode: Code[20]; CardNo: Code[20]): Boolean
    begin
        EXIT(ProcessCoupon(CouponCode, CardNo, 1));
    end;

    procedure IsUnique(AccountNo: Code[20]; Type: Option Phone,Email; Value: Text[100]): Boolean
    var
        MemberContact: Record "LSC Member Contact";
    begin
        MemberContact.Reset();
        case type of
            Type::Email:
                begin
                    MemberContact.SetCurrentKey("Search E-Mail");
                    MemberContact.SetFilter("Search E-Mail", UpperCase(Value));
                    if AccountNo <> '' then
                        MemberContact.SetFilter("Account No.", '<>%1', AccountNo);
                end;
            Type::Phone:
                begin
                    MemberContact.SetCurrentKey("Phone No.");
                    MemberContact.SetFilter("Phone No.", Value);
                    if AccountNo <> '' then
                        MemberContact.SetFilter("Account No.", '<>%1', AccountNo);
                    if MemberContact.IsEmpty then begin
                        MemberContact.Reset();
                        MemberContact.SetCurrentKey("Mobile Phone No.");
                        MemberContact.SetFilter("Mobile Phone No.", Value);
                        IF AccountNo <> '' THEN
                            MemberContact.SetFilter("Account No.", '<>%1', AccountNo);
                    end else
                        exit(false);
                end;
        END;
        exit(MemberContact.IsEmpty);
    end;

    procedure UpdateAccount(AccountNo: Code[10]; Name: Text; Phone: Text; MobilePhone: Text; Address: Text; Address2: Text; flatno: Text; buildingname: Text[50]; PostCode: Text; regioncode: Text; City: Text; country: text; gdprlevel: Integer; dateofbirth: Text; gender: Text; Email: Text; Language: Code[10]; updatedby: Text; other: Text; phonecode: Text[20]): Text
    begin
        exit(ProcessAccount(AccountNo, Name, Phone, MobilePhone, Address, Address2, flatno, buildingname, PostCode, regioncode, City, country, gdprlevel, DateOfBirth, gender, Email, Language, updatedby, other, phonecode));
    end;

    // procedure NewAccount(Name: Text; Phone: Text; MobilePhone: Text; Address: Text; Address2: Text; flatno: Text; PostCode: Text; regioncode: Text; City: Text; DateOfBirth: Text; Gender: Text; Email: Text; Language: Code[10]): Text
    // begin
    //New NewAccount for BC written
    //     exit(ProcessAccount('', Name, Phone, MobilePhone, Address, Address2, flatno, '', PostCode, regioncode, City, '', 0, DateOfBirth, gender, Email, Language, '', '', ''));
    // end;

    procedure MemberContactSearch(VAR MemberCont: Record "LSC Member Contact"; Value: Text[100]): Boolean
    var
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
    begin
        IF MembershipCard.GET(Value) THEN BEGIN
            MemberCont.GET(MembershipCard."Account No.", MembershipCard."Contact No.");
            EXIT(TRUE);
        END;

        MemberContact.RESET;
        MemberContact.SETCURRENTKEY("Phone No.");
        MemberContact.SETFILTER("Phone No.", Value);
        IF NOT MemberContact.FINDFIRST THEN BEGIN
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            MemberContact.SETFILTER("Mobile Phone No.", Value);
            IF NOT MemberContact.FINDFIRST THEN BEGIN
                MemberContact.RESET;
                MemberContact.SETCURRENTKEY("Search E-Mail");
                MemberContact.SETFILTER("Search E-Mail", UPPERCASE(Value));
                IF NOT MemberContact.FINDFIRST THEN
                    EXIT(FALSE);
            END;
        END;
        MemberCont := MemberContact;
        EXIT(TRUE);
    end;

    procedure MemberContactSearch2(VAR MemberCont: Record "LSC Member Contact"; Value: Text[100]): Integer
    var
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
    begin
        IF MembershipCard.GET(Value) THEN BEGIN
            MemberCont.GET(MembershipCard."Account No.", MembershipCard."Contact No.");
            EXIT(1);
        END;

        MemberContact.RESET;
        MemberContact.SETCURRENTKEY("Phone No.");
        MemberContact.SETFILTER("Phone No.", Value);
        IF MemberContact.COUNT > 1 THEN
            EXIT(3);
        IF NOT MemberContact.FINDFIRST THEN BEGIN
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            MemberContact.SETFILTER("Mobile Phone No.", Value);
            IF MemberContact.COUNT > 1 THEN
                EXIT(3);
            IF NOT MemberContact.FINDFIRST THEN BEGIN
                MemberContact.RESET;
                MemberContact.SETCURRENTKEY("Search E-Mail");
                MemberContact.SETFILTER("Search E-Mail", UPPERCASE(Value));
                IF MemberContact.COUNT > 1 THEN
                    EXIT(3);
                IF NOT MemberContact.FINDFIRST THEN
                    EXIT(0);
            END;
        END;
        MemberCont := MemberContact;
        EXIT(1);

    end;

    procedure MemberCardSearch(VAR MemberCard: Record "LSC Membership Card"; Value: Text[100]): Boolean
    var
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
    begin
        IF MembershipCard.GET(Value) THEN BEGIN
            MemberCard := MembershipCard;
            EXIT(TRUE);
        END;

        MemberContact.RESET;
        MemberContact.SETCURRENTKEY("Phone No.");
        MemberContact.SETFILTER("Phone No.", Value);
        IF NOT MemberContact.FINDFIRST THEN BEGIN
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            MemberContact.SETFILTER("Mobile Phone No.", Value);
            IF NOT MemberContact.FINDFIRST THEN BEGIN
                MemberContact.RESET;
                MemberContact.SETCURRENTKEY("Search E-Mail");
                MemberContact.SETFILTER("Search E-Mail", UPPERCASE(Value));
                IF NOT MemberContact.FINDFIRST THEN
                    EXIT(FALSE);
            END;
        END;
        MembershipCard.SETCURRENTKEY("Account No.", "Contact No.", Status);
        MembershipCard.SETRANGE("Account No.", MemberContact."Account No.");
        MembershipCard.SETRANGE("Contact No.", MemberContact."Contact No.");
        MembershipCard.SETRANGE(Status, MembershipCard.Status::Active);
        IF NOT MembershipCard.FINDFIRST THEN
            EXIT(FALSE);

        MemberCard := MembershipCard;
        EXIT(TRUE);
    end;

    procedure MemberCardFilter(AccNo: Code[20]; ContNo: Code[20]) ReturnText: Text
    var
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
    begin
        MembershipCard.RESET;
        MembershipCard.SETCURRENTKEY("Account No.", "Contact No.", Status);
        MembershipCard.SETRANGE("Account No.", AccNo);
        IF ContNo <> '' THEN BEGIN
            MembershipCard.SETRANGE("Contact No.", ContNo);
            MembershipCard.SETRANGE(Status, MembershipCard.Status::Active);
        END;

        IF MembershipCard.FINDSET THEN
            REPEAT
                IF MembershipCard.Status = MembershipCard.Status::Active THEN BEGIN
                    IF ReturnText = '' THEN
                        ReturnText := MembershipCard."Card No."
                    ELSE
                        ReturnText := ReturnText + '|' + MembershipCard."Card No.";
                END;
            UNTIL MembershipCard.NEXT = 0;
    end;

    procedure LinkMemberLogin(UserName: Text[50]; Password: Text; MemberContactNo: Code[20]; Email: Text): Integer
    var
        MemberContact: Record "LSC Member Contact";
        MemberLogin: Record "LSC Member Login";
        MemberLoginCard: Record "LSC Member Login Card";
        MembershipCard: Record "LSC Membership Card";
        eComGenFN: Codeunit "eCom_General Functions_NT";
        LSExternalFunctionsUtil: Codeunit "LSC External Functions Util";
        MailMgt: Codeunit "Mail Management";
        EmailAccountNo: Code[200];
        Pos: Integer;
    begin
        SelectLatestVersion();
        if UserName = '' then
            exit(1);
        if MemberContactNo = '' then
            exit(1);
        if UserNameExists(UserName) then
            exit(2);
        if not MemberCardMgt.PwdValid(Password) then
            exit(3);

        MemberContact.SetRange("Contact No.", MemberContactNo);
        if not MemberContact.FindFirst then
            exit(4);

        if MemberContact.Blocked then
            exit(5);

        Clear(MemberLogin);
        MemberLogin.SetRange("Account No.", MemberContact."Account No.");
        MemberLogin.SetRange("Contact No.", MemberContact."Contact No.");
        if MemberLogin.FindFirst then
            exit(6);

        if Email <> '' then
            if not MailMgt.CheckValidEmailAddress(Email) then
                exit(7);

        if Email <> '' then begin
            EmailAccountNo := MemberSearch(1, Email, false);
            if EmailAccountNo <> '' then
                if EmailAccountNo <> MemberContact."Account No." then
                    exit(8);
        end;

        if (Email <> '') /*AND (MemberContact."E-Mail" = '')*/ then begin
            MemberContact."E-Mail" := Email;
            MemberContact."Search E-Mail" := UpperCase(Email);
        end;

        Clear(MemberLogin);
        MemberLogin."Login ID" := UserName;
        MemberLogin.Password := LSExternalFunctionsUtil.Hash(Password);
        MemberLogin."Account No." := MemberContact."Account No.";
        MemberLogin."Contact No." := MemberContact."Contact No.";
        //MemberLogin."xClub ID" := MemberContact."Club Code";
        if MemberLogin.Insert() then begin
            MembershipCard.SetCurrentkey("Account No.", "Contact No.", Status);
            MembershipCard.SetRange("Account No.", MemberContact."Account No.");
            MembershipCard.SetRange("Contact No.", MemberContact."Contact No.");
            MembershipCard.SetRange(Status, MembershipCard.Status::Active);
            if MembershipCard.FindSet then begin
                eComGenFN.InsertPoints(MembershipCard."Card No.");
                eComGenFN.InsertAttributes(MembershipCard."Card No.");
                repeat
                    Clear(MemberLoginCard);
                    MemberLoginCard."Login ID" := MemberLogin."Login ID";
                    MemberLoginCard."Card No." := MembershipCard."Card No.";
                    MemberLoginCard.Insert;
                until MembershipCard.Next = 0;
            end;
            if Email <> '' then
                MemberContact.Modify;
            exit(0);
        end else
            exit(9);

    end;

    procedure IsPhoneRegistered(Value: Text): Integer
    var
        MemberContact: Record "LSC Member Contact";
        MemberLogin: Record "LSC Member Login";
        MemberLoginCard: Record "LSC Member Login Card";
        MembershipCard: Record "LSC Membership Card";
        Result: Integer;
    begin
        // 0 Not Found
        // 1 Registered
        // 2 Not Registered
        // 3 Multiple Accounts with phone found

        Result := MemberContactSearch2(MemberContact, Value);
        IF Result <> 1 THEN
            EXIT(Result);
        CLEAR(MemberLoginCard);
        MemberLoginCard.SETCURRENTKEY("Card No.");
        MembershipCard.SETCURRENTKEY("Account No.", "Contact No.", Status);
        MembershipCard.SETRANGE("Account No.", MemberContact."Account No.");
        MembershipCard.SETRANGE("Contact No.", MemberContact."Contact No.");
        MembershipCard.SETRANGE(Status, MembershipCard.Status::Active);
        IF MembershipCard.FINDSET THEN
            REPEAT
                MemberLoginCard.SETRANGE("Card No.", MembershipCard."Card No.");
                IF MemberLoginCard.FINDFIRST THEN
                    EXIT(1);
            UNTIL MembershipCard.NEXT = 0;

        EXIT(2);
    end;

    procedure GetMemberGDPRLevel(MemberContactNo: Code[20]): Integer
    var
        MemberContact: Record "LSC Member Contact";
    begin
        MemberContact.SETRANGE("Contact No.", MemberContactNo);
        IF NOT MemberContact.FINDFIRST THEN
            EXIT(-1);
        EXIT(MemberContact."GDPR Level");
    end;

    procedure SetMemberGDPR(MemberContactNo: Code[20]; GDPRLevel: Integer; UpdatedBy: Text; Other: Text): Integer
    var
        MemberContact: Record "LSC Member Contact";
    begin
        MemberContact.SETRANGE("Contact No.", MemberContactNo);
        IF NOT MemberContact.FINDFIRST THEN
            EXIT(-1);

        MemberContact."GDPR Level" := GDPRLevel;
        MemberContact."GDPR Date Updated" := TODAY;
        MemberContact."GDPR Time Updated" := TIME;

        MemberContact."GDPR Updated By" := UpdatedBy;
        MemberContact."GDPR Other" := Other;
        MemberContact.MODIFY;

        EXIT(0);
    end;

    procedure GetMemberExtras(MemberContactNo: Code[20]): Text
    var
        MemberContact: Record "LSC Member Contact";
    begin
        MemberContact.SETRANGE("Contact No.", MemberContactNo);
        IF NOT MemberContact.FINDFIRST THEN
            EXIT('');
        EXIT(FORMAT(MemberContact."Date of Birth", 0, '<Year4>-<Month,2>-<Day,2>') + '|' + FORMAT(MemberContact.Gender));
    end;

    procedure SetMemberExtras(MemberContactNo: Code[20]; DateOfBirth: Code[10]; Gender: Code[10]): Integer
    var
        MemberContact: Record "LSC Member Contact";
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        MemberContact.SETRANGE("Contact No.", MemberContactNo);
        IF NOT MemberContact.FINDFIRST THEN
            EXIT(-1);
        IF DateOfBirth <> '' THEN
            IF EVALUATE(Year, COPYSTR(DateOfBirth, 1, 4)) THEN
                IF EVALUATE(Month, COPYSTR(DateOfBirth, 6, 2)) THEN
                    IF EVALUATE(Day, COPYSTR(DateOfBirth, 9, 2)) THEN
                        MemberContact."Date of Birth" := DMY2DATE(Day, Month, Year);
        CASE Gender OF
            'MALE':
                MemberContact.Gender := MemberContact.Gender::Male;
            'FEMALE':
                MemberContact.Gender := MemberContact.Gender::Female;
        END;
        MemberContact."Gender 2" := Gender;
        MemberContact.MODIFY;

        EXIT(0);
    end;

    procedure GetMemberLoginID(Value: Text): Text
    var
        _MemberContact: Record "LSC Member Contact";
        _MemberLogin: Record "LSC Member Login";
        _MemberLoginCard: Record "LSC Member Login Card";
        _MembershipCard: Record "LSC Membership Card";
    begin
        //BC Upgrade Start
        if _MemberLogin.Get(Value) then
            exit(_MemberLogin."Login ID");
        //BC Upgrade end
        IF MemberContactSearch2(_MemberContact, Value) = 1 THEN BEGIN
            _MemberLogin.SETCURRENTKEY("Account No.", "Contact No.");
            _MemberLogin.SETRANGE("Account No.", _MemberContact."Account No.");
            _MemberLogin.SETRANGE("Contact No.", _MemberContact."Contact No.");
            IF _MemberLogin.FINDFIRST THEN
                EXIT(_MemberLogin."Login ID")
            ELSE BEGIN
                _MemberLoginCard.SETCURRENTKEY("Card No.");
                _MembershipCard.SETCURRENTKEY("Account No.", "Contact No.");
                _MembershipCard.SETRANGE("Account No.", _MemberContact."Account No.");
                _MembershipCard.SETRANGE("Contact No.", _MemberContact."Contact No.");
                IF _MembershipCard.FINDSET THEN
                    REPEAT
                        _MemberLoginCard.SETRANGE("Card No.", _MembershipCard."Card No.");
                        IF _MemberLoginCard.FINDFIRST THEN
                            EXIT(_MemberLoginCard."Login ID");
                    UNTIL _MembershipCard.NEXT = 0;
            END;
        END;
        EXIT('');
    end;

    procedure MemberNotificationImageLink(MemberNotification: Record "LSC Member Notification"; CouponHeader: Record "LSC Coupon Header")
    var
        RetailImageLink: Record "LSC Retail Image Link";
    begin
        IF CouponHeader."Member Notification Image ID" = '' THEN
            EXIT;
        IF NOT RetailImageLink.GET(MemberNotification.TABLENAME + ': ' + MemberNotification."No.", CouponHeader."Member Notification Image ID") THEN BEGIN
            RetailImageLink.INIT;
            RetailImageLink."Record Id" := MemberNotification.TABLENAME + ': ' + MemberNotification."No.";
            RetailImageLink."Image Id" := CouponHeader."Member Notification Image ID";
            RetailImageLink.TableName := MemberNotification.TABLENAME;
            RetailImageLink.KeyValue := MemberNotification."No.";
            RetailImageLink.INSERT(TRUE);
        END;
    end;

    procedure MemberSearch(Type: Option Phone,Email; Value: Text[100]; Contact: Boolean): Code[200]
    var
        MemberContact: Record "LSC Member Contact";
    begin
        SelectLatestVersion();
        MemberContact.Reset;
        case Type of
            Type::Email:
                begin
                    MemberContact.SetCurrentkey("Search E-Mail");
                    MemberContact.SetFilter("Search E-Mail", UpperCase(Value));
                end;
            Type::Phone:
                begin
                    MemberContact.SetCurrentkey("Phone No.");
                    MemberContact.SetFilter("Phone No.", Value);
                    if not MemberContact.FindFirst then begin
                        MemberContact.Reset;
                        MemberContact.SetCurrentkey("Mobile Phone No.");
                        MemberContact.SetFilter("Mobile Phone No.", Value);
                    end;
                end;
        end;
        if MemberContact.FindFirst then
            if not (Contact) then begin
                exit(MemberContact."Account No.");
            end else
                exit(MemberContact."Contact No." + '|' + MemberContact."E-Mail");
    end;

    procedure GetMemberStartingPoints(cardNo: Text[100]): Decimal
    var
        MemberAccount: Record "LSC Member Account";
        MembershipCard: Record "LSC Membership Card";
    begin
        SelectLatestVersion();
        if MembershipCard.GET(cardNo) then begin
            MemberAccount."No." := MembershipCard."Account No.";
            exit(MemberAccount.TotalRemainingPoints());
        end else
            exit(0);
    end;

    local procedure ProcessCoupon(CouponCode: Code[20]; CardNo: Code[20]; Type: Option Issue,Cancel): Boolean
    var
        CouponHeader: Record "LSC Coupon Header";
        CustCoupon: Record "MA_Customer Coupon_NT";
        CustCouponEntry2: Record "MA_Customer Coupon Entry_NT";
        CustCouponEntry: Record "MA_Customer Coupon Entry_NT";
        MemberAccount: Record "LSC Member Account";
        MemberPointJnlLine: Record "LSC Member Point Jnl. Line";
        MembershipCard: Record "LSC Membership Card";
        PointJnlPostLine: Codeunit "LSC Point Jnl.-Post Line";
        NextEntryNo: Integer;
    begin
        IF NOT MembershipCard.GET(CardNo) THEN
            EXIT(FALSE);
        IF NOT MemberAccount.GET(MembershipCard."Account No.") THEN
            EXIT(FALSE);
        IF NOT CouponHeader.GET(CouponCode) THEN
            EXIT(FALSE);
        IF (CouponHeader."Point Value" = 0) OR (CouponHeader.Status = CouponHeader.Status::Disabled) THEN
            EXIT(FALSE);

        CLEAR(MemberPointJnlLine);
        MemberPointJnlLine.Type := MemberPointJnlLine.Type::Redemption;
        MemberPointJnlLine.VALIDATE("Card No.", CardNo);
        MemberPointJnlLine.Date := TODAY;
        IF Type = Type::Issue THEN
            MemberPointJnlLine.VALIDATE(Points, CouponHeader."Point Value")
        ELSE
            MemberPointJnlLine.VALIDATE(Points, -CouponHeader."Point Value");

        IF NOT CustCoupon.GET(CouponCode, MemberPointJnlLine."Account No.") THEN BEGIN
            CLEAR(CustCoupon);
            CustCoupon."Contact No." := MemberPointJnlLine."Account No.";
            CustCoupon."Coupon Code" := CouponCode;
            CustCoupon.INSERT;
        END;

        NextEntryNo := 0;
        CLEAR(CustCouponEntry);
        CustCouponEntry.SETRANGE("Coupon Code", CouponCode);
        CustCouponEntry.SETRANGE("Contact No.", MemberPointJnlLine."Account No.");
        IF CustCouponEntry.FINDLAST THEN
            NextEntryNo := CustCouponEntry."Entry No.";
        NextEntryNo += 1;
        CLEAR(CustCouponEntry2);
        CustCouponEntry2."Contact No." := MemberPointJnlLine."Account No.";
        CustCouponEntry2."Coupon Code" := CouponCode;
        CustCouponEntry2."Entry No." := NextEntryNo;
        IF Type = Type::Issue THEN
            CustCouponEntry2.Quantity := 1
        ELSE
            CustCouponEntry2.Quantity := -1;

        CustCouponEntry2.Insert();
        PointJnlPostLine.RUN(MemberPointJnlLine);

        exit(true);
    end;

    local procedure ProcessAccount(AccountNo: Code[10]; Name: Text; Phone: Text; MobilePhone: Text; Address: Text; Address2: Text; flatno: Text; buildingname: Text[50]; PostCode: Text; RegionCode: Code[20]; City: Text; country: text; gdprlevel: Integer; DateOfBirth: Text; Gender: Text; Email: Text; Language: Code[10]; GDPRupdatedby: Text; other: Text; phonecode: Text[20]): Text
    var
        MemberAccount: Record "LSC Member Account";
        MemberClub: Record "LSC Member Club";
        MemberContact: Record "LSC Member Contact";
        MemberManagementSetup: Record "LSC Member Management Setup";
        MailMgt: Codeunit "Mail Management";
        Day: Integer;
        Month: Integer;
        Year: Integer;
        ErrorText: Text;
        MemberManagementSetupMissing: Label '%1 not found.';
        MobileDefaultClubMissing: Label '%1 not found. Check %2.';
    begin
        IF (Phone <> '') AND (STRLEN(Phone) > 8) THEN BEGIN
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Phone No.");
            MemberContact.SETFILTER("Phone No.", '=%1', '*@' + Phone + '*');
            IF AccountNo <> '' THEN
                MemberContact.SETFILTER("Account No.", '<>%1', AccountNo);
            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(NT000, MemberContact.FIELDCAPTION("Phone No."), Phone));
        END;

        IF (MobilePhone <> '') AND (STRLEN(MobilePhone) > 8) THEN BEGIN
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            MemberContact.SETFILTER("Mobile Phone No.", '=%1', '*@' + MobilePhone + '*');
            IF AccountNo <> '' THEN
                MemberContact.SETFILTER("Account No.", '<>%1', AccountNo);
            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(NT000, MemberContact.FIELDCAPTION("Mobile Phone No."), MobilePhone));
        END;
        //BC Upgrade Start
        // IF NOT MemberCardMgt.EmailValid(Email) THEN
        //     Email := '';
        if not MailMgt.CheckValidEmailAddress(Email) then
            exit(StrSubstNo(ContactErr, MemberContact."E-Mail"));
        //BC Upgrade End    
        IF (Email <> '') THEN BEGIN
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Search E-Mail");
            MemberContact.SETFILTER("Search E-Mail", '=%1', Email);
            IF AccountNo <> '' THEN
                MemberContact.SETFILTER("Account No.", '<>%1', AccountNo);
            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(NT000, MemberContact.FIELDCAPTION("E-Mail"), Email));
        END;
        MemberContact.Reset(); //BC Upgrade
        IF AccountNo <> '' THEN BEGIN
            MemberAccount.GET(AccountNo);
            MemberContact.SETRANGE("Account No.", AccountNo);
            MemberContact.SETRANGE("Main Contact", TRUE);
            MemberContact.FindFirst();
        END ELSE BEGIN
            //BC Upgrade Start

            // CLEAR(MemberAccount);
            // MemberAccount.INSERT(TRUE);
            // MemberAccount.VALIDATE("Club Code", 'AM');
            // MemberAccount.VALIDATE("Scheme Code", 'ALL');
            // MemberAccount.MODIFY(TRUE);
            // CLEAR(MemberContact);
            // MemberContact."Account No." := MemberAccount."No.";
            // MemberContact."Club Code" := 'AM';
            // MemberContact."Scheme Code" := 'ALL';
            // MemberContact.INSERT(TRUE);
            if not MemberManagementSetup.Get() then begin
                ErrorText := StrSubstNo(MemberManagementSetupMissing, MemberManagementSetup.TableCaption);
                exit(ErrorText);
            end;
            if not MemberClub.Get(MemberManagementSetup."Mobile Default Club Code") then begin
                ErrorText := StrSubstNo(MobileDefaultClubMissing, MemberManagementSetup.FieldCaption("Mobile Default Club Code"), MemberManagementSetup.TableCaption);
                exit(ErrorText);
                CLEAR(MemberAccount);
                MemberAccount.INSERT(TRUE);
            end;
            MemberAccount.VALIDATE("Club Code", MemberClub.Code);
            MemberAccount.VALIDATE("Scheme Code", MemberClub."Default Scheme");
            MemberAccount.MODIFY(TRUE);
            CLEAR(MemberContact);
            MemberContact."Account No." := MemberAccount."No.";
            MemberContact."Club Code" := MemberClub.Code;
            MemberContact."Scheme Code" := MemberClub."Default Scheme";
            MemberContact.INSERT(TRUE);
            //BC Upgrade end            
        END;

        MemberContact.Name := Name;
        MemberContact.Address := Address;
        MemberContact."Address 2" := Address2;
        MemberContact.City := City;
        MemberContact."Region Code" := RegionCode;
        MemberContact."Post Code" := PostCode;
        MemberContact."Phone No." := Phone;
        MemberContact."Mobile Phone No." := MobilePhone;
        MemberContact."Gender 2" := Gender;

        //BC Upgrade Start        
        MemberContact."Flat No." := flatno;
        MemberContact."Building Name" := buildingname;
        MemberContact."Region Code" := RegionCode;
        MemberContact."Country/Region Code" := country;
        MemberContact."GDPR Level" := gdprlevel;
        IF DateOfBirth <> '' THEN
            IF EVALUATE(Year, COPYSTR(DateOfBirth, 1, 4)) THEN
                IF EVALUATE(Month, COPYSTR(DateOfBirth, 6, 2)) THEN
                    IF EVALUATE(Day, COPYSTR(DateOfBirth, 9, 2)) THEN
                        MemberContact."Date of Birth" := DMY2DATE(Day, Month, Year);
        CASE UpperCase(Gender) OF
            'MALE', '1':
                MemberContact.Gender := MemberContact.Gender::Male;
            'FEMALE', '2':
                MemberContact.Gender := MemberContact.Gender::Female;
            else
                MemberContact.Gender := MemberContact.Gender::" ";
        end;
        MemberContact."E-Mail" := Email;
        MemberContact."Language Code" := Language;
        MemberContact."GDPR Updated By" := CopyStr(GDPRupdatedby, 1, MaxStrLen(MemberContact."GDPR Updated By"));
        MemberContact."GDPR Other" := CopyStr(other, 1, MaxStrLen(MemberContact."GDPR Other"));
        MemberContact.PhoneCode := CopyStr(phonecode, 1, MaxStrLen(MemberContact.PhoneCode));
        //BC Upgrade End
        MemberContact.Modify(true);
        exit('');
    end;

    procedure UserNameExists(UserName: Text[50]): Boolean
    var
        MemberLogin: Record "LSC Member Login";
    begin
        exit(MemberLogin.GET(UserName));
    end;

    procedure GetDirectMarketingInfo(CardID: Text[100]; ItemNo: Code[20]; StoreNo: Code[10]; var LoadMemberDirMarkInfoXML: XmlPort "MA_GetDirectMarketingInfo_NT";

    var
        ResponseCode: Code[30];

    var
        ErrorText: Text)
    var
        GetDirectMarketingInfo: Codeunit MA_GetDirectMarketingInfo_NT;
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        ResponseCode := '0000';
        ErrorText := '';
        ClearLastError;
        GetDirectMarketingInfo.SetRequest(CardID, ItemNo, StoreNo);
        if not GetDirectMarketingInfo.Run then begin
            ResponseCode := '0099'; //Unidentified Server Error (check Event Viewer on Server)
            ErrorText := GetLastErrorText;
        end else begin
            GetDirectMarketingInfo.GetResponse(ErrorText, LoadMemberDirMarkInfoXML);
            if ErrorText <> '' then
                ResponseCode := '1000'; //Data Error
        end;
        WebRequestFunctions.WriteRequestLog(format(enum::"LSC Web Services"::GetDirectMarketingInfo), StartDateTime, false, ErrorText);
    end;

    procedure MemberContactCreate(var ResponseCode: Code[30]; var ErrorText: Text; MemberContactCreateXML: XmlPort LSCMemberContactCreateXML;

    var
        ClubID: Code[10];

    var
        SchemeID: Code[10];

    var
        AccountID: Code[20];

    var
        ContactID: Code[20];

    var
        CardID: Text;

    var
        TotalRemainingPoints: Decimal)
    var
        MemberContactCreateUtils: Codeunit MA_MemberContactCreateUtils_NT;
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
        StartDateTime: DateTime;
    begin
        //Not In Use
        StartDateTime := CurrentDateTime;
        ResponseCode := '0000';
        ErrorText := '';
        ClearLastError;
        MemberContactCreateUtils.SetRequest(MemberContactCreateXML);
        if not MemberContactCreateUtils.Run then begin
            ResponseCode := '0099'; //Unidentified Server Error (check Event Viewer on Server)
            ErrorText := GetLastErrorText;
        end else begin
            MemberContactCreateUtils.GetResponse(ErrorText, ClubID, SchemeID, AccountID, ContactID, CardID, TotalRemainingPoints);
            if ErrorText <> '' then
                ResponseCode := '1000'; //Data Error
        end;
        WebRequestFunctions.WriteRequestLog(format(enum::"LSC Web Services"::MemberContactCreate), StartDateTime, false, ErrorText);
    end;

    // procedure DeleteAccount(LogInID: Text[50]): Text
    // var
    //     MemberLogin: Record "LSC Member Login";
    //     MemberLoginCard: Record "LSC Member Login Card";
    // begin
    //     MemberLoginCard.SetFilter("Login ID", LogInID);
    //     if MemberLogin.IsEmpty() then
    //         exit(LoginErr);

    //     if MemberLoginCard.FindSet() then
    //         repeat
    //             BlockMemberAcc(MemberLoginCard."Card No.");
    //         until MemberLoginCard.Next() = 0;
    // end;

    // local procedure BlockMemberAcc(CardNo: Text[100])
    // var
    //     MemberAcc: Record "LSC Member Account";
    //     MembershipCard: Record "LSC Membership Card";
    // begin
    //     if MembershipCard.Get(CardNo) then
    //         if MemberAcc.Get(MembershipCard."Account No.") then begin
    //             BlockMemberContact(MemberAcc);
    //             MemberAcc.Blocked := true;
    //             MemberAcc.Status := MemberAcc.Status::Closed;
    //             MemberAcc."Date Blocked" := Today;
    //             MemberAcc."Blocked By" := UserId;
    //             MemberAcc.Modify(true);
    //         end;
    // end;

    // local procedure BlockMemberContact(MemberAccount_p: Record "LSC Member Account"): Boolean
    // var
    //     MemberContact_l: Record "LSC Member Contact";
    // begin
    //     MemberContact_l.SetRange("Account No.", MemberAccount_p."No.");
    //     MemberContact_l.SetRange(Blocked, not MemberAccount_p.Blocked);
    //     if MemberContact_l.FindSet then
    //         repeat
    //             MemberContact_l."Phone No." := '';
    //             MemberContact_l."Mobile Phone No." := '';
    //             MemberContact_l.Name := '';
    //             MemberContact_l."Name 2" := '';
    //             MemberContact_l.Address := '';
    //             MemberContact_l."Address 2" := '';
    //             MemberContact_l."Address Confirmed" := false;
    //             MemberContact_l."Address ID" := 0;
    //             MemberContact_l."E-Mail" := '';
    //             MemberContact_l."E-Mail 2" := '';
    //             MemberContact_l."Search Name" := '';
    //             MemberContact_l."Search E-Mail" := '';
    //             MemberContact_l.Blocked := MemberAccount_p.Blocked;
    //             MemberContact_l."Reason Blocked" := MemberAccount_p."Reason Blocked";
    //             MemberContact_l."Date Blocked" := MemberAccount_p."Date Blocked";
    //             MemberContact_l."Blocked by" := MemberAccount_p."Blocked By";
    //             if not MemberContact_l.Modify(true) then
    //                 exit(false);
    //             if not BlockMemberContact(MemberContact_l) then //Block Membership card
    //                 exit(false);
    //         until MemberContact_l.Next = 0;
    //     exit(true);
    // end;

    // local procedure BlockMemberContact(MemberContact_p: Record "LSC Member Contact"): Boolean
    // var
    //     MemberCard2_l: Record "LSC Membership Card";
    //     MemberCard_l: Record "LSC Membership Card";
    // begin
    //     MemberCard_l.SetCurrentKey("Account No.", "Contact No.", Status);
    //     MemberCard_l.SetRange("Account No.", MemberContact_p."Account No.");
    //     MemberCard_l.SetRange("Contact No.", MemberContact_p."Contact No.");
    //     if MemberContact_p.Blocked then
    //         MemberCard_l.SetFilter(Status, '<>%1', MemberCard_l.Status::Blocked)
    //     else
    //         MemberCard_l.SetRange(Status, MemberCard_l.Status::Blocked);
    //     if MemberCard_l.FindSet then
    //         repeat
    //             MemberCard2_l.Get(MemberCard_l."Card No.");
    //             if MemberContact_p.Blocked then
    //                 MemberCard2_l.Status := MemberCard2_l.Status::Blocked
    //             else
    //                 MemberCard2_l.Status := MemberCard2_l.Status::Active;
    //             MemberCard2_l."Reason Blocked" := MemberContact_p."Reason Blocked";
    //             MemberCard2_l."Date Blocked" := MemberContact_p."Date Blocked";
    //             MemberCard2_l."Blocked by" := MemberContact_p."Blocked by";
    //             if not MemberCard2_l.Modify() then
    //                 exit(false);
    //         until MemberCard_l.Next = 0;
    //     exit(true);
    // end;

    procedure DeleteContact(AccountNo: Code[20]): Boolean
    var
        MemberAccount: Record "LSC Member Account";
        MemberLogin: Record "LSC Member Login";
        MemberLoginCard: Record "LSC Member Login Card";
        MemberContact: Record "LSC Member Contact";
        MemberContact2: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
    begin
        MemberAccount.Get(AccountNo);
        MemberAccount.Blocked := true;
        MemberAccount."Blocked By" := 'Mobile App';
        MemberAccount.Modify();
        MemberContact.SetRange("Account No.", MemberAccount."No.");
        if MemberContact.FindSet() then
            repeat
                clear(MemberContact2);
                MemberContact2."Account No." := MemberContact."Account No.";
                MemberContact2."Contact No." := MemberContact."Contact No.";
                MemberContact2.Blocked := true;
                MemberContact2."Club Code" := MemberContact."Club Code";
                MemberContact2."Scheme Code" := MemberContact."Scheme Code";
                MemberContact2.Modify();
            until MemberContact.Next() = 0;
        MembershipCard.SetCurrentKey("Account No.");
        MembershipCard.SetRange("Account No.", MemberAccount."No.");
        if MembershipCard.FindSet() then
            MembershipCard.ModifyAll(Status, MembershipCard.Status::Blocked);
        MemberLogin.SetRange("Account No.", MemberAccount."No.");
        if MemberLogin.FindSet() then
            repeat
                MemberLoginCard.SetRange("Login ID", MemberLogin."Login ID");
                MemberLoginCard.DeleteAll();
            until MemberLogin.Next() = 0;
        MemberLogin.DeleteAll();
        exit(true);
    end;

    // procedure MemberPreLogon(CurrInput: Text): Text
    // var
    //     MemberLogin: Record "LSC Member Login";
    //     MemberLogonCard: Record "LSC Member Login Card";
    //     MemberContact: Record "LSC Member Contact";
    //     MemberContactFound: Boolean;
    //     MemberCard: Record "LSC Membership Card";
    //     LoginID: Text[50];

    // begin
    //     if MemberLogin.Get(CurrInput) then
    //         exit(MemberLogin."Login ID");

    //     MemberContact.Reset();
    //     MemberContact.SetCurrentKey("Mobile Phone No.");
    //     MemberContact.SetFilter("Mobile Phone No.", '%1', CurrInput);
    //     MemberContactFound := MemberContact.FindFirst();
    //     if not MemberContactFound then begin
    //         MemberContact.Reset();
    //         MemberContact.SETCURRENTKEY("Phone No.");
    //         MemberContact.SETFILTER("Phone No.", '%1', CurrInput);
    //         MemberContactFound := MemberContact.FindFirst();
    //     end;
    //     if not MemberContactFound then begin
    //         MemberContact.Reset();
    //         MemberContact.SETCURRENTKEY("Search E-Mail");
    //         MemberContact.SETFILTER("Search E-Mail", '%1', CurrInput);
    //         MemberContactFound := MemberContact.FindFirst();
    //     end;
    //     if MemberContactFound then begin
    //         MemberCard.SetCurrentKey("Account No.", "Contact No.");
    //         MemberCard.SetFilter("Account No.", MemberContact."Account No.");
    //         MemberCard.SetFilter("Contact No.", MemberContact."Contact No.");
    //         MemberCard.SetFilter(Status, '%1', MemberCard.Status::Active);
    //         if MemberCard.FindFirst() then begin
    //             MemberLogonCard.SetFilter("Card No.", MemberCard."Card No.");
    //             if MemberLogonCard.FindFirst() then
    //                 exit(MemberLogonCard."Login ID");
    //         end;
    //     end;
    //     exit('');
    // end;
    procedure GetMemberExtraFields(contactNo: Code[20]; var pointBalance: Text; var regionCode: Code[20]; var buildingName: Text[50]; var phoneCode: Text[20]; var flatNo: Code[10]; var gdprLevel: Text[10]; var gdprUpdatedBy: Text[50]; var gdprOther: Text[50]): Text
    var
        MemberContact: Record "LSC Member Contact";
        eComMemFn: Codeunit "eCom_Member Functions_NT";

    begin
        MemberContact.SetFilter("Contact No.", contactNo);
        if not MemberContact.FindFirst() then
            exit(StrSubstNo(ContactErr, MemberContact.FieldCaption("Contact No.")));

        pointBalance := Format(eComMemFn.GetMemberPoints_CS(MemberContact."Contact No."), 0, 1);
        regionCode := MemberContact."Region Code";
        buildingName := MemberContact."Building Name";
        phoneCode := MemberContact.PhoneCode;
        flatNo := MemberContact."Flat No.";
        gdprLevel := format(MemberContact."GDPR Level", 0, 1);
        gdprUpdatedBy := MemberContact."GDPR Updated By";
        gdprOther := MemberContact."GDPR Other";
        exit('');
    end;

    procedure NewAccount(Name: Text; Phone: Text; MobilePhone: Text; Address: Text; Address2: Text; flatno: Text; PostCode: Text; regioncode: Text; City: Text; CountryCode: Code[10]; DateOfBirth: Text; Gender: Text; Email: Text; Language: Code[10]; GDPRLevel: Integer; LoginID: Text; Password: Text; GDPRUpdatedBy: Text[30]; GDPRother: Text[50]; phonecode: Text[20]; buildingname: Text[50]) RetVal: Text
    var
        MemberContact: Record "LSC Member Contact";
        Mobileutils: Codeunit "LSC Mobile utils";
        OK: Boolean;
        RespCode: Code[30];
        CardNo: Text;
        RespText: Text;
        eComGenFN: Codeunit "eCom_General Functions_NT";
    begin
        RetVal := ProcessAccount(MemberContact, '', Name, Phone, MobilePhone, Address, Address2, flatno, PostCode, regioncode, City, CountryCode, DateOfBirth, Gender, Email, Language, GDPRLevel, GDPRUpdatedBy, GDPRother, phonecode, buildingname, OK);
        if not OK then
            exit(RetVal);
        Mobileutils.MobileCreateMembershipCard(MemberContact, CardNo, RespText);
        if RespText <> '' then
            Error(RespText);
        CreateMemberLogin(LoginID, Password, MemberContact, CardNo);
        if CardNo <> '' then begin
            eComGenFN.InsertPoints(CardNo);
            eComGenFN.InsertAttributes(CardNo);
        end;
    end;

    local procedure ProcessAccount(var MemberContact: Record "LSC Member Contact"; AccountNo: Code[20]; Name: Text; Phone: Text; MobilePhone: Text; Address: Text; Address2: Text; flatno: Text; PostCode: Text; regioncode: Code[20]; City: Text; CountryCode: Code[10]; DateOfBirth: Text; Gender: Text; Email: Text; Language: Code[10]; GDPRLevel: Integer; GDPRUpdatedBy: Text[30]; GDPRother: Text[50]; phonecode: Text[20]; buildingname: Text[50]; var OK: Boolean): Text
    var
        MemberAccount: Record "LSC Member Account";
        MemberClub: Record "LSC Member Club";
        //UniqueStatus: Record "Unique Status";//BC Upgrade
        POSSession: Codeunit "LSC POS Session";
        MemberManagementSetupMissing: Label '%1 not found.';
        MobileDefaultClubMissing: Label '%1 not found. Check %2.';
        MemberManagementSetup: Record "LSC Member Management Setup";
        ErrorText: Text;
        MailMgt: Codeunit "Mail Management";
    begin
        SelectLatestVersion();
        OK := false;
        //BC Upgrade Start
        /*
        UniqueSetup.Get;
        UniqueSetup.TestField("Mobile App Member Club");
        UniqueSetup.TestField("Mobile App Member Scheme");
        MemberClub.Get(UniqueSetup."Mobile App Member Club");
        */
        //BC Upgrade End
        if Language = '' then
            Language := 'EN';

        if (Phone <> '') and (StrLen(Phone) >= 8) then begin
            if not IsUnique(AccountNo, 0, Phone) then
                exit(StrSubstNo(NT000, MemberContact.FieldCaption("Phone No."), Phone));
        end else
            if Phone <> '' then
                exit('Invalid phone no.');

        if (MobilePhone <> '') and (StrLen(MobilePhone) >= 8) then begin
            if not IsUnique(AccountNo, 0, MobilePhone) then
                exit(StrSubstNo(NT000, MemberContact.FieldCaption("Mobile Phone No."), MobilePhone));
        end else
            if MobilePhone <> '' then
                exit('Invalid mobile phone no.');

        if not MailMgt.CheckValidEmailAddress(Email) then
            Email := '';
        if (Email <> '') then begin
            MemberContact.Reset;
            MemberContact.SetCurrentkey("Search E-Mail");
            MemberContact.SetFilter("Search E-Mail", '=%1', Email);
            if AccountNo <> '' then
                MemberContact.SetFilter("Account No.", '<>%1', AccountNo);
            if MemberContact.FindFirst then
                exit(StrSubstNo(NT000, MemberContact.FieldCaption("E-Mail"), Email));
        end;
        if AccountNo <> '' then begin
            AccountNo := GetAccountNo(AccountNo);
            MemberAccount.Get(AccountNo);
            if (MemberAccount."Language Code" <> Language) and (Language <> '') then begin
                MemberAccount."Language Code" := Language;
                MemberAccount.Modify();
            end;
            Clear(MemberContact);
            MemberContact.SetRange("Account No.", AccountNo);
            MemberContact.SetRange("Main Contact", true);
            MemberContact.FindFirst;
        end else begin
            Clear(MemberAccount);
            if not MemberManagementSetup.Get() then begin
                ErrorText := StrSubstNo(MemberManagementSetupMissing, MemberManagementSetup.TableCaption);
                exit(ErrorText);
            end;
            if not MemberClub.Get(MemberManagementSetup."Mobile Default Club Code") then begin
                ErrorText := StrSubstNo(MobileDefaultClubMissing, MemberManagementSetup.FieldCaption("Mobile Default Club Code"), MemberManagementSetup.TableCaption);
                exit(ErrorText);
            end;
            MemberAccount."No. Series" := MemberClub."Account No. Series";
            MemberAccount.VALIDATE("Club Code", MemberClub.Code);//BC Upgrade
            MemberAccount.VALIDATE("Scheme Code", MemberClub."Default Scheme");//BC Upgrade            
            MemberAccount."Language Code" := Language;
            POSSession.setValue('NT_SKIP_CC', '1');
            MemberAccount.Insert(true);
            POSSession.DeleteValue('NT_SKIP_CC');
            Clear(MemberContact);
            MemberContact."Account No." := MemberAccount."No.";
            MemberContact."Club Code" := MemberClub.Code;
            MemberContact."Scheme Code" := MemberClub."Default Scheme";
            MemberContact."No. Series" := MemberClub."Contact No. Series";

            MemberContact.Insert(true);
        end;

        MemberContact.Validate(Name, Name);

        MemberContact.Address := Address;
        MemberContact."Address 2" := Address2;
        MemberContact."Flat No." := flatno;
        MemberContact.City := City;
        MemberContact."E-Mail" := Email;
        case UpperCase(Gender) of
            'MALE':
                MemberContact.Gender := MemberContact.Gender::Male;
            'FEMALE':
                MemberContact.Gender := MemberContact.Gender::Female;
            'OTHERS':
                MemberContact.Gender := MemberContact.Gender::" ";
        end;
        MemberContact."Language Code" := Language;
        MemberContact."Main Contact" := true;
        MemberContact."Region Code" := regioncode;
        //MemberContact.Country := CountryCode;
        MemberContact."Post Code" := PostCode;
        MemberContact."Phone No." := Phone;
        MemberContact."Mobile Phone No." := MobilePhone;
        //MemberContact."Gender 2" := Gender;
        MemberContact."Date of Birth" := Text2Date(DateOfBirth);
        //IF MemberContact."GDPR Level" <> GDPRLevel THEN BEGIN
        MemberContact."GDPR Level" := GDPRLevel;
        MemberContact."GDPR Date Updated" := Today;
        MemberContact."GDPR Time Updated" := Time;
        MemberContact."GDPR Updated By" := GDPRUpdatedBy;
        MemberContact."GDPR Other" := GDPRother;
        MemberContact.PhoneCode := phonecode;
        MemberContact."Building Name" := buildingname;
        MemberContact."Country/Region Code" := CountryCode;
        MemberContact.Modify(true);
        OK := true;
        exit('00|' + MemberContact."Account No." + '|' + MemberContact."Contact No.");
    end;

    procedure CreateMemberLogin(UserName: Text[50]; Password: Text; MemberContact: Record "LSC Member Contact"; CardNo: Text)
    var
        MemberLogin: Record "LSC Member Login";
        MemberLoginCard: Record "LSC Member Login Card";
        LSExternalFunctionsUtil: Codeunit "LSC External Functions Util";
        MemberCardMan: Codeunit "LSC Member Card Management";
        EmailAccountNo: Code[200];
        Pos: Integer;
    begin
        SelectLatestVersion();
        if UserName = '' then
            Error('Invalid User Name');
        if UserNameExists(UserName) then
            Error('User Name already exists.');
        if not MemberCardMan.PwdValid(Password) then
            Error('Invalid Password.');

        Clear(MemberLogin);
        MemberLogin."Login ID" := UserName;
        MemberLogin.Password := LSExternalFunctionsUtil.Hash(Password);
        MemberLogin."Account No." := MemberContact."Account No.";
        MemberLogin."Contact No." := MemberContact."Contact No.";
        //MemberLogin."xClub ID" := MemberContact."Club Code";
        if MemberLogin.Insert then begin
            Clear(MemberLoginCard);
            MemberLoginCard."Login ID" := MemberLogin."Login ID";
            MemberLoginCard."Card No." := CardNo;
            MemberLoginCard.Insert;
        end;
    end;

    local procedure Text2Date(Value: Text): Date
    var
        D: Integer;
        M: Integer;
        Y: Integer;
    begin
        if not Evaluate(Y, CopyStr(Value, 1, 4)) then
            exit(0D);
        if not Evaluate(M, CopyStr(Value, 6, 2)) then
            exit(0D);
        if not Evaluate(D, CopyStr(Value, 9, 2)) then
            exit(0D);
        exit(Dmy2date(D, M, Y));
    end;

    local procedure GetAccountNo(ContactNo: code[20]): code[20]
    var
        MemberAccount: Record "LSC Member Account";
        MemberContact: Record "LSC Member Contact";
    begin
        if MemberAccount.Get(ContactNo) then
            exit(ContactNo);
        MemberContact.SetCurrentKey("Contact No.");
        MemberContact.SetRange("Contact No.", ContactNo);
        if MemberContact.FindFirst() then
            exit(MemberContact."Account No.");
        exit(ContactNo);
    end;

    procedure TestConnection(): Text
    var
        ApplicationMgt: Codeunit "Application System Constants";
        BOUtils: Codeunit "LSC BO Utils";
        JsonObj: JsonObject;
        JsonResponse: Text;
    begin
        JsonObj.Add('TestConnectionResult', 'OK');
        JsonObj.Add('ApplicationVersion', ApplicationMgt.ApplicationVersion);
        JsonObj.Add('ApplicationBuild', ApplicationMgt.ApplicationBuild);
        JsonObj.Add('LSRetailVersion', BOUtils.getLSRetailVersion);
        JsonObj.Add('NTAlphaMegaCopyright', getNTAlphaMegaCopyright());
        JsonObj.WriteTo(JsonResponse);
        exit(JsonResponse);
    end;

    local procedure getNTAlphaMegaCopyright(): Text[50]
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        Publisher: text[50];
        Year: Integer;
        IsHandeld: Boolean;
    begin
        NAVAppInstalledApp.SetFilter(Name, 'eCommerceDynamicWeb');
        NAVAppInstalledApp.SetFilter(Publisher, 'Nextech AlphaMega');
        if NAVAppInstalledApp.findfirst then begin
            year := Date2DMY(today, 3);
            exit(StrSubstNo('© 2022-%1 %2', Year, NAVAppInstalledApp.Publisher));
        end;
    end;

    procedure GetMemberInfoForPos(cardNo: Text[100]) JsonResponse: Text
    var
        MemberAccount: Record "LSC Member Account";
        MembershipCard: Record "LSC Membership Card";
        AttributeMgt: Codeunit "LSC Member Attribute Mgmt";
        MemberAttributeListTemp: Record "LSC Member Attribute List" temporary;
        PosBaseAppGenFunc: Codeunit "Pos_General Functions Base_NT";
        JsonObj: JsonObject;
        JsonObj2: JsonObject;
        JsonArr: JsonArray;
        RecRef: RecordRef;
        StartingPoints: Decimal;
    begin
        SelectLatestVersion();
        if MembershipCard.GET(cardNo) then begin
            MemberAccount."No." := MembershipCard."Account No.";
            StartingPoints := MemberAccount.TotalRemainingPoints();
            AttributeMgt.GetAllAttributes(CardNo, MemberAttributeListTemp);
            if MemberAttributeListTemp.FindSet() then
                repeat
                    Clear(RecRef);
                    RecRef.GetTable(MemberAttributeListTemp);
                    JsonObj := PosBaseAppGenFunc.SerializeJsonObject(RecRef);
                    JsonArr.Add(JsonObj);
                //JsonObj2.Add('MemberAttributeList', JsonObj);
                until MemberAttributeListTemp.Next() = 0;
            JsonObj2.Add('StartingPoints', Format(StartingPoints, 0, 1));
            //JsonArr.Add(JsonObj);
            JsonObj2.Add('MemberAttributeList', JsonArr);
            // JsonArr.Add(JsonObj2);
            // JsonArr.WriteTo(JsonResponse);
            JsonObj2.WriteTo(JsonResponse);
            exit(JsonResponse);
        end;
    end;

    var
        CouponHeader: Record "LSC Coupon Header";
        MemberNotification: Record "LSC Member Notification";
        MobileAppSetup: Record "MA_Mobile App Setup_NT";
        TransCouponEntry2: Record "LSC Trans. Coupon Entry";
        TransCouponEntry: Record "LSC Trans. Coupon Entry";
        MemberCardMgt: Codeunit "LSC Member Card Management";
        ContactErr: Label 'Invalid %1';
        LoginErr: Label 'Invalid Login ID';
        NT000: Label '%1 %2 is used by another Contact.';
}
