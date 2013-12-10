%% behavioral
control = [0:3, 5:9, 12, 15, 20, 32, 36, 39, 41];
for k = control
    cfg=[];
    subNum=k;
    eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(k),'/2']);
    conditions = [110 120 130 140 150 160];
    % 110 - meaningfull, no repeats
    % 120 - meaningless, no repeats
    % 130 - meaningfull, first apperance
    % 140 - meaningless, first apperance
    % 150 - meaningfull, second apperance
    % 160 - meaningless, second apperance
    % defining trials in all the data.
    cfg.dataset ='xc,hb,lf_c,rfhp0.1Hz';
    cfg.trialdef.eventtype  = 'TRIGGER';
    cfg.trialdef.eventvalue = conditions;
    cfg.trialdef.prestim    = 0.3;
    cfg.trialdef.poststim   = 0.8;
    cfg.trialdef.offset=-0.3;
    cfg.trialfun='BIUtrialfun';
    if k ~= 15
        cfg.trialdef.visualtrig = 'visafter';
        cfg.trialdef.visualtrigwin = 0.2;
        cfg = ft_definetrial(cfg);
    else
        cfg = ft_definetrial(cfg);
        cfg.trl(:,[1 2]) = cfg.trl(:,[1 2]) + 48;
    end;
    %--------------------------------------------------------------------------
    % creating colume 7 with correct code
    cfg.trl(1:length(cfg.trl),7) = 0;
    for i=1:length(cfg.trl)
        if ((cfg.trl(i,4)==110) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==120) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==130) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==140) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==150) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==160) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        end;
    end;
    % behavioral results
    behav = [];
    % column 1 - meaningfull, no repeats
    % column 2 - meaningless, no repeats
    % column 3 - meaningfull, first apperance
    % column 4 - meaningless, first apperance
    % column 5 - meaningfull, second apperance
    % column 6 - meaningless, second apperance
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 110 && cfg.trl(i,7) == 1)
            behav.meaningfullNoRepeat.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 110 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaningfullNoRepeat.ER = error;
    behav.meaningfullNoRepeat.sd = std(behav.meaningfullNoRepeat.RT);
    behav.meaningfullNoRepeat.mean = mean(behav.meaningfullNoRepeat.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 120 && cfg.trl(i,7) == 1)
            behav.meaninglessNoRepeat.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 120 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaninglessNoRepeat.ER = error;
    behav.meaninglessNoRepeat.sd = std(behav.meaninglessNoRepeat.RT);
    behav.meaninglessNoRepeat.mean = mean(behav.meaninglessNoRepeat.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 130 && cfg.trl(i,7) == 1)
            behav.meaningfullFirst.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 130 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaningfullFirst.ER = error;
    behav.meaningfullFirst.sd = std(behav.meaningfullFirst.RT);
    behav.meaningfullFirst.mean = mean(behav.meaningfullFirst.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 140 && cfg.trl(i,7) == 1)
            behav.meaninglessFirst.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 140 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaninglessFirst.ER = error;
    behav.meaninglessFirst.sd = std(behav.meaninglessFirst.RT);
    behav.meaninglessFirst.mean = mean(behav.meaninglessFirst.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 150 && cfg.trl(i,7) == 1)
            behav.meaningfullSecond.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 150 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaningfullSecond.ER = error;
    behav.meaningfullSecond.sd = std(behav.meaningfullSecond.RT);
    behav.meaningfullSecond.mean = mean(behav.meaningfullSecond.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 160 && cfg.trl(i,7) == 1)
            behav.meaninglessSecond.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 160 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaninglessSecond.ER = error;
    behav.meaninglessSecond.sd = std(behav.meaninglessSecond.RT);
    behav.meaninglessSecond.mean = mean(behav.meaninglessSecond.RT);
    
    % looking for outliars
    for i = 1:length(behav.meaningfullNoRepeat.RT)
        behav.meaningfullNoRepeat.RT(i,2) = abs((behav.meaningfullNoRepeat.RT(i,1) - behav.meaningfullNoRepeat.mean) / behav.meaningfullNoRepeat.sd);
    end;
    behav.meaningfullNoRepeat.RTclean = behav.meaningfullNoRepeat.RT(behav.meaningfullNoRepeat.RT(:,2) < 2.5, 1);
    behav.meaningfullNoRepeat.SDclean = std(behav.meaningfullNoRepeat.RTclean);
    behav.meaningfullNoRepeat.MEANclean = mean(behav.meaningfullNoRepeat.RTclean);
    
    for i = 1:length(behav.meaninglessNoRepeat.RT)
        behav.meaninglessNoRepeat.RT(i,2) = abs((behav.meaninglessNoRepeat.RT(i,1) - behav.meaninglessNoRepeat.mean) / behav.meaninglessNoRepeat.sd);
    end;
    behav.meaninglessNoRepeat.RTclean = behav.meaninglessNoRepeat.RT(behav.meaninglessNoRepeat.RT(:,2) < 2.5, 1);
    behav.meaninglessNoRepeat.SDclean = std(behav.meaninglessNoRepeat.RTclean);
    behav.meaninglessNoRepeat.MEANclean = mean(behav.meaninglessNoRepeat.RTclean);
    
    for i = 1:length(behav.meaningfullFirst.RT)
        behav.meaningfullFirst.RT(i,2) = abs((behav.meaningfullFirst.RT(i,1) - behav.meaningfullFirst.mean) / behav.meaningfullFirst.sd);
    end;
    behav.meaningfullFirst.RTclean = behav.meaningfullFirst.RT(behav.meaningfullFirst.RT(:,2) < 2.5, 1);
    behav.meaningfullFirst.SDclean = std(behav.meaningfullFirst.RTclean);
    behav.meaningfullFirst.MEANclean = mean(behav.meaningfullFirst.RTclean);
    
    for i = 1:length(behav.meaninglessFirst.RT)
        behav.meaninglessFirst.RT(i,2) = abs((behav.meaninglessFirst.RT(i,1) - behav.meaninglessFirst.mean) / behav.meaninglessFirst.sd);
    end;
    behav.meaninglessFirst.RTclean = behav.meaninglessFirst.RT(behav.meaninglessFirst.RT(:,2) < 2.5, 1);
    behav.meaninglessFirst.SDclean = std(behav.meaninglessFirst.RTclean);
    behav.meaninglessFirst.MEANclean = mean(behav.meaninglessFirst.RTclean);
    
    for i = 1:length(behav.meaningfullSecond.RT)
        behav.meaningfullSecond.RT(i,2) = abs((behav.meaningfullSecond.RT(i,1) - behav.meaningfullSecond.mean) / behav.meaningfullSecond.sd);
    end;
    behav.meaningfullSecond.RTclean = behav.meaningfullSecond.RT(behav.meaningfullSecond.RT(:,2) < 2.5, 1);
    behav.meaningfullSecond.SDclean = std(behav.meaningfullSecond.RTclean);
    behav.meaningfullSecond.MEANclean = mean(behav.meaningfullSecond.RTclean);
    
    for i = 1:length(behav.meaninglessSecond.RT)
        behav.meaninglessSecond.RT(i,2) = abs((behav.meaninglessSecond.RT(i,1) - behav.meaninglessSecond.mean) / behav.meaninglessSecond.sd);
    end;
    behav.meaninglessSecond.RTclean = behav.meaninglessSecond.RT(behav.meaninglessSecond.RT(:,2) < 2.5, 1);
    behav.meaninglessSecond.SDclean = std(behav.meaninglessSecond.RTclean);
    behav.meaninglessSecond.MEANclean = mean(behav.meaninglessSecond.RTclean);
    
    NmeaningfullNoRepeat=length(find(cfg.trl==110));
    NmeaninglessNoRepeat=length(find(cfg.trl==120));
    NmeaningfullFirst=length(find(cfg.trl==130));
    NmeaninglessFirst=length(find(cfg.trl==140));
    NmeaningfullSecond=length(find(cfg.trl==150));
    NmeaninglessSecond=length(find(cfg.trl==160));
    
    behav.meaningfullNoRepeat.ER=(behav.meaningfullNoRepeat.ER/NmeaningfullNoRepeat)*100;
    behav.meaninglessNoRepeat.ER=(behav.meaninglessNoRepeat.ER/NmeaninglessNoRepeat)*100;
    behav.meaningfullFirst.ER=(behav.meaningfullFirst.ER/NmeaningfullFirst)*100;
    behav.meaninglessFirst.ER=(behav.meaninglessFirst.ER/NmeaninglessFirst)*100;
    behav.meaningfullSecond.ER=(behav.meaningfullSecond.ER/NmeaningfullSecond)*100;
    behav.meaninglessSecond.ER=(behav.meaninglessSecond.ER/NmeaninglessSecond)*100;
    
    eval(['behav',num2str(subNum),' = behav;'])
    eval(['save behav behav',num2str(subNum)])
