function outputdata=ZR_STRATEGY_SS040710(inputdata)
% ����ͻ�Ʋ���
% l_temp=load('G:\lm\STM-MATLAB-0710\StrategyProcess\MA60_l_inputdata.mat');
% inputdata=l_temp.l_inputdata;
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

outputdata.dailyinfo.date={};
outputdata.dailyinfo.trend=[];
%==========================================================================
l_dayhighprice=inputdata.commodity.serialmkdata.hp;
l_daylowprice=inputdata.commodity.serialmkdata.lp;
l_closeprice=inputdata.commodity.serialmkdata.cp;
%�ҵ�20���ڵ���߼ۺ���ͼ�
l_highprice=Inf*ones(1,numel(l_dayhighprice));     
l_lowprice=Inf*ones(1,numel(l_daylowprice));     
for l_id=1:numel(l_dayhighprice)
    if l_id>20
        l_highprice(l_id)=max(l_dayhighprice(l_id-20:l_id-1));
        l_lowprice(l_id)=min(l_daylowprice(l_id-20:l_id-1));
    end
end

l_diffprice1=l_highprice-l_closeprice';
l_signprice1=l_diffprice1(22:numel(l_diffprice1)).*l_diffprice1(21:numel(l_diffprice1)-1);
l_pos1=find(l_signprice1<0);%�������̼۴���������߼۵ĵ��λ��
l_posinter1=find(l_diffprice1==0);
l_postrade1=unique([l_pos1,l_posinter1]);

l_diffprice2=l_closeprice'-l_lowprice;
l_signprice2=l_diffprice2(22:numel(l_diffprice2)).*l_diffprice2(21:numel(l_diffprice2)-1);
l_pos2=find(l_signprice2<0);%�������̼۵���������ͼ۵ĵ��λ��
l_posinter2=find(l_diffprice2==0);
l_postrade2=unique([l_pos2,l_posinter2]);

l_signprice=[l_signprice1,l_signprice2];
l_postrade=unique([l_postrade1,l_postrade2]);                                   
%==========================================================================         

