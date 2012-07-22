function outputdata=MA60_MACD(inputdata)
temp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\MA60_l_inputdata.mat');
inputdata=temp.l_inputdata;
inputdata.strategyparams.ma1=60;
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
%计算60天平均曲线
Day60=zeros(1,inputdata.strategyparams.ma1)+1;%计算平均数的算子                                                                                                                                                                                                                         
Mean60Buff=conv(inputdata.commodity.serialmkdata.cp,Day60)/inputdata.strategyparams.ma1;%卷积求解
Price(1,:)=inputdata.commodity.serialmkdata.cp;
Price(2,:)=Mean60Buff(1:numel(inputdata.commodity.serialmkdata.cp));
Price(:,1:inputdata.strategyparams.ma1-1)=Inf;
%==========================================================================
%以异号为原则寻找交叉点，并将寻找到的异号点存入数组PositionTrade中
DiffPrice=Price(1,:)-Price(2,:);                                    
SignPrice=DiffPrice(2:numel(DiffPrice)).*DiffPrice(1:numel(DiffPrice)-1);
Position=find(SignPrice<0);%交点位置记录为实际交点的前一个点,当前点
PositionInter=find(DiffPrice==0);

CntName=char(inputdata.commodity.serialmkdata.ctname);%计算移仓点
DiffCntNme=CntName(2:end,:)-CntName(1:size(CntName,1)-1,:);
[PosChaDay,a]=find(DiffCntNme~=0);
PosChaDay=sort(PosChaDay);                                                                            
ForceTrade=unique(PosChaDay); %单个合约的最后一天
                                                  
PositionTrade=[Position,PositionInter];
PositionTrade=unique(sort(PositionTrade));


% figure('Name',cell2mat(inputdata.commodity.name));
% figure;
% plot(Price(1,:),'b');
% hold on;
% plot(Price(2,:),'r')
% hold off;
%==========================================================================
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','I');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','J');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','K');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','L');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','M');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.hp,'Sheet1','N');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.lp,'Sheet1','O');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',outMACD,'Sheet1','P');
%==========================================================================
%在不考虑强制平仓的情况下寻找出需要交易的点
Cnt=1;  %计数变量
for i=1:numel(PositionTrade)
    if(SignPrice(PositionTrade(i))~=0) %判断此交点位置是否刚好为整数
        if(Price(2,Position(i)+1)>Price(2,Position(i)) &&...   %MA均线上升
                Price(1,Position(i)+1)>Price(2,Position(i)+1) && Price(1,Position(i))<Price(2,Position(i))) %cp向上突破MA
            TradeDay(Cnt)=PositionTrade(i);
            Cnt=Cnt+1;
        elseif(Price(2,Position(i))>Price(2,Position(i)+1) &&...    %MA均线下降
                Price(1,Position(i))>Price(2,Position(i)) && Price(1,Position(i)+1)<Price(2,Position(i)+1)) %cp向下突破MA
            TradeDay(Cnt)=PositionTrade(i);
            Cnt=Cnt+1;
        end
    else %当交点位置刚好为整数时
        if(Price(2,Position(i)+1)>Price(2,Position(i)-1) &&...   %MA均线上升
                Price(1,Position(i)+1)>Price(2,Position(i)+1) && Price(1,Position(i)-1)<Price(2,Position(i)-1)) %cp向上突破MA
            TradeDay(Cnt)=PositionTrade(i);
            Cnt=Cnt+1;
        elseif(Price(2,Position(i)-1)>Price(2,Position(i)+1) &&...    %MA均线下降
                Price(1,Position(i)-1)>Price(2,Position(i)-1) && Price(1,Position(i)+1)<Price(2,Position(i)+1)) %cp向下突破MA
            TradeDay(Cnt)=PositionTrade(i);
            Cnt=Cnt+1;
        end
    end   
