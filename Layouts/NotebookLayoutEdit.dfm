object FormNotebookLayoutEdit: TFormNotebookLayoutEdit
  Left = 334
  Top = 295
  BorderIcons = [biSystemMenu]
  Caption = 'Notebook Layout'
  ClientHeight = 392
  ClientWidth = 338
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object BorderLayout: TBorderLayout
    Left = 0
    Top = 0
    Width = 338
    Height = 392
    Background = lbDefault
    Active = True
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    RightControl = panButtons
    CenterControl = listPages
    SettingsGuid = (
      '')
    object panButtons: TFlowLayout
      Left = 253
      Top = 5
      Width = 80
      Height = 382
      Background = lbTransparent
      Active = True
      Align = alNone
      BevelInner = bvNone
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      AutoHeight = 0
      Direction = fdVertTopBottom
      SettingsGuid = (
        '')
      object btnMoveUp: TButton
        Left = 0
        Top = 0
        Width = 80
        Height = 25
        Action = aMoveUp
        TabOrder = 0
      end
      object btnMoveDown: TButton
        Left = 0
        Top = 30
        Width = 80
        Height = 25
        Action = aMoveDown
        TabOrder = 1
      end
      object btnOk: TButton
        Left = 0
        Top = 60
        Width = 80
        Height = 25
        Action = aOK
        TabOrder = 2
      end
      object btnApply: TButton
        Left = 0
        Top = 90
        Width = 80
        Height = 25
        Action = aApply
        Caption = '?????????'
        TabOrder = 3
      end
      object btnCancel: TButton
        Left = 0
        Top = 120
        Width = 80
        Height = 25
        Action = aCancel
        Caption = '??????'
        TabOrder = 4
      end
    end
    object listPages: TStsListBox
      Left = 5
      Top = 5
      Width = 243
      Height = 382
      ItemHeight = 13
      ScrollWidth = 5
      TabOrder = 1
      AutoHint = ahSmart
      DragItems = True
      HorizScroll = True
    end
  end
  object Actions: TActionList
    Left = 32
    Top = 64
    object aMoveUp: TAction
      Caption = '????'
      ShortCut = 16422
      OnExecute = aMoveUpExecute
      OnUpdate = aMoveUpUpdate
    end
    object aMoveDown: TAction
      Caption = '????'
      ShortCut = 16424
      OnExecute = aMoveDownExecute
      OnUpdate = aMoveDownUpdate
    end
    object aOK: TAction
      Caption = 'OK'
      OnExecute = aOKExecute
    end
    object aApply: TAction
      Caption = 'Apply'
      OnExecute = aApplyExecute
      OnUpdate = aApplyUpdate
    end
    object aCancel: TAction
      Caption = 'Cancel'
      OnExecute = aCancelExecute
    end
  end
end
