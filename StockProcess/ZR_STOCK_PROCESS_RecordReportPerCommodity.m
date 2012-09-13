function ZR_STOCK_PROCESS_RecordReportPerCommodity(in_cmid)
%%%%%%%% 计算每一个品种的报告信息
global g_tradedata;
global g_report;
global g_rawdata;
% 遍历该品种所有的套利对
l_pairnum=length(g_tradedata);
l_tradeid=0;
l_posid=0;
g_report.commodity(in_cmid).name=g_rawdata.commodity.name;
g_report.commodity(in_cmid).record.pos.num=0;
for l_pairid=1:l_pairnum
    if(isempty(g_tradedata(l_pairid).pos.num))
%         fprintf('%s:无交易\n',cell2mat(g_tradedata(l_pairid).pos.name));
        continue;
    end    
    % pos 仓位报告    
    l_titlenames=fieldnames(g_report.record.pos);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
            if eval(l_judge)
                l_commandstr=strcat(l_commandstr,...
                    sprintf('g_report.commodity(in_cmid).record.pos.%s=l_posid+g_tradedata(l_pairid).pos.%s;',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid}));
            else
                l_commandstr=strcat(l_commandstr,...
                    sprintf('g_report.commodity(in_cmid).record.pos.%s((l_posid+1):g_report.commodity(in_cmid).record.pos.num)',...
                    l_titlenames{l_titleid}),sprintf('=g_tradedata(l_pairid).pos.%s;',l_titlenames{l_titleid}));            
            end     
        end
    end
    eval(l_commandstr);  
    l_posid=g_report.commodity(in_cmid).record.pos.num;
%     % trade 交易报告   
%     l_titlenames=fieldnames(g_report.record.trade);
%     l_commandstr='';
%     if ~isempty(l_titlenames)
%         for l_titleid=1:length(l_titlenames)
%             l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
%             if eval(l_judge)
%                 l_commandstr=strcat(l_commandstr,...
%                     sprintf('g_report.commodity(in_cmid).record.trade.%s=l_tradeid+g_tradedata(l_pairid).trade.%s;',...
%                     l_titlenames{l_titleid},l_titlenames{l_titleid}));
%             else
%                 l_commandstr=strcat(l_commandstr,...
%                     sprintf('g_report.commodity(in_cmid).record.trade.%s((l_tradeid+1):g_report.commodity(in_cmid).record.trade.num)',...
%                     l_titlenames{l_titleid}),sprintf('=g_tradedata(l_pairid).trade.%s;',l_titlenames{l_titleid}));             
%             end     
%         end
%     end
%     eval(l_commandstr);      
%     l_tradeid=g_report.commodity(in_cmid).record.trade.num;
end

% 日期数字
% l_startdatenum=min(l_opdatenums);
try
%     l_startdatenum=datenum(g_rawdata.contract(1).mkdata.date{1},'yyyy-mm-dd');
    l_startdatenum=datenum(g_rawdata.commodity.serialmkdata.date{1},'yyyy-mm-dd');
catch
    l_startdatenum=datenum(g_rawdata.pair(1).mkdata.date{1},'yyyy-mm-dd');
end
l_startdatevec=datevec(l_startdatenum);
l_startdatenum=datenum([l_startdatevec(1),1,1,0,0,0]);
% 一年第一天
g_report.commodity(in_cmid).startdatenum=l_startdatenum;
% l_enddatenum=max(l_cpdatenums);
try
%     l_enddatenum=datenum(g_rawdata.contract(end).mkdata.date{end},'yyyy-mm-dd');    
    l_enddatenum=datenum(g_rawdata.commodity.serialmkdata.date{end},'yyyy-mm-dd'); 
catch
    l_enddatenum=datenum(g_rawdata.pair(end).mkdata.date{end},'yyyy-mm-dd');
