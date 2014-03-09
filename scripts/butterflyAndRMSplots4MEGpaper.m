clear all
for i=[2:7 9 12 13 15]
    eval(['cd /home/meg/Data/Maor/PhD_SAM/SZ/sub',num2str(i)]);
    eval(['load sub',num2str(i),'avconds']);
    eval(['sub',num2str(i),'avg=sub',num2str(i),'avcond10;']);
    eval(['sub',num2str(i),'avg.avg=(sub',num2str(i),'avcond10.avg+sub',num2str(i),'avcond20.avg+sub',num2str(i),'avcond30.avg+sub',num2str(i),'avcond40.avg)./4;']);
end

SZgravg = ft_timelockgrandaverage([],sub2avg, sub3avg, sub4avg, sub5avg, sub6avg,...
    sub7avg, sub9avg, sub12avg, sub13avg, sub15avg);

for i=[13:21 23 25 27:29]
    eval(['cd /home/meg/Data/Maor/PhD_SAM/control/sub',num2str(i)]);
    eval(['load sub',num2str(i),'avconds']);
    eval(['sub',num2str(i),'avg=sub',num2str(i),'avcond10;']);
    eval(['sub',num2str(i),'avg.avg=(sub',num2str(i),'avcond10.avg+sub',num2str(i),'avcond20.avg+sub',num2str(i),'avcond30.avg+sub',num2str(i),'avcond40.avg)./4;']);
end

conGravg = ft_timelockgrandaverage([],sub13avg, sub14avg, sub15avg, sub16avg, sub17avg,...
    sub18avg, sub19avg, sub20avg, sub21avg, sub23avg, sub25avg, sub27avg, sub28avg, sub29avg);

% plots colored
figure
subplot(2,1,1)
rectangle('Position',[0.065 -1.5*10^(-13) 0.065 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.95]);
hold on
rectangle('Position',[0.135 -1.5*10^(-13) 0.08 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.85]);
rectangle('Position',[0.225 -1.5*10^(-13) 0.095 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.75]);
rectangle('Position',[0.32 -1.5*10^(-13) 0.115 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.65]);
rectangle('Position',[0.435 -1.5*10^(-13) 0.1 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.55]);
plot(SZgravg.time, SZgravg.avg, 'b');
ylim([-1.5*10^(-13) 1.5*10^(-13)]);
xlim([-0.1 0.6])
plot([-0.1 0.6], [0 0], 'k');
plot([0 0], [-1.5*10^(-13) 1.5*10^(-13)], 'k--');
subplot(2,1,2)
rectangle('Position',[0.045 -1.5*10^(-13) 0.065 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.95]);
hold on
rectangle('Position',[0.11 -1.5*10^(-13) 0.08 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.85]);
rectangle('Position',[0.195 -1.5*10^(-13) 0.095 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.75]);
rectangle('Position',[0.3 -1.5*10^(-13) 0.115 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.65]);
rectangle('Position',[0.44 -1.5*10^(-13) 0.1 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1,'Facecolor',[1 1 0.55]);
plot(SZgravg.time, conGravg.avg, 'r');
ylim([-1.5*10^(-13) 1.5*10^(-13)]);
xlim([-0.1 0.6])
plot([-0.1 0.6], [0 0], 'k');
plot([0 0], [-1.5*10^(-13) 1.5*10^(-13)], 'k--');

% plots B&W
figure
subplot(2,1,1)
rectangle('Position',[0.065 -1.5*10^(-13) 0.065 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
hold on
rectangle('Position',[0.135 -1.5*10^(-13) 0.08 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.225 -1.5*10^(-13) 0.095 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.32 -1.5*10^(-13) 0.115 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.435 -1.5*10^(-13) 0.1 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
plot(SZgravg.time, SZgravg.avg, 'k');
ylim([-1.5*10^(-13) 1.5*10^(-13)]);
xlim([-0.1 0.6])
plot([-0.1 0.6], [0 0], 'k');
plot([0 0], [-1.5*10^(-13) 1.5*10^(-13)], 'k--');
subplot(2,1,2)
rectangle('Position',[0.045 -1.5*10^(-13) 0.065 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
hold on
rectangle('Position',[0.11 -1.5*10^(-13) 0.08 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.195 -1.5*10^(-13) 0.095 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.3 -1.5*10^(-13) 0.115 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.44 -1.5*10^(-13) 0.1 3*10^(-13)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
plot(SZgravg.time, conGravg.avg, 'k');
ylim([-1.5*10^(-13) 1.5*10^(-13)]);
xlim([-0.1 0.6])
plot([-0.1 0.6], [0 0], 'k');
plot([0 0], [-1.5*10^(-13) 1.5*10^(-13)], 'k--');

x1=SZgravg.avg;
x2=conGravg.avg;
t=SZgravg.time;
x1=mean(sqrt(x1.^2))-mean(sqrt(x1(1:203).^2));
x2=mean(sqrt(x2.^2))-mean(sqrt(x2(1:203).^2));
plot(t,x1,'k')
hold on
plot(t,x2,'k--')
legend({'SZ (n = 10)','Control (n = 14)'});
xlim([-0.1 0.6]);

%% RMS for the gravg
SZRMSBL=mean(sqrt(mean(SZgravg.avg(:,1:203).^2)));
conRMSBL=mean(sqrt(mean(conGravg.avg(:,1:203).^2)));
SZRMS=sqrt(mean(SZgravg.avg.^2))-SZRMSBL;
conRMS=sqrt(mean(conGravg.avg.^2))-conRMSBL;
time=SZgravg.time;

figure
set(gca,'FontSize',14);
h=plot(time,SZRMS,'k')
set(h,'linewidth',2);
hold on
h=plot(time,conRMS,'k--')
set(h,'linewidth',2);
xlim([-0.1 0.6]);
xlabel('Time (s)');
ylabel('RMS Amplitude (T)');
legend({'SZ (n = 10)','Control (n = 14)'});
plot([0 0],[-1*10^(-14) 6*10^(-14)],'K--');

%
figure
subplot(2,1,1)
rectangle('Position',[0.065 -1*10^(-14) 0.065 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
hold on
rectangle('Position',[0.135 -1*10^(-14) 0.08 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.225 -1*10^(-14) 0.095 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.32 -1*10^(-14) 0.115 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.435 -1*10^(-14) 0.1 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
plot(time, SZRMS, 'k');
ylim([-1*10^(-14) 6*10^(-14)]);
xlim([-0.1 0.6])
plot([0 0], [-1.5*10^(-13) 1.5*10^(-13)], 'k--');
subplot(2,1,2)
rectangle('Position',[0.045 -1*10^(-14) 0.065 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
hold on
rectangle('Position',[0.11 -1*10^(-14) 0.08 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.195 -1*10^(-14) 0.095 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.3 -1*10^(-14) 0.115 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
rectangle('Position',[0.44 -1*10^(-14) 0.1 7*10^(-14)],...
          'Curvature',[0.2,0.2],'LineWidth',1);
plot(time, conRMS, 'k');
ylim([-1*10^(-14) 6*10^(-14)]);
xlim([-0.1 0.6])
plot([0 0], [-1.5*10^(-13) 1.5*10^(-13)], 'k--');