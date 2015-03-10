%% 1. for each subject create a grid using:
% for con
con = 1:14;
for i=con
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    if exist('c,rfhp0.1Hz')
        [vol,grid,mesh,M1]=headmodel_BIU([],[],5,[],'localspheres');
    elseif exist('xc,hb,lf_c,rfhp0.1Hz')
        [vol,grid,mesh,M1]=headmodel_BIU('xc,hb,lf_c,rfhp0.1Hz',[],5,[],'localspheres');
    end
    save grid vol grid mesh M1
    clear all
    close all
end

fm = [1:7 9:20];
for i=fm
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    if exist('c,rfhp0.1Hz', 'file')
        [vol,grid,mesh,M1]=headmodel_BIU([],[],5,[],'localspheres');
    elseif exist('xc,hb,lf_c,rfhp0.1Hz', 'file')
        [vol,grid,mesh,M1]=headmodel_BIU('xc,hb,lf_c,rfhp0.1Hz',[],5,[],'localspheres');
    end
    save grid vol grid mesh M1
    clear all
    close all
end
%% 2. create grid for template MRI (T1) from feildtrip (do it once)
% here is a link:
% http://fieldtrip.fcdonders.nl/example/create_single-subject_grids_in_individual_head_space_that_are_all_aligned_in_mni_space?s[]=create&s[]=mni&s[]=aligned&s[]=grids

%% 3. intstance conditions (pain and no-pain)
for j=fm % j=con
    %eval(['cd /media/My_Passport/fibrodata/con/con',num2str(j)]);
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(j)]);
    load splitconds
    p = find(pain.trialinfo(1:length(pain.trialinfo)/2,1)==230 | pain.trialinfo(1:length(pain.trialinfo)/2,1)==250);
    pain.trialinfo = pain.trialinfo(p,:);
    pain.sampleinfo = pain.sampleinfo(p,:);
    np = find(noPain.trialinfo(1:length(noPain.trialinfo)/2,1)==222 | noPain.trialinfo(1:length(noPain.trialinfo)/2,1)==240);
    noPain.trialinfo = noPain.trialinfo(np,:);
    noPain.sampleinfo = noPain.sampleinfo(np,:);

    cfg=[];
        cfg.toilim = [0.1 0.5]; % for instance
        cfg.minlength = 'maxperlen';
        painData=ft_redefinetrial(cfg,pain);
        noPainData=ft_redefinetrial(cfg,noPain);
        cfg.toilim = [-0.3 0];
        painDataBL=ft_redefinetrial(cfg,pain);
        noPainDataBL=ft_redefinetrial(cfg,noPain);
        
        cfg = [];
        cfg.method ='mtmfft';
        cfg.output ='fourier';
        cfg.keeptrials = 'yes';
        cfg.keeptapers = 'yes';
        cfg.foilim = [10 11]; % 
        cfg.tapsmofrq = 3; % smoothing (depends on the time window. the smallest the better but may not let you do less than 2)
        freqPain=ft_freqanalysis(cfg,painData);
        freqNoPain=ft_freqanalysis(cfg,noPainData);
        freqPainBL=ft_freqanalysis(cfg,painDataBL);
        freqNoPainBL=ft_freqanalysis(cfg,noPainDataBL);

        %%% here you should load the individual grid: 
        load grid
        % concatenate the two 
        freq1 = freqPain;
        freq1.fourierspctrm = cat(1,freqPain.fourierspctrm,freqNoPain.fourierspctrm);
        freq1.cumtapcnt = cat(1,freqPain.cumtapcnt,freqNoPain.cumtapcnt);
        freq1.cumsumcnt = cat(1,freqPain.cumsumcnt,freqNoPain.cumsumcnt);
        freq1.trialinfo = cat(1,freqPain.trialinfo,freqNoPain.trialinfo);        
        Ntrlr_pos_pain = length(freqPain.cumtapcnt);
        Ntrlr_pos_noPain = length(freqNoPain.cumtapcnt);       
        
        freqBL = freqPainBL;
        freqBL.fourierspctrm = cat(1,freqPainBL.fourierspctrm,freqNoPainBL.fourierspctrm);
        freqBL.cumtapcnt = cat(1,freqPainBL.cumtapcnt,freqNoPainBL.cumtapcnt);
        freqBL.cumsumcnt = cat(1,freqPainBL.cumsumcnt,freqNoPainBL.cumsumcnt);
        freqBL.trialinfo = cat(1,freqPainBL.trialinfo,freqNoPainBL.trialinfo);        
        Ntrlr_pos_painBL = length(freqPainBL.cumtapcnt);
        Ntrlr_pos_noPainBL = length(freqNoPainBL.cumtapcnt);             
        
            grad        = ft_read_header('xc,hb,lf_c,rfhp0.1Hz');
            % grad = ft_read_header('xc,lf,hb_c,rfhp0.1Hz');
            % source analysis for all trials
            cfg            = [];
            cfg.method     = 'pcc';
            cfg.frequency  = 10; % where you expect the pick to be
            cfg.pcc.lambda = 0;  % have no idea what it is      
            cfg.vol        = vol;
            cfg.grid       = grid;
            cfg.pcc.feedback   = 'textbar';
            cfg.keeptrials = 'yes';
            cfg.grad       = ft_convert_units(grad.grad,'mm');
            source1        = ft_sourceanalysis(cfg, freq1);
            sourceBL       = ft_sourceanalysis(cfg, freqBL);
            
            load /media/My_Passport/fibrodata/template_grid_5

            source1.pos      = template_grid.pos;
            source1.dim      = template_grid.dim;
            source1.xgrid    = template_grid.xgrid;
            source1.ygrid    = template_grid.ygrid;
            source1.zgrid    = template_grid.zgrid;
            sourceBL.pos     = template_grid.pos;
            sourceBL.dim     = template_grid.dim;
            sourceBL.xgrid   = template_grid.xgrid;
            sourceBL.ygrid   = template_grid.ygrid;
            sourceBL.zgrid   = template_grid.zgrid;

            cfg             = [];
            cfg.keeptrials  = 'yes';
            cfg.projectmom  = 'yes';
            cfg.transform   = 'log';
            sd1             = ft_sourcedescriptives(cfg, source1); % gives power to each VS
            sdBL            = ft_sourcedescriptives(cfg, sourceBL);
            
            % signal change (from BL)
            for i=1:length(sd1.trial)
                sd1.trial(1,i).pow(:,:) = sd1.trial(1,i).pow(:,:) - sdBL.trial(1,i).pow(:,:);
            end
            
            st1 = 1:Ntrlr_pos_pain;
            st2 = (Ntrlr_pos_pain+1):(Ntrlr_pos_pain+Ntrlr_pos_noPain);
            sd_pos_pain = sd1;
            sd_pos_noPain = sd1;
            sd_pos_pain.trial = sd1.trial(st1);
            sd_pos_noPain.trial = sd1.trial(st2);
            sdc=sd_pos_pain;
            sdc.trial = [sd_pos_pain.trial sd_pos_noPain.trial];
            eval(['con',num2str(j),'ppcPow=sdc;']);
            eval(['save ppc con',num2str(j),'ppcPow']);
            % 1. within subject statistics
            cfg            = [];
            cfg.method = 'analytic';
            cfg.statistic = 'indepsamplesT';
            cfg.parameter = 'pow';
            cfg.ivar =1;
            cfg.design(2,1:length(st1)+length(st2)) = [1:length(st1) 1:length(st2)];
            cfg.design(1,1:length(st1)+length(st2)) = [ones(1,length(st1)) 2*ones(1,length(st2))];
            stat           = ft_sourcestatistics(cfg, sdc);
            
            save withinSubStat stat
            clear all
