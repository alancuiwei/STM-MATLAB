function ZR_STRATEGY_SINGLE(varargin)
% 羽根英树的策略:010601

% 用到的全局变量
global g_commoditynames;
global g_rawdata;
global g_coredata;
global g_traderecord;
global g_commodityparams;
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
    % 根据每一个品种设置策略参数
    ZR_FUN_SetParamsPerCommodity(l_cmid);
    % 得到同品种合约的数量
    l_pairnum=length(g_rawdata.contract);
    % 遍历同品种所有套利对
    l_inputdata.commodity=g_rawdata.commodity;
    l_inputdata.strategyparms=g_commodityparams;
    for l_pairid=1:l_pairnum
        % 单个套利对的数据
        l_inputdata.contract=g_rawdata.contract(l_pairid);
        % 计算合约的指标
        l_output=hyperbola(l_inputdata);
        g_traderecord=l_output.record;
        % g_traderecord=l_output;
        % 计算交易记录
        ZR_PROCESS_TradeDataPerContract(l_pairid);
        % 计算交易记录，交易记录可能来自第三方     
    end
    % 计算报告数据
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
    % 保存交易的图表
    ZR_FUN_SaveTradeBarPerCommodity('contract');
end
% 报告汇总
ZR_PROCESS_CollectReport();














