////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                           Sanders the Softwarer                            //
//                                                                            //
//    TSTSNotifier - ��������� ��� �������� � ��������� ������� ����������    //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

unit StsListBoxDsgn;

interface

procedure Register;

implementation

uses Classes, StsListBox;

procedure Register;
begin
  RegisterComponents ('Sanders the Softwarer', [TSTSListBox]);
end;

end.
