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

Форма выбора настроек по умолчанию. Вызывается в дизайн-тайме для выбора, к
какому именно компоненту настроек будет привязан очередной созданный layout

------------------------------------------------------------------------------ }

unit LayoutSettingsSelect ;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FlowLayout, Layouts, StdCtrls, StsListBox, ExtCtrls, BaseLayout,
  BorderLayout, ActnList, LayoutSettings, Buttons, LayoutMisc ;

type
  TFormLayoutSettingsSelect = class ( TForm )
    BorderLayout1: TBorderLayout;
    listDefaultSettings: TStsListBox;
    Actions: TActionList;
    aSelect: TAction;
    aCancel: TAction;
    FlowLayout1: TFlowLayout;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure aCancelExecute(Sender: TObject);
    procedure aSelectExecute(Sender: TObject);
    procedure listDefaultSettingsDblClick(Sender: TObject);
    procedure aSelectUpdate(Sender: TObject);
  private
    Selected : TObject ;
  public
    class function Process ( List : TStringList ;
                             out Settings : TLayoutSettings ) : TModalResult ;
  end ;

implementation

uses CmpUtils ;

{$R *.dfm}

class function TFormLayoutSettingsSelect.Process (
  List : TStringList ; out Settings : TLayoutSettings ) : TModalResult ;
var
  i : integer ;
  S : TLayoutSettings ;
  N : string ;
begin
  with TFormLayoutSettingsSelect.Create ( nil ) do
  try
    for i := 0 to List.Count - 1 do
    begin
      S := List.Objects [ i ] as TLayoutSettings ;
      if S.Shadow
        then N := S.ShadowName
        else N := FormatComponentName ( S ) ;
      listDefaultSettings.Items.AddObject ( N, S ) ;
    end ;
    Result := ShowModal ;
    if Result = mrOk then Settings := Selected as TLayoutSettings ;
  finally
    Free ;
  end ;
end ;

procedure TFormLayoutSettingsSelect.aCancelExecute(Sender: TObject);
begin
  Self.Close ;
end;

procedure TFormLayoutSettingsSelect.aSelectExecute(Sender: TObject);
begin
  with listDefaultSettings do
    Self.Selected := Items.Objects [ ItemIndex ] ;
  Self.ModalResult := mrOk ;
end ;

procedure TFormLayoutSettingsSelect.listDefaultSettingsDblClick(
  Sender: TObject);
begin
  aSelect.Execute ;
end;

procedure TFormLayoutSettingsSelect.aSelectUpdate(Sender: TObject);
begin
  aSelect.Enabled := ( listDefaultSettings.ItemIndex >= 0 ) ;
end;

end.
