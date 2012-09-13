function outputdata=ZR_STRATEGY_040712(inputdata)
%Commodity Chanel Index strategy
%created on 22 August 2012 by Gang LIU
%1st version
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

%计算Aroon indicators
l_datalen = length(inputdata.commodity.serialmkdata.cp);
l_hp = inputdata.commodity.serialmkdata.hp;
l_lp = inputdata.commodity.serialmkdata.lp;
l_cp = inputdata.commodity.serialmkdata.cp;

l_CCI = TA_CCI(l_hp, l_lp, l_cp, inputdata.strategyparams.period);

% figure('Name',strcat('040714',cell2mat(inputdata.commodity.name)));
% plot(l_CCI, '-b');
% hold on
% plot(100*ones(1,l_datalen));
% hold on
% plot (-100*ones(1,l_datalen));
% hold off

l_CCI1 = l_CCI(1:end-1);
l_CCI2 = l_CCI(2:end);


%寻找强烈的买入或卖出信号
l_LongPositions1 = find((l_CCI1 < 100) & (l_CCI2 >= 100));
l_LongPositions2 = find((l_CCI1 < -100) & (l_CCI2 >= -100));
l_ShortPositions1 = find((l_CCI1 > 100) & (l_CCI2 <= 100)); 
l_ShortPositions2 = find((l_CCI1 > -100) & (l_CCI2 <= -100)); 
l_LongPositions = sort([l_LongPositions1; l_LongPositions2]);
l_ShortPositions = sort([l_ShortPositions1; l_ShortPositions2]);
l_LongPositions = l_LongPositions + 1;
l_ShortPositions = l_ShortPositions + 1;

%l_cnt = 0;
% for l_index = 1 : l_length1
%     
%     l_realindex = l_index - l_cnt;
%     
%     if l_realindex <= length(l_LongPositions)
%     
%         l_temp = find(l_ShortPositions==l_LongPositions(l_realindex), 1);
% 
%         if ~isempty(l_temp)
% 
%             l_LongPositions(l_realindex) = [];
%             l_ShortPositions(l_temp) = [];
%             l_cnt = l_cnt + 1;
% 
%         end
%         
%     end
%     
% end

