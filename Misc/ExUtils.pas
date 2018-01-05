////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                   ������������ ��� ������ � ������������                   //
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

�����: Sanders Prostorov (softwarer@mail.ru, softwarer@nm.ru)

��� ���������� ����� � ������ ������� ������������� �� http://softwarer.ru
��� ��������� �� ������� � ����������� �� ����������: http://bugs.softwarer.ru

------------------------------------------------------------------------------ }

{ ----- ������������� ������ ---------------------------------------------------

� ������ ������������ ����� ���������� EStsException, ��������� ����� �������
���������� ���������� �� ������ � ��������� �� �������������. ����� ����������
������ ������ ������ ����� ���� ������� ������������ ����������� ����� ���������
� �������������� ����������; ��� ��������� ������� ���������, ������� ���
������������ � �������������� ��������� �� ������. ���, ��������, ���������
�������� ����:

try
  Strings.LoadFromFile (CfgFileName);
  for i := 0 to Strings.Count - 1 do
  try
    Process (Strings.Names [i], Strings.ValueFromIndex [i]);
  except
    on E: Exception do
      raise AddExceptionFooter (E, '������: %d', [i + 1]);
  end;
except
  on E: Exception do
    with EStsException.Clone (E) do
    begin
      AddHeader ('������ ��� ������ ����������������� �����');
      AddFooter ('����: %s', [CfgFileName]);
      RaiseSelf;
    end;
end;

�������� ������������ ����� ���������� ����� ������ � ����������� ���� ���
�� �����������.

����� ������������ ������ ���������, ����� EStsException ��������� ���������
� ������ ���������� ������������ ���������� ���������� - ��� "���-��������",
����������� �������� ������������� ������. � ��� ����� � ����� �������� ��������
�������� ����������, ����� ����������� SQL �������� � ������ ����������, �������
�� ������� ���������� ������������, �� ������� �������� � ���-����, ����������
�� ������ "�������������� ����������" �/��� �������� ������������.

� ������ ���������� ��� �������� ���������� ������ EStsException. �����
EExpectable ������������ ��� ��� ��������� ��������, ��������� ������� ����� �
����� ������� � ��������� ��������������� ���������. ���� ��������� ���������
�������� �������������, �������� ���������������� ���������, �������� �����
� ������� ������������ � �. �. � ����������� Application.OnException ��� �����
������ ��� ������� ������� ������ �������� ����� ��������� �� ������ �
������������ ������������ ����������� �� ����������. �������� ���� ��������
������ �� EStsException, �� ������� �������� ������� � ������� ������� �������
�� ��� �������� ������. ����� EApplication ������������ ��� ��������� ��������,
���������� �������� � ����� ��������� - � ������ �������, ���� ���������
������������ ���������� ���� ����������� ��������. �������, ����� ENative
���������� ��� �������� ��� "�������" ���������� ������; �� ���������
������������� ������� ���������� - index out of range, canvas does not allow
drawing � ����� ������ - � ���������� EStsException � ��������������� ��� ���
���� ����� ��� ����������������.

����� ExceptionMapper ��������� � ������ � EStsException � ��������� ����������,
��� ������ "�������" ���������� ������������ � �������� EStsException. ��
��������� ��������� ��������� �����:

    - EStsException � �������� ��������� ��� ���������
    ExceptionMapper.Register (EStsException, nil);

    - SysUtils.EOSError � EInOutError ���������� � ��� EOSError
    ExceptionMapper.Register (SysUtils.EInOutError, ExUtils.EOSError);
    ExceptionMapper.Register (SysUtils.EOSError, ExUtils.EOSError);

    - �������� ������ ����������� ��� ������ ����� ���������
    ExceptionMapper.Register (EFileStreamError, EExpectable);

    - ��� ������ ���������� � ENative
    ExceptionMapper.Register (Exception, ENative);

����� InternalWarnings ������������ ��� ����������� "���������� ��������" -
�����, ��� ����������� ���������� � ������ ������ �������� ������ �������������,
�� �������� � �������� �����. ����� ��������� ���������������� ���������� �����
���������, ������� �����, ��������, ���������� �������� � ���-����. �������
������ ��������� ����� ������� ������: � "����������" ������ ���������
��������� �� ������� ������������; � ������������ ��� �� ��������� � ���������,
�� ��� ��� ����� ��������� �� �������� ������������.

------------------------------------------------------------------------------ }

