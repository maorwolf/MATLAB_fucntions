%% Time frequency analysis for 17 subs
% low frequencies
clear
subs = [7:12 14:19 21 25:28];
for sub = subs
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/timeFrequency'])
    load datafinal
        cfg             = [];
        cfg.resamplefs  = 300;
        cfg.detrend     = 'no';
        data            = ft_resampledata(cfg, datafinal);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials='no';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 10;
    cfgtfrl.foi       = 4:1:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.25;
    cfgtfrl.toi       = [-0.5:0.03:1];
    cfgtfrl.channel   = {'MEG', '-A41'};
        cfgtfrl.trials    = find(data.trialinfo==102);
        TF102l            = ft_freqanalysis(cfgtfrl, data);
        cfgtfrl.trials    = find(data.trialinfo==104);
        TF104l            = ft_freqanalysis(cfgtfrl, data);
        cfgtfrl.trials    = find(data.trialinfo==106);
        TF106l            = ft_freqanalysis(cfgtfrl, data);
        cfgtfrl.trials    = find(data.trialinfo==108);
        TF108l            = ft_freqanalysis(cfgtfrl, data);
    
    save TF_Low TF102l TF104l TF106l TF108l
    clear cfg cfgtfrl data datafinal TF102l TF104l TF106l TF108l
end;

%% base line
% clear all
% for i = [7:19 21 22 25:28];
%     eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/TF_Low'])
%     cfg=[];
%     cfg.baseline     = [-0.15 0];
%     cfg.baselinetype = 'absolute';
%     for j=102:2:108
%         eval(['TFl',num2str(j),'BL=ft_freqbaseline(cfg, TF',num2str(j),'l);']);
%         eval(['sub',num2str(i),'TFl',num2str(j),'BL = TFl',num2str(j),'BL;']);
%     end
%     clear cfg TF102l TFl102BL TF104l TFl104BL TF106l TFl106BL TF108l TFl108BL
%     for cond = 102:2:108
%         eval(['sub',num2str(i),'TFl',num2str(cond),'BLdesc = ft_freqdescriptives([],sub',num2str(i),'TFl',num2str(cond),'BL);']);
%     end;
%     eval(['clear sub',num2str(i),'TFl102BL sub',num2str(i),'TFl104BL sub',num2str(i),'TFl106BL sub',num2str(i),'TFl108BL']);
%     disp(i);
% end;

%% grand average

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFl102BLgavg         = ft_freqgrandaverage(cfg, sub7TFl102BLdesc, sub8TFl102BLdesc, sub9TFl102BLdesc, sub10TFl102BLdesc,...
    sub11TFl102BLdesc, sub12TFl102BLdesc, sub13TFl102BLdesc, sub14TFl102BLdesc, sub15TFl102BLdesc, sub16TFl102BLdesc, sub17TFl102BLdesc, sub18TFl102BLdesc,...
    sub19TFl102BLdesc, sub21TFl102BLdesc, sub22TFl102BLdesc, sub25TFl102BLdesc, sub26TFl102BLdesc, sub27TFl102BLdesc, sub28TFl102BLdesc);

TFl104BLgavg         = ft_freqgrandaverage(cfg, sub7TFl104BLdesc, sub8TFl104BLdesc, sub9TFl104BLdesc, sub10TFl104BLdesc,...
    sub11TFl104BLdesc, sub12TFl104BLdesc, sub13TFl104BLdesc, sub14TFl104BLdesc, sub15TFl104BLdesc, sub16TFl104BLdesc, sub17TFl104BLdesc, sub18TFl104BLdesc,...
    sub19TFl104BLdesc, sub21TFl104BLdesc, sub22TFl104BLdesc, sub25TFl104BLdesc, sub26TFl104BLdesc, sub27TFl104BLdesc, sub28TFl104BLdesc);

TFl106BLgavg         = ft_freqgrandaverage(cfg, sub7TFl106BLdesc, sub8TFl106BLdesc, sub9TFl106BLdesc, sub10TFl106BLdesc,...
    sub11TFl106BLdesc, sub12TFl106BLdesc, sub13TFl106BLdesc, sub14TFl106BLdesc, sub15TFl106BLdesc, sub16TFl106BLdesc, sub17TFl106BLdesc, sub18TFl106BLdesc,...
    sub19TFl106BLdesc, sub21TFl106BLdesc, sub22TFl106BLdesc, sub25TFl106BLdesc, sub26TFl106BLdesc, sub27TFl106BLdesc, sub28TFl106BLdesc);

