pageextension 60008 "Posted Statement List_NT" extends "LSC Posted Statement List"
{
    layout
    {

    }

    actions
    {

    }

    trigger OnOpenPage()
    var
    begin
        TreasRoleCenterMgmt.FilterPostedStatements(Rec);
    end;

    var
        TreasRoleCenterMgmt: Codeunit "Treasury Role Center Mgt._NT";
}