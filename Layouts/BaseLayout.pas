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

{ ----- Использование модуля ---------------------------------------------------

В этом файле находится класс TLayout - базовый класс для всех реализованных
алгоритмов выравнивания, а также другие базовые решения.

------------------------------------------------------------------------------ }

unit BaseLayout ;

{$I '..\..\options.inc'}

interface

uses
  Windows, SysUtils, Classes, Types, Contnrs, Messages, Controls, Forms,
  ExtCtrls, Graphics, Dialogs, Buttons, Math, ExUtils, LayoutSettings,
  STSNotifier, CmpUtils, LayoutMisc ;

type

  { Базовый класс исключений модуля }
  ELayout = class ( EComponent ) ;

  { Предварительные объявления }
  TLayoutMargins = class ;

  { Базовый класс выравниваемых панелей }
  TLayout = class ( TTransparentPanel )
  private
    FActive  : boolean ;
    FMargins : TLayoutMargins ;
    FSettings : TLayoutSettings ;
    FSettingsGuid : string ;
    FBackground : TLayoutBackground ;
    LayoutDepth : integer ;
    FlagIntoLayout, FlagDontRequestSettings : boolean ;
    FGradient : TGradientSettings ;
    FServiceControls : TComponentList ;
    FNewControls : TComponentList ;
    FControlJustAdded : TControl ;
    { Сравнение контролов для сортировки в ListControls }
    function CompareControlsInternal ( Control1, Control2 : TControl ) : integer ;
  protected
    { Перекрытые методы родительских классов }
    procedure Paint ; override ;
    procedure AlignControls ( AControl : TControl ; var ARect : TRect ) ; override ;
    { Обрабатываемые сообщения }
    procedure CmControlChange ( var M : TMessage ) ; message CM_CONTROLCHANGE ;
    procedure CmControlListChange ( var M : TMessage ) ; message CM_CONTROLLISTCHANGE ;
    { Оповещения, на которые мы реагируем }
    procedure GradientChanged ( Sender : TObject ) ;
    procedure SettingsChanged ( Sender : TObject ) ;
    procedure LayoutSettingsNotification ( Sender : TObject ) ;
    { Внутренние методы, предназначенные к наследованию }
    function CompareControls ( Control1, Control2 : TControl ) : integer ; virtual ; abstract ;
    procedure DoLayout ( Rect : TRect ) ; dynamic ;
    procedure DoBeforeLayout ; dynamic ;
    procedure DoAfterLayout ; dynamic ;
    procedure DesignPaintLayout ; dynamic ;
    procedure MarginsChanged ; dynamic ;
    procedure ControlAdded ( Control : TControl ) ; dynamic ;
    procedure ServiceControlAdded ( Control : TControl ) ; dynamic ;
    procedure ControlRemoved ( Control : TControl ) ; dynamic ;
    procedure ServiceControlRemoved ( Control : TControl ) ; dynamic ;
    procedure ControlLoaded ( Control : TControl ) ; dynamic ;
    function  CreateLayoutMargins : TLayoutMargins ; dynamic ;
    function  ControlNotificationsEnabled : boolean ; dynamic ;
    { Рабочие методы }
    procedure PaintingChanged ;
    function  DesignHighlightLayout : boolean ;
    procedure DrawDesignRect ( Rect : TRect ) ; overload ;
    procedure DrawDesignRect ( ALeft, ATop, ARight, ABottom : integer ) ; overload ;
    procedure KickOut ( Control : TControl ) ;
    procedure RegisterServiceControl ( Control : TControl ) ;
    function  IsServiceControl ( Control : TControl ) : boolean ;
    procedure CheckServiceControl ( Control : TControl ) ;
    function  LayoutRect : TRect ;
    procedure Modified ;
    { Чтение-запись Settings }
    procedure ReadSettingsGuid ( Reader : TReader ) ;
    procedure WriteSettingsGuid ( Writer : TWriter ) ;
    { Считывание устаревших свойств }
    procedure ReadLayoutActive ( Reader : TReader ) ;
    procedure ReadTransparent ( Reader : TReader ) ;
    { Методы свойств }
    procedure SetActive ( NewActive : boolean ) ;
    procedure SetMargins ( NewMargins : TLayoutMargins ) ;
    function  GetSettings : TLayoutSettings ;
    procedure SetSettings ( NewSettings : TLayoutSettings ) ;
    procedure SetBackground ( NewBackground : TLayoutBackground ) ;
    procedure SetGradient ( NewGradient : TGradientSettings ) ;
  public
    { Доопределение родительских методов }
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
    procedure Notification ( AComponent : TComponent ; Operation : TOperation ) ; override ;
    procedure DefineProperties ( Filer : TFiler ) ; override ;
    procedure ReadState ( Reader : TReader ) ; override ;
    procedure SetParent ( AParent : TWinControl ) ; override ;
    { Публикуемые методы }
    function ListControls ( Root : TWinControl ;
                            VisibleOnly : boolean ) : TControlList ; overload ;
    function ListControls ( VisibleOnly : boolean ) : TControlList ; overload ;
    function ListControls : TControlList ; overload ;
    function IsDesigning : boolean ;
    function IsLoading : boolean ;
    function IsDestroying ( AComponent : TComponent = nil ) : boolean ;
    procedure DisableLayout ;
    procedure EnableLayout ;
    procedure RequestLayout ;
  published
    property Background : TLayoutBackground read FBackground write SetBackground ;
    property Gradient : TGradientSettings read FGradient write SetGradient ;
    property Active : boolean read FActive write SetActive stored true ;
    property Margins : TLayoutMargins read FMargins write SetMargins ;
    property Settings : TLayoutSettings read GetSettings write SetSettings stored false ;
  published
    property Align nodefault ;
    property AutoSize ;
    property BevelInner nodefault ;
    property BevelOuter nodefault ;
    property BevelWidth ;
    property Color ;
    property Enabled ;
    property ParentColor nodefault ;
    property ParentShowHint ;
    property PopupMenu ;
    property ShowHint ;
    property TabOrder ;
    property TabStop ;
    property Visible ;
  end ;

  { Базовый класс для панелей с фиксированным списком подпанелей }

  EFixedListLayout = class ( ELayout ) ;

  TFixedListLayout = class ( TLayout )
  private
    FControls : array of TControl ;
    FMaxControl : integer ;
    FlagIntoSetControl : integer ;
  protected
    { Методы, предназначенные к наследованию }
    function GetControlsRequired : integer ; dynamic ; abstract ;
    { Доопределение родительских методов }
    procedure ControlAdded ( Control : TControl ) ; override ;
    procedure ControlRemoved ( Control : TControl ) ; override ;
    function  ControlNotificationsEnabled : boolean ; override ;
    { Методы свойств }
    function GetControl ( Index : integer ) : TControl ;
    procedure SetControl ( Index : integer ; NewControl : TControl ) ;
  protected
    property MaxControl : integer read FMaxControl ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
  end ;

  { Класс "отступов", актуальный практически в любой выравниваемой панели }
  TLayoutMargins = class ( TPersistent )
  private
    FMargins : array of integer ;
    FOwner : TLayout ;
  protected
    procedure Defaults ( const Default : array of integer ) ;
    function GetMargin ( Index : integer ) : integer ;
    procedure SetMargin ( Index : integer ; NewValue : integer ) ;
    function StoreMargin ( Index : integer ) : boolean ;
  public
    constructor Create ( AOwner : TLayout ) ; virtual ;
  published
    property Top : integer index 0 read GetMargin write SetMargin stored StoreMargin ;
    property Left : integer index 1 read GetMargin write SetMargin stored StoreMargin ;
    property Right : integer index 2 read GetMargin write SetMargin stored StoreMargin ;
    property Bottom : integer index 3 read GetMargin write SetMargin stored StoreMargin ;
    property Horiz : integer index 4 read GetMargin write SetMargin stored StoreMargin ;
    property Vert : integer index 5 read GetMargin write SetMargin stored StoreMargin ;
  end ;

