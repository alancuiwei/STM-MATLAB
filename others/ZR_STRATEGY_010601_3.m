function ZR_STRATEGY_010601_3(varargin)
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
    SUB_SetParamsPerCommodity(l_cmid);
    % �õ�ͬƷ�ֺ�Լ������
    l_ctnum=length(g_contractnames{l_cmid});
    % ����ͬƷ�����к�Լ
    for l_ctid=1:l_ctnum
        % �����Լ��ָ��
        SUB_ComputeIndicatorPerContract(l_ctid)
        % pair�����Ⱥ�Լ����1��
        if (l_ctid>=2)
            l_pairid=l_ctid-1;
            % ���������Ե�ָ����Ϣ
            SUB_ComputeIndicatorPerPair(l_pairid);
            % ������Ե�����
            SUB_ComputeStrategyDataPerPair(l_pairid);
            % ��������
            SUB_ComputeTradeDataPerPair(l_pairid);
        end
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


function SUB_SetParamsPerCommodity(in_cmid)
%%%%%%%% ����ÿһ��Ʒ�֣����ò��Բ���
global g_strategyparams;
global g_commodityparams;
g_commodityparams=[];
l_paramnames=fieldnames(g_strategyparams);
% ����g_indicatordata��ֵ
l_commandstr='';
for l_paramid=1:length(l_paramnames)
    l_commandstr=strcat(l_commandstr,'g_commodityparams.',l_paramnames{l_paramid},'=g_strategyparams.',...
        l_paramnames{l_paramid},'(in_cmid);');
end
eval(l_commandstr);


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
global g_indicatordata;
global g_rawdata;
global g_strategydata;
global g_commodityparams;
% ���ò���
l_counters=g_commodityparams.counters;
l_losses=g_commodityparams.losses;
% ����
l_num=0;
l_upcounter=0;
l_downcounter=0;
l_isop=0;
l_cpgap=g_rawdata.pair(in_pairid).mkdata.cpgap;
l_opdays=zeros(size(g_rawdata.pair(in_pairid).mkdata.cpgap));
l_cpdays=zeros(size(g_rawdata.pair(in_pairid).mkdata.cpgap));
g_strategydata(in_pairid).opdays=l_opdays;
g_strategydata(in_pairid).cpdays=l_cpdays;
if isempty(g_indicatordata.pair(in_pairid).positivecpgapid)
    return;
end
l_days=g_indicatordata.pair(in_pairid).positivecpgapid;
for l_gapid=1:length(l_days)
    l_num=l_num+1;
    if (l_num==1)
        % �״ν���
        if (l_days(l_gapid)>1)
            if (SUB_CheckIsCase3c(in_pairid,l_days(l_gapid)))
                % 3c������Ӳ�2��
                l_opdays(l_days(l_gapid))=3;
            else
                l_opdays(l_days(l_gapid))=1;
            end
            l_isop=1;
        end
        l_lastupcpgap=l_cpgap(l_days(l_gapid));
        l_lastdowncpgap=l_cpgap(l_days(l_gapid));       
    elseif(l_days(l_gapid)<=(l_lastid+1))
        if l_cpgap(l_days(l_gapid))>l_lastupcpgap
            l_lastupcpgap=l_cpgap(l_days(l_gapid));
            l_upcounter=l_upcounter+1;
            if (l_upcounter>=l_counters)
                % �ﵽƽ�ֵ�������downcouter���¼���
                if l_isop
                    l_cpdays(l_days(l_gapid))=1;
                    l_isop=0;
                end
                l_downcounter=0;
                l_lastdowncpgap=l_cpgap(l_days(l_gapid));
            end
        elseif (l_cpgap(l_days(l_gapid))<l_lastdowncpgap)
            l_lastdowncpgap=l_cpgap(l_days(l_gapid));
            l_downcounter=l_downcounter+1;
            if (l_isop)
                l_opdaygap=l_cpgap(find(l_opdays,1,'last'));
                if (l_cpgap(l_days(l_gapid))-l_opdaygap)<(-l_losses*g_indicatordata.pair(in_pairid).ATR(1))
                    % �ﵽֹ��ƽ�ֵ�������downcouter���¼���
                    l_cpdays(l_days(l_gapid))=8;
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid));
                    l_isop=0;                    
                end
            elseif (l_downcounter>=l_counters)&&(~l_isop)
                % �ﵽ���ֵ�������upcouter���¼���
                l_opdays(l_days(l_gapid))=2;
                l_upcounter=0;
                l_lastupcpgap=l_cpgap(l_days(l_gapid));
                l_isop=1;
            end           
        end
    else
        % �ִ�0�㿪ʼ����,ǰһ��ƽ��
        if l_isop
            l_cpdays(l_lastid+1)=8;
        end
        if (SUB_CheckIsCase3c(in_pairid,l_days(l_gapid)))
            % 3c������Ӳ�2��
            l_opdays(l_days(l_gapid))=3;
        else
            l_opdays(l_days(l_gapid))=1;
        end
        l_lastupcpgap=l_cpgap(l_days(l_gapid));
        l_lastdowncpgap=l_cpgap(l_days(l_gapid));
        l_upcounter=0;
        l_isop=1;
    end
    l_lastid=l_days(l_gapid);    
