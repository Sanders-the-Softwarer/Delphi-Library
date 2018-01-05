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

��� ���������� ����� ����� ��������� ������ RecordList, ������� ����� ����� ��
http://softwarer.ru

------------------------------------------------------------------------------ }

unit FrameLayout ;

interface

uses Classes, Types, SysUtils, Controls, Math, BaseLayout, ConstraintedLayout,
  RecordList, LayoutMisc ;

type

  { ���. ���������� � ���������� }
  TFrameLayoutConstraint = class ( TLayoutConstraint )
  private
    FData : array [ 0..1 ] of integer ;
  protected
    function GetData ( Index : integer ) : integer ;
    procedure SetData ( Index, NewValue : integer ) ;
  published
    property Row : integer index 0 read GetData write SetData ;
    property Col : integer index 1 read GetData write SetData ;
  end ;

  { ���. ���������� � ����������� }
  TFrameLayoutConstraints = class ( TLayoutConstraints )
  protected
    function ItemClass : TLayoutConstraintClass ; override ;
  end ;

  { ������ ����� � ������� }
  TGridData = class ( TRecordList )
  public
    constructor Create ; override ;
    { ������� ������ }
    function GetEntry ( ACoord, ASize : integer ) : integer ;
    procedure MakeEntry ( ACoord, ASize : integer ) ;
    procedure ClearSize ;
    procedure RecalcCoords ( Side, Internal : integer ) ;
  public
    property Coord [ ArrIndex : integer ] : integer index 0
             read GetInt write SetSortInt ;
    property Size  [ ArrIndex : integer ] : integer index 1
             read GetInt write SetInt ;
  end ;

  { ������������ ��� ���� ��������� � �������������� }
  TCustomFrameLayout = class ( TConstraintedLayout )
  private
    { ��������������� ���������� }
    Rows, Columns : TGridData ;
  protected
    { ������������� ������� ������������ ������� }
    function ConstraintsClass : TLayoutConstraintsClass ; override ;
    procedure DoLayout ( Rect : TRect ) ; override ;
    procedure DesignPaintLayout ; override ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
  end ;

implementation

type
  TCrackControl = class ( TControl ) ;

{ TCustomFrameLayout }

constructor TCustomFrameLayout.Create ( AOwner : TComponent ) ;
begin
  Rows := TGridData.Create ;
  Columns := TGridData.Create ;
  inherited ;
  Width := 350 ;
  Height := 120 ;
end ;

destructor TCustomFrameLayout.Destroy ;
begin
  FreeAndNil ( Rows ) ;
  FreeAndNil ( Columns ) ;
  inherited ;
end ;

{ ������� ������ ���. ���������� � �������� ����������� }
function TCustomFrameLayout.ConstraintsClass : TLayoutConstraintsClass ;
begin
  Result := TFrameLayoutConstraints ;
end ;

{ ������������ ��������� }
procedure TCustomFrameLayout.DoLayout ;
var
  Controls : TControlList ;
  i : integer ;
begin
  Controls := ListControls ( not IsDesigning ) ;
  try
    { ������� ������ ������ }
    Rows.Clear ;
    Columns.Clear ;
    if Controls.Count = 0 then exit ;
    { �������� ������ ����� � ������� }
    for i := 0 to Controls.Count - 1 do
      with Controls [ i ] do
      begin
        Rows.MakeEntry ( Top, Height ) ;
        Columns.MakeEntry ( Left, Width ) ;
      end ;
    { �������� ���������� � ������� }
    for i := 0 to Constraints.Count - 1 do
      with Constraints [ i ] as TFrameLayoutConstraint do
      begin
        Row := Rows.GetEntry ( Control.Top, Control.Height ) ;
        Col := Columns.GetEntry ( Control.Left, Control.Width ) ;
      end ;
    { ���������� ����������� ������� ����� � ������� }
    Rows.ClearSize ;
    Columns.ClearSize ;
    for i := 0 to Constraints.Count - 1 do
      with Constraints [ i ] as TFrameLayoutConstraint do
      begin
        Rows.Size [ Row ] := Max ( Rows.Size [ Row ], Control.Height ) ;
        Columns.Size [ Col ] := Max ( Columns.Size [ Col ], Control.Width ) ;
      end ;
    { ���������� ����� ���������� ����� � ������� }
    Rows.RecalcCoords ( Margins.Top, Margins.Vert ) ;
    Columns.RecalcCoords ( Margins.Left, Margins.Horiz ) ;
    { �� � ������� - ���������������� ��������� � ������� }
    for i := 0 to Constraints.Count - 1 do
      with Constraints [ i ] as TFrameLayoutConstraint do
      begin
        Control.Left := Columns.Coord [ Col ] ;
        if not TCrackControl ( Control ).AutoSize then
          Control.Width := Columns.Size [ Col ] ;
        Control.Top := Rows.Coord [ Row ] +
                       ( Rows.Size [ Row ] - Control.Height ) div 2 ;
      end ;
  finally
    FreeAndNil ( Controls ) ;
    Invalidate ;
  end ;
