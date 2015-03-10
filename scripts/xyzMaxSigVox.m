% 1. firstly, lets get ridd of the voxels outside the cortex
masktlrc('3dMVM_comp1+tlrc','MASKctx+tlrc','_ctx');

% 2. create your cluster mask based on F threshold in afni and save it.

% (alternative for 2) change the file and the sub brik [k] of the results: 3dMVM_comp1_ctx+tlrc'[0]'
%!3dclust -prefix clusterMaskGroupComp1 -1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -4.303 4.303 -dxyz=1 1.01 20 /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/3dANOVA_comp1_ctx+tlrc'[0]'

%% 
%  ===================== %%
%   from now on do it 6   %
%   times, each time for  %
%      for each comp      %
%  ===================== %%

%% 
%  ===============  for comp 1  =================
%
%% 3. extract the maximum values in each cluster for the group, semantic and interaction between the two
cd /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles
clear all
!3dExtrema -prefix Clust20_group_ext_comp1 -mask_file Clust20_group_comp1_mask+tlrc -data_thr 4.302 -sep_dist 30 -closure -volume 3dMVM_comp1_ctx+tlrc'[0]'
!3dExtrema -prefix Clust20_semantic_ext_comp1 -mask_file Clust20_semantic_comp1_mask+tlrc -data_thr 2.745 -sep_dist 30 -closure -volume 3dMVM_comp1_ctx+tlrc'[1]'
!3dExtrema -prefix Clust20_int_ext_comp1 -mask_file Clust20_int_comp1_mask+tlrc -data_thr 2.745 -sep_dist 30 -closure -volume 3dMVM_comp1_ctx+tlrc'[2]'

% 4. extract the cordinates of the extrene voxels
!3dmaskdump -xyz -nozero -noijk Clust20_group_ext_comp1+tlrc > Clust20_xyzGroup_comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_semantic_ext_comp1+tlrc > Clust20_xyzSemantic_comp1.txt
!3dmaskdump -xyz -nozero -noijk Clust20_int_ext_comp1+tlrc > Clust20_xyzInt_comp1.txt

% 5. creating a matrix of all maximum values for all subs for all condition
% according to the xyzInt file created
%% Group
% each subject power for each extreme voxel in the group effect
con = [13:21 23 25 27:29];
sz = [2:7 9 12 13 15];

voxGrp = importdata('Clust20_xyzGroup_comp1.txt');

