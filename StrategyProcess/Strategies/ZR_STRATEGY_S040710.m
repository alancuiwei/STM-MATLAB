function outputdata=ZR_STRATEGY_S040710(inputdata)
% ����ͻ�Ʋ���
% tmp=load('FWRa.mat');
% inputdata=tmp.l_inputdata;
%==========================================================================
% ���������ʼ������
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
l_dayhighprice=inputdata.commodity.serialmkdata.hp;
l_daylowprice=inputdata.commodity.serialmkdata.lp;
l_closeprice=inputdata.commodity.serialmkdata.cp;
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','A');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','B');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','C');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','D');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','E');
%==========================================================================
%�ҵ�20���ڵ���߼ۺ���ͼ�
for l_id=1:(numel(l_dayhighprice)-21)
    l_highprice(l_id)=max(l_dayhighprice(l_id:l_id+20));
    l_lowprice(l_id)=min(l_daylowprice(l_id:l_id+20));
end
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',l_highprice','Sheet1','F22:F2484');
%xlswrite('D:\zx\ZR_LIB_0619\040704\TestResults_SERIAL',l_lowprice','Sheet1','G22:G2484');
l_diffprice1=l_highprice-l_closeprice(22:end)';
l_signprice1=l_diffprice1(2:numel(l_diffprice1)).*l_diffprice1(1:numel(l_diffprice1)-1);
l_pos1=find(l_signprice1<0);%�������̼۴���������߼۵ĵ��λ��
l_posinter1=find(l_diffprice1==0);

l_diffprice2=l_closeprice(22:end)'-l_lowprice;
l_signprice2=l_diffprice2(2:numel(l_diffprice2)).*l_diffprice2(1:numel(l_diffprice2)-1);
l_pos2=find(l_signprice2<0);%�������̼۵���������ͼ۵ĵ��λ��
l_posinter2=find(l_diffprice2==0);

l_signprice=[l_signprice1,l_signprice2];
l_signprice=sort(l_signprice);
l_pos=[l_pos1,l_pos2]+21;
l_pos=sort(l_pos);
l_posinter=[l_posinter1,l_posinter2]+21;
l_posinter=sort(l_posinter);

l_postrade=[l_pos,l_posinter];
l_postrade=unique(sort(l_postrade));
%==========================================================================
%�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
        if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid))&&...
                l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)-20))%����ͻ�Ƶ������ж�
                TradeDay1(l_posid)=l_postrade(l_posid);
        else if(l_closeprice(l_postrade(l_posid))>l_closeprice(l_postrade(l_posid)+1)&&...
                    l_lowprice(l_postrade(l_posid)-20)>l_closeprice(l_postrade(l_posid)+1))%����ͻ�Ƶ������ж�
                    TradeDay1(l_posid)=l_postrade(l_posid);
            else
                TradeDay1(l_posid)=0;
            end
        end
    else %������λ�øպ�Ϊ����ʱ
        if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid))&&...
                l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)-20)) %����ͻ�Ƶ������ж�
            TradeDay1(l_posid)=l_postrade(l_posid);
        else if (l_closeprice(l_postrade(l_posid))>l_closeprice(l_postrade(l_posid)+1)&&...
                   l_lowprice(l_postrade(l_posid)-20)>l_closeprice(l_postrade(l_posid)+1))%����ͻ�Ƶ������ж�
                TradeDay1(l_posid)=l_postrade(l_posid);
            else
                TradeDay1(l_posid)=0;
            end
        end
end 
    if TradeDay1(l_posid)~=0
        break
    end
