function ZR_PROCESS_SaveDailyInfoToXML()
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
l_dailyinfoxml(length(g_reportset.dailyinfo.dailydatenum))=struct();
for l_id=1:length(g_reportset.dailyinfo.dailydatenum)
    l_dailyinfoxml(l_id).dailydatenum=l_dailyinfo.dailydatenum(l_id);
    % l_dailyinfoxml(l_id).margin=l_dailyinfo.margin(l_id);
    % l_dailyinfoxml(l_id).posnum=l_dailyinfo.posnum(l_id);
    l_dailyinfoxml(l_id).profit=l_dailyinfo.profit(l_id);
end
xml_write(strcat(g_tables.outdir,'/',g_tables.xml.dailyinfo.filename,'.xml'),l_dailyinfoxml);

end