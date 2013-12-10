%% Somato Sensory Script for Hypnosis Experiment
%-----------------------------------------------
%% cleaning heart beats, 50Hz and more using Abeles and Tal's script
% clear all
fileName = 'c,rfhp0.1Hz';
p=pdf4D(fileName);% transfer data into matlab compatable data
cleanCoefs = createCleanFile(p, fileName,...
    'byLF',[] ,'Method','Adaptive',...
    'xClean',[4,5,6],...
    'chans2ignore',[],...
    'byFFT',0,...
    'HeartBeat',[],... % use [] for automatic HB cleaning, use 0 to avoid HB cleaning
    'maskTrigBits', 512);

%% find Bad Channels
source='xc,hb,lf_c,rfhp0.1Hz';
findBadChans(source);
original_source='c,rfhp0.1Hz';% we added this line to compare between the data before and after cleaning with the Abeles fucntion
findBadChans(original_source);


%% finding trial
sub=9;
condition_vector=[102 104 106 108];

cfg= [];
cfg.dataset='xc,hb,lf_c,rfhp0.1Hz';%check name of the abeles function output
cfg.trialdef.eventtype='TRIGGER';
cfg.trialdef.eventvalue=condition_vector;  %triggers are for different kinds of metaphors 
cfg.trialdef.prestim=0.2; % time before trigger onset
cfg.trialdef.poststim=0.8; % time after trigger onset
cfg.trialdef.offset=-0.2; % defining the real zero: can be different than prestim
%cfg.trialdef.visualtrig='visafter'; % sync the trigger from E-prime with the visual trigger 
%cfg.trialdef.visualtrigwin=0.2; % look for the 2048 from the visual trigger in the next 200 ms interval time window
cfg.trialfun='BIUtrialfun'; % use the unique parameters of the Bar Ilan MEG
%cfg.trialdef.rspwin=2.5; %wait for response for 2 seconds, else, report that there was no response
cfg=ft_definetrial(cfg);
%% preprocessing
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-0.2 0];
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[0.1 80];
cfg.padding = 10;
cfg.channel = {'MEG'}; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
eval(['sub',num2str(sub),'dataorig=ft_preprocessing(cfg);']);

eval(['save dataorig sub',num2str(sub),'dataorig']);
%% remove muscle artifact
cfg.method='summary'; %trial
cfg.channel={'MEG'};
cfg.hpfilter='yes';
cfg.bpfilter='no';
cfg.hpfreq=60;
eval(['datacln=ft_rejectvisual(cfg, sub',num2str(sub),'dataorig);']);

% to see again
datacln=ft_rejectvisual(cfg, datacln);

% back to original data
cfg.demean='yes';
cfg.continuous='yes';
cfg.baselinewindow=[-0.2 0];
cfg.padding=0;
cfg.bpfilter='yes';
cfg.hpfilter='no';

cfg.bpfreq=[0.1 80];
cfg.channel = {'MEG'};
datacln=ft_preprocessing(cfg,datacln);

%% second option for muscle artifact
% remove muscle
cfg.artfctdef.muscle.feedback='yes';
cfg.artfctdef.muscle. channel={'MEG'};
cfg=ft_artifact_muscle(cfg);

cfg.artfctdef.reject = 'complete';   % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
cfg.method='trial'; %trial

datacln = ft_rejectartifact(cfg);
datacln = ft_preprocessing(datacln); 
%% ICA
%resampling data to speed up the ica
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy           = ft_resampledata(cfg, datacln);

% run ica (it takes a long time have a break)
cfg            = [];
cfg.channel    = {'MEG'};
comp_dummy           = ft_componentanalysis(cfg, dummy);

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
cfg.component = [1 2 18]; % change
dataica = ft_rejectcomponent(cfg, comp);

%% base line correction
dataica=correctBL(dataica,[-0.2 0]);

