function ZR_FUN_Disp(varargin)
% ���ݲ�ͬ��ϵͳ��ӡ��log��ͬ
if ~isunix
    disp(varargin{1});
else
    disp(varargin{2});
end

end