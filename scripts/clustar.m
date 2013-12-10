cfg=[];
cfg.keepindividual = 'yes';
gravgCon1=ft_timelockgrandaverage(cfg,sub1con1,sub2con1,ect);

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
neighbours = ft_prepare_neighbours(cfg, gravg);

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
r1=1:17;r1=[r1 r1 r1 r1];
r2=ones(1,17);r2=[r2 r2*2 r2*3 r2*4];

design=[squeeze(r1); squeeze(r2)];
cfg.clusterthreshold= 'nonparametric_common';
cfg.design = design;             % design matrix
cfg.ivar  = 2;        
cfg.uvar = 1;
cfg.neighbours=neighbours;
[stat] = ft_timelockstatistics(cfg, gravg102, gravg104, gravg106, gravg108);

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

