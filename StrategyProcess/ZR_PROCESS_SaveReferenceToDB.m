function ZR_PROCESS_SaveReferenceToDB()
% 将策略性能参数写入数据库
global g_tables;
global g_reportset;
l_sqlstr1='delete from strategyreference_t ';
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',g_tables.strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',g_tables.userid,' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',g_tables.ordernum,' ');
l_rightid=cell(1,length(g_reportset.commodity));
for l_id=1:length(g_reportset.commodity)
    l_rightid(l_id)=g_reportset.commodity(l_id).record.pos.rightid(1);
end
l_split=strfind(g_tables.strategyid,'-');
l_strategyid=strcat(g_tables.strategyid(1:l_split-1),'000000-',g_tables.strategyid(l_split+1:end),'000000');
l_rightid(end+1)={l_strategyid};
% 连接数据库
% l_conn=database('webfuturetest_101','root','123456');
l_conn=ZR_DATABASE_AccessDB('webfuturetest_101','conn');
exec(l_conn,l_sqlstr1);
l_colnames={'rightid';'minmarginaccount';'totalnetprofit';'grossprofit';'grossloss';'avemonthreturn';'aveyearreturn';'toaltradingdays';'totaltrades';'avedaytrades';...
    'numwintrades';'numlosstrades';'percentprofitable';'largestwintrade';'largestlosstrade';'avewintrade';'avelosstrade';'avetrade';'expectvalue';'maxdrawdown';...
    'maxdrawdowndays';'strategyid';'userid';'ordernum'};
l_strategyid=repmat({g_tables.strategyid},1,length(l_rightid));
l_userid=repmat({g_tables.userid},1,length(l_rightid));
l_ordernum=repmat({g_tables.ordernum},1,length(l_rightid));
l_exdata=g_tables.tabledata.reference([2,4:end],2:end);
l_exdata=cat(1,l_rightid,l_exdata,l_strategyid,l_userid,l_ordernum);
insert(l_conn, 'strategyreference_t', l_colnames, l_exdata')
close(l_conn);
end