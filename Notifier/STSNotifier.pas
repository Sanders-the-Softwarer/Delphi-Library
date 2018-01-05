////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                           Sanders the Softwarer                            //
//                                                                            //
//    TSTSNotifier - компонент для создания и поддержки списков оповещений    //
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

Автор: Sanders Prostorov, 2:5020/1583, softwarer@mail.ru, softwarer@nm.ru

------------------------------------------------------------------------------ }

{ ----- Описание ---------------------------------------------------------------

Компонент STSNotifier соотносится с некоторым общесистемным  событием, например,
регистрацией пользователя, и в момент исполнения этого события  выполняет  заре-
гистрированные для этого случая обработчики событий. Для  одного и того же собы-
тия может быть зарегистрировано сколько угодно обработчиков; каждая форма, фрейм
и т. п. может привязать к событию собственный обработчик  с  помощью  компонента
TSTSNotiferLink. Такая технология позволяет писать распределенную логику реакции
на ключевые  события  системы - например, каждое  окно  может  в  соответствии с
правами нового пользователя перестроить свои элементы, причем  для  этого не по-
требуется какого-либо центрального  модуля, который нужно будет  дописывать  для
каждого нового класса окон. Аналогично, если  некоторое событие может быть заре-
гистрировано в нескольких модулях, этим модулям совершенно не обязательно  знать
ни друг о друге, ни об обработчиках этого события.

Рекомендуемой технологией является создание отдельного DataModule, в котором бу-
дут размещены компоненты TSTSNotifier. Этот модуль не будет использовать никаких
других модулей, исключая стандартные, и потому может совершенно свободно исполь-
зоваться любыми модулями системы или даже независимо в нескольких  системах; при
этом использующие его модули ровным счетом ничего не должны  знать  друг о друге
и, соответственно, могут  быть изменены без необходимости в изменении других мо-
дулей. Следствием такого подхода является заметное упрощение создание интерфейса
со многими немодальными окнами, в  том числе представляющими несколько экземпля-
ров одного и того же класса.

------------------------------------------------------------------------------ }

{ ----- Использование компонента -----------------------------------------------

В дизайн-тайме достаточно бросить в модуль данных  компонент  TSTSNotifier. Поле
Description - по сути, это комментарий к компоненту - может быть  заполнено  для
сохранения информации, к какому именно событию соотнесен компонент. Для обработ-
ки события в каждой форме, в которой будет обрабатываться  событие, следует  ис-
пользовать компонент TSTSNotifierLink, привязать его к компоненту TSTSNotifier и
заполнить обработчик события OnNotification. В ран-тайме возможна  также  прямая
регистрация обработчиков с помощью метода RegisterNotification и удаление  ранее
зарегистрированного обработчика методом RemoveNotification.

Модуль, в котором зарегистрировано событие, должен инициировать оповещение с по-
мощью метода Fire. При оповещении могут быть  переданы  дополнительные  данные о
произошедшем событии. Для этого в компонент введено свойство Data типа  TObject,
заполняемое объектом, переданным при вызове метода Fire. При установленном свой-
стве AutoFreeData переданный объект уничтожается в конце выполнения метода Free;
в противном случае свойство Data получает значение nil, но об уничтожении объек-
та должен позаботиться инициатор оповещения. Получатели оповещения имеют возмож-
ность изменять объект Data; при этом следует учитывать, что порядок вызова заре-
гистрированных обработчиков не определен и может оказаться любым.

Исключения, возникающие в модуле при обработке оповещения, не  должны  влиять на
оповещение  других  модулей.  Поэтому  исключения, выпадающие  из   обработчиков
OnNotification, передаются в обработчик события OnException, а  при  его  отсут-
ствии - в Application.HandleException, после чего продолжается оповещение других
модулей.

------------------------------------------------------------------------------ }

{ ----- История изменений ------------------------------------------------------

26.09.2001 Компоненты созданы по мотивам компонента TNotifyList, созданного для
           проекта CTR View в компании AlSoft. В первой версии TSTSNotifier
           реализованы свойства Description, методы RegisterNotification,
           RemoveNotification, Fire. В компоненте TSTSNotifierLink реализованы
           свойства Notifier и OnNotification, метод Fire.
19.07.2004 Добавлено событие OnException. Подчищена пара неточностей.
19.11.2004 Добавлено свойство Data и соответствующий аргумент метода Fire,
           свойство AutoFreeData. При вызове метода STSNotifierLink.Fire при
           неприсвоенном свойстве Notifier генерится исключение (раньше вызов
           молча игнорировался).
02.12.2006 Добавлено свойство DataString и метод Fire (string)

------------------------------------------------------------------------------ }

unit STSNotifier ;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, RecordList ;

