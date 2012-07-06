function ZR_DATABASE_History_MasterPairs()
% 从数据库中得到所主次套利对和相应合约的数据

% 需要使用的全局变量
global G_ExtractHistoryDataFromMySQL;
global g_database;
% 临时变量
l_commoditynames=G_ExtractHistoryDataFromMySQL.allcommoditynames;
l_cmnum=length(l_commoditynames);
l_contractnames=G_ExtractHistoryDataFromMySQL.allcontractnames;
l_ctnum=length(l_contractnames);
l_pairs=G_ExtractHistoryDataFromMySQL.allpairs;
l_pairnum=length(G_ExtractHistoryDataFromMySQL.allpairs);
l_currentdate=G_ExtractHistoryDataFromMySQL.currentdate;
if l_pairnum > 0
l_pairnames{l_pairnum}='';
else
    l_pairnames = [];
end
 
% 检查g_database是否存在，不存在则重新生成
if isempty(g_database)
    % 行情数据更新日期
    g_database.currentdate=l_currentdate;
    % 遍历所有的品种名，获得所有的品种数据信息
    g_database.commoditynames=l_commoditynames;
    for l_cmid=1:l_cmnum
        g_database.commodities(l_cmid).info=ZR_FUN_QueryCommodityInfo(l_commoditynames{l_cmid});
        g_database.commodities(l_cmid).name=l_commoditynames(l_cmid);
        g_database.commodities(l_cmid).serialmkdata=ZR_FUN_QuerySerialMarketData(l_commoditynames{l_cmid});
    end
    disp('所有品种数据获取完毕！');
    % 遍历所有的合约名，获得所有的合约数据信息
    g_database.contractnames=l_contractnames;
    for l_ctid=1:l_ctnum
        l_ctname=l_contractnames{l_ctid};
        g_database.contracts(l_ctid).name=l_contractnames(l_ctid);
        g_database.contracts(l_ctid).cmid=find(strcmp(l_commoditynames,l_ctname(regexp(l_ctname,'[a-z_A-Z]'))));
        g_database.contracts(l_ctid).info=ZR_FUN_QueryActiveContractInfo(l_ctname);
        g_database.contracts(l_ctid).mkdata=ZR_FUN_QueryContractData(l_ctname);
        g_database.contracts(l_ctid).datalen=g_database.contracts(l_ctid).mkdata.datalen;
    end
    disp('所有合约数据获取完毕！');
    % 遍历所有的套利对，获得所有的套利对数据信息
    for l_pairid=1:l_pairnum
        l_ctname=l_pairs(l_pairid).ctname1;
        l_pairs(l_pairid).ctid1=find(strcmp(l_contractnames,l_ctname));
        l_ctname=l_pairs(l_pairid).ctname2;
        l_pairs(l_pairid).ctid2=find(strcmp(l_contractnames,l_ctname));
        l_pairnames{l_pairid}=strcat(l_pairs(l_pairid).ctname1,'-',l_pairs(l_pairid).ctname2);
        l_pairs(l_pairid).name=l_pairnames(l_pairid);
        l_pairs(l_pairid).mkdata=ZR_FUN_QueryPairData(l_pairs(l_pairid).ctname1,l_pairs(l_pairid).ctname2,...
            l_pairs(l_pairid).ctunit1,l_pairs(l_pairid).ctunit2);
%         l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
%             &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
        l_pairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(l_pairs(l_pairid).ctid1).info.daystolasttradedate...
           ,g_database.contracts(l_pairs(l_pairid).ctid2).info.daystolasttradedate);
        l_pairs(l_pairid).datalen=l_pairs(l_pairid).mkdata.datalen;
    end
    g_database.pairnames=l_pairnames;
    g_database.pairs=l_pairs;
    disp('所有品种数据获取完毕！');
    disp('所有数据获取完毕！');
    G_ExtractHistoryDataFromMySQL.isupdated=1;  
