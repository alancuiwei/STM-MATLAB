function ZR_PROCESS_VerifyRecord()
%检查并纠正交易记录
global g_traderecord;
global g_rawdata;
if length(g_traderecord.opdate)>length(g_traderecord.cpdate)
    g_traderecord.cpdate(end+1)=g_rawdata.commodity.serialmkdata.date(end);
    g_traderecord.cpdateprice(end+1)=g_rawdata.commodity.serialmkdata.cp(end);
end


end