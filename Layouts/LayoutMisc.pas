////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         ������ � ������������ ����������� ������������ �������� ����       //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

unit LayoutMisc ;

{ ----- ���������� -------------------------------------------------------------

��������������� ������ � Layouts.pas - ��������� ����������� � �������
��������������� ��. � �������� ������

------------------------------------------------------------------------------ }

{ ----- �������� ---------------------------------------------------------------

���� �������� ����������� ��������������� �������, ����������� � ����������
� ������� ���������� �������� ������ �� �������������� �������, � ����� -
� ��������� ������� - �������� �� �� �������� ������.

------------------------------------------------------------------------------ }

{$I '..\..\options.inc'}

interface

uses SysUtils, Classes, Types, Controls, Forms, Windows, Messages, Graphics,
  Gradient, STSNotifier, ExtCtrls ;

type
  { ����� ��������� ���� }
  TLayoutBackground = ( lbDefault, lbTransparent, lbSettingsGradient, lbGradient ) ;

  { ���� ��������� WM_ERASEBKGND }
  TWMEraseBkgnd = packed record
    Msg : Cardinal ;
    DC  : THandle ;
    Unused : Longint ;
    Result : Longint ;
  end ;

  { ����� "������ �������� ���������" }
  TControlList = class ( TList )
  protected
    function GetControl ( Index : integer ) : TControl ;
  public
    property Controls [ Index : integer ] : TControl read GetControl ; default ;
    function Last : TControl ;
  end ;

  { ������ � ���������� ������������ }
  TTransparentPanel = class ( TCustomPanel )
  private
    FTransparent : boolean ;
    procedure TransparentEraseBkgnd ( var Msg : TWMEraseBkgnd ) ;
    procedure SetTransparent ( NewTransparent : boolean ) ;
  protected
    procedure Paint ; override ;
    procedure WmEraseBkgnd ( var Msg : TWMEraseBkgnd ) ; message WM_ERASEBKGND ;
    property Transparent : boolean read FTransparent write SetTransparent ;
  public
    constructor Create ( AOwner : TComponent ) ; override ;
  end ;

var
  { ���������� � ����������� ���������� ������� }
  ConvertPropertyNotifier : TSTSNotifier ;

{ ���������� � ����������� ����������� �������� }
procedure NotifyConvertProperty ( Sender : TComponent ; PropName : string ) ;

{ ������� bitmap-� ��� ��������� ��������� }
function GradientPattern ( ColorBegin, ColorEnd : TColor ;
                           Reverse : boolean ; Rotation : TGradientRotation ;
                           Shift : TGradientShift ;  Style : TGradientStyle ;
                           UseSysColors : boolean ) : TBitmap ;

implementation

uses RecordList, LayoutSettings, BaseLayout ;

{ ���������� � ����������� ����������� �������� }
procedure NotifyConvertProperty ( Sender : TComponent ; PropName : string ) ;
var
  Hook : IDesignerHook ;
begin
  Assert ( Sender <> nil ) ;
  if ( Sender is TLayoutSettings ) and TLayoutSettings ( Sender ).Shadow then exit ;
  if Assigned ( ConvertPropertyNotifier ) then ConvertPropertyNotifier.Fire ( Sender, PropName ) ;
  if not Assigned ( Sender.Owner ) or not ( Sender.Owner is TCustomForm ) then exit ;
  Hook := TCustomForm ( Sender.Owner ).Designer ;
  if Assigned ( Hook ) then Hook.Modified ;
end ;

{ TControlList }

function TControlList.GetControl ( Index : integer ) : TControl ;
begin
  Result := TControl ( inherited Items [ Index ]) ;
  Assert ( Result <> nil ) ;
end ;

function TControlList.Last : TControl ;
begin
  Result := TControl ( inherited Last ) ;
  Assert ( Result <> nil ) ;
end ;

{ TGradientList }

{ ����������� ���������� ����� ��� ������ ��������� }
function GradientKey ( ColorBegin, ColorEnd : TColor ;
                       Reverse : boolean ; Rotation : TGradientRotation ;
                       Shift : TGradientShift ;  Style : TGradientStyle ;
                       UseSysColors : boolean ) : string ;
begin
  if UseSysColors
    then Result := 'SYSCOLORS'
    else Result := Format ( '%x %x', [ ColorBegin, ColorEnd ]) ;
  Result := Result + Format ( '%d %d %d %d', [ Ord ( Reverse ), Rotation,
                                               Shift, Ord ( Style )]) ;
end ;

type
  TGradientList = class ( TRecordList )
  public
    property Key [ ArrIndex : integer ] : AnsiString index 0
             read GetStr write SetSortStr ;
    property Component [ ArrIndex : integer ] : TObject index 1
             read GetOwnObj write SetOwnObj ;
  end ;

