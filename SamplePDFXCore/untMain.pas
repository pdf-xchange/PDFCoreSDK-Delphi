unit untMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Menus,
  Vcl.OleServer, Vcl.OleCtrls, Vcl.StdActns, Vcl.ExtCtrls, PDFXCoreAPI_TLB,
  Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    FileOpenDialog1: TFileOpenDialog;
    File1: TMenuItem;
    FileExit1: TFileExit;
    Exit1: TMenuItem;
    N1: TMenuItem;
    FileOpen1: TFileOpen;
    Open2: TMenuItem;
    Doc: TMenuItem;
    insertPage: TAction;
    deletePage: TAction;
    insertPage1: TMenuItem;
    deletePage1: TMenuItem;
    About: TAction;
    Help1: TMenuItem;
    About1: TMenuItem;
    N2: TMenuItem;
    RenderPage: TAction;
    PagetoBitmap1: TMenuItem;
    FileClose: TAction;
    FileClose1: TMenuItem;
    DrawPage: TAction;
    DrawPage1: TMenuItem;
    PXC_Inst1: TPXC_Inst;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    StatusBar1: TStatusBar;
    FileSaveAs1: TFileSaveAs;
    SaveAs1: TMenuItem;
    procedure FileOpen1Accept(Sender: TObject);
    procedure insertPageExecute(Sender: TObject);
    procedure deletePageExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AboutExecute(Sender: TObject);
    procedure RenderPageExecute(Sender: TObject);
    procedure DocUpdate(Sender: TObject);
    procedure DrawPageExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FileCloseExecute(Sender: TObject);
    procedure FileSaveAs1Accept(Sender: TObject);
  private
    FDoc: IPXC_Document;
    procedure BuildPageBitmap(APage: IPXC_Page; var B: TBitmap; ASize: Integer);
    procedure OpenFile(doc: IPXC_Document);
    procedure CloseFile(var doc: IPXC_Document);
    procedure DrawText(doc: IPXC_Document);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  About, untImageView, uDocAuthCallback, math, matrix;

const
  licKeyDEMO
    : string =
    'dEmOk4WZ3uxwI/9oEZODemogFi61n61nNVt6UTzu16hUPvDEmots7yE5IUcd4Z+NvMgQzdQ1' +
    '7lAG3IrDeMogTpzOfxzKsRfNQRD9UqkyyZx6sYwPrDtnWzndqSV/zSl+0QpJ5b8QtdemOBsq' +
    '8511v3l+sgec6JExR944vi35DEMOGC1GOsXDd9LzSU/Eg9TY/Y3yctxyh5UA9ljIWviQ9W4T' +
    'OzDmaiyv5giyCPYwO2HyZdemoa3fi8zpvOy2EeYgWvfPSGjRqxlCT1a0wBxpNe4QB5R6tr+X' +
    'qR9JPV/p8DJ4vRqDDsDEMOX4xm/iXP3fdz/1KQs/elwMqwtUUrJYjzvDu7AwBpWEQ9so04ZO' +
    'baGYL3C6N/oaKioFL+0d7cyEA+2+/CdEMoelQKDEVqvEUxatrMJsD6yald01Cd1DA1eq7Tt1' +
    'b3vn58E2dEMobiBmg4qkdOpLtjcYxh69t3BVtKxmu6uyXZd+gO0NZxHkQT+6/U1334DEMO+H' +
    '"oou1/TmICS9GS6p+nfTQLZpButSOkGfaT7V17n6NkTvSKwLtrwDEMO==';

  strCaption = 'Delphi Examples for PDF-XChangeCore SDK';

procedure TForm1.AboutExecute(Sender: TObject);
begin
  AboutBox.Parent := Self;
  AboutBox.ShowModal;
end;

function P2X(x, dpi: double): double;
begin
  Result := (x / 72) * dpi;
end;

procedure TForm1.BuildPageBitmap(APage: IPXC_Page; var B: TBitmap;
  ASize: Integer);
