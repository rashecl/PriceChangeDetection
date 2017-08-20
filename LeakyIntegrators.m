%% Run this block of code first
    try addpath('/Users/rashedharun/Desktop/Hanks Lab/Modeling/Functions')
    figurePositioning2
catch
    positions = {[1   449   648 357];...
                [650   449   648 357];...
                [0   18   648 357];...
                [650   18   648 357];...
                [110 22 1216 779]};
end

%% Fig1: Series of leaky integrators
close all
GenerateClicks('FreqTwo',100,'ChangeTime',7);
%     pairs = {'FreqOne'			50	; ...
%     'FreqTwo'                   100	; ...
%     'InitDelay'					0.5	; ...
%     'MeanChangeTime'            2.5 ; ...
%     'MaxChangeTime'             7.0 ; ...
%     'ResponseTime'              0.8 ; ...
%     'ChangeTime'                []  ; ...
%     }

tau = [];
tau = [0.002:0.002:.01];
tau = [tau, [.02:.02:.1]];
tau = [tau, [.2:.2:1]];
tau = [tau, [2:.5:4]];
k2 = reshape(tau,5,4)';

TI = 0.001; 
time = 0:TI:dur;
figure;
whitebg([.8 .8 .8])
H1 = gcf; 
set(H1, 'position', positions{5})
for s = 1:numel(tau)
    response = 0;
    responseCDF = [];
