function ZR_STOCK_PROCESS_OrderlistReportPerCommodity(in_cmid)
%%%%%%%% ����ÿһ��Ʒ�ֵı�����Ϣ
global g_orderdata;
global g_report;
global g_rawdata;
% ������Ʒ�����е�������
l_pairnum=length(g_orderdata);
l_orderposid=0;
g_report.commodity(in_cmid).name=g_rawdata.commodity.name;
g_report.commodity(in_cmid).orderlist.num=0;
for l_pairid=1:l_pairnum
%     if(isempty(g_orderdata(l_pairid).pos.num))
% %         fprintf('%s:�޽���\n',cell2mat(g_tradedata(l_pairid).pos.name));
%         continue;
%     end        
  l_titlenames=fieldnames(g_report.orderlist);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
            if eval(l_judge)
%                 l_commandstr=strcat(l_commandstr,...
%                     sprintf('g_report.commodity(in_cmid).orderlist.%s=l_orderposid+g_orderdata(l_pairid).%s;',...
%                     l_titlenames{l_titleid},l_titlenames{l_titleid}));
                eval('g_report.commodity(in_cmid).orderlist.num=l_orderposid+g_orderdata(l_pairid).num;');
            else
                l_commandstr=strcat(l_commandstr,...
                    sprintf('g_report.commodity(in_cmid).orderlist.%s((l_orderposid+1):g_report.commodity(in_cmid).orderlist.num)',...
                    l_titlenames{l_titleid}),sprintf('=g_orderdata(l_pairid).%s;',l_titlenames{l_titleid}));            
            end     
        end
    end
    eval(l_commandstr);  
    l_orderposid=g_report.commodity(in_cmid).orderlist.num;