end
TradeDay(1)=TradeDay1(end);
Cnt=2;%��������
for l_id=2:numel(l_postrade)
        if(l_signprice(l_postrade(l_id))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_id))&&...
                l_closeprice(l_postrade(l_id)+1)>l_highprice(l_postrade(l_id)-20)&&...
                l_closeprice(TradeDay(l_id-1))>l_closeprice(TradeDay(l_id-1)+1)&&l_lowprice(TradeDay(l_id-1)-20)>l_closeprice(TradeDay(l_id-1)+1))%����ͻ�Ƶ������ж�
                TradeDay(Cnt)=l_postrade(l_id);
                Cnt=Cnt+1;
            elseif(l_closeprice(l_postrade(l_id))>l_closeprice(l_postrade(l_id)+1)&&...
                    l_lowprice(l_postrade(l_id)-20)>l_closeprice(l_postrade(l_id)+1)&&...
                    l_closeprice(TradeDay(l_id-1)+1)>l_closeprice(TradeDay(l_id-1)) &&l_closeprice(TradeDay(l_id-1)+1)>l_highprice(TradeDay(l_id-1)-20))%����ͻ�Ƶ������ж�
                    TradeDay(Cnt)=l_postrade(l_id);
                    Cnt=Cnt+1;
            else
                TradeDay(Cnt)=TradeDay(l_id-1);
                Cnt=Cnt+1;
            end
        else %������λ�øպ�Ϊ����ʱ
            if(l_closeprice(l_postrade(l_id)+1)>l_closeprice(l_postrade(l_id)-1)&&...
                l_closeprice(l_postrade(l_id)+1)>l_highprice(l_postrade(l_id)-21)&&...
                l_closeprice(TradeDay(l_id-1)-1)>l_closeprice(TradeDay(l_id-1)+1)&&l_lowprice(TradeDay(l_id-1)-21)>l_closeprice(TradeDay(l_id-1)+1)) %����ͻ�Ƶ������ж�
                TradeDay(Cnt)=l_postrade(l_id);
                Cnt=Cnt+1;
            elseif (l_closeprice(l_postrade(l_id)-1)>l_closeprice(l_postrade(l_id)+1)&&...
                   l_lowprice(l_postrade(l_id)-21)>l_closeprice(l_postrade(l_id)+1)&&...
                    l_closeprice(TradeDay(l_id-1)+1)>l_closeprice(TradeDay(l_id-1)-1)&&l_closeprice(TradeDay(l_id-1)+1)>l_highprice(TradeDay(l_id-1)-21))%����ͻ�Ƶ������ж�
                TradeDay(Cnt)=l_postrade(l_id);
                Cnt=Cnt+1;
            else
                TradeDay(Cnt)=TradeDay(l_id-1);
                Cnt=Cnt+1;
            end
        end
end
RealTradeDay=unique(TradeDay);
%==========================================================================
%����record�е�opdateprice,direction
for l_tradeid=1:numel(RealTradeDay)
    if(l_signprice(RealTradeDay(l_tradeid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
        if(l_closeprice(RealTradeDay(l_tradeid)+1)>l_closeprice(RealTradeDay(l_tradeid))&&...
                l_closeprice(RealTradeDay(l_tradeid)+1)>l_highprice(RealTradeDay(l_tradeid)-20)) %����ͻ�Ƶ������ж�
            if(RealTradeDay(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                outputdata.orderlist.direction=1;
                outputdata.orderlist.price=0;
            else
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(RealTradeDay(l_tradeid)+2); %��������׼�¼
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(RealTradeDay(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(l_tradeid)+2);
                outputdata.record.direction(l_tradeid)=1;
            end
        elseif(l_closeprice(RealTradeDay(l_tradeid))>l_closeprice(RealTradeDay(l_tradeid)+1)&&...
                    l_closeprice(RealTradeDay(l_tradeid)+1)<l_lowprice(RealTradeDay(l_tradeid)-20)) %����ͻ�Ƶ������ж�
                if(RealTradeDay(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=-1;
                    outputdata.orderlist.price=0;
                else 
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(RealTradeDay(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(RealTradeDay(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(RealTradeDay(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=-1;
                end
        end
    else %������λ�øպ�Ϊ����ʱ
        if(l_closeprice(RealTradeDay(l_tradeid)+1)>l_closeprice(RealTradeDay(l_tradeid)-1)&&...
                l_closeprice(RealTradeDay(l_tradeid)+1)>l_highprice(RealTradeDay(l_tradeid)-20)) %����ͻ�Ƶ������ж�
            outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(RealTradeDay(l_tradeid)+1);
            outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(RealTradeDay(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(l_tradeid)+1);
            outputdata.record.direction(l_tradeid)=1;
        elseif(l_closeprice(RealTradeDay(l_tradeid)+1)<l_closeprice(RealTradeDay(l_tradeid)-1)&&... 
                    l_closeprice(RealTradeDay(l_tradeid)+1)<l_lowprice(RealTradeDay(l_tradeid)-20)) %����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(RealTradeDay(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(RealTradeDay(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(RealTradeDay(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=-1;
        end
    end   
    outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(RealTradeDay(l_tradeid)+1);
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



