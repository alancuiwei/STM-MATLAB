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
l_dailyinfodb=struct();

% �������Ƶ�ʱ�䣬ɸѡ
if (strcmp(g_tables.startdate,'nolimit')...
    &&strcmp(g_tables.enddate,'nolimit'))
    % û������
    l_startid=1;
    l_endid=length(g_reportset.dailyinfo.dailydatenum);
else
    l_startdatenum=0;
    l_enddatenum=inf;
    if ~strcmp(g_tables.enddate,'nolimit')
        % ��������������
        % ��������
        l_enddatenum=datenum(g_tables.enddate,'yyyy-mm-dd');            
    end
    if ~strcmp(g_tables.startdate,'nolimit')
        % ��ʼ����������
        % ��������
        l_startdatenum=datenum(g_tables.startdate,'yyyy-mm-dd');            
    end
    % �����Լ����ʼid
    l_startid=find(g_reportset.dailyinfo.dailydatenum>=l_startdatenum,1,'first');
    l_endid=find(g_reportset.dailyinfo.dailydatenum<=l_enddatenum,1,'last');
end
l_dailyinfodb.dailydatenum=l_dailyinfo.dailydatenum(l_startid:l_endid);
l_dailyinfodb.profit=l_dailyinfo.profit(l_startid:l_endid);

l_sqlstr1='delete from profitchart ';
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',g_tables.strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',num2str(g_tables.userid),' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',num2str(g_tables.ordernum),' ');
% �������ݿ�
% l_conn=database('webfuturetest_101','root','123456');
l_conn=ZR_DATABASE_AccessDB('webfuturetest_101','conn');
exec(l_conn,l_sqlstr1);
l_colnames={'dateint';'profit';'strategyid';'userid';'ordernum'};
l_strategyid=repmat({g_tables.strategyid},length(l_dailyinfodb.dailydatenum),1);
l_userid=repmat({str2double(g_tables.userid)},length(l_dailyinfodb.dailydatenum),1);
l_ordernum=repmat({str2double(g_tables.ordernum)},length(l_dailyinfodb.dailydatenum),1);
l_exdata=cat(2,num2cell(l_dailyinfodb.dailydatenum'),num2cell(l_dailyinfodb.profit'),l_strategyid,l_userid,l_ordernum);
insert(l_conn, 'profitchart', l_colnames, l_exdata);
close(l_conn);
end