pagecustomization eCom_SalesOrder_NT customizes "Sales Order"
{
    actions
    {
        modify(PostAndSend)
        {
            Promoted = false;
        }
        modify(PreviewPosting)
        {
            Promoted = false;
        }
        modify(PostAndNew)
        {
            Promoted = false;
        }
        modify(Post)
        {
            Promoted = false;
        }
        modify(GetRecurringSalesLines)
        {
            Promoted = false;
        }
        modify(CopyDocument)
        {
            Promoted = false;
        }
        modify(AttachAsPDF)
        {
            Visible = false;
        }

        modify(SendEmailConfirmation)
        {
            Promoted = false;
        }
        modify(Plan)
        {
            Visible = false;
        }
        modify("F&unctions")
        {
            Visible = false;
        }
        modify("Request Approval")
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
        modify("&Print")
        {
            Visible = false;
        }
        modify("&Order Confirmation")
        {
            Visible = false;
        }
        modify(Warehouse)
        {
            Visible = false;
        }
        modify(History)
        {
            Visible = false;
        }
        modify(Prepayment)
        {
            Visible = false;
        }
        modify(AssemblyOrders)
        {
            Visible = false;
        }
        modify("Create Inventor&y Put-away/Pick")
        {
            Promoted = false;
        }
        modify(Invoices)
        {
            Promoted = false;
        }
        modify("S&hipments")
        {
            Promoted = false;
        }
        modify(Customer)
        {
            Promoted = false;
        }
        modify(Documents)
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
        modify(Approvals)
        {
            Promoted = false;
        }
        modify("Co&mments")
        {
            Promoted = false;
        }
        modify(DocAttach)
        {
            Promoted = false;
        }

    }
}
