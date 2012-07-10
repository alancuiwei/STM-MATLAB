function out_strategyinfo=ZR_FUN_QueryArbitrageInfo(in_strategyid)
% ��ѯ����Ȩ�ޱ�õ���������ǰ�����Ʒ�֣�����CF��TA��a��������
% �����ݿ��еõ��ò��Ե���Ϣ
% ���룺������
% ���أ���ѯ�õ�������
l_sqlstr1='select rightid,firstcommodityid,secondcommodityid,firstcommodityunit,secondcommodityunit from commodityright_t';
l_sqlstr1=strcat(l_sqlstr1,' where rightid regexp ''^',in_strategyid,'''');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    error(strcat('û�в�����Ϣ:',in_strategyid));
else
    out_strategyinfo=struct('rightid',{l_data(:,1)}',...
        'firstcommodityid',{l_data(:,2)}',...
        'secondcommodityid',{l_data(:,3)}',...
        'firstcommodityunit',cell2mat(l_data(:,4)),...
        'secondcommodityunit',cell2mat(l_data(:,5)));
end

end