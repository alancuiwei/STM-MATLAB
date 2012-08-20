function ZR_FUN_SetStrategyParams(varargin)
%%%%%%%% 设置策略参数
global g_strategyparams;
global g_commoditynames;
global g_XMLfile;
% 参数赋值，优化执行时才会传入参数
% if(nargin>0)
%     % 默认是每种商品下单一手
%     l_commandstr='';
%     for l_paramid=1:(nargin/2)   
%         l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_commoditynames)); ');
%     end
%     eval(l_commandstr);
% end

% 策略参数设定
l_paramid=0;
l_paramstartnum=1;
for l_id=1:length(g_XMLfile)
    if length(g_XMLfile)>1
        l_commandstr='';
        l_titlenames=fieldnames(g_XMLfile{l_id}.g_strategyparams);
        l_paramendnum=length(l_titlenames)+l_paramstartnum-1;        
        for l_paramid=l_paramstartnum:l_paramendnum
            l_commandstr=sprintf('g_strategyparams{%d}.%s=%s*ones(1,length(g_commoditynames));',l_id,varargin{l_paramid*2-1},num2str(varargin{l_paramid*2}));
            eval(l_commandstr);
            l_paramstartnum=l_paramendnum+1;
        end     
    else
        l_commandstr='';
        l_titlenames=fieldnames(g_XMLfile.g_strategyparams);
        l_paramendnum=length(l_titlenames)+l_paramstartnum-1;          
        for l_paramid=1:(nargin/2)   
            l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_commoditynames)); ');
        end
        eval(l_commandstr);        
    end
    
    
end 