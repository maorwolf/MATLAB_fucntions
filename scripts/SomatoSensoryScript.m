%% Somato Sensory Script for Hypnosis Experiment
%-----------------------------------------------
%% 1. cleaning heart beats, 50Hz and more using Abeles and Tal's script
clear all
fileName = 'c,rfhp0.1Hz';
p=pdf4D(fileName);% transfer data into matlab compatable data
cleanCoefs = createCleanFile(p, fileName,...
    'byLF',[] ,'Method','Adaptive',...
    'xClean',[4 5 6],...
    'chans2ignore',[],...
    'byFFT',0,...
    'HeartBeat',[],... % use [] for automatic HB cleaning, use 0 to avoid HB cleaning
    'maskTrigBits', 512);

% checking that the cleaning worked as required %% Roy dont run this
% section.
pdf=pdf4D('c,rfhp0.1Hz'); 
pdf_new=pdf4D('xc,hb,lf_c,rfhp0.1Hz'); %change
data1 = read_data_block(pdf,[1 10173],13); %drop chi
data2 = read_data_block(pdf_new,[1 10173],13); %drop chi

[data1PSD, freq] = allSpectra(data1,1017.25,1,'FFT');
[data2PSD, freq] = allSpectra(data2,1017.25,1,'FFT');
figure;plot (freq(1,1:120),data1PSD(1,1:120),'r')
hold on;
plot (freq(1,1:120),data2PSD(1,1:120),'b')
xlabel ('Frequency Hz');
ylabel('SQRT(PSD), T/sqrt(Hz)');

%% 2. find Bad Channels
source='xc,hb,lf_c,rfhp0.1Hz';
findBadChans(source);
%original_source='c,rfhp0.1Hz';% we added this line to compare between the data before and after cleaning with the Abeles fucntion
%findBadChans(original_source);

channels = {'MEG'}; % channels = {'MEG', '-A41'};% Roy - run this first.
%% 3. finding trial
sub=10; % change to sub number
condition_vector=[102 104 106 108];
% 102 - pre right
% 104 - pre left
% 106 - post right
% 108 - post left

cfg = [];
cfg.dataset=source;%check name of the abeles function output
cfg.trialdef.eventtype='TRIGGER';
cfg.trialdef.eventvalue=condition_vector;  %triggers are for different kinds of metaphors 
cfg.trialdef.prestim=0.15; % time before trigger onset
cfg.trialdef.poststim=0.5; % time after trigger onset
cfg.trialdef.offset=-0.15; % defining the real zero: can be different than prestim
cfg.trialfun='BIUtrialfun'; % use the unique parameters of the Bar Ilan MEG
cfg=ft_definetrial(cfg);

%% 4. preprocessing for muscle artifact rejection
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-0.15,0];
cfg.hpfilter='yes';
cfg.hpfreq=60;
cfg.channel = channels; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
cfg.padding = 10;
dataorig=ft_preprocessing(cfg);

%% 5. remove muscle artifact
cfg1.method='summary'; %trial
datacln=ft_rejectvisual(cfg1, dataorig);

% to see again
datacln=ft_rejectvisual(cfg1, datacln);

%% 5.1 Deleting the bad trials from the original data so you don't refilter the data
cfg.trl = [];
cfg.trl = datacln.sampleinfo;
cfg.trl(:,3) = -153; % change according to your offset in samples!!!
cfg.trl(:,[4:6]) = datacln.trialinfo;

%% 5.1.1 preprocessing original data
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-0.15,0];
cfg.hpfilter='no';
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[1 40];
cfg.channel = channels; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
cfg.padding = 10;
dataorig=ft_preprocessing(cfg);

%% 6. ICA
%resampling data to speed up the ica
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy           = ft_resampledata(cfg, dataorig); % if you used 5.2 so change to datacln

% run ica (it takes a long time have a break)
cfg            = [];
cfg.channel    = channels;
comp_dummy     = componentanalysis(cfg, dummy);

