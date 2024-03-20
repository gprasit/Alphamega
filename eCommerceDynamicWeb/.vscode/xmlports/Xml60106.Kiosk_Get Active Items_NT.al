xmlport 60106 "Kiosk_Get Active Items_NT"
{
    Caption = 'Get Active Items';
    UseDefaultNamespace = true;
    FormatEvaluate = Xml;
    Namespaces = soap = 'http://schemas.xmlsoap.org/soap/envelope/'
                 , xsi = 'http://www.w3.org/2001/XMLSchema-instance'
                 , xsd = 'http://www.w3.org/2001/XMLSchema';


    schema
    {
        textelement(RootNodeName)
        {
            tableelement(RedemptionCategory; "Kiosk Redemption Header_NT")
            {
                MinOccurs = Zero;
                SourceTableView = where(Active = const(true));
                fieldelement(Name; RedemptionCategory.Category)
                {
                }
                fieldelement(Description; RedemptionCategory.Description)
                {
                }
                fieldelement(DescriptionGR; RedemptionCategory."Description GR")
                {
                }
                fieldelement(DescriptionRU; RedemptionCategory."Description RU")
                {
                }
                fieldelement(ImageFileName; RedemptionCategory."Image File Name")
                {
                    trigger OnBeforePassField()
                    var
                    begin
                        RedemptionCategory."Image File Name" := eComGenFn.ReplaceText(RedemptionCategory."Image File Name", '\', '\\');
                    end;
                }

                textelement(SubCatCount)
                {
                    trigger OnBeforePassVariable()
                    var
                        SubCat: Record "Kiosk Redem. Subcategory_NT";
                    begin
                        SubCat.SetFilter(Category, RedemptionCategory.Category);
                        SetAreaFilter(SubCat, CityIn);
                        SubCatCount := Format(SubCat.Count);
                    end;
                }
                textelement(SubCategory)
                {
                    tableelement(RedemptionSubCategory; "Kiosk Redem. Subcategory_NT")
                    {
                        MinOccurs = Zero;
                        fieldelement(Name; RedemptionSubCategory.Code)
                        {
                        }
                        fieldelement(Description; RedemptionSubCategory.Description)
                        {
                        }
                        fieldelement(DescriptionGR; RedemptionSubCategory."Description GR")
                        {
                        }
                        fieldelement(DescriptionRU; RedemptionSubCategory."Description RU")
                        {
                        }
                        fieldelement(ImageFileName; RedemptionSubCategory."Image File Name")
                        {
                            trigger OnBeforePassField()
                            begin
                                RedemptionSubCategory."Image File Name" := eComGenFn.ReplaceText(RedemptionSubCategory."Image File Name", '\', '\\');
                            end;
                        }
                        fieldelement(Category; RedemptionSubCategory.Category)
                        {
                        }
                        textelement(City)
                        {
                            trigger OnBeforePassVariable()
                            var
                                GenFn: Codeunit "eCom_General Functions_NT";
                            begin
                                City := format(GenFn.Integer2Binary(RedemptionSubCategory."Area"));
                            end;
                        }
                        textelement(CategoryItems)
                        {
                            tableelement(RedemptionCategoryItem; "Kiosk Redemption Line_NT")
                            {
                                MinOccurs = Zero;
                                fieldelement(ItemNo; RedemptionCategoryItem."Item No.")
                                {
                                }
                                fieldelement(Title; RedemptionCategoryItem.Title)
                                {
                                }
                                fieldelement(Description; RedemptionCategoryItem.Description)
                                {
                                }
                                fieldelement(DetailedDescription; RedemptionCategoryItem."Detailed Description")
                                {
                                }
                                fieldelement(DescriptionGR; RedemptionCategoryItem."Description GR")
                                {
                                }
                                fieldelement(DetailedDescriptionGR; RedemptionCategoryItem."Detailed Description GR")
                                {
                                }
                                fieldelement(DescriptionRU; RedemptionCategoryItem."Description RU")
                                {
                                }
                                fieldelement(DetailedDescriptionRU; RedemptionCategoryItem."Detailed Description RU")
                                {
                                }
                                fieldelement(ImageFileName; RedemptionCategoryItem."Image File Name")
                                {
                                    trigger OnBeforePassField()
                                    begin
                                        RedemptionCategoryItem."Image File Name" := eComGenFn.ReplaceText(RedemptionCategoryItem."Image File Name", '\', '\\');
                                    end;
                                }
                                fieldelement(StartingDate; RedemptionCategoryItem."Starting Date")
                                {
                                }
                                fieldelement(EndingDate; RedemptionCategoryItem."Ending Date")
                                {
                                }
                                fieldelement(Points; RedemptionCategoryItem.Points)
                                {
                                }
                                fieldelement(VoucherTermsFileName; RedemptionCategoryItem."Voucher Terms Text File Name")
                                {
                                    trigger OnBeforePassField()
                                    begin
                                        RedemptionCategoryItem."Voucher Terms Text File Name" := eComGenFn.ReplaceText(RedemptionCategoryItem."Voucher Terms Text File Name", '\', '\\');
                                    end;
                                }
                                fieldelement(VoucherTermsFileNameGR; RedemptionCategoryItem."Vou. Terms Text File Name GR")
                                {
                                    trigger OnBeforePassField()
                                    begin
                                        RedemptionCategoryItem."Vou. Terms Text File Name GR" := eComGenFn.ReplaceText(RedemptionCategoryItem."Vou. Terms Text File Name GR", '\', '\\');
                                    end;
                                }
                                fieldelement(VoucherTermsFileNameRU; RedemptionCategoryItem."Vou. Terms Text File Name RU")
                                {
                                    trigger OnBeforePassField()
                                    begin
                                        RedemptionCategoryItem."Vou. Terms Text File Name RU" := eComGenFn.ReplaceText(RedemptionCategoryItem."Vou. Terms Text File Name RU", '\', '\\');
                                    end;
                                }
                                fieldelement(Location; RedemptionCategoryItem."Location Description")
                                {
                                }
                                trigger OnPreXmlItem()
                                begin
                                    RedemptionCategoryItem.SetFilter(Category, RedemptionCategory.Category);
                                    RedemptionCategoryItem.SetFilter("Sub Category", RedemptionSubCategory.Code);
                                    RedemptionCategoryItem.SetFilter("Starting Date", '<=%1', Today);
                                    RedemptionCategoryItem.SetFilter("Ending Date", '>=%1', Today);
                                    RedemptionCategoryItem.SetFilter(Active, '%1', true);
                                end;
                            }
                        }
                        trigger OnPreXmlItem()
                        var
                        begin
                            RedemptionSubCategory.SetFilter(Category, RedemptionCategory.Category);
                            SetAreaFilter(RedemptionSubCategory, CityIn);
                        end;

                    }
                }
                trigger OnAfterGetRecord()
                var
                    KioskRedemLine: Record "Kiosk Redemption Line_NT";
                    KioskRedemSubCat: Record "Kiosk Redem. Subcategory_NT";
                    SkipIteration: Boolean;
                begin
                    SkipIteration := false;
                    KioskRedemSubCat.SetFilter(Category, RedemptionCategory.Category);
                    SetAreaFilter(KioskRedemSubCat, CityIn);
                    SkipIteration := (KioskRedemSubCat.Count = 0);
                    if not SkipIteration then begin
                        KioskRedemSubCat.FindSet();
                        repeat
                            KioskRedemLine.SetFilter(Category, KioskRedemSubCat.Category);
                            KioskRedemLine.SetFilter("Sub Category", KioskRedemSubCat.Code);
                            KioskRedemLine.SetFilter("Starting Date", '<=%1', Today);
                            KioskRedemLine.SetFilter("Ending Date", '>=%1', Today);
                            KioskRedemLine.SetFilter(Active, '%1', true);
                            SkipIteration := not KioskRedemLine.FindFirst();
                        until ((KioskRedemSubCat.Next() = 0) or SkipIteration);
                    end;
                    if SkipIteration then
                        currXMLport.Skip();
                end;
            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    procedure SetValues(City: Integer)
    begin
        CityIn := City;
    end;

    local procedure SetAreaFilter(var KioskRedemSubCat: Record "Kiosk Redem. Subcategory_NT"; AreaIn: Integer)
    var
    begin
        case AreaIn of
            0:
                KioskRedemSubCat.SetFilter("Area", '<>%1', 0);
            22:
                KioskRedemSubCat.SetFilter(Nicosia, '%1', true);
            23:
                KioskRedemSubCat.SetFilter(Famagusta, '%1', true);
            24:
                KioskRedemSubCat.SetFilter(Larnaca, '%1', true);
            25:
                KioskRedemSubCat.SetFilter(Limassol, '%1', true);
            26:
                KioskRedemSubCat.SetFilter(Paphos, '%1', true);
        end;
    end;

    var
        eComGenFn: Codeunit "eCom_General Functions_NT";
        CityIn: Integer;
        TxtBuilder: TextBuilder;
}
