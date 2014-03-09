
% create your cluster mask based on F threshold.
!3dclust -prefix clusterMaskGroupComp4 -1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -4.303 4.303 -dxyz=1 1.01 20 /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/3dANOVA_comp4_ctx+tlrc'[0]'


!3dExtrema -prefix groupF_ext -mask_file clusterMaskGroupComp4+tlrc -data_thr 4.302 -sep_dist 30 -closure -volume 3dANOVA_comp4_ctx+tlrc'[0]'


!3dmaskdump -xyz -nozero -noijk groupF_ext+tlrc > xyz.txt

voxels=importdata('xyz.txt');
voxels=voxels(:,1:3);
for subs = [
for i = 1:size(voxels,1)
    eval(['!3dmaskdump -xbox ',num2str(voxels(i,1:3)),' /home/meg/Data/Maor/PhD_SAM/AllSubsSAMfiles/con',num2str(subs),'/LITcomp4con+tlrc >> LITvoxValues.txt']);
