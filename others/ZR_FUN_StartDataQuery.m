function ZR_FUN_StartDataQuery(varargin)
clear global;
% ���������ļ�
ZR_CONFIG_DataQuery_File(varargin{:});
% �����ݿ��е�������
ZR_ExtractHistoryDataFromMySQL();
end