end
l_enddatevec=datevec(l_enddatenum);
l_enddatenum=datenum([l_enddatevec(1),12,31,0,0,0]);
% 一年最后一天
g_report.commodity(in_cmid).enddatenum=l_enddatenum;
if g_report.commodity(in_cmid).record.pos.num>0
    l_opdatenums=datenum(g_report.commodity(in_cmid).record.pos.opdate,'yyyy-mm-dd');
    l_opdateids=l_opdatenums-l_startdatenum+1;
    l_cpdatenums=datenum(g_report.commodity(in_cmid).record.pos.cpdate,'yyyy-mm-dd');
    l_cpdateids=l_cpdatenums-l_startdatenum+1;
    % 开仓的日期id
    % l_opids=unique(l_opdateids);
    % l_opcounts=histc(l_opdateids,l_opids);
    % 平仓的日期id
    % l_cpids=unique(l_cpdateids);
    %l_cpcounts=histc(l_cpdateids,l_cpids);
    % 保证金 可以优化
    % 计算daily数据：margin,profit,posnum,tradecharge
    % 初始化时间保证金向量
    g_report.commodity(in_cmid).dailyinfo.margin=zeros(1,(l_enddatenum-l_startdatenum+2));
    % 初始化时间仓位向量
    g_report.commodity(in_cmid).dailyinfo.posnum=zeros(1,(l_enddatenum-l_startdatenum+2));
    % 初始化时间获利向量
    g_report.commodity(in_cmid).dailyinfo.profit=zeros(1,(l_enddatenum-l_startdatenum+2));
    % 初始化交易费
    g_report.commodity(in_cmid).dailyinfo.tradecharge=zeros(1,(l_enddatenum-l_startdatenum+2));
    for l_index=1:length(l_opdateids)
        % 保证金
        g_report.commodity(in_cmid).dailyinfo.margin(l_opdateids(l_index))=...
            g_report.commodity(in_cmid).dailyinfo.margin(l_opdateids(l_index))+g_report.commodity(in_cmid).record.pos.margin(l_index);
        g_report.commodity(in_cmid).dailyinfo.margin(l_cpdateids(l_index)+1)=...
            g_report.commodity(in_cmid).dailyinfo.margin(l_cpdateids(l_index)+1)-g_report.commodity(in_cmid).record.pos.margin(l_index);
        % 仓位
        g_report.commodity(in_cmid).dailyinfo.posnum(l_opdateids(l_index))=...
            g_report.commodity(in_cmid).dailyinfo.posnum(l_opdateids(l_index))+1;
        g_report.commodity(in_cmid).dailyinfo.posnum(l_cpdateids(l_index)+1)=...
            g_report.commodity(in_cmid).dailyinfo.posnum(l_cpdateids(l_index)+1)-1;
        % 交易费
        g_report.commodity(in_cmid).dailyinfo.tradecharge(l_opdateids(l_index))=...
            g_report.commodity(in_cmid).dailyinfo.tradecharge(l_opdateids(l_index))+g_report.commodity(in_cmid).record.pos.optradecharge(l_index);
        g_report.commodity(in_cmid).dailyinfo.tradecharge(l_cpdateids(l_index))=...
            g_report.commodity(in_cmid).dailyinfo.tradecharge(l_cpdateids(l_index))+g_report.commodity(in_cmid).record.pos.cptradecharge(l_index);
        % 收益,应该从开仓日期开始从收益中扣除开仓手续费
        g_report.commodity(in_cmid).dailyinfo.profit(l_opdateids(l_index))=...
            g_report.commodity(in_cmid).dailyinfo.profit(l_opdateids(l_index))-g_report.commodity(in_cmid).record.pos.optradecharge(l_index); 
        g_report.commodity(in_cmid).dailyinfo.profit(l_cpdateids(l_index))=...
            g_report.commodity(in_cmid).dailyinfo.profit(l_cpdateids(l_index))+g_report.commodity(in_cmid).record.pos.profit(l_index)...
            +g_report.commodity(in_cmid).record.pos.optradecharge(l_index);  
    end
    % 扩大到每天的影响
    % 初始化时间保证金向量
    g_report.commodity(in_cmid).dailyinfo.margin=g_report.commodity(in_cmid).dailyinfo.margin(1:end-1);
    % 初始化时间仓位向量
    g_report.commodity(in_cmid).dailyinfo.posnum=g_report.commodity(in_cmid).dailyinfo.posnum(1:end-1);
    % 初始化时间获利向量
    g_report.commodity(in_cmid).dailyinfo.profit=g_report.commodity(in_cmid).dailyinfo.profit(1:end-1);
    % 初始化交易费
    g_report.commodity(in_cmid).dailyinfo.tradecharge=g_report.commodity(in_cmid).dailyinfo.tradecharge(1:end-1);  
    
    g_report.commodity(in_cmid).dailyinfo.margin=cumsum(g_report.commodity(in_cmid).dailyinfo.margin);
    g_report.commodity(in_cmid).dailyinfo.posnum=cumsum(g_report.commodity(in_cmid).dailyinfo.posnum);
    g_report.commodity(in_cmid).dailyinfo.tradecharge=cumsum(g_report.commodity(in_cmid).dailyinfo.tradecharge);
    g_report.commodity(in_cmid).dailyinfo.profit=cumsum(g_report.commodity(in_cmid).dailyinfo.profit);

    % l_margins=g_report.commodity(in_cmid).record.pos.margin;
    % for l_index=1:max(l_opcounts)
    %     % 开仓数相同的那些天
    %     l_days=l_opids(l_opcounts==l_index);
    %     g_report.commodity(in_cmid).dailyinfo.margin(l_days)=
    %     sum(l_margins(l_opids(l_opcounts==l_index)))
    % end
else
    % 初始化时间保证金向量
    g_report.commodity(in_cmid).dailyinfo.margin=zeros(1,(l_enddatenum-l_startdatenum+1));
    % 初始化时间仓位向量
    g_report.commodity(in_cmid).dailyinfo.posnum=zeros(1,(l_enddatenum-l_startdatenum+1));
    % 初始化时间获利向量
    g_report.commodity(in_cmid).dailyinfo.profit=zeros(1,(l_enddatenum-l_startdatenum+1));
    % 初始化交易费
    g_report.commodity(in_cmid).dailyinfo.tradecharge=zeros(1,(l_enddatenum-l_startdatenum+1));
end    
    % 初始化时间向量
    g_report.commodity(in_cmid).dailyinfo.dailydatenum=l_startdatenum:l_enddatenum;
end
