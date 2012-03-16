function out_strategyinfo=ZR_FUN_QueryArbitrageInfo(in_strategyid)
% 查询套利权限表得到，套利对前后项的品种，比如CF、TA、a……，。
% 从数据库中得到该策略的信息
% 输入：策略名
% 返回：查询得到的数据
l_sqlstr1='select rightid,firstcommodityid,secondcommodityid,firstcommodityunit,secondcommodityunit from commodityright_t';
l_sqlstr1=strcat(l_sqlstr1,' where rightid regexp ''^',in_strategyid,'''');

% 连接数据库
l_conn=database('futuretest','root','123456');
l_cur=fetch(exec(l_conn,l_sqlstr1));
l_data=l_cur.data;

% 读入数据
if(strcmp(l_data,'No Data'))
    error('没有策略%s信息',in_stratedyid);
else
    out_strategyinfo=struct('rightid',{l_data(:,1)}',...
        'firstcommodityid',{l_data(:,2)}',...
        'secondcommodityid',{l_data(:,3)}',...
        'firstcommodityunit',cell2mat(l_data(:,4)),...
        'secondcommodityunit',cell2mat(l_data(:,5)));
end
close(l_cur);
close(l_conn);
end