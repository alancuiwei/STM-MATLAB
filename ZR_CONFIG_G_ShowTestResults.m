function ZR_CONFIG_G_ShowTestResults()
% 记录测试结果展示参数
global G_ShowTestResults;
global g_XMLfile;
global g_DBconfig;
% 月收益表
G_ShowTestResults.g_tables.returnrate.title={' ','一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月','年收益'};
% 开仓记录表
G_ShowTestResults.g_tables.record.pos.rightid.title='rightid';
G_ShowTestResults.g_tables.record.pos.name.title='开仓名称';
G_ShowTestResults.g_tables.record.pos.isclosepos.title='是否实际平仓';
G_ShowTestResults.g_tables.record.pos.opdate.title='开仓日期';
G_ShowTestResults.g_tables.record.pos.cpdate.title='平仓日期';
G_ShowTestResults.g_tables.record.pos.opdateprice.title='开仓价格（差）';
G_ShowTestResults.g_tables.record.pos.cpdateprice.title='平仓价格（差）';
G_ShowTestResults.g_tables.record.pos.margin.title='保证金';
G_ShowTestResults.g_tables.record.pos.optradecharge.title='开仓手续费';
G_ShowTestResults.g_tables.record.pos.cptradecharge.title='平仓手续费';
G_ShowTestResults.g_tables.record.pos.profit.title='盈亏金额';
% % G_ShowTestResults.g_tables.record.pos.type.title='策略类型';
% % G_ShowTestResults.g_tables.record.pos.optype.title='开仓类型';
% % G_ShowTestResults.g_tables.record.pos.cptype.title='平仓类型';
% % G_ShowTestResults.g_tables.record.pos.opgapvl1.title='近期开仓交易量';
% % G_ShowTestResults.g_tables.record.pos.opgapvl2.title='远期开仓交易量';
% % G_ShowTestResults.g_tables.record.pos.cpgapvl1.title='近期平仓交易量';
% % G_ShowTestResults.g_tables.record.pos.cpgapvl2.title='远期平仓交易量';
% 交易记录表
% % G_ShowTestResults.g_tables.record.trade.name.title='交易名称';
% % G_ShowTestResults.g_tables.record.trade.opdate.title='交易开始日期';
% % G_ShowTestResults.g_tables.record.trade.cpdate.title='交易结束日期';
% % G_ShowTestResults.g_tables.record.trade.type.title='策略类型';
% % G_ShowTestResults.g_tables.record.trade.isclosepos.title='是否实际平仓';
% % G_ShowTestResults.g_tables.record.trade.profit.title='盈亏金额';
% 数据表
G_ShowTestResults.g_tables.tabledata.reference=[];
G_ShowTestResults.g_tables.tabledata.sort=[];
G_ShowTestResults.g_tables.tabledata.returnrate=[];
G_ShowTestResults.g_tables.tabledata.record.pos=[];
G_ShowTestResults.g_tables.tabledata.record.trade=[];
G_ShowTestResults.g_tables.outfiletype='xls';
G_ShowTestResults.g_tables.outdir='TestResult/Tables';
% 导出信息xls
G_ShowTestResults.g_tables.xls.outfile='TestResults';
G_ShowTestResults.g_tables.xls.reference.sheetname='reference';
G_ShowTestResults.g_tables.xls.sort.sheetname='sort';
G_ShowTestResults.g_tables.xls.returnrate.sheetname='returnrate';
G_ShowTestResults.g_tables.xls.record.pos.sheetname='posrecord';
G_ShowTestResults.g_tables.xls.record.trade.sheetname='traderecord';
G_ShowTestResults.g_tables.xls.optimization.filename='Optim';
% 导出到xml
G_ShowTestResults.g_tables.xml.record.pos.filename='posrecord';
G_ShowTestResults.g_tables.xml.returnrate.filename='returnrate';
G_ShowTestResults.g_tables.xml.reference.filename='reference';

% 测评参数表
G_ShowTestResults.g_tables.reference.name.title='合约名称';
G_ShowTestResults.g_tables.reference.costinput.title='投入资金';
G_ShowTestResults.g_tables.reference.numoforder.title='商品每笔交易手数';
G_ShowTestResults.g_tables.reference.totalnetprofit.title='总盈利亏损';
G_ShowTestResults.g_tables.reference.grossprofit.title='毛盈利金额';
G_ShowTestResults.g_tables.reference.grossloss.title='毛亏损金额';
G_ShowTestResults.g_tables.reference.avemonthreturnrate.title='平均月回报率';
G_ShowTestResults.g_tables.reference.aveyearreturnrate.title='平均年回报率';
G_ShowTestResults.g_tables.reference.totaltradedays.title='交易天数';
G_ShowTestResults.g_tables.reference.totaltradenum.title='总交易次数';
G_ShowTestResults.g_tables.reference.totaltradenumperday.title='日均交易次数';
G_ShowTestResults.g_tables.reference.profittradenum.title='盈利交易次数';
G_ShowTestResults.g_tables.reference.losstradenum.title='亏损交易次数';
G_ShowTestResults.g_tables.reference.profittraderate.title='盈利交易次数/总交易次数';
G_ShowTestResults.g_tables.reference.maxprofit.title='最大单笔盈利金额';
G_ShowTestResults.g_tables.reference.maxloss.title='最大单笔亏损金额';
G_ShowTestResults.g_tables.reference.profitpertrade.title='毛盈利金额/盈利交易次数';
G_ShowTestResults.g_tables.reference.losspertrade.title='毛亏损金额/亏损交易次数';
G_ShowTestResults.g_tables.reference.returnpertrade.title='平均每次交易盈亏金额';
G_ShowTestResults.g_tables.reference.expectedvalue.title='期望值';
G_ShowTestResults.g_tables.reference.maxdrawdown.title='最大资金回挫';
G_ShowTestResults.g_tables.reference.maxdrawdownspread.title='最长衰退期';
% 优化表
G_ShowTestResults.g_tables.optimization.param.period.title='周期';
G_ShowTestResults.g_tables.optimization.param.losses.title='止损参数';
G_ShowTestResults.g_tables.optimization.param.wins.title='盈利参数';
% G_ShowTestResults.g_tables.optimization.param.countersofup.title='上升计数';
% G_ShowTestResults.g_tables.optimization.param.countersofdown.title='下降计数';
% G_ShowTestResults.g_tables.optimization.param.losses.title='止损参数';
% G_ShowTestResults.g_tables.optimization.param.sharp.title='飙的幅度';
% G_ShowTestResults.g_tables.optimization.param.sharpdays.title='飙的天数';
G_ShowTestResults.g_tables.optimization.expectedvalue.title='最悲观期望值';

% 图形
G_ShowTestResults.g_figure.savetradebar.outdir='TestResult/Figure';
G_ShowTestResults.g_figure.savetradebar.outfiletype='-djpeg';
G_ShowTestResults.g_figure.savetradebar.issaved=0;

% 显示报告
G_ShowTestResults.g_tables.strategyid=g_XMLfile.strategyid;
if ~g_XMLfile.isupdated
    G_ShowTestResults.g_tables.outfiletype='xml';
    G_ShowTestResults.g_tables.outdir=g_XMLfile.path;
    G_ShowTestResults.g_figure.savetradebar.outdir=g_XMLfile.path;
elseif g_DBconfig.isupdated
    G_ShowTestResults.g_tables.outfiletype='database';
end
G_ShowTestResults.g_tables.outfiletype='xls';
end