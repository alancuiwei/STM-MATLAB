function ZR_STRATEGY_020603_L1_S7_S10_CurrentDate(varargin)
% 羽根英树的策略:010601

% 用到的全局变量
global g_commoditynames;
global g_rawdata;
global g_coredata;
% 设置策略参数
SUB_SetStrategyParams(varargin{:});
% 如果没有合约名集的信息，则用G_RunSpecialTestCase中的合约名集
if isempty(g_commoditynames)
    error('合约名列表没有初始化');
end
%%%% 算法过程
l_cmnum=length(g_commoditynames);
% 根据一组参数计算一轮
for l_cmid=1:l_cmnum         
    % 每一个品种初始化
    SUB_InitGlobalVarsPerCommodity();
    g_rawdata=g_coredata(l_cmid);
    % 根据每一个品种设置策略参数
    ZR_FUN_SetParamsPerCommodity(l_cmid);
    % 得到同品种合约的数量
    l_pairnum=length(g_rawdata.pair);
    % 遍历同品种所有套利对
    for l_pairid=1:l_pairnum
        % 计算合约的指标
        SUB_ComputeIndicatorPerPair(l_pairid);
        % 计算策略的数据
        SUB_ComputeStrategyDataPerPair(l_pairid);
        % 交易演算
        SUB_ComputeTradeDataPerPair(l_pairid);
    end
    % 计算报告数据
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
    % 保存交易的图表
    ZR_FUN_SaveTradeBarPerCommodity();
end
% 报告汇总
ZR_PROCESS_CollectReport();

function SUB_SetStrategyParams(varargin)
%%%%%%%% 设置策略参数
global g_strategyparams;
global g_commoditynames;
% 参数赋值，优化执行时才会传入参数
if(nargin>0)
    % 默认是每种商品下单一手
    g_strategyparams.handnum=ones(1,length(g_commoditynames)); 
    l_commandstr='';
    for l_paramid=1:(nargin/2)   
        l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_commoditynames)); ');
    end
    eval(l_commandstr);
end

function SUB_InitGlobalVarsPerCommodity()
%%%%%%%% 每一个品种初始化
global g_rawdata;
global g_indicatordata
global g_strategydata;
global g_tradedata;
global g_tradedataformat;
g_rawdata=[];
g_indicatordata=[];
g_strategydata=[];
g_tradedata=g_tradedataformat; 

function SUB_ComputeIndicatorPerContract(in_ctid)
%%%%%%%% 计算合约的指标信息
global g_indicatordata;
g_indicatordata.contract(in_ctid)=0;

function SUB_ComputeIndicatorPerPair(in_pairid)
%%%%%%%% 计算套利对的指标信息
global g_rawdata;
global g_indicatordata;
global g_commodityparams;
% 调用参数
l_period=g_commodityparams.period;
l_periodmin=round(l_period/2)+1;
if (g_rawdata.pair(in_pairid).datalen>l_period)
    % l_periodmin=l_period;
    % 计算gap为负时的，周期内的最大值
    l_cpgapdata=g_rawdata.pair(in_pairid).mkdata.cpgap;
    l_cpgapdata(l_cpgapdata>0)=0;
    g_indicatordata.pair(in_pairid).negativemaxgap=-TA_MAX(abs(l_cpgapdata),l_period).*(l_cpgapdata<0);
    % 计算gap周期内的最大值,以及最大值时的index
    l_cpgapdata=g_rawdata.pair(in_pairid).mkdata.cpgap;
    g_indicatordata.pair(in_pairid).maxgap=TA_MAX(l_cpgapdata,l_periodmin);
    g_indicatordata.pair(in_pairid).maxgapid=TA_MAXINDEX(l_cpgapdata,l_periodmin)+1;
    % 计算周期内gap为最大值时，近期和远期的价格
    g_indicatordata.pair(in_pairid).gapmaxprice(:,1)=g_rawdata.pair(in_pairid).mkdata.cp(g_indicatordata.pair(in_pairid).maxgapid,1);
    g_indicatordata.pair(in_pairid).gapmaxprice(:,2)=g_rawdata.pair(in_pairid).mkdata.cp(g_indicatordata.pair(in_pairid).maxgapid,2);
    % 计算周期内gap的均值
    l_cpATR=TA_ATR(TA_MAX(abs(g_rawdata.pair(in_pairid).mkdata.cpgap),l_period),...
        TA_MIN(abs(g_rawdata.pair(in_pairid).mkdata.cpgap),l_period),...
        abs(g_rawdata.pair(in_pairid).mkdata.cpgap),...
        l_period);
    l_opATR=TA_ATR(TA_MAX(abs(g_rawdata.pair(in_pairid).mkdata.opgap),l_period),...
        TA_MIN(abs(g_rawdata.pair(in_pairid).mkdata.opgap),l_period),...
        abs(g_rawdata.pair(in_pairid).mkdata.opgap),...
        l_period);
    % max([l_cpATR,l_opATR],[],2)
    g_indicatordata.pair(in_pairid).ATR=min(g_rawdata.commodity.info.tick)*ones(g_rawdata.pair(in_pairid).datalen,1);
    % g_indicatordata.pair(in_pairid).ATR=max([l_cpATR,l_opATR],[],2)/g_rawdata.commodity.info.tick/100;
    g_indicatordata.pair(in_pairid).serial=(TA_MA(double(g_rawdata.pair(in_pairid).mkdata.cpgap<0),l_period)>=1);
    g_indicatordata.pair(in_pairid).isallowed=(min(g_rawdata.pair(in_pairid).mkdata.vl,[],2)>=100);
