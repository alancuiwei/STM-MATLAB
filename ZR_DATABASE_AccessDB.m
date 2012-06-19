function out_data=ZR_DATABASE_AccessDB(in_DBname,in_sqlstr)
% 访问futuretest数据库和webfuturetest数据库
l_conn=database(in_DBname,'root','123456');
l_cur=fetch(exec(l_conn,in_sqlstr));
out_data=l_cur.data;
close(l_cur);
close(l_conn);
end