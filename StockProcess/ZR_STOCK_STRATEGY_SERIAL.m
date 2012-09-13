function ZR_STOCK_STRATEGY_SERIAL(varargin)
% ������Լ�Ĵ���

% �õ���ȫ�ֱ���
global g_commoditynames;
global g_rawdata;
global g_coredata;
global g_traderecord;
global g_commodityparams;
global g_rightid;
global g_orders;
global g_XMLfile;
global g_temprecord;

% ���ò��Բ���
if nargin>0
    ZR_STOCK_FUN_SetStrategyParams(varargin{:});
end

% ���û�к�Լ��������Ϣ������G_RunSpecialTestCase�еĺ�Լ����
if isempty(g_commoditynames)
    error('Ʒ�����б�û�г�ʼ��');
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
    l_inputdata=g_rawdata;
%     l_inputdata.strategyparams=g_commodityparams;
    % �������������
   
    % Ϊÿһ��Ʒ�ֳ�ʼ��dailyinfo��Ϣ
    l_inputdata.commodity.dailyinfo.date=l_inputdata.commodity.serialmkdata.date;
    l_inputdata.commodity.dailyinfo.trend=ones(numel(l_inputdata.commodity.serialmkdata.date),1)*2;
    l_inputdata.commodity.dailyinfo.trend(1)=0;
    if numel(g_XMLfile)>1
        % ִ�в������
        for l_xmlid=1:numel(g_XMLfile)
            if  numel(g_commodityparams) > 1
                l_inputdata.strategyparams=g_commodityparams{l_xmlid};
            else
                l_inputdata.strategyparams=g_commodityparams;                
            end
            eval(strcat('l_output_strategy=ZR_STOCK_STRATEGY_',g_XMLfile{l_xmlid}.strategyid,'(l_inputdata);'));
            if isempty(l_output_strategy.record.opdate)
                sprintf('��ϲ����в���:%s����Ʒ��:%sû�в��������Ϣ',g_XMLfile{l_xmlid}.strategyid,g_commoditynames{l_cmid})
                break;
            end
            % ���Ե�һ�������㷨������
            g_temprecord=cat(2,g_temprecord,l_output_strategy);
            l_inputdata.commodity.dailyinfo=l_output_strategy.dailyinfo;
        end
    else
        % ִ�е�������
        try
            l_inputdata.strategyparams=g_commodityparams;
            eval(strcat('l_output_strategy=ZR_STOCK_STRATEGY_',g_rawdata.rightid{1}(1:6),'(l_inputdata);'));
            if isempty(l_output_strategy.record.opdate)
                sprintf('����:%s����Ʒ��%sû�в��������Ϣ',g_rawdata.rightid{1}(1:6),g_commoditynames{l_cmid})
            end
        catch
            l_output_strategy.orderlist.price=[];
            l_output_strategy.orderlist.direction=[];
            l_output_strategy.orderlist.name={};   
            l_output_strategy.record.opdate={};
            l_output_strategy.record.opdateprice=[];
            l_output_strategy.record.cpdate={};
            l_output_strategy.record.cpdateprice=[];
            l_output_strategy.record.isclosepos=[];
            l_output_strategy.record.direction=[];
            l_output_strategy.record.ctname={};
            l_output_strategy.dailyinfo.date={};
            l_output_strategy.dailyinfo.trend=[];
        end
    end

    l_output=l_output_strategy;
    g_traderecord=l_output.record;
    g_orders=l_output.orderlist;
    ZR_STOCK_PROCESS_VerifyRecord();
    ZR_STOCK_PROCESS_TradeDataPerSerialContract();
    ZR_STOCK_PROCESS_OrderDataPerSerialContract();
    % ���㱨������
    ZR_STOCK_PROCESS_RecordReportPerCommodity(l_cmid);
    ZR_STOCK_PROCESS_OrderlistReportPerCommodity(l_cmid);
%     % ���潻�׵�ͼ��
%     ZR_STOCK_FUN_SaveTradeBarPerCommodity('contract');
end
% �������
ZR_STOCK_PROCESS_CollectReport();
