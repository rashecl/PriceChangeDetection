NYSE = importfile('121317_NYSE.csv');
% NASDAQ = importfile('121317_NASDAQ.csv')
tickers = table2cell([NYSE(:,2)]);
exchanges = table2cell([NYSE(:,4)]);
% tickers = {'STM'};
days2avg = 14;
days2momentum = 3; 

for t =110:115%:numel(tickers)
    exchange = char(exchanges{t});
    SYM = char(tickers{t});
    Ticker = getQuote(SYM, exchange, 'startDate','14-Dec-2015','endDate','12-Dec-2017');
    % Ticker = getQuote('SRNE','startDate','14-Dec-2013','endDate','16-Dec-2017');
    Ticker = nestedSortStruct(Ticker,'Idx');
    s=1;
%     movingAVG = nan(days2avg-1,1);
      movingAvg = [];
      extremity = [];
      momentum = [];
    for i = 1:numel(Ticker)
        if i <days2avg
            momentum = [momentum; nan];
            movingAvg = [movingAvg; nan];
            extremity = [extremity; nan];
        else
            
            momentum = [momentum; (Ticker(i).Close - min([Ticker(i-days2momentum+1:i).Low]))/(max([Ticker(i-days2momentum+1:i).High]) - min([Ticker(i-days2momentum+1:i).Low]))];
            movingAvg = [movingAvg; mean([Ticker(i-days2avg+1:i).Close])];
            extremity = [extremity; Ticker(i).Close-mean([Ticker(i-days2avg+1:i).Close])];
        end
        Ticker(i).movingAvg = movingAvg(end);
        Ticker(i).extremity = extremity(end);
        Ticker(i).momentum = momentum(end);
    end 
        
        figure (9646);
        clf
        hold on; title(SYM);
        set(gcf,'Position',[158 213 972 562])
        plot([Ticker.Date],[Ticker.Close],'-k');
        hold on; plot([Ticker.Date],[Ticker.movingAvg],'-b');
        hold on; plot([Ticker.Date],[Ticker.extremity],'-g');
        
        ylabel('Price')
        hold on; plot([Ticker.Date],[Ticker.momentum],'-k');
        
%         figure(34575); 
%         histogram([Ticker.extremity])

        Close = [Ticker.Close]';
        Date = [Ticker.Date]';

        % Identify when stock is @ a low extremity of moving average
        % (In the future we can describe this as certain std from the mean)
        idx1 = find([Ticker.extremity] < -.5);
        figure (9646);
        hold on; scatter(Date(idx1), Close(idx1),'or','tag','extremeLow')
        idx2 = find([Ticker.momentum] >.25);

        for ii = 1:numel(idx1)
            for jj = 1:numel (idx2) 
                if idx2(jj) > idx1(ii) && idx2(jj) < idx1(ii)+5
                    hold on; scatter(Date(idx2(jj)), Close(idx2(jj)),'og','tag','increasing')
                else
                end
            end
        end
        legend({'LI','Stock Price','extremity','momentum','extremeLow','increasing'})
        
        pause;
end

            

    
