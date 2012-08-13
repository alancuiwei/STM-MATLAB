function ZR_PROCESS_SaveReturnrateToXML()
% 把回报率导入到数据库中
global g_reference;
global g_tables;
l_returnratexml=struct('rightid',[],'yearid',[],'monthid',[],'returnrate',[]);

% 总体的收益率
l_split=strfind(g_tables.strategyid,'-');
if isempty(l_split)
    l_strategyid=strcat(g_tables.strategyid,'000000');
else
    l_strategyid=strcat(g_tables.strategyid(1:l_split-1),'000000-',g_tables.strategyid(l_split+1:end),'000000');
end
l_rightid=repmat({l_strategyid},1,length(g_reference.monthreturnrate.data(:)));
l_year=cell(1,length(g_reference.monthreturnrate.data(:)));
l_month=cell(1,length(g_reference.monthreturnrate.data(:)));
l_returnrate=cell(1,length(g_reference.monthreturnrate.data(:)));
for l_rateid=1:length(g_reference.monthreturnrate.data(:))
    l_yearid=g_reference.years.data(ceil(l_rateid/12));
    l_monthid=mod(l_rateid,12);
    if ~l_monthid
        l_monthid=12;
    end    
    l_year{l_rateid}=l_yearid;
    l_month{l_rateid}=l_monthid;
    l_returnrate{l_rateid}=g_reference.monthreturnrate.data(l_rateid);
end
l_startid=find(g_reference.monthreturnrate.data(:),1);
l_num=0;
% l_monthfigurexml=struct('ATTRIBUTE',[]);
for l_id=l_startid:length(l_returnrate)
    l_num=l_num+1;
    l_returnratexml(l_num).rightid=l_rightid{l_id};
    l_returnratexml(l_num).yearid=l_year{l_id};
    l_returnratexml(l_num).monthid=l_month{l_id};
    l_returnratexml(l_num).returnrate=l_returnrate{l_id};
%     l_monthfigurexml(l_num).ATTRIBUTE.name=strcat(num2str(l_year{l_id}),'-',num2str(l_month{l_id}));
%     l_monthfigurexml(l_num).ATTRIBUTE.value=l_returnrate{l_id};
end
% l_yearfigurexml=struct('ATTRIBUTE',[]);
% for l_yearid=1:length(g_reference.years.data)
%     l_yearfigurexml(l_yearid).ATTRIBUTE.name=g_reference.years.data(l_yearid);
%     l_yearfigurexml(l_yearid).ATTRIBUTE.value=g_reference.yearreturnrate.data(l_yearid);    
% end
xml_write(strcat(g_tables.outdir,'/',g_tables.xml.returnrate.filename,'.xml'),l_returnratexml);
% Pref.ItemName = 'set';
% xml_write(strcat(g_tables.outdir,'/','monthfigure','.xml'), l_monthfigurexml, 'MyTree',Pref);
% xml_write(strcat(g_tables.outdir,'/','yearfigure','.xml'), l_yearfigurexml, 'MyTree',Pref);
end