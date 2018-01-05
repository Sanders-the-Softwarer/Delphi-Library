////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                RecordList - реализация типа "Список записей"               //
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

{ ----- Применение модуля ------------------------------------------------------

Модуль RecordList предназначен для реализации таких часто используемых
структур данных, как массив (список) записей. Для использования класса следует
описать свой тип данных примерно следующим образом

type
  TMyRecords = class (TRecordList)
  public
    constructor Create; override;
  public
    property Key [ArrIndex: integer]: integer index 0 read GetInt write SetInt;
    property Value [ArrIndex: integer]: string index 1 read GetStr write SetStr;
  end;

constructor TMyRecords.Create;
begin
  inherited;
  RecordLength := 2;
end;

После этого уже возможно обращаться к записям и их полям по индексу в массиве,
например:

with TMyRecords.Create do
begin
  Add;
  Key [0] := 1;
  Value [0] := 'Единица';
end;

Хранение данных и доступ к ним определяются индексом, приписанным каждому
свойству (в примере 0 - для Key и 1 - для Value). В случае, если несколько
свойств описаны с одинаковым индексом, их значения будут размещены в памяти
по одному адресу, что скорее всего приведет к разрушительным последствиям.
Перед использованием объекта следует инициализировать его свойство RecordLength
количеством описанных свойств - это необходимо для корректного выделения памяти
для хранения строк.

Метод SetLength позволяет явно установить количество строк в классе. Лишние
строки при необходимости будут удалены; недостающие - добавлены и
инициализированы пустыми значениями. Кроме того, при установленном свойстве
AutoAdd любое обращение по индексу будет приводить к увеличению размера
массива до соответствующего значения.

Класс поддерживает "списочные" методы - Count, Add, Insert, Move, Exchange,
Delete, Clear - работы c записями. При установленном свойстве AutoAdd работа
этих методов может приводить к неожиданным последствиям; скажем, для пустого
списка вызов Delete (10) окажется эквивалентным добавлению десяти строк.

Класс поддерживает следующие типы данных:

  +--------------+----------------+----------------+
  | Тип          | Метод Get      | Метод Set      |
  +--------------+----------------+----------------+
  | integer      | GetInt         | SetInt         |
  | Cardinal     | GetCardinal    | SetCardinal    |
  | boolean      | GetBool        | SetBool        |
  | char         | GetChar        | SetChar        |
  | pointer      | GetPtr         | SetPtr         |
  | variant      | GetVariant     | SetVariant     |
  | PChar        | GetPChar       | SetPChar       |
  | AnsiString   | GetStr         | SetStr         |
  | WideString   | GetWideStr     | SetWideStr     |
  | Extended     | GetFloat       | SetFloat       |
  | TDateTime    | GetDate        | SetDate        |
  | TObject      | GetObj         | SetObj         |
  | TComponent   | GetComponent   | SetComponent   |
  | TStrings     | GetStrings     | SetStrings     |
  | TIcon        | GetIcon        | SetIcon        |
  | TClass       | GetClass       | SetClass       |
  | IInterface   | GetInterface   | SetInterface   |
  | TControl     | GetControl     | SetControl     |
  | TNotifyEvent | GetNotifyEvent | SetNotifyEvent |
  | TShiftState  | GetShiftState  | SetShiftState  |
  +--------------+----------------+----------------+

Методы доступа для других типов данных могут быть легко добавлены в
класс-потомок (так, методы доступа для любого объектного класса легко делаются
на основе GetObj/SetObj, см. реализацию для TIcon или TControl).

Класс поддерживает возможность автоматической сортировки по одному из полей. Для
использования этой возможности нужно:

  - в конструкторе класса или подобном месте вызвать метод SetSortOrder и
    определить требуемый способ сортировки

  - в качестве метода записи для свойства использовать "сортировочный" сеттер
    вместо обычного.

Сортировка возможна для целочисленных (SetSortInt), строковых (SetSortStr) и
прочих значений, для которых в классе определен метод SetSortXXXXX. При
использовании сортировки следует иметь в виду, что:

  - для строковых полей с помощью свойства SortCaseInsensitive может быть
    включена регистронезависимая сортировка

  - некоторые методы (Move, Exchange, Insert) неприменимы в режиме сортировки

  - изменение значения сортируемого поля приводит к немедленной пересортировке
    и изменению индекса модифицируемой записи.

Для сортируемых списков метод Add добавляет строку в середину списка - туда,
куда должны попадать записи с нулевым значением ключа.

Для добавления строк в сортированные списки предназначен метод InsertKey -
сразу заполняющий значение ключевого поля переданным значением и вставляющий
запись на нужное место в списке. Добавленные строки могут быть найдены в
списке с помощью методов SortIndexOf либо SortIndexRange.

Для более удобной работы с сортируемыми массивами предназначен механизм
закладок. Закладка - это некая характеристика строки массива, не меняющаяся на
протяжении всего периода жизни этой строки (после ее удаления закладка может
быть присвоена другой, новой строке). Функции IndexToBookmark и BookmarkToIndex
позволяют работать с записями, чей индекс может меняться из-за сортировки или
других операций с массивом.

Класс может выступать владельцем хранящихся в нем объектов и указателей. Это
значит, что он выполнит освобождение памяти (Free/FreeMem) при уничтожении,
очистке объекта либо присвоении свойству нового значения. Для использования
этого режима следует использовать методы GetOwnObj/SetOwnObj GetOwnPtr/SetOwnPtr
соответственно.

Подпрограмма AddRecord позволяет одним обращением передать значения сразу для
всех полей записи - перечисляя их по порядку индексов. Она корректно работает
и для сортируемых списков. Однако следует иметь в виду, что подпрограмма
ориентируется только на тип переданного variant-значения и при ее использовании
для инициализации массивов с "не соответствующими variant" типами свойств
возможны произвольные проблемы. Кроме того, при ее использовании для классов
с own-свойствами в редких случаях возможна утечка памяти.

Пара методов GetStoredStrings/SetStoredStrings позволяет описать "заранее
создаваемый" объект типа TStringList. В этом случае объект создается при
первом обращении к GetStoredStrings, а сеттер вместо замены указателя
выполняет присвоение через Assign.

------------------------------------------------------------------------------ }

