function out_traderecord=ZR_STRATEGY_PAIR_PLUGIN_020603_L1_S7_S10(in_inputdata)
% 羽根英树的策略:020601

SUB_ComputeIndicatorPerPair(in_inputdata);
% 计算策略的数据
SUB_ComputeStrategyDataPerPair(in_inputdata);
% 交易记录演算
out_traderecord=SUB_ComputeRecordDataPerPair(in_inputdata);


function SUB_ComputeIndicatorPerPair(in_inputdata)
%%%%%%%% 计算套利对的指标信息
global g_indicatordata;
% 调用参数
g_indicatordata=[];
l_period=in_inputdata.strategyparms.period;
l_periodmin=round(l_period/2)+1;
if (in_inputdata.pair.datalen>l_period)
    % l_periodmin=l_period;
    % 计算gap为负时的，周期内的最大值
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    l_cpgapdata(l_cpgapdata>0)=0;
    g_indicatordata.pair.negativemaxgap=-TA_MAX(abs(l_cpgapdata),l_period).*(l_cpgapdata<0);
    % 计算gap周期内的最大值,以及最大值时的index
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    g_indicatordata.pair.maxgap=TA_MAX(l_cpgapdata,l_periodmin);
    g_indicatordata.pair.maxgapid=TA_MAXINDEX(l_cpgapdata,l_periodmin)+1;
    % 计算周期内gap为最大值时，近期和远期的价格
    g_indicatordata.pair.gapmaxprice(:,1)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.maxgapid,1);
    g_indicatordata.pair.gapmaxprice(:,2)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.maxgapid,2);

    g_indicatordata.pair.ATR=min(in_inputdata.commodity.info.tick)*ones(in_inputdata.pair.datalen,1);
    g_indicatordata.pair.serial=(TA_MA(double(in_inputdata.pair.mkdata.cpgap<0),l_period)>=1);
    g_indicatordata.pair.isallowed=(min(in_inputdata.pair.mkdata.vl,[],2)>=100);
else
    % l_periodmin=l_period;
    % 计算gap为负时的，周期内的最大值
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    l_cpgapdata(l_cpgapdata>0)=0;
    g_indicatordata.pair.negativemaxgap=zeros(size(l_cpgapdata));
    % 计算gap周期内的最大值,以及最大值时的index
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    g_indicatordata.pair.maxgap=zeros(size(l_cpgapdata));
    g_indicatordata.pair.maxgapid=ones(size(l_cpgapdata));
    % 计算周期内gap为最大值时，近期和远期的价格
    g_indicatordata.pair.gapmaxprice(:,1)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.maxgapid,1);
    g_indicatordata.pair.gapmaxprice(:,2)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.maxgapid,2);

    g_indicatordata.pair.ATR=min(in_inputdata.commodity.info.tick)*ones(in_inputdata.pair.datalen,1);
    g_indicatordata.pair.serial=zeros(size(l_cpgapdata));
    g_indicatordata.pair.isallowed=zeros(size(l_cpgapdata));
end

function SUB_ComputeStrategyDataPerPair(in_inputdata)
%%%%%%%% 计算套策略相关数据
global g_indicatordata;
global g_strategydata;
g_strategydata=[];
% global g_commodityparams;
% 记录及远期价格比较，gap最大最小值的点
g_strategydata.isnegativemaxgappoint=(g_indicatordata.pair.negativemaxgap==in_inputdata.pair.mkdata.cpgap);
g_strategydata.isn2rpricehigher=(in_inputdata.pair.mkdata.cpgap>0);
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
g_strategydata.case1a.pricechange(:,1)=in_inputdata.pair.mkdata.cp(:,1)-g_indicatordata.pair.gapmaxprice(:,1);
g_strategydata.case1a.pricechange(:,2)=in_inputdata.pair.mkdata.cp(:,2)-g_indicatordata.pair.gapmaxprice(:,2);
g_strategydata.case1a.n2rpricechangediff=g_strategydata.case1a.pricechange(:,1)-g_strategydata.case1a.pricechange(:,2);
g_strategydata.case1a.isnearpriceup=(g_strategydata.case1a.pricechange(:,1)>0);
g_strategydata.case1a.isremotepriceup=(g_strategydata.case1a.pricechange(:,2)>0);
g_strategydata.case1a.isn2rchangebigger=(abs(g_strategydata.case1a.pricechange(:,1))>=abs(g_strategydata.case1a.pricechange(:,2)));
g_strategydata.case1a.ismatched=(g_strategydata.isnegativemaxgappoint)&(in_inputdata.pair.mkdata.cpgap<0)...
    &(~g_strategydata.case1a.isnearpriceup)...
    &(~g_strategydata.case1a.isremotepriceup)...
    &(g_strategydata.case1a.isn2rchangebigger)...
    &g_indicatordata.pair.isallowed;