var
  { Оповещение для подключения дизайн-таймового кода }
  CreateLayoutProc : TNotifyEvent ;

implementation

{$IfDef Use_TabOrder}uses TabOrder ;{$EndIf}

resourcestring
  STooManyControls  = 'На компоненте может быть размещено не более ' +
                      '%d дочерних компонент' ;
  SIsServiceControl = 'Компонент %s является служебным для компонента %s ' +
                      'и не должен использоваться обычным образом' ;

{ TLayout }

constructor TLayout.Create ( AOwner : TComponent ) ;
begin
  FGradient := TGradientSettings.Create ( Self.Settings ) ;
  FGradient.OnChange := GradientChanged ;
  FMargins := CreateLayoutMargins ;
  FNewControls := TComponentList.Create ( false ) ;
  inherited ;
  Transparent := false ;
  Caption  := '' ;
  FActive := true ;
  ParentColor := true ;
  Assert ( SettingsChangedNotifier <> nil ) ;
  SettingsChangedNotifier.RegisterNotification ( SettingsChanged ) ;
  Assert ( LayoutSettingsNotifier <> nil ) ;
  LayoutSettingsNotifier.RegisterNotification ( LayoutSettingsNotification ) ;
end ;

destructor TLayout.Destroy ;
begin
  if SettingsChangedNotifier <> nil then
    SettingsChangedNotifier.RemoveNotification ( SettingsChanged ) ;
  if LayoutSettingsNotifier <> nil then
    LayoutSettingsNotifier.RemoveNotification ( LayoutSettingsNotification ) ;
  inherited ;
  FreeAndNil ( FGradient ) ;
  FreeAndNil ( FMargins ) ;
  FreeAndNil ( FServiceControls ) ;
  FreeAndNil ( FNewControls ) ;
