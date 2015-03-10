%% Prof. Abeles and Tal clean files scripts:

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
sub=1;
eval(['cd /media/My_Passport/fibrodata/con/con',num2str(sub)])

source='xc,hb,lf_c,rfhp0.1Hz';

% 1. find Bad Channels
findBadChans(source);
%original_source='c,rfhp0.1Hz';% we added this line to compare between the data before and after cleaning with the Abeles fucntion
%findBadChans(original_source);
channels = {'MEG'}; % channels = {'MEG','-A41'};

% 2. finding trials and defining them
conditions = [222 230 240 250]; % pain - 230, 250; noPain - 222, 240
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
    if ((cfg.trl(i,4)==222) && (cfg.trl(i,6)==512))
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==230) && (cfg.trl(i,6)==256))
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==240) && (cfg.trl(i,6)==512))
        cfg.trl(i,7)=1;
    elseif ((cfg.trl(i,4)==250) && (cfg.trl(i,6)==256))
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
cfg.trl(:,4:7) = datacln.trialinfo;

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
cfg.component = [1 2 8 9]; % change
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
for i = [222 230 240 250]
    eval(['cfg.cond=',num2str(i),';']);
    eval(['con',num2str(i),'=splitconds(cfg, datafinal);']);
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
sub=14; % change sub number
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
for i=1:14
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load ERFaverages
end;
for j=[1:7 9:20]
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(j)]);
    load ERFaverages
end;
cd ..
cd ..
% RMS
for i=1:14
    eval(['conSub',num2str(i),'allRMS=sqrt(mean(conSub',num2str(i),'all.avg(:,1:2034).^2))-mean(sqrt(mean(conSub',num2str(i),'all.avg(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'noPainRMS=sqrt(mean(conSub',num2str(i),'noPain.avg(:,1:2034).^2))-mean(sqrt(mean(conSub',num2str(i),'noPain.avg(:,511:815).^2)));']);
    eval(['conSub',num2str(i),'painRMS=sqrt(mean(conSub',num2str(i),'pain.avg(:,1:2034).^2))-mean(sqrt(mean(conSub',num2str(i),'pain.avg(:,511:815).^2)));']);
end;
for j=[1:7 9:20]
    eval(['fmSub',num2str(j),'allRMS=sqrt(mean(fmSub',num2str(j),'all.avg(:,1:2034).^2))-mean(sqrt(mean(fmSub',num2str(j),'all.avg(:,511:815).^2)));']);
    eval(['fmSub',num2str(j),'noPainRMS=sqrt(mean(fmSub',num2str(j),'noPain.avg(:,1:2034).^2))-mean(sqrt(mean(fmSub',num2str(j),'noPain.avg(:,511:815).^2)));']);
    eval(['fmSub',num2str(j),'painRMS=sqrt(mean(fmSub',num2str(j),'pain.avg(:,1:2034).^2))-mean(sqrt(mean(fmSub',num2str(j),'pain.avg(:,511:815).^2)));']);
end;
% all subs matrices
for i=1:14
    eval(['conAllRMS.subs(i,:)=conSub',num2str(i),'allRMS;']);
    eval(['conNoPainRMS.subs(i,:)=conSub',num2str(i),'noPainRMS;']);
    eval(['conPainRMS.subs(i,:)=conSub',num2str(i),'painRMS;']);
end;
for j=[1:7 9:20]
    if j > 8
        eval(['fmAllRMS.subs(j-1,:)=fmSub',num2str(j),'allRMS;']);
        eval(['fmNoPainRMS.subs(j-1,:)=fmSub',num2str(j),'noPainRMS;']);
        eval(['fmPainRMS.subs(j-1,:)=fmSub',num2str(j),'painRMS;']);
    else
        eval(['fmAllRMS.subs(j,:)=fmSub',num2str(j),'allRMS;']);
        eval(['fmNoPainRMS.subs(j,:)=fmSub',num2str(j),'noPainRMS;']);
        eval(['fmPainRMS.subs(j,:)=fmSub',num2str(j),'painRMS;']);
    end
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

save RMS2 conAllRMS fmAllRMS conNoPainRMS fmNoPainRMS conPainRMS fmPainRMS
clear all
load RMS2
load time
% plotting
figure
h1 = plot(time,conAllRMS.mean,'b');
hold on;
h2 = plot(time,fmAllRMS.mean,'r');
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
h1 = plot(time,conNoPainRMS.mean,'b');
hold on;
h2 = plot(time,fmNoPainRMS.mean,'r');
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
h1 = plot(time,conPainRMS.mean,'b');
hold on;
h2 = plot(time,fmPainRMS.mean,'r');
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
h1 = plot(time,conNoPainRMS.mean,'b');
hold on;
h2 = plot(time,conPainRMS.mean,'r');
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
h1 = plot(time,fmNoPainRMS.mean,'b');
hold on;
h2 = plot(time,fmPainRMS.mean,'r');
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
h1 = plot(time,conAllLFRMS.mean,'b');
hold on;
h2 = plot(time,fmAllLFRMS.mean,'r');
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
h1 = plot(time,conNoPainLFRMS.mean,'b');
hold on;
h2 = plot(time,fmNoPainLFRMS.mean,'r');
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
h1 = plot(time,conPainLFRMS.mean,'b');
hold on;
h2 = plot(time,fmPainLFRMS.mean,'r');
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
h1 = plot(time,conNoPainLFRMS.mean,'b');
hold on;
h2 = plot(time,conPainLFRMS.mean,'r');
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
h1 = plot(time,fmNoPainLFRMS.mean,'b');
hold on;
h2 = plot(time,fmPainLFRMS.mean,'r');
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
h1 = plot(time,conAllRFRMS.mean,'b');
hold on;
h2 = plot(time,fmAllRFRMS.mean,'r');
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
h1 = plot(time,conNoPainRFRMS.mean,'b');
hold on;
h2 = plot(time,fmNoPainRFRMS.mean,'r');
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
h1 = plot(time,conPainRFRMS.mean,'b');
hold on;
h2 = plot(time,fmPainRFRMS.mean,'r');
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
h1 = plot(time,conNoPainRFRMS.mean,'b');
hold on;
h2 = plot(time,conPainRFRMS.mean,'r');
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
h1 = plot(time,fmNoPainRFRMS.mean,'b');
hold on;
h2 = plot(time,fmPainRFRMS.mean,'r');
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
h1 = plot(time,conAllLBRMS.mean,'b');
hold on;
h2 = plot(time,fmAllLBRMS.mean,'r');
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
h1 = plot(time,conNoPainLBRMS.mean,'b');
hold on;
h2 = plot(time,fmNoPainLBRMS.mean,'r');
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
h1 = plot(time,conPainLBRMS.mean,'b');
hold on;
h2 = plot(time,fmPainLBRMS.mean,'r');
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
h1 = plot(time,conNoPainLBRMS.mean,'b');
hold on;
h2 = plot(time,conPainLBRMS.mean,'r');
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
h1 = plot(time,fmNoPainLBRMS.mean,'b');
hold on;
h2 = plot(time,fmPainLBRMS.mean,'r');
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
h1 = plot(time,conAllRBRMS.mean,'b');
hold on;
h2 = plot(time,fmAllRBRMS.mean,'r');
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
h1 = plot(time,conNoPainRBRMS.mean,'b');
hold on;
h2 = plot(time,fmNoPainRBRMS.mean,'r');
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
h1 = plot(time,conPainRBRMS.mean,'b');
hold on;
h2 = plot(time,fmPainRBRMS.mean,'r');
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
h1 = plot(time,conNoPainRBRMS.mean,'b');
hold on;
h2 = plot(time,conPainRBRMS.mean,'r');
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
h1 = plot(time,fmNoPainRBRMS.mean,'b');
hold on;
h2 = plot(time,fmPainRBRMS.mean,'r');
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,fmNoPainRBRMS.mean+fmNoPainRBRMS.sd,fmNoPainRBRMS.mean-fmNoPainRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,fmPainRBRMS.mean+fmPainRBRMS.sd,fmPainRBRMS.mean-fmPainRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('RBRMS');
title('RBRMS for fibros: Blue - No Pain, Red - Pain');

%% time frequency analysis
% low frequencies
% control
clear all
for sub = 1:14
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(sub)]);
    load splitconds
    load ERFaverages
    avgPain = pain;
    avgNoPain = noPain;
    avgPain.trialinfo(2:length(avgPain.trialinfo),:) = [];
    avgNoPain.trialinfo(2:length(avgNoPain.trialinfo),:) = [];
    avgPain.trial = {};
    avgNoPain.trial = {};
    avgPain.time = {};
    avgNoPain.time = {};
    eval(['avgPain.trial{1} = conSub',num2str(sub),'pain.avg;']);
    eval(['avgNoPain.trial{1} = conSub',num2str(sub),'noPain.avg;']);
    eval(['avgPain.time{1} = conSub',num2str(sub),'pain.time;']);
    eval(['avgNoPain.time{1} = conSub',num2str(sub),'noPain.time;']);
        cfg             = [];
        cfg.resamplefs  = 300;
        cfg.detrend     = 'no';
        noPain       = ft_resampledata(cfg, noPain);
        pain         = ft_resampledata(cfg, pain);
        avgPain      = ft_resampledata(cfg, avgPain);
        avgNoPain      = ft_resampledata(cfg, avgNoPain);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials='yes';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 2:2:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = -0.8:0.03:1.2;
    cfgtfrl.channel   = {'MEG', '-A41'};
    TFpain            = ft_freqanalysis(cfgtfrl, pain);
    TFnoPain          = ft_freqanalysis(cfgtfrl, noPain);
    TFavgPain         = ft_freqanalysis(cfgtfrl, avgPain);
    TFavgNoPain       = ft_freqanalysis(cfgtfrl, avgNoPain);
    save TFtestLow TFpain TFnoPain TFavgPain TFavgNoPain
    clear TFpain TFnoPain TFavgPain TFavgNoPain
end;
% fm
clear all
for sub = [1:7 9:20]
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(sub)]);
    load splitconds
    load ERFaverages
    avgPain = pain;
    avgNoPain = noPain;
    avgPain.trialinfo(2:length(avgPain.trialinfo),:) = [];
    avgNoPain.trialinfo(2:length(avgNoPain.trialinfo),:) = [];
    avgPain.trial = {};
    avgNoPain.trial = {};
    avgPain.time = {};
    avgNoPain.time = {};
    eval(['avgPain.trial{1} = fmSub',num2str(sub),'pain.avg;']);
    eval(['avgNoPain.trial{1} = fmSub',num2str(sub),'noPain.avg;']);
    eval(['avgPain.time{1} = fmSub',num2str(sub),'pain.time;']);
    eval(['avgNoPain.time{1} = fmSub',num2str(sub),'noPain.time;']);
        cfg             = [];
        cfg.resamplefs  = 300;
        cfg.detrend     = 'no';
        noPain       = ft_resampledata(cfg, noPain);
        pain         = ft_resampledata(cfg, pain);
        avgPain      = ft_resampledata(cfg, avgPain);
        avgNoPain      = ft_resampledata(cfg, avgNoPain);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials='yes';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 2:2:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = -0.8:0.03:1.2;
    cfgtfrl.channel   = {'MEG', '-A41'};
    TFpain            = ft_freqanalysis(cfgtfrl, pain);
    TFnoPain          = ft_freqanalysis(cfgtfrl, noPain);
    TFavgPain         = ft_freqanalysis(cfgtfrl, avgPain);
    TFavgNoPain       = ft_freqanalysis(cfgtfrl, avgNoPain);
    save TFtestLow TFpain TFnoPain TFavgPain TFavgNoPain
    clear TFpain TFnoPain TFavgPain TFavgNoPain
end;
%% grand average for the time frequency
% control
clear all
cfg=[];
cfg.baseline     = [-0.3 0];
cfg.baselinetype = 'absolute';
for i = 1:14
    eval(['load /media/My_Passport/fibrodata/con/con',num2str(i),'/TFtestLow']);
    % calculate conditions' data as a relative change from their base-line
    TFavgNoPain=ft_freqbaseline(cfg,TFavgNoPain);
    TFavgPain=ft_freqbaseline(cfg,TFavgPain);
    TFnoPain=ft_freqbaseline(cfg,TFnoPain);
    TFpain=ft_freqbaseline(cfg,TFpain);
    eval(['conSub',num2str(i),'TFpain = TFpain;']);
    eval(['conSub',num2str(i),'TFnoPain = TFnoPain;']);
    eval(['conSub',num2str(i),'TFavgPain = TFavgPain;']);
    eval(['conSub',num2str(i),'TFavgNoPain = TFavgNoPain;']);
    clear TFpain TFnoPain TFavgPain TFavgNoPain
    disp(i);
end;

for i=1:14
    eval(['conSub',num2str(i),'TFLpainDesc = ft_freqdescriptives([],conSub',num2str(i),'TFpain);']);
    eval(['conSub',num2str(i),'TFLavgPainDesc = ft_freqdescriptives([],conSub',num2str(i),'TFavgPain);']);
    eval(['conSub',num2str(i),'TFLnoPainDesc = ft_freqdescriptives([],conSub',num2str(i),'TFnoPain);']);
    eval(['conSub',num2str(i),'TFLavgNoPainDesc = ft_freqdescriptives([],conSub',num2str(i),'TFavgNoPain);']);
    eval(['clear conSub',num2str(i),'TFpain conSub',num2str(i),'TFavgPain conSub',num2str(i),'TFnoPain conSub',num2str(i),'TFavgNoPain']);
end;

for i=1:14
    eval(['conSub',num2str(i),'TFLpainInd = conSub',num2str(i),'TFLpainDesc;']);
    eval(['conSub',num2str(i),'TFLpainInd.powspctrm = conSub',num2str(i),'TFLpainInd.powspctrm - conSub',num2str(i),'TFLavgPainDesc.powspctrm;']);
    eval(['conSub',num2str(i),'TFLnoPainInd = conSub',num2str(i),'TFLnoPainDesc;']);
    eval(['conSub',num2str(i),'TFLnoPainInd.powspctrm = conSub',num2str(i),'TFLnoPainInd.powspctrm - conSub',num2str(i),'TFLavgNoPainDesc.powspctrm;']);
    eval(['clear conSub',num2str(i),'TFLavgPainDesc conSub',num2str(i),'TFLavgNoPainDesc']);
end

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFLconPain         = ft_freqgrandaverage(cfg, conSub1TFLpainDesc, conSub2TFLpainDesc, conSub3TFLpainDesc,...
    conSub4TFLpainDesc, conSub5TFLpainDesc, conSub6TFLpainDesc, conSub7TFLpainDesc, conSub8TFLpainDesc,...
    conSub9TFLpainDesc, conSub10TFLpainDesc, conSub11TFLpainDesc, conSub12TFLpainDesc, conSub13TFLpainDesc,...
    conSub14TFLpainDesc);
clear conSub1TFLpainDesc conSub2TFLpainDesc conSub3TFLpainDesc conSub4TFLpainDesc conSub5TFLpainDesc...
    conSub6TFLpainDesc conSub7TFLpainDesc conSub8TFLpainDesc conSub9TFLpainDesc conSub10TFLpainDesc...
    conSub11TFLpainDesc conSub12TFLpainDesc conSub13TFLpainDesc conSub14TFLpainDesc

TFLconNoPain         = ft_freqgrandaverage(cfg, conSub1TFLnoPainDesc, conSub2TFLnoPainDesc, conSub3TFLnoPainDesc,...
    conSub4TFLnoPainDesc, conSub5TFLnoPainDesc, conSub6TFLnoPainDesc, conSub7TFLnoPainDesc, conSub8TFLnoPainDesc,...
    conSub9TFLnoPainDesc, conSub10TFLnoPainDesc, conSub11TFLnoPainDesc, conSub12TFLnoPainDesc, conSub13TFLnoPainDesc,...
    conSub14TFLnoPainDesc);
clear conSub1TFLnoPainDesc conSub2TFLnoPainDesc conSub3TFLnoPainDesc conSub4TFLnoPainDesc conSub5TFLnoPainDesc...
    conSub6TFLnoPainDesc conSub7TFLnoPainDesc conSub8TFLnoPainDesc conSub9TFLnoPainDesc conSub10TFLnoPainDesc...
    conSub11TFLnoPainDesc conSub12TFLnoPainDesc conSub13TFLnoPainDesc conSub14TFLnoPainDesc

TFLconPainInd         = ft_freqgrandaverage(cfg, conSub1TFLpainInd, conSub2TFLpainInd, conSub3TFLpainInd,...
    conSub4TFLpainInd, conSub5TFLpainInd, conSub6TFLpainInd, conSub7TFLpainInd, conSub8TFLpainInd,...
    conSub9TFLpainInd, conSub10TFLpainInd, conSub11TFLpainInd, conSub12TFLpainInd, conSub13TFLpainInd,...
    conSub14TFLpainInd);
clear conSub1TFLpainInd conSub2TFLpainInd conSub3TFLpainInd conSub4TFLpainInd conSub5TFLpainInd...
    conSub6TFLpainInd conSub7TFLpainInd conSub8TFLpainInd conSub9TFLpainInd conSub10TFLpainInd...
    conSub11TFLpainInd conSub12TFLpainInd conSub13TFLpainInd conSub14TFLpainInd

TFLconNoPainInd         = ft_freqgrandaverage(cfg, conSub1TFLnoPainInd, conSub2TFLnoPainInd, conSub3TFLnoPainInd,...
    conSub4TFLnoPainInd, conSub5TFLnoPainInd, conSub6TFLnoPainInd, conSub7TFLnoPainInd, conSub8TFLnoPainInd,...
    conSub9TFLnoPainInd, conSub10TFLnoPainInd, conSub11TFLnoPainInd, conSub12TFLnoPainInd, conSub13TFLnoPainInd,...
    conSub14TFLnoPainInd);
clear conSub1TFLnoPainInd conSub2TFLnoPainInd conSub3TFLnoPainInd conSub4TFLnoPainInd conSub5TFLnoPainInd...
    conSub6TFLnoPainInd conSub7TFLnoPainInd conSub8TFLnoPainInd conSub9TFLnoPainInd conSub10TFLnoPainInd...
    conSub11TFLnoPainInd conSub12TFLnoPainInd conSub13TFLnoPainInd conSub14TFLnoPainInd

% fm
cfg=[];
cfg.baseline     = [-0.3 0];
cfg.baselinetype = 'absolute';
for i = [1:7 9:20]
    eval(['load /media/My_Passport/fibrodata/fm/fm',num2str(i),'/TFtestLow']);
    TFavgNoPain=ft_freqbaseline(cfg,TFavgNoPain);
    TFavgPain=ft_freqbaseline(cfg,TFavgPain);
    TFnoPain=ft_freqbaseline(cfg,TFnoPain);
    TFpain=ft_freqbaseline(cfg,TFpain);
    eval(['fmSub',num2str(i),'TFpain = TFpain;']);
    eval(['fmSub',num2str(i),'TFnoPain = TFnoPain;']);
    eval(['fmSub',num2str(i),'TFavgPain = TFavgPain;']);
    eval(['fmSub',num2str(i),'TFavgNoPain = TFavgNoPain;']);
    clear TFpain TFnoPain TFavgPain TFavgNoPain
    disp(i);
end;

for i = [1:7 9:20]
    eval(['fmSub',num2str(i),'TFLpainDesc = ft_freqdescriptives([],fmSub',num2str(i),'TFpain);']);
    eval(['fmSub',num2str(i),'TFLavgPainDesc = ft_freqdescriptives([],fmSub',num2str(i),'TFavgPain);']);
    eval(['fmSub',num2str(i),'TFLnoPainDesc = ft_freqdescriptives([],fmSub',num2str(i),'TFnoPain);']);
    eval(['fmSub',num2str(i),'TFLavgNoPainDesc = ft_freqdescriptives([],fmSub',num2str(i),'TFavgNoPain);']);
    eval(['clear fmSub',num2str(i),'TFpain fmSub',num2str(i),'TFavgPain fmSub',num2str(i),'TFnoPain fmSub',num2str(i),'TFavgNoPain']);
end;

for i = [1:7 9:20]
    eval(['fmSub',num2str(i),'TFLpainInd = fmSub',num2str(i),'TFLpainDesc;']);
    eval(['fmSub',num2str(i),'TFLpainInd.powspctrm = fmSub',num2str(i),'TFLpainInd.powspctrm - fmSub',num2str(i),'TFLavgPainDesc.powspctrm;']);
    eval(['fmSub',num2str(i),'TFLnoPainInd = fmSub',num2str(i),'TFLnoPainDesc;']);
    eval(['fmSub',num2str(i),'TFLnoPainInd.powspctrm = fmSub',num2str(i),'TFLnoPainInd.powspctrm - fmSub',num2str(i),'TFLavgNoPainDesc.powspctrm;']);
    eval(['clear fmSub',num2str(i),'TFLavgPainDesc fmSub',num2str(i),'TFLavgNoPainDesc']);
end

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFLfmPain         = ft_freqgrandaverage(cfg, fmSub1TFLpainDesc, fmSub2TFLpainDesc, fmSub3TFLpainDesc,...
    fmSub4TFLpainDesc, fmSub5TFLpainDesc, fmSub6TFLpainDesc, fmSub7TFLpainDesc, fmSub9TFLpainDesc,...
    fmSub10TFLpainDesc, fmSub11TFLpainDesc, fmSub12TFLpainDesc, fmSub13TFLpainDesc, fmSub14TFLpainDesc,...
    fmSub15TFLpainDesc, fmSub16TFLpainDesc, fmSub17TFLpainDesc, fmSub18TFLpainDesc, fmSub19TFLpainDesc,...
    fmSub20TFLpainDesc);
clear fmSub1TFLpainDesc fmSub2TFLpainDesc fmSub3TFLpainDesc fmSub4TFLpainDesc fmSub5TFLpainDesc...
    fmSub6TFLpainDesc fmSub7TFLpainDesc fmSub9TFLpainDesc fmSub10TFLpainDesc fmSub11TFLpainDesc...
    fmSub12TFLpainDesc fmSub13TFLpainDesc fmSub14TFLpainDesc fmSub15TFLpainDesc fmSub16TFLpainDesc...
    fmSub17TFLpainDesc fmSub18TFLpainDesc fmSub19TFLpainDesc fmSub20TFLpainDesc

TFLfmNoPain         = ft_freqgrandaverage(cfg, fmSub1TFLnoPainDesc, fmSub2TFLnoPainDesc, fmSub3TFLnoPainDesc,...
    fmSub4TFLnoPainDesc, fmSub5TFLnoPainDesc, fmSub6TFLnoPainDesc, fmSub7TFLnoPainDesc, fmSub9TFLnoPainDesc,...
    fmSub10TFLnoPainDesc, fmSub11TFLnoPainDesc, fmSub12TFLnoPainDesc, fmSub13TFLnoPainDesc, fmSub14TFLnoPainDesc,...
    fmSub15TFLnoPainDesc, fmSub16TFLnoPainDesc, fmSub17TFLnoPainDesc, fmSub18TFLnoPainDesc, fmSub19TFLnoPainDesc,...
    fmSub20TFLnoPainDesc);
clear fmSub1TFLnoPainDesc fmSub2TFLnoPainDesc fmSub3TFLnoPainDesc fmSub4TFLnoPainDesc fmSub5TFLnoPainDesc...
    fmSub6TFLnoPainDesc fmSub7TFLnoPainDesc fmSub9TFLnoPainDesc fmSub10TFLnoPainDesc fmSub11TFLnoPainDesc...
    fmSub12TFLnoPainDesc fmSub13TFLnoPainDesc fmSub14TFLnoPainDesc fmSub15TFLnoPainDesc fmSub16TFLnoPainDesc...
    fmSub17TFLnoPainDesc fmSub18TFLnoPainDesc fmSub19TFLnoPainDesc fmSub20TFLnoPainDesc

TFLfmPainInd         = ft_freqgrandaverage(cfg, fmSub1TFLpainInd, fmSub2TFLpainInd, fmSub3TFLpainInd,...
    fmSub4TFLpainInd, fmSub5TFLpainInd, fmSub6TFLpainInd, fmSub7TFLpainInd, fmSub9TFLpainInd,...
    fmSub10TFLpainInd, fmSub11TFLpainInd, fmSub12TFLpainInd, fmSub13TFLpainInd, fmSub14TFLpainInd,...
    fmSub15TFLpainInd, fmSub16TFLpainInd, fmSub17TFLpainInd, fmSub18TFLpainInd, fmSub19TFLpainInd,...
    fmSub20TFLpainInd);
clear fmSub1TFLpainInd fmSub2TFLpainInd fmSub3TFLpainInd fmSub4TFLpainInd fmSub5TFLpainInd...
    fmSub6TFLpainInd fmSub7TFLpainInd fmSub9TFLpainInd fmSub10TFLpainInd fmSub11TFLpainInd...
    fmSub12TFLpainInd fmSub13TFLpainInd fmSub14TFLpainInd fmSub15TFLpainInd fmSub16TFLpainInd...
    fmSub17TFLpainInd fmSub18TFLpainInd fmSub19TFLpainInd fmSub20TFLpainInd

TFLfmNoPainInd         = ft_freqgrandaverage(cfg, fmSub1TFLnoPainInd, fmSub2TFLnoPainInd, fmSub3TFLnoPainInd,...
    fmSub4TFLnoPainInd, fmSub5TFLnoPainInd, fmSub6TFLnoPainInd, fmSub7TFLnoPainInd, fmSub9TFLnoPainInd,...
    fmSub10TFLnoPainInd, fmSub11TFLnoPainInd, fmSub12TFLnoPainInd, fmSub13TFLnoPainInd, fmSub14TFLnoPainInd,...
    fmSub15TFLnoPainInd, fmSub16TFLnoPainInd, fmSub17TFLnoPainInd, fmSub18TFLnoPainInd, fmSub19TFLnoPainInd,...
    fmSub20TFLnoPainInd);
clear fmSub1TFLnoPainInd fmSub2TFLnoPainInd fmSub3TFLnoPainInd fmSub4TFLnoPainInd fmSub5TFLnoPainInd...
    fmSub6TFLnoPainInd fmSub7TFLnoPainInd fmSub9TFLnoPainInd fmSub10TFLnoPainInd fmSub11TFLnoPainInd...
    fmSub12TFLnoPainInd fmSub13TFLnoPainInd fmSub14TFLnoPainInd fmSub15TFLnoPainInd fmSub16TFLnoPainInd...
    fmSub17TFLnoPainInd fmSub18TFLnoPainInd fmSub19TFLnoPainInd fmSub20TFLnoPainInd

cd /media/My_Passport/fibrodata
save TFLgavgs

