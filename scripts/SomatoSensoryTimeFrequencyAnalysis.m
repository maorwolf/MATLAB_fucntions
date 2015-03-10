%% 1. finding trial
clear all
sub = 116
eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub)])
condition_vector = [102 104 106 108];
% 102 - pre right
% 104 - pre left
% 106 - post right
% 108 - post left

%% 2. define trials
cfg                         = [];
cfg.dataset                 = 'xc,hb,lf_c,rfhp0.1Hz';
cfg.trialdef.eventtype      = 'TRIGGER';
cfg.trialdef.eventvalue     = condition_vector;  %triggers are for different kinds of metaphors 
cfg.trialdef.prestim        = 0.5; % time before trigger onset
cfg.trialdef.poststim       = 1; % time after trigger onset
cfg.trialdef.offset         = -0.5; % defining the real zero: can be different than prestim
%cfg.trialdef.visualtrig    = 'visafter'; % sync the trigger from E-prime with the visual trigger 
%cfg.trialdef.visualtrigwin = 0.2; % look for the 2048 from the visual trigger in the next 200 ms interval time window
cfg.trialfun                = 'BIUtrialfun'; % use the unique parameters of the Bar Ilan MEG
%cfg.trialdef.rspwin        = 2.5; %wait for response for 2 seconds, else, report that there was no response
cfg                         = ft_definetrial(cfg);

%% 3. preprocessing for muscle artifact rejection
cfg.demean         = 'yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous     = 'yes';
cfg.baselinewindow = [-0.15,0];
cfg.hpfilter       = 'yes';
cfg.hpfreq         = 60;
cfg.channel        = {'MEG'}; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig           = ft_preprocessing(cfg);

%% 4. remove muscle artifact
cfg1.method        = 'summary'; %trial
datacln            = ft_rejectvisual(cfg1, dataorig);

% configure the channels
channels = 'MEG'; % channels = {'MEG','-A41'}; %  channels = {'MEG','-A41'};
%% 5 Deleting the bad trials from the original data so you don't refilter the data
cfg.trl            = [];
cfg.trl            = datacln.sampleinfo;
cfg.trl(:,3)       = -509; % change according to your offset in samples!!!
cfg.trl(:,[4:6])   = datacln.trialinfo;

%% 6 preprocessing original data
cfg.demean         = 'yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous     = 'yes';
cfg.baselinewindow = [-0.15,0];
cfg.hpfilter       = 'no';
cfg.bpfilter       = 'yes'; % apply bandpass filter (see one line below)
cfg.bpfreq         = [1 200];
cfg.channel        = channels; 
cfg.padding        = 10;
dataorig           = ft_preprocessing(cfg);

%% 7. ICA
%resampling data to speed up the ica
cfg             = [];
cfg.resamplefs  = 300;
cfg.detrend     = 'no';
dummy           = ft_resampledata(cfg, dataorig);

% run ica (it takes a long time have a break)
cfg             = [];
cfg.channel     = channels;
comp_dummy      = ft_componentanalysis(cfg, dummy);

% see the components and find the artifacts
cfgb            = [];
cfgb.layout     = '4D248.lay';
cfgb.channel    = {comp_dummy.label{1:10}};
cfgb.continuous ='no';
comppic         = ft_databrowser(cfgb,comp_dummy);

%% cool visualization for one component (e.g.,comp = 3) along trials and time (after resampling)  
seeOneComp(comp_dummy) % change the number of components you want to see

%% 8. run the ICA on the original data
cfg           = [];
cfg.topo      = comp_dummy.topo;
cfg.topolabel = comp_dummy.topolabel;
comp          = ft_componentanalysis(cfg, dataorig);

% remove the artifact components
cfg           = [];
cfg.component = [8 17]; % change
dataica       = ft_rejectcomponent(cfg, comp);

clear comp_dummy comppic comp dummy
%% 9. base line correction
dataica = correctBL(dataica,[-0.15 0]);

%% 10. trial by trial
cfg           = [];
cfg.method    = 'trial'; % 'channel'
cfg.channel   = channels;
cfg1.bpfilter = 'yes';
cfg1.bpfreq   = [1 200];
datafinal     = ft_rejectvisual(cfg, dataica);

%% 11. recreating the trl matrix
datafinal.cfg.trl(:,1:2) = datafinal.sampleinfo(:,1:2);
datafinal.cfg.trl(:,3)   = -509; % the offset
datafinal.cfg.trl(:,4:6) = datafinal.trialinfo(:,1:3);

mkdir('timeFrequency');
eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency']);
save datafinal datafinal
%% 12. Time frequency analysis
% low frequencies
subs = [7:19 21 22 25:28];
for sub = subs
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency'])
    load datafinal
        cfg             = [];
        cfg.resamplefs  = 300;
        cfg.detrend     = 'no';
        datafinal       = ft_resampledata(cfg, datafinal);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials= 'yes';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 4:1:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = [-0.5:0.03:1];
    cfgtfrl.channel   = {'MEG', '-A41'};
    cfgtfrl.trials    = find(datafinal.trialinfo==102);
    TF102l            = ft_freqanalysis(cfgtfrl, datafinal);
    cfgtfrl.trials    = find(datafinal.trialinfo==104);
    TF104l            = ft_freqanalysis(cfgtfrl, datafinal);
    cfgtfrl.trials    = find(datafinal.trialinfo==106);
    TF106l            = ft_freqanalysis(cfgtfrl, datafinal);
    cfgtfrl.trials    = find(datafinal.trialinfo==108);
    TF108l            = ft_freqanalysis(cfgtfrl, datafinal);
    
    save TFtestLow TF102l TF104l TF106l TF108l
    clear all
end;