end
if l_isop
    if l_days(end)==g_rawdata.pair(in_pairid).datalen
        l_cpdays(end)=16;
    else
        l_cpdays(l_days(end)+1)=8;
    end
end
g_strategydata(in_pairid).opdays=l_opdays;
g_strategydata(in_pairid).cpdays=l_cpdays;

function SUB_ComputeTradeDataPerPair(in_pairid)
%%%%%%%% ���㽻������
global g_rawdata;
global g_tradedata;
global g_commodityparams;
global g_strategydata;
% ���ò���
l_handnum=g_commodityparams.handnum;
g_tradedata(in_pairid).caculationnum=2;
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
% ��¼�������
l_opdays=find(g_strategydata(in_pairid).opdays);
l_cpdays=find(g_strategydata(in_pairid).cpdays);
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
            if (g_strategydata(in_pairid).opdays(l_opdays(l_dayid))==3)
                g_tradedata(in_pairid).pos.type(l_posid)=31; 
            else
                g_tradedata(in_pairid).pos.type(l_posid)=32; 
            end
            % ��������
            g_tradedata(in_pairid).pos.opdate(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.date(l_opdays(l_dayid));
            % ����ʱ�Ľ��ں�Լ������
            g_tradedata(in_pairid).pos.opgapvl1(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(l_opdays(l_dayid),1);
            % ����ʱ��Զ�ں�Լ������
            g_tradedata(in_pairid).pos.opgapvl2(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(l_opdays(l_dayid),2);               
            % ��������
            g_tradedata(in_pairid).pos.optype(l_posid)=g_strategydata(in_pairid).opdays(l_opdays(l_dayid));
            % ����ʱ�ļ۲�
            g_tradedata(in_pairid).pos.opdategap(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.cpgap(l_opdays(l_dayid));
            % ƽ�ֻ�ͣ�ֵ�����
            g_tradedata(in_pairid).pos.cpdate(l_posid)=....
                g_rawdata.pair(in_pairid).mkdata.date(l_cpdays(l_dayid));
            % ƽ�ֻ�ͣ�ֵ�����
            g_tradedata(in_pairid).pos.cptype(l_posid)=g_strategydata(in_pairid).cpdays(l_cpdays(l_dayid));  
            % ƽ�ֻ�ͣ�ֵļ۲�
            g_tradedata(in_pairid).pos.cpdategap(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.cpgap(l_cpdays(l_dayid));
            % ��֤��
            g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit*l_margin*l_tradenum...
                *max(g_rawdata.pair(in_pairid).mkdata.cp(l_cpdays(l_dayid),:)));
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
            % ƽ��ʱ�Ľ��ں�Լ������
            g_tradedata(in_pairid).pos.cpgapvl1(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(l_cpdays(l_dayid),1);
            % ƽ��ʱ��Զ�ں�Լ������
            g_tradedata(in_pairid).pos.cpgapvl2(l_posid)=...
                g_rawdata.pair(in_pairid).mkdata.vl(l_cpdays(l_dayid),2);               
            % �ôβ�λ����ƽ�ֻ�ͣ�ֵļ۲�-����ʱ�ļ۲����ͳһ�������Ч��
            g_tradedata(in_pairid).pos.gapdiff(l_posid)=g_tradedata(in_pairid).pos.cpdategap(l_posid)-g_tradedata(in_pairid).pos.opdategap(l_posid); 
            l_sign=1;
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


function out_is3a=SUB_CheckIsCase3c(in_pairid,in_gapid)
%%%%%%%% ��������,��������������
global g_rawdata;
% ���ò���
l_isn2rpricehigher=g_rawdata.pair(in_pairid).mkdata.cp(in_gapid,1)<g_rawdata.pair(in_pairid).mkdata.cp(in_gapid,2);
l_isnearpriceup=g_rawdata.pair(in_pairid).mkdata.cp(in_gapid,1)-g_rawdata.pair(in_pairid).mkdata.cp(in_gapid-1,1);
l_isremotepriceup=g_rawdata.pair(in_pairid).mkdata.cp(in_gapid,2)-g_rawdata.pair(in_pairid).mkdata.cp(in_gapid-1,2);
l_isn2rchangebigger=abs(l_isnearpriceup)>=abs(l_isremotepriceup);
out_is3a=l_isn2rpricehigher&(l_isnearpriceup>0)&(l_isremotepriceup>0)&(~l_isn2rchangebigger);

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
        l_cpgaplen=g_rawdata.pair(l_pairid).datalen;
        % ��2��ʼ�����ɫ�Ƚ����
        l_color=zeros(l_cpgaplen,1);
        l_color(find(g_strategydata(l_pairid).opdays))=2;
        l_color(find(g_strategydata(l_pairid).cpdays))=4;            
        l_bar=bar(1:l_cpgaplen,g_rawdata.pair(l_pairid).mkdata.cpgap,'stacked');
        l_ch=get(l_bar,'children');
        set(l_ch, 'EdgeColor', 'w'); 
        set(l_ch,'FaceVertexCData',l_color);
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











