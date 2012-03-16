function ZR_PROCESS_SaveReferenceToDB(in_strategyid)
% 将策略性能参数写入数据库
global g_tables;
global g_reportset;
l_sqlstr1='delete from strategyreference_t ';
l_sqlstr1=strcat(l_sqlstr1,' where rightid regexp ''^',in_strategyid,'''');
l_rightid=cell(1,length(g_reportset.commodity));
for l_id=1:length(g_reportset.commodity)
    l_rightid(l_id)=g_reportset.commodity(l_id).record.pos.rightid(1);
end
l_strategyid=strcat(in_strategyid,'000000');
l_rightid(end+1)={l_strategyid};
% 连接数据库
l_conn=database('futuretest','root','123456');
exec(l_conn,l_sqlstr1);
l_colnames={'rightid';'minmarginaccount';'totalnetprofit';'grossprofit';'grossloss';'avemonthreturn';'aveyearreturn';'toaltradingdays';'totaltrades';'avedaytrades';...
    'numwintrades';'numlosstrades';'percentprofitable';'largestwintrade';'largestlosstrade';'avewintrade';'avelosstrade';'avetrade';'expectvalue';'maxdrawdown';...
    'maxdrawdowndays'};
l_exdata=g_tables.tabledata.reference([2,4:end],2:end);
l_exdata=cat(1,l_rightid,l_exdata);
insert(l_conn, 'strategyreference_t', l_colnames, l_exdata')
close(l_conn);
end