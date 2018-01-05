////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                   Подпрограммы для работы с исключениями                   //
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

{ ----- Использование модуля ---------------------------------------------------

В модуле определяется класс исключений EStsException, способный нести большее
количество информации об ошибке и контексте ее возникновения. Кроме собственно
текста ошибки объект может быть снабжен произвольным количеством строк заголовка
и дополнительной информации; это позволяет строить подробные, удобные для
пользователя и администратора сообщения об ошибке. Так, например, следующий
фрагмент кода:

try
  Strings.LoadFromFile (CfgFileName);
  for i := 0 to Strings.Count - 1 do
  try
    Process (Strings.Names [i], Strings.ValueFromIndex [i]);
  except
    on E: Exception do
      raise AddExceptionFooter (E, 'Строка: %d', [i + 1]);
  end;
except
  on E: Exception do
    with EStsException.Clone (E) do
    begin
      AddHeader ('Ошибка при чтении конфигурационного файла');
      AddFooter ('Файл: %s', [CfgFileName]);
      RaiseSelf;
    end;
end;

позволит пользователю легко определить место ошибки и предпринять меры для
ее исправления.

Кроме формирования текста сообщения, класс EStsException позволяет добавлять
в объект исключения произвольное количество параметров - пар "имя-значение",
описывающих контекст возникновения ошибки. В них можно и нужно записать значения
ключевых переменных, текст выполняемых SQL запросов и прочую информацию, которую
не следует показывать пользователю, но следует записать в лог-файл, отобразить
по кнопке "дополнительная информация" и/или отослать разработчику.

В модуле определены три основных наследника класса EStsException. Класс
EExpectable предназначен для тех ошибочных ситуаций, появление которых можно и
нужно ожидать в нормально функционирующей программе. Сюда относятся ошибочные
действия пользователей, неверные конфигурационные параметры, проблемы связи
с другими компьютерами и т. п. В обработчике Application.OnException для таких
ошибок как правило следует просто показать текст сообщения об ошибке и
предоставить пользователю возможность ее исправлять. Наследуя свои подобные
классы от EStsException, Вы сможете написать простую и удобную систему реакции
на все подобные ошибки. Класс EApplication предназначен для ошибочных ситуаций,
означающих проблему в самой программе - в первую очередь, сюда относятся
срабатывания различного рода контрольных проверок. Наконец, класс ENative
реализован как оболочка для "обычных" исключений Дельфи; он позволяет
импортировать обычные исключения - index out of range, canvas does not allow
drawing и любые другие - в наследника EStsException и воспользоваться для них
всей мощью его функциональности.

Класс ExceptionMapper действует в связке с EStsException и позволяет определить,
как именно "обычные" исключения отображаются в потомков EStsException. По
умолчанию действует следующая карта:

    - EStsException и потомков оставляем без изменений
    ExceptionMapper.Register (EStsException, nil);

    - SysUtils.EOSError и EInOutError отображаем в наш EOSError
    ExceptionMapper.Register (SysUtils.EInOutError, ExUtils.EOSError);
    ExceptionMapper.Register (SysUtils.EOSError, ExUtils.EOSError);

    - Файловые ошибки естественны при работе любой программы
    ExceptionMapper.Register (EFileStreamError, EExpectable);

    - Все прочее отображаем в ENative
    ExceptionMapper.Register (Exception, ENative);

Класс InternalWarnings предназначен для регистрации "неприятных ситуаций" -
таких, что выбрасывать исключение и мешать работе основной логики нерационально,
но сообщить о проблеме нужно. Класс позволяет зарегистрировать обработчик таких
сообщений, который будет, например, записывать проблемы в лог-файл. Обычная
логика обработки таких случаев проста: в "отладочном" режиме сообщения
выводятся на монитор программисту; у пользователя они не выводятся в интерфейс,
но так или иначе доводятся до сведения разработчика.

------------------------------------------------------------------------------ }

