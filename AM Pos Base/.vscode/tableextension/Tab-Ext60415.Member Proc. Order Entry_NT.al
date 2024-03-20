tableextension 60415 "Member Proc. Order Entry_NT" extends "LSC Member Process Order Entry"
{
    fields
    {
        modify("Document Source")
        {
            OptionCaption = 'POS,Order,Kiosk,Mobile App';
        }
        field(60101; "Points Used"; Code[20])
        {
            Caption = 'Points Used';
            DataClassification = CustomerContent;
        }
        field(60102; "Card No."; Code[20])
        {
            Caption = 'Card No.';
            DataClassification = CustomerContent;
        }
    }
        keys
    {        
            key(Key1_NT; "Date Processed",Date)
            {                
            }
    }

}
