function out_data=ZR_DATABASE_AccessDB(in_DBname,in_sqlstr)
% ����futuretest���ݿ��webfuturetest���ݿ�
l_conn=database(in_DBname,'root','123456');
l_cur=fetch(exec(l_conn,in_sqlstr));
out_data=l_cur.data;
close(l_cur);
close(l_conn);
end