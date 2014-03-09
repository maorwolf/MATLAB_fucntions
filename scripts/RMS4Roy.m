%% RMS Analysis
subs = [1 4:11 13:16];
for i = subs
    eval(['cd /home/meg/Data/Maor/Hypnosis/Subjects/HypCon',num2str(i),'/1_40Hz']);
    load averagedata
end

load LRpairs
a = 1;
for i = subs
    eval(['chansL = ismember(sub',num2str(i),'con102.label, LRpairs(:,1));']); % create for each sub a list of all left hemisphere channels
    eval(['chansR = ismember(sub',num2str(i),'con102.label, LRpairs(:,2));']); % create for each sub a list of all right hemisphere channels
    for j = [102:2:108] % for each sub for each condition for each hemisphere creates the RMS
        eval(['sub',num2str(i),'RMScon',num2str(j),'=sqrt(mean(sub',num2str(i),'con',num2str(j),'.avg.^2));']);
        eval(['sub',num2str(i),'RMScon',num2str(j),'=sub',num2str(i),'RMScon',num2str(j),'-mean(sub',num2str(i),'RMScon',num2str(j),'(1,1:153));']);
        eval(['sub',num2str(i),'conRMS',num2str(j),'L=sqrt(mean(sub',num2str(i),'con',num2str(j),'.avg(chansL,:).^2));']);
        eval(['sub',num2str(i),'conRMS',num2str(j),'L=sub',num2str(i),'conRMS',num2str(j),'L-mean(sub',num2str(i),'conRMS',num2str(j),'L(1,1:153));']);
        eval(['sub',num2str(i),'conRMS',num2str(j),'R=sqrt(mean(sub',num2str(i),'con',num2str(j),'.avg(chansR,:).^2));']);
        eval(['sub',num2str(i),'conRMS',num2str(j),'R=sub',num2str(i),'conRMS',num2str(j),'R-mean(sub',num2str(i),'conRMS',num2str(j),'R(1,1:153));']);
        eval(['con',num2str(j),'RMSL(a,:)=sub',num2str(i),'conRMS',num2str(j),'L;']);
        eval(['con',num2str(j),'RMSR(a,:)=sub',num2str(i),'conRMS',num2str(j),'R;']);  
    end;
    a=a+1;
end;
clear a i j

for j = [102:2:108]
    %eval(['con',num2str(j),'RMSL=con',num2str(j),'RMSL.*(10^14);']);
    %eval(['con',num2str(j),'RMSR=con',num2str(j),'RMSR.*(10^14);']);
    eval(['meanCon',num2str(j),'RMSL=mean(con',num2str(j),'RMSL);']);
    eval(['meanCon',num2str(j),'RMSR=mean(con',num2str(j),'RMSR);']);
end;
clear j

% calculating standart error
for k = [102:2:108]
    eval(['seCon',num2str(k),'RMSL=std(con',num2str(k),'RMSL)/sqrt(17);']);
    eval(['seCon',num2str(k),'RMSR=std(con',num2str(k),'RMSR)/sqrt(17);']);
end;

cd /home/meg/Data/Maor/Hypnosis
save HypConRMS con102RMSL con102RMSR con104RMSL con104RMSR con106RMSL con106RMSR con108RMSL con108RMSR...
    meanCon102RMSL meanCon102RMSR meanCon104RMSL meanCon104RMSR meanCon106RMSL meanCon106RMSR meanCon108RMSL meanCon108RMSR...
    seCon102RMSL seCon102RMSR seCon104RMSL seCon104RMSR seCon106RMSL seCon106RMSR seCon108RMSL seCon108RMSR
clear all

load HypConRMS
load time
% plot RMS
figure
subplot(2,1,1)
plot(time,meanCon102RMSL,'b') % LH pre right
hold on;
jbfill(time,meanCon102RMSL+seCon102RMSL,meanCon102RMSL-seCon102RMSL,[0,0,1],[0,0,1],0,0.3)
plot(time,meanCon106RMSL,'r') % LH post right
title('blue: pre right RMSL           red: post right RMSL')
jbfill(time,meanCon106RMSL+seCon106RMSL,meanCon106RMSL-seCon106RMSL,[1,0,0],[1,0,0],0,0.3)
grid;
subplot(2,1,2)
plot(time,meanCon104RMSR,'b') % RH pre left
hold on;
jbfill(time,meanCon104RMSR+seCon104RMSR,meanCon104RMSR-seCon104RMSR,[0,0,1],[0,0,1],0,0.3)
plot(time,meanCon108RMSR,'r') % RH post left
title('blue: pre left RMSR           red: post left RMSR')
jbfill(time,meanCon108RMSR+seCon108RMSR,meanCon108RMSR-seCon108RMSR,[1,0,0],[1,0,0],0,0.3)
grid;

figure;
plot(time, meanCon102RMSL - meanCon106RMSL, 'b')
hold on;
plot(time, meanCon104RMSR - meanCon108RMSR, 'r')
grid;

% RMS differences table for the 3 comps: 157-203ms, 232-292ms, 311-500ms
for i = 1:13
leftIndexRchans(i,:)=con104RMSR(i,:)-con108RMSR(i,:);
rightIndexLchans(i,:)=con102RMSL(i,:)-con106RMSL(i,:);
end;
load time

plot(time,mean(leftIndexRchans),'b')
hold on;
plot(time,mean(rightIndexLchans),'r')
grid;

for i = 1:13
    compsLeftIndex(i,1) = mean(leftIndexRchans(i,314:358));
    compsRightIndex(i,1) = mean(rightIndexLchans(i,314:358));
    compsLeftIndex(i,2) = mean(leftIndexRchans(i,390:451));
    compsRightIndex(i,2) = mean(rightIndexLchans(i,390:451));
    compsLeftIndex(i,3) = mean(leftIndexRchans(i,475:662));
    compsRightIndex(i,3) = mean(rightIndexLchans(i,475:662));
end;

compsLeftIndex = compsLeftIndex.*10^(14);
compsRightIndex = compsRightIndex.*10^(14);

% copy to excel and then to SPSS