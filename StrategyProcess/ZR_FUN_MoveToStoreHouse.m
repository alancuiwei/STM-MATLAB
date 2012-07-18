function outputdata = ZR_FUN_MoveToStoreHouse(inputdata1, inputdata2, TradeDay)
% 执行移仓操作
% 输入：inputdata1----来自l_inputdata
%       inputdata2----来自策略ZR_STRATEGY_XXXXXX的output
%       TradeDay------来则策略ZR_STRATEGY_XXXXXX的TradeDay
% 输出：outputdata----记录每一笔开仓和平仓的信息
%
% l_temp=load('serial_a.mat');
% inputdata=l_temp.l_inputdata;
% [Output,TradeDay] = ZR_STRATEGY_040704_new(inputdata);
%==========================================================================
%输出变量初始化操作
% outputdata.orderlist.price=[];
% outputdata.orderlist.direction=[];
% outputdata.record.opdate={};
% outputdata.record.opdateprice=[];
% outputdata.record.cpdate={};
% outputdata.record.cpdateprice=[];
% outputdata.record.isclosepos=[];
% outputdata.record.direction=[];
% outputdata.record.ctname={};
outputdata = inputdata2;
%==========================================================================
%计算移仓点
CntName=char(inputdata1.commodity.serialmkdata.ctname);
DiffCntNme=CntName(2:end,:)-CntName(1:size(CntName,1)-1,:);
[PosChaDay,a]=find(DiffCntNme~=0);
PosChaDay=sort(PosChaDay);                                                                            
ForceTrade=unique(PosChaDay); %单个合约的最后一天
%合并交易日和移仓日
RealTradeDayBuff=[TradeDay,ForceTrade'];
RealTradeDayBuff=sort(RealTradeDayBuff);
RealTradeDay=unique(RealTradeDayBuff);
%==========================================================================
%第一步矫正record,修改强制平仓价格以及当天的开仓价格
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1)
        if(ForceTrade(i)+2>numel(inputdata1.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
            outputdata.orderlist.direction=1;
            outputdata.orderlist.price=0;
        else
            outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
            outputdata.record.opdateprice(PositionForceInTrade)=inputdata1.commodity.serialmkdata.op(ForceTrade(i)+2)+inputdata1.commodity.serialmkdata.gap(ForceTrade(i)+2);
            outputdata.record.opdate(PositionForceInTrade)=inputdata1.commodity.serialmkdata.date(ForceTrade(i)+2);
        end
%         if(ForceTrade(i)+2>numel(inputdata1.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
%                 outputdata.orderlist.direction=1;
%                 outputdata.orderlist.price=0;
%         else
%             outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
% %            outputdata.record.opdateprice(PositionForceInTrade)=inputdata1.commodity.serialmkdata.op(ForceTrade(i)+1)+inputdata1.commodity.serialmkdata.gap(ForceTrade(i)+1);
%             CntName=inputdata1.commodity.serialmkdata.ctname(ForceTrade(i)+1);
%             DateNum=inputdata1.commodity.serialmkdata.date(ForceTrade(i)+2);
%             CntID=find(ismember(inputdata1.contractname,CntName)==1);
%             DataID=find(ismember(inputdata1.contract(1,CntID).mkdata.date,DateNum)==1);
%             outputdata.record.opdateprice(PositionForceInTrade)=inputdata1.contract(1,CntID).mkdata.op(DataID);
%             outputdata.record.opdate(PositionForceInTrade)=inputdata1.commodity.serialmkdata.date(ForceTrade(i)+2);
%         end
%         outputdata.record.ctname(PositionForceInTrade)=inputdata1.commodity.serialmkdata.ctname(ForceTrade(i)+1);
    end
%     outputdata.record.ctname(PositionInTrade)=inputdata1.commodity.serialmkdata.ctname(ForceTrade(i)+1);
end
%==========================================================================
% %完善outputdata.record,填入平仓日期和平仓价格
if(numel(outputdata.record.opdate)>=2)
    outputdata.record.cpdate=outputdata.record.opdate(2:end);
    outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
    outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
    outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
    outputdata.record.cpdate(numel(outputdata.record.opdateprice))=inputdata1.commodity.serialmkdata.date(end); 
    outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=inputdata1.commodity.serialmkdata.op(end);
    %{
    if(inputdata1.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
elseif(numel(outputdata.record.opdate)>=1)
    outputdata.record.cpdate=inputdata1.commodity.serialmkdata.date(end);
    outputdata.record.cpdateprice=inputdata1.commodity.serialmkdata.op(end)+inputdata1.commodity.serialmkdata.gap(end);
    outputdata.record.isclosepos=0;
    %{
    if(inputdata1.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
end
%==========================================================================

%第二步矫正record,修改强制平仓价格以及当天的开仓价格
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1) 
        %修改于移仓操作相关的平仓价格，需要上一步的合约名(cntname)，以及移仓日期(ForceTrade+2)
        %合约名ID的生成来源于cntname以及合约的日期
        if(ForceTrade(i)+2>numel(inputdata1.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
        else
            CntName=inputdata1.commodity.serialmkdata.ctname(ForceTrade(i));
%             CntName
            DateNum=inputdata1.commodity.serialmkdata.date(ForceTrade(i)+2);
%             DateNum
            CntID=find(ismember(inputdata1.contractname,CntName)==1);
%             find(ismember(inputdata1.contract(1,CntID).mkdata.date,DateNum)==1)
            DataID=find(ismember(inputdata1.contract(1,CntID).mkdata.date,DateNum)==1);
            outputdata.record.cpdateprice(PositionForceInTrade-1)=inputdata1.contract(1,CntID).mkdata.op(DataID);
        end
        % 0503-lm
        %主力合约在交割月前仍未平仓，当天立即移仓 
        Dattmp = char(inputdata1.commodity.serialmkdata.date(ForceTrade(i)));
        LastDayFlag = judgeIsLastDay(Dattmp);
        if (LastDayFlag)%LastDayFlag 表示交割月前仍未平仓的标志
            %这段的处理------
            CntName=inputdata1.commodity.serialmkdata.ctname(ForceTrade(i));
%             CntName
            DateNum=inputdata1.commodity.serialmkdata.date(ForceTrade(i));
%             DateNum
            CntID=find(ismember(inputdata1.contractname,CntName)==1);
            DataID=find(ismember(inputdata1.contract(1,CntID).mkdata.date,DateNum)==1);
            outputdata.record.cpdateprice(PositionForceInTrade-1)=inputdata1.contract(1,CntID).mkdata.op(DataID);
        end
        % 0503-lm
    end
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