var
  AWidth, AHeight: double;
  W, H, ADPI: Integer;
  ARect: tagRECT;
  APageMatrix: PXC_Matrix;
  AMatrixRect: PXC_Matrix;
  AFlags: Integer;
  ARenderParams: IPXC_PageRenderParams;
  AOCContext: IPXC_OCContext;
  srcRect: PXC_Rect;
begin
  ADPI := 300;
  if (B.PixelFormat = pfDevice) then
    B.PixelFormat := pf24bit;
  // Get Page dimensions in Points
  APage.GetDimension(AWidth, AHeight);
  // Make Sure the Image is not Too Big
  if (AHeight > AWidth) then
  begin
    if (P2X(AHeight, 100) > 4400) or (P2X(AWidth, 100) > 3400) then
      ADPI := 100;
  end
  else
  begin
    if (P2X(AWidth, 100) > 4400) or (P2X(AHeight, 100) > 3400) then
      ADPI := 100;
  end;
  // Convert to Pixes
  ADPI := Max(100, ADPI);
  W := Round(P2X(AWidth, ADPI));
  H := Round(P2X(AHeight, ADPI));

  if (ASize <= 0) then
    ASize := Max(H, W);

  if (H > W) then
  begin
    W := Ceil(ASize * (W / H));
    H := ASize;
  end
  else
  begin
    H := Ceil(ASize * (H / W));
    W := ASize;
  end;
  with ARect do
  begin
    Left := 0;
    Top := 0;
    Right := Left + W;
    Bottom := Top + H;
  end;
  B.SetSize(W, H);
  // Getting source page matrix
  APage.GetMatrix(PBox_PageBox, APageMatrix);
  AFlags := DDF_AsVector;
  ARenderParams := nil;
  AOCContext := nil;
  // Getting source page Page Box without rotation
  APage.get_Box(PBox_PageBox, srcRect);
  // Getting visual source Page Box by transforming it through matrix
  TransformRect(APageMatrix, srcRect);
  // We'll insert the visual src page into the image rectangle including page rotations and clipping
  AMatrixRect := RectToRectMatrix(srcRect, ARect);
  APageMatrix := Multiply(APageMatrix, AMatrixRect);
  APage.DrawToDevice(B.Canvas.Handle, ARect, APageMatrix, AFlags, ARenderParams, AOCContext, nil);
end;

procedure TForm1.CloseFile(var doc: IPXC_Document);
var
  bmp: TBitmap;
begin
  Caption := strCaption;
  if (Assigned(doc)) then
  begin
    doc.Close(0);
    doc := nil;
  end;
  bmp := TBitmap.Create;
  Image1.Picture.Bitmap := bmp;
end;

procedure TForm1.deletePageExecute(Sender: TObject);
var
  AUXInst: IAUX_Inst;
  ACount: Cardinal;
  ABitSet: IBitSet;
  APrg: IProgressMon;
  AUndo: IPXC_UndoRedoData;
begin
   if not Assigned(FDoc) then
      exit;

   AUXInst := PXC_Inst1.GetExtension('AUX') as IAUX_Inst;
   FDoc.Pages.Get_Count(ACount);
   ABitSet := AUXInst.CreateBitSet(ACount);
   ABitSet.Set_(0, 1, true);
   FDoc.Pages.DeletePages(ABitSet, APrg, AUndo);
   OpenFile(FDoc);
end;

procedure TForm1.FileCloseExecute(Sender: TObject);
begin
  CloseFile(FDoc);
end;

procedure TForm1.FileOpen1Accept(Sender: TObject);
var
  i: Integer;
  clb: TDocAuthCallback;
begin
  CloseFile(FDoc);

  clb := TDocAuthCallback.Create(PXC_Inst1);
  for i := 0 to FileOpen1.Dialog.Files.Count - 1 do
  begin
    FDoc := PXC_Inst1.OpenDocumentFromFile(PWideChar(FileOpen1.Dialog.Files[i]),
      clb, nil, 0, 0);
    Break;
  end;
  OpenFile(FDoc);
