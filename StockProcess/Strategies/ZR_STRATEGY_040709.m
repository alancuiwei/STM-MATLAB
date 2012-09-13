function outputdata=ZR_STRATEGY_040709(inputdata)
% ���ƶ�ƽ���߲���
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
switch (inputdata.strategyparams.selection_price)
    case 1%����ѡ��Ϊ1ʱ���ÿ��̼�
        l_price(1,:)=inputdata.commodity.serialmkdata.op;
    case 2%����ѡ��Ϊ2ʱ�������̼�
        l_price(1,:)=inputdata.commodity.serialmkdata.cp;
    case 3%����ѡ��Ϊ3ʱ������߼�
        l_price(1,:)=inputdata.commodity.serialmkdata.hp;
    case 4%����ѡ��Ϊ4ʱ������ͼ�
        l_price(1,:)=inputdata.commodity.serialmkdata.lp;
end
if (inputdata.strategyparams.selection==1)%����ѡ��1ʱΪ���ƶ�ƽ��
%���60�����
l_day60=zeros(1,inputdata.strategyparams.ma)+1;%����ƽ����������                                                                                                                                                                                                                         
l_mean60buff=conv(inputdata.commodity.serialmkdata.cp,l_day60)/inputdata.strategyparams.ma;%������
l_price(2,:)=l_mean60buff(1:numel(inputdata.commodity.serialmkdata.cp));
else if (inputdata.strategyparams.selection==2)%����ѡ��2ʱΪ��Ȩƽ��
outReal=TA_WMA(inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.period);
l_price(2,:)=outReal;
    else if(inputdata.strategyparams.selection==3)%����ѡ��3ʱΪָ������ƽ��
outReal=TA_EMA(inputdata.commodity.serialmkdata.cp,inputdata.strategyparams.counter);
l_price(2,:)=outReal;
        end
    end
end
l_price(l_price==0)=Inf;
%==========================================================================
% figure('Name',strcat('040709',cell2mat(inputdata.commodity.name)));
% plot(l_price(1,:),'-r*');
% hold on;
% plot(l_price(2,:),'-b+');
% legend('Cp','MA60',2);
% hold off;
%==========================================================================
%�����Ϊԭ��Ѱ�ҽ���㣬����Ѱ�ҵ�����ŵ��������PositionTrade��
l_signprice=l_price(2,2:numel(l_price(1,:)))-l_price(2,1:numel(l_price(1,:))-1);
l_diffprice=l_price(1,:)-l_price(2,:);
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040709\TestResults_SERIAL',l_price(2,:)','Sheet1','H');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040709\TestResults_SERIAL',inputdata.commodity.serialmkdata.date,'Sheet1','A');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040709\TestResults_SERIAL',inputdata.commodity.serialmkdata.ctname,'Sheet1','B');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040709\TestResults_SERIAL',inputdata.commodity.serialmkdata.op,'Sheet1','C');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040709\TestResults_SERIAL',inputdata.commodity.serialmkdata.cp,'Sheet1','D');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040709\TestResults_SERIAL',inputdata.commodity.serialmkdata.gap,'Sheet1','E');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040709\TestResults_SERIAL',inputdata.commodity.serialmkdata.hp,'Sheet1','F');
% xlswrite('D:\zx\STM-MATLAB-0813\StrategyProcess\Strategies\TestResults\040709\TestResults_SERIAL',inputdata.commodity.serialmkdata.lp,'Sheet1','G');
%==========================================================================         

