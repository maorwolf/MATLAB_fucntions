%% Prof. Abeles clean files scripts:

clear all
fileName = 'c,rfhp0.1Hz';
p=pdf4D(fileName);% transfer data into matlab compatable data
cleanCoefs = createCleanFile(p, fileName,...
    'byLF',[] ,'Method','Adaptive',...
    'xClean',[4 5 6],...
    'chans2ignore',[],...
    'byFFT',0,...
    'HeartBeat',[],... % use [] for automatic HB cleaning, use 0 to avoid HB cleaning
    'maskTrigBits', 256);

% for jump cleaning add: 'stepCorrect',1
% for forced HB cleaning use the same configoration but with the function:
% "createCleanFile_fhb"

% checking that the cleaning worked as required
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

% If I need to read the trig channel
trig = readTrig_BIU('xc,hb,lf_c,rfhp0.1Hz');
plot(trig)
trigVal = unique(trig);
% if I need to rewrite the trigChann
rewriteTrig('xc,hb,lf_c,rfhp0.1Hz',newTrig,'fix');

%% -------------------- Preprocessing and cleaning ------------------------
clear all
clc
cfg=[];
sub=31;

if sub == 19 || sub == 21
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(sub),'/4'])
else
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(sub),'/2'])
end
source='xc,hb,lf_c,rfhp0.1Hz';

% 1. find Bad Channels
findBadChans(source);
%original_source='c,rfhp0.1Hz';% we added this line to compare between the data before and after cleaning with the Abeles fucntion
%findBadChans(original_source);

channels = {'MEG'};

% 2. finding trials and defining them
conditions = [110 120 130 140 150 160];
cfg.dataset =source; 
cfg.trialdef.eventtype  = 'TRIGGER';
cfg.trialdef.eventvalue = conditions;
cfg.trialdef.prestim    = 1;
cfg.trialdef.poststim   = 1;
cfg.trialdef.offset=-1;
cfg.trialfun='BIUtrialfun';
if sub == 15 || sub == 24 || sub == 25
    cfg = ft_definetrial(cfg);
    cfg.trl(:,[1 2]) = cfg.trl(:,[1 2]) + 48;
else
    cfg.trialdef.visualtrig = 'visafter';
    cfg.trialdef.visualtrigwin = 0.2;
    cfg = ft_definetrial(cfg);
end

