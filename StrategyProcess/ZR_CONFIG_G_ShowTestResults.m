function ZR_CONFIG_G_ShowTestResults()
% ��¼���Խ��չʾ����
global G_ShowTestResults;
global g_XMLfile;
% �������
G_ShowTestResults.g_tables.returnrate.title={' ','һ��','����','����','����','����','����','����','����','����','ʮ��','ʮһ��','ʮ����','������'};
% ���ּ�¼��
G_ShowTestResults.g_tables.record.pos.rightid.title='rightid';
G_ShowTestResults.g_tables.record.pos.name.title='��������';
G_ShowTestResults.g_tables.record.pos.isclosepos.title='�Ƿ�ʵ��ƽ��';
G_ShowTestResults.g_tables.record.pos.opdate.title='��������';
G_ShowTestResults.g_tables.record.pos.cpdate.title='ƽ������';
G_ShowTestResults.g_tables.record.pos.opdateprice.title='���ּ۸񣨲';
G_ShowTestResults.g_tables.record.pos.cpdateprice.title='ƽ�ּ۸񣨲';
G_ShowTestResults.g_tables.record.pos.margin.title='��֤��';
G_ShowTestResults.g_tables.record.pos.optradecharge.title='����������';
G_ShowTestResults.g_tables.record.pos.cptradecharge.title='ƽ��������';
G_ShowTestResults.g_tables.record.pos.profit.title='ӯ�����';
G_ShowTestResults.g_tables.orderlist.name.title='��Լ����';
G_ShowTestResults.g_tables.orderlist.price.title='�۸�';
G_ShowTestResults.g_tables.orderlist.direction.title='���׷���';
% % G_ShowTestResults.g_tables.record.pos.type.title='��������';
% % G_ShowTestResults.g_tables.record.pos.optype.title='��������';
% % G_ShowTestResults.g_tables.record.pos.cptype.title='ƽ������';
% % G_ShowTestResults.g_tables.record.pos.opgapvl1.title='���ڿ��ֽ�����';
% % G_ShowTestResults.g_tables.record.pos.opgapvl2.title='Զ�ڿ��ֽ�����';
% % G_ShowTestResults.g_tables.record.pos.cpgapvl1.title='����ƽ�ֽ�����';
% % G_ShowTestResults.g_tables.record.pos.cpgapvl2.title='Զ��ƽ�ֽ�����';
% ���׼�¼��
% % G_ShowTestResults.g_tables.record.trade.name.title='��������';
% % G_ShowTestResults.g_tables.record.trade.opdate.title='���׿�ʼ����';
% % G_ShowTestResults.g_tables.record.trade.cpdate.title='���׽�������';
% % G_ShowTestResults.g_tables.record.trade.type.title='��������';
% % G_ShowTestResults.g_tables.record.trade.isclosepos.title='�Ƿ�ʵ��ƽ��';
% % G_ShowTestResults.g_tables.record.trade.profit.title='ӯ�����';
% ���ݱ�
G_ShowTestResults.g_tables.tabledata.reference=[];
G_ShowTestResults.g_tables.tabledata.sort=[];
G_ShowTestResults.g_tables.tabledata.returnrate=[];
G_ShowTestResults.g_tables.tabledata.record.pos=[];
G_ShowTestResults.g_tables.tabledata.record.trade=[];
G_ShowTestResults.g_tables.tabledata.orderlist=[];
G_ShowTestResults.g_tables.outfiletype='xls';
G_ShowTestResults.g_tables.outdir='TestResult/Tables';
% ������Ϣxls
G_ShowTestResults.g_tables.xls.outfile='TestResults';
G_ShowTestResults.g_tables.xls.reference.sheetname='reference';
G_ShowTestResults.g_tables.xls.sort.sheetname='sort';
G_ShowTestResults.g_tables.xls.returnrate.sheetname='returnrate';
G_ShowTestResults.g_tables.xls.record.pos.sheetname='posrecord';
G_ShowTestResults.g_tables.xls.record.trade.sheetname='traderecord';
G_ShowTestResults.g_tables.xls.optimization.filename='Optim';
G_ShowTestResults.g_tables.xls.orderlist.sheetname='orderlist';
% ������xml
G_ShowTestResults.g_tables.xml.record.pos.filename=strcat('posrecord-',num2str(g_XMLfile.userid));
G_ShowTestResults.g_tables.xml.returnrate.filename=strcat('returnrate-',num2str(g_XMLfile.userid));
G_ShowTestResults.g_tables.xml.reference.filename=strcat('reference-',num2str(g_XMLfile.userid));
G_ShowTestResults.g_tables.xml.dailyinfo.filename=strcat('dailyinfo-',num2str(g_XMLfile.userid));
G_ShowTestResults.g_tables.xml.orderlist.filename=strcat('orderlist-',num2str(g_XMLfile.userid));
% ����������
G_ShowTestResults.g_tables.reference.name.title='��Լ����';
G_ShowTestResults.g_tables.reference.costinput.title='Ͷ���ʽ�';
G_ShowTestResults.g_tables.reference.numoforder.title='��Ʒÿ�ʽ�������';
G_ShowTestResults.g_tables.reference.totalnetprofit.title='��ӯ������';
G_ShowTestResults.g_tables.reference.grossprofit.title='ëӯ�����';
G_ShowTestResults.g_tables.reference.grossloss.title='ë������';
G_ShowTestResults.g_tables.reference.avemonthreturnrate.title='ƽ���»ر���';
G_ShowTestResults.g_tables.reference.aveyearreturnrate.title='ƽ����ر���';
G_ShowTestResults.g_tables.reference.totaltradedays.title='��������';
G_ShowTestResults.g_tables.reference.totaltradenum.title='�ܽ��״���';
G_ShowTestResults.g_tables.reference.totaltradenumperday.title='�վ����״���';
G_ShowTestResults.g_tables.reference.profittradenum.title='ӯ�����״���';
G_ShowTestResults.g_tables.reference.losstradenum.title='�����״���';
G_ShowTestResults.g_tables.reference.profittraderate.title='ӯ�����״���/�ܽ��״���';
G_ShowTestResults.g_tables.reference.maxprofit.title='��󵥱�ӯ�����';
G_ShowTestResults.g_tables.reference.maxloss.title='��󵥱ʿ�����';
G_ShowTestResults.g_tables.reference.profitpertrade.title='ëӯ�����/ӯ�����״���';
G_ShowTestResults.g_tables.reference.losspertrade.title='ë������/�����״���';
G_ShowTestResults.g_tables.reference.returnpertrade.title='ƽ��ÿ�ν���ӯ�����';
G_ShowTestResults.g_tables.reference.expectedvalue.title='����ֵ';
G_ShowTestResults.g_tables.reference.maxdrawdown.title='����ʽ�ش�';
G_ShowTestResults.g_tables.reference.maxdrawdownspread.title='�˥����';
% �Ż���
l_titlenames=fieldnames(g_XMLfile.g_strategyparams);
l_commandstr='';
if ~isempty(l_titlenames)
    for l_titleid=1:length(l_titlenames)
        l_commandstr=strcat(l_commandstr,...
            sprintf('G_ShowTestResults.g_tables.optimization.param.%s.title=''%s'';',...
            l_titlenames{l_titleid},l_titlenames{l_titleid})); 
    end