{ ----- ��������� �� ���������� ------------------------------------------------

� ����������� ����������� ������ ���������� �������� �������� �����������
����������� �������������� ��������. ������� ��� � ���, ��� ���� ��� ���������
����������������� ���������� ���-�� ����� �� ��� � �� �������� ������ ����
�����������, �� � ������ ������ �� ������/����������� � ������� ����������
�� ������������ ����������; � ������ �� ��������� ������ ���������� ������
����� ��� �� ���, ����� �������� � �������, � �� ����������. ����� �������,
������� �� ������ �� ���������� ����������� ����������, �� � ���������
����������� ����������� ������������� ���������� � ������������ �������� �
�������������.

��������� ��������� � ��� ����� � � ��������� Assert, ������� ����� ����������
����������. �� ���� ������� � ������ �������� ��������, ���������� �����������
Assert, � ������������ ������ ��� ������� �������� ExAssert.

�� ��� �� ������������ ������� �������� ������������� � ExUtils ������
������������ ����������� ���������� (����, ��������, ������ ������� ��������
RecordList). ������� ����� � ���, ��� �� � ���� ������� ����� �������
������������ ExUtils, � �������������� ����� � ������ ���� ��� ������ ��������
� ���������� ������������; ������ ������ � ������ �������� ������� ���������
������ � ��� ���������� ������ � ���. ������ ����� ������� ������������ ������
������ CmpUtils � ������ ������, ��� ���������� �� ���� ������������
EqualHandlers ��������� �������.

����� EStsException ��������� ������������ ��������� � ���� OrigMessage, � �
Message ������ ������ - � ����������� ���� ����������-��������. ��� ������� ���
����, ����� ����������� ��� ������ � ������������, �� ����������� ������������
������ ������, ��� �������� �� ����� �������, ��������� ��������� �� ������.
���������� ����� ���������� � ���, ��� ���, �������� �������� Message ��� �����
������������ ExUtils, �� ������ ������� ���������� �������� (��� ����������
����� �����������). ������, ��� �������������� ��� ���� ������� ����.

------------------------------------------------------------------------------ }

{ ----- ������� ������ ---------------------------------------------------------

??.??.2006 ��������� ������������ ����������� ������� � ������ ExUtils. ������
           �������������������� ��������.

30.04.2008 ������ �������� ����������� � ����������� � ������������ � ���������
           ������.           

------------------------------------------------------------------------------ }

unit ExUtils;

interface

uses
  Classes, SysUtils;

