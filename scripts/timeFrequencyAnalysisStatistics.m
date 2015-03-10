% allSubs = [14 16 17 19 21 23:25 27 28 31 33:35 37 0:3 5:9 12 15 20 32 36 39];
% for i=allSubs
%     eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/timeFrequency/TFtest'])
%     eval(['sub',num2str(i),'WordLow = wordFirstLow;']);
%     eval(['sub',num2str(i),'NonWordLow = wordFirstLow;']);
%     eval(['sub',num2str(i),'WordLow.powspctrm = (wordFirstLow.powspctrm + wordSecondLow.powspctrm + wordSingleLow.powspctrm)/3;']);
%     eval(['sub',num2str(i),'NonWordLow.powspctrm = (nonWordFirstLow.powspctrm + nonWordSecondLow.powspctrm + nonWordSingleLow.powspctrm)/3;']);
%     clear nonWordFirstHigh nonWordFirstLow nonWordSecondHigh nonWordSecondLow...
%         nonWordSingleHigh nonWordSingleLow wordFirstHigh wordFirstLow wordSecondHigh...
%         wordSecondLow wordSingleHigh wordSingleLow
% end;
% 
% cfg= [];
% cfg.keepindividual = 'yes';
% WordLowGrAvg = ft_freqgrandaverage(cfg, sub14WordLow, sub16WordLow, sub17WordLow, sub19WordLow, sub21WordLow,...
%     sub23WordLow, sub24WordLow, sub25WordLow, sub27WordLow, sub28WordLow, sub31WordLow, sub33WordLow,...
%     sub34WordLow, sub35WordLow, sub37WordLow, sub0WordLow, sub1WordLow, sub2WordLow, sub3WordLow, sub5WordLow,...
%     sub6WordLow, sub7WordLow, sub8WordLow, sub9WordLow, sub12WordLow, sub15WordLow, sub20WordLow,...
%     sub32WordLow, sub36WordLow, sub39WordLow);
% NonWordLowGrAvg = ft_freqgrandaverage(cfg, sub14NonWordLow, sub16NonWordLow, sub17NonWordLow, sub19NonWordLow, sub21NonWordLow,...
%     sub23NonWordLow, sub24NonWordLow, sub25NonWordLow, sub27NonWordLow, sub28NonWordLow, sub31NonWordLow, sub33NonWordLow,...
%     sub34NonWordLow, sub35NonWordLow, sub37NonWordLow, sub0NonWordLow, sub1NonWordLow, sub2NonWordLow, sub3NonWordLow, sub5NonWordLow,...
%     sub6NonWordLow, sub7NonWordLow, sub8NonWordLow, sub9NonWordLow, sub12NonWordLow, sub15NonWordLow, sub20NonWordLow,...
%     sub32NonWordLow, sub36NonWordLow, sub39NonWordLow);

clear all
subsCon = [0:3 5:9 12 15 20 32 36 39];
for i = subsCon
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/timeFrequency/TFtest'])
    eval(['sub',num2str(i),'AllLow = wordFirstLow;']);
    eval(['sub',num2str(i),'AllHigh = wordFirstHigh;']);
    eval(['sub',num2str(i),'AllLow.powspctrm = (wordFirstLow.powspctrm + wordSecondLow.powspctrm + wordSingleLow.powspctrm + nonWordFirstLow.powspctrm + nonWordSecondLow.powspctrm + nonWordSingleLow.powspctrm)/6;']);
    eval(['sub',num2str(i),'AllHigh.powspctrm = (wordFirstHigh.powspctrm + wordSecondHigh.powspctrm + wordSingleHigh.powspctrm + nonWordFirstHigh.powspctrm + nonWordSecondHigh.powspctrm + nonWordSingleHigh.powspctrm)/6;']);
    clear nonWordFirstHigh nonWordFirstLow nonWordSecondHigh nonWordSecondLow...
        nonWordSingleHigh nonWordSingleLow wordFirstHigh wordFirstLow wordSecondHigh...
        wordSecondLow wordSingleHigh wordSingleLow
end;

cfg= [];
cfg.keepindividual = 'yes';
lowFreqGrAvgCon = ft_freqgrandaverage(cfg, sub0AllLow, sub1AllLow, sub2AllLow, sub3AllLow, sub5AllLow,...
    sub6AllLow, sub7AllLow, sub8AllLow, sub9AllLow, sub12AllLow, sub15AllLow, sub20AllLow,...
    sub32AllLow, sub36AllLow, sub39AllLow);
