
table 60006 "Treasury Journal Template_NT"
{
    DataClassification = CustomerContent;
    Caption = 'Treasury Journal Template';
    LookupPageID = "Treasury Journal Template";

    fields
    {
        field(1; Name; Code[20])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(5; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(10; "Posting Report ID"; Integer)
        {
            Caption = 'Posting Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Posting Report Caption");
            end;
        }
        field(20; "Page ID"; Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Page));

            trigger OnValidate()
            begin
                CalcFields("Page Caption");
            end;
        }
        field(25; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";

            trigger OnValidate()
            begin
                // SafeJnlLine.SetRange("Journal Template Name", Name);
                // SafeJnlLine.ModifyAll("Source Code", "Source Code");
                //Modify;
            end;
        }
        field(30; Recurring; Boolean)
        {
            Caption = 'Recurring';

            trigger OnValidate()
            begin
                if Recurring then
                    TestField("No. Series", '');
            end;
        }
        field(35; "Posting Report Caption"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Posting Report ID")));
            Caption = 'Posting Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Page Caption"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Page),
                                                                           "Object ID" = FIELD("Page ID")));
            Caption = 'Page Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(45; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if "No. Series" <> '' then begin
                    if Recurring then
                        Error(
                          Text000,
                          FieldCaption("Posting No. Series"));
                    if "No. Series" = "Posting No. Series" then
                        "Posting No. Series" := '';
                end;
            end;
        }
        field(50; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(Text001, "Posting No. Series"));
            end;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        // SafeJnlLine.SetRange("Journal Template Name", Name);
        // SafeJnlLine.DeleteAll;
        // SafeJnlBatch.SetRange("Journal Template Name", Name);
        // SafeJnlBatch.DeleteAll;
    end;

    trigger OnInsert()
    begin
        Validate("Page ID");
        Validate("Posting Report ID");
    end;

    var
        SafeJnlBatch: Record "LSC Store Safe Jnl. Batch";
        SafeJnlLine: Record "LSC Safe Jnl. Line";
        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';
}