type

  { �������������� ����������, ������������ ������ � ����������� }

  TExceptionParamType = (eptEmpty, eptVariant, eptObject, eptClass);

  TExceptionParam = record
    Name: string;
    ParamType: TExceptionParamType;
    VarValue: variant;
    ObjValue: TObject;
    ClassValue: TClass;
  end;

  TExceptionParams = array of TExceptionParam;

  { ������� ����� �������������� ���������� }
  EStsExceptionClass = class of EStsException;
  EStsException = class (Exception)
  private
    Headers, Footers: TStrings;
    Params: TExceptionParams;
    OrigMessage: string;
  protected
    { ����������� ���������� ����� � ��� }
    procedure Assign (Source: Exception); dynamic;
    { ������������ ������� ������ ��������� �� ������ }
    function CompleteMessage: string;
    { ������������ ������ ��������� �� ������ ��� ���������� �������� }
    function NoMessage: string;
    { �������� ������������� ������������ �������� }
    function CheckHeaders: boolean;
    function CheckFooters: boolean;
    { ������� ������ }
    function AddParam (const Name: string): integer; overload;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    class function Clone (E: Exception): EStsException;
  public
    procedure RaiseSelf;
    { ���������� � ��������� ������ ��������� }
    procedure AddHeader (Header: string); overload;
    procedure AddHeader (Header: string;
                         const Params: array of const); overload;
    { ���������� � ��������� ������� ������ }
    procedure AddFooter (Footer: string); overload;
    procedure AddFooter (Footer: string;
                         const Params: array of const); overload;
    { ���������� ��������� �������������� ���������� }
    procedure AddParam (const Name: string; const Value: variant); overload;
    procedure AddParam (const Name: string; const Value: TObject); overload;
    procedure AddParam (const Name: string; const Value: TClass); overload;
    { ������� �������� ���������� }
    function ParamCount: integer;
    function Param (ParamNo: integer): TExceptionParam;
  end;

  { �������� �������� ������������ ������� ���������� �� ���� ������ }
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

  { ����� "���������" ���������� - ������ ������������, ������������ ���}
  EExpectable = class (EStsException);

  { ����� ������ ���������� }
  EApplication = class (EStsException);

  { ����� ��� ������� ������� ���������� - ��, ��������� ��� }
  ENative = class (EStsException)
  private
    FNativeClass: ExceptClass;
  public
    procedure Assign (Source: Exception); override;
  public
    property NativeClass: ExceptClass read FNativeClass;
  end;

  { ����� ��� ������ �� }
  EOSError = class (ENative)
  private
    FErrorCode: cardinal;
  public
    procedure Assign (Source: Exception); override;
    property ErrorCode: cardinal read FErrorCode;
  end ;

  { ����� ��� ������, ����������� � ����������� ������� }
  EModule = class (EApplication)
  public
    procedure AfterConstruction; override;
  public
    function ModuleName: string; virtual; abstract;
  end;

  { ����� ������ ������ ������ }
  EExUtils = class (EModule)
  public
    function ModuleName: string; override;
  end;

  { ����� ��� ����������� �������� ��������� }

  TWarningEvent = procedure (const Warning: string) of object;

  InternalWarnings = class
  public
    { ���������� ��������� � �������� }
    class procedure Add (const Warning: string);
    { ���������� ���������� ��� ����� ���������� ��������������
      � ����������� ��� ����� }
    class procedure AddListener (Handler: TWarningEvent);
    class procedure RemoveListener (Handler: TWarningEvent);
  end;

{ ���������� ����� Clone/AddExceptionHeader }
function AddExceptionHeader (E: Exception;
                             Header: string): EStsException; overload;
function AddExceptionHeader (E: Exception; Header: string;
                             Params: array of const): EStsException; overload;

{ ���������� ����� Clone/AddExceptionFooter }
function AddExceptionFooter (E: Exception;
                             Footer: string): EStsException; overload;
function AddExceptionFooter (E: Exception; Footer: string;
                             Params: array of const): EStsException; overload;

implementation

uses CmpUtils;

resourcestring
  SSourceModule = '����������� ������';
  SSafeFormat   = 'ExUtils.SafeFormat: ������ ��� �������������� � ������';
  SAssert       = '��������� ����� ���� ��������� ������� ExUtils.Assert';
  SNoMessage    = '������ (%s) ��� ������ ��������� �� ������';
  SCloningNil   = '������� ������� ����������� �������������� (nil) ����������';
  SNativeClass  = '�������� ����� ����������';
  SInvalidMap   = 'ExceptionMap: ������ ��� �� ���� ����� ������ ������ - ' +
                  '������� EStsException';
  SCantMapNil   = 'ExceptionMap: ������ ���������� �������� nil';

{ ������ ����������� Assert, ����������� � �������� ������ }
procedure Assert (P1: TObject; P2: array of const; P3: IInterface);
begin
  System.Assert (true, SAssert);
  { ��� ������������ ������� �� ������ ���������� � ����������� ����. ��
    ������������ �������������� - ���� ������ ���������� � ������, ����
    ���-���� �� ������������ ��������� Assert � ������������� ������, ����
    �� � ���� ������ �� ������� ������ - ��. ��������� �� ����������
    �� ���� ������� ������������ ������ ������ ���������� ������ � ������,
    �� � ������ Assert ������� ������������ ExAssert }
