function ZR_CONFIG_SetFromXML(varargin)
% 读入XML文件
global g_XMLfile;
try
    g_XMLfile=xml_read(varargin{:});
    % 如果没有输入'strategypath'默认在当前目录
    if ~isfield(g_XMLfile,'strategypath')
        g_XMLfile.strategypath=pwd;
        g_XMLfile.isupdated=0;
    end
    g_XMLfile.strategyid=num2str(g_XMLfile.strategyid);
    if length(g_XMLfile.strategyid)==5
        g_XMLfile.strategyid=strcat('0',g_XMLfile.strategyid);
    end
catch
    if nargin>0
        error('xml文件不存在：%s',varargin{:});
    end
    g_XMLfile=[];
end
end