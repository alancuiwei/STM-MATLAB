function out_table=ZR_STOCK_FUN_GetReturnrateTable()
%%%%%%%% 得到收益率的表格，按年和月统计
global g_report;
global g_reference;
global g_tables;
% 各品种
l_table=repmat({''},size(g_tables.returnrate.title));
for l_cmid=1:length(g_report.commodity)
    l_monthreturnrate=g_reference.commodity.monthreturnrate(l_cmid).data;
    l_yearreturnrate=g_reference.commodity.yearreturnrate(l_cmid).data;
    l_years=g_reference.commodity.years(l_cmid).data;
    l_monthtitle=g_tables.returnrate.title;
    l_monthtitle(1)=g_report.commodity(l_cmid).name;
    l_table=cat(1,l_table,l_monthtitle,num2cell([l_years;l_monthreturnrate;l_yearreturnrate])',repmat({''},size(l_monthtitle)));  
end
% 总的
l_monthreturnrate=g_reference.monthreturnrate.data;
l_yearreturnrate=g_reference.yearreturnrate.data;
l_years=g_reference.years.data;
l_monthtitle=g_tables.returnrate.title;
l_monthtitle{1}='汇总';
out_table=cat(1,l_table,l_monthtitle,num2cell([l_years;l_monthreturnrate;l_yearreturnrate])'); 
end
