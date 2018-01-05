////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//        Панели с настроенными алгоритмами выравнивания дочерних окон        //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- Официоз ----------------------------------------------------------------

Любой желающий может распространять этот модуль, дорабатывать его, использовать
в собственных программных проектах, в том числе коммерческих, без необходимости
в дополнительных разрешениях от автора. В любой версии модуля должна сохраняться
информация об авторских правах и условиях распространения модуля.

При распространении доработанных версий модуля прошу изменить имя модуля и
базового класса для предотвращения коллизий между доработками различных авторов.

Если Вы сделали интересную доработку и согласны распространять ее на этих
условиях - сообщите о ней, и мы обговорим включение Вашей доработки в авторскую
версию модуля. Также прошу сообщать о найденных ошибках, если такие будут.

Автор: Sanders Prostorov, 2:5020/1583, softwarer@mail.ru, softwarer@nm.ru

Последняя версия этого файла доступна на http://softwarer.ru

------------------------------------------------------------------------------ }

{ ----- Применение модуля ------------------------------------------------------

Этот файл содержит набор компонент, действующих наподобие JDK-шных layout-ов.
Эти компоненты автоматически располагают свои дочерние компоненты (в том числе
другие layout-ы) в соответствии с заложенным алгоритмом и значительно повышают
как скорость, так и качество разработки интерфейса, позволяя обойтись без
настройки Align, Anchors, OnResize итп. и в то же время поддерживая
установленный режим при изменении размеров, видимости и других атрибутов
компонент.

При установленной макропеременной Use_TabOrder дополнительно используется модуль
TabOrder, в результате чего после любого изменения автоматически перестраивается
порядок обхода компонент с клавиатуры.

Примечание: эта библиотека не повторяет JDK; набор возможностей существенно
отличаются и даже "одинаково названные" классы могут действовать совсем
по-другому, нежели в Java.

Реализованные алгоритмы:

  TDelphiLayout    Использует стандартные алгоритмы Delphi (Align, Anchors итп).
                   По сути обычная панель, но автоматически расставляющая
                   TabOrder-ы и реализующая любую другую функциональность,
                   которая будет добавлена в базовый класс TLayout

  TFlowLayout      Позиционирует дочерние компоненты в один ряд (горизонтальный
                   или вертикальный) с постоянными промежутками между ними.
                   При горизонтальном выравнивании поддерживает у всех компонент
                   одинаковую высоту и может поддерживать одинаковую ширину; при
                   вертикальном выравнивании поддерживает одинаковую ширину и
                   может поддерживать высоту.

                   Предназначен для реализации панелей кнопок и аналогичных
                   решений.

  TBorderLayout    Позиционирует дочерние компоненты "один в центре, остальные
                   по краям" примерно аналогично свойству Align, но позволяет
                   отдать левой и правой панелям приоритет в размещении перед
                   верхней и нижней, а также поддерживает интервалы между
                   компонентами.

  TNotebookLayout  Работает аналогично компоненту TNotebook. В каждый момент
                   времени виден только один из размещенных компонентов,
                   растянутый на всю площадь панели.

                   В настоящей версии TNotebookLayout не содержит специальной
                   поддержки TTabSet или аналогичной функциональности - для
                   этого можно использовать TPageControl. В то же время он
                   позволяет эффективно заменить TNotebook там, где набор
                   закладок не нужен - скажем, в разного рода экспертах и
                   визардах.

  TDualListLayout  Позиционирует дочерние компоненты в режиме "двойного списка":
                   левая и правая панели равной ширины и, возможно, центральная
                   панель с кнопками между ними.

  TFrameLayout     Предназначен для выравнивая элементов в формах просмотра и
                   редактирования, диалогах настройки итп. Расставляет
                   компоненты в ячейках условной сетки, поддерживая одинаковую
                   ширину компонентов в колонках и центрируя по высоте в
                   строках.

Для компиляции класса TFrameLayout необходим модуль RecordList, который также
может быть найден на http://softwarer.ru

------------------------------------------------------------------------------ }

