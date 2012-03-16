function out_delivermonths=ZR_FUN_QueryDeliverMonths(in_commodityid)
% 查询该品种的主力合约
% 输入：品种名
% 返回：查询得到的数据
l_sqlstr1='select delivermonth from commodity_t';
l_sqlstr1=strcat(l_sqlstr1,' where commodityid=''',in_commodityid,'''');

% 连接数据库
l_conn=database('futuretest','root','123456');
l_cur=fetch(exec(l_conn,l_sqlstr1));
l_data=l_cur.data;

% 读入数据
if(strcmp(l_data,'No Data'))
    error('没有品种%s主力月份信息',in_commodityid);
else
    out_delivermonths=l_data(:,1)';
end
close(l_cur);
close(l_conn);
end