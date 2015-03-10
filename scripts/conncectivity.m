%%
% creating the SAMwts
%--------------------

% in each folder you should have: hs_file, config, dataorig and the ___.rtw
% the rtw file is a file with the name of the folder as a prefix (e.g., sub07.rtw).
% in the parent folder (one folder above the folder with the data) you should have the paramfile
% for each frequency band pass. For example, for Alpha it should look like
% this:

% NumStates 1
% DataBand 1 80
% ImageBand 8 13
% DataSegment 0	300
% ImageMetric Power
% ImageMode Pseudo-Z
% Model	MultiSphere     
% XBounds	-10	10      % the x grid
% YBounds	-9	9       % the y grid
% ZBounds	0	15      % the z grid
% ImageStep	0.5         % the grid resolution - 0.5cm

% Now, open a terminal and cd to the parent folder.
% enter: "SAMcov -r xxxxx -d xc,hb,lf_c,rfhp0.1Hz -m yyyyy -v". 
% Where xxxxx is the name of the folder with the data and yyyyy is the name of the
% paramfile.
% Enter: "SAMwts -r xxxxx -d xc,hb,lf_c,rfhp0.1Hz -m yyyyy -c Global -v".
% A SAM sub-folder was created inside the folder containing the wts file!!!

%% create trl for resting state
clear all
i=2; % begining of resting state in seconds
j=122; % end of resting state in seconds
cfg.trl(1,1)=round(i*1017); 
cfg.trl(1,2)=round(j*1017);
cfg.trl(1,3)=0;
cfg.trl(1,4)=100;
%% Definetrial
source= 'xc,hb,lf_c,rfhp0.1Hz'; % change if necesary
cfg.dataset=source;
cfg.trialfun='trialfun_beg';
cfg=ft_definetrial(cfg);

%% find bad channels
findBadChans(source);

cfg.channel= 'MEG'; % {'MEG','-A74','-A204'}; 

%% Preprocessing
cfg.demean='yes'; % normalize the data according to the base line average time1min window (see two lines below)
cfg.baselinewindow=[cfg.trl(1) cfg.trl(2)];
cfg.continuous='yes';
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[8 13];
cfg.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataorigAlpha=ft_preprocessing(cfg);


save dataorigAlpha dataorigAlpha
%% Creating the virtual sensors (wts metrix X data metrix) for the first 30s to find a seed voxel
% next function will read the wts file made by SAMwts and multiply the weights by
% the averaged data. you can do that also for unaveraged data and raw,
clear all
load dataorigAlpha

vs30=cell(1,30);
timeline30=cell(1,30);
allInd30=cell(1,30);
for i=0:29
    [vs30{1,i+1},timeline30{1,i+1},allInd30{1,i+1}]=VS_slice(dataorigAlpha,'SAM/HypAlpha,1-80Hz,Global.wts',1,[i i+1]);
    %[vs30{1,i+1},allInd30{1,i+1}]=inScalpVS(vs30{1,i+1},allInd30{1,i+1}); % excluding out of the scalp grid points
end;

% taking only voxels inside the scalp and normalizing the data
load '/home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/SAM/HypAlpha,1-80Hz,Global'

[ActWgts,allIndTemp]=inScalpVS(ActWgts,allInd30{1,1});

for i=0:29
    [vs30{1,i+1},allInd30{1,i+1}]=inScalpVS(vs30{1,i+1},allInd30{1,i+1}); % excluding out of the scalp grid points
end;

vs30=[vs30{1,1:30}];
allInd30=allInd30{1,1};
timeline30=[timeline30{1,1:30}];

vs30=vs30./repmat(sqrt(mean(ActWgts.^2,2)),1,30547);

vs30pow=mean(vs30.*vs30,2);
[powMax,indx]=max(vs30pow);
seed=allInd30(indx,:);

save vs30 vs30pow timeline30 allInd30 powMax indx seed -v7.3

%% ploting
hs=ft_read_headshape('hs_file');
hs.pnt=hs.pnt*100;

subplot(1,2,1);
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,vs30pow,'.');
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),10,'g','.');

subplot(1,2,2);
vs30powMax=vs30pow;
vs30powMax(indx,1)=1;
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,vs30powMax,'.');
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),10,'g','.');

%% 4 method to calculate connectivity
% after chosing the seed, now it is time to create the full virtual sensor for the seed and
% to calculate the connectivity between the seed virtual sensor and the
% other voxels' virtual sensors (one at a time).

%% Method 1: Averaged Envelope Correlation
clear all
load dataorigAlpha
load vs30

