%% 1. finding trial
clear all
clc
sub=12;
eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(sub),'/1'])
source='xc,hb,lf_c,rfhp0.1Hz';

conditions = [110 120 130 140 150 160 170 180 190];
% 110 - word, no repeats, high freq
% 120 - word, no repeats, low freq
% 130 - none word, no repeats
% 140 - word, first apperance, high freq
% 150 - word, first apperance, low freq
% 160 - word, second apperance, high freq
% 170 - word, second apperance, low freq
% 180 - none word, first repeat
% 190 - none word, second repeat

%% 2. define trials
cfg                         = [];
cfg.dataset                 = source;
cfg.trialdef.eventtype      = 'TRIGGER';
cfg.trialdef.eventvalue     = conditions;  %triggers are for different kinds of metaphors 
cfg.trialdef.prestim        = 0.5; % time before trigger onset
cfg.trialdef.poststim       = 1.5; % time after trigger onset
cfg.trialdef.offset         = -0.5; % defining the real zero: can be different than prestim
cfg.trialdef.visualtrig     = 'visafter'; % sync the trigger from E-prime with the visual trigger 
cfg.trialdef.visualtrigwin  = 0.2; % look for the 2048 from the visual trigger in the next 200 ms interval time window
cfg.trialfun                = 'BIUtrialfun'; % use the unique parameters of the Bar Ilan MEG
cfg.trialdef.rspwin         = 2.5; %wait for response for 2 seconds, else, report that there was no response
cfg                         = ft_definetrial(cfg);

% creating colume 7 with correct code
cfg.trl(1:length(cfg.trl),7) = 0;
for i=1:length(cfg.trl)
	if ((cfg.trl(i,4)==110) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1; 
    elseif ((cfg.trl(i,4)==120) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1; 
    elseif ((cfg.trl(i,4)==130) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1; 
    elseif ((cfg.trl(i,4)==140) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==150) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==160) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==170) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==180) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==190) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1; 
    end;
end;

%% 3. preprocessing for muscle artifact rejection
cfg.demean         = 'yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous     = 'yes';
cfg.baselinewindow = [-0.3,0];
cfg.hpfilter       = 'yes';
cfg.hpfreq         = 60;
cfg.channel        = {'MEG'}; 
dataorig           = ft_preprocessing(cfg);

%% 4. remove muscle artifact
cfg1.method        = 'summary'; %trial
datacln            = ft_rejectvisual(cfg1, dataorig);

% to see again
datacln            = ft_rejectvisual(cfg1, datacln);

% configure the channels
channels = 'MEG'; % channels = {'MEG','-A212'}; % channels = {'MEG','-A41'};
%% 5 Deleting the bad trials from the original data so you don't refilter the data
cfg.trl            = [];
cfg.trl            = datacln.sampleinfo;
cfg.trl(:,3)       = -509; % change according to your offset in samples!!!
cfg.trl(:,4:7)   = datacln.trialinfo;

%% 6 preprocessing original data
cfg.demean         = 'yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous     = 'yes';
cfg.baselinewindow = [-0.3,0];
cfg.hpfilter       = 'no';
cfg.bpfilter       = 'yes'; % apply bandpass filter (see one line below)
cfg.bpfreq         = [1 40]; % cfg.bpfreq         = [1 40];
cfg.channel        = channels; 
cfg.padding        = 10;
dataorig           = ft_preprocessing(cfg);
save dataorig dataorig
%% 7. ICA
%resampling data to speed up the ica
load handel % for playing the song at the end of the ICA

cfg             = [];
cfg.resamplefs  = 300;
cfg.detrend     = 'no';
dummy           = ft_resampledata(cfg, dataorig); % if you used 5.2 so change to datacln

% run ica (it takes a long time have a break)
cfg             = [];
cfg.channel     = channels;
comp_dummy      = ft_componentanalysis(cfg, dummy);
sound(y,Fs) % playing a song so I would know when it is done

% see the components and find the artifacts
cfgb            = [];
cfgb.layout     = '4D248.lay';
cfgb.channel    = {comp_dummy.label{1:10}};
cfgb.continuous ='no';
comppic         = ft_databrowser(cfgb,comp_dummy);

%% cool visualization for one component (e.g.,comp = 3) along trials and time (after resampling)  
seeOneComp(comp_dummy,14) % change the number of components you want to see

%% 8. run the ICA on the original data
cfg           = [];
cfg.topo      = comp_dummy.topo;
cfg.topolabel = comp_dummy.topolabel;
comp          = ft_componentanalysis(cfg, dataorig);

% remove the artifact components
cfg           = [];
cfg.component = [5 14]; % change
dataica       = ft_rejectcomponent(cfg, comp);

clear comp_dummy comppic comp dummy
%% 9. base line correction
dataica = correctBL(dataica,[-0.3 0]);

%% 10. trial by trial
cfg           = [];
cfg.method    = 'trial'; % 'channel'
cfg.channel   = {'MEG'};
cfg1.bpfilter = 'yes';
cfg1.bpfreq   = [1 40];
datafinal     = ft_rejectvisual(cfg, dataica);

save datafinal datafinal
%% 11. recreating the trl matrix and removing trials with errors
datafinal.cfg.trl(:,1:2) = datafinal.sampleinfo(:,1:2);
datafinal.cfg.trl(:,3)   = -509; % the offset
datafinal.cfg.trl(:,4:7) = datafinal.trialinfo;

datafinal.trial(find(datafinal.cfg.trl(:,7) == 0)) = [];
datafinal.time(find(datafinal.cfg.trl(:,7) == 0)) = [];
datafinal.cfg.trl(find(datafinal.cfg.trl(:,7) == 0),:) = [];
datafinal.sampleinfo = datafinal.cfg.trl(:,1:2);
datafinal.trialinfo = datafinal.cfg.trl(:,4:7);

% ----------------8<------------------8<-----------------8<----------------
%% 12. Time frequency analysis
% low frequencies
cfg               = [];
cfg.resamplefs    = 400;
cfg.detrend       = 'no';
cfg.feedback      = 'no';
datafinalresmpld  = ft_resampledata(cfg, datafinal);

cfgtfrl           = [];
cfgtfrl.output    = 'pow';
cfgtfrl.method    = 'mtmconvol';
cfgtfrl.taper     = 'hanning';
cfgtfrl.pad       = 5;
cfgtfrl.keeptrials= 'yes';
cfgtfrl.foi       = 2:1:40; % frequency of interest of which the resolution is dependent on the timw window...
cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
cfgtfrl.toi       = [-0.5:0.05:1.5];
cfgtfrl.channel   = {'MEG'};
cfgtfrl.trials    = find(datafinalresmpld.trialinfo(:,1)==110);
cfgtfrl.trials    = [cfgtfrl.trials; find(datafinalresmpld.trialinfo(:,1)==120)];
wordSingleLow     = ft_freqanalysis(cfgtfrl, datafinalresmpld);
cfgtfrl.trials    = find(datafinalresmpld.trialinfo(:,1)==130);
nonWordSingleLow  = ft_freqanalysis(cfgtfrl, datafinalresmpld);
cfgtfrl.trials    = find(datafinalresmpld.trialinfo(:,1)==140);
cfgtfrl.trials    = [cfgtfrl.trials; find(datafinalresmpld.trialinfo(:,1)==150)];
wordFirstLow      = ft_freqanalysis(cfgtfrl, datafinalresmpld);
cfgtfrl.trials    = find(datafinalresmpld.trialinfo(:,1)==160);
cfgtfrl.trials    = [cfgtfrl.trials; find(datafinalresmpld.trialinfo(:,1)==170)];
wordSecondLow     = ft_freqanalysis(cfgtfrl, datafinalresmpld);
cfgtfrl.trials    = find(datafinalresmpld.trialinfo(:,1)==180);
nonWordFirstLow   = ft_freqanalysis(cfgtfrl, datafinalresmpld);
cfgtfrl.trials    = find(datafinalresmpld.trialinfo(:,1)==190);
nonWordSecondLow  = ft_freqanalysis(cfgtfrl, datafinalresmpld);

