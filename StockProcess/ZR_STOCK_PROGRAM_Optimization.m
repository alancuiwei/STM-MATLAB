function ZR_STOCK_PROGRAM_Optimization(varargin)
% 独立的可执行文件，数据源来自'DATABASE_History.mat'
% 输入：策略参数（可选），策略配置文件（可选）
% 输出：优化报告
% 如果设置策略参数，则如下：
% |￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
% |  varargin{1}  |   varargin{2}         |       varargin{3}         |  varargin{4} |
% ------------------------------------------------------------------------
% |     'all'     |  
% |     'xml'     |  'g_XMLfileXXXX.xml'  |   
% |     'xml'     |  'g_XMLfileXXXX.xml'  |       'new'               |
% |     'xml'     |  'g_XMLfileXXXX.xml'  |   'g_DBconfigXXXX.xml'    |
% |   'database'  |   strategyid          |       userid              |   ordernum   |

% 加载搜索路径
if ~isdeployed
    addpath(strcat('./Strategies'));
end


switch varargin{1}
    case 'all'
%         ZR_STOCK_FUN_Disp('获取数据库策略配置信息!','extract DB configuration info!');
%         l_strategydata=ZR_STOCK_FUN_QueryWebstrategyConfigByDB();
%         for l_id=1:length(l_strategydata.strategyid)
%             disp(strcat('strategyid:',l_strategydata.strategyid{l_id},' userid:',num2str(l_strategydata.userid{l_id}),' ordernum:',num2str(l_strategydata.ordernum{l_id})));
%             ZR_STOCK_CONFIG_Start('database',l_strategydata.strategyid{l_id},num2str(l_strategydata.userid{l_id}),num2str(l_strategydata.ordernum{l_id}));
%             ZR_STOCK_RUN_Optimization();
%         end
%         ZR_STOCK_FUN_Disp('所有策略执行完毕!','complete strategy running!'); 
    otherwise
        ZR_STOCK_CONFIG_Start(varargin{:});
        ZR_STOCK_RUN_Optimization();
end

% 删除搜索路径
if ~isdeployed
    rmpath(strcat('./Strategies'));
end


end
