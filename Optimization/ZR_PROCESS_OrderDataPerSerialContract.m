function ZR_PROCESS_OrderDataPerSerialContract( )
%%%%%%%% ���㽻������
% global g_traderecord;
% global g_rawdata;
% global g_tradedata;
global g_orderlist;
global g_orderdata;
% price
l_price(1)=g_orderlist.price(1);
% direction
l_margin(1)=g_orderlist.direction(1);
% % ����������
% l_tradecharge(1)=g_rawdata.commodity.info(1).tradecharge;
% ��¼�������
l_posid=0;
% �����������numֵ�ж��Ƿ��п���
g_tradedata.pos.num=[];
if ~isfield(g_orderlist,'price')
    g_traderecord.num=0;
else
    g_traderecord.num=length(g_orderlist.price);
end
% g_tradedata(in_contractid).pos.name=g_rawdata.contract(in_contractid).name;
if(g_traderecord.num>0)
    for l_index=1:g_traderecord.num
        % pos��������1
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