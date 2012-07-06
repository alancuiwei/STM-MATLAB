function ZR_FUN_StartDataQuery(varargin)
clear global;
% 生成配置文件
ZR_CONFIG_DataQuery_File(varargin{:});
% 从数据库中导出数据
ZR_ExtractHistoryDataFromMySQL();
end