function ZR_STOCK_PROCESS_SaveOrderlistToDB()
% 将交易记录存入数据库中
global g_tables;
l_sqlstr1='delete from strategyorderlist ';
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',g_tables.strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',num2str(g_tables.userid),' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',num2str(g_tables.ordernum),' ');
% 连接数据库
% l_conn=database('webfuturetest_101','root','123456');
l_conn=ZR_STOCK_DATABASE_AccessDB('webfuturetest_101','conn');
exec(l_conn,l_sqlstr1);
l_colnames={'name';'price';'direction';'strategyid';'userid';'ordernum'};
l_strategyid=repmat({g_tables.strategyid},length(g_tables.tabledata.orderlist(2:end,1)),1);
l_userid=repmat({g_tables.userid},length(g_tables.tabledata.orderlist(2:end,1)),1);
l_ordernum=repmat({g_tables.ordernum},length(g_tables.tabledata.orderlist(2:end,1)),1);
l_exdata=cat(2,g_tables.tabledata.orderlist(2:end,[1,2,3]),l_strategyid,l_userid,l_ordernum);
insert(l_conn, 'strategyorderlist', l_colnames, l_exdata);
close(l_conn);
end
