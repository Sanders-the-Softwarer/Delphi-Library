////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//        ������ � ������������ ����������� ������������ �������� ����        //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- ������� ----------------------------------------------------------------

����� �������� ����� �������������� ���� ������, ������������ ���, ������������
� ����������� ����������� ��������, � ��� ����� ������������, ��� �������������
� �������������� ����������� �� ������. � ����� ������ ������ ������ �����������
���������� �� ��������� ������ � �������� ��������������� ������.

��� ��������������� ������������ ������ ������ ����� �������� ��� ������ �
�������� ������ ��� �������������� �������� ����� ����������� ��������� �������.

���� �� ������� ���������� ��������� � �������� �������������� �� �� ����
�������� - �������� � ���, � �� ��������� ��������� ����� ��������� � ���������
������ ������. ����� ����� �������� � ��������� �������, ���� ����� �����.

�����: Sanders Prostorov, 2:5020/1583, softwarer@mail.ru, softwarer@nm.ru

��������� ������ ����� ����� �������� �� http://softwarer.ru

------------------------------------------------------------------------------ }

{ ----- ���������� ������ ------------------------------------------------------

���� ���� �������� ����� ���������, ����������� ��������� JDK-���� layout-��.
��� ���������� ������������� ����������� ���� �������� ���������� (� ��� �����
������ layout-�) � ������������ � ���������� ���������� � ����������� ��������
��� ��������, ��� � �������� ���������� ����������, �������� �������� ���
��������� Align, Anchors, OnResize ���. � � �� �� ����� �����������
������������� ����� ��� ��������� ��������, ��������� � ������ ���������
���������.

��� ������������� ��������������� Use_TabOrder ������������� ������������ ������
TabOrder, � ���������� ���� ����� ������ ��������� ������������� ���������������
������� ������ ��������� � ����������.

����������: ��� ���������� �� ��������� JDK; ����� ������������ �����������
���������� � ���� "��������� ���������" ������ ����� ����������� ������
��-�������, ������ � Java.

������������� ���������:

  TDelphiLayout    ���������� ����������� ��������� Delphi (Align, Anchors ���).
                   �� ���� ������� ������, �� ������������� �������������
                   TabOrder-� � ����������� ����� ������ ����������������,
                   ������� ����� ��������� � ������� ����� TLayout

  TFlowLayout      ������������� �������� ���������� � ���� ��� (��������������
                   ��� ������������) � ����������� ������������ ����� ����.
                   ��� �������������� ������������ ������������ � ���� ���������
                   ���������� ������ � ����� ������������ ���������� ������; ���
                   ������������ ������������ ������������ ���������� ������ �
                   ����� ������������ ������.

                   ������������ ��� ���������� ������� ������ � �����������
                   �������.

  TBorderLayout    ������������� �������� ���������� "���� � ������, ���������
                   �� �����" �������� ���������� �������� Align, �� ���������
                   ������ ����� � ������ ������� ��������� � ���������� �����
                   ������� � ������, � ����� ������������ ��������� �����
                   ������������.

  TNotebookLayout  �������� ���������� ���������� TNotebook. � ������ ������
                   ������� ����� ������ ���� �� ����������� �����������,
                   ���������� �� ��� ������� ������.

                   � ��������� ������ TNotebookLayout �� �������� �����������
                   ��������� TTabSet ��� ����������� ���������������� - ���
                   ����� ����� ������������ TPageControl. � �� �� ����� ��
                   ��������� ���������� �������� TNotebook ���, ��� �����
                   �������� �� ����� - ������, � ������� ���� ��������� �
                   ��������.

  TDualListLayout  ������������� �������� ���������� � ������ "�������� ������":
                   ����� � ������ ������ ������ ������ �, ��������, �����������
                   ������ � �������� ����� ����.

  TFrameLayout     ������������ ��� ���������� ��������� � ������ ��������� �
                   ��������������, �������� ��������� ���. �����������
                   ���������� � ������� �������� �����, ����������� ����������
                   ������ ����������� � �������� � ��������� �� ������ �
                   �������.

��� ���������� ������ TFrameLayout ��������� ������ RecordList, ������� �����
����� ���� ������ �� http://softwarer.ru

------------------------------------------------------------------------------ }

