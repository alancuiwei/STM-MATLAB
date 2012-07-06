function ZR_STRATEGY_010601_L4_Advance(varargin)
% ���Ӣ���Ĳ���:010601

% �õ���ȫ�ֱ���
global g_contractnames;
global g_rawdata;
global g_coredata;
% ���ò��Բ���
SUB_SetStrategyParams(varargin{:});
% ���û�к�Լ��������Ϣ������G_RunSpecialTestCase�еĺ�Լ����
if isempty(g_contractnames)
    error('��Լ���б�û�г�ʼ��');
end
%%%% �㷨����
l_cmnum=length(g_contractnames);
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
    SUB_SaveTradeBarPerCommodity();
end
% �������
ZR_PROCESS_CollectReport();

function SUB_SetStrategyParams(varargin)
%%%%%%%% ���ò��Բ���
global g_strategyparams;
global g_contractnames;
% ������ֵ���Ż�ִ��ʱ�Żᴫ�����
if(nargin>0)
    % Ĭ����ÿ����Ʒ�µ�һ��
    g_strategyparams.handnum=ones(1,length(g_contractnames)); 
    l_commandstr='';
    for l_paramid=1:(nargin/2)   
        l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_contractnames)); ');
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

% ����0��id
g_indicatordata.pair(in_pairid).positivecpgapid=find(g_rawdata.pair(in_pairid).mkdata.cpgap>0);
% ֹ��tick
g_indicatordata.pair(in_pairid).ATR=g_rawdata.commodity.info.tick*ones(g_rawdata.pair(in_pairid).datalen,1);

function SUB_ComputeStrategyDataPerPair(in_pairid)
%%%%%%%% �����ײ����������

function SUB_ComputeTradeDataPerPair(in_pairid)
%%%%%%%% ���㽻������
global g_rawdata;
global g_tradedata;
global g_commodityparams;
global g_strategydata;
% ���ò���
l_handnum=g_commodityparams.handnum;
% ���׵�λ
l_tradeunit=g_rawdata.commodity.info.tradeunit*l_handnum;
% �Ƿ񵥱���ȡ��֤��
if(g_rawdata.commodity.info.issinglemargin)
    l_tradenum=1;
else
    l_tradenum=2;