{ ----- Замечания по реализации ------------------------------------------------

В большинстве подпрограмм модуля необходимо всячески избегать возбуждения
собственных исключительных ситуаций. Связано это с тем, что если при обработке
пользовательского исключения что-то пошло не так и мы выбросим вместо него
собственное, то в лучшем случае мы теряем/откладываем в сторону информацию
об оригинальном исключении; в худшем же обработка нашего исключения пойдет
через тот же код, снова свалится с ошибкой, и мы зациклимся. Таким образом,
следует не только не возбуждать собственных исключений, но и тщательно
продумывать возможность возникновения исключения в используемых объектах и
подпрограммах.

Сказанное относится в том числе и к директиве Assert, которая также возбуждает
исключения. По этой причине в модуле написана заглушка, забивающая стандартную
Assert, а пользоваться вместо нее следует функцией ExAssert.

По тем же соображениям следует избегать использования в ExUtils других
инструментов собственной библиотеки (хотя, например, сильно хочется добавить
RecordList). Причина этого в том, что те в свою очередь будут активно
использовать ExUtils, и образовавшиеся циклы в логике рано или поздно приведут
к неприятным последствиям; мелкая ошибка в модуле развалит систему обработки
ошибок и все приложение вместе с ней. Сейчас таким образом используется только
модуль CmpUtils и только потому, что вызываемая из него подпрограмма
EqualHandlers абсолютно надежна.

Класс EStsException сохраняет оригинальное сообщение в поле OrigMessage, а в
Message кладет полное - с добавлением всех заголовков-подвалов. Это сделано для
того, чтобы стандартный код работы с исключениями, не учитывающий особенностей
нашего класса, мог выводить на экран хорошее, подробное сообщение об ошибке.
Недостаток такой реализации в том, что код, меняющий свойство Message без учета
особенностей ExUtils, во многих случаях перестанет работать (его результаты
будут перезатерты). Однако, это представляется мне куда меньшим злом.

------------------------------------------------------------------------------ }

{ ----- История модуля ---------------------------------------------------------

??.??.2006 Несколько разрозненных подпрограмм собраны в модуль ExUtils. Период
           недокументированного развития.

30.04.2008 Модуль серьезно переработан и подготовлен к выкладыванию в свободный
           доступ.           

------------------------------------------------------------------------------ }

unit ExUtils;

interface

uses
  Classes, SysUtils;

type

  { Дополнительная информация, передающаяся вместе с исключением }

  TExceptionParamType = (eptEmpty, eptVariant, eptObject, eptClass);

  TExceptionParam = record
    Name: string;
    ParamType: TExceptionParamType;
    VarValue: variant;
    ObjValue: TObject;
    ClassValue: TClass;
  end;

  TExceptionParams = array of TExceptionParam;

  { Базовый класс поддерживаемых исключений }
  EStsExceptionClass = class of EStsException;
  EStsException = class (Exception)
  private
    Headers, Footers: TStrings;
    Params: TExceptionParams;
    OrigMessage: string;
  protected
    { Копирование информации извне к нам }
    procedure Assign (Source: Exception); dynamic;
    { Формирование полного текста сообщения об ошибке }
    function CompleteMessage: string;
    { Формирование текста сообщения об ошибке при отсутствии такового }
    function NoMessage: string;
    { Проверки существования используемых объектов }
    function CheckHeaders: boolean;
    function CheckFooters: boolean;
    { Рабочие методы }
    function AddParam (const Name: string): integer; overload;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    class function Clone (E: Exception): EStsException;
  public
    procedure RaiseSelf;
    { Добавление к сообщению строки заголовка }
    procedure AddHeader (Header: string); overload;
    procedure AddHeader (Header: string;
                         const Params: array of const); overload;
    { Добавление к сообщению нижнего титула }
    procedure AddFooter (Footer: string); overload;
    procedure AddFooter (Footer: string;
                         const Params: array of const); overload;
    { Добавление параметра дополнительной информации }
    procedure AddParam (const Name: string; const Value: variant); overload;
    procedure AddParam (const Name: string; const Value: TObject); overload;
    procedure AddParam (const Name: string; const Value: TClass); overload;
    { Возврат значений параметров }
    function ParamCount: integer;
    function Param (ParamNo: integer): TExceptionParam;
  end;

  { Менеджер маппинга традиционных классов исключений на наши классы }
  ExceptionMapper = class
  public
    class procedure Clear;
    class procedure SetDefault;
    class procedure SetFileStreamErrors (AExpectable: boolean);
    class procedure Register (Source: ExceptClass; Dest: EStsExceptionClass);
    class procedure Remove (Source: ExceptClass);
    class function Map (Source: Exception): EStsExceptionClass; overload;
    class function Map (Source: ExceptClass): EStsExceptionClass; overload;
  end;

  { Класс "ожидаемых" исключений - ошибки пользователя, конфигурации итп}
  EExpectable = class (EStsException);

  { Класс ошибок приложения }
  EApplication = class (EStsException);

  { Класс для импорта внешних исключений - ОС, библиотек итп }
  ENative = class (EStsException)
  private
    FNativeClass: ExceptClass;
  public
    procedure Assign (Source: Exception); override;
  public
    property NativeClass: ExceptClass read FNativeClass;
  end;

  { Класс для ошибок ОС }
  EOSError = class (ENative)
  private
    FErrorCode: cardinal;
  public
    procedure Assign (Source: Exception); override;
    property ErrorCode: cardinal read FErrorCode;
  end ;

  { Класс для ошибок, привязанных к программным модулям }
  EModule = class (EApplication)
  public
    procedure AfterConstruction; override;
  public
    function ModuleName: string; virtual; abstract;
  end;

  { Класс ошибок нашего модуля }
  EExUtils = class (EModule)
  public
    function ModuleName: string; override;
  end;

  { Класс для регистрации попутных замечаний }

  TWarningEvent = procedure (const Warning: string) of object;

  InternalWarnings = class
  public
    { Добавление сообщения о проблеме }
    class procedure Add (const Warning: string);
    { Добавление подписчика для связи выдаваемых предупреждений
      с интерфейсом или логом }
    class procedure AddListener (Handler: TWarningEvent);
    class procedure RemoveListener (Handler: TWarningEvent);
  end;

