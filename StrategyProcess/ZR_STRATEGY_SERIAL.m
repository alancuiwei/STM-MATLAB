function ZR_STRATEGY_SERIAL(varargin)
% 连续合约的处理

% 用到的全局变量
global g_commoditynames;
global g_rawdata;
global g_coredata;
global g_traderecord;
global g_commodityparams;
global g_rightid;
global g_orders;
global g_XMLfile;
global g_temprecord;

% 设置策略参数
if nargin>0
    ZR_FUN_SetStrategyParams(varargin{:});
end

% 如果没有合约名集的信息，则用G_RunSpecialTestCase中的合约名集
if isempty(g_commoditynames)
    error('品种名列表没有初始化');
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
    l_inputdata=g_rawdata;
%     l_inputdata.strategyparams=g_commodityparams;
    % 调入第三方函数
   
    % 为每一个品种初始化dailyinfo信息
    l_inputdata.commodity.dailyinfo.date=l_inputdata.commodity.serialmkdata.date;
    l_inputdata.commodity.dailyinfo.trend=zeros(numel(l_inputdata.commodity.serialmkdata.date),1);
    if numel(g_XMLfile)>1
        % 执行策略组合
        for l_xmlid=1:numel(g_XMLfile)
            try
                if  numel(g_commodityparams) > 1
                    l_inputdata.strategyparams=g_commodityparams{l_xmlid};
                else
                    l_inputdata.strategyparams=g_commodityparams;                
                end
                eval(strcat('l_output_strategy=ZR_STRATEGY_',g_XMLfile{l_xmlid}.strategyid,'(l_inputdata);'));
                if isempty(l_output_strategy.record.opdate)
                    sprintf('组合策略中策略:%s对于品种:%s没有策略输出信息',g_XMLfile{l_xmlid}.strategyid,g_commoditynames{l_cmid})
                    break;
                end
                % 测试第一个策略算法处理报告
                g_temprecord=cat(2,g_temprecord,l_output_strategy);
                l_inputdata.commodity.dailyinfo=l_output_strategy.dailyinfo;
            catch
                l_output_strategy.orderlist.price=[];
                l_output_strategy.orderlist.direction=[];
                l_output_strategy.orderlist.name={};   
                l_output_strategy.record.opdate={};
                l_output_strategy.record.opdateprice=[];
                l_output_strategy.record.cpdate={};
                l_output_strategy.record.cpdateprice=[];
                l_output_strategy.record.isclosepos=[];
                l_output_strategy.record.direction=[];
                l_output_strategy.record.ctname={};

                l_output_strategy.dailyinfo.date={};
                l_output_strategy.dailyinfo.trend=[];                
            end
        end
    else
        % 执行单个策略
        try
            l_inputdata.strategyparams=g_commodityparams;
            eval(strcat('l_output_strategy=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
            if isempty(l_output_strategy.record.opdate)
                sprintf('策略:%s对于品种%s没有策略输出信息',g_rawdata.rightid{1}(1:6),g_commoditynames{l_cmid})
            end
        catch
            l_output_strategy.orderlist.price=[];
            l_output_strategy.orderlist.direction=[];
            l_output_strategy.orderlist.name={};   
            l_output_strategy.record.opdate={};
            l_output_strategy.record.opdateprice=[];
            l_output_strategy.record.cpdate={};
            l_output_strategy.record.cpdateprice=[];
            l_output_strategy.record.isclosepos=[];
            l_output_strategy.record.direction=[];
            l_output_strategy.record.ctname={};

            l_output_strategy.dailyinfo.date={};
            l_output_strategy.dailyinfo.trend=[];
        end
    end
    
    % 执行移仓操作
    l_output_move=ZR_PROCESS_ShiftPositionPerSerial();
    % 融合策略与移仓的交易记录
    l_output=ZR_PROCESS_MergeStrategyAndShiftPos(l_output_strategy,l_output_move);

    g_traderecord=l_output.record;
    g_orders=l_output.orderlist;
    ZR_PROCESS_VerifyRecord();
    ZR_PROCESS_TradeDataPerSerialContract();
    ZR_PROCESS_OrderDataPerSerialContract();
    % 计算报告数据
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
    ZR_PROCESS_OrderlistReportPerCommodity(l_cmid);
%     % 保存交易的图表
%     ZR_FUN_SaveTradeBarPerCommodity('contract');
end
% 报告汇总
ZR_PROCESS_CollectReport();