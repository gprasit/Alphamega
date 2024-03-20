table 60015 "Treasury Cue_NT"
{
    Caption = 'Treasury Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(5; "Treasury Statements"; Integer)
        {
            Caption = 'Treasury Statements';
            CalcFormula = count("Treasury Statement_NT" where("Store Hierarchy No." = field("Store Hierarchy Filter")));
            FieldClass = FlowField;
        }
        field(10; "Treasury Statements - Posted"; Integer)
        {
            Caption = 'Treasury Statements - Posted';
            CalcFormula = count("Posted Treasury Statement_NT" where("Store Hierarchy No." = field("Store Hierarchy Filter")));
            FieldClass = FlowField;
        }
        field(15; "Overdue Sales Documents"; Integer)
        {
            CalcFormula = Count("Cust. Ledger Entry" WHERE("Document Type" = FILTER(Invoice | "Credit Memo"),
                                                            "Due Date" = FIELD("Overdue Date Filter"),
                                                            Open = CONST(true)));
            Caption = 'Overdue Sales Documents';
            FieldClass = FlowField;
        }
        field(20; "Purchase Documents Due Today"; Integer)
        {
            CalcFormula = Count("Vendor Ledger Entry" WHERE("Document Type" = FILTER(Invoice | "Credit Memo"),
                                                             "Due Date" = FIELD("Due Date Filter"),
                                                             Open = CONST(true)));
            Caption = 'Purchase Documents Due Today';
            FieldClass = FlowField;
        }
        field(25; "POs Pending Approval"; Integer)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Count("Purchase Header" WHERE("Document Type" = CONST(Order),
                                                         Status = FILTER("Pending Approval")));
            Caption = 'POs Pending Approval';
            FieldClass = FlowField;
        }
        field(30; "SOs Pending Approval"; Integer)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = Count("Sales Header" WHERE("Document Type" = CONST(Order),
                                                      Status = FILTER("Pending Approval")));
            Caption = 'SOs Pending Approval';
            FieldClass = FlowField;
        }
        field(35; "Approved Sales Orders"; Integer)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = Count("Sales Header" WHERE("Document Type" = CONST(Order),
                                                      Status = FILTER(Released | "Pending Prepayment")));
            Caption = 'Approved Sales Orders';
            FieldClass = FlowField;
        }
        field(40; "Approved Purchase Orders"; Integer)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Count("Purchase Header" WHERE("Document Type" = CONST(Order),
                                                         Status = FILTER(Released | "Pending Prepayment")));
            Caption = 'Approved Purchase Orders';
            FieldClass = FlowField;
        }
        field(45; "Vendors - Payment on Hold"; Integer)
        {
            CalcFormula = Count(Vendor WHERE(Blocked = FILTER(Payment)));
            Caption = 'Vendors - Payment on Hold';
            FieldClass = FlowField;
        }
        field(50; "Purchase Return Orders"; Integer)
        {
            AccessByPermission = TableData "Return Shipment Header" = R;
            CalcFormula = Count("Purchase Header" WHERE("Document Type" = CONST("Return Order")));
            Caption = 'Purchase Return Orders';
            FieldClass = FlowField;
        }
        field(55; "Sales Return Orders - All"; Integer)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            CalcFormula = Count("Sales Header" WHERE("Document Type" = CONST("Return Order")));
            Caption = 'Sales Return Orders - All';
            FieldClass = FlowField;
        }
        field(60; "Customers - Blocked"; Integer)
        {
            CalcFormula = Count(Customer WHERE(Blocked = FILTER(<> " ")));
            Caption = 'Customers - Blocked';
            FieldClass = FlowField;
        }
        field(65; "Overdue Purchase Documents"; Integer)
        {
            CalcFormula = Count("Vendor Ledger Entry" WHERE("Document Type" = FILTER(Invoice | "Credit Memo"),
                                                             "Due Date" = FIELD("Overdue Date Filter"),
                                                             Open = CONST(true)));
            Caption = 'Overdue Purchase Documents';
            FieldClass = FlowField;
        }
        field(70; "Purchase Discounts Next Week"; Integer)
        {
            CalcFormula = Count("Vendor Ledger Entry" WHERE("Document Type" = FILTER(Invoice | "Credit Memo"),
                                                             "Pmt. Discount Date" = FIELD("Due Next Week Filter"),
                                                             Open = CONST(true)));
            Caption = 'Purchase Discounts Next Week';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75; "Purch. Invoices Due Next Week"; Integer)
        {
            CalcFormula = Count("Vendor Ledger Entry" WHERE("Document Type" = FILTER(Invoice | "Credit Memo"),
                                                             "Due Date" = FIELD("Due Next Week Filter"),
                                                             Open = CONST(true)));
            Caption = 'Purch. Invoices Due Next Week';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80; "Due Next Week Filter"; Date)
        {
            Caption = 'Due Next Week Filter';
            FieldClass = FlowFilter;
        }
        field(85; "Due Date Filter"; Date)
        {
            Caption = 'Due Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(90; "Overdue Date Filter"; Date)
        {
            Caption = 'Overdue Date Filter';
            FieldClass = FlowFilter;
        }
        field(95; "New Incoming Documents"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Status = CONST(New)));
            Caption = 'New Incoming Documents';
            FieldClass = FlowField;
        }
        field(100; "Approved Incoming Documents"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Status = CONST(Released)));
            Caption = 'Approved Incoming Documents';
            FieldClass = FlowField;
        }
        field(105; "OCR Pending"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE("OCR Status" = FILTER(Ready | Sent | "Awaiting Verification")));
            Caption = 'OCR Pending';
            FieldClass = FlowField;
        }
        field(110; "OCR Completed"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE("OCR Status" = CONST(Success)));
            Caption = 'OCR Completed';
            FieldClass = FlowField;
        }
        field(115; "Non-Applied Payments"; Integer)
        {
            CalcFormula = Count("Bank Acc. Reconciliation" WHERE("Statement Type" = CONST("Payment Application")));
            Caption = 'Non-Applied Payments';
            FieldClass = FlowField;
        }
        field(120; "Cash Accounts Balance"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat;
            AutoFormatType = 11;
            Caption = 'Cash Accounts Balance';
            FieldClass = Normal;
        }
        field(125; "Last Depreciated Posted Date"; Date)
        {
            CalcFormula = Max("FA Ledger Entry"."FA Posting Date" WHERE("FA Posting Type" = CONST(Depreciation)));
            Caption = 'Last Depreciated Posted Date';
            FieldClass = FlowField;
        }
        field(130; "Outstanding Vendor Invoices"; Integer)
        {
            CalcFormula = Count("Vendor Ledger Entry" WHERE("Document Type" = FILTER(Invoice),
                                                             "Remaining Amount" = FILTER(< 0),
                                                             "Applies-to ID" = FILTER('')));
            Caption = 'Outstanding Vendor Invoices';
            Editable = false;
            FieldClass = FlowField;
        }
        field(135; "Store Hierarchy Filter"; Code[10])
        {
            Caption = 'Store Hierarchy Filter';
            FieldClass = FlowFilter;
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
    local procedure GetAmountFormat(): Text
    var
        ActivitiesCue: Record "Activities Cue";
    begin
        exit(ActivitiesCue.GetAmountFormat);
    end;
}