end ;

{ Оповещение об удалении компонент }
procedure TLayout.Notification ( AComponent : TComponent ; Operation : TOperation ) ;
begin
  inherited ;
  if ( Operation = opRemove ) and ( AComponent = FSettings ) then
    FSettings := nil ;
end ;

{ Сохранение Settings.Guid вместо указателя на компонент }
procedure TLayout.DefineProperties ( Filer : TFiler ) ;
var SaveGuid : boolean ;
begin
  SaveGuid := not Assigned ( Filer.Ancestor ) or
              SameText ( FSettingsGuid, TLayout ( Filer.Ancestor ).FSettingsGuid ) ;
  Filer.DefineProperty ( 'SettingsGuid', ReadSettingsGuid, WriteSettingsGuid, SaveGuid );
  Filer.DefineProperty ( 'LayoutActive', ReadLayoutActive, nil, false ) ;
  Filer.DefineProperty ( 'Transparent', ReadTransparent, nil, false ) ;
  inherited ;
end ;

{ Оповещение дизайн-таймовой части о чтении компонента }
procedure TLayout.ReadState ( Reader : TReader ) ;
begin
  FlagDontRequestSettings := true ;
  try
    DisableLayout ;
    inherited ;
  finally
    EnableLayout ;
  end ;
end ;

{ Установка родителя и применение дизайн-таймовых расширений }
procedure TLayout.SetParent ( AParent : TWinControl ) ;
begin
  inherited ;
  if not FlagDontRequestSettings and IsDesigning and not IsLoading then
  begin
    FlagDontRequestSettings := true ;
    if Assigned ( CreateLayoutProc ) then CreateLayoutProc ( Self ) ;
  end ;
end ;

{ Публикуемые методы }

{ Функция сравнения для сортировки компонент в списке }
function CompareControlsOuter ( Item1, Item2 : pointer ) : integer ;
var
  Control1 : TControl absolute Item1 ;
  Control2 : TControl absolute Item2 ;
begin
  Assert ( Item1 <> nil ) ;
  Assert ( Item2 <> nil ) ;
  Assert ( Control1.Parent <> nil ) ;
  Assert ( Control1.Parent = Control2.Parent ) ;
  Assert ( Control1.Parent is TLayout ) ;
  Result := TLayout ( Control1.Parent ).CompareControlsInternal ( Control1, Control2 ) ;
end ;

