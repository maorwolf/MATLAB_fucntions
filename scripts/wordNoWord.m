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

control = [0:3, 5:9, 12, 15, 20, 32, 36, 39, 41];

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

SZ = [14, 16, 17, 19, 21, 23, 25, 27, 28, 31, 33:35, 37];

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
load conRMS
wordSingle=[mean(SZRMSwordSingle(:,[377 418]),2);mean(conRMSwordSingle(:,[377 418]),2)]; % 70-110 ms
wordSingle(:,2)=[mean(SZRMSwordSingle(:,[428 499]),2);mean(conRMSwordSingle(:,[428 499]),2)]; % 120-190 ms
wordSingle(:,3)=[mean(SZRMSwordSingle(:,[586 649]),2);mean(conRMSwordSingle(:,[548 611]),2)]; % 238-300 ms
wordSingle(:,4)=[mean(SZRMSwordSingle(:,[650 701]),2);mean(conRMSwordSingle(:,[627 678]),2)]; % 316-366 ms
wordSingle(:,5)=[mean(SZRMSwordSingle(:,[702 775]),2);mean(conRMSwordSingle(:,[699 772]),2)]; % 386-458 ms
wordSingle(:,6)=[mean(SZRMSwordSingle(:,[953 1116]),2);mean(conRMSwordSingle(:,[916 1079]),2)]; % 600-760 ms

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
h1 = bar([mean(wordSingle(1:14,1)),mean(wordFirst(1:14,1)),mean(wordSecond(1:14,1));...
    mean(nonWordSingle(1:14,1)),mean(nonWordFirst(1:14,1)),mean(nonWordSecond(1:14,1))]);
title('RMS SZ Comp1');
ylabel('RMS*10^14');
ylim([0 30]);
set(h1(1), 'facecolor', [0 0 1]);
set(h1(2), 'facecolor', [1 0 0]);
set(h1(3), 'facecolor', [0 1 0]);
set(gca, 'XTickLabel', {'Word','Non Word'});
legend('Single','First','Second');

subplot(2,1,2)
h2 = bar([mean(wordSingle(15:30,1)),mean(wordFirst(15:30,1)),mean(wordSecond(15:30,1));...
    mean(nonWordSingle(15:30,1)),mean(nonWordFirst(15:30,1)),mean(nonWordSecond(15:30,1))]);
title('RMS Con Comp1');
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
h=bar([mean(wordSingle(:,1)) mean(nonWordSingle(:,1))]);
xlim([0 3]);
ylim([0 30]);

figure
subplot(2,1,1)
plot([1 2],[mean(wordFirst(1:14,1)),mean(wordSecond(1:14,1))],'w--o');
xlim([0.8 2.2])
ylim([15 30])
hold on;
plot([1 2],[mean(nonWordFirst(1:14,1)),mean(nonWordSecond(1:14,1))],'g--o');

subplot(2,1,2)
plot([1 2],[mean(wordFirst(15:30,1)),mean(wordSecond(15:30,1))],'w--o');
xlim([0.8 2.2])
ylim([15 30])
hold on;
plot([1 2],[mean(nonWordFirst(15:30,1)),mean(nonWordSecond(15:30,1))],'g--o');

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

figure
subplot(2,1,1)
plot([1 2],[mean(wordFirst(1:15,5)),mean(wordSecond(1:15,5))],'w--o');
xlim([0.8 2.2])
ylim([6 16])
hold on;
plot([1 2],[mean(nonWordFirst(1:15,5)),mean(nonWordSecond(1:15,5))],'g--o');

subplot(2,1,2)
plot([1 2],[mean(wordFirst(16:30,5)),mean(wordSecond(16:30,5))],'w--o');
xlim([0.8 2.2])
ylim([19 25])
hold on;
plot([1 2],[mean(nonWordFirst(16:30,5)),mean(nonWordSecond(16:30,5))],'g--o');

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