% cfgtfrh           = [];
% cfgtfrh.output    = 'pow';
% cfgtfrh.keeptrials= 'yes';
% cfgtfrh.method    = 'mtmconvol';
% cfgtfrh.pad       = 5;
% cfgtfrh.foi       = 40:5:140;
% cfgtfrh.t_ftimwin = ones(length(cfgtfrh.foi))*0.2;
% cfgtfrh.toi       = [-0.5:0.05:1];
% cfgtfrh.channel   = {'MEG'};
% cfgtfrh.tapsmofrq = 15;
% cfgtfrh.trials    = find(datafinalresmpld.trialinfo(:,1)==110);
% cfgtfrh.trials    = [cfgtfrh.trials; find(datafinalresmpld.trialinfo(:,1)==120)];
% wordSingleHigh    = ft_freqanalysis(cfgtfrh, datafinalresmpld);
% cfgtfrh.trials    = find(datafinalresmpld.trialinfo(:,1)==130);
% nonWordSingleHigh = ft_freqanalysis(cfgtfrh, datafinalresmpld);
% cfgtfrh.trials    = find(datafinalresmpld.trialinfo(:,1)==140);
% cfgtfrh.trials    = [cfgtfrh.trials; find(datafinalresmpld.trialinfo(:,1)==150)];
% wordFirstHigh     = ft_freqanalysis(cfgtfrh, datafinalresmpld);
% cfgtfrh.trials    = find(datafinalresmpld.trialinfo(:,1)==160);
% cfgtfrh.trials    = [cfgtfrh.trials; find(datafinalresmpld.trialinfo(:,1)==170)];
% wordSecondHigh    = ft_freqanalysis(cfgtfrh, datafinalresmpld);
% cfgtfrh.trials    = find(datafinalresmpld.trialinfo(:,1)==180);
% nonWordFirstHigh  = ft_freqanalysis(cfgtfrh, datafinalresmpld);
% cfgtfrh.trials    = find(datafinalresmpld.trialinfo(:,1)==190);
% nonWordSecondHigh = ft_freqanalysis(cfgtfrh, datafinalresmpld);

mkdir('timeFrequency');
save timeFrequency/TFtestLow wordSingleLow nonWordSingleLow wordFirstLow wordSecondLow...
    nonWordFirstLow nonWordSecondLow 
% save timeFrequency/TFtestHigh wordSingleHigh nonWordSingleHigh wordFirstHigh...
%     wordSecondHigh nonWordFirstHigh nonWordSecondHigh

