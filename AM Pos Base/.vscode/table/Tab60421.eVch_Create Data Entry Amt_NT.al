table 60421 "eVch_Create Data Entry Amt_NT"
{
    Caption = 'Create Data Entry Amount';
    DataClassification = CustomerContent;
    LookupPageId = "eVch_Create Data Entry Amt_NT";
    
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';            
        }
        field(2; Amount; Decimal)
        {
            Caption = 'Amount';            
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
