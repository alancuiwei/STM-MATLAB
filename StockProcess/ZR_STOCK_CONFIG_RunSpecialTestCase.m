function ZR_STOCK_CONFIG_RunSpecialTestCase()
% 记录运行时参数
% global G_RunSpecialTestCase;
global g_database;
global g_XMLfile;
global g_strategyid;
global g_rightid;
global g_method;
global g_commoditynames;
global g_contractnames;
global g_pairnames;
global g_allpairs;
global g_strategyparams;
% global g_DBconfig;
global g_tradedata;
global g_report;
global g_reference;
global coredata;

g_contractnames = {};
g_pairnames = {};
g_allpairs = [];

% 根据策略名，生成策略信息
l_strategyinfo=ZR_STOCK_FUN_QueryArbitrageInfo(g_strategyid);
g_rightid=l_strategyinfo.rightid;
% 根据策略信息，生成品种名、品种合约、套利对名称和套利对
for l_id=1:length(l_strategyinfo.rightid)
    l_rightid=cell2mat(l_strategyinfo.rightid(l_id));
    switch l_rightid(1:2)       %套利类型
        case '01'       %跨期套利
            g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);           %包含'-'说明是套利对
        case '02'       %跨产品套利
        case '04'       %单边策略
            g_commoditynames=l_strategyinfo.firstcommodityid;           %单边策略，去掉'-'
        case '10'       %？？？？？
    end
    switch(l_rightid(7:8))
        case '01'       %逐月套利对
            l_months=ZR_STOCK_FUN_QueryDeliverMonths(l_strategyinfo.firstcommodityid{l_id});  %查询该品种主力合约
        case '02'       %主力/次主力套利对
            l_months=ZR_STOCK_FUN_QueryMasterMonths(l_strategyinfo.firstcommodityid{l_id});   %查询该品种主力合约
    end
    l_contractnames=ZR_STOCK_FUN_QueryContractnames(l_strategyinfo.firstcommodityid{l_id},cell2mat(l_months));        %查询该品种所有合约名
    l_allpairs=struct('ctname1',[],'ctunit1',[],'ctname2',[],'ctunit2',[],'rightid',l_rightid);
    g_contractnames=cat(1,g_contractnames,l_contractnames(:));
    l_pairnames=cell((length(l_contractnames)-1),1);
    for l_ctid=1:(length(l_contractnames)-1) 
        l_pairnames{l_ctid}=strcat(l_contractnames{l_ctid},'-',l_contractnames{l_ctid+1});
        l_allpairs(l_ctid)=struct('ctname1',l_contractnames{l_ctid},'ctunit1',l_strategyinfo.firstcommodityunit(l_id),...
            'ctname2',l_contractnames{l_ctid+1},'ctunit2',l_strategyinfo.secondcommodityunit(l_id),'rightid',l_rightid);
    end
    g_pairnames=cat(1,g_pairnames,l_pairnames);
    g_allpairs=cat(2,g_allpairs,l_allpairs);
end

% 根据输入的策略名前两位，选择对应的数据处理和策略处理函数
switch g_strategyid(1:2)      %套利类型
    case '01'           %跨期套利
        g_method.runstrategy.fun=@ZR_STOCK_STRATEGY_PAIR;
        coredata.type='pair';
    case '04'           %单边策略
        g_method.runstrategy.fun=@ZR_STOCK_STRATEGY_SERIAL;  
        coredata.type='serial';
end
g_method.rundataprocess=@ZR_STOCK_DATAPROCESS;        %对于数据的处理，不区分策略

if ~g_XMLfile.isupdated
    coredata.startdate=g_XMLfile.coredata.startdate;
    coredata.enddate=g_XMLfile.coredata.enddate;
else
    coredata.startdate='nolimit';
    coredata.enddate='nolimit';
end

if ~isempty(g_XMLfile.g_commoditynames)
    g_commoditynames=g_XMLfile.g_commoditynames;
end
    
% 策略参数设定
    l_titlenames=fieldnames(g_XMLfile.g_strategyparams);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_commandstr=strcat(l_commandstr,...
                sprintf('g_strategyparams.%s=g_XMLfile.g_strategyparams.%s*%s',...
                l_titlenames{l_titleid},l_titlenames{l_titleid},'ones(length(g_commoditynames),1);')); 
        end
    end
    eval(l_commandstr);  
    g_strategyparams(1).handnum=1*ones(length(g_commoditynames),1);

