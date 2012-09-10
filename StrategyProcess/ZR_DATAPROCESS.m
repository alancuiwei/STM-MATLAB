function ZR_DATAPROCESS()
% 针对g_rawdata数据的预处理

% 声明全局变量
global G_RunSpecialTestCase;
global g_database;
global g_contractnames;
global g_commoditynames;
global g_pairnames;
global g_coredata;

if iscell(g_commoditynames)
    l_cmnum=length(g_commoditynames);
else
    l_cmnum=1;
end

if l_cmnum>1 
    for l_cmid=1:l_cmnum
        g_coredata(l_cmid).currentdate=g_database.currentdate;
        % 在g_database找到当前品种所在的位置，如果没有该品种，则跳过
        g_coredata(l_cmid).commodity.name=g_commoditynames(l_cmid);
        l_cmname=g_commoditynames{l_cmid};
        l_split=strfind(l_cmname,'-');
        if isempty(l_split)
            % 不包含‘-’说明是单边
            l_realcmid=strcmp(g_database.commoditynames,l_cmname);
            g_coredata(l_cmid).commodity.info=g_database.commodities(l_realcmid).info;
%             g_coredata(l_cmid).commodity.serialmkdata=g_database.commodities(l_realcmid).serialmkdata;
            % 根据选择的合约，筛选
            l_realctid=strncmp(g_database.contractnames,g_commoditynames{l_cmid},length(g_commoditynames{l_cmid}));
            if isempty(find(l_realctid, 1))
                l_ctid=0;     
            else
                l_ctid=1;
                l_ctnum=1;
                l_contract=g_database.contracts(l_realctid);
                l_contractname=g_database.contractnames(l_realctid);
                while l_ctnum<=length(g_database.contracts(l_realctid))
                    if isempty(find(strcmp(g_contractnames,l_contractname(l_ctnum)),1))
                        l_contract(l_ctid)=[];
                        l_contractname(l_ctid)=[];
                    else
                        l_ctid=l_ctid+1;
                    end
                    l_ctnum=l_ctnum+1;
                end
            end
            % 根据限制的时间，筛选
            if (strcmp(G_RunSpecialTestCase.coredata.startdate,'nolimit')...
                &&strcmp(G_RunSpecialTestCase.coredata.enddate,'nolimit'))
                % 没有限制
                g_coredata(l_cmid).commodity.serialmkdata=g_database.commodities(l_realcmid).serialmkdata;
            else
                l_startdatenum=0;
                l_enddatenum=inf;
                if ~strcmp(G_RunSpecialTestCase.coredata.enddate,'nolimit')
                    % 结束日期有限制
                    % 日期数字
                    l_enddatenum=datenum(G_RunSpecialTestCase.coredata.enddate,'yyyy-mm-dd');            
                end
                if ~strcmp(G_RunSpecialTestCase.coredata.startdate,'nolimit')
                    % 开始日期有限制
                    % 日期数字
                    l_startdatenum=datenum(G_RunSpecialTestCase.coredata.startdate,'yyyy-mm-dd');            
                end
                % 计算合约的起始id
                l_startid=find(datenum(g_database.commodities(l_realcmid).serialmkdata.date)>=l_startdatenum,1,'first');
                l_endid=find(datenum(g_database.commodities(l_realcmid).serialmkdata.date)<=l_enddatenum,1,'last');
                if isempty(l_startid)||isempty(l_endid)
                    continue;   
                end
                % 连续合约数据
                g_coredata(l_cmid).commodity.serialmkdata.date=g_database.commodities(l_realcmid).serialmkdata.date(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.op=g_database.commodities(l_realcmid).serialmkdata.op(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.hp=g_database.commodities(l_realcmid).serialmkdata.hp(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.lp=g_database.commodities(l_realcmid).serialmkdata.lp(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.cp=g_database.commodities(l_realcmid).serialmkdata.cp(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.vl=g_database.commodities(l_realcmid).serialmkdata.vl(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.oi=g_database.commodities(l_realcmid).serialmkdata.oi(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.gap=g_database.commodities(l_realcmid).serialmkdata.gap(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.ctname=g_database.commodities(l_realcmid).serialmkdata.ctname(l_startid:l_endid);
                g_coredata(l_cmid).commodity.serialmkdata.datalen=l_endid-l_startid+1;    
                g_coredata(l_cmid).currentdate=g_coredata(l_cmid).commodity.serialmkdata.date(end);
            end
  
            % 导入合约和套利对的数据
            if l_ctid
                g_coredata(l_cmid).contract=l_contract;
                g_coredata(l_cmid).contractname=l_contractname;
            end        
        else % 包含‘-’说明是套利对
            l_realcmid=strcmp(g_database.commoditynames,l_cmname(1:(l_split-1)));
            g_coredata(l_cmid).commodity.info(1)=g_database.commodities(l_realcmid).info;
            l_realcmid=strcmp(g_database.commoditynames,l_cmname((l_split+1):end));
            g_coredata(l_cmid).commodity.info(2)=g_database.commodities(l_realcmid).info; 
            % 根据选择的套利对，筛选
            l_matchstr=strcat('^',l_cmname(1:(l_split-1)),'\d{3,4}-',l_cmname((l_split+1):end),'\d{3,4}$');
            l_realpairid=~cellfun('isempty',regexp(g_database.pairnames,l_matchstr));   
            if isempty(find(l_realpairid, 1))
                l_pairid=0;     
            else    
                l_pairid=1;
                l_pairnum=1;
                l_pair=g_database.pairs(l_realpairid);
                l_pairindex=find(l_realpairid);
                while l_pairnum<=length(g_database.pairs(l_realpairid))
                    if isempty(find(strcmp(g_pairnames,g_database.pairnames(l_pairindex(l_pairnum))),1))
                        l_pair(l_pairid)=[];
                    else
                        l_pairid=l_pairid+1;
                    end
                    l_pairnum=l_pairnum+1;
                end  
            end
            % 导入合约和套利对的数据
            if l_pairid
                g_coredata(l_cmid).pair=l_pair;
            end 
        end
        ZR_FUN_Disp(sprintf('%s已经导入g_coredata!',cell2mat(g_coredata(l_cmid).commodity.name)),sprintf('%s import g_coredata!',cell2mat(g_coredata(l_cmid).commodity.name)));
    end
else
    g_coredata.currentdate=g_database.currentdate;
    % 在g_database找到当前品种所在的位置，如果没有该品种，则跳过
    g_coredata.commodity.name=g_commoditynames;
    l_cmname=g_commoditynames{1};
    l_split=strfind(l_cmname,'-');
    if isempty(l_split)
        % 不包含‘-’说明是单边
        l_realcmid=strcmp(g_database.commoditynames,l_cmname);
        g_coredata.commodity.info=g_database.commodities(l_realcmid).info;
        g_coredata.commodity.serialmkdata=g_database.commodities(l_realcmid).serialmkdata;
        % 根据选择的合约，筛选
        l_realctid=strncmp(g_database.contractnames,g_commoditynames,length(g_commoditynames));
        if isempty(find(l_realctid, 1))
            l_ctid=0;     
        else
            l_ctid=1;
            l_ctnum=1;
            l_contract=g_database.contracts(l_realctid);
            l_contractname=g_database.contractnames(l_realctid);
            while l_ctnum<=length(g_database.contracts(l_realctid))
                if isempty(find(strcmp(g_contractnames,l_contractname(l_ctnum)),1))
                    l_contract(l_ctid)=[];
                    l_contractname(l_ctid)=[];
                else
                    l_ctid=l_ctid+1;
                end
                l_ctnum=l_ctnum+1;
            end
        end
        % 导入合约和套利对的数据
        % 根据限制的时间，筛选
        if (strcmp(G_RunSpecialTestCase.coredata.startdate,'nolimit')...
            &&strcmp(G_RunSpecialTestCase.coredata.enddate,'nolimit'))
            % 没有限制
            g_coredata.commodity.serialmkdata=g_database.commodities(l_realcmid).serialmkdata;
        else
            l_startdatenum=0;
            l_enddatenum=inf;
            if ~strcmp(G_RunSpecialTestCase.coredata.enddate,'nolimit')
                % 结束日期有限制
                % 日期数字
                l_enddatenum=datenum(G_RunSpecialTestCase.coredata.enddate,'yyyy-mm-dd');            
            end
            if ~strcmp(G_RunSpecialTestCase.coredata.startdate,'nolimit')
                % 开始日期有限制
                % 日期数字
                l_startdatenum=datenum(G_RunSpecialTestCase.coredata.startdate,'yyyy-mm-dd');            
            end
            % 计算合约的起始id
            l_startid=find(datenum(g_database.commodities(l_realcmid).serialmkdata.date)>=l_startdatenum,1,'first');
            l_endid=find(datenum(g_database.commodities(l_realcmid).serialmkdata.date)<=l_enddatenum,1,'last');
            if ~isempty(l_startid)&&~isempty(l_endid)
                % 连续合约数据
                g_coredata.commodity.serialmkdata.date=g_database.commodities(l_realcmid).serialmkdata.date(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.op=g_database.commodities(l_realcmid).serialmkdata.op(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.hp=g_database.commodities(l_realcmid).serialmkdata.hp(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.lp=g_database.commodities(l_realcmid).serialmkdata.lp(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.cp=g_database.commodities(l_realcmid).serialmkdata.cp(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.vl=g_database.commodities(l_realcmid).serialmkdata.vl(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.oi=g_database.commodities(l_realcmid).serialmkdata.oi(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.gap=g_database.commodities(l_realcmid).serialmkdata.gap(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.ctname=g_database.commodities(l_realcmid).serialmkdata.ctname(l_startid:l_endid);
                g_coredata.commodity.serialmkdata.datalen=l_endid-l_startid+1;    
                g_coredata.currentdate=g_coredata.commodity.serialmkdata.date(end);
            end
        end        
        if l_ctid
            g_coredata.contract=l_contract;
            g_coredata.contractname=l_contractname;
        end        
    else % 包含‘-’说明是套利对
        l_realcmid=strcmp(g_database.commoditynames,l_cmname(1:(l_split-1)));
        g_coredata.commodity.info(1)=g_database.commodities(l_realcmid).info;
        l_realcmid=strcmp(g_database.commoditynames,l_cmname((l_split+1):end));
        g_coredata.commodity.info(2)=g_database.commodities(l_realcmid).info; 
        % 根据选择的套利对，筛选
        l_matchstr=strcat('^',l_cmname(1:(l_split-1)),'\d{3,4}-',l_cmname((l_split+1):end),'\d{3,4}$');
        l_realpairid=~cellfun('isempty',regexp(g_database.pairnames,l_matchstr));   
        if isempty(find(l_realpairid, 1))
            l_pairid=0;     
        else    
            l_pairid=1;
            l_pairnum=1;
            l_pair=g_database.pairs(l_realpairid);
            l_pairindex=find(l_realpairid);
            while l_pairnum<=length(g_database.pairs(l_realpairid))
                if isempty(find(strcmp(g_pairnames,g_database.pairnames(l_pairindex(l_pairnum))),1))
                    l_pair(l_pairid)=[];
                else
                    l_pairid=l_pairid+1;
                end
                l_pairnum=l_pairnum+1;
            end  
        end
        % 导入合约和套利对的数据
        if l_pairid
            g_coredata.pair=l_pair;
        end 
    end
    ZR_FUN_Disp(sprintf('%s已经导入g_coredata!',cell2mat(g_coredata.commodity.name)),sprintf('%s import g_coredata!',cell2mat(g_coredata.commodity.name)));
    
end
end