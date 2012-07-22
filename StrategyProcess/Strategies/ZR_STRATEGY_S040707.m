function outputdata=ZR_STRATEGY_S040707(inputdata)
% tmp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\KDJDl.mat');
% inputdata=tmp.l_inputdata;
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
%计算出KDJ曲线
[outSlowK,outSlowD] = TA_STOCH (inputdata.commodity.serialmkdata.hp,inputdata.commodity.serialmkdata.lp,inputdata.commodity.serialmkdata.cp, ...
    inputdata.strategyparams.K,inputdata.strategyparams.D,0,inputdata.strategyparams.J,0);
l_price(1,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*80;
l_price(2,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*20;
l_price(3,:)=outSlowD;%整理平均数计算结果放入数组Price中
l_price(l_price==0)=inf;
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',outSlowD,'Sheet1','M');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','H');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','I');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','J');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','K');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','L');
%==========================================================================
%以异号为原则寻找交叉点，并将寻找到的异号点存入数组PositionTrade中
l_lowdiffprice=l_price(2,:)-l_price(3,:);
l_lowsignprice=l_lowdiffprice(2:numel(l_lowdiffprice)).*l_lowdiffprice(1:numel(l_lowdiffprice)-1);
l_lowpos=find(l_lowsignprice<0);%计算小于20的点的位置
l_lowposinter=find(l_lowdiffprice==0);
% PositionTrade1=unique([l_lowpos,l_lowposinter]);

l_highdiffprice=l_price(3,:)-l_price(1,:);
l_highsignprice=l_highdiffprice(2:numel(l_highdiffprice)).*l_highdiffprice(1:numel(l_highdiffprice)-1);
l_highpos=find(l_highsignprice<0);%计算大于80的点的位置
l_highposinter=find(l_highdiffprice==0);
% PositionTrade2=unique([l_highpos,l_highposinter]);

% l_signprice=unique([l_lowsignprice,l_highsignprice]);
% l_postrade=unique([PositionTrade1,PositionTrade2]);

l_signprice=[l_lowsignprice,l_highsignprice];
l_signprice=sort(l_signprice);
l_pos=[l_lowpos,l_highpos];
l_pos=sort(l_pos);
l_pos(1:1)=[];
l_posinter=[l_lowposinter,l_highposinter];
l_posinter=sort(l_posinter);

l_postrade=[l_pos,l_posinter];
l_postrade=unique(sort(l_postrade));
%==========================================================================
%在不考虑强制平仓的情况下寻找出需要交易的点
Cnt=2;%计数变量
l_tradeday=[];
if(l_signprice(l_postrade(1))~=0) %判断此交点位置是否刚好为整数
        if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %向上突破的条件判断
                l_tradeday(1)=l_postrade(1);
        elseif(l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%向下突破的条件判断
                    l_tradeday(1)=l_postrade(1);
        end
else %当交点位置刚好为整数时
        if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %向上突破的条件判断
            l_tradeday(1)=l_postrade(1);
        elseif (l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%向下突破的条件判断
                l_tradeday(1)=l_postrade(1);
        end
end
for l_posid=2:numel(l_postrade)
    if(l_signprice(l_postrade(l_posid))~=0) %判断此交点位置是否刚好为整数
        if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)) && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1))&&...
                (l_price(3,l_tradeday(l_posid-1))>l_price(3,l_tradeday(l_posid-1)+1)&&l_price(2,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)+1)) %向上突破的条件判断
                l_tradeday(Cnt)=l_postrade(l_posid);
                Cnt=Cnt+1;
        elseif(l_price(3,l_postrade(l_posid))>l_price(3,l_postrade(l_posid)+1)&&l_price(2,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)) && l_price(3,l_tradeday(l_posid-1)+1)>l_price(1,l_tradeday(l_posid-1)+1))%向下突破的条件判断
                    l_tradeday(Cnt)=l_postrade(l_posid);
                    Cnt=Cnt+1;
        else
                l_tradeday(Cnt)=l_tradeday(l_posid-1);
                Cnt=Cnt+1;
        end
    else %当交点位置刚好为整数时
        if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)) && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1))&&...
                (l_price(3,l_tradeday(l_posid-1))>l_price(3,l_tradeday(l_posid-1)+1)&&l_price(2,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)+1)) %向上突破的条件判断
            l_tradeday(Cnt)=l_postrade(l_posid);
            Cnt=Cnt+1;
        elseif (l_price(3,l_postrade(l_posid))>l_price(3,l_postrade(l_posid)+1)&&l_price(2,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)) && l_price(3,l_tradeday(l_posid-1)+1)>l_price(1,l_tradeday(l_posid-1)+1))%向下突破的条件判断
                l_tradeday(Cnt)=l_postrade(l_posid);
                Cnt=Cnt+1;
        else
                l_tradeday(Cnt)=l_tradeday(l_posid-1);
                Cnt=Cnt+1;
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
for l_tradeid=1:numel(l_realtradeday)
    if(l_signprice(l_realtradeday(l_tradeid))~=0) %判断此交点位置是否刚好为非整数
        if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
            if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=-1;
                outputdata.orderlist.price=0;
            else
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                outputdata.record.direction(l_tradeid)=-1;
            end
        elseif(l_price(3,l_realtradeday(l_tradeid))>l_price(3,l_realtradeday(l_tradeid)+1)&&l_price(2,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)+1))%向下突破的条件判断
            if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
            else 
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
            end
        end
    else %当交点位置刚好为整数时
        if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1))%向上突破的条件判断
            outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
            outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
            outputdata.record.direction(l_tradeid)=-1;
        elseif(l_price(3,l_realtradeday(l_tradeid))>l_price(3,l_realtradeday(l_tradeid)+1)&&l_price(2,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)+1))%向下突破的条件判断
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
        end
    end   
    outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
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


