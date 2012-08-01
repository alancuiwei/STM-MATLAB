function ZR_CONFIG_G_RunSpecialTestCase()
% 记录运行时参数
global G_RunSpecialTestCase;
global g_XMLfile;
global g_DBconfig;

if iscell(g_XMLfile)
    l_XMLfile=g_XMLfile{1};
else
    l_XMLfile=g_XMLfile;
end

l_strategyid=l_XMLfile.strategyid;
switch l_strategyid(1:2)      %套利类型
    case '01'       %跨期套利
        G_RunSpecialTestCase.coredata.type='pair';
        G_RunSpecialTestCase.g_method.runstrategy.fun=@ZR_STRATEGY_PAIR;    
        G_RunSpecialTestCase.g_method.rundataprocess=@ZR_DATAPROCESS;
    case '04'       %单边策略
        G_RunSpecialTestCase.coredata.type='serial'; 
        G_RunSpecialTestCase.g_method.runstrategy.fun=@ZR_STRATEGY_SERIAL;
        G_RunSpecialTestCase.g_method.rundataprocess=@ZR_DATAPROCESS;
    case '10'       %？？？？？
end
% l_cmdstr=strcat('G_RunSpecialTestCase.g_method.rundataprocess=@ZR_DATAPROCESS_',l_strategyid,';');
% eval(l_cmdstr);

% G_RunSpecialTestCase.g_method.runstrategy.fun=@ZR_STRATEGY_SERIAL;
% G_RunSpecialTestCase.g_method.runstrategy.fun=@ZR_STRATEGY_PAIR;
% G_RunSpecialTestCase.g_method.rundataprocess=@ZR_DATAPROCESS_010603;
% G_RunSpecialTestCase.g_method.rundataprocess=@ZR_DATAPROCESS_040704;
%G_RunSpecialTestCase.coredata.type='pair';
G_RunSpecialTestCase.coredata.needupdate=1;
G_RunSpecialTestCase.issetbyXML=1;
% 如果有xml的设定就用xml
if G_RunSpecialTestCase.issetbyXML&&~l_XMLfile.isupdated
    G_RunSpecialTestCase.strategyid=l_XMLfile.strategyid;
    G_RunSpecialTestCase.coredata.startdate=l_XMLfile.coredata.startdate;
    G_RunSpecialTestCase.coredata.enddate=l_XMLfile.coredata.enddate;
    % 没有选择品种就用默认的所有品种
    l_commoditynames=l_XMLfile.g_commoditynames;
    if ~isempty(l_commoditynames)
        for l_stid=2:numel(g_XMLfile)
            if isempty(g_XMLfile{l_stid}.g_commoditynames)
                l_commoditynames={};
                break;
            end
            l_idx=ismember(l_commoditynames,g_XMLfile{l_stid}.g_commoditynames);
            if isempty(find(l_idx,1))
                l_commoditynames={};
                break;
            end
            l_commoditynames=l_commoditynames(l_idx);
        end
    end
    
    if isempty(l_commoditynames)
        G_RunSpecialTestCase.g_commoditynames=g_DBconfig.g_commoditynames;
        G_RunSpecialTestCase.g_pairnames=g_DBconfig.g_pairnames;
        G_RunSpecialTestCase.g_contractnames=g_DBconfig.allcontractnames;
    else
        G_RunSpecialTestCase.g_commoditynames=l_commoditynames;
        G_RunSpecialTestCase.g_pairnames=g_DBconfig.g_pairnames;   
        G_RunSpecialTestCase.g_contractnames=g_DBconfig.allcontractnames;
    end
%     if strcmp(g_XMLfile.strategyid, 'single')
%         G_RunSpecialTestCase.g_contractnames=g_DBconfig.g_contractnames;
%     else
%         G_RunSpecialTestCase.g_pairnames=g_DBconfig.g_pairnames; 
%     end
    % 
    
