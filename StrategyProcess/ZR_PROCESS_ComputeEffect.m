function ZR_PROCESS_ComputeEffect(varargin)
% 计算优化效率

global g_optimization;

if isempty(varargin{1})
    return;
else
    l_mat=load(varargin{1});
    l_valuelist=l_mat.valuelist;
    l_valuelist=sort(l_valuelist,'descend');
    l_totalnum=length(l_valuelist);
    l_searchnum=length(g_optimization.expectedvalue);
    l_searchmax=max(g_optimization.expectedvalue);
    l_index=find(l_valuelist<l_searchmax,1);
    g_optimization.effect.optimizerate=l_index/l_totalnum;
    g_optimization.effect.coverrate=l_searchnum/l_totalnum;
%     g_optimization.effect.efficiency=(1-l_index/l_totalnum)/(1-(1-l_index/l_totalnum)^l_searchnum);
%     l_sum=0;
%     for id=(l_searchnum-1):(l_totalnum-1)
%         l_sum=l_sum+(id+1)*nchoosek(id,(l_searchnum-1));
%     end
%     l_standardexpect=l_sum/nchoosek(l_totalnum,l_searchnum);
    g_optimization.effect.efficiency=(1-g_optimization.effect.optimizerate)/(1-1/l_searchnum);    
    disp('优化率：');
    disp(g_optimization.effect.optimizerate);
    disp('选样率：');
    disp(g_optimization.effect.coverrate);
    disp('寻优效率：');
    disp(g_optimization.effect.efficiency);
    if exist('effectlist.mat','file')
        l_effectlist=load('effectlist.mat');
        l_effectlist.optimizerate(end+1)=g_optimization.effect.optimizerate;
        l_effectlist.coverrate(end+1)=g_optimization.effect.coverrate;
        l_effectlist.efficiency(end+1)=g_optimization.effect.efficiency;
    else
        l_effectlist.optimizerate=g_optimization.effect.optimizerate;
        l_effectlist.coverrate=g_optimization.effect.coverrate;
        l_effectlist.efficiency=g_optimization.effect.efficiency;
    end    
    save('effectlist.mat','-struct','l_effectlist');
    
end

