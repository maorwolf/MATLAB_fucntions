clear all
for i=[2:7 9 12 13 15]
    eval(['cd /home/meg/Data/Maor/PhD_SAM/SZ/sub',num2str(i)]);
    eval(['load sub',num2str(i),'avconds']);
    for j=[10 20 30 40]
        eval(['sub',num2str(i),'avcond',num2str(j),'RMS=sqrt(mean(sub',num2str(i),'avcond',num2str(j),'.avg.^2)) - mean(sqrt(mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,1:203).^2)));']);
    end
    eval(['sub',num2str(i),'allRMS=mean([sub',num2str(i),'avcond10RMS; sub',num2str(i),'avcond20RMS; sub',num2str(i),'avcond30RMS; sub',num2str(i),'avcond40RMS]);']);
end


avgSZRMS = ([sub2allRMS; sub3allRMS; sub4allRMS; sub5allRMS; sub6allRMS; sub7allRMS; sub9allRMS; ...
    sub12allRMS; sub13allRMS; sub15allRMS]);

a=1;
for i=[2:7 9 12 13 15]
    for j=[10 20 30 40]
        eval(['szCond',num2str(j),'(a,:) = sub',num2str(i),'avcond',num2str(j),'RMS;']);
    end
    a=a+1;
end

for i=[13:21 23 25 27:29]
    eval(['cd /home/meg/Data/Maor/PhD_SAM/control/sub',num2str(i)]);
    eval(['load sub',num2str(i),'avconds']);
    for j=[10 20 30 40]
        eval(['sub',num2str(i),'avcond',num2str(j),'RMS=sqrt(mean(sub',num2str(i),'avcond',num2str(j),'.avg.^2)) - mean(sqrt(mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,1:203).^2)));']);
    end
    eval(['sub',num2str(i),'allRMS=mean([sub',num2str(i),'avcond10RMS; sub',num2str(i),'avcond20RMS; sub',num2str(i),'avcond30RMS; sub',num2str(i),'avcond40RMS]);']);
end

avgConRMS = ([sub13allRMS; sub14allRMS; sub15allRMS; sub16allRMS; sub17allRMS; sub18allRMS; sub19allRMS; ...
    sub20allRMS; sub21allRMS; sub23allRMS; sub25allRMS; sub27allRMS; sub28allRMS; sub29allRMS]);

a=1;
for i=[13:21 23 25 27:29]
    for j=[10 20 30 40]
        eval(['conCond',num2str(j),'(a,:) = sub',num2str(i),'avcond',num2str(j),'RMS;']);
    end
    a=a+1;
end

SZstd = std(avgSZRMS)/sqrt(10);
conStd = std(avgConRMS)/sqrt(14);

save /home/meg/Data/Maor/PhD_SAM/RMS avgSZRMS avgConRMS time conStd SZstd

plot(time, mean(avgSZRMS), 'b');
hold on;
plot(time, mean(avgConRMS), 'r');
jbfill(time,mean(avgSZRMS)+SZstd,mean(avgSZRMS)-SZstd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,mean(avgConRMS)+conStd,mean(avgConRMS)-conStd,[1,0,0],[1,0,0],0,0.3)
grid;

% average components
comp1 = [[mean(szCond10(:,nearest(time,0.06):nearest(time,0.12)),2); mean(conCond10(:,nearest(time,0.06):nearest(time,0.12)),2)],...
    [mean(szCond20(:,nearest(time,0.06):nearest(time,0.12)),2); mean(conCond20(:,nearest(time,0.06):nearest(time,0.12)),2)],...
    [mean(szCond30(:,nearest(time,0.06):nearest(time,0.12)),2); mean(conCond30(:,nearest(time,0.06):nearest(time,0.12)),2)],...
    [mean(szCond40(:,nearest(time,0.06):nearest(time,0.12)),2); mean(conCond40(:,nearest(time,0.06):nearest(time,0.12)),2)]];

comp2 = [[mean(szCond10(:,nearest(time,0.12):nearest(time,0.22)),2); mean(conCond10(:,nearest(time,0.12):nearest(time,0.22)),2)],...
    [mean(szCond20(:,nearest(time,0.12):nearest(time,0.22)),2); mean(conCond20(:,nearest(time,0.12):nearest(time,0.22)),2)],...
    [mean(szCond30(:,nearest(time,0.12):nearest(time,0.22)),2); mean(conCond30(:,nearest(time,0.12):nearest(time,0.22)),2)],...
    [mean(szCond40(:,nearest(time,0.12):nearest(time,0.22)),2); mean(conCond40(:,nearest(time,0.12):nearest(time,0.22)),2)]];

comp3 = [[mean(szCond10(:,nearest(time,0.22):nearest(time,0.3)),2); mean(conCond10(:,nearest(time,0.22):nearest(time,0.3)),2)],...
    [mean(szCond20(:,nearest(time,0.22):nearest(time,0.3)),2); mean(conCond20(:,nearest(time,0.22):nearest(time,0.3)),2)],...
    [mean(szCond30(:,nearest(time,0.22):nearest(time,0.3)),2); mean(conCond30(:,nearest(time,0.22):nearest(time,0.3)),2)],...
    [mean(szCond40(:,nearest(time,0.22):nearest(time,0.3)),2); mean(conCond40(:,nearest(time,0.22):nearest(time,0.3)),2)]];

