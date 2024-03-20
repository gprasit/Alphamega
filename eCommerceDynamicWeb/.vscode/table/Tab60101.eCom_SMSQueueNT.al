table 60101 "eCom_SMS Queue_NT"
{
    Caption = 'SMS Queue';
    DataClassification = CustomerContent;
    fields
    {
        field(60001; "Entry No."; Integer)
        {
            Caption = 'Entry No.';

        }
        field(60002; "Phone No."; Code[15])
        {
            Caption = 'Phone No.';
        }
        field(60003; Message; Text[250])
        {
            Caption = 'Message';
        }
        field(60004; Sent; Boolean)
        {
            Caption = 'Sent';
        }
        field(60005; Type; Integer)
        {
            Caption = 'Type';
        }
        field(60006; Date; Date)
        {
            Caption = 'Date';
        }
        field(60007; "Date Sent"; Date)
        {
            Caption = 'Date Sent';
        }
        field(60008; Time; Time)
        {
            Caption = 'Time';
        }
        field(60009; "Time Sent"; Time)
        {
            Caption = 'Time Sent';
        }
        field(60010; Success; Boolean)
        {
            Caption = 'Success';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