else
    % l_periodmin=l_period;
    % 计算gap为负时的，周期内的最大值
    l_cpgapdata=g_rawdata.pair(in_pairid).mkdata.cpgap;
    l_cpgapdata(l_cpgapdata>0)=0;
    g_indicatordata.pair(in_pairid).negativemaxgap=zeros(size(l_cpgapdata));
    % 计算gap周期内的最大值,以及最大值时的index
    l_cpgapdata=g_rawdata.pair(in_pairid).mkdata.cpgap;
    g_indicatordata.pair(in_pairid).maxgap=zeros(size(l_cpgapdata));
    g_indicatordata.pair(in_pairid).maxgapid=ones(size(l_cpgapdata));
    % 计算周期内gap为最大值时，近期和远期的价格
    g_indicatordata.pair(in_pairid).gapmaxprice(:,1)=g_rawdata.pair(in_pairid).mkdata.cp(g_indicatordata.pair(in_pairid).maxgapid,1);
    g_indicatordata.pair(in_pairid).gapmaxprice(:,2)=g_rawdata.pair(in_pairid).mkdata.cp(g_indicatordata.pair(in_pairid).maxgapid,2);
    % 计算周期内gap的均值
%     l_cpATR=TA_ATR(TA_MAX(abs(g_rawdata.pair(in_pairid).mkdata.cpgap),l_period),...
%         TA_MIN(abs(g_rawdata.pair(in_pairid).mkdata.cpgap),l_period),...
%         abs(g_rawdata.pair(in_pairid).mkdata.cpgap),...
%         l_period);
%     l_opATR=TA_ATR(TA_MAX(abs(g_rawdata.pair(in_pairid).mkdata.opgap),l_period),...
%         TA_MIN(abs(g_rawdata.pair(in_pairid).mkdata.opgap),l_period),...
%         abs(g_rawdata.pair(in_pairid).mkdata.opgap),...
%         l_period);
    % max([l_cpATR,l_opATR],[],2)
    g_indicatordata.pair(in_pairid).ATR=min(g_rawdata.commodity.info.tick)*ones(g_rawdata.pair(in_pairid).datalen,1);
    % g_indicatordata.pair(in_pairid).ATR=max([l_cpATR,l_opATR],[],2)/g_rawdata.commodity.info.tick/100;
    g_indicatordata.pair(in_pairid).serial=zeros(size(l_cpgapdata));
    g_indicatordata.pair(in_pairid).isallowed=zeros(size(l_cpgapdata));
end

