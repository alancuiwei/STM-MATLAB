function ZR_ExtractHistoryDataFromMySQL()
% ��MySQL���ݿ���һ�λ�ȡ��������Ҫ����������
% �����ݿ�����ݱ��浽g_database��
% ���ս�g_database�����ݱ���Ϊ*.mat���ݿ��ļ�
% ����Ѿ����������ݿ��ļ�������֮ǰ�����ݿ��ļ�


% ��Ҫʹ�õ�ȫ�ֱ���
global G_ExtractHistoryDataFromMySQL;
global G_Start;
global g_database;
global g_method;

% ����
g_method=G_ExtractHistoryDataFromMySQL.g_method;

% ����Ƿ��Ѿ�����Ӧ��*.data���ݿ��ļ����ɣ�����о͵���
if exist(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename),'file')
    % �������ݿ�����
    load(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename));    
else
    g_database=[];
end

% ִ�д����ݿ���ȡ���ݵķ���
g_method.runextractdatabase(); 

if G_ExtractHistoryDataFromMySQL.isupdated
    G_ExtractHistoryDataFromMySQL.isupdated=0;
    if exist(strcat(G_Start.currentpath,'/','g_coredata_specialtestcase.mat'),'file')
        delete(strcat(G_Start.currentpath,'/','g_coredata_specialtestcase.mat'));
    end
    save(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename),'g_database');
    disp('���ݿ��ļ����£�');
    disp(dir(strcat(G_Start.currentpath,'/',G_ExtractHistoryDataFromMySQL.outfilename)));     
else 
    disp('���ݿ��ļ�û�и��£�'); 
end

end