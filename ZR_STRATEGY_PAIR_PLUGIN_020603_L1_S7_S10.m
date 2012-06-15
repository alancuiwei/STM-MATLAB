function out_traderecord=ZR_STRATEGY_PAIR_PLUGIN_020603_L1_S7_S10(in_inputdata)
% ���Ӣ���Ĳ���:020601

SUB_ComputeIndicatorPerPair(in_inputdata);
% ������Ե�����
SUB_ComputeStrategyDataPerPair(in_inputdata);
% ���׼�¼����
out_traderecord=SUB_ComputeRecordDataPerPair(in_inputdata);


function SUB_ComputeIndicatorPerPair(in_inputdata)
%%%%%%%% ���������Ե�ָ����Ϣ
global g_indicatordata;
% ���ò���
g_indicatordata=[];
l_period=in_inputdata.strategyparms.period;
l_periodmin=round(l_period/2)+1;
if (in_inputdata.pair.datalen>l_period)
    % l_periodmin=l_period;
    % ����gapΪ��ʱ�ģ������ڵ����ֵ
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    l_cpgapdata(l_cpgapdata>0)=0;
    g_indicatordata.pair.negativemaxgap=-TA_MAX(abs(l_cpgapdata),l_period).*(l_cpgapdata<0);
    % ����gap�����ڵ����ֵ,�Լ����ֵʱ��index
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    g_indicatordata.pair.maxgap=TA_MAX(l_cpgapdata,l_periodmin);
    g_indicatordata.pair.maxgapid=TA_MAXINDEX(l_cpgapdata,l_periodmin)+1;
    % ����������gapΪ���ֵʱ�����ں�Զ�ڵļ۸�
    g_indicatordata.pair.gapmaxprice(:,1)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.maxgapid,1);
    g_indicatordata.pair.gapmaxprice(:,2)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.maxgapid,2);

    g_indicatordata.pair.ATR=min(in_inputdata.commodity.info.tick)*ones(in_inputdata.pair.datalen,1);
    g_indicatordata.pair.serial=(TA_MA(double(in_inputdata.pair.mkdata.cpgap<0),l_period)>=1);
    g_indicatordata.pair.isallowed=(min(in_inputdata.pair.mkdata.vl,[],2)>=100);
else
    % l_periodmin=l_period;
    % ����gapΪ��ʱ�ģ������ڵ����ֵ
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    l_cpgapdata(l_cpgapdata>0)=0;
    g_indicatordata.pair.negativemaxgap=zeros(size(l_cpgapdata));
    % ����gap�����ڵ����ֵ,�Լ����ֵʱ��index
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    g_indicatordata.pair.maxgap=zeros(size(l_cpgapdata));
    g_indicatordata.pair.maxgapid=ones(size(l_cpgapdata));
    % ����������gapΪ���ֵʱ�����ں�Զ�ڵļ۸�
    g_indicatordata.pair.gapmaxprice(:,1)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.maxgapid,1);
    g_indicatordata.pair.gapmaxprice(:,2)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.maxgapid,2);

    g_indicatordata.pair.ATR=min(in_inputdata.commodity.info.tick)*ones(in_inputdata.pair.datalen,1);
    g_indicatordata.pair.serial=zeros(size(l_cpgapdata));
    g_indicatordata.pair.isallowed=zeros(size(l_cpgapdata));
end

