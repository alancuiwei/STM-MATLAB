function ZR_FUN_SetStrategyParams(varargin)
%%%%%%%% ���ò��Բ���
global g_strategyparams;
global g_commoditynames;
% ������ֵ���Ż�ִ��ʱ�Żᴫ�����
if(nargin>0)
    % Ĭ����ÿ����Ʒ�µ�һ��
    g_strategyparams.handnum=ones(1,length(g_commoditynames)); 
    l_commandstr='';
    for l_paramid=1:(nargin/2)   
        l_commandstr=strcat(l_commandstr,'g_strategyparams.',varargin{l_paramid*2-1},'=',num2str(varargin{l_paramid*2}),'*ones(1,length(g_commoditynames)); ');
    end
    eval(l_commandstr);
end