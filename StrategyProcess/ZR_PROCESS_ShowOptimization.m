function ZR_PROCESS_ShowOptimization()
% 网格计算，参数配对
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
for l_paramtitleid=1:length(g_tables.optimization.param)
    l_title{l_paramtitleid}=g_tables.optimization.param{l_paramtitleid}.title;     
end

for l_valuetitleid=1:g_optimization.expectedvaluennum
    l_commandstr=sprintf('l_title{l_paramtitleid+l_valuetitleid}=''expectedvalue%d'';',l_valuetitleid);
    eval(l_commandstr);          
end
% 选取最大值
[l_max,l_maxid]=max(g_optimization.expectedvalue);
g_optimization.expectedvalue(end+1)=l_max;
g_optimization.param(end+1)=g_optimization.param(l_maxid);

switch g_tables.outfiletype
    case 'xls'
        %%%%%%%%%%%%%  各个品种情况
        if iscell(g_commoditynames)
            l_cmnum=length(g_commoditynames);
            for l_cmid=1:l_cmnum
                g_optimization.commodity(l_cmid).expectedvalue(end+1)=l_max;
                l_sheetname=cell2mat(g_commoditynames(l_cmid));
            %     l_sheetname=l_strname(regexp(l_strname,'[a-z_A-Z]')); 
                l_paramarray=cat(1,g_optimization.param{:});
                l_valuearray=cat(1,g_optimization.commodity(l_cmid).expectedvalue(:));
                l_valuearray=cat(2,l_paramarray,l_valuearray);
                l_valuearray=[l_title;num2cell(l_valuearray)];
                xlswrite(l_filename,l_valuearray,l_sheetname, 'A1');         
            end            
        else
            l_cmid=1;
            g_optimization.commodity(l_cmid).expectedvalue(end+1)=l_max;
            l_sheetname=g_commoditynames;
        %     l_sheetname=l_strname(regexp(l_strname,'[a-z_A-Z]')); 
            l_paramarray=cat(1,g_optimization.param{:});
            l_valuearray=cat(1,g_optimization.commodity(l_cmid).expectedvalue(:));
            l_valuearray=cat(2,l_paramarray,l_valuearray);
            l_valuearray=[l_title;num2cell(l_valuearray)];
            xlswrite(l_filename,l_valuearray,l_sheetname, 'A1');              
        end
%         for l_cmid=1:l_cmnum
%             g_optimization.commodity(l_cmid).expectedvalue(end+1)=l_max;
%             l_sheetname=cell2mat(g_commoditynames(l_cmid));
%         %     l_sheetname=l_strname(regexp(l_strname,'[a-z_A-Z]')); 
%             l_paramarray=cat(1,g_optimization.param{:});
%             l_valuearray=cat(1,g_optimization.commodity(l_cmid).expectedvalue(:));
%             l_valuearray=cat(2,l_paramarray,l_valuearray);
%             l_valuearray=[l_title;num2cell(l_valuearray)];
%             xlswrite(l_filename,l_valuearray,l_sheetname, 'A1');         
%         end

        %%%%%%%%%%%%% 总交易情况
        l_sheetname='AllCommodity';
        l_paramarray=cat(1,g_optimization.param{:});
        l_valuearray=cat(1,g_optimization.expectedvalue(:));
        l_valuearray=cat(2,l_paramarray,l_valuearray);
        l_valuearray=[l_title;num2cell(l_valuearray)];
        xlswrite(l_filename,l_valuearray,l_sheetname, 'A1');
    case 'xml'
        g_optimization.expectedvalue(isnan(g_optimization.expectedvalue))=0;
        l_paramarray=cat(1,g_optimization.param{:});
        l_valuearray=cat(1,g_optimization.expectedvalue(:));
        l_valuearray=cat(2,l_paramarray,l_valuearray);
        l_valuearray=[l_title;num2cell(l_valuearray)];
        xml_write(strcat(g_tables.outdir,'/',g_tables.xml.optimization.filename,'.xml'),l_valuearray(1:end,1:end));
end
end