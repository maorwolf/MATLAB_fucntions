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
    'maskTrigBits', 512);

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
% sub and conds definitions

%% -------------------- Preprocessing and cleaning ------------------------
clear all
clc
cfg=[];
sub=41;
eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(sub),'/1'])
source='xc,hb,lf_c,rfhp0.1Hz';

% 1. find Bad Channels
findBadChans(source);
%original_source='c,rfhp0.1Hz';% we added this line to compare between the data before and after cleaning with the Abeles fucntion
%findBadChans(original_source);


% 2. finding trials and defining them
conditions = [110 120 130 140 150 160 170 180 190];
% 110 - word, no repeats, high freq
% 120 - word, no repeats, low freq
% 130 - non word, no repeats
% 140 - word, first apperance, high freq
% 150 - word, first apperance, low freq
% 160 - word, second apperance, high freq
% 170 - word, second apperance, low freq
% 180 - non word, first repeat
% 190 - non word, second repeat

cfg.dataset =source; 
cfg.trialdef.eventtype  = 'TRIGGER';
cfg.trialdef.eventvalue = conditions;
cfg.trialdef.prestim    = 0.3;
cfg.trialdef.poststim   = 0.8;
cfg.trialdef.offset=-0.3;
cfg.trialfun='BIUtrialfun';
cfg.trialdef.visualtrig = 'visafter';
cfg.trialdef.visualtrigwin = 0.2;
cfg = ft_definetrial(cfg);

