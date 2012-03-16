function out_contractdata = ZR_FUN_QueryContractData(in_contractname)
% 从数据库中得到该合约的数据
% 输入：合约名
% 返回：查询得到的数据：struct(op,hp,lp,cp,vl.oi,index)
%       合约数据（日期、开、高、低、收、交易量、持仓量）
l_sqlstr1='select currentdate,openprice,highprice,lowprice,closeprice,volume,openinterest from marketdaydata_t';
l_sqlstr1=strcat(l_sqlstr1,' where contractid=''', in_contractname, ''' order by currentdate');

% 连接数据库
l_conn=database('futuretest','root','123456');
l_cur=fetch(exec(l_conn,l_sqlstr1));
l_data=l_cur.data;

% 读入数据
if(strcmp(l_data,'No Data'))
    out_contractdata=[];
    error('%s没有合约数据',cell2mat(in_contractname));
else
    out_contractdata=struct('date',{l_data(:,1)}',...
        'op',cell2mat(l_data(:,2)),...
        'hp',cell2mat(l_data(:,3)),...
        'lp',cell2mat(l_data(:,4)),...
        'cp',cell2mat(l_data(:,5)),...
        'vl',cell2mat(l_data(:,6)),...
        'oi',cell2mat(l_data(:,7)),...
        'datalen',length(l_data(:,2)));
end
close(l_cur);
close(l_conn);

end