% 策略运行时需要的数据
g_tradedata.pos.num=0;
g_tradedata.pos.name={};
g_tradedata.pos.rightid={};
g_tradedata.pos.isclosepos=[];
g_tradedata.pos.opdate={};
g_tradedata.pos.cpdate={};
g_tradedata.pos.opdateprice=[];
g_tradedata.pos.cpdateprice=[];
g_tradedata.pos.margin=[];
g_tradedata.pos.optradecharge=[];
g_tradedata.pos.cptradecharge=[];
g_tradedata.pos.profit=[];
% % g_tradedata.pos.type=[];
% % g_tradedata.pos.optype=[];
% % g_tradedata.pos.cptype=[];
% % g_tradedata.pos.gapdiff=[];
% % g_tradedata.pos.opgapvl1=[];
% % g_tradedata.pos.opgapvl2=[];
% % g_tradedata.pos.cpgapvl1=[];
% % g_tradedata.pos.cpgapvl2=[];
% % g_tradedata.trade.num=[];
% % g_tradedata.trade.name={};
% % g_tradedata.trade.type=[];
% % g_tradedata.trade.isclosepos=[];
% % g_tradedata.trade.opdate={};
% % g_tradedata.trade.cpdate={};
% % g_tradedata.trade.gapdiff=[];
% % g_tradedata.trade.profit=[];
% 报告中的数据
g_report.commodity.record.pos.num=0;
g_report.commodity.record.pos.name={};
g_report.commodity.record.pos.rightid={};
g_report.commodity.record.pos.isclosepos=[];
g_report.commodity.record.pos.opdate={};
g_report.commodity.record.pos.cpdate={};
g_report.commodity.record.pos.opdateprice=[];
g_report.commodity.record.pos.cpdateprice=[];
g_report.commodity.record.pos.margin=[];
g_report.commodity.record.pos.optradecharge=[];
g_report.commodity.record.pos.cptradecharge=[];
g_report.commodity.record.pos.profit=[];
% % g_report.commodity.record.pos.type=[];
% % g_report.commodity.record.pos.optype=[];
% % g_report.commodity.record.pos.cptype=[];
% % g_report.commodity.record.pos.opgapvl1=[];
% % g_report.commodity.record.pos.opgapvl2=[];
% % g_report.commodity.record.pos.cpgapvl1=[];
% % g_report.commodity.record.pos.cpgapvl2=[];
% % g_report.commodity.record.trade.num=0;
% % g_report.commodity.record.trade.name={};
% % g_report.commodity.record.trade.type=[];
% % g_report.commodity.record.trade.isclosepos=[];
% % g_report.commodity.record.trade.opdate={};
% % g_report.commodity.record.trade.cpdate={};
% % g_report.commodity.record.trade.profit=[];

g_report.startdatenum=[];
g_report.enddatenum=[];
% pos
g_report.record.pos.num=0;
g_report.record.pos.name={};
g_report.record.pos.rightid={};
g_report.record.pos.isclosepos=[];
g_report.record.pos.opdate={};
g_report.record.pos.cpdate={};
g_report.record.pos.opdateprice=[];
g_report.record.pos.cpdateprice=[];
g_report.record.pos.margin=[];
g_report.record.pos.optradecharge=[];
g_report.record.pos.cptradecharge=[];
g_report.record.pos.profit=[];
% % g_report.record.pos.type=[];
% % g_report.record.pos.optype=[];
% % g_report.record.pos.cptype=[];
% % g_report.record.pos.opgapvl1=[];
% % g_report.record.pos.opgapvl2=[];
% % g_report.record.pos.cpgapvl1=[];
% % g_report.record.pos.cpgapvl2=[];

% % % trade
% % g_report.record.trade.num=0;
% % g_report.record.trade.name={};
% % g_report.record.trade.type=[];
% % g_report.record.trade.isclosepos=[];
% % g_report.record.trade.opdate={};
% % g_report.record.trade.cpdate={};
% % g_report.record.trade.profit=[];
% reference
g_reference.sort.aveyearreturnrate.direction='descend';
g_reference.sort.aveyearreturnrate.weight=0.2;
g_reference.sort.totaltradenumperday.direction='descend';
g_reference.sort.totaltradenumperday.weight=0.2;
g_reference.sort.profittraderate.direction='descend';
g_reference.sort.profittraderate.weight=0.1;
g_reference.sort.expectedvalue.direction='descend';
g_reference.sort.expectedvalue.weight=0.3;
g_reference.sort.maxdrawdown.direction='ascend';
g_reference.sort.maxdrawdown.weight=0.2;
g_reference.sortorder={};
end
