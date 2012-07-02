function ZR_FUN_MEXA64()
fileFolder=fullfile('/home/ubuntu/lf/generated_mex_new');
dirOutput=dir(fullfile(fileFolder,'*.c'));
outfileNames={dirOutput.name}';
for l_fileid = 1:numel(outfileNames)
%     l_cmd = strcat('mex -I/usr/include/ta-lib -L/usr/lib/ta-lib -lta_common_csr -lta_libc_csr -lta_abstract_csr -lta_func_csr ',cell2mat(fileNames(l_fileid)),' -outdir /home/ubuntu/lf/ta-lib-mexa64');
    str = sprintf('mex -I/usr/include/ta-lib -L/usr/lib/ta-lib -lta_common_csr -lta_libc_csr -lta_abstract_csr -lta_func_csr %s -outdir /home/ubuntu/lf/ta-lib-mexa64',cell2mat(strcat(fileFolder,'/',outfileNames(l_fileid))));
    eval(str);
end