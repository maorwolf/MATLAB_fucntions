% creating a time table for all subs:
% -----------------------------------------------------
% % If we need the trigger channel to extract the times
% resp = readChan('xc,hb,lf_c,rfhp0.1Hz','RESPONSE');
% figure; plot(resp);
% trig = readTrig_BIU('xc,hb,lf_c,rfhp0.1Hz');
% figure; plot(trig);
% 
% % sub and conds definitions

%% -------------------- Preprocessing and cleaning ------------------------
clear all
source = 'xc,hb,lf_c,rfhp0.1Hz';
subRow = 1; % change to the row of the subject from the time table


% 1. find Bad Channels
findBadChans(source);
channels = {'MEG'}; % if there were bad channs % channels = {'MEG','-A41'}; % or % channels = {'MEG','-A41','-A208'};

%% 2. creating trl matrix
% codes:
% ---------------------------
% rest = 100                 |
% hypnosis induction = 110   |
% half body = 120            |
% out of body = 130          |
% dehypnosis = 140           |
% ---------------------------

timeMat = [2034	124102	310255	752750	762923	946024	1129125	1515673	1658085	1790325;
1017	123085	308221	732406	733423	927714	1139298	1424122	1532966	1642826;
1017	123085	127154	300083	798526	971455	1149470	1490242	1602137	1708946;
1017	123085	312500	749600	749600	956300	1140000	1525000	1694000	1785000;
1017	123085	297200	686400	686400	880100	1087419	1403777	1555000	1625000;
1017	123085	294300	627100	627100	784100	976541	1281710	1399708	1464811;
1017	123085	293300	673400	673400	848300	1052833	1338675	1531948	1626551;
1017	123085	305169	632717	632717	803800	996885	1293917	1451587	1554327;
1017	128171	325514	701889	712061	840300	1019264	1281710	1473966	1571620;
1017	123085	294997	623562	624579	777700	976541	1220676	1440398	1560431;
1017	123085	298048	722233	724268	882500	1052833	1332571	1517707	1626551;
1017	123085	320427	640855	1012144	1106000	651027	905335	1349864	1464811;
1017	123085	305169	600166	610338	7.83E+005	966369	1210504	1372243	1495328;
1017	123085	294997	698837	701889	829100	996885	1241021	1388519	1483000;
306186	428254	431306	879904	1230848	1367000	884990	1124039	1632654	1708946;
1017	123085	300083	579821	584907	686000	874818	1108781	1195245	1256279;
1017	123085	294997	701889	702906	839215	1010109	1276624	1463794	1528897;
1017	123085	310255	651027	656113	778181	959248	1205418	1404795	1474984;
40689	183101	356031	762923	778181	913473	1083350	1393605	1571620	1673343;
20345	142412	315341	661200	666286	823956	996885	1312227	1449553	1556362];

timeVec = timeMat(subRow,:);

% for rest (100)
cfg.trl(1,1) = timeVec(1)+round(1017.23*10);
cfg.trl(1,2) = round(cfg.trl(1,1)+1017.23*2);
cfg.trl(1,3) = 0;
cfg.trl(1,4) = 100;
for i=2:59
    cfg.trl(i,1) = round(cfg.trl(i-1,1)+1017.23);
    cfg.trl(i,2) = round(cfg.trl(i,1)+1017.23*2);
    cfg.trl(i,3) = 0;
    cfg.trl(i,4) = 100;
end

% for hypnosis induction (110)
cfg.trl(60,1) = timeVec(3);
cfg.trl(60,2) = round(cfg.trl(60,1)+1017.23*2);
cfg.trl(60,3) = 0;
cfg.trl(60,4) = 110;
for i=61:118
    cfg.trl(i,1) = round(cfg.trl(i-1,1)+1017.23);
    cfg.trl(i,2) = round(cfg.trl(i,1)+1017.23*2);
    cfg.trl(i,3) = 0;
    cfg.trl(i,4) = 110;
end

% for half body (120) 
cfg.trl(119,1) = timeVec(5);
cfg.trl(119,2) = round(cfg.trl(119,1)+1017.23*2);
cfg.trl(119,3) = 0;
cfg.trl(119,4) = 120;
for i=120:177
    cfg.trl(i,1) = round(cfg.trl(i-1,1)+1017.23);
    cfg.trl(i,2) = round(cfg.trl(i,1)+1017.23*2);
    cfg.trl(i,3) = 0;
    cfg.trl(i,4) = 120;