function SUB_ComputeStrategyDataPerPair(in_pairid)
%%%%%%%% 计算套策略相关数据
global g_indicatordata;
global g_rawdata;
global g_strategydata;
% global g_commodityparams;
% 记录及远期价格比较，gap最大最小值的点
g_strategydata(in_pairid).isnegativemaxgappoint=(g_indicatordata.pair(in_pairid).negativemaxgap==g_rawdata.pair(in_pairid).mkdata.cpgap);
g_strategydata(in_pairid).isn2rpricehigher=(g_rawdata.pair(in_pairid).mkdata.cpgap>0);
% 近期合约的涨幅，远期合约涨幅，近远期涨幅的比较，每一个策略类型计算方法不尽相同
%  序号	近期价格>远期价格	近期价格是否上涨	远期价格是否上涨	近格期价变化幅度>远期价格变化幅度	类型
%   1  |	      否       |	       否      |	       否       |	              否              |	 2
%   2  |	      否       |	       否      |	       否       |	              是              |	 1a
%   3  |	      否       |	       否      |	       是       |	              否              |	 1b
%   4  |	      否       |	       否      |	       是       |	              是              |	 1b
%   5  |	      否       |	       是      |	       否       |	              否              |	 2
%   6  |	      否       |	       是      |	       否       |	              是              |	 2
%   7  |	      否       |	       是      |	       是       |	              否              |	 1b
%   8  |	      否       |	       是      |	       是       |	              是              |	 2
%   9  |	      是       |	       否      |	       否       |	              否              |	 4
%   10 |	      是       |	       否      |	       否       |	              是              |	 3
%   11 |	      是       |	       否      |	       是       |	              否              |	 3
%   12 |	      是       |	       否      |	       是       |	              是              |	 3
%   13 |	      是       |	       是      |	       否       |	              否              |	 4
%   14 |	      是       |	       是      |	       否       |	              是              |	 4
%   15 |	      是       |	       是      |	       是       |	              否              |	 3
%   16 |	      是       |	       是      |	       是       |	              是              |	 4
% 计算1a情况的策略数据,波峰的形成是由于远期合约下跌幅度比近期小的情况
g_strategydata(in_pairid).case1a.pricechange(:,1)=g_rawdata.pair(in_pairid).mkdata.cp(:,1)-g_indicatordata.pair(in_pairid).gapmaxprice(:,1);
g_strategydata(in_pairid).case1a.pricechange(:,2)=g_rawdata.pair(in_pairid).mkdata.cp(:,2)-g_indicatordata.pair(in_pairid).gapmaxprice(:,2);
g_strategydata(in_pairid).case1a.n2rpricechangediff=g_strategydata(in_pairid).case1a.pricechange(:,1)-g_strategydata(in_pairid).case1a.pricechange(:,2);
g_strategydata(in_pairid).case1a.isnearpriceup=(g_strategydata(in_pairid).case1a.pricechange(:,1)>0);
g_strategydata(in_pairid).case1a.isremotepriceup=(g_strategydata(in_pairid).case1a.pricechange(:,2)>0);
g_strategydata(in_pairid).case1a.isn2rchangebigger=(abs(g_strategydata(in_pairid).case1a.pricechange(:,1))>=abs(g_strategydata(in_pairid).case1a.pricechange(:,2)));
g_strategydata(in_pairid).case1a.ismatched=(g_strategydata(in_pairid).isnegativemaxgappoint)&(g_rawdata.pair(in_pairid).mkdata.cpgap<0)...
    &(~g_strategydata(in_pairid).case1a.isnearpriceup)...
    &(~g_strategydata(in_pairid).case1a.isremotepriceup)...
    &(g_strategydata(in_pairid).case1a.isn2rchangebigger)...
    &g_indicatordata.pair(in_pairid).isallowed;    
% 计算1b情况的策略数据,波峰的形成是由于远期合约上涨幅度比近期大的情况
g_strategydata(in_pairid).case1b.pricechange(:,1)=g_rawdata.pair(in_pairid).mkdata.cp(:,1)-g_indicatordata.pair(in_pairid).gapmaxprice(:,1);
g_strategydata(in_pairid).case1b.pricechange(:,2)=g_rawdata.pair(in_pairid).mkdata.cp(:,2)-g_indicatordata.pair(in_pairid).gapmaxprice(:,2);
g_strategydata(in_pairid).case1b.n2rpricechangediff=g_strategydata(in_pairid).case1b.pricechange(:,1)-g_strategydata(in_pairid).case1b.pricechange(:,2);
g_strategydata(in_pairid).case1b.isnearpriceup=(g_strategydata(in_pairid).case1b.pricechange(:,1)>0);
g_strategydata(in_pairid).case1b.isremotepriceup=(g_strategydata(in_pairid).case1b.pricechange(:,2)>0);
g_strategydata(in_pairid).case1b.isn2rchangebigger=(abs(g_strategydata(in_pairid).case1b.pricechange(:,1))>abs(g_strategydata(in_pairid).case1b.pricechange(:,2)));
g_strategydata(in_pairid).case1b.ismatched=(g_strategydata(in_pairid).isnegativemaxgappoint)&(g_rawdata.pair(in_pairid).mkdata.cpgap<0)...
    &(g_strategydata(in_pairid).case1b.isremotepriceup)...
    &((~g_strategydata(in_pairid).case1b.isnearpriceup)|((g_strategydata(in_pairid).case1b.isremotepriceup)&(~g_strategydata(in_pairid).case1b.isn2rchangebigger)))...
    &g_indicatordata.pair(in_pairid).isallowed; 
g_strategydata(in_pairid).type=11*g_strategydata(in_pairid).case1a.ismatched+12*g_strategydata(in_pairid).case1b.ismatched;
g_strategydata(in_pairid).case1a.ismatched=(g_strategydata(in_pairid).case1a.ismatched|g_strategydata(in_pairid).case1b.ismatched);



