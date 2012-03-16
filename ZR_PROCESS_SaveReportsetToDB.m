function ZR_PROCESS_SaveReportsetToDB(in_strategyid)
% 将交易记录存入数据库中
global g_tables;
l_sqlstr1='delete from strategypositionrecord_t ';
l_sqlstr1=strcat(l_sqlstr1,' where rightid regexp ''^',in_strategyid,'''');
% 连接数据库
l_conn=database('futuretest','root','123456');
exec(l_conn,l_sqlstr1);
l_colnames={'rightid';'tradeobject';'isclosepos';'openposdate';'closeposdate';'openposprice';'closeposprice';'marginaccount';'profit'};
l_exdata=g_tables.tabledata.record.pos(2:end,[1,2,4,5,6,7,8,11,14]);
insert(l_conn, 'strategypositionrecord_t', l_colnames, l_exdata)
close(l_conn);
end