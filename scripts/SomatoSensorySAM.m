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
fitMRI2hs('c,rfhp0.1Hz') % don't use if have individual MRI

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
!@auto_tlrc -base TT_N27+tlrc -input brain+orig -no_ss -pad_base 60

% 2.10 creating the final hull.shape file:
!meshnorm ortho_brainhull.ply > hull.shape
% -------------------------------------------------------------------------
%% 3. creating param file (do it once!!)
cd /home/meg/Data/Maor/Hypnosis/Subjects
createPARAM('all4cov','ERF','all',[0 0.5],'all',[-0.15 0],[1 40],[-0.15 1]);
% -------------------------------------------------------------------------
%% 4. SAMcov,wts,erf
cd /home/meg/Data/Maor/Hypnosis/Subjects
!SAMcov64 -r Hyp22 -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -v
!SAMwts64 -r Hyp22 -d xc,hb,lf_c,rfhp0.1Hz -m all4cov -c alla -v
% "alla" and not "all" because it adds and 'a' to the file name for some reason

% reading the weights
cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp22
wtsNoSuf='SAM/all4cov,1-40Hz,alla';
[SAMHeader, ActIndex, ActWgts]=readWeights([wtsNoSuf,'.wts']); % it takes a while
save([wtsNoSuf,'.mat'],'SAMHeader', 'ActIndex', 'ActWgts'); % save in mat format, quicker to read later.

% noise estimation
ns=ActWgts;
ns=ns-repmat(mean(ns,2),1,size(ns,2));
ns=ns.*ns;
ns=mean(ns,2);

% get toi mean square (different than SAMerf, no BL correction)
cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp22/1_40Hz
load averagedata

%% creating virtual sensors
sub = 22;
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

% make image 3D of mean square (MS, power)
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
for j = 102:2:108
    for i=1:3
        eval(['cfg.prefix=''Con',num2str(j),'Comp',num2str(i),'MS'';']);
        eval(['VS2Brik(cfg,vsCon',num2str(j),'Comp',num2str(i),'MS);']);
    end;
end

% now move the brain+tlrc files to 1_40Hz folder
copyfile('/home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/brain+tlrc.BRIK','/home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/1_40Hz/brain+tlrc.BRIK')
copyfile('/home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/brain+tlrc.HEAD','/home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/1_40Hz/brain+tlrc.HEAD')

% open a terminal and type: 
cd /home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/1_40Hz
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
cd /home/meg/Data/Maor/Hypnosis/Subjects
3dANOVA3 -type 4 -alevels 2 -blevels 2 -clevels 17 -dset 1 1 1 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 2 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp8/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 3 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp9/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 4 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp10/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 5 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp11/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 6 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp12/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 7 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp14/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 8 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp15/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 9 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp13/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 10 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp17/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 11 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp22/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 12 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp19/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 13 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp21/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 14 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp25/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 15 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp26/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 16 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp27/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 17 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz/Con102Comp3MS+tlrc -dset 1 2 1 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 2 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp8/1_40Hz/Con104Comp3MS+tlrc   -dset 1 2 3 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp9/1_40Hz/Con104Comp3MS+tlrc   -dset 1 2 4 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp10/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 5 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp11/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 6 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp12/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 7 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp14/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 8 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp15/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 9 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp13/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 10 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp17/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 11 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp22/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 12 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp19/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 13 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp21/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 14 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp25/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 15 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp26/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 16 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp27/1_40Hz/Con104Comp3MS+tlrc  -dset 1 2 17 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz/Con104Comp3MS+tlrc  -dset 2 1 1 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz/Con106Comp3MS+tlrc   -dset 2 1 2 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp8/1_40Hz/Con106Comp3MS+tlrc   -dset 2 1 3 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp9/1_40Hz/Con106Comp3MS+tlrc   -dset 2 1 4 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp10/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 5 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp11/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 6 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp12/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 7 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp14/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 8 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp15/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 9 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp13/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 10 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp17/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 11 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp22/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 12 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp19/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 13 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp21/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 14 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp25/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 15 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp26/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 16 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp27/1_40Hz/Con106Comp3MS+tlrc  -dset 2 1 17 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz/Con106Comp3MS+tlrc  -dset 2 2 1 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz/Con108Comp3MS+tlrc   -dset 2 2 2 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp8/1_40Hz/Con108Comp3MS+tlrc   -dset 2 2 3 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp9/1_40Hz/Con108Comp3MS+tlrc   -dset 2 2 4 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp10/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 5 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp11/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 6 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp12/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 7 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp14/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 8 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp15/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 9 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp13/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 10 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp17/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 11 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp22/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 12 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp19/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 13 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp21/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 14 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp25/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 15 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp26/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 16 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp27/1_40Hz/Con108Comp3MS+tlrc  -dset 2 2 17 /home/meg/Data/Maor/Hypnosis/Subjects/Hyp28/1_40Hz/Con108Comp3MS+tlrc  -fa pre_post -fb right_left -fab prePost_RL -amean 1 preMean -amean 2 postMean -bmean 1 rightMean -bmean 2 leftMean -adiff 1 2 preMinusPost -bdiff 1 2 rightMinusLeft
% for control group!!
3dANOVA3 -type 4 -alevels 2 -blevels 2 -clevels 14 -dset 1 1 1 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 2 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon4/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 3 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon5/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 4 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon6/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 5 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon7/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 6 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon8/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 7 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon9/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 8 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon10/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 9 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon11/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 10 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon12/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 11 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon13/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 12 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon14/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 13 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon15/1_40Hz/Con102Comp3MS+tlrc -dset 1 1 14 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon16/1_40Hz/Con102Comp3MS+tlrc -dset 1 2 1 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 2 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon4/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 3 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon5/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 4 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon6/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 5 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon7/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 6 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon8/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 7 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon9/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 8 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon10/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 9 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon11/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 10 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon12/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 11 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon13/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 12 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon14/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 13 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon15/1_40Hz/Con104Comp3MS+tlrc -dset 1 2 14 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon16/1_40Hz/Con104Comp3MS+tlrc -dset 2 1 1 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 2 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon4/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 3 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon5/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 4 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon6/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 5 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon7/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 6 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon8/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 7 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon9/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 8 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon10/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 9 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon11/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 10 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon12/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 11 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon13/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 12 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon14/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 13 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon15/1_40Hz/Con106Comp3MS+tlrc -dset 2 1 14 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon16/1_40Hz/Con106Comp3MS+tlrc -dset 2 2 1 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon1/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 2 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon4/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 3 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon5/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 4 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon6/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 5 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon7/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 6 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon8/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 7 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon9/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 8 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon10/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 9 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon11/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 10 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon12/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 11 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon13/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 12 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon14/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 13 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon15/1_40Hz/Con108Comp3MS+tlrc -dset 2 2 14 /home/meg/Data/Maor/Hypnosis/Subjects/HypCon16/1_40Hz/Con108Comp3MS+tlrc -fa pre_post_con -fb right_left_con -fab prePost_RL_con
% copy results to SAMresults folder
cd /home/meg/Data/Maor/Hypnosis/SAMresults/Comp3New19Subs
% get ridd of the voxels outside the cortex
masktlrc('prePost_RL_19subs+tlrc','MASKctx+tlrc','_ctx');
masktlrc('right_left_19subs+tlrc','MASKctx+tlrc','_ctx');
masktlrc('pre_post_19subs+tlrc','MASKctx+tlrc','_ctx');

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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                    %%
% -------------- >8 ------- 30.4.14 ------ 8< --------p < .05------- %%
%                                                                    %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extracting maximum values
cd /home/meg/Data/Maor/Hypnosis/SAMresults/Comp3New19Subs
clear all
!3dExtrema -prefix Clust20_PrePost_ext -mask_file Clust20_PrePost_mask+tlrc -data_thr 4.417 -sep_dist 30 -closure -volume pre_post_19subs_ctx+tlrc
!3dExtrema -prefix Clust20_LR_ext -mask_file Clust20_LR_mask+tlrc -data_thr 4.417 -sep_dist 30 -closure -volume right_left_19subs_ctx+tlrc
!3dExtrema -prefix Clust20_Int_ext -mask_file Clust20_Int_mask+tlrc -data_thr 4.417 -sep_dist 30 -closure -volume prePost_RL_19subs_ctx+tlrc