else
    % 品种
    switch(G_ExtractHistoryDataFromMySQL.updatecommoditytype)
        case 'update'
            % 遍历所有的品种名，获得所有的品种数据信息
            g_database.commoditynames=l_commoditynames;
            g_database.commodities=[];
            for l_cmid=1:l_cmnum
                g_database.commodities(l_cmid).info=ZR_FUN_QueryCommodityInfo(l_commoditynames{l_cmid});
                g_database.commodities(l_cmid).name=l_commoditynames(l_cmid);
                g_database.commodities(l_cmid).serialmkdata=ZR_FUN_QuerySerialMarketData(l_commoditynames{l_cmid});
            end 
            disp('所有品种数据更新完毕！');
            G_ExtractHistoryDataFromMySQL.isupdated=1;
        case 'add'
            % 遍历新增品种名，获得所有的品种数据信息
            for l_cmid=(length(g_database.commoditynames)+1):l_cmnum
                g_database.commodities(l_cmid).info=ZR_FUN_QueryCommodityInfo(l_commoditynames{l_cmid});
                g_database.commodities(l_cmid).name=l_commoditynames(l_cmid);
            end 
            g_database.commoditynames=l_commoditynames;
            disp('所有品种数据更新完毕！');
            G_ExtractHistoryDataFromMySQL.isupdated=1;            
        otherwise
    end       
    % 合约
    switch(G_ExtractHistoryDataFromMySQL.updatecontracttype)
        case 'update'
            % 遍历所有的合约名，获得所有的合约数据信息
            g_database.contractnames=l_contractnames;
            g_database.contracts=[];            
            for l_ctid=1:l_ctnum
                l_ctname=l_contractnames{l_ctid};
                g_database.contracts(l_ctid).name=l_contractnames(l_ctid);
                g_database.contracts(l_ctid).cmid=find(strcmp(l_commoditynames,l_ctname(regexp(l_ctname,'[a-z_A-Z]'))));
                g_database.contracts(l_ctid).info=ZR_FUN_QueryActiveContractInfo(l_ctname);
                g_database.contracts(l_ctid).mkdata=ZR_FUN_QueryContractData(l_ctname);
                g_database.contracts(l_ctid).datalen=g_database.contracts(l_ctid).mkdata.datalen;
            end
            disp('所有合约数据更新完毕！');
            G_ExtractHistoryDataFromMySQL.isupdated=1;
        case 'add'
            % 遍历新增的合约名，获得所有的合约数据信息
            for l_ctid=(length(g_database.contractnames)+1):l_ctnum
                l_ctname=l_contractnames{l_ctid};
                g_database.contracts(l_ctid).name=l_contractnames(l_ctid);
                g_database.contracts(l_ctid).cmid=find(strcmp(l_commoditynames,l_ctname(regexp(l_ctname,'[a-z_A-Z]'))));
                g_database.contracts(l_ctid).info=ZR_FUN_QueryActiveContractInfo(l_ctname);
                g_database.contracts(l_ctid).mkdata=ZR_FUN_QueryContractData(l_ctname);
                g_database.contracts(l_ctid).datalen=g_database.contracts(l_ctid).mkdata.datalen;
            end      
            g_database.contractnames=l_contractnames;
            disp('所有合约数据更新完毕！');
            G_ExtractHistoryDataFromMySQL.isupdated=1;            
        otherwise
    end
    % 套利对
    switch(G_ExtractHistoryDataFromMySQL.updatepairtype)
        case 'update'
            % 遍历所有的套利对，获得所有的套利对数据信息
            g_database.pairnames=[];
            g_database.pairs=[];
            for l_pairid=1:l_pairnum
                l_ctname=l_pairs(l_pairid).ctname1;
                l_pairs(l_pairid).ctid1=find(strcmp(l_contractnames,l_ctname));
                l_ctname=l_pairs(l_pairid).ctname2;
                l_pairs(l_pairid).ctid2=find(strcmp(l_contractnames,l_ctname));
                l_pairnames{l_pairid}=strcat(l_pairs(l_pairid).ctname1,'-',l_pairs(l_pairid).ctname2);
                l_pairs(l_pairid).name=l_pairnames(l_pairid);      
                l_pairs(l_pairid).mkdata=ZR_FUN_QueryPairData(l_pairs(l_pairid).ctname1,l_pairs(l_pairid).ctname2,...
                    l_pairs(l_pairid).ctunit1,l_pairs(l_pairid).ctunit2);
%                 l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
%                     &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
                l_pairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(l_pairs(l_pairid).ctid1).info.daystolasttradedate...
                   ,g_database.contracts(l_pairs(l_pairid).ctid2).info.daystolasttradedate);   
                l_pairs(l_pairid).datalen=l_pairs(l_pairid).mkdata.datalen;
            end
            g_database.pairnames=l_pairnames;
            g_database.pairs=l_pairs;
            disp('所有套利对数据更新完毕！');
            G_ExtractHistoryDataFromMySQL.isupdated=1;
        case 'add'
            % 遍历新增的套利对，获得所有的套利对数据信息
            l_pairs=g_database.pairs;
            l_pairnames=g_database.pairnames;
            for l_pairid=(length(g_database.pairnames)+1):l_pairnum
                l_ctname=l_pairs(l_pairid).ctname1;
                l_pairs(l_pairid).ctid1=find(strcmp(l_contractnames,l_ctname));
                l_ctname=l_pairs(l_pairid).ctname2;
                l_pairs(l_pairid).ctid2=find(strcmp(l_contractnames,l_ctname));
                l_pairnames{l_pairid}=strcat(l_pairs(l_pairid).ctname1,'-',l_pairs(l_pairid).ctname2);
                l_pairs(l_pairid).name=l_pairnames(l_pairid);
                l_pairs(l_pairid).mkdata=ZR_FUN_QueryPairData(l_pairs(l_pairid).ctname1,l_pairs(l_pairid).ctname2,...
                    l_pairs(l_pairid).ctunit1,l_pairs(l_pairid).ctunit2);
%                 l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
%                     &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
                l_pairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(l_pairs(l_pairid).ctid1).info.daystolasttradedate...
                   ,g_database.contracts(l_pairs(l_pairid).ctid2).info.daystolasttradedate); 
                l_pairs(l_pairid).datalen=l_pairs(l_pairid).mkdata.datalen;
            end
            g_database.pairnames=l_pairnames;
            g_database.pairs=l_pairs;
            disp('所有套利对数据更新完毕！');
            G_ExtractHistoryDataFromMySQL.isupdated=1;            
        otherwise
    end
end

end