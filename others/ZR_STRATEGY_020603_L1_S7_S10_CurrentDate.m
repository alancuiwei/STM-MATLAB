function ZR_STRATEGY_020603_L1_S7_S10_CurrentDate(varargin)
% ���Ӣ���Ĳ���:010601

% �õ���ȫ�ֱ���
global g_commoditynames;
global g_rawdata;
global g_coredata;
% ���ò��Բ���
SUB_SetStrategyParams(varargin{:});
% ���û�к�Լ��������Ϣ������G_RunSpecialTestCase�еĺ�Լ����
if isempty(g_commoditynames)
    error('��Լ���б�û�г�ʼ��');
end
%%%% �㷨����
l_cmnum=length(g_commoditynames);
% ����һ���������һ��
for l_cmid=1:l_cmnum         
    % ÿһ��Ʒ�ֳ�ʼ��
    SUB_InitGlobalVarsPerCommodity();
    g_rawdata=g_coredata(l_cmid);
    % ����ÿһ��Ʒ�����ò��Բ���
    ZR_FUN_SetParamsPerCommodity(l_cmid);
    % �õ�ͬƷ�ֺ�Լ������
    l_pairnum=length(g_rawdata.pair);
    % ����ͬƷ������������
    for l_pairid=1:l_pairnum
        % �����Լ��ָ��
        SUB_ComputeIndicatorPerPair(l_pairid);
        % ������Ե�����
        SUB_ComputeStrategyDataPerPair(l_pairid);
        % ��������
        SUB_ComputeTradeDataPerPair(l_pairid);
    end
    % ���㱨������
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
    % ���潻�׵�ͼ��
    ZR_FUN_SaveTradeBarPerCommodity();
end
% �������
ZR_PROCESS_CollectReport();

function SUB_SetStrategyParams(varargin)
%%%%%%%% ���ò��Բ���
global g_strategyparams;
global g_commoditynames;
% ������ֵ���Ż�ִ��ʱ�Żᴫ�����
if(nargin>0)
    % Ĭ����ÿ����Ʒ�µ�һ��
    g_strategyparams.handnum=ones(1,length(g_commoditynames)); 
    l_commandstr='';
    for l_paramid=1:(nargin/2)   
        l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_commoditynames)); ');
    end
    eval(l_commandstr);
end

function SUB_InitGlobalVarsPerCommodity()
%%%%%%%% ÿһ��Ʒ�ֳ�ʼ��
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
%%%%%%%% �����Լ��ָ����Ϣ
global g_indicatordata;
g_indicatordata.contract(in_ctid)=0;

