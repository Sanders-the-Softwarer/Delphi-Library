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

Модуль содержит код, работающий только в дизайн-тайме. Этот модуль предлагается
включить в отдельный дизайн-таймовый пакет и не таскать за приложением в
ран-тайме.

Здесь содержится код, добавляющий некоторые фичи во время работы в IDE - так,
при кидании с палитры layout-компонент они автоматически привязываются к
настройкам, для BorderLayout-ов автоматически создается нижняя FlowLayout-панель
итп.

------------------------------------------------------------------------------ }

unit LayoutsDsgn ;

interface

uses Windows, Classes, SysUtils, Controls, StdCtrls, Buttons, DesignIntf,
  Registry, Dialogs ;

procedure Register ;

implementation

uses BaseLayout, Layouts, LayoutSettings, FlowLayout, NotebookLayout,
  InputLayout, RuledLayout, TypInfo, NotebookLayoutDsgn, CmpUtils, StsNotifier,
  LayoutMisc, LayoutSettingsSelect, SplitterLayout ;

type
  { Класс, методы которого будут использоваться как обработчики событий }
  TLayoutDsgn = class
  private
    LookForDefault : boolean ;
    DefaultSettingsList : TStringList ;
    IntoLoadLayoutSettings : boolean ;
  public
    constructor Create ;
    destructor Destroy ; override ;
    { Обработчики событий }
    procedure CreateLayout ( Sender : TObject ) ;
    procedure LayoutSettingsLoaded ( Sender : TObject ) ;
    procedure LayoutSettingsSaved ( Sender : TObject ) ;
    procedure ConvertProperty ( Sender : TObject ) ;
    procedure SettingsGuidDuplicates ( Sender : TObject ) ;
    procedure LabelRequiredProc ( Sender : TCustomInputLayout ;
                                  Control : TControl ) ;
    procedure LayoutSettingsNotification ( Sender : TObject ) ;
    procedure MakeShadowSettings ( Sender : TObject ) ;
    { Рабочие методы }
    procedure ListDefaultSettings ;
    function  SelectDefaultSettings ( Layout : TLayout ) : TLayoutSettings ;
    procedure SaveLayoutSettings ( Settings : TLayoutSettings ) ;
    procedure LoadLayoutSettings ( Guid : string ) ;
  end ;

var
  DsgnObject : TLayoutDsgn ;

const
  LayoutCategory = 'Layout' ;
  SaveLayoutSettingsKey = 'Software\Sanders the Softwarer\Design\LayoutSettings' ;

resourcestring
  SCantSaveLayout    = 'Ошибка при дополнительном сохранении настроек ' +
                       'компонента %s: %s'#13#13 +
                       'Из-за этой ошибки layout-компоненты, использующие ' +
                       'этот компонент настроек, могут некорректно ' +
                       'отображаться в тех случаях, когда компонент настроек ' +
                       'выгружен из памяти' ;
  SNoDefaultSettings = 'Не найдено ни одного компонента настроек по ' +
                       'умолчанию. Для того, чтобы правильно ' +
                       'инициализировать новые компоненты, создайте или ' +
                       'загрузите компонент TLayoutSettings с установленным ' +
                       'в true свойством Default' ;
  SGuidDuplicates    = 'Обнаружены несколько компонент TLayoutSettings, ' +
                       'обладающих одинаковым уникальным идентификатором ' +
                       '(GUID). Такая ситуация могла возникнуть вследствие ' +
                       'копирования компонента через буфер обмена или другой ' +
                       'подобной операции.'#13#13'Дублирование ' +
                       'идентификаторов недопустимо; одному из компонент ' +
                       'будет присвоен новый идентификатор. Это может ' +
                       'привести к тому, что уже существующие ' +
                       'layout-компоненты окажутся привязаны "не к тому" ' +
                       'компоненту настроек, поэтому Вам следует проверить ' +
                       'и при необходимости скорректировать привязку компонент';
  SDefaultSelected   = 'Автоматически выбран компонент настроек по умолчанию %s' ;
  SConvertProperties = 'Свойство %s.%s было сконвертировано из устаревшего ' +
                       'формата в новый. Убедитесь, что dfm-файл компонента ' +
                       'будет сохранен - в противном случае при следующих ' +
                       'операциях Вы снова получите это сообщение' ;

{ Регистрация свойства компонента в нашей категории }
procedure RegisterProperties ( ComponentClass : TClass ;
                               const Filters : array of string ) ;
begin
  RegisterPropertiesInCategory ( LayoutCategory, ComponentClass, Filters ) ;
end ;

