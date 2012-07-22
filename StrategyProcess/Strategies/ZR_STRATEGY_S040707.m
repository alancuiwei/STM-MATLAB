function outputdata=ZR_STRATEGY_S040707(inputdata)
% tmp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\KDJDl.mat');
% inputdata=tmp.l_inputdata;
%==========================================================================
%���������ʼ������
outputdata.orderlist.price=[];
outputdata.orderlist.direction=[];
outputdata.record.opdate={};
outputdata.record.opdateprice=[];
outputdata.record.cpdate={};
outputdata.record.cpdateprice=[];
outputdata.record.isclosepos=[];
outputdata.record.direction=[];
outputdata.record.ctname={};
%==========================================================================
%�����KDJ����
[outSlowK,outSlowD] = TA_STOCH (inputdata.commodity.serialmkdata.hp,inputdata.commodity.serialmkdata.lp,inputdata.commodity.serialmkdata.cp, ...
    inputdata.strategyparams.K,inputdata.strategyparams.D,0,inputdata.strategyparams.J,0);
l_price(1,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*80;
l_price(2,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*20;
l_price(3,:)=outSlowD;%����ƽ������������������Price��
l_price(l_price==0)=inf;
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',outSlowD,'Sheet1','M');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','H');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','I');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','J');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','K');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','L');
%==========================================================================
%�����Ϊԭ��Ѱ�ҽ���㣬����Ѱ�ҵ�����ŵ��������PositionTrade��
l_lowdiffprice=l_price(2,:)-l_price(3,:);
l_lowsignprice=l_lowdiffprice(2:numel(l_lowdiffprice)).*l_lowdiffprice(1:numel(l_lowdiffprice)-1);
l_lowpos=find(l_lowsignprice<0);%����С��20�ĵ��λ��
l_lowposinter=find(l_lowdiffprice==0);
% PositionTrade1=unique([l_lowpos,l_lowposinter]);

l_highdiffprice=l_price(3,:)-l_price(1,:);
l_highsignprice=l_highdiffprice(2:numel(l_highdiffprice)).*l_highdiffprice(1:numel(l_highdiffprice)-1);
l_highpos=find(l_highsignprice<0);%�������80�ĵ��λ��
l_highposinter=find(l_highdiffprice==0);
% PositionTrade2=unique([l_highpos,l_highposinter]);

% l_signprice=unique([l_lowsignprice,l_highsignprice]);
% l_postrade=unique([PositionTrade1,PositionTrade2]);

l_signprice=[l_lowsignprice,l_highsignprice];
l_signprice=sort(l_signprice);
l_pos=[l_lowpos,l_highpos];
l_pos=sort(l_pos);
l_pos(1:1)=[];
l_posinter=[l_lowposinter,l_highposinter];
l_posinter=sort(l_posinter);

l_postrade=[l_pos,l_posinter];
l_postrade=unique(sort(l_postrade));
%==========================================================================
%�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
Cnt=2;%��������
l_tradeday=[];
if(l_signprice(l_postrade(1))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
        if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(1)=l_postrade(1);
        elseif(l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%����ͻ�Ƶ������ж�
                    l_tradeday(1)=l_postrade(1);
        end
else %������λ�øպ�Ϊ����ʱ
        if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %����ͻ�Ƶ������ж�
            l_tradeday(1)=l_postrade(1);
        elseif (l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%����ͻ�Ƶ������ж�
                l_tradeday(1)=l_postrade(1);
        end
end
for l_posid=2:numel(l_postrade)
    if(l_signprice(l_postrade(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
        if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)) && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1))&&...
                (l_price(3,l_tradeday(l_posid-1))>l_price(3,l_tradeday(l_posid-1)+1)&&l_price(2,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(Cnt)=l_postrade(l_posid);
                Cnt=Cnt+1;
        elseif(l_price(3,l_postrade(l_posid))>l_price(3,l_postrade(l_posid)+1)&&l_price(2,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)) && l_price(3,l_tradeday(l_posid-1)+1)>l_price(1,l_tradeday(l_posid-1)+1))%����ͻ�Ƶ������ж�
                    l_tradeday(Cnt)=l_postrade(l_posid);
                    Cnt=Cnt+1;
        else
                l_tradeday(Cnt)=l_tradeday(l_posid-1);
                Cnt=Cnt+1;
        end
    else %������λ�øպ�Ϊ����ʱ
        if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)) && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1))&&...
                (l_price(3,l_tradeday(l_posid-1))>l_price(3,l_tradeday(l_posid-1)+1)&&l_price(2,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)+1)) %����ͻ�Ƶ������ж�
            l_tradeday(Cnt)=l_postrade(l_posid);
            Cnt=Cnt+1;
        elseif (l_price(3,l_postrade(l_posid))>l_price(3,l_postrade(l_posid)+1)&&l_price(2,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)) && l_price(3,l_tradeday(l_posid-1)+1)>l_price(1,l_tradeday(l_posid-1)+1))%����ͻ�Ƶ������ж�
                l_tradeday(Cnt)=l_postrade(l_posid);
                Cnt=Cnt+1;
        else
                l_tradeday(Cnt)=l_tradeday(l_posid-1);
                Cnt=Cnt+1;
        end
    end   
end
%==========================================================================
%�ϲ��������ں�ǿ��ƽ������,��ʱ��Щʱ������н��׵ķ���
% l_tradeday=unique(l_tradeday);
% RealTradeDayBuff=[l_tradeday,ForceTrade'];
% RealTradeDayBuff=sort(RealTradeDayBuff);
% l_realtradeday=unique(RealTradeDayBuff);
l_realtradeday=unique(l_tradeday);
%==========================================================================
%����record�е�opdateprice,direction
for l_tradeid=1:numel(l_realtradeday)
    if(l_signprice(l_realtradeday(l_tradeid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
        if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
            if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.direction=-1;
                outputdata.orderlist.price=0;
            else
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                outputdata.record.direction(l_tradeid)=-1;
            end
        elseif(l_price(3,l_realtradeday(l_tradeid))>l_price(3,l_realtradeday(l_tradeid)+1)&&l_price(2,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
            if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
            else 
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
            end
        end
    else %������λ�øպ�Ϊ����ʱ
        if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
            outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
            outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
            outputdata.record.direction(l_tradeid)=-1;
        elseif(l_price(3,l_realtradeday(l_tradeid))>l_price(3,l_realtradeday(l_tradeid)+1)&&l_price(2,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
        end
    end   
    outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
end

%==========================================================================
%����outputdata.record,����ƽ�����ں�ƽ�ּ۸�
if(numel(outputdata.record.opdate)>=2)
    outputdata.record.cpdate=outputdata.record.opdate(2:end);
    outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
    outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
    outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
    outputdata.record.cpdate(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.date(end); 
    outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.op(end);
    %{
    if(inputdata.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
elseif(numel(outputdata.record.opdate)>=1)
    outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
    outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
    outputdata.record.isclosepos=0;
    %{
    if(inputdata.contract.info.daystolasttradedate<=0) 
        outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
    end
    %}
end


