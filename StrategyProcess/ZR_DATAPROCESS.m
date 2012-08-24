function ZR_DATAPROCESS()
% ���g_rawdata���ݵ�Ԥ����

% ����ȫ�ֱ���
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
        % ��������-��˵���ǵ���
        l_realcmid=strcmp(g_database.commoditynames,l_cmname);
        g_coredata(l_cmid).commodity.info=g_database.commodities(l_realcmid).info;
        g_coredata(l_cmid).commodity.serialmkdata=g_database.commodities(l_realcmid).serialmkdata;
        % ����ѡ��ĺ�Լ��ɸѡ
        l_realctid=strncmp(g_database.contractnames,g_commoditynames{l_cmid},length(g_commoditynames{l_cmid}));
        if isempty(find(l_realctid, 1))
            l_ctid=0;     
        else
            l_ctid=1;
            l_ctnum=1;
            l_contract=g_database.contracts(l_realctid);
            l_contractname=g_database.contractnames(l_realctid);
            while l_ctnum<=length(g_database.contracts(l_realctid))
                if isempty(find(strcmp(g_contractnames,l_contractname(l_ctnum)),1))
                    l_contract(l_ctid)=[];
                    l_contractname(l_ctid)=[];
                else
                    l_ctid=l_ctid+1;
                end
                l_ctnum=l_ctnum+1;
            end
        end
        % �����Լ�������Ե�����
        if l_ctid
            g_coredata(l_cmid).contract=l_contract;
            g_coredata(l_cmid).contractname=l_contractname;
        end        
    else % ������-��˵����������
        l_realcmid=strcmp(g_database.commoditynames,l_cmname(1:(l_split-1)));
        g_coredata(l_cmid).commodity.info(1)=g_database.commodities(l_realcmid).info;
        l_realcmid=strcmp(g_database.commoditynames,l_cmname((l_split+1):end));
        g_coredata(l_cmid).commodity.info(2)=g_database.commodities(l_realcmid).info; 
        % ����ѡ��������ԣ�ɸѡ
        l_matchstr=strcat('^',l_cmname(1:(l_split-1)),'\d{3,4}-',l_cmname((l_split+1):end),'\d{3,4}$');
        l_realpairid=~cellfun('isempty',regexp(g_database.pairnames,l_matchstr));   
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
        % �����Լ�������Ե�����
        if l_pairid
            g_coredata(l_cmid).pair=l_pair;
        end 
    end
    ZR_FUN_Disp(sprintf('%s�Ѿ�����g_coredata!',cell2mat(g_coredata(l_cmid).commodity.name)),sprintf('%s import g_coredata!',cell2mat(g_coredata(l_cmid).commodity.name)));
end
end