{ ----- История модуля ---------------------------------------------------------

Конец 1998 года. Первая версия класса.

03.05.2000 Модуль переведен на работу под Delphi 5
19.05.2000 Добавлен метод Clear. Выделяемая память заполняется нулями
22.05.2000 Добавлены методы GetBoolValue, SetBoolValue
21.09.2000 Добавлены методы GetStr, SetStr, GetFloat, SetFloat; методы
           Get/SetBoolValue переименованы в GetBool и SetBool, а методы
           Get/SetValue - в Get/SetInt
29.09.2000 Если в потомке определялись строковые поля, но последнее поле было
           не строковым, вылетали bits index out of range

04.10.2000 Релиз второй версии CTR View (точная версия 2.0.18.76)

20.10.2000 Добавлен простейший кэш - запоминается последний использованный
           указатель. В результате скорость, например, импорта маршрутных данных
           в CTR View возросла на треть (82% попаданий в кэш)
23.11.2000 Добавлено свойство AutoAdd - для автоматического расширения массива
           при обращении по соответствующим индексам
04.12.2000 Добавлена проверка выхода за пределы выделяемой памяти
08.12.2000 Добавлена возможность автосортировки по заданному полю и методы
           SortIndexOf, InsertRecord
27.12.2000 В методах класса проверяется, был ли объект должным образом
           инициализирован
05.01.2001 Добавлены методы для работы с объектными полями
09.01.2001 Добавлена поддержка закладок
12.01.2001 Добавлена подпрограмма AddRecord; подпрограммы InsertRecord
           переименованы в InsertKey
14.02.2001 Добавлены подпрограммы GetStrings, SetStrings, SetOwnStrings,
           GetStoredStrings, SetStoredStrings. Добавлен метод Exchange

17.07.2004 Модуль доработан для работы под Delphi 6. Убраны завязки на другие
           нестандартные модули. Мелкие доработки; в частности, дана возможность
           на лету переопределять размер массива и менить порядок сортировки
18.07.2004 Класс переименован в TRecordList, модуль соответственно в RecordList.
           По результатам тестирования скорости проведена некоторая оптимизация.
01.08.2004 Добавлен метод SortIndexRange. Добавлена поддержка типа char (методы
           GetChar, SetChar, SetSortChar)
10.08.2004 Незначительно ускорены методы SortGetIndexFor и RequestRecord
14.08.2004 Добавлен виртуальный метод CreateStoredStrings
22.08.2004 Добавлена поддержка интерфейсов
17.01.2005 Мелкая оптимизация - убран вызов RegisterStringIndex в методе GetStr,
           расставлены модификаторы const
05.03.2005 Добавлена поддержка TDateTime, в том числе возможность сортировки
25.06.2007 Добавлена поддержка PChar
28.06.2007 Добавлена поддержка TClass
29.06.2007 Добавлена поддержка TShiftState и TNotifyEvent
01.07.2007 Добавлена поддержка TIcon
10.07.2007 Добавлена поддержка variant
13.07.2007 Добавлена регистронезависимые сортировка-поиск строк
17.01.2008 Добавлена работа с pointer-ами и cardinal-ами. Исправлена ошибка,
           из-за которой присвоение variant-свойству Unassigned, выполненное
           дважды подряд, приводило к AV
19.04.2008 Добавлена работа с WideString
21.04.2008 Реализация float изменена со строк на указатели. Это позволит
           AddRecord-у работать с сортируемыми полями дат, да и вообще
           правильнее.
21.04.2008 Исправлена ошибка - SetOwnXXXX методы не уничтожали предыдущий объект
           или указатель.
23.04.2008 Исправлена ошибка - GetVariant возвращал значением по умолчанию Null
           вместо Unassigned. Исправлена ошибка в реализации own объектов и
           указателей, из-за которой при присвоении нескольких одинаковых
           значений подряд рушилась память. Более корректно реализованы методы
           Add и AddRecord (ох, порушится куча старого кода...) 
23.04.2008 Перестроена внутренняя архитектура сортировки и сопутствующие ей
           методы, не очень обязательные проверки упрятаны в директивы Assert,
           что позволит отключать их при сборке релиза.
27.04.2008 Добавлен метод SetLength; переписана инструкция.
01.05.2008 Добавлены методы Get/SetComponent и сортировка по Object и Component.
           Методы SortIndexRange, если не нашли записей, возвращают Low = -1,
           High = -2 - таким образом в любой ситуации будет правильно работать
           цикл for i := Low to High.
10.06.2008 Оптимизация. Убран двойной вызов Count в CheckRecordIndex. Тело
           CheckRecordIndex перенесено в RequestRecord как в основного
           потребителя. Директива Inline ускорила тест в полтора раза.
16.07.2008 Втянуты изменения, сделанные в ветке для Sphaera. Еще некоторые
           оптимизации, в частности значительно уменьшено количество вызовов
           BookmarkToIndex; при смене порядка сортировки теперь данные не
           очищаются, но пересортировываются под новый порядок; более AddRecord
           после ClearSortOrder не восстанавливает старый порядок сортировки.
06.07.2009 Втянуты изменения, сделанные в ветке для Sphaera. Добавлена
           сортировка по float полям, поддержка SetNextSortStr.

------------------------------------------------------------------------------ }

{ ----- Замечания по реализации ------------------------------------------------

Для получения действительного адреса записи во всех случаях необходимо
использовать подпрограмму RequestRecord (поля - RequestField соответственно).

Работа с типом char реализована через строки (методы XxxStr). Причина этого в
том, что тип char часто конвертируется в тип string, и при другой реализации
начинается много тонких проблем - с AddRecord, SortIndexOf итп. Я не нашел
достаточно хорошего способа сделать "байтовую" реализацию char, поэтому сделал
его совместимым по реализации со string.

Класс в приципе не предназначен к наследованию, отличному от описания конкретных
экземпляров класса - поскольку в нашем распоряжении имеется исходный код,
изменения предполагается вносить в него

В текущей реализации в качестве закладок используется непосредственно адрес
области памяти, выделенной под соответствующую строку массива

Для сравнений-сортировки строк используется довольно корявый код, который надо
бы сделать получше, но который в отличие от AnsiCompareXXX, CompareString итп
обладает одним важным достоинством: он работает, причем без сюрпризов. Хотя
таки надо как-нибудь добиться нормальной работы от "правильных" функций или
еще лучше - сделать в классе настройку для выбора метода.

------------------------------------------------------------------------------ }

unit RecordList;

{$Inline Auto}

interface

uses Windows, Classes, SysUtils, Variants, Controls, Graphics, AnsiStrings;