function SUB_ComputeStrategyDataPerPair(in_inputdata)
%%%%%%%% �����ײ����������
global g_indicatordata;
global g_strategydata;
g_strategydata=[];
% global g_commodityparams;
% ��¼��Զ�ڼ۸�Ƚϣ�gap�����Сֵ�ĵ�
g_strategydata.isnegativemaxgappoint=(g_indicatordata.pair.negativemaxgap==in_inputdata.pair.mkdata.cpgap);
g_strategydata.isn2rpricehigher=(in_inputdata.pair.mkdata.cpgap>0);
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
% ����1b����Ĳ�������,������γ�������Զ�ں�Լ���Ƿ��ȱȽ��ڴ�����
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
%%%%%%%% ���㽻������
global g_tradecaculation;
% ���ò���
l_traderecord=[];
g_tradecaculation.caculationnum=1;
% ִ���������
SUB_TradeCalculationPeriodly(in_inputdata,1,11);
% ��¼�������
l_posid=0;
% �����������numֵ�ж��Ƿ��п���
% l_traderecord.name=in_inputdata.pair.name;
for l_caculationid=1:g_tradecaculation.caculationnum
    if(~isempty(g_tradecaculation(l_caculationid).result.trademap))
        for l_index=1:length(g_tradecaculation(l_caculationid).result.trademap(:,1))
            % pos��trade��������1
            l_posid=l_posid+1;
            % ƽ�ֵ��ͣ�ֵ�
            l_cspid=find(g_tradecaculation(l_caculationid).result.trademap(l_index,:)>=4,1);
            % pos
            % ����
            l_traderecord.name(l_posid)=in_inputdata.pair.name;
            l_traderecord.direction(l_posid)=1; %1�������࣬-1��������
            l_traderecord.opdate(l_posid)=...
                in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1));
            l_traderecord.cpdate(l_posid)=....
                in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));  
            l_traderecord.isclosepos(l_posid)=~(g_tradecaculation(l_caculationid).result.trademap(l_index,l_cspid)==32);
            % ����ʱ�ļ۸�
            l_traderecord.opdateprice(l_posid)=...
                in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1));
            % ƽ��ʱ�ļ۸�
            l_traderecord.cpdateprice(l_posid)=...
                in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));              
            % ����мӲֵ�
            l_apid=find(g_tradecaculation(l_caculationid).result.trademap(l_index,:)==2,1);
            if(~isempty(l_apid))
                l_posid=l_posid+1;
                l_traderecord.name(l_posid)=in_inputdata.pair.name;
                l_traderecord.direction(l_posid)=1; %1�������࣬-1��������
                l_traderecord.opdate(l_posid)=...
                    in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid));
                l_traderecord.cpdate(l_posid)=....
                    in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));  
                l_traderecord.isclosepos(l_posid)=~(g_tradecaculation(l_caculationid).result.trademap(l_index,l_cspid)==32);
                % ����ʱ�ļ۸�
                l_traderecord.opdateprice(l_posid)=...
                    in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid));
                % ƽ��ʱ�ļ۸�
                l_traderecord.cpdateprice(l_posid)=...
                    in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));                 
            end
        end
    end
end
out_traderecord=l_traderecord;

function SUB_TradeCalculationPeriodly(in_inputdata,in_calulationid,in_strategytype)
%%%%%%%% ��������,��������������
global g_tradecaculation;
global g_indicatordata;
global g_strategydata;

% l_currentdate=in_inputdata.currentdate;
% l_iscurrentdate=0;
% if strcmp(in_inputdata.pair.mkdata.date(end),l_currentdate);
%     l_iscurrentdate=1;
% end
% ���ò���
l_period=round(in_inputdata.strategyparms.period/2)+1;
l_losses=in_inputdata.strategyparms.losses;
l_wins=in_inputdata.strategyparms.wins;
g_tradecaculation(in_calulationid).type=in_strategytype;
if (in_inputdata.pair.datalen<in_inputdata.strategyparms.period)
    g_tradecaculation(in_calulationid).result.trademap=[];
    return;
end
% ����ʱ��ͼ
l_primaryindexmap=ZR_FUN_ComputeDaysMap(in_inputdata.pair.datalen,l_period);
g_tradecaculation(in_calulationid).primary.indexmap=l_primaryindexmap;
% ���ܽ����ӡ�ƽ�ֵ㣬l_wins����ƽ������Խ��ƽ�ֿ���ԽС
l_premax=g_indicatordata.pair.maxgap;
switch in_strategytype
    case 11
        % ���ܽ��ֵ�
        l_maybeopdays=g_strategydata.case1a.ismatched;
%         if ~l_iscurrentdate
%           l_maybeopdays(end-l_period:end)=0;      
%         end
    case 12
        % ���ܽ��ֵ�
        l_maybeopdays=g_strategydata.case1b.ismatched;
        % l_maybeopdays(end-l_period:end)=0;
end
% ���ܽ��ֵ�
g_tradecaculation(in_calulationid).primary.opdaysmap=l_maybeopdays(l_primaryindexmap);    
% ���ܼӲֵ�,�ٴ����㽨������
g_tradecaculation(in_calulationid).primary.apdaysmap=...
    ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)...
    -imresize_old(in_inputdata.pair.mkdata.cpgap,size(l_primaryindexmap)))<0);