%     l_titlenames=fieldnames(l_XMLfile.g_strategyparams);
%     l_commandstr='';
%     if ~isempty(l_titlenames)
%         for l_titleid=1:length(l_titlenames)
%             l_commandstr=strcat(l_commandstr,...
%                 sprintf('G_RunSpecialTestCase.g_strategyparams.%s=g_XMLfile.g_strategyparams.%s*%s',...
%                 l_titlenames{l_titleid},l_titlenames{l_titleid},'ones(length(G_RunSpecialTestCase.g_commoditynames),1);')); 
%         end
%     end
%     eval(l_commandstr);  
else
    G_RunSpecialTestCase.coredata.startdate='nolimit';
    G_RunSpecialTestCase.coredata.enddate='nolimit';
    G_RunSpecialTestCase.strategyid=g_DBconfig.strategyid;
    G_RunSpecialTestCase.g_commoditynames=g_DBconfig.g_commoditynames;
    G_RunSpecialTestCase.g_pairnames=g_DBconfig.g_pairnames;
    G_RunSpecialTestCase.g_contractnames=g_DBconfig.allcontractnames;
    
%     l_titlenames=fieldnames(l_XMLfile.g_strategyparams);
%     l_commandstr='';
%     if ~isempty(l_titlenames)
%         for l_titleid=1:length(l_titlenames)
%             l_commandstr=strcat(l_commandstr,...
%                 sprintf('G_RunSpecialTestCase.g_strategyparams.%s=g_XMLfile.g_strategyparams.%s*%s',...
%                 l_titlenames{l_titleid},l_titlenames{l_titleid},'ones(length(G_RunSpecialTestCase.g_commoditynames),1);')); 
%         end
%     end
%     eval(l_commandstr);  
%     G_RunSpecialTestCase.g_contractnames={'',''};
%     G_RunSpecialTestCase.g_strategyparams(1).period=4*ones(100,1);
%     G_RunSpecialTestCase.g_strategyparams(1).losses=0*ones(100,1);
%     G_RunSpecialTestCase.g_strategyparams(1).wins=-56*ones(100,1);
%     G_RunSpecialTestCase.g_strategyparams(1).handnum=1*ones(100,1);        
end

% 策略参数设定
if iscell(g_XMLfile)
    for l_xmlid = 1:numel(g_XMLfile)
        l_titlenames=fieldnames(g_XMLfile{l_xmlid}.g_strategyparams);
        l_commandstr='';
        if ~isempty(l_titlenames)
            for l_titleid=1:length(l_titlenames)
                l_commandstr=strcat(l_commandstr,...
                    sprintf('G_RunSpecialTestCase.g_strategyparams%s.%s=g_XMLfile%s.g_strategyparams.%s*%s',...
                    strcat('{',num2str(l_xmlid),'}'),l_titlenames{l_titleid},...
                    strcat('{',num2str(l_xmlid),'}'),l_titlenames{l_titleid},'ones(length(G_RunSpecialTestCase.g_commoditynames),1);')); 
            end
        end
        eval(l_commandstr);
        G_RunSpecialTestCase.g_strategyparams{l_xmlid}.handnum=1*ones(length(G_RunSpecialTestCase.g_commoditynames),1);
    end
else
    l_titlenames=fieldnames(g_XMLfile.g_strategyparams);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_commandstr=strcat(l_commandstr,...
                sprintf('G_RunSpecialTestCase.g_strategyparams.%s=g_XMLfile.g_strategyparams.%s*%s',...
                l_titlenames{l_titleid},l_titlenames{l_titleid},'ones(length(G_RunSpecialTestCase.g_commoditynames),1);')); 
        end
    end
    eval(l_commandstr);  
    G_RunSpecialTestCase.g_strategyparams(1).handnum=1*ones(length(G_RunSpecialTestCase.g_commoditynames),1);    
end
    

