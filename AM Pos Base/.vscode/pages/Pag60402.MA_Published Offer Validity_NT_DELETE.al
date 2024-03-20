// page 60402 "MA_Published Offer Validity_NT"
// {
//     Caption = 'Published Offer Validity';
//     PageType = ListPart;
//     SourceTable = "MA_Published Offer Validity_NT";
//     DelayedInsert = true;
//     AutoSplitKey = true;
//     layout
//     {
//         area(content)
//         {
//             repeater(control1)
//             {
//                 ShowCaption = false;
//                 field("Member Type"; Rec."Member Type")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Member Type field.';
//                 }
//                 field("Member Value"; Rec."Member Value")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Member Value field.';
//                 }
//             }
//         }
//     }
// }
