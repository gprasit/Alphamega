page 60019 "Treasury Activities_NT"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Treasury Cue_NT";

    layout
    {
        area(content)
        {
            cuegroup(Control36)
            {
                CueGroupLayout = Wide;
                ShowCaption = false;
                field("Treasury Statements"; Rec."Treasury Statements")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of unposted treasury statements.';
                }
                field("Statements"; OpenStatementsCnt)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the number of unposted statements.';
                    trigger OnDrillDown()
                    var
                    begin
                        Page.RunModal(Page::"LSC Open Statement List");
                    end;
                }
                field("Treasury Payment Journals"; TreasPmtJnlCnt)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the number of unposted treasury payment journal lines.';
                    trigger OnDrillDown()
                    begin
                        TreasRoleCenterMgmt.TreasuryJournalDrilldown(TreasJnlEntryType::"Cash-Payments")
                    end;
                }
                field("Treasury Receipt Journals"; TreasRcptJnlCnt)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the number of unposted treasury receipt journal lines.';
                    trigger OnDrillDown()
                    begin
                        TreasRoleCenterMgmt.TreasuryJournalDrilldown(TreasJnlEntryType::"Cash-Receipts")
                    end;

                }
                // field("Treasury Statements - Posted"; Rec."Treasury Statements - Posted")
                // {
                //     ApplicationArea = all;
                //     ToolTip = 'Specifies the number of posted treasury statements.';
                //     trigger OnDrillDown()
                //     var
                //     begin
                //         TreasRoleCenterMgmt.TreasuryStatementList(1);
                //     end;
                // }
                // field("Overdue Purchase Documents"; Rec."Overdue Purchase Documents")
                // {
                //     ApplicationArea = Basic, Suite;
                //     DrillDownPageID = "Vendor Ledger Entries";
                //     ToolTip = 'Specifies the number of purchase invoices where your payment is late.';
                // }
                // field("Cash Accounts Balance"; Rec."Cash Accounts Balance")
                // {
                //     ApplicationArea = Basic, Suite;
                //     DrillDownPageID = "Chart of Accounts";
                //     Image = Cash;
                //     ToolTip = 'Specifies the sum of the accounts that have the cash account category.';

                //     trigger OnDrillDown()
                //     var
                //         ActivitiesMgt: Codeunit "Activities Mgt.";
                //     begin
                //         ActivitiesMgt.DrillDownCalcCashAccountsBalances();
                //     end;
                // }
                // field("New Incoming Documents"; Rec."New Incoming Documents")
                // {
                //     ApplicationArea = Basic, Suite;
                //     DrillDownPageID = "Incoming Documents";
                //     ToolTip = 'Specifies the number of new incoming documents in the company. The documents are filtered by today''s date.';
                // }
            }
            // cuegroup(Payments)
            // {
            //     Caption = 'Payments';
            //     field("Purchase Documents Due Today"; Rec."Purchase Documents Due Today")
            //     {
            //         ApplicationArea = Basic, Suite;
            //         DrillDownPageID = "Vendor Ledger Entries";
            //         ToolTip = 'Specifies the number of purchase invoices that are due for payment today.';
            //     }
            //     field("Purch. Invoices Due Next Week"; Rec."Purch. Invoices Due Next Week")
            //     {
            //         ApplicationArea = Basic, Suite;
            //         ToolTip = 'Specifies the number of payments to vendors that are due next week.';
            //     }
            //     field("Purchase Discounts Next Week"; Rec."Purchase Discounts Next Week")
            //     {
            //         ApplicationArea = Basic, Suite;
            //         ToolTip = 'Specifies the number of purchase discounts that are available next week, for example, because the discount expires after next week.';
            //     }

            //     actions
            //     {
            //         // action("Edit Cash Receipt Journal")
            //         // {
            //         //     ApplicationArea = Basic, Suite;
            //         //     Caption = 'Edit Cash Receipt Journal';
            //         //     RunObject = Page "Cash Receipt Journal";
            //         //     ToolTip = 'Register received payments in a cash receipt journal that may already contain journal lines.';
            //         // }
            //         // action("New Sales Credit Memo")
            //         // {
            //         //     ApplicationArea = Basic, Suite;
            //         //     Caption = 'New Sales Credit Memo';
            //         //     RunObject = Page "Sales Credit Memo";
            //         //     RunPageMode = Create;
            //         //     ToolTip = 'Process a return or refund by creating a new sales credit memo.';
            //         // }
            //         // action("Edit Payment Journal")
            //         // {
            //         //     ApplicationArea = Basic, Suite;
            //         //     Caption = 'Edit Payment Journal';
            //         //     RunObject = Page "Payment Journal";
            //         //     ToolTip = 'Pay your vendors by filling the payment journal automatically according to payments due, and potentially export all payment to your bank for automatic processing.';
            //         // }
            //         // action("New Purchase Credit Memo")
            //         // {
            //         //     ApplicationArea = Basic, Suite;
            //         //     Caption = 'New Purchase Credit Memo';
            //         //     RunObject = Page "Purchase Credit Memo";
            //         //     RunPageMode = Create;
            //         //     ToolTip = 'Create a new purchase credit memo so you can manage returned items to a vendor.';
            //         // }
            //     }
            // }
            // cuegroup("Document Approvals")
            // {
            //     Caption = 'Document Approvals';
            //     field("POs Pending Approval"; Rec."POs Pending Approval")
            //     {
            //         ApplicationArea = Suite;
            //         DrillDownPageID = "Purchase Order List";
            //         ToolTip = 'Specifies the number of purchase orders that are pending approval.';
            //     }
            //     field("SOs Pending Approval"; Rec."SOs Pending Approval")
            //     {
            //         ApplicationArea = Suite;
            //         DrillDownPageID = "Sales Order List";
            //         ToolTip = 'Specifies the number of sales orders that are pending approval.';
            //     }

            //     actions
            //     {
            //         // action("Create Reminders...")
            //         // {
            //         //     ApplicationArea = Suite;
            //         //     Caption = 'Create Reminders...';
            //         //     RunObject = Report "Create Reminders";
            //         //     ToolTip = 'Remind your customers of late payments.';
            //         // }
            //         // action("Create Finance Charge Memos...")
            //         // {
            //         //     ApplicationArea = Suite;
            //         //     Caption = 'Create Finance Charge Memos...';
            //         //     RunObject = Report "Create Finance Charge Memos";
            //         //     ToolTip = 'Issue finance charge memos to your customers as a consequence of late payment.';
            //         // }
            //     }
            // }
            // cuegroup(Financials)
            // {
            //     Caption = 'Financials';
            //     field("Non-Applied Payments"; Rec."Non-Applied Payments")
            //     {
            //         ApplicationArea = Basic, Suite;
            //         Caption = 'Unprocessed Payments';
            //         DrillDownPageID = "Pmt. Reconciliation Journals";
            //         Image = Cash;
            //         ToolTip = 'Specifies a window to reconcile unpaid documents automatically with their related bank transactions by importing a bank statement feed or file. In the payment reconciliation journal, incoming or outgoing payments on your bank are automatically, or semi-automatically, applied to their related open customer or vendor ledger entries. Any open bank account ledger entries related to the applied customer or vendor ledger entries will be closed when you choose the Post Payments and Reconcile Bank Account action. This means that the bank account is automatically reconciled for payments that you post with the journal.';
            //     }

            //     actions
            //     {
            //         action("New Payment Reconciliation Journal")
            //         {
            //             ApplicationArea = Basic, Suite;
            //             Caption = 'New Payment Reconciliation Journal';
            //             ToolTip = 'Reconcile unpaid documents automatically with their related bank transactions by importing bank a bank statement feed or file.';

            //             trigger OnAction()
            //             var
            //                 BankAccReconciliation: Record "Bank Acc. Reconciliation";
            //             begin
            //                 BankAccReconciliation.OpenNewWorksheet();
            //             end;
            //         }
            //     }
            // }
            // cuegroup("Incoming Documents")
            // {
            //     Caption = 'Incoming Documents';
            //     field("Approved Incoming Documents"; Rec."Approved Incoming Documents")
            //     {
            //         ApplicationArea = Basic, Suite;
            //         DrillDownPageID = "Incoming Documents";
            //         ToolTip = 'Specifies the number of approved incoming documents in the company. The documents are filtered by today''s date.';
            //     }
            //     field("OCR Completed"; Rec."OCR Completed")
            //     {
            //         ApplicationArea = Basic, Suite;
            //         DrillDownPageID = "Incoming Documents";
            //         ToolTip = 'Specifies that incoming document records that have been created by the OCR service.';
            //     }

            //     actions
            //     {
            //         action(CheckForOCR)
            //         {
            //             ApplicationArea = Basic, Suite;
            //             Caption = 'Receive from OCR Service';
            //             RunObject = Codeunit "OCR - Receive from Service";
            //             RunPageMode = View;
            //             ToolTip = 'Process new incoming electronic documents that have been created by the OCR service and that you can convert to, for example, purchase invoices in Dynamics 365.';
            //             Visible = ShowCheckForOCR;
            //         }
            //     }
            // }
            cuegroup("Product Videos")
            {
                Caption = 'Product Videos';
                Visible = ShowProductVideosActivities;

                actions
                {
                    action(Action32)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Product Videos';
                        Image = TileVideo;
                        RunObject = Page "Product Videos";
                        ToolTip = 'Open a list of videos that showcase some of the product capabilities.';
                    }
                }
            }
            cuegroup("Get started")
            {
                Caption = 'Get started';
                Visible = ReplayGettingStartedVisible;

                actions
                {
                    action(ShowStartInMyCompany)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Try with my own data';
                        Image = TileSettings;
                        ToolTip = 'Set up My Company with the settings you choose. We''ll show you how, it''s easy.';
                        Visible = false;

                        trigger OnAction()
                        begin
                            // if UserTours.IsAvailable and O365GettingStartedMgt.AreUserToursEnabled() then
                            //     UserTours.StartUserTour(O365GettingStartedMgt.GetChangeCompanyTourID);
                        end;
                    }
                    action(ReplayGettingStarted)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Play Getting Started';
                        Image = TileVideo;
                        ToolTip = 'Show the Getting Started guide again.';

                        trigger OnAction()
                        var
                            O365GettingStarted: Record "O365 Getting Started";
                        begin
                            if O365GettingStarted.Get(UserId, ClientTypeManagement.GetCurrentClientType()) then begin
                                O365GettingStarted."Tour in Progress" := false;
                                O365GettingStarted."Current Page" := 1;
                                O365GettingStarted.Modify();
                                Commit();
                            end;

                            O365GettingStartedMgt.LaunchWizard(true, false);
                        end;
                    }
                }
            }
            // usercontrol(SATAsyncLoader; SatisfactionSurveyAsync)
            // {
            //     ApplicationArea = Basic, Suite;
            //     trigger ResponseReceived(Status: Integer; Response: Text)
            //     var
            //         SatisfactionSurveyMgt: Codeunit "Satisfaction Survey Mgt.";
            //     begin
            //         SatisfactionSurveyMgt.TryShowSurvey(Status, Response);
            //     end;

            //     trigger ControlAddInReady();
            //     begin
            //         IsAddInReady := true;
            //         CheckIfSurveyEnabled();
            //     end;
            // }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CuesAndKpis: Codeunit "Cues And KPIs";
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        ReplayGettingStartedVisible := false;
        if EnvironmentInfo.IsSaaS() then
            ReplayGettingStartedVisible := true;
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial();
        CalcTreasuryCueValues();
    end;

    trigger OnAfterGetRecord()
    begin
        CalculateCueFieldValues();
    end;

    trigger OnInit()
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        ReplayGettingStartedVisible := false;
        if EnvironmentInfo.IsSaaS() then
            ReplayGettingStartedVisible := true;
    end;

    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.SetFilter("Due Date Filter", '<=%1', WorkDate());
        Rec.SetFilter("Overdue Date Filter", '<%1', WorkDate());
        Rec.SetFilter("Due Next Week Filter", '%1..%2', CalcDate('<1D>', WorkDate()), CalcDate('<1W>', WorkDate()));

        ShowProductVideosActivities := ClientTypeManagement.GetCurrentClientType() <> CLIENTTYPE::Phone;
        ShowCheckForOCR := OCRServiceMgt.OcrServiceIsEnable();
        ShowIntelligentCloud := not EnvironmentInfo.IsSaaS();

        RoleCenterNotificationMgt.ShowNotifications();
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
        // if PageNotifier.IsAvailable then begin
        //     PageNotifier := PageNotifier.Create;
        //     PageNotifier.NotifyPageReady;
        // end;
    end;

    local procedure CalcTreasuryCueValues()
    var
        Statement: Record "LSC Statement";
        RetailUser: Record "LSC Retail User";
    begin

        // Rec."Treasury Statements" := TreasRoleCenterMgmt.TreasuryStmtCount(0);
        Rec."Treasury Statements - Posted" := TreasRoleCenterMgmt.TreasuryStmtCount(1);
        if RetailUser.Get(UserId) then begin
            Rec.SetFilter("Store Hierarchy Filter", RetailUser."Store Hierarchy No.");
            TreasPmtJnlCnt := TreasRoleCenterMgmt.TreasuryJournalCount(TreasJnlEntryType::"Cash-Payments", RetailUser."Store Hierarchy No.");
            TreasRcptJnlCnt := TreasRoleCenterMgmt.TreasuryJournalCount(TreasJnlEntryType::"Cash-Receipts", RetailUser."Store Hierarchy No.");
        end else begin
            TreasPmtJnlCnt := TreasRoleCenterMgmt.TreasuryJournalCount(TreasJnlEntryType::"Cash-Payments", '');
            TreasRcptJnlCnt := TreasRoleCenterMgmt.TreasuryJournalCount(TreasJnlEntryType::"Cash-Receipts", '');
        end;

        TreasRoleCenterMgmt.FilterStatements(Statement);
        OpenStatementsCnt := Statement.Count();
    end;

    local procedure CalculateCueFieldValues()
    var
        ActivitiesMgt: Codeunit "Activities Mgt.";
    begin
        if Rec.FieldActive("Cash Accounts Balance") then
            Rec."Cash Accounts Balance" := ActivitiesMgt.CalcCashAccountsBalances();
    end;

    local procedure StartWhatIsNewTour(hasTourCompleted: Boolean): Boolean
    var
        O365UserTours: Record "User Tours";
        TourID: Integer;
    begin
        TourID := O365GettingStartedMgt.GetWhatIsNewTourID();

        if O365UserTours.AlreadyCompleted(TourID) then
            exit(false);

        if not hasTourCompleted then begin
            //UserTours.StartUserTour(TourID);
            WhatIsNewTourVisible := true;
            exit(true);
        end;

        if WhatIsNewTourVisible then begin
            O365UserTours.MarkAsCompleted(TourID);
            WhatIsNewTourVisible := false;
        end;
        exit(false);
    end;

    // trigger UserTours::ShowTourWizard(hasTourCompleted: Boolean)
    // begin
    //     if O365GettingStartedMgt.IsGettingStartedSupported() then
    //         if O365GettingStartedMgt.LaunchWizard(false, hasTourCompleted) then begin
    //             HideSatisfactionSurvey := true;
    //             exit;
    //         end;

    //     if StartWhatIsNewTour(hasTourCompleted) then
    //         HideSatisfactionSurvey := true;
    // end;

    // trigger UserTours::IsTourInProgressResultReady(isInProgress: Boolean)
    // begin
    // end;

    // trigger PageNotifier::PageReady()
    // begin
    //     IsPageReady := true;
    //     CheckIfSurveyEnabled();
    // end;

    local procedure CheckIfSurveyEnabled()
    var
        SatisfactionSurveyMgt: Codeunit "Satisfaction Survey Mgt.";
        CheckUrl: Text;
    begin
        if not IsAddInReady then
            exit;
        if not IsPageReady then
            exit;
        // if not SatisfactionSurveyMgt.DeactivateSurvey() then
        //     exit;
        if HideSatisfactionSurvey then
            exit;
        // if not SatisfactionSurveyMgt.TryGetCheckUrl(CheckUrl) then
        //     exit;
        //CurrPage.SATAsyncLoader.SendRequest(CheckUrl, SatisfactionSurveyMgt.GetRequestTimeoutAsync());
    end;

    var
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        ClientTypeManagement: Codeunit "Client Type Management";
        EnvironmentInfo: Codeunit "Environment Information";
        OCRServiceMgt: Codeunit "OCR Service Mgt.";
        TreasRoleCenterMgmt: Codeunit "Treasury Role Center Mgt._NT";
        // [RunOnClient]
        // [WithEvents]
        // PageNotifier: DotNet PageNotifier;
        // [RunOnClient]
        // [WithEvents]
        // UserTours: DotNet UserTours;
        ShowProductVideosActivities: Boolean;
        HideSatisfactionSurvey: Boolean;
        ReplayGettingStartedVisible: Boolean;
        WhatIsNewTourVisible: Boolean;
        ShowCheckForOCR: Boolean;
        ShowIntelligentCloud: Boolean;
        IsAddInReady: Boolean;
        IsPageReady: Boolean;
        OpenStatementsCnt: Integer;
        TreasPmtJnlCnt: Integer;
        TreasRcptJnlCnt: Integer;
        TreasJnlEntryType: enum "Treas. Jnl. Entry Type_NT";
}
