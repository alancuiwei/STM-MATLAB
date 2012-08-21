function outputdata=ZR_STRATEGY_040714(inputdata)
%Aroon indicator strategy
%created on 21 August 2012 by Gang LIU
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


[l_AroonUp,l_AroonDown] = TA_AROON(l_lp, l_hp, inputdata.strategyparams.period);


plot(l_AroonUp, '-b');
hold on
plot(l_AroonDown, '-r');
hold on
plot(70*ones(l_datalen,1));



%寻找强烈的买入或卖出信号
l_LongPositions = find(l_AroonUp >= 70);
l_ShortPositions = find(l_AroonDown >=70);
l_length1 = length(l_LongPositions);

for l_index = 1 : l_length1
    
    if l_index <= length(l_LongPositions)
    
        l_temp = find(l_ShortPositions==l_LongPositions(l_index), 1);

        if ~isempty(l_temp)

            l_LongPositions(l_index) = [];
            l_ShortPositions(l_temp) = [];

        end
        
    end
    
end

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
        
        if((~isempty(find(l_LongPositions==l_dateindex,1))) && l_positionheld ~= 1 && inputdata.commodity.dailyinfo.trend(l_dateindex) == 2)
            
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
        
        elseif ((~isempty(find(l_ShortPositions==l_dateindex,1))) && l_positionheld ~= -1 && inputdata.commodity.dailyinfo.trend(l_dateindex) == 1)
            
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
    outputdata.dailyinfo.trend = inputdata.commodity.serialmkdata.date; 
    
end

disp('finished');

end