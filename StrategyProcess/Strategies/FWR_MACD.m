function outputdata=FWR_MACD(inputdata)
tmp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\FWRRO.mat');
inputdata=tmp.l_inputdata;
%==========================================================================
%���������ʼ������
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
[outMACD, outMACDSignal, outMACDHist]=TA_MACD(inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.fa,inputdata.strategyparams.sl,inputdata.strategyparams.si);
Price(1,:)=outMACD;
Price(3,:)=outMACDSignal;
Price(4,:)=outMACDHist;
Price1=inputdata.commodity.serialmkdata.hp;
Price2=inputdata.commodity.serialmkdata.lp;
Price3=inputdata.commodity.serialmkdata.cp;
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','I');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','J');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','K');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','L');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','M');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.hp,'Sheet1','N');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.lp,'Sheet1','O');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',outMACD,'Sheet1','P');
%==========================================================================
Price(2,:)=zeros(size(inputdata.commodity.serialmkdata.cp));
DiffPrice3=Price(1,:)-Price(2,:);
SignPrice3=DiffPrice3(2:numel(DiffPrice3)).*DiffPrice3(1:numel(DiffPrice3)-1);
Position3=find(SignPrice3<0);%����λ�ü�¼Ϊʵ�ʽ����ǰһ����,��ǰ��
cnt=1;
for i=1:numel(Position3)
    if (Price(1,Position3(i)+1)>Price(1,Position3(i))&&Price(1,Position3(i)+1)>Price(2,Position3(i)+1))
       Position_a(cnt)=Position3(i);
       cnt=cnt+1;
    else if (Price(1,Position3(i)+1)<Price(1,Position3(i))&&Price(1,Position3(i)+1)<Price(2,Position3(i)+1))
              Position_b(cnt)=Position3(i);
       cnt=cnt+1;
        end
    end
end
Position_a(Position_a==0)=[];
Position_b(Position_b==0)=[];
Position_a=unique(sort(Position_a));
Position_b=unique(sort(Position_b));
%���������ڵ���߼ۺ���ͼ�
for i=1:(numel(Price1)-5)
    H(i)=max(Price1(i:i+4));
    L(i)=min(Price2(i:i+4));
end
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',H','Sheet1','F22:F2484');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',L','Sheet1','G22:G2484');
DiffPrice1=H-Price3(6:end)';
SignPrice1=DiffPrice1(2:numel(DiffPrice1)).*DiffPrice1(1:numel(DiffPrice1)-1);
Position1=find(SignPrice1<0)+5;%�������̼۸���������߼۵ĵ��λ��
PositionInter1=find(DiffPrice1==0);
DiffPrice2=Price3(6:end)'-L;
SignPrice2=DiffPrice2(2:numel(DiffPrice2)).*DiffPrice2(1:numel(DiffPrice2)-1);
Position2=find(SignPrice2<0)+5;%�������̼�С��������ͼ۵ĵ��λ�� 
PositionInter2=find(DiffPrice2==0);
SignPrice=[SignPrice1,SignPrice2,SignPrice3];
SignPrice=sort(SignPrice);
Position1(Position1<(Position3(1)))=[];
Position2(Position2<(Position3(1)))=[];
Position=[Position1,Position2];
Position=unique(sort(Position));
PositionInter=[PositionInter1+6,PositionInter2+6];
PositionInter=unique(sort(PositionInter));

CntName=char(inputdata.commodity.serialmkdata.ctname);%�����Ʋֵ�
DiffCntNme=CntName(2:end,:)-CntName(1:size(CntName,1)-1,:);
[PosChaDay,a]=find(DiffCntNme~=0);
PosChaDay=sort(PosChaDay);
ForceTrade=unique(PosChaDay); %������Լ�����һ��

PositionTrade=[Position,PositionInter];
PositionTrade=unique(sort(PositionTrade));
%==========================================================================
%�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
Cnt=1;
for i=1:numel(PositionTrade)
        if(SignPrice(PositionTrade(i))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if(Price3(PositionTrade(i)+1)>Price3(PositionTrade(i))&&...
                Price3(PositionTrade(i)+1)>H(PositionTrade(i)-5)&&...
                H(PositionTrade(i)-5)>Price3(PositionTrade(i)))%����ͻ�Ƶ������ж�
                TradeDay(Cnt)=PositionTrade(i);
                Direction(Cnt)=1;
            elseif(Price3(PositionTrade(i))>Price3(PositionTrade(i)+1)&&...
                    L(PositionTrade(i)-5)>Price3(PositionTrade(i)+1)&&...
                    L(PositionTrade(i)-5)<Price3(PositionTrade(i)-1))%����ͻ�Ƶ������ж�
                    TradeDay(Cnt)=PositionTrade(i);
                    Direction(Cnt)=-1;
            end
            Cnt=Cnt+1;
        else %������λ�øպ�Ϊ����ʱ
            if(Price3(PositionTrade(i)+1)>Price3(PositionTrade(i)-1)&&...
                Price3(PositionTrade(i)+1)>H(PositionTrade(i)-6)&&...
                Price3(PositionTrade(i)-1)<H(PositionTrade(i)-5)) %����ͻ�Ƶ������ж�
                TradeDay(Cnt)=PositionTrade(i);
                Direction(Cnt)=1;
            elseif (Price3(PositionTrade(i)-1)>Price3(PositionTrade(i)+1)&&...
                   L(PositionTrade(i)-6)>Price3(PositionTrade(i)+1)&&...
                    L(PositionTrade(i)-6)<Price3(PositionTrade(i)-1))%����ͻ�Ƶ������ж�
                TradeDay(Cnt)=PositionTrade(i);
                Direction(Cnt)=-1;
                Cnt=Cnt+1;
            end
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
    elseif Price(1,TradeDay(i)+1)<Price(2,TradeDay(i)+1)
        TradeDay_b(cnt)=TradeDay(i);
        cnt=cnt+1;
    end
end
TradeDay_a(TradeDay_a==0)=[];
TradeDay_b(TradeDay_b==0)=[];
TradeDay_a=unique(sort(TradeDay_a));
TradeDay_b=unique(sort(TradeDay_b));
%==========================================================================
%�ɷ�����Ժ�ִ�в���ȷ��������������
Cnt=1;
RealTrade_a=[];
RealTrade_b=[];
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
RealTrade_a=unique(RealTrade_a);
RealTrade_b=unique(RealTrade_b);
if (~isempty(RealTrade_b)&&~isempty(RealTrade_a))
    Trade=sort([RealTrade_a,RealTrade_b]);
elseif ~isempty(RealTrade_b)
    Trade=sort([RealTrade_b]);
else
    Trade=([RealTrade_a]);
end
%     Trade=sort([RealTrade_a,RealTrade_b]);
%�޳�������������յĽ�����
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
%�ϲ��������ں�ǿ��ƽ������,��ʱ��Щʱ������н��׵ķ���
ForceTrade=ForceTrade';
ForceTrade(ForceTrade<Trade(1))=[];
RealTradeDayBuff=[Trade,ForceTrade];
RealTradeDayBuff=sort(RealTradeDayBuff);
RealTradeDay=unique(RealTradeDayBuff);
%==========================================================================
% cnt=1;
cnt=1;
for i=1:numel(Position3)
    if (Price(1,Position3(i)+1)>Price(1,Position3(i))&&Price(1,Position3(i)+1)>Price(2,Position3(i)+1))
       Position_a(cnt)=Position3(i);
       cnt=cnt+1;
    else if (Price(1,Position3(i)+1)<Price(1,Position3(i))&&Price(1,Position3(i)+1)<Price(2,Position3(i)+1))
              Position_b(cnt)=Position3(i);
       cnt=cnt+1;
        end
    end
end
for i=1:numel(RealTradeDay)
    a=find(RealTrade_a==RealTradeDay(i));
    b=find(RealTrade_b==RealTradeDay(i));
        if (a~=0)%����ͻ�Ƶ������ж�
            if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.price=0;
                outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %��������׼�¼
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                outputdata.record.direction(i)=1;
            end
        elseif(b~=0)%����ͻ�Ƶ������ж�
                if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.price=0;
                    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %��������׼�¼
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                    outputdata.record.direction(i)=-1;
                end
        else
            outputdata.record.opdate{i}=[];
            outputdata.record.ctname{i}=[];
        end
end     

%==========================================================================
%��һ������record,�޸�ǿ��ƽ�ּ۸��Լ�����Ŀ��ּ۸�
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1)
        if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
        else
            outputdata.record.opdateprice(PositionForceInTrade)=inputdata.commodity.serialmkdata.op(ForceTrade(i)+2)+inputdata.commodity.serialmkdata.gap(ForceTrade(i)+2);
            outputdata.record.opdate(PositionForceInTrade)=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2);
            outputdata.record.ctname(PositionForceInTrade)=inputdata.commodity.serialmkdata.ctname(ForceTrade(i)+1);
            outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
        end
    end
end
%==========================================================================

%����outputdata.record,����ƽ�����ں�ƽ�ּ۸�
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
%�ڶ�������record,�޸�ǿ��ƽ�ּ۸��Լ�����Ŀ��ּ۸�
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1) 
        %�޸����Ʋֲ�����ص�ƽ�ּ۸���Ҫ��һ���ĺ�Լ��(cntname)���Լ��Ʋ�����(ForceTrade+2)
        %��Լ��ID��������Դ��cntname�Լ���Լ������
        if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
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
        %������Լ�ڽ�����ǰ��δƽ�֣����������Ʋ� 
        Dattmp = char(inputdata.commodity.serialmkdata.date(ForceTrade(i)));
        C=char(CntName);
        c=C(end-1:end);
        d=Dattmp(1,6:7);
        if c<=d
        LastDayFlag = judgeIsLastDay(Dattmp);
        if (LastDayFlag)%LastDayFlag ��ʾ������ǰ��δƽ�ֵı�־
            %��εĴ���------
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
figure('Name',cell2mat(inputdata.commodity.name));
plot(H')
hold on
plot(L','r')
hold on
plot(Price3(22:end)','g')
plot(Price(1,:),'m');
hold on;
plot(Price(2,:),'k')
hold off
% �ж������ǲ������һ��
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