conPainAvg = mean(mean(mean(TFLconPain.powspctrm(:,:,5,31:44))));
fmPainAvg = mean(mean(mean(TFLfmPain.powspctrm(:,:,5,31:44))));
conNoPainAvg = mean(mean(mean(TFLconNoPain.powspctrm(:,:,5,31:44))));
fmNoPainAvg = mean(mean(mean(TFLfmNoPain.powspctrm(:,:,5,31:44))));
conPainSD = std(mean(mean(TFLconPain.powspctrm(:,:,5,31:44))));
fmPainSD = std(mean(mean(TFLfmPain.powspctrm(:,:,5,31:44))));
conNoPainSD = std(mean(mean(TFLconNoPain.powspctrm(:,:,5,31:44))));
fmNoPainSD = std(mean(mean(TFLfmNoPain.powspctrm(:,:,5,31:44))));
figure
h=barwitherr([conPainSD,fmPainSD;conNoPainSD,fmNoPainSD],[conPainAvg,fmPainAvg;conNoPainAvg,fmNoPainAvg]);
set(h(1), 'facecolor', [1 1 1]);
set(h(2), 'facecolor', [0 0 0]);
title('10-11Hz 100-500ms')
ylabel('Power Change Relative to Base-Line');
set(gca, 'XTickLabel', {'Pain','No Pain'});
legend('control','fibros');
text(0.7,conPainAvg-0.1*10^(-27),num2str(conPainAvg))
text(1,fmPainAvg-0.1*10^(-27),num2str(fmPainAvg))
text(1.7,conNoPainAvg-0.1*10^(-27),num2str(conNoPainAvg))
text(2,fmNoPainAvg-0.1*10^(-27),num2str(fmNoPainAvg))

% differences
TFLconPainMinusNoPain = TFLconPain;
TFLconPainMinusNoPain.powspctrm = TFLconPain.powspctrm - TFLconNoPain.powspctrm;
TFLfmPainMinusNoPain = TFLfmPain;
TFLfmPainMinusNoPain.powspctrm = TFLfmPain.powspctrm - TFLfmNoPain.powspctrm;
TFLconPainMinusNoPainInd = TFLconPainInd;
TFLconPainMinusNoPainInd.powspctrm = TFLconPainInd.powspctrm - TFLconNoPainInd.powspctrm;
TFLfmPainMinusNoPainInd = TFLfmPainInd;
TFLfmPainMinusNoPainInd.powspctrm = TFLfmPainInd.powspctrm - TFLfmNoPainInd.powspctrm;

% ploting
cfg              = [];
cfg.baseline     = 'yes'; 
cfg.baselinetype = 'absolute'; % cfg.baselinetype = 'relchange'; % if I used baseline
cfg.zlim         = [-2*10^(-27) 2*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
subplot(2,3,1)
ft_singleplotTFR(cfg, TFLconPain);
title('Control pain 1-40Hz')
subplot(2,3,2)
ft_singleplotTFR(cfg, TFLconNoPain);
title('Control no-pain 1-40Hz')
subplot(2,3,3)
cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLconPainMinusNoPain);
title('Control pain minus no-pain 1-40Hz')
subplot(2,3,4)
cfg.zlim = [-2*10^(-27) 2*10^(-27)];
ft_singleplotTFR(cfg, TFLfmPain);
title('Fibromyalgia pain 1-40Hz')
subplot(2,3,5)
ft_singleplotTFR(cfg, TFLfmNoPain);
title('Fibromyalgia no-pain 1-40Hz')
subplot(2,3,6)
cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLfmPainMinusNoPain);
title('Fibromyalgia pain minus no-pain 1-40Hz')

cfg              = [];
cfg.baseline     = 'no'; 
%cfg.baselinetype = 'absolute'; % 'relchange'
cfg.zlim         = [-20*10^(-28) 5*10^(-28)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'no';

figure;
subplot(2,3,1)
ft_singleplotTFR(cfg, TFLconPainInd);
title('Control pain Induced 1-40Hz')
subplot(2,3,2)
ft_singleplotTFR(cfg, TFLconNoPainInd);
title('Control no-pain Induced 1-40Hz')
subplot(2,3,3)
cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLconPainMinusNoPainInd);
title('Control pain minus no-pain Induced 1-40Hz')
subplot(2,3,4)
cfg.zlim = [-20*10^(-28) 5*10^(-28)];
ft_singleplotTFR(cfg, TFLfmPainInd);
title('Fibromyalgia pain Induced 1-40Hz')
subplot(2,3,5)
ft_singleplotTFR(cfg, TFLfmNoPainInd);
title('Fibromyalgia no-pain Induced 1-40Hz')
subplot(2,3,6)
cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLfmPainMinusNoPainInd);
title('Fibromyalgia pain minus no-pain Induced 1-40Hz')

% figure;
% subplot(1,3,1)
% ft_singleplotTFR(cfg, TFLconPain);
% title('control pain 1-40Hz')
% subplot(1,3,2)
% ft_singleplotTFR(cfg, TFLconNoPain);
% title('control no-pain 1-40Hz')
% subplot(1,3,3)
% cfg.zlim        = [-4*10^(-28) 4*10^(-28)];
% ft_singleplotTFR(cfg, TFLconPainMinusNoPain);
% title('control pain minus no-pain 1-40Hz')
% 
% figure
% subplot(1,2,1)
% ft_singleplotTFR(cfg, TFLfmNoPain);
% title('fibros no pain 1-40Hz')
% subplot(1,2,2)
% ft_singleplotTFR(cfg, TFLfmPain);
% title('fibros pain 1-40Hz')
% 
% 
% % ploting differences
% cfg              = [];
% cfg.baseline     = [-0.3 0]; 
% cfg.baselinetype = 'absolute'; % 'relchange'
% cfg.zlim        = [-2.5*10^(-27) 4*10^(-27)];
% cfg.interactive  = 'yes';
% cfg.layout       = '4D248.lay';
% cfg.colorbar     = 'yes';
% 
% figure;
% subplot(2,2,1)
% ft_singleplotTFR(cfg, TFLconPainMinusNoPain);
% title('control: pain minus no-pain 1-40Hz')
% subplot(2,2,2)
% ft_singleplotTFR(cfg, TFLfmPainMinusNoPain);
% title('fibros: pain minus no-pain 1-40Hz')
% subplot(2,2,3)
% cfg.zlim        = [-0.1*10^(-27) 2.5*10^(-27)];
% ft_singleplotTFR(cfg, TFLpainConMinusFm);
% title('pain: control minus fibros 1-40Hz')
% subplot(2,2,4)
% ft_singleplotTFR(cfg, TFLnoPainConMinusFm);
% title('no pain: control minus fibros 1-40Hz')

%% topoplot
cfg = [];                            
cfg.xlim = [0.1 0.5];
cfg.ylim = [10 10];
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
figure; ft_topoplotER(cfg,TFLconPainMinusNoPainInd)    
% take from the plot the channels that you are interested in and copy the
% list into "channel"
%%  time frequency statistics
cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT'; % or 'depsamplesT' for within subject
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG','-A41'};
% cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
cfg.correctm = 'cluster';
cfg.neighbours = ft_neighbourselection(cfg1);
cd '/media/My_Passport/fibrodata';
        
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:33) = [ones(1,14) 2*ones(1,19)];
cfg.design(2,1:33) = [1:14 1:19];
cfg.ivar =1;
%cfg.uvar =2; % if the statistics is dependent (within subject than
%uncomment this line)
cfg.avgovertime = 'yes'; % cfg.avgovertime = 'no';
cfg.avgoverfreq = 'yes'; % cfg.avgoverfreq = 'no';

cfg.latency     = [0.1 0.5];
cfg.frequency   = [10 10];

[stat] = ft_freqstatistics(cfg, TFLconPainMinusNoPain, TFLfmPainMinusNoPain);
[statInd] = ft_freqstatistics(cfg, TFLconPainMinusNoPainInd, TFLfmPainMinusNoPainInd);
[statCon] = ft_freqstatistics(cfg, TFLconPain, TFLconNoPain);

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
sigChans = find(stat.stat2~=0);

% plot
cfgp=[];
cfgp.colorbar='yes';
cfgp.parameter = 'stat';
cfgp.layout = '4D248.lay';
cfgp.alpha = 0.05;
ft_clusterplot(cfgp, stat)

% plot bars just for the dig channs
conPainAvg = mean(mean(mean(TFLconPain.powspctrm(:,sigChans,5,31:44))));
fmPainAvg = mean(mean(mean(TFLfmPain.powspctrm(:,sigChans,5,31:44))));
conNoPainAvg = mean(mean(mean(TFLconNoPain.powspctrm(:,sigChans,5,31:44))));
fmNoPainAvg = mean(mean(mean(TFLfmNoPain.powspctrm(:,sigChans,5,31:44))));
conPainSD = std(mean(mean(TFLconPain.powspctrm(:,sigChans,5,31:44))));
fmPainSD = std(mean(mean(TFLfmPain.powspctrm(:,sigChans,5,31:44))));
conNoPainSD = std(mean(mean(TFLconNoPain.powspctrm(:,sigChans,5,31:44))));
fmNoPainSD = std(mean(mean(TFLfmNoPain.powspctrm(:,sigChans,5,31:44))));
figure
h=barwitherr([conPainSD,fmPainSD;conNoPainSD,fmNoPainSD],[conPainAvg,fmPainAvg;conNoPainAvg,fmNoPainAvg]);
set(h(1), 'facecolor', [1 1 1]);
set(h(2), 'facecolor', [0 0 0]);
title('10-11Hz 100-500ms')
ylabel('Power Change Relative to Base-Line');
set(gca, 'XTickLabel', {'Pain','No Pain'});
legend('control','fibros');
text(0.7,conPainAvg-0.1*10^(-27),num2str(conPainAvg))
text(1,fmPainAvg-0.1*10^(-27),num2str(fmPainAvg))
text(1.7,conNoPainAvg-0.1*10^(-27),num2str(conNoPainAvg))
text(2,fmNoPainAvg-0.1*10^(-27),num2str(fmNoPainAvg))

% post hoc statistics
conPain = mean(mean(mean(TFLconPain.powspctrm(:,sigChans,5,31:44),2),3),4);
conPain = conPain(:);
fmPain = mean(mean(mean(TFLfmPain.powspctrm(:,sigChans,5,31:44),2),3),4);
fmPain = fmPain(:);
conNoPain = mean(mean(mean(TFLconNoPain.powspctrm(:,sigChans,5,31:44),2),3),4);
conNoPain = conNoPain(:);
fmNoPain = mean(mean(mean(TFLfmNoPain.powspctrm(:,sigChans,5,31:44),2),3),4);
fmNoPain = fmNoPain(:);

Td1 = ttest(conPain,conNoPain);
Td2 = ttest(fmPain,fmNoPain);
Ti1 = ttest2(conPain,fmPain);
Ti2 = ttest2(conNoPain,fmNoPain);
%% just for control
% ----------------
cfg.latency     = [0.1 0.5];
cfg.frequency   = [10 10];
cfg.statistic = 'depsamplesT';
cfg.design=[];
cfg.design(1,1:28) = [ones(1,14) 2*ones(1,14)];
cfg.design(2,1:28) = [1:14 1:14];
cfg.ivar =1;
cfg.uvar =2;
[statCon] = ft_freqstatistics(cfg, TFLconPain, TFLconNoPain);
[statConPlanar] = ft_freqstatistics(cfg, TFLconPainPlanar, TFLconNoPainPlanar);
[statInd] = ft_freqstatistics(cfg, TFLconPainInd, TFLconNoPainInd);

statCon.stat2 = statCon.mask.*statCon.stat; %  gives significatif t-value
find(statCon.stat2~=0)
% or
statInd.stat2 = statInd.mask.*statInd.stat; %  gives significatif t-value
find(statInd.stat2~=0)

% plot
cfgp=[];
cfgp.colorbar='yes';
cfgp.parameter = 'stat';
cfgp.layout = '4D248.lay';
cfgp.alpha = 0.05;
ft_clusterplot(cfgp, statCon)
ft_clusterplot(cfgp, statInd)

%% just for fm
cfg.statistic = 'depsamplesT';
cfg.design=[];
cfg.design(1,1:38) = [ones(1,19) 2*ones(1,19)];
cfg.design(2,1:38) = [1:19 1:19];
cfg.ivar =1;
cfg.uvar =2;
[statFM] = ft_freqstatistics(cfg, TFLfmPainInd, TFLfmNoPainInd);

statFM.stat2 = statFM.mask.*statFM.stat; %  gives significatif t-value
find(statFM.stat2~=0)

% 
% Right_PreMinusPost=mean(mean(mean(mean(TFl_RightPreMinusPost.powspctrm(:,stat.negclusterslabelmat==1,[3:7],[28:38])))));
% Left_PreMinusPost=mean(mean(mean(mean(TFl_LeftPreMinusPost.powspctrm(:,stat.negclusterslabelmat==1,[3:7],[28:38])))));
% 
% % cfg=[];
% % cfg.layout = '4D248.lay';
% % cfg.colorbar = 'yes';
% % cfg.parameter = 'powspctrm';
% % cfg.zlim = [-10*10^(-28) 10*10^(-28)];
% % cfg.xlim     = [0.324 0.63];
% % cfg.ylim   = [7 13];
% % cfg.highlight          = {'numbers'};
% % cfg.highlightsymbol    = {'*'};
% % cfg.highlightchannel   = {stat.label(stat.negclusterslabelmat==1)};
% % figure
% % ft_topoplotTFR(cfg,TFl_LeftPreMinusPost);
% % figure
% % ft_topoplotTFR(cfg,TFl_RightPreMinusPost);
% 
% %% creating tabels with means of the significnat component for control 10Hz 0.1-0.5ms
% for i=1:12
%     con(i,1) = (squeeze(mean(mean(mean(TFLconPain.powspctrm(i,:,5,31:44)))))...
%         - squeeze(mean(mean(mean(TFLconPain.powspctrm(i,:,5,18:27))))))...
%         /squeeze(mean(mean(mean(TFLconPain.powspctrm(i,:,5,18:27)))));
%     con(i,2) = (squeeze(mean(mean(mean(TFLconNoPain.powspctrm(i,:,5,31:44)))))...
%         - squeeze(mean(mean(mean(TFLconNoPain.powspctrm(i,:,5,18:27))))))...
%         /squeeze(mean(mean(mean(TFLconNoPain.powspctrm(i,:,5,18:27)))));
%     fm(i,1) = (squeeze(mean(mean(mean(TFLfmPain.powspctrm(i,:,5,31:44)))))...
%         - squeeze(mean(mean(mean(TFLfmPain.powspctrm(i,:,5,18:27))))))...
%         /squeeze(mean(mean(mean(TFLfmPain.powspctrm(i,:,5,18:27)))));
%     fm(i,2) = (squeeze(mean(mean(mean(TFLfmNoPain.powspctrm(i,:,5,31:44)))))...
%         - squeeze(mean(mean(mean(TFLfmNoPain.powspctrm(i,:,5,18:27))))))...
%         /squeeze(mean(mean(mean(TFLfmNoPain.powspctrm(i,:,5,18:27)))));
% end
% 
% con=con.*100;
% fm=fm.*100;
% mCon=mean(con);
% sdCon=std(con);
% mFm=mean(fm);
% sdFm=std(fm);
% for i=1:12
%     con(i,3)=(con(i,1)-mCon(1))/sdCon(1);
%     con(i,4)=(con(i,2)-mCon(2))/sdCon(2);
%     fm(i,3)=(fm(i,1)-mFm(1))/sdFm(1);
%     fm(i,4)=(fm(i,2)-mFm(2))/sdFm(2);
% end;

%% grand averages
clear all
for i=1:14
    eval(['load /home/meg/Data/Maor/fibrodata/con/con',num2str(i),'/ERFaverages']);
end
for i=[1:7,9:20]
    eval(['load /home/meg/Data/Maor/fibrodata/fm/fm',num2str(i),'/ERFaverages']);
end

cd /home/meg/Data/Maor/fibrodata

conPain = ft_timelockgrandaverage([],conSub1pain, conSub2pain, conSub3pain, conSub4pain,...
    conSub5pain, conSub6pain, conSub7pain, conSub8pain, conSub9pain, conSub10pain,...
    conSub11pain, conSub12pain, conSub13pain, conSub14pain);
conNoPain = ft_timelockgrandaverage([],conSub1noPain, conSub2noPain, conSub3noPain, conSub4noPain,...
    conSub5noPain, conSub6noPain, conSub7noPain, conSub8noPain, conSub9noPain, conSub10noPain,...
    conSub11noPain, conSub12noPain, conSub13noPain, conSub14noPain);
conAll = ft_timelockgrandaverage([],conSub1all, conSub2all, conSub3all, conSub4all,...
    conSub5all, conSub6all, conSub7all, conSub8all, conSub9all, conSub10all,...
    conSub11all, conSub12all, conSub13all, conSub14all);

fmPain = ft_timelockgrandaverage([],fmSub1pain, fmSub2pain, fmSub3pain, fmSub4pain, fmSub5pain,...
    fmSub6pain, fmSub7pain, fmSub9pain, fmSub10pain, fmSub11pain, fmSub12pain, fmSub13pain,...
    fmSub14pain, fmSub15pain, fmSub16pain, fmSub17pain, fmSub18pain, fmSub19pain, fmSub20pain);
fmNoPain = ft_timelockgrandaverage([],fmSub1noPain, fmSub2noPain, fmSub3noPain, fmSub4noPain, fmSub5noPain,...
    fmSub6noPain, fmSub7noPain, fmSub9noPain, fmSub10noPain, fmSub11noPain, fmSub12noPain, fmSub13noPain,...
    fmSub14noPain, fmSub15noPain, fmSub16noPain, fmSub17noPain, fmSub18noPain, fmSub19noPain, fmSub20noPain);
fmAll = ft_timelockgrandaverage([],fmSub1all, fmSub2all, fmSub3all, fmSub4all, fmSub5all,...
    fmSub6all, fmSub7all, fmSub9all, fmSub10all, fmSub11all, fmSub12all, fmSub13all,...
    fmSub14all, fmSub15all, fmSub16all, fmSub17all, fmSub18all, fmSub19all, fmSub20all);

save grAvg conAll fmAll conPain fmPain conNoPain fmNoPain
clear all
load grAvg

% ploting
plot(conAll.time,conAll.avg,'r');
hold on
plot(fmAll.time,fmAll.avg,'b');
grid on
axis tight

figure
cfg = [];                            
cfg.xlim = 0:0.02:0.5;
cfg.layout = '4D248.lay';
cfg.interactive = 'no';
ft_topoplotER(cfg,conAll)

figure
ft_topoplotER(cfg,fmAll)