% see the components and find the artifacts
cfgb=[];
cfgb.layout='4D248.lay';
cfgb.channel = {comp_dummy.label{1:10}};
cfgb.continuous='no';
comppic=ft_databrowser(cfgb,comp_dummy);

%% cool visualization for one component (e.g.,comp = 3) along trials and time (after resampling)  
seeOneComp(comp_dummy)% change the number of components you want to see

%% run the ICA on the original data
cfg = [];
cfg.topo      = comp_dummy.topo;
cfg.topolabel = comp_dummy.topolabel;
comp     = ft_componentanalysis(cfg, dataorig);

% remove the artifact components
cfg = [];
cfg.component = [ 1 4 6  ]; % enter the components numbers that you want to clean
dataica = ft_rejectcomponent(cfg, comp);

clear comp_dummy comppic comp dummy
%% 7. base line correction
dataica=correctBL(dataica,[-0.15 0]);

%% 8. trial by trial
cfg=[];
cfg.method='trial'; % 'channel'
cfg.channel=channels;
cfg1.bpfilter='yes';
cfg1.bpfreq=[1 40];
datafinal=ft_rejectvisual(cfg, dataica);

% 8.1
cfg.method='summary'; % 'channel'
datafinal=ft_rejectvisual(cfg, datafinal);
%% 9. recreating the trl matrix
datafinal.cfg.trl(:,1:2)=datafinal.sampleinfo(:,1:2);
datafinal.cfg.trl(:,3)=-153; % the offset
datafinal.cfg.trl(:,4:6)=datafinal.trialinfo(:,1:3);

%% if channel A41 was removed (if and only if!!!!!!)
datafinal = interpolateA41(datafinal)
%% 10. split conditions
cfg=[];
cfg.cond=102; % literal
eval(['sub',num2str(sub),'con102=splitconds(cfg,datafinal);']);
cfg.cond=104; 
eval(['sub',num2str(sub),'con104=splitconds(cfg,datafinal);']);
cfg.cond=106; 
eval(['sub',num2str(sub),'con106=splitconds(cfg,datafinal);']);
cfg.cond=108; 
eval(['sub',num2str(sub),'con108=splitconds(cfg,datafinal);']);

% for combining two or more datasets use: 
% cfg=[]; newName=ft_appenddata(cfg, data1, data2,...);
mkdir('1_40Hz');
eval(['save 1_40Hz/sub',num2str(sub),'datafinalsplit sub',num2str(sub),'con102 sub',num2str(sub),'con104 sub',num2str(sub),'con106 sub',num2str(sub),'con108']);

%% 11. averaging
for index=condition_vector
    eval(['sub',num2str(sub),'con',num2str(index),'=ft_timelockanalysis([],sub',num2str(sub),'con',num2str(index),');']);
end
eval(['sub',num2str(sub),'average=ft_timelockanalysis([], datafinal);']);

eval(['save 1_40Hz/averagedata sub',num2str(sub),'con',num2str(condition_vector(1)),' sub',num2str(sub),'con',num2str(condition_vector(2)),' sub',num2str(sub),'con',num2str(condition_vector(3)),' sub',num2str(sub),'con',num2str(condition_vector(4)),' sub',num2str(sub),'average;']);
clear all;
load 1_40Hz/averagedata
%%
%   -----------------------------------     %
%   ------- Cleaning is Done ----------     %
%   -----------------------------------     %
%% 12. Plots
sub=9; % change sub number
% Butterfly
figure;
eval(['plot(sub',num2str(sub),'average.time, sub',num2str(sub),'average.avg,''b'')']);
hold on;
axis tight;
yLimits = get(gca,'YLim');
plot([0 0],[yLimits(1) yLimits(2)],'k');
plot([-1 1],[0 0],'k');
grid on;