val=[];
a = 1;
for subs = con
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/LITcomp1con+tlrc > Clust20_LITvoxValuesGrpComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/CMcomp1con+tlrc > Clust20_CMvoxValuesGrpComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/NMcomp1con+tlrc > Clust20_NMvoxValuesGrpComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/URcomp1con+tlrc > Clust20_URvoxValuesGrpComp1.txt']);

        val = importdata('Clust20_LITvoxValuesGrpComp1.txt'); Clust20_conLITvoxelsComp1Grp(a,i) = val(4); val=[];
        val = importdata('Clust20_CMvoxValuesGrpComp1.txt'); Clust20_conCMvoxelsComp1Grp(a,i) = val(4); val=[];
        val = importdata('Clust20_NMvoxValuesGrpComp1.txt'); Clust20_conNMvoxelsComp1Grp(a,i) = val(4); val=[];
        val = importdata('Clust20_URvoxValuesGrpComp1.txt'); Clust20_conURvoxelsComp1Grp(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a=1;
for subs = sz
    for i = 1:size(voxGrp,1)
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/LITcomp1sz+tlrc > Clust20_LITvoxValuesGrpComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/CMcomp1sz+tlrc > Clust20_CMvoxValuesGrpComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/NMcomp1sz+tlrc > Clust20_NMvoxValuesGrpComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxGrp(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/URcomp1sz+tlrc > Clust20_URvoxValuesGrpComp1.txt']);

        val = importdata('Clust20_LITvoxValuesGrpComp1.txt'); Clust20_szLITvoxelsComp1Grp(a,i) = val(4); val=[];
        val = importdata('Clust20_CMvoxValuesGrpComp1.txt'); Clust20_szCMvoxelsComp1Grp(a,i) = val(4); val=[];
        val = importdata('Clust20_NMvoxValuesGrpComp1.txt'); Clust20_szNMvoxelsComp1Grp(a,i) = val(4); val=[];
        val = importdata('Clust20_URvoxValuesGrpComp1.txt'); Clust20_szURvoxelsComp1Grp(a,i) = val(4); val=[];
    end
    a = a+1;
end

for i=1:length(con)
    eval(['Clust20_conVoxelsComp1Grp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_conLITvoxelsComp1Grp(',num2str(i),',:);Clust20_conCMvoxelsComp1Grp(',num2str(i),',:);Clust20_conNMvoxelsComp1Grp(',num2str(i),',:);Clust20_conURvoxelsComp1Grp(',num2str(i),',:)],1);']);
end
for i=1:length(sz)
    eval(['Clust20_szVoxelsComp1Grp(',num2str(i),',1:size(voxGrp,1)) = mean([Clust20_szLITvoxelsComp1Grp(',num2str(i),',:);Clust20_szCMvoxelsComp1Grp(',num2str(i),',:);Clust20_szNMvoxelsComp1Grp(',num2str(i),',:);Clust20_szURvoxelsComp1Grp(',num2str(i),',:)],1);']);
end

% list of locations of the extreme voxels in the group effect
for i = 1:size(voxGrp,1)
    eval(['!whereami ',num2str(voxGrp(i,1)),' ',num2str(voxGrp(i,2)),' ',num2str(voxGrp(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiGrp{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiGrp{i,1}=wmiGrp{i,1}(2:end);
end

save Clust20_comp1Grp voxGrp wmiGrp Clust20_conVoxelsComp1Grp Clust20_szVoxelsComp1Grp

for i=1:size(voxGrp,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1) = mean(Clust20_conVoxelsComp1Grp(:,',num2str(i),'));']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1) = mean(Clust20_szVoxelsComp1Grp(:,',num2str(i),'));']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1) = std(Clust20_conVoxelsComp1Grp(:,',num2str(i),'))./sqrt(14);']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1) = std(Clust20_szVoxelsComp1Grp(:,',num2str(i),'))./sqrt(10);']);
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

%% Semantic
clear all
con = [13:21 23 25 27:29];
sz = [2:7 9 12 13 15];

voxSem = importdata('Clust20_xyzSemantic_comp1.txt');

% each subject power for each extreme voxel in the semantic effect
val=[];
a = 1;
for subs = con
    for i = 1:size(voxSem,1)
        eval(['!3dmaskdump -xbox ',num2str(voxSem(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/LITcomp1con+tlrc > Clust20_LITvoxValuesSemComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxSem(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/CMcomp1con+tlrc > Clust20_CMvoxValuesSemComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxSem(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/NMcomp1con+tlrc > Clust20_NMvoxValuesSemComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxSem(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/URcomp1con+tlrc > Clust20_URvoxValuesSemComp1.txt']);

        val = importdata('Clust20_LITvoxValuesSemComp1.txt'); Clust20_conLITvoxelsComp1Sem(a,i) = val(4); val=[];
        val = importdata('Clust20_CMvoxValuesSemComp1.txt'); Clust20_conCMvoxelsComp1Sem(a,i) = val(4); val=[];
        val = importdata('Clust20_NMvoxValuesSemComp1.txt'); Clust20_conNMvoxelsComp1Sem(a,i) = val(4); val=[];
        val = importdata('Clust20_URvoxValuesSemComp1.txt'); Clust20_conURvoxelsComp1Sem(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a=1;
for subs = sz
    for i = 1:size(voxSem,1)
        eval(['!3dmaskdump -xbox ',num2str(voxSem(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/LITcomp1sz+tlrc > Clust20_LITvoxValuesSemComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxSem(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/CMcomp1sz+tlrc > Clust20_CMvoxValuesSemComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxSem(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/NMcomp1sz+tlrc > Clust20_NMvoxValuesSemComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxSem(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/URcomp1sz+tlrc > Clust20_URvoxValuesSemComp1.txt']);

        val = importdata('Clust20_LITvoxValuesSemComp1.txt'); Clust20_szLITvoxelsComp1Sem(a,i) = val(4); val=[];
        val = importdata('Clust20_CMvoxValuesSemComp1.txt'); Clust20_szCMvoxelsComp1Sem(a,i) = val(4); val=[];
        val = importdata('Clust20_NMvoxValuesSemComp1.txt'); Clust20_szNMvoxelsComp1Sem(a,i) = val(4); val=[];
        val = importdata('Clust20_URvoxValuesSemComp1.txt'); Clust20_szURvoxelsComp1Sem(a,i) = val(4); val=[];
    end
    a = a+1;
end

Clust20_LITvoxelsComp1Sem = [Clust20_conLITvoxelsComp1Sem;Clust20_szLITvoxelsComp1Sem];
Clust20_CMvoxelsComp1Sem = [Clust20_conCMvoxelsComp1Sem;Clust20_szCMvoxelsComp1Sem];
Clust20_NMvoxelsComp1Sem = [Clust20_conNMvoxelsComp1Sem;Clust20_szNMvoxelsComp1Sem];
Clust20_URvoxelsComp1Sem = [Clust20_conURvoxelsComp1Sem;Clust20_szURvoxelsComp1Sem];

% list of locations of the extreme voxels in the semantic effect
for i = 1:size(voxSem,1)
    eval(['!whereami ',num2str(voxSem(i,1)),' ',num2str(voxSem(i,2)),' ',num2str(voxSem(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiSem{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiSem{i,1}=wmiSem{i,1}(2:end);
end

save Clust20_comp1Sem voxSem wmiSem Clust20_LITvoxelsComp1Sem Clust20_CMvoxelsComp1Sem Clust20_NMvoxelsComp1Sem Clust20_URvoxelsComp1Sem

for i=1:size(voxSem,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1:4) = [mean(Clust20_LITvoxelsComp1Sem(:,',num2str(i),')),mean(Clust20_CMvoxelsComp1Sem(:,',num2str(i),')),mean(Clust20_NMvoxelsComp1Sem(:,',num2str(i),')),mean(Clust20_URvoxelsComp1Sem(:,',num2str(i),'))];']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1:4) = [std(Clust20_LITvoxelsComp1Sem(:,',num2str(i),'))./sqrt(24),std(Clust20_CMvoxelsComp1Sem(:,',num2str(i),'))./sqrt(24),std(Clust20_NMvoxelsComp1Sem(:,',num2str(i),'))./sqrt(24),std(Clust20_URvoxelsComp1Sem(:,',num2str(i),'))./sqrt(24)];']);
end;

% plots for the semantic
for i=1:size(voxSem,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiSem{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(gca, 'XTickLabel', {'LIT','CM','NM','UR'});
end

%% Interaction
clear all
con = [13:21 23 25 27:29];
sz = [2:7 9 12 13 15];

voxInt = importdata('Clust20_xyzInt_comp1.txt');

% each subject power for each extreme voxel in the interaction
val=[];
a = 1;
for subs = con
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/LITcomp1con+tlrc > Clust20_LITvoxValuesIntComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/CMcomp1con+tlrc > Clust20_CMvoxValuesIntComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/NMcomp1con+tlrc > Clust20_NMvoxValuesIntComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/URcomp1con+tlrc > Clust20_URvoxValuesIntComp1.txt']);

        val = importdata('Clust20_LITvoxValuesIntComp1.txt'); Clust20_conLITvoxelsComp1Int(a,i) = val(4); val=[];
        val = importdata('Clust20_CMvoxValuesIntComp1.txt'); Clust20_conCMvoxelsComp1Int(a,i) = val(4); val=[];
        val = importdata('Clust20_NMvoxValuesIntComp1.txt'); Clust20_conNMvoxelsComp1Int(a,i) = val(4); val=[];
        val = importdata('Clust20_URvoxValuesIntComp1.txt'); Clust20_conURvoxelsComp1Int(a,i) = val(4); val=[];
    end
    a = a+1;
end
val=[];
a=1;
for subs = sz
    for i = 1:size(voxInt,1)
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/LITcomp1sz+tlrc > Clust20_LITvoxValuesIntComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/CMcomp1sz+tlrc > Clust20_CMvoxValuesIntComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/NMcomp1sz+tlrc > Clust20_NMvoxValuesIntComp1.txt']);
        eval(['!3dmaskdump -xbox ',num2str(voxInt(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/sz',num2str(subs),'/URcomp1sz+tlrc > Clust20_URvoxValuesIntComp1.txt']);

        val = importdata('Clust20_LITvoxValuesIntComp1.txt'); Clust20_szLITvoxelsComp1Int(a,i) = val(4); val=[];
        val = importdata('Clust20_CMvoxValuesIntComp1.txt'); Clust20_szCMvoxelsComp1Int(a,i) = val(4); val=[];
        val = importdata('Clust20_NMvoxValuesIntComp1.txt'); Clust20_szNMvoxelsComp1Int(a,i) = val(4); val=[];
        val = importdata('Clust20_URvoxValuesIntComp1.txt'); Clust20_szURvoxelsComp1Int(a,i) = val(4); val=[];
    end
    a = a+1;
end

% list of locations of the extreme voxels in the interaction
for i = 1:size(voxInt,1)
    eval(['!whereami ',num2str(voxInt(i,1)),' ',num2str(voxInt(i,2)),' ',num2str(voxInt(i,3)),' -atlas TT_Daemon > wmi.txt']);
    [~,wmiInt{i,1}]=system(['grep point: wmi.txt | cut -d''',':''',' -f2-']);
    wmiInt{i,1}=wmiInt{i,1}(2:end);
end

save Clust20_comp1Int voxInt wmiInt Clust20_conLITvoxelsComp1Int Clust20_conCMvoxelsComp1Int Clust20_conNMvoxelsComp1Int Clust20_conURvoxelsComp1Int...
    Clust20_szLITvoxelsComp1Int Clust20_szCMvoxelsComp1Int Clust20_szNMvoxelsComp1Int Clust20_szURvoxelsComp1Int

for i=1:size(voxInt,1)
    eval(['mean_comp1_voxel_',num2str(i),'(1,1:4) = [mean(Clust20_conLITvoxelsComp1Int(:,',num2str(i),')),mean(Clust20_conCMvoxelsComp1Int(:,',num2str(i),')),mean(Clust20_conNMvoxelsComp1Int(:,',num2str(i),')),mean(Clust20_conURvoxelsComp1Int(:,',num2str(i),'))];']);
    eval(['mean_comp1_voxel_',num2str(i),'(2,1:4) = [mean(Clust20_szLITvoxelsComp1Int(:,',num2str(i),')),mean(Clust20_szCMvoxelsComp1Int(:,',num2str(i),')),mean(Clust20_szNMvoxelsComp1Int(:,',num2str(i),')),mean(Clust20_szURvoxelsComp1Int(:,',num2str(i),'))];']);
    eval(['sd_comp1_voxel_',num2str(i),'(1,1:4) = [std(Clust20_conLITvoxelsComp1Int(:,',num2str(i),'))./sqrt(14),std(Clust20_conCMvoxelsComp1Int(:,',num2str(i),'))./sqrt(14),std(Clust20_conNMvoxelsComp1Int(:,',num2str(i),'))./sqrt(14),std(Clust20_conURvoxelsComp1Int(:,',num2str(i),'))./sqrt(14)];']);
    eval(['sd_comp1_voxel_',num2str(i),'(2,1:4) = [std(Clust20_szLITvoxelsComp1Int(:,',num2str(i),'))./sqrt(10),std(Clust20_szCMvoxelsComp1Int(:,',num2str(i),'))./sqrt(10),std(Clust20_szNMvoxelsComp1Int(:,',num2str(i),'))./sqrt(10),std(Clust20_szURvoxelsComp1Int(:,',num2str(i),'))./sqrt(10)];']);
end;

% plots for the interaction
for i=1:size(voxInt,1)
    figure;
    eval(['h1 = barwitherr(sd_comp1_voxel_',num2str(i),''',mean_comp1_voxel_',num2str(i),''');']);
    ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i});
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'LIT','CM','NM','UR'});
    legend('control','schizophrenia');
end

clear all
load Clust20_comp1Grp
load Clust20_comp1Sem
load Clust20_comp1Int
save Clust20_comp1ext

%% making a big tables for SPSS
javaaddpath('/home/meg/ft_BIU/matlab/files/jxl.jar')
javaaddpath('/home/meg/ft_BIU/matlab/files/MXL.jar')

comp1int = [Clust20_conLITvoxelsComp1Int Clust20_conCMvoxelsComp1Int Clust20_conNMvoxelsComp1Int Clust20_conURvoxelsComp1Int;...
    Clust20_szLITvoxelsComp1Int Clust20_szCMvoxelsComp1Int Clust20_szNMvoxelsComp1Int Clust20_szURvoxelsComp1Int];
comp1grp = [Clust20_conVoxelsComp1Grp; Clust20_szVoxelsComp1Grp];
comp1Sem = [Clust20_LITvoxelsComp1Sem Clust20_CMvoxelsComp1Sem Clust20_NMvoxelsComp1Sem Clust20_URvoxelsComp1Sem];

% interaction
d = {'Group'};
conds = {'LIT','CM','NM','UR'};
for j = 1:length(conds)
    cond = conds{j};
    for i = 1:size(voxInt,1)
        d1 = sprintf('%svox%d',cond,i);
        d = [d d1];
    end
end
for i = 1:14
    b = num2cell([1 Clust20_conLITvoxelsComp1Int(i,:) Clust20_conCMvoxelsComp1Int(i,:) Clust20_conNMvoxelsComp1Int(i,:) Clust20_conURvoxelsComp1Int(i,:)]);
    d = [d; b];
end
for i = 1:10
    b = num2cell([2 Clust20_szLITvoxelsComp1Int(i,:) Clust20_szCMvoxelsComp1Int(i,:) Clust20_szNMvoxelsComp1Int(i,:) Clust20_szURvoxelsComp1Int(i,:)]);
    d = [d; b];
end

xlwrite('comp1Int.xls', d);

% group
clear b;
d = {};
d1= {};
d2= {};
for i = 1:size(voxGrp,1)
    p1 = sprintf('conVox%d',i);
    p2 = sprintf('szVox%d',i);
    d1 = [d1 p1];
    d2 = [d2 p2];
end;
d = [d1 d2];

for i = 1:14
    if i < 11
        b = num2cell([Clust20_conVoxelsComp1Grp(i,:) Clust20_szVoxelsComp1Grp(i,:)]);
        d = [d; b];
    else
        b = num2cell([Clust20_conVoxelsComp1Grp(i,:) ones(1,size(voxGrp,1))*(-1000)]);
        d = [d; b];
    end
end

xlwrite('comp1Grp.xls', d);

% semantic
clear b d1
d = {};
conds = {'LIT','CM','NM','UR'};
for j = 1:length(conds)
    cond = conds{j};
    for i = 1:size(voxSem,1)
        d1 = sprintf('%svox%d',cond,i);
        d = [d d1];
    end
end
for i = 1:24
    b = num2cell([Clust20_LITvoxelsComp1Sem(i,:) Clust20_CMvoxelsComp1Sem(i,:) Clust20_NMvoxelsComp1Sem(i,:) Clust20_URvoxelsComp1Sem(i,:)]);
    d = [d; b];
end

xlwrite('comp1Sem.xls', d);

%% presenting the functional data in Suma

% copy into the folder 'templateSurface' the files I want to present.
% open terminal and cd to the folder and then:
% afni -niml -dset temp+tlrc &
% suma -spec temp_both.spec -sv temp+tlrc

% click somewhere on the suma and press 't'
% with < > [ ] buttons I can do magic.
% type ctrl+h for the list of shortcuts.

%% plotting
% % group
% for i=1:size(voxGrp,1)
%     eval(['grp_mean_comp1_voxel_',num2str(i),'(1,1) = mean(conVoxelsComp1Grp(:,',num2str(i),'));']);
%     eval(['grp_mean_comp1_voxel_',num2str(i),'(2,1) = mean(szVoxelsComp1Grp(:,',num2str(i),'));']);
%     eval(['grp_sd_comp1_voxel_',num2str(i),'(1,1) = std(conVoxelsComp1Grp(:,',num2str(i),'))./sqrt(14);']);
%     eval(['grp_sd_comp1_voxel_',num2str(i),'(2,1) = std(szVoxelsComp1Grp(:,',num2str(i),'))./sqrt(10);']);
% end;
% 
% for i=1:size(voxGrp,1)
%     figure;
%     eval(['h1 = barwitherr(grp_sd_comp1_voxel_',num2str(i),''',grp_mean_comp1_voxel_',num2str(i),''');']);
%     ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiGrp{i})
%     title(ti)
%     ylabel('Power');
%     %ylim([0 2.5]);
%     xlim([0 3]);
%     set(h1(1), 'facecolor', [1 1 1]);
%     set(gca, 'XTickLabel', {'control','schizophrenia'});
% end
% 
% % semantic
% for i=1:size(voxSem,1)
%     eval(['sem_mean_comp1_voxel_',num2str(i),'(1,1:4) = [mean(LITvoxelsComp1Sem(:,',num2str(i),')),mean(CMvoxelsComp1Sem(:,',num2str(i),')),mean(NMvoxelsComp1Sem(:,',num2str(i),')),mean(URvoxelsComp1Sem(:,',num2str(i),'))];']);
%     eval(['sem_sd_comp1_voxel_',num2str(i),'(1,1:4) = [std(LITvoxelsComp1Sem(:,',num2str(i),'))./sqrt(24),std(CMvoxelsComp1Sem(:,',num2str(i),'))./sqrt(24),std(NMvoxelsComp1Sem(:,',num2str(i),'))./sqrt(24),std(URvoxelsComp1Sem(:,',num2str(i),'))./sqrt(24)];']);
% end;
% 
% for i=1:size(voxSem,1)
%     figure;
%     eval(['h1 = barwitherr(sem_sd_comp1_voxel_',num2str(i),''',sem_mean_comp1_voxel_',num2str(i),''');']);
%     ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiSem{i})
%     title(ti)
%     ylabel('Power');
%     %ylim([0 2.5]);
%     set(h1(1), 'facecolor', [1 1 1]);
%     set(gca, 'XTickLabel', {'LIT','CM','NM','UR'});
% end
% 
% % interaction
% for i=1:size(voxInt,1)
%     eval(['int_mean_comp1_voxel_',num2str(i),'(1,1:4) = [mean(conLITvoxelsComp1Int(:,',num2str(i),')),mean(conCMvoxelsComp1Int(:,',num2str(i),')),mean(conNMvoxelsComp1Int(:,',num2str(i),')),mean(conURvoxelsComp1Int(:,',num2str(i),'))];']);
%     eval(['int_mean_comp1_voxel_',num2str(i),'(2,1:4) = [mean(szLITvoxelsComp1Int(:,',num2str(i),')),mean(szCMvoxelsComp1Int(:,',num2str(i),')),mean(szNMvoxelsComp1Int(:,',num2str(i),')),mean(szURvoxelsComp1Int(:,',num2str(i),'))];']);
%     eval(['int_sd_comp1_voxel_',num2str(i),'(1,1:4) = [std(conLITvoxelsComp1Int(:,',num2str(i),'))./sqrt(14),std(conCMvoxelsComp1Int(:,',num2str(i),'))./sqrt(14),std(conNMvoxelsComp1Int(:,',num2str(i),'))./sqrt(14),std(conURvoxelsComp1Int(:,',num2str(i),'))./sqrt(14)];']);
%     eval(['int_sd_comp1_voxel_',num2str(i),'(2,1:4) = [std(szLITvoxelsComp1Int(:,',num2str(i),'))./sqrt(10),std(szCMvoxelsComp1Int(:,',num2str(i),'))./sqrt(10),std(szNMvoxelsComp1Int(:,',num2str(i),'))./sqrt(10),std(szURvoxelsComp1Int(:,',num2str(i),'))./sqrt(10)];']);
% end;
% 
% for i=1:size(voxInt,1)
%     figure;
%     eval(['h1 = barwitherr(int_sd_comp1_voxel_',num2str(i),''',int_mean_comp1_voxel_',num2str(i),''');']);
%     ti = sprintf('Comp 1 voxel %s - %s',num2str(i),wmiInt{i})
%     title(ti)
%     ylabel('Power');
%     %ylim([0 2.5]);
%     set(h1(1), 'facecolor', [1 1 1]);
%     set(h1(2), 'facecolor', [0 0 0]);
%     set(gca, 'XTickLabel', {'LIT','CM','NM','UR'});
%     legend('control','schizophrenia');
% end