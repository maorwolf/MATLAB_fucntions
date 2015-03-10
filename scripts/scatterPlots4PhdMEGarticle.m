%% scatter plots for RSC with age and group
M350_SZ = [0.2962456306 0.573417375 0.3385766875 0.22071525 0.438349664 0.2327604769 0.3214479559 1.0514046667 0.0200900371 0.4675730574;...
    53 32 50 34 24 27 60 21 30 33];
M350_CON = [3.02659 1.4363888125 1.0337429497 0.2807041889 2.0048575039 0.4363267821 2.370527875 1.1731073287 0.5756230273 2.02889875,...
    0.917666375 1.13822725 1.1729591881 2.158097; 30 33 27 28 28 35 25 32 25 25 28 27 27 36];
M170_SZ = [0.22141 0.36748 0.21239 0.26248 0.0015558 0.49504 0.0085455 0.1594 0.069397 0.30599; 53 32 50 34 24 27 60 21 30 33];
M170_CON = [0.025183 0.0052318 1.523e-06 0 0.0014568 0.10803 1.52e-05 0.0016754 0.013846 1.7508e-06 0 7.4231e-07 0.051623 0.29234;...
    30 33 27 28 28 35 25 32 25 25 28 27 27 36];
M170_UR_left = [3.1408,0,1.4252,5.8897e-05,0,2.7036,0,2.1063,0.046761,1.4342,0,0.000257,0.009892,0,0.0001,0.01,0,0,0.02,0,0.0004,0,0,0;...
    53 32 50 34 24 27 60 21 30 33 30 33 27 28 28 35 25 32 25 25 28 27 27 36]';
M170_int_right = [0.44089 0.73465 0.168615 0.48614 0.002764153185 0.990075 0.016005 0.31835 0.121799 0.611999 0.050365 0.008946 0 0.0007 0.0029135 0 3.0401e-05 0.0009335 0.001202 0 0.0003 0 0.00107068 0;...
    53 32 50 34 24 27 60 21 30 33 30 33 27 28 28 35 25 32 25 25 28 27 27 36]';

gender =[1,1,1,1,1,1,0,1,1,1,0,1,1,1,1,1,1,1,0,1,0,0,0,0];

figure;
subplot(2,2,1)
scatter(M170_SZ(2,:),M170_SZ(1,:),50,'k','filled');
ylim([-0.01 0.5]);
hold on;
scatter(M170_CON(2,:),M170_CON(1,:),50,'k');
%title('M170 main effect for group');
%legend('SZ','Control');
subplot(2,2,2)
scatter(M350_SZ(2,:),M350_SZ(1,:),50,'k','filled');
ylim([-0.1 3.5]);
hold on;
scatter(M350_CON(2,:),M350_CON(1,:),50,'k');
%title('M350 main effect for group');
%legend('SZ','Control');
subplot(2,2,3)
scatter(M170_UR_left(1:10,2),M170_UR_left(1:10,1),50,'k','filled');
ylim([-0.1 3.5]);
hold on;
scatter(M170_UR_left(11:24,2),M170_UR_left(11:24,1),50,'k');
%title('M170 groupXtype UR left cluster');
%legend('SZ','Control');
subplot(2,2,4)
scatter(M170_int_right(1:10,2),M170_int_right(1:10,1),50,'k','filled');
ylim([-0.05 1.1]);
hold on;
scatter(M170_int_right(11:24,2),M170_int_right(11:24,1),50,'k');
%title('M170 groupXtype NM+UR right cluster');
%legend('SZ','Control');
%% corelations with age
M170forCorr = [M170_SZ'; M170_CON'];
[r_M170,rp_M170] = corr(M170forCorr);
M350forCorr = [M350_SZ'; M350_CON'];
[r_M350,rp_M350] = corr(M350forCorr);
[r_M170_int_right,rp_M170_int_right] = corr(M170_int_right);
[r_M170_UR_left,rp_M170_UR_left] = corr(M170_UR_left);

%% ttests with gender for all subs
M170grp = [M170_SZ(1,:) M170_CON(1,:)];
M350grp = [M350_SZ(1,:) M350_CON(1,:)];
M170intRight = M170_int_right(:,1)';
M170intLeft = M170_UR_left(:,1)';

M170grpM = M170grp(find(gender));
M170grpFM = M170grp(find(~gender));
M350grpM = M350grp(find(gender));
M350grpFM = M350grp(find(~gender));
M170intRightM = M170intRight(find(gender));
M170intRightFM = M170intRight(find(~gender));
M170intLeftM = M170intLeft(find(gender));
M170intLeftFM = M170intLeft(find(~gender));

[H,P,CI,STATS] = ttest2(M170grpM,M170grpFM);
[H,P,CI,STATS] = ttest2(M350grpM,M350grpFM);
[H,P,CI,STATS] = ttest2(M170intRightM,M170intRightFM);
[H,P,CI,STATS] = ttest2(M170intLeftM,M170intLeftFM);

%% ttests with gender for control group
gender = [0,1,1,1,1,1,1,1,0,1,0,0,0,0];
M170intRight = M170_int_right(11:24,1)';
M170intLeft = M170_UR_left(11:24,1)';

M170grpM = M170_CON(1,find(gender));
M170grpFM = M170_CON(1,find(~gender));
M350grpM = M350_CON(1,find(gender));
M350grpFM = M350_CON(1,find(~gender));
M170intRightM = M170intRight(1,find(gender));
M170intRightFM = M170intRight(1,find(~gender));
M170intLeftM = M170intLeft(1,find(gender));
M170intLeftFM = M170intLeft(1,find(~gender));

[H,P,CI,STATS] = ttest2(M170grpM,M170grpFM);
[H,P,CI,STATS] = ttest2(M350grpM,M350grpFM);
[H,P,CI,STATS] = ttest2(M170intRightM,M170intRightFM);
[H,P,CI,STATS] = ttest2(M170intLeftM,M170intLeftFM);

%% ttests for group just for men
genderSZ = [1,1,1,1,1,1,0,1,1,1];
genderCON = [0,1,1,1,1,1,1,1,0,1,0,0,0,0];

M170_SZm = M170_SZ(1,find(genderSZ));
M170_CONm = M170_CON(1,find(genderCON));

M350_SZm = M350_SZ(1,find(genderSZ));
M350_CONm = M350_CON(1,find(genderCON));

M170intLeft_SZm = M170_UR_left';
M170intLeft_SZm = M170intLeft_SZm(1,1:10);
M170intLeft_SZm = M170intLeft_SZm(1,find(genderSZ));

M170intLeft_CONm = M170_UR_left';
M170intLeft_CONm = M170intLeft_CONm(1,11:24);
M170intLeft_CONm = M170intLeft_CONm(1,find(genderCON));

M170intRight_SZm = M170_int_right';
M170intRight_SZm = M170intRight_SZm(1,1:10);
M170intRight_SZm = M170intRight_SZm(1,find(genderSZ));

M170intRight_CONm = M170_int_right';
M170intRight_CONm = M170intRight_CONm(1,11:24);
M170intRight_CONm = M170intRight_CONm(1,find(genderCON));

[H,P,CI,STATS] = ttest2(M170_SZm,M170_CONm);
[H,P,CI,STATS] = ttest2(M350_SZm,M350_CONm);
[H,P,CI,STATS] = ttest2(M170intLeft_SZm,M170intLeft_CONm);
[H,P,CI,STATS] = ttest2(M170intRight_SZm,M170intRight_CONm);