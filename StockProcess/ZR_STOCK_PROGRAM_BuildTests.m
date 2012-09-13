function ZR_STOCK_PROGRAM_BuildTests(varargin)
% 独立的可执行文件，数据源来自'DATABASE_History.mat'
% 输入：策略参数（可选），策略配置文件（可选）
% 输出：测试报告
%
% 如果没有策略参数，则根据数据库中数据表的配置信息执行所有的策略
% 如果设置策略参数，则如下：
% |￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
% |  varargin{1}  |   varargin{2}         |       varargin{3}         |  varargin{4} |
% ------------------------------------------------------------------------
% |     'all'     |  
% |     'xml'     |  'g_XMLfileXXXX.xml'  |   
% |     'xml'     |  'g_XMLfileXXXX.xml'  |       'new'               |
% |     'xml'     |  'g_XMLfileXXXX.xml'  |   'g_DBconfigXXXX.xml'    |
% |     'xml'     |  'g_XMLfileXXXX1.xml' |   'g_XMLfileXXXX2.xml'    |
% |   'database'  |   strategyid          |       userid              |   ordernum   |

% 加载搜索路径
if ~isdeployed
    addpath(strcat('./Strategies'));
end

ZR_STOCK_CONFIG_Start(varargin{:});
ZR_STOCK_RUN_SpecialTestCase();

% 删除搜索路径
if ~isdeployed
    rmpath(strcat('./Strategies'));
end
