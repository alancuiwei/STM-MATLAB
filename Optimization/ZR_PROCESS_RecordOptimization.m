function ZR_PROCESS_RecordOptimization(varargin)
% 网格计算，参数配对
% 计算的网格存放在g_paramgrid里

global g_commoditynames;
global g_optimization;
global g_method;
global g_report;
global G_Start;
global g_reportformat;



% 运行策略
tic;
g_report=g_reportformat;
g_method.runstrategy(varargin{:});


% 显示运行信息
g_optimization.counter=g_optimization.counter+1;
G_Start.progress=g_optimization.counter/g_optimization.valuenum;
G_Start.runtime(g_optimization.counter)=toc;
G_Start.remaintime=(g_optimization.valuenum-g_optimization.counter)*G_Start.runtime(g_optimization.counter)/24/3600;
G_Start.endtime=clock+G_Start.remaintime;
fprintf('完成进度为：%d%%，还需要时间为：%s\n',round(100*G_Start.progress),datestr(G_Start.remaintime,'HH:MM:SS'));

% 记录参数和对应的期望值
% l_paramidstr=[];
l_paramstr=[];
for l_paramid=1:(nargin/2)
%    l_paramorderid=find(double(g_optimization.range{l_paramid})==double(varargin{l_paramid*2}));
%     l_paramidstr=strcat(l_paramidstr,num2str(l_paramorderid));
    l_paramstr=strcat(l_paramstr,num2str(varargin{l_paramid*2}));
    if l_paramid~=(nargin/2)
        l_paramstr=strcat(l_paramstr,',');
%         l_paramidstr=strcat(l_paramidstr,',');
    end    
end
[l_totalvalue, l_commodityvalue]=g_method.runtargetfunction();
g_optimization.expectedvaluennum=length(l_totalvalue);
%%%%%%%%%%%%% 总交易情况
% 计算参数组
l_valuecounter=length(g_optimization.param);
g_optimization.param{l_valuecounter+1}=str2num(l_paramstr);
% 获得各个品种的期望值
l_cmnum=length(g_commoditynames);
for l_cmid=1:l_cmnum
    g_optimization.commodity(l_cmid).expectedvalue(l_valuecounter+1)=l_commodityvalue(l_cmid);
end
% 计算最悲观期望值
g_optimization.expectedvalue(l_valuecounter+1)=l_totalvalue;
end