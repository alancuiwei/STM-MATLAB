function ZR_PROCESS_CollectReport()
%%%%%%%% 汇总测试报告
global g_report;
% 开始交易的日期，合并dailyinfo中的margin,posnum,profit,tradecharge数据使用
l_startdatenum=min(cat(1,g_report.commodity(:).startdatenum));
l_startdatevec=datevec(l_startdatenum);
l_startdatenum=datenum([l_startdatevec(1),1,1,0,0,0]);
g_report.startdatenum=l_startdatenum;
l_enddatenum=max(cat(1,g_report.commodity(:).enddatenum));
l_enddatevec=datevec(l_enddatenum);
l_enddatenum=datenum([l_enddatevec(1),12,31,0,0,0]);
g_report.enddatenum=l_enddatenum;
% 初始化时间保证金向量
g_report.dailyinfo.dailydatenum=l_startdatenum:l_enddatenum;
% 初始化时间保证金向量
g_report.dailyinfo.margin=zeros(1,(l_enddatenum-l_startdatenum+1));
% 初始化时间仓位向量
g_report.dailyinfo.posnum=zeros(1,(l_enddatenum-l_startdatenum+1));
% 初始化时间获利向量
g_report.dailyinfo.profit=zeros(1,(l_enddatenum-l_startdatenum+1));
% 初始化交易费
g_report.dailyinfo.tradecharge=zeros(1,(l_enddatenum-l_startdatenum+1));
% l_posid=0;
% l_tradeid=0;
for l_cmid=1:length(g_report.commodity)
     % 没有报告
    if(g_report.commodity(l_cmid).record.pos.num<1)
%         fprintf('%s:无交易',g_report.commodity(l_cmid).name);
        continue;
    end 
    % pos 仓位报告    
    l_titlenames=fieldnames(g_report.record.pos);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
            if eval(l_judge)
                l_commandstr=strcat(l_commandstr,sprintf('g_report.record.pos.%s=g_report.record.pos.%s+g_report.commodity(l_cmid).record.pos.%s;',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));
            else
                l_commandstr=strcat(l_commandstr,sprintf('g_report.record.pos.%s=[g_report.record.pos.%s,g_report.commodity(l_cmid).record.pos.%s];',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));            
            end     
        end
    end
    eval(l_commandstr);       
%     % trade 交易报告   
%     l_titlenames=fieldnames(g_report.record.trade);
%     l_commandstr='';
%     if ~isempty(l_titlenames)
%         for l_titleid=1:length(l_titlenames)
%             l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
%             if eval(l_judge)
%                 l_commandstr=strcat(l_commandstr,sprintf('g_report.record.trade.%s=g_report.record.trade.%s+g_report.commodity(l_cmid).record.trade.%s;',...
%                     l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));
%             else
%                 l_commandstr=strcat(l_commandstr,sprintf('g_report.record.trade.%s=[g_report.record.trade.%s,g_report.commodity(l_cmid).record.trade.%s];',...
%                     l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));            
%             end     
%         end
%     end
%     eval(l_commandstr);  
    % 汇总daily信息
    l_startdateid=g_report.commodity(l_cmid).startdatenum-l_startdatenum+1;
    l_enddateid=g_report.commodity(l_cmid).enddatenum-l_startdatenum+1;
    g_report.dailyinfo.margin(l_startdateid:l_enddateid)=g_report.dailyinfo.margin(l_startdateid:l_enddateid)+g_report.commodity(l_cmid).dailyinfo.margin;
    g_report.dailyinfo.posnum(l_startdateid:l_enddateid)=g_report.dailyinfo.posnum(l_startdateid:l_enddateid)+g_report.commodity(l_cmid).dailyinfo.posnum;
    g_report.dailyinfo.profit(l_startdateid:l_enddateid)=g_report.dailyinfo.profit(l_startdateid:l_enddateid)+g_report.commodity(l_cmid).dailyinfo.profit;
    g_report.dailyinfo.tradecharge(l_startdateid:l_enddateid)=g_report.dailyinfo.tradecharge(l_startdateid:l_enddateid)...
        +g_report.commodity(l_cmid).dailyinfo.tradecharge; 
end
end