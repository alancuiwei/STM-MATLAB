function out_contractinfo=ZR_FUN_QueryActiveContractInfo(in_contractname)
% �����ݿ��еõ��ú�Լ����Ϣ
% ���룺��Լ��
% ���أ���ѯ�õ������ݣ�struct(daystolasttradeday)
l_sqlstr1='select lasttradedate,daystolasttradedate from contract_t where lasttradedate>CURRENT_DATE ';
l_sqlstr1=strcat(l_sqlstr1,' and contractid=''', in_contractname, '''');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('futuretest',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    out_contractinfo=struct('lasttradedate','2000-01-01',...
        'daystolasttradedate',-1);
    % error('%sû�к�Լ��Ϣ',cell2mat(in_contractname));
else
    out_contractinfo=struct('lasttradedate',{l_data(:,1)}',...
        'daystolasttradedate',cell2mat(l_data(:,2)));
end

end