type

  TRLBookmark = integer;
  ERecordList = class (Exception);
  TRLFinalizer = class;
  TRLAdapter = class;
  TRLAdapterClass = class of TRLAdapter;
  TRLFieldType = (ftUnknown, ftInteger, ftString, ftWideString, ftFloat,
                  ftDate, ftPointer, ftObject, ftComponent);

  ///////////////////////////////////////////////////////////////////
  //               Тип для хранения массивов записей               //
  ///////////////////////////////////////////////////////////////////

  TRecordList = class
  private
    FlagOK      : boolean;
    FlagInitOK  : boolean;
    FList       : TList  ;
    FRecordLen  : integer;
    FRecordSize : integer;
    FLastIndex  : integer;
    FLastAddress: pointer;
    FAutoAdd    : boolean;
    FSortSet    : boolean;
    FSortIndex  : integer;
    FNextUsed   : boolean;
    FOnDelete   : TNotifyEvent;
    FSortFieldType: TRLFieldType;
    FSortCaseInsensitive: boolean;
    StringFinalizer, WideStringFinalizer, OwnObjFinalizer,
      IntfFinalizer, VariantFinalizer, OwnPtrFinalizer: TRLFinalizer;
  private
    procedure FinalizeRecord (ArrIndex: integer);
    function SortGetIndexFor (const Value; Adapter: TRLAdapterClass): integer; overload;
    function SortIndexOf (const Key; Adapter: TRLAdapterClass): integer; overload;
    procedure SortIndexRange (const Key; Adapter: TRLAdapterClass;
                              out Low, High: integer); overload;
  protected
    { Служебные методы }
    function CheckOK: boolean;
    procedure CheckSortRequired;
    procedure CheckSortRestricted;
    function CheckRecordIndex (ArrIndex: integer): boolean;
    function CheckFieldIndex (FieldIndex: integer): boolean;
    procedure CheckSortAutoAdd (Found: boolean);
    function RequestRecord (ArrIndex: integer): pointer;
    function RequestField (ArrIndex, Index: integer): pointer;
    function MakeNewRecord: pointer;
    procedure SetSortOrder (Index: integer; AFieldType: TRLFieldType = ftUnknown);
    procedure SetSortNext (Index: integer);
    procedure ClearSortOrder;
    procedure Sort (FieldIndex: integer; FieldType: TRLFieldType);
    function InsertKeyCommon (NewIndex: integer): integer;
    function SortGetIndexFor (Value: integer): integer; overload;
    function SortGetIndexFor (Value: pointer): integer; overload;
    function SortGetIndexFor (Value: AnsiString): integer; overload;
    function SortGetIndexFor (Value: WideString): integer; overload;
    function SortGetIndexFor (Value: TDateTime): integer; overload;
    function CreateStoredStrings (Index: integer): TStrings; dynamic;
    { Методы свойств }
    procedure SetAutoAdd (NewAutoAdd: boolean);
    procedure SetRecordLength (Len: integer);
    procedure SetSortCaseInsensitive (NewCaseInsensitive: boolean);
    function GetInt (ArrIndex, Index: integer): integer;
    procedure SetInt (ArrIndex, Index, NewValue: integer);
    procedure SetSortInt (ArrIndex, Index, NewValue: integer);
    function GetCardinal (ArrIndex, Index: integer): Cardinal;
    procedure SetCardinal (ArrIndex, Index: integer; NewValue: Cardinal);
    function GetBool (ArrIndex, Index: integer): boolean;
    procedure SetBool (ArrIndex, Index: integer; NewValue: boolean);
    function GetChar (ArrIndex, Index: integer): AnsiChar;
    procedure SetChar (ArrIndex, Index: integer; NewValue: AnsiChar);
    procedure SetSortChar (ArrIndex, Index: integer; NewValue: AnsiChar);
    function GetPtr (ArrIndex, Index: integer): pointer;
    procedure SetPtr (ArrIndex, Index: integer; NewValue: pointer);
    procedure SetSortPtr (ArrIndex, Index: integer; NewValue: pointer);
    function GetOwnPtr (ArrIndex, Index: integer): pointer;
    procedure SetOwnPtr (ArrIndex, Index: integer; NewValue: pointer);
    procedure SetOwnSortPtr (ArrIndex, Index: integer; NewValue: pointer);
    function GetPChar (ArrIndex, Index: integer): PChar;
    procedure SetPChar (ArrIndex, Index: integer; NewValue: PChar);
    procedure SetOwnPChar (ArrIndex, Index: integer; NewValue: PChar);
    function GetPAnsiChar (ArrIndex, Index: integer): PAnsiChar;
    procedure SetPAnsiChar (ArrIndex, Index: integer; NewValue: PAnsiChar);
    procedure SetOwnPAnsiChar (ArrIndex, Index: integer; NewValue: PAnsiChar);
    function GetStr (ArrIndex, Index: integer): AnsiString;
    procedure SetStr (ArrIndex, Index: integer; NewValue: AnsiString);
    procedure SetSortStr (ArrIndex, Index: integer; NewValue: AnsiString);
    procedure SetNextSortStr (ArrIndex, Index: integer; NewValue: AnsiString);
    function GetWideStr (ArrIndex, Index: integer): WideString;
    procedure SetWideStr (ArrIndex, Index: integer; NewValue: WideString);
    procedure SetSortWideStr (ArrIndex, Index: integer; NewValue: WideString);
    function GetFloat (ArrIndex, Index: integer): Extended;
    procedure SetFloat (ArrIndex, Index: integer; NewValue: Extended);
    procedure SetSortFloat (ArrIndex, Index: integer; NewValue: Extended);
    function GetDate (ArrIndex, Index: integer): TDateTime;
    procedure SetDate (ArrIndex, Index: integer; NewValue: TDateTime);
    procedure SetSortDate (ArrIndex, Index: integer; NewValue: TDateTime);
    function GetObj (ArrIndex, Index: integer): TObject;
    procedure SetObj (ArrIndex, Index: integer; NewObject: TObject);
    procedure SetSortObj (ArrIndex, Index: integer; NewObject: TObject);
    function GetOwnObj (ArrIndex, Index: integer): TObject;
    procedure SetOwnObj (ArrIndex, Index: integer; NewObject: TObject);
    procedure SetSortOwnObj (ArrIndex, Index: integer; NewObject: TObject);
    function GetComponent (ArrIndex, Index: integer): TComponent;
    procedure SetComponent (ArrIndex, Index: integer; NewComponent: TComponent);
    procedure SetSortComponent (ArrIndex, Index: integer; NewComponent: TComponent);
    function GetStrings (ArrIndex, Index: integer): TStrings;
    procedure SetStrings (ArrIndex, Index: integer; NewStrings: TStrings);
    procedure SetOwnStrings (ArrIndex, Index: integer; NewStrings: TStrings);
    function GetStoredStrings (ArrIndex, Index: integer): TStrings;
    procedure SetStoredStrings (ArrIndex, Index: integer; NewStrings: TStrings);
    function GetIcon (ArrIndex, Index: integer): TIcon;
    procedure SetIcon (ArrIndex, Index: integer; NewIcon: TIcon);
    function GetOwnIcon (ArrIndex, Index: integer): TIcon;
    procedure SetOwnIcon (ArrIndex, Index: integer; NewIcon: TIcon);
    function GetClass (ArrIndex, Index: integer): TClass;
    procedure SetClass (ArrIndex, Index: integer; NewValue: TClass);
    procedure SetSortClass (ArrIndex, Index: integer; NewValue: TClass);
    function GetInterface (ArrIndex, Index: integer): IInterface;
    procedure SetInterface (ArrIndex, Index: integer; NewInterface: IInterface);
    function GetControl (ArrIndex, Index: integer): TControl;
    procedure SetControl (ArrIndex, Index: integer; NewControl: TControl);
    function GetNotifyEvent (ArrIndex, Index: integer): TNotifyEvent;
    procedure SetNotifyEvent (ArrIndex, Index: integer; NewEvent: TNotifyEvent);
    function GetShiftState (ArrIndex, Index: integer): TShiftState;
    procedure SetShiftState (ArrIndex, Index: integer; NewShift: TShiftState);
    function GetVariant (ArrIndex, Index: integer): variant;
    procedure SetVariant (ArrIndex, Index: integer; NewVariant: variant);
  protected
    property RecordLength: integer read FRecordLen write SetRecordLength;
    property RecordSize  : integer read FRecordSize;
    property SortIndex: integer read FSortIndex;
    property OnDelete: TNotifyEvent read FOnDelete write FOnDelete;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  public
    procedure SetLength (NewLength: integer);
    function  Count: integer;
    function  Add  : integer;
    function  Insert (Index: integer): integer;
    function  AddRecord (Data: array of variant): integer;
    function  InsertKey (Key: integer): integer; overload;
    function  InsertKey (Key: pointer): integer; overload;
    function  InsertKey (Key: AnsiString): integer; overload;
    function  InsertKey (Key: WideString): integer; overload;
    function  InsertKey (Key: Extended): integer; overload;
    function  InsertKey (Key: TDateTime): integer; overload;
    procedure Delete (Index: integer);
    procedure Clear;
    procedure Exchange (Index1, Index2: integer);
    procedure Move (IndexFrom, IndexTo: integer);
    function  SortIndexOf (Key: integer): integer; overload;
    function  SortIndexOf (Key: pointer): integer; overload;
    function  SortIndexOf (Key: AnsiString): integer; overload;
    function  SortIndexOf (Key: WideString): integer; overload;
    function  SortIndexOf (Key: TDateTime): integer; overload;
    procedure SortIndexRange (Key: integer;
                               out Low, High: integer); overload;
    procedure SortIndexRange (Key: pointer;
                               out Low, High: integer); overload;
    procedure SortIndexRange (Key: AnsiString;
                               out Low, High: integer); overload;
    procedure SortIndexRange (Key: WideString;
                               out Low, High: integer); overload;
    procedure SortIndexRange (Key: TDateTime;
                               out Low, High: integer); overload;
    function  InsertKey (Key: UnicodeString): integer; overload;
    function  SortIndexOf (Key: UnicodeString): integer; overload;
    procedure SortIndexRange (Key: UnicodeString;
                               out Low, High: integer); overload;
    function  IndexToBookmark (Index: integer): TRLBookmark;
    function  BookmarkToIndex (Bookmark: TRLBookmark): integer;
  public
    property AutoAdd: boolean read FAutoAdd write SetAutoAdd;
    property SortCaseInsensitive: boolean read FSortCaseInsensitive
      write SetSortCaseInsensitive;
  end;

  { Список с данными }
  TRLList = class (TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    Owner: TRecordList;
  end;

  { Вспомогательный класс для очистки памяти при удалении строк }
  TRLFinalizer = class (TBits)
  private
    Owner: TRecordList;
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); virtual; abstract;
  public
    constructor Create (AOwner: TRecordList);
    procedure RegisterField (Index: integer);
    function HasField (Index: integer): boolean;
    procedure FinalizeRecord (ArrIndex: integer);
    procedure FinalizeField (ArrIndex, Index: integer);
  end;

  { Вспомогательный класс для затачивания общих алгоритмов под типы данных }
  TRLAdapter = class
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; virtual; abstract;
  end;

implementation

resourcestring
  SSortRequired         = 'Метод неприменим для несортируемых классов';
  SSortRestricted       = 'Метод неприменим для сортируемых классов';
  SInvalidClass         = 'Класс (%s) неправильно инициализирован ' +
                          'и не готов к работе';
  SInvalidRecIndex      = 'Недопустимый индекс записи (%d)';
  SInvalidPropIndex     = 'Недопустимый индекс свойства для класса %s (%d)';
  SRequiresEmpty        = 'Операция может быть выполнена только при ' +
                          'отсутствии хранящихся данных';
  SAddRecordUnsupported = 'Метод AddRecord не поддерживает variant-тип (%d)';
  SSortAutoAdd          = 'Установка свойства AutoAdd несовместима с ' +
                          'сортировкой и наоборот';
  SInvalidSortFieldType = 'Для полей этого типа сортировка не поддерживается';

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                          Вспомогательные классы                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

type

  TIntArray = array [0..MaxInt div 4 - 1] of integer;
  PIntArray = ^TIntArray;

  TStringFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TWideStringFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TOwnObjFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TIntfFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TVariantFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TOwnPtrFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TIntAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TPtrAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TDateTimeAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TFloatAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TStringAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TWideStringAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                               TRecordList                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