{ Упрощенный вызов Clone/AddExceptionHeader }
function AddExceptionHeader (E: Exception;
                             Header: string): EStsException; overload;
function AddExceptionHeader (E: Exception; Header: string;
                             Params: array of const): EStsException; overload;

{ Упрощенный вызов Clone/AddExceptionFooter }
function AddExceptionFooter (E: Exception;
                             Footer: string): EStsException; overload;
function AddExceptionFooter (E: Exception; Footer: string;
                             Params: array of const): EStsException; overload;

implementation

uses CmpUtils;

resourcestring
  SSourceModule = 'Программный модуль';
  SSafeFormat   = 'ExUtils.SafeFormat: ошибка при форматировании с маской';
  SAssert       = 'Настырный идиот таки ухитрился вызвать ExUtils.Assert';
  SNoMessage    = 'Ошибка (%s) без текста сообщения об ошибке';
  SCloningNil   = 'Сделана попытка клонировать несуществующее (nil) исключение';
  SNativeClass  = 'Исходный класс исключения';
  SInvalidMap   = 'ExceptionMap: мапить сам на себя можно только классы - ' +
                  'потомки EStsException';
  SCantMapNil   = 'ExceptionMap: нельзя отображать параметр nil';

{ Замена стандартной Assert, действующая в пределах модуля }
procedure Assert (P1: TObject; P2: array of const; P3: IInterface);
begin
  System.Assert (true, SAssert);
  { Эта подпрограмма никогда не должна вызываться в программном коде. Ее
    единственное предназначение - дать ошибку компиляции в случае, если
    кто-либо по рассеянности употребит Assert в подпрограммах модуля, чего
    ни в коем случае не следует делать - см. замечания по реализации
    По этой причине подпрограмма всегда должна оставаться первой в модуле,
    ну а вместо Assert следует использовать ExAssert }
end;

{ Функция Format с подавлением исключений }
function SafeFormat (const Template: string;
                     const Params: array of const): string;
begin
  try
    Result := Format (Template, Params);
  except
    on E: Exception do
    begin
      Result := Template;
      InternalWarnings.Add (SSafeFormat + ' [' + Template + ']: ' + E.Message);
    end;
  end;
end;