end

% out of body (130) 
cfg.trl(178,1) = timeVec(7);
cfg.trl(178,2) = round(cfg.trl(178,1)+1017.23*2);
cfg.trl(178,3) = 0;
cfg.trl(178,4) = 130;
for i=179:236
    cfg.trl(i,1) = round(cfg.trl(i-1,1)+1017.23);
    cfg.trl(i,2) = round(cfg.trl(i,1)+1017.23*2);
    cfg.trl(i,3) = 0;
    cfg.trl(i,4) = 130;
end

% dehypnosis (140) 
cfg.trl(237,1) = timeVec(9);
cfg.trl(237,2) = round(cfg.trl(237,1)+1017.23*2);
cfg.trl(237,3) = 0;
cfg.trl(237,4) = 140;
for i=238:295
    cfg.trl(i,1) = round(cfg.trl(i-1,1)+1017.23);
    cfg.trl(i,2) = round(cfg.trl(i,1)+1017.23*2);
    cfg.trl(i,3) = 0;
    cfg.trl(i,4) = 140;
end
%% 3. finding trials and defining them
cfg.dataset     = source;
cfg.trialfun    = 'trialfun_beg';
cfg             = ft_definetrial(cfg);

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
channels = {'MEG','-A41'}; % run only if necessary and change -A41 if required

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
cfg.component   = [1 16]; % change to the components you want to clean!!!!!!! empty if no components shell be cleaned
dataica         = ft_rejectcomponent(cfg, comp);

% baseline correction
dataica=correctBL(dataica);
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

%% 8. split conditions
% recreating the trl matrix
datafinal.cfg.trl(:,1:2)=datafinal.sampleinfo(:,1:2);
datafinal.cfg.trl(:,3)=0; % the offset
datafinal.cfg.trl(:,4)=datafinal.trialinfo(:,1);

cfg.cond=100;
con100=splitconds(cfg,datafinal);
cfg.cond=110;
con110=splitconds(cfg,datafinal);
cfg.cond=120;
con120=splitconds(cfg,datafinal);
cfg.cond=130;
con130=splitconds(cfg,datafinal);
cfg.cond=140;
con140=splitconds(cfg,datafinal);

mkdir('PLI');
cd PLI
save splitconds con100 con110 con120 con130 con140

%% perform spectral analysis using fft
for i=[7:22 25:28]
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/PLI']);
    load splitconds
    
    cfg            = [];
    cfg.output     = 'pow';
    cfg.method     = 'mtmfft';
    cfg.taper      = 'hanning';
    cfg.foilim     = [1 100]; % all frequencies
    cfg.tapsmofrq  = 1;
    cfg.keeptrials = 'no';
    cfg.channel    = {'MEG','-A41'};
    
    spectRest =ft_freqanalysis(cfg,con100);
    spectEnter =ft_freqanalysis(cfg,con110);
    spectHalf =ft_freqanalysis(cfg,con120);
    spectOuter =ft_freqanalysis(cfg,con130);
    spectExit =ft_freqanalysis(cfg,con140);
    
    save powSpect spectRest spectEnter spectExit spectHalf spectOuter
    
    % ploting
    figure;
    plot(mean(spectRest.powspctrm));
    hold on;
    plot(mean(spectEnter.powspctrm),'r');
    plot(mean(spectHalf.powspctrm),'g');
    plot(mean(spectOuter.powspctrm),'k');
    plot(mean(spectExit.powspctrm),'m');
    set(gca, 'XScale', 'log');
    legend rest enter halfBody outOfBudy exit;
    clear all
end

%% averaging the power-spectrum
clear all
for i=[7:22, 25:28]
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/PLI']);
    load powSpect
    eval(['spectEnterHyp',num2str(i),'=spectEnter;']);
    eval(['spectExitHyp',num2str(i),'=spectExit;']);
    eval(['spectHalfHyp',num2str(i),'=spectHalf;']);
    eval(['spectOuterHyp',num2str(i),'=spectOuter;']);
    eval(['spectRestHyp',num2str(i),'=spectRest;']);
    eval(['save powSpect spectEnterHyp',num2str(i),' spectExitHyp',num2str(i),' spectHalfHyp',num2str(i),' spectOuterHyp',num2str(i),' spectRestHyp',num2str(i)]);
    clear all
end;

clear all
for i=[7:22, 25:28]
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/PLI']);
    load powSpect
end

