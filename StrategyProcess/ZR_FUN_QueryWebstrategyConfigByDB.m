function out_data=ZR_FUN_QueryWebstrategyConfigByDB()
% ��ѯwebstrategy��õ����õ���Ҫ��database�����õ�strategyid/userid/ordernum��
% �����ݿ��еõ��ò��Ե���Ϣ
% ���أ���ѯ�õ�������
l_sqlstr1='SELECT strategyid, userid, ordernum FROM strategyweb where configtype=''database''';

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    error('û�в�����Ϣ');
else
    out_data=struct('strategyid',{l_data(:,1)}',...
        'userid',{l_data(:,2)}',...
        'ordernum',{l_data(:,3)}');
end

end