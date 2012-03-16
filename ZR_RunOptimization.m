function ZR_RunOptimization(varargin)
% �����Ż�����

% ����ȫ�ֱ���
global G_ShowTestResults;
global G_Start;
global g_contractnames;
global g_commoditynames;
global g_pairnames;
global g_method;
global g_coredata;
global g_tables;
global g_figure;
global G_RunOptimization;
global g_optimization;
global g_reportformat;
% ��������ģʽ
G_Start.runmode='RunOptimization';
% ����ʹ�õĺ�Լ����
g_commoditynames=G_RunOptimization.g_commoditynames;
g_pairnames=G_RunOptimization.g_pairnames;
g_contractnames=G_RunOptimization.g_contractnames;
g_tables=G_ShowTestResults.g_tables;
g_figure=G_ShowTestResults.g_figure;
g_optimization=G_RunOptimization.g_optimization;
% ʹ�õķ���
g_reportformat=G_RunOptimization.g_report;
g_method=G_RunOptimization.g_method;
% �м����ݴ�������g_coredata
if isempty(g_coredata)
    if ~exist('g_coredata_optimization.mat', 'file')||(G_RunOptimization.coredata.needupdate)
        g_method.rundataprocess();
        save('g_coredata_optimization.mat','g_coredata');
    else
        load('g_coredata_optimization.mat');
    end
end
g_method.runopimization(varargin{:});
disp('�Ż����Խ���');
end