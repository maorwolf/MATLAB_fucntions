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
sub=2;
eval(['cd /media/My_Passport/fibrodata/con/con',num2str(sub)])

source='xc,hb,lf_c,rfhp0.1Hz';

% 1. find Bad Channels
findBadChans(source);
%original_source='c,rfhp0.1Hz';% we added this line to compare between the data before and after cleaning with the Abeles fucntion
%findBadChans(original_source);
channels = {'MEG'}; % channels = {'MEG','-A41'};

% 2. finding trials and defining them
conditions = [222 230 240 250];
cfg.dataset =source; 
cfg.trialdef.eventtype  = 'TRIGGER';
cfg.trialdef.eventvalue = conditions;
cfg.trialdef.prestim    = 0.8;
cfg.trialdef.poststim   = 1.2;
cfg.trialdef.offset=-0.8;
cfg.trialfun='BIUtrialfun';
cfg.trialdef.visualtrig = 'visafter';
cfg.trialdef.visualtrigwin = 0.2;
cfg = ft_definetrial(cfg);

% if no visual trigger was recorded:
% cfg.trl(:,[1 2]) = cfg.trl(:,[1 2]) + 36;

% creating colume 7 with correct code
cfg.trl(1:length(cfg.trl),7) = 0;
for i=1:length(cfg.trl)
	if ((cfg.trl(i,4)==222) && (cfg.trl(i,6)==512)) % Hand No Pain
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==230) && (cfg.trl(i,6)==256)) % Hand Pain
        cfg.trl(i,7)=1;
	elseif ((cfg.trl(i,4)==240) && (cfg.trl(i,6)==512)) % Leg No Pain
        cfg.trl(i,7)=1; 
	elseif ((cfg.trl(i,4)==250) && (cfg.trl(i,6)==256)) % Leg Pain
        cfg.trl(i,7)=1; 
    end;
end;

% 3. preprocessing for muscle artifact rejection
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-0.3,0];
cfg.trialdef.prestim    = 0.8;
cfg.trialdef.poststim   = 1.2;
cfg.trialdef.offset=-0.8;
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
cfg.trl(:,3) = -814; % change according to your offset in samples!!!
cfg.trl(:,[4:7]) = datacln.trialinfo;

% 5.1 preprocessing original data without the bad trials
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.baselinewindow=[-0.3,0];
cfg.trialdef.prestim    = 0.8;
cfg.trialdef.poststim   = 1.2;
cfg.trialdef.offset=-0.8;
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

% run the ICA on the original data
cfg = [];
cfg.topo      = comp_dummy.topo;
cfg.topolabel = comp_dummy.topolabel;
comp     = ft_componentanalysis(cfg, dataorig);

% remove the artifact components
cfg = [];
cfg.component = [1]; % change
dataica = ft_rejectcomponent(cfg, comp);

clear comp_dummy comppic comp dummy

% 7. base line correction
dataica=correctBL(dataica,[-0.3 0]);

% 8. trial by trial
cfg=[];
cfg.method='trial'; % 'channel'
cfg.channel=channels;
cfg1.bpfilter='yes';
cfg1.bpfreq=[1 40];
datafinal=ft_rejectvisual(cfg, dataica);

% 8.1 summary
cfg=[];
cfg.method='summary'; % 'channel'
datafinal=ft_rejectvisual(cfg, datafinal);

% 9. recreating the trl matrix
datafinal.cfg.trl(:,1:2)=datafinal.sampleinfo(:,1:2);
datafinal.cfg.trl(:,3)=-814; % the offset
datafinal.cfg.trl(:,4:7)=datafinal.trialinfo(:,1:4);

% if channel A41 was removed (if and only if!!!!!!)
% datafinal = interpolateA41(datafinal)

% 10. split conditions
cfg=[];
for i = [222 230 240 250]
    eval(['cfg.cond=',num2str(i),';']);
    eval(['con',num2str(i),'=splitconds(cfg,datafinal);']);
end;

% for combining two or more datasets use: 
cfg=[];
pain=ft_appenddata(cfg, con230, con250);
noPain=ft_appenddata(cfg, con222, con240);

save splitconds pain noPain

% 11. averaging
eval(['conSub',num2str(sub),'pain=ft_timelockanalysis([], pain);']);
eval(['conSub',num2str(sub),'noPain=ft_timelockanalysis([], noPain);']);
eval(['conSub',num2str(sub),'all=ft_timelockanalysis([], datafinal);']);

eval(['save ERFaverages conSub',num2str(sub),'all conSub',num2str(sub),'pain conSub',num2str(sub),'noPain'])
clear all;
load ERFaverages

