function ZR_FUN_SetParamsPerCommodity(in_cmid)
%%%%%%%% 根据每一个品种，设置策略参数
global g_strategyparams;
global g_commodityparams;
g_commodityparams=[];
l_paramnames=fieldnames(g_strategyparams);
% 设置g_indicatordata的值
l_commandstr='';
for l_paramid=1:length(l_paramnames)
    l_judge=sprintf('~isempty(g_strategyparams.%s)',l_paramnames{l_paramid});
    if eval(l_judge)
        l_commandstr=strcat(l_commandstr,'g_commodityparams.',l_paramnames{l_paramid},'=g_strategyparams.',...
            l_paramnames{l_paramid},'(in_cmid);');
    end
end
eval(l_commandstr);