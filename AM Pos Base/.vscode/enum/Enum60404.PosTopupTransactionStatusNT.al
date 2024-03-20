enum 60404 "Topup Transaction Status_NT"
{
    Extensible = true;
    
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Completed)
    {
        Caption = 'Completed';
    }
    value(2; Error)
    {
        Caption = 'Error';
    }
    value(3; Voided)
    {
        Caption = 'Voided';
    }
}