function SUB_ComputeTradeDataPerPair(in_pairid)
%%%%%%%% 计算交易数据
global g_rawdata;
global g_tradedata;
global g_commodityparams;
global g_strategydata;
% 调用参数
l_handnum=g_commodityparams.handnum;
g_tradedata(in_pairid).caculationnum=1;
% 交易单位
l_tradeunit(1)=g_rawdata.commodity.info(1).tradeunit*l_handnum;
l_tradeunit(2)=g_rawdata.commodity.info(2).tradeunit*l_handnum;
% % 是否单边收取保证金
% if(g_rawdata.commodity.info.issinglemargin)
%     l_tradenum=1;
% else
%     l_tradenum=2;
% end
% 保证金比例
l_margin(1)=g_rawdata.commodity.info(1).margin;
l_margin(2)=g_rawdata.commodity.info(2).margin;
% 交易手续费
l_tradecharge(1)=g_rawdata.commodity.info(1).tradecharge*l_handnum;
l_tradecharge(2)=g_rawdata.commodity.info(2).tradecharge*l_handnum;
% l_tradecharge=0;
% 执行演算过程
SUB_TradeCalculationPeriodly(in_pairid,1,11);
% SUB_TradeCalculationPeriodly(in_pairid,2,12);
% 记录交易情况
% 交割月开始日期
% 日期向量
l_lastdatevec=datevec(g_rawdata.pair(in_pairid).mkdata.date(end));
l_name=cell2mat(g_rawdata.pair(in_pairid).name);
l_halflen=ceil((length(l_name)-1)/2);
l_delivermonth=str2double(l_name(l_halflen-1:l_halflen));
l_lastdatenum=inf;
if l_delivermonth==l_lastdatevec(2)
    if l_delivermonth==1
        l_lastdatevec=[l_lastdatevec(1)-1,12,31,0,0,0];
    else
        l_lastdatevec=[l_lastdatevec(1),l_lastdatevec(2)-1,eomday(l_lastdatevec(1),l_lastdatevec(2)-1),0,0,0];
    end
    l_lastdatenum=datenum(l_lastdatevec);
end  
l_posid=0;
l_tradeid=0;
% 后续程序根据num值判断是否有开仓
g_tradedata(in_pairid).pos.num=[];
g_tradedata(in_pairid).trade.num=[];  
g_tradedata(in_pairid).pos.name=g_rawdata.pair(in_pairid).name;
g_tradedata(in_pairid).trade.name=g_rawdata.pair(in_pairid).name;
for l_caculationid=1:g_tradedata(in_pairid).caculationnum
    if(~isempty(g_tradedata(in_pairid).caculation(l_caculationid).result.trademap))
        for l_index=1:length(g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(:,1))
            % pos和trade数量自增1
            l_posid=l_posid+1;
            l_tradeid=l_tradeid+1;
            % 平仓点或停仓点
            l_cspid=find(g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(l_index,:)>=4,1);
            % pos
            % 名字
            g_tradedata(in_pairid).pos.name(l_posid)=g_rawdata.pair(in_pairid).name;
            g_tradedata(in_pairid).pos.rightid(l_posid)={g_rawdata.pair(in_pairid).rightid};
            % 策略类型
