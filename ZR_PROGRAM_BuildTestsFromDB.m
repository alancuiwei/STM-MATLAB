function ZR_PROGRAM_BuildTestsFromDB(varargin)
% 根据数据库中数据表的配置信息执行所有的策略
clc;
clear all;
disp('获取数据库策略配置信息');
l_strategydata=ZR_FUN_QueryWebstrategyConfigByDB();
for l_id=1:length(l_strategydata.strategyid)
    disp(strcat('strategyid:',l_strategydata.strategyid{l_id},' userid:',num2str(l_strategydata.userid{l_id}),' ordernum:',num2str(l_strategydata.ordernum{l_id})));
    ZR_PROGRAM_BuiltTestResult('database',l_strategydata.strategyid{l_id},num2str(l_strategydata.userid{l_id}),num2str(l_strategydata.ordernum{l_id}));
end
disp('策略执行完毕');
end