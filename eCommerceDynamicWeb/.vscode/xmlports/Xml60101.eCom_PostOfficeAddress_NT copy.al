// xmlport 60101 eCom_PostOfficeAddress_NT
// {
//     Caption = 'Post Office Address';
//     Direction = Export;
//     FormatEvaluate = Xml;
//     Encoding = UTF8;
//     Namespaces = soap = 'http://www.w3.org/2003/05/soap-envelope'
//                 , xsi = 'http://www.w3.org/2001/XMLSchema-instance'
//                 , xsd = 'http://www.w3.org/2001/XMLSchema';
//     schema
//     {
//         textelement(Envelope)
//         {
//             NamespacePrefix = 'soap';
//             textelement(Body)
//             {
//                 NamespacePrefix = 'soap';
//                 textelement(GetPostCodeAddressResponse)
//                 {
//                     textattribute(xmlns2)
//                     {
//                         XmlName = 'xlmns';
//                         trigger OnBeforePassVariable()
//                         var
//                         begin
//                             xmlns2 := 'http://tempuri.org/';
//                         end;
//                     }
//                     textelement(GetPostCodeAddressResult)
//                     {
//                         tableelement(PostOfficeAddress; eCom_PostOfficeAddress_NT)
//                         {
//                             fieldelement(EntryNo; PostOfficeAddress."Entry No.")
//                             {
//                             }
//                             textelement(ColSuccess)
//                             {
//                                 XmlName = 'Success';
//                                 trigger OnBeforePassVariable()
//                                 begin
//                                     ColSuccess := 'true';
//                                 end;
//                             }
//                             fieldelement(PostalCode; PostOfficeAddress."Postal Code")
//                             {
//                             }
//                             fieldelement(City; PostOfficeAddress.City)
//                             {
//                             }
//                             fieldelement("Area"; PostOfficeAddress."Area")
//                             {
//                             }
//                             fieldelement(StreetName; PostOfficeAddress."Street Name")
//                             {
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//     }
//     requestpage
//     {
//         layout
//         {
//             area(content)
//             {
//                 group(GroupName)
//                 {
//                 }
//             }
//         }
//         actions
//         {
//             area(processing)
//             {
//             }
//         }
//     }

// }
