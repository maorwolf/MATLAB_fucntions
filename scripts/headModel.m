% read MRI
mri = ft_read_mri(template);
% realign
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = '4d';
mri_realigned = ft_volumerealign(cfg,mri);
% segment the template brain and construct a volume conduction model (i.e. head model)
cfg = [];
cfg.coordsys = '4d';
mri_seg = ft_volumesegment(cfg, mri_realigned); %NB is in mm
% create singleshell
cfg = [];
hdm = ft_prepare_singleshell(cfg, mri_seg); %NB transforms to cm!