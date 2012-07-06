function ZR_PROGRAM_BuildTestsFromDB(varargin)
% 独立的可执行文件，数据源来自'DATABASE_History.mat'
% 输入：策略参数（可选），策略配置文件（可选）
% 输出：测试报告
%
% 如果没有策略参数，则根据数据库中数据表的配置信息执行所有的策略
% 如果设置策略参数，则如下：
% ________________________________________________________________________
% |              |     'xml'     |  'g_XMLfile_XXXX.xml'  |              |
% |  strategyid  ---------------------------------------------------------
% |              |   'database'  |         userid         |   ordernum   |
% |￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
% |  varargin{1} |  varargin{2}  |       varargin{3}      |  varargin{4} |
% ------------------------------------------------------------------------
clc;
if nargin < 1
    disp('获取数据库策略配置信息');
    l_strategydata=ZR_FUN_QueryWebstrategyConfigByDB();
    for l_id=1:length(l_strategydata.strategyid)
        disp(strcat('strategyid:',l_strategydata.strategyid{l_id},' userid:',num2str(l_strategydata.userid{l_id}),' ordernum:',num2str(l_strategydata.ordernum{l_id})));
        ZR_BuildTestResult(l_strategydata.strategyid{l_id},'database',num2str(l_strategydata.userid{l_id}),num2str(l_strategydata.ordernum{l_id}));
    end
    disp('策略执行完毕');
else
    ZR_BuildTestResult(varargin{:});
end