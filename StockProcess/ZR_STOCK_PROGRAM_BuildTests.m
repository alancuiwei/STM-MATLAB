function ZR_STOCK_PROGRAM_BuildTests(varargin)
% �����Ŀ�ִ���ļ�������Դ����'DATABASE_History.mat'
% ���룺���Բ�������ѡ�������������ļ�����ѡ��
% ��������Ա���
%
% ���û�в��Բ�������������ݿ������ݱ��������Ϣִ�����еĲ���
% ������ò��Բ����������£�
% |����������������������������������������������������������������������������
% |  varargin{1}  |   varargin{2}         |       varargin{3}         |  varargin{4} |
% ------------------------------------------------------------------------
% |     'all'     |  
% |     'xml'     |  'g_XMLfileXXXX.xml'  |   
% |     'xml'     |  'g_XMLfileXXXX.xml'  |       'new'               |
% |     'xml'     |  'g_XMLfileXXXX.xml'  |   'g_DBconfigXXXX.xml'    |
% |     'xml'     |  'g_XMLfileXXXX1.xml' |   'g_XMLfileXXXX2.xml'    |
% |   'database'  |   strategyid          |       userid              |   ordernum   |

% ��������·��
if ~isdeployed
    addpath(strcat('./Strategies'));
end

ZR_STOCK_CONFIG_Start(varargin{:});
ZR_STOCK_RUN_SpecialTestCase();

% ɾ������·��
if ~isdeployed
    rmpath(strcat('./Strategies'));
end