%             g_tradedata(in_pairid).pos.type(l_posid)=g_tradedata(in_pairid).caculation(l_caculationid).type; 
            g_tradedata(in_pairid).pos.type(l_posid)=g_strategydata(in_pairid).type(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1));
            % 建仓日期
            g_tradedata(in_pairid).pos.opdate(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.date(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1));
            % 建仓类型
            g_tradedata(in_pairid).pos.optype(l_posid)=1;
            % 建仓时的价差
            g_tradedata(in_pairid).pos.opdategap(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1));
            % 建仓时的近期合约交易量
            g_tradedata(in_pairid).pos.opgapvl1(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1),1);
            % 建仓时的远期合约交易量
            g_tradedata(in_pairid).pos.opgapvl2(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1),2);              
            % 平仓或停仓的日期
            g_tradedata(in_pairid).pos.cpdate(l_posid)=....
                g_rawdata.pair(in_pairid).mkdata.date(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
            % 平仓或停仓的类型
            g_tradedata(in_pairid).pos.cptype(l_posid)=g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(l_index,l_cspid);  
            % 是否实际平仓
            g_tradedata(in_pairid).pos.isclosepos(l_posid)=~(g_tradedata(in_pairid).pos.cptype(l_posid)==32);
            % 平仓或停仓的价差
            g_tradedata(in_pairid).pos.cpdategap(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
            % 平仓时的近期合约交易量
            g_tradedata(in_pairid).pos.cpgapvl1(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1);
            % 平仓时的远期合约交易量
            g_tradedata(in_pairid).pos.cpgapvl2(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2); 
            % 保证金
            g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
                *g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1)...
                +l_tradeunit(2)*l_margin(2)...
                *g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2));
            % 交易手续费
            g_tradedata(in_pairid).pos.optradecharge(l_posid)=0;
            g_tradedata(in_pairid).pos.cptradecharge(l_posid)=0;            
            for l_chargeid=1:length(l_tradecharge)
                if (l_tradecharge(l_chargeid)<1)
                    g_tradedata(in_pairid).pos.optradecharge(l_posid)=round(l_tradecharge(l_chargeid)*...
                        g_rawdata.pair(in_pairid).mkdata.op(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1),l_chargeid))...
                        +g_tradedata(in_pairid).pos.optradecharge(l_posid);
                    g_tradedata(in_pairid).pos.cptradecharge(l_posid)=round(l_tradecharge(l_chargeid)*...
                        g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),l_chargeid))...
                        +g_tradedata(in_pairid).pos.cptradecharge(l_posid);                
                else
                    g_tradedata(in_pairid).pos.optradecharge(l_posid)=l_tradecharge(l_chargeid)+g_tradedata(in_pairid).pos.optradecharge(l_posid);
                    g_tradedata(in_pairid).pos.cptradecharge(l_posid)=l_tradecharge(l_chargeid)+g_tradedata(in_pairid).pos.cptradecharge(l_posid);
                end
            end
            % 该次仓位的落差，平仓或停仓的价差-建仓时的价差，可以统一计算提高效率
            g_tradedata(in_pairid).pos.gapdiff(l_posid)=g_tradedata(in_pairid).pos.cpdategap(l_posid)-g_tradedata(in_pairid).pos.opdategap(l_posid);
            % 该次仓位的收益，可以统一计算提高效率
            l_sign=1;
            switch g_tradedata(in_pairid).pos.type(l_posid)
                case 11
                    l_sign=1;
                case 12;
                    l_sign=1;
            end
            g_tradedata(in_pairid).pos.profit(l_posid)=...
                ((g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1)...
                -g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1),1))...
                *l_tradeunit(1)...
                -(g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2)...
                -g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1),2))...
                *l_tradeunit(2))*l_sign...
                -g_tradedata(in_pairid).pos.optradecharge(l_posid)-g_tradedata(in_pairid).pos.cptradecharge(l_posid);              
            % trade 
            % 交易名
            g_tradedata(in_pairid).trade.name(l_tradeid)=g_rawdata.pair(in_pairid).name;
            % 策略类型
            g_tradedata(in_pairid).trade.type(l_tradeid)=g_tradedata(in_pairid).pos.type(l_posid);
            % 交易开始日期
            g_tradedata(in_pairid).trade.opdate(l_tradeid)=g_tradedata(in_pairid).pos.opdate(l_posid);
            % 交易结束日期            
            g_tradedata(in_pairid).trade.cpdate(l_tradeid)=g_tradedata(in_pairid).pos.cpdate(l_posid);
            if datenum(g_tradedata(in_pairid).trade.cpdate(l_tradeid))>l_lastdatenum
                g_tradedata(in_pairid).trade.type(l_tradeid)=g_tradedata(in_pairid).pos.type(l_posid)+100;
            end
            % 是否实际平仓
            g_tradedata(in_pairid).trade.isclosepos(l_tradeid)=g_tradedata(in_pairid).pos.isclosepos(l_posid);
            % 交易的落差，若有价差，则累加
            g_tradedata(in_pairid).trade.gapdiff(l_tradeid)=g_tradedata(in_pairid).pos.gapdiff(l_posid);
            % 一轮交易的仓位数
            g_tradedata(in_pairid).trade.posnum(l_tradeid)=1;
            % 一轮交易的收益
            g_tradedata(in_pairid).trade.profit(l_tradeid)=g_tradedata(in_pairid).pos.profit(l_posid);  
            % 如果有加仓点
            l_apid=find(g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(l_index,:)==2,1);
            if(~isempty(l_apid))
                l_posid=l_posid+1;
                % pos
                g_tradedata(in_pairid).pos.name(l_posid)=g_rawdata.pair(in_pairid).name;
                g_tradedata(in_pairid).pos.rightid(l_posid)={g_rawdata.pair(in_pairid).rightid};
