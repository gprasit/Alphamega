tableextension 60405 "eCom_Mix&Match Line Groups_NT" extends "LSC Mix & Match Line Groups"
{
    fields
    {
        field(60000; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(60001; GreekDescription; Text[250])
        {
            Caption = 'Greek Description';
            DataClassification = CustomerContent;
        }
    }
}
