function ZR_PROGRAM_BuildTestsFromDB(varargin)
% �����Ŀ�ִ���ļ�������Դ����'DATABASE_History.mat'
% ���룺���Բ�������ѡ�������������ļ�����ѡ��
% ��������Ա���
%
% ���û�в��Բ�������������ݿ������ݱ��������Ϣִ�����еĲ���
% ������ò��Բ����������£�
% ________________________________________________________________________
% |              |     'xml'     |  'g_XMLfile_XXXX.xml'  |              |
% |  strategyid  ---------------------------------------------------------
% |              |   'database'  |         userid         |   ordernum   |
% |����������������������������������������������������������������������������
% |  varargin{1} |  varargin{2}  |       varargin{3}      |  varargin{4} |
% ------------------------------------------------------------------------
clc;
if nargin < 1
    disp('��ȡ���ݿ����������Ϣ');
    l_strategydata=ZR_FUN_QueryWebstrategyConfigByDB();
    for l_id=1:length(l_strategydata.strategyid)
        disp(strcat('strategyid:',l_strategydata.strategyid{l_id},' userid:',num2str(l_strategydata.userid{l_id}),' ordernum:',num2str(l_strategydata.ordernum{l_id})));
        ZR_BuildTestResult(l_strategydata.strategyid{l_id},'database',num2str(l_strategydata.userid{l_id}),num2str(l_strategydata.ordernum{l_id}));
    end
    disp('����ִ�����');
else
    ZR_BuildTestResult(varargin{:});
end