%% SAMerf
% -------------------------------------------------------------------------
%% 1. creating marker files for all subs (do it once!)
% control
for i = 1:14
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load splitconds;
    disp(i);
    Pain=[((pain.sampleinfo(pain.trialinfo == 230,1)+814)./1017.25)',...
        ((pain.sampleinfo(pain.trialinfo == 250,1)+814)./1017.25)'];
    NoPain=[((pain.sampleinfo(pain.trialinfo == 222,1)+814)./1017.25)',...
        ((pain.sampleinfo(pain.trialinfo == 240,1)+814)./1017.25)'];
    All = ((pain.sampleinfo(:,1)+814)./1017.25)';

    Trig2mark('All',All,'Pain',Pain,'NoPain',NoPain);
    clear All NoPain Pain noPain pain
end

% fibros
for i = [1:7 9:20]
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    load splitconds;
    disp(i);
    Pain=[((pain.sampleinfo(pain.trialinfo == 230,1)+814)./1017.25)',...
        ((pain.sampleinfo(pain.trialinfo == 250,1)+814)./1017.25)'];
    NoPain=[((pain.sampleinfo(pain.trialinfo == 222,1)+814)./1017.25)',...
        ((pain.sampleinfo(pain.trialinfo == 240,1)+814)./1017.25)'];
    All = ((pain.sampleinfo(:,1)+814)./1017.25)';

    Trig2mark('All',All,'Pain',Pain,'NoPain',NoPain);
    clear All NoPain Pain noPain pain
end
% -------------------------------------------------------------------------
%% 2. fit individual MRI to HS
% using template MRI:
for i = [1:7,9:20]
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    if exist('c,rfhp0.1Hz', 'file')
        fitMRI2hs('c,rfhp0.1Hz');
    elseif exist('xc,hb,lf_c,rfhp0.1Hz', 'file')
        fitMRI2hs('xc,hb,lf_c,rfhp0.1Hz');
    end
    hs2afni()
end

for i = 1:14
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    if exist('c,rfhp0.1Hz', 'file')
        fitMRI2hs('c,rfhp0.1Hz');
    elseif exist('xc,hb,lf_c,rfhp0.1Hz', 'file')
        fitMRI2hs('xc,hb,lf_c,rfhp0.1Hz');
    end
    hs2afni()
end

%% Nudging:
% ------------
% 2.1. from the terminal open afni and define: overlay = hs, underlay =
% warped
% 2.2. go to Define datamode > plugins > nudge dataset
% 2.3. click on "choose dataset" and choose "warped"
% 2.4. now nudge. Chose warped as dataset and when you are done type "do
% all" and then quit.

% 2.5 creating hull file:
!~/abin/3dSkullStrip -input warped+orig -prefix mask -mask_vol -skulls -o_ply ortho

% 2.6. in the terminal type: "afni -niml &"
% 2.6.1. define: overlay = mask, underlay = warped
% 2.6.2. in the terminal type: "suma -niml -i_ply ortho_brainhull.ply -sv mask+orig -novolreg"
% 2.6.3. go to the suma window and click on "t". Check that there is a good fit

% 2.7 creating brain file: in MATLAB:
!~/abin/3dcalc -a warped+orig -b mask+orig -prefix brain -expr 'a*step(b-2.9)'

% 2.8 creating a tlrc file: in the terminal type: 
% "@auto_tlrc -base TT_N27+tlrc -input brain+orig -no_ss -pad_base 60"

% 2.9 creating the final hull.shape file for Nolte:
!meshnorm ortho_brainhull.ply > hull.shape
% -------------------------------------------------------------------------
%% 3. creating param file (do it once!!)
cd /home/meg/Data/Maor/fibrodata/subjects
createPARAM('all4cov','ERF','All',[0 0.7],'All',[-0.3 0],[1 40],[-0.3 0.7]); 
% because I create the VSs in MATLAB only the segment window [-0.3 0.7] is
% important.
% now go into the param file and change Nolte to MultiSphere (because I don't have individual MRIs)!!!!
% -------------------------------------------------------------------------

%% 4. real-time-weights
% copy SuDi.rtw files from SAM_BIU/docs folder into subs folders (according to dates: 0810 0811 0812) and change the
% names according to the sub folder name


%% 5. SAMcov,wts,erf
cd /home/meg/Data/Maor/fibrodata/subjects
for i=2:14
    eval(['!SAMcov64 -r con',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -v']);
    eval(['!SAMwts64 -r con',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -c Alla -v']);
end
for i=[1:7,9:20]
    if i==19 || i==20
        eval(['!SAMcov64 -r fm',num2str(i),' -d xc,lf,hb_c,rfhp0.1Hz -m all4cov -v']);
        eval(['!SAMwts64 -r fm',num2str(i),' -d xc,lf,hb_c,rfhp0.1Hz -m all4cov -c Alla -v']);
    else
        eval(['!SAMcov64 -r fm',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -v']);
        eval(['!SAMwts64 -r fm',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -c Alla -v']);
    end
end

% "Alla" and not "All" because it adds and 'a' to the file name for some reason

% reading the weights
clear
wtsNoSuf='SAM/all4cov,1-40Hz,Alla';
for i=1:14
    eval(['cd /home/meg/Data/Maor/fibrodata/subjects/con',num2str(i)]);
    [~, ~, ActWgts]=readWeights([wtsNoSuf,'.wts']); % it takes a while
    save([wtsNoSuf,'.mat'],'SAMHeader', 'ActIndex', 'ActWgts'); % save in mat format, quicker to read later.
    clear ActWgts
    disp(i);
end
for i=[1:7,9:20]
    eval(['cd /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(i)]);
    [~, ~, ActWgts]=readWeights([wtsNoSuf,'.wts']); % it takes a while
    save([wtsNoSuf,'.mat'], 'ActWgts'); % save in mat format, quicker to read later.
    clear ActWgts
    disp(i);
end

%% creating virtual sensors
%% for control
clear
load /home/meg/Data/Maor/fibrodata/subjects/time
for i=1:14
    disp(i);
    eval(['cd /home/meg/Data/Maor/fibrodata/subjects/con',num2str(i)]);
    % noise estimation
    load ERFaverages
    load 'SAM/all4cov,1-40Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    % comp1
    eval(['vsPainComp1=ActWgts*conSub',num2str(i),'pain.avg(:,nearest(time,.080):nearest(time,.160));']);
    vsPainComp1MS=mean(vsPainComp1.*vsPainComp1,2)./ns;
    vsPainComp1MS=vsPainComp1MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPainComp1MS(isnan(vsPainComp1MS))=0;
    % comp2
    eval(['vsPainComp2=ActWgts*conSub',num2str(i),'pain.avg(:,nearest(time,.180):nearest(time,.300));']);
    vsPainComp2MS=mean(vsPainComp2.*vsPainComp2,2)./ns;
    vsPainComp2MS=vsPainComp2MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPainComp2MS(isnan(vsPainComp2MS))=0;
    % comp3
    eval(['vsPainComp3=ActWgts*conSub',num2str(i),'pain.avg(:,nearest(time,.330):nearest(time,.480));']);
    vsPainComp3MS=mean(vsPainComp3.*vsPainComp3,2)./ns;
    vsPainComp3MS=vsPainComp3MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPainComp3MS(isnan(vsPainComp3MS))=0;    
    
    % for no-pain
    % comp1
    eval(['vsNoPainComp1=ActWgts*conSub',num2str(i),'noPain.avg(:,nearest(time,.080):nearest(time,.160));']);
    vsNoPainComp1MS=mean(vsNoPainComp1.*vsNoPainComp1,2)./ns;
    vsNoPainComp1MS=vsNoPainComp1MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPainComp1MS(isnan(vsNoPainComp1MS))=0;
    % comp2
    eval(['vsNoPainComp2=ActWgts*conSub',num2str(i),'noPain.avg(:,nearest(time,.180):nearest(time,.300));']);
    vsNoPainComp2MS=mean(vsNoPainComp2.*vsNoPainComp2,2)./ns;
    vsNoPainComp2MS=vsNoPainComp2MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPainComp2MS(isnan(vsNoPainComp2MS))=0;
    % comp3
    eval(['vsNoPainComp3=ActWgts*conSub',num2str(i),'noPain.avg(:,nearest(time,.330):nearest(time,.480));']);
    vsNoPainComp3MS=mean(vsNoPainComp3.*vsNoPainComp3,2)./ns;
    vsNoPainComp3MS=vsNoPainComp3MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPainComp3MS(isnan(vsNoPainComp3MS))=0;  


    %make image 3D of mean square (MS, power)
    cfg=[];
    cfg.step=5;
    cfg.boxSize=[-120 120 -90 90 -20 150];
    for j=1:3
        eval(['cfg.prefix=''painComp',num2str(j),'MS'';']);
        eval(['VS2Brik(cfg,vsPainComp',num2str(j),'MS);']);
        eval(['cfg.prefix=''noPainComp',num2str(j),'MS'';']);
        eval(['VS2Brik(cfg,vsNoPainComp',num2str(j),'MS);']);        
    end
    
    eval(['clear ActIndex ActWgts SAMHeader cfg conSub',num2str(i),'all conSub',num2str(i),'noPaon conSub',num2str(i),'pain j ns vsNoPainComp1 vsNoPainComp1MS vsNoPainComp2 vsNoPainComp2MS vsNoPainComp3 vsNoPainComp3MS vsPainComp1 vsPainComp1MS vsPainComp2 vsPainComp2MS vsPainComp3 vsPainComp3MS'])

end

%% for fm
clear
load /home/meg/Data/Maor/fibrodata/subjects/time
for i=[1:7,9:20]
    disp(i)
    eval(['cd /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(i)]);
    % noise estimation
    load ERFaverages
    load 'SAM/all4cov,1-40Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    % comp1
    eval(['vsPainComp1=ActWgts*fmSub',num2str(i),'pain.avg(:,nearest(time,.120):nearest(time,.200));']);
    vsPainComp1MS=mean(vsPainComp1.*vsPainComp1,2)./ns;
    vsPainComp1MS=vsPainComp1MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPainComp1MS(isnan(vsPainComp1MS))=0;
    % comp2
    eval(['vsPainComp2=ActWgts*fmSub',num2str(i),'pain.avg(:,nearest(time,.200):nearest(time,.320));']);
    vsPainComp2MS=mean(vsPainComp2.*vsPainComp2,2)./ns;
    vsPainComp2MS=vsPainComp2MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPainComp2MS(isnan(vsPainComp2MS))=0;
    % comp3
    eval(['vsPainComp3=ActWgts*fmSub',num2str(i),'pain.avg(:,nearest(time,.330):nearest(time,.480));']);
    vsPainComp3MS=mean(vsPainComp3.*vsPainComp3,2)./ns;
    vsPainComp3MS=vsPainComp3MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPainComp3MS(isnan(vsPainComp3MS))=0;    
    
    % for no-pain
    % comp1
    eval(['vsNoPainComp1=ActWgts*fmSub',num2str(i),'noPain.avg(:,nearest(time,.120):nearest(time,.200));']);
    vsNoPainComp1MS=mean(vsNoPainComp1.*vsNoPainComp1,2)./ns;
    vsNoPainComp1MS=vsNoPainComp1MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPainComp1MS(isnan(vsNoPainComp1MS))=0;
    % comp2
    eval(['vsNoPainComp2=ActWgts*fmSub',num2str(i),'noPain.avg(:,nearest(time,.200):nearest(time,.320));']);
    vsNoPainComp2MS=mean(vsNoPainComp2.*vsNoPainComp2,2)./ns;
    vsNoPainComp2MS=vsNoPainComp2MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPainComp2MS(isnan(vsNoPainComp2MS))=0;
    % comp3
    eval(['vsNoPainComp3=ActWgts*fmSub',num2str(i),'noPain.avg(:,nearest(time,.330):nearest(time,.480));']);
    vsNoPainComp3MS=mean(vsNoPainComp3.*vsNoPainComp3,2)./ns;
    vsNoPainComp3MS=vsNoPainComp3MS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPainComp3MS(isnan(vsNoPainComp3MS))=0;  


    %make image 3D of mean square (MS, power)
    cfg=[];
    cfg.step=5;
    cfg.boxSize=[-120 120 -90 90 -20 150];
    for j=1:3
        eval(['cfg.prefix=''painComp',num2str(j),'MS'';']);
        eval(['VS2Brik(cfg,vsPainComp',num2str(j),'MS);']);
        eval(['cfg.prefix=''noPainComp',num2str(j),'MS'';']);
        eval(['VS2Brik(cfg,vsNoPainComp',num2str(j),'MS);']);        
    end
    
    eval(['clear ActIndex ActWgts SAMHeader cfg conSub',num2str(i),'all conSub',num2str(i),'noPaon conSub',num2str(i),'pain j ns vsNoPainComp1 vsNoPainComp1MS vsNoPainComp2 vsNoPainComp2MS vsNoPainComp3 vsNoPainComp3MS vsPainComp1 vsPainComp1MS vsPainComp2 vsPainComp2MS vsPainComp3 vsPainComp3MS'])
    
end

%% moving files to tlrc and moving them into a folder
% now open a terminal and type:
%
% for i in {1..14}
% do
%     cd /home/meg/Data/Maor/fibrodata/subjects/con$i
%     @auto_tlrc -apar brain+tlrc -input painComp1MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input painComp1MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input painComp2MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input painComp3MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPainComp1MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPainComp2MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPainComp3MS+orig -dxyz 5
%     mkdir SAM_1_40Hz
%     cp *+tlrc* SAM_1_40Hz
% done
% 
% for i in 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 19 20
% do
%     cd /home/meg/Data/Maor/fibrodata/subjects/fm$i
%     @auto_tlrc -apar brain+tlrc -input painComp1MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input painComp1MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input painComp2MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input painComp3MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPainComp1MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPainComp2MS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPainComp3MS+orig -dxyz 5
%     mkdir SAM_1_40Hz
%     cp *+tlrc* SAM_1_40Hz
% done

%%
% 1. run 3dMVM
% 2. firstly, lets get ridd of the voxels outside the cortex
cd /home/meg/Data/Maor/fibrodata/subjects
masktlrc('3dMVM_Comp1+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dMVM_Comp2+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dMVM_Comp3+tlrc','MASKctx+tlrc','_ctx');

% 3. create your cluster mask based on F threshold in afni and save it.

%% 
%  ===============  for comp 1  =================
%
%% 3. extract the maximum values in each cluster for the group, pain and interaction between the two
cd /home/meg/Data/Maor/fibrodata/subjects
clear all
!3dExtrema -prefix Clust20_group_ext_comp1 -mask_file Clust20_group_comp1_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp1_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_pain_ext_comp1 -mask_file Clust20_pain_comp1_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp1_ctx+tlrc'[2]'
!3dExtrema -prefix Clust20_int_ext_comp1 -mask_file Clust20_int_comp1_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp1_ctx+tlrc'[3]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_group_ext_comp1+tlrc > Clust20_xyzGroup_comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_pain_ext_comp1+tlrc > Clust20_xyzpain_comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_int_ext_comp1+tlrc > Clust20_xyzInt_comp1.txt

% 5. creating a matrix of all maximum values for all subs for all condition
% according to the xyzInt file created
%% Group
% each subject power for each extreme voxel in the group effect
con = 1:14;
fm = [1:7 9:20];

voxGrp = importdata('Clust20_xyzGroup_comp1.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/painComp1MS+tlrc > Clust20_painVoxValuesGrpComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/noPainComp1MS+tlrc > Clust20_noPainVoxValuesGrpComp1.txt']);

        val = importdata('Clust20_painVoxValuesGrpComp1.txt'); Clust20_conPainVoxValuesGrpComp1(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesGrpComp1.txt'); Clust20_conNoPainVoxValuesGrpComp1(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a=1;
for subs = fm
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/painComp1MS+tlrc > Clust20_painVoxValuesGrpComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/noPainComp1MS+tlrc > Clust20_noPainVoxValuesGrpComp1.txt']);

        val = importdata('Clust20_painVoxValuesGrpComp1.txt'); Clust20_fmPainVoxValuesGrpComp1(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesGrpComp1.txt'); Clust20_fmNoPainVoxValuesGrpComp1(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_conVoxelsComp1Grp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_conPainVoxValuesGrpComp1(',num2str(i),',:);Clust20_conNoPainVoxValuesGrpComp1(',num2str(i),',:)],1);']);
end
for i=1:length(fm)
    eval(['Clust20_fmVoxelsComp1Grp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_fmPainVoxValuesGrpComp1(',num2str(i),',:);Clust20_fmNoPainVoxValuesGrpComp1(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrp,1)
    eval(['!whereami ',num2str(voxGrp(i,1)),' ',num2str(voxGrp(i,2)),' ',num2str(voxGrp(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrp{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrp{i,1}=wmiGrp{i,1}(2:end);
end

save Clust20_comp1Grp voxGrp wmiGrp Clust20_conVoxelsComp1Grp Clust20_fmVoxelsComp1Grp

for i=1:size(voxGrp,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1) = mean(Clust20_conVoxelsComp1Grp(:,',num2str(i),'));']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1) = mean(Clust20_fmVoxelsComp1Grp(:,',num2str(i),'));']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1) = std(Clust20_conVoxelsComp1Grp(:,',num2str(i),'))./sqrt(14);']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1) = std(Clust20_fmVoxelsComp1Grp(:,',num2str(i),'))./sqrt(19);']);
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
    set(gca, 'XTickLabel', {'control','fibro'});
end

%% pain
clear all
con = [1:14];
fm = [1:7 9:20];

voxPain = importdata('Clust20_xyzpain_comp1.txt');

% each subject power for each extreme voxel in the pain effect
val=[];
a = 1;
for subs = con
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/painComp1MS+tlrc > Clust20_painVoxValuesPainComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/noPainComp1MS+tlrc > Clust20_noPainVoxValuesPainComp1.txt']);

        val = importdata('Clust20_painVoxValuesPainComp1.txt'); Clust20_conPainVoxelsComp1Pain(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesPainComp1.txt'); Clust20_conNoPainVoxelsComp1Pain(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/painComp1MS+tlrc > Clust20_painVoxValuesPainComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/noPainComp1MS+tlrc > Clust20_noPainVoxValuesPainComp1.txt']);

        val = importdata('Clust20_painVoxValuesPainComp1.txt'); Clust20_fmPainVoxelsComp1Pain(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesPainComp1.txt'); Clust20_fmNoPainVoxelsComp1Pain(a,i) = val(4); val=[];
    end
    a = a+1;
end

Clust20_painVoxelsPain = [Clust20_fmPainVoxelsComp1Pain;Clust20_conPainVoxelsComp1Pain];
Clust20_noPainVoxelsPain = [Clust20_fmNoPainVoxelsComp1Pain;Clust20_conNoPainVoxelsComp1Pain];

% list of locations of the extreme voxels in the pain effect
for i = 1:size(voxPain,1)
    eval(['!whereami ',num2str(voxPain(i,1)),' ',num2str(voxPain(i,2)),' ',num2str(voxPain(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPain{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPain{i,1}=wmiPain{i,1}(2:end);
end

save Clust20_comp1Pain voxPain wmiPain Clust20_painVoxelsPain Clust20_noPainVoxelsPain

for i=1:size(voxPain,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_painVoxelsComp1Pain(:,',num2str(i),')),mean(Clust20_noPainVoxelsComp1Pain(:,',num2str(i),'))];']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1:2) = [std(Clust20_painVoxelsComp1Pain(:,',num2str(i),'))./sqrt(33),std(Clust20_noPainVoxelsComp1Pain(:,',num2str(i),'))./sqrt(33)];']);
end;

% plots for the pain
for i=1:size(voxPain,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiPain{i});
    title(ti)
    xlim([0 3]);
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pain','No Pain'});
end

%% Interaction
clear all
con = [1:14];
fm = [1:7 9:20];

voxInt = importdata('Clust20_xyzInt_comp1.txt');

% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/painComp1MS+tlrc > Clust20_painVoxValuesIntComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/noPainComp1MS+tlrc > Clust20_noPainVoxValuesIntComp1.txt']);

        val = importdata('Clust20_painVoxValuesIntComp1.txt'); Clust20_conPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntComp1.txt'); Clust20_conNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/painComp1MS+tlrc > Clust20_painVoxValuesIntComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/noPainComp1MS+tlrc > Clust20_noPainVoxValuesIntComp1.txt']);

        val = importdata('Clust20_painVoxValuesIntComp1.txt'); Clust20_fmPainVoxelsComp1Int(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntComp1.txt'); Clust20_fmNoPainVoxelsComp1Int(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_comp1Int voxInt wmiInt Clust20_fmPainVoxelsComp1Int Clust20_fmNoPainVoxelsComp1Int...
    Clust20_conPainVoxelsInt Clust20_conNoPainVoxelsInt

for i=1:size(voxInt,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_conPainVoxelsComp1Int(:,',num2str(i),')),mean(Clust20_conNoPainVoxelsComp1Int(:,',num2str(i),'))];']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_fmPainVoxelsComp1Int(:,',num2str(i),')),mean(Clust20_fmNoPainVoxelsComp1Int(:,',num2str(i),'))];']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1:2) = [std(Clust20_conPainVoxelsComp1Int(:,',num2str(i),'))./sqrt(14),std(Clust20_conNoPainVoxelsComp1Int(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1:2) = [std(Clust20_fmPainVoxelsComp1Int(:,',num2str(i),'))./sqrt(19),std(Clust20_fmNoPainVoxelsComp1Int(:,',num2str(i),'))./sqrt(19)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),',mean_comp1_voxel_',num2str(i),');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Control','Fibro'});
    legend('Pain','No Pain');
end

clear all
load Clust20_comp1Grp
load Clust20_comp1Pain
load Clust20_comp1Int
save Clust20_comp1ext

%% 
%  ===============  for comp 2  =================
%
%% 3. extract the maximum values in each cluster for the group, pain and interaction between the two
cd /home/meg/Data/Maor/fibrodata/subjects
clear all
!3dExtrema -prefix Clust20_group_ext_comp2 -mask_file Clust20_group_comp2_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp2_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_pain_ext_comp2 -mask_file Clust20_pain_comp2_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp2_ctx+tlrc'[2]'
!3dExtrema -prefix Clust20_int_ext_comp2 -mask_file Clust20_int_comp2_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp2_ctx+tlrc'[3]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_group_ext_comp2+tlrc > Clust20_xyzGroup_comp2.txt
!3dmaskdump -xyz -nozero -noijk Clust20_pain_ext_comp2+tlrc > Clust20_xyzpain_comp2.txt
!3dmaskdump -xyz -nozero -noijk Clust20_int_ext_comp2+tlrc > Clust20_xyzInt_comp2.txt

% 5. creating a matrix of all maximum values for all subs for all condition
% according to the xyzInt file created
%% Group
% each subject power for each extreme voxel in the group effect
con = 1:14;
fm = [1:7 9:20];

voxGrp = importdata('Clust20_xyzGroup_comp2.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/painComp2MS+tlrc > Clust20_painVoxValuesGrpComp2.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/noPainComp2MS+tlrc > Clust20_noPainVoxValuesGrpComp2.txt']);

        val = importdata('Clust20_painVoxValuesGrpComp2.txt'); Clust20_conPainVoxValuesGrpComp2(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesGrpComp2.txt'); Clust20_conNoPainVoxValuesGrpComp2(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a=1;
for subs = fm
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/painComp2MS+tlrc > Clust20_painVoxValuesGrpComp2.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/noPainComp2MS+tlrc > Clust20_noPainVoxValuesGrpComp2.txt']);

        val = importdata('Clust20_painVoxValuesGrpComp2.txt'); Clust20_fmPainVoxValuesGrpComp2(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesGrpComp2.txt'); Clust20_fmNoPainVoxValuesGrpComp2(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_conVoxelsComp2Grp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_conPainVoxValuesGrpComp2(',num2str(i),',:);Clust20_conNoPainVoxValuesGrpComp2(',num2str(i),',:)],1);']);
end
for i=1:length(fm)
    eval(['Clust20_fmVoxelsComp2Grp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_fmPainVoxValuesGrpComp2(',num2str(i),',:);Clust20_fmNoPainVoxValuesGrpComp2(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrp,1)
    eval(['!whereami ',num2str(voxGrp(i,1)),' ',num2str(voxGrp(i,2)),' ',num2str(voxGrp(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrp{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrp{i,1}=wmiGrp{i,1}(2:end);
end

save Clust20_comp2Grp voxGrp wmiGrp Clust20_conVoxelsComp2Grp Clust20_fmVoxelsComp2Grp

for i=1:size(voxGrp,1)
    eval(['mean_comp2_voxel_',num2str(i),'(1,1) = mean(Clust20_conVoxelsComp2Grp(:,',num2str(i),'));']);
    eval(['mean_comp2_voxel_',num2str(i),'(2,1) = mean(Clust20_fmVoxelsComp2Grp(:,',num2str(i),'));']);
    eval(['sd_comp2_voxel_',num2str(i),'(1,1) = std(Clust20_conVoxelsComp2Grp(:,',num2str(i),'))./sqrt(14);']);
    eval(['sd_comp2_voxel_',num2str(i),'(2,1) = std(Clust20_fmVoxelsComp2Grp(:,',num2str(i),'))./sqrt(19);']);
end;

% plots for the group
for i=1:size(voxGrp,1)
    figure;
    eval(['h1 = barwitherr(sd_comp2_voxel_',num2str(i),''',mean_comp2_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrp{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'control','fibro'});
end

%% pain
clear all
con = [1:14];
fm = [1:7 9:20];

voxPain = importdata('Clust20_xyzpain_comp2.txt');

% each subject power for each extreme voxel in the pain effect
val=[];
a = 1;
for subs = con
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/painComp2MS+tlrc > Clust20_painVoxValuesPainComp2.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/noPainComp2MS+tlrc > Clust20_noPainVoxValuesPainComp2.txt']);

        val = importdata('Clust20_painVoxValuesPainComp2.txt'); Clust20_conPainVoxelsComp2Pain(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesPainComp2.txt'); Clust20_conNoPainVoxelsComp2Pain(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/painComp2MS+tlrc > Clust20_painVoxValuesPainComp2.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/noPainComp2MS+tlrc > Clust20_noPainVoxValuesPainComp2.txt']);

        val = importdata('Clust20_painVoxValuesPainComp2.txt'); Clust20_fmPainVoxelsComp2Pain(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesPainComp2.txt'); Clust20_fmNoPainVoxelsComp2Pain(a,i) = val(4); val=[];
    end
    a = a+1;
end

Clust20_painVoxelsComp2Pain = [Clust20_fmPainVoxelsComp2Pain;Clust20_conPainVoxelsComp2Pain];
Clust20_noPainVoxelsComp2Pain = [Clust20_fmNoPainVoxelsComp2Pain;Clust20_conNoPainVoxelsComp2Pain];

% list of locations of the extreme voxels in the pain effect
for i = 1:size(voxPain,1)
    eval(['!whereami ',num2str(voxPain(i,1)),' ',num2str(voxPain(i,2)),' ',num2str(voxPain(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPain{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPain{i,1}=wmiPain{i,1}(2:end);
end

save Clust20_comp2Pain voxPain wmiPain Clust20_painVoxelsComp2Pain Clust20_noPainVoxelsComp2Pain

for i=1:size(voxPain,1)
    eval(['mean_comp2_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_painVoxelsComp2Pain(:,',num2str(i),')),mean(Clust20_noPainVoxelsComp2Pain(:,',num2str(i),'))];']);
    eval(['sd_comp2_voxel_',num2str(i),'(1,1:2) = [std(Clust20_painVoxelsComp2Pain(:,',num2str(i),'))./sqrt(33),std(Clust20_noPainVoxelsComp2Pain(:,',num2str(i),'))./sqrt(33)];']);
end;

% plots for the pain
for i=1:size(voxPain,1)
    figure;
    eval(['h1 = barwitherr(sd_comp2_voxel_',num2str(i),''',mean_comp2_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiPain{i});
    title(ti)
    xlim([0 3]);
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pain','No Pain'});
end

%% Interaction
clear all
con = [1:14];
fm = [1:7 9:20];

voxInt = importdata('Clust20_xyzInt_comp2.txt');

% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/painComp2MS+tlrc > Clust20_painVoxValuesIntComp2.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/noPainComp2MS+tlrc > Clust20_noPainVoxValuesIntComp2.txt']);

        val = importdata('Clust20_painVoxValuesIntComp2.txt'); Clust20_conPainVoxelsComp2Int(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntComp2.txt'); Clust20_conNoPainVoxelsComp2Int(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/painComp2MS+tlrc > Clust20_painVoxValuesIntComp2.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/noPainComp2MS+tlrc > Clust20_noPainVoxValuesIntComp2.txt']);

        val = importdata('Clust20_painVoxValuesIntComp2.txt'); Clust20_fmPainVoxelsComp2Int(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntComp2.txt'); Clust20_fmNoPainVoxelsComp2Int(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_comp2Int voxInt wmiInt Clust20_fmPainVoxelsComp2Int Clust20_fmNoPainVoxelsComp2Int...
    Clust20_conPainVoxelsComp2Int Clust20_conNoPainVoxelsComp2Int

for i=1:size(voxInt,1)
    eval(['mean_comp2_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_conPainVoxelsComp2Int(:,',num2str(i),')),mean(Clust20_conNoPainVoxelsComp2Int(:,',num2str(i),'))];']);
    eval(['mean_comp2_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_fmPainVoxelsComp2Int(:,',num2str(i),')),mean(Clust20_fmNoPainVoxelsComp2Int(:,',num2str(i),'))];']);
    eval(['sd_comp2_voxel_',num2str(i),'(1,1:2) = [std(Clust20_conPainVoxelsComp2Int(:,',num2str(i),'))./sqrt(14),std(Clust20_conNoPainVoxelsComp2Int(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_comp2_voxel_',num2str(i),'(2,1:2) = [std(Clust20_fmPainVoxelsComp2Int(:,',num2str(i),'))./sqrt(19),std(Clust20_fmNoPainVoxelsComp2Int(:,',num2str(i),'))./sqrt(19)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_comp2_voxel_',num2str(i),',mean_comp2_voxel_',num2str(i),');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Control','Fibro'});
    legend('Pain','No Pain');
end

clear all
load Clust20_comp2Grp
load Clust20_comp2Pain
load Clust20_comp2Int
save Clust20_comp2ext


%% 
%  ===============  for comp 3  =================
%
%% 3. extract the maximum values in each cluster for the group, pain and interaction between the two
cd /home/meg/Data/Maor/fibrodata/subjects
clear all
!3dExtrema -prefix Clust20_group_ext_comp3 -mask_file Clust20_group_comp3_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp3_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_pain_ext_comp3 -mask_file Clust20_pain_comp3_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp3_ctx+tlrc'[2]'
!3dExtrema -prefix Clust20_int_ext_comp3 -mask_file Clust20_int_comp3_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_Comp3_ctx+tlrc'[3]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_group_ext_comp3+tlrc > Clust20_xyzGroup_comp3.txt
!3dmaskdump -xyz -nozero -noijk Clust20_pain_ext_comp3+tlrc > Clust20_xyzpain_comp3.txt
!3dmaskdump -xyz -nozero -noijk Clust20_int_ext_comp3+tlrc > Clust20_xyzInt_comp3.txt

% 5. creating a matrix of all maximum values for all subs for all condition
% according to the xyzInt file created

%% No Group!!!!!

%% pain
clear all
con = [1:14];
fm = [1:7 9:20];

voxPain = importdata('Clust20_xyzpain_comp3.txt');

% each subject power for each extreme voxel in the pain effect
val=[];
a = 1;
for subs = con
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/painComp3MS+tlrc > Clust20_painVoxValuesPainComp3.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/noPainComp3MS+tlrc > Clust20_noPainVoxValuesPainComp3.txt']);

        val = importdata('Clust20_painVoxValuesPainComp3.txt'); Clust20_conPainVoxelsComp3Pain(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesPainComp3.txt'); Clust20_conNoPainVoxelsComp3Pain(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/painComp3MS+tlrc > Clust20_painVoxValuesPainComp3.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/noPainComp3MS+tlrc > Clust20_noPainVoxValuesPainComp3.txt']);

        val = importdata('Clust20_painVoxValuesPainComp3.txt'); Clust20_fmPainVoxelsComp3Pain(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesPainComp3.txt'); Clust20_fmNoPainVoxelsComp3Pain(a,i) = val(4); val=[];
    end
    a = a+1;
end

Clust20_painVoxelsComp3Pain = [Clust20_fmPainVoxelsComp3Pain;Clust20_conPainVoxelsComp3Pain];
Clust20_noPainVoxelsComp3Pain = [Clust20_fmNoPainVoxelsComp3Pain;Clust20_conNoPainVoxelsComp3Pain];

% list of locations of the extreme voxels in the pain effect
for i = 1:size(voxPain,1)
    eval(['!whereami ',num2str(voxPain(i,1)),' ',num2str(voxPain(i,2)),' ',num2str(voxPain(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPain{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPain{i,1}=wmiPain{i,1}(2:end);
end

save Clust20_comp3Pain voxPain wmiPain Clust20_painVoxelsComp3Pain Clust20_noPainVoxelsComp3Pain

for i=1:size(voxPain,1)
    eval(['mean_comp3_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_painVoxelsComp3Pain(:,',num2str(i),')),mean(Clust20_noPainVoxelsComp3Pain(:,',num2str(i),'))];']);
    eval(['sd_comp3_voxel_',num2str(i),'(1,1:2) = [std(Clust20_painVoxelsComp3Pain(:,',num2str(i),'))./sqrt(33),std(Clust20_noPainVoxelsComp3Pain(:,',num2str(i),'))./sqrt(33)];']);
end;

% plots for the pain
for i=1:size(voxPain,1)
    figure;
    eval(['h1 = barwitherr(sd_comp3_voxel_',num2str(i),''',mean_comp3_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiPain{i});
    title(ti)
    xlim([0 3]);
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pain','No Pain'});
end

%% Interaction
clear all
con = [1:14];
fm = [1:7 9:20];

voxInt = importdata('Clust20_xyzInt_comp3.txt');

% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/painComp3MS+tlrc > Clust20_painVoxValuesIntComp3.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_1_40Hz/noPainComp3MS+tlrc > Clust20_noPainVoxValuesIntComp3.txt']);

        val = importdata('Clust20_painVoxValuesIntComp3.txt'); Clust20_conPainVoxelsComp3Int(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntComp3.txt'); Clust20_conNoPainVoxelsComp3Int(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/painComp3MS+tlrc > Clust20_painVoxValuesIntComp3.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_1_40Hz/noPainComp3MS+tlrc > Clust20_noPainVoxValuesIntComp3.txt']);

        val = importdata('Clust20_painVoxValuesIntComp3.txt'); Clust20_fmPainVoxelsComp3Int(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntComp3.txt'); Clust20_fmNoPainVoxelsComp3Int(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_comp3Int voxInt wmiInt Clust20_fmPainVoxelsComp3Int Clust20_fmNoPainVoxelsComp3Int...
    Clust20_conPainVoxelsComp3Int Clust20_conNoPainVoxelsComp3Int

for i=1:size(voxInt,1)
    eval(['mean_comp3_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_conPainVoxelsComp3Int(:,',num2str(i),')),mean(Clust20_conNoPainVoxelsComp3Int(:,',num2str(i),'))];']);
    eval(['mean_comp3_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_fmPainVoxelsComp3Int(:,',num2str(i),')),mean(Clust20_fmNoPainVoxelsComp3Int(:,',num2str(i),'))];']);
    eval(['sd_comp3_voxel_',num2str(i),'(1,1:2) = [std(Clust20_conPainVoxelsComp3Int(:,',num2str(i),'))./sqrt(14),std(Clust20_conNoPainVoxelsComp3Int(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_comp3_voxel_',num2str(i),'(2,1:2) = [std(Clust20_fmPainVoxelsComp3Int(:,',num2str(i),'))./sqrt(19),std(Clust20_fmNoPainVoxelsComp3Int(:,',num2str(i),'))./sqrt(19)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_comp3_voxel_',num2str(i),',mean_comp3_voxel_',num2str(i),');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Control','Fibro'});
    legend('Pain','No Pain');
end

clear all
load Clust20_comp3Pain
load Clust20_comp3Int
save Clust20_comp3ext


%% for different frequency band (8-12Hz)
clear
load /media/My_Passport/fibrodata/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[10 11];
cfg.channel = {'MEG'};
for i=1:14
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    % noise estimation
    load ERFaverages
    eval(['conSub',num2str(i),'all_8_12_Hz=ft_preprocessing(cfg,conSub',num2str(i),'all);']);
    eval(['conSub',num2str(i),'noPain_8_12_Hz=ft_preprocessing(cfg,conSub',num2str(i),'noPain);']);
    eval(['conSub',num2str(i),'pain_8_12_Hz=ft_preprocessing(cfg,conSub',num2str(i),'pain);']);
    load 'SAM/all4cov,8-12Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    eval(['vsPain_8_12_Hz=ActWgts*conSub',num2str(i),'pain_8_12_Hz.avg(:,nearest(time,.250):nearest(time,.600));']);
    vsPain_8_12_HzMS=mean(vsPain_8_12_Hz.*vsPain_8_12_Hz,2)./ns;
    vsPain_8_12_HzMS=vsPain_8_12_HzMS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPain_8_12_HzMS(isnan(vsPain_8_12_HzMS))=0;
    
    % for no-pain
    eval(['vsNoPain_8_12_Hz=ActWgts*conSub',num2str(i),'noPain_8_12_Hz.avg(:,nearest(time,.250):nearest(time,.600));']);
    vsNoPain_8_12_HzMS=mean(vsNoPain_8_12_Hz.*vsNoPain_8_12_Hz,2)./ns;
    vsNoPain_8_12_HzMS=vsNoPain_8_12_HzMS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPain_8_12_HzMS(isnan(vsNoPain_8_12_HzMS))=0;

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_8_12_HzMS';
    VS2Brik(cfg1,vsPain_8_12_HzMS);
    cfg1.prefix='noPain_8_12_HzMS';
    VS2Brik(cfg1,vsNoPain_8_12_HzMS);        
    
    eval(['clear ActWgts cfg1 conSub',num2str(i),'all conSub',num2str(i),'all_8_12_Hz conSub',num2str(i),'noPain conSub',num2str(i),'noPain_8_12_Hz conSub',num2str(i),'pain conSub',num2str(i),'pain_8_12_Hz ns vsNoPain_8_12_Hz vsNoPain_8_12_HzMS vsPain_8_12_Hz vsPain_8_12_HzMS'])

end

clear
load /media/My_Passport/fibrodata/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.fmtinuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[10 11];
cfg.channel = {'MEG'};
for i=[1:7,9:20]
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    % noise estimation
    load ERFaverages
    eval(['fmSub',num2str(i),'all_8_12_Hz=ft_preprocessing(cfg,fmSub',num2str(i),'all);']);
    eval(['fmSub',num2str(i),'noPain_8_12_Hz=ft_preprocessing(cfg,fmSub',num2str(i),'noPain);']);
    eval(['fmSub',num2str(i),'pain_8_12_Hz=ft_preprocessing(cfg,fmSub',num2str(i),'pain);']);
    load 'SAM/all4cov,8-12Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    % comp1
    eval(['vsPain_8_12_Hz=ActWgts*fmSub',num2str(i),'pain_8_12_Hz.avg(:,nearest(time,.250):nearest(time,.600));']);
    vsPain_8_12_HzMS=mean(vsPain_8_12_Hz.*vsPain_8_12_Hz,2)./ns;
    vsPain_8_12_HzMS=vsPain_8_12_HzMS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPain_8_12_HzMS(isnan(vsPain_8_12_HzMS))=0;
    
    % for no-pain
    % comp1
    eval(['vsNoPain_8_12_Hz=ActWgts*fmSub',num2str(i),'noPain_8_12_Hz.avg(:,nearest(time,.250):nearest(time,.600));']);
    vsNoPain_8_12_HzMS=mean(vsNoPain_8_12_Hz.*vsNoPain_8_12_Hz,2)./ns;
    vsNoPain_8_12_HzMS=vsNoPain_8_12_HzMS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPain_8_12_HzMS(isnan(vsNoPain_8_12_HzMS))=0;

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_8_12_HzMS';
    VS2Brik(cfg1,vsPain_8_12_HzMS);
    cfg1.prefix='noPain_8_12_HzMS';
    VS2Brik(cfg1,vsNoPain_8_12_HzMS);        
    
    eval(['clear ActWgts cfg1 fmSub',num2str(i),'all fmSub',num2str(i),'all_8_12_Hz fmSub',num2str(i),'noPain fmSub',num2str(i),'noPain_8_12_Hz fmSub',num2str(i),'pain fmSub',num2str(i),'pain_8_12_Hz ns vsNoPain_8_12_Hz vsNoPain_8_12_HzMS vsPain_8_12_Hz vsPain_8_12_HzMS'])

end


%% moving files to tlrc and moving them into a folder
% now open a terminal and type:

% for i in {1..14}
% do
%     cd /media/My_Passport/fibrodata/con/con$i
%     @auto_tlrc -apar brain+tlrc -input pain_8_12_HzMS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPain_8_12_HzMS+orig -dxyz 5
%     mkdir SAM_abs_10_11_Hz
%     cp *HzMS+tlrc* SAM_abs_10_11_Hz
% done
% 
% for i in 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 19 20
% do
%     cd /media/My_Passport/fibrodata/fm/fm$i
%     @auto_tlrc -apar brain+tlrc -input pain_8_12_HzMS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPain_8_12_HzMS+orig -dxyz 5
%     mkdir SAM_abs_10_11_Hz
%     cp *HzMS+tlrc* SAM_abs_10_11_Hz
% done
%%
% 1. run 3dMVM
% 2. firstly, lets get ridd of the voxels outside the cortex
cd /media/My_Passport/fibrodata
masktlrc('3dMVM_abs_10_11_Hz+tlrc','MASKctx+tlrc','_ctx');

%% 3. create your cluster mask based on F threshold in afni and save it.

%% 
%  ===============  for comp 1  =================
%
% extract the maximum values in each cluster for the group, pain and interaction between the two
cd /home/meg/Data/Maor/fibrodata/subjects
clear all
!3dExtrema -prefix Clust20_8_12_group_ext -mask_file Clust20_8_12_Grp_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_8_12_Hz_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_8_12_pain_ext -mask_file Clust20_8_12_Pain_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_8_12_Hz_ctx+tlrc'[2]'
!3dExtrema -prefix Clust20_8_12_int_ext -mask_file Clust20_8_12_Int_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_8_12_Hz_ctx+tlrc'[3]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_8_12_group_ext+tlrc > Clust20_xyzGroup_8_12.txt
!3dmaskdump -xyz -nozero -noijk Clust20_8_12_pain_ext+tlrc > Clust20_xyzpain_8_12.txt
!3dmaskdump -xyz -nozero -noijk Clust20_8_12_int_ext+tlrc > Clust20_xyzInt_8_12.txt

% 5. creating a matrix of all maximum values for all subs for all condition
% according to the xyzInt file created
%% Group
% each subject power for each extreme voxel in the group effect
con = 1:14;
fm = [1:7 9:20];

voxGrp = importdata('Clust20_xyzGroup_8_12.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_8_12Hz/pain_8_12_HzMS+tlrc > Clust20_8_12Hz_painVoxValuesGrp.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_8_12Hz/noPain_8_12_HzMS+tlrc > Clust20_8_12Hz_noPainVoxValuesGrp.txt']);

        val = importdata('Clust20_8_12Hz_painVoxValuesGrp.txt'); Clust20_8_12Hz_conPainVoxValuesGrp(a,i) = val(4); val=[];
        val = importdata('Clust20_8_12Hz_noPainVoxValuesGrp.txt'); Clust20_8_12Hz_conNoPainVoxValuesGrp(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = fm
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_8_12Hz/pain_8_12_HzMS+tlrc > Clust20_8_12Hz_painVoxValuesGrp.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_8_12Hz/noPain_8_12_HzMS+tlrc > Clust20_8_12Hz_noPainVoxValuesGrp.txt']);

        val = importdata('Clust20_8_12Hz_painVoxValuesGrp.txt'); Clust20_8_12Hz_fmPainVoxValuesGrp(a,i) = val(4); val=[];
        val = importdata('Clust20_8_12Hz_noPainVoxValuesGrp.txt'); Clust20_8_12Hz_fmNoPainVoxValuesGrp(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_8_12Hz_conVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_8_12Hz_conPainVoxValuesGrp(',num2str(i),',:);Clust20_8_12Hz_conNoPainVoxValuesGrp(',num2str(i),',:)],1);']);
end
for i=1:length(fm)
    eval(['Clust20_8_12Hz_fmVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_8_12Hz_fmPainVoxValuesGrp(',num2str(i),',:);Clust20_8_12Hz_fmNoPainVoxValuesGrp(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrp,1)
    eval(['!whereami ',num2str(voxGrp(i,1)),' ',num2str(voxGrp(i,2)),' ',num2str(voxGrp(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrp{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrp{i,1}=wmiGrp{i,1}(2:end);
end

save Clust20_8_12Hz_Grp voxGrp wmiGrp Clust20_8_12Hz_conVoxelsGrp Clust20_8_12Hz_fmVoxelsGrp

for i=1:size(voxGrp,1)
    eval(['mean_voxel_',num2str(i),'(1,1) = mean(Clust20_8_12Hz_conVoxelsGrp(:,',num2str(i),'));']);
    eval(['mean_voxel_',num2str(i),'(2,1) = mean(Clust20_8_12Hz_fmVoxelsGrp(:,',num2str(i),'));']);
    eval(['sd_voxel_',num2str(i),'(1,1) = std(Clust20_8_12Hz_conVoxelsGrp(:,',num2str(i),'))./sqrt(14);']);
    eval(['sd_voxel_',num2str(i),'(2,1) = std(Clust20_8_12Hz_fmVoxelsGrp(:,',num2str(i),'))./sqrt(19);']);
end;

% plots for the group
for i=1:size(voxGrp,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrp{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'control','fibro'});
end

%% pain
clear all
con = 1:14;
fm = [1:7 9:20];

voxPain = importdata('Clust20_xyzpain_8_12.txt');

% each subject power for each extreme voxel in the pain effect
val=[];
a = 1;
for subs = con
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_8_12Hz/pain_8_12_HzMS+tlrc > Clust20_8_12Hz_painVoxValuesPain.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_8_12Hz/noPain_8_12_HzMS+tlrc > Clust20_8_12Hz_noPainVoxValuesPain.txt']);

        val = importdata('Clust20_8_12Hz_painVoxValuesPain.txt'); Clust20_8_12Hz_conPainVoxelsPain(a,i) = val(4); val=[];
        val = importdata('Clust20_8_12Hz_noPainVoxValuesPain.txt'); Clust20_8_12Hz_conNoPainVoxelsPain(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = fm
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_8_12Hz/pain_8_12_HzMS+tlrc > Clust20_8_12Hz_painVoxValuesPain.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_8_12Hz/noPain_8_12_HzMS+tlrc > Clust20_8_12Hz_noPainVoxValuesPain.txt']);

        val = importdata('Clust20_8_12Hz_painVoxValuesPain.txt'); Clust20_8_12Hz_fmPainVoxelsPain(a,i) = val(4); val=[];
        val = importdata('Clust20_8_12Hz_noPainVoxValuesPain.txt'); Clust20_8_12Hz_fmNoPainVoxelsPain(a,i) = val(4); val=[];
    end
    a = a+1;
end

Clust20_8_12Hz_painVoxelsPain = [Clust20_8_12Hz_fmPainVoxelsPain;Clust20_8_12Hz_conPainVoxelsPain];
Clust20_8_12Hz_noPainVoxelsPain = [Clust20_8_12Hz_fmNoPainVoxelsPain;Clust20_8_12Hz_conNoPainVoxelsPain];

% list of locations of the extreme voxels in the pain effect
for i = 1:size(voxPain,1)
    eval(['!whereami ',num2str(voxPain(i,1)),' ',num2str(voxPain(i,2)),' ',num2str(voxPain(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPain{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPain{i,1}=wmiPain{i,1}(2:end);
end

save Clust20_8_12Hz_Pain voxPain wmiPain Clust20_8_12Hz_painVoxelsPain Clust20_8_12Hz_noPainVoxelsPain

for i=1:size(voxPain,1)
    eval(['mean_8_12Hz_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_8_12Hz_painVoxelsPain(:,',num2str(i),')),mean(Clust20_8_12Hz_noPainVoxelsPain(:,',num2str(i),'))];']);
    eval(['sd_8_12Hz_voxel_',num2str(i),'(1,1:2) = [std(Clust20_8_12Hz_painVoxelsPain(:,',num2str(i),'))./sqrt(33),std(Clust20_8_12Hz_noPainVoxelsPain(:,',num2str(i),'))./sqrt(33)];']);
end;

% plots for the pain
for i=1:size(voxPain,1)
    figure;
    eval(['h1 = barwitherr(sd_8_12Hz_voxel_',num2str(i),''',mean_8_12Hz_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiPain{i});
    title(ti)
    xlim([0 3]);
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pain','No Pain'});
end

%% Interaction
clear all
con = [1:14];
fm = [1:7 9:20];

voxInt = importdata('Clust20_xyzInt_8_12.txt');

% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_8_12Hz/pain_8_12_HzMS+tlrc > Clust20_8_12Hz_painVoxValuesInt.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_8_12Hz/noPain_8_12_HzMS+tlrc > Clust20_8_12Hz_noPainVoxValuesInt.txt']);

        val = importdata('Clust20_8_12Hz_painVoxValuesInt.txt'); Clust20_8_12Hz_conPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_8_12Hz_noPainVoxValuesInt.txt'); Clust20_8_12Hz_conNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = fm
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_8_12Hz/pain_8_12_HzMS+tlrc > Clust20_8_12Hz_painVoxValuesInt.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_8_12Hz/noPain_8_12_HzMS+tlrc > Clust20_8_12Hz_noPainVoxValuesInt.txt']);

        val = importdata('Clust20_8_12Hz_painVoxValuesInt.txt'); Clust20_8_12Hz_fmPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_8_12Hz_noPainVoxValuesInt.txt'); Clust20_8_12Hz_fmNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_8_12Hz_Int voxInt wmiInt Clust20_8_12Hz_fmPainVoxelsInt Clust20_8_12Hz_fmNoPainVoxelsInt...
    Clust20_8_12Hz_conPainVoxelsInt Clust20_8_12Hz_conNoPainVoxelsInt

for i=1:size(voxInt,1)
    eval(['mean_8_12Hz_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_8_12Hz_conPainVoxelsInt(:,',num2str(i),')),mean(Clust20_8_12Hz_conNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['mean_8_12Hz_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_8_12Hz_fmPainVoxelsInt(:,',num2str(i),')),mean(Clust20_8_12Hz_fmNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['sd_8_12Hz_voxel_',num2str(i),'(1,1:2) = [std(Clust20_8_12Hz_conPainVoxelsInt(:,',num2str(i),'))./sqrt(14),std(Clust20_8_12Hz_conNoPainVoxelsInt(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_8_12Hz_voxel_',num2str(i),'(2,1:2) = [std(Clust20_8_12Hz_fmPainVoxelsInt(:,',num2str(i),'))./sqrt(19),std(Clust20_8_12Hz_fmNoPainVoxelsInt(:,',num2str(i),'))./sqrt(19)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_8_12Hz_voxel_',num2str(i),',mean_8_12Hz_voxel_',num2str(i),');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Control','Fibro'});
    legend('Pain','No Pain');
end

clear all
load Clust20_8_12Hz_Grp
load Clust20_8_12Hz_Pain
load Clust20_8_12Hz_Int
save Clust20_8_12Hz_ext
load Clust20_8_12Hz_ext


%% for different frequency band (12-18Hz)
%% 3. creating param file (do it once!!)
cd /home/meg/Data/Maor/fibrodata/subjects
createPARAM('all4cov_12_18Hz','ERF','All',[0 0.7],'All',[-0.3 0],[12 18],[-0.3 0.7]); 
% because I create the VSs in MATLAB only the segment window [-0.3 0.7] is
% important.
% now go into the param file and change Nolte to MultiSphere (because I don't have individual MRIs)!!!!
% -------------------------------------------------------------------------

%% 4. SAMcov,wts,erf
cd /home/meg/Data/Maor/fibrodata/subjects
for i=1:14
    eval(['!SAMcov64 -r con',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov_12_18Hz -v']);
    eval(['!SAMwts64 -r con',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov_12_18Hz -c Alla -v']);
end
for i=[1:7,9:20]
    if i==19 || i==20
        eval(['!SAMcov64 -r fm',num2str(i),' -d xc,lf,hb_c,rfhp0.1Hz -m all4cov_12_18Hz -v']);
        eval(['!SAMwts64 -r fm',num2str(i),' -d xc,lf,hb_c,rfhp0.1Hz -m all4cov_12_18Hz -c Alla -v']);
    else
        eval(['!SAMcov64 -r fm',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov_12_18Hz -v']);
        eval(['!SAMwts64 -r fm',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov_12_18Hz -c Alla -v']);
    end
end

% "Alla" and not "All" because it adds and 'a' to the file name for some reason

% reading the weights
clear
wtsNoSuf='SAM/all4cov_12_18Hz,12-18Hz,Alla';
for i=1:14
    eval(['cd /home/meg/Data/Maor/fibrodata/subjects/con',num2str(i)]);
    [~, ~, ActWgts]=readWeights([wtsNoSuf,'.wts']); % it takes a while
    save([wtsNoSuf,'.mat'], 'ActWgts'); % save in mat format, quicker to read later.
    clear ActWgts
    disp(i);
end
for i=[1:7,9:20]
    eval(['cd /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(i)]);
    [~, ~, ActWgts]=readWeights([wtsNoSuf,'.wts']); % it takes a while
    save([wtsNoSuf,'.mat'], 'ActWgts'); % save in mat format, quicker to read later.
    clear ActWgts
    disp(i);
end

%% 5. creating the virutal sensors
clear
load /home/meg/Data/Maor/fibrodata/subjects/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[12 18];
cfg.channel = {'MEG'};
for i=1:14
    disp(i);
    eval(['cd /home/meg/Data/Maor/fibrodata/subjects/con',num2str(i)]);
    % noise estimation
    load ERFaverages
    eval(['conSub',num2str(i),'all_12_18Hz=ft_preprocessing(cfg,conSub',num2str(i),'all);']);
    eval(['conSub',num2str(i),'noPain_12_18Hz=ft_preprocessing(cfg,conSub',num2str(i),'noPain);']);
    eval(['conSub',num2str(i),'pain_12_18Hz=ft_preprocessing(cfg,conSub',num2str(i),'pain);']);
    load 'SAM/all4cov_12_18Hz,12-18Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    eval(['vsPain_12_18Hz=ActWgts*conSub',num2str(i),'pain_12_18Hz.avg(:,nearest(time,.280):nearest(time,.600));']);
    vsPain_12_18HzMS=mean(vsPain_12_18Hz.*vsPain_12_18Hz,2)./ns;
    vsPain_12_18HzMS=vsPain_12_18HzMS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPain_12_18HzMS(isnan(vsPain_12_18HzMS))=0;
    
    % for no-pain
    eval(['vsNoPain_12_18Hz=ActWgts*conSub',num2str(i),'noPain_12_18Hz.avg(:,nearest(time,.280):nearest(time,.600));']);
    vsNoPain_12_18HzMS=mean(vsNoPain_12_18Hz.*vsNoPain_12_18Hz,2)./ns;
    vsNoPain_12_18HzMS=vsNoPain_12_18HzMS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPain_12_18HzMS(isnan(vsNoPain_12_18HzMS))=0;

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_12_18HzMS';
    VS2Brik(cfg1,vsPain_12_18HzMS);
    cfg1.prefix='noPain_12_18HzMS';
    VS2Brik(cfg1,vsNoPain_12_18HzMS);        
    
    eval(['clear ActWgts cfg1 conSub',num2str(i),'all conSub',num2str(i),'all_12_18Hz conSub',num2str(i),'noPain conSub',num2str(i),'noPain_12_18Hz conSub',num2str(i),'pain conSub',num2str(i),'pain_12_18Hz ns vsNoPain_12_18Hz vsNoPain_12_18HzMS vsPain_12_18Hz vsPain_12_18HzMS'])

end

clear
load /home/meg/Data/Maor/fibrodata/subjects/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.fmtinuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no2';
cfg.bpfreq=[12 18];
cfg.channel = {'MEG'};
for i=[1:7,9:20]
    disp(i);
    eval(['cd /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(i)]);
    % noise estimation
    load ERFaverages
    eval(['fmSub',num2str(i),'all_12_18Hz=ft_preprocessing(cfg,fmSub',num2str(i),'all);']);
    eval(['fmSub',num2str(i),'noPain_12_18Hz=ft_preprocessing(cfg,fmSub',num2str(i),'noPain);']);
    eval(['fmSub',num2str(i),'pain_12_18Hz=ft_preprocessing(cfg,fmSub',num2str(i),'pain);']);
    load 'SAM/all4cov_12_18Hz,12-18Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    % comp1
    eval(['vsPain_12_18Hz=ActWgts*fmSub',num2str(i),'pain_12_18Hz.avg(:,nearest(time,.280):nearest(time,.600));']);
    vsPain_12_18HzMS=mean(vsPain_12_18Hz.*vsPain_12_18Hz,2)./ns;
    vsPain_12_18HzMS=vsPain_12_18HzMS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsPain_12_18HzMS(isnan(vsPain_12_18HzMS))=0;
    
    % for no-pain
    % comp1
    eval(['vsNoPain_12_18Hz=ActWgts*fmSub',num2str(i),'noPain_12_18Hz.avg(:,nearest(time,.280):nearest(time,.600));']);
    vsNoPain_12_18HzMS=mean(vsNoPain_12_18Hz.*vsNoPain_12_18Hz,2)./ns;
    vsNoPain_12_18HzMS=vsNoPain_12_18HzMS.*10^25; % 10^25 is rescaling the data so it won't be so small
    vsNoPain_12_18HzMS(isnan(vsNoPain_12_18HzMS))=0;

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_12_18HzMS';
    VS2Brik(cfg1,vsPain_12_18HzMS);
    cfg1.prefix='noPain_12_18HzMS';
    VS2Brik(cfg1,vsNoPain_12_18HzMS);        
    
    eval(['clear ActWgts cfg1 fmSub',num2str(i),'all fmSub',num2str(i),'all_12_18Hz fmSub',num2str(i),'noPain fmSub',num2str(i),'noPain_12_18Hz fmSub',num2str(i),'pain fmSub',num2str(i),'pain_12_18Hz ns vsNoPain_12_18Hz vsNoPain_12_18HzMS vsPain_12_18Hz vsPain_12_18HzMS'])

end

%% moving files to tlrc and moving them into a folder
% now open a terminal and type:
% 
% for i in {1..14}
% do
%     cd /home/meg/Data/Maor/fibrodata/subjects/con$i
%     @auto_tlrc -apar brain+tlrc -input pain_12_18HzMS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPain_12_18HzMS+orig -dxyz 5
%     mkdir SAM_12_18Hz
%     cp *18HzMS+tlrc* SAM_12_18Hz
% done
% 
% for i in 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 19 20
% do
%     cd /home/meg/Data/Maor/fibrodata/subjects/fm$i
%     @auto_tlrc -apar brain+tlrc -input pain_12_18HzMS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPain_12_18HzMS+orig -dxyz 5
%     mkdir SAM_12_18Hz
%     cp *18HzMS+tlrc* SAM_12_18Hz
% done

%%
% 1. run 3dMVM_12_18Hz
% 2. firstly, lets get ridd of the voxels outside the cortex
cd /home/meg/Data/Maor/fibrodata/subjects
masktlrc('3dMVM_12_18Hz+tlrc','MASKctx+tlrc','_ctx');

%% 3. create your cluster mask based on F threshold in afni and save it.

%% 
%  ===============  for comp 1  =================
%
% extract the maximum values in each cluster for the group, pain and interaction between the two
cd /home/meg/Data/Maor/fibrodata/subjects
clear all
!3dExtrema -prefix Clust20_12_18_group_ext -mask_file Clust20_12_18_Grp_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_12_18Hz_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_12_18_pain_ext -mask_file Clust20_12_18_Pain_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_12_18Hz_ctx+tlrc'[2]'
!3dExtrema -prefix Clust20_12_18_int_ext -mask_file Clust20_12_18_Int_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_12_18Hz_ctx+tlrc'[3]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_12_18_group_ext+tlrc > Clust20_xyzGroup_12_18.txt
!3dmaskdump -xyz -nozero -noijk Clust20_12_18_pain_ext+tlrc > Clust20_xyzpain_12_18.txt
!3dmaskdump -xyz -nozero -noijk Clust20_12_18_int_ext+tlrc > Clust20_xyzInt_12_18.txt

% 5. creating a matrix of all maximum values for all subs for all condition
% according to the xyzInt file created

%% Group
% each subject power for each extreme voxel in the group effect
con = 1:14;
fm = [1:7 9:20];

voxGrp = importdata('Clust20_xyzGroup_12_18.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_12_18Hz/pain_12_18HzMS+tlrc > Clust20_12_18Hz_painVoxValuesGrp.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_12_18Hz/noPain_12_18HzMS+tlrc > Clust20_12_18Hz_noPainVoxValuesGrp.txt']);

        val = importdata('Clust20_12_18Hz_painVoxValuesGrp.txt'); Clust20_12_18Hz_conPainVoxValuesGrp(a,i) = val(4); val=[];
        val = importdata('Clust20_12_18Hz_noPainVoxValuesGrp.txt'); Clust20_12_18Hz_conNoPainVoxValuesGrp(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = fm
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_12_18Hz/pain_12_18HzMS+tlrc > Clust20_12_18Hz_painVoxValuesGrp.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_12_18Hz/noPain_12_18HzMS+tlrc > Clust20_12_18Hz_noPainVoxValuesGrp.txt']);

        val = importdata('Clust20_12_18Hz_painVoxValuesGrp.txt'); Clust20_12_18Hz_fmPainVoxValuesGrp(a,i) = val(4); val=[];
        val = importdata('Clust20_12_18Hz_noPainVoxValuesGrp.txt'); Clust20_12_18Hz_fmNoPainVoxValuesGrp(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_12_18Hz_conVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_12_18Hz_conPainVoxValuesGrp(',num2str(i),',:);Clust20_12_18Hz_conNoPainVoxValuesGrp(',num2str(i),',:)],1);']);
end
for i=1:length(fm)
    eval(['Clust20_12_18Hz_fmVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_12_18Hz_fmPainVoxValuesGrp(',num2str(i),',:);Clust20_12_18Hz_fmNoPainVoxValuesGrp(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrp,1)
    eval(['!whereami ',num2str(voxGrp(i,1)),' ',num2str(voxGrp(i,2)),' ',num2str(voxGrp(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrp{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrp{i,1}=wmiGrp{i,1}(2:end);
end

save Clust20_12_18Hz_Grp voxGrp wmiGrp Clust20_12_18Hz_conVoxelsGrp Clust20_12_18Hz_fmVoxelsGrp

for i=1:size(voxGrp,1)
    eval(['mean_voxel_',num2str(i),'(1,1) = mean(Clust20_12_18Hz_conVoxelsGrp(:,',num2str(i),'));']);
    eval(['mean_voxel_',num2str(i),'(2,1) = mean(Clust20_12_18Hz_fmVoxelsGrp(:,',num2str(i),'));']);
    eval(['sd_voxel_',num2str(i),'(1,1) = std(Clust20_12_18Hz_conVoxelsGrp(:,',num2str(i),'))./sqrt(14);']);
    eval(['sd_voxel_',num2str(i),'(2,1) = std(Clust20_12_18Hz_fmVoxelsGrp(:,',num2str(i),'))./sqrt(19);']);
end;

% plots for the group
for i=1:size(voxGrp,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrp{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'control','fibro'});
end
%% pain
clear all
con = 1:14;
fm = [1:7 9:20];

voxPain = importdata('Clust20_xyzpain_12_18.txt');

% each subject power for each extreme voxel in the pain effect
val=[];
a = 1;
for subs = con
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_12_18Hz/pain_12_18HzMS+tlrc > Clust20_12_18Hz_painVoxValuesPain.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_12_18Hz/noPain_12_18HzMS+tlrc > Clust20_12_18Hz_noPainVoxValuesPain.txt']);

        val = importdata('Clust20_12_18Hz_painVoxValuesPain.txt'); Clust20_12_18Hz_conPainVoxelsPain(a,i) = val(4); val=[];
        val = importdata('Clust20_12_18Hz_noPainVoxValuesPain.txt'); Clust20_12_18Hz_conNoPainVoxelsPain(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = fm
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_12_18Hz/pain_12_18HzMS+tlrc > Clust20_12_18Hz_painVoxValuesPain.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_12_18Hz/noPain_12_18HzMS+tlrc > Clust20_12_18Hz_noPainVoxValuesPain.txt']);

        val = importdata('Clust20_12_18Hz_painVoxValuesPain.txt'); Clust20_12_18Hz_fmPainVoxelsPain(a,i) = val(4); val=[];
        val = importdata('Clust20_12_18Hz_noPainVoxValuesPain.txt'); Clust20_12_18Hz_fmNoPainVoxelsPain(a,i) = val(4); val=[];
    end
    a = a+1;
end

Clust20_12_18Hz_painVoxelsPain = [Clust20_12_18Hz_fmPainVoxelsPain;Clust20_12_18Hz_conPainVoxelsPain];
Clust20_12_18Hz_noPainVoxelsPain = [Clust20_12_18Hz_fmNoPainVoxelsPain;Clust20_12_18Hz_conNoPainVoxelsPain];

% list of locations of the extreme voxels in the pain effect
for i = 1:size(voxPain,1)
    eval(['!whereami ',num2str(voxPain(i,1)),' ',num2str(voxPain(i,2)),' ',num2str(voxPain(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPain{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPain{i,1}=wmiPain{i,1}(2:end);
end

save Clust20_12_18Hz_Pain voxPain wmiPain Clust20_12_18Hz_painVoxelsPain Clust20_12_18Hz_noPainVoxelsPain

for i=1:size(voxPain,1)
    eval(['mean_12_18Hz_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_12_18Hz_painVoxelsPain(:,',num2str(i),')),mean(Clust20_12_18Hz_noPainVoxelsPain(:,',num2str(i),'))];']);
    eval(['sd_12_18Hz_voxel_',num2str(i),'(1,1:2) = [std(Clust20_12_18Hz_painVoxelsPain(:,',num2str(i),'))./sqrt(33),std(Clust20_12_18Hz_noPainVoxelsPain(:,',num2str(i),'))./sqrt(33)];']);
end;

% plots for the pain
for i=1:size(voxPain,1)
    figure;
    eval(['h1 = barwitherr(sd_12_18Hz_voxel_',num2str(i),''',mean_12_18Hz_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiPain{i});
    title(ti)
    xlim([0 3]);
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pain','No Pain'});
end

%% Interaction
clear all
con = [1:14];
fm = [1:7 9:20];

voxInt = importdata('Clust20_xyzInt_12_18.txt');

% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_12_18Hz/pain_12_18HzMS+tlrc > Clust20_12_18Hz_painVoxValuesInt.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/con',num2str(subs),'/SAM_12_18Hz/noPain_12_18HzMS+tlrc > Clust20_12_18Hz_noPainVoxValuesInt.txt']);

        val = importdata('Clust20_12_18Hz_painVoxValuesInt.txt'); Clust20_12_18Hz_conPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_12_18Hz_noPainVoxValuesInt.txt'); Clust20_12_18Hz_conNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end

val=[];
a = 1;
for subs = fm
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_12_18Hz/pain_12_18HzMS+tlrc > Clust20_12_18Hz_painVoxValuesInt.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/fibrodata/subjects/fm',num2str(subs),'/SAM_12_18Hz/noPain_12_18HzMS+tlrc > Clust20_12_18Hz_noPainVoxValuesInt.txt']);

        val = importdata('Clust20_12_18Hz_painVoxValuesInt.txt'); Clust20_12_18Hz_fmPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_12_18Hz_noPainVoxValuesInt.txt'); Clust20_12_18Hz_fmNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_12_18Hz_Int voxInt wmiInt Clust20_12_18Hz_fmPainVoxelsInt Clust20_12_18Hz_fmNoPainVoxelsInt...
    Clust20_12_18Hz_conPainVoxelsInt Clust20_12_18Hz_conNoPainVoxelsInt

for i=1:size(voxInt,1)
    eval(['mean_12_18Hz_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_12_18Hz_conPainVoxelsInt(:,',num2str(i),')),mean(Clust20_12_18Hz_conNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['mean_12_18Hz_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_12_18Hz_fmPainVoxelsInt(:,',num2str(i),')),mean(Clust20_12_18Hz_fmNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['sd_12_18Hz_voxel_',num2str(i),'(1,1:2) = [std(Clust20_12_18Hz_conPainVoxelsInt(:,',num2str(i),'))./sqrt(14),std(Clust20_12_18Hz_conNoPainVoxelsInt(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_12_18Hz_voxel_',num2str(i),'(2,1:2) = [std(Clust20_12_18Hz_fmPainVoxelsInt(:,',num2str(i),'))./sqrt(19),std(Clust20_12_18Hz_fmNoPainVoxelsInt(:,',num2str(i),'))./sqrt(19)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_12_18Hz_voxel_',num2str(i),',mean_12_18Hz_voxel_',num2str(i),');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Control','Fibro'});
    legend('Pain','No Pain');
end

clear all
load Clust20_12_18Hz_Grp
load Clust20_12_18Hz_Pain
load Clust20_12_18Hz_Int
save Clust20_12_18Hz_ext
load Clust20_12_18Hz_ext


%% planar gradiometer
% time frequency analysis for con planar data
for i=1:14
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load splitconds
    grad        = ft_read_header('xc,hb,lf_c,rfhp0.1Hz');
    pain.grad   = grad.grad;
    noPain.grad = grad.grad;

    cfg                         = [];
    cfg.planarmethod            = 'sincos';
    cfg_neighb.method           = 'distance';
    cfg_neighb.layout           = '4D248.lay';
    cfg_neighb.neighbourdist    = 0.04; 
    cfg.neighbours  = ft_prepare_neighbours(cfg_neighb, pain);
  
    pain_planar     = ft_megplanar(cfg, pain);
    noPain_planar   = ft_megplanar(cfg, noPain);

    cfg               = [];
    cfg.resamplefs    = 300;
    cfg.detrend       = 'no';
    noPain_planar     = ft_resampledata(cfg, noPain_planar);
    pain_planar       = ft_resampledata(cfg, pain_planar);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials= 'no';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 2:2:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = -0.8:0.03:1.2;
    cfgtfrl.channel   = {'MEG', '-A41'};
    TFpain_planar     = ft_freqanalysis(cfgtfrl, pain_planar);
    TFnoPain_planar   = ft_freqanalysis(cfgtfrl, noPain_planar);
    
    cfg = [];
    TFpain_planar_cmb = ft_combineplanar(cfg, TFpain_planar);
    TFnoPain_planar_cmb = ft_combineplanar(cfg, TFnoPain_planar);
    TFpain_planar_cmb.grad = TFpain_planar.grad;
    TFnoPain_planar_cmb.grad = TFnoPain_planar.grad;

    cfg=[];
    cfg.baseline     = [-0.3 0];
    cfg.baselinetype = 'absolute';
    TFpain_planar_cmb=ft_freqbaseline(cfg, TFpain_planar_cmb);
    TFnoPain_planar_cmb=ft_freqbaseline(cfg, TFnoPain_planar_cmb);
    save TF_planar TFpain_planar_cmb TFnoPain_planar_cmb
    clear all
end;

% time frequency analysis for fm planar data
for i = [1:7 9:20]
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    load splitconds
    grad        = ft_read_header('xc,hb,lf_c,rfhp0.1Hz');
    pain.grad   = grad.grad;
    noPain.grad = grad.grad;

    cfg                         = [];
    cfg.planarmethod            = 'sincos';
    cfg_neighb.method           = 'distance';
    cfg_neighb.layout           = '4D248.lay';
    cfg_neighb.neighbourdist    = 0.04; 
    cfg.neighbours  = ft_prepare_neighbours(cfg_neighb, pain);
  
    pain_planar     = ft_megplanar(cfg, pain);
    noPain_planar   = ft_megplanar(cfg, noPain);

    cfg               = [];
    cfg.resamplefs    = 300;
    cfg.detrend       = 'no';
    noPain_planar     = ft_resampledata(cfg, noPain_planar);
    pain_planar       = ft_resampledata(cfg, pain_planar);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials= 'no';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 2:2:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = -0.8:0.03:1.2;
    cfgtfrl.channel   = {'MEG', '-A41'};
    TFpain_planar     = ft_freqanalysis(cfgtfrl, pain_planar);
    TFnoPain_planar   = ft_freqanalysis(cfgtfrl, noPain_planar);
    
    cfg = [];
    TFpain_planar_cmb = ft_combineplanar(cfg, TFpain_planar);
    TFnoPain_planar_cmb = ft_combineplanar(cfg, TFnoPain_planar);
    TFpain_planar_cmb.grad = TFpain_planar.grad;
    TFnoPain_planar_cmb.grad = TFnoPain_planar.grad;

    cfg=[];
    cfg.baseline     = [-0.3 0];
    cfg.baselinetype = 'absolute';
    TFpain_planar_cmb=ft_freqbaseline(cfg, TFpain_planar_cmb);
    TFnoPain_planar_cmb=ft_freqbaseline(cfg, TFnoPain_planar_cmb);
    save TF_planar TFpain_planar_cmb TFnoPain_planar_cmb
    clear all
end;
%% ploting
cfg              = [];
cfg.baseline     = 'no'; 
%cfg.zlim         = [-2*10^(-27) 2*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
subplot(2,2,1)
ft_singleplotTFR(cfg, TFpain);
title('pain ex')
subplot(2,2,2)
ft_singleplotTFR(cfg, TFnoPain);
title('no pain ex')
subplot(2,2,3)
%cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFpain_planar_cmb);
title('pain grad')
subplot(2,2,4)
%cfg.zlim = [-2*10^(-27) 2*10^(-27)];
ft_singleplotTFR(cfg, TFnoPain_planar_cmb);
title('no pain grad')

cfg = [];                            
cfg.xlim = [0.2 0.5];
cfg.ylim = [10 12];
cfg.layout = '4D248.lay';
figure; 
subplot(1,2,1)
ft_topoplotER(cfg,TFpain)    
subplot(1,2,2)
ft_topoplotER(cfg,TFpain_planar_cmb)  

%% grand average planar gradiometer
% con
clear all
for i=1:14
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load TF_planar;
    eval(['TFpain_planar_con',num2str(i),'=TFpain_planar_cmb']);
    eval(['TFnoPain_planar_con',num2str(i),'=TFnoPain_planar_cmb']);
    clear TFpain_planar_cmb TFnoPain_planar_cmb
end;

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFLconPainPlanar   = ft_freqgrandaverage(cfg, TFpain_planar_con1, TFpain_planar_con2, TFpain_planar_con3, TFpain_planar_con4,...
    TFpain_planar_con5, TFpain_planar_con6, TFpain_planar_con7, TFpain_planar_con8, TFpain_planar_con9, TFpain_planar_con10,...
    TFpain_planar_con11, TFpain_planar_con12, TFpain_planar_con13, TFpain_planar_con14);
clear('TFpain_planar_con1', 'TFpain_planar_con2', 'TFpain_planar_con3', 'TFpain_planar_con4',...
    'TFpain_planar_con5', 'TFpain_planar_con6', 'TFpain_planar_con7', 'TFpain_planar_con8', 'TFpain_planar_con9', 'TFpain_planar_con10',...
    'TFpain_planar_con11', 'TFpain_planar_con12', 'TFpain_planar_con13', 'TFpain_planar_con14')
TFLconNoPainPlanar   = ft_freqgrandaverage(cfg, TFnoPain_planar_con1, TFnoPain_planar_con2, TFnoPain_planar_con3, TFnoPain_planar_con4,...
    TFnoPain_planar_con5, TFnoPain_planar_con6, TFnoPain_planar_con7, TFnoPain_planar_con8, TFnoPain_planar_con9, TFnoPain_planar_con10,...
    TFnoPain_planar_con11, TFnoPain_planar_con12, TFnoPain_planar_con13, TFnoPain_planar_con14);
clear('TFnoPain_planar_con1', 'TFnoPain_planar_con2', 'TFnoPain_planar_con3', 'TFnoPain_planar_con4',...
    'TFnoPain_planar_con5', 'TFnoPain_planar_con6', 'TFnoPain_planar_con7', 'TFnoPain_planar_con8', 'TFnoPain_planar_con9', 'TFnoPain_planar_con10',...
    'TFnoPain_planar_con11', 'TFnoPain_planar_con12', 'TFnoPain_planar_con13', 'TFnoPain_planar_con14')

% fm
for i=[1:7 9:20]
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    load TF_planar;
    eval(['TFpain_planar_fm',num2str(i),'=TFpain_planar_cmb']);
    eval(['TFnoPain_planar_fm',num2str(i),'=TFnoPain_planar_cmb']);
    clear TFpain_planar_cmb TFnoPain_planar_cmb
end;

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFLfmPainPlanar   = ft_freqgrandaverage(cfg, TFpain_planar_fm1, TFpain_planar_fm2, TFpain_planar_fm3, TFpain_planar_fm4,...
    TFpain_planar_fm5, TFpain_planar_fm6, TFpain_planar_fm7, TFpain_planar_fm9, TFpain_planar_fm10,...
    TFpain_planar_fm11, TFpain_planar_fm12, TFpain_planar_fm13, TFpain_planar_fm14, TFpain_planar_fm15, TFpain_planar_fm16,...
    TFpain_planar_fm17, TFpain_planar_fm18, TFpain_planar_fm19, TFpain_planar_fm20);
clear('TFpain_planar_fm1', 'TFpain_planar_fm2', 'TFpain_planar_fm3', 'TFpain_planar_fm4',...
    'TFpain_planar_fm5', 'TFpain_planar_fm6', 'TFpain_planar_fm7', 'TFpain_planar_fm9', 'TFpain_planar_fm10',...
    'TFpain_planar_fm11', 'TFpain_planar_fm12', 'TFpain_planar_fm13', 'TFpain_planar_fm14', 'TFpain_planar_fm15', 'TFpain_planar_fm16',...
    'TFpain_planar_fm17', 'TFpain_planar_fm18', 'TFpain_planar_fm19', 'TFpain_planar_fm20')
TFLfmNoPainPlanar   = ft_freqgrandaverage(cfg, TFnoPain_planar_fm1, TFnoPain_planar_fm2, TFnoPain_planar_fm3, TFnoPain_planar_fm4,...
    TFnoPain_planar_fm5, TFnoPain_planar_fm6, TFnoPain_planar_fm7, TFnoPain_planar_fm9, TFnoPain_planar_fm10,...
    TFnoPain_planar_fm11, TFnoPain_planar_fm12, TFnoPain_planar_fm13, TFnoPain_planar_fm14, TFnoPain_planar_fm15, TFnoPain_planar_fm16,...
    TFnoPain_planar_fm17, TFnoPain_planar_fm18, TFnoPain_planar_fm19, TFnoPain_planar_fm20);
clear('TFnoPain_planar_fm1', 'TFnoPain_planar_fm2', 'TFnoPain_planar_fm3', 'TFnoPain_planar_fm4',...
    'TFnoPain_planar_fm5', 'TFnoPain_planar_fm6', 'TFnoPain_planar_fm7', 'TFnoPain_planar_fm9', 'TFnoPain_planar_fm10',...
    'TFnoPain_planar_fm11', 'TFnoPain_planar_fm12', 'TFnoPain_planar_fm13', 'TFnoPain_planar_fm14', 'TFnoPain_planar_fm15', 'TFnoPain_planar_fm16',...
    'TFnoPain_planar_fm17', 'TFnoPain_planar_fm18', 'TFnoPain_planar_fm19', 'TFnoPain_planar_fm20')

cd /media/My_Passport/fibrodata
save TFL_planar_grandAvgs

conPainAvg = mean(mean(mean(TFLconPainPlanar.powspctrm(:,:,5,31:44))));
fmPainAvg = mean(mean(mean(TFLfmPainPlanar.powspctrm(:,:,5,31:44))));
conNoPainAvg = mean(mean(mean(TFLconNoPainPlanar.powspctrm(:,:,5,31:44))));
fmNoPainAvg = mean(mean(mean(TFLfmNoPainPlanar.powspctrm(:,:,5,31:44))));
conPainSD = std(mean(mean(TFLconPainPlanar.powspctrm(:,:,5,31:44))));
fmPainSD = std(mean(mean(TFLfmPainPlanar.powspctrm(:,:,5,31:44))));
conNoPainSD = std(mean(mean(TFLconNoPainPlanar.powspctrm(:,:,5,31:44))));
fmNoPainSD = std(mean(mean(TFLfmNoPainPlanar.powspctrm(:,:,5,31:44))));
figure
h=barwitherr([conPainSD,fmPainSD;conNoPainSD,fmNoPainSD],[conPainAvg,fmPainAvg;conNoPainAvg,fmNoPainAvg]);
set(h(1), 'facecolor', [1 1 1]);
set(h(2), 'facecolor', [0 0 0]);
title('10-11Hz 100-500ms')
ylabel('Power Change Relative to Base-Line');
set(gca, 'XTickLabel', {'Pain','No Pain'});
legend('control','fibros');
text(0.7,conPainAvg-0.1*10^(-27),num2str(conPainAvg))
text(1,fmPainAvg-0.1*10^(-27),num2str(fmPainAvg))
text(1.7,conNoPainAvg-0.1*10^(-27),num2str(conNoPainAvg))
text(2,fmNoPainAvg-0.1*10^(-27),num2str(fmNoPainAvg))


% differences
TFLconPainMinusNoPain = TFLconPainPlanar;
TFLconPainMinusNoPain.powspctrm = TFLconPainPlanar.powspctrm - TFLconNoPainPlanar.powspctrm;
TFLfmPainMinusNoPain = TFLfmPainPlanar;
TFLfmPainMinusNoPain.powspctrm = TFLfmPainPlanar.powspctrm - TFLfmNoPainPlanar.powspctrm;

% ploting
cfg              = [];
cfg.baseline     = 'no'; 
%cfg.zlim         = [-2*10^(-27) 2*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
subplot(2,3,1)
ft_singleplotTFR(cfg, TFLconPainPlanar);
title('Control pain 1-40Hz')
subplot(2,3,2)
ft_singleplotTFR(cfg, TFLconNoPainPlanar);
title('Control no-pain 1-40Hz')
subplot(2,3,3)
%cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLconPainMinusNoPain);
title('Control pain minus no-pain 1-40Hz')
subplot(2,3,4)
%cfg.zlim = [-2*10^(-27) 2*10^(-27)];
ft_singleplotTFR(cfg, TFLfmPainPlanar);
title('Fibromyalgia pain 1-40Hz')
subplot(2,3,5)
ft_singleplotTFR(cfg, TFLfmNoPainPlanar);
title('Fibromyalgia no-pain 1-40Hz')
subplot(2,3,6)
%cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLfmPainMinusNoPain);
title('Fibromyalgia pain minus no-pain 1-40Hz')

% topoplot
cfg = [];                            
cfg.xlim = [0.2 0.6];
cfg.ylim = [10 11];
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
cfg.colorbar = 'yes';
figure; 
subplot(2,2,1)
ft_topoplotER(cfg,TFLconPainPlanar)  ;  
title('con pain planar');
subplot(2,2,2)
ft_topoplotER(cfg,TFLconNoPainPlanar);
title('con no-pain planar');
subplot(2,2,3)
ft_topoplotER(cfg,TFLfmPainPlanar)  ;  
title('fm pain planar');
subplot(2,2,4)
ft_topoplotER(cfg,TFLfmNoPainPlanar);
title('fm no-pain planar');

% topoplot differences
cfg = [];                            
cfg.xlim = [0.1 0.5];
cfg.ylim = [10 11];
cfg.zlim = [-14*10^(-24) 6*10^(-24)];
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
cfg.colorbar = 'no';
figure;
subplot(1,2,1)
ft_topoplotER(cfg,TFLconPainMinusNoPainPlanar);
title('con pain minus no-pain planar');
subplot(1,2,2)
ft_topoplotER(cfg,TFLfmPainMinusNoPainPlanar);
title('fm pain minus no-pain planar');

cfg.zlim = [-12*10^(-28) 6*10^(-28)];
figure;
subplot(1,2,1)
ft_topoplotER(cfg,TFLconPainMinusNoPain);
title('con pain minus no-pain magneto');
subplot(1,2,2)
ft_topoplotER(cfg,TFLfmPainMinusNoPain);
title('fm pain minus no-pain magneto');

cfg              = [];
cfg.baseline     = 'no'; 
cfg.zlim         = [-10*10^(-24) 1.5*10^(-23)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
cfg.channel = {'A30', 'A31', 'A32', 'A51', 'A52', 'A53', 'A54', 'A55', 'A79', 'A80', 'A81', 'A82', 'A110', 'A111'};

figure;
subplot(2,3,1)
ft_singleplotTFR(cfg, TFLconPainPlanar);
title('Control pain 1-40Hz')
subplot(2,3,2)
ft_singleplotTFR(cfg, TFLconNoPainPlanar);
title('Control no-pain 1-40Hz')
subplot(2,3,4)
ft_singleplotTFR(cfg, TFLfmPainPlanar);
title('Fibromyalgia pain 1-40Hz')
subplot(2,3,5)
ft_singleplotTFR(cfg, TFLfmNoPainPlanar);
title('Fibromyalgia no-pain 1-40Hz')
subplot(2,3,3)
cfg.zlim = [-8*10^(-24) 6*10^(-24)];
ft_singleplotTFR(cfg, TFLconPainMinusNoPain);
title('Control pain minus no-pain 1-40Hz')
subplot(2,3,6)
ft_singleplotTFR(cfg, TFLfmPainMinusNoPain);
title('Fibromyalgia pain minus no-pain 1-40Hz')

% magnetometer
cfg              = [];
cfg.baseline     = 'no'; 
cfg.zlim         = [-5*10^(-27) 3*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';
% choose for right channs
cfg.channel = {'A80', 'A81', 'A82', 'A109', 'A110', 'A111', 'A112', 'A113', 'A141', 'A142', 'A143', 'A144', 'A145', 'A168', 'A169', 'A170', 'A190'};
% choose for left channs
cfg.channel = {'A26', 'A27', 'A46', 'A47', 'A48', 'A72', 'A73', 'A74', 'A102', 'A103', 'A104'}
% choose for right and left channs
cfg.channel = {'A26', 'A27', 'A46', 'A47', 'A48', 'A72', 'A73', 'A74', 'A102', 'A103', 'A104', 'A80', 'A81', 'A82', 'A109', 'A110', 'A111', 'A112', 'A113', 'A141', 'A142', 'A143', 'A144', 'A145', 'A168', 'A169', 'A170', 'A190'}

figure;
subplot(2,3,1)
ft_singleplotTFR(cfg, TFLconPain);
title('Control pain 1-40Hz')
subplot(2,3,2)
ft_singleplotTFR(cfg, TFLconNoPain);
title('Control no-pain 1-40Hz')
subplot(2,3,4)
ft_singleplotTFR(cfg, TFLfmPain);
title('Fibromyalgia pain 1-40Hz')
subplot(2,3,5)
ft_singleplotTFR(cfg, TFLfmNoPain);
title('Fibromyalgia no-pain 1-40Hz')
subplot(2,3,3)
cfg.zlim = [-2*10^(-27) 2*10^(-27)];
ft_singleplotTFR(cfg, TFLconPainMinusNoPain);
title('Control pain minus no-pain 1-40Hz')
subplot(2,3,6)
ft_singleplotTFR(cfg, TFLfmPainMinusNoPain);
title('Fibromyalgia pain minus no-pain 1-40Hz')

%% Log
for i = 1:14
    disp(i)
    eval(['load /media/My_Passport/fibrodata/con/con',num2str(i),'/TFtestLow']);
    eval(['TFpain',num2str(i),'=TFpain;']);
    eval(['TFnoPain',num2str(i),'=TFnoPain;']);
    clear TFpain TFnoPain
end;


for i=1:14
    eval(['conSub',num2str(i),'TFLpainDesc = ft_freqdescriptives([],TFpain',num2str(i),');']);
    eval(['conSub',num2str(i),'TFLnoPainDesc = ft_freqdescriptives([],TFnoPain',num2str(i),');']);
    eval(['clear TFpain',num2str(i),' TFnoPain',num2str(i)]);
end;

for i=1:14
    eval(['conSub',num2str(i),'TFLpainLog=conSub',num2str(i),'TFLpainDesc';]);
    eval(['conSub',num2str(i),'TFLpainLog.powspctrm=log(conSub',num2str(i),'TFLpainLog.powspctrm)';]);
    eval(['conSub',num2str(i),'TFLnoPainLog=conSub',num2str(i),'TFLnoPainDesc';]);
    eval(['conSub',num2str(i),'TFLnoPainLog.powspctrm=log(conSub',num2str(i),'TFLnoPainLog.powspctrm)';]);
end;

cfg=[];
cfg.baseline     = [-0.3 0];
cfg.baselinetype = 'absolute';
for i = 1:14
    eval(['conSub',num2str(i),'TFLpainLogBL=ft_freqbaseline(cfg,conSub',num2str(i),'TFLpainLog);']);
    eval(['conSub',num2str(i),'TFLnoPainLogBL=ft_freqbaseline(cfg,conSub',num2str(i),'TFLnoPainLog);']);
    eval(['clear conSub',num2str(i),'TFLnoPainDesc conSub',num2str(i),'TFLpainDesc']);
    disp(i);
end;

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFLconPainLog         = ft_freqgrandaverage(cfg, conSub1TFLpainLogBL, conSub2TFLpainLogBL, conSub3TFLpainLogBL,...
    conSub4TFLpainLogBL, conSub5TFLpainLogBL, conSub6TFLpainLogBL, conSub7TFLpainLogBL, conSub8TFLpainLogBL,...
    conSub9TFLpainLogBL, conSub10TFLpainLogBL, conSub11TFLpainLogBL, conSub12TFLpainLogBL, conSub13TFLpainLogBL,...
    conSub14TFLpainLogBL);
clear conSub1TFLpainLogBL conSub2TFLpainLogBL conSub3TFLpainLogBL conSub4TFLpainLogBL conSub5TFLpainLogBL...
    conSub6TFLpainLogBL conSub7TFLpainLogBL conSub8TFLpainLogBL conSub9TFLpainLogBL conSub10TFLpainLogBL...
    conSub11TFLpainLogBL conSub12TFLpainLogBL conSub13TFLpainLogBL conSub14TFLpainLogBL
clear conSub1TFLpainLog conSub2TFLpainLog conSub3TFLpainLog conSub4TFLpainLog conSub5TFLpainLog...
    conSub6TFLpainLog conSub7TFLpainLog conSub8TFLpainLog conSub9TFLpainLog conSub10TFLpainLog...
    conSub11TFLpainLog conSub12TFLpainLog conSub13TFLpainLog conSub14TFLpainLog

cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFLconNoPainLog         = ft_freqgrandaverage(cfg, conSub1TFLnoPainLogBL, conSub2TFLnoPainLogBL, conSub3TFLnoPainLogBL,...
    conSub4TFLnoPainLogBL, conSub5TFLnoPainLogBL, conSub6TFLnoPainLogBL, conSub7TFLnoPainLogBL, conSub8TFLnoPainLogBL,...
    conSub9TFLnoPainLogBL, conSub10TFLnoPainLogBL, conSub11TFLnoPainLogBL, conSub12TFLnoPainLogBL, conSub13TFLnoPainLogBL,...
    conSub14TFLnoPainLogBL);
clear conSub1TFLnoPainLogBL conSub2TFLnoPainLogBL conSub3TFLnoPainLogBL conSub4TFLnoPainLogBL conSub5TFLnoPainLogBL...
    conSub6TFLnoPainLogBL conSub7TFLnoPainLogBL conSub8TFLnoPainLogBL conSub9TFLnoPainLogBL conSub10TFLnoPainLogBL...
    conSub11TFLnoPainLogBL conSub12TFLnoPainLogBL conSub13TFLnoPainLogBL conSub14TFLnoPainLogBL
clear conSub1TFLnoPainLog conSub2TFLnoPainLog conSub3TFLnoPainLog conSub4TFLnoPainLog conSub5TFLnoPainLog...
    conSub6TFLnoPainLog conSub7TFLnoPainLog conSub8TFLnoPainLog conSub9TFLnoPainLog conSub10TFLnoPainLog...
    conSub11TFLnoPainLog conSub12TFLnoPainLog conSub13TFLnoPainLog conSub14TFLnoPainLog

%% analysis just for the comp channs
% choose for right channs
channel = {'A80', 'A81', 'A82', 'A109', 'A110', 'A111', 'A112', 'A113', 'A141', 'A142', 'A143', 'A144', 'A145', 'A168', 'A169', 'A170', 'A190'};
% choose for left channs
channel = {'A26', 'A27', 'A46', 'A47', 'A48', 'A72', 'A73', 'A74', 'A102', 'A103', 'A104'};
% choose for right and left channs
channel = {'A26', 'A27', 'A46', 'A47', 'A48', 'A72', 'A73', 'A74', 'A102', 'A103', 'A104', 'A80', 'A81', 'A82', 'A109', 'A110', 'A111', 'A112', 'A113', 'A141', 'A142', 'A143', 'A144', 'A145', 'A168', 'A169', 'A170', 'A190'};

[chansInx,x] = find(ismember(TFLconPain.label,channel));
data=zeros(66,4);
data(1:28,2)=1;
data(29:66,2)=2;
data([1:14,29:47],3)=1;
data([15:28,48:66],3)=2;
data([1:14,15:28],4)=[1:14,1:14];
data([29:47,48:66],4)=[15:33,15:33];
data(1:14,1)=mean(mean(TFLconPain.powspctrm(:,chansInx,5,31:44),4),2);
data(15:28,1)=mean(mean(TFLconNoPain.powspctrm(:,chansInx,5,31:44),4),2);
data(29:47,1)=mean(mean(TFLfmPain.powspctrm(:,chansInx,5,31:44),4),2);
data(48:66,1)=mean(mean(TFLfmNoPain.powspctrm(:,chansInx,5,31:44),4),2);

[SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(data);
% ttest for con
[H,P,CI] = ttest(data([1:14],1),data([15:28],1))

% all channs
data(1:14,1)=mean(mean(TFLconPain.powspctrm(:,:,5,31:44),4),2);
data(15:28,1)=mean(mean(TFLconNoPain.powspctrm(:,:,5,31:44),4),2);
data(29:47,1)=mean(mean(TFLfmPain.powspctrm(:,:,5,31:44),4),2);
data(48:66,1)=mean(mean(TFLfmNoPain.powspctrm(:,:,5,31:44),4),2);

% min point
[chansInx,x] = find(ismember(TFLconPain.label,channel));
data=zeros(66,4);
data(1:28,2)=1;
data(29:66,2)=2;
data([1:14,29:47],3)=1;
data([15:28,48:66],3)=2;
data([1:14,15:28],4)=[1:14,1:14];
data([29:47,48:66],4)=[15:33,15:33];
data(1:14,1)=min(min(TFLconPain.powspctrm(:,chansInx,5,31:44),[],4),[],2);
data(15:28,1)=min(min(TFLconNoPain.powspctrm(:,chansInx,5,31:44),[],4),[],2);
data(29:47,1)=min(min(TFLfmPain.powspctrm(:,chansInx,5,31:44),[],4),[],2);
data(48:66,1)=min(min(TFLfmNoPain.powspctrm(:,chansInx,5,31:44),[],4),[],2);

[SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(data);

% min point all channs
data=zeros(66,4);
data(1:28,2)=1;
data(29:66,2)=2;
data([1:14,29:47],3)=1;
data([15:28,48:66],3)=2;
data([1:14,15:28],4)=[1:14,1:14];
data([29:47,48:66],4)=[15:33,15:33];
data(1:14,1)=min(min(min(TFLconPain.powspctrm(:,:,5,31:44),[],4),[],3),[],2);
data(15:28,1)=min(min(min(TFLconNoPain.powspctrm(:,:,5,31:44),[],4),[],3),[],2);
data(29:47,1)=min(min(min(TFLfmPain.powspctrm(:,:,5,31:44),[],4),[],3),[],2);
data(48:66,1)=min(min(min(TFLfmNoPain.powspctrm(:,:,5,31:44),[],4),[],3),[],2);

[SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(data);

%% virtual sensors for 10-11Hz frequency band (using 8-12 wts because it couldn't do 10-11)
clear
load /media/My_Passport/fibrodata/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[10 11];
cfg.channel = {'MEG'};

% for con
for i=1:14
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    % noise estimation
    load ERFaverages
    eval(['conSub',num2str(i),'all_10_11_Hz=ft_preprocessing(cfg,conSub',num2str(i),'all);']);
    eval(['conSub',num2str(i),'noPain_10_11_Hz=ft_preprocessing(cfg,conSub',num2str(i),'noPain);']);
    eval(['conSub',num2str(i),'pain_10_11_Hz=ft_preprocessing(cfg,conSub',num2str(i),'pain);']);
    load 'SAM/all4cov,8-12Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    eval(['vsPain_10_11_Hz=ActWgts*conSub',num2str(i),'pain_10_11_Hz.avg(:,nearest(time,.100):nearest(time,.500));']);
    eval(['vsPainBL_10_11_Hz=ActWgts*conSub',num2str(i),'pain_10_11_Hz.avg(:,nearest(time,-.300):nearest(time,0));']);
    vsPain_10_11_HzMS=mean(vsPain_10_11_Hz.*vsPain_10_11_Hz,2)./ns;
    vsPainBL_10_11_HzMS=mean(vsPainBL_10_11_Hz.*vsPainBL_10_11_Hz,2)./ns;
    vsPain_10_11_HzMS=vsPain_10_11_HzMS-vsPainBL_10_11_HzMS;
    vsPain_10_11_HzMS=vsPain_10_11_HzMS.*10^28; % 10^28 is rescaling the data so it won't be so small
    vsPain_10_11_HzMS(isnan(vsPain_10_11_HzMS))=0;
    
    % for no-pain
    eval(['vsNoPain_10_11_Hz=ActWgts*conSub',num2str(i),'noPain_10_11_Hz.avg(:,nearest(time,.100):nearest(time,.500));']);
    eval(['vsNoPainBL_10_11_Hz=ActWgts*conSub',num2str(i),'noPain_10_11_Hz.avg(:,nearest(time,-.300):nearest(time,0));']);
    vsNoPain_10_11_HzMS=mean(vsNoPain_10_11_Hz.*vsNoPain_10_11_Hz,2)./ns;
    vsNoPainBL_10_11_HzMS=mean(vsNoPainBL_10_11_Hz.*vsNoPainBL_10_11_Hz,2)./ns;
    vsNoPain_10_11_HzMS=vsNoPain_10_11_HzMS-vsNoPainBL_10_11_HzMS;
    vsNoPain_10_11_HzMS=vsNoPain_10_11_HzMS.*10^28; % 10^28 is rescaling the data so it won't be so small
    vsNoPain_10_11_HzMS(isnan(vsNoPain_10_11_HzMS))=0;

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_10_11_HzMS';
    VS2Brik(cfg1,vsPain_10_11_HzMS);
    cfg1.prefix='noPain_10_11_HzMS';
    VS2Brik(cfg1,vsNoPain_10_11_HzMS);        
    
    eval(['clear vsNoPainBL_10_11_HzMS vsNoPainBL_10_11_Hz vsPainBL_10_11_HzMS vsPainBL_10_11_Hz ActWgts cfg1 conSub',num2str(i),'all conSub',num2str(i),'all_10_11_Hz conSub',num2str(i),'noPain conSub',num2str(i),'noPain_10_11_Hz conSub',num2str(i),'pain conSub',num2str(i),'pain_10_11_Hz ns vsNoPain_10_11_Hz vsNoPain_10_11_HzMS vsPain_10_11_Hz vsPain_10_11_HzMS'])

end

% for fm
for i=[1:8,9:20]
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    % noise estimation
    load ERFaverages
    eval(['fmSub',num2str(i),'all_10_11_Hz=ft_preprocessing(cfg,fmSub',num2str(i),'all);']);
    eval(['fmnSub',num2str(i),'noPain_10_11_Hz=ft_preprocessing(cfg,fmSub',num2str(i),'noPain);']);
    eval(['fmSub',num2str(i),'pain_10_11_Hz=ft_preprocessing(cfg,fmSub',num2str(i),'pain);']);
    load 'SAM/all4cov,8-12Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    eval(['vsPain_10_11_Hz=ActWgts*fmSub',num2str(i),'pain_10_11_Hz.avg(:,nearest(time,.100):nearest(time,.500));']);
    eval(['vsPainBL_10_11_Hz=ActWgts*fmSub',num2str(i),'pain_10_11_Hz.avg(:,nearest(time,-.300):nearest(time,0));']);
    vsPain_10_11_HzMS=mean(vsPain_10_11_Hz.*vsPain_10_11_Hz,2)./ns;
    vsPainBL_10_11_HzMS=mean(vsPainBL_10_11_Hz.*vsPainBL_10_11_Hz,2)./ns;
    vsPain_10_11_HzMS=vsPain_10_11_HzMS-vsPainBL_10_11_HzMS;
    vsPain_10_11_HzMS=vsPain_10_11_HzMS.*10^28; % 10^28 is rescaling the data so it won't be so small
    vsPain_10_11_HzMS(isnan(vsPain_10_11_HzMS))=0;
    
    % for no-pain
    eval(['vsNoPain_10_11_Hz=ActWgts*fmSub',num2str(i),'noPain_10_11_Hz.avg(:,nearest(time,.100):nearest(time,.500));']);
    eval(['vsNoPainBL_10_11_Hz=ActWgts*fmSub',num2str(i),'noPain_10_11_Hz.avg(:,nearest(time,-.300):nearest(time,0));']);
    vsNoPain_10_11_HzMS=mean(vsNoPain_10_11_Hz.*vsNoPain_10_11_Hz,2)./ns;
    vsNoPainBL_10_11_HzMS=mean(vsNoPainBL_10_11_Hz.*vsNoPainBL_10_11_Hz,2)./ns;
    vsNoPain_10_11_HzMS=vsNoPain_10_11_HzMS-vsNoPainBL_10_11_HzMS;
    vsNoPain_10_11_HzMS=vsNoPain_10_11_HzMS.*10^28; % 10^28 is rescaling the data so it won't be so small
    vsNoPain_10_11_HzMS(isnan(vsNoPain_10_11_HzMS))=0;

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_10_11_HzMS';
    VS2Brik(cfg1,vsPain_10_11_HzMS);
    cfg1.prefix='noPain_10_11_HzMS';
    VS2Brik(cfg1,vsNoPain_10_11_HzMS);        
    
    eval(['clear vsNoPainBL_10_11_HzMS vsNoPainBL_10_11_Hz vsPainBL_10_11_HzMS vsPainBL_10_11_Hz ActWgts cfg1 fmSub',num2str(i),'all fmSub',num2str(i),'all_10_11_Hz fmSub',num2str(i),'noPain fmSub',num2str(i),'noPain_10_11_Hz fmSub',num2str(i),'pain fmSub',num2str(i),'pain_10_11_Hz ns vsNoPain_10_11_Hz vsNoPain_10_11_HzMS vsPain_10_11_Hz vsPain_10_11_HzMS'])

end

% 1. Run 3dMVM_10_11_Hz.txt
% 2. Get ridd of the voxels outside the cortex
cd /media/My_Passport/fibrodata
masktlrc('3dMVM_10_11_Hz+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dMVM_withContrs_10_11_Hz+tlrc','MASKctx+tlrc','_ctx');
%% 3. extract the maximum values in each cluster for the group, pain and interaction between the two
cd /media/My_Passport/fibrodata
clear all
!3dExtrema -prefix Clust20_group_ext -mask_file Clust20_group_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_10_11_Hz_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_pain_ext -mask_file Clust20_painNoPain_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_10_11_Hz_ctx+tlrc'[2]'
!3dExtrema -prefix Clust20_int_ext -mask_file Clust20_int_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_10_11_Hz_ctx+tlrc'[3]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_group_ext+tlrc > Clust20_xyzGroup.txt
!3dmaskdump -xyz -nozero -noijk Clust20_pain_ext+tlrc > Clust20_xyzpain.txt
!3dmaskdump -xyz -nozero -noijk Clust20_int_ext+tlrc > Clust20_xyzInt.txt

% 5. creating a matrix of all maximum values for all subs for all condition
% according to the xyzInt file created
%% Group
% each subject power for each extreme voxel in the group effect
con = 1:14;
fm = [1:7 9:20];

voxGrp = importdata('Clust20_xyzGroup.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_10_11_Hz/pain_10_11_HzMS+tlrc > Clust20_painVoxValuesGrp.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_10_11_Hz/noPain_10_11_HzMS+tlrc > Clust20_noPainVoxValuesGrp.txt']);

        val = importdata('Clust20_painVoxValuesGrp.txt'); Clust20_conPainVoxValuesGrp(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesGrp.txt'); Clust20_conNoPainVoxValuesGrp(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a=1;
for subs = fm
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_10_11_Hz/pain_10_11_HzMS+tlrc > Clust20_painVoxValuesGrp.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_10_11_Hz/noPain_10_11_HzMS+tlrc > Clust20_noPainVoxValuesGrp.txt']);

        val = importdata('Clust20_painVoxValuesGrp.txt'); Clust20_fmPainVoxValuesGrp(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesGrp.txt'); Clust20_fmNoPainVoxValuesGrp(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_conVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_conPainVoxValuesGrp(',num2str(i),',:);Clust20_conNoPainVoxValuesGrp(',num2str(i),',:)],1);']);
end
for i=1:length(fm)
    eval(['Clust20_fmVoxelsGrp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_fmPainVoxValuesGrp(',num2str(i),',:);Clust20_fmNoPainVoxValuesGrp(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrp,1)
    eval(['!whereami ',num2str(voxGrp(i,1)),' ',num2str(voxGrp(i,2)),' ',num2str(voxGrp(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrp{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrp{i,1}=wmiGrp{i,1}(2:end);
end

save Clust20_10_11_Hz_Grp voxGrp wmiGrp Clust20_conVoxelsGrp Clust20_fmVoxelsGrp

for i=1:size(voxGrp,1)
    eval(['mean_voxel_',num2str(i),'(1,1) = mean(Clust20_conVoxelsGrp(:,',num2str(i),'));']);
    eval(['mean_voxel_',num2str(i),'(2,1) = mean(Clust20_fmVoxelsGrp(:,',num2str(i),'));']);
    eval(['sd_voxel_',num2str(i),'(1,1) = std(Clust20_conVoxelsGrp(:,',num2str(i),'))./sqrt(14);']);
    eval(['sd_voxel_',num2str(i),'(2,1) = std(Clust20_fmVoxelsGrp(:,',num2str(i),'))./sqrt(19);']);
end;

% plots for the group
for i=1:size(voxGrp,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('voxel %s - %s',num2str(i),wmiGrp{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'control','fibro'});
end

%% pain
clear all
con = [1:14];
fm = [1:7 9:20];

voxPain = importdata('Clust20_xyzpain.txt');

% each subject power for each extreme voxel in the pain effect
val=[];
a = 1;
for subs = con
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_10_11_Hz/pain_10_11_HzMS+tlrc > Clust20_painVoxValuesPain.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_10_11_Hz/noPain_10_11_HzMS+tlrc > Clust20_noPainVoxValuesPain.txt']);

        val = importdata('Clust20_painVoxValuesPain.txt'); Clust20_conPainVoxelsPain(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesPain.txt'); Clust20_conNoPainVoxelsPain(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxPain,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_10_11_Hz/pain_10_11_HzMS+tlrc > Clust20_painVoxValuesPain.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPain(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_10_11_Hz/noPain_10_11_HzMS+tlrc > Clust20_noPainVoxValuesPain.txt']);

        val = importdata('Clust20_painVoxValuesPain.txt'); Clust20_fmPainVoxelsPain(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesPain.txt'); Clust20_fmNoPainVoxelsPain(a,i) = val(4); val=[];
    end
    a = a+1;
end

Clust20_painVoxelsPain = [Clust20_fmPainVoxelsPain;Clust20_conPainVoxelsPain];
Clust20_noPainVoxelsPain = [Clust20_fmNoPainVoxelsPain;Clust20_conNoPainVoxelsPain];

% list of locations of the extreme voxels in the pain effect
for i = 1:size(voxPain,1)
    eval(['!whereami ',num2str(voxPain(i,1)),' ',num2str(voxPain(i,2)),' ',num2str(voxPain(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPain{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPain{i,1}=wmiPain{i,1}(2:end);
end

save Clust20_10_11_Hz_Pain voxPain wmiPain Clust20_painVoxelsPain Clust20_noPainVoxelsPain

for i=1:size(voxPain,1)
    eval(['mean_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_painVoxelsPain(:,',num2str(i),')),mean(Clust20_noPainVoxelsPain(:,',num2str(i),'))];']);
    eval(['sd_voxel_',num2str(i),'(1,1:2) = [std(Clust20_painVoxelsPain(:,',num2str(i),'))./sqrt(33),std(Clust20_noPainVoxelsPain(:,',num2str(i),'))./sqrt(33)];']);
end;

% plots for the pain
for i=1:size(voxPain,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('voxel %s - %s',num2str(i),wmiPain{i});
    title(ti)
    xlim([0 3]);
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pain','No Pain'});
end

%% Interaction
clear all
con = [1:14];
fm = [1:7 9:20];

voxInt = importdata('Clust20_xyzInt.txt');

% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_10_11_Hz/pain_10_11_HzMS+tlrc > Clust20_painVoxValuesInt.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_10_11_Hz/noPain_10_11_HzMS+tlrc > Clust20_noPainVoxValuesInt.txt']);

        val = importdata('Clust20_painVoxValuesInt.txt'); Clust20_conPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesInt.txt'); Clust20_conNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_10_11_Hz/pain_10_11_HzMS+tlrc > Clust20_painVoxValuesInt.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_10_11_Hz/noPain_10_11_HzMS+tlrc > Clust20_noPainVoxValuesInt.txt']);

        val = importdata('Clust20_painVoxValuesInt.txt'); Clust20_fmPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesInt.txt'); Clust20_fmNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_10_11_Hz_Int voxInt wmiInt Clust20_fmPainVoxelsInt Clust20_fmNoPainVoxelsInt...
    Clust20_conPainVoxelsInt Clust20_conNoPainVoxelsInt

for i=1:size(voxInt,1)
    eval(['mean_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_conPainVoxelsInt(:,',num2str(i),')),mean(Clust20_conNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['mean_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_fmPainVoxelsInt(:,',num2str(i),')),mean(Clust20_fmNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['sd_voxel_',num2str(i),'(1,1:2) = [std(Clust20_conPainVoxelsInt(:,',num2str(i),'))./sqrt(14),std(Clust20_conNoPainVoxelsInt(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_voxel_',num2str(i),'(2,1:2) = [std(Clust20_fmPainVoxelsInt(:,',num2str(i),'))./sqrt(19),std(Clust20_fmNoPainVoxelsInt(:,',num2str(i),'))./sqrt(19)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),',mean_voxel_',num2str(i),');']);
    ti = sprintf('voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Control','Fibro'});
    legend('Pain','No Pain');
end

clear all
load Clust20_10_11_Hz_Grp
load Clust20_10_11_Hz_Pain
load Clust20_10_11_Hz_Int
save Clust20_10_11_Hz_ext

%%% -------------------------------------------------------------------------------------------------------
%%% -------------------------------------------------------------------------------------------------------
%% virtual sensors for 10-11Hz frequency band trial by trial (using 8-12 wts because it couldn't do 10-11)
clear
load /media/My_Passport/fibrodata/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[10 11];
cfg.channel = {'MEG'};

% for con
for i=1:14
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    % noise estimation
    load splitconds
    noPain_10_11_Hz=ft_preprocessing(cfg,noPain);
    pain_10_11_Hz=ft_preprocessing(cfg,pain);
    load 'SAM/all4cov,8-12Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    vsPainAlpha=zeros(63455,1);
    for j=1:length(pain_10_11_Hz.trial)
        vsPain_10_11_Hz=ActWgts*pain_10_11_Hz.trial{1,j}(:,nearest(time,.100):nearest(time,.500));
        vsPainBL_10_11_Hz=ActWgts*pain_10_11_Hz.trial{1,j}(:,nearest(time,-.300):nearest(time,0));
        vsPain_10_11_HzMS=mean(vsPain_10_11_Hz.*vsPain_10_11_Hz,2)./ns;
        vsPainBL_10_11_HzMS=mean(vsPainBL_10_11_Hz.*vsPainBL_10_11_Hz,2)./ns;
        vsPain_10_11_HzMS=vsPain_10_11_HzMS-vsPainBL_10_11_HzMS;
        vsPain_10_11_HzMS=vsPain_10_11_HzMS.*10^28; 
        vsPain_10_11_HzMS(isnan(vsPain_10_11_HzMS))=0;
        vsPainAlpha=vsPainAlpha+vsPain_10_11_HzMS;
        disp(j);
    end
    vsPain_10_11_HzMS=vsPainAlpha./length(pain_10_11_Hz.trial);
    
    % for no-pain
    vsNoPainAlpha=zeros(63455,1);
    for j=1:length(noPain_10_11_Hz.trial)
        vsNoPain_10_11_Hz=ActWgts*noPain_10_11_Hz.trial{1,j}(:,nearest(time,.100):nearest(time,.500));
        vsNoPainBL_10_11_Hz=ActWgts*noPain_10_11_Hz.trial{1,j}(:,nearest(time,-.300):nearest(time,0));
        vsNoPain_10_11_HzMS=mean(vsNoPain_10_11_Hz.*vsNoPain_10_11_Hz,2)./ns;
        vsNoPainBL_10_11_HzMS=mean(vsNoPainBL_10_11_Hz.*vsNoPainBL_10_11_Hz,2)./ns;
        vsNoPain_10_11_HzMS=vsNoPain_10_11_HzMS-vsNoPainBL_10_11_HzMS;
        vsNoPain_10_11_HzMS=vsNoPain_10_11_HzMS.*10^28; 
        vsNoPain_10_11_HzMS(isnan(vsNoPain_10_11_HzMS))=0;
        vsNoPainAlpha=vsNoPainAlpha+vsNoPain_10_11_HzMS;
        disp(j);
    end
    vsNoPain_10_11_HzMS=vsNoPainAlpha./length(noPain_10_11_Hz.trial);

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_alpha_HzMS';
    VS2Brik(cfg1,vsPain_10_11_HzMS);
    cfg1.prefix='noPain_alpha_HzMS';
    VS2Brik(cfg1,vsNoPain_10_11_HzMS);        
    
    eval(['clear vsNoPainBL_10_11_HzMS vsNoPainBL_10_11_Hz vsPainBL_10_11_HzMS vsPainBL_10_11_Hz ActWgts cfg1 conSub',num2str(i),'all conSub',num2str(i),'all_10_11_Hz conSub',num2str(i),'noPain conSub',num2str(i),'noPain_10_11_Hz conSub',num2str(i),'pain conSub',num2str(i),'pain_10_11_Hz ns vsNoPain_10_11_Hz vsNoPain_10_11_HzMS vsPain_10_11_Hz vsPain_10_11_HzMS'])

end

% for fm
for i=[1:7,9:20]
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    % noise estimation
    load splitconds
    noPain_10_11_Hz=ft_preprocessing(cfg,noPain);
    pain_10_11_Hz=ft_preprocessing(cfg,pain);
    load 'SAM/all4cov,8-12Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    vsPainAlpha=zeros(63455,1);
    for j=1:length(pain_10_11_Hz.trial)
        vsPain_10_11_Hz=ActWgts*pain_10_11_Hz.trial{1,j}(:,nearest(time,.100):nearest(time,.500));
        vsPainBL_10_11_Hz=ActWgts*pain_10_11_Hz.trial{1,j}(:,nearest(time,-.300):nearest(time,0));
        vsPain_10_11_HzMS=mean(vsPain_10_11_Hz.*vsPain_10_11_Hz,2)./ns;
        vsPainBL_10_11_HzMS=mean(vsPainBL_10_11_Hz.*vsPainBL_10_11_Hz,2)./ns;
        vsPain_10_11_HzMS=vsPain_10_11_HzMS-vsPainBL_10_11_HzMS;
        vsPain_10_11_HzMS=vsPain_10_11_HzMS.*10^28; 
        vsPain_10_11_HzMS(isnan(vsPain_10_11_HzMS))=0;
        vsPainAlpha=vsPainAlpha+vsPain_10_11_HzMS;
        disp(j);
    end
    vsPain_10_11_HzMS=vsPainAlpha./length(pain_10_11_Hz.trial);
    
    % for no-pain
    vsNoPainAlpha=zeros(63455,1);
    for j=1:length(noPain_10_11_Hz.trial)
        vsNoPain_10_11_Hz=ActWgts*noPain_10_11_Hz.trial{1,j}(:,nearest(time,.100):nearest(time,.500));
        vsNoPainBL_10_11_Hz=ActWgts*noPain_10_11_Hz.trial{1,j}(:,nearest(time,-.300):nearest(time,0));
        vsNoPain_10_11_HzMS=mean(vsNoPain_10_11_Hz.*vsNoPain_10_11_Hz,2)./ns;
        vsNoPainBL_10_11_HzMS=mean(vsNoPainBL_10_11_Hz.*vsNoPainBL_10_11_Hz,2)./ns;
        vsNoPain_10_11_HzMS=vsNoPain_10_11_HzMS-vsNoPainBL_10_11_HzMS;
        vsNoPain_10_11_HzMS=vsNoPain_10_11_HzMS.*10^28; 
        vsNoPain_10_11_HzMS(isnan(vsNoPain_10_11_HzMS))=0;
        vsNoPainAlpha=vsNoPainAlpha+vsNoPain_10_11_HzMS;
        disp(j);
    end
    vsNoPain_10_11_HzMS=vsNoPainAlpha./length(noPain_10_11_Hz.trial);

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_alpha_HzMS';
    VS2Brik(cfg1,vsPain_10_11_HzMS);
    cfg1.prefix='noPain_alpha_HzMS';
    VS2Brik(cfg1,vsNoPain_10_11_HzMS);        
    
    eval(['clear vsNoPainBL_10_11_HzMS vsNoPainBL_10_11_Hz vsPainBL_10_11_HzMS vsPainBL_10_11_Hz ActWgts cfg1 conSub',num2str(i),'all conSub',num2str(i),'all_10_11_Hz conSub',num2str(i),'noPain conSub',num2str(i),'noPain_10_11_Hz conSub',num2str(i),'pain conSub',num2str(i),'pain_10_11_Hz ns vsNoPain_10_11_Hz vsNoPain_10_11_HzMS vsPain_10_11_Hz vsPain_10_11_HzMS'])

end

%% moving files to tlrc and moving them into a folder
% now open a terminal and type:
% for i in {1..14}
% do
%     cd /media/My_Passport/fibrodata/con/con$i
%     @auto_tlrc -apar brain+tlrc -input pain_alpha_HzMS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPain_alpha_HzMS+orig -dxyz 5
%     cp *HzMS+tlrc* SAM_10_11_Hz
% done
% 
% for i in 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 19 20
% do
%     cd /media/My_Passport/fibrodata/fm/fm$i
%     @auto_tlrc -apar brain+tlrc -input pain_alpha_HzMS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPain_alpha_HzMS+orig -dxyz 5
%     cp *HzMS+tlrc* SAM_10_11_Hz
% done

cd /media/My_Passport/fibrodata
masktlrc('3dMVM_withContrs_alpha_Hz+tlrc','MASKctx+tlrc','_ctx');

%% 3. extract the maximum values in each cluster for the group, pain and interaction between the two
cd /media/My_Passport/fibrodata
clear all
!3dExtrema -prefix Clust20_intalpha_ext -mask_file Clust20_IntAlpha_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_10_11_Hz_ctx+tlrc'[3]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_intalpha_ext+tlrc > Clust20_xyzIntAlpha.txt

% 5. creating a matrix of all maximum values for all subs for all condition
% according to the xyzInt file created
%% Group
% each subject power for each extreme voxel in the group effect
con = 1:14;
fm = [1:7 9:20];

%% Interaction
clear all
con = [1:14];
fm = [1:7 9:20];

voxInt = importdata('Clust20_xyzIntAlpha.txt');
% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_10_11_Hz/pain_alpha_HzMS+tlrc > Clust20_painVoxValuesIntAlpha.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_10_11_Hz/noPain_alpha_HzMS+tlrc > Clust20_noPainVoxValuesIntAlpha.txt']);

        val = importdata('Clust20_painVoxValuesIntAlpha.txt'); Clust20_conPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntAlpha.txt'); Clust20_conNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_10_11_Hz/pain_alpha_HzMS+tlrc > Clust20_painVoxValuesIntAlpha.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_10_11_Hz/noPain_alpha_HzMS+tlrc > Clust20_noPainVoxValuesIntAlpha.txt']);

        val = importdata('Clust20_painVoxValuesIntAlpha.txt'); Clust20_fmPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntAlpha.txt'); Clust20_fmNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_alpha_Hz_Int voxInt wmiInt Clust20_fmPainVoxelsInt Clust20_fmNoPainVoxelsInt...
    Clust20_conPainVoxelsInt Clust20_conNoPainVoxelsInt

for i=1:size(voxInt,1)
    eval(['mean_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_conPainVoxelsInt(:,',num2str(i),')),mean(Clust20_conNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['mean_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_fmPainVoxelsInt(:,',num2str(i),')),mean(Clust20_fmNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['sd_voxel_',num2str(i),'(1,1:2) = [std(Clust20_conPainVoxelsInt(:,',num2str(i),'))./sqrt(14),std(Clust20_conNoPainVoxelsInt(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_voxel_',num2str(i),'(2,1:2) = [std(Clust20_fmPainVoxelsInt(:,',num2str(i),'))./sqrt(19),std(Clust20_fmNoPainVoxelsInt(:,',num2str(i),'))./sqrt(19)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),',mean_voxel_',num2str(i),');']);
    ti = sprintf('voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Control','Fibro'});
    legend('Pain','No Pain');
end

%% present in suma (copy the brick files into surface template folder)
afni -niml &
suma -niml -spec tempTest_both.spec -sv temp+tlrc

%% ------------- 30.9.14 ------------------
%% virtual sensors for 8-12Hz frequency band trial by trial (using 8-12 wts)
clear
load /media/My_Passport/fibrodata/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[8 12];
cfg.channel = {'MEG'};

% for con
for i=2:14
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    % noise estimation
    load splitconds
    noPain_8_12_Hz=ft_preprocessing(cfg,noPain);
    pain_8_12_Hz=ft_preprocessing(cfg,pain);
    load 'SAM/all4cov,8-12Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    vsPainAlpha=zeros(63455,1);
    for j=1:length(pain_8_12_Hz.trial)
        vsPain_8_12_Hz=ActWgts*pain_8_12_Hz.trial{1,j}(:,nearest(time,.100):nearest(time,.500));
        vsPainBL_8_12_Hz=ActWgts*pain_8_12_Hz.trial{1,j}(:,nearest(time,-.300):nearest(time,0));
        vsPain_8_12_HzMS=mean(vsPain_8_12_Hz.*vsPain_8_12_Hz,2)./ns;
        vsPainBL_8_12_HzMS=mean(vsPainBL_8_12_Hz.*vsPainBL_8_12_Hz,2)./ns;
        vsPain_8_12_HzMS=vsPain_8_12_HzMS-vsPainBL_8_12_HzMS;
        vsPain_8_12_HzMS=vsPain_8_12_HzMS.*10^28; 
        vsPain_8_12_HzMS(isnan(vsPain_8_12_HzMS))=0;
        vsPainAlpha=vsPainAlpha+vsPain_8_12_HzMS;
        disp(j);
    end
    vsPain_8_12_HzMS=vsPainAlpha./length(pain_8_12_Hz.trial);
    
    % for no-pain
    vsNoPainAlpha=zeros(63455,1);
    for j=1:length(noPain_8_12_Hz.trial)
        vsNoPain_8_12_Hz=ActWgts*noPain_8_12_Hz.trial{1,j}(:,nearest(time,.100):nearest(time,.500));
        vsNoPainBL_8_12_Hz=ActWgts*noPain_8_12_Hz.trial{1,j}(:,nearest(time,-.300):nearest(time,0));
        vsNoPain_8_12_HzMS=mean(vsNoPain_8_12_Hz.*vsNoPain_8_12_Hz,2)./ns;
        vsNoPainBL_8_12_HzMS=mean(vsNoPainBL_8_12_Hz.*vsNoPainBL_8_12_Hz,2)./ns;
        vsNoPain_8_12_HzMS=vsNoPain_8_12_HzMS-vsNoPainBL_8_12_HzMS;
        vsNoPain_8_12_HzMS=vsNoPain_8_12_HzMS.*10^28; 
        vsNoPain_8_12_HzMS(isnan(vsNoPain_8_12_HzMS))=0;
        vsNoPainAlpha=vsNoPainAlpha+vsNoPain_8_12_HzMS;
        disp(j);
    end
    vsNoPain_8_12_HzMS=vsNoPainAlpha./length(noPain_8_12_Hz.trial);

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_alpha_HzMS';
    VS2Brik(cfg1,vsPain_8_12_HzMS);
    cfg1.prefix='noPain_alpha_HzMS';
    VS2Brik(cfg1,vsNoPain_8_12_HzMS);        
    
    eval(['clear vsNoPainBL_8_12_HzMS vsNoPainBL_8_12_Hz vsPainBL_8_12_HzMS vsPainBL_8_12_Hz ActWgts cfg1 conSub',num2str(i),'all conSub',num2str(i),'all_8_12_Hz conSub',num2str(i),'noPain conSub',num2str(i),'noPain_8_12_Hz conSub',num2str(i),'pain conSub',num2str(i),'pain_8_12_Hz ns vsNoPain_8_12_Hz vsNoPain_8_12_HzMS vsPain_8_12_Hz vsPain_8_12_HzMS'])

end

% for fm
clear
load /media/My_Passport/fibrodata/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[8 12];
cfg.channel = {'MEG'};

for i=[1:7,9:20]
    disp(i);
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    % noise estimation
    load splitconds
    noPain_8_12_Hz=ft_preprocessing(cfg,noPain);
    pain_8_12_Hz=ft_preprocessing(cfg,pain);
    load 'SAM/all4cov,8-12Hz,Alla'
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction
    
    % for pain
    vsPainAlpha=zeros(63455,1);
    for j=1:length(pain_8_12_Hz.trial)
        vsPain_8_12_Hz=ActWgts*pain_8_12_Hz.trial{1,j}(:,nearest(time,.100):nearest(time,.500));
        vsPainBL_8_12_Hz=ActWgts*pain_8_12_Hz.trial{1,j}(:,nearest(time,-.300):nearest(time,0));
        vsPain_8_12_HzMS=mean(vsPain_8_12_Hz.*vsPain_8_12_Hz,2)./ns;
        vsPainBL_8_12_HzMS=mean(vsPainBL_8_12_Hz.*vsPainBL_8_12_Hz,2)./ns;
        vsPain_8_12_HzMS=vsPain_8_12_HzMS-vsPainBL_8_12_HzMS;
        vsPain_8_12_HzMS=vsPain_8_12_HzMS.*10^28; 
        vsPain_8_12_HzMS(isnan(vsPain_8_12_HzMS))=0;
        vsPainAlpha=vsPainAlpha+vsPain_8_12_HzMS;
        disp(j);
    end
    vsPain_8_12_HzMS=vsPainAlpha./length(pain_8_12_Hz.trial);
    
    % for no-pain
    vsNoPainAlpha=zeros(63455,1);
    for j=1:length(noPain_8_12_Hz.trial)
        vsNoPain_8_12_Hz=ActWgts*noPain_8_12_Hz.trial{1,j}(:,nearest(time,.100):nearest(time,.500));
        vsNoPainBL_8_12_Hz=ActWgts*noPain_8_12_Hz.trial{1,j}(:,nearest(time,-.300):nearest(time,0));
        vsNoPain_8_12_HzMS=mean(vsNoPain_8_12_Hz.*vsNoPain_8_12_Hz,2)./ns;
        vsNoPainBL_8_12_HzMS=mean(vsNoPainBL_8_12_Hz.*vsNoPainBL_8_12_Hz,2)./ns;
        vsNoPain_8_12_HzMS=vsNoPain_8_12_HzMS-vsNoPainBL_8_12_HzMS;
        vsNoPain_8_12_HzMS=vsNoPain_8_12_HzMS.*10^28; 
        vsNoPain_8_12_HzMS(isnan(vsNoPain_8_12_HzMS))=0;
        vsNoPainAlpha=vsNoPainAlpha+vsNoPain_8_12_HzMS;
        disp(j);
    end
    vsNoPain_8_12_HzMS=vsNoPainAlpha./length(noPain_8_12_Hz.trial);

    %make image 3D of mean square (MS, power)
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix='pain_alpha_HzMS';
    VS2Brik(cfg1,vsPain_8_12_HzMS);
    cfg1.prefix='noPain_alpha_HzMS';
    VS2Brik(cfg1,vsNoPain_8_12_HzMS);        
    
    eval(['clear vsNoPainBL_8_12_HzMS vsNoPainBL_8_12_Hz vsPainBL_8_12_HzMS vsPainBL_8_12_Hz ActWgts cfg1 conSub',num2str(i),'all conSub',num2str(i),'all_8_12_Hz conSub',num2str(i),'noPain conSub',num2str(i),'noPain_8_12_Hz conSub',num2str(i),'pain conSub',num2str(i),'pain_8_12_Hz ns vsNoPain_8_12_Hz vsNoPain_8_12_HzMS vsPain_8_12_Hz vsPain_8_12_HzMS'])

end

%% moving files to tlrc and moving them into a folder
% now open a terminal and type:
% for i in {1..14}
% do
%     cd /media/My_Passport/fibrodata/con/con$i
%     mkdir SAM_8_12_Hz_old
%     mv *alpha_HzMS+tlrc* SAM_8_12_Hz_old
%     @auto_tlrc -apar brain+tlrc -input pain_alpha_HzMS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPain_alpha_HzMS+orig -dxyz 5
%     mkdir SAM_8_12_Hz
%     cp *alpha_HzMS+tlrc* SAM_8_12_Hz
% done
% % 
% for i in 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 19 20
% do
%     cd /media/My_Passport/fibrodata/fm/fm$i
%     mkdir SAM_8_12_Hz_old
%     mv *alpha_HzMS+tlrc* SAM_8_12_Hz_old
%     @auto_tlrc -apar brain+tlrc -input pain_alpha_HzMS+orig -dxyz 5
%     @auto_tlrc -apar brain+tlrc -input noPain_alpha_HzMS+orig -dxyz 5
%     mkdir SAM_8_12_Hz
%     cp *alpha_HzMS+tlrc* SAM_8_12_Hz
% done

cd /media/My_Passport/fibrodata/SAM_8_12_Hz_BL
masktlrc('3dMVM_8_12_Hz_BL+tlrc','MASKctx+tlrc','_ctx');

%% 3. extract the maximum values in each cluster for the group, pain and interaction between the two
cd /media/My_Passport/fibrodata/SAM_8_12_Hz_BL
clear all
!3dExtrema -prefix Clust20_8_12_Int_ext -mask_file Clust20_8_12_Int_mask+tlrc -data_thr 4.162 -sep_dist 30 -closure -volume 3dMVM_8_12_Hz_BL_ctx+tlrc'[3]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_8_12_Int_ext+tlrc > Clust20_8_12_Int_ext.txt

% 5. creating a matrix of all maximum values according to the xyzInt file created
%% Interaction
clear all
con = [1:14];
fm = [1:7 9:20];

voxInt = importdata('Clust20_8_12_Int_ext.txt');
% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_8_12_Hz/pain_alpha_HzMS+tlrc > Clust20_painVoxValuesIntAlpha.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/con/con',num2str(subs),'/SAM_8_12_Hz/noPain_alpha_HzMS+tlrc > Clust20_noPainVoxValuesIntAlpha.txt']);

        val = importdata('Clust20_painVoxValuesIntAlpha.txt'); Clust20_conPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntAlpha.txt'); Clust20_conNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a = 1;
for subs = fm
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_8_12_Hz/pain_alpha_HzMS+tlrc > Clust20_painVoxValuesIntAlpha.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /media/My_Passport/fibrodata/fm/fm',num2str(subs),'/SAM_8_12_Hz/noPain_alpha_HzMS+tlrc > Clust20_noPainVoxValuesIntAlpha.txt']);

        val = importdata('Clust20_painVoxValuesIntAlpha.txt'); Clust20_fmPainVoxelsInt(a,i) = val(4); val=[];
        val = importdata('Clust20_noPainVoxValuesIntAlpha.txt'); Clust20_fmNoPainVoxelsInt(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_8_12_Hz_BL_Int voxInt wmiInt Clust20_fmPainVoxelsInt Clust20_fmNoPainVoxelsInt...
    Clust20_conPainVoxelsInt Clust20_conNoPainVoxelsInt

for i=1:size(voxInt,1)
    eval(['mean_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_conPainVoxelsInt(:,',num2str(i),')),mean(Clust20_conNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['mean_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_fmPainVoxelsInt(:,',num2str(i),')),mean(Clust20_fmNoPainVoxelsInt(:,',num2str(i),'))];']);
    eval(['sd_voxel_',num2str(i),'(1,1:2) = [std(Clust20_conPainVoxelsInt(:,',num2str(i),'))./sqrt(14),std(Clust20_conNoPainVoxelsInt(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_voxel_',num2str(i),'(2,1:2) = [std(Clust20_fmPainVoxelsInt(:,',num2str(i),'))./sqrt(19),std(Clust20_fmNoPainVoxelsInt(:,',num2str(i),'))./sqrt(19)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),',mean_voxel_',num2str(i),');']);
    ti = sprintf('voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Control','Fibro'});
    legend('Pain','No Pain');
end

% %% present in suma (copy the brick files into surface template folder)
% afni -niml &
% suma -niml -spec tempTest_both.spec -sv temp+tlrc

%% virtual sensors for 10-11Hz frequency band trial by trial (using 8-12 wts because it couldn't do 10-11)
clear
load /media/My_Passport/fibrodata/time
cfg.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[8 12];
cfg.channel = {'MEG'};

disp(1);
eval(['cd /media/My_Passport/fibrodata/con/con',num2str(1)]);
% noise estimation
load splitconds
noPain_8_12_Hz=ft_preprocessing(cfg,noPain);
pain_8_12_Hz=ft_preprocessing(cfg,pain);
load 'SAM/all4cov,8-12Hz,Alla'
ns=ActWgts;
ns=ns-repmat(mean(ns,2),1,size(ns,2));
ns=ns.*ns;
ns=mean(ns,2);
    
% for pain
vsPain_10_11=zeros(63455,1);
vs_8_12=ActWgts*pain_8_12_Hz.trial{1,1};
vsTemp=pain;
vsTemp.trial={};
cfg=[];
cfg.demean='yes';
cfg.continuous='yes';
cfg.blcwindow=[-0.3,0];
cfg.bpfilter='yes';
cfg.hpfilter='no';
cfg.bpfreq=[10 11];
cfg.channel = 'A22';
test=sum(vs_8_12,2);
I=find(test~=0);
tic
for k=I'
    vsTemp.trial{1}=vs_8_12(k,:);
    vs_10_11=ft_preprocessing(cfg,vsTemp);
    vs_10_11_Comp=vs_10_11.trial{1}(:,nearest(time,.100):nearest(time,.500));
    vs_10_11_BL=vs_10_11.trial{1}(:,nearest(time,-.300):nearest(time,.0));
    vs_10_11_Comp_MS=mean(vs_10_11_Comp.*vs_10_11_Comp,2)./ns(k);
    vs_10_11_BL_MS=mean(vs_10_11_BL.*vs_10_11_BL,2)./ns(k);
    vs_10_11_Comp_BL_MS=(vs_10_11_Comp_MS-vs_10_11_BL_MS).*10^27;
    vs_10_11_Comp_BL_MS(isnan(vs_10_11_Comp_BL_MS))=0;
    vsPain_10_11(k,:)=vsPain_10_11(k,:)+vs_10_11_Comp_BL_MS;
end;
toc
% it will take 170 days to run so bye bye!!!

%% Time Frequency Analysis for 2:1:40 freq bins (instead of 2:2:40)
% and looking at each subject pain - noPain plot
%% time frequency analysis
% low frequencies
% control
clear all
for sub = 1:14
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(sub)]);
    load splitconds
    load ERFaverages
    avgPain = pain;
    avgNoPain = noPain;
    avgPain.trialinfo(2:length(avgPain.trialinfo),:) = [];
    avgNoPain.trialinfo(2:length(avgNoPain.trialinfo),:) = [];
    avgPain.trial = {};
    avgNoPain.trial = {};
    avgPain.time = {};
    avgNoPain.time = {};
    eval(['avgPain.trial{1} = conSub',num2str(sub),'pain.avg;']);
    eval(['avgNoPain.trial{1} = conSub',num2str(sub),'noPain.avg;']);
    eval(['avgPain.time{1} = conSub',num2str(sub),'pain.time;']);
    eval(['avgNoPain.time{1} = conSub',num2str(sub),'noPain.time;']);
        cfg             = [];
        cfg.resamplefs  = 300;
        cfg.detrend     = 'yes';
        noPain       = ft_resampledata(cfg, noPain);
        pain         = ft_resampledata(cfg, pain);
        avgPain      = ft_resampledata(cfg, avgPain);
        avgNoPain      = ft_resampledata(cfg, avgNoPain);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials='no';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 2:1:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = -0.8:0.03:1.2;
    cfgtfrl.channel   = {'MEG', '-A41'};
    TFpain            = ft_freqanalysis(cfgtfrl, pain);
    TFnoPain          = ft_freqanalysis(cfgtfrl, noPain);
    TFavgPain         = ft_freqanalysis(cfgtfrl, avgPain);
    TFavgNoPain       = ft_freqanalysis(cfgtfrl, avgNoPain);
    save TFtestLowNew TFpain TFnoPain TFavgPain TFavgNoPain
    clear TFpain TFnoPain TFavgPain TFavgNoPain
end;

clear all
cfg=[];
cfg.baseline     = [-0.3 0];
cfg.baselinetype = 'absolute';
for i = 1:14
    eval(['load /media/My_Passport/fibrodata/con/con',num2str(i),'/TFtestLowNew']);
    % calculate conditions' data as a relative change from their base-line
    TFnoPain=ft_freqbaseline(cfg,TFnoPain);
    TFpain=ft_freqbaseline(cfg,TFpain);
    eval(['conSub',num2str(i),'TFpain = TFpain;']);
    eval(['conSub',num2str(i),'TFnoPain = TFnoPain;']);
    clear TFpain TFnoPain TFavgPain TFavgNoPain
    disp(i);
end;

for i=1:14
    eval(['conSub',num2str(i),'TFLpainDesc = ft_freqdescriptives([],conSub',num2str(i),'TFpain);']);
    eval(['conSub',num2str(i),'TFLnoPainDesc = ft_freqdescriptives([],conSub',num2str(i),'TFnoPain);']);
    eval(['clear conSub',num2str(i),'TFpain conSub',num2str(i),'TFavgPain conSub',num2str(i),'TFnoPain conSub',num2str(i),'TFavgNoPain']);
end;

% differences
for i=1:14
    eval(['conSub',num2str(i),'PainMinusNoPain=conSub',num2str(i),'TFLpainDesc;']);
    eval(['conSub',num2str(i),'PainMinusNoPain.powspctrm=conSub',num2str(i),'TFLpainDesc.powspctrm-conSub',num2str(i),'TFLnoPainDesc.powspctrm;']);
end

% ploting
cfg              = [];
cfg.baseline     = 'no'; 
%cfg.zlim         = [-2*10^(-27) 2*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

for i=1:14
    figure;
    subplot(1,3,1)
    eval(['ft_singleplotTFR(cfg, conSub',num2str(i),'TFLpainDesc);']);
    eval(['title(''sub ',num2str(i),' pain'')']);
    subplot(1,3,2)
    eval(['ft_singleplotTFR(cfg, conSub',num2str(i),'TFLnoPainDesc);']);
    eval(['title(''sub ',num2str(i),' noPain'')']);
    subplot(1,3,3)
    %cfg.zlim = [-3*10^(-28) 3*10^(-28)];
    eval(['ft_singleplotTFR(cfg, conSub',num2str(i),'PainMinusNoPain);']);
    eval(['title(''sub ',num2str(i),' pain - noPain'')']);
end

% grand average
cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFLconPain         = ft_freqgrandaverage(cfg, conSub1TFLpainDesc, conSub2TFLpainDesc, conSub3TFLpainDesc,...
    conSub4TFLpainDesc, conSub5TFLpainDesc, conSub6TFLpainDesc, conSub7TFLpainDesc, conSub8TFLpainDesc,...
    conSub9TFLpainDesc, conSub10TFLpainDesc, conSub11TFLpainDesc, conSub12TFLpainDesc, conSub13TFLpainDesc,...
    conSub14TFLpainDesc);
TFLconNoPain         = ft_freqgrandaverage(cfg, conSub1TFLnoPainDesc, conSub2TFLnoPainDesc, conSub3TFLnoPainDesc,...
    conSub4TFLnoPainDesc, conSub5TFLnoPainDesc, conSub6TFLnoPainDesc, conSub7TFLnoPainDesc, conSub8TFLnoPainDesc,...
    conSub9TFLnoPainDesc, conSub10TFLnoPainDesc, conSub11TFLnoPainDesc, conSub12TFLnoPainDesc, conSub13TFLnoPainDesc,...
    conSub14TFLnoPainDesc);
% differences
TFLconPainMinusNoPain = TFLconPain;
TFLconPainMinusNoPain.powspctrm = TFLconPain.powspctrm - TFLconNoPain.powspctrm;

% ploting
cfg              = [];
cfg.baseline     = 'yes'; 
cfg.baselinetype = 'absolute'; % cfg.baselinetype = 'relchange'; % if I used baseline
%cfg.zlim         = [-2*10^(-27) 2*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
subplot(1,3,1)
ft_singleplotTFR(cfg, TFLconPain);
title('Control pain 1-40Hz')
subplot(1,3,2)
ft_singleplotTFR(cfg, TFLconNoPain);
title('Control no-pain 1-40Hz')
subplot(1,3,3)
cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLconPainMinusNoPain);
title('Control pain minus no-pain 1-40Hz')

%% for fm
clear all
for sub = [1:7 9:20]
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(sub)]);
    load splitconds
    load ERFaverages
    avgPain = pain;
    avgNoPain = noPain;
    avgPain.trialinfo(2:length(avgPain.trialinfo),:) = [];
    avgNoPain.trialinfo(2:length(avgNoPain.trialinfo),:) = [];
    avgPain.trial = {};
    avgNoPain.trial = {};
    avgPain.time = {};
    avgNoPain.time = {};
    eval(['avgPain.trial{1} = fmSub',num2str(sub),'pain.avg;']);
    eval(['avgNoPain.trial{1} = fmSub',num2str(sub),'noPain.avg;']);
    eval(['avgPain.time{1} = fmSub',num2str(sub),'pain.time;']);
    eval(['avgNoPain.time{1} = fmSub',num2str(sub),'noPain.time;']);
        cfg             = [];
        cfg.resamplefs  = 300;
        cfg.detrend     = 'no';
        noPain       = ft_resampledata(cfg, noPain);
        pain         = ft_resampledata(cfg, pain);
        avgPain      = ft_resampledata(cfg, avgPain);
        avgNoPain      = ft_resampledata(cfg, avgNoPain);
    cfgtfrl           = [];
    cfgtfrl.output    = 'pow';
    cfgtfrl.method    = 'mtmconvol';
    cfgtfrl.keeptrials='yes';
    cfgtfrl.taper     = 'hanning';
    cfgtfrl.pad       = 5;
    cfgtfrl.foi       = 2:1:40; 
    cfgtfrl.t_ftimwin = ones(length(cfgtfrl.foi))*0.5;
    cfgtfrl.toi       = -0.8:0.03:1.2;
    cfgtfrl.channel   = {'MEG', '-A41'};
    TFpain            = ft_freqanalysis(cfgtfrl, pain);
    TFnoPain          = ft_freqanalysis(cfgtfrl, noPain);
    TFavgPain         = ft_freqanalysis(cfgtfrl, avgPain);
    TFavgNoPain       = ft_freqanalysis(cfgtfrl, avgNoPain);
    save TFtestLowNew TFpain TFnoPain TFavgPain TFavgNoPain
    clear TFpain TFnoPain TFavgPain TFavgNoPain
end;

clear all
cfg=[];
cfg.baseline     = [-0.3 0];
cfg.baselinetype = 'absolute';
for i = [1:7 9:20]
    eval(['load /media/My_Passport/fibrodata/fm/fm',num2str(i),'/TFtestLowNew']);
    % calculate conditions' data as a relative change from their base-line
    TFnoPain=ft_freqbaseline(cfg,TFnoPain);
    TFpain=ft_freqbaseline(cfg,TFpain);
    eval(['fmSub',num2str(i),'TFpain = TFpain;']);
    eval(['fmSub',num2str(i),'TFnoPain = TFnoPain;']);
    clear TFpain TFnoPain TFavgPain TFavgNoPain
    disp(i);
end;

for i=[1:7 9:20]
    eval(['fmSub',num2str(i),'TFLpainDesc = ft_freqdescriptives([],fmSub',num2str(i),'TFpain);']);
    eval(['fmSub',num2str(i),'TFLnoPainDesc = ft_freqdescriptives([],fmSub',num2str(i),'TFnoPain);']);
    eval(['clear fmSub',num2str(i),'TFpain fmSub',num2str(i),'TFavgPain fmSub',num2str(i),'TFnoPain fmSub',num2str(i),'TFavgNoPain']);
end;

% differences
for i=[1:7 9:20]
    eval(['fmSub',num2str(i),'PainMinusNoPain=fmSub',num2str(i),'TFLpainDesc;']);
    eval(['fmSub',num2str(i),'PainMinusNoPain.powspctrm=fmSub',num2str(i),'TFLpainDesc.powspctrm-fmSub',num2str(i),'TFLnoPainDesc.powspctrm;']);
end

% ploting
cfg              = [];
cfg.baseline     = 'no'; 
%cfg.zlim         = [-2*10^(-27) 2*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

for i=[1:7 9:20]
    figure;
    subplot(1,3,1)
    eval(['ft_singleplotTFR(cfg, fmSub',num2str(i),'TFLpainDesc);']);
    eval(['title(''sub ',num2str(i),' pain'')']);
    subplot(1,3,2)
    eval(['ft_singleplotTFR(cfg, fmSub',num2str(i),'TFLnoPainDesc);']);
    eval(['title(''sub ',num2str(i),' noPain'')']);
    subplot(1,3,3)
    %cfg.zlim = [-3*10^(-28) 3*10^(-28)];
    eval(['ft_singleplotTFR(cfg, fmSub',num2str(i),'PainMinusNoPain);']);
    eval(['title(''sub ',num2str(i),' pain - noPain'')']);
end

% grand average
cfg = [];
cfg.keepindividual = 'yes';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = {'MEG', '-A41'};
cfg.parameter      = 'powspctrm';

TFLfmPain         = ft_freqgrandaverage(cfg, fmSub1TFLpainDesc, fmSub2TFLpainDesc, fmSub3TFLpainDesc,...
    fmSub4TFLpainDesc, fmSub5TFLpainDesc, fmSub6TFLpainDesc, fmSub7TFLpainDesc, fmSub9TFLpainDesc,...
    fmSub10TFLpainDesc, fmSub11TFLpainDesc, fmSub12TFLpainDesc, fmSub13TFLpainDesc, fmSub14TFLpainDesc,...
    fmSub15TFLpainDesc, fmSub16TFLpainDesc, fmSub17TFLpainDesc, fmSub18TFLpainDesc, fmSub19TFLpainDesc,...
    fmSub20TFLpainDesc);

TFLfmNoPain         = ft_freqgrandaverage(cfg, fmSub1TFLnoPainDesc, fmSub2TFLnoPainDesc, fmSub3TFLnoPainDesc,...
    fmSub4TFLnoPainDesc, fmSub5TFLnoPainDesc, fmSub6TFLnoPainDesc, fmSub7TFLnoPainDesc, fmSub9TFLnoPainDesc,...
    fmSub10TFLnoPainDesc, fmSub11TFLnoPainDesc, fmSub12TFLnoPainDesc, fmSub13TFLnoPainDesc, fmSub14TFLnoPainDesc,...
    fmSub15TFLnoPainDesc, fmSub16TFLnoPainDesc, fmSub17TFLnoPainDesc, fmSub18TFLnoPainDesc, fmSub19TFLnoPainDesc,...
    fmSub20TFLnoPainDesc);

% differences
TFLfmPainMinusNoPain = TFLfmPain;
TFLfmPainMinusNoPain.powspctrm = TFLfmPain.powspctrm - TFLfmNoPain.powspctrm;

% ploting
cfg              = [];
cfg.baseline     = 'yes'; 
cfg.baselinetype = 'absolute'; % cfg.baselinetype = 'relchange'; % if I used baseline
%cfg.zlim         = [-2*10^(-27) 2*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'yes';

figure;
subplot(1,3,1)
ft_singleplotTFR(cfg, TFLfmPain);
title('Control pain 1-40Hz')
subplot(1,3,2)
ft_singleplotTFR(cfg, TFLfmNoPain);
title('Control no-pain 1-40Hz')
subplot(1,3,3)
cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLfmPainMinusNoPain);
title('Control pain minus no-pain 1-40Hz')


%% New Cluster Analysis
load /media/My_Passport/fibrodata/TFLgrandaverage_10_2014
% ploting
cfg              = [];
cfg.baseline     = 'no'; 
cfg.zlim         = [-2*10^(-27) 2*10^(-27)];
%cfg.ylim         = [0 15];
cfg.xlim         = [-0.1 0.9];
cfg.interactive  = 'yes';
cfg.layout       = '4D248.lay';
cfg.colorbar     = 'no';

figure;
subplot(2,3,1)
ft_singleplotTFR(cfg, TFLconPain);
title('Control pain 1-40Hz')
subplot(2,3,2)
ft_singleplotTFR(cfg, TFLconNoPain);
title('Control no-pain 1-40Hz')
subplot(2,3,3)
cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLconPainMinusNoPain);
title('Control pain minus no-pain 1-40Hz')
subplot(2,3,4)
cfg.zlim = [-2*10^(-27) 2*10^(-27)];
ft_singleplotTFR(cfg, TFLfmPain);
title('Fibromyalgia pain 1-40Hz')
subplot(2,3,5)
ft_singleplotTFR(cfg, TFLfmNoPain);
title('Fibromyalgia no-pain 1-40Hz')
subplot(2,3,6)
cfg.zlim = [-3*10^(-28) 3*10^(-28)];
ft_singleplotTFR(cfg, TFLfmPainMinusNoPain);
title('Fibromyalgia pain minus no-pain 1-40Hz')

%%  time frequency statistics
cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT'; % or 'depsamplesT' for within subject
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG','-A41'};
% cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
cfg.correctm = 'cluster';
cfg.neighbours = ft_neighbourselection(cfg1);
cd '/media/My_Passport/fibrodata';
        
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:33) = [ones(1,14) 2*ones(1,19)];
cfg.design(2,1:33) = [1:14 1:19];
cfg.ivar =1;
%cfg.uvar =2; % if the statistics is dependent (within subject than
%uncomment this line)
cfg.avgovertime = 'yes'; % cfg.avgovertime = 'no';
cfg.avgoverfreq = 'yes'; % cfg.avgoverfreq = 'no';

cfg.latency     = [0.25 0.49];
cfg.frequency   = [10 11];

[stat] = ft_freqstatistics(cfg, TFLconPainMinusNoPain, TFLfmPainMinusNoPain);

cfg.statistic = 'depsamplesT';
cfg.design=[];
cfg.design(1,1:28) = [ones(1,14) 2*ones(1,14)];
cfg.design(2,1:28) = [1:14 1:14];
cfg.ivar =1;
cfg.uvar =2;
[statCon] = ft_freqstatistics(cfg, TFLconPain, TFLconNoPain);

cfg.design(1,1:38) = [ones(1,19) 2*ones(1,19)];
cfg.design(2,1:38) = [1:19 1:19];
[statFM] = ft_freqstatistics(cfg, TFLfmPain, TFLfmNoPain);

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
sigChans = find(stat.stat2~=0);

% plot
cfgp=[];
cfgp.colorbar='yes';
cfgp.parameter = 'stat';
cfgp.layout = '4D248.lay';
cfgp.alpha = 0.1;
ft_clusterplot(cfgp, stat)

%% looking for outlayers for 250-490ms (36-44 in matrix), 10-11Hz (9-10 in matrix)
load TFLgrandaverage_10_2014
sigChans=find(stat.prob<0.1);
compAlphaCon=zeros(size(TFLconPain.powspctrm,1),4);
for i=1:size(TFLconPain.powspctrm,1)
    compAlphaCon(i,1)=mean(mean(mean(TFLconPain.powspctrm(i,sigChans,[9 10],36:44),4),3),2);
    compAlphaCon(i,2)=mean(mean(mean(TFLconNoPain.powspctrm(i,sigChans,[9 10],36:44),4),3),2);
end
compAlphaFm=zeros(size(TFLfmPain.powspctrm,1),4);
for i=1:size(TFLfmPain.powspctrm,1)
    compAlphaFm(i,1)=mean(mean(mean(TFLfmPain.powspctrm(i,sigChans,[9 10],36:44),4),3),2);
    compAlphaFm(i,2)=mean(mean(mean(TFLfmNoPain.powspctrm(i,sigChans,[9 10],36:44),4),3),2);
end

compAlphaCon(:,3)=compAlphaCon(:,1)-compAlphaCon(:,2);
MeanDiffCon=repmat(mean(compAlphaCon(:,3)),14,1);
SdDiffCon=repmat(std(compAlphaCon(:,3)),14,1);
compAlphaCon(:,4)=(compAlphaCon(:,3)-MeanDiffCon)./SdDiffCon;

compAlphaFm(:,3)=compAlphaFm(:,1)-compAlphaFm(:,2);
MeanDiffFm=repmat(mean(compAlphaFm(:,3)),19,1);
SdDiffFm=repmat(std(compAlphaFm(:,3)),19,1);
compAlphaFm(:,4)=(compAlphaFm(:,3)-MeanDiffFm)./SdDiffFm;

% sub 12 from FM group (raw 11) is an outlayier
TFLfmPainClean=TFLfmPain;
TFLfmPainClean.powspctrm=TFLfmPain.powspctrm([1:10,12:end],:,:,:);
TFLfmNoPainClean=TFLfmNoPain;
TFLfmNoPainClean.powspctrm=TFLfmNoPain.powspctrm([1:10,12:end],:,:,:);

% differences clean
TFLfmPainMinusNoPainClean = TFLfmPainClean;
TFLfmPainMinusNoPainClean.powspctrm = TFLfmPainClean.powspctrm - TFLfmNoPainClean.powspctrm;

cfg =[];
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT'; % or 'depsamplesT' for within subject
cfg.tail = 0;
cfg.alpha = 0.05;
cfg.channel = {'MEG','-A41'};
% cfg.avgoverchan = 'yes';   
        cd '/home/meg/Data/Maor/SchizoProject/Subjects/AviMa0/1/';
        cfg1.gradfile = 'e,rfhp1.0Hz,COH1';
cfg1.method='triangulation';
cfg.correctm = 'cluster';
cfg.neighbours = ft_neighbourselection(cfg1);
cd '/media/My_Passport/fibrodata';
        
cfg.numrandomization = 1000;%'gui', 'text',
cfg.clusterstatistic = 'maxsum'; %how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
cfg.clusterthreshold = 'parametric';%method for single-sample threshold, 'parametric', 'nonparametric_individual', 'nonparametric_common' (default = 'parametric')
cfg.clusteralpha     = 0.05;%for either parametric or nonparametric thresholding (default = 0.05)
cfg.clustercritval   = [-1.96 1.96];
cfg.clustertail      =  0;    
cfg.design(1,1:32) = [ones(1,14) 2*ones(1,18)];
cfg.design(2,1:32) = [1:14 1:18];
cfg.ivar =1;
%cfg.uvar =2; % if the statistics is dependent (within subject than
%uncomment this line)
cfg.avgovertime = 'yes'; % cfg.avgovertime = 'no';
cfg.avgoverfreq = 'yes'; % cfg.avgoverfreq = 'no';

cfg.latency     = [0.25 0.49];
cfg.frequency   = [10 11];

[stat] = ft_freqstatistics(cfg, TFLconPainMinusNoPain, TFLfmPainMinusNoPainClean);

stat.stat2 = stat.mask.*stat.stat; %  gives significatif t-value
sigChans = find(stat.stat2~=0);

% plot
cfgp=[];
cfgp.colorbar='yes';
cfgp.parameter = 'stat';
cfgp.layout = '4D248.lay';
cfgp.alpha = 0.05;
ft_clusterplot(cfgp, stat)

%% choosing the channels myself
sigChans = find(mean(mean(mean(TFLconPainMinusNoPain.powspctrm(:,:,[9 10],36:44),4),3),1)<-10^(-27));

cfg = [];                            
cfg.xlim = [0.25 0.49];
cfg.ylim = [10 11];
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
cfg.colorbar = 'yes';
cfg.highlight = 'labels';
cfg.highlightchannel = TFLconPainMinusNoPain.label(sigChans');
figure; ft_topoplotER(cfg,TFLconPainMinusNoPain)   
% the picture turned out good! taking the channs and running statistics on
% them only

% looking for outlayiers
compAlphaCon=zeros(size(TFLconPain.powspctrm,1),4);
for i=1:size(TFLconPain.powspctrm,1)
    compAlphaCon(i,1)=mean(mean(mean(TFLconPain.powspctrm(i,sigChans,[9 10],36:44),4),3),2);
    compAlphaCon(i,2)=mean(mean(mean(TFLconNoPain.powspctrm(i,sigChans,[9 10],36:44),4),3),2);
end
compAlphaFm=zeros(size(TFLfmPain.powspctrm,1),4);
for i=1:size(TFLfmPain.powspctrm,1)
    compAlphaFm(i,1)=mean(mean(mean(TFLfmPain.powspctrm(i,sigChans,[9 10],36:44),4),3),2);
    compAlphaFm(i,2)=mean(mean(mean(TFLfmNoPain.powspctrm(i,sigChans,[9 10],36:44),4),3),2);
end

compAlphaCon(:,3)=compAlphaCon(:,1)-compAlphaCon(:,2);
MeanDiffCon=repmat(mean(compAlphaCon(:,3)),14,1);
SdDiffCon=repmat(std(compAlphaCon(:,3)),14,1);
compAlphaCon(:,4)=(compAlphaCon(:,3)-MeanDiffCon)./SdDiffCon;

compAlphaFm(:,3)=compAlphaFm(:,1)-compAlphaFm(:,2);
MeanDiffFm=repmat(mean(compAlphaFm(:,3)),19,1);
SdDiffFm=repmat(std(compAlphaFm(:,3)),19,1);
compAlphaFm(:,4)=(compAlphaFm(:,3)-MeanDiffFm)./SdDiffFm;

% taking out outlayiers
TFLfmPainClean=TFLfmPain;
TFLfmPainClean.powspctrm=TFLfmPain.powspctrm([1,3:8,10:end],:,:,:);
TFLfmNoPainClean=TFLfmNoPain;
TFLfmNoPainClean.powspctrm=TFLfmNoPain.powspctrm([1,3:8,10:end],:,:,:);
TFLconPainClean=TFLconPain;
TFLconPainClean.powspctrm=TFLconPainClean.powspctrm([1:4,6:end],:,:,:);
TFLconNoPainClean=TFLconNoPain;
TFLconNoPainClean.powspctrm=TFLconNoPainClean.powspctrm([1:4,6:end],:,:,:);

comp_250_490ms_10_11Hz = zeros(60,4);
comp_250_490ms_10_11Hz(:,1) = [mean(mean(mean(TFLconPainClean.powspctrm(:,channs,[9 10], 36:44),4),3),2);...
    mean(mean(mean(TFLfmPainClean.powspctrm(:,channs,[9 10], 36:44),4),3),2);...
    mean(mean(mean(TFLconNoPainClean.powspctrm(:,channs,[9 10], 36:44),4),3),2);...
    mean(mean(mean(TFLfmNoPainClean.powspctrm(:,channs,[9 10], 36:44),4),3),2)];
comp_250_490ms_10_11Hz(:,2) = [ones(26,1); ones(34,1)*2];
comp_250_490ms_10_11Hz(:,3) = [ones(13,1); ones(13,1)*2; ones(17,1); ones(17,1)*2];
comp_250_490ms_10_11Hz(:,4) = [1:13, 1:13, 14:30, 14:30]';

[SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(comp_250_490ms_10_11Hz,0);

%% looking for sig clusters myself using movies
temp=zeros(66,4);
temp(:,2)=[ones(28,1); ones(38,1)*2];
temp(:,3)=[ones(14,1); ones(14,1)*2; ones(19,1); ones(19,1)*2];
temp(:,4)=[1:14,1:14,15:33,15:33]';
for f=1:length(TFLconPain.freq)
    for t=1:length(TFLconPain.time)
        for chan=1:length(TFLconPain.label)
            temp(:,1)=[TFLconPain.powspctrm(:,chan,f,t);TFLfmPain.powspctrm(:,chan,f,t);TFLconNoPain.powspctrm(:,chan,f,t);...
                TFLfmNoPain.powspctrm(:,chan,f,t)];
            [SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(temp,1);
            Fanova(f,t,chan)=Ps{4};
        end
    end
end

save FanovaAllFreqTimeChans Fanova
% looking for clusters in time using movies (without corecction for multiplt
% comparisons)
load FanovaAllFreqTimeChans
load TFLgrandaverage_10_2014
for ii=7:13
    eval(['f',num2str(ii),'p.pval=squeeze(Fanova(find(TFLconPain.freq==',num2str(ii),'),:,:))'';']);
    eval(['f',num2str(ii),'p.dimord=''chan_time'';']);
    eval(['f',num2str(ii),'p.time=TFLconPain.time;']);
    eval(['f',num2str(ii),'p.label=TFLconPain.label;']);
    cfga.zparam='pval';
    cfga.layout='4D248.lay';
    cfga.colorbar = 'no';
    cfga.highlight = 'on';
    eval(['f',num2str(ii),'p.pval(isnan(f',num2str(ii),'p.pval))=1;']);
    cfgb.layout = '4D248.lay';
    cfgb.colorbar = 'no';
    
    figure;
    j=1;
    for i=27:59
        subplot(1,3,1)
            eval(['cfga.highlightchannel = f',num2str(ii),'p.label(f',num2str(ii),'p.pval(:,i)<0.05);']);
            eval(['cfga.xlim = [f',num2str(ii),'p.time(i) f',num2str(ii),'p.time(i)];']);
            eval(['ft_topoplotER(cfga,f',num2str(ii),'p)']);     
        cfgb.xlim = [TFLconPain.time(i) TFLconPain.time(i)];
        cfgb.ylim = [ii ii];
        subplot(1,3,2) 
            ft_topoplotER(cfgb,TFLconPainMinusNoPain)
            title('Con Pain Minus No-Pain');
        subplot(1,3,3)
            ft_topoplotER(cfgb,TFLfmPainMinusNoPain)
            title('Fm Pain Minus No-Pain');
        eval(['freq',num2str(ii),'movie(j) = getframe(gcf);']);
        j=j+1
    end;
    close all
end

save freqMovies
% showing the movie
implay(freq13movie)

% ploting
cfg = [];                            
cfg.xlim = [0.1 0.2];
cfg.ylim = [10 12];
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
cfg.colorbar = 'yes';
figure;
subplot(1,2,1)
ft_topoplotER(cfg,TFLconPainMinusNoPain)
subplot(1,2,2)
ft_topoplotER(cfg,TFLfmPainMinusNoPain) 

figure
subplot(1,2,1)
ft_topoplotER(cfg,TFLconPain)
title('Con Pain')
subplot(1,2,2)
ft_topoplotER(cfg,TFLconNoPain)
title('Con No-Pain')

%% according to the movies and pictures I decided to try and take 10-12hz and 0.1-0.19ms
% on grand average with keep individuals
conChans = find(mean(mean(mean(TFLconPain.powspctrm(:,:,[find(TFLconPain.freq==10):find(TFLconPain.freq==12)],...
    31:34),4),3),1)<(-1.5)*10^(-27))';
fmChans = find(mean(mean(mean(TFLfmPain.powspctrm(:,:,[find(TFLconPain.freq==10):find(TFLconPain.freq==12)],...
    31:34),4),3),1)<(-1.5)*10^(-27))';

cfg = [];                            
cfg.xlim = [0.1 0.19];
cfg.ylim = [10 12];
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
cfg.colorbar = 'no';
cfg.highlight = 'labels';
cfg.highlightchannel = TFLconPainMinusNoPain.label(conChans);

figure; 
subplot(2,3,1)
ft_topoplotER(cfg,TFLconPainMinusNoPain)
title('Con Pain minus No-Pain');
subplot(2,3,2)
ft_topoplotER(cfg,TFLconPain)
title('Con Pain');
subplot(2,3,3)
ft_topoplotER(cfg,TFLconNoPain)
title('Con No-Pain');

cfg.highlightchannel = TFLconPainMinusNoPain.label(fmChans);

subplot(2,3,4)
ft_topoplotER(cfg,TFLfmPainMinusNoPain)
title('FM Pain minus No-Pain');
subplot(2,3,5)
ft_topoplotER(cfg,TFLfmPain)
title('FM Pain');
subplot(2,3,6)
ft_topoplotER(cfg,TFLfmNoPain)
title('FM No-Pain');

load LRpairs
conChansL = conChans(ismember(TFLconPain.label(conChans),LRpairs(:,1)));
conChansR = conChans(ismember(TFLconPain.label(conChans),LRpairs(:,2)));
fmChansL = fmChans(ismember(TFLfmPain.label(fmChans),LRpairs(:,1)));
fmChansR = fmChans(ismember(TFLfmPain.label(fmChans),LRpairs(:,2)));

% creating a table for statistics
compAlphaCon=zeros(size(TFLconPain.powspctrm,1),4);
for i=1:size(TFLconPain.powspctrm,1)
    compAlphaCon(i,1)=mean(mean(mean(TFLconPain.powspctrm(i,conChansL,9:11,31:34),4),3),2);
    compAlphaCon(i,2)=mean(mean(mean(TFLconNoPain.powspctrm(i,conChansL,9:11,31:34),4),3),2);
    compAlphaCon(i,3)=mean(mean(mean(TFLconPain.powspctrm(i,conChansR,9:11,31:34),4),3),2);
    compAlphaCon(i,4)=mean(mean(mean(TFLconNoPain.powspctrm(i,conChansR,9:11,31:34),4),3),2);
end

compAlphaFm=zeros(size(TFLfmPain.powspctrm,1),4);
for i=1:size(TFLfmPain.powspctrm,1)
    compAlphaFm(i,1)=mean(mean(mean(TFLfmPain.powspctrm(i,fmChansL,9:11,31:34),4),3),2);
    compAlphaFm(i,2)=mean(mean(mean(TFLfmNoPain.powspctrm(i,fmChansL,9:11,31:34),4),3),2);
    compAlphaFm(i,3)=mean(mean(mean(TFLfmPain.powspctrm(i,fmChansR,9:11,31:34),4),3),2);
    compAlphaFm(i,4)=mean(mean(mean(TFLfmNoPain.powspctrm(i,fmChansR,9:11,31:34),4),3),2);
end


% bar plot
compAlphaMeans = [mean(compAlphaCon,1); mean(compAlphaFm,1)];
compAlphaSD = [std(compAlphaCon)./14; std(compAlphaFm)./19];

figure
subplot(1,2,1)
h1=barwitherr([compAlphaSD(:,[1 2])],[compAlphaMeans(:,[1 2])]);
set(h1(1), 'facecolor', [1 1 0.6]);
set(h1(2), 'facecolor', [0 0.5 0.5]);
title('10-12Hz, 100-190ms, Left Component')
ylabel('Power Change Relative to Base-Line');
set(gca, 'XTickLabel', {'control','fibros'});
legend('Pain','No Pain');
subplot(1,2,2)
h2=barwitherr([compAlphaSD(:,[3 4])],[compAlphaMeans(:,[3 4])]);
set(h2(1), 'facecolor', [1 1 0.6]);
set(h2(2), 'facecolor', [0 0.5 0.5]);
title('10-12Hz, 100-190ms, Right Component')
set(gca, 'XTickLabel', {'control','fibros'});
legend('Pain','No Pain');

cfg = [];                            
cfg.xlim = [0.1 0.19];
cfg.ylim = [10 12];
cfg.layout = '4D248.lay';
cfg.interactive = 'yes';
cfg.colorbar = 'no';
cfg.highlight = 'labels';

figure; 
subplot(2,2,1)
cfg.highlightchannel = TFLconPain.label(conChansL);
ft_topoplotER(cfg,TFLconPain)
title('Con Pain Left');
subplot(2,2,2)
cfg.highlightchannel = TFLconPain.label(conChansR);
ft_topoplotER(cfg,TFLconPain)
title('Con Pain Right');
subplot(2,2,3)
cfg.highlightchannel = TFLfmPain.label(fmChansL);
ft_topoplotER(cfg,TFLfmPain)
title('FM Pain Left');
subplot(2,2,4)
cfg.highlightchannel = TFLfmPain.label(fmChansR);
ft_topoplotER(cfg,TFLfmPain)
title('FM Pain Right');
