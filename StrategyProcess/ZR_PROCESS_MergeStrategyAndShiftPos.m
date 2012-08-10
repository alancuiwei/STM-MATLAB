function outputdata = ZR_PROCESS_MergeStrategyAndShiftPos(inputdata_strategy, inputdata_move)
%融合来自策略算法的输出和移仓操作的输出
% in_strategy=load('./l_output_strategy_new.mat');
% in_move=load('./l_output_move.mat');
% inputdata_strategy=in_strategy.l_output_strategy_new;
% inputdata_move=in_move.l_output_move;
%==========================================================================
% %需要的全局变量
global g_rawdata;
% l_temp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\MA60_l_inputdata.mat');
% g_rawdata=l_temp.l_inputdata;
%==========================================================================
%输出变量初始化操作
outputdata.orderlist.price=[];
outputdata.orderlist.direction=[];
outputdata.orderlist.name={};
outputdata.record.opdate={};
outputdata.record.opdateprice=[];
outputdata.record.cpdate={};
outputdata.record.cpdateprice=[];
outputdata.record.isclosepos=[];
outputdata.record.direction=[];
outputdata.record.ctname={};
%==========================================================================
if isempty(inputdata_strategy.record.opdate)
    return;
end
%==========================================================================
% %去除策略交易记录中连续做多或做空的记录
% l_direction=inputdata_strategy.record.direction(1);
% for i = 2:numel(inputdata_strategy.record.direction)
%     if l_direction==inputdata_strategy.record.direction(i)
%         inputdata_strategy.record.direction(i)=0;
%     else
%         l_direction=inputdata_strategy.record.direction(i);
%     end
% end
% l_tickout=find(inputdata_strategy.record.direction==0);
% if ~isempty(l_tickout)
%     inputdata_strategy.record.opdate(l_tickout)=[];
%     inputdata_strategy.record.opdateprice(l_tickout)=[];
%     inputdata_strategy.record.cpdate(l_tickout)=[];
%     inputdata_strategy.record.cpdateprice(l_tickout)=[];
%     inputdata_strategy.record.isclosepos(l_tickout)=[];
%     inputdata_strategy.record.direction(l_tickout)=[];
%     inputdata_strategy.record.ctname(l_tickout)=[];
% end
%==========================================================================
%去掉建仓之前所有的移仓记录
l_idxtemp=zeros(1,numel(inputdata_move.record.opdate));
for l_id = 1:numel(inputdata_move.record.opdate)
    if datenum(inputdata_move.record.opdate(l_id))<=datenum(inputdata_strategy.record.opdate(1))
        l_idxtemp(l_id)=1;
    end
end
if ~isequal(l_idxtemp,zeros(1,numel(inputdata_move.record.opdate)))
    l_idxtemp=logical(l_idxtemp);
    inputdata_move.record.opdate(l_idxtemp)=[];
    inputdata_move.record.opdateprice(l_idxtemp)=[];
    inputdata_move.record.cpdate(l_idxtemp)=[];
    inputdata_move.record.cpdateprice(l_idxtemp)=[];
    inputdata_move.record.isclosepos(l_idxtemp)=[];
    inputdata_move.record.direction(l_idxtemp)=[];
    inputdata_move.record.ctname(l_idxtemp)=[];
end
%==========================================================================
% 合并交易记录
% 1.去除没有仓位日期的移仓记录
l_strategy_opdatenum=datenum(inputdata_strategy.record.opdate,'yyyy-mm-dd');
l_strategy_cpdatenum=datenum(inputdata_strategy.record.cpdate,'yyyy-mm-dd');
l_reject=cell(1,numel(l_strategy_cpdatenum));
l_cnt=1;
for l_cpid = 1:numel(l_strategy_cpdatenum)-1  % 找出每一次平仓与下一次开仓之间的日期，这段时间内的移仓操作是不需要的
    if l_strategy_opdatenum(l_cpid+1)>l_strategy_cpdatenum(l_cpid)+1
        l_reject{1,l_cnt}=l_strategy_cpdatenum(l_cpid):l_strategy_opdatenum(l_cpid+1)-1; 
        l_cnt=l_cnt+1;
    end
end
if l_strategy_cpdatenum(end)<datenum(g_rawdata.commodity.serialmkdata.date(end),'yyyy-mm-dd')
    l_reject{1,l_cnt+1}=l_strategy_cpdatenum(end):datenum(g_rawdata.commodity.serialmkdata.date(end),'yyyy-mm-dd');
