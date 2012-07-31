function outputdata=K_hanging(inputdata)
tmp=load('KDJl.mat');
inputdata=tmp.l_inputdata;
tick=input('输入合约最小价格变动tick=');
T=input('输入计算周期T=');
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
Price(1,:)=inputdata.commodity.serialmkdata.op;
Price(2,:)=inputdata.commodity.serialmkdata.cp;
Price(3,:)=inputdata.commodity.serialmkdata.hp;
Price(4,:)=inputdata.commodity.serialmkdata.lp;
% a=1:1:numel(Price(1,:));
% figure('Name',cell2mat(inputdata.commodity.name));
% plot(a,Price(3,:),'b*',a,Price(4,:),'r+');
% grid on
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','A');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','B');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','C');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','D');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','E');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.hp,'Sheet1','F');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.lp,'Sheet1','G');
%==========================================================================
%计算实体和上引线下引线的长度
cnt=1;
for i=(T+1):numel(Price(1,:))
    diff1(cnt)=max(Price(1,i),Price(2,i))-min(Price(1,i),Price(2,i));
    diff2(cnt)=Price(3,i)-max(Price(1,i),Price(2,i));
    diff3(cnt)=min(Price(1,i),Price(2,i))-Price(4,i);
    cnt=cnt+1;
end
%计算5日最低值
for i=1:(numel(Price(3,:))-T)
    H(i)=min(Price(3,i:i+(T-1)));
end
Price3=Price(3,(T+1):length(Price(3,:)));
cnt=1;
for i=1:numel(diff1)
    if (diff3(i)>=2*diff1(i)&&diff2(i)<=2*tick&&Price3(i)>=H(i))
        Position(cnt)=i+T;
        cnt=cnt+1;
    end
end
Position(Position==0)=[];
%==========================================================================
%根据连续4天创新低筛选真正的锤子线
for i=1:numel(Position)
    num(1)=0;
    hp=Price(3,1);
    lp=Price(4,1);
    for j=2:Position(i)
        if (Price(3,j)>hp||Price(4,j)<lp)
            if (Price(4,j)>=lp&&Price(3,j)>hp)
                num(j)=num(j-1)+1;
                hp=Price(3,j);
            elseif (Price(3,j)<hp&&Price(4,j)<=lp)
                num(j)=0;
                lp=Price(4,j);
            elseif (Price(3,j)>hp&&Price(4,j)<lp)
                num(j)=0;
                hp=Price(3,j);
                lp=Price(4,j);
            end
        else
        num(j)=num(j-1);
        end
    end
    if ((num(end)<=4)||(num(end-1)==num(end)))
        Position(i)=0;
    end
end
Position(Position==0)=[];
%==========================================================================
CntName=char(inputdata.commodity.serialmkdata.ctname);%计算移仓点
DiffCntNme=CntName(1:size(CntName,1)-1,:)-CntName(2:end,:);
[PosChaDay,a]=find(DiffCntNme~=0);
PosChaDay=sort(PosChaDay);
if ~isempty(Position)
PosChaDay(PosChaDay<=(Position(1)))=[];
end
ForceTrade=unique(PosChaDay); %单个合约的最后一天
%==========================================================================
RealTradeDayBuff=[Position,ForceTrade'];
RealTradeDayBuff=sort(RealTradeDayBuff);
RealTradeDay=unique(RealTradeDayBuff);
%==========================================================================
%更新record中的opdateprice,direction
for i=1:numel(RealTradeDay)
            if(RealTradeDay(i)+1>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
                outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+1); %计算出交易记录
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+1);
                outputdata.record.direction(i)=-1;
            end
       
    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
end
%==========================================================================
%第一步矫正record,修改强制平仓价格以及当天的开仓价格
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1)
        if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
                outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(ForceTrade(i)+1);
        else
            outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
            outputdata.record.opdateprice(PositionForceInTrade)=inputdata.commodity.serialmkdata.op(ForceTrade(i)+1)+inputdata.commodity.serialmkdata.gap(ForceTrade(i)+1);
            outputdata.record.opdate(PositionForceInTrade)=inputdata.commodity.serialmkdata.date(ForceTrade(i)+1);
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
        if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
                outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(ForceTrade(i)+1);
        else
            CntName=inputdata.commodity.serialmkdata.ctname(ForceTrade(i));
            CntName;
            DateNum=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2);
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
j=1;
for i=1:length(RealTradeDay)
while j<=length(inputdata.commodity.serialmkdata.date)
    outputdata.dailyinfo.date(j)=inputdata.commodity.serialmkdata.date(j);
    realtrade=find(j==RealTradeDay(i));
    if (realtrade>=1)
    if outputdata.record.direction(i)==1
        outputdata.dailyinfo.trend(RealTradeDay(i))=2;
    else
        outputdata.dailyinfo.trend(RealTradeDay(i))=1;
    end
    break
    j=j+1;
    else
    outputdata.dailyinfo.trend(j)=4;
    j=j+1;
    end
    end
end
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