type
  { Вспомогательные типы данных для адресации полей }
  PInterface = ^IInterface;
  PPVariant = ^PVariant;

constructor TRecordList.Create;
begin
  FList := TList.Create;
  FLastIndex := -1;
  FSortIndex := -1;
  FlagInitOK := true;
  StringFinalizer := TStringFinalizer.Create (Self);
  WideStringFinalizer := TWideStringFinalizer.Create (Self);
  OwnObjFinalizer := TOwnObjFinalizer.Create (Self);
  IntfFinalizer := TIntfFinalizer.Create (Self);
  VariantFinalizer := TVariantFinalizer.Create (Self);
  OwnPtrFinalizer := TOwnPtrFinalizer.Create (Self);
end;

destructor TRecordList.Destroy;
begin
  FlagOk := false;
  Clear;
  FreeAndNil (FList);
  FLastIndex := -1;
  FreeAndNil (StringFinalizer);
  FreeAndNil (WideStringFinalizer);
  FreeAndNil (OwnObjFinalizer);
  FreeAndNil (IntfFinalizer);
  FreeAndNil (VariantFinalizer);
  FreeAndNil (OwnPtrFinalizer);
  inherited;
end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                             Основные методы                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{ Установка количества элементов в массиве }
procedure TRecordList.SetLength (NewLength: integer);
var i: integer;
begin
  CheckSortRestricted;
  for i := Count + 1 to NewLength do Add;
  for i := Count - 1 downto NewLength do Delete (i);
  Assert (Count = NewLength);
end;

{ Возврат количества элементов в массиве }
function TRecordList.Count: integer;
begin
  Result := FList.Count;
end;

{ Добавление очередного элемента к массиву }
function TRecordList.Add: integer;
begin
  if not FSortSet then
    Result := Insert (Count)
  else
    case FSortFieldType of
      ftInteger   : Result := InsertKey (0);
      ftString    : Result := InsertKey ('');
      ftWideString: Result := InsertKey (WideString (''));
      ftFloat     : Result := InsertKey (0.0);
      ftDate      : Result := InsertKey (0.0);
      ftPointer,
      ftObject,
      ftComponent : Result := InsertKey (nil);
      else          Result := InsertKeyCommon (0);
    end;
end;

{ Вставка записи в указанное место }
function TRecordList.Insert (Index: integer): integer;
var
  NewPtr: pointer;
begin
  CheckSortRestricted;
  NewPtr       := MakeNewRecord;
  FList.Insert (Index, NewPtr);
  FLastIndex   := Index;
  FLastAddress := NewPtr;
  Insert       := Index;
end;

{ Вставка и заполнение очередного элемента массива }
function TRecordList.AddRecord (Data: array of variant): integer;
var
  ArrIndex, i: integer;
  Bookmark: TRLBookmark;
begin
  ArrIndex := Add;
  Bookmark := IndexToBookmark (ArrIndex);
  for i := Low (Data) to High (Data) do
  begin
    if VarIsStr (Data [i]) then
      if FSortIndex = i then
        begin
          SetSortStr (ArrIndex, i, AnsiString (Data [i]));
          ArrIndex := BookmarkToIndex (Bookmark);
        end
      else
        SetStr (ArrIndex, i, AnsiString (Data [i]))
    else if VarIsFloat (Data [i]) then
      if FSortIndex = i then
        begin
          SetSortFloat (ArrIndex, i, Data [i]);
          ArrIndex := BookmarkToIndex (Bookmark);
        end
      else
        SetFloat (ArrIndex, i, Data [i])
    else if VarIsOrdinal (Data [i]) then
      if FSortIndex = i then
        begin
          SetSortInt (ArrIndex, i, Data [i]);
          ArrIndex := BookmarkToIndex (Bookmark);
        end
      else
        SetInt (ArrIndex, i, Data [i])
    else if VarIsNull (Data [i]) then
      SetVariant (ArrIndex, i, Data [i])
    else
      raise ERecordList.CreateFmt (SAddRecordUnsupported, [VarType (Data [i])]);
  end;
  { Вернем результат }
  Result := ArrIndex;
end;

{ Вставка записи в отсортированный список (общие действия)}
function TRecordList.InsertKeyCommon (NewIndex: integer): integer;
var
  NewPtr: pointer;
begin
  Assert (FList <> nil);
  NewPtr := MakeNewRecord;
  FList.Insert (NewIndex, NewPtr);
  FLastIndex   := NewIndex;
  FLastAddress := NewPtr;
  Result := NewIndex;
end;

{ Вставка записи в отсортированный список }
function TRecordList.InsertKey (Key: integer): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetInt (Result, FSortIndex, Key);
end;

{ Вставка записи в отсортированный список }
function TRecordList.InsertKey (Key: pointer): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetPtr (Result, FSortIndex, Key);
end;

{ Вставка записи в отсортированный список }
function TRecordList.InsertKey (Key: AnsiString): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetStr (Result, FSortIndex, Key);
end;

{ Вставка записи в отсортированный список }
function TRecordList.InsertKey (Key: WideString): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetWideStr (Result, FSortIndex, Key);
end;

{ Вставка записи в отсортированный список }
function TRecordList.InsertKey (Key: Extended): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetFloat (Result, FSortIndex, Key);
end;

{ Вставка записи в отсортированный список }
function TRecordList.InsertKey (Key: TDateTime): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetDate (Result, FSortIndex, Key);
end;

{ Удаление элемента из массива }
procedure TRecordList.Delete (Index: integer);
var Ptr: pointer;
begin
  Ptr := RequestRecord (Index);
  FinalizeRecord (Index);
  FList.Delete (Index);
  FreeMem (Ptr, RecordSize);
  FLastIndex := -1;
end;

{ Очистка массива }
procedure TRecordList.Clear;
var i: integer;
begin
  for i := Count - 1 downto 0 do Delete (i);
end;

{ Перестановка двух элементов массива }
procedure TRecordList.Exchange (Index1, Index2: integer);
begin
  CheckSortRestricted;
  CheckRecordIndex (Index1);
  CheckRecordIndex (Index2);
  FList.Exchange (Index1, Index2);
  FLastIndex := -1;
end;

{ Перемещение записи на новое место }
procedure TRecordList.Move (IndexFrom, IndexTo: integer);
begin
  CheckSortRestricted;
  CheckRecordIndex (IndexFrom);
  CheckRecordIndex (IndexTo);
  FList.Move (IndexFrom, IndexTo);
  FLastIndex := -1;
end;

{ Поиск записи по ключу }
function TRecordList.SortIndexOf (Key: integer): integer;
begin
  Result := SortIndexOf (Key, TIntAdapter);
end;

{ Поиск записи по ключу }
function TRecordList.SortIndexOf (Key: pointer): integer;
begin
  Result := SortIndexOf (Key, TPtrAdapter);
end;

{ Поиск записи по ключу }
function TRecordList.SortIndexOf (Key: AnsiString): integer;
begin
  if FNextUsed then Key := AnsiStrings.AnsiLowerCase (Key);
  Result := SortIndexOf (Key, TStringAdapter);
end;

{ Поиск записи по ключу }
function TRecordList.SortIndexOf (Key: WideString): integer;
begin
  Result := SortIndexOf (Key, TWideStringAdapter);
end;

function TRecordList.InsertKey (Key: UnicodeString): integer;
begin
  Result := InsertKey (AnsiString (Key));
end;

function TRecordList.SortIndexOf (Key: UnicodeString): integer;
begin
  Result := SortIndexOf (AnsiString (Key));
end;

procedure TRecordList.SortIndexRange (Key: UnicodeString;
                                      out Low, High: integer);
begin
  SortIndexRange (AnsiString (Key), Low, High);
end;

{ Поиск записи по ключу }
function TRecordList.SortIndexOf (Key: TDateTime): integer;
begin
  Result := SortIndexOf (Key, TDateTimeAdapter);
end;

{ Поиск диапазона записей по ключу }
procedure TRecordList.SortIndexRange (const Key;
                                      Adapter: TRLAdapterClass;
                                      out Low, High: integer);