end
l_rejectday=cell2mat(l_reject);
l_rejectidx=ismember(datenum(inputdata_move.record.opdate,'yyyy-mm-dd'),l_rejectday);
inputdata_move.record.opdate(l_rejectidx)=[];
inputdata_move.record.opdateprice(l_rejectidx)=[];
inputdata_move.record.cpdate(l_rejectidx)=[];
inputdata_move.record.cpdateprice(l_rejectidx)=[];
inputdata_move.record.isclosepos(l_rejectidx)=[];
inputdata_move.record.direction(l_rejectidx)=[];
inputdata_move.record.ctname(l_rejectidx)=[];

% 2.填入orderlist
if ~isempty(inputdata_strategy.orderlist.name)
    outputdata.orderlist.price=inputdata_strategy.orderlist.price;
    outputdata.orderlist.direction=inputdata_strategy.orderlist.direction;
    outputdata.orderlist.name=inputdata_strategy.orderlist.name;
elseif ~isempty(inputdata_move.orderlist.name)
    if inputdata_strategy.record.isclosepos(end)==0
        outputdata.orderlist.price=inputdata_move.orderlist.price;
        outputdata.orderlist.direction=inputdata_strategy.record.direction(end); %移仓操作中orderlist的方向取决于之前策略算出的交易方向
        outputdata.orderlist.name=inputdata_move.orderlist.name;
    end
end

% 3. 去除移仓记录中开/平仓与策略算法中开/平仓相同的那一天的记录
l_sameopdateidx=ismember(inputdata_move.record.opdate,inputdata_strategy.record.opdate);
l_samecpdateidx=ismember(inputdata_move.record.cpdate,inputdata_strategy.record.cpdate);
l_delmoveidx=l_sameopdateidx | l_samecpdateidx;
inputdata_move.record.opdate(l_delmoveidx)=[];
inputdata_move.record.opdateprice(l_delmoveidx)=[];
inputdata_move.record.cpdate(l_delmoveidx)=[];
inputdata_move.record.cpdateprice(l_delmoveidx)=[];
inputdata_move.record.direction(l_delmoveidx)=[];
inputdata_move.record.isclosepos(l_delmoveidx)=[];
inputdata_move.record.ctname(l_delmoveidx)=[];

% 4.合并开仓日期、开仓价格、交易方向以及合约名称，并根据开仓日期的顺序进行排序
outputdata.record.opdate=sort([inputdata_strategy.record.opdate,inputdata_move.record.opdate]); 
for l_id = 1:numel(outputdata.record.opdate)
    if ismember(outputdata.record.opdate(l_id),inputdata_strategy.record.opdate)
        l_idx=find(ismember(inputdata_strategy.record.opdate,outputdata.record.opdate(l_id))==1);
        outputdata.record.opdateprice(l_id)=inputdata_strategy.record.opdateprice(l_idx);
%         outputdata.record.cpdate(i)=inputdata_strategy.record.cpdate(l_idx);
%         outputdata.record.cpdateprice(i)=inputdata_strategy.record.cpdateprice(l_idx);
%         outputdata.record.isclosepos(l_id)=inputdata_strategy.record.isclosepos(l_idx);
        outputdata.record.direction(l_id)=inputdata_strategy.record.direction(l_idx);
        outputdata.record.ctname(l_id)=inputdata_strategy.record.ctname(l_idx);
    elseif ismember(outputdata.record.opdate(l_id),inputdata_move.record.opdate)
        l_idx=find(ismember(inputdata_move.record.opdate,outputdata.record.opdate(l_id))==1);
        outputdata.record.opdateprice(l_id)=inputdata_move.record.opdateprice(l_idx);
%         outputdata.record.cpdate(l_id)=inputdata_move.record.cpdate(l_idx);
%         outputdata.record.cpdateprice(l_id)=inputdata_move.record.cpdateprice(l_idx);
%         outputdata.record.isclosepos(l_id)=inputdata_move.record.isclosepos(l_idx);
        outputdata.record.direction(l_id)=inputdata_move.record.direction(l_idx);
        outputdata.record.ctname(l_id)=inputdata_move.record.ctname(l_idx);
    end
end

% 5.修正交易方向
for l_id = 1:numel(outputdata.record.opdate)
    if (outputdata.record.direction(l_id)==0) % 移仓操作中，交易方向均初始化为0
        outputdata.record.direction(l_id)=outputdata.record.direction(l_id-1); % 将交易方向为0的，改为与前一次交易方向相同
    end
end

