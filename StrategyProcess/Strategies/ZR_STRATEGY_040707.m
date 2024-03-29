function outputdata=ZR_STRATEGY_040707(inputdata)
% D值（KDJ）策略
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
%计算出KDJ曲线
[outSlowK,outSlowD] = TA_STOCH (inputdata.commodity.serialmkdata.hp,inputdata.commodity.serialmkdata.lp,inputdata.commodity.serialmkdata.cp, ...
    inputdata.strategyparams.K,inputdata.strategyparams.D,0,inputdata.strategyparams.J,0);
l_price(1,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*80;
l_price(2,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*20;
l_price(3,:)=outSlowD;%整理平均数计算结果放入数组Price中
l_price(l_price==0)=Inf;
%==========================================================================
% figure('Name',strcat('040707',cell2mat(inputdata.commodity.name)));
% plot(l_price(1,:),'-b');
% hold on;
% plot(l_price(2,:),'-g');
% hold on;
% plot(l_price(3,:),'-r*');
% axis([1 numel(inputdata.commodity.serialmkdata.cp) -170 170]);
% legend('80H','20L','D',2);
% hold off;
%==========================================================================
%以异号为原则寻找交叉点，并将寻找到的异号点存入数组PositionTrade中
l_diffprice1=l_price(2,:)-l_price(3,:);
l_signprice1=l_diffprice1(2:numel(l_diffprice1)).*l_diffprice1(1:numel(l_diffprice1)-1);
l_pos1=find(l_signprice1<0);%计算小于20的点的位置
l_position1=find(l_diffprice1==0);
l_position1(l_position1==length(l_price(1,:)))=[];
l_posinter1=[l_pos1,l_position1];
l_diffprice2=l_price(3,:)-l_price(1,:);
l_signprice2=l_diffprice2(2:numel(l_diffprice2)).*l_diffprice2(1:numel(l_diffprice2)-1);
l_pos2=find(l_signprice2<0);%计算大于80的点的位置
l_position2=find(l_diffprice2==0);
l_position2(l_position2==length(l_price(1,:)))=[];
l_posinter2=[l_pos2,l_position2];
% l_signprice=[l_signprice1,l_signprice2];
% l_signprice=sort(l_signprice);
l_pos=[l_pos1,l_pos2];
l_pos=sort(l_pos);
l_pos(1:1)=[];
l_posinter=[l_posinter1,l_posinter2];
l_posinter=sort(l_posinter);

l_postrade=[l_pos,l_posinter];
l_postrade=unique(sort(l_postrade));                                             
%==========================================================================         

if isequal(zeros(numel(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend) %判断是否作为主策略或单一策略
    %在不考虑强制平仓的情况下寻找出需要交易的点
%     l_tradeday(1)=l_postrade(1);
    l_cnt=2;%计数变量
for i=1:numel(l_postrade)
    l_a1=find(l_posinter1==l_postrade(i));
    l_a2=find(l_posinter2==l_postrade(i));
  if l_a1~=0
     if(l_signprice1(l_postrade(i))~=0) %判断此交点位置是否刚好为整数
            if(l_price(3,l_postrade(i)+1)<l_price(3,l_postrade(i)) && l_price(3,l_postrade(i)+1)<l_price(2,l_postrade(i)+1)) %向下突破20的条件判断
                    l_tradeday(1)=l_postrade(i);
                    break
            end
     else 
        if(l_price(3,l_postrade(i)+1)<l_price(3,l_postrade(i)-1) && l_price(3,l_postrade(i)+1)<l_price(2,l_postrade(i)+1)) %向下突破20的条件判断
         l_tradeday(1)=l_postrade(i);
          break
        end
     end
  else if l_a2~=0
           if(l_price(3,l_postrade(i))<l_price(3,l_postrade(i)+1)&&l_price(1,l_postrade(i)+1)<l_price(3,l_postrade(i)+1))%向上突破80的条件判断
                        l_tradeday(1)=l_postrade(i);
                        break
           end
      else
          if(l_price(3,l_postrade(i))<l_price(3,l_postrade(i)+1)&&l_price(1,l_postrade(i)+1)<l_price(3,l_postrade(i)+1))%向上突破80的条件判断
           l_tradeday(1)=l_postrade(i);
          break
           end
      end
  end
end
l_pos1=find(l_postrade==l_tradeday(1));
    for l_posid=(l_pos1+1):numel(l_postrade)
    l_a1=find(l_posinter1==l_postrade(l_posid));
    l_a2=find(l_posinter2==l_postrade(l_posid));
    if l_a1~=0
        if(l_signprice1(l_postrade(l_posid))~=0) %判断此交点位置是否刚好为整数
            if(l_price(3,l_postrade(l_posid)+1)<l_price(3,l_postrade(l_posid)) && l_price(3,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_cnt-1))<l_price(3,l_tradeday(l_cnt-1)+1)&&l_price(1,l_tradeday(l_cnt-1)+1)<l_price(3,l_tradeday(l_cnt-1)+1)) %向上突破的条件判断
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_cnt=l_cnt+1;
            else
                l_tradeday(l_cnt)=l_tradeday(l_cnt-1);
                l_cnt=l_cnt+1;
            end
        else
            if(l_price(3,l_postrade(l_posid)+1)<l_price(3,l_postrade(l_posid)-1) && l_price(3,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_cnt-1))<l_price(3,l_tradeday(l_cnt-1)+1)&&l_price(1,l_tradeday(l_cnt-1)+1)<l_price(3,l_tradeday(l_cnt-1)+1)) %向上突破的条件判断
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_cnt=l_cnt+1;
            else
                l_tradeday(l_cnt)=l_tradeday(l_cnt-1);
                l_cnt=l_cnt+1;
            end
        end
    elseif l_a2~=0
            if(l_signprice2(l_postrade(l_posid))~=0) %判断此交点位置是否刚好为整数
           if(l_price(3,l_postrade(l_posid))<l_price(3,l_postrade(l_posid)+1)&&l_price(1,l_postrade(l_posid)+1)<l_price(3,l_postrade(l_posid)+1)&&...
                        l_price(3,l_tradeday(l_cnt-1)+1)<l_price(3,l_tradeday(l_cnt-1)) && l_price(2,l_tradeday(l_cnt-1)+1)>l_price(3,l_tradeday(l_cnt-1)+1))%向下突破的条件判断
                        l_tradeday(l_cnt)=l_postrade(l_posid);
                        l_cnt=l_cnt+1;
           else
                l_tradeday(l_cnt)=l_tradeday(l_cnt-1);
                l_cnt=l_cnt+1;
           end
            else
            if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)-1) && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_cnt-1))>l_price(3,l_tradeday(l_cnt-1)+1)&&l_price(2,l_tradeday(l_cnt-1)+1)>l_price(3,l_tradeday(l_cnt-1)+1)) %向上突破的条件判断
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_cnt=l_cnt+1;
            else
                l_tradeday(l_cnt)=l_tradeday(l_cnt-1);
                l_cnt=l_cnt+1;
            end
        end   
    end
    end
    l_realtradeday=unique(l_tradeday);
    %==========================================================================
    %更新record中的opdateprice,direction
    for l_tradeid=1:numel(l_realtradeday)
    l_a1=find(l_posinter1==l_realtradeday(l_tradeid));
    l_a2=find(l_posinter2==l_realtradeday(l_tradeid));
    if l_a1~=0
        if(l_signprice1(l_realtradeday(l_tradeid))~=0) %判断此交点位置是否刚好为非整数
            if(l_price(3,l_realtradeday(l_tradeid)+1)<l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1))%向上突破的条件判断
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            end
        else
              if(l_price(3,l_realtradeday(l_tradeid)+1)<l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1))%向上突破的条件判断
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
              end
        end
    elseif l_a2~=0
         if(l_signprice2(l_realtradeday(l_tradeid))~=0) %判断此交点位置是否刚好为非整数
            if (l_price(3,l_realtradeday(l_tradeid))<l_price(3,l_realtradeday(l_tradeid)+1)&&l_price(1,l_realtradeday(l_tradeid)+1)<l_price(3,l_realtradeday(l_tradeid)+1))%向下突破的条件判断
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
            if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1))%向上突破的条件判断
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=-1;
            end
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
    % 1.根据策略算法与前向策略趋势（“与”关系），寻找出做多或做空的点
    % 2.根据策略算法本身，寻找可能平仓的点
    l_opcnt=1;%计数变量
    l_cpcnt=1;
    l_direction1=zeros(1,numel(l_posinter1));
    l_optradeday1=zeros(1,numel(l_posinter1));
    l_direction2=zeros(1,numel(l_posinter2));
    l_optradeday2=zeros(1,numel(l_posinter2));
    l_cptradeday1=zeros(1,numel(l_posinter1));
    l_cptradeday2=zeros(1,numel(l_posinter2));
    for l_posid=1:numel(l_posinter1)
        if(l_signprice1(l_posinter1(l_posid))~=0) %判断此交点位置是否刚好为整数
            if((l_price(3,l_posinter1(l_posid)+1)<l_price(3,l_posinter1(l_posid))...
                    &&l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1))||(l_price(3,l_posinter1(l_posid)+1)>l_price(3,l_posinter1(l_posid))...
                    &&l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1)))%向下突破20
                if (l_price(3,l_posinter1(l_posid)+1)<l_price(3,l_posinter1(l_posid))...
                    &&l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1))
                if (inputdata.commodity.dailyinfo.trend(l_posinter1(l_posid)+1)==2)
                    l_optradeday1(l_opcnt)=l_posinter1(l_posid);
                    l_direction1(l_opcnt)=1;
                    l_opcnt=l_opcnt+1;
                end
                end
                l_cptradeday1(l_cpcnt)=l_posinter1(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
          else %当交点位置刚好为整数时
            if((l_price(3,l_posinter1(l_posid)+1)<l_price(3,l_posinter1(l_posid)-1)...
                    && l_price(3,l_posinter1(l_posid)-1)>l_price(2,l_posinter1(l_posid)-1) && l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1))||(l_price(3,l_posinter1(l_posid)+1)>l_price(3,l_posinter1(l_posid)-1)...
                    && l_price(3,l_posinter1(l_posid)-1)<l_price(2,l_posinter1(l_posid)-1)&&l_price(3,l_posinter1(l_posid)+1)>l_price(2,l_posinter1(l_posid)+1))) %向上突破的条件判断
                if (l_price(3,l_posinter1(l_posid)+1)<l_price(3,l_posinter1(l_posid)-1)...
                    && l_price(3,l_posinter1(l_posid)-1)>l_price(2,l_posinter1(l_posid)-1) && l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1))
                if (inputdata.commodity.dailyinfo.trend(l_posinter1(l_posid)+1)==2)
                    l_optradeday1(l_opcnt)=l_posinter1(l_posid);
                    l_direction1(l_opcnt)=1;
                    l_opcnt=l_opcnt+1;
                end
                end
                l_cptradeday1(l_cpcnt)=l_posinter1(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
        end
    end
    l_opcnt=1;%计数变量
    l_cpcnt=1;
    for l_posid=1:numel(l_posinter2)
        if(l_signprice2(l_posinter2(l_posid))~=0) %判断此交点位置是否刚好为整数
            if((l_price(3,l_posinter2(l_posid))<l_price(3,l_posinter2(l_posid)+1)...
                    &&l_price(1,l_posinter2(l_posid)+1)<l_price(3,l_posinter2(l_posid)+1))||(l_price(3,l_posinter2(l_posid))>l_price(3,l_posinter2(l_posid)+1)...
                    &&l_price(1,l_posinter2(l_posid)+1)>l_price(3,l_posinter2(l_posid)+1)))%向上突破80
                if (l_price(3,l_posinter2(l_posid))<l_price(3,l_posinter2(l_posid)+1)...
                    &&l_price(1,l_posinter2(l_posid)+1)<l_price(3,l_posinter2(l_posid)+1))
                if (inputdata.commodity.dailyinfo.trend(l_posinter2(l_posid)+1)==1)
                    l_optradeday2(l_opcnt)=l_posinter2(l_posid);
                    l_direction2(l_opcnt)=-1;
                    l_opcnt=l_opcnt+1;
                end
                end
                l_cptradeday2(l_cpcnt)=l_posinter2(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
        else %当交点刚好为整数时
            if((l_price(3,l_posinter2(l_posid)-1)<l_price(3,l_posinter2(l_posid)+1)...
                    && l_price(1,l_posinter2(l_posid)-1)>l_price(3,l_posinter2(l_posid)-1) && l_price(1,l_posinter2(l_posid)+1)<l_price(3,l_posinter2(l_posid)+1))||(l_price(3,l_posinter2(l_posid)-1)>l_price(3,l_posinter2(l_posid)+1)...
                    && l_price(1,l_posinter2(l_posid)-1)<l_price(3,l_posinter2(l_posid)-1)&& l_price(1,l_posinter2(l_posid)+1)>l_price(3,l_posinter2(l_posid)+1)))%向下突破的条件判断
                if (l_price(3,l_posinter2(l_posid)-1)<l_price(3,l_posinter2(l_posid)+1)...
                    && l_price(1,l_posinter2(l_posid)-1)>l_price(3,l_posinter2(l_posid)-1) && l_price(1,l_posinter2(l_posid)+1)<l_price(3,l_posinter2(l_posid)+1))
                if (inputdata.commodity.dailyinfo.trend(l_posinter2(l_posid)+1)==1)
                    l_optradeday2(l_opcnt)=l_posinter2(l_posid);
                    l_direction2(l_opcnt)=-1;
                    l_opcnt=l_opcnt+1;
                end
                end
                l_cptradeday2(l_cpcnt)=l_posinter2(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
        end   
    end
    l_optradeday1(l_optradeday1==0)=[];
    l_cptradeday1(l_cptradeday1==0)=[];
    l_optradeday2(l_optradeday2==0)=[];
    l_cptradeday2(l_cptradeday2==0)=[];
    l_optradeday=[l_optradeday1,l_optradeday2];
    l_cptradeday=[l_cptradeday1,l_cptradeday2];
    if isempty(l_optradeday)
        return;
    end
%     l_direction(l_direction==0)=[];
%     %去除连续做多或做空的交易日期
%     if isempty(l_direction)
%         return;
%     end
%     l_directionkey=l_direction(1);
%     for l_id = 2:numel(l_tradeday)
%         if l_direction(l_id)==l_directionkey
%             l_tradeday(l_id)=-1;
%         else
%             l_directionkey=l_direction(l_id);
%         end
%     end
%     l_tradeday(l_tradeday==-1)=[];
    l_oprealtradeday=unique(l_optradeday);
    l_cprealtradeday=unique(l_cptradeday);
    %==========================================================================
    %更新record中的opdateprice,direction
    for l_tradeid=1:numel(l_oprealtradeday)
        a=find(l_optradeday1==l_oprealtradeday(l_tradeid));
        b=find(l_optradeday2==l_oprealtradeday(l_tradeid));
        if(a~=0) %判断此交点位置是否刚好为非整数
            if(l_price(3,l_oprealtradeday(l_tradeid)+1)<l_price(3,l_oprealtradeday(l_tradeid))...
                    && l_price(3,l_oprealtradeday(l_tradeid)+1)<l_price(2,l_oprealtradeday(l_tradeid)+1)) %向下突破20
                if(l_oprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+2); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            end
        elseif (b~=0)
            if(l_price(3,l_oprealtradeday(l_tradeid))<l_price(3,l_oprealtradeday(l_tradeid)+1)...
                    &&l_price(1,l_oprealtradeday(l_tradeid)+1)<l_price(3,l_oprealtradeday(l_tradeid)+1)) %向下突破的条件判断
                    if(l_oprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                        outputdata.orderlist.direction=-1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
                    else 
                        outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+2); %计算出交易记录
                        outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+2);
                        outputdata.record.direction(l_tradeid)=-1;
                    end
            end
%         else %当交点位置刚好为整数时
%             if(l_price(3,l_oprealtradeday(l_tradeid)+1)>l_price(3,l_oprealtradeday(l_tradeid)-1)...
%                     && l_price(3,l_oprealtradeday(l_tradeid)-1)<l_price(1,l_oprealtradeday(l_tradeid)-1) && l_price(3,l_oprealtradeday(l_tradeid)+1)>l_price(1,l_oprealtradeday(l_tradeid)+1)) %向上突破的条件判断
%                 outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+1); %计算出交易记录
%                 outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+2);
%                 outputdata.record.direction(l_tradeid)=-1;
%             elseif(l_price(3,l_oprealtradeday(l_tradeid)-1)>l_price(3,l_oprealtradeday(l_tradeid)+1)...
%                     && l_price(2,l_oprealtradeday(l_tradeid)-1)<l_price(3,l_oprealtradeday(l_tradeid)-1) && l_price(2,l_oprealtradeday(l_tradeid)+1)>l_price(3,l_oprealtradeday(l_tradeid)+1)) %向下突破的条件判断
%                 outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+1); %计算出交易记录
%                 outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+2);
%                 outputdata.record.direction(l_tradeid)=-1;
%             end
        end   
        outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
    end
    %==========================================================================
    % 根据策略算法本身，寻找可能平仓的点
    l_tempcpdate=cell(1,numel(l_cprealtradeday));
    if(l_cprealtradeday(end)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
        outputdata.orderlist.direction(end+1)=-outputdata.record.direction(end);
        outputdata.orderlist.price(end+1)=0;
        outputdata.orderlist.name(end+1)=inputdata.commodity.serialmkdata.ctname(end-2);
        l_cprealtradeday(end)=[];
        l_tempcpdate(end)=[];
    end         
    l_tempcpdate=inputdata.commodity.serialmkdata.date(l_cprealtradeday+2);
%      for l_tradeid=1:numel(l_cprealtradeday)
%         if(l_signprice1(l_cprealtradeday(l_tradeid))~=0&&l_signprice2(l_cprealtradeday(l_tradeid))~=0) %判断此交点位置是否刚好为非整数
%             if(l_price(3,l_cprealtradeday(l_tradeid)+1)>l_price(3,l_cprealtradeday(l_tradeid))...
%                     && l_price(3,l_cprealtradeday(l_tradeid)+1)>l_price(1,l_cprealtradeday(l_tradeid)+1)) %向上突破的条件判断
%                 l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid)+2); %计算出交易记录
%             elseif(l_price(3,l_cprealtradeday(l_tradeid))>l_price(3,l_cprealtradeday(l_tradeid)+1)...
%                     &&l_price(2,l_cprealtradeday(l_tradeid)+1)>l_price(3,l_cprealtradeday(l_tradeid)+1)) %向下突破的条件判断
%                 l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid)+2); %计算出交易记录
%             end
%         else %当交点位置刚好为整数时
%             if(l_price(3,l_cprealtradeday(l_tradeid)+1)>l_price(3,l_cprealtradeday(l_tradeid)-1)...
%                     && l_price(3,l_cprealtradeday(l_tradeid)-1)<l_price(1,l_cprealtradeday(l_tradeid)-1) && l_price(3,l_cprealtradeday(l_tradeid)+1)>l_price(1,l_cprealtradeday(l_tradeid)+1)) %向上突破的条件判断
%                 l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid)+1); %计算出交易记录
%             elseif(l_price(3,l_cprealtradeday(l_tradeid)-1)>l_price(3,l_cprealtradeday(l_tradeid)+1)...
%                     && l_price(2,l_cprealtradeday(l_tradeid)-1)<l_price(3,l_cprealtradeday(l_tradeid)-1) && l_price(2,l_cprealtradeday(l_tradeid)+1)>l_price(3,l_cprealtradeday(l_tradeid)+1)) %向下突破的条件判断
%                 l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid)+1); %计算出交易记录
%             end
%         end   
%     end
    %==========================================================================
     % 根据策略算法与前向策略趋势（“或”关系），寻找出平仓点
    l_difftrend=inputdata.commodity.dailyinfo.trend(2:end)-inputdata.commodity.dailyinfo.trend(1:end-1);
    l_postrend=find(l_difftrend~=0);
    l_trendchangeday=unique(l_postrend);    % 趋势变化前的最后一天
    if(l_trendchangeday(end)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
        outputdata.orderlist.direction(end+1)=-outputdata.record.direction(end);
        outputdata.orderlist.price(end+1)=0;
        outputdata.orderlist.name(end+1)=inputdata.commodity.serialmkdata.ctname(end-2);
        l_trendchangeday(end)=[];
    end      
    for i=1:numel(l_trendchangeday)
        if (l_trendchangeday(i)+2<=numel(inputdata.commodity.dailyinfo.date))
            l_trendchangedate(i)=inputdata.commodity.dailyinfo.date(l_trendchangeday(i)+1);
        else
            l_trendchangedate(i)=inputdata.commodity.dailyinfo.date(end);
        end
    end
%     l_strategycpdate=outputdata.record.opdate(2:end); % 对于该策略，开仓时即平仓 
    l_strategycpdate=l_tempcpdate;
    l_cpdate=unique([l_trendchangedate,l_strategycpdate']);
    
    l_opdatenum=datenum(outputdata.record.opdate,'yyyy-mm-dd');
    l_cpdatenum=datenum(l_cpdate,'yyyy-mm-dd');
    l_cnt=1;
    for l_opid = 1:numel(l_opdatenum)-1
        l_firstcpindex=find(l_cpdatenum>l_opdatenum(l_opid),1);
        if ~isempty(l_firstcpindex)
            if datenum(l_cpdate(l_firstcpindex),'yyyy-mm-dd')<=l_opdatenum(l_opid+1)
                outputdata.record.cpdate(l_cnt)=l_cpdate(l_firstcpindex);
                l_cnt=l_cnt+1;
            end
        end
    end
    outputdata.record.cpdate(numel(l_opdatenum))=inputdata.commodity.serialmkdata.date(end);
    l_firstcpindex=find(l_cpdatenum>l_opdatenum(end));
    if ~isempty(l_firstcpindex)
        if datenum(l_cpdate(l_firstcpindex),'yyyy-mm-dd')<l_opdatenum(end)
            outputdata.record.cpdate(end)=l_cpdate(l_firstcpindex);
        end
    end
    outputdata.record.cpdate=unique(outputdata.record.cpdate);
    %==========================================================================
    % 去除连续做多或做空的交易记录
    l_deleteidx=[];
    for l_id = 2:numel(outputdata.record.opdate)-1
        if (outputdata.record.direction(l_id)==outputdata.record.direction(l_id-1))
            if (outputdata.record.cpdate{l_id-1}==outputdata.record.opdate{l_id})
                l_deleteidx=cat(2,l_deleteidx,l_id);
            end
        end
    end
    outputdata.record.opdate(l_deleteidx)=[];
    outputdata.record.opdateprice(l_deleteidx)=[];
    outputdata.record.cpdate(l_deleteidx)=[];
    outputdata.record.direction(l_deleteidx)=[];
    outputdata.record.ctname(l_deleteidx)=[];
    %======================================================================
    % 完善平仓价格和是否实际平仓信息
    if numel(outputdata.record.cpdate)>=2
        for l_cpid = 1:numel(outputdata.record.cpdate)-1
            l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.cpdate(l_cpid)),1);
            outputdata.record.cpdateprice(l_cpid)=inputdata.commodity.serialmkdata.op(l_dateid)+inputdata.commodity.serialmkdata.gap(l_dateid);
        end
%         for l_cpid = 1:numel(outputdata.record.cpdate)-1
%             l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.opdate(l_cpid)),1);
%             l_ctname=inputdata.commodity.serialmkdata.ctname(l_dateid);
%             l_ctnameid=find(ismember(inputdata.contractname,l_ctname),1);
%             l_ctndateid=find(ismember(inputdata.contract(l_ctnameid).mkdata.date,outputdata.record.cpdate(l_cpid)),1);
%             outputdata.record.cpdateprice(l_cpid)=inputdata.contract(l_ctnameid).mkdata.op(l_ctndateid);
%         end
        outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice));
        if outputdata.record.cpdate{end}==inputdata.commodity.serialmkdata.date{end}
            outputdata.record.cpdateprice(end+1)=inputdata.commodity.serialmkdata.op(end);
            outputdata.record.isclosepos(end)=0;
        else
            l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.cpdate(end)),1);
            outputdata.record.cpdateprice(end+1)=inputdata.commodity.serialmkdata.op(l_dateid)+inputdata.commodity.serialmkdata.gap(l_dateid);