{ ----- Намечено к реализации --------------------------------------------------

Реализовать базовый класс TConstrainedLayout и на его основе - TFrameLayout

Реализовать класс "сплиттеров" для использования в FrameLayout/BorderLayout

Добавить в BorderLayout поддержку сплиттеров

DockLayout - что-то типа PaneLayout, подходящее для докинга

Подумать о GridLayout/BoxLayout или доработках в эту сторону

------------------------------------------------------------------------------ }

{ ----- История изменений ------------------------------------------------------

13.12.2004 Сподобился соединить старые наработки и новые идеи; решил заложить
           новый модуль с отстроенной иерархией классов, и добавлять в него
           переработанные прежние решени. Реализованы: базовый класс TLayout,
           классы TDelphiLayout, TFlowLayout, TNotebookLayout. Сюда же
           подключается расстановка TabOrder-ов.
16.12.2004 Реализован TDualListLayout
18.12.2004 Реализован TBorderLayout, базовый класс TFixedListLayout
20.12.2004 TDualListLayout переписан через TFixedListLayout

------------------------------------------------------------------------------ }

unit Layouts ;

interface

uses
  Classes, BasicLayouts, FlowLayout, BorderLayout, DualLayout, FrameLayout,
  ConstraintedLayout, NotebookLayout, InputLayout, SplitterLayout,
  LayoutSettings ;

type

  { Обычное выравнивание Delphi }
  TDelphiLayout = class ( TCustomDelphiLayout ) ;

  { Потоковое выравнивание }
  TFlowLayout = class ( TCustomFlowLayout )
  published
    property AutoHeight ;
    property AutoWidth ;
    property Direction ;
    property Margins ;
  end ;

  { Панель кнопок, привязанная к ActionList-у }
  TActionPane = class ( TCustomActionPane )
  published
    property Actions ;
    property Category ;
  end;

  { Многостраничное выравнивание }
  TNotebookLayout = class ( TCustomNotebookLayout )
  public
    property Pages ;
  published
    property ActivePage ;
    property AutoSelectFirst ;
    property OnChanging ;
    property OnChange ;
  end ;

  { Выравнивание панели ввода данных }
  TInputLayout = class ( TCustomInputLayout )
  published
    property AutoLabelWidth ;
    property LabelWidth ;
    property LabelAlignment ;
    property RubberControl ;
  end ;

  { Выравнивание двойного списка }

  TDualLayout = class ( TCustomDualLayout )
  published
    property Margins ;
    property LeftControl ;
    property RightControl ;
    property CenterControl ;
  end ;

  TVerticalDualLayout = class ( TCustomVerticalDualLayout )
  published
    property Margins ;
    property LeftControl ;
    property RightControl ;
    property CenterControl ;
  end ;

  { Выравнивание "по краям" }
  TBorderLayout = class ( TCustomBorderLayout )
  published
    property Margins ;
    property TopControl ;
    property LeftControl ;
    property RightControl ;
    property BottomControl ;
    property CenterControl ;
    property SubTopControl ;
    property SubBottomControl ;
  end ;

  { Выравнивание для форм просмотра/редактирования }
  TFrameLayout = class ( TCustomFrameLayout )
  published
    property Margins ;
    property Constraints ;
  end ;

  { Панель для выравнивания с полозком }
  TSplitterLayout = class ( TCustomSplitterLayout )
  published
    property BottomControl ;
    property DefaultPosition ;
    property Direction ;
    property EnableFlip ;
    property HCursor ;
    property HideControl ;
    property LeftControl ;
    property MinLeft ;
    property MinRight ;
    property Ratio ;
    property ResizeBehaviour ;
    property RightControl ;
    property Position ;
    property TopControl ;
    property VCursor ;
  end;

procedure Register;

implementation

procedure Register ;
begin
  RegisterComponents ( 'Layouts', [ TLayoutSettings, TDelphiLayout,
    TBorderLayout, TFlowLayout, TDualLayout, TNotebookLayout, TInputLayout,
    TActionPane, TInputLayoutLabel, TSplitterLayout {, TRuledLayout} ]) ;
end;

end.