end            
%% source plot
% source interpolate
% source plot
load sMRI
load withinSubStat
cfg = [];
%cfg.downsample = 2;
cfg.parameter = 'stat';
sourceInterp = ft_sourceinterpolate(cfg, stat, sMRI);  %%% here you put the within subject or the group stat file

tCrit = stat.critval(1,2);
sigT = sourceInterp.stat;
sigT(find((sigT > -tCrit) & (sigT < tCrit))) = 0;
sigT(find(isnan(sigT))) = 0;
sourceInterp.sigT = sigT;

cfg = [];
cfg.method         = 'ortho'; % cfg.method = 'slice'; % cfg.method = 'surface';
cfg.funparameter   = 'sigT';
cfg.maskparameter  = cfg.funparameter;
cfg.funcolormap    = 'jet';
cfg.funcolorlim = 'maxabs';
%cfg.opacitylim     = [-2.5 2.5];
%cfg.opacitymap     = 'vdown';
cfg.projmethod     = 'nearest';
cfg.atlas          = 'TTatlas+tlrc.HEAD';
cfg.surfdownsample = 2;
cfg.interactive    = 'yes';
cfg.coordsys = 'mni';
figure
ft_sourceplot(cfg, sourceInterp);

%% 2. between subject statistics on the t-values from each sub
for i=1:14
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load withinSubStat
    eval(['statCon',num2str(i),'=stat']);
    clear stat
