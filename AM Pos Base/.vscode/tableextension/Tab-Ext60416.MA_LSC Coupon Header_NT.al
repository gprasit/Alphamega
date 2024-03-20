tableextension 60416 "MA_LSC Coupon Header_NT" extends "LSC Coupon Header"
{
    fields
    {
        field(60101; "Check Member Quantity"; Boolean)
        {
            Caption = 'Check Member Quantity';
            DataClassification = CustomerContent;
        }
        field(60102; "Member Attribute"; Code[10])
        {
            Caption = 'Member Attribute';
            DataClassification = CustomerContent;
            TableRelation = "LSC Member Attribute".Code;
            trigger OnValidate()
            var
                MemberAttribute: Record "LSC Member Attribute";
            begin
                if "Member Attribute" <> xRec."Member Attribute" then begin
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
            end;
        }
        field(60103; "Member Attribute Value"; Text[30])
        {
            Caption = 'Member Attribute Value';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                MemberAttribute: Record "LSC Member Attribute";
            begin
                if "Member Attribute Value" <> xRec."Member Attribute Value" then begin
                    MemberAttribute.GET("Member Attribute");
                    "Member Attribute Value" := MemberAttribute.TestCurrentInput("Member Attribute Value", DATABASE::"LSC Offer");
                end;
            end;

            trigger OnLookup()
            var
                MemberAttribute: Record "LSC Member Attribute";
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
        field(60104; "Point Value"; Decimal)
        {
            Caption = 'Point Value';
            DataClassification = CustomerContent;
        }
        field(60105; "Amount to Trigger"; Decimal)
        {
            Caption = 'Amount to Trigger';
            DataClassification = CustomerContent;
        }
        field(60106; "Amt. to Trigger Based on Lines"; Boolean)
        {
            Caption = 'Amt. to Trigger Based on Lines';
            DataClassification = CustomerContent;
        }
        field(60107; "Amount To Issue"; Decimal)
        {
            Caption = 'Amount To Issue';
            DataClassification = CustomerContent;
        }
        field(60108; "Amount To Issue Base"; Option)
        {
            Caption = 'Amount To Issue Base';
            OptionMembers = "Transaction Total","Coupon Lines";
            DataClassification = CustomerContent;
        }
        field(60109; "Tender Type"; Code[20])
        {
            Caption = 'Tender Type';
            TableRelation = "LSC Tender Type Setup".Code WHERE("Default Function" = CONST(Coupons));
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                TestField(Handling, Handling::Tender);
            end;
        }
        field(60110; "No. Series From Server"; Boolean)
        {
            Caption = 'No. Series From Server';
            DataClassification = CustomerContent;
        }
        field(60111; "Member Not. Primary Text"; Text[40])
        {
            Caption = 'Member Not. Primary Text';
            DataClassification = CustomerContent;
        }
        field(60112; "Member Not. Secondary Text"; Text[160])
        {
            Caption = 'Member Not. Secondary Text';
            DataClassification = CustomerContent;
        }
        field(60113; "Member Notification Image ID"; Code[20])
        {
            Caption = 'Member Notification Image ID';
            TableRelation = "LSC Retail Image";
            DataClassification = CustomerContent;
        }
        field(60114; "Member Notification Display"; Option)
        {
            Caption = 'Member Notification Display';
            OptionMembers = Always,Once;
            DataClassification = CustomerContent;
        }
        field(60115; "Member Notification Date Calc."; DateFormula)
        {
            Caption = 'Member Notification Date Calc.';
            DataClassification = CustomerContent;
        }
    }
}
