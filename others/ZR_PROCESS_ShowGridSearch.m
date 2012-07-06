function ZR_PROCESS_ShowGridSearch()
% ������㣬�������
% param1�����һ����������Ʒ���ڣ���param2����ڶ���������ֹ��㣩
% �������������g_paramgrid��

global g_commoditynames;
global g_tables;
global g_optimization;
global g_method;
% ���Ŀ¼�����ھʹ���
if (~exist(g_tables.outdir,'dir'))
    mkdir(g_tables.outdir);
end
% ����filename
l_filename=strcat(g_tables.xls.optimization.filename,strrep(char(g_method.runstrategy),'ZR_STRATEGY_','_'));
for index=1:g_optimization.paramnum
    l_filename=strcat(l_filename,'_',g_optimization.paramname{index});
end
l_filename=strcat(g_tables.outdir,'/',l_filename,'.xls');
if (exist(l_filename,'file'))
    delete(l_filename);
end
%����
l_title={};
l_paramtitlenames=fieldnames(g_tables.optimization.param);
for l_paramtitleid=1:length(l_paramtitlenames)
    l_commandstr=sprintf('l_title{l_paramtitleid}=g_tables.optimization.param.%s.title;',l_paramtitlenames{l_paramtitleid});
    eval(l_commandstr);          
end

for l_valuetitleid=1:g_optimization.expectedvaluennum
    l_commandstr=sprintf('l_title{l_paramtitleid+l_valuetitleid}=''����ֵ%d'';',l_valuetitleid);
    eval(l_commandstr);          
end

%%%%%%%%%%%%%  ����Ʒ�����
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

%%%%%%%%%%%%% �ܽ������
l_sheetname='AllCommodity';
l_paramarray=cat(1,g_optimization.param{:});
l_valuearray=cat(1,g_optimization.expectedvalue(:));
l_valuearray=cat(2,l_paramarray,l_valuearray);
l_valuearray=[l_title;num2cell(l_valuearray)];
xlswrite(l_filename,l_valuearray,l_sheetname, 'A1');

end