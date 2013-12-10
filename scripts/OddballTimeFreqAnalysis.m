
% cd into subject directory

load /home/meg/Data/noa/paths
open path2oddball

%%
clear all;
fileName='xc,hb,lf_c,rfhp0.1Hz';


%%
trig=readTrig_BIU(fileName);
trig=clearTrig(trig);
trig(1:(end-600))=trig(601:end);trig((end-599):end)=0; % canceling the latency delay between E-prime triger and actual apperance of triger
% read X3 channel
cfg=[];
cfg.dataset=fileName;
cfg.trialfun='trialfun_beg';
cfg1=ft_definetrial(cfg);
cfg1.channel='X3';
cfg1.hpfilter='yes';
cfg1.hpfreq=110;
Aud=ft_preprocessing(cfg1);
trigFixed=fixAudTrig(trig,Aud.trial{1,1},[],0.01,610);
rewriteTrig(fileName,trigFixed,'fix',[]);
% check the trigger

%% finding trial
cfg= [];
cfg.dataset='fix_xc,hb,lf_c,rfhp0.1Hz';%check name of the abeles function output
cfg.trialdef.eventtype='TRIGGER';
cfg.trialdef.eventvalue=[32 64 128];  %triggers are for different kinds of metaphors 
cfg.trialdef.prestim=0.5; % time before trigger onset
cfg.trialdef.poststim=0.7; % time after trigger onset
cfg.trialdef.offset=-0.5; % defining the real zero: can be different than prestim
cfg.trialdef.rspwin=1500; %wait for response for 2 seconds, else, report that there was no response
cfg.trialfun='BIUtrialfun'; % use the unique parameters of the Bar Ilan MEG
cfg=ft_definetrial(cfg);

%% adding colomn seven: 1 - correct answer; 0 - wrong answer
a=length(cfg.trl);
cfg.trl(a,4)=100;
cfg.trl(1:a,7)=0;

res64=find(cfg.trl(:,4)==64);
for i=res64';
    dif(1,1)=cfg.trl(i,5)-cfg.trl(i,1);
    if cfg.trl(i,4)==64 && dif<2035;
        cfg.trl(i,7)=1;
    else
        cfg.trl(i,7)=0;
    end;
end;

res32=find(cfg.trl(:,4)==32);
for i=res32';
    if cfg.trl(i,5)==cfg.trl(i+1,5) || cfg.trl(i,5)==0;
        cfg.trl(i,7)=1;
    else
        cfg.trl(i,7)=0;
    end;
end;


res128=find(cfg.trl(:,4)==128);
for i=res128';
    if cfg.trl(i,5)==cfg.trl(i+1,5) || cfg.trl(i,5)==0;
        cfg.trl(i,7)=1;
    else
        cfg.trl(i,7)=0;
    end;
end;

f=find(cfg.trl(:,4)==64);
fi=find(cfg.trl(f,7)==1);
a=size(fi,1);
disp('number of correct oddball answers');
a
%% preprocessing
cfg.blc='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.5,0];
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[1 40];
cfg.channel = {'MEG','-A204','-A74'}; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
datahf=ft_preprocessing(cfg);

%% Muscle artifact
cfg4=[];
cfg4.method='summary'; %trial
cfg4.channel={'MEG','-A204','-A74'};
%cfg4.alim=1e-12;
cfg4.hpfilter='yes';
cfg4.hpfreq=60;
datahfrv=ft_rejectvisual(cfg4, datahf);

% to see again
datahfrv=ft_rejectvisual(cfg4, datahfrv);

% press zero, enter and select bad trials
% trl=[];trlCount=1;
% for trli=1:length(cfg2.trl)
%     if ~ismember(cfg2.trl(trli,1),datahfrv.cfg.artifact)
%         trl(trlCount,1:3)=cfg2.trl(trli,1:3);
%         trlCount=trlCount+1;
%     end
% end
% cfg2.trl=trl;
%cfg2.trl=reindex(datahf.cfg.trl,datahfrv.cfg.trl);
%% re-preprocessing
cfg3=[];
cfg3.demean='yes';
cfg3.baselinewindow=[-0.5,0];
cfg3.bpfilter='yes';
cfg3.bpfreq=[1 40];
cfg3.channel={'MEG','-A204','-A74'};
dataorig=ft_preprocessing(cfg3,datahfrv); % reading the data

save dataorig dataorig

%% cleaning by ICA
% cd to subject directory
load dataorig
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy           = ft_resampledata(cfg, dataorig);

%run ica
cfg            = [];
cfg.channel    = 'MEG';
comp_dummy           = ft_componentanalysis(cfg, dummy);
save comp_dummy comp_dummy

%see the components and find the artifact
cfgb=[];
cfgb.layout='4D248.lay';
cfgb.channel = {comp_dummy.label{1:10}};
cfgb.continuous='no';
comppic=ft_databrowser(cfgb,comp_dummy);


% cfg=[];
% cfg.comp=[1:10];
% cfg.layout='4D248.lay';
% comppic=ft_componentbrowser(cfg,comp_dummy);

% if there is comps to reject:
% run the ICA in the original data
cfg = [];
cfg.topo      = comp_dummy.topo;
cfg.topolabel = comp_dummy.topolabel;
comp     = ft_componentanalysis(cfg, dataorig);

