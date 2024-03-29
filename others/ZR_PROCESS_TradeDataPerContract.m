function ZR_PROCESS_TradeDataPerContract(in_contractid)
%%%%%%%% 计算交易数据
global g_traderecord;
global g_rawdata;
global g_tradedata;

% 交易单位
l_tradeunit(1)=g_rawdata.commodity.info(1).tradeunit;
% 保证金比例
l_margin(1)=g_rawdata.commodity.info(1).margin;
% 交易手续费
l_tradecharge(1)=g_rawdata.commodity.info(1).tradecharge;

% 记录交易情况
l_posid=0;
% 后续程序根据num值判断是否有开仓
g_tradedata(in_contractid).pos.num=[];
if ~isfield(g_traderecord,'direction')
    g_traderecord.num=0;
else
    g_traderecord.num=length(g_traderecord.direction);
end
g_tradedata(in_contractid).pos.name=g_rawdata.contract(in_contractid).name;
if(g_traderecord.num>0)
    for l_index=1:g_traderecord.num
        % pos数量自增1
        l_posid=l_posid+1;
        % pos
        % 名字
        g_tradedata(in_contractid).pos.name(l_posid)=g_rawdata.contract(in_contractid).name;
        g_tradedata(in_contractid).pos.rightid(l_posid)={'100000'};
        % 开仓时间
        g_tradedata(in_contractid).pos.opdate(l_posid)=g_traderecord.opdate(l_index);
        % 平仓时间
        g_tradedata(in_contractid).pos.cpdate(l_posid)=g_traderecord.cpdate(l_index);
        % 建仓时的价差
        g_tradedata(in_contractid).pos.opdateprice(l_posid)=...
            g_traderecord.opdateprice(l_index);        
        g_tradedata(in_contractid).pos.cpdateprice(l_posid)=...
            g_traderecord.cpdateprice(l_index);  
        % 是否平仓
        g_tradedata(in_contractid).pos.isclosepos(l_posid)=g_traderecord.isclosepos(l_index);
        l_sign=g_traderecord.direction(l_index);  
        % 保证金
        g_tradedata(in_contractid).pos.margin(l_posid)=round(l_tradeunit(1)*l_margin(1)...
            *g_tradedata(in_contractid).pos.cpdateprice(l_posid));
        % 交易手续费            
        if (l_tradecharge(1)<1)
            g_tradedata(in_contractid).pos.optradecharge(l_posid)=round(l_tradecharge(1)*...
                g_tradedata(in_contractid).pos.opdateprice(l_posid));
            g_tradedata(in_contractid).pos.cptradecharge(l_posid)=round(l_tradecharge(1)*...
                g_tradedata(in_contractid).pos.cpdateprice(l_posid));          
        else
            g_tradedata(in_contractid).pos.optradecharge(l_posid)=l_tradecharge(1);
            g_tradedata(in_contractid).pos.cptradecharge(l_posid)=l_tradecharge(1);
        end
        % 收益
        g_tradedata(in_contractid).pos.profit(l_posid)=...
            ((g_tradedata(in_contractid).pos.cpdateprice(l_posid)...
            -g_tradedata(in_contractid).pos.opdateprice(l_posid))...
            *l_tradeunit(1))*l_sign...
            -g_tradedata(in_contractid).pos.optradecharge(l_posid)-g_tradedata(in_contractid).pos.cptradecharge(l_posid); 
    end
    g_tradedata(in_contractid).pos.num=l_posid;
end