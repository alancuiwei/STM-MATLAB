function ZR_OPTIMIZE_GridSearch(varargin)
% 网格计算，参数配对
% param1代表第一个参数（商品周期），param2代表第二个参数（止损点）
% 计算的网格存放在g_paramgrid里

global g_optimization;



% 参数 分析参数个数，编写参数形式
l_parmstr=[];
l_disstr=[];
if nargin>0
    l_len(nargin/2)=0;
    for l_paramid=1:(nargin/2)
        l_len(l_paramid)=length(varargin{l_paramid*2});
        g_optimization.range{l_paramid}=varargin{l_paramid*2};
        g_optimization.paramname{l_paramid}=varargin{l_paramid*2-1};
        l_disstr=strcat(l_disstr,'''',g_optimization.paramname{l_paramid},':'',num2str(l_paramid',num2str(l_paramid),'),''; ''');
        l_parmstr=strcat(l_parmstr,'''',g_optimization.paramname{l_paramid},''',l_paramid',num2str(l_paramid)); 
        if l_paramid~=(nargin/2)
            l_parmstr=strcat(l_parmstr,',');
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
        l_parmstr=strcat(l_parmstr,'''',g_optimization.paramname{l_paramid},''',l_paramid',num2str(l_paramid)); 
        if l_paramid~=length(g_optimization.adjustparams)
            l_parmstr=strcat(l_parmstr,',');
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
%             l_parmstr=strcat(l_parmstr,'''',g_optimization.paramname{l_paramid},''',l_paramid',num2str(l_paramid)); 
%             if l_paramid~=length(l_titlenames)
%                 l_parmstr=strcat(l_parmstr,',');
%                 l_disstr=strcat(l_disstr,',');
%             end               
%         end      
%     end       
end


% 计算总共有的参数组
g_optimization.paramnum=length(g_optimization.paramname);
g_optimization.valuenum=prod(l_len);
disp(strcat('参数组合有：',num2str(g_optimization.valuenum),'组'));
% if(g_optimization.valuenum>10000)
%     disp('参数组合太多，目前限制为10000，如果确实需要，请修改ZR_OPTIMIZE_GridSearch中的限制！');
%     return;
% end

l_commdandstr=strcat('disp(strcat(',l_disstr,'));ZR_PROCESS_RecordOptimization(',l_parmstr,'); ');


l_paramid1=[];
l_paramid2=[];
l_paramid3=[];
l_paramid4=[];
l_paramid5=[];
l_paramid6=[];
% 根据参数个数编写循环层数
for l_paramid=1:g_optimization.paramnum
    l_commdandstr=strcat('for l_paramid',num2str(l_paramid),'=[',num2str(g_optimization.range{l_paramid}),'] ',l_commdandstr,' end; ');
end 
eval(l_commdandstr);

end