function SUB_ComputeIndicatorPerPair(in_pairid)
%%%%%%%% ���������Ե�ָ����Ϣ
global g_rawdata;
global g_indicatordata;
global g_commodityparams;
% ���ò���
l_period=g_commodityparams.period;
l_periodmin=round(l_period/2)+1;
if (g_rawdata.pair(in_pairid).datalen>l_period)
    % l_periodmin=l_period;
    % ����gapΪ��ʱ�ģ������ڵ����ֵ
    l_cpgapdata=g_rawdata.pair(in_pairid).mkdata.cpgap;
    l_cpgapdata(l_cpgapdata>0)=0;
    g_indicatordata.pair(in_pairid).negativemaxgap=-TA_MAX(abs(l_cpgapdata),l_period).*(l_cpgapdata<0);
    % ����gap�����ڵ����ֵ,�Լ����ֵʱ��index
    l_cpgapdata=g_rawdata.pair(in_pairid).mkdata.cpgap;
    g_indicatordata.pair(in_pairid).maxgap=TA_MAX(l_cpgapdata,l_periodmin);
    g_indicatordata.pair(in_pairid).maxgapid=TA_MAXINDEX(l_cpgapdata,l_periodmin)+1;
    % ����������gapΪ���ֵʱ�����ں�Զ�ڵļ۸�
    g_indicatordata.pair(in_pairid).gapmaxprice(:,1)=g_rawdata.pair(in_pairid).mkdata.cp(g_indicatordata.pair(in_pairid).maxgapid,1);
    g_indicatordata.pair(in_pairid).gapmaxprice(:,2)=g_rawdata.pair(in_pairid).mkdata.cp(g_indicatordata.pair(in_pairid).maxgapid,2);
    % ����������gap�ľ�ֵ
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
    % ����gapΪ��ʱ�ģ������ڵ����ֵ
    l_cpgapdata=g_rawdata.pair(in_pairid).mkdata.cpgap;
    l_cpgapdata(l_cpgapdata>0)=0;
    g_indicatordata.pair(in_pairid).negativemaxgap=zeros(size(l_cpgapdata));
    % ����gap�����ڵ����ֵ,�Լ����ֵʱ��index
    l_cpgapdata=g_rawdata.pair(in_pairid).mkdata.cpgap;
    g_indicatordata.pair(in_pairid).maxgap=zeros(size(l_cpgapdata));
    g_indicatordata.pair(in_pairid).maxgapid=ones(size(l_cpgapdata));
    % ����������gapΪ���ֵʱ�����ں�Զ�ڵļ۸�
    g_indicatordata.pair(in_pairid).gapmaxprice(:,1)=g_rawdata.pair(in_pairid).mkdata.cp(g_indicatordata.pair(in_pairid).maxgapid,1);
    g_indicatordata.pair(in_pairid).gapmaxprice(:,2)=g_rawdata.pair(in_pairid).mkdata.cp(g_indicatordata.pair(in_pairid).maxgapid,2);
    % ����������gap�ľ�ֵ
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
%%%%%%%% �����ײ����������
global g_indicatordata;
global g_rawdata;
global g_strategydata;
% global g_commodityparams;
% ��¼��Զ�ڼ۸�Ƚϣ�gap�����Сֵ�ĵ�
g_strategydata(in_pairid).isnegativemaxgappoint=(g_indicatordata.pair(in_pairid).negativemaxgap==g_rawdata.pair(in_pairid).mkdata.cpgap);
g_strategydata(in_pairid).isn2rpricehigher=(g_rawdata.pair(in_pairid).mkdata.cpgap>0);
% ���ں�Լ���Ƿ���Զ�ں�Լ�Ƿ�����Զ���Ƿ��ıȽϣ�ÿһ���������ͼ��㷽��������ͬ
%  ���	���ڼ۸�>Զ�ڼ۸�	���ڼ۸��Ƿ�����	Զ�ڼ۸��Ƿ�����	�����ڼ۱仯����>Զ�ڼ۸�仯����	����
%   1  |	      ��       |	       ��      |	       ��       |	              ��              |	 2
%   2  |	      ��       |	       ��      |	       ��       |	              ��              |	 1a
%   3  |	      ��       |	       ��      |	       ��       |	              ��              |	 1b
%   4  |	      ��       |	       ��      |	       ��       |	              ��              |	 1b
%   5  |	      ��       |	       ��      |	       ��       |	              ��              |	 2
%   6  |	      ��       |	       ��      |	       ��       |	              ��              |	 2
%   7  |	      ��       |	       ��      |	       ��       |	              ��              |	 1b
%   8  |	      ��       |	       ��      |	       ��       |	              ��              |	 2
%   9  |	      ��       |	       ��      |	       ��       |	              ��              |	 4
%   10 |	      ��       |	       ��      |	       ��       |	              ��              |	 3
%   11 |	      ��       |	       ��      |	       ��       |	              ��              |	 3
%   12 |	      ��       |	       ��      |	       ��       |	              ��              |	 3
%   13 |	      ��       |	       ��      |	       ��       |	              ��              |	 4
%   14 |	      ��       |	       ��      |	       ��       |	              ��              |	 4
%   15 |	      ��       |	       ��      |	       ��       |	              ��              |	 3
%   16 |	      ��       |	       ��      |	       ��       |	              ��              |	 4
% ����1a����Ĳ�������,������γ�������Զ�ں�Լ�µ����ȱȽ���С�����
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
% ����1b����Ĳ�������,������γ�������Զ�ں�Լ���Ƿ��ȱȽ��ڴ�����
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
%%%%%%%% ���㽻������
global g_rawdata;
global g_tradedata;
global g_commodityparams;
global g_strategydata;
% ���ò���
l_handnum=g_commodityparams.handnum;
g_tradedata(in_pairid).caculationnum=1;
% ���׵�λ
l_tradeunit(1)=g_rawdata.commodity.info(1).tradeunit*l_handnum;
l_tradeunit(2)=g_rawdata.commodity.info(2).tradeunit*l_handnum;
% % �Ƿ񵥱���ȡ��֤��
% if(g_rawdata.commodity.info.issinglemargin)
%     l_tradenum=1;
% else
%     l_tradenum=2;
% end
% ��֤�����
l_margin(1)=g_rawdata.commodity.info(1).margin;
l_margin(2)=g_rawdata.commodity.info(2).margin;
% ����������
l_tradecharge(1)=g_rawdata.commodity.info(1).tradecharge*l_handnum;
l_tradecharge(2)=g_rawdata.commodity.info(2).tradecharge*l_handnum;
% l_tradecharge=0;
% ִ���������
SUB_TradeCalculationPeriodly(in_pairid,1,11);
% SUB_TradeCalculationPeriodly(in_pairid,2,12);
% ��¼�������
% �����¿�ʼ����
% ��������
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
% �����������numֵ�ж��Ƿ��п���
g_tradedata(in_pairid).pos.num=[];
g_tradedata(in_pairid).trade.num=[];  
g_tradedata(in_pairid).pos.name=g_rawdata.pair(in_pairid).name;
g_tradedata(in_pairid).trade.name=g_rawdata.pair(in_pairid).name;
for l_caculationid=1:g_tradedata(in_pairid).caculationnum
    if(~isempty(g_tradedata(in_pairid).caculation(l_caculationid).result.trademap))
        for l_index=1:length(g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(:,1))
            % pos��trade��������1
            l_posid=l_posid+1;
            l_tradeid=l_tradeid+1;
            % ƽ�ֵ��ͣ�ֵ�
            l_cspid=find(g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(l_index,:)>=4,1);
            % pos
            % ����
            g_tradedata(in_pairid).pos.name(l_posid)=g_rawdata.pair(in_pairid).name;
            g_tradedata(in_pairid).pos.rightid(l_posid)={g_rawdata.pair(in_pairid).rightid};
            % ��������
