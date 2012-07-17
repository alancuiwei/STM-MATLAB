function outputdata=MA_MACD_FG(inputdata)
% tmp=load('MA_MACD_FGa.mat');
% inputdata=tmp.l_inputdata;
T=input('输入时间周期T=');
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
Price_1=inputdata.commodity.serialmkdata.hp;
Price_2=inputdata.commodity.serialmkdata.lp;
Price_3=inputdata.commodity.serialmkdata.cp;
Price_4=inputdata.commodity.serialmkdata.op;
for i=1:(numel(Price_1)-T)
    H(i)=max(Price_1(i:i+(T-1)));
    L(i)=min(Price_2(i:i+(T-1)));
    C(i)=Price_3(i+T);
    O(i)=Price_4(i+T);
end
[outMACD, outMACDSignal, outMACDHist]=TA_MACD(C',inputdata.strategyparams.fa,inputdata.strategyparams.sl,inputdata.strategyparams.si);
Price1=outMACD;
Day=zeros(1,inputdata.strategyparams.ma1)+1;%计算平均数的算子                                                                                                                                                                                                                         
Mean60Buff=conv(C,Day)/inputdata.strategyparams.ma1;%卷积求解
Price(2,:)=Mean60Buff(1:numel(C));
Price(1,:)=C;
Price(:,1:inputdata.strategyparams.ma1-1)=Inf;%整理平均数计算结果放入数组Price中
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','A');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','B');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','C');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','D');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','E');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',Price(2,:)','Sheet1','F');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',outMACD,'Sheet1','G');
%==========================================================================
Price2=zeros(size(outMACD));
DiffPrice=Price1-Price2;
SignPrice=DiffPrice(2:numel(DiffPrice)).*DiffPrice(1:numel(DiffPrice)-1);
Position1=find(SignPrice<0);%交点位置记录为实际交点的前一个点,当前点
cnt=1;
for i=1:numel(Position1)
    if (Price1(Position1(i)+1)>Price1(Position1(i))&&Price1(Position1(i)+1)>Price2(Position1(i)+1))
       Position_a(cnt)=Position1(i);
       cnt=cnt+1;
    elseif (Price1(Position1(i)+1)<Price1(Position1(i))&&Price1(Position1(i)+1)<Price2(Position1(i)+1))
       Position_b(cnt)=Position1(i);
       cnt=cnt+1;
    end
end
Position_a(Position_a==0)=[];
Position_b(Position_b==0)=[];
Position_a=unique(sort(Position_a));
Position_b=unique(sort(Position_b));

DiffPrice=Price(2,:)-Price(1,:);                                    
SignPrice=DiffPrice(2:numel(DiffPrice)).*DiffPrice(1:numel(DiffPrice)-1);
Position=find(SignPrice<0);%交点位置记录为实际交点的前一个点,当前点
PositionInter=find(DiffPrice==0);
%==========================================================================
CntName=char(inputdata.commodity.serialmkdata.ctname);%计算移仓点
DiffCntNme=CntName(2:end,:)-CntName(1:size(CntName,1)-1,:);
[PosChaDay,a]=find(DiffCntNme~=0);
PosChaDay=sort(PosChaDay);                                                                            
ForceTrade=unique(PosChaDay)-T; %单个合约的最后一天
                                                  
PositionTrade=[Position,PositionInter];
PositionTrade=unique(sort(PositionTrade));

 figure('Name',cell2mat(inputdata.commodity.name));
 plot(Price(1,:),'b');
 hold on;
 plot(Price(2,:),'r')
 hold on;
 plot(Price2+1800,'m')
 hold on;
 plot(Price1+1800,'g')
 hold off;
 