{ Перечисление дочерних окон }
function TLayout.ListControls ( Root : TWinControl ;
                                VisibleOnly : boolean ) : TControlList ;
var
  Control : TControl ;
  i : integer ;
begin
  Result := TControlList.Create ;
  for i := 0 to Root.ControlCount - 1 do
  begin
    Control := Root.Controls [ i ] ;
    if ( Control.Visible or not VisibleOnly ) and not IsServiceControl ( Control )
      then Result.Add ( Control ) ;
  end ;
  Result.Sort ( CompareControlsOuter ) ;
  FNewControls.Clear ;
end ;

{ Перечисление дочерних окон }
function TLayout.ListControls ( VisibleOnly : boolean ) : TControlList ;
begin
  Result := ListControls ( Self, VisibleOnly ) ;
end ;

{ Перечисление дочерних окон }
function TLayout.ListControls : TControlList ;
begin
  Result := ListControls ( not IsDesigning ) ;
end ;

{ Проверка статуса редактирования }
function TLayout.IsDesigning : boolean ;
begin
  Result := ( csDesigning in ComponentState ) ;
end ;

{ Проверка статуса загрузки }
function TLayout.IsLoading : boolean ;
begin
  Result := ( csLoading in ComponentState ) ;
end ;

{ Проверка статуса уничтожения }
function TLayout.IsDestroying ( AComponent : TComponent = nil ) : boolean ;
begin
  if AComponent = nil
    then Result := ( csDestroying in ComponentState )
    else Result := ( csDestroying in AComponent.ComponentState ) ;
end ;

{ Временный запрет выравнивания }
procedure TLayout.DisableLayout ;
begin
  Inc ( LayoutDepth ) ;
end ;

{ Разрешение ранее запрещенного выравнивания }
procedure TLayout.EnableLayout ;
begin
  if LayoutDepth > 0 then Dec ( LayoutDepth ) ;
  if LayoutDepth = 0 then RequestLayout ;
end ;

{ Запрос на перерасчет выравнивания }
procedure TLayout.RequestLayout ;
begin
  if IsDestroying or not Active or FlagIntoLayout or ( LayoutDepth > 0 )
     or ( Parent = nil ) then exit ;
  try
    FlagIntoLayout := true ;
    DoBeforeLayout ;
    DoLayout ( LayoutRect ) ;
    DoAfterLayout ;
    Invalidate ;
  finally
    FlagIntoLayout := false ;
  end ;
end ;

{ Рабочие методы }

{ Расстановка компонент }
procedure TLayout.DoLayout ;
begin
end ;

{ Выполнение кода перед выравниванием }
procedure TLayout.DoBeforeLayout ;
begin
end ;

{ Выполнение кода после выравнивания }
procedure TLayout.DoAfterLayout ;
begin
  {$IfDef Use_TabOrder} UpdateTabOrders ( Self ) ; {$EndIf}
end ;

{ Дополнительная подсветка выравнивания в дизайн-тайме }
procedure TLayout.DesignPaintLayout ;
begin
  if ( BevelInner = bvNone ) and ( BevelOuter = bvNone )
    then DrawDesignRect ( 0, 0, Width, Height ) ;
end ;

{ Реакция на изменения в настройках полей }
procedure TLayout.MarginsChanged ;
begin
  RequestLayout ;
end ;

{ Реакция на добавление дочернего компонента }
procedure TLayout.ControlAdded ( Control : TControl ) ;
begin
  Assert ( Control <> nil ) ;
  FNewControls.Add ( Control ) ;
  Control.FreeNotification ( Self ) ;
end ;

{ Реакция на добавление вспомогательного компонента }
procedure TLayout.ServiceControlAdded ( Control : TControl ) ;
begin
  Assert ( Control <> nil ) ;
  Control.FreeNotification ( Self ) ;
end ;

{ Реакция на удаление дочернего компонента }
procedure TLayout.ControlRemoved ( Control : TControl ) ;
begin
  Assert ( Control <> nil ) ;
  Control.RemoveFreeNotification ( Self ) ;
end ;

