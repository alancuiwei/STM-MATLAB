function ZR_PROCESS_ComputeReference(varargin)
%%%%%%%% 计算测评指标
global g_reportset;
global g_reference;
% 如果有两个参数，计算的开始时间的和终止的时间
l_setwindow=0;
if nargin>0
    switch nargin
        case 1
        case 2
            l_setwindow=1;
            l_startwindownum=datenum(varargin{1});
            l_endwindownum=datenum(varargin{2});
            if l_startwindownum>l_endwindownum
                return;
            end
    end
end

% 各品种
for l_cmid=1:length(g_reportset.commodity)
    % 开始统计的时间 
    l_startid=1;
    l_endid=g_reportset.commodity(l_cmid).enddatenum-g_reportset.commodity(l_cmid).startdatenum+1;
    if l_setwindow
        if l_startwindownum>=g_reportset.commodity(l_cmid).startdatenum
            l_startid=l_startwindownum-g_reportset.commodity(l_cmid).startdatenum+1;
        else
            l_startwindownum=g_reportset.commodity(l_cmid).startdatenum;
        end
        if l_endwindownum<=g_reportset.commodity(l_cmid).enddatenum
            l_endid=l_endwindownum-g_reportset.commodity(l_cmid).startdatenum+1;
        else
            l_endwindownum=g_reportset.commodity(l_cmid).enddatenum;
        end       
    end
    
    if max(abs(g_reportset.commodity(l_cmid).dailyinfo.margin(l_startid:l_endid)))>0
        if l_setwindow
            % 日期数字
            l_startdatenum=g_reportset.commodity(l_cmid).startdatenum;
            l_enddatenum=g_reportset.commodity(l_cmid).enddatenum;
            % 日期向量
            l_startdatevec=datevec(l_startwindownum);
            l_enddatevec=datevec(l_endwindownum);
            % 年份
            l_yearnum=l_enddatevec(1,1)-l_startdatevec(1,1);    
            g_reference.commodity.name(l_cmid)=g_reportset.commodity(l_cmid).name;
            g_reference.commodity.rightid(l_cmid)=g_reportset.commodity(l_cmid).record.pos.rightid(1);
            % 投入资金
            g_reference.commodity.costinput(l_cmid)=max(abs(g_reportset.commodity(l_cmid).dailyinfo.margin(l_startid:l_endid))); 
            % 下单数量 在此处没有办法计算
            % g_reference.commodity.numoforder(l_cmid)=[]; 
            % 总盈利亏损
            l_tradeprofit=g_reportset.commodity(l_cmid).record.trade.profit(...
                (datenum(g_reportset.commodity(l_cmid).record.trade.cpdate)<=l_endwindownum)&(datenum(g_reportset.commodity(l_cmid).record.trade.opdate)>=l_startwindownum));
            l_posprofit=g_reportset.commodity(l_cmid).record.pos.profit(...
                (datenum(g_reportset.commodity(l_cmid).record.pos.cpdate)<=l_endwindownum)&(datenum(g_reportset.commodity(l_cmid).record.pos.opdate)>=l_startwindownum));            
            g_reference.commodity.totalnetprofit(l_cmid)=g_reportset.commodity(l_cmid).dailyinfo.profit(l_endid)-g_reportset.commodity(l_cmid).dailyinfo.profit(l_startid);   
            % 毛盈利
            g_reference.commodity.grossprofit(l_cmid)=sum(l_tradeprofit(l_tradeprofit>0)); 
            % 毛亏损
            g_reference.commodity.grossloss(l_cmid)=sum(l_tradeprofit(l_tradeprofit<0));
            % 月回报率
            l_monthprofit=zeros(1,(12*(l_yearnum+1)));
            l_yearprofit=zeros(1,(l_yearnum+1));
            l_numofmonth=0;
            l_numofyear=0;
            for l_yearid=l_startdatevec(1,1):l_enddatevec(1,1)
                for l_monthid=1:12
                    l_numofmonth=l_numofmonth+1;
                    l_dayid=eomday(l_yearid,l_monthid);
                    l_dayvec=[l_yearid,l_monthid,l_dayid,0,0,0];
                    l_endofmonthnum=datenum(l_dayvec);
                    % 计算收益
                    l_monthprofit(l_numofmonth)=g_reportset.commodity(l_cmid).dailyinfo.profit(l_endofmonthnum-l_startdatenum+1);
                end
                l_numofyear=l_numofyear+1;
                l_yearprofit(l_numofyear)=l_monthprofit(l_numofmonth);
            end
            l_tradeprofitmonthrate=(l_monthprofit-[0,l_monthprofit(1:(length(l_monthprofit)-1))])/g_reference.commodity.costinput(l_cmid);
            g_reference.commodity.monthreturnrate(l_cmid).data=reshape(l_tradeprofitmonthrate,[12,l_yearnum+1]);
            % 月平均回报率
            l_tradetime=l_endid-l_startid+1;
            l_monthnum=ceil(l_tradetime/30); 
            g_reference.commodity.avemonthreturnrate(l_cmid)=l_monthprofit(l_numofmonth)/g_reference.commodity.costinput(l_cmid)/l_monthnum;
            % 年回报率
            l_tradeprofityearrate=(l_yearprofit-[0,l_yearprofit(1:(length(l_yearprofit)-1))])/g_reference.commodity.costinput(l_cmid);
            g_reference.commodity.yearreturnrate(l_cmid).data=l_tradeprofityearrate; 
            g_reference.commodity.years(l_cmid).data=l_startdatevec(1,1):l_enddatevec(1,1);
            % 年平均回报率
            l_yearnum=ceil(l_tradetime/365); 
            g_reference.commodity.aveyearreturnrate(l_cmid)=l_yearprofit(l_numofyear)/g_reference.commodity.costinput(l_cmid)/l_yearnum;
            % 总交易天数
            g_reference.commodity.totaltradedays(l_cmid)=l_tradetime;
            % 总开仓次数
            g_reference.commodity.totalposnum(l_cmid)=length(l_posprofit);     
            % 总交易次数
            g_reference.commodity.totaltradenum(l_cmid)=length(l_tradeprofit);
            % 平均每天交易次数
            g_reference.commodity.totaltradenumperday(l_cmid)=g_reference.commodity.totaltradenum(l_cmid)/g_reference.commodity.totaltradedays(l_cmid); 
            % 盈利交易次数
            g_reference.commodity.profittradenum(l_cmid)=sum(l_tradeprofit>0); 
            % 亏损交易次数
            g_reference.commodity.losstradenum(l_cmid)=sum(l_tradeprofit<=0);
            % 盈利交易次数的比率
            g_reference.commodity.profittraderate(l_cmid)=g_reference.commodity.profittradenum(l_cmid)/g_reference.commodity.totaltradenum(l_cmid);
            % 最大单笔盈利金额
            g_reference.commodity.maxprofit(l_cmid)=max(l_tradeprofit); 
            % 最大单笔亏损金额
            g_reference.commodity.maxloss(l_cmid)=min(l_tradeprofit);
            % 每单交易盈利
            g_reference.commodity.profitpertrade(l_cmid)=sum(l_tradeprofit(l_tradeprofit>0))....
                /g_reference.commodity.profittradenum(l_cmid); 
            % 每单交易亏损
            g_reference.commodity.losspertrade(l_cmid)=sum(l_tradeprofit(l_tradeprofit<=0))....
                /g_reference.commodity.losstradenum(l_cmid);
            % 总体每单交易盈亏率
            g_reference.commodity.returnpertrade(l_cmid)=sum(l_tradeprofit)....
                /g_reference.commodity.totaltradenum(l_cmid);
            % 期望值
            g_reference.commodity.expectedvalue(l_cmid)=g_reference.commodity.returnpertrade(l_cmid)/abs(g_reference.commodity.losspertrade(l_cmid)); 
            % 最大回退
            [l_maxdrawdown, l_maxdrawdownspread]=maxdrawdown(g_reportset.commodity(l_cmid).dailyinfo.profit(l_startid:l_endid),'arithmetic');
            g_reference.commodity.maxdrawdown(l_cmid)=l_maxdrawdown; 
            % 最大回退
            g_reference.commodity.maxdrawdownspread(l_cmid)=l_maxdrawdownspread(2)-l_maxdrawdownspread(1);
            
        else
            % 日期数字
            l_startdatenum=g_reportset.commodity(l_cmid).startdatenum;
            l_enddatenum=g_reportset.commodity(l_cmid).enddatenum;
            % 日期向量
            l_startdatevec=datevec(g_reportset.commodity(l_cmid).startdatenum);
            l_enddatevec=datevec(g_reportset.commodity(l_cmid).enddatenum);
            % 年份
            l_yearnum=l_enddatevec(1,1)-l_startdatevec(1,1);    
            g_reference.commodity.name(l_cmid)=g_reportset.commodity(l_cmid).name;
            g_reference.commodity.rightid(l_cmid)=g_reportset.commodity(l_cmid).record.pos.rightid(1);
            % 投入资金
            g_reference.commodity.costinput(l_cmid)=max(abs(g_reportset.commodity(l_cmid).dailyinfo.margin)); 
            % 下单数量 在此处没有办法计算
            % g_reference.commodity.numoforder(l_cmid)=[]; 
            % 总盈利亏损
            g_reference.commodity.totalnetprofit(l_cmid)=g_reportset.commodity(l_cmid).dailyinfo.profit(l_enddatenum-l_startdatenum+1);   
            % 毛盈利
            g_reference.commodity.grossprofit(l_cmid)=sum(g_reportset.commodity(l_cmid).record.trade.profit(g_reportset.commodity(l_cmid).record.trade.profit>0)); 
            % 毛亏损
            g_reference.commodity.grossloss(l_cmid)=sum(g_reportset.commodity(l_cmid).record.trade.profit(g_reportset.commodity(l_cmid).record.trade.profit<0));
            % 月回报率
            l_monthprofit=zeros(1,(12*(l_yearnum+1)));
            l_yearprofit=zeros(1,(l_yearnum+1));
            l_numofmonth=0;
            l_numofyear=0;
            for l_yearid=l_startdatevec(1,1):l_enddatevec(1,1)
                for l_monthid=1:12
                    l_numofmonth=l_numofmonth+1;
                    l_dayid=eomday(l_yearid,l_monthid);
                    l_dayvec=[l_yearid,l_monthid,l_dayid,0,0,0];
                    l_endofmonthnum=datenum(l_dayvec);
                    % 计算收益
                    l_monthprofit(l_numofmonth)=g_reportset.commodity(l_cmid).dailyinfo.profit(l_endofmonthnum-l_startdatenum+1);
                end
                l_numofyear=l_numofyear+1;
                l_yearprofit(l_numofyear)=l_monthprofit(l_numofmonth);
            end
            l_tradeprofitmonthrate=(l_monthprofit-[0,l_monthprofit(1:(length(l_monthprofit)-1))])/g_reference.commodity.costinput(l_cmid);
            g_reference.commodity.monthreturnrate(l_cmid).data=reshape(l_tradeprofitmonthrate,[12,l_yearnum+1]);
            % 月平均回报率
            l_tradetime=find(g_reportset.commodity(l_cmid).dailyinfo.posnum>0,1,'last')-find(g_reportset.commodity(l_cmid).dailyinfo.posnum>0,1,'first');
            l_monthnum=ceil(l_tradetime/30); 
            g_reference.commodity.avemonthreturnrate(l_cmid)=l_monthprofit(l_numofmonth)/g_reference.commodity.costinput(l_cmid)/l_monthnum;
            % 年回报率
            l_tradeprofityearrate=(l_yearprofit-[0,l_yearprofit(1:(length(l_yearprofit)-1))])/g_reference.commodity.costinput(l_cmid);
            g_reference.commodity.yearreturnrate(l_cmid).data=l_tradeprofityearrate; 
            g_reference.commodity.years(l_cmid).data=l_startdatevec(1,1):l_enddatevec(1,1);
            % 年平均回报率
            l_yearnum=ceil(l_tradetime/365); 
            g_reference.commodity.aveyearreturnrate(l_cmid)=l_yearprofit(l_numofyear)/g_reference.commodity.costinput(l_cmid)/l_yearnum;
            % 总交易天数
            g_reference.commodity.totaltradedays(l_cmid)=l_tradetime;
            % 总开仓次数
            g_reference.commodity.totalposnum(l_cmid)=g_reportset.commodity(l_cmid).record.pos.num;     
            % 总交易次数
            g_reference.commodity.totaltradenum(l_cmid)=g_reportset.commodity(l_cmid).record.trade.num;
            % 平均每天交易次数
            g_reference.commodity.totaltradenumperday(l_cmid)=g_reference.commodity.totaltradenum(l_cmid)/g_reference.commodity.totaltradedays(l_cmid); 
            % 盈利交易次数
            g_reference.commodity.profittradenum(l_cmid)=sum(g_reportset.commodity(l_cmid).record.trade.profit>0); 
            % 亏损交易次数
            g_reference.commodity.losstradenum(l_cmid)=sum(g_reportset.commodity(l_cmid).record.trade.profit<=0);
            % 盈利交易次数的比率
            g_reference.commodity.profittraderate(l_cmid)=g_reference.commodity.profittradenum(l_cmid)/g_reference.commodity.totaltradenum(l_cmid);
            % 最大单笔盈利金额
            g_reference.commodity.maxprofit(l_cmid)=max(g_reportset.commodity(l_cmid).record.trade.profit); 
            % 最大单笔亏损金额
            g_reference.commodity.maxloss(l_cmid)=min(g_reportset.commodity(l_cmid).record.trade.profit);
            % 每单交易盈利
            g_reference.commodity.profitpertrade(l_cmid)=sum(g_reportset.commodity(l_cmid).record.trade.profit(g_reportset.commodity(l_cmid).record.trade.profit>0))....
                /g_reference.commodity.profittradenum(l_cmid); 
            % 每单交易亏损
            g_reference.commodity.losspertrade(l_cmid)=sum(g_reportset.commodity(l_cmid).record.trade.profit(g_reportset.commodity(l_cmid).record.trade.profit<=0))....
                /g_reference.commodity.losstradenum(l_cmid);
            % 总体每单交易盈亏率
            g_reference.commodity.returnpertrade(l_cmid)=sum(g_reportset.commodity(l_cmid).record.trade.profit)....
                /g_reference.commodity.totaltradenum(l_cmid);
            % 期望值
            g_reference.commodity.expectedvalue(l_cmid)=g_reference.commodity.returnpertrade(l_cmid)/abs(g_reference.commodity.losspertrade(l_cmid)); 
            % 最大回退
            [l_maxdrawdown, l_maxdrawdownspread]=maxdrawdown(g_reportset.commodity(l_cmid).dailyinfo.profit,'arithmetic');
            g_reference.commodity.maxdrawdown(l_cmid)=l_maxdrawdown; 
            % 最大回退
            g_reference.commodity.maxdrawdownspread(l_cmid)=l_maxdrawdownspread(2)-l_maxdrawdownspread(1);
        end
    else 
        % 日期数字
        l_startdatenum=g_reportset.commodity(l_cmid).startdatenum;
        l_enddatenum=g_reportset.commodity(l_cmid).enddatenum;
        % 日期向量
        l_startdatevec=datevec(g_reportset.commodity(l_cmid).startdatenum);
        l_enddatevec=datevec(g_reportset.commodity(l_cmid).enddatenum);
        % 年份
        l_yearnum=l_enddatevec(1,1)-l_startdatevec(1,1);    
        g_reference.commodity.name(l_cmid)=g_reportset.commodity(l_cmid).name;
        % 投入资金
        g_reference.commodity.costinput(l_cmid)=0; 
        % 下单数量 在此处没有办法计算
        % g_reference.commodity.numoforder(l_cmid)=[]; 
        % 总盈利亏损
        g_reference.commodity.totalnetprofit(l_cmid)=0;   
        % 毛盈利
        g_reference.commodity.grossprofit(l_cmid)=0; 
        % 毛亏损
        g_reference.commodity.grossloss(l_cmid)=0;
        % 月回报率
        l_monthprofit=zeros(1,(12*(l_yearnum+1)));
        l_yearprofit=zeros(1,(l_yearnum+1));
        l_numofmonth=0;
        l_numofyear=0;
        for l_yearid=l_startdatevec(1,1):l_enddatevec(1,1)
            for l_monthid=1:12
                l_numofmonth=l_numofmonth+1;
                l_dayid=eomday(l_yearid,l_monthid);
                l_dayvec=[l_yearid,l_monthid,l_dayid,0,0,0];
                l_endofmonthnum=datenum(l_dayvec);
                % 计算收益
                l_monthprofit(l_numofmonth)=g_reportset.commodity(l_cmid).dailyinfo.profit(l_endofmonthnum-l_startdatenum+1);
            end
            l_numofyear=l_numofyear+1;
            l_yearprofit(l_numofyear)=l_monthprofit(l_numofmonth);
        end
        l_tradeprofitmonthrate=(l_monthprofit-[0,l_monthprofit(1:(length(l_monthprofit)-1))]);
        g_reference.commodity.monthreturnrate(l_cmid).data=reshape(l_tradeprofitmonthrate,[12,l_yearnum+1]);
        % 月平均回报率
        g_reference.commodity.avemonthreturnrate(l_cmid)=0;
        % 年回报率
        l_tradeprofityearrate=(l_yearprofit-[0,l_yearprofit(1:(length(l_yearprofit)-1))]);
        g_reference.commodity.yearreturnrate(l_cmid).data=l_tradeprofityearrate; 
        g_reference.commodity.years(l_cmid).data=l_startdatevec(1,1):l_enddatevec(1,1);
        % 年平均回报率
        g_reference.commodity.aveyearreturnrate(l_cmid)=0;
        % 总交易天数
        g_reference.commodity.totaltradedays(l_cmid)=0;
        % 总开仓次数
        g_reference.commodity.totalposnum(l_cmid)=0;     
        % 总交易次数
        g_reference.commodity.totaltradenum(l_cmid)=0;
        % 平均每天交易次数
        g_reference.commodity.totaltradenumperday(l_cmid)=0; 
        % 盈利交易次数
        g_reference.commodity.profittradenum(l_cmid)=0; 
        % 亏损交易次数
        g_reference.commodity.losstradenum(l_cmid)=0;
        % 盈利交易次数的比率
        g_reference.commodity.profittraderate(l_cmid)=0;
        % 最大单笔盈利金额
        g_reference.commodity.maxprofit(l_cmid)=0; 
        % 最大单笔亏损金额
        g_reference.commodity.maxloss(l_cmid)=0;
        % 每单交易盈利
        g_reference.commodity.profitpertrade(l_cmid)=0; 
        % 每单交易亏损
        g_reference.commodity.losspertrade(l_cmid)=0;
        % 总体每单交易盈亏率
        g_reference.commodity.returnpertrade(l_cmid)=0;
        % 期望值
        g_reference.commodity.expectedvalue(l_cmid)=0; 
        % 最大回退
        g_reference.commodity.maxdrawdown(l_cmid)=0; 
        % 最大回退
        g_reference.commodity.maxdrawdownspread(l_cmid)=0;
    end
