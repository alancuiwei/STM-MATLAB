function ZR_PROCESS_SaveReportsetToDB()
% 将交易记录存入数据库中
global g_tables;
l_sqlstr1='delete from strategypositionrecord_t ';
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',g_tables.strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',g_tables.userid,' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',g_tables.ordernum,' ');
% 连接数据库
% l_conn=database('webfuturetest_101','root','123456');
l_conn=ZR_DATABASE_AccessDB('webfuturetest_101','conn');
exec(l_conn,l_sqlstr1);
l_colnames={'rightid';'tradeobject';'isclosepos';'openposdate';'closeposdate';'openposprice';'closeposprice';'marginaccount';'profit';'strategyid';'userid';'ordernum'};
l_strategyid=repmat({g_tables.strategyid},length(g_tables.tabledata.record.pos(2:end,1)),1);
l_userid=repmat({str2double(g_tables.userid)},length(g_tables.tabledata.record.pos(2:end,1)),1);
l_ordernum=repmat({str2double(g_tables.ordernum)},length(g_tables.tabledata.record.pos(2:end,1)),1);
l_exdata=cat(2,g_tables.tabledata.record.pos(2:end,[1,2,3,4,5,6,7,8,11]),l_strategyid,l_userid,l_ordernum);
insert(l_conn, 'strategypositionrecord_t', l_colnames, l_exdata);
close(l_conn);
end