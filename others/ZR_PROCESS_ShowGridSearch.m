function ZR_PROCESS_ShowGridSearch()
% 网格计算，参数配对
% param1代表第一个参数（商品周期），param2代表第二个参数（止损点）
% 计算的网格存放在g_paramgrid里

global g_commoditynames;
global g_tables;
global g_optimization;
global g_method;
% 如果目录不存在就创建
if (~exist(g_tables.outdir,'dir'))
    mkdir(g_tables.outdir);
end
% 定义filename
l_filename=strcat(g_tables.xls.optimization.filename,strrep(char(g_method.runstrategy),'ZR_STRATEGY_','_'));
for index=1:g_optimization.paramnum
    l_filename=strcat(l_filename,'_',g_optimization.paramname{index});
end
l_filename=strcat(g_tables.outdir,'/',l_filename,'.xls');
if (exist(l_filename,'file'))
    delete(l_filename);
end
%标题
l_title={};
l_paramtitlenames=fieldnames(g_tables.optimization.param);
for l_paramtitleid=1:length(l_paramtitlenames)
    l_commandstr=sprintf('l_title{l_paramtitleid}=g_tables.optimization.param.%s.title;',l_paramtitlenames{l_paramtitleid});
    eval(l_commandstr);          
end

for l_valuetitleid=1:g_optimization.expectedvaluennum
    l_commandstr=sprintf('l_title{l_paramtitleid+l_valuetitleid}=''期望值%d'';',l_valuetitleid);
    eval(l_commandstr);          
end

%%%%%%%%%%%%%  各个品种情况
l_cmnum=length(g_commoditynames);
for l_cmid=1:l_cmnum
    l_sheetname=cell2mat(g_commoditynames(l_cmid));
%     l_sheetname=l_strname(regexp(l_strname,'[a-z_A-Z]')); 
    l_paramarray=cat(1,g_optimization.param{:});
    l_valuearray=cat(1,g_optimization.commodity(l_cmid).expectedvalue(:));
    l_valuearray=cat(2,l_paramarray,l_valuearray);
    l_valuearray=[l_title;num2cell(l_valuearray)];
    xlswrite(l_filename,l_valuearray,l_sheetname, 'A1');         
end

%%%%%%%%%%%%% 总交易情况
l_sheetname='AllCommodity';
l_paramarray=cat(1,g_optimization.param{:});
l_valuearray=cat(1,g_optimization.expectedvalue(:));
l_valuearray=cat(2,l_paramarray,l_valuearray);
l_valuearray=[l_title;num2cell(l_valuearray)];
xlswrite(l_filename,l_valuearray,l_sheetname, 'A1');

end