begin
  { Если не найдено, вернем заведомо пустой диапазон }
  Low := SortIndexOf (Key, Adapter);
  High := Low - 1;
  if Low < 0 then exit;
  { SortIndexOf возвращает одну из записей - отмотаем к концам списка }
  High := Low;
  while (Low > 0) and (Adapter.Compare (Self,
                       RequestField (Low - 1, FSortIndex)^, Key) = 0) do
    Dec (Low);
  while (High < Count - 1) and (Adapter.Compare (Self,
                                RequestField (High + 1, FSortIndex)^, Key) = 0) do
    Inc (High);
end;


{ Поиск диапазона записей по ключу }
procedure TRecordList.SortIndexRange (Key: integer;
                                      out Low, High: integer);
begin
  SortIndexRange (Key, TIntAdapter, Low, High);
end;

{ Поиск диапазона записей по ключу }
procedure TRecordList.SortIndexRange (Key: pointer;
                                      out Low, High: integer);
begin
  SortIndexRange (Key, TPtrAdapter, Low, High);
end;

{ Поиск диапазона записей по ключу }
procedure TRecordList.SortIndexRange (Key: AnsiString;
                                      out Low, High: integer);
begin
  if FNextUsed then Key := AnsiStrings.AnsiLowerCase (Key);
  SortIndexRange (Key, TStringAdapter, Low, High);
end;

{ Поиск диапазона записей по ключу }
procedure TRecordList.SortIndexRange (Key: WideString;
                                      out Low, High: integer);
begin
  SortIndexRange (Key, TWideStringAdapter, Low, High);
end;

{ Поиск диапазона записей по ключу }
procedure TRecordList.SortIndexRange (Key: TDateTime;
                                      out Low, High: integer);
begin
  SortIndexRange (Key, TDateTimeAdapter, Low, High);
end;

{ Возврат закладки по текущему индексу записи }
function TRecordList.IndexToBookmark (Index: integer): TRLBookmark;
begin
  Assert (CheckOK);
  Result := TRLBookmark (RequestRecord (Index));
end;

{ Возврат индекса по закладке }
function TRecordList.BookmarkToIndex (Bookmark: TRLBookmark): integer;
begin
  Assert (CheckOK);
  Result := FList.IndexOf (pointer (Bookmark));
end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Служебные методы                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{ Проверка готовности класса к работе }
function TRecordList.CheckOK: boolean;
begin
  Result := true;
  Assert (Self <> nil);
  if (not FlagInitOK) or not Assigned (FList) or (RecordLength <= 0) then
    raise ERecordList.CreateFmt (SInvalidClass, [Self.ClassName]);
  FlagOk := true;
end;

{ Проверка, установлена ли сортировка }
procedure TRecordList.CheckSortRequired;
begin
  if not FlagOk then CheckOK;
  if not FSortSet then raise ERecordList.Create (SSortRequired);
end;

{ Проверка, нет ли сортировки }
procedure TRecordList.CheckSortRestricted;
begin
  if not FlagOk then CheckOK;CheckOK;
  if FSortSet then raise ERecordList.Create (SSortRestricted);
end;

{ Проверка корректности индекса записи }
function TRecordList.CheckRecordIndex (ArrIndex: integer): boolean;
begin
  RequestRecord (ArrIndex);
  Result := true;
end;

{ Проверка корректности индекса свойства }
function TRecordList.CheckFieldIndex (FieldIndex: integer): boolean;
begin
  if (FieldIndex >= 0) and (FieldIndex < RecordLength)
    then Result := true
    else raise ERecordList.CreateFmt (SInvalidPropIndex, [Self.ClassName, FieldIndex]);
end;

{ Проверка несовместимости установленных режимов }
procedure TRecordList.CheckSortAutoAdd (Found: boolean);
begin
  if Found then
    raise ERecordList.Create (SSortAutoAdd);
end;

{ Возврат адреса строки данных }
function TRecordList.RequestRecord (ArrIndex: integer): pointer;
begin
  RequestRecord := RequestField (ArrIndex, 0);
end;

{ Возврат адреса поля данных }
function TRecordList.RequestField (ArrIndex, Index: integer): pointer;
var TooBig: boolean;
begin
  Assert (CheckOK);
  if ArrIndex <> FLastIndex then
  begin
    TooBig := (ArrIndex >= Count);
    if AutoAdd and TooBig then
      SetLength (ArrIndex + 1)
    else if TooBig or (ArrIndex < 0) then
      raise ERecordList.CreateFmt (SInvalidRecIndex, [ArrIndex]);
    FLastAddress := FList.List [ArrIndex];
    FLastIndex := ArrIndex;
  end;
  Assert (CheckFieldIndex (Index));
  Result := @PIntArray (FLastAddress)^ [Index];
end;

{ Выделение и подготовка памяти для новой записи }
function TRecordList.MakeNewRecord: pointer;
begin
  if not FlagOk then CheckOK;
  Result := AllocMem (RecordSize);
end;

{ Установка порядка сортировки списка }
procedure TRecordList.SetSortOrder (Index: integer;
                                    AFieldType: TRLFieldType = ftUnknown);
begin
  Assert (CheckOK and CheckFieldIndex (Index));
  if not FSortSet then CheckSortAutoAdd (AutoAdd);
  FSortFieldType := AFieldType;
  if FSortSet and (Index = FSortIndex) then exit;
  if (Count > 0) then Sort (Index, AFieldType);
  FSortIndex := Index;
  FSortSet   := true;
end;

{ Установка порядка сортировки по паре полей }
procedure TRecordList.SetSortNext (Index: integer);
begin
  SetSortOrder (Index + 1, ftString);
  FNextUsed := true;
  SortCaseInsensitive := false;
end;

{ Сброс установленного порядка сортировки }
procedure TRecordList.ClearSortOrder;
begin
  Assert (CheckOK);
  FSortSet := false;
  FSortIndex := -1; { если не сделать, AddRecord восстанавливает сортировку }
  FSortFieldType := ftUnknown;
end;

threadvar
  CmpOwner: TRecordList;
  CmpOffset: integer;
  CmpAdapter: TRLAdapterClass;

function SortCmpFunc (Item1, Item2: Pointer): Integer;
var F1, F2: pointer;
begin
  F1 := @PIntArray (Item1) [CmpOffset];
  F2 := @PIntArray (Item2) [CmpOffset];
  Result := CmpAdapter.Compare (CmpOwner, F1^, F2^);
end;

{ Сортировка по заданному полю }
procedure TRecordList.Sort (FieldIndex: integer; FieldType: TRLFieldType);
begin
  CheckSortRestricted;
  CheckFieldIndex (FieldIndex);
  CmpOwner := Self;
  CmpOffset := FieldIndex;
  case FieldType of
    ftInteger   : CmpAdapter := TIntAdapter;
    ftString    : CmpAdapter := TStringAdapter;
    ftWideString: CmpAdapter := TWideStringAdapter;
    ftDate      : CmpAdapter := TDateTimeAdapter;
    ftFloat     : CmpAdapter := TFloatAdapter;
    ftPointer   : CmpAdapter := TPtrAdapter;
    ftObject    : CmpAdapter := TPtrAdapter;
    ftComponent : CmpAdapter := TPtrAdapter;
    else raise ERecordList.Create (SInvalidSortFieldType);
  end;
  FList.Sort (SortCmpFunc);
end;

{ Поиск места для заданного значения при сортировке }
function TRecordList.SortGetIndexFor (const Value; Adapter: TRLAdapterClass): integer;
var
  Left, Right, Test, CmpResult: integer;
begin
  CheckSortRequired;
  Left := 0;
  Right := Count;
  while Left < Right do
  begin
    Test := (Left + Right) div 2;
    CmpResult := Adapter.Compare (Self, RequestField (Test, FSortIndex)^, Value);
    if CmpResult < 0 then
      Left := Test + 1
    else if CmpResult > 0 then
      Right := Test
    else
      begin
        Left := Test;
        Right := Test;
      end;
  end;
  Result := Left;
end;

{ Поиск записи по ключу }
function TRecordList.SortIndexOf (const Key; Adapter: TRLAdapterClass): integer;
var
  Index: integer;
  Field: pointer;
begin
  Result := -1;
  Index := SortGetIndexFor (Key, Adapter);
  if Index >= Count then exit;
  Field := RequestField (Index, FSortIndex);
  if Adapter.Compare (Self, Field^, Key) = 0 then Result := Index;
end;

{ Поиск места для заданного значения при сортировке по integer полю }
function TRecordList.SortGetIndexFor (Value: integer): integer;
begin
  Result := SortGetIndexFor (Value, TIntAdapter);
end;

