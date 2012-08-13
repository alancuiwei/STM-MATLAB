function out_periodmkdata=ZR_FUN_ComputePeriodMKdata(input_mkdata,period)
% tmp=load('in.mat');
% inputdata=tmp.l_inputdata;
% period=input('输入时间周期period=');
Price1=input_mkdata.hp;
Price2=input_mkdata.lp;
Price3=input_mkdata.cp;
Price4=input_mkdata.op;
cnt=1;
for i=1:(numel(Price1)-period+1)
     if mod(i,period)==0
        O(cnt)=Price4(i+1-period);
        C(cnt)=Price3(i+1-period);
        H(cnt)=max(Price1(i+1-period:i));
        L(cnt)=min(Price2(i+1-period:i));
        cnt=cnt+1;
    end
end
out_periodmkdata.hp=H;
out_periodmkdata.lp=L;
out_periodmkdata.op=O;
out_periodmkdata.cp=C;