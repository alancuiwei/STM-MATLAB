function ZR_STOCK_PROCESS_VerifyRecord()
%��鲢�������׼�¼
global g_traderecord;
% global g_rawdata;
if length(g_traderecord.opdate)>length(g_traderecord.cpdate)
    g_traderecord.cpdate(end+1)=g_traderecord.opdate(end);
    g_traderecord.cpdateprice(end+1)=g_traderecord.opdateprice(end);
end


end
