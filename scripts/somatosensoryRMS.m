%% RMS trial by trial

clear
DATA_ROOT = '/home/meg/Data/Maor/Hypnosis/Subjects';
cd(DATA_ROOT)
runDir = '1_40Hz'; % the sub-folder where the fieldtrip data is
subjects = {'Hyp7','Hyp8','Hyp9','Hyp10','Hyp11','Hyp12','Hyp14','Hyp15','Hyp16','Hyp17','Hyp18','Hyp19','Hyp21','Hyp25','Hyp26','Hyp27','Hyp28'};
% for control exp:
% subjects = {'Hyp101', 'Hyp104', 'Hyp105', 'Hyp106', 'Hyp107', 'Hyp108', 'Hyp109', 'Hyp110', 'Hyp111', 'Hyp112', 'Hyp113', 'Hyp114', 'Hyp115', 'Hyp116'};
numSubs = length(subjects);
subNum = 1 : numSubs;

condNames = {'sub**datafinalsplit'};
condNum = 102:2:108;

load LRpairs
bandPass = {[8 12], [13 25], [26 40], [1 40]};
for covI=1:length(bandPass)
    % define frequency band for analysis
    f1 = bandPass{covI}(1);
    f2 = bandPass{covI}(2);
    
    for subI = 1:numSubs
        cd(sprintf( ['%s/%s'], DATA_ROOT, subjects{subI}));
        TypeName = strrep(condNames{1}, '**', sprintf(subjects{subI}(4:end)));
        % load FT data
        fprintf('Loading %s/%s/%s/%s.mat', DATA_ROOT, subjects{subI}, runDir, TypeName)
        load(sprintf('%s/%s/%s/%s.mat', DATA_ROOT, subjects{subI}, runDir, TypeName));
        for condI = 1:length(condNum)
            clear Data
            eval(sprintf('Data = sub%scon%d;', sprintf(subjects{subI}(4:end)), condNum(condI)));
            disp(' ');
            numTrl = length(Data.trial);
            
            cfgBl=[];
            cfgBl.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
            cfgBl.continuous='yes';
            cfgBl.baselinewindow=[-0.15,0];
            cfgBl.bpfilter='yes';
            cfgBl.bpfreq=[f1 f2];
            cfgBl.channel = 'all';
            Data=ft_preprocessing(cfgBl, Data);
            
            chansL = ismember(Data.label, LRpairs(:,1));
            chansR = ismember(Data.label, LRpairs(:,2));
            
            clear DataRMSL DataRMSR
            DataRMSL=zeros(length(Data.trial),length(Data.time{1}));
            DataRMSR=zeros(length(Data.trial),length(Data.time{1}));
            for trl=1:length(Data.trial)
                DataRMSL(trl,:)=sqrt(mean(Data.trial{trl}(chansL,:).^2));
                DataRMSR(trl,:)=sqrt(mean(Data.trial{trl}(chansR,:).^2));
            end
            eval(sprintf('DataRMSL%d=mean(DataRMSL).*10^14;',condNum(condI)));
            eval(sprintf('DataRMSR%d=mean(DataRMSR).*10^14;',condNum(condI)));
            eval(sprintf('cond%dRMSL(%d,1:%d)=DataRMSL%d;',condNum(condI),subI,length(Data.time{1}),condNum(condI)));
            eval(sprintf('cond%dRMSR(%d,1:%d)=DataRMSR%d;',condNum(condI),subI,length(Data.time{1}),condNum(condI)));
        end
    end
    cd(DATA_ROOT)
    save(sprintf('RMS_%d_%d',f1,f2),'cond102RMSL','cond102RMSR','cond104RMSL','cond104RMSR','cond106RMSL','cond106RMSR','cond108RMSL','cond108RMSR');
    clear cond102RMSL cond102RMSR cond104RMSL cond104RMSR cond106RMSL cond106RMSR cond108RMSL cond108RMSR 
end

%% plot RMS
clear all
load time
bandPass = {[8 12], [13 25], [26 40], [1 40]};

