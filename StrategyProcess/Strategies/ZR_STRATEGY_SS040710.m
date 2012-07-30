function outputdata=ZR_STRATEGY_SS040710(inputdata)
% 四周突破策略
% l_temp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\MA60_l_inputdata.mat');
% inputdata=l_temp.l_inputdata;
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

outputdata.dailyinfo.date={};
outputdata.dailyinfo.trend=[];
%==========================================================================
l_dayhighprice=inputdata.commodity.serialmkdata.hp;
l_daylowprice=inputdata.commodity.serialmkdata.lp;
l_closeprice=inputdata.commodity.serialmkdata.cp;
%找到20天内的最高价和最低价
l_highprice=Inf*ones(1,numel(l_dayhighprice));     
l_lowprice=Inf*ones(1,numel(l_daylowprice));     
for l_id=1:numel(l_dayhighprice)
    if l_id>20
        l_highprice(l_id)=max(l_dayhighprice(l_id-20:l_id-1));
        l_lowprice(l_id)=min(l_daylowprice(l_id-20:l_id-1));
    end
end

l_diffprice1=l_highprice-l_closeprice';
l_signprice1=l_diffprice1(22:numel(l_diffprice1)).*l_diffprice1(21:numel(l_diffprice1)-1);
l_pos1=find(l_signprice1<0);%计算收盘价大于四周最高价的点的位置
l_posinter1=find(l_diffprice1==0);
l_postrade1=unique([l_pos1,l_posinter1]);

l_diffprice2=l_closeprice'-l_lowprice;
l_signprice2=l_diffprice2(22:numel(l_diffprice2)).*l_diffprice2(21:numel(l_diffprice2)-1);
l_pos2=find(l_signprice2<0);%计算收盘价低于四周最低价的点的位置
l_posinter2=find(l_diffprice2==0);
l_postrade2=unique([l_pos2,l_posinter2]);

l_signprice=[l_signprice1,l_signprice2];
l_postrade=unique([l_postrade1,l_postrade2]);                                   
%==========================================================================         

if isequal(zeros(numel(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend) %判断是否作为主策略或单一策略
    %在不考虑强制平仓的情况下寻找出需要交易的点
    l_cnt=1;%计数变量
    l_tradeday=zeros(1,numel(l_postrade));
    l_direction=zeros(1,numel(l_postrade));
    for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %判断此交点位置是否刚好为整数
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)+1)) %向上突破的条件判断
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=1;
                l_cnt=l_cnt+1;
            elseif(l_closeprice(l_postrade(l_posid)+1)<l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)+1)<l_lowprice(l_postrade(l_posid)+1)) %向下突破的条件判断
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=-1;
                l_cnt=l_cnt+1;
            end
        else %当交点位置刚好为整数时
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)-1)<l_highprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)+1)) %向上突破的条件判断
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=1;
                l_cnt=l_cnt+1;
            elseif(l_closeprice(l_postrade(l_posid)+1)<l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)-1)>l_lowprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)+1)<l_lowprice(l_postrade(l_posid)+1)) %向下突破的条件判断
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=-1;
                l_cnt=l_cnt+1;
            end
        end
    end
    l_tradeday(l_tradeday==0)=[];
    l_direction(l_direction==0)=[];
    %去除连续做多或做空的交易日期
    l_directionkey=l_direction(1);
    for l_id = 2:numel(l_tradeday)
        if l_direction(l_id)==l_directionkey
            l_tradeday(l_id)=-1;
        else
            l_directionkey=l_direction(l_id);
        end
    end
    l_tradeday(l_tradeday==-1)=[];
    l_realtradeday=unique(l_tradeday);
    %==========================================================================
    %更新record中的opdateprice,direction
    for l_tradeid=1:numel(l_realtradeday)
        if(l_signprice(l_realtradeday(l_tradeid))~=0) %判断此交点位置是否刚好为非整数
            if(l_closeprice(l_realtradeday(l_tradeid)+1)>l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)>l_highprice(l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            elseif(l_closeprice(l_realtradeday(l_tradeid)+1)<l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)<l_lowprice(l_realtradeday(l_tradeid)+1)) %向下突破的条件判断
                    if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                        outputdata.orderlist.direction=-1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                    else 
                        outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                        outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                        outputdata.record.direction(l_tradeid)=-1;
                    end
            end
        else %当交点位置刚好为整数时
            if(l_closeprice(l_realtradeday(l_tradeid)+1)>l_closeprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)-1)<l_highprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)>l_highprice(l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
            elseif(l_closeprice(l_realtradeday(l_tradeid)+1)<l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)-1)>l_lowprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)<l_lowprice(l_realtradeday(l_tradeid)+1)) %向下突破的条件判断
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                    outputdata.record.direction(l_tradeid)=-1;
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
    %======================================================================
    %填入dailyinfo信息
    outputdata.dailyinfo.date=inputdata.commodity.serialmkdata.date;
    outputdata.dailyinfo.trend=-Inf*ones(numel(inputdata.commodity.serialmkdata.date),1);
    for i = 1:numel(outputdata.record.direction)
        if outputdata.record.direction(i)==1
            outputdata.dailyinfo.trend(l_realtradeday(i)+1)=2;    %做多
        elseif outputdata.record.direction(i)==-1
            outputdata.dailyinfo.trend(l_realtradeday(i)+1)=1;    %做空
        end
    end
    if ~isempty(outputdata.orderlist)   %就交点在昨天和今天之间
        if outputdata.orderlist.direction==1
            outputdata.dailyinfo.trend(l_realtradeday(end))=2;
        elseif outputdata.orderlist.direction==-1
            outputdata.dailyinfo.trend(l_realtradeday(end))=1;
        end
    end
    l_trendIdx=find(outputdata.dailyinfo.trend~=-Inf);
    if ~isempty(l_trendIdx)
        if l_trendIdx(1)>1
            outputdata.dailyinfo.trend(1:l_trendIdx(1)-1)=4;    %不做
        else
            outputdata.dailyinfo.trend(1)=4;
        end
        l_trend=outputdata.dailyinfo.trend(l_trendIdx(1));      %填补空缺
        for i = l_trendIdx(1)+1:numel(outputdata.dailyinfo.trend)
            if outputdata.dailyinfo.trend(i)==-Inf
                outputdata.dailyinfo.trend(i)=l_trend;
            else
                l_trend=outputdata.dailyinfo.trend(i);
            end
        end
    end
    %======================================================================
