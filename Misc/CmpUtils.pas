////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                   Подпрограммы для работы с компонентами                   //
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

{ ----- История модуля ---------------------------------------------------------

??.??.2006 Несколько разрозненных подпрограмм собраны в модуль CmpUtils. Период
           недокументированного развития.

01.05.2008 Модуль серьезно переработан и подготовлен к выкладыванию в свободный
           доступ. Класс EComponentException переименован в EComponent.
           Добавлены методы HandlerOwned, HandlerOwnedBy. Добавлен модуль
           FreeNotifier и функция FreeNotifier для доступа к нему. EComponent
           использует FreeNotifier, чтобы проконтролировать возможное
           уничтожение компонента в ходе обработки исключений.
15.05.2008 Добавлены макропеременные Restrict_ExUtils и Restrict_FreeNotifier.

------------------------------------------------------------------------------ }

{ ----- Макропеременные --------------------------------------------------------

Внесите в опции проекта определение макропеременной Restrict_ExUtils, если
у Вас нет модуля ExUtils, и Вы не собираетесь его подключать. При этом классы
исключений модуля окажутся унаследованными непосредственно от Exception. 

Внесите в опции проекта определение макропеременной Restrict_FreeNotifier, если
у Вас нет модуля FreeNotifier, и Вы не собираетесь его подключать. При этом
из модуля окажется убранной функция FreeNotifier, предоставляющая доступ к
функционалу этого модуля, а класс EComponent потеряет способность корректно
реагировать на уничтожение компонента в процессе обработки исключения (скажем,
вследствие срабатывания секции finally)

Я советую вносить такие определения в настройки проекта, а не в текст модулей.
Причин для этого две:

1. Последующие обновления с моего сайта не затрут Ваши изменения
2. Настройка в опциях проекта будет действовать для всех моих файлов, не требуя
   модификации каждого.

------------------------------------------------------------------------------ }

unit CmpUtils;

interface

uses Classes, SysUtils, Forms, Dialogs
  {$IfNDef Restrict_ExUtils}, ExUtils {$EndIf}
  {$IfNDef Restrict_FreeNotifier}, FreeNotifier {$EndIf};

type

  { Действия функции CreateComponent в случае ошибки }
  TCreateComponentErrorAction = (eaDefault, eaResult, eaMessage, eaException);

  { Возможные ошибки }

  {$IfDef Restrict_ExUtils}
  EApplication = Exception;
  EModule = Exception;
  {$EndIf} 

  EFormSurplus = class (EApplication);
  EFormNotFound = class (EApplication);

  { Класс для ошибок, привязанных к компонентам }
  EComponent = class (EModule)
  private
    FComponent: TComponent;
    {$IfNDef Restrict_FreeNotifier}
    FComponentFreed: boolean;
    procedure FreeComponentHandler (AComponent: TComponent);
    {$EndIf}
  public
    constructor Create (AComponent: TComponent; const AMessage: string);
    constructor CreateFmt (AComponent: TComponent; const AMessage: string;
                                                   const Params: array of const);
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  public
    property Component: TComponent read FComponent;
    {$IfNDef Restrict_FreeNotifier}
    property ComponentFreed: boolean read FComponentFreed;
    {$EndIf}
  end;

{ Создание объекта указанного типа, если это возможно }
function CreateComponent (var ComponentCreated;
                          Owner: TComponent;
                          ClassName, DefaultName: string;
                          ErrorAction: TCreateComponentErrorAction): boolean;

{ Формирование строки "полного имени" компонента }
function FormatComponentName (Component: TComponent): string;

{ Присвоение компоненту имени, уникального в пределах владельца }
procedure UniqueComponentName (Component: TComponent;
                               DefaultName: string = '');

{ Сравнение двух обработчиков событий на равенство }
function EqualHandlers (const First, Second): boolean;

{ Получение владельца указанного обработчика событий }
function HandlerOwner (const Handler): TObject;

{ Проверка того, что обработчик события принадлежит указанному компоненту }
function HandlerOwnedBy (const Handler; AOwner: TObject): boolean;

{ Поиск формы по имени формы и/или имени класса }
function FormByName (const AName, AClassName: string): TForm;

{$IfNDef Restrict_FreeNotifier}
{ Функция для доступа к менеджеру оповещений об уничтожении компонент }
function FreeNotifier: TFreeNotifier;
{$EndIf}

implementation

resourcestring
  SCantCreate   = 'Не удалось создать компонент [%s] - класс не найден';
  SFormSurplus  = 'Критериям поиска соответствуют сразу несколько форм';
  SFormNotFound = 'Ни одна форма не соответствует критериям поиска';
  SComponent    = 'Компонент';

{ Формирование строки "полного имени" компонента }
function FormatComponentName (Component: TComponent): string;
var
  Prefix: string;
  Exists: boolean;
