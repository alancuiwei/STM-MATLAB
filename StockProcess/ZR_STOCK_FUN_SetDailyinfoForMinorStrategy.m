function outputdata=ZR_STOCK_FUN_SetDailyinfoForMinorStrategy(inputdata, inputdata_strategy)
% 修改inputdata中dailyinfo信息，其为策略输出的dailyinfo结果
outputdata=inputdata;
outptdata.commodity.dailyinfo=inputdata_strategy.commodity.dailyinfo;
end
