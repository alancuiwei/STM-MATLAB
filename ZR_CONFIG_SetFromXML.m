function ZR_CONFIG_SetFromXML(varargin)
% ����XML�ļ�
global g_XMLfile;
try
    g_XMLfile=xml_read(varargin{:});
    % ���û������'strategypath'Ĭ���ڵ�ǰĿ¼
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
        error('xml�ļ������ڣ�%s',varargin{:});
    end
    g_XMLfile=[];
end
end