begin
  Exists := Assigned (Component);
  if Exists and Assigned (Component.Owner)
    then Prefix := FormatComponentName (Component.Owner) + '.'
    else Prefix := '';
  if Exists
    then Result := Component.Name
    else Result := '(nil)';
  if Result = '' then
    Result := Format ('%s ($%p)', [Component.ClassName, pointer (Component)]);
  Result := Prefix + Result;
end;

{ Присвоение компоненту имени, уникального в пределах владельца }
procedure UniqueComponentName (Component: TComponent;
                               DefaultName: string = '');
var
  i: integer;
  NewName: string;
begin
  if not Assigned (Component) then exit;
  if DefaultName = '' then DefaultName := Copy (Component.ClassName, 2, 1000);
  i := 0;
  NewName := DefaultName;
  if Assigned (Component.Owner) then
    while Component.Owner.FindComponent (NewName) <> nil do
    begin
      Inc (i);
      NewName := Format ('%s%d', [DefaultName, i]);
    end;
  Component.Name := NewName;
end;

{ Сравнение двух обработчиков событий на равенство }
function EqualHandlers (const First, Second): boolean;
var
  M1: TMethod absolute First;
  M2: TMethod absolute Second;
begin
  Result := (M1.Code = M2.Code) and (M1.Data = M2.Data);
end;

{ Получение владельца указанного обработчика событий }
function HandlerOwner (const Handler): TObject;
var M: TMethod absolute Handler;
begin
  Result := TObject (M.Data);
end;

{ Проверка того, что обработчик события принадлежит указанному компоненту }
function HandlerOwnedBy (const Handler; AOwner: TObject): boolean;
var M: TMethod absolute Handler;
begin
  Result := (HandlerOwner (Handler) = AOwner);
end;

{ Создание объекта указанного типа, если это возможно }
function CreateComponent (var ComponentCreated;
                          Owner: TComponent;
                          ClassName, DefaultName: string;
                          ErrorAction: TCreateComponentErrorAction): boolean;
var
  Component     : TComponent absolute ComponentCreated;
  ComponentClass: TComponentClass;
  Msg           : string;
begin
  Component := nil;
  Result    := false;
  { Найдем подходящий класс }
  ComponentClass := TComponentClass (GetClass (ClassName));
  if not Assigned (ComponentClass) then
  begin
    Msg := Format (SCantCreate, [ClassName]);
    if ErrorAction = eaDefault then
      if Assigned (Owner) and (csDesigning in Owner.ComponentState)
        then ErrorAction := eaMessage
        else ErrorAction := eaException;
    case ErrorAction of
      eaMessage  : MessageDlg (Msg, mtError, [mbOk], 0);
      eaException: raise EClassNotFound.Create (Msg);
    end;
    exit;
  end;
  { Создадим компонент }
  Component := ComponentClass.Create (Owner);
  UniqueComponentName (Component, DefaultName);
  Result := true;
end;

{ Поиск формы по имени формы и/или имени класса }
function FormByName (const AName, AClassName: string): TForm;
var i: integer;
begin
  Result := nil;
  with Screen do
    for i := 0 to FormCount - 1 do
      if ((AName = '') or SameText (AName, Forms [i].Name)) and
         ((AClassName = '') or SameText (AClassName, Forms [i].ClassName)) then
      begin
        if Assigned (Result) then raise EFormSurplus.Create (SFormSurplus);
        Result := Forms [i];
      end;
  if not Assigned (Result) then raise EFormNotFound.Create (SFormNotFound);
end;

{$IfNDef Restrict_FreeNotifier}
{ Функция для доступа к менеджеру оповещений об уничтожении компонент }
function FreeNotifier: TFreeNotifier;
begin
  {$Warnings Off}
  Result := TFreeNotifier.Create;
  {$Warnings On}
end;
{$EndIf}

{ EComponent }

procedure EComponent.AfterConstruction;
begin
  inherited;
  {$IfNDef Restrict_ExUtils}
  AddParam (SComponent, FComponent);
  {$EndIf}
  {$IfNDef Restrict_FreeNotifier}
  FreeNotifier.AddListener (FreeComponentHandler, FComponent);
  {$EndIf}
end;

procedure EComponent.BeforeDestruction;
begin
  {$IfNDef Restrict_FreeNotifier}
  FreeNotifier.RemoveAllListeners (Self);
  {$EndIf}
  inherited;
end;

constructor EComponent.CreateFmt (AComponent: TComponent;
                                  const AMessage: string;
                                  const Params: array of const);
begin
  FComponent := AComponent;
  inherited CreateFmt (AMessage, Params);
end;

constructor EComponent.Create (AComponent: TComponent;
                               const AMessage: string);
begin
  FComponent := AComponent;
  inherited Create (AMessage);
end;

{$IfNDef Restrict_FreeNotifier}
procedure EComponent.FreeComponentHandler (AComponent: TComponent);
begin
  if AComponent <> FComponent then exit;
  FComponentFreed := true;
  FComponent := nil;
end;
{$EndIf}

end.
