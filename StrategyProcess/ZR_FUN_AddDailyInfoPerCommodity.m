function inputdata=ZR_FUN_AddDailyInfoPerCommodity(inputdata)
% Ϊinputdata����dailyinfo��Ϣ
% inputdata.commodity.dailyinfo.date�����������ڣ������Ľ����գ���cell������tradedaylen��1��
% inputdata.commodity.dailyinfo.trend�������Ʒ���0��״̬��1���գ�2���࣬4������cell������tradedaylen��1��
inputdata.commodity.dailyinfo.date=inputdata.commodity.serialmkdata.date;
inputdata.commodity.dailyinfo.trend=zeros(numel(inputdata.commodity.serialmkdata.date),1);
end