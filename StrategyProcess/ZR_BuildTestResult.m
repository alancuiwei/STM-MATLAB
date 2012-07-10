function ZR_BuildTestResult(varargin)
clear global;
% ����ȫ�ֱ���
global g_strategyid;
global g_path;
global g_database;
global g_matfilename;
global g_XMLfile;

global g_method;
global g_commoditynames;
global g_contractnames;
global g_pairnames;
global g_coredata;
global coredata;
global g_rightid;

global g_tradedata;
global g_report;
global g_reference;
global g_tables;
global g_figure;
global g_strategyparams;

% g_tradedata = [];
% g_report = [];
% g_reference = [];
% g_tables = [];
% g_figure = [];
% g_strategyparams = [];
% coredata = [];      % G_RunSpecialTestCase.coredata

if nargin < 0
    error('�����������');
end

switch varargin{1}
    case 'xml'
        ZR_CONFIG_SetFromXML(varargin{2});
    case 'database'     
        ZR_CONFIG_SetXMLfileFromDB(varargin{2},varargin{3},varargin{4});
end

% ����·��Ϊ��ǰ����·��
g_path=pwd;

% ʹ�õĲ�����
g_strategyid=varargin{2};
g_matfilename = 'DATABASE_History.mat';

addpath(strcat(pwd,'/','data'));
if exist(strcat(g_path,'/data/',g_matfilename),'file')
    % �������ݿ�����
    load(strcat(g_path,'/data/',g_matfilename));     %��mat�ļ�����g_database������
else
%     g_database=[];
    error('����������DATABASE_History.mat�ļ�');
end

% �������в���
ZR_CONFIG_RunSpecialTestCase();
% �������ɱ������
ZR_CONFIG_ShowTestResults();

% ����ʹ�õĺ�Լ����
g_contractnames=g_database.contractnames;

% �����ݽ��д���
g_method.rundataprocess();   

% ���в���
% �������·��
addpath(strcat(pwd,'/strategies/'));
for l_methodid=1:length(g_method.runstrategy)
    g_method.runstrategy(l_methodid).fun(varargin{:});
    ZR_PROCESS_MergeReportset();
end

% �����������ָ��
ZR_PROCESS_ComputeReferenceInwindow(coredata.startdate,coredata.enddate);

ZR_PROCESS_ShowReport();

% ɾ������·��
rmpath(strcat(pwd,'/strategies/'));
% ��ʾ����
disp('���Խ���');