cfg = [];
cfg.component = [1 2 4 5 7 8]; % change
dataica = ft_rejectcomponent(cfg, comp);


%% base line correction
dataica=correctBL(dataica,[-0.5 0]);
%% reject visual summary

cfg=[];
cfg.method='summary'; %trial
% cfg.method = 'trial';
cfg.channel='MEG';
cfg.alim=1e-12;
datacln=ft_rejectvisual(cfg, dataica);
% see again
datacln=ft_rejectvisual(cfg, datacln);
% or (if no ica comp was removed)
% datacln=ft_rejectvisual(cfg, dataorig);

%% reject visual trial
cfg=[];
cfg.method='trial';
cfg.channel='MEG';
cfg.alim=1e-12;
datacln=ft_rejectvisual(cfg, datacln);

save datacln datacln

%% recreating the trl matrix
datacln.cfg.trl(:,1:2)=datacln.sampleinfo(:,1:2);
datacln.cfg.trl(:,3)=-509; % the offset
datacln.cfg.trl(:,4:7)=datacln.trialinfo(:,1:4);

%% split conditions
cfg=[];
cfg.cond=32; % literal
datanovel=splitcondscrt(cfg,datacln);
cfg.cond=64; 
dataoddball=splitcondscrt(cfg,datacln);
cfg.cond=128; 
datastand=splitcondscrt(cfg,datacln);

save datasplit datanovel dataoddball datastand

clear all;
load datasplit
A(1,1)=length(datastand.trial);
A(1,2)=length(dataoddball.trial);
A(1,3)=length(datanovel.trial);

mini=min(A);

a=randperm(A(1,1));
a1=a(1:mini);
datastandmin=datastand;
datastandmin.trial={};
datastandmin.time={};

b=1;
for i=a1
    datastandmin.trial{1,b}=datastand.trial{1,i};
    datastandmin.time{1,b}=datastand.time{1,i};
    b=b+1;
end;

%
a=randperm(A(1,2));
a1=a(1:mini);
dataoddballmin=dataoddball;
dataoddballmin.trial={};
dataoddballmin.time={};

b=1;
for i=a1
    dataoddballmin.trial{1,b}=dataoddball.trial{1,i};
    dataoddballmin.time{1,b}=dataoddball.time{1,i};
    b=b+1;
end;   

a=randperm(A(1,3));
a1=a(1:mini);
datanovelmin=datanovel;
datanovelmin.trial={};
datanovelmin.time={};

b=1;
for i=a1
    datanovelmin.trial{1,b}=datanovel.trial{1,i};
    datanovelmin.time{1,b}=datanovel.time{1,i};
    b=b+1;
end;

% calculating general avarege
%clear all
%load datamin
dataminall=datanovelmin;
dataminall.trial=dataoddballmin.trial;
a=size(dataminall.trial,2);
for i=1:size(datanovelmin.trial,2)  ;
    dataminall.trial{1,(i+a)}=datanovelmin.trial{1,i};
    dataminall.trial{1,i+(a*2)}=datastandmin.trial{1,i};
end;

%check if length of trial equals: b=a*3
for i=size(dataminall.time,2)+1:size(dataminall.trial,2)  %46:135
dataminall.time{1,i}=dataminall.time{1,1};
end;

save datamin datastandmin dataoddballmin datanovelmin dataminall

%% Time-Frequency Analysis
clear all
load datamin

cfgtfr= [];
cfgtfr.output= 'pow';
cfgtfr.method= 'mtmconvol';
cfgtfr.taper= 'hanning';
cfgtfr.foi= 1:40; % frequency of interest of which the resolution is dependent on the timw window...
% for 500ms we will have 2Hz resolution and the foi will be 2:2:40
%cfgtfr.t_ftimwin= 4./cfgtfr.foi; % length of time window dependent on number of cycles we want...
% (in this case - 4)
cfgtfr.t_ftimwin=ones(length(cfgtfr.foi))*0.3;
cfgtfr.toi=[-0.5:0.01:0.7];
%cfgtfr.trials=1;
cfgtfr.channel={'MEG','-A204','-A74'};
%cfgtfr.tapsmofrq  = 1;
TFnovel = ft_freqanalysis(cfgtfr, datanovelmin);
TFoddball = ft_freqanalysis(cfgtfr, dataoddballmin);
TFstand = ft_freqanalysis(cfgtfr, datastandmin);
TFall   =  ft_freqanalysis(cfgtfr, dataminall);

save TFtest TFnovel TFoddball TFstand TFall

% now plot one channel
figure;
cfg=[];
cfg.baseline     = [-0.35 -0.1]; 
cfg.baselinetype = 'absolute'; 	
cfg.interactive='yes';
cfg.layout='4D248.lay';
cfg.colorbar='yes';
ft_multiplotTFR(cfg, TFnovel);

figure;ft_singleplotTFR(cfg, TFnovel);


%cfg = [];       
%cfg.zlim  = [-3*10^(-29) 8*10^(-26)];
%cfg.interactive = 'yes';
%cfg.layout = '4D248.lay';
%ft_multiplotTFR(cfg, TFnovel)
%figure;
%ft_multiplotTFR(cfg, TFoddball)