%                 g_tradedata(in_pairid).pos.type(l_posid)=g_tradedata(in_pairid).caculation(l_caculationid).type; 
                g_tradedata(in_pairid).pos.type(l_posid)=g_strategydata(in_pairid).type(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1));
                g_tradedata(in_pairid).pos.opdate(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.date(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid));
                g_tradedata(in_pairid).pos.optype(l_posid)=2;  % 加仓type
                g_tradedata(in_pairid).pos.opdategap(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid)); 
                % 建仓时的近期合约交易量
                g_tradedata(in_pairid).pos.opgapvl1(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid),1);
                % 建仓时的远期合约交易量
                g_tradedata(in_pairid).pos.opgapvl2(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid),2); 
                g_tradedata(in_pairid).pos.cpdate(l_posid)=....
                    g_rawdata.pair(in_pairid).mkdata.date(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
                g_tradedata(in_pairid).pos.cptype(l_posid)=g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(l_index,l_cspid);
                % 是否实际平仓
                g_tradedata(in_pairid).pos.isclosepos(l_posid)=~(g_tradedata(in_pairid).pos.cptype(l_posid)==32);                
                g_tradedata(in_pairid).pos.cpdategap(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
                % 平仓时的近期合约交易量
                g_tradedata(in_pairid).pos.cpgapvl1(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1);
                % 平仓时的远期合约交易量
                g_tradedata(in_pairid).pos.cpgapvl2(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2);
                % 保证金
                g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
                    *g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1)...
                    +l_tradeunit(2)*l_margin(2)...
                    *g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2));         
                % 交易手续费
                g_tradedata(in_pairid).pos.optradecharge(l_posid)=0;
                g_tradedata(in_pairid).pos.cptradecharge(l_posid)=0;            
                for l_chargeid=1:length(l_tradecharge)
                    if (l_tradecharge(l_chargeid)<1)
                        g_tradedata(in_pairid).pos.optradecharge(l_posid)=round(l_tradecharge(l_chargeid)*...
                            g_rawdata.pair(in_pairid).mkdata.op(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid),l_chargeid))...
                            +g_tradedata(in_pairid).pos.optradecharge(l_posid);
                        g_tradedata(in_pairid).pos.cptradecharge(l_posid)=round(l_tradecharge(l_chargeid)*...
                            g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),l_chargeid))...
                            +g_tradedata(in_pairid).pos.cptradecharge(l_posid);                
                    else
                        g_tradedata(in_pairid).pos.optradecharge(l_posid)=l_tradecharge(l_chargeid)+g_tradedata(in_pairid).pos.optradecharge(l_posid);
                        g_tradedata(in_pairid).pos.cptradecharge(l_posid)=l_tradecharge(l_chargeid)+g_tradedata(in_pairid).pos.cptradecharge(l_posid);
                    end
                end
                % 该次仓位的收益，可以统一计算提高效率
                g_tradedata(in_pairid).pos.gapdiff(l_posid)=g_tradedata(in_pairid).pos.cpdategap(l_posid)-g_tradedata(in_pairid).pos.opdategap(l_posid);                
                g_tradedata(in_pairid).pos.profit(l_posid)=...
                    ((g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1)...
                    -g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid),1))...
                    *l_tradeunit(1)...
                    -(g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2)...
                    -g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid),2))...
                    *l_tradeunit(2))*l_sign...
                    -g_tradedata(in_pairid).pos.optradecharge(l_posid)-g_tradedata(in_pairid).pos.cptradecharge(l_posid);                     
                % trade
                % 是否实际平仓
                g_tradedata(in_pairid).trade.isclosepos(l_tradeid)=g_tradedata(in_pairid).pos.isclosepos(l_posid);                
                g_tradedata(in_pairid).trade.posnum(l_tradeid)=2;
                g_tradedata(in_pairid).trade.gapdiff(l_tradeid)=g_tradedata(in_pairid).trade.gapdiff(l_tradeid)+g_tradedata(in_pairid).pos.gapdiff(l_posid); 
                g_tradedata(in_pairid).trade.profit(l_tradeid)=g_tradedata(in_pairid).trade.profit(l_tradeid)+g_tradedata(in_pairid).pos.profit(l_posid);
            end
            g_tradedata(in_pairid).pos.num=l_posid;
            g_tradedata(in_pairid).trade.num=l_tradeid;       
        end
    end
end

function SUB_TradeCalculationPeriodly(in_pairid,in_calulationid,in_strategytype)
%%%%%%%% 交易演算,交易有周期限制
global g_tradedata;
global g_indicatordata;
global g_rawdata;
global g_strategydata;
global g_commodityparams;

