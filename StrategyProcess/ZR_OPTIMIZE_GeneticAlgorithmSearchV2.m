function ZR_OPTIMIZE_GeneticAlgorithmSearchV2(varargin)
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



%确定每一代的个体数量
l_SizeOfPopulation = 10;

%初始化
l_Individuals = cell(l_SizeOfPopulation,1);  
l_size = zeros(1,g_optimization.paramnum);

%检查每个参数取值的数量
for l_paramid = 1 : g_optimization.paramnum
    l_size(l_paramid) = length(g_optimization.range{l_paramid});
end

%随机设定第一代的构成,确保不重复
for l_n = 1 : l_SizeOfPopulation
    l_limit=10;
    while 1 
        
        for l_paramid = 1 : g_optimization.paramnum
            l_Individuals{l_n}(l_paramid) =  g_optimization.range{l_paramid}(ceil(l_size(l_paramid)*rand())); 
        end 
        
        l_nonverified = isempty(find(cell2mat(cellfun(@(x) (isequal(x,l_Individuals{l_n})), g_optimization.param, 'UniformOutput', false)), 1));
        
        if l_nonverified == 1
            break;
        end
        if l_limit<0
            l_limit=10;
            break;
        else
            l_limit=l_limit-1;
        end
        
    end 
    
    l_parmstr = [];
            
    for l_i = 1 : g_optimization.paramnum
                
        l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_Individuals{l_n}(l_i)));
                
        if l_i < g_optimization.paramnum
            l_parmstr = strcat(l_parmstr, ',');
        end
        
    end
    
    %disp(l_parmstr);
    
    l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');
            
    eval(l_commandstr);
    
end


%寻找第一代中的最优
l_profits = g_optimization.expectedvalue;
[l_BestProfitUntilNow, l_index] = max(g_optimization.expectedvalue);
l_BestIndividualUntilNow = g_optimization.param{l_index};

%繁殖和变异
l_NumberOfGeneration = 5;
l_RateOfMutation = 0.01;
l_Probability = zeros(l_SizeOfPopulation, 1);
l_Proba = zeros(l_SizeOfPopulation, 1);
l_Parents = cell(2, l_SizeOfPopulation);

for l_ii = 1 : l_SizeOfPopulation
    l_Proba(l_ii) = 1.2^l_ii;           %一个可调参数
end

l_sum = sum(l_Proba);

for l_ii = 1 : l_SizeOfPopulation
    l_Proba(l_ii) = l_Proba(l_ii) / l_sum;
end


for l_ii = 1 : l_SizeOfPopulation
    l_Probability(l_ii) = sum(l_Proba(1:l_ii));
end

for l_g = 1 : l_NumberOfGeneration
    
    [l_temp,l_index] = sort(l_profits);
    
    for l_ii = 1 : l_SizeOfPopulation
        
        l_Parents{1, l_ii} = l_Individuals{l_index(l_RandInt(l_Probability))};
        
        l_Parents{2, l_ii} = l_Individuals{l_index(l_RandInt(l_Probability))};
        
    end
    
    l_barrier = floor(g_optimization.paramnum/2);
    
    for l_ii = 1 : l_SizeOfPopulation
     
        for l_paramid = 1 : g_optimization.paramnum
            
            if l_paramid <= l_barrier
                l_Individuals{l_ii}(l_paramid) = l_Parents{1, l_ii}(l_paramid);
            else
                l_Individuals{l_ii}(l_paramid) = l_Parents{2, l_ii}(l_paramid);
            end
            
        end
        
    end
    
    for l_ii = 1 : l_SizeOfPopulation
        
        while 1
            
            for l_paramid = 1 : g_optimization.paramnum
                if rand() < l_RateOfMutation
                    l_Individuals{l_ii}(l_paramid) = g_optimization.range{l_paramid}(ceil(rand()*l_size(l_paramid)));
                end
            end
            
            l_nonverified = isempty(find(cell2mat(cellfun(@(x) (isequal(x,l_Individuals{l_ii})), g_optimization.param, 'UniformOutput', false)), 1));
            
            if l_nonverified == 1
                break;
            end
            if l_limit<0
                l_limit=10;
                break;
            else
                l_limit=l_limit-1;
            end        
        end
        
        l_parmstr = [];

        for l_i = 1 : g_optimization.paramnum

            l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_Individuals{l_ii}(l_i)));

            if l_i < g_optimization.paramnum
                l_parmstr = strcat(l_parmstr, ',');
            end

        end

        %disp(l_parmstr);

        l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');

        eval(l_commandstr);
        
    end
    
    
    
    l_profits = g_optimization.expectedvalue(end-l_SizeOfPopulation + 1 :end);
    [l_temp, l_index] = max(l_profits);
    
    if l_temp > l_BestProfitUntilNow 
        
        l_BestProfitUntilNow = l_temp;
        l_BestIndividualUntilNow = g_optimization.param{end-l_SizeOfPopulation+l_index};
        
    end
    
end

%disp('最优参数组合为：');
%disp(num2str(l_BestIndividualUntilNow));
%disp('最佳收益期望为：')
%disp(num2str(l_BestProfitUntilNow));

% load('GA.mat');
% ga(end+1) = l_BestProfitUntilNow;
% save 'GA.mat' ga

end


function value =  l_RandInt(Proba)
    r = rand();
    index = 1;
    while r > Proba(index)
        index = index + 1;
    end
    value = index;
end