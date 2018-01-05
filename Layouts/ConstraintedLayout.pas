////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         ������ � ������������ ����������� ������������ �������� ����       //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- ���������� -------------------------------------------------------------

��������������� ������ � Layouts.pas - ��������� ����������� � �������
��������������� ��. � �������� ������

------------------------------------------------------------------------------ }

unit ConstraintedLayout ;

interface

uses SysUtils, Classes, Controls, BaseLayout, LayoutMisc ;

type

  TLayoutConstraint = class ;
  TLayoutConstraints = class ;
  TLayoutConstraintClass = class of TLayoutConstraint ;
  TLayoutConstraintsClass = class of TLayoutConstraints ;

  { ������� ����� ��� �������������� ���������� }
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

  { ���������, �������� �������������� �������� ��������� }
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

  { ������� ����� ��� ������� � �������������� ��������� ��������� }
  TConstraintedLayout = class ( TLayout )
  private
    FConstraints : TLayoutConstraints ;
  protected
    { ������������� ������� ������������ ������� }
    procedure DoBeforeLayout ; override ;
    { ������, ��������������� � ���������� � �������� }
    function ConstraintsClass : TLayoutConstraintsClass ; dynamic ;
    { ������ ������� }
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

{ ������� ������ ���������, ���������� � ����������� }
function TConstraintedLayout.ConstraintsClass : TLayoutConstraintsClass ;
begin
  Result := TLayoutConstraints ;
end ;

{ ���������� ������ ���. ���������� � ����������� ����� ������������� }
procedure TConstraintedLayout.DoBeforeLayout ;
begin
  inherited ;
  FConstraints.UpdateConstraints ;
end ;

{ ������ ������� }

procedure TConstraintedLayout.SetConstraints ( NewConstraints : TLayoutConstraints ) ;
begin
end ;

{ TLayoutConstraints }

constructor TLayoutConstraints.Create ( AOwner : TPersistent ) ;
begin
  inherited Create ( AOwner, ItemClass ) ;
end ;

{ ���������� ������ ����������� � ������������ ������ ��������� }
procedure TLayoutConstraints.UpdateConstraints ;
var
  List : TControlList ;
  i : integer ;
begin
  if Layout.IsLoading then exit ;
  List := Layout.ListControls ( false ) ;
  try
    { ��������� ���������� �� ��������� � ���� ����������� }
    for i := Count - 1 downto 0 do
      if List.IndexOf ( Items [ i ].Control ) < 0
        then Delete ( i ) ;
    { �������� �������� ��� ����������� ��������� }
    for i := 0 to List.Count - 1 do
      if FindByControl ( List [ i ]) = nil then
        TLayoutConstraint ( Self.Add ).Control := List [ i ] ;
  finally
    FreeAndNil ( List ) ;
  end ;
end ;

{ ����� ���. ���������� �� ���������� }
function TLayoutConstraints.FindByControl ( AControl : TControl ) : TLayoutConstraint ;
var i : integer ;
begin
  Result := nil ;
  for i := Count - 1 downto 0 do
    if Items [ i ].Control = AControl then Result := Items [ i ] ;
end ;

{ ������� ���������� ���������� }
function TLayoutConstraints.Layout : TLayout ;
begin
  Result := Owner as TLayout ;
end ;

{ ������� ������ �������������� ���������� }
function TLayoutConstraints.ItemClass : TLayoutConstraintClass ;
begin
  Result := TLayoutConstraint ;
end ;

{ ������ ������� }

function TLayoutConstraints.GetItem ( Index : integer ) : TLayoutConstraint ;
begin
  Result := inherited Items [ Index ] as TLayoutConstraint ;
end ;

{ TLayoutConstraint }

{ ������� ��������� ��������� }
function TLayoutConstraint.Constraints : TLayoutConstraints ;
begin
  Result := Collection as TLayoutConstraints ;
end ;

{ ������� ���������� ���������� }
function TLayoutConstraint.Layout : TLayout ;
begin
  Result := Collection.Owner as TLayout ;
end ;

{ ������� ����� ���������� ��� Object Inspector }
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

