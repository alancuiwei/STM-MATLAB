function out_pairdata = ZR_FUN_QueryPairData(varargin)
% 从数据库中得到近远期合约同时存在时间的数据
% 输入： beforecontractname（近期合约名），aftercontractname（远期合约名）
% 返回： 两个合约的重叠区间的数据
in_beforecontractname=varargin{1};
in_aftercontractname=varargin{2};
if (nargin>2)
    in_beforecontractunit=varargin{3};
    in_aftercontractunit=varargin{4};
else
    in_beforecontractunit=1;
    in_aftercontractunit=1;    
end
sqlstr1='select before_t.openprice,before_t.highprice,before_t.lowprice,before_t.closeprice,before_t.volume,before_t.openinterest,before_t.orderid';
sqlstr1=strcat(sqlstr1,',after_t.openprice,after_t.highprice,after_t.lowprice,after_t.closeprice,after_t.volume,after_t.openinterest,after_t.orderid');
sqlstr1=strcat(sqlstr1,',before_t.currentdate');
sqlstr1=strcat(sqlstr1,' from marketdaydata_t as before_t,marketdaydata_t as after_t where before_t.currentdate=after_t.currentdate');
sqlstr1=strcat(sqlstr1,' and before_t.contractid=''', in_beforecontractname, ''' and after_t.contractid=''', in_aftercontractname);
sqlstr1=strcat(sqlstr1, ''' and before_t.closeprice between 1 and 100000000 and after_t.closeprice between 1 and 100000000 order by before_t.currentdate;');

% 连接数据库
temp_data=ZR_DATABASE_AccessDB('futuretest',sqlstr1);

if(strcmp(temp_data,'No Data'))
    out_pairdata=[];
    error('%s-%s没有配对数据',cell2mat(in_beforecontractname),cell2mat(in_aftercontractname));
else
    out_pairdata=struct('date',{temp_data(:,15)}',...
        'opgap',cell2mat(temp_data(:,1))-cell2mat(temp_data(:,8)),...
        'op',[cell2mat(temp_data(:,1)),cell2mat(temp_data(:,8))],...
        'cpgap',cell2mat(temp_data(:,4))-cell2mat(temp_data(:,11)),...
        'cp',[cell2mat(temp_data(:,4)),cell2mat(temp_data(:,11))],...
        'vl',[cell2mat(temp_data(:,5)),cell2mat(temp_data(:,12))],...
        'index',[cell2mat(temp_data(:,7)),cell2mat(temp_data(:,14))],...
        'datalen',length(temp_data(:,1)));
end


end