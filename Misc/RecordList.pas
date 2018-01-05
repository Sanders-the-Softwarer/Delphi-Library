////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                RecordList - ���������� ���� "������ �������"               //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- ������� ----------------------------------------------------------------

����� �������� ����� �������������� ���� ������, ������������ ���, ������������
� ����������� ����������� ��������, � ��� ����� ������������, ��� �������������
� �������������� ����������� �� ������. � ����� ������ ������ ������ �����������
���������� �� ��������� ������ � �������� ��������������� ������.

��� ��������������� ������������ ������ ������ ����� �������� ��� ������ �
�������� ������ ��� �������������� �������� ����� ����������� ��������� �������.

���� �� ������� ���������� ��������� � �������� �������������� �� �� ����
�������� - �������� � ���, � �� ��������� ��������� ����� ��������� � ���������
������ ������. ����� ����� �������� � ��������� �������, ���� ����� �����.

�����: Sanders Prostorov (softwarer@mail.ru, softwarer@nm.ru)

��� ���������� ����� � ������ ������� ������������� �� http://softwarer.ru
��� ��������� �� ������� � ����������� �� ����������: http://bugs.softwarer.ru

------------------------------------------------------------------------------ }

{ ----- ���������� ������ ------------------------------------------------------

������ RecordList ������������ ��� ���������� ����� ����� ������������
�������� ������, ��� ������ (������) �������. ��� ������������� ������ �������
������� ���� ��� ������ �������� ��������� �������

type
  TMyRecords = class (TRecordList)
  public
    constructor Create; override;
  public
    property Key [ArrIndex: integer]: integer index 0 read GetInt write SetInt;
    property Value [ArrIndex: integer]: string index 1 read GetStr write SetStr;
  end;

constructor TMyRecords.Create;
begin
  inherited;
  RecordLength := 2;
end;

����� ����� ��� �������� ���������� � ������� � �� ����� �� ������� � �������,
��������:

with TMyRecords.Create do
begin
  Add;
  Key [0] := 1;
  Value [0] := '�������';
end;

�������� ������ � ������ � ��� ������������ ��������, ����������� �������
�������� (� ������� 0 - ��� Key � 1 - ��� Value). � ������, ���� ���������
������� ������� � ���������� ��������, �� �������� ����� ��������� � ������
�� ������ ������, ��� ������ ����� �������� � �������������� ������������.
����� �������������� ������� ������� ���������������� ��� �������� RecordLength
����������� ��������� ������� - ��� ���������� ��� ����������� ��������� ������
��� �������� �����.

����� SetLength ��������� ���� ���������� ���������� ����� � ������. ������
������ ��� ������������� ����� �������; ����������� - ��������� �
���������������� ������� ����������. ����� ����, ��� ������������� ��������
AutoAdd ����� ��������� �� ������� ����� ��������� � ���������� �������
������� �� ���������������� ��������.

����� ������������ "���������" ������ - Count, Add, Insert, Move, Exchange,
Delete, Clear - ������ c ��������. ��� ������������� �������� AutoAdd ������
���� ������� ����� ��������� � ����������� ������������; ������, ��� �������
������ ����� Delete (10) �������� ������������� ���������� ������ �����.

����� ������������ ��������� ���� ������:

  +--------------+----------------+----------------+
  | ���          | ����� Get      | ����� Set      |
  +--------------+----------------+----------------+
  | integer      | GetInt         | SetInt         |
  | Cardinal     | GetCardinal    | SetCardinal    |
  | boolean      | GetBool        | SetBool        |
  | char         | GetChar        | SetChar        |
  | pointer      | GetPtr         | SetPtr         |
  | variant      | GetVariant     | SetVariant     |
  | PChar        | GetPChar       | SetPChar       |
  | AnsiString   | GetStr         | SetStr         |
  | WideString   | GetWideStr     | SetWideStr     |
  | Extended     | GetFloat       | SetFloat       |
  | TDateTime    | GetDate        | SetDate        |
  | TObject      | GetObj         | SetObj         |
  | TComponent   | GetComponent   | SetComponent   |
  | TStrings     | GetStrings     | SetStrings     |
  | TIcon        | GetIcon        | SetIcon        |
  | TClass       | GetClass       | SetClass       |
  | IInterface   | GetInterface   | SetInterface   |
  | TControl     | GetControl     | SetControl     |
  | TNotifyEvent | GetNotifyEvent | SetNotifyEvent |
  | TShiftState  | GetShiftState  | SetShiftState  |
  +--------------+----------------+----------------+

������ ������� ��� ������ ����� ������ ����� ���� ����� ��������� �
�����-������� (���, ������ ������� ��� ������ ���������� ������ ����� ��������
�� ������ GetObj/SetObj, ��. ���������� ��� TIcon ��� TControl).

����� ������������ ����������� �������������� ���������� �� ������ �� �����. ���
������������� ���� ����������� �����:

  - � ������������ ������ ��� �������� ����� ������� ����� SetSortOrder �
    ���������� ��������� ������ ����������

  - � �������� ������ ������ ��� �������� ������������ "�������������" ������
    ������ ��������.

���������� �������� ��� ������������� (SetSortInt), ��������� (SetSortStr) �
������ ��������, ��� ������� � ������ ��������� ����� SetSortXXXXX. ���
������������� ���������� ������� ����� � ����, ���:

  - ��� ��������� ����� � ������� �������� SortCaseInsensitive ����� ����
    �������� ������������������� ����������

  - ��������� ������ (Move, Exchange, Insert) ����������� � ������ ����������

  - ��������� �������� ������������ ���� �������� � ����������� ��������������
    � ��������� ������� �������������� ������.

��� ����������� ������� ����� Add ��������� ������ � �������� ������ - ����,
���� ������ �������� ������ � ������� ��������� �����.

��� ���������� ����� � ������������� ������ ������������ ����� InsertKey -
����� ����������� �������� ��������� ���� ���������� ��������� � �����������
������ �� ������ ����� � ������. ����������� ������ ����� ���� ������� �
������ � ������� ������� SortIndexOf ���� SortIndexRange.

��� ����� ������� ������ � ������������ ��������� ������������ ��������
��������. �������� - ��� ����� �������������� ������ �������, �� ���������� ��
���������� ����� ������� ����� ���� ������ (����� �� �������� �������� �����
���� ��������� ������, ����� ������). ������� IndexToBookmark � BookmarkToIndex
��������� �������� � ��������, ��� ������ ����� �������� ��-�� ���������� ���
������ �������� � ��������.

����� ����� ��������� ���������� ���������� � ��� �������� � ����������. ���
������, ��� �� �������� ������������ ������ (Free/FreeMem) ��� �����������,
������� ������� ���� ���������� �������� ������ ��������. ��� �������������
����� ������ ������� ������������ ������ GetOwnObj/SetOwnObj GetOwnPtr/SetOwnPtr
��������������.

������������ AddRecord ��������� ����� ���������� �������� �������� ����� ���
���� ����� ������ - ���������� �� �� ������� ��������. ��� ��������� ��������
� ��� ����������� �������. ������ ������� ����� � ����, ��� ������������
������������� ������ �� ��� ����������� variant-�������� � ��� �� �������������
��� ������������� �������� � "�� ���������������� variant" ������ �������
�������� ������������ ��������. ����� ����, ��� �� ������������� ��� �������
� own-���������� � ������ ������� �������� ������ ������.

���� ������� GetStoredStrings/SetStoredStrings ��������� ������� "�������
�����������" ������ ���� TStringList. � ���� ������ ������ ��������� ���
������ ��������� � GetStoredStrings, � ������ ������ ������ ���������
��������� ���������� ����� Assign.

------------------------------------------------------------------------------ }

