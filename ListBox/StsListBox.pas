////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                 StsListBox - ������������ ��������� TListBox               //
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

�����: Sanders Prostorov (softwarer@mail.ru, softwarer@nm.ru)

��� ���������� ����� � ������ ������� ������������� �� http://softwarer.ru
��� ��������� �� ������� � ����������� �� ����������: http://bugs.softwarer.ru

------------------------------------------------------------------------------ }

{ ----- ���������� -------------------------------------------------------------

��������� ������ ������������ ������ ������������ TListBox ����������� �� ����
�������. �� ��������� �� ����������� TListBox ��������� ��������� �������� �
�������:

  property AutoHint : TAutoHint ;

  �������� ������ ��������������� ��������� (������) ��� ��������� ���� ��
  ������ ���������. � ������ ahAlways ��������� �������� ������; � ������
  ahSmart (�� ���������) ��������� ��������, ���� ������ ����������� ��������
  �� ������. ����� ��������� ������� ��� ������ ����� ������ ��������� � �����
  ���� ������� � ������� OnGetHintFor.

  ��������� �������� ������ � ��� ������, ���� � ����� �������� ������ ���������
  (�� ���� ShowHint = true ���� �������� ����� ParentShowHint).

  property DragItems : boolean ;

  �������� drag'n'drop ��������� � ��������� (�� ��������� ���������).

  property HorizScroll : boolean ;

  �������� �������������� �������������� � ������, ���� ������ ��������� ��
  ���������� �� ������ � ���������� ����� (�� ��������� ��������).

  property OnDragging : TListBoxDragEvent ;

  �������, ������������ ��� �������������� ����� ������ ���������. ����������
  ����� ������������ ������ �� ����� �����.

  property OnDragged  : TListBoxDragEvent ;

  �������, ������������ ��� �������������� ����� ������ ���������. ����������
  ����� ����������� ������ �� ����� �����.

  property OnGetWidth : TListBoxWidthEvent ;

  �������, ������������ ��� ������������� ��������� "������" ��������� ������.
  ��������� ��������� HorizScroll � AutoHint ��������� �������� � ������
  ���������������� ��������� ����������.

  property OnGetHintFor : TGetHintForEvent ;

  �������, ������������ ����� ������� ��������� � ������� �������� AutoHint.
  ��������� ������ ����� � �������� ������������ ���������.

------------------------------------------------------------------------------ }

{ ----- ������� ������ ---------------------------------------------------------

2000-� ���. ������ ������ ����������.

14.07.2004 ��������� ���������� ��� ������ ��� Delphi 6
18.07.2004 ������ ��������� ����� �������� ���������� � ��������� �������������:
           ��������� ������ DoDragging, DoDragged, DoGetWidth. ����������
           ������: ���� ������������ "����������" ������� ����, ��� ������ �
           ������ ������
05.12.2004 ��������� �������� AutoHint

------------------------------------------------------------------------------ }

unit StsListBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Math ;

