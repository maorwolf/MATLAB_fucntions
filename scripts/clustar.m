for i=[7:12,14,15,17:19,25:28];
    eval(['load /home/meg/Data/Maor/Hypnosis/Subjects/Hyp',num2str(i),'/1_40Hz/averagedata']);
end

cfg=[];
cfg.keepindividual = 'yes';
gravgCon102=ft_timelockgrandaverage(cfg, sub7con102, sub8con102, sub9con102, sub10con102, sub11con102,...
     sub12con102, sub14con102, sub15con102, sub17con102, sub18con102, sub19con102, sub25con102,...
      sub26con102, sub27con102, sub28con102);
gravgCon104=ft_timelockgrandaverage(cfg, sub7con104, sub8con104, sub9con104, sub10con104, sub11con104,...
     sub12con104, sub14con104, sub15con104, sub17con104, sub18con104, sub19con104, sub25con104,...
      sub26con104, sub27con104, sub28con104);
gravgCon106=ft_timelockgrandaverage(cfg, sub7con106, sub8con106, sub9con106, sub10con106, sub11con106,...
     sub12con106, sub14con106, sub15con106, sub17con106, sub18con106, sub19con106, sub25con106,...
      sub26con106, sub27con106, sub28con106);
gravgCon108=ft_timelockgrandaverage(cfg, sub7con108, sub8con108, sub9con108, sub10con108, sub11con108,...
     sub12con108, sub14con108, sub15con108, sub17con108, sub18con108, sub19con108, sub25con108,...
      sub26con108, sub27con108, sub28con108);

cd /home/meg/Data/Maor/Hypnosis/Subjects
save grAvgsKeepIndi gravgCon102 gravgCon104 gravgCon106 gravgCon108
clear
load grAvgsKeepIndi
% cfg.channel = 'all';
% cfg.latency = 'all';  
% cfg.frequency = 'all';
% cfg.roi = [];
% cfg.avgoverchan = 'no';
% cfg.avgovertime = 'no'; 
% cfg.avgoverfreq = 'no';
% cfg.avgoverroi = 'no';


%%
cfg=[];
cfg.method='distance';
cfg.neighbourdist = 0.04;
cfg.layout='4D248.lay';
neighbours = ft_prepare_neighbours(cfg, gravgCon102);

cfg = [];
cfg.channel = {'MEG'};
cfg.latency = [0.065 0.14];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesF';
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;

cfg.tail = 0;                    % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail = 0;
cfg.alpha = 0.05;               % alpha level of the permutation test
cfg.numrandomization = 500;
% 
r1=1:15;r1=[r1 r1 r1 r1];
r2=ones(1,15);r2=[r2 r2*2 r2*3 r2*4];

design=[squeeze(r1); squeeze(r2)];
cfg.clusterthreshold= 'nonparametric_common';
cfg.design = design;             % design matrix
cfg.ivar  = 2;        
cfg.uvar = 1;
cfg.neighbours=neighbours;
[stat] = ft_timelockstatistics(cfg, gravgCon102, gravgCon104, gravgCon106, gravgCon108);

save stat065_140 stat

% cluster plot
cfg=[];
cfg.parameter = 'stat';
cfg.alpha=0.05;
cfg.layout = '4D248.lay';
ft_clusterplot(cfg,stat)

% finding significant clusters
chans = [];
clusterChans = [];
clusters = [];
a= 1;
for i = 1:max(max(stat.posclusterslabelmat))
    [mn, mx, chans] = findcluster(i,stat, 'pos');
    if mx - mn > 0.02 && length(chans) > 3
        clusters(a,1) = i;
        clusters(a,2) = mx - mn;
        clusters(a,3) = mn;
        clusters(a,4) = mx;
        clusters(a,5) = length(chans);
        clusterChans{a} = chans;
        a = a + 1;
    end;
end;
for i = 1:max(max(stat.negclusterslabelmat))
    [mn, mx, chans] = findcluster(i,stat, 'neg');
    if mx - mn > 0.02 && length(chans) > 3
        clusters(a,1) = i;
        clusters(a,2) = mx - mn;
        clusters(a,3) = mn;
        clusters(a,4) = mx;
        clusters(a,5) = length(chans);
        clusterChans{a} = chans;
        a = a + 1;
    end;
end;

cfg = [];
for i = 1:size(clusters,1)
    subplot(3,3,i)
    cfg.xlim=[clusters(i,3) clusters(i,4)];
    cfg.highlight = 'on';
    cfg.highlightchannel = stat.label(clusterChans{i});
    cfg.layout = '4D248.lay';
    ft_topoplotER(cfg, gravg);
end;

for k = [102:2:108]
    for i = 1:size(clusters,1)
        for j = 1:17
            eval(['con',num2str(k),'cluster(j,i) = mean(gravg',num2str(k),'.individual(j,clusterChans{i},clusters(i,3):clusters(i,4)));']);
        end;
    end;
end;

save clusterAnalysis con102cluster con104cluster con106cluster con108cluster

