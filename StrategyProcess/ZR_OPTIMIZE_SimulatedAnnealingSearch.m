function ZR_OPTIMIZE_SimulatedAnnealingSearch(varargin)
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
g_optimization.valuenum=sum(l_len);               %这个数字不准确
%disp(strcat('参数组合有：',num2str(g_optimization.valuenum),'组'));
% if(g_optimization.valuenum>10000)
%     disp('参数组合太多，目前限制为10000，如果确实需要，请修改ZR_OPTIMIZE_GridSearch中的限制！');
%     return;
% end



l_Currentpoint = zeros(1, g_optimization.paramnum);       %记录当前点各参数的值
l_size = zeros(1, g_optimization.paramnum);               %用于记录每个参数有多少种可能性
l_position = zeros(1, g_optimization.paramnum);           %记录当前点各参数的位置
l_kmax = 50;                                              %搜索次数

%检查每个参数的可能性个数&随机选择初始点
for l_paramid = 1 : g_optimization.paramnum
    l_size(l_paramid) = length(g_optimization.range{l_paramid});
    l_position(l_paramid) = ceil(l_size(l_paramid)*rand());
    l_Currentpoint(l_paramid) =  g_optimization.range{l_paramid}(l_position(l_paramid)); 
end


%计算初始点的收益值
l_parmstr = [];
            
for l_i = 1 : g_optimization.paramnum
                
    l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_Currentpoint(l_i)));

    if l_i < g_optimization.paramnum
        l_parmstr = strcat(l_parmstr, ',');
    end
    
end
    
disp(l_parmstr);
    
l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');
            
eval(l_commandstr);



l_GlobalBestProfit = g_optimization.expectedvalue(1);      %用于记录已找到的最大收益
l_GlobalBestParam = g_optimization.param{1};               %用于记录已找到的最优参数组合
l_profit = g_optimization.expectedvalue(1);                %当前点的收益

l_constant = [-1,0,1];   %用于生成邻域点
 
l_k = 0;

while l_k < l_kmax

    %随机选择邻域点
    l_neighbour = zeros(1, g_optimization.paramnum);
    
    l_newposition = zeros(1, g_optimization.paramnum);
    
    l_movedirection = zeros(1, g_optimization.paramnum);
    
    l_loopnumber = 0;  %防止无限循环
    
    while 1
        
        for l_paramid = 1 : g_optimization.paramnum
            l_movedirection(l_paramid) = l_constant(ceil(rand()*3));
            l_newposition(l_paramid) = min(max(1, l_position(l_paramid) + l_movedirection(l_paramid)), l_size(l_paramid));
            l_neighbour(l_paramid) = g_optimization.range{l_paramid}(l_newposition(l_paramid));
        end
        
        l_nonverified = isempty(find(cell2mat(cellfun(@(x) (isequal(x,l_neighbour)), g_optimization.param, 'UniformOutput', false)), 1));
        
        if l_nonverified == 1
           l_k = l_k + 1;
           break;
        end  
        
        l_loopnumber = l_loopnumber + 1;
        
        if l_loopnumber > 20
            for l_paramid = 1 : g_optimization.paramnum
                l_newposition(l_paramid) = min(max(1, ceil(rand()*l_size(l_paramid))), l_size(l_paramid));
                l_neighbour(l_paramid) = g_optimization.range{l_paramid}(l_newposition(l_paramid));                
            end
            l_k = l_k + 1;
            break;
        end
        
    end
     
    %计算领域点的收益
    l_parmstr = [];

    for l_i = 1 : g_optimization.paramnum

        l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_neighbour(l_i)));

        if l_i < g_optimization.paramnum
            l_parmstr = strcat(l_parmstr, ',');
        end

    end

    disp(l_parmstr);

    l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');

    eval(l_commandstr);
    
    
    
    l_neighbourprofit = g_optimization.expectedvalue(end);
    
    l_Temperature = exp((l_kmax - l_k)^3*0.0001) - 1;
    
    if l_Proba(l_profit, l_neighbourprofit, l_Temperature) >= rand()
        
        if l_neighbourprofit > l_GlobalBestProfit
            
            l_GlobalBestProfit = l_neighbourprofit;
            
            for l_paramid = 1 : g_optimization.paramnum
                l_GlobalBestParam(l_paramid) = g_optimization.range{l_paramid}(l_newposition(l_paramid));
            end
            
        end
        
        l_position = l_newposition;
        
        l_profit = l_neighbourprofit;
        
    end

end


%输出结果
disp(' 最优参数组合为：')
disp(l_GlobalBestParam);
disp('最大收益为：')
disp(l_GlobalBestProfit);
end

function value = l_Proba(oldprofit, newprofit, temperature)
    if newprofit > oldprofit
        value = 1;
    else  if temperature ==0
            value = 0;
          else value = exp((newprofit - oldprofit) / temperature);
          end
    end
    
end
    
    
