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

%% create the trl matrix
clear all;
load /home/meg/Data/Maor/Hypnosis/timeSmpls % time table in samples of begining and end of each stage
sub=2;

str=['restS=time(',num2str(sub),',1)'];
eval(str);
str=['restE=time(',num2str(sub),',2)'];
eval(str);

str=['enterS=time(',num2str(sub),',3)'];
eval(str);
str=['enterE=time(',num2str(sub),',4)'];
eval(str);

str=['halfS=time(',num2str(sub),',5)'];
eval(str);
str=['halfE=time(',num2str(sub),',6)'];
eval(str);

str=['outerS=time(',num2str(sub),',7)'];
eval(str);
str=['outerE=time(',num2str(sub),',8)'];
eval(str);

str=['safeS=time(',num2str(sub),',9)'];
eval(str);
str=['safeE=time(',num2str(sub),',10)'];
eval(str);

str=['back2bodyS=time(',num2str(sub),',11)'];
eval(str);
str=['back2bodyE=time(',num2str(sub),',12)'];
eval(str);

str=['cnclHalfS=time(',num2str(sub),',13)'];
eval(str);
str=['cnclHalfE=time(',num2str(sub),',14)'];
eval(str);

str=['exitS=time(',num2str(sub),',15)'];
eval(str);
str=['exitE=time(',num2str(sub),',16)'];
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

epochedSafe=safeS:508.5:safeE-1017;
epochedSafe=round(epochedSafe);

trlSafe(1:size(epochedSafe,2),1)=epochedSafe';
trlSafe(1:size(epochedSafe,2),2)=epochedSafe'+1017;
trlSafe(1:size(epochedSafe,2),3)=0;
trlSafe(1:size(epochedSafe,2),4)=50; % code for safe place

epochedBack2body=back2bodyS:508.5:back2bodyE-1017;
epochedBack2body=round(epochedBack2body);

trlBack2body(1:size(epochedBack2body,2),1)=epochedBack2body';
trlBack2body(1:size(epochedBack2body,2),2)=epochedBack2body'+1017;
trlBack2body(1:size(epochedBack2body,2),3)=0;
trlBack2body(1:size(epochedBack2body,2),4)=60; % code for back to body

epochedCnclHalf=cnclHalfS:508.5:cnclHalfE-1017;
epochedCnclHalf=round(epochedCnclHalf);

trlCnclHalf(1:size(epochedCnclHalf,2),1)=epochedCnclHalf';
trlCnclHalf(1:size(epochedCnclHalf,2),2)=epochedCnclHalf'+1017;
trlCnclHalf(1:size(epochedCnclHalf,2),3)=0;
trlCnclHalf(1:size(epochedCnclHalf,2),4)=70; % code for canceling half body exprience

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
cfg5.trl=trlSafe;
cfg6.trl=trlBack2body;
cfg7.trl=trlCnclHalf;
cfg8.trl=trlExit;

save trl cfg1 cfg2 cfg3 cfg4 cfg5 cfg6 cfg7 cfg8 sub
clear all
load trl
%% Definetrial
source= 'xc,hb,lf_c,rfhp0.1Hz';
cfg1.dataset=source;
cfg1.trialfun='trialfun_beg';
cfg1=ft_definetrial(cfg1);

source= 'xc,hb,lf_c,rfhp0.1Hz';
cfg2.dataset=source;
cfg2.trialfun='trialfun_beg';
cfg2=ft_definetrial(cfg2);

source= 'xc,hb,lf_c,rfhp0.1Hz';
cfg3.dataset=source;
cfg3.trialfun='trialfun_beg';
cfg3=ft_definetrial(cfg3);

source= 'xc,hb,lf_c,rfhp0.1Hz';
cfg4.dataset=source;
cfg4.trialfun='trialfun_beg';
cfg4=ft_definetrial(cfg4);

source= 'xc,hb,lf_c,rfhp0.1Hz';
cfg5.dataset=source;
cfg5.trialfun='trialfun_beg';
cfg5=ft_definetrial(cfg5);

source= 'xc,hb,lf_c,rfhp0.1Hz';
cfg6.dataset=source;
cfg6.trialfun='trialfun_beg';
cfg6=ft_definetrial(cfg6);

source= 'xc,hb,lf_c,rfhp0.1Hz';
cfg7.dataset=source;
cfg7.trialfun='trialfun_beg';
cfg7=ft_definetrial(cfg7);

source= 'xc,hb,lf_c,rfhp0.1Hz';
cfg8.dataset=source;
cfg8.trialfun='trialfun_beg';
cfg8=ft_definetrial(cfg8);

%% find bad channels
findBadChans(source);

cfg1.channel= 'MEG'; % {'MEG','-A74','-A204'}; 
cfg2.channel= 'MEG';
cfg3.channel= 'MEG';
cfg4.channel= 'MEG';
cfg5.channel= 'MEG';
cfg6.channel= 'MEG';
cfg7.channel= 'MEG';
cfg8.channel= 'MEG';