{ ----- ������� ������ ---------------------------------------------------------

����� 1998 ����. ������ ������ ������.

03.05.2000 ������ ��������� �� ������ ��� Delphi 5
19.05.2000 �������� ����� Clear. ���������� ������ ����������� ������
22.05.2000 ��������� ������ GetBoolValue, SetBoolValue
21.09.2000 ��������� ������ GetStr, SetStr, GetFloat, SetFloat; ������
           Get/SetBoolValue ������������� � GetBool � SetBool, � ������
           Get/SetValue - � Get/SetInt
29.09.2000 ���� � ������� ������������ ��������� ����, �� ��������� ���� ����
           �� ���������, �������� bits index out of range

04.10.2000 ����� ������ ������ CTR View (������ ������ 2.0.18.76)

20.10.2000 �������� ���������� ��� - ������������ ��������� ��������������
           ���������. � ���������� ��������, ��������, ������� ���������� ������
           � CTR View �������� �� ����� (82% ��������� � ���)
23.11.2000 ��������� �������� AutoAdd - ��� ��������������� ���������� �������
           ��� ��������� �� ��������������� ��������
04.12.2000 ��������� �������� ������ �� ������� ���������� ������
08.12.2000 ��������� ����������� �������������� �� ��������� ���� � ������
           SortIndexOf, InsertRecord
27.12.2000 � ������� ������ �����������, ��� �� ������ ������� �������
           ���������������
05.01.2001 ��������� ������ ��� ������ � ���������� ������
09.01.2001 ��������� ��������� ��������
12.01.2001 ��������� ������������ AddRecord; ������������ InsertRecord
           ������������� � InsertKey
14.02.2001 ��������� ������������ GetStrings, SetStrings, SetOwnStrings,
           GetStoredStrings, SetStoredStrings. �������� ����� Exchange

17.07.2004 ������ ��������� ��� ������ ��� Delphi 6. ������ ������� �� ������
           ������������� ������. ������ ���������; � ���������, ���� �����������
           �� ���� �������������� ������ ������� � ������ ������� ����������
18.07.2004 ����� ������������ � TRecordList, ������ �������������� � RecordList.
           �� ����������� ������������ �������� ��������� ��������� �����������.
01.08.2004 �������� ����� SortIndexRange. ��������� ��������� ���� char (������
           GetChar, SetChar, SetSortChar)
10.08.2004 ������������� �������� ������ SortGetIndexFor � RequestRecord
14.08.2004 �������� ����������� ����� CreateStoredStrings
22.08.2004 ��������� ��������� �����������
17.01.2005 ������ ����������� - ����� ����� RegisterStringIndex � ������ GetStr,
           ����������� ������������ const
05.03.2005 ��������� ��������� TDateTime, � ��� ����� ����������� ����������
25.06.2007 ��������� ��������� PChar
28.06.2007 ��������� ��������� TClass
29.06.2007 ��������� ��������� TShiftState � TNotifyEvent
01.07.2007 ��������� ��������� TIcon
10.07.2007 ��������� ��������� variant
13.07.2007 ��������� ������������������� ����������-����� �����
17.01.2008 ��������� ������ � pointer-��� � cardinal-���. ���������� ������,
           ��-�� ������� ���������� variant-�������� Unassigned, �����������
           ������ ������, ��������� � AV
19.04.2008 ��������� ������ � WideString
21.04.2008 ���������� float �������� �� ����� �� ���������. ��� ��������
           AddRecord-� �������� � ������������ ������ ���, �� � ������
           ����������.
21.04.2008 ���������� ������ - SetOwnXXXX ������ �� ���������� ���������� ������
           ��� ���������.
23.04.2008 ���������� ������ - GetVariant ��������� ��������� �� ��������� Null
           ������ Unassigned. ���������� ������ � ���������� own �������� �
           ����������, ��-�� ������� ��� ���������� ���������� ����������
           �������� ������ �������� ������. ����� ��������� ����������� ������
           Add � AddRecord (��, ��������� ���� ������� ����...) 
23.04.2008 ����������� ���������� ����������� ���������� � ������������� ��
           ������, �� ����� ������������ �������� �������� � ��������� Assert,
           ��� �������� ��������� �� ��� ������ ������.
27.04.2008 �������� ����� SetLength; ���������� ����������.
01.05.2008 ��������� ������ Get/SetComponent � ���������� �� Object � Component.
           ������ SortIndexRange, ���� �� ����� �������, ���������� Low = -1,
           High = -2 - ����� ������� � ����� �������� ����� ��������� ��������
           ���� for i := Low to High.
10.06.2008 �����������. ����� ������� ����� Count � CheckRecordIndex. ����
           CheckRecordIndex ���������� � RequestRecord ��� � ���������
           �����������. ��������� Inline �������� ���� � ������� ����.
16.07.2008 ������� ���������, ��������� � ����� ��� Sphaera. ��� ���������
           �����������, � ��������� ����������� ��������� ���������� �������
           BookmarkToIndex; ��� ����� ������� ���������� ������ ������ ��
           ���������, �� ������������������� ��� ����� �������; ����� AddRecord
           ����� ClearSortOrder �� ��������������� ������ ������� ����������.
06.07.2009 ������� ���������, ��������� � ����� ��� Sphaera. ���������
           ���������� �� float �����, ��������� SetNextSortStr.

------------------------------------------------------------------------------ }

{ ----- ��������� �� ���������� ------------------------------------------------

��� ��������� ��������������� ������ ������ �� ���� ������� ����������
������������ ������������ RequestRecord (���� - RequestField ��������������).

������ � ����� char ����������� ����� ������ (������ XxxStr). ������� ����� �
���, ��� ��� char ����� �������������� � ��� string, � ��� ������ ����������
���������� ����� ������ ������� - � AddRecord, SortIndexOf ���. � �� �����
���������� �������� ������� ������� "��������" ���������� char, ������� ������
��� ����������� �� ���������� �� string.

����� � ������� �� ������������ � ������������, ��������� �� �������� ����������
����������� ������ - ��������� � ����� ������������ ������� �������� ���,
��������� �������������� ������� � ����

� ������� ���������� � �������� �������� ������������ ��������������� �����
������� ������, ���������� ��� ��������������� ������ �������

��� ���������-���������� ����� ������������ �������� ������� ���, ������� ����
�� ������� �������, �� ������� � ������� �� AnsiCompareXXX, CompareString ���
�������� ����� ������ ������������: �� ��������, ������ ��� ���������. ����
���� ���� ���-������ �������� ���������� ������ �� "����������" ������� ���
��� ����� - ������� � ������ ��������� ��� ������ ������.

------------------------------------------------------------------------------ }

unit RecordList;

{$Inline Auto}

interface

uses Windows, Classes, SysUtils, Variants, Controls, Graphics, AnsiStrings;