subs = [7:19 21 22 25:28];
for sub = subs
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency'])
    load datafinal
        cfg             = [];
        cfg.resamplefs  = 300;
        cfg.detrend     = 'no';
        datafinal       = ft_resampledata(cfg, datafinal);
    cfgtfrh           = [];
    cfgtfrh.output    = 'pow';
    cfgtfrh.keeptrials= 'yes';
    cfgtfrh.method    = 'mtmconvol';
    cfgtfrh.pad       = 5;
    cfgtfrh.foi       = 40:5:140; 
    cfgtfrh.t_ftimwin = ones(length(cfgtfrh.foi))*0.2;
    cfgtfrh.toi       = [-0.5:0.03:1];
    cfgtfrh.channel   = {'MEG','-A41'};
    cfgtfrh.tapsmofrq = 15;
    cfgtfrh.trials    = find(datafinal.trialinfo==102);
    TF102h            = ft_freqanalysis(cfgtfrh, datafinal);
    cfgtfrh.trials    = find(datafinal.trialinfo==104);
    TF104h            = ft_freqanalysis(cfgtfrh, datafinal);
    cfgtfrh.trials    = find(datafinal.trialinfo==106);
    TF106h            = ft_freqanalysis(cfgtfrh, datafinal);
    cfgtfrh.trials    = find(datafinal.trialinfo==108);
    TF108h            = ft_freqanalysis(cfgtfrh, datafinal);
    
    save TFtestHigh TF102h TF104h TF106h TF108h
    clear all
end;

load timeFrequency/TFtestLow

