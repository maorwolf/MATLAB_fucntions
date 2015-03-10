%% Script to create power change data at the source level
% 1 - load wts and FT data
% 2 - Calculate FFT for each trial for a given time window at the sensor
%     level and the average the results over all trials
% 3 - multiply wts*avgDataFFT for each virtual sensor
% 4 - average the mean power across a certain frequency band
% 5 - write into a Brik file the averaged power change for each subject
% 6 - perform permutations on the results

%% create param file and wts (do it for each freq band)
% remember you need the marker file for each subject
clear
% for hyp exp:
subjects = {'Hyp7','Hyp8','Hyp9','Hyp10','Hyp11','Hyp12','Hyp14','Hyp15','Hyp16','Hyp17','Hyp18','Hyp19','Hyp21','Hyp25','Hyp26','Hyp27','Hyp28'};
% for control exp:
% subjects = {'Hyp101', 'Hyp104', 'Hyp105', 'Hyp106', 'Hyp107', 'Hyp108', 'Hyp109', 'Hyp110', 'Hyp111', 'Hyp112', 'Hyp113', 'Hyp114', 'Hyp115', 'Hyp116'};
cd /home/meg/Data/Maor/Hypnosis/Subjects

createPARAM('all4cov','ERF','all',[0 0.5],'all',[-0.15 0],[26 40],[-0.15 1]);
% for control exp change "Nolte" to "MultiSphere"
for i=1:length(subjects)
    eval(['!SAMcov64 -r ',subjects{i},' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -v']);
    eval(['!SAMwts64 -r ',subjects{i},' -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -c alla -v']);
end

%%
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

bandPass = {[8 12], [13 25], [26 40], [1 40]};