if isequal(zeros(numel(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend) %�ж��Ƿ���Ϊ�����Ի�һ����
    %�ڲ�����ǿ��ƽ�ֵ������Ѱ�ҳ���Ҫ���׵�����
    l_cnt=1;  %��������
    l_tradeday=zeros(1,numel(l_signprice));
    l_direction=zeros(1,numel(l_signprice));
    for l_posid=1:numel(l_signprice)
        if(l_signprice(l_posid)>0) %�жϾ����Ƿ�����
            if(l_diffprice(l_posid+1)>0) %���̼ۣ����̼ۣ���߼ۣ���ͼۣ��ھ�����
                l_tradeday(l_cnt)=l_posid;
                l_direction(l_cnt)=1;
                l_cnt=l_cnt+1;
            end
            elseif(l_signprice(l_posid)<0) %�жϾ����Ƿ��½�
                if(l_diffprice(l_posid+1)<0) %���̼ۣ����̼ۣ���߼ۣ���ͼۣ��ھ�����
                l_tradeday(l_cnt)=l_posid;
                l_direction(l_cnt)=-1;
                l_cnt=l_cnt+1;
                end  
        end
    end
    l_tradeday(l_tradeday==0)=[];
    l_direction(l_direction==0)=[];
    %�޳�������������յĽ�����
    if isempty(l_direction)
        return;
    end
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
        if(l_signprice(l_realtradeday(l_tradeid))>0) %�жϾ����Ƿ�����
            if(l_diffprice(l_realtradeday(l_tradeid)+1)>0) %�жϼ۸��Ƿ��ھ�������
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
            elseif(l_signprice(l_realtradeday(l_tradeid))<0) %�жϾ����Ƿ�����
                if(l_diffprice(l_realtradeday(l_tradeid)+1)<0) %�жϼ۸��Ƿ��ھ�������
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
    % 2.���ݲ����㷨����Ѱ�ҿ���ƽ�ֵĵ�
    l_opcnt=1;%��������
    l_cpcnt=1;
    l_direction=zeros(1,numel(l_signprice));
    l_optradeday=zeros(1,numel(l_signprice));
    l_cptradeday=zeros(1,numel(l_signprice));
    for l_posid=1:numel(l_signprice)
        if(l_signprice(l_posid)>0) %�жϾ����Ƿ�����
            if(l_diffprice(l_posid+1)>0) %���̼ۣ����̼ۣ���߼ۣ���ͼۣ��ھ�����
                if inputdata.commodity.dailyinfo.trend(l_posid)==2
                    l_optradeday(l_opcnt)=l_posid;
                    l_direction(l_opcnt)=1;
                    l_opcnt=l_opcnt+1;
                end
                l_cptradeday(l_cpcnt)=l_posid;
                l_cpcnt=l_cpcnt+1;
            end
            elseif(l_signprice(l_posid)<0) %�жϾ����Ƿ�����
                if(l_diffprice(l_posid+1)<0)%���̼ۣ����̼ۣ���߼ۣ���ͼۣ��ھ�����
                    if inputdata.commodity.dailyinfo.trend(l_posid)==1
                    l_optradeday(l_opcnt)=l_posid;
                    l_direction(l_opcnt)=-1;
                    l_opcnt=l_opcnt+1;
                    end
                    l_cptradeday(l_cpcnt)=l_posid;
                    l_cpcnt=l_cpcnt+1;
                end
        end   
    end
    l_optradeday(l_optradeday==0)=[];
    l_cptradeday(l_cptradeday==0)=[];
    if isempty(l_optradeday)
        return;
    end
%     l_direction(l_direction==0)=[];
%     %�޳�������������յĽ�����
%     if isempty(l_direction)
%         return;
%     end
%     l_directionkey=l_direction(1);
%     for l_id = 2:numel(l_tradeday)
%         if l_direction(l_id)==l_directionkey
%             l_tradeday(l_id)=-1;
%         else
%             l_directionkey=l_direction(l_id);
%         end
%     end
%     l_tradeday(l_tradeday==-1)=[];
    l_oprealtradeday=unique(l_optradeday);
    l_cprealtradeday=unique(l_cptradeday);
    %==========================================================================
    %����record�е�opdateprice,direction
%����record�е�opdateprice,direction
    for l_tradeid=1:numel(l_oprealtradeday)
        if(l_signprice(l_oprealtradeday(l_tradeid))>0) %�жϾ����Ƿ�����
            if(l_diffprice(l_oprealtradeday(l_tradeid)+1)>0) %�жϼ۸��Ƿ��ھ�������
                if(l_oprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(end);
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)+2); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid)+2)+inputdata.commodity.serialmkdata.gap(l_oprealtradeday(l_tradeid)+2);
                    outputdata.record.direction(l_tradeid)=1;
                end
            end
            elseif(l_signprice(l_oprealtradeday(l_tradeid))<0) %�жϾ����Ƿ�����
                if(l_diffprice(l_oprealtradeday(l_tradeid)+1)<0) %�жϼ۸��Ƿ��ھ�������
                    if(l_oprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                        outputdata.orderlist.direction=-1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(end);
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
    % ���ݲ����㷨����Ѱ�ҿ���ƽ�ֵĵ�
    l_tempcpdate=cell(1,numel(l_cprealtradeday));
    for l_tradeid=1:numel(l_cprealtradeday)
        if(l_signprice(l_cprealtradeday(l_tradeid))>0) %�жϾ����Ƿ�����
            if(l_diffprice(l_cprealtradeday(l_tradeid)+1)>0)%�жϼ۸��ھ�������
               if(l_cprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                  l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(end);
               else
                l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid)+2); %��������׼�¼
               end
            end
            elseif(l_signprice(l_cprealtradeday(l_tradeid))<0) %�жϾ����Ƿ�����
             if(l_diffprice(l_cprealtradeday(l_tradeid)+1)<0)%�жϼ۸��ھ�������
                if(l_cprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                   l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(end);
                else
                l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid)+2); %��������׼�¼
                end
             end
        end   
    end
    %==========================================================================
    % ���ݲ����㷨��ǰ��������ƣ����򡱹�ϵ����Ѱ�ҳ�ƽ�ֵ�
    l_difftrend=inputdata.commodity.dailyinfo.trend(2:end)-inputdata.commodity.dailyinfo.trend(1:end-1);
    l_postrend=find(l_difftrend~=0);
    l_trendchangeday=unique(l_postrend);    % ���Ʊ仯ǰ�����һ��
    for i=1:numel(l_trendchangeday)
        if (l_trendchangeday(i)+2<=numel(inputdata.commodity.dailyinfo.date))
            l_trendchangedate(i)=inputdata.commodity.dailyinfo.date(l_trendchangeday(i)+2);
        else
            l_trendchangedate(i)=inputdata.commodity.dailyinfo.date(end);
        end
    end
