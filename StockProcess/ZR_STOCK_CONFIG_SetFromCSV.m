function ZR_STOCK_CONFIG_SetFromCSV()
global g_database;
global g_DBconfig;
global g_XMLfile;
if iscell(g_XMLfile)    %���g_XMLfileXXXX.xml�ļ����
    ZR_STOCK_PROCESS_ImportStockMKData(g_XMLfile{1}.g_commoditynames);
    %ʹ��������id��Ϊg_DBconfig�Ĳ���id 
    g_DBconfig.strategyid=g_XMLfile{1}.strategyid;
    %rightid������һ��'rightid1'-'rightid2'-...
    g_DBconfig.g_rightid={strcat(g_XMLfile{1}.strategyid,'000000')};
    g_DBconfig.isupdated=g_XMLfile{1}.isupdated;    
else
    ZR_STOCK_PROCESS_ImportStockMKData(g_XMLfile.g_commoditynames);
    %ʹ��������id��Ϊg_DBconfig�Ĳ���id 
    g_DBconfig.strategyid=g_XMLfile.strategyid;
    %rightid������һ��'rightid1'-'rightid2'-...
    g_DBconfig.g_rightid={strcat(g_XMLfile.strategyid,'000000')};
    g_DBconfig.isupdated=g_XMLfile.isupdated;        
end
g_DBconfig.allcommoditynames=g_database.commoditynames;
g_DBconfig.g_commoditynames=g_database.commoditynames;
g_DBconfig.allcontractnames=g_database.commoditynames;
g_DBconfig.currentdate=g_database.currentdate;
g_DBconfig.g_pairnames={};   
g_DBconfig.allcontractnames={};
end
