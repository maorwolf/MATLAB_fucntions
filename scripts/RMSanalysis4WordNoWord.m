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

% Front channels
Fchans = [LFchans;RFchans;{'A2'};{'A3'};{'A4'};{'A5'};{'A19'};{'A37'};{'A61'};{'A89'};{'A121'}];
% Back channels
Bchans = [LBchans;RBchans;{'A12'};{'A28'};{'A49'};{'A75'};{'A105'};{'A137'};{'A186'};{'A220'}];
% Left and Right channels
load LRpairs
Lchans = LRpairs(:,1);
Rchans = LRpairs(:,2);

save channs LBchans RBchans LFchans RFchans Fchans Bchans Lchans Rchans

%% RMS 
% LRFB for word first
clear all
load channs

SZ = [14, 16, 17, 19, 21, 23 24, 27:29, 31, 33:35, 37];

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'wordFirst.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'wordFirst.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'wordFirst.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'wordFirst.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'wordFirst.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'wordFirst.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'wordFirst.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'wordFirst.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSwordFirstL=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstL=sub',num2str(i),'RMSwordFirstL-mean(sub',num2str(i),'RMSwordFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstR=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstR=sub',num2str(i),'RMSwordFirstR-mean(sub',num2str(i),'RMSwordFirstR(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordFirstF=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstF=sub',num2str(i),'RMSwordFirstF-mean(sub',num2str(i),'RMSwordFirstF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstB=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstB=sub',num2str(i),'RMSwordFirstB-mean(sub',num2str(i),'RMSwordFirstB(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordFirstLF=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstLF=sub',num2str(i),'RMSwordFirstLF-mean(sub',num2str(i),'RMSwordFirstLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstRF=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstRF=sub',num2str(i),'RMSwordFirstRF-mean(sub',num2str(i),'RMSwordFirstRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordFirstLB=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstLB=sub',num2str(i),'RMSwordFirstLB-mean(sub',num2str(i),'RMSwordFirstLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstRB=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstRB=sub',num2str(i),'RMSwordFirstRB-mean(sub',num2str(i),'RMSwordFirstRB(1,1:305));']);
    
    eval(['SZRMSwordFirstL(a,:)=sub',num2str(i),'RMSwordFirstL;']);
    eval(['SZRMSwordFirstR(a,:)=sub',num2str(i),'RMSwordFirstR;']);
    eval(['SZRMSwordFirstF(a,:)=sub',num2str(i),'RMSwordFirstF;']);
    eval(['SZRMSwordFirstB(a,:)=sub',num2str(i),'RMSwordFirstB;']);
    eval(['SZRMSwordFirstLF(a,:)=sub',num2str(i),'RMSwordFirstLF;']);
    eval(['SZRMSwordFirstRF(a,:)=sub',num2str(i),'RMSwordFirstRF;']);
    eval(['SZRMSwordFirstLB(a,:)=sub',num2str(i),'RMSwordFirstLB;']);
    eval(['SZRMSwordFirstRB(a,:)=sub',num2str(i),'RMSwordFirstRB;']);
    a=a+1;
end;
clear a i

con = [0:3 5:9 12 15 20 32 36 39 41];

a = 1;
for i = con
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'wordFirst.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'wordFirst.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'wordFirst.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'wordFirst.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'wordFirst.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'wordFirst.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'wordFirst.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'wordFirst.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSwordFirstL=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstL=sub',num2str(i),'RMSwordFirstL-mean(sub',num2str(i),'RMSwordFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstR=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstR=sub',num2str(i),'RMSwordFirstR-mean(sub',num2str(i),'RMSwordFirstR(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordFirstF=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstF=sub',num2str(i),'RMSwordFirstF-mean(sub',num2str(i),'RMSwordFirstF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstB=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstB=sub',num2str(i),'RMSwordFirstB-mean(sub',num2str(i),'RMSwordFirstB(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordFirstLF=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstLF=sub',num2str(i),'RMSwordFirstLF-mean(sub',num2str(i),'RMSwordFirstLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstRF=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstRF=sub',num2str(i),'RMSwordFirstRF-mean(sub',num2str(i),'RMSwordFirstRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordFirstLB=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstLB=sub',num2str(i),'RMSwordFirstLB-mean(sub',num2str(i),'RMSwordFirstLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordFirstRB=sqrt(mean(sub',num2str(i),'wordFirst.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordFirstRB=sub',num2str(i),'RMSwordFirstRB-mean(sub',num2str(i),'RMSwordFirstRB(1,1:305));']);
    
    eval(['conRMSwordFirstL(a,:)=sub',num2str(i),'RMSwordFirstL;']);
    eval(['conRMSwordFirstR(a,:)=sub',num2str(i),'RMSwordFirstR;']);
    eval(['conRMSwordFirstF(a,:)=sub',num2str(i),'RMSwordFirstF;']);
    eval(['conRMSwordFirstB(a,:)=sub',num2str(i),'RMSwordFirstB;']);
    eval(['conRMSwordFirstLF(a,:)=sub',num2str(i),'RMSwordFirstLF;']);
    eval(['conRMSwordFirstRF(a,:)=sub',num2str(i),'RMSwordFirstRF;']);
    eval(['conRMSwordFirstLB(a,:)=sub',num2str(i),'RMSwordFirstLB;']);
    eval(['conRMSwordFirstRB(a,:)=sub',num2str(i),'RMSwordFirstRB;']);
    a=a+1;
end;
clear a i

%% RMS for word first
% comp1
wordFirstLBComp1=[mean(SZRMSwordFirstLB(:,[377 418]),2);mean(conRMSwordFirstLB(:,[377 418]),2)]; % 70-110 ms
wordFirstLFComp1=[mean(SZRMSwordFirstLF(:,[377 418]),2);mean(conRMSwordFirstLF(:,[377 418]),2)]; % 70-110 ms
wordFirstRBComp1=[mean(SZRMSwordFirstRB(:,[377 418]),2);mean(conRMSwordFirstRB(:,[377 418]),2)]; % 70-110 ms
wordFirstRFComp1=[mean(SZRMSwordFirstRF(:,[377 418]),2);mean(conRMSwordFirstRF(:,[377 418]),2)]; % 70-110 ms
% comp2
wordFirstLBComp2=[mean(SZRMSwordFirstLB(:,[428 499]),2);mean(conRMSwordFirstLB(:,[428 499]),2)]; % 120-190 ms
wordFirstLFComp2=[mean(SZRMSwordFirstLF(:,[428 499]),2);mean(conRMSwordFirstLF(:,[428 499]),2)]; % 120-190 ms
wordFirstRBComp2=[mean(SZRMSwordFirstRB(:,[428 499]),2);mean(conRMSwordFirstRB(:,[428 499]),2)]; % 120-190 ms
wordFirstRFComp2=[mean(SZRMSwordFirstRF(:,[428 499]),2);mean(conRMSwordFirstRF(:,[428 499]),2)]; % 120-190 ms
% comp3
wordFirstLBComp3=[mean(SZRMSwordFirstLB(:,[586 649]),2);mean(conRMSwordFirstLB(:,[548 611]),2)]; 
wordFirstLFComp3=[mean(SZRMSwordFirstLF(:,[586 649]),2);mean(conRMSwordFirstLF(:,[548 611]),2)]; 
wordFirstRBComp3=[mean(SZRMSwordFirstRB(:,[586 649]),2);mean(conRMSwordFirstRB(:,[548 611]),2)]; 
wordFirstRFComp3=[mean(SZRMSwordFirstRF(:,[586 649]),2);mean(conRMSwordFirstRF(:,[548 611]),2)]; 
% comp4
wordFirstLBComp4=[mean(SZRMSwordFirstLB(:,[650 701]),2);mean(conRMSwordFirstLB(:,[627 678]),2)];
wordFirstLFComp4=[mean(SZRMSwordFirstLF(:,[650 701]),2);mean(conRMSwordFirstLF(:,[627 678]),2)]; 
wordFirstRBComp4=[mean(SZRMSwordFirstRB(:,[650 701]),2);mean(conRMSwordFirstRB(:,[627 678]),2)]; 
wordFirstRFComp4=[mean(SZRMSwordFirstRF(:,[650 701]),2);mean(conRMSwordFirstRF(:,[627 678]),2)]; 
% comp5
wordFirstLBComp5=[mean(SZRMSwordFirstLB(:,[702 775]),2);mean(conRMSwordFirstLB(:,[699 772]),2)]; 
wordFirstLFComp5=[mean(SZRMSwordFirstLF(:,[702 775]),2);mean(conRMSwordFirstLF(:,[699 772]),2)];
wordFirstRBComp5=[mean(SZRMSwordFirstRB(:,[702 775]),2);mean(conRMSwordFirstRB(:,[699 772]),2)];
wordFirstRFComp5=[mean(SZRMSwordFirstRF(:,[702 775]),2);mean(conRMSwordFirstRF(:,[699 772]),2)];
% comp6
wordFirstLBComp6=[mean(SZRMSwordFirstLB(:,[953 1116]),2);mean(conRMSwordFirstLB(:,[916 1079]),2)];
wordFirstLFComp6=[mean(SZRMSwordFirstLF(:,[953 1116]),2);mean(conRMSwordFirstLF(:,[916 1079]),2)];
wordFirstRBComp6=[mean(SZRMSwordFirstRB(:,[953 1116]),2);mean(conRMSwordFirstRB(:,[916 1079]),2)];
wordFirstRFComp6=[mean(SZRMSwordFirstRF(:,[953 1116]),2);mean(conRMSwordFirstRF(:,[916 1079]),2)]; 

save RMS_wordFirst_LRBF wordFirstLBComp1 wordFirstLFComp1 wordFirstRBComp1 wordFirstRFComp1 ...
    wordFirstLBComp2 wordFirstLFComp2 wordFirstRBComp2 wordFirstRFComp2 ...
    wordFirstLBComp3 wordFirstLFComp3 wordFirstRBComp3 wordFirstRFComp3 ...
    wordFirstLBComp4 wordFirstLFComp4 wordFirstRBComp4 wordFirstRFComp4 ...
    wordFirstLBComp5 wordFirstLFComp5 wordFirstRBComp5 wordFirstRFComp5 ...
    wordFirstLBComp6 wordFirstLFComp6 wordFirstRBComp6 wordFirstRFComp6
clear all

%% LRFB for word second
clear all
load channs

SZ = [14, 16, 17, 19, 21, 23 24, 27:29, 31, 33:35, 37];

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'wordSecond.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'wordSecond.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'wordSecond.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'wordSecond.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'wordSecond.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'wordSecond.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'wordSecond.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'wordSecond.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSwordSecondL=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondL=sub',num2str(i),'RMSwordSecondL-mean(sub',num2str(i),'RMSwordSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondR=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondR=sub',num2str(i),'RMSwordSecondR-mean(sub',num2str(i),'RMSwordSecondR(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSecondF=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondF=sub',num2str(i),'RMSwordSecondF-mean(sub',num2str(i),'RMSwordSecondF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondB=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondB=sub',num2str(i),'RMSwordSecondB-mean(sub',num2str(i),'RMSwordSecondB(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSecondLF=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondLF=sub',num2str(i),'RMSwordSecondLF-mean(sub',num2str(i),'RMSwordSecondLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondRF=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondRF=sub',num2str(i),'RMSwordSecondRF-mean(sub',num2str(i),'RMSwordSecondRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSecondLB=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondLB=sub',num2str(i),'RMSwordSecondLB-mean(sub',num2str(i),'RMSwordSecondLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondRB=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondRB=sub',num2str(i),'RMSwordSecondRB-mean(sub',num2str(i),'RMSwordSecondRB(1,1:305));']);
    
    eval(['SZRMSwordSecondL(a,:)=sub',num2str(i),'RMSwordSecondL;']);
    eval(['SZRMSwordSecondR(a,:)=sub',num2str(i),'RMSwordSecondR;']);
    eval(['SZRMSwordSecondF(a,:)=sub',num2str(i),'RMSwordSecondF;']);
    eval(['SZRMSwordSecondB(a,:)=sub',num2str(i),'RMSwordSecondB;']);
    eval(['SZRMSwordSecondLF(a,:)=sub',num2str(i),'RMSwordSecondLF;']);
    eval(['SZRMSwordSecondRF(a,:)=sub',num2str(i),'RMSwordSecondRF;']);
    eval(['SZRMSwordSecondLB(a,:)=sub',num2str(i),'RMSwordSecondLB;']);
    eval(['SZRMSwordSecondRB(a,:)=sub',num2str(i),'RMSwordSecondRB;']);
    a=a+1;
end;
clear a i

con = [0:3 5:9 12 15 20 32 36 39 41];

a = 1;
for i = con
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'wordSecond.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'wordSecond.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'wordSecond.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'wordSecond.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'wordSecond.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'wordSecond.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'wordSecond.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'wordSecond.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSwordSecondL=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondL=sub',num2str(i),'RMSwordSecondL-mean(sub',num2str(i),'RMSwordSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondR=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondR=sub',num2str(i),'RMSwordSecondR-mean(sub',num2str(i),'RMSwordSecondR(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSecondF=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondF=sub',num2str(i),'RMSwordSecondF-mean(sub',num2str(i),'RMSwordSecondF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondB=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondB=sub',num2str(i),'RMSwordSecondB-mean(sub',num2str(i),'RMSwordSecondB(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSecondLF=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondLF=sub',num2str(i),'RMSwordSecondLF-mean(sub',num2str(i),'RMSwordSecondLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondRF=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondRF=sub',num2str(i),'RMSwordSecondRF-mean(sub',num2str(i),'RMSwordSecondRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSecondLB=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondLB=sub',num2str(i),'RMSwordSecondLB-mean(sub',num2str(i),'RMSwordSecondLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSecondRB=sqrt(mean(sub',num2str(i),'wordSecond.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSecondRB=sub',num2str(i),'RMSwordSecondRB-mean(sub',num2str(i),'RMSwordSecondRB(1,1:305));']);
    
    eval(['conRMSwordSecondL(a,:)=sub',num2str(i),'RMSwordSecondL;']);
    eval(['conRMSwordSecondR(a,:)=sub',num2str(i),'RMSwordSecondR;']);
    eval(['conRMSwordSecondF(a,:)=sub',num2str(i),'RMSwordSecondF;']);
    eval(['conRMSwordSecondB(a,:)=sub',num2str(i),'RMSwordSecondB;']);
    eval(['conRMSwordSecondLF(a,:)=sub',num2str(i),'RMSwordSecondLF;']);
    eval(['conRMSwordSecondRF(a,:)=sub',num2str(i),'RMSwordSecondRF;']);
    eval(['conRMSwordSecondLB(a,:)=sub',num2str(i),'RMSwordSecondLB;']);
    eval(['conRMSwordSecondRB(a,:)=sub',num2str(i),'RMSwordSecondRB;']);
    a=a+1;
end;
clear a i

%% RMS for word second
% comp1
wordSecondLBComp1=[mean(SZRMSwordSecondLB(:,[377 418]),2);mean(conRMSwordSecondLB(:,[377 418]),2)]; % 70-110 ms
wordSecondLFComp1=[mean(SZRMSwordSecondLF(:,[377 418]),2);mean(conRMSwordSecondLF(:,[377 418]),2)]; % 70-110 ms
wordSecondRBComp1=[mean(SZRMSwordSecondRB(:,[377 418]),2);mean(conRMSwordSecondRB(:,[377 418]),2)]; % 70-110 ms
wordSecondRFComp1=[mean(SZRMSwordSecondRF(:,[377 418]),2);mean(conRMSwordSecondRF(:,[377 418]),2)]; % 70-110 ms
% comp2
wordSecondLBComp2=[mean(SZRMSwordSecondLB(:,[428 499]),2);mean(conRMSwordSecondLB(:,[428 499]),2)]; % 120-190 ms
wordSecondLFComp2=[mean(SZRMSwordSecondLF(:,[428 499]),2);mean(conRMSwordSecondLF(:,[428 499]),2)]; % 120-190 ms
wordSecondRBComp2=[mean(SZRMSwordSecondRB(:,[428 499]),2);mean(conRMSwordSecondRB(:,[428 499]),2)]; % 120-190 ms
wordSecondRFComp2=[mean(SZRMSwordSecondRF(:,[428 499]),2);mean(conRMSwordSecondRF(:,[428 499]),2)]; % 120-190 ms
% comp3
wordSecondLBComp3=[mean(SZRMSwordSecondLB(:,[586 649]),2);mean(conRMSwordSecondLB(:,[548 611]),2)]; 
wordSecondLFComp3=[mean(SZRMSwordSecondLF(:,[586 649]),2);mean(conRMSwordSecondLF(:,[548 611]),2)]; 
wordSecondRBComp3=[mean(SZRMSwordSecondRB(:,[586 649]),2);mean(conRMSwordSecondRB(:,[548 611]),2)]; 
wordSecondRFComp3=[mean(SZRMSwordSecondRF(:,[586 649]),2);mean(conRMSwordSecondRF(:,[548 611]),2)]; 
% comp4
wordSecondLBComp4=[mean(SZRMSwordSecondLB(:,[650 701]),2);mean(conRMSwordSecondLB(:,[627 678]),2)];
wordSecondLFComp4=[mean(SZRMSwordSecondLF(:,[650 701]),2);mean(conRMSwordSecondLF(:,[627 678]),2)]; 
wordSecondRBComp4=[mean(SZRMSwordSecondRB(:,[650 701]),2);mean(conRMSwordSecondRB(:,[627 678]),2)]; 
wordSecondRFComp4=[mean(SZRMSwordSecondRF(:,[650 701]),2);mean(conRMSwordSecondRF(:,[627 678]),2)]; 
% comp5
wordSecondLBComp5=[mean(SZRMSwordSecondLB(:,[702 775]),2);mean(conRMSwordSecondLB(:,[699 772]),2)]; 
wordSecondLFComp5=[mean(SZRMSwordSecondLF(:,[702 775]),2);mean(conRMSwordSecondLF(:,[699 772]),2)];
wordSecondRBComp5=[mean(SZRMSwordSecondRB(:,[702 775]),2);mean(conRMSwordSecondRB(:,[699 772]),2)];
wordSecondRFComp5=[mean(SZRMSwordSecondRF(:,[702 775]),2);mean(conRMSwordSecondRF(:,[699 772]),2)];
% comp6
wordSecondLBComp6=[mean(SZRMSwordSecondLB(:,[953 1116]),2);mean(conRMSwordSecondLB(:,[916 1079]),2)];
wordSecondLFComp6=[mean(SZRMSwordSecondLF(:,[953 1116]),2);mean(conRMSwordSecondLF(:,[916 1079]),2)];
wordSecondRBComp6=[mean(SZRMSwordSecondRB(:,[953 1116]),2);mean(conRMSwordSecondRB(:,[916 1079]),2)];
wordSecondRFComp6=[mean(SZRMSwordSecondRF(:,[953 1116]),2);mean(conRMSwordSecondRF(:,[916 1079]),2)]; 

save RMS_wordSecond_LRBF wordSecondLBComp1 wordSecondLFComp1 wordSecondRBComp1 wordSecondRFComp1 ...
    wordSecondLBComp2 wordSecondLFComp2 wordSecondRBComp2 wordSecondRFComp2 ...
    wordSecondLBComp3 wordSecondLFComp3 wordSecondRBComp3 wordSecondRFComp3 ...
    wordSecondLBComp4 wordSecondLFComp4 wordSecondRBComp4 wordSecondRFComp4 ...
    wordSecondLBComp5 wordSecondLFComp5 wordSecondRBComp5 wordSecondRFComp5 ...
    wordSecondLBComp6 wordSecondLFComp6 wordSecondRBComp6 wordSecondRFComp6
clear all

%% LRFB for word single
clear all
load channs

SZ = [14, 16, 17, 19, 21, 23 24, 27:29, 31, 33:35, 37];

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'wordSingle.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'wordSingle.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'wordSingle.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'wordSingle.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'wordSingle.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'wordSingle.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'wordSingle.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'wordSingle.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSwordSingleL=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleL=sub',num2str(i),'RMSwordSingleL-mean(sub',num2str(i),'RMSwordSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleR=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleR=sub',num2str(i),'RMSwordSingleR-mean(sub',num2str(i),'RMSwordSingleR(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSingleF=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleF=sub',num2str(i),'RMSwordSingleF-mean(sub',num2str(i),'RMSwordSingleF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleB=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleB=sub',num2str(i),'RMSwordSingleB-mean(sub',num2str(i),'RMSwordSingleB(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSingleLF=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleLF=sub',num2str(i),'RMSwordSingleLF-mean(sub',num2str(i),'RMSwordSingleLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleRF=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleRF=sub',num2str(i),'RMSwordSingleRF-mean(sub',num2str(i),'RMSwordSingleRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSingleLB=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleLB=sub',num2str(i),'RMSwordSingleLB-mean(sub',num2str(i),'RMSwordSingleLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleRB=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleRB=sub',num2str(i),'RMSwordSingleRB-mean(sub',num2str(i),'RMSwordSingleRB(1,1:305));']);
    
    eval(['SZRMSwordSingleL(a,:)=sub',num2str(i),'RMSwordSingleL;']);
    eval(['SZRMSwordSingleR(a,:)=sub',num2str(i),'RMSwordSingleR;']);
    eval(['SZRMSwordSingleF(a,:)=sub',num2str(i),'RMSwordSingleF;']);
    eval(['SZRMSwordSingleB(a,:)=sub',num2str(i),'RMSwordSingleB;']);
    eval(['SZRMSwordSingleLF(a,:)=sub',num2str(i),'RMSwordSingleLF;']);
    eval(['SZRMSwordSingleRF(a,:)=sub',num2str(i),'RMSwordSingleRF;']);
    eval(['SZRMSwordSingleLB(a,:)=sub',num2str(i),'RMSwordSingleLB;']);
    eval(['SZRMSwordSingleRB(a,:)=sub',num2str(i),'RMSwordSingleRB;']);
    a=a+1;
end;
clear a i

con = [0:3 5:9 12 15 20 32 36 39 41];

a = 1;
for i = con
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'wordSingle.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'wordSingle.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'wordSingle.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'wordSingle.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'wordSingle.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'wordSingle.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'wordSingle.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'wordSingle.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSwordSingleL=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleL=sub',num2str(i),'RMSwordSingleL-mean(sub',num2str(i),'RMSwordSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleR=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleR=sub',num2str(i),'RMSwordSingleR-mean(sub',num2str(i),'RMSwordSingleR(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSingleF=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleF=sub',num2str(i),'RMSwordSingleF-mean(sub',num2str(i),'RMSwordSingleF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleB=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleB=sub',num2str(i),'RMSwordSingleB-mean(sub',num2str(i),'RMSwordSingleB(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSingleLF=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleLF=sub',num2str(i),'RMSwordSingleLF-mean(sub',num2str(i),'RMSwordSingleLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleRF=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleRF=sub',num2str(i),'RMSwordSingleRF-mean(sub',num2str(i),'RMSwordSingleRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSwordSingleLB=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleLB=sub',num2str(i),'RMSwordSingleLB-mean(sub',num2str(i),'RMSwordSingleLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSwordSingleRB=sqrt(mean(sub',num2str(i),'wordSingle.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSwordSingleRB=sub',num2str(i),'RMSwordSingleRB-mean(sub',num2str(i),'RMSwordSingleRB(1,1:305));']);
    
    eval(['conRMSwordSingleL(a,:)=sub',num2str(i),'RMSwordSingleL;']);
    eval(['conRMSwordSingleR(a,:)=sub',num2str(i),'RMSwordSingleR;']);
    eval(['conRMSwordSingleF(a,:)=sub',num2str(i),'RMSwordSingleF;']);
    eval(['conRMSwordSingleB(a,:)=sub',num2str(i),'RMSwordSingleB;']);
    eval(['conRMSwordSingleLF(a,:)=sub',num2str(i),'RMSwordSingleLF;']);
    eval(['conRMSwordSingleRF(a,:)=sub',num2str(i),'RMSwordSingleRF;']);
    eval(['conRMSwordSingleLB(a,:)=sub',num2str(i),'RMSwordSingleLB;']);
    eval(['conRMSwordSingleRB(a,:)=sub',num2str(i),'RMSwordSingleRB;']);
    a=a+1;
end;
clear a i

%% RMS for word single
% comp1
wordSingleLBComp1=[mean(SZRMSwordSingleLB(:,[377 418]),2);mean(conRMSwordSingleLB(:,[377 418]),2)]; % 70-110 ms
wordSingleLFComp1=[mean(SZRMSwordSingleLF(:,[377 418]),2);mean(conRMSwordSingleLF(:,[377 418]),2)]; % 70-110 ms
wordSingleRBComp1=[mean(SZRMSwordSingleRB(:,[377 418]),2);mean(conRMSwordSingleRB(:,[377 418]),2)]; % 70-110 ms
wordSingleRFComp1=[mean(SZRMSwordSingleRF(:,[377 418]),2);mean(conRMSwordSingleRF(:,[377 418]),2)]; % 70-110 ms
% comp2
wordSingleLBComp2=[mean(SZRMSwordSingleLB(:,[428 499]),2);mean(conRMSwordSingleLB(:,[428 499]),2)]; % 120-190 ms
wordSingleLFComp2=[mean(SZRMSwordSingleLF(:,[428 499]),2);mean(conRMSwordSingleLF(:,[428 499]),2)]; % 120-190 ms
wordSingleRBComp2=[mean(SZRMSwordSingleRB(:,[428 499]),2);mean(conRMSwordSingleRB(:,[428 499]),2)]; % 120-190 ms
wordSingleRFComp2=[mean(SZRMSwordSingleRF(:,[428 499]),2);mean(conRMSwordSingleRF(:,[428 499]),2)]; % 120-190 ms
% comp3
wordSingleLBComp3=[mean(SZRMSwordSingleLB(:,[586 649]),2);mean(conRMSwordSingleLB(:,[548 611]),2)]; 
wordSingleLFComp3=[mean(SZRMSwordSingleLF(:,[586 649]),2);mean(conRMSwordSingleLF(:,[548 611]),2)]; 
wordSingleRBComp3=[mean(SZRMSwordSingleRB(:,[586 649]),2);mean(conRMSwordSingleRB(:,[548 611]),2)]; 
wordSingleRFComp3=[mean(SZRMSwordSingleRF(:,[586 649]),2);mean(conRMSwordSingleRF(:,[548 611]),2)]; 
% comp4
wordSingleLBComp4=[mean(SZRMSwordSingleLB(:,[650 701]),2);mean(conRMSwordSingleLB(:,[627 678]),2)];
wordSingleLFComp4=[mean(SZRMSwordSingleLF(:,[650 701]),2);mean(conRMSwordSingleLF(:,[627 678]),2)]; 
wordSingleRBComp4=[mean(SZRMSwordSingleRB(:,[650 701]),2);mean(conRMSwordSingleRB(:,[627 678]),2)]; 
wordSingleRFComp4=[mean(SZRMSwordSingleRF(:,[650 701]),2);mean(conRMSwordSingleRF(:,[627 678]),2)]; 
% comp5
wordSingleLBComp5=[mean(SZRMSwordSingleLB(:,[702 775]),2);mean(conRMSwordSingleLB(:,[699 772]),2)]; 
wordSingleLFComp5=[mean(SZRMSwordSingleLF(:,[702 775]),2);mean(conRMSwordSingleLF(:,[699 772]),2)];
wordSingleRBComp5=[mean(SZRMSwordSingleRB(:,[702 775]),2);mean(conRMSwordSingleRB(:,[699 772]),2)];
wordSingleRFComp5=[mean(SZRMSwordSingleRF(:,[702 775]),2);mean(conRMSwordSingleRF(:,[699 772]),2)];
% comp6
wordSingleLBComp6=[mean(SZRMSwordSingleLB(:,[953 1116]),2);mean(conRMSwordSingleLB(:,[916 1079]),2)];
wordSingleLFComp6=[mean(SZRMSwordSingleLF(:,[953 1116]),2);mean(conRMSwordSingleLF(:,[916 1079]),2)];
wordSingleRBComp6=[mean(SZRMSwordSingleRB(:,[953 1116]),2);mean(conRMSwordSingleRB(:,[916 1079]),2)];
wordSingleRFComp6=[mean(SZRMSwordSingleRF(:,[953 1116]),2);mean(conRMSwordSingleRF(:,[916 1079]),2)]; 

save RMS_wordSingle_LRBF wordSingleLBComp1 wordSingleLFComp1 wordSingleRBComp1 wordSingleRFComp1 ...
    wordSingleLBComp2 wordSingleLFComp2 wordSingleRBComp2 wordSingleRFComp2 ...
    wordSingleLBComp3 wordSingleLFComp3 wordSingleRBComp3 wordSingleRFComp3 ...
    wordSingleLBComp4 wordSingleLFComp4 wordSingleRBComp4 wordSingleRFComp4 ...
    wordSingleLBComp5 wordSingleLFComp5 wordSingleRBComp5 wordSingleRFComp5 ...
    wordSingleLBComp6 wordSingleLFComp6 wordSingleRBComp6 wordSingleRFComp6
clear all

%% LRFB for non-word single
clear all
load channs

SZ = [14, 16, 17, 19, 21, 23 24, 27:29, 31, 33:35, 37];

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'nonWordSingle.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordSingle.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'nonWordSingle.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'nonWordSingle.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'nonWordSingle.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'nonWordSingle.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'nonWordSingle.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'nonWordSingle.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSnonWordSingleL=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleL=sub',num2str(i),'RMSnonWordSingleL-mean(sub',num2str(i),'RMSnonWordSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleR=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleR=sub',num2str(i),'RMSnonWordSingleR-mean(sub',num2str(i),'RMSnonWordSingleR(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSingleF=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleF=sub',num2str(i),'RMSnonWordSingleF-mean(sub',num2str(i),'RMSnonWordSingleF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleB=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleB=sub',num2str(i),'RMSnonWordSingleB-mean(sub',num2str(i),'RMSnonWordSingleB(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSingleLF=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleLF=sub',num2str(i),'RMSnonWordSingleLF-mean(sub',num2str(i),'RMSnonWordSingleLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleRF=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleRF=sub',num2str(i),'RMSnonWordSingleRF-mean(sub',num2str(i),'RMSnonWordSingleRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSingleLB=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleLB=sub',num2str(i),'RMSnonWordSingleLB-mean(sub',num2str(i),'RMSnonWordSingleLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleRB=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleRB=sub',num2str(i),'RMSnonWordSingleRB-mean(sub',num2str(i),'RMSnonWordSingleRB(1,1:305));']);
    
    eval(['SZRMSnonWordSingleL(a,:)=sub',num2str(i),'RMSnonWordSingleL;']);
    eval(['SZRMSnonWordSingleR(a,:)=sub',num2str(i),'RMSnonWordSingleR;']);
    eval(['SZRMSnonWordSingleF(a,:)=sub',num2str(i),'RMSnonWordSingleF;']);
    eval(['SZRMSnonWordSingleB(a,:)=sub',num2str(i),'RMSnonWordSingleB;']);
    eval(['SZRMSnonWordSingleLF(a,:)=sub',num2str(i),'RMSnonWordSingleLF;']);
    eval(['SZRMSnonWordSingleRF(a,:)=sub',num2str(i),'RMSnonWordSingleRF;']);
    eval(['SZRMSnonWordSingleLB(a,:)=sub',num2str(i),'RMSnonWordSingleLB;']);
    eval(['SZRMSnonWordSingleRB(a,:)=sub',num2str(i),'RMSnonWordSingleRB;']);
    a=a+1;
end;
clear a i

con = [0:3 5:9 12 15 20 32 36 39 41];

a = 1;
for i = con
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'nonWordSingle.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordSingle.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'nonWordSingle.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'nonWordSingle.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'nonWordSingle.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'nonWordSingle.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'nonWordSingle.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'nonWordSingle.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSnonWordSingleL=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleL=sub',num2str(i),'RMSnonWordSingleL-mean(sub',num2str(i),'RMSnonWordSingleL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleR=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleR=sub',num2str(i),'RMSnonWordSingleR-mean(sub',num2str(i),'RMSnonWordSingleR(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSingleF=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleF=sub',num2str(i),'RMSnonWordSingleF-mean(sub',num2str(i),'RMSnonWordSingleF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleB=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleB=sub',num2str(i),'RMSnonWordSingleB-mean(sub',num2str(i),'RMSnonWordSingleB(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSingleLF=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleLF=sub',num2str(i),'RMSnonWordSingleLF-mean(sub',num2str(i),'RMSnonWordSingleLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleRF=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleRF=sub',num2str(i),'RMSnonWordSingleRF-mean(sub',num2str(i),'RMSnonWordSingleRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSingleLB=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleLB=sub',num2str(i),'RMSnonWordSingleLB-mean(sub',num2str(i),'RMSnonWordSingleLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSingleRB=sqrt(mean(sub',num2str(i),'nonWordSingle.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSingleRB=sub',num2str(i),'RMSnonWordSingleRB-mean(sub',num2str(i),'RMSnonWordSingleRB(1,1:305));']);
    
    eval(['conRMSnonWordSingleL(a,:)=sub',num2str(i),'RMSnonWordSingleL;']);
    eval(['conRMSnonWordSingleR(a,:)=sub',num2str(i),'RMSnonWordSingleR;']);
    eval(['conRMSnonWordSingleF(a,:)=sub',num2str(i),'RMSnonWordSingleF;']);
    eval(['conRMSnonWordSingleB(a,:)=sub',num2str(i),'RMSnonWordSingleB;']);
    eval(['conRMSnonWordSingleLF(a,:)=sub',num2str(i),'RMSnonWordSingleLF;']);
    eval(['conRMSnonWordSingleRF(a,:)=sub',num2str(i),'RMSnonWordSingleRF;']);
    eval(['conRMSnonWordSingleLB(a,:)=sub',num2str(i),'RMSnonWordSingleLB;']);
    eval(['conRMSnonWordSingleRB(a,:)=sub',num2str(i),'RMSnonWordSingleRB;']);
    a=a+1;
end;
clear a i

%% RMS for non-word single
% comp1
nonWordSingleLBComp1=[mean(SZRMSnonWordSingleLB(:,[377 418]),2);mean(conRMSnonWordSingleLB(:,[377 418]),2)]; % 70-110 ms
nonWordSingleLFComp1=[mean(SZRMSnonWordSingleLF(:,[377 418]),2);mean(conRMSnonWordSingleLF(:,[377 418]),2)]; % 70-110 ms
nonWordSingleRBComp1=[mean(SZRMSnonWordSingleRB(:,[377 418]),2);mean(conRMSnonWordSingleRB(:,[377 418]),2)]; % 70-110 ms
nonWordSingleRFComp1=[mean(SZRMSnonWordSingleRF(:,[377 418]),2);mean(conRMSnonWordSingleRF(:,[377 418]),2)]; % 70-110 ms
% comp2
nonWordSingleLBComp2=[mean(SZRMSnonWordSingleLB(:,[428 499]),2);mean(conRMSnonWordSingleLB(:,[428 499]),2)]; % 120-190 ms
nonWordSingleLFComp2=[mean(SZRMSnonWordSingleLF(:,[428 499]),2);mean(conRMSnonWordSingleLF(:,[428 499]),2)]; % 120-190 ms
nonWordSingleRBComp2=[mean(SZRMSnonWordSingleRB(:,[428 499]),2);mean(conRMSnonWordSingleRB(:,[428 499]),2)]; % 120-190 ms
nonWordSingleRFComp2=[mean(SZRMSnonWordSingleRF(:,[428 499]),2);mean(conRMSnonWordSingleRF(:,[428 499]),2)]; % 120-190 ms
% comp3
nonWordSingleLBComp3=[mean(SZRMSnonWordSingleLB(:,[586 649]),2);mean(conRMSnonWordSingleLB(:,[548 611]),2)]; 
nonWordSingleLFComp3=[mean(SZRMSnonWordSingleLF(:,[586 649]),2);mean(conRMSnonWordSingleLF(:,[548 611]),2)]; 
nonWordSingleRBComp3=[mean(SZRMSnonWordSingleRB(:,[586 649]),2);mean(conRMSnonWordSingleRB(:,[548 611]),2)]; 
nonWordSingleRFComp3=[mean(SZRMSnonWordSingleRF(:,[586 649]),2);mean(conRMSnonWordSingleRF(:,[548 611]),2)]; 
% comp4
nonWordSingleLBComp4=[mean(SZRMSnonWordSingleLB(:,[650 701]),2);mean(conRMSnonWordSingleLB(:,[627 678]),2)];
nonWordSingleLFComp4=[mean(SZRMSnonWordSingleLF(:,[650 701]),2);mean(conRMSnonWordSingleLF(:,[627 678]),2)]; 
nonWordSingleRBComp4=[mean(SZRMSnonWordSingleRB(:,[650 701]),2);mean(conRMSnonWordSingleRB(:,[627 678]),2)]; 
nonWordSingleRFComp4=[mean(SZRMSnonWordSingleRF(:,[650 701]),2);mean(conRMSnonWordSingleRF(:,[627 678]),2)]; 
% comp5
nonWordSingleLBComp5=[mean(SZRMSnonWordSingleLB(:,[702 775]),2);mean(conRMSnonWordSingleLB(:,[699 772]),2)]; 
nonWordSingleLFComp5=[mean(SZRMSnonWordSingleLF(:,[702 775]),2);mean(conRMSnonWordSingleLF(:,[699 772]),2)];
nonWordSingleRBComp5=[mean(SZRMSnonWordSingleRB(:,[702 775]),2);mean(conRMSnonWordSingleRB(:,[699 772]),2)];
nonWordSingleRFComp5=[mean(SZRMSnonWordSingleRF(:,[702 775]),2);mean(conRMSnonWordSingleRF(:,[699 772]),2)];
% comp6
nonWordSingleLBComp6=[mean(SZRMSnonWordSingleLB(:,[953 1116]),2);mean(conRMSnonWordSingleLB(:,[916 1079]),2)];
nonWordSingleLFComp6=[mean(SZRMSnonWordSingleLF(:,[953 1116]),2);mean(conRMSnonWordSingleLF(:,[916 1079]),2)];
nonWordSingleRBComp6=[mean(SZRMSnonWordSingleRB(:,[953 1116]),2);mean(conRMSnonWordSingleRB(:,[916 1079]),2)];
nonWordSingleRFComp6=[mean(SZRMSnonWordSingleRF(:,[953 1116]),2);mean(conRMSnonWordSingleRF(:,[916 1079]),2)]; 

save RMS_nonWordSingle_LRBF nonWordSingleLBComp1 nonWordSingleLFComp1 nonWordSingleRBComp1 nonWordSingleRFComp1 ...
    nonWordSingleLBComp2 nonWordSingleLFComp2 nonWordSingleRBComp2 nonWordSingleRFComp2 ...
    nonWordSingleLBComp3 nonWordSingleLFComp3 nonWordSingleRBComp3 nonWordSingleRFComp3 ...
    nonWordSingleLBComp4 nonWordSingleLFComp4 nonWordSingleRBComp4 nonWordSingleRFComp4 ...
    nonWordSingleLBComp5 nonWordSingleLFComp5 nonWordSingleRBComp5 nonWordSingleRFComp5 ...
    nonWordSingleLBComp6 nonWordSingleLFComp6 nonWordSingleRBComp6 nonWordSingleRFComp6
clear all

%% LRFB for non-word first
clear all
load channs

SZ = [14, 16, 17, 19, 21, 23 24, 27:29, 31, 33:35, 37];

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'nonWordFirst.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordFirst.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'nonWordFirst.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'nonWordFirst.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'nonWordFirst.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'nonWordFirst.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'nonWordFirst.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'nonWordFirst.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSnonWordFirstL=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstL=sub',num2str(i),'RMSnonWordFirstL-mean(sub',num2str(i),'RMSnonWordFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstR=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstR=sub',num2str(i),'RMSnonWordFirstR-mean(sub',num2str(i),'RMSnonWordFirstR(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordFirstF=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstF=sub',num2str(i),'RMSnonWordFirstF-mean(sub',num2str(i),'RMSnonWordFirstF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstB=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstB=sub',num2str(i),'RMSnonWordFirstB-mean(sub',num2str(i),'RMSnonWordFirstB(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordFirstLF=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstLF=sub',num2str(i),'RMSnonWordFirstLF-mean(sub',num2str(i),'RMSnonWordFirstLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstRF=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstRF=sub',num2str(i),'RMSnonWordFirstRF-mean(sub',num2str(i),'RMSnonWordFirstRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordFirstLB=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstLB=sub',num2str(i),'RMSnonWordFirstLB-mean(sub',num2str(i),'RMSnonWordFirstLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstRB=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstRB=sub',num2str(i),'RMSnonWordFirstRB-mean(sub',num2str(i),'RMSnonWordFirstRB(1,1:305));']);
    
    eval(['SZRMSnonWordFirstL(a,:)=sub',num2str(i),'RMSnonWordFirstL;']);
    eval(['SZRMSnonWordFirstR(a,:)=sub',num2str(i),'RMSnonWordFirstR;']);
    eval(['SZRMSnonWordFirstF(a,:)=sub',num2str(i),'RMSnonWordFirstF;']);
    eval(['SZRMSnonWordFirstB(a,:)=sub',num2str(i),'RMSnonWordFirstB;']);
    eval(['SZRMSnonWordFirstLF(a,:)=sub',num2str(i),'RMSnonWordFirstLF;']);
    eval(['SZRMSnonWordFirstRF(a,:)=sub',num2str(i),'RMSnonWordFirstRF;']);
    eval(['SZRMSnonWordFirstLB(a,:)=sub',num2str(i),'RMSnonWordFirstLB;']);
    eval(['SZRMSnonWordFirstRB(a,:)=sub',num2str(i),'RMSnonWordFirstRB;']);
    a=a+1;
end;
clear a i

con = [0:3 5:9 12 15 20 32 36 39 41];

a = 1;
for i = con
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'nonWordFirst.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordFirst.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'nonWordFirst.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'nonWordFirst.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'nonWordFirst.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'nonWordFirst.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'nonWordFirst.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'nonWordFirst.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSnonWordFirstL=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstL=sub',num2str(i),'RMSnonWordFirstL-mean(sub',num2str(i),'RMSnonWordFirstL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstR=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstR=sub',num2str(i),'RMSnonWordFirstR-mean(sub',num2str(i),'RMSnonWordFirstR(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordFirstF=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstF=sub',num2str(i),'RMSnonWordFirstF-mean(sub',num2str(i),'RMSnonWordFirstF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstB=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstB=sub',num2str(i),'RMSnonWordFirstB-mean(sub',num2str(i),'RMSnonWordFirstB(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordFirstLF=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstLF=sub',num2str(i),'RMSnonWordFirstLF-mean(sub',num2str(i),'RMSnonWordFirstLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstRF=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstRF=sub',num2str(i),'RMSnonWordFirstRF-mean(sub',num2str(i),'RMSnonWordFirstRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordFirstLB=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstLB=sub',num2str(i),'RMSnonWordFirstLB-mean(sub',num2str(i),'RMSnonWordFirstLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordFirstRB=sqrt(mean(sub',num2str(i),'nonWordFirst.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordFirstRB=sub',num2str(i),'RMSnonWordFirstRB-mean(sub',num2str(i),'RMSnonWordFirstRB(1,1:305));']);
    
    eval(['conRMSnonWordFirstL(a,:)=sub',num2str(i),'RMSnonWordFirstL;']);
    eval(['conRMSnonWordFirstR(a,:)=sub',num2str(i),'RMSnonWordFirstR;']);
    eval(['conRMSnonWordFirstF(a,:)=sub',num2str(i),'RMSnonWordFirstF;']);
    eval(['conRMSnonWordFirstB(a,:)=sub',num2str(i),'RMSnonWordFirstB;']);
    eval(['conRMSnonWordFirstLF(a,:)=sub',num2str(i),'RMSnonWordFirstLF;']);
    eval(['conRMSnonWordFirstRF(a,:)=sub',num2str(i),'RMSnonWordFirstRF;']);
    eval(['conRMSnonWordFirstLB(a,:)=sub',num2str(i),'RMSnonWordFirstLB;']);
    eval(['conRMSnonWordFirstRB(a,:)=sub',num2str(i),'RMSnonWordFirstRB;']);
    a=a+1;
end;
clear a i

%% RMS for non-word first
% comp1
nonWordFirstLBComp1=[mean(SZRMSnonWordFirstLB(:,[377 418]),2);mean(conRMSnonWordFirstLB(:,[377 418]),2)]; % 70-110 ms
nonWordFirstLFComp1=[mean(SZRMSnonWordFirstLF(:,[377 418]),2);mean(conRMSnonWordFirstLF(:,[377 418]),2)]; % 70-110 ms
nonWordFirstRBComp1=[mean(SZRMSnonWordFirstRB(:,[377 418]),2);mean(conRMSnonWordFirstRB(:,[377 418]),2)]; % 70-110 ms
nonWordFirstRFComp1=[mean(SZRMSnonWordFirstRF(:,[377 418]),2);mean(conRMSnonWordFirstRF(:,[377 418]),2)]; % 70-110 ms
% comp2
nonWordFirstLBComp2=[mean(SZRMSnonWordFirstLB(:,[428 499]),2);mean(conRMSnonWordFirstLB(:,[428 499]),2)]; % 120-190 ms
nonWordFirstLFComp2=[mean(SZRMSnonWordFirstLF(:,[428 499]),2);mean(conRMSnonWordFirstLF(:,[428 499]),2)]; % 120-190 ms
nonWordFirstRBComp2=[mean(SZRMSnonWordFirstRB(:,[428 499]),2);mean(conRMSnonWordFirstRB(:,[428 499]),2)]; % 120-190 ms
nonWordFirstRFComp2=[mean(SZRMSnonWordFirstRF(:,[428 499]),2);mean(conRMSnonWordFirstRF(:,[428 499]),2)]; % 120-190 ms
% comp3
nonWordFirstLBComp3=[mean(SZRMSnonWordFirstLB(:,[586 649]),2);mean(conRMSnonWordFirstLB(:,[548 611]),2)]; 
nonWordFirstLFComp3=[mean(SZRMSnonWordFirstLF(:,[586 649]),2);mean(conRMSnonWordFirstLF(:,[548 611]),2)]; 
nonWordFirstRBComp3=[mean(SZRMSnonWordFirstRB(:,[586 649]),2);mean(conRMSnonWordFirstRB(:,[548 611]),2)]; 
nonWordFirstRFComp3=[mean(SZRMSnonWordFirstRF(:,[586 649]),2);mean(conRMSnonWordFirstRF(:,[548 611]),2)]; 
% comp4
nonWordFirstLBComp4=[mean(SZRMSnonWordFirstLB(:,[650 701]),2);mean(conRMSnonWordFirstLB(:,[627 678]),2)];
nonWordFirstLFComp4=[mean(SZRMSnonWordFirstLF(:,[650 701]),2);mean(conRMSnonWordFirstLF(:,[627 678]),2)]; 
nonWordFirstRBComp4=[mean(SZRMSnonWordFirstRB(:,[650 701]),2);mean(conRMSnonWordFirstRB(:,[627 678]),2)]; 
nonWordFirstRFComp4=[mean(SZRMSnonWordFirstRF(:,[650 701]),2);mean(conRMSnonWordFirstRF(:,[627 678]),2)]; 
% comp5
nonWordFirstLBComp5=[mean(SZRMSnonWordFirstLB(:,[702 775]),2);mean(conRMSnonWordFirstLB(:,[699 772]),2)]; 
nonWordFirstLFComp5=[mean(SZRMSnonWordFirstLF(:,[702 775]),2);mean(conRMSnonWordFirstLF(:,[699 772]),2)];
nonWordFirstRBComp5=[mean(SZRMSnonWordFirstRB(:,[702 775]),2);mean(conRMSnonWordFirstRB(:,[699 772]),2)];
nonWordFirstRFComp5=[mean(SZRMSnonWordFirstRF(:,[702 775]),2);mean(conRMSnonWordFirstRF(:,[699 772]),2)];
% comp6
nonWordFirstLBComp6=[mean(SZRMSnonWordFirstLB(:,[953 1116]),2);mean(conRMSnonWordFirstLB(:,[916 1079]),2)];
nonWordFirstLFComp6=[mean(SZRMSnonWordFirstLF(:,[953 1116]),2);mean(conRMSnonWordFirstLF(:,[916 1079]),2)];
nonWordFirstRBComp6=[mean(SZRMSnonWordFirstRB(:,[953 1116]),2);mean(conRMSnonWordFirstRB(:,[916 1079]),2)];
nonWordFirstRFComp6=[mean(SZRMSnonWordFirstRF(:,[953 1116]),2);mean(conRMSnonWordFirstRF(:,[916 1079]),2)]; 

save RMS_nonWordFirst_LRBF nonWordFirstLBComp1 nonWordFirstLFComp1 nonWordFirstRBComp1 nonWordFirstRFComp1 ...
    nonWordFirstLBComp2 nonWordFirstLFComp2 nonWordFirstRBComp2 nonWordFirstRFComp2 ...
    nonWordFirstLBComp3 nonWordFirstLFComp3 nonWordFirstRBComp3 nonWordFirstRFComp3 ...
    nonWordFirstLBComp4 nonWordFirstLFComp4 nonWordFirstRBComp4 nonWordFirstRFComp4 ...
    nonWordFirstLBComp5 nonWordFirstLFComp5 nonWordFirstRBComp5 nonWordFirstRFComp5 ...
    nonWordFirstLBComp6 nonWordFirstLFComp6 nonWordFirstRBComp6 nonWordFirstRFComp6
clear all

%% LRFB for non-word second
clear all
load channs

SZ = [14, 16, 17, 19, 21, 23 24, 27:29, 31, 33:35, 37];

a = 1;
for i = SZ
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'nonWordSecond.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordSecond.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'nonWordSecond.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'nonWordSecond.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'nonWordSecond.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'nonWordSecond.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'nonWordSecond.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'nonWordSecond.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSnonWordSecondL=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondL=sub',num2str(i),'RMSnonWordSecondL-mean(sub',num2str(i),'RMSnonWordSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondR=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondR=sub',num2str(i),'RMSnonWordSecondR-mean(sub',num2str(i),'RMSnonWordSecondR(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSecondF=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondF=sub',num2str(i),'RMSnonWordSecondF-mean(sub',num2str(i),'RMSnonWordSecondF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondB=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondB=sub',num2str(i),'RMSnonWordSecondB-mean(sub',num2str(i),'RMSnonWordSecondB(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSecondLF=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondLF=sub',num2str(i),'RMSnonWordSecondLF-mean(sub',num2str(i),'RMSnonWordSecondLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondRF=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondRF=sub',num2str(i),'RMSnonWordSecondRF-mean(sub',num2str(i),'RMSnonWordSecondRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSecondLB=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondLB=sub',num2str(i),'RMSnonWordSecondLB-mean(sub',num2str(i),'RMSnonWordSecondLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondRB=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondRB=sub',num2str(i),'RMSnonWordSecondRB-mean(sub',num2str(i),'RMSnonWordSecondRB(1,1:305));']);
    
    eval(['SZRMSnonWordSecondL(a,:)=sub',num2str(i),'RMSnonWordSecondL;']);
    eval(['SZRMSnonWordSecondR(a,:)=sub',num2str(i),'RMSnonWordSecondR;']);
    eval(['SZRMSnonWordSecondF(a,:)=sub',num2str(i),'RMSnonWordSecondF;']);
    eval(['SZRMSnonWordSecondB(a,:)=sub',num2str(i),'RMSnonWordSecondB;']);
    eval(['SZRMSnonWordSecondLF(a,:)=sub',num2str(i),'RMSnonWordSecondLF;']);
    eval(['SZRMSnonWordSecondRF(a,:)=sub',num2str(i),'RMSnonWordSecondRF;']);
    eval(['SZRMSnonWordSecondLB(a,:)=sub',num2str(i),'RMSnonWordSecondLB;']);
    eval(['SZRMSnonWordSecondRB(a,:)=sub',num2str(i),'RMSnonWordSecondRB;']);
    a=a+1;
end;
clear a i

con = [0:3 5:9 12 15 20 32 36 39 41];

a = 1;
for i = con
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/1/averagedataERF']);
    
    eval(['chansL = ismember(sub',num2str(i),'nonWordSecond.label, Lchans);']);
    eval(['chansR = ismember(sub',num2str(i),'nonWordSecond.label, Rchans);']);
    eval(['chansF = ismember(sub',num2str(i),'nonWordSecond.label, Fchans);']);
    eval(['chansB = ismember(sub',num2str(i),'nonWordSecond.label, Bchans);']);
    eval(['chansLF = ismember(sub',num2str(i),'nonWordSecond.label, LFchans);']);
    eval(['chansRF = ismember(sub',num2str(i),'nonWordSecond.label, RFchans);']);  
    eval(['chansLB = ismember(sub',num2str(i),'nonWordSecond.label, LBchans);']);
    eval(['chansRB = ismember(sub',num2str(i),'nonWordSecond.label, RBchans);']);
    
    eval(['sub',num2str(i),'RMSnonWordSecondL=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansL,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondL=sub',num2str(i),'RMSnonWordSecondL-mean(sub',num2str(i),'RMSnonWordSecondL(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondR=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansR,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondR=sub',num2str(i),'RMSnonWordSecondR-mean(sub',num2str(i),'RMSnonWordSecondR(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSecondF=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondF=sub',num2str(i),'RMSnonWordSecondF-mean(sub',num2str(i),'RMSnonWordSecondF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondB=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondB=sub',num2str(i),'RMSnonWordSecondB-mean(sub',num2str(i),'RMSnonWordSecondB(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSecondLF=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansLF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondLF=sub',num2str(i),'RMSnonWordSecondLF-mean(sub',num2str(i),'RMSnonWordSecondLF(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondRF=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansRF,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondRF=sub',num2str(i),'RMSnonWordSecondRF-mean(sub',num2str(i),'RMSnonWordSecondRF(1,1:305));']);
    eval(['sub',num2str(i),'RMSnonWordSecondLB=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansLB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondLB=sub',num2str(i),'RMSnonWordSecondLB-mean(sub',num2str(i),'RMSnonWordSecondLB(1,1:305));']); 
    eval(['sub',num2str(i),'RMSnonWordSecondRB=sqrt(mean(sub',num2str(i),'nonWordSecond.avg(chansRB,:).^2));']);
    eval(['sub',num2str(i),'RMSnonWordSecondRB=sub',num2str(i),'RMSnonWordSecondRB-mean(sub',num2str(i),'RMSnonWordSecondRB(1,1:305));']);
    
    eval(['conRMSnonWordSecondL(a,:)=sub',num2str(i),'RMSnonWordSecondL;']);
    eval(['conRMSnonWordSecondR(a,:)=sub',num2str(i),'RMSnonWordSecondR;']);
    eval(['conRMSnonWordSecondF(a,:)=sub',num2str(i),'RMSnonWordSecondF;']);
    eval(['conRMSnonWordSecondB(a,:)=sub',num2str(i),'RMSnonWordSecondB;']);
    eval(['conRMSnonWordSecondLF(a,:)=sub',num2str(i),'RMSnonWordSecondLF;']);
    eval(['conRMSnonWordSecondRF(a,:)=sub',num2str(i),'RMSnonWordSecondRF;']);
    eval(['conRMSnonWordSecondLB(a,:)=sub',num2str(i),'RMSnonWordSecondLB;']);
    eval(['conRMSnonWordSecondRB(a,:)=sub',num2str(i),'RMSnonWordSecondRB;']);
    a=a+1;
end;
clear a i

%% RMS for non-word second
% comp1
nonWordSecondLBComp1=[mean(SZRMSnonWordSecondLB(:,[377 418]),2);mean(conRMSnonWordSecondLB(:,[377 418]),2)]; % 70-110 ms
nonWordSecondLFComp1=[mean(SZRMSnonWordSecondLF(:,[377 418]),2);mean(conRMSnonWordSecondLF(:,[377 418]),2)]; % 70-110 ms
nonWordSecondRBComp1=[mean(SZRMSnonWordSecondRB(:,[377 418]),2);mean(conRMSnonWordSecondRB(:,[377 418]),2)]; % 70-110 ms
nonWordSecondRFComp1=[mean(SZRMSnonWordSecondRF(:,[377 418]),2);mean(conRMSnonWordSecondRF(:,[377 418]),2)]; % 70-110 ms
% comp2
nonWordSecondLBComp2=[mean(SZRMSnonWordSecondLB(:,[428 499]),2);mean(conRMSnonWordSecondLB(:,[428 499]),2)]; % 120-190 ms
nonWordSecondLFComp2=[mean(SZRMSnonWordSecondLF(:,[428 499]),2);mean(conRMSnonWordSecondLF(:,[428 499]),2)]; % 120-190 ms
nonWordSecondRBComp2=[mean(SZRMSnonWordSecondRB(:,[428 499]),2);mean(conRMSnonWordSecondRB(:,[428 499]),2)]; % 120-190 ms
nonWordSecondRFComp2=[mean(SZRMSnonWordSecondRF(:,[428 499]),2);mean(conRMSnonWordSecondRF(:,[428 499]),2)]; % 120-190 ms
% comp3
nonWordSecondLBComp3=[mean(SZRMSnonWordSecondLB(:,[586 649]),2);mean(conRMSnonWordSecondLB(:,[548 611]),2)]; 
nonWordSecondLFComp3=[mean(SZRMSnonWordSecondLF(:,[586 649]),2);mean(conRMSnonWordSecondLF(:,[548 611]),2)]; 
nonWordSecondRBComp3=[mean(SZRMSnonWordSecondRB(:,[586 649]),2);mean(conRMSnonWordSecondRB(:,[548 611]),2)]; 
nonWordSecondRFComp3=[mean(SZRMSnonWordSecondRF(:,[586 649]),2);mean(conRMSnonWordSecondRF(:,[548 611]),2)]; 
% comp4
nonWordSecondLBComp4=[mean(SZRMSnonWordSecondLB(:,[650 701]),2);mean(conRMSnonWordSecondLB(:,[627 678]),2)];
nonWordSecondLFComp4=[mean(SZRMSnonWordSecondLF(:,[650 701]),2);mean(conRMSnonWordSecondLF(:,[627 678]),2)]; 
nonWordSecondRBComp4=[mean(SZRMSnonWordSecondRB(:,[650 701]),2);mean(conRMSnonWordSecondRB(:,[627 678]),2)]; 
nonWordSecondRFComp4=[mean(SZRMSnonWordSecondRF(:,[650 701]),2);mean(conRMSnonWordSecondRF(:,[627 678]),2)]; 
% comp5
nonWordSecondLBComp5=[mean(SZRMSnonWordSecondLB(:,[702 775]),2);mean(conRMSnonWordSecondLB(:,[699 772]),2)]; 
nonWordSecondLFComp5=[mean(SZRMSnonWordSecondLF(:,[702 775]),2);mean(conRMSnonWordSecondLF(:,[699 772]),2)];
nonWordSecondRBComp5=[mean(SZRMSnonWordSecondRB(:,[702 775]),2);mean(conRMSnonWordSecondRB(:,[699 772]),2)];
nonWordSecondRFComp5=[mean(SZRMSnonWordSecondRF(:,[702 775]),2);mean(conRMSnonWordSecondRF(:,[699 772]),2)];
% comp6
nonWordSecondLBComp6=[mean(SZRMSnonWordSecondLB(:,[953 1116]),2);mean(conRMSnonWordSecondLB(:,[916 1079]),2)];
nonWordSecondLFComp6=[mean(SZRMSnonWordSecondLF(:,[953 1116]),2);mean(conRMSnonWordSecondLF(:,[916 1079]),2)];
nonWordSecondRBComp6=[mean(SZRMSnonWordSecondRB(:,[953 1116]),2);mean(conRMSnonWordSecondRB(:,[916 1079]),2)];
nonWordSecondRFComp6=[mean(SZRMSnonWordSecondRF(:,[953 1116]),2);mean(conRMSnonWordSecondRF(:,[916 1079]),2)]; 

save RMS_nonWordSecond_LRBF nonWordSecondLBComp1 nonWordSecondLFComp1 nonWordSecondRBComp1 nonWordSecondRFComp1 ...
    nonWordSecondLBComp2 nonWordSecondLFComp2 nonWordSecondRBComp2 nonWordSecondRFComp2 ...
    nonWordSecondLBComp3 nonWordSecondLFComp3 nonWordSecondRBComp3 nonWordSecondRFComp3 ...
    nonWordSecondLBComp4 nonWordSecondLFComp4 nonWordSecondRBComp4 nonWordSecondRFComp4 ...
    nonWordSecondLBComp5 nonWordSecondLFComp5 nonWordSecondRBComp5 nonWordSecondRFComp5 ...
    nonWordSecondLBComp6 nonWordSecondLFComp6 nonWordSecondRBComp6 nonWordSecondRFComp6
clear all

%%
% plot
figure; 
subplot(2,1,1)
plot(time,mean(SZRMSwordFirstLF));
hold on;
plot(time,mean(SZRMSwordFirstRF),'r');
plot(time,mean(SZRMSwordFirstLB),'k');
plot(time,mean(SZRMSwordFirstRB),'g');
title('SZ RMS - word first');
legend('Left Front','Right Front','Left Back','Right Back');
subplot(2,1,2)
plot(time,mean(conRMSwordFirstLF));
hold on;
plot(time,mean(conRMSwordFirstRF),'r');
plot(time,mean(conRMSwordFirstLB),'k');
plot(time,mean(conRMSwordFirstRB),'g');
title('Con RMS - word first');
legend('Left Front','Right Front','Left Back','Right Back');

%% create table for SPSS
load RMS_nonWordSecond_LRBF
load RMS_wordSecond_LRBF
load RMS_nonWordSingle_LRBF
load RMS_wordSingle_LRBF
load RMS_nonWordFirst_LRBF
load RMS_wordFirst_LRBF

% Comp1
wordSingleComp1 = [wordSingleLFComp1, wordSingleRFComp1, wordSingleLBComp1, wordSingleRBComp1];
clear wordSingleLFComp1 wordSingleRFComp1 wordSingleLBComp1 wordSingleRBComp1
wordFirstComp1 = [wordFirstLFComp1, wordFirstRFComp1, wordFirstLBComp1, wordFirstRBComp1];
clear wordFirstLFComp1 wordFirstRFComp1 wordFirstLBComp1 wordFirstRBComp1
wordSecondComp1 = [wordSecondLFComp1, wordSecondRFComp1, wordSecondLBComp1, wordSecondRBComp1];
clear wordSecondLFComp1 wordSecondRFComp1 wordSecondLBComp1 wordSecondRBComp1
nonWordSingleComp1 = [nonWordSingleLFComp1, nonWordSingleRFComp1, nonWordSingleLBComp1, nonWordSingleRBComp1];
clear nonWordSingleLFComp1 nonWordSingleRFComp1 nonWordSingleLBComp1 nonWordSingleRBComp1
nonWordFirstComp1 = [nonWordFirstLFComp1, nonWordFirstRFComp1, nonWordFirstLBComp1, nonWordFirstRBComp1];
clear nonWordFirstLFComp1 nonWordFirstRFComp1 nonWordFirstLBComp1 nonWordFirstRBComp1
nonWordSecondComp1 = [nonWordSecondLFComp1, nonWordSecondRFComp1, nonWordSecondLBComp1, nonWordSecondRBComp1];
clear nonWordSecondLFComp1 nonWordSecondRFComp1 nonWordSecondLBComp1 nonWordSecondRBComp1
% Comp2
wordSingleComp2 = [wordSingleLFComp2, wordSingleRFComp2, wordSingleLBComp2, wordSingleRBComp2];
clear wordSingleLFComp2 wordSingleRFComp2 wordSingleLBComp2 wordSingleRBComp2
wordFirstComp2 = [wordFirstLFComp2, wordFirstRFComp2, wordFirstLBComp2, wordFirstRBComp2];
clear wordFirstLFComp2 wordFirstRFComp2 wordFirstLBComp2 wordFirstRBComp2
wordSecondComp2 = [wordSecondLFComp2, wordSecondRFComp2, wordSecondLBComp2, wordSecondRBComp2];
clear wordSecondLFComp2 wordSecondRFComp2 wordSecondLBComp2 wordSecondRBComp2
nonWordSingleComp2 = [nonWordSingleLFComp2, nonWordSingleRFComp2, nonWordSingleLBComp2, nonWordSingleRBComp2];
clear nonWordSingleLFComp2 nonWordSingleRFComp2 nonWordSingleLBComp2 nonWordSingleRBComp2
nonWordFirstComp2 = [nonWordFirstLFComp2, nonWordFirstRFComp2, nonWordFirstLBComp2, nonWordFirstRBComp2];
clear nonWordFirstLFComp2 nonWordFirstRFComp2 nonWordFirstLBComp2 nonWordFirstRBComp2
nonWordSecondComp2 = [nonWordSecondLFComp2, nonWordSecondRFComp2, nonWordSecondLBComp2, nonWordSecondRBComp2];
clear nonWordSecondLFComp2 nonWordSecondRFComp2 nonWordSecondLBComp2 nonWordSecondRBComp2
% Comp3
wordSingleComp3 = [wordSingleLFComp3, wordSingleRFComp3, wordSingleLBComp3, wordSingleRBComp3];
clear wordSingleLFComp3 wordSingleRFComp3 wordSingleLBComp3 wordSingleRBComp3
wordFirstComp3 = [wordFirstLFComp3, wordFirstRFComp3, wordFirstLBComp3, wordFirstRBComp3];
clear wordFirstLFComp3 wordFirstRFComp3 wordFirstLBComp3 wordFirstRBComp3
wordSecondComp3 = [wordSecondLFComp3, wordSecondRFComp3, wordSecondLBComp3, wordSecondRBComp3];
clear wordSecondLFComp3 wordSecondRFComp3 wordSecondLBComp3 wordSecondRBComp3
nonWordSingleComp3 = [nonWordSingleLFComp3, nonWordSingleRFComp3, nonWordSingleLBComp3, nonWordSingleRBComp3];
clear nonWordSingleLFComp3 nonWordSingleRFComp3 nonWordSingleLBComp3 nonWordSingleRBComp3
nonWordFirstComp3 = [nonWordFirstLFComp3, nonWordFirstRFComp3, nonWordFirstLBComp3, nonWordFirstRBComp3];
clear nonWordFirstLFComp3 nonWordFirstRFComp3 nonWordFirstLBComp3 nonWordFirstRBComp3
nonWordSecondComp3 = [nonWordSecondLFComp3, nonWordSecondRFComp3, nonWordSecondLBComp3, nonWordSecondRBComp3];
clear nonWordSecondLFComp3 nonWordSecondRFComp3 nonWordSecondLBComp3 nonWordSecondRBComp3
% Comp4
wordSingleComp4 = [wordSingleLFComp4, wordSingleRFComp4, wordSingleLBComp4, wordSingleRBComp4];
clear wordSingleLFComp4 wordSingleRFComp4 wordSingleLBComp4 wordSingleRBComp4
wordFirstComp4 = [wordFirstLFComp4, wordFirstRFComp4, wordFirstLBComp4, wordFirstRBComp4];
clear wordFirstLFComp4 wordFirstRFComp4 wordFirstLBComp4 wordFirstRBComp4
wordSecondComp4 = [wordSecondLFComp4, wordSecondRFComp4, wordSecondLBComp4, wordSecondRBComp4];
clear wordSecondLFComp4 wordSecondRFComp4 wordSecondLBComp4 wordSecondRBComp4
nonWordSingleComp4 = [nonWordSingleLFComp4, nonWordSingleRFComp4, nonWordSingleLBComp4, nonWordSingleRBComp4];
clear nonWordSingleLFComp4 nonWordSingleRFComp4 nonWordSingleLBComp4 nonWordSingleRBComp4
nonWordFirstComp4 = [nonWordFirstLFComp4, nonWordFirstRFComp4, nonWordFirstLBComp4, nonWordFirstRBComp4];
clear nonWordFirstLFComp4 nonWordFirstRFComp4 nonWordFirstLBComp4 nonWordFirstRBComp4
nonWordSecondComp4 = [nonWordSecondLFComp4, nonWordSecondRFComp4, nonWordSecondLBComp4, nonWordSecondRBComp4];
clear nonWordSecondLFComp4 nonWordSecondRFComp4 nonWordSecondLBComp4 nonWordSecondRBComp4
% Comp5
wordSingleComp5 = [wordSingleLFComp5, wordSingleRFComp5, wordSingleLBComp5, wordSingleRBComp5];
clear wordSingleLFComp5 wordSingleRFComp5 wordSingleLBComp5 wordSingleRBComp5
wordFirstComp5 = [wordFirstLFComp5, wordFirstRFComp5, wordFirstLBComp5, wordFirstRBComp5];
clear wordFirstLFComp5 wordFirstRFComp5 wordFirstLBComp5 wordFirstRBComp5
wordSecondComp5 = [wordSecondLFComp5, wordSecondRFComp5, wordSecondLBComp5, wordSecondRBComp5];
clear wordSecondLFComp5 wordSecondRFComp5 wordSecondLBComp5 wordSecondRBComp5
nonWordSingleComp5 = [nonWordSingleLFComp5, nonWordSingleRFComp5, nonWordSingleLBComp5, nonWordSingleRBComp5];
clear nonWordSingleLFComp5 nonWordSingleRFComp5 nonWordSingleLBComp5 nonWordSingleRBComp5
nonWordFirstComp5 = [nonWordFirstLFComp5, nonWordFirstRFComp5, nonWordFirstLBComp5, nonWordFirstRBComp5];
clear nonWordFirstLFComp5 nonWordFirstRFComp5 nonWordFirstLBComp5 nonWordFirstRBComp5
nonWordSecondComp5 = [nonWordSecondLFComp5, nonWordSecondRFComp5, nonWordSecondLBComp5, nonWordSecondRBComp5];
clear nonWordSecondLFComp5 nonWordSecondRFComp5 nonWordSecondLBComp5 nonWordSecondRBComp5
% Comp6
wordSingleComp6 = [wordSingleLFComp6, wordSingleRFComp6, wordSingleLBComp6, wordSingleRBComp6];
clear wordSingleLFComp6 wordSingleRFComp6 wordSingleLBComp6 wordSingleRBComp6
wordFirstComp6 = [wordFirstLFComp6, wordFirstRFComp6, wordFirstLBComp6, wordFirstRBComp6];
clear wordFirstLFComp6 wordFirstRFComp6 wordFirstLBComp6 wordFirstRBComp6
wordSecondComp6 = [wordSecondLFComp6, wordSecondRFComp6, wordSecondLBComp6, wordSecondRBComp6];
clear wordSecondLFComp6 wordSecondRFComp6 wordSecondLBComp6 wordSecondRBComp6
nonWordSingleComp6 = [nonWordSingleLFComp6, nonWordSingleRFComp6, nonWordSingleLBComp6, nonWordSingleRBComp6];
clear nonWordSingleLFComp6 nonWordSingleRFComp6 nonWordSingleLBComp6 nonWordSingleRBComp6
nonWordFirstComp6 = [nonWordFirstLFComp6, nonWordFirstRFComp6, nonWordFirstLBComp6, nonWordFirstRBComp6];
clear nonWordFirstLFComp6 nonWordFirstRFComp6 nonWordFirstLBComp6 nonWordFirstRBComp6
nonWordSecondComp6 = [nonWordSecondLFComp6, nonWordSecondRFComp6, nonWordSecondLBComp6, nonWordSecondRBComp6];
clear nonWordSecondLFComp6 nonWordSecondRFComp6 nonWordSecondLBComp6 nonWordSecondRBComp6

comp1 = [wordSingleComp1,wordFirstComp1,wordSecondComp1,nonWordSingleComp1,nonWordFirstComp1,nonWordSecondComp1];
clear wordSingleComp1 wordFirstComp1 wordSecondComp1 nonWordSingleComp1 nonWordFirstComp1 nonWordSecondComp1
comp2 = [wordSingleComp2,wordFirstComp2,wordSecondComp2,nonWordSingleComp2,nonWordFirstComp2,nonWordSecondComp2];
clear wordSingleComp2 wordFirstComp2 wordSecondComp2 nonWordSingleComp2 nonWordFirstComp2 nonWordSecondComp2
comp3 = [wordSingleComp3,wordFirstComp3,wordSecondComp3,nonWordSingleComp3,nonWordFirstComp3,nonWordSecondComp3];
clear wordSingleComp3 wordFirstComp3 wordSecondComp3 nonWordSingleComp3 nonWordFirstComp3 nonWordSecondComp3
comp4 = [wordSingleComp4,wordFirstComp4,wordSecondComp4,nonWordSingleComp4,nonWordFirstComp4,nonWordSecondComp4];
clear wordSingleComp4 wordFirstComp4 wordSecondComp4 nonWordSingleComp4 nonWordFirstComp4 nonWordSecondComp4
comp5 = [wordSingleComp5,wordFirstComp5,wordSecondComp5,nonWordSingleComp5,nonWordFirstComp5,nonWordSecondComp5];
clear wordSingleComp5 wordFirstComp5 wordSecondComp5 nonWordSingleComp5 nonWordFirstComp5 nonWordSecondComp5
comp6 = [wordSingleComp6,wordFirstComp6,wordSecondComp6,nonWordSingleComp6,nonWordFirstComp6,nonWordSecondComp6];
clear wordSingleComp6 wordFirstComp6 wordSecondComp6 nonWordSingleComp6 nonWordFirstComp6 nonWordSecondComp6

save RMS_wordEx_LRBF