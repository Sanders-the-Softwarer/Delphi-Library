////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                           Sanders the Softwarer                            //
//                                                                            //
//    TSTSNotifier - ��������� ��� �������� � ��������� ������� ����������    //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

unit StsNotifierDsgn;

interface

procedure Register;

implementation

uses Classes, StsNotifier;

procedure Register;
begin
  RegisterComponents ('Sanders the Softwarer', [TSTSNotifier, TSTSNotifierLink]);
end;

end.
