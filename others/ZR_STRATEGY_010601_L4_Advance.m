function ZR_STRATEGY_010601_L4_Advance(varargin)
% 羽根英树的策略:010601

% 用到的全局变量
global g_contractnames;
global g_rawdata;
global g_coredata;
% 设置策略参数
SUB_SetStrategyParams(varargin{:});
% 如果没有合约名集的信息，则用G_RunSpecialTestCase中的合约名集
if isempty(g_contractnames)
    error('合约名列表没有初始化');
end
%%%% 算法过程
l_cmnum=length(g_contractnames);
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
    SUB_SaveTradeBarPerCommodity();
end
% 报告汇总
ZR_PROCESS_CollectReport();

function SUB_SetStrategyParams(varargin)
%%%%%%%% 设置策略参数
global g_strategyparams;
global g_contractnames;
% 参数赋值，优化执行时才会传入参数
if(nargin>0)
    % 默认是每种商品下单一手
    g_strategyparams.handnum=ones(1,length(g_contractnames)); 
    l_commandstr='';
    for l_paramid=1:(nargin/2)   
        l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_contractnames)); ');
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

% 大于0的id
g_indicatordata.pair(in_pairid).positivecpgapid=find(g_rawdata.pair(in_pairid).mkdata.cpgap>0);
% 止损tick
g_indicatordata.pair(in_pairid).ATR=g_rawdata.commodity.info.tick*ones(g_rawdata.pair(in_pairid).datalen,1);

function SUB_ComputeStrategyDataPerPair(in_pairid)
%%%%%%%% 计算套策略相关数据

function SUB_ComputeTradeDataPerPair(in_pairid)
%%%%%%%% 计算交易数据
global g_rawdata;
global g_tradedata;
global g_commodityparams;
global g_strategydata;
% 调用参数
l_handnum=g_commodityparams.handnum;
% 交易单位
l_tradeunit=g_rawdata.commodity.info.tradeunit*l_handnum;
% 是否单边收取保证金
if(g_rawdata.commodity.info.issinglemargin)
    l_tradenum=1;
else
    l_tradenum=2;
