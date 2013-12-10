clear all
clc
cfg = [];
sub = 28;
eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),])

cfgTemp                     = [];
cfgTemp.dataset             = 'xc,hb,lf_c,rfhp0.1Hz';
cfgTemp.trialdef.eventtype  = 'TRIGGER';
cfgTemp.trialdef.eventvalue = [102 104 106 108];
cfgTemp.trialdef.prestim    = 0; % time before trigger onset
cfgTemp.trialdef.poststim   = 0.2; % time after trigger onset
cfgTemp.trialdef.offset     = 0; % defining the real zero: can be different than prestim
cfgTemp.trialfun            = 'BIUtrialfun'; % use the unique parameters of the Bar Ilan MEG
cfgTemp                     = ft_definetrial(cfgTemp);
trl                         = cfgTemp.trl;

PreStart  = trl(1,1);
PreEnd    = trl(max([max(find(trl(:,4)==102)),max(find(trl(:,4)==104))]),1);
PostStart = trl(min([min(find(trl(:,4)==106)),min(find(trl(:,4)==108))]),1);
PostEnd   = trl(end,1);

eval(['clear cfgTemp sub',num2str(sub),'average sub',num2str(sub),'con102 sub',num2str(sub),'con104 sub',num2str(sub),'con106 sub',num2str(sub),'con108'])

epoched1 = PreStart:1017:PreEnd-2034;
epoched2 = PostStart:1017:PostEnd-2034;
epoched1 = round(epoched1);
epoched2 = round(epoched2);

trl1(1:size(epoched1,2),1) = epoched1';
trl1(1:size(epoched1,2),2) = epoched1'+2034;
trl1(1:size(epoched1,2),3) = 0;
trl1(1:size(epoched1,2),4) = 10;
trl2(1:size(epoched2,2),1) = epoched2';
trl2(1:size(epoched2,2),2) = epoched2'+2034;
trl2(1:size(epoched2,2),3) = 0;
trl2(1:size(epoched2,2),4) = 20;

cfg.trl = [trl1;trl2];

% definetrial
source       = 'xc,hb,lf_c,rfhp0.1Hz'; % change if necesary
cfg.dataset  = source;
cfg.trialfun = 'trialfun_beg';
cfg          = ft_definetrial(cfg);

% preprocessing for muscle artifact rejection
cfg.demean     = 'no'; 
cfg.continuous = 'yes';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 60;
cfg.channel    = 'MEG'; 
dataorig       = ft_preprocessing(cfg);

% remove muscle artifact
cfg1.method = 'summary'; %trial
datacln     = ft_rejectvisual(cfg1, dataorig);

% to see again
datacln = ft_rejectvisual(cfg1, datacln);

% Deleting the bad trials from the original data so you don't refilter the data
cfg.trl      = [];
cfg.trl      = datacln.sampleinfo;
cfg.trl(:,3) = 0; % change according to your offset in samples!!!
cfg.trl(:,4) = datacln.trialinfo;

% preprocessing original data without the bad trials
cfg.demean      = 'no'; 
cfg.continuous  = 'yes';
cfg.hpfilter    = 'no';
cfg.bpfilter    = 'yes';
cfg.bpfreq      = [0.2 100];
cfg.padding     = 10; 
cfg.channel     = {'MEG','-A41'}; % cfg.channel = 'MEG';
dataorig        = ft_preprocessing(cfg);

% ICA
% resampling data to speed up the ica
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy          = ft_resampledata(cfg, dataorig); % if you used 5.2 so change to datacln

% run ica (it takes a long time have a break)
cfg         = [];
cfg.channel = {'MEG','-A41'}; % cfg.channel = 'MEG';
comp_dummy  = ft_componentanalysis(cfg, dummy);

% see the components and find the artifacts
cfgb            = [];
cfgb.layout     = '4D248.lay';
cfgb.channel    = {comp_dummy.label{1:10}};
cfgb.continuous = 'no';
comppic         = ft_databrowser(cfgb,comp_dummy);

% cool visualization for one component (e.g.,comp = 3) along trials and time (after resampling)  
seeOneComp(comp_dummy,2) % change the number of components you want to see

% run the ICA on the original data
cfg           = [];
cfg.topo      = comp_dummy.topo;
cfg.topolabel = comp_dummy.topolabel;
comp          = ft_componentanalysis(cfg, dataorig);

% remove the artifact components
cfg           = [];
cfg.component = [10]; % change
dataica       = ft_rejectcomponent(cfg, comp);

