%% Script to calculate Phase Lag Index according to:
%% Hillebrand et al. Frequency-dependent .... 2012
% 1 - load wts and FT data
% 2 - Calculate FFT for each trial for a given time window at the sensor
%     level and the average the results over all trials
% 3 - multiply wts*avgDataFFT for each virtual sensor
% 4 - average the mean power across a certain frequency band
% 5 - write into a Brik file the averaged power change for each subject
% 6 - perform permutations on the results

% define directories
DATA_ROOT= '/home/idan/Desktop/data_rhythm'; %'/media/MyPassport/ElementsBackup/MEGanalysis_new/data_rhythm';
cd(DATA_ROOT)
if ~exist('PLI','dir')
   mkdir('PLI');
end
dataTrlDir = sprintf('%s/PLI/dataTrl', DATA_ROOT);
runDir = 'run17';
% define tlrc template path and smoothing
templatePath = '/media/MyPassport/ElementsBackup/MEGanalysis_new/data_rhythm/warped+tlrc'; % Name of the template to use for tlrc
% end - define directories


subNum = 3;

condName = {'CHANGE'};
covDir = {
    'SAM/expSAM_CHANGE_LAST_VS_5_15,5-15Hz',...
    'SAM/expSAM_CHANGE_LAST_VS_15_25,15-25Hz',...
    'SAM/expSAM_CHANGE_LAST_VS_25_35,25-35Hz',...
    'SAM/expSAM_CHANGE_LAST_VS_35_45,35-45Hz',...
    'SAM/expSAM_CHANGE_LAST_VS_1_40,1-40Hz',...
    };
% bandPass = {[5 15], [15 25], [25 35], [35 45], [1 40]};
subI = 3;
FTdataName = 'data1'; % name of the variable that holds the FT structure of the data of one condition (not the name of the file)
% define frequency band for analysis
fA1 = 8;
fA2 = 12;

%% ===================== Use FFT at the sensor level and then multiply by the wts ===============================================

% initialize for this run
samplingRate = 508.625;
% index for condition name (according to condNames)
covI = 5;  % index for covariance name (according to covDir)
tw = 200; % time window for fft (in samples)
overlap = 190; % Samples for overlap
tEnd = 1272; % data length
tStart = [1:tw-overlap:tEnd]; % vector defining index for the beginning of each time window
offsetT = 1; % offset of the first sample from time 0 (in sec.)
tMEG = (0:tw-overlap:tEnd)/samplingRate-offsetT; % time vector for MEG
wtsDir = '~/Desktop/data_rhythm'; % data path for the wts file
MEGfft = cell(1, 1);
% Rs = cell(1, 10);

% end initialization
condI = 1;
%% ================= Start FFT analysis =========================
cd(sprintf( ['%s/%d'], DATA_ROOT, subI));
TypeName = condName{condI};
% load FT data
if exist(sprintf('/media/MyPassport/ElementsBackup/MEGanalysis_new/data_rhythm/%s/run17/%s.mat',num2str(subI), TypeName), 'file')
    fprintf('Loading /media/MyPassport/ElementsBackup/MEGanalysis_new/data_rhythm/%s/run17/%s.mat\n',num2str(subI), TypeName)
    load(sprintf('/media/MyPassport/ElementsBackup/MEGanalysis_new/data_rhythm/%s/run17/%s.mat',num2str(subI), TypeName))
    Data = data1;
    %                 cfg = [];
    %                 cfg.bpfilter = 'yes';
    %                 cfg.bpfreq = bandPass{covI};
    %                 Data = ft_preprocessing(cfg,Data);
    numTrl = length(Data.trial);
    clear data1
else
    error('Data not found')
end

% reading the wts
wtsNoSuf =sprintf('%s/%d/%s,Sum', wtsDir, subI, covDir{covI});% name of the wts
if exist([wtsNoSuf,'.mat'],'file')
    load ([wtsNoSuf,'.mat'])
else
    [SAMHeader, ActIndex, ActWgts]=readWeights([wtsNoSuf,'.wts']);
    save([wtsNoSuf,'.mat'],'SAMHeader', 'ActIndex', 'ActWgts'); %save in mat format, quicker to read later.
end