end
% 保证金比例
l_margin=g_rawdata.commodity.info.margin;
% 交易手续费
l_tradecharge=g_rawdata.commodity.info.tradecharge*l_handnum;
% 执行演算过程
g_tradedata(in_pairid).caculationnum=1;
SUB_TradeCalculation(in_pairid,1,41);
% 记录交易情况
l_opdays=find(g_tradedata(in_pairid).caculation(1).opdays);
l_cpdays=find(g_tradedata(in_pairid).caculation(1).cpdays);
l_posid=0;
l_tradeid=0;
% 后续程序根据num值判断是否有开仓
g_tradedata(in_pairid).pos.num=[];
g_tradedata(in_pairid).trade.num=[];  
g_tradedata(in_pairid).pos.name=g_rawdata.pair(in_pairid).name;
g_tradedata(in_pairid).trade.name=g_rawdata.pair(in_pairid).name;
if ~isempty(l_opdays)
    for l_dayid=1:length(l_opdays)
        % pos和trade数量自增1
        l_posid=l_posid+1;
        l_tradeid=l_tradeid+1;
        % 策略类型
        if (g_tradedata(in_pairid).caculation(1).opdays(l_opdays(l_dayid))==3)
            g_tradedata(in_pairid).pos.type(l_posid)=41; 
        else
            g_tradedata(in_pairid).pos.type(l_posid)=42; 
        end
        % 建仓日期
        g_tradedata(in_pairid).pos.opdate(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.date(l_opdays(l_dayid));
        % 建仓类型
        g_tradedata(in_pairid).pos.optype(l_posid)=g_tradedata(in_pairid).caculation(1).opdays(l_opdays(l_dayid));
        % 建仓时的价差
        g_tradedata(in_pairid).pos.opdategap(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.cpgap(l_opdays(l_dayid));
        % 建仓时的近期合约交易量
        g_tradedata(in_pairid).pos.opgapvl1(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.vl(l_opdays(l_dayid),1);
        % 建仓时的远期合约交易量
        g_tradedata(in_pairid).pos.opgapvl2(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.vl(l_opdays(l_dayid),2);                
        % 平仓或停仓的日期
        g_tradedata(in_pairid).pos.cpdate(l_posid)=....
            g_rawdata.pair(in_pairid).mkdata.date(l_cpdays(l_dayid));
        % 平仓或停仓的类型
        g_tradedata(in_pairid).pos.cptype(l_posid)=g_tradedata(in_pairid).caculation(1).cpdays(l_cpdays(l_dayid));  
        % 平仓或停仓的价差
        g_tradedata(in_pairid).pos.cpdategap(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.cpgap(l_cpdays(l_dayid));
        % 保证金
        g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit*l_margin*l_tradenum...
            *max(g_rawdata.pair(in_pairid).mkdata.cp(l_cpdays(l_dayid),:)));
        % 平仓时的近期合约交易量
        g_tradedata(in_pairid).pos.cpgapvl1(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.vl(l_cpdays(l_dayid),1);
        % 平仓时的远期合约交易量
        g_tradedata(in_pairid).pos.cpgapvl2(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.vl(l_cpdays(l_dayid),2);            
        % 交易手续费
        if (l_tradecharge<1)
            g_tradedata(in_pairid).pos.optradecharge(l_posid)=round(sum(l_tradecharge*...
                g_rawdata.pair(in_pairid).mkdata.op(l_opdays(l_dayid),:)));
            g_tradedata(in_pairid).pos.cptradecharge(l_posid)=round(sum(l_tradecharge*...
                g_rawdata.pair(in_pairid).mkdata.cp(l_cpdays(l_dayid),:)));                
        else
            g_tradedata(in_pairid).pos.optradecharge(l_posid)=l_tradecharge*2;
            g_tradedata(in_pairid).pos.cptradecharge(l_posid)=l_tradecharge*2;
        end

        % 该次仓位的落差，平仓或停仓的价差-建仓时的价差，可以统一计算提高效率
        g_tradedata(in_pairid).pos.gapdiff(l_posid)=g_tradedata(in_pairid).pos.cpdategap(l_posid)-g_tradedata(in_pairid).pos.opdategap(l_posid); 
        l_sign=-1;
        g_tradedata(in_pairid).pos.profit(l_posid)=g_tradedata(in_pairid).pos.gapdiff(l_posid)*l_tradeunit*l_sign...
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
        % 交易的落差，若有价差，则累加
        g_tradedata(in_pairid).trade.gapdiff(l_tradeid)=g_tradedata(in_pairid).pos.gapdiff(l_posid);
        % 一轮交易的仓位数
        g_tradedata(in_pairid).trade.posnum(l_tradeid)=1;
        % 一轮交易的收益
        g_tradedata(in_pairid).trade.profit(l_tradeid)=g_tradedata(in_pairid).pos.profit(l_posid);  
        g_tradedata(in_pairid).pos.num=l_posid;
        g_tradedata(in_pairid).trade.num=l_tradeid;               
    end
end


function SUB_SaveTradeBarPerCommodity()
%%%%%%%% 生成交易的图
global g_rawdata;
global g_tradedata;
global g_figure;
global G_Start;
global g_strategydata;
if (strcmp(G_Start.runmode,'RunSpecialTestCase')&&(g_figure.savetradebar.issaved))
    % 遍历该品种所有的套利对
    close all; 
    l_pairnum=length(g_tradedata);
    for l_pairid=1:l_pairnum
        if(isempty(g_tradedata(l_pairid).pos.num))
            continue;
        end  
        figure('Name',cell2mat(g_rawdata.pair(l_pairid).name));
        for l_caculationid=1:g_tradedata(l_pairid).caculationnum
            l_cpgaplen=g_rawdata.pair(l_pairid).datalen;
            % 从2开始标记颜色比较清楚
            l_color=zeros(l_cpgaplen,1);
            l_color(find(g_tradedata(l_pairid).caculation(l_caculationid).opdays))=2;
            l_color(find(g_tradedata(l_pairid).caculation(l_caculationid).cpdays))=4;            
            l_bar=bar(1:l_cpgaplen,g_rawdata.pair(l_pairid).mkdata.cpgap,'stacked');
            l_ch=get(l_bar,'children');
            set(l_ch, 'EdgeColor', 'w'); 
            set(l_ch,'FaceVertexCData',l_color);
        end
        if (~exist(g_figure.savetradebar.outdir,'dir'))
            mkdir(g_figure.savetradebar.outdir);
        end
        % 保存图形的类型
        switch g_figure.savetradebar.outfiletype
            case 'fig'
                saveas(gcf,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.pair(l_pairid).name)));
            otherwise
                saveas(gcf,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.pair(l_pairid).name)));
                print(gcf,g_figure.savetradebar.outfiletype,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.pair(l_pairid).name)));
        end
    end
end

function SUB_TradeCalculation(in_pairid,in_calulationid,in_strategytype)
%%%%%%%% 交易演算
global g_tradedata;
global g_indicatordata;
global g_rawdata;
global g_commodityparams;

% 调用参数
l_counters=g_commodityparams.counters;
l_losses=g_commodityparams.losses;
l_wins=g_commodityparams.wins;
g_tradedata(in_pairid).caculation(in_calulationid).type=in_strategytype;
% 计数
l_num=0;
l_upcounter=0;
l_downcounter=0;
l_isop=0;
l_cpgap=g_rawdata.pair(in_pairid).mkdata.cpgap;
l_opdays=zeros(size(g_rawdata.pair(in_pairid).mkdata.cpgap));
l_cpdays=zeros(size(g_rawdata.pair(in_pairid).mkdata.cpgap));
g_tradedata(in_pairid).caculation(in_calulationid).opdays=l_opdays;
g_tradedata(in_pairid).caculation(in_calulationid).cpdays=l_cpdays;
if isempty(g_indicatordata.pair(in_pairid).positivecpgapid)
    return;