% 12. Plots
sub=12; % change sub number
% Butterfly
figure;
eval(['plot(conSub',num2str(sub),'all.time, conSub',num2str(sub),'all.avg,''b'')']);
hold on;
plot([0 0],[2*10^(-13) -2*10^(-13)],'k');
grid on;
axis tight;


figure;
eval(['plot(conSub',num2str(sub),'pain.time, conSub',num2str(sub),'pain.avg,''b'')']);
hold on;
eval(['plot(conSub',num2str(sub),'noPain.time, conSub',num2str(sub),'noPain.avg,''r'')']);
plot([0 0],[2*10^(-13) -2*10^(-13)],'k');
text(-0.025,-2.05*10^(-13),'stimulus onset');
xlabel('time in ms');
ylabel('amplitude');
title('blue - pain, red - no pain');
grid on;
axis tight;

%% RMS
% load data
clear all
for i=1:12
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load ERFaverages
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    load ERFaverages
end;
cd ..
cd ..
% RMS
for i=1:12
    eval(['conSub',num2str(i),'allRMS=sqrt(mean(conSub',num2str(i),'all.avg(:,1:2034).^2))-mean(sqrt(mean(conSub',num2str(i),'all.avg(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'allRMS=sqrt(mean(fmSub',num2str(i),'all.avg(:,1:2034).^2))-mean(sqrt(mean(fmSub',num2str(i),'all.avg(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'noPainRMS=sqrt(mean(conSub',num2str(i),'noPain.avg(:,1:2034).^2))-mean(sqrt(mean(conSub',num2str(i),'noPain.avg(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'noPainRMS=sqrt(mean(fmSub',num2str(i),'noPain.avg(:,1:2034).^2))-mean(sqrt(mean(fmSub',num2str(i),'noPain.avg(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'painRMS=sqrt(mean(conSub',num2str(i),'pain.avg(:,1:2034).^2))-mean(sqrt(mean(conSub',num2str(i),'pain.avg(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'painRMS=sqrt(mean(fmSub',num2str(i),'pain.avg(:,1:2034).^2))-mean(sqrt(mean(fmSub',num2str(i),'pain.avg(:,511:815).^2)));']);
end;
% all subs matrices
for i=1:12
    eval(['conAllRMS.subs(i,:)=conSub',num2str(i),'allRMS;']);
    eval(['fmAllRMS.subs(i,:)=fmSub',num2str(i),'allRMS;']);
    eval(['conNoPainRMS.subs(i,:)=conSub',num2str(i),'noPainRMS;']);
    eval(['fmNoPainRMS.subs(i,:)=fmSub',num2str(i),'noPainRMS;']);
    eval(['conPainRMS.subs(i,:)=conSub',num2str(i),'painRMS;']);
    eval(['fmPainRMS.subs(i,:)=fmSub',num2str(i),'painRMS;']);
end;
% means and sds
conAllRMS.mean = mean(conAllRMS.subs);
fmAllRMS.mean = mean(fmAllRMS.subs);
conNoPainRMS.mean = mean(conNoPainRMS.subs);
fmNoPainRMS.mean = mean(fmNoPainRMS.subs);
conPainRMS.mean = mean(conPainRMS.subs);
fmPainRMS.mean = mean(fmPainRMS.subs);
conAllRMS.sd = std(conAllRMS.subs);
fmAllRMS.sd = std(fmAllRMS.subs);
conNoPainRMS.sd = std(conNoPainRMS.subs);
fmNoPainRMS.sd = std(fmNoPainRMS.subs);
conPainRMS.sd = std(conPainRMS.subs);
fmPainRMS.sd = std(fmPainRMS.subs);

save RMS conAllRMS fmAllRMS conNoPainRMS fmNoPainRMS conPainRMS fmPainRMS
clear all
load RMS
load time
% plotting
figure
h1 = plot(time,conAllRMS.mean,'b')
hold on;
h2 = plot(time,fmAllRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conAllRMS.mean+conAllRMS.sd,conAllRMS.mean-conAllRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmAllRMS.mean+fmAllRMS.sd,fmAllRMS.mean-fmAllRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RMS');
title('RMS for all conditions: Blue - control, Red - fibros');

figure
subplot(2,1,1)
h1 = plot(time,conNoPainRMS.mean,'b')
hold on;
h2 = plot(time,fmNoPainRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainRMS.mean+conNoPainRMS.sd,conNoPainRMS.mean-conNoPainRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmNoPainRMS.mean+fmNoPainRMS.sd,fmNoPainRMS.mean-fmNoPainRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RMS');
title('RMS for No Pain: Blue - control, Red - fibros');

subplot(2,1,2)
h1 = plot(time,conPainRMS.mean,'b')
hold on;
h2 = plot(time,fmPainRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conPainRMS.mean+conPainRMS.sd,conPainRMS.mean-conPainRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainRMS.mean+fmPainRMS.sd,fmPainRMS.mean-fmPainRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RMS');
title('RMS for Pain: Blue - control, Red - fibros');

% pain vs no pain in each group
figure
subplot(2,1,1)
h1 = plot(time,conNoPainRMS.mean,'b')
hold on;
h2 = plot(time,conPainRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainRMS.mean+conNoPainRMS.sd,conNoPainRMS.mean-conNoPainRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conPainRMS.mean+conPainRMS.sd,conPainRMS.mean-conPainRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RMS');
title('RMS for control: Blue - No Pain, Red - Pain');

subplot(2,1,2)
h1 = plot(time,fmNoPainRMS.mean,'b')
hold on;
h2 = plot(time,fmPainRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,fmNoPainRMS.mean+fmNoPainRMS.sd,fmNoPainRMS.mean-fmNoPainRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainRMS.mean+fmPainRMS.sd,fmPainRMS.mean-fmPainRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RMS');
title('RMS for fibros: Blue - No Pain, Red - Pain');

%% RMS Left Right Front Back
% load data
clear all
for i=1:12
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load ERFaverages
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    load ERFaverages
end;
cd ..
cd ..
% Left Front channels
LF = [6:9 20:24 38:43 62:68 90:97 122:129 153:157 177:179 196 197 212 213 229:232];
a=1;
for chan=LF
    eval(['LFchans{a} = ''A',num2str(chan),''';']);
    a=a+1;
end;
LFchans = LFchans';

% Right Front channels
RF = [15:18 32:36 55:60 82:88 113:120 145:152 172:176 193:195 210 211 227 228 245:248];
a=1;
for chan=RF
    eval(['RFchans{a} = ''A',num2str(chan),''';']);
    a=a+1;
end;
RFchans = RFchans';

% Left Back channels
LB = [11 26 27 45:48 70:74 99:104 131:136 159:164 180:185 199:203 214:219 234:238];
a=1;
for chan=LB
    eval(['LBchans{a} = ''A',num2str(chan),''';']);
    a=a+1;
end;
LBchans = LBchans';

% Right Back channels
RB = [13 29 30 50:53 76:80 106:111 138:143 165:170 187:192 204:208 221:226 239:243];
a=1;
for chan=RB
    eval(['RBchans{a} = ''A',num2str(chan),''';']);
    a=a+1;
end;
RBchans = RBchans';

% LF RMS
for i=1:12
    eval(['conSub',num2str(i),'allLFRMS=conSub',num2str(i),'all.avg(find(ismember(conSub',num2str(i),'all.label,LFchans)),1:2034);']);
    eval(['conSub',num2str(i),'allLFRMS=sqrt(mean(conSub',num2str(i),'allLFRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'allLFRMS(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'painLFRMS=conSub',num2str(i),'pain.avg(find(ismember(conSub',num2str(i),'pain.label,LFchans)),1:2034);']);
    eval(['conSub',num2str(i),'painLFRMS=sqrt(mean(conSub',num2str(i),'painLFRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'painLFRMS(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'noPainLFRMS=conSub',num2str(i),'noPain.avg(find(ismember(conSub',num2str(i),'noPain.label,LFchans)),1:2034);']);
    eval(['conSub',num2str(i),'noPainLFRMS=sqrt(mean(conSub',num2str(i),'noPainLFRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'noPainLFRMS(:,511:815).^2)));']);
    
    eval(['fmSub',num2str(i),'allLFRMS=fmSub',num2str(i),'all.avg(find(ismember(fmSub',num2str(i),'all.label,LFchans)),1:2034);']);
    eval(['fmSub',num2str(i),'allLFRMS=sqrt(mean(fmSub',num2str(i),'allLFRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'allLFRMS(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'painLFRMS=fmSub',num2str(i),'pain.avg(find(ismember(fmSub',num2str(i),'pain.label,LFchans)),1:2034);']);
    eval(['fmSub',num2str(i),'painLFRMS=sqrt(mean(fmSub',num2str(i),'painLFRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'painLFRMS(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'noPainLFRMS=fmSub',num2str(i),'noPain.avg(find(ismember(fmSub',num2str(i),'noPain.label,LFchans)),1:2034);']);
    eval(['fmSub',num2str(i),'noPainLFRMS=sqrt(mean(fmSub',num2str(i),'noPainLFRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'noPainLFRMS(:,511:815).^2)));']);
end

for i=1:12
    eval(['conAllLFRMS.subs(i,:)=conSub',num2str(i),'allLFRMS;']);
    eval(['fmAllLFRMS.subs(i,:)=fmSub',num2str(i),'allLFRMS;']);
    eval(['conNoPainLFRMS.subs(i,:)=conSub',num2str(i),'noPainLFRMS;']);
    eval(['fmNoPainLFRMS.subs(i,:)=fmSub',num2str(i),'noPainLFRMS;']);
    eval(['conPainLFRMS.subs(i,:)=conSub',num2str(i),'painLFRMS;']);
    eval(['fmPainLFRMS.subs(i,:)=fmSub',num2str(i),'painLFRMS;']);
end;

% RF RMS
for i=1:12
    eval(['conSub',num2str(i),'allRFRMS=conSub',num2str(i),'all.avg(find(ismember(conSub',num2str(i),'all.label,RFchans)),1:2034);']);
    eval(['conSub',num2str(i),'allRFRMS=sqrt(mean(conSub',num2str(i),'allRFRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'allRFRMS(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'painRFRMS=conSub',num2str(i),'pain.avg(find(ismember(conSub',num2str(i),'pain.label,RFchans)),1:2034);']);
    eval(['conSub',num2str(i),'painRFRMS=sqrt(mean(conSub',num2str(i),'painRFRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'painRFRMS(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'noPainRFRMS=conSub',num2str(i),'noPain.avg(find(ismember(conSub',num2str(i),'noPain.label,RFchans)),1:2034);']);
    eval(['conSub',num2str(i),'noPainRFRMS=sqrt(mean(conSub',num2str(i),'noPainRFRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'noPainRFRMS(:,511:815).^2)));']);
    
    eval(['fmSub',num2str(i),'allRFRMS=fmSub',num2str(i),'all.avg(find(ismember(fmSub',num2str(i),'all.label,RFchans)),1:2034);']);
    eval(['fmSub',num2str(i),'allRFRMS=sqrt(mean(fmSub',num2str(i),'allRFRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'allRFRMS(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'painRFRMS=fmSub',num2str(i),'pain.avg(find(ismember(fmSub',num2str(i),'pain.label,RFchans)),1:2034);']);
    eval(['fmSub',num2str(i),'painRFRMS=sqrt(mean(fmSub',num2str(i),'painRFRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'painRFRMS(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'noPainRFRMS=fmSub',num2str(i),'noPain.avg(find(ismember(fmSub',num2str(i),'noPain.label,RFchans)),1:2034);']);
    eval(['fmSub',num2str(i),'noPainRFRMS=sqrt(mean(fmSub',num2str(i),'noPainRFRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'noPainRFRMS(:,511:815).^2)));']);
end

for i=1:12
    eval(['conAllRFRMS.subs(i,:)=conSub',num2str(i),'allRFRMS;']);
    eval(['fmAllRFRMS.subs(i,:)=fmSub',num2str(i),'allRFRMS;']);
    eval(['conNoPainRFRMS.subs(i,:)=conSub',num2str(i),'noPainRFRMS;']);
    eval(['fmNoPainRFRMS.subs(i,:)=fmSub',num2str(i),'noPainRFRMS;']);
    eval(['conPainRFRMS.subs(i,:)=conSub',num2str(i),'painRFRMS;']);
    eval(['fmPainRFRMS.subs(i,:)=fmSub',num2str(i),'painRFRMS;']);
end;

% LB RMS
for i=1:12
    eval(['conSub',num2str(i),'allLBRMS=conSub',num2str(i),'all.avg(find(ismember(conSub',num2str(i),'all.label,LBchans)),1:2034);']);
    eval(['conSub',num2str(i),'allLBRMS=sqrt(mean(conSub',num2str(i),'allLBRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'allLBRMS(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'painLBRMS=conSub',num2str(i),'pain.avg(find(ismember(conSub',num2str(i),'pain.label,LBchans)),1:2034);']);
    eval(['conSub',num2str(i),'painLBRMS=sqrt(mean(conSub',num2str(i),'painLBRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'painLBRMS(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'noPainLBRMS=conSub',num2str(i),'noPain.avg(find(ismember(conSub',num2str(i),'noPain.label,LBchans)),1:2034);']);
    eval(['conSub',num2str(i),'noPainLBRMS=sqrt(mean(conSub',num2str(i),'noPainLBRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'noPainLBRMS(:,511:815).^2)));']);
    
    eval(['fmSub',num2str(i),'allLBRMS=fmSub',num2str(i),'all.avg(find(ismember(fmSub',num2str(i),'all.label,LBchans)),1:2034);']);
    eval(['fmSub',num2str(i),'allLBRMS=sqrt(mean(fmSub',num2str(i),'allLBRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'allLBRMS(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'painLBRMS=fmSub',num2str(i),'pain.avg(find(ismember(fmSub',num2str(i),'pain.label,LBchans)),1:2034);']);
    eval(['fmSub',num2str(i),'painLBRMS=sqrt(mean(fmSub',num2str(i),'painLBRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'painLBRMS(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'noPainLBRMS=fmSub',num2str(i),'noPain.avg(find(ismember(fmSub',num2str(i),'noPain.label,LBchans)),1:2034);']);
    eval(['fmSub',num2str(i),'noPainLBRMS=sqrt(mean(fmSub',num2str(i),'noPainLBRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'noPainLBRMS(:,511:815).^2)));']);
end

for i=1:12
    eval(['conAllLBRMS.subs(i,:)=conSub',num2str(i),'allLBRMS;']);
    eval(['fmAllLBRMS.subs(i,:)=fmSub',num2str(i),'allLBRMS;']);
    eval(['conNoPainLBRMS.subs(i,:)=conSub',num2str(i),'noPainLBRMS;']);
    eval(['fmNoPainLBRMS.subs(i,:)=fmSub',num2str(i),'noPainLBRMS;']);
    eval(['conPainLBRMS.subs(i,:)=conSub',num2str(i),'painLBRMS;']);
    eval(['fmPainLBRMS.subs(i,:)=fmSub',num2str(i),'painLBRMS;']);
end;

% RB RMS
for i=1:12
    eval(['conSub',num2str(i),'allRBRMS=conSub',num2str(i),'all.avg(find(ismember(conSub',num2str(i),'all.label,RBchans)),1:2034);']);
    eval(['conSub',num2str(i),'allRBRMS=sqrt(mean(conSub',num2str(i),'allRBRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'allRBRMS(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'painRBRMS=conSub',num2str(i),'pain.avg(find(ismember(conSub',num2str(i),'pain.label,RBchans)),1:2034);']);
    eval(['conSub',num2str(i),'painRBRMS=sqrt(mean(conSub',num2str(i),'painRBRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'painRBRMS(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'noPainRBRMS=conSub',num2str(i),'noPain.avg(find(ismember(conSub',num2str(i),'noPain.label,RBchans)),1:2034);']);
    eval(['conSub',num2str(i),'noPainRBRMS=sqrt(mean(conSub',num2str(i),'noPainRBRMS.^2))-mean(sqrt(mean(conSub',num2str(i),'noPainRBRMS(:,511:815).^2)));']);
    
    eval(['fmSub',num2str(i),'allRBRMS=fmSub',num2str(i),'all.avg(find(ismember(fmSub',num2str(i),'all.label,RBchans)),1:2034);']);
    eval(['fmSub',num2str(i),'allRBRMS=sqrt(mean(fmSub',num2str(i),'allRBRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'allRBRMS(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'painRBRMS=fmSub',num2str(i),'pain.avg(find(ismember(fmSub',num2str(i),'pain.label,RBchans)),1:2034);']);
    eval(['fmSub',num2str(i),'painRBRMS=sqrt(mean(fmSub',num2str(i),'painRBRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'painRBRMS(:,511:815).^2)));']);
    eval(['fmSub',num2str(i),'noPainRBRMS=fmSub',num2str(i),'noPain.avg(find(ismember(fmSub',num2str(i),'noPain.label,RBchans)),1:2034);']);
    eval(['fmSub',num2str(i),'noPainRBRMS=sqrt(mean(fmSub',num2str(i),'noPainRBRMS.^2))-mean(sqrt(mean(fmSub',num2str(i),'noPainRBRMS(:,511:815).^2)));']);
end

for i=1:12
    eval(['conAllRBRMS.subs(i,:)=conSub',num2str(i),'allRBRMS;']);
    eval(['fmAllRBRMS.subs(i,:)=fmSub',num2str(i),'allRBRMS;']);
    eval(['conNoPainRBRMS.subs(i,:)=conSub',num2str(i),'noPainRBRMS;']);
    eval(['fmNoPainRBRMS.subs(i,:)=fmSub',num2str(i),'noPainRBRMS;']);
    eval(['conPainRBRMS.subs(i,:)=conSub',num2str(i),'painRBRMS;']);
    eval(['fmPainRBRMS.subs(i,:)=fmSub',num2str(i),'painRBRMS;']);
end;

save RMSLRFB conAllRBRMS fmAllRBRMS conNoPainRBRMS fmNoPainRBRMS conPainRBRMS fmPainRBRMS...
    conAllLBRMS fmAllLBRMS conNoPainLBRMS fmNoPainLBRMS conPainLBRMS fmPainLBRMS...
    conAllLFRMS fmAllLFRMS conNoPainLFRMS fmNoPainLFRMS conPainLFRMS fmPainLFRMS...
    conAllRFRMS fmAllRFRMS conNoPainRFRMS fmNoPainRFRMS conPainRFRMS fmPainRFRMS
clear all
load RMSLRFB
load time

%% means sds and ploting for LFRMS
% means and sds
conAllLFRMS.mean = mean(conAllLFRMS.subs);
fmAllLFRMS.mean = mean(fmAllLFRMS.subs);
conNoPainLFRMS.mean = mean(conNoPainLFRMS.subs);
fmNoPainLFRMS.mean = mean(fmNoPainLFRMS.subs);
conPainLFRMS.mean = mean(conPainLFRMS.subs);
fmPainLFRMS.mean = mean(fmPainLFRMS.subs);
conAllLFRMS.sd = std(conAllLFRMS.subs);
fmAllLFRMS.sd = std(fmAllLFRMS.subs);
conNoPainLFRMS.sd = std(conNoPainLFRMS.subs);
fmNoPainLFRMS.sd = std(fmNoPainLFRMS.subs);
conPainLFRMS.sd = std(conPainLFRMS.subs);
fmPainLFRMS.sd = std(fmPainLFRMS.subs);

% plotting
figure
h1 = plot(time,conAllLFRMS.mean,'b')
hold on;
h2 = plot(time,fmAllLFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conAllLFRMS.mean+conAllLFRMS.sd,conAllLFRMS.mean-conAllLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmAllLFRMS.mean+fmAllLFRMS.sd,fmAllLFRMS.mean-fmAllLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LFRMS');
title('LFRMS for all conditions: Blue - control, Red - fibros');

figure
subplot(2,1,1)
h1 = plot(time,conNoPainLFRMS.mean,'b')
hold on;
h2 = plot(time,fmNoPainLFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainLFRMS.mean+conNoPainLFRMS.sd,conNoPainLFRMS.mean-conNoPainLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmNoPainLFRMS.mean+fmNoPainLFRMS.sd,fmNoPainLFRMS.mean-fmNoPainLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LFRMS');
title('LFRMS for No Pain: Blue - control, Red - fibros');

subplot(2,1,2)
h1 = plot(time,conPainLFRMS.mean,'b')
hold on;
h2 = plot(time,fmPainLFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conPainLFRMS.mean+conPainLFRMS.sd,conPainLFRMS.mean-conPainLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainLFRMS.mean+fmPainLFRMS.sd,fmPainLFRMS.mean-fmPainLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LFRMS');
title('LFRMS for Pain: Blue - control, Red - fibros');

% pain vs no pain in each group
figure
subplot(2,1,1)
h1 = plot(time,conNoPainLFRMS.mean,'b')
hold on;
h2 = plot(time,conPainLFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainLFRMS.mean+conNoPainLFRMS.sd,conNoPainLFRMS.mean-conNoPainLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conPainLFRMS.mean+conPainLFRMS.sd,conPainLFRMS.mean-conPainLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LFRMS');
title('LFRMS for control: Blue - No Pain, Red - Pain');

subplot(2,1,2)
h1 = plot(time,fmNoPainLFRMS.mean,'b')
hold on;
h2 = plot(time,fmPainLFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,fmNoPainLFRMS.mean+fmNoPainLFRMS.sd,fmNoPainLFRMS.mean-fmNoPainLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainLFRMS.mean+fmPainLFRMS.sd,fmPainLFRMS.mean-fmPainLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LFRMS');
title('LFRMS for fibros: Blue - No Pain, Red - Pain');

%% means sds and ploting for RFRMS
% means and sds
conAllRFRMS.mean = mean(conAllRFRMS.subs);
fmAllRFRMS.mean = mean(fmAllRFRMS.subs);
conNoPainRFRMS.mean = mean(conNoPainRFRMS.subs);
fmNoPainRFRMS.mean = mean(fmNoPainRFRMS.subs);
conPainRFRMS.mean = mean(conPainRFRMS.subs);
fmPainRFRMS.mean = mean(fmPainRFRMS.subs);
conAllRFRMS.sd = std(conAllRFRMS.subs);
fmAllRFRMS.sd = std(fmAllRFRMS.subs);
conNoPainRFRMS.sd = std(conNoPainRFRMS.subs);
fmNoPainRFRMS.sd = std(fmNoPainRFRMS.subs);
conPainRFRMS.sd = std(conPainRFRMS.subs);
fmPainRFRMS.sd = std(fmPainRFRMS.subs);

% plotting
figure
h1 = plot(time,conAllRFRMS.mean,'b')
hold on;
h2 = plot(time,fmAllRFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conAllRFRMS.mean+conAllRFRMS.sd,conAllRFRMS.mean-conAllRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmAllRFRMS.mean+fmAllRFRMS.sd,fmAllRFRMS.mean-fmAllRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RFRMS');
title('RFRMS for all conditions: Blue - control, Red - fibros');

figure
subplot(2,1,1)
h1 = plot(time,conNoPainRFRMS.mean,'b')
hold on;
h2 = plot(time,fmNoPainRFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainRFRMS.mean+conNoPainRFRMS.sd,conNoPainRFRMS.mean-conNoPainRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmNoPainRFRMS.mean+fmNoPainRFRMS.sd,fmNoPainRFRMS.mean-fmNoPainRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RFRMS');
title('RFRMS for No Pain: Blue - control, Red - fibros');

subplot(2,1,2)
h1 = plot(time,conPainRFRMS.mean,'b')
hold on;
h2 = plot(time,fmPainRFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conPainRFRMS.mean+conPainRFRMS.sd,conPainRFRMS.mean-conPainRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainRFRMS.mean+fmPainRFRMS.sd,fmPainRFRMS.mean-fmPainRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RFRMS');
title('RFRMS for Pain: Blue - control, Red - fibros');

% pain vs no pain in each group
figure
subplot(2,1,1)
h1 = plot(time,conNoPainRFRMS.mean,'b')
hold on;
h2 = plot(time,conPainRFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainRFRMS.mean+conNoPainRFRMS.sd,conNoPainRFRMS.mean-conNoPainRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conPainRFRMS.mean+conPainRFRMS.sd,conPainRFRMS.mean-conPainRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RFRMS');
title('RFRMS for control: Blue - No Pain, Red - Pain');

subplot(2,1,2)
h1 = plot(time,fmNoPainRFRMS.mean,'b')
hold on;
h2 = plot(time,fmPainRFRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,fmNoPainRFRMS.mean+fmNoPainRFRMS.sd,fmNoPainRFRMS.mean-fmNoPainRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainRFRMS.mean+fmPainRFRMS.sd,fmPainRFRMS.mean-fmPainRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RFRMS');
title('RFRMS for fibros: Blue - No Pain, Red - Pain');

%% means sds and ploting for LBRMS
% means and sds
conAllLBRMS.mean = mean(conAllLBRMS.subs);
fmAllLBRMS.mean = mean(fmAllLBRMS.subs);
conNoPainLBRMS.mean = mean(conNoPainLBRMS.subs);
fmNoPainLBRMS.mean = mean(fmNoPainLBRMS.subs);
conPainLBRMS.mean = mean(conPainLBRMS.subs);
fmPainLBRMS.mean = mean(fmPainLBRMS.subs);
conAllLBRMS.sd = std(conAllLBRMS.subs);
fmAllLBRMS.sd = std(fmAllLBRMS.subs);
conNoPainLBRMS.sd = std(conNoPainLBRMS.subs);
fmNoPainLBRMS.sd = std(fmNoPainLBRMS.subs);
conPainLBRMS.sd = std(conPainLBRMS.subs);
fmPainLBRMS.sd = std(fmPainLBRMS.subs);

% plotting
figure
h1 = plot(time,conAllLBRMS.mean,'b')
hold on;
h2 = plot(time,fmAllLBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conAllLBRMS.mean+conAllLBRMS.sd,conAllLBRMS.mean-conAllLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmAllLBRMS.mean+fmAllLBRMS.sd,fmAllLBRMS.mean-fmAllLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LBRMS');
title('LBRMS for all conditions: Blue - control, Red - fibros');

figure
subplot(2,1,1)
h1 = plot(time,conNoPainLBRMS.mean,'b')
hold on;
h2 = plot(time,fmNoPainLBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainLBRMS.mean+conNoPainLBRMS.sd,conNoPainLBRMS.mean-conNoPainLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmNoPainLBRMS.mean+fmNoPainLBRMS.sd,fmNoPainLBRMS.mean-fmNoPainLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LBRMS');
title('LBRMS for No Pain: Blue - control, Red - fibros');

subplot(2,1,2)
h1 = plot(time,conPainLBRMS.mean,'b')
hold on;
h2 = plot(time,fmPainLBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conPainLBRMS.mean+conPainLBRMS.sd,conPainLBRMS.mean-conPainLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainLBRMS.mean+fmPainLBRMS.sd,fmPainLBRMS.mean-fmPainLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LBRMS');
title('LBRMS for Pain: Blue - control, Red - fibros');

% pain vs no pain in each group
figure
subplot(2,1,1)
h1 = plot(time,conNoPainLBRMS.mean,'b')
hold on;
h2 = plot(time,conPainLBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainLBRMS.mean+conNoPainLBRMS.sd,conNoPainLBRMS.mean-conNoPainLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conPainLBRMS.mean+conPainLBRMS.sd,conPainLBRMS.mean-conPainLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LBRMS');
title('LBRMS for control: Blue - No Pain, Red - Pain');

subplot(2,1,2)
h1 = plot(time,fmNoPainLBRMS.mean,'b')
hold on;
h2 = plot(time,fmPainLBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,fmNoPainLBRMS.mean+fmNoPainLBRMS.sd,fmNoPainLBRMS.mean-fmNoPainLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainLBRMS.mean+fmPainLBRMS.sd,fmPainLBRMS.mean-fmPainLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('LBRMS');
title('LBRMS for fibros: Blue - No Pain, Red - Pain');

%% means sds and ploting for RBRMS
% means and sds
conAllRBRMS.mean = mean(conAllRBRMS.subs);
fmAllRBRMS.mean = mean(fmAllRBRMS.subs);
conNoPainRBRMS.mean = mean(conNoPainRBRMS.subs);
fmNoPainRBRMS.mean = mean(fmNoPainRBRMS.subs);
conPainRBRMS.mean = mean(conPainRBRMS.subs);
fmPainRBRMS.mean = mean(fmPainRBRMS.subs);
conAllRBRMS.sd = std(conAllRBRMS.subs);
fmAllRBRMS.sd = std(fmAllRBRMS.subs);
conNoPainRBRMS.sd = std(conNoPainRBRMS.subs);
fmNoPainRBRMS.sd = std(fmNoPainRBRMS.subs);
conPainRBRMS.sd = std(conPainRBRMS.subs);
fmPainRBRMS.sd = std(fmPainRBRMS.subs);

% plotting
figure
h1 = plot(time,conAllRBRMS.mean,'b')
hold on;
h2 = plot(time,fmAllRBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conAllRBRMS.mean+conAllRBRMS.sd,conAllRBRMS.mean-conAllRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmAllRBRMS.mean+fmAllRBRMS.sd,fmAllRBRMS.mean-fmAllRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RBRMS');
title('RBRMS for all conditions: Blue - control, Red - fibros');

figure
subplot(2,1,1)
h1 = plot(time,conNoPainRBRMS.mean,'b')
hold on;
h2 = plot(time,fmNoPainRBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainRBRMS.mean+conNoPainRBRMS.sd,conNoPainRBRMS.mean-conNoPainRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmNoPainRBRMS.mean+fmNoPainRBRMS.sd,fmNoPainRBRMS.mean-fmNoPainRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RBRMS');
title('RBRMS for No Pain: Blue - control, Red - fibros');

subplot(2,1,2)
h1 = plot(time,conPainRBRMS.mean,'b')
hold on;
h2 = plot(time,fmPainRBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conPainRBRMS.mean+conPainRBRMS.sd,conPainRBRMS.mean-conPainRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainRBRMS.mean+fmPainRBRMS.sd,fmPainRBRMS.mean-fmPainRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RBRMS');
title('RBRMS for Pain: Blue - control, Red - fibros');

% pain vs no pain in each group
figure
subplot(2,1,1)
h1 = plot(time,conNoPainRBRMS.mean,'b')
hold on;
h2 = plot(time,conPainRBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conNoPainRBRMS.mean+conNoPainRBRMS.sd,conNoPainRBRMS.mean-conNoPainRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conPainRBRMS.mean+conPainRBRMS.sd,conPainRBRMS.mean-conPainRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RBRMS');
title('RBRMS for control: Blue - No Pain, Red - Pain');

subplot(2,1,2)
h1 = plot(time,fmNoPainRBRMS.mean,'b')
hold on;
h2 = plot(time,fmPainRBRMS.mean,'r')
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,fmNoPainRBRMS.mean+fmNoPainRBRMS.sd,fmNoPainRBRMS.mean-fmNoPainRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainRBRMS.mean+fmPainRBRMS.sd,fmPainRBRMS.mean-fmPainRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RBRMS');
title('RBRMS for fibros: Blue - No Pain, Red - Pain');

%% Behavioral Data
clear all
for i=1:12
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load ERFaverages
    eval(['ERcon(i,1) = length(conSub',num2str(i),'all.cfg.previous.trl(:,7))-sum(conSub',num2str(i),'all.cfg.previous.trl(:,7))']);
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    load ERFaverages
    eval(['ERfm(i,1) = length(fmSub',num2str(i),'all.cfg.previous.trl(:,7))-sum(fmSub',num2str(i),'all.cfg.previous.trl(:,7))']);
end;