%% trial by trial
cfg=[];
cfg.method='trial'; % 'channel'
cfg.channel='MEG';
cfg1.bpfilter='yes';
cfg1.bpfreq=[0.1 80];
datafinal=ft_rejectvisual(cfg, dataica);

%% recreating the trl matrix
datafinal.cfg.trl(:,1:2)=datafinal.sampleinfo(:,1:2);
datafinal.cfg.trl(:,3)=-305; % the offset
datafinal.cfg.trl(:,4:6)=datafinal.trialinfo(:,1:3);

%% split conditions
cfg=[];
cfg.cond=102; % literal
con102=splitconds(cfg,datafinal);
cfg.cond=104; 
con104=splitconds(cfg,datafinal);
cfg.cond=106; 
con106=splitconds(cfg,datafinal);
cfg.cond=108; 
con108=splitconds(cfg,datafinal);

% for combining two or more datasets use: 
% cfg=[]; newName=ft_appenddata(cfg, data1, data2,...);
cfg=[];
con102and104=ft_appenddata(cfg, con102,con104);
con106and108=ft_appenddata(cfg, con106,con108);
con102and106=ft_appenddata(cfg, con102,con106);
con104and108=ft_appenddata(cfg, con104,con108);

eval(['save sub',num2str(sub),'datafinalsplit con102 con104 con106 con108 con102and104 con106and108 con102and106 con104and108']);

% averaging
for index=condition_vector
    eval(['sub',num2str(sub),'con',num2str(index),'=ft_timelockanalysis([],con',num2str(index),');']);
end
eval(['sub',num2str(sub),'con102and104=ft_timelockanalysis([],con102and104);']);
eval(['sub',num2str(sub),'con106and108=ft_timelockanalysis([],con106and108);']);
eval(['sub',num2str(sub),'con102and106=ft_timelockanalysis([],con102and106);']);
eval(['sub',num2str(sub),'con104and108=ft_timelockanalysis([],con104and108);']);

eval(['sub',num2str(sub),'average=ft_timelockanalysis([],datafinal);']);


eval(['save averageData sub sub',num2str(sub),'con102and104 sub',num2str(sub),'con106and108 sub',num2str(sub),'con102and106 sub',num2str(sub),'con104and108 sub',num2str(sub),'con',num2str(condition_vector(1)),' sub',num2str(sub),'con',num2str(condition_vector(2)),' sub',num2str(sub),'con',num2str(condition_vector(3)),' sub',num2str(sub),'con',num2str(condition_vector(4)),' sub',num2str(sub),'average;']);
clear all;
eval(['load averageData']);

%% Plots

% Butterfly
cfg=[];
cfg.showlabels='yes';
cfg.fontsize=10;
cfg.layout='butterfly';
cfg.showlabels='yes';
eval(['ft_multiplotER(cfg, sub',num2str(sub),'con104, sub',num2str(sub),'con108);']);

eval(['ft_singleplotER(cfg, sub',num2str(sub),'con104, sub',num2str(sub),'con108);']);
title('blue - Pre Left         red - Post Left');

% Interactive
cfg=[];
cfg.interactive='yes';
cfg.layout='4D248.lay';
eval(['ft_multiplotER(cfg,sub',num2str(sub),'con104, sub',num2str(sub),'con108);']);
figure;
eval(['ft_multiplotER(cfg,sub',num2str(sub),'con102, sub',num2str(sub),'con106);']);

% topoplot
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[0.00:0.05:0.3]; % from 300ms to 600ms in 10ms interval
% cfg.zlim=[-9*10^(-14) 2*10^(-13)];
cfg.colorbar='no'; % change to 'no' in order to avoid the annoying colorbar that squeeze the plot
% cfg.comment='no'; % to ommit the text from the plot
eval(['ft_topoplotER(cfg,sub',num2str(sub),'con104);']);







% --------------------------------------------------------------------------------------------------------------------------
cfg=[];
cfg.keepindividual = 'yes'