end;

%%
SZ = [14, 16, 17, 19, 21, 23:25, 27:29, 31, 33:35, 37];
for k = SZ
    cfg=[];
    subNum=k;
    if k == 19 || k == 21
        eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(k),'/4']);
    else
        eval(['cd /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(k),'/2']);
    end;
    conditions = [110 120 130 140 150 160];
    % 110 - meaningfull, no repeats
    % 120 - meaningless, no repeats
    % 130 - meaningfull, first apperance
    % 140 - meaningless, first apperance
    % 150 - meaningfull, second apperance
    % 160 - meaningless, second apperance
    % defining trials in all the data.
    if k == 23
        cfg.dataset ='fix_xc,hb,lf_c,rfhp0.1Hz';
    elseif k == 29
        cfg.dataset ='hb,lf_c,rfhp0.1Hz';
    else
        cfg.dataset ='xc,hb,lf_c,rfhp0.1Hz';
    end;
    cfg.trialdef.eventtype  = 'TRIGGER';
    cfg.trialdef.eventvalue = conditions;
    cfg.trialdef.prestim    = 0.3;
    cfg.trialdef.poststim   = 0.8;
    cfg.trialdef.offset=-0.3;
    cfg.trialfun='BIUtrialfun';
    if k ~= 24 && k ~= 25
        cfg.trialdef.visualtrig = 'visafter';
        cfg.trialdef.visualtrigwin = 0.2;
        cfg = ft_definetrial(cfg);
    else
        cfg = ft_definetrial(cfg);
        cfg.trl(:,[1 2]) = cfg.trl(:,[1 2]) + 48;
    end;
    %--------------------------------------------------------------------------
    % creating colume 7 with correct code
    cfg.trl(1:length(cfg.trl),7) = 0;
    for i=1:length(cfg.trl)
        if ((cfg.trl(i,4)==110) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==120) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==130) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==140) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==150) && (cfg.trl(i,6)==256))
            cfg.trl(i,7)=1;
        elseif ((cfg.trl(i,4)==160) && (cfg.trl(i,6)==512))
            cfg.trl(i,7)=1;
        end;
    end;
    % behavioral results
    behav = [];
    % column 1 - meaningfull, no repeats
    % column 2 - meaningless, no repeats
    % column 3 - meaningfull, first apperance
    % column 4 - meaningless, first apperance
    % column 5 - meaningfull, second apperance
    % column 6 - meaningless, second apperance
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 110 && cfg.trl(i,7) == 1)
            behav.meaningfullNoRepeat.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 110 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaningfullNoRepeat.ER = error;
    behav.meaningfullNoRepeat.sd = std(behav.meaningfullNoRepeat.RT);
    behav.meaningfullNoRepeat.mean = mean(behav.meaningfullNoRepeat.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 120 && cfg.trl(i,7) == 1)
            behav.meaninglessNoRepeat.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 120 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaninglessNoRepeat.ER = error;
    behav.meaninglessNoRepeat.sd = std(behav.meaninglessNoRepeat.RT);
    behav.meaninglessNoRepeat.mean = mean(behav.meaninglessNoRepeat.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 130 && cfg.trl(i,7) == 1)
            behav.meaningfullFirst.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 130 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaningfullFirst.ER = error;
    behav.meaningfullFirst.sd = std(behav.meaningfullFirst.RT);
    behav.meaningfullFirst.mean = mean(behav.meaningfullFirst.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 140 && cfg.trl(i,7) == 1)
            behav.meaninglessFirst.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 140 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaninglessFirst.ER = error;
    behav.meaninglessFirst.sd = std(behav.meaninglessFirst.RT);
    behav.meaninglessFirst.mean = mean(behav.meaninglessFirst.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 150 && cfg.trl(i,7) == 1)
            behav.meaningfullSecond.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 150 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaningfullSecond.ER = error;
    behav.meaningfullSecond.sd = std(behav.meaningfullSecond.RT);
    behav.meaningfullSecond.mean = mean(behav.meaningfullSecond.RT);
    
    line = 1;
    error= 0;
    for i = 1:length(cfg.trl)
        if (cfg.trl(i,4) == 160 && cfg.trl(i,7) == 1)
            behav.meaninglessSecond.RT(line,1) = cfg.trl(i,5) - (cfg.trl(i,1) + 305);
            line = line + 1;
        elseif (cfg.trl(i,4) == 160 && cfg.trl(i,7) == 0)
            error = error + 1;
        end;
    end;
    behav.meaninglessSecond.ER = error;
    behav.meaninglessSecond.sd = std(behav.meaninglessSecond.RT);
    behav.meaninglessSecond.mean = mean(behav.meaninglessSecond.RT);
    
    % looking for outliars
    for i = 1:length(behav.meaningfullNoRepeat.RT)
        behav.meaningfullNoRepeat.RT(i,2) = abs((behav.meaningfullNoRepeat.RT(i,1) - behav.meaningfullNoRepeat.mean) / behav.meaningfullNoRepeat.sd);
    end;
    behav.meaningfullNoRepeat.RTclean = behav.meaningfullNoRepeat.RT(behav.meaningfullNoRepeat.RT(:,2) < 2.5, 1);
    behav.meaningfullNoRepeat.SDclean = std(behav.meaningfullNoRepeat.RTclean);
    behav.meaningfullNoRepeat.MEANclean = mean(behav.meaningfullNoRepeat.RTclean);
    
    for i = 1:length(behav.meaninglessNoRepeat.RT)
        behav.meaninglessNoRepeat.RT(i,2) = abs((behav.meaninglessNoRepeat.RT(i,1) - behav.meaninglessNoRepeat.mean) / behav.meaninglessNoRepeat.sd);
    end;
    behav.meaninglessNoRepeat.RTclean = behav.meaninglessNoRepeat.RT(behav.meaninglessNoRepeat.RT(:,2) < 2.5, 1);
    behav.meaninglessNoRepeat.SDclean = std(behav.meaninglessNoRepeat.RTclean);
    behav.meaninglessNoRepeat.MEANclean = mean(behav.meaninglessNoRepeat.RTclean);
    
    for i = 1:length(behav.meaningfullFirst.RT)
        behav.meaningfullFirst.RT(i,2) = abs((behav.meaningfullFirst.RT(i,1) - behav.meaningfullFirst.mean) / behav.meaningfullFirst.sd);
    end;
    behav.meaningfullFirst.RTclean = behav.meaningfullFirst.RT(behav.meaningfullFirst.RT(:,2) < 2.5, 1);
    behav.meaningfullFirst.SDclean = std(behav.meaningfullFirst.RTclean);
    behav.meaningfullFirst.MEANclean = mean(behav.meaningfullFirst.RTclean);
    
    for i = 1:length(behav.meaninglessFirst.RT)
        behav.meaninglessFirst.RT(i,2) = abs((behav.meaninglessFirst.RT(i,1) - behav.meaninglessFirst.mean) / behav.meaninglessFirst.sd);
    end;
    behav.meaninglessFirst.RTclean = behav.meaninglessFirst.RT(behav.meaninglessFirst.RT(:,2) < 2.5, 1);
    behav.meaninglessFirst.SDclean = std(behav.meaninglessFirst.RTclean);
    behav.meaninglessFirst.MEANclean = mean(behav.meaninglessFirst.RTclean);
    
    for i = 1:length(behav.meaningfullSecond.RT)
        behav.meaningfullSecond.RT(i,2) = abs((behav.meaningfullSecond.RT(i,1) - behav.meaningfullSecond.mean) / behav.meaningfullSecond.sd);
    end;
    behav.meaningfullSecond.RTclean = behav.meaningfullSecond.RT(behav.meaningfullSecond.RT(:,2) < 2.5, 1);
    behav.meaningfullSecond.SDclean = std(behav.meaningfullSecond.RTclean);
    behav.meaningfullSecond.MEANclean = mean(behav.meaningfullSecond.RTclean);
    
    for i = 1:length(behav.meaninglessSecond.RT)
        behav.meaninglessSecond.RT(i,2) = abs((behav.meaninglessSecond.RT(i,1) - behav.meaninglessSecond.mean) / behav.meaninglessSecond.sd);
    end;
    behav.meaninglessSecond.RTclean = behav.meaninglessSecond.RT(behav.meaninglessSecond.RT(:,2) < 2.5, 1);
    behav.meaninglessSecond.SDclean = std(behav.meaninglessSecond.RTclean);
    behav.meaninglessSecond.MEANclean = mean(behav.meaninglessSecond.RTclean);
    
    NmeaningfullNoRepeat=length(find(cfg.trl==110));
    NmeaninglessNoRepeat=length(find(cfg.trl==120));
    NmeaningfullFirst=length(find(cfg.trl==130));
    NmeaninglessFirst=length(find(cfg.trl==140));
    NmeaningfullSecond=length(find(cfg.trl==150));
    NmeaninglessSecond=length(find(cfg.trl==160));
    
    behav.meaningfullNoRepeat.ER=(behav.meaningfullNoRepeat.ER/NmeaningfullNoRepeat)*100;
    behav.meaninglessNoRepeat.ER=(behav.meaninglessNoRepeat.ER/NmeaninglessNoRepeat)*100;
    behav.meaningfullFirst.ER=(behav.meaningfullFirst.ER/NmeaningfullFirst)*100;
    behav.meaninglessFirst.ER=(behav.meaninglessFirst.ER/NmeaninglessFirst)*100;
    behav.meaningfullSecond.ER=(behav.meaningfullSecond.ER/NmeaningfullSecond)*100;
    behav.meaninglessSecond.ER=(behav.meaninglessSecond.ER/NmeaninglessSecond)*100;
    
    eval(['behav',num2str(subNum),' = behav;'])
    eval(['save behav behav',num2str(subNum)])
