function ZR_RUN_SpecialTestCase(varargin)
% 只执行一个测试case

% 声明全局变量
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
% 设置运行模式
G_Start.runmode='RunSpecialTestCase';
% 策略使用的合约名称
g_tradedataformat=G_RunSpecialTestCase.g_tradedata;
g_report=G_RunSpecialTestCase.g_report;
g_reference=G_RunSpecialTestCase.g_reference;
g_commoditynames=G_RunSpecialTestCase.g_commoditynames;
g_pairnames=G_RunSpecialTestCase.g_pairnames;
g_contractnames=G_RunSpecialTestCase.g_contractnames;
g_tables=G_ShowTestResults.g_tables;
g_figure=G_ShowTestResults.g_figure;
g_rightid=g_DBconfig.g_rightid;
% 使用的方法
g_method=G_RunSpecialTestCase.g_method;

g_method.rundataprocess();
% 策略参数
for l_methodid=1:length(g_method.runstrategy)
    g_report=G_RunSpecialTestCase.g_report;
    g_strategyparams=G_RunSpecialTestCase.g_strategyparams(l_methodid);
    g_method.runstrategy(l_methodid).fun(varargin{:});
    ZR_PROCESS_MergeReportset();
end

% 计算总体测评指标
ZR_PROCESS_ComputeReferenceInwindow(G_RunSpecialTestCase.coredata.startdate,G_RunSpecialTestCase.coredata.enddate);
% 保存测试报告
ZR_PROCESS_ShowReport();
% 提示结束
ZR_FUN_Disp('测试结束!','Test case Finished!');