covI = 3; % choose the desired frequency band for the analysis
% define frequency band for analysis
f1 = bandPass{covI}(1);
f2 = bandPass{covI}(2);
%% ===================== Use FFT at the sensor level and then multiply by the wts ===============================================
for condI = 1  : length(condNum)
    
    % initialize for this run
    samplingRate = 1017.25;
    tw = 200; % time window for fft (in samples)
    overlap = 190; % Samples for overlap
    tEnd = 662; % data length (how many time-samples are in your fieldtrip data)
    tStart = 1:tw-overlap:tEnd; % vector defining index for the beginning of each time window
    offsetT = 0.150; % offset of the first sample from time 0 (in sec.)
    tMEG = (0:tw-overlap:tEnd)/samplingRate-offsetT; % time vector for MEG
    MEGfft = cell(numSubs, length(tStart));
    Rs = cell(1, numSubs);

    % end initialization
    
    %% ================= Start FFT analysis =========================
    tI = 0;
    tIstopFlag = 1;
    % run over all time windows
    while tIstopFlag
        tI = tI+1;
        disp('*****************');
        disp(['time window ',num2str(tI),'/',num2str(length(0:tw-overlap:tEnd))]);
        disp('*****************');
        % run over all subjects
        for subI = 1:numSubs
            
            cd(sprintf( ['%s/%s'], DATA_ROOT, subjects{subI}));
            TypeName = strrep(condNames{1}, '**', sprintf(subjects{subI}(4:end)));
            wtsDir = sprintf('%s/%s/SAM', DATA_ROOT, subjects{subI}); % data path for the wts file
            % load FT data
            if exist(sprintf('%s/%s/%s/%s.mat', DATA_ROOT, subjects{subI}, runDir, TypeName), 'file')
                fprintf('Loading %s/%s/%s/%s.mat', DATA_ROOT, subjects{subI}, runDir, TypeName)
                load(sprintf('%s/%s/%s/%s.mat', DATA_ROOT, subjects{subI}, runDir, TypeName));
                eval(sprintf('Data = sub%scon%d;', sprintf(subjects{subI}(4:end)), condNum(condI)));
                disp(' ');
                numTrl = length(Data.trial);
            else
                error('Data not found')
            end
            
            cfgBl=[];
            cfgBl.demean='yes'; % normalize the data according to the base line average time window (see two lines below)
            cfgBl.continuous='yes';
            cfgBl.baselinewindow=[-0.15,0];
            cfgBl.bpfilter='yes';
            cfgBl.bpfreq=[f1 f2];
            cfgBl.channel = 'all';
            Data=ft_preprocessing(cfgBl, Data);
            
            % reading the wts
            wtsNoSuf =sprintf('%s/all4cov,%d-%dHz,alla', wtsDir, f1, f2);% name of the wts
            if exist([wtsNoSuf,'.mat'],'file')
                load ([wtsNoSuf,'.mat'])
            else
                [SAMHeader, ActIndex, ActWgts]=readWeights([wtsNoSuf,'.wts']);
                save([wtsNoSuf,'.mat'],'SAMHeader', 'ActIndex', 'ActWgts'); %save in mat format, quicker to read later.
            end
            
            % For a single subject, at a specific time window -
            % go over all trials, calculate fft for each trial and average the
            % results over trials
            for trlI = 1 : length(Data.trial)
                %disp(['trial ',num2str(trlI)]);
                if tStart(tI)+tw-1 >= length(Data.trial{1,trlI})
                    MEG1 = Data.trial{1,trlI}(:,tStart(tI):end);
                    tIstopFlag = 0;
                else
                    MEG1 = Data.trial{1,trlI}(:,tStart(tI):tStart(tI)+tw-1);
                end
                
                MEG1= double(MEG1);
                % general variables
                Fs = Data.fsample;                               % Sampling frequency
                T = 1/Fs;                                        % Sample time
                L = size(MEG1,2);                                % Length of signal
                t = (0:L-1)*T;                                   % Time vector
                NFFT = 2^nextpow2(L);                            % Next power of 2 from length of VS
                f = Fs/2*linspace(0,1,NFFT/2+1);
                if trlI == 1
                    MEGfft{subI,tI} = zeros(size(MEG1,1),NFFT);% frequencies vector
                end
                
                % MEG FFT, channel by channel
                for ch = 1:size(MEG1,1)
                    MEGfft{subI,tI}(ch,:) = MEGfft{subI,tI}(ch,:) + fft(MEG1(ch,:),NFFT,2);
                end
            end % for trlI ...
            MEGfft{subI,tI} =  MEGfft{subI,tI}/length(Data.trial);
            % find indices for requested frequency band
            fi1 = ft_nearest(f,f1)-1;
            if fi1 == 0
                fi1 = 1;
            end
            fi2 = ft_nearest(f,f2);
            for i = 1:size(ActWgts,1)
                if isequal(ActWgts(i,:),zeros(1,248))
                    %skipping VS outside the hull
                    Rs{subI}(i,tI) = 0;
                    continue
                end
                %         count the current VS
%                 disp(['VS ',num2str(i)]);
                %         calc the VS fft and PSD
                x = ActWgts(i,:)*squeeze(MEGfft{subI,tI});    % VS fft
                Pxx = abs(x).^2/L;            % calculating the VS PSD
                Rs{subI}(i,tI) = mean(Pxx(fi1:fi2));
            end % for i = ...
            
        end % for subI ...
    end % while tIstopFlag
    cd(DATA_ROOT)
    save(sprintf('Rs_%s_%s_cond%d',num2str(f1), num2str(f2), condNum(condI)), 'Rs');
    clear ActIndex ActWgts Data Fs L MEG1 MEGfft NFFT Pxx Rs SAMHeader T TypeName ch f fi1 fi2 i numTrl offsetT overlap samplingRate subI t tEnd tI tIstopFlag tMEG tStart trll tw wtsDir wtsNoSuf x
    for i=102:2108
        for j=[7:12 14:19 21 25:28]
            eval(['clear sub',num2str(j),'con',num2str(i)]);
        end
    end
    clear i j
end

% ============================ END FFT analysis =========================