var
  GradientList : TGradientList ;
  GradientBitmap : TBitmap ;

{ ������� bitmap-� ��� ��������� ��������� }
function GradientPattern ( ColorBegin, ColorEnd : TColor ;
                           Reverse : boolean ; Rotation : TGradientRotation ;
                           Shift : TGradientShift ;  Style : TGradientStyle ;
                           UseSysColors : boolean ) : TBitmap ;
var
  Key : string ;
  Index : integer ;
  Gradient : TGradient ;
  Copied : boolean ;
begin
  Assert ( GradientList <> nil ) ;
  Assert ( GradientBitmap <> nil ) ;
  Key := GradientKey ( ColorBegin, ColorEnd, Reverse, Rotation, Shift, Style, UseSysColors ) ;
  Index := GradientList.SortIndexOf ( Key ) ;
  if Index < 0 then
  begin
    Gradient := TGradient.Create ( nil ) ;
    Gradient.ColorBegin := ColorBegin ;
    Gradient.ColorEnd := ColorEnd ;
    Gradient.Reverse := Reverse ;
    Gradient.Rotation := Rotation ;
    Gradient.Shift := Shift ;
    Gradient.Style := Style ;
    Gradient.UseSysColors := UseSysColors ;
    Index := GradientList.InsertKey ( Key ) ;
    GradientList.Component [ Index ] := Gradient ;
  end ;
  Copied := ( GradientList.Component [ Index ] as TGradient ).CopyPatternTo ( GradientBitmap ) ;
  Assert ( Copied ) ;
  Result := GradientBitmap ;
end ;

{ TTransparentPanel }

constructor TTransparentPanel.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  BevelInner := bvNone ;
  BevelOuter := bvNone ;
  ControlStyle := ControlStyle - [ csSetCaption ] ;
  Transparent := true ;
end ;

{ ������� �� WM_ERASEBKGND � ������ ������������ }
procedure TTransparentPanel.TransparentEraseBkgnd ( var Msg : TWMEraseBkgnd ) ;
var
  SaveIndex : integer ;
  P : TPoint ;
  LDC : integer ;
begin
  Msg.Result := 1 ;
  if Parent = nil then exit ;
  { ���� ��������� ���������, ������ ��������� ���� ������������� �������� }
  SaveIndex := SaveDC ( Msg.DC ) ;
  GetViewportOrgEx ( Msg.DC, P ) ;
  SetViewportOrgEx ( Msg.DC, P.X - Self.Left, P.Y - Self.Top, nil ) ;
  IntersectClipRect ( Msg.DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight ) ;
  try
    Assert ( SizeOf ( Msg.DC ) = SizeOf ( LDC )) ;
    Move ( Msg.DC, LDC, SizeOf ( Msg.DC )) ;
    Parent.Perform ( WM_ERASEBKGND, LDC, 0 ) ;
    Parent.Perform ( WM_PAINT, LDC, 0 ) ;
  except
    { ����� ��� ������������� �������� ��������� ���������� � IDE � ������
      ������; ����� ����������� ������� �� �����, � �������� �� ��������� }
  end ;
  RestoreDC ( Msg.DC, SaveIndex ) ;
  if ( Parent is TCustomControl ) or ( Parent is TCustomForm ) or
     ( csDesigning in ComponentState ) then exit ;
  Parent.Invalidate ;
end ;

{ ��������� ��������� ������������ }
procedure TTransparentPanel.SetTransparent ( NewTransparent : boolean ) ;
begin
  if FTransparent = NewTransparent then exit ;
  FTransparent := NewTransparent ;
  if FTransparent
    then ControlStyle := ControlStyle - [ csOpaque ]
    else ControlStyle := ControlStyle + [ csOpaque ] ;
  RecreateWnd ;
  Invalidate ;
end ;

{ ��������� ���������� }
procedure TTransparentPanel.Paint ;
begin
  if not Transparent then inherited ;
end ;

{ ������� �� WM_ERASEBKGND }
procedure TTransparentPanel.WmEraseBkgnd ( var Msg : TWMEraseBkgnd ) ;
begin
  if Transparent
    then TransparentEraseBkgnd ( Msg )
    else inherited ;
end ;

initialization
  GradientList := TGradientList.Create ;
  GradientList.RecordLength := 2 ;
  GradientList.SetSortOrder ( 0 ) ;
  GradientBitmap := TBitmap.Create ;

finalization
  FreeAndNil ( GradientList ) ;
  FreeAndNil ( GradientBitmap ) ;

end.

