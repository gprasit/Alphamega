controladdin "SGN SGNSignaturePad"
{
    MaximumHeight = 720;
    // MinimumHeight = 400;
    MinimumHeight = 200;
    MaximumWidth = 1920;
    MinimumWidth = 360;

    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    // RequestedHeight = 400;
    // RequestedWidth = 1280;
    RequestedHeight = 200;
    RequestedWidth = 640;
    Scripts = '.vscode/javascript/sign.js', 'https://cdn.jsdelivr.net/npm/signature_pad@2.3.2/dist/signature_pad.min.js';
    StyleSheets = '.vscode/css/style.css';

    event Ready()
    procedure InitializeSignaturePad()

    event Sign(Signature: Text)
}