function ZR_CONFIG_SetFromDB(varargin)
% �����ݿ��еõ���������
global g_DBconfig;
global g_XMLfile;
global G_Start;

g_DBconfig.allcommoditynames={};
g_DBconfig.g_commoditynames={};
g_DBconfig.allcontractnames={};
g_DBconfig.g_pairnames={};
g_DBconfig.allpairs=[];

if iscell(g_XMLfile)    %���g_XMLfileXXXX.xml�ļ����
    l_DBconfig=struct('allcommoditynames',{},'g_commoditynames',{},'allcontractnames',{},...
        'g_pairnames',{},'allpairs',[],'currentdate',{},'strategyid',[],'g_rightid',{},'isupdated',[]);
    l_strategyinfo=struct('rightid',{},'firstcommodityid',{},'secondcommodityid',{},'firstcommodityunit',[],'secondcommodityunit',[]);
    for l_xmlid=1:numel(g_XMLfile)
%         l_strategyid=ZR_FUN_GetStrategyidFromXMLfile(g_XMLfile{l_xmlid});
        l_strategyid=g_XMLfile{l_xmlid}.strategyid;
        if find(cellfun(@isempty,strfind(varargin,strcat('g_DBconfig',l_strategyid,'.xml'))))==0     %��xml�ļ���ȡDBconfig��Ϣ
            l_DBconfig(l_xmlid)=xml_read(strcat(g_XMLfile{l_xmlid}.strategypath,'/','g_DBconfig',l_strategyid,'.xml'));
            if ~iscell(l_DBconfig(l_xmlid).allcommoditynames)
                    l_DBconfig(l_xmlid).allcommoditynames = {l_DBconfig(l_xmlid).allcommoditynames};
            end
            if ~iscell(l_DBconfig(l_xmlid).g_commoditynames)
                    l_DBconfig(l_xmlid).g_commoditynames = {l_DBconfig(l_xmlid).g_commoditynames};
            end
            if ~iscell(l_DBconfig(l_xmlid).g_rightid)
                    l_DBconfig(l_xmlid).g_rightid = {l_DBconfig(l_xmlid).g_rightid};
            end
                        % ��g_DBconfig�е�g_rightid��Ա��������Ҫ��num2str����
            for l_id = 1:length(l_DBconfig(l_xmlid).g_rightid) 
                l_DBconfig(l_xmlid).g_rightid{l_id} = num2str(l_DBconfig(l_xmlid).g_rightid{l_id});
                if length(l_DBconfig(l_xmlid).g_rightid{l_id}) < 12
                    l_DBconfig(l_xmlid).g_rightid{l_id} = strcat('0',l_DBconfig(l_xmlid).g_rightid{l_id});
                end
            end
            l_DBconfig(l_xmlid).strategyid=l_strategyid;
            l_DBconfig(l_xmlid).isupdated=0;
        else                        %�����ݿ��ȡDBconfig��Ϣ
            l_strategyinfo(l_xmlid)=ZR_FUN_QueryArbitrageInfo(l_strategyid);
            l_DBconfig(l_xmlid).allcommoditynames=unique(cat(1,l_strategyinfo(l_xmlid).firstcommodityid,l_strategyinfo(l_xmlid).secondcommodityid));
            l_DBconfig(l_xmlid).g_commoditynames=strcat(l_strategyinfo(l_xmlid).firstcommodityid,'-',l_strategyinfo(l_xmlid).secondcommodityid);           %����'-'˵����������
            l_DBconfig(l_xmlid).g_rightid=l_strategyinfo(l_xmlid).rightid;
            l_DBconfig(l_xmlid).allcontractnames={};
            l_DBconfig(l_xmlid).g_pairnames={};
            l_DBconfig(l_xmlid).allpairs=[];
            l_DBconfig(l_xmlid).currentdate=ZR_FUN_QueryMarketdataCurrentdate();
            l_DBconfig(l_xmlid).isupdated=0;
            for l_id=1:length(l_strategyinfo(l_xmlid).rightid)
                l_rightid=cell2mat(l_strategyinfo(l_xmlid).rightid(l_id));
                switch(l_rightid(7:8))
                    case '01'       %����������
                        l_months=ZR_FUN_QueryDeliverMonths(l_strategyinfo(l_xmlid).firstcommodityid{l_id});  %��ѯ��Ʒ��������Լ
                    case '02'       %����/������������
                        l_months=ZR_FUN_QueryMasterMonths(l_strategyinfo(l_xmlid).firstcommodityid{l_id});   %��ѯ��Ʒ��������Լ
                end
                l_contractnames=ZR_FUN_QueryContractnames(l_strategyinfo(l_xmlid).firstcommodityid{l_id},cell2mat(l_months));        %��ѯ��Ʒ�����к�Լ��
                l_DBconfig(l_xmlid).allcontractnames=cat(1,l_DBconfig(l_xmlid).allcontractnames,l_contractnames(:));
                switch l_rightid(1:2)       %��������
                    case '01'       %��������
