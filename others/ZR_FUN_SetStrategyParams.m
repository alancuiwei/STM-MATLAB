function ZR_FUN_SetStrategyParams(varargin)
%%%%%%%% 设置策略参数
global g_strategyparams;
global g_commoditynames;
% 参数赋值，优化执行时才会传入参数
if(nargin>0)
    % 默认是每种商品下单一手
    g_strategyparams.handnum=ones(1,length(g_commoditynames)); 
    l_commandstr='';
    for l_paramid=1:(nargin/2)   
        l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_commoditynames)); ');
    end
    eval(l_commandstr);
end