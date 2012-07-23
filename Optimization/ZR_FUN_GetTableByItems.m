function out_table=ZR_FUN_GetTableByItems(in_varstr)
% 根据item得到title名称，item必须包含title的属性;
global g_tables;
global g_reportset;
global g_reference;
l_titlestr='';
l_datastr='';
switch in_varstr
    case 'pos'
        l_titlenames=fieldnames(g_tables.record.pos);
        if ~isempty(l_titlenames)
            for l_titleid=1:length(l_titlenames)
                l_titlestr=strcat(l_titlestr,',','g_tables.record.pos.',l_titlenames{l_titleid},'.title');
                if (eval(strcat('iscell(g_reportset.record.pos.',l_titlenames{l_titleid},')')))
                    l_datastr=strcat(l_datastr,';','g_reportset.record.pos.',l_titlenames{l_titleid});
                else
                    l_datastr=strcat(l_datastr,';','num2cell(g_reportset.record.pos.',l_titlenames{l_titleid},')');
                end                
            end
            % 把第一个逗号去除掉
            l_titlestr(1)=[];
            l_datastr(1)=[];
            % 将参数加到方法中
            l_commandstr=sprintf('out_table=[{%s};[%s]''];',l_titlestr,l_datastr);
            eval(l_commandstr);
        else
            error('%s没有title属性',in_varstr);
            out_table={};
        end
     case 'trade'
        l_titlenames=fieldnames(g_tables.record.trade);
        if ~isempty(l_titlenames)
            for l_titleid=1:length(l_titlenames)
                l_titlestr=strcat(l_titlestr,',','g_tables.record.trade.',l_titlenames{l_titleid},'.title');
                if (eval(strcat('iscell(g_reportset.record.trade.',l_titlenames{l_titleid},')')))
                    l_datastr=strcat(l_datastr,';','g_reportset.record.trade.',l_titlenames{l_titleid});
                else
                    l_datastr=strcat(l_datastr,';','num2cell(g_reportset.record.trade.',l_titlenames{l_titleid},')');                    
                end
            end
            % 把第一个逗号去除掉
            l_titlestr(1)=[];
            l_datastr(1)=[];
            % 将参数加到方法中
            l_commandstr=sprintf('out_table=[{%s};[%s]''];',l_titlestr,l_datastr);
            eval(l_commandstr);
        else
            error('%s没有title属性',in_varstr);
            out_table={};
        end
     case 'reference'   
        l_titlenames=fieldnames(g_tables.reference);
        if ~isempty(l_titlenames)
            for l_titleid=1:length(l_titlenames)
                l_titlestr=strcat(l_titlestr,';','g_tables.reference.',l_titlenames{l_titleid},'.title');
                if (eval(strcat('iscell(g_reference.commodity.',l_titlenames{l_titleid},')')))
                    l_datastr=strcat(l_datastr,';','g_reference.commodity.',l_titlenames{l_titleid},',g_reference.',l_titlenames{l_titleid});
                else
                    l_datastr=strcat(l_datastr,';','num2cell([g_reference.commodity.',l_titlenames{l_titleid},',g_reference.',l_titlenames{l_titleid},'])');
                end    
            end
            % 把第一个逗号去除掉
            l_datastr(1)=[];
            % 将参数加到方法中
            l_commandstr=sprintf('out_table=[{%s},[%s]];',l_titlestr,l_datastr);
            eval(l_commandstr);
        else
            error('%s没有title属性',in_varstr);
            out_table={};
        end          
     case 'sort'
        l_titlenames=fieldnames(g_reference.sort);
        if ~isempty(l_titlenames)
            l_sortid={};
            for l_titleid=1:length(l_titlenames)
                l_titlestr=strcat(l_titlestr,',','g_tables.reference.',l_titlenames{l_titleid},'.title');
                l_commandstr=sprintf('l_sortid(l_titleid,:)=g_reference.sort.%s.order;',...
                    l_titlenames{l_titleid});
                eval(l_commandstr);
            end
            % 把第一个逗号去除掉
            l_titlestr(1)=[];
            l_titles=[];          
            % 将参数加到方法中
            l_commandstr=sprintf('l_titles={''排名号'',%s,''最终排名''};',l_titlestr);
            eval(l_commandstr);   
            l_sortid((length(l_titlenames)+1),:)=g_reference.sortorder;
            % 输出
            out_table=[l_titles',[num2cell(1:length(g_reportset.commodity));l_sortid]];      
        else
            error('%s没有title属性',in_varstr);
            out_table={};
        end           
         
%         l_titlenames=fieldnames(g_tables.sort);
%         if ~isempty(l_titlenames)
%             l_sortvalue=[];
%             l_sortid=[];
%             l_weight=zeros(1,length(l_titlenames));
%             for l_titleid=1:length(l_titlenames)
%                 l_titlestr=strcat(l_titlestr,',','g_tables.reference.',l_titlenames{l_titleid},'.title');
%                 l_commandstr=sprintf('l_weight(l_titleid)=g_tables.sort.%s.weight;',l_titlenames{l_titleid});
%                 eval(l_commandstr);
%                 l_commandstr=sprintf('[l_sortvalue,l_sortid(l_titleid,:)]=sort(g_reference.commodity.%s,2,g_tables.sort.%s.direction);',...
%                     l_titlenames{l_titleid},l_titlenames{l_titleid});
%                 eval(l_commandstr);
%             end
%             l_orderarray=repmat(1:length(g_report.commodity),length(l_titlenames),1);
%             l_totalweight=sum(l_orderarray(l_sortid).*repmat(l_weight',1,length(g_report.commodity)),1);
%             [l_sortvalue, l_sortid((length(l_titlenames)+1),:)]=sort(l_totalweight,2);
%             % 把第一个逗号去除掉
%             l_titlestr(1)=[];
%             l_titles=[];          
%             % 将参数加到方法中
%             l_commandstr=sprintf('l_titles={''排名号'',%s,''最终排名''};',l_titlestr);
%             eval(l_commandstr);   
%             % 输出
%             out_table=[l_titles',[num2cell(1:length(g_report.commodity));g_reference.commodity.name(l_sortid)]];      
%         else
%             error('%s没有title属性',in_varstr);
%             out_table={};
%         end           
end

end