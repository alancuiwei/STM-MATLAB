function ZR_PROGRAM_BuildTestsFromDB(varargin)
% �������ݿ������ݱ��������Ϣִ�����еĲ���
clc;
clear all;
disp('��ȡ���ݿ����������Ϣ');
l_strategydata=ZR_FUN_QueryWebstrategyConfigByDB();
for l_id=1:length(l_strategydata.strategyid)
    disp(strcat('strategyid:',l_strategydata.strategyid{l_id},' userid:',num2str(l_strategydata.userid{l_id}),' ordernum:',num2str(l_strategydata.ordernum{l_id})));
    ZR_PROGRAM_BuiltTestResult('database',l_strategydata.strategyid{l_id},num2str(l_strategydata.userid{l_id}),num2str(l_strategydata.ordernum{l_id}));
end
disp('����ִ�����');
end