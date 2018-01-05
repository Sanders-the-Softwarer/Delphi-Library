////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         ������ � ������������ ����������� ������������ �������� ����       //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

unit NotebookLayout ;

{ ----- ���������� -------------------------------------------------------------

��������������� ������ � Layouts.pas - ��������� ����������� � �������
��������������� ��. � �������� ������

------------------------------------------------------------------------------ }

{ ----- �������� ---------------------------------------------------------------

� ���� ����� ��������� ��������� ������������ "�������" ��� "�������� �������".

����� TNotebookLayout �������� ���������� ������������ ���������� TNotebook. �
������ ������ ������� ����� ������ ���� �� �������� ���������, ��������
��������� ActivePage. ����� ����������� �������� ��� �������� ��������
(��������).

------------------------------------------------------------------------------ }

{ ----- ��������� �� ���������� ------------------------------------------------

��������� ������������ ������ csNoDesignVisible � ����������� ���������, ������
���������� ��������������� ��� ��� �������� ���������� � ����. � ��������, ���
������ �� ��������� ������������ (���������������, ���� �� ����), �� ��������,
���������� ���������, ������������ ���� �����, ����� �� �������.

------------------------------------------------------------------------------ }

{$I '..\..\options.inc'}

interface

uses SysUtils, Types, Classes, Controls, Contnrs, BaseLayout ;

