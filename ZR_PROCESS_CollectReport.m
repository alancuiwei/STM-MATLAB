function ZR_PROCESS_CollectReport()
%%%%%%%% ���ܲ��Ա���
global g_report;
% ��ʼ���׵����ڣ��ϲ�dailyinfo�е�margin,posnum,profit,tradecharge����ʹ��
l_startdatenum=min(cat(1,g_report.commodity(:).startdatenum));
l_startdatevec=datevec(l_startdatenum);
l_startdatenum=datenum([l_startdatevec(1),1,1,0,0,0]);
g_report.startdatenum=l_startdatenum;
l_enddatenum=max(cat(1,g_report.commodity(:).enddatenum));
l_enddatevec=datevec(l_enddatenum);
l_enddatenum=datenum([l_enddatevec(1),12,31,0,0,0]);
g_report.enddatenum=l_enddatenum;
% ��ʼ��ʱ�䱣֤������
g_report.dailyinfo.dailydatenum=l_startdatenum:l_enddatenum;
% ��ʼ��ʱ�䱣֤������
g_report.dailyinfo.margin=zeros(1,(l_enddatenum-l_startdatenum+1));
% ��ʼ��ʱ���λ����
g_report.dailyinfo.posnum=zeros(1,(l_enddatenum-l_startdatenum+1));
% ��ʼ��ʱ���������
g_report.dailyinfo.profit=zeros(1,(l_enddatenum-l_startdatenum+1));
% ��ʼ�����׷�
g_report.dailyinfo.tradecharge=zeros(1,(l_enddatenum-l_startdatenum+1));
% l_posid=0;
% l_tradeid=0;
for l_cmid=1:length(g_report.commodity)
     % û�б���
    if(g_report.commodity(l_cmid).record.pos.num<1)
%         fprintf('%s:�޽���',g_report.commodity(l_cmid).name);
        continue;
    end 
    % pos ��λ����    
    l_titlenames=fieldnames(g_report.record.pos);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
            if eval(l_judge)
                l_commandstr=strcat(l_commandstr,sprintf('g_report.record.pos.%s=g_report.record.pos.%s+g_report.commodity(l_cmid).record.pos.%s;',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));
            else
                l_commandstr=strcat(l_commandstr,sprintf('g_report.record.pos.%s=[g_report.record.pos.%s,g_report.commodity(l_cmid).record.pos.%s];',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));            
            end     
        end
    end
    eval(l_commandstr);       
%     % trade ���ױ���   
%     l_titlenames=fieldnames(g_report.record.trade);
%     l_commandstr='';
%     if ~isempty(l_titlenames)
%         for l_titleid=1:length(l_titlenames)
%             l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
%             if eval(l_judge)
%                 l_commandstr=strcat(l_commandstr,sprintf('g_report.record.trade.%s=g_report.record.trade.%s+g_report.commodity(l_cmid).record.trade.%s;',...
%                     l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));
%             else
%                 l_commandstr=strcat(l_commandstr,sprintf('g_report.record.trade.%s=[g_report.record.trade.%s,g_report.commodity(l_cmid).record.trade.%s];',...
%                     l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));            
%             end     
%         end
%     end
%     eval(l_commandstr);  
    % ����daily��Ϣ
    l_startdateid=g_report.commodity(l_cmid).startdatenum-l_startdatenum+1;
    l_enddateid=g_report.commodity(l_cmid).enddatenum-l_startdatenum+1;
    g_report.dailyinfo.margin(l_startdateid:l_enddateid)=g_report.dailyinfo.margin(l_startdateid:l_enddateid)+g_report.commodity(l_cmid).dailyinfo.margin;
    g_report.dailyinfo.posnum(l_startdateid:l_enddateid)=g_report.dailyinfo.posnum(l_startdateid:l_enddateid)+g_report.commodity(l_cmid).dailyinfo.posnum;
    g_report.dailyinfo.profit(l_startdateid:l_enddateid)=g_report.dailyinfo.profit(l_startdateid:l_enddateid)+g_report.commodity(l_cmid).dailyinfo.profit;
    g_report.dailyinfo.tradecharge(l_startdateid:l_enddateid)=g_report.dailyinfo.tradecharge(l_startdateid:l_enddateid)...
        +g_report.commodity(l_cmid).dailyinfo.tradecharge; 
end
end