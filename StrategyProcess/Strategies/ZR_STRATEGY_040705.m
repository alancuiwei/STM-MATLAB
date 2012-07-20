function outputdata=ZR_STRATEGY_040705(inputdata)
%tmp=load('KDJRO.mat');
%inputdata=tmp.l_inputdata;
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
%�����KDJ����
[outSlowK,outSlowD] = TA_STOCH (inputdata.commodity.serialmkdata.hp,inputdata.commodity.serialmkdata.lp,inputdata.commodity.serialmkdata.cp, ...
    inputdata.strategyparams.K,inputdata.strategyparams.D,0,inputdata.strategyparams.J,0);
Price(1,:)=outSlowK;
Price(2,:)=outSlowD;%����ƽ������������������Price��
Price(Price==0)=inf;
%==========================================================================
%�����Ϊԭ��Ѱ�ҽ���㣬����Ѱ�ҵ�����ŵ��������PositionTrade��
DiffPrice=Price(1,:)-Price(2,:);
SignPrice=DiffPrice(2:numel(DiffPrice)).*DiffPrice(1:numel(DiffPrice)-1);
Position=find(SignPrice<0);%����λ�ü�¼Ϊʵ�ʽ����ǰһ����,��ǰ��
PositionInter=find(DiffPrice==0);

CntName=char(inputdata.commodity.serialmkdata.ctname);%�����Ʋֵ�
DiffCntNme=CntName(2:end,:)-CntName(1:size(CntName,1)-1,:);
[PosChaDay,a]=find(DiffCntNme~=0);
PosChaDay=sort(PosChaDay);
PosChaDay(PosChaDay<=(Position(1)))=[];
ForceTrade=unique(PosChaDay); %������Լ�����һ��

PositionTrade=[Position,PositionInter];
PositionTrade=unique(sort(PositionTrade));
%==========================================================================
%�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
Cnt=1;%��������
% figure('Name',cell2mat(inputdata.commodity.name));
% plot(Price')
Direction=[];
for i=1:numel(PositionTrade)
    if(SignPrice(PositionTrade(i))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
        if(Price(1,PositionTrade(i)+1)>Price(1,PositionTrade(i)) && Price(2,PositionTrade(i)+1)>Price(2,PositionTrade(i)) ...
                && Price(1,PositionTrade(i)+1)>Price(2,PositionTrade(i)+1)) %����ͻ�Ƶ������ж�
                TradeDay(Cnt)=PositionTrade(i);
                Direction(Cnt)=1;
                Cnt=Cnt+1;
        elseif(Price(1,PositionTrade(i))>Price(1,PositionTrade(i)+1)&&Price(2,PositionTrade(i))>Price(2,PositionTrade(i)+1) ...
                    && Price(1,PositionTrade(i)+1)<Price(2,PositionTrade(i)+1)) %����ͻ�Ƶ������ж�
                    TradeDay(Cnt)=PositionTrade(i);
                    Direction(Cnt)=-1;
                    Cnt=Cnt+1;
        end
    else %������λ�øպ�Ϊ����ʱ
        if(Price(1,PositionTrade(i)+1)>Price(1,PositionTrade(i)-1)&&Price(2,PositionTrade(i)+1)>Price(2,PositionTrade(i)-1) ...
                && Price(1,PositionTrade(i)+1)>Price(2,PositionTrade(i)+1)) %����ͻ�Ƶ������ж�
            TradeDay(Cnt)=PositionTrade(i);
            Direction(Cnt)=1;
            Cnt=Cnt+1;
        elseif(Price(1,PositionTrade(i)+1)<Price(1,PositionTrade(i)-1)&&Price(2,PositionTrade(i)+1)<Price(2,PositionTrade(i)-1) ... 
                    && Price(1,PositionTrade(i)+1)<Price(2,PositionTrade(i)+1)) %����ͻ�Ƶ������ж�
                TradeDay(Cnt)=PositionTrade(i);
                Direction(Cnt)=-1;
                Cnt=Cnt+1;
        end
    end   
end
%ȥ��������������յĽ�������
direction=Direction(1);
for i = 2:numel(TradeDay)
    if Direction(i)==direction
        TradeDay(i)=-1;
    else
        direction=Direction(i);
    end
end
TradeDay(TradeDay==-1)=[];
TradeDay=unique(TradeDay);
%==========================================================================
%�ϲ��������ں�ǿ��ƽ������,��ʱ��Щʱ������н��׵ķ���
RealTradeDayBuff=[TradeDay,ForceTrade'];
RealTradeDayBuff=sort(RealTradeDayBuff);
RealTradeDay=unique(RealTradeDayBuff);
%==========================================================================
%����record�е�opdateprice,direction
for i=1:numel(RealTradeDay)
    if(SignPrice(RealTradeDay(i))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
        if(Price(1,RealTradeDay(i)+1)>Price(1,RealTradeDay(i)) && Price(2,RealTradeDay(i)+1)>Price(2,RealTradeDay(i)) ...
                && Price(1,RealTradeDay(i))<Price(2,RealTradeDay(i)) && Price(1,RealTradeDay(i)+1)>Price(2,RealTradeDay(i)+1)) %����ͻ�Ƶ������ж�
            if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %��������׼�¼
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                outputdata.record.direction(i)=1;
            end
        elseif(Price(1,RealTradeDay(i))>Price(1,RealTradeDay(i)+1)&&Price(2,RealTradeDay(i))>Price(2,RealTradeDay(i)+1) ...
                    && Price(1,RealTradeDay(i))>Price(2,RealTradeDay(i)) && Price(1,RealTradeDay(i)+1)<Price(2,RealTradeDay(i)+1)) %����ͻ�Ƶ������ж�
                if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=-1;
                    outputdata.orderlist.price=0;
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %��������׼�¼
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                    outputdata.record.direction(i)=-1;
                end
        end
    else %������λ�øպ�Ϊ����ʱ
        if(Price(1,RealTradeDay(i)+1)>Price(1,RealTradeDay(i)-1)&&Price(2,RealTradeDay(i)+1)>Price(2,RealTradeDay(i)-1) ...
                && Price(1,RealTradeDay(i)-1)<Price(2,RealTradeDay(i)-1) && Price(1,RealTradeDay(i)+1)>Price(2,RealTradeDay(i)+1)) %����ͻ�Ƶ������ж�
            outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+1);
            outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+1);
            outputdata.record.direction(i)=1;
        elseif(Price(1,RealTradeDay(i)+1)<Price(1,RealTradeDay(i)-1)&&Price(2,RealTradeDay(i)+1)<Price(2,RealTradeDay(i)-1) ... 
                    && Price(1,RealTradeDay(i)-1)>Price(2,RealTradeDay(i)-1) && Price(1,RealTradeDay(i)+1)<Price(2,RealTradeDay(i)+1)) %����ͻ�Ƶ������ж�
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+1);
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+1);
                outputdata.record.direction(i)=-1;
        end
    end   
    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
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
            outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
            CntName=inputdata.commodity.serialmkdata.ctname(ForceTrade(i)+1);
            DateNum=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2);
            CntID=find(ismember(inputdata.contractname,CntName)==1);
            DataID=find(ismember(inputdata.contract(1,CntID).mkdata.date,DateNum)==1);
            outputdata.record.opdateprice(PositionForceInTrade)=inputdata.contract(1,CntID).mkdata.op(DataID);
%             outputdata.record.opdateprice(PositionForceInTrade)=inputdata.commodity.serialmkdata.op(ForceTrade(i)+2)+inputdata.commodity.serialmkdata.gap(ForceTrade(i)+2);
            outputdata.record.opdate(PositionForceInTrade)=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2);
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
%         C=char(CntName);
%         c=C(end-1:end);
%         d=Dattmp(1,6:7);
%         if c<=d
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
%         end
        % 0503-lm
    end
end
%==========================================================================

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

