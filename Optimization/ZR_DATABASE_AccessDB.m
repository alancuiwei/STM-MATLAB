function out_data=ZR_DATABASE_AccessDB(varargin) %(in_DBname,in_sqlstr)
% 访问futuretest数据库和webfuturetest数据库
% global g_JDBCdriver;
% global g_DatabaseURL;
if ~isunix
    l_conn=database(varargin{1},'root','123456');
else
    l_conn=database(varargin{1},'root','123456','com.mysql.jdbc.Driver','jdbc:mysql://127.0.0.1:3306/');
end
switch varargin{2}
    case 'sql'
          l_cur=fetch(exec(l_conn,varargin{3}));
          out_data=l_cur.data;  
          close(l_cur);
          close(l_conn);
    case 'conn'
          out_data=l_conn;
end
%
end