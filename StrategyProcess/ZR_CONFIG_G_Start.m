function ZR_CONFIG_G_Start()
% ��¼����ʱ����
global G_Start;
global g_XMLfile;
G_Start.runmode=[];
G_Start.progress=[];
G_Start.starttime=[];
G_Start.remaintime=[];
G_Start.endtime=[];
if isempty(g_XMLfile.strategypath)
    G_Start.currentpath=pwd;
else
    G_Start.currentpath=g_XMLfile.strategypath;
end
end