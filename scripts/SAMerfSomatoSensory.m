%% SAMerf
% -------------------------------------------------------------------------
%% 1. creating marker files for all subs (do it once!)
for i = [7:12,14:19,21,25:28]
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz']);
    eval(['load sub',num2str(i),'datafinalsplit']);
    for j = 102:2:108
        eval(['con',num2str(j),'=((sub',num2str(i),'con',num2str(j),'.sampleinfo(sub',num2str(i),'con',num2str(j),'.trialinfo == ',num2str(j),',1)+153)./1017.25)'';']);
    end
    eval(['all = ((sub',num2str(i),'con102.sampleinfo(:,1)+153)./1017.25)'';']);
    cd ..
    Trig2mark('all',all,'preRightIndex',con102,'preLeftIndex',con104,'postRightIndex',con106,'postLeftIndex',con108);
    eval(['clear con102 con104 con106 con108 all j ans sub',num2str(i),'con102 sub',num2str(i),'con104 sub',num2str(i),'con106 sub',num2str(i),'con108']);
end;

cd ..
clear all
% -------------------------------------------------------------------------
%% 2. fit individual MRI to HS
% 2.1 open terminal and cd to the MRI files of the subject

% 2.2 type: "to3d ___*" (where ___ is the prefix of the MRI slices names)

% 2.3 in the window that automaticly opens write the folder path of the main folder of the subject (starting: "/home/meg/...") at the
% buttom and the output file name - "anat". save and close

