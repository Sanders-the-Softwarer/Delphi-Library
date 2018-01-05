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

�������� ������������ ������� �����, ����������� ����� �����, ����������� � ���
���� ����� - ������, ���������� �� ������ � ����������� �� ������.

����� ������ ���� ��������� � ��������������� �� ����� �������������� � �������
�������� FocusControl, � ��������� ������ ��� ����������� ��������, ��� "�������
���������� ������".

�������� LabelAlignment ��������� ������ ����� ������������ ����� ������������
�������� ���������. �������� LabelWidth � AutoLabelWidth ��������� ������
������������� ������ ���� ����� ���� ������������ �� ������������ ����������.
�������� RubberControl ��������� ������� ���������, ������������� �� ������ ���
���������� ������� ������������ � ������ (�������������� ���������� alClient).

��� ���������� ���������� �� ������ ���������� ���������� ���������� �������
LabelRequiredProc. � ������-����� �� ������������ ��� ����, ����� ������� �
��������� � ������������ ���������� �����, ��� ������� �������� ���������
LayoutSettings.DefaultLabel. �������� LayoutSettings.Labels ������������ ���
����������� ����, ����� ���������� ����� ��������� � �������� ����� � �����
�� �������� ����������� ����� � �������������� ��������; ��� �������� ���������
��������� ��������� �� ������ � �������������� �������, �������� ������������
DevExpress.

------------------------------------------------------------------------------ }

unit InputLayout ;

{$I '..\..\options.inc'}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls, Math, BaseLayout ;