%% 13 ploting
figure;
cfg              = [];
cfg.baseline     = [-0.5 0]; 
cfg.baselinetype = 'absolute';
%cfg.zlim        = [-3*10^(-29) 8*10^(-26)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

%ft_multiplotTFR(cfg, TF102l);
subplot(2,2,1)
ft_singleplotTFR(cfg, TF104l);
title('pre left')
subplot(2,2,2)
ft_singleplotTFR(cfg, TF108l);
title('post left')
subplot(2,2,3)
ft_singleplotTFR(cfg, TF102l);
title('pre right')
subplot(2,2,4)
ft_singleplotTFR(cfg, TF106l);
title('post right')

%% 14 grand average
clear all
subs = [7:19, 21, 22, 25:28];
for sub = subs
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency'])
    load TFtestLow
    for cond = [102 104 106 108]
        eval(['sub',num2str(sub),'TF',num2str(cond),'ldesc = ft_freqdescriptives([], TF',num2str(cond),'l);']);
    end;
    clear TF102l TF104l TF106l TF108l
    disp(sub);
end;

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TF102lgavg         = ft_freqgrandaverage(cfg, sub7TF102ldesc, sub8TF102ldesc, sub9TF102ldesc, sub10TF102ldesc,...
    sub11TF102ldesc, sub12TF102ldesc, sub13TF102ldesc, sub14TF102ldesc, sub15TF102ldesc, sub17TF102ldesc, sub19TF102ldesc,...
    sub21TF102ldesc, sub22TF102ldesc, sub25TF102ldesc, sub26TF102ldesc, sub27TF102ldesc, sub28TF102ldesc);

TF104lgavg         = ft_freqgrandaverage(cfg, sub7TF104ldesc, sub8TF104ldesc, sub9TF104ldesc, sub10TF104ldesc,...
    sub11TF104ldesc, sub12TF104ldesc, sub13TF104ldesc, sub14TF104ldesc, sub15TF104ldesc, sub17TF104ldesc, sub19TF104ldesc,...
    sub21TF104ldesc, sub22TF104ldesc, sub25TF104ldesc, sub26TF104ldesc, sub27TF104ldesc, sub28TF104ldesc);

TF106lgavg         = ft_freqgrandaverage(cfg, sub7TF106ldesc, sub8TF106ldesc, sub9TF106ldesc, sub10TF106ldesc,...
    sub11TF106ldesc, sub12TF106ldesc, sub13TF106ldesc, sub14TF106ldesc, sub15TF106ldesc, sub17TF106ldesc, sub19TF106ldesc,...
    sub21TF106ldesc, sub22TF106ldesc, sub25TF106ldesc, sub26TF106ldesc, sub27TF106ldesc, sub28TF106ldesc);

TF108lgavg         = ft_freqgrandaverage(cfg, sub7TF108ldesc, sub8TF108ldesc, sub9TF108ldesc, sub10TF108ldesc,...
    sub11TF108ldesc, sub12TF108ldesc, sub13TF108ldesc, sub14TF108ldesc, sub15TF108ldesc, sub17TF108ldesc, sub19TF108ldesc,...
    sub21TF108ldesc, sub22TF108ldesc, sub25TF108ldesc, sub26TF108ldesc, sub27TF108ldesc, sub28TF108ldesc);

cd /home/meg/Data/Maor/Hypnosis/Subjects
save TFlgavgs TF102lgavg TF104lgavg TF106lgavg TF108lgavg
clear all
load TFlgavgs

%% do the same for high frequencies

load TFlgavgs
load TFhgavgs

% ploting
cfg              = [];
cfg.baseline     = [-0.5 0]; 
cfg.baselinetype = 'absolute'; % 'relchange'
cfg.zlim        = [-8*10^(-28) 8*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'no';

figure;
%ft_multiplotTFR(cfg, TF102l);
subplot(2,2,1)
ft_singleplotTFR(cfg, TF104lgavg);
title('pre left low frequencies')
subplot(2,2,2)
ft_singleplotTFR(cfg, TF108lgavg);
title('post left low frequencies')
subplot(2,2,3)
ft_singleplotTFR(cfg, TF102lgavg);
title('pre right low frequencies')
subplot(2,2,4)
ft_singleplotTFR(cfg, TF106lgavg);
title('post right low frequencies')

figure;
subplot(2,2,1)
ft_singleplotTFR(cfg, TF104hgavg);
title('pre left high frequencies')
subplot(2,2,2)
ft_singleplotTFR(cfg, TF108hgavg);
title('post left high frequencies')
subplot(2,2,3)
ft_singleplotTFR(cfg, TF102hgavg);
title('pre right high frequencies')
subplot(2,2,4)
ft_singleplotTFR(cfg, TF106hgavg);
title('post right high frequencies')

% differences
TFl_LeftPreMinusPost = TF104lgavg;
TFl_LeftPreMinusPost.powspctrm = TF104lgavg.powspctrm - TF108lgavg.powspctrm;
TFl_RightPreMinusPost = TF102lgavg;
TFl_RightPreMinusPost.powspctrm = TF102lgavg.powspctrm - TF106lgavg.powspctrm;

% ploting
cfg              = [];
cfg.baseline     = [-0.5 0]; 
cfg.baselinetype = 'absolute';
cfg.zlim        = [-8*10^(-28) 8*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'no';

figure;
%ft_multiplotTFR(cfg, TF102l);
subplot(1,2,1)
ft_singleplotTFR(cfg, TFl_LeftPreMinusPost);
title('pre-post left low frequencies')
subplot(1,2,2)
ft_singleplotTFR(cfg, TFl_RightPreMinusPost);
title('pre-post right low frequencies')

%%  statistics
cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG', '-A41'};
% cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
        cfg.correctm = 'cluster';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
cfg.neighbours = ft_neighbourselection(cfg1);
cd '/home/meg/Data/Maor/Hypnosis/Subjects'
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:2*17) = [ones(1,17) 2*ones(1,17)];
cfg.design(2,1:2*17) = [1:17 1:17];
cfg.ivar =1;
cfg.uvar =2;
cfg.avgovertime = 'yes'; % cfg.avgovertime = 'no';
cfg.avgoverfreq = 'yes'; % cfg.avgoverfreq = 'no';

cfg.latency     = [0.12 0.64];
cfg.frequency   = [7 13];

[stat] = ft_freqstatistics(cfg, TFl_LeftPreMinusPost, TFl_RightPreMinusPost);
disp('neg clusters:');
stat.negclusters.prob
disp('pos clusters:');
stat.posclusters.prob

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
stat.stat2

% plot
cfgp=[];
cfgp.colorbar='yes';
cfgp.parameter = 'stat';
cfgp.layout = '4D248.lay';
cfgp.alpha = 0.05;
ft_clusterplot(cfgp, stat)

Right_PreMinusPost=mean(mean(mean(mean(TFl_RightPreMinusPost.powspctrm(:,stat.negclusterslabelmat==1,[3:7],[28:38])))));
Left_PreMinusPost=mean(mean(mean(mean(TFl_LeftPreMinusPost.powspctrm(:,stat.negclusterslabelmat==1,[3:7],[28:38])))));

% cfg=[];
% cfg.layout = '4D248.lay';
% cfg.colorbar = 'yes';
% cfg.parameter = 'powspctrm';
% cfg.zlim = [-10*10^(-28) 10*10^(-28)];
% cfg.xlim     = [0.324 0.63];
% cfg.ylim   = [7 13];
% cfg.highlight          = {'numbers'};
% cfg.highlightsymbol    = {'*'};
% cfg.highlightchannel   = {stat.label(stat.negclusterslabelmat==1)};
% figure
% ft_topoplotTFR(cfg,TFl_LeftPreMinusPost);
% figure
% ft_topoplotTFR(cfg,TFl_RightPreMinusPost);
%%
% ------------------ 8< -------------------- 
%
%% statistics: each sub against it's BL
% Low freqs    
i=1;
for sub = [7:12 14 15 17 19 21 25:28]
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency/TFtestLow.mat']);
    All = TF102l;
    All.powspctrm = [All.powspctrm; TF104l.powspctrm; TF106l.powspctrm; TF108l.powspctrm];
    
    lala=All;
    lala.time=All.time(10:17); %-0.23 : -0.02 sec
    lala.powspctrm=lala.powspctrm(:,:,:,10:17);
    
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
    disp(i);
    i=i+1;
end;

%plot
figure
cfg =[];
cfg.zlim = [-20 20];  
cfg.parameter = 'stat2';
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
ft_singleplotTFR(cfg,AllStat10);

%% comparing the t values of all subs to 0
for sub = [7:12 14 15 17 19 21 25:28]
    eval(['AllStatZero',num2str(sub),' = AllStat',num2str(sub),';']);
    eval(['AllStatZero',num2str(sub),'.stat = zeros(1,20,51);']);
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
    cfg.design(1,1:2*15) = [ones(1,15) 2*ones(1,15)];
    cfg.design(2,1:2*15) = [1:15 1:15];
    cfg.ivar =1;
    cfg.uvar =2;
    
    stat = ft_freqstatistics(cfg,AllStat7,AllStat8,AllStat9,AllStat10,AllStat11,AllStat12,AllStat14,AllStat15,...
        AllStat17,AllStat19,AllStat21,AllStat25,AllStat26,AllStat27,AllStat28,AllStatZero7,AllStatZero8,...
        AllStatZero9,AllStatZero10,AllStatZero11,AllStatZero12,AllStatZero14,AllStatZero15,AllStatZero17,...
        AllStatZero19,AllStatZero21,AllStatZero25,AllStatZero26,AllStatZero27,AllStatZero28);
    
    stat.stat2 = stat.mask.*stat.stat; %  gives signifi
    
%plot
figure
cfg =[];
cfg.zlim = [-40 40];  
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
%     cfg.cluster/home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/timeFrequencythreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
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
save TFagainstBL

clear all
for sub = [7:12 14 15 17 19 21 25:28]
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency/TFtestLow.mat']);
    All = TF102l;
    All.powspctrm = [All.powspctrm; TF104l.powspctrm; TF106l.powspctrm; TF108l.powspctrm];
    eval(['All',num2str(sub),' = ft_freqdescriptives([], All)']);
end;

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG'};
cfg.parameter      = 'powspctrm';

All = ft_freqgrandaverage(cfg, All10, All11, All12, All14, All15, All17, All19, All21, All25,...
    All26, All27, All28, All7, All8, All9);

%plot
figure
cfg =[];
%cfg.zlim = [-20 20];  
cfg.parameter = 'powspctrm';
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
cfg.xlim = [0.271456 0.596602];
cfg.ylim = [4.878955 8.840440];
ft_topoplotER(cfg,All);

%% for SPSS

comp1channels = {'A1','A2','A3','A8','A9','A10','A14','A15','A16','A23','A24','A25','A31','A32','A33','A42',...
    'A43','A44','A52','A53','A54','A55','A56','A67','A68','A69','A79','A80','A81','A82','A83','A84','A95',...
    'A96','A97','A98','A109','A110','A111','A112','A113','A114','A115','A127','A128','A129','A130','A131',...
    'A132','A141','A142','A143','A144','A145','A146','A147','A155','A156','A157','A158','A159','A160','A168',...
    'A169','A170','A171','A172','A173','A174','A179','A181','A190','A191','A193','A210','A211'};

comp2channels = {'A1','A2','A3','A4','A7','A8','A9','A10','A14','A15','A16','A17','A22','A23','A24','A25',...
    'A31','A32','A33','A34','A41','A42','A43','A44','A52','A53','A54','A55','A56','A57','A66','A67','A68',...
    'A69','A79','A80','A81','A82','A83','A84','A95','A96','A97','A98','A111','A112','A113','A114','A115',...
    'A116','A127','A128','A129','A130','A131','A142','A143','A144','A145','A146','A147','A148','A155','A156',...
    'A157','A169','A170','A172','A173','A174','A179','A191','A193','A208','A211'};

comp3channels = {'A32','A53','A54','A55','A56','A67','A68','A69','A79','A80','A81','A82','A83','A95','A96',...
    'A97','A98','A99','A100','A101','A108','A109','A110','A111','A112','A113','A114','A115','A126','A127',...
    'A128','A129','A130','A131','A132','A133','A140','A141','A142','A143','A144','A145','A146','A147','A154',...
    'A155','A156','A157','A158','A159','A160','A161','A167','A168','A169','A170','A171','A172','A173','A174',...
    'A175','A178','A179','A181','A182','A189','A190','A191','A193','A194','A196','A197','A199','A207','A208',...
    'A210','A211','A213','A227'};


% I stopped here!!!
a=1;
for sub = [7:12 14 15 17 19 21 25:28]
    
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency/TFtestLow.mat']);
    
    % comp1 (t: 0.117961 0.358932 ; f: 15.05777 20.94497)
    chans = find(ismember(TF102l.label,comp1channels))';
    TF102lComp1 = mean(mean(mean(mean(TF102l.powspctrm(:,chans,7:10,21:30),2),3),4),1);
    TF104lComp1 = mean(mean(mean(mean(TF104l.powspctrm(:,chans,7:10,21:30),2),3),4),1);
    TF106lComp1 = mean(mean(mean(mean(TF106l.powspctrm(:,chans,7:10,21:30),2),3),4),1);
    TF108lComp1 = mean(mean(mean(mean(TF108l.powspctrm(:,chans,7:10,21:30),2),3),4),1);
    
    % comp2 (t: 0.144369 0.325923 ; f: 25.01650 31.06877)
    chans = find(ismember(TF102l.label,comp2channels))';
    TF102lComp2 = mean(mean(mean(mean(TF102l.powspctrm(:,chans,13:16,22:29),2),3),4),1);
    TF104lComp2 = mean(mean(mean(mean(TF104l.powspctrm(:,chans,13:16,22:29),2),3),4),1);
    TF106lComp2 = mean(mean(mean(mean(TF106l.powspctrm(:,chans,13:16,22:29),2),3),4),1);
    TF108lComp2 = mean(mean(mean(mean(TF108l.powspctrm(:,chans,13:16,22:29),2),3),4),1);
    
    % comp3 (t: 0.271456 0.596602 ; f: 4.878955 8.840440)
    chans = find(ismember(TF102l.label,comp3channels))';
    TF102lComp3 = mean(mean(mean(mean(TF102l.powspctrm(:,chans,2:5,27:38),2),3),4),1);
    TF104lComp3 = mean(mean(mean(mean(TF104l.powspctrm(:,chans,2:5,27:38),2),3),4),1);
    TF106lComp3 = mean(mean(mean(mean(TF106l.powspctrm(:,chans,2:5,27:38),2),3),4),1);
    TF108lComp3 = mean(mean(mean(mean(TF108l.powspctrm(:,chans,2:5,27:38),2),3),4),1);

    % matrix for SPSS
    TF4SPSSComp1(a,1:4) = [TF102lComp1,TF104lComp1,TF106lComp1,TF108lComp1];
    TF4SPSSComp2(a,1:4) = [TF102lComp2,TF104lComp2,TF106lComp2,TF108lComp2];
    TF4SPSSComp3(a,1:4) = [TF102lComp3,TF104lComp3,TF106lComp3,TF108lComp3];
    a=a+1;
end;

TF4SPSSComp1=TF4SPSSComp1.*10^27;
TF4SPSSComp2=TF4SPSSComp2.*10^27;
TF4SPSSComp3=TF4SPSSComp3.*10^27;

TF4SPSS = [TF4SPSSComp1,TF4SPSSComp2,TF4SPSSComp3];

%% ------------------------ >8 ---------------- 27.4.14
%% 12. Time frequency analysis for all conditions with base line
% low frequencies
subs = [7:15 17 19 21 22 25:28];
for sub = subs
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency'])
    load datafinal
        cfg             = [];
        cfg.resamplefs  = 300;
        cfg.detrend     = 'no';
        datafinal       = ft_resampledata(cfg, datafinal);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials='yes';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 2:2:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = -0.5:0.03:1;
    cfgtfrl.channel   = {'MEG', '-A41'};
    cfgtfrl.trials    = 'all';
    TFlall            = ft_freqanalysis(cfgtfrl, datafinal);
    save TFlall
    clear all
end;

%% base line
clear all
for i = [7:19, 21, 22, 25:28];
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/TFlall'])
    cfg=[];
    cfg.baseline     = [-0.15 0];
    cfg.baselinetype = 'absolute';
    TFlallBL=ft_freqbaseline(cfg, TFlall);
    eval(['sub',num2str(i),'TFlallBL = TFlallBL;']);
    clear TFlall
    disp(i);
end;

%% grand average
subs = [7:19, 21, 22, 25:28];
for sub = subs
    eval(['sub',num2str(sub),'TFlallBLdesc = ft_freqdescriptives([],sub',num2str(sub),'TFlallBL);']);
    disp(sub);
end;

cfg = [];
cfg.keepindividual = 'no';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFlallBLgavg         = ft_freqgrandaverage(cfg, sub7TFlallBLdesc, sub8TFlallBLdesc, sub9TFlallBLdesc, sub10TFlallBLdesc,...
    sub11TFlallBLdesc, sub12TFlallBLdesc, sub13TFlallBLdesc, sub14TFlallBLdesc, sub15TFlallBLdesc, sub17TFlallBLdesc, sub19TFlallBLdesc,...
    sub21TFlallBLdesc, sub22TFlallBLdesc, sub25TFlallBLdesc, sub26TFlallBLdesc, sub27TFlallBLdesc, sub28TFlallBLdesc);

cd /home/meg/Data/Maor/Hypnosis/Subjects
save TFlallBLgavg TFlallBLgavg
clear all
load TFlallBLgavg


%% plots
cfg              = [];
cfg.zlim        = [-8*10^(-28) 8*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'no';
figure;
ft_singleplotTFR(cfg, TFlallBLgavg);
title('all conditions')

figure;
cfg1=[];
cfg1.layout = '4D248.lay';
cfg1.colorbar = 'yes';
cfg1.parameter = 'powspctrm';
%cfg1.marker = 'labels';
cfg1.zlim = [-2*10^(-27) 2*10^(-27)];
cfg1.xlim     = [0.13 0.64];
cfg1.ylim   = [8 12];
ft_topoplotTFR(cfg1, TFlallBLgavg);

%% base line for each condition
clear all
for i = [7:19, 21, 22, 25:28];
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/TFtestLow'])
    cfg=[];
    cfg.baseline     = [-0.15 0];
    cfg.baselinetype = 'absolute';
    for j=2:2:8
        eval(['sub',num2str(i),'TF10',num2str(j),'lBL = ft_freqbaseline(cfg, TF10',num2str(j),'l);']);
    end
    clear TF102l TF104l TF106l TF108l
    disp(i);
end;
figure;
cfg1=[];
cfg1.layout = '4D248.lay';
cfg1.colorbar = 'yes';
cfg1.parameter = 'powspctrm';
%cfg1.marker = 'labels';
cfg1.zlim = [-2*10^(-27) 2*10^(-27)];
cfg1.xlim     = [0.13 0.64];
cfg1.ylim   = [8 12];
ft_topoplotTFR(cfg1, TFlallBLgavg);
%% grand average
subs = [7:15 17, 19, 21, 22, 25:28];
for sub = subs
    for cond = 102:2:108
        eval(['sub',num2str(sub),'TF',num2str(cond),'lBLdesc = ft_freqdescriptives([],sub',num2str(sub),'TF',num2str(cond),'lBL);']);
    end;
end;

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TF102lBLgavg         = ft_freqgrandaverage(cfg, sub7TF102lBLdesc, sub8TF102lBLdesc, sub9TF102lBLdesc, sub10TF102lBLdesc,...
    sub11TF102lBLdesc, sub12TF102lBLdesc, sub13TF102lBLdesc, sub14TF102lBLdesc, sub15TF102lBLdesc, sub17TF102lBLdesc, sub19TF102lBLdesc,...
    sub21TF102lBLdesc, sub22TF102lBLdesc, sub25TF102lBLdesc, sub26TF102lBLdesc, sub27TF102lBLdesc, sub28TF102lBLdesc);

TF104lBLgavg         = ft_freqgrandaverage(cfg, sub7TF104lBLdesc, sub8TF104lBLdesc, sub9TF104lBLdesc, sub10TF104lBLdesc,...
    sub11TF104lBLdesc, sub12TF104lBLdesc, sub13TF104lBLdesc, sub14TF104lBLdesc, sub15TF104lBLdesc, sub17TF104lBLdesc, sub19TF104lBLdesc,...
    sub21TF104lBLdesc, sub22TF104lBLdesc, sub25TF104lBLdesc, sub26TF104lBLdesc, sub27TF104lBLdesc, sub28TF104lBLdesc);

TF106lBLgavg         = ft_freqgrandaverage(cfg, sub7TF106lBLdesc, sub8TF106lBLdesc, sub9TF106lBLdesc, sub10TF106lBLdesc,...
    sub11TF106lBLdesc, sub12TF106lBLdesc, sub13TF106lBLdesc, sub14TF106lBLdesc, sub15TF106lBLdesc, sub17TF106lBLdesc, sub19TF106lBLdesc,...
    sub21TF106lBLdesc, sub22TF106lBLdesc, sub25TF106lBLdesc, sub26TF106lBLdesc, sub27TF106lBLdesc, sub28TF106lBLdesc);

TF108lBLgavg         = ft_freqgrandaverage(cfg, sub7TF108lBLdesc, sub8TF108lBLdesc, sub9TF108lBLdesc, sub10TF108lBLdesc,...
    sub11TF108lBLdesc, sub12TF108lBLdesc, sub13TF108lBLdesc, sub14TF108lBLdesc, sub15TF108lBLdesc, sub17TF108lBLdesc, sub19TF108lBLdesc,...
    sub21TF108lBLdesc, sub22TF108lBLdesc, sub25TF108lBLdesc, sub26TF108lBLdesc, sub27TF108lBLdesc, sub28TF108lBLdesc);

cd /home/meg/Data/Maor/Hypnosis/Subjects
save TFlBLgavgs TF102lBLgavg TF104lBLgavg TF106lBLgavg TF108lBLgavg
clear all
load TFlBLgavgs

%% plots
cfg              = [];
cfg.zlim        = [-10*10^(-28) 6*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
figure;
subplot(2,2,1)
ft_singleplotTFR(cfg, TF104lBLgavg);
title('pre left')
subplot(2,2,2)
ft_singleplotTFR(cfg, TF108lBLgavg);
title('post left')
subplot(2,2,3)
ft_singleplotTFR(cfg, TF102lBLgavg);
title('pre right')
subplot(2,2,4)
ft_singleplotTFR(cfg, TF106lBLgavg);
title('post right')

%% finding the channels for each component
%% comp1
comp1 = mean(mean(TFlallBLgavg.powspctrm(:,2:3,26:28),3),2);
comp1Chans=find(comp1 > 0.35*10^(-27));

figure;
cfg1=[];
cfg1.layout = '4D248.lay';
cfg1.colorbar = 'yes';
cfg1.parameter = 'powspctrm';
%cfg1.marker = 'labels';
cfg1.highlight = 'on';
cfg1.highlightchannel = comp1Chans;
cfg1.zlim = [-2*10^(-27) 2*10^(-27)];
cfg1.xlim     = [0.25 0.310];
cfg1.ylim   = [3 6];
ft_topoplotTFR(cfg1, TFlallBLgavg);

% extracting the comp chans from left and right minus the midline chans
load LRpairs
comp1LeftChans = ismember(TFlallBLgavg.label(comp1Chans), LRpairs(:,1));
comp1RightChans = ismember(TFlallBLgavg.label(comp1Chans), LRpairs(:,2));

%% comp2
comp2 = mean(mean(TFlallBLgavg.powspctrm(:,4:6,22:39),3),2);
comp2Chans=find(comp2 < -0.5*10^(-27));

figure;
cfg1=[];
cfg1.layout = '4D248.lay';
cfg1.colorbar = 'yes';
cfg1.parameter = 'powspctrm';
%cfg1.marker = 'labels';
cfg1.highlight = 'on';
cfg1.highlightchannel = comp2Chans;
cfg1.zlim = [-2*10^(-27) 2*10^(-27)];
cfg1.xlim     = [0.13 0.63];
cfg1.ylim   = [8 12];
ft_topoplotTFR(cfg1, TFlallBLgavg);

% extracting the comp chans from left and right minus the midline chans
load LRpairs
comp2LeftChans = ismember(TFlallBLgavg.label(comp2Chans), LRpairs(:,1));
comp2RightChans = ismember(TFlallBLgavg.label(comp2Chans), LRpairs(:,2));

%% comp3
comp3 = mean(mean(TFlallBLgavg.powspctrm(:,7:10,22:31),3),2);
comp3Chans=find(comp3 < -0.25*10^(-27));

figure;
cfg1=[];
cfg1.layout = '4D248.lay';
cfg1.colorbar = 'yes';
cfg1.parameter = 'powspctrm';
%cfg1.marker = 'labels';
cfg1.highlight = 'on';
cfg1.highlightchannel = comp3Chans;
cfg1.zlim = [-2*10^(-27) 2*10^(-27)];
cfg1.xlim     = [0.13 0.4];
cfg1.ylim   = [13 20];
ft_topoplotTFR(cfg1, TFlallBLgavg);

% extracting the comp chans from left and right minus the midline chans
load LRpairs
comp3LeftChans = ismember(TFlallBLgavg.label(comp3Chans), LRpairs(:,1));
comp3RightChans = ismember(TFlallBLgavg.label(comp3Chans), LRpairs(:,2));

save TFAchans comp1LeftChans comp1RightChans comp2LeftChans comp2RightChans comp3LeftChans comp3RightChans

%% Tables 4 SPSS
clear all
load TFlBLgavgs
load TFAchans

TF102lBLcomp1R = mean(mean(mean(TF102lBLgavg.powspctrm(:,comp1RightChans,2:3,26:28),4),3),2);
TF102lBLcomp1L = mean(mean(mean(TF102lBLgavg.powspctrm(:,comp1LeftChans,2:3,26:28),4),3),2);
TF104lBLcomp1R = mean(mean(mean(TF104lBLgavg.powspctrm(:,comp1RightChans,2:3,26:28),4),3),2);
TF104lBLcomp1L = mean(mean(mean(TF104lBLgavg.powspctrm(:,comp1LeftChans,2:3,26:28),4),3),2);
TF106lBLcomp1R = mean(mean(mean(TF106lBLgavg.powspctrm(:,comp1RightChans,2:3,26:28),4),3),2);
TF106lBLcomp1L = mean(mean(mean(TF106lBLgavg.powspctrm(:,comp1LeftChans,2:3,26:28),4),3),2);
TF108lBLcomp1R = mean(mean(mean(TF108lBLgavg.powspctrm(:,comp1RightChans,2:3,26:28),4),3),2);
TF108lBLcomp1L = mean(mean(mean(TF108lBLgavg.powspctrm(:,comp1LeftChans,2:3,26:28),4),3),2);

TF102lBLcomp2R = mean(mean(mean(TF102lBLgavg.powspctrm(:,comp2RightChans,4:6,22:39),4),3),2);
TF102lBLcomp2L = mean(mean(mean(TF102lBLgavg.powspctrm(:,comp2LeftChans,4:6,22:39),4),3),2);
TF104lBLcomp2R = mean(mean(mean(TF104lBLgavg.powspctrm(:,comp2RightChans,4:6,22:39),4),3),2);
TF104lBLcomp2L = mean(mean(mean(TF104lBLgavg.powspctrm(:,comp2LeftChans,4:6,22:39),4),3),2);
TF106lBLcomp2R = mean(mean(mean(TF106lBLgavg.powspctrm(:,comp2RightChans,4:6,22:39),4),3),2);
TF106lBLcomp2L = mean(mean(mean(TF106lBLgavg.powspctrm(:,comp2LeftChans,4:6,22:39),4),3),2);
TF108lBLcomp2R = mean(mean(mean(TF108lBLgavg.powspctrm(:,comp2RightChans,4:6,22:39),4),3),2);
TF108lBLcomp2L = mean(mean(mean(TF108lBLgavg.powspctrm(:,comp2LeftChans,4:6,22:39),4),3),2);

TF102lBLcomp3R = mean(mean(mean(TF102lBLgavg.powspctrm(:,comp3RightChans,7:10,22:31),4),3),2);
TF102lBLcomp3L = mean(mean(mean(TF102lBLgavg.powspctrm(:,comp3LeftChans,7:10,22:31),4),3),2);
TF104lBLcomp3R = mean(mean(mean(TF104lBLgavg.powspctrm(:,comp3RightChans,7:10,22:31),4),3),2);
TF104lBLcomp3L = mean(mean(mean(TF104lBLgavg.powspctrm(:,comp3LeftChans,7:10,22:31),4),3),2);
TF106lBLcomp3R = mean(mean(mean(TF106lBLgavg.powspctrm(:,comp3RightChans,7:10,22:31),4),3),2);
TF106lBLcomp3L = mean(mean(mean(TF106lBLgavg.powspctrm(:,comp3LeftChans,7:10,22:31),4),3),2);
TF108lBLcomp3R = mean(mean(mean(TF108lBLgavg.powspctrm(:,comp3RightChans,7:10,22:31),4),3),2);
TF108lBLcomp3L = mean(mean(mean(TF108lBLgavg.powspctrm(:,comp3LeftChans,7:10,22:31),4),3),2);

save TFBL_LR_4SPSS
for i=1:3
    for j=102:2:108
        eval(['TF',num2str(j),'lBLcomp',num2str(i),'L=TF',num2str(j),'lBLcomp',num2str(i),'L.*10^28;']);
        eval(['TF',num2str(j),'lBLcomp',num2str(i),'R=TF',num2str(j),'lBLcomp',num2str(i),'R.*10^28;']);
    end
end

%% cluster analysis for the TFA_BL_gravgs
% differences
TFl_LeftPreMinusPost = TF104lBLgavg;
TFl_LeftPreMinusPost.powspctrm = TF104lBLgavg.powspctrm - TF108lBLgavg.powspctrm;
TFl_RightPreMinusPost = TF102lBLgavg;
TFl_RightPreMinusPost.powspctrm = TF102lBLgavg.powspctrm - TF106lBLgavg.powspctrm;

% ploting
cfg              = [];
cfg.baseline     = [-0.5 0]; 
cfg.baselinetype = 'absolute';
cfg.zlim        = [-8*10^(-28) 8*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'no';

figure;
%ft_multiplotTFR(cfg, TF102l);
subplot(1,2,1)
ft_singleplotTFR(cfg, TFl_LeftPreMinusPost);
title('pre-post left low frequencies')
subplot(1,2,2)
ft_singleplotTFR(cfg, TFl_RightPreMinusPost);
title('pre-post right low frequencies')

%%  statistics
cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG', '-A41'};
% cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
        cfg.correctm = 'cluster';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
cfg.neighbours = ft_neighbourselection(cfg1);
cd '/home/meg/Data/Maor/Hypnosis/Subjects'
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:2*17) = [ones(1,17) 2*ones(1,17)];
cfg.design(2,1:2*17) = [1:17 1:17];
cfg.ivar =1;
cfg.uvar =2;
cfg.avgovertime = 'yes'; % cfg.avgovertime = 'no';
cfg.avgoverfreq = 'yes'; % cfg.avgoverfreq = 'no';

cfg.latency     = [0.485 0.7];
cfg.frequency   = [9 13];

[stat] = ft_freqstatistics(cfg, TFl_LeftPreMinusPost, TFl_RightPreMinusPost);
disp('neg clusters:');
stat.negclusters.prob
disp('pos clusters:');
stat.posclusters.prob

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
stat.stat2

%% -------------------------------- 8< --------------------------
%  --------------------------- June 2014 ------------------------
%% freqdescriptives for trials
clear all
subs = [7:19, 21, 22, 25:28];
for sub = subs
eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency'])
load TFtestLow
for cond = [102 104 106 108]
eval(['sub',num2str(sub),'TF',num2str(cond),'ldesc = ft_freqdescriptives([], TF',num2str(cond),'l);']);
end;
clear TF102l TF104l TF106l TF108l
disp(sub);
end;
%% base line for each condition
for i = [7:19, 21, 22, 25:28];
    cfg=[];
    cfg.baseline     = [-0.15 0];
    cfg.baselinetype = 'absolute';
    for j=2:2:8
        eval(['sub',num2str(i),'TF10',num2str(j),'lBL = ft_freqbaseline(cfg, sub',num2str(i),'TF10',num2str(j),'ldesc);']);
    end
    eval(['clear sub',num2str(i),'TF102ldesc sub',num2str(i),'TF104ldesc sub',num2str(i),'TF106ldesc sub',num2str(i),'TF108ldesc']);
    disp(i);
end;
%% grand average
cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TF102lBLgavg         = ft_freqgrandaverage(cfg, sub7TF102lBL, sub8TF102lBL, sub9TF102lBL, sub10TF102lBL,...
    sub11TF102lBL, sub12TF102lBL, sub13TF102lBL, sub14TF102lBL, sub15TF102lBL, sub16TF102lBL, sub17TF102lBL,...
    sub18TF102lBL, sub19TF102lBL, sub21TF102lBL, sub22TF102lBL, sub25TF102lBL, sub26TF102lBL, sub27TF102lBL, sub28TF102lBL);

TF104lBLgavg         = ft_freqgrandaverage(cfg, sub7TF104lBL, sub8TF104lBL, sub9TF104lBL, sub10TF104lBL,...
    sub11TF104lBL, sub12TF104lBL, sub13TF104lBL, sub14TF104lBL, sub15TF104lBL, sub16TF104lBL, sub17TF104lBL,...
    sub18TF104lBL, sub19TF104lBL, sub21TF104lBL, sub22TF104lBL, sub25TF104lBL, sub26TF104lBL, sub27TF104lBL, sub28TF104lBL);

TF106lBLgavg         = ft_freqgrandaverage(cfg, sub7TF106lBL, sub8TF106lBL, sub9TF106lBL, sub10TF106lBL,...
    sub11TF106lBL, sub12TF106lBL, sub13TF106lBL, sub14TF106lBL, sub15TF106lBL, sub16TF106lBL, sub17TF106lBL,...
    sub18TF106lBL, sub19TF106lBL, sub21TF106lBL, sub22TF106lBL, sub25TF106lBL, sub26TF106lBL, sub27TF106lBL, sub28TF106lBL);

TF108lBLgavg         = ft_freqgrandaverage(cfg, sub7TF108lBL, sub8TF108lBL, sub9TF108lBL, sub10TF108lBL,...
    sub11TF108lBL, sub12TF108lBL, sub13TF108lBL, sub14TF108lBL, sub15TF108lBL, sub16TF108lBL, sub17TF108lBL,...
    sub18TF108lBL, sub19TF108lBL, sub21TF108lBL, sub22TF108lBL, sub25TF108lBL, sub26TF108lBL, sub27TF108lBL, sub28TF108lBL);

cd /home/meg/Data/Maor/Hypnosis/Subjects
save TFlBLgavgs TF102lBLgavg TF104lBLgavg TF106lBLgavg TF108lBLgavg
clear all
load TFlBLgavgs

%% plots
TF102lBLgavg.powspctrm = TF102lBLgavg.powspctrm.*10^28;
TF104lBLgavg.powspctrm = TF104lBLgavg.powspctrm.*10^28;
TF106lBLgavg.powspctrm = TF106lBLgavg.powspctrm.*10^28;
TF108lBLgavg.powspctrm = TF108lBLgavg.powspctrm.*10^28;
cfg              = [];
cfg.zlim        = [-10 7];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
figure;
subplot(2,2,1)
ft_singleplotTFR(cfg, TF104lBLgavg);
title('pre left')
subplot(2,2,2)
ft_singleplotTFR(cfg, TF108lBLgavg);
title('post left')
subplot(2,2,3)
ft_singleplotTFR(cfg, TF102lBLgavg);
title('pre right')
subplot(2,2,4)
ft_singleplotTFR(cfg, TF106lBLgavg);
title('post right')

%%  statistics: F-test
cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesF';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG', '-A41'};
% cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
        cfg.correctm = 'cluster';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
cfg.neighbours = ft_neighbourselection(cfg1);
cd '/home/meg/Data/Maor/Hypnosis/Subjects'
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:4*19) = [ones(1,19) 2*ones(1,19) 3*ones(1,19) 4*ones(1,19)];
cfg.design(2,1:4*19) = [1:19 1:19 1:19 1:19];
cfg.ivar =1;
cfg.uvar =2;
cfg.avgovertime = 'yes'; % cfg.avgovertime = 'no';
cfg.avgoverfreq = 'yes'; % cfg.avgoverfreq = 'no';

cfg.latency     = [0.316 0.5];
cfg.frequency   = [8 12];

[stat] = ft_freqstatistics(cfg, TF102lBLgavg, TF104lBLgavg, TF106lBLgavg, TF108lBLgavg);
disp('neg clusters:');
stat.negclusters.prob
disp('pos clusters:');
stat.posclusters.prob

stat.stat2 = stat.mask.*stat.stat; %  gives significatif F-value
stat.stat2
%% plot results
figure
cfg=[];
cfg.colorbar='yes';
cfg.parameter = 'stat2';
cfg.layout = '4D248.lay';
ft_clusterplot(cfg, stat)

%% post-hoc analysis
% for right hand
channsIndx = find(stat.stat2);
channs = stat.label(channsIndx); % only significant channels from the ANOVA
cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = channs; % only significant channels from the ANOVA % cfg.channel = {'MEG', '-A41'};
% cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
        cfg.correctm = 'cluster';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
cfg.neighbours = ft_neighbourselection(cfg1);
cd '/home/meg/Data/Maor/Hypnosis/Subjects'
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:2*19) = [ones(1,19) 2*ones(1,19)];
cfg.design(2,1:2*19) = [1:19 1:19];
cfg.ivar =1;
cfg.uvar =2;
cfg.avgovertime = 'yes'; % cfg.avgovertime = 'no';
cfg.avgoverfreq = 'yes'; % cfg.avgoverfreq = 'no';

cfg.latency     = [0.316 0.5];
cfg.frequency   = [8 12];

[stat] = ft_freqstatistics(cfg, TF104lBLgavg, TF108lBLgavg);
disp('neg clusters:');
stat.negclusters.prob
disp('pos clusters:');
stat.posclusters.prob

stat.stat2 = stat.mask.*stat.stat; %  gives significatif F-value
stat.stat2

%% SPSS tables for 8-12Hz 316-500ms
TF102lBL = mean(mean(mean(TF102lBLgavg.powspctrm(:,channsIndx,4:6,28:34),4),3),2);
TF104lBL = mean(mean(mean(TF104lBLgavg.powspctrm(:,channsIndx,4:6,28:34),4),3),2);
TF106lBL = mean(mean(mean(TF106lBLgavg.powspctrm(:,channsIndx,4:6,28:34),4),3),2);
TF108lBL = mean(mean(mean(TF108lBLgavg.powspctrm(:,channsIndx,4:6,28:34),4),3),2);

load LRpairs
chansL = ismember(TF102lBLgavg.label, LRpairs(:,1));
chansR = ismember(TF102lBLgavg.label, LRpairs(:,2));
TF102lBL_L = mean(mean(mean(TF102lBLgavg.powspctrm(:,find(chansL),4:6,28:34),4),3),2);
TF104lBL_R = mean(mean(mean(TF104lBLgavg.powspctrm(:,find(chansR),4:6,28:34),4),3),2);
TF106lBL_L = mean(mean(mean(TF106lBLgavg.powspctrm(:,find(chansL),4:6,28:34),4),3),2);
TF108lBL_R = mean(mean(mean(TF108lBLgavg.powspctrm(:,find(chansR),4:6,28:34),4),3),2);

[H,P,CI,STATS]=ttest(TF102lBL_L,TF106lBL_L)
[H,P,CI,STATS]=ttest(TF104lBL_R,TF108lBL_R)