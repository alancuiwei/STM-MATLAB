function out_traderecord=ZR_STRATEGY_010604(in_inputdata)
% ���Ӣ���Ĳ���:010604: ����2

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
l_periodhalf=round(l_period/2)+1;
if (in_inputdata.pair.datalen>l_period)
    % ����gapΪ��ʱ�ģ������ڵ���Сֵ
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    g_indicatordata.pair.negativemingap=-TA_MIN(abs(l_cpgapdata),l_period).*(l_cpgapdata<0);
    % ����gap�����ڵ����ֵ,�Լ����ֵʱ��index
    l_cpgapdata=in_inputdata.pair.mkdata.cpgap;
    g_indicatordata.pair.mingap=TA_MIN(l_cpgapdata,l_periodhalf);
    g_indicatordata.pair.mingapid=TA_MININDEX(l_cpgapdata,l_periodhalf)+1;
    % ����������gapΪ��Сֵʱ�����ں�Զ�ڵļ۸�
    g_indicatordata.pair.gapminprice(:,1)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.mingapid,1);
    g_indicatordata.pair.gapminprice(:,2)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.mingapid,2);
    % ����������gap�ľ�ֵ
    g_indicatordata.pair.ATR=min(in_inputdata.commodity.info.tick)*ones(in_inputdata.pair.datalen,1);
    % �Ƿ���������������
    g_indicatordata.pair.serial=(TA_MA(double(in_inputdata.pair.mkdata.cpgap<0),l_period)>=1);
    g_indicatordata.pair.isallowed=(min(in_inputdata.pair.mkdata.vl,[],2)>=100);
else
     % ����gapΪ��ʱ�ģ������ڵ���Сֵ
    g_indicatordata.pair.negativemingap=zeros(size(in_inputdata.pair.mkdata.cpgap));
    % ����gap�����ڵ����ֵ,�Լ����ֵʱ��index
    g_indicatordata.pair.mingap=zeros(size(in_inputdata.pair.mkdata.cpgap));
    g_indicatordata.pair.mingapid=ones(size(in_inputdata.pair.mkdata.cpgap));
    % ����������gapΪ��Сֵʱ�����ں�Զ�ڵļ۸�
    g_indicatordata.pair.gapminprice(:,1)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.mingapid,1);
    g_indicatordata.pair.gapminprice(:,2)=in_inputdata.pair.mkdata.cp(g_indicatordata.pair.mingapid,2);
    % ����������gap�ľ�ֵ
    g_indicatordata.pair.ATR=min(in_inputdata.commodity.info.tick)*ones(in_inputdata.pair.datalen,1);
    % �Ƿ���������������
    g_indicatordata.pair.serial=zeros(size(in_inputdata.pair.mkdata.cpgap));
    g_indicatordata.pair.isallowed=(min(in_inputdata.pair.mkdata.vl,[],2)>=100);   
