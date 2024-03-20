pagecustomization eCom_SalesOrderList_NT customizes "Sales Order List"
{
    actions
    {
        modify("Print Confirmation")
        {
            Promoted = false;
        }
        modify(AttachAsPDF)
        {
            Promoted = false;
            Visible = false;
        }
        modify(Post)
        {
            Promoted = false;
        }
        modify(PostAndSend)
        {
            Promoted = false;
        }
        modify("Post &Batch")
        {
            Promoted = false;
        }
        modify("Preview Posting")
        {
            Promoted = false;
        }
        modify("Sales Reservation Avail.")
        {
            Promoted = false;
            Visible = false;
        }
        modify("F&unctions")
        {
            Visible = false;
        }
        modify(Action3)
        {
            Visible = false;
        }
        modify("P&osting")
        {
            Visible = false;
        }
        modify("Email Confirmation")
        {
            Visible = false;
        }
        modify(Display)
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
        modify("S&hipments")
        {
            Promoted = false;
        }
        modify(PostedSalesInvoices)
        {
            Promoted = false;
        }
        modify("&Print")
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
    }
}