%% SAMerf
% ------------- 8< ------------- 8< ------------------ 8< ---------------------
%% 1. creating marker files for all subs (do it once!)
for i = [0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1']);
    load datafinal;
    
    trials = datafinal.trialinfo(datafinal.trialinfo(:,4)==1,1);
    samples = datafinal.sampleinfo(datafinal.trialinfo(:,4)==1,1);
    
    wordSingle=[((samples(trials == 110)+509)./1017.25)', ((samples(trials == 120)+509)./1017.25)'];
    wordFirst=[((samples(trials == 140)+509)./1017.25)', ((samples(trials == 150)+509)./1017.25)'];
    wordSecond=[((samples(trials == 160)+509)./1017.25)', ((samples(trials == 170)+509)./1017.25)'];
    nonWordSingle=((samples(trials == 130)+509)./1017.25)';
    nonWordFirst=((samples(trials == 180)+509)./1017.25)';
    nonWordSecond=((samples(trials == 190)+509)./1017.25)';
    All=((samples+509)./1017.25)';
    
    Trig2mark('All',All,'wordSingle',wordSingle,'wordFirst',wordFirst,'wordSecond',wordSecond,'nonWordSingle',nonWordSingle,'nonWordFirst',nonWordFirst,'nonWordSecond',nonWordSecond);
    clear trials samples All wordSingle wordFirst wordSecond nonWordSingle nonWordFirst nonWordSecond
    disp(i);
end

%% 2. fit MRI to HS
% using template MRI:
for i = [0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1']);
    if exist('c,rfhp0.1Hz', 'file')
        fitMRI2hs('c,rfhp0.1Hz');
    elseif exist('xc,hb,lf_c,rfhp0.1Hz', 'file')
        fitMRI2hs('xc,hb,lf_c,rfhp0.1Hz');
    end
    hs2afni()
end

% Nudging:
% ------------
% 2.1. from the terminal open afni and define: overlay = hs, underlay =
% warped
% 2.2. go to Define datamode > plugins > nudge dataset
% 2.3. click on "choose dataset" and choose "warped"
% 2.4. now nudge. When you are done type "do all" and then quit.
% 2.5 creating a tlrc file: in the terminal type: 
% @auto_tlrc -base ~/SAM_BIU/docs/temp+tlrc -input warped+orig -no_ss
% -------------------------------------------------------------------------
%% 3. creating param file (do it once!!)
cd /home/meg/Data/Maor/SchizoProject/Subjects
createPARAM('all4covWord','ERF','All',[0 0.8],'All',[-0.3 0],[1 40],[-0.3 0.8]); 
% because I create the VSs in MATLAB only the segment window [-0.3 0.8] is
% important.
% now go into the param file and change Nolte to MultiSphere (because I don't have individual MRIs)!!!!
% because my subjects have subfolders I need to copy the paramfile into
% each subject's main folder
% -------------------------------------------------------------------------
%% 4. SAMcov,wts,erf
a=1;
for i=[0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),]);
    !SAMcov64 -r 1 -d xc,hb,lf_c,rfhp0.1Hz -m all4covWord -v
    !SAMwts64 -r 1 -d xc,hb,lf_c,rfhp0.1Hz -m all4covWord -c Alla -v
    disp('*********************');
    disp(['      sub ',num2str(a),'/30']);
    disp('*********************');
    a=a+1;
end
% "Alla" and not "All" because it adds and 'a' to the file name for some reason

% reading the weights
clear all
a=1;
wtsNoSuf='SAM/all4covWord,1-40Hz,Alla';
for i=[0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1']);
    [~, ~, ActWgts]=readWeights([wtsNoSuf,'.wts']); % it takes a while
    save([wtsNoSuf,'.mat'], 'ActWgts'); % save in mat format, quicker to read later.
    clear ActWgts
    disp(i);
end
%--------------------------------------------------
%% 5. creating virtual sensors
clear all
compTime = [377 418; 428 499; 548 611; 627 678; 699 772; 916 1079];
a=1;
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
for i=[0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1']);
    % noise estimation
    load averagedataERF
    load 'SAM/all4covWord,1-40Hz,Alla'
    if i==37
        ActWgts(:,[84 216])=[]; % deleting channs A41 and A212
    end
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);
    for j=1:6 % 6 comps
        % get toi mean square (different than SAMerf, no BL correction
        eval(['vsWordSingleComp',num2str(j),'=ActWgts*sub',num2str(i),'wordSingle.avg(:,compTime(j,1):compTime(j,2));']);
        eval(['vsNonWordSingleComp',num2str(j),'=ActWgts*sub',num2str(i),'nonWordSingle.avg(:,compTime(j,1):compTime(j,2));']);
        eval(['vsWordFirstComp',num2str(j),'=ActWgts*sub',num2str(i),'wordFirst.avg(:,compTime(j,1):compTime(j,2));']);
        eval(['vsNonWordFirstComp',num2str(j),'=ActWgts*sub',num2str(i),'nonWordFirst.avg(:,compTime(j,1):compTime(j,2));']);
        eval(['vsWordSecondComp',num2str(j),'=ActWgts*sub',num2str(i),'wordSecond.avg(:,compTime(j,1):compTime(j,2));']);
        eval(['vsNonWordSecondComp',num2str(j),'=ActWgts*sub',num2str(i),'nonWordSecond.avg(:,compTime(j,1):compTime(j,2));']);
        % get MS
        eval(['vsWordSingleComp',num2str(j),'MS=mean(vsWordSingleComp',num2str(j),'.*vsWordSingleComp',num2str(j),',2)./ns;']);
        eval(['vsNonWordSingleComp',num2str(j),'MS=mean(vsNonWordSingleComp',num2str(j),'.*vsNonWordSingleComp',num2str(j),',2)./ns;']);
        eval(['vsWordFirstComp',num2str(j),'MS=mean(vsWordFirstComp',num2str(j),'.*vsWordFirstComp',num2str(j),',2)./ns;']);
        eval(['vsNonWordFirstComp',num2str(j),'MS=mean(vsNonWordFirstComp',num2str(j),'.*vsNonWordFirstComp',num2str(j),',2)./ns;']);
        eval(['vsWordSecondComp',num2str(j),'MS=mean(vsWordSecondComp',num2str(j),'.*vsWordSecondComp',num2str(j),',2)./ns;']);
        eval(['vsNonWordSecondComp',num2str(j),'MS=mean(vsNonWordSecondComp',num2str(j),'.*vsNonWordSecondComp',num2str(j),',2)./ns;']);
        % 10^25 is rescaling the data so it won't be so small
        eval(['vsWordSingleComp',num2str(j),'MS=vsWordSingleComp',num2str(j),'MS.*10^25;']); 
        eval(['vsNonWordSingleComp',num2str(j),'MS=vsNonWordSingleComp',num2str(j),'MS.*10^25;']); 
        eval(['vsWordFirstComp',num2str(j),'MS=vsWordFirstComp',num2str(j),'MS.*10^25;']); 
        eval(['vsNonWordFirstComp',num2str(j),'MS=vsNonWordFirstComp',num2str(j),'MS.*10^25;']); 
        eval(['vsWordSecondComp',num2str(j),'MS=vsWordSecondComp',num2str(j),'MS.*10^25;']); 
        eval(['vsNonWordSecondComp',num2str(j),'MS=vsNonWordSecondComp',num2str(j),'MS.*10^25;']); 
        % get rid of nans
        eval(['vsWordSingleComp',num2str(j),'MS(isnan(vsWordSingleComp',num2str(j),'MS))=0;']);
        eval(['vsNonWordSingleComp',num2str(j),'MS(isnan(vsNonWordSingleComp',num2str(j),'MS))=0;']);
        eval(['vsWordFirstComp',num2str(j),'MS(isnan(vsWordFirstComp',num2str(j),'MS))=0;']);
        eval(['vsNonWordFirstComp',num2str(j),'MS(isnan(vsNonWordFirstComp',num2str(j),'MS))=0;']);
        eval(['vsWordSecondComp',num2str(j),'MS(isnan(vsWordSecondComp',num2str(j),'MS))=0;']);
        eval(['vsNonWordSecondComp',num2str(j),'MS(isnan(vsNonWordSecondComp',num2str(j),'MS))=0;']);
        %make image 3D of mean square (MS, power)
        eval(['cfg.prefix=''wordSingleComp',num2str(j),''';']);
        eval(['VS2Brik(cfg,vsWordSingleComp',num2str(j),'MS);']);
        eval(['cfg.prefix=''nonWordSingleComp',num2str(j),''';']);
        eval(['VS2Brik(cfg,vsNonWordSingleComp',num2str(j),'MS);']);
        eval(['cfg.prefix=''wordFirstComp',num2str(j),''';']);
        eval(['VS2Brik(cfg,vsWordFirstComp',num2str(j),'MS);']);
        eval(['cfg.prefix=''nonWordFirstComp',num2str(j),''';']);
        eval(['VS2Brik(cfg,vsNonWordFirstComp',num2str(j),'MS);']);
        eval(['cfg.prefix=''wordSecondComp',num2str(j),''';']);
        eval(['VS2Brik(cfg,vsWordSecondComp',num2str(j),'MS);']);
        eval(['cfg.prefix=''nonWordSecondComp',num2str(j),''';']);
        eval(['VS2Brik(cfg,vsNonWordSecondComp',num2str(j),'MS);']);
    end
    disp(' ');
    disp('*********************');
    disp(['      sub ',num2str(a),'/30']);
    disp('*********************');
    disp(' ');
    a=a+1;
    
    clear j ns ActWgts
    clear vsNonWordFirstComp1 vsNonWordFirstComp1MS vsNonWordSecondComp1 vsNonWordSecondComp1MS vsNonWordSingleComp1 vsNonWordSingleComp1MS
    clear vsWordFirstComp1 vsWordFirstComp1MS vsWordSecondComp1 vsWordSecondComp1MS vsWordSingleComp1 vsWordSingleComp1MS
    clear vsNonWordFirstComp2 vsNonWordFirstComp2MS vsNonWordSecondComp2 vsNonWordSecondComp2MS vsNonWordSingleComp2 vsNonWordSingleComp2MS
    clear vsWordFirstComp2 vsWordFirstComp2MS vsWordSecondComp2 vsWordSecondComp2MS vsWordSingleComp2 vsWordSingleComp2MS
    clear vsNonWordFirstComp3 vsNonWordFirstComp3MS vsNonWordSecondComp3 vsNonWordSecondComp3MS vsNonWordSingleComp3 vsNonWordSingleComp3MS
    clear vsWordFirstComp3 vsWordFirstComp3MS vsWordSecondComp3 vsWordSecondComp3MS vsWordSingleComp3 vsWordSingleComp3MS
    clear vsNonWordFirstComp4 vsNonWordFirstComp4MS vsNonWordSecondComp4 vsNonWordSecondComp4MS vsNonWordSingleComp4 vsNonWordSingleComp4MS
    clear vsWordFirstComp4 vsWordFirstComp4MS vsWordSecondComp4 vsWordSecondComp4MS vsWordSingleComp4 vsWordSingleComp4MS
    clear vsNonWordFirstComp5 vsNonWordFirstComp5MS vsNonWordSecondComp5 vsNonWordSecondComp5MS vsNonWordSingleComp5 vsNonWordSingleComp5MS
    clear vsWordFirstComp5 vsWordFirstComp5MS vsWordSecondComp5 vsWordSecondComp5MS vsWordSingleComp5 vsWordSingleComp5MS
    clear vsNonWordFirstComp6 vsNonWordFirstComp6MS vsNonWordSecondComp6 vsNonWordSecondComp6MS vsNonWordSingleComp6 vsNonWordSingleComp6MS
    clear vsWordFirstComp6 vsWordFirstComp6MS vsWordSecondComp6 vsWordSecondComp6MS vsWordSingleComp6 vsWordSingleComp6MS
    eval(['clear sub',num2str(i),'all sub',num2str(i),'nonWordFirst sub',num2str(i),'nonWordSecond sub',num2str(i),'nonWordSingle']);
    eval(['clear sub',num2str(i),'wordFirst sub',num2str(i),'wordSecond sub',num2str(i),'wordSingle']);
end
clear all
%% 6. moving files to tlrc and moving them into a folder
% now open a terminal and type:
a=1;
for i=[0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1']);
    mkdir SAM_1_40Hz
    for j=1:6
          eval(['!@auto_tlrc -apar warped+tlrc -input wordSingleComp',num2str(j),'+orig -dxyz 5']);
          eval(['!@auto_tlrc -apar warped+tlrc -input nonWordSingleComp',num2str(j),'+orig -dxyz 5']);
          eval(['!@auto_tlrc -apar warped+tlrc -input wordFirstComp',num2str(j),'+orig -dxyz 5']);
          eval(['!@auto_tlrc -apar warped+tlrc -input nonWordFirstComp',num2str(j),'+orig -dxyz 5']);
          eval(['!@auto_tlrc -apar warped+tlrc -input wordSecondComp',num2str(j),'+orig -dxyz 5']);
          eval(['!@auto_tlrc -apar warped+tlrc -input nonWordSecondComp',num2str(j),'+orig -dxyz 5']);
          eval(['movefile(''*Comp',num2str(j),'+orig*'', ''SAM_1_40Hz'')']);
          eval(['movefile(''*Comp',num2str(j),'+tlrc*'', ''SAM_1_40Hz'')']);
    end
    disp(' ');
    disp('*********************');
    disp(['      sub ',num2str(a),'/30']);
    disp('*********************');
    disp(' ');
    a=a+1;
end
%% 7. 3dMVM and mask
% run 3dMVM
cd /home/meg/Data/Maor/SchizoProject/wordNoWord
masktlrc('3dMVM_Single_Comp1+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dMVM_Single_Comp2+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dMVM_Single_Comp3+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dMVM_Single_Comp4+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dMVM_Single_Comp5+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dMVM_Single_Comp6+tlrc','MASKctx+tlrc','_ctx');
% the 3dMVM for the Repeat doesn't need masking because it was done on
% masked files.
%% permutation test
% first, let's mask the cortex for each sub
for j=1:6
    for i=[0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
        eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/SAM_1_40Hz']);
        eval(['masktlrc(''wordSingleComp',num2str(j),'+tlrc'',''MASKctx+tlrc'',''_ctx'');']);
        eval(['masktlrc(''nonWordSingleComp',num2str(j),'+tlrc'',''MASKctx+tlrc'',''_ctx'');']);
        eval(['masktlrc(''wordFirstComp',num2str(j),'+tlrc'',''MASKctx+tlrc'',''_ctx'');']);
        eval(['masktlrc(''wordSecondComp',num2str(j),'+tlrc'',''MASKctx+tlrc'',''_ctx'');']);
        eval(['masktlrc(''nonWordFirstComp',num2str(j),'+tlrc'',''MASKctx+tlrc'',''_ctx'');']);
        eval(['masktlrc(''nonWordSecondComp',num2str(j),'+tlrc'',''MASKctx+tlrc'',''_ctx'');']);
    end
end

%% for the Single
clear all
cd /home/meg/Data/Maor/SchizoProject/wordNoWord/permutations
conds = {'word', 'nonWord'};
grp = {'con','con','con','con','con','con','con','con','con','con','con','con','con','con','con','con','sz','sz','sz','sz',...
    'sz','sz','sz','sz','sz','sz','sz','sz','sz','sz'};
% for comp1
for i = 1:340
    [~,grpIndx]=sort(rand(1,30));
    [~,condIndx]=sort(rand(2,30));
    
    eval(['!echo "3dMVM -prefix comp1singlePremut',num2str(i),' -jobs 6 -model group -wsVars wordNonWord -num_glt 0 '...
    '-dataTable Subj group wordNonWord InputFile '...
    'sub1 ',grp{grpIndx(1)},' ', conds{condIndx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', conds{condIndx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', conds{condIndx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', conds{condIndx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', conds{condIndx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', conds{condIndx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', conds{condIndx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', conds{condIndx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', conds{condIndx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', conds{condIndx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', conds{condIndx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', conds{condIndx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', conds{condIndx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', conds{condIndx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', conds{condIndx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', conds{condIndx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', conds{condIndx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', conds{condIndx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', conds{condIndx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', conds{condIndx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', conds{condIndx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', conds{condIndx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', conds{condIndx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', conds{condIndx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', conds{condIndx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', conds{condIndx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', conds{condIndx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', conds{condIndx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', conds{condIndx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', conds{condIndx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', conds{condIndx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', conds{condIndx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', conds{condIndx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', conds{condIndx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', conds{condIndx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', conds{condIndx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', conds{condIndx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', conds{condIndx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', conds{condIndx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', conds{condIndx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', conds{condIndx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', conds{condIndx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', conds{condIndx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', conds{condIndx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(24)},' ', conds{condIndx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(24)},' ', conds{condIndx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc" >> mvmPermutComp1A']);
end

for i = 341:680
    [~,grpIndx]=sort(rand(1,30));
    [~,condIndx]=sort(rand(2,30));
    
    eval(['!echo "3dMVM -prefix comp1singlePremut',num2str(i),' -jobs 6 -model group -wsVars wordNonWord -num_glt 0 '...
    '-dataTable Subj group wordNonWord InputFile '...
    'sub1 ',grp{grpIndx(1)},' ', conds{condIndx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', conds{condIndx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', conds{condIndx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', conds{condIndx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', conds{condIndx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', conds{condIndx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', conds{condIndx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', conds{condIndx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', conds{condIndx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', conds{condIndx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', conds{condIndx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', conds{condIndx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', conds{condIndx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', conds{condIndx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', conds{condIndx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', conds{condIndx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', conds{condIndx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', conds{condIndx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', conds{condIndx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', conds{condIndx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', conds{condIndx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', conds{condIndx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', conds{condIndx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', conds{condIndx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', conds{condIndx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', conds{condIndx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', conds{condIndx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', conds{condIndx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', conds{condIndx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', conds{condIndx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', conds{condIndx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', conds{condIndx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', conds{condIndx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', conds{condIndx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', conds{condIndx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', conds{condIndx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', conds{condIndx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', conds{condIndx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', conds{condIndx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', conds{condIndx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', conds{condIndx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', conds{condIndx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', conds{condIndx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', conds{condIndx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(24)},' ', conds{condIndx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(24)},' ', conds{condIndx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc" >> mvmPermutComp1B']);
end

for i = 681:1000
    [~,grpIndx]=sort(rand(1,30));
    [~,condIndx]=sort(rand(2,30));
    
    eval(['!echo "3dMVM -prefix comp1singlePremut',num2str(i),' -jobs 6 -model group -wsVars wordNonWord -num_glt 0 '...
    '-dataTable Subj group wordNonWord InputFile '...
    'sub1 ',grp{grpIndx(1)},' ', conds{condIndx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', conds{condIndx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', conds{condIndx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', conds{condIndx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', conds{condIndx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', conds{condIndx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', conds{condIndx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', conds{condIndx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', conds{condIndx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', conds{condIndx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', conds{condIndx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', conds{condIndx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', conds{condIndx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', conds{condIndx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', conds{condIndx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', conds{condIndx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', conds{condIndx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', conds{condIndx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', conds{condIndx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', conds{condIndx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', conds{condIndx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', conds{condIndx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', conds{condIndx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', conds{condIndx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', conds{condIndx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', conds{condIndx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', conds{condIndx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', conds{condIndx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', conds{condIndx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', conds{condIndx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', conds{condIndx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', conds{condIndx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', conds{condIndx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', conds{condIndx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', conds{condIndx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', conds{condIndx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', conds{condIndx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', conds{condIndx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', conds{condIndx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', conds{condIndx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', conds{condIndx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', conds{condIndx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', conds{condIndx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', conds{condIndx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(23)},' ', conds{condIndx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(23)},' ', conds{condIndx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(24)},' ', conds{condIndx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordSingleComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(24)},' ', conds{condIndx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordSingleComp1_ctx+tlrc" >> mvmPermutComp1C']);
end
%% For the Repeat
clear all
cd /home/meg/Data/Maor/SchizoProject/wordNoWord/permutations
condA = {'first', 'second'};
condB = {'word', 'nonWord'};
grp = {'con','con','con','con','con','con','con','con','con','con','con','con','con','con','con','con','sz','sz','sz','sz',...
    'sz','sz','sz','sz','sz','sz','sz','sz','sz','sz'};
% for comp1
for i = 1:340
    [~,grpIndx]=sort(rand(1,30));
    [~,condAindx]=sort(rand(2,30));
    [~,condBindx]=sort(rand(2,30));
    eval(['!echo "3dMVM -prefix comp1RepeatPermut',num2str(i),' -jobs 6 -model group -wsVars rep*wordNonWord -num_glt 0 '...
    '-dataTable Subj group rep wordNonWord InputFile '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(1,1)},' ', condB{condBindx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(1,1)},' ', condB{condBindx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(2,1)},' ', condB{condBindx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(2,1)},' ', condB{condBindx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(1,2)},' ', condB{condBindx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(1,2)},' ', condB{condBindx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(2,2)},' ', condB{condBindx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(2,2)},' ', condB{condBindx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(1,3)},' ', condB{condBindx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(1,3)},' ', condB{condBindx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(2,3)},' ', condB{condBindx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(2,3)},' ', condB{condBindx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(1,4)},' ', condB{condBindx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(1,4)},' ', condB{condBindx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(2,4)},' ', condB{condBindx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(2,4)},' ', condB{condBindx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(1,5)},' ', condB{condBindx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(1,5)},' ', condB{condBindx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(2,5)},' ', condB{condBindx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(2,5)},' ', condB{condBindx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(1,6)},' ', condB{condBindx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(1,6)},' ', condB{condBindx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(2,6)},' ', condB{condBindx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(2,6)},' ', condB{condBindx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(1,7)},' ', condB{condBindx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(1,7)},' ', condB{condBindx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(2,7)},' ', condB{condBindx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(2,7)},' ', condB{condBindx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(1,8)},' ', condB{condBindx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(1,8)},' ', condB{condBindx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(2,8)},' ', condB{condBindx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(2,8)},' ', condB{condBindx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(1,9)},' ', condB{condBindx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(1,9)},' ', condB{condBindx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(2,9)},' ', condB{condBindx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(2,9)},' ', condB{condBindx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(1,10)},' ', condB{condBindx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(1,10)},' ', condB{condBindx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(2,10)},' ', condB{condBindx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(2,10)},' ', condB{condBindx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(1,11)},' ', condB{condBindx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(1,11)},' ', condB{condBindx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(2,11)},' ', condB{condBindx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(2,11)},' ', condB{condBindx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(1,12)},' ', condB{condBindx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(1,12)},' ', condB{condBindx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(2,12)},' ', condB{condBindx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(2,12)},' ', condB{condBindx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...    
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(1,13)},' ', condB{condBindx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(1,13)},' ', condB{condBindx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(2,13)},' ', condB{condBindx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(2,13)},' ', condB{condBindx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(1,14)},' ', condB{condBindx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(1,14)},' ', condB{condBindx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(2,14)},' ', condB{condBindx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(2,14)},' ', condB{condBindx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(1,15)},' ', condB{condBindx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(1,15)},' ', condB{condBindx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(2,15)},' ', condB{condBindx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(2,15)},' ', condB{condBindx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(1,16)},' ', condB{condBindx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(1,16)},' ', condB{condBindx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(2,16)},' ', condB{condBindx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(2,16)},' ', condB{condBindx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(1,17)},' ', condB{condBindx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(1,17)},' ', condB{condBindx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(2,17)},' ', condB{condBindx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(2,17)},' ', condB{condBindx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(1,18)},' ', condB{condBindx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(1,18)},' ', condB{condBindx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(2,18)},' ', condB{condBindx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(2,18)},' ', condB{condBindx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(1,19)},' ', condB{condBindx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(1,19)},' ', condB{condBindx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(2,19)},' ', condB{condBindx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(2,19)},' ', condB{condBindx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(1,20)},' ', condB{condBindx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(1,20)},' ', condB{condBindx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(2,20)},' ', condB{condBindx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(2,20)},' ', condB{condBindx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(1,21)},' ', condB{condBindx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(1,21)},' ', condB{condBindx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(2,21)},' ', condB{condBindx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(2,21)},' ', condB{condBindx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(1,22)},' ', condB{condBindx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(1,22)},' ', condB{condBindx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(2,22)},' ', condB{condBindx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(2,22)},' ', condB{condBindx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(1,23)},' ', condB{condBindx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(1,23)},' ', condB{condBindx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(2,23)},' ', condB{condBindx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(2,23)},' ', condB{condBindx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(1,24)},' ', condB{condBindx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(1,24)},' ', condB{condBindx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(2,24)},' ', condB{condBindx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(2,24)},' ', condB{condBindx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(1,25)},' ', condB{condBindx(1,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(1,25)},' ', condB{condBindx(2,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(2,25)},' ', condB{condBindx(1,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(2,25)},' ', condB{condBindx(2,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(1,26)},' ', condB{condBindx(1,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(1,26)},' ', condB{condBindx(2,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(2,26)},' ', condB{condBindx(1,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(2,26)},' ', condB{condBindx(2,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(1,27)},' ', condB{condBindx(1,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(1,27)},' ', condB{condBindx(2,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(2,27)},' ', condB{condBindx(1,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(2,27)},' ', condB{condBindx(2,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(1,28)},' ', condB{condBindx(1,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(1,28)},' ', condB{condBindx(2,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(2,28)},' ', condB{condBindx(1,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(2,28)},' ', condB{condBindx(2,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(1,29)},' ', condB{condBindx(1,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(1,29)},' ', condB{condBindx(2,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(2,29)},' ', condB{condBindx(1,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(2,29)},' ', condB{condBindx(2,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(1,30)},' ', condB{condBindx(1,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(1,30)},' ', condB{condBindx(2,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(2,30)},' ', condB{condBindx(1,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(2,30)},' ', condB{condBindx(2,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc" >> RepeatPermutComp1A']);
end

for i = 341:680
    [~,grpIndx]=sort(rand(1,30));
    [~,condAindx]=sort(rand(2,30));
    [~,condBindx]=sort(rand(2,30));
    eval(['!echo "3dMVM -prefix comp1RepeatPermut',num2str(i),' -jobs 6 -model group -wsVars rep*wordNonWord -num_glt 0 '...
    '-dataTable Subj group rep wordNonWord InputFile '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(1,1)},' ', condB{condBindx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(1,1)},' ', condB{condBindx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(2,1)},' ', condB{condBindx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(2,1)},' ', condB{condBindx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(1,2)},' ', condB{condBindx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(1,2)},' ', condB{condBindx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(2,2)},' ', condB{condBindx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(2,2)},' ', condB{condBindx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(1,3)},' ', condB{condBindx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(1,3)},' ', condB{condBindx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(2,3)},' ', condB{condBindx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(2,3)},' ', condB{condBindx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(1,4)},' ', condB{condBindx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(1,4)},' ', condB{condBindx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(2,4)},' ', condB{condBindx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(2,4)},' ', condB{condBindx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(1,5)},' ', condB{condBindx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(1,5)},' ', condB{condBindx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(2,5)},' ', condB{condBindx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(2,5)},' ', condB{condBindx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(1,6)},' ', condB{condBindx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(1,6)},' ', condB{condBindx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(2,6)},' ', condB{condBindx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(2,6)},' ', condB{condBindx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(1,7)},' ', condB{condBindx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(1,7)},' ', condB{condBindx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(2,7)},' ', condB{condBindx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(2,7)},' ', condB{condBindx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(1,8)},' ', condB{condBindx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(1,8)},' ', condB{condBindx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(2,8)},' ', condB{condBindx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(2,8)},' ', condB{condBindx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(1,9)},' ', condB{condBindx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(1,9)},' ', condB{condBindx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(2,9)},' ', condB{condBindx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(2,9)},' ', condB{condBindx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(1,10)},' ', condB{condBindx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(1,10)},' ', condB{condBindx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(2,10)},' ', condB{condBindx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(2,10)},' ', condB{condBindx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(1,11)},' ', condB{condBindx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(1,11)},' ', condB{condBindx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(2,11)},' ', condB{condBindx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(2,11)},' ', condB{condBindx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(1,12)},' ', condB{condBindx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(1,12)},' ', condB{condBindx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(2,12)},' ', condB{condBindx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(2,12)},' ', condB{condBindx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...    
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(1,13)},' ', condB{condBindx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(1,13)},' ', condB{condBindx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(2,13)},' ', condB{condBindx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(2,13)},' ', condB{condBindx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(1,14)},' ', condB{condBindx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(1,14)},' ', condB{condBindx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(2,14)},' ', condB{condBindx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(2,14)},' ', condB{condBindx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(1,15)},' ', condB{condBindx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(1,15)},' ', condB{condBindx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(2,15)},' ', condB{condBindx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(2,15)},' ', condB{condBindx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(1,16)},' ', condB{condBindx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(1,16)},' ', condB{condBindx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(2,16)},' ', condB{condBindx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(2,16)},' ', condB{condBindx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(1,17)},' ', condB{condBindx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(1,17)},' ', condB{condBindx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(2,17)},' ', condB{condBindx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(2,17)},' ', condB{condBindx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(1,18)},' ', condB{condBindx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(1,18)},' ', condB{condBindx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(2,18)},' ', condB{condBindx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(2,18)},' ', condB{condBindx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(1,19)},' ', condB{condBindx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(1,19)},' ', condB{condBindx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(2,19)},' ', condB{condBindx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(2,19)},' ', condB{condBindx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(1,20)},' ', condB{condBindx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(1,20)},' ', condB{condBindx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(2,20)},' ', condB{condBindx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(2,20)},' ', condB{condBindx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(1,21)},' ', condB{condBindx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(1,21)},' ', condB{condBindx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(2,21)},' ', condB{condBindx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(2,21)},' ', condB{condBindx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(1,22)},' ', condB{condBindx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(1,22)},' ', condB{condBindx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(2,22)},' ', condB{condBindx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(2,22)},' ', condB{condBindx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(1,23)},' ', condB{condBindx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(1,23)},' ', condB{condBindx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(2,23)},' ', condB{condBindx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(2,23)},' ', condB{condBindx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(1,24)},' ', condB{condBindx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(1,24)},' ', condB{condBindx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(2,24)},' ', condB{condBindx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(2,24)},' ', condB{condBindx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(1,25)},' ', condB{condBindx(1,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(1,25)},' ', condB{condBindx(2,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(2,25)},' ', condB{condBindx(1,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(2,25)},' ', condB{condBindx(2,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(1,26)},' ', condB{condBindx(1,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(1,26)},' ', condB{condBindx(2,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(2,26)},' ', condB{condBindx(1,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(2,26)},' ', condB{condBindx(2,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(1,27)},' ', condB{condBindx(1,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(1,27)},' ', condB{condBindx(2,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(2,27)},' ', condB{condBindx(1,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(2,27)},' ', condB{condBindx(2,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(1,28)},' ', condB{condBindx(1,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(1,28)},' ', condB{condBindx(2,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(2,28)},' ', condB{condBindx(1,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(2,28)},' ', condB{condBindx(2,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(1,29)},' ', condB{condBindx(1,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(1,29)},' ', condB{condBindx(2,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(2,29)},' ', condB{condBindx(1,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(2,29)},' ', condB{condBindx(2,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(1,30)},' ', condB{condBindx(1,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(1,30)},' ', condB{condBindx(2,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(2,30)},' ', condB{condBindx(1,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(2,30)},' ', condB{condBindx(2,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc" >> RepeatPermutComp1B']);
end    

for i = 681:1000
    [~,grpIndx]=sort(rand(1,30));
    [~,condAindx]=sort(rand(2,30));
    [~,condBindx]=sort(rand(2,30));
    eval(['!echo "3dMVM -prefix comp1RepeatPermut',num2str(i),' -jobs 6 -model group -wsVars rep*wordNonWord -num_glt 0 '...
    '-dataTable Subj group rep wordNonWord InputFile '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(1,1)},' ', condB{condBindx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(1,1)},' ', condB{condBindx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(2,1)},' ', condB{condBindx(1,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub1 ',grp{grpIndx(1)},' ', condA{condAindx(2,1)},' ', condB{condBindx(2,1)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(1,2)},' ', condB{condBindx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(1,2)},' ', condB{condBindx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(2,2)},' ', condB{condBindx(1,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub2 ',grp{grpIndx(2)},' ', condA{condAindx(2,2)},' ', condB{condBindx(2,2)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa1/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(1,3)},' ', condB{condBindx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(1,3)},' ', condB{condBindx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(2,3)},' ', condB{condBindx(1,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub3 ',grp{grpIndx(3)},' ', condA{condAindx(2,3)},' ', condB{condBindx(2,3)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa2/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(1,4)},' ', condB{condBindx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(1,4)},' ', condB{condBindx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(2,4)},' ', condB{condBindx(1,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub4 ',grp{grpIndx(4)},' ', condA{condAindx(2,4)},' ', condB{condBindx(2,4)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa3/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(1,5)},' ', condB{condBindx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(1,5)},' ', condB{condBindx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(2,5)},' ', condB{condBindx(1,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub5 ',grp{grpIndx(5)},' ', condA{condAindx(2,5)},' ', condB{condBindx(2,5)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa5/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(1,6)},' ', condB{condBindx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(1,6)},' ', condB{condBindx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(2,6)},' ', condB{condBindx(1,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub6 ',grp{grpIndx(6)},' ', condA{condAindx(2,6)},' ', condB{condBindx(2,6)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa6/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(1,7)},' ', condB{condBindx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(1,7)},' ', condB{condBindx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(2,7)},' ', condB{condBindx(1,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub7 ',grp{grpIndx(7)},' ', condA{condAindx(2,7)},' ', condB{condBindx(2,7)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa7/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(1,8)},' ', condB{condBindx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(1,8)},' ', condB{condBindx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(2,8)},' ', condB{condBindx(1,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub8 ',grp{grpIndx(8)},' ', condA{condAindx(2,8)},' ', condB{condBindx(2,8)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa8/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(1,9)},' ', condB{condBindx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(1,9)},' ', condB{condBindx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(2,9)},' ', condB{condBindx(1,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub9 ',grp{grpIndx(9)},' ', condA{condAindx(2,9)},' ', condB{condBindx(2,9)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa9/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(1,10)},' ', condB{condBindx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(1,10)},' ', condB{condBindx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(2,10)},' ', condB{condBindx(1,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub10 ',grp{grpIndx(10)},' ', condA{condAindx(2,10)},' ', condB{condBindx(2,10)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa12/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(1,11)},' ', condB{condBindx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(1,11)},' ', condB{condBindx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(2,11)},' ', condB{condBindx(1,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub11 ',grp{grpIndx(11)},' ', condA{condAindx(2,11)},' ', condB{condBindx(2,11)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa14/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(1,12)},' ', condB{condBindx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(1,12)},' ', condB{condBindx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(2,12)},' ', condB{condBindx(1,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub12 ',grp{grpIndx(12)},' ', condA{condAindx(2,12)},' ', condB{condBindx(2,12)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa15/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...    
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(1,13)},' ', condB{condBindx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(1,13)},' ', condB{condBindx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(2,13)},' ', condB{condBindx(1,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub13 ',grp{grpIndx(13)},' ', condA{condAindx(2,13)},' ', condB{condBindx(2,13)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa16/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(1,14)},' ', condB{condBindx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(1,14)},' ', condB{condBindx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(2,14)},' ', condB{condBindx(1,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub14 ',grp{grpIndx(14)},' ', condA{condAindx(2,14)},' ', condB{condBindx(2,14)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa17/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(1,15)},' ', condB{condBindx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(1,15)},' ', condB{condBindx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(2,15)},' ', condB{condBindx(1,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub15 ',grp{grpIndx(15)},' ', condA{condAindx(2,15)},' ', condB{condBindx(2,15)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa19/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(1,16)},' ', condB{condBindx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(1,16)},' ', condB{condBindx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(2,16)},' ', condB{condBindx(1,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub16 ',grp{grpIndx(16)},' ', condA{condAindx(2,16)},' ', condB{condBindx(2,16)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa20/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(1,17)},' ', condB{condBindx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(1,17)},' ', condB{condBindx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(2,17)},' ', condB{condBindx(1,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub17 ',grp{grpIndx(17)},' ', condA{condAindx(2,17)},' ', condB{condBindx(2,17)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa21/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(1,18)},' ', condB{condBindx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(1,18)},' ', condB{condBindx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(2,18)},' ', condB{condBindx(1,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub18 ',grp{grpIndx(18)},' ', condA{condAindx(2,18)},' ', condB{condBindx(2,18)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa23/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(1,19)},' ', condB{condBindx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(1,19)},' ', condB{condBindx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(2,19)},' ', condB{condBindx(1,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub19 ',grp{grpIndx(19)},' ', condA{condAindx(2,19)},' ', condB{condBindx(2,19)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa25/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(1,20)},' ', condB{condBindx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(1,20)},' ', condB{condBindx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(2,20)},' ', condB{condBindx(1,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub20 ',grp{grpIndx(20)},' ', condA{condAindx(2,20)},' ', condB{condBindx(2,20)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa27/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(1,21)},' ', condB{condBindx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(1,21)},' ', condB{condBindx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(2,21)},' ', condB{condBindx(1,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub21 ',grp{grpIndx(21)},' ', condA{condAindx(2,21)},' ', condB{condBindx(2,21)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa28/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(1,22)},' ', condB{condBindx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(1,22)},' ', condB{condBindx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(2,22)},' ', condB{condBindx(1,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub22 ',grp{grpIndx(22)},' ', condA{condAindx(2,22)},' ', condB{condBindx(2,22)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa31/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(1,23)},' ', condB{condBindx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(1,23)},' ', condB{condBindx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(2,23)},' ', condB{condBindx(1,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub23 ',grp{grpIndx(23)},' ', condA{condAindx(2,23)},' ', condB{condBindx(2,23)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa32/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(1,24)},' ', condB{condBindx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(1,24)},' ', condB{condBindx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(2,24)},' ', condB{condBindx(1,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub24 ',grp{grpIndx(24)},' ', condA{condAindx(2,24)},' ', condB{condBindx(2,24)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa33/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(1,25)},' ', condB{condBindx(1,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(1,25)},' ', condB{condBindx(2,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(2,25)},' ', condB{condBindx(1,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub25 ',grp{grpIndx(25)},' ', condA{condAindx(2,25)},' ', condB{condBindx(2,25)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa34/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(1,26)},' ', condB{condBindx(1,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(1,26)},' ', condB{condBindx(2,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(2,26)},' ', condB{condBindx(1,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub26 ',grp{grpIndx(26)},' ', condA{condAindx(2,26)},' ', condB{condBindx(2,26)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa35/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(1,27)},' ', condB{condBindx(1,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(1,27)},' ', condB{condBindx(2,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(2,27)},' ', condB{condBindx(1,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub27 ',grp{grpIndx(27)},' ', condA{condAindx(2,27)},' ', condB{condBindx(2,27)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa36/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(1,28)},' ', condB{condBindx(1,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(1,28)},' ', condB{condBindx(2,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(2,28)},' ', condB{condBindx(1,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub28 ',grp{grpIndx(28)},' ', condA{condAindx(2,28)},' ', condB{condBindx(2,28)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa37/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(1,29)},' ', condB{condBindx(1,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(1,29)},' ', condB{condBindx(2,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(2,29)},' ', condB{condBindx(1,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub29 ',grp{grpIndx(29)},' ', condA{condAindx(2,29)},' ', condB{condBindx(2,29)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa39/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(1,30)},' ', condB{condBindx(1,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordFirstComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(1,30)},' ', condB{condBindx(2,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordFirstComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(2,30)},' ', condB{condBindx(1,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/wordSecondComp1_ctx+tlrc '...
    'sub30 ',grp{grpIndx(30)},' ', condA{condAindx(2,30)},' ', condB{condBindx(2,30)},' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa41/1/SAM_1_40Hz/nonWordSecondComp1_ctx+tlrc" >> RepeatPermutComp1C']);
end

%% extracting the cluster sizes and F values for "Single"
cd /home/meg/Data/Maor/SchizoProject/wordNoWord/permutations/SingleComp1
for i=1:1000
    % read max F value - need to correct it and take F values only from
    % clusters bigger than 20 (let's say)!!!
    %eval(['!~/abin/3dBrickStat -max comp1premut',num2str(i),'_ctx+tlrc''[1]'' >> FmaxGrp.txt']);
    %eval(['!~/abin/3dBrickStat -max comp1premut',num2str(i),'_ctx+tlrc''[2]'' >> FmaxWrd.txt']);
    %eval(['!~/abin/3dBrickStat -max comp1premut',num2str(i),'_ctx+tlrc''[3]'' >> FmaxInt.txt']);
    
    % compute volume of largest positive clusters
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1singlePremut',num2str(i),'+tlrc''[1]''+tlrc > p05ClustGrp.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1singlePremut',num2str(i),'+tlrc''[2]''+tlrc > p05ClustWrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1singlePremut',num2str(i),'+tlrc''[3]''+tlrc > p05ClustInt.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1singlePremut',num2str(i),'+tlrc''[1]''+tlrc > p01ClustGrp.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1singlePremut',num2str(i),'+tlrc''[2]''+tlrc > p01ClustWrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1singlePremut',num2str(i),'+tlrc''[3]''+tlrc > p01ClustInt.txt'])
    p05ClustGrp=importdata('p05ClustGrp.txt');
    p05ClustWrd=importdata('p05ClustWrd.txt');
    p05ClustInt=importdata('p05ClustInt.txt');
    p01ClustGrp=importdata('p01ClustGrp.txt');
    p01ClustWrd=importdata('p01ClustWrd.txt');
    p01ClustInt=importdata('p01ClustInt.txt');
    if iscell(p05ClustGrp)
        p05ClustGrpSize=0;
    else
        p05ClustGrpSize=p05ClustGrp(1)/125;
    end
    if iscell(p05ClustWrd)
        p05ClustWrdSize=0;
    else
        p05ClustWrdSize=p05ClustWrd(1)/125;
    end  
    if iscell(p05ClustInt)
        p05ClustIntSize=0;
    else
        p05ClustIntSize=p05ClustInt(1)/125;
    end
    if iscell(p01ClustGrp)
        p01ClustGrpSize=0;
    else
        p01ClustGrpSize=p01ClustGrp(1)/125;
    end
    if iscell(p01ClustWrd)
        p01ClustWrdSize=0;
    else
        p01ClustWrdSize=p01ClustWrd(1)/125;
    end  
    if iscell(p01ClustInt)
        p01ClustIntSize=0;
    else
        p01ClustIntSize=p01ClustInt(1)/125;
    end
    clust05GrpSize(i)=p05ClustGrpSize;
    clust05WrdSize(i)=p05ClustWrdSize;
    clust05IntSize(i)=p05ClustIntSize;    
    clust01GrpSize(i)=p01ClustGrpSize;
    clust01WrdSize(i)=p01ClustWrdSize;
    clust01IntSize(i)=p01ClustIntSize;    
    !rm *ClustGrp.txt
    !rm *ClustWrd.txt
    !rm *ClustInt.txt
end

% find critical values
clust05GrpSize=sort(clust05GrpSize,'descend');
clust05WrdSize=sort(clust05WrdSize,'descend');
clust05IntSize=sort(clust05IntSize,'descend');
clust01GrpSize=sort(clust01GrpSize,'descend');
clust01WrdSize=sort(clust01WrdSize,'descend');
clust01IntSize=sort(clust01IntSize,'descend');
% FmaxGrp=importdata('FmaxGrp.txt');
% FmaxWrd=importdata('FmaxWrd.txt');
% FmaxInt=importdata('FmaxInt.txt');

% FmaxGrp=sort(FmaxGrp,'descend');
% FmaxWrd=sort(FmaxWrd,'descend');
% FmaxInt=sort(FmaxInt,'descend');

% FcritGrp = FmaxGrp(50);
% FcritWrd = FmaxWrd(50);
% FcritInt = FmaxInt(50);
clust05SizeCritGrp = [clust05GrpSize(50),clust05GrpSize(100)];
clust05SizeCritWrd = [clust05WrdSize(50),clust05WrdSize(100)];
clust05SizeCritInt = [clust05IntSize(50),clust05IntSize(100)];
clust01SizeCritGrp = [clust01GrpSize(50),clust01GrpSize(100)];
clust01SizeCritWrd = [clust01WrdSize(50),clust01WrdSize(100)];
clust01SizeCritInt = [clust01IntSize(50),clust01IntSize(100)];

save comp1permutCrit_Size_F clust05SizeCritGrp clust05SizeCritWrd clust05SizeCritInt clust01SizeCritGrp clust01SizeCritWrd clust01SizeCritInt

%!rm FmaxGrp.txt
%!rm FmaxWrd.txt
%!rm FmaxInt.txt

%% for "Repeat"
cd /home/meg/Data/Maor/SchizoProject/wordNoWord/permutations/RepeatComp1
for i=1:1000
    % read max F value - need to correct it and take F values only from
    % clusters bigger than 20 (let's say)!!!
    %eval(['!~/abin/3dBrickStat -max comp1premut',num2str(i),'_ctx+tlrc''[1]'' >> FmaxGrp.txt']);
    %eval(['!~/abin/3dBrickStat -max comp1premut',num2str(i),'_ctx+tlrc''[2]'' >> FmaxWrd.txt']);
    %eval(['!~/abin/3dBrickStat -max comp1premut',num2str(i),'_ctx+tlrc''[3]'' >> FmaxInt.txt']);
    
    % compute volume of largest positive clusters
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[1]''+tlrc > p05ClustGrp.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[2]''+tlrc > p05ClustRep.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[3]''+tlrc > p05ClustGrp_Rep.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[4]''+tlrc > p05ClustWrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[5]''+tlrc > p05ClustGrp_Wrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[6]''+tlrc > p05ClustRep_Wrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 4.198 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[7]''+tlrc > p05ClustGrp_Rep_Wrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[1]''+tlrc > p01ClustGrp.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[2]''+tlrc > p01ClustRep.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[3]''+tlrc > p01ClustGrp_Rep.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[4]''+tlrc > p01ClustWrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[5]''+tlrc > p01ClustGrp_Wrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[6]''+tlrc > p01ClustRep_Wrd.txt'])
    eval(['!~/abin/3dclust -quiet -1clip 7.648 5 125 comp1RepeatPermut',num2str(i),'+tlrc''[7]''+tlrc > p01ClustGrp_Rep_Wrd.txt'])
    p05ClustGrp=importdata('p05ClustGrp.txt');
    p05ClustRep=importdata('p05ClustRep.txt');
    p05ClustGrp_Rep=importdata('p05ClustGrp_Rep.txt');
    p05ClustWrd=importdata('p05ClustWrd.txt');
    p05ClustGrp_Wrd=importdata('p05ClustGrp_Wrd.txt');
    p05ClustRep_Wrd=importdata('p05ClustRep_Wrd.txt');
    p05ClustGrp_Rep_Wrd=importdata('p05ClustGrp_Rep_Wrd.txt');
    p01ClustGrp=importdata('p01ClustGrp.txt');
    p01ClustRep=importdata('p01ClustRep.txt');
    p01ClustGrp_Rep=importdata('p01ClustGrp_Rep.txt');
    p01ClustWrd=importdata('p01ClustWrd.txt');
    p01ClustGrp_Wrd=importdata('p01ClustGrp_Wrd.txt');
    p01ClustRep_Wrd=importdata('p01ClustRep_Wrd.txt');
    p01ClustGrp_Rep_Wrd=importdata('p01ClustGrp_Rep_Wrd.txt');
    % Grp p=05
    if iscell(p05ClustGrp)
        p05ClustGrpSize=0;
    else
        p05ClustGrpSize=p05ClustGrp(1)/125;
    end
    % Rep p=05
    if iscell(p05ClustRep)
        p05ClustRepSize=0;
    else
        p05ClustRepSize=p05ClustRep(1)/125;
    end  
    % Grp_Rep p=05
    if iscell(p05ClustGrp_Rep)
        p05ClustGrp_RepSize=0;
    else
        p05ClustGrp_RepSize=p05ClustGrp_Rep(1)/125;
    end
    % Wrd p=05
    if iscell(p05ClustWrd)
        p05ClustWrdSize=0;
    else
        p05ClustWrdSize=p05ClustWrd(1)/125;
    end
    % Grp_Wrd p=05
    if iscell(p05ClustGrp_Wrd)
        p05ClustGrp_WrdSize=0;
    else
        p05ClustGrp_WrdSize=p05ClustGrp_Wrd(1)/125;
    end
    % Rep_Wrd p=05
    if iscell(p05ClustRep_Wrd)
        p05ClustRep_WrdSize=0;
    else
        p05ClustRep_WrdSize=p05ClustRep_Wrd(1)/125;
    end
    % Grp_Rep_Wrd p=05
    if iscell(p05ClustGrp_Rep_Wrd)
        p05ClustGrp_Rep_WrdSize=0;
    else
        p05ClustGrp_Rep_WrdSize=p05ClustGrp_Rep_Wrd(1)/125;
    end
    
    % Grp p=01
    if iscell(p01ClustGrp)
        p01ClustGrpSize=0;
    else
        p01ClustGrpSize=p01ClustGrp(1)/125;
    end
    % Rep p=01
    if iscell(p01ClustRep)
        p01ClustRepSize=0;
    else
        p01ClustRepSize=p01ClustRep(1)/125;
    end  
    % Grp_Rep p=01
    if iscell(p01ClustGrp_Rep)
        p01ClustGrp_RepSize=0;
    else
        p01ClustGrp_RepSize=p01ClustGrp_Rep(1)/125;
    end
    % Wrd p=01
    if iscell(p01ClustWrd)
        p01ClustWrdSize=0;
    else
        p01ClustWrdSize=p01ClustWrd(1)/125;
    end
    % Grp_Wrd p=01
    if iscell(p01ClustGrp_Wrd)
        p01ClustGrp_WrdSize=0;
    else
        p01ClustGrp_WrdSize=p01ClustGrp_Wrd(1)/125;
    end
    % Rep_Wrd p=01
    if iscell(p01ClustRep_Wrd)
        p01ClustRep_WrdSize=0;
    else
        p01ClustRep_WrdSize=p01ClustRep_Wrd(1)/125;
    end
    % Grp_Rep_Wrd p=01
    if iscell(p01ClustGrp_Rep_Wrd)
        p01ClustGrp_Rep_WrdSize=0;
    else
        p01ClustGrp_Rep_WrdSize=p01ClustGrp_Rep_Wrd(1)/125;
    end
    
    clust05GrpSize(i)=p05ClustGrpSize;
    clust05RepSize(i)=p05ClustRepSize;
    clust05Grp_RepSize(i)=p05ClustGrp_RepSize;
    clust05WrdSize(i)=p05ClustWrdSize;
    clust05Grp_WrdSize(i)=p05ClustGrp_WrdSize;
    clust05Rep_WrdSize(i)=p05ClustRep_WrdSize;
    clust05Grp_Rep_WrdSize(i)=p05ClustGrp_Rep_WrdSize;
    clust01GrpSize(i)=p01ClustGrpSize;
    clust01RepSize(i)=p01ClustRepSize;
    clust01Grp_RepSize(i)=p01ClustGrp_RepSize;
    clust01WrdSize(i)=p01ClustWrdSize;
    clust01Grp_WrdSize(i)=p01ClustGrp_WrdSize;
    clust01Rep_WrdSize(i)=p01ClustRep_WrdSize;
    clust01Grp_Rep_WrdSize(i)=p01ClustGrp_Rep_WrdSize;
    !rm *ClustGrp.txt
    !rm *ClustRep.txt
    !rm *ClustGrp_Rep.txt
    !rm *ClustWrd.txt
    !rm *ClustGrp_Wrd.txt
    !rm *ClustRep_Wrd.txt
    !rm *ClustGrp_Rep_Wrd.txt
    disp(' ');
    disp('**********************');
    disp(i);
    disp('**********************');
    disp(' ');
end

% find critical values
clust05GrpSize=sort(clust05GrpSize,'descend');
clust05RepSize=sort(clust05RepSize,'descend');
clust05Grp_RepSize=sort(clust05Grp_RepSize,'descend');
clust05WrdSize=sort(clust05WrdSize,'descend');
clust05Grp_WrdSize=sort(clust05Grp_WrdSize,'descend');
clust05Rep_WrdSize=sort(clust05Rep_WrdSize,'descend');
clust05Grp_Rep_WrdSize=sort(clust05Grp_Rep_WrdSize,'descend');
clust01GrpSize=sort(clust01GrpSize,'descend');
clust01RepSize=sort(clust01RepSize,'descend');
clust01Grp_RepSize=sort(clust01Grp_RepSize,'descend');
clust01WrdSize=sort(clust01WrdSize,'descend');
clust01Grp_WrdSize=sort(clust01Grp_WrdSize,'descend');
clust01Rep_WrdSize=sort(clust01Rep_WrdSize,'descend');
clust01Grp_Rep_WrdSize=sort(clust01Grp_Rep_WrdSize,'descend');
% FmaxGrp=importdata('FmaxGrp.txt');
% FmaxWrd=importdata('FmaxWrd.txt');
% FmaxInt=importdata('FmaxInt.txt');

% FmaxGrp=sort(FmaxGrp,'descend');
% FmaxWrd=sort(FmaxWrd,'descend');
% FmaxInt=sort(FmaxInt,'descend');

% FcritGrp = FmaxGrp(50);
% FcritWrd = FmaxWrd(50);
% FcritInt = FmaxInt(50);
clust05SizeCritGrp = [clust05GrpSize(50),clust05GrpSize(100)];
clust05SizeCritRep = [clust05RepSize(50),clust05RepSize(100)];
clust05SizeCritGrp_Rep = [clust05Grp_RepSize(50),clust05Grp_RepSize(100)];
clust05SizeCritWrd = [clust05WrdSize(50),clust05WrdSize(100)];
clust05SizeCritGrp_Wrd = [clust05Grp_WrdSize(50),clust05Grp_WrdSize(100)];
clust05SizeCritRep_Wrd = [clust05Rep_WrdSize(50),clust05Rep_WrdSize(100)];
clust05SizeCritGrp_Rep_Wrd = [clust05Grp_Rep_WrdSize(50),clust05Grp_Rep_WrdSize(100)];
clust01SizeCritGrp = [clust01GrpSize(50),clust01GrpSize(100)];
clust01SizeCritRep = [clust01RepSize(50),clust01RepSize(100)];
clust01SizeCritGrp_Rep = [clust01Grp_RepSize(50),clust01Grp_RepSize(100)];
clust01SizeCritWrd = [clust01WrdSize(50),clust01WrdSize(100)];
clust01SizeCritGrp_Wrd = [clust01Grp_WrdSize(50),clust01Grp_WrdSize(100)];
clust01SizeCritRep_Wrd = [clust01Rep_WrdSize(50),clust01Rep_WrdSize(100)];
clust01SizeCritGrp_Rep_Wrd = [clust01Grp_Rep_WrdSize(50),clust01Grp_Rep_WrdSize(100)];

save comp1permutCrit_Size_F clust05SizeCritGrp clust05SizeCritRep clust05SizeCritGrp_Rep clust05SizeCritWrd clust05SizeCritGrp_Wrd clust05SizeCritRep_Wrd clust05SizeCritGrp_Rep_Wrd clust01SizeCritGrp clust01SizeCritRep clust01SizeCritGrp_Rep clust01SizeCritWrd clust01SizeCritGrp_Wrd clust01SizeCritRep_Wrd clust01SizeCritGrp_Rep_Wrd

%!rm FmaxGrp.txt
%!rm FmaxWrd.txt
%!rm FmaxInt.txt

%% Extracting the max voxels for post-hoc analysis and plots
%  ===============  for comp 1  =================
%% ---------------- For Single -----------------------------
% after creating the masks in Afni for each effect:
% extract the maximum values in each cluster for the group, semantic and interaction between the two
cd /home/meg/Data/Maor/SchizoProject/wordNoWord
clear all
!3dExtrema -prefix Clust20_Comp1_Single_Grp_ext -mask_file Clust20_Comp1_Single_Grp_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Single_Comp1_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_Comp1_Single_Wrd_ext -mask_file Clust20_Comp1_Single_Wrd_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Single_Comp1_ctx+tlrc'[2]'
!3dExtrema -prefix Clust20_Comp1_Single_Grp_Wrd_ext -mask_file Clust20_Comp1_Single_Grp_Wrd_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Single_Comp1_ctx+tlrc'[3]'

% extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Single_Grp_ext+tlrc > Clust20_xyzGrp_Single_Comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Single_Wrd_ext+tlrc > Clust20_xyzWrd_Single_Comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Single_Grp_Wrd_ext+tlrc > Clust20_xyzInt_Single_Comp1.txt

%% creating a matrix of all maximum values for all subs for all condition
%% 1. Group
% each subject power for each extreme voxel in the group effect
con = [0:3 5:9 12 15 20 32 36 39 41];
sz = [14 16 17 19 21 23 25 27 28 31 33:35 37];

voxGrp = importdata('Clust20_xyzGrp_Single_Comp1.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSingleComp1+tlrc > Clust20_Word_Single_Vals4Grp_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSingleComp1+tlrc > Clust20_NonWord_Single_Vals4Grp_Comp1.txt']);

        val = importdata('Clust20_Word_Single_Vals4Grp_Comp1.txt'); con_Clust20_Word_Single_Vals4Grp_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Single_Vals4Grp_Comp1.txt'); con_Clust20_NonWord_Single_Vals4Grp_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a=1;
for subs = sz
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSingleComp1+tlrc > Clust20_Word_Single_Vals4Grp_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSingleComp1+tlrc > Clust20_NonWord_Single_Vals4Grp_Comp1.txt']);

        val = importdata('Clust20_Word_Single_Vals4Grp_Comp1.txt'); sz_Clust20_Word_Single_Vals4Grp_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Single_Vals4Grp_Comp1.txt'); sz_Clust20_NonWord_Single_Vals4Grp_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_Single_Comp1_conVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([con_Clust20_Word_Single_Vals4Grp_Comp1(',num2str(i),',:);con_Clust20_NonWord_Single_Vals4Grp_Comp1(',num2str(i),',:)],1);']);
end
for i=1:length(sz)
    eval(['Clust20_Single_Comp1_szVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([sz_Clust20_Word_Single_Vals4Grp_Comp1(',num2str(i),',:);sz_Clust20_NonWord_Single_Vals4Grp_Comp1(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrp,1)
    eval(['!whereami ',num2str(voxGrp(i,1)),' ',num2str(voxGrp(i,2)),' ',num2str(voxGrp(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrp{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrp{i,1}=wmiGrp{i,1}(2:end);
end

save Clust20_Single_Comp1_Grp voxGrp wmiGrp Clust20_Single_Comp1_conVoxelsGrp Clust20_Single_Comp1_szVoxelsGrp

for i=1:size(voxGrp,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1) = mean(Clust20_Single_Comp1_conVoxelsGrp(:,',num2str(i),'));']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1) = mean(Clust20_Single_Comp1_szVoxelsGrp(:,',num2str(i),'));']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1) = std(Clust20_Single_Comp1_conVoxelsGrp(:,',num2str(i),'))./sqrt(16);']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1) = std(Clust20_Single_Comp1_szVoxelsGrp(:,',num2str(i),'))./sqrt(14);']);
end;

% plots for the group
for i=1:size(voxGrp,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrp{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'control','schizophrenia'});
end

%% 2. Wrd
clear all
% each subject power for each extreme voxel in the word effect
allSubs = [0:3 5:9 12 14:17 19:21 23 25 27 28 31:36 37 39 41];
voxWrd = importdata('Clust20_xyzWrd_Single_Comp1.txt');

val=[];
a = 1;
for subs=allSubs
    for i = 1:size(voxWrd,1)
        eval(['!3dmaskdump -xbox ',num2str(voxWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSingleComp1+tlrc > Clust20_Word_Single_Vals4Wrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSingleComp1+tlrc > Clust20_NonWord_Single_Vals4Wrd_Comp1.txt']);

        val = importdata('Clust20_Word_Single_Vals4Wrd_Comp1.txt'); Clust20_Word_Single_Vals4Wrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Single_Vals4Wrd_Comp1.txt'); Clust20_NonWord_Single_Vals4Wrd_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the word effect
for i = 1:size(voxWrd,1)
    eval(['!whereami ',num2str(voxWrd(i,1)),' ',num2str(voxWrd(i,2)),' ',num2str(voxWrd(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiWrd{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiWrd{i,1}=wmiWrd{i,1}(2:end);
end

save Clust20_Single_Comp1_Wrd voxWrd wmiWrd Clust20_Word_Single_Vals4Wrd_Comp1 Clust20_NonWord_Single_Vals4Wrd_Comp1

for i=1:size(voxWrd,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1) = mean(Clust20_Word_Single_Vals4Wrd_Comp1(:,',num2str(i),'));']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1) = mean(Clust20_NonWord_Single_Vals4Wrd_Comp1(:,',num2str(i),'));']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1) = std(Clust20_Word_Single_Vals4Wrd_Comp1(:,',num2str(i),'))./sqrt(16);']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1) = std(Clust20_NonWord_Single_Vals4Wrd_Comp1(:,',num2str(i),'))./sqrt(14);']);
end;

% plots for the word
for i=1:size(voxWrd,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiWrd{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Word','Non Word'});
end
%% For Repeat
cd /home/meg/Data/Maor/SchizoProject/wordNoWord
clear all
!3dExtrema -prefix Clust20_Comp1_Repeat_Grp_ext -mask_file Clust20_Comp1_Repeat_Grp_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Repeat_Comp1_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_Comp1_Repeat_Wrd_ext -mask_file Clust20_Comp1_Repeat_Wrd_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Repeat_Comp1_ctx+tlrc'[4]'
!3dExtrema -prefix Clust20_Comp1_Repeat_Rep_ext -mask_file Clust20_Comp1_Repeat_Rep_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Repeat_Comp1_ctx+tlrc'[2]'
!3dExtrema -prefix Clust20_Comp1_Repeat_Grp_Wrd_ext -mask_file Clust20_Comp1_Repeat_Grp_Wrd_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Repeat_Comp1_ctx+tlrc'[5]'
!3dExtrema -prefix Clust20_Comp1_Repeat_Grp_Rep_ext -mask_file Clust20_Comp1_Repeat_Grp_Rep_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Repeat_Comp1_ctx+tlrc'[3]'
!3dExtrema -prefix Clust20_Comp1_Repeat_Rep_Wrd_ext -mask_file Clust20_Comp1_Repeat_Rep_Wrd_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Repeat_Comp1_ctx+tlrc'[6]'
!3dExtrema -prefix Clust20_Comp1_Repeat_Grp_Rep_Wrd_ext -mask_file Clust20_Comp1_Repeat_Grp_Rep_Wrd_mask+tlrc -data_thr 4.197 -sep_dist 30 -closure -volume 3dMVM_Repeat_Comp1_ctx+tlrc'[7]'

% extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Repeat_Grp_ext+tlrc > Clust20_xyzGrp_Repeat_Comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Repeat_Wrd_ext+tlrc > Clust20_xyzWrd_Repeat_Comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Repeat_Rep_ext+tlrc > Clust20_xyzRep_Repeat_Comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Repeat_Grp_Rep_ext+tlrc > Clust20_xyzGrpRep_Repeat_Comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Repeat_Grp_Wrd_ext+tlrc > Clust20_xyzGrpWrd_Repeat_Comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Repeat_Rep_Wrd_ext+tlrc > Clust20_xyzRepWrd_Repeat_Comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Comp1_Repeat_Grp_Rep_Wrd_ext+tlrc > Clust20_xyzGrpRepWrd_Repeat_Comp1.txt

%% creating a matrix of all maximum values for all subs for all condition
%% 1. Group
% each subject power for each extreme voxel in the group effect
con = [0:3 5:9 12 15 20 32 36 39 41];
sz = [14 16 17 19 21 23 25 27 28 31 33:35 37];

voxGrp = importdata('Clust20_xyzGrp_Repeat_Comp1.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4Grp_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4Grp_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4Grp_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4Grp_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4Grp_Comp1.txt'); con_Clust20_Word_First_Vals4Grp_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4Grp_Comp1.txt'); con_Clust20_NonWord_First_Vals4Grp_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4Grp_Comp1.txt'); con_Clust20_Word_Second_Vals4Grp_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4Grp_Comp1.txt'); con_Clust20_NonWord_Second_Vals4Grp_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = sz
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4Grp_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4Grp_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4Grp_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4Grp_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4Grp_Comp1.txt'); sz_Clust20_Word_First_Vals4Grp_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4Grp_Comp1.txt'); sz_Clust20_NonWord_First_Vals4Grp_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4Grp_Comp1.txt'); sz_Clust20_Word_Second_Vals4Grp_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4Grp_Comp1.txt'); sz_Clust20_NonWord_Second_Vals4Grp_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_Repeat_Comp1_conVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([con_Clust20_Word_First_Vals4Grp_Comp1(',num2str(i),',:);con_Clust20_NonWord_First_Vals4Grp_Comp1(',num2str(i),',:);con_Clust20_Word_Second_Vals4Grp_Comp1(',num2str(i),',:);con_Clust20_NonWord_Second_Vals4Grp_Comp1(',num2str(i),',:)],1);']);
end
for i=1:length(sz)
    eval(['Clust20_Repeat_Comp1_szVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([sz_Clust20_Word_First_Vals4Grp_Comp1(',num2str(i),',:);sz_Clust20_NonWord_First_Vals4Grp_Comp1(',num2str(i),',:);sz_Clust20_Word_Second_Vals4Grp_Comp1(',num2str(i),',:);sz_Clust20_NonWord_Second_Vals4Grp_Comp1(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrp,1)
    eval(['!whereami ',num2str(voxGrp(i,1)),' ',num2str(voxGrp(i,2)),' ',num2str(voxGrp(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrp{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrp{i,1}=wmiGrp{i,1}(2:end);
end

save Clust20_Repeat_Comp1_Grp voxGrp wmiGrp Clust20_Repeat_Comp1_conVoxelsGrp Clust20_Repeat_Comp1_szVoxelsGrp

for i=1:size(voxGrp,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1) = mean(Clust20_Repeat_Comp1_conVoxelsGrp(:,',num2str(i),'));']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1) = mean(Clust20_Repeat_Comp1_szVoxelsGrp(:,',num2str(i),'));']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1) = std(Clust20_Repeat_Comp1_conVoxelsGrp(:,',num2str(i),'))./sqrt(16);']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1) = std(Clust20_Repeat_Comp1_szVoxelsGrp(:,',num2str(i),'))./sqrt(14);']);
end;

% plots for the group
for i=1:size(voxGrp,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrp{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'control','schizophrenia'});
end

%% 2. Word
% each subject power for each extreme voxel in the word effect
clear all
allSubs = [0:3 5:9 12 14:17 19:21 23 25 27 28 31:36 37 39 41];
voxWrd = importdata('Clust20_xyzWrd_Repeat_Comp1.txt');

val=[];
a = 1;
for subs = allSubs
    for i = 1:size(voxWrd,1)
        eval(['!3dmaskdump -xbox ',num2str(voxWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4Wrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4Wrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4Wrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4Wrd_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4Wrd_Comp1.txt'); Clust20_Word_First_Vals4Wrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4Wrd_Comp1.txt'); Clust20_NonWord_First_Vals4Wrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4Wrd_Comp1.txt'); Clust20_Word_Second_Vals4Wrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4Wrd_Comp1.txt'); Clust20_NonWord_Second_Vals4Wrd_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(allSubs)
    eval(['Clust20_Repeat_Comp1_wordVoxelsWrd(',num2str(i),',1:size(voxWrd,1)) = mean([Clust20_Word_First_Vals4Wrd_Comp1(',num2str(i),',:);Clust20_Word_Second_Vals4Wrd_Comp1(',num2str(i),',:)],1);']);
end
for i=1:length(allSubs)
    eval(['Clust20_Repeat_Comp1_nonWordVoxelsWrd(',num2str(i),',1:size(voxWrd,1)) = mean([Clust20_NonWord_First_Vals4Wrd_Comp1(',num2str(i),',:);Clust20_NonWord_Second_Vals4Wrd_Comp1(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the word effect
for i = 1:size(voxWrd,1)
    eval(['!whereami ',num2str(voxWrd(i,1)),' ',num2str(voxWrd(i,2)),' ',num2str(voxWrd(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiWrd{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiWrd{i,1}=wmiWrd{i,1}(2:end);
end

save Clust20_Repeat_Comp1_Wrd voxWrd wmiWrd Clust20_Repeat_Comp1_wordVoxelsWrd Clust20_Repeat_Comp1_nonWordVoxelsWrd

for i=1:size(voxWrd,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1) = mean(Clust20_Repeat_Comp1_wordVoxelsWrd(:,',num2str(i),'));']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1) = mean(Clust20_Repeat_Comp1_nonWordVoxelsWrd(:,',num2str(i),'));']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1) = std(Clust20_Repeat_Comp1_wordVoxelsWrd(:,',num2str(i),'))./sqrt(16);']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1) = std(Clust20_Repeat_Comp1_nonWordVoxelsWrd(:,',num2str(i),'))./sqrt(14);']);
end;

% plots for the word
for i=1:size(voxWrd,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiWrd{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'word','non word'});
end

%% 3. Repeat
% each subject power for each extreme voxel in the repeat effect
clear all
allSubs = [0:3 5:9 12 14:17 19:21 23 25 27 28 31:36 37 39 41];
voxRep = importdata('Clust20_xyzRep_Repeat_Comp1.txt');

val=[];
a = 1;
for subs = allSubs
    for i = 1:size(voxRep,1)
        eval(['!3dmaskdump -xbox ',num2str(voxRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4Rep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4Rep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4Rep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4Rep_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4Rep_Comp1.txt'); Clust20_Word_First_Vals4Rep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4Rep_Comp1.txt'); Clust20_NonWord_First_Vals4Rep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4Rep_Comp1.txt'); Clust20_Word_Second_Vals4Rep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4Rep_Comp1.txt'); Clust20_NonWord_Second_Vals4Rep_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(allSubs)
    eval(['Clust20_Repeat_Comp1_firstVoxelsRep(',num2str(i),',1:size(voxRep,1)) = mean([Clust20_Word_First_Vals4Rep_Comp1(',num2str(i),',:);Clust20_NonWord_First_Vals4Rep_Comp1(',num2str(i),',:)],1);']);
end
for i=1:length(allSubs)
    eval(['Clust20_Repeat_Comp1_secondVoxelsRep(',num2str(i),',1:size(voxRep,1)) = mean([Clust20_Word_Second_Vals4Rep_Comp1(',num2str(i),',:);Clust20_NonWord_Second_Vals4Rep_Comp1(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the repeat effect
for i = 1:size(voxRep,1)
    eval(['!whereami ',num2str(voxRep(i,1)),' ',num2str(voxRep(i,2)),' ',num2str(voxRep(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiRep{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiRep{i,1}=wmiRep{i,1}(2:end);
end

save Clust20_Repeat_Comp1_Rep voxRep wmiRep Clust20_Repeat_Comp1_firstVoxelsRep Clust20_Repeat_Comp1_secondVoxelsRep

for i=1:size(voxRep,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1) = mean(Clust20_Repeat_Comp1_firstVoxelsRep(:,',num2str(i),'));']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1) = mean(Clust20_Repeat_Comp1_secondVoxelsRep(:,',num2str(i),'));']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1) = std(Clust20_Repeat_Comp1_firstVoxelsRep(:,',num2str(i),'))./sqrt(16);']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1) = std(Clust20_Repeat_Comp1_secondVoxelsRep(:,',num2str(i),'))./sqrt(14);']);
end;

% plots for the repeat
for i=1:size(voxRep,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiRep{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'first','second'});
end

%% 4. Group X Repeat
% each subject power for each extreme voxel in the group X repeat effect
clear all
con = [0:3 5:9 12 15 20 32 36 39 41];
sz = [14 16 17 19 21 23 25 27 28 31 33:35 37];

voxGrpRep = importdata('Clust20_xyzGrpRep_Repeat_Comp1.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrpRep,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4GrpRep_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4GrpRep_Comp1.txt'); con_Clust20_Word_First_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4GrpRep_Comp1.txt'); con_Clust20_NonWord_First_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4GrpRep_Comp1.txt'); con_Clust20_Word_Second_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4GrpRep_Comp1.txt'); con_Clust20_NonWord_Second_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = sz
    for i = 1:size(voxGrpRep,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4GrpRep_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4GrpRep_Comp1.txt'); sz_Clust20_Word_First_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4GrpRep_Comp1.txt'); sz_Clust20_NonWord_First_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4GrpRep_Comp1.txt'); sz_Clust20_Word_Second_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4GrpRep_Comp1.txt'); sz_Clust20_NonWord_Second_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_Repeat_Comp1_conFirstVoxelsGrpRep(',num2str(i),',1:size(voxGrpRep,1)) = mean([con_Clust20_Word_First_Vals4GrpRep_Comp1(',num2str(i),',:);con_Clust20_NonWord_First_Vals4GrpRep_Comp1(',num2str(i),',:)],1);']);
    eval(['Clust20_Repeat_Comp1_conSecondVoxelsGrpRep(',num2str(i),',1:size(voxGrpRep,1)) = mean([con_Clust20_Word_Second_Vals4GrpRep_Comp1(',num2str(i),',:);con_Clust20_NonWord_Second_Vals4GrpRep_Comp1(',num2str(i),',:)],1);']);
end

for i=1:length(sz)
    eval(['Clust20_Repeat_Comp1_szFirstVoxelsGrpRep(',num2str(i),',1:size(voxGrpRep,1)) = mean([sz_Clust20_Word_First_Vals4GrpRep_Comp1(',num2str(i),',:);sz_Clust20_NonWord_First_Vals4GrpRep_Comp1(',num2str(i),',:)],1);']);
    eval(['Clust20_Repeat_Comp1_szSecondVoxelsGrpRep(',num2str(i),',1:size(voxGrpRep,1)) = mean([sz_Clust20_Word_Second_Vals4GrpRep_Comp1(',num2str(i),',:);sz_Clust20_NonWord_Second_Vals4GrpRep_Comp1(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrpRep,1)
    eval(['!whereami ',num2str(voxGrpRep(i,1)),' ',num2str(voxGrpRep(i,2)),' ',num2str(voxGrpRep(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrpRep{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrpRep{i,1}=wmiGrpRep{i,1}(2:end);
end

save Clust20_Repeat_Comp1_GrpRep voxGrpRep wmiGrpRep Clust20_Repeat_Comp1_conFirstVoxelsGrpRep Clust20_Repeat_Comp1_conSecondVoxelsGrpRep Clust20_Repeat_Comp1_szFirstVoxelsGrpRep Clust20_Repeat_Comp1_szSecondVoxelsGrpRep

for i=1:size(voxGrpRep,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,[1 2]) = [mean(Clust20_Repeat_Comp1_conFirstVoxelsGrpRep(:,',num2str(i),')), mean(Clust20_Repeat_Comp1_conSecondVoxelsGrpRep(:,',num2str(i),'))];']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,[1 2]) = [mean(Clust20_Repeat_Comp1_szFirstVoxelsGrpRep(:,',num2str(i),')), mean(Clust20_Repeat_Comp1_szSecondVoxelsGrpRep(:,',num2str(i),'))];']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,[1 2]) = [std(Clust20_Repeat_Comp1_conFirstVoxelsGrpRep(:,',num2str(i),'))./sqrt(16), std(Clust20_Repeat_Comp1_conSecondVoxelsGrpRep(:,',num2str(i),'))./sqrt(16)];']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,[1 2]) = [std(Clust20_Repeat_Comp1_szFirstVoxelsGrpRep(:,',num2str(i),'))./sqrt(14), std(Clust20_Repeat_Comp1_szSecondVoxelsGrpRep(:,',num2str(i),'))./sqrt(14)];']);
end;

% plots for the group
for i=1:size(voxGrpRep,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrpRep{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'first','second'});
    legend('control','schizophrenia');
end

%% 4. Group X Repeat
% each subject power for each extreme voxel in the group X repeat effect
clear all
con = [0:3 5:9 12 15 20 32 36 39 41];
sz = [14 16 17 19 21 23 25 27 28 31 33:35 37];

voxGrpRep = importdata('Clust20_xyzGrpRep_Repeat_Comp1.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrpRep,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4GrpRep_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4GrpRep_Comp1.txt'); con_Clust20_Word_First_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4GrpRep_Comp1.txt'); con_Clust20_NonWord_First_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4GrpRep_Comp1.txt'); con_Clust20_Word_Second_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4GrpRep_Comp1.txt'); con_Clust20_NonWord_Second_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = sz
    for i = 1:size(voxGrpRep,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4GrpRep_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRep(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4GrpRep_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4GrpRep_Comp1.txt'); sz_Clust20_Word_First_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4GrpRep_Comp1.txt'); sz_Clust20_NonWord_First_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4GrpRep_Comp1.txt'); sz_Clust20_Word_Second_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4GrpRep_Comp1.txt'); sz_Clust20_NonWord_Second_Vals4GrpRep_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_Repeat_Comp1_conFirstVoxelsGrpRep(',num2str(i),',1:size(voxGrpRep,1)) = mean([con_Clust20_Word_First_Vals4GrpRep_Comp1(',num2str(i),',:);con_Clust20_NonWord_First_Vals4GrpRep_Comp1(',num2str(i),',:)],1);']);
    eval(['Clust20_Repeat_Comp1_conSecondVoxelsGrpRep(',num2str(i),',1:size(voxGrpRep,1)) = mean([con_Clust20_Word_Second_Vals4GrpRep_Comp1(',num2str(i),',:);con_Clust20_NonWord_Second_Vals4GrpRep_Comp1(',num2str(i),',:)],1);']);
end

for i=1:length(sz)
    eval(['Clust20_Repeat_Comp1_szFirstVoxelsGrpRep(',num2str(i),',1:size(voxGrpRep,1)) = mean([sz_Clust20_Word_First_Vals4GrpRep_Comp1(',num2str(i),',:);sz_Clust20_NonWord_First_Vals4GrpRep_Comp1(',num2str(i),',:)],1);']);
    eval(['Clust20_Repeat_Comp1_szSecondVoxelsGrpRep(',num2str(i),',1:size(voxGrpRep,1)) = mean([sz_Clust20_Word_Second_Vals4GrpRep_Comp1(',num2str(i),',:);sz_Clust20_NonWord_Second_Vals4GrpRep_Comp1(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group x repeat effect
for i = 1:size(voxGrpRep,1)
    eval(['!whereami ',num2str(voxGrpRep(i,1)),' ',num2str(voxGrpRep(i,2)),' ',num2str(voxGrpRep(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrpRep{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrpRep{i,1}=wmiGrpRep{i,1}(2:end);
end

save Clust20_Repeat_Comp1_GrpRep voxGrpRep wmiGrpRep Clust20_Repeat_Comp1_conFirstVoxelsGrpRep Clust20_Repeat_Comp1_conSecondVoxelsGrpRep Clust20_Repeat_Comp1_szFirstVoxelsGrpRep Clust20_Repeat_Comp1_szSecondVoxelsGrpRep

for i=1:size(voxGrpRep,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,[1 2]) = [mean(Clust20_Repeat_Comp1_conFirstVoxelsGrpRep(:,',num2str(i),')), mean(Clust20_Repeat_Comp1_conSecondVoxelsGrpRep(:,',num2str(i),'))];']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,[1 2]) = [mean(Clust20_Repeat_Comp1_szFirstVoxelsGrpRep(:,',num2str(i),')), mean(Clust20_Repeat_Comp1_szSecondVoxelsGrpRep(:,',num2str(i),'))];']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,[1 2]) = [std(Clust20_Repeat_Comp1_conFirstVoxelsGrpRep(:,',num2str(i),'))./sqrt(16), std(Clust20_Repeat_Comp1_conSecondVoxelsGrpRep(:,',num2str(i),'))./sqrt(16)];']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,[1 2]) = [std(Clust20_Repeat_Comp1_szFirstVoxelsGrpRep(:,',num2str(i),'))./sqrt(14), std(Clust20_Repeat_Comp1_szSecondVoxelsGrpRep(:,',num2str(i),'))./sqrt(14)];']);
end;

% plots for the group x repeat effect
for i=1:size(voxGrpRep,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrpRep{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'first','second'});
    legend('control','schizophrenia');
end

%% 5. Group X Word
% each subject power for each extreme voxel in the group X word effect
clear all
con = [0:3 5:9 12 15 20 32 36 39 41];
sz = [14 16 17 19 21 23 25 27 28 31 33:35 37];

voxGrpWrd = importdata('Clust20_xyzGrpWrd_Repeat_Comp1.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrpWrd,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrpWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4GrpWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4GrpWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4GrpWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4GrpWrd_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4GrpWrd_Comp1.txt'); con_Clust20_Word_First_Vals4GrpWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4GrpWrd_Comp1.txt'); con_Clust20_NonWord_First_Vals4GrpWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4GrpWrd_Comp1.txt'); con_Clust20_Word_Second_Vals4GrpWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4GrpWrd_Comp1.txt'); con_Clust20_NonWord_Second_Vals4GrpWrd_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = sz
    for i = 1:size(voxGrpWrd,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrpWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4GrpWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4GrpWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4GrpWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4GrpWrd_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4GrpWrd_Comp1.txt'); sz_Clust20_Word_First_Vals4GrpWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4GrpWrd_Comp1.txt'); sz_Clust20_NonWord_First_Vals4GrpWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4GrpWrd_Comp1.txt'); sz_Clust20_Word_Second_Vals4GrpWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4GrpWrd_Comp1.txt'); sz_Clust20_NonWord_Second_Vals4GrpWrd_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_Repeat_Comp1_conWordVoxelsGrpWrd(',num2str(i),',1:size(voxGrpWrd,1)) = mean([con_Clust20_Word_First_Vals4GrpWrd_Comp1(',num2str(i),',:);con_Clust20_Word_Second_Vals4GrpWrd_Comp1(',num2str(i),',:)],1);']);
    eval(['Clust20_Repeat_Comp1_conNonWordVoxelsGrpWrd(',num2str(i),',1:size(voxGrpWrd,1)) = mean([con_Clust20_NonWord_First_Vals4GrpWrd_Comp1(',num2str(i),',:);con_Clust20_NonWord_Second_Vals4GrpWrd_Comp1(',num2str(i),',:)],1);']);
end

for i=1:length(sz)
    eval(['Clust20_Repeat_Comp1_szWordVoxelsGrpWrd(',num2str(i),',1:size(voxGrpWrd,1)) = mean([sz_Clust20_Word_First_Vals4GrpWrd_Comp1(',num2str(i),',:);sz_Clust20_Word_Second_Vals4GrpWrd_Comp1(',num2str(i),',:)],1);']);
    eval(['Clust20_Repeat_Comp1_szNonWordVoxelsGrpWrd(',num2str(i),',1:size(voxGrpWrd,1)) = mean([sz_Clust20_NonWord_First_Vals4GrpWrd_Comp1(',num2str(i),',:);sz_Clust20_NonWord_Second_Vals4GrpWrd_Comp1(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group x word effect
for i = 1:size(voxGrpWrd,1)
    eval(['!whereami ',num2str(voxGrpWrd(i,1)),' ',num2str(voxGrpWrd(i,2)),' ',num2str(voxGrpWrd(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrpWrd{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrpWrd{i,1}=wmiGrpWrd{i,1}(2:end);
end

save Clust20_Repeat_Comp1_GrpWrd voxGrpWrd wmiGrpWrd Clust20_Repeat_Comp1_conWordVoxelsGrpWrd Clust20_Repeat_Comp1_conNonWordVoxelsGrpWrd Clust20_Repeat_Comp1_szWordVoxelsGrpWrd Clust20_Repeat_Comp1_szNonWordVoxelsGrpWrd

for i=1:size(voxGrpWrd,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,[1 2]) = [mean(Clust20_Repeat_Comp1_conWordVoxelsGrpWrd(:,',num2str(i),')), mean(Clust20_Repeat_Comp1_conNonWordVoxelsGrpWrd(:,',num2str(i),'))];']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,[1 2]) = [mean(Clust20_Repeat_Comp1_szWordVoxelsGrpWrd(:,',num2str(i),')), mean(Clust20_Repeat_Comp1_szNonWordVoxelsGrpWrd(:,',num2str(i),'))];']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,[1 2]) = [std(Clust20_Repeat_Comp1_conWordVoxelsGrpWrd(:,',num2str(i),'))./sqrt(16), std(Clust20_Repeat_Comp1_conNonWordVoxelsGrpWrd(:,',num2str(i),'))./sqrt(16)];']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,[1 2]) = [std(Clust20_Repeat_Comp1_szWordVoxelsGrpWrd(:,',num2str(i),'))./sqrt(14), std(Clust20_Repeat_Comp1_szNonWordVoxelsGrpWrd(:,',num2str(i),'))./sqrt(14)];']);
end;

% plots for the group x word effect
for i=1:size(voxGrpWrd,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrpWrd{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'word','non word'});
    legend('control','schizophrenia');
end

%% 6. Repeat X Word
% each subject power for each extreme voxel in the repeat x word effect
clear all
allSubs = [0:3 5:9 12 14:17 19:21 23 25 27 28 31:36 37 39 41];

voxRepWrd = importdata('Clust20_xyzRepWrd_Repeat_Comp1.txt');

val=[];
a = 1;
for subs = allSubs
    for i = 1:size(voxRepWrd,1)
        eval(['!3dmaskdump -xbox ',num2str(voxRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4RepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4RepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4RepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4RepWrd_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4RepWrd_Comp1.txt'); Clust20_Word_First_Vals4RepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4RepWrd_Comp1.txt'); Clust20_NonWord_First_Vals4RepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4RepWrd_Comp1.txt'); Clust20_Word_Second_Vals4RepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4RepWrd_Comp1.txt'); Clust20_NonWord_Second_Vals4RepWrd_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the repeat x word effect
for i = 1:size(voxRepWrd,1)
    eval(['!whereami ',num2str(voxRepWrd(i,1)),' ',num2str(voxRepWrd(i,2)),' ',num2str(voxRepWrd(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiRepWrd{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiRepWrd{i,1}=wmiRepWrd{i,1}(2:end);
end

save Clust20_Repeat_Comp1_RepWrd voxRepWrd wmiRepWrd Clust20_Word_First_Vals4RepWrd_Comp1 Clust20_NonWord_First_Vals4RepWrd_Comp1 Clust20_Word_Second_Vals4RepWrd_Comp1 Clust20_NonWord_Second_Vals4RepWrd_Comp1

for i=1:size(voxRepWrd,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,[1 2]) = [mean(Clust20_Word_First_Vals4RepWrd_Comp1(:,',num2str(i),')), mean(Clust20_NonWord_First_Vals4RepWrd_Comp1(:,',num2str(i),'))];']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,[1 2]) = [mean(Clust20_Word_Second_Vals4RepWrd_Comp1(:,',num2str(i),')), mean(Clust20_NonWord_Second_Vals4RepWrd_Comp1(:,',num2str(i),'))];']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,[1 2]) = [std(Clust20_Word_First_Vals4RepWrd_Comp1(:,',num2str(i),'))./sqrt(30), std(Clust20_NonWord_First_Vals4RepWrd_Comp1(:,',num2str(i),'))./sqrt(30)];']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,[1 2]) = [std(Clust20_Word_Second_Vals4RepWrd_Comp1(:,',num2str(i),'))./sqrt(30), std(Clust20_NonWord_Second_Vals4RepWrd_Comp1(:,',num2str(i),'))./sqrt(30)];']);
end;

% plots for the repeat x word effect
for i=1:size(voxRepWrd,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiRepWrd{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'word','non word'});
    legend('first','second');
end

%% 7. Group X Repeat X Word
% each subject power for each extreme voxel in the group x repeat x word effect
clear all
con = [0:3 5:9 12 15 20 32 36 39 41];
sz = [14 16 17 19 21 23 25 27 28 31 33:35 37];

voxGrpRepWrd = importdata('Clust20_xyzGrpRepWrd_Repeat_Comp1.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrpRepWrd,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4GrpRepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4GrpRepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4GrpRepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4GrpRepWrd_Comp1.txt'); con_Clust20_Word_First_Vals4GrpRepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4GrpRepWrd_Comp1.txt'); con_Clust20_NonWord_First_Vals4GrpRepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4GrpRepWrd_Comp1.txt'); con_Clust20_Word_Second_Vals4GrpRepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1.txt'); con_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = sz
    for i = 1:size(voxGrpRepWrd,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordFirstComp1+tlrc > Clust20_Word_First_Vals4GrpRepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordFirstComp1+tlrc > Clust20_NonWord_First_Vals4GrpRepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/wordSecondComp1+tlrc > Clust20_Word_Second_Vals4GrpRepWrd_Comp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrpRepWrd(i,1:3)),' /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(subs),'/1/SAM_1_40Hz/nonWordSecondComp1+tlrc > Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1.txt']);
        val = importdata('Clust20_Word_First_Vals4GrpRepWrd_Comp1.txt'); sz_Clust20_Word_First_Vals4GrpRepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_First_Vals4GrpRepWrd_Comp1.txt'); sz_Clust20_NonWord_First_Vals4GrpRepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_Word_Second_Vals4GrpRepWrd_Comp1.txt'); sz_Clust20_Word_Second_Vals4GrpRepWrd_Comp1(a,i) = val(4); val=[];
        val = importdata('Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1.txt'); sz_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the group x repeat x word effect
for i = 1:size(voxGrpRepWrd,1)
    eval(['!whereami ',num2str(voxGrpRepWrd(i,1)),' ',num2str(voxGrpRepWrd(i,2)),' ',num2str(voxGrpRepWrd(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrpRepWrd{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrpRepWrd{i,1}=wmiGrpRepWrd{i,1}(2:end);
end

save Clust20_Repeat_Comp1_GrpRepWrd voxGrpRepWrd wmiGrpRepWrd con_Clust20_Word_First_Vals4GrpRepWrd_Comp1 ...
    con_Clust20_NonWord_First_Vals4GrpRepWrd_Comp1 con_Clust20_Word_Second_Vals4GrpRepWrd_Comp1 con_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1 ...
    sz_Clust20_Word_First_Vals4GrpRepWrd_Comp1 sz_Clust20_NonWord_First_Vals4GrpRepWrd_Comp1 sz_Clust20_Word_Second_Vals4GrpRepWrd_Comp1 ...
    sz_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1

for i=1:size(voxGrpRepWrd,1)
    eval(['mean1_comp1_voxel_',num2str(i),'(1,[1 2]) = [mean(con_Clust20_Word_First_Vals4GrpRepWrd_Comp1(:,',num2str(i),')), mean(con_Clust20_Word_Second_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))];']);
    eval(['mean1_comp1_voxel_',num2str(i),'(2,[1 2]) = [mean(sz_Clust20_Word_First_Vals4GrpRepWrd_Comp1(:,',num2str(i),')), mean(sz_Clust20_Word_Second_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))];']);
    eval(['sd1_comp1_voxel_',num2str(i),'(1,[1 2]) = [std(con_Clust20_Word_First_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))./sqrt(16), std(con_Clust20_Word_Second_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))./sqrt(16)];']);
    eval(['sd1_comp1_voxel_',num2str(i),'(2,[1 2]) = [std(sz_Clust20_Word_First_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))./sqrt(14), std(sz_Clust20_Word_Second_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))./sqrt(14)];']);
    
    eval(['mean2_comp1_voxel_',num2str(i),'(1,[1 2]) = [mean(con_Clust20_NonWord_First_Vals4GrpRepWrd_Comp1(:,',num2str(i),')), mean(con_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))];']);
    eval(['mean2_comp1_voxel_',num2str(i),'(2,[1 2]) = [mean(sz_Clust20_NonWord_First_Vals4GrpRepWrd_Comp1(:,',num2str(i),')), mean(sz_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))];']);
    eval(['sd2_comp1_voxel_',num2str(i),'(1,[1 2]) = [std(con_Clust20_Word_First_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))./sqrt(16), std(con_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))./sqrt(16)];']);
    eval(['sd2_comp1_voxel_',num2str(i),'(2,[1 2]) = [std(sz_Clust20_Word_First_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))./sqrt(14), std(sz_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp1(:,',num2str(i),'))./sqrt(14)];']);
end;

% plots for the group x repeat x word effect
for i=1:size(voxGrpRepWrd,1)
    figure;
    subplot(1,2,1)
    eval(['h1 = barwitherr(sd1_comp1_voxel_',num2str(i),''',mean1_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 Word voxel %s - %s',num2str(i),wmiGrpRepWrd{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'first','second'});
    legend('control','schizophrenia');
    
    subplot(1,2,2)
    eval(['h1 = barwitherr(sd2_comp1_voxel_',num2str(i),''',mean2_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 2 Non-Word voxel %s - %s',num2str(i),wmiGrpRepWrd{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'first','second'});
    legend('control','schizophrenia');
end

%% checking for correlations between symptoms and effects
% list of symptoms (pos,neg):
cd /home/meg/Data/Maor/SchizoProject/wordNoWord
load behavWord
% checking for trade off
[r,p]=corrcoef(ERSZ,RTSZ);
% checking for correlations between symptoms and behavioral results
ERSZ(:,7)=mean(ERSZ(:,[1 3 5]),2);
ERSZ(:,8)=mean(ERSZ(:,[2 4 6]),2);
RTSZ(:,7)=mean(RTSZ(:,[1 3 5]),2);
RTSZ(:,8)=mean(RTSZ(:,[2 4 6]),2);

symptoms = [[9;29;24;28;29;17;7;25;14;7;7;23;32;31],[19;7;25;17;13;10;19;11;17;13;15;11;16;21]];

for i=1:size(symptoms,2)
    for j=1:size(ERSZ,2)
        [ER_r,ER_p]=corrcoef(symptoms(:,i),ERSZ(:,j));
        [RT_r,RT_p]=corrcoef(symptoms(:,i),RTSZ(:,j));
        ER_R(i,j)=ER_r(1,2);ER_P(i,j)=ER_p(1,2);
        RT_R(i,j)=RT_r(1,2);RT_P(i,j)=RT_p(1,2);
    end
end

% checking for correlations between symptoms and SAM results
% for comp1 Repeat: group x repeat vox 5
load Clust20_Repeat_Comp1_GrpRep
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp1_szFirstVoxelsGrpRep(:,5))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp1_szFirstVoxelsGrpRep(:,5))
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp1_szSecondVoxelsGrpRep(:,5))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp1_szSecondVoxelsGrpRep(:,5))
% for comp2 Single: group vox 1
load Clust20_Single_Comp2_Grp
[r,p]=corrcoef(symptoms(:,1),Clust20_Single_Comp2_szVoxelsGrp(:,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_Single_Comp2_szVoxelsGrp(:,1))
% for comp2 Single: word vox 7
load Clust20_Single_Comp2_Wrd
sz=[11 13:15 17:22 24:26 28];
[r,p]=corrcoef(symptoms(:,1),Clust20_Word_Single_Vals4Wrd_Comp2(sz,7))
[r,p]=corrcoef(symptoms(:,2),Clust20_Word_Single_Vals4Wrd_Comp2(sz,7))
[r,p]=corrcoef(symptoms(:,1),Clust20_NonWord_Single_Vals4Wrd_Comp2(sz,7))
[r,p]=corrcoef(symptoms(:,2),Clust20_NonWord_Single_Vals4Wrd_Comp2(sz,7))
% for comp2 Repeat: group x repeat vox 1
load Clust20_Repeat_Comp2_GrpRep
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp2_szFirstVoxelsGrpRep(:,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp2_szFirstVoxelsGrpRep(:,1))
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp2_szSecondVoxelsGrpRep(:,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp2_szSecondVoxelsGrpRep(:,1))
% for comp2 Repeat: group x repeat x word vox 3
load Clust20_Repeat_Comp2_GrpRepWrd
[r,p]=corrcoef(symptoms(:,1),sz_Clust20_NonWord_First_Vals4GrpRepWrd_Comp2(:,3))
[r,p]=corrcoef(symptoms(:,2),sz_Clust20_NonWord_First_Vals4GrpRepWrd_Comp2(:,3))
[r,p]=corrcoef(symptoms(:,1),sz_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp2(:,3))
[r,p]=corrcoef(symptoms(:,2),sz_Clust20_NonWord_Second_Vals4GrpRepWrd_Comp2(:,3))
[r,p]=corrcoef(symptoms(:,1),sz_Clust20_Word_First_Vals4GrpRepWrd_Comp2(:,3))
[r,p]=corrcoef(symptoms(:,2),sz_Clust20_Word_First_Vals4GrpRepWrd_Comp2(:,3))
[r,p]=corrcoef(symptoms(:,1),sz_Clust20_Word_Second_Vals4GrpRepWrd_Comp2(:,3))
[r,p]=corrcoef(symptoms(:,2),sz_Clust20_Word_Second_Vals4GrpRepWrd_Comp2(:,3))
% for comp3 Single: word vox 1 and 2
load Clust20_Single_Comp3_Wrd
sz=[11 13:15 17:22 24:26 28];
[r,p]=corrcoef(symptoms(:,1),Clust20_NonWord_Single_Vals4Wrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_NonWord_Single_Vals4Wrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,1),Clust20_Word_Single_Vals4Wrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_Word_Single_Vals4Wrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,1),Clust20_NonWord_Single_Vals4Wrd_Comp3(sz,2))
[r,p]=corrcoef(symptoms(:,2),Clust20_NonWord_Single_Vals4Wrd_Comp3(sz,2))
[r,p]=corrcoef(symptoms(:,1),Clust20_Word_Single_Vals4Wrd_Comp3(sz,2))
[r,p]=corrcoef(symptoms(:,2),Clust20_Word_Single_Vals4Wrd_Comp3(sz,2))
% for comp3 Repeat: group x word vox 1
load Clust20_Repeat_Comp3_GrpWrd
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp3_szNonWordVoxelsGrpWrd(:,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp3_szNonWordVoxelsGrpWrd(:,1))
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp3_szWordVoxelsGrpWrd(:,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp3_szWordVoxelsGrpWrd(:,1))
% for comp3 Repeat: group x word vox 1
load Clust20_Repeat_Comp3_RepWrd
sz=[11 13:15 17:22 24:26 28];
[r,p]=corrcoef(symptoms(:,1),Clust20_NonWord_First_Vals4RepWrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_NonWord_First_Vals4RepWrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,1),Clust20_NonWord_Second_Vals4RepWrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_NonWord_Second_Vals4RepWrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,1),Clust20_Word_First_Vals4RepWrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_Word_First_Vals4RepWrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,1),Clust20_Word_Second_Vals4RepWrd_Comp3(sz,1))
[r,p]=corrcoef(symptoms(:,2),Clust20_Word_Second_Vals4RepWrd_Comp3(sz,1))
% for comp4 Single: word vox 3 and 11
load Clust20_Single_Comp4_Wrd
sz=[11 13:15 17:22 24:26 28];
[r,p]=corrcoef(symptoms(:,1),Clust20_NonWord_Single_Vals4Wrd_Comp4(sz,3))
[r,p]=corrcoef(symptoms(:,2),Clust20_NonWord_Single_Vals4Wrd_Comp4(sz,3))
[r,p]=corrcoef(symptoms(:,1),Clust20_NonWord_Single_Vals4Wrd_Comp4(sz,11))
[r,p]=corrcoef(symptoms(:,2),Clust20_NonWord_Single_Vals4Wrd_Comp4(sz,11))
[r,p]=corrcoef(symptoms(:,1),Clust20_Word_Single_Vals4Wrd_Comp4(sz,3))
[r,p]=corrcoef(symptoms(:,2),Clust20_Word_Single_Vals4Wrd_Comp4(sz,3))
[r,p]=corrcoef(symptoms(:,1),Clust20_Word_Single_Vals4Wrd_Comp4(sz,11))
[r,p]=corrcoef(symptoms(:,2),Clust20_Word_Single_Vals4Wrd_Comp4(sz,11))
% for comp4 Repeat: group vox 4
load Clust20_Repeat_Comp4_Grp
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp4_szVoxelsGrp(:,4))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp4_szVoxelsGrp(:,4))
% for comp5 Repeat: word vox 5
load Clust20_Repeat_Comp5_Wrd
sz=[11 13:15 17:22 24:26 28];
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp5_nonWordVoxelsWrd(sz,5))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp5_nonWordVoxelsWrd(sz,5))
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp5_wordVoxelsWrd(sz,5))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp5_wordVoxelsWrd(sz,5))
% for comp6 Single: group vox 5
load Clust20_Single_Comp6_Grp
[r,p]=corrcoef(symptoms(:,1),Clust20_Single_Comp6_szVoxelsGrp(:,5))
[r,p]=corrcoef(symptoms(:,2),Clust20_Single_Comp6_szVoxelsGrp(:,5))
% for comp6 Repeat: repeat vox 7
load Clust20_Repeat_Comp6_Rep
sz=[11 13:15 17:22 24:26 28];
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp6_firstVoxelsRep(sz,7))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp6_firstVoxelsRep(sz,7))
[r,p]=corrcoef(symptoms(:,1),Clust20_Repeat_Comp6_secondVoxelsRep(sz,7))
[r,p]=corrcoef(symptoms(:,2),Clust20_Repeat_Comp6_secondVoxelsRep(sz,7))

%% Word vs. Non-Word
% creating virtual sensors
clear all
compTime = [377 418; 428 499; 548 611; 627 678; 699 772; 916 1079];
a=1;
for i=[0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1']);
    load datafinal
    % split conditions
    datafinal.cfg.trl(:,1:2)=datafinal.sampleinfo(:,1:2);
    datafinal.cfg.trl(:,3)=-305; % the offset
    datafinal.cfg.trl(:,4:7)=datafinal.trialinfo(:,1:4);
    cfg=[];
    for cond = [110 120 130 140 150 160 170 180 190]
        eval(['cfg.cond=',num2str(cond),';']);
        eval(['con',num2str(cond),'=splitcondscrt(cfg,datafinal);']);
    end;

    % for combining two or more datasets use: 
    cfg=[];
    word=ft_appenddata(cfg, con110, con120, con140, con150, con160, con170);
    nonWord=ft_appenddata(cfg, con130, con180, con190); 

    % averaging
    wordAvg = ft_timelockanalysis([],word);
    nonWordAvg = ft_timelockanalysis([],nonWord);
    
    clear cfg con110 con120 con130 con140 con150 con160 con170 con180 con190 datafinal nonWord word
    
    % noise estimation
    load 'SAM/all4covWord,1-40Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);
    for j=1:6 % 6 comps
        % get toi mean square (different than SAMerf, no BL correction
        eval(['vsWordComp',num2str(j),'=ActWgts*wordAvg.avg(:,compTime(j,1):compTime(j,2));']);
        eval(['vsNonWordComp',num2str(j),'=ActWgts*nonWordAvg.avg(:,compTime(j,1):compTime(j,2));']);
        % get MS
        eval(['vsWordComp',num2str(j),'MS=mean(vsWordComp',num2str(j),'.*vsWordComp',num2str(j),',2)./ns;']);
        eval(['vsNonWordComp',num2str(j),'MS=mean(vsNonWordComp',num2str(j),'.*vsNonWordComp',num2str(j),',2)./ns;']);
        % 10^25 is rescaling the data so it won't be so small
        eval(['vsWordComp',num2str(j),'MS=vsWordComp',num2str(j),'MS.*10^25;']); 
        eval(['vsNonWordComp',num2str(j),'MS=vsNonWordComp',num2str(j),'MS.*10^25;']); 
        % get rid of nans
        eval(['vsWordComp',num2str(j),'MS(isnan(vsWordComp',num2str(j),'MS))=0;']);
        eval(['vsNonWordComp',num2str(j),'MS(isnan(vsNonWordComp',num2str(j),'MS))=0;']);
        %make image 3D of mean square (MS, power)
        cfg=[];
        cfg.step=5;
        cfg.boxSize=[-120 120 -90 90 -20 150];
        eval(['cfg.prefix=''wordComp',num2str(j),''';']);
        eval(['VS2Brik(cfg,vsWordComp',num2str(j),'MS);']);
        eval(['cfg.prefix=''nonWordComp',num2str(j),''';']);
        eval(['VS2Brik(cfg,vsNonWordComp',num2str(j),'MS);']);
    end
    disp(' ');
    disp('*********************');
    disp(['      sub ',num2str(a),'/30']);
    disp('*********************');
    disp(' ');
    a=a+1;
    
    clear j ns ActWgts
    clear wordAvg nonWordAvg vsNonWordComp1 vsNonWordComp1MS vsWordComp1 vsWordComp1MS vsNonWordComp2 vsNonWordComp2MS vsWordComp2 vsWordComp2MS 
    clear vsNonWordComp3 vsNonWordComp3MS vsWordComp3 vsWordComp3MS vsNonWordComp4 vsNonWordComp4MS vsWordComp4 vsWordComp4MS 
    clear vsNonWordComp5 vsNonWordComp5MS vsWordComp5 vsWordComp5MS vsNonWordComp6 vsNonWordComp6MS vsWordComp6 vsWordComp6MS 
end
%% moving files to tlrc and moving them into a folder
% now open a terminal and type:
a=1;
for i=[0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1']);
    for j=1:6
          eval(['!@auto_tlrc -apar warped+tlrc -input wordComp',num2str(j),'+orig -dxyz 5']);
          eval(['!@auto_tlrc -apar warped+tlrc -input nonWordComp',num2str(j),'+orig -dxyz 5']);
          eval(['movefile(''*Comp',num2str(j),'+orig*'', ''SAM_1_40Hz'')']);
          eval(['movefile(''*Comp',num2str(j),'+tlrc*'', ''SAM_1_40Hz'')']);
    end
    disp(' ');
    disp('*********************');
    disp(['      sub ',num2str(a),'/30']);
    disp('*********************');
    disp(' ');
    a=a+1;
end
%% masking the tlrc files and running a t-test just for control (word vs. nonWord)
% masking
for i=[0:3 5:9 12 14:17 19:21 23 25 27 28 31:37 39 41]
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/SAM_1_40Hz']);
    for j=1:6
        eval(['masktlrc(''wordComp',num2str(j),'+tlrc'',''MASKctx+tlrc'',''_ctx'');']);
        eval(['masktlrc(''nonWordComp',num2str(j),'+tlrc'',''MASKctx+tlrc'',''_ctx'');']);
    end
end
% run "3dttest_control_word_vs_nonWord"
%% permutations
