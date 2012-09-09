function [out_totalvalue,out_commodityvalue]=ZR_TARGETFUNCTION_MostPessimistic()
% ��������ֵ

global g_commoditynames;
global g_report;
%%%%%%%%%%%%% �ܽ������
l_reference=[];
% �����������ֵ
% Ͷ���ʽ�
l_reference.costinput=max(abs(g_report.dailyinfo.margin)); 
% �ܽ��״���
l_reference.totaltradenum=g_report.record.pos.num;
% ӯ�����״���
l_reference.profittradenum=sum(g_report.record.pos.profit>0); 
% �����״���
l_reference.losstradenum=sum(g_report.record.pos.profit<=0);
% ÿ������ӯ��
l_reference.profitpertrade=sum(g_report.record.pos.profit(g_report.record.pos.profit>0))....
    /l_reference.profittradenum; 
% ÿ�����׿���
l_reference.losspertrade=sum(g_report.record.pos.profit(g_report.record.pos.profit<=0))....
    /l_reference.losstradenum;
% ���
out_totalvalue=(l_reference.profitpertrade*(l_reference.profittradenum-l_reference.profittradenum^0.5)...
    +l_reference.losspertrade*(l_reference.losstradenum+l_reference.losstradenum^0.5))/l_reference.costinput;

% ���Ʒ����
if iscell(g_commoditynames)
    l_cmnum=length(g_commoditynames);
else
    l_cmnum=1;
end
out_commodityvalue(l_cmnum)=0;
for l_cmid=1:l_cmnum 
    % �����Ʒ���������ֵ
    l_reference=[];
    if max(g_report.commodity(l_cmid).dailyinfo.margin)>0
        % Ͷ���ʽ�
        l_reference.costinput=max(abs(g_report.commodity(l_cmid).dailyinfo.margin)); 
        % �ܽ��״���
        l_reference.totaltradenum=g_report.commodity(l_cmid).record.pos.num;
        % ӯ�����״���
        l_reference.profittradenum=sum(g_report.commodity(l_cmid).record.pos.profit>0); 
        % �����״���
        l_reference.losstradenum=sum(g_report.commodity(l_cmid).record.pos.profit<=0);
        % ÿ������ӯ��
        l_reference.profitpertrade=sum(g_report.commodity(l_cmid).record.pos.profit(g_report.commodity(l_cmid).record.pos.profit>0))....
            /l_reference.profittradenum; 
        % ÿ�����׿���
        l_reference.losspertrade=sum(g_report.commodity(l_cmid).record.pos.profit(g_report.commodity(l_cmid).record.pos.profit<=0))....
            /l_reference.losstradenum;
        % ���
        out_commodityvalue(l_cmid)=(l_reference.profitpertrade*(l_reference.profittradenum-l_reference.profittradenum^0.5)...
            +l_reference.losspertrade*(l_reference.losstradenum+l_reference.losstradenum^0.5))/l_reference.costinput;   
    else
        out_commodityvalue(l_cmid)=0;
    end
end