figure;
subplot(2,1,1)
eval(['plot(sub',num2str(sub),'con104.time, sub',num2str(sub),'con104.avg,''b'')']);
hold on;
eval(['plot(sub',num2str(sub),'con108.time, sub',num2str(sub),'con108.avg,''r'')']);
axis tight;
yLimits = get(gca,'YLim');
plot([0 0],[yLimits(1) yLimits(2)],'k');
plot([-1 1],[0 0],'k');
text(-0.025,-2.05*10^(-13),'stimulus onset');
xlabel('time in ms');
ylabel('amplitude');
title('blue - pre left, red - post left');
grid on;

subplot(2,1,2)
eval(['plot(sub',num2str(sub),'con102.time, sub',num2str(sub),'con102.avg,''b'')']);
hold on;
eval(['plot(sub',num2str(sub),'con106.time, sub',num2str(sub),'con106.avg,''r'')']);
axis tight;
yLimits = get(gca,'YLim');
plot([0 0],[yLimits(1) yLimits(2)],'k');
plot([-1 1],[0 0],'k');
text(-0.025,-2.05*10^(-13),'stimulus onset');
xlabel('time in ms');
ylabel('amplitude');
title('blue - pre right, red - post right');
grid on;


% topoplot
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[0:0.05:0.5]; % from 300ms to 600ms in 10ms interval
% cfg.zlim=[-9*10^(-14) 2*10^(-13)];
cfg.colorbar='no'; % change to 'no' in order to avoid the annoying colorbar that squeeze the plot
% cfg.comment='no'; % to ommit the text from the plot
eval(['ft_topoplotER(cfg,sub',num2str(sub),'average);']);


cfg=[];
cfg.interactive='yes';
cfg.layout='4D248.lay';
cfg.channel='MEG';
cfg.showlabels='yes';
title('blue - right finger post; red - left finger post');
eval(['ft_multiplotER(cfg,sub',num2str(sub),'con106, sub',num2str(sub),'con108);']);


%% ---- THE END ----- (for Roy)














% mesh and imagesc
eval(['figure; mesh(sub',num2str(sub),'con104.avg)']);
eval(['figure; mesh(sub',num2str(sub),'con108.avg)']);

figure;
subplot(1,2,1)
eval(['imagesc(sub',num2str(sub),'con104.avg)']);
title('pre left')
subplot(1,2,2)
eval(['imagesc(sub',num2str(sub),'con108.avg)']);
title('post left')

%% corelation between left pre and post
corr=[];
eval(['con104mean=mean(sub',num2str(sub),'con104.avg,1);']);
eval(['con108mean=mean(sub',num2str(sub),'con108.avg,1);']);
corr=[con104mean' con108mean'];
[LeftPrePostR,LeftPrePostP]=corrcoef(corr);

corr=[];
eval(['l=size(sub',num2str(sub),'con104.avg,1)']);
for i=1:l
    for j=1:l
       eval(['a1=sub',num2str(sub),'con104.avg(i,:);']);
       eval(['a2=sub',num2str(sub),'con108.avg(j,:);']);
       corr=[a1' a2'];
       [R,P]=corrcoef(corr);
       ChanCorrLeftPrePostR(i,j)=R(1,2);
       ChanCorrLeftPrePostP(i,j)=P(1,2);
    end;
    disp(i)
end;
imagesc(ChanCorrLeftPrePostR);


% singleplot
figure;
eval(['ft_singleplotER([], sub',num2str(sub),'con104, sub',num2str(sub),'con108);']);
title('blue - Pre Left         red - Post Left');

% Interactive
cfg=[];
cfg.interactive='yes';
cfg.layout='4D248.lay';
cfg.channel='MEG';
cfg.showlabels='yes';
eval(['ft_multiplotER(cfg,sub',num2str(sub),'con104, sub',num2str(sub),'con108);']);

figure;
eval(['ft_multiplotER(cfg,sub',num2str(sub),'con102, sub',num2str(sub),'con106);']);