highFreqGrAvgCon = ft_freqgrandaverage(cfg, sub0AllHigh, sub1AllHigh, sub2AllHigh, sub3AllHigh, sub5AllHigh,...
    sub6AllHigh, sub7AllHigh, sub8AllHigh, sub9AllHigh, sub12AllHigh, sub15AllHigh, sub20AllHigh,...
    sub32AllHigh, sub36AllHigh, sub39AllHigh);

subsSZ = [14 16 17 19 21 23:25 27 28 31 33:35 37];
for i = subsSZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/timeFrequency/TFtest'])
    eval(['sub',num2str(i),'AllLow = wordFirstLow;']);
    eval(['sub',num2str(i),'AllHigh = wordFirstHigh;']);
    eval(['sub',num2str(i),'AllLow.powspctrm = (wordFirstLow.powspctrm + wordSecondLow.powspctrm + wordSingleLow.powspctrm + nonWordFirstLow.powspctrm + nonWordSecondLow.powspctrm + nonWordSingleLow.powspctrm)/6;']);
    eval(['sub',num2str(i),'AllHigh.powspctrm = (wordFirstHigh.powspctrm + wordSecondHigh.powspctrm + wordSingleHigh.powspctrm + nonWordFirstHigh.powspctrm + nonWordSecondHigh.powspctrm + nonWordSingleHigh.powspctrm)/6;']);
    clear nonWordFirstHigh nonWordFirstLow nonWordSecondHigh nonWordSecondLow...
        nonWordSingleHigh nonWordSingleLow wordFirstHigh wordFirstLow wordSecondHigh...
        wordSecondLow wordSingleHigh wordSingleLow
end;

cfg= [];
cfg.keepindividual = 'yes';
lowFreqGrAvgSZ = freqgrandaverage(cfg, sub14AllLow, sub16AllLow, sub17AllLow, sub19AllLow, sub21AllLow,...
    sub23AllLow, sub24AllLow, sub25AllLow, sub27AllLow, sub28AllLow, sub31AllLow, sub33AllLow,...
    sub34AllLow, sub35AllLow, sub37AllLow);
highFreqGrAvgSZ = freqgrandaverage(cfg, sub14AllHigh, sub16AllHigh, sub17AllHigh, sub19AllHigh, sub21AllHigh,...
    sub23AllHigh, sub24AllHigh, sub25AllHigh, sub27AllHigh, sub28AllHigh, sub31AllHigh, sub33AllHigh,...
    sub34AllHigh, sub35AllHigh, sub37AllHigh);

save TFallCondsGrAvg lowFreqGrAvgSZ highFreqGrAvgSZ lowFreqGrAvgCon highFreqGrAvgCon
clear all
load TFallCondsGrAvg

% merging some conditions together
clear all
subsCon = [0:3 5:9 12 15 20 32 36 39];
for i = subsCon
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/timeFrequency/TFtest'])
    eval(['sub',num2str(i),'WordLow = wordFirstLow;']);
    eval(['sub',num2str(i),'NonWordLow = wordFirstLow;']);
    eval(['sub',num2str(i),'SingleLow = wordFirstLow;']);
    eval(['sub',num2str(i),'FirstLow = wordFirstLow;']);  
    eval(['sub',num2str(i),'SecondLow = wordFirstLow;']);  
    eval(['sub',num2str(i),'WordLow.powspctrm = (wordFirstLow.powspctrm + wordSecondLow.powspctrm + wordSingleLow.powspctrm)/3;']);
    eval(['sub',num2str(i),'NonWordLow.powspctrm = (nonWordFirstLow.powspctrm + nonWordSecondLow.powspctrm + nonWordSingleLow.powspctrm)/3;']);
    eval(['sub',num2str(i),'SingleLow.powspctrm = (wordSingleLow.powspctrm + nonWordSingleLow.powspctrm)/2;']);
    eval(['sub',num2str(i),'FirstLow.powspctrm = (wordFirstLow.powspctrm + nonWordFirstLow.powspctrm)/2;']);
    eval(['sub',num2str(i),'SecondLow.powspctrm = (wordSecondLow.powspctrm + nonWordSecondLow.powspctrm)/2;']);
    clear nonWordFirstHigh nonWordFirstLow nonWordSecondHigh nonWordSecondLow...
        nonWordSingleHigh nonWordSingleLow wordFirstHigh wordFirstLow wordSecondHigh...
        wordSecondLow wordSingleHigh wordSingleLow
