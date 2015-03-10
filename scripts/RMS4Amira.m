%% RMS for Amira
clear all
% 110 - 4%green
% 120 - 64%green
% 210 - 4%red
% 220 - 64%red
for i=1:19
    eval(['load amira',num2str(i),'_c/averagedata']);
end
szL = [19 18 15 14 13 11 9 8 3 1];
szH = [17 16 12 10 7 6 5 4 2];

time = sub1average.time;

cfg = [];
cfg.keepindividual = 'no';
cfg.channel        = {'MEG', '-A204'};
grAvg = ft_timelockgrandaverage(cfg, sub1average, sub2average, sub3average, sub4average, sub5average, sub6average, sub7average, sub8average, sub9average,...
    sub10average, sub11average, sub12average, sub13average, sub14average, sub15average, sub16average, sub17average, sub18average, sub19average);
grAvgSZL = ft_timelockgrandaverage(cfg, sub1average, sub2average, sub4average, sub5average, sub6average, sub7average, sub10average, sub12average, sub16average, sub19average);
grAvgSZH = ft_timelockgrandaverage(cfg, sub2average, sub4average, sub5average, sub6average, sub7average, sub10average, sub12average, sub16average, sub17average);

figure;plot(grAvg.time,grAvg.avg,'b');
figure;plot(grAvgSZL.time, grAvgSZL.avg,'b');
hold on;plot(grAvgSZH.time, grAvgSZH.avg,'r');
title('blue - low, red - high');

% RMS
for i=1:19
    for j=[110 120 210 220]
        eval(['sub',num2str(i),'RMScon',num2str(j),'=sqrt(mean(sub',num2str(i),'con',num2str(j),'.avg.^2,1));']);
    end
end

% averaged RMS
con110SZL = [sub1RMScon110; sub3RMScon110; sub8RMScon110; sub9RMScon110; sub11RMScon110; sub13RMScon110; sub14RMScon110; sub15RMScon110;...
    sub18RMScon110; sub19RMScon110];
con120SZL = [sub1RMScon120; sub3RMScon120; sub8RMScon120; sub9RMScon120; sub11RMScon120; sub13RMScon120; sub14RMScon120; sub15RMScon120;...
    sub18RMScon120; sub19RMScon120];
con210SZL = [sub1RMScon210; sub3RMScon210; sub8RMScon210; sub9RMScon210; sub11RMScon210; sub13RMScon210; sub14RMScon210; sub15RMScon210;...
    sub18RMScon210; sub19RMScon210];
con220SZL = [sub1RMScon220; sub3RMScon220; sub8RMScon220; sub9RMScon220; sub11RMScon220; sub13RMScon220; sub14RMScon220; sub15RMScon220;...
    sub18RMScon220; sub19RMScon220];

con110SZH = [sub2RMScon110; sub4RMScon110; sub5RMScon110; sub6RMScon110; sub7RMScon110; sub10RMScon110; sub12RMScon110; sub13RMScon110;...
    sub16RMScon110];
con120SZH = [sub2RMScon120; sub4RMScon120; sub5RMScon120; sub6RMScon120; sub7RMScon120; sub10RMScon120; sub12RMScon120; sub13RMScon120;...
    sub16RMScon120];
con210SZH = [sub2RMScon210; sub4RMScon210; sub5RMScon210; sub6RMScon210; sub7RMScon210; sub10RMScon210; sub12RMScon210; sub13RMScon210;...
    sub16RMScon210];
con220SZH = [sub2RMScon220; sub4RMScon220; sub5RMScon220; sub6RMScon220; sub7RMScon220; sub10RMScon220; sub12RMScon220; sub13RMScon220;...
    sub16RMScon220];

save RMSamira con110SZH con110SZL con120SZH con120SZL con210SZH con210SZL con220SZH con220SZL time
clear all
load RMSamira

figure
subplot(2,2,1)
plot(time,mean(con110SZH),'--b');hold on;plot(time,mean(con110SZL),'b');title('4% green; --blue - low, -blue - high');
subplot(2,2,2)
plot(time,mean(con120SZH),'--b');hold on;plot(time,mean(con120SZL),'b');title('64% green; --blue - low, -blue - high');
subplot(2,2,3)
plot(time,mean(con210SZH),'--b');hold on;plot(time,mean(con210SZL),'b');title('4% red; --blue - low, -blue - high');
subplot(2,2,4)
plot(time,mean(con220SZH),'--b');hold on;plot(time,mean(con220SZL),'b');title('64% red; --blue - low, -blue - high');

% comp1 70-100ms
comp1=zeros(19,4);
comp1(:,1) = [mean(con110SZL(:,nearest(time,0.07):nearest(time,0.1)),2); mean(con110SZH(:,nearest(time,0.07):nearest(time,0.1)),2)];
comp1(:,2) = [mean(con120SZL(:,nearest(time,0.07):nearest(time,0.1)),2); mean(con120SZH(:,nearest(time,0.07):nearest(time,0.1)),2)];
comp1(:,3) = [mean(con210SZL(:,nearest(time,0.07):nearest(time,0.1)),2); mean(con210SZH(:,nearest(time,0.07):nearest(time,0.1)),2)];
comp1(:,4) = [mean(con220SZL(:,nearest(time,0.07):nearest(time,0.1)),2); mean(con220SZH(:,nearest(time,0.07):nearest(time,0.1)),2)];
% comp2 110-160ms
comp2=zeros(19,4);
comp2(:,1) = [mean(con110SZL(:,nearest(time,0.11):nearest(time,0.16)),2); mean(con110SZH(:,nearest(time,0.11):nearest(time,0.16)),2)];
comp2(:,2) = [mean(con120SZL(:,nearest(time,0.11):nearest(time,0.16)),2); mean(con120SZH(:,nearest(time,0.11):nearest(time,0.16)),2)];
comp2(:,3) = [mean(con210SZL(:,nearest(time,0.11):nearest(time,0.16)),2); mean(con210SZH(:,nearest(time,0.11):nearest(time,0.16)),2)];
comp2(:,4) = [mean(con220SZL(:,nearest(time,0.11):nearest(time,0.16)),2); mean(con220SZH(:,nearest(time,0.11):nearest(time,0.16)),2)];
% comp3 160-220ms
comp3=zeros(19,4);
comp3(:,1) = [mean(con110SZL(:,nearest(time,0.16):nearest(time,0.22)),2); mean(con110SZH(:,nearest(time,0.16):nearest(time,0.22)),2)];
comp3(:,2) = [mean(con120SZL(:,nearest(time,0.16):nearest(time,0.22)),2); mean(con120SZH(:,nearest(time,0.16):nearest(time,0.22)),2)];
comp3(:,3) = [mean(con210SZL(:,nearest(time,0.16):nearest(time,0.22)),2); mean(con210SZH(:,nearest(time,0.16):nearest(time,0.22)),2)];
comp3(:,4) = [mean(con220SZL(:,nearest(time,0.16):nearest(time,0.22)),2); mean(con220SZH(:,nearest(time,0.16):nearest(time,0.22)),2)];

comp1=comp1.*10^14;
comp2=comp2.*10^14;
comp3=comp3.*10^14;

%%
con110=[con110SZH;con110SZL];
con120=[con120SZH;con120SZL];
con210=[con210SZH;con210SZL];
con220=[con220SZH;con220SZL];

figure
subplot(1,2,1)
plot(time,mean(con110),'--b');hold on;plot(time,mean(con210),'b');title('4% -- green - red');
subplot(1,2,2)
plot(time,mean(con120),'--b');hold on;plot(time,mean(con220),'b');title('64% -- green - red');
