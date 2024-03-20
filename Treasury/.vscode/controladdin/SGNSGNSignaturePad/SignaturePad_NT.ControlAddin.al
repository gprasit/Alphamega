controladdin "Signature Pad_NT"
{
    //MaximumHeight = 720;
    MaximumHeight = 1500;
    MinimumHeight = 400;
    MaximumWidth = 1920;
    MinimumWidth = 360;

    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    RequestedHeight = 1500;
    RequestedWidth = 1280;

    Scripts = '.vscode/javascript/sign_NT.js', 'https://cdn.jsdelivr.net/npm/signature_pad@2.3.2/dist/signature_pad.min.js';
    StyleSheets = '.vscode/css/style.css';
    event Ready()
    procedure InitializeSignaturePad()

    event Sign(Signature: Text)
}