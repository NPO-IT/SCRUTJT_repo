object Form3: TForm3
  Left = 774
  Top = 252
  BorderStyle = bsNone
  Caption = #1042#1088#1077#1084#1077#1085#1085#1086#1081' '#1080#1085#1090#1077#1088#1074#1072#1083
  ClientHeight = 492
  ClientWidth = 483
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = -8
    Top = 0
    Width = 489
    Height = 489
    TabOrder = 0
    object Label1: TLabel
      Left = 64
      Top = 16
      Width = 378
      Height = 29
      Caption = #1047#1072#1076#1072#1081#1090#1077' '#1074#1088#1077#1084#1077#1085#1085#1086#1081' '#1080#1085#1090#1077#1088#1074#1072#1083
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 184
      Top = 48
      Width = 143
      Height = 29
      Caption = #1076#1083#1103' '#1079#1072#1087#1080#1089#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 56
      Top = 112
      Width = 144
      Height = 20
      Caption = #1053#1072#1095#1072#1083#1086' '#1080#1085#1090#1077#1088#1074#1072#1083#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 56
      Top = 152
      Width = 132
      Height = 20
      Caption = #1050#1086#1085#1077#1094' '#1080#1085#1090#1077#1088#1074#1072#1083#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 144
      Top = 392
      Width = 213
      Height = 29
      Caption = #1055#1088#1086#1075#1088#1077#1089#1089' '#1079#1072#1087#1080#1089#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 32
      Top = 192
      Width = 430
      Height = 29
      Caption = #1047#1072#1076#1072#1081#1090#1077' '#1087#1086#1076#1080#1085#1090#1077#1088#1074#1072#1083#1099' '#1074' '#1082#1086#1090#1086#1088#1099#1093' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 144
      Top = 224
      Width = 218
      Height = 29
      Caption = #1074#1099#1087#1086#1083#1085#1103#1090#1100' '#1087#1086#1080#1089#1082
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object MaskEdit1: TMaskEdit
      Left = 272
      Top = 104
      Width = 152
      Height = 28
      EditMask = '00.00.0000 00:00:00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      MaxLength = 19
      ParentFont = False
      TabOrder = 0
      Text = '  .  .       :  :  '
    end
    object MaskEdit2: TMaskEdit
      Left = 272
      Top = 144
      Width = 152
      Height = 28
      EditMask = '00.00.0000 00:00:00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      MaxLength = 19
      ParentFont = False
      TabOrder = 1
      Text = '  .  .       :  :  '
    end
    object Button2: TButton
      Left = 168
      Top = 312
      Width = 169
      Height = 41
      Caption = #1047#1072#1076#1072#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = Button2Click
    end
    object ProgressBar1: TProgressBar
      Left = 16
      Top = 440
      Width = 457
      Height = 41
      TabOrder = 3
    end
    object MaskEdit3: TMaskEdit
      Left = 152
      Top = 264
      Width = 202
      Height = 28
      EditMask = '0999999999999999999999'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      MaxLength = 22
      ParentFont = False
      TabOrder = 4
      Text = '                      '
    end
  end
end
