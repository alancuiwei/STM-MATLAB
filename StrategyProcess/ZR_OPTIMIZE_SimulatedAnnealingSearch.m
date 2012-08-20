function ZR_OPTIMIZE_SimulatedAnnealingSearch(varargin)
% ������㣬�������
% param1�����һ����������Ʒ���ڣ���param2����ڶ���������ֹ��㣩
% �������������g_paramgrid��

global g_optimization;



% ���� ������������
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


% �����ܹ��еĲ�����
g_optimization.paramnum=length(g_optimization.paramname);
g_optimization.valuenum=sum(l_len);               %������ֲ�׼ȷ
%disp(strcat('��������У�',num2str(g_optimization.valuenum),'��'));
% if(g_optimization.valuenum>10000)
%     disp('�������̫�࣬Ŀǰ����Ϊ10000�����ȷʵ��Ҫ�����޸�ZR_OPTIMIZE_GridSearch�е����ƣ�');
%     return;
% end



l_Currentpoint = zeros(1, g_optimization.paramnum);       %��¼��ǰ���������ֵ
l_size = zeros(1, g_optimization.paramnum);               %���ڼ�¼ÿ�������ж����ֿ�����
l_position = zeros(1, g_optimization.paramnum);           %��¼��ǰ���������λ��
l_kmax = 50;                                              %��������

%���ÿ�������Ŀ����Ը���&���ѡ���ʼ��
for l_paramid = 1 : g_optimization.paramnum
    l_size(l_paramid) = length(g_optimization.range{l_paramid});
    l_position(l_paramid) = ceil(l_size(l_paramid)*rand());
    l_Currentpoint(l_paramid) =  g_optimization.range{l_paramid}(l_position(l_paramid)); 
end


%�����ʼ�������ֵ
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



l_GlobalBestProfit = g_optimization.expectedvalue(1);      %���ڼ�¼���ҵ����������
l_GlobalBestParam = g_optimization.param{1};               %���ڼ�¼���ҵ������Ų������
l_profit = g_optimization.expectedvalue(1);                %��ǰ�������

l_constant = [-1,0,1];   %�������������
 
l_k = 0;

while l_k < l_kmax

    %���ѡ�������
    l_neighbour = zeros(1, g_optimization.paramnum);
    
    l_newposition = zeros(1, g_optimization.paramnum);
    
    l_movedirection = zeros(1, g_optimization.paramnum);
    
    l_loopnumber = 0;  %��ֹ����ѭ��
    
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
     
    %��������������
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


%������
disp(' ���Ų������Ϊ��')
disp(l_GlobalBestParam);
disp('�������Ϊ��')
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
    
    