type

  TRLBookmark = integer;
  ERecordList = class (Exception);
  TRLFinalizer = class;
  TRLAdapter = class;
  TRLAdapterClass = class of TRLAdapter;
  TRLFieldType = (ftUnknown, ftInteger, ftString, ftWideString, ftFloat,
                  ftDate, ftPointer, ftObject, ftComponent);

  ///////////////////////////////////////////////////////////////////
  //               ��� ��� �������� �������� �������               //
  ///////////////////////////////////////////////////////////////////

  TRecordList = class
  private
    FlagOK      : boolean;
    FlagInitOK  : boolean;
    FList       : TList  ;
    FRecordLen  : integer;
    FRecordSize : integer;
    FLastIndex  : integer;
    FLastAddress: pointer;
    FAutoAdd    : boolean;
    FSortSet    : boolean;
    FSortIndex  : integer;
    FNextUsed   : boolean;
    FOnDelete   : TNotifyEvent;
    FSortFieldType: TRLFieldType;
    FSortCaseInsensitive: boolean;
    StringFinalizer, WideStringFinalizer, OwnObjFinalizer,
      IntfFinalizer, VariantFinalizer, OwnPtrFinalizer: TRLFinalizer;
  private
    procedure FinalizeRecord (ArrIndex: integer);
    function SortGetIndexFor (const Value; Adapter: TRLAdapterClass): integer; overload;
    function SortIndexOf (const Key; Adapter: TRLAdapterClass): integer; overload;
    procedure SortIndexRange (const Key; Adapter: TRLAdapterClass;
                              out Low, High: integer); overload;
  protected
    { ��������� ������ }
    function CheckOK: boolean;
    procedure CheckSortRequired;
    procedure CheckSortRestricted;
    function CheckRecordIndex (ArrIndex: integer): boolean;
    function CheckFieldIndex (FieldIndex: integer): boolean;
    procedure CheckSortAutoAdd (Found: boolean);
    function RequestRecord (ArrIndex: integer): pointer;
    function RequestField (ArrIndex, Index: integer): pointer;
    function MakeNewRecord: pointer;
    procedure SetSortOrder (Index: integer; AFieldType: TRLFieldType = ftUnknown);
    procedure SetSortNext (Index: integer);
    procedure ClearSortOrder;
    procedure Sort (FieldIndex: integer; FieldType: TRLFieldType);
    function InsertKeyCommon (NewIndex: integer): integer;
    function SortGetIndexFor (Value: integer): integer; overload;
    function SortGetIndexFor (Value: pointer): integer; overload;
    function SortGetIndexFor (Value: AnsiString): integer; overload;
    function SortGetIndexFor (Value: WideString): integer; overload;
    function SortGetIndexFor (Value: TDateTime): integer; overload;
    function CreateStoredStrings (Index: integer): TStrings; dynamic;
    { ������ ������� }
    procedure SetAutoAdd (NewAutoAdd: boolean);
    procedure SetRecordLength (Len: integer);
    procedure SetSortCaseInsensitive (NewCaseInsensitive: boolean);
    function GetInt (ArrIndex, Index: integer): integer;
    procedure SetInt (ArrIndex, Index, NewValue: integer);
    procedure SetSortInt (ArrIndex, Index, NewValue: integer);
    function GetCardinal (ArrIndex, Index: integer): Cardinal;
    procedure SetCardinal (ArrIndex, Index: integer; NewValue: Cardinal);
    function GetBool (ArrIndex, Index: integer): boolean;
    procedure SetBool (ArrIndex, Index: integer; NewValue: boolean);
    function GetChar (ArrIndex, Index: integer): AnsiChar;
    procedure SetChar (ArrIndex, Index: integer; NewValue: AnsiChar);
    procedure SetSortChar (ArrIndex, Index: integer; NewValue: AnsiChar);
    function GetPtr (ArrIndex, Index: integer): pointer;
    procedure SetPtr (ArrIndex, Index: integer; NewValue: pointer);
    procedure SetSortPtr (ArrIndex, Index: integer; NewValue: pointer);
    function GetOwnPtr (ArrIndex, Index: integer): pointer;
    procedure SetOwnPtr (ArrIndex, Index: integer; NewValue: pointer);
    procedure SetOwnSortPtr (ArrIndex, Index: integer; NewValue: pointer);
    function GetPChar (ArrIndex, Index: integer): PChar;
    procedure SetPChar (ArrIndex, Index: integer; NewValue: PChar);
    procedure SetOwnPChar (ArrIndex, Index: integer; NewValue: PChar);
    function GetPAnsiChar (ArrIndex, Index: integer): PAnsiChar;
    procedure SetPAnsiChar (ArrIndex, Index: integer; NewValue: PAnsiChar);
    procedure SetOwnPAnsiChar (ArrIndex, Index: integer; NewValue: PAnsiChar);
    function GetStr (ArrIndex, Index: integer): AnsiString;
    procedure SetStr (ArrIndex, Index: integer; NewValue: AnsiString);
    procedure SetSortStr (ArrIndex, Index: integer; NewValue: AnsiString);
    procedure SetNextSortStr (ArrIndex, Index: integer; NewValue: AnsiString);
    function GetWideStr (ArrIndex, Index: integer): WideString;
    procedure SetWideStr (ArrIndex, Index: integer; NewValue: WideString);
    procedure SetSortWideStr (ArrIndex, Index: integer; NewValue: WideString);
    function GetFloat (ArrIndex, Index: integer): Extended;
    procedure SetFloat (ArrIndex, Index: integer; NewValue: Extended);
    procedure SetSortFloat (ArrIndex, Index: integer; NewValue: Extended);
    function GetDate (ArrIndex, Index: integer): TDateTime;
    procedure SetDate (ArrIndex, Index: integer; NewValue: TDateTime);
    procedure SetSortDate (ArrIndex, Index: integer; NewValue: TDateTime);
    function GetObj (ArrIndex, Index: integer): TObject;
    procedure SetObj (ArrIndex, Index: integer; NewObject: TObject);
    procedure SetSortObj (ArrIndex, Index: integer; NewObject: TObject);
    function GetOwnObj (ArrIndex, Index: integer): TObject;
    procedure SetOwnObj (ArrIndex, Index: integer; NewObject: TObject);
    procedure SetSortOwnObj (ArrIndex, Index: integer; NewObject: TObject);
    function GetComponent (ArrIndex, Index: integer): TComponent;
    procedure SetComponent (ArrIndex, Index: integer; NewComponent: TComponent);
    procedure SetSortComponent (ArrIndex, Index: integer; NewComponent: TComponent);
    function GetStrings (ArrIndex, Index: integer): TStrings;
    procedure SetStrings (ArrIndex, Index: integer; NewStrings: TStrings);
    procedure SetOwnStrings (ArrIndex, Index: integer; NewStrings: TStrings);
    function GetStoredStrings (ArrIndex, Index: integer): TStrings;
    procedure SetStoredStrings (ArrIndex, Index: integer; NewStrings: TStrings);
    function GetIcon (ArrIndex, Index: integer): TIcon;
    procedure SetIcon (ArrIndex, Index: integer; NewIcon: TIcon);
    function GetOwnIcon (ArrIndex, Index: integer): TIcon;
    procedure SetOwnIcon (ArrIndex, Index: integer; NewIcon: TIcon);
    function GetClass (ArrIndex, Index: integer): TClass;
    procedure SetClass (ArrIndex, Index: integer; NewValue: TClass);
    procedure SetSortClass (ArrIndex, Index: integer; NewValue: TClass);
    function GetInterface (ArrIndex, Index: integer): IInterface;
    procedure SetInterface (ArrIndex, Index: integer; NewInterface: IInterface);
    function GetControl (ArrIndex, Index: integer): TControl;
    procedure SetControl (ArrIndex, Index: integer; NewControl: TControl);
    function GetNotifyEvent (ArrIndex, Index: integer): TNotifyEvent;
    procedure SetNotifyEvent (ArrIndex, Index: integer; NewEvent: TNotifyEvent);
    function GetShiftState (ArrIndex, Index: integer): TShiftState;
    procedure SetShiftState (ArrIndex, Index: integer; NewShift: TShiftState);
    function GetVariant (ArrIndex, Index: integer): variant;
    procedure SetVariant (ArrIndex, Index: integer; NewVariant: variant);
  protected
    property RecordLength: integer read FRecordLen write SetRecordLength;
    property RecordSize  : integer read FRecordSize;
    property SortIndex: integer read FSortIndex;
    property OnDelete: TNotifyEvent read FOnDelete write FOnDelete;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  public
    procedure SetLength (NewLength: integer);
    function  Count: integer;
    function  Add  : integer;
    function  Insert (Index: integer): integer;
    function  AddRecord (Data: array of variant): integer;
    function  InsertKey (Key: integer): integer; overload;
    function  InsertKey (Key: pointer): integer; overload;
    function  InsertKey (Key: AnsiString): integer; overload;
    function  InsertKey (Key: WideString): integer; overload;
    function  InsertKey (Key: Extended): integer; overload;
    function  InsertKey (Key: TDateTime): integer; overload;
    procedure Delete (Index: integer);
    procedure Clear;
    procedure Exchange (Index1, Index2: integer);
    procedure Move (IndexFrom, IndexTo: integer);
    function  SortIndexOf (Key: integer): integer; overload;
    function  SortIndexOf (Key: pointer): integer; overload;
    function  SortIndexOf (Key: AnsiString): integer; overload;
    function  SortIndexOf (Key: WideString): integer; overload;
    function  SortIndexOf (Key: TDateTime): integer; overload;
    procedure SortIndexRange (Key: integer;
                               out Low, High: integer); overload;
    procedure SortIndexRange (Key: pointer;
                               out Low, High: integer); overload;
    procedure SortIndexRange (Key: AnsiString;
                               out Low, High: integer); overload;
    procedure SortIndexRange (Key: WideString;
                               out Low, High: integer); overload;
    procedure SortIndexRange (Key: TDateTime;
                               out Low, High: integer); overload;
    function  InsertKey (Key: UnicodeString): integer; overload;
    function  SortIndexOf (Key: UnicodeString): integer; overload;
    procedure SortIndexRange (Key: UnicodeString;
                               out Low, High: integer); overload;
    function  IndexToBookmark (Index: integer): TRLBookmark;
    function  BookmarkToIndex (Bookmark: TRLBookmark): integer;
  public
    property AutoAdd: boolean read FAutoAdd write SetAutoAdd;
    property SortCaseInsensitive: boolean read FSortCaseInsensitive
      write SetSortCaseInsensitive;
  end;

  { ������ � ������� }
  TRLList = class (TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    Owner: TRecordList;
  end;

  { ��������������� ����� ��� ������� ������ ��� �������� ����� }
  TRLFinalizer = class (TBits)
  private
    Owner: TRecordList;
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); virtual; abstract;
  public
    constructor Create (AOwner: TRecordList);
    procedure RegisterField (Index: integer);
    function HasField (Index: integer): boolean;
    procedure FinalizeRecord (ArrIndex: integer);
    procedure FinalizeField (ArrIndex, Index: integer);
  end;

  { ��������������� ����� ��� ����������� ����� ���������� ��� ���� ������ }
  TRLAdapter = class
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; virtual; abstract;
  end;

implementation

resourcestring
  SSortRequired         = '����� ���������� ��� ������������� �������';
  SSortRestricted       = '����� ���������� ��� ����������� �������';
  SInvalidClass         = '����� (%s) ����������� ��������������� ' +
                          '� �� ����� � ������';
  SInvalidRecIndex      = '������������ ������ ������ (%d)';
  SInvalidPropIndex     = '������������ ������ �������� ��� ������ %s (%d)';
  SRequiresEmpty        = '�������� ����� ���� ��������� ������ ��� ' +
                          '���������� ���������� ������';
  SAddRecordUnsupported = '����� AddRecord �� ������������ variant-��� (%d)';
  SSortAutoAdd          = '��������� �������� AutoAdd ������������ � ' +
                          '����������� � ��������';
  SInvalidSortFieldType = '��� ����� ����� ���� ���������� �� ��������������';

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                          ��������������� ������                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

