function outputdata = ZR_PROCESS_MergeStrategyAndShiftPos(inputdata_strategy, inputdata_move)
%融合来自策略算法的输出和移仓操作的输出
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
%去除策略交易记录中连续做多或做空的记录
l_direction=inputdata_strategy.record.direction(1);
for i = 2:numel(inputdata_strategy.record.direction)
    if l_direction==inputdata_strategy.record.direction(i)
        inputdata_strategy.record.direction(i)=0;
    else
        l_direction=inputdata_strategy.record.direction(i);
    end
end
l_tickout=find(inputdata_strategy.record.direction==0);
if ~isempty(l_tickout)
    inputdata_strategy.record.opdate(l_tickout)=[];
    inputdata_strategy.record.opdateprice(l_tickout)=[];
    inputdata_strategy.record.cpdate(l_tickout)=[];
    inputdata_strategy.record.cpdateprice(l_tickout)=[];
    inputdata_strategy.record.isclosepos(l_tickout)=[];
    inputdata_strategy.record.direction(l_tickout)=[];
    inputdata_strategy.record.ctname(l_tickout)=[];
%     inputdata_strategy.record.opdate=sort(inputdata_strategy.record.opdate);
%     inputdata_strategy.record.opdateprice=sort(inputdata_strategy.record.opdateprice);
%     inputdata_strategy.record.cpdate=sort(inputdata_strategy.record.cpdate);
%     inputdata_strategy.record.cpdateprice=sort(inputdata_strategy.record.cpdateprice);
%     inputdata_strategy.record.isclosepos=sort(inputdata_strategy.record.isclosepos);
%     inputdata_strategy.record.direction=sort(inputdata_strategy.record.direction);
%     inputdata_strategy.record.ctname=sort(inputdata_strategy.record.ctname);
end
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
%合并交易记录
outputdata.orderlist.price=inputdata_strategy.orderlist.price;
outputdata.orderlist.direction=inputdata_strategy.orderlist.direction;
outputdata.orderlist.name=inputdata_strategy.orderlist.name;
%合并开仓日期，并根据开仓日期的顺序进行排序
outputdata.record.opdate=unique([inputdata_strategy.record.opdate,inputdata_move.record.opdate]); 
for l_id = 1:numel(outputdata.record.opdate)
    if ismember(outputdata.record.opdate(l_id),inputdata_move.record.opdate)
        l_idx=find(ismember(inputdata_move.record.opdate,outputdata.record.opdate(l_id))==1);
        outputdata.record.opdateprice(l_id)=inputdata_move.record.opdateprice(l_idx);
%         outputdata.record.cpdate(l_id)=inputdata_move.record.cpdate(l_idx);
%         outputdata.record.cpdateprice(l_id)=inputdata_move.record.cpdateprice(l_idx);
        outputdata.record.isclosepos(l_id)=inputdata_move.record.isclosepos(l_idx);
        outputdata.record.direction(l_id)=inputdata_move.record.direction(l_idx);
        outputdata.record.ctname(l_id)=inputdata_move.record.ctname(l_idx);
        
    elseif ismember(outputdata.record.opdate(l_id),inputdata_strategy.record.opdate)
        l_idx=find(ismember(inputdata_strategy.record.opdate,outputdata.record.opdate(l_id))==1);
        outputdata.record.opdateprice(l_id)=inputdata_strategy.record.opdateprice(l_idx);
%         outputdata.record.cpdate(i)=inputdata_strategy.record.cpdate(l_idx);
%         outputdata.record.cpdateprice(i)=inputdata_strategy.record.cpdateprice(l_idx);
        outputdata.record.isclosepos(l_id)=inputdata_strategy.record.isclosepos(l_idx);
        outputdata.record.direction(l_id)=inputdata_strategy.record.direction(l_idx);
        outputdata.record.ctname(l_id)=inputdata_strategy.record.ctname(l_idx);
    end
end
%填入交易方向
for l_id = 1:numel(outputdata.record.opdate)
    if (outputdata.record.direction(l_id)==0)
        outputdata.record.direction(l_id)=outputdata.record.direction(l_id-1);
    end
end
%填入平仓日期和平仓价格
if(numel(outputdata.record.opdate)>=2)
    outputdata.record.cpdate=outputdata.record.opdate(2:end);
    outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
    outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
    outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
    outputdata.record.cpdate(numel(outputdata.record.opdateprice))=g_rawdata.commodity.serialmkdata.date(end); 
    outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=g_rawdata.commodity.serialmkdata.op(end);
    %{
    if(g_rawdata.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
elseif(numel(outputdata.record.opdate)>=1)
    outputdata.record.cpdate=g_rawdata.commodity.serialmkdata.date(end);
    outputdata.record.cpdateprice=g_rawdata.commodity.serialmkdata.op(end)+g_rawdata.commodity.serialmkdata.gap(end);
    outputdata.record.isclosepos=0;
    %{
    if(g_rawdata.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
end
%==========================================================================
%修正交易记录中强制移仓的开仓价格
for l_id = 1:numel(outputdata.record.opdate)
    l_idx=find(ismember(inputdata_move.record.opdate,outputdata.record.opdate(l_id))==1);
    if ~isempty(l_idx)
        outputdata.record.cpdateprice(l_id-1)=inputdata_move.record.cpdateprice(l_idx);
    end
end
%==========================================================================
%修正交易记录中orderlist对应的合约名
if ~isempty(outputdata.orderlist)
    outputdata.record.ctname(end+1)=inputdata_strategy.record.ctname(end);
end