{ ----- �������� � ���������� --------------------------------------------------

����������� ������� ����� TConstrainedLayout � �� ��� ������ - TFrameLayout

����������� ����� "����������" ��� ������������� � FrameLayout/BorderLayout

�������� � BorderLayout ��������� ����������

DockLayout - ���-�� ���� PaneLayout, ���������� ��� �������

�������� � GridLayout/BoxLayout ��� ���������� � ��� �������

------------------------------------------------------------------------------ }

{ ----- ������� ��������� ------------------------------------------------------

13.12.2004 ���������� ��������� ������ ��������� � ����� ����; ����� ��������
           ����� ������ � ����������� ��������� �������, � ��������� � ����
           �������������� ������� ������. �����������: ������� ����� TLayout,
           ������ TDelphiLayout, TFlowLayout, TNotebookLayout. ���� ��
           ������������ ����������� TabOrder-��.
16.12.2004 ���������� TDualListLayout
18.12.2004 ���������� TBorderLayout, ������� ����� TFixedListLayout
20.12.2004 TDualListLayout ��������� ����� TFixedListLayout

------------------------------------------------------------------------------ }

unit Layouts ;

interface

uses
  Classes, BasicLayouts, FlowLayout, BorderLayout, DualLayout, FrameLayout,
  ConstraintedLayout, NotebookLayout, InputLayout, SplitterLayout,
  LayoutSettings ;

type

  { ������� ������������ Delphi }
  TDelphiLayout = class ( TCustomDelphiLayout ) ;

  { ��������� ������������ }
  TFlowLayout = class ( TCustomFlowLayout )
  published
    property AutoHeight ;
    property AutoWidth ;
    property Direction ;
    property Margins ;
  end ;

  { ������ ������, ����������� � ActionList-� }
  TActionPane = class ( TCustomActionPane )
  published
    property Actions ;
    property Category ;
  end;

  { ��������������� ������������ }
  TNotebookLayout = class ( TCustomNotebookLayout )
  public
    property Pages ;
  published
    property ActivePage ;
    property AutoSelectFirst ;
    property OnChanging ;
    property OnChange ;
  end ;

  { ������������ ������ ����� ������ }
  TInputLayout = class ( TCustomInputLayout )
  published
    property AutoLabelWidth ;
    property LabelWidth ;
    property LabelAlignment ;
    property RubberControl ;
  end ;

  { ������������ �������� ������ }

  TDualLayout = class ( TCustomDualLayout )
  published
    property Margins ;
    property LeftControl ;
    property RightControl ;
    property CenterControl ;
  end ;

  TVerticalDualLayout = class ( TCustomVerticalDualLayout )
  published
    property Margins ;
    property LeftControl ;
    property RightControl ;
    property CenterControl ;
  end ;

  { ������������ "�� �����" }
  TBorderLayout = class ( TCustomBorderLayout )
  published
    property Margins ;
    property TopControl ;
    property LeftControl ;
    property RightControl ;
    property BottomControl ;
    property CenterControl ;
    property SubTopControl ;
    property SubBottomControl ;
  end ;

  { ������������ ��� ���� ���������/�������������� }
  TFrameLayout = class ( TCustomFrameLayout )
  published
    property Margins ;
    property Constraints ;
  end ;

  { ������ ��� ������������ � �������� }
  TSplitterLayout = class ( TCustomSplitterLayout )
  published
    property BottomControl ;
    property DefaultPosition ;
    property Direction ;
    property EnableFlip ;
    property HCursor ;
    property HideControl ;
    property LeftControl ;
    property MinLeft ;
    property MinRight ;
    property Ratio ;
    property ResizeBehaviour ;
    property RightControl ;
    property Position ;
    property TopControl ;
    property VCursor ;
  end;

procedure Register;

implementation

procedure Register ;
begin
  RegisterComponents ( 'Layouts', [ TLayoutSettings, TDelphiLayout,
    TBorderLayout, TFlowLayout, TDualLayout, TNotebookLayout, TInputLayout,
    TActionPane, TInputLayoutLabel, TSplitterLayout {, TRuledLayout} ]) ;
end;

end.