end;

{ ������� Format � ����������� ���������� }
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

{ �������, ������� ������� ������������ ������ Assert }
function ExAssert (Condition: boolean; const Msg: string): boolean; overload;
begin
  Result := Condition;
  if not Result then InternalWarnings.Add (Msg);
end;

{ �������, ������� ������� ������������ ������ Assert }
function ExAssert (Condition: boolean;
                   const Msg: string;
                   const Params: array of const): boolean; overload;
begin
  Result := ExAssert (Condition, SafeFormat (Msg, Params));
end;

{ ���������� ����� Clone/AddExceptionHeader }
function AddExceptionHeader (E: Exception; Header: string): EStsException;
begin
  Result := EStsException.Clone (E);
  Result.AddHeader (Header);
end;

{ ���������� ����� Clone/AddExceptionHeader }
function AddExceptionHeader (E: Exception; Header: string;
                             Params: array of const): EStsException;
begin
  Result := EStsException.Clone (E);
  Result.AddHeader (Header, Params);
end;

{ ���������� ����� Clone/AddExceptionFooter }
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

{ �������� �������� ���. ���������� ��� ������ ������ ������������ }
procedure EStsException.AfterConstruction;
begin
  inherited;
  Headers := TStringList.Create;
  Footers := TStringList.Create;
end;

{ ����������� �������� ���. ���������� }
destructor EStsException.Destroy;
begin
  inherited;
  FreeAndNil (Headers);
  FreeAndNil (Footers);
end;

{ ������������ ���������� � �������������� ��� native-������� }
class function EStsException.Clone (E: Exception): EStsException;
type
  EStsExceptionClass = class of EStsException;
var
  ExClass: EStsExceptionClass;
begin
  { ���������� �������� nil }
  if not ExAssert (E <> nil, 'EStsException.Clone: E = nil') then
  begin
    Result := EExUtils.Create (SCloningNil);
    exit;
  end;
  { �������� ������ � �������� ��� }
  ExClass := ExceptionMapper.Map (E);
  Result := ExClass.Create ('');
  Result.Assign (E);
end;

{ ��������������� }
procedure EStsException.RaiseSelf;
begin
  CompleteMessage;
  raise Self;
end;

{ ���������� � ��������� ��������� }
procedure EStsException.AddHeader (Header: string;
                                   const Params: array of const);
begin
  AddHeader (SafeFormat (Header, Params));
end;

{ ���������� � ��������� ��������� }
procedure EStsException.AddHeader (Header: string);
begin
  Header := Trim (Header);
  if Header = '' then exit;
  if CheckHeaders then Headers.Insert (0, Header);
  CompleteMessage;
end;

{ ���������� � ��������� ������� ������ }
procedure EStsException.AddFooter (Footer: string;
                                   const Params: array of const);
begin
  AddFooter (SafeFormat (Footer, Params));
end;

{ ���������� � ��������� ������� ������ }
procedure EStsException.AddFooter (Footer: string);
begin
  Footer := Trim (Footer);
  if Footer = '' then exit;
  if CheckFooters then Footers.Add (Footer);
  CompleteMessage;
end;

{ ���������� ��������� �������������� ���������� }
procedure EStsException.AddParam (const Name: string; const Value: variant);
begin
  with Params [AddParam (Name)] do
  begin
    ParamType := eptVariant;
    VarValue := Value;
  end;
end;

{ ���������� ��������� �������������� ���������� }
procedure EStsException.AddParam (const Name: string; const Value: TObject);
begin
  with Params [AddParam (Name)] do
  begin
    ParamType := eptObject;
    ObjValue := Value;
  end;
end;

{ ���������� ��������� �������������� ���������� }
procedure EStsException.AddParam (const Name: string; const Value: TClass);
begin
  with Params [AddParam (Name)] do
  begin
    ParamType := eptClass;
    ClassValue := Value;
  end;
end;

{ ������� �������� ���������� }

function EStsException.ParamCount: integer;
begin
  Result := Length (Params);
