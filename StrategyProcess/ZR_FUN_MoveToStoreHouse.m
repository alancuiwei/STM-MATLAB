function outputdata = ZR_FUN_MoveToStoreHouse(inputdata1, inputdata2, TradeDay)
% ִ���Ʋֲ���
% ���룺inputdata1----����l_inputdata
%       inputdata2----���Բ���ZR_STRATEGY_XXXXXX��output
%       TradeDay------�������ZR_STRATEGY_XXXXXX��TradeDay
% �����outputdata----��¼ÿһ�ʿ��ֺ�ƽ�ֵ���Ϣ
%
% l_temp=load('serial_a.mat');
% inputdata=l_temp.l_inputdata;
% [Output,TradeDay] = ZR_STRATEGY_040704_new(inputdata);
%==========================================================================
%���������ʼ������
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
%�����Ʋֵ�
CntName=char(inputdata1.commodity.serialmkdata.ctname);
DiffCntNme=CntName(2:end,:)-CntName(1:size(CntName,1)-1,:);
[PosChaDay,a]=find(DiffCntNme~=0);
PosChaDay=sort(PosChaDay);                                                                            
ForceTrade=unique(PosChaDay); %������Լ�����һ��
%�ϲ������պ��Ʋ���
RealTradeDayBuff=[TradeDay,ForceTrade'];
RealTradeDayBuff=sort(RealTradeDayBuff);
RealTradeDay=unique(RealTradeDayBuff);
%==========================================================================
%��һ������record,�޸�ǿ��ƽ�ּ۸��Լ�����Ŀ��ּ۸�
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1)
        if(ForceTrade(i)+2>numel(inputdata1.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
            outputdata.orderlist.direction=1;
            outputdata.orderlist.price=0;
        else
            outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
            outputdata.record.opdateprice(PositionForceInTrade)=inputdata1.commodity.serialmkdata.op(ForceTrade(i)+2)+inputdata1.commodity.serialmkdata.gap(ForceTrade(i)+2);
            outputdata.record.opdate(PositionForceInTrade)=inputdata1.commodity.serialmkdata.date(ForceTrade(i)+2);
        end
%         if(ForceTrade(i)+2>numel(inputdata1.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
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
% %����outputdata.record,����ƽ�����ں�ƽ�ּ۸�
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

%�ڶ�������record,�޸�ǿ��ƽ�ּ۸��Լ�����Ŀ��ּ۸�
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1) 
        %�޸����Ʋֲ�����ص�ƽ�ּ۸���Ҫ��һ���ĺ�Լ��(cntname)���Լ��Ʋ�����(ForceTrade+2)
        %��Լ��ID��������Դ��cntname�Լ���Լ������
        if(ForceTrade(i)+2>numel(inputdata1.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
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
        %������Լ�ڽ�����ǰ��δƽ�֣����������Ʋ� 
        Dattmp = char(inputdata1.commodity.serialmkdata.date(ForceTrade(i)));
        LastDayFlag = judgeIsLastDay(Dattmp);
        if (LastDayFlag)%LastDayFlag ��ʾ������ǰ��δƽ�ֵı�־
            %��εĴ���------
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