////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//         Панели с настроенными алгоритмами выравнивания дочерних окон       //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

unit NotebookLayoutDsgn;

{ ----- Примечание -------------------------------------------------------------

Вспомогательный модуль к Layouts.pas - подробные комментарии и условия
распространения см. в основном модуле

------------------------------------------------------------------------------ }

{ ----- Описание ---------------------------------------------------------------

Файл содержит дизайн-таймовые редакторы для компонента TNotebookLayout

------------------------------------------------------------------------------ }

interface

uses SysUtils, Classes, Controls, Forms, DesignIntf, DesignEditors, DesignMenus,
  Dialogs, NotebookLayout, Layouts ;

type
  { Редактор компонента }
  TNotebookLayoutEditor = class ( TComponentEditor )
  protected
    function Layout : TNotebookLayout ;
    procedure SelectPageClick ( Sender : TObject ) ;
  public
    procedure Edit ; override ;
    function GetVerbCount : integer ; override ;
    function GetVerb ( Index : integer ) : string ; override ;
    procedure PrepareItem ( Index : integer ;
                            const AItem : IMenuItem ) ; override ;
    procedure ExecuteVerb ( Index : integer ) ; override ;
  end ;

  { Редактор свойства ActivePage }
  TActivePageEditor = class ( TPropertyEditor )
  protected
    function Layout : TNotebookLayout ;
    function ControlName ( Control : TControl ) : string ;
  public
    function GetAttributes : TPropertyAttributes ; override ;
    function GetValue : string ; override ;
    procedure GetValues ( Proc : TGetStrProc ) ; override ;
    procedure SetValue ( const Value : string ) ; override ;
  end ;

implementation

uses NotebookLayoutEdit ;

{ TNotebookLayoutEditor }

resourcestring
  SEditPages = 'Редактировать...' ;
  SSelect    = 'Выбрать' ;
  SFirstPage = 'Первая страница' ;
  SPrevPage  = 'Предыдущая страница' ;
  SNextPage  = 'Следующая страница' ;
  SLastPage  = 'Последняя страница' ;

{ Форма редактирования }
procedure TNotebookLayoutEditor.Edit ;
var Modified : boolean ;
begin
  TFormNotebookLayoutEdit.Edit ( Layout, Modified ) ;
  if Modified and Assigned ( Designer ) then Designer.Modified ;
end ;

{ Количество дополнительных пунктов меню }
function TNotebookLayoutEditor.GetVerbCount : integer ;
begin
  Result := 8 ;
end ;

{ Дополнительные пункты меню }
function TNotebookLayoutEditor.GetVerb ( Index : integer ) : string ;
begin
  case Index of
    0 : Result := SEditPages ;
    1 : Result := '-' ;
    2 : Result := SSelect ;
    3 : Result := '-' ;
    4 : Result := SFirstPage ;
    5 : Result := SPrevPage ;
    6 : Result := SNextPage ;
    7 : Result := SLastPage ;
  end ;
end ;

{ Доработка пунктов меню }
procedure TNotebookLayoutEditor.PrepareItem ( Index : integer ;
  const AItem : IMenuItem ) ;
var
  i : integer ;
  P : TControl ;
begin
  case Index of
    1 : AItem.Visible := Layout.HasPages ;
    2 : with Layout do
          if Layout.HasPages then
            for i := 0 to PageCount - 1 do
            begin
              P := GetPage ( i ) ;
              with AItem.AddItem ( P.Name, 0, ActivePage = P, true,
                SelectPageClick ) do Tag := integer ( P ) ;
            end
          else
            AItem.Visible := false ;
    4..7 : AItem.Enabled := Layout.HasPages ;
  end ;
end ;

{ Выполнение пунктов меню }
procedure TNotebookLayoutEditor.ExecuteVerb(Index: integer);
begin
  case Index of
    0 : Edit ;
    4 : Layout.SelectFirst ;
    5 : Layout.SelectPrev ;
    6 : Layout.SelectNext ;
    7 : Layout.SelectLast ;
  end ;
end ;

{ Возврат компонента с приведением типа }
function TNotebookLayoutEditor.Layout : TNotebookLayout ;
begin
  Result := TNotebookLayout ( GetComponent ) ;
  Assert ( Result <> nil ) ;
  Assert ( Result.InheritsFrom ( TCustomNotebookLayout )) ;
end ;

{ Обработчик клика для выбора страницы из меню }
procedure TNotebookLayoutEditor.SelectPageClick ( Sender : TObject ) ;
begin
  Layout.ActivePage := TControl ( TComponent ( Sender ).Tag ) ;
end ;

{ TActivePageEditor }

{ Возврат компонента с приведением типа }
function TActivePageEditor.Layout : TNotebookLayout ;
begin
  Result := TNotebookLayout ( GetComponent ( 0 )) ;
  Assert ( Result <> nil ) ;
  Assert ( Result.InheritsFrom ( TCustomNotebookLayout )) ;
end ;

{ Формирование имени контрола, удобного для использования в интерфейсе }
function TActivePageEditor.ControlName ( Control : TControl ) : string ;
begin
  if Control = nil then
    Result := ''
  else if Control.Name <> '' then
    Result := Control.Name
  else
    Result := Format ( '%s (%p)', [ Control.ClassName, integer ( Control )]) ;
end ;

{ Возврат вида редактора }
function TActivePageEditor.GetAttributes : TPropertyAttributes ;
begin
  Result := [ paValueList ] ;
end ;

{ Формирование значения для вывода в редактор }
function TActivePageEditor.GetValue : string ;
begin
  Result := ControlName ( Layout.ActivePage ) ;
end;

{ Формирование выпадающего списка значений }
procedure TActivePageEditor.GetValues ( Proc : TGetStrProc ) ;
var i : integer ;
begin
  for i := 0 to Layout.PageCount - 1 do
    Proc ( ControlName ( Layout.GetPage ( i ))) ;
end;

{ Установка нового значения }
procedure TActivePageEditor.SetValue ( const Value : string ) ;
var i : integer ;
begin
  for i := 0 to Layout.PageCount - 1 do
    if Value = ControlName ( Layout.GetPage ( i )) then
    begin
      Layout.ActivePage := Layout.GetPage ( i ) ;
      Self.Modified ;
    end ;
end ;

end.
