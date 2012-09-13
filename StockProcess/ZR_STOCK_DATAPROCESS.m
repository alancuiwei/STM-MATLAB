function ZR_STOCK_DATAPROCESS()
% 针对g_rawdata数据的预处理

% 声明全局变量
global G_RunSpecialTestCase;
global g_database;
global g_contractnames;
global g_commoditynames;
global g_pairnames;
global g_coredata;

l_cmnum=length(g_commoditynames);
l_cmid=1;
l_realcmid=1;

g_coredata(l_cmid).commodity.serialmkdata.date=g_database.commodities(l_realcmid).serialmkdata.date;
g_coredata(l_cmid).commodity.serialmkdata.op=g_database.commodities(l_realcmid).serialmkdata.op;
g_coredata(l_cmid).commodity.serialmkdata.hp=g_database.commodities(l_realcmid).serialmkdata.hp;
g_coredata(l_cmid).commodity.serialmkdata.lp=g_database.commodities(l_realcmid).serialmkdata.lp;
g_coredata(l_cmid).commodity.serialmkdata.cp=g_database.commodities(l_realcmid).serialmkdata.cp;
g_coredata(l_cmid).commodity.serialmkdata.vl=g_database.commodities(l_realcmid).serialmkdata.vl;
g_coredata(l_cmid).commodity.serialmkdata.oi=g_database.commodities(l_realcmid).serialmkdata.oi;
g_coredata(l_cmid).commodity.serialmkdata.gap=g_database.commodities(l_realcmid).serialmkdata.gap;
g_coredata(l_cmid).commodity.serialmkdata.ctname=g_database.commodities(l_realcmid).serialmkdata.ctname;
g_coredata(l_cmid).commodity.serialmkdata.datalen=length(g_database.commodities(l_realcmid).serialmkdata.date); 
g_coredata(l_cmid).commodity.name=g_database.commodities.name;
g_coredata(l_cmid).currentdate=g_coredata(l_cmid).commodity.serialmkdata.date(end);
g_coredata(l_cmid).commodity.info=g_database.commodities(l_realcmid).info;
g_contractnames=g_database.contractnames;
g_commoditynames=g_database.commoditynames;

end