end;

function EStsException.Param (ParamNo: integer): TExceptionParam;
begin
  if (ParamNo >= Low (Params)) and (ParamNo <= High (Params))
    then Result := Params [ParamNo]
    else { ������ �������� �� ��������� - ������ ������ };
end;

{ ����������� ���������� ���������� �� ������� � ������ }
procedure EStsException.Assign (Source: Exception);
var StsSource: EStsException absolute Source;
begin
  if not ExAssert (Source <> nil, 'EStsException.Assign: Source = nil') then exit;
  { �������� ����� Exception }
  Self.Message := Source.Message;
  Self.HelpContext := Source.HelpContext;
  { �������� ����� EStsException }
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

{ ������������ ������� ������ ��������� �� ������ }
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

{ ������������ ������ ��������� �� ������ ��� ���������� �������� }
function EStsException.NoMessage: string;
begin
  Result := SafeFormat (SNoMessage, [Self.ClassName]);
end;

{ �������� ������������� ������������ �������� }

function EStsException.CheckHeaders: boolean;
begin
  Result := ExAssert (Headers <> nil, 'EStsException: Headers = nil');
end;

function EStsException.CheckFooters: boolean;
begin
  Result := ExAssert (Footers <> nil, 'EStsException: Footers = nil');
end;

{ ������� ������ }
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

{ ����� ������ �� ���������� }
function ExceptionMapIndex (Source: ExceptClass): integer;
begin
  Result := High (ExceptionMap);
  while Result >= Low (ExceptionMap) do
    if ExceptionMap [Result].Source = Source
      then exit
      else Dec (Result);
end;

{ ����� ����� �������� }
class procedure ExceptionMapper.Clear;
begin
  SetLength (ExceptionMap, 0);
end;

{ ��������� ����� �������� �� ��������� }
class procedure ExceptionMapper.SetDefault;
begin
  Clear;
  Register (Exception, ENative);
  Register (SysUtils.EOSError, ExUtils.EOSError);
  Register (SysUtils.EInOutError, ExUtils.EOSError);
  Register (EStsException, nil);
  SetFileStreamErrors (true);
end;

{ ���������� �������� ������ �����-������ }
class procedure ExceptionMapper.SetFileStreamErrors (AExpectable: boolean);
begin
  if AExpectable
    then Register (EFileStreamError, EExpectable)
    else Register (EFileStreamError, ENative);
end;

{ ���������� ���� ��������� ������ �� ���������� }
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

{ �������� ������ �� ���������� }
class procedure ExceptionMapper.Remove (Source: ExceptClass);
var I, H: integer;
begin
  I := ExceptionMapIndex (Source);
  if I < 0 then exit;
  H := High (ExceptionMap);
  if I < H then ExceptionMap [I] := ExceptionMap [H];
  SetLength (ExceptionMap, H);
end;

{ ������ ��������� ������ ���������� �� EStsException }
class function ExceptionMapper.Map (Source: Exception): EStsExceptionClass;
begin
  if ExAssert (Source <> nil, 'ExceptionMapper.Map: Source = nil')
    then Result := Map (ExceptClass (Source.ClassType))
    else Result := EStsException;
end;

{ ������ ��������� ������ ���������� �� EStsException }
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

{ ���������� ��������� � �������� }
class procedure InternalWarnings.Add (const Warning: string);
begin
  if Warnings = nil then exit; { ����� ������ ��������������, ��� ����� ��������� }
  if Warnings.IndexOf (Warning) >= 0 then exit; { ��� ���� }
  Warnings.Add (Warning);
end;

{ ���������� ���������� ��� ����� ���������� �������������� � ����������� ��� ����� }
class procedure InternalWarnings.AddListener (Handler: TWarningEvent);
var L: integer;
begin
  if not Assigned (Handler) then exit;
  { ��������� �� ������ }
  RemoveListener (Handler);
  { ��� ������ ������� }
  L := Length (Listeners);
  SetLength (Listeners, L + 1);
  Listeners [L] := Handler;
end;

{ �������� ���������� }
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
