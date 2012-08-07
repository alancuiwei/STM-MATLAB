function outputdata=FG(inputdata,T)
% tmp=load('in.mat');
% inputdata=tmp.l_inputdata;
% T=input('输入时间周期T=');
Price1=inputdata.commodity.serialmkdata.hp;
Price2=inputdata.commodity.serialmkdata.lp;
Price3=inputdata.commodity.serialmkdata.cp;
Price4=inputdata.commodity.serialmkdata.op;
cnt=1;
for i=1:(numel(Price1)-T+1)
     if mod(i,T)==0
        O(cnt)=Price4(i+1-T);
        C(cnt)=Price3(i+1-T);
        H(cnt)=max(Price1(i+1-T:i));
        L(cnt)=min(Price2(i+1-T:i));
        cnt=cnt+1;
    end
end
outputdata.hp=H;
outputdata.lp=L;
outputdata.op=O;
outputdata.cp=C;