end
% ��֤�����
l_margin=g_rawdata.commodity.info.margin;
% ����������
l_tradecharge=g_rawdata.commodity.info.tradecharge*l_handnum;
% ִ���������
g_tradedata(in_pairid).caculationnum=1;
SUB_TradeCalculation(in_pairid,1,41);
% ��¼�������
l_opdays=find(g_tradedata(in_pairid).caculation(1).opdays);
l_cpdays=find(g_tradedata(in_pairid).caculation(1).cpdays);
l_posid=0;
l_tradeid=0;
% �����������numֵ�ж��Ƿ��п���
g_tradedata(in_pairid).pos.num=[];
g_tradedata(in_pairid).trade.num=[];  
g_tradedata(in_pairid).pos.name=g_rawdata.pair(in_pairid).name;
g_tradedata(in_pairid).trade.name=g_rawdata.pair(in_pairid).name;
if ~isempty(l_opdays)
    for l_dayid=1:length(l_opdays)
        % pos��trade��������1
        l_posid=l_posid+1;
        l_tradeid=l_tradeid+1;
        % ��������
        if (g_tradedata(in_pairid).caculation(1).opdays(l_opdays(l_dayid))==3)
            g_tradedata(in_pairid).pos.type(l_posid)=41; 
        else
            g_tradedata(in_pairid).pos.type(l_posid)=42; 
        end
        % ��������
        g_tradedata(in_pairid).pos.opdate(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.date(l_opdays(l_dayid));
        % ��������
        g_tradedata(in_pairid).pos.optype(l_posid)=g_tradedata(in_pairid).caculation(1).opdays(l_opdays(l_dayid));
        % ����ʱ�ļ۲�
        g_tradedata(in_pairid).pos.opdategap(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.cpgap(l_opdays(l_dayid));
        % ����ʱ�Ľ��ں�Լ������
        g_tradedata(in_pairid).pos.opgapvl1(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.vl(l_opdays(l_dayid),1);
        % ����ʱ��Զ�ں�Լ������
        g_tradedata(in_pairid).pos.opgapvl2(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.vl(l_opdays(l_dayid),2);                
        % ƽ�ֻ�ͣ�ֵ�����
        g_tradedata(in_pairid).pos.cpdate(l_posid)=....
            g_rawdata.pair(in_pairid).mkdata.date(l_cpdays(l_dayid));
        % ƽ�ֻ�ͣ�ֵ�����
        g_tradedata(in_pairid).pos.cptype(l_posid)=g_tradedata(in_pairid).caculation(1).cpdays(l_cpdays(l_dayid));  
        % ƽ�ֻ�ͣ�ֵļ۲�
        g_tradedata(in_pairid).pos.cpdategap(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.cpgap(l_cpdays(l_dayid));
        % ��֤��
        g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit*l_margin*l_tradenum...
            *max(g_rawdata.pair(in_pairid).mkdata.cp(l_cpdays(l_dayid),:)));
        % ƽ��ʱ�Ľ��ں�Լ������
        g_tradedata(in_pairid).pos.cpgapvl1(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.vl(l_cpdays(l_dayid),1);
        % ƽ��ʱ��Զ�ں�Լ������
        g_tradedata(in_pairid).pos.cpgapvl2(l_posid)=...
            g_rawdata.pair(in_pairid).mkdata.vl(l_cpdays(l_dayid),2);            
        % ����������
        if (l_tradecharge<1)
            g_tradedata(in_pairid).pos.optradecharge(l_posid)=round(sum(l_tradecharge*...
                g_rawdata.pair(in_pairid).mkdata.op(l_opdays(l_dayid),:)));
            g_tradedata(in_pairid).pos.cptradecharge(l_posid)=round(sum(l_tradecharge*...
                g_rawdata.pair(in_pairid).mkdata.cp(l_cpdays(l_dayid),:)));                
        else
            g_tradedata(in_pairid).pos.optradecharge(l_posid)=l_tradecharge*2;
            g_tradedata(in_pairid).pos.cptradecharge(l_posid)=l_tradecharge*2;
        end

        % �ôβ�λ����ƽ�ֻ�ͣ�ֵļ۲�-����ʱ�ļ۲����ͳһ�������Ч��
        g_tradedata(in_pairid).pos.gapdiff(l_posid)=g_tradedata(in_pairid).pos.cpdategap(l_posid)-g_tradedata(in_pairid).pos.opdategap(l_posid); 
        l_sign=-1;
        g_tradedata(in_pairid).pos.profit(l_posid)=g_tradedata(in_pairid).pos.gapdiff(l_posid)*l_tradeunit*l_sign...
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
        % ���׵������м۲���ۼ�
        g_tradedata(in_pairid).trade.gapdiff(l_tradeid)=g_tradedata(in_pairid).pos.gapdiff(l_posid);
        % һ�ֽ��׵Ĳ�λ��
        g_tradedata(in_pairid).trade.posnum(l_tradeid)=1;
        % һ�ֽ��׵�����
        g_tradedata(in_pairid).trade.profit(l_tradeid)=g_tradedata(in_pairid).pos.profit(l_posid);  
        g_tradedata(in_pairid).pos.num=l_posid;
        g_tradedata(in_pairid).trade.num=l_tradeid;               
    end
end


function SUB_SaveTradeBarPerCommodity()
%%%%%%%% ���ɽ��׵�ͼ
global g_rawdata;
global g_tradedata;
global g_figure;
global G_Start;
global g_strategydata;
if (strcmp(G_Start.runmode,'RunSpecialTestCase')&&(g_figure.savetradebar.issaved))
    % ������Ʒ�����е�������
    close all; 
    l_pairnum=length(g_tradedata);
    for l_pairid=1:l_pairnum
        if(isempty(g_tradedata(l_pairid).pos.num))
            continue;
        end  
        figure('Name',cell2mat(g_rawdata.pair(l_pairid).name));
        for l_caculationid=1:g_tradedata(l_pairid).caculationnum
            l_cpgaplen=g_rawdata.pair(l_pairid).datalen;
            % ��2��ʼ�����ɫ�Ƚ����
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
        % ����ͼ�ε�����
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
%%%%%%%% ��������
global g_tradedata;
global g_indicatordata;
global g_rawdata;
global g_commodityparams;

% ���ò���
l_counters=g_commodityparams.counters;
l_losses=g_commodityparams.losses;
l_wins=g_commodityparams.wins;
g_tradedata(in_pairid).caculation(in_calulationid).type=in_strategytype;
% ����
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
        % �״ν���,0�㸽��
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
            % �ﵽƽ�ֵ�������downcouter���¼�����0�㸽��
            if l_isop
                l_opdaygap=l_cpgap(find(l_opdays,1,'last'));
                if (l_cpgap(l_days(l_gapid))-l_opdaygap)>(l_losses*g_indicatordata.pair(in_pairid).ATR(1))
                    % �ﵽֹ��ƽ�ֵ�������downcouter���¼���
                    l_cpdays(l_days(l_gapid))=8;
                    l_isop=0;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid));    
%                 elseif (l_upcounter>=l_counters) 
%                     % �ﵽֹ��ƽ�ֵ�������downcouter���¼���
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
                    % ���ֵ�������downcouter���¼���
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
                    % �ﵽֹӯƽ�ֵ�������downcouter���¼���
                    l_cpdays(l_days(l_gapid))=4;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid)); 
                    l_isop=0;                    
                elseif (l_downcounter>=floor(l_counters/2)) 
                    % �ﵽֹӯƽ�ֵ�������downcouter���¼���
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
                    % �ﵽ���ֵ�������upcouter���¼���
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
        % �ִ�0�㿪ʼ����,ǰһ��ƽ��
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

% ���һ�������գ������Խ���
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












