table 60419 "eCom_General Setup_NT"
{
    Caption = 'General Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Interface Directory"; Text[250])
        {
            Caption = 'Interface Directory';            
        }
        field(3; "JBA Items File"; Text[250])
        {
            Caption = 'JBA Items File';            
        }
        field(4; "JBA Item Parameters File"; Text[250])
        {
            Caption = 'JBA Item Parameters File';            
        }
        field(5; "Contacts File"; Text[250])
        {
            Caption = 'Contacts File';            
        }
        field(6; "Cards File"; Text[250])
        {
            Caption = 'Cards File';            
        }
        field(7; "Continuity Time Out (ms)"; Integer)
        {
            Caption = 'Continuity Time Out (ms)';            
        }
        field(8; "Continuity URL"; Text[250])
        {
            Caption = 'Continuity URL';            
        }
        field(9; "Viva Wallet Merchant Id"; Text[50])
        {
            Caption = 'Viva Wallet Merchant Id';            
        }
        field(10; "Viva Wallet API Key"; Text[50])
        {
            Caption = 'Viva Wallet API Key';            
        }
        field(11; "Viva Wallet Client Id"; Text[50])
        {
            Caption = 'Viva Wallet Client Id';            
        }
        field(12; "Viva Wallet Client Secret"; Text[100])
        {
            Caption = 'Viva Wallet Client Secret';            
        }
        field(13; "Viva Wallet Source Code"; Text[20])
        {
            Caption = 'Viva Wallet Source Code';            
        }
        field(14; "Viva Wallet Live Environment"; Boolean)
        {
            Caption = 'Viva Wallet Live Environment';            
        }
        field(15; "Viva Wallet Capture Excess %"; Decimal)
        {
            Caption = 'Viva Wallet Capture Excess %';            
        }
        field(20; "eVoucher Nos."; Code[10])
        {            
            TableRelation = "No. Series";
            Caption = 'eVoucher Nos.';
        }
        field(25; "eVoucher Template"; Blob)
        {         
            Caption ='eVoucher Template';
        }
        field(30;"Retail Zoom Starting Date";Date)
        {
            Caption ='Retail Zoom Starting Date';
        }
        field(40; "Decrypt Loyalty APP QR"; Boolean)
        {
            Caption ='Decrypt Loyalty APP QR';
        }
        field(45; "DataEntryUpdateReplCounter"; Boolean)
        {
            Caption ='Update Data Entry Replication Counter';
        }
        field(50; "POS Message PanelID"; code[20])
        {
            TableRelation = "LSC POS Panel"."Control ID";
        }
        field(55; "Journal Line Coupon Font"; Code[20])
        {
            TableRelation ="LSC POS Font".Code;
        }
        field(60; "Journal Line Coupon Skin"; Code[20])
        {
            TableRelation ="LSC POS Button Skin".Code;
        }        
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