n=20; % number of subs
spectEnterAvg=spectEnterHyp10;
spectEnterAvg.powspctrm=(spectEnterHyp7.powspctrm+spectEnterHyp8.powspctrm+spectEnterHyp9.powspctrm+spectEnterHyp10.powspctrm+...
    spectEnterHyp11.powspctrm+spectEnterHyp12.powspctrm+spectEnterHyp13.powspctrm+spectEnterHyp14.powspctrm+spectEnterHyp15.powspctrm+...
    spectEnterHyp16.powspctrm+spectEnterHyp17.powspctrm+spectEnterHyp18.powspctrm+spectEnterHyp19.powspctrm+spectEnterHyp20.powspctrm+...
    spectEnterHyp21.powspctrm+spectEnterHyp22.powspctrm+spectEnterHyp25.powspctrm+spectEnterHyp26.powspctrm+spectEnterHyp27.powspctrm+...
    spectEnterHyp28.powspctrm)./n;

spectExitAvg=spectExitHyp10;
spectExitAvg.powspctrm=(spectExitHyp7.powspctrm+spectExitHyp8.powspctrm+spectExitHyp9.powspctrm+spectExitHyp10.powspctrm+...
    spectExitHyp11.powspctrm+spectExitHyp12.powspctrm+spectExitHyp13.powspctrm+spectExitHyp14.powspctrm+spectExitHyp15.powspctrm+...
    spectExitHyp16.powspctrm+spectExitHyp17.powspctrm+spectExitHyp18.powspctrm+spectExitHyp19.powspctrm+spectExitHyp20.powspctrm+...
    spectExitHyp21.powspctrm+spectExitHyp22.powspctrm+spectExitHyp25.powspctrm+spectExitHyp26.powspctrm+spectExitHyp27.powspctrm+...
    spectExitHyp28.powspctrm)./n;

spectHalfAvg=spectHalfHyp10;
spectHalfAvg.powspctrm=(spectHalfHyp7.powspctrm+spectHalfHyp8.powspctrm+spectHalfHyp9.powspctrm+spectHalfHyp10.powspctrm+...
    spectHalfHyp11.powspctrm+spectHalfHyp12.powspctrm+spectHalfHyp13.powspctrm+spectHalfHyp14.powspctrm+spectHalfHyp15.powspctrm+...
    spectHalfHyp16.powspctrm+spectHalfHyp17.powspctrm+spectHalfHyp18.powspctrm+spectHalfHyp19.powspctrm+spectHalfHyp20.powspctrm+...
    spectHalfHyp21.powspctrm+spectHalfHyp22.powspctrm+spectHalfHyp25.powspctrm+spectHalfHyp26.powspctrm+spectHalfHyp27.powspctrm+...
    spectHalfHyp28.powspctrm)./n;

spectOuterAvg=spectOuterHyp10;
spectOuterAvg.powspctrm=(spectOuterHyp7.powspctrm+spectOuterHyp8.powspctrm+spectOuterHyp9.powspctrm+spectOuterHyp10.powspctrm+...
    spectOuterHyp11.powspctrm+spectOuterHyp12.powspctrm+spectOuterHyp13.powspctrm+spectOuterHyp14.powspctrm+spectOuterHyp15.powspctrm+...
    spectOuterHyp16.powspctrm+spectOuterHyp17.powspctrm+spectOuterHyp18.powspctrm+spectOuterHyp19.powspctrm+spectOuterHyp20.powspctrm+...
    spectOuterHyp21.powspctrm+spectOuterHyp22.powspctrm+spectOuterHyp25.powspctrm+spectOuterHyp26.powspctrm+spectOuterHyp27.powspctrm+...
    spectOuterHyp28.powspctrm)./n;

spectRestAvg=spectRestHyp10;
spectRestAvg.powspctrm=(spectRestHyp7.powspctrm+spectRestHyp8.powspctrm+spectRestHyp9.powspctrm+spectRestHyp10.powspctrm+...
    spectRestHyp11.powspctrm+spectRestHyp12.powspctrm+spectRestHyp13.powspctrm+spectRestHyp14.powspctrm+spectRestHyp15.powspctrm+...
    spectRestHyp16.powspctrm+spectRestHyp17.powspctrm+spectRestHyp18.powspctrm+spectRestHyp19.powspctrm+spectRestHyp20.powspctrm+...
    spectRestHyp21.powspctrm+spectRestHyp22.powspctrm+spectRestHyp25.powspctrm+spectRestHyp26.powspctrm+spectRestHyp27.powspctrm+...
    spectRestHyp28.powspctrm)./n;