% 计算1b情况的策略数据,波峰的形成是由于远期合约上涨幅度比近期大的情况
g_strategydata.case1b.pricechange(:,1)=in_inputdata.pair.mkdata.cp(:,1)-g_indicatordata.pair.gapmaxprice(:,1);
g_strategydata.case1b.pricechange(:,2)=in_inputdata.pair.mkdata.cp(:,2)-g_indicatordata.pair.gapmaxprice(:,2);
g_strategydata.case1b.n2rpricechangediff=g_strategydata.case1b.pricechange(:,1)-g_strategydata.case1b.pricechange(:,2);
g_strategydata.case1b.isnearpriceup=(g_strategydata.case1b.pricechange(:,1)>0);
g_strategydata.case1b.isremotepriceup=(g_strategydata.case1b.pricechange(:,2)>0);
g_strategydata.case1b.isn2rchangebigger=(abs(g_strategydata.case1b.pricechange(:,1))>abs(g_strategydata.case1b.pricechange(:,2)));
g_strategydata.case1b.ismatched=(g_strategydata.isnegativemaxgappoint)&(in_inputdata.pair.mkdata.cpgap<0)...
    &(g_strategydata.case1b.isremotepriceup)...
    &((~g_strategydata.case1b.isnearpriceup)|((g_strategydata.case1b.isremotepriceup)&(~g_strategydata.case1b.isn2rchangebigger)))...
    &g_indicatordata.pair.isallowed; 
g_strategydata.type=11*g_strategydata.case1a.ismatched+12*g_strategydata.case1b.ismatched;
g_strategydata.case1a.ismatched=(g_strategydata.case1a.ismatched|g_strategydata.case1b.ismatched);



function out_traderecord=SUB_ComputeRecordDataPerPair(in_inputdata)
%%%%%%%% 计算交易数据
global g_tradecaculation;
% 调用参数
l_traderecord=[];
g_tradecaculation.caculationnum=1;
% 执行演算过程
SUB_TradeCalculationPeriodly(in_inputdata,1,11);
% 记录交易情况
l_posid=0;
% 后续程序根据num值判断是否有开仓
% l_traderecord.name=in_inputdata.pair.name;
for l_caculationid=1:g_tradecaculation.caculationnum
    if(~isempty(g_tradecaculation(l_caculationid).result.trademap))
        for l_index=1:length(g_tradecaculation(l_caculationid).result.trademap(:,1))
            % pos和trade数量自增1
            l_posid=l_posid+1;
            % 平仓点或停仓点
            l_cspid=find(g_tradecaculation(l_caculationid).result.trademap(l_index,:)>=4,1);
            % pos
            % 名字
            l_traderecord.name(l_posid)=in_inputdata.pair.name;
            l_traderecord.direction(l_posid)=1; %1代表做多，-1代表做空
            l_traderecord.opdate(l_posid)=...
                in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1));
            l_traderecord.cpdate(l_posid)=....
                in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));  
            l_traderecord.isclosepos(l_posid)=~(g_tradecaculation(l_caculationid).result.trademap(l_index,l_cspid)==32);
            % 建仓时的价格
            l_traderecord.opdateprice(l_posid)=...
                in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1));
            % 平仓时的价格
            l_traderecord.cpdateprice(l_posid)=...
                in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));              
            % 如果有加仓点
            l_apid=find(g_tradecaculation(l_caculationid).result.trademap(l_index,:)==2,1);
            if(~isempty(l_apid))
                l_posid=l_posid+1;
                l_traderecord.name(l_posid)=in_inputdata.pair.name;
                l_traderecord.direction(l_posid)=1; %1代表做多，-1代表做空
                l_traderecord.opdate(l_posid)=...
                    in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid));
                l_traderecord.cpdate(l_posid)=....
                    in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));  
                l_traderecord.isclosepos(l_posid)=~(g_tradecaculation(l_caculationid).result.trademap(l_index,l_cspid)==32);
                % 建仓时的价格
                l_traderecord.opdateprice(l_posid)=...
                    in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid));
                % 平仓时的价格
                l_traderecord.cpdateprice(l_posid)=...
                    in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));                 
            end
        end
    end
