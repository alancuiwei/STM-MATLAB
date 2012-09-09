function [out_totalvalue,out_commodityvalue]=ZR_TARGETFUNCTION_MostPessimistic()
% 计算期望值

global g_commoditynames;
global g_report;
%%%%%%%%%%%%% 总交易情况
l_reference=[];
% 计算最悲观期望值
% 投入资金
l_reference.costinput=max(abs(g_report.dailyinfo.margin)); 
% 总交易次数
l_reference.totaltradenum=g_report.record.pos.num;
% 盈利交易次数
l_reference.profittradenum=sum(g_report.record.pos.profit>0); 
% 亏损交易次数
l_reference.losstradenum=sum(g_report.record.pos.profit<=0);
% 每单交易盈利
l_reference.profitpertrade=sum(g_report.record.pos.profit(g_report.record.pos.profit>0))....
    /l_reference.profittradenum; 
% 每单交易亏损
l_reference.losspertrade=sum(g_report.record.pos.profit(g_report.record.pos.profit<=0))....
    /l_reference.losstradenum;
% 输出
out_totalvalue=(l_reference.profitpertrade*(l_reference.profittradenum-l_reference.profittradenum^0.5)...
    +l_reference.losspertrade*(l_reference.losstradenum+l_reference.losstradenum^0.5))/l_reference.costinput;

% 获得品种数
if iscell(g_commoditynames)
    l_cmnum=length(g_commoditynames);
else
    l_cmnum=1;
end
out_commodityvalue(l_cmnum)=0;
for l_cmid=1:l_cmnum 
    % 计算各品种最悲观期望值
    l_reference=[];
    if max(g_report.commodity(l_cmid).dailyinfo.margin)>0
        % 投入资金
        l_reference.costinput=max(abs(g_report.commodity(l_cmid).dailyinfo.margin)); 
        % 总交易次数
        l_reference.totaltradenum=g_report.commodity(l_cmid).record.pos.num;
        % 盈利交易次数
        l_reference.profittradenum=sum(g_report.commodity(l_cmid).record.pos.profit>0); 
        % 亏损交易次数
        l_reference.losstradenum=sum(g_report.commodity(l_cmid).record.pos.profit<=0);
        % 每单交易盈利
        l_reference.profitpertrade=sum(g_report.commodity(l_cmid).record.pos.profit(g_report.commodity(l_cmid).record.pos.profit>0))....
            /l_reference.profittradenum; 
        % 每单交易亏损
        l_reference.losspertrade=sum(g_report.commodity(l_cmid).record.pos.profit(g_report.commodity(l_cmid).record.pos.profit<=0))....
            /l_reference.losstradenum;
        % 输出
        out_commodityvalue(l_cmid)=(l_reference.profitpertrade*(l_reference.profittradenum-l_reference.profittradenum^0.5)...
            +l_reference.losspertrade*(l_reference.losstradenum+l_reference.losstradenum^0.5))/l_reference.costinput;   
    else
        out_commodityvalue(l_cmid)=0;
    end
end