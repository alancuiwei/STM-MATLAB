function out_contractinfo=ZR_FUN_QueryActiveContractInfo(in_contractname)
% �����ݿ��еõ��ú�Լ����Ϣ
% ���룺��Լ��
% ���أ���ѯ�õ������ݣ�struct(daystolasttradeday)
l_sqlstr1='select lasttradedate,daystolasttradedate from contract_t where lasttradedate>CURRENT_DATE ';
l_sqlstr1=strcat(l_sqlstr1,' and contractid=''', in_contractname, '''');

% �������ݿ�
l_conn=database('futuretest','root','123456');
l_cur=fetch(exec(l_conn,l_sqlstr1));
l_data=l_cur.data;

% ��������
if(strcmp(l_data,'No Data'))
    out_contractinfo=struct('lasttradedate','2000-01-01',...
        'daystolasttradedate',-1);
    % error('%sû�к�Լ��Ϣ',cell2mat(in_contractname));
else
    out_contractinfo=struct('lasttradedate',{l_data(:,1)}',...
        'daystolasttradedate',cell2mat(l_data(:,2)));
end
close(l_cur);
close(l_conn);

end