end
out_traderecord=l_traderecord;

function SUB_TradeCalculationPeriodly(in_inputdata,in_calulationid,in_strategytype)
%%%%%%%% 交易演算,交易有周期限制
global g_tradecaculation;
global g_indicatordata;
global g_strategydata;

% l_currentdate=in_inputdata.currentdate;
% l_iscurrentdate=0;
% if strcmp(in_inputdata.pair.mkdata.date(end),l_currentdate);
%     l_iscurrentdate=1;
% end
% 调用参数
l_period=round(in_inputdata.strategyparms.period/2)+1;
l_losses=in_inputdata.strategyparms.losses;
l_wins=in_inputdata.strategyparms.wins;
g_tradecaculation(in_calulationid).type=in_strategytype;
if (in_inputdata.pair.datalen<in_inputdata.strategyparms.period)
    g_tradecaculation(in_calulationid).result.trademap=[];
    return;
end
% 计算时间图
l_primaryindexmap=ZR_FUN_ComputeDaysMap(in_inputdata.pair.datalen,l_period);
g_tradecaculation(in_calulationid).primary.indexmap=l_primaryindexmap;
% 可能建、加、平仓点，l_wins单笔平仓收益越大，平仓可能越小
l_premax=g_indicatordata.pair.maxgap;
switch in_strategytype
    case 11
        % 可能建仓点
        l_maybeopdays=g_strategydata.case1a.ismatched;
%         if ~l_iscurrentdate
%           l_maybeopdays(end-l_period:end)=0;      
%         end
    case 12
        % 可能建仓点
        l_maybeopdays=g_strategydata.case1b.ismatched;
        % l_maybeopdays(end-l_period:end)=0;
end
% 可能建仓点
g_tradecaculation(in_calulationid).primary.opdaysmap=l_maybeopdays(l_primaryindexmap);    
% 可能加仓点,再次满足建仓条件
g_tradecaculation(in_calulationid).primary.apdaysmap=...
    ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)...
    -imresize_old(in_inputdata.pair.mkdata.cpgap,size(l_primaryindexmap)))<0);
g_tradecaculation(in_calulationid).primary.apdaysmap=...
    g_tradecaculation(in_calulationid).primary.apdaysmap&g_tradecaculation(in_calulationid).primary.opdaysmap;
% 可能平仓
g_tradecaculation(in_calulationid).primary.cpdaysmap=...
    ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)-imresize_old(l_premax,size(l_primaryindexmap)))...
            >(l_wins*g_indicatordata.pair.ATR(1)));
% 停仓点
g_tradecaculation(in_calulationid).primary.spdaysmap=zeros(size(l_primaryindexmap));
% result 交易结果
% 取出所有可能的建仓点
l_maybeopdayids=find(l_maybeopdays>0);
g_tradecaculation(in_calulationid).result.opdaynum=length(l_maybeopdayids);
% 计算时间图，根据g_trade.indexmap算的，
g_tradecaculation(in_calulationid).result.indexmap=g_tradecaculation(in_calulationid).primary.indexmap(l_maybeopdayids,:);

% 开仓，先将可能建仓点的图赋给交易图表,将首列为零的行剔除
g_tradecaculation(in_calulationid).result.opdaysmap=...
    g_tradecaculation(in_calulationid).primary.opdaysmap(g_tradecaculation(in_calulationid).result.indexmap);