TFl108BLgavg         = ft_freqgrandaverage(cfg, sub7TFl108BLdesc, sub8TFl108BLdesc, sub9TFl108BLdesc, sub10TFl108BLdesc,...
    sub11TFl108BLdesc, sub12TFl108BLdesc, sub13TFl108BLdesc, sub14TFl108BLdesc, sub15TFl108BLdesc, sub16TFl108BLdesc, sub17TFl108BLdesc, sub18TFl108BLdesc,...
    sub19TFl108BLdesc, sub21TFl108BLdesc, sub22TFl108BLdesc, sub25TFl108BLdesc, sub26TFl108BLdesc, sub27TFl108BLdesc, sub28TFl108BLdesc);

cd /home/meg/Data/Maor/Hypnosis/Subjects
save TFlBLgavgs TFl102BLgavg TFl104BLgavg TFl106BLgavg TFl108BLgavg
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
ft_singleplotTFR(cfg, TFl104BLgavg);
title('pre left')
subplot(2,2,2)
ft_singleplotTFR(cfg, TFl108BLgavg);
title('post left')
subplot(2,2,3)
ft_singleplotTFR(cfg, TFl102BLgavg);
title('pre right')
subplot(2,2,4)
ft_singleplotTFR(cfg, TFl106BLgavg);
title('post right')


%% for 17 subs without subtracting the baseline
subs = [7:12 14:19 21 25:28];
for i=subs
    load(sprintf('/home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/timeFrequency/TF_Low',i));
    for cond = 102:2:108
        eval([sprintf('sub%dcond%dTF=ft_freqdescriptives([],TF%dl)',i,cond,cond);]);
        clear(sprintf('TF%dl',cond));
    end;
end

cond102 = ['TFl102gavg = ft_freqgrandaverage(cfg'];
cond104 = ['TFl104gavg = ft_freqgrandaverage(cfg'];
cond106 = ['TFl106gavg = ft_freqgrandaverage(cfg'];
cond108 = ['TFl108gavg = ft_freqgrandaverage(cfg'];
for i=subs
    cond102 = [cond102, ', ', sprintf('sub%dcond102TF',i)];
    cond104 = [cond104, ', ', sprintf('sub%dcond104TF',i)];
    cond106 = [cond106, ', ', sprintf('sub%dcond106TF',i)];
    cond108 = [cond108, ', ', sprintf('sub%dcond108TF',i)];
end
cond102 = [cond102,');'];
cond104 = [cond104,');'];
cond106 = [cond106,');'];
cond108 = [cond108,');'];

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';
eval(cond102);
eval(cond104);
eval(cond106);
eval(cond108);

cd /home/meg/Data/Maor/Hypnosis
save TF17subsWithoutBL TFl102gavg TFl104gavg TFl106gavg TFl108gavg
clear
load TF17subsWithoutBL

%% plots
cfg              = [];
%cfg.zlim        = [-10*10^(-28) 6*10^(-28)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
figure;
subplot(2,2,1)
ft_singleplotTFR(cfg, TFl104gavg);
title('pre left')
subplot(2,2,2)
ft_singleplotTFR(cfg, TFl108gavg);
title('post left')
subplot(2,2,3)
ft_singleplotTFR(cfg, TFl102gavg);
title('pre right')
subplot(2,2,4)
ft_singleplotTFR(cfg, TFl106gavg);
title('post right')

%% cluster analysis
cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG','-A41'};
cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
cfg.correctm = 'cluster';
    cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
    cfg1.method='triangulation';
cfg.neighbours = ft_neighbourselection(cfg1);
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

cfg.latency     = [0.35 0.55];
cfg.frequency   = [1 5];

% statR = ft_freqstatistics(cfg,TFl102gavg,TFl106gavg);
% statL = ft_freqstatistics(cfg,TFl104gavg,TFl108gavg);
% stat.posclusters.prob

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
stat.stat2
