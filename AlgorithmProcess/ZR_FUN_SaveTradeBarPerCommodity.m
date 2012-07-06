function ZR_FUN_SaveTradeBarPerCommodity(in_type)
%%%%%%%% 生成交易的图
global g_rawdata;
global g_tradedata;
global g_figure;
% global G_Start;
% if (strcmp(G_Start.runmode,'RunSpecialTestCase')&&(g_figure.savetradebar.issaved))
if g_figure.savetradebar.issaved
    switch in_type
        case 'pair'
            % 遍历该品种所有的套利对
            close all; 
            l_pairnum=length(g_tradedata);
            for l_pairid=1:l_pairnum
                if(isempty(g_tradedata(l_pairid).pos.num))
                    continue;
                end  
                figure('Name',cell2mat(g_rawdata.pair(l_pairid).name));
                l_cpgaplen=g_rawdata.pair(l_pairid).mkdata.datalen;
                for l_posid=1:g_tradedata(l_pairid).pos.num
                    l_opdateid=find(strcmp(g_tradedata(l_pairid).pos.opdate(l_posid),g_rawdata.pair(l_pairid).mkdata.date),1);
                    l_cpdateid=find(strcmp(g_tradedata(l_pairid).pos.cpdate(l_posid),g_rawdata.pair(l_pairid).mkdata.date),1);
                    % 从2开始标记颜色比较清楚
                    l_color=zeros(l_cpgaplen,1);
                    l_color(l_opdateid,:)=2;
                    l_color(l_cpdateid,:)=3;            
                    l_bar=bar(1:l_cpgaplen,g_rawdata.pair(l_pairid).mkdata.cpgap,'stacked');
                    l_ch=get(l_bar,'children');
                    set(l_ch, 'EdgeColor', 'w'); 
                    set(l_ch,'FaceVertexCData',l_color);
                end
                if (~exist(g_figure.savetradebar.outdir,'dir'))
                    mkdir(g_figure.savetradebar.outdir);
                end
                % 保存图形的类型
                switch g_figure.savetradebar.outfiletype
                    case 'fig'
                        saveas(gcf,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.pair(l_pairid).name)));
                    otherwise
                        saveas(gcf,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.pair(l_pairid).name)));
                        print(gcf,g_figure.savetradebar.outfiletype,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.pair(l_pairid).name)));
                end
            end
        case 'single'
            % 遍历该品种所有的合约
            close all; 
            l_pairnum=length(g_tradedata);
            for l_contractid=1:l_pairnum
                if(isempty(g_tradedata(l_contractid).pos.num))
                    continue;
                end  
                figure('Name',cell2mat(g_rawdata.contract(l_contractid).name));
                l_cpgaplen=g_rawdata.contract(l_contractid).mkdata.datalen;
                for l_posid=1:g_tradedata(l_contractid).pos.num
                    l_opdateid=find(strcmp(g_tradedata(l_contractid).pos.opdate(l_posid),g_rawdata.contract(l_contractid).mkdata.date),1);
                    l_cpdateid=find(strcmp(g_tradedata(l_contractid).pos.cpdate(l_posid),g_rawdata.contract(l_contractid).mkdata.date),1);
                    % 从2开始标记颜色比较清楚
                    l_color=zeros(l_cpgaplen,1);
                    l_color(l_opdateid,:)=2;
                    l_color(l_cpdateid,:)=3;            
                    l_bar=bar(1:l_cpgaplen,g_rawdata.contract(l_contractid).mkdata.cpgap,'stacked');
                    l_ch=get(l_bar,'children');
                    set(l_ch, 'EdgeColor', 'w'); 
                    set(l_ch,'FaceVertexCData',l_color);
                end
                if (~exist(g_figure.savetradebar.outdir,'dir'))
                    mkdir(g_figure.savetradebar.outdir);
                end
                % 保存图形的类型
                switch g_figure.savetradebar.outfiletype
                    case 'fig'
                        saveas(gcf,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.contract(l_contractid).name)));
                    otherwise
                        saveas(gcf,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.contract(l_contractid).name)));
                        print(gcf,g_figure.savetradebar.outfiletype,strcat(g_figure.savetradebar.outdir,'/',cell2mat(g_rawdata.contract(l_contractid).name)));
                end
            end
    end
end