g_tradecaculation(in_calulationid).primary.apdaysmap=...
    g_tradecaculation(in_calulationid).primary.apdaysmap&g_tradecaculation(in_calulationid).primary.opdaysmap;
% ����ƽ��
g_tradecaculation(in_calulationid).primary.cpdaysmap=...
    ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)-imresize_old(l_premax,size(l_primaryindexmap)))...
            >(l_wins*g_indicatordata.pair.ATR(1)));
% ͣ�ֵ�
g_tradecaculation(in_calulationid).primary.spdaysmap=zeros(size(l_primaryindexmap));
% result ���׽��
% ȡ�����п��ܵĽ��ֵ�
l_maybeopdayids=find(l_maybeopdays>0);
g_tradecaculation(in_calulationid).result.opdaynum=length(l_maybeopdayids);
% ����ʱ��ͼ������g_trade.indexmap��ģ�
g_tradecaculation(in_calulationid).result.indexmap=g_tradecaculation(in_calulationid).primary.indexmap(l_maybeopdayids,:);

% ���֣��Ƚ����ܽ��ֵ��ͼ��������ͼ��,������Ϊ������޳�
g_tradecaculation(in_calulationid).result.opdaysmap=...
    g_tradecaculation(in_calulationid).primary.opdaysmap(g_tradecaculation(in_calulationid).result.indexmap);
% �Ӳ֣�2����ʼ����һ�У�Ŀ�ı���ͽ�����Ϣ����
g_tradecaculation(in_calulationid).result.apdaysmap=...
    2*g_tradecaculation(in_calulationid).primary.apdaysmap(g_tradecaculation(in_calulationid).result.indexmap(:,1),:);
g_tradecaculation(in_calulationid).result.apdaysmap(:,1)=0;
% ƽ�֣�4
g_tradecaculation(in_calulationid).result.cpdaysmap=...
    4*g_tradecaculation(in_calulationid).primary.cpdaysmap(g_tradecaculation(in_calulationid).result.indexmap(:,1),:);
g_tradecaculation(in_calulationid).result.cpdaysmap(:,1)=0;
% ���֣�8
g_tradecaculation(in_calulationid).result.spdaysmap=...
    8*g_tradecaculation(in_calulationid).primary.spdaysmap(g_tradecaculation(in_calulationid).result.indexmap);
g_tradecaculation(in_calulationid).result.spdaysmap(:,1)=0;
% �����������
% �������п��ܵĽ��ֵ㣬��ʱ�����������õľ���
for l_index=1:g_tradecaculation(in_calulationid).result.opdaynum  
    % �����һ��Ϊ�㣬�����ǽ��ֵ㣬���Լ���
    if(g_tradecaculation(in_calulationid).result.opdaysmap(l_index,1)==0)
        continue;
    end
    % ��¼��һ�μӲֵ㣬���֮��ļӲֵ㣻û�мӲֵ㣬���¼Ϊ0
    l_apid=find(g_tradecaculation(in_calulationid).result.apdaysmap(l_index,:),1);  
    if (isempty(l_apid)||(l_apid>=l_period))
        % ������û�мӲֵ�
        l_apid=0;
        g_tradecaculation(in_calulationid).result.apdaysmap(l_index,:)=0;
    else
        g_tradecaculation(in_calulationid).result.apdaysmap(l_index,(l_apid+1):l_period)=0;
    end
    % ��¼��һ��ƽ�ֵ㣬���֮���ƽ�ֵ㣬û��ƽ�ֵ㣬���¼Ϊ0
    l_cpid=find(g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,:),1); 
    if (isempty(l_cpid)||(l_cpid>=l_period))
        % ������û�мӲֵ�
        l_cpid=0;
        g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,:)=0;
    else
        g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,(l_cpid+1):l_period)=0;
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
    % ���û��ƽ�ֵ��ͣ�ֵ㣬ʱ��ƽ�֣�16
    if((l_cpid==0)&&(l_spid==0))        
        g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,l_period)=16;
        % ������ֻ����һ�ν���
        l_opdays=find(g_tradecaculation(in_calulationid).result.opdaysmap(l_index,2:l_period));
        if(~isempty(l_opdays))
            g_tradecaculation(in_calulationid).result.opdaysmap(l_index+(1:length(l_opdays)),1)=0;  
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
                g_tradecaculation(in_calulationid).result.cpdaysmap(l_index,:)=0;
            else
                l_end=l_cpid;
                g_tradecaculation(in_calulationid).result.spdaysmap(l_index,:)=0;
            end
        end 
        % ����Ӳֵ���ƽ�ֵ�֮������Ч
        if(l_apid>=l_end)
            g_tradecaculation(in_calulationid).result.apdaysmap(l_index,:)=0;
        end
        % û��ƽ�ֺ�ͣ�ֵ�����£�������ֻ����һ�ν���
        l_opdays=find(g_tradecaculation(in_calulationid).result.opdaysmap(l_index,2:l_end));
        if(~isempty(l_opdays))
            g_tradecaculation(in_calulationid).result.opdaysmap(l_index+(1:length(l_opdays)),1)=0;  
        end
    end
    g_tradecaculation(in_calulationid).result.opdaysmap(l_index,2:l_period)=0; 
