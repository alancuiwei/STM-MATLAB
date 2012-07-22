function outputdata = ZR_STRATEGY_SERIAL_PROCESS(strategyid1,strategyid2,inputdata)
% ���ݲ���id�ţ�����������ݽ��д���
% ���������
%           strategyid1����������ԣ�����������ʱ���������
%           strategyid2����ִ�в��ԣ�����ȷ��������������յ�����
%           inputdata������ʷ����
% ���������
%           outputdata�������׼�¼
%
% �˺����������Ʋֲ���

% strategyid1='040704';
% strategyid2='040704';
temp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\MA60_MACD.mat');
inputdata=temp.l_inputdata;
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
% �������
eval(strcat('PositionDay=ZR_STRATEGY_serial_',strategyid1,'(inputdata);'));
PositionDay_a=PositionDay{1,:};
PositionDay_b=PositionDay{2,:};
%==========================================================================
% ִ�в���
eval(strcat('TradeDay=ZR_STRATEGY_serial_',strategyid2,'(inputdata);'));
TradeDay_a=TradeDay{1,:};
TradeDay_b=TradeDay{2,:};
%==========================================================================
%�ɷ�����Ժ�ִ�в���ȷ��������������
if isempty(PositionDay_a) && isempty(PositionDay_b)
    sprintf('������ԣ�û�н��׷���');
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
%�޳�������������յĽ�����
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
%�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
for i=1:numel(RealTradeDay)
    a=find(RealTrade_a==RealTradeDay(i));
    b=find(RealTrade_b==RealTradeDay(i));
        if (a~=0)       %����ͻ�Ƶ������ж�
            if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.price=0;
                outputdata.orderlist.direction=1;
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %��������׼�¼
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                outputdata.record.direction(i)=1;
            end
        elseif(b~=0)        %����ͻ�Ƶ������ж�
                if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.direction=-1;
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %��������׼�¼
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                    outputdata.record.direction(i)=-1;
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
elseif(numel(outputdata.record.opdate)>=1)
    outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
    outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
    outputdata.record.isclosepos=0;
end

end