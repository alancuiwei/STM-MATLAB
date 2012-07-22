function ZR_CONFIG_SetFromDB(varargin)
% �����ݿ��еõ���������
global g_DBconfig;
global g_XMLfile;
global G_Start;

% �����������а���'g_DBconfigXXXX.xml'�ļ�������ļ��л�ȡ������DB���ظ���
if nargin>2 && ~isempty(strfind(varargin{3},'.xml'))
        if exist(varargin{3})
            g_DBconfig=xml_read(strcat(g_XMLfile.strategypath,'/','g_DBconfig',g_XMLfile.strategyid,'.xml'));
            % ��xml_read�ж�����g_DBconfig�����еĳ�Ա������Ҫ��ת�ò���
%           g_DBconfig.allcommoditynames = g_DBconfig.allcommoditynames';
%           g_DBconfig.allcontractnames = g_DBconfig.allcontractnames';
%           g_DBconfig.g_rightid = g_DBconfig.g_rightid';
%           g_DBconfig.g_pairnames = g_DBconfig.g_pairnames';
%           g_DBconfig.allpairs = g_DBconfig.allpairs';
            if ~iscell(g_DBconfig.allcommoditynames)
                g_DBconfig.allcommoditynames = {g_DBconfig.allcommoditynames};
            end
            if ~iscell(g_DBconfig.g_commoditynames)
                g_DBconfig.g_commoditynames = {g_DBconfig.g_commoditynames};
            end
            if ~iscell(g_DBconfig.g_rightid)
                g_DBconfig.g_rightid = {g_DBconfig.g_rightid};
            end
                    % ��g_DBconfig�е�g_rightid��Ա��������Ҫ��num2str����
            for l_id = 1:length(g_DBconfig.g_rightid)
                g_DBconfig.g_rightid{l_id} = num2str(g_DBconfig.g_rightid{l_id});
                if length(g_DBconfig.g_rightid{l_id}) < 12
                    g_DBconfig.g_rightid{l_id} = strcat('0',g_DBconfig.g_rightid{l_id});
                end
            end
            g_DBconfig.strategyid=g_XMLfile.strategyid;
            g_DBconfig.isupdated=0;
            return;
        else
            error('xml�ļ�������:%s',varargin{3});
        end
end

g_DBconfig.strategyid=g_XMLfile.strategyid;        
l_strategyinfo=ZR_FUN_QueryArbitrageInfo(g_XMLfile.strategyid);
g_DBconfig.allcommoditynames=unique(cat(1,l_strategyinfo.firstcommodityid,l_strategyinfo.secondcommodityid));
g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);           %����'-'˵����������
g_DBconfig.g_rightid=l_strategyinfo.rightid;
g_DBconfig.allcontractnames={};
g_DBconfig.g_pairnames={};
g_DBconfig.allpairs=[];
g_DBconfig.currentdate=ZR_FUN_QueryMarketdataCurrentdate();
g_DBconfig.isupdated=0;
for l_id=1:length(l_strategyinfo.rightid)
    l_rightid=cell2mat(l_strategyinfo.rightid(l_id));
    switch l_rightid(1:2)       %��������
        case '01'       %��������
            g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);           %����'-'˵����������
        case '02'       %���Ʒ����
        case '04'       %���߲���
            g_DBconfig.g_commoditynames=l_strategyinfo.firstcommodityid;           %���߲��ԣ�ȥ��'-'
        case '10'       %����������
    end
    switch(l_rightid(7:8))
        case '01'       %����������
            l_months=ZR_FUN_QueryDeliverMonths(l_strategyinfo.firstcommodityid{l_id});  %��ѯ��Ʒ��������Լ
        case '02'       %����/������������
            l_months=ZR_FUN_QueryMasterMonths(l_strategyinfo.firstcommodityid{l_id});   %��ѯ��Ʒ��������Լ
    end
    l_contractnames=ZR_FUN_QueryContractnames(l_strategyinfo.firstcommodityid{l_id},cell2mat(l_months));        %��ѯ��Ʒ�����к�Լ��
    l_allpairs=struct('ctname1',[],'ctunit1',[],'ctname2',[],'ctunit2',[],'rightid',l_rightid);
    g_DBconfig.allcontractnames=cat(1,g_DBconfig.allcontractnames,l_contractnames(:));
    l_pairnames=cell((length(l_contractnames)-1),1);
    for l_ctid=1:(length(l_contractnames)-1)
        l_pairnames{l_ctid}=strcat(l_contractnames{l_ctid},'-',l_contractnames{l_ctid+1});
        l_allpairs(l_ctid)=struct('ctname1',l_contractnames{l_ctid},'ctunit1',l_strategyinfo.firstcommodityunit(l_id),...
            'ctname2',l_contractnames{l_ctid+1},'ctunit2',l_strategyinfo.secondcommodityunit(l_id),'rightid',l_rightid);
    end
    g_DBconfig.g_pairnames=cat(1,g_DBconfig.g_pairnames,l_pairnames);
    g_DBconfig.allpairs=cat(2,g_DBconfig.allpairs,l_allpairs);
end

if nargin > 2
    switch varargin{3}                 
        case 'new'
        % д��xml�ļ�
        xml_write(strcat(G_Start.currentpath,'/','g_DBconfig',g_XMLfile.strategyid,'.xml'),g_DBconfig);
        exit;
        otherwise        
    end
end

g_DBconfig.isupdated=g_XMLfile.isupdated;
