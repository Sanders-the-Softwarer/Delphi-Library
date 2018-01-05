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

В этом файле находится класс TRuledLayout - базовый класс для алгоритмов
выравнивания, поддерживающих ввод дополнительной информации о размещении каждого
из дочерних компонент.

Дополнительная информация поддерживается в виде так называемых правил -
объектов, привязанных к каждому дочернему контролу и задающих свойства его
размещения. Наследники этого базового класса должны определять свои классы
правил с необходимым им набором свойств.

------------------------------------------------------------------------------ }

unit RuledLayout ;

{$I '..\..\options.inc'}

interface

uses SysUtils, Classes, Controls, BaseLayout ;

type

  TRuledLayout = class ;
  TLayoutRule  = class ;
  TLayoutRules = class ;
  TLayoutRuleClass = class of TLayoutRule ;
  TLayoutRulesClass = class of TLayoutRules ;

  { Базовый класс для правил выравнивания }
  TLayoutRule = class ( TCollectionItem )
  private
    FRules : TLayoutRules ;
    FControl : TControl ;
  protected
    function GetDisplayName : string ; override ;
    procedure SetControl ( NewControl : TControl ) ;
  public
    constructor Create ( Collection : TCollection ) ; override ;
    function Rules  : TLayoutRules ;
    function Layout : TRuledLayout ;
    procedure Assign ( Source : TPersistent ) ; override ;
    procedure AssignFrom ( Source : TPersistent ) ; dynamic ; abstract ;
  published
    property Control : TControl read FControl write SetControl ;
  end ;

  { Коллекция, хранящая правила выравнивания }
  TLayoutRules = class ( TOwnedCollection )
  private
    FLayout : TRuledLayout ;
    FlagChangeEnabled : boolean ;
  protected
    function RuleClass : TLayoutRuleClass ; dynamic ;
    function GetItem ( Index : integer ) : TLayoutRule ;
    procedure Notify ( Item : TCollectionItem ;
                       Action : TCollectionNotification ) ; override ;
  public
    constructor Create ( AOwner : TPersistent ) ; dynamic ;
    procedure CreateRuleFor ( AControl : TControl ) ; dynamic ;
    procedure ClearEmpty ;
    procedure DropByControl ( AControl : TControl ) ;
    function FindByControl ( AControl : TControl ) : TLayoutRule ;
  public
    property Layout : TRuledLayout read FLayout ;
    property Items [ Index : integer ] : TLayoutRule read GetItem ; default ;
  end ;

  { Базовый класс для панелей с дополнительным описанием компонент }
  TRuledLayout = class ( TLayout )
  private
    FRules : TLayoutRules ;
    ControlAdding, ControlDeleting : TControl ;
  protected
    { Доопределение методов родительских классов }
    procedure ControlAdded ( AControl : TControl ) ; override ;
    procedure ControlRemoved ( AControl : TControl ) ; override ;
    procedure DoBeforeLayout ; override ;
    { Методы, предназначенные к перекрытию в потомках }
    function RulesClass : TLayoutRulesClass ; dynamic ;
    function RuleClass : TLayoutRuleClass ; dynamic ;
    { Методы свойств }
    procedure SetRules ( NewRules : TLayoutRules ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
    { Функции интерфейса с правилами }
    function IsAdding ( out AControl : TControl ) : boolean ;
    function IsDeleting ( AControl : TControl ) : boolean ;
  published
    property Rules : TLayoutRules read FRules write SetRules ;
  end ;

implementation

resourcestring
  SCantAddRule    = 'Нельзя добавлять правила. Для добавления правила ' +
                    'положите на layout-компонент новый элемент управления' ;
  SCantDropRule   = 'Нельзя удалять правила; вместо этого перенесите или ' +
                    'удалите компонент, описываемый правилом' ;
  SCantSetControl = 'Нельзя переадресовать правило на другой компонент. ' +
                    'Положите его на layout-панель и настройте для него ' +
                    'его собственное правило' ;

{ TRuledLayout }

constructor TRuledLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  FRules := RulesClass.Create ( Self ) ;
end ;

destructor TRuledLayout.Destroy ;
begin
  inherited ;
  FreeAndNil ( FRules ) ;
end ;

{ Функции интерфейса с правилами }

function TRuledLayout.IsAdding ( out AControl : TControl ) : boolean ;
begin
  AControl := ControlAdding ;
  Result := ( AControl <> nil ) ;
end ;

function TRuledLayout.IsDeleting ( AControl : TControl ) : boolean ;
begin
  Result := ( ControlDeleting = AControl ) ;
end ;

{ Возврат класса коллекции, работающей с компонентом }
function TRuledLayout.RulesClass : TLayoutRulesClass ;
begin
  Result := TLayoutRules ;
end ;

{ Возврат класса элемента коллекции правил }
function TRuledLayout.RuleClass : TLayoutRuleClass ;
begin
  Result := TLayoutRule ;
end ;

{ Реакция на добавление компонент }
procedure TRuledLayout.ControlAdded ( AControl : TControl ) ;
begin
  inherited ;
  try
    ControlAdding := AControl ;
    Rules.Add ;
  finally
    ControlAdding := nil ;
  end ;
end ;

{ Реакция на удаление компонент }
procedure TRuledLayout.ControlRemoved ( AControl : TControl ) ;
begin
  inherited ;
  try
    ControlDeleting := AControl ;
    Rules.DropByControl ( AControl ) ;
  finally
    ControlDeleting := nil ;
  end ;
end ;

{ Удаление пустых правил, которые какой-нибудь идиот мог добавить в IDE }
procedure TRuledLayout.DoBeforeLayout ;
begin
  if not IsLoading then Rules.ClearEmpty ;
  inherited ;
end ;

{ Методы свойств }

procedure TRuledLayout.SetRules ( NewRules : TLayoutRules ) ;
begin
  FRules.Assign ( NewRules ) ;
end ;

{ TLayoutRules }

constructor TLayoutRules.Create ( AOwner : TPersistent ) ;
begin
  FLayout := AOwner as TRuledLayout ;
  inherited Create ( AOwner, RuleClass ) ;
end ;

{ Создание правила для отображения добавленного компонента }
procedure TLayoutRules.CreateRuleFor ( AControl : TControl ) ;
var NewRule : TLayoutRule ;
begin
  try
    FlagChangeEnabled := true ;
    NewRule := Add as TLayoutRule ;
    NewRule.Control := AControl ;
  finally
    FlagChangeEnabled := false ;
  end ;
end ;

{ Очистка от пустых правил. Обычно их нет, но кто-нибудь может добавить в IDE }
procedure TLayoutRules.ClearEmpty ;
var i : integer ;
begin
  for i := Count - 1 downto 0 do
    if Items [ i ].Control = nil then Items [ i ].Free ;
end ;

{ Удаление записи о компоненте }
procedure TLayoutRules.DropByControl ( AControl : TControl ) ;
begin
  try
    FlagChangeEnabled := true ;
    FindByControl ( AControl ).Free ;
  finally
    FlagChangeEnabled := false ;
  end ;
end ;

{ Поиск доп. информации по компоненту }
function TLayoutRules.FindByControl ( AControl : TControl ) : TLayoutRule ;
var i : integer ;
begin
  Result := nil ;
  for i := Count - 1 downto 0 do
    if Items [ i ].Control = AControl then Result := Items [ i ] ;
end ;

{ Возврат класса дополнительной информации }
function TLayoutRules.RuleClass : TLayoutRuleClass ;
begin
  Result := Layout.RuleClass ;
end ;

{ Свойство Items }
function TLayoutRules.GetItem ( Index : integer ) : TLayoutRule ;
begin
  Result := inherited Items [ Index ] as TLayoutRule ;
end ;

{ Реакция на создание или удаление правила }
procedure TLayoutRules.Notify ( Item : TCollectionItem ;
                                Action : TCollectionNotification ) ;
var
  Rule : TLayoutRule absolute Item ;
  AControl : TControl ;
begin
  Assert ( Layout <> nil ) ;
  Assert ( Item <> nil ) ;
  Assert ( Item is TLayoutRule ) ;
  { Разрешаем удаление вместе с Layout-ом }
  if Layout.IsDestroying then exit ;
  { Разрешаем удаление пустых правил }
  if ( Action = cnExtracting ) and ( Rule.Control = nil ) then exit ;
  { Разрешаем загрузку из dfm }
  if ( Action = cnAdded ) and Layout.IsLoading then exit ;
  { Разрешаем создание правила для добавляемого компонента }
  if ( Action = cnAdded ) and Layout.IsAdding ( AControl ) then
  begin
    Rule.FControl := AControl ;
    exit ;
  end ;
  { Разрешаем удаление правила для удаляемого компонента }
  if ( Action = cnDeleting ) and Layout.IsDeleting ( Rule.Control ) then exit ;
  { Иначе - ругаемся }
  case Action of
    cnAdded : raise ELayout.Create ( Layout, SCantAddRule ) ;
    else      raise ELayout.Create ( Layout, SCantDropRule ) ;
  end ;
end ;

{ TLayoutRule }

constructor TLayoutRule.Create ( Collection : TCollection ) ;
begin
  inherited ;
  FRules := Collection as TLayoutRules ;
end ;

{ Возврат владеющей коллекции }
function TLayoutRule.Rules : TLayoutRules ;
begin
  Result := FRules ;
end ;

{ Возврат владеющего компонента }
function TLayoutRule.Layout : TRuledLayout ;
begin
  Result := Rules.Layout ;
end ;

{ Копирование свойств объекта }
procedure TLayoutRule.Assign ( Source : TPersistent ) ;
begin
  if Self.ClassType = Source.ClassType
    then AssignFrom ( Source )
    else inherited ;
end ;

{ Возврат имени компонента для Object Inspector }
function TLayoutRule.GetDisplayName : string ;
begin
  if Assigned ( FControl )
    then Result := FControl.Name
    else Result := inherited GetDisplayName ;
end ;

{ Привязка правила к компоненту }
procedure TLayoutRule.SetControl ( NewControl : TControl ) ;
begin
  Assert ( Layout <> nil ) ;
  if Layout.IsLoading
    then FControl := NewControl
    else raise ELayout.Create ( Layout, SCantSetControl ) ;
end ;

end.

