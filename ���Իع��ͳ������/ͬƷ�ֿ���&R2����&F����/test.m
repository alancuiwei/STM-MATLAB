function [] = test()
load('DATABASE_History.mat');
len1 = length(g_database.commoditynames);
commoditypair = cell(len1,2);

for ii = 1 : len1
   str = g_database.commoditynames{ii};
   commoditypair{ii,1} = str;
   commoditypair{ii,2} = str;
end

monthpairs = [1,5; 5,9; 9,1];

for ii = 1 : len1
    for jj = 1 : 3
    month1 = monthpairs(jj,1);
    month2 = monthpairs(jj,2);
    monthstr1 = strcat(num2str(0), num2str(month1));
    monthstr2 = strcat(num2str(0), num2str(month2));
    commodity1 = commoditypair{ii,1};
    commodity2 = commoditypair{ii,2};
    data = g_database.pairnames(~cellfun('isempty',regexp(g_database.pairnames,strcat('^',commodity1,'\d{1,2}',monthstr1,'-',commodity2,'\d{1,2}',monthstr2,'$'))))
    Arbitrage(data);
    end
end
    
end