type

  TAutoHint = ( ahNone, ahSmart, ahAlways ) ;

  TListBoxDragEvent = procedure ( Sender : TObject ;
                                  OldIndex, NewIndex : integer ;
                                  var Accept : boolean ) of object ;
  TListBoxWidthEvent = procedure ( Sender : TObject ; ItemIndex : integer ;
                                   var ItemWidth : integer ) of object ;
  TGetHintForEvent = procedure ( Sender : TObject ; ItemIndex : integer ;
                                 var HintStr : string ;
                                 var HintTopLeft : TPoint ;
                                 var HintMaxWidth : integer ) of object ;

  TStsListBox = class ( TListBox )
  private
    { ��������� ������� }
    FAutoHint    : TAutoHint ;
    FDragItems   : boolean ;
    FHorizScroll : boolean ;
    FItemDragged : integer ;
    FOnDragging  : TListBoxDragEvent ;
    FOnDragged   : TListBoxDragEvent ;
    FOnGetWidth  : TListBoxWidthEvent ;
    FOnGetHintFor : TGetHintForEvent ;
    { ���������� ������ }
    procedure ProcessDrag ( NewIndex : integer ; var Accept : boolean ) ;
    procedure WmSetRedraw ( var M : TMessage ) ; message WM_SETREDRAW ;
    procedure CmFontChanged ( var M : TMessage ) ; message CM_FONTCHANGED ;
    procedure CmHintShow ( var M : TCMHintShow ) ; message CM_HINTSHOW ;
  protected
    function GetScrollExtent : integer ;
    function CalcWidth ( ItemIndex : integer ) : integer ;
    { ����� ������������ ������� }
    procedure DoDragging ( OldIndex, NewIndex : integer ;
                           var Accept : boolean ) ; dynamic ;
    procedure DoDragged  ( OldIndex, NewIndex : integer ;
                           var Accept : boolean ) ; dynamic ;
    procedure DoGetWidth ( ItemIndex : integer ;
                           var ItemWidth : integer ) ; dynamic ;
    procedure DoGetHintFor ( ItemIndex : integer ;
                             var HintStr : string ;
                             var HintTopLeft : TPoint ;
                             var HintMaxWidth : integer ) ; dynamic ;
    { ���������� ������������ ������� }
    procedure SetParent ( AParent : TWinControl ) ; override ;
    procedure DoStartDrag ( var DragObject : TDragObject ) ; override ;
    procedure DoEndDrag ( Target : TObject ; X, Y : integer ) ; override ;
    procedure DragOver ( Source : TObject ; X, Y : integer ;
                         State : TDragState ; var Accept : Boolean ) ; override ;
    procedure MouseMove ( Shift : TShiftState ; X, Y : integer ) ; override ;
    procedure DrawItem ( Index : integer ; Rect : TRect ;
                         State : TOwnerDrawState ) ; override ;
    { ������ ������� }
    procedure SetDragItems ( NewDragItems : boolean ) ;
    procedure SetHorizScroll ( NewHorizScroll : boolean ) ;
    procedure SetOnGetWidth ( NewHandler : TListBoxWidthEvent ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    procedure CreateParams ( var Params : TCreateParams ) ; override ;
    procedure UpdateHorizScrollBar ;
  public
    property ItemDragged : integer read FItemDragged ;
  published
    property AutoHint   : TAutoHint read FAutoHint write FAutoHint nodefault ;
    property DragItems   : boolean read FDragItems write SetDragItems ;
    property HorizScroll : boolean read FHorizScroll write SetHorizScroll ;
    property OnDragging : TListBoxDragEvent read FOnDragging write FOnDragging ;
    property OnDragged  : TListBoxDragEvent read FOnDragged write FOnDragged ;
    property OnGetWidth : TListBoxWidthEvent read FOnGetWidth write SetOnGetWidth ;
    property OnGetHintFor : TGetHintForEvent read FOnGetHintFor write FOnGetHintFor ;
  end;

implementation

constructor TStsListBox.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  HorizScroll := true ;
  AutoHint := ahSmart ;
end ;

procedure TStsListBox.CreateParams ( var Params : TCreateParams ) ;
begin
  inherited ;
  Params.Style := Params.Style or WS_HSCROLL ;
end ;

procedure TStsListBox.UpdateHorizScrollBar ;
var Extent : integer ;
begin
  if not Assigned ( Parent ) then exit ;
  if HorizScroll then Extent := GetScrollExtent else Extent := 0 ;
  Extent := Extent and $7FFF ; { ����� ��� Win95 }
  SendMessage ( Self.Handle, LB_SETHORIZONTALEXTENT, Extent, 0 ) ;
end ;

function TStsListBox.GetScrollExtent : integer ;
var i : integer ;
begin
  Result := 0 ;
  for i := 0 to Items.Count - 1 do
    Result := Max ( Result, CalcWidth ( i )) ;
  Inc ( Result, 5 ) ;
end ;

function TStsListBox.CalcWidth ( ItemIndex : integer ) : integer ;
begin
  Result := Canvas.TextWidth ( Items [ ItemIndex ]) ;
  DoGetWidth ( ItemIndex, Result ) ;
end ;

procedure TStsListBox.DoDragged ( OldIndex, NewIndex : integer ;
  var Accept : boolean ) ;
begin
  if Assigned ( FOnDragged ) then
    FOnDragged ( Self, OldIndex, NewIndex, Accept ) ;
end ;

procedure TStsListBox.DoDragging ( OldIndex, NewIndex : integer ;
  var Accept : boolean ) ;
begin
  if Assigned ( FOnDragging ) then
    FOnDragging ( Self, OldIndex, NewIndex, Accept ) ;
end ;

procedure TStsListBox.DoGetWidth ( ItemIndex : integer ;
                                   var ItemWidth : integer ) ;
begin
  if Assigned ( FOnGetWidth ) then
    FOnGetWidth ( Self, ItemIndex, ItemWidth ) ;
end ;

procedure TStsListBox.DoGetHintFor ( ItemIndex : integer ;
                                     var HintStr : string ;
                                     var HintTopLeft : TPoint ;
                                     var HintMaxWidth : integer ) ;
begin
  if Assigned ( FOnGetHintFor ) then
    FOnGetHintFor ( Self, ItemIndex, HintStr, HintTopLeft, HintMaxWidth ) ;
end ;

procedure TStsListBox.SetParent ( AParent : TWinControl ) ;
begin
  inherited ;
  UpdateHorizScrollBar ;
end ;

procedure TStsListBox.DoStartDrag ( var DragObject : TDragObject ) ;
var P : TPoint ;
begin
  { �������� ��������������� ������� � ������� �����������, ����� ����������
    ��� � ����� �������� }
  if DragItems and GetCursorPos ( P ) then
  begin
    P := ScreenToClient ( P ) ;
    FItemDragged := ItemAtPos ( P, true ) ;
    Invalidate ;
  end ;
  { �������� ������������ ������ ���� ���������� }
  inherited ;
end ;

procedure TStsListBox.DoEndDrag ( Target : TObject ; X, Y : integer ) ;
begin
  { ������� ��� �������������� � �������� �������� � ���������� ���� }
  if DragItems then
  begin
    FItemDragged := -1 ;
    Invalidate ;
  end ;
  { �������� ����������� ��� }
  inherited ;
end ;

procedure TStsListBox.DragOver ( Source : TObject ; X, Y : integer ;
                                 State : TDragState ; var Accept : Boolean ) ;
var CurItem : integer ;
begin
  { ���� ���� �������������� ������ ���������, �������� ��� }
  if ( Source = Self ) and ( ItemDragged >= 0 ) then
  begin
    Accept := true ;
    CurItem := ItemAtPos ( Point ( X, Y ), false ) ;
    if CurItem > Items.Count - 1
      then CurItem := Items.Count - 1
    else if CurItem < 0 then
      if Y > 0
        then CurItem := ItemDragged
      else if TopIndex = 0
        then CurItem := 0
        else CurItem := TopIndex - 1 ;
    ProcessDrag ( CurItem, Accept ) ;
    if Accept then exit ;
  end ;
  { �������� ����������� ��� }
  inherited ;
end ;

procedure TStsListBox.MouseMove ( Shift : TShiftState ; X, Y : integer ) ;
begin
  if DragItems and ( ssLeft in Shift ) then BeginDrag ( false ) ;
  inherited ;
end ;

procedure TStsListBox.DrawItem ( Index : integer ; Rect : TRect ;
                                 State : TOwnerDrawState ) ;
begin
  { ������� ������� ��� ��������� ���������������� �������� }
  if Index = FItemDragged then
    with Canvas do
    begin
      Brush.Color := clHighlightText ;
      Font.Color := clHighlight ;
    end ;
  { �������� ����������� ��������� }
  inherited ;
end ;

{ ������ ������� }

procedure TStsListBox.SetDragItems ( NewDragItems : boolean ) ;
begin
  if Dragging and not NewDragItems then CancelDrag ;
  FDragItems := NewDragItems ;
end ;

procedure TStsListBox.SetHorizScroll ( NewHorizScroll : boolean ) ;
begin
  if FHorizScroll = NewHorizScroll then exit ;
  FHorizScroll := NewHorizScroll ;
  UpdateHorizScrollBar ;
end ;

procedure TStsListBox.SetOnGetWidth ( NewHandler : TListBoxWidthEvent ) ;
begin
  FOnGetWidth := NewHandler ;
  UpdateHorizScrollBar ;
end ;

{ ���������� ������ }

procedure TStsListBox.ProcessDrag ( NewIndex : integer ; var Accept : boolean ) ;
var Delta, OldItemDragged : integer ; Dummy : boolean ;
begin
  if NewIndex = ItemDragged then exit ;
  { ������� ��������������� ����� � ������� ���������� �� �������������� }
  DoDragging ( ItemDragged, NewIndex, Accept ) ;
  if not Accept then exit ;
  { ������ ��������� ��������� ������� � ������ ����� }
  OldItemDragged := ItemDragged ;
  if ItemDragged > NewIndex then Delta := -1 else Delta := 1 ;
  while ItemDragged <> NewIndex do
  begin
    Items.Exchange ( ItemDragged, ItemDragged + Delta ) ;
    FItemDragged := ItemDragged + Delta ;
  end ;
  { ������� � ����������� }
  Dummy := true ;
  DoDragged ( OldItemDragged, NewIndex, Dummy ) ;
  { ��������� ��������� �� ������� ������� }
  ItemIndex := NewIndex ;
  { ���������� ��� }
  Invalidate ;
end ;

procedure TStsListBox.WmSetRedraw ( var M : TMessage ) ;
begin
  if M.WParam <> 0 then UpdateHorizScrollBar ;
  inherited ;
end ;

procedure TStsListBox.CmFontChanged ( var M : TMessage ) ;
begin
  inherited ;
  UpdateHorizScrollBar ;
end ;

procedure TStsListBox.CmHintShow ( var M : TCMHintShow ) ;
var
  P : TPoint ;
  HintItem, AHintMaxWidth : integer ;
  HintRect : TRect ;
  AHintStr : string ;
begin
  M.Result := 1 ;
  if AutoHint = ahNone then
    inherited
  else
    begin
      P := M.HintInfo^.CursorPos ;
      HintItem := ItemAtPos ( P, true ) ;
      if HintItem < 0 then exit ;
      if ( AutoHint = ahSmart ) and ( CalcWidth ( HintItem ) <= ClientWidth )
        then exit ;
      AHintStr := Items [ HintItem ] ;
      HintRect := ItemRect ( HintItem ) ;
      AHintMaxWidth := M.HintInfo^.HintMaxWidth ;
      DoGetHintFor ( HintItem, AHintStr, HintRect.TopLeft, AHintMaxWidth ) ;
      HintRect.TopLeft := ClientToScreen ( HintRect.TopLeft ) ;
      HintRect.BottomRight := ClientToScreen ( HintRect.BottomRight ) ;
      with M, HintInfo^ do
      begin
        CursorRect := HintRect ;
        HintStr := AHintStr ;
        HintPos.Y := HintRect.Top ;
        HintPos.X := HintRect.Left ;
        HintMaxWidth := AHintMaxWidth ;
        Result := 0 ;
      end ;
    end ;
end ;

end.