%% Preprocessing
cfg1.blc='no'; % normalize the data according to the base line average time window (see two lines below)
cfg1.continuous='yes';
cfg1.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg1.bpfreq=[1 80];
cfg1.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig1=ft_preprocessing(cfg1);

cfg2.blc='no'; % normalize the data according to the base line average time window (see two lines below)
cfg2.continuous='yes';
cfg2.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg2.bpfreq=[1 80];
cfg2.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig2=ft_preprocessing(cfg2);

cfg3.blc='no'; % normalize the data according to the base line average time window (see two lines below)
cfg3.continuous='yes';
cfg3.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg3.bpfreq=[1 80];
cfg3.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig3=ft_preprocessing(cfg3);

cfg4.blc='no'; % normalize the data according to the base line average time window (see two lines below)
cfg4.continuous='yes';
cfg4.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg4.bpfreq=[1 80];
cfg4.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig4=ft_preprocessing(cfg4);

cfg5.blc='no'; % normalize the data according to the base line average time window (see two lines below)
cfg5.continuous='yes';
cfg5.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg5.bpfreq=[1 80];
cfg5.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig5=ft_preprocessing(cfg5);

cfg6.blc='no'; % normalize the data according to the base line average time window (see two lines below)
cfg6.continuous='yes';
cfg6.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg6.bpfreq=[1 80];
cfg6.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig6=ft_preprocessing(cfg6);

cfg7.blc='no'; % normalize the data according to the base line average time window (see two lines below)
cfg7.continuous='yes';
cfg7.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg7.bpfreq=[1 80];
cfg7.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig7=ft_preprocessing(cfg7);

cfg8.blc='no'; % normalize the data according to the base line average time window (see two lines below)
cfg8.continuous='yes';
cfg8.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg8.bpfreq=[1 80];
cfg8.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig8=ft_preprocessing(cfg8);

clear cfg1 cfg2 cfg3 cfg4 cfg5 cfg6 cfg7 cfg8
save dataorig dataorig1 dataorig2 dataorig3 dataorig4 dataorig5 dataorig6 dataorig7 dataorig8
%% remove muscle artifact
cfg=[];
cfg.method='summary'; %trial
cfg.channel='MEG';
cfg.hpfilter='yes';
cfg.hpfreq=60;
datacln=ft_rejectvisual(cfg, dataorig);

% to see again
datacln=ft_rejectvisual(cfg, datacln);

% back to original data
datacln.cfg.trl=datacln.sampleinfo;
datacln.cfg.trl(:,3)=0;
cfg1.hpfilter='no';
datacln=ft_preprocessing(cfg1,datacln);

%% ICA
%resampling data to speed up the ica
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy           = ft_resampledata(cfg, datacln);

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
cfg.component = [1 2 5]; % change
dataica = ft_rejectcomponent(cfg, comp);

%% perform spectral analysis using fft

cfg3            = [];
cfg3.output     = 'pow';
cfg3.method     = 'mtmfft';
cfg3.foilim     = [1 80]; % all frequencies
cfg3.tapsmofrq  = 1;
cfg3.keeptrials = 'no';
cfg3.channel    = 'MEG';
spect1 =ft_freqanalysis(cfg3,dataorig1);
spect2 =ft_freqanalysis(cfg3,dataorig2);
spect3 =ft_freqanalysis(cfg3,dataorig3);
spect4 =ft_freqanalysis(cfg3,dataorig4);
spect5 =ft_freqanalysis(cfg3,dataorig5);
spect6 =ft_freqanalysis(cfg3,dataorig6);
spect7 =ft_freqanalysis(cfg3,dataorig7);
spect8 =ft_freqanalysis(cfg3,dataorig8);

clear dataorig1 dataorig2 dataorig3 dataorig4 dataorig5 dataorig6 dataorig7 dataorig8
save spect spect1 spect2 spect3 spect4 spect5 spect6 spect7 spect8 

plot(mean(spect1.powspctrm));
hold on;
plot(mean(spect2.powspctrm),'r');
plot(mean(spect3.powspctrm),'g');
plot(mean(spect4.powspctrm),'k');


% multiple topoplots
figure;
cfg=[];
cfg.xlim=[1:1:20];
ft_topoplotER(cfg,spect1);
figure;
cfg=[];
cfg.xlim=[21:1:40];
ft_topoplotER(cfg,spect1);
% topoplot for alpha
figure;
cfg=[]; 
cfg.xlim=[8 12];
cfg.colorbar='yes';
ft_topoplotER(cfg,spect1);
title('Alpha')

% topoplot for beta
figure;
cfg=[]; 
cfg.xlim=[13 30];
cfg.colorbar='yes';
ft_topoplotER(cfg,spect1);
title('Beta')

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