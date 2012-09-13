function ZR_STOCK_CONFIG_G_Start()
% 记录运行时参数
global G_Start;
global g_XMLfile;
% G_Start.runmode=varargin;
G_Start.progress=[];
G_Start.starttime=[];
G_Start.remaintime=[];
G_Start.endtime=[];
if iscell(g_XMLfile)
    l_XMLfile=g_XMLfile{1};
else
    l_XMLfile=g_XMLfile;
end
if isempty(l_XMLfile.strategypath)
    G_Start.currentpath=pwd;
else
    G_Start.currentpath=l_XMLfile.strategypath;
end

end
