pageextension 60002 SchedulerJob extends "LSC Scheduler Job"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Log")
        {
            group("Add &SubJobs")
            {
                action("&PreLoad")
                {
                    Caption = 'Add Pre Load Subjobs';
                    Image = InteractionLog;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        SchJobMgmt: Codeunit NewCompanySetupMgmt_NT;
                    begin
                        SchJobMgmt.CreatePreLoadSubJobLines(Rec);
                    end;
                }

            }
        }
    }

    var
        myInt: Integer;
}