%             g_tradedata(in_pairid).pos.type(l_posid)=g_tradedata(in_pairid).caculation(l_caculationid).type; 
            g_tradedata(in_pairid).pos.type(l_posid)=g_strategydata(in_pairid).type(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1));
            % ��������
            g_tradedata(in_pairid).pos.opdate(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.date(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1));
            % ��������
            g_tradedata(in_pairid).pos.optype(l_posid)=1;
            % ����ʱ�ļ۲�
            g_tradedata(in_pairid).pos.opdategap(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1));
            % ����ʱ�Ľ��ں�Լ������
            g_tradedata(in_pairid).pos.opgapvl1(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1),1);
            % ����ʱ��Զ�ں�Լ������
            g_tradedata(in_pairid).pos.opgapvl2(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,1),2);              
            % ƽ�ֻ�ͣ�ֵ�����
            g_tradedata(in_pairid).pos.cpdate(l_posid)=....
                g_rawdata.pair(in_pairid).mkdata.date(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
            % ƽ�ֻ�ͣ�ֵ�����
            g_tradedata(in_pairid).pos.cptype(l_posid)=g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(l_index,l_cspid);  
            % �Ƿ�ʵ��ƽ��
            g_tradedata(in_pairid).pos.isclosepos(l_posid)=~(g_tradedata(in_pairid).pos.cptype(l_posid)==32);
            % ƽ�ֻ�ͣ�ֵļ۲�
            g_tradedata(in_pairid).pos.cpdategap(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
            % ƽ��ʱ�Ľ��ں�Լ������
            g_tradedata(in_pairid).pos.cpgapvl1(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1);
            % ƽ��ʱ��Զ�ں�Լ������
            g_tradedata(in_pairid).pos.cpgapvl2(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2); 
            % ��֤��
            g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
                *g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1)...
                +l_tradeunit(2)*l_margin(2)...
                *g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2));
            % ����������
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
            % �ôβ�λ����ƽ�ֻ�ͣ�ֵļ۲�-����ʱ�ļ۲����ͳһ�������Ч��
            g_tradedata(in_pairid).pos.gapdiff(l_posid)=g_tradedata(in_pairid).pos.cpdategap(l_posid)-g_tradedata(in_pairid).pos.opdategap(l_posid);
            % �ôβ�λ�����棬����ͳһ�������Ч��
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
            % ������
            g_tradedata(in_pairid).trade.name(l_tradeid)=g_rawdata.pair(in_pairid).name;
            % ��������
            g_tradedata(in_pairid).trade.type(l_tradeid)=g_tradedata(in_pairid).pos.type(l_posid);
            % ���׿�ʼ����
            g_tradedata(in_pairid).trade.opdate(l_tradeid)=g_tradedata(in_pairid).pos.opdate(l_posid);
            % ���׽�������            
            g_tradedata(in_pairid).trade.cpdate(l_tradeid)=g_tradedata(in_pairid).pos.cpdate(l_posid);
            if datenum(g_tradedata(in_pairid).trade.cpdate(l_tradeid))>l_lastdatenum
                g_tradedata(in_pairid).trade.type(l_tradeid)=g_tradedata(in_pairid).pos.type(l_posid)+100;
            end
            % �Ƿ�ʵ��ƽ��
            g_tradedata(in_pairid).trade.isclosepos(l_tradeid)=g_tradedata(in_pairid).pos.isclosepos(l_posid);
            % ���׵������м۲���ۼ�
            g_tradedata(in_pairid).trade.gapdiff(l_tradeid)=g_tradedata(in_pairid).pos.gapdiff(l_posid);
            % һ�ֽ��׵Ĳ�λ��
            g_tradedata(in_pairid).trade.posnum(l_tradeid)=1;
            % һ�ֽ��׵�����
            g_tradedata(in_pairid).trade.profit(l_tradeid)=g_tradedata(in_pairid).pos.profit(l_posid);  
            % ����мӲֵ�
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
                g_tradedata(in_pairid).pos.optype(l_posid)=2;  % �Ӳ�type
                g_tradedata(in_pairid).pos.opdategap(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid)); 
                % ����ʱ�Ľ��ں�Լ������
                g_tradedata(in_pairid).pos.opgapvl1(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid),1);
                % ����ʱ��Զ�ں�Լ������
                g_tradedata(in_pairid).pos.opgapvl2(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_apid),2); 
                g_tradedata(in_pairid).pos.cpdate(l_posid)=....
                    g_rawdata.pair(in_pairid).mkdata.date(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
                g_tradedata(in_pairid).pos.cptype(l_posid)=g_tradedata(in_pairid).caculation(l_caculationid).result.trademap(l_index,l_cspid);
                % �Ƿ�ʵ��ƽ��
                g_tradedata(in_pairid).pos.isclosepos(l_posid)=~(g_tradedata(in_pairid).pos.cptype(l_posid)==32);                
                g_tradedata(in_pairid).pos.cpdategap(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.cpgap(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
                % ƽ��ʱ�Ľ��ں�Լ������
                g_tradedata(in_pairid).pos.cpgapvl1(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1);
                % ƽ��ʱ��Զ�ں�Լ������
                g_tradedata(in_pairid).pos.cpgapvl2(l_posid)=...
                    g_rawdata.pair(in_pairid).mkdata.vl(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2);
                % ��֤��
                g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
                    *g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1)...
                    +l_tradeunit(2)*l_margin(2)...
                    *g_rawdata.pair(in_pairid).mkdata.cp(g_tradedata(in_pairid).caculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2));         
                % ����������
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
                % �ôβ�λ�����棬����ͳһ�������Ч��
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
                % �Ƿ�ʵ��ƽ��
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
%%%%%%%% ��������,��������������
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
% ���ò���
l_period=round(g_commodityparams.period/2)+1;
l_losses=g_commodityparams.losses;
l_wins=g_commodityparams.wins;
g_tradedata(in_pairid).caculation(in_calulationid).type=in_strategytype;
if (g_rawdata.pair(in_pairid).datalen<g_commodityparams.period)
    g_tradedata(in_pairid).caculation(in_calulationid).result.trademap=[];
    return;
end
% ����ʱ��ͼ
l_primaryindexmap=ZR_FUN_ComputeDaysMap(g_rawdata.pair(in_pairid).datalen,l_period);
g_tradedata(in_pairid).caculation(in_calulationid).primary.indexmap=l_primaryindexmap;
% ���ܽ����ӡ�ƽ�ֵ㣬l_wins����ƽ������Խ��ƽ�ֿ���ԽС
l_premax=g_indicatordata.pair(in_pairid).maxgap;
switch in_strategytype
    case 11
        % ���ܽ��ֵ�
        l_maybeopdays=g_strategydata(in_pairid).case1a.ismatched;
        if ~l_iscurrentdate
          l_maybeopdays(end-l_period:end)=0;      
        end
    case 12
        % ���ܽ��ֵ�
        l_maybeopdays=g_strategydata(in_pairid).case1b.ismatched;
        % l_maybeopdays(end-l_period:end)=0;
end
% ���ܽ��ֵ�
g_tradedata(in_pairid).caculation(in_calulationid).primary.opdaysmap=l_maybeopdays(l_primaryindexmap);    
% ���ܼӲֵ�,�ٴ����㽨������
g_tradedata(in_pairid).caculation(in_calulationid).primary.apdaysmap=...
    ((g_rawdata.pair(in_pairid).mkdata.cpgap(l_primaryindexmap)...
    -imresize_old(g_rawdata.pair(in_pairid).mkdata.cpgap,size(l_primaryindexmap)))<0);
g_tradedata(in_pairid).caculation(in_calulationid).primary.apdaysmap=...
    g_tradedata(in_pairid).caculation(in_calulationid).primary.apdaysmap&g_tradedata(in_pairid).caculation(in_calulationid).primary.opdaysmap;
% ����ƽ��
g_tradedata(in_pairid).caculation(in_calulationid).primary.cpdaysmap=...
    ((g_rawdata.pair(in_pairid).mkdata.cpgap(l_primaryindexmap)-imresize_old(l_premax,size(l_primaryindexmap)))...
            >(l_wins*g_indicatordata.pair(in_pairid).ATR(1)));
% ͣ�ֵ�
g_tradedata(in_pairid).caculation(in_calulationid).primary.spdaysmap=zeros(size(l_primaryindexmap));
% result ���׽��
% ȡ�����п��ܵĽ��ֵ�
l_maybeopdayids=find(l_maybeopdays>0);
g_tradedata(in_pairid).caculation(in_calulationid).result.opdaynum=length(l_maybeopdayids);
% ����ʱ��ͼ������g_trade.indexmap��ģ�
g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap=g_tradedata(in_pairid).caculation(in_calulationid).primary.indexmap(l_maybeopdayids,:);

% ���֣��Ƚ����ܽ��ֵ��ͼ��������ͼ��,������Ϊ������޳�
g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap=...
    g_tradedata(in_pairid).caculation(in_calulationid).primary.opdaysmap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap);
