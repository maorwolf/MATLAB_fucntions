% Moran's script

%% creat ROI masks


!3dclust -1Dformat -savemask msk -nosum -1dindex 1 -1tindex 1 -2thresh -2.044 2.044 -dxyz=1 1.01 20 dataFile.HEAD
!whereami -mask_atlas_region TT_Daemon:left:Superior_Frontal_Gyrus -prefix LSFG
!3dresample -dxyz 5 5 5 -prefix rsLSFG -inset LSFG+tlrc -rmode Cu
!3dcalc -prefix LSFGclust -a msk+tlrc -b rsLSFG+tlrc -exp 'a*b'



%% find max voxel and mean cluster values in ROI using the masks created in "createROImask"


allPath = '/media/Tera_/DataMEG2/cleanDataDec262011/tlrcFiles/MOI';
masksPath = '/media/Tera_/DataMEG2/cleanDataDec262011/tlrcFiles/tTests/PL/';
counter = 0;

mskFile = [masksPath 'msk+tlrc'];

dataFileName = 'rest_alpha';

frequency = 'alpha';

region = {'LMFG' 'LSFG' 'LMidFG' };

condition = {'OT' 'PL'};

allSubs = {
    '701' '702' '703' '704' '705' '707' '708' '720' '727' '729' '738' '740' '742' '743'...
    '709' '712' '713' '715' '716' '717' '719' '721' '723' '725' '726' '731' '734' '735' '737'...
    '706' '710' '711' '714' '718' '724' '732' '733' '739' '741' '744'};




for i = 1:length(allSubs);
    
    subPath = [allPath allSubs{i}];
     totalOut = {};
           
    for regionNum = 1:length(region)
        ROI = region{regionNum};
        
        regionMaskFile = [masksPath ROI 'clust+tlrc'];
        
        for conditionNum = 1:length(condition)
            condish = condition{conditionNum};
            
            % calculate average using '3dmaskave'
            dataFile = [subPath '/' dataFileName '_' condish '+tlrc'];
            out = evalc(['!~/abin/3dmaskave' ' -mask '  regionMaskFile ' ' dataFile '''[0]''']);
            
            result_a = regexp(out,'(?m)^([+-]?[.0-9]+)\s+','tokens');
            result_a =  result_a{:};
            result_a_name = [ROI '_' condish '_res_a'];
            eval([result_a_name ' = result_a']);
            
            %complete loop for maximal voxel calculation (see below)
            totalOut(conditionNum+counter) =  [result_a];
%          
            
        end
        counter = counter + 2;
    end
    totalOut = [allSubs{i} totalOut];
    totalOutName = ['MOI' allSubs{i} 'results_' frequency];
    eval([totalOutName ' = totalOut']);
    fileName = [subPath '/' totalOutName];
    save(fileName, totalOutName) ;
    counter = 0;
    
end

% prepare results table 

title = {
    
'sub' 'MFG_OT_avg'  'MFG_PL_avg' 'SFG_OT_avg' 'SFG_PL_avg' 'MidFG_OT_avg'  'MidFG_PL_avg'};


allResults_alpha = [title; MOI701results_alpha; MOI702results_alpha; MOI703results_alpha; MOI704results_alpha; MOI705results_alpha; MOI707results_alpha;...
    MOI708results_alpha; MOI720results_alpha; MOI727results_alpha; MOI729results_alpha; MOI738results_alpha; MOI740results_alpha;...
    MOI742results_alpha; MOI743results_alpha; MOI709results_alpha; MOI712results_alpha; MOI713results_alpha; MOI715results_alpha;...
    MOI716results_alpha; MOI717results_alpha; MOI719results_alpha; MOI721results_alpha; MOI723results_alpha; MOI725results_alpha;...
    MOI726results_alpha; MOI731results_alpha; MOI734results_alpha; MOI735results_alpha; MOI737results_alpha; MOI706results_alpha;...
    MOI710results_alpha; MOI711results_alpha; MOI714results_alpha; MOI718results_alpha; MOI724results_alpha; MOI732results_alpha;...
    MOI733results_alpha; MOI739results_alpha; MOI741results_alpha; MOI744results_alpha];
%save /media/Tera_/DataMEG2/cleanDataDec262011/tlrcFiles/sourceResultsFiles/allResults_delta allResults_delta




%calculate maximal (m) voxel in each ROI using '3dExtrema'


% out = evalc(['!~/abin/3dExtrema' ' -maxima' ' -closure' ' -sep_dist 1000' ' -volume' ' -mask_file ' maskFile ' -mask_thr 0.95 ' dataFile '''[0]''']);
% res_m = regexp(out,'(?m)^\s+([+-.0-9]+)\s+([+-.0-9]+)\s+([+-.0-9]+)\s+([+-.0-9]+)\s+([+-.0-9]+)\s+([+-.0-9]+)\s*$','tokens');
% res_m = res_m{:};
% 


% title = {
%     'sub' 'indx' 'MFG_OT_max' 'x' 'y' 'z' 'count' ...
%         'indx' 'MFG_PL_max' 'x' 'y' 'z' 'count' ...
%         ' indx' 'SFG_OT_max' 'x' 'y' 'z' 'count' ...
%         ' indx' 'SFG_PLmax' 'x' 'y' 'z' 'count'  ...
%         ' indx' 'frontal_OT_max' 'x' 'y' 'z' 'count' ...
%         'indx ' 'frontal_PL_max' 'x' 'y' 'z' 'count' ...
%         'MFG_OT_avg'  'MFG_PL_avg' 'SFG_OT_avg' 'SFG_PL_avg' 'MidFG_OT_avg'  'MidFG_PL_avg' 'frontal_OT_avg' 'frontal_PL_avg'};%for alpha, avg and max vals.