% 策略运行时需要的数据
G_RunSpecialTestCase.g_tradedata.pos.num=0;
G_RunSpecialTestCase.g_tradedata.pos.name={};
G_RunSpecialTestCase.g_tradedata.pos.rightid={};
G_RunSpecialTestCase.g_tradedata.pos.isclosepos=[];
G_RunSpecialTestCase.g_tradedata.pos.opdate={};
G_RunSpecialTestCase.g_tradedata.pos.cpdate={};
G_RunSpecialTestCase.g_tradedata.pos.opdateprice=[];
G_RunSpecialTestCase.g_tradedata.pos.cpdateprice=[];
G_RunSpecialTestCase.g_tradedata.pos.margin=[];
G_RunSpecialTestCase.g_tradedata.pos.optradecharge=[];
G_RunSpecialTestCase.g_tradedata.pos.cptradecharge=[];
G_RunSpecialTestCase.g_tradedata.pos.profit=[];
G_RunSpecialTestCase.g_orderlist.price=[];
G_RunSpecialTestCase.g_orderlist.direction=[];
G_RunSpecialTestCase.g_orderlist.name={};
G_RunSpecialTestCase.g_orderlist.num=[];
% % G_RunSpecialTestCase.g_tradedata.pos.type=[];
% % G_RunSpecialTestCase.g_tradedata.pos.optype=[];
% % G_RunSpecialTestCase.g_tradedata.pos.cptype=[];
% % G_RunSpecialTestCase.g_tradedata.pos.gapdiff=[];
% % G_RunSpecialTestCase.g_tradedata.pos.opgapvl1=[];
% % G_RunSpecialTestCase.g_tradedata.pos.opgapvl2=[];
% % G_RunSpecialTestCase.g_tradedata.pos.cpgapvl1=[];
% % G_RunSpecialTestCase.g_tradedata.pos.cpgapvl2=[];
% % G_RunSpecialTestCase.g_tradedata.trade.num=[];
% % G_RunSpecialTestCase.g_tradedata.trade.name={};
% % G_RunSpecialTestCase.g_tradedata.trade.type=[];
% % G_RunSpecialTestCase.g_tradedata.trade.isclosepos=[];
% % G_RunSpecialTestCase.g_tradedata.trade.opdate={};
% % G_RunSpecialTestCase.g_tradedata.trade.cpdate={};
% % G_RunSpecialTestCase.g_tradedata.trade.gapdiff=[];
% % G_RunSpecialTestCase.g_tradedata.trade.profit=[];
% 报告中的数据
G_RunSpecialTestCase.g_report.commodity.record.pos.num=0;
G_RunSpecialTestCase.g_report.commodity.record.pos.name={};
G_RunSpecialTestCase.g_report.commodity.record.pos.rightid={};
G_RunSpecialTestCase.g_report.commodity.record.pos.isclosepos=[];
G_RunSpecialTestCase.g_report.commodity.record.pos.opdate={};
G_RunSpecialTestCase.g_report.commodity.record.pos.cpdate={};
G_RunSpecialTestCase.g_report.commodity.record.pos.opdateprice=[];
G_RunSpecialTestCase.g_report.commodity.record.pos.cpdateprice=[];
G_RunSpecialTestCase.g_report.commodity.record.pos.margin=[];
G_RunSpecialTestCase.g_report.commodity.record.pos.optradecharge=[];
G_RunSpecialTestCase.g_report.commodity.record.pos.cptradecharge=[];
G_RunSpecialTestCase.g_report.commodity.record.pos.profit=[];
% % G_RunSpecialTestCase.g_report.commodity.record.pos.type=[];
% % G_RunSpecialTestCase.g_report.commodity.record.pos.optype=[];
% % G_RunSpecialTestCase.g_report.commodity.record.pos.cptype=[];
% % G_RunSpecialTestCase.g_report.commodity.record.pos.opgapvl1=[];
% % G_RunSpecialTestCase.g_report.commodity.record.pos.opgapvl2=[];
% % G_RunSpecialTestCase.g_report.commodity.record.pos.cpgapvl1=[];
% % G_RunSpecialTestCase.g_report.commodity.record.pos.cpgapvl2=[];
% % G_RunSpecialTestCase.g_report.commodity.record.trade.num=0;
% % G_RunSpecialTestCase.g_report.commodity.record.trade.name={};
% % G_RunSpecialTestCase.g_report.commodity.record.trade.type=[];
% % G_RunSpecialTestCase.g_report.commodity.record.trade.isclosepos=[];
% % G_RunSpecialTestCase.g_report.commodity.record.trade.opdate={};
% % G_RunSpecialTestCase.g_report.commodity.record.trade.cpdate={};
% % G_RunSpecialTestCase.g_report.commodity.record.trade.profit=[];
G_RunSpecialTestCase.g_report.commodity.orderlist.num=0;
G_RunSpecialTestCase.g_report.commodity.orderlist.price=[];
G_RunSpecialTestCase.g_report.commodity.orderlist.direction=[];
G_RunSpecialTestCase.g_report.commodity.orderlist.name={};