{ Функция, которую следует использовать вместо Assert }
function ExAssert (Condition: boolean; const Msg: string): boolean; overload;
begin
  Result := Condition;
  if not Result then InternalWarnings.Add (Msg);
end;

{ Функция, которую следует использовать вместо Assert }
function ExAssert (Condition: boolean;
                   const Msg: string;
                   const Params: array of const): boolean; overload;
begin
  Result := ExAssert (Condition, SafeFormat (Msg, Params));
end;

{ Упрощенный вызов Clone/AddExceptionHeader }
function AddExceptionHeader (E: Exception; Header: string): EStsException;
begin
  Result := EStsException.Clone (E);
  Result.AddHeader (Header);
end;

{ Упрощенный вызов Clone/AddExceptionHeader }
function AddExceptionHeader (E: Exception; Header: string;
                             Params: array of const): EStsException;
begin
  Result := EStsException.Clone (E);
  Result.AddHeader (Header, Params);
end;

{ Упрощенный вызов Clone/AddExceptionFooter }
function AddExceptionFooter (E: Exception; Footer: string): EStsException;
begin
  Result := EStsException.Clone (E);
  Result.AddFooter (Footer);
end;

function AddExceptionFooter (E: Exception; Footer: string;
                             Params: array of const): EStsException;
begin
  Result := EStsException.Clone (E);
  Result.AddFooter (Footer, Params);
end;

{ EStsException }

{ Создание объектов доп. информации при вызове любого конструктора }
procedure EStsException.AfterConstruction;
begin
  inherited;
  Headers := TStringList.Create;
  Footers := TStringList.Create;
end;

{ Уничтожение объектов доп. информации }
destructor EStsException.Destroy;
begin
  inherited;
  FreeAndNil (Headers);
  FreeAndNil (Footers);
end;

{ Клонирование исключения с перекодировкой для native-классов }
class function EStsException.Clone (E: Exception): EStsException;
type
  EStsExceptionClass = class of EStsException;
var
  ExClass: EStsExceptionClass;
begin
  { Обработаем параметр nil }
  if not ExAssert (E <> nil, 'EStsException.Clone: E = nil') then
  begin
    Result := EExUtils.Create (SCloningNil);
    exit;
  end;
  { Создадим объект и наполним его }
  ExClass := ExceptionMapper.Map (E);
  Result := ExClass.Create ('');
  Result.Assign (E);
end;

{ Самовозбуждение }
procedure EStsException.RaiseSelf;
begin
  CompleteMessage;
  raise Self;
end;

{ Добавление к сообщению заголовка }
procedure EStsException.AddHeader (Header: string;
                                   const Params: array of const);
begin
  AddHeader (SafeFormat (Header, Params));
end;

{ Добавление к сообщению заголовка }
procedure EStsException.AddHeader (Header: string);
begin
  Header := Trim (Header);
  if Header = '' then exit;
  if CheckHeaders then Headers.Insert (0, Header);
  CompleteMessage;
end;

{ Добавление к сообщению нижнего титула }
procedure EStsException.AddFooter (Footer: string;
                                   const Params: array of const);
begin
  AddFooter (SafeFormat (Footer, Params));
end;

{ Добавление к сообщению нижнего титула }
procedure EStsException.AddFooter (Footer: string);
begin
  Footer := Trim (Footer);
  if Footer = '' then exit;
  if CheckFooters then Footers.Add (Footer);
  CompleteMessage;
end;

{ Добавление параметра дополнительной информации }
procedure EStsException.AddParam (const Name: string; const Value: variant);
begin
  with Params [AddParam (Name)] do
  begin
    ParamType := eptVariant;
    VarValue := Value;
  end;
end;

{ Добавление параметра дополнительной информации }
procedure EStsException.AddParam (const Name: string; const Value: TObject);
begin
  with Params [AddParam (Name)] do
  begin
    ParamType := eptObject;
    ObjValue := Value;
  end;
end;

{ Добавление параметра дополнительной информации }
procedure EStsException.AddParam (const Name: string; const Value: TClass);
begin
  with Params [AddParam (Name)] do
  begin
    ParamType := eptClass;
    ClassValue := Value;
  end;
