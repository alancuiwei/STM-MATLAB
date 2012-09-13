function outputdata=ZR_STRATEGY_040807(inputdata)
%Three Starts in the South strategy
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
l_op = inputdata.commodity.serialmkdata.op;

%l_outcome = TA_CDL3STARSINSOUTH(l_op, l_hp, l_lp, l_cp);
l_outcome = three_stars_in_the_south(l_op, l_hp, l_lp, l_cp);

if isequal(zeros(length(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend)
    for l_dateindex = 1 : l_datalen
        if l_outcome(l_dateindex) == 1
            outputdata.dailyinfo.trend(l_dateindex) = 2;
        else
            outputdata.dailyinfo.trend(l_dateindex) = 0;
        end
    end
    outputdata.dailyinfo.date = inputdata.commodity.serialmkdata.date;
else
    disp('该策略不能作为后项策略')
end

disp('finished');


end

function output = three_stars_in_the_south(op, hp, lp, cp)
   
    len = length(op);
    output = zeros(len,1);

    
    for i = 3 : len
        logic1 = (cp(i-2)<op(i-2)) && (cp(i-2) > lp(i-2)) && (abs(op(i-2) -hp(i-2)) < 1e-4);
        logic2 = (cp(i-1)<op(i-1)) && (cp(i-1) > lp(i-1)) && (abs(op(i-1) - hp(i-1)) < 1e-4) && ( (op(i-1)-cp(i-1)) < (op(i-2)-cp(i-2))  ) && ( (cp(i-1)-lp(i-1)) < (cp(i-2)-lp(i-2))  );
        logic3 = (hp(i) < hp(i-1)) && (lp(i) > lp(i-1)) && (abs(op(i) - hp(i)) < 1e-4) && (abs(cp(i) - lp(i)) < 1e-4);
        if logic1 && logic2 && logic3
            output(i) = 1;
        end
    end

end