end
% try
%     l_startdatenum=datenum(g_rawdata.contract(1).mkdata.date{1},'yyyy-mm-dd');
% catch
%     l_startdatenum=datenum(g_rawdata.pair(1).mkdata.date{1},'yyyy-mm-dd');
% end
% l_startdatevec=datevec(l_startdatenum);
% l_startdatenum=datenum([l_startdatevec(1),1,1,0,0,0]);
% % һ���һ��
% g_report.commodity(in_cmid).startdatenum=l_startdatenum;
% % l_enddatenum=max(l_cpdatenums);
% try
%     l_enddatenum=datenum(g_rawdata.contract(end).mkdata.date{end},'yyyy-mm-dd');    
% catch
%     l_enddatenum=datenum(g_rawdata.pair(end).mkdata.date{end},'yyyy-mm-dd');
% end
% l_enddatevec=datevec(l_enddatenum);
% l_enddatenum=datenum([l_enddatevec(1),12,31,0,0,0]);
% % һ�����һ��
% g_report.commodity(in_cmid).enddatenum=l_enddatenum;
% if g_report.commodity(in_cmid).record.pos.num>0
%     l_opdatenums=datenum(g_report.commodity(in_cmid).record.pos.opdate,'yyyy-mm-dd');
%     l_opdateids=l_opdatenums-l_startdatenum+1;
%     l_cpdatenums=datenum(g_report.commodity(in_cmid).record.pos.cpdate,'yyyy-mm-dd');
%     l_cpdateids=l_cpdatenums-l_startdatenum+1;
%     % ����daily���ݣ�margin,profit,posnum,tradecharge
%     % ��ʼ��ʱ�䱣֤������
%     g_report.commodity(in_cmid).dailyinfo.margin=zeros(1,(l_enddatenum-l_startdatenum+2));
%     % ��ʼ��ʱ���λ����
%     g_report.commodity(in_cmid).dailyinfo.posnum=zeros(1,(l_enddatenum-l_startdatenum+2));
%     % ��ʼ��ʱ���������
%     g_report.commodity(in_cmid).dailyinfo.profit=zeros(1,(l_enddatenum-l_startdatenum+2));
%     % ��ʼ�����׷�
%     g_report.commodity(in_cmid).dailyinfo.tradecharge=zeros(1,(l_enddatenum-l_startdatenum+2));
%     for l_index=1:length(l_opdateids)
%         % ��֤��
%         g_report.commodity(in_cmid).dailyinfo.margin(l_opdateids(l_index))=...
%             g_report.commodity(in_cmid).dailyinfo.margin(l_opdateids(l_index))+g_report.commodity(in_cmid).record.pos.margin(l_index);
%         g_report.commodity(in_cmid).dailyinfo.margin(l_cpdateids(l_index)+1)=...
%             g_report.commodity(in_cmid).dailyinfo.margin(l_cpdateids(l_index)+1)-g_report.commodity(in_cmid).record.pos.margin(l_index);
%         % ��λ
%         g_report.commodity(in_cmid).dailyinfo.posnum(l_opdateids(l_index))=...
%             g_report.commodity(in_cmid).dailyinfo.posnum(l_opdateids(l_index))+1;
%         g_report.commodity(in_cmid).dailyinfo.posnum(l_cpdateids(l_index)+1)=...
%             g_report.commodity(in_cmid).dailyinfo.posnum(l_cpdateids(l_index)+1)-1;
%         % ���׷�
%         g_report.commodity(in_cmid).dailyinfo.tradecharge(l_opdateids(l_index))=...
%             g_report.commodity(in_cmid).dailyinfo.tradecharge(l_opdateids(l_index))+g_report.commodity(in_cmid).record.pos.optradecharge(l_index);
%         g_report.commodity(in_cmid).dailyinfo.tradecharge(l_cpdateids(l_index))=...
%             g_report.commodity(in_cmid).dailyinfo.tradecharge(l_cpdateids(l_index))+g_report.commodity(in_cmid).record.pos.cptradecharge(l_index);
%         % ����,Ӧ�ôӿ������ڿ�ʼ�������п۳�����������
%         g_report.commodity(in_cmid).dailyinfo.profit(l_opdateids(l_index))=...
%             g_report.commodity(in_cmid).dailyinfo.profit(l_opdateids(l_index))-g_report.commodity(in_cmid).record.pos.optradecharge(l_index); 
%         g_report.commodity(in_cmid).dailyinfo.profit(l_cpdateids(l_index))=...
%             g_report.commodity(in_cmid).dailyinfo.profit(l_cpdateids(l_index))+g_report.commodity(in_cmid).record.pos.profit(l_index)...
%             +g_report.commodity(in_cmid).record.pos.optradecharge(l_index);  
%     end
%     % ����ÿ���Ӱ��
%     % ��ʼ��ʱ�䱣֤������
%     g_report.commodity(in_cmid).dailyinfo.margin=g_report.commodity(in_cmid).dailyinfo.margin(1:end-1);
%     % ��ʼ��ʱ���λ����
%     g_report.commodity(in_cmid).dailyinfo.posnum=g_report.commodity(in_cmid).dailyinfo.posnum(1:end-1);
%     % ��ʼ��ʱ���������
%     g_report.commodity(in_cmid).dailyinfo.profit=g_report.commodity(in_cmid).dailyinfo.profit(1:end-1);
%     % ��ʼ�����׷�
%     g_report.commodity(in_cmid).dailyinfo.tradecharge=g_report.commodity(in_cmid).dailyinfo.tradecharge(1:end-1);  
%     
%     g_report.commodity(in_cmid).dailyinfo.margin=cumsum(g_report.commodity(in_cmid).dailyinfo.margin);
%     g_report.commodity(in_cmid).dailyinfo.posnum=cumsum(g_report.commodity(in_cmid).dailyinfo.posnum);
%     g_report.commodity(in_cmid).dailyinfo.tradecharge=cumsum(g_report.commodity(in_cmid).dailyinfo.tradecharge);
%     g_report.commodity(in_cmid).dailyinfo.profit=cumsum(g_report.commodity(in_cmid).dailyinfo.profit);
% else
%     % ��ʼ��ʱ�䱣֤������
%     g_report.commodity(in_cmid).dailyinfo.margin=zeros(1,(l_enddatenum-l_startdatenum+1));
%     % ��ʼ��ʱ���λ����
%     g_report.commodity(in_cmid).dailyinfo.posnum=zeros(1,(l_enddatenum-l_startdatenum+1));
%     % ��ʼ��ʱ���������
%     g_report.commodity(in_cmid).dailyinfo.profit=zeros(1,(l_enddatenum-l_startdatenum+1));
%     % ��ʼ�����׷�
%     g_report.commodity(in_cmid).dailyinfo.tradecharge=zeros(1,(l_enddatenum-l_startdatenum+1));
% end    
%     % ��ʼ��ʱ������
%     g_report.commodity(in_cmid).dailyinfo.dailydatenum=l_startdatenum:l_enddatenum;
% end