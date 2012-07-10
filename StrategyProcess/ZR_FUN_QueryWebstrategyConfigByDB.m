function out_data=ZR_FUN_QueryWebstrategyConfigByDB()
% 查询webstrategy表得到，得到需要从database中配置的strategyid/userid/ordernum。
% 从数据库中得到该策略的信息
% 返回：查询得到的数据
l_sqlstr1='SELECT strategyid, userid, ordernum FROM strategyweb where configtype=''database''';

% 连接数据库
l_data=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_sqlstr1);

% 读入数据
if(strcmp(l_data,'No Data'))
    error('没有策略信息');
else
    out_data=struct('strategyid',{l_data(:,1)}',...
        'userid',{l_data(:,2)}',...
        'ordernum',{l_data(:,3)}');
end

end