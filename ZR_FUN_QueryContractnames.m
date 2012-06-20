function out_contractnames=ZR_FUN_QueryContractnames(in_commodityid,in_months)
% 查询该品种所有的合约名
% 输入：品种名
% 返回：查询得到的数据
l_sqlstr1='select distinct _t.contractid from (select contractid from marketdaydata_t';
l_sqlstr1=strcat(l_sqlstr1,' where contractid regexp ''^',in_commodityid,'[0-9].*(',in_months,')$'' order by currentdate) _t');

% 连接数据库
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% 读入数据
if(strcmp(l_data,'No Data'))
    error('没有品种%s合约信息',in_commodityid);
else
    out_contractnames=l_data(:,1)';
end

end
