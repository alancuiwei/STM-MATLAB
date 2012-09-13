function ZR_STOCK_CONFIG_G_RunOptimization()
% 记录优化过程参数
global G_RunOptimization;
global G_RunSpecialTestCase;
global g_XMLfile;

if iscell(g_XMLfile)
    if ~isfield(g_XMLfile{1}, 'adjustparams')
        return;
    end    
    l_XMLfile=g_XMLfile{1};    
    for l_id=2:length(g_XMLfile)
        l_XMLfile.strategyid=strcat(l_XMLfile.strategyid,'-',g_XMLfile{l_id}.strategyid);
    end
    % 策略参数设定
    l_paramid=0;
    for l_id=1:length(g_XMLfile)
        l_titlenames=fieldnames(g_XMLfile{l_id}.g_strategyparams);
        l_commandstr='';
        
        if ~isempty(l_titlenames)
            for l_titleid=1:length(l_titlenames)
                l_paramid=l_paramid+1;
                l_commandstr=strcat(l_commandstr,...
                    sprintf('G_RunOptimization.g_optimization.adjustparams{%d}.data=g_XMLfile{%d}.adjustparams.%s;',...
                    l_paramid,l_id,l_titlenames{l_titleid})); 
                l_commandstr=strcat(l_commandstr,...
                    sprintf('G_RunOptimization.g_optimization.adjustparams{%d}.name={''%s''};',...
                    l_paramid,l_titlenames{l_titleid}));              
            end
        end
        eval(l_commandstr); 
    end 
else
    if ~isfield(g_XMLfile, 'adjustparams')
        return;
    end      
    l_XMLfile=g_XMLfile;
    l_titlenames=fieldnames(g_XMLfile.g_strategyparams);
    l_commandstr='';
    l_paramid=0;
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_paramid=l_paramid+1;
            l_commandstr=strcat(l_commandstr,...
                sprintf('G_RunOptimization.g_optimization.adjustparams{%d}.data=g_XMLfile.adjustparams.%s;',...
                l_paramid,l_titlenames{l_titleid})); 
            l_commandstr=strcat(l_commandstr,...
                sprintf('G_RunOptimization.g_optimization.adjustparams{%d}.name={''%s''};',...
                l_paramid,l_titlenames{l_titleid}));             
        end
    end
    eval(l_commandstr); 
end
% 优化过程
switch l_XMLfile.optimizedmethod
    case 0
        G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_SimulatedAnnealingSearch;
    case 1
        G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_MultipointHillClimbingSearch; 
    case 2
        G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_AnotherMultipointHillClimbingSearch;
    case 3
        G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_SimulatedAnnealingSearch;
    case 4
        G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_SimulatedAnnealingSearch2;
    case 5
        G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_GeneticAlgorithmSearchV2;
    case 6
        G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_PrioritizedStepSearch;        
end
% G_RunOptimization=read_xml('OPTIMIZE_GridSearch_01061.xml');
% G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_GridSearch;
% G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_PrioritizedStepSearch;
% G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_GeneticAlgorithmSearchV2;
% G_RunOptimization.g_method.runopimization=@ZR_STOCK_OPTIMIZE_GeneticAlgorithmSearchV2;
switch l_XMLfile.strategyid(1:2)      %套利类型
    case '01'           %跨期套利
        G_RunOptimization.g_method.runstrategy=@ZR_STOCK_STRATEGY_PAIR;
        G_RunOptimization.coredata.type='pair';
    case '04'           %单边策略
        G_RunOptimization.g_method.runstrategy=@ZR_STOCK_STRATEGY_SERIAL;  
        G_RunOptimization.coredata.type='serial';
end
% G_RunOptimization.g_method.runstrategy=@ZR_STOCK_STRATEGY_PAIR;
G_RunOptimization.g_method.rundataprocess=@ZR_STOCK_DATAPROCESS;
G_RunOptimization.g_method.runtargetfunction=@ZR_STOCK_TARGETFUNCTION_MostPessimistic;
% G_RunOptimization.coredata.type='pair';
G_RunOptimization.coredata.needupdate=1;
% G_RunOptimization.coredata.startdate='nolimit';
% G_RunOptimization.coredata.enddate='2011-12-01';

G_RunOptimization.strategyid=l_XMLfile.strategyid;
G_RunOptimization.coredata.startdate=l_XMLfile.coredata.startdate;
G_RunOptimization.coredata.enddate=l_XMLfile.coredata.enddate;

G_RunOptimization.g_commoditynames=G_RunSpecialTestCase.g_commoditynames;
G_RunOptimization.g_pairnames=G_RunSpecialTestCase.g_pairnames;
G_RunOptimization.g_contractnames=G_RunSpecialTestCase.g_contractnames;
G_RunOptimization.g_report=G_RunSpecialTestCase.g_report;




%G_RunOptimization.g_optimization.adjustparams.period.data=12:4:20;
%G_RunOptimization.g_optimization.adjustparams.losses.data=0:50:200;
%G_RunOptimization.g_optimization.adjustparams.wins.data=-100:50:100;

% G_RunOptimization.g_optimization.adjustparams.countersofup.data=3:4;
% G_RunOptimization.g_optimization.adjustparams.countersofdown.data=5:6;
% G_RunOptimization.g_optimization.adjustparams.losses.data=[50,60,70];
% G_RunOptimization.g_optimization.adjustparams.sharp.data=[50,100,150];
% G_RunOptimization.g_optimization.adjustparams.sharpdays.data=2:3;
% G_RunOptimization.g_optimization.adjustparams.period.data=4:2:24;
% G_RunOptimization.g_optimization.adjustparams.losses.data=-100:10:100;
% G_RunOptimization.g_optimization.adjustparams.wins.data=-100:10:100;

G_RunOptimization.g_optimization.commodity.expectedvalue=[];
G_RunOptimization.g_optimization.param={};
G_RunOptimization.g_optimization.expectedvalue=[];
G_RunOptimization.g_optimization.counter=0;
% G_RunOptimization.g_optimization.commodity.param.data=;
end
