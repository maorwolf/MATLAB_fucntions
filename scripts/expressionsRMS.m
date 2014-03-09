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
bar([SZ, con]);
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

%% RMS Left Right Front Back for control!!!
% load data
clear all
control = [0:3, 5:9, 12, 15, 20, 32, 36, 39, 41];
for i=control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
end;
sz = [14, 16, 17, 19, 21, 23:25, 27:29, 31, 33:35, 37];
for i = sz
    if i == 19 || i == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/4/averagedataERF']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/averagedataERF']);
    end
end
% Left Front channels
LF = [6:9 20:24 38:43 62:68 90:97 122:129 153:157 177:179 196 197 212 213 229:232];
a=1;
for chan=LF
    eval(['LFchans{a} = ''A',num2str(chan),''';']);
    a=a+1;
end;
LFchans = LFchans';

% Right Front channels
RF = [15:18 32:36 55:60 82:88 113:120 145:152 172:176 193:195 210 211 227 228 245:248];
a=1;
for chan=RF
    eval(['RFchans{a} = ''A',num2str(chan),''';']);
    a=a+1;
end;
RFchans = RFchans';

% Left Back channels
LB = [11 26 27 45:48 70:74 99:104 131:136 159:164 180:185 199:203 214:219 234:238];
a=1;
for chan=LB
    eval(['LBchans{a} = ''A',num2str(chan),''';']);
    a=a+1;
end;
LBchans = LBchans';

% Right Back channels
RB = [13 29 30 50:53 76:80 106:111 138:143 165:170 187:192 204:208 221:226 239:243];
a=1;
for chan=RB
    eval(['RBchans{a} = ''A',num2str(chan),''';']);
    a=a+1;
end;
RBchans = RBchans';

%% LF RMS
for i=control
    eval(['sub',num2str(i),'allLFRMS=sub',num2str(i),'all.avg(find(ismember(sub',num2str(i),'all.label,LFchans)),:);']);
    eval(['sub',num2str(i),'allLFRMS=sqrt(mean(sub',num2str(i),'allLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'allLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSingleLFRMS=sub',num2str(i),'fullSingle.avg(find(ismember(sub',num2str(i),'fullSingle.label,LFchans)),:);']);
    eval(['sub',num2str(i),'fullSingleLFRMS=sqrt(mean(sub',num2str(i),'fullSingleLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSingleLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullFirstLFRMS=sub',num2str(i),'fullFirst.avg(find(ismember(sub',num2str(i),'fullFirst.label,LFchans)),:);']);
    eval(['sub',num2str(i),'fullFirstLFRMS=sqrt(mean(sub',num2str(i),'fullFirstLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullFirstLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSecondLFRMS=sub',num2str(i),'fullSecond.avg(find(ismember(sub',num2str(i),'fullSecond.label,LFchans)),:);']);
    eval(['sub',num2str(i),'fullSecondLFRMS=sqrt(mean(sub',num2str(i),'fullSecondLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSecondLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSingleLFRMS=sub',num2str(i),'lessSingle.avg(find(ismember(sub',num2str(i),'lessSingle.label,LFchans)),:);']);
    eval(['sub',num2str(i),'lessSingleLFRMS=sqrt(mean(sub',num2str(i),'lessSingleLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSingleLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessFirstLFRMS=sub',num2str(i),'lessFirst.avg(find(ismember(sub',num2str(i),'lessFirst.label,LFchans)),:);']);
    eval(['sub',num2str(i),'lessFirstLFRMS=sqrt(mean(sub',num2str(i),'lessFirstLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessFirstLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSecondLFRMS=sub',num2str(i),'lessSecond.avg(find(ismember(sub',num2str(i),'lessSecond.label,LFchans)),:);']);
    eval(['sub',num2str(i),'lessSecondLFRMS=sqrt(mean(sub',num2str(i),'lessSecondLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSecondLFRMS(:,1:305).^2)));']);
end
for i=sz
    eval(['sub',num2str(i),'allLFRMS=sub',num2str(i),'all.avg(find(ismember(sub',num2str(i),'all.label,LFchans)),:);']);
    eval(['sub',num2str(i),'allLFRMS=sqrt(mean(sub',num2str(i),'allLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'allLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSingleLFRMS=sub',num2str(i),'fullSingle.avg(find(ismember(sub',num2str(i),'fullSingle.label,LFchans)),:);']);
    eval(['sub',num2str(i),'fullSingleLFRMS=sqrt(mean(sub',num2str(i),'fullSingleLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSingleLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullFirstLFRMS=sub',num2str(i),'fullFirst.avg(find(ismember(sub',num2str(i),'fullFirst.label,LFchans)),:);']);
    eval(['sub',num2str(i),'fullFirstLFRMS=sqrt(mean(sub',num2str(i),'fullFirstLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullFirstLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSecondLFRMS=sub',num2str(i),'fullSecond.avg(find(ismember(sub',num2str(i),'fullSecond.label,LFchans)),:);']);
    eval(['sub',num2str(i),'fullSecondLFRMS=sqrt(mean(sub',num2str(i),'fullSecondLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSecondLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSingleLFRMS=sub',num2str(i),'lessSingle.avg(find(ismember(sub',num2str(i),'lessSingle.label,LFchans)),:);']);
    eval(['sub',num2str(i),'lessSingleLFRMS=sqrt(mean(sub',num2str(i),'lessSingleLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSingleLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessFirstLFRMS=sub',num2str(i),'lessFirst.avg(find(ismember(sub',num2str(i),'lessFirst.label,LFchans)),:);']);
    eval(['sub',num2str(i),'lessFirstLFRMS=sqrt(mean(sub',num2str(i),'lessFirstLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessFirstLFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSecondLFRMS=sub',num2str(i),'lessSecond.avg(find(ismember(sub',num2str(i),'lessSecond.label,LFchans)),:);']);
    eval(['sub',num2str(i),'lessSecondLFRMS=sqrt(mean(sub',num2str(i),'lessSecondLFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSecondLFRMS(:,1:305).^2)));']);
end
    
% tables of all subs for control and for sz
a=1;
for i=control
    eval(['conAllLFRMS.subs(a,:)=sub',num2str(i),'allLFRMS;']);
    eval(['conFullSingleLFRMS.subs(a,:)=sub',num2str(i),'fullSingleLFRMS;']);
    eval(['conFullFirstLFRMS.subs(a,:)=sub',num2str(i),'fullFirstLFRMS;']);
    eval(['conFullSecondLFRMS.subs(a,:)=sub',num2str(i),'fullSecondLFRMS;']);
    eval(['conLessSingleLFRMS.subs(a,:)=sub',num2str(i),'lessSingleLFRMS;']);
    eval(['conLessFirstLFRMS.subs(a,:)=sub',num2str(i),'lessFirstLFRMS;']);
    eval(['conLessSecondLFRMS.subs(a,:)=sub',num2str(i),'lessSecondLFRMS;']);
    a=a+1;
end;
a=1;
for i=sz
    eval(['szAllLFRMS.subs(a,:)=sub',num2str(i),'allLFRMS;']);
    eval(['szFullSingleLFRMS.subs(a,:)=sub',num2str(i),'fullSingleLFRMS;']);
    eval(['szFullFirstLFRMS.subs(a,:)=sub',num2str(i),'fullFirstLFRMS;']);
    eval(['szFullSecondLFRMS.subs(a,:)=sub',num2str(i),'fullSecondLFRMS;']);
    eval(['szLessSingleLFRMS.subs(a,:)=sub',num2str(i),'lessSingleLFRMS;']);
    eval(['szLessFirstLFRMS.subs(a,:)=sub',num2str(i),'lessFirstLFRMS;']);
    eval(['szLessSecondLFRMS.subs(a,:)=sub',num2str(i),'lessSecondLFRMS;']);
    a=a+1;
end;
% means and sds
conAllLFRMS.mean = mean(conAllLFRMS.subs);
conAllLFRMS.sd = std(conAllLFRMS.subs);
conFullSingleLFRMS.mean = mean(conFullSingleLFRMS.subs);
conFullSingleLFRMS.sd = std(conFullSingleLFRMS.subs);
conFullFirstLFRMS.mean = mean(conFullFirstLFRMS.subs);
conFullFirstLFRMS.sd = std(conFullFirstLFRMS.subs);
conFullSecondLFRMS.mean = mean(conFullSecondLFRMS.subs);
conFullSecondLFRMS.sd = std(conFullSecondLFRMS.subs);
conLessSingleLFRMS.mean = mean(conLessSingleLFRMS.subs);
conLessSingleLFRMS.sd = std(conLessSingleLFRMS.subs);
conLessFirstLFRMS.mean = mean(conLessFirstLFRMS.subs);
conLessFirstLFRMS.sd = std(conLessFirstLFRMS.subs);
conLessSecondLFRMS.mean = mean(conLessSecondLFRMS.subs);
conLessSecondLFRMS.sd = std(conLessSecondLFRMS.subs);
cd /home/meg/Data/Maor/SchizoProject/expressions
save conLFRMS conAllLFRMS conFullSingleLFRMS conFullFirstLFRMS conFullSecondLFRMS conLessSingleLFRMS conLessFirstLFRMS conLessSecondLFRMS

szAllLFRMS.mean = mean(szAllLFRMS.subs);
szAllLFRMS.sd = std(szAllLFRMS.subs);
szFullSingleLFRMS.mean = mean(szFullSingleLFRMS.subs);
szFullSingleLFRMS.sd = std(szFullSingleLFRMS.subs);
szFullFirstLFRMS.mean = mean(szFullFirstLFRMS.subs);
szFullFirstLFRMS.sd = std(szFullFirstLFRMS.subs);
szFullSecondLFRMS.mean = mean(szFullSecondLFRMS.subs);
szFullSecondLFRMS.sd = std(szFullSecondLFRMS.subs);
szLessSingleLFRMS.mean = mean(szLessSingleLFRMS.subs);
szLessSingleLFRMS.sd = std(szLessSingleLFRMS.subs);
szLessFirstLFRMS.mean = mean(szLessFirstLFRMS.subs);
szLessFirstLFRMS.sd = std(szLessFirstLFRMS.subs);
szLessSecondLFRMS.mean = mean(szLessSecondLFRMS.subs);
szLessSecondLFRMS.sd = std(szLessSecondLFRMS.subs);
cd /home/meg/Data/Maor/SchizoProject/expressions
save szLFRMS szAllLFRMS szFullSingleLFRMS szFullFirstLFRMS szFullSecondLFRMS szLessSingleLFRMS szLessFirstLFRMS szLessSecondLFRMS

clear all
load conLFRMS
load szLFRMS
load time

% plotting
figure
h1 = plot(time,szAllLFRMS.mean,'b');
hold on;
h2 = plot(time,conAllLFRMS.mean,'r');
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szAllLFRMS.mean+szAllLFRMS.sd,szAllLFRMS.mean-szAllLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conAllLFRMS.mean+conAllLFRMS.sd,conAllLFRMS.mean-conAllLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Left Front RMS: Blue - SZ, Red - Control');
%
figure
subplot(2,1,1)
h1 = plot(time,conFullSingleLFRMS.mean,'b');
hold on;
h2 = plot(time,conFullFirstLFRMS.mean,'r');
h3 = plot(time,conFullSecondLFRMS.mean,'g');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conFullSingleLFRMS.mean+conFullSingleLFRMS.sd,conFullSingleLFRMS.mean-conFullSingleLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullFirstLFRMS.mean+conFullFirstLFRMS.sd,conFullFirstLFRMS.mean-conFullFirstLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,conFullSecondLFRMS.mean+conFullSecondLFRMS.sd,conFullSecondLFRMS.mean-conFullSecondLFRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Control Left Front RMS: Blue - Meaningfull Single, Red - Meaningfull First, Green - Meaningfull Second');

subplot(2,1,2)
h1 = plot(time,szFullSingleLFRMS.mean,'b');
hold on;
h2 = plot(time,szFullFirstLFRMS.mean,'r');
h3 = plot(time,szFullSecondLFRMS.mean,'g');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSingleLFRMS.mean+szFullSingleLFRMS.sd,szFullSingleLFRMS.mean-szFullSingleLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,szFullFirstLFRMS.mean+szFullFirstLFRMS.sd,szFullFirstLFRMS.mean-szFullFirstLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,szFullSecondLFRMS.mean+szFullSecondLFRMS.sd,szFullSecondLFRMS.mean-szFullSecondLFRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('SZ Left Front RMS: Blue - Meaningfull Single, Red - Meaningfull First, Green - Meaningfull Second');
%
figure
subplot(2,1,1)
h1 = plot(time,conLessSingleLFRMS.mean,'b');
hold on;
h2 = plot(time,conLessFirstLFRMS.mean,'r');
h3 = plot(time,conLessSecondLFRMS.mean,'g');
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conLessSingleLFRMS.mean+conLessSingleLFRMS.sd,conLessSingleLFRMS.mean-conLessSingleLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessFirstLFRMS.mean+conLessFirstLFRMS.sd,conLessFirstLFRMS.mean-conLessFirstLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,conLessSecondLFRMS.mean+conLessSecondLFRMS.sd,conLessSecondLFRMS.mean-conLessSecondLFRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Control Left Front RMS: Blue - MeaningLess Single, Red - MeaningLess First, Green - MeaningLess Second');

subplot(2,1,2)
h1 = plot(time,szLessSingleLFRMS.mean,'b');
hold on;
h2 = plot(time,szLessFirstLFRMS.mean,'r');
h3 = plot(time,szLessSecondLFRMS.mean,'g');
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSingleLFRMS.mean+szLessSingleLFRMS.sd,szLessSingleLFRMS.mean-szLessSingleLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,szLessFirstLFRMS.mean+szLessFirstLFRMS.sd,szLessFirstLFRMS.mean-szLessFirstLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,szLessSecondLFRMS.mean+szLessSecondLFRMS.sd,szLessSecondLFRMS.mean-szLessSecondLFRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('SZ Left Front RMS: Blue - MeaningLess Single, Red - MeaningLess First, Green - MeaningLess Second');
%
figure
subplot(3,1,1)
h1 = plot(time,szFullSingleLFRMS.mean,'b');
hold on;
h2 = plot(time,conFullSingleLFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSingleLFRMS.mean+szFullSingleLFRMS.sd,szFullSingleLFRMS.mean-szFullSingleLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullSingleLFRMS.mean+conFullSingleLFRMS.sd,conFullSingleLFRMS.mean-conFullSingleLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Left Front RMS: Blue - SZ Meaningfull Single, Red - Control Meaningfull Single');

subplot(3,1,2)
h1 = plot(time,szFullFirstLFRMS.mean,'b');
hold on;
h2 = plot(time,conFullFirstLFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullFirstLFRMS.mean+szFullFirstLFRMS.sd,szFullFirstLFRMS.mean-szFullFirstLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullFirstLFRMS.mean+conFullFirstLFRMS.sd,conFullFirstLFRMS.mean-conFullFirstLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Left Front RMS: Blue - SZ Meaningfull First, Red - Control Meaningfull First');

subplot(3,1,3)
h1 = plot(time,szFullSecondLFRMS.mean,'b');
hold on;
h2 = plot(time,conFullSecondLFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSecondLFRMS.mean+szFullSecondLFRMS.sd,szFullSecondLFRMS.mean-szFullSecondLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullSecondLFRMS.mean+conFullSecondLFRMS.sd,conFullSecondLFRMS.mean-conFullSecondLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Left Front RMS: Blue - SZ Meaningfull Second, Red - Control Meaningfull Second');

%
figure
subplot(3,1,1)
h1 = plot(time,szLessSingleLFRMS.mean,'b');
hold on;
h2 = plot(time,conLessSingleLFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSingleLFRMS.mean+szLessSingleLFRMS.sd,szLessSingleLFRMS.mean-szLessSingleLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessSingleLFRMS.mean+conLessSingleLFRMS.sd,conLessSingleLFRMS.mean-conLessSingleLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Left Front RMS: Blue - SZ Meaningless Single, Red - Control Meaningless Single');

subplot(3,1,2)
h1 = plot(time,szLessFirstLFRMS.mean,'b');
hold on;
h2 = plot(time,conLessFirstLFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessFirstLFRMS.mean+szLessFirstLFRMS.sd,szLessFirstLFRMS.mean-szLessFirstLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessFirstLFRMS.mean+conLessFirstLFRMS.sd,conLessFirstLFRMS.mean-conLessFirstLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Left Front RMS: Blue - SZ Meaningless First, Red - Control Meaningless First');

subplot(3,1,3)
h1 = plot(time,szLessSecondLFRMS.mean,'b');
hold on;
h2 = plot(time,conLessSecondLFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSecondLFRMS.mean+szLessSecondLFRMS.sd,szLessSecondLFRMS.mean-szLessSecondLFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessSecondLFRMS.mean+conLessSecondLFRMS.sd,conLessSecondLFRMS.mean-conLessSecondLFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Front RMS');
title('Left Front RMS: Blue - SZ Meaningless Second, Red - Control Meaningless Second');

%% RF RMS
for i=control
    eval(['sub',num2str(i),'allRFRMS=sub',num2str(i),'all.avg(find(ismember(sub',num2str(i),'all.label,RFchans)),:);']);
    eval(['sub',num2str(i),'allRFRMS=sqrt(mean(sub',num2str(i),'allRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'allRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSingleRFRMS=sub',num2str(i),'fullSingle.avg(find(ismember(sub',num2str(i),'fullSingle.label,RFchans)),:);']);
    eval(['sub',num2str(i),'fullSingleRFRMS=sqrt(mean(sub',num2str(i),'fullSingleRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSingleRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullFirstRFRMS=sub',num2str(i),'fullFirst.avg(find(ismember(sub',num2str(i),'fullFirst.label,RFchans)),:);']);
    eval(['sub',num2str(i),'fullFirstRFRMS=sqrt(mean(sub',num2str(i),'fullFirstRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullFirstRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSecondRFRMS=sub',num2str(i),'fullSecond.avg(find(ismember(sub',num2str(i),'fullSecond.label,RFchans)),:);']);
    eval(['sub',num2str(i),'fullSecondRFRMS=sqrt(mean(sub',num2str(i),'fullSecondRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSecondRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSingleRFRMS=sub',num2str(i),'lessSingle.avg(find(ismember(sub',num2str(i),'lessSingle.label,RFchans)),:);']);
    eval(['sub',num2str(i),'lessSingleRFRMS=sqrt(mean(sub',num2str(i),'lessSingleRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSingleRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessFirstRFRMS=sub',num2str(i),'lessFirst.avg(find(ismember(sub',num2str(i),'lessFirst.label,RFchans)),:);']);
    eval(['sub',num2str(i),'lessFirstRFRMS=sqrt(mean(sub',num2str(i),'lessFirstRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessFirstRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSecondRFRMS=sub',num2str(i),'lessSecond.avg(find(ismember(sub',num2str(i),'lessSecond.label,RFchans)),:);']);
    eval(['sub',num2str(i),'lessSecondRFRMS=sqrt(mean(sub',num2str(i),'lessSecondRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSecondRFRMS(:,1:305).^2)));']);
end
for i=sz
    eval(['sub',num2str(i),'allRFRMS=sub',num2str(i),'all.avg(find(ismember(sub',num2str(i),'all.label,RFchans)),:);']);
    eval(['sub',num2str(i),'allRFRMS=sqrt(mean(sub',num2str(i),'allRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'allRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSingleRFRMS=sub',num2str(i),'fullSingle.avg(find(ismember(sub',num2str(i),'fullSingle.label,RFchans)),:);']);
    eval(['sub',num2str(i),'fullSingleRFRMS=sqrt(mean(sub',num2str(i),'fullSingleRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSingleRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullFirstRFRMS=sub',num2str(i),'fullFirst.avg(find(ismember(sub',num2str(i),'fullFirst.label,RFchans)),:);']);
    eval(['sub',num2str(i),'fullFirstRFRMS=sqrt(mean(sub',num2str(i),'fullFirstRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullFirstRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSecondRFRMS=sub',num2str(i),'fullSecond.avg(find(ismember(sub',num2str(i),'fullSecond.label,RFchans)),:);']);
    eval(['sub',num2str(i),'fullSecondRFRMS=sqrt(mean(sub',num2str(i),'fullSecondRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSecondRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSingleRFRMS=sub',num2str(i),'lessSingle.avg(find(ismember(sub',num2str(i),'lessSingle.label,RFchans)),:);']);
    eval(['sub',num2str(i),'lessSingleRFRMS=sqrt(mean(sub',num2str(i),'lessSingleRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSingleRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessFirstRFRMS=sub',num2str(i),'lessFirst.avg(find(ismember(sub',num2str(i),'lessFirst.label,RFchans)),:);']);
    eval(['sub',num2str(i),'lessFirstRFRMS=sqrt(mean(sub',num2str(i),'lessFirstRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessFirstRFRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSecondRFRMS=sub',num2str(i),'lessSecond.avg(find(ismember(sub',num2str(i),'lessSecond.label,RFchans)),:);']);
    eval(['sub',num2str(i),'lessSecondRFRMS=sqrt(mean(sub',num2str(i),'lessSecondRFRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSecondRFRMS(:,1:305).^2)));']);
end
    
% tables of all subs for control and for sz
a=1;
for i=control
    eval(['conAllRFRMS.subs(a,:)=sub',num2str(i),'allRFRMS;']);
    eval(['conFullSingleRFRMS.subs(a,:)=sub',num2str(i),'fullSingleRFRMS;']);
    eval(['conFullFirstRFRMS.subs(a,:)=sub',num2str(i),'fullFirstRFRMS;']);
    eval(['conFullSecondRFRMS.subs(a,:)=sub',num2str(i),'fullSecondRFRMS;']);
    eval(['conLessSingleRFRMS.subs(a,:)=sub',num2str(i),'lessSingleRFRMS;']);
    eval(['conLessFirstRFRMS.subs(a,:)=sub',num2str(i),'lessFirstRFRMS;']);
    eval(['conLessSecondRFRMS.subs(a,:)=sub',num2str(i),'lessSecondRFRMS;']);
    a=a+1;
end;
a=1;
for i=sz
    eval(['szAllRFRMS.subs(a,:)=sub',num2str(i),'allRFRMS;']);
    eval(['szFullSingleRFRMS.subs(a,:)=sub',num2str(i),'fullSingleRFRMS;']);
    eval(['szFullFirstRFRMS.subs(a,:)=sub',num2str(i),'fullFirstRFRMS;']);
    eval(['szFullSecondRFRMS.subs(a,:)=sub',num2str(i),'fullSecondRFRMS;']);
    eval(['szLessSingleRFRMS.subs(a,:)=sub',num2str(i),'lessSingleRFRMS;']);
    eval(['szLessFirstRFRMS.subs(a,:)=sub',num2str(i),'lessFirstRFRMS;']);
    eval(['szLessSecondRFRMS.subs(a,:)=sub',num2str(i),'lessSecondRFRMS;']);
    a=a+1;
end;
% means and sds
conAllRFRMS.mean = mean(conAllRFRMS.subs);
conAllRFRMS.sd = std(conAllRFRMS.subs);
conFullSingleRFRMS.mean = mean(conFullSingleRFRMS.subs);
conFullSingleRFRMS.sd = std(conFullSingleRFRMS.subs);
conFullFirstRFRMS.mean = mean(conFullFirstRFRMS.subs);
conFullFirstRFRMS.sd = std(conFullFirstRFRMS.subs);
conFullSecondRFRMS.mean = mean(conFullSecondRFRMS.subs);
conFullSecondRFRMS.sd = std(conFullSecondRFRMS.subs);
conLessSingleRFRMS.mean = mean(conLessSingleRFRMS.subs);
conLessSingleRFRMS.sd = std(conLessSingleRFRMS.subs);
conLessFirstRFRMS.mean = mean(conLessFirstRFRMS.subs);
conLessFirstRFRMS.sd = std(conLessFirstRFRMS.subs);
conLessSecondRFRMS.mean = mean(conLessSecondRFRMS.subs);
conLessSecondRFRMS.sd = std(conLessSecondRFRMS.subs);
cd /home/meg/Data/Maor/SchizoProject/expressions
save conRFRMS conAllRFRMS conFullSingleRFRMS conFullFirstRFRMS conFullSecondRFRMS conLessSingleRFRMS conLessFirstRFRMS conLessSecondRFRMS

szAllRFRMS.mean = mean(szAllRFRMS.subs);
szAllRFRMS.sd = std(szAllRFRMS.subs);
szFullSingleRFRMS.mean = mean(szFullSingleRFRMS.subs);
szFullSingleRFRMS.sd = std(szFullSingleRFRMS.subs);
szFullFirstRFRMS.mean = mean(szFullFirstRFRMS.subs);
szFullFirstRFRMS.sd = std(szFullFirstRFRMS.subs);
szFullSecondRFRMS.mean = mean(szFullSecondRFRMS.subs);
szFullSecondRFRMS.sd = std(szFullSecondRFRMS.subs);
szLessSingleRFRMS.mean = mean(szLessSingleRFRMS.subs);
szLessSingleRFRMS.sd = std(szLessSingleRFRMS.subs);
szLessFirstRFRMS.mean = mean(szLessFirstRFRMS.subs);
szLessFirstRFRMS.sd = std(szLessFirstRFRMS.subs);
szLessSecondRFRMS.mean = mean(szLessSecondRFRMS.subs);
szLessSecondRFRMS.sd = std(szLessSecondRFRMS.subs);
cd /home/meg/Data/Maor/SchizoProject/expressions
save szRFRMS szAllRFRMS szFullSingleRFRMS szFullFirstRFRMS szFullSecondRFRMS szLessSingleRFRMS szLessFirstRFRMS szLessSecondRFRMS

clear all
load conRFRMS
load szRFRMS
load time

% plotting
figure
h1 = plot(time,szAllRFRMS.mean,'b');
hold on;
h2 = plot(time,conAllRFRMS.mean,'r');
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szAllRFRMS.mean+szAllRFRMS.sd,szAllRFRMS.mean-szAllRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conAllRFRMS.mean+conAllRFRMS.sd,conAllRFRMS.mean-conAllRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Right Front RMS: Blue - SZ, Red - Control');
%
figure
subplot(2,1,1)
h1 = plot(time,conFullSingleRFRMS.mean,'b');
hold on;
h2 = plot(time,conFullFirstRFRMS.mean,'r');
h3 = plot(time,conFullSecondRFRMS.mean,'g');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conFullSingleRFRMS.mean+conFullSingleRFRMS.sd,conFullSingleRFRMS.mean-conFullSingleRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullFirstRFRMS.mean+conFullFirstRFRMS.sd,conFullFirstRFRMS.mean-conFullFirstRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,conFullSecondRFRMS.mean+conFullSecondRFRMS.sd,conFullSecondRFRMS.mean-conFullSecondRFRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Control Right Front RMS: Blue - Meaningfull Single, Red - Meaningfull First, Green - Meaningfull Second');

subplot(2,1,2)
h1 = plot(time,szFullSingleRFRMS.mean,'b');
hold on;
h2 = plot(time,szFullFirstRFRMS.mean,'r');
h3 = plot(time,szFullSecondRFRMS.mean,'g');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSingleRFRMS.mean+szFullSingleRFRMS.sd,szFullSingleRFRMS.mean-szFullSingleRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,szFullFirstRFRMS.mean+szFullFirstRFRMS.sd,szFullFirstRFRMS.mean-szFullFirstRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,szFullSecondRFRMS.mean+szFullSecondRFRMS.sd,szFullSecondRFRMS.mean-szFullSecondRFRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('SZ Right Front RMS: Blue - Meaningfull Single, Red - Meaningfull First, Green - Meaningfull Second');
%
figure
subplot(2,1,1)
h1 = plot(time,conLessSingleRFRMS.mean,'b');
hold on;
h2 = plot(time,conLessFirstRFRMS.mean,'r');
h3 = plot(time,conLessSecondRFRMS.mean,'g');
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conLessSingleRFRMS.mean+conLessSingleRFRMS.sd,conLessSingleRFRMS.mean-conLessSingleRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessFirstRFRMS.mean+conLessFirstRFRMS.sd,conLessFirstRFRMS.mean-conLessFirstRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,conLessSecondRFRMS.mean+conLessSecondRFRMS.sd,conLessSecondRFRMS.mean-conLessSecondRFRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Control Right Front RMS: Blue - MeaningLess Single, Red - MeaningLess First, Green - MeaningLess Second');

subplot(2,1,2)
h1 = plot(time,szLessSingleRFRMS.mean,'b');
hold on;
h2 = plot(time,szLessFirstRFRMS.mean,'r');
h3 = plot(time,szLessSecondRFRMS.mean,'g');
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSingleRFRMS.mean+szLessSingleRFRMS.sd,szLessSingleRFRMS.mean-szLessSingleRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,szLessFirstRFRMS.mean+szLessFirstRFRMS.sd,szLessFirstRFRMS.mean-szLessFirstRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,szLessSecondRFRMS.mean+szLessSecondRFRMS.sd,szLessSecondRFRMS.mean-szLessSecondRFRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('SZ Right Front RMS: Blue - MeaningLess Single, Red - MeaningLess First, Green - MeaningLess Second');
%
figure
subplot(3,1,1)
h1 = plot(time,szFullSingleRFRMS.mean,'b');
hold on;
h2 = plot(time,conFullSingleRFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSingleRFRMS.mean+szFullSingleRFRMS.sd,szFullSingleRFRMS.mean-szFullSingleRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullSingleRFRMS.mean+conFullSingleRFRMS.sd,conFullSingleRFRMS.mean-conFullSingleRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Right Front RMS: Blue - SZ Meaningfull Single, Red - Control Meaningfull Single');

subplot(3,1,2)
h1 = plot(time,szFullFirstRFRMS.mean,'b');
hold on;
h2 = plot(time,conFullFirstRFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullFirstRFRMS.mean+szFullFirstRFRMS.sd,szFullFirstRFRMS.mean-szFullFirstRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullFirstRFRMS.mean+conFullFirstRFRMS.sd,conFullFirstRFRMS.mean-conFullFirstRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Right Front RMS: Blue - SZ Meaningfull First, Red - Control Meaningfull First');

subplot(3,1,3)
h1 = plot(time,szFullSecondRFRMS.mean,'b');
hold on;
h2 = plot(time,conFullSecondRFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSecondRFRMS.mean+szFullSecondRFRMS.sd,szFullSecondRFRMS.mean-szFullSecondRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullSecondRFRMS.mean+conFullSecondRFRMS.sd,conFullSecondRFRMS.mean-conFullSecondRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Right Front RMS: Blue - SZ Meaningfull Second, Red - Control Meaningfull Second');
%
figure
subplot(3,1,1)
h1 = plot(time,szLessSingleRFRMS.mean,'b');
hold on;
h2 = plot(time,conLessSingleRFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSingleRFRMS.mean+szLessSingleRFRMS.sd,szLessSingleRFRMS.mean-szLessSingleRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessSingleRFRMS.mean+conLessSingleRFRMS.sd,conLessSingleRFRMS.mean-conLessSingleRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Right Front RMS: Blue - SZ Meaningless Single, Red - Control Meaningless Single');

subplot(3,1,2)
h1 = plot(time,szLessFirstRFRMS.mean,'b');
hold on;
h2 = plot(time,conLessFirstRFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessFirstRFRMS.mean+szLessFirstRFRMS.sd,szLessFirstRFRMS.mean-szLessFirstRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessFirstRFRMS.mean+conLessFirstRFRMS.sd,conLessFirstRFRMS.mean-conLessFirstRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Right Front RMS: Blue - SZ Meaningless First, Red - Control Meaningless First');

subplot(3,1,3)
h1 = plot(time,szLessSecondRFRMS.mean,'b');
hold on;
h2 = plot(time,conLessSecondRFRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSecondRFRMS.mean+szLessSecondRFRMS.sd,szLessSecondRFRMS.mean-szLessSecondRFRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessSecondRFRMS.mean+conLessSecondRFRMS.sd,conLessSecondRFRMS.mean-conLessSecondRFRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Front RMS');
title('Right Front RMS: Blue - SZ Meaningless Second, Red - Control Meaningless Second');

%% LB RMS
for i=control
    eval(['sub',num2str(i),'allLBRMS=sub',num2str(i),'all.avg(find(ismember(sub',num2str(i),'all.label,LBchans)),:);']);
    eval(['sub',num2str(i),'allLBRMS=sqrt(mean(sub',num2str(i),'allLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'allLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSingleLBRMS=sub',num2str(i),'fullSingle.avg(find(ismember(sub',num2str(i),'fullSingle.label,LBchans)),:);']);
    eval(['sub',num2str(i),'fullSingleLBRMS=sqrt(mean(sub',num2str(i),'fullSingleLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSingleLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullFirstLBRMS=sub',num2str(i),'fullFirst.avg(find(ismember(sub',num2str(i),'fullFirst.label,LBchans)),:);']);
    eval(['sub',num2str(i),'fullFirstLBRMS=sqrt(mean(sub',num2str(i),'fullFirstLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullFirstLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSecondLBRMS=sub',num2str(i),'fullSecond.avg(find(ismember(sub',num2str(i),'fullSecond.label,LBchans)),:);']);
    eval(['sub',num2str(i),'fullSecondLBRMS=sqrt(mean(sub',num2str(i),'fullSecondLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSecondLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSingleLBRMS=sub',num2str(i),'lessSingle.avg(find(ismember(sub',num2str(i),'lessSingle.label,LBchans)),:);']);
    eval(['sub',num2str(i),'lessSingleLBRMS=sqrt(mean(sub',num2str(i),'lessSingleLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSingleLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessFirstLBRMS=sub',num2str(i),'lessFirst.avg(find(ismember(sub',num2str(i),'lessFirst.label,LBchans)),:);']);
    eval(['sub',num2str(i),'lessFirstLBRMS=sqrt(mean(sub',num2str(i),'lessFirstLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessFirstLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSecondLBRMS=sub',num2str(i),'lessSecond.avg(find(ismember(sub',num2str(i),'lessSecond.label,LBchans)),:);']);
    eval(['sub',num2str(i),'lessSecondLBRMS=sqrt(mean(sub',num2str(i),'lessSecondLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSecondLBRMS(:,1:305).^2)));']);
end
for i=sz
    eval(['sub',num2str(i),'allLBRMS=sub',num2str(i),'all.avg(find(ismember(sub',num2str(i),'all.label,LBchans)),:);']);
    eval(['sub',num2str(i),'allLBRMS=sqrt(mean(sub',num2str(i),'allLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'allLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSingleLBRMS=sub',num2str(i),'fullSingle.avg(find(ismember(sub',num2str(i),'fullSingle.label,LBchans)),:);']);
    eval(['sub',num2str(i),'fullSingleLBRMS=sqrt(mean(sub',num2str(i),'fullSingleLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSingleLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullFirstLBRMS=sub',num2str(i),'fullFirst.avg(find(ismember(sub',num2str(i),'fullFirst.label,LBchans)),:);']);
    eval(['sub',num2str(i),'fullFirstLBRMS=sqrt(mean(sub',num2str(i),'fullFirstLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullFirstLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSecondLBRMS=sub',num2str(i),'fullSecond.avg(find(ismember(sub',num2str(i),'fullSecond.label,LBchans)),:);']);
    eval(['sub',num2str(i),'fullSecondLBRMS=sqrt(mean(sub',num2str(i),'fullSecondLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSecondLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSingleLBRMS=sub',num2str(i),'lessSingle.avg(find(ismember(sub',num2str(i),'lessSingle.label,LBchans)),:);']);
    eval(['sub',num2str(i),'lessSingleLBRMS=sqrt(mean(sub',num2str(i),'lessSingleLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSingleLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessFirstLBRMS=sub',num2str(i),'lessFirst.avg(find(ismember(sub',num2str(i),'lessFirst.label,LBchans)),:);']);
    eval(['sub',num2str(i),'lessFirstLBRMS=sqrt(mean(sub',num2str(i),'lessFirstLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessFirstLBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSecondLBRMS=sub',num2str(i),'lessSecond.avg(find(ismember(sub',num2str(i),'lessSecond.label,LBchans)),:);']);
    eval(['sub',num2str(i),'lessSecondLBRMS=sqrt(mean(sub',num2str(i),'lessSecondLBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSecondLBRMS(:,1:305).^2)));']);
end
    
% tables of all subs for control and for sz
a=1;
for i=control
    eval(['conAllLBRMS.subs(a,:)=sub',num2str(i),'allLBRMS;']);
    eval(['conFullSingleLBRMS.subs(a,:)=sub',num2str(i),'fullSingleLBRMS;']);
    eval(['conFullFirstLBRMS.subs(a,:)=sub',num2str(i),'fullFirstLBRMS;']);
    eval(['conFullSecondLBRMS.subs(a,:)=sub',num2str(i),'fullSecondLBRMS;']);
    eval(['conLessSingleLBRMS.subs(a,:)=sub',num2str(i),'lessSingleLBRMS;']);
    eval(['conLessFirstLBRMS.subs(a,:)=sub',num2str(i),'lessFirstLBRMS;']);
    eval(['conLessSecondLBRMS.subs(a,:)=sub',num2str(i),'lessSecondLBRMS;']);
    a=a+1;
end;
a=1;
for i=sz
    eval(['szAllLBRMS.subs(a,:)=sub',num2str(i),'allLBRMS;']);
    eval(['szFullSingleLBRMS.subs(a,:)=sub',num2str(i),'fullSingleLBRMS;']);
    eval(['szFullFirstLBRMS.subs(a,:)=sub',num2str(i),'fullFirstLBRMS;']);
    eval(['szFullSecondLBRMS.subs(a,:)=sub',num2str(i),'fullSecondLBRMS;']);
    eval(['szLessSingleLBRMS.subs(a,:)=sub',num2str(i),'lessSingleLBRMS;']);
    eval(['szLessFirstLBRMS.subs(a,:)=sub',num2str(i),'lessFirstLBRMS;']);
    eval(['szLessSecondLBRMS.subs(a,:)=sub',num2str(i),'lessSecondLBRMS;']);
    a=a+1;
end;
% means and sds
conAllLBRMS.mean = mean(conAllLBRMS.subs);
conAllLBRMS.sd = std(conAllLBRMS.subs);
conFullSingleLBRMS.mean = mean(conFullSingleLBRMS.subs);
conFullSingleLBRMS.sd = std(conFullSingleLBRMS.subs);
conFullFirstLBRMS.mean = mean(conFullFirstLBRMS.subs);
conFullFirstLBRMS.sd = std(conFullFirstLBRMS.subs);
conFullSecondLBRMS.mean = mean(conFullSecondLBRMS.subs);
conFullSecondLBRMS.sd = std(conFullSecondLBRMS.subs);
conLessSingleLBRMS.mean = mean(conLessSingleLBRMS.subs);
conLessSingleLBRMS.sd = std(conLessSingleLBRMS.subs);
conLessFirstLBRMS.mean = mean(conLessFirstLBRMS.subs);
conLessFirstLBRMS.sd = std(conLessFirstLBRMS.subs);
conLessSecondLBRMS.mean = mean(conLessSecondLBRMS.subs);
conLessSecondLBRMS.sd = std(conLessSecondLBRMS.subs);
cd /home/meg/Data/Maor/SchizoProject/expressions
save conLBRMS conAllLBRMS conFullSingleLBRMS conFullFirstLBRMS conFullSecondLBRMS conLessSingleLBRMS conLessFirstLBRMS conLessSecondLBRMS

szAllLBRMS.mean = mean(szAllLBRMS.subs);
szAllLBRMS.sd = std(szAllLBRMS.subs);
szFullSingleLBRMS.mean = mean(szFullSingleLBRMS.subs);
szFullSingleLBRMS.sd = std(szFullSingleLBRMS.subs);
szFullFirstLBRMS.mean = mean(szFullFirstLBRMS.subs);
szFullFirstLBRMS.sd = std(szFullFirstLBRMS.subs);
szFullSecondLBRMS.mean = mean(szFullSecondLBRMS.subs);
szFullSecondLBRMS.sd = std(szFullSecondLBRMS.subs);
szLessSingleLBRMS.mean = mean(szLessSingleLBRMS.subs);
szLessSingleLBRMS.sd = std(szLessSingleLBRMS.subs);
szLessFirstLBRMS.mean = mean(szLessFirstLBRMS.subs);
szLessFirstLBRMS.sd = std(szLessFirstLBRMS.subs);
szLessSecondLBRMS.mean = mean(szLessSecondLBRMS.subs);
szLessSecondLBRMS.sd = std(szLessSecondLBRMS.subs);
cd /home/meg/Data/Maor/SchizoProject/expressions
save szLBRMS szAllLBRMS szFullSingleLBRMS szFullFirstLBRMS szFullSecondLBRMS szLessSingleLBRMS szLessFirstLBRMS szLessSecondLBRMS

clear all
load conLBRMS
load szLBRMS
load time

% plotting
figure
h1 = plot(time,szAllLBRMS.mean,'b');
hold on;
h2 = plot(time,conAllLBRMS.mean,'r');
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szAllLBRMS.mean+szAllLBRMS.sd,szAllLBRMS.mean-szAllLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conAllLBRMS.mean+conAllLBRMS.sd,conAllLBRMS.mean-conAllLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Left Back RMS: Blue - SZ, Red - Control');
%
figure
subplot(2,1,1)
h1 = plot(time,conFullSingleLBRMS.mean,'b');
hold on;
h2 = plot(time,conFullFirstLBRMS.mean,'r');
h3 = plot(time,conFullSecondLBRMS.mean,'g');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conFullSingleLBRMS.mean+conFullSingleLBRMS.sd,conFullSingleLBRMS.mean-conFullSingleLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullFirstLBRMS.mean+conFullFirstLBRMS.sd,conFullFirstLBRMS.mean-conFullFirstLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,conFullSecondLBRMS.mean+conFullSecondLBRMS.sd,conFullSecondLBRMS.mean-conFullSecondLBRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Control Left Back RMS: Blue - Meaningfull Single, Red - Meaningfull First, Green - Meaningfull Second');

subplot(2,1,2)
h1 = plot(time,szFullSingleLBRMS.mean,'b');
hold on;
h2 = plot(time,szFullFirstLBRMS.mean,'r');
h3 = plot(time,szFullSecondLBRMS.mean,'g');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSingleLBRMS.mean+szFullSingleLBRMS.sd,szFullSingleLBRMS.mean-szFullSingleLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,szFullFirstLBRMS.mean+szFullFirstLBRMS.sd,szFullFirstLBRMS.mean-szFullFirstLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,szFullSecondLBRMS.mean+szFullSecondLBRMS.sd,szFullSecondLBRMS.mean-szFullSecondLBRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('SZ Left Back RMS: Blue - Meaningfull Single, Red - Meaningfull First, Green - Meaningfull Second');
%
figure
subplot(2,1,1)
h1 = plot(time,conLessSingleLBRMS.mean,'b');
hold on;
h2 = plot(time,conLessFirstLBRMS.mean,'r');
h3 = plot(time,conLessSecondLBRMS.mean,'g');
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conLessSingleLBRMS.mean+conLessSingleLBRMS.sd,conLessSingleLBRMS.mean-conLessSingleLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessFirstLBRMS.mean+conLessFirstLBRMS.sd,conLessFirstLBRMS.mean-conLessFirstLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,conLessSecondLBRMS.mean+conLessSecondLBRMS.sd,conLessSecondLBRMS.mean-conLessSecondLBRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Control Left Back RMS: Blue - MeaningLess Single, Red - MeaningLess First, Green - MeaningLess Second');

subplot(2,1,2)
h1 = plot(time,szLessSingleLBRMS.mean,'b');
hold on;
h2 = plot(time,szLessFirstLBRMS.mean,'r');
h3 = plot(time,szLessSecondLBRMS.mean,'g');
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSingleLBRMS.mean+szLessSingleLBRMS.sd,szLessSingleLBRMS.mean-szLessSingleLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,szLessFirstLBRMS.mean+szLessFirstLBRMS.sd,szLessFirstLBRMS.mean-szLessFirstLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,szLessSecondLBRMS.mean+szLessSecondLBRMS.sd,szLessSecondLBRMS.mean-szLessSecondLBRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('SZ Left Back RMS: Blue - MeaningLess Single, Red - MeaningLess First, Green - MeaningLess Second');
%
figure
subplot(3,1,1)
h1 = plot(time,szFullSingleLBRMS.mean,'b');
hold on;
h2 = plot(time,conFullSingleLBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSingleLBRMS.mean+szFullSingleLBRMS.sd,szFullSingleLBRMS.mean-szFullSingleLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullSingleLBRMS.mean+conFullSingleLBRMS.sd,conFullSingleLBRMS.mean-conFullSingleLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Left Back RMS: Blue - SZ Meaningfull Single, Red - Control Meaningfull Single');

subplot(3,1,2)
h1 = plot(time,szFullFirstLBRMS.mean,'b');
hold on;
h2 = plot(time,conFullFirstLBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullFirstLBRMS.mean+szFullFirstLBRMS.sd,szFullFirstLBRMS.mean-szFullFirstLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullFirstLBRMS.mean+conFullFirstLBRMS.sd,conFullFirstLBRMS.mean-conFullFirstLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Left Back RMS: Blue - SZ Meaningfull First, Red - Control Meaningfull First');

subplot(3,1,3)
h1 = plot(time,szFullSecondLBRMS.mean,'b');
hold on;
h2 = plot(time,conFullSecondLBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSecondLBRMS.mean+szFullSecondLBRMS.sd,szFullSecondLBRMS.mean-szFullSecondLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullSecondLBRMS.mean+conFullSecondLBRMS.sd,conFullSecondLBRMS.mean-conFullSecondLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Left Back RMS: Blue - SZ Meaningfull Second, Red - Control Meaningfull Second');
%
figure
subplot(3,1,1)
h1 = plot(time,szLessSingleLBRMS.mean,'b');
hold on;
h2 = plot(time,conLessSingleLBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSingleLBRMS.mean+szLessSingleLBRMS.sd,szLessSingleLBRMS.mean-szLessSingleLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessSingleLBRMS.mean+conLessSingleLBRMS.sd,conLessSingleLBRMS.mean-conLessSingleLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Left Back RMS: Blue - SZ Meaningless Single, Red - Control Meaningless Single');

subplot(3,1,2)
h1 = plot(time,szLessFirstLBRMS.mean,'b');
hold on;
h2 = plot(time,conLessFirstLBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessFirstLBRMS.mean+szLessFirstLBRMS.sd,szLessFirstLBRMS.mean-szLessFirstLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessFirstLBRMS.mean+conLessFirstLBRMS.sd,conLessFirstLBRMS.mean-conLessFirstLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Left Back RMS: Blue - SZ Meaningless First, Red - Control Meaningless First');

subplot(3,1,3)
h1 = plot(time,szLessSecondLBRMS.mean,'b');
hold on;
h2 = plot(time,conLessSecondLBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSecondLBRMS.mean+szLessSecondLBRMS.sd,szLessSecondLBRMS.mean-szLessSecondLBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessSecondLBRMS.mean+conLessSecondLBRMS.sd,conLessSecondLBRMS.mean-conLessSecondLBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Left Back RMS');
title('Left Back RMS: Blue - SZ Meaningless Second, Red - Control Meaningless Second');

%% RB RMS
for i=control
    eval(['sub',num2str(i),'allRBRMS=sub',num2str(i),'all.avg(find(ismember(sub',num2str(i),'all.label,RBchans)),:);']);
    eval(['sub',num2str(i),'allRBRMS=sqrt(mean(sub',num2str(i),'allRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'allRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSingleRBRMS=sub',num2str(i),'fullSingle.avg(find(ismember(sub',num2str(i),'fullSingle.label,RBchans)),:);']);
    eval(['sub',num2str(i),'fullSingleRBRMS=sqrt(mean(sub',num2str(i),'fullSingleRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSingleRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullFirstRBRMS=sub',num2str(i),'fullFirst.avg(find(ismember(sub',num2str(i),'fullFirst.label,RBchans)),:);']);
    eval(['sub',num2str(i),'fullFirstRBRMS=sqrt(mean(sub',num2str(i),'fullFirstRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullFirstRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSecondRBRMS=sub',num2str(i),'fullSecond.avg(find(ismember(sub',num2str(i),'fullSecond.label,RBchans)),:);']);
    eval(['sub',num2str(i),'fullSecondRBRMS=sqrt(mean(sub',num2str(i),'fullSecondRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSecondRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSingleRBRMS=sub',num2str(i),'lessSingle.avg(find(ismember(sub',num2str(i),'lessSingle.label,RBchans)),:);']);
    eval(['sub',num2str(i),'lessSingleRBRMS=sqrt(mean(sub',num2str(i),'lessSingleRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSingleRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessFirstRBRMS=sub',num2str(i),'lessFirst.avg(find(ismember(sub',num2str(i),'lessFirst.label,RBchans)),:);']);
    eval(['sub',num2str(i),'lessFirstRBRMS=sqrt(mean(sub',num2str(i),'lessFirstRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessFirstRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSecondRBRMS=sub',num2str(i),'lessSecond.avg(find(ismember(sub',num2str(i),'lessSecond.label,RBchans)),:);']);
    eval(['sub',num2str(i),'lessSecondRBRMS=sqrt(mean(sub',num2str(i),'lessSecondRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSecondRBRMS(:,1:305).^2)));']);
end
for i=sz
    eval(['sub',num2str(i),'allRBRMS=sub',num2str(i),'all.avg(find(ismember(sub',num2str(i),'all.label,RBchans)),:);']);
    eval(['sub',num2str(i),'allRBRMS=sqrt(mean(sub',num2str(i),'allRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'allRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSingleRBRMS=sub',num2str(i),'fullSingle.avg(find(ismember(sub',num2str(i),'fullSingle.label,RBchans)),:);']);
    eval(['sub',num2str(i),'fullSingleRBRMS=sqrt(mean(sub',num2str(i),'fullSingleRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSingleRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullFirstRBRMS=sub',num2str(i),'fullFirst.avg(find(ismember(sub',num2str(i),'fullFirst.label,RBchans)),:);']);
    eval(['sub',num2str(i),'fullFirstRBRMS=sqrt(mean(sub',num2str(i),'fullFirstRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullFirstRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'fullSecondRBRMS=sub',num2str(i),'fullSecond.avg(find(ismember(sub',num2str(i),'fullSecond.label,RBchans)),:);']);
    eval(['sub',num2str(i),'fullSecondRBRMS=sqrt(mean(sub',num2str(i),'fullSecondRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'fullSecondRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSingleRBRMS=sub',num2str(i),'lessSingle.avg(find(ismember(sub',num2str(i),'lessSingle.label,RBchans)),:);']);
    eval(['sub',num2str(i),'lessSingleRBRMS=sqrt(mean(sub',num2str(i),'lessSingleRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSingleRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessFirstRBRMS=sub',num2str(i),'lessFirst.avg(find(ismember(sub',num2str(i),'lessFirst.label,RBchans)),:);']);
    eval(['sub',num2str(i),'lessFirstRBRMS=sqrt(mean(sub',num2str(i),'lessFirstRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessFirstRBRMS(:,1:305).^2)));']);
    eval(['sub',num2str(i),'lessSecondRBRMS=sub',num2str(i),'lessSecond.avg(find(ismember(sub',num2str(i),'lessSecond.label,RBchans)),:);']);
    eval(['sub',num2str(i),'lessSecondRBRMS=sqrt(mean(sub',num2str(i),'lessSecondRBRMS.^2))-mean(sqrt(mean(sub',num2str(i),'lessSecondRBRMS(:,1:305).^2)));']);
end
    
% tables of all subs for control and for sz
a=1;
for i=control
    eval(['conAllRBRMS.subs(a,:)=sub',num2str(i),'allRBRMS;']);
    eval(['conFullSingleRBRMS.subs(a,:)=sub',num2str(i),'fullSingleRBRMS;']);
    eval(['conFullFirstRBRMS.subs(a,:)=sub',num2str(i),'fullFirstRBRMS;']);
    eval(['conFullSecondRBRMS.subs(a,:)=sub',num2str(i),'fullSecondRBRMS;']);
    eval(['conLessSingleRBRMS.subs(a,:)=sub',num2str(i),'lessSingleRBRMS;']);
    eval(['conLessFirstRBRMS.subs(a,:)=sub',num2str(i),'lessFirstRBRMS;']);
    eval(['conLessSecondRBRMS.subs(a,:)=sub',num2str(i),'lessSecondRBRMS;']);
    a=a+1;
end;
a=1;
for i=sz
    eval(['szAllRBRMS.subs(a,:)=sub',num2str(i),'allRBRMS;']);
    eval(['szFullSingleRBRMS.subs(a,:)=sub',num2str(i),'fullSingleRBRMS;']);
    eval(['szFullFirstRBRMS.subs(a,:)=sub',num2str(i),'fullFirstRBRMS;']);
    eval(['szFullSecondRBRMS.subs(a,:)=sub',num2str(i),'fullSecondRBRMS;']);
    eval(['szLessSingleRBRMS.subs(a,:)=sub',num2str(i),'lessSingleRBRMS;']);
    eval(['szLessFirstRBRMS.subs(a,:)=sub',num2str(i),'lessFirstRBRMS;']);
    eval(['szLessSecondRBRMS.subs(a,:)=sub',num2str(i),'lessSecondRBRMS;']);
    a=a+1;
end;
% means and sds
conAllRBRMS.mean = mean(conAllRBRMS.subs);
conAllRBRMS.sd = std(conAllRBRMS.subs);
conFullSingleRBRMS.mean = mean(conFullSingleRBRMS.subs);
conFullSingleRBRMS.sd = std(conFullSingleRBRMS.subs);
conFullFirstRBRMS.mean = mean(conFullFirstRBRMS.subs);
conFullFirstRBRMS.sd = std(conFullFirstRBRMS.subs);
conFullSecondRBRMS.mean = mean(conFullSecondRBRMS.subs);
conFullSecondRBRMS.sd = std(conFullSecondRBRMS.subs);
conLessSingleRBRMS.mean = mean(conLessSingleRBRMS.subs);
conLessSingleRBRMS.sd = std(conLessSingleRBRMS.subs);
conLessFirstRBRMS.mean = mean(conLessFirstRBRMS.subs);
conLessFirstRBRMS.sd = std(conLessFirstRBRMS.subs);
conLessSecondRBRMS.mean = mean(conLessSecondRBRMS.subs);
conLessSecondRBRMS.sd = std(conLessSecondRBRMS.subs);
cd /home/meg/Data/Maor/SchizoProject/expressions
save conRBRMS conAllRBRMS conFullSingleRBRMS conFullFirstRBRMS conFullSecondRBRMS conLessSingleRBRMS conLessFirstRBRMS conLessSecondRBRMS

szAllRBRMS.mean = mean(szAllRBRMS.subs);
szAllRBRMS.sd = std(szAllRBRMS.subs);
szFullSingleRBRMS.mean = mean(szFullSingleRBRMS.subs);
szFullSingleRBRMS.sd = std(szFullSingleRBRMS.subs);
szFullFirstRBRMS.mean = mean(szFullFirstRBRMS.subs);
szFullFirstRBRMS.sd = std(szFullFirstRBRMS.subs);
szFullSecondRBRMS.mean = mean(szFullSecondRBRMS.subs);
szFullSecondRBRMS.sd = std(szFullSecondRBRMS.subs);
szLessSingleRBRMS.mean = mean(szLessSingleRBRMS.subs);
szLessSingleRBRMS.sd = std(szLessSingleRBRMS.subs);
szLessFirstRBRMS.mean = mean(szLessFirstRBRMS.subs);
szLessFirstRBRMS.sd = std(szLessFirstRBRMS.subs);
szLessSecondRBRMS.mean = mean(szLessSecondRBRMS.subs);
szLessSecondRBRMS.sd = std(szLessSecondRBRMS.subs);
cd /home/meg/Data/Maor/SchizoProject/expressions
save szRBRMS szAllRBRMS szFullSingleRBRMS szFullFirstRBRMS szFullSecondRBRMS szLessSingleRBRMS szLessFirstRBRMS szLessSecondRBRMS

clear all
load conRBRMS
load szRBRMS
load time

% plotting
figure
h1 = plot(time,szAllRBRMS.mean,'b');
hold on;
h2 = plot(time,conAllRBRMS.mean,'r');
set(h1(1),'linewidth',5);
set(h2(1),'linewidth',5);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szAllRBRMS.mean+szAllRBRMS.sd,szAllRBRMS.mean-szAllRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conAllRBRMS.mean+conAllRBRMS.sd,conAllRBRMS.mean-conAllRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Right Back RMS: Blue - SZ, Red - Control');
%
figure
subplot(2,1,1)
h1 = plot(time,conFullSingleRBRMS.mean,'b');
hold on;
h2 = plot(time,conFullFirstRBRMS.mean,'r');
h3 = plot(time,conFullSecondRBRMS.mean,'g');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conFullSingleRBRMS.mean+conFullSingleRBRMS.sd,conFullSingleRBRMS.mean-conFullSingleRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullFirstRBRMS.mean+conFullFirstRBRMS.sd,conFullFirstRBRMS.mean-conFullFirstRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,conFullSecondRBRMS.mean+conFullSecondRBRMS.sd,conFullSecondRBRMS.mean-conFullSecondRBRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Control Right Back RMS: Blue - Meaningfull Single, Red - Meaningfull First, Green - Meaningfull Second');

subplot(2,1,2)
h1 = plot(time,szFullSingleRBRMS.mean,'b');
hold on;
h2 = plot(time,szFullFirstRBRMS.mean,'r');
h3 = plot(time,szFullSecondRBRMS.mean,'g');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSingleRBRMS.mean+szFullSingleRBRMS.sd,szFullSingleRBRMS.mean-szFullSingleRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,szFullFirstRBRMS.mean+szFullFirstRBRMS.sd,szFullFirstRBRMS.mean-szFullFirstRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,szFullSecondRBRMS.mean+szFullSecondRBRMS.sd,szFullSecondRBRMS.mean-szFullSecondRBRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('SZ Right Back RMS: Blue - Meaningfull Single, Red - Meaningfull First, Green - Meaningfull Second');
%
figure
subplot(2,1,1)
h1 = plot(time,conLessSingleRBRMS.mean,'b');
hold on;
h2 = plot(time,conLessFirstRBRMS.mean,'r');
h3 = plot(time,conLessSecondRBRMS.mean,'g');
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,conLessSingleRBRMS.mean+conLessSingleRBRMS.sd,conLessSingleRBRMS.mean-conLessSingleRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessFirstRBRMS.mean+conLessFirstRBRMS.sd,conLessFirstRBRMS.mean-conLessFirstRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,conLessSecondRBRMS.mean+conLessSecondRBRMS.sd,conLessSecondRBRMS.mean-conLessSecondRBRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Control Right Back RMS: Blue - MeaningLess Single, Red - MeaningLess First, Green - MeaningLess Second');

subplot(2,1,2)
h1 = plot(time,szLessSingleRBRMS.mean,'b');
hold on;
h2 = plot(time,szLessFirstRBRMS.mean,'r');
h3 = plot(time,szLessSecondRBRMS.mean,'g');
set(h1(1),'linewidth',3);
set(h2(1),'linewidth',3);
set(h3(1),'linewidth',3);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSingleRBRMS.mean+szLessSingleRBRMS.sd,szLessSingleRBRMS.mean-szLessSingleRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,szLessFirstRBRMS.mean+szLessFirstRBRMS.sd,szLessFirstRBRMS.mean-szLessFirstRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
jbfill(time,szLessSecondRBRMS.mean+szLessSecondRBRMS.sd,szLessSecondRBRMS.mean-szLessSecondRBRMS.sd,[0,1,0],[0,1,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('SZ Right Back RMS: Blue - MeaningLess Single, Red - MeaningLess First, Green - MeaningLess Second');
%
figure
subplot(3,1,1)
h1 = plot(time,szFullSingleRBRMS.mean,'b');
hold on;
h2 = plot(time,conFullSingleRBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSingleRBRMS.mean+szFullSingleRBRMS.sd,szFullSingleRBRMS.mean-szFullSingleRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullSingleRBRMS.mean+conFullSingleRBRMS.sd,conFullSingleRBRMS.mean-conFullSingleRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Right Back RMS: Blue - SZ Meaningfull Single, Red - Control Meaningfull Single');

subplot(3,1,2)
h1 = plot(time,szFullFirstRBRMS.mean,'b');
hold on;
h2 = plot(time,conFullFirstRBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullFirstRBRMS.mean+szFullFirstRBRMS.sd,szFullFirstRBRMS.mean-szFullFirstRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullFirstRBRMS.mean+conFullFirstRBRMS.sd,conFullFirstRBRMS.mean-conFullFirstRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Right Back RMS: Blue - SZ Meaningfull First, Red - Control Meaningfull First');

subplot(3,1,3)
h1 = plot(time,szFullSecondRBRMS.mean,'b');
hold on;
h2 = plot(time,conFullSecondRBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szFullSecondRBRMS.mean+szFullSecondRBRMS.sd,szFullSecondRBRMS.mean-szFullSecondRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conFullSecondRBRMS.mean+conFullSecondRBRMS.sd,conFullSecondRBRMS.mean-conFullSecondRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Right Back RMS: Blue - SZ Meaningfull Second, Red - Control Meaningfull Second');
%
figure
subplot(3,1,1)
h1 = plot(time,szLessSingleRBRMS.mean,'b');
hold on;
h2 = plot(time,conLessSingleRBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSingleRBRMS.mean+szLessSingleRBRMS.sd,szLessSingleRBRMS.mean-szLessSingleRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessSingleRBRMS.mean+conLessSingleRBRMS.sd,conLessSingleRBRMS.mean-conLessSingleRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Right Back RMS: Blue - SZ Meaningless Single, Red - Control Meaningless Single');

subplot(3,1,2)
h1 = plot(time,szLessFirstRBRMS.mean,'b');
hold on;
h2 = plot(time,conLessFirstRBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessFirstRBRMS.mean+szLessFirstRBRMS.sd,szLessFirstRBRMS.mean-szLessFirstRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessFirstRBRMS.mean+conLessFirstRBRMS.sd,conLessFirstRBRMS.mean-conLessFirstRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Right Back RMS: Blue - SZ Meaningless First, Red - Control Meaningless First');

subplot(3,1,3)
h1 = plot(time,szLessSecondRBRMS.mean,'b');
hold on;
h2 = plot(time,conLessSecondRBRMS.mean,'r');
axis([time(1),time(end),-2*10^(-14),12*10^(-14)])
set(h1(1),'linewidth',4);
set(h2(1),'linewidth',4);
grid on;
plot([0 0],[(-1)*10^(-14) 9*10^(-14)],'k');
jbfill(time,szLessSecondRBRMS.mean+szLessSecondRBRMS.sd,szLessSecondRBRMS.mean-szLessSecondRBRMS.sd,[0,0,1],[0,0,1],0,0.3)
jbfill(time,conLessSecondRBRMS.mean+conLessSecondRBRMS.sd,conLessSecondRBRMS.mean-conLessSecondRBRMS.sd,[1,0,0],[1,0,0],0,0.3)
xlabel('time in s');
ylabel('Right Back RMS');
title('Right Back RMS: Blue - SZ Meaningless Second, Red - Control Meaningless Second');