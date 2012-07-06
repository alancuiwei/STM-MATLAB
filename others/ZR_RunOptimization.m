function ZR_RunOptimization(varargin)
% 运行优化过程

% 声明全局变量
global G_ShowTestResults;
global G_Start;
global g_contractnames;
global g_commoditynames;
global g_pairnames;
global g_method;
global g_coredata;
global g_tables;
global g_figure;
global G_RunOptimization;
global g_optimization;
global g_reportformat;
% 设置运行模式
G_Start.runmode='RunOptimization';
% 策略使用的合约名称
g_commoditynames=G_RunOptimization.g_commoditynames;
g_pairnames=G_RunOptimization.g_pairnames;
g_contractnames=G_RunOptimization.g_contractnames;
g_tables=G_ShowTestResults.g_tables;
g_figure=G_ShowTestResults.g_figure;
g_optimization=G_RunOptimization.g_optimization;
% 使用的方法
g_reportformat=G_RunOptimization.g_report;
g_method=G_RunOptimization.g_method;
% 中间数据处理，生成g_coredata
if isempty(g_coredata)
    if ~exist('g_coredata_optimization.mat', 'file')||(G_RunOptimization.coredata.needupdate)
        g_method.rundataprocess();
        save('g_coredata_optimization.mat','g_coredata');
    else
        load('g_coredata_optimization.mat');
    end
end
g_method.runopimization(varargin{:});
disp('优化测试结束');
end