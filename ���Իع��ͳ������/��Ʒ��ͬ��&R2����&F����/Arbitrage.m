function [] = Arbitrage(history)
if length(history) >=2   
    load('DATABASE_History.mat');
    len = length(history);
    position = zeros(len, 1);
    x = cell(len-1, 1);
    y = cell(len-1, 1);
    completeX = [];
    completeY = [];

    for ii = 1 : len
        position(ii) = find( cell2mat( cellfun( @(x) (isequal(x, history{ii})), g_database.pairnames, 'UniformOutput', false) ) );
        if ii <= len - 1
            x{ii} = g_database.pairs(1,position(ii)).mkdata.cp(:,1);
            x{ii} = x{ii}(1:end-20);
            y{ii} = g_database.pairs(1,position(ii)).mkdata.cp(:,2);
            y{ii} = y{ii}(1:end-20);
        end
    end

    for ii = 1 : len-1
        completeX = [completeX; x{ii}];
        completeY = [completeY; y{ii}];
    end

    completeX = [ones(length(completeX),1), completeX];

    try 
        [b, bint, res, rint, stats] = regress(completeY, completeX);

        historylength = length(completeY); 

        F = finv(0.95,1, historylength - 2);
        
        if F < stats(2);
            Ftest = 1;
        else
            Ftest = 0;
        end

        average = mean(res);
        sigma = std(res);

        lowerbound = average - 2*sigma;
        upperbound = average + 2*sigma;

        testposition = position(end);

        testX = g_database.pairs(1, testposition).mkdata.cp(:,1);
        testX = [ones(length(testX),1), testX];
        testY = g_database.pairs(1, testposition).mkdata.cp(:,2);

        testRes = testY - testX * b;

        testlength = length(testRes);

        number1 = sum(testRes < lowerbound);

        number2 = sum(testRes > upperbound);

        totalnumber = number1 + number2;

    catch exception
        %throw(exception);
        historylength = NaN;
        testlength = NaN;
        b(1) = NaN;
        b(2) = NaN;
        stats = NaN;
        Ftest= NaN;
        lowerbound = NaN;
        upperbound = NaN;
        totalnumber = NaN;
    end

    load('跨品种同期.mat');
       
    if ~exist('name', 'var')
        name = {};
    end
    
    if ~exist('length1', 'var')
        length1 = [];
    end

    if ~exist('length2', 'var')
        length2 = [];
    end
    
    if ~exist('coeff1', 'var')
        coeff1 = [];
    end

    if ~exist('coeff2', 'var')
        coeff2 = [];
    end
    
    if ~exist('R2', 'var')
        R2 = [];
    end
    
    if ~exist('F_95', 'var')
        F_95 = [];
    end
    
    if ~exist('low', 'var')
        low = [];
    end
    
    if ~exist('upper', 'var')
        upper = [];
    end
    
    if ~exist('outernumber', 'var')
        outernumber = [];
    end


    
    
    name{end+1} = history{end};
    length1(end+1) = historylength;
    length2(end+1) = testlength;
    coeff1(end+1) = b(1);
    coeff2(end+1) = b(2);
    R2(end+1) = stats(1);
    F_95(end+1) = Ftest;
    low(end+1) = lowerbound;
    upper(end+1) = upperbound;
    outernumber(end+1) = totalnumber;

    save '跨品种同期.mat' name length1 length2 coeff1 coeff2 R2 F_95 low upper outernumber
end
end