object Form1: TForm1
  Left = 208
  Top = 143
  Width = 1549
  Height = 879
  Caption = #1057#1050#1056#1059#1058#1046#1058
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = -24
    Top = 512
    Width = 1553
    Height = 265
  end
  object Splitter1: TSplitter
    Left = 0
    Top = 0
    Height = 841
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1129
    Height = 97
    TabOrder = 0
    object Label2: TLabel
      Left = 528
      Top = 8
      Width = 63
      Height = 24
      Caption = #1042#1088#1077#1084#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object timeLabel: TLabel
      Left = 656
      Top = 8
      Width = 7
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 528
      Top = 32
      Width = 74
      Height = 24
      Caption = #1064#1080#1088#1086#1090#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 528
      Top = 56
      Width = 83
      Height = 24
      Caption = #1044#1086#1083#1075#1086#1090#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelLat: TLabel
      Left = 656
      Top = 32
      Width = 7
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelLon: TLabel
      Left = 656
      Top = 56
      Width = 7
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 968
      Top = 0
      Width = 92
      Height = 22
      Caption = #1057#1082#1086#1088#1086#1089#1090#1100
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlue
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object changeFile: TButton
      Left = 0
      Top = 0
      Width = 153
      Height = 49
      Caption = #1042#1099#1073#1088#1072#1090#1100' '#1082#1072#1090#1072#1083#1086#1075
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = changeFileClick
    end
    object StartButton: TButton
      Left = 152
      Top = 0
      Width = 129
      Height = 49
      Caption = #1057#1090#1072#1088#1090' '#1088#1072#1079#1073#1086#1088#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = StartButtonClick
    end
    object StopButton: TButton
      Left = 280
      Top = 0
      Width = 121
      Height = 49
      Caption = #1057#1090#1086#1087' '#1088#1072#1079#1073#1086#1088#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = StopButtonClick
    end
    object Button1: TButton
      Left = 0
      Top = 48
      Width = 153
      Height = 49
      Caption = #1047#1072#1087'. '#1052#1075'.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 152
      Top = 48
      Width = 129
      Height = 49
      Caption = #1047#1072#1087'. '#1089#1088'.'#1082#1074'.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
    end
    object Button3: TButton
      Left = 280
      Top = 48
      Width = 121
      Height = 49
      Caption = #1047#1072#1087'. '#1072#1073#1089'.'#1084#1072#1082#1089'. '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = Button3Click
    end
  end
  object Chart1: TChart
    Left = 0
    Top = 96
    Width = 1129
    Height = 201
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    MarginLeft = 5
    MarginRight = 5
    MarginTop = 5
    Title.Font.Charset = DEFAULT_CHARSET
    Title.Font.Color = clBlue
    Title.Font.Height = -19
    Title.Font.Name = 'Arial'
    Title.Font.Style = [fsBold]
    Title.Text.Strings = (
      #1044#1080#1072#1075#1088#1072#1084#1084#1072' '#1073#1099#1089#1090#1088#1099#1093' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074)
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMaximum = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Maximum = 20.000000000000000000
    BottomAxis.Minimum = 1.000000000000000000
    LeftAxis.Automatic = False
    LeftAxis.AutomaticMaximum = False
    LeftAxis.AutomaticMinimum = False
    LeftAxis.Maximum = 256.000000000000000000
    LeftAxis.TickLength = 7
    Legend.Visible = False
    View3D = False
    TabOrder = 1
    object Series1: TBarSeries
      Cursor = crArrow
      Marks.ArrowLength = 20
      Marks.Visible = True
      SeriesColor = 4227072
      ShowInLegend = False
      OnClick = Series1Click
      BarWidthPercent = 75
      XValues.DateTime = False
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      YValues.DateTime = False
      YValues.Name = 'Bar'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
    end
  end
  object Chart2: TChart
    Left = 0
    Top = 296
    Width = 1129
    Height = 217
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Title.Font.Charset = DEFAULT_CHARSET
    Title.Font.Color = clBlue
    Title.Font.Height = -19
    Title.Font.Name = 'Arial'
    Title.Font.Style = [fsBold]
    Title.Text.Strings = (
      #1043#1080#1089#1090#1086#1075#1088#1072#1084#1084#1072' '#1073#1099#1089#1090#1088#1099#1093' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074)
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMaximum = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Maximum = 500.000000000000000000
    LeftAxis.Automatic = False
    LeftAxis.AutomaticMaximum = False
    LeftAxis.AutomaticMinimum = False
    LeftAxis.Maximum = 300.000000000000000000
    Legend.Visible = False
    View3D = False
    TabOrder = 2
    object Series2: TLineSeries
      Marks.ArrowLength = 8
      Marks.Visible = False
      SeriesColor = clRed
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.DateTime = False
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      YValues.DateTime = False
      YValues.Name = 'Y'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
    end
  end
  object GroupBox1: TGroupBox
    Left = 1128
    Top = 0
    Width = 401
    Height = 513
    Caption = #1048#1085#1092#1086' '#1088#1072#1079#1073#1080#1088#1072#1077#1084#1086#1075#1086' '#1089#1083#1086#1074#1072
    TabOrder = 3
    object Memo1: TMemo
      Left = 8
      Top = 16
      Width = 385
      Height = 481
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 3
    Top = 776
    Width = 1526
    Height = 63
    TabOrder = 4
    object Label6: TLabel
      Left = 504
      Top = 8
      Width = 131
      Height = 24
      Caption = #1053#1086#1084#1077#1088' '#1092#1072#1081#1083#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object TrackBar1: TTrackBar
      Left = 8
      Top = 40
      Width = 1505
      Height = 20
      Max = 100000
      PageSize = 1
      Position = 1
      TabOrder = 0
      OnChange = TrackBar1Change
    end
    object FileNumTrack: TTrackBar
      Left = 640
      Top = 8
      Width = 361
      Height = 33
      Max = 1
      Min = 1
      PageSize = 1
      Position = 1
      TabOrder = 1
      OnChange = FileNumTrackChange
    end
  end
  object Panel3: TPanel
    Left = 920
    Top = 24
    Width = 185
    Height = 65
    TabOrder = 5
    object Label7: TLabel
      Left = 144
      Top = 48
      Width = 30
      Height = 13
      Caption = #1052#1072#1082#1089'.'
    end
    object Label9: TLabel
      Left = 16
      Top = 48
      Width = 24
      Height = 13
      Caption = #1052#1080#1085'.'
    end
    object TrackBar2: TTrackBar
      Left = 8
      Top = 4
      Width = 169
      Height = 45
      Max = 160
      Min = 1
      Position = 20
      TabOrder = 0
      OnChange = TrackBar2Change
    end
  end
  object OpenDialog1: TOpenDialog
    Top = 96
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 488
    Top = 8
  end
end