end;

%% load and save all subs
clear all;
% good subs (according to erf)
control = [0:3, 5:9, 12, 15, 20, 32, 36, 39, 41];
SZ = [14, 16, 17, 19, 21, 23:25, 27:29, 31, 33:35, 37];

a=1;
for i = control
    eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(i),'/2/behav']);
    eval(['ERcontrol(a,1)=behav',num2str(i),'.meaningfullNoRepeat.ER;']);
    eval(['RTcontrol(a,1)=behav',num2str(i),'.meaningfullNoRepeat.MEANclean;']);
    eval(['ERcontrol(a,2)=behav',num2str(i),'.meaninglessNoRepeat.ER;']);
    eval(['RTcontrol(a,2)=behav',num2str(i),'.meaninglessNoRepeat.MEANclean;']);
    eval(['ERcontrol(a,3)=behav',num2str(i),'.meaningfullFirst.ER;']);
    eval(['RTcontrol(a,3)=behav',num2str(i),'.meaningfullFirst.MEANclean;']);
    eval(['ERcontrol(a,4)=behav',num2str(i),'.meaninglessFirst.ER;']);
    eval(['RTcontrol(a,4)=behav',num2str(i),'.meaninglessFirst.MEANclean;']);
    eval(['ERcontrol(a,5)=behav',num2str(i),'.meaningfullSecond.ER;']);
    eval(['RTcontrol(a,5)=behav',num2str(i),'.meaningfullSecond.MEANclean;']);
    eval(['ERcontrol(a,6)=behav',num2str(i),'.meaninglessSecond.ER;']);
    eval(['RTcontrol(a,6)=behav',num2str(i),'.meaninglessSecond.MEANclean;']);
    a=a+1;
