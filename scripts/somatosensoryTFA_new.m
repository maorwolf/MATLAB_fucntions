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
    cfgtfrl.toi       = -0.5:0.03:1;
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
clear all
subs = [7:12 14:19 21 25:28];
for i = subs;
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/TF_Low'])
    cfg=[];
    cfg.baseline     = [-0.1 0];
    cfg.baselinetype = 'absolute';
    for j=102:2:108
        eval(['TFl',num2str(j),'BL=ft_freqbaseline(cfg, TF',num2str(j),'l);']);
        eval(['sub',num2str(i),'TFl',num2str(j),'BL = TFl',num2str(j),'BL;']);
    end
    clear cfg TF102l TFl102BL TF104l TFl104BL TF106l TFl106BL TF108l TFl108BL
    for cond = 102:2:108
        eval(['sub',num2str(i),'TFl',num2str(cond),'BLdesc = ft_freqdescriptives([],sub',num2str(i),'TFl',num2str(cond),'BL);']);
    end;
    eval(['clear sub',num2str(i),'TFl102BL sub',num2str(i),'TFl104BL sub',num2str(i),'TFl106BL sub',num2str(i),'TFl108BL']);
    disp(i);
end;

%% grand average

cfg = [];
cfg.keepindividual = 'no';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFl102BLgavg         = ft_freqgrandaverage(cfg, sub7TFl102BLdesc, sub8TFl102BLdesc, sub9TFl102BLdesc, sub10TFl102BLdesc,...
    sub11TFl102BLdesc, sub12TFl102BLdesc, sub14TFl102BLdesc, sub15TFl102BLdesc, sub16TFl102BLdesc, sub17TFl102BLdesc, sub18TFl102BLdesc,...
    sub19TFl102BLdesc, sub21TFl102BLdesc, sub25TFl102BLdesc, sub26TFl102BLdesc, sub27TFl102BLdesc, sub28TFl102BLdesc);

TFl104BLgavg         = ft_freqgrandaverage(cfg, sub7TFl104BLdesc, sub8TFl104BLdesc, sub9TFl104BLdesc, sub10TFl104BLdesc,...
    sub11TFl104BLdesc, sub12TFl104BLdesc, sub13TFl104BLdesc, sub14TFl104BLdesc, sub15TFl104BLdesc, sub16TFl104BLdesc, sub17TFl104BLdesc, sub18TFl104BLdesc,...
    sub19TFl104BLdesc, sub21TFl104BLdesc, sub22TFl104BLdesc, sub25TFl104BLdesc, sub26TFl104BLdesc, sub27TFl104BLdesc, sub28TFl104BLdesc);

TFl106BLgavg         = ft_freqgrandaverage(cfg, sub7TFl106BLdesc, sub8TFl106BLdesc, sub9TFl106BLdesc, sub10TFl106BLdesc,...
    sub11TFl106BLdesc, sub12TFl106BLdesc, sub13TFl106BLdesc, sub14TFl106BLdesc, sub15TFl106BLdesc, sub16TFl106BLdesc, sub17TFl106BLdesc, sub18TFl106BLdesc,...
    sub19TFl106BLdesc, sub21TFl106BLdesc, sub22TFl106BLdesc, sub25TFl106BLdesc, sub26TFl106BLdesc, sub27TFl106BLdesc, sub28TFl106BLdesc);

TFl108BLgavg         = ft_freqgrandaverage(cfg, sub7TFl108BLdesc, sub8TFl108BLdesc, sub9TFl108BLdesc, sub10TFl108BLdesc,...
    sub11TFl108BLdesc, sub12TFl108BLdesc, sub13TFl108BLdesc, sub14TFl108BLdesc, sub15TFl108BLdesc, sub16TFl108BLdesc, sub17TFl108BLdesc, sub18TFl108BLdesc,...
    sub19TFl108BLdesc, sub21TFl108BLdesc, sub22TFl108BLdesc, sub25TFl108BLdesc, sub26TFl108BLdesc, sub27TFl108BLdesc, sub28TFl108BLdesc);