for i=1:length(bandPass)
    load(sprintf('RMS_%d_%d',bandPass{i}(1),bandPass{i}(2)));
    % contralateral
    figure
    subplot(4,1,2)
    plot(time,mean(cond102RMSL),'b') % LH pre right
    hold on;
    %jbfill(time,meanCon102RMSL+seCon102RMSL,meanCon102RMSL-seCon102RMSL,[0,0,1],[0,0,1],0,0.3)
    plot(time,mean(cond106RMSL),'r') % LH post right
    %jbfill(time,meanCon106RMSL+seCon106RMSL,meanCon106RMSL-seCon106RMSL,[1,0,0],[1,0,0],0,0.3)
    grid;
    title('Contrlateral Right Hand (n=17); Blue - pre hypnosis, Red - during hypnosis');
    subplot(4,1,1)
    plot(time,mean(cond104RMSR),'b') % RH pre left
    hold on;
    %jbfill(time,meanCon104RMSR+seCon104RMSR,meanCon104RMSR-seCon104RMSR,[0,0,1],[0,0,1],0,0.3)
    plot(time,mean(cond108RMSR),'r') % RH post left
    %jbfill(time,meanCon108RMSR+seCon108RMSR,meanCon108RMSR-seCon108RMSR,[1,0,0],[1,0,0],0,0.3)
    grid;
    title('Contrlateral Left Hand (n=17); Blue - pre hypnosis, Red - during hypnosis');
    
    % ipsilateral
    subplot(4,1,4)
    plot(time,mean(cond102RMSR),'b')
    hold on;
    %jbfill(time,meanCon102RMSL+seCon102RMSL,meanCon102RMSL-seCon102RMSL,[0,0,1],[0,0,1],0,0.3)
    plot(time,mean(cond106RMSR),'r')
    %jbfill(time,meanCon106RMSL+seCon106RMSL,meanCon106RMSL-seCon106RMSL,[1,0,0],[1,0,0],0,0.3)
    grid;
    title('Ipsilateral Right Hand (n=17); Blue - pre hypnosis, Red - during hypnosis');
    subplot(4,1,3)
    plot(time,mean(cond104RMSL),'b')
    hold on;
    %jbfill(time,meanCon104RMSR+seCon104RMSR,meanCon104RMSR-seCon104RMSR,[0,0,1],[0,0,1],0,0.3)
    plot(time,mean(cond108RMSL),'r')
    %jbfill(time,meanCon108RMSR+seCon108RMSR,meanCon108RMSR-seCon108RMSR,[1,0,0],[1,0,0],0,0.3)
    grid;
    title('Ipsilateral Left Hand (n=17); Blue - pre hypnosis, Red - during hypnosis');
    clear cond102RMSL cond102RMSR cond104RMSL cond104RMSR cond106RMSL cond106RMSR cond108RMSL cond108RMSR
end

%% RMS on the average
clear
DATA_ROOT = '/home/meg/Data/Maor/Hypnosis/Subjects';
cd(DATA_ROOT)
runDir = '1_40Hz'; % the sub-folder where the fieldtrip data is
subjects = {'Hyp7','Hyp8','Hyp9','Hyp10','Hyp11','Hyp12','Hyp14','Hyp15','Hyp16','Hyp17','Hyp18','Hyp19','Hyp21','Hyp25','Hyp26','Hyp27','Hyp28'};
% for control exp:
% subjects = {'Hyp101', 'Hyp104', 'Hyp105', 'Hyp106', 'Hyp107', 'Hyp108', 'Hyp109', 'Hyp110', 'Hyp111', 'Hyp112', 'Hyp113', 'Hyp114', 'Hyp115', 'Hyp116'};
numSubs = length(subjects);
subNum = 1 : numSubs;

condNames = {'sub**datafinalsplit'};
condNum = 102:2:108;

