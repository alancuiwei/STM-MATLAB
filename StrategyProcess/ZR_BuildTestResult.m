function ZR_BuildTestResult(varargin)
clear global;
% 声明全局变量
global g_strategyid;
global g_path;
global g_database;
global g_matfilename;
global g_XMLfile;

global g_method;
global g_commoditynames;
global g_contractnames;
global g_pairnames;
global g_coredata;
global coredata;
global g_rightid;

global g_tradedata;
global g_report;
global g_reference;
global g_tables;
global g_figure;
global g_strategyparams;

% g_tradedata = [];
% g_report = [];
% g_reference = [];
% g_tables = [];
% g_figure = [];
% g_strategyparams = [];
% coredata = [];      % G_RunSpecialTestCase.coredata

if nargin < 0
    error('请输入策略名');
end

switch varargin{1}
    case 'xml'
        ZR_CONFIG_SetFromXML(varargin{2});
    case 'database'     
        ZR_CONFIG_SetXMLfileFromDB(varargin{2},varargin{3},varargin{4});
end

% 设置路径为当前工作路径
g_path=pwd;

% 使用的策略名
g_strategyid=varargin{2};
g_matfilename = 'DATABASE_History.mat';

addpath(strcat(pwd,'/','data'));
if exist(strcat(g_path,'/data/',g_matfilename),'file')
    % 导入数据库数据
    load(strcat(g_path,'/data/',g_matfilename));     %从mat文件导入g_database变量中
else
%     g_database=[];
    error('程序依赖于DATABASE_History.mat文件');
end

% 配置运行参数
ZR_CONFIG_RunSpecialTestCase();
% 配置生成报告参数
ZR_CONFIG_ShowTestResults();

% 策略使用的合约名称
g_contractnames=g_database.contractnames;

% 对数据进行处理
g_method.rundataprocess();   

% 运行策略
% 添加搜索路径
addpath(strcat(pwd,'/strategies/'));
for l_methodid=1:length(g_method.runstrategy)
    g_method.runstrategy(l_methodid).fun(varargin{:});
    ZR_PROCESS_MergeReportset();
end

% 计算总体测评指标
ZR_PROCESS_ComputeReferenceInwindow(coredata.startdate,coredata.enddate);

ZR_PROCESS_ShowReport();

% 删除搜索路径
rmpath(strcat(pwd,'/strategies/'));
% 提示结束
disp('测试结束');