{ Реакция на удаление вспомогательного компонента }
procedure TLayout.ServiceControlRemoved ( Control : TControl ) ;
begin
  Assert ( Control <> nil ) ;
  Control.RemoveFreeNotification ( Self ) ;
end ;

{ Реакция на загрузку компонента из dfm }
procedure TLayout.ControlLoaded ( Control : TControl ) ;
begin
  Assert ( Control <> nil ) ;
  Control.FreeNotification ( Self ) ;
end ;

{ Создание объекта реализующего свойство Margins }
function TLayout.CreateLayoutMargins : TLayoutMargins ;
begin
  Result := TLayoutMargins.Create ( Self ) ;
end ;

{ Разрешение или запрет уведомлений об изменении списка компонент }
function TLayout.ControlNotificationsEnabled : boolean ;
begin
  Result := true ;
end ;

{ Реакция на изменение стиля отображения }
procedure TLayout.PaintingChanged ;
begin
  RecreateWnd ;
  Invalidate ;
end ;

{ Проверка необходимости "подсветить" выбранное выравнивание }
function TLayout.DesignHighlightLayout : boolean ;
begin
  Result := IsDesigning ;
end ;

{ Отрисовка выделяющей линии }

procedure TLayout.DrawDesignRect ( ALeft, ATop, ARight, ABottom : integer ) ;
begin
  DrawDesignRect ( Rect ( ALeft, ATop, ARight, ABottom )) ;
end ;

{ Выбрасывание некорректного дочернего компонента наружу }
procedure TLayout.KickOut ( Control : TControl ) ;
begin
  if Control = nil then exit ;
  if IsDestroying ( Control ) then exit ;
  if Control.Parent <> Self then exit ;
  if IsDesigning
    then Control.Parent := GetParentForm ( Self )
    else Control.Parent := nil ;
end ;

{ Регистрация компонента как служебного }
procedure TLayout.RegisterServiceControl ( Control : TControl ) ;
begin
  if not Assigned ( FServiceControls ) then
    FServiceControls := TComponentList.Create ( false ) ;
  if FServiceControls.IndexOf ( Control ) < 0 then
    FServiceControls.Add ( Control ) ;
end ;

{ Проверка, не относится ли компонент к служебным }
function TLayout.IsServiceControl ( Control : TControl ) : boolean ;
begin
  Result := Assigned ( FServiceControls ) and
            ( FServiceControls.IndexOf ( Control ) >= 0 ) ;
end ;

{ Проверка с возбуждением исключения, если компонент служебный }
procedure TLayout.CheckServiceControl ( Control : TControl ) ;
begin
  if IsServiceControl ( Control ) then
    raise EFixedListLayout.CreateFmt ( Self, SIsServiceControl, [ FormatComponentName ( Control )]) ;
end ;

{ Определение координат области выравнивания }
function TLayout.LayoutRect : TRect ;
begin
  Result := ClientRect ;
  Inc ( Result.Top, Self.Margins.Top ) ;
  Inc ( Result.Left, Self.Margins.Left ) ;
  Dec ( Result.Right, Self.Margins.Right ) ;
  Dec ( Result.Bottom, Self.Margins.Bottom ) ;
end ;

{ Оповещение IDE об изменении компонента }
procedure TLayout.Modified ;
var
  Form : TCustomForm ;
  Hook : IDesignerHook ;
begin
  Form := GetParentForm ( Self ) ;
  if not Assigned ( Form ) then exit ;
  Hook := Form.Designer ;
  if not Assigned ( Hook ) then exit ;
  Hook.Modified ;
end ;

{ Чтение-запись Settings }

procedure TLayout.ReadSettingsGuid ( Reader : TReader ) ;
begin
  FSettings := nil ;
  Reader.ReadListBegin ;
  if Reader.EndOfList
    then FSettingsGuid := ''
    else FSettingsGuid := UpperCase ( Reader.ReadWideString ) ;
  Reader.ReadListEnd ;
end ;

procedure TLayout.WriteSettingsGuid ( Writer : TWriter ) ;
begin
  Writer.WriteListBegin ;
  Writer.WriteWideString ( UpperCase ( FSettingsGuid )) ;
  Writer.WriteListEnd ;