{ Поиск места для заданного значения при сортировке по pointer полю }
function TRecordList.SortGetIndexFor (Value: pointer): integer;
begin
  Result := SortGetIndexFor (Value, TPtrAdapter);
end;

{ Поиск места для заданного значения при сортировке по строковому полю }
function TRecordList.SortGetIndexFor (Value: AnsiString): integer;
begin
  if FNextUsed then Value := AnsiStrings.AnsiLowerCase (Value);
  Result := SortGetIndexFor (Value, TStringAdapter);
end;

{ Поиск места для заданного значения при сортировке по строковому полю }
function TRecordList.SortGetIndexFor (Value: WideString): integer;
begin
  Result := SortGetIndexFor (Value, TWideStringAdapter);
end;

{ Поиск места для заданного значения при сортировке по полю даты }
function TRecordList.SortGetIndexFor (Value: TDateTime): integer;
begin
  Result := SortGetIndexFor (Value, TDateTimeAdapter);
end;

{ Создание "хранимого" списка строк }
function TRecordList.CreateStoredStrings (Index: integer): TStrings;
begin
  Result := TStringList.Create;
end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                              Методы свойств                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{ Установка режима автодобавления }
procedure TRecordList.SetAutoAdd (NewAutoAdd: boolean);
begin
  if NewAutoAdd then CheckSortAutoAdd (FSortSet);
  FAutoAdd := NewAutoAdd;
end;

{ Установка количества полей в записи }
procedure TRecordList.SetRecordLength (Len: integer);
begin
  if RecordLength = Len then exit;
  if Count > 0 then Clear;
  FRecordLen  := Len;
  FRecordSize := Len * SizeOf (Integer);
end;

{ Установка режима сортировки }
procedure TRecordList.SetSortCaseInsensitive (NewCaseInsensitive: boolean);
begin
  if FSortCaseInsensitive = NewCaseInsensitive then exit;
  if Count > 0 then raise ERecordList.Create (SRequiresEmpty);
  FSortCaseInsensitive := NewCaseInsensitive;
end;

{ Возврат значения указанного поля (integer)}
function TRecordList.GetInt (ArrIndex, Index: integer): integer;
begin
  Result := PInteger (RequestField (ArrIndex, Index))^;
end;

{ Установка значения указанного поля (integer)}
procedure TRecordList.SetInt (ArrIndex, Index, NewValue: integer);
begin
  PInteger (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ Установка значения ключевого поля (integer)}
