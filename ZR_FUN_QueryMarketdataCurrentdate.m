function out_currentdate=ZR_FUN_QueryMarketdataCurrentdate()
% 得到当前行情更新的日期
% 返回：查询得到的数据
l_sqlstr1='select currentdate from marketdaydata_t order by currentdate DESC limit 0,1;';

% 连接数据库
l_conn=database('futuretest','root','123456');
l_cur=fetch(exec(l_conn,l_sqlstr1));
l_data=l_cur.data;

% 读入数据
if(strcmp(l_data,'No Data'))
    error('没有合约行情日期');
else
    out_currentdate=l_data(:,1)';
end
close(l_cur);
close(l_conn);
end