% trial by trial
cfg           = [];
cfg.method    = 'trial'; % 'channel'
cfg.channel   = {'MEG','-A41'}; % cfg.channel='MEG';
cfg1.bpfilter = 'yes';
cfg1.bpfreq   = [0.2 100];
datafinal     = ft_rejectvisual(cfg, dataica);

% recreating the trl
datafinal.cfg.trl      = datafinal.sampleinfo;
datafinal.cfg.trl(:,3) = 0; % the offset
datafinal.cfg.trl(:,4) = datafinal.trialinfo(:,1);

% perform spectral analysis using fft
cfg            = [];
cfg.output     = 'pow';
cfg.method     = 'mtmfft';
cfg.taper      = 'hanning';
cfg.foilim     = [0.2 100]; % all frequencies
cfg.tapsmofrq  = 1;
cfg.keeptrials = 'no';
cfg.channel    = {'MEG','-A41'}; % cfg.channel='MEG';

cfg.trials  = (find(datafinal.cfg.trl(:,4)==10))'
spectPreHyp = ft_freqanalysis(cfg,datafinal);

cfg.trials   = (find(datafinal.cfg.trl(:,4)==20))'
spectPostHyp = ft_freqanalysis(cfg,datafinal);

mkdir('0.2_100Hz');
save 0.2_100Hz/powSpect spectPreHyp spectPostHyp
clear all
load 0.2_100Hz/powSpect

% ploting
plot(mean(spectPreHyp.powspctrm));
hold on;
plot(mean(spectPostHyp.powspctrm),'r');
title('blue - Pre Hypnosis; red - Post Hypnosis');

%% grand average
clear all
subs = [7:12, 14:19, 21, 25:28];
for sub=subs
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/0.2_100Hz/powSpect']);
    eval(['spectPostHyp',num2str(sub),'=spectPostHyp;']);
    eval(['spectPreHyp',num2str(sub),'=spectPreHyp;']);
    clear spectPostHyp spectPreHyp
end;

% excluding channels A41 and A212
sub=[];
for sub=[9,10,16,17,21,28]
    eval(['spectPostHyp',num2str(sub),'.label(216,:)=[];']);
    eval(['spectPostHyp',num2str(sub),'.powspctrm(216,:)=[];']);
    eval(['spectPreHyp',num2str(sub),'.label(216,:)=[];']);
    eval(['spectPreHyp',num2str(sub),'.powspctrm(216,:)=[];']);
end;
sub=[];
for sub=[7:12, 14:16, 18, 19, 21, 25:27]
    eval(['spectPostHyp',num2str(sub),'.label(84,:)=[];']);
    eval(['spectPostHyp',num2str(sub),'.powspctrm(84,:)=[];']);
    eval(['spectPreHyp',num2str(sub),'.label(84,:)=[];']);
    eval(['spectPreHyp',num2str(sub),'.powspctrm(84,:)=[];']);
end;

% averaging

spectPostHypMean=spectPostHyp10;

for chan=1:246
    spectPostHypMean.powspctrm(chan,:)=mean([spectPostHyp7.powspctrm(chan,:); spectPostHyp8.powspctrm(chan,:); spectPostHyp9.powspctrm(chan,:); spectPostHyp10.powspctrm(chan,:);...
    spectPostHyp11.powspctrm(chan,:); spectPostHyp12.powspctrm(chan,:); spectPostHyp14.powspctrm(chan,:); spectPostHyp15.powspctrm(chan,:); spectPostHyp16.powspctrm(chan,:); spectPostHyp17.powspctrm(chan,:);...
    spectPostHyp18.powspctrm(chan,:); spectPostHyp19.powspctrm(chan,:); spectPostHyp21.powspctrm(chan,:); spectPostHyp25.powspctrm(chan,:); spectPostHyp26.powspctrm(chan,:); spectPostHyp27.powspctrm(chan,:);...
    spectPostHyp28.powspctrm(chan,:)]);
end;

spectPreHypMean=spectPreHyp10;

