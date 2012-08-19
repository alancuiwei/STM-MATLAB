function [] = test()
load('DATABASE_History.mat');
len1 = length(g_database.commoditynames);
commoditypair = cell(len1,2);

for ii = 1 : len1
   str = g_database.commoditynames{ii};
   position = strfind(str, '-');
   commoditypair{ii,1} = str(1 : position-1);
   commoditypair{ii,2} = str(position+1 : end);
end

for ii = 1 : len1
    for month = [1,5,9]
    commodity1 = commoditypair{ii,1};
    commodity2 = commoditypair{ii,2};
    monthstr = strcat(num2str(0), num2str(month));
    data = g_database.pairnames(~cellfun('isempty',regexp(g_database.pairnames,strcat('^',commodity1,'\d{1,2}',monthstr,'-',commodity2,'\d{1,2}',monthstr,'$'))))
    Arbitrage(data);
    end
end
    
end