procedure Register ;
begin
  RegisterComponents ( 'Layouts', [ TLayoutSettings, TDelphiLayout,
    TBorderLayout, TFlowLayout, TDualLayout, TNotebookLayout, TInputLayout,
    TActionPane, TInputLayoutLabel, TSplitterLayout {, TRuledLayout} ]) ;
  { Регистрация редакторов }
  RegisterPropertyEditor ( TypeInfo ( TStrings ), TLayoutSettings,
    'Labels', nil ) ;
  RegisterComponentEditor ( TCustomNotebookLayout, TNotebookLayoutEditor ) ;
  RegisterPropertyEditor ( TypeInfo ( TControl ), TCustomNotebookLayout,
    'ActivePage', TActivePageEditor ) ;
  { Регистрация наших свойств в нашей категории }
  RegisterProperties ( TLayoutSettings, [ 'Default', 'ComponentSettings',
    'IDESettings', 'InputLayoutSettings' ]) ;
  RegisterProperties ( TLayout, [ 'LayoutActive', 'Margins', 'Settings',
    'Background', 'Gradient' ]) ;
  RegisterProperties ( TFlowLayout, [ 'AutoHeight', 'AutoWidth',
    'DelimiterControl', 'Direction' ]) ;
  RegisterProperties ( TNotebookLayout, [ 'ActivePage' ]) ;
  RegisterProperties ( TDualLayout, [ 'LeftControl', 'RightControl',
    'CenterControl' ]) ;
  RegisterProperties ( TBorderLayout, [ 'CenterControl', 'TopControl',
    'LeftControl', 'RightControl', 'BottomControl', 'SubTopControl',
    'SubBottomControl' ]) ;
  RegisterProperties ( TInputLayout, [ 'AutoLabelWidth', 'LabelWidth',
    'LabelAlignment', 'RubberControl' ]) ;
  RegisterProperties ( TRuledLayout, [ 'Rules' ]) ;
  RegisterProperties ( TSplitterLayout, [ 'BottomControl', 'DefaultPosition',
    'Direction', 'HideControl', 'LeftControl', 'MinLeft', 'MinRight',
    'Ratio', 'ResizeBehaviour', 'RightControl', 'Position', 'TopControl' ]) ;

end ;

{ TLayoutDsgn }

constructor TLayoutDsgn.Create ;
begin
  inherited ;
  DefaultSettingsList := TStringList.Create ;
  BaseLayout.CreateLayoutProc := Self.CreateLayout ;
  LayoutSettings.GuidDuplicatesProc := Self.SettingsGuidDuplicates ;
  InputLayout.LabelRequiredProc := Self.LabelRequiredProc ;
  LayoutSettings.LayoutSettingsLoadedProc := Self.LayoutSettingsLoaded ;
  LayoutSettings.LayoutSettingsSavedProc := Self.LayoutSettingsSaved ;
  Assert ( ConvertPropertyNotifier <> nil ) ;
  ConvertPropertyNotifier.RegisterNotification ( ConvertProperty ) ;
  Assert ( MakeShadowSettingsNotifier <> nil ) ;
  MakeShadowSettingsNotifier.RegisterNotification ( MakeShadowSettings ) ;
  Assert ( LayoutSettingsNotifier <> nil ) ;
  LayoutSettingsNotifier.RegisterNotification ( LayoutSettingsNotification ) ;
end ;

destructor TLayoutDsgn.Destroy ;
begin
  inherited ;
  FreeAndNil ( DefaultSettingsList ) ;
  BaseLayout.CreateLayoutProc := nil ;
  LayoutSettings.GuidDuplicatesProc := nil ;
  InputLayout.LabelRequiredProc := nil ;
  LayoutSettings.LayoutSettingsLoadedProc := nil ;
  LayoutSettings.LayoutSettingsSavedProc := nil ;
  if ConvertPropertyNotifier <> nil then
    ConvertPropertyNotifier.RemoveNotification ( ConvertProperty ) ;
  if LayoutSettingsNotifier <> nil then
    LayoutSettingsNotifier.RemoveNotification ( LayoutSettingsNotification ) ;
end ;

procedure TLayoutDsgn.CreateLayout ( Sender : TObject ) ;
var
  Selected, Settings : TLayoutSettings ;
  Layout       : TLayout absolute Sender ;
  BorderLayout : TBorderLayout absolute Sender ;
  DualLayout   : TDualLayout absolute Sender ;
  Flow         : TFlowLayout ;
