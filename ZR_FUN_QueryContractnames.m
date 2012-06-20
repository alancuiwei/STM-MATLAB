function out_contractnames=ZR_FUN_QueryContractnames(in_commodityid,in_months)
% ��ѯ��Ʒ�����еĺ�Լ��
% ���룺Ʒ����
% ���أ���ѯ�õ�������
l_sqlstr1='select distinct _t.contractid from (select contractid from marketdaydata_t';
l_sqlstr1=strcat(l_sqlstr1,' where contractid regexp ''^',in_commodityid,'[0-9].*(',in_months,')$'' order by currentdate) _t');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    error('û��Ʒ��%s��Լ��Ϣ',in_commodityid);
else
    out_contractnames=l_data(:,1)';
end

end