end;

{ Возврат значений параметров }

function EStsException.ParamCount: integer;
begin
  Result := Length (Params);
end;

function EStsException.Param (ParamNo: integer): TExceptionParam;
begin
  if (ParamNo >= Low (Params)) and (ParamNo <= High (Params))
    then Result := Params [ParamNo]
    else { пойдет значение по умолчанию - пустая запись };
end;

{ Копирование информации исключения из объекта в объект }
procedure EStsException.Assign (Source: Exception);
var StsSource: EStsException absolute Source;
begin
  if not ExAssert (Source <> nil, 'EStsException.Assign: Source = nil') then exit;
  { Копируем члены Exception }
  Self.Message := Source.Message;
  Self.HelpContext := Source.HelpContext;
  { Копируем члены EStsException }
  if Source is EStsException then
  begin
    Self.OrigMessage := StsSource.OrigMessage;
    Self.Params := StsSource.Params;
    if Self.CheckHeaders and StsSource.CheckHeaders then
      Self.Headers.Assign (StsSource.Headers);
    if Self.CheckFooters and StsSource.CheckFooters then
      Self.Footers.Assign (StsSource.Footers);
    CompleteMessage;
  end;
end;

{ Формирование полного текста сообщения об ошибке }
function EStsException.CompleteMessage: string;
begin
  if OrigMessage = '' then OrigMessage := Trim (Self.Message);
  if OrigMessage = '' then OrigMessage := NoMessage;
  Result := OrigMessage;
  if CheckHeaders and (Headers.Count > 0) then
    Result := Headers.Text + #13#10 + Result;
  if CheckFooters and (Footers.Count > 0) then
    Result := Result + #13#10#13#10 + Footers.Text;
  Self.Message := Result;
end;

{ Формирование текста сообщения об ошибке при отсутствии такового }
function EStsException.NoMessage: string;
begin
  Result := SafeFormat (SNoMessage, [Self.ClassName]);
end;

{ Проверки существования используемых объектов }

function EStsException.CheckHeaders: boolean;
begin
  Result := ExAssert (Headers <> nil, 'EStsException: Headers = nil');
end;

function EStsException.CheckFooters: boolean;
begin
  Result := ExAssert (Footers <> nil, 'EStsException: Footers = nil');
end;

{ Рабочие методы }
function EStsException.AddParam (const Name: string): integer;
begin
  Result := Length (Params);
  SetLength (Params, Result + 1);
  Params [Result].Name := Name;
end;

{ ExceptionMapper }

type
  TExceptionMapItem = record
    Source: ExceptClass;
    Dest: EStsExceptionClass;
  end;

var
  ExceptionMap: array of TExceptionMapItem;

{ Поиск записи об исключении }
function ExceptionMapIndex (Source: ExceptClass): integer;
begin
  Result := High (ExceptionMap);
  while Result >= Low (ExceptionMap) do
    if ExceptionMap [Result].Source = Source
      then exit
      else Dec (Result);
end;

{ Сброс карты маппинга }
class procedure ExceptionMapper.Clear;
begin
  SetLength (ExceptionMap, 0);
end;

{ Установка карты маппинга по умолчанию }
class procedure ExceptionMapper.SetDefault;
begin
  Clear;
  Register (Exception, ENative);
  Register (SysUtils.EOSError, ExUtils.EOSError);
  Register (SysUtils.EInOutError, ExUtils.EOSError);
  Register (EStsException, nil);
  SetFileStreamErrors (true);
end;

{ Управление статусом ошибок ввода-вывода }
class procedure ExceptionMapper.SetFileStreamErrors (AExpectable: boolean);
begin
  if AExpectable
    then Register (EFileStreamError, EExpectable)
    else Register (EFileStreamError, ENative);
end;

{ Добавление либо изменение записи об исключении }
class procedure ExceptionMapper.Register (Source: ExceptClass;
                                          Dest: EStsExceptionClass);
