function outputdata=ZR_STRATEGY_040709(inputdata)
% 60天均线策略
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
%算出60天均线
l_day60=zeros(1,inputdata.strategyparams.ma)+1;%计算平均数的算子                                                                                                                                                                                                                         
l_mean60buff=conv(inputdata.commodity.serialmkdata.cp,l_day60)/inputdata.strategyparams.ma;%卷积求解
l_price(1,:)=inputdata.commodity.serialmkdata.cp;
l_price(2,:)=l_mean60buff(1:numel(inputdata.commodity.serialmkdata.cp));
%==========================================================================
figure('Name',strcat('040709',cell2mat(inputdata.commodity.name)));
plot(l_price(1,:),'-r*');
hold on;
plot(l_price(2,:),'-b+');
legend('Cp','MA60',2);
hold off;
%==========================================================================
%以异号为原则寻找交叉点，并将寻找到的异号点存入数组PositionTrade中
l_diffprice=l_price(2,:)-l_price(1,:);                                    
l_signprice=l_diffprice(2:numel(l_diffprice)).*l_diffprice(1:numel(l_diffprice)-1);
l_pos=find(l_signprice<0);%交点位置记录为实际交点的前一个点,当前点
l_posinter=find(l_diffprice==0);

l_postrade=[l_pos,l_posinter];
l_postrade=unique(l_postrade);                                             
%==========================================================================         

if isequal(zeros(numel(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend) %判断是否作为主策略或单一策略
    %在不考虑强制平仓的情况下寻找出需要交易的日期
    l_cnt=1;  %计数变量
    l_tradeday=zeros(1,numel(l_postrade));
    l_direction=zeros(1,numel(l_postrade));
    for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %判断此交点位置是否刚好为整数
            if(l_price(2,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)) &&...   %MA均线上升
                    l_price(1,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)+1) && l_price(1,l_postrade(l_posid))<l_price(2,l_postrade(l_posid))) %cp向上突破MA
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=1;
                l_cnt=l_cnt+1;
            elseif(l_price(2,l_postrade(l_posid))>l_price(2,l_postrade(l_posid)+1) &&...    %MA均线下降
                    l_price(1,l_postrade(l_posid))>l_price(2,l_postrade(l_posid)) && l_price(1,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1)) %cp向下突破MA
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=-1;
                l_cnt=l_cnt+1;
            end
        else %当交点位置刚好为整数时
            if(l_price(2,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)-1) &&...   %MA均线上升
                    l_price(1,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)+1) && l_price(1,l_postrade(l_posid)-1)<l_price(2,l_postrade(l_posid)-1)) %cp向上突破MA
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=1;
                l_cnt=l_cnt+1;
            elseif(l_price(2,l_postrade(l_posid)-1)>l_price(2,l_postrade(l_posid)+1) &&...    %MA均线下降
                    l_price(1,l_postrade(l_posid)-1)>l_price(2,l_postrade(l_posid)-1) && l_price(1,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1)) %cp向下突破MA
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=-1;
                l_cnt=l_cnt+1;
            end
        end   
    end
    l_tradeday(l_tradeday==0)=[];
    l_direction(l_direction==0)=[];
    %剔除连续做多或做空的交易日
    if isempty(l_direction)
        return;
    end
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
            if(l_price(2,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)) ... 
                    && l_price(1,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            elseif(l_price(2,l_realtradeday(l_tradeid))>l_price(2,l_realtradeday(l_tradeid)+1) ...
                        && l_price(1,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1)) %向下突破的条件判断
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
            if(l_price(2,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)-1) ...
                    && l_price(1,l_realtradeday(l_tradeid)-1)<l_price(2,l_realtradeday(l_tradeid)-1) && l_price(1,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
            elseif(l_price(2,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)-1) ... 
                        && l_price(1,l_realtradeday(l_tradeid)-1)>l_price(2,l_realtradeday(l_tradeid)-1) && l_price(1,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1)) %向下突破的条件判断
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
else                %否则作为次策略，决定真正交易日期
    %在不考虑强制平仓的情况下寻找出需要交易的日期
    l_cnt=1;  %计数变量
    l_tradeday=zeros(1,numel(l_postrade));
    l_direction=zeros(1,numel(l_postrade));
    for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %判断此交点位置是否刚好为整数
            if(l_price(2,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)) &&...   %MA均线上升
                    l_price(1,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)+1) && l_price(1,l_postrade(l_posid))<l_price(2,l_postrade(l_posid))) %cp向上突破MA
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid))==2
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
                end
            elseif(l_price(2,l_postrade(l_posid))>l_price(2,l_postrade(l_posid)+1) &&...    %MA均线下降
                    l_price(1,l_postrade(l_posid))>l_price(2,l_postrade(l_posid)) && l_price(1,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1)) %cp向下突破MA
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid))==1
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=-1;
                    l_cnt=l_cnt+1;
                end
            end
        else %当交点位置刚好为整数时
            if(l_price(2,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)-1) &&...   %MA均线上升
                    l_price(1,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)+1) && l_price(1,l_postrade(l_posid)-1)<l_price(2,l_postrade(l_posid)-1)) %cp向上突破MA
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid))==2
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
                end
            elseif(l_price(2,l_postrade(l_posid)-1)>l_price(2,l_postrade(l_posid)+1) &&...    %MA均线下降
                    l_price(1,l_postrade(l_posid)-1)>l_price(2,l_postrade(l_posid)-1) && l_price(1,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1)) %cp向下突破MA
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid))==1
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=-1;
                    l_cnt=l_cnt+1;
                end
            end
        end   
    end
    l_tradeday(l_tradeday==0)=[];
    l_direction(l_direction==0)=[];
    %剔除连续做多或做空的交易日
    if isempty(l_direction)
        return;
    end
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
            if(l_price(2,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)) ... 
                    && l_price(1,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            elseif(l_price(2,l_realtradeday(l_tradeid))>l_price(2,l_realtradeday(l_tradeid)+1) ...
                        && l_price(1,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1)) %向下突破的条件判断
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
            if(l_price(2,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)-1) ...
                    && l_price(1,l_realtradeday(l_tradeid)-1)<l_price(2,l_realtradeday(l_tradeid)-1) && l_price(1,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)+1)) %向上突破的条件判断
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
            elseif(l_price(2,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)-1) ... 
                        && l_price(1,l_realtradeday(l_tradeid)-1)>l_price(2,l_realtradeday(l_tradeid)-1) && l_price(1,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1)) %向下突破的条件判断
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