%     keyboard
    for i = 1:numel(binaryClicks)
        response = [response, response(i) + binaryClicks(i)*1-response(i)*TI/tau(s)];
        responseCDF = [responseCDF, poisscdf(response(end),50*tau(s))];
        if response(end) < 0 
            response(end) = 0
        else
        end
    end 
    response(1) = [];
    
    LI(s).Responses = response/tau(s);
    LI(s).ResponsesCDF = responseCDF;
    subplot(5,5,s+5);
        hold on; scatter(time,LI(s).Responses, 1,[LI(s).ResponsesCDF', 1-abs(.5-LI(s).ResponsesCDF')/.5, 1-LI(s).ResponsesCDF']);  
        % Color scheme:
        % Blue: Likely lower than 50Hz
        % Green: Likely 50Hz 1-abs(.5-P_lower)/.5
        % Red: Likely higher than 50Hz
        l = line([changetime, changetime],[ylim]);
        l.LineStyle = '--'; l.Color = 'k';
        title(strcat("tau= ", num2str(tau(s))))
        text(3*tau(s),-1,'\uparrow 3\tau','FontSize',6)
        if s == 1
            ylabel({'Estimated click rate',strcat('(response/','\tau',')')})
            plot(time,LI(s).Responses,'k');  
        else
        end
end

subplot(5,5,[1:5])
    % Gaussian filter parameters for reverse correlation;
    krn_width = 0.05; %## .025 previously
    bin_size = 0.01;    % .01 default
    dx=ceil(krn_width/bin_size);
    krn=normpdf(-dx:dx,0,krn_width/bin_size); %##
    krn=(krn)/sum(krn)/bin_size;
    [y,x] = stats.spike_filter(0,clicktimes,krn,'pre', 0,'post',dur,'kernel_bin_size',0.01);
    plot(x,y,'LineWidth',3);
    YLIM = [ylim];
    hold on; stem(clicktimes, YLIM(2)*ones(size(clicktimes)),'--.y');
    hold on; l = line([changetime, changetime],[ylim]);
            l.LineStyle = '--'; l.Color = 'k';
    title('Leaky integration with multiple timescales of integration', 'FontSize', 18)
cmap = [linspace(0,1,64)', [zeros(16,1);linspace(0,1,16)';linspace(1,0,16)';zeros(16,1)], linspace(1,0,64)'];
H1.Colormap = cmap;
c= colorbar;
c.Position = [0.95 0.1097 0.0123 .82];
c.Label.String = 'Cumulative lower tail probability assuming 50Hz Poisson Clickrate';
c.Label.FontSize = 14;

%% Fig2: Weighted sum (average) of relevant integrators
close all
clear LI
% GenerateClicks('FreqTwo',100,'ChangeTime',2.5);

%     pairs = {'FreqOne'			50	; ...
%     'FreqTwo'                   100	; ...
%     'InitDelay'					0.5	; ...
%     'MeanChangeTime'            2.5 ; ...
%     'MaxChangeTime'             7.0 ; ...
%     'ResponseTime'              0.8 ; ...
%     'ChangeTime'                []  ; ...
%     }

tau = [];
tau = [tau, [.2:.2:1]];
k2 = reshape(tau,5,1)';

TI = 0.001; 
time = 0:TI:dur;
figure(2);
whitebg([.8 .8 .8])
H1 = gcf; 
set(H1, 'position', positions{5})
for s = 1:numel(tau)
    response = 0;
    responseCDF = [];
%     keyboard
    for i = 1:numel(binaryClicks)
        response = [response, response(i) + binaryClicks(i)*1-response(i)*TI/tau(s)];
        responseCDF = [responseCDF, poisscdf(response(end),50*tau(s))];
        if response(end) < 0 
            response(end) = 0
        else
        end
    end 
    response(1) = [];
    
    LI(s).Responses = response/tau(s);
    LI(s).ResponsesCDF = responseCDF;
    subplot(3,5,s+5);
        hold on; scatter(time,LI(s).Responses, 1,[LI(s).ResponsesCDF', 1-abs(.5-LI(s).ResponsesCDF')/.5, 1-LI(s).ResponsesCDF']);  
        % Color scheme:
        % Blue: Likely lower than 50Hz
        % Green: Likely 50Hz 1-abs(.5-P_lower)/.5
        % Red: Likely higher than 50Hz
        l = line([changetime, changetime],[ylim]);
        l.LineStyle = '--'; l.Color = 'k';
        title(strcat("tau= ", num2str(tau(s))))
        text(3*tau(s),-1,'\uparrow 3\tau','FontSize',6)
        if s == 1
            ylabel({'Estimated click rate',strcat('(response/','\tau',')')}) 
        else
        end
end

subplot(3,5,[1:5])
    % Gaussian filter parameters for reverse correlation;
    krn_width = 0.05; %## .025 previously
    bin_size = 0.01;    % .01 default
    dx=ceil(krn_width/bin_size);
    krn=normpdf(-dx:dx,0,krn_width/bin_size); %##
    krn=(krn)/sum(krn)/bin_size;
    [y,x] = stats.spike_filter(0,clicktimes,krn,'pre', 0,'post',dur,'kernel_bin_size',0.01);
    plot(x,y,'LineWidth',3);
    YLIM = [ylim];
    hold on; stem(clicktimes, YLIM(2)*ones(size(clicktimes)),'--.y');
    hold on; l = line([changetime, changetime],[ylim]);
            l.LineStyle = '--'; l.Color = 'k';
    title('Fixed weighted sum of integrators can be approximated with a single \tau', 'FontSize', 18)
    cmap = [linspace(0,1,64)', [zeros(16,1);linspace(0,1,16)';linspace(1,0,16)';zeros(16,1)], linspace(1,0,64)'];
    H1.Colormap = cmap;
    c= colorbar;
    c.Position = [0.95 0.1097 0.0123 .82];
    c.Label.String = 'Cumulative lower tail probability assuming 50Hz Poisson Clickrate';
    c.Label.FontSize = 14;

subplot(3,5,[11:15])
    meanResponse = mean([LI(1).Responses;LI(2).Responses;LI(3).Responses;LI(4).Responses;LI(5).Responses]);
    meanTau = mean(tau);
    responseCDF = zeros(size(meanResponse));
    for i = 1:numel(meanResponse)
        responseCDF(i) = poisscdf(meanResponse(i)*meanTau,50*meanTau); %Note meanResponse was expressed in click rate
        responseCDF3(i) = poisscdf(LI(3).Responses(i)*meanTau,50*meanTau);
    end
    
    hold on; scatter(time,meanResponse, 1,[responseCDF', 1-abs(.5-responseCDF')/.5, 1-responseCDF']);  
    hold on; l = line([changetime, changetime],[ylim]);
            l.LineStyle = '--'; l.Color = 'k';
    title(strcat('mean \tau =',num2str(meanTau)), 'FontSize', 16)
subplot(3,5,6)
    hold on; plot(time,meanResponse,'--k')
subplot(3,5,8)
    hold on; plot(time,meanResponse,'--k')
subplot(3,5,10)
    hold on; plot(time,meanResponse,'--k')
        
%% Explanation of how figs were generated
H2=figure (3); 
whitebg([1,1,1]);
set(0, 'defaultFigureColor', [0.9400    0.9400    0.9400])
set(H2, 'position', positions{5})
for s = 1:numel(tau)
    S= subplot(4,5,s);
        S.Color = [.94 .94 .94];
        hold on; [AX,Y1, Y2] = plotyy(time,LI(s).Responses, time,LI(s).ResponsesCDF);
%         Y1.LineStyle = '-';
        Y2.LineStyle = ':';
        title(strcat("tau= ", num2str(tau(s))))
end

% How can we normalize all responses so all integrators are on the same scale?
% We can z-score responses, but that would require statistics over an entire session's data
% Or! We could z-score responses from 50Hz clickrate data and z-score would
% directly inform us how far that click rate is from the mean.

% Response/k = Clickrate

%% Fig3: Random Noise added to leaky integrator  % Still working on this...
s = 1 * sqrt(TI);
tau = 0.6;
TI = 0.001; 
figure; 
noisyResponse = 0;
for z = 1:10
    for i = 1:numel(binaryClicks)
        noisyResponse = [noisyResponse, noisyResponse(i) + binaryClicks(i)*1-noisyResponse(i)*TI/tau + normrnd(0,s)];
        responseCDF = [responseCDF, poisscdf(noisyResponse(end),50*tau(s))];
        if response(end) < 0 
            response(end) = 0
        else
        end
    end     
        response(1) = [];
    
    hold on; scatter(time,noisyResponse, 1,[responsesCDF', 1-abs(.5-responsesCDF')/.5, 1-responsesCDF']); 
end