end

% �޳��Ƿ����ֵ�
l_resultindex=find(g_tradecaculation(in_calulationid).result.opdaysmap(:,1));
% ���Ӽ�ƽ�ֵ���ӵõ�trademap
g_tradecaculation(in_calulationid).result.trademap=g_tradecaculation(in_calulationid).result.opdaysmap(l_resultindex,:)...
    +g_tradecaculation(in_calulationid).result.apdaysmap(l_resultindex,:)...
    +g_tradecaculation(in_calulationid).result.cpdaysmap(l_resultindex,:)...
    +g_tradecaculation(in_calulationid).result.spdaysmap(l_resultindex,:); 
% �����յ�id
g_tradecaculation(in_calulationid).result.tddaysmap=g_tradecaculation(in_calulationid).result.indexmap(l_resultindex,:);
if ~isempty(g_tradecaculation(in_calulationid).result.tddaysmap)
    if(in_inputdata.pair.info.daystolasttradedate>0)
        % ��������һ�������н��֣���Ϊ�Ƿ�
        if (in_inputdata.pair.info.daystolasttradedate<=l_period)
            % �Ƿ����һ�������н���
            g_tradecaculation(in_calulationid).result.trademap(...
                g_tradecaculation(in_calulationid).result.tddaysmap(:,1)>=...
                (in_inputdata.pair.datalen-in_inputdata.pair.info.daystolasttradedate),:)=[];
            g_tradecaculation(in_calulationid).result.tddaysmap(...
                g_tradecaculation(in_calulationid).result.tddaysmap(:,1)>=...
                (in_inputdata.pair.datalen-in_inputdata.pair.info.daystolasttradedate),:)=[];        
            % l_resultindex(l_lastop)=[];
        end   
        % ���һ�ν��ף��������ٽ�������һ�������ڣ�
        l_lastperiod=g_tradecaculation(in_calulationid).result.tddaysmap(end,1)-(in_inputdata.pair.datalen-l_period+1);
        if (l_lastperiod>0)...
                &&((sum(g_tradecaculation(in_calulationid).result.trademap(end,(end-l_lastperiod+1):end)>=4)>0)...
                ||(g_tradecaculation(in_calulationid).result.tddaysmap(end,1)==in_inputdata.pair.datalen))
            g_tradecaculation(in_calulationid).result.trademap(end,...
                g_tradecaculation(in_calulationid).result.trademap(end,:)>=4)=32;
        end  
    else
        % �Ƿ����һ�������н���
        g_tradecaculation(in_calulationid).result.trademap(...
            g_tradecaculation(in_calulationid).result.tddaysmap(:,1)>=...
            (in_inputdata.pair.datalen-l_period),:)=[];
        g_tradecaculation(in_calulationid).result.tddaysmap(...
            g_tradecaculation(in_calulationid).result.tddaysmap(:,1)>=...
            (in_inputdata.pair.datalen-l_period),:)=[];           
    end
end

% �����յ�id
g_tradecaculation(in_calulationid).result.tddaysmap=g_tradecaculation(in_calulationid).result.indexmap(l_resultindex,:);

% function out_trade=SUB_TradeCalculation(in_pairid,in_calulationid,in_strategytype)










