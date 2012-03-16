function ZR_RunSpecialTestCase(varargin)
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
global g_coredata;
global g_tradedataformat;
global g_report;
global g_reference;
global g_tables;
global g_figure;
global g_XMLfile;
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
% 使用的方法
g_method=G_RunSpecialTestCase.g_method;
% 中间数据处理，生成g_coredata
% if isempty(g_coredata)
%     if ~exist('g_coredata_specialtestcase.mat', 'file')||(G_RunSpecialTestCase.coredata.needupdate)
%         g_method.rundataprocess();
%         save('g_coredata_specialtestcase.mat','g_coredata');
%     else
%         load('g_coredata_specialtestcase.mat');
%     end
% end

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

ZR_PROCESS_ShowReport();
% 提示结束
disp('测试结束');
