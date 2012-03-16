function ZR_CONFIG_G_ExtractHistoryDataFromMySQL()
% 获取数据库数据参数
global G_ExtractHistoryDataFromMySQL;
global g_DBconfig;
global G_Start;
G_ExtractHistoryDataFromMySQL.g_method.runextractdatabase=@ZR_DATABASE_History_MasterPairs;
G_ExtractHistoryDataFromMySQL.outfilename='DATABASE_History_010601_0129.mat';
G_ExtractHistoryDataFromMySQL.isupdated=0;
G_ExtractHistoryDataFromMySQL.updatepairtype='no';
G_ExtractHistoryDataFromMySQL.updatecontracttype='no';
G_ExtractHistoryDataFromMySQL.updatecommoditytype='no';
G_ExtractHistoryDataFromMySQL.issetbyDB=1;
if G_ExtractHistoryDataFromMySQL.issetbyDB
    if g_DBconfig.isupdated
        if exist(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename),'file')
            delete(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename));
        end
        if exist(strcat(G_Start.currentpath,'/','g_coredata_specialtestcase.mat'),'file')
            delete(strcat(G_Start.currentpath,'/','g_coredata_specialtestcase.mat'));
        end    
    end
    G_ExtractHistoryDataFromMySQL.allcommoditynames=g_DBconfig.allcommoditynames;
    G_ExtractHistoryDataFromMySQL.allcontractnames=g_DBconfig.allcontractnames;
    G_ExtractHistoryDataFromMySQL.allpairs=g_DBconfig.allpairs;
    G_ExtractHistoryDataFromMySQL.currentdate=g_DBconfig.currentdate;
end
end