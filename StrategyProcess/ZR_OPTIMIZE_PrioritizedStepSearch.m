function ZR_OPTIMIZE_PrioritizedStepSearch(varargin)
% 网格计算，参数配对
% param1代表第一个参数（商品周期），param2代表第二个参数（止损点）
% 计算的网格存放在g_paramgrid里

global g_optimization;



% 参数 分析参数个数
%l_parmstr=[];
l_disstr=[];
if nargin>0
    l_len(nargin/2)=0;
    for l_paramid=1:(nargin/2)
        l_len(l_paramid)=length(varargin{l_paramid*2});
        g_optimization.range{l_paramid}=varargin{l_paramid*2};
        g_optimization.paramname{l_paramid}=varargin{l_paramid*2-1};
        l_disstr=strcat(l_disstr,'''',g_optimization.paramname{l_paramid},':'',num2str(l_paramid',num2str(l_paramid),'),''; ''');
        %l_parmstr=strcat(l_parmstr,'''',g_optimization.paramname{l_paramid},''',l_paramid',num2str(l_paramid)); 
        if l_paramid~=(nargin/2)
            %l_parmstr=strcat(l_parmstr,',');
            l_disstr=strcat(l_disstr,',');
        end    
    end
else  
    l_len=zeros(length(g_optimization.adjustparams),1);
    for l_paramid=1:length(g_optimization.adjustparams)
        l_len(l_paramid)=length(g_optimization.adjustparams{l_paramid}.data);
        g_optimization.range{l_paramid}=g_optimization.adjustparams{l_paramid}.data;
        g_optimization.paramname(l_paramid)=g_optimization.adjustparams{l_paramid}.name;
        l_disstr=strcat(l_disstr,'''',g_optimization.paramname{l_paramid},':'',num2str(l_paramid',num2str(l_paramid),'),''; ''');
%         l_parmstr=strcat(l_parmstr,'''',g_optimization.paramname{l_paramid},''',l_paramid',num2str(l_paramid)); 
        if l_paramid~=length(g_optimization.adjustparams)
%             l_parmstr=strcat(l_parmstr,',');
            l_disstr=strcat(l_disstr,',');
        end            
    end    
    
%     l_titlenames=fieldnames(g_optimization.adjustparams);
%     l_len(length(l_titlenames))=0;
%     if ~isempty(l_titlenames)
%         for l_paramid=1:length(l_titlenames)
%             l_commandstr=sprintf('l_len(l_paramid)=length(g_optimization.adjustparams.%s.data);',l_titlenames{l_paramid});
%             eval(l_commandstr);
%             l_commandstr=sprintf('g_optimization.range{l_paramid}=g_optimization.adjustparams.%s.data;',l_titlenames{l_paramid});
%             eval(l_commandstr);
%             g_optimization.paramname(l_paramid)=l_titlenames(l_paramid);
%             l_disstr=strcat(l_disstr,'''',g_optimization.paramname{l_paramid},':'',num2str(l_paramid',num2str(l_paramid),'),''; ''');
%             %l_parmstr=strcat(l_parmstr,'''',g_optimization.paramname{l_paramid},''',l_paramid',num2str(l_paramid)); 
%             if l_paramid~=length(l_titlenames)
%                 %l_parmstr=strcat(l_parmstr,',');
%                 l_disstr=strcat(l_disstr,',');
%             end               
%         end      
%     end       
end


% 计算总共有的参数组
g_optimization.paramnum=length(g_optimization.paramname);
g_optimization.valuenum=sum(l_len);    %这个数字不准确
%disp(strcat('参数组合有：',num2str(g_optimization.valuenum),'组'));
% if(g_optimization.valuenum>10000)
%     disp('参数组合太多，目前限制为10000，如果确实需要，请修改ZR_OPTIMIZE_GridSearch中的限制！');
%     return;
% end


%初始化最优参数
l_bestparam = zeros(1,g_optimization.paramnum);
for l_paramid = 1 : g_optimization.paramnum
    l_bestparam(l_paramid) =  g_optimization.range{l_paramid}(1); 
end

%确定迭代次数
l_numberOfIteration = 3;

%优先步骤搜索
for l_iteration = 1 : l_numberOfIteration
   
    for l_paramid = 1 : g_optimization.paramnum
        
        for l_currentparam = g_optimization.range{l_paramid}
        
            l_parmstr = [];
        
            if l_paramid > 1
                for l_i = 1 : l_paramid - 1;
                    l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_bestparam(l_i)));
                    l_parmstr = strcat(l_parmstr, ',');
                end
            end
        
            l_parmstr = strcat(l_parmstr, '''',g_optimization.paramname{l_paramid},'''',',',num2str(l_currentparam));
            
            
            if l_paramid < g_optimization.paramnum
                l_parmstr = strcat(l_parmstr, ',');
                for l_i = l_paramid + 1 : g_optimization.paramnum
                    l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_bestparam(l_i)));
                    if l_i < g_optimization.paramnum
                        l_parmstr = strcat(l_parmstr, ',');
                    end
                end
            end
            
            disp(l_parmstr);
            
            l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');
            
            eval(l_commandstr);
        end
        
        l_length1 = length(g_optimization.expectedvalue);
        l_length2 = length(g_optimization.range{l_paramid});
        [l_temp ,l_index] = max(g_optimization.expectedvalue(l_length1 - l_length2 + 1 : l_length1)); 
        l_index = l_index + l_length1 - l_length2;
        l_bestparam = g_optimization.param{l_index};        
    end
    
    if l_iteration == l_numberOfIteration
        disp('最优参数组为：');
        disp(l_bestparam);
    end
end

end