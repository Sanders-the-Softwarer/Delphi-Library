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

�������� ������������ ��������� � ������ �������� ������. �������� LeftControl,
RightControl � CenterControl ������ �������, ������������� �������������� �����,
������ � �� ������ (������ ��� ����� ������, ������ ������ � ������������ ������
������ ��������������). ��������� ���������� ������������� ������������� �
��������������� ��������; ����� ���� ��������� �� �����������.

------------------------------------------------------------------------------ }

unit DualLayout ;

interface

uses
  Messages, Types, Classes, SysUtils, Controls, ExtCtrls, Forms, Math, Dialogs,
  Buttons, BaseLayout, FlowLayout ;

type

  { ������������ �������� ������ }

  TCustomDualLayout = class ( TFixedListLayout )
  protected
    { ������������� ������������ ������� }
    function GetControlsRequired : integer ; override ;
    procedure DoLayout ( Rect : TRect ) ; override ;
    procedure DesignPaintLayout ; override ;
    { ������� ������ }
    procedure CalcLayout ( const Rect : TRect ;
                           out ATopLeft, ABottomRight, ACenter : TRect ) ; virtual ;
  public
    { ������������� ������������ ������� }
    constructor Create ( AOwner : TComponent ) ; override ;
  protected
    property LeftControl : TControl index 0 read GetControl write SetControl ;
    property RightControl : TControl index 1 read GetControl write SetControl ;
    property CenterControl : TControl index 2 read GetControl write SetControl ;
  end ;

  TCustomVerticalDualLayout = class ( TCustomDualLayout )
  protected
    procedure CalcLayout ( const Rect : TRect ;
                           out ATopLeft, ABottomRight, ACenter : TRect ) ; override ;
  protected
    property TopControl : TControl index 0 read GetControl write SetControl ;
    property BottomControl : TControl index 1 read GetControl write SetControl ;
  end ;

implementation

{ TCustomDualLayout }

constructor TCustomDualLayout.Create ( AOwner : TComponent ) ;
begin
  inherited ;
  Width := 300 ;
  Height := 180 ;
end ;

{ ������������� ������������ ������� }

{ ������� ���������� �������������� ��������� }
function TCustomDualLayout.GetControlsRequired : integer ;
begin
  Result := 3 ;
end ;

{ ����������� ������� }
procedure TCustomDualLayout.DoLayout ( Rect : TRect ) ;
var LT, RB, C : TRect ;
begin
  CalcLayout ( Rect, LT, RB, C ) ;
  if Assigned ( LeftControl ) then LeftControl.BoundsRect := LT ;
  if Assigned ( RightControl ) then RightControl.BoundsRect := RB ;
  if Assigned ( CenterControl ) then CenterControl.BoundsRect := C ;
end ;

{ ������-�������� ��������� }
procedure TCustomDualLayout.DesignPaintLayout ;
var LT, RB, C : TRect ;
begin
  inherited ;
  CalcLayout ( LayoutRect, LT, RB, C ) ;
  DrawDesignRect ( LT.Left, LT.Top, LT.Right, LT.Bottom ) ;
  DrawDesignRect ( RB.Left, RB.Top, RB.Right, RB.Bottom ) ;
end ;

{ ������ ��������� �������� ��������� }
procedure TCustomDualLayout.CalcLayout (
  const Rect : TRect ; out ATopLeft, ABottomRight, ACenter : TRect ) ;
var CenterWidth, PanelsWidth : integer ;
begin
  if CenterControl <> nil
    then CenterWidth := CenterControl.Width + 2 * Margins.Horiz
    else CenterWidth := Self.Margins.Horiz ;
  PanelsWidth := Rect.Right - Rect.Left - CenterWidth ;
  ATopLeft := Types.Rect ( Rect.Left, Rect.Top, Rect.Left + PanelsWidth div 2, Rect.Bottom ) ;
  ABottomRight := Types.Rect ( ATopLeft.Right + CenterWidth, Rect.Top, Rect.Right, Rect.Bottom ) ;
  ACenter := Types.Rect ( ATopLeft.Right + Margins.Horiz, Rect.Top, ABottomRight.Left - Margins.Horiz, Rect.Bottom ) ;
end ;

{ TCustomVerticalDualLayout }

procedure TCustomVerticalDualLayout.CalcLayout ( const Rect : TRect ;
  out ATopLeft, ABottomRight, ACenter : TRect ) ;
var CenterHeight, PanelsHeight : integer ;
begin
  if CenterControl <> nil
    then CenterHeight := CenterControl.Height + 2 * Margins.Vert
    else CenterHeight := Margins.Vert ;
  PanelsHeight := Rect.Bottom - Rect.Top - CenterHeight ;
  ATopLeft := Types.Rect ( Rect.Left, Rect.Top, Rect.Right, Rect.Top + PanelsHeight div 2 ) ;
  ABottomRight := Types.Rect ( Rect.Left, ATopLeft.Bottom + CenterHeight, Rect.Right, Rect.Bottom ) ;
  ACenter := Types.Rect ( Rect.Left, ATopLeft.Bottom + Margins.Vert, Rect.Right, ABottomRight.Top - Margins.Vert ) ;
end ;

end.

