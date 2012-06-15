function ZR_DATABASE_History_MasterPairs()
% �����ݿ��еõ������������Ժ���Ӧ��Լ������

% ��Ҫʹ�õ�ȫ�ֱ���
global G_ExtractHistoryDataFromMySQL;
global g_database;
% ��ʱ����
l_commoditynames=G_ExtractHistoryDataFromMySQL.allcommoditynames;
l_cmnum=length(l_commoditynames);
l_contractnames=G_ExtractHistoryDataFromMySQL.allcontractnames;
l_ctnum=length(l_contractnames);
l_pairs=G_ExtractHistoryDataFromMySQL.allpairs;
l_pairnum=length(G_ExtractHistoryDataFromMySQL.allpairs);
l_currentdate=G_ExtractHistoryDataFromMySQL.currentdate;
if l_pairnum > 0
l_pairnames{l_pairnum}='';
else
    l_pairnames = [];
end
 
% ���g_database�Ƿ���ڣ�����������������
if isempty(g_database)
    % �������ݸ�������
    g_database.currentdate=l_currentdate;
    % �������е�Ʒ������������е�Ʒ��������Ϣ
    g_database.commoditynames=l_commoditynames;
    for l_cmid=1:l_cmnum
        g_database.commodities(l_cmid).info=ZR_FUN_QueryCommodityInfo(l_commoditynames{l_cmid});
        g_database.commodities(l_cmid).name=l_commoditynames(l_cmid);
        g_database.commodities(l_cmid).serialmkdata=ZR_FUN_QuerySerialMarketData(l_commoditynames{l_cmid});
    end
    disp('����Ʒ�����ݻ�ȡ��ϣ�');
    % �������еĺ�Լ����������еĺ�Լ������Ϣ
    g_database.contractnames=l_contractnames;
    for l_ctid=1:l_ctnum
        l_ctname=l_contractnames{l_ctid};
        g_database.contracts(l_ctid).name=l_contractnames(l_ctid);
        g_database.contracts(l_ctid).cmid=find(strcmp(l_commoditynames,l_ctname(regexp(l_ctname,'[a-z_A-Z]'))));
        g_database.contracts(l_ctid).info=ZR_FUN_QueryActiveContractInfo(l_ctname);
        g_database.contracts(l_ctid).mkdata=ZR_FUN_QueryContractData(l_ctname);
        g_database.contracts(l_ctid).datalen=g_database.contracts(l_ctid).mkdata.datalen;
    end
    disp('���к�Լ���ݻ�ȡ��ϣ�');
    % �������е������ԣ�������е�������������Ϣ
    for l_pairid=1:l_pairnum
        l_ctname=l_pairs(l_pairid).ctname1;
        l_pairs(l_pairid).ctid1=find(strcmp(l_contractnames,l_ctname));
        l_ctname=l_pairs(l_pairid).ctname2;
        l_pairs(l_pairid).ctid2=find(strcmp(l_contractnames,l_ctname));
        l_pairnames{l_pairid}=strcat(l_pairs(l_pairid).ctname1,'-',l_pairs(l_pairid).ctname2);
        l_pairs(l_pairid).name=l_pairnames(l_pairid);
        l_pairs(l_pairid).mkdata=ZR_FUN_QueryPairData(l_pairs(l_pairid).ctname1,l_pairs(l_pairid).ctname2,...
            l_pairs(l_pairid).ctunit1,l_pairs(l_pairid).ctunit2);
%         l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
%             &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
        l_pairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(l_pairs(l_pairid).ctid1).info.daystolasttradedate...
           ,g_database.contracts(l_pairs(l_pairid).ctid2).info.daystolasttradedate);
        l_pairs(l_pairid).datalen=l_pairs(l_pairid).mkdata.datalen;
    end
    g_database.pairnames=l_pairnames;
    g_database.pairs=l_pairs;
    disp('����Ʒ�����ݻ�ȡ��ϣ�');
    disp('�������ݻ�ȡ��ϣ�');
    G_ExtractHistoryDataFromMySQL.isupdated=1;  
