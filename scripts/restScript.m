%% cleaning heart beats, 50Hz and more using Abeles and Tal's script
fileName = 'c,rfhp0.1Hz';
p=pdf4D(fileName);
cleanCoefs = createCleanFile(p, fileName,...
    'byLF',512,'Method','Adaptive',...
    'xClean',[4,5,6],...
    'chans2ignore',[],...
    'byFFT',0,...
    'HeartBeat',[],... % use [] for automatic HB cleaning, use 0 to avoid HB cleaning
    'maskTrigBits', 512);

%% create the trl matrix
clear all;
s=1; % in seconds
e=120; % in seconds
epochedRest=s*1017:508.5:(e*1017)-1017;
epochedRest=round(epochedRest);

trlRest(1:size(epochedRest,2),1)=epochedRest';
trlRest(1:size(epochedRest,2),2)=epochedRest'+1017;
trlRest(1:size(epochedRest,2),3)=0;
trlRest(1:size(epochedRest,2),4)=10; % code for rest

cfg.trl=trlRest;


%% Definetrial
source= 'xc,lf_c,rfhp0.1Hz'; % change if necesary
cfg.dataset=source;
cfg.trialfun='trialfun_beg';
cfg=ft_definetrial(cfg);

%% find bad channels
findBadChans(source);

%% Preprocessing
cfg.demean='no'; % normalize the data according to the base line average time1min window (see two lines below)
cfg.continuous='yes';
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[0.1 200];
cfg.channel = 'MEG'; %cfg.channel = {'MEG','-A74'}; %MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig=ft_preprocessing(cfg);

% hdr=ft_read_header('xc,hb,lf_c1,rfhp0.1Hz'); % if I need to see the
% number of samples in the original data

save dataRest dataorig
%% remove muscle artifact
cfg1=[];
cfg1.method='summary'; %trial
cfg1.channel='MEG'; %cfg1.channel = {'MEG','-A74'};
cfg1.hpfilter='yes';
cfg1.hpfreq=60;
datacln=ft_rejectvisual(cfg1, dataorig);

% to see again
datacln=ft_rejectvisual(cfg, datacln);

% back to original data with base line correction
datacln.cfg.trl=datacln.sampleinfo;
datacln.cfg.trl(:,3)=0;
datacln=ft_preprocessing(cfg,datacln);

%% ICA
% resampling data to speed up the ica

cfg2=cfg;
cfg2.bpfreq=[1 40];
data4ica=ft_preprocessing(cfg2,datacln);

cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy           = ft_resampledata(cfg, data4ica);

% run ica (it takes a long time have a break)
cfg            = [];
cfg.channel    = 'MEG'; %cfg.channel = {'MEG','-A74'}; 
comp_dummy     = ft_componentanalysis(cfg, dummy);

% see the components and find the artifacts
cfgb=[];
cfgb.layout='4D248.lay';
cfgb.channel = {comp_dummy.label{1:10}};
cfgb.continuous='no';
comppic=ft_databrowser(cfgb,comp_dummy);

% run the ICA on the original data
cfg = [];
cfg.topo      = comp_dummy.topo;
cfg.topolabel = comp_dummy.topolabel;
comp     = ft_componentanalysis(cfg, datacln);

% remove the artifact components
cfg = [];
cfg.component = [1 2 3 6]; % change
dataica = ft_rejectcomponent(cfg, comp);

% recreating the trl
dataica.cfg.trl=dataica.sampleinfo;
dataica.cfg.trl(:,3)=0;
dataica.cfg.trl(:,4)=dataica.trialinfo;

%% PCA in case ICA failed and then change ica to pca in the rest of the script
% cfg2=cfg;
% cfg2.bpfreq=[1 40];
% data4pca=ft_preprocessing(cfg2,datacln);
% 
% cfg  = [];
% cfg.method='pca';
% comp = ft_componentanalysis(cfg, data4pca);
% 
% %see the components and find the artifact
% cfg=[];
% cfg.comp=1:10;
% cfg.layout='4D248.lay';
% comppic=ft_databrowser(cfg,comp);
% 
% cfg = [];
% cfg.component = [3 4]; % change
% datapca = ft_rejectcomponent(cfg, comp);
% 
% % recreating the trl
% datapca.cfg.trl=datapca.sampleinfo;
% datapca.cfg.trl(:,3)=0;
% datapca.cfg.trl(:,4)=datapca.trialinfo;

%% perform spectral analysis using fft

cfg            = [];
cfg.output     = 'pow';
cfg.method     = 'mtmfft';
cfg.taper      = 'hanning';
cfg.foilim     = [0.1 200]; % all frequencies
cfg.tapsmofrq  = 1;
cfg.keeptrials = 'no';
cfg.channel    = 'MEG'; %cfg.channel = {'MEG','-A74'}; 

