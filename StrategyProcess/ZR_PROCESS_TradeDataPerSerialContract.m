function ZR_PROCESS_TradeDataPerSerialContract( )
%%%%%%%% ���㽻������
global g_traderecord;
global g_rawdata;
global g_tradedata;
% ���׵�λ
l_tradeunit(1)=g_rawdata.commodity.info(1).tradeunit;
% ��֤�����
l_margin(1)=g_rawdata.commodity.info(1).margin;
% ����������
l_tradecharge(1)=g_rawdata.commodity.info(1).tradecharge;
% ��¼�������
l_posid=0;
% �����������numֵ�ж��Ƿ��п���
g_tradedata.pos.num=[];
if ~isfield(g_traderecord,'direction')
    g_traderecord.num=0;
else
    g_traderecord.num=length(g_traderecord.direction);
end
% g_tradedata(in_contractid).pos.name=g_rawdata.contract(in_contractid).name;
if(g_traderecord.num>0)
    for l_index=1:g_traderecord.num
        % pos��������1
        l_posid=l_posid+1;
        % pos
        % ����
        g_tradedata.pos.name(l_posid)=g_traderecord.ctname(l_index);
        g_tradedata.pos.rightid(l_posid)=g_rawdata.rightid;
        % ����ʱ��
        g_tradedata.pos.opdate(l_posid)=g_traderecord.opdate(l_index);
        % ƽ��ʱ��
        g_tradedata.pos.cpdate(l_posid)=g_traderecord.cpdate(l_index);
        % ����ʱ�ļ۲�
        g_tradedata.pos.opdateprice(l_posid)=...
            g_traderecord.opdateprice(l_index);        
        g_tradedata.pos.cpdateprice(l_posid)=...
            g_traderecord.cpdateprice(l_index);  
        % �Ƿ�ƽ��
        g_tradedata.pos.isclosepos(l_posid)=g_traderecord.isclosepos(l_index);
        l_sign=g_traderecord.direction(l_index);  
        % ��֤��
        g_tradedata.pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
            *g_tradedata.pos.cpdateprice(l_posid));
        % ����������            
        if (l_tradecharge(1)<1)
            g_tradedata.pos.optradecharge(l_posid)=round(l_tradecharge(1)*...
                g_tradedata.pos.opdateprice(l_posid));
            g_tradedata.pos.cptradecharge(l_posid)=round(l_tradecharge(1)*...
                g_tradedata.pos.cpdateprice(l_posid));          
        else
            g_tradedata.pos.optradecharge(l_posid)=l_tradecharge(1);
            g_tradedata.pos.cptradecharge(l_posid)=l_tradecharge(1);
        end
        % ���׷���
        g_tradedata.pos.direction(l_posid)=g_traderecord.direction(l_index);
        % ����
        g_tradedata.pos.profit(l_posid)=...
            ((g_tradedata.pos.cpdateprice(l_posid)...
            -g_tradedata.pos.opdateprice(l_posid))...
            *l_tradeunit(1))*l_sign...
            -g_tradedata.pos.optradecharge(l_posid)-g_tradedata.pos.cptradecharge(l_posid); 
    end
    g_tradedata.pos.num=l_posid;
end
% g_orderdata.num=[];
% if ~isfield(g_orderlist,'price')
%     g_orderdata.num=0;
% else
%     g_orderdata.num=length(g_orderlist.price);
% % end
% if (g_orderdata.num>0)
%     for l_orderindex=1:g_orderdata.num
%         l_orderposid=l_orderposid+1;
%         %name
%         g_orderdata.name(l_orderposid)=g_orderlist.name(l_orderindex);
%         %price
%         g_orderdata.price(l_orderposid)=g_orderlist.price(l_orderindex);
%         %direction
%         g_orderdata.direction(l_orderposid)=g_orderlist.direction(l_orderindex);
%     end
%     g_orderdata.num=l_orderposid;
% else
%         g_orderdata.name={};
%         g_orderdata.price=[];
%         g_orderdata.direction=[];
%         g_orderdata.num=0;
%         
% end
