function out_currentdate=ZR_FUN_QueryMarketdataCurrentdate()
% �õ���ǰ������µ�����
% ���أ���ѯ�õ�������
l_sqlstr1='select currentdate from marketdaydata_t order by currentdate DESC limit 0,1;';

% �������ݿ�
l_conn=database('futuretest','root','123456');
l_cur=fetch(exec(l_conn,l_sqlstr1));
l_data=l_cur.data;

% ��������
if(strcmp(l_data,'No Data'))
    error('û�к�Լ��������');
else
    out_currentdate=l_data(:,1)';
end
close(l_cur);
close(l_conn);
end