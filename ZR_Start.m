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
% % 从数据库中导出数据
% ZR_ExtractHistoryDataFromMySQL();
% % 特定参数输入的运行模式
% ZR_RunSpecialTestCase();
% 
%%
clc;
clear all;
ZR_CONFIG_File('D:\Users\Administrator\Documents\MATLAB\ZR_LIB_0220\ZR_LIB\g_XMLfile010603.xml');
% 从数据库中导出数据
ZR_ExtractHistoryDataFromMySQL();
% 优化过程
ZR_RunOptimization();
% % 
% % %%
% % ZR_PROCESS_ComputeReferenceInwindow('2009-01-01','2009-12-31');
% % ZR_PROCESS_ShowReport();
% end