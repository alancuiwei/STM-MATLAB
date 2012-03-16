function ZR_PROCESS_MergeReportset()
% 把report进行合并，成为reportset

global g_reportset;
global g_report;

if isempty(g_reportset)
    g_reportset=g_report;
else
    % 建仓记录
    l_titlenames=fieldnames(g_report.record.pos);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
            if eval(l_judge)
                l_commandstr=strcat(l_commandstr,sprintf('g_reportset.record.pos.%s=g_reportset.record.pos.%s+g_report.record.pos.%s;',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));
            else
                l_commandstr=strcat(l_commandstr,sprintf('g_reportset.record.pos.%s=[g_reportset.record.pos.%s,g_report.record.pos.%s];',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));            
            end     
        end
    end
    eval(l_commandstr);   
    % 交易记录
    l_titlenames=fieldnames(g_report.record.trade);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
            if eval(l_judge)
                l_commandstr=strcat(l_commandstr,sprintf('g_reportset.record.trade.%s=g_reportset.record.trade.%s+g_report.record.trade.%s;',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));
            else
                l_commandstr=strcat(l_commandstr,sprintf('g_reportset.record.trade.%s=[g_reportset.record.trade.%s,g_report.record.trade.%s];',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));            
            end     
        end
    end
    eval(l_commandstr);  
    % daily的信息
    l_titlenames=fieldnames(g_report.dailyinfo);
    l_commandstr='';
    if ~isempty(l_titlenames)
        for l_titleid=1:length(l_titlenames)
            l_commandstr=strcat(l_commandstr,sprintf('g_reportset.dailyinfo.%s=g_reportset.dailyinfo.%s+g_report.dailyinfo.%s;',...
                l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid})); 
        end
    end
    eval(l_commandstr);    
    
    % 各个品种
    for l_cmid=1:length(g_report.commodity)
         % 没有报告
        if(g_report.commodity(l_cmid).record.pos.num<1)
            continue;
        end 
        % 建仓记录
        l_titlenames=fieldnames(g_report.record.pos);
        l_commandstr='';
        if ~isempty(l_titlenames)
            for l_titleid=1:length(l_titlenames)
                l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
                if eval(l_judge)
                    l_commandstr=strcat(l_commandstr,...
                        sprintf('g_reportset.commodity(l_cmid).record.pos.%s=g_reportset.commodity(l_cmid).record.pos.%s+g_report.commodity(l_cmid).record.pos.%s;',...
                        l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));
                else
                    l_commandstr=strcat(l_commandstr,...
                        sprintf('g_reportset.commodity(l_cmid).record.pos.%s=[g_reportset.commodity(l_cmid).record.pos.%s,g_report.commodity(l_cmid).record.pos.%s];',...
                        l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));            
                end     
            end
        end
        eval(l_commandstr);   
        % 交易记录
        l_titlenames=fieldnames(g_report.record.trade);
        l_commandstr='';
        if ~isempty(l_titlenames)
            for l_titleid=1:length(l_titlenames)
                l_judge=sprintf('strcmp(''%s'',''num'')',l_titlenames{l_titleid});
                if eval(l_judge)
                    l_commandstr=strcat(l_commandstr,...
                        sprintf('g_reportset.commodity(l_cmid).record.trade.%s=g_reportset.commodity(l_cmid).record.trade.%s+g_report.commodity(l_cmid).record.trade.%s;',...
                        l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));
                else
                    l_commandstr=strcat(l_commandstr,...
                        sprintf('g_reportset.commodity(l_cmid).record.trade.%s=[g_reportset.commodity(l_cmid).record.trade.%s,g_report.commodity(l_cmid).record.trade.%s];',...
                        l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));            
                end     
            end
        end
        eval(l_commandstr);  
        % daily的信息
        l_titlenames=fieldnames(g_report.dailyinfo);
        l_commandstr='';
        if ~isempty(l_titlenames)
            for l_titleid=1:length(l_titlenames)
                l_commandstr=strcat(l_commandstr,...
                    sprintf('g_reportset.commodity(l_cmid).dailyinfo.%s=g_reportset.commodity(l_cmid).dailyinfo.%s+g_report.commodity(l_cmid).dailyinfo.%s;',...
                    l_titlenames{l_titleid},l_titlenames{l_titleid},l_titlenames{l_titleid}));  
            end
        end
        eval(l_commandstr); 
    end    
end

end