cfg.keepindividual = 'no';
TFlAllgavg = ft_freqgrandaverage(cfg, sub7TFl102BLdesc, sub7TFl104BLdesc, sub7TFl106BLdesc, sub7TFl108BLdesc, sub8TFl102BLdesc, sub8TFl104BLdesc, sub8TFl106BLdesc, sub8TFl108BLdesc, sub9TFl102BLdesc, sub9TFl104BLdesc, sub9TFl106BLdesc, sub9TFl108BLdesc, sub10TFl102BLdesc, sub10TFl104BLdesc, sub10TFl106BLdesc, sub10TFl108BLdesc, sub11TFl102BLdesc, sub11TFl104BLdesc, sub11TFl106BLdesc, sub11TFl108BLdesc, sub12TFl102BLdesc, sub12TFl104BLdesc, sub12TFl106BLdesc, sub12TFl108BLdesc, sub14TFl102BLdesc, sub14TFl104BLdesc, sub14TFl106BLdesc, sub14TFl108BLdesc, sub15TFl102BLdesc, sub15TFl104BLdesc, sub15TFl106BLdesc, sub15TFl108BLdesc, sub16TFl102BLdesc, sub16TFl104BLdesc, sub16TFl106BLdesc, sub16TFl108BLdesc, sub17TFl102BLdesc, sub17TFl104BLdesc, sub17TFl106BLdesc, sub17TFl108BLdesc, sub18TFl102BLdesc, sub18TFl104BLdesc, sub18TFl106BLdesc, sub18TFl108BLdesc, sub19TFl102BLdesc, sub19TFl104BLdesc, sub19TFl106BLdesc, sub19TFl108BLdesc, sub21TFl102BLdesc, sub21TFl104BLdesc, sub21TFl106BLdesc, sub21TFl108BLdesc, sub25TFl102BLdesc, sub25TFl104BLdesc, sub25TFl106BLdesc, sub25TFl108BLdesc, sub26TFl102BLdesc, sub26TFl104BLdesc, sub26TFl106BLdesc, sub26TFl108BLdesc, sub27TFl102BLdesc, sub27TFl104BLdesc, sub27TFl106BLdesc, sub27TFl108BLdesc, sub28TFl102BLdesc, sub28TFl104BLdesc, sub28TFl106BLdesc, sub28TFl108BLdesc);

cd /home/meg/Data/Maor/Hypnosis/Subjects
save TFlBLgavgs TFl102BLgavg TFl104BLgavg TFl106BLgavg TFl108BLgavg
save TFlBLall TFlAllgavg
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


%% for 17 subs without subtracting the baseline
subs = [7:12 14:19 21 25:28];
for i=subs
    load(sprintf('/home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/timeFrequency/TF_Low',i));
    for cond = 102:2:108
        eval(sprintf('sub%dcond%dTF=ft_freqdescriptives([],TF%dl)',i,cond,cond));
        clear(sprintf('TF%dl',cond));
    end;
end

cond102 = 'TFl102gavg = ft_freqgrandaverage(cfg';
cond104 = 'TFl104gavg = ft_freqgrandaverage(cfg';
cond106 = 'TFl106gavg = ft_freqgrandaverage(cfg';
cond108 = 'TFl108gavg = ft_freqgrandaverage(cfg';
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


TF102min106=TFl102gavg;
TF102min106.powspctrm=TFl102gavg.powspctrm-TFl106gavg.powspctrm;
TF104min108=TFl104gavg;
TF104min108.powspctrm=TFl104gavg.powspctrm-TFl108gavg.powspctrm;
figure;
cfg.xlim=[-0.15 0.5];
subplot(1,2,1)
ft_singleplotTFR(cfg, TF102min106);
title('pre right minus post right')
subplot(1,2,2)
ft_singleplotTFR(cfg, TF104min108);
title('pre left minus post left')


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

cfg.latency     = [0.455 0.465];
cfg.frequency   = [11 13];

statR = ft_freqstatistics(cfg,TFl102gavg,TFl106gavg);
statL = ft_freqstatistics(cfg,TFl104gavg,TFl108gavg);


stat.posclusters.prob

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
stat.stat2


%% BL for 17
clear all
subs = [7:12 14:19 21 25:28];
for i=subs
    load(sprintf('/home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/timeFrequency/TF_Low',i));
    for cond = 102:2:108
        eval(sprintf('sub%dcond%dTF=ft_freqdescriptives([],TF%dl)',i,cond,cond));
        clear(sprintf('TF%dl',cond));
    end;
end


for i = subs;
    cfg=[];
    cfg.baseline     = [-0.15 0];
    cfg.baselinetype = 'absolute'; % 'absolute', 'relchange' or 'relative' (default = 'absolute')
    for j=102:2:108
        eval(['sub',num2str(i),'TFl',num2str(j),'BL = ft_freqbaseline(cfg, sub',num2str(i),'cond',num2str(j),'TF);']);
    end
end;

cfg = [];
cfg.keepindividual = 'no';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

for i=subs
    eval(['sub',num2str(i),'TFlAllBL=ft_freqgrandaverage(cfg,sub',num2str(i),'TFl102BL, sub',num2str(i),'TFl104BL, sub',num2str(i),'TFl106BL, sub',num2str(i),'TFl108BL)']);
