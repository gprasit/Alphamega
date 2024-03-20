codeunit 60110 eCom_SalesReturnWFResponses_NT
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', true, true)]
    local procedure AddMyWorkflowResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(SalesReturnResponseCode, Database::"Sales Header", 'Finish eCOMM CUSTOM.', '');
    end;
    /* NOT IN USE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowEventHierarchiesToLibrary(EventFunctionName: Code[128])
    begin
    end;
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', true, true)]
    procedure ExecuteWorkflowResponses(ResponseWorkflowStepInstance: Record "Workflow Step Instance"; var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant)
    var
        WorkflowResponse: record "Workflow Response";
    begin
        if WorkflowResponse.GET(ResponseWorkflowStepInstance."Function Name") then
            case WorkflowResponse."Function Name" of
                'eComCOMPLETE_RETURN':
                    BEGIN
                        SalesReturnResponse(Variant, ResponseWorkflowStepInstance);
                        ResponseExecuted := TRUE;
                    END;
            END;
    end;

    local procedure SalesReturnResponse(SalesHeader: Record "Sales Header"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::"Return Order" then
            exit;
        Message('Flow is in WIP for : %1 ', SalesHeader."No.")
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowEventOnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        Case ResponseFunctionName of
            SalesReturnResponseCode():
                WorkflowResponseHandling.AddResponsePredecessor(SalesReturnResponseCode(), 'RUNWORKFLOWONAPPROVEAPPROVALREQUEST');
        End
    end;

    local procedure SalesReturnResponseCode(): code[128];
    begin
        exit('eComCOMPLETE_RETURN');
    end;
}
