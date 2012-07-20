function ZR_PROCESS_TradeDataPerContract(in_contractid)
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
g_tradedata(in_contractid).pos.num=[];
if ~isfield(g_traderecord,'direction')
    g_traderecord.num=0;
else
    g_traderecord.num=length(g_traderecord.direction);
end
g_tradedata(in_contractid).pos.name=g_rawdata.contract(in_contractid).name;
if(g_traderecord.num>0)
    for l_index=1:g_traderecord.num
        % pos��������1
        l_posid=l_posid+1;
        % pos
        % ����
        g_tradedata(in_contractid).pos.name(l_posid)=g_rawdata.contract(in_contractid).name;
        g_tradedata(in_contractid).pos.rightid(l_posid)={'100000'};
        % ����ʱ��
        g_tradedata(in_contractid).pos.opdate(l_posid)=g_traderecord.opdate(l_index);
        % ƽ��ʱ��
        g_tradedata(in_contractid).pos.cpdate(l_posid)=g_traderecord.cpdate(l_index);
        % ����ʱ�ļ۲�
        g_tradedata(in_contractid).pos.opdateprice(l_posid)=...
            g_traderecord.opdateprice(l_index);        
        g_tradedata(in_contractid).pos.cpdateprice(l_posid)=...
            g_traderecord.cpdateprice(l_index);  
        % �Ƿ�ƽ��
        g_tradedata(in_contractid).pos.isclosepos(l_posid)=g_traderecord.isclosepos(l_index);
        l_sign=g_traderecord.direction(l_index);  
        % ��֤��
        g_tradedata(in_contractid).pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
            *g_tradedata(in_contractid).pos.cpdateprice(l_posid));
        % ����������            
        if (l_tradecharge(1)<1)
            g_tradedata(in_contractid).pos.optradecharge(l_posid)=round(l_tradecharge(1)*...
                g_tradedata(in_contractid).pos.opdateprice(l_posid));
            g_tradedata(in_contractid).pos.cptradecharge(l_posid)=round(l_tradecharge(1)*...
                g_tradedata(in_contractid).pos.cpdateprice(l_posid));          
        else
            g_tradedata(in_contractid).pos.optradecharge(l_posid)=l_tradecharge(1);
            g_tradedata(in_contractid).pos.cptradecharge(l_posid)=l_tradecharge(1);
        end
        % ����
        g_tradedata(in_contractid).pos.profit(l_posid)=...
            ((g_tradedata(in_contractid).pos.cpdateprice(l_posid)...
            -g_tradedata(in_contractid).pos.opdateprice(l_posid))...
            *l_tradeunit(1))*l_sign...
            -g_tradedata(in_contractid).pos.optradecharge(l_posid)-g_tradedata(in_contractid).pos.cptradecharge(l_posid); 
    end
    g_tradedata(in_contractid).pos.num=l_posid;
end