for trlI = 1 : numTrl
    disp(['trial ',num2str(trlI)]);
    cd(sprintf( ['%s/%d'], DATA_ROOT, subI));
    
    
    % For a single subject,  -
    % go over all trials, calculate fft for each trial and average the
    % results over trials
    MEG1 = Data.trial{1,trlI};
    % general variables
    Fs = Data.fsample;                               % Sampling frequency
    T = 1/Fs;                                        % Sample time
    L = size(MEG1,2);                                % Length of signal
    t = (0:L-1)*T;                                   % Time vector
    NFFT = 2^nextpow2(L);                            % Next power of 2 from length of VS
    f = Fs/2*linspace(0,1,NFFT/2+1);
    

    MEGfft{trlI} = zeros(size(MEG1,1),NFFT);
    % only in the first trial define the matrix that holds the avg fft
    if trlI == 1
        avgMEGfft = zeros(size(MEG1,1),NFFT);
    end
    % MEG FFT, channel by channel
    for ch = 1:size(MEG1,1)
        MEGfft{trlI}(ch,:) = fft(MEG1(ch,:),NFFT,2);
        avgMEGfft(ch,:) = avgMEGfft(ch,:) + fft(MEG1(ch,:),NFFT,2);
    end
end % for trlI ...


avgMEGfft =  avgMEGfft/length(Data.trial);

% find indices the requested frequencies from the fft
fi1 = ft_nearest(f,fA1);
fi2 = ft_nearest(f,fA2);
for i = 1:size(ActWgts,1)
    if isequal(ActWgts(i,:),zeros(1,248))
        %skipping VS outside the hull
        meanPowVS(i,1) = 0;
        continue
    end
    %         count the current VS
    %                 disp(['VS ',num2str(i)]);
    %         calc the VS fft and PSD
    x = (ActWgts(i,:)*avgMEGfft)./norm(ActWgts(i,:));    % VS fft
    Pxx = abs(x).^2/L;            % calculating the VS PSD
    meanPowVS(i,1) = mean(Pxx(fi1:fi2));
end % for i = ...

% save the variables from this run
cd PLI
save(sprintf('meanPowVS_%d_%d', fA1, fA2), 'meanPowVS', 'avgMEGfft', 'MEGfft')


%% write the data as a BRIK file for each subject
cd(DATA_ROOT)
cd PLI
brikFileName = sprintf('meanPowVSnorm_%s_%s_%s',num2str(fA1), num2str(fA2), condName)

cfg1=[];
cfg1.step=5;
cfg1.boxSize=[-120 120 -90 90 -20 150];
cfg1.prefix=brikFileName;
VS2Brik(cfg1, meanPowVS);

% move mean functional data to tlrc according to template
command = sprintf('@auto_tlrc -apar %s  -input %s+orig -dxyz 5', templatePath, brikFileName);
unix(command, '-echo');

%% create a signal at a certain ROI
% Multiply the tlrc Brik files by the mask of each ROI
maskPath = '/home/idan/Desktop/data_rhythm/maskCortex'; % PUT IN LAB_FILES
% Name and path of the MEG functional data (in AFNI format)
dataName = '/home/idan/Desktop/data_rhythm/PLI/meanPowVSnorm_8_12_CHANGE+tlrc';

% make list of ROIs according to the list in the directory of the mask 
% NOTE: only regions with 'left' or 'right' are included 
cd(maskPath)
list = ls;

pat = '\s+';
s = regexp(list, pat, 'split');
a=1;
masksList = cell(round(length(s)/2), 1);
for strIndx=1:length(s)
    if ~isempty(strfind(s{strIndx},'BRIK')) && (~isempty(strfind(s{strIndx},'left')) || ~isempty(strfind(s{strIndx},'right')))
        masksList{a} = strrep(s{strIndx}, '.BRIK', '');
        a=a+1;
    end  
end
masksList = masksList(1:a-1);

% create BRIK files of FFT functional data for each ROI
for regI = 1 : length(masksList)
    region = masksList{regI};
    % resample the mask
    command = sprintf('3dresample -dxyz 5 5 5 -prefix rs_%s -inset %s -rmode Cu', region, region);
    unix(command,'-echo')
    % Normalize mask to 1
    command = sprintf('3dcalc -a rs_%s -b rs_%s -prefix norm_%s -expr a/b',region,region,region)
    unix(command,'-echo')
    % multiply data by the ROI mask
    command = sprintf('3dcalc -a %s -b norm_%s -prefix %s_%s -expr a*b', dataName, region, dataName, region)
    unix(command,'-echo')
    
    !rm norm_*[err, V, Info, ErrMessage] = BrikLoad(BrikName, Opt);
    !rm rs_*
end

