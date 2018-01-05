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

TFlowLayout - алгоритм выравнивания дочерних компонент в один горизонтальный или
вертикальный ряд. Чаще всего алгоритм применяется для создания панели с
несколькими кнопками (типа TButton или аналогичных). Алгоритм может располагать
кнопки горизонтально либо вертикально, прижимая к любой границе либо центрируя -
что дает возможность применить его, например, в качестве центрального компонента
двойного списка.

Дополнительный компонент TActionPane привязывается к ActionList-у и
автоматически строит набор кнопок, привязанных к соответствующим action-ам.

------------------------------------------------------------------------------ }

unit FlowLayout ;

{$I '..\..\options.inc'}

interface

uses SysUtils, Classes, Controls, Math, Types, ActnList, Contnrs, BaseLayout,
  StsNotifier, LayoutMisc ;

type

  { Потоковое выравнивание }

  TFlowDirection = ( fdHorizLeft, fdHorizRight, fdHorizCenter, fdHorizLeftRight,
                     fdVertTop, fdVertBottom, fdVertCenter, fdVertTopBottom ) ;

  TCustomFlowLayout = class ( TLayout )
  private
    FDirection  : TFlowDirection ;
    FAutoWidth  : integer ;
    FAutoHeight : integer ;
    FDelimiterControl : TControl ;
    LastControl       : TControl ;
  protected
    { Доопределение родительских методов }
    procedure SetParent ( AParent : TWinControl ) ; override ;
    function CompareControls ( Control1, Control2 : TControl ) : integer ; override ;
    procedure DoLayout ( Rect : TRect ) ; override ;
    procedure ControlRemoved ( Control : TControl ) ; override ;
    { Рабочие методы }
    function CalcMinSize ( Controls : TControlList ;
                           IndexFrom, IndexTo : integer ) : integer ;
    procedure PlaceHoriz ( Controls : TControlList ; Start : integer ;
                           IndexFrom : integer = -1 ;
                           IndexTo : integer = -1 ) ;
    procedure PlaceVert  ( Controls : TControlList ; Start : integer ;
                           IndexFrom : integer = -1 ;
                           IndexTo : integer = -1 ) ;
    { Методы свойств }
    function  GetAutoHeight : integer ;
    procedure SetAutoHeight ( NewHeight : integer ) ;
    function  GetAutoWidth : integer ;
    procedure SetAutoWidth ( NewWidth : integer ) ;
    procedure SetDelimiterControl ( NewControl : TControl ) ;
    procedure SetDirection ( NewDirection : TFlowDirection ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    function IsHorizontal : boolean ;
    function IsVertical : boolean ;
  protected
    property AutoHeight : integer read GetAutoHeight write SetAutoHeight
                          stored IsVertical ;
    property AutoWidth  : integer read GetAutoWidth write SetAutoWidth
                          stored IsHorizontal ;
    property DelimiterControl : TControl read FDelimiterControl
                          write SetDelimiterControl ;
    property Direction  : TFlowDirection read FDirection write SetDirection ;
  end ;

  { Панель кнопок, привязанная к ActionList-у }

  TCustomActionPane = class ( TCustomFlowLayout )
  private
    FActions : TActionList ;
    FButtons : TComponentList ;
    FOldActionsChanged : TNotifyEvent ;
    FCategory : string ;
  protected
    procedure DoBeforeLayout ; override ;
    procedure ControlAdded ( Control : TControl ) ; override ;
    procedure ControlRemoved ( Control : TControl ) ; override ;
    function CalcActionsFiltered : integer ;
    procedure UpdateButtons ;
    procedure ActionsChanged ( Sender : TObject ) ;
    procedure SetActions ( NewActions : TActionList ) ;
    procedure SetCategory ( NewCategory : string ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
    procedure Loaded ; override ;
    procedure Notification ( AComponent : TComponent ;
                             AOperation : TOperation ) ; override ;
  published
    property Actions : TActionList read FActions write SetActions ;
    property Category : string read FCategory write SetCategory ;
  end ;

  EActionPaneRejectsControl = class ( ELayout ) ;

implementation

uses CmpUtils ;

resourcestring
  SActionPaneRejectsControl = 'Компонент работает только с контролами, ' +
    'автоматически создаваемыми для представления компонент TAction, и не ' +
    'принимает на себя никаких других визуальных объектов' ;

{ TCustomFlowLayout }

constructor TCustomFlowLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  Height := 35 ;
end ;

procedure TCustomFlowLayout.SetParent ( AParent : TWinControl ) ;
begin
  if ( Height = 35 ) and ( AParent is TLayout ) then Height := 25 ;
  inherited ;
end;

function TCustomFlowLayout.CompareControls ( Control1, Control2 : TControl ) : integer ;
begin
  if IsHorizontal
    then Result := Control1.Left - Control2.Left
    else Result := Control1.Top - Control2.Top ;
end ;

{ Потоковое размещение компонент }
procedure TCustomFlowLayout.DoLayout ( Rect : TRect ) ;
var
  Controls : TControlList ;
  MinSize, DelimitedSize, DelimiterIndex : integer ;
begin
  Controls := ListControls ( not IsDesigning ) ;
  LastControl := nil ;
  try
    if Controls.Count = 0 then exit ;
    LastControl := Controls.Last ;
    MinSize := CalcMinSize ( Controls, 0, Controls.Count - 1 ) ;
    DelimiterIndex := Controls.IndexOf ( DelimiterControl ) ;
    if DelimiterIndex < 0 then DelimiterIndex := Controls.Count ;
    DelimitedSize := CalcMinSize ( Controls, DelimiterIndex, Controls.Count - 1 ) ;
    case Direction of
      fdHorizLeft :
          PlaceHoriz ( Controls, Rect.Left ) ;
      fdHorizRight :
          PlaceHoriz ( Controls, Rect.Right - MinSize ) ;
      fdVertTop :
          PlaceVert ( Controls, Rect.Top ) ;
      fdVertBottom :
          PlaceVert ( Controls, Rect.Bottom - MinSize ) ;
      fdHorizCenter :
          PlaceHoriz ( Controls, ( Rect.Right + Rect.Left - MinSize ) div 2 ) ;
      fdVertCenter :
          PlaceVert ( Controls, ( Rect.Bottom + Rect.Top - MinSize ) div 2 ) ;
      fdHorizLeftRight :
          begin
            PlaceHoriz ( Controls, Rect.Left, -1, DelimiterIndex - 1 ) ;
            PlaceHoriz ( Controls, Rect.Right - DelimitedSize, DelimiterIndex, -1 ) ;
          end ;
      fdVertTopBottom :
          begin
            PlaceVert ( Controls, Rect.Top, -1, DelimiterIndex - 1 ) ;
            PlaceVert ( Controls, Rect.Bottom - DelimitedSize, DelimiterIndex, -1 ) ;
          end ;
    end ;
  finally
    FreeAndNil ( Controls ) ;
  end ;
end ;

{ Реакция на удаление компонента }
procedure TCustomFlowLayout.ControlRemoved ( Control : TControl ) ;
begin
  inherited ;
  if FDelimiterControl = Control then DelimiterControl := nil ;
end ;

{ Вычисление места, занимаемого компонентами }
function TCustomFlowLayout.CalcMinSize ( Controls : TControlList ;
  IndexFrom, IndexTo : integer ) : integer ;
var
  i, Count : integer ;
begin
  Result := 0 ;
  for i := IndexFrom to IndexTo do
  begin
    if AutoWidth > 0 then Controls [ i ].Width := AutoWidth ;
    if AutoHeight > 0 then Controls [ i ].Height := AutoHeight ;
    if IsHorizontal
      then Inc ( Result, Controls [ i ].Width )
      else Inc ( Result, Controls [ i ].Height ) ;
  end ;
  Count := IndexTo - IndexFrom + 1 ;
  if Count > 1 then
    if IsHorizontal
      then Inc ( Result, Self.Margins.Horiz * ( Count - 1 ))
      else Inc ( Result, Self.Margins.Vert * ( Count - 1 )) ;
end ;

{ Размещение компонент по горизонтали }
procedure TCustomFlowLayout.PlaceHoriz ( Controls : TControlList ;
  Start : integer ; IndexFrom : integer = -1 ; IndexTo : integer = -1 ) ;
var
  i : integer ;
begin
  if IndexFrom = -1 then IndexFrom := 0 ;
  if IndexTo = -1 then IndexTo := Controls.Count - 1 ;
  for i := IndexFrom to IndexTo do
    with Controls [ i ] do
    begin
      Top := Self.Margins.Top ;
      Left := Start ;
      Inc ( Start, Width + Self.Margins.Horiz ) ;
    end ;
end ;

{ Размещение компонент по вертикали }
procedure TCustomFlowLayout.PlaceVert ( Controls : TControlList ;
  Start : integer ; IndexFrom : integer = -1 ; IndexTo : integer = -1 ) ;
var
  i : integer ;
begin
  if IndexFrom = -1 then IndexFrom := 0 ;
  if IndexTo = -1 then IndexTo := Controls.Count - 1 ;
  for i := IndexFrom to IndexTo do
    with Controls [ i ] do
    begin
      Left := Self.Margins.Left ;
      Top := Start ;
      Inc ( Start, Height + Self.Margins.Vert ) ;
    end ;
end ;

{ Проверка "горизонтального" либо "вертикального" направления выравнивания }

function TCustomFlowLayout.IsHorizontal : boolean ;
begin
  Result := ( Direction in [ fdHorizLeft, fdHorizRight, fdHorizCenter,
                             fdHorizLeftRight ]) ;
end ;

function TCustomFlowLayout.IsVertical : boolean ;
begin
  Result := not IsHorizontal ;
end ;

{ Методы свойств }

function TCustomFlowLayout.GetAutoHeight : integer ;
begin
  if IsHorizontal
    then Result := Self.ClientHeight - Self.Margins.Top - Self.Margins.Bottom
    else Result := FAutoHeight ;
end ;

procedure TCustomFlowLayout.SetAutoHeight ( NewHeight : integer ) ;
begin
  NewHeight := Max ( 0, NewHeight ) ;
  if FAutoHeight = NewHeight then exit ;
  FAutoHeight := NewHeight ;
  if IsHorizontal and not IsLoading then
    Self.ClientHeight := NewHeight + Self.Margins.Top + Self.Margins.Bottom ;
  RequestLayout ;
end ;

function TCustomFlowLayout.GetAutoWidth : integer ;
begin
  if IsVertical
    then Result := Self.ClientWidth - Self.Margins.Left - Self.Margins.Right
    else Result := FAutoWidth ;
end ;

procedure TCustomFlowLayout.SetAutoWidth ( NewWidth : integer ) ;
begin
  NewWidth := Max ( 0, NewWidth ) ;
  if FAutoWidth = NewWidth then exit ;
  FAutoWidth := NewWidth ;
  if IsVertical and not IsLoading then
    Self.ClientWidth := NewWidth + Self.Margins.Left + Self.Margins.Right ;
  RequestLayout ;
end ;

procedure TCustomFlowLayout.SetDelimiterControl ( NewControl : TControl ) ;
begin
  if NewControl = FDelimiterControl then exit ;
  try
    DisableLayout ;
    if Assigned ( NewControl ) and ( NewControl.Parent <> Self ) then
    begin
      NewControl.Parent := nil ;
      NewControl.Left := Self.Width + 10 ;
      NewControl.Parent := Self ;
    end ;
    FDelimiterControl := NewControl ;
  finally
    EnableLayout ;
  end ;
end ;

procedure TCustomFlowLayout.SetDirection ( NewDirection : TFlowDirection ) ;
var Controls : TControlList ;
begin
  if Direction = NewDirection then exit ;
  FDirection := NewDirection ;
  Controls := nil ;
  if (FDirection in [ fdHorizLeftRight, fdVertTopBottom ]) and
     ( DelimiterControl = nil ) then
  try
    Controls := ListControls ;
    if Controls.Count > 0 then DelimiterControl := Controls.Last ;
  finally
    FreeAndNil ( Controls ) ;
  end ;
  RequestLayout ;
end ;

{ TCustomActionPane }

constructor TCustomActionPane.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  ControlStyle := ControlStyle - [ csAcceptsControls ] ;
  FButtons := TComponentList.Create ( false ) ;
end ;

destructor TCustomActionPane.Destroy ;
begin
  FreeAndNil ( FButtons ) ;
  inherited ;
end ;

procedure TCustomActionPane.Loaded ;
begin
  inherited ;
  UpdateButtons ;
end ;

{ Реакция на удаление action list-а }
procedure TCustomActionPane.Notification ( AComponent : TComponent ;
                                           AOperation : TOperation ) ;
begin
  inherited ;
  if ( AOperation = opRemove ) and ( AComponent = FActions ) then
    SetActions ( nil ) ;
end ;

{ Обновление списка компонент перед выравниванием }
procedure TCustomActionPane.DoBeforeLayout ;
begin
  UpdateButtons ;
  inherited ;
end ;

{ Реакция на добавление компонента }
procedure TCustomActionPane.ControlAdded ( Control : TControl ) ;
begin
  Assert ( FButtons <> nil ) ;
  if FButtons.IndexOf ( Control ) < 0 then
  begin
    KickOut ( Control ) ;
    raise EActionPaneRejectsControl.Create ( Self, SActionPaneRejectsControl ) ;
  end ;
  inherited ;
end ;

{ Реакция на уничтожение кнопки }
procedure TCustomActionPane.ControlRemoved ( Control : TControl ) ;
begin
  FButtons.Remove ( Control ) ;
  inherited ;
end ;

{ Расчет количества кнопок }
function TCustomActionPane.CalcActionsFiltered : integer ;
var i : integer ;
begin
  Result := 0 ;
  if not Assigned ( FActions ) then exit ;
  Result := FActions.ActionCount ;
  if Category = '' then exit ;
  for i := Result - 1 downto 0 do
    if not SameText ( Category, FActions [ i ].Category ) then Dec ( Result ) ;
end ;

{ Подстраивание компонент под список действий }
procedure TCustomActionPane.UpdateButtons ;
var
  ActionCount, i, C : integer ;
  B : TControl ;
begin
  DisableLayout ;
  ActionCount := CalcActionsFiltered ;
  try
    { Доставим недостающих кнопок }
    while FButtons.Count < ActionCount do
      if CreateComponent ( B, Self, Settings.ComponentSettings.DefaultButton,
                           '', eaDefault )
        then FButtons.Add ( B )
        else exit ;
    { Прибьем лишние кнопки }
    for i := FButtons.Count - 1 downto ActionCount do
      FButtons [ i ].Free ;
    { Привяжем к действиям по порядку }
    C := -1 ;
    for i := 0 to ActionCount - 1 do
    begin
      Assert ( FButtons [ i ] <> nil ) ;
      Assert ( FButtons [ i ] is TControl ) ;
      B := TControl ( FButtons [ i ]) ;
      repeat
        Inc ( C )
      until ( Category = '' ) or ( SameText ( FActions [ C ].Category, Category )) ;
      B.Action := FActions [ C ] ;
      if IsHorizontal
        then B.Left := i * 10
        else B.Top  := i * 10 ;
      B.Parent := Self ;
    end ;
  finally
    EnableLayout ;
  end ;
end ;

{ Установка списка действий }
procedure TCustomActionPane.SetActions ( NewActions : TActionList ) ;
var A : TNotifyEvent ;
begin
  if FActions = NewActions then exit ;
  { Освободим от себя старый список }
  A := Self.ActionsChanged ;
  if ( FActions <> nil ) and EqualHandlers ( FActions.OnChange, A ) then
  begin
    FActions.OnChange := FOldActionsChanged ;
    FOldActionsChanged := nil ;
  end ;
  { Обременим собой новый }
  if NewActions <> nil then
  begin
    FreeNotification ( NewActions ) ;
    FOldActionsChanged := NewActions.OnChange ;
    NewActions.OnChange := Self.ActionsChanged ;
  end ;
  { И все }
  FActions := NewActions ;
  UpdateButtons ;
end ;

procedure TCustomActionPane.SetCategory ( NewCategory : string) ;
begin
  if SameText ( FCategory, NewCategory ) then exit ;
  FCategory := NewCategory ;
  UpdateButtons ;
end ;

{ Реакция на изменение списка действий }
procedure TCustomActionPane.ActionsChanged ( Sender : TObject ) ;
begin
  if @FOldActionsChanged <> nil then FOldActionsChanged ( Sender ) ;
  UpdateButtons ;
end ;

end.

