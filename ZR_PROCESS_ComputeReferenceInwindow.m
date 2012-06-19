function ZR_PROCESS_ComputeReferenceInwindow(varargin)
%%%%%%%% �������ָ��
global g_reportset;
global g_reference;
% �������������������Ŀ�ʼʱ��ĺ���ֹ��ʱ��
l_setwindow=0;
if nargin>0
    switch nargin
        case 1
        case 2
            l_setwindow=1;
            if strcmp(varargin{1},'nolimit')
                l_startwindownum=1;
            else
                l_startwindownum=datenum(varargin{1});
            end
            if strcmp(varargin{2},'nolimit')
                l_endwindownum=inf;
            else
                l_endwindownum=datenum(varargin{2});
            end
            if l_startwindownum>l_endwindownum
                return;
            end
    end
end

% ��Ʒ��
for l_cmid=1:length(g_reportset.commodity)
    % ��ʼͳ�Ƶ�ʱ�� 
    l_startid=1;
    l_endid=g_reportset.commodity(l_cmid).enddatenum-g_reportset.commodity(l_cmid).startdatenum+1;
    if l_setwindow
        if l_startwindownum>=g_reportset.commodity(l_cmid).startdatenum
            l_startid=l_startwindownum-g_reportset.commodity(l_cmid).startdatenum+1;
        else
            l_startwindownum=g_reportset.commodity(l_cmid).startdatenum;
        end
        if l_endwindownum<=g_reportset.commodity(l_cmid).enddatenum
            l_endid=l_endwindownum-g_reportset.commodity(l_cmid).startdatenum+1;
        else
            l_endwindownum=g_reportset.commodity(l_cmid).enddatenum;
        end       
    end
    
    if max(abs(g_reportset.commodity(l_cmid).dailyinfo.margin(l_startid:l_endid)))>0
        % ��������
        l_startdatenum=g_reportset.commodity(l_cmid).startdatenum;
        l_enddatenum=g_reportset.commodity(l_cmid).enddatenum;
        % ��������
        l_startdatevec=datevec(l_startwindownum);
        l_enddatevec=datevec(l_endwindownum);
        % ���
        l_yearnum=l_enddatevec(1,1)-l_startdatevec(1,1);    
        g_reference.commodity.name(l_cmid)=g_reportset.commodity(l_cmid).name;
        g_reference.commodity.rightid(l_cmid)=g_reportset.commodity(l_cmid).record.pos.rightid(1);
        % Ͷ���ʽ�
        g_reference.commodity.costinput(l_cmid)=max(abs(g_reportset.commodity(l_cmid).dailyinfo.margin(l_startid:l_endid))); 
        % �µ����� �ڴ˴�û�а취����
        % g_reference.commodity.numoforder(l_cmid)=[]; 
        % ��ӯ������
%         l_tradeprofit=g_reportset.commodity(l_cmid).record.trade.profit(...
%             (datenum(g_reportset.commodity(l_cmid).record.trade.cpdate)<=l_endwindownum)&(datenum(g_reportset.commodity(l_cmid).record.trade.opdate)>=l_startwindownum));
        l_posprofit=g_reportset.commodity(l_cmid).record.pos.profit(...
            (datenum(g_reportset.commodity(l_cmid).record.pos.cpdate)<=l_endwindownum)&(datenum(g_reportset.commodity(l_cmid).record.pos.opdate)>=l_startwindownum));            
        g_reference.commodity.totalnetprofit(l_cmid)=sum(l_posprofit);   
        % ëӯ��
        g_reference.commodity.grossprofit(l_cmid)=sum(l_posprofit(l_posprofit>0)); 
        % ë����
        g_reference.commodity.grossloss(l_cmid)=sum(l_posprofit(l_posprofit<0));
        % �»ر���
        l_monthprofit=zeros(1,(12*(l_yearnum+1)));
        l_yearprofit=zeros(1,(l_yearnum+1));
        l_numofmonth=0;
        l_numofyear=0;
        for l_yearid=l_startdatevec(1,1):l_enddatevec(1,1)
            for l_monthid=1:12
                l_numofmonth=l_numofmonth+1;
                l_dayid=eomday(l_yearid,l_monthid);
                l_dayvec=[l_yearid,l_monthid,l_dayid,0,0,0];
                l_endofmonthnum=datenum(l_dayvec);
                % ��������
                l_monthprofit(l_numofmonth)=g_reportset.commodity(l_cmid).dailyinfo.profit(l_endofmonthnum-l_startdatenum+1)....
                    -g_reportset.commodity(l_cmid).dailyinfo.profit(l_startid);
            end
            l_numofyear=l_numofyear+1;
            l_yearprofit(l_numofyear)=l_monthprofit(l_numofmonth);
        end
        l_trademonthrate=(l_monthprofit-[0,l_monthprofit(1:(length(l_monthprofit)-1))])/g_reference.commodity.costinput(l_cmid);
        g_reference.commodity.monthreturnrate(l_cmid).data=reshape(l_trademonthrate,[12,l_yearnum+1]);
        % ��ƽ���ر���
        l_tradetime=l_endid-l_startid+1;
        l_monthnum=ceil(l_tradetime/30); 
        g_reference.commodity.avemonthreturnrate(l_cmid)=l_monthprofit(l_numofmonth)/g_reference.commodity.costinput(l_cmid)/l_monthnum;
        % ��ر���
        l_tradeyearrate=(l_yearprofit-[0,l_yearprofit(1:(length(l_yearprofit)-1))])/g_reference.commodity.costinput(l_cmid);
        g_reference.commodity.yearreturnrate(l_cmid).data=l_tradeyearrate; 
        g_reference.commodity.years(l_cmid).data=l_startdatevec(1,1):l_enddatevec(1,1);
        % ��ƽ���ر���
        l_yearnum=ceil(l_tradetime/365); 
        g_reference.commodity.aveyearreturnrate(l_cmid)=l_yearprofit(l_numofyear)/g_reference.commodity.costinput(l_cmid)/l_yearnum;
        % �ܽ�������
        g_reference.commodity.totaltradedays(l_cmid)=l_tradetime;
        % �ܿ��ִ���
        g_reference.commodity.totalposnum(l_cmid)=length(l_posprofit);     
        % �ܽ��״���
        g_reference.commodity.totaltradenum(l_cmid)=length(l_posprofit);
        % ƽ��ÿ�콻�״���
        g_reference.commodity.totaltradenumperday(l_cmid)=g_reference.commodity.totaltradenum(l_cmid)/g_reference.commodity.totaltradedays(l_cmid); 
        % ӯ�����״���
        g_reference.commodity.profittradenum(l_cmid)=sum(l_posprofit>0); 
        % �����״���
        g_reference.commodity.losstradenum(l_cmid)=sum(l_posprofit<=0);
        % ӯ�����״����ı���
        g_reference.commodity.profittraderate(l_cmid)=g_reference.commodity.profittradenum(l_cmid)/g_reference.commodity.totaltradenum(l_cmid);
        % ��󵥱�ӯ�����
        if isempty(l_posprofit(l_posprofit>0))
            g_reference.commodity.maxprofit(l_cmid)=0;
            % ÿ������ӯ��
            g_reference.commodity.profitpertrade(l_cmid)=0;             
        else
            g_reference.commodity.maxprofit(l_cmid)=max(l_posprofit(l_posprofit>0)); 
        % ÿ������ӯ��
        g_reference.commodity.profitpertrade(l_cmid)=sum(l_posprofit(l_posprofit>0))....
            /g_reference.commodity.profittradenum(l_cmid); 
        end
        % ��󵥱ʿ�����
        if isempty(l_posprofit(l_posprofit<0))
            g_reference.commodity.maxloss(l_cmid)=0;
            % ÿ�����׿���
            g_reference.commodity.losspertrade(l_cmid)=0;            
        else
            g_reference.commodity.maxloss(l_cmid)=min(l_posprofit(l_posprofit<0));
        % ÿ�����׿���
        g_reference.commodity.losspertrade(l_cmid)=sum(l_posprofit(l_posprofit<=0))....
            /g_reference.commodity.losstradenum(l_cmid);
        end        
        % ����ÿ������ӯ����
        g_reference.commodity.returnpertrade(l_cmid)=sum(l_posprofit)....
            /g_reference.commodity.totaltradenum(l_cmid);
        % ����ֵ
        g_reference.commodity.expectedvalue(l_cmid)=g_reference.commodity.returnpertrade(l_cmid)/(abs(g_reference.commodity.losspertrade(l_cmid)+1)); 
        % ������
        [l_maxdrawdown, l_maxdrawdownspread]=maxdrawdown(g_reportset.commodity(l_cmid).dailyinfo.profit(l_startid:l_endid)...
            -g_reportset.commodity(l_cmid).dailyinfo.profit(l_startid),'arithmetic');
        g_reference.commodity.maxdrawdown(l_cmid)=l_maxdrawdown; 
        % ������
        g_reference.commodity.maxdrawdownspread(l_cmid)=l_maxdrawdownspread(2)-l_maxdrawdownspread(1);
    else 
        % ��������
        l_startdatenum=g_reportset.commodity(l_cmid).startdatenum;
        l_enddatenum=g_reportset.commodity(l_cmid).enddatenum;
        % ��������
        l_startdatevec=datevec(g_reportset.commodity(l_cmid).startdatenum);
        l_enddatevec=datevec(g_reportset.commodity(l_cmid).enddatenum);
        % ���
        l_yearnum=l_enddatevec(1,1)-l_startdatevec(1,1);    
        g_reference.commodity.name(l_cmid)=g_reportset.commodity(l_cmid).name;
        % Ͷ���ʽ�
        g_reference.commodity.costinput(l_cmid)=0; 
        % �µ����� �ڴ˴�û�а취����
        % g_reference.commodity.numoforder(l_cmid)=[]; 
        % ��ӯ������
        g_reference.commodity.totalnetprofit(l_cmid)=0;   
        % ëӯ��
        g_reference.commodity.grossprofit(l_cmid)=0; 
        % ë����
        g_reference.commodity.grossloss(l_cmid)=0;
        % �»ر���
        l_monthprofit=zeros(1,(12*(l_yearnum+1)));
        l_yearprofit=zeros(1,(l_yearnum+1));
        l_numofmonth=0;
        l_numofyear=0;
        for l_yearid=l_startdatevec(1,1):l_enddatevec(1,1)
            for l_monthid=1:12
                l_numofmonth=l_numofmonth+1;
                l_dayid=eomday(l_yearid,l_monthid);
                l_dayvec=[l_yearid,l_monthid,l_dayid,0,0,0];
                l_endofmonthnum=datenum(l_dayvec);
                % ��������
                l_monthprofit(l_numofmonth)=g_reportset.commodity(l_cmid).dailyinfo.profit(l_endofmonthnum-l_startdatenum+1)....
                    -g_reportset.commodity(l_cmid).dailyinfo.profit(l_startid);
            end
            l_numofyear=l_numofyear+1;
            l_yearprofit(l_numofyear)=l_monthprofit(l_numofmonth);
        end
        l_trademonthrate=(l_monthprofit-[0,l_monthprofit(1:(length(l_monthprofit)-1))]);
        g_reference.commodity.monthreturnrate(l_cmid).data=reshape(l_trademonthrate,[12,l_yearnum+1]);
        % ��ƽ���ر���
        g_reference.commodity.avemonthreturnrate(l_cmid)=0;
        % ��ر���
        l_tradeyearrate=(l_yearprofit-[0,l_yearprofit(1:(length(l_yearprofit)-1))]);
        g_reference.commodity.yearreturnrate(l_cmid).data=l_tradeyearrate; 
        g_reference.commodity.years(l_cmid).data=l_startdatevec(1,1):l_enddatevec(1,1);
        % ��ƽ���ر���
        g_reference.commodity.aveyearreturnrate(l_cmid)=0;
        % �ܽ�������
        g_reference.commodity.totaltradedays(l_cmid)=0;
        % �ܿ��ִ���
        g_reference.commodity.totalposnum(l_cmid)=0;     
        % �ܽ��״���
        g_reference.commodity.totaltradenum(l_cmid)=0;
        % ƽ��ÿ�콻�״���
        g_reference.commodity.totaltradenumperday(l_cmid)=0; 
        % ӯ�����״���
        g_reference.commodity.profittradenum(l_cmid)=0; 
        % �����״���
        g_reference.commodity.losstradenum(l_cmid)=0;
        % ӯ�����״����ı���
        g_reference.commodity.profittraderate(l_cmid)=0;
        % ��󵥱�ӯ�����
        g_reference.commodity.maxprofit(l_cmid)=0; 
        % ��󵥱ʿ�����
        g_reference.commodity.maxloss(l_cmid)=0;
        % ÿ������ӯ��
        g_reference.commodity.profitpertrade(l_cmid)=0; 
        % ÿ�����׿���
        g_reference.commodity.losspertrade(l_cmid)=0;
        % ����ÿ������ӯ����
        g_reference.commodity.returnpertrade(l_cmid)=0;
        % ����ֵ
        g_reference.commodity.expectedvalue(l_cmid)=0; 
        % ������
        g_reference.commodity.maxdrawdown(l_cmid)=0; 
        % ������
        g_reference.commodity.maxdrawdownspread(l_cmid)=0;
    end
