function ZR_CONFIG_SetFromDB(in_strategyid)
% 从数据库中得到配置数据
global g_DBconfig;
global g_XMLfile;
% global G_Start;
% 如果从XML文件中获取参数，DB不必更新

g_DBconfig.strategyid=in_strategyid;
l_strategyinfo=ZR_FUN_QueryArbitrageInfo(in_strategyid);
g_DBconfig.allcommoditynames=unique(cat(1,l_strategyinfo.firstcommodityid,l_strategyinfo.secondcommodityid));
% g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);           %包含'-'说明是套利对
g_DBconfig.g_rightid=l_strategyinfo.rightid;
g_DBconfig.allcontractnames={};
g_DBconfig.g_pairnames={};
g_DBconfig.allpairs=[];
g_DBconfig.currentdate=ZR_FUN_QueryMarketdataCurrentdate();
g_DBconfig.isupdated=0;

for l_id=1:length(l_strategyinfo.rightid)
    l_rightid=cell2mat(l_strategyinfo.rightid(l_id));
    switch l_rightid(1:2)       %套利类型
        case '01'       %跨期套利
            g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);           %包含'-'说明是套利对
        case '02'       %跨产品套利
        case '04'       %单边策略
            g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid);           %单边策略，去掉'-'
        case '10'       %？？？？？
    end
    switch(l_rightid(7:8))
        case '01'       %逐月套利对
            l_months=ZR_FUN_QueryDeliverMonths(l_strategyinfo.firstcommodityid{l_id});  %查询该品种主力合约
        case '02'       %主力/次主力套利对
            l_months=ZR_FUN_QueryMasterMonths(l_strategyinfo.firstcommodityid{l_id});   %查询该品种主力合约
    end
    l_contractnames=ZR_FUN_QueryContractnames(l_strategyinfo.firstcommodityid{l_id},cell2mat(l_months));        %查询该品种所有合约名
    l_allpairs=struct('ctname1',[],'ctunit1',[],'ctname2',[],'ctunit2',[],'rightid',l_rightid);
    g_DBconfig.allcontractnames=cat(1,g_DBconfig.allcontractnames,l_contractnames(:));
    l_pairnames=cell((length(l_contractnames)-1),1);
    for l_ctid=1:(length(l_contractnames)-1) 
        l_pairnames{l_ctid}=strcat(l_contractnames{l_ctid},'-',l_contractnames{l_ctid+1});
        l_allpairs(l_ctid)=struct('ctname1',l_contractnames{l_ctid},'ctunit1',l_strategyinfo.firstcommodityunit(l_id),...
            'ctname2',l_contractnames{l_ctid+1},'ctunit2',l_strategyinfo.secondcommodityunit(l_id),'rightid',l_rightid);
    end
    g_DBconfig.g_pairnames=cat(1,g_DBconfig.g_pairnames,l_pairnames);
    g_DBconfig.allpairs=cat(2,g_DBconfig.allpairs,l_allpairs);
end
%     g_DBconfig.allcontractnames=sort(g_DBconfig.allcontractnames);

% 写入xml文件
% xml_write(strcat(G_Start.currentpath,'/','g_DBconfig',in_strategyid,'.xml'),g_DBconfig);
g_DBconfig.isupdated=g_XMLfile.isupdated;
end