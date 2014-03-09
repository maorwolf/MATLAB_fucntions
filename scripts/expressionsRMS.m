%%%%%%%%%% RMS Analysis %%%%%%%%%%

%% RMS for the average
RMScon = sqrt(mean((conAllCondsGrAvg.avg.^2)));
RMSsz = sqrt(mean((SZAllCondsGrAvg.avg.^2)));
RMScon=RMScon-mean(RMScon(1:305));
RMSsz=RMSsz-mean(RMSsz(1:305));

figure
h1=plot(conAllCondsGrAvg.time, RMScon, 'r');
set(h1,'linewidth',5)
hold on
h2=plot(SZAllCondsGrAvg.time, RMSsz, 'b');
set(h2,'linewidth',5)
plot([-0.5 -0.5], [0 5*10^(-14)], 'k'); 
plot([0 0], [0 5*10^(-14)], 'k'); 
title('Blue - SZ (n = 16); Red - Control (n = 16)')
text(-0.025, 0,'target');
text(-0.525, 0,'prime');
grid on;
axis tight;
%% RMS for control
clear all
cd /home/meg/Data/Maor/SchizoProject/expressions
load LRpairs

control = [0:3, 5:9, 12, 15, 20, 32, 36, 39, 41];

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'fullFirst.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'fullFirst.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSfullFirst=sqrt(mean(sub',num2str(i),'fullFirst.avg.^2));']);
    eval(['sub',num2str(i),'RMSfullFirst=sub',num2str(i),'RMSfullFirst-mean(sub',num2str(i),'RMSfullFirst(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSfullFirstL=sqrt(mean(sub',num2str(i),'fullFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSfullFirstL=sub',num2str(i),'RMSfullFirstL-mean(sub',num2str(i),'RMSfullFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSfullFirstR=sqrt(mean(sub',num2str(i),'fullFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSfullFirstR=sub',num2str(i),'RMSfullFirstR-mean(sub',num2str(i),'RMSfullFirstR(1,1:305));']);
    eval(['conRMSfullFirst(a,:)=sub',num2str(i),'RMSfullFirst;']);
    eval(['conRMSfullFirstL(a,:)=sub',num2str(i),'RMSfullFirstL;']);
    eval(['conRMSfullFirstR(a,:)=sub',num2str(i),'RMSfullFirstR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'fullSecond.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'fullSecond.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSfullSecond=sqrt(mean(sub',num2str(i),'fullSecond.avg.^2));']);
    eval(['sub',num2str(i),'RMSfullSecond=sub',num2str(i),'RMSfullSecond-mean(sub',num2str(i),'RMSfullSecond(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSfullSecondL=sqrt(mean(sub',num2str(i),'fullSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSfullSecondL=sub',num2str(i),'RMSfullSecondL-mean(sub',num2str(i),'RMSfullSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSfullSecondR=sqrt(mean(sub',num2str(i),'fullSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSfullSecondR=sub',num2str(i),'RMSfullSecondR-mean(sub',num2str(i),'RMSfullSecondR(1,1:305));']);
    eval(['conRMSfullSecond(a,:)=sub',num2str(i),'RMSfullSecond;']);
    eval(['conRMSfullSecondL(a,:)=sub',num2str(i),'RMSfullSecondL;']);
    eval(['conRMSfullSecondR(a,:)=sub',num2str(i),'RMSfullSecondR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'fullSingle.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'fullSingle.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSfullSingle=sqrt(mean(sub',num2str(i),'fullSingle.avg.^2));']);
    eval(['sub',num2str(i),'RMSfullSingle=sub',num2str(i),'RMSfullSingle-mean(sub',num2str(i),'RMSfullSingle(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSfullSingleL=sqrt(mean(sub',num2str(i),'fullSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSfullSingleL=sub',num2str(i),'RMSfullSingleL-mean(sub',num2str(i),'RMSfullSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSfullSingleR=sqrt(mean(sub',num2str(i),'fullSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSfullSingleR=sub',num2str(i),'RMSfullSingleR-mean(sub',num2str(i),'RMSfullSingleR(1,1:305));']);
    eval(['conRMSfullSingle(a,:)=sub',num2str(i),'RMSfullSingle;']);
    eval(['conRMSfullSingleL(a,:)=sub',num2str(i),'RMSfullSingleL;']);
    eval(['conRMSfullSingleR(a,:)=sub',num2str(i),'RMSfullSingleR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'lessFirst.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'lessFirst.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSlessFirst=sqrt(mean(sub',num2str(i),'lessFirst.avg.^2));']);
    eval(['sub',num2str(i),'RMSlessFirst=sub',num2str(i),'RMSlessFirst-mean(sub',num2str(i),'RMSlessFirst(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSlessFirstL=sqrt(mean(sub',num2str(i),'lessFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSlessFirstL=sub',num2str(i),'RMSlessFirstL-mean(sub',num2str(i),'RMSlessFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSlessFirstR=sqrt(mean(sub',num2str(i),'lessFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSlessFirstR=sub',num2str(i),'RMSlessFirstR-mean(sub',num2str(i),'RMSlessFirstR(1,1:305));']);
    eval(['conRMSlessFirst(a,:)=sub',num2str(i),'RMSlessFirst;']);
    eval(['conRMSlessFirstL(a,:)=sub',num2str(i),'RMSlessFirstL;']);
    eval(['conRMSlessFirstR(a,:)=sub',num2str(i),'RMSlessFirstR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'lessSecond.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'lessSecond.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSlessSecond=sqrt(mean(sub',num2str(i),'lessSecond.avg.^2));']);
    eval(['sub',num2str(i),'RMSlessSecond=sub',num2str(i),'RMSlessSecond-mean(sub',num2str(i),'RMSlessSecond(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSlessSecondL=sqrt(mean(sub',num2str(i),'lessSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSlessSecondL=sub',num2str(i),'RMSlessSecondL-mean(sub',num2str(i),'RMSlessSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSlessSecondR=sqrt(mean(sub',num2str(i),'lessSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSlessSecondR=sub',num2str(i),'RMSlessSecondR-mean(sub',num2str(i),'RMSlessSecondR(1,1:305));']);
    eval(['conRMSlessSecond(a,:)=sub',num2str(i),'RMSlessSecond;']);
    eval(['conRMSlessSecondL(a,:)=sub',num2str(i),'RMSlessSecondL;']);
    eval(['conRMSlessSecondR(a,:)=sub',num2str(i),'RMSlessSecondR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    eval(['chansL = ismember(sub',num2str(i),'lessSingle.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'lessSingle.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSlessSingle=sqrt(mean(sub',num2str(i),'lessSingle.avg.^2));']);
    eval(['sub',num2str(i),'RMSlessSingle=sub',num2str(i),'RMSlessSingle-mean(sub',num2str(i),'RMSlessSingle(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSlessSingleL=sqrt(mean(sub',num2str(i),'lessSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSlessSingleL=sub',num2str(i),'RMSlessSingleL-mean(sub',num2str(i),'RMSlessSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSlessSingleR=sqrt(mean(sub',num2str(i),'lessSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSlessSingleR=sub',num2str(i),'RMSlessSingleR-mean(sub',num2str(i),'RMSlessSingleR(1,1:305));']);
    eval(['conRMSlessSingle(a,:)=sub',num2str(i),'RMSlessSingle;']);
    eval(['conRMSlessSingleL(a,:)=sub',num2str(i),'RMSlessSingleL;']);
    eval(['conRMSlessSingleR(a,:)=sub',num2str(i),'RMSlessSingleR;']);  
    a=a+1;
end;
clear a i

save conRMS conRMSlessFirst conRMSlessFirstL conRMSlessFirstR conRMSlessSecond...
    conRMSlessSecondL conRMSlessSecondR conRMSlessSingle conRMSlessSingleL...
    conRMSlessSingleR conRMSfullFirst conRMSfullFirstL conRMSfullFirstR conRMSfullSecond...
    conRMSfullSecondL conRMSfullSecondR conRMSfullSingle conRMSfullSingleL conRMSfullSingleR

clear all

%% RMS for SZ
clear all
cd /home/meg/Data/Maor/SchizoProject/expressions
load LRpairs

SZ = [14, 16, 17, 19, 21, 23:25, 27:29, 31, 33:35, 37];

a = 1;
for i = SZ
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
    eval(['chansL = ismember(sub',num2str(i),'fullFirst.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'fullFirst.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSfullFirst=sqrt(mean(sub',num2str(i),'fullFirst.avg.^2));']);
    eval(['sub',num2str(i),'RMSfullFirst=sub',num2str(i),'RMSfullFirst-mean(sub',num2str(i),'RMSfullFirst(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSfullFirstL=sqrt(mean(sub',num2str(i),'fullFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSfullFirstL=sub',num2str(i),'RMSfullFirstL-mean(sub',num2str(i),'RMSfullFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSfullFirstR=sqrt(mean(sub',num2str(i),'fullFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSfullFirstR=sub',num2str(i),'RMSfullFirstR-mean(sub',num2str(i),'RMSfullFirstR(1,1:305));']);
    eval(['SZRMSfullFirst(a,:)=sub',num2str(i),'RMSfullFirst;']);
    eval(['SZRMSfullFirstL(a,:)=sub',num2str(i),'RMSfullFirstL;']);
    eval(['SZRMSfullFirstR(a,:)=sub',num2str(i),'RMSfullFirstR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
    eval(['chansL = ismember(sub',num2str(i),'fullSecond.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'fullSecond.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSfullSecond=sqrt(mean(sub',num2str(i),'fullSecond.avg.^2));']);
    eval(['sub',num2str(i),'RMSfullSecond=sub',num2str(i),'RMSfullSecond-mean(sub',num2str(i),'RMSfullSecond(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSfullSecondL=sqrt(mean(sub',num2str(i),'fullSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSfullSecondL=sub',num2str(i),'RMSfullSecondL-mean(sub',num2str(i),'RMSfullSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSfullSecondR=sqrt(mean(sub',num2str(i),'fullSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSfullSecondR=sub',num2str(i),'RMSfullSecondR-mean(sub',num2str(i),'RMSfullSecondR(1,1:305));']);
    eval(['SZRMSfullSecond(a,:)=sub',num2str(i),'RMSfullSecond;']);
    eval(['SZRMSfullSecondL(a,:)=sub',num2str(i),'RMSfullSecondL;']);
    eval(['SZRMSfullSecondR(a,:)=sub',num2str(i),'RMSfullSecondR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
    eval(['chansL = ismember(sub',num2str(i),'fullSingle.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'fullSingle.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSfullSingle=sqrt(mean(sub',num2str(i),'fullSingle.avg.^2));']);
    eval(['sub',num2str(i),'RMSfullSingle=sub',num2str(i),'RMSfullSingle-mean(sub',num2str(i),'RMSfullSingle(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSfullSingleL=sqrt(mean(sub',num2str(i),'fullSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSfullSingleL=sub',num2str(i),'RMSfullSingleL-mean(sub',num2str(i),'RMSfullSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSfullSingleR=sqrt(mean(sub',num2str(i),'fullSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSfullSingleR=sub',num2str(i),'RMSfullSingleR-mean(sub',num2str(i),'RMSfullSingleR(1,1:305));']);
    eval(['SZRMSfullSingle(a,:)=sub',num2str(i),'RMSfullSingle;']);
    eval(['SZRMSfullSingleL(a,:)=sub',num2str(i),'RMSfullSingleL;']);
    eval(['SZRMSfullSingleR(a,:)=sub',num2str(i),'RMSfullSingleR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
    eval(['chansL = ismember(sub',num2str(i),'lessFirst.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'lessFirst.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSlessFirst=sqrt(mean(sub',num2str(i),'lessFirst.avg.^2));']);
    eval(['sub',num2str(i),'RMSlessFirst=sub',num2str(i),'RMSlessFirst-mean(sub',num2str(i),'RMSlessFirst(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSlessFirstL=sqrt(mean(sub',num2str(i),'lessFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSlessFirstL=sub',num2str(i),'RMSlessFirstL-mean(sub',num2str(i),'RMSlessFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSlessFirstR=sqrt(mean(sub',num2str(i),'lessFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSlessFirstR=sub',num2str(i),'RMSlessFirstR-mean(sub',num2str(i),'RMSlessFirstR(1,1:305));']);
    eval(['SZRMSlessFirst(a,:)=sub',num2str(i),'RMSlessFirst;']);
    eval(['SZRMSlessFirstL(a,:)=sub',num2str(i),'RMSlessFirstL;']);
    eval(['SZRMSlessFirstR(a,:)=sub',num2str(i),'RMSlessFirstR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
    eval(['chansL = ismember(sub',num2str(i),'lessSecond.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'lessSecond.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSlessSecond=sqrt(mean(sub',num2str(i),'lessSecond.avg.^2));']);
    eval(['sub',num2str(i),'RMSlessSecond=sub',num2str(i),'RMSlessSecond-mean(sub',num2str(i),'RMSlessSecond(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSlessSecondL=sqrt(mean(sub',num2str(i),'lessSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSlessSecondL=sub',num2str(i),'RMSlessSecondL-mean(sub',num2str(i),'RMSlessSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSlessSecondR=sqrt(mean(sub',num2str(i),'lessSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSlessSecondR=sub',num2str(i),'RMSlessSecondR-mean(sub',num2str(i),'RMSlessSecondR(1,1:305));']);
    eval(['SZRMSlessSecond(a,:)=sub',num2str(i),'RMSlessSecond;']);
    eval(['SZRMSlessSecondL(a,:)=sub',num2str(i),'RMSlessSecondL;']);
    eval(['SZRMSlessSecondR(a,:)=sub',num2str(i),'RMSlessSecondR;']);  
    a=a+1;
end;
clear a i

a = 1;
for i = SZ
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
    eval(['chansL = ismember(sub',num2str(i),'lessSingle.label, LRpairs(:,1));']);
    eval(['chansR = ismember(sub',num2str(i),'lessSingle.label, LRpairs(:,2));']);
    eval(['sub',num2str(i),'RMSlessSingle=sqrt(mean(sub',num2str(i),'lessSingle.avg.^2));']);
    eval(['sub',num2str(i),'RMSlessSingle=sub',num2str(i),'RMSlessSingle-mean(sub',num2str(i),'RMSlessSingle(1,1:305));']); % 305 - base line correction time window
    eval(['sub',num2str(i),'RMSlessSingleL=sqrt(mean(sub',num2str(i),'lessSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSlessSingleL=sub',num2str(i),'RMSlessSingleL-mean(sub',num2str(i),'RMSlessSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSlessSingleR=sqrt(mean(sub',num2str(i),'lessSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSlessSingleR=sub',num2str(i),'RMSlessSingleR-mean(sub',num2str(i),'RMSlessSingleR(1,1:305));']);
    eval(['SZRMSlessSingle(a,:)=sub',num2str(i),'RMSlessSingle;']);
    eval(['SZRMSlessSingleL(a,:)=sub',num2str(i),'RMSlessSingleL;']);
    eval(['SZRMSlessSingleR(a,:)=sub',num2str(i),'RMSlessSingleR;']);  
    a=a+1;
end;
clear a i

save SZRMS SZRMSlessFirst SZRMSlessFirstL SZRMSlessFirstR SZRMSlessSecond...
    SZRMSlessSecondL SZRMSlessSecondR SZRMSlessSingle SZRMSlessSingleL...
    SZRMSlessSingleR SZRMSfullFirst SZRMSfullFirstL SZRMSfullFirstR SZRMSfullSecond...
    SZRMSfullSecondL SZRMSfullSecondR SZRMSfullSingle SZRMSfullSingleL SZRMSfullSingleR

clear all

load conRMS
load SZRMS
%% plot RMS
load time
load SZRMS
load conRMS
% all conditions
figure
subplot(3,2,1)
plot(time,mean(SZRMSfullSingle,1),'b')
hold on;
plot(time,mean(conRMSfullSingle,1),'r')
grid on;
axis tight;
title('Single presentation of meaningfull; blue - SZ, red - control')
d
subplot(3,2,2)
plot(time,mean(SZRMSlessSingle,1),'b')
hold on;
plot(time,mean(conRMSlessSingle,1),'r')
grid on;
axis tight;
title('Single presentation of meaningless; blue - SZ, red - control')

subplot(3,2,3)
plot(time,mean(SZRMSfullFirst,1),'b')
hold on;
plot(time,mean(conRMSfullFirst,1),'r')
grid on;
axis tight;
title('First presentation of meaningfull; blue - SZ, red - control')

subplot(3,2,4)
plot(time,mean(SZRMSlessFirst,1),'b')
hold on;
plot(time,mean(conRMSlessFirst,1),'r')
grid on;
axis tight;
title('First presentation of meaningless; blue - SZ, red - control')

subplot(3,2,5)
plot(time,mean(SZRMSfullSecond,1),'b')
hold on;
plot(time,mean(conRMSfullSecond,1),'r')
grid on;
axis tight;
title('Second presentation of meaningfull; blue - SZ, red - control')

subplot(3,2,6)
plot(time,mean(SZRMSlessSecond,1),'b')
hold on;
plot(time,mean(conRMSlessSecond,1),'r')
grid on;
axis tight;
title('Second presentation of meaningless; blue - SZ, red - control')

% Left vs. Right
% full single
figure
subplot(3,1,1)
plot(time,mean(SZRMSfullSingle,1),'b')
hold on;
plot(time,mean(conRMSfullSingle,1),'r')
grid on;
axis tight;
title('Single presentation of meaningfull; blue - SZ (n = 16), red - control (n = 16)')
subplot(3,1,2)
plot(time,mean(SZRMSfullSingleL,1),'b')
hold on;
plot(time,mean(conRMSfullSingleL,1),'r')
grid on;
axis tight;
title('Left channels of single presentation of meaningfull; blue - SZ (n = 16), red - control (n = 16)')
subplot(3,1,3)
plot(time,mean(SZRMSfullSingleR,1),'b')
hold on;
plot(time,mean(conRMSfullSingleR,1),'r')
grid on;
axis tight;
title('Right channels of single presentation of meaningfull; blue - SZ (n = 16), red - control (n = 16)')

% less single
figure
subplot(3,1,1)
plot(time,mean(SZRMSlessSingle,1),'b')
hold on;
plot(time,mean(conRMSlessSingle,1),'r')
grid on;
axis tight;
title('Single presentation of meaningless; blue - SZ (n = 16), red - control (n = 16)')
subplot(3,1,2)
plot(time,mean(SZRMSlessSingleL,1),'b')
hold on;
plot(time,mean(conRMSlessSingleL,1),'r')
grid on;
axis tight;
title('Left channels of single presentation of meaningless; blue - SZ (n = 16), red - control (n = 16)')
subplot(3,1,3)
plot(time,mean(SZRMSlessSingleR,1),'b')
hold on;
plot(time,mean(conRMSlessSingleR,1),'r')
grid on;
axis tight;
title('Right channels of single presentation of meaningless; blue - SZ (n = 16), red - control (n = 16)')


%% RMS for 6 comps
load SZRMS
load conRMS
fullSingle=[mean(SZRMSfullSingle(:,[550 611]),2);mean(conRMSfullSingle(:,[550 611]),2)]; % (-0.46)-(-0.4) s
fullSingle(:,2)=[mean(SZRMSfullSingle(:,[611 753]),2);mean(conRMSfullSingle(:,[611 753]),2)]; % (-0.4)-(0.26) s
fullSingle(:,3)=[mean(SZRMSfullSingle(:,[868 995]),2);mean(conRMSfullSingle(:,[868 995]),2)]; % (-0.1475)-(-0.0226) s
fullSingle(:,4)=[mean(SZRMSfullSingle(:,[1065 1137]),2);mean(conRMSfullSingle(:,[1065 1137]),2)]; % 0.046-0.117 s
fullSingle(:,5)=[mean(SZRMSfullSingle(:,[1140 1220]),2);mean(conRMSfullSingle(:,[1140 1220]),2)]; % 0.12-0.1980 s
fullSingle(:,6)=[mean(SZRMSfullSingle(:,[1377 1549]),2);mean(conRMSfullSingle(:,[1377 1549]),2)]; % 0.3529-0.522 s

fullFirst=[mean(SZRMSfullFirst(:,[550 611]),2);mean(conRMSfullFirst(:,[550 611]),2)];
fullFirst(:,2)=[mean(SZRMSfullFirst(:,[611 753]),2);mean(conRMSfullFirst(:,[611 753]),2)];
fullFirst(:,3)=[mean(SZRMSfullFirst(:,[868 995]),2);mean(conRMSfullFirst(:,[868 995]),2)];
fullFirst(:,4)=[mean(SZRMSfullFirst(:,[1065 1137]),2);mean(conRMSfullFirst(:,[1065 1137]),2)];
fullFirst(:,5)=[mean(SZRMSfullFirst(:,[1140 1220]),2);mean(conRMSfullFirst(:,[1140 1220]),2)];
fullFirst(:,6)=[mean(SZRMSfullFirst(:,[1377 1549]),2);mean(conRMSfullFirst(:,[1377 1549]),2)];

fullSecond=[mean(SZRMSfullSecond(:,[550 611]),2);mean(conRMSfullSecond(:,[550 611]),2)];
fullSecond(:,2)=[mean(SZRMSfullSecond(:,[611 753]),2);mean(conRMSfullSecond(:,[611 753]),2)];
fullSecond(:,3)=[mean(SZRMSfullSecond(:,[868 995]),2);mean(conRMSfullSecond(:,[868 995]),2)];
fullSecond(:,4)=[mean(SZRMSfullSecond(:,[1065 1137]),2);mean(conRMSfullSecond(:,[1065 1137]),2)];
fullSecond(:,5)=[mean(SZRMSfullSecond(:,[1140 1220]),2);mean(conRMSfullSecond(:,[1140 1220]),2)];
fullSecond(:,6)=[mean(SZRMSfullSecond(:,[1377 1549]),2);mean(conRMSfullSecond(:,[1377 1549]),2)];

lessSingle=[mean(SZRMSlessSingle(:,[550 611]),2);mean(conRMSlessSingle(:,[550 611]),2)];
lessSingle(:,2)=[mean(SZRMSlessSingle(:,[611 753]),2);mean(conRMSlessSingle(:,[611 753]),2)];
lessSingle(:,3)=[mean(SZRMSlessSingle(:,[868 995]),2);mean(conRMSlessSingle(:,[868 995]),2)];
lessSingle(:,4)=[mean(SZRMSlessSingle(:,[1065 1137]),2);mean(conRMSlessSingle(:,[1065 1137]),2)];
lessSingle(:,5)=[mean(SZRMSlessSingle(:,[1140 1220]),2);mean(conRMSlessSingle(:,[1140 1220]),2)];
lessSingle(:,6)=[mean(SZRMSlessSingle(:,[1377 1549]),2);mean(conRMSlessSingle(:,[1377 1549]),2)];

lessFirst=[mean(SZRMSlessFirst(:,[550 611]),2);mean(conRMSlessFirst(:,[550 611]),2)];
lessFirst(:,2)=[mean(SZRMSlessFirst(:,[611 753]),2);mean(conRMSlessFirst(:,[611 753]),2)];
lessFirst(:,3)=[mean(SZRMSlessFirst(:,[868 995]),2);mean(conRMSlessFirst(:,[868 995]),2)];
lessFirst(:,4)=[mean(SZRMSlessFirst(:,[1065 1137]),2);mean(conRMSlessFirst(:,[1065 1137]),2)];
lessFirst(:,5)=[mean(SZRMSlessFirst(:,[1140 1220]),2);mean(conRMSlessFirst(:,[1140 1220]),2)];
lessFirst(:,6)=[mean(SZRMSlessFirst(:,[1377 1549]),2);mean(conRMSlessFirst(:,[1377 1549]),2)];

lessSecond=[mean(SZRMSlessSecond(:,[550 611]),2);mean(conRMSlessSecond(:,[550 611]),2)];
lessSecond(:,2)=[mean(SZRMSlessSecond(:,[611 753]),2);mean(conRMSlessSecond(:,[611 753]),2)];
lessSecond(:,3)=[mean(SZRMSlessSecond(:,[868 995]),2);mean(conRMSlessSecond(:,[868 995]),2)];
lessSecond(:,4)=[mean(SZRMSlessSecond(:,[1065 1137]),2);mean(conRMSlessSecond(:,[1065 1137]),2)];
lessSecond(:,5)=[mean(SZRMSlessSecond(:,[1140 1220]),2);mean(conRMSlessSecond(:,[1140 1220]),2)];
lessSecond(:,6)=[mean(SZRMSlessSecond(:,[1377 1549]),2);mean(conRMSlessSecond(:,[1377 1549]),2)];

fullSingle = fullSingle.*10^15;
fullFirst = fullFirst.*10^15;
fullSecond = fullSecond.*10^15;
lessSingle = lessSingle.*10^15;
lessFirst = lessFirst.*10^15;
lessSecond = lessSecond.*10^15;

save RMS fullSingle fullFirst fullSecond lessSingle lessFirst lessSecond
clear all
load RMS
RMS4SPSS = [fullSingle, fullFirst, fullSecond, lessSingle, lessFirst, lessSecond];
save RMS4SPSS RMS4SPSS
%% means and SDs for 6 comps
clear all
load RMS
for i=1:6
    eval(['Comp',num2str(i),'MeansSZ=[mean(fullSingle(1:16,',num2str(i),')), mean(fullFirst(1:16,',num2str(i),')), mean(fullSecond(1:16,',num2str(i),')); mean(lessSingle(1:16,',num2str(i),')), mean(lessFirst(1:16,',num2str(i),')), mean(lessSecond(1:16,',num2str(i),'))];']);
    eval(['Comp',num2str(i),'SDsSZ=[std(fullSingle(1:16,',num2str(i),')), std(fullFirst(1:16,',num2str(i),')), std(fullSecond(1:16,',num2str(i),')); std(lessSingle(1:16,',num2str(i),')), std(lessFirst(1:16,',num2str(i),')), std(lessSecond(1:16,',num2str(i),'))];']);
    eval(['Comp',num2str(i),'MeansCon=[mean(fullSingle(17:32,',num2str(i),')), mean(fullFirst(17:32,',num2str(i),')), mean(fullSecond(17:32,',num2str(i),')); mean(lessSingle(17:32,',num2str(i),')), mean(lessFirst(17:32,',num2str(i),')), mean(lessSecond(17:32,',num2str(i),'))];']);
    eval(['Comp',num2str(i),'SDsCon=[std(fullSingle(17:32,',num2str(i),')), std(fullFirst(17:32,',num2str(i),')), std(fullSecond(17:32,',num2str(i),')); std(lessSingle(17:32,',num2str(i),')), std(lessFirst(17:32,',num2str(i),')), std(lessSecond(17:32,',num2str(i),'))];']);
end
%% RMS means plots for 6 comps
for i=1:6
    figure;
    subplot(2,1,1)
    eval(['h1 = barwitherr(Comp',num2str(i),'SDsSZ'', Comp',num2str(i),'MeansSZ'');']);
    eval(['title(''RMS Comp',num2str(i),' SZ'');']);
    ylabel('RMS*10^15');
    ylim([0 50]);
    set(h1(1), 'facecolor', [0 0 1]);
    set(h1(2), 'facecolor', [1 0 0]);
    set(gca, 'XTickLabel', {'Single','First','Second'});
    legend('meaningfull','meaningless');
    subplot(2,1,2)
    eval(['h2 = barwitherr(Comp',num2str(i),'SDsCon'', Comp',num2str(i),'MeansCon'');']);
    eval(['title(''RMS Comp',num2str(i),' Control'');']);
    ylabel('RMS*10^15');
    ylim([0 50]);
    set(h2(1), 'facecolor', [0 0 1]);
    set(h2(2), 'facecolor', [1 0 0]);
    set(gca, 'XTickLabel', {'Single','First','Second'});
    legend('meaningfull','meaningless');
end

%% looking for outlaiers
load RMS4SPSS
for i=1:32
    eval(['Z(',num2str(i),',1)=(mean(RMS4SPSS(',num2str(i),',:))-mean(mean(RMS4SPSS)))/std(mean(RMS4SPSS,2));']);
end

outlier.Indx=find(abs(Z)>2.5); % result: row 11 - AviMa29 - is an ourlier!!!!
outlier.Z=Z(outlier.Indx);


% h = waitbar(0,'Calculating')
% for ii = 1 : 1000
%     waitbar(ii/1000,h);
% end
% close(h)










% plot of significant results
% comp1
figure
subplot(2,1,1)
plot([1 2],[mean(fullFirst(1:15,1)),mean(fullSecond(1:15,1))],'w--o');
xlim([0.8 2.2])
ylim([15 30])
hold on;
plot([1 2],[mean(lessFirst(1:15,1)),mean(lessSecond(1:15,1))],'g--o');

subplot(2,1,2)
plot([1 2],[mean(fullFirst(16:30,1)),mean(fullSecond(16:30,1))],'w--o');
xlim([0.8 2.2])
ylim([15 30])
hold on;
plot([1 2],[mean(lessFirst(16:30,1)),mean(lessSecond(16:30,1))],'g--o');

%comp2
figure
subplot(2,1,1)
plot([1 2],[mean(fullFirst(1:15,2)),mean(fullSecond(1:15,2))],'w--o');
xlim([0.8 2.2])
ylim([30 45])
hold on;
plot([1 2],[mean(lessFirst(1:15,2)),mean(lessSecond(1:15,2))],'g--o');

subplot(2,1,2)
plot([1 2],[mean(fullFirst(16:30,2)),mean(fullSecond(16:30,2))],'w--o');
xlim([0.8 2.2])
ylim([30 45])
hold on;
plot([1 2],[mean(lessFirst(16:30,2)),mean(lessSecond(16:30,2))],'g--o');

%comp3
SZ = mean([mean(fullSingle(1:15,3)) mean(lessSingle(1:15,3))]);
con = mean([mean(fullSingle(16:30,3)) mean(lessSingle(16:30,3))]);
h = bar([SZ, con]);
xlim([0 3])

bar([mean(fullSingle(:,3)), mean(lessSingle(:,3))])
xlim([0 3])
ylim([0 30])

plot([1 2],[mean([mean(lessFirst(1:15,3)),mean(fullFirst(1:15,3))]),...
    mean([mean(lessSecond(1:15,3)),mean(fullSecond(1:15,3))])],'w--o');
xlim([0.8 2.2])
%ylim([30 45])
hold on;
plot([1 2],[mean([mean(lessFirst(16:30,3)),mean(fullFirst(16:30,3))]),...
    mean([mean(lessSecond(16:30,3)),mean(fullSecond(16:30,3))])],'g--o');

% comp4
plot([1 2],[mean([mean(lessFirst(1:15,4)),mean(fullFirst(1:15,4))]),...
    mean([mean(lessSecond(1:15,4)),mean(fullSecond(1:15,4))])],'w--o');
xlim([0.8 2.2])
%ylim([30 45])
hold on;
plot([1 2],[mean([mean(lessFirst(16:30,4)),mean(fullFirst(16:30,4))]),...
    mean([mean(lessSecond(16:30,4)),mean(fullSecond(16:30,4))])],'g--o');

% comp5
SZ = mean([mean(fullFirst(1:15,5)),mean(lessFirst(1:15,5)),...
    mean(fullSecond(1:15,5)),mean(lessSecond(1:15,5))]);
con = mean([mean(fullFirst(16:30,5)),mean(lessFirst(16:30,5)),...
    mean(fullSecond(16:30,5)),mean(lessSecond(16:30,5))]);
h = bar([SZ, con]);
xlim([0 3])

plot([1 2],[mean([mean(lessFirst(1:15,5)),mean(fullFirst(1:15,5))]),...
    mean([mean(lessSecond(1:15,5)),mean(fullSecond(1:15,5))])],'w--o');
xlim([0.8 2.2])
ylim([8 22])
hold on;
plot([1 2],[mean([mean(lessFirst(16:30,5)),mean(fullFirst(16:30,5))]),...
    mean([mean(lessSecond(16:30,5)),mean(fullSecond(16:30,5))])],'g--o');

