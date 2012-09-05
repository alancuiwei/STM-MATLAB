function ZR_PROCESS_SaveDailyInfoToDB()
% 将交易日线数据存入数据库中
global g_reportset;
global g_tables;
l_1970datenum=datenum('1970-01-01');
% 初始化时间保证金向量
l_dailyinfo.dailydatenum=(g_reportset.dailyinfo.dailydatenum-l_1970datenum)*86400000;
% 初始化时间保证金向量
% l_dailyinfo.margin=g_reportset.dailyinfo.margin;
% 初始化时间仓位向量
% l_dailyinfo.posnum=g_reportset.dailyinfo.posnum;
% 初始化时间获利向量
l_dailyinfo.profit=g_reportset.dailyinfo.profit;
% 初始化交易费
l_dailyinfo.tradecharge=g_reportset.dailyinfo.tradecharge;
l_dailyinfodb=struct();

% 根据限制的时间，筛选
if (strcmp(g_tables.startdate,'nolimit')...
    &&strcmp(g_tables.enddate,'nolimit'))
    % 没有限制
    l_startid=1;
    l_endid=length(g_reportset.dailyinfo.dailydatenum);
else
    l_startdatenum=0;
    l_enddatenum=inf;
    if ~strcmp(g_tables.enddate,'nolimit')
        % 结束日期有限制
        % 日期数字
        l_enddatenum=datenum(g_tables.enddate,'yyyy-mm-dd');            
    end
    if ~strcmp(g_tables.startdate,'nolimit')
        % 开始日期有限制
        % 日期数字
        l_startdatenum=datenum(g_tables.startdate,'yyyy-mm-dd');            
    end
    % 计算合约的起始id
    l_startid=find(g_reportset.dailyinfo.dailydatenum>=l_startdatenum,1,'first');
    l_endid=find(g_reportset.dailyinfo.dailydatenum<=l_enddatenum,1,'last');
end
l_dailyinfodb.dailydatenum=l_dailyinfo.dailydatenum(l_startid:l_endid);
l_dailyinfodb.profit=l_dailyinfo.profit(l_startid:l_endid);

l_sqlstr1='delete from profitchart ';
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',g_tables.strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',num2str(g_tables.userid),' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',num2str(g_tables.ordernum),' ');
% 连接数据库
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