% ActWgts only for in scalp voxles - load HypAlpha,1-80Hz,Global.mat from the SAM folder
nonZero=find(sum(abs(ActWgts),2)>0); % looking for voxels out of the scalp (weights zero)
ActWgtsInScalp=ActWgts(nonZero,:); % taking only non zero ActWgts
clear ActWgts nonZero SAMheader ActIndex

save ActWgtsInScalp ActWgtsInScalp

% creating the virtual sensors, enveloping them and calculating the
% correlations between the seed and the rest of the voxels.
% this stage takes 15 mins so have a break!!!
meanEnvelope=zeros(size(ActWgtsInScalp,1),120);
for i=1:120
    voxBF=ActWgtsInScalp*dataorigAlpha.trial{1,1}(:,(1017*(i-1)+1):(1017*i));
    voxBFenv=hilbert(voxBF');
    voxBFenv=abs(voxBFenv');
    meanEnvelope(:,i)=mean(voxBFenv,2); % this is for the second method (see next section)
    for j=1:size(allInd30,1)
        seedAndVox=[];
        seedAndVox(:,1)=voxBFenv(indx,:)';
        seedAndVox(:,2)=voxBFenv(j,:)';
        [R,P]=corrcoef(seedAndVox);
        AEC.R(j,i)=R(1,2);
        AEC.P(j,i)=P(1,2);
    end;
    disp(i);
end;

save meanEnvelope meanEnvelope
save AEC AEC allInd30 
clear all
load AEC

AEC.RpCorr=zeros(size(allInd30,1),1);
AEC.Rp=zeros(size(allInd30,1),1);
pCorr=0.05/(size(allInd30,1)-1);
AEC.RpCorr(find(mean(AEC.P,2)<pCorr),1)=1;
AEC.Rp(find(mean(AEC.P,2)<0.05),1)=1;

% ploting
hs=ft_read_headshape('hs_file');
hs.pnt=hs.pnt*100;

figure;
subplot(1,2,1)
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,mean(AEC.R,2),'.');
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),10,'g','.');

subplot(1,2,2)
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,AEC.Rp,'.');
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),10,'g','.');

figure;
subplot(1,2,1)
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,mean(AEC.R,2),'.');
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),10,'g','.');

subplot(1,2,2)
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,AEC.RpCorr,'.');
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),10,'g','.');
%% Method 2: Correlation of Averaged Envelopes
% calculating the correclations it takes less then a min.
clear all
load meanEnvelope
load vs30

CAE=[];
seedAndVox=zeros(120,2);
seedAndVox(:,1)=meanEnvelope(indx,:)';
for j=1:size(allInd30,1)
    seedAndVox(:,2)=meanEnvelope(j,:)';
    [R,P]=corrcoef(seedAndVox);
    CAE.R(j,1)=R(1,2);
    CAE.P(j,1)=P(1,2);
end;

save CAE CAE allInd30
clear all
load CAE

CAE.RpCorr=zeros(size(allInd30,1),1);
CAE.Rp=zeros(size(allInd30,1),1);
pCorr=0.05/(size(allInd30,1)-1);
CAE.RpCorr(find(CAE.P<pCorr),1)=1;
CAE.Rp(find(CAE.P<0.05),1)=1;
% ploting
hs=ft_read_headshape('hs_file');
hs.pnt=hs.pnt*100;

subplot(1,2,1);
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,CAE.R,'.');
hold on; % for hs plot on the plot
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),20,'g','.');

subplot(1,2,2);
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,CAE.Rp,'.');
hold on; % for hs plot on the plot
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),20,'g','.');

figure;
subplot(1,2,1);
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,CAE.R,'.');
hold on; % for hs plot on the plot
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),20,'g','.');

subplot(1,2,2);
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,CAE.RpCorr,'.');
hold on; % for hs plot on the plot
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),20,'g','.');
%% Method 3: Coherence
% firstly, we need all the data so we will start from the begining
clear all
i=2; % begining of resting state in seconds
j=122; % end of resting state in seconds
cfg.trl(1,1)=round(i*1017); 
cfg.trl(1,2)=round(j*1017);
cfg.trl(1,3)=0;
cfg.trl(1,4)=100;

% Definetrial
source= 'xc,hb,lf_c,rfhp0.1Hz'; % change if necesary
cfg.dataset=source;
cfg.trialfun='trialfun_beg';
cfg=ft_definetrial(cfg);

% find bad channels
findBadChans(source);

cfg.channel= 'MEG'; % {'MEG','-A74','-A204'}; 

