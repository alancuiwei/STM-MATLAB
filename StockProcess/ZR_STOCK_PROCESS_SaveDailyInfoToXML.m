function ZR_STOCK_PROCESS_SaveDailyInfoToXML()
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
l_dailyinfoxml=struct();

% 根据限制的时间，筛选
if (strcmp(g_tables.startdate,'nolimit')...
    &&strcmp(g_tables.enddate,'nolimit'))
    % 没有限制
    l_startid=1;
    l_endid=length(g_reportset.dailyinfo.dailydatenum);
else
    l_startdatenum=0;
    l_enddatenum=inf;
    if ~strcmp(g_tables.enddate,'nolimit')
        % 结束日期有限制
        % 日期数字
        l_enddatenum=datenum(g_tables.enddate,'yyyy-mm-dd');            
    end
    if ~strcmp(g_tables.startdate,'nolimit')
        % 开始日期有限制
        % 日期数字
        l_startdatenum=datenum(g_tables.startdate,'yyyy-mm-dd');            
    end
    % 计算合约的起始id
    l_startid=find(g_reportset.dailyinfo.dailydatenum>=l_startdatenum,1,'first');
    l_endid=find(g_reportset.dailyinfo.dailydatenum<=l_enddatenum,1,'last');
end

for l_id=1:(l_endid-l_startid)
    l_dailyinfoxml(l_id).dailydatenum=l_dailyinfo.dailydatenum(l_id+l_startid-1);
    % l_dailyinfoxml(l_id).margin=l_dailyinfo.margin(l_id);
    % l_dailyinfoxml(l_id).posnum=l_dailyinfo.posnum(l_id);
    l_dailyinfoxml(l_id).profit=l_dailyinfo.profit(l_id+l_startid-1);
end
xml_write(strcat(g_tables.outdir,'/',g_tables.xml.dailyinfo.filename,'.xml'),l_dailyinfoxml);

end
