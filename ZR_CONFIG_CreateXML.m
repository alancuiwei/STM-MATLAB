function ZR_CONFIG_CreateXML()
% ��������в��������б���
% clc;
% clear all;
global G_Start;
global G_ExtractHistoryDataFromMySQL;
global G_RunSpecialTestCase;
global G_ShowTestResults;
global G_RunOptimization;
global G_ConfigFile;
G_Start=[];
G_ExtractHistoryDataFromMySQL=[];
G_RunSpecialTestCase=[];
G_ShowTestResults=[];
G_RunOptimization=[];

% ���ó������в���
ZR_CONFIG_G_Start();
% ��ȡ���ݿ����ݲ���
ZR_CONFIG_G_ExtractHistoryDataFromMySQL();
% ����ֻ����һ��caseʱ��Ĳ���
ZR_CONFIG_G_RunSpecialTestCase();
% ��¼���Խ��չʾ����
ZR_CONFIG_G_ShowTestResults();
% ��¼�Ż����̲���
ZR_CONFIG_G_RunOptimization();

G_ConfigFile.G_Start=G_Start;
G_ConfigFile.G_ExtractHistoryDataFromMySQL=G_ExtractHistoryDataFromMySQL;
G_ConfigFile.G_RunSpecialTestCase=G_RunSpecialTestCase;
G_ConfigFile.G_ShowTestResults=G_ShowTestResults;
G_ConfigFile.G_RunOptimization=G_RunOptimization;
% xml_write('G_ConfigFile.xml',G_ConfigFile);
end