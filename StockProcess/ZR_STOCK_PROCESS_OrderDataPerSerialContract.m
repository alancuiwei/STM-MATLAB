function ZR_STOCK_PROCESS_OrderDataPerSerialContract( )
%%%%%%%% 计算交易数据
global g_orders;
global g_orderdata;
% 记录交易情况
l_orderposid=0;
% 后续程序根据num值判断是否有开仓
g_orderdata.num=[];
if ~isfield(g_orders,'price')
    g_orderdata.num=0;
else
    g_orderdata.num=length(g_orders.price);
end
% g_tradedata(in_contractid).pos.name=g_rawdata.contract(in_contractid).name
% end
if (g_orderdata.num>0)
    for l_orderindex=1:g_orderdata.num
        l_orderposid=l_orderposid+1;
        %name
        g_orderdata.name(l_orderposid)=g_orders.name(l_orderindex);
        %price
        g_orderdata.price(l_orderposid)=g_orders.price(l_orderindex);
        %direction
        g_orderdata.direction(l_orderposid)=g_orders.direction(l_orderindex);
    end
    g_orderdata.num=l_orderposid;
        else
        g_orderdata.name={};
        g_orderdata.price=[];
        g_orderdata.direction=[];
        g_orderdata.num=0;
        
end