type
  { ����� ���������� ����� }
  TLabelAlignment = ( laLeft, laRight, laTop ) ;

  { ������������ ������ ����� ������ }
  TCustomInputLayout = class ( TLayout )
  private
    FAutoLabelWidth : boolean ;
    FLabelWidth : integer ;
    FLabelAlignment : TLabelAlignment ;
    FRubberControl : TControl ;
  protected
    { ������������� ������������ ������� }
    function CompareControls ( Control1, Control2 : TControl ) : integer ; override ;
    procedure DoLayout ( Rect : TRect ) ; override ;
    procedure ControlAdded ( Control : TControl ) ; override ;
    procedure ControlRemoved ( Control : TControl ) ; override ;
    { ������� ������ }
    procedure LayoutControls ( Root : TWinControl ; Rect : TRect ) ;
    function IsLabel ( Control : TControl ) : boolean ;
    function GetFocusControl ( Control : TControl ) : TControl ;
    { ������ ������� }
    procedure SetAutoLabelWidth ( NewAutoLabelWidth : boolean ) ;
    procedure SetLabelWidth ( NewWidth : integer ) ;
    procedure SetLabelAlignment ( NewAlignment : TLabelAlignment ) ;
    procedure SetRubberControl ( NewControl : TControl ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
  protected
    property AutoLabelWidth : boolean read FAutoLabelWidth write SetAutoLabelWidth ;
    property LabelWidth : integer read FLabelWidth write SetLabelWidth ;
    property LabelAlignment : TLabelAlignment read FLabelAlignment write SetLabelAlignment ;
    property RubberControl : TControl read FRubberControl write SetRubberControl ;
  end ;

  { �����, ������������ ��� ������������� � InputLayout }
  TInputLayoutLabel = class ( TLabel )
  protected
    function GetFocusControl : TWinControl ;
    procedure SetFocusControl ( NewFocusControl : TWinControl ) ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
  published
    property FocusControl : TWinControl read GetFocusControl write SetFocusControl ;
  end ;

type
  TLabelRequiredProc = procedure ( Layout : TCustomInputLayout ;
                                   Control : TControl ) of object ;

var
  LabelRequiredProc : TLabelRequiredProc = nil ;

implementation

uses
  TypInfo, LayoutSettings, LayoutMisc ;

{ TCustomInputLayout }

constructor TCustomInputLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  Width := 400 ;
  Height := 300 ;
  FLabelAlignment := laLeft ;
  FAutoLabelWidth := true ;
end ;

function TCustomInputLayout.CompareControls ( Control1, Control2 : TControl ) : integer ;
var
  L1, L2 : boolean ;
begin
  L1 := IsLabel ( Control1 ) ;
  L2 := IsLabel ( Control2 ) ;
  if L1 and not L2 then
    Result := -1
  else if L2 and not L1 then
    Result := 1
  else
    Result := Control1.Top - Control2.Top ;
end ;

procedure TCustomInputLayout.DoLayout ( Rect : TRect ) ;
begin
  LayoutControls ( Self, Rect ) ;
end ;

{ ������� ������ � ������� }

function TCustomInputLayout.IsLabel ( Control : TControl ) : boolean ;
begin
  Result := Settings.ComponentSettings.LabelsInfo.IsLabelClass ( Control.ClassName ) ;
end ;

function TCustomInputLayout.GetFocusControl ( Control : TControl ) : TControl ;
var PropName : string ;
begin
  PropName := Settings.ComponentSettings.LabelsInfo.GetFocusControl ( Control.ClassName ) ;
  if PropName <> ''
    then Result := GetObjectProp ( Control, PropName, TControl ) as TControl
    else Result := nil ;
end ;

{ ����������� ������ ��� ���������� ��������� �� ������ ��������� }
function CalcVertShift ( Control1, Control2 : TControl ) : integer ;
begin
  Result := Min ( 4, ( Control2.Height - Control1.Height ) div 2 ) ;
end ;

{ �������� ����� ������������ }
procedure TCustomInputLayout.LayoutControls ( Root : TWinControl ;
                                              Rect : TRect ) ;
var
  Controls, Labels, FocusedLabels : TControlList ;
  Current, CurLabel, FocusControl : TControl ;
  i, index, CurTop, CurWidth, Delta, OldHeight, OldBottom : integer ;
begin
  Controls := ListControls ( Root, not IsDesigning ) ;
  Labels := TControlList.Create ;
  FocusedLabels := TControlList.Create ;
  try
    { ���������� ������ ����� }
    for i := 0 to Controls.Count - 1 do
      if IsLabel ( Controls [ i ]) then Labels.Add ( Controls [ i ]) ;
    for i := Labels.Count - 1 downto 0 do
    begin
      FocusControl := GetFocusControl ( Labels [ i ]) ;
      if Assigned ( FocusControl ) and
         ( Controls.IndexOf ( FocusControl ) >= 0 ) and
         ( Labels.IndexOf ( FocusControl ) < 0 )
        then FocusedLabels.Add ( Labels [ i ]) ;
    end ;
    { ��� ����������� ������ �������� ���� }
    if AutoLabelWidth then
    begin
      CurWidth := 0 ;
      for i := 0 to FocusedLabels.Count - 1 do
        CurWidth := Max ( CurWidth, FocusedLabels [ i ].Width ) ;
      FLabelWidth := CurWidth ;
    end ;
    { ��� ������������ ����� ��� ����������� ������������ }
    if LabelAlignment = laTop then
      begin
        { ��������� ����� ����� ����������� ������������ }
        for i := 0 to FocusedLabels.Count - 1 do
        begin
          CurLabel := FocusedLabels [ i ] ;
          FocusControl := GetFocusControl ( CurLabel ) ;
          Controls.Remove ( CurLabel ) ;
          index := Controls.IndexOf ( FocusControl ) ;
          Controls.Insert ( index, CurLabel ) ;
        end ;
        { ������ �������, ���������� ���������� � ���� ������� }
        CurTop := Rect.Top ;
        for i := 0 to Controls.Count - 1 do
        begin
          Current := Controls [ i ] ;
          Current.Left := Rect.Left ;
          Current.Top  := CurTop ;
          if not IsLabel ( Current ) then
            Current.Width := Rect.Right - Current.Left ;
          Inc ( CurTop, Current.Height + Self.Margins.Vert ) ;
        end ;
      end
    { ��� ������������ ����� ����� }
    else
      begin
        CurTop := Rect.Top ;
        { ��������� ���������� }
        for i := 0 to Controls.Count - 1 do
        begin
          Current := Controls [ i ] ;
          if FocusedLabels.IndexOf ( Current ) >= 0 then continue ;
          Current.Top := CurTop ;
          if Labels.IndexOf ( Current ) < 0 then
            begin
              Current.Left := Rect.Left + LabelWidth + Self.Margins.Horiz ;
              Current.Width := Rect.Right - Current.Left ;
            end
          else if LabelAlignment = laLeft then
            Current.Left := Rect.Left
          else
            Current.Left := Rect.Left + LabelWidth - Current.Width ;
          CurTop := CurTop + Current.Height + Self.Margins.Vert ;
        end ;
        { ������ ���������� � ��� ����� }
        for i := 0 to FocusedLabels.Count - 1 do
        begin
          CurLabel := FocusedLabels [ i ] ;
          FocusControl := GetFocusControl ( CurLabel ) ;
          CurLabel.Top  := FocusControl.Top + CalcVertShift ( CurLabel, FocusControl ) ;
          if LabelAlignment = laLeft
            then CurLabel.Left := Rect.Left
            else CurLabel.Left := Rect.Left + LabelWidth - CurLabel.Width ;
        end ;
      end ;
    { ���������� ������������ }
    if not Assigned ( RubberControl ) then exit ;
    Current := Controls.Last ;
    Delta := Rect.Bottom - Current.Top - Current.Height ;
    if Delta = 0 then exit ;
    OldHeight := RubberControl.Height ;
    OldBottom := RubberControl.Top + RubberControl.Height ;
    RubberControl.Height := RubberControl.Height + Delta ;
    Delta := RubberControl.Height - OldHeight ;
    if Delta = 0 then exit ;
    for i := 0 to Controls.Count - 1 do
      if Controls [ i ].Top > OldBottom then
        Controls [ i ].Top := Controls [ i ].Top + Delta ;
  finally
    FreeAndNil ( Controls ) ;
    FreeAndNil ( Labels ) ;
    FreeAndNil ( FocusedLabels ) ;
  end ;
end ;

{ ��������� ����� ����������� ������ }
procedure TCustomInputLayout.SetAutoLabelWidth ( NewAutoLabelWidth : boolean ) ;
begin
  if FAutoLabelWidth = NewAutoLabelWidth then exit ;
  FAutoLabelWidth := NewAutoLabelWidth ;
  RequestLayout ;
end ;

{ ��������� ������ ���� ����� }
procedure TCustomInputLayout.SetLabelWidth ( NewWidth : integer ) ;
begin
  FAutoLabelWidth := false ;
  if FLabelWidth = NewWidth then exit ;
  FLabelWidth := NewWidth ;
  RequestLayout ;
end ;

{ ��������� ������������ ����� }
procedure TCustomInputLayout.SetLabelAlignment ( NewAlignment : TLabelAlignment ) ;
begin
  if FLabelAlignment = NewAlignment then exit ;
  FLabelAlignment := NewAlignment ;
  RequestLayout ;
end ;

{ ��������� "����������" ���������� }
procedure TCustomInputLayout.SetRubberControl ( NewControl : TControl ) ;
begin
  if FRubberControl = NewControl then exit ;
  try
    DisableLayout ;
    if Assigned ( NewControl ) then NewControl.Parent := Self ;
    FRubberControl := NewControl ;
  finally
    EnableLayout ;
  end ;
end ;

{ ������� �� ���������� �������� ��������� }
procedure TCustomInputLayout.ControlAdded ( Control : TControl ) ;
begin
  inherited ;
  if not IsLabel ( Control ) and Assigned ( LabelRequiredProc ) then
    LabelRequiredProc ( Self, Control ) ;
end ;

{ ������� �� �������� �������� ��������� }
procedure TCustomInputLayout.ControlRemoved ( Control : TControl ) ;
begin
  if Control = FRubberControl then FRubberControl := nil ;
  inherited ;
end ;

{ TInputLayoutLabel }

constructor TInputLayoutLabel.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  Transparent := true ;
end ;

function TInputLayoutLabel.GetFocusControl : TWinControl ;
begin
  Result := inherited FocusControl ;
end ;

procedure TInputLayoutLabel.SetFocusControl ( NewFocusControl : TWinControl ) ;
begin
  inherited FocusControl := NewFocusControl ;
  if Assigned ( Parent ) then Parent.Realign ;
end ;

end.

