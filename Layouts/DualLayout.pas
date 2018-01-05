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

Алгоритм выравнивания компонент в режиме двойного списка. Свойства LeftControl,
RightControl и CenterControl задают объекты, располагаемые соответственно слева,
справа и по центру (обычно это левый список, правый список и вертикальная панель
кнопок соответственно). Брошенные компоненты автоматически располагаются в
соответствующих позициях; более трех компонент не добавляется.

------------------------------------------------------------------------------ }

unit DualLayout ;

interface

uses
  Messages, Types, Classes, SysUtils, Controls, ExtCtrls, Forms, Math, Dialogs,
  Buttons, BaseLayout, FlowLayout ;

type

  { Выравнивание двойного списка }

  TCustomDualLayout = class ( TFixedListLayout )
  protected
    { Доопределение родительских методов }
    function GetControlsRequired : integer ; override ;
    procedure DoLayout ( Rect : TRect ) ; override ;
    procedure DesignPaintLayout ; override ;
    { Рабочие методы }
    procedure CalcLayout ( const Rect : TRect ;
                           out ATopLeft, ABottomRight, ACenter : TRect ) ; virtual ;
  public
    { Доопределение родительских методов }
    constructor Create ( AOwner : TComponent ) ; override ;
  protected
    property LeftControl : TControl index 0 read GetControl write SetControl ;
    property RightControl : TControl index 1 read GetControl write SetControl ;
    property CenterControl : TControl index 2 read GetControl write SetControl ;
  end ;

  TCustomVerticalDualLayout = class ( TCustomDualLayout )
  protected
    procedure CalcLayout ( const Rect : TRect ;
                           out ATopLeft, ABottomRight, ACenter : TRect ) ; override ;
  protected
    property TopControl : TControl index 0 read GetControl write SetControl ;
    property BottomControl : TControl index 1 read GetControl write SetControl ;
  end ;

implementation

{ TCustomDualLayout }

constructor TCustomDualLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  Width := 300 ;
  Height := 180 ;
end ;

{ Доопределение родительских методов }

{ Возврат количества поддерживаемых компонент }
function TCustomDualLayout.GetControlsRequired : integer ;
begin
  Result := 3 ;
end ;

{ Расстановка панелей }
procedure TCustomDualLayout.DoLayout ( Rect : TRect ) ;
var LT, RB, C : TRect ;
begin
  CalcLayout ( Rect, LT, RB, C ) ;
  if Assigned ( LeftControl ) then LeftControl.BoundsRect := LT ;
  if Assigned ( RightControl ) then RightControl.BoundsRect := RB ;
  if Assigned ( CenterControl ) then CenterControl.BoundsRect := C ;
end ;

{ Дизайн-таймовая отрисовка }
procedure TCustomDualLayout.DesignPaintLayout ;
var LT, RB, C : TRect ;
begin
  inherited ;
  CalcLayout ( LayoutRect, LT, RB, C ) ;
  DrawDesignRect ( LT.Left, LT.Top, LT.Right, LT.Bottom ) ;
  DrawDesignRect ( RB.Left, RB.Top, RB.Right, RB.Bottom ) ;
end ;

{ Расчет положения дочерних компонент }
procedure TCustomDualLayout.CalcLayout (
  const Rect : TRect ; out ATopLeft, ABottomRight, ACenter : TRect ) ;
var CenterWidth, PanelsWidth : integer ;
begin
  if CenterControl <> nil
    then CenterWidth := CenterControl.Width + 2 * Margins.Horiz
    else CenterWidth := Self.Margins.Horiz ;
  PanelsWidth := Rect.Right - Rect.Left - CenterWidth ;
  ATopLeft := Types.Rect ( Rect.Left, Rect.Top, Rect.Left + PanelsWidth div 2, Rect.Bottom ) ;
  ABottomRight := Types.Rect ( ATopLeft.Right + CenterWidth, Rect.Top, Rect.Right, Rect.Bottom ) ;
  ACenter := Types.Rect ( ATopLeft.Right + Margins.Horiz, Rect.Top, ABottomRight.Left - Margins.Horiz, Rect.Bottom ) ;
end ;

{ TCustomVerticalDualLayout }

procedure TCustomVerticalDualLayout.CalcLayout ( const Rect : TRect ;
  out ATopLeft, ABottomRight, ACenter : TRect ) ;
var CenterHeight, PanelsHeight : integer ;
begin
  if CenterControl <> nil
    then CenterHeight := CenterControl.Height + 2 * Margins.Vert
    else CenterHeight := Margins.Vert ;
  PanelsHeight := Rect.Bottom - Rect.Top - CenterHeight ;
  ATopLeft := Types.Rect ( Rect.Left, Rect.Top, Rect.Right, Rect.Top + PanelsHeight div 2 ) ;
  ABottomRight := Types.Rect ( Rect.Left, ATopLeft.Bottom + CenterHeight, Rect.Right, Rect.Bottom ) ;
  ACenter := Types.Rect ( Rect.Left, ATopLeft.Bottom + Margins.Vert, Rect.Right, ABottomRight.Top - Margins.Vert ) ;
end ;

end.