load LRpairs
bandPass = {[8 12], [13 25], [26 40], [1 40]};
for covI=1:length(bandPass)
    % define frequency band for analysis
    f1 = bandPass{covI}(1);
    f2 = bandPass{covI}(2);
    
    for subI = 1:numSubs
        cd(sprintf( ['%s/%s'], DATA_ROOT, subjects{subI}));
        TypeName = strrep(condNames{1}, '**', sprintf(subjects{subI}(4:end)));
        % load FT data
        fprintf('Loading %s/%s/%s/%s.mat', DATA_ROOT, subjects{subI}, runDir, TypeName)
        load(sprintf('%s/%s/%s/%s.mat', DATA_ROOT, subjects{subI}, runDir, TypeName));
        for condI = 1:length(condNum)
            clear Data DataT
            eval(sprintf('Data = sub%scon%d;', sprintf(subjects{subI}(4:end)), condNum(condI)));
            disp(' ');
            numTrl = length(Data.trial);
            
            cfgBl=[];
            cfgBl.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
            cfgBl.continuous='yes';
            cfgBl.baselinewindow=[-0.15,0];
            cfgBl.bpfilter='yes';
            cfgBl.bpfreq=[f1 f2];
            cfgBl.channel = 'all';
            DataT=ft_preprocessing(cfgBl, Data);
            Data=ft_timelockanalysis([],DataT);
            
            chansL = ismember(Data.label, LRpairs(:,1));
            chansR = ismember(Data.label, LRpairs(:,2));
            
            clear DataRMSL DataRMSR
            DataRMSL=sqrt(mean(Data.avg(chansL,:).^2));
            DataRMSR=sqrt(mean(Data.avg(chansR,:).^2));

            eval(sprintf('DataRMSL%d=DataRMSL.*10^14;',condNum(condI)));
            eval(sprintf('DataRMSR%d=DataRMSR.*10^14;',condNum(condI)));
            eval(sprintf('cond%dRMSL(%d,1:%d)=DataRMSL%d;',condNum(condI),subI,length(Data.time),condNum(condI)));
            eval(sprintf('cond%dRMSR(%d,1:%d)=DataRMSR%d;',condNum(condI),subI,length(Data.time),condNum(condI)));
        end
    end
    cd(DATA_ROOT)
    save(sprintf('RMS_%d_%d_avg',f1,f2),'cond102RMSL','cond102RMSR','cond104RMSL','cond104RMSR','cond106RMSL','cond106RMSR','cond108RMSL','cond108RMSR');
    clear cond102RMSL cond102RMSR cond104RMSL cond104RMSR cond106RMSL cond106RMSR cond108RMSL cond108RMSR 
end

%% plot
clear all
load time
bandPass = {[8 12], [13 25], [26 40], [1 40]};

for i=1:length(bandPass)
    load(sprintf('RMS_%d_%d_avg',bandPass{i}(1),bandPass{i}(2)));
    % contralateral
    figure
    subplot(4,1,2)
    plot(time,mean(cond102RMSL),'b') % LH pre right
    hold on;
    %jbfill(time,meanCon102RMSL+seCon102RMSL,meanCon102RMSL-seCon102RMSL,[0,0,1],[0,0,1],0,0.3)
    plot(time,mean(cond106RMSL),'r') % LH post right
    %jbfill(time,meanCon106RMSL+seCon106RMSL,meanCon106RMSL-seCon106RMSL,[1,0,0],[1,0,0],0,0.3)
    grid;
    title('Contrlateral Right Hand (n=17); Blue - pre hypnosis, Red - during hypnosis');
    subplot(4,1,1)
    plot(time,mean(cond104RMSR),'b') % RH pre left
    hold on;
    %jbfill(time,meanCon104RMSR+seCon104RMSR,meanCon104RMSR-seCon104RMSR,[0,0,1],[0,0,1],0,0.3)
    plot(time,mean(cond108RMSR),'r') % RH post left
    %jbfill(time,meanCon108RMSR+seCon108RMSR,meanCon108RMSR-seCon108RMSR,[1,0,0],[1,0,0],0,0.3)
    grid;
    title('Contrlateral Left Hand (n=17); Blue - pre hypnosis, Red - during hypnosis');
    
    % ipsilateral
    subplot(4,1,4)
    plot(time,mean(cond102RMSR),'b')
    hold on;
    %jbfill(time,meanCon102RMSL+seCon102RMSL,meanCon102RMSL-seCon102RMSL,[0,0,1],[0,0,1],0,0.3)
    plot(time,mean(cond106RMSR),'r')
    %jbfill(time,meanCon106RMSL+seCon106RMSL,meanCon106RMSL-seCon106RMSL,[1,0,0],[1,0,0],0,0.3)
    grid;
    title('Ipsilateral Right Hand (n=17); Blue - pre hypnosis, Red - during hypnosis');
    subplot(4,1,3)
    plot(time,mean(cond104RMSL),'b')
    hold on;
    %jbfill(time,meanCon104RMSR+seCon104RMSR,meanCon104RMSR-seCon104RMSR,[0,0,1],[0,0,1],0,0.3)
    plot(time,mean(cond108RMSL),'r')
    %jbfill(time,meanCon108RMSR+seCon108RMSR,meanCon108RMSR-seCon108RMSR,[1,0,0],[1,0,0],0,0.3)
    grid;
    title('Ipsilateral Left Hand (n=17); Blue - pre hypnosis, Red - during hypnosis');
    clear cond102RMSL cond102RMSR cond104RMSL cond104RMSR cond106RMSL cond106RMSR cond108RMSL cond108RMSR
end