end
% TradeDay(TradeDay==0)=[];
% Direction(Direction==0)=[];
% direction=Direction(1);
% for i = 2:numel(TradeDay)
%     if isequal(direction,Direction(i))
%         TradeDay(i)=0;
%     else
%         direction=Direction(i);
%     end
% end
% TradeDay(TradeDay==0)=[];
% TradeDay=unique(TradeDay);
%==========================================================================
% for i=1:numel(PositionTrade)
%         if(SignPrice(PositionTrade(i))~=0) %判断此交点位置是否刚好为整数
%             if(Price(2,PositionTrade(i)+1)>Price(2,PositionTrade(i))&&...
%                 Price(1,PositionTrade(i))>Price(2,i))%向上突破的条件判断
%                 TradeDay1(i)=PositionTrade(i);
%             elseif(Price(2,PositionTrade(i))>Price(2,PositionTrade(i)+1)&&...
%                     Price(1,PositionTrade(i))<Price(2,i))%向下突破的条件判断
%                     TradeDay1(i)=PositionTrade(i);
%             else
%                 TradeDay1(i)=0;
%             end
%         else %当交点位置刚好为整数时
%             if(Price(2,PositionTrade(i)+1)>Price(2,PositionTrade(i)-1)&&...
%                 Price(1,PositionTrade(i))>Price(2,i)) %向上突破的条件判断
%                 TradeDay1(i)=PositionTrade(i);
%             elseif (Price(2,PositionTrade(i)-1)>Price(2,PositionTrade(i)+1)&&...
%                     Price(1,PositionTrade(i))<Price(2,i))%向下突破的条件判断
%                 TradeDay1(i)=PositionTrade(i);
%             else
%                 TradeDay1(i)=0;
%             end
%         end
%     if TradeDay1(i)~=0
%         break
%     end
% end
% TradeDay(1)=TradeDay1(end);
% Cnt=2;%计数变量
% for i=2:numel(PositionTrade)
%         if(SignPrice(PositionTrade(i))~=0) %判断此交点位置是否刚好为整数
%             if(Price(2,PositionTrade(i)+1)>Price(2,PositionTrade(i))&&...
%                 Price(1,PositionTrade(i)+1)>Price(2,PositionTrade(i))&&...
%                 Price(1,PositionTrade(i))<Price(2,PositionTrade(i)))%向上突破的条件判断
%                 TradeDay(Cnt)=PositionTrade(i);
%                 Cnt=Cnt+1;
%             elseif(Price(2,PositionTrade(i))>Price(2,PositionTrade(i)+1)&&...
%                    Price(1,PositionTrade(i)+1)<Price(2,PositionTrade(i)+1)&&...
%                     Price(1,PositionTrade(i))>Price(2,PositionTrade(i)))%向下突破的条件判断
%                     TradeDay(Cnt)=PositionTrade(i);
%                     Cnt=Cnt+1;
%             else
%                 TradeDay(Cnt)=TradeDay(Cnt-1);
%                 Cnt=Cnt+1;
%             end
%         else %当交点位置刚好为整数时
%             if(Price(2,PositionTrade(i)+1)>Price(2,PositionTrade(i)-1)&&...
%                 Price(1,PositionTrade(i)+1)>Price(2,PositionTrade(i)+1)&&...
%                 Price(1,PositionTrade(i)-1)<Price(2,PositionTrade(i)-1))%向上突破的条件判断
%                 TradeDay(Cnt)=PositionTrade(i);
%                 Cnt=Cnt+1;
%             elseif (Price(2,PositionTrade(i)-1)>Price(2,PositionTrade(i)+1)&&...
%                    Price(1,PositionTrade(i)+1)<Price(2,PositionTrade(i)+1)&&...
%                     Price(1,PositionTrade(i)-1)>Price(2,PositionTrade(i)-1))%向下突破的条件判断
%                 TradeDay(Cnt)=PositionTrade(i);
%                 Cnt=Cnt+1;
%             else
%                 TradeDay(Cnt)=TradeDay(Cnt-1);
%                 Cnt=Cnt+1;
%             end
%         end
% end
%==========================================================================
%修改TradeDay
TradeDay=unique(TradeDay);
TradeDay_a(TradeDay_a==0)=[];
TradeDay_b(TradeDay_b==0)=[];
TradeDay_a=unique(sort(TradeDay_a));
TradeDay_b=unique(sort(TradeDay_b));
x=min(length(TradeDay_a),length(Position_a));
y=min(length(TradeDay_b),length(Position_b));
n1=1;
n2=1;
n3=1;
n4=1;
if TradeDay_a(1)==TradeDay(1)
    for i=1:x
        for j=1:numel(Position_a)
        if Position_a(j)>TradeDay_a(i)
            a(n1)=Position_a(j);
            Position_a(j)=[];
            n1=n1+1;
            break
        end
        end
    end
    a(x:end)=[];
    a=a';
    for i=1:numel(a)
        for j=1:numel(TradeDay_b)
            if TradeDay_b(j)>a(i)
                b(n2)=TradeDay_b(j);
                TradeDay_b(j)=[];
                n2=n2+1;
                break
            end
        end
    end
     for i=1:numel(b)
        for j=1:numel(Position_b)
            if Position_b(j)>b(i)
                c(n3)=Position_b(j);
                Position_b(j)=[];
                n3=n3+1;
                break
            end
        end
     end
     Trade=[a(1),c(1)];
     DirectionDay=[TradeDay_a(1),b(1)];
     for i=1:(numel(c))
         if c(i)>a(i+1)
             a(i+1)=0;
             c(i+1)=0;
         end
     end
     a(a==0)=[];
     c(c==0)=[];
     for i=2:numel(c)
         if TradeDay_a(i)>c(n4)
             Trade=[Trade,a(i),c(i)];
             DirectionDay=[DirectionDay,TradeDay_a(i),b(i)];
             n4=n4+1;
         end
     end