end

for i=[1:7 9:20]
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    load withinSubStat
    eval(['statFm',num2str(i),'=stat']);
    clear stat
end

cfg                  = [];
cfg.method           = 'montecarlo';
cfg.statistic        = 'indepsamplesT';
cfg.parameter        = 'stat';
cfg.channel          = 'all';
cfg.avgoverfreq      = 'yes';
cfg.latency          = 'all';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 1000;
cfg.ivar =1;
cfg.design(2,1:14) = 1:14;
cfg.design(2,15:(15+18)) = 1:19;
cfg.design(1,1:14) = [ones(1,14)];
cfg.design(1,15:(15+18)) = [ones(1,19)*2];
[stat]           = ft_sourcestatistics(cfg, statCon1, statCon2, statCon3, statCon4, statCon5, statCon6, statCon7, statCon8, statCon9,...
statCon10, statCon11, statCon12, statCon13, statCon14, statFm1, statFm2, statFm3, statFm4, statFm5, statFm6, statFm7, statFm9,...
statFm10, statFm11, statFm12, statFm13, statFm14, statFm15, statFm16, statFm17, statFm18, statFm19, statFm20);

%

load sMRI
cfg = [];
%cfg.downsample = 2;
cfg.parameter = 'stat';
sourceInterp = ft_sourceinterpolate(cfg, stat, sMRI);

cfg = [];
cfg.method         = 'ortho'; % cfg.method = 'slice'; % cfg.method = 'surface';
cfg.funparameter   = 'stat';
cfg.funcolormap    = 'jet';
cfg.funcolorlim = 'maxabs';
%cfg.opacitylim     = [-2.5 2.5];
%cfg.opacitymap     = 'vdown';
cfg.projmethod     = 'nearest';
cfg.atlas          = 'TTatlas+tlrc.HEAD';
cfg.surfdownsample = 2;
cfg.interactive    = 'yes';
cfg.coordsys = 'mni';
figure
ft_sourceplot(cfg, sourceInterp);

%% just control group (pain vs. no-pain)
for i=1:14
    eval(['cd /media/My_Passport/fibrodata/con/con',num2str(i)]);
    load withinSubStat
    eval(['statCon',num2str(i),'=stat;']);
    eval(['statCon',num2str(i),'_0=statCon',num2str(i),';']);
    eval(['statCon',num2str(i),'_0.stat(~isnan(statCon',num2str(i),'_0.stat))=0;']);
    clear stat
end

cfg                  = [];
cfg.method           = 'montecarlo';
cfg.statistic        = 'indepsamplesT';
cfg.parameter        = 'stat';
cfg.channel          = 'all';
cfg.avgoverfreq      = 'yes';
cfg.latency          = 'all';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 1000;
cfg.ivar =1;
cfg.design(2,1:14) = 1:14;
cfg.design(2,15:(15+13)) = 1:14;
cfg.design(1,1:14) = ones(1,14);
cfg.design(1,15:(15+13)) = ones(1,14)*2;
[stat] = ft_sourcestatistics(cfg, statCon1, statCon2, statCon3, statCon4, statCon5, statCon6, statCon7, statCon8, statCon9,...
statCon10, statCon11, statCon12, statCon13, statCon14,...
statCon1_0, statCon2_0, statCon3_0, statCon4_0, statCon5_0, statCon6_0, statCon7_0, statCon8_0, statCon9_0,...
statCon10_0, statCon11_0, statCon12_0, statCon13_0, statCon14_0);

%% pain vs. no-pain (across group)
for i=1:14
eval(['statCon',num2str(i),'_0=statCon',num2str(i),';']);
eval(['statCon',num2str(i),'_0.stat(~isnan(statCon',num2str(i),'_0.stat))=0;']);
end;
for i=[1:7 9:20]
eval(['statFm',num2str(i),'_0=statFm',num2str(i),';']);
eval(['statFm',num2str(i),'_0.stat(~isnan(statFm',num2str(i),'_0.stat))=0;']);
end;

