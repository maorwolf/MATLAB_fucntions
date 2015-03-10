%% Prof. Abeles and Tal clean files scripts:

clear all
fileName = 'c,rfhp0.1Hz,ee';
p=pdf4D(fileName);% transfer data into matlab compatable data
cleanCoefs = createCleanFile(p, fileName,...
    'byLF',[] ,'Method','Adaptive',...
    'xClean',[4 5 6],...
    'chans2ignore',[],...
    'byFFT',0,...
    'HeartBeat',[],... % use [] for automatic HB cleaning, use 0 to avoid HB cleaning
    'maskTrigBits', [256,512]);
    
% for jump cleaning add: 'stepCorrect',1,...
% for forced HB cleaning use the same configoration but with the function:
% "createCleanFile_fhb"

% For the Fran files read the trig channel
trig = readTrig_BIU('xc,hb,lf_c,rfhp0.1Hz,ee');
plot(trig);
trigVal = unique(trig);
disp(trigVal);

% if I need to rewrite the trigChann
newTrig=trig;
for i=1:length(newTrig)
    if newTrig(i)==4350;
        newTrig(i)=0;
    end
end
plot(newTrig)
rewriteTrig('xc,hb,lf_c,rfhp0.1Hz,ee',newTrig,'fix');
% sub and conds definitions

%% -------------------- Preprocessing and cleaning ------------------------
clear all
clc

source = 'xc,hb,lf_c,rfhp0.1Hz,ee'; % source='fix_xc,hb,lf_c,rfhp0.1Hz,ee';

% 1. find Bad Channels
findBadChans(source);
channels = {'MEG'}; % if there were bad channs % channels = {'MEG','-A41'}; % or % channels = {'MEG','-A41','-A208'};

%% ------------------------------------------------------------------------
%  --------------------- For Fran files -----------------------------------
%  ------------------------------------------------------------------------
%% 2. finding trials and defining them
conditions              = [202 204]; % 202 - rest closed; 204 - rest open
cfg                     = [];
cfg.dataset             = source; 
cfg.trialdef.eventtype  = 'TRIGGER';
cfg.trialdef.eventvalue = conditions;
cfg.trialdef.prestim    = 0;
cfg.trialdef.poststim   = 1;
cfg.trialdef.offset     = 0;
cfg                     = ft_definetrial(cfg);

%% 3. recreating the trl matrix
start202 = cfg.trl(1,1);
start204 = cfg.trl(2,1);

cfg.trl(1,1) = start202;
cfg.trl(1,2) = round(start202+1017.23*2);
cfg.trl(1,3) = 0;
cfg.trl(1,4) = 202;

for i=2:120
    cfg.trl(i,1) = round(cfg.trl(i-1,1)+1017.23);
    cfg.trl(i,2) = round(cfg.trl(i,1)+1017.23*2);
    cfg.trl(i,3) = 0;
    cfg.trl(i,4) = 202;
end

cfg.trl(121,1) = start204;
cfg.trl(121,2) = round(start204+1017.23*2);
cfg.trl(121,3) = 0;
cfg.trl(121,4) = 204;

for i=122:240
    cfg.trl(i,1) = round(cfg.trl(i-1,1)+1017.23);
    cfg.trl(i,2) = round(cfg.trl(i,1)+1017.23*2);
    cfg.trl(i,3) = 0;
    cfg.trl(i,4) = 204;
end

%% ------------------------------------------------------------------------
%  --------------------- For AviMA files ----------------------------------
%  ------------------------------------------------------------------------
%% 2. creating trl matrix
start204     = 1; % change to the starting time (in seconds) of the resting state
start204     = round(start204*1017.23);
cfg.trl(1,1) = start204;
cfg.trl(1,2) = round(start204+1017.23*2);
cfg.trl(1,3) = 0;
cfg.trl(1,4) = 204;

for i=2:120
    cfg.trl(i,1) = round(cfg.trl(i-1,1)+1017.23);
    cfg.trl(i,2) = round(cfg.trl(i,1)+1017.23*2);
    cfg.trl(i,3) = 0;
    cfg.trl(i,4) = 204;
end

%% 3. finding trials and defining them
cfg.dataset     = source;
cfg.trialfun    = 'trialfun_beg';
cfg             = ft_definetrial(cfg);

