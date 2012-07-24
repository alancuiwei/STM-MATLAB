function outputdata=ZR_STRATEGY_S040705(inputdata)
%tmp=load('KDJRO.mat');
%inputdata=tmp.l_inputdata;
%==========================================================================
%���������ʼ������
outputdata.orderlist.price=[];
outputdata.orderlist.direction=[];
outputdata.orderlist.name={};
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
l_price(1,:)=outSlowK;
l_price(2,:)=outSlowD;%����ƽ������������������Price��
l_price(l_price==0)=Inf;
%==========================================================================
%�����Ϊԭ��Ѱ�ҽ���㣬����Ѱ�ҵ�����ŵ��������PositionTrade��
l_diffprice=l_price(1,:)-l_price(2,:);
l_signprice=l_diffprice(2:numel(l_diffprice)).*l_diffprice(1:numel(l_diffprice)-1);
l_pos=find(l_signprice<0);%����λ�ü�¼Ϊʵ�ʽ����ǰһ����,��ǰ��
l_posinter=find(l_diffprice==0);
l_postrade=[l_pos,l_posinter];
l_postrade=unique(sort(l_postrade));
%==========================================================================
%�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
Cnt=1;%��������
% figure('Name',cell2mat(inputdata.commodity.name));
% plot(l_price')
l_tradeday=zeros(1,numel(l_postrade));
l_direction=zeros(1,numel(l_postrade));
for l_posid=1:numel(l_postrade)
    if(l_signprice(l_postrade(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
        if(l_price(1,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)) && l_price(2,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)) ...
                && l_price(1,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(Cnt)=l_postrade(l_posid);
                l_direction(Cnt)=1;
                Cnt=Cnt+1;
        elseif(l_price(1,l_postrade(l_posid))>l_price(1,l_postrade(l_posid)+1)&&l_price(2,l_postrade(l_posid))>l_price(2,l_postrade(l_posid)+1) ...
                    && l_price(1,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                    l_tradeday(Cnt)=l_postrade(l_posid);
                    l_direction(Cnt)=-1;
                    Cnt=Cnt+1;
        end
    else %������λ�øպ�Ϊ����ʱ
        if(l_price(1,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)-1)&&l_price(2,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)-1) ...
                && l_price(1,l_postrade(l_posid)+1)>l_price(2,l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
            l_tradeday(Cnt)=l_postrade(l_posid);
            l_direction(Cnt)=1;
            Cnt=Cnt+1;
        elseif(l_price(1,l_postrade(l_posid)+1)<l_price(1,l_postrade(l_posid)-1)&&l_price(2,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)-1) ... 
                    && l_price(1,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(Cnt)=l_postrade(l_posid);
                l_direction(Cnt)=-1;
                Cnt=Cnt+1;
        end
    end   
end
l_tradeday(l_tradeday==0)=[];
l_direction(l_direction==0)=[];
%ȥ��������������յĽ�������
l_directionkey=l_direction(1);
for l_id = 2:numel(l_tradeday)
    if l_direction(l_id)==l_directionkey
        l_tradeday(l_id)=-1;
    else
        l_directionkey=l_direction(l_id);
    end
end
l_tradeday(l_tradeday==-1)=[];
l_realtradeday=unique(l_tradeday);
%==========================================================================
%����record�е�opdateprice,direction
for l_tradeid=1:numel(l_realtradeday)
    if(l_signprice(l_realtradeday(l_tradeid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
        if(l_price(1,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)) && l_price(2,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)) ...
                && l_price(1,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
            if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
                outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
            else
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                outputdata.record.direction(l_tradeid)=1;
            end
        elseif(l_price(1,l_realtradeday(l_tradeid))>l_price(1,l_realtradeday(l_tradeid)+1)&&l_price(2,l_realtradeday(l_tradeid))>l_price(2,l_realtradeday(l_tradeid)+1) ...
                    && l_price(1,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=-1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else 
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=-1;
                end
        end
    else %������λ�øպ�Ϊ����ʱ
        if(l_price(1,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)-1)&&l_price(2,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)-1) ...
                && l_price(1,l_realtradeday(l_tradeid)+1)>l_price(2,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
            outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
            outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
            outputdata.record.direction(l_tradeid)=1;
        elseif(l_price(1,l_realtradeday(l_tradeid)+1)<l_price(1,l_realtradeday(l_tradeid)-1)&&l_price(2,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)-1) ... 
                    && l_price(1,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=-1;
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


