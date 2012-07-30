function ZR_OPTIMIZE_AnotherMultipointHillClimbingSearch(varargin)
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
    l_titlenames=fieldnames(g_optimization.adjustparams);
    l_len(length(l_titlenames))=0;
    if ~isempty(l_titlenames)
        for l_paramid=1:length(l_titlenames)
            l_commandstr=sprintf('l_len(l_paramid)=length(g_optimization.adjustparams.%s.data);',l_titlenames{l_paramid});
            eval(l_commandstr);
            l_commandstr=sprintf('g_optimization.range{l_paramid}=g_optimization.adjustparams.%s.data;',l_titlenames{l_paramid});
            eval(l_commandstr);
            g_optimization.paramname(l_paramid)=l_titlenames(l_paramid);
            l_disstr=strcat(l_disstr,'''',g_optimization.paramname{l_paramid},':'',num2str(l_paramid',num2str(l_paramid),'),''; ''');
            %l_parmstr=strcat(l_parmstr,'''',g_optimization.paramname{l_paramid},''',l_paramid',num2str(l_paramid)); 
            if l_paramid~=length(l_titlenames)
                %l_parmstr=strcat(l_parmstr,',');
                l_disstr=strcat(l_disstr,',');
            end               
        end      
    end       
end


% 计算总共有的参数组
g_optimization.paramnum=length(g_optimization.paramname);
g_optimization.valuenum=sum(l_len);               %这个数字不准确
%disp(strcat('参数组合有：',num2str(g_optimization.valuenum),'组'));
% if(g_optimization.valuenum>10000)
%     disp('参数组合太多，目前限制为10000，如果确实需要，请修改ZR_OPTIMIZE_GridSearch中的限制！');
%     return;
% end



%确定多点登山搜索的出发点数
l_numberOfStartingpoints = 3;

%初始化
l_LocalStartingpoints = cell(l_numberOfStartingpoints,1);     %初始点
l_size = zeros(1,g_optimization.paramnum);

%检查参数变化范围
for l_paramid = 1 : g_optimization.paramnum
    l_size(l_paramid) = length(g_optimization.range{l_paramid});
end

disp(l_size);

%随机选择初始点
for l_point = 1 : l_numberOfStartingpoints
    for l_paramid = 1 : g_optimization.paramnum
        l_length = length(g_optimization.range{l_paramid});
        l_LocalStartingpoints{l_point}(l_paramid) =  g_optimization.range{l_paramid}(ceil(l_length*rand())); 
    end
end

%计算初始点的收益值
for l_point = 1 : l_numberOfStartingpoints
    
    l_parmstr = [];
            
    for l_i = 1 : g_optimization.paramnum
                
        l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_LocalStartingpoints{l_point}(l_i)));
                
        if l_i < g_optimization.paramnum
            l_parmstr = strcat(l_parmstr, ',');
        end
        
    end
    
    disp(l_parmstr);
    
    l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');
            
    eval(l_commandstr);
    
end

%初始化旧的局部最优和新的局部最优
l_OldLocalBestprofits = g_optimization.expectedvalue;
l_NewLocalBestprofits = g_optimization.expectedvalue;

%多点登山型搜索
for l_point = 1 : l_numberOfStartingpoints
    
    %登山搜索
    while 1
        
        %设置邻域点的值
        l_testpoints = cell(0);
        
        l_testpositions = cell(0);
        
        l_position = zeros(1,g_optimization.paramnum);
        
        %检查参数位置
        for l_paramid = 1 : g_optimization.paramnum
            l_position(l_paramid) = find(g_optimization.range{l_paramid}==l_LocalStartingpoints{l_point}(l_paramid));
        end
        
        %设置邻域点参数位置
        l_commandstr = 'l_testpositions{end+1} = [';
        
        for l_paramid = 1 : g_optimization.paramnum
            
            l_commandstr = strcat(l_commandstr,'min(max(' ,num2str(l_position(l_paramid)), '+', 'l_direction', num2str(l_paramid),',1),l_size(', num2str(l_paramid),'))');
            
            if l_paramid < g_optimization.paramnum
                l_commandstr = strcat(l_commandstr, ',');
            end
            
            if l_paramid == g_optimization.paramnum
                l_commandstr = strcat(l_commandstr,'];');
            end
        end
        
        for l_paramid = 1 : g_optimization.paramnum
            l_commandstr = strcat('for l_direction', num2str(l_paramid), '=[-1,0,1] ', l_commandstr, ' end; ' );
        end
        
        eval(l_commandstr);
        
        %根据参数位置给领域点赋值
        l_numerator1 = length(l_testpositions);
        
        for l_i = 1 : l_numerator1
            
            l_newpoint = zeros(1,g_optimization.paramnum);
            
            for l_paramid = 1 : g_optimization.paramnum                            
                l_newpoint(l_paramid) = g_optimization.range{l_paramid}(l_testpositions{l_i}(l_paramid));                
            end    
            
            l_testpoints{end+1} = l_newpoint;
            
        end
        
        
        %计算邻域点的收益
        l_numberofpointcalculated = 0;
        l_numerator2 = length(l_testpoints);
        
        for l_i = 1 : l_numerator2 
            
            l_tp = l_testpoints{l_i};
            
            l_nonverified = isempty(find(cell2mat(cellfun(@(x) (isequal(x,l_tp)), g_optimization.param, 'UniformOutput', false)), 1));
            
            if l_nonverified == 0;
                continue;
            end
            
            l_parmstr = [];
            
            for l_k = 1 : g_optimization.paramnum
                
                l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_k},'''',',',num2str(l_tp(l_k)));
                
                if l_k < g_optimization.paramnum
                    l_parmstr = strcat(l_parmstr, ',');
                end
                
            end
            
            disp(l_parmstr);
             
            l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');
            
            eval(l_commandstr);
            
            l_numberofpointcalculated = l_numberofpointcalculated + 1;
            
        end
        
        %找出最佳邻点        
        if l_numberofpointcalculated >= 1
            l_length1 = length(g_optimization.expectedvalue);
            [l_NewLocalBestprofits(l_point), l_index] = max(g_optimization.expectedvalue(l_length1 - l_numberofpointcalculated + 1 : l_length1));        
            l_index = l_index + l_length1 - l_numberofpointcalculated;
        
            %判断是否局部最优，是则停止搜索，不是则继续搜索
            if l_NewLocalBestprofits(l_point) <= l_OldLocalBestprofits(l_point)
                break;
            end
       
            l_OldLocalBestprofits(l_point) = l_NewLocalBestprofits(l_point);
            l_LocalStartingpoints{l_point} = g_optimization.param{l_index};
        end
        
        if l_numberofpointcalculated ==0
            break
        end
        
    end
    
end

%找出局部最优中的最大值
[l_temp, l_index2] = max(l_OldLocalBestprofits);
disp(' 最优参数组合为：')
disp(l_LocalStartingpoints{l_index2});
disp('最大收益为：')
disp(num2str(l_temp));

end