clear all
for i=[2:7 9 12 13 15]
    eval(['cd /home/meg/Data/Maor/PhD_SAM/SZ/sub',num2str(i)]);
    eval(['load sub',num2str(i),'avconds']);
    for j=[10 20 30 40]
        eval(['SZsub',num2str(i),'comp2cond',num2str(j),' = mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,1:203),2)-mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,326:428),2);']);
        eval(['SZsub',num2str(i),'comp4cond',num2str(j),' = mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,1:203),2)-mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,510:631),2);']);
    end
end

for i=[13:21 23 25 27:29]
    eval(['cd /home/meg/Data/Maor/PhD_SAM/control/sub',num2str(i)]);
    eval(['load sub',num2str(i),'avconds']);
    for j=[10 20 30 40]
        eval(['CONsub',num2str(i),'comp2cond',num2str(j),' = mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,1:203),2)-mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,326:428),2);']);
        eval(['CONsub',num2str(i),'comp4cond',num2str(j),' = mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,1:203),2)-mean(sub',num2str(i),'avcond',num2str(j),'.avg(:,510:631),2);']);
    end
end

hdr=ft_read_header('hb,lf_c,rfhp1.0Hz')
neighbours=[];
cfg=[];
cfg.method='distance';
cfg.neighbourdist = 0.04;
cfg.grad=hdr.grad;
neighbours = ft_prepare_neighbours(cfg);

chan=zeros(96,4);
chan(:,2)=[ones(40,1);ones(56,1)*2];
chan(:,3)=repmat([1; 2; 3; 4],24,1);
a=1;
for i=1:4:96
    chan(i:i+3,4)=a;
    a=a+1;
end;

% real results comp2
for i=1:248
    chanT=[];
    for c=[10 20 30 40]
        for s=[2:7 9 12 13 15]
            eval(['chanT = [chanT;SZsub',num2str(s),'comp2cond',num2str(c),'(',num2str(i),')];']);
        end;
        for s=[13:21 23 25 27:29]
            eval(['chanT = [chanT;CONsub',num2str(s),'comp2cond',num2str(c),'(',num2str(i),')];']);   
        end;
    end;
    chan(:,1)=chanT;
    [~, ~, ~, ~, p]=mixed_between_within_anova(chan,1);
    chansGrp(i)=p{1};
    chansSem(i)=p{3};
    chansInt(i)=p{4};
    i
end;

find(chansGrp<0.05)
find(chansSem<0.05)
find(chansInt<0.05)

% cluster
label=sub12avcond10.label;
cluster=zeros(248:248);
for i=1:248
    for j=1:length(neighbours(i).neighblabel)
        idx=find(strcmp(label,neighbours(i).neighblabel(j)));
        cluster(i,idx) = 1;
    end
end
onoff = zeros(248,1,1);
onoff(find(chansGrp<0.05),1,1)=1;
[clusterGrp,NumGrp]=findclusters(onoff,cluster,4)
onoff = zeros(248,1,1);
onoff(find(chansSem<0.05),1,1)=1;
[clusterGrp,NumSem]=findclusters(onoff,cluster,4)
onoff = zeros(248,1,1);
onoff(find(chansInt<0.05),1,1)=1;
[clusterInt,NumInt]=findclusters(onoff,cluster,4)


%% real results comp4
chan=zeros(96,4);
chan(:,2)=[ones(40,1);ones(56,1)*2];
chan(:,3)=repmat([1; 2; 3; 4],24,1);
a=1;
for i=1:4:96
    chan(i:i+3,4)=a;
    a=a+1;
end;

for i=1:248
    chanT=[];
    for c=[10 20 30 40]
        for s=[2:7 9 12 13 15]
            eval(['chanT = [chanT;SZsub',num2str(s),'comp4cond',num2str(c),'(',num2str(i),')];']);
        end;
        for s=[13:21 23 25 27:29]
            eval(['chanT = [chanT;CONsub',num2str(s),'comp4cond',num2str(c),'(',num2str(i),')];']);   
        end;
    end;
    chan(:,1)=chanT;
    [~, ~, ~, ~, p]=mixed_between_within_anova(chan,1);
    chansGrp(i)=p{1};
    chansSem(i)=p{3};
    chansInt(i)=p{4};
    i
end;

find(chansGrp<0.05)
find(chansSem<0.05)
find(chansInt<0.05)

% cluster
label=sub12avcond10.label;
cluster=zeros(248:248);
for i=1:248
    for j=1:length(neighbours(i).neighblabel)
        idx=find(strcmp(label,neighbours(i).neighblabel(j)));
        cluster(i,idx) = 1;
    end
end
onoff = zeros(248,1,1);
onoff(find(chansGrp<0.05),1,1)=1;
[clusterGrp,NumGrp]=findclusters(onoff,cluster,4)

onoff = zeros(248,1,1);
onoff(find(chansSem<0.05),1,1)=1;
[clusterGrp,NumSem]=findclusters(onoff,cluster,4)

onoff = zeros(248,1,1);
onoff(find(chansInt<0.05),1,1)=1;
[clusterInt,NumInt]=findclusters(onoff,cluster,4)

% permutations

