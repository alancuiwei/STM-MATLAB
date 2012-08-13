function out_periodmkdata=ZR_FUN_ComputePeriodMKdata(input_mkdata,period)
% period=input('输入时间周期period=');
l_cnt=1;
for i=1:(numel(input_mkdata.hp)-period+1)
     if mod(i,period)==0
        l_period_op(l_cnt)=input_mkdata.op(i+1-period);
        l_period_cp(l_cnt)=input_mkdata.cp(i+1-period);
        l_period_hp(l_cnt)=max(input_mkdata.hp(i+1-period:i));
        l_period_lp(l_cnt)=min(input_mkdata.lp(i+1-period:i));
        l_cnt=l_cnt+1;
    end
end
out_periodmkdata.hp=l_period_hp;
out_periodmkdata.lp=l_period_lp;
out_periodmkdata.op=l_period_op;
out_periodmkdata.cp=l_period_cp;