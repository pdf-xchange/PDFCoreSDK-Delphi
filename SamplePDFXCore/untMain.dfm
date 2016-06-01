object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Delphi Examples for PDF-XChangeCore SDK '
  ClientHeight = 675
  ClientWidth = 899
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 899
    Height = 656
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    TabOrder = 0
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 398
      Height = 430
      AutoSize = True
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 656
    Width = 899
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object MainMenu1: TMainMenu
    Left = 40
    Top = 24
    object File1: TMenuItem
      Caption = 'File'
      object Open2: TMenuItem
        Action = FileOpen1
      end
      object SaveAs1: TMenuItem
        Action = FileSaveAs1
      end
      object FileClose1: TMenuItem
        Action = FileClose
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = FileExit1
      end
    end
    object Doc: TMenuItem
      Caption = 'Document'
      object insertPage1: TMenuItem
        Action = insertPage
      end
      object deletePage1: TMenuItem
        Action = deletePage
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object PagetoBitmap1: TMenuItem
        Action = RenderPage
      end
      object DrawPage1: TMenuItem
        Action = DrawPage
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Action = About
      end
    end
  end
  object ActionList1: TActionList
    Left = 120
    Top = 24
    object FileExit1: TFileExit
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit|Quits the application'
      ImageIndex = 43
    end
    object FileOpen1: TFileOpen
      Category = 'File'
      Caption = '&Open...'
      Dialog.DefaultExt = 'pdf'
      Dialog.Filter = 'PDF file (*.pdf)|*.pdf|All files (*.*)|*.*'
      Hint = 'Open|Opens an existing file'
      ImageIndex = 7
      ShortCut = 16463
      OnAccept = FileOpen1Accept
    end
    object insertPage: TAction
      Category = 'File'
      Caption = 'Insert Page'
      ShortCut = 16429
      OnExecute = insertPageExecute
      OnUpdate = DocUpdate
    end
    object deletePage: TAction
      Category = 'File'
      Caption = 'Delete Page'
      ShortCut = 16430
      OnExecute = deletePageExecute
      OnUpdate = DocUpdate
    end
    object About: TAction
      Category = 'File'
      Caption = 'About'
      OnExecute = AboutExecute
    end
    object RenderPage: TAction
      Caption = 'Page to Bitmap'
      OnExecute = RenderPageExecute
      OnUpdate = DocUpdate
    end
    object FileClose: TAction
      Category = 'File'
      Caption = 'Close'
      ShortCut = 16471
      OnExecute = FileCloseExecute
      OnUpdate = DocUpdate
    end
    object DrawPage: TAction
      Caption = 'Draw Text to Page'
      OnExecute = DrawPageExecute
      OnUpdate = DocUpdate
    end
    object FileSaveAs1: TFileSaveAs
      Category = 'File'
      Caption = 'Save &As...'
      Dialog.DefaultExt = '*.pdf'
      Dialog.FileName = 'NewFile.pdf'
      Dialog.Filter = 'PDF file (*.pdf)|*.pdf'
      Hint = 'Save As|Saves the active file with a new name'
      ImageIndex = 30
      ShortCut = 16467
      OnAccept = FileSaveAs1Accept
    end
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 200
    Top = 24
  end
  object PXC_Inst1: TPXC_Inst
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 280
    Top = 24
  end
end