%% write the data as a BRIK file for each subject
% ************************************************
condNum = [102:2:108];
for i=[1 2]
    condAct = condNum(i); % "1" for right hand and "2" for left hand
    condCtrl = condNum(i+2); % "3" for right hand and "4" for left hand

    cd(DATA_ROOT)
    fileNameAct = sprintf('Rs_%s_%s_cond%d',num2str(f1), num2str(f2), condAct)
    load(fileNameAct)
    RsAct = Rs;
    clear Rs
    fileNameCtrl = sprintf('Rs_%s_%s_cond%d',num2str(f1), num2str(f2), condCtrl)
    load(fileNameCtrl)
    RsCtrl = Rs;
    clear Rs

    samplingRate = 1017.25;
    tw = 200; % time window for fft (in samples)
    overlap = 190; % Samples for overlap
    tEnd = 662; % data length
    tStart = [1:tw-overlap:tEnd]; % vector defining index for the beginning of each time window
    offsetT = 0.150 % offset of the first sample from time 0 (in sec.)
    tMEG = (0:tw-overlap:tEnd)/samplingRate-offsetT; % time vector for MEG
    
    % define tlrc template path and smoothing
    smoothData = 1; % 1 - smooth the data, 0 - don't smooth
    for subI = 1 : numSubs
        % Generating the AFNI BRIK files
        cd(DATA_ROOT)
        cd(sprintf('%s',subjects{subI}))
        cfg1=[];
        cfg1.step=5;
        cfg1.boxSize=[-120 120 -90 90 -20 150];
        cfg1.prefix=fileNameAct;
        cfg1.torig=tMEG(1)*1000;% time of the first sample in ms (e.g. -100)
        cfg1.TR=1/(samplingRate/1000); % the difference between two samples in ms.
        VS2Brik(cfg1, RsAct{subI});
    
        cfg1=[];
        cfg1.step=5;
        cfg1.boxSize=[-120 120 -90 90 -20 150];
        cfg1.prefix=fileNameCtrl;
        cfg1.torig=tMEG(1)*1000;% time of the first sample in ms (e.g. -100)
        cfg1.TR=1/(samplingRate/1000); % the difference between two samples in ms.
        VS2Brik(cfg1, RsCtrl{subI});
    
        % move active and control functional data to tlrc according to template
        command = sprintf('@auto_tlrc -apar brain+tlrc -input %s+orig -dxyz 5', fileNameAct);
        unix(command, '-echo');
        command = sprintf('@auto_tlrc -apar brain+tlrc -input %s+orig -dxyz 5', fileNameCtrl);
        unix(command, '-echo');
        % smooth the data if specified
        if smoothData
            command = sprintf('3dmerge -1blur_sigma 10.0 -doall -prefix %s_blur_10mm %s+tlrc', fileNameAct, fileNameAct);
            unix(command,'-echo')
            command = sprintf('3dmerge -1blur_sigma 10.0 -doall -prefix %s_blur_10mm %s+tlrc', fileNameCtrl, fileNameCtrl);
            unix(command,'-echo')
        end % smooth data
    end
    
    
    %% ======================  Start Permutation Test ========================
    % do it twice. Once for Right hand (conds 102 % 106) and once for left hand (conds 104 & 108)
    cd(DATA_ROOT)
    load(sprintf('Rs_%s_%s_cond%d',num2str(f1), num2str(f2), condAct));
    % define Brik file names
    BrikNameAct =   sprintf('Rs_%s_%s_cond%d_blur_10mm+tlrc',num2str(f1), num2str(f2), condAct); 
    BrikNameCtrl =  sprintf('Rs_%s_%s_cond%d_blur_10mm+tlrc',num2str(f1), num2str(f2), condCtrl); 
    n = 200; % define number of permutations
    numSubs = length(subNum);
    
    
    timeWinI = 1; % length of time window in samples
    tThresh=3; % primary threshold for ttest !!!!!!!! should be between 3 to 4
    %partNum = 4; % division to parts
    trlLengthI = size(Rs{1},2); % get trial length
    tStart = 1 : timeWinI: trlLengthI; % vector for time windows
    tEnd = timeWinI : timeWinI : trlLengthI;
    % end initialization
    
    dirName=sprintf('%s/wholeBrainAfniStatFFTpowChange_%d_%dHz_conds%d_%d_%s_thresh_%s_n_%s',DATA_ROOT,f1,f2,condAct,condCtrl,strrep(date,'-','_'),num2str(tThresh),num2str(n));
    if ~exist(dirName,'dir')
        command = sprintf('mkdir %s', dirName);
        unix(command)
    end
    
    %% create average matrices for active and control conditions
    
    numTime = length(tStart);
    clustSize = cell(2,numTime);
    for timeI =  1 : numTime
        voxIend = 0;
        % generate a matrix for permutation test
        P = choose4PermutTrl(numSubs, n);
        fprintf('Starting permutation test for time window %s/%s \n', num2str(timeI), num2str(length(tStart)));
        cd(dirName)
    
        % Run the permutations
        clustSize{1,timeI}=zeros(n,2);
        if exist('tMinMax.txt','file')
            !rm tMinMax.txt
        end
        if exist('Post_Pre_Norm+tlrc.BRIK','file')
            !rm Post_Pre+tlrc*
        end
        if exist('neg+tlrc.BRIK','file')
            !rm neg+tlrc*
            !rm pos+tlrc*
        end
    
        for permi=1:n
            fprintf(['Permutation #',num2str(permi), ' in time window ', num2str(timeI),'\n']);
    
            if exist('TTnew+tlrc.BRIK','file')
                !rm TTnew+tlrc*
            end
    
            setA='-setA';
            setB='-setB';
            for subi= subNum
                if P(permi,subi) == subi
                    setA= [setA, ' ' ,sprintf('%s/%s/', DATA_ROOT, subjects{subi}), BrikNameAct,'''','[',num2str(timeI-1),']',''''];
                    setB= [setB, ' ' ,sprintf('%s/%s/', DATA_ROOT, subjects{subi}), BrikNameCtrl,'''','[',num2str(timeI-1),']',''''];
                else
                    setA= [setA, ' ' ,sprintf('%s/%s/', DATA_ROOT, subjects{subi}), BrikNameCtrl,'''','[',num2str(timeI-1),']',''''];
                    setB= [setB, ' ' ,sprintf('%s/%s/', DATA_ROOT, subjects{subi}), BrikNameAct,'''','[',num2str(timeI-1),']',''''];
                end
            end
            % next two lines run 3dttest++, one permutation
            command = ['3dttest++ -paired -no1sam -mask ~/SAM_BIU/docs/MASKbrain+tlrc -prefix ', dirName,  '/TTnew ',setA,' ',setB];
            [~, ~] = unix(command,'-echo');
    
            % read min and max t value
            !3dBrickStat -min -max TTnew+tlrc'[1]' >> tMinMax.txt
            % compute volume of largest positive and negative clusters
            eval(['!3dcalc -a TTnew+tlrc''','[1]''',' -exp ''','ispositive(a-',num2str(tThresh),')*a''',' -prefix pos'])
            eval(['!3dcalc -a TTnew+tlrc''','[1]''',' -exp ''','isnegative(a+',num2str(tThresh),')*a''',' -prefix neg'])
            eval(['!3dclust -quiet -1clip ',num2str(tThresh),' 5 125 neg+tlrc > negClust.txt'])
            eval(['!3dclust -quiet -1clip ',num2str(tThresh),' 5 125 pos+tlrc > posClust.txt'])
            negClust=importdata('negClust.txt');
            posClust=importdata('posClust.txt');
            if iscell(negClust) || isempty(negClust)
                negClustSize=0;
            else
                negClustSize=negClust(1)/125;
            end
            if iscell(posClust) || isempty(posClust)
                posClustSize=0;
            else
                posClustSize=posClust(1)/125;
            end
            clustSize{1,timeI}(permi,1:2)=[negClustSize,posClustSize];
            !rm neg+tlrc*
            !rm pos+tlrc*
            !rm *Clust.txt
        end
    
        % take the 5% extreme (max and -1*min) t values as criticat t
        tList=importdata('tMinMax.txt');
        tList=[-tList(:,1);tList(:,2)];
        tList=sort(tList,'descend');
        critT=tList(ceil(0.05*n*2));
        clustSize{2,timeI} = critT;
        save clustSize clustSize tList
        !rm tMinMax.txt
    
        % perform the real ttest
        setA='-setA';
        setB='-setB';
        for subi= subNum
            setA= [setA, ' ' ,sprintf('%s/%s/', DATA_ROOT, subjects{subi}), BrikNameAct,'''','[',num2str(timeI-1),']',''''];
            setB= [setB, ' ' ,sprintf('%s/%s/', DATA_ROOT, subjects{subi}), BrikNameCtrl,'''','[',num2str(timeI-1),']',''''];
        end
        % next two lines run 3dttest++, one permutation
        command = ['3dttest++ -paired -no1sam -mask ~/SAM_BIU/docs/MASKbrain+tlrc -prefix ', dirName, '/realTTest', num2str(timeI),' ',setA,' ',setB];
        [~, ~] = unix(command,'-echo');
    
        % now open AFNI and view Post_Pre+tlrc.
        % to see if you have sig voxels check the range of the overlay (see arrow0). Note, there
        % are two images there, means difference (brik[0]) and t values (brik[1]).
        % choose [1] in Define Overlay (Arrow1).
        % to see if you have large clusters set the threshold to tThresh (arrow with no number), click on
        % clusterize (arrow2), set (arrow3), Rpt (arrow4). Look at the list for
        % cluster size (arrow6).
        %     !~/abin/afni -dset ~/SAM_BIU/docs/temp+tlrc
    
    end
    
    %% After the permutation test, find which clusters exceeded the 95% percentile of the maximal cluster distribution
    
    cd(dirName)
    load clustSize
    clustSizeNew = clustSize;
    numT = size(clustSizeNew,2);%size(clustSizeNew, 2);
    
    [row, col] = find(~cellfun(@isempty,clustSizeNew));
    fullCol = unique(col)';
    
    for timeI = fullCol
    
        clustSizeNew{1,timeI}=[clustSizeNew{1,timeI}(:,1);clustSizeNew{1,timeI}(:,2)];
        clustSizeNew{1,timeI}=sort(clustSizeNew{1,timeI},'descend');
        % take the 5% greatest volumes (in voxels) as critical cluster size
        critClustSize=clustSizeNew{1,timeI}(ceil(0.05*n*2));
        clustSizeNew{3,timeI} = critClustSize;
    
    end
    
    save clustSizeNew clustSizeNew
    
    realClustSize = zeros(1,numT);
    !rm ROIclustTTest.txt
    fid = fopen('ROIclustTTest.txt','a+');
    for timeI = fullCol
        %     command = sprintf('~/abin/3dclust -1clip 4 5 -%s realTTest%s+tlrc[1] > clustTTest%s.1D', num2str(clustSizeNew{3,timeI}), num2str(timeI), num2str(timeI));
        command = sprintf('3dclust -1clip %s 5 -%s realTTest%s+tlrc[1] > clustTTest%s.1D', num2str(tThresh), num2str(clustSizeNew{3,timeI}),  num2str(timeI), num2str(timeI));
        [status, result] = unix(command,'-echo');
        command = sprintf('whereami -coord_file clustTTest%s.1D[1,2,3] -tab -atlas TT_Daemon', num2str(timeI));
        [status, result] = unix(command,'-echo');
        fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX %s\n\n %s\n\n\n', num2str(timeI), result));
    
        % read min and max t value
        !3dBrickStat -min -max TTnew+tlrc'[1]' >> tMinMax.txt
        % compute volume of largest positive and negative clusters
        eval(['!3dcalc -a realTTest', num2str(timeI), '+tlrc''','[1]''',' -exp ''','ispositive(a-',num2str(tThresh),')*a''',' -prefix pos'])
        eval(['!3dcalc -a realTTest', num2str(timeI), '+tlrc''','[1]''',' -exp ''','isnegative(a+',num2str(tThresh),')*a''',' -prefix neg'])
        eval(['!3dclust -quiet -1clip ',num2str(tThresh),' 5 125 neg+tlrc > negClust.txt'])
        eval(['!3dclust -quiet -1clip ',num2str(tThresh),' 5 125 pos+tlrc > posClust.txt'])
        negClust=importdata('negClust.txt');
        posClust=importdata('posClust.txt');
        if iscell(negClust) || isempty(negClust)
            negClustSize=0;
        else
            negClustSize=negClust(1)/125;
        end
        if iscell(posClust) || isempty(posClust)
            posClustSize=0;
        else
            posClustSize=posClust(1)/125;
        end
        realClustSize(1,timeI) = max([negClustSize,posClustSize]);
        !rm neg+tlrc*
        !rm pos+tlrc*
        !rm *Clust.txt
    
    end
    
    fclose(fid);
    
    %% show a curve of maximal cluster size and critical cluster size
    samplingRate = 1017.25;
    tw = 200; % time window for fft (in samples)
    overlap = 190; % Samples for overlap
    tEnd = 662; % data length
    tStart = [1:tw-overlap:tEnd]; % vector defining index for the beginning of each time window
    offsetT = 0.150 %
    timeWinS = -offsetT:(tw-overlap)/samplingRate:((tEnd-round(offsetT*samplingRate)-overlap)/samplingRate);
    
    critCS = zeros(1,numT);
    Fband = bandPass{covI};
    for  cI = fullCol
        critCS(cI) = clustSizeNew{3,cI};
    end
    
    figure
    plot(timeWinS, critCS,'b-o')
    hold on
    plot(timeWinS, realClustSize, 'r-o')
    set(gca, 'fontsize', 14)
    legend('Permutation', 'Real')
    xlabel('Time, Sec.')
    ylabel('Cluster Size')
    title(sprintf('Permutation Test Clusters FFT Power Change FB = %s-%s, n = %s, T = %s', num2str(f1), num2str(f2), num2str(n), num2str(tThresh)))
    saveas(gcf, sprintf('FFTpowChangeClust_%s_%s_n%s_T%s.fig', num2str(f1), num2str(f2), num2str(n), num2str(tThresh)));
    saveas(gcf, sprintf('FFTpowChangeClust_%s_%s_n%s_T%s.png', num2str(f1), num2str(f2), num2str(n), num2str(tThresh)));
    
    figure
    plot(critCS,'b-o')
    hold on
    plot(realClustSize, 'r-o')
end

%%


% =========== 8< ================ End of Script ================ 8< ================



%%

% --------------   check for consistancy across subjects -----------------
clear
load Rs_8_12_cond102
RsAct=Rs;
load Rs_8_12_cond106
RsCtrl=Rs;

Rs102=zeros(14,1);
Rs106=zeros(14,1);

for i=1:14
    Rs102(i)=mean(mean(RsAct{i}(RsAct{i}(:,1) ~= 0,11:22),1)); % change 35:39 according to time windows of interest
    Rs106(i)=mean(mean(RsCtrl{i}(RsCtrl{i}(:,1) ~= 0,11:22),1)); % change 35:39 according to time windows of interest
end

figure
plot(Rs102,'o')
hold on
plot(Rs106,'or');

% ---------------   move files without BL to 'RsFilesNoBL' folder --------
DATA_ROOT = '/home/meg/Data/Maor/Hypnosis/Subjects';
subjects = {'Hyp7','Hyp8','Hyp9','Hyp10','Hyp11','Hyp12','Hyp14','Hyp15','Hyp16','Hyp17','Hyp18','Hyp19','Hyp21','Hyp25','Hyp26','Hyp27','Hyp28'};
for i = 1:length(subjects)
    cd(sprintf('%s/%s',DATA_ROOT,subjects{i}));
    movefile('Rs_1_40*', 'RsfilesNoBL/');
end





%% ============ Show results after analysis is finished ===================
clear
close all
clc

DATA_ROOT = '/home/meg/Data/Maor/Hypnosis/Subjects';
cd(DATA_ROOT)
dirName = 'wholeBrainAfniStatFFTpowChange_8_12Hz_conds104_108_21_Jan_2015_thresh_3_n_200';

% initialize for this run
n = 200; % define number of permutations
tThresh = 3;
% define frequency band for analysis
f1 = 8;
f2 = 12;
% end initialization

cd(dirName)
load clustSize
clustSizeNew = clustSize;
numT = size(clustSizeNew,2);
[row, col] = find(~cellfun(@isempty,clustSizeNew));
fullCol = unique(col)';

for timeI = fullCol

    clustSizeNew{1,timeI}=[clustSizeNew{1,timeI}(:,1);clustSizeNew{1,timeI}(:,2)];
    clustSizeNew{1,timeI}=sort(clustSizeNew{1,timeI},'descend');
    % take the 5% greatest volumes (in voxels) as critical cluster size
    critClustSize=clustSizeNew{1,timeI}(ceil(0.05*n));
    clustSizeNew{3,timeI} = critClustSize;

end

save clustSizeNewFix clustSizeNew

realClustSize = zeros(1,numT);
!rm ROIclustTTestFix.txt
fid = fopen('ROIclustTTestFix.txt','a+');
for timeI = fullCol
    %     command = sprintf('~/abin/3dclust -1clip 4 5 -%s realTTest%s+tlrc[1] > clustTTest%s.1D', num2str(clustSizeNew{3,timeI}), num2str(timeI), num2str(timeI));
    command = sprintf('3dclust -1clip %s 5 -%s realTTest%s+tlrc[1] > clustTTestFix%s.1D', num2str(tThresh), num2str(clustSizeNew{3,timeI}),  num2str(timeI), num2str(timeI));
    [status, result] = unix(command,'-echo');
    command = sprintf('whereami -coord_file clustTTestFix%s.1D[1,2,3] -tab -atlas TT_Daemon', num2str(timeI));
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX %s\n\n %s\n\n\n', num2str(timeI), result));

    % read min and max t value
    !3dBrickStat -min -max TTnew+tlrc'[1]' >> tMinMax.txt
    % compute volume of largest positive and negative clusters
    eval(['!3dcalc -a realTTest', num2str(timeI), '+tlrc''','[1]''',' -exp ''','ispositive(a-',num2str(tThresh),')*a''',' -prefix pos'])
    eval(['!3dcalc -a realTTest', num2str(timeI), '+tlrc''','[1]''',' -exp ''','isnegative(a+',num2str(tThresh),')*a''',' -prefix neg'])
    eval(['!3dclust -quiet -1clip ',num2str(tThresh),' 5 125 neg+tlrc > negClust.txt'])
    eval(['!3dclust -quiet -1clip ',num2str(tThresh),' 5 125 pos+tlrc > posClust.txt'])
    negClust=importdata('negClust.txt');
    posClust=importdata('posClust.txt');
    if iscell(negClust) || isempty(negClust)
        negClustSize=0;
    else
        negClustSize=negClust(1)/125;
    end
    if iscell(posClust) || isempty(posClust)
        posClustSize=0;
    else
        posClustSize=posClust(1)/125;
    end
    realClustSize(1,timeI) = max([negClustSize,posClustSize]);
    !rm neg+tlrc*
    !rm pos+tlrc*
    !rm *Clust.txt

end

fclose(fid);

% plot results
timeWinS = -0.8:0.02:1.36;
critCS = zeros(1,numT);
for  cI = fullCol
    critCS(cI) = clustSizeNew{3,cI};
end

figure
plot(timeWinS, critCS,'b-o')
hold on
plot(timeWinS, realClustSize, 'r-o')
set(gca, 'fontsize', 14)
legend('Permutation', 'Real')
xlabel('Time, Sec.')
ylabel('Cluster Size')
title(sprintf('Permutation Test Clusters FFT Power Change FB = %s-%s, n = %s, T = %s', num2str(f1), num2str(f2), num2str(n), num2str(tThresh)))
saveas(gcf, sprintf('FFTpowChangeClustFix_%s_%s_n%s_T%s.fig', num2str(f1), num2str(f2), num2str(n), num2str(tThresh)));
saveas(gcf, sprintf('FFTpowChangeClustFix_%s_%s_n%s_T%s.png', num2str(f1), num2str(f2), num2str(n), num2str(tThresh)));

%% presenting the functional data in Suma

% copy into the folder "/home/meg/SAM_BIU/docs/templateSurface" the files I want to present. 
% open terminal and cd to the folder and then:
% afni -niml -dset temp+tlrc &
% suma -spec temp_both.spec -sv temp+tlrc

% click somewhere on the suma and press 't'
% with < > [ ] buttons I can do magic.
% type ctrl+h for the list of shortcuts.


%% mask cortex only
masktlrc('prePost_RL_19subs+tlrc','MASKctx+tlrc','_ctx');