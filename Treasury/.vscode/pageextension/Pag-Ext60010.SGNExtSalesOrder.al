pageextension 60010 "SGN Ext. Sales Order" extends "Sales Order"
{
    layout
    {
        addafter(Control1900201301)
        {
            group("SGN Signature Group")
            {
                usercontrol("SGN SGNSignaturePad"; "SGN SGNSignaturePad")
                {
                    ApplicationArea = All;
                    Visible = true;
                    trigger Ready()
                    begin
                        CurrPage."SGN SGNSignaturePad".InitializeSignaturePad();
                    end;

                    trigger Sign(Signature: Text)
                    begin
                        Rec.SignDocument(Signature);
                        // TempRec.CalcFields("SGN Signature");
                        // If TempRec."SGN Signature".HasValue then begin
                        //     Message('ok');
                        //     Rec."SGN Signature" := TempRec."SGN Signature";
                        //     Rec.Modify();
                        //     CurrPage.Update();
                        // end;


                    end;
                }

            }
            field("SGN Signature"; Rec."SGN Signature_SH")
            {
                Caption = 'Customer Signature';
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    var
        TempRec: Record "Sales Header";
}
