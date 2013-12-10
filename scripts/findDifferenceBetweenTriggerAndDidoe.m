clear all
trig = readTrig_BIU('xc,hb,lf_c,rfhp0.1Hz');
a = 1;
i = 1;
while i < length(trig)
    if trig(i) == 222 || trig(i) == 230 || trig(i) == 240 || trig(i) == 250 %% change to your condition list
        cond = trig(i);
        diff(a,1) = trig(i);
        diff(a,2) = i;
        i = i + 1;
        while trig(i) == cond;
            i = i + 1;
        end;
        diff(a,3) = trig(i);
        diff(a,4) = i;
        i = i + 1;
        while trig(i) ~= 0
            i = i + 1;
        end;
        a = a + 1;
    end;
    i = i + 1;
end;

diff(:,5) = diff(:,4) - diff(:,2);

% for expression's experiment
% diff(1:2:length(diff),:)=[];

minDiff = min(diff(:,5));
maxDiff = max(diff(:,5));
meanDiff = mean(diff(:,5));
modeDiff = mode(diff(:,5));
rangeDiff = range(diff(:,5));
sdDiff = std(diff(:,5));


% column 1 - the condition trigger
% column 2 - the sample when the condition started
% column 3 - the trigger of the condition + diode
% column 4 - the sample when the diode started
% column 5 - the difference between column 4 and 2


% after ft_definetrial (without the visualtrigger lines): 
for i = 1:length(cfg.trl)
    cfg.trl(i,1) = cfg.trl(i,1) + 33;
    cfg.trl(i,2) = cfg.trl(i,2) + 33;
end

% for expression's experiment
for i = 1:length(cfg.trl)
    cfg.trl(i,1) = cfg.trl(i,1) + 48;
    cfg.trl(i,2) = cfg.trl(i,2) + 48;
end


