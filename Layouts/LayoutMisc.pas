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

interface

uses SysUtils, Classes, Types, Controls, Forms, Windows, Messages, Graphics,
  STSNotifier, ExtCtrls ;

type
  { ����� ��������� ���� }
  TLayoutBackground = ( lbDefault, lbTransparent ) ;

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

end.

