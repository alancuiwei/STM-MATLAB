function ZR_PROGRAM_WriteToMatFromDB(varargin)
% ����Ʒ�����ƣ������ݿ�����ӦƷ�����Լ��Ϣд��mat�ļ�
% ���룺Ʒ������
% �����Ʒ�ֶ�Ӧ����Ϣд��mat�ļ�
%   �������        Ʒ������
%   varargin{1:7}  'TA' 'RO' 'a' 'l' 'p' 'v' 'y'
%  varargin{8}      --д���ļ���·������д��Ĭ�ϱ����ڵ�ǰ·����
% varargin{1}='RO';
numinputs = nargin;
if numinputs < 0
    error('��ָ��Ʒ������');
end
currentpath = pwd;
global g_database;
g_database.currentdate={};
g_database.commoditynames={};
g_database.commodities={};
g_database.contractnames={};
g_database.contracts={};
g_database.pairnames={};
g_database.pairs={};
% ���ݲ�������ȡ������Ϣ
% strategyinfo=ZR_FUN_QueryArbitrageInfo_new(varargin{:});
% �������ݸ�������
g_database.currentdate=ZR_FUN_QueryMarketdataCurrentdate();
% ��ȡƷ������
l_commoditynames={};
for id = 1:numinputs
    l_commoditynames = cat(2,l_commoditynames,varargin{id});
end
% g_database.commoditynames=unique(l_commoditynames);   uniqueִ�к���������򣿣���
g_database.commoditynames=l_commoditynames;
% �������е�Ʒ������������е�Ʒ��������Ϣ
for l_cmid=1:length(g_database.commoditynames)
    g_database.commodities(l_cmid).info=ZR_FUN_QueryCommodityInfo(g_database.commoditynames{l_cmid});
    g_database.commodities(l_cmid).name=g_database.commoditynames(l_cmid);
    g_database.commodities(l_cmid).serialmkdata=ZR_FUN_QuerySerialMarketData(g_database.commoditynames{l_cmid});
end
disp('����Ʒ�����ݻ�ȡ��ϣ�');

% ��ȡ��Լ����
allpairs=[];
for l_id=1:numel(g_database.commoditynames)
    l_rightid='1';      %��������Ϊ��1��
    l_months=ZR_FUN_QueryMasterMonths(g_database.commoditynames(l_id));       %��ѯ��Ʒ��������Լ
%     l_months=ZR_FUN_QueryDeliverMonths(g_database.commoditynames(l_id));    %��ѯ���º�Լ     
    l_contractnames=ZR_FUN_QueryContractnames(g_database.commoditynames(l_id),cell2mat(l_months));        %��ѯ��Ʒ�����к�Լ��
    l_allpairs=struct('ctname1',[],'ctunit1',[],'ctname2',[],'ctunit2',[],'rightid',l_rightid);
    g_database.contractnames=cat(1,g_database.contractnames,l_contractnames(:));    %�ݲ����ÿ�Ʒ��
%     l_pairnames=cell((length(l_contractnames)-1),1);
    for l_ctid=1:(length(l_contractnames)-1)
%         l_pairnames{l_ctid}=strcat(l_contractnames{l_ctid},'-',l_contractnames{l_ctid+1});
        l_allpairs(l_ctid)=struct('ctname1',l_contractnames{l_ctid},'ctunit1',1,...
                            'ctname2',l_contractnames{l_ctid+1},'ctunit2',1,'rightid',l_rightid);
    end
%     g_DBconfig.g_pairnames=cat(1,g_DBconfig.g_pairnames,l_pairnames);
    allpairs=cat(2,allpairs,l_allpairs);
end

% �������еĺ�Լ����������еĺ�Լ������Ϣ
for l_ctid=1:length(g_database.contractnames)
    l_ctname=g_database.contractnames{l_ctid};
    g_database.contracts(l_ctid).name=g_database.contractnames(l_ctid);
    g_database.contracts(l_ctid).cmid=find(strcmp(l_commoditynames,l_ctname(regexp(l_ctname,'[a-z_A-Z]'))));
    g_database.contracts(l_ctid).info=ZR_FUN_QueryActiveContractInfo(l_ctname);
    g_database.contracts(l_ctid).mkdata=ZR_FUN_QueryContractData(l_ctname);
    g_database.contracts(l_ctid).datalen=g_database.contracts(l_ctid).mkdata.datalen;
end
disp('���к�Լ���ݻ�ȡ��ϣ�');

% �������е������ԣ�������е�������������Ϣ
for l_pairid=1:length(allpairs)
    l_ctname=allpairs(l_pairid).ctname1;
    allpairs(l_pairid).ctid1=find(strcmp(g_database.contractnames,l_ctname));
    l_ctname=allpairs(l_pairid).ctname2;
    allpairs(l_pairid).ctid2=find(strcmp(g_database.contractnames,l_ctname));
    l_pairnames{l_pairid}=strcat(allpairs(l_pairid).ctname1,'-',allpairs(l_pairid).ctname2);
    allpairs(l_pairid).name=l_pairnames(l_pairid);
    allpairs(l_pairid).mkdata=ZR_FUN_QueryPairData(allpairs(l_pairid).ctname1,allpairs(l_pairid).ctname2,...
        allpairs(l_pairid).ctunit1,allpairs(l_pairid).ctunit2);
%         l_pairs(l_pairid).info.isactive=g_database.contracts(l_pairs(l_pairid).ctid1).info.isactive...
%             &g_database.contracts(l_pairs(l_pairid).ctid2).info.isactive;
    allpairs(l_pairid).info.daystolasttradedate=min(g_database.contracts(allpairs(l_pairid).ctid1).info.daystolasttradedate...
           ,g_database.contracts(allpairs(l_pairid).ctid2).info.daystolasttradedate);
    allpairs(l_pairid).datalen=allpairs(l_pairid).mkdata.datalen;
end
g_database.pairnames=l_pairnames;
g_database.pairs=allpairs;
disp('����Ʒ�����ݻ�ȡ��ϣ�');
disp('�������ݻ�ȡ��ϣ�');
    
% д�����ݵ�mat�ļ�
% time=datevec(datestr(now));
% time_month=num2str(time(2));
% time_day=num2str(time(3));
% if time(2)<10
%     time_month=strcat('0',num2str(time(2)));
% end
save(strcat(currentpath,'/','DATABASE_History.mat'),'g_database');
disp('���ݿ��ļ����£�');
disp(dir(strcat(currentpath,'/','DATABASE_History.mat')));

end