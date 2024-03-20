// pageextension 60004 "Tender Type_NT" extends "LSC Tender Type Card"
// {
//     layout
//     {
//         // Add changes to page layout here
//         addlast(Posting)
//         {
//             field("Master Tender"; Rec."Master Tender")
//             {
//                 ApplicationArea = All;
//                 ToolTip = 'Specifies the value of tender where amounts to be clubbed while calculating statement.';
//             }

//         }

//     }

//     actions
//     {
//         // Add changes to page actions here
//     }

//     var
//         myInt: Integer;
// }
