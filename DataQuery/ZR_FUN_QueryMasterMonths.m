function out_mastermonths=ZR_FUN_QueryMasterMonths(in_commodityid)
% ��ѯ��Ʒ�ֵ�������Լ
% ���룺Ʒ����
% ���أ���ѯ�õ�������
l_sqlstr1='select mastermonth from commodity_t';
l_sqlstr1=strcat(l_sqlstr1,' where commodityid=''',in_commodityid,'''');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    error('û��Ʒ��%s�����·���Ϣ',in_commodityid);
else
    out_mastermonths=l_data(:,1)';
end

end