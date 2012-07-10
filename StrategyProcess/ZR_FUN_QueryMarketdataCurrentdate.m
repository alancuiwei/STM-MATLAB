function out_currentdate=ZR_FUN_QueryMarketdataCurrentdate()
% 得到当前行情更新的日期
% 返回：查询得到的数据
l_sqlstr1='select currentdate from marketdaydata_t order by currentdate DESC limit 0,1;';

% 连接数据库
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% 读入数据
if(strcmp(l_data,'No Data'))
    error('没有合约行情日期');
else
    out_currentdate=l_data(:,1)';
end

end