end
l_days=g_indicatordata.pair(in_pairid).positivecpgapid;
for l_gapid=1:length(l_days)
    l_num=l_num+1;
    if (l_num==1)
        % 首次建仓,0点附近
        if (l_days(l_gapid)>1)&&(min(g_rawdata.pair(in_pairid).mkdata.vl(l_days(l_gapid),:))>=100)
            l_opdays(l_days(l_gapid))=1;
            l_isop=1;
        end
        l_lastupcpgap=l_cpgap(l_days(l_gapid));
        l_lastdowncpgap=l_cpgap(l_days(l_gapid));       
    elseif(l_days(l_gapid)<=(l_lastid+1))
        if l_cpgap(l_days(l_gapid))>l_lastupcpgap
            l_lastupcpgap=l_cpgap(l_days(l_gapid));
            l_upcounter=l_upcounter+1;           
            % 达到平仓的条件，downcouter重新计数，0点附近
            if l_isop
                l_opdaygap=l_cpgap(find(l_opdays,1,'last'));
                if (l_cpgap(l_days(l_gapid))-l_opdaygap)>(l_losses*g_indicatordata.pair(in_pairid).ATR(1))
                    % 达到止损平仓的条件，downcouter重新计数
                    l_cpdays(l_days(l_gapid))=8;
                    l_isop=0;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid));    
%                 elseif (l_upcounter>=l_counters) 
%                     % 达到止损平仓的条件，downcouter重新计数
%                     l_cpdays(l_days(l_gapid))=8;
%                     l_isop=0;
%                     l_upcounter=0;
%                     l_lastupcpgap=l_cpgap(l_days(l_gapid));
%                     l_downcounter=0;
%                     l_lastdowncpgap=l_cpgap(l_days(l_gapid));                                            
                end
            else 
                l_downcounter=0;
                l_lastdowncpgap=l_cpgap(l_days(l_gapid));                 
                if (l_upcounter>=l_counters)&&(min(g_rawdata.pair(in_pairid).mkdata.vl(l_days(l_gapid),:))>=100) 
                    % 建仓的条件，downcouter重新计数
                    l_opdays(l_days(l_gapid))=2;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid));                      
                    l_isop=1;                      
                end                
            end            
        elseif (l_cpgap(l_days(l_gapid))<l_lastdowncpgap)
            l_lastdowncpgap=l_cpgap(l_days(l_gapid));
            l_downcounter=l_downcounter+1;             
            if (l_isop)
                l_opdaygap=l_cpgap(find(l_opdays,1,'last'));
                if (l_cpgap(l_days(l_gapid))-l_opdaygap)<(-l_wins*g_indicatordata.pair(in_pairid).ATR(1))
                    % 达到止盈平仓的条件，downcouter重新计数
                    l_cpdays(l_days(l_gapid))=4;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid)); 
                    l_isop=0;                    
                elseif (l_downcounter>=floor(l_counters/2)) 
                    % 达到止盈平仓的条件，downcouter重新计数
                    l_cpdays(l_days(l_gapid))=4;
                    l_isop=0;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid));                       
                end  
            else
%                 l_upcounter=0;
%                 l_lastupcpgap=l_cpgap(l_days(l_gapid));                 
                if (l_downcounter>=l_counters)&&(min(g_rawdata.pair(in_pairid).mkdata.vl(l_days(l_gapid),:))>=100)
                    % 达到建仓的条件，upcouter重新计数
                    l_opdays(l_days(l_gapid))=3;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid)); 
                    l_isop=1;
                end
            end           
        end
    else
        % 又从0点开始计算,前一天平仓
        if l_isop
            l_cpdays(l_lastid+1)=5;
            l_isop=0;
        end
        if (min(g_rawdata.pair(in_pairid).mkdata.vl(l_days(l_gapid),:))>=100)
            l_opdays(l_days(l_gapid))=1;
            l_isop=1;
        end
        l_upcounter=0;
        l_lastupcpgap=l_cpgap(l_days(l_gapid));
        l_downcounter=0;
        l_lastdowncpgap=l_cpgap(l_days(l_gapid));         
    end
    l_lastid=l_days(l_gapid);    
end

% 最后一个交易日，不可以建仓
if l_isop
    if (l_opdays(end)>0)
        l_opdays(end)=0;
    elseif l_days(end)==g_rawdata.pair(in_pairid).datalen
        l_cpdays(end)=16;
    else
        l_cpdays(l_days(end)+1)=5;
    end
end
g_tradedata(in_pairid).caculation(in_calulationid).opdays=l_opdays;
g_tradedata(in_pairid).caculation(in_calulationid).cpdays=l_cpdays;












