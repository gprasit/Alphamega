controladdin "PDF Viewer"
{
    Scripts = 'https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.3.1.min.js', 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.8.335/pdf.min.js', '.vscode/javascript/script.js';

    StartupScript = '.vscode/javascript/Startup.js';
    StyleSheets = '.vscode/css/stylesheet.css', 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css';

    MinimumHeight = 1;
    MinimumWidth = 1;
    MaximumHeight = 2000;
    HorizontalStretch = true;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalShrink = true;
    event ControlAddinReady();
    event onView()
    procedure LoadPDF(PDFDocument: Text; IsFactbox: Boolean)
    procedure SetVisible(IsVisible: Boolean)
}