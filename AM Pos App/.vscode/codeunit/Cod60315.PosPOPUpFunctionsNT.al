codeunit 60315 "Pos_POP Up Functions_NT"

{
    trigger OnRun()
    begin

    end;

    procedure PopUpPosMessage(MsgTxt: Text[100]): Boolean
    begin
        exit(PosMessage(MsgTxt));
    end;

    procedure PosMessage(MsgTxt: Text): Boolean
    var
        TxtBuiler: TextBuilder;
        GenSetup: Record "eCom_General Setup_NT";
    begin
        Clear(EPosCtrl);
        Clear(POSSession);
        if not GenSetup.Get() then
            exit(false);
        if GenSetup."POS Message PanelID" = '' then
            exit(false);
        TxtBuiler.Append(MsgTxt);
        TxtBuiler.Replace('\', '<br/>');
        MsgTxt := TxtBuiler.ToText();
        POSSession.SetValue('<#MU_InfoText1>', MsgTxt);
        if GenSetup.Get() then
            if GenSetup."POS Message PanelID" <> '' then
                EPosCtrl.ShowPanelModal(GenSetup."POS Message PanelID");
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 10012718, 'OnModalPanelResult', '', false, false)]
    local procedure ProcessPopupOnModalPanelResult(panelID: Text; resultOK: Boolean; payload: Text; var processed: Boolean)
    var
        PosGenUtils: Codeunit "Pos_General Utility_NT";
    begin
        if panelID = PosGenUtils.GetMsgPanelID() then
            POSSession.DeleteValue('MU_InfoText1');
    end;

    procedure PosConfirmMessage(MsgTxt: Text)
    var
        TxtBuiler: TextBuilder;
    begin
        TxtBuiler.Append(MsgTxt);
        TxtBuiler.Replace('\', '<br/>');
        MsgTxt := TxtBuiler.ToText();
        POSSession.SetValue('<#MU_InfoText1>', MsgTxt);
        EPosCtrl.ShowPanelModal('#CONFIRM_NT');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", 'OnModalPanelResult', '', true, true)]
    local procedure OnModelPanelResult(panelID: Text; payload: Text; resultOK: Boolean; var processed: Boolean)
    var
        LSCCommentPanelController: Codeunit "LSC Comment Panel Controller";
        POSSession: Codeunit "LSC POS Session";
    begin
        //        if strpos(panelID, POSSession.LSCCommentSalesPOSPanelFilter()) = 1 then
        //          LSCCommentPanelController.OnAfterLSCCommentSalesPOSPanelCloseUpdateLSCCommentsInDataGrid();
        //if panelID = '#CONFIRM_NT' then
        //    Message('%1',resultOK);
    end;


    var
        EPosCtrl: Codeunit "LSC POS Control Interface";
        POSSession: Codeunit "LSC POS Session";

}