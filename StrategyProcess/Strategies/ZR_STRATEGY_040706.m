function [outputdata,TradeDay]=ZR_STRATEGY_040706(inputdata)
%tmp=load('inRO.mat');
%inputdata=tmp.l_inputdata;
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
%计算出MACD值
[outMACD, outMACDSignal, outMACDHist]=TA_MACD(inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.fa,inputdata.strategyparams.sl,inputdata.strategyparams.si);
Price(1,:)=outMACD;
Price(3,:)=outMACDSignal;
Price(4,:)=outMACDHist;
%==========================================================================
%以异号为原则寻找交叉点，并将寻找到的异号点存入数组PositionTrade中
Price(2,:)=zeros(size(inputdata.commodity.serialmkdata.cp));
DiffPrice=Price(1,:)-Price(2,:);
SignPrice=DiffPrice(2:numel(DiffPrice)).*DiffPrice(1:numel(DiffPrice)-1);
Position=find(SignPrice<0);%交点位置记录为实际交点的前一个点,当前点
PositionInter=find(DiffPrice==0);

CntName=char(inputdata.commodity.serialmkdata.ctname);%计算移仓点
DiffCntNme=CntName(1:size(CntName,1)-1,:)-CntName(2:end,:);
[PosChaDay,a]=find(DiffCntNme~=0);
PosChaDay=sort(PosChaDay);
PosChaDay(PosChaDay<=(Position(1)))=[];
ForceTrade=unique(PosChaDay); %单个合约的最后一天

PositionTrade=[Position,PositionInter];
PositionTrade=unique(sort(PositionTrade));
%==========================================================================
%在不考虑强制平仓的情况下寻找出需要交易的点
Cnt=1;%计数变量

for i=34:numel(PositionTrade)
    if(SignPrice(PositionTrade(i))~=0) %判断此交点位置是否刚好为整数
        if(Price(1,PositionTrade(i)+1)>Price(1,PositionTrade(i)) && Price(1,PositionTrade(i)+1)>Price(2,PositionTrade(i)+1)) %向上突破的条件判断
                TradeDay(Cnt)=PositionTrade(i);
                Cnt=Cnt+1;
        else if(Price(1,PositionTrade(i))>Price(1,PositionTrade(i)+1) && Price(1,PositionTrade(i)+1)<Price(2,PositionTrade(i)+1)) %向下突破的条件判断
                    TradeDay(Cnt)=PositionTrade(i);
                    Cnt=Cnt+1; 
            end
        end
    else %当交点位置刚好为整数时
        if(Price(1,PositionTrade(i)+1)>Price(1,PositionTrade(i)) && Price(1,PositionTrade(i)+1)>Price(2,PositionTrade(i)+1)) %向上突破的条件判断
            TradeDay(Cnt)=PositionTrade(i);
            Cnt=Cnt+1;
        else if(Price(1,PositionTrade(i)+1)<Price(1,PositionTrade(i)) && Price(1,PositionTrade(i)+1)<Price(2,PositionTrade(i))) %向下突破的条件判断
                TradeDay(Cnt)=PositionTrade(i);
                Cnt=Cnt+1;
            end
        end
    end   
end
%==========================================================================
%合并交易日期和强制平仓日期,此时这些时间必须有交易的发生
RealTradeDayBuff=[TradeDay,ForceTrade'];
RealTradeDayBuff=sort(RealTradeDayBuff);
RealTradeDay=unique(RealTradeDayBuff);
%==========================================================================
%更新record中的opdateprice,direction
for i=1:numel(RealTradeDay)
    if(SignPrice(RealTradeDay(i))~=0) %判断此交点位置是否刚好为非整数
        if(Price(1,RealTradeDay(i)+1)>Price(1,RealTradeDay(i)) && Price(1,RealTradeDay(i)+1)>Price(2,RealTradeDay(i)+1)) %向上突破的条件判断
            if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %计算出交易记录
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                outputdata.record.direction(i)=1;
            end
        else if(Price(1,RealTradeDay(i))>Price(1,RealTradeDay(i)+1) && Price(1,RealTradeDay(i)+1)<Price(2,RealTradeDay(i)+1)) %向下突破的条件判断
                if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更行outputdata.orderlist向量
                    outputdata.orderlist.direction=-1;
                    outputdata.orderlist.price=0;
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %计算出交易记录
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                    outputdata.record.direction(i)=-1;
                end
            end
        end
    else %当交点位置刚好为整数时
        if(Price(1,RealTradeDay(i)+1)>Price(1,RealTradeDay(i)-1) && Price(1,RealTradeDay(i)+1)>Price(2,RealTradeDay(i)+1)) %向上突破的条件判断
            outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+1);
            outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+1);
            outputdata.record.direction(i)=1;
        else if(Price(1,RealTradeDay(i)+1)<Price(1,RealTradeDay(i)-1) && Price(1,RealTradeDay(i)+1)<Price(2,RealTradeDay(i)+1)) %向下突破的条件判断
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+1);
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+1);
                outputdata.record.direction(i)=-1;
            end
        end
    end   
    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
end
%==========================================================================
%第一步矫正record,修改强制平仓价格以及当天的开仓价格
% for i=1:numel(ForceTrade)
%     PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
%     if (PositionForceInTrade>1)
%         if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
%                 outputdata.orderlist.direction=1;
%                 outputdata.orderlist.price=0;
%         else
%             outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
%             outputdata.record.opdateprice(PositionForceInTrade)=inputdata.commodity.serialmkdata.op(ForceTrade(i)+2)+inputdata.commodity.serialmkdata.gap(ForceTrade(i)+2);
%             outputdata.record.opdate(PositionForceInTrade)=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2);
%         end
%     end
% end
%==========================================================================

%完善outputdata.record,填入平仓日期和平仓价格
% if(numel(outputdata.record.opdate)>=2)
%     outputdata.record.cpdate=outputdata.record.opdate(2:end);
%     outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
%     outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
%     outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
%     outputdata.record.cpdate(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.date(end); 
%     outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.op(end);
%     %{
%     if(inputdata.contract.info.daystolasttradedate<=0) 
%         outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%     end
%     %}
% elseif(numel(outputdata.record.opdate)>=1)
%     outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
%     outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
%     outputdata.record.isclosepos=0;
%     %{
%     if(inputdata.contract.info.daystolasttradedate<=0) 
%         outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%     end
%     %}
% end
%==========================================================================
%第二步矫正record,修改强制平仓价格以及当天的开仓价格
% for i=1:numel(ForceTrade)
%     PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
%     if (PositionForceInTrade>1) 
%         %修改于移仓操作相关的平仓价格，需要上一步的合约名(cntname)，以及移仓日期(ForceTrade+2)
%         %合约名ID的生成来源于cntname以及合约的日期
%         if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
%                 outputdata.orderlist.direction=1;
%                 outputdata.orderlist.price=0;
%         else
%             CntName=inputdata.commodity.serialmkdata.ctname(ForceTrade(i));
%             CntName;
%             DateNum=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2);
%             DateNum;
%             CntID=find(ismember(inputdata.contractname,CntName)==1);
%             find(ismember(inputdata.contract(1,CntID).mkdata.date,DateNum)==1);
%             DataID=find(ismember(inputdata.contract(1,CntID).mkdata.date,DateNum)==1);
%             outputdata.record.cpdateprice(PositionForceInTrade-1)=inputdata.contract(1,CntID).mkdata.op(DataID);
%         end
%     end
% end
% figure('Name',cell2mat(inputdata.commodity.name));
% plot(Price(1,:),'b');
% hold on;
% plot(Price(2,:),'r')
% hold off;