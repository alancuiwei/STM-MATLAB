function ZR_STRATEGY_SERIAL(varargin)
% ���Ӣ���Ĳ���:010601

% �õ���ȫ�ֱ���
global g_commoditynames;
global g_rawdata;
global g_coredata;
global g_traderecord;
global g_commodityparams;
global g_rightid;
global g_orderlist;

% ���ò��Բ���
% ZR_FUN_SetStrategyParams(varargin{:});

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
%     eval(strcat('[l_stoutput,TradeDay]=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
%     l_output=ZR_FUN_MoveToStoreHouse(l_inputdata,l_stoutput,TradeDay);

%     eval(strcat('l_output=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));

%     l_output=ZR_STRATEGY_COMBINE('040709','040705',l_inputdata);
%     prerecord=ZR_STRATEGY_SERIAL_PROCESS('040709','040706',l_inputdata);
%     l_output=ZR_FUN_MoveToStoreHousePerSerial(l_inputdata,prerecord);
%   
    %ִ�в��Ժ���
    eval(strcat('l_output_strategy=ZR_STRATEGY_S',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
    %ִ���Ʋֲ���
    l_output_move=ZR_PROCESS_ShiftPositionPerSerial();
    %�ںϲ������ƲֵĽ��׼�¼
    l_output=ZR_PROCESS_MergeStrategyAndShiftPos(l_output_strategy,l_output_move);
 
    g_traderecord=l_output.record;    
    g_orderlist=l_output.orderlist;
    ZR_PROCESS_TradeDataPerSerialContract();
    % ���㱨������
    ZR_PROCESS_RecordReportPerCommodity(l_cmid);
    ZR_PROCESS_OrderlistReportPerCommodity(l_cmid);
%     % ���潻�׵�ͼ��
%     ZR_FUN_SaveTradeBarPerCommodity('contract');
end
% �������
ZR_PROCESS_CollectReport();