% creating colume 7 with correct code
cfg.trl(1:length(cfg.trl),7) = 0;
for i=1:length(cfg.trl)
	if ((cfg.trl(i,4)==110) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==120) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1;
	elseif ((cfg.trl(i,4)==130) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1; 
	elseif ((cfg.trl(i,4)==140) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1; 
    elseif ((cfg.trl(i,4)==150) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1; 
	elseif ((cfg.trl(i,4)==160) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1; 
    end;
end;

% if no visual trigger was recorded:
% cfg.trl(:,[1,2])=cfg.trl(:,[1,2])+48;

% 3. preprocessing for muscle artifact rejection
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-1,-0.7];
cfg.trialdef.prestim    = 1;
cfg.trialdef.poststim   = 1;
cfg.trialdef.offset=-1;
cfg.hpfilter='yes';
cfg.hpfreq=60;
cfg.channel = channels; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorig=ft_preprocessing(cfg);

% 4. remove muscle artifact
cfg1.method='summary'; %trial
datacln=ft_rejectvisual(cfg1, dataorig);

% to see again
datacln=ft_rejectvisual(cfg1, datacln);

% 5 Deleting the bad trials from the original data so you don't refilter the data
cfg.trl = [];
cfg.trl = datacln.sampleinfo;
cfg.trl(:,3) = -1017; % change according to your offset in samples!!!
cfg.trl(:,[4:7]) = datacln.trialinfo;

% 5.1 preprocessing original data without the bad trials
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-1,-0.7];
cfg.trialdef.prestim    = 1;
cfg.trialdef.poststim   = 1;
cfg.trialdef.offset=-1;
cfg.hpfilter='no';
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[1 40];
cfg.channel = channels;
cfg.padding = 10;
dataorig=ft_preprocessing(cfg);

% 6. ICA
%resampling data to speed up the ica
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy           = ft_resampledata(cfg, dataorig); % if you used 5.2 so change to datacln

% run ica (it takes a long time have a break)
cfg            = [];
cfg.channel    = channels;
comp_dummy           = ft_componentanalysis(cfg, dummy);

% see the components and find the artifacts
cfgb=[];
cfgb.layout='4D248.lay';
cfgb.channel = {comp_dummy.label{1:10}};
cfgb.continuous='no';
comppic=ft_databrowser(cfgb,comp_dummy);

% cool visualization for one component (e.g.,comp = 3) along trials and time (after resampling)  
seeOneComp(comp_dummy) % change the number of components you want to see

% use this visualisation for choosing the trials to delete from the
% original data so you won't have to mess with the data by doing ICA

% comp=2; % change according to the component you want to see
% m=zeros(length(comp_dummy.trial),length(comp_dummy.time{1,1}));
% for i=1:length(comp_dummy.trial)
% m(i,:)=comp_dummy.trial{1,i}(comp,:);
% end;
% figure;mesh(m)
% figure;imagesc(m)

% run the ICA on the original data
cfg = [];
cfg.topo      = comp_dummy.topo;
cfg.topolabel = comp_dummy.topolabel;
comp     = ft_componentanalysis(cfg, dataorig);

% remove the artifact components
cfg = [];
cfg.component = [16]; % change
dataica = ft_rejectcomponent(cfg, comp);

clear comp_dummy comppic comp dummy

% % PCA - if ICA didn't deliver the goods
% cfg = [];
% cfg.method = 'pca';
% %cfg.channel = {'MEG'};
% comp = ft_componentanalysis(cfg, dataorig);
% 
% %see the components and find the artifact
% cfg=[];
% cfg.comp=1:5;
% cfg.layout='4D248.lay';
% comppic=ft_databrowser(cfg,comp);
% 
% reject the bad components
% cfg = [];
% cfg.component = [3 4]; % change
% datapca = ft_rejectcomponent(cfg, comp);

% 7. base line correction
dataica=correctBL(dataica,[-1,-0.7]);

% 8.1 trial summary
cfg=[];
cfg.method='trial'; % 'channel'
cfg.channel=channels;
cfg1.bpfilter='yes';
cfg1.bpfreq=[1 40];
datafinal=ft_rejectvisual(cfg, dataica);

% 8.2 trial by trial
cfg.method='summary';
datafinal=ft_rejectvisual(cfg, datafinal);
% see again
datafinal=ft_rejectvisual(cfg, datafinal);

%% if you need to interpolate channel A41 or A163
% datafinal = interpolateA41(datafinal)
% datafinal = interpolateA163(datafinal)
%%
% 9. recreating the trl matrix
datafinal.cfg.trl(:,1:2)=datafinal.sampleinfo(:,1:2);
datafinal.cfg.trl(:,3)=-1017; % the offset
datafinal.cfg.trl(:,4:7)=datafinal.trialinfo(:,1:4);

save datafinal datafinal

% 10. split conditions
cfg=[];
for i = [110 120 130 140 150 160]
    eval(['cfg.cond=',num2str(i),';']);
    eval(['con',num2str(i),'=splitcondscrt(cfg,datafinal);']);
end;

% 11. averaging
eval(['sub',num2str(sub),'fullSingle=ft_timelockanalysis([],con110);']);
eval(['sub',num2str(sub),'lessSingle=ft_timelockanalysis([],con120);']);
eval(['sub',num2str(sub),'fullFirst=ft_timelockanalysis([],con130);']);
eval(['sub',num2str(sub),'lessFirst=ft_timelockanalysis([],con140);']);
eval(['sub',num2str(sub),'fullSecond=ft_timelockanalysis([],con150);']);
eval(['sub',num2str(sub),'lessSecond=ft_timelockanalysis([],con160);']);
eval(['sub',num2str(sub),'all=ft_timelockanalysis([], datafinal);']);

eval(['save averagedataERF sub',num2str(sub),'fullSingle sub',num2str(sub),'lessSingle sub',num2str(sub),'fullFirst sub',num2str(sub),'fullSecond sub',num2str(sub),'lessFirst sub',num2str(sub),'lessSecond sub',num2str(sub),'all'])
clear all;
load averagedataERF

% 12. Plots
f=pwd;
sub=str2num(f(end-3:end-2));
if isempty(sub) == 1
    sub=str2num(f(end-2));
end

% Butterfly
figure;
eval(['plot(sub',num2str(sub),'all.time, sub',num2str(sub),'all.avg,''b'')']);
axis tight;
hold on;
yLimits = get(gca,'YLim');
plot([0 0],[yLimits(1) yLimits(2)],'k');
plot([-1 1],[0 0],'k');
text(-0.025,-2.05*10^(-13),'target');
grid on;

% cfg = [];
% cfg.viewmode = 'butterfly'; 
% ft_databrowser(cfg, data);

figure;for i = SZ
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
end
eval(['plot(sub',num2str(sub),'fullSingle.time, sub',num2str(sub),'fullSingle.avg,''b'')']);
axis tight;
hold on;
eval(['plot(sub',num2str(sub),'lessSingle.time, sub',num2str(sub),'lessSingle.avg,''r'')']);
yLimits = get(gca,'YLim');
plot([0 0],[yLimits(1) yLimits(2)],'k');
plot([-1 1],[0 0],'k');
text(-0.025,-2.05*10^(-13),'target');
xlabel('time in ms');
ylabel('amplitude');
title('blue - fullSingle, red - lessSingle');
grid on;

% multiplotER interactive
cfg=[];
cfg.layout='4D248.lay';
cfg.interactive = 'yes';
eval(['ft_multiplotER(cfg, sub',num2str(sub),'fullFirst, sub',num2str(sub),'fullSecond);']);






figure;
eval(['plot(sub',num2str(sub),'wordFirst.time, sub',num2str(sub),'wordFirst.avg,''b'')']);
hold on;
eval(['plot(sub',num2str(sub),'wordSecond.time, sub',num2str(sub),'wordSecond.avg,''r'')']);
plot([0 0],[2*10^(-13) -2*10^(-13)],'k');
text(-0.025,-2.05*10^(-13),'stimulus onset');
xlabel('time in ms');
ylabel('amplitude');
title('blue - wordFirst, red - wordSecond');
grid on;
axis tight;

figure;
eval(['plot(sub',num2str(sub),'nonWordFirst.time, sub',num2str(sub),'nonWordFirst.avg,''b'')']);
hold on;
eval(['plot(sub',num2str(sub),'nonWordSecond.time, sub',num2str(sub),'nonWordSecond.avg,''r'')']);
plot([0 0],[2*10^(-13) -2*10^(-13)],'k');
text(-0.025,-2.05*10^(-13),'stimulus onset');
xlabel('time in ms');
ylabel('amplitude');
title('blue - nonWordFirst, red - nonWordSecond');
grid on;
axis tight;

% topoplot
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=(0.2:0.05:0.5); % from 300ms to 600ms in 10ms interval
% cfg.zlim=[-9*10^(-14) 2*10^(-13)];
cfg.colorbar='no'; % change to 'no' in order to avoid the annoying colorbar that squeeze the plot
% cfg.comment='no'; % to ommit the text from the plot
ft_topoplotER(cfg,sub26average);

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

%% grand average
clear all
cd /home/meg/Data/Maor/SchizoProject/expressions
control = [0:3, 5:9, 12, 15, 20, 32, 36, 39, 41];
SZ = [14, 16, 17, 19, 21, 23:25, 27:29, 31, 33:35, 37];
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
end
conAllCondsGrAvg = ft_timelockgrandaverage([],sub0all, sub1all, sub2all, sub3all, sub5all,...
    sub6all, sub7all, sub8all, sub9all, sub12all, sub15all,sub20all, sub32all,...
    sub36all, sub39all, sub41all);
for i = SZ
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
end
SZAllCondsGrAvg = ft_timelockgrandaverage([],sub14all, sub16all, sub17all, sub19all,...
    sub21all, sub23all, sub24all, sub25all, sub27all, sub28all,sub29all, sub31all,...
    sub33all, sub34all, sub35all, sub37all);
save gravgs conAllCondsGrAvg SZAllCondsGrAvg
clear all
load gravgs

% plots
figure
plot(conAllCondsGrAvg.time, conAllCondsGrAvg.avg, 'r');
hold on
plot(SZAllCondsGrAvg.time, SZAllCondsGrAvg.avg, 'b');
grid on;
axis tight;
plot([-0.5 -0.5], [-10^(-13) 10^(-13)], 'k'); 
plot([0 0], [-10^(-13) 10^(-13)], 'k'); 
title('Blue - SZ (n = 16); Red - Control (n = 16)')
text(-0.025,-1.02*10^(-13),'target');
text(-0.525,-1.02*10^(-13),'prime');

% topoplot
figure
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[0.238 0.3]; % from 300ms to 600ms in 10ms interval
cfg.zlim=[-3*10^(-14) 3*10^(-14)];
cfg.colorbar='yes'; % change to 'no' in order to avoid the annoying colorbar that squeeze the plot
cfg.comment='no'; % to ommit the text from the plot
subplot(1,2,1)
ft_topoplotER(cfg,SZAllCondsGrAvg);
subplot(1,2,2)
ft_topoplotER(cfg,conAllCondsGrAvg);



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
r1=1:17;r1=[r1 r1 r1 r1];
r2=ones(1,17);r2=[r2 r2*2 r2*3 r2*4];

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

cfg=[];
cfg.parameter = 'stat';
cfg.alpha=0.05;
cfg.layout = '4D248.lay';
ft_clusterplot(cfg,stat)