end
eval(l_commandstr);  
G_ShowTestResults.g_tables.optimization.expectedvalue.title='expected';
% G_ShowTestResults.g_tables.optimization.param.period.title='����';
% G_ShowTestResults.g_tables.optimization.param.losses.title='ֹ�����';
% G_ShowTestResults.g_tables.optimization.param.wins.title='ӯ������';
% G_ShowTestResults.g_tables.optimization.param.countersofup.title='��������';
% G_ShowTestResults.g_tables.optimization.param.countersofdown.title='�½�����';
% G_ShowTestResults.g_tables.optimization.param.losses.title='ֹ�����';
% G_ShowTestResults.g_tables.optimization.param.sharp.title='쭵ķ���';
% G_ShowTestResults.g_tables.optimization.param.sharpdays.title='쭵�����';
% G_ShowTestResults.g_tables.optimization.expectedvalue.title='�������ֵ';

% ͼ��
G_ShowTestResults.g_figure.savetradebar.outdir='TestResult/Figure';
G_ShowTestResults.g_figure.savetradebar.outfiletype='-djpeg';
G_ShowTestResults.g_figure.savetradebar.issaved=0;

% ��ʾ����
G_ShowTestResults.g_tables.strategyid=g_XMLfile.strategyid;
G_ShowTestResults.g_tables.outdir=g_XMLfile.path;
G_ShowTestResults.g_figure.savetradebar.outdir=g_XMLfile.path;    
switch g_XMLfile.resulttype
    case 'xml'
        G_ShowTestResults.g_tables.outfiletype='xml';    
    case 'database'
        G_ShowTestResults.g_tables.outfiletype='database';     
        G_ShowTestResults.g_tables.userid=g_XMLfile.userid; 
        G_ShowTestResults.g_tables.ordernum=g_XMLfile.ordernum; 
        G_ShowTestResults.g_tables.strategyid=g_XMLfile.strategyid; 
    case 'xls'  
        G_ShowTestResults.g_tables.outfiletype='xls';
end


% if ~g_XMLfile.isupdated
%     G_ShowTestResults.g_tables.outfiletype='xml';
%     G_ShowTestResults.g_tables.outdir=g_XMLfile.path;
%     G_ShowTestResults.g_figure.savetradebar.outdir=g_XMLfile.path;
% elseif g_DBconfig.isupdated
%     G_ShowTestResults.g_tables.outfiletype='database';
% end
% G_ShowTestResults.g_tables.outfiletype='xls';
% G_ShowTestResults.g_tables.outfiletype='xml';
end