figure;
plot(mean(spectRestAvg.powspctrm));
hold on;
plot(mean(spectEnterAvg.powspctrm),'r');
plot(mean(spectHalfAvg.powspctrm),'g');
plot(mean(spectOuterAvg.powspctrm),'k');
plot(mean(spectExitAvg.powspctrm),'m');
set(gca, 'XScale', 'log');
ylim([0 6*10^(-27)]);
legend rest enter halfBody outOfBudy exit;

% without bad subs (8, 19, 20, 22, 28)
n=15; % number of subs
spectEnterAvgClean=spectEnterHyp10;
spectEnterAvgClean.powspctrm=(spectEnterHyp7.powspctrm+spectEnterHyp9.powspctrm+spectEnterHyp10.powspctrm+...
    spectEnterHyp11.powspctrm+spectEnterHyp12.powspctrm+spectEnterHyp13.powspctrm+spectEnterHyp14.powspctrm+spectEnterHyp15.powspctrm+...
    spectEnterHyp16.powspctrm+spectEnterHyp17.powspctrm+spectEnterHyp18.powspctrm+...
    spectEnterHyp21.powspctrm+spectEnterHyp25.powspctrm+spectEnterHyp26.powspctrm+spectEnterHyp27.powspctrm)./n;

spectExitAvgClean=spectExitHyp10;
spectExitAvgClean.powspctrm=(spectExitHyp7.powspctrm+spectExitHyp9.powspctrm+spectExitHyp10.powspctrm+...
    spectExitHyp11.powspctrm+spectExitHyp12.powspctrm+spectExitHyp13.powspctrm+spectExitHyp14.powspctrm+spectExitHyp15.powspctrm+...
    spectExitHyp16.powspctrm+spectExitHyp17.powspctrm+spectExitHyp18.powspctrm+...
    spectExitHyp21.powspctrm+spectExitHyp25.powspctrm+spectExitHyp26.powspctrm+spectExitHyp27.powspctrm)./n;

spectHalfAvgClean=spectHalfHyp10;
spectHalfAvgClean.powspctrm=(spectHalfHyp7.powspctrm+spectHalfHyp9.powspctrm+spectHalfHyp10.powspctrm+...
    spectHalfHyp11.powspctrm+spectHalfHyp12.powspctrm+spectHalfHyp13.powspctrm+spectHalfHyp14.powspctrm+spectHalfHyp15.powspctrm+...
    spectHalfHyp16.powspctrm+spectHalfHyp17.powspctrm+spectHalfHyp18.powspctrm+...
    spectHalfHyp21.powspctrm+spectHalfHyp25.powspctrm+spectHalfHyp26.powspctrm+spectHalfHyp27.powspctrm)./n;

spectOuterAvgClean=spectOuterHyp10;
spectOuterAvgClean.powspctrm=(spectOuterHyp7.powspctrm+spectOuterHyp9.powspctrm+spectOuterHyp10.powspctrm+...
    spectOuterHyp11.powspctrm+spectOuterHyp12.powspctrm+spectOuterHyp13.powspctrm+spectOuterHyp14.powspctrm+spectOuterHyp15.powspctrm+...
    spectOuterHyp16.powspctrm+spectOuterHyp17.powspctrm+spectOuterHyp18.powspctrm+...
    spectOuterHyp21.powspctrm+spectOuterHyp25.powspctrm+spectOuterHyp26.powspctrm+spectOuterHyp27.powspctrm)./n;

spectRestAvgClean=spectRestHyp10;
spectRestAvgClean.powspctrm=(spectRestHyp7.powspctrm+spectRestHyp9.powspctrm+spectRestHyp10.powspctrm+...
    spectRestHyp11.powspctrm+spectRestHyp12.powspctrm+spectRestHyp13.powspctrm+spectRestHyp14.powspctrm+spectRestHyp15.powspctrm+...
    spectRestHyp16.powspctrm+spectRestHyp17.powspctrm+spectRestHyp18.powspctrm+...
    spectRestHyp21.powspctrm+spectRestHyp25.powspctrm+spectRestHyp26.powspctrm+spectRestHyp27.powspctrm)./n;