type

  ESTSNotifier = class ( Exception ) ;
  TExceptionEvent = procedure ( Sender : TObject ; E : Exception ;
                                out ReRaise : boolean ) of object ;

  TNotifications = class ( TRecordList )
  public
    constructor Create ; override ;
  public
    property Event [ ArrIndex : integer ] : TNotifyEvent index 0
             read GetNotifyEvent write SetNotifyEvent ;
    property Sender [ ArrIndex : integer ] : TObject index 1
             read GetObj write SetObj ;
  end ;

  { Основной компонент - список оповещений }
  TSTSNotifier = class ( TComponent )
  private
    FDescription  : TStrings ;
    Notifications : TNotifications ;
    FOnException  : TExceptionEvent ;
    FAutoFreeData : boolean ;
    FData         : TObject ;
    FDataString   : string ;
  protected
    { Вызов обработчиков событий }
    procedure DoException ( E : Exception ; out ReRaise : boolean ) ; dynamic ;
    { Методы свойств }
    function GetDescription : TStrings ;
    procedure SetDescription ( NewStrings : TStrings ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
    procedure Notification ( AComponent : TComponent ;
                             AOperation : TOperation ) ; override ;
    { Основные методы }
    procedure RegisterNotification ( ANotification : TNotifyEvent ) ;
    procedure RemoveNotification ( ANotification : TNotifyEvent ) ;
    procedure Fire ( AData : TObject = nil ) ; overload ;
    procedure Fire ( AData : string ) ; overload ;
    procedure Fire ( AData : TObject ; ADataString : string ) ; overload ;
  public
    property Data : TObject read FData write FData ;
    property DataString : string read FDataString write FDataString ;
  published
    property AutoFreeData : boolean read FAutoFreeData write FAutoFreeData ;
    property Description : TStrings read GetDescription write SetDescription ;
    property OnException : TExceptionEvent read FOnException write FOnException ;
  end ;

  { Дополнительный компонент - интерфейс к списку оповещений }
  TSTSNotifierLink = class ( TComponent )
  private
    FNotifier     : TSTSNotifier ;
    FNotification : TNotifyEvent ;
  protected
    procedure NotificationHandler ( Sender : TObject ) ;
    procedure DoNotification ( Sender : TObject ) ; virtual ;
    { Методы свойств }
    procedure SetNotifier ( NewNotifier : TSTSNotifier ) ;
  public
    destructor Destroy ; override ;
    procedure Notification ( AComponent : TComponent ;
                             Operation  : TOperation ) ; override ;
    { Основные методы }
    procedure Fire ( AData : TObject = nil ) ; overload ;
    procedure Fire ( AData : string ) ; overload ;
    procedure Fire ( AData : TObject ; ADataString : string ) ; overload ;
  published
    property Notifier : TSTSNotifier read FNotifier write SetNotifier ;
    property OnNotification : TNotifyEvent read FNotification
                                           write FNotification ;
  end ;

procedure Register;

implementation

uses CmpUtils ;

resourcestring
  SNotifierRequired = 'Операция не может быть выполнена без привязки ' +
                      'к компоненту TSTSNotifier' ;

procedure Register;
begin
  RegisterComponents ('Sanders the Softwarer', [TSTSNotifier, TSTSNotifierLink]);
end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                                TSTSNotifier                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

constructor TSTSNotifier.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  FDescription  := TStringList.Create ;
  Notifications := TNotifications.Create ;
end ;

destructor TSTSNotifier.Destroy ;
begin
  inherited ;
  FreeAndNil ( FDescription ) ;
  FreeAndNil ( Notifications ) ;
end ;

procedure TSTSNotifier.Notification ( AComponent : TComponent ;
                                      AOperation : TOperation ) ;
var
  i : integer ;
  E : TNotifyEvent ;
  M : TMethod absolute E ;
begin
  inherited ;
  if AOperation <> opRemove then exit ;
  with Notifications do
    for i := Count - 1 downto 0 do
      if Sender [ i ] = AComponent then Delete ( i ) ;
end;

{ Основные методы }

procedure TSTSNotifier.RegisterNotification ( ANotification : TNotifyEvent ) ;
var
  M : TMethod absolute ANotification ;
  E : TNotifyEvent ;
  i : integer ;
begin
  if csDestroying in ComponentState then exit ;
  for i := 0 to Notifications.Count - 1 do
  begin
    E := Notifications.Event [ i ] ;
    if EqualHandlers ( ANotification, E ) then exit ;
  end ;
  i := Notifications.Add ;
  Notifications.Event  [ i ] := ANotification ;
  Notifications.Sender [ i ] := TObject ( M.Data ) ;
  if TObject ( M.Data ) is TComponent then
    TComponent ( M.Data ).FreeNotification ( Self ) ;
end ;

procedure TSTSNotifier.RemoveNotification ( ANotification : TNotifyEvent ) ;
var
  i : integer ;
  E : TNotifyEvent ;
begin
  if csDestroying in ComponentState then exit ;
  for i := Notifications.Count - 1 downto 0 do
  begin
    E := Notifications.Event [ i ] ;
    if EqualHandlers ( ANotification, E ) then Notifications.Delete ( i ) ;
  end ;
end ;

procedure TSTSNotifier.Fire ( AData : TObject = nil ) ;
var
  Notification : TNotifyEvent ;
  ReRaise      : boolean      ;
  i            : integer      ;
begin
  if csDestroying in ComponentState then exit ;
  try
    FData := AData ;
    for i := Notifications.Count - 1 downto 0 do
    begin
      if i >= Notifications.Count then continue ;
      Notification := Notifications.Event [ i ] ;
      if Assigned ( Notification ) then
        try
          Notification ( Self ) ;
        except
          on E : EAccessViolation do
            begin
              Notifications.Delete ( i ) ;
              raise ;
            end ;
          on E : Exception do
            begin
              DoException ( E, ReRaise ) ;
              if ReRaise then raise ;
            end ;
        end ;
    end ;
  finally
    FDataString := '' ;
    if AutoFreeData then FData.Free ;
    FData := nil ;
  end ;
end ;

procedure TSTSNotifier.Fire ( AData : string ) ;
begin
  FDataString := AData ;
  Fire ;
end ;

procedure TSTSNotifier.Fire ( AData : TObject ; ADataString : string ) ;
begin
  FDataString := ADataString ;
  Fire ( AData ) ;
end ;

{ Вызов обработчиков событий }

procedure TSTSNotifier.DoException ( E : Exception ; out ReRaise : boolean ) ;
begin
  ReRaise := false ;
  if Assigned ( FOnException )
    then FOnException ( Self, E, ReRaise )
    else Application.ShowException ( E ) ;
end ;

{ Методы свойств }

function TSTSNotifier.GetDescription : TStrings ;
begin
  GetDescription := FDescription ;
end ;

procedure TSTSNotifier.SetDescription ( NewStrings : TStrings ) ;
begin
  FDescription.Assign ( NewStrings ) ;
end ;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                              TSTSNotifierLink                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

destructor TSTSNotifierLink.Destroy ;
begin
  Notifier := nil ;
  inherited ;
end ;

procedure TSTSNotifierLink.Notification ( AComponent : TComponent ;
                                          Operation  : TOperation ) ;
begin
  if ( AComponent = Notifier ) and ( Operation = opRemove )
    then Notifier := nil ;
  inherited ;
end ;

{ Основные методы }

procedure TSTSNotifierLink.Fire ( AData : TObject = nil ) ;
begin
  if Assigned ( Notifier )
    then Notifier.Fire ( AData )
    else raise ESTSNotifier.Create ( SNotifierRequired ) ;
end ;

procedure TSTSNotifierLink.Fire ( AData : string ) ;
begin
  if Assigned ( Notifier )
    then Notifier.Fire ( AData )
    else raise ESTSNotifier.Create ( SNotifierRequired ) ;
end ;

procedure TSTSNotifierLink.Fire ( AData : TObject ; ADataString : string ) ;
begin
  if Assigned ( Notifier )
    then Notifier.Fire ( AData, ADataString )
    else raise ESTSNotifier.Create ( SNotifierRequired ) ;
end ;

{ Внутренние методы }

procedure TSTSNotifierLink.NotificationHandler ( Sender : TObject ) ;
begin
  if not ( csDestroying in ComponentState ) then DoNotification ( Sender ) ;
end ;

procedure TSTSNotifierLink.DoNotification ( Sender : TObject ) ;
begin
  if Assigned ( FNotification ) then FNotification ( Sender ) ;
end ;

{ Методы свойств }

procedure TSTSNotifierLink.SetNotifier ( NewNotifier : TSTSNotifier ) ;
begin
  if NewNotifier = Notifier then exit ;
  if Assigned ( Notifier ) then
  begin
    Notifier.RemoveNotification ( NotificationHandler ) ;
    Notifier.RemoveFreeNotification ( Self ) ;
  end ;
  FNotifier := NewNotifier ;
  if Assigned ( Notifier ) then
  begin
    Notifier.RegisterNotification ( NotificationHandler ) ;
    Notifier.FreeNotification ( Self ) ;
  end ;
end ;

{ TNotifications }

constructor TNotifications.Create ;
begin
  inherited ;
  RecordLength := 2 ;
end ;

end.
