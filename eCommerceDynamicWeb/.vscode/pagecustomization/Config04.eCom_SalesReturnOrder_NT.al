pagecustomization eCom_SalesReturnOrder_NT customizes "Sales Return Order"
{
    actions
    {
        modify("Cred&it Memos")
        {
            Promoted = false;
        }
        modify("Return Receipts")
        {
            Promoted = false;
        }
        modify(Customer)
        {
            Promoted = false;
        }
        modify("F&unctions")
        {
            Visible = false;
        }
        modify(Action13)
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
        modify(Statistics)
        {
            Promoted = false;
        }
        modify(Dimensions)
        {
            Promoted = false;
        }
        modify(AttachAsPDF)
        {
            Promoted = false;
            Visible = false;
        }
        modify("Post and &Print")
        {
            Visible = false;
        }
        modify("Preview Posting")
        {
            Visible = false;
        }
        modify(Post)
        {
            Visible = false;
        }

        modify(Approvals)
        {
            Promoted = false;
        }
        modify("Co&mments")
        {
            Promoted = false;
        }
        modify(GetPostedDocumentLinesToReverse)
        {
            Visible = false;
        }
        modify("Apply Entries")
        {
            Visible = false;
        }
        modify("Create Return-Related &Documents")
        {
            Visible = false;
        }
    }
}