figure;
plot(mean(spectRestAvgClean.powspctrm));
hold on;
plot(mean(spectEnterAvgClean.powspctrm),'r');
plot(mean(spectHalfAvgClean.powspctrm),'g');
plot(mean(spectOuterAvgClean.powspctrm),'k');
plot(mean(spectExitAvgClean.powspctrm),'m');
set(gca, 'XScale', 'log');
ylim([0 6*10^(-27)]);
legend rest enter halfBody outOfBudy exit;
% based on this plot I found that the interesting frequency window is
% 8-13Hz. I'll extract the maximum power of each condition for each subject

% averaging the channels
for j=[7:22, 25:28] % only good subs
    eval(['spectEnterHyp',num2str(j),'Avg=mean(spectEnterHyp',num2str(j),'.powspctrm);'])
    eval(['spectExitHyp',num2str(j),'Avg=mean(spectExitHyp',num2str(j),'.powspctrm);'])
    eval(['spectHalfHyp',num2str(j),'Avg=mean(spectHalfHyp',num2str(j),'.powspctrm);'])
    eval(['spectOuterHyp',num2str(j),'Avg=mean(spectOuterHyp',num2str(j),'.powspctrm);'])
    eval(['spectRestHyp',num2str(j),'Avg=mean(spectRestHyp',num2str(j),'.powspctrm);'])
    eval(['clear spectRestHyp',num2str(j),' spectOuterHyp',num2str(j),' spectHalfHyp',num2str(j),' spectExitHyp',num2str(j),' spectEnterHyp',num2str(j)]);
end

% extracting the maximum power from the frequency window of interest
a=1;
maxAlpha=zeros(20,5);
for j=[7:22, 25:28]
    eval(['maxAlpha(a,1)=max(spectRestHyp',num2str(j),'Avg(15:25));']);
    eval(['maxAlpha(a,2)=max(spectEnterHyp',num2str(j),'Avg(15:25));']);
    eval(['maxAlpha(a,3)=max(spectHalfHyp',num2str(j),'Avg(15:25));']);
    eval(['maxAlpha(a,4)=max(spectOuterHyp',num2str(j),'Avg(15:25));']);
    eval(['maxAlpha(a,5)=max(spectExitHyp',num2str(j),'Avg(15:25));']);
    a=a+1;
end

maxAlpha=maxAlpha*10^27;
cd /home/meg/Data/Maor/Hypnosis
save maxAlpha maxAlpha

maxAlphaClean = maxAlpha([1,3:12,15,17:19],[1:5]);

h=barwitherr(std(maxAlphaClean)./sqrt(15),mean(maxAlphaClean));
title('Alpha Maximum Power Spectrum (n=15)');
ylim([0 9]);
ylabel('Power*10^27');
set(h(1), 'facecolor', [1 1 1]);
set(gca, 'XTickLabel', {'Rest','Enter','Half','Outer','Exit'});
% saved the plot as AlphaPowerSpctrm.tif

pANOVA=anova1(maxAlphaClean);
[h p ch stat]=ttest(maxAlphaClean(:,1),maxAlphaClean(:,3))


%% ---------------------------- 8< -------------------------------------
%
% *************** PLI ****************
%
%%
% SAMerf
% -------------------------------------------------------------------------
%% 1. creating marker files for all subs (do it once!)
% subs with Ind MRI 7:15, 17, 19, 21, 25:28 (Nolte Model)
% subs without Ind MRI 16, 18, 20, 22 (MultiSphere Model)
clear all
for i = [7:22 25:28]
    eval(['cd /home/meg/Data/Maor/Hypnosis/HypData4PLI/',num2str(i),'']);
    load splitconds
    eval(['all = ((con100.sampleinfo(:,1))./1017.25)'';']);
    for j = 100:10:140
        eval(['con',num2str(j),'=((con',num2str(j),'.sampleinfo(con',num2str(j),'.trialinfo == ',num2str(j),',1))./1017.25)'';']);
    end
    Trig2mark('all',all,'rest',con100,'induce',con110,'half',con120,'outer',con130,'exit',con140);
    clear all ans con100 con110 con120 con130 con140 j
end;

clear all

%% 2. creating param file (do it once!!)
cd /home/meg/Data/Maor/Hypnosis/HypData4PLI
createPARAM('all4cov','ERF','all',[0.05 2],'all',[0 0.1],[8 12],[0 2]);
% -------------------------------------------------------------------------
%% 2. fit individual MRI to HS
% 2.1 open terminal and cd to the MRI files of the subject

% 2.2 type: "to3d ___*" (where ___ is the prefix of the MRI slices names)

% 2.3 in the window that automaticly opens write the folder path of the main folder of the subject (starting: "/home/meg/...") at the
% buttom and the output file name - "anat". save and close

