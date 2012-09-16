function outputdata=ZR_STRATEGY_040807(inputdata)
% ������һ��/������һ����Three Inside Up/Down��
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
%Ѱ��������һ��/������һ���ĵ㣬����Ѱ�ҵ��ĵ��������PositionTrade��
outInteger=TA_CDL3INSIDE(inputdata.commodity.serialmkdata.op,...
    inputdata.commodity.serialmkdata.hp,...
    inputdata.commodity.serialmkdata.lp,...
    inputdata.commodity.serialmkdata.cp);
    l_posinter=find(outInteger~=0);
    %ȥ��������������յĽ�������
    if isempty(l_posinter)
        return;
    end
    l_tradeday=zeros(1,numel(l_posinter));
    for l_id = 1:(numel(l_posinter)-1)
        if (l_posinter(l_id)>0 && l_posinter(l_id+1)>0) || (l_posinter(l_id)<0 && l_posinter(l_id+1)<0)
            l_tradeday(l_id+1)=-1;
        end
    end
    l_posinter(l_tradeday==-1)=[];
    l_realtradeday=unique(l_posinter);
if ~isempty(l_realtradeday)
%==========================================================================
    if isequal(zeros(numel(inputdata.commodity.dailyinfo.trend),1),inputdata.commodity.dailyinfo.trend) %�ж��Ƿ���Ϊ�����Ի�һ����
        %����record�е�opdateprice,direction
        for l_tradeid=1:numel(l_realtradeday)
            if outInteger(l_realtradeday(l_tradeid))<0                                    %������һ��
                if(l_realtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=-1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid)); 
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid))+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid));
                    outputdata.record.direction(l_tradeid)=-1;
                end
            elseif outInteger(l_realtradeday(l_tradeid))>0                                %������һ��
                if(l_realtradeday(l_tradeid)>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                    outputdata.orderlist.direction=1;
                    outputdata.orderlist.price=0;
                    outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid));
                else
                    outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_realtradeday(l_tradeid)); %��������׼�¼
                    outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_realtradeday(l_tradeid))+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid));
                    outputdata.record.direction(l_tradeid)=1;
                end
            end
            outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(l_realtradeday(l_tradeid));
        end
%==========================================================================
        %����outputdata.record,����ƽ�����ں�ƽ�ּ۸�
        if(numel(outputdata.record.opdate)>=2)
            outputdata.record.cpdate=outputdata.record.opdate(2:end);
            outputdata.record.cpdateprice=outputdata.record.opdateprice(2:end);
            outputdata.record.isclosepos=ones(1,numel(outputdata.record.opdateprice)-1);
            outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=0;
            outputdata.record.cpdate(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.date(end);
            outputdata.record.cpdateprice(numel(outputdata.record.opdateprice))=inputdata.commodity.serialmkdata.cp(end)+inputdata.commodity.serialmkdata.gap(end);
            %{
            if(inputdata.contract.info.daystolasttradedate<=0)
                outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
            end
            %}
        elseif(numel(outputdata.record.opdate)>=1)
            outputdata.record.cpdate=inputdata.commodity.serialmkdata.date(end);
            outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.cp(end)+inputdata.commodity.serialmkdata.gap(end);
            l_id=find(strcmp(inputdata.contractname,inputdata.commodity.serialmkdata.ctname(end-1))==1);
            l_id2= strcmp(inputdata.contract(l_id).mkdata.date,outputdata.record.cpdate)==1;
            outputdata.record.cpdateprice=inputdata.contract(l_id).mkdata.cp(l_id2);
            outputdata.record.isclosepos=0;
            %{
            if(inputdata.contract.info.daystolasttradedate<=0)
                outputdata.record.isclosepos(numel(outputdata.record.opdateprice))=1;
            end
            %}
        end
%==========================================================================
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
%==========================================================================
    else                %������Ϊ�β��ԣ�����������������
        % 1.���ݲ����㷨��ǰ��������ƣ����롱��ϵ����Ѱ�ҳ���������յĵ�
        % 2.���ݲ����㷨����Ѱ�ҿ���ƽ�ֵĵ�
        
        l_opcnt=1;%��������
        l_cpcnt=1;                                                         
        l_direction=zeros(1,numel(l_postrade));
        l_optradeday=zeros(1,numel(l_postrade));
        l_cptradeday=zeros(1,numel(l_postrade));
        for l_posid=1:numel(l_postrade)
            if outInteger(l_realtradeday(l_posid))<0                                    %������һ��
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid))==1
                    l_optradeday(l_opcnt)=l_postrade(l_posid);
                    l_direction(l_opcnt)=-1;
                    l_opcnt=l_opcnt+1;
                end
                l_cptradeday(l_cpcnt)=l_postrade(l_posid);
                l_cpcnt=l_cpcnt+1;
            elseif outInteger(l_realtradeday(l_posid))>0                                %������һ��
                if inputdata.commodity.dailyinfo.trend(l_postrade(l_posid))==2
                    l_optradeday(l_opcnt)=l_postrade(l_posid);
                    l_direction(l_opcnt)=1;
                    l_opcnt=l_opcnt+1;
                end
                l_cptradeday(l_cpcnt)=l_postrade(l_posid);
                l_cpcnt=l_cpcnt+1;
            end
        end
        if (~isempty(l_optradeday)&&~isempty(l_cptradeday))
            
            l_optradeday(l_optradeday==0)=[];
            l_cptradeday(l_cptradeday==0)=[];
            if isempty(l_optradeday)
                return;
            end
            l_oprealtradeday=unique(l_optradeday);
            l_cprealtradeday=unique(l_cptradeday);
            
