function out_contractdata = ZR_FUN_QueryContractData(in_contractname)
% �����ݿ��еõ��ú�Լ������
% ���룺��Լ��
% ���أ���ѯ�õ������ݣ�struct(op,hp,lp,cp,vl.oi,index)
%       ��Լ���ݣ����ڡ������ߡ��͡��ա����������ֲ�����
l_sqlstr1='select currentdate,openprice,highprice,lowprice,closeprice,volume,openinterest from marketdaydata_t';
l_sqlstr1=strcat(l_sqlstr1,' where contractid=''', in_contractname, ''' and closeprice between 1 and 100000000 order by currentdate');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    out_contractdata=[];
    error('%sû�к�Լ����',cell2mat(in_contractname));
else
    out_contractdata=struct('date',{l_data(:,1)}',...
        'op',cell2mat(l_data(:,2)),...
        'hp',cell2mat(l_data(:,3)),...
        'lp',cell2mat(l_data(:,4)),...
        'cp',cell2mat(l_data(:,5)),...
        'vl',cell2mat(l_data(:,6)),...
        'oi',cell2mat(l_data(:,7)),...
        'datalen',length(l_data(:,2)));
end

end