%如果作为单一策略或者主策略
if isequal(zeros(length(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend)

    l_positionheld = 0;

    for l_dateindex = 1 : l_datalen
        
        if((~isempty(find(l_LongPositions==l_dateindex,1))) && l_positionheld ~= 1)
            
            if l_dateindex == l_datalen
                
                outputdata.orderlist.direction = 1;
                outputdata.orderlist.price = 0;
                outputdata.orderlist.name = inputdata.commodity.serialmkdata.ctname(l_dateindex);
                l_positionheld = 1;
            
            else
                
                outputdata.record.opdate(end+1) = inputdata.commodity.serialmkdata.date(l_dateindex+1);
                outputdata.record.opdateprice(end+1) = inputdata.commodity.serialmkdata.op(l_dateindex+1) + inputdata.commodity.serialmkdata.gap(l_dateindex+1);
                outputdata.record.direction(end+1) = 1;
                outputdata.record.ctname(end+1) = inputdata.commodity.serialmkdata.ctname(l_dateindex+1);
                l_positionheld = 1;
                
            end
        
        elseif ((~isempty(find(l_ShortPositions==l_dateindex,1))) && l_positionheld ~= -1)
            
             if l_dateindex == l_datalen
                
                outputdata.orderlist.direction = -1;
                outputdata.orderlist.price = 0;
                outputdata.orderlist.name = inputdata.commodity.serialmkdata.ctname(l_dateindex);
                l_positionheld = -1;
            
            else
                
                outputdata.record.opdate(end+1) = inputdata.commodity.serialmkdata.date(l_dateindex+1);
                outputdata.record.opdateprice(end+1) = inputdata.commodity.serialmkdata.op(l_dateindex+1) + inputdata.commodity.serialmkdata.gap(l_dateindex+1);
                outputdata.record.direction(end+1) = -1;
                outputdata.record.ctname(end+1) = inputdata.commodity.serialmkdata.ctname(l_dateindex+1);
                l_positionheld = -1;
                
             end
            
        end

    end
    
    %补充outputdata.record中的信息
    if(length(outputdata.record.opdate)>=2)
        
        outputdata.record.cpdate=outputdata.record.opdate(2:end);
        outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
        outputdata.record.isclosepos=ones(1,length(outputdata.record.opdateprice)-1);
        outputdata.record.isclosepos(length(outputdata.record.opdateprice))=0;
        outputdata.record.cpdate(length(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.date(end); 
        outputdata.record.cpdateprice(length(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.cp(end);
        
    elseif(length(outputdata.record.opdate) ==1)
        
        outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
        outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.cp(end)+inputdata.commodity.serialmkdata.gap(end);
        outputdata.record.isclosepos=0;
        
    end
    
    %填写outputdata.dailyinfo
    outputdata.dailyinfo.date=inputdata.commodity.serialmkdata.date;
    
    for l_dateindex = 1 : l_datalen
        
        if ~isempty(find(l_ShortPositions==l_dateindex,1))
            outputdata.dailyinfo.trend(l_dateindex) = 1;
        elseif ~isempty(find(l_LongPositions==l_dateindex,1))
            outputdata.dailyinfo.trend(l_dateindex) = 2;
        else
            outputdata.dailyinfo.trend(l_dateindex) = 4;
        end
        
    end
    
else
    
    l_positionheld = 0;

    for l_dateindex = 1 : l_datalen

        if(l_positionheld == 0)

            if (~isempty(find(l_LongPositions==l_dateindex,1))) && inputdata.commodity.dailyinfo.trend(l_dateindex) == 2

                if l_dateindex == l_datalen

                    outputdata.orderlist.direction = 1;
                    outputdata.orderlist.price = 0;
                    outputdata.orderlist.name = inputdata.commodity.serialmkdata.ctname(l_dateindex);

                else

                    outputdata.record.opdate(end+1) = inputdata.commodity.serialmkdata.date(l_dateindex+1);
                    outputdata.record.opdateprice(end+1) = inputdata.commodity.serialmkdata.op(l_dateindex+1) + inputdata.commodity.serialmkdata.gap(l_dateindex+1);
                    outputdata.record.direction(end+1) = 1;
                    outputdata.record.isclosepos(end+1) = 0;
                    outputdata.record.ctname(end+1) = inputdata.commodity.serialmkdata.ctname(l_dateindex+1);
                    l_positionheld = 1;

                end            

            elseif (~isempty(find(l_ShortPositions==l_dateindex,1))) && inputdata.commodity.dailyinfo.trend(l_dateindex) == 1

                if l_dateindex == l_datalen

                    outputdata.orderlist.direction = -1;
                    outputdata.orderlist.price = 0;
                    outputdata.orderlist.name = inputdata.commodity.serialmkdata.ctname(l_dateindex);

                else

                    outputdata.record.opdate(end+1) = inputdata.commodity.serialmkdata.date(l_dateindex+1);
                    outputdata.record.opdateprice(end+1) = inputdata.commodity.serialmkdata.op(l_dateindex+1) + inputdata.commodity.serialmkdata.gap(l_dateindex+1);
                    outputdata.record.direction(end+1) = -1;
                    outputdata.record.isclosepos(end+1) = 0;
                    outputdata.record.ctname(end+1) = inputdata.commodity.serialmkdata.ctname(l_dateindex+1);
                    l_positionheld = -1;

                end

            end

        elseif l_positionheld == -1

            if (~isempty(find(l_LongPositions==l_dateindex,1))) || inputdata.commodity.dailyinfo.trend(l_dateindex) == 2

                if l_dateindex == l_datalen

                    outputdata.orderlist.direction = 1;
                    outputdata.orderlist.price = 0;
                    outputdata.orderlist.name = inputdata.commodity.serialmkdata.ctname(l_dateindex);

                else

                    outputdata.record.cpdate(end+1) = inputdata.commodity.serialmkdata.date(l_dateindex+1);
                    outputdata.record.cpdateprice(end+1) = inputdata.commodity.serialmkdata.op(l_dateindex+1) + inputdata.commodity.serialmkdata.gap(l_dateindex+1);
                    outputdata.record.isclosepos(end) = 1;
                    l_positionheld = 0;

                end

            end

            if (~isempty(find(l_LongPositions==l_dateindex,1))) && inputdata.commodity.dailyinfo.trend(l_dateindex) == 2

                if l_dateindex == l_datalen

                    outputdata.orderlist.direction = 1;
                    outputdata.orderlist.price = 0;
                    outputdata.orderlist.name = inputdata.commodity.serialmkdata.ctname(l_dateindex);

                else

                    outputdata.record.opdate(end+1) = inputdata.commodity.serialmkdata.date(l_dateindex+1);
                    outputdata.record.opdateprice(end+1) = inputdata.commodity.serialmkdata.op(l_dateindex+1) + inputdata.commodity.serialmkdata.gap(l_dateindex+1);
                    outputdata.record.direction(end+1) = 1;
                    outputdata.record.isclosepos(end+1) = 0;
                    outputdata.record.ctname(end+1) = inputdata.commodity.serialmkdata.ctname(l_dateindex+1);
                    l_positionheld = 1;

                end

            end

        elseif l_positionheld == 1 

            if (~isempty(find(l_ShortPositions==l_dateindex,1))) || inputdata.commodity.dailyinfo.trend(l_dateindex) == 1

                if l_dateindex == l_datalen

                    outputdata.orderlist.direction = -1;
                    outputdata.orderlist.price = 0;
                    outputdata.orderlist.name = inputdata.commodity.serialmkdata.ctname(l_dateindex);

                else

                    outputdata.record.cpdate(end+1) = inputdata.commodity.serialmkdata.date(l_dateindex+1);
                    outputdata.record.cpdateprice(end+1) = inputdata.commodity.serialmkdata.op(l_dateindex+1) + inputdata.commodity.serialmkdata.gap(l_dateindex+1);
                    outputdata.record.isclosepos(end) = 1;
                    l_positionheld = 0;

                end

            end

            if (~isempty(find(l_ShortPositions==l_dateindex,1))) && inputdata.commodity.dailyinfo.trend(l_dateindex) == 1

                if l_dateindex == l_datalen

                    outputdata.orderlist.direction = -1;
                    outputdata.orderlist.price = 0;
                    outputdata.orderlist.name = inputdata.commodity.serialmkdata.ctname(l_dateindex);

                else

                    outputdata.record.opdate(end+1) = inputdata.commodity.serialmkdata.date(l_dateindex+1);
                    outputdata.record.opdateprice(end+1) = inputdata.commodity.serialmkdata.op(l_dateindex+1) + inputdata.commodity.serialmkdata.gap(l_dateindex+1);
                    outputdata.record.direction(end+1) = -1;
                    outputdata.record.isclosepos(end+1) = 0;
                    outputdata.record.ctname(end+1) = inputdata.commodity.serialmkdata.ctname(l_dateindex+1);
                    l_positionheld = -1;

                end

            end

        end     

    end
    
    if l_positionheld ~= 0
     outputdata.record.cpdate(end+1) = inputdata.commodity.serialmkdata.date(end);
     outputdata.record.cpdateprice(end+1) = inputdata.commodity.serialmkdata.op(end) + inputdata.commodity.serialmkdata.gap(end);
    end
    
    %填写outputdata.dailyinfo
    outputdata.dailyinfo.date=inputdata.commodity.serialmkdata.date;
    outputdata.dailyinfo.trend = inputdata.commodity.serialmkdata.date; 

end



% disp('finished');


end