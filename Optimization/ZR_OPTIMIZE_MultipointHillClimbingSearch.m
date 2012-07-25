function ZR_OPTIMIZE_MultipointHillClimbingSearch(varargin)
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


% �����ܹ��еĲ�����
g_optimization.paramnum=length(g_optimization.paramname);
g_optimization.valuenum=sum(l_len);               %������ֲ�׼ȷ
%disp(strcat('��������У�',num2str(g_optimization.valuenum),'��'));
% if(g_optimization.valuenum>10000)
%     disp('�������̫�࣬Ŀǰ����Ϊ10000�����ȷʵ��Ҫ�����޸�ZR_OPTIMIZE_GridSearch�е����ƣ�');
%     return;
% end



%ȷ������ɽ�����ĳ�������
l_numberOfStartingpoints = 3;

%��ʼ��
l_LocalStartingpoints = cell(l_numberOfStartingpoints);     %��ʼ��
l_OldLocalBestprofits = zeros(1,l_numberOfStartingpoints);    %�ɵľֲ���������
l_NewLocalBestprofits = zeros(1,l_numberOfStartingpoints);    %�µľֲ���������
l_size = zeros(1,g_optimization.paramnum);

%�������仯��Χ
for l_paramid = 1 : g_optimization.paramnum
    l_size(l_paramid) = length(g_optimization.range{l_paramid});
end

disp(l_size);

%���ѡ���ʼ��
for l_point = 1 : l_numberOfStartingpoints
    for l_paramid = 1 : g_optimization.paramnum
        l_length = length(g_optimization.range{l_paramid});
        l_LocalStartingpoints{l_point}(l_paramid) =  g_optimization.range{l_paramid}(ceil(l_length*rand())); 
    end
end

%�����ʼ�������ֵ
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

%��ʼ���ɵľֲ����ź��µľֲ�����
l_OldLocalBestprofits = g_optimization.expectedvalue;
l_NewLocalBestprofits = g_optimization.expectedvalue;

%����ɽ������
for l_point = 1 : l_numberOfStartingpoints
    
    %��ɽ����
    while 1
        
        %����������ֵ
        l_testpoints = cell(2,g_optimization.paramnum);
        
        for l_paramid = 1 : g_optimization.paramnum
            
            l_testpoints{1,l_paramid} = l_LocalStartingpoints{l_point};
            
            l_testpoints{2,l_paramid} = l_LocalStartingpoints{l_point};
            
            l_position = find(g_optimization.range{l_paramid} == l_LocalStartingpoints{l_point}(l_paramid));
            
            if l_position > 1 
                l_testpoints{1,l_paramid}(l_paramid) = g_optimization.range{l_paramid}(l_position - 1);
            end
            
            if l_position < l_size(l_paramid) 
                 l_testpoints{2,l_paramid}(l_paramid) = g_optimization.range{l_paramid}(l_position + 1);
            end
            
        end
        
        %��������������
        l_numberofpointscalculated = 0;
        
        for l_paramid = 1 : g_optimization.paramnum
            
            l_verified1 = 0;
            
            l_verified2 = 0;
            
            l_lengthofparam = length(g_optimization.param);
            
            for l_i = 1 : l_lengthofparam
                
                if g_optimization.param{l_i} == l_testpoints{1,l_paramid}
                    
                   l_verified1 = 1;
                   break;
                   
                end
                
            end
                    
           for l_i = 1 : l_lengthofparam
               
                if g_optimization.param{l_i} == l_testpoints{2,l_paramid}
                    
                   l_verified2 = 1;
                   break;
                   
                end
                
           end     
            
            if l_verified1 == 0
                
                l_parmstr = [];
                
                for l_i = 1 : g_optimization.paramnum
                
                    l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_testpoints{1,l_paramid}(l_i)));
                
                    if l_i < g_optimization.paramnum
                        l_parmstr = strcat(l_parmstr, ',');
                    end
                
                end
            
                disp(l_parmstr);
             
                l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');
            
                eval(l_commandstr);
                
                l_numberofpointscalculated = l_numberofpointscalculated + 1;
            end
            
            if l_verified2 ==0
                
                l_parmstr = [];
            
                for l_i = 1 : g_optimization.paramnum
                
                    l_parmstr =strcat(l_parmstr,'''',g_optimization.paramname{l_i},'''',',',num2str(l_testpoints{2,l_paramid}(l_i)));
                
                    if l_i < g_optimization.paramnum
                        l_parmstr = strcat(l_parmstr, ',');
                    end
                    
                end
            
                disp(l_parmstr);
            
                l_commandstr=strcat(' ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');
            
                eval(l_commandstr);
                
                l_numberofpointscalculated = l_numberofpointscalculated + 1;
                
           end
            
        end
        
        %�ҳ�����ڵ�
         if l_numberofpointscalculated >= 1
            l_length1 = length(g_optimization.expectedvalue);
            [l_NewLocalBestprofits(l_point), l_index] = max(g_optimization.expectedvalue(l_length1 - l_numberofpointscalculated + 1 : l_length1));        
            l_index = l_index + l_length1 - l_numberofpointscalculated;
        
            %�ж��Ƿ�ֲ����ţ�����ֹͣ�������������������
            if l_NewLocalBestprofits(l_point) <= l_OldLocalBestprofits(l_point)
                break;
            end
       
            l_OldLocalBestprofits(l_point) = l_NewLocalBestprofits(l_point);
            l_LocalStartingpoints{l_point} = g_optimization.param{l_index};
        end
        
        if l_numberofpointscalculated ==0
            break;
        end
            
    end
    
end

%�ҳ��ֲ������е����ֵ
[l_temp, l_index2] = max(l_OldLocalBestprofits);
disp(' ���Ų������Ϊ��')
disp(l_LocalStartingpoints{l_index2});
disp('�������Ϊ��')
disp(num2str(l_temp));
end