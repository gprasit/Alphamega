xmlport 60103 kiosk_DoLoginResponse_NT
{
    Caption = 'Do Login Response';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    schema
    {
        textelement(DoLoginResult)
        {
            textelement(LoginSuccess)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    LoginSuccess := LoginSuccessVal;
                end;
            }
            textelement(ContactFound)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    ContactFound := ContactFoundVal;
                end;
            }
            textelement(PinOK)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    PinOK := PinOKVal;
                end;
            }
            textelement(InvalidPin)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    InvalidPin := InvalidPinVal;
                end;
            }
            textelement(AddressConfirmed)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    AddressConfirmed := AddressConfirmedVal;
                end;
            }
            tableelement(ContactInfo; "LSC Member Contact")
            {

                UseTemporary = true;
                MinOccurs = Zero;
                fieldelement(ContactNo; ContactInfo."Contact No.")
                {
                }
                fieldelement(Name; ContactInfo.Name)
                {
                }
                fieldelement(Phone; ContactInfo."Phone No.")
                {
                }
                fieldelement(MobilePhone; ContactInfo."Mobile Phone No.")
                {
                }
                fieldelement(Address; ContactInfo.Address)
                {
                }
                fieldelement(Address2; ContactInfo."Address 2")
                {
                }
                fieldelement(PostCode; ContactInfo."Post Code")
                {
                }
                fieldelement("Area"; ContactInfo."Region Code")
                {
                }
                fieldelement(City; ContactInfo.City)
                {
                }
                fieldelement(Gender; ContactInfo."Gender 2")
                {
                }
                fieldelement(Email; ContactInfo."E-Mail")
                {
                }
                fieldelement(AppartmentNo; ContactInfo."Flat No.")
                {
                }
                textelement(PointBalance)
                {
                    trigger OnBeforePassVariable()
                    var
                        eComMemberFn: Codeunit "eCom_Member Functions_NT";
                    begin
                        PointBalance := Format(eComMemberFn.GetMemberPoints_CS(ContactInfo."Contact No."), 0, 1);
                    end;
                }
                fieldelement(Date_Of_Birth; ContactInfo."Date of Birth")
                {
                }
                fieldelement(PIN; ContactInfo."Kiosk Pin")
                {
                }
                fieldelement(Language; ContactInfo."Language Code")
                {
                }
                textelement(CardNo)
                {
                    trigger OnBeforePassVariable()
                    begin
                        CardNo := EnteredCardNoVal;
                    end;
                }

            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    procedure SetAccountInfo(AccNo: Code[20]; ContactNo: Code[20]; TextValues: array[6] of Text[100])
    var
        MemberContact: Record "LSC Member Contact";
    begin
        if AccNo <> '' then
            if MemberContact.Get(AccNo, ContactNo) then begin
                ContactInfo.Init();
                ContactInfo.TransferFields(MemberContact);
                ContactInfo.Insert();
            end;
        AddressConfirmedVal := TextValues[1];
        ContactFoundVal := TextValues[2];
        EnteredCardNoVal := TextValues[3];
        InvalidPinVal := TextValues[4];
        LoginSuccessVal := TextValues[5];
        PinOKVal := TextValues[6];
    end;

    var
        AddressConfirmedVal: Text[5];
        ContactFoundVal: Text[5];
        EnteredCardNoVal: Text;
        InvalidPinVal: Text[5];
        LoginSuccessVal: Text[5];
        PinOKVal: Text[5];
}
