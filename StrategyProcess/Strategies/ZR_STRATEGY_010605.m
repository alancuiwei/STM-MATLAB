function out_traderecord=ZR_STRATEGY_010605(in_inputdata)
% ���Ӣ���Ĳ���:010605 ����3
SUB_ComputeIndicatorPerPair(in_inputdata);
% ������Ե�����
% SUB_ComputeStrategyDataPerPair(in_inputdata);
% ���׼�¼����
out_traderecord=SUB_ComputeRecordDataPerPair(in_inputdata);


% % �õ���ȫ�ֱ���
% global g_contractnames;
% global g_rawdata;
% global g_coredata;
% % ���ò��Բ���
% SUB_SetStrategyParams(varargin{:});
% % ���û�к�Լ��������Ϣ������G_RunSpecialTestCase�еĺ�Լ����
% if isempty(g_contractnames)
%     error('��Լ���б�û�г�ʼ��');
% end
% %%%% �㷨����
% l_cmnum=length(g_contractnames);
% % ����һ���������һ��
% for l_cmid=1:l_cmnum         
%     % ÿһ��Ʒ�ֳ�ʼ��
%     SUB_InitGlobalVarsPerCommodity();
%     g_rawdata=g_coredata(l_cmid);
%     % ����ÿһ��Ʒ�����ò��Բ���
%     ZR_FUN_SetParamsPerCommodity(l_cmid);
%     % �õ�ͬƷ�ֺ�Լ������
%     l_pairnum=length(g_rawdata.pair);
%     % ����ͬƷ������������
%     for l_pairid=1:l_pairnum
%         % �����Լ��ָ��
%         SUB_ComputeIndicatorPerPair(l_pairid);
%         % ������Ե�����
%         SUB_ComputeStrategyDataPerPair(l_pairid);
%         % ��������
%         SUB_ComputeTradeDataPerPair(l_pairid);
%     end
%     % ���㱨������
%     ZR_PROCESS_RecordReportPerCommodity(l_cmid);
%     % ���潻�׵�ͼ��
%     SUB_SaveTradeBarPerCommodity();
% end
% % �������
% ZR_PROCESS_CollectReport();
% 
% function SUB_SetStrategyParams(varargin)
% %%%%%%%% ���ò��Բ���
% global g_strategyparams;
% global g_contractnames;
% % ������ֵ���Ż�ִ��ʱ�Żᴫ�����
% if(nargin>0)
%     % Ĭ����ÿ����Ʒ�µ�һ��
%     g_strategyparams.handnum=ones(1,length(g_contractnames)); 
%     l_commandstr='';
%     for l_paramid=1:(nargin/2)   
%         l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_contractnames)); ');
%     end
%     eval(l_commandstr);
% end
% 
% function SUB_InitGlobalVarsPerCommodity()
% %%%%%%%% ÿһ��Ʒ�ֳ�ʼ��
% global g_rawdata;
% global g_indicatordata
% global g_strategydata;
% global g_tradecaculation;
% global g_tradecaculationformat;
% g_rawdata=[];
% g_indicatordata=[];
% g_strategydata=[];
% g_tradecaculation=g_tradecaculationformat; 
% 
% 
% function SUB_ComputeIndicatorPerContract(in_ctid)
% %%%%%%%% �����Լ��ָ����Ϣ
% global g_indicatordata;
% g_indicatordata.contract(in_ctid)=0;

function SUB_ComputeIndicatorPerPair(in_inputdata)
%%%%%%%% ���������Ե�ָ����Ϣ
global g_indicatordata;
g_indicatordata=[];
% ����0��id
g_indicatordata.pair.positivecpgapid=find(in_inputdata.pair.mkdata.cpgap>0);
% ֹ��tick
g_indicatordata.pair.ATR=min(in_inputdata.commodity.info.tick)*ones(in_inputdata.pair.datalen,1);

function SUB_ComputeStrategyDataPerPair(in_inputdata)
%%%%%%%% �����ײ����������

function out_traderecord=SUB_ComputeRecordDataPerPair(in_inputdata)
%%%%%%%% ���㽻������
global g_tradecaculation;
% ���ò���
l_traderecord=[];
g_tradecaculation.caculationnum=1;
% ִ���������
SUB_TradeCalculation(in_inputdata,1,31);
% ��¼�������
l_opdays=find(g_tradecaculation.opdays);
l_cpdays=find(g_tradecaculation.cpdays);
l_posid=0;
% �����������numֵ�ж��Ƿ��п���
% l_traderecord.name=in_inputdata.pair.name;
if ~isempty(l_opdays)
    for l_dayid=1:length(l_opdays)
        % pos��trade��������1
        l_posid=l_posid+1;
        l_traderecord.name(l_posid)=in_inputdata.pair.name;
        l_traderecord.direction(l_posid)=-1; %1�������࣬-1��������
        % ��������
        l_traderecord.opdate(l_posid)=...
            in_inputdata.pair.mkdata.date(l_opdays(l_dayid));
        % ƽ������
        l_traderecord.cpdate(l_posid)=...
            in_inputdata.pair.mkdata.date(l_cpdays(l_dayid));     
        % ����ʱ�ļ۸�
        l_traderecord.opdateprice(l_posid)=...
            in_inputdata.pair.mkdata.cpgap(l_opdays(l_dayid));
        % ƽ��ʱ�ļ۸�
        l_traderecord.cpdateprice(l_posid)=...
            in_inputdata.pair.mkdata.cpgap(l_cpdays(l_dayid)); 
        l_traderecord.isclosepos(l_posid)=1; % 
    end
end

out_traderecord.record=l_traderecord;
out_traderecord.orderlist.price=[];
out_traderecord.orderlist.direction=[];
out_traderecord.orderlist.name={};


function SUB_ComputeTradeDataPerPair(in_inputdata)
%%%%%%%% ���㽻������
global g_tradecaculation;
% ���ò���
l_handnum=in_inputdata.strategyparms.handnum;
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
% ����������
l_tradecharge=in_inputdata.commodity.info.tradecharge*l_handnum;
% ִ���������
g_tradecaculation.caculationnum=1;
SUB_TradeCalculation(in_pairid,1,41);
% ��¼�������
l_opdays=find(g_tradecaculation(1).opdays);
l_cpdays=find(g_tradecaculation(1).cpdays);
l_posid=0;
l_tradeid=0;
% �����������numֵ�ж��Ƿ��п���
g_tradecaculation.pos.num=[];
g_tradecaculation.trade.num=[];  
g_tradecaculation.pos.name=in_inputdata.pair.name;
g_tradecaculation.trade.name=in_inputdata.pair.name;
if ~isempty(l_opdays)
    for l_dayid=1:length(l_opdays)
        % pos��trade��������1
        l_posid=l_posid+1;
        l_tradeid=l_tradeid+1;
            % ��������
            if (g_tradecaculation(1).opdays(l_opdays(l_dayid))==3)
                g_tradecaculation.pos.type(l_posid)=31; 
            else
                g_tradecaculation.pos.type(l_posid)=32; 
            end
            % ��������
            g_tradecaculation.pos.opdate(l_posid)=...
                in_inputdata.pair.mkdata.date(l_opdays(l_dayid));
            % ��������
            g_tradecaculation.pos.optype(l_posid)=g_tradecaculation(1).opdays(l_opdays(l_dayid));
            % ����ʱ�ļ۲�
            g_tradecaculation.pos.opdategap(l_posid)=...
                in_inputdata.pair.mkdata.cpgap(l_opdays(l_dayid));
            % ����ʱ�Ľ��ں�Լ������
            g_tradecaculation.pos.opgapvl1(l_posid)=...
                in_inputdata.pair.mkdata.vl(l_opdays(l_dayid),1);
            % ����ʱ��Զ�ں�Լ������
            g_tradecaculation.pos.opgapvl2(l_posid)=...
                in_inputdata.pair.mkdata.vl(l_opdays(l_dayid),2);                
            % ƽ�ֻ�ͣ�ֵ�����
            g_tradecaculation.pos.cpdate(l_posid)=....
                in_inputdata.pair.mkdata.date(l_cpdays(l_dayid));
            % ƽ�ֻ�ͣ�ֵ�����
            g_tradecaculation.pos.cptype(l_posid)=g_tradecaculation(1).cpdays(l_cpdays(l_dayid));  
            % ƽ�ֻ�ͣ�ֵļ۲�
            g_tradecaculation.pos.cpdategap(l_posid)=...
                in_inputdata.pair.mkdata.cpgap(l_cpdays(l_dayid));
            % ��֤��
            g_tradecaculation.pos.margin(l_posid)=round(l_tradeunit*l_margin*l_tradenum...
                *max(in_inputdata.pair.mkdata.cp(l_cpdays(l_dayid),:)));
            % ƽ��ʱ�Ľ��ں�Լ������
            g_tradecaculation.pos.cpgapvl1(l_posid)=...
                in_inputdata.pair.mkdata.vl(l_cpdays(l_dayid),1);
            % ƽ��ʱ��Զ�ں�Լ������
            g_tradecaculation.pos.cpgapvl2(l_posid)=...
                in_inputdata.pair.mkdata.vl(l_cpdays(l_dayid),2);            
            % ����������
            if (l_tradecharge<1)
                g_tradecaculation.pos.optradecharge(l_posid)=round(sum(l_tradecharge*...
                    in_inputdata.pair.mkdata.op(l_opdays(l_dayid),:)));
                g_tradecaculation.pos.cptradecharge(l_posid)=round(sum(l_tradecharge*...
                    in_inputdata.pair.mkdata.cp(l_cpdays(l_dayid),:)));                
            else
                g_tradecaculation.pos.optradecharge(l_posid)=l_tradecharge*2;
                g_tradecaculation.pos.cptradecharge(l_posid)=l_tradecharge*2;
            end
            
            % �ôβ�λ����ƽ�ֻ�ͣ�ֵļ۲�-����ʱ�ļ۲����ͳһ�������Ч��
            g_tradecaculation.pos.gapdiff(l_posid)=g_tradecaculation.pos.cpdategap(l_posid)-g_tradecaculation.pos.opdategap(l_posid); 
            l_sign=1;
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
            % ���׵������м۲���ۼ�
            g_tradecaculation.trade.gapdiff(l_tradeid)=g_tradecaculation.pos.gapdiff(l_posid);
            % һ�ֽ��׵Ĳ�λ��
            g_tradecaculation.trade.posnum(l_tradeid)=1;
            % һ�ֽ��׵�����
            g_tradecaculation.trade.profit(l_tradeid)=g_tradecaculation.pos.profit(l_posid);  
            g_tradecaculation.pos.num=l_posid;
            g_tradecaculation.trade.num=l_tradeid;               
    end
