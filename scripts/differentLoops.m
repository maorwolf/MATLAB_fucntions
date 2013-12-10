subs = [7:12 14:17 19 21 25:27];
i=1;
for sub = subs
    i
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency'])
    load dataorig
    cfg             = [];
    cfg.resamplefs  = 300;
    cfg.detrend     = 'no';
    dummy           = ft_resampledata(cfg, dataorig); 
    cfg             = [];
    cfg.channel     = 'MEG';
    comp_dummy      = ft_componentanalysis(cfg, dummy);
    save ica comp_dummy
    clear comp_dummy
    i = i + 1;
end

subs = [27 28];
for sub = subs
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(sub),'/1'])
    load datafinal
    % low frequencies
    cfgtfrl           = [];
    cfgtfrl.keeptrials= 'yes'
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 2:2:40; % frequency of interest of which the resolution is dependent on the timw window...
    % for 500ms we will have 2Hz resolution and the foi will be 2:2:40
    %cfgtfr.t_ftimwin = 4./cfgtfr.foi; % length of time window dependent on number of cycles we want...
    % (in this case - 4)
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = [-0.5:0.01:1.5];
    %cfgtfr.trials    = 1;
    cfgtfrl.channel   = 'MEG';
    %cfgtfr.tapsmofrq = 1;
    cfgtfrl.trials    = find(datafinal.cfg.trl(:,4)==110);
    cfgtfrl.trials    = [cfgtfrl.trials; find(datafinal.cfg.trl(:,4)==120)];
    wordSingleLow     = ft_freqanalysis(cfgtfrl, datafinal);
    cfgtfrl.trials    = find(datafinal.cfg.trl(:,4)==130);
    nonWordSingleLow  = ft_freqanalysis(cfgtfrl, datafinal);
    cfgtfrl.trials    = find(datafinal.cfg.trl(:,4)==140);
    cfgtfrl.trials    = [cfgtfrl.trials; find(datafinal.cfg.trl(:,4)==150)];
    wordFirstLow      = ft_freqanalysis(cfgtfrl, datafinal);
    cfgtfrl.trials    = find(datafinal.cfg.trl(:,4)==160);
    cfgtfrl.trials    = [cfgtfrl.trials; find(datafinal.cfg.trl(:,4)==170)];
    wordSecondLow     = ft_freqanalysis(cfgtfrl, datafinal);
    cfgtfrl.trials    = find(datafinal.cfg.trl(:,4)==180);
    nonWordFirstLow   = ft_freqanalysis(cfgtfrl, datafinal);
    cfgtfrl.trials    = find(datafinal.cfg.trl(:,4)==190);
    nonWordSecondLow  = ft_freqanalysis(cfgtfrl, datafinal);
    
    % high frequencies
    cfgtfrh           = [];
    cfgtfrh.keeptrials= 'yes'
    cfgtfrh.output    = 'pow';
    cfgtfrh.method    = 'mtmconvol';
    %cfgtfrh.taper    = 'hanning';
    cfgtfrh.pad       = 5;
    cfgtfrh.foi       = 40:2:150; % frequency of interest of which the resolution is dependent on the timw window...
    % for 500ms we will have 2Hz resolution and the foi will be 2:2:40
    %cfgtfr.t_ftimwin = 4./cfgtfr.foi; % length of time window dependent on number of cycles we want...
    % (in this case - 4)
    cfgtfrh.t_ftimwin = ones(length(cfgtfrh.foi))*0.2;
    cfgtfrh.toi       = [-0.5:0.01:1.5];
    %cfgtfr.trials    = 1;
    cfgtfrh.channel   = 'MEG';
    cfgtfrh.tapsmofrq = 15;
    cfgtfrh.trials    = find(datafinal.cfg.trl(:,4)==110);
    cfgtfrh.trials    = [cfgtfrh.trials; find(datafinal.cfg.trl(:,4)==120)];
    wordSingleHigh    = ft_freqanalysis(cfgtfrh, datafinal);
    cfgtfrh.trials    = find(datafinal.cfg.trl(:,4)==130);
    nonWordSingleHigh = ft_freqanalysis(cfgtfrh, datafinal);
    cfgtfrh.trials    = find(datafinal.cfg.trl(:,4)==140);
    cfgtfrh.trials    = [cfgtfrh.trials; find(datafinal.cfg.trl(:,4)==150)];
    wordFirstHigh     = ft_freqanalysis(cfgtfrh, datafinal);
    cfgtfrh.trials    = find(datafinal.cfg.trl(:,4)==160);
    cfgtfrh.trials    = [cfgtfrh.trials; find(datafinal.cfg.trl(:,4)==170)];
    wordSecondHigh    = ft_freqanalysis(cfgtfrh, datafinal);
    cfgtfrh.trials    = find(datafinal.cfg.trl(:,4)==180);
    nonWordFirstHigh  = ft_freqanalysis(cfgtfrh, datafinal);
    cfgtfrh.trials    = find(datafinal.cfg.trl(:,4)==190);
    nonWordSecondHigh = ft_freqanalysis(cfgtfrh, datafinal);
    
    
    save timeFrequency/TFtest wordSingleLow nonWordSingleLow wordFirstLow wordSecondLow...
        nonWordFirstLow nonWordSecondLow wordSingleHigh nonWordSingleHigh wordFirstHigh...
        wordSecondHigh nonWordFirstHigh nonWordSecondHigh
    clear all
end


%% ica for schizo project for low frequencies (1-40Hz)
load handel
subs = [14:17 19:21 23 24 27:29 31:37 39 41];
for i = subs
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1'])
    load dataorig
    cfg             = [];
    cfg.resamplefs  = 300;
    cfg.detrend     = 'no';
    dummy           = ft_resampledata(cfg, dataorig); % if you used 5.2 so change to datacln
    
    % run ica (it takes a long time have a break)
    cfg             = [];
    if i == 27 || i == 28
        cfg.channel = {'MEG','-A41'};
    else
        cfg.channel     = {'MEG'};
    end
    comp_dummy      = ft_componentanalysis(cfg, dummy);
    save ica comp_dummy
    clear dummy comp_dummy
end;
sound(y,Fs) 

