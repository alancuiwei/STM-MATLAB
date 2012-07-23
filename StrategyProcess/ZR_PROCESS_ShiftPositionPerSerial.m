function outputdata = ZR_PROCESS_ShiftPositionPerSerial(varargin)
% 对单个连续合约进行移仓操作
% 输出参数：
%           outputdata——加入移仓操作以后，更正的交易记录
%
% l_temp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\MA60_l_inputdata.mat');
% inputdata=l_temp.l_inputdata;
%==========================================================================
%用到的全局变量
global g_rawdata;
%HardCode
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
%计算移仓点
l_ctname=char(g_rawdata.commodity.serialmkdata.ctname);
l_diffctname=l_ctname(2:end,:)-l_ctname(1:size(l_ctname,1)-1,:);
[l_posday,a]=find(l_diffctname~=0);
l_posday=sort(l_posday);                                                                            
l_forceday=unique(l_posday); %单个合约的最后一天
%==========================================================================
%填入开仓日期、开仓价格、平仓价格以及主力合约名
for i=1:numel(l_forceday)
    if(l_forceday(i)+2>numel(g_rawdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
            outputdata.orderlist.direction=1;
            outputdata.orderlist.price=0;
            outputdata.orderlist.name=g_rawdata.commodity.serialmkdata.ctname(l_forceday(i)+1);
    else
            l_contractname=g_rawdata.commodity.serialmkdata.ctname(l_forceday(i)+1);
            l_datenum=g_rawdata.commodity.serialmkdata.date(l_forceday(i)+2);
            l_contractid=find(ismember(g_rawdata.contractname,l_contractname)==1);
            l_dateid=find(ismember(g_rawdata.contract(1,l_contractid).mkdata.date,l_datenum)==1);
            outputdata.record.opdateprice(i)=g_rawdata.contract(1,l_contractid).mkdata.op(l_dateid);
            outputdata.record.opdate(i)=g_rawdata.commodity.serialmkdata.date(l_forceday(i)+2);
            
            l_datetmp = char(g_rawdata.commodity.serialmkdata.date(l_forceday(i)));
            l_islastday = judgeIsLastDay(l_datetmp);
            if (l_islastday)%l_islastday 表示交割月前仍未平仓的标志
                %这段的处理------
                l_contractname=g_rawdata.commodity.serialmkdata.ctname(l_forceday(i));
                l_datenum=g_rawdata.commodity.serialmkdata.date(l_forceday(i));
                l_contractid=find(ismember(g_rawdata.contractname,l_contractname)==1);
                l_dateid=find(ismember(g_rawdata.contract(1,l_contractid).mkdata.date,l_datenum)==1);
                outputdata.record.cpdateprice(i)=g_rawdata.contract(1,l_contractid).mkdata.op(l_dateid);
            else
                l_contractname=g_rawdata.commodity.serialmkdata.ctname(l_forceday(i));
                l_datenum=g_rawdata.commodity.serialmkdata.date(l_forceday(i)+2);
                l_contractid=find(ismember(g_rawdata.contractname,l_contractname)==1);
                l_dateid=find(ismember(g_rawdata.contract(1,l_contractid).mkdata.date,l_datenum)==1);
                outputdata.record.cpdateprice(i)=g_rawdata.contract(1,l_contractid).mkdata.op(l_dateid);
            end
    end
    outputdata.record.ctname(i)=g_rawdata.commodity.serialmkdata.ctname(l_forceday(i)+1);
end

%==========================================================================
%填入交易方向
%由于移仓操作的交易方向取决于之前策略算出的交易方向，这里先初始化为0
outputdata.record.direction=zeros(1,numel(outputdata.record.opdate));
%==========================================================================
%填入平仓日期和平仓价格
if(numel(outputdata.record.opdate)>=2)
    outputdata.record.cpdate=outputdata.record.opdate(2:end);
    outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
    outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
    outputdata.record.cpdate(numel(outputdata.record.opdateprice))=g_rawdata.commodity.serialmkdata.date(end); 
%     outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=g_rawdata.commodity.serialmkdata.op(end);
    %{
    if(g_rawdata.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
elseif(numel(outputdata.record.opdate)>=1)
    outputdata.record.cpdate=g_rawdata.commodity.serialmkdata.date(end);
%     outputdata.record.cpdateprice=g_rawdata.commodity.serialmkdata.op(end)+g_rawdata.commodity.serialmkdata.gap(end);
    outputdata.record.isclosepos=0;
    %{
    if(g_rawdata.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
end
%==========================================================================

% 判断日期是不是最后一天
function lastDay = judgeIsLastDay(date)
Day = str2double(date(end-1:end));
Month = str2double(date(end-4:end-3));
Year = str2double(date(1:4));
if(mod(Year,100) ~= 0)
    if (mod(Year,4) == 0)
        Leap = 1;
    else
        Leap = 0;
    end
else
    if(mod(Year,400) == 0)
        Leap = 1;
    else
        Leap = 0;
    end
end

switch(Month)
    case {1,3,5,7,8,10,12}
        if(Day == 31)
            lastDay = 1;
        else
            lastDay = 0;
        end
    case {4,6,9,11}
        if(Day == 30)
            lastDay = 1;
        else
            lastDay = 0;
        end
    case 2
        if(Leap)
            if(Day == 29)
                lastDay = 1;
            else
                lastDay = 0;
            end
        else
            if(Day == 28)
                lastDay = 1;
            else
                lastDay = 0;
            end
        end
    otherwise
        lastDay = 0;
end