% topoplot
cfg=[];
subplot(2,1,1);
cfg.layout='4D248.lay';
cfg.xlim=[0.00:0.05:0.3]; % from 300ms to 600ms in 10ms interval
% cfg.zlim=[-9*10^(-14) 2*10^(-13)];
cfg.colorbar='no'; % change to 'no' in order to avoid the annoying colorbar that squeeze the plot
% cfg.comment='no'; % to ommit the text from the plot
eval(['ft_topoplotER(cfg,sub',num2str(sub),'con104);']);
subplot(2,1,2);
eval(['ft_topoplotER(cfg,sub',num2str(sub),'con108);']);

%% --------------------------------------------------------------------------------------------------------------------------
% grand averaging
clear all
subs=[7:12,14:19,21,25:28]; % total = 17 subs
for i=subs
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/averagedata']);
end;

cfg=[];
cfg.keepindividual = 'yes';
gravg=ft_timelockgrandaverage(cfg,sub7average, sub8average, sub9average, sub10average,...
    sub11average, sub12average, sub14average, sub15average, sub16average, sub17average,...
    sub18average, sub19average, sub21average, sub25average, sub26average, sub27average, sub28average);
clear sub7average sub8average sub9average sub10average sub11average sub12average...
sub14average sub15average sub16average sub17average sub18average sub19average...
sub21average sub25average sub26average sub27average sub28average

gravg102=ft_timelockgrandaverage(cfg,sub7con102, sub8con102, sub9con102, sub10con102,...
    sub11con102, sub12con102, sub14con102, sub15con102, sub16con102, sub17con102, sub18con102,...
    sub19con102, sub21con102, sub25con102, sub26con102, sub27con102, sub28con102);
clear sub7con102 sub8con102 sub9con102 sub10con102 sub11con102 sub12con102 sub14con102...
sub15con102 sub16con102 sub17con102 sub18con102 sub19con102 sub21con102 sub25con102 sub26con102...
sub27con102 sub28con102

gravg104=ft_timelockgrandaverage(cfg,sub7con104, sub8con104, sub9con104, sub10con104,...
    sub11con104, sub12con104, sub14con104, sub15con104, sub16con104, sub17con104, sub18con104,...
    sub19con104, sub21con104, sub25con104, sub26con104, sub27con104, sub28con104);
clear sub7con104 sub8con104 sub9con104 sub10con104 sub11con104 sub12con104 sub14con104...
sub15con104 sub16con104 sub17con104 sub18con104 sub19con104 sub21con104 sub25con104 sub26con104...
sub27con104 sub28con104

gravg106=ft_timelockgrandaverage(cfg,sub7con106, sub8con106, sub9con106, sub10con106,...
    sub11con106, sub12con106, sub14con106, sub15con106, sub16con106, sub17con106, sub18con106,...
    sub19con106, sub21con106, sub25con106, sub26con106, sub27con106, sub28con106);
clear sub7con106 sub8con106 sub9con106 sub10con106 sub11con106 sub12con106 sub14con106...
sub15con106 sub16con106 sub17con106 sub18con106 sub19con106 sub21con106 sub25con106 sub26con106...
sub27con106 sub28con106

gravg108=ft_timelockgrandaverage(cfg,sub7con108, sub8con108, sub9con108, sub10con108,...
    sub11con108, sub12con108, sub14con108, sub15con108, sub16con108, sub17con108, sub18con108,...
    sub19con108, sub21con108, sub25con108, sub26con108, sub27con108, sub28con108);
clear sub7con108 sub8con108 sub9con108 sub10con108 sub11con108 sub12con108 sub14con108...
sub15con108 sub16con108 sub17con108 sub18con108 sub19con108 sub21con108 sub25con108 sub26con108...
sub27con108 sub28con108

save gravgs gravg gravg102 gravg104 gravg106 gravg108
%% plot
cfg=[];
cfg.interactive='yes';
cfg.layout='4D248.lay';
ft_multiplotER(cfg,gravg102,gravg104,gravg106,gravg108);

% Butterfly
cfg=[];
figure
plot(gravg104.time,gravg104.avg,'b')
grid;
hold on
plot(gravg104.time,gravg108.avg,'r')
title('Left Pre (blue) and Left Post (red)');
figure
plot(gravg104.time,gravg102.avg,'b')
grid;
hold on
plot(gravg104.time,gravg106.avg,'r')
title('Right Pre (blue) and Right Post (red)');