l_currentdate=g_rawdata.currentdate;
l_iscurrentdate=0;
if strcmp(g_rawdata.pair(in_pairid).mkdata.date(end),l_currentdate);
    l_iscurrentdate=1;
end
% 调用参数
l_period=round(g_commodityparams.period/2)+1;
l_losses=g_commodityparams.losses;
l_wins=g_commodityparams.wins;
g_tradedata(in_pairid).caculation(in_calulationid).type=in_strategytype;
if (g_rawdata.pair(in_pairid).datalen<g_commodityparams.period)
    g_tradedata(in_pairid).caculation(in_calulationid).result.trademap=[];
    return;
end
% 计算时间图
l_primaryindexmap=ZR_FUN_ComputeDaysMap(g_rawdata.pair(in_pairid).datalen,l_period);
g_tradedata(in_pairid).caculation(in_calulationid).primary.indexmap=l_primaryindexmap;
% 可能建、加、平仓点，l_wins单笔平仓收益越大，平仓可能越小
l_premax=g_indicatordata.pair(in_pairid).maxgap;
switch in_strategytype
    case 11
        % 可能建仓点
        l_maybeopdays=g_strategydata(in_pairid).case1a.ismatched;
        if ~l_iscurrentdate
          l_maybeopdays(end-l_period:end)=0;      
        end
    case 12
        % 可能建仓点
        l_maybeopdays=g_strategydata(in_pairid).case1b.ismatched;
        % l_maybeopdays(end-l_period:end)=0;
end
% 可能建仓点
g_tradedata(in_pairid).caculation(in_calulationid).primary.opdaysmap=l_maybeopdays(l_primaryindexmap);    
% 可能加仓点,再次满足建仓条件
g_tradedata(in_pairid).caculation(in_calulationid).primary.apdaysmap=...
    ((g_rawdata.pair(in_pairid).mkdata.cpgap(l_primaryindexmap)...
    -imresize_old(g_rawdata.pair(in_pairid).mkdata.cpgap,size(l_primaryindexmap)))<0);
g_tradedata(in_pairid).caculation(in_calulationid).primary.apdaysmap=...
    g_tradedata(in_pairid).caculation(in_calulationid).primary.apdaysmap&g_tradedata(in_pairid).caculation(in_calulationid).primary.opdaysmap;
% 可能平仓
g_tradedata(in_pairid).caculation(in_calulationid).primary.cpdaysmap=...
    ((g_rawdata.pair(in_pairid).mkdata.cpgap(l_primaryindexmap)-imresize_old(l_premax,size(l_primaryindexmap)))...
            >(l_wins*g_indicatordata.pair(in_pairid).ATR(1)));
% 停仓点
g_tradedata(in_pairid).caculation(in_calulationid).primary.spdaysmap=zeros(size(l_primaryindexmap));
% result 交易结果
% 取出所有可能的建仓点
l_maybeopdayids=find(l_maybeopdays>0);
g_tradedata(in_pairid).caculation(in_calulationid).result.opdaynum=length(l_maybeopdayids);
% 计算时间图，根据g_trade.indexmap算的，
g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap=g_tradedata(in_pairid).caculation(in_calulationid).primary.indexmap(l_maybeopdayids,:);

% 开仓，先将可能建仓点的图赋给交易图表,将首列为零的行剔除
g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap=...
    g_tradedata(in_pairid).caculation(in_calulationid).primary.opdaysmap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap);
% 加仓：2，初始化第一列，目的避免和建仓信息混淆
g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap=...
    2*g_tradedata(in_pairid).caculation(in_calulationid).primary.apdaysmap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(:,1),:);
g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(:,1)=0;
% 平仓：4
g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap=...
    4*g_tradedata(in_pairid).caculation(in_calulationid).primary.cpdaysmap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(:,1),:);
g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(:,1)=0;
% 减仓：8
g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap=...
    8*g_tradedata(in_pairid).caculation(in_calulationid).primary.spdaysmap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap);
