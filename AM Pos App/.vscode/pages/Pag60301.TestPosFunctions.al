// page 60301 "Test Pos Functions"
// {
//     Caption = 'Test Pos Functions';
//     PageType = Card;
//     ApplicationArea = all;
//     UsageCategory = Administration;

//     layout
//     {
//         area(Content)
//         {
//             field("Card No."; CardNo)
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(DeCrypt)
//             {
//                 ApplicationArea = All;
//                 trigger OnAction()
//                 var
//                     GenFun: Codeunit "Pos_General Functions_NT";
//                 begin
//                     message(GenFun.ProcessScannerData('elWvVqLg+PF2pFJEGbMLHeNBdvoljkKmQCVGPHG0ePmR8fWdWFeFiHPvM3kWdHNVz1ibBUnfJVZkw86V2LmcIVyePLbRqt8aR+U98fbJo7roGLvAtqqQiaVNiSLrKjo8+q7sdhndyrdoOAxxRNgfRUPMB0ONHWaWYQ/Ji3Td6hSc46dp+BwiDsJGiYH88/qr'));
//                 end;
//             }
//             action("Get Points")
//             {
//                 ApplicationArea = All;

//                 trigger OnAction()
//                 var
//                     GenFun: Codeunit "Pos_General Functions_NT";
//                     StartingPoint: Decimal;
//                 begin
//                     genfun.GetMemberStartingPoints(CardNo, StartingPoint);
//                     Message('Return Value %1', StartingPoint);
//                 end;
//             }
//             action("Get MemberInfo")
//             {
//                 ApplicationArea = All;

//                 trigger OnAction()
//                 var
//                     GenFun: Codeunit "Pos_General Functions_NT";
//                     StartingPoint: Decimal;
//                     MemberAttributeListTemp: Record "LSC Member Attribute List" temporary;
//                 begin
//                     genfun.GetMemberInfoForPos(CardNo, StartingPoint, MemberAttributeListTemp);
//                     Message('Start Points-%1 Attributes-%2', StartingPoint, MemberAttributeListTemp.Count);
//                 end;
//             }
//             // action("WS_DATAENTRY_OFF")
//             // {
//             //     ApplicationArea = All;

//             //     trigger OnAction()
//             //     var
//             //         PosFunProf: Record "LSC POS Func. Profile";
//             //     begin
//             //         PosFunProf.Get('#ALPHAMEGA');
//             //         PosFunProf.ModifyAll(PosFunProf."TS Data Entries", false);
//             //     end;
//             // }
//             // // action(CustBalance)
//             // {
//             //     ApplicationArea = All;

//             //     trigger OnAction()
//             //     var
//             //         Cust: Record Customer;
//             //     begin
//             //         Cust.Get('DAT002');
//             //         Cust.CalcFields("LSC Amt. Charged On POS");
//             //         message('%1', Cust."LSC Amt. Charged On POS");
//             //     end;
//             // }
//             // // action(UpdatePointJnlAcc)
//             // {
//             //     Caption = 'Create Opening Member Point Jrnl';
//             //     ApplicationArea = All;

//             //     trigger OnAction()
//             //     var
//             //         MemPointJnl: Record "LSC Member Point Jnl. Line";
//             //     begin
//             //             CalcPointsAndCreateJnl
//             //     end;
//             // }

//         }
//     }


//     // LOCAL procedure CalcPointsAndCreateJnl()
//     // var
//     //     MemberAccount: Record "LSC Member Account";
//     //     Window: Dialog;
//     //     RemainingPoints: Decimal;
//     //     MemOpening: Record "Member Opening_NT";
//     //     Cnt: Integer;
//     //     LineNo: Integer;
//     // begin
//     //     LineNo := 10000;
//     //     IF GUIALLOWED THEN
//     //         Window.OPEN(Text001 + Text002);
//     //     // TempBlockedMembers.RESET;
//     //     // TempBlockedMembers.DELETEALL;
        
//     //     IF MemOpening.FINDSET THEN
//     //         REPEAT
//     //             //UnBlockMemberAcc(MemberAccount."No.");                 
//     //             RemainingPoints := MemOpening.Points;
//     //             IF RemainingPoints <> 0 THEN BEGIN
//     //                 Cnt += 1;
//     //                 IF GUIALLOWED THEN BEGIN
//     //                     Window.UPDATE(1, MemOpening."Member Acc");
//     //                     Window.UPDATE(2, Cnt);
//     //                 END;                    
//     //                 CreatePointJnl(MemOpening."Member Acc", RemainingPoints,LineNo);
//     //                 LineNo +=10;
//     //             END;

//     //         UNTIL MemOpening.NEXT = 0;
//     //     IF GUIALLOWED THEN
//     //         Window.CLOSE;
//     // end;

//     // LOCAL procedure CreatePointJnl(AccNo: Code[20]; PointBalance: Decimal;LineNo:  Integer)
//     // var
//     //     MemPointJnlLine: Record "LSC Member Point Jnl. Line";
        
//     // begin
//     //     // MemPointJnlLine.SETRANGE("Journal Template Name", 'MEMBER');
//     //     // MemPointJnlLine.SETRANGE(MemPointJnlLine."Journal Batch Name", 'MIGRATION');
//     //     // IF MemPointJnlLine.FINDLAST THEN
//     //     //     LineNo := MemPointJnlLine."Line No." + 10
//     //     // ELSE
//     //     //     LineNo := 10000;

//     //     CLEAR(MemPointJnlLine);
//     //     MemPointJnlLine.INIT;
//     //     MemPointJnlLine.VALIDATE("Journal Template Name", 'MEMBER');
//     //     MemPointJnlLine.VALIDATE("Journal Batch Name", 'MIGRATION');
//     //     MemPointJnlLine.VALIDATE(Date, TODAY);
//     //     MemPointJnlLine."Document No." := 'MAOP'+Format(Today);
//     //     MemPointJnlLine."Line No." := LineNo;
//     //     MemPointJnlLine.VALIDATE("Account No.", AccNo);
//     //     if PointBalance > 0 then
//     //         MemPointJnlLine.VALIDATE(Type, MemPointJnlLine.Type::"Pos. Adjustment")
//     //     else
//     //         MemPointJnlLine.VALIDATE(Type, MemPointJnlLine.Type::"Neg. Adjustment");

//     //     MemPointJnlLine.VALIDATE("Point Type", MemPointJnlLine."Point Type"::"Award Points");
//     //     MemPointJnlLine.VALIDATE(Points, PointBalance);
//     //     MemPointJnlLine.Description := STRSUBSTNO(Text003, MemPointJnlLine.Date);
//     //     MemPointJnlLine.INSERT(TRUE);
//     // end;

//     var
//         myInt: Integer;
//         CardNo: Text[250];

//         Text001: label 'Processing Member Account              #1######\\';
//         Text002: label 'Records Processed              #2######\\';
//         Text003: Label 'Opening Balance as of %1';
// }