%% ------------------------------------------------------------------------
%  --------------------- continue from here for all files -----------------
%  ------------------------------------------------------------------------
%% 4. preprocessing for muscle artifact rejection
cfg.demean              = 'yes'; % normalizes the data
cfg.continuous          = 'yes';
cfg.trialdef.prestim    = 0;
cfg.trialdef.poststim   = 2;
cfg.trialdef.offset     = 0;
cfg.hpfilter            = 'yes';
cfg.hpfreq              = 60;
cfg.channel             = channels;
dataorig                = ft_preprocessing(cfg);

% remove muscle artifact
cfg1.method     = 'summary'; %trial
datacln         = ft_rejectvisual(cfg1, dataorig);

% if there is a bad channel redifine the channels:
channels = {'MEG','-A41'};

% Deleting the bad trials from the original trl matrix so you don't refilter the data
cfg.trl         = [];
cfg.trl         = datacln.sampleinfo;
cfg.trl(:,3)    = 0;
cfg.trl(:,4)    = datacln.trialinfo;

%% 5. preprocessing original data without the bad trials
cfg.demean              = 'yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous          = 'yes';
cfg.trialdef.prestim    = 0;
cfg.trialdef.poststim   = 2;
cfg.trialdef.offset     = 0;
cfg.hpfilter            = 'no';
cfg.bpfilter            = 'yes'; % apply bandpass filter (see one line below)
cfg.bpfreq              = [1 100];
cfg.channel             = channels; 
cfg.padding             = 10;
dataorig                = ft_preprocessing(cfg);
% cfg.bpfreq              = [1 40];
% data4ICA                = ft_preprocessing(cfg);
%% 6. ICA
% resampling data to speed up the ica
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy          = ft_resampledata(cfg, dataorig);

% run ica (it takes a long time have a break)
cfg            = [];
cfg.channel    = channels;
comp_dummy     = ft_componentanalysis(cfg, dummy);

% see the components and find the artifacts
cfgb=[];
cfgb.layout     = '4D248.lay';
cfgb.channel    = (comp_dummy.label(1:10));
cfgb.continuous = 'no';
ft_databrowser(cfgb,comp_dummy);

% cool visualization for one component
badTrials2 = seeOneComp(comp_dummy);

% run the ICA on the original data
cfg             = [];
cfg.topo        = comp_dummy.topo;
cfg.topolabel   = comp_dummy.topolabel;
comp            = ft_componentanalysis(cfg, dataorig);

% remove the artifact components
cfg             = [];
cfg.component   = [5]; % change to the components you want to clean!!!!!!! empty if no components shell be cleaned
dataica         = ft_rejectcomponent(cfg, comp);

%% 7. reject trials 
% trial by trial
cfg=[];
cfg.method='trial'; % 'channel'
cfg.channel=channels;
cfg1.bpfilter='yes';
cfg1.bpfreq=[1 40];
datafinal=ft_rejectvisual(cfg, dataica);

% summary
cfg=[];
cfg.method='summary'; % 'channel'
datafinal=ft_rejectvisual(cfg, datafinal);

%% 8. split conditions only for Fran files!!!!!!!!!!
cond202.cfg=datafinal.cfg;
cond202.label=datafinal.label;
cond202.fsmaple=datafinal.fsample;
cond202.grad=datafinal.grad;
cond202.trial=datafinal.trial(datafinal.trialinfo==202);
cond202.time=datafinal.time(datafinal.trialinfo==202);
cond202.trialinfo=datafinal.trialinfo(datafinal.trialinfo==202);
cond202.sampleinfo=datafinal.sampleinfo(datafinal.trialinfo==202);

cond204.cfg=datafinal.cfg;
cond204.label=datafinal.label;
cond204.fsmaple=datafinal.fsample;
cond204.grad=datafinal.grad;
cond204.trial=datafinal.trial(datafinal.trialinfo==204);
cond204.time=datafinal.time(datafinal.trialinfo==204);
cond204.trialinfo=datafinal.trialinfo(datafinal.trialinfo==204);
cond204.sampleinfo=datafinal.sampleinfo(datafinal.trialinfo==204);

save splitconds cond202 cond204

%% for AviMa files
cond204 = datafinal;
save splitconds cond204
