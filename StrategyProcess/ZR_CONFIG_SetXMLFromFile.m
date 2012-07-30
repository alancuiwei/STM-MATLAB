function ZR_CONFIG_SetXMLFromFile(varargin)
% ����XML�ļ�
global g_XMLfile;
% g_XMLfile=struct([]);
try
    l_cnt=1;
    for l_id=2:nargin
        if strfind(varargin{l_id},'g_XMLfile')
            g_XMLfile{l_cnt}=xml_read(varargin{l_id});
            if length(num2str(g_XMLfile{l_cnt}.strategyid))==5
                g_XMLfile{l_cnt}.strategyid=strcat('0',num2str(g_XMLfile{l_cnt}.strategyid));
            end
            l_cnt=l_cnt+1;
        end
    end
    % ���û������'strategypath'Ĭ���ڵ�ǰĿ¼
    if ~isfield(g_XMLfile{1},'strategypath')
        g_XMLfile{1}.strategypath='';
        g_XMLfile{1}.isupdated=0;
    end
    
    if numel(g_XMLfile)==1
        g_XMLfile=g_XMLfile{1};
    end
    
    % addpath(g_XMLfile.strategypath);
%     g_XMLfile.strategyid=num2str(g_XMLfile.strategyid);
%     if length(g_XMLfile.strategyid)==5
%         g_XMLfile.strategyid=strcat('0',g_XMLfile.strategyid);
%     end
catch
    if nargin>0
        error('xml�ļ������ڣ�%s',varargin{:});
    end
    g_XMLfile=[];
end
end