end ;

{ Считывание устаревшего свойства LayoutActive }
procedure TLayout.ReadLayoutActive ( Reader : TReader ) ;
begin
  Active := Reader.ReadBoolean ;
  NotifyConvertProperty ( Self, 'LayoutActive' ) ;
end ;

{ Считывание устаревшего свойства Transparent }
procedure TLayout.ReadTransparent ( Reader : TReader ) ;
var Value : boolean ;
begin
  Value := Reader.ReadBoolean ;
  if Value
    then Background := lbTransparent
    else Background := lbDefault ;
  NotifyConvertProperty ( Self, 'Transparent' ) ;
end ;

var
  SaveBrush : TBrush ;
  SavePen   : TPen ;

procedure TLayout.DrawDesignRect ( Rect : TRect ) ;
var
  Coords : array of TPoint ;
begin
  Assert ( SaveBrush <> nil ) ;
  Assert ( SavePen <> nil ) ;
  if not IsDesigning then exit ;
  SetLength ( Coords, 5 ) ;
  Coords [ 0 ] := Point ( Rect.Left, Rect.Top ) ;
  Coords [ 1 ] := Point ( Rect.Right - 1, Rect.Top ) ;
  Coords [ 2 ] := Point ( Rect.Right - 1, Rect.Bottom - 1 ) ;
  Coords [ 3 ] := Point ( Rect.Left, Rect.Bottom - 1 ) ;
  Coords [ 4 ] := Coords [ 0 ] ;
  with Canvas do
  begin
    SaveBrush.Assign ( Brush ) ;
    SavePen.Assign ( Pen ) ;
    Pen.Style := psSolid ;
    Pen.Color := clHighlightText ;
    Pen.Width := 1 ;
    Polyline ( Coords ) ;
    Pen.Style := psDot ;
    Pen.Color := clHighlight ;
    Polyline ( Coords ) ;
    Brush.Assign ( SaveBrush ) ;
    Pen.Assign ( SavePen ) ;
  end ;
end ;

{ Отрисовка компонента }
procedure TLayout.Paint ;
var
  G : TGradientSettings ;
  B : TBitmap ;
begin
  case Background of
    lbDefault :
      inherited ;
    lbGradient, lbSettingsGradient :
      begin
        if Background = lbGradient
          then G := Gradient
          else G := Settings.GradientSettings ;
        B := GradientPattern ( G.ColorBegin, G.ColorEnd, G.Reverse, G.Rotation,
                               G.Shift, G.Style, G.UseSysColors ) ;
        Canvas.StretchDraw ( ClientRect, B ) ;
      end ;
  end ;
  if DesignHighlightLayout then DesignPaintLayout ;
end ;

{ Выравнивание после изменений в дочерних компонентах }
procedure TLayout.AlignControls ( AControl : TControl ; var ARect : TRect ) ;
begin
  if Assigned ( FControlJustAdded ) and ( FControlJustAdded = AControl )
    then FControlJustAdded := nil
    else RequestLayout ;
end ;

{ Реакция на изменение списка контролов }
procedure TLayout.CmControlChange ( var M : TMessage ) ;
var
  Added, IsService : boolean ;
  Control : TControl ;
begin
  inherited ;
  if not ControlNotificationsEnabled then exit ;
  Control := TControl ( M.WParam ) ;
  Added := boolean ( M.LParam ) ;
  IsService := IsServiceControl ( Control ) ;
  if Added and IsLoading then
    ControlLoaded ( Control )
  else if Added and not IsService then
    ControlAdded ( Control )
  else if Added and IsService then
    ServiceControlAdded ( Control )
  else if not Added and not IsService then
    ControlRemoved ( Control )
  else if not Added and IsService then
    ServiceControlRemoved ( Control ) ;
  RequestLayout ;
end ;

{ Подготовка к изменению списка контролов }
procedure TLayout.CmControlListChange ( var M : TMessage ) ;
begin
  if boolean ( M.LParam ) then
    FControlJustAdded := TControl ( M.WParam ) ;
end ;