type

  TIntArray = array [0..MaxInt div 4 - 1] of integer;
  PIntArray = ^TIntArray;

  TStringFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TWideStringFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TOwnObjFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TIntfFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TVariantFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TOwnPtrFinalizer = class (TRLFinalizer)
  protected
    procedure FinalizeFieldImpl (ArrIndex, Index: integer); override;
  end;

  TIntAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TPtrAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TDateTimeAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TFloatAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TStringAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

  TWideStringAdapter = class (TRLAdapter)
  public
    class function Compare (Owner: TRecordList;
                            const Left, Right): integer; override;
  end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                               TRecordList                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

type
  { ��������������� ���� ������ ��� ��������� ����� }
  PInterface = ^IInterface;
  PPVariant = ^PVariant;

constructor TRecordList.Create;
begin
  FList := TList.Create;
  FLastIndex := -1;
  FSortIndex := -1;
  FlagInitOK := true;
  StringFinalizer := TStringFinalizer.Create (Self);
  WideStringFinalizer := TWideStringFinalizer.Create (Self);
  OwnObjFinalizer := TOwnObjFinalizer.Create (Self);
  IntfFinalizer := TIntfFinalizer.Create (Self);
  VariantFinalizer := TVariantFinalizer.Create (Self);
  OwnPtrFinalizer := TOwnPtrFinalizer.Create (Self);
end;

destructor TRecordList.Destroy;
begin
  FlagOk := false;
  Clear;
  FreeAndNil (FList);
  FLastIndex := -1;
  FreeAndNil (StringFinalizer);
  FreeAndNil (WideStringFinalizer);
  FreeAndNil (OwnObjFinalizer);
  FreeAndNil (IntfFinalizer);
  FreeAndNil (VariantFinalizer);
  FreeAndNil (OwnPtrFinalizer);
  inherited;
end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                             �������� ������                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{ ��������� ���������� ��������� � ������� }
procedure TRecordList.SetLength (NewLength: integer);
var i: integer;
begin
  CheckSortRestricted;
  for i := Count + 1 to NewLength do Add;
  for i := Count - 1 downto NewLength do Delete (i);
  Assert (Count = NewLength);
end;

{ ������� ���������� ��������� � ������� }
function TRecordList.Count: integer;
begin
  Result := FList.Count;
end;

{ ���������� ���������� �������� � ������� }
function TRecordList.Add: integer;
begin
  if not FSortSet then
    Result := Insert (Count)
  else
    case FSortFieldType of
      ftInteger   : Result := InsertKey (0);
      ftString    : Result := InsertKey ('');
      ftWideString: Result := InsertKey (WideString (''));
      ftFloat     : Result := InsertKey (0.0);
      ftDate      : Result := InsertKey (0.0);
      ftPointer,
      ftObject,
      ftComponent : Result := InsertKey (nil);
      else          Result := InsertKeyCommon (0);
    end;
end;

{ ������� ������ � ��������� ����� }
function TRecordList.Insert (Index: integer): integer;
var
  NewPtr: pointer;
begin
  CheckSortRestricted;
  NewPtr       := MakeNewRecord;
  FList.Insert (Index, NewPtr);
  FLastIndex   := Index;
  FLastAddress := NewPtr;
  Insert       := Index;
end;

{ ������� � ���������� ���������� �������� ������� }
function TRecordList.AddRecord (Data: array of variant): integer;
var
  ArrIndex, i: integer;
  Bookmark: TRLBookmark;
begin
  ArrIndex := Add;
  Bookmark := IndexToBookmark (ArrIndex);
  for i := Low (Data) to High (Data) do
  begin
    if VarIsStr (Data [i]) then
      if FSortIndex = i then
        begin
          SetSortStr (ArrIndex, i, AnsiString (Data [i]));
          ArrIndex := BookmarkToIndex (Bookmark);
        end
      else
        SetStr (ArrIndex, i, AnsiString (Data [i]))
    else if VarIsFloat (Data [i]) then
      if FSortIndex = i then
        begin
          SetSortFloat (ArrIndex, i, Data [i]);
          ArrIndex := BookmarkToIndex (Bookmark);
        end
      else
        SetFloat (ArrIndex, i, Data [i])
    else if VarIsOrdinal (Data [i]) then
      if FSortIndex = i then
        begin
          SetSortInt (ArrIndex, i, Data [i]);
          ArrIndex := BookmarkToIndex (Bookmark);
        end
      else
        SetInt (ArrIndex, i, Data [i])
    else if VarIsNull (Data [i]) then
      SetVariant (ArrIndex, i, Data [i])
    else
      raise ERecordList.CreateFmt (SAddRecordUnsupported, [VarType (Data [i])]);
  end;
  { ������ ��������� }
  Result := ArrIndex;
end;

{ ������� ������ � ��������������� ������ (����� ��������)}
function TRecordList.InsertKeyCommon (NewIndex: integer): integer;
var
  NewPtr: pointer;
begin
  Assert (FList <> nil);
  NewPtr := MakeNewRecord;
  FList.Insert (NewIndex, NewPtr);
  FLastIndex   := NewIndex;
  FLastAddress := NewPtr;
  Result := NewIndex;
end;

{ ������� ������ � ��������������� ������ }
function TRecordList.InsertKey (Key: integer): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetInt (Result, FSortIndex, Key);
end;

{ ������� ������ � ��������������� ������ }
function TRecordList.InsertKey (Key: pointer): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetPtr (Result, FSortIndex, Key);
end;

{ ������� ������ � ��������������� ������ }
function TRecordList.InsertKey (Key: AnsiString): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetStr (Result, FSortIndex, Key);
end;

{ ������� ������ � ��������������� ������ }
function TRecordList.InsertKey (Key: WideString): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetWideStr (Result, FSortIndex, Key);
end;

{ ������� ������ � ��������������� ������ }
function TRecordList.InsertKey (Key: Extended): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetFloat (Result, FSortIndex, Key);
end;

{ ������� ������ � ��������������� ������ }
function TRecordList.InsertKey (Key: TDateTime): integer;
begin
  Result := InsertKeyCommon (SortGetIndexFor (Key));
  SetDate (Result, FSortIndex, Key);
end;

{ �������� �������� �� ������� }
procedure TRecordList.Delete (Index: integer);
var Ptr: pointer;
begin
  Ptr := RequestRecord (Index);
  FinalizeRecord (Index);
  FList.Delete (Index);
  FreeMem (Ptr, RecordSize);
  FLastIndex := -1;
end;

{ ������� ������� }
procedure TRecordList.Clear;
var i: integer;
begin
  for i := Count - 1 downto 0 do Delete (i);
end;

{ ������������ ���� ��������� ������� }
procedure TRecordList.Exchange (Index1, Index2: integer);
begin
  CheckSortRestricted;
  CheckRecordIndex (Index1);
  CheckRecordIndex (Index2);
  FList.Exchange (Index1, Index2);
  FLastIndex := -1;
end;

{ ����������� ������ �� ����� ����� }
procedure TRecordList.Move (IndexFrom, IndexTo: integer);
begin
  CheckSortRestricted;
  CheckRecordIndex (IndexFrom);
  CheckRecordIndex (IndexTo);
  FList.Move (IndexFrom, IndexTo);
  FLastIndex := -1;
end;

{ ����� ������ �� ����� }
function TRecordList.SortIndexOf (Key: integer): integer;
begin
  Result := SortIndexOf (Key, TIntAdapter);
end;

{ ����� ������ �� ����� }
function TRecordList.SortIndexOf (Key: pointer): integer;
begin
  Result := SortIndexOf (Key, TPtrAdapter);
end;

{ ����� ������ �� ����� }
function TRecordList.SortIndexOf (Key: AnsiString): integer;
begin
  if FNextUsed then Key := AnsiStrings.AnsiLowerCase (Key);
  Result := SortIndexOf (Key, TStringAdapter);
end;

{ ����� ������ �� ����� }
function TRecordList.SortIndexOf (Key: WideString): integer;
begin
  Result := SortIndexOf (Key, TWideStringAdapter);
end;

function TRecordList.InsertKey (Key: UnicodeString): integer;
begin
  Result := InsertKey (AnsiString (Key));
end;

function TRecordList.SortIndexOf (Key: UnicodeString): integer;
begin
  Result := SortIndexOf (AnsiString (Key));
end;

procedure TRecordList.SortIndexRange (Key: UnicodeString;
                                      out Low, High: integer);
begin
  SortIndexRange (AnsiString (Key), Low, High);
end;

{ ����� ������ �� ����� }
function TRecordList.SortIndexOf (Key: TDateTime): integer;
begin
  Result := SortIndexOf (Key, TDateTimeAdapter);
