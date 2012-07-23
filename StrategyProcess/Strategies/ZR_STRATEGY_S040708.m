function outputdata=ZR_STRATEGY_S040708(inputdata)
% tmp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\RSIRO.mat');
% inputdata=tmp.l_inputdata;
%==========================================================================
%输出变量初始化操作
outputdata.orderlist.price=[];
outputdata.orderlist.direction=[];
outputdata.orderlist.name={};
outputdata.record.opdate={};
outputdata.record.opdateprice=[];
outputdata.record.cpdate={};
outputdata.record.cpdateprice=[];
outputdata.record.isclosepos=[];
outputdata.record.direction=[];
outputdata.record.ctname={};
%==========================================================================
%计算出KDJ曲线
outReal=TA_RSI(inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.D);
l_price(1,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*80;
l_price(2,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*20;
l_price(3,:)=outReal;%整理平均数计算结果放入数组Price中
l_price(l_price==0)=inf;
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',outReal,'Sheet1','M');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','H');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','I');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','J');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','K');
% xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','L');
%==========================================================================
%以异号为原则寻找交叉点，并将寻找到的异号点存入数组PositionTrade中
l_diffprice1=l_price(2,:)-l_price(3,:);
l_signprice1=l_diffprice1(2:numel(l_diffprice1)).*l_diffprice1(1:numel(l_diffprice1)-1);
l_pos1=find(l_signprice1<0);%计算小于20的点的位置
l_posinter1=find(l_diffprice1==0);

l_diffprice2=l_price(3,:)-l_price(1,:);
l_signprice2=l_diffprice2(2:numel(l_diffprice2)).*l_diffprice2(1:numel(l_diffprice2)-1);
l_pos2=find(l_signprice2<0);%计算大于80的点的位置
l_posinter2=find(l_diffprice2==0);

l_signprice=[l_signprice1,l_signprice2];
l_signprice=sort(l_signprice);
l_pos=[l_pos1,l_pos2];
l_pos=sort(l_pos);
l_pos(1:1)=[];
l_posinter=[l_posinter1,l_posinter2];
l_posinter=sort(l_posinter);

% CntName=char(inputdata.commodity.serialmkdata.ctname);%计算移仓点
% DiffCntNme=CntName(2:end,:)-CntName(1:size(CntName,1)-1,:);
% [PosChaDay,a]=find(DiffCntNme~=0);
% PosChaDay=sort(PosChaDay);
% PosChaDay(PosChaDay<=(l_pos(1)))=[];
% ForceTrade=unique(PosChaDay); %单个合约的最后一天

l_postrade=[l_pos,l_posinter];
l_postrade=unique(sort(l_postrade));
%==========================================================================
%在不考虑强制平仓的情况下寻找出需要交易的点
Cnt=2;%计数变量
l_tradeday=[];
 if(l_signprice(l_postrade(1))~=0) %判断此交点位置是否刚好为整数
        if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %向上突破的条件判断
                l_tradeday(1)=l_postrade(1);
        else if(l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%向下突破的条件判断
                    l_tradeday(1)=l_postrade(1);
            end
        end
 else %当交点位置刚好为整数时
        if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %向上突破的条件判断
            l_tradeday(1)=l_postrade(1);
        else if (l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%向下突破的条件判断
                l_tradeday(1)=l_postrade(1);
            end
        end
 end
for i=2:numel(l_postrade)
    if(l_signprice(l_postrade(i))~=0) %判断此交点位置是否刚好为整数
        if(l_price(3,l_postrade(i)+1)>l_price(3,l_postrade(i)) && l_price(3,l_postrade(i)+1)>l_price(1,l_postrade(i)+1))&&...
                (l_price(3,l_tradeday(i-1))>l_price(3,l_tradeday(i-1)+1)&&l_price(2,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)+1)) %向上突破的条件判断
                l_tradeday(Cnt)=l_postrade(i);
                Cnt=Cnt+1;
        else if(l_price(3,l_postrade(i))>l_price(3,l_postrade(i)+1)&&l_price(2,l_postrade(i)+1)>l_price(3,l_postrade(i)+1))&&...
                    (l_price(3,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)) && l_price(3,l_tradeday(i-1)+1)>l_price(1,l_tradeday(i-1)+1))%向下突破的条件判断
                    l_tradeday(Cnt)=l_postrade(i);
                    Cnt=Cnt+1;
            else
                l_tradeday(Cnt)=l_tradeday(i-1);
                Cnt=Cnt+1;
            end
        end
    else %当交点位置刚好为整数时
        if(l_price(3,l_postrade(i)+1)>l_price(3,l_postrade(i)) && l_price(3,l_postrade(i)+1)>l_price(1,l_postrade(i)+1))&&...
                (l_price(3,l_tradeday(i-1))>l_price(3,l_tradeday(i-1)+1)&&l_price(2,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)+1)) %向上突破的条件判断
            l_tradeday(Cnt)=l_postrade(i);
            Cnt=Cnt+1;
        else if (l_price(3,l_postrade(i))>l_price(3,l_postrade(i)+1)&&l_price(2,l_postrade(i)+1)>l_price(3,l_postrade(i)+1))&&...
                    (l_price(3,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)) && l_price(3,l_tradeday(i-1)+1)>l_price(1,l_tradeday(i-1)+1))%向下突破的条件判断
                l_tradeday(Cnt)=l_postrade(i);
                Cnt=Cnt+1;
            else
                l_tradeday(Cnt)=l_tradeday(i-1);
                Cnt=Cnt+1;
            end
        end
    end   
end
%==========================================================================
%合并交易日期和强制平仓日期,此时这些时间必须有交易的发生
% l_tradeday=unique(l_tradeday);
% RealTradeDayBuff=[l_tradeday,ForceTrade'];
% RealTradeDayBuff=sort(RealTradeDayBuff);
% l_realtradeday=unique(RealTradeDayBuff);
l_realtradeday=unique(l_tradeday);
%==========================================================================
%更新record中的opdateprice,direction
for i=1:numel(l_realtradeday)
    if(l_signprice(l_realtradeday(i))~=0) %判断此交点位置是否刚好为非整数
        if(l_price(3,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)) && l_price(3,l_realtradeday(i)+1)>l_price(1,l_realtradeday(i)+1))%向上突破的条件判断
            if(l_realtradeday(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=-1;
                outputdata.orderlist.price=0;
                outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
            else
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+2); %计算出交易记录
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+2);
                outputdata.record.direction(i)=-1;
            end
        else if (l_price(3,l_realtradeday(i))>l_price(3,l_realtradeday(i)+1)&&l_price(2,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)+1))%向下突破的条件判断
                if(l_realtradeday(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
                else 
                    outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+2); %计算出交易记录
                    outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+2);
                    outputdata.record.direction(i)=1;
                end
            end
        end
    else %当交点位置刚好为整数时
        if(l_price(3,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)) && l_price(3,l_realtradeday(i)+1)>l_price(1,l_realtradeday(i)+1))%向上突破的条件判断
            outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+1);
            outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+1);
            outputdata.record.direction(i)=-1;
        else if (l_price(3,l_realtradeday(i))>l_price(3,l_realtradeday(i)+1)&&l_price(2,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)+1))%向下突破的条件判断
                outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+1);
                outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+1);
                outputdata.record.direction(i)=1;
            end
        end
    end   
    outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
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


