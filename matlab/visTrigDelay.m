function visTriger=visTrigDelay(condition_vector,data)
% The function calculate the difference betwenn the E-prime triger and the
% visual triger. The input is a condition vector and the data after Abeles
% and Tal's function. The output is a structure with the following data:
% minimum difference
% maximum difference
% mean difference
% mode difference
% range difference
% standart diviation of the difference
trig = readTrig_BIU(data);
a = 1;
i = 1;
while i < length(trig)
    if ismember(trig(i),condition_vector)
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

visTriger.minDiff = min(diff(:,5));
visTriger.maxDiff = max(diff(:,5));
visTriger.meanDiff = mean(diff(:,5));
visTriger.modeDiff = mode(diff(:,5));
visTriger.rangeDiff = range(diff(:,5));
visTriger.sdDiff = std(diff(:,5));
