%% cleaning heart beats, 50Hz and more using Abeles and Tal's script
fileName = 'c,rfhp0.1Hz';
p=pdf4D(fileName);
cleanCoefs = createCleanFile(p, fileName,...
    'byLF',256 ,'Method','Adaptive',...
    'xClean',[4,5,6],...
    'chans2ignore',[],...
    'byFFT',0,...
    'HeartBeat',[],... % use [] for automatic HB cleaning, use 0 to avoid HB cleaning
    'maskTrigBits', 512);


%% find Bad Channels
source='xc,hb,lf_c,rfhp0.1Hz';
findBadChans(source);


%% create the trl matrix
clear all;
load /home/meg/Data/Maor/Hypnosis/time1min % time1min table in samples of begining and end of each stage
sub=1;

str=['restS=time1min(',num2str(sub),',1)'];
eval(str);
str=['restE=time1min(',num2str(sub),',2)'];
eval(str);

str=['enterS=time1min(',num2str(sub),',3)'];
eval(str);
str=['enterE=time1min(',num2str(sub),',4)'];
eval(str);

str=['halfS=time1min(',num2str(sub),',5)'];
eval(str);
str=['halfE=time1min(',num2str(sub),',6)'];
eval(str);

str=['outerS=time1min(',num2str(sub),',7)'];
eval(str);
str=['outerE=time1min(',num2str(sub),',8)'];
eval(str);

str=['exitS=time1min(',num2str(sub),',9)'];
eval(str);
str=['exitE=time1min(',num2str(sub),',10)'];
eval(str);

epochedRest=restS:508.5:restE-1017;
epochedRest=round(epochedRest);

trlRest(1:size(epochedRest,2),1)=epochedRest';
trlRest(1:size(epochedRest,2),2)=epochedRest'+1017;
trlRest(1:size(epochedRest,2),3)=0;
trlRest(1:size(epochedRest,2),4)=10; % code for rest

epochedEnter=enterS:508.5:enterE-1017;
epochedEnter=round(epochedEnter);

trlEnter(1:size(epochedEnter,2),1)=epochedEnter';
trlEnter(1:size(epochedEnter,2),2)=epochedEnter'+1017;
trlEnter(1:size(epochedEnter,2),3)=0;
trlEnter(1:size(epochedEnter,2),4)=20; % code for entering hypnosis

epochedHalf=halfS:508.5:halfE-1017;
epochedHalf=round(epochedHalf);

trlHalf(1:size(epochedHalf,2),1)=epochedHalf';
trlHalf(1:size(epochedHalf,2),2)=epochedHalf'+1017;
trlHalf(1:size(epochedHalf,2),3)=0;
trlHalf(1:size(epochedHalf,2),4)=30; % code for half body experience

epochedOuter=outerS:508.5:outerE-1017;
epochedOuter=round(epochedOuter);

trlOuter(1:size(epochedOuter,2),1)=epochedOuter';
trlOuter(1:size(epochedOuter,2),2)=epochedOuter'+1017;
trlOuter(1:size(epochedOuter,2),3)=0;
trlOuter(1:size(epochedOuter,2),4)=40; % code for outer body experience

epochedExit=exitS:508.5:exitE-1017;
epochedExit=round(epochedExit);

trlExit(1:size(epochedExit,2),1)=epochedExit';
trlExit(1:size(epochedExit,2),2)=epochedExit'+1017;
trlExit(1:size(epochedExit,2),3)=0;
trlExit(1:size(epochedExit,2),4)=80; % code for exiting hypnosis

cfg1.trl=trlRest;
cfg2.trl=trlEnter;
cfg3.trl=trlHalf;
cfg4.trl=trlOuter;
cfg5.trl=trlExit;

cfg.trl=trlRest;
cfg.trl(size(cfg.trl,1)+1:size(cfg.trl,1)+119,:)=cfg2.trl(:,:);
cfg.trl(size(cfg.trl,1)+1:size(cfg.trl,1)+119,:)=cfg3.trl(:,:);
cfg.trl(size(cfg.trl,1)+1:size(cfg.trl,1)+119,:)=cfg4.trl(:,:);
cfg.trl(size(cfg.trl,1)+1:size(cfg.trl,1)+119,:)=cfg5.trl(:,:);

save trl1min cfg
clear all
load trl1min

%% Definetrial
source= 'xc,hb,lf_c,rfhp0.1Hz'; % change if necesary
cfg.dataset=source;
cfg.trialfun='trialfun_beg';
cfg=ft_definetrial(cfg);

%% find bad channels
%findBadChans(source);

cfg.channel= 'MEG'; % {'MEG','-A74','-A204'}; 

%% Preprocessing
cfg.demean='no'; % normalize the data according to the base line average time1min window (see two lines below)
cfg.continuous='yes';
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[0.1 200];
cfg.padding=2; % expend the trials to 2s (in this case adding 0.5s to the begining and end of the trial)
cfg.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig=ft_preprocessing(cfg);

% hdr=ft_read_header('xc,hb,lf_c1,rfhp0.1Hz'); % if I need to see the
% number of samples in the original data

save dataorig1min dataorig
%% remove muscle artifact
cfg1=[];
cfg1.method='summary'; %trial
cfg1.channel='MEG';
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
cfg.channel    = 'MEG';
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
cfg.component = [1]; % change
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
cfg.channel    = 'MEG';

cfg.trials=(find(dataica.cfg.trl(:,4)==10))'
spectRest =ft_freqanalysis(cfg,dataica);

cfg.trials=(find(dataica.cfg.trl(:,4)==20))'
spectEnter =ft_freqanalysis(cfg,dataica);

cfg.trials=(find(dataica.cfg.trl(:,4)==30))'
spectHalf =ft_freqanalysis(cfg,dataica);

cfg.trials=(find(dataica.cfg.trl(:,4)==40))'
spectOuter =ft_freqanalysis(cfg,dataica);

cfg.trials=(find(dataica.cfg.trl(:,4)==80))'
spectExit =ft_freqanalysis(cfg,dataica);

save powSpect spectRest spectEnter spectExit spectHalf spectOuter
clear all
load powSpect

% ploting
plot(mean(spectRest.powspctrm));
hold on;
plot(mean(spectEnter.powspctrm),'r');
plot(mean(spectHalf.powspctrm),'g');
plot(mean(spectOuter.powspctrm),'k');
plot(mean(spectExit.powspctrm),'m');
title('blue - rest; red - enter; green - halfBody; black - outerBody; pink - exit');

% multiple topoplots
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