end


function SUB_SaveTradeBarPerCommodity()
%%%%%%%% ���ɽ��׵�ͼ
global g_rawdata;
global g_tradecaculation;
global g_figure;
global G_Start;
global g_strategydata;
if (strcmp(G_Start.runmode,'RunSpecialTestCase')&&(g_figure.savetradebar.issaved))
    % ������Ʒ�����е�������
    close all; 
    l_pairnum=length(g_tradecaculation);
    for l_pairid=1:l_pairnum
        if(isempty(g_tradecaculation(l_pairid).pos.num))
            continue;
        end  
        figure('Name',cell2mat(g_rawdata.pair(l_pairid).name));
        for l_caculationid=1:g_tradecaculation(l_pairid).caculationnum
            l_cpgaplen=g_rawdata.pair(l_pairid).datalen;
            % ��2��ʼ�����ɫ�Ƚ����
            l_color=zeros(l_cpgaplen,1);
            l_color(find(g_tradecaculation(l_pairid).caculation(l_caculationid).opdays))=2;
            l_color(find(g_tradecaculation(l_pairid).caculation(l_caculationid).cpdays))=4;            
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

function SUB_TradeCalculation(in_inputdata,in_calulationid,in_strategytype)
%%%%%%%% ��������
global g_tradecaculation;
global g_indicatordata;
g_tradecaculation=[];
% ���ò���
l_countersofdown=in_inputdata.strategyparms.countersofdown;
l_countersofup=in_inputdata.strategyparms.countersofup;
l_losses=in_inputdata.strategyparms.losses;
l_sharp=in_inputdata.strategyparms.sharp;
l_sharpdays=in_inputdata.strategyparms.sharpdays;
% l_wins=g_commodityparams.wins;
g_tradecaculation(in_calulationid).type=in_strategytype;
% ����
l_num=0;
l_upcounter=0;
l_downcounter=0;
l_isop=0;
l_loss=0;
l_sharpnum=0;
% l_zero=0;
l_cpgap=in_inputdata.pair.mkdata.cpgap;
l_opdays=zeros(size(in_inputdata.pair.mkdata.cpgap));
l_cpdays=zeros(size(in_inputdata.pair.mkdata.cpgap));
g_tradecaculation(in_calulationid).opdays=l_opdays;
g_tradecaculation(in_calulationid).cpdays=l_cpdays;
if isempty(g_indicatordata.pair.positivecpgapid)
    return;
end
l_days=g_indicatordata.pair.positivecpgapid;
for l_gapid=1:length(l_days)
    l_num=l_num+1;
    if (l_num==1)
        % �״�,λ��0
