function ZR_DATAPROCESS_020603()
% ���g_rawdata���ݵ�Ԥ����

% ����ȫ�ֱ���
global G_RunSpecialTestCase;
global g_database;
global g_contractnames;
global g_commoditynames;
global g_pairnames;
global g_coredata;

l_cmnum=length(g_commoditynames);
for l_cmid=1:l_cmnum
    g_coredata(l_cmid).currentdate=g_database.currentdate;
    % ��g_database�ҵ���ǰƷ�����ڵ�λ�ã����û�и�Ʒ�֣�������
    g_coredata(l_cmid).commodity.name=g_commoditynames(l_cmid);
    l_cmname=g_commoditynames{l_cmid};
    l_split=strfind(l_cmname,'-');
    if isempty(l_split)
        l_realcmid=strcmp(g_database.commoditynames,l_cmname);
        g_coredata(l_cmid).commodity.info=g_database.commodities(l_realcmid).info;
    else
        l_realcmid=strcmp(g_database.commoditynames,l_cmname(1:(l_split-1)));
        g_coredata(l_cmid).commodity.info(1)=g_database.commodities(l_realcmid).info;
        l_realcmid=strcmp(g_database.commoditynames,l_cmname((l_split+1):end));
        g_coredata(l_cmid).commodity.info(2)=g_database.commodities(l_realcmid).info;            
    end
    % ����ѡ��ĺ�Լ��ɸѡ
    l_realctid=strncmp(g_database.contractnames,g_commoditynames{l_cmid},length(g_commoditynames{l_cmid}));
    if isempty(find(l_realctid, 1))
        l_ctid=0;     
    else
        l_ctid=1;
        l_ctnum=1;
        l_contract=g_database.contracts(l_realctid);
        while l_ctnum<=length(g_database.contracts(l_realctid))
            if isempty(find(strcmp(g_contractnames,g_database.contractnames(l_ctnum)),1))
                l_contract(l_ctid)=[];
            else
                l_ctid=l_ctid+1;
            end
            l_ctnum=l_ctnum+1;
        end
    end
    % ����ѡ��������ԣ�ɸѡ
    if isempty(l_split)
        l_realpairid=strncmp(g_database.pairnames,g_commoditynames{l_cmid},length(g_commoditynames{l_cmid}));  
    else
        l_matchstr=strcat('^',l_cmname(1:(l_split-1)),'\d{3,4}-',l_cmname((l_split+1):end),'\d{3,4}$');
        l_realpairid=~cellfun('isempty',regexp(g_database.pairnames,l_matchstr));        
    end
    if isempty(find(l_realpairid, 1))
        l_pairid=0;     
    else    
        l_pairid=1;
        l_pairnum=1;
        l_pair=g_database.pairs(l_realpairid);
        l_pairindex=find(l_realpairid);
        while l_pairnum<=length(g_database.pairs(l_realpairid))
            if isempty(find(strcmp(g_pairnames,g_database.pairnames(l_pairindex(l_pairnum))),1))
                l_pair(l_pairid)=[];
            else
                l_pairid=l_pairid+1;
            end
            l_pairnum=l_pairnum+1;
        end  
    end
    % �������Ƶ�ʱ�䣬ɸѡ
    if (strcmp(G_RunSpecialTestCase.coredata.startdate,'nolimit')...
        &&strcmp(G_RunSpecialTestCase.coredata.enddate,'nolimit'))
        % û������
        if l_ctid
            g_coredata(l_cmid).contract=l_contract;
        end
        if l_pairid
            g_coredata(l_cmid).pair=l_pair;
        end
        disp('coredata����ͬ�������£�');
    else
       
        l_startdatenum=0;
        l_enddatenum=inf;
        if strcmp(G_RunSpecialTestCase.coredata.startdate,'nolimit')
            % ��������������
            % ��������
            l_enddatenum=datenum(G_RunSpecialTestCase.coredata.enddate,'yyyy-mm-dd');            
        end
        if strcmp(G_RunSpecialTestCase.coredata.enddate,'nolimit')
            % ��ʼ����������
            % ��������
            l_startdatenum=datenum(G_RunSpecialTestCase.coredata.startdate,'yyyy-mm-dd');            
        end
        if l_ctid    
            % ������Ʒ�����к�Լ        
            l_ctnum=length(l_contract);
            for l_ctid=1:l_ctnum
                % �����Լ����ʼid
                l_startid=find(datenum(l_contract(l_ctid).mkdata.date)>=l_startdatenum,1,'first');
                l_endid=find(datenum(l_contract(l_ctid).mkdata.date)<=l_enddatenum,1,'last');
                if isempty(l_startid)||isempty(l_endid)
                    warning('%s��%s-%s�ڼ�û�����ݣ�',...
                        l_contract(l_ctid).name{1},...
                        G_RunSpecialTestCase.coredata.startdate,...
                        G_RunSpecialTestCase.coredata.enddate);
    %                 g_coredata(l_cmid).contract(l_ctid)=[];
    %                 g_coredata(l_cmid).pair(l_ctid)=[];
                    continue;
                end
                g_coredata(l_cmid).contract(l_ctid)=l_contract(l_ctid);
                if (l_endid-l_startid+1)~=l_contract(l_ctid).mkdata.datalen
                    % ��Լ��Ϣ
                    g_coredata(l_cmid).contract(l_ctid)=l_contract(l_ctid);
                    g_coredata(l_cmid).contract(l_ctid).name=l_contract(l_ctid).name; 
                    g_coredata(l_cmid).contract(l_ctid).mkdata.date=l_contract(l_ctid).mkdata.date(l_startid:l_endid);
                    g_coredata(l_cmid).contract(l_ctid).mkdata.op=l_contract(l_ctid).mkdata.op(l_startid:l_endid);
                    g_coredata(l_cmid).contract(l_ctid).mkdata.hp=l_contract(l_ctid).mkdata.hp(l_startid:l_endid);
                    g_coredata(l_cmid).contract(l_ctid).mkdata.lp=l_contract(l_ctid).mkdata.lp(l_startid:l_endid);
                    g_coredata(l_cmid).contract(l_ctid).mkdata.cp=l_contract(l_ctid).mkdata.cp(l_startid:l_endid);
                    g_coredata(l_cmid).contract(l_ctid).mkdata.vl=l_contract(l_ctid).mkdata.vl(l_startid:l_endid);
                    g_coredata(l_cmid).contract(l_ctid).mkdata.oi=l_contract(l_ctid).mkdata.oi(l_startid:l_endid);
                end
                g_coredata(l_cmid).contract(l_ctid).datalen=l_endid-l_startid+1; 
            end 
        end
        
        % ��������Ϣ
        if l_pairid
            g_coredata(l_cmid).pair=l_pair;
            % ������Ʒ������������        
            l_pairnum=length(l_pair);            
            for l_pairid=1:l_pairnum
                % �����Լ����ʼid
                l_startid=find(datenum(l_pair(l_pairid).mkdata.date)>=l_startdatenum,1,'first');
                l_endid=find(datenum(l_pair(l_pairid).mkdata.date)<=l_enddatenum,1,'last');
                if isempty(l_startid)||isempty(l_endid)
                    warning('%s��%s-%s�ڼ�û�����ݣ�',...
                        l_pair(l_pairid).name{1},...
                        G_RunSpecialTestCase.coredata.startdate,...
                        G_RunSpecialTestCase.coredata.enddate);
                    continue;
                end
                g_coredata(l_cmid).pair(l_pairid)=l_pair(l_pairid);
                if (l_endid-l_startid+1)~=l_pair(l_pairid).mkdata.datalen
                    g_coredata(l_cmid).pair(l_pairid).mkdata=[];
                    g_coredata(l_cmid).pair(l_pairid).name=l_pair(l_pairid).name;              
                    g_coredata(l_cmid).pair(l_pairid).mkdata.date=l_pair(l_pairid).mkdata.date(l_startid:l_endid);
                    g_coredata(l_cmid).pair(l_pairid).mkdata.op(:,1)=l_pair(l_pairid).mkdata.op(l_startid:l_endid,1);
                    g_coredata(l_cmid).pair(l_pairid).mkdata.op(:,2)=l_pair(l_pairid).mkdata.op(l_startid:l_endid,2);
                    g_coredata(l_cmid).pair(l_pairid).mkdata.cp(:,1)=l_pair(l_pairid).mkdata.cp(l_startid:l_endid,1);
                    g_coredata(l_cmid).pair(l_pairid).mkdata.cp(:,2)=l_pair(l_pairid).mkdata.cp(l_startid:l_endid,2);
                    g_coredata(l_cmid).pair(l_pairid).mkdata.vl(:,1)=l_pair(l_pairid).mkdata.vl(l_startid:l_endid,1);
                    g_coredata(l_cmid).pair(l_pairid).mkdata.vl(:,2)=l_pair(l_pairid).mkdata.vl(l_startid:l_endid,2);                
                    g_coredata(l_cmid).pair(l_pairid).mkdata.index(:,1)=l_pair(l_pairid).mkdata.index(l_startid:l_endid,1);
                    g_coredata(l_cmid).pair(l_pairid).mkdata.index(:,2)=l_pair(l_pairid).mkdata.index(l_startid:l_endid,2);                 
                    g_coredata(l_cmid).pair(l_pairid).mkdata.opgap=l_pair(l_pairid).mkdata.opgap(l_startid:l_endid);
                    g_coredata(l_cmid).pair(l_pairid).mkdata.cpgap=l_pair(l_pairid).mkdata.cpgap(l_startid:l_endid);
                end
                g_coredata(l_cmid).pair(l_pairid).datalen=l_endid-l_startid+1; 
            end
        end
    end
    fprintf('%s�Ѿ�����g_coredata!\n',cell2mat(g_coredata(l_cmid).commodity.name));
end
end