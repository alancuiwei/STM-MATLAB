function out_commodityinfo=ZR_FUN_QueryCommodityInfo(in_cmname)
% �����ݿ��еõ���Ʒ�ֵ���Ϣ
% ���룺Ʒ����
% ���أ���ѯ�õ�����Ϣ��struct(tick,margin,tradecharge,issinglemargin)
%      Ʒ����Ϣ����С�۸���������֤�𣬽��������ѣ��Ƿ񵥱���ȡ��

l_sqlstr1='select commodity_t.commodityid,commodity_t.tick,commodity_t.exchtrademargin+ibbranchcommodity_t.trademargingap,';
l_sqlstr1=strcat(l_sqlstr1,...
    'ibbranchcommodity_t.tradecharge,commodity_t.issinglemargin,commodity_t.tradeunit from commodity_t,ibbranchcommodity_t ');
l_sqlstr1=strcat(l_sqlstr1,...
    ' where commodity_t.commodityid=''', in_cmname, ''' and ibbranchcommodity_t.commodityid=''', in_cmname, ...
    ''' and commodity_t.commodityid=ibbranchcommodity_t.commodityid');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('futuretest',l_sqlstr1);

% ��������,���û��Ʒ����Ϣ���򱨴�
if(strcmp(l_data,'No Data'))
    out_commodityinfo=[];
    error('%sû��Ʒ����Ϣ',cell2mat(in_cmname));
else
    out_commodityinfo=struct('commodityid',l_data(1),...
        'tick',cell2mat(l_data(2)),...
        'margin',cell2mat(l_data(3))+0.05,...
        'tradecharge',cell2mat(l_data(4)),...
        'issinglemargin',cell2mat(l_data(5)),...
        'tradeunit',cell2mat(l_data(6)));
end

end