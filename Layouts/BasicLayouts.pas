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

