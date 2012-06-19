function out_contractinfo=ZR_FUN_QueryActiveContractInfo(in_contractname)
% 从数据库中得到该合约的信息
% 输入：合约名
% 返回：查询得到的数据：struct(daystolasttradeday)
l_sqlstr1='select lasttradedate,daystolasttradedate from contract_t where lasttradedate>CURRENT_DATE ';
l_sqlstr1=strcat(l_sqlstr1,' and contractid=''', in_contractname, '''');

% 连接数据库
l_data=ZR_DATABASE_AccessDB('futuretest',l_sqlstr1);

% 读入数据
if(strcmp(l_data,'No Data'))
    out_contractinfo=struct('lasttradedate','2000-01-01',...
        'daystolasttradedate',-1);
    % error('%s没有合约信息',cell2mat(in_contractname));
else
    out_contractinfo=struct('lasttradedate',{l_data(:,1)}',...
        'daystolasttradedate',cell2mat(l_data(:,2)));
end

end