end
% 计算汇总后的测评指标
% 日期数字
l_startdatenum=g_reportset.startdatenum;
l_enddatenum=g_reportset.enddatenum;
% 日期向量
l_startdatevec=datevec(g_reportset.startdatenum);
l_enddatevec=datevec(g_reportset.enddatenum);
% 年份
l_yearnum=l_enddatevec(1,1)-l_startdatevec(1,1);    
g_reference.name={'总评'};
% 投入资金
g_reference.costinput=max(abs(g_reportset.dailyinfo.margin)); 
% 下单数量
g_reference.commodity.numoforder=floor(max(g_reference.commodity.costinput)./g_reference.commodity.costinput); 
g_reference.numoforder=0;
% 总盈利亏损
g_reference.totalnetprofit=g_reportset.dailyinfo.profit(l_enddatenum-l_startdatenum+1); 
% 毛盈利
g_reference.grossprofit=sum(g_reportset.record.trade.profit(g_reportset.record.trade.profit>0)); 
% 毛亏损
g_reference.grossloss=sum(g_reportset.record.trade.profit(g_reportset.record.trade.profit<0));
% 月回报率
l_monthprofit=zeros(1,(12*(l_yearnum+1)));
l_yearprofit=zeros(1,(l_yearnum+1));
l_numofmonth=0;
l_numofyear=0;
for l_yearid=l_startdatevec(1,1):l_enddatevec(1,1)
    for l_monthid=1:12
        l_numofmonth=l_numofmonth+1;
        l_dayid=eomday(l_yearid,l_monthid);
        l_dayvec=[l_yearid,l_monthid,l_dayid,0,0,0];
        l_endofmonthnum=datenum(l_dayvec);
        % 计算收益
        l_monthprofit(l_numofmonth)=g_reportset.dailyinfo.profit(l_endofmonthnum-l_startdatenum+1);
    end
    l_numofyear=l_numofyear+1;
    l_yearprofit(l_numofyear)=l_monthprofit(l_numofmonth);
