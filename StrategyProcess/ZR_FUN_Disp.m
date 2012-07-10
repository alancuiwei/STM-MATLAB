function ZR_FUN_Disp(varargin)
% 根据不同的系统打印的log不同
if ~isunix
    disp(varargin{1});
else
    disp(varargin{2});
end

end