end;

cfg= [];
cfg.keepindividual = 'yes';
WordLowGrAvgCon = ft_freqgrandaverage(cfg, sub0WordLow, sub1WordLow, sub2WordLow, sub3WordLow, sub5WordLow,...
    sub6WordLow, sub7WordLow, sub8WordLow, sub9WordLow, sub12WordLow, sub15WordLow, sub20WordLow,...
    sub32WordLow, sub36WordLow, sub39WordLow);
NonWordLowGrAvgCon = ft_freqgrandaverage(cfg, sub0NonWordLow, sub1NonWordLow, sub2NonWordLow, sub3NonWordLow, sub5NonWordLow,...
    sub6NonWordLow, sub7NonWordLow, sub8NonWordLow, sub9NonWordLow, sub12NonWordLow, sub15NonWordLow, sub20NonWordLow,...
    sub32NonWordLow, sub36NonWordLow, sub39NonWordLow);
SingleLowGrAvgCon = ft_freqgrandaverage(cfg, sub0SingleLow, sub1SingleLow, sub2SingleLow, sub3SingleLow, sub5SingleLow,...
    sub6SingleLow, sub7SingleLow, sub8SingleLow, sub9SingleLow, sub12SingleLow, sub15SingleLow, sub20SingleLow,...
    sub32SingleLow, sub36SingleLow, sub39SingleLow);
FirstLowGrAvgCon = ft_freqgrandaverage(cfg, sub0FirstLow, sub1FirstLow, sub2FirstLow, sub3FirstLow, sub5FirstLow,...
    sub6FirstLow, sub7FirstLow, sub8FirstLow, sub9FirstLow, sub12FirstLow, sub15FirstLow, sub20FirstLow,...
    sub32FirstLow, sub36FirstLow, sub39FirstLow);
SecondLowGrAvgCon = ft_freqgrandaverage(cfg, sub0SecondLow, sub1SecondLow, sub2SecondLow, sub3SecondLow, sub5SecondLow,...
    sub6SecondLow, sub7SecondLow, sub8SecondLow, sub9SecondLow, sub12SecondLow, sub15SecondLow, sub20SecondLow,...
    sub32SecondLow, sub36SecondLow, sub39SecondLow);

cd /home/meg/Data/Maor/SchizoProject/Subjects
save ControlMergedConds WordLowGrAvgCon NonWordLowGrAvgCon SingleLowGrAvgCon FirstLowGrAvgCon SecondLowGrAvgCon
clear all

subsSZ = [14 16 17 19 21 23:25 27 28 31 33:35 37];
for i = subsSZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/timeFrequency/TFtest'])
    eval(['sub',num2str(i),'WordLow = wordFirstLow;']);
    eval(['sub',num2str(i),'NonWordLow = wordFirstLow;']);
    eval(['sub',num2str(i),'SingleLow = wordFirstLow;']);
    eval(['sub',num2str(i),'FirstLow = wordFirstLow;']);  
    eval(['sub',num2str(i),'SecondLow = wordFirstLow;']);  
    eval(['sub',num2str(i),'WordLow.powspctrm = (wordFirstLow.powspctrm + wordSecondLow.powspctrm + wordSingleLow.powspctrm)/3;']);
    eval(['sub',num2str(i),'NonWordLow.powspctrm = (nonWordFirstLow.powspctrm + nonWordSecondLow.powspctrm + nonWordSingleLow.powspctrm)/3;']);
    eval(['sub',num2str(i),'SingleLow.powspctrm = (wordSingleLow.powspctrm + nonWordSingleLow.powspctrm)/2;']);
    eval(['sub',num2str(i),'FirstLow.powspctrm = (wordFirstLow.powspctrm + nonWordFirstLow.powspctrm)/2;']);
    eval(['sub',num2str(i),'SecondLow.powspctrm = (wordSecondLow.powspctrm + nonWordSecondLow.powspctrm)/2;']);
    clear nonWordFirstHigh nonWordFirstLow nonWordSecondHigh nonWordSecondLow...
        nonWordSingleHigh nonWordSingleLow wordFirstHigh wordFirstLow wordSecondHigh...
        wordSecondLow wordSingleHigh wordSingleLow
end;

