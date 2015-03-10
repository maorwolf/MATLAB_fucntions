% for L vs. R: "load LRpairs"


% loading SZ data and creating RMS for all correct trials
clear all
load /home/meg/Data/Maor/Metaphors/Schizophrenics/avgSubs

for i=[2:7,9,12,13,15]
    eval(['sub',num2str(i),'RMS=sqrt(mean(sub',num2str(i),'avg.avg.^2));']);
    eval(['clear sub',num2str(i),'avg']); 
end;

% base line correction
for i=[2:7,9,12,13,15]
    eval(['SZ',num2str(i),'RMSBL=sub',num2str(i),'RMS-mean(sub',num2str(i),'RMS(1,1:204));']);
    eval(['clear sub',num2str(i),'RMS']); 
end;

% loading control data and creating RMS for all correct trials
clear all
load /home/meg/Data/Maor/Metaphors/controls/avgSubs

for i=[13:21,23,25,27:29]
    eval(['sub',num2str(i),'RMS=sqrt(mean(sub',num2str(i),'avg.avg.^2));']);
    eval(['clear sub',num2str(i),'avg']); 
end;

% base line correction
for i=[13:21,23,25,27:29]
    eval(['con',num2str(i),'RMSBL=sub',num2str(i),'RMS-mean(sub',num2str(i),'RMS(1,1:204));']);
    eval(['clear sub',num2str(i),'RMS']); 
end;

save /home/meg/Data/Maor/Metaphors/subsRMSBL

% group mean
SZRMSBL=zeros(10,1017);
a=1;
for i=[2:7,9,12,13,15]
    eval(['SZRMSBL(a,:)=SZ',num2str(i),'RMSBL;']);
    a=a+1;
end;
clear a

conRMSBL=zeros(14,1017);
b=1;
for i=[13:21,23,25,27:29]
    eval(['conRMSBL(b,:)=con',num2str(i),'RMSBL;']);
    b=b+1;
end;
clear b

SZRMSBLavg=mean(SZRMSBL);
conRMSBLavg=mean(conRMSBL);

save RMSBL SZRMSBL conRMSBL SZRMSBLavg conRMSBLavg

clear all
load RMSBL

% loading time series
load /home/meg/Data/Maor/Metaphors/Schizophrenics/002/sub2avconds sub2avcond10
time=sub2avcond10.time;
clear sub2avcond10

plot(time, SZRMSBLavg)
hold on;
plot(time, conRMSBLavg,'r')

% choosing randomly 10 out of 14 control subs
r=round(rand(14,1)*1000)+[.13; .14; .15; .16; .17; .18; .19; .20; .21; .23; .25; .27; .28; .29];
r=sort(r);
r(:,2)=r-round(r);
r(:,2)=r(:,2).*100;
con10randSubs=r(1:10,2);
con10randSubs=sort(con10randSubs);
con10randSubs=uint16(con10randSubs)';

% loading 10 control subs and creating RMSBL
load /home/meg/Data/Maor/Metaphors/controls/avgSubs

for i=con10randSubs
    eval(['sub',num2str(i),'RMS=sqrt(mean(sub',num2str(i),'avg.avg.^2));']);
    eval(['clear sub',num2str(i),'avg']); 
end;

% base line correction
for i=con10randSubs
    eval(['con',num2str(i),'RMSBL=sub',num2str(i),'RMS-mean(sub',num2str(i),'RMS(1,1:204));']);
    eval(['clear sub',num2str(i),'RMS']); 
end;

con10RMSBL=zeros(10,1017);
c=1;
for i=con10randSubs
    eval(['con10RMSBL(c,:)=con',num2str(i),'RMSBL;']);
    c=c+1;
end;
clear c

con10RMSBLavg=mean(con10RMSBL);

save RMS10con con10RMSBL con10RMSBLavg con10randSubs

clear all
load RMS10con
load RMSBL
load /home/meg/Data/Maor/Metaphors/Schizophrenics/002/sub2avconds sub2avcond10
time=sub2avcond10.time;
clear sub2avcond10

% ploting
figure;
plot(time, SZRMSBLavg)
hold on;
plot(time, conRMSBLavg,'r')
plot(time, con10RMSBLavg,'g')