%                         l_DBconfig(l_xmlid).g_commoditynames=strcat(l_strategyinfo(l_xmlid).firstcommodityid,'-',l_strategyinfo(l_xmlid).secondcommodityid);           %����'-'˵����������
%                         l_allpairs=struct('ctname1',[],'ctunit1',[],'ctname2',[],'ctunit2',[],'rightid',l_rightid);
%                         l_pairnames=cell((length(l_contractnames)-1),1);
%                         for l_ctid=1:(length(l_contractnames)-1)
%                             l_pairnames{l_ctid}=strcat(l_contractnames{l_ctid},'-',l_contractnames{l_ctid+1});
%                             l_allpairs(l_ctid)=struct('ctname1',l_contractnames{l_ctid},'ctunit1',l_strategyinfo(l_xmlid).firstcommodityunit(l_id),...
%                                 'ctname2',l_contractnames{l_ctid+1},'ctunit2',l_strategyinfo(l_xmlid).secondcommodityunit(l_id),'rightid',l_rightid);
%                         end
%                         l_DBconfig(l_xmlid).g_pairnames=cat(1,l_DBconfig(l_xmlid).g_pairnames,l_pairnames);
%                         l_DBconfig(l_xmlid).allpairs=cat(2,l_DBconfig(l_xmlid).allpairs,l_allpairs);
                    case '02'       %���Ʒ����
                    case '04'       %���߲���
                        l_DBconfig(l_xmlid).g_commoditynames=l_strategyinfo(l_xmlid).firstcommodityid;           %���߲��ԣ�ȥ��'-'
                    case '10'       %����������
                end
            end
        end
    end
    %ȡ��ͬ��Ʒ��Ʒ����Լ��������������������
    l_allcommoditynames=l_DBconfig(1).allcommoditynames;
    l_commoditynames=l_DBconfig(1).g_commoditynames;
    l_allcontractnames=l_DBconfig(1).allcontractnames;
    for l_dbid=2:numel(l_DBconfig)  
        l_allcomidx=ismember(l_allcommoditynames,l_DBconfig(l_dbid).allcommoditynames);
        l_comidx=ismember(l_commoditynames,l_DBconfig(l_dbid).g_commoditynames);
        l_cntidx=ismember(l_allcontractnames,l_DBconfig(l_dbid).allcontractnames);
        if isempty(find(l_allcomidx,1)) || isempty(find(l_comidx,1))
            error('û�й�ͬ��Ʒ����!');
        end
        l_allcommoditynames=l_allcommoditynames(l_allcomidx);
        l_commoditynames=l_commoditynames(l_comidx);
        l_allcontractnames=l_allcontractnames(l_cntidx);
    end
    g_DBconfig.allcommoditynames=l_allcommoditynames;
    g_DBconfig.g_commoditynames=l_commoditynames;
    g_DBconfig.allcontractnames=l_allcontractnames;

    % ����������Լ���ԣ�����Ҫ������������������Ϣ
    % g_DBconfig.g_pairnames=cat(1,g_DBconfig.g_pairnames,l_DBconfig(l_dbid).g_pairnames);
    % g_DBconfig.allpairs=cat(2,g_DBconfig.allpairs,l_DBconfig(l_dbid).allpairs);

    g_DBconfig.currentdate=ZR_FUN_QueryMarketdataCurrentdate();
    %ʹ��������id��Ϊg_DBconfig�Ĳ���id 
    g_DBconfig.strategyid=g_XMLfile{1}.strategyid;
    %rightid������һ��'rightid1'-'rightid2'-...
    g_DBconfig.g_rightid={};
    for l_commodityid=1:numel(g_DBconfig.g_commoditynames)
        l_rightid='';
        for l_stid=1:numel(l_strategyinfo)-1
            l_id=cell2mat(l_strategyinfo(l_stid).rightid(1));
            switch(l_id(1:2))
                case '01'
                    l_commodityindex=ismember(strcat(l_strategyinfo(l_stid).firstcommodityid,'-',l_strategyinfo(l_stid).secondcommodityid),g_DBconfig.g_commoditynames(l_commodityid));
                    l_rightid=strcat(l_rightid,l_strategyinfo(l_stid).rightid(l_commodityindex),'-');
                case '04'
                    l_commodityindex=ismember(l_strategyinfo(l_stid).firstcommodityid,g_DBconfig.g_commoditynames(l_commodityid));
                    l_rightid=strcat(l_rightid,l_strategyinfo(l_stid).rightid(l_commodityindex),'-');
            end
        end
        l_id=cell2mat(l_strategyinfo(end).rightid(1));
        switch(l_id(1:2))
            case '01'
                l_commodityindex=ismember(strcat(l_strategyinfo(end).firstcommodityid,'-',l_strategyinfo(end).secondcommodityid),g_DBconfig.g_commodiynames(l_commodityid));
                l_rightid=strcat(l_rightid,l_strategyinfo(end).rightid(l_commodityindex));
            case '04'
                l_commodityindex=ismember(l_strategyinfo(end).firstcommodityid,g_DBconfig.g_commoditynames(l_commodityid));
                l_rightid=strcat(l_rightid,l_strategyinfo(end).rightid(l_commodityindex));
        end
        g_DBconfig.g_rightid(l_commodityid,1)=l_rightid;
    end
