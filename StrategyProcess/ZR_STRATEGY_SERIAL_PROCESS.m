function outputdata = ZR_STRATEGY_SERIAL_PROCESS(strategyid1,strategyid2,inputdata)
% 根据策略id号，对输入的数据进行处理
% 输入参数：
%           strategyid1——方向策略，用来决定何时做多或做空
%           strategyid2——执行策略，用来确定具体做多或做空的日期
%           inputdata——历史数据
% 输出参数：
%           outputdata——交易记录
%
% 此函数不包括移仓操作

% strategyid1='040704';
% strategyid2='040704';
temp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\MA60_MACD.mat');
inputdata=temp.l_inputdata;
%==========================================================================
%输出变量初始化操作
outputdata.orderlist.price=[];
outputdata.orderlist.direction=[];
outputdata.record.opdate={};
outputdata.record.opdateprice=[];
outputdata.record.cpdate={};
outputdata.record.cpdateprice=[];
outputdata.record.isclosepos=[];
outputdata.record.direction=[];
outputdata.record.ctname={};
%==========================================================================
% 方向策略
eval(strcat('PositionDay=ZR_STRATEGY_serial_',strategyid1,'(inputdata);'));
PositionDay_a=PositionDay{1,:};
PositionDay_b=PositionDay{2,:};
%==========================================================================
% 执行策略
eval(strcat('TradeDay=ZR_STRATEGY_serial_',strategyid2,'(inputdata);'));
TradeDay_a=TradeDay{1,:};
TradeDay_b=TradeDay{2,:};
%==========================================================================
%由方向策略和执行策略确定真正交易日期
if isempty(PositionDay_a) && isempty(PositionDay_b)
    sprintf('方向策略：没有交易发生');
    return;
end
RealTrade_a=[];
RealTrade_b=[];
Cnt=1;
for i = 1:numel(PositionDay_a)
    Trade_ID=find(TradeDay_a>PositionDay_a(i));
    if ~isempty(Trade_ID)
        Pos_ID=find(PositionDay_b>PositionDay_a(i));
        if ~isempty(Pos_ID) && PositionDay_b(Pos_ID(1))<TradeDay_a(Trade_ID(1))
            continue;
        else
            RealTrade_a(Cnt)=TradeDay_a(Trade_ID(1));
            Cnt=Cnt+1;
        end
    end
end
Cnt=1;
for i = 1:numel(PositionDay_b)
    Trade_ID=find(TradeDay_b>PositionDay_b(i));
    if ~isempty(Trade_ID)
        Pos_ID=find(PositionDay_a>PositionDay_b(i));
        if ~isempty(Pos_ID) && PositionDay_a(Pos_ID(1))<TradeDay_b(Trade_ID(1))
            continue;
        else
            RealTrade_b(Cnt)=TradeDay_b(Trade_ID(1));
            Cnt=Cnt+1;
        end
    end
end
if ~isempty(RealTrade_a)
    RealTrade_a=unique(RealTrade_a);
end
if ~isempty(RealTrade_b)
    RealTrade_b=unique(RealTrade_b);
end
RealTradeDay=sort([RealTrade_a,RealTrade_b]);
%剔除连续做多或做空的交易日
Flag=zeros(1,numel(RealTradeDay));
for i = 1:numel(RealTradeDay)
    if ismember(RealTradeDay(i),RealTrade_a)
        Trade_flag(i)=1;
    elseif ismember(RealTradeDay(i),RealTrade_b)                    
        Trade_flag(i)=-1;
    end
    if i>1
        if Trade_flag(i)==Trade_flag(i-1)
            Flag(i)=-1;
        end
    end
end
TickOutIdx= Flag==-1;       % Instead of 'TickOutIdx=find(Flag==-1);' for acceleration
RealTradeDay(TickOutIdx)=[];
%==========================================================================
%在不考虑强制平仓的情况下寻找出需要交易的点
for i=1:numel(RealTradeDay)
    a=find(RealTrade_a==RealTradeDay(i));
    b=find(RealTrade_b==RealTradeDay(i));
        if (a~=0)       %向上突破的条件判断
            if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.price=0;
                outputdata.orderlist.direction=1;
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %计算出交易记录
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                outputdata.record.direction(i)=1;
            end
        elseif(b~=0)        %向下突破的条件判断
                if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更行outputdata.orderlist向量
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.direction=-1;
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %计算出交易记录
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                    outputdata.record.direction(i)=-1;
                end
        end
end
%==========================================================================
%完善outputdata.record,填入平仓日期和平仓价格
if(numel(outputdata.record.opdate)>=2)
    outputdata.record.cpdate=outputdata.record.opdate(2:end);
    outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
    outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
    outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
    outputdata.record.cpdate(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.date(end); 
    outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.op(end);
elseif(numel(outputdata.record.opdate)>=1)
    outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
    outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
    outputdata.record.isclosepos=0;
end

end