% Preprocessing
cfg.demean='yes'; % normalize the data according to the base line average time1min window (see two lines below)
cfg.baselinewindow=[cfg.trl(1) cfg.trl(2)];
cfg.continuous='yes';
cfg.bpfilter='yes'; % apply bandpass filter (see one line below)
cfg.bpfreq=[1 80];
cfg.channel = 'MEG'; % MEG channels configuration. Take the MEG channels and exclude the minus ones 
dataAllFreq=ft_preprocessing(cfg);

save dataAllFreq dataAllFreq
clear all

load dataAllFreq
load vs30
load ActWgtsInScalp

for i=1:120 % takes a very long time... over 3.5 hours!!!!!!!!!!!!!!!!!!!!!
    voxBF=ActWgtsInScalp*dataAllFreq.trial{1,1}(:,(1017*(i-1)+1):(1017*i));
    for j=1:size(allInd30,1) % coherence for alpha (takes 3.5 mins)
        [Cxy(j,:),F(1,:)]=mscohere(voxBF(indx,:),voxBF(j,:),508,0,1017,1017); % change indx for other freq
        CohAlpha(j,i)=mean(Cxy(j,9:14),2);
    end;
    disp(i);
end;

meanCohAlpha=mean(CohAlpha,2);

save CohAlpha CohAlpha F meanCohAlpha 
%% calculating a coherence threshold for alpha - takes about an hour
clear all
load dataAllFreq
load vs30
load ActWgtsInScalp

% 1. choosing 100 random seeds (excluding the real seed)
randSeeds=1+round(rand(1,100)*(size(allInd30,1)-1));
while ismember(indx,randSeeds) % making sure the seed is not part of the reandom vector
   randSeeds(find(randSeeds==indx))=1+round(rand(1,1)*size(allInd30,1));
end;

% 2. choosing 100 random voxels to calculate the coherence between them and
% seeds and adjusting the ActWgtsInScalp matrix
randVox=1+round(rand(1,100)*(size(allInd30,1)-1));
randActWgtsInScalp=ActWgtsInScalp(find(randVox),:);

save randSeeds randVox randSeeds randActWgtsInScalp

% 3. calculating coherence for each seed and extracting the maximum value
a=1;
for j=[randSeeds]
    for i=1:100
        seedBF=ActWgtsInScalp(j,:)*dataAllFreq.trial{1,1}(:,(1017*(i-1)+1):(1017*i));
        voxBF=randActWgtsInScalp*dataAllFreq.trial{1,1}(:,(1017*(i-1)+1):(1017*i));
        for k=1:100
            tCxy(k,:)=mscohere(seedBF,voxBF(k,:),508,0,1017,1017); % t for temp
            tCohAlpha(k,i)=mean(tCxy(k,9:14),2);
        end;
     end;
     disp(a)
     meantCohAlpha(1,a)=mean(mean(tCohAlpha,2));
     a=a+1;
end;

maxCohAlpha=max(meantCohAlpha);
CohAlpha95=sort(meantCohAlpha);
CohAlpha95=CohAlpha95(1,95);

save CohAlphaThreshold maxCohAlpha meantCohAlpha CohAlpha95
    
clear all
load CohAlphaThreshold 
load CohAlpha
load vs30

% taking only sig voxels (according to our threshold)
CohAlphaSig95=zeros(size(allInd30,1),1);
CohAlphaSigMax=zeros(size(allInd30,1),1);
CohAlphaSigMax(find(meanCohAlpha > maxCohAlpha))=1; % according to max threshold
CohAlphaSig95(find(meanCohAlpha > CohAlpha95))=1; % according to 95% threshold
% ploting the results
hs=ft_read_headshape('hs_file');
hs.pnt=hs.pnt*100;

subplot(1,2,1)
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,CohAlphaSigMax,'.');
title('Coherence Alpha Max Sig')
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),20,'g','.');

subplot(1,2,2)
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,CohAlphaSig95,'.');
title('Coherence Alpha 95% Sig')
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),20,'g','.');

save CohAlphaSig CohAlphaSigMax CohAlphaSig95

%% Method 4: Imaginary Coherence
% as above but this time only the absolute of the imaginary part was
% averaged across segments
clear all
load dataAllFreq
load vs30
load ActWgtsInScalp

for i=1:120 % takes a very long time... over 3.5 hours!!!!!!!!!!!!!!!!!!!!!
    voxBF=ActWgtsInScalp*dataAllFreq.trial{1,1}(:,(1017*(i-1)+1):(1017*i));
    for j=1:size(allInd30,1) % coherence for alpha (takes 3.5 mins)
        [Cxy(j,:),F(1,:)]=Imscohere(voxBF(indx,:),voxBF(j,:),508,0,1017,1017);
        % this is a version of mscohere which I made. It calls the
        % function Iwelch instead of welch. There, you should change
        % line 147 to: "Pxx = (abs(imag(Pxy)).^2)./(Pxx.*Pyy);"
        ICohAlpha(j,i)=mean(Cxy(j,9:14),2);
    end;
    disp(i);
