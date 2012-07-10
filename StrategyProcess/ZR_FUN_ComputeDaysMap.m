function out_daysmap=ZR_FUN_ComputeDaysMap(in_daysnum, in_period)
%如果参数为alldaynum=9，limiteddaynum=4
%[1,2,3,4;
% 2,3,4,5;
% 3,4,5,6;
% 4,5,6,7;
% 5,6,7,8;
% 6,7,8,9;
% 7,8,9,9;
% 8,9,9,9;
% 9,9,9,9;]
l_temp1=imresize_old((1:in_daysnum)',[in_daysnum, in_period]);
l_temp2=imresize_old(0:(in_period-1),[in_daysnum, in_period]);
l_temp3=l_temp1+l_temp2;
out_daysmap=(l_temp3<=in_daysnum).*l_temp3+(l_temp3>in_daysnum).*in_daysnum;
end