% 加仓：2，初始化第一列，目的避免和建仓信息混淆
g_tradecaculation(in_calulationid).result.apdaysmap=...
    2*g_tradecaculation(in_calulationid).primary.apdaysmap(g_tradecaculation(in_calulationid).result.indexmap(:,1),:);
g_tradecaculation(in_calulationid).result.apdaysmap(:,1)=0;
% 平仓：4
g_tradecaculation(in_calulationid).result.cpdaysmap=...
    4*g_tradecaculation(in_calulationid).primary.cpdaysmap(g_tradecaculation(in_calulationid).result.indexmap(:,1),:);
g_tradecaculation(in_calulationid).result.cpdaysmap(:,1)=0;
% 减仓：8
g_tradecaculation(in_calulationid).result.spdaysmap=...
    8*g_tradecaculation(in_calulationid).primary.spdaysmap(g_tradecaculation(in_calulationid).result.indexmap);
g_tradecaculation(in_calulationid).result.spdaysmap(:,1)=0;
% 交易演算过程
% 遍历所有可能的建仓点，暂时构建不出适用的矩阵
for l_index=1:g_tradecaculation(in_calulationid).result.opdaynum  
    % 如果第一列为零，即不是建仓点，忽略计算
    if(g_tradecaculation(in_calulationid).result.opdaysmap(l_index,1)==0)
        continue;
    end
    % 记录第一次加仓点，清除之后的加仓点；没有加仓点，则记录为0
    l_apid=find(g_tradecaculation(in_calulationid).result.apdaysmap(l_index,:),1);  
    if (isempty(l_apid)||(l_apid>=l_period))
        % 周期内没有加仓点
        l_apid=0;
        g_tradecaculation(in_calulationid).result.apdaysmap(l_index,:)=0;
    else
        g_tradecaculation(in_calulationid).result.apdaysmap(l_index,(l_apid+1):l_period)=0;
    end
    % 记录第一次平仓点，清除之后的平仓点，没有平仓点，则记录为0
    l_cpid=find(g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,:),1); 
    if (isempty(l_cpid)||(l_cpid>=l_period))
        % 周期内没有加仓点
        l_cpid=0;
        g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,:)=0;
    else
        g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,(l_cpid+1):l_period)=0;
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
                    8*((in_inputdata.pair.mkdata.cpgap(g_tradecaculation(in_calulationid).result.indexmap(l_index,(l_apid+1):l_period))...
                    -in_inputdata.pair.mkdata.cpgap(g_tradecaculation(in_calulationid).result.indexmap(l_index,l_apid)))...
                    <(-l_losses*g_indicatordata.pair.ATR(g_tradecaculation(in_calulationid).result.indexmap(l_index,l_apid))));
            case 12
                l_spdays((l_apid+1):l_period)=...
                    8*((in_inputdata.pair.mkdata.cpgap(g_tradecaculation(in_calulationid).result.indexmap(l_index,(l_apid+1):l_period))...
                    -in_inputdata.pair.mkdata.cpgap(g_tradecaculation(in_calulationid).result.indexmap(l_index,l_apid)))...
                    <(-l_losses*g_indicatordata.pair.ATR(g_tradecaculation(in_calulationid).result.indexmap(l_index,l_apid))));                               
        end
        g_tradecaculation(in_calulationid).result.spdaysmap(l_index,:)=l_spdays;
        l_spid=find(l_spdays,1);
        if (isempty(l_spid)||(l_spid>=l_period))
            l_spid=0;
            g_tradecaculation(in_calulationid).result.spdaysmap(l_index,:)=0;
        else
            g_tradecaculation(in_calulationid).result.spdaysmap(l_index,(l_spid+1):l_period)=0;
        end
    end
    % 如果没有平仓点和停仓点，时间平仓：16
    if((l_cpid==0)&&(l_spid==0))        
        g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,l_period)=16;
        % 周期内只允许一次建仓
        l_opdays=find(g_tradecaculation(in_calulationid).result.opdaysmap(l_index,2:l_period));
        if(~isempty(l_opdays))
            g_tradecaculation(in_calulationid).result.opdaysmap(l_index+(1:length(l_opdays)),1)=0;  
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
                g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,:)=0;
            else
                l_end=l_cpid;
                g_tradecaculation(in_calulationid).result.spdaysmap(l_index,:)=0;
            end
        end 
        % 如果加仓点在平仓点之后，则无效
        if(l_apid>=l_end)
            g_tradecaculation(in_calulationid).result.apdaysmap(l_index,:)=0;
        end
        % 没有平仓和停仓的情况下，周期内只允许一次建仓
        l_opdays=find(g_tradecaculation(in_calulationid).result.opdaysmap(l_index,2:l_end));
        if(~isempty(l_opdays))
            g_tradecaculation(in_calulationid).result.opdaysmap(l_index+(1:length(l_opdays)),1)=0;  
        end
    end
    g_tradecaculation(in_calulationid).result.opdaysmap(l_index,2:l_period)=0; 