%     %rightid�����������������Ժ��������Զ�Ӧ��ͬƷ��ʱ��ȡ�����Ե�rightid��Ϊ��Ʒ�ֵ�rightid
%     g_DBconfig.g_rightid={};
%     l_cnt=1;
%     for l_commodityid=1:numel(g_DBconfig.g_commoditynames)
%         for l_stid=1:numel(l_strategyinfo)
%             if ismember(g_DBconfig.g_commoditynames(l_commodityid),l_strategyinfo(l_stid).firstcommodityid)
%                 l_idx=find(ismember(l_strategyinfo(l_stid).firstcommodityid,g_DBconfig.g_commoditynames(l_commodityid))==1);
%                 g_DBconfig.g_rightid(l_cnt,1)=l_strategyinfo(l_stid).rightid(logical(l_idx));
%                 l_cnt=l_cnt+1;
%                 break;
%             end
%         end
%     end
    %
    g_DBconfig.isupdated=g_XMLfile{1}.isupdated;
else    %ֻ��һ��g_XMLfileXXXX.xml�ļ�
%     l_strategyid=ZR_FUN_GetStrategyidFromXMLfile(g_XMLfile);
    l_strategyid=g_XMLfile.strategyid;
    g_DBconfig.strategyid=l_strategyid;        
    l_strategyinfo=ZR_FUN_QueryArbitrageInfo(l_strategyid);
    g_DBconfig.allcommoditynames=unique(cat(1,l_strategyinfo.firstcommodityid,l_strategyinfo.secondcommodityid));
    g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);           %����'-'˵����������
    g_DBconfig.g_rightid=l_strategyinfo.rightid;
    g_DBconfig.currentdate=ZR_FUN_QueryMarketdataCurrentdate();
    g_DBconfig.isupdated=0;
    for l_id=1:length(l_strategyinfo.rightid)
        l_rightid=cell2mat(l_strategyinfo.rightid(l_id));
        switch(l_rightid(7:8))
            case '01'       %����������
                l_months=ZR_FUN_QueryDeliverMonths(l_strategyinfo.firstcommodityid{l_id});  %��ѯ��Ʒ��������Լ
            case '02'       %����/������������
                l_months=ZR_FUN_QueryMasterMonths(l_strategyinfo.firstcommodityid{l_id});   %��ѯ��Ʒ��������Լ
        end
        l_contractnames=ZR_FUN_QueryContractnames(l_strategyinfo.firstcommodityid{l_id},cell2mat(l_months));        %��ѯ��Ʒ�����к�Լ��
        g_DBconfig.allcontractnames=cat(1,g_DBconfig.allcontractnames,l_contractnames(:));
        switch l_rightid(1:2)       %��������
            case '01'       %��������
                g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);   %����'-'˵����������
                l_allpairs=struct('ctname1',[],'ctunit1',[],'ctname2',[],'ctunit2',[],'rightid',l_rightid);
                l_pairnames=cell((length(l_contractnames)-1),1);
                for l_ctid=1:(length(l_contractnames)-1)
                    l_pairnames{l_ctid}=strcat(l_contractnames{l_ctid},'-',l_contractnames{l_ctid+1});
                    l_allpairs(l_ctid)=struct('ctname1',l_contractnames{l_ctid},'ctunit1',l_strategyinfo.firstcommodityunit(l_id),...
                        'ctname2',l_contractnames{l_ctid+1},'ctunit2',l_strategyinfo.secondcommodityunit(l_id),'rightid',l_rightid);
                end
                g_DBconfig.g_pairnames=cat(1,g_DBconfig.g_pairnames,l_pairnames);
                g_DBconfig.allpairs=cat(2,g_DBconfig.allpairs,l_allpairs);
            case '02'       %���Ʒ����
            case '04'       %���߲���
                g_DBconfig.g_commoditynames=l_strategyinfo.firstcommodityid;           %���߲��ԣ�ȥ��'-'
            case '10'       %����������
        end    
    end
    
    if nargin>2
        if ismember('new',varargin)
        % д��xml�ļ�
            xml_write(strcat(G_Start.currentpath,'/','g_DBconfig',l_strategyid,'.xml'),g_DBconfig);
            exit;
        end
    end