cfg= [];
cfg.keepindividual = 'yes';
WordLowGrAvgSZ = ft_freqgrandaverage(cfg, sub14WordLow, sub16WordLow, sub17WordLow, sub19WordLow, sub21WordLow,...
    sub23WordLow, sub24WordLow, sub25WordLow, sub27WordLow, sub28WordLow, sub31WordLow, sub33WordLow,...
    sub34WordLow, sub35WordLow, sub37WordLow);
NonWordLowGrAvgSZ = ft_freqgrandaverage(cfg, sub14NonWordLow, sub16NonWordLow, sub17NonWordLow, sub19NonWordLow, sub21NonWordLow,...
    sub23NonWordLow, sub24NonWordLow, sub25NonWordLow, sub27NonWordLow, sub28NonWordLow, sub31NonWordLow, sub33NonWordLow,...
    sub34NonWordLow, sub35NonWordLow, sub37NonWordLow);
SingleLowGrAvgSZ = ft_freqgrandaverage(cfg, sub14SingleLow, sub16SingleLow, sub17SingleLow, sub19SingleLow, sub21SingleLow,...
    sub23SingleLow, sub24SingleLow, sub25SingleLow, sub27SingleLow, sub28SingleLow, sub31SingleLow, sub33SingleLow,...
    sub34SingleLow, sub35SingleLow, sub37SingleLow);
FirstLowGrAvgSZ = ft_freqgrandaverage(cfg, sub14FirstLow, sub16FirstLow, sub17FirstLow, sub19FirstLow, sub21FirstLow,...
    sub23FirstLow, sub24FirstLow, sub25FirstLow, sub27FirstLow, sub28FirstLow, sub31FirstLow, sub33FirstLow,...
    sub34FirstLow, sub35FirstLow, sub37FirstLow);
SecondLowGrAvgSZ = ft_freqgrandaverage(cfg, sub14SecondLow, sub16SecondLow, sub17SecondLow, sub19SecondLow, sub21SecondLow,...
    sub23SecondLow, sub24SecondLow, sub25SecondLow, sub27SecondLow, sub28SecondLow, sub31SecondLow, sub33SecondLow,...
    sub34SecondLow, sub35SecondLow, sub37SecondLow);

cd /home/meg/Data/Maor/SchizoProject/Subjects
save SZMergedConds WordLowGrAvgSZ NonWordLowGrAvgSZ SingleLowGrAvgSZ FirstLowGrAvgSZ SecondLowGrAvgSZ
clear all

load SZMergedConds 
load ControlMergedConds
%% statistics: each condition against it's BL
% Low freqs    
    % for control

        lala=lowFreqGrAvgCon;
        lala.time=lowFreqGrAvgCon.time(11:46); %-0.4 : -0.05 sec
        lala.powspctrm=lala.powspctrm(:,:,:,11:46);

        lala.powspctrm = repmat(nanmean(lala.powspctrm(:,:,:,1:end),4),[1 1 1 size(lowFreqGrAvgCon.powspctrm,4)]);
        BL = lowFreqGrAvgCon;
        BL.powspctrm = lala.powspctrm;
        clear lala

cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG'};
cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
        cfg.correctm = 'cluster';
% cfg.correctm = 'FDR';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
% cfg1.method='distance';
cfg.neighbours = ft_neighbourselection(cfg1);
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:2*15) = [ones(1,15) 2*ones(1,15)];
cfg.design(2,1:2*15) = [1:15 1:15];
cfg.ivar =1;
cfg.uvar =2;

stat = ft_freqstatistics(cfg,lowFreqGrAvgCon,BL);

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value

lowFreqConStat = stat;

%plot
figure
cfg =[];
cfg.zlim = [-5 5];  
cfg.parameter = 'stat2';
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
ft_singleplotTFR(cfg,lowFreqConStat);

    % for SZ

        lala=lowFreqGrAvgSZ;
        lala.time=lowFreqGrAvgSZ.time(11:46); %-0.4 : -0.05 sec
        lala.powspctrm=lala.powspctrm(:,:,:,11:46);

        lala.powspctrm = repmat(nanmean(lala.powspctrm(:,:,:,1:end),4),[1 1 1 size(lowFreqGrAvgSZ.powspctrm,4)]);
        BL = lowFreqGrAvgSZ;
        BL.powspctrm = lala.powspctrm;
        clear lala

cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG'};
cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
        cfg.correctm = 'cluster';
% cfg.correctm = 'FDR';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
% cfg1.method='distance';
cfg.neighbours = ft_neighbourselection(cfg1);
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:2*15) = [ones(1,15) 2*ones(1,15)];
cfg.design(2,1:2*15) = [1:15 1:15];
cfg.ivar =1;
cfg.uvar =2;