%% topoplot
% right index
figure
subplot(2,2,1)
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[0.118 0.157]; % from 300ms to 600ms in 10ms interval
cfg.zlim=[-6*10^(-14) 7*10^(-14)];
cfg.interactive = 'yes';
cfg.colorbar='yes'; % change to 'no' in order to avoid the annoying colorbar that squeeze the plot
%cfg.comment='no'; % to ommit the text from the plot
ft_topoplotER(cfg,gravg102);
subplot(2,2,2)
ft_topoplotER(cfg,gravg106);
cfg.xlim=[0.157 0.187];
subplot(2,2,3)
ft_topoplotER(cfg,gravg102);
subplot(2,2,4)
ft_topoplotER(cfg,gravg106);

% left index
figure
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[0.27 0.59]; % from 300ms to 600ms in 10ms interval
cfg.ylim=[4.88 8.84];
%cfg.zlim=[0 12*10^(-27)];
%cfg.interactive = 'yes';
cfg.colorbar='yes'; % change to 'no' in order to avoid the annoying colorbar that squeezes the plot
cfg.comment='no'; % to ommit the text from the plot
subplot(2,1,1)
ft_topoplotTFR(cfg,TF102lgavg);
subplot(2,1,2)
ft_topoplotTFR(cfg,TF106lgavg);
figure;
subplot(2,1,1)
ft_topoplotTFR(cfg,TF104lgavg);
subplot(2,1,2)
ft_topoplotTFR(cfg,TF108lgavg);

%% RMS Analysis
load allSubs

