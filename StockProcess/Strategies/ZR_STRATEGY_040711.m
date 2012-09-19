function outputdata=ZR_STRATEGY_040711(inputdata)
% ����ָ�곬����
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
%�����Will%R����
outReal=TA_WILLR(inputdata.commodity.serialmkdata.hp,inputdata.commodity.serialmkdata.lp,inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.period);
l_price(1,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*80;
l_price(2,:)=ones(size(inputdata.commodity.serialmkdata.cp)).*20;
l_price(3,:)=-outReal;
%==========================================================================
% figure('Name',strcat('040707',cell2mat(inputdata.commodity.name)));
% plot(l_price(1,:),'-b');
% hold on;
% plot(l_price(2,:),'-g');
% hold on;
% plot(l_price(3,:),'-r*');
% axis([1 numel(inputdata.commodity.serialmkdata.cp) -170 170]);
% legend('80H','20L','D',2);
% hold off;
%==========================================================================
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',l_price(3,:)','Sheet1','F');
% % xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',l_price(2,:)','Sheet1','I');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','A');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','B');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','C');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','D');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','E');
% % xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',inputdata.commodity.serialmkdata.hp,'Sheet1','F');
% % xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',inputdata.commodity.serialmkdata.lp,'Sheet1','G');
% % %xlswrite('D:\zx\STM-MATLAB-0807\StrategyProcess\Strategies\TestResults\040711\TestResults_SERIAL',l_price(1,:)','Sheet1','G');
%==========================================================================
%�����Ϊԭ��Ѱ�ҽ���㣬����Ѱ�ҵ�����ŵ��������PositionTrade��
l_diffprice1=l_price(2,:)-l_price(3,:);
l_signprice1=l_diffprice1(2:numel(l_diffprice1)).*l_diffprice1(1:numel(l_diffprice1)-1);
l_pos1=find(l_signprice1<0);%����С��20�ĵ��λ��
l_position1=find(l_diffprice1==0);
l_posinter1=[l_pos1,l_position1];
l_diffprice2=l_price(3,:)-l_price(1,:);
l_signprice2=l_diffprice2(2:numel(l_diffprice2)).*l_diffprice2(1:numel(l_diffprice2)-1);
l_pos2=find(l_signprice2<0);%�������80�ĵ��λ��
l_position2=find(l_diffprice2==0);
l_posinter2=[l_pos2,l_position2];
% l_signprice=[l_signprice1,l_signprice2];
% l_signprice=sort(l_signprice);
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
%     l_tradeday(1)=l_postrade(1);
    l_cnt=2;%��������
for i=1:numel(l_postrade)
    l_a1=find(l_posinter1==l_postrade(i));
    l_a2=find(l_posinter2==l_postrade(i));
  if l_a1~=0
     if(l_signprice1(l_postrade(i))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if(l_price(3,l_postrade(i)+1)<l_price(3,l_postrade(i)) && l_price(3,l_postrade(i)+1)<l_price(2,l_postrade(i)+1)) %����ͻ��20�������ж�
                    l_tradeday(1)=l_postrade(i);
                    break
            end
     else 
        if(l_price(3,l_postrade(i)+1)<l_price(3,l_postrade(i)-1) && l_price(3,l_postrade(i)+1)<l_price(2,l_postrade(i)+1)) %����ͻ��20�������ж�
         l_tradeday(1)=l_postrade(i);
          break
        end
     end
  else if l_a2~=0
           if(l_price(3,l_postrade(i))<l_price(3,l_postrade(i)+1)&&l_price(1,l_postrade(i)+1)<l_price(3,l_postrade(i)+1))%����ͻ��80�������ж�
                        l_tradeday(1)=l_postrade(i);
                        break
           end
      else
          if(l_price(3,l_postrade(i))<l_price(3,l_postrade(i)+1)&&l_price(1,l_postrade(i)+1)<l_price(3,l_postrade(i)+1))%����ͻ��80�������ж�
           l_tradeday(1)=l_postrade(i);
          break
           end
      end
  end
end
l_pos1=find(l_postrade==l_tradeday(1));
    for l_posid=(l_pos1+1):numel(l_postrade)
    l_a1=find(l_posinter1==l_postrade(l_posid));
    l_a2=find(l_posinter2==l_postrade(l_posid));
    if l_a1~=0
        if(l_signprice1(l_postrade(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if(l_price(3,l_postrade(l_posid)+1)<l_price(3,l_postrade(l_posid)) && l_price(3,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_cnt-1))<l_price(3,l_tradeday(l_cnt-1)+1)&&l_price(1,l_tradeday(l_cnt-1)+1)<l_price(3,l_tradeday(l_cnt-1)+1)) %����ͻ�Ƶ������ж�
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_cnt=l_cnt+1;
            else
                l_tradeday(l_cnt)=l_tradeday(l_cnt-1);
                l_cnt=l_cnt+1;
            end
        else
            if(l_price(3,l_postrade(l_posid)+1)<l_price(3,l_postrade(l_posid)-1) && l_price(3,l_postrade(l_posid)+1)<l_price(2,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_cnt-1))<l_price(3,l_tradeday(l_cnt-1)+1)&&l_price(1,l_tradeday(l_cnt-1)+1)<l_price(3,l_tradeday(l_cnt-1)+1)) %����ͻ�Ƶ������ж�
                    l_tradeday(l_cnt)=l_postrade(l_posid);
                    l_cnt=l_cnt+1;
            else
                l_tradeday(l_cnt)=l_tradeday(l_cnt-1);
                l_cnt=l_cnt+1;
            end
        end
    elseif l_a2~=0
            if(l_signprice2(l_postrade(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
           if(l_price(3,l_postrade(l_posid))<l_price(3,l_postrade(l_posid)+1)&&l_price(1,l_postrade(l_posid)+1)<l_price(3,l_postrade(l_posid)+1)&&...
                        l_price(3,l_tradeday(l_cnt-1)+1)<l_price(3,l_tradeday(l_cnt-1)) && l_price(2,l_tradeday(l_cnt-1)+1)>l_price(3,l_tradeday(l_cnt-1)+1))%����ͻ�Ƶ������ж�
                        l_tradeday(l_cnt)=l_postrade(l_posid);
                        l_cnt=l_cnt+1;
           else
                l_tradeday(l_cnt)=l_tradeday(l_cnt-1);
                l_cnt=l_cnt+1;
           end
            else
            if(l_price(3,l_postrade(l_posid)+1)>l_price(3,l_postrade(l_posid)-1) && l_price(3,l_postrade(l_posid)+1)>l_price(1,l_postrade(l_posid)+1))&&...
                    (l_price(3,l_tradeday(l_cnt-1))>l_price(3,l_tradeday(l_cnt-1)+1)&&l_price(2,l_tradeday(l_cnt-1)+1)>l_price(3,l_tradeday(l_cnt-1)+1)) %����ͻ�Ƶ������ж�
                l_tradeday(l_cnt)=l_postrade(l_posid);
                l_cnt=l_cnt+1;
            else
                l_tradeday(l_cnt)=l_tradeday(l_cnt-1);
                l_cnt=l_cnt+1;
            end
        end   
    end
    end
    l_realtradeday=unique(l_tradeday);
    %==========================================================================
    %����record�е�opdateprice,direction
    for l_tradeid=1:numel(l_realtradeday)
    l_a1=find(l_posinter1==l_realtradeday(l_tradeid));
    l_a2=find(l_posinter2==l_realtradeday(l_tradeid));
    if l_a1~=0
        if(l_signprice1(l_realtradeday(l_tradeid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
            if(l_price(3,l_realtradeday(l_tradeid)+1)<l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
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
        else
              if(l_price(3,l_realtradeday(l_tradeid)+1)<l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)<l_price(2,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=1;
              end
        end
    elseif l_a2~=0
         if(l_signprice2(l_realtradeday(l_tradeid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
            if (l_price(3,l_realtradeday(l_tradeid))<l_price(3,l_realtradeday(l_tradeid)+1)&&l_price(1,l_realtradeday(l_tradeid)+1)<l_price(3,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
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
            if(l_price(3,l_realtradeday(l_tradeid)+1)>l_price(3,l_realtradeday(l_tradeid)) && l_price(3,l_realtradeday(l_tradeid)+1)>l_price(1,l_realtradeday(l_tradeid)+1))%����ͻ�Ƶ������ж�
                outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)+1);
                outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid)+1)+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid)+1);
                outputdata.record.direction(l_tradeid)=-1;
            end
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
else                %������Ϊ�β��ԣ�����������������
    % 1.���ݲ����㷨��ǰ��������ƣ����롱��ϵ����Ѱ�ҳ���������յĵ�
    % 2.���ݲ����㷨������Ѱ�ҿ���ƽ�ֵĵ�
    l_opcnt=1;%��������
    l_cpcnt=1;
    l_direction1=zeros(1,numel(l_posinter1));
    l_optradeday1=zeros(1,numel(l_posinter1));
    l_direction2=zeros(1,numel(l_posinter2));
    l_optradeday2=zeros(1,numel(l_posinter2));
    l_cptradeday1=zeros(1,numel(l_posinter1));
    l_cptradeday2=zeros(1,numel(l_posinter2));
    for l_posid=1:numel(l_posinter1)
        if(l_signprice1(l_posinter1(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if((l_price(3,l_posinter1(l_posid)+1)<l_price(3,l_posinter1(l_posid))...
                    &&l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1))||(l_price(3,l_posinter1(l_posid)+1)>l_price(3,l_posinter1(l_posid))...
                    &&l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1)))%����ͻ��20
                if (l_price(3,l_posinter1(l_posid)+1)<l_price(3,l_posinter1(l_posid))...
                    &&l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1))
                if (inputdata.commodity.dailyinfo.trend(l_posinter1(l_posid)+1)==2)
                    l_optradeday1(l_opcnt)=l_posinter1(l_posid);
                    l_direction1(l_opcnt)=1;
                    l_opcnt=l_opcnt+1;
                end
                end
                l_cptradeday1(l_cpcnt)=l_posinter1(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
          else %������λ�øպ�Ϊ����ʱ
            if((l_price(3,l_posinter1(l_posid)+1)<l_price(3,l_posinter1(l_posid)-1)...
                    && l_price(3,l_posinter1(l_posid)-1)>l_price(2,l_posinter1(l_posid)-1) && l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1))||(l_price(3,l_posinter1(l_posid)+1)>l_price(3,l_posinter1(l_posid)-1)...
                    && l_price(3,l_posinter1(l_posid)-1)<l_price(2,l_posinter1(l_posid)-1)&&l_price(3,l_posinter1(l_posid)+1)>l_price(2,l_posinter1(l_posid)+1))) %����ͻ�Ƶ������ж�
                if (l_price(3,l_posinter1(l_posid)+1)<l_price(3,l_posinter1(l_posid)-1)...
                    && l_price(3,l_posinter1(l_posid)-1)>l_price(2,l_posinter1(l_posid)-1) && l_price(3,l_posinter1(l_posid)+1)<l_price(2,l_posinter1(l_posid)+1))
                if (inputdata.commodity.dailyinfo.trend(l_posinter1(l_posid)+1)==2)
                    l_optradeday1(l_opcnt)=l_posinter1(l_posid);
                    l_direction1(l_opcnt)=1;
                    l_opcnt=l_opcnt+1;
                end
                end
                l_cptradeday1(l_cpcnt)=l_posinter1(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
        end
    end
    l_opcnt=1;%��������
    l_cpcnt=1;
    for l_posid=1:numel(l_posinter2)
        if(l_signprice2(l_posinter2(l_posid))~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ����
            if((l_price(3,l_posinter2(l_posid))<l_price(3,l_posinter2(l_posid)+1)...
                    &&l_price(1,l_posinter2(l_posid)+1)<l_price(3,l_posinter2(l_posid)+1))||(l_price(3,l_posinter2(l_posid))>l_price(3,l_posinter2(l_posid)+1)...
                    &&l_price(1,l_posinter2(l_posid)+1)>l_price(3,l_posinter2(l_posid)+1)))%����ͻ��80
                if (l_price(3,l_posinter2(l_posid))<l_price(3,l_posinter2(l_posid)+1)...
                    &&l_price(1,l_posinter2(l_posid)+1)<l_price(3,l_posinter2(l_posid)+1))
                if (inputdata.commodity.dailyinfo.trend(l_posinter2(l_posid)+1)==1)
                    l_optradeday2(l_opcnt)=l_posinter2(l_posid);
                    l_direction2(l_opcnt)=-1;
                    l_opcnt=l_opcnt+1;
                end
                end
                l_cptradeday2(l_cpcnt)=l_posinter2(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
        else %������պ�Ϊ����ʱ
            if((l_price(3,l_posinter2(l_posid)-1)<l_price(3,l_posinter2(l_posid)+1)...
                    && l_price(1,l_posinter2(l_posid)-1)>l_price(3,l_posinter2(l_posid)-1) && l_price(1,l_posinter2(l_posid)+1)<l_price(3,l_posinter2(l_posid)+1))||(l_price(3,l_posinter2(l_posid)-1)>l_price(3,l_posinter2(l_posid)+1)...
                    && l_price(1,l_posinter2(l_posid)-1)<l_price(3,l_posinter2(l_posid)-1)&& l_price(1,l_posinter2(l_posid)+1)>l_price(3,l_posinter2(l_posid)+1)))%����ͻ�Ƶ������ж�
                if (l_price(3,l_posinter2(l_posid)-1)<l_price(3,l_posinter2(l_posid)+1)...
                    && l_price(1,l_posinter2(l_posid)-1)>l_price(3,l_posinter2(l_posid)-1) && l_price(1,l_posinter2(l_posid)+1)<l_price(3,l_posinter2(l_posid)+1))
                if (inputdata.commodity.dailyinfo.trend(l_posinter2(l_posid)+1)==1)
                    l_optradeday2(l_opcnt)=l_posinter2(l_posid);
                    l_direction2(l_opcnt)=-1;
                    l_opcnt=l_opcnt+1;
                end
                end
                l_cptradeday2(l_cpcnt)=l_posinter2(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
        end   
    end
    l_optradeday1(l_optradeday1==0)=[];
    l_cptradeday1(l_cptradeday1==0)=[];
    l_optradeday2(l_optradeday2==0)=[];
    l_cptradeday2(l_cptradeday2==0)=[];
    l_optradeday=[l_optradeday1,l_optradeday2];
    l_cptradeday=[l_cptradeday1,l_cptradeday2];
    if isempty(l_optradeday)
        return;
    end
    l_oprealtradeday=unique(l_optradeday);
    l_cprealtradeday=unique(l_cptradeday);
    %==========================================================================
    %����record�е�opdateprice,direction
    for l_tradeid=1:numel(l_oprealtradeday)
        a=find(l_optradeday1==l_oprealtradeday(l_tradeid));
        b=find(l_optradeday2==l_oprealtradeday(l_tradeid));
        if(a~=0) %�жϴ˽���λ���Ƿ�պ�Ϊ������
            if(l_price(3,l_oprealtradeday(l_tradeid)+1)<l_price(3,l_oprealtradeday(l_tradeid))...
                    && l_price(3,l_oprealtradeday(l_tradeid)+1)<l_price(2,l_oprealtradeday(l_tradeid)+1)) %����ͻ��20
                if(l_oprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            end
        elseif (b~=0)
            if(l_price(3,l_oprealtradeday(l_tradeid))<l_price(3,l_oprealtradeday(l_tradeid)+1)...
                    &&l_price(1,l_oprealtradeday(l_tradeid)+1)<l_price(3,l_oprealtradeday(l_tradeid)+1)) %����ͻ�Ƶ������ж�
                    if(l_oprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                        outputdata.orderlist.direction=-1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
                    else 
                        outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+2); %��������׼�¼
                        outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+2);
                        outputdata.record.direction(l_tradeid)=-1;
                    end
            end
        end   
        outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
    end
    %==========================================================================
    % ���ݲ����㷨������Ѱ�ҿ���ƽ�ֵĵ�
    l_tempcpdate=cell(1,numel(l_cprealtradeday));
    l_tempcpdate=inputdata.commodity.serialmkdata.date(l_cprealtradeday+2);
    %==========================================================================
     % ���ݲ����㷨��ǰ��������ƣ����򡱹�ϵ����Ѱ�ҳ�ƽ�ֵ�
    l_difftrend=inputdata.commodity.dailyinfo.trend(2:end)-inputdata.commodity.dailyinfo.trend(1:end-1);
    l_postrend=find(l_difftrend~=0);
    l_trendchangeday=unique(l_postrend);    % ���Ʊ仯ǰ�����һ��
    for i=1:numel(l_trendchangeday)
        if (l_trendchangeday(i)+2<=numel(inputdata.commodity.dailyinfo.date))
            l_trendchangedate(i)=inputdata.commodity.dailyinfo.date(l_trendchangeday(i)+1);
        else
            l_trendchangedate(i)=inputdata.commodity.dailyinfo.date(end);
        end
    end
%     l_strategycpdate=outputdata.record.opdate(2:end); % ���ڸò��ԣ�����ʱ��ƽ�� 
    l_strategycpdate=l_tempcpdate;
    l_cpdate=unique([l_trendchangedate,l_strategycpdate']);
    
    l_opdatenum=datenum(outputdata.record.opdate,'yyyy-mm-dd');
    l_cpdatenum=datenum(l_cpdate,'yyyy-mm-dd');
    l_cnt=1;
    for l_opid = 1:numel(l_opdatenum)-1
        l_firstcpindex=find(l_cpdatenum>l_opdatenum(l_opid),1);
        if ~isempty(l_firstcpindex)
            if datenum(l_cpdate(l_firstcpindex),'yyyy-mm-dd')<=l_opdatenum(l_opid+1)
                outputdata.record.cpdate(l_cnt)=l_cpdate(l_firstcpindex);
                l_cnt=l_cnt+1;
            end
        end
    end
    outputdata.record.cpdate(numel(l_opdatenum))=inputdata.commodity.serialmkdata.date(end);
    l_firstcpindex=find(l_cpdatenum>l_opdatenum(end));
    if ~isempty(l_firstcpindex)
        if datenum(l_cpdate(l_firstcpindex),'yyyy-mm-dd')<l_opdatenum(end)
            outputdata.record.cpdate(end)=l_cpdate(l_firstcpindex);
        end
    end
    outputdata.record.cpdate=unique(outputdata.record.cpdate);
    %==========================================================================
    % ȥ��������������յĽ��׼�¼
    l_deleteidx=[];
    for l_id = 2:numel(outputdata.record.opdate)-1
        if (outputdata.record.direction(l_id)==outputdata.record.direction(l_id-1))
            if (outputdata.record.cpdate{l_id-1}==outputdata.record.opdate{l_id})
                l_deleteidx=cat(2,l_deleteidx,l_id);
            end
        end
    end
    outputdata.record.opdate(l_deleteidx)=[];
    outputdata.record.opdateprice(l_deleteidx)=[];
    outputdata.record.cpdate(l_deleteidx)=[];
    outputdata.record.direction(l_deleteidx)=[];
    outputdata.record.ctname(l_deleteidx)=[];
    %======================================================================
    % ����ƽ�ּ۸���Ƿ�ʵ��ƽ����Ϣ
    if numel(outputdata.record.cpdate)>=2
        for l_cpid = 1:numel(outputdata.record.cpdate)-1
            l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.cpdate(l_cpid)),1);
            outputdata.record.cpdateprice(l_cpid)=inputdata.commodity.serialmkdata.op(l_dateid)+inputdata.commodity.serialmkdata.gap(l_dateid);
        end
        outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice));
        if outputdata.record.cpdate{end}==inputdata.commodity.serialmkdata.date{end}
            outputdata.record.cpdateprice(end+1)=inputdata.commodity.serialmkdata.op(end);
            outputdata.record.isclosepos(end)=0;
        else
            l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.cpdate(end)),1);
            outputdata.record.cpdateprice(end+1)=inputdata.commodity.serialmkdata.op(l_dateid)+inputdata.commodity.serialmkdata.gap(l_dateid);
        end
    else
        outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
        outputdata.record.isclosepos=0;
    end

    %======================================================================
    % ����dailyinfo��Ϣ
    outputdata.dailyinfo.date=inputdata.commodity.dailyinfo.date;
    outputdata.dailyinfo.trend=inputdata.commodity.dailyinfo.trend; % ���޸�
end