%==========================================================================
%在不考虑强制平仓的情况下寻找出需要交易的日期
Cnt=1;  %计数变量
for i=1:numel(PositionTrade)
    if(SignPrice(PositionTrade(i))~=0) %判断此交点位置是否刚好为整数
        if(Price(2,Position(i)+1)>Price(2,Position(i)) &&...   %MA均线上升
                Price(1,Position(i)+1)>Price(2,Position(i)+1) && Price(1,Position(i))<Price(2,Position(i))) %cp向上突破MA
            TradeDay(Cnt)=PositionTrade(i);
            Direction(Cnt)=1;
        elseif(Price(2,Position(i))>Price(2,Position(i)+1) &&...    %MA均线下降
                Price(1,Position(i))>Price(2,Position(i)) && Price(1,Position(i)+1)<Price(2,Position(i)+1)) %cp向下突破MA
            TradeDay(Cnt)=PositionTrade(i);
            Direction(Cnt)=-1;
        end
        Cnt=Cnt+1;
    else %当交点位置刚好为整数时
        if(Price(2,Position(i)+1)>Price(2,Position(i)-1) &&...   %MA均线上升
                Price(1,Position(i)+1)>Price(2,Position(i)+1) && Price(1,Position(i)-1)<Price(2,Position(i)-1)) %cp向上突破MA
            TradeDay(Cnt)=PositionTrade(i);
            Direction(Cnt)=1;
        elseif(Price(2,Position(i)-1)>Price(2,Position(i)+1) &&...    %MA均线下降
                Price(1,Position(i)-1)>Price(2,Position(i)-1) && Price(1,Position(i)+1)<Price(2,Position(i)+1)) %cp向下突破MA
            TradeDay(Cnt)=PositionTrade(i);
            Direction(Cnt)=-1;
        end
        Cnt=Cnt+1;
    end   
end
TradeDay(TradeDay==0)=[];
Direction(Direction==0)=[];
direction=Direction(1);
for i = 2:numel(TradeDay)
    if isequal(direction,Direction(i))
        TradeDay(i)=0;
    else
        direction=Direction(i);
    end
end
TradeDay(TradeDay==0)=[];
TradeDay=unique(TradeDay);
cnt=1;
for i=1:numel(TradeDay)
    if Price(1,TradeDay(i)+1)>Price(2,TradeDay(i)+1)
       TradeDay_a(cnt)=TradeDay(i);
       cnt=cnt+1;
    else if Price(1,TradeDay(i)+1)<Price(2,TradeDay(i)+1)
              TradeDay_b(cnt)=TradeDay(i);
       cnt=cnt+1;
        end
    end
end
% TradeDay=unique(TradeDay);
TradeDay_a(TradeDay_a==0)=[];
TradeDay_b(TradeDay_b==0)=[];
TradeDay_a=unique(sort(TradeDay_a));
TradeDay_b=unique(sort(TradeDay_b));
%==========================================================================
%由方向策略和执行策略确定真正交易日期
RealTrade_a=[];
RealTrade_b=[];
Cnt=1;
for i = 1:numel(TradeDay_a)
    PA_ID=find(Position_a>TradeDay_a(i));
    if ~isempty(PA_ID)
        MA_ID=find(TradeDay_b>TradeDay_a(i));
        if ~isempty(MA_ID) && TradeDay_b(MA_ID(1))<Position_a(PA_ID(1))
            continue;
        else
            RealTrade_a(Cnt)=Position_a(PA_ID(1));
            Cnt=Cnt+1;
        end
    end
end
Cnt=1;
for i = 1:numel(TradeDay_b)
    PB_ID=find(Position_b>TradeDay_b(i));
    if ~isempty(PB_ID)
        MB_ID=find(TradeDay_a>TradeDay_b(i));
        if ~isempty(MB_ID) && TradeDay_a(MB_ID(1))<Position_b(PB_ID(1))
            continue;
        else
            RealTrade_b(Cnt)=Position_b(PB_ID(1));
            Cnt=Cnt+1;
        end
    end
end
% Trade=sort([RealTrade_a,RealTrade_b]);
if ~isempty(RealTrade_a) && ~isempty(RealTrade_b)
    Trade=sort([unique(RealTrade_a),unique(RealTrade_b)]);
else
    if isempty(RealTrade_a) && ~isempty(RealTrade_b)
        Trade=sort(unique(RealTrade_b));
    elseif isempty(RealTrade_b) && ~isempty(RealTrade_a)
        Trade=sort(unique(RealTrade_a));
    else
        error('No Trade Day');
    end
end
%剔除连续做多或做空的交易日
Flag=zeros(1,numel(Trade));
for i = 1:numel(Trade)
    if ismember(Trade(i),RealTrade_a)
        Trade_flag(i)=1;
    else
        Trade_flag(i)=-1;
    end
    Flag(i) = Trade_flag(i);
    if i>1
        if Flag(i)==Flag(i-1)
            Flag(i)=0;
        end
    end
