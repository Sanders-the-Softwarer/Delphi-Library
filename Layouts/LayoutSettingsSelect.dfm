object FormLayoutSettingsSelect: TFormLayoutSettingsSelect
  Left = 351
  Top = 340
  BorderStyle = bsDialog
  Caption = #1042#1099#1073#1086#1088' '#1076#1077#1081#1089#1090#1074#1091#1102#1097#1080#1093' '#1085#1072#1089#1090#1088#1086#1077#1082
  ClientHeight = 291
  ClientWidth = 290
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object BorderLayout1: TBorderLayout
    Left = 0
    Top = 0
    Width = 290
    Height = 291
    Background = lbSettingsGradient
    Gradient.ColorBegin = clWhite
    Gradient.ColorEnd = clBtnFace
    Gradient.Reverse = False
    Gradient.Rotation = 0
    Gradient.Shift = 0
    Gradient.Style = gsRadialBR
    Gradient.UseSysColors = False
    LayoutActive = True
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    BottomControl = FlowLayout1
    CenterControl = listDefaultSettings
    SettingsGuid = (
      '')
    object listDefaultSettings: TStsListBox
      Left = 5
      Top = 5
      Width = 280
      Height = 251
      ItemHeight = 13
      ScrollWidth = 5
      TabOrder = 0
      OnDblClick = listDefaultSettingsDblClick
      AutoHint = ahSmart
      DragItems = False
      HorizScroll = True
    end
    object FlowLayout1: TFlowLayout
      Left = 5
      Top = 261
      Width = 280
      Height = 25
      Background = lbTransparent
      Gradient.ColorBegin = clWhite
      Gradient.ColorEnd = clBtnFace
      Gradient.Reverse = False
      Gradient.Rotation = 0
      Gradient.Shift = 0
      Gradient.Style = gsRadialBR
      Gradient.UseSysColors = False
      LayoutActive = True
      Align = alNone
      BevelInner = bvNone
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      AutoWidth = 0
      Direction = fdHorizRight
      SettingsGuid = (
        '')
      object BitBtn1: TBitBtn
        Left = 125
        Top = 0
        Width = 75
        Height = 25
        Action = aSelect
        Caption = #1042#1099#1073#1088#1072#1090#1100
        TabOrder = 0
      end
      object BitBtn2: TBitBtn
        Left = 205
        Top = 0
        Width = 75
        Height = 25
        Action = aCancel
        Caption = #1054#1090#1084#1077#1085#1072
        TabOrder = 1
      end
    end
  end
  object Actions: TActionList
    Left = 240
    Top = 70
    object aSelect: TAction
      Caption = #1042#1099#1073#1088#1072#1090#1100
      ShortCut = 16397
      OnExecute = aSelectExecute
      OnUpdate = aSelectUpdate
    end
    object aCancel: TAction
      Caption = #1054#1090#1084#1077#1085#1072
      ShortCut = 8219
      OnExecute = aCancelExecute
    end
  end
end
