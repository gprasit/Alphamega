query 60101 "MA_Published Offers_NT"
{
    Caption = 'Published Offers';
    QueryType = Normal;

    elements
    {
        dataitem(Published_Offer; "LSC Published Offer")
        {
            column(No; "No.")
            {
            }
            column(Discount_Type; "Discount Type")
            {
            }
            column(Discount_No; "Discount No.")
            {
            }
            column(Description; Description)
            {
            }
            column(Offer_Category; "Offer Category")
            {
            }
            column(Primary_Text; "Primary Text")
            {
            }
            column(Secondary_Text; "Secondary Text")
            {
            }
            column(Valid_To_Date; "Valid To Date")
            {
            }
            column(Member_Type; "Member Type")
            {
            }
            column(Member_Value; "Member Value")
            {
            }
            column(Member_Attribute; "Member Attribute")
            {
            }
            column(Member_Attribute_Value2; "Member Attribute Value")
            {
            }
            column(Status; Status)
            {
            }
            column(Display_Order; "Display Order")
            {
            }
            dataitem(Validation_Period; "LSC Validation Period")
            {
                DataItemLink = ID = Published_Offer."Validation Period ID";
                column(ID; ID)
                {
                }
                column(Ending_Date; "Ending Date")
                {
                }
            }
        }
    }


    trigger OnBeforeOpen()
    begin

    end;
}
