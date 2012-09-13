function ZR_STOCK_PROCESS_ImportStockMKData(varargin)

global g_database;

l_stockfilename=strcat('./Data/',varargin{1},'.csv');
l_file = fopen(l_stockfilename, 'rt');
l_rawmkdata = textscan(l_file, '%s %f %f %f %f %f %f', ...
      'Delimiter',',');
fclose(l_file);

l_mkdata.datalen=length(l_rawmkdata{1});
l_mkdata.date=cellfun(@(e_element) (datestr(e_element,'yyyy-mm-dd')),l_rawmkdata{1},'UniformOutput',false);
l_mkdata.op=l_rawmkdata{2};
l_mkdata.hp=l_rawmkdata{3};
l_mkdata.lp=l_rawmkdata{4};
l_mkdata.cp=l_rawmkdata{5};
l_mkdata.vl=l_rawmkdata{6};
l_mkdata.oi=l_rawmkdata{7};
l_mkdata.gap=zeros(1,l_mkdata.datalen);
l_mkdata.ctname=repmat(varargin(1),1,l_mkdata.datalen);
g_database.commodities.serialmkdata=l_mkdata;
g_database.commodities.name=varargin(1);
g_database.commodities.info.commodityid=varargin(1);
g_database.commodities.info.tick=1;
g_database.commodities.info.margin=1;
g_database.commodities.info.tradecharge=0;
g_database.commodities.info.issinglemargin=0;
g_database.commodities.info.tradeunit=1;
g_database.currentdate=l_mkdata.date(end);
g_database.commoditynames=varargin(1);
g_database.contractnames=varargin(1);
g_database.contracts.mkdata=l_mkdata;
g_database.contracts.name=varargin(1);


end