end;

{ ����� ��������� ������� �� ����� }
procedure TRecordList.SortIndexRange (const Key;
                                      Adapter: TRLAdapterClass;
                                      out Low, High: integer);
begin
  { ���� �� �������, ������ �������� ������ �������� }
  Low := SortIndexOf (Key, Adapter);
  High := Low - 1;
  if Low < 0 then exit;
  { SortIndexOf ���������� ���� �� ������� - �������� � ������ ������ }
  High := Low;
  while (Low > 0) and (Adapter.Compare (Self,
                       RequestField (Low - 1, FSortIndex)^, Key) = 0) do
    Dec (Low);
  while (High < Count - 1) and (Adapter.Compare (Self,
                                RequestField (High + 1, FSortIndex)^, Key) = 0) do
    Inc (High);
end;


{ ����� ��������� ������� �� ����� }
procedure TRecordList.SortIndexRange (Key: integer;
                                      out Low, High: integer);
begin
  SortIndexRange (Key, TIntAdapter, Low, High);
end;

{ ����� ��������� ������� �� ����� }
procedure TRecordList.SortIndexRange (Key: pointer;
                                      out Low, High: integer);
begin
  SortIndexRange (Key, TPtrAdapter, Low, High);
end;

{ ����� ��������� ������� �� ����� }
procedure TRecordList.SortIndexRange (Key: AnsiString;
                                      out Low, High: integer);
begin
  if FNextUsed then Key := AnsiStrings.AnsiLowerCase (Key);
  SortIndexRange (Key, TStringAdapter, Low, High);
end;

{ ����� ��������� ������� �� ����� }
procedure TRecordList.SortIndexRange (Key: WideString;
                                      out Low, High: integer);
begin
  SortIndexRange (Key, TWideStringAdapter, Low, High);
end;

{ ����� ��������� ������� �� ����� }
procedure TRecordList.SortIndexRange (Key: TDateTime;
                                      out Low, High: integer);
begin
  SortIndexRange (Key, TDateTimeAdapter, Low, High);
end;

{ ������� �������� �� �������� ������� ������ }
function TRecordList.IndexToBookmark (Index: integer): TRLBookmark;
begin
  Assert (CheckOK);
  Result := TRLBookmark (RequestRecord (Index));
end;

{ ������� ������� �� �������� }
function TRecordList.BookmarkToIndex (Bookmark: TRLBookmark): integer;
begin
  Assert (CheckOK);
  Result := FList.IndexOf (pointer (Bookmark));
end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            ��������� ������                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{ �������� ���������� ������ � ������ }
function TRecordList.CheckOK: boolean;
begin
  Result := true;
  Assert (Self <> nil);
  if (not FlagInitOK) or not Assigned (FList) or (RecordLength <= 0) then
    raise ERecordList.CreateFmt (SInvalidClass, [Self.ClassName]);
  FlagOk := true;
end;

{ ��������, ����������� �� ���������� }
procedure TRecordList.CheckSortRequired;
begin
  if not FlagOk then CheckOK;
  if not FSortSet then raise ERecordList.Create (SSortRequired);
end;

{ ��������, ��� �� ���������� }
procedure TRecordList.CheckSortRestricted;
begin
  if not FlagOk then CheckOK;CheckOK;
  if FSortSet then raise ERecordList.Create (SSortRestricted);
end;

{ �������� ������������ ������� ������ }
function TRecordList.CheckRecordIndex (ArrIndex: integer): boolean;
begin
  RequestRecord (ArrIndex);
  Result := true;
end;

{ �������� ������������ ������� �������� }
function TRecordList.CheckFieldIndex (FieldIndex: integer): boolean;
begin
  if (FieldIndex >= 0) and (FieldIndex < RecordLength)
    then Result := true
    else raise ERecordList.CreateFmt (SInvalidPropIndex, [Self.ClassName, FieldIndex]);
end;

{ �������� ��������������� ������������� ������� }
procedure TRecordList.CheckSortAutoAdd (Found: boolean);
begin
  if Found then
    raise ERecordList.Create (SSortAutoAdd);
end;

{ ������� ������ ������ ������ }
function TRecordList.RequestRecord (ArrIndex: integer): pointer;
begin
  RequestRecord := RequestField (ArrIndex, 0);
end;

{ ������� ������ ���� ������ }
function TRecordList.RequestField (ArrIndex, Index: integer): pointer;
var TooBig: boolean;
begin
  Assert (CheckOK);
  if ArrIndex <> FLastIndex then
  begin
    TooBig := (ArrIndex >= Count);
    if AutoAdd and TooBig then
      SetLength (ArrIndex + 1)
    else if TooBig or (ArrIndex < 0) then
      raise ERecordList.CreateFmt (SInvalidRecIndex, [ArrIndex]);
    FLastAddress := FList.List [ArrIndex];
    FLastIndex := ArrIndex;
  end;
  Assert (CheckFieldIndex (Index));
  Result := @PIntArray (FLastAddress)^ [Index];
end;

{ ��������� � ���������� ������ ��� ����� ������ }
function TRecordList.MakeNewRecord: pointer;
begin
  if not FlagOk then CheckOK;
  Result := AllocMem (RecordSize);
end;

{ ��������� ������� ���������� ������ }
procedure TRecordList.SetSortOrder (Index: integer;
                                    AFieldType: TRLFieldType = ftUnknown);
begin
  Assert (CheckOK and CheckFieldIndex (Index));
  if not FSortSet then CheckSortAutoAdd (AutoAdd);
  FSortFieldType := AFieldType;
  if FSortSet and (Index = FSortIndex) then exit;
  if (Count > 0) then Sort (Index, AFieldType);
  FSortIndex := Index;
  FSortSet   := true;
end;

{ ��������� ������� ���������� �� ���� ����� }
procedure TRecordList.SetSortNext (Index: integer);
begin
  SetSortOrder (Index + 1, ftString);
  FNextUsed := true;
  SortCaseInsensitive := false;
end;

{ ����� �������������� ������� ���������� }
procedure TRecordList.ClearSortOrder;
begin
  Assert (CheckOK);
  FSortSet := false;
  FSortIndex := -1; { ���� �� �������, AddRecord ��������������� ���������� }
  FSortFieldType := ftUnknown;
end;

threadvar
  CmpOwner: TRecordList;
  CmpOffset: integer;
  CmpAdapter: TRLAdapterClass;

function SortCmpFunc (Item1, Item2: Pointer): Integer;
var F1, F2: pointer;
begin
  F1 := @PIntArray (Item1) [CmpOffset];
  F2 := @PIntArray (Item2) [CmpOffset];
  Result := CmpAdapter.Compare (CmpOwner, F1^, F2^);
end;

{ ���������� �� ��������� ���� }
procedure TRecordList.Sort (FieldIndex: integer; FieldType: TRLFieldType);
begin
  CheckSortRestricted;
  CheckFieldIndex (FieldIndex);
  CmpOwner := Self;
  CmpOffset := FieldIndex;
  case FieldType of
    ftInteger   : CmpAdapter := TIntAdapter;
    ftString    : CmpAdapter := TStringAdapter;
    ftWideString: CmpAdapter := TWideStringAdapter;
    ftDate      : CmpAdapter := TDateTimeAdapter;
    ftFloat     : CmpAdapter := TFloatAdapter;
    ftPointer   : CmpAdapter := TPtrAdapter;
    ftObject    : CmpAdapter := TPtrAdapter;
    ftComponent : CmpAdapter := TPtrAdapter;
    else raise ERecordList.Create (SInvalidSortFieldType);
  end;
  FList.Sort (SortCmpFunc);
end;

{ ����� ����� ��� ��������� �������� ��� ���������� }
function TRecordList.SortGetIndexFor (const Value; Adapter: TRLAdapterClass): integer;
var
  Left, Right, Test, CmpResult: integer;
begin
  CheckSortRequired;
  Left := 0;
  Right := Count;
  while Left < Right do
  begin
    Test := (Left + Right) div 2;
    CmpResult := Adapter.Compare (Self, RequestField (Test, FSortIndex)^, Value);
    if CmpResult < 0 then
      Left := Test + 1
    else if CmpResult > 0 then
      Right := Test
    else
      begin
        Left := Test;
        Right := Test;
      end;
  end;
  Result := Left;
end;

{ ����� ������ �� ����� }
function TRecordList.SortIndexOf (const Key; Adapter: TRLAdapterClass): integer;
var
  Index: integer;
  Field: pointer;
begin
  Result := -1;
  Index := SortGetIndexFor (Key, Adapter);
  if Index >= Count then exit;
  Field := RequestField (Index, FSortIndex);
  if Adapter.Compare (Self, Field^, Key) = 0 then Result := Index;
end;

