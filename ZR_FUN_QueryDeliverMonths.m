function out_delivermonths=ZR_FUN_QueryDeliverMonths(in_commodityid)
% ��ѯ��Ʒ�ֵ�������Լ
% ���룺Ʒ����
% ���أ���ѯ�õ�������
l_sqlstr1='select delivermonth from commodity_t';
l_sqlstr1=strcat(l_sqlstr1,' where commodityid=''',in_commodityid,'''');

% �������ݿ�
l_conn=database('futuretest','root','123456');
l_cur=fetch(exec(l_conn,l_sqlstr1));
l_data=l_cur.data;

% ��������
if(strcmp(l_data,'No Data'))
    error('û��Ʒ��%s�����·���Ϣ',in_commodityid);
else
    out_delivermonths=l_data(:,1)';
end
close(l_cur);
close(l_conn);
end