end
function SUB_ComputeStrategyDataPerPair(in_inputdata)
%%%%%%%% �����ײ����������
global g_indicatordata;
global g_strategydata;
g_strategydata=[];
% global g_commodityparams;
% ��¼��Զ�ڼ۸�Ƚϣ�gap�����Сֵ�ĵ�
g_strategydata.isnegativemingappoint=(g_indicatordata.pair.negativemingap==in_inputdata.pair.mkdata.cpgap);
g_strategydata.isn2rpricehigher=(in_inputdata.pair.mkdata.cpgap>=0);
% ���ں�Լ���Ƿ���Զ�ں�Լ�Ƿ�����Զ���Ƿ��ıȽϣ�ÿһ���������ͼ��㷽��������ͬ
%  ���	���ڼ۸�>Զ�ڼ۸�	���ڼ۸��Ƿ�����	Զ�ڼ۸��Ƿ�����	�����ڼ۱仯����>Զ�ڼ۸�仯����	����
%   1  |	      ��       |	       ��      |	       ��       |	              ��              |	 2a
%   2  |	      ��       |	       ��      |	       ��       |	              ��              |	 1a
%   3  |	      ��       |	       ��      |	       ��       |	              ��              |	 1b
%   4  |	      ��       |	       ��      |	       ��       |	              ��              |	 1b
%   5  |	      ��       |	       ��      |	       ��       |	              ��              |	 2b
%   6  |	      ��       |	       ��      |	       ��       |	              ��              |	 2b
%   7  |	      ��       |	       ��      |	       ��       |	              ��              |	 1b
%   8  |	      ��       |	       ��      |	       ��       |	              ��              |	 2c
%   9  |	      ��       |	       ��      |	       ��       |	              ��              |	 4
%   10 |	      ��       |	       ��      |	       ��       |	              ��              |	 3
%   11 |	      ��       |	       ��      |	       ��       |	              ��              |	 3
%   12 |	      ��       |	       ��      |	       ��       |	              ��              |	 3
%   13 |	      ��       |	       ��      |	       ��       |	              ��              |	 4
%   14 |	      ��       |	       ��      |	       ��       |	              ��              |	 4
%   15 |	      ��       |	       ��      |	       ��       |	              ��              |	 3
%   16 |	      ��       |	       ��      |	       ��       |	              ��              |	 4
% ����2a����Ĳ�������
g_strategydata.case2a.pricechange(:,1)=in_inputdata.pair.mkdata.cp(:,1)-g_indicatordata.pair.gapminprice(:,1);
g_strategydata.case2a.pricechange(:,2)=in_inputdata.pair.mkdata.cp(:,2)-g_indicatordata.pair.gapminprice(:,2);
g_strategydata.case2a.n2rpricechangediff=g_strategydata.case2a.pricechange(:,1)-g_strategydata.case2a.pricechange(:,2);
g_strategydata.case2a.isnearpriceup=(g_strategydata.case2a.pricechange(:,1)>0);
g_strategydata.case2a.isremotepriceup=(g_strategydata.case2a.pricechange(:,2)>0);
g_strategydata.case2a.isn2rchangebigger=(abs(g_strategydata.case2a.pricechange(:,1))>abs(g_strategydata.case2a.pricechange(:,2)));
g_strategydata.case2a.ismatched=(g_strategydata.isnegativemingappoint)&(~g_strategydata.isn2rpricehigher)...
    &(~g_strategydata.case2a.isnearpriceup)&(~g_strategydata.case2a.isremotepriceup)&(~g_strategydata.case2a.isn2rchangebigger)...
    &g_indicatordata.pair.isallowed;
% ����2b����Ĳ�������
g_strategydata.case2b.pricechange(:,1)=in_inputdata.pair.mkdata.cp(:,1)-g_indicatordata.pair.gapminprice(:,1);
g_strategydata.case2b.pricechange(:,2)=in_inputdata.pair.mkdata.cp(:,2)-g_indicatordata.pair.gapminprice(:,2);
g_strategydata.case2b.n2rpricechangediff=g_strategydata.case2b.pricechange(:,1)-g_strategydata.case2b.pricechange(:,2);
g_strategydata.case2b.isnearpriceup=(g_strategydata.case2b.pricechange(:,1)>0);
g_strategydata.case2b.isremotepriceup=(g_strategydata.case2b.pricechange(:,2)>0);
g_strategydata.case2b.isn2rchangebigger=(abs(g_strategydata.case2b.pricechange(:,1))>abs(g_strategydata.case2b.pricechange(:,2)));
g_strategydata.case2b.ismatched=(g_strategydata.isnegativemingappoint)&(~g_strategydata.isn2rpricehigher)...
    &(g_strategydata.case2b.isnearpriceup)&(~g_strategydata.case2b.isremotepriceup)...
    &g_indicatordata.pair.isallowed;
% ����2c����Ĳ�������
g_strategydata.case2c.pricechange(:,1)=in_inputdata.pair.mkdata.cp(:,1)-g_indicatordata.pair.gapminprice(:,1);
g_strategydata.case2c.pricechange(:,2)=in_inputdata.pair.mkdata.cp(:,2)-g_indicatordata.pair.gapminprice(:,2);
g_strategydata.case2c.n2rpricechangediff=g_strategydata.case2c.pricechange(:,1)-g_strategydata.case2c.pricechange(:,2);
g_strategydata.case2c.isnearpriceup=(g_strategydata.case2c.pricechange(:,1)>0);
g_strategydata.case2c.isremotepriceup=(g_strategydata.case2c.pricechange(:,2)>0);
g_strategydata.case2c.isn2rchangebigger=(abs(g_strategydata.case2c.pricechange(:,1))>abs(g_strategydata.case2c.pricechange(:,2)));
g_strategydata.case2c.ismatched=(g_strategydata.isnegativemingappoint)&(~g_strategydata.isn2rpricehigher)...
    &(g_strategydata.case2c.isnearpriceup)&(g_strategydata.case2c.isremotepriceup)&(g_strategydata.case2c.isn2rchangebigger)...
    &g_indicatordata.pair.isallowed;
