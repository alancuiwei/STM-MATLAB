function ZR_PROCESS_ShowReport()
%%%%%%%% 显示报告过程
global g_tables;
global g_method;

% 开仓记录
g_tables.tabledata.record.pos=ZR_FUN_GetTableByItems('pos');
% 交易记录       
% g_tables.tabledata.record.trade=ZR_FUN_GetTableByItems('trade');
% 收益率表
g_tables.tabledata.returnrate=ZR_FUN_GetReturnrateTable();
% 测评指标       
g_tables.tabledata.reference=ZR_FUN_GetTableByItems('reference');
% 排序报告
g_tables.tabledata.sort=ZR_FUN_GetTableByItems('sort'); 
% 报告的输出类型
switch g_tables.outfiletype
    case 'xls'
        % 如果目录不存在就创建
        l_filename=g_tables.xls.outfile;
        for l_strategyid=1:length(g_method.runstrategy)
            l_filename=strcat(l_filename,strrep(char(g_method.runstrategy(l_strategyid).fun),'ZR_STRATEGY_','_'));
        end
        l_filename=strcat(g_tables.outdir,'/',l_filename,'.xls');
        if (~exist(g_tables.outdir,'dir'))
            mkdir(g_tables.outdir);
        elseif exist(l_filename,'file')
            delete(l_filename);
        end               
        try
            xlswrite(l_filename,g_tables.tabledata.record.pos,g_tables.xls.record.pos.sheetname, 'A1');
%             xlswrite(l_filename,g_tables.tabledata.record.trade,g_tables.xls.record.trade.sheetname, 'A1');
            xlswrite(l_filename,g_tables.tabledata.returnrate,g_tables.xls.returnrate.sheetname, 'A1');
            xlswrite(l_filename,g_tables.tabledata.reference,g_tables.xls.reference.sheetname, 'A1'); 
            xlswrite(l_filename,g_tables.tabledata.sort,g_tables.xls.sort.sheetname, 'A1'); 
        catch
        end
    case 'database'  
        ZR_PROCESS_SaveReportsetToDB(g_tables.strategyid);
        ZR_PROCESS_SaveReferenceToDB(g_tables.strategyid);
        ZR_PROCESS_SaveReturnrateToDB(g_tables.strategyid);     
    case 'xml'
        xml_write(strcat(g_tables.outdir,'/',g_tables.xml.record.pos.filename,'.xml'),g_tables.tabledata.record.pos);
        ZR_PROCESS_SaveReturnrateToXML();
        ZR_PROCESS_SaveReferenceToXML();
        ZR_PROCESS_SaveDailyInfoToXML();
end

end