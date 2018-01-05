////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//              Singleton - базовый класс для реализации синглтонов           //
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

Все обновления этого и других модулей выкладываются на http://softwarer.ru

------------------------------------------------------------------------------ }

{ ----- Применение модуля ------------------------------------------------------

Класс TSingleton содержит базовую реализацию для объектов-синглтонов. Метод
NewInstance переопределен таким образом, что все вызовы конструкторов
соответствующего класса возвращают один и тот же объект, созданный при самом
первом вызове. Аналогично, метод FreeInstance переопределен так, что любые
вызовы деструкторов игнорируются - таким образом, любой внешний модуль может
работать с объектом абсолютно обычным образом. Любой объект TSingleton
существует начиная с первого вызова конструктора и вплоть до завершения работы
программного модуля (до выполнения секции finalization модуля Singleton).

Для упрощения создания и уничтожения объектов добавлены виртуальные методы
InitSingleton и DoneSingleton. Наследники могут доопределять эти методы для
инициализации и деинициализации синглтонов; класс вызывает их только при
действительном создании и уничтожении объектов.

Метод RegisterSupport позволяет указать, что создаваемый объект также должен
использоваться для реализации указанных классов синглтонов. Это дает возможность
заместить классом-наследником предка: ранее разработанные модули могут
продолжать использовать TParentSingleton.Create, но при этом будет возвращаться
(и использоваться) тот же самый экземпляр наследника, что и при вызове
TChildSingleton.Create. В этом случае первый вызов TChildSingleton.Create
должен быть выполнен ранее первого вызова TParentSingleton.Create. Виртуальный
метод Supports автоматически вызывается при создании объекта и предназначен
специально для размещения в нем вызовов RegisterSupports.

Класс TSingleton реализует базовые интерфейсные методы примерно аналогично
TInterfacedObject, но - в силу специфики синглтона - без поддержки счетчика
ссылок и освобождения объекта при уничтожении последней ссылки. Это позволяет
использовать при работе с синглтонами интерфейсы (что затруднительно при
стандартной реализации).

Созданный объект регистрируется как синглтон в методе AfterConstruction. Таким
образом, в случае, если при создании объекта произошло исключение, объект
остается незарегистрированным, и следующее обращение к конструктору приведет
к новой попытке создания объекта.

Операции модуля в общем случае не являются потоково-безопасными. Для реализации
потоково-безопасного приложения достаточно создать все синглтоны заранее, до
начала их использования; в этом случае операции параллельного чтения (поиска и
использования созданного объекта) будут вполне безопасными.

Кажется бессмыслицей, но класс содержит деструктор DestroySingleton,
предназначенный для "досрочного" уничтожения объекта. Причина этого в том, что
иногда объект таки надо прозрачно или явно уничтожать, например для того, чтобы
пересоздать его в другой реализации. Также это нужно для синглтонов, работающих
в дизайн-тайме (для корректной перекомпиляции и реинсталляции пакетов).

------------------------------------------------------------------------------ }

unit Singleton ;

interface

uses Classes, SysUtils, Contnrs ;

type

  { Класс исключений, возбуждаемых в модуле }
  ESingleton = class ( Exception ) ;

  TSingletonClass = class of TSingleton ;

  { Базовый класс синглтона }
  TSingleton = class ( TObject, IInterface )
  private
    KeyClass : TSingletonClass ;
    IsDestroying : boolean ;
  protected
    class function SupportsSelf : boolean ; virtual ;
    procedure Supports ; virtual ;
    procedure RegisterSupport ( Classes : array of TSingletonClass ) ;
    function IsDestroyingSingleton : boolean ;
  protected
    function QueryInterface ( const IID : TGUID ; out Obj ) : HResult ; stdcall ;
    function _AddRef : integer ; stdcall ;
    function _Release : integer ; stdcall ;
  protected
    procedure InitSingleton ; virtual ;
    procedure DoneSingleton ; virtual ;
  public
    class function NewInstance : TObject ; override ;
    procedure FreeInstance ; override ;
    procedure AfterConstruction ; override ;
  public
    class procedure DestroySingleton ;
    class procedure DestroyAllSingletons ;
  end ;

