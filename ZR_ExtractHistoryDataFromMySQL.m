function ZR_ExtractHistoryDataFromMySQL()
% 从MySQL数据库中一次获取策略所需要的所有数据
% 将数据库的数据保存到g_database里
% 最终将g_database该数据保存为*.mat数据库文件
% 如果已经生成了数据库文件，导入之前的数据库文件


% 需要使用的全局变量
global G_ExtractHistoryDataFromMySQL;
global G_Start;
global g_database;
global g_method;

% 方法
g_method=G_ExtractHistoryDataFromMySQL.g_method;

% 检查是否已经有相应的*.data数据库文件生成，如果有就导入
if exist(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename),'file')
    % 导入数据库数据
    load(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename));    
else
    g_database=[];
end

% 执行从数据库提取数据的方法
g_method.runextractdatabase(); 

if G_ExtractHistoryDataFromMySQL.isupdated
    G_ExtractHistoryDataFromMySQL.isupdated=0;
    if exist(strcat(G_Start.currentpath,'/','g_coredata_specialtestcase.mat'),'file')
        delete(strcat(G_Start.currentpath,'/','g_coredata_specialtestcase.mat'));
    end
    save(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename),'g_database');
    disp('数据库文件更新：');
    disp(dir(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename)));     
else 
    disp('数据库文件没有更新：'); 
end

end