end
l_tradeprofitmonthrate=(l_monthprofit-[0,l_monthprofit(1:(length(l_monthprofit)-1))])/g_reference.costinput;
g_reference.monthreturnrate.data=reshape(l_tradeprofitmonthrate,[12,l_yearnum+1]);
% 月平均回报率
l_tradetime=find(g_reportset.dailyinfo.posnum>0,1,'last')-find(g_reportset.dailyinfo.posnum>0,1,'first');
l_monthnum=ceil(l_tradetime/30); 
g_reference.avemonthreturnrate=l_monthprofit(l_numofmonth)/g_reference.costinput/l_monthnum;
% 年回报率
l_tradeprofityearrate=(l_yearprofit-[0,l_yearprofit(1:(length(l_yearprofit)-1))])/g_reference.costinput;
g_reference.yearreturnrate.data=l_tradeprofityearrate; 
g_reference.years.data=l_startdatevec(1,1):l_enddatevec(1,1);
% 年平均回报率
l_yearnum=ceil(l_tradetime/365); 
g_reference.aveyearreturnrate=l_yearprofit(l_numofyear)/g_reference.costinput/l_yearnum;
% 总交易天数
g_reference.totaltradedays=l_tradetime;
% 总开仓次数
g_reference.totalposnum=g_reportset.record.pos.num;     
% 总交易次数
g_reference.totaltradenum=g_reportset.record.trade.num;
% 平均每天交易次数
g_reference.totaltradenumperday=g_reference.totaltradenum/g_reference.totaltradedays; 
% 盈利交易次数
g_reference.profittradenum=sum(g_reportset.record.trade.profit>0); 
% 亏损交易次数
g_reference.losstradenum=sum(g_reportset.record.trade.profit<=0);
% 盈利交易次数的比率
g_reference.profittraderate=g_reference.profittradenum/g_reference.totaltradenum;
% 最大单笔盈利金额
g_reference.maxprofit=max(g_reportset.record.trade.profit); 
% 最大单笔亏损金额
g_reference.maxloss=min(g_reportset.record.trade.profit);
% 每单交易盈利
g_reference.profitpertrade=sum(g_reportset.record.trade.profit(g_reportset.record.trade.profit>0))....
    /g_reference.profittradenum; 