% �Ӳ֣�2����ʼ����һ�У�Ŀ�ı���ͽ�����Ϣ����
g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap=...
    2*g_tradedata(in_pairid).caculation(in_calulationid).primary.apdaysmap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(:,1),:);
g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(:,1)=0;
% ƽ�֣�4
g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap=...
    4*g_tradedata(in_pairid).caculation(in_calulationid).primary.cpdaysmap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(:,1),:);
g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(:,1)=0;
% ���֣�8
g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap=...
    8*g_tradedata(in_pairid).caculation(in_calulationid).primary.spdaysmap(g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap);
g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap(:,1)=0;
% �����������
% �������п��ܵĽ��ֵ㣬��ʱ�����������õľ���
for l_index=1:g_tradedata(in_pairid).caculation(in_calulationid).result.opdaynum  
    % �����һ��Ϊ�㣬�����ǽ��ֵ㣬���Լ���
    if(g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index,1)==0)
        continue;
    end
    % ��¼��һ�μӲֵ㣬���֮��ļӲֵ㣻û�мӲֵ㣬���¼Ϊ0
    l_apid=find(g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_index,:),1);  
    if (isempty(l_apid)||(l_apid>=l_period))
        % ������û�мӲֵ�
        l_apid=0;
        g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_index,:)=0;
    else
        g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_index,(l_apid+1):l_period)=0;
    end
    % ��¼��һ��ƽ�ֵ㣬���֮���ƽ�ֵ㣬û��ƽ�ֵ㣬���¼Ϊ0
    l_cpid=find(g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,:),1); 
    if (isempty(l_cpid)||(l_cpid>=l_period))
        % ������û�мӲֵ�
        l_cpid=0;
        g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,:)=0;
    else
        g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,(l_cpid+1):l_period)=0;
    end    
    % ���ݵ�һ�μӲ֣�����ֹ��ͣ�ֵ�
    if(l_apid==0)
        l_spid=0;
    else
        % ���Ӳ���֮��ÿ���gap���Ӳ��յ�ǰ��gap���бȽ�
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
    % ���û��ƽ�ֵ��ͣ�ֵ㣬ʱ��ƽ�֣�16
    if((l_cpid==0)&&(l_spid==0))        
        g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_index,l_period)=16;
        % ������ֻ����һ�ν���
        l_opdays=find(g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index,2:l_period));
        if(~isempty(l_opdays))
            g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index+(1:length(l_opdays)),1)=0;  
        end
    else
        % ����ô�ƽ��ͣ�ֵ�֮��Ľ��ֵ㣬��һ�����⣻�������ж�ƽ�ֵ��ͣ�ֵ��Ⱥ�˳��
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
        % ����Ӳֵ���ƽ�ֵ�֮������Ч
        if(l_apid>=l_end)
            g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_index,:)=0;
        end
        % û��ƽ�ֺ�ͣ�ֵ�����£�������ֻ����һ�ν���
        l_opdays=find(g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index,2:l_end));
        if(~isempty(l_opdays))
            g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index+(1:length(l_opdays)),1)=0;  
        end
    end
    g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_index,2:l_period)=0; 