Trade=unique(sort(Trade)); 
DirectionDay=unique(sort(DirectionDay));
else
    for i=1:y
        for j=1:numel(Position_b)
        if Position_b(j)>TradeDay_b(i)
            a(n1)=Position_b(j);
            Position_b(j)=[];
            n1=n1+1;
            break
        end
        end
    end
    a(y+1:end)=[];
    a=a';
    for i=1:numel(a)
        for j=1:numel(TradeDay_a)
            if TradeDay_a(j)>a(i)
                b(n2)=TradeDay_a(j);
                TradeDay_a(j)=[];
                n2=n2+1;
                break
            end
        end
    end
     for i=1:numel(b)
        for j=1:numel(Position_a)
            if Position_a(j)>b(i)
                c(n3)=Position_a(j);
                Position_a(j)=[];
                n3=n3+1;
                break
            end
        end
     end
     Trade=[a(1),c(1)];
     DirectionDay=[TradeDay_b(1),b(1)];
          for i=8:(numel(c))
         if c(i)>a(i+1)
             a(i+1)=0;
             c(i+1)=0;
         end
     end
     a(a==0)=[];
     c(c==0)=[];
     for i=2:numel(c)
         if TradeDay_b(i)>c(n4)
             Trade=[Trade,a(i),c(i)];
             DirectionDay=[DirectionDay,TradeDay_b(i),b(i)];
             n4=i;
         end
     end
 Trade=unique(sort(Trade)); 
 DirectionDay=unique(sort(DirectionDay));
end
%==========================================================================
%合并交易日期和强制平仓日期,此时这些时间必须有交易的发生
ForceTrade=ForceTrade';
ForceTrade(ForceTrade<Trade(1))=[];
Direction1=[DirectionDay,ForceTrade];
RealTradeDayBuff=[Trade,ForceTrade];
RealTradeDayBuff=sort(RealTradeDayBuff);
RealTradeDay=unique(RealTradeDayBuff);
Direction=unique(sort(Direction1));
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
    a=find(Position_a==RealTradeDay(i));
    b=find(Position_b==RealTradeDay(i));
        if (a~=0)%向上突破的条件判断
            if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.price=0;
                outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
%                 cnt=cnt+1;
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %计算出交易记录
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                outputdata.record.direction(i)=1;
%                 cnt=cnt+1;
            end
        elseif(b~=0)%向下突破的条件判断
                if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更行outputdata.orderlist向量
                    outputdata.orderlist.price=0;
                    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
%                     cnt=cnt+1;
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(RealTradeDay(i)+2); %计算出交易记录
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(RealTradeDay(i)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(i)+2);
                    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(i)+1);
                    outputdata.record.direction(i)=-1;