end ;

{ ��������� ������������ � ������-����� }
procedure TCustomFrameLayout.DesignPaintLayout ;
var
  Current, i : integer ;
begin
  inherited ;
  if Margins.Vert > 0 then
    for i := 1 to Rows.Count - 1 do
    begin
      Current := Rows.Coord [ i ] - Margins.Vert div 2 - 1 ;
      DrawDesignRect ( Margins.Left, Current, Width - Margins.Right, Current + 1 ) ;
    end ;
  if Margins.Horiz > 0 then
    for i := 1 to Columns.Count - 1 do
    begin
      Current := Columns.Coord [ i ] - Margins.Horiz div 2 - 1 ;
      DrawDesignRect ( Current, Margins.Top, Current + 1, Height - Margins.Bottom ) ;
    end ;
end ;

{ TFrameLayoutConstraints }

function TFrameLayoutConstraints.ItemClass : TLayoutConstraintClass ;
begin
  Result := TFrameLayoutConstraint ;
end ;

{ TFrameLayoutConstraint }

function TFrameLayoutConstraint.GetData ( Index : integer ) : integer ;
begin
  Result := FData [ Index ] ;
end ;

procedure TFrameLayoutConstraint.SetData ( Index, NewValue : integer ) ;
begin
  if NewValue < 0 then NewValue := 0 ;
  if FData [ Index ] = NewValue then exit ;
  FData [ Index ] := NewValue ;
  Layout.RequestLayout ;
end ;

{ TGridData }

constructor TGridData.Create ;
begin
  inherited ;
  RecordLength := 2 ;
  SetSortOrder ( 0 ) ;
end ;

{ ����� ������, ���������� ��� ���������� ���������� }
function TGridData.GetEntry ( ACoord, ASize : integer ) : integer ;
var CCoord, CSize, Intersect, i : integer ;
begin
  for i := Count - 1 downto 0 do
  begin
    Result := i ;
    CCoord := Coord [ i ] ;
    CSize  := Size [ i ] ;
    if CCoord > ACoord
      then Intersect := ACoord + ASize - CCoord
      else Intersect := CCoord + CSize - ACoord ;
    if Min ( ASize, CSize ) <= 2 * Intersect then exit ;
  end ;
  Result := -1 ;
end ;

{ ���������� ������ � ������, ���� ��� ���������� }
procedure TGridData.MakeEntry ( ACoord, ASize : integer ) ;
begin
  if GetEntry ( ACoord, ASize ) < 0 then
    AddRecord ([ ACoord, ASize ]) ;
end ;

{ ������� ���� ������� (��� �����������)}
procedure TGridData.ClearSize ;
var i : integer ;
begin
  for i := Count - 1 downto 0 do Size [ i ] := 0 ;
end ;

{ ������ ����� ��������� �� ������ ������������� �������� }
procedure TGridData.RecalcCoords ( Side, Internal : integer ) ;
var i : integer ;
begin
  Coord [ 0 ] := Side ;
  for i := 1 to Count - 1 do
    if Size [ i - 1 ] = 0
      then Coord [ i ] := Coord [ i - 1 ]
      else Coord [ i ] := Coord [ i - 1 ] + Size [ i - 1 ] + Internal ;
end ;

end.

