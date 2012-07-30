function outputdata=ZR_STRATEGY_SS040708(inputdata)
% RSI����
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
%�����KDJ����
outReal=TA_RSI(inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.D);
l_price(1,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*80;
l_price(2,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*20;
l_price(3,:)=outReal;%����ƽ������������������Price��
l_price(l_price==0)=inf;
%==========================================================================
%�����Ϊԭ��Ѱ�ҽ���㣬����Ѱ�ҵ�����ŵ��������PositionTrade��
l_diffprice1=l_price(2,:)-l_price(3,:);
l_signprice1=l_diffprice1(2:numel(l_diffprice1)).*l_diffprice1(1:numel(l_diffprice1)-1);
l_pos1=find(l_signprice1<0);%����С��20�ĵ��λ��
l_posinter1=find(l_diffprice1==0);

l_diffprice2=l_price(3,:)-l_price(1,:);
l_signprice2=l_diffprice2(2:numel(l_diffprice2)).*l_diffprice2(1:numel(l_diffprice2)-1);
l_pos2=find(l_signprice2<0);%�������80�ĵ��λ��
l_posinter2=find(l_diffprice2==0);

l_signprice=[l_signprice1,l_signprice2];
l_signprice=sort(l_signprice);
l_pos=[l_pos1,l_pos2];
l_pos=sort(l_pos);
l_pos(1:1)=[];
l_posinter=[l_posinter1,l_posinter2];
l_posinter=sort(l_posinter);

l_postrade=[l_pos,l_posinter];
l_postrade=unique(sort(l_postrade));                                             
%==========================================================================         

if isequal(zeros(numel(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend) %�ж��Ƿ���Ϊ�����Ի�һ����
    %�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
    l_cnt=2;%��������
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
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_cnt=l_cnt+1;
            elseif(l_price(3,l_postrade(l_posid))>l_price(3,l_postrade(l_posid)+1)&&l_price(2,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)+1))&&...
                        (l_price(3,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)) && l_price(3,l_tradeday(l_posid-1)+1)>l_price(1,l_tradeday(l_posid-1)+1))%����ͻ�Ƶ������ж�
                        l_tradeday(l_cnt)=l_postrade(l_posid);
                        l_cnt=l_cnt+1;
            else
                l_tradeday(l_cnt)=l_tradeday(l_posid-1);
                l_cnt=l_cnt+1;
            end
        else %������λ�øպ�Ϊ����ʱ
            if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)) && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_posid-1))>l_price(3,l_tradeday(l_posid-1)+1)&&l_price(2,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_cnt=l_cnt+1;
            elseif (l_price(3,l_postrade(l_posid))>l_price(3,l_postrade(l_posid)+1)&&l_price(2,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)+1))&&...
                        (l_price(3,l_tradeday(l_posid-1)+1)>l_price(3,l_tradeday(l_posid-1)) && l_price(3,l_tradeday(l_posid-1)+1)>l_price(1,l_tradeday(l_posid-1)+1))%����ͻ�Ƶ������ж�
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_cnt=l_cnt+1;
            else
                l_tradeday(l_cnt)=l_tradeday(l_posid-1);
                l_cnt=l_cnt+1;
            end
        end   
    end
    l_realtradeday=unique(l_tradeday);
    %==========================================================================
    %����record�е�opdateprice,direction
    for l_tradeid=1:numel(l_realtradeday)
        if(l_signprice(l_realtradeday(l_tradeid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
            if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=-1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=-1;
                end
            elseif (l_price(3,l_realtradeday(l_tradeid))>l_price(3,l_realtradeday(l_tradeid)+1)&&l_price(2,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
                    if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                        outputdata.orderlist.direction=1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
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
            elseif (l_price(3,l_realtradeday(l_tradeid))>l_price(3,l_realtradeday(l_tradeid)+1)&&l_price(2,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
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
    %======================================================================
    %����dailyinfo��Ϣ
    outputdata.dailyinfo.date=inputdata.commodity.serialmkdata.date;
    outputdata.dailyinfo.trend=-Inf*ones(1,numel(inputdata.commodity.serialmkdata.date));
    for i = 1:numel(outputdata.record.direction)
        if outputdata.record.direction(i)==1
            outputdata.dailyinfo.trend(l_realtradeday(i))=2;    %����
        elseif outputdata.record.direction(i)==-1
            outputdata.dailyinfo.trend(l_realtradeday(i))=1;    %����
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
else                %������Ϊ�β��ԣ�����������������
    %�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
    l_cnt=1;%��������
    l_tradeday=zeros(1,numel(l_postrade));
    l_direction=zeros(1,numel(l_postrade));
    for l_posid=1:numel(l_postrade)
        if(l_signprice(l_postrade(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid))...
                    && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==2
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
                end
            elseif(l_price(3,l_postrade(l_posid))>l_price(3,l_postrade(l_posid)+1)...
                    &&l_price(2,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==1
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=-1;
                    l_cnt=l_cnt+1;
                end
            end
        else %������λ�øպ�Ϊ����ʱ
            if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)-1)...
                    && l_price(3,l_postrade(l_posid)-1)<l_price(1,l_postrade(l_posid)-1) && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid)-1)==2
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_direction(l_cnt)=1;
                    l_cnt=l_cnt+1;
                end
            elseif(l_price(3,l_postrade(l_posid)-1)>l_price(3,l_postrade(l_posid)+1)...
                    && l_price(2,l_postrade(l_posid)-1)<l_price(3,l_postrade(l_posid)-1) && l_price(2,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)+1)) %����ͻ�Ƶ������ж�
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
            if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid))...
                    && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            elseif(l_price(3,l_realtradeday(l_tradeid))>l_price(3,l_realtradeday(l_tradeid)+1)...
                    &&l_price(2,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
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
            if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)-1)...
                    && l_price(3,l_realtradeday(l_tradeid)-1)<l_price(1,l_realtradeday(l_tradeid)-1) && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
                outputdata.record.direction(l_tradeid)=1;
            elseif(l_price(3,l_realtradeday(l_tradeid)-1)>l_price(3,l_realtradeday(l_tradeid)+1)...
                    && l_price(2,l_realtradeday(l_tradeid)-1)<l_price(3,l_realtradeday(l_tradeid)-1) && l_price(2,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+2); %��������׼�¼
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+2);
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The following is zhaoxia's code. 
    % ��������Ϊ����ִ�У��ڼ��㽻�����ڵ�ʱ����Ҫ����֮ǰ�Ĳ����������trend���������ж�
    % ����ʱ��Ӧ�ü��ڽ�tradeday��������������յ�����ɾ������Ϊɾ���п��ܷ����������ڵ���©
    % ���ڴˣ�ע�͵�
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵ĵ�
%     l_cnt=2;%��������
%     l_tradeday=[];
%      if(l_signprice(l_postrade(1))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
%             if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %����ͻ�Ƶ������ж�
%                     l_tradeday(1)=l_postrade(1);
%             else if(l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%����ͻ�Ƶ������ж�
%                         l_tradeday(1)=l_postrade(1);
%                 end
%             end
%      else %������λ�øպ�Ϊ����ʱ
%             if(l_price(3,l_postrade(1)+1)>l_price(3,l_postrade(1)) && l_price(3,l_postrade(1)+1)>l_price(1,l_postrade(1)+1)) %����ͻ�Ƶ������ж�
%                 l_tradeday(1)=l_postrade(1);
%             else if (l_price(3,l_postrade(1))>l_price(3,l_postrade(1)+1)&&l_price(2,l_postrade(1)+1)>l_price(3,l_postrade(1)+1))%����ͻ�Ƶ������ж�
%                     l_tradeday(1)=l_postrade(1);
%                 end
%             end
%      end
%     for i=2:numel(l_postrade)
%         if(l_signprice(l_postrade(i))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
%             if(l_price(3,l_postrade(i)+1)>l_price(3,l_postrade(i)) && l_price(3,l_postrade(i)+1)>l_price(1,l_postrade(i)+1))&&...
%                     (l_price(3,l_tradeday(i-1))>l_price(3,l_tradeday(i-1)+1)&&l_price(2,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)+1)) %����ͻ�Ƶ������ж�
%                     l_tradeday(l_cnt)=l_postrade(i);
%                     l_cnt=l_cnt+1;
%             else if(l_price(3,l_postrade(i))>l_price(3,l_postrade(i)+1)&&l_price(2,l_postrade(i)+1)>l_price(3,l_postrade(i)+1))&&...
%                         (l_price(3,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)) && l_price(3,l_tradeday(i-1)+1)>l_price(1,l_tradeday(i-1)+1))%����ͻ�Ƶ������ж�
%                         l_tradeday(l_cnt)=l_postrade(i);
%                         l_cnt=l_cnt+1;
%                 else
%                     l_tradeday(l_cnt)=l_tradeday(i-1);
%                     l_cnt=l_cnt+1;
%                 end
%             end
%         else %������λ�øպ�Ϊ����ʱ
%             if(l_price(3,l_postrade(i)+1)>l_price(3,l_postrade(i)) && l_price(3,l_postrade(i)+1)>l_price(1,l_postrade(i)+1))&&...
%                     (l_price(3,l_tradeday(i-1))>l_price(3,l_tradeday(i-1)+1)&&l_price(2,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)+1)) %����ͻ�Ƶ������ж�
%                 l_tradeday(l_cnt)=l_postrade(i);
%                 l_cnt=l_cnt+1;
%             else if (l_price(3,l_postrade(i))>l_price(3,l_postrade(i)+1)&&l_price(2,l_postrade(i)+1)>l_price(3,l_postrade(i)+1))&&...
%                         (l_price(3,l_tradeday(i-1)+1)>l_price(3,l_tradeday(i-1)) && l_price(3,l_tradeday(i-1)+1)>l_price(1,l_tradeday(i-1)+1))%����ͻ�Ƶ������ж�
%                     l_tradeday(l_cnt)=l_postrade(i);
%                     l_cnt=l_cnt+1;
%                 else
%                     l_tradeday(l_cnt)=l_tradeday(i-1);
%                     l_cnt=l_cnt+1;
%                 end
%             end
%         end   
%     end
%     %==========================================================================
%     %�ϲ��������ں�ǿ��ƽ������,��ʱ��Щʱ������н��׵ķ���
%     % l_tradeday=unique(l_tradeday);
%     % RealTradeDayBuff=[l_tradeday,ForceTrade'];
%     % RealTradeDayBuff=sort(RealTradeDayBuff);
%     % l_realtradeday=unique(RealTradeDayBuff);
%     l_realtradeday=unique(l_tradeday);
%     %==========================================================================
%     %����record�е�opdateprice,direction
%     for i=1:numel(l_realtradeday)
%         if(l_signprice(l_realtradeday(i))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
%             if(l_price(3,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)) && l_price(3,l_realtradeday(i)+1)>l_price(1,l_realtradeday(i)+1))%����ͻ�Ƶ������ж�
%                 if(l_realtradeday(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
%                     outputdata.orderlist.direction=-1;
%                     outputdata.orderlist.price=0;
%                     outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
%                 else
%                     outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+2); %��������׼�¼
%                     outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+2);
%                     outputdata.record.direction(i)=-1;
%                 end
%             else if (l_price(3,l_realtradeday(i))>l_price(3,l_realtradeday(i)+1)&&l_price(2,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)+1))%����ͻ�Ƶ������ж�
%                     if(l_realtradeday(i)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
%                         outputdata.orderlist.direction=1;
%                         outputdata.orderlist.price=0;
%                         outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
%                     else 
%                         outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+2); %��������׼�¼
%                         outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+2)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+2);
%                         outputdata.record.direction(i)=1;
%                     end
%                 end
%             end
%         else %������λ�øպ�Ϊ����ʱ
%             if(l_price(3,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)) && l_price(3,l_realtradeday(i)+1)>l_price(1,l_realtradeday(i)+1))%����ͻ�Ƶ������ж�
%                 outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+1);
%                 outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+1);
%                 outputdata.record.direction(i)=-1;
%             else if (l_price(3,l_realtradeday(i))>l_price(3,l_realtradeday(i)+1)&&l_price(2,l_realtradeday(i)+1)>l_price(3,l_realtradeday(i)+1))%����ͻ�Ƶ������ж�
%                     outputdata.record.opdate(i)=inputdata.commodity.serialmkdata.date(l_realtradeday(i)+1);
%                     outputdata.record.opdateprice(i)=inputdata.commodity.serialmkdata.op(l_realtradeday(i)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(i)+1);
%                     outputdata.record.direction(i)=1;
%                 end
%             end
%         end   
%         outputdata.record.ctname(i)=inputdata.commodity.serialmkdata.ctname(l_realtradeday(i)+1);
%     end
% 
%     %==========================================================================
%     %����outputdata.record,����ƽ�����ں�ƽ�ּ۸�
%     if(numel(outputdata.record.opdate)>=2)
%         outputdata.record.cpdate=outputdata.record.opdate(2:end);
%         outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
%         outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
%         outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
%         outputdata.record.cpdate(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.date(end); 
%         outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.op(end);
%         %{
%         if(inputdata.contract.info.daystolasttradedate<=0) 
%             outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%         end
%         %}
%     elseif(numel(outputdata.record.opdate)>=1)
%         outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
%         outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
%         outputdata.record.isclosepos=0;
%         %{
%         if(inputdata.contract.info.daystolasttradedate<=0) 
%             outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
%         end
%         %}
%     end



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