cfg.trials=(find(dataica.cfg.trl(:,4)==10))'
spectRest =ft_freqanalysis(cfg,dataica);

save powSpectRest spectRest
clear all
load powSpectRest

% ploting
plot(mean(spectRest.powspctrm));

% multiple topoplots
figure;
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[1:1:20];
ft_topoplotER(cfg,spectRest);

figure;
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[21:1:40];
ft_topoplotER(cfg,spectRest);

% topoplot for alpha
figure;
cfg=[]; 
cfg.layout='4D248.lay';
cfg.xlim=[8 12];
cfg.colorbar='yes';
ft_topoplotER(cfg,spectEnter);
title('Enter Hynposis - Alpha')

figure;
cfg=[]; 
cfg.layout='4D248.lay';
cfg.xlim=[8 12];
cfg.colorbar='yes';
ft_topoplotER(cfg,spectExit);
title('Exit Hynposis - Alpha')

% topoplot for beta
figure;
cfg=[]; 
cfg.layout='4D248.lay';
cfg.xlim=[13 30];
cfg.colorbar='yes';
ft_topoplotER(cfg,spectEnter);
title('Enter Hynposis - Beta')

figure;
cfg=[]; 
cfg.layout='4D248.lay';
cfg.xlim=[13 30];
cfg.colorbar='yes';
ft_topoplotER(cfg,spectExit);
title('Exit Hynposis - Beta')

% topoplot for gamma
figure;
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[30 80];
cfg.colorbar='yes';
ft_topoplotER(cfg,spect);
title('Gamma')

% topoplot for delta
figure;
cfg=[]; 
cfg.layout='4D248.lay';
cfg.xlim=[1 4];
cfg.colorbar='yes';
ft_topoplotER(cfg,spect);
title('Delta')

% topoplot for theta
figure;
cfg=[]; 
cfg.layout='4D248.lay';
cfg.xlim=[4 7];
cfg.colorbar='yes';
ft_topoplotER(cfg,spect);
title('Theta')

% grandaverage for SZ
cfg=[];
cfg.keepindividual = 'yes'
%cfg.foilim         = [fmin fmax]
%cfg.channel        = Nx1 cell-array with selection of channels
grAvgRestSZ=ft_freqgrandaverage(cfg,spectRestSub13,spectRestSub14,spectRestSub16,spectRestSub17,spectRestSub19,spectRestSub21,spectRestSub22,spectRestSub23,spectRestSub24);

cfg=[];
cfg.keepindividual = 'yes'
%cfg.foilim         = [fmin fmax]
%cfg.channel        = Nx1 cell-array with selection of channels
grAvgRestCon=ft_freqgrandaverage(cfg,spectRestSub09,spectRestSub10,spectRestSub11,spectRestSub12,spectRestSub15,spectRestSub20);


% ploting the average
clear x y
x=grAvgRestSZ;
x.powspctrm=mean(x.powspctrm);
y(1:247,1:201)=x.powspctrm(1,1:247,1:201);
x.powspctrm=[];
x.powspctrm=y;
x.dimord='chan_freq';
plot(mean(x.powspctrm));

hold on;
clear x y
x=grAvgRestCon;
x.powspctrm=mean(x.powspctrm);
y(1:247,1:201)=x.powspctrm(1,1:247,1:201);
x.powspctrm=[];
x.powspctrm=y;
x.dimord='chan_freq';
plot(mean(x.powspctrm),'r');

% topoplots for the peaks
figure;
subplot(1,2,1);
cfg=[]; 
cfg.layout='4D248.lay';
cfg.xlim=[1 4];
cfg.zlim=[1.82*10^(-27) 1.29*10^(-26)];
cfg.colorbar='yes';
ft_topoplotER(cfg,grAvgRestCon);
title('Control (n=7) - Delta (1-4Hz)');
subplot(1,2,2);
ft_topoplotER(cfg,grAvgRestSZ);
title('SZ (n=8) - Delta (1-4Hz)');

figure;
subplot(1,2,1);
cfg=[]; 
cfg.layout='4D248.lay';
cfg.xlim=[8 14];
cfg.zlim=[3.68*10^(-28) 7.51*10^(-27)];
cfg.colorbar='yes';
ft_topoplotER(cfg,grAvgRestCon);
title('Control (n=7) - Alpha (8-14Hz)');
subplot(1,2,2);
ft_topoplotER(cfg,grAvgRestSZ);
title('SZ (n=8) - Alpha (8-14Hz)');