begin
  Assert ( Sender is TLayout ) ;
  { Выберем компонент настроек }
  Selected := SelectDefaultSettings ( Layout ) ;
  Layout.Settings := Selected ;
  Settings := Layout.Settings ;
  { Общие настройки }
  if Assigned ( Layout.Parent ) and ( Layout.Parent is TLayout )
    then Layout.Background := Settings.IDESettings.ChildBackground
    else Layout.Background := Settings.IDESettings.RootBackground ;
  Layout.Gradient.Assign ( Settings.GradientSettings ) ;
  { BorderLayout }
  if Sender is TBorderLayout then
    if Settings.IDESettings.AddFlowLayout and
       CreateComponent ( Flow, BorderLayout.Owner, 'TFlowLayout', 'FlowLayout', eaDefault ) then
    begin
      Flow.Settings  := Selected ;
      Flow.Direction := fdHorizLeft ;
      Flow.Height    := 25 ;
      BorderLayout.BottomControl := Flow ;
    end ;
  { DualLayout }
  if Sender is TDualLayout then
    if Settings.IDESettings.AddFlowLayout and
       CreateComponent ( Flow, DualLayout.Owner, 'TFlowLayout', 'FlowLayout', eaDefault ) then
    begin
      Flow.Settings   := Selected ;
      Flow.AutoWidth  := 25 ;
      Flow.Direction  := fdVertCenter ;
      Flow.AutoHeight := 25 ;
      Flow.Width      := 25 ;
      DualLayout.CenterControl := Flow ;
    end ;
  { SplitterLayout }
  if Sender is TSplitterLayout then
    if Layout.Settings.IDESettings.FlipSplitter and Assigned ( Layout.Parent )
       and ( Layout.Parent is TSplitterLayout ) then
      TSplitterLayout ( Layout ).FlipDirection ;
end ;

{ Оповещении о считывании настроек из dfm }
procedure TLayoutDsgn.LayoutSettingsLoaded ( Sender : TObject ) ;
var Settings : TLayoutSettings absolute Sender ;
begin
  Assert ( Sender <> nil ) ;
  Assert ( Sender is TLayoutSettings ) ;
  SaveLayoutSettings ( Settings ) ;
end ;

{ Оповещение о сохранении настроек в dfm }
procedure TLayoutDsgn.LayoutSettingsSaved ( Sender : TObject ) ;
var Settings : TLayoutSettings absolute Sender ;
begin
  Assert ( Sender <> nil ) ;
  Assert ( Sender is TLayoutSettings ) ;
  SaveLayoutSettings ( Settings ) ;
end ;

{ Оповещение о конвертации свойств старого формата }
procedure TLayoutDsgn.ConvertProperty ( Sender : TObject ) ;
var
  Notifier : TSTSNotifier absolute Sender ;
  Data     : TObject ;
  Settings : TLayoutSettings ;
  Msg      : string ;
begin
  Assert ( Sender <> nil ) ;
  Assert ( Sender is TSTSNotifier ) ;
  Data := Notifier.Data ;
  Assert ( Data <> nil ) ;
  if Data is TLayoutSettings
    then Settings := TLayoutSettings ( Data )
  else if Data is TLayout
    then Settings := TLayout ( Data ).Settings
  else
    exit ;
  if not Settings.IDESettings.MsgConvertProperties then exit ;
  Msg := Format ( SConvertProperties,
                  [ FormatComponentName ( TComponent ( Data )), Notifier.DataString ]) ;
  MessageDlg ( Msg, mtInformation, [ mbOk ], 0 ) ;
end ;

{ Оповещение о дублировании GUID-ов }
procedure TLayoutDsgn.SettingsGuidDuplicates ( Sender : TObject ) ;
begin
  MessageDlg ( SGuidDuplicates, mtInformation, [ mbOk ], 0 ) ;
end ;

{ Оповещение о необходимости снабдить компонент меткой }
procedure TLayoutDsgn.LabelRequiredProc ( Sender : TCustomInputLayout ;
                                          Control : TControl ) ;
var
  NewLabel : TControl ;
  LabelClass, PropName : string ;
begin
  if not ( Control is TWinControl ) then exit ;
  LabelClass := Sender.Settings.ComponentSettings.DefaultLabel ;
  if not CreateComponent ( NewLabel, Sender.Owner, LabelClass, '', eaDefault ) then exit ;
  PropName := Sender.Settings.ComponentSettings.LabelsInfo.GetFocusControl ( LabelClass ) ;
  if PropName <> '' then SetObjectProp ( NewLabel, PropName, Control ) ;
  NewLabel.Parent := Sender ;
  Sender.RequestLayout ;
end ;

{ Реакция на оповещение компонента о себе }
procedure TLayoutDsgn.LayoutSettingsNotification ( Sender : TObject ) ;
var
  Data : TObject ;
  Settings : TLayoutSettings absolute Data ;
begin
  Assert ( Sender <> nil ) ;
  Assert ( Sender is TSTSNotifier ) ;
  Data := TSTSNotifier ( Sender ).Data ;
  Assert ( Data <> nil ) ;
  Assert ( Data is TLayoutSettings ) ;
  if LookForDefault and Settings.Default then
    DefaultSettingsList.AddObject ( FormatComponentName ( Settings ), Settings ) ;
end ;

