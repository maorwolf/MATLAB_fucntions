clear all
subs = [7:12 14:19 21 25:28];

    samplingRate = 1017.25;
    tw = 200; % time window for fft (in samples)
    overlap = 190; % Samples for overlap
    tEnd = 662-tw; % data length (how many time-samples are in your fieldtrip data)
    tStart = 1:tw-overlap:tEnd; % vector defining index for the beginning of each time window
    offsetT = 0.150; % offset of the first sample from time 0 (in sec.)
    tMEG = (0:tw-overlap:tEnd)/samplingRate-offsetT; % time vector for MEG
    
for i=subs
    eval(sprintf('cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/SAM',i))
    load('/SAM/all4cov,1-40Hz,alla.mat')
    % noise estimation
    ns=ActWgts;
    ns=ns-repmat(mean(ns,2),1,size(ns,2));
    ns=ns.*ns;
    ns=mean(ns,2);
    
    % get toi mean square (different than SAMerf, no BL correction)
    cd ..
    cd 1_40Hz
    load averagedata
    % run over all time windows
    disp(['sub ',num2str(i)])
    cfg=[];
    cfg.step=5;
    cfg.boxSize=[-120 120 -90 90 -20 150];
    for j=1:length(tStart)
        vs102=[]; vs104=[]; vs106=[]; vs108=[];
        disp(['time window ',num2str(j)])
        eval(sprintf('vs102=ActWgts*sub%dcon102.avg(:,nearest(sub%dcon102.time,tMEG(%d)):nearest(sub%dcon102.time,tMEG(%d)+0.2));',i,i,j,i,j))
        vs102=mean(vs102.*vs102,2)./ns;
        vs102=vs102./max(vs102);
        vs102(isnan(vs102))=0;
        cfg.prefix=sprintf('cond102TW%d',j);
        VS2Brik(cfg,vs102);
        command = sprintf('@auto_tlrc -apar brain+tlrc -input %s+orig -dxyz 5', cfg.prefix);
        unix(command, '-echo');
        eval(sprintf('vs104=ActWgts*sub%dcon104.avg(:,nearest(sub%dcon104.time,tMEG(%d)):nearest(sub%dcon104.time,tMEG(%d)+0.2));',i,i,j,i,j))
        vs104=mean(vs104.*vs104,2)./ns;
        vs104=vs104./max(vs104);
        vs104(isnan(vs104))=0;
        cfg.prefix=sprintf('cond104TW%d',j);
        VS2Brik(cfg,vs104);
        command = sprintf('@auto_tlrc -apar brain+tlrc -input %s+orig -dxyz 5', cfg.prefix);
        unix(command, '-echo');
        eval(sprintf('vs106=ActWgts*sub%dcon106.avg(:,nearest(sub%dcon106.time,tMEG(%d)):nearest(sub%dcon106.time,tMEG(%d)+0.2));',i,i,j,i,j))
        vs106=mean(vs106.*vs106,2)./ns;
        vs106=vs106./max(vs106);
        vs106(isnan(vs106))=0;
        cfg.prefix=sprintf('cond106TW%d',j);
        VS2Brik(cfg,vs106);
        command = sprintf('@auto_tlrc -apar brain+tlrc -input %s+orig -dxyz 5', cfg.prefix);
        unix(command, '-echo');
        eval(sprintf('vs108=ActWgts*sub%dcon108.avg(:,nearest(sub%dcon108.time,tMEG(%d)):nearest(sub%dcon108.time,tMEG(%d)+0.2));',i,i,j,i,j))
        vs108=mean(vs108.*vs108,2)./ns;
        vs108=vs108./max(vs108);
        vs108(isnan(vs108))=0;
        cfg.prefix=sprintf('cond108TW%d',j);
        VS2Brik(cfg,vs108);
        command = sprintf('@auto_tlrc -apar brain+tlrc -input %s+orig -dxyz 5', cfg.prefix);
        unix(command, '-echo');
    end
end

cd /home/meg/Data/Maor/Hypnosis/Subjects

for tw=1:length(tStart)
    dirName=sprintf('evokedSAMresultsSlidingWindowRight');
    setA='-setA';
    setB='-setB';
    for subi= subs
        setA= [setA, ' ' ,sprintf('/home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/1_40Hz/cond102TW%d+tlrc',subi,tw)];
        setB= [setB, ' ' ,sprintf('/home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/1_40Hz/cond106TW%d+tlrc',subi,tw)];
    end
    command = ['3dttest++ -paired -no1sam -mask ~/SAM_BIU/docs/MASKbrain+tlrc -prefix ', dirName, '/realTTest', num2str(tw),' ',setA,' ',setB];
    [~, ~] = unix(command,'-echo');
    
    dirName=sprintf('evokedSAMresultsSlidingWindowLeft');
    setA='-setA';
    setB='-setB';
    for subi= subs
        setA= [setA, ' ' ,sprintf('/home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/1_40Hz/cond104TW%d+tlrc',subi,tw)];
        setB= [setB, ' ' ,sprintf('/home/meg/Data/Maor/Hypnosis/Subjects/Hyp%d/1_40Hz/cond108TW%d+tlrc',subi,tw)];
    end
    command = ['3dttest++ -paired -no1sam -mask ~/SAM_BIU/docs/MASKbrain+tlrc -prefix ', dirName, '/realTTest', num2str(tw),' ',setA,' ',setB];
    [~, ~] = unix(command,'-echo');
end