end
% ������ܺ�Ĳ���ָ��
l_startid=1;
l_endid=g_reportset.enddatenum-g_reportset.startdatenum+1;
if l_setwindow
    if l_startwindownum>=g_reportset.startdatenum
        l_startid=l_startwindownum-g_reportset.startdatenum+1;
    else
        l_startwindownum=g_reportset.startdatenum;
    end
    if l_endwindownum<=g_reportset.enddatenum
        l_endid=l_endwindownum-g_reportset.startdatenum+1;
    else
        l_endwindownum=g_reportset.enddatenum;
    end       
end

% ��������
l_startdatenum=g_reportset.startdatenum;
l_enddatenum=g_reportset.enddatenum;
% ��������
l_startdatevec=datevec(l_startwindownum);
l_enddatevec=datevec(l_endwindownum);    
% ���
l_yearnum=l_enddatevec(1,1)-l_startdatevec(1,1);    
g_reference.name={'����'};

% Ͷ���ʽ�
g_reference.costinput=max(abs(g_reportset.dailyinfo.margin(l_startid:l_endid))); 
% �µ�����
g_reference.commodity.numoforder=floor(max(g_reference.commodity.costinput)./g_reference.commodity.costinput); 
g_reference.numoforder=0;
% ��ӯ������
% l_tradeprofit=g_reportset.record.trade.profit(...
%     (datenum(g_reportset.record.trade.cpdate)<=l_endwindownum)&(datenum(g_reportset.record.trade.opdate)>=l_startwindownum));
l_posprofit=g_reportset.record.pos.profit(...
    (datenum(g_reportset.record.pos.cpdate)<=l_endwindownum)&(datenum(g_reportset.record.pos.opdate)>=l_startwindownum)); 
