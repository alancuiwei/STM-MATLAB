function ZR_PROCESS_SaveReturnrateToDB(in_strategyid)
% 把回报率导入到数据库中
global g_reference;
l_data=struct('rightid',[],'yearid',[],'monthid',[],'returnrate',[]);
l_clock=clock;
for l_cmid=1:length(g_reference.commodity.monthreturnrate)
    l_rightid=repmat(g_reference.commodity.rightid(l_cmid),1,length(g_reference.commodity.monthreturnrate(l_cmid).data(:)));
    l_year=cell(1,length(g_reference.commodity.monthreturnrate(l_cmid).data(:)));
    l_month=cell(1,length(g_reference.commodity.monthreturnrate(l_cmid).data(:)));
    l_returnrate=cell(1,length(g_reference.commodity.monthreturnrate(l_cmid).data(:)));
    for l_rateid=1:length(g_reference.commodity.monthreturnrate(l_cmid).data(:))
        l_yearid=g_reference.commodity.years(l_cmid).data(ceil(l_rateid/12));
        l_monthid=mod(l_rateid,12);
        if ~l_monthid
            l_monthid=12;
        end
        l_year{l_rateid}=l_yearid;
        l_month{l_rateid}=l_monthid;
        l_returnrate{l_rateid}=g_reference.commodity.monthreturnrate(l_cmid).data(l_rateid);
    end
    l_startid=find(g_reference.commodity.monthreturnrate(l_cmid).data(:),1);
    l_endid=find(cell2mat(l_month)==l_clock(2),1,'last');
    l_data.rightid=cat(2,l_data.rightid,l_rightid(l_startid:l_endid));
    l_data.yearid=cat(2,l_data.yearid,l_year(l_startid:l_endid));
    l_data.monthid=cat(2,l_data.monthid,l_month(l_startid:l_endid));
    l_data.returnrate=cat(2,l_data.returnrate,l_returnrate(l_startid:l_endid));
end
% 总体的收益率
l_rightid=repmat({strcat(in_strategyid,'000000')},1,length(g_reference.monthreturnrate.data(:)));
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
l_endid=find(cell2mat(l_month)==l_clock(2),1,'last');
l_data.rightid=cat(2,l_data.rightid,l_rightid(l_startid:l_endid));
l_data.yearid=cat(2,l_data.yearid,l_year(l_startid:l_endid));
l_data.monthid=cat(2,l_data.monthid,l_month(l_startid:l_endid));
l_data.returnrate=cat(2,l_data.returnrate,l_returnrate(l_startid:l_endid));

l_sqlstr1='delete from strategyreturnrate_t ';
l_sqlstr1=strcat(l_sqlstr1,' where rightid regexp ''^',in_strategyid,'''');
% 连接数据库
l_conn=database('futuretest','root','123456');
exec(l_conn,l_sqlstr1);
l_colnames={'rightid';'yearid';'monthid';'returnrate'};
l_exdata=[l_data.rightid',l_data.yearid',l_data.monthid',l_data.returnrate'];
insert(l_conn, 'strategyreturnrate_t', l_colnames, l_exdata)
close(l_conn);

end