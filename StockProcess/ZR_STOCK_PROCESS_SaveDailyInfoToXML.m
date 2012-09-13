function ZR_STOCK_PROCESS_SaveDailyInfoToXML()
global g_reportset;
global g_tables;
l_1970datenum=datenum('1970-01-01');
% ��ʼ��ʱ�䱣֤������
l_dailyinfo.dailydatenum=(g_reportset.dailyinfo.dailydatenum-l_1970datenum)*86400000;
% ��ʼ��ʱ�䱣֤������
% l_dailyinfo.margin=g_reportset.dailyinfo.margin;
% ��ʼ��ʱ���λ����
% l_dailyinfo.posnum=g_reportset.dailyinfo.posnum;
% ��ʼ��ʱ���������
l_dailyinfo.profit=g_reportset.dailyinfo.profit;
% ��ʼ�����׷�
l_dailyinfo.tradecharge=g_reportset.dailyinfo.tradecharge;
l_dailyinfoxml=struct();

% �������Ƶ�ʱ�䣬ɸѡ
if (strcmp(g_tables.startdate,'nolimit')...
    &&strcmp(g_tables.enddate,'nolimit'))
    % û������
    l_startid=1;
    l_endid=length(g_reportset.dailyinfo.dailydatenum);
else
    l_startdatenum=0;
    l_enddatenum=inf;
    if ~strcmp(g_tables.enddate,'nolimit')
        % ��������������
        % ��������
        l_enddatenum=datenum(g_tables.enddate,'yyyy-mm-dd');            
    end
    if ~strcmp(g_tables.startdate,'nolimit')
        % ��ʼ����������
        % ��������
        l_startdatenum=datenum(g_tables.startdate,'yyyy-mm-dd');            
    end
    % �����Լ����ʼid
    l_startid=find(g_reportset.dailyinfo.dailydatenum>=l_startdatenum,1,'first');
    l_endid=find(g_reportset.dailyinfo.dailydatenum<=l_enddatenum,1,'last');
end

for l_id=1:(l_endid-l_startid)
    l_dailyinfoxml(l_id).dailydatenum=l_dailyinfo.dailydatenum(l_id+l_startid-1);
    % l_dailyinfoxml(l_id).margin=l_dailyinfo.margin(l_id);
    % l_dailyinfoxml(l_id).posnum=l_dailyinfo.posnum(l_id);
    l_dailyinfoxml(l_id).profit=l_dailyinfo.profit(l_id+l_startid-1);
end
xml_write(strcat(g_tables.outdir,'/',g_tables.xml.dailyinfo.filename,'.xml'),l_dailyinfoxml);

end
