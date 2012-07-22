function outputdata=ZR_STRATEGY_S040710(inputdata)
% 四周突破策略
% tmp=load('FWRa.mat');
% inputdata=tmp.l_inputdata;
%==========================================================================
% 输出变量初始化操作
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
l_dayhighprice=inputdata.commodity.serialmkdata.hp;
l_daylowprice=inputdata.commodity.serialmkdata.lp;
l_closeprice=inputdata.commodity.serialmkdata.cp;
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','A');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','B');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','C');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','D');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','E');
%==========================================================================
%找到20天内的最高价和最低价
for l_id=1:(numel(l_dayhighprice)-21)
    l_highprice(l_id)=max(l_dayhighprice(l_id:l_id+20));
    l_lowprice(l_id)=min(l_daylowprice(l_id:l_id+20));
end
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',l_highprice','Sheet1','F22:F2484');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',l_lowprice','Sheet1','G22:G2484');
l_diffprice1=l_highprice-l_closeprice(22:end)';
l_signprice1=l_diffprice1(2:numel(l_diffprice1)).*l_diffprice1(1:numel(l_diffprice1)-1);
l_pos1=find(l_signprice1<0);%计算收盘价大于四周最高价的点的位置
l_posinter1=find(l_diffprice1==0);

l_diffprice2=l_closeprice(22:end)'-l_lowprice;
l_signprice2=l_diffprice2(2:numel(l_diffprice2)).*l_diffprice2(1:numel(l_diffprice2)-1);
l_pos2=find(l_signprice2<0);%计算收盘价低于四周最低价的点的位置
l_posinter2=find(l_diffprice2==0);

l_signprice=[l_signprice1,l_signprice2];
l_signprice=sort(l_signprice);
l_pos=[l_pos1,l_pos2]+21;
l_pos=sort(l_pos);
l_posinter=[l_posinter1,l_posinter2]+21;
l_posinter=sort(l_posinter);

l_postrade=[l_pos,l_posinter];
l_postrade=unique(sort(l_postrade));
%==========================================================================
%在不考虑强制平仓的情况下寻找出需要交易的点
for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %判断此交点位置是否刚好为整数
        if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid))&&...
                l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)-20))%向上突破的条件判断
                TradeDay1(l_posid)=l_postrade(l_posid);
        else if(l_closeprice(l_postrade(l_posid))>l_closeprice(l_postrade(l_posid)+1)&&...
                    l_lowprice(l_postrade(l_posid)-20)>l_closeprice(l_postrade(l_posid)+1))%向下突破的条件判断
                    TradeDay1(l_posid)=l_postrade(l_posid);
            else
                TradeDay1(l_posid)=0;
            end
        end
    else %当交点位置刚好为整数时
        if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid))&&...
                l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)-20)) %向上突破的条件判断
            TradeDay1(l_posid)=l_postrade(l_posid);
        else if (l_closeprice(l_postrade(l_posid))>l_closeprice(l_postrade(l_posid)+1)&&...
                   l_lowprice(l_postrade(l_posid)-20)>l_closeprice(l_postrade(l_posid)+1))%向下突破的条件判断
                TradeDay1(l_posid)=l_postrade(l_posid);
            else
                TradeDay1(l_posid)=0;
            end
        end
end 
    if TradeDay1(l_posid)~=0
        break
    end