%             l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.opdate(end)),1);
%             l_ctname=inputdata.commodity.serialmkdata.ctname(l_dateid);
%             l_ctnameid=find(ismember(inputdata.contractname,l_ctname),1);
%             l_ctndateid=find(ismember(inputdata.contract(l_ctnameid).mkdata.date,outputdata.record.cpdate(end)),1);
%             outputdata.record.cpdateprice(end+1)=inputdata.contract(l_ctnameid).mkdata.op(l_ctndateid);
        end
    else
        outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
        outputdata.record.isclosepos=0;
    end
%     for l_cpid = 1:numel(outputdata.record.cpdate)
%         l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.opdate(l_cpid)),1);
%         l_ctname=inputdata.commodity.serialmkdata.ctname(l_dateid);
%         l_ctnameid=find(ismember(inputdata.contractname,l_ctname),1);
%         l_ctndateid=find(ismember(inputdata.contract(l_ctnameid).mkdata.date,outputdata.record.cpdate(l_cpid)),1);
%         outputdata.record.cpdateprice(l_cpid)=inputdata.contract(l_ctnameid).mkdata.op(l_ctndateid);
%     end
%     outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
%     if outputdata.record.cpdate{end}==inputdata.commodity.serialmkdata.date{end}
%         outputdata.record.isclosepos(end+1)=0;
%     else
%         outputdata.record.isclosepos(end+1)=1;
%     end
    %==========================================================================
