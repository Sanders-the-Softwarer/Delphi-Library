////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         Панели с настроенными алгоритмами выравнивания дочерних окон       //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

unit LayoutMisc ;

{ ----- Примечание -------------------------------------------------------------

Вспомогательный модуль к Layouts.pas - подробные комментарии и условия
распространения см. в основном модуле

------------------------------------------------------------------------------ }

{ ----- Описание ---------------------------------------------------------------

Файл содержит определения вспомогательных классов, подпрограмм и оповещений
и призван разгрузить основные модули от второстепенных деталей, а также -
в некоторых случаях - избавить их от взаимных ссылок.

------------------------------------------------------------------------------ }

interface

uses SysUtils, Classes, Types, Controls, Forms, Windows, Messages, Graphics,
  STSNotifier, ExtCtrls ;

type
  { Стили отрисовки фона }
  TLayoutBackground = ( lbDefault, lbTransparent ) ;

  { Поля сообщения WM_ERASEBKGND }
  TWMEraseBkgnd = packed record
    Msg : Cardinal ;
    DC  : THandle ;
    Unused : Longint ;
    Result : Longint ;
  end ;

  { Класс "список дочерних компонент" }
  TControlList = class ( TList )
  protected
    function GetControl ( Index : integer ) : TControl ;
  public
    property Controls [ Index : integer ] : TControl read GetControl ; default ;
    function Last : TControl ;
  end ;

  { Панель с поддержкой прозрачности }
  TTransparentPanel = class ( TCustomPanel )
  private
    FTransparent : boolean ;
    procedure TransparentEraseBkgnd ( var Msg : TWMEraseBkgnd ) ;
    procedure SetTransparent ( NewTransparent : boolean ) ;
  protected
    procedure Paint ; override ;
    procedure WmEraseBkgnd ( var Msg : TWMEraseBkgnd ) ; message WM_ERASEBKGND ;
    property Transparent : boolean read FTransparent write SetTransparent ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
  end ;

var
  { Оповещение о конвертации устаревших свойств }
  ConvertPropertyNotifier : TSTSNotifier ;

{ Оповещение о конвертации устаревшего свойства }
procedure NotifyConvertProperty ( Sender : TComponent ; PropName : string ) ;

implementation

uses RecordList, LayoutSettings, BaseLayout ;

{ Оповещение о конвертации устаревшего свойства }
procedure NotifyConvertProperty ( Sender : TComponent ; PropName : string ) ;
var
  Hook : IDesignerHook ;
begin
  Assert ( Sender <> nil ) ;
  if ( Sender is TLayoutSettings ) and TLayoutSettings ( Sender ).Shadow then exit ;
  if Assigned ( ConvertPropertyNotifier ) then ConvertPropertyNotifier.Fire ( Sender, PropName ) ;
  if not Assigned ( Sender.Owner ) or not ( Sender.Owner is TCustomForm ) then exit ;
  Hook := TCustomForm ( Sender.Owner ).Designer ;
  if Assigned ( Hook ) then Hook.Modified ;
end ;

{ TControlList }

function TControlList.GetControl ( Index : integer ) : TControl ;
begin
  Result := TControl ( inherited Items [ Index ]) ;
  Assert ( Result <> nil ) ;
end ;

function TControlList.Last : TControl ;
begin
  Result := TControl ( inherited Last ) ;
  Assert ( Result <> nil ) ;
end ;

{ TTransparentPanel }

constructor TTransparentPanel.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  BevelInner := bvNone ;
  BevelOuter := bvNone ;
  ControlStyle := ControlStyle - [ csSetCaption ] ;
  Transparent := true ;
end ;

{ Реакция на WM_ERASEBKGND в режиме прозрачности }
procedure TTransparentPanel.TransparentEraseBkgnd ( var Msg : TWMEraseBkgnd ) ;
var
  SaveIndex : integer ;
  P : TPoint ;
  LDC : integer ;
begin
  Msg.Result := 1 ;
  if Parent = nil then exit ;
  { Если компонент прозрачен, вместо затирания фона прорисовываем родителя }
  SaveIndex := SaveDC ( Msg.DC ) ;
  GetViewportOrgEx ( Msg.DC, P ) ;
  SetViewportOrgEx ( Msg.DC, P.X - Self.Left, P.Y - Self.Top, nil ) ;
  IntersectClipRect ( Msg.DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight ) ;
  try
    Assert ( SizeOf ( Msg.DC ) = SizeOf ( LDC )) ;
    Move ( Msg.DC, LDC, SizeOf ( Msg.DC )) ;
    Parent.Perform ( WM_ERASEBKGND, LDC, 0 ) ;
    Parent.Perform ( WM_PAINT, LDC, 0 ) ;
  except
    { иначе при специфических условиях возникает исключение в IDE и дельфа
      падает; более комфортного решения не нашел, в рантайме не натыкался }
  end ;
  RestoreDC ( Msg.DC, SaveIndex ) ;
  if ( Parent is TCustomControl ) or ( Parent is TCustomForm ) or
     ( csDesigning in ComponentState ) then exit ;
  Parent.Invalidate ;
end ;

{ Отработка изменения прозрачности }
procedure TTransparentPanel.SetTransparent ( NewTransparent : boolean ) ;
begin
  if FTransparent = NewTransparent then exit ;
  FTransparent := NewTransparent ;
  if FTransparent
    then ControlStyle := ControlStyle - [ csOpaque ]
    else ControlStyle := ControlStyle + [ csOpaque ] ;
  RecreateWnd ;
  Invalidate ;
end ;

{ Отрисовка компонента }
procedure TTransparentPanel.Paint ;
begin
  if not Transparent then inherited ;
end ;

{ Реакция на WM_ERASEBKGND }
procedure TTransparentPanel.WmEraseBkgnd ( var Msg : TWMEraseBkgnd ) ;
begin
  if Transparent
    then TransparentEraseBkgnd ( Msg )
    else inherited ;
end ;

end.

