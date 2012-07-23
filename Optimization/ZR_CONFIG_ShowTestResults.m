function ZR_CONFIG_ShowTestResults()
% 记录测试结果展示参数
% global G_ShowTestResults;
global g_tables;
global g_figure;
global g_XMLfile;
global g_DBconfig;
% 月收益表
g_tables.returnrate.title={' ','一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月','年收益'};
% 开仓记录表
g_tables.record.pos.rightid.title='rightid';
g_tables.record.pos.name.title='开仓名称';
g_tables.record.pos.isclosepos.title='是否实际平仓';
g_tables.record.pos.opdate.title='开仓日期';
g_tables.record.pos.cpdate.title='平仓日期';
g_tables.record.pos.opdateprice.title='开仓价格（差）';
g_tables.record.pos.cpdateprice.title='平仓价格（差）';
g_tables.record.pos.margin.title='保证金';
g_tables.record.pos.optradecharge.title='开仓手续费';
g_tables.record.pos.cptradecharge.title='平仓手续费';
g_tables.record.pos.profit.title='盈亏金额';
% % g_tables.record.pos.type.title='策略类型';
% % g_tables.record.pos.optype.title='开仓类型';
% % g_tables.record.pos.cptype.title='平仓类型';
% % g_tables.record.pos.opgapvl1.title='近期开仓交易量';
% % g_tables.record.pos.opgapvl2.title='远期开仓交易量';
% % g_tables.record.pos.cpgapvl1.title='近期平仓交易量';
% % g_tables.record.pos.cpgapvl2.title='远期平仓交易量';
% 交易记录表
% % g_tables.record.trade.name.title='交易名称';
% % g_tables.record.trade.opdate.title='交易开始日期';
% % g_tables.record.trade.cpdate.title='交易结束日期';
% % g_tables.record.trade.type.title='策略类型';
% % g_tables.record.trade.isclosepos.title='是否实际平仓';
% % g_tables.record.trade.profit.title='盈亏金额';
% 数据表
g_tables.tabledata.reference=[];
g_tables.tabledata.sort=[];
g_tables.tabledata.returnrate=[];
g_tables.tabledata.record.pos=[];
g_tables.tabledata.record.trade=[];
g_tables.outfiletype='xls';
g_tables.outdir='TestResult/Tables';
% 导出信息xls
g_tables.xls.outfile='TestResults';
g_tables.xls.reference.sheetname='reference';
g_tables.xls.sort.sheetname='sort';
g_tables.xls.returnrate.sheetname='returnrate';
g_tables.xls.record.pos.sheetname='posrecord';
g_tables.xls.record.trade.sheetname='traderecord';
g_tables.xls.optimization.filename='Optim';
% 导出到xml
g_tables.xml.record.pos.filename=strcat('posrecord-',num2str(g_XMLfile.userid));
g_tables.xml.returnrate.filename=strcat('returnrate-',num2str(g_XMLfile.userid));
g_tables.xml.reference.filename=strcat('reference-',num2str(g_XMLfile.userid));
g_tables.xml.dailyinfo.filename=strcat('dailyinfo-',num2str(g_XMLfile.userid));

% 测评参数表
g_tables.reference.name.title='合约名称';
g_tables.reference.costinput.title='投入资金';
g_tables.reference.numoforder.title='商品每笔交易手数';
g_tables.reference.totalnetprofit.title='总盈利亏损';
g_tables.reference.grossprofit.title='毛盈利金额';
g_tables.reference.grossloss.title='毛亏损金额';
g_tables.reference.avemonthreturnrate.title='平均月回报率';
g_tables.reference.aveyearreturnrate.title='平均年回报率';
g_tables.reference.totaltradedays.title='交易天数';
g_tables.reference.totaltradenum.title='总交易次数';
g_tables.reference.totaltradenumperday.title='日均交易次数';
g_tables.reference.profittradenum.title='盈利交易次数';
g_tables.reference.losstradenum.title='亏损交易次数';
g_tables.reference.profittraderate.title='盈利交易次数/总交易次数';
g_tables.reference.maxprofit.title='最大单笔盈利金额';
g_tables.reference.maxloss.title='最大单笔亏损金额';
g_tables.reference.profitpertrade.title='毛盈利金额/盈利交易次数';
g_tables.reference.losspertrade.title='毛亏损金额/亏损交易次数';
g_tables.reference.returnpertrade.title='平均每次交易盈亏金额';
g_tables.reference.expectedvalue.title='期望值';
g_tables.reference.maxdrawdown.title='最大资金回挫';
g_tables.reference.maxdrawdownspread.title='最长衰退期';
% 优化表
g_tables.optimization.param.period.title='周期';
g_tables.optimization.param.losses.title='止损参数';
g_tables.optimization.param.wins.title='盈利参数';
% g_tables.optimization.param.countersofup.title='上升计数';
% g_tables.optimization.param.countersofdown.title='下降计数';
% g_tables.optimization.param.losses.title='止损参数';
% g_tables.optimization.param.sharp.title='飙的幅度';
% g_tables.optimization.param.sharpdays.title='飙的天数';
g_tables.optimization.expectedvalue.title='最悲观期望值';

% 图形
g_figure.savetradebar.outdir='TestResult/Figure';
g_figure.savetradebar.outfiletype='-djpeg';
g_figure.savetradebar.issaved=0;

% 显示报告
g_tables.strategyid=g_XMLfile.strategyid;
g_tables.outdir=g_XMLfile.path;
g_figure.savetradebar.outdir=g_XMLfile.path;    
switch g_XMLfile.resulttype
    case 'xml'
        g_tables.outfiletype='xml';    
    case 'database'
        g_tables.outfiletype='database';     
        g_tables.userid=g_XMLfile.userid; 
        g_tables.ordernum=g_XMLfile.ordernum; 
        g_tables.strategyid=g_XMLfile.strategyid; 
    case 'xls'  
        g_tables.outfiletype='xls';
end


% if ~g_XMLfile.isupdated
%     g_tables.outfiletype='xml';
%     g_tables.outdir=g_XMLfile.path;
%     g_figure.savetradebar.outdir=g_XMLfile.path;
% elseif g_DBconfig.isupdated
%     g_tables.outfiletype='database';
% end
% g_tables.outfiletype='xls';
% g_tables.outfiletype='xml';
end