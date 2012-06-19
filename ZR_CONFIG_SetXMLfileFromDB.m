function ZR_CONFIG_SetXMLfileFromDB(in_strategyid, in_userid, in_ordernum)
% �����ݿ��л�ò�������дXMLfile
% ���룺strategyid��userid��ordernum
global g_XMLfile;
g_XMLfile.coredata.startdate=[];
g_XMLfile.coredata.enddate=[];
g_XMLfile.g_commoditynames=[];
g_XMLfile.g_pairnames=[];
g_XMLfile.g_contractnames=[];
g_XMLfile.strategyid=in_strategyid;
g_XMLfile.path='';
g_XMLfile.strategypath='';
g_XMLfile.isupdated=0;
g_XMLfile.userid=in_userid;
g_XMLfile.ordernum=in_ordernum;
g_XMLfile.objecttype='future';
g_XMLfile.resulttype='database';

l_sqlstr1='SELECT startdate, commoditynames  FROM strategyweb ';
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',in_strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',in_userid,' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',in_ordernum,' ');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('webfuturetest_101',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    error('û�в���%s��Ϣ',in_stratedyid);
else
    g_XMLfile.coredata.startdate=l_data{1,1};
    if ~strcmp(l_data{1,2},'null')
        g_XMLfile.g_commoditynames=regexp(l_data{1,2}, '\|', 'split');
    end
end

% ��ȡ���Բ���
l_sqlstr1='SELECT paramname, paramvalue FROM strategyparam_t ';
l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',in_strategyid,''' ');
l_sqlstr1=strcat(l_sqlstr1,' and userid= ',in_userid,' ');
l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',in_ordernum,' ');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('webfuturetest_101',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    error('û�в���%s��Ϣ',in_stratedyid);
else
    for l_id=1:length(l_data(:,1))
        l_cmdstr=strcat('g_XMLfile.g_strategyparams.',l_data{l_id,1},'=',num2str(l_data{l_id,2}),';');
        eval(l_cmdstr);
    end
end

end