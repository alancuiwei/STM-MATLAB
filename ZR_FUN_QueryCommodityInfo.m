function out_commodityinfo=ZR_FUN_QueryCommodityInfo(in_cmname)
% 从数据库中得到该品种的信息
% 输入：品种名
% 返回：查询得到的信息：struct(tick,margin,tradecharge,issinglemargin)
%      品种信息（最小价格跳动，保证金，交易手续费，是否单边收取）

l_sqlstr1='select commodity_t.commodityid,commodity_t.tick,commodity_t.exchtrademargin+ibbranchcommodity_t.trademargingap,';
l_sqlstr1=strcat(l_sqlstr1,...
    'ibbranchcommodity_t.tradecharge,commodity_t.issinglemargin,commodity_t.tradeunit from commodity_t,ibbranchcommodity_t ');
l_sqlstr1=strcat(l_sqlstr1,...
    ' where commodity_t.commodityid=''', in_cmname, ''' and ibbranchcommodity_t.commodityid=''', in_cmname, ...
    ''' and commodity_t.commodityid=ibbranchcommodity_t.commodityid');

% 连接数据库
l_data=ZR_DATABASE_AccessDB('futuretest',l_sqlstr1);

% 读入数据,如果没有品种信息，则报错
if(strcmp(l_data,'No Data'))
    out_commodityinfo=[];
    error('%s没有品种信息',cell2mat(in_cmname));
else
    out_commodityinfo=struct('commodityid',l_data(1),...
        'tick',cell2mat(l_data(2)),...
        'margin',cell2mat(l_data(3))+0.05,...
        'tradecharge',cell2mat(l_data(4)),...
        'issinglemargin',cell2mat(l_data(5)),...
        'tradeunit',cell2mat(l_data(6)));
end

end