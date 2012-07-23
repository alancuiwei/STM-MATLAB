function ZR_STRATEGY_SERIAL(varargin)
% 羽根英树的策略:010601

% 用到的全局变量
global g_commoditynames;
global g_rawdata;
global g_coredata;
global g_traderecord;
global g_commodityparams;
global g_rightid;
global g_orderlist;

% 设置策略参数
% ZR_FUN_SetStrategyParams(varargin{:});

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
%     eval(strcat('[l_stoutput,TradeDay]=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
%     l_output=ZR_FUN_MoveToStoreHouse(l_inputdata,l_stoutput,TradeDay);

%     eval(strcat('l_output=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));

%     l_output=ZR_STRATEGY_COMBINE('040709','040705',l_inputdata);
%     prerecord=ZR_STRATEGY_SERIAL_PROCESS('040709','040706',l_inputdata);
%     l_output=ZR_FUN_MoveToStoreHousePerSerial(l_inputdata,prerecord);
%   
    %执行策略函数
    eval(strcat('l_output_strategy=ZR_STRATEGY_S',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
    %执行移仓操作
    l_output_move=ZR_PROCESS_ShiftPositionPerSerial();
    %融合策略与移仓的交易记录
    l_output=ZR_PROCESS_MergeStrategyAndShiftPos(l_output_strategy,l_output_move);
 
    g_traderecord=l_output.record;    
    g_orderlist=l_output.orderlist;
    ZR_PROCESS_TradeDataPerSerialContract();
    % 计算报告数据
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
    ZR_PROCESS_OrderlistReportPerCommodity(l_cmid);
%     % 保存交易的图表
%     ZR_FUN_SaveTradeBarPerCommodity('contract');
end
% 报告汇总
ZR_PROCESS_CollectReport();