%     %完善outputdata.record,填入平仓日期和平仓价格
%     if(numel(outputdata.record.opdate)>=2)
%         outputdata.record.cpdate=outputdata.record.opdate(2:end);
%         outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
%         outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
%         outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
%         outputdata.record.cpdate(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.date(end); 
%         outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.op(end);
%         %{
%         if(inputdata.contract.info.daystolasttradedate<=0) 
%             outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%         end
%         %}
%     elseif(numel(outputdata.record.opdate)>=1)
%         outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
%         outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
%         outputdata.record.isclosepos=0;
%         %{
%         if(inputdata.contract.info.daystolasttradedate<=0) 
%             outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%         end
%         %}
%     end
    %======================================================================
    % 填入dailyinfo信息
    outputdata.dailyinfo.date=inputdata.commodity.dailyinfo.date;
    outputdata.dailyinfo.trend=inputdata.commodity.dailyinfo.trend; % 待修改
end


%==========================================================================
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The following is zhaoxia's code. 
    % 当策略作为后向执行，在计算交易日期的时候，需要根据之前的策略所算出的trend进行重新判断
    % 而此时不应该急于将tradeday中连续做多或做空的日期删除，因为删除有可能发生交易日期的疏漏
    % 故在此，注释掉
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %在不考虑强制平仓的情况下寻找出需要交易的点
%     l_cnt=2;%计数变量
%     l_tradeday=[];
%      if(l_signprice(l_postrade(1))~=0) %判断此交点位置是否刚好为整数
%             if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %向上突破的条件判断
%                     l_tradeday(1)=l_postrade(1);
%             else if(l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%向下突破的条件判断
%                         l_tradeday(1)=l_postrade(1);
%                 end
%             end
%      else %当交点位置刚好为整数时
%             if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %向上突破的条件判断
%                 l_tradeday(1)=l_postrade(1);
%             else if (l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%向下突破的条件判断
%                     l_tradeday(1)=l_postrade(1);
%                 end
%             end
%      end
%     for i=2:numel(l_postrade)
%         if(l_signprice(l_postrade(i))~=0) %判断此交点位置是否刚好为整数
%             if(l_price(3,l_postrade(i)+1)>l_price(3,l_postrade(i)) && l_price(3,l_postrade(i)+1)>l_price(1,l_postrade(i)+1))&&...
%                     (l_price(3,l_tradeday(i-1))>l_price(3,l_tradeday(i-1)+1)&&l_price(2,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)+1)) %向上突破的条件判断
%                     l_tradeday(l_cnt)=l_postrade(i);
%                     l_cnt=l_cnt+1;
%             else if(l_price(3,l_postrade(i))>l_price(3,l_postrade(i)+1)&&l_price(2,l_postrade(i)+1)>l_price(3,l_postrade(i)+1))&&...
%                         (l_price(3,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)) && l_price(3,l_tradeday(i-1)+1)>l_price(1,l_tradeday(i-1)+1))%向下突破的条件判断
%                         l_tradeday(l_cnt)=l_postrade(i);
%                         l_cnt=l_cnt+1;
%                 else
%                     l_tradeday(l_cnt)=l_tradeday(i-1);
%                     l_cnt=l_cnt+1;
%                 end
%             end
%         else %当交点位置刚好为整数时
%             if(l_price(3,l_postrade(i)+1)>l_price(3,l_postrade(i)) && l_price(3,l_postrade(i)+1)>l_price(1,l_postrade(i)+1))&&...
%                     (l_price(3,l_tradeday(i-1))>l_price(3,l_tradeday(i-1)+1)&&l_price(2,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)+1)) %向上突破的条件判断
%                 l_tradeday(l_cnt)=l_postrade(i);
%                 l_cnt=l_cnt+1;
%             else if (l_price(3,l_postrade(i))>l_price(3,l_postrade(i)+1)&&l_price(2,l_postrade(i)+1)>l_price(3,l_postrade(i)+1))&&...
%                         (l_price(3,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)) && l_price(3,l_tradeday(i-1)+1)>l_price(1,l_tradeday(i-1)+1))%向下突破的条件判断
%                     l_tradeday(l_cnt)=l_postrade(i);
%                     l_cnt=l_cnt+1;
%                 else
%                     l_tradeday(l_cnt)=l_tradeday(i-1);
%                     l_cnt=l_cnt+1;
%                 end
%             end
%         end   
%     end
%     %==========================================================================
%     %合并交易日期和强制平仓日期,此时这些时间必须有交易的发生
%     % l_tradeday=unique(l_tradeday);
%     % RealTradeDayBuff=[l_tradeday,ForceTrade'];
%     % RealTradeDayBuff=sort(RealTradeDayBuff);
%     % l_realtradeday=unique(RealTradeDayBuff);
%     l_realtradeday=unique(l_tradeday);
%     %==========================================================================
%     %更新record中的opdateprice,direction
%     for i=1:numel(l_realtradeday)
%         if(l_signprice(l_realtradeday(i))~=0) %判断此交点位置是否刚好为非整数
%             if(l_price(3,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)) && l_price(3,l_realtradeday(i)+1)>l_price(1,l_realtradeday(i)+1))%向上突破的条件判断
%                 if(l_realtradeday(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
%                     outputdata.orderlist.direction=-1;
%                     outputdata.orderlist.price=0;
%                     outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
%                 else
%                     outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+2); %计算出交易记录
%                     outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+2);
%                     outputdata.record.direction(i)=-1;
%                 end
%             else if (l_price(3,l_realtradeday(i))>l_price(3,l_realtradeday(i)+1)&&l_price(2,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)+1))%向下突破的条件判断
%                     if(l_realtradeday(i)+2>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
%                         outputdata.orderlist.direction=1;
%                         outputdata.orderlist.price=0;
%                         outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
%                     else 
%                         outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+2); %计算出交易记录
%                         outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+2);
%                         outputdata.record.direction(i)=1;
%                     end
%                 end
%             end
%         else %当交点位置刚好为整数时
%             if(l_price(3,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)) && l_price(3,l_realtradeday(i)+1)>l_price(1,l_realtradeday(i)+1))%向上突破的条件判断
%                 outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+1);
%                 outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+1);
%                 outputdata.record.direction(i)=-1;
%             else if (l_price(3,l_realtradeday(i))>l_price(3,l_realtradeday(i)+1)&&l_price(2,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)+1))%向下突破的条件判断
%                     outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+1);
%                     outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+1);
%                     outputdata.record.direction(i)=1;
%                 end
%             end
%         end   
%         outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
%     end
% 
%     %==========================================================================
%     %完善outputdata.record,填入平仓日期和平仓价格
%     if(numel(outputdata.record.opdate)>=2)
%         outputdata.record.cpdate=outputdata.record.opdate(2:end);
%         outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
%         outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
%         outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
%         outputdata.record.cpdate(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.date(end); 
%         outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.op(end);
%         %{
%         if(inputdata.contract.info.daystolasttradedate<=0) 
%             outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%         end
%         %}
%     elseif(numel(outputdata.record.opdate)>=1)
%         outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
%         outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
%         outputdata.record.isclosepos=0;
%         %{
%         if(inputdata.contract.info.daystolasttradedate<=0) 
%             outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%         end
%         %}
%     end



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




