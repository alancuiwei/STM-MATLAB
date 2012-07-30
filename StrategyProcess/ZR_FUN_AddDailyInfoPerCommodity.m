function inputdata=ZR_FUN_AddDailyInfoPerCommodity(inputdata)
% 为inputdata增加dailyinfo信息
% inputdata.commodity.dailyinfo.date——交易日期（连续的交易日）：cell向量（tradedaylen×1）
% inputdata.commodity.dailyinfo.trend——趋势方向，0无状态，1做空，2做多，4不做：cell向量（tradedaylen×1）
inputdata.commodity.dailyinfo.date=inputdata.commodity.serialmkdata.date;
inputdata.commodity.dailyinfo.trend=zeros(numel(inputdata.commodity.serialmkdata.date),1);
end