function ZR_CONFIG_DataQuery_File(varargin)
% ��������в��������б���

global G_ExtractHistoryDataFromMySQL;
global g_XMLfile;

G_ExtractHistoryDataFromMySQL=[];

switch varargin{1}
    case 'xml'
        if nargin>0
            % ��XML�ļ������
            ZR_CONFIG_SetFromXML(varargin{2});
        else
            error('����ִ�б�������xml�ļ�')
        end        
    case 'database'
        ZR_CONFIG_SetXMLfileFromDB(varargin{2},varargin{3},varargin{4});
end

% �����ݿ���õ���������,���Բ���hardcode
ZR_CONFIG_DataQuery_SetFromDB(g_XMLfile.strategyid);
% ��ȡ���ݿ����ݲ���
ZR_CONFIG_G_ExtractHistoryDataFromMySQL();

end