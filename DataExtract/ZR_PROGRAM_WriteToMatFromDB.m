function ZR_PROGRAM_WriteToMatFromDB(varargin)
% 根据品种名称，将数据库中相应品种与合约信息写入mat文件
% 输入：品种名称
% 输出：品种对应的信息写入mat文件
%   输入参数        品种名称
%   varargin{1:7}  'TA' 'RO' 'a' 'l' 'p' 'v' 'y'
%  varargin{8}      --写入文件的路径，不写则默认保存在当前路径下
% varargin{1}='RO';
numinputs = nargin;
if numinputs < 0
    error('需指定品种名称');
end
currentpath = pwd;
global g_database;
g_database.currentdate={};
g_database.commoditynames={};
g_database.commodities={};
g_database.contractnames={};
g_database.contracts={};
g_database.pairnames={};
g_database.pairs={};
% 根据策略名获取策略信息
% strategyinfo=ZR_FUN_QueryArbitrageInfo_new(varargin{:});
% 行情数据更新日期
g_database.currentdate=ZR_FUN_QueryMarketdataCurrentdate();
% 获取品种名称
l_commoditynames={};
for id = 1:numinputs
    l_commoditynames = cat(2,l_commoditynames,varargin{id});
end
% g_database.commoditynames=unique(l_commoditynames);   unique执行后会重新排序？？？
g_database.commoditynames=l_commoditynames;
% 遍历所有的品种名，获得所有的品种数据信息
for l_cmid=1:length(g_database.commoditynames)
    g_database.commodities(l_cmid).info=ZR_FUN_QueryCommodityInfo(g_database.commoditynames{l_cmid});
    g_database.commodities(l_cmid).name=g_database.commoditynames(l_cmid);
    g_database.commodities(l_cmid).serialmkdata=ZR_FUN_QuerySerialMarketData(g_database.commoditynames{l_cmid});
end
disp('所有品种数据获取完毕！');

% 获取合约名称
allpairs=[];
for l_id=1:numel(g_database.commoditynames)
    l_rightid='1';      %策略名改为‘1’
    l_months=ZR_FUN_QueryMasterMonths(g_database.commoditynames(l_id));       %查询该品种主力合约
%     l_months=ZR_FUN_QueryDeliverMonths(g_database.commoditynames(l_id));    %查询逐月合约     
    l_contractnames=ZR_FUN_QueryContractnames(g_database.commoditynames(l_id),cell2mat(l_months));        %查询该品种所有合约名
    l_allpairs=struct('ctname1',[],'ctunit1',[],'ctname2',[],'ctunit2',[],'rightid',l_rightid);
    g_database.contractnames=cat(1,g_database.contractnames,l_contractnames(:));    %暂不适用跨品种
%     l_pairnames=cell((length(l_contractnames)-1),1);
    for l_ctid=1:(length(l_contractnames)-1)
%         l_pairnames{l_ctid}=strcat(l_contractnames{l_ctid},'-',l_contractnames{l_ctid+1});
        l_allpairs(l_ctid)=struct('ctname1',l_contractnames{l_ctid},'ctunit1',1,...
                            'ctname2',l_contractnames{l_ctid+1},'ctunit2',1,'rightid',l_rightid);
    end
%     g_DBconfig.g_pairnames=cat(1,g_DBconfig.g_pairnames,l_pairnames);
    allpairs=cat(2,allpairs,l_allpairs);
end

% 遍历所有的合约名，获得所有的合约数据信息
for l_ctid=1:length(g_database.contractnames)
    l_ctname=g_database.contractnames{l_ctid};
    g_database.contracts(l_ctid).name=g_database.contractnames(l_ctid);
    g_database.contracts(l_ctid).cmid=find(strcmp(l_commoditynames,l_ctname(regexp(l_ctname,'[a-z_A-Z]'))));
    g_database.contracts(l_ctid).info=ZR_FUN_QueryActiveContractInfo(l_ctname);
    g_database.contracts(l_ctid).mkdata=ZR_FUN_QueryContractData(l_ctname);
    g_database.contracts(l_ctid).datalen=g_database.contracts(l_ctid).mkdata.datalen;
end
disp('所有合约数据获取完毕！');

% 遍历所有的套利对，获得所有的套利对数据信息
for l_pairid=1:length(allpairs)
    l_ctname=allpairs(l_pairid).ctname1;
    allpairs(l_pairid).ctid1=find(strcmp(g_database.contractnames,l_ctname));
    l_ctname=allpairs(l_pairid).ctname2;
    allpairs(l_pairid).ctid2=find(strcmp(g_database.contractnames,l_ctname));
    l_pairnames{l_pairid}=strcat(allpairs(l_pairid).ctname1,'-',allpairs(l_pairid).ctname2);
    allpairs(l_pairid).name=l_pairnames(l_pairid);
    allpairs(l_pairid).mkdata=ZR_FUN_QueryPairData(allpairs(l_pairid).ctname1,allpairs(l_pairid).ctname2,...
        allpairs(l_pairid).ctunit1,allpairs(l_pairid).ctunit2);
%         l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
%             &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
    allpairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(allpairs(l_pairid).ctid1).info.daystolasttradedate...
           ,g_database.contracts(allpairs(l_pairid).ctid2).info.daystolasttradedate);
    allpairs(l_pairid).datalen=allpairs(l_pairid).mkdata.datalen;
end
g_database.pairnames=l_pairnames;
g_database.pairs=allpairs;
disp('所有品种数据获取完毕！');
disp('所有数据获取完毕！');
    
% 写入数据到mat文件
% time=datevec(datestr(now));
% time_month=num2str(time(2));
% time_day=num2str(time(3));
% if time(2)<10
%     time_month=strcat('0',num2str(time(2)));
% end
save(strcat(currentpath,'/','DATABASE_History.mat'),'g_database');
disp('数据库文件更新：');
disp(dir(strcat(currentpath,'/','DATABASE_History.mat')));

end