{ ����� ����� ��� ��������� �������� ��� ���������� �� integer ���� }
function TRecordList.SortGetIndexFor (Value: integer): integer;
begin
  Result := SortGetIndexFor (Value, TIntAdapter);
end;

{ ����� ����� ��� ��������� �������� ��� ���������� �� pointer ���� }
function TRecordList.SortGetIndexFor (Value: pointer): integer;
begin
  Result := SortGetIndexFor (Value, TPtrAdapter);
end;

{ ����� ����� ��� ��������� �������� ��� ���������� �� ���������� ���� }
function TRecordList.SortGetIndexFor (Value: AnsiString): integer;
begin
  if FNextUsed then Value := AnsiStrings.AnsiLowerCase (Value);
  Result := SortGetIndexFor (Value, TStringAdapter);
end;

{ ����� ����� ��� ��������� �������� ��� ���������� �� ���������� ���� }
function TRecordList.SortGetIndexFor (Value: WideString): integer;
begin
  Result := SortGetIndexFor (Value, TWideStringAdapter);
end;

{ ����� ����� ��� ��������� �������� ��� ���������� �� ���� ���� }
function TRecordList.SortGetIndexFor (Value: TDateTime): integer;
begin
  Result := SortGetIndexFor (Value, TDateTimeAdapter);
end;

{ �������� "���������" ������ ����� }
function TRecordList.CreateStoredStrings (Index: integer): TStrings;
begin
  Result := TStringList.Create;
end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                              ������ �������                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{ ��������� ������ �������������� }
procedure TRecordList.SetAutoAdd (NewAutoAdd: boolean);
begin
  if NewAutoAdd then CheckSortAutoAdd (FSortSet);
  FAutoAdd := NewAutoAdd;
end;

{ ��������� ���������� ����� � ������ }
procedure TRecordList.SetRecordLength (Len: integer);
begin
  if RecordLength = Len then exit;
  if Count > 0 then Clear;
  FRecordLen  := Len;
  FRecordSize := Len * SizeOf (Integer);
end;

{ ��������� ������ ���������� }
procedure TRecordList.SetSortCaseInsensitive (NewCaseInsensitive: boolean);
begin
  if FSortCaseInsensitive = NewCaseInsensitive then exit;
  if Count > 0 then raise ERecordList.Create (SRequiresEmpty);
  FSortCaseInsensitive := NewCaseInsensitive;
end;

{ ������� �������� ���������� ���� (integer)}
function TRecordList.GetInt (ArrIndex, Index: integer): integer;
begin
  Result := PInteger (RequestField (ArrIndex, Index))^;
end;

{ ��������� �������� ���������� ���� (integer)}
procedure TRecordList.SetInt (ArrIndex, Index, NewValue: integer);
begin
  PInteger (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ ��������� �������� ��������� ���� (integer)}
