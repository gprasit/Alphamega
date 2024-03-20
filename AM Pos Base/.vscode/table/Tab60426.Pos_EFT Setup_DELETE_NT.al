// table 60426 "Pos_EFT Setup_NT"
// {
//     Caption = 'EFT Setup';
//     DataClassification = CustomerContent;

//     fields
//     {

//         field(1; "POS Terminal No."; Code[10])
//         {
//             Caption = 'POS Terminal No.';
//             TableRelation = "LSC POS Terminal";
//         }
//         field(2; Provider; Enum "Pos_EFT Provider_NT")
//         {
//             Caption = 'Provider';
//         }
//         field(11; "Merchant ID"; Integer)
//         {
//             Caption = 'Merchant ID';
//         }

//         field(12; "Pan Encrypted"; Boolean)
//         {
//             Caption = 'Pan Encrypted';
//         }
//         field(13; "Return CVM"; Boolean)
//         {
//             Caption = 'Return CVM';
//         }
//         field(14; "Print Receipt"; Boolean)
//         {
//             Caption = 'Print Receipt';
//         }
//         field(15; Password; Text[20])
//         {
//             Caption = 'Password';
//         }
//         field(17; Diagnostics; Boolean)
//         {
//             Caption = 'Diagnostics';
//         }
//         field(18; "Folder Path"; Text[250])
//         {
//             Caption = 'Folder Path';
//         }
//         field(19; "Time Out"; Integer)
//         {
//             Caption = 'Time Out';
//         }
//         field(20; Host; Text[30])
//         {
//             Caption = 'Host';
//         }
//         field(21; Port; Integer)
//         {
//             Caption = 'Port';
//         }
//         field(22; "Protocol Variant"; Code[2])
//         {
//             Caption = 'Protocol Variant';
//         }
//         field(23; "Send Acknowledgement"; Boolean)
//         {
//             Caption = 'Send Acknowledgement';
//         }
//         field(24; "Print Merchant Copy"; Boolean)
//         {
//             Caption = 'Print Merchant Copy';
//         }
//         field(25; "Debug File Path"; Text[250])
//         {
//             Caption = 'Debug File Path';
//         }
//         field(26; "Cash Back Alert Message"; Text[100])
//         {
//             Caption = 'Cash Back Alert Message';
//         }
//         field(27; "DCC Alert Message"; Text[100])
//         {
//             Caption = 'DCC Alert Message';
//         }
//         field(28; "Construct Transaction Report"; Boolean)
//         {
//             Caption = 'Construct Transaction Report';
//         }
//         field(29; "Cash Back Message"; Text[100])
//         {
//             Caption = 'Cash Back Message';
//         }
//         field(30; "Terminal ID"; Code[20])
//         {
//             Caption = 'Terminal ID';
//         }
//         field(31; "Transaction Counter"; Integer)
//         {
//             Caption = 'Transaction Counter';
//         }
//         field(32; "Print Header On EFT Report"; Boolean)
//         {
//             Caption = 'Print Header On EFT Report';
//         }
//     }
//     keys
//     {
//         key(PK; "POS Terminal No.",Provider)
//         {
//             Clustered = true;
//         }
//     }
// }