% 2.4 tagalign:
% 2.4.1 copy into the sub folder the file MNI305.tag and change the name of
% the file to the "subsname".tag
% 2.4.2 Now we type afni in the terminal window. Choose 'underlay' as anat file
% Press: 'Define data mode' => 'plugin' => 'edit tagset' => 'dataset' => 'anat'
% Write in 'tag file' the "subsname".tag, and press 'read' button
% click on Nasion, mark the location on the MRI and press 'set'. repeat for
% LP and RP.
% When done with all three click on 'write' (it will write the new
% locations to the subname.tag file, then click on 'save' (it will save
% these locations in the anat file, and finally click on 'done' to finish.
% 2.4.3 now from MATLAB run the commend:
!/home/meg/abin/3dTagalign -master /home/meg/brainhull/master+orig -prefix ./ortho anat+orig
% The last stage aligned the fiducial points you just marked on the MRI with 
% the fiducial points marked doing digitization
% The function's output are ortho+orig HEAD and BRIK files – these will be later used for nudgnig

% if using template MRI start here:
fitMRI2hs('c,rfhp0.1Hz')

% 2.4.4 in MATLAB run:
hs2afni() % creating HS+orig files

% 2.5 Nudging:
% ------------
% 2.5.1 from the terminal open afni and define: overlay = hs, underlay = ortho
% 2.5.2 go to Define datamode > plugins > nudge dataset
% 2.5.3 click on "choose dataset" and choose "ortho"
% 2.5.4 now nudge. Chhose ortho as dataset and when you are done type "do
% all" and then quit.

% 2.6 creating hull file:
!~/abin/3dSkullStrip -input ortho+orig -prefix mask -mask_vol -skulls -o_ply ortho
% 2.6.1 if using template MRI:
!~/abin/3dSkullStrip -input warped+orig -prefix mask -mask_vol -skulls -o_ply ortho

% if massive chunks missing consider adding one of these options:
% before 3dSkullStrip run the next line:
% !~/abin/3dUnifize -prefix ortho_unshaded ortho+orig
% and then:
% !~/abin/3dSkullStrip -input ortho_unshaded+orig -prefix mask -mask_vol -skulls -o_ply ortho -blur_fwhm 2
% or together with 3dSkullStrip run:
% -ld 30
% or
% -blur_fwhm 2 % play with the number (up and down)
% or
% -blur_fwhm 2 -avoid_vent -avoid_vent -init_radius 75

% 2.7 in the terminal type: "afni -niml &"
% 2.7.1 define: overlay = mask, underlay = ortho
% 2.7.2 in the terminal type: "suma -niml -i_ply ortho_brainhull.ply -sv mask+orig -novolreg"
% 2.7.3 go to the suma window and click on "t". Check that there is a good fit

% 2.8 creating brain file: in MATLAB:
!~/abin/3dcalc -a ortho+orig -b mask+orig -prefix brain -expr 'a*step(b-2.9)'
% 2.8.1 if using template MRI:
!~/abin/3dcalc -a warped+orig -b mask+orig -prefix brain -expr 'a*step(b-2.9)'

% 2.9 creating a tlrc file: in the terminal type: 
% "@auto_tlrc -base TT_N27+tlrc -input brain+orig -no_ss -pad_base 60"

% 2.10 creating the final hull.shape file:
!meshnorm ortho_brainhull.ply > hull.shape
% -------------------------------------------------------------------------
%% 3. creating param file (do it once!!)
cd /home/meg/Data/Maor/Hypnosis/Subjects
createPARAM('all4cov','ERF','all',[0 0.5],'all',[-0.15 0],[1 40],[-0.15 1]);
% now go into the param file and change Multisphere to Nolte!!!!
% -------------------------------------------------------------------------
%% 4. SAMcov,wts,erf
cd /home/meg/Data/Maor/Hypnosis/Subjects
!SAMcov -r Hyp28 -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -v
!SAMwts -r Hyp28 -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -c alla -v
% "alla" and not "all" because it adds and 'a' to the file name for some reason

% reading the weights
cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28
wtsNoSuf='SAM/all4cov,1-40Hz,alla';
[SAMHeader, ActIndex, ActWgts]=readWeights([wtsNoSuf,'.wts']); % it takes a while
save([wtsNoSuf,'.mat'],'SAMHeader', 'ActIndex', 'ActWgts'); % save in mat format, quicker to read later.

% noise estimation
ns=ActWgts;
ns=ns-repmat(mean(ns,2),1,size(ns,2));
ns=ns.*ns;
ns=mean(ns,2);

% get toi mean square (different than SAMerf, no BL correction)
cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz
load averagedata

%% creating virtual sensors
sub = 28;
for j = 102:2:108
    eval(['vsCon',num2str(j),'Comp1=ActWgts*sub',num2str(sub),'con',num2str(j),'.avg(:,278:313);']);
    eval(['vsCon',num2str(j),'Comp1MS=mean(vsCon',num2str(j),'Comp1.*vsCon',num2str(j),'Comp1,2)./ns;']);
    eval(['vsCon',num2str(j),'Comp1MS=vsCon',num2str(j),'Comp1MS./max(vsCon',num2str(j),'Comp1MS);']); % scale
    eval(['vsCon',num2str(j),'Comp1MS(isnan(vsCon',num2str(j),'Comp1MS)) = 0;']);
    eval(['vsCon',num2str(j),'Comp2=ActWgts*sub',num2str(sub),'con',num2str(j),'.avg(:,314:343);']);
    eval(['vsCon',num2str(j),'Comp2MS=mean(vsCon',num2str(j),'Comp2.*vsCon',num2str(j),'Comp2,2)./ns;']);
    eval(['vsCon',num2str(j),'Comp2MS=vsCon',num2str(j),'Comp2MS./max(vsCon',num2str(j),'Comp2MS);']); % scale
    eval(['vsCon',num2str(j),'Comp2MS(isnan(vsCon',num2str(j),'Comp2MS)) = 0;']);
    eval(['vsCon',num2str(j),'Comp3=ActWgts*sub',num2str(sub),'con',num2str(j),'.avg(:,471:662);']);
    eval(['vsCon',num2str(j),'Comp3MS=mean(vsCon',num2str(j),'Comp3.*vsCon',num2str(j),'Comp3,2)./ns;']);
    eval(['vsCon',num2str(j),'Comp3MS=vsCon',num2str(j),'Comp3MS./max(vsCon',num2str(j),'Comp3MS);']); % scale
    eval(['vsCon',num2str(j),'Comp3MS(isnan(vsCon',num2str(j),'Comp3MS)) = 0;']);
end

%make image 3D of mean square (MS, power)
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
for j = 102:2:108
    for i=1:3
        eval(['cfg.prefix=''Con',num2str(j),'Comp',num2str(i),'MS'';']);
        eval(['VS2Brik(cfg,vsCon',num2str(j),'Comp',num2str(i),'MS);']);
    end;
end

%% now move the brain+tlrc files to 1_40Hz folder, open a terminal and type: 
@auto_tlrc -apar brain+tlrc -input Con102Comp1MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con102Comp2MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con102Comp3MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con104Comp1MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con104Comp2MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con104Comp3MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con106Comp1MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con106Comp2MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con106Comp3MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con108Comp1MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con108Comp2MS+orig -dxyz 5
@auto_tlrc -apar brain+tlrc -input Con108Comp3MS+orig -dxyz 5


%% Make a power movie of the whole trial for each condition
% for con 102
vsCon102=(ActWgts*sub8con102.avg).*(ActWgts*sub8con102.avg);
ns=repmat(ns,1,size(vsCon102,2));
vsCon102=vsCon102./ns;
vsCon102=vsCon102./max(max(max(vsCon102)));

cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
cfg.prefix='Con102';
cfg.torig=-150;
cfg.TR=1/1.017;
VS2Brik(cfg,vsCon102);

% open afni and open a second afni from afni. Choose "Define datamode",
% choose "Lock" and tick "Time Lock". Choose "Graph", stand some where on
% the graph window and then satnd on one of the brain windows and press "v".
% if you want to have the brain in underlay move to the folder
% "brain+orig"x2

%% statistics in afni
% repeated measure anova (run in terminal)
3dANOVA3 -type 4 -alevels 2 -blevels 2 -clevels 17 -dset 1 1 1 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 2 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp8/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 3 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp9/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 4 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp10/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 5 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp11/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 6 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp12/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 7 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp14/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 8 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp15/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 9 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp16/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 10 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp17/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 11 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp18/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 12 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp19/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 13 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp21/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 14 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp25/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 15 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp26/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 16 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp27/1_40Hz/Con102Comp1MS+tlrc -dset 1 1 17 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz/Con102Comp1MS+tlrc -dset 1 2 1 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz/Con104Comp1MS+tlrc -dset 1 2 2 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp8/1_40Hz/Con104Comp1MS+tlrc   -dset 1 2 3 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp9/1_40Hz/Con104Comp1MS+tlrc   -dset 1 2 4 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp10/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 5 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp11/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 6 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp12/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 7 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp14/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 8 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp15/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 9 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp16/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 10 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp17/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 11 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp18/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 12 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp19/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 13 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp21/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 14 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp25/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 15 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp26/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 16 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp27/1_40Hz/Con104Comp1MS+tlrc  -dset 1 2 17 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz/Con104Comp1MS+tlrc  -dset 2 1 1 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz/Con106Comp1MS+tlrc   -dset 2 1 2 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp8/1_40Hz/Con106Comp1MS+tlrc   -dset 2 1 3 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp9/1_40Hz/Con106Comp1MS+tlrc   -dset 2 1 4 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp10/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 5 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp11/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 6 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp12/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 7 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp14/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 8 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp15/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 9 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp16/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 10 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp17/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 11 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp18/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 12 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp19/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 13 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp21/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 14 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp25/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 15 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp26/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 16 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp27/1_40Hz/Con106Comp1MS+tlrc  -dset 2 1 17 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz/Con106Comp1MS+tlrc  -dset 2 2 1 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz/Con108Comp1MS+tlrc   -dset 2 2 2 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp8/1_40Hz/Con108Comp1MS+tlrc   -dset 2 2 3 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp9/1_40Hz/Con108Comp1MS+tlrc   -dset 2 2 4 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp10/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 5 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp11/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 6 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp12/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 7 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp14/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 8 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp15/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 9 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp16/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 10 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp17/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 11 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp18/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 12 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp19/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 13 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp21/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 14 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp25/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 15 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp26/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 16 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp27/1_40Hz/Con108Comp1MS+tlrc  -dset 2 2 17 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz/Con108Comp1MS+tlrc  -fa pre_post -fb right_left -fab prePost_RL -amean 1 preMean -amean 2 postMean -bmean 1 rightMean -bmean 2 leftMean -adiff 1 2 preMinusPost -bdiff 1 2 rightMinusLeft
% copy results to SAMresults folder

% to see results
cd /home/meg/Data/Maor/Hypnosis/SAMresults
% open terminal and type: "afni -niml &"
% and then type: "suma -niml -i_ply orthotlrc_brainhull.ply -sv masktlrc+tlrc -novolreg"
% press "t" on the suma window and now they interact. right click on the
% summa will align the afni windows and left click on the afni wnidows will
% align the summa.

%% make a list of all the ROIs in all the clusters
%                            -----------
%                             for comp1
%                            -----------
% F(p<0.05) = 4.493
% number of minimum voxels in cluster = -20
fid = fopen('ROIclust20FtestComp1.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 4.493 5 -20 prePost_RL+tlrc[1] > clust20FtestComp1.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust20FtestComp1.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% F(p<0.05) = 4.493
% number of minimum voxels in cluster = -50
fid = fopen('ROIclust50FtestComp1.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 4.493 5 -50 prePost_RL+tlrc[1] > clust50FtestComp1.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust50FtestComp1.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

%% post hoc analysis (alpha/4)
% for 104 vs 108
% t(p<0.025) = 2.351
% number of minimum voxels in cluster = -5
fid = fopen('ROIclust5Ttest104Vs108Comp1.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 2.351 5 -5 tdif_104Vs108+tlrc[1] > clust5Ttest104Vs108Comp1.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust5Ttest104Vs108Comp1.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest104Vs108Comp1.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -20 tdif_104Vs108+tlrc[1] > clust20Ttest104Vs108Comp1.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest104Vs108Comp1.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% -------------------------------------------------------------------------
% for 102 vs 106
% t(p<0.025) = 2.351
% number of minimum voxels in cluster = -5
fid = fopen('ROIclust5Ttest102Vs106Comp1.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 2.351 5 -5 tdif_102Vs106+tlrc[1] > clust5Ttest102Vs106Comp1.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust5Ttest102Vs106Comp1.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest102Vs106Comp1.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -20 tdif_102Vs106+tlrc[1] > clust20Ttest102Vs106Comp1.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest102Vs106Comp1.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% % -------------------------------------------------------------------------
% % for 102 vs 104
% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -50
% fid = fopen('ROIclust50Ttest102Vs104Comp1.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -50 tdif_102Vs104+tlrc[1] > clust50Ttest102Vs104Comp1.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust50Ttest102Vs104Comp1.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% 
% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest102Vs104Comp1.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -20 tdif_102Vs104+tlrc[1] > clust20Ttest102Vs104Comp1.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest102Vs104Comp1.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% % -------------------------------------------------------------------------
% % for 106 vs 108
% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -50
% fid = fopen('ROIclust50Ttest106Vs108Comp1.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -50 tdif_106Vs108+tlrc[1] > clust50Ttest106Vs108Comp1.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust50Ttest106Vs108Comp1.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% 
% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest106Vs108Comp1.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -20 tdif_106Vs108+tlrc[1] > clust20Ttest106Vs108Comp1.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest106Vs108Comp1.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
%%
%                            -----------
%                             for comp2
%                            -----------
% F(p<0.05) = 4.493
% number of minimum voxels in cluster = -20
fid = fopen('ROIclust20FtestComp2.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 4.493 5 -20 prePost_RL+tlrc[1] > clust20FtestComp2.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust20FtestComp2.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% F(p<0.05) = 4.493
% number of minimum voxels in cluster = -50
fid = fopen('ROIclust50FtestComp2.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 4.493 5 -50 prePost_RL+tlrc[1] > clust50FtestComp2.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust50FtestComp2.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

%% post hoc analysis (alpha/4)
% for 104 vs 108
% t(p<0.025) = 2.351
% number of minimum voxels in cluster = -5
fid = fopen('ROIclust5Ttest104Vs108Comp2.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 2.351 5 -5 tdif_104Vs108+tlrc[1] > clust5Ttest104Vs108Comp2.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust5Ttest104Vs108Comp2.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest104Vs108Comp2.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -20 tdif_104Vs108+tlrc[1] > clust20Ttest104Vs108Comp2.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest104Vs108Comp2.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% -------------------------------------------------------------------------
% for 102 vs 106
% t(p<0.025) = 2.351
% number of minimum voxels in cluster = -50
fid = fopen('ROIclust5Ttest102Vs106Comp2.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 2.351 5 -5 tdif_102Vs106+tlrc[1] > clust5Ttest102Vs106Comp2.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust5Ttest102Vs106Comp2.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest102Vs106Comp2.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -20 tdif_102Vs106+tlrc[1] > clust20Ttest102Vs106Comp2.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest102Vs106Comp2.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% % -------------------------------------------------------------------------
% % for 102 vs 104
% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -50
% fid = fopen('ROIclust50Ttest102Vs104Comp2.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -50 tdif_102Vs104+tlrc[1] > clust50Ttest102Vs104Comp2.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust50Ttest102Vs104Comp2.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% 
% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest102Vs104Comp2.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -20 tdif_102Vs104+tlrc[1] > clust20Ttest102Vs104Comp2.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest102Vs104Comp2.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% % -------------------------------------------------------------------------
% % for 106 vs 108
% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -50
% fid = fopen('ROIclust50Ttest106Vs108Comp2.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -50 tdif_106Vs108+tlrc[1] > clust50Ttest106Vs108Comp2.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust50Ttest106Vs108Comp2.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% 
% % t(p<0.0125) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest106Vs108Comp2.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.648 5 -20 tdif_106Vs108+tlrc[1] > clust20Ttest106Vs108Comp2.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest106Vs108Comp2.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
%%
%                            -----------
%                             for comp3
%                            -----------
% F(p<0.05) = 4.493
% number of minimum voxels in cluster = -20
fid = fopen('ROIclust20FtestComp3.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 4.493 5 -20 prePost_RL+tlrc[1] > clust20FtestComp3.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust20FtestComp3.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% F(p<0.05) = 4.493
% number of minimum voxels in cluster = -50
fid = fopen('ROIclust50FtestComp3.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 4.493 5 -50 prePost_RL+tlrc[1] > clust50FtestComp3.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust50FtestComp3.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);
%% post hoc analysis (alpha/4)

% it preforms set2 - set1. Thus, negative results = more activity for set1 !!!!!!!!!!!
% ------------------------------------------------------------------------------------
% for 104 vs 108
% t(p<0.025) = 2.351
% number of minimum voxels in cluster = -5
fid = fopen('ROIclust5Ttest104Vs108Comp3.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 2.351 5 -5 tdif_104Vs108+tlrc[1] > clust5Ttest104Vs108Comp3.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust5Ttest104Vs108Comp3.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% % t(p<0.0125) = 2.351
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest104Vs108Comp3.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.351 5 -20 tdif_104Vs108+tlrc[1] > clust20Ttest104Vs108Comp3.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest104Vs108Comp3.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% -------------------------------------------------------------------------
% for 102 vs 106
% t(p<0.025) = 2.351
% number of minimum voxels in cluster = -5
fid = fopen('ROIclust5Ttest102Vs106Comp3.txt','a+');

    command = sprintf('~/abin/3dclust -1clip 2.351 5 -5 tdif_102Vs106+tlrc[1] > clust5Ttest102Vs106Comp3.1D');
    [status, result] = unix(command,'-echo');
    command = sprintf('~/abin/whereami -coord_file clust5Ttest102Vs106Comp3.1D[1,2,3] -tab -atlas TT_Daemon');
    [status, result] = unix(command,'-echo');
    fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));

fclose(fid);

% % t(p<0.0125) = 2.351
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest102Vs106Comp3.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.351 5 -20 tdif_102Vs106+tlrc[1] > clust20Ttest102Vs106Comp3.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest102Vs106Comp3.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% -------------------------------------------------------------------------
% for 102 vs 104
% t(p<0.025) = 2.648
% number of minimum voxels in cluster = -50
% fid = fopen('ROIclust50Ttest102Vs104Comp3.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.351 5 -50 tdif_102Vs104+tlrc[1] > clust50Ttest102Vs104Comp3.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust50Ttest102Vs104Comp3.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% 
% % t(p<0.025) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest102Vs104Comp3.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.351 5 -20 tdif_102Vs104+tlrc[1] > clust20Ttest102Vs104Comp3.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest102Vs104Comp3.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% % -------------------------------------------------------------------------
% % for 106 vs 108
% % t(p<0.025) = 2.648
% % number of minimum voxels in cluster = -50
% fid = fopen('ROIclust50Ttest106Vs108Comp3.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.351 5 -50 tdif_106Vs108+tlrc[1] > clust50Ttest106Vs108Comp3.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust50Ttest106Vs108Comp3.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);
% 
% % t(p<0.025) = 2.648
% % number of minimum voxels in cluster = -20
% fid = fopen('ROIclust20Ttest106Vs108Comp3.txt','a+');
% 
%     command = sprintf('~/abin/3dclust -1clip 2.351 5 -20 tdif_106Vs108+tlrc[1] > clust20Ttest106Vs108Comp3.1D');
%     [status, result] = unix(command,'-echo');
%     command = sprintf('~/abin/whereami -coord_file clust20Ttest106Vs108Comp3.1D[1,2,3] -tab -atlas TT_Daemon');
%     [status, result] = unix(command,'-echo');
%     fwrite(fid, sprintf('CLUSTERS FOR TIME INDEX \n\n %s\n\n\n', result));
% 
% fclose(fid);

%% presenting the functional data in Suma

% copy into the folder 'templateSurface' the files I want to present.
% open terminal and cd to the folder and then:
% afni -niml -dset temp+tlrc &
% suma -spec temp_both.spec -sv temp+tlrc

% click somewhere on the suma and press 't'
% with < > [ ] buttons I can do magic.
% type ctrl+h for the list of shortcuts.