cfg                  = [];
cfg.method           = 'montecarlo';
cfg.statistic        = 'indepsamplesT';
cfg.parameter        = 'stat';
cfg.channel          = 'all';
cfg.avgoverfreq      = 'yes';
cfg.latency          = 'all';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 1000;
cfg.ivar =1;
cfg.design(2,1:33) = 1:33;
cfg.design(2,34:(34+32)) = 1:33;
cfg.design(1,1:33) = ones(1,33);
cfg.design(1,34:(34+32)) = ones(1,33)*2;
[stat]           = ft_sourcestatistics(cfg, statCon1, statCon2, statCon3, statCon4, statCon5, statCon6, statCon7, statCon8, statCon9,...
statCon10, statCon11, statCon12, statCon13, statCon14, statFm1, statFm2, statFm3, statFm4, statFm5, statFm6, statFm7, statFm20,...
statFm9, statFm10, statFm11, statFm12, statFm13, statFm14, statFm15, statFm16, statFm17, statFm18, statFm19,...
statCon1_0, statCon2_0, statCon3_0, statCon4_0, statCon5_0, statCon6_0, statCon7_0, statCon8_0, statCon9,...
statCon10_0, statCon11_0, statCon12_0, statCon13_0, statCon14_0, statFm1_0, statFm2_0, statFm3_0, statFm4_0, statFm5_0, statFm6_0, statFm7_0, statFm20_0,...
statFm9_0, statFm10_0, statFm11_0, statFm12_0, statFm13_0, statFm14_0, statFm15_0, statFm16_0, statFm17_0, statFm18_0, statFm19_0);

%% looking at what is sig before permutation
stat.stat(stat.stat>(-1.96) & stat.stat<1.96 & ~isnan(stat.stat))=0;

load sMRI
cfg = [];
%cfg.downsample = 2;
cfg.parameter = 'stat';
sourceInterp = ft_sourceinterpolate(cfg, stat, sMRI);

cfg = [];
cfg.method         = 'ortho'; % cfg.method = 'slice'; % cfg.method = 'surface';
cfg.funparameter   = 'stat';
cfg.funcolormap    = 'jet';
cfg.funcolorlim = 'maxabs';
%cfg.opacitylim     = [-2.5 2.5];
%cfg.opacitymap     = 'vdown';
cfg.projmethod     = 'nearest';
cfg.atlas          = 'TTatlas+tlrc.HEAD';
cfg.surfdownsample = 2;
cfg.interactive    = 'yes';
cfg.coordsys = 'mni';
figure
ft_sourceplot(cfg, sourceInterp);

%% just fm group (pain vs. no-pain)
for i=[1:7 9:20]
    eval(['cd /media/My_Passport/fibrodata/fm/fm',num2str(i)]);
    load withinSubStat
    eval(['statFm',num2str(i),'=stat;']);
    eval(['statFm',num2str(i),'_0=statFm',num2str(i),';']);
    eval(['statFm',num2str(i),'_0.stat(~isnan(statFm',num2str(i),'_0.stat))=0;']);
    clear stat
end

cfg                  = [];
cfg.method           = 'montecarlo';
cfg.statistic        = 'indepsamplesT';
cfg.parameter        = 'stat';
cfg.channel          = 'all';
cfg.avgoverfreq      = 'yes';
cfg.latency          = 'all';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 1000;
cfg.ivar =1;
cfg.design(2,1:19) = 1:19;
cfg.design(2,20:(20+18)) = 1:19;
cfg.design(1,1:19) = ones(1,19);
cfg.design(1,20:(20+18)) = ones(1,19)*2;
[stat]           = ft_sourcestatistics(cfg, statFm1, statFm2, statFm3, statFm4, statFm5, statFm6, statFm7, statFm20,...
statFm9, statFm10, statFm11, statFm12, statFm13, statFm14, statFm15, statFm16, statFm17, statFm18, statFm19,...
statFm1_0, statFm2_0, statFm3_0, statFm4_0, statFm5_0, statFm6_0, statFm7_0, statFm20_0,...
statFm9_0, statFm10_0, statFm11_0, statFm12_0, statFm13_0, statFm14_0, statFm15_0, statFm16_0, statFm17_0, statFm18_0, statFm19_0);

%
stat.stat(stat.stat>(-1.96) & stat.stat<1.96 & ~isnan(stat.stat))=0;

load sMRI
cfg = [];
%cfg.downsample = 2;
cfg.parameter = 'stat';
sourceInterp = ft_sourceinterpolate(cfg, stat, sMRI);

cfg = [];
cfg.method         = 'ortho'; % cfg.method = 'slice'; % cfg.method = 'surface';
cfg.funparameter   = 'stat';
cfg.funcolormap    = 'jet';
cfg.funcolorlim = 'maxabs';
%cfg.opacitylim     = [-2.5 2.5];
%cfg.opacitymap     = 'vdown';
cfg.projmethod     = 'nearest';
cfg.atlas          = 'TTatlas+tlrc.HEAD';
cfg.surfdownsample = 2;
cfg.interactive    = 'yes';
cfg.coordsys = 'mni';
figure
ft_sourceplot(cfg, sourceInterp);