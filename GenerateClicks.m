function Y = GenerateClicks(varargin)    
% Y = GenerateClicks(varargin) 
% Varargin:
%     'FreqOne'			
%     'FreqTwo'                   
%     'InitDelay'                 
%     'MeanChangeTime'            
%     'ResponseTime'
%     'MaxChangeTime'

% Dependencies:
%     parseargs()

   global changetime  
    %% default varargin values:
    pairs = {'FreqOne'			50	; ...
    'FreqTwo'                   100	; ...
    'InitDelay'					0.5	; ...
    'MeanChangeTime'            2.5 ; ...
    'MaxChangeTime'             7.0 ; ...
    'ResponseTime'              0.8 ; ...
    'ChangeTime'                []  ; ...
    }; utils.parseargs(varargin, pairs);

    
    %% Generate Poisson Clicks
    % Create changetime and determine trial duration    
    if isempty(ChangeTime)
        changetime = random('exp',MeanChangeTime,1);
        while changetime < InitDelay || changetime > MaxChangeTime  
            changetime = random('exp',MeanChangeTime,1); % changetime
        end
    else
        changetime = ChangeTime;
    end
        dur = ResponseTime + changetime;

    % Generate Poisson Click train
        clicktimes = [];
        C_Time = 0; 
        while C_Time < changetime
            TI = random('exp',1/FreqOne);
            C_Time = C_Time+TI;
            clicktimes = [clicktimes C_Time]; 
        end
        clicktimes(end) = [];
        C_Time = changetime;
        while C_Time <= dur
            TI = random('exp',1/FreqTwo);
            C_Time = C_Time+TI;
            clicktimes = [clicktimes C_Time];
        end
        clicktimes(end)=[];
        binaryClicks = histc(clicktimes,[0:0.001:dur]);
    Y = clicktimes;
    assignin ('base', 'clicktimes', clicktimes)
    assignin ('base', 'changetime', changetime)
    assignin ('base', 'FreqOne', FreqOne)
    assignin ('base', 'FreqTwo', FreqTwo)
    assignin ('base', 'dur', dur)
    assignin ('base', 'binaryClicks', binaryClicks)