end;

b=1;
for j = SZ
    if j == 19 || j == 21
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(j),'/4/behav']);
    else
        eval(['load /home/meg/Data/Maor/SchizoProject/Subjects/AviMa',num2str(j),'/2/behav']);
    end;
    eval(['ERSZ(b,1)=behav',num2str(j),'.meaningfullNoRepeat.ER;']);
    eval(['RTSZ(b,1)=behav',num2str(j),'.meaningfullNoRepeat.MEANclean;']);
    eval(['ERSZ(b,2)=behav',num2str(j),'.meaninglessNoRepeat.ER;']);
    eval(['RTSZ(b,2)=behav',num2str(j),'.meaninglessNoRepeat.MEANclean;']);
    eval(['ERSZ(b,3)=behav',num2str(j),'.meaningfullFirst.ER;']);
    eval(['RTSZ(b,3)=behav',num2str(j),'.meaningfullFirst.MEANclean;']);
    eval(['ERSZ(b,4)=behav',num2str(j),'.meaninglessFirst.ER;']);
    eval(['RTSZ(b,4)=behav',num2str(j),'.meaninglessFirst.MEANclean;']);
    eval(['ERSZ(b,5)=behav',num2str(j),'.meaningfullSecond.ER;']);
    eval(['RTSZ(b,5)=behav',num2str(j),'.meaningfullSecond.MEANclean;']);
    eval(['ERSZ(b,6)=behav',num2str(j),'.meaninglessSecond.ER;']);
    eval(['RTSZ(b,6)=behav',num2str(j),'.meaninglessSecond.MEANclean;']);
    b=b+1;
