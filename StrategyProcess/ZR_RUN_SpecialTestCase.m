function ZR_RUN_SpecialTestCase(varargin)
% ִֻ��һ������case

% ����ȫ�ֱ���
global G_RunSpecialTestCase;
global G_ShowTestResults;
global G_Start;
global g_commoditynames;
global g_contractnames;
global g_pairnames;
global g_method;
global g_strategyparams;
global g_tradedataformat;
global g_report;
global g_reference;
global g_tables;
global g_figure;
global g_rightid;
global g_DBconfig;
% ��������ģʽ
G_Start.runmode='RunSpecialTestCase';
% ����ʹ�õĺ�Լ����
g_tradedataformat=G_RunSpecialTestCase.g_tradedata;
g_report=G_RunSpecialTestCase.g_report;
g_reference=G_RunSpecialTestCase.g_reference;
g_commoditynames=G_RunSpecialTestCase.g_commoditynames;
g_pairnames=G_RunSpecialTestCase.g_pairnames;
g_contractnames=G_RunSpecialTestCase.g_contractnames;
g_tables=G_ShowTestResults.g_tables;
g_figure=G_ShowTestResults.g_figure;
g_rightid=g_DBconfig.g_rightid;
% ʹ�õķ���
g_method=G_RunSpecialTestCase.g_method;

g_method.rundataprocess();
% ���Բ���
for l_methodid=1:length(g_method.runstrategy)
    g_report=G_RunSpecialTestCase.g_report;
    g_strategyparams=G_RunSpecialTestCase.g_strategyparams(l_methodid);
    g_method.runstrategy(l_methodid).fun(varargin{:});
    ZR_PROCESS_MergeReportset();
end

% �����������ָ��
ZR_PROCESS_ComputeReferenceInwindow(G_RunSpecialTestCase.coredata.startdate,G_RunSpecialTestCase.coredata.enddate);
% ������Ա���
ZR_PROCESS_ShowReport();
% ��ʾ����
ZR_FUN_Disp('���Խ���!','Test case Finished!');