end
TickOutIdx=find(Flag==0);
Trade(TickOutIdx)=0;
Trade(Trade==0)=[];
%==========================================================================
%合并交易日期和强制平仓日期,此时这些时间必须有交易的发生
ForceTrade=ForceTrade';
ForceTrade(ForceTrade<Trade(1))=[];
RealTradeDayBuff=[Trade,ForceTrade];
RealTradeDayBuff=sort(RealTradeDayBuff);
RealTradeDay=unique(RealTradeDayBuff);
%==========================================================================
for i=1:numel(RealTradeDay)
    a=find(RealTrade_a==RealTradeDay(i));
    b=find(RealTrade_b==RealTradeDay(i));
        if (a~=0)%向上突破的条件判断
            if(RealTradeDay(i)+2+T>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.price=0;
                outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+T+1);
%                 cnt=cnt+1;
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+T+2); %计算出交易记录
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+T+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+T+2);
                outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+T+1);
                outputdata.record.direction(i)=1;
%                 cnt=cnt+1;
            end
        elseif(b~=0)%向下突破的条件判断
                if(RealTradeDay(i)+2+T>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更行outputdata.orderlist向量
                    outputdata.orderlist.price=0;
                    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+T+1);
%                     cnt=cnt+1;
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+T+2); %计算出交易记录
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+T+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+T+2);
                    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+T+1);
                    outputdata.record.direction(i)=-1;
%                     cnt=cnt+1;
                end
        else outputdata.record.opdate{i}=[];
             outputdata.record.ctname{i}=[];
             outputdata.record.direction(i)=0;
%             cnt=cnt+1;
            end
end     
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1)
        if(ForceTrade(i)+2+T>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
        else
            outputdata.record.opdateprice(PositionForceInTrade)=inputdata.commodity.serialmkdata.op(ForceTrade(i)+T+2)+inputdata.commodity.serialmkdata.gap(ForceTrade(i)+T+2);
            outputdata.record.opdate(PositionForceInTrade)=inputdata.commodity.serialmkdata.date(ForceTrade(i)+T+2);
            outputdata.record.ctname(PositionForceInTrade)=inputdata.commodity.serialmkdata.ctname(ForceTrade(i)+T+1);
            outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
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
    %{
    if(inputdata.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
elseif(numel(outputdata.record.opdate)>=1)
    outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
    outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
    outputdata.record.isclosepos=0;
    %{
    if(inputdata.contract.info.daystolasttradedate<=0) 
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
        if(ForceTrade(i)+2+T>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
        else
            CntName=inputdata.commodity.serialmkdata.ctname(ForceTrade(i)+T);
            CntName;
            DateNum=inputdata.commodity.serialmkdata.date(ForceTrade(i)+T+2);
            DateNum;
            CntID=find(ismember(inputdata.contractname,CntName)==1);
            find(ismember(inputdata.contract(1,CntID).mkdata.date,DateNum)==1);
            DataID=find(ismember(inputdata.contract(1,CntID).mkdata.date,DateNum)==1);
            outputdata.record.cpdateprice(PositionForceInTrade-1)=inputdata.contract(1,CntID).mkdata.op(DataID);
        end
         % 0503-lm
        %主力合约在交割月前仍未平仓，当天立即移仓 
        Dattmp = char(inputdata.commodity.serialmkdata.date(ForceTrade(i)));
        C=char(CntName);
        c=C(end-1:end);
        d=Dattmp(1,6:7);
        if c<=d
        LastDayFlag = judgeIsLastDay(Dattmp);
        if (LastDayFlag)%LastDayFlag 表示交割月前仍未平仓的标志
            %这段的处理------
            CntName=inputdata.commodity.serialmkdata.ctname(ForceTrade(i));
            CntName;
            DateNum=inputdata.commodity.serialmkdata.date(ForceTrade(i));
            DateNum;
            CntID=find(ismember(inputdata.contractname,CntName)==1);
            DataID=find(ismember(inputdata.contract(1,CntID).mkdata.date,DateNum)==1);
            outputdata.record.cpdateprice(PositionForceInTrade-1)=inputdata.contract(1,CntID).mkdata.op(DataID);
        end
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


