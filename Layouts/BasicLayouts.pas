////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         Панели с настроенными алгоритмами выравнивания дочерних окон       //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- Примечание -------------------------------------------------------------

Вспомогательный модуль к Layouts.pas - подробные комментарии и условия
распространения см. в основном модуле

------------------------------------------------------------------------------ }

{ ----- Описание ---------------------------------------------------------------

В этом файле находятся простые, базовые алгоритмы выравнивания.

TDelphiLayout    Обычный алгоритм выравнивания Delphi. Класс, по сути, является
                 обычной панелью, на которой автоматически расставляются
                 TabOrder-ы и действует другая общая функциональность layout-ов.

TNotebookLayout  Работает аналогично стандартному компоненту TNotebook. В каждый
                 момент времени виден только один из дочерних компонент,
                 заданный свойство ActivePage. При изменении ActivePage, а также
                 при изменении свойства Visible дочерних компонент новый
                 компонент становится видимым вместо старого.

------------------------------------------------------------------------------ }

unit BasicLayouts ;

interface

uses
  Messages, Types, Classes, SysUtils, Controls, ExtCtrls, Forms, Math, Dialogs,
  Buttons, BaseLayout ;

type

  { Обычное выравнивание в стиле Delphi }

  TCustomDelphiLayout = class ( TLayout )
  private
    SaveControl : TControl ;
    SaveRect : TRect ;
  protected
    { Доопределение родительских методов }
    procedure AlignControls ( AControl : TControl ; var ARect : TRect ) ; override ;
    procedure DoLayout ; override ;
  end ;

  { Выравнивание а-ля TNotebook }

  TCustomNotebookLayout = class ( TLayout )
  private
    FActivePage : TControl ;
  protected
    { Доопределение родительских методов }
    procedure DoLayout ; override ;
    { Рабочие методы }
    procedure SelectControl ( AControl : TControl ) ;
    procedure SelectOther ( AControl : TControl ) ;
    { Методы свойств }
    procedure SetActivePage ( NewControl : TControl ) ;
  public
    { Доопределение родительских методов }
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

{ Размещение компонент }
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

{ Реакция на удаление компонент }
procedure TCustomNotebookLayout.Notification ( AComponent : TComponent ;
                                         Operation : TOperation ) ;
begin
  inherited ;
  if ( Operation = opRemove ) and ( AComponent = ActivePage ) then
    SelectOther ( ActivePage ) ;
end ;

{ Рабочие методы }

{ Установка текущего видимого компонента }
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

{ Установка видимым любого компонента, кроме указанного }
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

{ Изменение текущего видимого компонента }
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