else
    % Ʒ��
    switch(G_ExtractHistoryDataFromMySQL.updatecommoditytype)
        case 'update'
            % �������е�Ʒ������������е�Ʒ��������Ϣ
            g_database.commoditynames=l_commoditynames;
            g_database.commodities=[];
            for l_cmid=1:l_cmnum
                g_database.commodities(l_cmid).info=ZR_FUN_QueryCommodityInfo(l_commoditynames{l_cmid});
                g_database.commodities(l_cmid).name=l_commoditynames(l_cmid);
                g_database.commodities(l_cmid).serialmkdata=ZR_FUN_QuerySerialMarketData(l_commoditynames{l_cmid});
            end 
            disp('����Ʒ�����ݸ�����ϣ�');
            G_ExtractHistoryDataFromMySQL.isupdated=1;
        case 'add'
            % ��������Ʒ������������е�Ʒ��������Ϣ
            for l_cmid=(length(g_database.commoditynames)+1):l_cmnum
                g_database.commodities(l_cmid).info=ZR_FUN_QueryCommodityInfo(l_commoditynames{l_cmid});
                g_database.commodities(l_cmid).name=l_commoditynames(l_cmid);
            end 
            g_database.commoditynames=l_commoditynames;
            disp('����Ʒ�����ݸ�����ϣ�');
            G_ExtractHistoryDataFromMySQL.isupdated=1;            
        otherwise
    end       
    % ��Լ
    switch(G_ExtractHistoryDataFromMySQL.updatecontracttype)
        case 'update'
            % �������еĺ�Լ����������еĺ�Լ������Ϣ
            g_database.contractnames=l_contractnames;
            g_database.contracts=[];            
            for l_ctid=1:l_ctnum
                l_ctname=l_contractnames{l_ctid};
                g_database.contracts(l_ctid).name=l_contractnames(l_ctid);
                g_database.contracts(l_ctid).cmid=find(strcmp(l_commoditynames,l_ctname(regexp(l_ctname,'[a-z_A-Z]'))));
                g_database.contracts(l_ctid).info=ZR_FUN_QueryActiveContractInfo(l_ctname);
                g_database.contracts(l_ctid).mkdata=ZR_FUN_QueryContractData(l_ctname);
                g_database.contracts(l_ctid).datalen=g_database.contracts(l_ctid).mkdata.datalen;
            end
            disp('���к�Լ���ݸ�����ϣ�');
            G_ExtractHistoryDataFromMySQL.isupdated=1;
        case 'add'
            % ���������ĺ�Լ����������еĺ�Լ������Ϣ
            for l_ctid=(length(g_database.contractnames)+1):l_ctnum
                l_ctname=l_contractnames{l_ctid};
                g_database.contracts(l_ctid).name=l_contractnames(l_ctid);
                g_database.contracts(l_ctid).cmid=find(strcmp(l_commoditynames,l_ctname(regexp(l_ctname,'[a-z_A-Z]'))));
                g_database.contracts(l_ctid).info=ZR_FUN_QueryActiveContractInfo(l_ctname);
                g_database.contracts(l_ctid).mkdata=ZR_FUN_QueryContractData(l_ctname);
                g_database.contracts(l_ctid).datalen=g_database.contracts(l_ctid).mkdata.datalen;
            end      
            g_database.contractnames=l_contractnames;
            disp('���к�Լ���ݸ�����ϣ�');
            G_ExtractHistoryDataFromMySQL.isupdated=1;            
        otherwise
    end
    % ������
    switch(G_ExtractHistoryDataFromMySQL.updatepairtype)
        case 'update'
            % �������е������ԣ�������е�������������Ϣ
            g_database.pairnames=[];
            g_database.pairs=[];
            for l_pairid=1:l_pairnum
                l_ctname=l_pairs(l_pairid).ctname1;
                l_pairs(l_pairid).ctid1=find(strcmp(l_contractnames,l_ctname));
                l_ctname=l_pairs(l_pairid).ctname2;
                l_pairs(l_pairid).ctid2=find(strcmp(l_contractnames,l_ctname));
                l_pairnames{l_pairid}=strcat(l_pairs(l_pairid).ctname1,'-',l_pairs(l_pairid).ctname2);
                l_pairs(l_pairid).name=l_pairnames(l_pairid);      
                l_pairs(l_pairid).mkdata=ZR_FUN_QueryPairData(l_pairs(l_pairid).ctname1,l_pairs(l_pairid).ctname2,...
                    l_pairs(l_pairid).ctunit1,l_pairs(l_pairid).ctunit2);
%                 l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
%                     &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
                l_pairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(l_pairs(l_pairid).ctid1).info.daystolasttradedate...
                   ,g_database.contracts(l_pairs(l_pairid).ctid2).info.daystolasttradedate);   
                l_pairs(l_pairid).datalen=l_pairs(l_pairid).mkdata.datalen;
            end
            g_database.pairnames=l_pairnames;
            g_database.pairs=l_pairs;
            disp('�������������ݸ�����ϣ�');
            G_ExtractHistoryDataFromMySQL.isupdated=1;
        case 'add'
            % ���������������ԣ�������е�������������Ϣ
            l_pairs=g_database.pairs;
            l_pairnames=g_database.pairnames;
            for l_pairid=(length(g_database.pairnames)+1):l_pairnum
                l_ctname=l_pairs(l_pairid).ctname1;
                l_pairs(l_pairid).ctid1=find(strcmp(l_contractnames,l_ctname));
                l_ctname=l_pairs(l_pairid).ctname2;
                l_pairs(l_pairid).ctid2=find(strcmp(l_contractnames,l_ctname));
                l_pairnames{l_pairid}=strcat(l_pairs(l_pairid).ctname1,'-',l_pairs(l_pairid).ctname2);
                l_pairs(l_pairid).name=l_pairnames(l_pairid);
                l_pairs(l_pairid).mkdata=ZR_FUN_QueryPairData(l_pairs(l_pairid).ctname1,l_pairs(l_pairid).ctname2,...
                    l_pairs(l_pairid).ctunit1,l_pairs(l_pairid).ctunit2);
%                 l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
%                     &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
                l_pairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(l_pairs(l_pairid).ctid1).info.daystolasttradedate...
                   ,g_database.contracts(l_pairs(l_pairid).ctid2).info.daystolasttradedate); 
                l_pairs(l_pairid).datalen=l_pairs(l_pairid).mkdata.datalen;
            end
            g_database.pairnames=l_pairnames;
            g_database.pairs=l_pairs;
            disp('�������������ݸ�����ϣ�');
            G_ExtractHistoryDataFromMySQL.isupdated=1;            
        otherwise
    end
end

end