% ��������ϲ�
g_strategydata.type=21*g_strategydata.case2a.ismatched...
    +22*g_strategydata.case2b.ismatched...
    +23*g_strategydata.case2c.ismatched;
g_strategydata.case2a.ismatched=(g_strategydata.case2a.ismatched|g_strategydata.case2b.ismatched...
    |g_strategydata.case2c.ismatched);
%     &(in_inputdata.contract.mkdata.vl(in_inputdata.pair.mkdata.index(:,1))>=100)...

function SUB_ComputeTradeDataPerPair(in_pairid)
%%%%%%%% ���㽻������
global in_inputdata;
global g_tradecaculation;
global g_commodityparams;
global g_strategydata;
% ���ò���
l_handnum=g_commodityparams.handnum;
g_tradecaculation.caculationnum=1;
% ���׵�λ
l_tradeunit=in_inputdata.commodity.info.tradeunit*l_handnum;
% �Ƿ񵥱���ȡ��֤��
if(in_inputdata.commodity.info.issinglemargin)
    l_tradenum=1;
else
    l_tradenum=2;
end
% ��֤�����
l_margin=in_inputdata.commodity.info.margin;
% l_margin=0.1;
% ����������
l_tradecharge=in_inputdata.commodity.info.tradecharge*l_handnum;
% l_tradecharge=0;
% ִ���������
SUB_TradeCalculationPeriodly(in_pairid,1,21);
% ��¼�������
% �����¿�ʼ����
% ��������
l_lastdatevec=datevec(in_inputdata.pair.mkdata.date(end));
l_name=cell2mat(in_inputdata.pair.name);
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
g_tradecaculation.pos.num=[];
g_tradecaculation.trade.num=[];  
g_tradecaculation.pos.name=in_inputdata.pair.name;
g_tradecaculation.trade.name=in_inputdata.pair.name;
for l_caculationid=1:g_tradecaculation.caculationnum
    if(~isempty(g_tradecaculation(l_caculationid).result.trademap))
        for l_index=1:length(g_tradecaculation(l_caculationid).result.trademap(:,1))
            % pos��trade��������1
            l_posid=l_posid+1;
            l_tradeid=l_tradeid+1;
            % ƽ�ֵ��ͣ�ֵ�
            l_cspid=find(g_tradecaculation(l_caculationid).result.trademap(l_index,:)>=4,1);
            % pos
            % ����
            g_tradecaculation.pos.name(l_posid)=in_inputdata.pair.name;
            % ��������
