function out_strategyid=ZR_FUN_GetStrategyidFromXMLfile(in_XMLfile)
% if numel(g_XMLfile.strategyid)>1
%     out_strategyid=num2str(g_XMLfile.strategyid{1});
% else
%     out_strategyid=num2str(g_XMLfile.strategyid);
% end
out_strategyid=num2str(in_XMLfile.strategyid);
if length(out_strategyid)==5
        out_strategyid=strcat('0',out_strategyid);
end
end