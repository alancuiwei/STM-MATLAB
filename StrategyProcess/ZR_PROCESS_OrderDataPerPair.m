function ZR_PROCESS_OrderDataPerPair(in_pairid)
% ��ÿһ��pair��order����orderdata��
global g_orderdata;
global g_orderlist;

g_orderdata(in_pairid).num=length(g_orderlist.price);
g_orderdata(in_pairid).price=g_orderlist.price;
g_orderdata(in_pairid).name=g_orderlist.name;
g_orderdata(in_pairid).direction=g_orderlist.direction;


end