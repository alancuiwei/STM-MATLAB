function ZR_PROCESS_SaveDailyInfoToDB()
% �������������ݴ������ݿ���
global g_reportset;
global g_tables;
l_1970datenum=datenum('1970-01-01');
% ��ʼ��ʱ�䱣֤������
l_dailyinfo.dailydatenum=(g_reportset.dailyinfo.dailydatenum-l_1970datenum)*86400000;
% ��ʼ��ʱ�䱣֤������
% l_dailyinfo.margin=g_reportset.dailyinfo.margin;
% ��ʼ��ʱ���λ����
% l_dailyinfo.posnum=g_reportset.dailyinfo.posnum;
% ��ʼ��ʱ���������
l_dailyinfo.profit=g_reportset.dailyinfo.profit;
% ��ʼ�����׷�
l_dailyinfo.tradecharge=g_reportset.dailyinfo.tradecharge;

l_sqlstr1='delete from profitchart ';
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',g_tables.strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',g_tables.userid,' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',g_tables.ordernum,' ');
% �������ݿ�
% l_conn=database('webfuturetest_101','root','123456');
l_conn=ZR_DATABASE_AccessDB('webfuturetest_101','conn');
exec(l_conn,l_sqlstr1);
l_colnames={'dateint';'profit';'strategyid';'userid';'ordernum'};
l_strategyid=repmat({g_tables.strategyid},length(l_dailyinfo.dailydatenum),1);
l_userid=repmat({str2double(g_tables.userid)},length(l_dailyinfo.dailydatenum),1);
l_ordernum=repmat({str2double(g_tables.ordernum)},length(l_dailyinfo.dailydatenum),1);
l_exdata=cat(2,num2cell(l_dailyinfo.dailydatenum'),num2cell(l_dailyinfo.profit'),l_strategyid,l_userid,l_ordernum);
insert(l_conn, 'profitchart', l_colnames, l_exdata);
close(l_conn);
end