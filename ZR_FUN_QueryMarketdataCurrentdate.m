function out_currentdate=ZR_FUN_QueryMarketdataCurrentdate()
% �õ���ǰ������µ�����
% ���أ���ѯ�õ�������
l_sqlstr1='select currentdate from marketdaydata_t order by currentdate DESC limit 0,1;';

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    error('û�к�Լ��������');
else
    out_currentdate=l_data(:,1)';
end

end