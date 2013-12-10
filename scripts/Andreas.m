%% Andreas Exp.
%-----------------------------------------------
%% cleaning heart beats, 50Hz and 24Hz using Abeles and Tal's script
clear all
fileName = 'c,rfhp0.1Hz';
p=pdf4D(fileName);% transfer data into matlab compatable data
cleanCoefs = createCleanFile(p, fileName,...
    'byLF',[] ,'Method','Adaptive',...
    'xClean',[4,5,6],...
    'chans2ignore',[],...
    'byFFT',0,...
    'HeartBeat',[],... % use [] for automatic HB cleaning, use 0 to avoid HB cleaning
    'maskTrigBits', 512);


%% rewriting the trig channel accordign to X1
clear all;
fileName='xc,hb,lf_c,rfhp0.1Hz';

trig=readTrig_BIU(fileName);
trig=clearTrig(trig);
trig(1:(end-600))=trig(601:end);
trig((end-599):end)=0; % canceling the latency delay between E-prime triger and actual apperance of triger

% read X1 channel
cfg=[];
cfg.dataset=fileName;
cfg.trialfun='trialfun_beg';
cfg1=ft_definetrial(cfg);
cfg1.channel='X1';
cfg1.hpfilter='yes';
cfg1.hpfreq=50;
Aud=ft_preprocessing(cfg1);
trigFixed=fixAudTrig(trig,Aud.trial{1,1},[],0.01,610);
rewriteTrig(fileName,trigFixed,'fix',[]); % check the trigger

%% find Bad Channels
source='xc,hb,lf_c,rfhp0.1Hz';
findBadChans(source);

original_source='c,rfhp0.1Hz';% we added this line to compare between the data before and after cleaning with the Abeles fucntion
findBadChans(original_source);


%% finding trial
sub=1;
condition_vector=[2 18 50 82 114 10 26 58 90 122 4 20 52 84 116 12 28 60 92 124 6 22 54 86 118 14 30 62 94 126];

cfg= [];
cfg.dataset='xc,hb,lf_c,rfhp0.1Hz';%check name of the abeles function output
cfg.trialdef.eventtype='TRIGGER';
cfg.trialdef.eventvalue=condition_vector;  %triggers are for different kinds of metaphors 
cfg.trialdef.prestim=0.2; % time before trigger onset
cfg.trialdef.poststim=1.25; % time after trigger onset
cfg.trialdef.offset=-0.2; % defining the real zero: can be different than prestim
%cfg.trialdef.visualtrig='visafter'; % sync the trigger from E-prime with the visual trigger 
%cfg.trialdef.visualtrigwin=0.2; % look for the 2048 from the visual trigger in the next 200 ms interval time window
cfg.trialfun='BIUtrialfun'; % use the unique parameters of the Bar Ilan MEG
%cfg.trialdef.rspwin=2.5; %wait for response for 2 seconds, else, report that there was no response
cfg=ft_definetrial(cfg);

%% preprocessing
cfg.blc='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.2,0];
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[1 40];
cfg.padding = 3;
cfg.channel = {'MEG'}; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
eval(['sub',num2str(sub),'dataorig=ft_preprocessing(cfg);']);

eval(['save dataorig sub',num2str(sub),'dataorig']);