end

% 剔除非法建仓点
l_resultindex=find(g_tradecaculation(in_calulationid).result.opdaysmap(:,1));
% 开加减平仓点相加得到trademap
g_tradecaculation(in_calulationid).result.trademap=g_tradecaculation(in_calulationid).result.opdaysmap(l_resultindex,:)...
    +g_tradecaculation(in_calulationid).result.apdaysmap(l_resultindex,:)...
    +g_tradecaculation(in_calulationid).result.cpdaysmap(l_resultindex,:)...
    +g_tradecaculation(in_calulationid).result.spdaysmap(l_resultindex,:); 
% 交易日的id
g_tradecaculation(in_calulationid).result.tddaysmap=g_tradecaculation(in_calulationid).result.indexmap(l_resultindex,:);
if ~isempty(g_tradecaculation(in_calulationid).result.tddaysmap)
    if(in_inputdata.pair.info.daystolasttradedate>0)
        % 如果在最后一个周期有建仓，认为非法
        if (in_inputdata.pair.info.daystolasttradedate<=l_period)
            % 是否最后一个周期有建仓
            g_tradecaculation(in_calulationid).result.trademap(...
                g_tradecaculation(in_calulationid).result.tddaysmap(:,1)>=...
                (in_inputdata.pair.datalen-in_inputdata.pair.info.daystolasttradedate),:)=[];
            g_tradecaculation(in_calulationid).result.tddaysmap(...
                g_tradecaculation(in_calulationid).result.tddaysmap(:,1)>=...
                (in_inputdata.pair.datalen-in_inputdata.pair.info.daystolasttradedate),:)=[];        
            % l_resultindex(l_lastop)=[];
        end   
        % 最后一次交易，并且在临近结束的一个周期内，
        l_lastperiod=g_tradecaculation(in_calulationid).result.tddaysmap(end,1)-(in_inputdata.pair.datalen-l_period+1);
        if (l_lastperiod>0)...
                &&((sum(g_tradecaculation(in_calulationid).result.trademap(end,(end-l_lastperiod+1):end)>=4)>0)...
                ||(g_tradecaculation(in_calulationid).result.tddaysmap(end,1)==in_inputdata.pair.datalen))
            g_tradecaculation(in_calulationid).result.trademap(end,...
                g_tradecaculation(in_calulationid).result.trademap(end,:)>=4)=32;
        end  
    else
        % 是否最后一个周期有建仓
        g_tradecaculation(in_calulationid).result.trademap(...
            g_tradecaculation(in_calulationid).result.tddaysmap(:,1)>=...
            (in_inputdata.pair.datalen-l_period),:)=[];
        g_tradecaculation(in_calulationid).result.tddaysmap(...
            g_tradecaculation(in_calulationid).result.tddaysmap(:,1)>=...
            (in_inputdata.pair.datalen-l_period),:)=[];           
    end
end

% 交易日的id
g_tradecaculation(in_calulationid).result.tddaysmap=g_tradecaculation(in_calulationid).result.indexmap(l_resultindex,:);

% function out_trade=SUB_TradeCalculation(in_pairid,in_calulationid,in_strategytype)