%             g_tradecaculation.pos.type(l_posid)=g_tradecaculation(l_caculationid).type; 
            g_tradecaculation.pos.type(l_posid)=g_strategydata.type(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1));
            % ��������
            g_tradecaculation.pos.opdate(l_posid)=...
                in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1));
            % ��������
            g_tradecaculation.pos.optype(l_posid)=1;
            % ����ʱ�ļ۲�
            g_tradecaculation.pos.opdategap(l_posid)=...
                in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1));
            % ����ʱ�Ľ��ں�Լ������
            g_tradecaculation.pos.opgapvl1(l_posid)=...
                in_inputdata.pair.mkdata.vl(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1),1);
            % ����ʱ��Զ�ں�Լ������
            g_tradecaculation.pos.opgapvl2(l_posid)=...
                in_inputdata.pair.mkdata.vl(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1),2);              
            % ƽ�ֻ�ͣ�ֵ�����
            g_tradecaculation.pos.cpdate(l_posid)=....
                in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
            % ƽ�ֻ�ͣ�ֵ�����
            g_tradecaculation.pos.cptype(l_posid)=g_tradecaculation(l_caculationid).result.trademap(l_index,l_cspid);  
            % ƽ�ֻ�ͣ�ֵļ۲�
            g_tradecaculation.pos.cpdategap(l_posid)=...
                in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
            % ƽ��ʱ�Ľ��ں�Լ������
            g_tradecaculation.pos.cpgapvl1(l_posid)=...
                in_inputdata.pair.mkdata.vl(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1);
            % ƽ��ʱ��Զ�ں�Լ������
            g_tradecaculation.pos.cpgapvl2(l_posid)=...
                in_inputdata.pair.mkdata.vl(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2);             
            % ��֤��
            g_tradecaculation.pos.margin(l_posid)=round(l_tradeunit*l_margin*l_tradenum...
                *max(in_inputdata.pair.mkdata.cp(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid),:)));
            % ����������
            if (l_tradecharge<1)
                g_tradecaculation.pos.optradecharge(l_posid)=round(sum(l_tradecharge*...
                    in_inputdata.pair.mkdata.op(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1),:)));
                g_tradecaculation.pos.cptradecharge(l_posid)=round(sum(l_tradecharge*...
                    in_inputdata.pair.mkdata.cp(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid),:)));                
            else
                g_tradecaculation.pos.optradecharge(l_posid)=l_tradecharge*2;
                g_tradecaculation.pos.cptradecharge(l_posid)=l_tradecharge*2;
            end
            % �ôβ�λ����ƽ�ֻ�ͣ�ֵļ۲�-����ʱ�ļ۲����ͳһ�������Ч��
            g_tradecaculation.pos.gapdiff(l_posid)=g_tradecaculation.pos.cpdategap(l_posid)-g_tradecaculation.pos.opdategap(l_posid);
            % �ôβ�λ�����棬����ͳһ�������Ч��
            switch g_tradecaculation.pos.type(l_posid)
                case 21
                    l_sign=-1;
                case 22;
                    l_sign=-1;
                case 23
                    l_sign=-1;
            end
            g_tradecaculation.pos.profit(l_posid)=g_tradecaculation.pos.gapdiff(l_posid)*l_tradeunit*l_sign...
                -g_tradecaculation.pos.optradecharge(l_posid)-g_tradecaculation.pos.cptradecharge(l_posid);              
            % trade 
            % ������
            g_tradecaculation.trade.name(l_tradeid)=in_inputdata.pair.name;
            % ��������
            g_tradecaculation.trade.type(l_tradeid)=g_tradecaculation.pos.type(l_posid);
            % ���׿�ʼ����
            g_tradecaculation.trade.opdate(l_tradeid)=g_tradecaculation.pos.opdate(l_posid);
            % ���׽�������
            g_tradecaculation.trade.cpdate(l_tradeid)=g_tradecaculation.pos.cpdate(l_posid);
            if datenum(g_tradecaculation.trade.cpdate(l_tradeid))>l_lastdatenum
                g_tradecaculation.trade.type(l_tradeid)=g_tradecaculation.pos.type(l_posid)+100;
            end            
            % ���׵������м۲���ۼ�
            g_tradecaculation.trade.gapdiff(l_tradeid)=g_tradecaculation.pos.gapdiff(l_posid);
            % һ�ֽ��׵Ĳ�λ��
            g_tradecaculation.trade.posnum(l_tradeid)=1;
            % һ�ֽ��׵�����
            g_tradecaculation.trade.profit(l_tradeid)=g_tradecaculation.pos.profit(l_posid);  
            % ����мӲֵ�
            l_apid=find(g_tradecaculation(l_caculationid).result.trademap(l_index,:)==2,1);
            if(~isempty(l_apid))
                l_posid=l_posid+1;
                % pos
                g_tradecaculation.pos.name(l_posid)=in_inputdata.pair.name;
