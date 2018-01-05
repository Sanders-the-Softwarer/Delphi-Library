////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         Расширенная поддержка оповещений об освобождении компонент         //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- Официоз ----------------------------------------------------------------

Любой желающий может распространять этот модуль, дорабатывать его, использовать
в собственных программных проектах, в том числе коммерческих, без необходимости
в дополнительных разрешениях от автора. В любой версии модуля должна сохраняться
информация об авторских правах и условиях распространения модуля.

При распространении доработанных версий модуля прошу изменить имя модуля и
базового класса для предотвращения коллизий между доработками различных авторов.

Если Вы сделали интересную доработку и согласны распространять ее на этих
условиях - сообщите о ней, и мы обговорим включение Вашей доработки в авторскую
версию модуля. Также прошу сообщать о найденных ошибках, если такие будут.

Автор: Sanders Prostorov (softwarer@mail.ru, softwarer@nm.ru)

Все обновления этого и других модулей выкладываются на http://softwarer.ru
Для сообщений об ошибках и предложений по доработкам: http://bugs.softwarer.ru

------------------------------------------------------------------------------ }

unit FreeNotifier;

{ ----- Применение модуля ------------------------------------------------------

С помощью метода AddListener в менеджере регистрируется интерес подписчика
получить оповещение об уничтожении указанного компонента. Когда такое событие
случится, подписчик получит известие об этом методом вызова указанного
обработчика события. Основное предназначение модуля - поддержка этого
функционала для оповещения объектов, не являющихся компонентами (и потому
не способными непосредственно использовать механизм FreeNotification). 

Подписчик может отказаться от оповещения с помощью метода RemoveListener и
как минимум должен сделать это перед собственным уничтожением, если не является
компонентом - в противном случае обработчик события будет вызван для уже
уничтоженного объекта с вытекающими отсюда последствиями. При уничтожении
компонент менеджер самостоятельно убирает ссылки на них из хранящихся данных.
Для облегчения отписки добавлен метод RemoveAllListeners, который позволяет
объекту одним движением отписаться от всех оповещений, которые он
зарегистрировал.

Доступ к менеджеру удобно организовывать с помощью функций FreeNotifier,
размещенных в модулях CmpUtils и FreeUtils; непосредственно включать модуль
в каждое место использования не требуется.

------------------------------------------------------------------------------ }

{ ----- История модуля ---------------------------------------------------------

01.05.2008 Первая версия модуля

------------------------------------------------------------------------------ }

interface

uses Classes, Singleton;

type
  { Оповещение об уничтожении компонента }
  TFreeListener = procedure (AComponent: TComponent) of object;

  { Менеджер оповещений об уничтожении }
  TFreeNotifier = class (TSingleton)
  public
    procedure AddListener (Listener: TFreeListener;
                           Component: TComponent); overload; virtual; abstract;
    procedure AddListener (Listener: TFreeListener;
                           Components: array of TComponent); overload;
    procedure RemoveListener (Listener: TFreeListener;
                              Component: TComponent); overload; virtual; abstract;
    procedure RemoveListener (Listener: TFreeListener;
                              Components: array of TComponent); overload;
    procedure RemoveAllListeners (AOwner: TObject); virtual; abstract;
  end;

implementation

uses SysUtils, RecordList, CmpUtils;

{ FreeNotifier }

type

  { Информация о зарегистрированных обработчиках }
  TFreeNotifierData = class (TRecordList)
  protected
    function GetListener (ArrIndex, Index: integer): TFreeListener;
    procedure SetListener (ArrIndex, Index: integer; NewListener: TFreeListener);
  public
    constructor Create; override;
  public
    property WaitFor [ArrIndex: integer]: TComponent index 0
             read GetComponent write SetSortComponent;
    property Handler [ArrIndex: integer]: TFreeListener index 1
             read GetListener write SetListener;
    property Qnt [ArrIndex: integer]: integer index 2
             read GetInt write SetInt;
  end;

  { Компонент, слушающий free notifications }
  TSignaller = class (TComponent)
  protected
    function Data: TFreeNotifierData;
  public
    procedure Notification (AComponent: TComponent;
                            AOperation: TOperation); override;
  end;

  { Собственно реализация FreeNotifier-а }
  TFreeNotifierImpl = class (TFreeNotifier)
  private
    Data: TFreeNotifierData;
    Signaller: TSignaller;
    procedure FreeListenerOwnerHandler (AOwner: TComponent);
  public
    procedure InitSingleton; override;
    procedure DoneSingleton; override;
  public
    procedure AddListener (Listener: TFreeListener;
                           Component: TComponent); override;
    procedure RemoveListener (Listener: TFreeListener;
                              Component: TComponent); override;
    procedure RemoveAllListeners (AOwner: TObject); override;
  end;

constructor TFreeNotifierData.Create;
begin
  inherited;
  RecordLength := 3;
  SetSortOrder (0, ftComponent);
end;

{ Методы доступа для свойства типа TFreeListener }

