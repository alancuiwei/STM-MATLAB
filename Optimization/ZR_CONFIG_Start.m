function ZR_CONFIG_Start(varargin)
% ��������в��������б���
% clear global;
% global G_Start;
% global G_ExtractHistoryDataFromMySQL;
% global G_RunSpecialTestCase;
% global G_ShowTestResults;
% global G_RunOptimization;
% % global G_ConfigFile;
% global g_XMLfile;
% G_Start=[];
% G_ExtractHistoryDataFromMySQL=[];
% G_RunSpecialTestCase=[];
% G_ShowTestResults=[];
% G_RunOptimization=[];

% ����mat����
if exist('./Data/DATABASE_History.mat','file')
    % �������ݿ�����
    load(strcat('./Data/DATABASE_History.mat'));     %��mat�ļ�����g_database������
else
    ZR_FUN_Disp('����������DATABASE_History.mat�ļ�!','need DATABASE_History.mat!');
    error('stopped!');
end

switch varargin{1}
    case 'xml'
        ZR_CONFIG_SetXMLFromFile(varargin{2});    
    case 'database'
        ZR_CONFIG_SetXMLFromDB(varargin{2},varargin{3},varargin{4});
    otherwise
        ZR_FUN_Disp('�������벻��!','wrong argument!');        
        error('stopped!');
end
% ���ó������в���
ZR_CONFIG_G_Start();
% �����ݿ���õ���������,���Բ���hardcode
ZR_CONFIG_SetFromDB(varargin{:});
% ��ȡ���ݿ����ݲ���
ZR_CONFIG_G_ExtractHistoryDataFromMySQL();
% ����ֻ����һ��caseʱ��Ĳ���
ZR_CONFIG_G_RunSpecialTestCase();
% ��¼���Խ��չʾ����
ZR_CONFIG_G_ShowTestResults();
% ��¼�Ż����̲���
ZR_CONFIG_G_RunOptimization();

% G_ConfigFile.G_Start=G_Start;
% G_ConfigFile.G_ExtractHistoryDataFromMySQL=G_ExtractHistoryDataFromMySQL;
% G_ConfigFile.G_RunSpecialTestCase=G_RunSpecialTestCase;
% G_ConfigFile.G_ShowTestResults=G_ShowTestResults;
% G_ConfigFile.G_RunOptimization=G_RunOptimization;
% xml_write('G_ConfigFile.xml',G_ConfigFile);
end