%                     cnt=cnt+1;
                end
        else outputdata.record.opdate{i}=[];
             outputdata.record.ctname{i}=[];
%             cnt=cnt+1;
            end
end     
% for i=1:numel(RealTradeDay)
%    if(SignPrice(RealTradeDay(i))~=0) %判断此交点位置是否刚好为非整数
%         if((Price3(RealTradeDay(i)+1)>Price3(RealTradeDay(i))&&...
%                 Price3(RealTradeDay(i)+1)>H(RealTradeDay(i)-5)))%向上突破的条件判断
%             if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
%                 outputdata.orderlist.direction=1;
%                 outputdata.orderlist.price=0;
%             else
%                outputdata.record.direction(i)=1;
%             end
%         else if((Price3(RealTradeDay(i))>Price3(RealTradeDay(i)+1)&&...
%                     L(RealTradeDay(i)-5)>Price3(RealTradeDay(i)+1)))%向下突破的条件判断
%                 if(RealTradeDay(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更行outputdata.orderlist向量
%                     outputdata.orderlist.direction=-1;
%                     outputdata.orderlist.price=0;
%                else 
%                    outputdata.record.direction(i)=-1;
%                end
%             end
%         end
%     else %当交点位置刚好为整数时
%         if((Price3(RealTradeDay(i)+1)>Price3(RealTradeDay(i)-1)&&...
%                Price3(RealTradeDay(i)+1)>H(RealTradeDay(i)-5)))%向上突破的条件判断
%            outputdata.record.direction(i)=1;
%         else if((Price3(RealTradeDay(i)-1)>Price3(RealTradeDay(i)+1)&&...
%                    L(RealTradeDay(i)-5)>Price3(RealTradeDay(i)+1)))%向下突破的条件判断
%                outputdata.record.direction(i)=-1;
%            end
%         end
%                end
% end
% cnt=1;
% for i=1:numel(Position3)
%     if (Price(1,Position3(i)+1)>Price(1,Position3(i))&&Price(1,Position3(i)+1)>Price(2,Position3(i)+1))
%        Position_a(cnt)=Position3(i);
%        cnt=cnt+1;
%     else if (Price(1,Position3(i)+1)<Price(1,Position3(i))&&Price(1,Position3(i)+1)<Price(2,Position3(i)+1))
%               Position_b(cnt)=Position3(i);
%        cnt=cnt+1;
%         end
%     end
% end
% Position_a(Position_a==0)=[];
% Position_b(Position_b==0)=[];
% Position_a=unique(sort(Position_a));
% Position_b=unique(sort(Position_b));
% Position_a(Position_a==0)=[];
% Position_b(Position_b==0)=[];
% Position_a=unique(sort(Position_a));
% Position_b=unique(sort(Position_b));
% for i=1:numel(RealTradeDay)
%     a=find(Trade==RealTradeDay(i));
%     b=find(Position_a==RealTradeDay(i));
%     c=find(Position_b==RealTradeDay(i));
%     b1=find(Position1==RealTradeDay(i));
%     c1=find(Position2==RealTradeDay(i));
%     if (a~=0)
%     if ((b~=0&b1~=0)|(b~=0&c1~=0))
%         d=mod(a,4);
%         if (d~=1&d~=3)
%             outputdata.record.direction(i)=0;
%         end
%     else if ((c~=0&b1~=0)|(c~=0&c1~=0))
%           d=mod(a,4);
%         if (d~=1&d~=3)
%             outputdata.record.direction(i)=0;
%         end
%         else
%                      d=mod(a,4);
%         if (d~=1&d~=3)
%             outputdata.record.direction(i)=0;
%         end 
%         end
%     end
%     else
%         outputdata.record.direction(i)=0;
%     end
% end
% for i=1:numel(Direction)
%     a=find(ForceTrade'==Direction(i));
%     b=find(Position1==Direction(i));
%     c=find(Position2==Direction(i));
%     if (a~=0)
%        outputdata.record.direction(i)=0;
%     else
%     if (b~=0)
%             outputdata.record.direction(i)=1;
%     else
%             outputdata.record.direction(i)=-1;
%     end
% 
%         end 
% end
%==========================================================================
%第一步矫正record,修改强制平仓价格以及当天的开仓价格
% for i=1:numel(ForceTrade)
%     PositionForceInTrade=find(Direction==ForceTrade(i));
%     if (PositionForceInTrade>1)
%         if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
%                 outputdata.orderlist.direction=1;
%                 outputdata.orderlist.price=0;
%         else
%             outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-1);
% %             outputdata.record.opdateprice(PositionForceInTrade)=inputdata.commodity.serialmkdata.op(ForceTrade(i)+2)+inputdata.commodity.serialmkdata.gap(ForceTrade(i)+2);
% %             outputdata.record.opdate1(PositionForceInTrade)=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2);
%         end
%     end
% end
% for i=1:numel(ForceTrade)
%     PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
%     if (PositionForceInTrade>1)
%         if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
% %                 outputdata.orderlist.direction=1;
%                 outputdata.orderlist.price=0;
%         else
% %             m=outputdata.record.direction(PositionForceInTrade-1:-1:1);
% %             n=find(m);
% %             if numel(n)~=0
% % %             outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade-n(1));
% %             outputdata.record.opdateprice(PositionForceInTrade)=inputdata.commodity.serialmkdata.op(ForceTrade(i)+2)+inputdata.commodity.serialmkdata.gap(ForceTrade(i)+2);
% %             outputdata.record.ctname1(PositionForceInTrade)=inputdata.commodity.serialmkdata.ctname(ForceTrade(i));
% %             outputdata.record.opdate1(PositionForceInTrade)=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2);
% %             else
% %             outputdata.record.direction(PositionForceInTrade)=outputdata.record.direction(PositionForceInTrade);
%             outputdata.record.opdateprice(PositionForceInTrade)=inputdata.commodity.serialmkdata.op(ForceTrade(i)+2)+inputdata.commodity.serialmkdata.gap(ForceTrade(i)+2);
%             outputdata.record.ctname(PositionForceInTrade)=inputdata.commodity.serialmkdata.ctname(ForceTrade(i));
%             outputdata.record.opdate(PositionForceInTrade)=inputdata.commodity.serialmkdata.date(ForceTrade(i)+2); 
%             end
%         end
% end
% % n=1;
% % for i=1:numel(outputdata.record.opdate1)
% %   if(~isempty(outputdata.record.opdate1{i}))
% %         outputdata.record.opdate{n}=outputdata.record.opdate1{i};
% %         n=n+1;
% %     end
% % end
for i=1:numel(ForceTrade)
    PositionForceInTrade=find(RealTradeDay==ForceTrade(i));
    if (PositionForceInTrade>1)
        if(ForceTrade(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
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
% n=1;
% for i=1:numel(outputdata.record.opdate1)
%   if(~isempty(outputdata.record.opdate1{i}))
%         outputdata.record.opdate{n}=outputdata.record.opdate1{i};
%         n=n+1;
%     end
% end
% 
% n=1;
% for i=1:numel(outputdata.record.cpdate1)
%   if(~isempty(outputdata.record.cpdate1{i}))
%         outputdata.record.cpdate{n}=outputdata.record.cpdate1{i};
%         n=n+1;
%     end
% end
% n=1;
% for i=1:numel(outputdata.record.ctname1)
%   if(~isempty(outputdata.record.ctname1{i}))
%         outputdata.record.ctname{n}=outputdata.record.ctname1{i};
%         n=n+1;
%     end
% end    
% outputdata.record.direction(outputdata.record.direction==0)=[];
% outputdata.record.cpdateprice(outputdata.record.cpdateprice==0)=[];
% outputdata.record.opdateprice(outputdata.record.opdateprice==0)=[];
%==========================================================================
% figure('Name',cell2mat(inputdata.commodity.name));
% plot(H')
% hold on
% plot(L','r')
% hold on
% plot(Price3(22:end)','g')
% plot(Price(1,:),'m');
% hold on;
% plot(Price(2,:),'k')
% hold off
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


