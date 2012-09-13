function ZR_STOCK_PROCESS_SaveReferenceToXML()
% 将策略性能参数写入数据库
global g_reference;
global g_tables;
l_split=strfind(g_tables.strategyid,'-');
if isempty(l_split)
    l_rightid=strcat(g_tables.strategyid,'000000');
else
    l_rightid=strcat(g_tables.strategyid(1:l_split-1),'000000-',g_tables.strategyid(l_split+1:end),'000000');
end
l_referencexml.rightid=l_rightid;
l_referencexml.minmarginaccount=g_reference.costinput;
l_referencexml.totalnetprofit=g_reference.totalnetprofit;
l_referencexml.grossprofit=g_reference.grossprofit;
l_referencexml.grossloss=g_reference.grossloss;
l_referencexml.avemonthreturn=g_reference.avemonthreturnrate;
l_referencexml.aveyearreturn=g_reference.aveyearreturnrate;
l_referencexml.toaltradingdays=g_reference.totaltradedays;
l_referencexml.totaltrades=g_reference.totaltradenum;
l_referencexml.avedaytrades=g_reference.totaltradenumperday;
l_referencexml.numwintrades=g_reference.profittradenum;
l_referencexml.numlosstrades=g_reference.losstradenum;
l_referencexml.percentprofitable=g_reference.profittraderate;
l_referencexml.largestwintrade=g_reference.maxprofit;
l_referencexml.largestlosstrade=g_reference.maxloss;
l_referencexml.avewintrade=g_reference.profitpertrade;
l_referencexml.avelosstrade=g_reference.losspertrade;
l_referencexml.avetrade=g_reference.returnpertrade;
l_referencexml.expectvalue=g_reference.expectedvalue;
l_referencexml.maxdrawdown=g_reference.maxdrawdown;
l_referencexml.maxdrawdowndays=g_reference.maxdrawdownspread;

xml_write(strcat(g_tables.outdir,'/',g_tables.xml.reference.filename,'.xml'),l_referencexml);
end
