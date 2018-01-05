////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         ����������� ��������� ���������� �� ������������ ���������         //
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

unit FreeNotifier;

{ ----- ���������� ������ ------------------------------------------------------

� ������� ������ AddListener � ��������� �������������� ������� ����������
�������� ���������� �� ����������� ���������� ����������. ����� ����� �������
��������, ��������� ������� �������� �� ���� ������� ������ ����������
����������� �������. �������� �������������� ������ - ��������� �����
����������� ��� ���������� ��������, �� ���������� ������������ (� ������
�� ���������� ��������������� ������������ �������� FreeNotification). 

��������� ����� ���������� �� ���������� � ������� ������ RemoveListener �
��� ������� ������ ������� ��� ����� ����������� ������������, ���� �� ��������
����������� - � ��������� ������ ���������� ������� ����� ������ ��� ���
������������� ������� � ����������� ������ �������������. ��� �����������
��������� �������� �������������� ������� ������ �� ��� �� ���������� ������.
��� ���������� ������� �������� ����� RemoveAllListeners, ������� ���������
������� ����� ��������� ���������� �� ���� ����������, ������� ��
���������������.

������ � ��������� ������ �������������� � ������� ������� FreeNotifier,
����������� � ������� CmpUtils � FreeUtils; ��������������� �������� ������
� ������ ����� ������������� �� ���������.

------------------------------------------------------------------------------ }

{ ----- ������� ������ ---------------------------------------------------------

01.05.2008 ������ ������ ������

------------------------------------------------------------------------------ }

interface

uses Classes, Singleton;

type
  { ���������� �� ����������� ���������� }
  TFreeListener = procedure (AComponent: TComponent) of object;

  { �������� ���������� �� ����������� }
  TFreeNotifier = class (TSingleton)
  public
    procedure AddListener (Listener: TFreeListener;
                           Component: TComponent); overload; virtual; abstract;
    procedure AddListener (Listener: TFreeListener;
                           Components: array of TComponent); overload;
    procedure RemoveListener (Listener: TFreeListener;
                              Component: TComponent); overload; virtual; abstract;
    procedure RemoveListener (Listener: TFreeListener;
                              Components: array of TComponent); overload;
    procedure RemoveAllListeners (AOwner: TObject); virtual; abstract;
  end;

implementation

uses SysUtils, RecordList, CmpUtils;

{ FreeNotifier }

type

  { ���������� � ������������������ ������������ }
  TFreeNotifierData = class (TRecordList)
  protected
    function GetListener (ArrIndex, Index: integer): TFreeListener;
    procedure SetListener (ArrIndex, Index: integer; NewListener: TFreeListener);
  public
    constructor Create; override;
  public
    property WaitFor [ArrIndex: integer]: TComponent index 0
             read GetComponent write SetSortComponent;
    property Handler [ArrIndex: integer]: TFreeListener index 1
             read GetListener write SetListener;
    property Qnt [ArrIndex: integer]: integer index 2
             read GetInt write SetInt;
  end;

  { ���������, ��������� free notifications }
  TSignaller = class (TComponent)
  protected
    function Data: TFreeNotifierData;
  public
    procedure Notification (AComponent: TComponent;
                            AOperation: TOperation); override;
  end;

  { ���������� ���������� FreeNotifier-� }
  TFreeNotifierImpl = class (TFreeNotifier)
  private
    Data: TFreeNotifierData;
    Signaller: TSignaller;
    procedure FreeListenerOwnerHandler (AOwner: TComponent);
  public
    procedure InitSingleton; override;
    procedure DoneSingleton; override;
  public
    procedure AddListener (Listener: TFreeListener;
                           Component: TComponent); override;
    procedure RemoveListener (Listener: TFreeListener;
                              Component: TComponent); override;
    procedure RemoveAllListeners (AOwner: TObject); override;
  end;

constructor TFreeNotifierData.Create;
begin
  inherited;
  RecordLength := 3;
  SetSortOrder (0, ftComponent);
end;

{ ������ ������� ��� �������� ���� TFreeListener }

function TFreeNotifierData.GetListener (ArrIndex, Index: integer): TFreeListener;
begin
  Result := TFreeListener (GetNotifyEvent (ArrIndex, Index));
end;

procedure TFreeNotifierData.SetListener (ArrIndex, Index: integer; NewListener: TFreeListener);
begin
  SetNotifyEvent (ArrIndex, Index, TNotifyEvent (NewListener));
end;

{ TFreeNotifier }