procedure TRecordList.SetSortInt (ArrIndex, Index, NewValue: integer);
var NewRow: integer;
begin
  SetSortOrder (Index, ftInteger);
  if GetInt (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetInt (NewRow, Index, NewValue);
end;

{ ������� �������� ���������� ���� (Cardinal)}
function TRecordList.GetCardinal (ArrIndex, Index: integer): Cardinal;
begin
  Result := PCardinal (RequestField (ArrIndex, Index))^;
end;

{ ��������� �������� ���������� ���� (Cardinal)}
procedure TRecordList.SetCardinal (ArrIndex, Index: integer; NewValue: Cardinal);
var INewValue: integer absolute NewValue;
begin
  PCardinal (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ ������� �������� ���������� ���� (boolean)}
function TRecordList.GetBool (ArrIndex, Index: integer): boolean;
begin
  GetBool := (GetInt (ArrIndex, Index) <> 0);
end;

{ ��������� �������� ���������� ���� (boolean)}
procedure TRecordList.SetBool (ArrIndex, Index: integer; NewValue: boolean);
begin
  SetInt (ArrIndex, Index, Ord (NewValue));
end;

{ ������� �������� ���������� ���� (char)}
function TRecordList.GetChar (ArrIndex, Index: integer): AnsiChar;
var S: AnsiString;
begin
  S := GetStr (ArrIndex, Index);
  if S <> '' then Result := S [1] else Result := #0;
end;

{ ��������� �������� ���������� ���� (char)}
procedure TRecordList.SetChar (ArrIndex, Index: integer; NewValue: AnsiChar);
begin
  SetStr (ArrIndex, Index, NewValue);
end;

{ ��������� �������� ���������� ������������ ���� (char)}
procedure TRecordList.SetSortChar (ArrIndex, Index: integer; NewValue: AnsiChar);
begin
  SetSortStr (ArrIndex, Index, NewValue);
end;

{ ������� �������� ���������� ���� (pointer)}
function TRecordList.GetPtr (ArrIndex, Index: integer): pointer;
begin
  Result := PPointer (RequestField (ArrIndex, Index))^;
end;

{ ��������� �������� ���������� ���� (pointer)}
procedure TRecordList.SetPtr (ArrIndex, Index: integer; NewValue: pointer);
var OldValue: pointer;
begin
  if OwnPtrFinalizer.HasField (Index) then
  begin
    OldValue := GetPtr (ArrIndex, Index);
    if OldValue = NewValue then exit;
    OwnPtrFinalizer.FinalizeField (ArrIndex, Index);
  end;
  PPointer (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ ��������� �������� ������������ ���� (pointer)}
procedure TRecordList.SetSortPtr (ArrIndex, Index: integer; NewValue: pointer);
var NewRow: integer;
begin
  SetSortOrder (Index, ftPointer);
  if GetPtr (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow = ArrIndex then exit;
  if NewRow > ArrIndex then Dec (NewRow);
  FList.Move (ArrIndex, NewRow);
  FLastIndex := -1;
  SetPtr (NewRow, Index, NewValue);
end;

{ ������� �������� ���������� ������������ ���� (pointer)}
function TRecordList.GetOwnPtr (ArrIndex, Index: integer): pointer;
begin
  OwnPtrFinalizer.RegisterField (Index);
  Result := PPointer (RequestField (ArrIndex, Index))^;
end;

{ ��������� �������� ���������� ������������ ���� (pointer)}
procedure TRecordList.SetOwnPtr (ArrIndex, Index: integer; NewValue: pointer);
begin
  OwnPtrFinalizer.RegisterField (Index);
  SetPtr (ArrIndex, Index, NewValue);
end;

{ ��������� �������� ������������ ������������ ���� (pointer)}
procedure TRecordList.SetOwnSortPtr (ArrIndex, Index: integer; NewValue: pointer);
begin
  OwnPtrFinalizer.RegisterField (Index);
  SetSortPtr (ArrIndex, Index, NewValue);
end;

{ ������� �������� ���������� ���� (char)}
function TRecordList.GetPChar (ArrIndex, Index: integer): PChar;
begin
  Result := PChar (GetPtr (ArrIndex, Index));
end;

{ ��������� �������� ���������� ���� (char)}

procedure TRecordList.SetPChar (ArrIndex, Index: integer; NewValue: PChar);
begin
  SetPtr (ArrIndex, Index, NewValue);
end;

procedure TRecordList.SetOwnPChar (ArrIndex, Index: integer; NewValue: PChar);
begin
  SetOwnPtr (ArrIndex, Index, NewValue);
end;

{ ������� �������� ���������� ���� (AnsiChar)}
function TRecordList.GetPAnsiChar (ArrIndex, Index: integer): PAnsiChar;
begin
  Result := PAnsiChar (GetPtr (ArrIndex, Index));
end;

{ ��������� �������� ���������� ���� (AnsiChar)}

procedure TRecordList.SetPAnsiChar (ArrIndex, Index: integer; NewValue: PAnsiChar);
begin
  SetPtr (ArrIndex, Index, NewValue);
end;

procedure TRecordList.SetOwnPAnsiChar (ArrIndex, Index: integer; NewValue: PAnsiChar);
begin
  SetOwnPtr (ArrIndex, Index, NewValue);
end;

{ ������� �������� ���������� ���� (string)}
function TRecordList.GetStr (ArrIndex, Index: integer): AnsiString;
begin
  StringFinalizer.RegisterField (Index);
  Result := PAnsiString (RequestField (ArrIndex, Index))^;
end;

{ ��������� �������� ���������� ���� (string)}
procedure TRecordList.SetStr (ArrIndex, Index: integer;
                              NewValue: AnsiString);
begin
  StringFinalizer.RegisterField (Index);
  PAnsiString (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ ��������� �������� ��������� ���� (string)}
procedure TRecordList.SetSortStr (ArrIndex, Index: integer;
                                  NewValue: AnsiString);
var NewRow: integer;
begin
  SetSortOrder (Index, ftString);
  if GetStr (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetStr (NewRow, Index, NewValue);
end;

{ ��������� �������� �������� ���� ����� (string)}
procedure TRecordList.SetNextSortStr (ArrIndex, Index: integer; NewValue: AnsiString);
begin
  FNextUsed := true;
  SetStr (ArrIndex, Index, NewValue);
  SetSortStr (ArrIndex, Index + 1, AnsiStrings.AnsiLowerCase (NewValue));
end;

{ ������� �������� ���������� ���� (string)}
function TRecordList.GetWideStr (ArrIndex, Index: integer): WideString;
begin
  WideStringFinalizer.RegisterField (Index);
  Result := PWideString (RequestField (ArrIndex, Index))^;
end;

{ ��������� �������� ���������� ���� (string)}
procedure TRecordList.SetWideStr (ArrIndex, Index: integer;
                                  NewValue: WideString);
begin
  WideStringFinalizer.RegisterField (Index);
  PWideString (RequestField (ArrIndex, Index))^ := NewValue;
end;

{ ��������� �������� ��������� ���� (string)}
procedure TRecordList.SetSortWideStr (ArrIndex, Index: integer;
                                      NewValue: WideString);
var NewRow: integer;
begin
  SetSortOrder (Index, ftWideString);
  if GetWideStr (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetWideStr (NewRow, Index, NewValue);
end;

{ ������� �������� ���������� ���� (float)}
function TRecordList.GetFloat (ArrIndex, Index: integer): Extended;
var P: PExtended;
begin
  P := GetPtr (ArrIndex, Index);
  if Assigned (P) then Result := P^ else Result := 0.0;
end;

{ ��������� �������� ���������� ���� (float)}
procedure TRecordList.SetFloat (ArrIndex, Index: integer;
                                NewValue: Extended);
var P: PExtended;
begin
  P := GetPtr (ArrIndex, Index);
  if not Assigned (P) then GetMem (P, SizeOf (P^));
  P^ := NewValue;
  SetOwnPtr (ArrIndex, Index, P);
end;

{ ��������� �������� ��������� ���� (float)}
procedure TRecordList.SetSortFloat (ArrIndex, Index: integer; NewValue: Extended);
var NewRow: integer;
begin
  SetSortOrder (Index, ftFloat);
  if GetFloat (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetFloat (NewRow, Index, NewValue);
end;

{ ������� �������� ���������� ���� (date)}
function TRecordList.GetDate (ArrIndex, Index: integer): TDateTime;
begin
  Result := GetFloat (ArrIndex, Index);
end;

{ ��������� �������� ���������� ���� (date)}
procedure TRecordList.SetDate (ArrIndex, Index: integer;
                               NewValue: TDateTime);
begin
  SetFloat (ArrIndex, Index, NewValue);
end;

{ ��������� �������� ��������� ���� (date)}
procedure TRecordList.SetSortDate (ArrIndex, Index: integer;
                                   NewValue: TDateTime);
var NewRow: integer;
begin
  SetSortOrder (Index, ftDate);
  if GetDate (ArrIndex, Index) = NewValue then exit;
  NewRow := SortGetIndexFor (NewValue);
  if NewRow <> ArrIndex then
  begin
    if NewRow > ArrIndex then Dec (NewRow);
    FList.Move (ArrIndex, NewRow);
    FLastIndex := -1;
  end;
  SetDate (NewRow, Index, NewValue);
end;

{ ������� �������� ���������� ���� (TObject)}
function TRecordList.GetObj (ArrIndex, Index: integer): TObject;
begin
  GetObj := TObject (GetPtr (ArrIndex, Index));
end;

{ ��������� �������� ���������� ���� (TObject)}
procedure TRecordList.SetObj (ArrIndex, Index: integer; NewObject: TObject);
var OldObject: TObject;
begin
  if OwnObjFinalizer.HasField (Index) then
  begin
    OldObject := GetObj (ArrIndex, Index);
    if OldObject = NewObject then exit;
    OwnObjFinalizer.FinalizeField (ArrIndex, Index);
  end;
  SetPtr (ArrIndex, Index, NewObject);
end;

{ ��������� �������� ������������ ���� (TObject)}
procedure TRecordList.SetSortObj (ArrIndex, Index: integer; NewObject: TObject);
var OldObject: TObject;
begin
  if OwnObjFinalizer.HasField (Index) then
  begin
    OldObject := GetObj (ArrIndex, Index);
    if OldObject = NewObject then exit;
    OwnObjFinalizer.FinalizeField (ArrIndex, Index);
  end;
  SetSortPtr (ArrIndex, Index, NewObject);
end;

{ ������� �������� ���������� ���� (TObject)}
function TRecordList.GetOwnObj (ArrIndex, Index: integer): TObject;
begin
  OwnObjFinalizer.RegisterField (Index);
  Result := GetObj (ArrIndex, Index);
end;

{ ��������� �������� ���������� ���� (TObject)}
procedure TRecordList.SetOwnObj (ArrIndex, Index: integer;
                                 NewObject: TObject);
begin
  OwnObjFinalizer.RegisterField (Index);
  SetObj (ArrIndex, Index, NewObject);
end;

{ ��������� �������� ������������ ���� (TObject)}
procedure TRecordList.SetSortOwnObj (ArrIndex, Index: integer; NewObject: TObject);
begin
  OwnObjFinalizer.RegisterField (Index);
  SetSortObj (ArrIndex, Index, NewObject);
end;

{ ������� �������� ���������� ���� (TComponent)}
function TRecordList.GetComponent (ArrIndex, Index: integer): TComponent;
begin
  Result := TComponent (GetObj (ArrIndex, Index));
end;

{ ��������� �������� ���������� ���� (TComponent)}
procedure TRecordList.SetComponent (ArrIndex, Index: integer;
                                    NewComponent: TComponent);
begin
  SetObj (ArrIndex, Index, NewComponent);
end;

{ ��������� �������� ������������ ���� (TComponent)}
procedure TRecordList.SetSortComponent (ArrIndex, Index: integer;
                                        NewComponent: TComponent);
begin
  SetSortObj (ArrIndex, Index, NewComponent);
end;

{ ������� �������� ���������� ���� (TStrings)}
function TRecordList.GetStrings (ArrIndex, Index: integer): TStrings;
begin
  Result := TStrings (GetObj (ArrIndex, Index));
end;

{ ��������� �������� ���������� ���� (TStrings)}
procedure TRecordList.SetStrings (ArrIndex, Index: integer;
                                   NewStrings: TStrings);
begin
  SetObj (ArrIndex, Index, NewStrings);
end;

{ ��������� �������� ���������� ���� (TStrings)}
procedure TRecordList.SetOwnStrings (ArrIndex, Index: integer;
                                      NewStrings: TStrings);
begin
  SetOwnObj (ArrIndex, Index, NewStrings);
end;

{ ������� �������� ���� (�������� TStrings)}
function TRecordList.GetStoredStrings (ArrIndex, Index: integer): TStrings;
begin
  Result := GetStrings (ArrIndex, Index);
  if Assigned (Result) then exit;
  Result := CreateStoredStrings (Index);
  SetOwnObj (ArrIndex, Index, Result);
end;

{ ��������� �������� ���� (�������� TStrings)}
procedure TRecordList.SetStoredStrings (ArrIndex, Index: integer;
                                         NewStrings: TStrings);
begin
  GetStoredStrings (ArrIndex, Index).Assign (NewStrings);
end;

{ ������� �������� ���������� ���� (Icon)}
function TRecordList.GetIcon (ArrIndex, Index: integer): TIcon;
begin
  Result := TIcon (GetObj (ArrIndex, Index));
end;

{ ��������� �������� ���������� ���� (Icon)}
procedure TRecordList.SetIcon (ArrIndex, Index: integer; NewIcon: TIcon);
begin
  SetObj (ArrIndex, Index, NewIcon);
end;

{ ������� �������� ���������� ���� (Icon)}
function TRecordList.GetOwnIcon (ArrIndex, Index: integer): TIcon;
begin
  Result := TIcon (GetOwnObj (ArrIndex, Index));
end;

{ ��������� �������� ���������� ���� (Icon)}
procedure TRecordList.SetOwnIcon (ArrIndex, Index: integer; NewIcon: TIcon);
begin
  SetOwnObj (ArrIndex, Index, NewIcon);
end;

{ ������� �������� ���� (class) }
function TRecordList.GetClass (ArrIndex, Index: integer): TClass;
begin
  Result := TClass (GetPtr (ArrIndex, Index));
end;

{ ��������� �������� ���� (class)}
procedure TRecordList.SetClass (ArrIndex, Index: integer; NewValue: TClass);
begin
  SetPtr (ArrIndex, Index, NewValue);
end;

{ ��������� �������� ������������ ���� (class)}
procedure TRecordList.SetSortClass (ArrIndex, Index: integer; NewValue: TClass);
begin
  SetSortPtr (ArrIndex, Index, NewValue);
end;

{ ������� �������� ���� (interface)}
function TRecordList.GetInterface (ArrIndex, Index: integer): IInterface;
begin
  Result := PInterface (RequestField (ArrIndex, Index))^;
end;

{ ��������� �������� ���� (interface)}
procedure TRecordList.SetInterface (ArrIndex, Index: integer;
                                     NewInterface: IInterface);
begin
  IntfFinalizer.RegisterField (Index);
  PInterface (RequestField (ArrIndex, Index))^ := NewInterface;
end;

{ ������� �������� ���� (TControl)}
function TRecordList.GetControl (ArrIndex, Index: integer): TControl;
begin
  Result := TControl (GetObj (ArrIndex, Index));
end;

{ ��������� �������� ���� (TControl)}
procedure TRecordList.SetControl (ArrIndex, Index: integer;
                                   NewControl: TControl);
begin
  SetObj (ArrIndex, Index, NewControl);
end;

type
  PNotifyEvent = ^TNotifyEvent;

{ ������� �������� ���� (TNotifyEvent)}
function TRecordList.GetNotifyEvent (ArrIndex, Index: integer): TNotifyEvent;
var P: PNotifyEvent;
begin
  Result := nil;
  P := GetPtr (ArrIndex, Index);
  if Assigned (P) then Result := P^;
end;

{ ��������� �������� ���� (TNotifyEvent)}
procedure TRecordList.SetNotifyEvent (ArrIndex, Index: integer;
                                      NewEvent: TNotifyEvent);
var P: PNotifyEvent;
begin
  if @NewEvent = nil then
    SetOwnPtr (ArrIndex, Index, nil)
  else
    begin
      P := GetPtr (ArrIndex, Index);
      if not Assigned (P) then
      begin
        GetMem (P, SizeOf (TNotifyEvent));
        SetOwnPtr (ArrIndex, Index, P);
      end;
      P^ := NewEvent;
    end;
end;                                          

{ ������� �������� ���� (TShiftState)}
function TRecordList.GetShiftState (ArrIndex, Index: integer): TShiftState;
begin
  word (Result) := LoWord (GetInt (ArrIndex, Index));
end;

{ ��������� �������� ���� (TShiftState)}
procedure TRecordList.SetShiftState (ArrIndex, Index: integer; NewShift: TShiftState);
begin
  SetInt (ArrIndex, Index, word (NewShift));
end;

{ ������� �������� ���� (variant)}
function TRecordList.GetVariant (ArrIndex, Index: integer): variant;
var Ptr: PVariant;
begin
  Result := Null;
  VariantFinalizer.RegisterField (Index);
  Ptr := PPVariant (RequestField (ArrIndex, Index))^;
  if Assigned (Ptr) then Result := Ptr^ else Result := Unassigned;
end;

{ ��������� �������� ���� (variant)}
procedure TRecordList.SetVariant (ArrIndex, Index: integer; NewVariant: variant);
var Ptr: PPVariant;
begin
  VariantFinalizer.RegisterField (Index);
  Ptr := RequestField (ArrIndex, Index);
  if VarType (NewVariant) = varEmpty then
    begin
      if not Assigned (Ptr^) then exit;
      Ptr^^ := Unassigned;
      Dispose (Ptr^);
      Ptr^ := nil;
    end
  else
    begin
      if Ptr^ = nil then New (Ptr^);
      Ptr^^ := NewVariant;
    end;
end;

{ ������������ ������, ������� ���������� ���������� }
procedure TRecordList.FinalizeRecord (ArrIndex: integer);
begin
  StringFinalizer.FinalizeRecord (ArrIndex);
  WideStringFinalizer.FinalizeRecord (ArrIndex);
  OwnObjFinalizer.FinalizeRecord (ArrIndex);
  IntfFinalizer.FinalizeRecord (ArrIndex);
  VariantFinalizer.FinalizeRecord (ArrIndex);
  OwnPtrFinalizer.FinalizeRecord (ArrIndex);
end;

{ TRLFinalizer }

constructor TRLFinalizer.Create (AOwner: TRecordList);
begin
  Assert (AOwner <> nil);
  inherited Create;
  Owner := AOwner;
end;

procedure TRLFinalizer.FinalizeRecord (ArrIndex: integer);
var i: integer;
begin
  for i := 0 to Size - 1 do
    if Bits [i] then FinalizeField (ArrIndex, i);
end;

procedure TRLFinalizer.FinalizeField (ArrIndex, Index: integer);
begin
  if HasField (Index) then FinalizeFieldImpl (ArrIndex, Index);
end;

function TRLFinalizer.HasField (Index: integer): boolean;
begin
  Result := (Index < Size) and Bits [Index];
end;

procedure TRLFinalizer.RegisterField (Index: integer);
begin
  if Owner.CheckFieldIndex (Index) then Bits [Index] := true;
end;

{ TStringFinalizer }

procedure TStringFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.SetStr (ArrIndex, Index, '');
end;

{ TWideStringFinalizer }

procedure TWideStringFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.SetWideStr (ArrIndex, Index, '');
end;

{ TOwnObjFinalizer }

procedure TOwnObjFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.GetObj (ArrIndex, Index).Free;
end;

{ TIntfFinalizer }

procedure TIntfFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.SetInterface (ArrIndex, Index, nil);
end;

{ TVariantFinalizer }

procedure TVariantFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  Owner.SetVariant (ArrIndex, Index, Unassigned);
end;

{ TOwnPtrFinalizer }

procedure TOwnPtrFinalizer.FinalizeFieldImpl (ArrIndex, Index: integer);
begin
  Assert (Owner <> nil);
  FreeMem (Owner.GetPtr (ArrIndex, Index));
end;

{ TIntAdapter }

class function TIntAdapter.Compare (Owner: TRecordList;
                                    const Left, Right): integer;
var
  ILeft: integer absolute Left;
  IRight: integer absolute Right;
begin
  Result := ILeft - IRight;
end;

{ TPtrAdapter }

class function TPtrAdapter.Compare (Owner: TRecordList;
                                    const Left, Right): integer;
begin
  Result := TIntAdapter.Compare (Owner, Left, Right);                                    
end;

{ TDateTimeAdapter }

class function TDateTimeAdapter.Compare (Owner: TRecordList;
                                         const Left, Right): integer;
var
  DLeft: ^Extended absolute Left;
  DRight: TDateTime absolute Right;
  Cmp: Extended;
begin
  if DLeft = nil then Cmp := -DRight else Cmp := DLeft^ - DRight;
  if Cmp < 0 then
    Result := -1
  else if Cmp > 0 then
    Result := 1
  else
    Result := 0;
end;

{ TFloatAdapter }

class function TFloatAdapter.Compare (Owner: TRecordList;
                                         const Left, Right): integer;
var
  FLeft: ^Extended absolute Left;
  FRight: ^Extended absolute Right;
begin
  if FLeft^ < FRight^ then
    Result := -1
  else if FLeft^ > FRight^ then
    Result := 1
  else
    Result := 0;
end;

{ TStringAdapter }

class function TStringAdapter.Compare (Owner: TRecordList;
                                       const Left, Right): integer;
var
  SLeft: AnsiString absolute Left;
  SRight: AnsiString absolute Right;
  TLeft, TRight: AnsiString;
begin
  if Owner.SortCaseInsensitive then
    begin
      TLeft := AnsiStrings.AnsiLowerCase (SLeft);
      TRight := AnsiStrings.AnsiLowerCase (SRight);
    end
  else
    begin
      TLeft := SLeft;
      TRight := SRight;
    end;
  if TLeft < TRight then
    Result := -1
  else if TLeft > TRight then
    Result := 1
  else
    Result := 0;
end;

{ TWideStringAdapter }

class function TWideStringAdapter.Compare (Owner: TRecordList;
                                           const Left, Right): integer;
var
  SLeft: WideString absolute Left;
  SRight: WideString absolute Right;
  TLeft, TRight: WideString;
begin
  if Owner.SortCaseInsensitive then
    begin
      TLeft := WideLowerCase (SLeft);
      TRight := WideLowerCase (SRight);
    end
  else
    begin
      TLeft := SLeft;
      TRight := SRight;
    end;
  if TLeft < TRight then
    Result := -1
  else if TLeft > TRight then
    Result := 1
  else
    Result := 0;
end;

{ TRLList }

procedure TRLList.Notify (Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if (Action <> lnAdded) and Assigned (Owner) and Assigned (Owner.FOnDelete) then
    Owner.FOnDelete (Owner);
end;

initialization
  Assert (SizeOf (Cardinal)   = SizeOf (integer));
  Assert (SizeOf (pointer)    = SizeOf (integer));
  Assert (SizeOf (AnsiString) = SizeOf (integer));
  Assert (SizeOf (WideString) = SizeOf (integer));
end.

