function ZR_PROGRAM_WriteToMatFromDB2(varargin)
% 根据套利对品种名称，将数据库中相应品种与合约信息写入mat文件
% 输入：套利对品种名称
% 输出：品种对应的信息写入mat文件
% 特别为跨品种的数据集。 
% ZR_PROGRAM_WriteToMatFromDB2 'pair' 'a-m'
numinputs = nargin;
currentpath = pwd;
global g_database;
g_database.currentdate={};
g_database.commoditynames={};
g_database.commodities=[];
g_database.contractnames={};
g_database.contracts=[];
g_database.pairnames={};
g_database.pairs=[];
if numinputs < 0
    error('需指定品种名称');
end

switch varargin{1}
    case 'pair'
        % 行情数据更新日期
        g_database.currentdate=ZR_FUN_QueryMarketdataCurrentdate();
        % 获取品种名称
        l_commoditynames={};
        for id = 2:numinputs
            l_commoditynames = cat(2,l_commoditynames,varargin{id});
        end   
        g_database.commoditynames=l_commoditynames;
        for l_cmid=1:length(g_database.commoditynames)
            l_allpairs=[];
            l_pairnames=[];
            l_rightid='1';      %策略名改为‘1’
            l_split=strfind(g_database.commoditynames{l_cmid},'-');
            l_cmnames1=g_database.commoditynames{l_cmid}(1:(l_split-1));
            l_cmnames2=g_database.commoditynames{l_cmid}((l_split+1):end);
            l_months1=ZR_FUN_QueryMasterMonths(l_cmnames1);       %查询该品种主力合约  
            l_months2=ZR_FUN_QueryMasterMonths(l_cmnames2);       %查询该品种主力合约
            l_ctnames1=ZR_FUN_QueryContractnames(l_cmnames1,cell2mat(l_months1));        %查询该品种所有合约名
            l_ctnames2=ZR_FUN_QueryContractnames(l_cmnames2,cell2mat(l_months2));        %查询该品种所有合约名
            g_database.contractnames=cat(2,g_database.contractnames,l_ctnames1,l_ctnames2); 
            for l_id=1:length(l_ctnames1)
                l_tempname1=l_ctnames1(l_id);
                l_tempname2=l_ctnames2(find(strcmp(l_ctnames2,strrep(l_tempname1,l_cmnames1,l_cmnames2)),1));
                if ~isempty(l_tempname2)
                    l_pairs=struct('ctname1',l_tempname1,'ctunit1',1,...
                            'ctname2',l_tempname2,'ctunit2',1,'rightid',l_rightid);
                    l_allpairs=cat(2,l_allpairs,l_pairs);
                end
            end
            % 遍历所有的套利对，获得所有的套利对数据信息
            for l_pairid=1:length(l_allpairs)
                l_ctname=l_allpairs(l_pairid).ctname1;
                l_allpairs(l_pairid).ctid1=find(strcmp(g_database.contractnames{l_cmid},l_ctname));
                l_ctname=l_allpairs(l_pairid).ctname2;
                l_allpairs(l_pairid).ctid2=find(strcmp(g_database.contractnames{l_cmid},l_ctname));
                l_pairnames{l_pairid}=strcat(l_allpairs(l_pairid).ctname1,'-',l_allpairs(l_pairid).ctname2);
                l_allpairs(l_pairid).name=l_pairnames(l_pairid);
                l_allpairs(l_pairid).mkdata=ZR_FUN_QueryPairData(l_allpairs(l_pairid).ctname1,l_allpairs(l_pairid).ctname2,...
                    l_allpairs(l_pairid).ctunit1,l_allpairs(l_pairid).ctunit2);
            %         l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
            %             &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
%                 l_allpairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(l_allpairs(l_pairid).ctid1).info.daystolasttradedate...
%                        ,g_database.contracts(l_allpairs(l_pairid).ctid2).info.daystolasttradedate);
                l_allpairs(l_pairid).datalen=l_allpairs(l_pairid).mkdata.datalen;
            end   
            g_database.pairnames=cat(2,g_database.pairnames,l_pairnames);
            g_database.pairs=cat(2,g_database.pairs,l_allpairs);            
        end
        disp('所有品种数据获取完毕！');
        disp('所有数据获取完毕！');           
            
end

save(strcat(currentpath,'/','DATABASE_History.mat'),'g_database');
disp('数据库文件更新：');
disp(dir(strcat(currentpath,'/','DATABASE_History.mat')));

end