procedure TFreeNotifier.AddListener (Listener: TFreeListener;
                                     Components: array of TComponent);
var i: integer;
begin
  for i := Low (Components) to High (Components) do
    AddListener (Listener, Components [i]);
end;

procedure TFreeNotifier.RemoveListener (Listener: TFreeListener;
                                        Components: array of TComponent);
var i: integer;
begin
  for i := Low (Components) to High (Components) do
    RemoveListener (Listener, Components [i]);
end;

{ ���������� TFreeNotifier }

procedure TFreeNotifierImpl.InitSingleton;
begin
  inherited;
  Data := TFreeNotifierData.Create;
  Signaller := TSignaller.Create (nil);
end;

procedure TFreeNotifierImpl.DoneSingleton;
begin
  inherited;
  FreeAndNil (Signaller);
  FreeAndNil (Data);
end;

{ ����������� ������������������ � ���������� }
procedure TFreeNotifierImpl.AddListener (Listener: TFreeListener;
                                         Component: TComponent);
var
  i, L, H: integer;
  Handler: TFreeListener;
  ListenerOwner: TObject;
begin
  if not Assigned (Component) or not Assigned (Listener) then exit;
  Assert (Data <> nil);
  { ���� ���������� ��� ����, �������� ������� }
  Data.SortIndexRange (Component, L, H);
  for i := L to H do
  begin
    Handler := Data.Handler [i];
    if EqualHandlers (Listener, Handler) then
    begin
      Data.Qnt [i] := Data.Qnt [i] + 1;
      exit;
    end;
  end;
  { ����� ������� ����� ������ }
  Signaller.FreeNotification (Component);
  i := Data.InsertKey (Component);
  Data.Handler [i] := Listener;
  Data.Qnt [i] := 1;
  { ���������� ����� ��������� ����������� ���������� - ��������� ����������� }
  ListenerOwner := HandlerOwner (Listener);
  if (ListenerOwner <> Self) and (ListenerOwner is TComponent) then
    AddListener (FreeListenerOwnerHandler, TComponent (ListenerOwner));
end;

{ ������ ������������������ � ���������� }
procedure TFreeNotifierImpl.RemoveListener (Listener: TFreeListener;
                                            Component: TComponent);
var
  i, L, H: integer;
  Handler: TFreeListener;
begin
  Assert (Data <> nil);
  { ������ ����������� ��� ���������� ���������� }
  Data.SortIndexRange (Component, L, H);
  { ������ ����������� �� ����������� ������� }
  for i := H downto L do
  begin
    Handler := Data.Handler [i];
    if EqualHandlers (Listener, Handler) then
    begin
      { �� � �������� ������� ���� ������ ������ }
      if Data.Qnt [i] = 1
        then Data.Delete (i)
        else Data.Qnt [i] := Data.Qnt [i] - 1;
      exit;
    end;
  end;
end;

{ �������� ���� ������� � ��������� ���������� ������������ }
procedure TFreeNotifierImpl.RemoveAllListeners (AOwner: TObject);
var
  i: integer;
  Handler: TFreeListener;
begin
  Assert (Data <> nil);
  for i := Data.Count - 1 downto 0 do
  begin
    Handler := Data.Handler [i];
    if HandlerOwnedBy (Handler, AOwner) then Data.Delete (i);
  end;
end;

{ ������� �� �������� ��������� ����������� }
procedure TFreeNotifierImpl.FreeListenerOwnerHandler (AOwner: TComponent);
begin
  RemoveAllListeners (AOwner);
end;

{ ������� �� ����������� ��������� }
procedure TSignaller.Notification (AComponent: TComponent;
                                   AOperation: TOperation);
var
  i, L, H: integer;
  Handlers: array of TFreeListener;
begin
  inherited;
  if AOperation <> opRemove then exit;
  { ������ ����������� }
  Assert (Data <> nil);
  Data.SortIndexRange (AComponent, L, H);
  if H < L then exit;
  { ������� �� � ������������� �����, ����� �� �������� � ���������� �����������
    ������ ������������ }
  SetLength (Handlers, H - L + 1);
  for i := L to H do
    Handlers [i - L] := Data.Handler [i];
  { �� � ������� ������� ����������� }
  for i := Low (Handlers) to High (Handlers) do
    if Assigned (Handlers [i]) then Handlers [i] (AComponent);
end;

function TSignaller.Data: TFreeNotifierData;
begin
  Result := TFreeNotifierImpl.Create.Data;
end;

initialization
  TFreeNotifierImpl.Create.RegisterSupport ([TFreeNotifier]);
end.
