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

{ ----- ������� ������ ---------------------------------------------------------

??.??.2006 ��������� ������������ ����������� ������� � ������ CmpUtils. ������
           �������������������� ��������.

01.05.2008 ������ �������� ����������� � ����������� � ������������ � ���������
           ������. ����� EComponentException ������������ � EComponent.
           ��������� ������ HandlerOwned, HandlerOwnedBy. �������� ������
           FreeNotifier � ������� FreeNotifier ��� ������� � ����. EComponent
           ���������� FreeNotifier, ����� ����������������� ���������
           ����������� ���������� � ���� ��������� ����������.
15.05.2008 ��������� ��������������� Restrict_ExUtils � Restrict_FreeNotifier.

------------------------------------------------------------------------------ }

{ ----- ��������������� --------------------------------------------------------

������� � ����� ������� ����������� ��������������� Restrict_ExUtils, ����
� ��� ��� ������ ExUtils, � �� �� ����������� ��� ����������. ��� ���� ������
���������� ������ �������� ��������������� ��������������� �� Exception. 

������� � ����� ������� ����������� ��������������� Restrict_FreeNotifier, ����
� ��� ��� ������ FreeNotifier, � �� �� ����������� ��� ����������. ��� ����
�� ������ �������� �������� ������� FreeNotifier, ��������������� ������ �
����������� ����� ������, � ����� EComponent �������� ����������� ���������
����������� �� ����������� ���������� � �������� ��������� ���������� (������,
���������� ������������ ������ finally)

� ������� ������� ����� ����������� � ��������� �������, � �� � ����� �������.
������ ��� ����� ���:

1. ����������� ���������� � ����� ����� �� ������ ���� ���������
2. ��������� � ������ ������� ����� ����������� ��� ���� ���� ������, �� ������
   ����������� �������.

------------------------------------------------------------------------------ }

unit CmpUtils;

interface

uses Classes, SysUtils, Forms, Dialogs
  {$IfNDef Restrict_ExUtils}, ExUtils {$EndIf}
  {$IfNDef Restrict_FreeNotifier}, FreeNotifier {$EndIf};

type

  { �������� ������� CreateComponent � ������ ������ }
  TCreateComponentErrorAction = (eaDefault, eaResult, eaMessage, eaException);

  { ��������� ������ }

  {$IfDef Restrict_ExUtils}
  EApplication = Exception;
  EModule = Exception;
  {$EndIf} 

  EFormSurplus = class (EApplication);
  EFormNotFound = class (EApplication);

  { ����� ��� ������, ����������� � ����������� }
  EComponent = class (EModule)
  private
    FComponent: TComponent;
    {$IfNDef Restrict_FreeNotifier}
    FComponentFreed: boolean;
    procedure FreeComponentHandler (AComponent: TComponent);
    {$EndIf}
  public
    constructor Create (AComponent: TComponent; const AMessage: string);
    constructor CreateFmt (AComponent: TComponent; const AMessage: string;
                                                   const Params: array of const);
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  public
    property Component: TComponent read FComponent;
    {$IfNDef Restrict_FreeNotifier}
    property ComponentFreed: boolean read FComponentFreed;
    {$EndIf}
  end;

{ �������� ������� ���������� ����, ���� ��� �������� }
function CreateComponent (var ComponentCreated;
                          Owner: TComponent;
                          ClassName, DefaultName: string;
                          ErrorAction: TCreateComponentErrorAction): boolean;

{ ������������ ������ "������� �����" ���������� }
function FormatComponentName (Component: TComponent): string;

{ ���������� ���������� �����, ����������� � �������� ��������� }
procedure UniqueComponentName (Component: TComponent;
                               DefaultName: string = '');

{ ��������� ���� ������������ ������� �� ��������� }
function EqualHandlers (const First, Second): boolean;

{ ��������� ��������� ���������� ����������� ������� }
function HandlerOwner (const Handler): TObject;

{ �������� ����, ��� ���������� ������� ����������� ���������� ���������� }
function HandlerOwnedBy (const Handler; AOwner: TObject): boolean;

{ ����� ����� �� ����� ����� �/��� ����� ������ }
function FormByName (const AName, AClassName: string): TForm;

{$IfNDef Restrict_FreeNotifier}
{ ������� ��� ������� � ��������� ���������� �� ����������� ��������� }
function FreeNotifier: TFreeNotifier;
{$EndIf}

implementation

resourcestring
  SCantCreate   = '�� ������� ������� ��������� [%s] - ����� �� ������';
  SFormSurplus  = '��������� ������ ������������� ����� ��������� ����';
  SFormNotFound = '�� ���� ����� �� ������������� ��������� ������';
  SComponent    = '���������';

{ ������������ ������ "������� �����" ���������� }
function FormatComponentName (Component: TComponent): string;
var
  Prefix: string;
  Exists: boolean;