g_reference.totalnetprofit=sum(l_posprofit); 
% ëӯ��
g_reference.grossprofit=sum(l_posprofit(l_posprofit>0)); 
% ë����
g_reference.grossloss=sum(l_posprofit(l_posprofit<0));
% �»ر���
l_monthprofit=zeros(1,(12*(l_yearnum+1)));
l_yearprofit=zeros(1,(l_yearnum+1));
l_numofmonth=0;
l_numofyear=0;
for l_yearid=l_startdatevec(1,1):l_enddatevec(1,1)
    for l_monthid=1:12
        l_numofmonth=l_numofmonth+1;
        l_dayid=eomday(l_yearid,l_monthid);
        l_dayvec=[l_yearid,l_monthid,l_dayid,0,0,0];
        l_endofmonthnum=datenum(l_dayvec);
        % ��������
        l_monthprofit(l_numofmonth)=g_reportset.dailyinfo.profit(l_endofmonthnum-l_startdatenum+1)-g_reportset.dailyinfo.profit(l_startid);
    end
    l_numofyear=l_numofyear+1;
    l_yearprofit(l_numofyear)=l_monthprofit(l_numofmonth);
end
l_trademonthrate=(l_monthprofit-[0,l_monthprofit(1:(length(l_monthprofit)-1))])/g_reference.costinput;
g_reference.monthreturnrate.data=reshape(l_trademonthrate,[12,l_yearnum+1]);
% ��ƽ���ر���
l_tradetime=l_endid-l_startid+1;
l_monthnum=ceil(l_tradetime/30); 
g_reference.avemonthreturnrate=l_monthprofit(l_numofmonth)/g_reference.costinput/l_monthnum;
% ��ر���
l_tradeyearrate=(l_yearprofit-[0,l_yearprofit(1:(length(l_yearprofit)-1))])/g_reference.costinput;
g_reference.yearreturnrate.data=l_tradeyearrate; 
g_reference.years.data=l_startdatevec(1,1):l_enddatevec(1,1);
% ��ƽ���ر���
l_yearnum=ceil(l_tradetime/365); 
g_reference.aveyearreturnrate=l_yearprofit(l_numofyear)/g_reference.costinput/l_yearnum;
% �ܽ�������
g_reference.totaltradedays=l_tradetime;
% �ܿ��ִ���
g_reference.totalposnum=length(l_posprofit);     
% �ܽ��״���
g_reference.totaltradenum=length(l_posprofit);
% ƽ��ÿ�콻�״���
g_reference.totaltradenumperday=g_reference.totaltradenum/g_reference.totaltradedays; 
% ӯ�����״���
g_reference.profittradenum=sum(l_posprofit>0); 
% �����״���
g_reference.losstradenum=sum(l_posprofit<=0);
% ӯ�����״����ı���
g_reference.profittraderate=g_reference.profittradenum/g_reference.totaltradenum;
% ��󵥱�ӯ�����
if isempty(l_posprofit(l_posprofit>0))
    g_reference.maxprofit=0;
    % ÿ������ӯ��
    g_reference.profitpertrade=0; 