procedure TRecordList.SetSortInt (ArrIndex, Index, NewValue: integer);
var NewRow: integer;
begin
  SetSortOrder (Index, ftInteger);
  if GetInt (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetInt (NewRow, Index, NewValue);
end;

{ Возврат значения указанного поля (Cardinal)}
function TRecordList.GetCardinal (ArrIndex, Index: integer): Cardinal;
begin
  Result := PCardinal (RequestField (ArrIndex, Index))^;
end;

{ Установка значения указанного поля (Cardinal)}
procedure TRecordList.SetCardinal (ArrIndex, Index: integer; NewValue: Cardinal);
var INewValue: integer absolute NewValue;
begin
  PCardinal (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ Возврат значения указанного поля (boolean)}
function TRecordList.GetBool (ArrIndex, Index: integer): boolean;
begin
  GetBool := (GetInt (ArrIndex, Index) <> 0);
end;

{ Установка значения указанного поля (boolean)}
procedure TRecordList.SetBool (ArrIndex, Index: integer; NewValue: boolean);
begin
  SetInt (ArrIndex, Index, Ord (NewValue));
end;

{ Возврат значения указанного поля (char)}
function TRecordList.GetChar (ArrIndex, Index: integer): AnsiChar;
var S: AnsiString;
begin
  S := GetStr (ArrIndex, Index);
  if S <> '' then Result := S [1] else Result := #0;
end;

{ Установка значения указанного поля (char)}
procedure TRecordList.SetChar (ArrIndex, Index: integer; NewValue: AnsiChar);
begin
  SetStr (ArrIndex, Index, NewValue);
end;

{ Установка значения указанного сортируемого поля (char)}
procedure TRecordList.SetSortChar (ArrIndex, Index: integer; NewValue: AnsiChar);
begin
  SetSortStr (ArrIndex, Index, NewValue);
end;

{ Возврат значения указанного поля (pointer)}
function TRecordList.GetPtr (ArrIndex, Index: integer): pointer;
begin
  Result := PPointer (RequestField (ArrIndex, Index))^;
end;

{ Установка значения указанного поля (pointer)}
procedure TRecordList.SetPtr (ArrIndex, Index: integer; NewValue: pointer);
var OldValue: pointer;
begin
  if OwnPtrFinalizer.HasField (Index) then
  begin
    OldValue := GetPtr (ArrIndex, Index);
    if OldValue = NewValue then exit;
    OwnPtrFinalizer.FinalizeField (ArrIndex, Index);
  end;
  PPointer (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ Установка значения сортируемого поля (pointer)}
procedure TRecordList.SetSortPtr (ArrIndex, Index: integer; NewValue: pointer);
var NewRow: integer;
begin
  SetSortOrder (Index, ftPointer);
  if GetPtr (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow = ArrIndex then exit;
  if NewRow > ArrIndex then Dec (NewRow);
  FList.Move (ArrIndex, NewRow);
  FLastIndex := -1;
  SetPtr (NewRow, Index, NewValue);
end;

{ Возврат значения указанного собственного поля (pointer)}
function TRecordList.GetOwnPtr (ArrIndex, Index: integer): pointer;
begin
  OwnPtrFinalizer.RegisterField (Index);
  Result := PPointer (RequestField (ArrIndex, Index))^;
end;

{ Установка значения указанного собственного поля (pointer)}
procedure TRecordList.SetOwnPtr (ArrIndex, Index: integer; NewValue: pointer);
begin
  OwnPtrFinalizer.RegisterField (Index);
  SetPtr (ArrIndex, Index, NewValue);
end;

{ Установка значения сортируемого собственного поля (pointer)}
procedure TRecordList.SetOwnSortPtr (ArrIndex, Index: integer; NewValue: pointer);
begin
  OwnPtrFinalizer.RegisterField (Index);
  SetSortPtr (ArrIndex, Index, NewValue);
end;

{ Возврат значения указанного поля (char)}
function TRecordList.GetPChar (ArrIndex, Index: integer): PChar;
begin
  Result := PChar (GetPtr (ArrIndex, Index));
end;

{ Установка значения указанного поля (char)}

procedure TRecordList.SetPChar (ArrIndex, Index: integer; NewValue: PChar);
begin
  SetPtr (ArrIndex, Index, NewValue);
end;

procedure TRecordList.SetOwnPChar (ArrIndex, Index: integer; NewValue: PChar);
begin
  SetOwnPtr (ArrIndex, Index, NewValue);
end;

{ Возврат значения указанного поля (AnsiChar)}
function TRecordList.GetPAnsiChar (ArrIndex, Index: integer): PAnsiChar;
begin
  Result := PAnsiChar (GetPtr (ArrIndex, Index));
end;

{ Установка значения указанного поля (AnsiChar)}

procedure TRecordList.SetPAnsiChar (ArrIndex, Index: integer; NewValue: PAnsiChar);
begin
  SetPtr (ArrIndex, Index, NewValue);
end;

procedure TRecordList.SetOwnPAnsiChar (ArrIndex, Index: integer; NewValue: PAnsiChar);
begin
  SetOwnPtr (ArrIndex, Index, NewValue);
end;

{ Возврат значения указанного поля (string)}
function TRecordList.GetStr (ArrIndex, Index: integer): AnsiString;
begin
  StringFinalizer.RegisterField (Index);
  Result := PAnsiString (RequestField (ArrIndex, Index))^;
end;

{ Установка значения указанного поля (string)}
procedure TRecordList.SetStr (ArrIndex, Index: integer;
                              NewValue: AnsiString);
begin
  StringFinalizer.RegisterField (Index);
  PAnsiString (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ Установка значения ключевого поля (string)}
procedure TRecordList.SetSortStr (ArrIndex, Index: integer;
                                  NewValue: AnsiString);
var NewRow: integer;
begin
  SetSortOrder (Index, ftString);
  if GetStr (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetStr (NewRow, Index, NewValue);
end;

{ Установка значения ключевой пары полей (string)}
procedure TRecordList.SetNextSortStr (ArrIndex, Index: integer; NewValue: AnsiString);
begin
  FNextUsed := true;
  SetStr (ArrIndex, Index, NewValue);
  SetSortStr (ArrIndex, Index + 1, AnsiStrings.AnsiLowerCase (NewValue));
end;

{ Возврат значения указанного поля (string)}
function TRecordList.GetWideStr (ArrIndex, Index: integer): WideString;
begin
  WideStringFinalizer.RegisterField (Index);
  Result := PWideString (RequestField (ArrIndex, Index))^;
end;

{ Установка значения указанного поля (string)}
procedure TRecordList.SetWideStr (ArrIndex, Index: integer;
                                  NewValue: WideString);
begin
  WideStringFinalizer.RegisterField (Index);
  PWideString (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ Установка значения ключевого поля (string)}
procedure TRecordList.SetSortWideStr (ArrIndex, Index: integer;
                                      NewValue: WideString);
var NewRow: integer;
begin
  SetSortOrder (Index, ftWideString);
  if GetWideStr (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetWideStr (NewRow, Index, NewValue);
end;

{ Возврат значения указанного поля (float)}
function TRecordList.GetFloat (ArrIndex, Index: integer): Extended;
var P: PExtended;
begin
  P := GetPtr (ArrIndex, Index);
  if Assigned (P) then Result := P^ else Result := 0.0;
end;

{ Установка значения указанного поля (float)}
procedure TRecordList.SetFloat (ArrIndex, Index: integer;
                                NewValue: Extended);
var P: PExtended;
begin
  P := GetPtr (ArrIndex, Index);
  if not Assigned (P) then GetMem (P, SizeOf (P^));
  P^ := NewValue;
  SetOwnPtr (ArrIndex, Index, P);
end;

{ Установка значения ключевого поля (float)}
procedure TRecordList.SetSortFloat (ArrIndex, Index: integer; NewValue: Extended);
var NewRow: integer;
begin
  SetSortOrder (Index, ftFloat);
  if GetFloat (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetFloat (NewRow, Index, NewValue);
end;

{ Возврат значения указанного поля (date)}
function TRecordList.GetDate (ArrIndex, Index: integer): TDateTime;
begin
  Result := GetFloat (ArrIndex, Index);
end;

{ Установка значения указанного поля (date)}
procedure TRecordList.SetDate (ArrIndex, Index: integer;
                               NewValue: TDateTime);
begin
  SetFloat (ArrIndex, Index, NewValue);
end;

{ Установка значения ключевого поля (date)}
procedure TRecordList.SetSortDate (ArrIndex, Index: integer;
                                   NewValue: TDateTime);
var NewRow: integer;
begin
  SetSortOrder (Index, ftDate);
  if GetDate (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetDate (NewRow, Index, NewValue);
end;

{ Возврат значения указанного поля (TObject)}
function TRecordList.GetObj (ArrIndex, Index: integer): TObject;
begin
  GetObj := TObject (GetPtr (ArrIndex, Index));
end;

{ Установка значения указанного поля (TObject)}
procedure TRecordList.SetObj (ArrIndex, Index: integer; NewObject: TObject);
var OldObject: TObject;
begin
  if OwnObjFinalizer.HasField (Index) then
  begin
    OldObject := GetObj (ArrIndex, Index);
    if OldObject = NewObject then exit;
    OwnObjFinalizer.FinalizeField (ArrIndex, Index);
  end;
  SetPtr (ArrIndex, Index, NewObject);
end;

{ Установка значения сортируемого поля (TObject)}
procedure TRecordList.SetSortObj (ArrIndex, Index: integer; NewObject: TObject);
var OldObject: TObject;
begin
  if OwnObjFinalizer.HasField (Index) then
  begin
    OldObject := GetObj (ArrIndex, Index);
    if OldObject = NewObject then exit;
    OwnObjFinalizer.FinalizeField (ArrIndex, Index);
  end;
  SetSortPtr (ArrIndex, Index, NewObject);
end;

{ Возврат значения указанного поля (TObject)}
function TRecordList.GetOwnObj (ArrIndex, Index: integer): TObject;
begin
  OwnObjFinalizer.RegisterField (Index);
  Result := GetObj (ArrIndex, Index);
end;

{ Установка значения указанного поля (TObject)}
procedure TRecordList.SetOwnObj (ArrIndex, Index: integer;
                                 NewObject: TObject);
begin
  OwnObjFinalizer.RegisterField (Index);
  SetObj (ArrIndex, Index, NewObject);
end;

{ Установка значения сортируемого поля (TObject)}
procedure TRecordList.SetSortOwnObj (ArrIndex, Index: integer; NewObject: TObject);
begin
  OwnObjFinalizer.RegisterField (Index);
  SetSortObj (ArrIndex, Index, NewObject);
end;

{ Возврат значения указанного поля (TComponent)}
function TRecordList.GetComponent (ArrIndex, Index: integer): TComponent;
begin
  Result := TComponent (GetObj (ArrIndex, Index));
end;

{ Установка значения указанного поля (TComponent)}
procedure TRecordList.SetComponent (ArrIndex, Index: integer;
                                    NewComponent: TComponent);
begin
  SetObj (ArrIndex, Index, NewComponent);
end;

{ Установка значения сортируемого поля (TComponent)}
procedure TRecordList.SetSortComponent (ArrIndex, Index: integer;
                                        NewComponent: TComponent);
begin
  SetSortObj (ArrIndex, Index, NewComponent);
end;

{ Возврат значения указанного поля (TStrings)}
function TRecordList.GetStrings (ArrIndex, Index: integer): TStrings;
begin
  Result := TStrings (GetObj (ArrIndex, Index));
end;

{ Установка значения указанного поля (TStrings)}
procedure TRecordList.SetStrings (ArrIndex, Index: integer;
                                   NewStrings: TStrings);
begin
  SetObj (ArrIndex, Index, NewStrings);
end;

{ Установка значения указанного поля (TStrings)}
procedure TRecordList.SetOwnStrings (ArrIndex, Index: integer;
                                      NewStrings: TStrings);
begin
  SetOwnObj (ArrIndex, Index, NewStrings);
end;

{ Возврат значения поля (хранимый TStrings)}
function TRecordList.GetStoredStrings (ArrIndex, Index: integer): TStrings;
begin
  Result := GetStrings (ArrIndex, Index);
  if Assigned (Result) then exit;
  Result := CreateStoredStrings (Index);
  SetOwnObj (ArrIndex, Index, Result);
end;

{ Установка значения поля (хранимый TStrings)}
procedure TRecordList.SetStoredStrings (ArrIndex, Index: integer;
                                         NewStrings: TStrings);
begin
  GetStoredStrings (ArrIndex, Index).Assign (NewStrings);
end;

{ Возврат значения указанного поля (Icon)}
function TRecordList.GetIcon (ArrIndex, Index: integer): TIcon;
begin
  Result := TIcon (GetObj (ArrIndex, Index));
end;

{ Установка значения указанного поля (Icon)}
procedure TRecordList.SetIcon (ArrIndex, Index: integer; NewIcon: TIcon);
begin
  SetObj (ArrIndex, Index, NewIcon);
end;

{ Возврат значения указанного поля (Icon)}
function TRecordList.GetOwnIcon (ArrIndex, Index: integer): TIcon;
begin
  Result := TIcon (GetOwnObj (ArrIndex, Index));
end;

{ Установка значения указанного поля (Icon)}
procedure TRecordList.SetOwnIcon (ArrIndex, Index: integer; NewIcon: TIcon);
begin
  SetOwnObj (ArrIndex, Index, NewIcon);
end;

{ Возврат значения поля (class) }
function TRecordList.GetClass (ArrIndex, Index: integer): TClass;
begin
  Result := TClass (GetPtr (ArrIndex, Index));
end;

{ Установка значения поля (class)}
procedure TRecordList.SetClass (ArrIndex, Index: integer; NewValue: TClass);
begin
  SetPtr (ArrIndex, Index, NewValue);
end;

{ Установка значения сортируемого поля (class)}
procedure TRecordList.SetSortClass (ArrIndex, Index: integer; NewValue: TClass);
begin
  SetSortPtr (ArrIndex, Index, NewValue);
end;

{ Возврат значения поля (interface)}
function TRecordList.GetInterface (ArrIndex, Index: integer): IInterface;
begin
  Result := PInterface (RequestField (ArrIndex, Index))^;
end;

{ Установка значения поля (interface)}
procedure TRecordList.SetInterface (ArrIndex, Index: integer;
                                     NewInterface: IInterface);
begin
  IntfFinalizer.RegisterField (Index);
  PInterface (RequestField (ArrIndex, Index))^ := NewInterface;
end;

{ Возврат значения поля (TControl)}
function TRecordList.GetControl (ArrIndex, Index: integer): TControl;
begin
  Result := TControl (GetObj (ArrIndex, Index));
end;

{ Установка значения поля (TControl)}
procedure TRecordList.SetControl (ArrIndex, Index: integer;
                                   NewControl: TControl);
begin
  SetObj (ArrIndex, Index, NewControl);
end;

type
  PNotifyEvent = ^TNotifyEvent;

{ Возврат значения поля (TNotifyEvent)}
function TRecordList.GetNotifyEvent (ArrIndex, Index: integer): TNotifyEvent;
var P: PNotifyEvent;
begin
  Result := nil;
  P := GetPtr (ArrIndex, Index);
  if Assigned (P) then Result := P^;
end;

{ Установка значения поля (TNotifyEvent)}
procedure TRecordList.SetNotifyEvent (ArrIndex, Index: integer;
                                      NewEvent: TNotifyEvent);
var P: PNotifyEvent;
begin
  if @NewEvent = nil then
    SetOwnPtr (ArrIndex, Index, nil)
  else
    begin
      P := GetPtr (ArrIndex, Index);
      if not Assigned (P) then
      begin
        GetMem (P, SizeOf (TNotifyEvent));
        SetOwnPtr (ArrIndex, Index, P);
      end;
      P^ := NewEvent;
    end;
end;                                          

{ Возврат значения поля (TShiftState)}
function TRecordList.GetShiftState (ArrIndex, Index: integer): TShiftState;
begin
  word (Result) := LoWord (GetInt (ArrIndex, Index));
end;

{ Установка значения поля (TShiftState)}
procedure TRecordList.SetShiftState (ArrIndex, Index: integer; NewShift: TShiftState);
begin
  SetInt (ArrIndex, Index, word (NewShift));
end;

{ Возврат значения поля (variant)}
function TRecordList.GetVariant (ArrIndex, Index: integer): variant;
var Ptr: PVariant;
begin
  Result := Null;
  VariantFinalizer.RegisterField (Index);
  Ptr := PPVariant (RequestField (ArrIndex, Index))^;
  if Assigned (Ptr) then Result := Ptr^ else Result := Unassigned;
end;

{ Установка значения поля (variant)}
procedure TRecordList.SetVariant (ArrIndex, Index: integer; NewVariant: variant);
var Ptr: PPVariant;
begin
  VariantFinalizer.RegisterField (Index);
  Ptr := RequestField (ArrIndex, Index);
  if VarType (NewVariant) = varEmpty then
    begin
      if not Assigned (Ptr^) then exit;
      Ptr^^ := Unassigned;
      Dispose (Ptr^);
      Ptr^ := nil;
    end
  else
    begin
      if Ptr^ = nil then New (Ptr^);
      Ptr^^ := NewVariant;
    end;
end;

{ Освобождение памяти, занятой строковыми значениями }
procedure TRecordList.FinalizeRecord (ArrIndex: integer);
begin
  StringFinalizer.FinalizeRecord (ArrIndex);
  WideStringFinalizer.FinalizeRecord (ArrIndex);
  OwnObjFinalizer.FinalizeRecord (ArrIndex);
  IntfFinalizer.FinalizeRecord (ArrIndex);
  VariantFinalizer.FinalizeRecord (ArrIndex);
  OwnPtrFinalizer.FinalizeRecord (ArrIndex);
end;

{ TRLFinalizer }

constructor TRLFinalizer.Create (AOwner: TRecordList);
begin
  Assert (AOwner <> nil);
  inherited Create;
  Owner := AOwner;
end;

procedure TRLFinalizer.FinalizeRecord (ArrIndex: integer);
var i: integer;
begin
  for i := 0 to Size - 1 do
    if Bits [i] then FinalizeField (ArrIndex, i);
end;

procedure TRLFinalizer.FinalizeField (ArrIndex, Index: integer);
begin
  if HasField (Index) then FinalizeFieldImpl (ArrIndex, Index);
end;

function TRLFinalizer.HasField (Index: integer): boolean;
begin
  Result := (Index < Size) and Bits [Index];
end;

procedure TRLFinalizer.RegisterField (Index: integer);
begin
  if Owner.CheckFieldIndex (Index) then Bits [Index] := true;
end;

{ TStringFinalizer }

procedure TStringFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.SetStr (ArrIndex, Index, '');
end;

{ TWideStringFinalizer }

procedure TWideStringFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.SetWideStr (ArrIndex, Index, '');
end;

{ TOwnObjFinalizer }

procedure TOwnObjFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.GetObj (ArrIndex, Index).Free;
end;

{ TIntfFinalizer }

procedure TIntfFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.SetInterface (ArrIndex, Index, nil);
end;

{ TVariantFinalizer }

procedure TVariantFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.SetVariant (ArrIndex, Index, Unassigned);
end;

{ TOwnPtrFinalizer }

procedure TOwnPtrFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  FreeMem (Owner.GetPtr (ArrIndex, Index));
end;

{ TIntAdapter }

class function TIntAdapter.Compare (Owner: TRecordList;
                                    const Left, Right): integer;
var
  ILeft: integer absolute Left;
  IRight: integer absolute Right;
begin
  Result := ILeft - IRight;
end;

{ TPtrAdapter }

class function TPtrAdapter.Compare (Owner: TRecordList;
                                    const Left, Right): integer;
begin
  Result := TIntAdapter.Compare (Owner, Left, Right);                                    
end;

{ TDateTimeAdapter }

class function TDateTimeAdapter.Compare (Owner: TRecordList;
                                         const Left, Right): integer;
var
  DLeft: ^Extended absolute Left;
  DRight: TDateTime absolute Right;
  Cmp: Extended;
begin
  if DLeft = nil then Cmp := -DRight else Cmp := DLeft^ - DRight;
  if Cmp < 0 then
    Result := -1
  else if Cmp > 0 then
    Result := 1
  else
    Result := 0;
end;

{ TFloatAdapter }

class function TFloatAdapter.Compare (Owner: TRecordList;
                                         const Left, Right): integer;
var
  FLeft: ^Extended absolute Left;
  FRight: ^Extended absolute Right;
begin
  if FLeft^ < FRight^ then
    Result := -1
  else if FLeft^ > FRight^ then
    Result := 1
  else
    Result := 0;
end;

{ TStringAdapter }

class function TStringAdapter.Compare (Owner: TRecordList;
                                       const Left, Right): integer;
var
  SLeft: AnsiString absolute Left;
  SRight: AnsiString absolute Right;
  TLeft, TRight: AnsiString;
begin
  if Owner.SortCaseInsensitive then
    begin
      TLeft := AnsiStrings.AnsiLowerCase (SLeft);
      TRight := AnsiStrings.AnsiLowerCase (SRight);
    end
  else
    begin
      TLeft := SLeft;
      TRight := SRight;
    end;
  if TLeft < TRight then
    Result := -1
  else if TLeft > TRight then
    Result := 1
  else
    Result := 0;
end;

{ TWideStringAdapter }

class function TWideStringAdapter.Compare (Owner: TRecordList;
                                           const Left, Right): integer;
var
  SLeft: WideString absolute Left;
  SRight: WideString absolute Right;
  TLeft, TRight: WideString;
begin
  if Owner.SortCaseInsensitive then
    begin
      TLeft := WideLowerCase (SLeft);
      TRight := WideLowerCase (SRight);
    end
  else
    begin
      TLeft := SLeft;
      TRight := SRight;
    end;
  if TLeft < TRight then
    Result := -1
  else if TLeft > TRight then
    Result := 1
  else
    Result := 0;
end;

{ TRLList }

procedure TRLList.Notify (Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if (Action <> lnAdded) and Assigned (Owner) and Assigned (Owner.FOnDelete) then
    Owner.FOnDelete (Owner);
end;

initialization
  Assert (SizeOf (Cardinal)   = SizeOf (integer));
  Assert (SizeOf (pointer)    = SizeOf (integer));
  Assert (SizeOf (AnsiString) = SizeOf (integer));
  Assert (SizeOf (WideString) = SizeOf (integer));
end.

