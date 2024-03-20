codeunit 60118 MA_MemberContactCreateUtils_NT
{
    trigger OnRun()
    begin
        RunRequest;
    end;

    var
        ContactCreateParametersTemp_g: Record "LSC Contact Create Parameters" temporary;
        MemberAttributeValueTemp_g: Record "LSC Member Attribute Value" temporary;
        SessionKeyValues_g: Codeunit "LSC Session Key Values";
        AccountID_g: Code[20];
        ClubID_g: Code[10];
        ContactID_g: Code[20];
        POSFunctionalityProfileCode_g: Code[10];
        SchemeID_g: Code[10];
        TotalRemainingPoints_g: Decimal;
        CardID_g: Text;
        ErrorText_g: Text;

    local procedure RunRequest()
    var
        MemberAccount: Record "LSC Member Account";
        MemberClub: Record "LSC Member Club";
        MemberContact2: Record "LSC Member Contact";
        MemberContact: Record "LSC Member Contact";
        MemberLogin: Record "LSC Member Login";
        MemberManagementSetup: Record "LSC Member Management Setup";
        MemberScheme: Record "LSC Member Scheme";
        eComGenFN: Codeunit "eCom_General Functions_NT";
        LSExternalFunctionsUtil: Codeunit "LSC External Functions Util";
        MailManagement: Codeunit "Mail Management";
        MemberAttributeManagement: Codeunit "LSC Member Attribute Mgmt";
        MemberCardManagement: Codeunit "LSC Member Card Management";
        Mobileutils: Codeunit "LSC Mobile utils";
        AuthenticatorLogin: Boolean;
        Authorized: Boolean;
        IsHandled: Boolean;
        ManualAccountNumber: Boolean;
        ContactHandlingViolation2: Label '%1 must be the same as %2 or ignored in %3 %4.';
        ContactHandlingViolation: Label 'The Members Club Contact Handling is Contact same as Account, only one contact is allowed for the Account.';
        ContactInfoIsMissingTxt: Label 'Contact information missing.';
        EmailAddressIsInvalid: Label 'Email address is invalid.';
        LoginInfoInvalid: Label 'Login ID or Password invalid.';
        MobileDefaultClubMissing: Label '%1 not found. Check %2.';
        SomethingAlreadyExists: Label '%1 already exists.';
        SomethingForSomethingNotFound: Label '%1 for %2 not found.';
        SomethingIsNotInSomething: Label '%1 is not in %2.';
        SomethingMissing: Label '%1 missing.';
        SomethingNotFound: Label '%1 not found.';
        UnableToInsertError: Label 'Unable to insert in table %1.';
        UnableToModifyError: Label 'Unable to modify in table %1';
    begin
        SelectLatestVersion();
        if ContactCreateParametersTemp_g.IsEmpty then begin
            ErrorText_g := StrSubstNo(ContactInfoIsMissingTxt);
            exit;
        end;

        if (ContactCreateParametersTemp_g.Authenticator = '') or (ContactCreateParametersTemp_g.AuthenticationID = '') then
            if (ContactCreateParametersTemp_g."Login ID" = '') or (ContactCreateParametersTemp_g.Password = '') then begin
                ErrorText_g := LoginInfoInvalid;
                exit;
            end;

        if ContactCreateParametersTemp_g.Email = '' then begin
            ErrorText_g := StrSubstNo(SomethingMissing, ContactCreateParametersTemp_g.FieldCaption(Email));
            exit;
        end;

        if ContactCreateParametersTemp_g.FirstName = '' then begin
            ErrorText_g := StrSubstNo(SomethingMissing, ContactCreateParametersTemp_g.FieldCaption(FirstName));
            exit;
        end;

        if ContactCreateParametersTemp_g.Authenticator <> '' then begin
            AuthenticatorLogin := true;
            ContactCreateParametersTemp_g."Login ID" := CreateMemberLoginID();
            ContactCreateParametersTemp_g.Password := '';
        end;

        //Optional fields and validation
        ClubID_g := ContactCreateParametersTemp_g.ClubID;
        SchemeID_g := ContactCreateParametersTemp_g.SchemeID;
        AccountID_g := ContactCreateParametersTemp_g.AccountID;
        ContactID_g := ContactCreateParametersTemp_g.ContactID;
        if ClubID_g <> '' then begin
            if not MemberClub.Get(ClubID_g) then begin
                ErrorText_g := StrSubstNo(SomethingNotFound, MemberClub.TableCaption);
                exit;
            end;
            if SchemeID_g = '' then
                if MemberClub."Default Scheme" <> '' then
                    SchemeID_g := MemberClub."Default Scheme"
                else begin
                    MemberScheme.SetRange("Club Code", ClubID_g);
                    if MemberScheme.FindFirst then
                        SchemeID_g := MemberScheme.Code;
                    MemberScheme.SetRange("Club Code");
                end;
        end;
        if SchemeID_g <> '' then begin
            if not MemberScheme.Get(SchemeID_g) then begin
                ErrorText_g := StrSubstNo(SomethingNotFound, MemberScheme.TableCaption);
                exit;
            end;
            if MemberScheme."Club Code" <> ClubID_g then begin
                ErrorText_g := StrSubstNo(SomethingIsNotInSomething, MemberScheme.TableCaption, MemberClub.TableCaption);
                exit;
            end;
        end;
        if AccountID_g <> '' then
            if MemberAccount.Get(AccountID_g) then begin
                if ClubID_g <> '' then
                    if MemberAccount."Club Code" <> ClubID_g then begin
                        ErrorText_g := StrSubstNo(SomethingIsNotInSomething, MemberAccount.TableCaption, MemberClub.TableCaption);
                        exit;
                    end;
                if not MemberClub.Get(MemberAccount."Club Code") then begin
                    ErrorText_g := StrSubstNo(SomethingForSomethingNotFound, MemberClub.TableCaption, MemberAccount.TableCaption);
                    exit;
                end else begin
                    MemberContact2.SetRange("Account No.", AccountID_g);
                    if not MemberContact2.IsEmpty then
                        if MemberClub."Contact Handling" = MemberClub."Contact Handling"::"Contact same as Account" then begin
                            ErrorText_g := ContactHandlingViolation;
                            exit;
                        end;
                end;
            end else begin
                if (MemberClub."Contact Handling" = MemberClub."Contact Handling"::"Contact same as Account") and
                   (AccountID_g <> ContactID_g) and (ContactID_g <> '')
                then begin
                    ErrorText_g := StrSubstNo(ContactHandlingViolation2, MemberContact.FieldCaption("Contact No."), MemberContact.FieldCaption("Account No."), MemberClub.TableCaption, MemberClub.Code);
                    exit;
                end;
                ManualAccountNumber := true;
            end;
        Authorized := IsAdminUser(ContactCreateParametersTemp_g."Login ID", ContactCreateParametersTemp_g.Password);
        if not Authorized then begin
            if not AuthenticatorLogin then
                if not MemberCardManagement.UserIDValid(ContactCreateParametersTemp_g."Login ID") or not MemberCardManagement.PwdValid(ContactCreateParametersTemp_g.Password) then begin
                    ErrorText_g := LoginInfoInvalid;
                    exit;
                end;

            MemberLogin.Reset;
            MemberLogin.SetRange("Login ID", LowerCase(ContactCreateParametersTemp_g."Login ID"));
            if MemberLogin.FindFirst then begin
                ErrorText_g := StrSubstNo(SomethingAlreadyExists, ContactCreateParametersTemp_g."Login ID");
                exit;
            end;
        end;

        OnBeforeCheckValidEmailAddress(ContactCreateParametersTemp_g.Email, IsHandled);
        if not IsHandled then
            if not MailManagement.CheckValidEmailAddress(ContactCreateParametersTemp_g.Email) then begin
                ErrorText_g := EmailAddressIsInvalid;
                exit;
            end;

        MemberManagementSetup.Get;
        if (AccountID_g = '') or ManualAccountNumber then begin
            //Create Account if AccountID_g is empty or manually entered and not found
            if ClubID_g = '' then
                if not MemberClub.Get(MemberManagementSetup."Mobile Default Club Code") then begin
                    ErrorText_g := StrSubstNo(MobileDefaultClubMissing, MemberManagementSetup.FieldCaption("Mobile Default Club Code"), MemberManagementSetup.TableCaption);
                    exit;
                end;
            Clear(MemberAccount);
            if ManualAccountNumber then
                MemberAccount."No." := AccountID_g
            else
                MemberAccount."No." := '';
            MemberAccount."Club Code" := MemberClub.Code;
            MemberAccount."No. Series" := MemberClub."Account No. Series";
            if ContactCreateParametersTemp_g.MiddleName = '' then
                MemberAccount.Description := CopyStr(ContactCreateParametersTemp_g.FirstName + ' ' + ContactCreateParametersTemp_g.LastName, 1, MaxStrLen(MemberAccount.Description))
            else
                MemberAccount.Description := CopyStr(ContactCreateParametersTemp_g.FirstName + ' ' + ContactCreateParametersTemp_g.MiddleName + ' ' + ContactCreateParametersTemp_g.LastName, 1, MaxStrLen(MemberContact.Name));
            if not MemberAccount.Insert(true) then begin
                ErrorText_g := StrSubstNo(UnableToInsertError, MemberAccount.TableCaption);
                exit;
            end else
                if MemberClub."Contact Handling" = MemberClub."Contact Handling"::"Contact same as Account" then begin
                    //Contact has been created by account insert trigger
                    AccountID_g := MemberAccount."No.";
                    MemberContact.Get(MemberAccount."No.", MemberAccount."No.");
                end else begin
                    //Family or Company
                    Clear(MemberContact);
                    MemberContact."Club Code" := MemberAccount."Club Code";
                    MemberContact."Scheme Code" := MemberAccount."Scheme Code";
                    MemberContact."Account No." := MemberAccount."No.";
                    MemberContact.Validate("Contact No.", ContactID_g);
                    if not MemberContact.Insert(true) then begin
                        ErrorText_g := StrSubstNo(UnableToInsertError, MemberContact.TableCaption);
                        exit;
                    end;
                end;
        end else begin
            //Account supplied - create contact
            Clear(MemberContact);
            MemberContact."Account No." := MemberAccount."No.";
            MemberContact."Club Code" := MemberAccount."Club Code";
            MemberContact."Scheme Code" := MemberAccount."Scheme Code";
            MemberContact.Validate("Contact No.", ContactID_g);
            if not MemberContact.Insert(true) then begin
                ErrorText_g := StrSubstNo(UnableToInsertError, MemberContact.TableCaption);
                exit;
            end;
        end;

        if AccountID_g = '' then
            if SchemeID_g = '' then
                MemberContact."Scheme Code" := MemberClub."Default Scheme"
            else
                MemberContact."Scheme Code" := MemberScheme.Code;
        MemberContact.Address := ContactCreateParametersTemp_g.Address1;
        MemberContact."Address 2" := ContactCreateParametersTemp_g.Address2;
        MemberContact.City := ContactCreateParametersTemp_g.City;
        MemberContact."Post Code" := ContactCreateParametersTemp_g.PostCode;
        MemberContact."E-Mail" := ContactCreateParametersTemp_g.Email;
        MemberContact."Phone No." := ContactCreateParametersTemp_g.Phone;
        MemberContact."Mobile Phone No." := ContactCreateParametersTemp_g.MobilePhoneNo;
        MemberContact.County := ContactCreateParametersTemp_g.StateProvinceRegion;
        MemberContact."Country/Region Code" := ContactCreateParametersTemp_g.Country;
        MemberContact."House/Apartment No." := ContactCreateParametersTemp_g.HouseApartmentNo;
        MemberContact."Territory Code" := ContactCreateParametersTemp_g."Territory Code";
        MemberContact.Gender := ContactCreateParametersTemp_g.Gender;
        MemberContact."External ID" := ContactCreateParametersTemp_g.ExternalID;
        MemberContact."External System" := ContactCreateParametersTemp_g.ExternalSystem;
        MemberContact.Validate("First Name", ContactCreateParametersTemp_g.FirstName);
        MemberContact.Validate("Middle Name", ContactCreateParametersTemp_g.MiddleName);
        MemberContact.Validate(Surname, ContactCreateParametersTemp_g.LastName);
        if ContactCreateParametersTemp_g.MiddleName = '' then
            MemberContact.Validate(Name, CopyStr(ContactCreateParametersTemp_g.FirstName + ' ' + ContactCreateParametersTemp_g.LastName, 1, MaxStrLen(MemberAccount.Description)))
        else
            MemberContact.Validate(Name, CopyStr(ContactCreateParametersTemp_g.FirstName + ' ' + ContactCreateParametersTemp_g.MiddleName + ' ' + ContactCreateParametersTemp_g.LastName, 1, MaxStrLen(MemberContact.Name)));
        MemberContact.Validate("Date of Birth", ContactCreateParametersTemp_g.DateOfBirth);

        if ContactCreateParametersTemp_g."Send Receipt by E-mail" = ContactCreateParametersTemp_g."Send Receipt by E-mail"::" " then
            MemberContact."Send Receipt by E-mail" := MemberManagementSetup."Send Receipt by E-mail"
        else
            MemberContact."Send Receipt by E-mail" := ContactCreateParametersTemp_g."Send Receipt by E-mail";

        OnBeforeContactCreate(MemberContact, ContactCreateParametersTemp_g);

        if not MemberContact.Modify(true) then begin
            ErrorText_g := StrSubstNo(UnableToModifyError, MemberContact);
            exit;
        end;

        if not Authorized then begin
            //Create User
            Clear(MemberLogin);
            MemberLogin."Login ID" := LowerCase(ContactCreateParametersTemp_g."Login ID");
            if AuthenticatorLogin then
                MemberLogin.Password := ''
            else
                MemberLogin.Password := LSExternalFunctionsUtil.Hash(ContactCreateParametersTemp_g.Password);
            if not MemberLogin.Insert(true) then begin
                ErrorText_g := StrSubstNo(UnableToInsertError, MemberLogin);
                exit;
            end;
            if ContactCreateParametersTemp_g.DeviceID <> '' then begin
                Mobileutils.CreateMemberDevice(ContactCreateParametersTemp_g.DeviceID, ContactCreateParametersTemp_g.DeviceFriendlyName, ErrorText_g);
                if ErrorText_g <> '' then
                    exit;
                Mobileutils.CreateMemberLoginDevice(MemberLogin."Login ID", ContactCreateParametersTemp_g.DeviceID, ErrorText_g);
                if ErrorText_g <> '' then
                    exit;
                Mobileutils.MobileCreateMembershipCard(MemberContact, CardID_g, ErrorText_g);
                if ErrorText_g <> '' then
                    exit;
                MemberAccount.Get(MemberContact."Account No.");
                TotalRemainingPoints_g := MemberAccount.TotalRemainingPoints;
                Mobileutils.CreateMemberLoginCard(MemberLogin."Login ID", CardID_g, ErrorText_g);
                if ErrorText_g <> '' then
                    exit;
            end;
        end;
        ClubID_g := MemberContact."Club Code";
        SchemeID_g := MemberContact."Scheme Code";
        AccountID_g := MemberContact."Account No.";
        ContactID_g := MemberContact."Contact No.";
        //Update Attribute Values
        MemberAttributeManagement.MemberAttributeValueUpdate(ErrorText_g, MemberAttributeValueTemp_g, MemberContact);
        if CardID_g <> '' then begin
            eComGenFN.InsertPoints(CardID_g);
            eComGenFN.InsertAttributes(CardID_g);
        end;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure SetRequest(var MemberContactCreateXML: XmlPort LSCMemberContactCreateXML)
    var
        ClientSessionUtility: Codeunit "LSC Client Session Utility";
    begin
        if not ClientSessionUtility.IsLocalRequest then
            MemberContactCreateXML.Import;
        MemberContactCreateXML.GetMemberContact(ContactCreateParametersTemp_g, MemberAttributeValueTemp_g);
    end;

#if __IS_SAAS__
    internal
#endif
    procedure SendRequest(var ResponseCode: Code[30]; var ErrorText: Text; var ContactCreateParametersTemp: Record "LSC Contact Create Parameters" temporary; var MemberAttributeValueTemp: Record "LSC Member Attribute Value" temporary; var ClubID: Code[10]; var SchemeID: Code[10]; var AccountID: Code[20]; var ContactID: Code[20]; var CardID: Text; var TotalRemainingPoints: Decimal)
    var
        WSServerBuffer: Record "LSC WS Server Buffer" temporary;
        MemberContactCreate: Codeunit LSCMemberContactCreate;
        RequestHandler: Codeunit "LSC Request Handler";
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
        MemberContactCreateXML: XmlPort LSCMemberContactCreateXML;
        RequestOk: Boolean;
        ReqDateTime: DateTime;
        LogFileID: Text;
        URIMissingTxt: Label 'Web Server URI is Missing for Request %1';
    begin
        RequestOk := false;
        ReqDateTime := CurrentDateTime;
        LogFileID := WebRequestFunctions.CreateLogFileID(ReqDateTime);
        RequestHandler.GetWebServerList(format(enum::"LSC Web Services"::MemberContactCreate), POSFunctionalityProfileCode_g, WSServerBuffer);
        WSServerBuffer.Reset;
        if WSServerBuffer.FindSet then
            repeat
                if WSServerBuffer."Local Request" then begin
                    Clear(MemberContactCreateXML);
                    MemberContactCreateXML.SetMemberContact(ContactCreateParametersTemp, MemberAttributeValueTemp);
                    MemberContactCreateXML.Export;
                    Commit;
                    SessionKeyValues_g.SetValue('#LOCALREQUEST', 'TRUE');
                    MemberContactCreate.MemberContactCreate(ResponseCode, ErrorText, MemberContactCreateXML, ClubID, SchemeID, AccountID, ContactID, CardID, TotalRemainingPoints);
                    SessionKeyValues_g.SetValue('#LOCALREQUEST', 'FALSE');
                    RequestOk := true;
                    RequestHandler.AddToConnLog(WSServerBuffer."Profile ID", 'Local', 'Local', '');
                end else begin
                    RequestHandler.FindDestURI(format(enum::"LSC Web Services"::MemberContactCreate), WSServerBuffer);
                    WSServerBuffer."Extended Web Service URI" := WebRequestFunctions.ConvertToNewUrl(WSServerBuffer."Extended Web Service URI");
                    WSServerBuffer."Log File ID" := LogFileID;
                    PostMemberContactCreate(WSServerBuffer, ResponseCode, ErrorText, ContactCreateParametersTemp, MemberAttributeValueTemp, ClubID, SchemeID, AccountID, ContactID, CardID, TotalRemainingPoints);
                    if ResponseCode <> '0098' then
                        RequestOk := true;
                    RequestHandler.AddToConnLog(WSServerBuffer."Profile ID", WSServerBuffer."Dist. Location", WSServerBuffer."Extended Web Service URI", ErrorText);
                end;
            until (WSServerBuffer.Next = 0) or RequestOk
        else begin
            ErrorText := StrSubstNo(URIMissingTxt, format(enum::"LSC Web Services"::MemberContactCreate));
            RequestHandler.AddToConnLog('', '', '', ErrorText);
        end;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure GetResponse(var ErrorText: Text; var ClubID: Code[10]; var SchemeID: Code[10]; var AccountID: Code[20]; var ContactID: Code[20]; var CardID: Text; var TotalRemainingPoints: Decimal)
    begin
        ErrorText := ErrorText_g;
        ClubID := ClubID_g;
        SchemeID := SchemeID_g;
        AccountID := AccountID_g;
        ContactID := ContactID_g;
        CardID := CardID_g;
        TotalRemainingPoints := TotalRemainingPoints_g;
    end;

    local procedure PostMemberContactCreate(var WSServerBuffer: Record "LSC WS Server Buffer"; var ResponseCode: Code[30]; var ErrorText: Text; var ContactCreateParametersTemp: Record "LSC Contact Create Parameters" temporary; var MemberAttributeValueTemp: Record "LSC Member Attribute Value" temporary; var ClubID: Code[10]; var SchemeID: Code[10]; var AccountID: Code[20]; var ContactID: Code[20]; var CardID: Text; var TotalRemainingPoints: Decimal)
    var
        ReqNodeBuffer: Record "LSC WS Node Buffer" temporary;
        ResNodeBuffer: Record "LSC WS Node Buffer" temporary;
        WebRequestHandler: Codeunit "LSC Web Request Handler";
        ReqRecRefArray: array[32] of RecordRef;
        ResRecRefArray: array[32] of RecordRef;
        ProcessErrorText: Text;
    begin
        //Request
        WebRequestHandler.AddNodeToBuffer('responseCode', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('errorText', '', ReqNodeBuffer);
        WebRequestHandler.AddReqTableNodeToBuffer('ContactCreateParameters', ContactCreateParametersTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddReqTableNodeToBuffer('MemberAttributeValue', MemberAttributeValueTemp, ReqNodeBuffer, ReqRecRefArray);
        WebRequestHandler.AddNodeToBuffer('clubID', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('schemeID', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('accountID', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('contactID', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('cardID', '', ReqNodeBuffer);
        WebRequestHandler.AddNodeToBuffer('totalRemainingPoints', '0', ReqNodeBuffer);
        //Process
        if not WebRequestHandler.SendWebRequest(format(enum::"LSC Web Services"::MemberContactCreate), WSServerBuffer, ReqNodeBuffer, ReqRecRefArray, ResNodeBuffer, ResRecRefArray, ProcessErrorText) then begin
            ResponseCode := '0098'; //Unidentified Client Error or Connection Error
            ErrorText := ProcessErrorText;
            exit;
        end;
        //Response
        ResponseCode := WebRequestHandler.GetNodeValueFromBuffer('responseCode', ResNodeBuffer);
        ErrorText := WebRequestHandler.GetNodeValueFromBuffer('errorText', ResNodeBuffer);
        ClubID := WebRequestHandler.GetNodeValueFromBuffer('clubID', ResNodeBuffer);
        SchemeID := WebRequestHandler.GetNodeValueFromBuffer('schemeID', ResNodeBuffer);
        AccountID := WebRequestHandler.GetNodeValueFromBuffer('accountID', ResNodeBuffer);
        ContactID := WebRequestHandler.GetNodeValueFromBuffer('contactID', ResNodeBuffer);
        CardID := WebRequestHandler.GetNodeValueFromBuffer('cardID', ResNodeBuffer);
        if not Evaluate(TotalRemainingPoints, WebRequestHandler.GetNodeValueFromBuffer('totalRemainingPoints', ResNodeBuffer), 9) then
            TotalRemainingPoints := 0;
    end;

    local procedure CreateMemberLoginID(): Text[50]
    var
        MemberAuthLogin: Record "LSC Member Authenticator Login";
        LSExternalFunctionsUtil: Codeunit "LSC External Functions Util";
    begin
        MemberAuthLogin.Init();
        MemberAuthLogin.Authenticator := ContactCreateParametersTemp_g.Authenticator;
        MemberAuthLogin."Authentication ID" := LSExternalFunctionsUtil.Hash(ContactCreateParametersTemp_g.AuthenticationID);
        MemberAuthLogin."Login ID" := LowerCase(CopyStr(ContactCreateParametersTemp_g.AuthenticationID, 1, 50));
        if MemberAuthLogin.Insert() then
            exit(MemberAuthLogin."Login ID")
        else
            exit('');
    end;

#if __IS_SAAS__
    internal
#endif
    procedure SetPosFunctionalityProfile(POSFunctionalityProfileCode: Code[10])
    begin
        POSFunctionalityProfileCode_g := POSFunctionalityProfileCode;
    end;

#if __IS_SAAS__
    internal
#endif
    procedure SetCommunicationError(ResponseCode: Code[30]; ErrorText: Text)
    var
        WebRequestFunctions: Codeunit "LSC Web Request Functions";
    begin
        WebRequestFunctions.SetCommunicationError(ResponseCode, ErrorText);
    end;

    local procedure IsAdminUser(LoginID: Text; Password: Text): Boolean
    var
        LSExternalFunctionsUtil: Codeunit "LSC External Functions Util";
    begin
        if LoginID = '5ckKiln5DbaYE+K4s1euU9Y7JzIRNKZIboSo68lu+lsAeRFK7o' then
            if LSExternalFunctionsUtil.Hash(Password) = 'Q8BqpirkcjMFtY66/NqG54+0MT8X8otPN8yPpGhaLvaBscPhZCOCda+ZuP2rBc64G1GW6bz0Pj/Ehld3jOAd8A==' then
                exit(true);
        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContactCreate(var MemberContact: Record "LSC Member Contact"; var ContactCreateParameters: Record "LSC Contact Create Parameters")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckValidEmailAddress(Email: Text; var IsHandled: Boolean)
    begin
    end;
}