var I: integer;
begin
  if not Assigned (Source) then
    raise EExUtils.Create (SCantMapNil);
  if not Assigned (Dest) and not Source.InheritsFrom (EStsException) then
    raise EExUtils.Create (SInvalidMap);
  I := ExceptionMapIndex (Source);
  if I < 0 then
  begin
    I := Length (ExceptionMap);
    SetLength (ExceptionMap, I + 1);
  end;
  ExceptionMap [I].Source := Source;
  ExceptionMap [I].Dest := Dest;
end;

{ Удаление записи об исключении }
class procedure ExceptionMapper.Remove (Source: ExceptClass);
var I, H: integer;
begin
  I := ExceptionMapIndex (Source);
  if I < 0 then exit;
  H := High (ExceptionMap);
  if I < H then ExceptionMap [I] := ExceptionMap [H];
  SetLength (ExceptionMap, H);
end;

{ Мапинг исходного класса исключения на EStsException }
class function ExceptionMapper.Map (Source: Exception): EStsExceptionClass;
begin
  if ExAssert (Source <> nil, 'ExceptionMapper.Map: Source = nil')
    then Result := Map (ExceptClass (Source.ClassType))
    else Result := EStsException;
end;

{ Мапинг исходного класса исключения на EStsException }
class function ExceptionMapper.Map (Source: ExceptClass): EStsExceptionClass; 
var
  ExClass: TClass;
  i: integer;
begin
  Result := EStsException;
  ExClass := TObject;
  for i := Low (ExceptionMap) to High (ExceptionMap) do
    if Source.InheritsFrom (ExceptionMap [i].Source) then
      if ExceptionMap [i].Source.InheritsFrom (ExClass) then
      begin
        ExClass := ExceptionMap [i].Source;
        Result  := ExceptionMap [i].Dest;
      end;
  if Result = nil then Result := EStsExceptionClass (Source);
end;

{ InternalWarnings }

var
  Warnings: TStringList;
  Listeners: array of TWarningEvent;

{ Добавление сообщения о проблеме }
class procedure InternalWarnings.Add (const Warning: string);
begin
  if Warnings = nil then exit; { лучше забыть предупреждение, чем убить программу }
  if Warnings.IndexOf (Warning) >= 0 then exit; { уже было }
  Warnings.Add (Warning);
end;

{ Добавление подписчика для связи выдаваемых предупреждений с интерфейсом или логом }
class procedure InternalWarnings.AddListener (Handler: TWarningEvent);
var L: integer;
begin
  if not Assigned (Handler) then exit;
  { Защитимся от дублей }
  RemoveListener (Handler);
  { Вот теперь добавим }
  L := Length (Listeners);
  SetLength (Listeners, L + 1);
  Listeners [L] := Handler;
end;

{ Удаление подписчика }
class procedure InternalWarnings.RemoveListener (Handler: TWarningEvent);
var i, Last: integer;
begin
  Last := High (Listeners);
  for i := Last downto Low (Listeners) do
    if EqualHandlers (Handler, Listeners [i]) then
    begin
      if i < Last then Listeners [i] := Listeners [Last];
      SetLength (Listeners, Last);
      Dec (Last);
    end;
end;

{ ENative }

procedure ENative.Assign (Source: Exception);
begin
  inherited;
  if Source is ENative then
    Self.FNativeClass := ENative (Source).FNativeClass
  else
    begin
      Self.FNativeClass := ExceptClass (Source.ClassType);
      Self.AddParam (SNativeClass, Self.NativeClass);
    end;
end;

{ EModule }

procedure EModule.AfterConstruction;
begin
  inherited;
  AddParam (SSourceModule, ModuleName);
end;

{ EExUtils }

function EExUtils.ModuleName: string;
begin
  Result := 'ExUtils';
end;

{ EOSError }

procedure EOSError.Assign (Source: Exception);
begin
  inherited;
  if Source is SysUtils.EOSError then
    Self.FErrorCode := SysUtils.EOSError (Source).ErrorCode;
  if Source is SysUtils.EInOutError then
    Self.FErrorCode := SysUtils.EInOutError (Source).ErrorCode;
end;

initialization
  ExceptionMapper.SetDefault;
  Warnings := TStringList.Create;
  Warnings.CaseSensitive := false;

finalization
  FreeAndNil (Warnings);
  
end.