{ Реакция на саморекламу компонента настроек }
procedure TLayout.LayoutSettingsNotification ( Sender : TObject ) ;
var
  Data : TObject ;
  LayoutSettings : TLayoutSettings absolute Data ;
begin
  Assert ( Sender <> nil ) ;
  Assert ( Sender is TSTSNotifier ) ;
  Data := TSTSNotifier ( Sender ).Data ;
  Assert ( Data <> nil ) ;
  Assert ( Data is TLayoutSettings ) ;
  if SameText ( LayoutSettings.Guid, FSettingsGuid ) then
    FSettings := LayoutSettings ;
end ;

{ Реакция на изменение настроек градиента }
procedure TLayout.GradientChanged ( Sender : TObject ) ;
begin
  if Background = lbGradient then PaintingChanged ;
end ;

{ Реакция на изменение глобальных настроек }
procedure TLayout.SettingsChanged ( Sender : TObject ) ;
begin
  Assert ( Sender is TSTSNotifier ) ;
  if TSTSNotifier ( Sender ).Data <> Self.Settings then exit ;
  if Background = lbSettingsGradient then PaintingChanged ;
  RequestLayout ;
end ;

{ Методы свойств }

procedure TLayout.SetActive ( NewActive : boolean ) ;
begin
  if FActive = NewActive then exit ;
  FActive := NewActive ;
  RequestLayout ;
end ;

procedure TLayout.SetMargins ( NewMargins : TLayoutMargins ) ;
begin
end ;

function TLayout.GetSettings : TLayoutSettings ;
begin
  Assert ( FindByGuidNotifier <> nil ) ;
  if not Assigned ( FSettings ) then
    FindByGuidNotifier.Fire ( FSettingsGuid ) ;
  if not Assigned ( FSettings ) then
    MakeShadowSettingsNotifier.Fire ( FSettingsGuid ) ;
  if Assigned ( FSettings )
    then Result := FSettings
    else Result := DefaultLayoutSettings ;
  Assert ( Result <> nil ) ;
end ;

procedure TLayout.SetSettings ( NewSettings : TLayoutSettings ) ;
begin
  if FSettings = NewSettings then exit ;
  FSettings := NewSettings ;
  if Assigned ( FSettings ) then
    begin
      FreeNotification ( FSettings ) ;
      FSettingsGuid := FSettings.Guid ;
    end
  else
    FSettingsGuid := '' ;
  RequestLayout ;
end ;

procedure TLayout.SetBackground ( NewBackground : TLayoutBackground ) ;
var OldTransparent : boolean ;
begin
  if FBackground = NewBackground then exit ;
  FBackground := NewBackground ;
  OldTransparent := Transparent ;
  Transparent := ( FBackground = lbTransparent ) ;
  if OldTransparent = Transparent then PaintingChanged ;
end ;

procedure TLayout.SetGradient ( NewGradient : TGradientSettings ) ;
begin
  FGradient.Assign ( NewGradient ) ;
end ;

{ Сравнение контролов для сортировки в ListControls }
function TLayout.CompareControlsInternal ( Control1, Control2 : TControl ) : integer ;
var i1, i2 : integer ;
begin
  Assert ( FNewControls <> nil ) ;
  i1 := FNewControls.IndexOf ( Control1 ) ;
  i2 := FNewControls.IndexOf ( Control2 ) ;
  if ( Control1 = Control2 ) then
    Result := 0
  else if ( i1 < 0 ) and ( i2 < 0 ) then
    Result := CompareControls ( Control1, Control2 )
  else if ( i1 >= 0 ) and ( i2 < 0 ) then
    Result := 1
  else if ( i1 < 0 ) and ( i2 >= 0 ) then
    Result := -1
  else
    Result := Sign ( i1 - i2 ) ;
end ;

{ TFixedListLayout }

{ Создание массива дочерних для компонент при создании компонента }
constructor TFixedListLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  FMaxControl := GetControlsRequired - 1 ;
  SetLength ( FControls, MaxControl + 1 ) ;
end ;