type
  TCustomNotebookLayout = class ;

  { ������� ��� ����� ������� �������� }
  TPageChangeEvent = procedure ( Sender : TCustomNotebookLayout ;
                                 PageFrom, PageTo : TControl ) of object ;

  { ������������ �-�� TNotebook }
  TCustomNotebookLayout = class ( TLayout )
  private
    FActivePage : TControl ;
    FAutoSelectFirst : boolean ;
    FPages : TComponentList ;
    FOnChanging, FOnChange : TPageChangeEvent ;
  protected
    { ������������� ������������ ������� }
    procedure ControlAdded ( Control : TControl ) ; override ;
    procedure ControlRemoved ( Control : TControl ) ; override ;
    procedure ControlLoaded ( Control : TControl ) ; override ;
    function CompareControls ( Control1, Control2 : TControl ) : integer ; override ;
    procedure DoLayout ( Rect : TRect ) ; override ;
    procedure GetChildren ( Proc : TGetChildProc ; Root : TComponent ) ; override ;
    procedure ShowControl ( AControl : TControl ) ; override ;
    { ����� ������������ ������� }
    procedure DoChanging ( PageFrom, PageTo : TControl ) ; dynamic ;
    procedure DoChange ( PageFrom, PageTo : TControl ) ; dynamic ;
    { ������ ������� }
    procedure SetActivePage ( NewControl : TControl ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
    procedure Loaded ; override ;
    { ���������������� ������ }
    function HasPages : boolean ;
    function FirstPageActive : boolean ;
    function LastPageActive : boolean ;
    procedure SelectFirst ;
    procedure SelectNext ( Rotate : boolean = false ) ;
    procedure SelectPrev ( Rotate : boolean = false ) ;
    procedure SelectLast ;
    function PageCount : integer ;
    function GetPage ( Index : integer ) : TControl ;
    function ActivePageIndex : integer ;
    procedure MovePage ( APage : TControl ; NewIndex : integer ) ;
  protected
    property ActivePage : TControl read FActivePage write SetActivePage ;
    property AutoSelectFirst : boolean read FAutoSelectFirst write FAutoSelectFirst nodefault ;
    property Pages [ Index : integer ] : TControl read GetPage ;
    property OnChanging : TPageChangeEvent read FOnChanging write FOnChanging ;
    property OnChange : TPageChangeEvent read FOnChange write FOnChange ;
  end ;

implementation

uses LayoutMisc, Math;

{ TCustomNotebookLayout }

constructor TCustomNotebookLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  FPages := TComponentList.Create ( false ) ;
  FAutoSelectFirst := true ;
  Width  := 300 ;
  Height := 400 ;
end ;

destructor TCustomNotebookLayout.Destroy ;
begin
  inherited ;
  FreeAndNil ( FPages ) ;
end ;

procedure TCustomNotebookLayout.Loaded ;
begin
  inherited ;
  if AutoSelectFirst then SelectFirst ;
end ;

{ ��������, ���� �� ������ �������� }
function TCustomNotebookLayout.HasPages : boolean ;
begin
  Result := ( FPages.Count > 0 ) ;
end ;

{ ��������, �� ������ �� �������� ������� }
function TCustomNotebookLayout.FirstPageActive : boolean ;
begin
  Result := HasPages and ( FActivePage = FPages.First ) ;
end ;

{ ��������, �� ��������� �� �������� ������� }
function TCustomNotebookLayout.LastPageActive : boolean ;
begin
  Result := HasPages and ( FActivePage = FPages.Last ) ;
end ;

{ ������� � ������ �������� }
procedure TCustomNotebookLayout.SelectFirst ;
begin
  if HasPages then ActivePage := TControl ( FPages.First ) ;
end ;

{ ������� � ��������� �������� }
procedure TCustomNotebookLayout.SelectNext ( Rotate : boolean = false ) ;
begin
  if HasPages and not LastPageActive then
    ActivePage := TControl ( FPages [ ActivePageIndex + 1 ])
  else if LastPageActive and Rotate then
    SelectFirst ;
end ;

{ ������� � ���������� �������� }
procedure TCustomNotebookLayout.SelectPrev ( Rotate : boolean = false ) ;
begin
  if HasPages and not FirstPageActive then
    ActivePage := TControl ( FPages [ ActivePageIndex - 1 ])
  else if FirstPageActive and Rotate then
    SelectLast ;
end ;

{ ������� � ��������� �������� }
procedure TCustomNotebookLayout.SelectLast ;
begin
  if HasPages then ActivePage := TControl ( FPages.Last ) ;
end ;

{ ������� ���������� ������� }
function TCustomNotebookLayout.PageCount : integer ;
begin
  Result := FPages.Count ;
end ;

{ ������� �������� �� ������� }
function TCustomNotebookLayout.GetPage ( Index : integer ) : TControl ;
begin
  Result := TControl ( FPages [ Index ]) ;
end ;

{ ������� ������� ������� �������� }
function TCustomNotebookLayout.ActivePageIndex : integer ;
begin
  Result := FPages.IndexOf ( FActivePage ) ;
end ;

{ ����������� �������� �� ����� ����� � ������������������ }
procedure TCustomNotebookLayout.MovePage ( APage : TControl ;
  NewIndex : integer ) ;
var
  OldIndex : integer ;
begin
  OldIndex := FPages.IndexOf ( APage ) ;
  if OldIndex >= 0 then FPages.Move ( OldIndex, NewIndex ) ;
end ;

{ ������� �� ���������� ���������� }
procedure TCustomNotebookLayout.ControlAdded ( Control : TControl ) ;
begin
  inherited ;
  Control.ControlStyle := Control.ControlStyle + [ csNoDesignVisible ] ;
  FPages.Add ( Control ) ;
  if ActivePage = nil then ActivePage := Control ;
end ;

{ ������� �� �������� ���������� }
procedure TCustomNotebookLayout.ControlRemoved ( Control : TControl ) ;
begin
  if FActivePage = Control then SelectNext ( true ) ;
  if FActivePage = Control then FActivePage := nil ;
  FPages.Remove ( Control ) ;
  Control.ControlStyle := Control.ControlStyle - [ csNoDesignVisible ] ;
  inherited ;
end ;

{ ������� �� �������� ���������� �� dfm }
procedure TCustomNotebookLayout.ControlLoaded ( Control : TControl ) ;
begin
  ControlAdded ( Control ) ;
end ;

{ ���������� ��������� }
procedure TCustomNotebookLayout.DoLayout ( Rect : TRect ) ;
var
  List : TControlList ;
  Control : TControl ;
  i : integer ;
begin
  List := ListControls ( false ) ;
  try
    for i := List.Count - 1 downto 0 do
    begin
      Control := List.Controls [ i ] ;
      Control.Visible := ( Control = FActivePage ) ;
    end ;
    if Assigned ( FActivePage ) then FActivePage.BoundsRect := Rect ;
  finally
    FreeAndNil ( List ) ;
  end ;
end ;

function TCustomNotebookLayout.CompareControls ( Control1, Control2 : TControl ) : integer ;
var i1, i2 : integer ;
begin
  i1 := FPages.IndexOf ( Control1 ) ;
  i2 := FPages.IndexOf ( Control2 ) ;
  Result := Sign ( i1 - i2 ) ;
    { �� ����� �������� ����� ��������� IndexOf < 0, ������� ��� Assert }
end ;

{ ������������ �������� ��������� }
procedure TCustomNotebookLayout.GetChildren ( Proc : TGetChildProc ;
  Root : TComponent ) ;
var i : integer ;
begin
  for i := 0 to FPages.Count - 1 do Proc ( FPages [ i ]) ;
end ;

{ ����������� ��������� ���������� }
procedure TCustomNotebookLayout.ShowControl ( AControl : TControl ) ;
begin
  if FPages.IndexOf ( AControl ) >= 0 then SetActivePage ( AControl ) ;
  inherited ;
end ;

{ ����� ������������ ������� }

procedure TCustomNotebookLayout.DoChanging ( PageFrom, PageTo : TControl ) ;
begin
  if Assigned ( FOnChanging ) then FOnChanging ( Self, PageFrom, PageTo ) ;
end ;

procedure TCustomNotebookLayout.DoChange ( PageFrom, PageTo : TControl ) ;
begin
  if Assigned ( FOnChange ) then FOnChange ( Self, PageFrom, PageTo ) ;
end ;

type
  TCrackWinControl = class ( TWinControl ) ;

{ ��������� �������� �������� ���������� }
procedure TCustomNotebookLayout.SetActivePage ( NewControl : TControl ) ;
var OldActivePage : TControl ;
begin
  if ActivePage = NewControl then exit ;
  if NewControl = nil then exit ;
  if FPages.IndexOf ( NewControl ) < 0 then exit ;
  OldActivePage := FActivePage ;
  DoChanging ( OldActivePage, NewControl ) ;
  FActivePage := NewControl ;
  RequestLayout ;
  FActivePage.BringToFront ;
  if AutoSelectFirst and ( FActivePage is TWinControl ) then
    TCrackWinControl ( FActivePage ).SelectFirst ;
  DoChange ( OldActivePage, NewControl ) ;
end ;

end.