end
TradeDay(1)=TradeDay1(end);
Cnt=2;%计数变量
for l_id=2:numel(l_postrade)
        if(l_signprice(l_postrade(l_id))~=0) %判断此交点位置是否刚好为整数
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_id))&&...
                l_closeprice(l_postrade(l_id)+1)>l_highprice(l_postrade(l_id)-20)&&...
                l_closeprice(TradeDay(l_id-1))>l_closeprice(TradeDay(l_id-1)+1)&&l_lowprice(TradeDay(l_id-1)-20)>l_closeprice(TradeDay(l_id-1)+1))%向上突破的条件判断
                TradeDay(Cnt)=l_postrade(l_id);
                Cnt=Cnt+1;
            elseif(l_closeprice(l_postrade(l_id))>l_closeprice(l_postrade(l_id)+1)&&...
                    l_lowprice(l_postrade(l_id)-20)>l_closeprice(l_postrade(l_id)+1)&&...
                    l_closeprice(TradeDay(l_id-1)+1)>l_closeprice(TradeDay(l_id-1)) &&l_closeprice(TradeDay(l_id-1)+1)>l_highprice(TradeDay(l_id-1)-20))%向下突破的条件判断
                    TradeDay(Cnt)=l_postrade(l_id);
                    Cnt=Cnt+1;
            else
                TradeDay(Cnt)=TradeDay(l_id-1);
                Cnt=Cnt+1;
            end
        else %当交点位置刚好为整数时
            if(l_closeprice(l_postrade(l_id)+1)>l_closeprice(l_postrade(l_id)-1)&&...
                l_closeprice(l_postrade(l_id)+1)>l_highprice(l_postrade(l_id)-21)&&...
                l_closeprice(TradeDay(l_id-1)-1)>l_closeprice(TradeDay(l_id-1)+1)&&l_lowprice(TradeDay(l_id-1)-21)>l_closeprice(TradeDay(l_id-1)+1)) %向上突破的条件判断
                TradeDay(Cnt)=l_postrade(l_id);
                Cnt=Cnt+1;
            elseif (l_closeprice(l_postrade(l_id)-1)>l_closeprice(l_postrade(l_id)+1)&&...
                   l_lowprice(l_postrade(l_id)-21)>l_closeprice(l_postrade(l_id)+1)&&...
                    l_closeprice(TradeDay(l_id-1)+1)>l_closeprice(TradeDay(l_id-1)-1)&&l_closeprice(TradeDay(l_id-1)+1)>l_highprice(TradeDay(l_id-1)-21))%向下突破的条件判断
                TradeDay(Cnt)=l_postrade(l_id);
                Cnt=Cnt+1;
            else
                TradeDay(Cnt)=TradeDay(l_id-1);
                Cnt=Cnt+1;
            end
        end
end
RealTradeDay=unique(TradeDay);
%==========================================================================
%更新record中的opdateprice,direction
for l_tradeid=1:numel(RealTradeDay)
    if(l_signprice(RealTradeDay(l_tradeid))~=0) %判断此交点位置是否刚好为非整数
        if(l_closeprice(RealTradeDay(l_tradeid)+1)>l_closeprice(RealTradeDay(l_tradeid))&&...
                l_closeprice(RealTradeDay(l_tradeid)+1)>l_highprice(RealTradeDay(l_tradeid)-20)) %向上突破的条件判断
            if(RealTradeDay(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
            else
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(RealTradeDay(l_tradeid)+2); %计算出交易记录
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(RealTradeDay(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(l_tradeid)+2);
                outputdata.record.direction(l_tradeid)=1;
            end
        elseif(l_closeprice(RealTradeDay(l_tradeid))>l_closeprice(RealTradeDay(l_tradeid)+1)&&...
                    l_closeprice(RealTradeDay(l_tradeid)+1)<l_lowprice(RealTradeDay(l_tradeid)-20)) %向下突破的条件判断
                if(RealTradeDay(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更行outputdata.orderlist向量
                    outputdata.orderlist.direction=-1;
                    outputdata.orderlist.price=0;
                else 
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(RealTradeDay(l_tradeid)+2); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(RealTradeDay(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=-1;
                end
        end
    else %当交点位置刚好为整数时
        if(l_closeprice(RealTradeDay(l_tradeid)+1)>l_closeprice(RealTradeDay(l_tradeid)-1)&&...
                l_closeprice(RealTradeDay(l_tradeid)+1)>l_highprice(RealTradeDay(l_tradeid)-20)) %向上突破的条件判断
            outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(RealTradeDay(l_tradeid)+1);
            outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(RealTradeDay(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(l_tradeid)+1);
            outputdata.record.direction(l_tradeid)=1;
        elseif(l_closeprice(RealTradeDay(l_tradeid)+1)<l_closeprice(RealTradeDay(l_tradeid)-1)&&... 
                    l_closeprice(RealTradeDay(l_tradeid)+1)<l_lowprice(RealTradeDay(l_tradeid)-20)) %向下突破的条件判断
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(RealTradeDay(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(RealTradeDay(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=-1;
        end
    end   
    outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(l_tradeid)+1);
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