%     l_strategycpdate=outputdata.record.opdate(2:end); % ���ڸò��ԣ�����ʱ��ƽ��
    l_strategycpdate=l_tempcpdate;
    l_cpdate=unique([l_trendchangedate,l_strategycpdate]);
    
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
%     outputdata.record.cpdate=unique(outputdata.record.cpdate);
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
%         for l_cpid = 1:numel(outputdata.record.cpdate)-1
%             l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.opdate(l_cpid)),1);
%             l_ctname=inputdata.commodity.serialmkdata.ctname(l_dateid);
%             l_ctnameid=find(ismember(inputdata.contractname,l_ctname),1);
%             l_ctndateid=find(ismember(inputdata.contract(l_ctnameid).mkdata.date,outputdata.record.cpdate(l_cpid)),1);
%             outputdata.record.cpdateprice(l_cpid)=inputdata.contract(l_ctnameid).mkdata.op(l_ctndateid);
%         end
        outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice));
        if outputdata.record.cpdate{end}==inputdata.commodity.serialmkdata.date{end}
            outputdata.record.cpdateprice(end+1)=inputdata.commodity.serialmkdata.op(end);
            outputdata.record.isclosepos(end)=0;
        else
            l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.cpdate(end)),1);
            outputdata.record.cpdateprice(end+1)=inputdata.commodity.serialmkdata.op(l_dateid)+inputdata.commodity.serialmkdata.gap(l_dateid);
%             l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.opdate(end)),1);
%             l_ctname=inputdata.commodity.serialmkdata.ctname(l_dateid);
%             l_ctnameid=find(ismember(inputdata.contractname,l_ctname),1);
%             l_ctndateid=find(ismember(inputdata.contract(l_ctnameid).mkdata.date,outputdata.record.cpdate(end)),1);
%             outputdata.record.cpdateprice(end+1)=inputdata.contract(l_ctnameid).mkdata.op(l_ctndateid);
        end
    else
        outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.op(end)+inputdata.commodity.serialmkdata.gap(end);
        outputdata.record.isclosepos=0;
    end
%     for l_cpid = 1:numel(outputdata.record.cpdate)
%         l_dateid=find(ismember(inputdata.commodity.serialmkdata.date,outputdata.record.opdate(l_cpid)),1);
%         l_ctname=inputdata.commodity.serialmkdata.ctname(l_dateid);
%         l_ctnameid=find(ismember(inputdata.contractname,l_ctname),1);
%         l_ctndateid=find(ismember(inputdata.contract(l_ctnameid).mkdata.date,outputdata.record.cpdate(l_cpid)),1);
%         outputdata.record.cpdateprice(l_cpid)=inputdata.contract(l_ctnameid).mkdata.op(l_ctndateid);
%     end
%     outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
%     if outputdata.record.cpdate{end}==inputdata.commodity.serialmkdata.date{end}
%         outputdata.record.isclosepos(end+1)=0;
%     else
%         outputdata.record.isclosepos(end+1)=1;
%     end
    %=========================================================================
    %����outputdata.record,����ƽ�����ں�ƽ�ּ۸�
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