% [grandavgG4L] = ft_timelockgrandaverage([], G4avg01, G4avg03, G4avg08, G4avg09, G4avg11, G4avg14, G4avg15)
% [grandavgG64L] = ft_timelockgrandaverage([], G64avg01, G64avg03, G64avg08, G64avg09, G64avg11, G64avg14, G64avg15)
% [grandavgR4L] = ft_timelockgrandaverage([], R4avg01, R4avg03, R4avg08, R4avg09, R4avg11, R4avg14, R4avg15)
% [grandavgR64L] = ft_timelockgrandaverage([], R64avg01, R64avg03, R64avg08, R64avg09, R64avg11, R64avg14, R64avg15)
% [grandavgG4H] = ft_timelockgrandaverage([], G4avg04, G4avg05, G4avg06, G4avg10, G4avg12, G4avg13)
% [grandavgG64H] = ft_timelockgrandaverage([], G64avg04, G64avg05, G64avg06, G64avg10, G64avg12, G64avg13)
% [grandavgR4H] = ft_timelockgrandaverage([], R4avg04, R4avg05, R4avg06, R4avg10, R4avg12, R4avg13)
% [grandavgR64H] = ft_timelockgrandaverage([], R64avg04, R64avg05, R64avg06, R64avg10, R64avg12, R64avg13)
%eval(['load /home/meg/Desktop/YuvalEitanPracticeData/averageSubject/sub',num2str(i),'/subject',num2str(i),'_data;']);
        %eval(['data=subject_',num2str(i),'_',num2str(l),'.avg;']);
        total_subjects=4;
        subject_number=4;
        subject_index=1:total_subjects;
        condition_vector=[10 20 30 40];
        for condition_index=condition_vector
            eval(['grandavg_' num2str(condition_index) '=ft_timelockgrandaverage(cfg, subject_' num2str(1) '_' num2str(condition_index) ...
                'subject_' num2str(2) '_' num2str(condition_index)...
                 'subject_' num2str(3) '_' num2str(condition_index)...
                 'subject_' num2str(4) '_' num2str(condition_index) ')']);
        end

% [grandavg_10] = ft_timelockgrandaverage(cfg, subject_1_10, subject_2_10, subject_3_10);
% [grandavg_20] = ft_timelockgrandaverage(cfg, subject_1_20, subject_2_20, subject_3_20);
% 
% [grandavg_30] = ft_timelockgrandaverage(cfg, subject_1_30, subject_2_30, subject_3_30);
% [grandavg_40] = ft_timelockgrandaverage(cfg, subject_1_40, subject_2_40, subject_3_40);

[grandavg_total_average] = ft_timelockgrandaverage([], subject_1_total_average, subject_2_total_average, subject_3_total_average);
save grand_average grandavg_10 grandavg_20 grandavg_30 grandavg_40 grandavg_total_average


%% plot
cfg=[];
cfg.interactive='yes';
cfg.layout='4D248.lay';
ft_multiplotER(cfg,grandavg_10,grandavg_20,grandavg_30,grandavg_total_average); % cfg.graphcolor='brgkywrgbkywrgbkywrgbkyw'
% one condition only
% ft_multiplotER(cfg,G64avg)
save avgs G4avg G64avg R4avg R64avg

% Butterfly
cfg=[];
cfg.showlabels='yes';
cfg.fontsize=10;
cfg.layout='butterfly';
cfg.showlabels='yes';
ft_multiplotER(cfg, grandavg_40);
ft_singleplotER(cfg, Yuval_eitan_average_10, Yuval_eitan_average_20);

% topoplot
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[-0.2:0.05:1]; % from 300ms to 600ms in 10ms interval
% cfg.zlim=[-9*10^(-14) 2*10^(-13)];
cfg.colorbar='no'; % change to 'no' in order to avoid the annoying colorbar that squeeze the plot
% cfg.comment='no'; % to ommit the text from the plot
ft_topoplotER(cfg,grandavg_40);