end

TFlAllavg= ft_freqgrandaverage(cfg, sub7TFlAllBL, sub8TFlAllBL, sub9TFlAllBL, sub10TFlAllBL, sub11TFlAllBL, sub12TFlAllBL, sub14TFlAllBL, sub15TFlAllBL,...
    sub16TFlAllBL, sub17TFlAllBL, sub18TFlAllBL, sub19TFlAllBL, sub21TFlAllBL, sub25TFlAllBL, sub26TFlAllBL, sub27TFlAllBL, sub28TFlAllBL);


cfg.keepindividual = 'yes';
TFlAll= ft_freqgrandaverage(cfg, sub7TFlAllBL, sub8TFlAllBL, sub9TFlAllBL, sub10TFlAllBL, sub11TFlAllBL, sub12TFlAllBL, sub14TFlAllBL, sub15TFlAllBL,...
    sub16TFlAllBL, sub17TFlAllBL, sub18TFlAllBL, sub19TFlAllBL, sub21TFlAllBL, sub25TFlAllBL, sub26TFlAllBL, sub27TFlAllBL, sub28TFlAllBL);


save TFlAllBLabsolute TFlAll TFlAllavg
clear all
load TFlAll
% plot
cfg              = [];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
cfg.xlim         = [-0.15 0.6];
figure;
ft_singleplotTFR(cfg, TFlAllavg);

%% reducing the evoked
clear all
subs = [7:12 14:19 21 25:28];
for i=subs
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/datafinal.mat']);
    data=ft_timelockanalysis([],datafinal);
    datafinal.trial=[]; datafinal.trial{1}=data.avg;
    datafinal.time=[]; datafinal.time{1}=data.time;
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
    cfgtfrl.toi       = -0.5:0.03:1;
    cfgtfrl.channel   = {'MEG', '-A41'};
    eval(['sub',num2str(i),'TFavg = ft_freqanalysis(cfgtfrl, data);']);
    clear data datafinal
end

for i = subs;
    cfg=[];
    cfg.baseline     = [-0.15 0];
    cfg.baselinetype = 'absolute'; % 'absolute', 'relchange' or 'relative' (default = 'absolute')
    eval(['sub',num2str(i),'TFBL = ft_freqbaseline(cfg, sub',num2str(i),'TFavg);']);
end;

cfg = [];
cfg.keepindividual = 'no';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFlAllBL= ft_freqgrandaverage(cfg, sub7TFBL, sub8TFBL, sub9TFBL, sub10TFBL, sub11TFBL, sub12TFBL, sub14TFBL, sub15TFBL, sub16TFBL, sub17TFBL,...
    sub18TFBL, sub19TFBL, sub21TFBL, sub25TFBL, sub26TFBL, sub27TFBL, sub28TFBL);

save TFlAllBLrel TFlAllBL
%% 
clear all
load TFlAllBLabsolute
load TFlAllBL
%TFlAll.powspctrm=TFlAll.powspctrm.*10^27;
%TFlAllBL.powspctrm=TFlAllBL.powspctrm.*10^27;
TFlAllInd=TFlAll;
%TFlAllInd.powspctrm=TFlAll.powspctrm-TFlAllBL.powspctrm;

for i=1:17
    TFBL(i,1:247,1:37,1:51)=TFlAllBL.powspctrm;
end

TFlAllInd.powspctrm=TFlAll.powspctrm-(TFBL);


% plot
cfg              = [];
%cfg.zlim         = [-0.1 0.1];
cfg.interactive  = 'no';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
cfg.xlim         = [-0.15 0.5];
figure;
subplot(1,2,1)
ft_singleplotTFR(cfg, TFlAll);
subplot(1,2,2)
ft_singleplotTFR(cfg, TFlAllBL);
subplot(1,3,3)
ft_singleplotTFR(cfg, TFlAllInd);

%% statistics against the BL
% Low freqs    

        lala=TFlAllInd;
        lala.time=TFlAllInd.time(12:17); %-0.14 : 0.01 sec
        lala.powspctrm=lala.powspctrm(:,:,:,12:17);

        lala.powspctrm = repmat(nanmean(lala.powspctrm(:,:,:,1:end),4),[1 1 1 size(TFlAllInd.powspctrm,4)]);
        BL = TFlAllInd;
        BL.powspctrm = lala.powspctrm;
        clear lala

cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG'};
cfg.avgoverchan = 'yes';   
        cfg.correctm = 'cluster';
% cfg.correctm = 'FDR';
        cfg1.gradfile = '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