end;

meanICohAlpha=mean(ICohAlpha,2);

save ICohAlpha ICohAlpha F meanICohAlpha

% calculating Icoherence for each rand seed and extracting the maximum value
load randSeeds
a=1;
for j=[randSeeds]
    for i=1:100
        seedBF=ActWgtsInScalp(j,:)*dataAllFreq.trial{1,1}(:,(1017*(i-1)+1):(1017*i));
        voxBF=randActWgtsInScalp*dataAllFreq.trial{1,1}(:,(1017*(i-1)+1):(1017*i));
        for k=1:100
            tCxy(k,:)=Imscohere(seedBF,voxBF(k,:),508,0,1017,1017); % Imscohere takes only the imaginary part
            % this is a version of mscohere which I made. It calls the
            % function Iwelch instead of welch. There, you should change
            % line 147 to: "Pxx = (abs(imag(Pxy)).^2)./(Pxx.*Pyy);"
            tICohAlpha(k,i)=mean(tCxy(k,9:14),2);
        end;
     end;
     disp(a)
     meantICohAlpha(1,a)=mean(mean(tICohAlpha,2));
     a=a+1;
end;

maxICohAlpha=max(meantICohAlpha);
ICohAlpha95=sort(meantICohAlpha);
ICohAlpha95=ICohAlpha95(1,95);

save ICohAlphaThreshold maxICohAlpha meantICohAlpha ICohAlpha95
    
clear all
load ICohAlphaThreshold 
load ICohAlpha
load vs30

% creating a matrix with sig (according to our threshold) coherence voxels
% for each freq band
ICohAlphaSig95=zeros(size(allInd30,1),1);
ICohAlphaSigMax=zeros(size(allInd30,1),1);
ICohAlphaSigMax(find(meanICohAlpha > maxICohAlpha))=1; % according to max threshold
ICohAlphaSig95(find(meanICohAlpha > ICohAlpha95))=1; % according to 95% threshold

% ploting the results
hs=ft_read_headshape('hs_file');
hs.pnt=hs.pnt*100;

subplot(1,2,1)
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,ICohAlphaSigMax,'.');
title('ICoherence Alpha Max Sig')
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),20,'g','.');

subplot(1,2,2)
scatter3(allInd30(:,1),allInd30(:,2),allInd30(:,3),30,ICohAlphaSig95,'.');
title('ICoherence Alpha 95% Sig')
hold on;
scatter3(hs.pnt(:,1),hs.pnt(:,2),hs.pnt(:,3),20,'g','.');

save ICohAlphaSig ICohAlphaSigMax ICohAlphaSig95

%% projecting the data on MRI tamplet
% first download Afni for MATLAB from: 
% http://afni.nimh.nih.gov/afni/download/afnimatlab/psc_project_view
% create a path on MATLAB
% you should also download the vs movie package from:
% https://github.com/yuval-harpaz/vsMovies
% create a path on MATLAB
% Now you are good to go...

% secondly, we should have the original voxels vector with all the voxels
% including the ones that are outside the scalp
load dataAllFreq
[vs,timeline,allInd]=VS_slice(dataorig,'SAM/HypAlpha,1-80Hz,Global.wts',1,[1 2]);
vs(:,2:end)=[];

% inserting our statistic into the vs vector (or metrix if we want a movie)
% instead of the virtual sensors
VS=zeros(length(vs),1);
indind=find(vs);
VS(indind)=CAE.R; % or AEC/Coh/ICoh depends on your statist

torig=0; % beginning of VS in ms
TR=num2str(1000/1017.25); % time of requisition, time gap between samples (sampling rate here is 1017.25)
cfg=[];
%cfg.func='~/vsMovies/Data/funcTemp+orig';
cfg.step=5;
cfg.boxSize=[-100 100 -90 90 0 150];
cfg.prefix='CohAlpha'; % or AEC/Coh/ICoh depends on your statist
cfg.TR=TR;
cfg.torig=torig;
VS2Brik(cfg,VS); % the output is CAE+orig file
%hs2afni('hs_file'); % creating hs file for afni if you need to nudge the
%data

% creating tamplet MRI
fitMRI2hs('xc,hb,lf_c,rfhp0.1Hz'); % the output is a warped+orig file

% Finally, open a terminal cd to the directory where the data is and then open
% afni. Underlay=warped ; Overlay=CAE/AEC/Coh/ICoh


