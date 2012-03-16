function ZR_PROCESS_TradeDataPerPair(in_pairid)
%%%%%%%% 计算交易数据
global g_traderecord;
global g_rawdata;
global g_tradedata;

% 交易单位
l_tradeunit(1)=g_rawdata.commodity.info(1).tradeunit;
l_tradeunit(2)=g_rawdata.commodity.info(2).tradeunit;
% 保证金比例
l_margin(1)=g_rawdata.commodity.info(1).margin;
l_margin(2)=g_rawdata.commodity.info(2).margin;
% 交易手续费
l_tradecharge(1)=g_rawdata.commodity.info(1).tradecharge;
l_tradecharge(2)=g_rawdata.commodity.info(2).tradecharge;

% 记录交易情况
l_posid=0;
% 后续程序根据num值判断是否有开仓
g_tradedata(in_pairid).pos.num=[];
if ~isfield(g_traderecord,'direction')
    g_traderecord.num=0;
else
    g_traderecord.num=length(g_traderecord.direction);
end
g_tradedata(in_pairid).pos.name=g_rawdata.pair(in_pairid).name;
if(g_traderecord.num>0)
    for l_index=1:g_traderecord.num
        % pos数量自增1
        l_posid=l_posid+1;
        % pos
        % 名字
        g_tradedata(in_pairid).pos.name(l_posid)=g_rawdata.pair(in_pairid).name;
        g_tradedata(in_pairid).pos.rightid(l_posid)={g_rawdata.pair(in_pairid).rightid};
        % 开仓时间
        g_tradedata(in_pairid).pos.opdate(l_posid)=g_traderecord.opdate(l_index);
        l_opdateid= find(strcmp(g_traderecord.opdate{l_index},g_rawdata.pair(in_pairid).mkdata.date),1,'first');
        % 平仓时间
        g_tradedata(in_pairid).pos.cpdate(l_posid)=g_traderecord.cpdate(l_index);
        l_cpdateid=find(strcmp(g_traderecord.cpdate{l_index},g_rawdata.pair(in_pairid).mkdata.date),1,'first');
        % 建仓时的价差
        g_tradedata(in_pairid).pos.opdateprice(l_posid)=...
            g_traderecord.opdateprice(l_index);        
        g_tradedata(in_pairid).pos.cpdateprice(l_posid)=...
            g_traderecord.cpdateprice(l_index);  
        % 是否平仓
        g_tradedata(in_pairid).pos.isclosepos(l_posid)=g_traderecord.isclosepos(l_index);
        l_sign=g_traderecord.direction(l_index);  
        % 保证金
        g_tradedata(in_pairid).pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
            *g_rawdata.pair(in_pairid).mkdata.cp(l_cpdateid,1)...
            +l_tradeunit(2)*l_margin(2)...
            *g_rawdata.pair(in_pairid).mkdata.cp(l_cpdateid,2));
        % 交易手续费
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
        % 收益
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