clear all
load timeFrequency/TFtestLow
% load timeFrequency/TFtestHigh
%% 13 ploting
cfg              = [];
cfg.baseline     = [-0.5 0]; 
cfg.baselinetype = 'absolute';
%cfg.zlim        = [-3*10^(-27) 1.5*10^(-27)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
subplot(3,2,1)
ft_singleplotTFR(cfg, wordSingleLow);
title('single presentation of a word')
subplot(3,2,2)
ft_singleplotTFR(cfg, wordFirstLow);
title('first presentation of a word')
subplot(3,2,3)
ft_singleplotTFR(cfg, wordSecondLow);
title('second presentation of a word')
subplot(3,2,4)
ft_singleplotTFR(cfg, nonWordSingleLow);
title('single presentation of a non-word')
subplot(3,2,5)
ft_singleplotTFR(cfg, nonWordFirstLow);
title('first presentation of a non-word')
subplot(3,2,6)
ft_singleplotTFR(cfg, nonWordSecondLow);
title('second presentation of a non-word')

% figure;
% subplot(3,2,1)
% ft_singleplotTFR(cfg, wordSingleHigh);
% title('single presentation of a word')
% subplot(3,2,2)
% ft_singleplotTFR(cfg, wordFirstHigh);
% title('first presentation of a word')
% subplot(3,2,3)
% ft_singleplotTFR(cfg, wordSecondHigh);
% title('second presentation of a word')
% subplot(3,2,4)
% ft_singleplotTFR(cfg, nonWordSingleHigh);
% title('single presentation of a non-word')
% subplot(3,2,5)
% ft_singleplotTFR(cfg, nonWordFirstHigh);
% title('first presentation of a non-word')
% subplot(3,2,6)
% ft_singleplotTFR(cfg, nonWordSecondHigh);
% title('second presentation of a non-word')

%% 14 grand averag 
clear all
subsSZ = [14 16 17 19 21 23 24 27:29 31 33:35 37];
for i = subsSZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/timeFrequency/TFtestLow'])
    
        cfg=[];
        cfg.baseline     = [-0.3 0];
        cfg.baselinetype = 'absolute';
        nonWordFirstBL=ft_freqbaseline(cfg,nonWordFirstLow);
        nonWordFirstBLdesc=ft_freqdescriptives([],nonWordFirstBL);
        nonWordSecondBL=ft_freqbaseline(cfg,nonWordSecondLow);
        nonWordSecondBLdesc=ft_freqdescriptives([],nonWordSecondBL);
        nonWordSingleBL=ft_freqbaseline(cfg,nonWordSingleLow);
        nonWordSingleBLdesc=ft_freqdescriptives([],nonWordSingleBL);
        wordFirstBL=ft_freqbaseline(cfg,wordFirstLow);
        wordFirstBLdesc=ft_freqdescriptives([],wordFirstBL);
        wordSecondBL=ft_freqbaseline(cfg,wordSecondLow);
        wordSecondBLdesc=ft_freqdescriptives([],wordSecondBL);
        wordSingleBL=ft_freqbaseline(cfg,wordSingleLow);
        wordSingleBLdesc=ft_freqdescriptives([],wordSingleBL);
        
        clear cfg nonWordFirstLow nonWordFirstBL nonWordSecondLow nonWordSecondBL nonWordSingleLow nonWordSingleBL ...
            wordFirstLow wordFirstBL wordSecondLow wordSecondBL wordSingleLow wordSingleBL
          
    %eval(['sub',num2str(i),'nonWordFirstHigh = nonWordFirstHigh;']);
    eval(['sub',num2str(i),'nonWordFirstBLdesc = ft_freqdescriptives([], nonWordFirstBLdesc);']);
    %eval(['sub',num2str(i),'nonWordSecondHigh = nonWordSecondHigh;']);
    eval(['sub',num2str(i),'nonWordSecondBLdesc = ft_freqdescriptives([], nonWordSecondBLdesc);']);
    %eval(['sub',num2str(i),'nonWordSingleHigh = nonWordSingleHigh;']);
    eval(['sub',num2str(i),'nonWordSingleBLdesc = ft_freqdescriptives([], nonWordSingleBLdesc);']);
    %eval(['sub',num2str(i),'wordFirstHigh = wordFirstHigh;']);
    eval(['sub',num2str(i),'wordFirstBLdesc = ft_freqdescriptives([], wordFirstBLdesc);']);
    %eval(['sub',num2str(i),'wordSecondHigh = wordSecondHigh;']);
    eval(['sub',num2str(i),'wordSecondBLdesc = ft_freqdescriptives([], wordSecondBLdesc);']);
    %eval(['sub',num2str(i),'wordSingleHigh = wordSingleHigh;']);
    eval(['sub',num2str(i),'wordSingleBLdesc = ft_freqdescriptives([], wordSingleBLdesc);']);
    
    clear nonWordFirstBLdesc nonWordSecondBLdesc nonWordSingleBLdesc wordFirstBLdesc wordSecondBLdesc wordSingleBLdesc
end;

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG'};
cfg.parameter      = 'powspctrm';

nonWordFirstSZ = ft_freqgrandaverage(cfg, sub14nonWordFirstBLdesc, sub16nonWordFirstBLdesc,...
    sub17nonWordFirstBLdesc, sub19nonWordFirstBLdesc, sub21nonWordFirstBLdesc, sub23nonWordFirstBLdesc,...
    sub24nonWordFirstBLdesc, sub27nonWordFirstBLdesc, sub28nonWordFirstBLdesc, sub29nonWordFirstBLdesc,...
    sub31nonWordFirstBLdesc, sub33nonWordFirstBLdesc, sub34nonWordFirstBLdesc, sub35nonWordFirstBLdesc,...
    sub37nonWordFirstBLdesc);
clear sub14nonWordFirstBLdesc sub16nonWordFirstBLdesc sub17nonWordFirstBLdesc sub19nonWordFirstBLdesc...
    sub21nonWordFirstBLdesc sub23nonWordFirstBLdesc sub24nonWordFirstBLdesc sub29nonWordFirstBLdesc...
    sub27nonWordFirstBLdesc sub28nonWordFirstBLdesc sub31nonWordFirstBLdesc sub33nonWordFirstBLdesc...
    sub34nonWordFirstBLdesc sub35nonWordFirstBLdesc sub37nonWordFirstBLdesc

nonWordSecondSZ = ft_freqgrandaverage(cfg, sub14nonWordSecondBLdesc, sub16nonWordSecondBLdesc,...
    sub17nonWordSecondBLdesc, sub19nonWordSecondBLdesc, sub21nonWordSecondBLdesc, sub23nonWordSecondBLdesc,...
    sub24nonWordSecondBLdesc, sub27nonWordSecondBLdesc, sub28nonWordSecondBLdesc, sub29nonWordSecondBLdesc,...
    sub31nonWordSecondBLdesc, sub33nonWordSecondBLdesc, sub34nonWordSecondBLdesc, sub35nonWordSecondBLdesc,...
    sub37nonWordSecondBLdesc);
clear sub14nonWordSecondBLdesc sub16nonWordSecondBLdesc sub17nonWordSecondBLdesc sub19nonWordSecondBLdesc...
    sub21nonWordSecondBLdesc sub23nonWordSecondBLdesc sub24nonWordSecondBLdesc sub29nonWordSecondBLdesc...
    sub27nonWordSecondBLdesc sub28nonWordSecondBLdesc sub31nonWordSecondBLdesc sub33nonWordSecondBLdesc...
    sub34nonWordSecondBLdesc sub35nonWordSecondBLdesc sub37nonWordSecondBLdesc

nonWordSingleSZ = ft_freqgrandaverage(cfg, sub14nonWordSingleBLdesc, sub16nonWordSingleBLdesc,...
    sub17nonWordSingleBLdesc, sub19nonWordSingleBLdesc, sub21nonWordSingleBLdesc, sub23nonWordSingleBLdesc,...
    sub24nonWordSingleBLdesc, sub27nonWordSingleBLdesc, sub28nonWordSingleBLdesc, sub29nonWordSingleBLdesc,...
    sub31nonWordSingleBLdesc, sub33nonWordSingleBLdesc, sub34nonWordSingleBLdesc, sub35nonWordSingleBLdesc,...
    sub37nonWordSingleBLdesc);
clear sub14nonWordSingleBLdesc sub16nonWordSingleBLdesc sub17nonWordSingleBLdesc sub19nonWordSingleBLdesc...
    sub21nonWordSingleBLdesc sub23nonWordSingleBLdesc sub24nonWordSingleBLdesc sub29nonWordSingleBLdesc...
    sub27nonWordSingleBLdesc sub28nonWordSingleBLdesc sub31nonWordSingleBLdesc sub33nonWordSingleBLdesc...
    sub34nonWordSingleBLdesc sub35nonWordSingleBLdesc sub37nonWordSingleBLdesc

wordFirstSZ = ft_freqgrandaverage(cfg, sub14wordFirstBLdesc, sub16wordFirstBLdesc,...
    sub17wordFirstBLdesc, sub19wordFirstBLdesc, sub21wordFirstBLdesc, sub23wordFirstBLdesc,...
    sub24wordFirstBLdesc, sub27wordFirstBLdesc, sub28wordFirstBLdesc, sub29wordFirstBLdesc,...
    sub31wordFirstBLdesc, sub33wordFirstBLdesc, sub34wordFirstBLdesc, sub35wordFirstBLdesc,...
    sub37wordFirstBLdesc);
clear sub14wordFirstBLdesc sub16wordFirstBLdesc sub17wordFirstBLdesc sub19wordFirstBLdesc...
    sub21wordFirstBLdesc sub23wordFirstBLdesc sub24wordFirstBLdesc sub29wordFirstBLdesc...
    sub27wordFirstBLdesc sub28wordFirstBLdesc sub31wordFirstBLdesc sub33wordFirstBLdesc...
    sub34wordFirstBLdesc sub35wordFirstBLdesc sub37wordFirstBLdesc

wordSecondSZ = ft_freqgrandaverage(cfg, sub14wordSecondBLdesc, sub16wordSecondBLdesc,...
    sub17wordSecondBLdesc, sub19wordSecondBLdesc, sub21wordSecondBLdesc, sub23wordSecondBLdesc,...
    sub24wordSecondBLdesc, sub27wordSecondBLdesc, sub28wordSecondBLdesc, sub29wordSecondBLdesc, ...
    sub31wordSecondBLdesc, sub33wordSecondBLdesc, sub34wordSecondBLdesc, sub35wordSecondBLdesc,...
    sub37wordSecondBLdesc);
clear sub14wordSecondBLdesc sub16wordSecondBLdesc sub17wordSecondBLdesc sub19wordSecondBLdesc...
    sub21wordSecondBLdesc sub23wordSecondBLdesc sub24wordSecondBLdesc sub29wordSecondBLdesc...
    sub27wordSecondBLdesc sub28wordSecondBLdesc sub31wordSecondBLdesc sub33wordSecondBLdesc...
    sub34wordSecondBLdesc sub35wordSecondBLdesc sub37wordSecondBLdesc

wordSingleSZ = ft_freqgrandaverage(cfg, sub14wordSingleBLdesc, sub16wordSingleBLdesc,...
    sub17wordSingleBLdesc, sub19wordSingleBLdesc, sub21wordSingleBLdesc, sub23wordSingleBLdesc,...
    sub24wordSingleBLdesc, sub27wordSingleBLdesc, sub28wordSingleBLdesc, sub29wordSingleBLdesc,...
    sub31wordSingleBLdesc, sub33wordSingleBLdesc, sub34wordSingleBLdesc, sub35wordSingleBLdesc,...
    sub37wordSingleBLdesc);
clear sub14wordSingleBLdesc sub16wordSingleBLdesc sub17wordSingleBLdesc sub19wordSingleBLdesc...
    sub21wordSingleBLdesc sub23wordSingleBLdesc sub24wordSingleBLdesc sub29wordSingleBLdesc...
    sub27wordSingleBLdesc sub28wordSingleBLdesc sub31wordSingleBLdesc sub33wordSingleBLdesc...
    sub34wordSingleBLdesc sub35wordSingleBLdesc sub37wordSingleBLdesc

cd /home/meg/Data/Maor/SchizoProject/Subjects
clear subsSZ cfg i
save TFgvSZLow
clear all
% ----------------------8<-----------------8<-------------------8<---------------------
clear all
subsCon = [0:3 5:9 12 15 20 32 36 39 41];
for i = subsCon
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/timeFrequency/TFtestLow'])
    
        cfg=[];
        cfg.baseline     = [-0.3 0];
        cfg.baselinetype = 'absolute';
        nonWordFirstBL=ft_freqbaseline(cfg,nonWordFirstLow);
        nonWordFirstBLdesc=ft_freqdescriptives([],nonWordFirstBL);
        nonWordSecondBL=ft_freqbaseline(cfg,nonWordSecondLow);
        nonWordSecondBLdesc=ft_freqdescriptives([],nonWordSecondBL);
        nonWordSingleBL=ft_freqbaseline(cfg,nonWordSingleLow);
        nonWordSingleBLdesc=ft_freqdescriptives([],nonWordSingleBL);
        wordFirstBL=ft_freqbaseline(cfg,wordFirstLow);
        wordFirstBLdesc=ft_freqdescriptives([],wordFirstBL);
        wordSecondBL=ft_freqbaseline(cfg,wordSecondLow);
        wordSecondBLdesc=ft_freqdescriptives([],wordSecondBL);
        wordSingleBL=ft_freqbaseline(cfg,wordSingleLow);
        wordSingleBLdesc=ft_freqdescriptives([],wordSingleBL);
        
        clear cfg nonWordFirstLow nonWordFirstBL nonWordSecondLow nonWordSecondBL nonWordSingleLow nonWordSingleBL ...
            wordFirstLow wordFirstBL wordSecondLow wordSecondBL wordSingleLow wordSingleBL
        
    %eval(['sub',num2str(i),'nonWordFirstHigh = nonWordFirstHigh;']);
    eval(['sub',num2str(i),'nonWordFirstBLdesc = ft_freqdescriptives([], nonWordFirstBLdesc);']);
    %eval(['sub',num2str(i),'nonWordSecondHigh = nonWordSecondHigh;']);
    eval(['sub',num2str(i),'nonWordSecondBLdesc = ft_freqdescriptives([], nonWordSecondBLdesc);']);
    %eval(['sub',num2str(i),'nonWordSingleHigh = nonWordSingleHigh;']);
    eval(['sub',num2str(i),'nonWordSingleBLdesc = ft_freqdescriptives([], nonWordSingleBLdesc);']);
    %eval(['sub',num2str(i),'wordFirstHigh = wordFirstHigh;']);
    eval(['sub',num2str(i),'wordFirstBLdesc = ft_freqdescriptives([], wordFirstBLdesc);']);
    %eval(['sub',num2str(i),'wordSecondHigh = wordSecondHigh;']);
    eval(['sub',num2str(i),'wordSecondBLdesc = ft_freqdescriptives([], wordSecondBLdesc);']);
    %eval(['sub',num2str(i),'wordSingleHigh = wordSingleHigh;']);
    eval(['sub',num2str(i),'wordSingleBLdesc = ft_freqdescriptives([], wordSingleBLdesc);']);
    
    clear nonWordFirstBLdesc nonWordSecondBLdesc nonWordSingleBLdesc wordFirstBLdesc wordSecondBLdesc wordSingleBLdesc
end;

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG'};
cfg.parameter      = 'powspctrm';

nonWordFirstCon = ft_freqgrandaverage(cfg, sub0nonWordFirstBLdesc, sub1nonWordFirstBLdesc,...
    sub2nonWordFirstBLdesc, sub3nonWordFirstBLdesc, sub5nonWordFirstBLdesc, sub6nonWordFirstBLdesc,...
    sub7nonWordFirstBLdesc, sub8nonWordFirstBLdesc, sub9nonWordFirstBLdesc, sub12nonWordFirstBLdesc,...
    sub15nonWordFirstBLdesc, sub20nonWordFirstBLdesc, sub32nonWordFirstBLdesc, sub36nonWordFirstBLdesc,...
    sub39nonWordFirstBLdesc, sub41nonWordFirstBLdesc);
clear sub0nonWordFirstBLdesc sub1nonWordFirstBLdesc sub2nonWordFirstBLdesc sub3nonWordFirstBLdesc...
    sub5nonWordFirstBLdesc sub6nonWordFirstBLdesc sub7nonWordFirstBLdesc sub8nonWordFirstBLdesc...
    sub9nonWordFirstBLdesc sub12nonWordFirstBLdesc sub15nonWordFirstBLdesc sub20nonWordFirstBLdesc...
    sub32nonWordFirstBLdesc sub36nonWordFirstBLdesc sub39nonWordFirstBLdesc sub41nonWordFirstBLdesc

nonWordSecondCon = ft_freqgrandaverage(cfg, sub0nonWordSecondBLdesc, sub1nonWordSecondBLdesc,...
    sub2nonWordSecondBLdesc, sub3nonWordSecondBLdesc, sub5nonWordSecondBLdesc, sub6nonWordSecondBLdesc,...
    sub7nonWordSecondBLdesc, sub8nonWordSecondBLdesc, sub9nonWordSecondBLdesc, sub12nonWordSecondBLdesc,...
    sub15nonWordSecondBLdesc, sub20nonWordSecondBLdesc, sub32nonWordSecondBLdesc, sub36nonWordSecondBLdesc,...
    sub39nonWordSecondBLdesc, sub41nonWordSecondBLdesc);
clear sub0nonWordSecondBLdesc sub1nonWordSecondBLdesc sub2nonWordSecondBLdesc sub3nonWordSecondBLdesc...
    sub5nonWordSecondBLdesc sub6nonWordSecondBLdesc sub7nonWordSecondBLdesc sub8nonWordSecondBLdesc...
    sub9nonWordSecondBLdesc sub12nonWordSecondBLdesc sub15nonWordSecondBLdesc sub20nonWordSecondBLdesc...
    sub32nonWordSecondBLdesc sub36nonWordSecondBLdesc sub39nonWordSecondBLdesc sub41nonWordSecondBLdesc

nonWordSingleCon = ft_freqgrandaverage(cfg, sub0nonWordSingleBLdesc, sub1nonWordSingleBLdesc,...
    sub2nonWordSingleBLdesc, sub3nonWordSingleBLdesc, sub5nonWordSingleBLdesc, sub6nonWordSingleBLdesc,...
    sub7nonWordSingleBLdesc, sub8nonWordSingleBLdesc, sub9nonWordSingleBLdesc, sub12nonWordSingleBLdesc,...
    sub15nonWordSingleBLdesc, sub20nonWordSingleBLdesc, sub32nonWordSingleBLdesc, sub36nonWordSingleBLdesc,...
    sub39nonWordSingleBLdesc, sub41nonWordSingleBLdesc);
clear sub0nonWordSingleBLdesc sub1nonWordSingleBLdesc sub2nonWordSingleBLdesc sub3nonWordSingleBLdesc...
    sub5nonWordSingleBLdesc sub6nonWordSingleBLdesc sub7nonWordSingleBLdesc sub8nonWordSingleBLdesc...
    sub9nonWordSingleBLdesc sub12nonWordSingleBLdesc sub15nonWordSingleBLdesc sub20nonWordSingleBLdesc...
    sub32nonWordSingleBLdesc sub36nonWordSingleBLdesc sub39nonWordSingleBLdesc sub41nonWordSingleBLdesc

wordFirstCon = ft_freqgrandaverage(cfg, sub0wordFirstBLdesc, sub1wordFirstBLdesc,...
    sub2wordFirstBLdesc, sub3wordFirstBLdesc, sub5wordFirstBLdesc, sub6wordFirstBLdesc,...
    sub7wordFirstBLdesc, sub8wordFirstBLdesc, sub9wordFirstBLdesc, sub12wordFirstBLdesc,...
    sub15wordFirstBLdesc, sub20wordFirstBLdesc, sub32wordFirstBLdesc, sub36wordFirstBLdesc,...
    sub39wordFirstBLdesc, sub41wordFirstBLdesc);
clear sub0wordFirstBLdesc sub1wordFirstBLdesc sub2wordFirstBLdesc sub3wordFirstBLdesc...
    sub5wordFirstBLdesc sub6wordFirstBLdesc sub7wordFirstBLdesc sub8wordFirstBLdesc...
    sub9wordFirstBLdesc sub12wordFirstBLdesc sub15wordFirstBLdesc sub20wordFirstBLdesc...
    sub32wordFirstBLdesc sub36wordFirstBLdesc sub39wordFirstBLdesc sub41wordFirstBLdesc

wordSecondCon = ft_freqgrandaverage(cfg, sub0wordSecondBLdesc, sub1wordSecondBLdesc,...
    sub2wordSecondBLdesc, sub3wordSecondBLdesc, sub5wordSecondBLdesc, sub6wordSecondBLdesc,...
    sub7wordSecondBLdesc, sub8wordSecondBLdesc, sub9wordSecondBLdesc, sub12wordSecondBLdesc,...
    sub15wordSecondBLdesc, sub20wordSecondBLdesc, sub32wordSecondBLdesc, sub36wordSecondBLdesc,...
    sub39wordSecondBLdesc, sub41wordSecondBLdesc);
clear sub0wordSecondBLdesc sub1wordSecondBLdesc sub2wordSecondBLdesc sub3wordSecondBLdesc...
    sub5wordSecondBLdesc sub6wordSecondBLdesc sub7wordSecondBLdesc sub8wordSecondBLdesc...
    sub9wordSecondBLdesc sub12wordSecondBLdesc sub15wordSecondBLdesc sub20wordSecondBLdesc...
    sub32wordSecondBLdesc sub36wordSecondBLdesc sub39wordSecondBLdesc sub41wordSecondBLdesc

wordSingleCon = ft_freqgrandaverage(cfg, sub0wordSingleBLdesc, sub1wordSingleBLdesc,...
    sub2wordSingleBLdesc, sub3wordSingleBLdesc, sub5wordSingleBLdesc, sub6wordSingleBLdesc,...
    sub7wordSingleBLdesc, sub8wordSingleBLdesc, sub9wordSingleBLdesc, sub12wordSingleBLdesc,...
    sub15wordSingleBLdesc, sub20wordSingleBLdesc, sub32wordSingleBLdesc, sub36wordSingleBLdesc,...
    sub39wordSingleBLdesc, sub41wordSingleBLdesc);
clear sub0wordSingleBLdesc sub1wordSingleBLdesc sub2wordSingleBLdesc sub3wordSingleBLdesc...
    sub5wordSingleBLdesc sub6wordSingleBLdesc sub7wordSingleBLdesc sub8wordSingleBLdesc...
    sub9wordSingleBLdesc sub12wordSingleBLdesc sub15wordSingleBLdesc sub20wordSingleBLdesc...
    sub32wordSingleBLdesc sub36wordSingleBLdesc sub39wordSingleBLdesc sub41wordSingleBLdesc

cd /home/meg/Data/Maor/SchizoProject/Subjects
clear subsCon cfg i
save TFgvConLow
clear all
%% --------- the end ---------
load TFgvConLow
load TFgvSZLow

% ploting SZ
cfg              = [];
%cfg.zlim        = [-10*10^(-28) 8*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
%ft_multiplotTFR(cfg, TF102l);
subplot(2,3,1)
ft_singleplotTFR(cfg, wordSingleSZ);
title('single word SZ')
subplot(2,3,2)
ft_singleplotTFR(cfg, wordFirstSZ);
title('first word SZ')
subplot(2,3,3)
ft_singleplotTFR(cfg, wordSecondSZ);
title('second word SZ')
subplot(2,3,4)
ft_singleplotTFR(cfg, nonWordSingleSZ);
title('single non-word SZ')
subplot(2,3,5)
ft_singleplotTFR(cfg, nonWordFirstSZ);
title('first non-word SZ')
subplot(2,3,6)
ft_singleplotTFR(cfg, nonWordSecondSZ);
title('second non-word SZ')

% SZ vs. Con words low frequencies
cfg              = [];
%cfg.zlim        = [-20*10^(-28) 8*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
subplot(2,3,1)
ft_singleplotTFR(cfg, wordSingleSZ);
title('single word SZ')
subplot(2,3,2)
ft_singleplotTFR(cfg, wordFirstSZ);
title('first word SZ')
subplot(2,3,3)
ft_singleplotTFR(cfg, wordSecondSZ);
title('second word SZ')
subplot(2,3,4)
ft_singleplotTFR(cfg, wordSingleCon);
title('single word Control')
subplot(2,3,5)
ft_singleplotTFR(cfg, wordFirstCon);
title('first word Control')
subplot(2,3,6)
ft_singleplotTFR(cfg, wordSecondCon);
title('second word Control')

cfg              = [];
cfg.baseline     = [-0.5 0]; 
cfg.baselinetype = 'absolute';
cfg.zlim        = [-20*10^(-28) 8*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

% SZ vs. Con non-words low frequencies
figure;
subplot(2,3,1)
ft_singleplotTFR(cfg, nonWordSingleLowSZ);
title('single non-word SZ')
subplot(2,3,2)
ft_singleplotTFR(cfg, nonWordFirstLowSZ);
title('first non-word SZ')
subplot(2,3,3)
ft_singleplotTFR(cfg, nonWordSecondLowSZ);
title('second non-word SZ')
subplot(2,3,4)
ft_singleplotTFR(cfg, nonWordSingleLowCon);
title('single non-word Control')
subplot(2,3,5)
ft_singleplotTFR(cfg, nonWordFirstLowCon);
title('first non-word Control')
subplot(2,3,6)
ft_singleplotTFR(cfg, nonWordSecondLowCon);
title('second non-word Control')

%%  statistics
% comp1 (t: 0.042-0.247 ; f: 2-7)
wordFirstLowConComp1 = mean(mean(mean(wordFirstLowCon.powspctrm(:,:,1:6,12:16),2),3),4);
wordFirstLowSZComp1 = mean(mean(mean(wordFirstLowSZ.powspctrm(:,:,1:6,12:16),2),3),4);
nonWordFirstLowConComp1 = mean(mean(mean(nonWordFirstLowCon.powspctrm(:,:,1:6,12:16),2),3),4);
nonWordFirstLowSZComp1 = mean(mean(mean(nonWordFirstLowSZ.powspctrm(:,:,1:6,12:16),2),3),4);

wordSingleLowConComp1 = mean(mean(mean(wordSingleLowCon.powspctrm(:,:,1:6,12:16),2),3),4);
wordSingleLowSZComp1 = mean(mean(mean(wordSingleLowSZ.powspctrm(:,:,1:6,12:16),2),3),4);
nonWordSingleLowConComp1 = mean(mean(mean(nonWordSingleLowCon.powspctrm(:,:,1:6,12:16),2),3),4);
nonWordSingleLowSZComp1 = mean(mean(mean(nonWordSingleLowSZ.powspctrm(:,:,1:6,12:16),2),3),4);

wordSecondLowConComp1 = mean(mean(mean(wordSecondLowCon.powspctrm(:,:,1:6,12:16),2),3),4);
wordSecondLowSZComp1 = mean(mean(mean(wordSecondLowSZ.powspctrm(:,:,1:6,12:16),2),3),4);
nonWordSecondLowConComp1 = mean(mean(mean(nonWordSecondLowCon.powspctrm(:,:,1:6,12:16),2),3),4);
nonWordSecondLowSZComp1 = mean(mean(mean(nonWordSecondLowSZ.powspctrm(:,:,1:6,12:16),2),3),4);
%% comp2 (t: 0.3-0.6 ; f: 7-11)
wordFirstLowConComp2 = mean(mean(mean(wordFirstLowCon.powspctrm(:,:,6:10,17:21),2),3),4);
wordFirstLowSZComp2 = mean(mean(mean(wordFirstLowSZ.powspctrm(:,:,6:10,17:21),2),3),4);
nonWordFirstLowConComp2 = mean(mean(mean(nonWordFirstLowCon.powspctrm(:,:,6:10,17:21),2),3),4);
nonWordFirstLowSZComp2 = mean(mean(mean(nonWordFirstLowSZ.powspctrm(:,:,6:10,17:21),2),3),4);

wordSingleLowConComp2 = mean(mean(mean(wordSingleLowCon.powspctrm(:,:,6:10,17:21),2),3),4);
wordSingleLowSZComp2 = mean(mean(mean(wordSingleLowSZ.powspctrm(:,:,6:10,17:21),2),3),4);
nonWordSingleLowConComp2 = mean(mean(mean(nonWordSingleLowCon.powspctrm(:,:,6:10,17:21),2),3),4);
nonWordSingleLowSZComp2 = mean(mean(mean(nonWordSingleLowSZ.powspctrm(:,:,6:10,17:21),2),3),4);

wordSecondLowConComp2 = mean(mean(mean(wordSecondLowCon.powspctrm(:,:,6:10,17:21),2),3),4);
wordSecondLowSZComp2 = mean(mean(mean(wordSecondLowSZ.powspctrm(:,:,6:10,17:21),2),3),4);
nonWordSecondLowConComp2 = mean(mean(mean(nonWordSecondLowCon.powspctrm(:,:,6:10,17:21),2),3),4);
nonWordSecondLowSZComp2 = mean(mean(mean(nonWordSecondLowSZ.powspctrm(:,:,6:10,17:21),2),3),4);
%% comp3 (t: 0.4-0.9 ; 2-4)
wordFirstLowConComp3 = mean(mean(mean(wordFirstLowCon.powspctrm(:,:,1:3,19:29),2),3),4);
wordFirstLowSZComp3 = mean(mean(mean(wordFirstLowSZ.powspctrm(:,:,1:3,19:29),2),3),4);
nonWordFirstLowConComp3 = mean(mean(mean(nonWordFirstLowCon.powspctrm(:,:,1:3,19:29),2),3),4);
nonWordFirstLowSZComp3 = mean(mean(mean(nonWordFirstLowSZ.powspctrm(:,:,1:3,19:29),2),3),4);

wordSingleLowConComp3 = mean(mean(mean(wordSingleLowCon.powspctrm(:,:,1:3,19:29),2),3),4);
wordSingleLowSZComp3 = mean(mean(mean(wordSingleLowSZ.powspctrm(:,:,1:3,19:29),2),3),4);
nonWordSingleLowConComp3 = mean(mean(mean(nonWordSingleLowCon.powspctrm(:,:,1:3,19:29),2),3),4);
nonWordSingleLowSZComp3 = mean(mean(mean(nonWordSingleLowSZ.powspctrm(:,:,1:3,19:29),2),3),4);

wordSecondLowConComp3 = mean(mean(mean(wordSecondLowCon.powspctrm(:,:,1:3,19:29),2),3),4);
wordSecondLowSZComp3 = mean(mean(mean(wordSecondLowSZ.powspctrm(:,:,1:3,19:29),2),3),4);
nonWordSecondLowConComp3 = mean(mean(mean(nonWordSecondLowCon.powspctrm(:,:,1:3,19:29),2),3),4);
nonWordSecondLowSZComp3 = mean(mean(mean(nonWordSecondLowSZ.powspctrm(:,:,1:3,19:29),2),3),4);
%% matrix
TF4SPSSComp1 = [wordSingleLowSZComp1,wordFirstLowSZComp1,wordSecondLowSZComp1,...
    nonWordSingleLowSZComp1,nonWordFirstLowSZComp1,nonWordSecondLowSZComp1;...
    wordSingleLowConComp1,wordFirstLowConComp1,wordSecondLowConComp1,...
    nonWordSingleLowConComp1,nonWordFirstLowConComp1,nonWordSecondLowConComp1];
TF4SPSSComp1=TF4SPSSComp1.*10^27;

TF4SPSSComp2 = [wordSingleLowSZComp2,wordFirstLowSZComp2,wordSecondLowSZComp2,...
    nonWordSingleLowSZComp2,nonWordFirstLowSZComp2,nonWordSecondLowSZComp2;...
    wordSingleLowConComp2,wordFirstLowConComp2,wordSecondLowConComp2,...
    nonWordSingleLowConComp2,nonWordFirstLowConComp2,nonWordSecondLowConComp2];
TF4SPSSComp2=TF4SPSSComp2.*10^27;

TF4SPSSComp3 = [wordSingleLowSZComp3,wordFirstLowSZComp3,wordSecondLowSZComp3,...
    nonWordSingleLowSZComp3,nonWordFirstLowSZComp3,nonWordSecondLowSZComp3;...
    wordSingleLowConComp3,wordFirstLowConComp3,wordSecondLowConComp3,...
    nonWordSingleLowConComp3,nonWordFirstLowConComp3,nonWordSecondLowConComp3];
TF4SPSSComp3=TF4SPSSComp3.*10^27;
%%
clear stat
cd /home/meg/Data/Maor/Hypnosis/Subjects

cfg = [];
cfg.channel          = {'MEG'};
cfg.latency          = [0.05 0.2];
cfg.frequency        = [39 45.4];
cfg.avgoverfreq      = 'yes';
cfg.avgovertime      = 'yes';
cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
cfg.numrandomization = 1000;
% specifies with which sensors other sensors can form clusters
cfg_neighb.gradfile  = '/home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/c,rfhp0.1Hz';
cfg_neighb.method    = 'distance';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, gavg102hminus106h);

subj = 16;
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg, gavg102hminus106h, gavg104hminus108h);

save stat_freq_0.45ms_0.75ms_1Hz_3Hz stat;

% ploting
figure;
cfg = [];
cfg.alpha  = 0.05;
cfg.parameter = 'stat';
%cfg.zlim   = [-4 4];
cfg.layout = '4D248.lay';
ft_clusterplot(cfg, stat);

%% append conditions
cd /home/meg/Data/Maor/SchizoProject/Subjects
load TFgvConLow
load TFgvSZLow

All = nonWordFirstSZ;
All.powspctrm = [nonWordFirstSZ.powspctrm; nonWordSecondSZ.powspctrm;...
    nonWordSingleSZ.powspctrm; wordFirstSZ.powspctrm;...
    wordSecondSZ.powspctrm; wordSingleSZ.powspctrm;...
    nonWordFirstCon.powspctrm; nonWordSecondCon.powspctrm;...
    nonWordSingleCon.powspctrm; wordFirstCon.powspctrm;...
    wordSecondCon.powspctrm; wordSingleCon.powspctrm];
SZ = nonWordFirstSZ;
SZ.powspctrm = [nonWordFirstSZ.powspctrm; nonWordSecondSZ.powspctrm;...
    nonWordSingleSZ.powspctrm; wordFirstSZ.powspctrm;...
    wordSecondSZ.powspctrm; wordSingleSZ.powspctrm];
Con = nonWordFirstCon;
Con.powspctrm = [nonWordFirstCon.powspctrm; nonWordSecondCon.powspctrm;...
    nonWordSingleCon.powspctrm; wordFirstCon.powspctrm;...
    wordSecondCon.powspctrm; wordSingleCon.powspctrm];
% averaging across participents
All = ft_freqdescriptives([],All);
SZ = ft_freqdescriptives([],SZ);
Con = ft_freqdescriptives([],Con);
% creating the fidderence between the two groups
SZ_Con = SZ;
SZ_Con.powspctrm = SZ.powspctrm - Con.powspctrm;
% ploting
cfg              = [];
cfg.zlim        = [-10*10^(-28) 6*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
figure;
ft_singleplotTFR(cfg, All);
title('All conds both groups')
figure;
subplot(1,3,1)
ft_singleplotTFR(cfg, SZ_Con);
title('SZ minus Con')
subplot(1,3,2)
ft_singleplotTFR(cfg, SZ);
title('SZ')
subplot(1,3,3)
ft_singleplotTFR(cfg, Con);
title('Con')

% topoplot
figure;
cfg.zlim='maxmin';
cfg.colorbar='no';
cfg.xlim=[0.1:0.05:0.9]; % time
cfg.ylim=[8 12]; % freq
ft_topoplotER(cfg,All);

figure;
cfg.colorbar='yes';
cfg.xlim=[0.25 0.65];
cfg.ylim=[8 12];
ft_topoplotER(cfg,All);

chans=find(mean(mean(All.powspctrm(:,7:11,16:24),3),2)<-1*10^(-27));
figure;
cfg.highlight='on';
cfg.highlightchannel=All.label(chans);
cfg.colorbar='yes';
cfg.xlim=[0.25 0.65];
cfg.ylim=[8 12];
ft_topoplotER(cfg,All);

% repeated measures ANOVA for 250-650ms 8-12Hz
Alpha(1:31,1)=[ones(16,1); ones(15,1)*2];
Alpha(1:16,2)=mean(mean(mean(wordSingleCon.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(17:31,2)=mean(mean(mean(wordSingleSZ.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(1:16,3)=mean(mean(mean(wordFirstCon.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(17:31,3)=mean(mean(mean(wordFirstSZ.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(1:16,4)=mean(mean(mean(wordSecondCon.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(17:31,4)=mean(mean(mean(wordSecondSZ.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(1:16,5)=mean(mean(mean(nonWordSingleCon.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(17:31,5)=mean(mean(mean(nonWordSingleSZ.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(1:16,6)=mean(mean(mean(nonWordFirstCon.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(17:31,6)=mean(mean(mean(nonWordFirstSZ.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(1:16,7)=mean(mean(mean(nonWordSecondCon.powspctrm(:,chans,7:11,16:24),4),3),2);
Alpha(17:31,7)=mean(mean(mean(nonWordSecondSZ.powspctrm(:,chans,7:11,16:24),4),3),2);
%% statistics: each sub against it's BL
% Low freqs    
i=1;
for sub = [14 16 17 19 21 23 24 27:29 31 33:35 37 0:3 5:9 12 15 20 32 36 39 41]
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(sub),'/1/timeFrequency/TFtestLow.mat']);
    All = wordFirstLow;
    All.powspctrm = [All.powspctrm; nonWordFirstLow.powspctrm; nonWordSecondLow.powspctrm;...
        nonWordSingleLow.powspctrm; wordSecondLow.powspctrm; wordSingleLow.powspctrm];
    
    lala=All;
    lala.time=All.time(6:11); %-0.25 : -0.05 sec
    lala.powspctrm=lala.powspctrm(:,:,:,6:11);
    
    lala.powspctrm = repmat(nanmean(lala.powspctrm(:,:,:,1:end),4),[1 1 1 size(All.powspctrm,4)]);
    BL = All;
    BL.powspctrm = lala.powspctrm;
    clear lala
    
    cfg =[];
    cfg.method = 'montecarlo';
    cfg.statistic = 'depsamplesT';
    cfg.tail = 0;
    cfg.alpha = 0.05;
    cfg.channel = {'MEG'};
    cfg.avgoverchan = 'yes';
    cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
    cfg.correctm = 'cluster';
    % cfg.correctm = 'FDR';
    cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
    cfg1.method='triangulation';
    % cfg1.method='distance';
    cfg.neighbours = ft_neighbourselection(cfg1);
    cfg.numrandomization = 1000;%'gui', 'text',
    cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
    cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
    cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
    cfg.clustercritval   = [-1.96 1.96];
    cfg.clustertail      =  0;
    cfg.design(1,1:2*size(All.powspctrm,1)) = [ones(1,size(All.powspctrm,1)) 2*ones(1,size(All.powspctrm,1))];
    cfg.design(2,1:2*size(All.powspctrm,1)) = [1:size(All.powspctrm,1) 1:size(All.powspctrm,1)];
    cfg.ivar =1;
    cfg.uvar =2;
    
    stat = ft_freqstatistics(cfg,All,BL);
    
    stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
    
    eval(['AllStat',num2str(sub),' = stat;']);
    i
    i=i+1;
end;

%plot
figure
cfg =[];
cfg.zlim = [-20 20];  
cfg.parameter = 'stat2';
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
ft_singleplotTFR(cfg,AllStat8);

%% comparing the t values of all subs to 0
for sub = [14 16 17 19 21 23 24 27:29 31 33:35 37 0:3 5:9 12 15 20 32 36 39 41]
    eval(['AllStatZero',num2str(sub),' = AllStat',num2str(sub),';']);
    eval(['AllStatZero',num2str(sub),'.stat = zeros(1,39,41);']);
end;
    cfg.method    = 'montecarlo';
    cfg.statistic = 'pooledT';
    cfg.correctm  = 'cluster';
    cfg.parameter = 'stat';
    cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
    cfg.correctm = 'cluster';
    % cfg.correctm = 'FDR';
    cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
    cfg1.method='triangulation';
    % cfg1.method='distance';
    cfg.neighbours = ft_neighbourselection(cfg1);
    cfg.numrandomization = 1000;%'gui', 'text',
    cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
    cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
    cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
    cfg.clustercritval   = [-1.96 1.96];
    cfg.clustertail      =  0;
    cfg.design(1,1:2*31) = [ones(1,31) 2*ones(1,31)];
    cfg.design(2,1:2*31) = [1:31 1:31];
    cfg.ivar =1;
    cfg.uvar =2;
    
    stat = ft_freqstatistics(cfg,AllStat0,AllStat1,AllStat12,AllStat14,AllStat15,AllStat16,AllStat17,AllStat19,...
        AllStat2,AllStat20,AllStat21,AllStat23,AllStat24,AllStat27,AllStat28,AllStat29,AllStat3,AllStat31,...
        AllStat32,AllStat33,AllStat34,AllStat35,AllStat36,AllStat37,AllStat39,AllStat41,AllStat5,AllStat6,...
        AllStat7,AllStat8,AllStat9,AllStatZero0,AllStatZero1,AllStatZero12,AllStatZero14,AllStatZero15,...
        AllStatZero16,AllStatZero17,AllStatZero19,AllStatZero2,AllStatZero20,AllStatZero21,AllStatZero23,...
        AllStatZero24,AllStatZero27,AllStatZero28,AllStatZero29,AllStatZero3,AllStatZero31,AllStatZero32,...
        AllStatZero33,AllStatZero34,AllStatZero35,AllStatZero36,AllStatZero37,AllStatZero39,AllStatZero41,...
        AllStatZero5,AllStatZero6,AllStatZero7,AllStatZero8,AllStatZero9);
    
    stat.stat2 = stat.mask.*stat.stat; %  gives signifi
    
%plot
figure
cfg =[];
cfg.zlim = [-70 70];  
cfg.parameter = 'stat2';
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
ft_singleplotTFR(cfg,stat);

% %% SZ_T_against_BL vs. Con_T_against_BL
% 
%     cfg.method    = 'montecarlo';
%     cfg.statistic = 'pooledT';
%     cfg.correctm  = 'cluster';
%     cfg.parameter = 'stat';
%     cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
%     cfg.correctm = 'cluster';
%     % cfg.correctm = 'FDR';
%     cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
%     cfg1.method='triangulation';
%     % cfg1.method='distance';
%     cfg.neighbours = ft_neighbourselection(cfg1);
%     cfg.numrandomization = 1000;%'gui', 'text',
%     cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
%     cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
%     cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
%     cfg.clustercritval   = [-1.96 1.96];
%     cfg.clustertail      =  0;
%     cfg.design(1,1:31) = [ones(1,15) 2*ones(1,16)];
%     cfg.design(2,1:31) = [1:15 1:16];
%     cfg.ivar =1;
%     cfg.uvar =2;
%     statSZvsCon = ft_freqstatistics(cfg,AllStat14,AllStat16,AllStat17,AllStat19,AllStat21,AllStat23,AllStat24,AllStat27,...
%         AllStat28,AllStat29,AllStat31,AllStat33,AllStat34,AllStat35,AllStat37,AllStat0,AllStat1,AllStat2,...
%         AllStat3,AllStat5,AllStat6,AllStat7,AllStat8,AllStat9,AllStat12,AllStat15,AllStat20,AllStat32,...
%         AllStat36,AllStat39,AllStat41);
%     
%     statSZvsCon.stat2 = statSZvsCon.mask.*statSZvsCon.stat; %  gives signifi
%     
% %plot
% figure
% cfg =[];
% cfg.zlim = [-20 20];  
% cfg.parameter = 'stat';
% cfg.layout = '4D248.lay';
% cfg.interactive = 'yes';
% ft_singleplotTFR(cfg,statSZvsCon);

save TFagainstBL

%% for SPSS

comp1channels = {'A53','A54','A55','A67','A68','A69','A70','A78','A79','A80','A81','A82','A83','A95','A96',...
    'A97','A98','A99','A100','A101','A102','A105','A106','A107','A108','A109','A110','A111','A112','A113',...
    'A114','A127','A128','A129','A130','A131','A132','A133','A134','A135','A136','A137','A138','A139','A140',...
    'A141','A142','A143','A144','A145','A146','A147','A155','A156','A157','A158','A159','A160','A161','A162',...
    'A163','A164','A165','A166','A167','A168','A169','A170','A171','A172','A173','A174','A179','A180','A181',...
    'A182','A183','A184','A185','A186','A187','A188','A189','A190','A191','A193','A196','A199','A200','A201',...
    'A205','A206','A207','A208','A210','A211','A215','A216','A227'}';
comp2channels = {'A1','A2','A3','A8','A9','A10','A11','A12','A13','A14','A15','A16','A23','A24','A25','A26',...
    'A27','A28','A29','A30','A31','A32','A33','A41','A42','A43','A44','A45','A46','A47','A52','A53','A54',...
    'A55','A56','A65','A66','A67','A68','A69','A70','A71','A72','A73','A79','A80','A81','A82','A83','A84',...
    'A94','A95','A96','A97','A98','A99','A100','A110','A111','A112','A113','A114','A115','A126','A127','A128',...
    'A129','A130','A131','A143','A144','A145','A146','A147','A148','A154','A155','A156','A157','A158','A159',...
    'A170','A172','A173','A174','A175','A178','A179','A193','A194','A196','A197','A210','A211','A213'}';
comp3channels = {'A1','A2','A3','A7','A8','A9','A10','A11','A12','A13','A14','A15','A16','A22','A23','A24',...
    'A25','A26','A27','A28','A30','A31','A32','A33','A40','A41','A42','A43','A44','A45','A46','A54','A55',...
    'A56','A57','A65','A66','A67','A68','A69','A70','A81','A82','A83','A84','A94','A95','A96','A97','A98',...
    'A99','A112','A113','A114','A115','A126','A127','A128','A129','A130','A131','A144','A145','A146','A147',...
    'A148','A154','A155','A156','A157','A158','A159','A171','A172','A173','A174','A175','A178','A179','A193',...
    'A194','A196','A197','A211','A213','A227'}';

% comp1 (t: 0.272222 0.630474 ; f: 7.427785 12.416781)
chans = find(ismember(wordFirstLowSZ.label,comp1channels))';
wordFirstLowConComp1 = mean(mean(mean(wordFirstLowCon.powspctrm(:,chans,6:12,17:23),2),3),4);
wordFirstLowSZComp1 = mean(mean(mean(wordFirstLowSZ.powspctrm(:,chans,6:12,17:23),2),3),4);
nonWordFirstLowConComp1 = mean(mean(mean(nonWordFirstLowCon.powspctrm(:,chans,6:12,17:23),2),3),4);
nonWordFirstLowSZComp1 = mean(mean(mean(nonWordFirstLowSZ.powspctrm(:,chans,6:12,17:23),2),3),4);

wordSingleLowConComp1 = mean(mean(mean(wordSingleLowCon.powspctrm(:,chans,6:12,17:23),2),3),4);
wordSingleLowSZComp1 = mean(mean(mean(wordSingleLowSZ.powspctrm(:,chans,6:12,17:23),2),3),4);
nonWordSingleLowConComp1 = mean(mean(mean(nonWordSingleLowCon.powspctrm(:,chans,6:12,17:23),2),3),4);
nonWordSingleLowSZComp1 = mean(mean(mean(nonWordSingleLowSZ.powspctrm(:,chans,6:12,17:23),2),3),4);

wordSecondLowConComp1 = mean(mean(mean(wordSecondLowCon.powspctrm(:,chans,6:12,17:23),2),3),4);
wordSecondLowSZComp1 = mean(mean(mean(wordSecondLowSZ.powspctrm(:,chans,6:12,17:23),2),3),4);
nonWordSecondLowConComp1 = mean(mean(mean(nonWordSecondLowCon.powspctrm(:,chans,6:12,17:23),2),3),4);
nonWordSecondLowSZComp1 = mean(mean(mean(nonWordSecondLowSZ.powspctrm(:,chans,6:12,17:23),2),3),4);

% comp2 (t: 0.283279 0.681337 ; f: 15.474553 21.429161)
chans = find(ismember(wordFirstLowSZ.label,comp2channels))';
wordFirstLowConComp2 = mean(mean(mean(wordFirstLowCon.powspctrm(:,chans,14:21,17:25),2),3),4);
wordFirstLowSZComp2 = mean(mean(mean(wordFirstLowSZ.powspctrm(:,chans,14:21,17:25),2),3),4);
nonWordFirstLowConComp2 = mean(mean(mean(nonWordFirstLowCon.powspctrm(:,chans,14:21,17:25),2),3),4);
nonWordFirstLowSZComp2 = mean(mean(mean(nonWordFirstLowSZ.powspctrm(:,chans,14:21,17:25),2),3),4);

wordSingleLowConComp2 = mean(mean(mean(wordSingleLowCon.powspctrm(:,chans,14:21,17:25),2),3),4);
wordSingleLowSZComp2 = mean(mean(mean(wordSingleLowSZ.powspctrm(:,chans,14:21,17:25),2),3),4);
nonWordSingleLowConComp2 = mean(mean(mean(nonWordSingleLowCon.powspctrm(:,chans,14:21,17:25),2),3),4);
nonWordSingleLowSZComp2 = mean(mean(mean(nonWordSingleLowSZ.powspctrm(:,chans,14:21,17:25),2),3),4);

wordSecondLowConComp2 = mean(mean(mean(wordSecondLowCon.powspctrm(:,chans,14:21,17:25),2),3),4);
wordSecondLowSZComp2 = mean(mean(mean(wordSecondLowSZ.powspctrm(:,chans,14:21,17:25),2),3),4);
nonWordSecondLowConComp2 = mean(mean(mean(nonWordSecondLowCon.powspctrm(:,chans,14:21,17:25),2),3),4);
nonWordSecondLowSZComp2 = mean(mean(mean(nonWordSecondLowSZ.powspctrm(:,chans,14:21,17:25),2),3),4);

% comp3 (t: 0.338565 0.617206 ; f: 22.662999 29.475928)
chans = find(ismember(wordFirstLowSZ.label,comp3channels))';
wordFirstLowConComp3 = mean(mean(mean(wordFirstLowCon.powspctrm(:,chans,21:29,18:23),2),3),4);
wordFirstLowSZComp3 = mean(mean(mean(wordFirstLowSZ.powspctrm(:,chans,21:29,18:23),2),3),4);
nonWordFirstLowConComp3 = mean(mean(mean(nonWordFirstLowCon.powspctrm(:,chans,21:29,18:23),2),3),4);
nonWordFirstLowSZComp3 = mean(mean(mean(nonWordFirstLowSZ.powspctrm(:,chans,21:29,18:23),2),3),4);

wordSingleLowConComp3 = mean(mean(mean(wordSingleLowCon.powspctrm(:,chans,21:29,18:23),2),3),4);
wordSingleLowSZComp3 = mean(mean(mean(wordSingleLowSZ.powspctrm(:,chans,21:29,18:23),2),3),4);
nonWordSingleLowConComp3 = mean(mean(mean(nonWordSingleLowCon.powspctrm(:,chans,21:29,18:23),2),3),4);
nonWordSingleLowSZComp3 = mean(mean(mean(nonWordSingleLowSZ.powspctrm(:,chans,21:29,18:23),2),3),4);

wordSecondLowConComp3 = mean(mean(mean(wordSecondLowCon.powspctrm(:,chans,21:29,18:23),2),3),4);
wordSecondLowSZComp3 = mean(mean(mean(wordSecondLowSZ.powspctrm(:,chans,21:29,18:23),2),3),4);
nonWordSecondLowConComp3 = mean(mean(mean(nonWordSecondLowCon.powspctrm(:,chans,21:29,18:23),2),3),4);
nonWordSecondLowSZComp3 = mean(mean(mean(nonWordSecondLowSZ.powspctrm(:,chans,21:29,18:23),2),3),4);

% matrix for SPSS
TF4SPSSComp1 = [wordSingleLowSZComp1,wordFirstLowSZComp1,wordSecondLowSZComp1,...
    nonWordSingleLowSZComp1,nonWordFirstLowSZComp1,nonWordSecondLowSZComp1;...
    wordSingleLowConComp1,wordFirstLowConComp1,wordSecondLowConComp1,...
    nonWordSingleLowConComp1,nonWordFirstLowConComp1,nonWordSecondLowConComp1];
TF4SPSSComp1=TF4SPSSComp1.*10^27;

TF4SPSSComp2 = [wordSingleLowSZComp2,wordFirstLowSZComp2,wordSecondLowSZComp2,...
    nonWordSingleLowSZComp2,nonWordFirstLowSZComp2,nonWordSecondLowSZComp2;...
    wordSingleLowConComp2,wordFirstLowConComp2,wordSecondLowConComp2,...
    nonWordSingleLowConComp2,nonWordFirstLowConComp2,nonWordSecondLowConComp2];
TF4SPSSComp2=TF4SPSSComp2.*10^27;

TF4SPSSComp3 = [wordSingleLowSZComp3,wordFirstLowSZComp3,wordSecondLowSZComp3,...
    nonWordSingleLowSZComp3,nonWordFirstLowSZComp3,nonWordSecondLowSZComp3;...
    wordSingleLowConComp3,wordFirstLowConComp3,wordSecondLowConComp3,...
    nonWordSingleLowConComp3,nonWordFirstLowConComp3,nonWordSecondLowConComp3];
TF4SPSSComp3=TF4SPSSComp3.*10^27;

TF4SPSS = [TF4SPSSComp1,TF4SPSSComp2,TF4SPSSComp3];