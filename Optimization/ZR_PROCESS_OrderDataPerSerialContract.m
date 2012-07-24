function ZR_PROCESS_OrderDataPerSerialContract( )
%%%%%%%% 计算交易数据
% global g_traderecord;
% global g_rawdata;
% global g_tradedata;
global g_orderlist;
global g_orderdata;
% price
l_price(1)=g_orderlist.price(1);
% direction
l_margin(1)=g_orderlist.direction(1);
% % 交易手续费
% l_tradecharge(1)=g_rawdata.commodity.info(1).tradecharge;
% 记录交易情况
l_posid=0;
% 后续程序根据num值判断是否有开仓
g_tradedata.pos.num=[];
if ~isfield(g_orderlist,'price')
    g_traderecord.num=0;
else
    g_traderecord.num=length(g_orderlist.price);
end
% g_tradedata(in_contractid).pos.name=g_rawdata.contract(in_contractid).name;
if(g_traderecord.num>0)
    for l_index=1:g_traderecord.num
        % pos数量自增1
        l_posid=l_posid+1;
        if ~isempty(g_orderlist)
        g_orderdata.pos.price(l_posid)=g_orderlist.price(l_index);
        g_orderdata.pos.direction(l_posid)=g_orderlist.direction;
        g_orderdata.pos.name(l_posid)=g_prderlist.name;
        else
        g_orderdata.pos.price(l_posid)=0;
        g_orderdata.pos.direction(l_posid)=0;
        g_orderdata.pos.name(l_posid)=0;  
        end
    end
    g_tradedata.pos.num=l_posid;
end