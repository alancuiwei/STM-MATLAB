function ZR_STRATEGY_SERIAL(varargin)
% ������Լ�Ĵ���

% �õ���ȫ�ֱ���
global g_commoditynames;
global g_rawdata;
global g_coredata;
global g_traderecord;
global g_commodityparams;
global g_rightid;
global g_orderlist;
global g_XMLfile;

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
%     l_inputdata.strategyparams=g_commodityparams;
    % �������������
%     eval(strcat('[l_stoutput,TradeDay]=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
%     l_output=ZR_FUN_MoveToStoreHouse(l_inputdata,l_stoutput,TradeDay);

%     eval(strcat('l_output=ZR_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));

%     l_output=ZR_STRATEGY_COMBINE('040709','040705',l_inputdata);
%     prerecord=ZR_STRATEGY_SERIAL_PROCESS('040709','040706',l_inputdata);
%     l_output=ZR_FUN_MoveToStoreHousePerSerial(l_inputdata,prerecord);
%   
    % Ϊÿһ��Ʒ�ֳ�ʼ��dailyinfo��Ϣ
    l_inputdata=ZR_FUN_AddDailyInfoPerCommodity(l_inputdata);
    
    if numel(g_XMLfile)>1
        % ִ�в������
        for l_xmlid=1:numel(g_XMLfile)
            l_strategyid=ZR_FUN_GetStrategyidFromXMLfile(g_XMLfile{l_xmlid});
            l_inputdata.strategyparams=g_commodityparams{l_xmlid};
            eval(strcat('l_output_strategy=ZR_STRATEGY_SS',l_strategyid,'(l_inputdata);'));
            l_inputdata.commodity.dailyinfo=l_output_strategy.dailyinfo;
        end
    else
        % ִ�е�������
        l_inputdata.strategyparams=g_commodityparams;
        eval(strcat('l_output_strategy=ZR_STRATEGY_SS',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
    end
    
%     if numel(g_XMLfile.strategyid)>1
%         l_minor_strategyid=ZR_FUN_GetMinorStrategyid(); % �ҵ��β���id
%         % ִ�в������
%         eval(strcat('l_output_strategy1=ZR_STRATEGY_SS',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
% %         l_inputdata=ZR_FUN_SetDailyinfoForMinorStrategy(l_inputdata,l_output_strategy1);
%         l_inputdata.commodity.dailyinfo=l_output_strategy1.dailyinfo; %�޸�dailyinfo��Ϣ
%         eval(strcat('l_output_strategy=ZR_STRATEGY_SS',l_minor_strategyid,'(l_inputdata);'));
%     else
%         % ִ�е������Ժ���
%         eval(strcat('l_output_strategy=ZR_STRATEGY_SS',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
%     end
    
    % ִ���Ʋֲ���
    l_output_move=ZR_PROCESS_ShiftPositionPerSerial();
    % �ںϲ������ƲֵĽ��׼�¼
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