%                 g_tradecaculation.pos.type(l_posid)=g_tradecaculation(l_caculationid).type; 
                g_tradecaculation.pos.type(l_posid)=g_strategydata.type(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,1));
                g_tradecaculation.pos.opdate(l_posid)=...
                    in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid));
                g_tradecaculation.pos.optype(l_posid)=2;  % �Ӳ�type
                g_tradecaculation.pos.opdategap(l_posid)=...
                    in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid));
                % ����ʱ�Ľ��ں�Լ������
                g_tradecaculation.pos.opgapvl1(l_posid)=...
                    in_inputdata.pair.mkdata.vl(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid),1);
                % ����ʱ��Զ�ں�Լ������
                g_tradecaculation.pos.opgapvl2(l_posid)=...
                    in_inputdata.pair.mkdata.vl(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid),2);                  
                g_tradecaculation.pos.cpdate(l_posid)=....
                    in_inputdata.pair.mkdata.date(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
                g_tradecaculation.pos.cptype(l_posid)=g_tradecaculation(l_caculationid).result.trademap(l_index,l_cspid);  
                g_tradecaculation.pos.cpdategap(l_posid)=...
                    in_inputdata.pair.mkdata.cpgap(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid));
                % ƽ��ʱ�Ľ��ں�Լ������
                g_tradecaculation.pos.cpgapvl1(l_posid)=...
                    in_inputdata.pair.mkdata.vl(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid),1);
                % ƽ��ʱ��Զ�ں�Լ������
                g_tradecaculation.pos.cpgapvl2(l_posid)=...
                    in_inputdata.pair.mkdata.vl(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid),2);                
                % ��֤��
                g_tradecaculation.pos.margin(l_posid)=round(l_tradeunit*l_margin*l_tradenum...
                    *max(in_inputdata.pair.mkdata.cp(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid),:)));          
                % ����������
                if (l_tradecharge<1)
                    g_tradecaculation.pos.optradecharge(l_posid)=round(sum(l_tradecharge*...
                        in_inputdata.pair.mkdata.op(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_apid),:)));
                    g_tradecaculation.pos.cptradecharge(l_posid)=round(sum(l_tradecharge*...
                        in_inputdata.pair.mkdata.cp(g_tradecaculation(l_caculationid).result.tddaysmap(l_index,l_cspid),:)));                
                else
                    g_tradecaculation.pos.optradecharge(l_posid)=l_tradecharge*2;
                    g_tradecaculation.pos.cptradecharge(l_posid)=l_tradecharge*2;
                end
                % �ôβ�λ�����棬����ͳһ�������Ч��
                g_tradecaculation.pos.gapdiff(l_posid)=g_tradecaculation.pos.cpdategap(l_posid)-g_tradecaculation.pos.opdategap(l_posid);                
                g_tradecaculation.pos.profit(l_posid)=g_tradecaculation.pos.gapdiff(l_posid)*l_tradeunit*l_sign...
                    -g_tradecaculation.pos.optradecharge(l_posid)-g_tradecaculation.pos.cptradecharge(l_posid);                    
                % trade
                g_tradecaculation.trade.posnum(l_tradeid)=2;
                g_tradecaculation.trade.gapdiff(l_tradeid)=g_tradecaculation.trade.gapdiff(l_tradeid)+g_tradecaculation.pos.gapdiff(l_posid); 
                g_tradecaculation.trade.profit(l_tradeid)=g_tradecaculation.trade.profit(l_tradeid)+g_tradecaculation.pos.profit(l_posid);
            end
            g_tradecaculation.pos.num=l_posid;
            g_tradecaculation.trade.num=l_tradeid;       
        end
    end
end

function SUB_TradeCalculationPeriodly(in_inputdata,in_calulationid,in_strategytype)
%%%%%%%% ��������,��������������
global g_tradecaculation;
global g_indicatordata;
global g_strategydata;

% ���ò���
l_period=round(in_inputdata.strategyparms.period/2)+1;
l_losses=in_inputdata.strategyparms.losses;
l_wins=in_inputdata.strategyparms.wins;
g_tradecaculation(in_calulationid).type=in_strategytype;
if (in_inputdata.pair.datalen<l_period)
    g_tradecaculation(in_calulationid).result.trademap=[];
    return;
end
% ����ʱ��ͼ
l_primaryindexmap=ZR_FUN_ComputeDaysMap(in_inputdata.pair.datalen,l_period);
g_tradecaculation(in_calulationid).primary.indexmap=l_primaryindexmap;
% ���ܽ����ӡ�ƽ�ֵ㣬l_wins����ƽ������Խ��ƽ�ֿ���ԽС
l_premin=g_indicatordata.pair.mingap;
switch in_strategytype
    case 21
        % ���ܽ��ֵ�
        l_maybeopdays=g_strategydata.case2a.ismatched;
        l_maybeopdays(end)=0; 
%        l_maybeopdays(end-1:end)=0;
        % ���ܽ��ֵ�
        g_tradecaculation(in_calulationid).primary.opdaysmap=l_maybeopdays(l_primaryindexmap);    
        % ���ܼӲֵ�,�ٴ����㽨������
%         g_tradecaculation(in_calulationid).primary.apdaysmap=...
%             ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)...
%             -imresize_old(in_inputdata.pair.mkdata.cpgap,size(l_primaryindexmap)))>0);
%         g_tradecaculation(in_calulationid).primary.apdaysmap=...
%             g_tradecaculation(in_calulationid).primary.apdaysmap&g_tradecaculation(in_calulationid).primary.opdaysmap;
        g_tradecaculation(in_calulationid).primary.apdaysmap=zeros(size(l_primaryindexmap));
        % ����ƽ��
        g_tradecaculation(in_calulationid).primary.cpdaysmap=...
            ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)-imresize_old(l_premin,size(l_primaryindexmap)))...
                    <(-l_wins*g_indicatordata.pair.ATR(1)));
        g_tradecaculation(in_calulationid).primary.cpdaysmap=g_tradecaculation(in_calulationid).primary.cpdaysmap...
            |(l_primaryindexmap>=(in_inputdata.pair.datalen-1));
