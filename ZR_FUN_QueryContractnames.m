function out_contractnames=ZR_FUN_QueryContractnames(in_commodityid,in_months)
% ��ѯ��Ʒ�����еĺ�Լ��
% ���룺Ʒ����
% ���أ���ѯ�õ�������
l_sqlstr1='select distinct _t.contractid from (select contractid from marketdaydata_t';
l_sqlstr1=strcat(l_sqlstr1,' where contractid regexp ''^',in_commodityid,'[0-9].*(',in_months,')$'' order by currentdate) _t');

% �������ݿ�
l_conn=database('futuretest','root','123456');
l_cur=fetch(exec(l_conn,l_sqlstr1));
l_data=l_cur.data;

% ��������
if(strcmp(l_data,'No Data'))
    error('û��Ʒ��%s��Լ��Ϣ',in_commodityid);
else
    out_contractnames=l_data(:,1)';
end
close(l_cur);
close(l_conn);
end
