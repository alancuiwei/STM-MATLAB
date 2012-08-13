function outputdata=ZR_STRATEGY_040711(inputdata)
% tmp=load('in.mat');
% inputdata=tmp.l_inputdata;
% T=input('输入时间周期T=')
% t=input('算法参数t=')
period=input('输入时间周期period=');
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
%计算出EMA值
input_mkdata=inputdata.commodity.serialmkdata;
if (inputdata.strategyparams.T>1)
out_periodmkdata=ZR_FUN_ComputePeriodMKdata(input_mkdata,period);
outReal=TA_EMA(out_periodmkdata.cp',inputdata.strategyparams.t);
cnt=1;
EMA=zeros(numel(inputdata.commodity.serialmkdata.date),1);
for i=1:numel(outReal)
    EMA(cnt*inputdata.strategyparams.T+1:(cnt+1)*inputdata.strategyparams.T)=outReal(i);
    cnt=cnt+1;
end
if numel(EMA)>numel(inputdata.commodity.serialmkdata.date)
    EMA(numel(inputdata.commodity.serialmkdata.date)+1:end)=[];
end
Price(1,:)=EMA;
else
outReal=TA_EMA(inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.t);
Price(1,:)=outReal;
end
% xlswrite('D:\zx\STM-MATLAB-0807\StrategyProcess\Strategies\TestResults\040704\TestResults_SERIAL',Price(1,:)','Sheet1','F');
% xlswrite('D:\zx\STM-MATLAB-0807\StrategyProcess\Strategies\TestResults\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','A');
% xlswrite('D:\zx\STM-MATLAB-0807\StrategyProcess\Strategies\TestResults\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','B');
% xlswrite('D:\zx\STM-MATLAB-0807\StrategyProcess\Strategies\TestResults\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','C');
% xlswrite('D:\zx\STM-MATLAB-0807\StrategyProcess\Strategies\TestResults\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','D');
% xlswrite('D:\zx\STM-MATLAB-0807\StrategyProcess\Strategies\TestResults\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','E');
%==========================================================================
% figure('Name',strcat('040706',cell2mat(inputdata.commodity.name)));
% plot(l_price(1,:),'-r*');
% hold on;
% plot(l_price(2,:),'k')
% legend('MACD',2);
% hold off;
%==========================================================================
%以异号为原则寻找交叉点，并将寻找到的异号点存入数组PositionTrade中
l_signprice=Price(1,2:numel(Price(1,:)))-Price(1,1:numel(Price(1,:))-1);
% l_pos=2:numel(Price)%交点位置记录为实际交点的前一个点,当前点
% l_posinter=find(l_diffprice==0);
% l_postrade=[l_pos,l_posinter];
% l_postrade=unique(sort(l_postrade));                                            
%==========================================================================                                          
%==========================================================================         
if isequal(zeros(numel(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend) %判断是否作为主策略或单一策略
    %在不考虑强制平仓的情况下寻找出需要交易的点
    l_cnt=1;%计数变量
    l_direction=zeros(1,numel(l_signprice));
    l_tradeday=zeros(1,numel(l_signprice));
    for l_posid=1:numel(l_signprice)
            if(l_signprice(l_posid)>0) %递增
                    l_tradeday(l_cnt)=l_posid;
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
            elseif(l_signprice(l_posid)) %递减
                        l_tradeday(l_cnt)=l_posid;
                        l_direction(l_cnt)=-1;
                        l_cnt=l_cnt+1; 
            end
    end
    l_tradeday(l_tradeday==0)=[];
    l_direction(l_direction==0)=[];
    if isempty(l_direction)
        return;
    end
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
     for l_tradeid=1:(numel(l_realtradeday))
            if(l_signprice(l_realtradeday(l_tradeid))>0) %递增
                if(l_realtradeday(l_tradeid)+1>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(end);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                    outputdata.record.direction(l_tradeid)=1;
                end
            else if(l_signprice(l_realtradeday(l_tradeid))<0) %递减 
                    if(l_realtradeday(l_tradeid)+1>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更行outputdata.orderlist向量
                        outputdata.orderlist.direction=-1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(end);
                    else 
                        outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1); %计算出交易记录
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
    %在不考虑强制平仓的情况下寻找出需要交易的点
    l_opcnt=1;%计数变量
    l_cpcnt=1;
    l_direction=zeros(1,numel(l_signprice));
    l_optradeday=zeros(1,numel(l_signprice));
    l_cptradeday=zeros(1,numel(l_signprice));
    for l_posid=1:numel(l_signprice)
            if(l_signprice(l_posid)>0) %递增
                if (inputdata.commodity.dailyinfo.trend(l_posid)==2)
                    l_optradeday(l_opcnt)=l_posid;
                    l_direction(l_opcnt)=1;
                    l_opcnt=l_opcnt+1;
                end
                l_cptradeday(l_cpcnt)=l_posid;
                l_cpcnt=l_cpcnt+1;
            elseif (l_signprice(l_posid)<0) %递减
                if (inputdata.commodity.dailyinfo.trend(l_posid)==1)
                    l_optradeday(l_opcnt)=l_posid;
                    l_direction(l_opcnt)=-1;
                    l_opcnt=l_opcnt+1;
                end
                l_cptradeday(l_cpcnt)=l_posid;
                l_cpcnt=l_cpcnt+1;
            end
        end   
    l_optradeday(l_optradeday==0)=[];
    l_cptradeday(l_cptradeday==0)=[];
    if isempty(l_optradeday)
        return;
    end
    l_oprealtradeday=unique(l_optradeday);
    l_cprealtradeday=unique(l_cptradeday);
    %==========================================================================
    %更新record中的opdateprice,direction
     for l_tradeid=1:numel(l_oprealtradeday)
            if(l_signprice(l_oprealtradeday(l_tradeid))>0) %递增
                if(l_oprealtradeday(l_tradeid)+1>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更新outputdata.orderlist向量
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(end);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+1); %计算出交易记录
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+1);
                    outputdata.record.direction(l_tradeid)=1;
                end
            else if(l_signprice(l_oprealtradeday(l_tradeid))<0) %递减 
                    if(l_oprealtradeday(l_tradeid)+1>numel(inputdata.commodity.serialmkdata.date)) %假如交点为今天和昨天之间，则更行outputdata.orderlist向量
                        outputdata.orderlist.direction=-1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(end);
                    else 
                        outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+1); %计算出交易记录
                        outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+1);
                        outputdata.record.direction(l_tradeid)=-1;
                    end
                end
            end  
        outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
    end
    %==========================================================================
    % 根据策略算法本身，寻找可能平仓的点
    l_tempcpdate=cell(1,numel(l_cprealtradeday));
     for l_tradeid=1:numel(l_cprealtradeday)
        if(l_signprice(l_cprealtradeday(l_tradeid))~=0) %判断此交点位置是否刚好为非整数
            if(l_signprice(l_cprealtradeday(l_tradeid))>0) %递增
                l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid)+1);
            elseif(l_signprice(l_cprealtradeday(l_tradeid))<0) %递减
                l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid)+1);
            end
        end   
    end
    %==========================================================================
    % 根据策略算法与前向策略趋势（“或”关系），寻找出平仓点
    l_difftrend=inputdata.commodity.dailyinfo.trend(2:end)-inputdata.commodity.dailyinfo.trend(1:end-1);
    l_postrend=find(l_difftrend~=0);
    l_trendchangeday=unique(l_postrend);    % 趋势变化前的最后一天
    for i=1:numel(l_trendchangeday)
        if (l_trendchangeday(i)+2<=numel(inputdata.commodity.dailyinfo.date))
            l_trendchangedate(i)=inputdata.commodity.dailyinfo.date(l_trendchangeday(i)+2);
        else
            l_trendchangedate(i)=inputdata.commodity.dailyinfo.date(end);
        end
    end
%     l_strategycpdate=outputdata.record.opdate(2:end); % 对于该策略，开仓时即平仓
    l_strategycpdate=l_tempcpdate;
    l_cpdate=unique([l_trendchangedate,l_strategycpdate]);
    
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
    %完善outputdata.record,填入平仓日期和平仓价格
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