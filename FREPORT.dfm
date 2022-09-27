object frmReport: TfrmReport
  Left = 0
  Top = 0
  Caption = 'frmReport'
  ClientHeight = 610
  ClientWidth = 877
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object RLReport1: TRLReport
    Left = 32
    Top = 0
    Width = 794
    Height = 1123
    DataSource = DataSource1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    object RLBand1: TRLBand
      Left = 38
      Top = 38
      Width = 718
      Height = 67
      BandType = btHeader
      object RLLabel1: TRLLabel
        Left = 8
        Top = 16
        Width = 270
        Height = 22
        Caption = 'Relat'#243'rio de Abastecimentos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RLDraw1: TRLDraw
        Left = 8
        Top = 53
        Width = 707
        Height = 11
        DrawKind = dkLine
      end
      object RLLabel6: TRLLabel
        Left = 596
        Top = 16
        Width = 31
        Height = 16
        Caption = 'P'#225'g.'
      end
      object RLSystemInfo2: TRLSystemInfo
        Left = 629
        Top = 16
        Width = 28
        Height = 16
        Alignment = taRightJustify
        AutoSize = False
        Info = itPageNumber
        Text = ''
      end
      object RLLabel7: TRLLabel
        Left = 658
        Top = 16
        Width = 18
        Height = 16
        Caption = 'de'
      end
      object RLSystemInfo3: TRLSystemInfo
        Left = 678
        Top = 16
        Width = 28
        Height = 16
        AutoSize = False
        Info = itLastPageNumber
        Text = ''
      end
    end
    object RLBand2: TRLBand
      Left = 38
      Top = 105
      Width = 718
      Height = 32
      BandType = btColumnHeader
      object RLLabel2: TRLLabel
        Left = 8
        Top = 3
        Width = 39
        Height = 19
        Caption = 'Data'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RLLabel3: TRLLabel
        Left = 216
        Top = 3
        Width = 62
        Height = 19
        Caption = 'Tanque'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RLLabel4: TRLLabel
        Left = 391
        Top = 3
        Width = 59
        Height = 19
        Caption = 'Bomba'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RLLabel5: TRLLabel
        Left = 619
        Top = 3
        Width = 44
        Height = 19
        Alignment = taRightJustify
        Caption = 'Valor'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RLDraw2: TRLDraw
        Left = 8
        Top = 20
        Width = 707
        Height = 9
        DrawKind = dkLine
      end
    end
    object RLBand4: TRLBand
      Left = 38
      Top = 225
      Width = 718
      Height = 22
      BandType = btFooter
      object RLSystemInfo1: TRLSystemInfo
        Left = 659
        Top = 6
        Width = 49
        Height = 14
        Alignment = taRightJustify
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        Info = itFullDate
        ParentFont = False
        Text = ''
      end
      object RLDraw3: TRLDraw
        Left = 8
        Top = -1
        Width = 707
        Height = 10
        DrawKind = dkLine
      end
    end
    object RLBand3: TRLBand
      Left = 38
      Top = 137
      Width = 718
      Height = 38
      object RLDBText1: TRLDBText
        Left = 3
        Top = 6
        Width = 117
        Height = 16
        DataField = 'DATAMOVIMENTO'
        DataSource = DataSource1
        Text = ''
      end
      object RLDBText2: TRLDBText
        Left = 216
        Top = 6
        Width = 93
        Height = 16
        DataField = 'DESCTANQUE'
        DataSource = DataSource1
        Text = ''
      end
      object RLDBText3: TRLDBText
        Left = 391
        Top = 6
        Width = 88
        Height = 16
        DataField = 'DESCBOMBA'
        DataSource = DataSource1
        Text = ''
      end
      object RLDBText4: TRLDBText
        Left = 615
        Top = 3
        Width = 48
        Height = 16
        Alignment = taRightJustify
        DataField = 'VALOR'
        DataSource = DataSource1
        Text = ''
      end
    end
    object RLBand5: TRLBand
      Left = 38
      Top = 175
      Width = 718
      Height = 50
      BandType = btSummary
      object RLDBResult1: TRLDBResult
        Left = 576
        Top = 16
        Width = 87
        Height = 16
        Alignment = taRightJustify
        DataField = 'VALOR'
        DataSource = DataSource1
        Info = riSum
        Text = ''
      end
      object RLLabel8: TRLLabel
        Left = 472
        Top = 16
        Width = 102
        Height = 16
        Caption = 'Total no Periodo:'
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = frmRelatorio.FDQueryRel
    Left = 544
    Top = 272
  end
end
