function ZR_PROCESS_RecordGridSearch(varargin)
% ������㣬�������
% param1�����һ����������Ʒ���ڣ���param2����ڶ���������ֹ��㣩
% �������������g_paramgrid��

global g_commoditynames;
global g_optimization;
global g_method;
global g_report;
global G_Start;

% ��ʾ������Ϣ
g_optimization.counter=g_optimization.counter+1;
G_Start.progress=g_optimization.counter/g_optimization.valuenum;
G_Start.runtime(g_optimization.counter)=toc;
G_Start.remaintime=(g_optimization.valuenum-g_optimization.counter)*G_Start.runtime(g_optimization.counter)/24/3600;
G_Start.endtime=clock+G_Start.remaintime;
fprintf('��ɽ���Ϊ��%d%%������Ҫʱ��Ϊ��%s\n',round(100*G_Start.progress),datestr(G_Start.remaintime,'HH:MM:SS'));

% ��¼�����Ͷ�Ӧ������ֵ
l_paramidstr=[];
l_paramstr=[];
for l_paramid=1:(nargin/2)
    l_paramorderid=find(double(g_optimization.range{l_paramid})==double(varargin{l_paramid*2}));
    l_paramidstr=strcat(l_paramidstr,num2str(l_paramorderid));
    l_paramstr=strcat(l_paramstr,num2str(varargin{l_paramid*2}));
    if l_paramid~=(nargin/2)
        l_paramstr=strcat(l_paramstr,',');
        l_paramidstr=strcat(l_paramidstr,',');
    end    
end
[l_totalvalue, l_commodityvalue]=g_method.runtargetfunction();
g_optimization.expectedvaluennum=length(l_totalvalue);
%%%%%%%%%%%%% �ܽ������
% ���������
l_commandstr=strcat('g_optimization.param{',l_paramidstr,'}=str2num(l_paramstr);');
eval(l_commandstr);
% ��ø���Ʒ�ֵ�����ֵ
l_cmnum=length(g_commoditynames);
for l_cmid=1:l_cmnum
    l_commandstr=strcat('g_optimization.commodity(l_cmid).expectedvalue(',l_paramidstr,')=l_commodityvalue(l_cmid);');
    eval(l_commandstr);
end
% �����������ֵ
l_commandstr=strcat('g_optimization.expectedvalue(',l_paramidstr,')=l_totalvalue;');
eval(l_commandstr);
end