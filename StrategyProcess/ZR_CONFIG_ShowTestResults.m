function ZR_CONFIG_ShowTestResults()
% ��¼���Խ��չʾ����
% global G_ShowTestResults;
global g_tables;
global g_figure;
global g_XMLfile;
global g_DBconfig;
% �������
g_tables.returnrate.title={' ','һ��','����','����','����','����','����','����','����','����','ʮ��','ʮһ��','ʮ����','������'};
% ���ּ�¼��
g_tables.record.pos.rightid.title='rightid';
g_tables.record.pos.name.title='��������';
g_tables.record.pos.isclosepos.title='�Ƿ�ʵ��ƽ��';
g_tables.record.pos.opdate.title='��������';
g_tables.record.pos.cpdate.title='ƽ������';
g_tables.record.pos.opdateprice.title='���ּ۸񣨲';
g_tables.record.pos.cpdateprice.title='ƽ�ּ۸񣨲';
g_tables.record.pos.margin.title='��֤��';
g_tables.record.pos.optradecharge.title='����������';
g_tables.record.pos.cptradecharge.title='ƽ��������';
g_tables.record.pos.profit.title='ӯ�����';
% % g_tables.record.pos.type.title='��������';
% % g_tables.record.pos.optype.title='��������';
% % g_tables.record.pos.cptype.title='ƽ������';
% % g_tables.record.pos.opgapvl1.title='���ڿ��ֽ�����';
% % g_tables.record.pos.opgapvl2.title='Զ�ڿ��ֽ�����';
% % g_tables.record.pos.cpgapvl1.title='����ƽ�ֽ�����';
% % g_tables.record.pos.cpgapvl2.title='Զ��ƽ�ֽ�����';
% ���׼�¼��
% % g_tables.record.trade.name.title='��������';
% % g_tables.record.trade.opdate.title='���׿�ʼ����';
% % g_tables.record.trade.cpdate.title='���׽�������';
% % g_tables.record.trade.type.title='��������';
% % g_tables.record.trade.isclosepos.title='�Ƿ�ʵ��ƽ��';
% % g_tables.record.trade.profit.title='ӯ�����';
% ���ݱ�
g_tables.tabledata.reference=[];
g_tables.tabledata.sort=[];
g_tables.tabledata.returnrate=[];
g_tables.tabledata.record.pos=[];
g_tables.tabledata.record.trade=[];
g_tables.outfiletype='xls';
g_tables.outdir='TestResult/Tables';
% ������Ϣxls
g_tables.xls.outfile='TestResults';
g_tables.xls.reference.sheetname='reference';
g_tables.xls.sort.sheetname='sort';
g_tables.xls.returnrate.sheetname='returnrate';
g_tables.xls.record.pos.sheetname='posrecord';
g_tables.xls.record.trade.sheetname='traderecord';
g_tables.xls.optimization.filename='Optim';
% ������xml
g_tables.xml.record.pos.filename=strcat('posrecord-',num2str(g_XMLfile.userid));
g_tables.xml.returnrate.filename=strcat('returnrate-',num2str(g_XMLfile.userid));
g_tables.xml.reference.filename=strcat('reference-',num2str(g_XMLfile.userid));
g_tables.xml.dailyinfo.filename=strcat('dailyinfo-',num2str(g_XMLfile.userid));

% ����������
g_tables.reference.name.title='��Լ����';
g_tables.reference.costinput.title='Ͷ���ʽ�';
g_tables.reference.numoforder.title='��Ʒÿ�ʽ�������';
g_tables.reference.totalnetprofit.title='��ӯ������';
g_tables.reference.grossprofit.title='ëӯ�����';
g_tables.reference.grossloss.title='ë������';
g_tables.reference.avemonthreturnrate.title='ƽ���»ر���';
g_tables.reference.aveyearreturnrate.title='ƽ����ر���';
g_tables.reference.totaltradedays.title='��������';
g_tables.reference.totaltradenum.title='�ܽ��״���';
g_tables.reference.totaltradenumperday.title='�վ����״���';
g_tables.reference.profittradenum.title='ӯ�����״���';
g_tables.reference.losstradenum.title='�����״���';
g_tables.reference.profittraderate.title='ӯ�����״���/�ܽ��״���';
g_tables.reference.maxprofit.title='��󵥱�ӯ�����';
g_tables.reference.maxloss.title='��󵥱ʿ�����';
g_tables.reference.profitpertrade.title='ëӯ�����/ӯ�����״���';
g_tables.reference.losspertrade.title='ë������/�����״���';
g_tables.reference.returnpertrade.title='ƽ��ÿ�ν���ӯ�����';
g_tables.reference.expectedvalue.title='����ֵ';
g_tables.reference.maxdrawdown.title='����ʽ�ش�';
g_tables.reference.maxdrawdownspread.title='�˥����';
% �Ż���
g_tables.optimization.param.period.title='����';
g_tables.optimization.param.losses.title='ֹ�����';
g_tables.optimization.param.wins.title='ӯ������';
% g_tables.optimization.param.countersofup.title='��������';
% g_tables.optimization.param.countersofdown.title='�½�����';
% g_tables.optimization.param.losses.title='ֹ�����';
% g_tables.optimization.param.sharp.title='쭵ķ���';
% g_tables.optimization.param.sharpdays.title='쭵�����';
g_tables.optimization.expectedvalue.title='�������ֵ';

% ͼ��
g_figure.savetradebar.outdir='TestResult/Figure';
g_figure.savetradebar.outfiletype='-djpeg';
g_figure.savetradebar.issaved=0;

% ��ʾ����
g_tables.strategyid=g_XMLfile.strategyid;
g_tables.outdir=g_XMLfile.path;
g_figure.savetradebar.outdir=g_XMLfile.path;    
switch g_XMLfile.resulttype
    case 'xml'
        g_tables.outfiletype='xml';    
    case 'database'
        g_tables.outfiletype='database';     
        g_tables.userid=g_XMLfile.userid; 
        g_tables.ordernum=g_XMLfile.ordernum; 
        g_tables.strategyid=g_XMLfile.strategyid; 
    case 'xls'  
        g_tables.outfiletype='xls';
end


% if ~g_XMLfile.isupdated
%     g_tables.outfiletype='xml';
%     g_tables.outdir=g_XMLfile.path;
%     g_figure.savetradebar.outdir=g_XMLfile.path;
% elseif g_DBconfig.isupdated
%     g_tables.outfiletype='database';
% end
% g_tables.outfiletype='xls';
% g_tables.outfiletype='xml';
end