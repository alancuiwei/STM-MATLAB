function ZR_STOCK_PROGRAM_Optimization(varargin)
% �����Ŀ�ִ���ļ�������Դ����'DATABASE_History.mat'
% ���룺���Բ�������ѡ�������������ļ�����ѡ��
% ������Ż�����
% ������ò��Բ����������£�
% |����������������������������������������������������������������������������
% |  varargin{1}  |   varargin{2}         |       varargin{3}         |  varargin{4} |
% ------------------------------------------------------------------------
% |     'all'     |  
% |     'xml'     |  'g_XMLfileXXXX.xml'  |   
% |     'xml'     |  'g_XMLfileXXXX.xml'  |       'new'               |
% |     'xml'     |  'g_XMLfileXXXX.xml'  |   'g_DBconfigXXXX.xml'    |
% |   'database'  |   strategyid          |       userid              |   ordernum   |

% ��������·��
if ~isdeployed
    addpath(strcat('./Strategies'));
end


switch varargin{1}
    case 'all'
%         ZR_STOCK_FUN_Disp('��ȡ���ݿ����������Ϣ!','extract DB configuration info!');
%         l_strategydata=ZR_STOCK_FUN_QueryWebstrategyConfigByDB();
%         for l_id=1:length(l_strategydata.strategyid)
%             disp(strcat('strategyid:',l_strategydata.strategyid{l_id},' userid:',num2str(l_strategydata.userid{l_id}),' ordernum:',num2str(l_strategydata.ordernum{l_id})));
%             ZR_STOCK_CONFIG_Start('database',l_strategydata.strategyid{l_id},num2str(l_strategydata.userid{l_id}),num2str(l_strategydata.ordernum{l_id}));
%             ZR_STOCK_RUN_Optimization();
%         end
%         ZR_STOCK_FUN_Disp('���в���ִ�����!','complete strategy running!'); 
    otherwise
        ZR_STOCK_CONFIG_Start(varargin{:});
        ZR_STOCK_RUN_Optimization();
end

% ɾ������·��
if ~isdeployed
    rmpath(strcat('./Strategies'));
end


end
