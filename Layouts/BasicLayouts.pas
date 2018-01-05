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
    procedure DoLayout ( Rect : TRect ) ; override ;
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

end.

