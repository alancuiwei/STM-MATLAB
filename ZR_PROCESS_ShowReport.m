function ZR_PROCESS_ShowReport()
%%%%%%%% ��ʾ�������
global g_tables;
global g_method;

% ���ּ�¼
g_tables.tabledata.record.pos=ZR_FUN_GetTableByItems('pos');
% ���׼�¼       
% g_tables.tabledata.record.trade=ZR_FUN_GetTableByItems('trade');
% �����ʱ�
g_tables.tabledata.returnrate=ZR_FUN_GetReturnrateTable();
% ����ָ��       
g_tables.tabledata.reference=ZR_FUN_GetTableByItems('reference');
% ���򱨸�
g_tables.tabledata.sort=ZR_FUN_GetTableByItems('sort'); 
% ������������
switch g_tables.outfiletype
    case 'xls'
        % ���Ŀ¼�����ھʹ���
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