{ Подбор места для очередного компонента }
procedure TFixedListLayout.ControlAdded ( Control : TControl ) ;
var i : integer ;
begin
  for i := 0 to MaxControl do
    if FControls [ i ] = nil then
    begin
      SetControl ( i, Control ) ;
      exit ;
    end ;
  KickOut ( Control ) ;
  raise EFixedListLayout.CreateFmt ( Self, STooManyControls, [ MaxControl + 1 ]) ;
end ;

{ Реакция на удаление компонента }
procedure TFixedListLayout.ControlRemoved ( Control : TControl ) ;
var i : integer ;
begin
  inherited ;
  for i := MaxControl downto 0 do
    if FControls [ i ] = Control then
    begin
      FControls [ i ] := nil ;
      RequestLayout ;
    end ;
end ;

{ Разрешение или запрет уведомлений об изменении списка компонент }
function TFixedListLayout.ControlNotificationsEnabled : boolean ;
begin
  Result := ( FlagIntoSetControl = 0 ) ;
end ;

{ Методы свойств }

function TFixedListLayout.GetControl ( Index : integer ) : TControl ;
begin
  Result := FControls [ Index ] ;
end ;

procedure TFixedListLayout.SetControl ( Index : integer ; NewControl : TControl ) ;
var i : integer ;
begin
  if NewControl = GetControl ( Index ) then exit ;
  CheckServiceControl ( NewControl ) ;
  try
    Inc ( FlagIntoSetControl ) ;
    DisableLayout ;
    for i := 0 to MaxControl do
      if Assigned ( FControls [ i ]) and
         (( i = Index ) or ( FControls [ i ] = NewControl )) then
      begin
        RemoveFreeNotification ( FControls [ i ]) ;
        if FControls [ i ] <> NewControl then KickOut ( FControls [ i ]) ;
        FControls [ i ] := nil ;
      end ;
    if Assigned ( NewControl ) then
    begin
      FreeNotification ( NewControl ) ;
      NewControl.Parent := Self ;
      FControls [ Index ] := NewControl ;
    end ;
  finally
    Dec ( FlagIntoSetControl ) ;
    EnableLayout ;
  end ;
end ;

{ TLayoutMargins }

constructor TLayoutMargins.Create ( AOwner : TLayout ) ;
begin
  Assert ( AOwner <> nil ) ;
  SetLength ( FMargins, 6 ) ;
  inherited Create ;
  FOwner := AOwner ;
  Defaults ([ -1, -1, -1, -1, -1, -1 ]) ;
end ;

procedure TLayoutMargins.Defaults ( const Default : array of integer ) ;
var i : integer ;
begin
  for i := Low ( Default ) to High ( Default ) do
  begin
    Assert ( Default [ i ] >= -1 ) ;
    SetMargin ( i, Default [ i ]) ;
  end ;
end ;

function TLayoutMargins.GetMargin ( Index : integer ) : integer ;
begin
  if Index < Length ( FMargins )
    then Result := FMargins [ Index ]
    else Result := -1 ;
  if Result = -1 then
    if ( Index in [ 0..3 ]) and Assigned ( FOwner ) and
       Assigned ( FOwner.Parent ) and ( FOwner.Parent is TLayout )
      then Result := 0
      else Result := 5 ;
end ;

procedure TLayoutMargins.SetMargin ( Index, NewValue : integer ) ;
begin
  if NewValue < -1 then NewValue := -1 ;
  if Index >= Length ( FMargins ) then SetLength ( FMargins, Index + 1 ) ;
  if FMargins [ Index ] = NewValue then exit ;
  FMargins [ Index ] := NewValue ;
  FOwner.MarginsChanged ;
end ;

function TLayoutMargins.StoreMargin ( Index : integer ) : boolean ;
begin
  Result := ( FMargins [ Index ] <> -1 ) ;
end ;

initialization
  SaveBrush := TBrush.Create ;
  SavePen := TPen.Create ;
  ConvertPropertyNotifier := TSTSNotifier.Create ( nil ) ;

finalization
  FreeAndNil ( SaveBrush ) ;
  FreeAndNil ( SavePen ) ;
  FreeAndNil ( ConvertPropertyNotifier ) ;

end.
