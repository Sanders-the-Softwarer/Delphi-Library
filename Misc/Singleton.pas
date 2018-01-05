////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//              Singleton - ������� ����� ��� ���������� ����������           //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- ������� ----------------------------------------------------------------

����� �������� ����� �������������� ���� ������, ������������ ���, ������������
� ����������� ����������� ��������, � ��� ����� ������������, ��� �������������
� �������������� ����������� �� ������. � ����� ������ ������ ������ �����������
���������� �� ��������� ������ � �������� ��������������� ������.

��� ��������������� ������������ ������ ������ ����� �������� ��� ������ �
�������� ������ ��� �������������� �������� ����� ����������� ��������� �������.

���� �� ������� ���������� ��������� � �������� �������������� �� �� ����
�������� - �������� � ���, � �� ��������� ��������� ����� ��������� � ���������
������ ������. ����� ����� �������� � ��������� �������, ���� ����� �����.

�����: Sanders Prostorov, 2:5020/1583, softwarer@mail.ru, softwarer@nm.ru

��� ���������� ����� � ������ ������� ������������� �� http://softwarer.ru

------------------------------------------------------------------------------ }

{ ----- ���������� ������ ------------------------------------------------------

����� TSingleton �������� ������� ���������� ��� ��������-����������. �����
NewInstance ������������� ����� �������, ��� ��� ������ �������������
���������������� ������ ���������� ���� � ��� �� ������, ��������� ��� �����
������ ������. ����������, ����� FreeInstance ������������� ���, ��� �����
������ ������������ ������������ - ����� �������, ����� ������� ������ �����
�������� � �������� ��������� ������� �������. ����� ������ TSingleton
���������� ������� � ������� ������ ������������ � ������ �� ���������� ������
������������ ������ (�� ���������� ������ finalization ������ Singleton).

��� ��������� �������� � ����������� �������� ��������� ����������� ������
InitSingleton � DoneSingleton. ���������� ����� ������������ ��� ������ ���
������������� � ��������������� ����������; ����� �������� �� ������ ���
�������������� �������� � ����������� ��������.

����� RegisterSupport ��������� �������, ��� ����������� ������ ����� ������
�������������� ��� ���������� ��������� ������� ����������. ��� ���� �����������
��������� �������-����������� ������: ����� ������������� ������ �����
���������� ������������ TParentSingleton.Create, �� ��� ���� ����� ������������
(� ��������������) ��� �� ����� ��������� ����������, ��� � ��� ������
TChildSingleton.Create. � ���� ������ ������ ����� TChildSingleton.Create
������ ���� �������� ����� ������� ������ TParentSingleton.Create. �����������
����� Supports ������������� ���������� ��� �������� ������� � ������������
���������� ��� ���������� � ��� ������� RegisterSupports.

����� TSingleton ��������� ������� ������������ ������ �������� ����������
TInterfacedObject, �� - � ���� ��������� ��������� - ��� ��������� ��������
������ � ������������ ������� ��� ����������� ��������� ������. ��� ���������
������������ ��� ������ � ����������� ���������� (��� �������������� ���
����������� ����������).

��������� ������ �������������� ��� �������� � ������ AfterConstruction. �����
�������, � ������, ���� ��� �������� ������� ��������� ����������, ������
�������� ��������������������, � ��������� ��������� � ������������ ��������
� ����� ������� �������� �������.

�������� ������ � ����� ������ �� �������� ��������-�����������. ��� ����������
��������-����������� ���������� ���������� ������� ��� ��������� �������, ��
������ �� �������������; � ���� ������ �������� ������������� ������ (������ �
������������� ���������� �������) ����� ������ �����������.

������� ������������, �� ����� �������� ���������� DestroySingleton,
��������������� ��� "����������" ����������� �������. ������� ����� � ���, ���
������ ������ ���� ���� ��������� ��� ���� ����������, �������� ��� ����, �����
����������� ��� � ������ ����������. ����� ��� ����� ��� ����������, ����������
� ������-����� (��� ���������� �������������� � ������������� �������).

------------------------------------------------------------------------------ }

unit Singleton ;

interface

uses Classes, SysUtils, Contnrs ;

type

  { ����� ����������, ������������ � ������ }
  ESingleton = class ( Exception ) ;

  TSingletonClass = class of TSingleton ;

  { ������� ����� ��������� }
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
  SDoesNotSupportSelf = '����� %s �������� �����������, �� ����������� ��� ' +
                        '������� �� ����������������' ;
  SDuplicate = '����������� ������ <%s> ����������; ����������� �� ' +
               '���������������� � ������� <%s>' ;

implementation

uses RecordList ;

type
  { ������ ��������� singleton-�� }
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

{ �������� ������ ������� ���� ������� ����� ���������� }
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

{ ������������� ������������ ������ �� ���������� ������ ������ }
procedure TSingleton.FreeInstance ;
begin
  if not IsDestroyingSingleton then exit ;
  DoneSingleton ;
  inherited FreeInstance ;
end ;

{ �����, ���������� ����������� }
procedure TSingleton.InitSingleton ;
begin
end ;

{ �����, ���������� ���������� }
procedure TSingleton.DoneSingleton ;
begin
end ;

{ ��������� ����� ��������� �������� ������� }
procedure TSingleton.AfterConstruction ;
var KeyIndex : integer ;
begin
  Assert ( Singletons <> nil ) ;
  { ���� ��� ���������������� - ��������� �����, ������ ������ }
  KeyIndex := Singletons.IndexOfKey ( KeyClass ) ;
  if KeyIndex >= 0 then exit ;
  { ����� ���������� �������� }
  inherited ;
  { ��� ������������ ������ ���� ������� �� KeyIndex >= 0 }
  Assert ( KeyClass = Self.ClassType ) ;
  Assert ( SupportsSelf ) ;
  { �������������� ��������� ���� � ������ }
  RegisterSupport ([ KeyClass ]) ;
  Supports ;
  KeyIndex := Singletons.IndexOfKey ( KeyClass ) ;
  Assert ( KeyIndex >= 0 ) ;
  Singletons.Primary [ KeyIndex ] := true ;
end ;

{ ����� ����������� ��������� }
class procedure TSingleton.DestroySingleton ;
var
  i : integer ;
  S : TSingleton ;
begin
  if Singletons = nil then exit ; { ���� ������ ����, ���������� ������ }
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

{ ����� ����������� ���� ���������� }
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

{ �����, ����������� ��������� ��������� ������� ���� - ��� ����������� ������� }
class function TSingleton.SupportsSelf : boolean ;
begin
  Result := true ;
end;

{ ����������� ����������� �������� }
procedure TSingleton.Supports ;
begin
end ;

{ ����������� ������� ��� ������������ ��������� ��������� ������� }
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

{ ��������� ������� }

function TSingleton.IsDestroyingSingleton : boolean ;
var i : integer ;
begin
  Result := true ;
  { ���������� ������ ���� � ������ ������ ���������� }
  if SingletonDestroying or IsDestroying then exit ;
  { ���� � ������ ������ ��� �������� (�� ����������� � Singletons )}
  for i := Singletons.Count - 1 downto 0 do
    if Singletons.Server [ i ] = Self then Result := false ;
end ;

{ ��������� ����������� }

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