for chan=1:246
    spectPreHypMean.powspctrm(chan,:)=mean([spectPreHyp7.powspctrm(chan,:); spectPreHyp8.powspctrm(chan,:); spectPreHyp9.powspctrm(chan,:); spectPreHyp10.powspctrm(chan,:);...
    spectPreHyp11.powspctrm(chan,:); spectPreHyp12.powspctrm(chan,:); spectPreHyp14.powspctrm(chan,:); spectPreHyp15.powspctrm(chan,:); spectPreHyp16.powspctrm(chan,:); spectPreHyp17.powspctrm(chan,:);...
    spectPreHyp18.powspctrm(chan,:); spectPreHyp19.powspctrm(chan,:); spectPreHyp21.powspctrm(chan,:); spectPreHyp25.powspctrm(chan,:); spectPreHyp26.powspctrm(chan,:); spectPreHyp27.powspctrm(chan,:);...
    spectPreHyp28.powspctrm(chan,:)]);
end;

% ploting the grand averages
plot(mean(spectPreHypMean.powspctrm));
hold on;
plot(mean(spectPostHypMean.powspctrm),'r');
title('blue - Pre Hypnosis; red - Post Hypnosis');

%% Left channels Vs. Right channels
clear all
% creating a template stracture for later on coping the average data on to 
sub=7;
eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/0.2_100Hz/powSpect']);
spectTemplate = spectPreHyp;
clear spectPreHyp spectPostHyp sub
% creating power spectrum for Right channs and Left channs sperately for
% Pre and Post
load LRpairs
subs = [7:12, 14:19, 21, 25:28];
for sub=subs
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/0.2_100Hz/powSpect']);
    % excluding channs A41 and A212 from all subs
    if ismember(sub,[9,10,16,17,21,28])
        spectPostHyp.label(216,:)=[];
        spectPostHyp.powspctrm(216,:)=[];
        spectPreHyp.label(216,:)=[];
        spectPreHyp.powspctrm(216,:)=[];
    end;
    if ismember(sub,[7:12, 14:16, 18, 19, 21, 25:27])
        spectPostHyp.label(84,:)=[];
        spectPostHyp.powspctrm(84,:)=[];
        spectPreHyp.label(84,:)=[];
        spectPreHyp.powspctrm(84,:)=[];
    end;
    eval(['spectPostHyp',num2str(sub),'=spectPostHyp;']);
    eval(['spectPreHyp',num2str(sub),'=spectPreHyp;']);
    eval(['chansLeftPre=ismember(spectPreHyp',num2str(sub),'.label,LRpairs(:,1));']);
    eval(['chansRightPre=ismember(spectPreHyp',num2str(sub),'.label,LRpairs(:,2));']);
    eval(['chansLeftPost=ismember(spectPostHyp',num2str(sub),'.label,LRpairs(:,1));']);
    eval(['chansRightPost=ismember(spectPostHyp',num2str(sub),'.label,LRpairs(:,2));']);
    eval(['PreHypLeft',num2str(sub),'=spectPreHyp',num2str(sub),'.powspctrm(find(chansLeftPre),:);']); % creates a power spectrum data matrix only of the left channels for PreHyp
    eval(['PreHypRight',num2str(sub),'=spectPreHyp',num2str(sub),'.powspctrm(find(chansRightPre),:);']);
    eval(['PostHypLeft',num2str(sub),'=spectPostHyp',num2str(sub),'.powspctrm(find(chansLeftPost),:);']);
    eval(['PostHypRight',num2str(sub),'=spectPostHyp',num2str(sub),'.powspctrm(find(chansRightPost),:);']);
    eval(['clear spectPostHyp spectPreHyp chansLeftPre chansRightPre chansLeftPost chansLeftPost spectPreHyp',num2str(sub),' spectPostHyp',num2str(sub)]);
end;

% averaging
%----------
% Post Right
PostHypRightMean = spectTemplate;
PostHypRightMean.powspctrm = [];
for chan=1:115
    PostHypRightMean.powspctrm(chan,:)=mean([PostHypRight7(chan,:); PostHypRight8(chan,:); PostHypRight9(chan,:); PostHypRight10(chan,:);...
    PostHypRight11(chan,:); PostHypRight12(chan,:); PostHypRight14(chan,:); PostHypRight15(chan,:); PostHypRight16(chan,:); PostHypRight17(chan,:);...
    PostHypRight18(chan,:); PostHypRight19(chan,:); PostHypRight21(chan,:); PostHypRight25(chan,:); PostHypRight26(chan,:); PostHypRight27(chan,:);...
    PostHypRight28(chan,:)]);
