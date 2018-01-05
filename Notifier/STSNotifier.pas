////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                           Sanders the Softwarer                            //
//                                                                            //
//    TSTSNotifier - ��������� ��� �������� � ��������� ������� ����������    //
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

------------------------------------------------------------------------------ }

{ ----- �������� ---------------------------------------------------------------

��������� STSNotifier ����������� � ��������� �������������  ��������, ��������,
������������ ������������, � � ������ ���������� ����� �������  ���������  ����-
�������������� ��� ����� ������ ����������� �������. ���  ������ � ���� �� ����-
��� ����� ���� ���������������� ������� ������ ������������; ������ �����, �����
� �. �. ����� ��������� � ������� ����������� ����������  �  �������  ����������
TSTSNotiferLink. ����� ���������� ��������� ������ �������������� ������ �������
�� ��������  �������  ������� - ��������, ������  ����  �����  �  ������������ �
������� ������ ������������ ����������� ���� ��������, ������  ���  ����� �� ��-
��������� ������-���� ������������  ������, ������� ����� �����  ����������  ���
������� ������ ������ ����. ����������, ����  ��������� ������� ����� ���� ����-
������������ � ���������� �������, ���� ������� ���������� �� �����������  �����
�� ���� � �����, �� �� ������������ ����� �������.

������������� ����������� �������� �������� ���������� DataModule, � ������� ��-
��� ��������� ���������� TSTSNotifier. ���� ������ �� ����� ������������ �������
������ �������, �������� �����������, � ������ ����� ���������� �������� ������-
�������� ������ �������� ������� ��� ���� ���������� � ����������  ��������; ���
���� ������������ ��� ������ ������ ������ ������ �� ������  �����  ���� � �����
�, ��������������, �����  ���� �������� ��� ������������� � ��������� ������ ��-
�����. ���������� ������ ������� �������� �������� ��������� �������� ����������
�� ������� ������������ ������, �  ��� ����� ��������������� ��������� ��������-
��� ������ � ���� �� ������.

------------------------------------------------------------------------------ }

{ ----- ������������� ���������� -----------------------------------------------

� ������-����� ���������� ������� � ������ ������  ���������  TSTSNotifier. ����
Description - �� ����, ��� ����������� � ���������� - ����� ����  ���������  ���
���������� ����������, � ������ ������ ������� ��������� ���������. ��� �������-
�� ������� � ������ �����, � ������� ����� ��������������  �������, �������  ��-
���������� ��������� TSTSNotifierLink, ��������� ��� � ���������� TSTSNotifier �
��������� ���������� ������� OnNotification. � ���-����� ��������  �����  ������
����������� ������������ � ������� ������ RegisterNotification � ��������  �����
������������������� ����������� ������� RemoveNotification.

������, � ������� ���������������� �������, ������ ������������ ���������� � ��-
����� ������ Fire. ��� ���������� ����� ����  ��������  ��������������  ������ �
������������ �������. ��� ����� � ��������� ������� �������� Data ����  TObject,
����������� ��������, ���������� ��� ������ ������ Fire. ��� ������������� ����-
���� AutoFreeData ���������� ������ ������������ � ����� ���������� ������ Free;
� ��������� ������ �������� Data �������� �������� nil, �� �� ����������� �����-
�� ������ ������������ ��������� ����������. ���������� ���������� ����� ������-
����� �������� ������ Data; ��� ���� ������� ���������, ��� ������� ������ ����-
�������������� ������������ �� ��������� � ����� ��������� �����.

����������, ����������� � ������ ��� ��������� ����������, ��  ������  ������ ��
����������  ������  �������.  �������  ����������, ����������  ��   ������������
OnNotification, ���������� � ���������� ������� OnException, �  ���  ���  �����-
����� - � Application.HandleException, ����� ���� ������������ ���������� ������
�������.

------------------------------------------------------------------------------ }

{ ----- ������� ��������� ------------------------------------------------------

26.09.2001 ���������� ������� �� ������� ���������� TNotifyList, ���������� ���
           ������� CTR View � �������� AlSoft. � ������ ������ TSTSNotifier
           ����������� �������� Description, ������ RegisterNotification,
           RemoveNotification, Fire. � ���������� TSTSNotifierLink �����������
           �������� Notifier � OnNotification, ����� Fire.
19.07.2004 ��������� ������� OnException. ��������� ���� �����������.
19.11.2004 ��������� �������� Data � ��������������� �������� ������ Fire,
           �������� AutoFreeData. ��� ������ ������ STSNotifierLink.Fire ���
           ������������� �������� Notifier ��������� ���������� (������ �����
           ����� �������������).
02.12.2006 ��������� �������� DataString � ����� Fire (string)

------------------------------------------------------------------------------ }

