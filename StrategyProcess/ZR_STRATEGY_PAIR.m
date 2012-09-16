function ZR_STRATEGY_PAIR(varargin)
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
if nargin>0
    ZR_FUN_SetStrategyParams(varargin{:});
end

% 如果没有合约名集的信息，则用G_RunSpecialTestCase中的合约名集
if isempty(g_commoditynames)
    error('合约名列表没有初始化');
end
%%%% 算法过程
if iscell(g_commoditynames)
    l_cmnum=length(g_commoditynames);
else
    l_cmnum=1;
end
% 根据一组参数计算一轮
for l_cmid=1:l_cmnum         
    % 每一个品种初始化
    ZR_FUN_InitGlobalVarsPerCommodity();
    g_rawdata=g_coredata(l_cmid);
    g_rawdata.rightid=g_rightid(l_cmid);
    % 根据每一个品种设置策略参数
    ZR_FUN_SetParamsPerCommodity(l_cmid);
    % 得到同品种合约的数量
    l_pairnum=length(g_rawdata.pair);
    % 遍历同品种所有套利对
    l_inputdata.commodity=g_rawdata.commodity;
    l_inputdata.strategyparms=g_commodityparams;
    for l_pairid=1:l_pairnum
        % 单个套利对的数据
        l_inputdata.pair=g_rawdata.pair(l_pairid);
        % 计算合约的指标
        l_output=[];
        try
            eval(strcat('l_output=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
        catch
            l_output.orderlist.price=[];
            l_output.orderlist.direction=[];
            l_output.orderlist.name={};   
            l_output.record.opdate={};
            l_output.record.opdateprice=[];
            l_output.record.cpdate={};
            l_output.record.cpdateprice=[];
            l_output.record.isclosepos=[];
            l_output.record.direction=[];
            l_output.record.ctname={};

            l_output.dailyinfo.date={};
            l_output.dailyinfo.trend=[];            
        end
        g_orderlist=l_output.orderlist;
        g_traderecord=l_output.record;
%         switch g_strategyid
%             case '010603'
%                 g_traderecord=ZR_STRATEGY_010603(l_inputdata);
%         end
        % 计算交易记录
        ZR_PROCESS_TradeDataPerPair(l_pairid);
        ZR_PROCESS_OrderDataPerPair(l_pairid);
        % 计算交易记录，交易记录可能来自第三方     
    end
    % 计算报告数据
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
    ZR_PROCESS_OrderlistReportPerCommodity(l_cmid);
    % 保存交易的图表
    ZR_FUN_SaveTradeBarPerCommodity('pair');
end
% 报告汇总
ZR_PROCESS_CollectReport();