%% =========== extracting the voxel with maximum power for each ROI =================
regStruct.regionName = masksList';                          % Names of the regions
regStruct.ROIvoxInd = cell(1,length(masksList));            % All the voxel indices for each ROI
regStruct.maxROIvoxOrigInd = zeros(1,length(masksList));    % Original index of the voxel with maximal power for each ROI
regStruct.maxROIvoxNewInd = zeros(1,length(masksList));     % New index (after deleting zeros) of each voxel


Opt.Format = 'vector';
for regI = 1:length(masksList)
    BrikName = sprintf('%s_%s', dataName, masksList{regI});
    [err, V, Info, ErrMessage] = BrikLoad(BrikName, Opt);
    regStruct.ROIvoxInd{regI} = find(V);
    [val,regStruct.maxROIvoxOrigInd(regI)] = max(V);  
    Vreg = V(regStruct.ROIvoxInd{regI});
    [val,regStruct.maxROIvoxNewInd(regI)] = max(Vreg);  
end

% *********** Finished selecting one voxel from each ROI **************

%% ================== Create hilbert transform and calculate phase for each of the selected voxels ===================
% 1. Read the wts and the data, multiply them and write as BRIK files
% 2. Read the BRIK files, take the selected voxel according to regStruct
% 3. perform hilbert transform on the selected voxel
% 4. Calculate phase

cd(sprintf( ['%s/%d'], DATA_ROOT, subI));
TypeName = condName{condI};
% load FT data
if exist(sprintf('/media/MyPassport/ElementsBackup/MEGanalysis_new/data_rhythm/%s/run17/%s.mat',num2str(subI), TypeName), 'file')
    fprintf('Loading /media/MyPassport/ElementsBackup/MEGanalysis_new/data_rhythm/%s/run17/%s.mat\n',num2str(subI), TypeName)
    load(sprintf('/media/MyPassport/ElementsBackup/MEGanalysis_new/data_rhythm/%s/run17/%s.mat',num2str(subI), TypeName))
    eval(sprintf('Data = %s', FTdataName));
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [fA1 fA2];
    Data = ft_preprocessing(cfg,Data);
    numTrl = length(Data.trial);
    clear data1
else
    error('Data not found')
end

% reading the wts
wtsNoSuf =sprintf('%s/%d/%s,Sum', wtsDir, subI, covDir{covI});% name of the wts
if exist([wtsNoSuf,'.mat'],'file')
    load ([wtsNoSuf,'.mat'])
else
    [SAMHeader, ActIndex, ActWgts]=readWeights([wtsNoSuf,'.wts']);
    save([wtsNoSuf,'.mat'],'SAMHeader', 'ActIndex', 'ActWgts'); %save in mat format, quicker to read later.
end

trlLen = length(Data.trial{1});
cd(DATA_ROOT)
cd PLI

if ~exist(dataTrlDir, 'dir')
   mkdir(dataTrlDir) 
end
cd(dataTrlDir)
% Create VS for each trial, and choose the voxel of interest from each ROI
for trlI = 1 : numTrl
    disp(['trial ',num2str(trlI)]);
    %     cd(sprintf( ['%s/%d'], DATA_ROOT, subI));
    normWts = zeros(size(ActWgts,1), trlLen); 
    for i = 1:size(ActWgts,1)
        normWts(i,:) = norm(ActWgts(i,:));
    end
    VS = (ActWgts*Data.trial{trlI})./normWts;    % VS fft
    cfg1=[];
    cfg1.step=5;
    cfg1.boxSize=[-120 120 -90 90 -20 150];
    cfg1.prefix=sprintf('%s_freq%d_%d_trl%d', TypeName, fA1, fA2, trlI);
    cfg1.torig=tMEG(1)*1000;% time of the first sample in ms (e.g. -100)
    cfg1.TR=1/(samplingRate/1000); % the difference between two samples in ms.
    VS2Brik(cfg1, VS);
    % move active and control functional data to tlrc according to template
    command = sprintf('@auto_tlrc -apar %s  -input %s+orig -dxyz 5', templatePath, cfg1.prefix);
    unix(command, '-echo');
    % read the BRIK
    Opt.Format = 'vector';
    BrikName = sprintf('%s+tlrc', cfg1.prefix);
    [err, V, Info, ErrMessage] = BrikLoad(BrikName, Opt);
    % take the signal from the selected voxel of interest for each ROI
    regStruct.VStrlMaxVox{trlI} = V(regStruct.maxROIvoxOrigInd,:);
    command = sprintf('rm %s*', cfg1.prefix);
    unix(command,'-echo');
end % for trlI ...


