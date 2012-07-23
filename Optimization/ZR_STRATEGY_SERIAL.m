function ZR_STRATEGY_SERIAL(varargin)
% ���Ӣ���Ĳ���:010601

% �õ���ȫ�ֱ���
global g_commoditynames;
global g_rawdata;
global g_coredata;
global g_traderecord;
global g_commodityparams;
global g_rightid;

% ���ò��Բ���
ZR_FUN_SetStrategyParams(varargin{:});

% ���û�к�Լ��������Ϣ������G_RunSpecialTestCase�еĺ�Լ����
if isempty(g_commoditynames)
    error('Ʒ�����б�û�г�ʼ��');
end
%%%% �㷨����
l_cmnum=length(g_commoditynames);
% ����һ���������һ��
for l_cmid=1:l_cmnum         
    % ÿһ��Ʒ�ֳ�ʼ��
    ZR_FUN_InitGlobalVarsPerCommodity();
    g_rawdata=g_coredata(l_cmid);
    g_rawdata.rightid=g_rightid(l_cmid);
    % ����ÿһ��Ʒ�����ò��Բ���
    ZR_FUN_SetParamsPerCommodity(l_cmid);
    l_inputdata=g_rawdata;
    l_inputdata.strategyparams=g_commodityparams;
    % �������������
%     eval(strcat('l_output=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
    eval(strcat('[l_stoutput,TradeDay]=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
    l_output=ZR_FUN_MoveToStoreHouse(l_inputdata,l_stoutput,TradeDay);
%     switch g_strategyid
%         case '040704'
%             l_output=ZR_STRATEGY_040704(l_inputdata);
%         case '040705'
%             l_output=ZR_STRATEGY_040705(l_inputdata);
%         case '040706'
%             l_output=ZR_STRATEGY_040706(l_inputdata);
%     end
    g_traderecord=l_output.record;    
    ZR_PROCESS_TradeDataPerSerialContract();
    % ���㱨������
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
%     % ���潻�׵�ͼ��
%     ZR_FUN_SaveTradeBarPerCommodity('contract');
end
% �������
ZR_PROCESS_CollectReport();