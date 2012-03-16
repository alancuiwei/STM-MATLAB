function ZR_PROGRAM_BuiltTestResult(varargin)
% 独立的程序生成测试报告
ZR_CONFIG_File(varargin{:});
% 从数据库中导出数据
ZR_ExtractHistoryDataFromMySQL();
% 特定参数输入的运行模式
ZR_RunSpecialTestCase();
end