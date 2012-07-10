function ZR_PROCESS_SaveDailyInfoToXML()
global g_reportset;
global g_tables;
l_1970datenum=datenum('1970-01-01');
% 初始化时间保证金向量
l_dailyinfo.dailydatenum=(g_reportset.dailyinfo.dailydatenum-l_1970datenum)*86400000;
% 初始化时间保证金向量
% l_dailyinfo.margin=g_reportset.dailyinfo.margin;
% 初始化时间仓位向量
% l_dailyinfo.posnum=g_reportset.dailyinfo.posnum;
% 初始化时间获利向量
l_dailyinfo.profit=g_reportset.dailyinfo.profit;
% 初始化交易费
l_dailyinfo.tradecharge=g_reportset.dailyinfo.tradecharge;
l_dailyinfoxml(length(g_reportset.dailyinfo.dailydatenum))=struct();
for l_id=1:length(g_reportset.dailyinfo.dailydatenum)
    l_dailyinfoxml(l_id).dailydatenum=l_dailyinfo.dailydatenum(l_id);
    % l_dailyinfoxml(l_id).margin=l_dailyinfo.margin(l_id);
    % l_dailyinfoxml(l_id).posnum=l_dailyinfo.posnum(l_id);
    l_dailyinfoxml(l_id).profit=l_dailyinfo.profit(l_id);
end
xml_write(strcat(g_tables.outdir,'/',g_tables.xml.dailyinfo.filename,'.xml'),l_dailyinfoxml);

end