%         if (l_days(l_gapid)>1)
%             l_zero=1;
%         end        
        l_lastupcpgap=l_cpgap(l_days(l_gapid));
        l_lastdowncpgap=l_cpgap(l_days(l_gapid));       
    elseif(l_days(l_gapid)<=(l_lastid+1))
        if l_cpgap(l_days(l_gapid))>l_lastupcpgap
            l_lastupcpgap=l_cpgap(l_days(l_gapid));
            l_upcounter=l_upcounter+1;
            % �ﵽƽ�ֵ�������downcouter���¼�����0�㸽��
            if l_isop              
                if (l_upcounter>=l_countersofup) 
                    % �ﵽֹӮƽ�ֵ�������downcouter���¼���
                    l_cpdays(l_days(l_gapid))=4;
                    l_isop=0;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid));                       
                end
            else
                if (l_upcounter>=l_countersofup)&&(min(in_inputdata.pair.mkdata.vl(l_days(l_gapid),:))>=100) 
                    % �ﵽ˳�ƽ��ֵ�������downcouter���¼���
                    l_opdays(l_days(l_gapid))=3;
                    l_isop=1;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid));  
                    l_loss=0;
                end
                if(l_loss)
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid)); 
                    l_loss=0;
%                 elseif(l_zero)&&(l_upcounter>=2*l_counters)
%                     l_upcounter=0;
%                     l_lastupcpgap=l_cpgap(l_days(l_gapid));
%                     l_downcounter=0;
%                     l_lastdowncpgap=l_cpgap(l_days(l_gapid));
%                     l_zero=0;
                end
            end            
        elseif (l_cpgap(l_days(l_gapid))<l_lastdowncpgap)               
            % 쭵����
            if ((l_lastdowncpgap-l_cpgap(l_days(l_gapid)))>l_sharp)&&(~l_isop)
                l_sharpnum=l_sharpnum+1;
                if l_sharpnum>=l_sharpdays
                     % �ﵽ���ֵ�������upcouter���¼���
                    l_opdays(l_days(l_gapid))=4;
                    l_upcounter=0;
                    l_lastupcpgap=l_cpgap(l_days(l_gapid));
                    l_downcounter=0;
                    l_lastdowncpgap=l_cpgap(l_days(l_gapid)); 
                    l_isop=1;                       
                end
            else
                l_sharpnum=0;
                l_lastdowncpgap=l_cpgap(l_days(l_gapid));
                l_downcounter=l_downcounter+1;
                if (l_isop)
                    l_opdaygap=l_cpgap(find(l_opdays,1,'last'));
                    if (l_cpgap(l_days(l_gapid))-l_opdaygap)<(-l_losses*g_indicatordata.pair.ATR(1))
                        % �ﵽֹ��ƽ�ֵ�������downcouter���¼���
                        l_cpdays(l_days(l_gapid))=8;
                        l_upcounter=0;
                        l_lastupcpgap=l_opdaygap;
                        l_downcounter=0;
                        l_lastdowncpgap=l_cpgap(l_days(l_gapid)); 
                        l_loss=1;
                        l_isop=0;                                         
                    end  
                else
                    if (~l_loss)&&(l_downcounter>=l_countersofdown)&&(min(in_inputdata.pair.mkdata.vl(l_days(l_gapid),:))>=100)
                        % �ﵽ���ֵ�������upcouter���¼���
                        l_opdays(l_days(l_gapid))=2;
                        l_upcounter=0;
                        l_lastupcpgap=l_cpgap(l_days(l_gapid));
                        l_downcounter=0;
                        l_lastdowncpgap=l_cpgap(l_days(l_gapid)); 
                        l_isop=1;
                    end
                end                  
            end                     
        end
    else
        % �ִ�0�㿪ʼ����,ǰһ��ƽ��
        if l_isop
            l_cpdays(l_lastid+1)=5;
            l_isop=0;
        end
        l_upcounter=0;
        l_lastupcpgap=l_cpgap(l_days(l_gapid));
        l_downcounter=0;
        l_lastdowncpgap=l_cpgap(l_days(l_gapid));  
%         l_zero=1;
        l_loss=0;
    end
    l_lastid=l_days(l_gapid);    
end

% ���һ�������գ������Խ���
if l_isop
    if (l_opdays(end)>0)
        l_opdays(end)=0;
    elseif l_days(end)==in_inputdata.pair.datalen
        l_cpdays(end)=16;
    else
        l_cpdays(l_days(end)+1)=5;
    end
end
g_tradecaculation(in_calulationid).opdays=l_opdays;
g_tradecaculation(in_calulationid).cpdays=l_cpdays;










