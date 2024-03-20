codeunit 60310 "Pos_Scheduled Functions_NT"
{
    trigger OnRun()
    begin
        AddNewSpecialGroup();
    end;

    local procedure AddNewSpecialGroup()
    var
        Division: Record "LSC Division";
        SpecialGroup: Record "LSC Item Special Groups";
    begin
        if GuiAllowed then begin
            Window.Open(
                '#1#################################\\' +
                SpecialGroupMsg +
                ItemSpecialGroupMsg +
                ItemSpecialGroupMsg2);
            Window.Update(1, 'Creating New Item Special Groups from Division.');
        end;
        if Division.FindSet() then
            repeat
                if not SpecialGroup.Get(Division.Code) then begin
                    SpecialGroup.Init();
                    SpecialGroup.Code := Division.Code;
                    SpecialGroup.Description := Division.Description;
                    SpecialGroup.Insert();
                end;
                if GuiAllowed then
                    Window.Update(2, SpecialGroup.Code);
                AttachSpecialGroupToItem(SpecialGroup);
            until Division.Next() = 0;
        if GuiAllowed then
            Window.Close();
    end;

    local procedure AttachSpecialGroupToItem(var SpecialGroup: Record "LSC Item Special Groups")
    var
        Item: Record Item;
        ItemSpecialGrpLink: Record "LSC Item/Special Group Link";
    begin
        Item.SetCurrentKey("LSC Division Code");
        Item.SetFilter("LSC Division Code", SpecialGroup.Code);
        if Item.FindSet() then
            repeat
                if GuiAllowed then
                    Window.Update(3, Item."No.");
                if not ItemSpecialGrpLink.Get(Item."No.", SpecialGroup.Code) then begin
                    if GuiAllowed then
                    Window.Update(4, StrSubstNo('%1 %2',SpecialGroup.Code, Item."No."));    
                    ItemSpecialGrpLink.Init();
                    ItemSpecialGrpLink.Validate("Item No.", item."No.");
                    ItemSpecialGrpLink.Validate("Special Group Code", SpecialGroup.Code);
                    ItemSpecialGrpLink.Insert();
                end;
            until Item.Next() = 0;
    end;

    var
        Window: Dialog;
        ItemSpecialGroupMsg: Label 'Checking Item           #3######\';
        ItemSpecialGroupMsg2: Label 'Creating Item Special Group           #4######\';
        SpecialGroupMsg: Label 'Special Group               #2######\';
}