begin
  Exists := Assigned (Component);
  if Exists and Assigned (Component.Owner)
    then Prefix := FormatComponentName (Component.Owner) + '.'
    else Prefix := '';
  if Exists
    then Result := Component.Name
    else Result := '(nil)';
  if Result = '' then
    Result := Format ('%s ($%p)', [Component.ClassName, pointer (Component)]);
  Result := Prefix + Result;
end;

{ ���������� ���������� �����, ����������� � �������� ��������� }
procedure UniqueComponentName (Component: TComponent;
                               DefaultName: string = '');
var
  i: integer;
  NewName: string;
begin
  if not Assigned (Component) then exit;
  if DefaultName = '' then DefaultName := Copy (Component.ClassName, 2, 1000);
  i := 0;
  NewName := DefaultName;
  if Assigned (Component.Owner) then
    while Component.Owner.FindComponent (NewName) <> nil do
    begin
      Inc (i);
      NewName := Format ('%s%d', [DefaultName, i]);
    end;
  Component.Name := NewName;
end;

{ ��������� ���� ������������ ������� �� ��������� }
function EqualHandlers (const First, Second): boolean;
var
  M1: TMethod absolute First;
  M2: TMethod absolute Second;
begin
  Result := (M1.Code = M2.Code) and (M1.Data = M2.Data);
end;

{ ��������� ��������� ���������� ����������� ������� }
function HandlerOwner (const Handler): TObject;
var M: TMethod absolute Handler;
begin
  Result := TObject (M.Data);
end;

{ �������� ����, ��� ���������� ������� ����������� ���������� ���������� }
function HandlerOwnedBy (const Handler; AOwner: TObject): boolean;
var M: TMethod absolute Handler;
begin
  Result := (HandlerOwner (Handler) = AOwner);
end;

{ �������� ������� ���������� ����, ���� ��� �������� }
function CreateComponent (var ComponentCreated;
                          Owner: TComponent;
                          ClassName, DefaultName: string;
                          ErrorAction: TCreateComponentErrorAction): boolean;
var
  Component     : TComponent absolute ComponentCreated;
  ComponentClass: TComponentClass;
  Msg           : string;
begin
  Component := nil;
  Result    := false;
  { ������ ���������� ����� }
  ComponentClass := TComponentClass (GetClass (ClassName));
  if not Assigned (ComponentClass) then
  begin
    Msg := Format (SCantCreate, [ClassName]);
    if ErrorAction = eaDefault then
      if Assigned (Owner) and (csDesigning in Owner.ComponentState)
        then ErrorAction := eaMessage
        else ErrorAction := eaException;
    case ErrorAction of
      eaMessage  : MessageDlg (Msg, mtError, [mbOk], 0);
      eaException: raise EClassNotFound.Create (Msg);
    end;
    exit;
  end;
  { �������� ��������� }
  Component := ComponentClass.Create (Owner);
  UniqueComponentName (Component, DefaultName);
  Result := true;
end;

{ ����� ����� �� ����� ����� �/��� ����� ������ }
function FormByName (const AName, AClassName: string): TForm;
var i: integer;
begin
  Result := nil;
  with Screen do
    for i := 0 to FormCount - 1 do
      if ((AName = '') or SameText (AName, Forms [i].Name)) and
         ((AClassName = '') or SameText (AClassName, Forms [i].ClassName)) then
      begin
        if Assigned (Result) then raise EFormSurplus.Create (SFormSurplus);
        Result := Forms [i];
      end;
  if not Assigned (Result) then raise EFormNotFound.Create (SFormNotFound);
end;

{$IfNDef Restrict_FreeNotifier}
{ ������� ��� ������� � ��������� ���������� �� ����������� ��������� }
function FreeNotifier: TFreeNotifier;
begin
  {$Warnings Off}
  Result := TFreeNotifier.Create;
  {$Warnings On}
end;
{$EndIf}

{ EComponent }

procedure EComponent.AfterConstruction;
begin
  inherited;
  {$IfNDef Restrict_ExUtils}
  AddParam (SComponent, FComponent);
  {$EndIf}
  {$IfNDef Restrict_FreeNotifier}
  FreeNotifier.AddListener (FreeComponentHandler, FComponent);
  {$EndIf}
end;

procedure EComponent.BeforeDestruction;
begin
  {$IfNDef Restrict_FreeNotifier}
  FreeNotifier.RemoveAllListeners (Self);
  {$EndIf}
  inherited;
end;

constructor EComponent.CreateFmt (AComponent: TComponent;
                                  const AMessage: string;
                                  const Params: array of const);
begin
  FComponent := AComponent;
  inherited CreateFmt (AMessage, Params);
end;

constructor EComponent.Create (AComponent: TComponent;
                               const AMessage: string);
begin
  FComponent := AComponent;
  inherited Create (AMessage);
end;

{$IfNDef Restrict_FreeNotifier}
procedure EComponent.FreeComponentHandler (AComponent: TComponent);
begin
  if AComponent <> FComponent then exit;
  FComponentFreed := true;
  FComponent := nil;
end;
{$EndIf}

end.
