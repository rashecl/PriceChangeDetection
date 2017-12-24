function stockData=getQuote(SYM,exchange,varargin)
        endDate = char(datetime(datetime('today'), 'format','dd-MMM-yyyy'));
        startDate = char(datetime(datetime('today') - 365, 'format','dd-MMM-yyyy'));
        exchange = 'NYSE';
        plotData = 0;
    overridedefaults(who, varargin)
    % getQuote('MSFT','startDate','14-Dec-2016','endDate','14-Dec-2017')
    
    % Parse date: 
    startDay = startDate(1:2);      endDay = endDate(1:2);
    startMonth = startDate(4:6);    endMonth = endDate(4:6);    
    startYear = startDate(8:11);    
    endYear = endDate(8:11);    
    
    
    % Grab company ID:
%     text = urlread(['http://finance.google.com/finance/historical?q=',SYM]);
    text = urlread(['http://finance.google.com/finance/historical?q=',exchange, '%3A',SYM]);
    % https://finance.google.com/finance?q=NSDQ%3AAMSF
    [~,idx] = regexp(text,'cid value="*');
    text2 = text(idx+1:idx+20);
    text2 = strsplit(text2, '"');
    cid = text2{1};
        %ensure the CID fetched was for the same company requested
        %This can be partly avoided by specifying stock market 
        % Ex: NYSE:ADX or NSDQ:AMSF
%     idx = regexp(text,' historical prices - Google Finance');
    idx = regexp(text,' historical prices - Google Finance');
    text3 = strsplit(text(idx-10:idx-1),':');
    if ~strcmpi(SYM,text3{end})
        error('Missmatching symbols: Symbol fetched was different from symbol requested')
    else
    end
        
    % GatherTickerData    
    urlstr = ['https://finance.google.com/finance/historical?cid=',cid,'&startdate=', startMonth,'+',startDay,'%2C+',startYear,'&enddate=',endMonth,'+',endDay,'%2C+',endYear,'&output=csv']
%     data = urlread('http://finance.google.com/finance/historical?q=UHAL&output=csv');
%     keyboard
    data = urlread(urlstr);
    data = strsplit(data,{',', '\n'});
    data(end) = [];
    data=reshape(data,6,[])';
    stockData = struct( 'Date', [],...
                        'Open', [], ...
                        'High', [], ...
                        'Low', [], ...
                        'Close', [],...
                        'Volume', [],...
                        'Idx', []);

    for i = 2:size(data,1)
        datestr = char(data(i,1));
        year = datestr(end-1:end);
        datestr(end-1:end) = [];
        datestr = [datestr, '20', year];

        stockData(end+1) = struct('Date', datetime(datestr),...
                        'Open', str2double(data(i,2)), ...
                        'High', str2double(data(i,3)), ...
                        'Low', str2double(data(i,4)), ...
                        'Close', str2double(data(i,5)),...
                        'Volume', str2double(data(i,6)),...
                        'Idx',size(data,1)-i+1);
    end
    stockData(1) = [];
    stockData = nestedSortStruct(stockData,'Idx');
    
    switch plotData
        case 1
        figure;
            plot([stockData.Date],[stockData.Close],'-o','MarkerSize',2,'hittest','on');
            
            hold on; 
                for i=1:numel(stockData)
                    plot([stockData(i).Date stockData(i).Date],[stockData(i).Low stockData(i).High],'Color',[.4 .4 .4],'hittest','off')  
                    scatter(stockData(i).Date,stockData(i).Close,1,'b',...
                        'tag',strcat('Date:', char(stockData(i).Date),...
                            ', H:',num2str(stockData(i).High),...
                            ', L:', num2str(stockData(i).Low),...
                            ', Vol:', num2str(stockData(i).Volume)),...
                        'ButtonDownFcn', @dispDateBreakdown, 'hittest','on') 
                end
                
            title(SYM)
            ylabel('Price')
            
        otherwise
    end
%         Date =[stockData.Date]';
%         Closeing = [stockData.Close]';
%         closing = table(Date,Closeing);
    assignin('base','SYM',SYM)
end

% https://finance.google.com/finance/historical?cid=1027614502756686&startdate=Dec+12%2C+2013&enddate=Dec+14%2C+2017&num=30&ei=rMYwWrjnD8Ox2AbN24OgCg
% https://finance.google.com/finance/historical?cid=1027614502756686&startdate=Dec+14%2C+2013&enddate=Dec+14%2C+2017
