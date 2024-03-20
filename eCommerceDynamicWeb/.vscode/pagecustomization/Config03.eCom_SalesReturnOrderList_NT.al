pagecustomization eCom_SalesReturnOrderList_NT customizes "Sales Return Order List"
{
    actions
    {
        modify("Get Posted Doc&ument Lines to Reverse")
        {
            Promoted = false;
        }
        modify(Post)
        {
            Promoted = false;
        }
        modify("Post and &Print")
        {
            Promoted = false;
        }
        modify("Post and Email")
        {
            Promoted = false;
        }
        modify("Preview Posting")
        {
            Promoted = false;
        }
        modify("Post &Batch")
        {
            Promoted = false;
        }
        modify("F&unctions")
        {
            Visible = false;
        }
        modify(Action8)
        {
            Visible = false;
        }
        modify("P&osting")
        {
            Visible = false;
        }
        modify(Documents)
        {
            Visible = false;
        }
        modify(Warehouse)
        {
            Visible = false;
        }
        modify(Dimensions)
        {
            Promoted = false;
        }
        modify(Statistics)
        {
            Promoted = false;
        }
        modify("Co&mments")
        {
            Promoted = false;
        }
        modify(Approvals)
        {
            Promoted = false;
        }
        modify("&Print")
        {
            Promoted = false;
        }
        modify(AttachAsPDF)
        {
            Promoted = false;
            Visible = false;
        }
    }
}