%==========================================================================
            %����record�е�opdateprice,direction
            for l_tradeid=1:numel(l_oprealtradeday)
                if outInteger(l_oprealtradeday(l_tradeid))<0                                    %������һ��
                    if(l_oprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                        outputdata.orderlist.direction=-1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
                    else
                        outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)); %��������׼�¼
                        outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid))+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid));
                        outputdata.record.direction(l_tradeid)=-1;
                    end
                elseif outInteger(l_oprealtradeday(l_tradeid))>0                                %������һ��
                    if(l_oprealtradeday(l_tradeid)+2>numel(inputdata.commodity.serialmkdata.date)) %���罻��Ϊ���������֮�䣬�����outputdata.orderlist����
                        outputdata.orderlist.direction=1;
                        outputdata.orderlist.price=0;
                        outputdata.orderlist.name=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
                    else
                        outputdata.record.opdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_oprealtradeday(l_tradeid)); %��������׼�¼
                        outputdata.record.opdateprice(l_tradeid)=inputdata.commodity.serialmkdata.op(l_oprealtradeday(l_tradeid))+inputdata.commodity.serialmkdata.gap(l_realtradeday(l_tradeid));
                        outputdata.record.direction(l_tradeid)=1;
                    end
                end
                outputdata.record.ctname(l_tradeid)=inputdata.commodity.serialmkdata.ctname(l_oprealtradeday(l_tradeid)+1);
            end
%==========================================================================
            % ���ݲ����㷨����Ѱ�ҿ���ƽ�ֵĵ�
            l_tempcpdate=cell(1,numel(l_cprealtradeday));
            for l_tradeid=1:numel(l_cprealtradeday)
                if outInteger(l_cprealtradeday(l_tradeid))<0                                    %������һ��
                    l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid));
                elseif outInteger(l_cprealtradeday(l_tradeid))>0                                %������һ��
                    l_tempcpdate(l_tradeid)=inputdata.commodity.serialmkdata.date(l_cprealtradeday(l_tradeid));
                end
            end
%==========================================================================
            % ���ݲ����㷨��ǰ��������ƣ����򡱹�ϵ����Ѱ�ҳ�ƽ�ֵ�
            l_difftrend=inputdata.commodity.dailyinfo.trend(2:end)-inputdata.commodity.dailyinfo.trend(1:end-1);
            l_postrend=find(l_difftrend~=0);
            l_trendchangeday=unique(l_postrend);    % ���Ʊ仯ǰ�����һ��
            for i=1:numel(l_trendchangeday)
                if (l_trendchangeday(i)+2<=numel(inputdata.commodity.dailyinfo.date))
                    l_trendchangedate=inputdata.commodity.dailyinfo.date(l_trendchangeday(i)+2);
                else
                    l_trendchangedate=inputdata.commodity.dailyinfo.date(end);
                end
            end
            %     l_strategycpdate=outputdata.record.opdate(2:end); % ���ڸò��ԣ�����ʱ��ƽ��
            l_strategycpdate=l_tempcpdate;
            l_cpdate=unique([l_trendchangedate',l_strategycpdate]);
            
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
%==========================================================================
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
                outputdata.record.cpdateprice=inputdata.commodity.serialmkdata.cp(end)+inputdata.commodity.serialmkdata.gap(end);
                outputdata.record.isclosepos=0;
            end
%==========================================================================
            % ����dailyinfo��Ϣ
            outputdata.dailyinfo.date=inputdata.commodity.dailyinfo.date;
            outputdata.dailyinfo.trend=inputdata.commodity.dailyinfo.trend; % ���޸�
        end
    end
%==========================================================================
end