% creating colume 7 with correct code
cfg.trl(1:length(cfg.trl),7) = 0;
for i=1:length(cfg.trl)
	if ((cfg.trl(i,4)==110) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==120) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1;
	elseif ((cfg.trl(i,4)==130) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1; 
	elseif ((cfg.trl(i,4)==140) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1; 
    elseif ((cfg.trl(i,4)==150) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1; 
	elseif ((cfg.trl(i,4)==160) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1; 
	elseif ((cfg.trl(i,4)==170) && (cfg.trl(i,6)==256)) 
        cfg.trl(i,7)=1; 
	elseif ((cfg.trl(i,4)==180) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1; 
	elseif ((cfg.trl(i,4)==190) && (cfg.trl(i,6)==512)) 
        cfg.trl(i,7)=1;
    end;
end;

% if no visual trigger was recorded:
% cfg.trl(:,[1,2])=cfg.trl(:,[1,2])+33;

% 3. preprocessing for muscle artifact rejection
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-0.3,0];
cfg.trialdef.prestim    = 0.3;
cfg.trialdef.poststim   = 0.8;
cfg.trialdef.offset=-0.3;
cfg.hpfilter='yes';
cfg.hpfreq=60;
cfg.channel = {'MEG'}; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
cfg.padding = 10;
dataorig=ft_preprocessing(cfg);

% 4. remove muscle artifact
cfg1.method='summary'; %trial
datacln=ft_rejectvisual(cfg1, dataorig);

% to see again
datacln=ft_rejectvisual(cfg1, datacln);

% 5 Deleting the bad trials from the original data so you don't refilter the data
cfg.trl = [];
cfg.trl = datacln.sampleinfo;
cfg.trl(:,3) = -305; % change according to your offset in samples!!!
cfg.trl(:,[4:7]) = datacln.trialinfo;

% 5.1 preprocessing original data without the bad trials
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-0.3,0];
cfg.trialdef.prestim    = 0.3;
cfg.trialdef.poststim   = 0.8;
cfg.trialdef.offset=-0.3;
cfg.hpfilter='no';
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[1 40];
cfg.channel = {'MEG'}; % {'MEG','-A41','-A212'};
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
cfg.channel    = {'MEG'};
comp_dummy           = ft_componentanalysis(cfg, dummy);

% see the components and find the artifacts
cfgb=[];
cfgb.layout='4D248.lay';
cfgb.channel = {comp_dummy.label{1:10}};
cfgb.continuous='no';
comppic=ft_databrowser(cfgb,comp_dummy);

% cool visualization for one component (e.g.,comp = 3) along trials and time (after resampling)  
seeOneComp(comp_dummy,16) % change the number of components you want to see

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
cfg.component = []; % change
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
dataica=correctBL(dataica,[-0.3 0]);

% 8. trial by trial
cfg=[];
cfg.method='trial'; % 'channel'
cfg.channel='MEG';
cfg1.bpfilter='yes';
cfg1.bpfreq=[1 40];
datafinal=ft_rejectvisual(cfg, dataica);

% 9. recreating the trl matrix
datafinal.cfg.trl(:,1:2)=datafinal.sampleinfo(:,1:2);
datafinal.cfg.trl(:,3)=-305; % the offset
datafinal.cfg.trl(:,4:7)=datafinal.trialinfo(:,1:4);

% 10. split conditions
cfg=[];
for i = [110 120 130 140 150 160 170 180 190]
    eval(['cfg.cond=',num2str(i),';']);
    eval(['con',num2str(i),'=splitcondscrt(cfg,datafinal);']);
end;

% for combining two or more datasets use: 
cfg=[];
wordSingle=ft_appenddata(cfg, con110, con120);
nonWordSingle=con130;
wordFirst=ft_appenddata(cfg, con140, con150);
wordSecond=ft_appenddata(cfg, con160, con170);
nonWordFirst=con180;
nonWordSecond=con190;

% 11. averaging
eval(['sub',num2str(sub),'wordSingle=ft_timelockanalysis([],wordSingle);']);
eval(['sub',num2str(sub),'nonWordSingle=ft_timelockanalysis([],nonWordSingle);']);
eval(['sub',num2str(sub),'wordFirst=ft_timelockanalysis([],wordFirst);']);
eval(['sub',num2str(sub),'wordSecond=ft_timelockanalysis([],wordSecond);']);
eval(['sub',num2str(sub),'nonWordFirst=ft_timelockanalysis([],nonWordFirst);']);
eval(['sub',num2str(sub),'nonWordSecond=ft_timelockanalysis([],nonWordSecond);']);
eval(['sub',num2str(sub),'all=ft_timelockanalysis([], datafinal);']);

eval(['save averagedataERF sub',num2str(sub),'wordSingle sub',num2str(sub),'nonWordSingle sub',num2str(sub),'wordFirst sub',num2str(sub),'wordSecond sub',num2str(sub),'nonWordFirst sub',num2str(sub),'nonWordSecond sub',num2str(sub),'all'])
clear all;
load averagedataERF

% 12. Plots
sub=39; % change sub number
% Butterfly
figure;
eval(['plot(sub',num2str(sub),'all.time, sub',num2str(sub),'all.avg,''b'')']);
hold on;
plot([0 0],[2*10^(-13) -2*10^(-13)],'k');
grid on;
axis tight;


figure;
eval(['plot(sub',num2str(sub),'nonWordSingle.time, sub',num2str(sub),'nonWordSingle.avg,''b'')']);
hold on;
eval(['plot(sub',num2str(sub),'wordSingle.time, sub',num2str(sub),'wordSingle.avg,''r'')']);
plot([0 0],[2*10^(-13) -2*10^(-13)],'k');
text(-0.025,-2.05*10^(-13),'stimulus onset');
xlabel('time in ms');
ylabel('amplitude');
title('blue - nonWordSingle, red - wordSingle');
grid on;
axis tight;

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
control = [0:3, 5:9, 12, 15, 20, 32, 36, 39];
SZ = [14, 16, 17, 19, 21, 23:25, 27 28, 31, 33:35, 37];
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
end
conAllCondsGrAvg = ft_timelockgrandaverage([],sub0all, sub1all, sub2all, sub3all, sub5all,...
    sub6all, sub7all, sub8all, sub9all, sub12all, sub15all,sub20all, sub32all,...
    sub36all, sub39all);
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
end
SZAllCondsGrAvg = ft_timelockgrandaverage([],sub14all, sub16all, sub17all, sub19all,...
    sub21all, sub23all, sub24all, sub25all, sub27all, sub28all,sub31all,...
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
plot([0 0], [-10^(-13) 10^(-13)], 'k'); 
title('Blue - SZ (n = 15); Red - Control (n = 15)')

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
%%

%%%%%%%%%% RMS Analysis %%%%%%%%%%

%% RMS for control
clear all
cd /home/meg/Data/Maor/SchizoProject/Subjects
load LRpairs

control = [0:3, 5:9, 12, 15, 20, 32, 36, 39];

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'wordFirst.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'wordFirst.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSwordFirst=sqrt(mean(sub',num2str(i),'wordFirst.avg.^2));']);
    eval(['sub',num2str(i),'RMSwordFirst=sub',num2str(i),'RMSwordFirst-mean(sub',num2str(i),'RMSwordFirst(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSwordFirstL=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstL=sub',num2str(i),'RMSwordFirstL-mean(sub',num2str(i),'RMSwordFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstR=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstR=sub',num2str(i),'RMSwordFirstR-mean(sub',num2str(i),'RMSwordFirstR(1,1:305));']);
    eval(['conRMSwordFirst(a,:)=sub',num2str(i),'RMSwordFirst;']);
    eval(['conRMSwordFirstL(a,:)=sub',num2str(i),'RMSwordFirstL;']);
    eval(['conRMSwordFirstR(a,:)=sub',num2str(i),'RMSwordFirstR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'wordSecond.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'wordSecond.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSwordSecond=sqrt(mean(sub',num2str(i),'wordSecond.avg.^2));']);
    eval(['sub',num2str(i),'RMSwordSecond=sub',num2str(i),'RMSwordSecond-mean(sub',num2str(i),'RMSwordSecond(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSwordSecondL=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondL=sub',num2str(i),'RMSwordSecondL-mean(sub',num2str(i),'RMSwordSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondR=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondR=sub',num2str(i),'RMSwordSecondR-mean(sub',num2str(i),'RMSwordSecondR(1,1:305));']);
    eval(['conRMSwordSecond(a,:)=sub',num2str(i),'RMSwordSecond;']);
    eval(['conRMSwordSecondL(a,:)=sub',num2str(i),'RMSwordSecondL;']);
    eval(['conRMSwordSecondR(a,:)=sub',num2str(i),'RMSwordSecondR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'wordSingle.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'wordSingle.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSwordSingle=sqrt(mean(sub',num2str(i),'wordSingle.avg.^2));']);
    eval(['sub',num2str(i),'RMSwordSingle=sub',num2str(i),'RMSwordSingle-mean(sub',num2str(i),'RMSwordSingle(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSwordSingleL=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleL=sub',num2str(i),'RMSwordSingleL-mean(sub',num2str(i),'RMSwordSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleR=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleR=sub',num2str(i),'RMSwordSingleR-mean(sub',num2str(i),'RMSwordSingleR(1,1:305));']);
    eval(['conRMSwordSingle(a,:)=sub',num2str(i),'RMSwordSingle;']);
    eval(['conRMSwordSingleL(a,:)=sub',num2str(i),'RMSwordSingleL;']);
    eval(['conRMSwordSingleR(a,:)=sub',num2str(i),'RMSwordSingleR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'nonWordFirst.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordFirst.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSnonWordFirst=sqrt(mean(sub',num2str(i),'nonWordFirst.avg.^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirst=sub',num2str(i),'RMSnonWordFirst-mean(sub',num2str(i),'RMSnonWordFirst(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSnonWordFirstL=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstL=sub',num2str(i),'RMSnonWordFirstL-mean(sub',num2str(i),'RMSnonWordFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstR=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstR=sub',num2str(i),'RMSnonWordFirstR-mean(sub',num2str(i),'RMSnonWordFirstR(1,1:305));']);
    eval(['conRMSnonWordFirst(a,:)=sub',num2str(i),'RMSnonWordFirst;']);
    eval(['conRMSnonWordFirstL(a,:)=sub',num2str(i),'RMSnonWordFirstL;']);
    eval(['conRMSnonWordFirstR(a,:)=sub',num2str(i),'RMSnonWordFirstR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'nonWordSecond.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordSecond.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSnonWordSecond=sqrt(mean(sub',num2str(i),'nonWordSecond.avg.^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecond=sub',num2str(i),'RMSnonWordSecond-mean(sub',num2str(i),'RMSnonWordSecond(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSnonWordSecondL=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondL=sub',num2str(i),'RMSnonWordSecondL-mean(sub',num2str(i),'RMSnonWordSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondR=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondR=sub',num2str(i),'RMSnonWordSecondR-mean(sub',num2str(i),'RMSnonWordSecondR(1,1:305));']);
    eval(['conRMSnonWordSecond(a,:)=sub',num2str(i),'RMSnonWordSecond;']);
    eval(['conRMSnonWordSecondL(a,:)=sub',num2str(i),'RMSnonWordSecondL;']);
    eval(['conRMSnonWordSecondR(a,:)=sub',num2str(i),'RMSnonWordSecondR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'nonWordSingle.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordSingle.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSnonWordSingle=sqrt(mean(sub',num2str(i),'nonWordSingle.avg.^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingle=sub',num2str(i),'RMSnonWordSingle-mean(sub',num2str(i),'RMSnonWordSingle(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSnonWordSingleL=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleL=sub',num2str(i),'RMSnonWordSingleL-mean(sub',num2str(i),'RMSnonWordSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleR=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleR=sub',num2str(i),'RMSnonWordSingleR-mean(sub',num2str(i),'RMSnonWordSingleR(1,1:305));']);
    eval(['conRMSnonWordSingle(a,:)=sub',num2str(i),'RMSnonWordSingle;']);
    eval(['conRMSnonWordSingleL(a,:)=sub',num2str(i),'RMSnonWordSingleL;']);
    eval(['conRMSnonWordSingleR(a,:)=sub',num2str(i),'RMSnonWordSingleR;']);  
    a=a+1;
end;
clear a i

save conRMS conRMSnonWordFirst conRMSnonWordFirstL conRMSnonWordFirstR conRMSnonWordSecond...
    conRMSnonWordSecondL conRMSnonWordSecondR conRMSnonWordSingle conRMSnonWordSingleL...
    conRMSnonWordSingleR conRMSwordFirst conRMSwordFirstL conRMSwordFirstR conRMSwordSecond...
    conRMSwordSecondL conRMSwordSecondR conRMSwordSingle conRMSwordSingleL conRMSwordSingleR

clear all

%% RMS for SZ
clear all
cd /home/meg/Data/Maor/SchizoProject/Subjects
load LRpairs

SZ = [14, 16, 17, 19, 21, 23:25, 27, 28, 31, 33:35, 37];

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'wordFirst.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'wordFirst.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSwordFirst=sqrt(mean(sub',num2str(i),'wordFirst.avg.^2));']);
    eval(['sub',num2str(i),'RMSwordFirst=sub',num2str(i),'RMSwordFirst-mean(sub',num2str(i),'RMSwordFirst(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSwordFirstL=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstL=sub',num2str(i),'RMSwordFirstL-mean(sub',num2str(i),'RMSwordFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstR=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstR=sub',num2str(i),'RMSwordFirstR-mean(sub',num2str(i),'RMSwordFirstR(1,1:305));']);
    eval(['SZRMSwordFirst(a,:)=sub',num2str(i),'RMSwordFirst;']);
    eval(['SZRMSwordFirstL(a,:)=sub',num2str(i),'RMSwordFirstL;']);
    eval(['SZRMSwordFirstR(a,:)=sub',num2str(i),'RMSwordFirstR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'wordSecond.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'wordSecond.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSwordSecond=sqrt(mean(sub',num2str(i),'wordSecond.avg.^2));']);
    eval(['sub',num2str(i),'RMSwordSecond=sub',num2str(i),'RMSwordSecond-mean(sub',num2str(i),'RMSwordSecond(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSwordSecondL=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondL=sub',num2str(i),'RMSwordSecondL-mean(sub',num2str(i),'RMSwordSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondR=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondR=sub',num2str(i),'RMSwordSecondR-mean(sub',num2str(i),'RMSwordSecondR(1,1:305));']);
    eval(['SZRMSwordSecond(a,:)=sub',num2str(i),'RMSwordSecond;']);
    eval(['SZRMSwordSecondL(a,:)=sub',num2str(i),'RMSwordSecondL;']);
    eval(['SZRMSwordSecondR(a,:)=sub',num2str(i),'RMSwordSecondR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'wordSingle.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'wordSingle.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSwordSingle=sqrt(mean(sub',num2str(i),'wordSingle.avg.^2));']);
    eval(['sub',num2str(i),'RMSwordSingle=sub',num2str(i),'RMSwordSingle-mean(sub',num2str(i),'RMSwordSingle(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSwordSingleL=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleL=sub',num2str(i),'RMSwordSingleL-mean(sub',num2str(i),'RMSwordSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleR=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleR=sub',num2str(i),'RMSwordSingleR-mean(sub',num2str(i),'RMSwordSingleR(1,1:305));']);
    eval(['SZRMSwordSingle(a,:)=sub',num2str(i),'RMSwordSingle;']);
    eval(['SZRMSwordSingleL(a,:)=sub',num2str(i),'RMSwordSingleL;']);
    eval(['SZRMSwordSingleR(a,:)=sub',num2str(i),'RMSwordSingleR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'nonWordFirst.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordFirst.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSnonWordFirst=sqrt(mean(sub',num2str(i),'nonWordFirst.avg.^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirst=sub',num2str(i),'RMSnonWordFirst-mean(sub',num2str(i),'RMSnonWordFirst(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSnonWordFirstL=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstL=sub',num2str(i),'RMSnonWordFirstL-mean(sub',num2str(i),'RMSnonWordFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstR=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstR=sub',num2str(i),'RMSnonWordFirstR-mean(sub',num2str(i),'RMSnonWordFirstR(1,1:305));']);
    eval(['SZRMSnonWordFirst(a,:)=sub',num2str(i),'RMSnonWordFirst;']);
    eval(['SZRMSnonWordFirstL(a,:)=sub',num2str(i),'RMSnonWordFirstL;']);
    eval(['SZRMSnonWordFirstR(a,:)=sub',num2str(i),'RMSnonWordFirstR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'nonWordSecond.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordSecond.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSnonWordSecond=sqrt(mean(sub',num2str(i),'nonWordSecond.avg.^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecond=sub',num2str(i),'RMSnonWordSecond-mean(sub',num2str(i),'RMSnonWordSecond(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSnonWordSecondL=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondL=sub',num2str(i),'RMSnonWordSecondL-mean(sub',num2str(i),'RMSnonWordSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondR=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondR=sub',num2str(i),'RMSnonWordSecondR-mean(sub',num2str(i),'RMSnonWordSecondR(1,1:305));']);
    eval(['SZRMSnonWordSecond(a,:)=sub',num2str(i),'RMSnonWordSecond;']);
    eval(['SZRMSnonWordSecondL(a,:)=sub',num2str(i),'RMSnonWordSecondL;']);
    eval(['SZRMSnonWordSecondR(a,:)=sub',num2str(i),'RMSnonWordSecondR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'nonWordSingle.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordSingle.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSnonWordSingle=sqrt(mean(sub',num2str(i),'nonWordSingle.avg.^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingle=sub',num2str(i),'RMSnonWordSingle-mean(sub',num2str(i),'RMSnonWordSingle(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSnonWordSingleL=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleL=sub',num2str(i),'RMSnonWordSingleL-mean(sub',num2str(i),'RMSnonWordSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleR=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleR=sub',num2str(i),'RMSnonWordSingleR-mean(sub',num2str(i),'RMSnonWordSingleR(1,1:305));']);
    eval(['SZRMSnonWordSingle(a,:)=sub',num2str(i),'RMSnonWordSingle;']);
    eval(['SZRMSnonWordSingleL(a,:)=sub',num2str(i),'RMSnonWordSingleL;']);
    eval(['SZRMSnonWordSingleR(a,:)=sub',num2str(i),'RMSnonWordSingleR;']);  
    a=a+1;
end;
clear a i

save SZRMS SZRMSnonWordFirst SZRMSnonWordFirstL SZRMSnonWordFirstR SZRMSnonWordSecond...
    SZRMSnonWordSecondL SZRMSnonWordSecondR SZRMSnonWordSingle SZRMSnonWordSingleL...
    SZRMSnonWordSingleR SZRMSwordFirst SZRMSwordFirstL SZRMSwordFirstR SZRMSwordSecond...
    SZRMSwordSecondL SZRMSwordSecondR SZRMSwordSingle SZRMSwordSingleL SZRMSwordSingleR

clear all

load conRMS
load SZRMS
%% plot RMS
load time
load SZRMS
% all conditions
figure
subplot(3,2,1)
plot(time,mean(SZRMSwordSingle,1),'b')
hold on;
plot(time,mean(conRMSwordSingle,1),'r')
grid on;
axis tight;
title('Single presentation of words; blue - SZ, red - control')

subplot(3,2,2)
plot(time,mean(SZRMSnonWordSingle,1),'b')
hold on;
plot(time,mean(conRMSnonWordSingle,1),'r')
grid on;
axis tight;
title('Single presentation of non-words; blue - SZ, red - control')

subplot(3,2,3)
plot(time,mean(SZRMSwordFirst,1),'b')
hold on;
plot(time,mean(conRMSwordFirst,1),'r')
grid on;
axis tight;
title('First presentation of words; blue - SZ, red - control')

subplot(3,2,4)
plot(time,mean(SZRMSnonWordFirst,1),'b')
hold on;
plot(time,mean(conRMSnonWordFirst,1),'r')
grid on;
axis tight;
title('First presentation of non-words; blue - SZ, red - control')

subplot(3,2,5)
plot(time,mean(SZRMSwordSecond,1),'b')
hold on;
plot(time,mean(conRMSwordSecond,1),'r')
grid on;
axis tight;
title('Second presentation of words; blue - SZ, red - control')

subplot(3,2,6)
plot(time,mean(SZRMSnonWordSecond,1),'b')
hold on;
plot(time,mean(conRMSnonWordSecond,1),'r')
grid on;
axis tight;
title('Second presentation of non-words; blue - SZ, red - control')

% Left vs. Right
% word single
figure
subplot(3,1,1)
plot(time,mean(SZRMSwordSingle,1),'b')
hold on;
plot(time,mean(conRMSwordSingle,1),'r')
grid on;
axis tight;
title('Single presentation of words; blue - SZ (n = 16), red - control (n = 15)')
subplot(3,1,2)
plot(time,mean(SZRMSwordSingleL,1),'b')
hold on;
plot(time,mean(conRMSwordSingleL,1),'r')
grid on;
axis tight;
title('Left channels of single presentation of words; blue - SZ (n = 16), red - control (n = 15)')
subplot(3,1,3)
plot(time,mean(SZRMSwordSingleR,1),'b')
hold on;
plot(time,mean(conRMSwordSingleR,1),'r')
grid on;
axis tight;
title('Right channels of single presentation of words; blue - SZ (n = 16), red - control (n = 15)')

% nonWord single
figure
subplot(3,1,1)
plot(time,mean(SZRMSnonWordSingle,1),'b')
hold on;
plot(time,mean(conRMSnonWordSingle,1),'r')
grid on;
axis tight;
title('Single presentation of non-words; blue - SZ (n = 16), red - control (n = 15)')
subplot(3,1,2)
plot(time,mean(SZRMSnonWordSingleL,1),'b')
hold on;
plot(time,mean(conRMSnonWordSingleL,1),'r')
grid on;
axis tight;
title('Left channels of single presentation of non-words; blue - SZ (n = 16), red - control (n = 15)')
subplot(3,1,3)
plot(time,mean(SZRMSnonWordSingleR,1),'b')
hold on;
plot(time,mean(conRMSnonWordSingleR,1),'r')
grid on;
axis tight;
title('Right channels of single presentation of non-words; blue - SZ (n = 16), red - control (n = 15)')

%% RMS for 6 comps
load SZRMS
wordSingle=[mean(SZRMSwordSingle(:,[377 418]),2);mean(conRMSwordSingle(:,[377 418]),2)]; % 70-110 ms
wordSingle(:,2)=[mean(SZRMSwordSingle(:,[428 499]),2);mean(conRMSwordSingle(:,[428 499]),2)]; % 120-190 ms
wordSingle(:,3)=[mean(SZRMSwordSingle(:,[586 649]),2);mean(conRMSwordSingle(:,[548 611]),2)]; % 238-300 ms
wordSingle(:,4)=[mean(SZRMSwordSingle(:,[650 701]),2);mean(conRMSwordSingle(:,[627 678]),2)]; % 316-366 ms
wordSingle(:,5)=[mean(SZRMSwordSingle(:,[702 775]),2);mean(conRMSwordSingle(:,[699 772]),2)]; % 386-458 ms
wordSingle(:,6)=[mean(SZRMSwordSingle(:,[953 1116]),2);mean(conRMSwordSingle(:,[916 1079]),2)]; % 600-160 ms

wordFirst=[mean(SZRMSwordFirst(:,[377 418]),2);mean(conRMSwordFirst(:,[377 418]),2)];
wordFirst(:,2)=[mean(SZRMSwordFirst(:,[428 499]),2);mean(conRMSwordFirst(:,[428 499]),2)];
wordFirst(:,3)=[mean(SZRMSwordFirst(:,[586 649]),2);mean(conRMSwordFirst(:,[548 611]),2)];
wordFirst(:,4)=[mean(SZRMSwordFirst(:,[650 701]),2);mean(conRMSwordFirst(:,[627 678]),2)];
wordFirst(:,5)=[mean(SZRMSwordFirst(:,[702 775]),2);mean(conRMSwordFirst(:,[699 772]),2)];
wordFirst(:,6)=[mean(SZRMSwordFirst(:,[953 1116]),2);mean(conRMSwordFirst(:,[916 1079]),2)];

wordSecond=[mean(SZRMSwordSecond(:,[377 418]),2);mean(conRMSwordSecond(:,[377 418]),2)];
wordSecond(:,2)=[mean(SZRMSwordSecond(:,[428 499]),2);mean(conRMSwordSecond(:,[428 499]),2)];
wordSecond(:,3)=[mean(SZRMSwordSecond(:,[586 649]),2);mean(conRMSwordSecond(:,[548 611]),2)];
wordSecond(:,4)=[mean(SZRMSwordSecond(:,[650 701]),2);mean(conRMSwordSecond(:,[627 678]),2)];
wordSecond(:,5)=[mean(SZRMSwordSecond(:,[702 775]),2);mean(conRMSwordSecond(:,[699 772]),2)];
wordSecond(:,6)=[mean(SZRMSwordSecond(:,[953 1116]),2);mean(conRMSwordSecond(:,[916 1079]),2)];

nonWordSingle=[mean(SZRMSnonWordSingle(:,[377 418]),2);mean(conRMSnonWordSingle(:,[377 418]),2)];
nonWordSingle(:,2)=[mean(SZRMSnonWordSingle(:,[428 499]),2);mean(conRMSnonWordSingle(:,[428 499]),2)];
nonWordSingle(:,3)=[mean(SZRMSnonWordSingle(:,[586 649]),2);mean(conRMSnonWordSingle(:,[548 611]),2)];
nonWordSingle(:,4)=[mean(SZRMSnonWordSingle(:,[650 701]),2);mean(conRMSnonWordSingle(:,[627 678]),2)];
nonWordSingle(:,5)=[mean(SZRMSnonWordSingle(:,[702 775]),2);mean(conRMSnonWordSingle(:,[699 772]),2)];
nonWordSingle(:,6)=[mean(SZRMSnonWordSingle(:,[953 1116]),2);mean(conRMSnonWordSingle(:,[916 1079]),2)];

nonWordFirst=[mean(SZRMSnonWordFirst(:,[377 418]),2);mean(conRMSnonWordFirst(:,[377 418]),2)];
nonWordFirst(:,2)=[mean(SZRMSnonWordFirst(:,[428 499]),2);mean(conRMSnonWordFirst(:,[428 499]),2)];
nonWordFirst(:,3)=[mean(SZRMSnonWordFirst(:,[586 649]),2);mean(conRMSnonWordFirst(:,[548 611]),2)];
nonWordFirst(:,4)=[mean(SZRMSnonWordFirst(:,[650 701]),2);mean(conRMSnonWordFirst(:,[627 678]),2)];
nonWordFirst(:,5)=[mean(SZRMSnonWordFirst(:,[702 775]),2);mean(conRMSnonWordFirst(:,[699 772]),2)];
nonWordFirst(:,6)=[mean(SZRMSnonWordFirst(:,[953 1116]),2);mean(conRMSnonWordFirst(:,[916 1079]),2)];

nonWordSecond=[mean(SZRMSnonWordSecond(:,[377 418]),2);mean(conRMSnonWordSecond(:,[377 418]),2)];
nonWordSecond(:,2)=[mean(SZRMSnonWordSecond(:,[428 499]),2);mean(conRMSnonWordSecond(:,[428 499]),2)];
nonWordSecond(:,3)=[mean(SZRMSnonWordSecond(:,[586 649]),2);mean(conRMSnonWordSecond(:,[548 611]),2)];
nonWordSecond(:,4)=[mean(SZRMSnonWordSecond(:,[650 701]),2);mean(conRMSnonWordSecond(:,[627 678]),2)];
nonWordSecond(:,5)=[mean(SZRMSnonWordSecond(:,[702 775]),2);mean(conRMSnonWordSecond(:,[699 772]),2)];
nonWordSecond(:,6)=[mean(SZRMSnonWordSecond(:,[953 1116]),2);mean(conRMSnonWordSecond(:,[916 1079]),2)];

wordSingle = wordSingle.*10^15;
wordFirst = wordFirst.*10^15;
wordSecond = wordSecond.*10^15;
nonWordSingle = nonWordSingle.*10^15;
nonWordFirst = nonWordFirst.*10^15;
nonWordSecond = nonWordSecond.*10^15;

save RMS4SPSS wordSingle wordFirst wordSecond nonWordSingle nonWordFirst nonWordSecond
clear all
load RMS4SPSS

% ploting
figure;
subplot(2,1,1)
h1 = bar([mean(wordSingle(1:15,1)),mean(wordFirst(1:15,1)),mean(wordSecond(1:15,1));...
    mean(nonWordSingle(1:15,1)),mean(nonWordFirst(1:15,1)),mean(nonWordSecond(1:15,1))]);
title('RT Comp1');
ylabel('RMS*10^14');
ylim([0 30]);
set(h1(1), 'facecolor', [0 0 1]);
set(h1(2), 'facecolor', [1 0 0]);
set(h1(3), 'facecolor', [0 1 0]);
set(gca, 'XTickLabel', {'Word','Non Word'});
legend('Single','First','Second');

subplot(2,1,2)
h2 = bar([mean(wordSingle(16:30,1)),mean(wordFirst(16:30,1)),mean(wordSecond(16:30,1));...
    mean(nonWordSingle(16:30,1)),mean(nonWordFirst(16:30,1)),mean(nonWordSecond(16:30,1))]);
title('RT Comp1');
ylabel('RMS*10^14');
ylim([0 30]);
set(h2(1), 'facecolor', [0 0 1]);
set(h2(2), 'facecolor', [1 0 0]);
set(h2(3), 'facecolor', [0 1 0]);
set(gca, 'XTickLabel', {'Word','Non Word'});
legend('Single','First','Second');

% plot of significant results
% comp1
figure
subplot(2,1,1)
plot([1 2],[mean(wordFirst(1:15,1)),mean(wordSecond(1:15,1))],'w--o');
xlim([0.8 2.2])
ylim([15 30])
hold on;
plot([1 2],[mean(nonWordFirst(1:15,1)),mean(nonWordSecond(1:15,1))],'g--o');

subplot(2,1,2)
plot([1 2],[mean(wordFirst(16:30,1)),mean(wordSecond(16:30,1))],'w--o');
xlim([0.8 2.2])
ylim([15 30])
hold on;
plot([1 2],[mean(nonWordFirst(16:30,1)),mean(nonWordSecond(16:30,1))],'g--o');

%comp2
figure
subplot(2,1,1)
plot([1 2],[mean(wordFirst(1:15,2)),mean(wordSecond(1:15,2))],'w--o');
xlim([0.8 2.2])
ylim([30 45])
hold on;
plot([1 2],[mean(nonWordFirst(1:15,2)),mean(nonWordSecond(1:15,2))],'g--o');

subplot(2,1,2)
plot([1 2],[mean(wordFirst(16:30,2)),mean(wordSecond(16:30,2))],'w--o');
xlim([0.8 2.2])
ylim([30 45])
hold on;
plot([1 2],[mean(nonWordFirst(16:30,2)),mean(nonWordSecond(16:30,2))],'g--o');

%comp3
sz = mean([mean(wordSingle(1:15,3)) mean(nonWordSingle(1:15,3))]);
con = mean([mean(wordSingle(16:30,3)) mean(nonWordSingle(16:30,3))]);
h = bar([sz, con]);
xlim([0 3])

bar([mean(wordSingle(:,3)), mean(nonWordSingle(:,3))])
xlim([0 3])
ylim([0 30])

plot([1 2],[mean([mean(nonWordFirst(1:15,3)),mean(wordFirst(1:15,3))]),...
    mean([mean(nonWordSecond(1:15,3)),mean(wordSecond(1:15,3))])],'w--o');
xlim([0.8 2.2])
%ylim([30 45])
hold on;
plot([1 2],[mean([mean(nonWordFirst(16:30,3)),mean(wordFirst(16:30,3))]),...
    mean([mean(nonWordSecond(16:30,3)),mean(wordSecond(16:30,3))])],'g--o');

% comp4
plot([1 2],[mean([mean(nonWordFirst(1:15,4)),mean(wordFirst(1:15,4))]),...
    mean([mean(nonWordSecond(1:15,4)),mean(wordSecond(1:15,4))])],'w--o');
xlim([0.8 2.2])
%ylim([30 45])
hold on;
plot([1 2],[mean([mean(nonWordFirst(16:30,4)),mean(wordFirst(16:30,4))]),...
    mean([mean(nonWordSecond(16:30,4)),mean(wordSecond(16:30,4))])],'g--o');

% comp5
sz = mean([mean(wordFirst(1:15,5)),mean(nonWordFirst(1:15,5)),...
    mean(wordSecond(1:15,5)),mean(nonWordSecond(1:15,5))]);
con = mean([mean(wordFirst(16:30,5)),mean(nonWordFirst(16:30,5)),...
    mean(wordSecond(16:30,5)),mean(nonWordSecond(16:30,5))]);
h = bar([sz, con]);
xlim([0 3])

plot([1 2],[mean([mean(nonWordFirst(1:15,5)),mean(wordFirst(1:15,5))]),...
    mean([mean(nonWordSecond(1:15,5)),mean(wordSecond(1:15,5))])],'w--o');
xlim([0.8 2.2])
ylim([8 22])
hold on;
plot([1 2],[mean([mean(nonWordFirst(16:30,5)),mean(wordFirst(16:30,5))]),...
    mean([mean(nonWordSecond(16:30,5)),mean(wordSecond(16:30,5))])],'g--o');

szWord = mean([mean(wordFirst(1:15,5)),mean(wordSecond(1:15,5))]);
szNonWord = mean([mean(nonWordFirst(1:15,5)),mean(nonWordSecond(1:15,5))]);
conWord = mean([mean(wordFirst(16:30,5)),mean(wordSecond(16:30,5))]);
conNonWord = mean([mean(nonWordFirst(16:30,5)),mean(nonWordSecond(16:30,5))]);
plot([1 2], [szWord szNonWord],'w--o');
xlim([0.8 2.2])
ylim([8 22])
hold on;
plot([1 2],[conWord conNonWord],'g--o')

% comp6
sz = mean([mean(wordFirst(1:15,6)),mean(nonWordFirst(1:15,6)),...
    mean(wordSecond(1:15,6)),mean(nonWordSecond(1:15,6))]);
con = mean([mean(wordFirst(16:30,6)),mean(nonWordFirst(16:30,6)),...
    mean(wordSecond(16:30,6)),mean(nonWordSecond(16:30,6))]);
h = bar([sz, con]);
xlim([0 3])


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
subplot(2,2,1)
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[0.118 0.157]; % from 300ms to 600ms in 10ms interval
cfg.zlim=[-6*10^(-14) 7*10^(-14)];
cfg.interactive = 'yes';
cfg.colorbar='yes'; % change to 'no' in order to avoid the annoying colorbar that squeeze the plot
%cfg.comment='no'; % to ommit the text from the plot
ft_topoplotER(cfg,gravg104);
subplot(2,2,2)
ft_topoplotER(cfg,gravg108);
cfg.xlim=[0.157 0.187];
subplot(2,2,3)
ft_topoplotER(cfg,gravg104);
subplot(2,2,4)
ft_topoplotER(cfg,gravg108);

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

load time
% plot RMS
figure
subplot(2,1,1)
plot(time,meanCon102RMSL,'b') % LH pre right
hold on;
plot(time,meanCon106RMSL,'r') % LH post right
grid;
subplot(2,1,2)
plot(time,meanCon104RMSR,'b') % RH pre left
hold on;
plot(time,meanCon108RMSR,'r') % RH post left
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