%         g_tradecaculation(in_calulationid).primary.cpdaysmap=l_maybecpdays(l_primaryindexmap);
        % ͣ�ֵ�
        g_tradecaculation(in_calulationid).primary.spdaysmap=zeros(size(l_primaryindexmap));        
    case 22
        % ���ܽ��ֵ�
        l_maybeopdays=g_strategydata.case2b.ismatched;
        l_maybeopdays(end)=0;      
        % ���ܽ��ֵ�
        g_tradecaculation(in_calulationid).primary.opdaysmap=l_maybeopdays(l_primaryindexmap);    
        % ���ܼӲֵ�,�ٴ����㽨������
        g_tradecaculation(in_calulationid).primary.apdaysmap=...
            ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)...
            -imresize_old(in_inputdata.pair.mkdata.cpgap,size(l_primaryindexmap)))>0);
        g_tradecaculation(in_calulationid).primary.apdaysmap=...
            g_tradecaculation(in_calulationid).primary.apdaysmap&g_tradecaculation(in_calulationid).primary.opdaysmap;
        % ����ƽ��
        g_tradecaculation(in_calulationid).primary.cpdaysmap=...
            ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)-imresize_old(l_premin,size(l_primaryindexmap)))...
                    <(-l_wins*g_indicatordata.pair.ATR(1)));
        g_tradecaculation(in_calulationid).primary.cpdaysmap=g_tradecaculation(in_calulationid).primary.cpdaysmap...
            |(l_primaryindexmap==in_inputdata.pair.datalen);
%         g_tradecaculation(in_calulationid).primary.cpdaysmap=l_maybecpdays(l_primaryindexmap);
        % ͣ�ֵ�
        g_tradecaculation(in_calulationid).primary.spdaysmap=zeros(size(l_primaryindexmap));        
    case 23
        % ���ܽ��ֵ�
        l_maybeopdays=g_strategydata.case2c.ismatched;
        l_maybeopdays(end)=0;     
        % ���ܽ��ֵ�
        g_tradecaculation(in_calulationid).primary.opdaysmap=l_maybeopdays(l_primaryindexmap);    
        % ���ܼӲֵ�,�ٴ����㽨������
        g_tradecaculation(in_calulationid).primary.apdaysmap=zeros(size(l_primaryindexmap));   
        % ����ƽ��
        g_tradecaculation(in_calulationid).primary.cpdaysmap=...
            ((in_inputdata.pair.mkdata.cpgap(l_primaryindexmap)-imresize_old(l_premin,size(l_primaryindexmap)))...
                    <(-l_wins*g_indicatordata.pair.ATR(1)));
        g_tradecaculation(in_calulationid).primary.cpdaysmap=g_tradecaculation(in_calulationid).primary.cpdaysmap...
            |(l_primaryindexmap==in_inputdata.pair.datalen);
%         g_tradecaculation(in_calulationid).primary.cpdaysmap=l_maybecpdays(l_primaryindexmap);
        % ͣ�ֵ�
        g_tradecaculation(in_calulationid).primary.spdaysmap=zeros(size(l_primaryindexmap));        
end
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
        l_spdays((l_apid+1):l_period)=...
            8*((in_inputdata.pair.mkdata.cpgap(g_tradecaculation(in_calulationid).result.indexmap(l_index,(l_apid+1):l_period))...
            -in_inputdata.pair.mkdata.cpgap(g_tradecaculation(in_calulationid).result.indexmap(l_index,l_apid)))...
            >(l_losses*g_indicatordata.pair.ATR(g_tradecaculation(in_calulationid).result.indexmap(l_index,l_apid))));                  
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

function out_traderecord=SUB_ComputeRecordDataPerPair(in_inputdata)
%%%%%%%% ���㽻������
global g_tradecaculation;
% ���ò���
l_traderecord=[];
g_tradecaculation.caculationnum=1;
% ִ���������
SUB_TradeCalculationPeriodly(in_inputdata,1,21);
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
            l_traderecord.direction(l_posid)=-1; %1�������࣬-1��������
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
out_traderecord.record=l_traderecord;
out_traderecord.orderlist.price=[];
out_traderecord.orderlist.direction=[];
out_traderecord.orderlist.name={};











