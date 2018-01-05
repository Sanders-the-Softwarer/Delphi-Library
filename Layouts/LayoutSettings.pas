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

Компонент содержит настройки, общие сразу для многих layout-компонент (в
большинстве случаев хватает единственного компонента на все приложение).

Компоненты настроек образуют дерево, в котором каждый компонент берет часть
настроек у родителя и вносит часть собственных. Layout-компоненты цепляются
к выбранному варианту настроек и питаются оттуда как дефолтовыми значениями
свойств (что актуально только при создании нового компонента), так и текущими
настройками отображения.

Для идентификации компонентов используются GUID-ы, генерящиеся при создании
компонента и далее обычно не меняющиеся. Это позволяет избежать прямых связей,
поддержка которых стала бы кошмаром для разработчика, но вносит проблему
дублирования - в результате наследования или копирования компонент может
оказаться необходимым менять идентификатор.

------------------------------------------------------------------------------ }

unit LayoutSettings ;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Contnrs,
  Graphics, STSNotifier, LayoutMisc ;

type
  { Заранее объявим основной компонент }
  TLayoutSettings = class ;

  { Базовый класс для групп свойств }
  TLayoutSubSettings = class ( TPersistent )
  private
    FSettings : TLayoutSettings ;
  public
    constructor Create ( ASettings : TLayoutSettings ) ;
    property Settings : TLayoutSettings read FSettings ;
  end ;

  { Настройки поведения в дизайн-тайме }
  TIDESettings = class ( TLayoutSubSettings )
  private
    FAddFlowLayout : boolean ;
    FRootBackground, FChildBackground : TLayoutBackground ;
    FRegistrySettings : boolean ;
    FMsgDefaultSelected : boolean ;
    FMsgConvertProperties : boolean ;
    FFlipSplitter : boolean ;
  public
    procedure AfterConstruction ; override ;
  published
    { Добавлять ли FlowLayout на подходящие компоненты }
    property AddFlowLayout : boolean
        read FAddFlowLayout write FAddFlowLayout stored true ;
    { Значение Background для корневых layout-ов }
    property RootBackground : TLayoutBackground
        read FRootBackground write FRootBackground stored true ;
    { Значение Background для layout-ов, лежащих на других layout-ах }
    property ChildBackground : TLayoutBackground
        read FChildBackground write FChildBackground stored true ;
    { Использовать ли registry для сохранения-восстановления настроек }
    property RegistrySettings : boolean
        read FRegistrySettings write FRegistrySettings stored true ;
    { Выдавать ли сообщение при автоматическом выборе настроек по умолчанию }
    property MsgDefaultSelected : boolean
        read FMsgDefaultSelected write FMsgDefaultSelected stored true ;
    { Выдавать ли сообщение при конвертации старых свойств в новый формат }
    property MsgConvertProperties : boolean
        read FMsgConvertProperties write FMsgConvertProperties stored true ;
    { Менять ли ориентацию уложенных друг на друга сплиттеров }
    property FlipSplitter : boolean
        read FFlipSplitter write FFlipSplitter stored true ;
  end ;

  { Описание компонент-меток }

  TLabelInfo = class ( TCollectionItem )
  private
    FLabelClass, FFocusControl : string ;
  protected
    function Settings : TLayoutSettings ;
    function GetDisplayName : string ; override ;
    procedure SetLabelClass ( NewLabelClass : string ) ;
    procedure SetFocusControl ( NewFocusControl : string ) ;
  published
    property LabelClass : string read FLabelClass write SetLabelClass ;
    property FocusControl : string read FFocusControl write SetFocusControl ;
  end ;

  TLabelsInfo = class ( TOwnedCollection )
  protected
    { Возврат свойства с приведением типа }
    function GetItem ( Index : integer ) : TLabelInfo ;
    { Поиск информации для указанного класса }
    function FindLabelInfo ( ALabelClass : string ) : TLabelInfo ;
  public
    constructor Create ( AOwner : TPersistent ) ;
    { Возврат компонента, к которому привязаны настройки }
    function Settings : TLayoutSettings ;
    { Добавление записи в список }
    procedure Add ( ALabelClass, AFocusControl : string ) ;
    { Проверка, является ли указанный класс классом меток }
    function IsLabelClass ( ClassName : string ) : boolean ;
    { Возврат свойства связи с обслуживаемым компонентом }
    function GetFocusControl ( ClassName : string ) : string ;
  public
    property Items [ Index : integer ] : TLabelInfo read GetItem ;
  end ;

  { Настройки компонент }
  TComponentSettings = class ( TLayoutSubSettings )
  private
    FDefaultLabel : string ;
    FDefaultButton : string ;
    FLabelsInfo : TLabelsInfo ;
    FConvertingFromLabels : TStringList ;
  protected
    procedure SetLabelsInfo ( NewLabelsInfo : TLabelsInfo ) ;
    procedure ConvertingLabelsHandler ( Sender : TObject ) ;
  public
    procedure AfterConstruction ; override ;
    destructor Destroy ; override ;
    function ConvertingFromLabels : TStringList ;
  published
    property DefaultButton : string read FDefaultButton write FDefaultButton ;
    property DefaultLabel : string read FDefaultLabel write FDefaultLabel ;
    property LabelsInfo : TLabelsInfo read FLabelsInfo write SetLabelsInfo ;
  end ;

  { Компонент настроек }
  TLayoutSettings = class ( TComponent )
  private
    FShadow  : boolean ;
    FShadowName : string ;
    FDefault : boolean ;
    FGuid    : string ;
    FComponentSettings : TComponentSettings ;
    FIDESettings : TIDESettings ;
    FlagIntoWriteState : boolean ;
  protected
    procedure CreateGuid ;
    function  GetGuid : string ;
    procedure SetGuid ( NewGuid : string ) ;
    procedure ReadGuid ( Reader : TReader ) ;
    procedure WriteGuid ( Writer : TWriter ) ;
    procedure ReadAddFlowLayout ( Reader : TReader ) ;
    procedure ReadDefaultLabel ( Reader : TReader ) ;
    function  GetLabels : TStrings ;
    procedure SetLabels ( NewLabels : TStrings ) ;
    { Оповещения, на которые мы отвечаем }
    procedure GradientChanged ( Sender : TObject ) ;
    procedure FindByGuidNotification ( Sender : TObject ) ;
    procedure FindDefaultNotification ( Sender : TObject ) ;
    procedure DropShadowSettings ( Sender : TObject ) ;
    { Методы свойств }
    procedure SetComponentSettings ( NewSettings : TComponentSettings ) ;
    procedure SetIDESettings ( NewSettings : TIDESettings ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    constructor CreateShadow ;
    destructor Destroy ; override ;
    procedure DefineProperties ( Filer : TFiler ) ; override ;
    procedure WriteState ( Writer : TWriter ) ; override ;
    procedure Loaded ; override ;
    procedure NotifyChanged ;
  public
    property Guid : string read FGuid ;
    property Shadow : boolean read FShadow ;
    property ShadowName : string read FShadowName write FShadowName ;
  published
    property Default : boolean
        read FDefault write FDefault stored true ;
    property ComponentSettings : TComponentSettings
        read FComponentSettings write SetComponentSettings ;
    property IDESettings : TIDESettings
        read FIDESettings write SetIDESettings ;
    property Labels : TStrings read GetLabels write SetLabels stored false ;
  end ;

var
  { Оповещение о дублировании GUID и необходимости генерации нового }
  GuidDuplicatesProc : TNotifyEvent ;
  { Оповещения о чтении-записи Settings-компонента }
  LayoutSettingsLoadedProc : TNotifyEvent ;
  LayoutSettingsSavedProc  : TNotifyEvent ;
  { Оповещение поиска компонента по guid-у }
  FindByGuidNotifier : TSTSNotifier ;
  { Оповещение поиска компонента настроек по умолчанию }
  FindDefaultNotifier : TSTSNotifier ;
  { Оповещение о потребности в теневом компоненте настроек по умолчанию }
  MakeShadowSettingsNotifier : TSTSNotifier ;
  { Оповещение удаления теневого компонента }
  DropShadowSettingsNotifier : TSTSNotifier ;
  { Оповещение о себе нового или искомого компонента }
  LayoutSettingsNotifier : TSTSNotifier ;
  { Оповещение об изменении настроек }
  SettingsChangedNotifier : TSTSNotifier ;

{ Поиск настроек по умолчанию }
function DefaultLayoutSettings : TLayoutSettings ;
function DefaultLayoutSettingsList : TControlList ;

implementation

uses BaseLayout, RecordList ;

resourcestring
  SLabelsObsolete = 'Свойство Labels устарело и поддерживается только для ' +
                    'конвертации старых dfm-файлов. Не надо обращаться к ' +
                    'нему во время работы программы; используйте ' +
                    'ComponentSettings.LabelsInfo' ;

type
  { Список созданных компонент }
  TSettingsList = class ( TRecordList )
  protected
    function GetSettings ( ArrIndex, Index : integer ) : TLayoutSettings ;
    procedure SetSettings ( ArrIndex, Index : integer ; NewSettings : TLayoutSettings ) ;
  public
    property Guid [ ArrIndex : integer ] : AnsiString index 0
             read GetStr write SetSortStr ;
    property Settings [ ArrIndex : integer ] : TLayoutSettings index 1
             read GetSettings write SetSettings ;
  public
    constructor Create ; override ;
    procedure Remove ( AGuid : string ) ;
  end ;

constructor TSettingsList.Create ;
begin
  inherited Create ;
  RecordLength := 2 ;
  SetSortOrder ( 0 ) ;
end ;

procedure TSettingsList.Remove ( AGuid : string ) ;
var i : integer ;
begin
  i := SortIndexOf ( AGuid ) ;
  if i >= 0 then Delete ( i ) ;
end ;

function TSettingsList.GetSettings ;
begin
  Result := TLayoutSettings ( GetObj ( ArrIndex, Index )) ;
end ;

procedure TSettingsList.SetSettings ;
begin
  SetObj ( ArrIndex, Index, NewSettings ) ;
end ;

var
  SettingsList : TSettingsList ;

{ TLayoutSettings }

constructor TLayoutSettings.Create ( AOwner : TComponent ) ;
begin
  Assert ( FindByGuidNotifier <> nil ) ;
  Assert ( FindDefaultNotifier <> nil ) ;
  Assert ( DropShadowSettingsNotifier <> nil ) ;
  inherited ;
  FComponentSettings := TComponentSettings.Create ( Self ) ;
  FIDESettings := TIDESettings.Create ( Self ) ;
  FComponentStyle := ComponentStyle - [ csInheritable ] ;
  FindByGuidNotifier.RegisterNotification ( FindByGuidNotification ) ;
  FindDefaultNotifier.RegisterNotification ( FindDefaultNotification ) ;
  if Shadow
    then DropShadowSettingsNotifier.RegisterNotification ( DropShadowSettings )
    else CreateGuid ;
end ;

{ Конструктор для создания теневых компонент }
constructor TLayoutSettings.CreateShadow ;
begin
  FShadow := true ;
  Create ( Application ) ;
end ;

destructor TLayoutSettings.Destroy ;
begin
  if FindByGuidNotifier <> nil then
    FindByGuidNotifier.RemoveNotification ( FindByGuidNotification ) ;
  if FindDefaultNotifier <> nil then
    FindDefaultNotifier.RemoveNotification ( FindDefaultNotification ) ;
  if DropShadowSettingsNotifier <> nil then
    DropShadowSettingsNotifier.RemoveNotification ( DropShadowSettings ) ;
  if SettingsList <> nil then
    SettingsList.Remove ( FGuid ) ;
  inherited ;
  FreeAndNil ( FComponentSettings ) ;
  FreeAndNil ( FIDESettings ) ;
end ;

{ Чтение-запись GUID из dfm }
procedure TLayoutSettings.DefineProperties ( Filer : TFiler ) ;
begin
  inherited ;
  Filer.DefineProperty ( 'Guid', ReadGuid, WriteGuid, true ) ;
  { Конвертация свойств предыдущих версий компонента }
  Filer.DefineProperty ( 'AddFlowLayout', ReadAddFlowLayout, nil, false );
  Filer.DefineProperty ( 'DefaultLabel', ReadDefaultLabel, nil, false ) ;
end ;

{ После сохранения компонента в dfm }
procedure TLayoutSettings.WriteState ( Writer : TWriter ) ;
begin
  inherited ;
  if FlagIntoWriteState or Shadow or not Assigned ( LayoutSettingsSavedProc ) then exit ;
  try
    FlagIntoWriteState := true ;
    LayoutSettingsSavedProc ( Self ) ;
  finally
    FlagIntoWriteState := false ;
  end ;
end ;

{ После считывания компонента из dfm }
procedure TLayoutSettings.Loaded ;
begin
  inherited ;
  if Assigned ( LayoutSettingsLoadedProc ) and not Shadow then
  try
    FlagIntoWriteState := true ;
    LayoutSettingsLoadedProc ( Self ) ;
  finally
    FlagIntoWriteState := false ;
  end ;
end ;

{ Оповещение компонент об изменении настроек }
procedure TLayoutSettings.NotifyChanged ;
begin
  if not ( csLoading in ComponentState ) then
    SettingsChangedNotifier.Fire ( Self ) ;
end ;

{ Создание GUID-а, идентифицирующего компонент }
procedure TLayoutSettings.CreateGuid ;
var G : TGUID ;
begin
  if SysUtils.CreateGuid ( G ) <> S_OK then RaiseLastOSError ;
  SetGuid ( GuidToString ( G )) ;
end ;

{ Возврат GUID-а с генерацией при необходимости }
function TLayoutSettings.GetGuid : string ;
begin
  if FGuid = '' then CreateGuid ;
  Result := FGuid ;
end ;

{ Установка Guid-а }
procedure TLayoutSettings.SetGuid ( NewGuid : string ) ;
var i1, i2 : integer ;
begin
  Assert ( DropShadowSettingsNotifier <> nil ) ;
  Assert ( SettingsList <> nil ) ;
  DropShadowSettingsNotifier.Fire ( NewGuid ) ;
  i1 := SettingsList.SortIndexOf ( FGuid ) ;
  i2 := SettingsList.SortIndexOf ( NewGuid ) ;
  if i2 >= 0 then
    begin
      if Assigned ( GuidDuplicatesProc ) then GuidDuplicatesProc ( Self ) ;
      CreateGuid ;
    end
  else
    begin
      FGuid := NewGuid ;
      if i1 >= 0
        then SettingsList.Guid [ i1 ] := NewGuid
        else SettingsList.AddRecord ([ NewGuid, integer ( Self )]) ;
      Assert ( LayoutSettingsNotifier <> nil ) ;
      LayoutSettingsNotifier.Fire ( Self ) ;
    end ;
end ;

{ Чтение Guid из dfm }
procedure TLayoutSettings.ReadGuid ( Reader : TReader ) ;
begin
  SetGuid ( Reader.ReadString ) ;
end ;

{ Запись Guid в dfm }
procedure TLayoutSettings.WriteGuid ( Writer : TWriter ) ;
begin
  Writer.WriteString ( GetGuid ) ;
end ;

{ Считывание свойства AddFlowLayout, существовавшего в предыдущей версии }
procedure TLayoutSettings.ReadAddFlowLayout ( Reader : TReader ) ;
begin
  IDESettings.AddFlowLayout := Reader.ReadBoolean ;
  NotifyConvertProperty ( Self, 'AddFlowLayout' ) ;
end ;

{ Считывание свойства DefaultLabel, существовавшего в предыдущей версии }
procedure TLayoutSettings.ReadDefaultLabel ( Reader : TReader ) ;
begin
  ComponentSettings.DefaultLabel := Reader.ReadString ;
  NotifyConvertProperty ( Self, 'DefaultLabel' ) ;
end ;

{ Считывание устаревшего свойства Labels }

function TLayoutSettings.GetLabels : TStrings ;
begin
  if [ csLoading, csDesigning ] * ComponentState <> []
    then Result := ComponentSettings.ConvertingFromLabels
    else raise ELayout.Create ( Self, SLabelsObsolete ) ;
end ;

procedure TLayoutSettings.SetLabels ( NewLabels : TStrings ) ;
begin
end ;

{ Оповещение об изменении настроек градиента }
procedure TLayoutSettings.GradientChanged ( Sender : TObject ) ;
begin
  NotifyChanged ;
end ;

{ Ответ на оповещение поиска компонента по Guid-у }
procedure TLayoutSettings.FindByGuidNotification ( Sender : TObject ) ;
var SearchGuid : string ;
begin
  Assert ( LayoutSettingsNotifier <> nil ) ;
  SearchGuid := ( Sender as TSTSNotifier ).DataString ;
  if SearchGuid = Self.Guid then
    LayoutSettingsNotifier.Fire ( Self ) ;
end ;

{ Ответ на оповещение поиска компонента по умолчанию }
procedure TLayoutSettings.FindDefaultNotification ( Sender : TObject ) ;
begin
  Assert ( LayoutSettingsNotifier <> nil ) ;
  if Self.Default then
    LayoutSettingsNotifier.Fire ( Self ) ;
end ;

{ Оповещение о загрузке основного компонента и необходимости удаления теневого }
procedure TLayoutSettings.DropShadowSettings ( Sender : TObject ) ;
begin
  Assert ( Sender <> nil ) ;
  Assert ( Sender is TSTSNotifier ) ;
  if Shadow and SameText ( Self.Guid, TSTSNotifier ( Sender ).DataString ) then
    Self.Free ;
end ;

{ Методы свойств }

procedure TLayoutSettings.SetComponentSettings ( NewSettings : TComponentSettings ) ;
begin
end ;

procedure TLayoutSettings.SetIDESettings ( NewSettings : TIDESettings ) ;
begin
end ;

{ TLayoutSubSettings }

constructor TLayoutSubSettings.Create ( ASettings : TLayoutSettings ) ;
begin
  inherited Create ;
  FSettings := ASettings ;
end ;

{ TIDESettings }

procedure TIDESettings.AfterConstruction ;
begin
  inherited ;
  FAddFlowLayout := true ;
  FRootBackground := lbDefault ;
  FChildBackground := lbDefault ;
  FRegistrySettings := true ;
  FMsgConvertProperties := true ;
  FFlipSplitter := true ;
end ;

{ TLabelInfo }

{ Возврат компонента-владельца }
function TLabelInfo.Settings : TLayoutSettings ;
begin
  Assert ( Collection <> nil ) ;
  Assert ( Collection is TLabelsInfo ) ;
  Result := TLabelsInfo ( Collection ).Settings ;
  Assert ( Result <> nil ) ;
end ;

{ Возврат названия компонента для Object Inspector-а }
function TLabelInfo.GetDisplayName : string ;
begin
  if LabelClass <> ''
    then Result := Format ( '%s (%s)', [ LabelClass, FocusControl ])
    else Result := inherited GetDisplayName ;
end ;

{ Установка свойства LabelClass }
procedure TLabelInfo.SetLabelClass ( NewLabelClass : string ) ;
begin
  if FLabelClass = NewLabelClass then exit ;
  FLabelClass := NewLabelClass ;
  Settings.NotifyChanged ;
end ;

{ Установка свойства FocusControl }
procedure TLabelInfo.SetFocusControl ( NewFocusControl : string ) ;
begin
  if FFocusControl = NewFocusControl then exit ;
  FFocusControl := NewFocusControl ;
  Settings.NotifyChanged ;
end ;

{ TLabelsInfo }

constructor TLabelsInfo.Create ( AOwner : TPersistent ) ;
begin
  inherited Create ( AOwner, TLabelInfo ) ;
end ;

{ Возврат компонента, к которому привязаны настройки }
function TLabelsInfo.Settings : TLayoutSettings ;
begin
  Assert ( Owner <> nil ) ;
  Assert ( Owner is TLayoutSettings ) ;
  Result := TLayoutSettings ( Owner ) ;
end ;

{ Добавление записи в список }
procedure TLabelsInfo.Add ( ALabelClass, AFocusControl : string ) ;
begin
  with inherited Add as TLabelInfo do
  begin
    LabelClass := ALabelClass ;
    FocusControl := AFocusControl ;
  end ;
end ;

{ Проверка, является ли указанный класс классом меток }
function TLabelsInfo.IsLabelClass ( ClassName : string ) : boolean ;
begin
  Result := ( FindLabelInfo ( ClassName ) <> nil ) ;
end ;

{ Возврат свойства связи с обслуживаемым компонентом }
function TLabelsInfo.GetFocusControl ( ClassName : string ) : string ;
var LabelInfo : TLabelInfo ;
begin
  LabelInfo := FindLabelInfo ( ClassName ) ;
  if Assigned ( LabelInfo )
    then Result := LabelInfo.FocusControl
    else Result := '' ;
end ;

{ Поиск информации для указанного класса }
function TLabelsInfo.FindLabelInfo ( ALabelClass : string ) : TLabelInfo ;
var i : integer ;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items [ i ] ;
    if SameText ( ALabelClass, Result.LabelClass ) then exit ;
  end ;
  Result := nil ;
end ;

{ Возврат свойства с приведением типа }
function TLabelsInfo.GetItem ( Index : integer ) : TLabelInfo ;
begin
  Result := TLabelInfo ( inherited Items [ Index ]) ;
  Assert ( Result <> nil ) ;
  Assert ( Result is TLabelInfo ) ;
end ;

{ TComponentSettings }

procedure TComponentSettings.AfterConstruction ;
begin
  inherited ;
  DefaultButton := 'TBitBtn' ;
  DefaultLabel  := 'TInputLayoutLabel' ;
  FLabelsInfo := TLabelsInfo.Create ( Self.Settings ) ;
  FLabelsInfo.Add ( 'TLabel', 'FocusControl' ) ;
  FLabelsInfo.Add ( 'TStaticText', 'FocusControl' ) ;
  FLabelsInfo.Add ( 'TInputLayoutLabel', 'FocusControl' ) ;
end ;

destructor TComponentSettings.Destroy ;
begin
  inherited ;
  FreeAndNil ( FLabelsInfo ) ;
  FreeAndNil ( FConvertingFromLabels ) ;
end ;

{ Подготовка объекта-импортера настроек старого формата }
function TComponentSettings.ConvertingFromLabels : TStringList ;
begin
  if FConvertingFromLabels = nil then
  begin
    FConvertingFromLabels := TStringList.Create ;
    FConvertingFromLabels.OnChange := ConvertingLabelsHandler ;
  end ;
  Result := FConvertingFromLabels ;
end ;

procedure TComponentSettings.SetLabelsInfo ( NewLabelsInfo : TLabelsInfo ) ;
begin
end ;

{ Конвертация настроек из старого формата в новый }
procedure TComponentSettings.ConvertingLabelsHandler ( Sender : TObject ) ;
var
  i, p : integer ;
  S : string ;
begin
  for i := 0 to FConvertingFromLabels.Count - 1 do
  begin
    S := FConvertingFromLabels [ i ] ;
    p := Pos ( '.', S ) ;
    if p <= 0 then continue ;
    LabelsInfo.Add ( System.Copy ( S, 1, p - 1 ), System.Copy ( S, p + 1, Length ( S ))) ;
  end ;
  NotifyConvertProperty ( Settings, 'Labels' ) ;
end ;

{ TDefaultSettingsFinder }

type
  TDefaultSettingsFinder = class ( TSTSNotifierLink )
  private
    FList : TControlList ;
    procedure DoNotification ( Sender : TObject ) ; override ;
  public
    constructor Create ; reintroduce ;
    destructor Destroy ; override ;
    class function List : TControlList ;
  end ;

var
  DefaultSettingsFinder : TDefaultSettingsFinder ;
  VendorLayoutSettings  : TLayoutSettings ;

class function TDefaultSettingsFinder.List : TControlList ;
begin
  if DefaultSettingsFinder = nil then
    DefaultSettingsFinder := TDefaultSettingsFinder.Create ;
  DefaultSettingsFinder.FList.Clear ;
  FindDefaultNotifier.Fire ;
  Result := DefaultSettingsFinder.FList ;
end ;

constructor TDefaultSettingsFinder.Create ;
begin
  inherited Create ( nil ) ;
  FList := TControlList.Create ;
  Notifier := LayoutSettingsNotifier ;
end ;

destructor TDefaultSettingsFinder.Destroy ;
begin
  inherited ;
  FreeAndNil ( FList ) ;
end ;

procedure TDefaultSettingsFinder.DoNotification ( Sender : TObject ) ;
begin
  Assert ( Notifier.Data <> nil ) ;
  Assert ( Notifier.Data is TLayoutSettings ) ;
  FList.Add ( Notifier.Data ) ;
end ;

{ Поиск настроек по умолчанию }
function DefaultLayoutSettingsList : TControlList ;
begin
  Result := TDefaultSettingsFinder.List ;
end ;

{ Поиск настроек по умолчанию }
function DefaultLayoutSettings : TLayoutSettings ;
var List : TControlList ;
begin
  List := DefaultLayoutSettingsList ;
  if List.Count > 0
    then Result := TLayoutSettings ( List.Last )
    else Result := VendorLayoutSettings ;
end ;

initialization
  FindByGuidNotifier := TSTSNotifier.Create ( nil ) ;
  FindDefaultNotifier := TSTSNotifier.Create ( nil ) ;
  LayoutSettingsNotifier := TSTSNotifier.Create ( nil ) ;
  SettingsChangedNotifier := TSTSNotifier.Create ( nil ) ;
  MakeShadowSettingsNotifier := TSTSNotifier.Create ( nil ) ;
  DropShadowSettingsNotifier := TSTSNotifier.Create ( nil ) ;
  SettingsList := TSettingsList.Create ;
  VendorLayoutSettings := TLayoutSettings.Create ( nil ) ;

finalization
  FreeAndNil ( DefaultSettingsFinder ) ;
  FreeAndNil ( VendorLayoutSettings ) ;
  FreeAndNil ( SettingsList ) ;
  FreeAndNil ( FindByGuidNotifier ) ;
  FreeAndNil ( FindDefaultNotifier ) ;
  FreeAndNil ( LayoutSettingsNotifier ) ;
  FreeAndNil ( SettingsChangedNotifier ) ;
  FreeAndNil ( MakeShadowSettingsNotifier ) ;
  FreeAndNil ( DropShadowSettingsNotifier ) ;

end.

