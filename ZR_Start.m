%%
clc;
clear all;
% ZR_PROGRAM_BuiltTestResult();
% ZR_PROGRAM_BuiltTestResult('C:\Users\WUKang\Documents\MATLAB\Test\tester1\010603\g_XMLfile010603.xml');
ZR_PROGRAM_BuiltTestResult('D:\Users\Administrator\Documents\MATLAB\ZR_LIB_0220\ZR_LIB\g_XMLfile100000.xml');
% function ZR_Start(in_xmlfile)
% % %%


% clc;
% clear all;
% ZR_CONFIG_File(in_xmlfile);
% % �����ݿ��е�������
% ZR_ExtractHistoryDataFromMySQL();
% % �ض��������������ģʽ
% ZR_RunSpecialTestCase();
% 
%%
clc;
clear all;
ZR_CONFIG_File('D:\Users\Administrator\Documents\MATLAB\ZR_LIB_0220\ZR_LIB\g_XMLfile010603.xml');
% �����ݿ��е�������
ZR_ExtractHistoryDataFromMySQL();
% �Ż�����
ZR_RunOptimization();
% % 
% % %%
% % ZR_PROCESS_ComputeReferenceInwindow('2009-01-01','2009-12-31');
% % ZR_PROCESS_ShowReport();
% end