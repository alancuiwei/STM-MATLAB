function ZR_STRATEGY_SERIAL(varargin)
% 羽根英树的策略:010601

% 用到的全局变量
global g_commoditynames;
global g_rawdata;
global g_coredata;
global g_traderecord;
global g_commodityparams;
global g_rightid;

% 设置策略参数
ZR_FUN_SetStrategyParams(varargin{:});

% 如果没有合约名集的信息，则用G_RunSpecialTestCase中的合约名集
if isempty(g_commoditynames)
    error('品种名列表没有初始化');
end
%%%% 算法过程
l_cmnum=length(g_commoditynames);
% 根据一组参数计算一轮
for l_cmid=1:l_cmnum         
    % 每一个品种初始化
    ZR_FUN_InitGlobalVarsPerCommodity();
    g_rawdata=g_coredata(l_cmid);
    g_rawdata.rightid=g_rightid(l_cmid);
    % 根据每一个品种设置策略参数
    ZR_FUN_SetParamsPerCommodity(l_cmid);
    l_inputdata=g_rawdata;
    l_inputdata.strategyparams=g_commodityparams;
    % 调入第三方函数
%     eval(strcat('l_output=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
    eval(strcat('[l_stoutput,TradeDay]=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
    l_output=ZR_FUN_MoveToStoreHouse(l_inputdata,l_stoutput,TradeDay);
%     switch g_strategyid
%         case '040704'
%             l_output=ZR_STRATEGY_040704(l_inputdata);
%         case '040705'
%             l_output=ZR_STRATEGY_040705(l_inputdata);
%         case '040706'
%             l_output=ZR_STRATEGY_040706(l_inputdata);
%     end
    g_traderecord=l_output.record;    
    ZR_PROCESS_TradeDataPerSerialContract();
    % 计算报告数据
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
%     % 保存交易的图表
%     ZR_FUN_SaveTradeBarPerCommodity('contract');
end
% 报告汇总
ZR_PROCESS_CollectReport();