% extract the cordinates of the extreme voxels
!3dmaskdump -xyz -nozero -noijk Clust20_PrePost_ext+tlrc > Clust20_xyz_PrePost.txt
!3dmaskdump -xyz -nozero -noijk Clust20_LR_ext+tlrc > Clust20_xyz_LR.txt
!3dmaskdump -xyz -nozero -noijk Clust20_Int_ext+tlrc > Clust20_xyz_Int.txt

% creating a matrix of all maximum values for all subs for all condition
% according to the xyz files created
%% PrePost
% each subject power for each extreme voxel in the PrePost effect
clear all
subs = [7:19 21 22 25:28];
voxPrePost = importdata('Clust20_xyz_PrePost.txt');

val=[];
a = 1;
for i=subs
    for j = 1:size(voxPrePost,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con102Comp3MS+tlrc > Clust20_VoxValuesPreRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con104Comp3MS+tlrc > Clust20_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con106Comp3MS+tlrc > Clust20_VoxValuesPostRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con108Comp3MS+tlrc > Clust20_VoxValuesPostLeft.txt']);
                        
        val = importdata('Clust20_VoxValuesPreRight.txt'); Clust20_VoxValuesPreRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPreLeft.txt'); Clust20_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostRight.txt'); Clust20_VoxValuesPostRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostLeft.txt'); Clust20_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(subs)
    eval(['Clust20_VoxPre(',num2str(i),',1:size(voxPrePost,1)) = mean([Clust20_VoxValuesPreRight(',num2str(i),',:);Clust20_VoxValuesPreLeft(',num2str(i),',:)],1);']);
    eval(['Clust20_VoxPost(',num2str(i),',1:size(voxPrePost,1)) = mean([Clust20_VoxValuesPostRight(',num2str(i),',:);Clust20_VoxValuesPostLeft(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxPrePost,1)
    eval(['!whereami ',num2str(voxPrePost(i,1)),' ',num2str(voxPrePost(i,2)),' ',num2str(voxPrePost(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPrePost{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPrePost{i,1}=wmiPrePost{i,1}(2:end);
end

save Clust20_PrePost voxPrePost wmiPrePost Clust20_VoxPre Clust20_VoxPost

% means and sds
for i=1:size(voxPrePost,1)
    eval(['mean_voxel_',num2str(i),'(1,1) = mean(Clust20_VoxPre(:,',num2str(i),'));']);
    eval(['mean_voxel_',num2str(i),'(2,1) = mean(Clust20_VoxPost(:,',num2str(i),'));']);
    eval(['sd_voxel_',num2str(i),'(1,1) = std(Clust20_VoxPre(:,',num2str(i),'))./sqrt(17);']);
    eval(['sd_voxel_',num2str(i),'(2,1) = std(Clust20_VoxPost(:,',num2str(i),'))./sqrt(17);']);
end;

% plots for the group
for i=1:size(voxPrePost,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiPrePost{i});
    title(ti)
    ylabel('Relative Signal Change');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pre','Post'});
end

%% LR
% each subject power for each extreme voxel in the LR effect
clear all
subs = [7:19 21 22 25:28];
voxLR = importdata('Clust20_xyz_LR.txt');

val=[];
a = 1;
for i=subs
    for j = 1:size(voxLR,1)
        eval(['!3dmaskdump -xbox ',num2str(voxLR(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con102Comp3MS+tlrc > Clust20_VoxValuesPreRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxLR(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con104Comp3MS+tlrc > Clust20_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxLR(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con106Comp3MS+tlrc > Clust20_VoxValuesPostRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxLR(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con108Comp3MS+tlrc > Clust20_VoxValuesPostLeft.txt']);
                        
        val = importdata('Clust20_VoxValuesPreRight.txt'); Clust20_VoxValuesPreRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPreLeft.txt'); Clust20_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostRight.txt'); Clust20_VoxValuesPostRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostLeft.txt'); Clust20_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(subs)
    eval(['Clust20_VoxLeft(',num2str(i),',1:size(voxLR,1)) = mean([Clust20_VoxValuesPreRight(',num2str(i),',:);Clust20_VoxValuesPostRight(',num2str(i),',:)],1);']);
    eval(['Clust20_VoxRight(',num2str(i),',1:size(voxLR,1)) = mean([Clust20_VoxValuesPreLeft(',num2str(i),',:);Clust20_VoxValuesPostLeft(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxLR,1)
    eval(['!whereami ',num2str(voxLR(i,1)),' ',num2str(voxLR(i,2)),' ',num2str(voxLR(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiLR{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiLR{i,1}=wmiLR{i,1}(2:end);
end

save Clust20_LR voxLR wmiLR Clust20_VoxRight Clust20_VoxLeft

% means and sds
for i=1:size(voxLR,1)
    eval(['mean_voxel_',num2str(i),'(1,1) = mean(Clust20_VoxLeft(:,',num2str(i),'));']);
    eval(['mean_voxel_',num2str(i),'(2,1) = mean(Clust20_VoxRight(:,',num2str(i),'));']);
    eval(['sd_voxel_',num2str(i),'(1,1) = std(Clust20_VoxLeft(:,',num2str(i),'))./sqrt(17);']);
    eval(['sd_voxel_',num2str(i),'(2,1) = std(Clust20_VoxRight(:,',num2str(i),'))./sqrt(17);']);
end;

% plots for the group
for i=1:size(voxLR,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiLR{i});
    title(ti)
    ylabel('Relative Signal Change');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Left','Right'});
end

%% Interaction
clear all
subs = [7:19 21 22 25:28];
voxInt = importdata('Clust20_xyz_Int.txt');


% each subject power for each extreme voxel in the interaction

val=[];
a = 1;
for i=subs
    for j = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con102Comp3MS+tlrc > Clust20_VoxValuesPreRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con104Comp3MS+tlrc > Clust20_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con106Comp3MS+tlrc > Clust20_VoxValuesPostRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con108Comp3MS+tlrc > Clust20_VoxValuesPostLeft.txt']);
                        
        val = importdata('Clust20_VoxValuesPreRight.txt'); Clust20_VoxValuesPreRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPreLeft.txt'); Clust20_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostRight.txt'); Clust20_VoxValuesPostRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostLeft.txt'); Clust20_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_Int voxInt wmiInt Clust20_VoxValuesPreRight Clust20_VoxValuesPreLeft Clust20_VoxValuesPostRight Clust20_VoxValuesPostLeft 

for i=1:size(voxInt,1)
    eval(['mean_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_VoxValuesPreLeft(:,',num2str(i),')),mean(Clust20_VoxValuesPostLeft(:,',num2str(i),'))];']);
    eval(['mean_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_VoxValuesPreRight(:,',num2str(i),')),mean(Clust20_VoxValuesPostRight(:,',num2str(i),'))];']);
    eval(['sd_voxel_',num2str(i),'(1,1:2) = [std(Clust20_VoxValuesPreLeft(:,',num2str(i),'))./sqrt(14),std(Clust20_VoxValuesPostLeft(:,',num2str(i),'))./sqrt(17)];']);
    eval(['sd_voxel_',num2str(i),'(2,1:2) = [std(Clust20_VoxValuesPreRight(:,',num2str(i),'))./sqrt(19),std(Clust20_VoxValuesPostRight(:,',num2str(i),'))./sqrt(17)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),',mean_voxel_',num2str(i),');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Relative Signal Change');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');
end

clear all
load Clust20_PrePost
load Clust20_LR
load Clust20_Int
save Clust20_ext


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                    %%
% -------------- >8 ------- 30.4.14 ------ 8< --------p < .01------- %%
%                                                                    %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extracting maximum values
cd /home/meg/Data/Maor/Hypnosis/SAMresults/Comp3New17Subs
clear all
!3dExtrema -prefix Clust20_p01_PrePost_ext -mask_file Clust20_p01_PrePost_mask+tlrc -data_thr 8.546 -sep_dist 30 -closure -volume pre_post_ctx+tlrc
!3dExtrema -prefix Clust20_p01_LR_ext -mask_file Clust20_p01_LR_mask+tlrc -data_thr 8.546 -sep_dist 30 -closure -volume right_left_ctx+tlrc
!3dExtrema -prefix Clust20_p01_Int_ext -mask_file Clust20_p01_Int_mask+tlrc -data_thr 8.546 -sep_dist 30 -closure -volume prePost_RL_ctx+tlrc

% extract the cordinates of the extreme voxels
!3dmaskdump -xyz -nozero -noijk Clust20_p01_PrePost_ext+tlrc > Clust20_xyz_p01_PrePost.txt
!3dmaskdump -xyz -nozero -noijk Clust20_p01_LR_ext+tlrc > Clust20_xyz_p01_LR.txt
!3dmaskdump -xyz -nozero -noijk Clust20_p01_Int_ext+tlrc > Clust20_xyz_p01_Int.txt

% creating a matrix of all maximum values for all subs for all condition
% according to the xyz files created
%% PrePost
% each subject power for each extreme voxel in the PrePost effect
clear all
subs = [7:15 17 19 21 22 25:28];
voxPrePost = importdata('Clust20_xyz_p01_PrePost.txt');

val=[];
a = 1;
for i=subs
    for j = 1:size(voxPrePost,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con102Comp3MS+tlrc > Clust20_VoxValuesPreRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con104Comp3MS+tlrc > Clust20_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con106Comp3MS+tlrc > Clust20_VoxValuesPostRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con108Comp3MS+tlrc > Clust20_VoxValuesPostLeft.txt']);
                        
        val = importdata('Clust20_VoxValuesPreRight.txt'); Clust20_VoxValuesPreRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPreLeft.txt'); Clust20_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostRight.txt'); Clust20_VoxValuesPostRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostLeft.txt'); Clust20_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(subs)
    eval(['Clust20_VoxPre(',num2str(i),',1:size(voxPrePost,1)) = mean([Clust20_VoxValuesPreRight(',num2str(i),',:);Clust20_VoxValuesPreLeft(',num2str(i),',:)],1);']);
    eval(['Clust20_VoxPost(',num2str(i),',1:size(voxPrePost,1)) = mean([Clust20_VoxValuesPostRight(',num2str(i),',:);Clust20_VoxValuesPostLeft(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxPrePost,1)
    eval(['!whereami ',num2str(voxPrePost(i,1)),' ',num2str(voxPrePost(i,2)),' ',num2str(voxPrePost(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPrePost{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPrePost{i,1}=wmiPrePost{i,1}(2:end);
end

save Clust20_p01_PrePost voxPrePost wmiPrePost Clust20_VoxPre Clust20_VoxPost

% means and sds
for i=1:size(voxPrePost,1)
    eval(['mean_voxel_',num2str(i),'(1,1) = mean(Clust20_VoxPre(:,',num2str(i),'));']);
    eval(['mean_voxel_',num2str(i),'(2,1) = mean(Clust20_VoxPost(:,',num2str(i),'));']);
    eval(['sd_voxel_',num2str(i),'(1,1) = std(Clust20_VoxPre(:,',num2str(i),'))./sqrt(17);']);
    eval(['sd_voxel_',num2str(i),'(2,1) = std(Clust20_VoxPost(:,',num2str(i),'))./sqrt(17);']);
end;

% plots for the group
for i=1:size(voxPrePost,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiPrePost{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pre','Post'});
end

%% LR
% each subject power for each extreme voxel in the LR effect
clear all
subs = [7:15 17 19 21 22 25:28];
voxLR = importdata('Clust20_xyz_p01_LR.txt');

val=[];
a = 1;
for i=subs
    for j = 1:size(voxLR,1)
        eval(['!3dmaskdump -xbox ',num2str(voxLR(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con102Comp3MS+tlrc > Clust20_VoxValuesPreRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxLR(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con104Comp3MS+tlrc > Clust20_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxLR(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con106Comp3MS+tlrc > Clust20_VoxValuesPostRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxLR(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con108Comp3MS+tlrc > Clust20_VoxValuesPostLeft.txt']);
                        
        val = importdata('Clust20_VoxValuesPreRight.txt'); Clust20_VoxValuesPreRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPreLeft.txt'); Clust20_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostRight.txt'); Clust20_VoxValuesPostRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostLeft.txt'); Clust20_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(subs)
    eval(['Clust20_VoxLeft(',num2str(i),',1:size(voxLR,1)) = mean([Clust20_VoxValuesPreRight(',num2str(i),',:);Clust20_VoxValuesPostRight(',num2str(i),',:)],1);']);
    eval(['Clust20_VoxRight(',num2str(i),',1:size(voxLR,1)) = mean([Clust20_VoxValuesPreLeft(',num2str(i),',:);Clust20_VoxValuesPostLeft(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxLR,1)
    eval(['!whereami ',num2str(voxLR(i,1)),' ',num2str(voxLR(i,2)),' ',num2str(voxLR(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiLR{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiLR{i,1}=wmiLR{i,1}(2:end);
end

save Clust20_p01_LR voxLR wmiLR Clust20_VoxRight Clust20_VoxLeft

% means and sds
for i=1:size(voxLR,1)
    eval(['mean_voxel_',num2str(i),'(1,1) = mean(Clust20_VoxLeft(:,',num2str(i),'));']);
    eval(['mean_voxel_',num2str(i),'(2,1) = mean(Clust20_VoxRight(:,',num2str(i),'));']);
    eval(['sd_voxel_',num2str(i),'(1,1) = std(Clust20_VoxLeft(:,',num2str(i),'))./sqrt(17);']);
    eval(['sd_voxel_',num2str(i),'(2,1) = std(Clust20_VoxRight(:,',num2str(i),'))./sqrt(17);']);
end;

% plots for the group
for i=1:size(voxLR,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiLR{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Left','Right'});
end

%% Interaction
clear all
subs = [7:15 17 19 21 22 25:28];
voxInt = importdata('Clust20_xyz_p01_Int.txt');


% each subject power for each extreme voxel in the interaction

val=[];
a = 1;
for i=subs
    for j = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con102Comp3MS+tlrc > Clust20_VoxValuesPreRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con104Comp3MS+tlrc > Clust20_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con106Comp3MS+tlrc > Clust20_VoxValuesPostRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con108Comp3MS+tlrc > Clust20_VoxValuesPostLeft.txt']);
                        
        val = importdata('Clust20_VoxValuesPreRight.txt'); Clust20_VoxValuesPreRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPreLeft.txt'); Clust20_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostRight.txt'); Clust20_VoxValuesPostRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostLeft.txt'); Clust20_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_p01_Int voxInt wmiInt Clust20_VoxValuesPreRight Clust20_VoxValuesPreLeft Clust20_VoxValuesPostRight Clust20_VoxValuesPostLeft 

for i=1:size(voxInt,1)
    eval(['mean_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_VoxValuesPreLeft(:,',num2str(i),')),mean(Clust20_VoxValuesPostLeft(:,',num2str(i),'))];']);
    eval(['mean_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_VoxValuesPreRight(:,',num2str(i),')),mean(Clust20_VoxValuesPostRight(:,',num2str(i),'))];']);
    eval(['sd_voxel_',num2str(i),'(1,1:2) = [std(Clust20_VoxValuesPreLeft(:,',num2str(i),'))./sqrt(14),std(Clust20_VoxValuesPostLeft(:,',num2str(i),'))./sqrt(17)];']);
    eval(['sd_voxel_',num2str(i),'(2,1:2) = [std(Clust20_VoxValuesPreRight(:,',num2str(i),'))./sqrt(19),std(Clust20_VoxValuesPostRight(:,',num2str(i),'))./sqrt(17)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');
end

clear all
load Clust20_p01_PrePost
load Clust20_p01_LR
load Clust20_p01_Int
save Clust20_p01_ext

%% mean voxels for each cluster
% for control (vox1&2, vox5&6, vox7&8)
load /home/meg/Data/Maor/Hypnosis/SAMresults/Comp3Control/Clust20_Int

mean_voxels_1_2(1,1:2) = [mean([Clust20_VoxValuesPreLeft(:,1);Clust20_VoxValuesPreLeft(:,2)]),...
    mean([Clust20_VoxValuesPostLeft(:,1);Clust20_VoxValuesPostLeft(:,2)])];
mean_voxels_1_2(2,1:2) = [mean([Clust20_VoxValuesPreRight(:,1);Clust20_VoxValuesPreRight(:,2)]),...
    mean([Clust20_VoxValuesPostRight(:,1);Clust20_VoxValuesPostRight(:,2)])];
sd_voxels_1_2(1,1:2) = [std([Clust20_VoxValuesPreLeft(:,1);Clust20_VoxValuesPreLeft(:,2)])/sqrt(28),...
    std([Clust20_VoxValuesPostLeft(:,1);Clust20_VoxValuesPostLeft(:,2)])/sqrt(28)];
sd_voxels_1_2(2,1:2) = [std([Clust20_VoxValuesPreRight(:,1);Clust20_VoxValuesPreRight(:,2)])/sqrt(28),...
    std([Clust20_VoxValuesPostRight(:,1);Clust20_VoxValuesPostRight(:,2)])/sqrt(28)];

mean_voxels_5_6(1,1:2) = [mean([Clust20_VoxValuesPreLeft(:,5);Clust20_VoxValuesPreLeft(:,6)]),...
    mean([Clust20_VoxValuesPostLeft(:,5);Clust20_VoxValuesPostLeft(:,6)])];
mean_voxels_5_6(2,1:2) = [mean([Clust20_VoxValuesPreRight(:,5);Clust20_VoxValuesPreRight(:,6)]),...
    mean([Clust20_VoxValuesPostRight(:,5);Clust20_VoxValuesPostRight(:,6)])];
sd_voxels_5_6(1,1:2) = [std([Clust20_VoxValuesPreLeft(:,5);Clust20_VoxValuesPreLeft(:,6)])/sqrt(28),...
    std([Clust20_VoxValuesPostLeft(:,5);Clust20_VoxValuesPostLeft(:,6)])/sqrt(28)];
sd_voxels_5_6(2,1:2) = [std([Clust20_VoxValuesPreRight(:,5);Clust20_VoxValuesPreRight(:,6)])/sqrt(28),...
    std([Clust20_VoxValuesPostRight(:,5);Clust20_VoxValuesPostRight(:,6)])/sqrt(28)];

mean_voxels_7_8(1,1:2) = [mean([Clust20_VoxValuesPreLeft(:,7);Clust20_VoxValuesPreLeft(:,8)]),...
    mean([Clust20_VoxValuesPostLeft(:,7);Clust20_VoxValuesPostLeft(:,8)])];
mean_voxels_7_8(2,1:2) = [mean([Clust20_VoxValuesPreRight(:,7);Clust20_VoxValuesPreRight(:,8)]),...
    mean([Clust20_VoxValuesPostRight(:,7);Clust20_VoxValuesPostRight(:,8)])];
sd_voxels_7_8(1,1:2) = [std([Clust20_VoxValuesPreLeft(:,7);Clust20_VoxValuesPreLeft(:,8)])/sqrt(28),...
    std([Clust20_VoxValuesPostLeft(:,7);Clust20_VoxValuesPostLeft(:,8)])/sqrt(28)];
sd_voxels_7_8(2,1:2) = [std([Clust20_VoxValuesPreRight(:,7);Clust20_VoxValuesPreRight(:,8)])/sqrt(28),...
    std([Clust20_VoxValuesPostRight(:,7);Clust20_VoxValuesPostRight(:,8)])/sqrt(28)];


    figure;
    h1 = barwitherr(sd_voxels_1_2',mean_voxels_1_2');
    title('voxels 1 and 2')
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');
    
    figure;
    h1 = barwitherr(sd_voxels_5_6',mean_voxels_5_6');
    title('voxels 5 and 6')
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');
    
    figure;
    h1 = barwitherr(sd_voxels_7_8',mean_voxels_7_8');
    title('voxels 7 and 8')
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');

% for hyp (vox2:6)
load /home/meg/Data/Maor/Hypnosis/SAMresults/Comp3New19Subs/Clust20_Int
PreLeftVoxels2to6 = [Clust20_VoxValuesPreLeft(:,2);Clust20_VoxValuesPreLeft(:,3);...
    Clust20_VoxValuesPreLeft(:,4);Clust20_VoxValuesPreLeft(:,5);Clust20_VoxValuesPreLeft(:,6)];
PreRightVoxels2to6 = [Clust20_VoxValuesPreRight(:,2);Clust20_VoxValuesPreRight(:,3);...
    Clust20_VoxValuesPreRight(:,4);Clust20_VoxValuesPreRight(:,5);Clust20_VoxValuesPreRight(:,6)];
PostLeftVoxels2to6 = [Clust20_VoxValuesPostLeft(:,2);Clust20_VoxValuesPostLeft(:,3);...
    Clust20_VoxValuesPostLeft(:,4);Clust20_VoxValuesPostLeft(:,5);Clust20_VoxValuesPostLeft(:,6)];
PostRightVoxels2to6 = [Clust20_VoxValuesPostRight(:,2);Clust20_VoxValuesPostRight(:,3);...
    Clust20_VoxValuesPostRight(:,4);Clust20_VoxValuesPostRight(:,5);Clust20_VoxValuesPostRight(:,6)];

mean_voxels_2to6 = [mean(PreLeftVoxels2to6), mean(PostLeftVoxels2to6); mean(PreRightVoxels2to6),...
    mean(PostRightVoxels2to6)];
sd_voxels_2to6 = [std(PreLeftVoxels2to6)/sqrt(95), std(PostLeftVoxels2to6)/sqrt(95); std(PreRightVoxels2to6)/sqrt(95),...
    std(PostRightVoxels2to6)/sqrt(95)];

    figure;
    h1 = barwitherr(sd_voxels_2to6',mean_voxels_2to6');
    title('voxels 2 to 6')
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');
    
for i=[1,7,8]
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');
end

%% Extract extreeme voxels for original 15 subs (1-40Hz), Comp3
cd /home/meg/Data/Maor/Hypnosis/SAMresults/Comp3
masktlrc('prePost_RL+tlrc','MASKctx+tlrc','_ctx');
% extracting maximum values
clear all
!3dExtrema -prefix Clust20_Int_ext -mask_file Clust20_Int_mask+tlrc -data_thr 4.497 -sep_dist 30 -closure -volume prePost_RL_ctx+tlrc

% extract the cordinates of the extreme voxels
!3dmaskdump -xyz -nozero -noijk Clust20_Int_ext+tlrc > Clust20_xyz_Int.txt

% creating a matrix of all maximum values for all subs for all condition
% according to the xyz files created
% Interaction
clear all
subs = [7:12 14 15 17 19 21 25:28];
voxInt = importdata('Clust20_xyz_Int.txt');


% each subject power for each extreme voxel in the interaction

val=[];
a = 1;
for i=subs
    for j = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con102Comp3MS+tlrc > Clust20_VoxValuesPreRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con104Comp3MS+tlrc > Clust20_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con106Comp3MS+tlrc > Clust20_VoxValuesPostRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con108Comp3MS+tlrc > Clust20_VoxValuesPostLeft.txt']);
                        
        val = importdata('Clust20_VoxValuesPreRight.txt'); Clust20_VoxValuesPreRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPreLeft.txt'); Clust20_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostRight.txt'); Clust20_VoxValuesPostRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostLeft.txt'); Clust20_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_Int voxInt wmiInt Clust20_VoxValuesPreRight Clust20_VoxValuesPreLeft Clust20_VoxValuesPostRight Clust20_VoxValuesPostLeft 

for i=1:size(voxInt,1)
    eval(['mean_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_VoxValuesPreLeft(:,',num2str(i),')),mean(Clust20_VoxValuesPostLeft(:,',num2str(i),'))];']);
    eval(['mean_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_VoxValuesPreRight(:,',num2str(i),')),mean(Clust20_VoxValuesPostRight(:,',num2str(i),'))];']);
    eval(['sd_voxel_',num2str(i),'(1,1:2) = [std(Clust20_VoxValuesPreLeft(:,',num2str(i),'))./sqrt(14),std(Clust20_VoxValuesPostLeft(:,',num2str(i),'))./sqrt(17)];']);
    eval(['sd_voxel_',num2str(i),'(2,1:2) = [std(Clust20_VoxValuesPreRight(:,',num2str(i),'))./sqrt(19),std(Clust20_VoxValuesPostRight(:,',num2str(i),'))./sqrt(17)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');
end
%%
% ------------------------------------------------------------------
%
%% SAMerf for Alpha (7-13Hz), 324-630ms, 15 original subs
% -------------------------------------------------------
% creating param file (do it once!!)
cd /home/meg/Data/Maor/Hypnosis/Subjects
createPARAM('alpha4cov','ERF','all',[0 0.65],'all',[-0.15 0],[7 13],[-0.15 1]);
% SAMcov,wts,erf
subs=[7:12,14,15,17,19,21,25:28];
cd /home/meg/Data/Maor/Hypnosis/Subjects
for i=subs
    eval(['!SAMcov64 -r Hyp',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m alpha4cov -v']);
    eval(['!SAMwts64 -r Hyp',num2str(i),' -d xc,hb,lf_c,rfhp0.1Hz -m alpha4cov -c alla -v']);
end
% "alla" and not "all" because it adds and 'a' to the file name for some reason

% creating the averages for each subject

cfg=[];
cfg.demean         = 'yes'; % normalize the data according to the base line average time window (see two lines below)
cfg.continuous     = 'yes';
cfg.baselinewindow = [-0.15,0];
cfg.bpfilter       = 'yes'; % apply bandpass filter (see one line below)
cfg.bpfreq         = [7 13];
cfg.channel        = {'MEG'}; % MEG channels configuration. Take the MEG channels and exclude the minus ones 

for i=subs
    disp(i);
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency']);
    load datafinal
    for j=[102:2:108]
        cfg1=[];
        eval(['cfg1.trials=datafinal.trialinfo(:,1)==',num2str(j),';']);
        eval(['con',num2str(j),'=ft_timelockanalysis(cfg1,datafinal);']);
        eval(['sub',num2str(i),'alpha',num2str(j),' = ft_preprocessing(cfg, con',num2str(j),');']);
    end
    eval(['save data7_13Hz sub',num2str(i),'alpha102 sub',num2str(i),'alpha104 sub',num2str(i),'alpha106 sub',num2str(i),'alpha108'])
end

for i=subs
% reading the weights
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i)]);
    wtsNoSuf='SAM/alpha4cov,7-13Hz,alla';
    [SAMHeader, ActIndex, ActWgts]=readWeights([wtsNoSuf,'.wts']); % it takes a while
    ActWgts(:,216)=[];
    save([wtsNoSuf,'.mat'],'SAMHeader', 'ActIndex', 'ActWgts'); % save in mat format, quicker to read later.

    % noise estimation
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);

    % get toi mean square (different than SAMerf, no BL correction)
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency']);
    load data7_13Hz

    % creating virtual sensors
    
    for j = 102:2:108
        eval(['vsCon',num2str(j),'Alpha=ActWgts*sub',num2str(i),'alpha',num2str(j),'.avg(:,840:1151);']);
        eval(['vsCon',num2str(j),'AlphaMS=mean(vsCon',num2str(j),'Alpha.*vsCon',num2str(j),'Alpha,2)./ns;']);
        eval(['vsCon',num2str(j),'AlphaMS=vsCon',num2str(j),'AlphaMS./max(vsCon',num2str(j),'AlphaMS);']); % scale
        eval(['vsCon',num2str(j),'AlphaMS(isnan(vsCon',num2str(j),'AlphaMS)) = 0;']);
    end
    
    % make image 3D of mean square (MS, power)
    cfg=[];
    cfg.step=5;
    cfg.boxSize=[-120 120 -90 90 -20 150];
    for j = 102:2:108
         eval(['cfg.prefix=''Con',num2str(j),'AlphaMS'';']);
         eval(['VS2Brik(cfg,vsCon',num2str(j),'AlphaMS);']);
    end

    % now move the brain+tlrc files to 7_13Hz folder
    eval(['copyfile(''/home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/brain+tlrc.BRIK'',''/home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/brain+tlrc.BRIK'')']);
    eval(['copyfile(''/home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/brain+tlrc.HEAD'',''/home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/brain+tlrc.HEAD'')']);
end

% moving the files to tlrc
% open a terminal and type: 
for i in 7 8 9 10 11 12 14 15 17 19 21 25 26 27 28
do
    cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp$i/timeFrequency
    @auto_tlrc -apar brain+tlrc -input Con102AlphaMS+orig -dxyz 5
    @auto_tlrc -apar brain+tlrc -input Con104AlphaMS+orig -dxyz 5
    @auto_tlrc -apar brain+tlrc -input Con106AlphaMS+orig -dxyz 5
    @auto_tlrc -apar brain+tlrc -input Con108AlphaMS+orig -dxyz 5
done

%% statistics in afni
% repeated measure anova (run in terminal)
cd /home/meg/Data/Maor/Hypnosis/SAMresults/Alpha
./3dANOVA3_alpha
% get ridd of the voxels outside the cortex
masktlrc('prePost_RL+tlrc','MASKctx+tlrc','_ctx');
% extracting maximum values
clear all
!3dExtrema -prefix Clust20_Int_ext -mask_file Clust20_Int_mask+tlrc -data_thr 4.603 -sep_dist 30 -closure -volume prePost_RL_ctx+tlrc

% extract the cordinates of the extreme voxels
!3dmaskdump -xyz -nozero -noijk Clust20_Int_ext+tlrc > Clust20_xyz_Int.txt

% creating a matrix of all maximum values for all subs for all condition
% according to the xyz files created
clear all
subs = [7:12 14 15 17 19 21 25:28];
voxInt = importdata('Clust20_xyz_Int.txt');
% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for i=subs
    for j = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/Con102AlphaMS+tlrc > Clust20_VoxValuesPreRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/Con104AlphaMS+tlrc > Clust20_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/Con106AlphaMS+tlrc > Clust20_VoxValuesPostRight.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/timeFrequency/Con108AlphaMS+tlrc > Clust20_VoxValuesPostLeft.txt']);
                        
        val = importdata('Clust20_VoxValuesPreRight.txt'); Clust20_VoxValuesPreRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPreLeft.txt'); Clust20_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostRight.txt'); Clust20_VoxValuesPostRight(a,j) = val(4); val=[];
        val = importdata('Clust20_VoxValuesPostLeft.txt'); Clust20_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_Alpha_Int voxInt wmiInt Clust20_VoxValuesPreRight Clust20_VoxValuesPreLeft Clust20_VoxValuesPostRight Clust20_VoxValuesPostLeft 

for i=1:size(voxInt,1)
    eval(['mean_voxel_',num2str(i),'(1,1:2) = [mean(Clust20_VoxValuesPreLeft(:,',num2str(i),')),mean(Clust20_VoxValuesPostLeft(:,',num2str(i),'))];']);
    eval(['mean_voxel_',num2str(i),'(2,1:2) = [mean(Clust20_VoxValuesPreRight(:,',num2str(i),')),mean(Clust20_VoxValuesPostRight(:,',num2str(i),'))];']);
    eval(['sd_voxel_',num2str(i),'(1,1:2) = [std(Clust20_VoxValuesPreLeft(:,',num2str(i),'))./sqrt(14),std(Clust20_VoxValuesPostLeft(:,',num2str(i),'))./sqrt(17)];']);
    eval(['sd_voxel_',num2str(i),'(2,1:2) = [std(Clust20_VoxValuesPreRight(:,',num2str(i),'))./sqrt(19),std(Clust20_VoxValuesPostRight(:,',num2str(i),'))./sqrt(17)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'Pre','Post'});
    legend('Left','Right');
end

%% Pre Left Vs. Post Left!!!!!!
% -----------------------------
!3dExtrema -prefix Clust8_PrePostL_ext -mask_file Clust8_PreL_PostL_mask+tlrc -data_thr 2.01 -sep_dist 30 -closure -volume PreLvsPostL_19subs_ctx+tlrc
!3dmaskdump -xyz -nozero -noijk Clust8_PrePostL_ext+tlrc > Clust8_xyz_PrePostL.txt
clear all
subs = [7:19 21 22 25:28];
voxPrePost = importdata('Clust8_xyz_PrePostL.txt');
val=[];
a = 1;
for i=subs
    for j = 1:size(voxPrePost,1)
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con104Comp3MS+tlrc > Clust8_VoxValuesPreLeft.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxPrePost(j,1:3)),' /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/Con108Comp3MS+tlrc > Clust8_VoxValuesPostLeft.txt']);
        val = importdata('Clust8_VoxValuesPreLeft.txt'); Clust8_VoxValuesPreLeft(a,j) = val(4); val=[];
        val = importdata('Clust8_VoxValuesPostLeft.txt'); Clust8_VoxValuesPostLeft(a,j) = val(4); val=[];
    end
    a = a+1;
end

for i = 1:size(voxPrePost,1)
    eval(['!whereami ',num2str(voxPrePost(i,1)),' ',num2str(voxPrePost(i,2)),' ',num2str(voxPrePost(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiPrePost{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiPrePost{i,1}=wmiPrePost{i,1}(2:end);
end

save Clust8_PrePostL voxPrePost wmiPrePost Clust8_VoxValuesPreLeft Clust8_VoxValuesPostLeft

for i=1:size(voxPrePost,1)
    eval(['mean_voxel_',num2str(i),'(1,1) = mean(Clust8_VoxValuesPreLeft(:,',num2str(i),'));']);
    eval(['mean_voxel_',num2str(i),'(2,1) = mean(Clust8_VoxValuesPostLeft(:,',num2str(i),'));']);
    eval(['sd_voxel_',num2str(i),'(1,1) = std(Clust8_VoxValuesPreLeft(:,',num2str(i),'))./sqrt(19);']);
    eval(['sd_voxel_',num2str(i),'(2,1) = std(Clust8_VoxValuesPostLeft(:,',num2str(i),'))./sqrt(19);']);
end;

% plots for the group
for i=1:size(voxPrePost,1)
    figure;
    eval(['h1 = barwitherr(sd_voxel_',num2str(i),''',mean_voxel_',num2str(i),''');']);
    ti = sprintf('Pre Left Vs. Post Left voxel %s - %s',num2str(i),wmiPrePost{i});
    title(ti)
    ylabel('Relative Signal Change');
    %ylim([0 2.5]);
    xlim([0 3]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'Pre','Post'});
end

%% ----------------------------------------- 11.12.2014 -------------------------------------
%% SAM for early EarlyComps
% EarlyComp1 25-60ms
% EarlyComp2 60-133ms
% EarlyComp3 133-200ms
% EarlyComp4 200-300ms
for sub = [7:19 21 22 25:28];
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/1_40Hz']);
    load averagedata
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(sub),'/SAM/''all4cov,1-40Hz,alla.mat''']);
    % noise estimation
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);
    for j = 102:2:108
        eval(['vsCon',num2str(j),'EarlyComp1=ActWgts*sub',num2str(sub),'con',num2str(j),'.avg(:,179:215);']);
        eval(['vsCon',num2str(j),'EarlyComp1MS=mean(vsCon',num2str(j),'EarlyComp1.*vsCon',num2str(j),'EarlyComp1,2)./ns;']);
        eval(['vsCon',num2str(j),'EarlyComp1MS=vsCon',num2str(j),'EarlyComp1MS./max(vsCon',num2str(j),'EarlyComp1MS);']); % scale
        eval(['vsCon',num2str(j),'EarlyComp1MS(isnan(vsCon',num2str(j),'EarlyComp1MS)) = 0;']);
        eval(['vsCon',num2str(j),'EarlyComp2=ActWgts*sub',num2str(sub),'con',num2str(j),'.avg(:,215:289);']);
        eval(['vsCon',num2str(j),'EarlyComp2MS=mean(vsCon',num2str(j),'EarlyComp2.*vsCon',num2str(j),'EarlyComp2,2)./ns;']);
        eval(['vsCon',num2str(j),'EarlyComp2MS=vsCon',num2str(j),'EarlyComp2MS./max(vsCon',num2str(j),'EarlyComp2MS);']); % scale
        eval(['vsCon',num2str(j),'EarlyComp2MS(isnan(vsCon',num2str(j),'EarlyComp2MS)) = 0;']);
        eval(['vsCon',num2str(j),'EarlyComp3=ActWgts*sub',num2str(sub),'con',num2str(j),'.avg(:,289:357);']);
        eval(['vsCon',num2str(j),'EarlyComp3MS=mean(vsCon',num2str(j),'EarlyComp3.*vsCon',num2str(j),'EarlyComp3,2)./ns;']);
        eval(['vsCon',num2str(j),'EarlyComp3MS=vsCon',num2str(j),'EarlyComp3MS./max(vsCon',num2str(j),'EarlyComp3MS);']); % scale
        eval(['vsCon',num2str(j),'EarlyComp3MS(isnan(vsCon',num2str(j),'EarlyComp3MS)) = 0;']);
        eval(['vsCon',num2str(j),'EarlyComp4=ActWgts*sub',num2str(sub),'con',num2str(j),'.avg(:,357:459);']);
        eval(['vsCon',num2str(j),'EarlyComp4MS=mean(vsCon',num2str(j),'EarlyComp4.*vsCon',num2str(j),'EarlyComp4,2)./ns;']);
        eval(['vsCon',num2str(j),'EarlyComp4MS=vsCon',num2str(j),'EarlyComp4MS./max(vsCon',num2str(j),'EarlyComp4MS);']); % scale
        eval(['vsCon',num2str(j),'EarlyComp4MS(isnan(vsCon',num2str(j),'EarlyComp4MS)) = 0;']);
    end
    % make image 3D of mean square (MS, power)
    cfg=[];
    cfg.step=5;
    cfg.boxSize=[-120 120 -90 90 -20 150];
    for k = 102:2:108
        for l=1:4
            eval(['cfg.prefix=''Con',num2str(k),'EarlyComp',num2str(l),'MS'';']);
            eval(['VS2Brik(cfg,vsCon',num2str(k),'EarlyComp',num2str(l),'MS);']);
        end;
    end
  
    !@auto_tlrc -apar brain+tlrc -input Con102EarlyComp1MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con102EarlyComp2MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con102EarlyComp3MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con102EarlyComp4MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con104EarlyComp1MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con104EarlyComp2MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con104EarlyComp3MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con104EarlyComp4MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con106EarlyComp1MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con106EarlyComp2MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con106EarlyComp3MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con106EarlyComp4MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con108EarlyComp1MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con108EarlyComp2MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con108EarlyComp3MS+orig -dxyz 5
    !@auto_tlrc -apar brain+tlrc -input Con108EarlyComp4MS+orig -dxyz 5
    
    eval(['clear ActIndex ActWgts SAMHeader ns  sub',num2str(sub),'average sub',num2str(sub),'con102 sub',num2str(sub),'con104 sub',num2str(sub),'con106 sub',num2str(sub),'con108']);
    clear vsCon102EarlyComp1 vsCon102EarlyComp1MS vsCon102EarlyComp2 vsCon102EarlyComp2MS vsCon102EarlyComp3 vsCon102EarlyComp3MS vsCon102EarlyComp4 vsCon102EarlyComp4MS
    clear vsCon104EarlyComp1 vsCon104EarlyComp1MS vsCon104EarlyComp2 vsCon104EarlyComp2MS vsCon104EarlyComp3 vsCon104EarlyComp3MS vsCon104EarlyComp4 vsCon104EarlyComp4MS
    clear vsCon106EarlyComp1 vsCon106EarlyComp1MS vsCon106EarlyComp2 vsCon106EarlyComp2MS vsCon106EarlyComp3 vsCon106EarlyComp3MS vsCon106EarlyComp4 vsCon106EarlyComp4MS
    clear vsCon108EarlyComp1 vsCon108EarlyComp1MS vsCon108EarlyComp2 vsCon108EarlyComp2MS vsCon108EarlyComp3 vsCon108EarlyComp3MS vsCon108EarlyComp4 vsCon108EarlyComp4MS
    disp(sub);
end

% 3dttest early comps
cd /home/meg/Data/Maor/Hypnosis/SAMresults
% run 3dttestComp3 and 3dttestEarlyComps
masktlrc('3dttestComp3Left+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestComp3Right+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestEarlyComp1Left+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestEarlyComp1Right+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestEarlyComp2Left+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestEarlyComp2Right+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestEarlyComp3Left+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestEarlyComp3Right+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestEarlyComp4Left+tlrc','MASKctx+tlrc','_ctx');
masktlrc('3dttestEarlyComp4Right+tlrc','MASKctx+tlrc','_ctx');
