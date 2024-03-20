// page 60412 "Pos_EFT Log_NT"
// {
//     ApplicationArea = All;
//     Caption = 'EFT Log';
//     PageType = List;
//     SourceTable = "Pos_EFT Log_NT";
//     UsageCategory = Administration;
//     Editable = false;
//     InsertAllowed=false;
//     DeleteAllowed = false;
//     ModifyAllowed = false;
//     layout
//     {
//         area(content)
//         {
//             repeater(General)
//             {
//                 field("Entry No."; Rec."Entry No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Entry No. field.';
//                 }
//                 field("Store No."; Rec."Store No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Store No. field.';
//                 }
//                 field("POS Terminal No."; Rec."POS Terminal No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the POS Terminal No. field.';
//                 }
//                 field("Card Number"; Rec."Card Number")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Card Number field.';
//                 }
//                 field(Amount; Rec.Amount)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Amount field.';
//                 }
//                 field("Authorization No."; Rec."Authorization No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Authorization No. field.';
//                 }
//                 field("Card Type"; Rec."Card Type")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Card Type field.';
//                 }
//                 field("Cardholder Name"; Rec."Cardholder Name")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Cardholder Name field.';
//                 }
//                 field("Cashback Amount"; Rec."Cashback Amount")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Cashback Amount field.';
//                 }
//                 field("DCC Amount"; Rec."DCC Amount")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the DCC Amount field.';
//                 }
//                 field("DCC Currency Code"; Rec."DCC Currency Code")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the DCC Currency Code field.';
//                 }
//                 field("DCC Exch. Date"; Rec."DCC Exch. Date")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the DCC Exch. Date field.';
//                 }
//                 field("DCC Exch. Rate"; Rec."DCC Exch. Rate")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the DCC Exch. Rate field.';
//                 }
//                 field("DCC Numeric Currency"; Rec."DCC Numeric Currency")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the DCC Numeric Currency field.';
//                 }
//                 field("Date"; Rec."Date")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Date field.';
//                 }
//                 field("EFT Authorization Code"; Rec."EFT Authorization Code")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the EFT Authorization Code field.';
//                 }
//                 field("EFT Batch No."; Rec."EFT Batch No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the EFT Batch No. field.';
//                 }
//                 field("EFT Response"; Rec."EFT Response")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the EFT Response field.';
//                 }
//                 field("EFT Response Text"; Rec."EFT Response Text")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the EFT Response Text field.';
//                 }
//                 field("EFT Transaction No."; Rec."EFT Transaction No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the EFT Transaction No. field.';
//                 }
//                 field("Entry Type"; Rec."Entry Type")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Entry Type field.';
//                 }
//                 field("Expiration Date"; Rec."Expiration Date")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Expiration Date field.';
//                 }
//                 field("Gift Card Balance"; Rec."Gift Card Balance")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Gift Card Balance field.';
//                 }
//                 field("Gift Card Trans. Ref. No."; Rec."Gift Card Trans. Ref. No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Gift Card Trans. Ref. No. field.';
//                 }
//                 field("JCC Receipt No."; Rec."JCC Receipt No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the JCC Receipt No. field.';
//                 }
//                 field("Net Amount"; Rec."Net Amount")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Net Amount field.';
//                 }
//                 field("Original Amount"; Rec."Original Amount")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Original Amount field.';
//                 }
//                 field("Original Transaction Type"; Rec."Original Transaction Type")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Original Transaction Type field.';
//                 }
//                 field("PANEncrypted 1"; Rec."PANEncrypted 1")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the PANEncrypted 1 field.';
//                 }
//                 field("PANEncrypted 2"; Rec."PANEncrypted 2")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the PANEncrypted 2 field.';
//                 }
//                 field("PANEncrypted 3"; Rec."PANEncrypted 3")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the PANEncrypted 3 field.';
//                 }                
//                 field(Pending; Rec.Pending)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Pending field.';
//                 }
//                 field(Provider; Rec.Provider)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Provider field.';
//                 }
//                 field("Receipt No."; Rec."Receipt No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Receipt No. field.';
//                 }
//                 field("Replication Counter"; Rec."Replication Counter")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Replication Counter field.';
//                 }
//                 field("Return Reference No."; Rec."Return Reference No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Return Reference No. field.';
//                 }
//                 field("Status Message"; Rec."Status Message")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Status Message field.';
//                 }                
//                 field("System ID"; Rec."System ID")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the System ID field.';
//                 }
//                 field(SystemCreatedAt; Rec.SystemCreatedAt)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the SystemCreatedAt field.';
//                 }
//                 field(SystemCreatedBy; Rec.SystemCreatedBy)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the SystemCreatedBy field.';
//                 }
//                 field(SystemId; Rec.SystemId)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the SystemId field.';
//                 }
//                 field(SystemModifiedAt; Rec.SystemModifiedAt)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the SystemModifiedAt field.';
//                 }
//                 field(SystemModifiedBy; Rec.SystemModifiedBy)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the SystemModifiedBy field.';
//                 }
//                 field("Terminal ID"; Rec."Terminal ID")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Terminal ID field.';
//                 }
//                 field("Time"; Rec."Time")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Time field.';
//                 }
//                 field("Total Amount"; Rec."Total Amount")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Total Amount field.';
//                 }
//                 field("Transaction Reference"; Rec."Transaction Reference")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Transaction Reference field.';
//                 }
//                 field("Transaction Type"; Rec."Transaction Type")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Transaction Type field.';
//                 }
//                 field("User ID"; Rec."User ID")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the User ID field.';
//                 }
//                 field(Voided; Rec.Voided)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Voided field.';
//                 }                
//             }
//         }
//     }
// }
