function ZR_PROGRAM_BuiltTestResult(varargin)
% �����ĳ������ɲ��Ա���
ZR_CONFIG_File(varargin{:});
% �����ݿ��е�������
ZR_ExtractHistoryDataFromMySQL();
% �ض��������������ģʽ
ZR_RunSpecialTestCase();
end