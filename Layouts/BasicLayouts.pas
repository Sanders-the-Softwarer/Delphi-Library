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

{ ----- �������� ---------------------------------------------------------------

� ���� ����� ��������� �������, ������� ��������� ������������.

TDelphiLayout    ������� �������� ������������ Delphi. �����, �� ����, ��������
                 ������� �������, �� ������� ������������� �������������
                 TabOrder-� � ��������� ������ ����� ���������������� layout-��.

TNotebookLayout  �������� ���������� ������������ ���������� TNotebook. � ������
                 ������ ������� ����� ������ ���� �� �������� ���������,
                 �������� �������� ActivePage. ��� ��������� ActivePage, � �����
                 ��� ��������� �������� Visible �������� ��������� �����
                 ��������� ���������� ������� ������ �������.

------------------------------------------------------------------------------ }

unit BasicLayouts ;

interface

uses
  Messages, Types, Classes, SysUtils, Controls, ExtCtrls, Forms, Math, Dialogs,
  Buttons, BaseLayout ;

type

  { ������� ������������ � ����� Delphi }

  TCustomDelphiLayout = class ( TLayout )
  private
    SaveControl : TControl ;
    SaveRect : TRect ;
  protected
    { ������������� ������������ ������� }
    procedure AlignControls ( AControl : TControl ; var ARect : TRect ) ; override ;
    procedure DoLayout ; override ;
  end ;

  { ������������ �-�� TNotebook }

  TCustomNotebookLayout = class ( TLayout )
  private
    FActivePage : TControl ;
  protected
    { ������������� ������������ ������� }
    procedure DoLayout ; override ;
    { ������� ������ }
    procedure SelectControl ( AControl : TControl ) ;
    procedure SelectOther ( AControl : TControl ) ;
    { ������ ������� }
    procedure SetActivePage ( NewControl : TControl ) ;
  public
    { ������������� ������������ ������� }
    procedure Notification ( AComponent : TComponent ;
                             Operation : TOperation ) ; override ;
  protected
    property ActivePage : TControl read FActivePage write SetActivePage ;
  end ;

implementation

{ TCustomDelphiLayout }

procedure TCustomDelphiLayout.AlignControls ( AControl : TControl ;
                                              var ARect : TRect ) ;
begin
  SaveControl := AControl ;
  SaveRect := ARect ;
  inherited ;
  ARect := SaveRect ;
end;

type
  TAlignControlsProc = procedure ( AControl : TControl ;
                                   var ARect : TRect ) of object ;
  TCrackCustomPanel  = class ( TCustomPanel ) ;

procedure TCustomDelphiLayout.DoLayout ;
var
  GrannyProc : TAlignControlsProc ;
  Method     : TMethod absolute GrannyProc ;
begin
  Method.Code := @TCrackCustomPanel.AlignControls ;
  Method.Data := Self ;
  GrannyProc ( SaveControl, SaveRect ) ;
end ;

{ TCustomNotebookLayout }

{ ���������� ��������� }
procedure TCustomNotebookLayout.DoLayout ;
var List : TControlList ;
begin
  List := ListControls ( true ) ;
  try
    case List.Count of
      0 : SelectOther ( FActivePage ) ;
      1 : SelectControl ( List [ 0 ]) ;
      else
        begin
          List.Remove ( FActivePage ) ;
          SelectControl ( List [ 0 ]) ;
        end ;
    end ;
    if Assigned ( FActivePage ) then
      FActivePage.BoundsRect := Self.ClientRect ;
  finally
    FreeAndNil ( List ) ;
  end ;
end ;

{ ������� �� �������� ��������� }
procedure TCustomNotebookLayout.Notification ( AComponent : TComponent ;
                                         Operation : TOperation ) ;
begin
  inherited ;
  if ( Operation = opRemove ) and ( AComponent = ActivePage ) then
    SelectOther ( ActivePage ) ;
end ;

{ ������� ������ }

{ ��������� �������� �������� ���������� }
procedure TCustomNotebookLayout.SelectControl ( AControl : TControl ) ;
var
  ParentForm : TCustomForm ;
  Found : boolean ;
  i : integer ;
begin
  ParentForm := GetParentForm ( Self ) ;
  if Assigned ( ParentForm ) and ContainsControl ( ParentForm.ActiveControl )
    then ParentForm.ActiveControl := Self ;
  try
    DisableAlign ;
    for i := ControlCount - 1 downto 0 do
    begin
      Found := ( Controls [ i ] = AControl ) ;
      Controls [ i ].Visible := Found ;
      if Designing then
        if Found
          then ControlStyle := ControlStyle - [ csNoDesignVisible ]
          else ControlStyle := ControlStyle + [ csNoDesignVisible ] ;
      if Found then Controls [ i ].BringToFront ;
      if Assigned ( ParentForm ) and ( ParentForm.ActiveControl = Self )
        then SelectFirst ;
    end ;
    FActivePage := AControl ;
  finally
    EnableAlign ;
    RequestAlign ;
  end ;
end ;

{ ��������� ������� ������ ����������, ����� ���������� }
procedure TCustomNotebookLayout.SelectOther ( AControl : TControl ) ;
var NewControl : TControl ;
begin
  NewControl := nil ;
  if ( ControlCount > 0 ) and ( Controls [ 0 ] <> AControl )
    then NewControl := Controls [ 0 ]
  else if ControlCount > 1
    then NewControl := Controls [ 1 ] ;
  SelectControl ( NewControl ) ;
end ;

{ ��������� �������� �������� ���������� }
procedure TCustomNotebookLayout.SetActivePage ( NewControl : TControl ) ;
begin
  if ActivePage = NewControl then exit ;
  try
    DisableLayout ;
    if Assigned ( NewControl ) then
      begin
        NewControl.Parent := Self ;
        NewControl.FreeNotification ( Self ) ;
        SelectControl ( NewControl ) ;
      end
    else
      SelectOther ( ActivePage ) ;
  finally
    EnableLayout ;
    RequestLayout ;
  end ;
end ;

end.

