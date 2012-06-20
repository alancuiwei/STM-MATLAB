function out_delivermonths=ZR_FUN_QueryDeliverMonths(in_commodityid)
% 查询该品种的主力合约
% 输入：品种名
% 返回：查询得到的数据
l_sqlstr1='select delivermonth from commodity_t';
l_sqlstr1=strcat(l_sqlstr1,' where commodityid=''',in_commodityid,'''');

% 连接数据库
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% 读入数据
if(strcmp(l_data,'No Data'))
    error('没有品种%s主力月份信息',in_commodityid);
else
    out_delivermonths=l_data(:,1)';
end

end