g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap(:,1)=0;
% 交易演算过程
% 遍历所有可能的建仓点，暂时构建不出适用的矩阵
for l_index=1:g_tradedata(in_pairid).caculation(in_calulationid).result.opdaynum  
    % 如果第一列为零，即不是建仓点，忽略计算
    if(g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index,1)==0)
        continue;
    end
    % 记录第一次加仓点，清除之后的加仓点；没有加仓点，则记录为0
    l_apid=find(g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_index,:),1);  
    if (isempty(l_apid)||(l_apid>=l_period))
        % 周期内没有加仓点
        l_apid=0;
        g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_index,:)=0;
    else
        g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_index,(l_apid+1):l_period)=0;
    end
    % 记录第一次平仓点，清除之后的平仓点，没有平仓点，则记录为0
    l_cpid=find(g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,:),1); 
    if (isempty(l_cpid)||(l_cpid>=l_period))
        % 周期内没有加仓点
        l_cpid=0;
        g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,:)=0;
    else
        g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,(l_cpid+1):l_period)=0;
    end    
    % 根据第一次加仓，计算止损停仓点
    if(l_apid==0)
        l_spid=0;
    else
        % 将加仓日之后每天的gap跟加仓日当前的gap进行比较
        l_spdays=zeros(1,l_period);
        switch in_strategytype
            case 11
                l_spdays((l_apid+1):l_period)=...
                    8*((g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_index,(l_apid+1):l_period))...
                    -g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_index,l_apid)))...
                    <(-l_losses*g_indicatordata.pair(in_pairid).ATR(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_index,l_apid))));
            case 12
                l_spdays((l_apid+1):l_period)=...
                    8*((g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_index,(l_apid+1):l_period))...
                    -g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_index,l_apid)))...
                    <(-l_losses*g_indicatordata.pair(in_pairid).ATR(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_index,l_apid))));                               
        end
        g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap(l_index,:)=l_spdays;
        l_spid=find(l_spdays,1);
        if (isempty(l_spid)||(l_spid>=l_period))
            l_spid=0;
            g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap(l_index,:)=0;
        else
            g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap(l_index,(l_spid+1):l_period)=0;
        end
    end
    % 如果没有平仓点和停仓点，时间平仓：16
    if((l_cpid==0)&&(l_spid==0))        
        g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,l_period)=16;
        % 周期内只允许一次建仓
        l_opdays=find(g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index,2:l_period));
        if(~isempty(l_opdays))
            g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index+(1:length(l_opdays)),1)=0;  
        end
    else
        % 清除该次平、停仓点之间的建仓点，第一个除外；必须先判断平仓点和停仓点先后顺序
        if(l_cpid==0)
            l_end=l_spid;
        elseif(l_spid==0) 
            l_end=l_cpid;
        else
            if(l_cpid>l_spid)
                l_end=l_spid;
                g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,:)=0;
            else
                l_end=l_cpid;
                g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap(l_index,:)=0;
            end
        end 
        % 如果加仓点在平仓点之后，则无效
        if(l_apid>=l_end)
            g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_index,:)=0;
        end
        % 没有平仓和停仓的情况下，周期内只允许一次建仓
        l_opdays=find(g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index,2:l_end));
        if(~isempty(l_opdays))
            g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index+(1:length(l_opdays)),1)=0;  
        end
    end
    g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index,2:l_period)=0; 
end

% 剔除非法建仓点
l_resultindex=find(g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(:,1));
% 开加减平仓点相加得到trademap
g_tradedata(in_pairid).caculation(in_calulationid).result.trademap=g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_resultindex,:)...
    +g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_resultindex,:)...
    +g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_resultindex,:)...
    +g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap(l_resultindex,:); 
% 交易日的id
g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap=g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_resultindex,:);
if ~isempty(g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap)&&l_iscurrentdate
    % 如果在最后一个周期有建仓，认为非法
    if ((g_rawdata.pair(in_pairid).info.daystolasttradedate>0)&&(g_rawdata.pair(in_pairid).info.daystolasttradedate<=l_period))
        % 是否最后一个周期有建仓
        g_tradedata(in_pairid).caculation(in_calulationid).result.trademap(...
            g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(:,1)>=...
            (g_rawdata.pair(in_pairid).datalen-g_rawdata.pair(in_pairid).info.daystolasttradedate),:)=[];
        g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(...
            g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(:,1)>=...
            (g_rawdata.pair(in_pairid).datalen-g_rawdata.pair(in_pairid).info.daystolasttradedate),:)=[];        
        % l_resultindex(l_lastop)=[];
    end   
    % 最后一次交易，并且在临近结束的一个周期内，
    if (g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(end,1)>(g_rawdata.pair(in_pairid).datalen-l_period+1))...
            &&((g_tradedata(in_pairid).caculation(in_calulationid).result.trademap(end,end)==16)...
            ||(g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(end,1)==g_rawdata.pair(in_pairid).datalen))
        g_tradedata(in_pairid).caculation(in_calulationid).result.trademap(end,...
            g_tradedata(in_pairid).caculation(in_calulationid).result.trademap(end,:)>=4)=32;
    end  
end

% 交易日的id
g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap=g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_resultindex,:);

% function out_trade=SUB_TradeCalculation(in_pairid,in_calulationid,in_strategytype)