a = 1;
for i = [7:12, 14:19, 21, 25:28]
    eval(['chansL = ismember(sub',num2str(i),'con102.label, LRpairs(:,1));']) % sum = 114 (because I deleted chan A41
    eval(['chansR = ismember(sub',num2str(i),'con102.label, LRpairs(:,2));']) % sum = 115
    for j = [102:2:108]
        eval(['sub',num2str(i),'RMScon',num2str(j),'=sqrt(mean(sub',num2str(i),'con',num2str(j),'.avg.^2));']);
        eval(['sub',num2str(i),'RMScon',num2str(j),'=sub',num2str(i),'RMScon',num2str(j),'-mean(sub',num2str(i),'RMScon',num2str(j),'(1,1:153));']);
        eval(['sub',num2str(i),'conRMS',num2str(j),'L=sqrt(mean(sub',num2str(i),'con',num2str(j),'.avg(chansL,:).^2));']);
        eval(['sub',num2str(i),'conRMS',num2str(j),'L=sub',num2str(i),'conRMS',num2str(j),'L-mean(sub',num2str(i),'conRMS',num2str(j),'L(1,1:153));']);
        eval(['sub',num2str(i),'conRMS',num2str(j),'R=sqrt(mean(sub',num2str(i),'con',num2str(j),'.avg(chansR,:).^2));']);
        eval(['sub',num2str(i),'conRMS',num2str(j),'R=sub',num2str(i),'conRMS',num2str(j),'R-mean(sub',num2str(i),'conRMS',num2str(j),'R(1,1:153));']);
        eval(['con',num2str(j),'RMSL(a,:)=sub',num2str(i),'conRMS',num2str(j),'L;']);
        eval(['con',num2str(j),'RMSR(a,:)=sub',num2str(i),'conRMS',num2str(j),'R;']);  
    end;
    a=a+1;
end;
clear a i j

for j = [102:2:108]
    %eval(['con',num2str(j),'RMSL=con',num2str(j),'RMSL.*(10^14);']);
    %eval(['con',num2str(j),'RMSR=con',num2str(j),'RMSR.*(10^14);']);
    eval(['meanCon',num2str(j),'RMSL=mean(con',num2str(j),'RMSL);']);
    eval(['meanCon',num2str(j),'RMSR=mean(con',num2str(j),'RMSR);']);
end;
clear j

% calculating standart error
for k = [102:2:108]
    eval(['seCon',num2str(k),'RMSL=std(con',num2str(k),'RMSL)/sqrt(17);']);
    eval(['seCon',num2str(k),'RMSR=std(con',num2str(k),'RMSR)/sqrt(17);']);
end;

load time
% plot RMS
figure
subplot(2,1,1)
plot(time,meanCon102RMSL,'b') % LH pre right
hold on;
jbfill(time,meanCon102RMSL+seCon102RMSL,meanCon102RMSL-seCon102RMSL,[0,0,1],[0,0,1],0,0.3)
plot(time,meanCon106RMSL,'r') % LH post right
jbfill(time,meanCon106RMSL+seCon106RMSL,meanCon106RMSL-seCon106RMSL,[1,0,0],[1,0,0],0,0.3)
grid;
subplot(2,1,2)
plot(time,meanCon104RMSR,'b') % RH pre left
hold on;
jbfill(time,meanCon104RMSR+seCon104RMSR,meanCon104RMSR-seCon104RMSR,[0,0,1],[0,0,1],0,0.3)
plot(time,meanCon108RMSR,'r') % RH post left
jbfill(time,meanCon108RMSR+seCon108RMSR,meanCon108RMSR-seCon108RMSR,[1,0,0],[1,0,0],0,0.3)
grid;

figure;
plot(time, meanCon102RMSL - meanCon106RMSL, 'b')
hold on;
plot(time, meanCon104RMSR - meanCon108RMSR, 'r')
grid;

% RMS differences table for the 3 comps: 118-157ms, 157-187ms, 311-500ms
for i = 1:17
leftIndexRchans(i,:)=con104RMSR(i,:)-con108RMSR(i,:);
rightIndexLchans(i,:)=con102RMSL(i,:)-con106RMSL(i,:);
end;
load time

plot(time,mean(leftIndexRchans),'b')
hold on;
plot(time,mean(rightIndexLchans),'r')
grid;

for i = 1:17
    compsLeftIndex(i,1) = mean(leftIndexRchans(i,278:313));
    compsRightIndex(i,1) = mean(rightIndexLchans(i,278:313));
    compsLeftIndex(i,2) = mean(leftIndexRchans(i,321:343));
    compsRightIndex(i,2) = mean(rightIndexLchans(i,321:343));
    compsLeftIndex(i,3) = mean(leftIndexRchans(i,476:662));
    compsRightIndex(i,3) = mean(rightIndexLchans(i,476:662));
    compsLeftIndex(i,4) = mean(leftIndexRchans(i,442:470));
    compsRightIndex(i,4) = mean(rightIndexLchans(i,442:470));
end;

mean(compsLeftIndex(:,1))
mean(compRightIndex(:,1))

comp4 = [];
comp4 = [compsLeftIndex(:,4), compsLeftIndex(:,4)];
[hTtest, pTtest] = ttest(comp4);

comp1vs2 = [];
comp1vs2 = [compsRightIndex(:,[1 2]); compsLeftIndex(:,[1 2])];
RESP = 17;
[pAnova, tableAnova, statAnova] = anova2(comp1vs2,RESP);

[hTtestPostHoc, pTtestPostHoc] = ttest(compsRightIndex(:,[1 2]));
%% cluster analysis
cfg=[];
cfg.method='distance';
cfg.neighbourdist = 0.04;
cfg.layout='4D248.lay';
neighbours = ft_prepare_neighbours(cfg, gravg);

cfg = [];
cfg.channel = {'MEG'};
cfg.latency = [0 0.5];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesF'
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;

cfg.tail = 0;                    % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail = 0;
cfg.alpha = 0.05;               % alpha level of the permutation test
cfg.numrandomization = 500;
% 
r1=1:15;r1=[r1 r1 r1 r1];
r2=ones(1,15);r2=[r2 r2*2 r2*3 r2*4];

design=[squeeze(r1); squeeze(r2)];
cfg.clusterthreshold= 'nonparametric_common';
cfg.design = design;             % design matrix
cfg.ivar  = 2;        
cfg.uvar = 1;
cfg.neighbours=neighbours;
[stat] = ft_timelockstatistics(cfg, gravg102, gravg104, gravg106, gravg108);

save stat0_500 stat

% cluster plot
imagesc(stat.posclusterslabelmat);

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
stat.stat2;
imagesc(stat.stat2);

% plot cluster for each sample time
cfg=[];
cfg.parameter = 'stat';
cfg.alpha=0.05;
cfg.layout = '4D248.lay';
cfg.xlim = [0.032 0.142];
ft_clusterplot(cfg,stat)

% plot clusters that were found according to imagesc
cfg=[];
chans = zeros(246,3);
clusterChans{1} = [16 18 49 51 53 55 56 86 92 155 186 188 190]';
clusterChans{2} = [16 18 49 51 53 55 56 92 155 186 188 190]';
clusterChans{3} = [53 55 155 188]';

clusterTimes = [0.032 0.142; 0.213 0.278; 0.338 0.385];
for i = 1:3
    subplot(1,3,i)
    cfg.xlim=[clusterTimes(i,1) clusterTimes(i,2)];
    cfg.highlight = 'on';
    cfg.highlightchannel = stat.label(clusterChans{i});
    cfg.layout = '4D248.lay';
    ft_topoplotER(cfg, gravg);
end

% and for each condition in each time window
figure;
cfg=[];
for i = 1:4
    subplot(2,2,i)
    cfg.xlim=[0.338 0.385];
    cfg.highlight = 'on';
    cfg.highlightchannel = stat.label(clusterChans{3});
    cfg.layout = '4D248.lay';
    %cfg.colorbar = 'yes';
    cfg.zlim = [-6*10^(-14) 4*10^(-14)];
    eval(['ft_topoplotER(cfg, gravg',num2str(100+i*2),');']);
    eval(['title(''con',num2str(100+i*2),''');']);
end

gravg102Minus106 = gravg;
gravg102Minus106.individual = gravg102.individual - gravg106.individual;

gravg104Minus108 = gravg;
gravg104Minus108.individual = gravg104.individual - gravg108.individual;

figure;
cfg=[];
subplot(1,2,1)
    cfg.xlim=[0.338 0.385];
    cfg.highlight = 'on';
    cfg.highlightchannel = stat.label(clusterChans{1});
    cfg.layout = '4D248.lay';
    %cfg.colorbar = 'yes';
    cfg.zlim = [-2*10^(-14) 3*10^(-14)];
    ft_topoplotER(cfg, gravg102Minus106);
    title('pre right minus post right')
subplot(1,2,2)
    ft_topoplotER(cfg, gravg104Minus108);
    title('pre left minus post left')

% create table for SPSS
cluster4SPSS = zeros(15,24);
chansL = [16 49 51 86 186];
chansR = [18 53 55 56 92 155 188 190];
for i = 1:15
    for j = 1:4
        eval(['cluster4SPSS(i,j) = mean(mean(gravg',num2str(100+j*2),'.individual(i,chansL,157:298)));']);
        eval(['cluster4SPSS(i,j+4) = mean(mean(gravg',num2str(100+j*2),'.individual(i,chansR,157:298)));']); 
        eval(['cluster4SPSS(i,j+8) = mean(mean(gravg',num2str(100+j*2),'.individual(i,chansL,370:437)));']);
        eval(['cluster4SPSS(i,j+12) = mean(mean(gravg',num2str(100+j*2),'.individual(i,chansR,370:437)));']);
        eval(['cluster4SPSS(i,j+16) = mean(mean(gravg',num2str(100+j*2),'.individual(i,chansL,498:546)));']);
        eval(['cluster4SPSS(i,j+20) = mean(mean(gravg',num2str(100+j*2),'.individual(i,chansR,498:546)));']);  
    end;
end;

cluster4SPSS = cluster4SPSS*10^14;