function ZR_DATAPROCESS_010601()
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
    % ��g_database�ҵ���ǰƷ�����ڵ�λ�ã����û�и�Ʒ�֣�������
    l_realcmid=strcmp(g_database.commoditynames,g_commoditynames{l_cmid});
    if isempty(find(l_realcmid, 1))
        continue;
    end
    g_coredata(l_cmid).commodity.name=g_commoditynames(l_cmid);
    g_coredata(l_cmid).commodity.info=g_database.commodities(l_realcmid).info;
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
    l_realpairid=strncmp(g_database.pairnames,g_commoditynames{l_cmid},length(g_commoditynames{l_cmid}));  
    if isempty(find(l_realctid, 1))
        l_pairid=0;     
    else    
        l_pairid=1;
        l_pairnum=1;
        l_pair=g_database.pairs(l_realpairid);
        while l_pairnum<=length(g_database.pairs(l_realpairid))
            if isempty(find(strcmp(g_pairnames,g_database.pairnames(l_pairnum)),1))
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
                g_coredata(l_cmid).contract(l_ctid).name=l_contract(l_ctid).name; 
    %             % �����²�����
    %             % ��������
    %             l_lastdatevec=datevec(g_database.rawdata(l_realcmid).contract(l_ctid).mkdata.date(end));
    %             l_name=cell2mat(g_database.rawdata(l_realcmid).contract(l_ctid).name);
    %             l_delivermonth=str2double(l_name(end-1:end));
    %             if l_delivermonth==l_lastdatevec(2)
    %                 if l_delivermonth==1
    %                     l_lastdatevec=[l_lastdatevec(1)-1,12,31,0,0,0];
    %                 else
    %                     l_lastdatevec=[l_lastdatevec(1),l_lastdatevec(2)-1,eomday(l_lastdatevec(1),l_lastdatevec(2)-1),0,0,0];
    %                 end
    %                 l_lastdatenum=datenum(l_lastdatevec);
    %                 l_lastid=find(datenum(g_database.rawdata(l_realcmid).contract(l_ctid).mkdata.date)<=l_lastdatenum,1,'last');
    %                 if l_endid>l_lastid
    %                     l_endid=l_lastid;
    %                 end
    %             end
                % ��Լ��Ϣ
                g_coredata(l_cmid).contract(l_ctid).mkdata.date=l_contract(l_ctid).mkdata.date(l_startid:l_endid);
                g_coredata(l_cmid).contract(l_ctid).mkdata.op=l_contract(l_ctid).mkdata.op(l_startid:l_endid);
                g_coredata(l_cmid).contract(l_ctid).mkdata.hp=l_contract(l_ctid).mkdata.hp(l_startid:l_endid);
                g_coredata(l_cmid).contract(l_ctid).mkdata.lp=l_contract(l_ctid).mkdata.lp(l_startid:l_endid);
                g_coredata(l_cmid).contract(l_ctid).mkdata.cp=l_contract(l_ctid).mkdata.cp(l_startid:l_endid);
                g_coredata(l_cmid).contract(l_ctid).mkdata.vl=l_contract(l_ctid).mkdata.vl(l_startid:l_endid);
                g_coredata(l_cmid).contract(l_ctid).mkdata.oi=l_contract(l_ctid).mkdata.oi(l_startid:l_endid);
                g_coredata(l_cmid).contract(l_ctid).datalen=l_endid-l_startid+1; 
            end 
        end
        
        % ��������Ϣ
        if l_pairid
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
    %                     g_coredata(l_cmid).contract(l_pairid)=[];
    %                     g_coredata(l_cmid).pair(l_pairid)=[];
                    continue;
                end
                g_coredata(l_cmid).pair(l_pairid).name=l_pair(l_pairid).name;
    %                 % �����²�����
    %                 % ��������
    %                 l_lastdatevec=datevec(g_database.rawdata(l_realcmid).pair(l_pairid).mkdata.date(end));
    %                 l_name=cell2mat(g_database.rawdata(l_realcmid).pair(l_pairid).name);
    %                 l_halflen=ceil((length(l_name)-1)/2);
    %                 l_delivermonth=str2double(l_name(l_halflen-1:l_halflen));
    %                 if l_delivermonth==l_lastdatevec(2)
    %                     if l_delivermonth==1
    %                         l_lastdatevec=[l_lastdatevec(1)-1,12,31,0,0,0];
    %                     else
    %                         l_lastdatevec=[l_lastdatevec(1),l_lastdatevec(2)-1,eomday(l_lastdatevec(1),l_lastdatevec(2)-1),0,0,0];
    %                     end
    %                     l_lastdatenum=datenum(l_lastdatevec);
    %                     l_lastid=find(datenum(g_database.rawdata(l_realcmid).pair(l_pairid).mkdata.date)<=l_lastdatenum,1,'last');
    %                     if l_endid>l_lastid
    %                         l_endid=l_lastid;
    %                     end
    %                 end                
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
                g_coredata(l_cmid).pair(l_pairid).datalen=l_endid-l_startid+1; 
            end
        end
    end
    fprintf('%s�Ѿ�����g_coredata!',cell2mat(g_coredata(l_cmid).commodity.name));
end
end