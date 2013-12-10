function datafinal=interpolateA163(data)
datafinalNew = data;
load /home/meg/Data/Maor/SchizoProject/Subjects/label
datafinalNew.label = label;
trial={};
for i = 1:length(datafinalNew.trial)
interpoA163 = mean(datafinalNew.trial{i}([103 172 203 204 235 237],:));
trial{i} = datafinalNew.trial{i}(1:136,:);
trial{i}(137,:) = interpoA163;
trial{i}([138:248],:) = datafinalNew.trial{i}([137:247],:);
end;
datafinalNew.trial = trial;
datafinal = datafinalNew;