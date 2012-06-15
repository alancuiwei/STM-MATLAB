function ZR_CONFIG_File(varargin)
% 清空命令行参数和所有变量
global G_Start;
global G_ExtractHistoryDataFromMySQL;
global G_RunSpecialTestCase;
global G_ShowTestResults;
global G_RunOptimization;
% global G_ConfigFile;
global g_XMLfile;
G_Start=[];
G_ExtractHistoryDataFromMySQL=[];
G_RunSpecialTestCase=[];
G_ShowTestResults=[];
G_RunOptimization=[];
switch varargin{1}
    case 'xml'
        if nargin>0
            % 从XML文件里读出
            ZR_CONFIG_SetFromXML(varargin{2});
        else
            error('程序执行必须依赖xml文件')
        end        
    case 'database'
end
% 配置程序运行参数
ZR_CONFIG_G_Start();
% 从数据库里得到配置数据,策略参数hardcode
ZR_CONFIG_SetFromDB(g_XMLfile.strategyid);
% 获取数据库数据参数
ZR_CONFIG_G_ExtractHistoryDataFromMySQL();
% 设置只运行一个case时候的参数
ZR_CONFIG_G_RunSpecialTestCase();
% 记录测试结果展示参数
ZR_CONFIG_G_ShowTestResults();
% 记录优化过程参数
ZR_CONFIG_G_RunOptimization();

% G_ConfigFile.G_Start=G_Start;
% G_ConfigFile.G_ExtractHistoryDataFromMySQL=G_ExtractHistoryDataFromMySQL;
% G_ConfigFile.G_RunSpecialTestCase=G_RunSpecialTestCase;
% G_ConfigFile.G_ShowTestResults=G_ShowTestResults;
% G_ConfigFile.G_RunOptimization=G_RunOptimization;
% xml_write('G_ConfigFile.xml',G_ConfigFile);
end