unit STSNotifier ;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, RecordList ;

type

  ESTSNotifier = class ( Exception ) ;
  TExceptionEvent = procedure ( Sender : TObject ; E : Exception ;
                                out ReRaise : boolean ) of object ;

  TNotifications = class ( TRecordList )
  public
    constructor Create ; override ;
  public
    property Event [ ArrIndex : integer ] : TNotifyEvent index 0
             read GetNotifyEvent write SetNotifyEvent ;
    property Sender [ ArrIndex : integer ] : TObject index 1
             read GetObj write SetObj ;
  end ;

  { �������� ��������� - ������ ���������� }
  TSTSNotifier = class ( TComponent )
  private
    FDescription  : TStrings ;
    Notifications : TNotifications ;
    FOnException  : TExceptionEvent ;
    FAutoFreeData : boolean ;
    FData         : TObject ;
    FDataString   : string ;
  protected
    { ����� ������������ ������� }
    procedure DoException ( E : Exception ; out ReRaise : boolean ) ; dynamic ;
    { ������ ������� }
    function GetDescription : TStrings ;
    procedure SetDescription ( NewStrings : TStrings ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
    procedure Notification ( AComponent : TComponent ;
                             AOperation : TOperation ) ; override ;
    { �������� ������ }
    procedure RegisterNotification ( ANotification : TNotifyEvent ) ;
    procedure RemoveNotification ( ANotification : TNotifyEvent ) ;
    procedure Fire ( AData : TObject = nil ) ; overload ;
    procedure Fire ( AData : string ) ; overload ;
    procedure Fire ( AData : TObject ; ADataString : string ) ; overload ;
  public
    property Data : TObject read FData write FData ;
    property DataString : string read FDataString write FDataString ;
  published
    property AutoFreeData : boolean read FAutoFreeData write FAutoFreeData ;
    property Description : TStrings read GetDescription write SetDescription ;
    property OnException : TExceptionEvent read FOnException write FOnException ;
  end ;

  { �������������� ��������� - ��������� � ������ ���������� }
  TSTSNotifierLink = class ( TComponent )
  private
    FNotifier     : TSTSNotifier ;
    FNotification : TNotifyEvent ;
  protected
    procedure NotificationHandler ( Sender : TObject ) ;
    procedure DoNotification ( Sender : TObject ) ; virtual ;
    { ������ ������� }
    procedure SetNotifier ( NewNotifier : TSTSNotifier ) ;
  public
    destructor Destroy ; override ;
    procedure Notification ( AComponent : TComponent ;
                             Operation  : TOperation ) ; override ;
    { �������� ������ }
    procedure Fire ( AData : TObject = nil ) ; overload ;
    procedure Fire ( AData : string ) ; overload ;
    procedure Fire ( AData : TObject ; ADataString : string ) ; overload ;
  published
    property Notifier : TSTSNotifier read FNotifier write SetNotifier ;
    property OnNotification : TNotifyEvent read FNotification
                                           write FNotification ;
  end ;

procedure Register;

implementation

uses CmpUtils ;

resourcestring
  SNotifierRequired = '�������� �� ����� ���� ��������� ��� �������� ' +
                      '� ���������� TSTSNotifier' ;

procedure Register;
begin
  RegisterComponents ('Sanders the Softwarer', [TSTSNotifier, TSTSNotifierLink]);
end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                                TSTSNotifier                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

constructor TSTSNotifier.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  FDescription  := TStringList.Create ;
  Notifications := TNotifications.Create ;
end ;

destructor TSTSNotifier.Destroy ;
begin
  inherited ;
  FreeAndNil ( FDescription ) ;
  FreeAndNil ( Notifications ) ;
end ;

procedure TSTSNotifier.Notification ( AComponent : TComponent ;
                                      AOperation : TOperation ) ;
var
  i : integer ;
  E : TNotifyEvent ;
  M : TMethod absolute E ;
begin
  inherited ;
  if AOperation <> opRemove then exit ;
  with Notifications do
    for i := Count - 1 downto 0 do
      if Sender [ i ] = AComponent then Delete ( i ) ;
end;

{ �������� ������ }

procedure TSTSNotifier.RegisterNotification ( ANotification : TNotifyEvent ) ;
var
  M : TMethod absolute ANotification ;
  E : TNotifyEvent ;
  i : integer ;
begin
  if csDestroying in ComponentState then exit ;
  for i := 0 to Notifications.Count - 1 do
  begin
    E := Notifications.Event [ i ] ;
    if EqualHandlers ( ANotification, E ) then exit ;
  end ;
  i := Notifications.Add ;
  Notifications.Event  [ i ] := ANotification ;
  Notifications.Sender [ i ] := TObject ( M.Data ) ;
  if TObject ( M.Data ) is TComponent then
    TComponent ( M.Data ).FreeNotification ( Self ) ;
end ;

procedure TSTSNotifier.RemoveNotification ( ANotification : TNotifyEvent ) ;
var
  i : integer ;
  E : TNotifyEvent ;
begin
  if csDestroying in ComponentState then exit ;
  for i := Notifications.Count - 1 downto 0 do
  begin
    E := Notifications.Event [ i ] ;
    if EqualHandlers ( ANotification, E ) then Notifications.Delete ( i ) ;
  end ;
end ;

procedure TSTSNotifier.Fire ( AData : TObject = nil ) ;
var
  Notification : TNotifyEvent ;
  ReRaise      : boolean      ;
  i            : integer      ;
begin
  if csDestroying in ComponentState then exit ;
  try
    FData := AData ;
    for i := Notifications.Count - 1 downto 0 do
    begin
      if i >= Notifications.Count then continue ;
      Notification := Notifications.Event [ i ] ;
      if Assigned ( Notification ) then
        try
          Notification ( Self ) ;
        except
          on E : EAccessViolation do
            begin
              Notifications.Delete ( i ) ;
              raise ;
            end ;
          on E : Exception do
            begin
              DoException ( E, ReRaise ) ;
              if ReRaise then raise ;
            end ;
        end ;
    end ;
  finally
    FDataString := '' ;
    if AutoFreeData then FData.Free ;
    FData := nil ;
  end ;
end ;

procedure TSTSNotifier.Fire ( AData : string ) ;
begin
  FDataString := AData ;
  Fire ;
end ;

procedure TSTSNotifier.Fire ( AData : TObject ; ADataString : string ) ;
begin
  FDataString := ADataString ;
  Fire ( AData ) ;
end ;

{ ����� ������������ ������� }

procedure TSTSNotifier.DoException ( E : Exception ; out ReRaise : boolean ) ;
begin
  ReRaise := false ;
  if Assigned ( FOnException )
    then FOnException ( Self, E, ReRaise )
    else Application.ShowException ( E ) ;
end ;

{ ������ ������� }

function TSTSNotifier.GetDescription : TStrings ;
begin
  GetDescription := FDescription ;
end ;

procedure TSTSNotifier.SetDescription ( NewStrings : TStrings ) ;
begin
  FDescription.Assign ( NewStrings ) ;
end ;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                              TSTSNotifierLink                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

destructor TSTSNotifierLink.Destroy ;
begin
  Notifier := nil ;
  inherited ;
end ;

procedure TSTSNotifierLink.Notification ( AComponent : TComponent ;
                                          Operation  : TOperation ) ;
begin
  if ( AComponent = Notifier ) and ( Operation = opRemove )
    then Notifier := nil ;
  inherited ;
end ;

{ �������� ������ }

procedure TSTSNotifierLink.Fire ( AData : TObject = nil ) ;
begin
  if Assigned ( Notifier )
    then Notifier.Fire ( AData )
    else raise ESTSNotifier.Create ( SNotifierRequired ) ;
end ;

procedure TSTSNotifierLink.Fire ( AData : string ) ;
begin
  if Assigned ( Notifier )
    then Notifier.Fire ( AData )
    else raise ESTSNotifier.Create ( SNotifierRequired ) ;
end ;

procedure TSTSNotifierLink.Fire ( AData : TObject ; ADataString : string ) ;
begin
  if Assigned ( Notifier )
    then Notifier.Fire ( AData, ADataString )
    else raise ESTSNotifier.Create ( SNotifierRequired ) ;
end ;

{ ���������� ������ }

procedure TSTSNotifierLink.NotificationHandler ( Sender : TObject ) ;
begin
  if not ( csDestroying in ComponentState ) then DoNotification ( Sender ) ;
end ;

procedure TSTSNotifierLink.DoNotification ( Sender : TObject ) ;
begin
  if Assigned ( FNotification ) then FNotification ( Sender ) ;
end ;

{ ������ ������� }

procedure TSTSNotifierLink.SetNotifier ( NewNotifier : TSTSNotifier ) ;
begin
  if NewNotifier = Notifier then exit ;
  if Assigned ( Notifier ) then
  begin
    Notifier.RemoveNotification ( NotificationHandler ) ;
    Notifier.RemoveFreeNotification ( Self ) ;
  end ;
  FNotifier := NewNotifier ;
  if Assigned ( Notifier ) then
  begin
    Notifier.RegisterNotification ( NotificationHandler ) ;
    Notifier.FreeNotification ( Self ) ;
  end ;
end ;

{ TNotifications }

constructor TNotifications.Create ;
begin
  inherited ;
  RecordLength := 2 ;
end ;

end.
