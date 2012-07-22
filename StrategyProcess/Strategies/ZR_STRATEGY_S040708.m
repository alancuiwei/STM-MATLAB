function outputdata=ZR_STRATEGY_S040708(inputdata)
% tmp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\RSIRO.mat');
% inputdata=tmp.l_inputdata;
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
outReal=TA_RSI(inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.D);
Price(1,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*80;
Price(2,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*20;
Price(3,:)=outReal;%����ƽ������������������Price��
Price(Price==0)=inf;
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',outReal,'Sheet1','M');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','H');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','I');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','J');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','K');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','L');
%==========================================================================
%�����Ϊԭ��Ѱ�ҽ���㣬����Ѱ�ҵ�����ŵ��������PositionTrade��
DiffPrice1=Price(2,:)-Price(3,:);
SignPrice1=DiffPrice1(2:numel(DiffPrice1)).*DiffPrice1(1:numel(DiffPrice1)-1);
Position1=find(SignPrice1<0);%����С��20�ĵ��λ��
PositionInter1=find(DiffPrice1==0);
DiffPrice2=Price(3,:)-Price(1,:);
SignPrice2=DiffPrice2(2:numel(DiffPrice2)).*DiffPrice2(1:numel(DiffPrice2)-1);
Position2=find(SignPrice2<0);%�������80�ĵ��λ��
PositionInter2=find(DiffPrice2==0);
SignPrice=[SignPrice1,SignPrice2];
SignPrice=sort(SignPrice);
Position=[Position1,Position2];
Position=sort(Position);
Position(1:1)=[];
PositionInter=[PositionInter1,PositionInter2];
PositionInter=sort(PositionInter);

% CntName=char(inputdata.commodity.serialmkdata.ctname);%�����Ʋֵ�
% DiffCntNme=CntName(2:end,:)-CntName(1:size(CntName,1)-1,:);
% [PosChaDay,a]=find(DiffCntNme~=0);
% PosChaDay=sort(PosChaDay);
% PosChaDay(PosChaDay<=(Position(1)))=[];
% ForceTrade=unique(PosChaDay); %������Լ�����һ��

PositionTrade=[Position,PositionInter];
PositionTrade=unique(sort(PositionTrade));
%==========================================================================
%�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
Cnt=2;%��������
 if(SignPrice(PositionTrade(1))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
        if(Price(3,PositionTrade(1)+1)>Price(3,PositionTrade(1)) && Price(3,PositionTrade(1)+1)>Price(1,PositionTrade(1)+1)) %����ͻ�Ƶ������ж�
                TradeDay(1)=PositionTrade(1);
        else if(Price(3,PositionTrade(1))>Price(3,PositionTrade(1)+1)&&Price(2,PositionTrade(1)+1)>Price(3,PositionTrade(1)+1))%����ͻ�Ƶ������ж�
                    TradeDay(1)=PositionTrade(1);
            end
        end
 else %������λ�øպ�Ϊ����ʱ
        if(Price(3,PositionTrade(1)+1)>Price(3,PositionTrade(1)) && Price(3,PositionTrade(1)+1)>Price(1,PositionTrade(1)+1)) %����ͻ�Ƶ������ж�
            TradeDay(1)=PositionTrade(1);
        else if (Price(3,PositionTrade(1))>Price(3,PositionTrade(1)+1)&&Price(2,PositionTrade(1)+1)>Price(3,PositionTrade(1)+1))%����ͻ�Ƶ������ж�
                TradeDay(1)=PositionTrade(1);
            end
        end
 end
for i=2:numel(PositionTrade)
    if(SignPrice(PositionTrade(i))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
        if(Price(3,PositionTrade(i)+1)>Price(3,PositionTrade(i)) && Price(3,PositionTrade(i)+1)>Price(1,PositionTrade(i)+1))&&...
                (Price(3,TradeDay(i-1))>Price(3,TradeDay(i-1)+1)&&Price(2,TradeDay(i-1)+1)>Price(3,TradeDay(i-1)+1)) %����ͻ�Ƶ������ж�
                TradeDay(Cnt)=PositionTrade(i);
                Cnt=Cnt+1;
        else if(Price(3,PositionTrade(i))>Price(3,PositionTrade(i)+1)&&Price(2,PositionTrade(i)+1)>Price(3,PositionTrade(i)+1))&&...
                    (Price(3,TradeDay(i-1)+1)>Price(3,TradeDay(i-1)) && Price(3,TradeDay(i-1)+1)>Price(1,TradeDay(i-1)+1))%����ͻ�Ƶ������ж�
                    TradeDay(Cnt)=PositionTrade(i);
                    Cnt=Cnt+1;
            else
                TradeDay(Cnt)=TradeDay(i-1);
                Cnt=Cnt+1;
            end
        end
    else %������λ�øպ�Ϊ����ʱ
        if(Price(3,PositionTrade(i)+1)>Price(3,PositionTrade(i)) && Price(3,PositionTrade(i)+1)>Price(1,PositionTrade(i)+1))&&...
                (Price(3,TradeDay(i-1))>Price(3,TradeDay(i-1)+1)&&Price(2,TradeDay(i-1)+1)>Price(3,TradeDay(i-1)+1)) %����ͻ�Ƶ������ж�
            TradeDay(Cnt)=PositionTrade(i);
            Cnt=Cnt+1;
        else if (Price(3,PositionTrade(i))>Price(3,PositionTrade(i)+1)&&Price(2,PositionTrade(i)+1)>Price(3,PositionTrade(i)+1))&&...
                    (Price(3,TradeDay(i-1)+1)>Price(3,TradeDay(i-1)) && Price(3,TradeDay(i-1)+1)>Price(1,TradeDay(i-1)+1))%����ͻ�Ƶ������ж�
                TradeDay(Cnt)=PositionTrade(i);
                Cnt=Cnt+1;
            else
                TradeDay(Cnt)=TradeDay(i-1);
                Cnt=Cnt+1;
            end
        end
    end   
end
%==========================================================================
%�ϲ��������ں�ǿ��ƽ������,��ʱ��Щʱ������н��׵ķ���
% TradeDay=unique(TradeDay);
% RealTradeDayBuff=[TradeDay,ForceTrade'];
% RealTradeDayBuff=sort(RealTradeDayBuff);
% RealTradeDay=unique(RealTradeDayBuff);
RealTradeDay=unique(TradeDay);
%==========================================================================
%����record�е�opdateprice,direction
for i=1:numel(RealTradeDay)
    if(SignPrice(RealTradeDay(i))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
        if(Price(3,RealTradeDay(i)+1)>Price(3,RealTradeDay(i)) && Price(3,RealTradeDay(i)+1)>Price(1,RealTradeDay(i)+1))%����ͻ�Ƶ������ж�
            if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.direction=-1;
                outputdata.orderlist.price=0;
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %��������׼�¼
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                outputdata.record.direction(i)=-1;
            end
        else if (Price(3,RealTradeDay(i))>Price(3,RealTradeDay(i)+1)&&Price(2,RealTradeDay(i)+1)>Price(3,RealTradeDay(i)+1))%����ͻ�Ƶ������ж�
                if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %��������׼�¼
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                    outputdata.record.direction(i)=1;
                end
            end
        end
    else %������λ�øպ�Ϊ����ʱ
        if(Price(3,RealTradeDay(i)+1)>Price(3,RealTradeDay(i)) && Price(3,RealTradeDay(i)+1)>Price(1,RealTradeDay(i)+1))%����ͻ�Ƶ������ж�
            outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+1);
            outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+1);
            outputdata.record.direction(i)=-1;
        else if (Price(3,RealTradeDay(i))>Price(3,RealTradeDay(i)+1)&&Price(2,RealTradeDay(i)+1)>Price(3,RealTradeDay(i)+1))%����ͻ�Ƶ������ж�
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+1);
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+1);
                outputdata.record.direction(i)=1;
            end
        end
    end   
    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
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