end;

procedure TForm1.FileSaveAs1Accept(Sender: TObject);
var
  str: String;
  AProg: IProgressMon;
begin
  if Assigned(FDoc) then
  begin
    str := FileSaveAs1.Dialog.FileName;
    FDoc.WriteToFile(@str[1], AProg, 0);
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseFile(FDoc);
  PXC_Inst1.Finalize;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  i: Integer;
  clb: TDocAuthCallback;
  str: String;
begin
  PXC_Inst1.Init(@licKeyDEMO[1]);
  try
    clb := TDocAuthCallback.Create(PXC_Inst1);
    str := ExtractFilePath(Application.ExeName) + '..\..\YourNewFile.pdf';
    FDoc := PXC_Inst1.OpenDocumentFromFile(PWideChar(str), clb, nil, 0, 0);
    OpenFile(FDoc);
  except

  end;
end;

procedure TForm1.insertPageExecute(Sender: TObject);
var
  Arc: PXC_Rect;
  ArcRes: PXC_Rect;
  APrg: IProgressMon;
  AUndo: IPXC_UndoRedoData;
  APage: IPXC_Page;
begin
   if not Assigned(FDoc) then
      exit;

  Arc.left := 0;
  Arc.top := 40;
  Arc.right := 80;
  Arc.bottom := 0;
  FDoc.Pages.AddEmptyPages(0, 1, Arc, APrg, AUndo);
  OpenFile(FDoc);
end;

procedure TForm1.OpenFile(doc: IPXC_Document);
var
  APage: IPXC_Page;
  bmp: TBitmap;
  ACount: Cardinal;
begin
   if not Assigned(FDoc) then
      exit;

  doc.Pages.Get_Count(ACount);
  Caption := strCaption + ' - ' +  doc.SrcInfo.DispTitle;
  StatusBar1.Panels[0].Text := ' File Title: "' + doc.SrcInfo.DispFileTitle + '" Pages: 1 of ' + IntToStr(ACount);
  doc.Pages.Get_Item(0, APage);
  bmp := TBitmap.Create;
  BuildPageBitmap(APage, bmp, -1);
  Image1.Picture.Bitmap := bmp;
end;

procedure TForm1.DocUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(FDoc);
end;

procedure TForm1.DrawPageExecute(Sender: TObject);
begin
   if not Assigned(FDoc) then
      exit;

  DrawText(FDoc);
  OpenFile(FDoc);
end;

procedure TForm1.DrawText(doc: IPXC_Document);
var
  CC: IPXC_ContentCreator;
  Content: IPXC_Content;
  AFont: IPXC_Font;
  AText: String;
  AFontSize, x, y: Double;
  APage: IPXC_Page;
begin
  if Assigned(doc) then
  begin
    AFontSize := 15;
    AText := 'TESTING';
    AFont := doc.CreateNewFont('Arial', 0, 400);
    doc.Pages.Get_Item(0, APage); //Test Page is 612 x 792 points
    //Start roughly in the middle of the page
    x := 5;
    y := 25;

    CC := doc.CreateContentCreator;
    CC.SetTextRenderMode(TRM_Fill); //TRM_None;
    CC.SetFont(AFont);
    CC.SetFontSize(AFontSize);
    CC.SetStrokeColorRGB(0); //Black
    CC.ShowTextLine(x, y, PChar(AText), -1, 0);
    CC.Detach(Content);
    APage.PlaceContent(Content, PlaceContent_After);
  end;
end;

procedure TForm1.RenderPageExecute(Sender: TObject);
var
  APage: IPXC_Page;
  bmp: TBitmap;
begin
  FDoc.Pages.Get_Item(0, APage);
  bmp := TBitmap.Create;
  BuildPageBitmap(APage, bmp, 2048);
  Form2.Image1.Picture.Bitmap := bmp;
  Form2.Show();
end;

end.
