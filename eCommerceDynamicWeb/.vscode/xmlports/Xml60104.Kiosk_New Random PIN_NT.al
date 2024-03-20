xmlport 60104 "kiosk_New Random PIN_NT"
{
    Caption = 'New Random PIN';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    schema
    {
        textelement(RootNewRandomPINResponse)
        {
            MinOccurs = Zero;
            textelement(ChangeSuccess)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    ChangeSuccess := ChangeSuccessVal;
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
            textelement(InvalidPin)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    InvalidPin := InvalidPinVal;
                end;
            }
            textelement(SMSSent)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    SMSSent := SMSSentVal;
                end;
            }
            textelement(PIN)
            {
                MinOccurs = Zero;
                trigger OnBeforePassVariable()
                begin
                    PIN := PINVal;
                end;
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
    procedure SetResponseValues(ChangeSuccess: Text[5]; ContactFound: Text[5]; InValidPIN: Text[5]; SMSSent: Text[5]; PIN: Text[4])
    begin
        ChangeSuccessVal := ChangeSuccess;
        ContactFoundVal := ContactFound;
        InValidPINVal := InValidPIN;
        SMSSentVal := SMSSent;
        PINVal := PIN;
    end;

    var
        ChangeSuccessVal: Text[5];
        ContactFoundVal: Text[5];
        InValidPINVal: Text[5];
        PINVal: Text[4];
        SMSSentVal: Text[5];
}