function TFreeNotifierData.GetListener (ArrIndex, Index: integer): TFreeListener;
begin
  Result := TFreeListener (GetNotifyEvent (ArrIndex, Index));
end;

procedure TFreeNotifierData.SetListener (ArrIndex, Index: integer; NewListener: TFreeListener);
begin
  SetNotifyEvent (ArrIndex, Index, TNotifyEvent (NewListener));
end;

{ TFreeNotifier }

procedure TFreeNotifier.AddListener (Listener: TFreeListener;
                                     Components: array of TComponent);
var i: integer;
begin
  for i := Low (Components) to High (Components) do
    AddListener (Listener, Components [i]);
end;

procedure TFreeNotifier.RemoveListener (Listener: TFreeListener;
                                        Components: array of TComponent);
var i: integer;
begin
  for i := Low (Components) to High (Components) do
    RemoveListener (Listener, Components [i]);
end;

{ Реализация TFreeNotifier }

procedure TFreeNotifierImpl.InitSingleton;
begin
  inherited;
  Data := TFreeNotifierData.Create;
  Signaller := TSignaller.Create (nil);
end;

procedure TFreeNotifierImpl.DoneSingleton;
begin
  inherited;
  FreeAndNil (Signaller);
  FreeAndNil (Data);
end;

{ Регистрация заинтересованности в оповещении }
procedure TFreeNotifierImpl.AddListener (Listener: TFreeListener;
                                         Component: TComponent);
var
  i, L, H: integer;
  Handler: TFreeListener;
  ListenerOwner: TObject;
begin
  if not Assigned (Component) or not Assigned (Listener) then exit;
  Assert (Data <> nil);
  { Если обработчик уже есть, увеличим счетчик }
  Data.SortIndexRange (Component, L, H);
  for i := L to H do
  begin
    Handler := Data.Handler [i];
    if EqualHandlers (Listener, Handler) then
    begin
      Data.Qnt [i] := Data.Qnt [i] + 1;
      exit;
    end;
  end;
  { Иначе вставим новую запись }
  Signaller.FreeNotification (Component);
  i := Data.InsertKey (Component);
  Data.Handler [i] := Listener;
  Data.Qnt [i] := 1;
  { Отработаем также возможное уничтожение компонента - владельца обработчика }
  ListenerOwner := HandlerOwner (Listener);
  if (ListenerOwner <> Self) and (ListenerOwner is TComponent) then
    AddListener (FreeListenerOwnerHandler, TComponent (ListenerOwner));
end;

{ Отмена заинтересованности в оповещении }
procedure TFreeNotifierImpl.RemoveListener (Listener: TFreeListener;
                                            Component: TComponent);
var
  i, L, H: integer;
  Handler: TFreeListener;
begin
  Assert (Data <> nil);
  { Найдем обработчики для указанного компонента }
  Data.SortIndexRange (Component, L, H);
  { Найдем совпадающие по обработчику событий }
  for i := H downto L do
  begin
    Handler := Data.Handler [i];
    if EqualHandlers (Listener, Handler) then
    begin
      { Ну и уменьшим счетчик либо удалим запись }
      if Data.Qnt [i] = 1
        then Data.Delete (i)
        else Data.Qnt [i] := Data.Qnt [i] - 1;
      exit;
    end;
  end;
end;

{ Удаление всех записей с указанным владельцем обработчиков }
procedure TFreeNotifierImpl.RemoveAllListeners (AOwner: TObject);
var
  i: integer;
  Handler: TFreeListener;
begin
  Assert (Data <> nil);
  for i := Data.Count - 1 downto 0 do
  begin
    Handler := Data.Handler [i];
    if HandlerOwnedBy (Handler, AOwner) then Data.Delete (i);
  end;
end;

{ Реакция на удаление владельца обработчика }
procedure TFreeNotifierImpl.FreeListenerOwnerHandler (AOwner: TComponent);
begin
  RemoveAllListeners (AOwner);
end;

{ Реакция на уничтожение компонент }
procedure TSignaller.Notification (AComponent: TComponent;
                                   AOperation: TOperation);
var
  i, L, H: integer;
  Handlers: array of TFreeListener;
begin
  inherited;
  if AOperation <> opRemove then exit;
  { Найдем обработчики }
  Assert (Data <> nil);
  Data.SortIndexRange (AComponent, L, H);
  if H < L then exit;
  { Сбросим их в промежуточный буфер, чтобы не возиться с изменением регистрации
    внутри обработчиков }
  SetLength (Handlers, H - L + 1);
  for i := L to H do
    Handlers [i - L] := Data.Handler [i];
  { Ну и наконец вызовем обработчики }
  for i := Low (Handlers) to High (Handlers) do
    if Assigned (Handlers [i]) then Handlers [i] (AComponent);
end;

function TSignaller.Data: TFreeNotifierData;
begin
  Result := TFreeNotifierImpl.Create.Data;
end;

initialization
  TFreeNotifierImpl.Create.RegisterSupport ([TFreeNotifier]);
end.
