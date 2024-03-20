table 60420 "eVch_eVoucher Header_NT"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GeneralSetup.Get();
                    NoSeriesMgt.TestManual(GeneralSetup."eVoucher Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(5; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
        }
        field(10; Description; Text[20])
        {
            Caption = 'Description';
        }
        field(15; "Invoice No."; Text[20])
        {
            Caption = 'Invoice No.';
        }
        field(20; Status; Option)
        {
            OptionMembers = Open,"Pending Approval",Released,Posted,Cancelled;
            OptionCaption = 'Open,Pending Approval,Released,Posted,Cancelled';
        }
        field(25; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            trigger OnValidate()
            var
                Cust: Record Customer;
            begin
                if Cust.Get("Customer No.") then
                    "Customer Name" := Cust.Name;
            end;
        }
        field(30; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(35; "Member Card No."; Text[100])
        {
            Caption = 'Member Card No.';
            TableRelation = "LSC Membership Card";
            trigger OnValidate()
            var
                MemberContact: Record "LSC Member Contact";
                MembershipCard: Record "LSC Membership Card";
            begin
                if MembershipCard.Get("Member Card No.") then
                    if MemberContact.GET(MembershipCard."Account No.", MembershipCard."Contact No.") then
                        "Member Contact Name" := MemberContact.Name;
            end;
        }
        field(40; "Member Contact Name"; Text[100])
        {
            Caption = 'Member Contact Name';
        }
        field(45; Prefix; Code[7])
        {
            Caption = 'Prefix';
        }
        field(50; "Data Entry Type"; Code[20])
        {
            TableRelation = "LSC POS Data Entry Type";
            trigger OnValidate()
            var
                DataEntryType: Record "LSC POS Data Entry Type";
                AmountEditable: Boolean;
            begin
                if DataEntryType.GET("Data Entry Type") then begin
                    Prefix := DataEntryType.Prefix;
                    AmountEditable := DataEntryType."Amount Editable";
                end;
            end;
        }
        field(55; "Amount Code"; Code[10])
        {
            Caption = 'Amount Code';
            TableRelation = "eVch_Create Data Entry Amt_NT";
            trigger OnValidate()
            var
                CreateDataEntryAmount: Record "eVch_Create Data Entry Amt_NT";
            begin
                if CreateDataEntryAmount.Get("Amount Code") then
                    Amount := CreateDataEntryAmount.Amount;
            end;
        }
        field(60; Amount; Decimal)
        {
            Caption = 'Amount';
            Editable = false;
        }
        field(65; "Creation Nos."; Option)
        {
            Caption = 'Creation Nos.';
            OptionMembers = Random,"Number Series";
            OptionCaption = 'Random,Number Series';
        }
        field(70; "Send e-Mail"; Boolean)
        {
            Caption = 'Send e-Mail';
        }
        field(75; "Creation No. Series"; Code[10])
        {
            Caption = 'Creation No. Series';
            TableRelation = "No. Series";
        }
        field(80; "Line Total Amount"; Decimal)
        {
            Caption = 'Line Total Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("eVch_eVoucher Line_NT"."Line Amount" where("Document No." = field("No.")));
        }
        field(85; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
        }
        field(90; "Template File Name"; Text[250])
        {
            Caption = 'Template File Name';
            trigger OnLookup()
            var
                iStream: InStream;
                oStream: OutStream;
                iLine: Text;
                Env: DotNet Environment;
            begin
                "Template File Name" := '';
                Clear(Template);
                UploadIntoStream('Import File', '', 'html files (*.html)|*.html|All files (*.*)|*.*', "Template File Name", iStream);
                if "Template File Name" <> '' then begin
                    Clear(Template);
                    Template.CreateOutStream(oStream);
                    while not iStream.EOS do begin
                        iStream.ReadText(iLine);
                        oStream.WriteText(iLine + Env.NewLine);
                    end;
                end;
            end;
        }
        field(95; Template; Blob)
        {
            Caption = 'Template';
        }

    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; Status)
        {
        }
    }

    var
        eVoucherEmailQueue: Record "eVch_eVoucher Email Queue_NT";
        eVoucherLine: Record "eVch_eVoucher Line_NT";
        GeneralSetup: Record "eCom_General Setup_NT";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            GeneralSetup.Get();
            GeneralSetup.TestField("eVoucher Nos.");
            NoSeriesMgt.InitSeries(GeneralSetup."eVoucher Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        "Send e-Mail" := true;
    end;

    trigger OnModify()
    begin
        TestStatusOpen;
    end;

    trigger OnDelete()
    begin
        TestStatusOpen;
        if LineExist then
            eVoucherLine.DeleteAll();
        eVoucherEmailQueue.SetRange("Created by Receipt No.", "No.");
        if not eVoucherEmailQueue.IsEmpty then
            eVoucherEmailQueue.DeleteAll();
    end;

    trigger OnRename()
    begin
        Error('You cannot rename this record.');
    end;

    procedure AssistEdit(OldRec: Record "eVch_eVoucher Header_NT"): Boolean
    var
        eVoucher: Record "eVch_eVoucher Header_NT";
    begin
        with eVoucher do begin
            eVoucher := Rec;
            GeneralSetup.Get();
            GeneralSetup.TestField("eVoucher Nos.");
            if NoSeriesMgt.SelectSeries(GeneralSetup."eVoucher Nos.", OldRec."No. Series", "No. Series") THEN begin
                NoSeriesMgt.SetSeries("No.");
                Rec := eVoucher;
                exit(true);
            end;
        end;
    end;

    procedure TestStatusOpen()
    begin
        TestField(Status, Status::Open);
    end;

    local procedure LineExist(): Boolean
    begin
        eVoucherLine.SetRange("Document No.", "No.");
        exit(eVoucherLine.FindSet());
    end;
}