end;

ERmean(1,1:6) = mean(ERSZ,1);
ERmean(2,1:6) = mean(ERcontrol,1);
RTmean(1,1:6) = mean(RTSZ,1);
RTmean(2,1:6) = mean(RTcontrol,1);
ER_SZ_sd=std(ERSZ);
ER_con_sd=std(ERcontrol);
RT_SZ_sd=std(RTSZ);
RT_con_sd=std(RTcontrol);
ERsd=[ER_SZ_sd; ER_con_sd];
RTsd=[RT_SZ_sd; RT_con_sd];
% column 1 - meaningfull No Repeat
% column 2 - meaningless No Repeat
% column 3 - meaningfull First
% column 4 - meaningless First
% column 5 - meaningfull Second
% column 6 - meaningless Second
cd /home/meg/Data/Maor/SchizoProject/expressions
save behavExpressions ERcontrol RTcontrol ERSZ RTSZ ER_SZ_sd ER_con_sd ERmean ERsd RT_SZ_sd RT_con_sd RTmean RTsd
clear all
load behavExpressions
%% plotting
figure;

subplot(2,1,1)
h1 = barwitherr(ERsd'./4, ERmean');% Plot with errorbars
title('Errors');
ylabel('Number of Errors');
ylim([0 20]);
set(h1(1), 'facecolor', [0 0.7 0.6]);
set(h1(2), 'facecolor', [0 0.2 0.5]);
set(gca, 'XTickLabel', {'Meanfull 0';'Meanless 0';'Meanfull 1';'Meanless 1';'Meanfull 2';'Meanless 2'});
legend('Schizophrenia','Control');

subplot(2,1,2)
h2 = barwitherr(RTsd'./4, RTmean');% Plot with errorbars
title('Reaction Times');
ylabel('ms');
ylim([0 1200]);
set(h2(1), 'facecolor', [0 0.7 0.6]);
set(h2(2), 'facecolor', [0 0.2 0.5]);
set(gca, 'XTickLabel', {'Meanfull 0';'Meanless 0';'Meanfull 1';'Meanless 1';'Meanfull 2';'Meanless 2'});
legend('Schizophrenia','Control');