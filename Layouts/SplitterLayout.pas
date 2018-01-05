////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         Панели с настроенными алгоритмами выравнивания дочерних окон       //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- Примечание -------------------------------------------------------------

Вспомогательный модуль к Layouts.pas - подробные комментарии и условия
распространения см. в основном модуле

------------------------------------------------------------------------------ }

{ ----- Описание ---------------------------------------------------------------

TSplitterLayout - алгоритм выравнивания двух контролов горизонтально или
вертикально с перемещаемым разделителем между ними.

------------------------------------------------------------------------------ }

unit SplitterLayout ;

interface

uses Windows, Classes, Controls, Types, Math, BaseLayout, ExtCtrls, Forms ;

type
  { Типы свойств }
  TSplitDirection = ( sdHorizontal, sdVertical ) ;
  THideControl = ( hideNone, hideLeft, hideRight ) ;
  TResizeBehaviour = ( rsKeepLeft, rsKeepRight, rsKeepRatio ) ;
  TDefaultPosition = ( dpRatio, dpMinLeft, dpMinRight ) ;

  { Панель для выравнивания с полозком }
  TCustomSplitterLayout = class ( TFixedListLayout )
  private
    FHCursor, FVCursor : TCursor ;
    FPosition, FMinLeft, FMinRight : integer ;
    DefaultPositionYet : boolean ;
    FHideControl : THideControl ;
    FRatio : real ;
    FResize : TResizeBehaviour ;
    FDefaultPosition : TDefaultPosition ;
    FDirection : TSplitDirection ;
    FSplitter : TControl ;
    FEnableFlip : boolean ;
  protected
    { Доопределение родительских методов }
    function GetControlsRequired : integer ; override ;
    procedure ControlAdded ( Control : TControl ) ; override ;
    procedure DoLayout ( Rect : TRect ) ; override ;
    procedure DesignPaintLayout ; override ;
    { Служебные методы }
    procedure CalcLayout ( const Rect : TRect ;
                           out RectLeft, RectRight, RectSplitter : TRect ;
                           out VisibleLeft, VisibleRight : boolean ) ;
    function MaxPosition : integer ;
    procedure CorrectPosition ( var APosition : integer ) ;
    { Методы свойств }
    procedure SetDirection ( NewDirection : TSplitDirection ) ;
    procedure SetMinLeft ( NewMinLeft : integer ) ;
    procedure SetMinRight ( NewMinRight : integer ) ;
    procedure SetHideControl ( NewHideControl : THideControl ) ;
    procedure SetRatio ( NewRatio : real ) ;
    procedure SetResize ( NewResize : TResizeBehaviour ) ;
    procedure SetPosition ( NewPosition : integer ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    procedure SetParent ( AParent : TWinControl ) ; override ;
    procedure SetBounds ( ALeft, ATop, AWidth, AHeight : integer) ; override ;
    procedure FlipDirection ;
    procedure SetDefaultPosition ;
  protected
    property BottomControl : TControl index 1 read GetControl write SetControl stored false ;
    property DefaultPosition : TDefaultPosition read FDefaultPosition write FDefaultPosition ;
    property Direction : TSplitDirection read FDirection write SetDirection ;
    property EnableFlip : boolean read FEnableFlip write FEnableFlip ;
    property HCursor : TCursor read FHCursor write FHCursor ;
    property HideControl : THideControl read FHideControl write SetHideControl ;
    property LeftControl : TControl index 0 read GetControl write SetControl ;
    property MinLeft : integer read FMinLeft write SetMinLeft ;
    property MinRight : integer read FMinRight write SetMinRight ;
    property Ratio : real read FRatio write SetRatio ;
    property ResizeBehaviour : TResizeBehaviour read FResize write SetResize ;
    property RightControl : TControl index 1 read GetControl write SetControl ;
    property Position : integer read FPosition write SetPosition ;
    property TopControl : TControl index 0 read GetControl write SetControl stored false ;
    property VCursor : TCursor read FVCursor write FVCursor ;
  end ;

implementation

uses LayoutMisc ;

resourcestring
  SInternal001 = 'Внутренняя ошибка #1: неожиданное значение Direction';

{ TSplitter }

type
  { Компонент - полозок }
  TSplitter = class ( TTransparentPanel )
  private
    Active : boolean ;
    DeltaX, DeltaY : integer ;
  protected
    procedure Paint ; override ;
    procedure DblClick ; override ;
    procedure MouseDown ( Button : TMouseButton ; Shift : TShiftState ;
                          X, Y : integer ) ; override ;
    procedure MouseUp   ( Button : TMouseButton ; Shift : TShiftState ;
                          X, Y : integer ) ; override ;
    procedure MouseMove ( Shift : TShiftState; X, Y : integer ) ; override ;
  public
    function Layout : TCustomSplitterLayout ;
  end ;

{ Панель, на которой лежит полозок }
function TSplitter.Layout : TCustomSplitterLayout ;
begin
  Assert ( Assigned ( Parent ) and ( Parent is TCustomSplitterLayout )) ;
  Result := Parent as TCustomSplitterLayout ;
end ;

{ Отрисовка полозка в активном и в неактивном состоянии }
procedure TSplitter.Paint ;
var
  DC  : THandle ;
  Mid, Shift : integer ;
begin
  DC := 0 ;
  if Active then
    try
      DC := GetDCEx ( Self.Handle, 0, DCX_PARENTCLIP or DCX_CACHE or {DCX_CLIPSIBLINGS or}
                      DCX_LOCKWINDOWUPDATE ) ;
      case Layout.Direction of
        sdHorizontal : begin
                         Mid := Width div 2 ;
                         if Width > 2 then Shift := 1 else Shift := 0 ;
                         BitBlt ( DC, Mid - Shift, 0, 1, Height, 0, 0, 0, DSTINVERT ) ;
                         if Shift > 0 then
                           BitBlt ( DC, Mid + Shift, 0, 1, Height, 0, 0, 0, DSTINVERT ) ;
                       end ;
        sdVertical   : begin
                         Mid := Height div 2 ;
                         if Height > 2 then Shift := 1 else Shift := 0 ;
                         BitBlt ( DC, 0, Mid - Shift, Width, 1, 0, 0, 0, DSTINVERT ) ;
                         if Shift > 0 then
                           BitBlt ( DC, 0, Mid + Shift, Width, 1, 0, 0, 0, DSTINVERT ) ;
                       end ;
      end ;
    finally
      ReleaseDC ( Self.Handle, DC ) ;
    end
  else
    inherited ;
end ;

{ Реакция на двойной щелчок по полозку }
procedure TSplitter.DblClick ;
begin
  Layout.SetDefaultPosition ;
end ;

{ Реакция на нажатие кнопки мыши }
procedure TSplitter.MouseDown ( Button : TMouseButton ; Shift : TShiftState ;
                                X, Y : integer ) ;
begin
  { Нажали левую кнопку - начинаем тащить }
  if ( Button = mbLeft ) and ( Shift = [ ssLeft ]) then
  begin
    DeltaX := X ;
    DeltaY := Y ;
    Active := true ;
    Invalidate ;
    exit ;
  end ;
  { Нажали обе кнопки разом - перебрасываем направление }
  if ( Button in [ mbLeft, mbRight ]) and
     ( Shift = [ ssLeft, ssRight ]) and
     ( Layout.EnableFlip or Layout.IsDesigning ) then
  begin
    Active := false ;
    Layout.FlipDirection ;
  end ;
end ;

{ Реакция на отпускание кнопки мыши - завершаем перемещение }
procedure TSplitter.MouseUp ( Button : TMouseButton ; Shift : TShiftState ;
                              X, Y : integer ) ;
begin
  if not Active or ( Button <> mbLeft ) then exit ;
  Active := false ;
  Invalidate ;
end ;

{ Реакция на перемещение курсора - перемещение полозка в том же направлении }
procedure TSplitter.MouseMove ( Shift : TShiftState; X, Y : integer ) ;
var
  NewPosition, FinalPosition : integer ;
  P : TPoint ;
begin
  if not Active then exit ;
  Assert ( Layout <> nil ) ;
  P := Mouse.CursorPos ;
  case Layout.Direction of
    sdHorizontal : NewPosition := Layout.Position + X - DeltaX ;
    sdVertical   : NewPosition := Layout.Position + Y - DeltaY ;
    else raise ELayout.Create ( Self, SInternal001 ) ;
  end ;
  FinalPosition := NewPosition ;
  Layout.CorrectPosition ( FinalPosition ) ;
  if NewPosition <> FinalPosition then
  begin
    case Layout.Direction of
      sdHorizontal : Inc ( P.X, FinalPosition - NewPosition ) ;
      sdVertical   : Inc ( P.Y, FinalPosition - NewPosition ) ;
    end ;
    Mouse.CursorPos := P ;
  end ;
  Layout.Position := FinalPosition ;
end ;

{ TCustomSplitterLayout }

constructor TCustomSplitterLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  FHCursor := crHSplit ;
  FVCursor := crVSplit ;
  FMinLeft := 50 ;
  FMinRight := 50 ;
  FRatio   := 0.25 ;
  Width    := 400 ;
  Height   := 300 ;
  FSplitter := TSplitter.Create ( nil ) ;
  RegisterServiceControl ( FSplitter ) ;
  FSplitter.Parent := Self ;
  Self.DoubleBuffered := true ;
end ;

{ Доопределение родительских методов }

procedure TCustomSplitterLayout.SetParent ( AParent : TWinControl ) ;
begin
  inherited ;
  if not Assigned ( AParent ) then exit ;
  if not DefaultPositionYet then SetDefaultPosition ;
  DefaultPositionYet := true ;
end ;

{ Реакция на изменение размеров компонента }
procedure TCustomSplitterLayout.SetBounds ( ALeft, ATop, AWidth, AHeight : integer) ;
var SavedSize, NewSize : integer ;
begin
  try
    DisableLayout ;
    SavedSize := MaxPosition ;
    inherited ;
    NewSize := MaxPosition ;
    if NewSize = SavedSize then exit ;
    case ResizeBehaviour of
      rsKeepRight : Position := Position + NewSize - SavedSize ;
      rsKeepRatio : Position := Round ( NewSize * Position / SavedSize ) ;
    end ;
  finally
    EnableLayout ;
  end ;
end ;

function TCustomSplitterLayout.GetControlsRequired : integer ;
begin
  Result := 2 ;
end ;

{ Размещение нового дочернего компонента }
procedure TCustomSplitterLayout.ControlAdded ( Control : TControl ) ;
var
  VisibleLeft, VisibleRight : boolean ;
  RectLeft, RectRight, RectSplitter : TRect ;
  P : TPoint ;
begin
  Assert ( Control <> nil ) ;
  CalcLayout ( LayoutRect, RectLeft, RectRight, RectSplitter, VisibleLeft, VisibleRight ) ;
  P := ScreenToClient ( Control.ClientOrigin ) ;
  if VisibleLeft and PtInRect ( RectLeft, P ) and ( LeftControl = nil ) then
    LeftControl := Control
  else if VisibleRight and PtInRect ( RectRight, P ) and ( RightControl = nil ) then
    RightControl := Control
  else
    inherited ;
  if Control is TWinControl then TWinControl ( Control ).DoubleBuffered := true ;
end ;

{ Расстановка компонент }
procedure TCustomSplitterLayout.DoLayout ( Rect : TRect ) ;
var
  RectLeft, RectRight, RectSplitter : TRect ;
  VisibleLeft, VisibleRight : boolean ;
begin
  CorrectPosition ( FPosition ) ;
  CalcLayout ( Rect, RectLeft, RectRight, RectSplitter, VisibleLeft, VisibleRight ) ;
  FSplitter.BoundsRect := RectSplitter ;
  FSplitter.BringToFront ;
  if Direction = sdHorizontal
    then FSplitter.Cursor := HCursor
    else FSplitter.Cursor := VCursor ;
  if Assigned ( LeftControl ) then
  begin
    LeftControl.BoundsRect := RectLeft ;
    LeftControl.Visible := VisibleLeft ;
  end ;
  if Assigned ( RightControl ) then
  begin
    RightControl.BoundsRect := RectRight ;
    RightControl.Visible := VisibleRight ;
  end ;
end ;

procedure TCustomSplitterLayout.DesignPaintLayout ;
var
  R1, R2, R3 : TRect ;
  V1, V2 : boolean ;
begin
  if ( Margins.Left > 0 ) or ( Margins.Top > 0 ) or ( Margins.Right > 0 ) or
     ( Margins.Bottom > 0 ) then inherited ;
  CalcLayout ( LayoutRect, R1, R2, R3, V1, V2 ) ;
  if V1 and not Assigned ( LeftControl ) then DrawDesignRect ( R1 ) ;
  if V2 and not Assigned ( RightControl ) then DrawDesignRect ( R2 ) ;
end ;

{ Служебные методы }

procedure TCustomSplitterLayout.CalcLayout ( const Rect : TRect ;
                                             out RectLeft, RectRight, RectSplitter : TRect ;
                                             out VisibleLeft, VisibleRight : boolean ) ;
const
  RectInvalid : TRect = ( Left : -MaxInt ; Top : -MaxInt ;
                          Right : -MaxInt ; Bottom : -MaxInt ) ;
begin
  VisibleLeft := true ;
  VisibleRight := true ;
  RectSplitter := RectInvalid ;
  if HideControl = hideLeft then
    begin
      RectLeft := RectInvalid ;
      RectRight := Rect ;
      VisibleLeft := false ;
    end
  else if HideControl = hideRight then
    begin
      RectLeft := Rect ;
      RectRight := RectInvalid ;
      VisibleRight := false ;
    end
  else if Direction = sdVertical then
    begin
      RectLeft := Classes.Rect ( Rect.Left, Rect.Top, Rect.Right, Rect.Top + Position ) ;
      RectRight := Classes.Rect ( Rect.Left, Rect.Top + Position + Margins.Vert,
                                  Rect.Right, Rect.Bottom ) ;
      RectSplitter := Classes.Rect ( Rect.Left, RectLeft.Bottom,
                                     Rect.Right, RectRight.Top ) ;
    end
  else
    begin
      RectLeft := Classes.Rect ( Rect.Left, Rect.Top, Rect.Left + Position, Rect.Bottom ) ;
      RectRight := Classes.Rect ( Rect.Left + Position + Margins.Horiz, Rect.Top,
                                  Rect.Right, Rect.Bottom ) ;
      RectSplitter := Classes.Rect ( RectLeft.Right, Rect.Top,
                                     RectRight.Left, Rect.Bottom ) ;
    end ;
end ;

{ Определение физически возможного диапазона позиций для разделителя }
function TCustomSplitterLayout.MaxPosition : integer ;
begin
  if Direction = sdVertical then
    begin
      if HandleAllocated then Result := ClientHeight else Result := Height ;
      Dec ( Result, Margins.Top + Margins.Bottom + Margins.Vert ) ;
    end
  else
    begin
      if HandleAllocated then Result := ClientWidth else Result := Width ;
      Dec ( Result, Margins.Left + Margins.Right + Margins.Horiz ) ;
    end ;
end ;

{ Перевод в позицию по умолчанию }
procedure TCustomSplitterLayout.SetDefaultPosition ;
begin
  if Parent = nil then exit ;
  case DefaultPosition of
    dpMinLeft  : Position := MinLeft ;
    dpMinRight : Position := MaxPosition - MinRight ;
    dpRatio    : Position := Round ( Ratio * MaxPosition ) ;
  end ;
end ;

{ Подгонка позиции разделителя под ограничения }
procedure TCustomSplitterLayout.CorrectPosition ( var APosition : integer ) ;
begin
  if MinLeft + MinRight >= MaxPosition then
    APosition := Round ( MinLeft * MaxPosition / ( MinLeft + MinRight ))
  else
    APosition := Min ( MaxPosition - MinRight, Max ( MinLeft, APosition )) ;
end ;

{ Изменение ориентации разделителя }
procedure TCustomSplitterLayout.FlipDirection ;
begin
  case Direction of
    sdHorizontal : Direction := sdVertical ;
    sdVertical   : Direction := sdHorizontal ;
  end ;
  Modified ;
end ;

{ Методы свойств }

procedure TCustomSplitterLayout.SetHideControl ( NewHideControl : THideControl ) ;
begin
  if FHideControl = NewHideControl then exit ;
  FHideControl := NewHideControl ;
  RequestLayout ;
end ;

procedure TCustomSplitterLayout.SetDirection ( NewDirection : TSplitDirection ) ;
begin
  if FDirection = NewDirection then exit ;
  FDirection := NewDirection ;
  RequestLayout ;
end ;

procedure TCustomSplitterLayout.SetMinLeft ( NewMinLeft : integer ) ;
begin
  if NewMinLeft < 0 then NewMinLeft := 0 ;
  if FMinLeft = NewMinLeft then exit ;
  FMinLeft := NewMinLeft ;
  RequestLayout ;
end ;

procedure TCustomSplitterLayout.SetMinRight ( NewMinRight : integer ) ;
begin
  if NewMinRight < 0 then NewMinRight := 0 ;
  if FMinRight = NewMinRight then exit ;
  FMinRight := NewMinRight ;
  RequestLayout ;
end ;

procedure TCustomSplitterLayout.SetPosition ( NewPosition : integer ) ;
begin
  if FPosition = NewPosition then exit ;
  FPosition := NewPosition ;
  RequestLayout ;
  Modified ;
end ;

procedure TCustomSplitterLayout.SetRatio ( NewRatio : real ) ;
begin
  FRatio := NewRatio ;
end ;

procedure TCustomSplitterLayout.SetResize ( NewResize : TResizeBehaviour ) ;
begin
  FResize := NewResize ;
end ;

end.