stat = ft_freqstatistics(cfg,lowFreqGrAvgSZ,BL);

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value

lowFreqSZStat = stat;

%plot
figure
cfg =[];
cfg.zlim = [-5 5];  
cfg.parameter = 'stat2';
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
ft_singleplotTFR(cfg,lowFreqSZStat);

% High freqs    
    % for control

        lala=highFreqGrAvgCon;
        lala.time=highFreqGrAvgCon.time(11:46); %-0.4 : -0.05 sec
        lala.powspctrm=lala.powspctrm(:,:,:,11:46);

        lala.powspctrm = repmat(nanmean(lala.powspctrm(:,:,:,1:end),4),[1 1 1 size(highFreqGrAvgCon.powspctrm,4)]);
        BL = highFreqGrAvgCon;
        BL.powspctrm = lala.powspctrm;
        clear lala

cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG'};
cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
        cfg.correctm = 'cluster';
% cfg.correctm = 'FDR';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
% cfg1.method='distance';
cfg.neighbours = ft_neighbourselection(cfg1);
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:2*15) = [ones(1,15) 2*ones(1,15)];
cfg.design(2,1:2*15) = [1:15 1:15];
cfg.ivar =1;
cfg.uvar =2;

stat = ft_freqstatistics(cfg,highFreqGrAvgCon,BL);

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value

highFreqConStat = stat;

%plot
figure
cfg =[];
cfg.zlim = [-5 5];  
cfg.parameter = 'stat2';
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
ft_singleplotTFR(cfg,highFreqConStat);

    % for SZ

        lala=highFreqGrAvgSZ;
        lala.time=highFreqGrAvgSZ.time(11:46); %-0.4 : -0.05 sec
        lala.powspctrm=lala.powspctrm(:,:,:,11:46);

        lala.powspctrm = repmat(nanmean(lala.powspctrm(:,:,:,1:end),4),[1 1 1 size(highFreqGrAvgSZ.powspctrm,4)]);
        BL = highFreqGrAvgSZ;
        BL.powspctrm = lala.powspctrm;
        clear lala

cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG'};
cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/'
        cfg.correctm = 'cluster';
% cfg.correctm = 'FDR';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
% cfg1.method='distance';
cfg.neighbours = ft_neighbourselection(cfg1);
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:2*15) = [ones(1,15) 2*ones(1,15)];
cfg.design(2,1:2*15) = [1:15 1:15];
cfg.ivar =1;
cfg.uvar =2;

stat = ft_freqstatistics(cfg,highFreqGrAvgSZ,BL);

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value

highFreqSZStat = stat;

%plot
figure
cfg =[];
cfg.zlim = [-5 5];  
cfg.parameter = 'stat2';
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
ft_singleplotTFR(cfg,highFreqSZStat);

%% SZ vs. Con 
load TFgvCon 
load TFgvSZ
% see the difference between two conditions:
condition1 = WordLowGrAvgCon;
condition2 = WordLowGrAvgSZ;

TFAdiff = condition1;
TFAdiff.powspctrm = condition1.powspctrm - condition2.powspctrm; % change conditions

cfg              = [];
cfg.baseline     = [-0.5 0];
cfg.baselinetype = 'absolute';
cfg.zlim        = [-4*10^(-27) 2*10^(-27)];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
subplot(1,3,1)
ft_singleplotTFR(cfg, condition1);
title('Con')
subplot(1,3,2)
ft_singleplotTFR(cfg, condition2);
title('SZ')
subplot(1,3,3)
ft_singleplotTFR(cfg, TFAdiff); % for better resulution in the plot you can choose a window and then channels
title('Diff')


cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG'};
% cfg.avgoverchan = 'yes';   
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
cfg.design(1,1:2*15) = [ones(1,15) 2*ones(1,15)];
cfg.design(2,1:2*15) = [1:15 1:15];
cfg.ivar =1;
cfg.uvar =2;
cfg.avgovertime = 'yes'; % cfg.avgovertime = 'no';
cfg.avgoverfreq = 'yes'; % cfg.avgoverfreq = 'no';

cfg.latency     = [0.35 0.55];
cfg.frequency   = [1 5];

stat = ft_freqstatistics(cfg,NonWordLowGrAvgCon,NonWordLowGrAvgSZ,WordLowGrAvgCon,WordLowGrAvgSZ);
stat.posclusters.prob

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
stat.stat2
