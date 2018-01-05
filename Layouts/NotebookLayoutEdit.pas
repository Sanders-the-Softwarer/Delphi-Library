////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                   Окно редактирования для NotebookLayout                   //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

unit NotebookLayoutEdit ;

{ ----- Примечание -------------------------------------------------------------

Вспомогательный модуль к Layouts.pas - подробные комментарии и условия
распространения см. в основном модуле

------------------------------------------------------------------------------ }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, BaseLayout, BorderLayout, Layouts, FlowLayout,
  ActnList, StdCtrls, StsListBox, NotebookLayout, LayoutMisc, System.Actions ;

type
  TFormNotebookLayoutEdit = class ( TForm )
    BorderLayout: TBorderLayout;
    panButtons: TFlowLayout;
    btnMoveUp: TButton;
    btnMoveDown: TButton;
    Actions: TActionList;
    aMoveUp: TAction;
    aMoveDown: TAction;
    aOK: TAction;
    aApply: TAction;
    aCancel: TAction;
    btnOk: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    listPages: TStsListBox;
    procedure aMoveUpUpdate(Sender: TObject);
    procedure aMoveUpExecute(Sender: TObject);
    procedure aMoveDownUpdate(Sender: TObject);
    procedure aMoveDownExecute(Sender: TObject);
    procedure aOKExecute(Sender: TObject);
    procedure aApplyUpdate(Sender: TObject);
    procedure aApplyExecute(Sender: TObject);
    procedure aCancelExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    Layout : TNotebookLayout ;
    Changed, Modified : boolean ;
  protected
    procedure InitPages ;
    procedure SavePages ;
  public
    class procedure Edit ( ALayout : TNotebookLayout ;
                           out AModified : boolean ) ;
  end ;

implementation

uses CmpUtils ;

{$R *.dfm}

{ Редактирование компонента }
class procedure TFormNotebookLayoutEdit.Edit ( ALayout : TNotebookLayout ;
  out AModified : boolean ) ;
begin
  with TFormNotebookLayoutEdit.Create ( nil ) do
  try
    Layout := ALayout ;
    ShowModal ;
    AModified := Modified ;
  finally
    Free ;
  end ;
end ;

{ Заполнение листбокса страницами компонента }
procedure TFormNotebookLayoutEdit.InitPages ;
var
  i : integer ;
  P : TControl ;
begin
  with listPages, Items do
  try
    BeginUpdate ;
    Clear ;
    for i := 0 to Layout.PageCount - 1 do
    begin
      P := Layout.Pages [ i ] ;
      Items.AddObject ( FormatComponentName ( P ), P ) ;
    end ;
  finally
    EndUpdate ;
  end ;
end ;

{ Сохранение изменений }
procedure TFormNotebookLayoutEdit.SavePages ;
var
  i : integer ;
  P : TControl ;
begin
  with listPages do
    for i := 0 to Items.Count - 1 do
    begin
      P := TControl ( Items.Objects [ i ]) ;
      Layout.MovePage ( P, i ) ; 
    end ;
end ;

procedure TFormNotebookLayoutEdit.aMoveUpUpdate(Sender: TObject);
begin
  aMoveUp.Enabled := ( listPages.ItemIndex > 0 ) ;
end;

procedure TFormNotebookLayoutEdit.aMoveUpExecute(Sender: TObject);
var NewIndex : integer ;
begin
  with listPages do
  begin
    NewIndex := ItemIndex - 1 ;
    Items.Move ( ItemIndex, NewIndex ) ;
    ItemIndex := NewIndex ;
  end ;
  Changed := true ;
end;

procedure TFormNotebookLayoutEdit.aMoveDownUpdate(Sender: TObject);
begin
  with listPages do
    aMoveDown.Enabled := ( ItemIndex >= 0 ) and ( ItemIndex < Items.Count - 1 ) ;
end;

procedure TFormNotebookLayoutEdit.aMoveDownExecute(Sender: TObject);
var NewIndex : integer ;
begin
  with listPages do
  begin
    NewIndex := ItemIndex + 1 ;
    Items.Move ( ItemIndex, NewIndex ) ;
    ItemIndex := NewIndex ;
  end ;
  Changed := true ;
end;

procedure TFormNotebookLayoutEdit.aOKExecute(Sender: TObject);
begin
  aApply.Execute ;
  ModalResult := mrOk ;
end;

procedure TFormNotebookLayoutEdit.aApplyUpdate(Sender: TObject);
begin
  aApply.Enabled := Changed ;
end;

procedure TFormNotebookLayoutEdit.aApplyExecute(Sender: TObject);
begin
  SavePages ;
  Changed := false ;
end;

procedure TFormNotebookLayoutEdit.aCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel ;
end;

procedure TFormNotebookLayoutEdit.FormShow(Sender: TObject);
begin
  InitPages ;
end;

end.
