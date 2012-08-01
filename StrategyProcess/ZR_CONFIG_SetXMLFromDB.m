function ZR_CONFIG_SetXMLFromDB(in_strategyid,in_userid,in_ordernum)
% �����ݿ��л�ò�������дXMLfile
% ���룺in_strategyid, in_userid, in_ordernum
%
global g_XMLfile;
l_split=strfind(in_strategyid,'-');
if ~isempty(l_split)    %˵���ǲ������
    l_strategy={numel(l_split)+1};
    for l_stid=1:numel(l_split)
        l_strategy{l_stid}=in_strategyid(l_split(l_stid)-6:l_split(l_stid)-1);
    end
    l_strategy{end+1}=in_strategyid(l_split(end)+1:l_split(end)+6);
    for l_strategyid=1:numel(l_strategy)
        g_XMLfile{l_strategyid}.coredata.startdate=[];
        g_XMLfile{l_strategyid}.coredata.enddate=[];
        g_XMLfile{l_strategyid}.g_commoditynames=[];
        g_XMLfile{l_strategyid}.g_pairnames=[];
        g_XMLfile{l_strategyid}.g_contractnames=[];
        g_XMLfile{l_strategyid}.strategyid=l_strategy{l_strategyid};
        g_XMLfile{l_strategyid}.path='';
        g_XMLfile{l_strategyid}.strategypath='';
        g_XMLfile{l_strategyid}.isupdated=0;
        g_XMLfile{l_strategyid}.userid=in_userid;
        g_XMLfile{l_strategyid}.ordernum=in_ordernum;
        g_XMLfile{l_strategyid}.objecttype='future';
        g_XMLfile{l_strategyid}.resulttype='database';
        
        l_sqlstr1='SELECT startdate, commoditynames  FROM strategyweb ';
        l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',in_strategyid,''' ');
        l_sqlstr1=strcat(l_sqlstr1,' and userid= ',in_userid,' ');
        l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',in_ordernum,' ');
        % �������ݿ�
        l_data=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_sqlstr1);
        % ��������
        if(strcmp(l_data,'No Data'))
            error(strcat('û�в�����Ϣ:',in_strategyid));
        else
            g_XMLfile{l_strategyid}.coredata.startdate=l_data{1,1};
            if ~strcmp(l_data{1,2},'null')
                g_XMLfile{l_strategyid}.g_commoditynames=regexp(l_data{1,2}, '\|', 'split');
            end
        end
        
        % ��ȡ���Բ���
        l_sqlstr1='SELECT paramname, paramvalue FROM strategyparam_t ';
        l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',in_strategyid,''' ');
        l_sqlstr1=strcat(l_sqlstr1,' and userid= ',in_userid,' ');
        l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',in_ordernum,' ');
        % �������ݿ�
        l_data=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_sqlstr1);
        % ��������
        if(strcmp(l_data,'No Data'))
            error(strcat('û�в�����Ϣ:',in_strategyid));
        else    % ���ݵ������ԵĲ������ҵ�����еĲ�����������Ӧ���еĲ��Բ���ֵ
            l_subsqlstr='SELECT paramname FROM strategyparam_t ';
            l_subsqlstr=strcat(l_subsqlstr,' WHERE strategyid= ''',l_strategy{l_strategyid},''' ');
            l_subsqlstr=strcat(l_subsqlstr,' and userid= 0');
            l_subsqlstr=strcat(l_subsqlstr,' and ordernum= 0');
            l_subdata=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_subsqlstr);
            if(strcmp(l_subdata,'No Data'))
                error(strcat('û�в�����Ϣ:',l_strategy{l_strategyid}));
            else
                for l_id=1:length(l_subdata(:,1))
%                     l_index=strcmp(l_data(:,1),l_subdata(l_id,1),l_id);
                    l_index=find(strcmp(l_data(:,1),l_subdata(l_id,1))==1);
                    if isempty(l_index)
                        sprintf('ȱ�ٲ���%s�Ĳ�����',l_strategy{l_strategyid});
                        return;
                    end
                    if numel(l_index)>1
                        l_cmdstr=strcat('g_XMLfile{l_strategyid}.g_strategyparams.',l_data{l_index(l_strategyid),1},'=',num2str(l_data{l_index(l_strategyid),2}),';');
                    else
                        l_cmdstr=strcat('g_XMLfile{l_strategyid}.g_strategyparams.',l_data{l_index,1},'=',num2str(l_data{l_index,2}),';');
                    end
                    eval(l_cmdstr);
                end
            end
%             for l_id=1:length(l_data(:,1))
%                 l_cmdstr=strcat('g_XMLfile{l_strategyid}.g_strategyparams.',l_data{l_id,1},'=',num2str(l_data{l_id,2}),';');
%                 eval(l_cmdstr);
%             end
        end
    end
else    %��������
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
    l_data=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_sqlstr1);

    % ��������
    if(strcmp(l_data,'No Data'))
        error(strcat('û�в�����Ϣ:',in_strategyid));
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
    l_data=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_sqlstr1);

    % ��������
    if(strcmp(l_data,'No Data'))
        error(strcat('û�в�����Ϣ:',in_strategyid));
    else
        for l_id=1:length(l_data(:,1))
            l_cmdstr=strcat('g_XMLfile.g_strategyparams.',l_data{l_id,1},'=',num2str(l_data{l_id,2}),';');
            eval(l_cmdstr);
        end
    end
end


% g_XMLfile.coredata.startdate=[];
% g_XMLfile.coredata.enddate=[];
% g_XMLfile.g_commoditynames=[];
% g_XMLfile.g_pairnames=[];
% g_XMLfile.g_contractnames=[];
% g_XMLfile.strategyid=in_strategyid;
% g_XMLfile.path='';
% g_XMLfile.strategypath='';
% g_XMLfile.isupdated=0;
% g_XMLfile.userid=in_userid;
% g_XMLfile.ordernum=in_ordernum;
% g_XMLfile.objecttype='future';
% g_XMLfile.resulttype='database';

% l_sqlstr1='SELECT startdate, commoditynames  FROM strategyweb ';
% l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',in_strategyid,''' ');
% l_sqlstr1=strcat(l_sqlstr1,' and userid= ',in_userid,' ');
% l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',in_ordernum,' ');

% % �������ݿ�
% l_data=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_sqlstr1);
% 
% % ��������
% if(strcmp(l_data,'No Data'))
%     error(strcat('û�в�����Ϣ:',in_strategyid));
% else
%     g_XMLfile.coredata.startdate=l_data{1,1};
%     if ~strcmp(l_data{1,2},'null')
%         g_XMLfile.g_commoditynames=regexp(l_data{1,2}, '\|', 'split');
%     end
% end

% % ��ȡ���Բ���
% l_sqlstr1='SELECT paramname, paramvalue FROM strategyparam_t ';
% l_sqlstr1=strcat(l_sqlstr1,' WHERE strategyid= ''',in_strategyid,''' ');
% l_sqlstr1=strcat(l_sqlstr1,' and userid= ',in_userid,' ');
% l_sqlstr1=strcat(l_sqlstr1,' and ordernum= ',in_ordernum,' ');
% 
% % �������ݿ�
% l_data=ZR_DATABASE_AccessDB('webfuturetest_101','sql',l_sqlstr1);
% 
% % ��������
% if(strcmp(l_data,'No Data'))
%     error(strcat('û�в�����Ϣ:',in_strategyid));
% else
%     for l_id=1:length(l_data(:,1))
%         l_cmdstr=strcat('g_XMLfile.g_strategyparams.',l_data{l_id,1},'=',num2str(l_data{l_id,2}),';');
%         eval(l_cmdstr);
%     end
% end

end