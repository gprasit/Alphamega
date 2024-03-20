codeunit 60111 "Kiosk Management_NT"
{

    trigger OnRun()
    var
        KioskSetup: Record "Kiosk Setup_NT";
        ss: Codeunit "Kiosk Management_NT";
        tempblob: Codeunit "Temp Blob";
        xmlmgt: Codeunit "XML DOM Management";
        GetActiveItemsXML: XmlPort "Kiosk_Get Active Items_NT";
        NewRandomPINXML: XmlPort "kiosk_New Random PIN_NT";
        instr: instream;
        ostream: OutStream;
        FileName: Text;
        xx: Text;
        TxtBuilder: TextBuilder;
    begin
        //GetActiveItems(0, GetActiveItemsXML);
        //CreateVoucher('3011828', '01', '0101', '811775', 'TEST KIOSK', 'ALPHAMEGA');
        exit;
        // KioskSetup.Get();
        // SendEmail('prasit@hotmail.com', 'Prasit Ghosh', 'CARDNO125487', 'PIN1', KioskSetup.FieldNo("Welcome Email Template"));
        // NewRandomPIN('93111111', NewRandomPINXML);

        //GetPostCodeAddress('2057');        
        Clear(tempBlob);
        FileName := 'SalesOrder';
        tempBlob.CreateOutStream(oStream, TEXTENCODING::UTF8);
        tempblob.CreateInStream(Instr);
        UploadIntoStream('Select File', 'C:\Nextech\eCommerce', '', FileName, Instr);
        //xmlbuffer.LoadFromStream(instr);
        while not instr.EOS do begin
            instr.Read(xx);
            TxtBuilder.Append(xx);
        end;
        //UpdateInfo(xx);
        //ConfirmAddressGDPR(xx);

    end;

    procedure UpdateInfo(xmlRequest: Text; var UpdateInfoXML: XmlPort "Kiosk_Generic_XML_Response_NT")
    var
        TempXmlBuffer: Record "XML Buffer" temporary;
        eConGenFn: Codeunit "eCom_General Functions_NT";
        Root: XmlElement;
        Seperator: Char;
        contactno: code[20];
        RegionCode: Code[150];
        Address2: Text;
        Address: Text;
        AreaTxt: Text;
        BuildingName: Text[50];
        CardID: Text;
        City: Text;
        DateOfBirth: Text;
        Email: Text;
        FirstName: Text;
        FlatNumber: Text[10];
        Gender: Text;
        KioskCode: Text;
        Language: Text;
        LastName: Text;
        MobilePhone: Text;
        Name: Text;
        NameList: List of [Text];
        PhoneCode: Text[20];
        PhoneNo: Text;
        PIN: Text;
        PointBalance: Text;
        PostCode: Text;
        ResultTxt: Text;
        XmlResponse: Text;
        NodeList: XmlNodeList;
    begin

        TempXmlBuffer.LoadFromText(xmlRequest);
        //if XmlDocument.ReadFrom(XMLRequest, XmlDoc) then begin        
        if not TempXmlBuffer.IsEmpty then begin
            //XmlDoc.GetRoot(Root);

            //NodeList := Root.GetChildElements();
            //ReadChildElement(NodeList, ':ContactNo', NodeVal);
            // NodeVal := '';


            ContactNo := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'ContactNo', TempXmlBuffer.Type::Element);
            Name := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Name', TempXmlBuffer.Type::Element);
            Seperator := 32;
            NameList := Name.Split(Seperator);

            if NameList.Count = 1 then
                FirstName := NameList.Get(1);

            if NameList.Count >= 2 then begin
                FirstName := NameList.Get(1);
                LastName := NameList.Get(2);
            end;

            PhoneNo := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Phone', TempXmlBuffer.Type::Element);
            MobilePhone := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'MobilePhone', TempXmlBuffer.Type::Element);
            Address := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Address', TempXmlBuffer.Type::Element);
            Address2 := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Address2', TempXmlBuffer.Type::Element);
            PostCode := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'PostCode', TempXmlBuffer.Type::Element);
            AreaTxt := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Area', TempXmlBuffer.Type::Element);
            RegionCode := AreaTxt;
            City := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'City', TempXmlBuffer.Type::Element);
            DateOfBirth := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'DateOfBirth', TempXmlBuffer.Type::Element);
            //DateOfBirth := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Date_Of_Birth', TempXmlBuffer.Type::Element);
            Gender := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Gender', TempXmlBuffer.Type::Element);
            Email := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Email', TempXmlBuffer.Type::Element);
            FlatNumber := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'AppartmentNo', TempXmlBuffer.Type::Element);
            PointBalance := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'PointBalance', TempXmlBuffer.Type::Element);
            PIN := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'PIN', TempXmlBuffer.Type::Element);
            Language := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Language', TempXmlBuffer.Type::Element);
            KioskCode := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'KioskCode', TempXmlBuffer.Type::Element);
            CardID := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'CardNo', TempXmlBuffer.Type::Element);

            if not CheckPIN(PIN) then begin
                XmlResponse := CreateXmlResponse('UpdateInfoResponse', 'UpdateInfoResult', PinError, '', '', 'false');
                UpdateInfoXML.SetResponseValues('UpdateInfoResponse', 'UpdateInfoResult', 'false', PinError, '', '');
                UpdateInfoXML.Export();
                exit;
            end;

            ResultTxt := CreateUpdateContact_Kiosk(ContactNo, FirstName, LastName, PhoneNo
                                                , MobilePhone, Address, Address2, PostCode
                                                , RegionCode, City, DateOfBirth, Gender
                                                , Email, 0, CardID, BuildingName
                                                , FlatNumber, PhoneCode, '', '', PIN, Language, KioskCode);
            // if ResultTxt = '' then //No Error
            //     XmlResponse := createXmlResponse('UpdateInfoResponse', 'UpdateInfoResult', ResultTxt, '', CardID, 'true')
            // else
            //     XmlResponse := CreateXmlResponse('UpdateInfoResponse', 'UpdateInfoResult', ResultTxt, '', CardID, 'false');
            // exit(XmlResponse);
            if ResultTxt = '' then //No Error
                //XmlResponse := createXmlResponse('UpdateInfoResponse', 'UpdateInfoResult', ResultTxt, '', CardID, 'true')
                UpdateInfoXML.SetResponseValues('UpdateInfoResponse', 'UpdateInfoResult', 'true', ResultTxt, '', CardID)
            else
                UpdateInfoXML.SetResponseValues('UpdateInfoResponse', 'UpdateInfoResult', 'false', ResultTxt, '', CardID);
            UpdateInfoXML.Export();

        end;
    end;

    procedure ConfirmAddressGDPR(xmlRequest: Text; var ConfirmAddressGDPRXML: XmlPort "Kiosk_Generic_XML_Response_NT")
    var
        TempXmlBuffer: Record "XML Buffer" temporary;
        eConGenFn: Codeunit "eCom_General Functions_NT";
        Root: XmlElement;
        Seperator: Char;
        contactno: code[20];
        RegionCode: Code[150];
        GDPRLevel: Integer;
        Address2: Text;
        Address: Text;
        AreaTxt: Text;
        BuildingName: Text[50];
        CardID: Text;
        City: Text;
        DateOfBirth: Text;
        Email: Text;
        FirstName: Text;
        FlatNumber: Text[10];
        GDPRLevelTxt: Text;
        GDPROther: Text;
        GDPRUpdatedBy: Text;
        Gender: Text;
        KioskCode: Text;
        Language: Text;
        LastName: Text;
        MobilePhone: Text;
        Name: Text;
        NameList: List of [Text];
        PhoneCode: Text[20];
        PhoneNo: Text;
        PIN: Text;
        PointBalance: Text;
        PostCode: Text;
        ResultTxt: Text;
        XmlResponse: Text;
        NodeList: XmlNodeList;
    begin

        TempXmlBuffer.LoadFromText(xmlRequest);

        if not TempXmlBuffer.IsEmpty then begin

            ContactNo := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'ContactNo', TempXmlBuffer.Type::Element);
            Name := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Name', TempXmlBuffer.Type::Element);
            Seperator := 32;
            NameList := Name.Split(Seperator);

            if NameList.Count = 1 then
                FirstName := NameList.Get(1);

            if NameList.Count >= 2 then begin
                FirstName := NameList.Get(1);
                LastName := NameList.Get(2);
            end;

            PhoneNo := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Phone', TempXmlBuffer.Type::Element);
            MobilePhone := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'MobilePhone', TempXmlBuffer.Type::Element);
            Address := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Address', TempXmlBuffer.Type::Element);
            Address2 := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Address2', TempXmlBuffer.Type::Element);
            PostCode := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'PostCode', TempXmlBuffer.Type::Element);
            AreaTxt := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Area', TempXmlBuffer.Type::Element);
            City := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'City', TempXmlBuffer.Type::Element);
            DateOfBirth := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'DateOfBirth', TempXmlBuffer.Type::Element);
            //DateOfBirth := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Date_Of_Birth', TempXmlBuffer.Type::Element);
            Gender := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Gender', TempXmlBuffer.Type::Element);
            Email := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Email', TempXmlBuffer.Type::Element);
            FlatNumber := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'AppartmentNo', TempXmlBuffer.Type::Element);
            PointBalance := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'PointBalance', TempXmlBuffer.Type::Element);
            PIN := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'PIN', TempXmlBuffer.Type::Element);
            Language := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Language', TempXmlBuffer.Type::Element);
            KioskCode := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'KioskCode', TempXmlBuffer.Type::Element);
            CardID := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'CardNo', TempXmlBuffer.Type::Element);
            GDPRLevelTxt := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'GDPRLevel', TempXmlBuffer.Type::Element);
            GDPRUpdatedBy := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'UpdatedBy', TempXmlBuffer.Type::Element);
            GDPROther := eConGenFn.XmlBufferFindNodeText(TempXmlBuffer, 'Other', TempXmlBuffer.Type::Element);
            if GDPRLevelTxt <> '' then
                if not Evaluate(GDPRLevel, GDPRLevelTxt) then begin
                    //XmlResponse := CreateXmlResponse('ConfirmAddressGDPRResponse', 'ConfirmAddressGDPRResult', GDPRLevelError, '', '', 'false');
                    // exit(XmlResponse);
                    ConfirmAddressGDPRXML.SetResponseValues('ConfirmAddressGDPRResponse', 'ConfirmAddressGDPRResult', 'false', GDPRLevelError, '', '');
                    ConfirmAddressGDPRXML.Export();
                    exit;
                end;
            if not CheckPIN(PIN) then begin
                // XmlResponse := CreateXmlResponse('ConfirmAddressGDPRResponse', 'ConfirmAddressGDPRResult', PinError, '', '', 'false');
                // exit(XmlResponse);
                ConfirmAddressGDPRXML.SetResponseValues('ConfirmAddressGDPRResponse', 'ConfirmAddressGDPRResult', 'false', PinError, '', '');
                ConfirmAddressGDPRXML.Export();
                exit;
            end;

            ResultTxt := CreateUpdateContact_Kiosk(ContactNo, FirstName, LastName, PhoneNo
                                                , MobilePhone, Address, Address2, PostCode
                                                , RegionCode, City, DateOfBirth, Gender
                                                , Email, GDPRLevel, CardID, BuildingName
                                                , FlatNumber, PhoneCode, GDPRUpdatedBy, GDPROther, PIN, Language, KioskCode);
            //if ResultTxt = '' then //No Error
            //XmlResponse := createXmlResponse('ConfirmAddressGDPRResponse', 'ConfirmAddressGDPRResult', ResultTxt, '', CardID, 'true')
            // else
            //     XmlResponse := CreateXmlResponse('ConfirmAddressGDPRResponse', 'ConfirmAddressGDPRResult', ResultTxt, '', CardID, 'false');
            // exit(XmlResponse);

            if ResultTxt = '' then //No Error                
                ConfirmAddressGDPRXML.SetResponseValues('ConfirmAddressGDPRResponse', 'ConfirmAddressGDPRResult', 'true', ResultTxt, '', CardID)
            else
                ConfirmAddressGDPRXML.SetResponseValues('ConfirmAddressGDPRResponse', 'ConfirmAddressGDPRResult', 'false', ResultTxt, '', CardID);


            ConfirmAddressGDPRXML.Export();
            //exit(XmlResponse);
        end;
    end;


    procedure ReadChildElement(NodeList: XmlNodeList; ElementName: Text; Var NodeValue: Text)
    var
        ChildElement: XmlElement;
        i: Integer;
        ChildNode: XmlNode;
        ChildNodeList: XmlNodeList;
    begin
        //foreach ChildNode in NodeList do begin
        for i := 1 to NodeList.Count do begin
            if NodeList.Get(i, ChildNode) then
                if ChildNode.IsXmlElement then begin
                    ChildElement := ChildNode.AsXmlElement();
                    if ChildNode.AsXmlElement().Name = ElementName then begin
                        NodeValue := ChildNode.AsXmlElement().InnerText;
                    end else
                        if ChildElement.HasElements then begin
                            ChildNodeList := ChildElement.GetChildElements();
                            ReadChildElement(ChildNodeList, ElementName, NodeValue);
                        end;
                end;
        end;
    end;

    local procedure CheckPIN(PIN: Text): Boolean
    var
        PINIntVal: Integer;
    begin

        if PIN = '' then
            exit(false);

        if StrLen(PIN) <> 4 then
            exit(false);

        if not Evaluate(PINIntVal, PIN) then
            exit(false);

        if ((PINIntVal < 1) or (PINIntVal > 9999)) then
            exit(false);
        exit(true);
    end;

    local procedure CreateUpdateContact_Kiosk(VAR ContactNo: Code[20]; FirstName: Text; LastName: Text; PhoneNo: Text; MobilePhone: Text; Address: Text; Address2: Text; PostCode: Text; RegionCode: Code[150]; City: Text; DateOfBirth: Text; Gender: Text; Email: Text; GDPRLevel: Integer; VAR CardID: Text; BuildingName: Text[50]; FlatNumber: Text[10]; PhoneCode: Text[20]; GDPRUpdateBy: Text; GDPROther: Text; PIN: Text[4]; LanguageCode: Code[20]; KioskCode: Text): Text
    var
        KioskSetup: Record "Kiosk Setup_NT";
        MemberAccount: Record "LSC Member Account";
        MemberClub: Record "LSC Member Club";
        MemberContact: Record "LSC Member Contact";
        MemberShipCard: Record "LSC Membership Card";
        MailMgt: Codeunit "Mail Management";
        Mobileutils: Codeunit "LSC Mobile utils";
        NewRegistration: Boolean;
        Response_Code: Code[30];
        DOB: Date;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        CardNo: Text;
        Name: Text;
        Response_Text: Text;
    begin
        //BC Upgrade Sart
        ClearLastError();
        NewRegistration := ContactNo = '';

        if (not KioskSetup.Get() and (KioskSetup."Registration Bonus Points" = 0)) then
            exit(StrSubstNo(Text002, KioskSetup.FieldCaption("Registration Bonus Points"), KioskSetup.TableCaption));

        if KioskSetup."Club Code" = '' then
            exit(StrSubstNo(Text002, KioskSetup.FieldCaption("Club Code"), KioskSetup.TableCaption));

        if KioskSetup."Default Country/Region Code" = '' then
            exit(StrSubstNo(Text002, KioskSetup.FieldCaption("Default Country/Region Code"), KioskSetup.TableCaption));

        //BC Upgrade End

        //Created by CS NT at 09-09-2019 for Alphamega Car Competition
        //Registration => ContactNo=''
        //IsExistingCustomer => Customer has a Loyalty Card and creates an eCommerce account (Cannot change MobilePhone or Email at this stage)
        //CS NT 04-11-2019 Reverse Mobile Phone No. with Phone No.

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
                EXIT(STRSUBSTNO(Text001, MemberContact.FIELDCAPTION("Mobile Phone No."), MobilePhone));
            //And then check in Mobile Phone No. for the Mobile Phone
            CLEAR(MemberContact);
            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Mobile Phone No.");
            //MemberContact.SETFILTER("Mobile Phone No.",'=%1','*@' + MobilePhone + '*');
            MemberContact.SETFILTER("Mobile Phone No.", '=%1', MobilePhone);
            IF ContactNo <> '' THEN
                MemberContact.SETFILTER("Contact No.", '<>%1', ContactNo);
            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(Text001, MemberContact.FIELDCAPTION("Mobile Phone No."), MobilePhone));
        END
        ELSE
            EXIT('Invalid Mobile Phone Number provided.');

        IF (Email <> '') THEN BEGIN
            //IF NOT MemberCardMgt.EmailValid(Email) THEN //BC Upgrade
            if not MailMgt.CheckValidEmailAddress(Email) then //BC Upgrade
                EXIT('Please provide a valid E-mail address.');//CS NT

            MemberContact.RESET;
            MemberContact.SETCURRENTKEY("Search E-Mail");
            MemberContact.SETFILTER("Search E-Mail", '=%1', Email);
            IF ContactNo <> '' THEN
                MemberContact.SETFILTER("Contact No.", '<>%1', ContactNo);

            IF MemberContact.FINDFIRST THEN
                EXIT(STRSUBSTNO(Text001, MemberContact.FIELDCAPTION("E-Mail"), Email));
        END
        ELSE
            EXIT('Please provide an E-mail address to proceed.');

        IF (ContactNo <> '') THEN BEGIN
            CLEAR(MemberContact);
            MemberContact.SETRANGE("Contact No.", ContactNo);
            MemberContact.FINDFIRST;
            MemberContact.SETRANGE("Main Contact", TRUE); // CS NT Is this needed?
        END ELSE BEGIN

            //MemberClub.GET('AM');//BC Upgrade
            MemberClub.GET(KioskSetup."Club Code");//BC Upgrade

            CLEAR(MemberAccount);
            MemberAccount."No. Series" := MemberClub."Account No. Series";

            //BC Upgrade Start

            //MemberAccount."Club Code" := 'AM';
            MemberAccount."Club Code" := KioskSetup."Club Code";
            //MemberAccount.INSERT(TRUE);
            MemberContact."Created In Store No." := KioskSetup."Default Kiosk Store No.";
            if not MemberAccount.Insert(true) then
                exit(StrSubstNo('%1 %2', GetLastErrorCode, MemberAccount.TableCaption));

            //BC Upgrade End
            CLEAR(MemberContact);
            MemberContact."No. Series" := MemberClub."Contact No. Series";
            MemberContact."Account No." := MemberAccount."No.";
            //MemberContact."Club Code" := 'AM';//BC Upgrade
            MemberContact."Club Code" := MemberAccount."Club Code";//BC Upgrade
            //MemberContact."Created In Store No." := '9999';BC Upgrade
            MemberContact."Created In Store No." := CopyStr(KioskCode, 1, MaxStrLen(MemberContact."Created In Store No."));//BC Upgrade
                                                                                                                           //MemberContact.INSERT(TRUE);//BC Upgrade
            if not MemberContact.Insert(true) then //BC Upgrade
                exit(StrSubstNo('%1 %2', GetLastErrorCode, MemberContact.TableCaption));
            MemberContact.Name := Name;
            //Mobileutils.MobileCreateMembershipCard(MemberContact, CardNo, Response_Code, Response_Text);//BC Upgrade
            MemberContact."Scheme Code" := MemberAccount."Scheme Code";//BC Upgrade
            Mobileutils.MobileCreateMembershipCard(MemberContact, CardNo, Response_Text);//Changed In BC
            if Response_Text <> '' then //BC Upgrade
                exit(Response_Text);
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

        CASE UpperCase(Gender) OF
            'MALE':
                begin
                    MemberContact.Gender := MemberContact.Gender::Male;
                    MemberContact."Gender 2" := 'MALE';//BC Upgrade
                end;
            '1':
                MemberContact.Gender := MemberContact.Gender::Male;
            'FEMALE':
                MemberContact.Gender := MemberContact.Gender::Female;
            '2':
                begin
                    MemberContact.Gender := MemberContact.Gender::Female;
                    MemberContact."Gender 2" := 'FEMALE';//BC Upgrade
                end;
        END;

        CASE Gender OF  //MALE;FEMALE
            '1':
                MemberContact."Gender 2" := 'MALE';
            '2':
                MemberContact."Gender 2" := 'FEMALE';
        END;

        //MemberContact.Country := 'CY';//Changed In BC
        MemberContact."Country/Region Code" := KioskSetup."Default Country/Region Code";//BC Upgrade
        //..CS NT

        //CS NT Reverse Mobile Phone No. with Phone No.

        MemberContact."Phone No." := MobilePhone;
        MemberContact."Mobile Phone No." := PhoneNo;

        //BC Upgrade Start
        MemberContact."Phone No." := PhoneNo;
        MemberContact."Mobile Phone No." := MobilePhone;

        if GDPRUpdateBy <> '' then
            MemberContact."GDPR Updated By" := COPYSTR(GDPRUpdateBy, 1, MAXSTRLEN(MemberContact."GDPR Updated By"));
        if GDPROther <> '' then
            MemberContact."GDPR Other" := COPYSTR(GDPROther, 1, MAXSTRLEN(MemberContact."GDPR Other"));

        MemberContact."Kiosk Pin" := PIN;
        MemberContact."Language Code" := LanguageCode;//BC Upgrade
        MemberContact."Address Confirmed" := true;
        if DateOfBirth <> '' then
            if Evaluate(DOB, DateOfBirth) then
                MemberContact."Date of Birth" := DOB;
        //BC Upgrade End
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

        //BC Upgrade Start        
        if NewRegistration then begin
            //PostBonusPointEntry(CopyStr(Format(CurrentDateTime), 1, 20), MemberShipCard, KioskSetup."Registration Bonus Points", CopyStr(KioskCode, 1, 20));            
            InsertPoints2(KioskSetup."Registration Bonus Points", KioskSetup."Default Kiosk Store No.", KioskCode, CopyStr(Format(CurrentDateTime), 1, 20), CardID, MemberShipCard."Account No.");
            SendSMS(MemberContact."Mobile Phone No.", MemberContact.Name, KioskSetup."Registration Bonus Points", CardID, PIN, KioskSetup.FieldNo("Welcome SMS Template"));
            SendEmail(MemberContact."E-Mail", MemberContact.Name, CardID, PIN, KioskSetup.FieldNo("Welcome Email Template"));
        end else begin
            SendSMS(MemberContact."Mobile Phone No.", MemberContact.Name, KioskSetup."Registration Bonus Points", CardID, PIN, KioskSetup.FieldNo("Update SMS Template"));
            SendEmail(MemberContact."E-Mail", MemberContact.Name, CardID, PIN, KioskSetup.FieldNo("Update Email Template"));
        end;
        //BC Upgrade End;
        exit('');
    end;

    local procedure CreateXmlResponse(NodeName: Text; NodeName2: Text; ErrMsg: Text; ErrMsg2: Text; CardNo: Text; ResultStatus: Text): Text
    var
        SoapBody: XmlElement;
        SoapEnvelope: XmlElement;
        xmlElem2: XmlElement;
        xmlElem3: XmlElement;
        xmlElem4: XmlElement;
        xmlElem5: XmlElement;
        xmlElem6: XmlElement;
        xmlElem: XmlElement;
        XmlDoc: XmlDocument;
        XmlAtr: XmlAttribute;
        NamespacePreix: Text;
        XmlResult: Text;
        CommonNS: Label 'http://tempuri.org/', Locked = true;
        NamespaceUri: label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
        xsdUri: Label 'http://www.w3.org/2001/XMLSchema', Locked = true;
        xsiUri: label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;
        XmlDec: XmlDeclaration;
    begin
        NamespacePreix := 'soap';

        //Create the doc
        xmlDoc := xmlDocument.Create();

        //Add the declaration
        xmlDec := xmlDeclaration.Create('1.0', 'utf-8', 'no');
        xmlDoc.SetDeclaration(xmlDec);

        //Create root node
        SoapEnvelope := XmlElement.Create('Envelope', NamespaceUri);
        XmlAtr := XmlAttribute.CreateNamespaceDeclaration(NamespacePreix, NamespaceUri);
        SoapEnvelope.Add(XmlAtr);

        XmlAtr := XmlAttribute.CreateNamespaceDeclaration('xsi', xsiUri);
        SoapEnvelope.Add(XmlAtr);

        XmlAtr := XmlAttribute.CreateNamespaceDeclaration('xsd', xsdUri);
        SoapEnvelope.Add(XmlAtr);
        SoapBody := XmlElement.Create('Body', NamespaceUri);

        xmlElem := XmlElement.Create(NodeName, CommonNS);

        xmlElem2 := XmlElement.Create(NodeName2, CommonNS);

        xmlElem3 := XmlElement.Create('ErrorMessage', CommonNS);
        xmlElem3.Add(XmlText.Create(ErrMsg));


        xmlElem4 := XmlElement.Create('ErrorMessage2', CommonNS);
        xmlElem4.Add(XmlText.Create(ErrMsg2));


        xmlElem5 := XmlElement.Create('CardNo', CommonNS);
        xmlElem5.Add(XmlText.Create(CardNo));


        xmlElem6 := XmlElement.Create('ResultStatus', CommonNS);
        xmlElem6.Add(XmlText.Create(ResultStatus));


        //Write elements to the doc
        xmlElem2.Add(xmlElem3);
        xmlElem2.Add(xmlElem4);
        xmlElem2.Add(xmlElem5);
        xmlElem2.Add(xmlElem6);
        xmlElem.Add(xmlElem2);
        SoapBody.Add(xmlElem);
        SoapEnvelope.Add(SoapBody);
        //XmlDoc.Add(xmlElem);
        XmlDoc.Add(SoapEnvelope);

        XmlDoc.WriteTo(XmlResult);
        exit(XmlResult);
    end;

    // procedure GetPostCodeAddress(postcode: Text): Text
    // var
    //     PostCodeAddr: Record "eCom_PostOfficeAddress_NT";
    //     TempBlob: Codeunit "Temp Blob";
    //     Instr: InStream;
    //     OutStr: OutStream;
    //     xmlLine: Text;
    //     TxtBuilder: TextBuilder;
    // begin
    //     TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
    //     PostCodeAddr.SetRange("Postal Code", postcode);
    //     Xmlport.Export(Xmlport::eCom_PostOfficeAddress_NT, OutStr, PostCodeAddr);
    //     TempBlob.CreateInStream(Instr);
    //     while not InStr.EOS do begin
    //         instr.Read(xmlLine);
    //         TxtBuilder.Append(xmlLine);
    //     end;
    //     exit(TxtBuilder.ToText());
    // end;
    procedure GetPostCodeAddress(postcode: Text; var PostCodeAddressXML: XmlPort Kiosk_PostOfficeAddress_NT)
    var
        PostCodeAddr: Record "eCom_PostOfficeAddress_NT";
        TempBlob: Codeunit "Temp Blob";
        Instr: InStream;
        OutStr: OutStream;
        xmlLine: Text;
        TxtBuilder: TextBuilder;

    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        PostCodeAddr.SetRange("Postal Code", postcode);
        PostCodeAddressXML.SetTableView(PostCodeAddr);
        PostCodeAddressXML.Export();
    end;

    procedure GetPostCodes(var GetPostCodesResponse: XmlPort Kiosk_GetPostCodes_NT)
    begin
        GetPostCodesResponse.SetUniquePostalCodes();
        GetPostCodesResponse.Export();
    end;

    procedure PostBonusPointEntry(DocNo: Code[20]; MemberCard: Record "LSC Membership Card"; BonusPoints: Integer; StoreNo: Code[20]): Boolean
    var
        MemberClub: Record "LSC Member Club";
        MemberPointJnlLine: Record "LSC Member Point Jnl. Line";
        PointJnlPostLine: Codeunit "LSC Point Jnl.-Post Line";
    begin
        IF BonusPoints = 0 THEN
            EXIT;

        MemberClub.GET(MemberCard."Club Code");
        MemberPointJnlLine.INIT;
        MemberPointJnlLine.Type := MemberPointJnlLine.Type::"Pos. Adjustment";
        MemberPointJnlLine.Date := Today;
        MemberPointJnlLine."Source Type" := MemberPointJnlLine."Source Type"::Journal;
        MemberPointJnlLine."Document No." := DocNo;
        MemberPointJnlLine."Account No." := MemberCard."Account No.";
        MemberPointJnlLine."Contact No" := MemberCard."Contact No.";
        MemberPointJnlLine."Card No." := MemberCard."Card No.";
        MemberPointJnlLine."Point Type" := MemberPointJnlLine."Point Type"::"Award Points";
        MemberPointJnlLine.Points := BonusPoints;
        MemberPointJnlLine."Point Value" := MemberClub."Point Value";
        MemberPointJnlLine."Total Value" := MemberPointJnlLine.Points * MemberPointJnlLine."Point Value";
        MemberPointJnlLine."Source Type" := MemberPointJnlLine."Source Type"::"Sales Invoice";
        MemberPointJnlLine."Store No." := StoreNo;
        MemberPointJnlLine."POS Terminal No." := '';
        MemberPointJnlLine."Transaction No." := 0;
        //PointJnlPostLine.RunWithCheck(MemberPointJnlLine);//BC22 Upgrade
        PointJnlPostLine.Run(MemberPointJnlLine);//BC22 Upgrade
        EXIT(TRUE);
    end;

    local procedure SendEmail(Email: Text[80]; ContName: Code[20]; CardNo: Text[100]; PIN: Text[4]; FieldNo: Integer): Boolean
    var
        KioskSetup: Record "Kiosk Setup_NT";
        eComGenFn: Codeunit "eCom_General Functions_NT";
        InS: InStream;
        TemplateTxt: Text;
        TxtBuilder: TextBuilder;
    begin
        if not KioskSetup.Get() then
            exit(false);
        case FieldNo of
            kiosksetup.FieldNo("Welcome Email Template"):
                begin
                    KioskSetup.CalcFields("Welcome Email Template");
                    if not KioskSetup."Welcome Email Template".HasValue then
                        exit(false);
                    KioskSetup."Welcome Email Template".CreateInStream(InS, TextEncoding::UTF8);
                    while not Ins.EOS do begin
                        Ins.Read(TemplateTxt);
                        TxtBuilder.Append(TemplateTxt);
                    end;
                    TxtBuilder.Replace('%NAME%', ContName);
                    TxtBuilder.Replace('%BONUSPOINTS%', Format(KioskSetup."Registration Bonus Points"));
                    TxtBuilder.Replace('%CARDNO%', CardNo);
                    TxtBuilder.Replace('%PIN%', PIN);
                    exit(eComGenFn.SendEmail(Email, TxtBuilder.ToText()) = '');
                end;
            kiosksetup.FieldNo("Change PIN Email Template"):
                begin
                    KioskSetup.CalcFields("Change PIN Email Template");
                    if not KioskSetup."Change PIN Email Template".HasValue then
                        exit(false);
                    KioskSetup."Change PIN Email Template".CreateInStream(InS, TextEncoding::UTF8);
                    while not Ins.EOS do begin
                        Ins.Read(TemplateTxt);
                        TxtBuilder.Append(TemplateTxt);
                    end;
                    TxtBuilder.Replace('%NAME%', ContName);
                    TxtBuilder.Replace('%PIN%', PIN);
                    exit(eComGenFn.SendEmail(Email, TxtBuilder.ToText()) = '');
                end;
            kiosksetup.FieldNo("Update Email Template"):
                begin
                    KioskSetup.CalcFields("Update Email Template");
                    if not KioskSetup."Update Email Template".HasValue then
                        exit(false);
                    KioskSetup."Update Email Template".CreateInStream(InS, TextEncoding::UTF8);
                    while not Ins.EOS do begin
                        Ins.Read(TemplateTxt);
                        TxtBuilder.Append(TemplateTxt);
                    end;
                    TxtBuilder.Replace('%NAME%', ContName);
                    TxtBuilder.Replace('%PIN%', PIN);
                    exit(eComGenFn.SendEmail(Email, TxtBuilder.ToText()) = '');
                end;
        end;
        exit(false);
    end;

    procedure DoLogin(CardNo: Text; PIN: Text; var DoLoginXML: XmlPort kiosk_DoLoginResponse_NT)
    var
        MemberCard: Record "LSC Membership Card";
        MemberContact: Record "LSC Member Contact";
        MemberContactOk: Boolean;
        PINOk: Boolean;
        XMLNodeValues: array[6] of Text[100];
    begin
        XMLNodeValues[1] := 'false';//AddressConfirmed
        XMLNodeValues[2] := 'false';//ContactFound
        XMLNodeValues[3] := 'false';//EnteredCardNo
        XMLNodeValues[4] := 'true';//InvalidPinVal
        XMLNodeValues[5] := 'false';//LoginSuccess
        XMLNodeValues[6] := 'false';//PinOKVal

        MemberContactOk := GetMemberContact(CardNo, MemberContact);

        if MemberContactOk then
            PINOk := (MemberContact."Kiosk Pin" = PIN);

        if MemberContactOk then begin
            if MemberContact."Address Confirmed" then
                XMLNodeValues[1] := 'true' //AddressConfirmed
            else
                XMLNodeValues[1] := 'false';//AddressConfirmed
            XMLNodeValues[2] := 'true';//ContactFound
        end;
        XMLNodeValues[3] := CardNo; //CardNo
        if PINOk then begin
            XMLNodeValues[4] := 'false';//InvalidPinVal            
            XMLNodeValues[6] := 'true';//PinOKVal
        end;

        if (MemberContactOk and PINOk) then begin
            XMLNodeValues[5] := 'true';//LoginSuccess
            DoLoginXML.SetAccountInfo(MemberContact."Account No.", MemberContact."Contact No.", XMLNodeValues);
            DoLoginXML.Export();
        end else begin
            XMLNodeValues[5] := 'false';//LoginSuccess
            DoLoginXML.SetAccountInfo('', '', XMLNodeValues);
            DoLoginXML.Export();
        end;
    end;

    local procedure SendSMS(MobilePhone: Text[80]; ContName: Text[80]; BonusPoints: Integer; CardNo: Text[80]; PIN: Text[4]; FieldNo: Integer): Boolean
    var
        KioskSetup: Record "Kiosk Setup_NT";
        eComMemberFN: Codeunit "eCom_Member Functions_NT";
        InS: InStream;
        TemplateTxt: Text;
        TxtBuilder: TextBuilder;
    begin
        if not KioskSetup.Get() then
            exit(false);
        case FieldNo of
            KioskSetup.FieldNo("Welcome SMS Template"):
                begin
                    KioskSetup.CalcFields("Welcome SMS Template");
                    if KioskSetup."Welcome SMS Template".HasValue then begin
                        KioskSetup."Welcome SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                        while not Ins.EOS do begin
                            Ins.Read(TemplateTxt);
                            TxtBuilder.Append(TemplateTxt);
                        end;
                        TxtBuilder.Replace('%NAME%', ContName);
                        TxtBuilder.Replace('%BONUSPOINTS%', Format(KioskSetup."Registration Bonus Points"));
                        TxtBuilder.Replace('%CARDNO%', CardNo);
                        TxtBuilder.Replace('%PIN%', PIN);
                        exit(eComMemberFN.SendSMS_CS(MobilePhone, TxtBuilder.ToText()) = '');
                    end;
                end;
            KioskSetup.FieldNo(KioskSetup."Change PIN SMS Template"):
                begin
                    KioskSetup.CalcFields("Change PIN SMS Template");
                    if KioskSetup."Change PIN SMS Template".HasValue then begin
                        KioskSetup."Change PIN SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                        while not Ins.EOS do begin
                            Ins.Read(TemplateTxt);
                            TxtBuilder.Append(TemplateTxt);
                        end;
                        TxtBuilder.Replace('%NAME%', ContName);
                        TxtBuilder.Replace('%PIN%', PIN);
                        exit(eComMemberFN.SendSMS_CS(MobilePhone, TxtBuilder.ToText()) = '');
                    end;
                end;
            KioskSetup.FieldNo(KioskSetup."Update SMS Template"):
                begin
                    KioskSetup.CalcFields("Update SMS Template");
                    if KioskSetup."Update SMS Template".HasValue then begin
                        KioskSetup."Update SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                        while not Ins.EOS do begin
                            Ins.Read(TemplateTxt);
                            TxtBuilder.Append(TemplateTxt);
                        end;
                        TxtBuilder.Replace('%NAME%', ContName);
                        TxtBuilder.Replace('%PIN%', PIN);
                        exit(eComMemberFN.SendSMS_CS(MobilePhone, TxtBuilder.ToText()) = '');
                    end;
                end;
        end;
        exit(false);
    end;

    procedure NewRandomPIN(CardNo: Text; var NewRandomPINXML: XmlPort "kiosk_New Random PIN_NT")
    var
        KioskSetup: Record "Kiosk Setup_NT";
        MemberCard: Record "LSC Membership Card";
        MemberContact: Record "LSC Member Contact";
        CardOk: Boolean;
        MemberContactOk: Boolean;
        PINOk: Boolean;
        RandNum: Integer;
        ChangeSuccessVal: Text[5];
        ContactFoundVal: Text[5];
        InValidPINVal: Text[5];
        NewPin: Text[4];
        SMSSentVal: Text[5];
        XMLNodeValues: array[4] of Text[100];
    begin
        XMLNodeValues[1] := 'false';//ChangeSuccess
        XMLNodeValues[2] := 'false';//ContactFound
        XMLNodeValues[3] := 'false';//InvalidPin
        XMLNodeValues[4] := 'false';//SMSSent        

        // CardOk := MemberCard.Get(CardNo);

        // if CardOk then
        //     MemberContactOk := MemberContact.get(MemberCard."Account No.", MemberCard."Contact No.");
        MemberContactOk := GetMemberContact(CardNo, MemberContact);
        if MemberContactOk then begin
            Randomize();
            RandNum := Random(9999);
            NewPin := Format(RandNum);
            if StrLen(NewPin) = 1 then
                RandNum := RandNum * 1000;

            if StrLen(NewPin) = 2 then
                RandNum := RandNum * 100;

            if StrLen(NewPin) = 3 then
                RandNum := RandNum * 10;

            NewPin := Format(RandNum);


            XMLNodeValues[2] := 'true';//ContactFound
            MemberContact."Kiosk Pin" := NewPin;
            if MemberContact.Modify() then begin
                if MemberContact."Mobile Phone No." <> '' then begin
                    SendSMS(MemberContact."Mobile Phone No.", MemberContact.Name, 0, CardNo, NewPin, KioskSetup.FieldNo("Change PIN SMS Template"));

                    if MemberContact."E-Mail" <> '' then
                        SendEmail(MemberContact."E-Mail", MemberContact.Name, CardNo, NewPin, KioskSetup.FieldNo("Change PIN Email Template"));
                    XMLNodeValues[4] := 'true';//EmailSent                     
                end;
                XMLNodeValues[1] := 'true';//ChangeSuccess
            end;
        end;
        NewRandomPINXML.SetResponseValues(XMLNodeValues[1], XMLNodeValues[2], XMLNodeValues[3], XMLNodeValues[4], NewPin);

    end;

    local procedure GetMemberContact(var CardNo: text; var MemberContact: Record "LSC Member Contact"): Boolean
    var
        MemberCard: Record "LSC Membership Card";
        CardOk: Boolean;
        MemberContactFound: Boolean;
    begin

        MemberContact.SetFilter("Contact No.", CardNo);
        CardOk := MemberContact.FindFirst();
        MemberContactFound := CardOk;

        if not CardOk then
            CardOk := MemberCard.Get(CardNo);

        if CardOk then
            if not MemberContactFound then
                MemberContactFound := MemberContact.get(MemberCard."Account No.", MemberCard."Contact No.");

        if not CardOk then begin
            MemberContact.Reset();
            MemberContact.SetCurrentKey("Mobile Phone No.");
            MemberContact.SetFilter("Mobile Phone No.", '%1', CardNo);
            MemberContactFound := MemberContact.FindFirst();
            CardOk := MemberContactFound;
            if not MemberContactFound then begin
                MemberContact.Reset();
                MemberContact.SETCURRENTKEY("Phone No.");
                MemberContact.SETFILTER("Phone No.", '%1', CardNo);
                MemberContactFound := MemberContact.FindFirst();
                CardOk := MemberContactFound;
            end;
            if not MemberContactFound then begin
                MemberContact.Reset();
                MemberContact.SETCURRENTKEY("Search E-Mail");
                MemberContact.SETFILTER("Search E-Mail", '%1', CardNo);
                MemberContactFound := MemberContact.FindFirst();
                CardOk := MemberContactFound;
            end;
            if MemberContactFound then begin
                MemberCard.SetCurrentKey("Account No.", "Contact No.");
                MemberCard.SetFilter("Account No.", MemberContact."Account No.");
                MemberCard.SetFilter("Contact No.", MemberContact."Contact No.");
                if MemberCard.FindFirst() then
                    CardNo := MemberCard."Card No.";
            end;
        end;
        exit(MemberContactFound);
    end;

    procedure GetActiveItems(City: Integer; var GetActiveItemsXML: XmlPort "Kiosk_Get Active Items_NT")
    begin
        GetActiveItemsXML.SetValues(City);
        GetActiveItemsXML.Export();
    end;

    procedure CreateVoucher(CardNo: Text; Category: Text; SubCategory: Text; ItemNo: Text; UserID: Text; SupplierID: Text; var CreateVoucherXML: XmlPort "Create Voucher_XMLResponse_NT")
    var
        CouponHeader: Record "LSC Coupon Header";
        KioskRedemCategory: Record "Kiosk Redemption Header_NT";
        KioskRedemLine: Record "Kiosk Redemption Line_NT";
        KioskRedemSubCat: Record "Kiosk Redem. Subcategory_NT";
        KioskSetup: Record "Kiosk Setup_NT";
        MemberContact: Record "LSC Member Contact";
        MemberShipCard: Record "LSC Membership Card";
        CouponManagement: Codeunit "LSC Coupon Management";
        eComGenFN: Codeunit "eCom_General Functions_NT";
        eComMemberFn: Codeunit "eCom_Member Functions_NT";
        PointBalance: BigInteger;
        BarcodeNo: Code[22];
        CardID: Text[100];
        ErrorMsg: Text[1000];
        XMLResult: array[10] of Text;
    begin
        XMLResult[1] := 'false';//Success
        XMLResult[2] := '';//VoucherNo
        XMLResult[3] := '0';//VoucherStatus
        XMLResult[4] := '';//Error
        XMLResult[5] := '';//Error2
        XMLResult[6] := '';//Owner
        XMLResult[7] := '';//RedemptionDate
        XMLResult[8] := '';//RedemedByCompany
        XMLResult[9] := '';//ItemDescription
        XMLResult[10] := '';//RedemedByStore

        if not GetMemberContact(CardNo, MemberContact) then
            XMLResult[4] := ErrCard;

        if XMLResult[4] = '' then
            if not KioskRedemCategory.Get(Category) then
                XMLResult[4] := ErrCategory;

        if XMLResult[4] = '' then
            if not KioskRedemSubCat.Get(Category, SubCategory) then
                XMLResult[4] := ErrSubCategory;

        if XMLResult[4] = '' then begin
            KioskRedemLine.SetFilter(Category, Category);
            KioskRedemLine.SetFilter("Sub Category", SubCategory);
            KioskRedemLine.SetFilter("Item No.", ItemNo);
            if not KioskRedemLine.FindFirst() then
                XMLResult[4] := ErrItemNotFound;
        end;
        if XMLResult[4] = '' then
            if UserID = '' then
                XMLResult[4] := ErrUserND;

        if XMLResult[4] = '' then
            if SupplierID = '' then
                XMLResult[4] := ErrSupplierND;

        if XMLResult[4] = '' then begin
            PointBalance := eComMemberFn.GetMemberPoints_CS(MemberContact."Contact No.");

            if ((PointBalance <= 0) or (PointBalance - KioskRedemLine.Points < 0)) then
                XMLResult[4] := ErrPoints;
        end;
        if XMLResult[4] = '' then
            if not KioskSetup.Get() then
                XMLResult[4] := StrSubstNo(ErrKiosk, KioskSetup.TableCaption);

        if XMLResult[4] = '' then
            if KioskRedemLine."Coupon No." = '' then
                XMLResult[4] := StrSubstNo(ErrCoupon, KioskRedemLine.FieldCaption("Coupon No."), ItemNo);

        if XMLResult[4] = '' then
            if not CouponHeader.Get(KioskRedemLine."Coupon No.") then
                XMLResult[4] := StrSubstNo(ErrCouponNF, KioskRedemLine."Coupon No.");

        if XMLResult[4] = '' then
            if CouponHeader."Barcode Mask" = '' then
                XMLResult[4] := StrSubstNo(ErrCouponBMNF, CouponHeader.FieldCaption("Barcode Mask"), CouponHeader.Code);

        //Check mask
        if XMLResult[4] = '' then begin
            ErrorMsg := CouponManagement.CheckBarcodeMask(CouponHeader."Barcode Mask", CouponHeader."Coupon Reference No.",
                          CouponHeader."Coupon Issuer", CouponHeader."First Valid Date Formula", CouponHeader."Last Valid Date Formula",
                          CouponHeader."Barcode Element 1".AsInteger(), CouponHeader."Barcode Element 2".AsInteger(),
                          CouponHeader."Barcode Element 3".AsInteger(), CouponHeader."Barcode Element 4".AsInteger(), CouponHeader."Barcode Element 5".AsInteger(), CouponHeader."Barcode Element 6".AsInteger(), CouponHeader."Barcode Element 7".AsInteger(), CouponHeader."Barcode Element 8".AsInteger());

            if ErrorMsg <> '' then
                XMLResult[4] := Text003 + ' ' + ErrorMsg + ' ' + Text004;
        end;

        //CreateCoupon
        if XMLResult[4] = '' then
            XMLResult[4] := eComGenFN.IssueCouponLS(CouponHeader, BarcodeNo);
        //Insert Redemption And Coupn Entry    
        if XMLResult[4] = '' then begin
            MemberShipCard.SETCURRENTKEY("Account No.", "Contact No.", Status);
            MemberShipCard.SETRANGE(MemberShipCard."Account No.", MemberContact."Account No.");
            MemberShipCard.SETRANGE(MemberShipCard."Contact No.", MemberContact."Contact No.");
            IF MemberShipCard.FINDLAST THEN
                CardID := MemberShipCard."Card No.";
            XMLResult[4] := Web_Process_Redemption(CardID, UserID, BarcodeNo, Category, SubCategory, ItemNo, true);
        end;
        if XMLResult[4] = '' then begin
            XMLResult[1] := 'true';//Success
            XMLResult[2] := BarcodeNo;//VoucherNo            
            XMLResult[4] := '';//Error
            if MemberContact."Mobile Phone No." <> '' then
                SendSMSEmail_Voucher(MemberContact."Mobile Phone No.", BarcodeNo, KioskRedemLine."Item No.", KioskRedemLine.Description, format(KioskRedemLine.Points, 0, 1), KioskSetup.FieldNo("Voucher SMS Template"));

            if MemberContact."E-Mail" <> '' then
                SendSMSEmail_Voucher(MemberContact."E-Mail", BarcodeNo, KioskRedemLine."Item No.", KioskRedemLine.Description, format(KioskRedemLine.Points, 0, 1), KioskSetup.FieldNo("Voucher Email Template"));
        end;
        CreateVoucherXML.SetResponseValues(XMLResult[1], XMLResult[2], XMLResult[3], XMLResult[4]);
        CreateVoucherXML.Export();
    end;


    procedure Web_Process_Redemption(CardNo: Code[20]; KioskID: Code[20]; VoucherNo: Code[20]; CategoryCode: Code[20]; SubCategoryCode: Code[20]; ItemNo: Code[20]; DirectPost: Boolean): Text
    var
        CouponEntry2: Record "LSC Coupon Entry";
        CouponEntry: Record "LSC Coupon Entry";
        CouponHeader: Record "LSC Coupon Header";
        Kiosk: Record "Kiosk_NT";
        KioskLoyaltyPointsTrans2: Record "Kiosk Loyalty Points Trans._NT";
        KioskLoyaltyPointsTrans: Record "Kiosk Loyalty Points Trans._NT";
        KioskRedemptionLine: Record "Kiosk Redemption Line_NT";
        KioskSetup: Record "Kiosk Setup_NT";
        MemberAccount: Record "LSC Member Account";
        MemberContact: Record "LSC Member Contact";
        MembershipCard: Record "LSC Membership Card";
        RedemptionVoucher2: Record "Redemption Voucher_NT";
        RedemptionVoucher: Record "Redemption Voucher_NT";
    begin
        if not KioskSetup.Get() then
            Clear(KioskSetup);
        MembershipCard.GET(CardNo);
        MemberAccount.GET(MembershipCard."Account No.");
        MemberContact.GET(MembershipCard."Account No.", MembershipCard."Contact No.");
        KioskRedemptionLine.SETRANGE(Category, CategoryCode);
        KioskRedemptionLine.SETRANGE("Sub Category", SubCategoryCode);
        KioskRedemptionLine.SETRANGE("Item No.", ItemNo);
        KioskRedemptionLine.FINDFIRST;

        CouponHeader.GET(KioskRedemptionLine."Coupon No.");
        //BC Upgrade Start

        Kiosk.SETRANGE("IP Address", KioskID);
        IF NOT Kiosk.FINDFIRST THEN
            CLEAR(Kiosk);

        // IF DirectPost THEN
        //     IF KioskRedemptionLine.Points > 0 then
        //         IF NOT InsertPoints(-KioskRedemptionLine.Points, Kiosk."Kiosk Store", Kiosk."Terminal No.", VoucherNo) THEN
        //             EXIT('Unable to process request');
        //BC Upgrade - Commented as Isertpoints was calling InsertPoint2 in NAV. InsertPoint2 was called directly in BC 

        //if not InsertPoints2(-KioskRedemptionLine.Points, KioskSetup."Default Kiosk Store No.", KioskID, VoucherNo, MembershipCard."Card No.", MemberContact."Account No.") then
        if not InsertPoints2(-KioskRedemptionLine.Points, Kiosk."Kiosk Store", Kiosk."Terminal No.", VoucherNo, MembershipCard."Card No.", MemberContact."Account No.") then
            exit('Unable to process request');
        //BC Upgrade End
        KioskLoyaltyPointsTrans2.LOCKTABLE;
        IF NOT KioskLoyaltyPointsTrans2.FINDLAST THEN
            CLEAR(KioskLoyaltyPointsTrans2);
        //BC Upgrade Start    

         CouponEntry2.SETRANGE("Store No.", Kiosk."Kiosk Store");
         CouponEntry2.SETRANGE("POS Terminal No.", Kiosk."Terminal No.");

        //Below 2 lines Commented 12.02.24 as Kiosk is required to Identify Store & Terminal from where Voucher is redeemed.        
        //CouponEntry2.SETRANGE("Store No.", KioskSetup."Default Kiosk Store No.");
        //CouponEntry2.SETRANGE("POS Terminal No.", KioskID);

        //BC Upgrade End

        CouponEntry2.SETRANGE("Transaction No.", 1);
        CouponEntry2.SETRANGE("Coupon Code", CouponHeader.Code);
        IF NOT CouponEntry2.FINDLAST THEN
            CLEAR(CouponEntry2);

        RedemptionVoucher2.LOCKTABLE;
        IF NOT RedemptionVoucher2.FINDLAST THEN
            CLEAR(RedemptionVoucher2);

        CLEAR(KioskLoyaltyPointsTrans);
        KioskLoyaltyPointsTrans."Card No." := CardNo;
        KioskLoyaltyPointsTrans."Contact No." := MemberContact."Contact No.";
        KioskLoyaltyPointsTrans."Date Of Issue" := TODAY;
        KioskLoyaltyPointsTrans."Entry No." := KioskLoyaltyPointsTrans2."Entry No." + 1;
        KioskLoyaltyPointsTrans."Entry Type" := KioskLoyaltyPointsTrans."Entry Type"::Payment;
        KioskLoyaltyPointsTrans."Item-Catalogue Ref. Item No." := ItemNo;
        KioskLoyaltyPointsTrans."Item-Catalogue Ref. No." := CategoryCode;
        KioskLoyaltyPointsTrans."Line No." := 10000;
        KioskLoyaltyPointsTrans.Points := -KioskRedemptionLine.Points;

        //BC Upgrade Start

         KioskLoyaltyPointsTrans."Store No." := Kiosk."Kiosk Store";
         KioskLoyaltyPointsTrans."POS Terminal No." := Kiosk."Terminal No.";
        //Below 2 lines Commented 12.02.24 as Kiosk is required to Identify Store & Terminal from where Voucher is redeemed.        
        //KioskLoyaltyPointsTrans."Store No." := KioskSetup."Default Kiosk Store No.";
        //KioskLoyaltyPointsTrans."POS Terminal No." := KioskID;

        //BC Upgrade End

        KioskLoyaltyPointsTrans."Receipt No." := VoucherNo;
        KioskLoyaltyPointsTrans."Transaction No." := 1;
        KioskLoyaltyPointsTrans.Processed := DirectPost;
        KioskLoyaltyPointsTrans.Insert();

        CLEAR(RedemptionVoucher);
        RedemptionVoucher."Entry No." := RedemptionVoucher2."Entry No." + 1;
        RedemptionVoucher."Voucher No." := VoucherNo;
        RedemptionVoucher."Created by" := KioskID;
        RedemptionVoucher."Creation Date" := TODAY;
        RedemptionVoucher."Creation Time" := CREATEDATETIME(TODAY, TIME);
        RedemptionVoucher."Loyalty Card No." := CardNo;
        //BC Upgrade Start
        //RedemptionVoucher."Supplier ID" := 'ALPHAMEGA';
        RedemptionVoucher."Supplier ID" := KioskSetup."Default Supplier ID";
        //BC Upgrade end
        RedemptionVoucher.Category := CategoryCode;
        RedemptionVoucher."Item No." := ItemNo;
        RedemptionVoucher."Item Description" := KioskRedemptionLine.Description;
        RedemptionVoucher.Points := KioskRedemptionLine.Points;
        RedemptionVoucher.INSERT;

        CLEAR(CouponEntry);
        CouponEntry.Barcode := VoucherNo;
        CouponEntry."Coupon Code" := CouponHeader.Code;
        CouponEntry."Coupon Function" := CouponEntry."Coupon Function"::Issue;
        CouponEntry."Coupon No." := FORMAT(CouponEntry2."Line No." + 1);
        CouponEntry."Coupon Reference No." := CouponHeader."Coupon Reference No.";
        CouponEntry."Issue Date" := TODAY;

        //BC Upgrade Start

         CouponEntry."Issued by POS Terminal" := Kiosk."Terminal No.";
         CouponEntry."Issued by Store" := Kiosk."Kiosk Store";
         //Below 2 lines Commented 12.02.24 as Kiosk is required to Identify Store & Terminal from where Voucher is redeemed.        
        //CouponEntry."Issued by POS Terminal" := KioskID;
        //CouponEntry."Issued by Store" := KioskSetup."Default Kiosk Store No.";

        //BC Upgrade End

        CouponEntry."Issued by User" := KioskID;
        CouponEntry."Line No." := CouponEntry2."Line No." + 1;

        //BC Upgrade Start

        CouponEntry."POS Terminal No." := Kiosk."Terminal No.";
        CouponEntry."Store No." := Kiosk."Kiosk Store";
        
        //Below 2 lines Commented 12.02.24 as Kiosk is required to Identify Store & Terminal from where Voucher is redeemed.        
        // CouponEntry."Store No." := KioskSetup."Default Kiosk Store No.";
        // CouponEntry."POS Terminal No." := KioskID;

        //BC Upgrade End

        CouponEntry."Sequence No." := 1;
        CouponEntry."Transaction No." := 1;
        CouponEntry."Value Type" := CouponEntry."Value Type"::Triggering;
        CouponEntry.Insert();
        exit('');
    end;

    local procedure InsertPoints2(Points: Decimal; StoreNo: Code[20]; POSTermNo: Code[20]; DocNo: Code[20]; CardNo: Text[100]; AccNo: Code[20]): Boolean
    var
        MemProcOrderEntry: Record "LSC Member Process Order Entry";
        NextTransNo: Integer;
    begin
        IF StrLen(StoreNo) > 10 THEN
            StoreNo := COPYSTR(StoreNo, 1, 10);
        CLEAR(MemProcOrderEntry);

        //BC Upgrade Start
        //MemProcOrderEntry.SETRANGE("Document Source", MemProcOrderEntry."Document Source"::Kiosk);
        MemProcOrderEntry.SetRange("Document Source", MemProcOrderEntry."Document Source"::POS);
        //BC Upgrade End
        MemProcOrderEntry.SetRange("Store No.", StoreNo);
        MemProcOrderEntry.SetRange("POS Terminal No.", POSTermNo);
        IF MemProcOrderEntry.FindLast() THEN
            NextTransNo := MemProcOrderEntry."Transaction No.";

        NextTransNo += 1;

        Clear(MemProcOrderEntry);
        //BC Upgrade Start
        //MemProcOrderEntry."Document Source" := MemProcOrderEntry."Document Source"::Kiosk;
        MemProcOrderEntry."Document Source" := MemProcOrderEntry."Document Source"::POS;
        //BC Upgrade End
        MemProcOrderEntry."Store No." := StoreNo;
        MemProcOrderEntry."POS Terminal No." := POSTermNo;
        MemProcOrderEntry."Transaction No." := NextTransNo;
        MemProcOrderEntry.Date := TODAY;
        MemProcOrderEntry.Time := TIME;
        // MemProcOrderEntry."Card No." := MembershipCard."Card No.";
        // MemProcOrderEntry."Account No." := MembershipCard."Account No.";

        MemProcOrderEntry."Card No." := CardNo;
        MemProcOrderEntry."Account No." := AccNo;
        MemProcOrderEntry."Points in Transaction" := Points;
        IF DocNo <> '' THEN
            MemProcOrderEntry."Document No." := DocNo;

        exit(MemProcOrderEntry.Insert());
    end;

    local procedure SendSMSEmail_Voucher(MobilePhoneEmail: Text[80]; VchNo: Text[80]; ItemNo: Code[20]; ItemDescription: Text; PointsRedemed: Text[50]; FieldNo: Integer): Boolean
    var
        KioskSetup: Record "Kiosk Setup_NT";
        eComGenFn: Codeunit "eCom_General Functions_NT";
        eComMemberFN: Codeunit "eCom_Member Functions_NT";
        InS: InStream;
        TemplateTxt: Text;
        TxtBuilder: TextBuilder;
    begin
        if not KioskSetup.Get() then
            exit(false);
        case FieldNo of
            KioskSetup.FieldNo("Voucher SMS Template"):
                begin
                    KioskSetup.CalcFields("Voucher SMS Template");
                    if KioskSetup."Voucher SMS Template".HasValue then begin
                        KioskSetup."Voucher SMS Template".CreateInStream(InS, TextEncoding::UTF8);
                        while not Ins.EOS do begin
                            Ins.Read(TemplateTxt);
                            TxtBuilder.Append(TemplateTxt);
                        end;
                        TxtBuilder.Replace('%VOUCHERNO%', VchNo);
                        TxtBuilder.Replace('%BONUSPOINTS%', Format(KioskSetup."Registration Bonus Points"));
                        TxtBuilder.Replace('%ITEMNO%', ItemNo);
                        TxtBuilder.Replace('%DESCRIPTION%', ItemDescription);
                        TxtBuilder.Replace('%POINTSREDEEMED%', PointsRedemed);
                        exit(eComMemberFN.SendSMS_CS(MobilePhoneEmail, TxtBuilder.ToText()) = '');
                    end;
                end;
            KioskSetup.FieldNo("Voucher Email Template"):
                begin
                    KioskSetup.CalcFields("Voucher Email Template");
                    if KioskSetup."Voucher Email Template".HasValue then begin
                        KioskSetup."Voucher Email Template".CreateInStream(InS, TextEncoding::UTF8);
                        while not Ins.EOS do begin
                            Ins.Read(TemplateTxt);
                            TxtBuilder.Append(TemplateTxt);
                        end;
                        TxtBuilder.Replace('%VOUCHERNO%', VchNo);
                        TxtBuilder.Replace('%BONUSPOINTS%', Format(KioskSetup."Registration Bonus Points"));
                        TxtBuilder.Replace('%ITEMNO%', ItemNo);
                        TxtBuilder.Replace('%DESCRIPTION%', ItemDescription);
                        TxtBuilder.Replace('%POINTSREDEEMED%', PointsRedemed);
                        //exit(eComMemberFN.SendSMS_CS(MobilePhone, TxtBuilder.ToText()) = '');
                        exit(eComGenFn.SendEmail(MobilePhoneEmail, TxtBuilder.ToText()) = '');
                    end;
                end;
        end;
        exit(false);
    end;

    var
        ErrCard: Label 'Card not found.';
        ErrCategory: label 'Category not defined.';
        ErrCoupon: label '%1 missing from Item %2';
        ErrCouponBMNF: Label 'The %1 must be filled out for %2';
        ErrCouponNF: label 'Coupon %1 not found';
        ErrItemNotFound: Label 'Item not defined.';
        ErrKiosk: Label '%1 not found';
        ErrPoints: Label 'Insufficient Points';
        ErrSubCategory: Label 'Sub Category not defined.';
        ErrSupplierND: Label 'Supplier ID not defined.';
        ErrUserND: Label 'User ID not defined.';
        GDPRLevelError: Label 'Invalid value in GDPR Level';
        PinError: Label 'Invalid Pin';
        Text001: Label '%1 %2 is used by another Contact.';
        Text002: Label '%1 is missing from %2 for new registration';
        Text003: Label 'Barcode Mask is NOT correctly constructed.';
        Text004: Label 'You can not issue coupons if the Barcode Mask is not constructed according to the Barcode Elements.';
}