if isequal(zeros(numel(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend) %�ж��Ƿ���Ϊ�����Ի�һ����
    %�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
    l_cnt=1;%��������
    l_tradeday=zeros(1,numel(l_postrade));
    l_direction=zeros(1,numel(l_postrade));
    for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=1;
                l_cnt=l_cnt+1;
            elseif(l_closeprice(l_postrade(l_posid)+1)<l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)+1)<l_lowprice(l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=-1;
                l_cnt=l_cnt+1;
            end
        else %������λ�øպ�Ϊ����ʱ
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)-1)<l_highprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=1;
                l_cnt=l_cnt+1;
            elseif(l_closeprice(l_postrade(l_posid)+1)<l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)-1)>l_lowprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)+1)<l_lowprice(l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_direction(l_cnt)=-1;
                l_cnt=l_cnt+1;
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
            if(l_closeprice(l_realtradeday(l_tradeid)+1)>l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)>l_highprice(l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            elseif(l_closeprice(l_realtradeday(l_tradeid)+1)<l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)<l_lowprice(l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
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
            if(l_closeprice(l_realtradeday(l_tradeid)+1)>l_closeprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)-1)<l_highprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)>l_highprice(l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
            elseif(l_closeprice(l_realtradeday(l_tradeid)+1)<l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)-1)>l_lowprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)<l_lowprice(l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
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
    %======================================================================
    %����dailyinfo��Ϣ
    outputdata.dailyinfo.date=inputdata.commodity.serialmkdata.date;
    outputdata.dailyinfo.trend=-Inf*ones(numel(inputdata.commodity.serialmkdata.date),1);
    for i = 1:numel(outputdata.record.direction)
        if outputdata.record.direction(i)==1
            outputdata.dailyinfo.trend(l_realtradeday(i)+1)=2;    %����
        elseif outputdata.record.direction(i)==-1
            outputdata.dailyinfo.trend(l_realtradeday(i)+1)=1;    %����
        end
    end
    if ~isempty(outputdata.orderlist)   %�ͽ���������ͽ���֮��
        if outputdata.orderlist.direction==1
            outputdata.dailyinfo.trend(l_realtradeday(end))=2;
        elseif outputdata.orderlist.direction==-1
            outputdata.dailyinfo.trend(l_realtradeday(end))=1;
        end
    end
    l_trendIdx=find(outputdata.dailyinfo.trend~=-Inf);
    if ~isempty(l_trendIdx)
        if l_trendIdx(1)>1
            outputdata.dailyinfo.trend(1:l_trendIdx(1)-1)=4;    %����
        else
            outputdata.dailyinfo.trend(1)=4;
        end
        l_trend=outputdata.dailyinfo.trend(l_trendIdx(1));      %���ȱ
        for i = l_trendIdx(1)+1:numel(outputdata.dailyinfo.trend)
            if outputdata.dailyinfo.trend(i)==-Inf
                outputdata.dailyinfo.trend(i)=l_trend;
            else
                l_trend=outputdata.dailyinfo.trend(i);
            end
        end
    end
    %======================================================================
else        %������Ϊ�β��ԣ�����������������
    %�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
    l_cnt=1;%��������
    l_tradeday=zeros(1,numel(l_postrade));
    l_direction=zeros(1,numel(l_postrade));
    for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==2
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
                end
            elseif(l_closeprice(l_postrade(l_posid)+1)<l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)+1)<l_lowprice(l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==1
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=-1;
                    l_cnt=l_cnt+1;
                end
            end
        else %������λ�øպ�Ϊ����ʱ
            if(l_closeprice(l_postrade(l_posid)+1)>l_closeprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)-1)<l_highprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)+1)>l_highprice(l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==2
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
                end
            elseif(l_closeprice(l_postrade(l_posid)+1)<l_closeprice(l_postrade(l_posid))...
                    && l_closeprice(l_postrade(l_posid)-1)>l_lowprice(l_postrade(l_posid)-1)...
                    && l_closeprice(l_postrade(l_posid)+1)<l_lowprice(l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==1
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=-1;
                    l_cnt=l_cnt+1;
                end
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
            if(l_closeprice(l_realtradeday(l_tradeid)+1)>l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)>l_highprice(l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            elseif(l_closeprice(l_realtradeday(l_tradeid)+1)<l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)<l_lowprice(l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
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
            if(l_closeprice(l_realtradeday(l_tradeid)+1)>l_closeprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)-1)<l_highprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)>l_highprice(l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
            elseif(l_closeprice(l_realtradeday(l_tradeid)+1)<l_closeprice(l_realtradeday(l_tradeid))...
                    && l_closeprice(l_realtradeday(l_tradeid)-1)>l_lowprice(l_realtradeday(l_tradeid)-1)...
                    && l_closeprice(l_realtradeday(l_tradeid)+1)<l_lowprice(l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
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
    %======================================================================
    % ����dailyinfo��Ϣ
    outputdata.dailyinfo.date=inputdata.commodity.dailyinfo.date;
    outputdata.dailyinfo.trend=inputdata.commodity.dailyinfo.trend; % ���޸�
end 
 

%==========================================================================
%���������Ľ������ں����Ʒ���
% outputdata.dailyinfo.date=inputdata.commodity.serialmkdata.date;
% for i = 1:numel(outputdata.dailyinfo.date)
%     DateID=find(ismember(outputdata.record.opdate,outputdata.dailyinfo.date(i))==1);
%     if ~isempty(DateID)
%         outputdata.dailyinfo.trend(i)=outputdata.record.direction(DateID);
%     else
%         outputdata.dailyinfo.trend(i)=0;
%     end
% end
% outputdata.dailyinfo.trend=outputdata.dailyinfo.trend';



