function ZR_CONFIG_DataQuery_File(varargin)
% 清空命令行参数和所有变量

global G_ExtractHistoryDataFromMySQL;
global g_XMLfile;

G_ExtractHistoryDataFromMySQL=[];

switch varargin{1}
    case 'xml'
        if nargin>0
            % 从XML文件里读出
            ZR_CONFIG_SetFromXML(varargin{2});
        else
            error('程序执行必须依赖xml文件')
        end        
    case 'database'
        ZR_CONFIG_SetXMLfileFromDB(varargin{2},varargin{3},varargin{4});
end

% 从数据库里得到配置数据,策略参数hardcode
ZR_CONFIG_DataQuery_SetFromDB(g_XMLfile.strategyid);
% 获取数据库数据参数
ZR_CONFIG_G_ExtractHistoryDataFromMySQL();

end