% cfg1.method='distance';
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

stat = ft_freqstatistics(cfg,TFlAllInd,BL);

stat.stat2 = stat.mask.*(stat.stat); %  gives significatif t-value

%plot
figure
cfgp =[];
cfgp.xlim = [-0.15 0.5];
cfgp.ylim = [1 40];
cfgp.zlim = [-5 5];  
cfgp.parameter = 'stat2';
cfgp.layout = '4D248.lay';
cfgp.interactive = 'no';
%cfgp.colormap = gray(10); 
ft_singleplotTFR(cfgp,stat);

save TFfinal TFBL BL TFlAll TFlAllBL TFlAllInd TFlAllavg

%% time frequency for control
clear
subs = [101, 104:116];
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
    cfgtfrl.toi       = -0.5:0.03:1;
    cfgtfrl.channel   = {'MEG', '-A41'};
    TFALL = ft_freqanalysis(cfgtfrl, data);
    
    save TF_Low TFALL
    clear cfg cfgtfrl data datafinal TFALL
end;

%% BL for control
clear all
subs = [101, 104:116];
for i=subs
    load(sprintf('/home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/timeFrequency/TF_Low',i));
    eval(sprintf('sub%dTFALL=ft_freqdescriptives([],TFALL)',i));
end


for i = subs;
    cfg=[];
    cfg.baseline     = [-0.15 0];
    cfg.baselinetype = 'relative'; % 'absolute', 'relchange' or 'relative' (default = 'absolute')
    eval(['sub',num2str(i),'TFALLBL = ft_freqbaseline(cfg, sub',num2str(i),'TFALL);']);
end;

cfg = [];
cfg.keepindividual = 'no';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';


TFlAllavg= ft_freqgrandaverage(cfg, sub101TFALLBL, sub104TFALLBL, sub105TFALLBL, sub106TFALLBL, sub107TFALLBL, sub108TFALLBL, sub109TFALLBL, sub110TFALLBL,...
    sub111TFALLBL, sub112TFALLBL, sub113TFALLBL, sub114TFALLBL, sub115TFALLBL, sub116TFALLBL);


cfg.keepindividual = 'yes';
TFlAll= ft_freqgrandaverage(cfg, sub101TFALLBL, sub104TFALLBL, sub105TFALLBL, sub106TFALLBL, sub107TFALLBL, sub108TFALLBL, sub109TFALLBL, sub110TFALLBL,...
    sub111TFALLBL, sub112TFALLBL, sub113TFALLBL, sub114TFALLBL, sub115TFALLBL, sub116TFALLBL);


save con_TFlAllBLrelative TFlAll TFlAllavg
clear all
load con_TFlAllBLrelative
% plot
cfg              = [];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
cfg.xlim         = [-0.15 0.6];
figure;
ft_singleplotTFR(cfg, TFlAllavg);

%% reducing the evoked
clear all
subs = [101, 104:116];
for i=subs
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/datafinal.mat']);
    data=ft_timelockanalysis([],datafinal);
    datafinal.trial=[]; datafinal.trial{1}=data.avg;
    datafinal.time=[]; datafinal.time{1}=data.time;
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
    cfgtfrl.toi       = -0.5:0.03:1;
    cfgtfrl.channel   = {'MEG', '-A41'};
    eval(['sub',num2str(i),'TFavg = ft_freqanalysis(cfgtfrl, data);']);
    clear data datafinal
end

for i = subs;
    cfg=[];
    cfg.baseline     = [-0.15 0];
    cfg.baselinetype = 'relative'; % 'absolute', 'relchange' or 'relative' (default = 'absolute')
    eval(['sub',num2str(i),'TFBL = ft_freqbaseline(cfg, sub',num2str(i),'TFavg);']);
end;

cfg = [];
cfg.keepindividual = 'no';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFlAllBL= ft_freqgrandaverage(cfg, sub101TFBL, sub104TFBL, sub105TFBL, sub106TFBL, sub107TFBL, sub108TFBL, sub109TFBL,...
    sub110TFBL, sub111TFBL, sub112TFBL, sub113TFBL, sub114TFBL, sub115TFBL, sub116TFBL);

save conTFlAllBLrel TFlAllBL
%% 
clear all
load conTFlAllBLrel
load con_TFlAllBLrelative

% plot
cfg              = [];
%cfg.zlim         = [-0.1 0.1];
cfg.interactive  = 'no';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
cfg.xlim         = [-0.15 0.5];
figure;
subplot(1,2,1)
ft_singleplotTFR(cfg, TFlAll);
subplot(1,2,2)
ft_singleplotTFR(cfg, TFlAllBL);