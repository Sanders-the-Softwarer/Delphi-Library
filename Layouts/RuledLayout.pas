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

{ ----- ������������� ������ ---------------------------------------------------

� ���� ����� ��������� ����� TRuledLayout - ������� ����� ��� ����������
������������, �������������� ���� �������������� ���������� � ���������� �������
�� �������� ���������.

�������������� ���������� �������������� � ���� ��� ���������� ������ -
��������, ����������� � ������� ��������� �������� � �������� �������� ���
����������. ���������� ����� �������� ������ ������ ���������� ���� ������
������ � ����������� �� ������� �������.

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

  { ������� ����� ��� ������ ������������ }
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

  { ���������, �������� ������� ������������ }
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

  { ������� ����� ��� ������� � �������������� ��������� ��������� }
  TRuledLayout = class ( TLayout )
  private
    FRules : TLayoutRules ;
    ControlAdding, ControlDeleting : TControl ;
  protected
    { ������������� ������� ������������ ������� }
    procedure ControlAdded ( AControl : TControl ) ; override ;
    procedure ControlRemoved ( AControl : TControl ) ; override ;
    procedure DoBeforeLayout ; override ;
    { ������, ��������������� � ���������� � �������� }
    function RulesClass : TLayoutRulesClass ; dynamic ;
    function RuleClass : TLayoutRuleClass ; dynamic ;
    { ������ ������� }
    procedure SetRules ( NewRules : TLayoutRules ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
    { ������� ���������� � ��������� }
    function IsAdding ( out AControl : TControl ) : boolean ;
    function IsDeleting ( AControl : TControl ) : boolean ;
  published
    property Rules : TLayoutRules read FRules write SetRules ;
  end ;

implementation

resourcestring
  SCantAddRule    = '������ ��������� �������. ��� ���������� ������� ' +
                    '�������� �� layout-��������� ����� ������� ����������' ;
  SCantDropRule   = '������ ������� �������; ������ ����� ���������� ��� ' +
                    '������� ���������, ����������� ��������' ;
  SCantSetControl = '������ �������������� ������� �� ������ ���������. ' +
                    '�������� ��� �� layout-������ � ��������� ��� ���� ' +
                    '��� ����������� �������' ;

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

{ ������� ���������� � ��������� }

function TRuledLayout.IsAdding ( out AControl : TControl ) : boolean ;
begin
  AControl := ControlAdding ;
  Result := ( AControl <> nil ) ;
end ;

function TRuledLayout.IsDeleting ( AControl : TControl ) : boolean ;
begin
  Result := ( ControlDeleting = AControl ) ;
end ;

{ ������� ������ ���������, ���������� � ����������� }
function TRuledLayout.RulesClass : TLayoutRulesClass ;
begin
  Result := TLayoutRules ;
end ;

{ ������� ������ �������� ��������� ������ }
function TRuledLayout.RuleClass : TLayoutRuleClass ;
begin
  Result := TLayoutRule ;
end ;

{ ������� �� ���������� ��������� }
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

{ ������� �� �������� ��������� }
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

{ �������� ������ ������, ������� �����-������ ����� ��� �������� � IDE }
procedure TRuledLayout.DoBeforeLayout ;
begin
  if not IsLoading then Rules.ClearEmpty ;
  inherited ;
end ;

{ ������ ������� }

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

{ �������� ������� ��� ����������� ������������ ���������� }
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

{ ������� �� ������ ������. ������ �� ���, �� ���-������ ����� �������� � IDE }
procedure TLayoutRules.ClearEmpty ;
var i : integer ;
begin
  for i := Count - 1 downto 0 do
    if Items [ i ].Control = nil then Items [ i ].Free ;
end ;

{ �������� ������ � ���������� }
procedure TLayoutRules.DropByControl ( AControl : TControl ) ;
begin
  try
    FlagChangeEnabled := true ;
    FindByControl ( AControl ).Free ;
  finally
    FlagChangeEnabled := false ;
  end ;
end ;

{ ����� ���. ���������� �� ���������� }
function TLayoutRules.FindByControl ( AControl : TControl ) : TLayoutRule ;
var i : integer ;
begin
  Result := nil ;
  for i := Count - 1 downto 0 do
    if Items [ i ].Control = AControl then Result := Items [ i ] ;
end ;

{ ������� ������ �������������� ���������� }
function TLayoutRules.RuleClass : TLayoutRuleClass ;
begin
  Result := Layout.RuleClass ;
end ;

{ �������� Items }
function TLayoutRules.GetItem ( Index : integer ) : TLayoutRule ;
begin
  Result := inherited Items [ Index ] as TLayoutRule ;
end ;

{ ������� �� �������� ��� �������� ������� }
procedure TLayoutRules.Notify ( Item : TCollectionItem ;
                                Action : TCollectionNotification ) ;
var
  Rule : TLayoutRule absolute Item ;
  AControl : TControl ;
begin
  Assert ( Layout <> nil ) ;
  Assert ( Item <> nil ) ;
  Assert ( Item is TLayoutRule ) ;
  { ��������� �������� ������ � Layout-�� }
  if Layout.IsDestroying then exit ;
  { ��������� �������� ������ ������ }
  if ( Action = cnExtracting ) and ( Rule.Control = nil ) then exit ;
  { ��������� �������� �� dfm }
  if ( Action = cnAdded ) and Layout.IsLoading then exit ;
  { ��������� �������� ������� ��� ������������ ���������� }
  if ( Action = cnAdded ) and Layout.IsAdding ( AControl ) then
  begin
    Rule.FControl := AControl ;
    exit ;
  end ;
  { ��������� �������� ������� ��� ���������� ���������� }
  if ( Action = cnDeleting ) and Layout.IsDeleting ( Rule.Control ) then exit ;
  { ����� - �������� }
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

{ ������� ��������� ��������� }
function TLayoutRule.Rules : TLayoutRules ;
begin
  Result := FRules ;
end ;

{ ������� ���������� ���������� }
function TLayoutRule.Layout : TRuledLayout ;
begin
  Result := Rules.Layout ;
end ;

{ ����������� ������� ������� }
procedure TLayoutRule.Assign ( Source : TPersistent ) ;
begin
  if Self.ClassType = Source.ClassType
    then AssignFrom ( Source )
    else inherited ;
end ;

{ ������� ����� ���������� ��� Object Inspector }
function TLayoutRule.GetDisplayName : string ;
begin
  if Assigned ( FControl )
    then Result := FControl.Name
    else Result := inherited GetDisplayName ;
end ;

{ �������� ������� � ���������� }
procedure TLayoutRule.SetControl ( NewControl : TControl ) ;
begin
  Assert ( Layout <> nil ) ;
  if Layout.IsLoading
    then FControl := NewControl
    else raise ELayout.Create ( Layout, SCantSetControl ) ;
end ;

end.