% 6.填入平仓日期和平仓价格
outputdata.record.cpdate=sort([inputdata_strategy.record.cpdate,inputdata_move.record.cpdate]);
for l_id = 1:numel(outputdata.record.cpdate)
    if ismember(outputdata.record.cpdate(l_id),inputdata_move.record.cpdate)
        l_idx=find(ismember(inputdata_move.record.cpdate,outputdata.record.cpdate(l_id)),1,'first');
        outputdata.record.cpdateprice(l_id)=inputdata_move.record.cpdateprice(l_idx);
    elseif ismember(outputdata.record.cpdate(l_id),inputdata_strategy.record.cpdate)
        l_idx=find(ismember(inputdata_strategy.record.cpdate,outputdata.record.cpdate(l_id)),1,'first');
        outputdata.record.cpdateprice(l_id)=inputdata_strategy.record.cpdateprice(l_idx);
    end
end
% if numel(outputdata.record.cpdate)<numel(outputdata.record.opdate) % 当今天有开仓，需补齐今天的平仓信息
%     outputdata.record.cpdate(end+1)=g_rawdata.commodity.serialmkdata.date(end);
%     outputdata.record.cpdateprice(end+1)=g_rawdata.commodity.serialmkdata.op(end);
% end
% if(numel(outputdata.record.opdate)>=2)
%     outputdata.record.cpdate=outputdata.record.opdate(2:end);
%     outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
%     outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
%     outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
%     outputdata.record.cpdate(numel(outputdata.record.opdateprice))=g_rawdata.commodity.serialmkdata.date(end); 
%     outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=g_rawdata.commodity.serialmkdata.op(end);
%     %{
%     if(g_rawdata.contract.info.daystolasttradedate<=0) 
%         outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%     end
%     %}
% elseif(numel(outputdata.record.opdate)>=1)
%     outputdata.record.cpdate=g_rawdata.commodity.serialmkdata.date(end);
%     outputdata.record.cpdateprice=g_rawdata.commodity.serialmkdata.op(end)+g_rawdata.commodity.serialmkdata.gap(end);
%     outputdata.record.isclosepos=0;
%     %{
%     if(g_rawdata.contract.info.daystolasttradedate<=0) 
%         outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%     end
%     %}
% end
%==========================================================================
% 修正开仓日期和平仓日期
% l_samecpdate=inputdata_strategy.record.cpdate(ismember(inputdata_strategy.record.cpdate,inputdata_move.record.cpdate));
% for l_scpid=1:numel(l_samecpdate)
%     l_tempopdate=l_samecpdate(l_scpid);
%     l_flag_strcpdate=ismember(l_tempopdate,inputdata_strategy.record.opdate);
%     l_flag_mocpdate=ismember(l_tempopdate,inputdata_move.record.opdate);
%     if ~l_flag_strcpdate && l_flag_mocpdate
%         l_opdateid=find(ismember(outputdata.record.opdate,l_tempopdate),1);
%         if ~isempty(l_opdateid)
%             outputdata.record.opdate(l_opdateid)=[];
%             outputdata.record.opdateprice(l_opdateid)=[];
%             outputdata.record.direction(l_opdateid)=[];
%             outputdata.record.ctname(l_opdateid)=[];
%         end
%     end
% end

% for l_cpid = 1:numel(inputdata_move.record.cpdate) % 如果由策略决定的平仓日期与移仓为同一天，则删除移仓记录
%     l_tempopdate=inputdata_move.record.cpdate(l_cpid); % 由于移仓操作时，开仓日期与平仓日期相同，故在此用平仓日期来查询
%     if ismember(l_tempopdate,outputdata.record.opdate)
%         l_flag_strcpdate=ismember(l_tempopdate,inputdata_strategy.record.opdate);
%         l_flag_mocpdate=ismember(l_tempopdate,inputdata_move.record.opdate);
%         if ~l_flag_strcpdate && l_flag_mocpdate
%             l_opdateid=find(ismember(outputdata.record.opdate,l_tempopdate),1);
%             if ~isempty(l_opdateid)
%                 outputdata.record.opdate(l_opdateid)=[];
%                 outputdata.record.opdateprice(l_opdateid)=[];
%             end
%         end
%     end
% end
%==========================================================================
% 7.修正交易记录中强制移仓的开仓价格
for l_id = 1:numel(outputdata.record.opdate)
    l_idx=find(ismember(inputdata_move.record.opdate,outputdata.record.opdate(l_id))==1);
    if ~isempty(l_idx)
        outputdata.record.cpdateprice(l_id-1)=inputdata_move.record.cpdateprice(l_idx);
    end
end
%==========================================================================
% 8.修正交易记录中是否实际平仓
outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdate));
if outputdata.record.cpdate{end}==g_rawdata.commodity.serialmkdata.date{end} % 如果到今天为止有未平仓的，则将平仓日期写为今天
    outputdata.record.isclosepos(end)=0;
end
