function out_contractnames=ZR_FUN_QueryContractnames(in_commodityid,in_months)
% ��ѯ��Ʒ�����еĺ�Լ��
% ���룺Ʒ����
% ���أ���ѯ�õ�������
l_sqlstr1='select distinct _t.contractid from (select contractid from marketdaydata_t';
l_sqlstr1=strcat(l_sqlstr1,' where contractid regexp ''^',in_commodityid,'[0-9].*(',in_months,')$'' order by currentdate) _t');

% �������ݿ�
l_data=ZR_DATABASE_AccessDB('futuretest','sql',l_sqlstr1);

% ��������
if(strcmp(l_data,'No Data'))
    error('û��Ʒ��%s��Լ��Ϣ',in_commodityid);
else
    % �Ժ�Լ������������
%     out_contractnames=l_data(:,1)';
    l_contractnames=sort(l_data(:,1)');
    for l_cnid = 1:length(l_contractnames)
        l_cnlen(l_cnid)=length(cell2mat(l_contractnames(l_cnid)));
    end
    l_cnlen=unique(l_cnlen);
    if numel(l_cnlen) == 1
        out_contractnames=l_contractnames;
        return;
    end
    l_cnlen=sort(l_cnlen,'descend');
%     l_tempcontractNames;
    for cnt = 1:length(l_cnlen)
        l_tempcontractNames(cnt).ctname={};
    end
    for l_cnid = 1:length(l_contractnames)
        for lenId = 1:length(l_cnlen)
            if length(cell2mat(l_contractnames(l_cnid)))==l_cnlen(lenId)
                l_tempcontractNames(lenId).ctname=cat(2,l_tempcontractNames(lenId).ctname,l_contractnames(l_cnid));
                break;
            end
        end
    end
    
    l_contractnames={};
    for lenId = 1:length(l_cnlen)
        l_contractnames=cat(2,l_contractnames,sort(l_tempcontractNames(lenId).ctname));
    end
    out_contractnames=l_contractnames;
%     for l_cnlenid = 1:length(l_cnlen)
%         contractNames=l_contractnames(l_cntractId(l_cnlenid));
%         out_contractnames=cat(1,out_contractnames,sort(contractNames));
%     end
end

end