resourcestring
  SDoesNotSupportSelf = 'Класс %s является абстрактным, но замещающего его ' +
                        'потомка не зарегистрировано' ;
  SDuplicate = 'Регистрация класса <%s> невозможна; пересечение по ' +
               'функциональности с классом <%s>' ;

implementation

uses RecordList ;

type
  { Список созданных singleton-ов }
  TSingletonList = class ( TRecordList )
  protected
    function GetSingleton ( ArrIndex, Index : integer ) : TSingleton ;
    procedure SetSingleton ( ArrIndex, Index : integer ;
                             NewSingleton : TSingleton ) ;
    function GetSingletonClass ( ArrIndex, Index : integer ) : TSingletonClass ;
    procedure SetSortSingletonClass ( ArrIndex, Index : integer ;
                                      NewSingletonClass : TSingletonClass ) ;
  public
    constructor Create ; override ;
    function IndexOfKey ( Key : TSingletonClass ) : integer ;
  public
    property Key [ ArrIndex : integer ] : TSingletonClass index 0
             read GetSingletonClass write SetSortSingletonClass ;
    property Server [ ArrIndex : integer ] : TSingleton index 1
             read GetSingleton write SetSingleton ;
    property ServerName [ ArrIndex : integer ] : AnsiString index 2
             read GetStr write SetStr ;
    property Primary [ ArrIndex : integer ] : boolean index 3
             read GetBool write SetBool ;
  end ;

constructor TSingletonList.Create ;
begin
  inherited ;
  RecordLength := 4 ;
  SetSortOrder ( 0, ftPointer ) ;
end ;

function TSingletonList.IndexOfKey ( Key : TSingletonClass ) : integer ;
begin
  Result := SortIndexOf ( pointer ( Key )) ;
end ;

function TSingletonList.GetSingleton ( ArrIndex, Index : integer ) : TSingleton ;
begin
  Result := TSingleton ( GetObj ( ArrIndex, Index )) ;
end ;

procedure TSingletonList.SetSingleton ( ArrIndex, Index : integer ;
                                        NewSingleton : TSingleton ) ;
begin
  SetObj ( ArrIndex, Index, NewSingleton ) ;
end ;

function TSingletonList.GetSingletonClass ( ArrIndex, Index : integer ) : TSingletonClass ;
begin
  Result := TSingletonClass ( GetClass ( ArrIndex, Index )) ;
end ;

procedure TSingletonList.SetSortSingletonClass ( ArrIndex, Index : integer ;
                                                 NewSingletonClass : TSingletonClass ) ;
begin
  SetSortClass ( ArrIndex, Index, NewSingletonClass ) ;
end ;

var
  Singletons : TSingletonList ;
  SingletonDestroying : boolean = false ;

{ Создание нового объекта либо возврат ранее созданного }
class function TSingleton.NewInstance : TObject ;
var KeyIndex : integer ;
begin
  Assert ( Singletons <> nil ) ;
  KeyIndex := Singletons.IndexOfKey ( Self ) ;
  if KeyIndex >= 0 then
    Result := Singletons.Server [ KeyIndex ]
  else
    begin
      if not SupportsSelf then
        raise ESingleton.CreateFmt ( SDoesNotSupportSelf, [ Self.ClassName ]) ;
      Result := inherited NewInstance ;
      TSingleton ( Result ).KeyClass := Self ;
      TSingleton ( Result ).InitSingleton ;
    end ;
end ;

{ Игнорирование деструкторов вплоть до завершения работы модуля }
procedure TSingleton.FreeInstance ;
begin
  if not IsDestroyingSingleton then exit ;
  DoneSingleton ;
  inherited FreeInstance ;
end ;

{ Метод, заменяющий конструктор }
procedure TSingleton.InitSingleton ;
begin
end ;

{ Метод, заменяющий деструктор }
procedure TSingleton.DoneSingleton ;
begin
end ;