{ Создание теневого компонента }
procedure TLayoutDsgn.MakeShadowSettings ( Sender : TObject ) ;
begin
  Assert ( Sender <> nil ) ;
  Assert ( Sender is TSTSNotifier ) ;
  LoadLayoutSettings ( TSTSNotifier ( Sender ).DataString ) ;
end ;

{ Перечисление компонент настроек по умолчанию }
procedure TLayoutDsgn.ListDefaultSettings ;
begin
  Assert ( DefaultSettingsList <> nil ) ;
  Assert ( FindDefaultNotifier <> nil ) ;
  { Найдем компоненты по умолчанию }
  DefaultSettingsList.Clear ;
  try
    LookForDefault := true ;
    LayoutSettings.FindDefaultNotifier.Fire ;
  finally
    LookForDefault := false ;
  end ;
end ;

{ Выбор используемых настроек по умолчанию }
function TLayoutDsgn.SelectDefaultSettings ( Layout : TLayout ) : TLayoutSettings ;
begin
  Assert ( Layout <> nil ) ;
  Result := nil ;
  ListDefaultSettings ;
  { Если их ноль, ругнемся и нехай использует дефолт }
  if DefaultSettingsList.Count = 0 then
  begin
    MessageDlg ( SNoDefaultSettings, mtInformation, [ mbOk ], 0 ) ;
    exit ;
  end ;
  { Если их один, его и вернем }
  if DefaultSettingsList.Count = 1 then
  begin
    Result := DefaultSettingsList.Objects [ 0 ] as TLayoutSettings ;
    if Result.IDESettings.MsgDefaultSelected then
      MessageDlg ( Format ( SDefaultSelected, [ FormatComponentName ( Result )]),
                   mtInformation, [ mbOk ], 0 ) ;
    exit ;
  end ;
  { Если их несколько, предложим выбор между ними }
  TFormLayoutSettingsSelect.Process ( DefaultSettingsList, Result ) ;
end ;

{ Сохранение настроек в реестр }
procedure TLayoutDsgn.SaveLayoutSettings ( Settings : TLayoutSettings ) ;
var
  Stream : TMemoryStream ;
  Reg    : TRegistry ;
  SavedName : string ;
begin
  Assert ( Settings <> nil ) ;
  if not Settings.IDESettings.RegistrySettings then exit ;
  Stream := TMemoryStream.Create ;
  Reg := TRegistry.Create ;
  try try
    try
      SavedName := Settings.Name ;
      Settings.Name := '' ;
      Stream.WriteComponent ( Settings ) ;
    finally
      Settings.Name := SavedName ;
    end ;
    Reg.RootKey := HKEY_CURRENT_USER ;
    Reg.Access  := KEY_WRITE ;
    if not Reg.OpenKey ( SaveLayoutSettingsKey + '\' + Settings.Guid, true ) then Abort ;
    Reg.WriteString ( 'Name', FormatComponentName ( Settings )) ;
    Reg.WriteBinaryData ( 'Data', Stream.Memory^, Stream.Position ) ;
  except
    on E : Exception do
      MessageDlg ( Format ( SCantSaveLayout, [ Settings.Name, E.Message ]),
                   mtError, [ mbOk ], 0 ) ;
      end ;
  finally
    FreeAndNil ( Stream ) ;
    FreeAndNil ( Reg ) ;
  end ;
end ;

{ Считывание настроек из реестра }
procedure TLayoutDsgn.LoadLayoutSettings ( Guid : string ) ;
var
  NewSettings : TLayoutSettings ;
  Buf, Name : string ;
  Stream : TStringStream ;
  Reg : TRegistry ;
begin
  if IntoLoadLayoutSettings then exit ;
  if Guid = '' then exit ;
  Reg := TRegistry.Create ;
  Stream := nil ;
  try
    IntoLoadLayoutSettings := true ;
    Reg.RootKey := HKEY_CURRENT_USER ;
    Reg.Access  := KEY_READ ;
    if not Reg.OpenKey ( SaveLayoutSettingsKey + '\' + Guid, false ) then exit ;
    SetLength ( Buf, 10240 ) ;
    Name := Reg.ReadString ( 'Name' ) ;
    Reg.ReadBinaryData ( 'Data', Buf [ 1 ], Length ( Buf )) ;
    Stream := TStringStream.Create ( Buf ) ;
    NewSettings := TLayoutSettings.CreateShadow ;
    Stream.ReadComponent ( NewSettings ) ;
    NewSettings.ShadowName := Name ;
  finally
    FreeAndNil ( Stream ) ;
    FreeAndNil ( Reg ) ;
    IntoLoadLayoutSettings := false ;
  end ;
end ;

initialization
  DsgnObject := TLayoutDsgn.Create ;

finalization
  FreeAndNil ( DsgnObject ) ;

end.

