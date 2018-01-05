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

В этом файле находится класс TBorderLayout, реализующий алгоритм выравнивания
вложенных компонент "по краям". В первом приближении алгоритм аналогичен
использованию свойства Align, но его возможности несколько шире.

Свойства TopControl, BottomControl и прочие задают компоненты, расположенные с
соответствующим выравниванием. Некоторые компоненты могут быть не заданы;
алгоритм размещает их следующим образом:

    +---------------------------------------------------+
    |                     TopControl                    |
    +-----+---------------------------------------+-----+
    |  L  |              SubTopControl            |  R  |
    |  e  +---------------------------------------+  i  |
    |  f  |                                       |  g  |
    |  t  |                                       |  h  |
    |  C  |                                       |  t  |
    |  o  |              CenterControl            |  C  |
    |  n  |                                       |  o  |
    |  t  |                                       |  n  |
    |  r  |                                       |  t  |
    |  o  |                                       |  r  |
    |  l  +---------------------------------------+  o  |
    |     |             SubBottomControl          |  l  |
    +-----+---------------------------------------+-----+
    |                    BottomControl                  |
    +---------------------------------------------------+

С помощью этого алгоритма оформляется основа большинства окон: например, окно
визарда (мастера) делается так:

- на форму кладется TBorderLayout с выравниванием alClient
- в качестве BottomControl используется TFlowLayout, на котором размещены кнопки
- в качестве LeftControl используется TImage с поясняющей картинкой
- в качестве SubBottomControl используется TBevel, отделяющий кнопки
- в качестве CenterControl используется TNotebookLayout со страницами мастера

------------------------------------------------------------------------------ }

unit BorderLayout ;

{$I '..\..\options.inc'}

interface

uses Classes, Types, Controls, BaseLayout ;

type
  TCustomBorderLayout = class ( TFixedListLayout )
  protected
    { Доопределяемые методы родительских классов }
    procedure DoLayout ( Rect : TRect ) ; override ;
    function GetControlsRequired : integer ; override ;
    procedure ControlAdded ( Control : TControl ) ; override ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
  protected
    property CenterControl : TControl index 0 read GetControl write SetControl ;
    property TopControl    : TControl index 1 read GetControl write SetControl ;
    property BottomControl : TControl index 2 read GetControl write SetControl ;
    property LeftControl   : TControl index 3 read GetControl write SetControl ;
    property RightControl  : TControl index 4 read GetControl write SetControl ;
    property SubTopControl : TControl index 5 read GetControl write SetControl ;
    property SubBottomControl : TControl index 6 read GetControl write SetControl ;
  end ;

implementation

{ TCustomBorderLayout }

constructor TCustomBorderLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  Width := 400 ;
  Height := 300 ;
end ;

{ Выравнивание компонент }
procedure TCustomBorderLayout.DoLayout ( Rect : TRect ) ;

  function IsVisible ( Control : TControl ) : boolean ;
  begin
    Result := Assigned ( Control ) and ( IsDesigning or Control.Visible ) ;
  end ;

begin
  { Разместим верхний компонент }
  if IsVisible ( TopControl ) then
  begin
    TopControl.Top := Rect.Top ;
    TopControl.Left := Rect.Left ;
    TopControl.Width := Rect.Right - Rect.Left ;
    Inc ( Rect.Top, TopControl.Height + Self.Margins.Vert ) ;
  end ;
  { Разместим нижний компонент }
  if IsVisible ( BottomControl ) then
  begin
    BottomControl.Top := Rect.Bottom - BottomControl.Height ;
    BottomControl.Left := Rect.Left ;
    BottomControl.Width := Rect.Right - Rect.Left ;
    Dec ( Rect.Bottom, BottomControl.Height + Self.Margins.Vert ) ;
  end ;
  { Разместим левый компонент }
  if IsVisible ( LeftControl ) then
  begin
    LeftControl.Top := Rect.Top ;
    LeftControl.Left := Rect.Left ;
    LeftControl.Height := Rect.Bottom - Rect.Top ;
    Inc ( Rect.Left, LeftControl.Width + Self.Margins.Horiz ) ;
  end ;
  { Разместим правый компонент }
  if IsVisible ( RightControl ) then
  begin
    RightControl.Top := Rect.Top ;
    RightControl.Left := Rect.Right - RightControl.Width ;
    RightControl.Height := Rect.Bottom - Rect.Top ;
    Dec ( Rect.Right, RightControl.Width + Self.Margins.Horiz ) ;
  end ;
  { Разместим дополнительный верхний компонент }
  if IsVisible ( SubTopControl ) then
  begin
    SubTopControl.Top := Rect.Top ;
    SubTopControl.Left := Rect.Left ;
    SubTopControl.Width := Rect.Right - Rect.Left ;
    Inc ( Rect.Top, SubTopControl.Height + Self.Margins.Vert ) ;
  end ;
  { Разместим дополнительный нижний компонент }
  if IsVisible ( SubBottomControl ) then
  begin
    SubBottomControl.Top := Rect.Bottom - SubBottomControl.Height ;
    SubBottomControl.Left := Rect.Left ;
    SubBottomControl.Width := Rect.Right - Rect.Left ;
    Dec ( Rect.Bottom, SubBottomControl.Height + Self.Margins.Vert ) ;
  end ;
  { Разместим центральный компонент }
  if IsVisible ( CenterControl ) then
    CenterControl.BoundsRect := Rect ;
end ;

{ Возврат количества поддерживаемых дочерних компонент }
function TCustomBorderLayout.GetControlsRequired : integer ;
begin
  Result := 7 ;
end ;

{ Размещение нового дочернего компонента }
procedure TCustomBorderLayout.ControlAdded ( Control : TControl ) ;
var Pos : TRect ;
begin
  Assert ( Control <> nil ) ;
  Pos.TopLeft := ScreenToClient ( Control.ClientToScreen ( Control.ClientRect.TopLeft )) ;
  Pos.BottomRight := ScreenToClient ( Control.ClientToScreen ( Control.ClientRect.BottomRight )) ;
  { Посмотрим, куда именно брошен компонент }
  if ( Pos.Bottom < Height div 4 ) and ( TopControl = nil )
    then TopControl := Control
  else if ( Pos.Bottom < Height div 4 ) and ( SubTopControl = nil )
    then SubTopControl := Control
  else if ( Pos.Top > Height * 3 div 4 ) and ( BottomControl = nil )
    then BottomControl := Control
  else if ( Pos.Top > Height * 3 div 4 ) and ( SubBottomControl = nil )
    then SubBottomControl := Control
  else if ( Pos.Right < Width div 4 ) and ( LeftControl = nil )
    then LeftControl := Control
  else if ( Pos.Left > Width * 3 div 4 ) and ( RightControl = nil )
    then RightControl := Control
  else if ( Pos.Left > Width div 5 ) and ( Pos.Top > Height div 5 ) and
    ( Pos.Right < Width * 4 div 5 ) and ( Pos.Bottom < Height * 4 div 5 ) and
    ( CenterControl = nil )
    then CenterControl := Control
  { Если не сработало - пользуемся стандартным алгоритмом }
  else
    inherited ;
end ;

end.