{ Отработка после успешного создания объекта }
procedure TSingleton.AfterConstruction ;
var KeyIndex : integer ;
begin
  Assert ( Singletons <> nil ) ;
  { Если уже зарегистрированы - повторный вызов, делать нечего }
  KeyIndex := Singletons.IndexOfKey ( KeyClass ) ;
  if KeyIndex >= 0 then exit ;
  { Дадим поработать родителю }
  inherited ;
  { При невыполнении должны были отпасть по KeyIndex >= 0 }
  Assert ( KeyClass = Self.ClassType ) ;
  Assert ( SupportsSelf ) ;
  { Зарегистрируем поддержку себя и других }
  RegisterSupport ([ KeyClass ]) ;
  Supports ;
  KeyIndex := Singletons.IndexOfKey ( KeyClass ) ;
  Assert ( KeyIndex >= 0 ) ;
  Singletons.Primary [ KeyIndex ] := true ;
end ;

{ Явное уничтожение синглтона }
class procedure TSingleton.DestroySingleton ;
var
  i : integer ;
  S : TSingleton ;
begin
  if Singletons = nil then exit ; { Если список пуст, уничтожать нечего }
  i := Singletons.IndexOfKey ( Self ) ;
  if i < 0 then exit ;
  if not Singletons.Primary [ i ] then
    Singletons.Delete ( i )
  else
    begin
      S := Singletons.Server [ i ] ;
      for i := Singletons.Count - 1 downto 0 do
        if Singletons.Server [ i ] = S then Singletons.Delete ( i ) ;
      S.IsDestroying := true ;
      FreeAndNil ( S ) ;
    end ;
end ;

{ Явное уничтожение всех синглтонов }
class procedure TSingleton.DestroyAllSingletons ;
var
  i : integer ;
  Primaries : TObjectList ;
begin
  if not Assigned ( Singletons ) then exit ;
  Primaries := TObjectList.Create ( false ) ;
  for i := Singletons.Count - 1 downto 0 do
    if Singletons.Primary [ i ] then
    begin
      Assert ( Primaries.IndexOf ( Singletons.Server [ i ]) < 0 ) ;
      Primaries.Add ( Singletons.Server [ i ]) ;
    end ;
  FreeAndNil ( Singletons ) ;
  FreeAndNil ( Primaries  ) ;
end ;

{ Метод, позволяющий отключить поддержку классом себя - для абстрактных предков }
class function TSingleton.SupportsSelf : boolean ;
begin
  Result := true ;
end;

{ Регистрация реализуемых объектов }
procedure TSingleton.Supports ;
begin
end ;

{ Регистрация объекта как реализующего синглтоны указанных классов }
procedure TSingleton.RegisterSupport ( Classes : array of TSingletonClass ) ;
var
  i, KeyIndex : integer ;
  ServerName  : string ;
begin
  for i := Low ( Classes ) to High ( Classes ) do
  begin
    KeyIndex := Singletons.IndexOfKey ( Classes [ i ]) ;
    if KeyIndex < 0 then
      Singletons.AddRecord ([ integer ( Classes [ i ]), integer ( Self ), Self.ClassName ])
    else if ( KeyIndex >= 0 ) and ( Singletons.Server [ KeyIndex ] <> Self ) then
      begin
        ServerName := Singletons.ServerName [ KeyIndex ] ;
        raise ESingleton.CreateFmt ( SDuplicate, [ ClassName, ServerName ]) ;
      end;
  end ;
end ;

{ Статусные функции }

function TSingleton.IsDestroyingSingleton : boolean ;
var i : integer ;
begin
  Result := true ;
  { Уничтожаем объект либо в случае явного завершения }
  if SingletonDestroying or IsDestroying then exit ;
  { Либо в случае ошибки при создании (до регистрации в Singletons )}
  for i := Singletons.Count - 1 downto 0 do
    if Singletons.Server [ i ] = Self then Result := false ;
end ;

{ Поддержка интерфейсов }

function TSingleton.QueryInterface ( const IID : TGUID ; out Obj ) : HResult ;
begin
  if GetInterface ( IID, Obj )
    then Result := 0
    else Result := E_NOINTERFACE ;
end ;

function TSingleton._AddRef : integer ;
begin
  Result := -1 ;
end ;

function TSingleton._Release : integer ;
begin
  Result := -1 ;
end ;

initialization
  Singletons := TSingletonList.Create ;

finalization
  SingletonDestroying := true ;
  TSingleton.DestroyAllSingletons ;

end.