else
    g_reference.maxprofit=max(l_posprofit(l_posprofit>0)); 
% ÿ������ӯ��
g_reference.profitpertrade=sum(l_posprofit(l_posprofit>0))....
    /g_reference.profittradenum; 
end
% ��󵥱ʿ�����
if isempty(l_posprofit(l_posprofit<0))
    g_reference.maxloss=0;
    % ÿ�����׿���
    g_reference.losspertrade=0;    
else
    g_reference.maxloss=min(l_posprofit(l_posprofit<=0));
% ÿ�����׿���
g_reference.losspertrade=sum(l_posprofit(l_posprofit<=0))....
    /g_reference.losstradenum;
end  

% ����ÿ������ӯ����
g_reference.returnpertrade=sum(l_posprofit)....
    /g_reference.totaltradenum;
% ����ֵ
g_reference.expectedvalue=g_reference.returnpertrade/(abs(g_reference.losspertrade)+1); 
% ������
[l_maxdrawdown, l_maxdrawdownspread]=maxdrawdown(g_reportset.dailyinfo.profit(l_startid:l_endid)...
    -g_reportset.dailyinfo.profit(l_startid),'arithmetic');
g_reference.maxdrawdown=l_maxdrawdown; 
% ������
g_reference.maxdrawdownspread=l_maxdrawdownspread(2)-l_maxdrawdownspread(1);


% ��������
l_titlenames=fieldnames(g_reference.sort);
if ~isempty(l_titlenames)
    l_sortid=[];
    l_weight=zeros(1,length(l_titlenames));
    for l_titleid=1:length(l_titlenames)
        l_commandstr=sprintf('l_weight(l_titleid)=g_reference.sort.%s.weight;',l_titlenames{l_titleid});
        eval(l_commandstr);
        l_commandstr=sprintf('[l_sortvalue,l_sortid(l_titleid,:)]=sort(g_reference.commodity.%s,2,g_reference.sort.%s.direction);',...
            l_titlenames{l_titleid},l_titlenames{l_titleid});
        eval(l_commandstr);
        l_commandstr=sprintf('g_reference.sort.%s.order=g_reference.commodity.name(l_sortid(l_titleid,:));',l_titlenames{l_titleid});
        eval(l_commandstr);
    end
    [l_sortvalue,l_orderarray]=sort(l_sortid,2,'ascend');
    l_totalweight=sum(l_orderarray.*repmat(l_weight',1,length(g_reportset.commodity)),1);
    [l_sortvalue,l_sortid((length(l_titlenames)+1),:)]=sort(l_totalweight,2);
    g_reference.sortorder=g_reference.commodity.name(l_sortid((length(l_titlenames)+1),:));
end
end