% 每单交易亏损
g_reference.losspertrade=sum(g_reportset.record.trade.profit(g_reportset.record.trade.profit<=0))....
    /g_reference.losstradenum;
% 总体每单交易盈亏率
g_reference.returnpertrade=sum(g_reportset.record.trade.profit)....
    /g_reference.totaltradenum;
% 期望值
g_reference.expectedvalue=g_reference.returnpertrade/abs(g_reference.losspertrade); 
% 最大回退
[l_maxdrawdown, l_maxdrawdownspread]=maxdrawdown(g_reportset.dailyinfo.profit,'arithmetic');
g_reference.maxdrawdown=l_maxdrawdown; 
% 最大回退
g_reference.maxdrawdownspread=l_maxdrawdownspread(2)-l_maxdrawdownspread(1);
% 计算排序
l_titlenames=fieldnames(g_reference.sort);
if ~isempty(l_titlenames)
    l_sortid=[];
    l_weight=zeros(1,length(l_titlenames));
    for l_titleid=1:length(l_titlenames)
        l_commandstr=sprintf('l_weight(l_titleid)=g_reference.sort.%s.weight;',l_titlenames{l_titleid});
        eval(l_commandstr);
        l_commandstr=sprintf('[l_sortvalue,l_sortid(l_titleid,:)]=sort(g_reference.commodity.%s,2,g_reference.sort.%s.direction);',...
            l_titlenames{l_titleid},l_titlenames{l_titleid});
        eval(l_commandstr);
        l_commandstr=sprintf('g_reference.sort.%s.order=g_reference.commodity.name(l_sortid(l_titleid,:));',l_titlenames{l_titleid});
        eval(l_commandstr);
    end
    [l_sortvalue,l_orderarray]=sort(l_sortid,2,'ascend');
    l_totalweight=sum(l_orderarray.*repmat(l_weight',1,length(g_reportset.commodity)),1);
    [l_sortvalue,l_sortid((length(l_titlenames)+1),:)]=sort(l_totalweight,2);
    g_reference.sortorder=g_reference.commodity.name(l_sortid((length(l_titlenames)+1),:));
end
end