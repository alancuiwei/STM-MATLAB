function ZR_PROCESS_TradeDataPerPair(in_pairid)
%%%%%%%% ���㽻������
global g_traderecord;
global g_rawdata;
global g_tradedata;

% ���׵�λ
l_tradeunit(1)=g_rawdata.commodity.info(1).tradeunit;
l_tradeunit(2)=g_rawdata.commodity.info(2).tradeunit;
% ��֤�����
l_margin(1)=g_rawdata.commodity.info(1).margin;
l_margin(2)=g_rawdata.commodity.info(2).margin;
% ����������
l_tradecharge(1)=g_rawdata.commodity.info(1).tradecharge;
l_tradecharge(2)=g_rawdata.commodity.info(2).tradecharge;

% ��¼�������
l_posid=0;
% �����������numֵ�ж��Ƿ��п���
g_tradedata(in_pairid).pos.num=[];
if ~isfield(g_traderecord,'direction')
    g_traderecord.num=0;
else
    g_traderecord.num=length(g_traderecord.direction);
end
g_tradedata(in_pairid).pos.name=g_rawdata.pair(in_pairid).name;
if(g_traderecord.num>0)
    for l_index=1:g_traderecord.num
        % pos��������1
        l_posid=l_posid+1;
        % pos
        % ����
        g_tradedata(in_pairid).pos.name(l_posid)=g_rawdata.pair(in_pairid).name;
        g_tradedata(in_pairid).pos.rightid(l_posid)={g_rawdata.pair(in_pairid).rightid};
        % ����ʱ��
        g_tradedata(in_pairid).pos.opdate(l_posid)=g_traderecord.opdate(l_index);
        l_opdateid= find(strcmp(g_traderecord.opdate{l_index},g_rawdata.pair(in_pairid).mkdata.date),1,'first');
        % ƽ��ʱ��
        g_tradedata(in_pairid).pos.cpdate(l_posid)=g_traderecord.cpdate(l_index);
        l_cpdateid=find(strcmp(g_traderecord.cpdate{l_index},g_rawdata.pair(in_pairid).mkdata.date),1,'first');
        % ����ʱ�ļ۲�
        g_tradedata(in_pairid).pos.opdateprice(l_posid)=...
            g_traderecord.opdateprice(l_index);        
        g_tradedata(in_pairid).pos.cpdateprice(l_posid)=...
            g_traderecord.cpdateprice(l_index);  
        % �Ƿ�ƽ��
        g_tradedata(in_pairid).pos.isclosepos(l_posid)=g_traderecord.isclosepos(l_index);
        l_sign=g_traderecord.direction(l_index);  
        % ��֤��
        g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
            *g_rawdata.pair(in_pairid).mkdata.cp(l_cpdateid,1)...
            +l_tradeunit(2)*l_margin(2)...
            *g_rawdata.pair(in_pairid).mkdata.cp(l_cpdateid,2));
        % ����������
        g_tradedata(in_pairid).pos.optradecharge(l_posid)=0;
        g_tradedata(in_pairid).pos.cptradecharge(l_posid)=0;            
        for l_chargeid=1:length(l_tradecharge)
            if (l_tradecharge(l_chargeid)<1)
                g_tradedata(in_pairid).pos.optradecharge(l_posid)=round(l_tradecharge(l_chargeid)*...
                    g_rawdata.pair(in_pairid).mkdata.op(l_opdateid,l_chargeid))...
                    +g_tradedata(in_pairid).pos.optradecharge(l_posid);
                g_tradedata(in_pairid).pos.cptradecharge(l_posid)=round(l_tradecharge(l_chargeid)*...
                    g_rawdata.pair(in_pairid).mkdata.cp(l_cpdateid,l_chargeid))...
                    +g_tradedata(in_pairid).pos.cptradecharge(l_posid);                
            else
                g_tradedata(in_pairid).pos.optradecharge(l_posid)=l_tradecharge(l_chargeid)+g_tradedata(in_pairid).pos.optradecharge(l_posid);
                g_tradedata(in_pairid).pos.cptradecharge(l_posid)=l_tradecharge(l_chargeid)+g_tradedata(in_pairid).pos.cptradecharge(l_posid);
            end
        end
        % ����
        g_tradedata(in_pairid).pos.profit(l_posid)=...
            ((g_rawdata.pair(in_pairid).mkdata.cp(l_cpdateid,1)...
            -g_rawdata.pair(in_pairid).mkdata.cp(l_opdateid,1))...
            *l_tradeunit(1)...
            -(g_rawdata.pair(in_pairid).mkdata.cp(l_cpdateid,2)...
            -g_rawdata.pair(in_pairid).mkdata.cp(l_opdateid,2))...
            *l_tradeunit(2))*l_sign...
            -g_tradedata(in_pairid).pos.optradecharge(l_posid)-g_tradedata(in_pairid).pos.cptradecharge(l_posid); 
    end
    g_tradedata(in_pairid).pos.num=l_posid;
end