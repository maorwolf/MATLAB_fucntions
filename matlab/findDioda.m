function diff=findDioda(data,trigVec)
% The function calculats the difference between e-prime trigger and the diode.
% inputs: 1. data name (e.g., 'xc,hb,lf_c,rfhp0.1Hz')
%         2. vector of your triggers (e.g., [120 140 160 180])
% output: structure with many variables regarding the difference between
% the e-prime trigger and the diode
%
% Mar 9th
% Moranne & Maor
t = readTrig_BIU(data);
dif=[];
k=1;
a=1;
j=1;
while k < length(t)
    isInTrig=ismember(t(k),trigVec);
    if isInTrig
        dif(a,1)=k;
        dif(a,3)=t(k);
        j=k+1;
        while t(j)~=2048+t(k) % 2048 is the triger sent from the diode
            j=j+1;
        end
        dif(a,2)=j;
        a=a+1;
        k=j+1;
    else
        k=k+1;
    end
end    

dif(:,4)=dif(:,2)-dif(:,1);

diff.dif=dif;
diff.difMode=mode(dif(:,4));
diff.difMean=mean(dif(:,4));
diff.difMin=min(dif(:,4));
diff.difMax=max(dif(:,4));
diff.difRange=diff.difMax-diff.difMin;
diff.midRange=diff.difMin+(diff.difRange/2);
hist(dif(:,4));