else        %否则作为次策略，决定真正交易日期
    %在不考虑强制平仓的情况下寻找出需要交易的点
    l_cnt=1;%计数变量
    l_tradeday=zeros(1,numel(l_postrade));
    l_direction=zeros(1,numel(l_postrade));
    for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %判断此交点位置是否刚好为整数
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)+1)) %向上突破的条件判断
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==2
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
                end
            elseif(l_closeprice(l_postrade(l_posid)+1)<l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)+1)<l_lowprice(l_postrade(l_posid)+1)) %向下突破的条件判断
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==1
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=-1;
                    l_cnt=l_cnt+1;
                end
            end
        else %当交点位置刚好为整数时
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)-1)<l_highprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)+1)) %向上突破的条件判断
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==2
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
                end
            elseif(l_closeprice(l_postrade(l_posid)+1)<l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)-1)>l_lowprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)+1)<l_lowprice(l_postrade(l_posid)+1)) %向下突破的条件判断
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==1
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=-1;
                    l_cnt=l_cnt+1;
                end
            end
        end
    end
    l_tradeday(l_tradeday==0)=[];
    l_direction(l_direction==0)=[];
    %去除连续做多或做空的交易日期
    l_directionkey=l_direction(1);
    for l_id = 2:numel(l_tradeday)
        if l_direction(l_id)==l_directionkey
            l_tradeday(l_id)=-1;
        else
            l_directionkey=l_direction(l_id);
        end
    end
    l_tradeday(l_tradeday==-1)=[];
    l_realtradeday=unique(l_tradeday);
    %==========================================================================
    %更新record中的opdateprice,direction
    for l_tradeid=1:numel(l_realtradeday)
        if(l_signprice(l_realtradeday(l_tradeid))~=0) %判断此交点位置是否刚好为非整数
            if(l_closeprice(l_realtradeday(l_tradeid)+1)>l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)>l_highprice(l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            elseif(l_closeprice(l_realtradeday(l_tradeid)+1)<l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)<l_lowprice(l_realtradeday(l_tradeid)+1)) %向下突破的条件判断
                    if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                        outputdata.orderlist.direction=-1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                    else 
                        outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                        outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                        outputdata.record.direction(l_tradeid)=-1;
                    end
            end
        else %当交点位置刚好为整数时
            if(l_closeprice(l_realtradeday(l_tradeid)+1)>l_closeprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)-1)<l_highprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)>l_highprice(l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
            elseif(l_closeprice(l_realtradeday(l_tradeid)+1)<l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)-1)>l_lowprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)<l_lowprice(l_realtradeday(l_tradeid)+1)) %向下突破的条件判断
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                    outputdata.record.direction(l_tradeid)=-1;
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
    %======================================================================
    % 填入dailyinfo信息
    outputdata.dailyinfo.date=inputdata.commodity.dailyinfo.date;
    outputdata.dailyinfo.trend=inputdata.commodity.dailyinfo.trend; % 待修改
end 
 

%==========================================================================
%填入连续的交易日期和趋势方向
% outputdata.dailyinfo.date=inputdata.commodity.serialmkdata.date;
% for i = 1:numel(outputdata.dailyinfo.date)
%     DateID=find(ismember(outputdata.record.opdate,outputdata.dailyinfo.date(i))==1);
%     if ~isempty(DateID)
%         outputdata.dailyinfo.trend(i)=outputdata.record.direction(DateID);
%     else
%         outputdata.dailyinfo.trend(i)=0;
%     end
% end
% outputdata.dailyinfo.trend=outputdata.dailyinfo.trend';



