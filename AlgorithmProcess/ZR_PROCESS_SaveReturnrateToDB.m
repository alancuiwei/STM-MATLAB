function ZR_PROCESS_SaveReturnrateToDB()
% 把回报率导入到数据库中
global g_reference;
global g_tables;
l_data=struct('rightid',[],'yearid',[],'monthid',[],'returnrate',[],'strategyid',[],'userid',[],'ordernum',[]);
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
l_rightid=repmat({strcat(g_tables.strategyid,'000000')},1,length(g_reference.monthreturnrate.data(:)));
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
l_data.strategyid=repmat({g_tables.strategyid}, 1, length(l_data.returnrate));
l_data.userid=repmat({g_tables.userid}, 1, length(l_data.returnrate));
l_data.ordernum=repmat({g_tables.ordernum}, 1, length(l_data.returnrate));

l_sqlstr1='delete from strategyreturnrate_t ';
% l_sqlstr1=strcat(l_sqlstr1,' where rightid regexp ''^',in_strategyid,'''');
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',g_tables.strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',g_tables.userid,' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',g_tables.ordernum,' ');
% 连接数据库
% l_conn=database('webfuturetest_101','root','123456');
l_conn=ZR_DATABASE_AccessDB('webfuturetest_101','conn');
exec(l_conn,l_sqlstr1);
l_colnames={'rightid';'yearid';'monthid';'returnrate';'strategyid';'userid';'ordernum'};
l_exdata=[l_data.rightid',l_data.yearid',l_data.monthid',l_data.returnrate',l_data.strategyid',l_data.userid',l_data.ordernum'];
insert(l_conn, 'strategyreturnrate_t', l_colnames, l_exdata);
close(l_conn);

end