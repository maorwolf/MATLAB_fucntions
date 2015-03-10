% 1. fit MRI to HS
fitMRI2hs('c,rfhp0.1Hz,ee') % don't use if have individual MRI

% 2 creating HS+orig files
hs2afni()

% 2.5 Nudging:
% ------------
% open a terminal and cd to the subject folder and then type "afni"
% 2.5.1 from the terminal open afni and define: overlay = hs, underlay =
% warped
% 2.5.2 go to Define datamode > plugins > nudge dataset
% 2.5.3 click on "choose dataset" and choose "warped"
% 2.5.4 now nudge. When you are done type "do
% all" and then quit.

% 2.6 creating hull file:
!~/abin/3dSkullStrip -input warped+orig -prefix mask -mask_vol -skulls -o_ply ortho

% 2.7 back to afni, define: overlay = mask, underlay = warped
% Check that there is a good fit.

% 2.8 creating brain file: in MATLAB:
!~/abin/3dcalc -a warped+orig -b mask+orig -prefix brain -expr 'a*step(b-2.9)'

% 2.9 creating a tlrc file: in the terminal type: 
% "@auto_tlrc -base TT_N27+tlrc -input brain+orig -no_ss -pad_base 60"

% 2.10 creating the final hull.shape file:
!meshnorm ortho_brainhull.ply > hull.shape