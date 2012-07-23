function ZR_CONFIG_Start(varargin)
% 清空命令行参数和所有变量
% clear global;
% global G_Start;
% global G_ExtractHistoryDataFromMySQL;
% global G_RunSpecialTestCase;
% global G_ShowTestResults;
% global G_RunOptimization;
% % global G_ConfigFile;
% global g_XMLfile;
% G_Start=[];
% G_ExtractHistoryDataFromMySQL=[];
% G_RunSpecialTestCase=[];
% G_ShowTestResults=[];
% G_RunOptimization=[];

% 载入mat数据
if exist('./Data/DATABASE_History.mat','file')
    % 导入数据库数据
    load(strcat('./Data/DATABASE_History.mat'));     %从mat文件导入g_database变量中
else
    ZR_FUN_Disp('程序依赖于DATABASE_History.mat文件!','need DATABASE_History.mat!');
    error('stopped!');
end

switch varargin{1}
    case 'xml'
        ZR_CONFIG_SetXMLFromFile(varargin{2});    
    case 'database'
        ZR_CONFIG_SetXMLFromDB(varargin{2},varargin{3},varargin{4});
    otherwise
        ZR_FUN_Disp('参数输入不对!','wrong argument!');        
        error('stopped!');
end
% 配置程序运行参数
ZR_CONFIG_G_Start();
% 从数据库里得到配置数据,策略参数hardcode
ZR_CONFIG_SetFromDB(varargin{:});
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