comp4 = [[mean(szCond10(:,nearest(time,0.3):nearest(time,0.42)),2); mean(conCond10(:,nearest(time,0.3):nearest(time,0.42)),2)],...
    [mean(szCond20(:,nearest(time,0.3):nearest(time,0.42)),2); mean(conCond20(:,nearest(time,0.3):nearest(time,0.42)),2)],...
    [mean(szCond30(:,nearest(time,0.3):nearest(time,0.42)),2); mean(conCond30(:,nearest(time,0.3):nearest(time,0.42)),2)],...
    [mean(szCond40(:,nearest(time,0.3):nearest(time,0.42)),2); mean(conCond40(:,nearest(time,0.3):nearest(time,0.42)),2)]];

comp5 = [[mean(szCond10(:,nearest(time,0.42):nearest(time,0.55)),2); mean(conCond10(:,nearest(time,0.42):nearest(time,0.55)),2)],...
    [mean(szCond20(:,nearest(time,0.42):nearest(time,0.55)),2); mean(conCond20(:,nearest(time,0.42):nearest(time,0.55)),2)],...
    [mean(szCond30(:,nearest(time,0.42):nearest(time,0.55)),2); mean(conCond30(:,nearest(time,0.42):nearest(time,0.55)),2)],...
    [mean(szCond40(:,nearest(time,0.42):nearest(time,0.55)),2); mean(conCond40(:,nearest(time,0.42):nearest(time,0.55)),2)]];

allCompsRMS = [comp1, comp2, comp3, comp4, comp5];
allCompsRMS = allCompsRMS*10^14;
save allCompsRMS allCompsRMS

meanSZ =mean(allCompsRMS(1:10,:));
meanCon=mean(allCompsRMS(11:24,:));
sdSZ   =std(allCompsRMS(1:10,:));
sdCon  =std(allCompsRMS(11:24,:));

meanAll = [meanSZ;meanCon];
sdAll   = [sdSZ;sdCon];

% ploting
a=1;
for i=[1 5 9 13 17]
    figure;
    eval(['h1 = barwitherr(sdAll(:,',num2str(i),':(',num2str(i),'+3)),meanAll(:,',num2str(i),':(',num2str(i),'+3)));']);
    ti = sprintf('Comp %s',num2str(a));
    title(ti)
    ylabel('Power');
    %ylim([0 2.5]);
    set(h1(1), 'facecolor', [1 1 1]);
    set(h1(2), 'facecolor', [0 0 0]);
    set(gca, 'XTickLabel', {'schizophrenia','control'});
    legend('LIT','CM','NM','UR');
    a=a+1;
end


%% comp4 plot (based on old analysis)
means=[1.9472*10^(-14);2.6716*10^(-14)];
sds=[0.81053*10^(-14);0.64619*10^(-14)];
h=barwitherr(sds,means);
title('0.3 - 0.4 s')
set(h(1), 'facecolor', [1 1 1]);
xlim([0 3])
set(gca, 'XTickLabel', {'schizophrenia','control'});





%% first averaging the conditions and then doing RMS for each subject and then averaging the RMSs

clear all
for i=[2:7 9 12 13 15]
    eval(['cd /home/meg/Data/Maor/PhD_SAM/SZ/sub',num2str(i)]);
    eval(['load sub',num2str(i),'avconds']);
    eval(['sub',num2str(i),'avconds=(sub',num2str(i),'avcond10.avg+sub',num2str(i),'avcond20.avg+sub',num2str(i),'avcond30.avg+sub',num2str(i),'avcond40.avg)./4;']);
    eval(['sub',num2str(i),'RMS=sqrt(mean(sub',num2str(i),'avconds.^2)) - mean(sqrt(mean(sub',num2str(i),'avconds(:,1:203).^2)));']);
end

avgSZRMS = ([sub2RMS; sub3RMS; sub4RMS; sub5RMS; sub6RMS; sub7RMS; sub9RMS; ...
    sub12RMS; sub13RMS; sub15RMS]);

for i=[13:21 23 25 27:29]
    eval(['cd /home/meg/Data/Maor/PhD_SAM/control/sub',num2str(i)]);
    eval(['load sub',num2str(i),'avconds']);
    eval(['sub',num2str(i),'avconds=(sub',num2str(i),'avcond10.avg+sub',num2str(i),'avcond20.avg+sub',num2str(i),'avcond30.avg+sub',num2str(i),'avcond40.avg)./4;']);
    eval(['sub',num2str(i),'RMS=sqrt(mean(sub',num2str(i),'avconds.^2)) - mean(sqrt(mean(sub',num2str(i),'avconds(:,1:203).^2)));']);
end

avgConRMS = ([sub13RMS; sub14RMS; sub15RMS; sub16RMS; sub17RMS; sub18RMS; sub19RMS; ...
    sub20RMS; sub21RMS; sub23RMS; sub25RMS; sub27RMS; sub28RMS; sub29RMS]);

RMS.SZ_mean = mean(avgSZRMS);
RMS.SZ_se = std(avgSZRMS)./sqrt(10);
RMS.con_mean = mean(avgConRMS);
RMS.con_se = std(avgConRMS)./sqrt(14);

save RMS1

% ploting

plot(time, RMS.SZ_mean, 'k');
hold on;
plot(time, RMS.con_mean, 'k--');
jbfill(time,RMS.SZ_mean+RMS.SZ_se,RMS.SZ_mean-RMS.SZ_se,[0,0,0],[0,0,0],0,0.3)
jbfill(time,RMS.con_mean+RMS.con_se,RMS.con_mean-RMS.con_se,[0,0,0],[0,0,0],0,0.1)
xlim([-0.1 0.6]);
plot([0 0],[-1*10^(-14) 7*10^(-14)],'k--');
legend('SZ (n = 10)','Control (n = 14)');