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

unit ConstraintedLayout ;

interface

uses SysUtils, Classes, Controls, BaseLayout, LayoutMisc ;

type

  TLayoutConstraint = class ;
  TLayoutConstraints = class ;
  TLayoutConstraintClass = class of TLayoutConstraint ;
  TLayoutConstraintsClass = class of TLayoutConstraints ;

  { Базовый класс для дополнительной информации }
  TLayoutConstraint = class ( TCollectionItem )
  private
    FControl : TControl ;
  protected
    function GetDisplayName : string ; override ;
    procedure SetControl ( NewControl : TControl ) ;
  public
    function Constraints : TLayoutConstraints ;
    function Layout : TLayout ;
  published
    property Control : TControl read FControl write SetControl ;
  end ;

  { Коллекция, хранящая дополнительные свойства компонент }
  TLayoutConstraints = class ( TOwnedCollection )
  protected
    function ItemClass : TLayoutConstraintClass ; dynamic ;
    function GetItem ( Index : integer ) : TLayoutConstraint ;
  public
    constructor Create ( AOwner : TPersistent ) ; virtual ;
    procedure UpdateConstraints ;
    function FindByControl ( AControl : TControl ) : TLayoutConstraint ;
    function Layout : TLayout ;
  public
    property Items [ Index : integer ] : TLayoutConstraint read GetItem ; default ;
  end ;

  { Базовый класс для панелей с дополнительным описанием компонент }
  TConstraintedLayout = class ( TLayout )
  private
    FConstraints : TLayoutConstraints ;
  protected
    { Доопределение методов родительских классов }
    procedure DoBeforeLayout ; override ;
    { Методы, предназначенные к перекрытию в потомках }
    function ConstraintsClass : TLayoutConstraintsClass ; dynamic ;
    { Методы свойств }
    procedure SetConstraints ( NewConstraints : TLayoutConstraints ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
  protected
    property Constraints : TLayoutConstraints read FConstraints write SetConstraints ;
  end ;

implementation

{ TConstraintedLayout }

constructor TConstraintedLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  FConstraints := ConstraintsClass.Create ( Self ) ;
end ;

destructor TConstraintedLayout.Destroy ;
begin
  FreeAndNil ( FConstraints ) ;
  inherited ;
end ;

{ Возврат класса коллекции, работающей с компонентом }
function TConstraintedLayout.ConstraintsClass : TLayoutConstraintsClass ;
begin
  Result := TLayoutConstraints ;
end ;

{ Обновление списка доп. информации о компонентах перед выравниванием }
procedure TConstraintedLayout.DoBeforeLayout ;
begin
  inherited ;
  FConstraints.UpdateConstraints ;
end ;

{ Методы свойств }

procedure TConstraintedLayout.SetConstraints ( NewConstraints : TLayoutConstraints ) ;
begin
end ;

{ TLayoutConstraints }

constructor TLayoutConstraints.Create ( AOwner : TPersistent ) ;
begin
  inherited Create ( AOwner, ItemClass ) ;
end ;

{ Приведение списка ограничений в соответствие списку компонент }
procedure TLayoutConstraints.UpdateConstraints ;
var
  List : TControlList ;
  i : integer ;
begin
  if Layout.IsLoading then exit ;
  List := Layout.ListControls ( false ) ;
  try
    { Уничтожим информацию об удаленных с окна компонентах }
    for i := Count - 1 downto 0 do
      if List.IndexOf ( Items [ i ].Control ) < 0
        then Delete ( i ) ;
    { Создадим элементы для добавленных компонент }
    for i := 0 to List.Count - 1 do
      if FindByControl ( List [ i ]) = nil then
        TLayoutConstraint ( Self.Add ).Control := List [ i ] ;
  finally
    FreeAndNil ( List ) ;
  end ;
end ;

{ Поиск доп. информации по компоненту }
function TLayoutConstraints.FindByControl ( AControl : TControl ) : TLayoutConstraint ;
var i : integer ;
begin
  Result := nil ;
  for i := Count - 1 downto 0 do
    if Items [ i ].Control = AControl then Result := Items [ i ] ;
end ;

{ Возврат владеющего компонента }
function TLayoutConstraints.Layout : TLayout ;
begin
  Result := Owner as TLayout ;
end ;

{ Возврат класса дополнительной информации }
function TLayoutConstraints.ItemClass : TLayoutConstraintClass ;
begin
  Result := TLayoutConstraint ;
end ;

{ Методы свойств }

function TLayoutConstraints.GetItem ( Index : integer ) : TLayoutConstraint ;
begin
  Result := inherited Items [ Index ] as TLayoutConstraint ;
end ;

{ TLayoutConstraint }

{ Возврат владеющей коллекции }
function TLayoutConstraint.Constraints : TLayoutConstraints ;
begin
  Result := Collection as TLayoutConstraints ;
end ;

{ Возврат владеющего компонента }
function TLayoutConstraint.Layout : TLayout ;
begin
  Result := Collection.Owner as TLayout ;
end ;

{ Возврат имени компонента для Object Inspector }
function TLayoutConstraint.GetDisplayName : string ;
begin
  if Assigned ( FControl )
    then Result := FControl.Name
    else Result := inherited GetDisplayName ;
end ;

procedure TLayoutConstraint.SetControl ( NewControl : TControl ) ;
begin
  if FControl = NewControl then exit ;
  Constraints.FindByControl ( NewControl ).Free ;
  FControl := NewControl ;
  if not Layout.IsLoading then Layout.RequestLayout ;
end ;

end.