end;
% Post Left
PostHypLeftMean = spectTemplate;
PostHypLeftMean.powspctrm = [];
for chan=1:113
    PostHypLeftMean.powspctrm(chan,:)=mean([PostHypLeft7(chan,:); PostHypLeft8(chan,:); PostHypLeft9(chan,:); PostHypLeft10(chan,:);...
    PostHypLeft11(chan,:); PostHypLeft12(chan,:); PostHypLeft14(chan,:); PostHypLeft15(chan,:); PostHypLeft16(chan,:); PostHypLeft17(chan,:);...
    PostHypLeft18(chan,:); PostHypLeft19(chan,:); PostHypLeft21(chan,:); PostHypLeft25(chan,:); PostHypLeft26(chan,:); PostHypLeft27(chan,:);...
    PostHypLeft28(chan,:)]);
end;
% Pre Right
PreHypRightMean = spectTemplate;
PreHypRightMean.powspctrm = [];
for chan=1:115
    PreHypRightMean.powspctrm(chan,:)=mean([PreHypRight7(chan,:); PreHypRight8(chan,:); PreHypRight9(chan,:); PreHypRight10(chan,:);...
    PreHypRight11(chan,:); PreHypRight12(chan,:); PreHypRight14(chan,:); PreHypRight15(chan,:); PreHypRight16(chan,:); PreHypRight17(chan,:);...
    PreHypRight18(chan,:); PreHypRight19(chan,:); PreHypRight21(chan,:); PreHypRight25(chan,:); PreHypRight26(chan,:); PreHypRight27(chan,:);...
    PreHypRight28(chan,:)]);
end;
% Pre Left
PreHypLeftMean = spectTemplate;
PreHypLeftMean.powspctrm = [];
for chan=1:113
    PreHypLeftMean.powspctrm(chan,:)=mean([PreHypLeft7(chan,:); PreHypLeft8(chan,:); PreHypLeft9(chan,:); PreHypLeft10(chan,:);...
    PreHypLeft11(chan,:); PreHypLeft12(chan,:); PreHypLeft14(chan,:); PreHypLeft15(chan,:); PreHypLeft16(chan,:); PreHypLeft17(chan,:);...
    PreHypLeft18(chan,:); PreHypLeft19(chan,:); PreHypLeft21(chan,:); PreHypLeft25(chan,:); PreHypLeft26(chan,:); PreHypLeft27(chan,:);...
    PreHypLeft28(chan,:)]);
end;

save powSpctrmLvsR PreHypLeftMean PreHypRightMean PostHypLeftMean PostHypRightMean
clear all
load powSpctrmLvsR

% ploting
subplot(2,1,1)
plot(mean(PreHypLeftMean.powspctrm));
hold on;
plot(mean(PostHypLeftMean.powspctrm),'r');
title('blue - Pre Hypnosis Left Channels; red - Post Hypnosis Left Channels');
subplot(2,1,2)
plot(mean(PreHypRightMean.powspctrm));
hold on;
plot(mean(PostHypRightMean.powspctrm),'r');
title('blue - Pre Hypnosis Right Channels; red - Post Hypnosis Right Channels');

%% multiple topoplots
figure;
cfg=[];
cfg.xlim=[1:1:20];
ft_topoplotER(cfg,spectRest);
figure;
cfg=[];
cfg.xlim=[21:1:40];
ft_topoplotER(cfg,spectRest);
% topoplot for alpha
figure;
cfg=[]; 
cfg.xlim=[8 12];
cfg.colorbar='yes';
ft_topoplotER(cfg,spectEnter);
title('Enter Hynposis - Alpha')

figure;
cfg=[]; 
cfg.xlim=[8 12];
cfg.colorbar='yes';
ft_topoplotER(cfg,spectExit);
title('Exit Hynposis - Alpha')

% topoplot for beta
figure;
cfg=[]; 
cfg.xlim=[13 30];
cfg.colorbar='yes';
ft_topoplotER(cfg,spectEnter);
title('Enter Hynposis - Beta')

figure;
cfg=[]; 
cfg.xlim=[13 30];
cfg.colorbar='yes';
ft_topoplotER(cfg,spectExit);
title('Exit Hynposis - Beta')

% topoplot for gamma
figure;
cfg=[];
cfg.xlim=[30 80];
cfg.colorbar='yes';
ft_topoplotER(cfg,spect);
title('Gamma')

% topoplot for delta
figure;
cfg=[]; 
cfg.xlim=[1 4];
cfg.colorbar='yes';
ft_topoplotER(cfg,spect);
title('Delta')

% topoplot for theta
figure;
cfg=[]; 
cfg.xlim=[4 7];
cfg.colorbar='yes';
ft_topoplotER(cfg,spect);
title('Theta')

save powspctrmRest spect