end

% �޳��Ƿ����ֵ�
l_resultindex=find(g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(:,1));
% ���Ӽ�ƽ�ֵ���ӵõ�trademap
g_tradedata(in_pairid).caculation(in_calulationid).result.trademap=g_tradedata(in_pairid).caculation(in_calulationid).result.opdaysmap(l_resultindex,:)...
    +g_tradedata(in_pairid).caculation(in_calulationid).result.apdaysmap(l_resultindex,:)...
    +g_tradedata(in_pairid).caculation(in_calulationid).result.cpdaysmap(l_resultindex,:)...
    +g_tradedata(in_pairid).caculation(in_calulationid).result.spdaysmap(l_resultindex,:); 
% �����յ�id
g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap=g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_resultindex,:);
if ~isempty(g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap)&&l_iscurrentdate
    % ��������һ�������н��֣���Ϊ�Ƿ�
    if ((g_rawdata.pair(in_pairid).info.daystolasttradedate>0)&&(g_rawdata.pair(in_pairid).info.daystolasttradedate<=l_period))
        % �Ƿ����һ�������н���
        g_tradedata(in_pairid).caculation(in_calulationid).result.trademap(...
            g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(:,1)>=...
            (g_rawdata.pair(in_pairid).datalen-g_rawdata.pair(in_pairid).info.daystolasttradedate),:)=[];
        g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(...
            g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(:,1)>=...
            (g_rawdata.pair(in_pairid).datalen-g_rawdata.pair(in_pairid).info.daystolasttradedate),:)=[];        
        % l_resultindex(l_lastop)=[];
    end   
    % ���һ�ν��ף��������ٽ�������һ�������ڣ�
    if (g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(end,1)>(g_rawdata.pair(in_pairid).datalen-l_period+1))...
            &&((g_tradedata(in_pairid).caculation(in_calulationid).result.trademap(end,end)==16)...
            ||(g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap(end,1)==g_rawdata.pair(in_pairid).datalen))
        g_tradedata(in_pairid).caculation(in_calulationid).result.trademap(end,...
            g_tradedata(in_pairid).caculation(in_calulationid).result.trademap(end,:)>=4)=32;
    end  
end

% �����յ�id
g_tradedata(in_pairid).caculation(in_calulationid).result.tddaysmap=g_tradedata(in_pairid).caculation(in_calulationid).result.indexmap(l_resultindex,:);

% function out_trade=SUB_TradeCalculation(in_pairid,in_calulationid,in_strategytype)









