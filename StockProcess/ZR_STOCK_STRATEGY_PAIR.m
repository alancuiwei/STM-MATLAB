function ZR_STOCK_STRATEGY_PAIR(varargin)
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
if nargin>0
    ZR_STOCK_FUN_SetStrategyParams(varargin{:});
end

% ���û�к�Լ��������Ϣ������G_RunSpecialTestCase�еĺ�Լ����
if isempty(g_commoditynames)
    error('��Լ���б�û�г�ʼ��');
end
%%%% �㷨����
l_cmnum=length(g_commoditynames);
% ����һ���������һ��
for l_cmid=1:l_cmnum         
    % ÿһ��Ʒ�ֳ�ʼ��
    ZR_STOCK_FUN_InitGlobalVarsPerCommodity();
    g_rawdata=g_coredata(l_cmid);
    g_rawdata.rightid=g_rightid(l_cmid);
    % ����ÿһ��Ʒ�����ò��Բ���
    ZR_STOCK_FUN_SetParamsPerCommodity(l_cmid);
    % �õ�ͬƷ�ֺ�Լ������
    l_pairnum=length(g_rawdata.pair);
    % ����ͬƷ������������
    l_inputdata.commodity=g_rawdata.commodity;
    l_inputdata.strategyparms=g_commodityparams;
    for l_pairid=1:l_pairnum
        % ���������Ե�����
        l_inputdata.pair=g_rawdata.pair(l_pairid);
        % �����Լ��ָ��
        l_output=[];
        eval(strcat('l_output=ZR_STOCK_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
        g_orderlist=l_output.orderlist;
        g_traderecord=l_output.record;
%         switch g_strategyid
%             case '010603'
%                 g_traderecord=ZR_STOCK_STRATEGY_010603(l_inputdata);
%         end
        % ���㽻�׼�¼
        ZR_STOCK_PROCESS_TradeDataPerPair(l_pairid);
        ZR_STOCK_PROCESS_OrderDataPerPair(l_pairid);
        % ���㽻�׼�¼�����׼�¼�������Ե�����     
    end
    % ���㱨������
    ZR_STOCK_PROCESS_RecordReportPerCommodity(l_cmid);
    ZR_STOCK_PROCESS_OrderlistReportPerCommodity(l_cmid);
    % ���潻�׵�ͼ��
    ZR_STOCK_FUN_SaveTradeBarPerCommodity('pair');
end
% �������
ZR_STOCK_PROCESS_CollectReport();