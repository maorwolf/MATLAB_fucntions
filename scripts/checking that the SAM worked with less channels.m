ActWgts247from248=ActWgts248(:,[1:215,217:248]);

r=corr(ActWgts247from248(20000:21000,:)',ActWgts247(20000:21000,:)');

imagesc(abs(r));
cd /home/meg/Data/Maor/Hypnosis/Subjects/Hyp7/1_40Hz
load averagedata
sub7average.avg=sub7average.avg([1:215,217:248],:);
sub7average.label=sub7average.label([1:215,217:248]);
data=sub7average;

plot(data.avg','b');
vsData247from248=ActWgts247from248*data.avg(:,mean(150:200));
vsData247=ActWgts247*data.avg(:,mean(150:200));

ns247=ActWgts247;
ns247=ns247-repmat(mean(ns247,2),1,size(ns247,2));
ns247=sqrt(ns247.*ns247);
ns247=mean(ns247,2);

ns247from248=ActWgts247from248;
ns247from248=ns247from248-repmat(mean(ns247from248,2),1,size(ns247from248,2));
ns247from248=sqrt(ns247from248.*ns247from248);
ns247from248=mean(ns247from248,2);

vsData247from248=abs(vsData247from248)./ns247from248;
vsData247=abs(vsData247)./ns247;

fg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
cfg.prefix='test247';
VS2Brik(cfg,vsData247);
cfg.prefix='test247from248';
VS2Brik(cfg,vsData247from248);
