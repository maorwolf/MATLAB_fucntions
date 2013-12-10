function datafinal=interpolateA41(data)
datafinalNew = data;
load /home/meg/Data/Maor/SchizoProject/Subjects/label
datafinalNew.label = label;
trial={};
for i = 1:length(datafinalNew.trial)
interpoA41 = mean(datafinalNew.trial{i}([1, 86, 87, 182],:));
trial{i} = datafinalNew.trial{i}(1:215,:);
trial{i}(216,:) = interpoA41;
trial{i}([217:248],:) = datafinalNew.trial{i}([216:247],:);
end;
datafinalNew.trial = trial;
datafinal = datafinalNew;