G_RunSpecialTestCase.g_report.startdatenum=[];
G_RunSpecialTestCase.g_report.enddatenum=[];
% pos
G_RunSpecialTestCase.g_report.record.pos.num=0;
G_RunSpecialTestCase.g_report.record.pos.name={};
G_RunSpecialTestCase.g_report.record.pos.rightid={};
G_RunSpecialTestCase.g_report.record.pos.isclosepos=[];
G_RunSpecialTestCase.g_report.record.pos.opdate={};
G_RunSpecialTestCase.g_report.record.pos.cpdate={};
G_RunSpecialTestCase.g_report.record.pos.opdateprice=[];
G_RunSpecialTestCase.g_report.record.pos.cpdateprice=[];
G_RunSpecialTestCase.g_report.record.pos.margin=[];
G_RunSpecialTestCase.g_report.record.pos.optradecharge=[];
G_RunSpecialTestCase.g_report.record.pos.cptradecharge=[];
G_RunSpecialTestCase.g_report.record.pos.profit=[];
% % G_RunSpecialTestCase.g_report.record.pos.type=[];
% % G_RunSpecialTestCase.g_report.record.pos.optype=[];
% % G_RunSpecialTestCase.g_report.record.pos.cptype=[];
% % G_RunSpecialTestCase.g_report.record.pos.opgapvl1=[];
% % G_RunSpecialTestCase.g_report.record.pos.opgapvl2=[];
% % G_RunSpecialTestCase.g_report.record.pos.cpgapvl1=[];
% % G_RunSpecialTestCase.g_report.record.pos.cpgapvl2=[];
G_RunSpecialTestCase.g_report.orderlist.price=[];
G_RunSpecialTestCase.g_report.orderlist.direction=[];
G_RunSpecialTestCase.g_report.orderlist.name={};
G_RunSpecialTestCase.g_report.orderlist.num=[];
% % % trade
% % G_RunSpecialTestCase.g_report.record.trade.num=0;
% % G_RunSpecialTestCase.g_report.record.trade.name={};
% % G_RunSpecialTestCase.g_report.record.trade.type=[];
% % G_RunSpecialTestCase.g_report.record.trade.isclosepos=[];
% % G_RunSpecialTestCase.g_report.record.trade.opdate={};
% % G_RunSpecialTestCase.g_report.record.trade.cpdate={};
% % G_RunSpecialTestCase.g_report.record.trade.profit=[];
% reference
G_RunSpecialTestCase.g_reference.sort.aveyearreturnrate.direction='descend';
G_RunSpecialTestCase.g_reference.sort.aveyearreturnrate.weight=0.2;
G_RunSpecialTestCase.g_reference.sort.totaltradenumperday.direction='descend';
G_RunSpecialTestCase.g_reference.sort.totaltradenumperday.weight=0.2;
G_RunSpecialTestCase.g_reference.sort.profittraderate.direction='descend';
G_RunSpecialTestCase.g_reference.sort.profittraderate.weight=0.1;
G_RunSpecialTestCase.g_reference.sort.expectedvalue.direction='descend';
G_RunSpecialTestCase.g_reference.sort.expectedvalue.weight=0.3;
G_RunSpecialTestCase.g_reference.sort.maxdrawdown.direction='ascend';
G_RunSpecialTestCase.g_reference.sort.maxdrawdown.weight=0.2;
G_RunSpecialTestCase.g_reference.sortorder={};
end