table 60134 "MA_Member Attr Value Update_NT"
{
    Caption = 'Member Attribute Value Update';
    DataClassification = CustomerContent;
    LookupPageId = "MA_Member Attr Value Update_NT";

    fields
    {
        field(1; "Type"; Option)
        {
            Caption = 'Type';
            OptionMembers = "New Member","Use Coupon";
            DataClassification = CustomerContent;
        }
        field(2; "Club Code"; Code[10])
        {
            Caption = 'Club Code';
            TableRelation = "LSC Member Club";
            DataClassification = CustomerContent;
        }
        field(3; "Member Attribute"; Code[10])
        {
            Caption = 'Member Attribute';
            TableRelation = "LSC Member Attribute";
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                if "Member Attribute" <> xRec."Member Attribute" then
                    if "Member Attribute" = '' then
                        "Member Attribute Value" := ''
                    else begin
                        MemberAttribute.Get("Member Attribute");
                        if MemberAttribute."Default Value" <> '' then
                            "Member Attribute Value" := MemberAttribute."Default Value"
                        else
                            "Member Attribute Value" := '';
                    end;
            end;
        }
        field(4; "Member Attribute Value"; Text[30])
        {
            Caption = 'Member Attribute Value';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                if "Member Attribute Value" <> xRec."Member Attribute Value" then begin
                    MemberAttribute.GET("Member Attribute");
                    "Member Attribute Value" := MemberAttribute.TestCurrentInput("Member Attribute Value", DATABASE::"LSC Offer");
                end;
            end;

            trigger OnLookup()
            var
                LookupValue: Text[30];
            begin
                if "Member Attribute" <> '' then begin
                    MemberAttribute.GET("Member Attribute");
                    LookupValue := MemberAttribute.RunLookup("Member Attribute Value");
                    if LookupValue <> '' then
                        Validate("Member Attribute Value", LookupValue);
                end;
            end;
        }
    }
    keys
    {
        key(PK; Type, "Club Code", "Member Attribute")
        {
            Clustered = true;
        }
    }
    var

        MemberAttribute: Record "LSC Member Attribute";
}