end

% [l_unique_pairnames,l_pairnameidx]=unique(g_DBconfig.g_pairnames,'first');
% g_DBconfig.g_pairnames=g_DBconfig.g_pairnames(sort(l_pairnameidx));
% [l_unique_allpairs,l_allpairidx]=unique(g_DBconfig.allpairs,'first');
% g_DBconfig.allpairs=g_DBconfig.allpairs(sort(l_allpairidx));


% l_strategyid=ZR_FUN_GetMainStrategyid();
% % �����������а���'g_DBconfigXXXX.xml'�ļ�������ļ��л�ȡ������DB���ظ���
% if nargin>2 && ~isempty(strfind(varargin{3},'g_DBconfig'))
%         if exist(varargin{3})
%             g_DBconfig=xml_read(strcat(g_XMLfile{1}.strategypath,'/','g_DBconfig',l_strategyid,'.xml'));
%             % ��xml_read�ж�����g_DBconfig�����еĳ�Ա������Ҫ��ת�ò���
% %           g_DBconfig.allcommoditynames = g_DBconfig.allcommoditynames';
% %           g_DBconfig.allcontractnames = g_DBconfig.allcontractnames';
% %           g_DBconfig.g_rightid = g_DBconfig.g_rightid';
% %           g_DBconfig.g_pairnames = g_DBconfig.g_pairnames';
% %           g_DBconfig.allpairs = g_DBconfig.allpairs';
%             if ~iscell(g_DBconfig.allcommoditynames)
%                 g_DBconfig.allcommoditynames = {g_DBconfig.allcommoditynames};
%             end
%             if ~iscell(g_DBconfig.g_commoditynames)
%                 g_DBconfig.g_commoditynames = {g_DBconfig.g_commoditynames};
%             end
%             if ~iscell(g_DBconfig.g_rightid)
%                 g_DBconfig.g_rightid = {g_DBconfig.g_rightid};
%             end
%                     % ��g_DBconfig�е�g_rightid��Ա��������Ҫ��num2str����
%             for l_id = 1:length(g_DBconfig.g_rightid)
%                 g_DBconfig.g_rightid{l_id} = num2str(g_DBconfig.g_rightid{l_id});
%                 if length(g_DBconfig.g_rightid{l_id}) < 12
%                     g_DBconfig.g_rightid{l_id} = strcat('0',g_DBconfig.g_rightid{l_id});
%                 end
%             end
%             g_DBconfig.strategyid=l_strategyid;
%             g_DBconfig.isupdated=0;
%             return;
%         else
%             error('xml�ļ�������:%s',varargin{3});
%         end
% end
% 
% g_DBconfig.strategyid=l_strategyid;        
% l_strategyinfo=ZR_FUN_QueryArbitrageInfo(l_strategyid);
% g_DBconfig.allcommoditynames=unique(cat(1,l_strategyinfo.firstcommodityid,l_strategyinfo.secondcommodityid));
% g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);           %����'-'˵����������
% g_DBconfig.g_rightid=l_strategyinfo.rightid;
% g_DBconfig.allcontractnames={};
% g_DBconfig.g_pairnames={};
% g_DBconfig.allpairs=[];
% g_DBconfig.currentdate=ZR_FUN_QueryMarketdataCurrentdate();
% g_DBconfig.isupdated=0;
% for l_id=1:length(l_strategyinfo.rightid)
%     l_rightid=cell2mat(l_strategyinfo.rightid(l_id));
%     switch l_rightid(1:2)       %��������
%         case '01'       %��������
%             g_DBconfig.g_commoditynames=strcat(l_strategyinfo.firstcommodityid,'-',l_strategyinfo.secondcommodityid);           %����'-'˵����������
%         case '02'       %���Ʒ����
%         case '04'       %���߲���
%             g_DBconfig.g_commoditynames=l_strategyinfo.firstcommodityid;           %���߲��ԣ�ȥ��'-'
%         case '10'       %����������
%     end
%     switch(l_rightid(7:8))
%         case '01'       %����������
%             l_months=ZR_FUN_QueryDeliverMonths(l_strategyinfo.firstcommodityid{l_id});  %��ѯ��Ʒ��������Լ
%         case '02'       %����/������������
%             l_months=ZR_FUN_QueryMasterMonths(l_strategyinfo.firstcommodityid{l_id});   %��ѯ��Ʒ��������Լ
%     end
%     l_contractnames=ZR_FUN_QueryContractnames(l_strategyinfo.firstcommodityid{l_id},cell2mat(l_months));        %��ѯ��Ʒ�����к�Լ��
%     l_allpairs=struct('ctname1',[],'ctunit1',[],'ctname2',[],'ctunit2',[],'rightid',l_rightid);
%     g_DBconfig.allcontractnames=cat(1,g_DBconfig.allcontractnames,l_contractnames(:));
%     l_pairnames=cell((length(l_contractnames)-1),1);
%     for l_ctid=1:(length(l_contractnames)-1)
%         l_pairnames{l_ctid}=strcat(l_contractnames{l_ctid},'-',l_contractnames{l_ctid+1});
%         l_allpairs(l_ctid)=struct('ctname1',l_contractnames{l_ctid},'ctunit1',l_strategyinfo.firstcommodityunit(l_id),...
%             'ctname2',l_contractnames{l_ctid+1},'ctunit2',l_strategyinfo.secondcommodityunit(l_id),'rightid',l_rightid);
%     end
%     g_DBconfig.g_pairnames=cat(1,g_DBconfig.g_pairnames,l_pairnames);
%     g_DBconfig.allpairs=cat(2,g_DBconfig.allpairs,l_allpairs);
% end
% 
% if nargin > 2
%     switch varargin{3}                 
%         case 'new'
%         % д��xml�ļ�
%         xml_write(strcat(G_Start.currentpath,'/','g_DBconfig',l_strategyid,'.xml'),g_DBconfig);
%         exit;
%         otherwise        
%     end
% end
% 
% g_DBconfig.isupdated=g_XMLfile{1}.isupdated;