% 2.4 tagalign:
% 2.4.1 copy into the sub folder the file MNI305.tag and change the name of
% the file to the "subsname".tag
% 2.4.2 Now we type afni in the terminal window. Choose 'underlay' as anat file
% Press: 'Define data mode' => 'plugin' => 'edit tagset' => 'dataset' => 'anat'
% Write in 'tag file' the "subsname".tag, and press 'read' button
% click on Nasion, mark the location on the MRI and press 'set'. repeat for
% LP and RP.
% When done with all three click on 'write' (it will write the new
% locations to the subname.tag file, then click on 'save' (it will save
% these locations in the anat file, and finally click on 'done' to finish.
% 2.4.3 now from MATLAB run the commend:
!/home/meg/abin/3dTagalign -master /home/meg/brainhull/master+orig -prefix ./ortho anat+orig
% The last stage aligned the fiducial points you just marked on the MRI with 
% the fiducial points marked doing digitization
% The function's output are ortho+orig HEAD and BRIK files – these will be later used for nudgnig

% if using template MRI start here:
fitMRI2hs('c,rfhp0.1Hz') % don't use if have individual MRI

% 2.4.4 in MATLAB run:
hs2afni() % creating HS+orig files

% 2.5 Nudging:
% ------------
% 2.5.1 from the terminal open afni and define: overlay = hs, underlay = ortho
% 2.5.2 go to Define datamode > plugins > nudge dataset
% 2.5.3 click on "choose dataset" and choose "ortho"
% 2.5.4 now nudge. Chhose ortho as dataset and when you are done type "do
% all" and then quit.

% 2.6 creating hull file:
!~/abin/3dSkullStrip -input ortho+orig -prefix mask -mask_vol -skulls -o_ply ortho
% 2.6.1 if using template MRI:
!~/abin/3dSkullStrip -input warped+orig -prefix mask -mask_vol -skulls -o_ply ortho

% if massive chunks missing consider adding one of these options:
% before 3dSkullStrip run the next line:
% !~/abin/3dUnifize -prefix ortho_unshaded ortho+orig
% and then:
% !~/abin/3dSkullStrip -input ortho_unshaded+orig -prefix mask -mask_vol -skulls -o_ply ortho -blur_fwhm 2
% or together with 3dSkullStrip run:
% -ld 30
% or
% -blur_fwhm 2 % play with the number (up and down)
% or
% -blur_fwhm 2 -avoid_vent -avoid_vent -init_radius 75

% 2.7 in the terminal type: "afni -niml -dset ortho+orig mask+orig &"
% 2.7.1 define: overlay = mask, underlay = ortho
% 2.7.2 in the terminal type: "suma -niml -i_ply ortho_brainhull.ply -sv ortho+orig -novolreg"
% 2.7.3 go to the suma window and click on "t". Check that there is a good fit

% 2.8 creating the final hull.shape file (only for the Nolte model):
!meshnorm ortho_brainhull.ply > hull.shape
%% -------------------------------------------------------------------------
% 4. SAMcov,wts,erf
% you need to move the config, rtw and the xc,hb,lf_c,rfhp0.1Hz files into
% the sub PLI folder
% if I want the SAM to ignore a channel I need to have a text doc in the
% sub folder named BadChans contains:
% first raw - number of bad channels
% second raw - bad channels names
% channel A41 is at index 216!!!!!!!!
cd /home/meg/Data/Maor/Hypnosis/HypData4PLI
!SAMcov64 -r 7 -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -v
!SAMwts64 -r 7 -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -c alla -v
% "alla" and not "all" because it adds and 'a' to the file name for some reason
% you can delete from the sub folder the xc,hb,lf_c,rfhp0.1Hz file now

%% --------- PLI ------------
clear all
cd /home/meg/Data/Maor/Hypnosis/HypData4PLI/7
load splitconds
[regStruct, PLIstruct]  = pliBIUfuncVer4('-dataRoot', '/home/meg/Data/Maor/Hypnosis/HypData4PLI', ...
    '-subNum', 7, ...
    '-condName', 'REST', ...
    '-freq', [8 12], ...
    '-wtsFile', '/home/meg/Data/Maor/Hypnosis/HypData4PLI/7/SAM/all4cov,8-12Hz,alla', ...
    '-FTdata', con100, ...
    '-maskPath', '/home/meg/Data/Maor/PLI/Masks/maskCortex')